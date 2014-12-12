unit randinfo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Spin,
  ds;

type
  TRandomSelectForm = class(TForm)
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    SpinEdit3: TSpinEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    lblProgress: TLabel;
    Memo1: TMemo;
    Label5: TLabel;
    CheckSites: TCheckBox;
    CheckFeatures: TCheckBox;
    procedure BitBtn1Click(Sender: TObject);
    procedure RunRandomSelections(const iLowerBound, iUpperBound, iIterations : integer;
                                  const fReportSites, fReportFeatures : boolean);
    procedure RandomSelect(const iBoundCount : integer);
    procedure ReportIteration(const iBoundCount,iIterationCount : integer;
                              const fReportSites, fReportFeatures : boolean);
    procedure ResetSelections;
    procedure ReportListOfSites(const sFilename : string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RandomSelectForm: TRandomSelectForm;
  SelectedArray : Array_t;

implementation

uses saverpt, Control,
     filectrl, reports, global, calcdef;

{$R *.DFM}

procedure TRandomSelectForm.RunRandomSelections(const iLowerBound, iUpperBound, iIterations : integer;
                                                const fReportSites, fReportFeatures : boolean);
var
   iIterationCount, iBoundCount : integer;
begin
     // run the series of random selections

     SelectedArray := Array_t.Create;
     SelectedArray.init(SizeOf(boolean),iSiteCount);

     for iBoundCount := iLowerBound to iUpperBound do
     begin
          lblProgress.Caption := 'Processing ' + IntToStr(iBoundCount-iLowerBound+1) +
                                 ' of ' + IntToStr(iUpperBound - iLowerBound + 1);
          lblProgress.Update;

          for iIterationCount := 1 to iIterations do
          begin
               RandomSelect(iBoundCount);
               ReportIteration(iBoundCount,iIterationCount,
                               fReportSites, fReportFeatures);
               ResetSelections;
          end;
     end;

     SelectedArray.Destroy;
end;

procedure TRandomSelectForm.RandomSelect(const iBoundCount : integer);
var
   iSelected, iCount, iSelectedSites, iSiteKey : integer;
   fSelected : boolean;
   pSite : sitepointer;
begin
     new(pSite);
     // randomly select iBoundCount sites
     iSelected := 0;

     // init SelectedArray to false
     fSelected := False;
     for iCount := 1 to iSiteCount do
         SelectedArray.setValue(iCount,@fSelected);

     repeat
           // randomly select a site
           iCount := Random(iSiteCount-1)+1;
           SelectedArray.rtnValue(iCount,@fSelected);
           if not fSelected then
           begin
                SiteArr.rtnValue(iCount,pSite);
                if (pSite^.status = Av)
                or (pSite^.status = Fl) then
                begin
                     fSelected := True;
                     SelectedArray.setValue(iCount,@fSelected);
                     Inc(iSelected);
                end;
           end;

     until (iSelected >= iBoundCount);

     // now select all the sites whose flag is true in SelectedArray
     for iCount := 1 to iSiteCount do
     begin
          SelectedArray.rtnValue(iCount,@fSelected);
          if fSelected then
          begin
               // add this site to the list of sites to select
               SiteArr.rtnValue(iCount,pSite);

               CalcDeferrSite(pSite);
          end;
     end;

     { Use
        CalcDeferrSite
        CalcUnDeferrSite
       to adjust targets for selecting and deselecting sets of sites
     }

     dispose(pSite);
end;

procedure TRandomSelectForm.ReportListOfSites(const sFilename : string);
var
   iCount : integer;
   fSelected : boolean;
   pSite : sitepointer;
   ReportFile : TextFile;
   sLine : string;
begin
     // report the list of sites selected from this iteration as a csv file
     AssignFile(ReportFile,sFilename);
     rewrite(ReportFile);
     writeln(ReportFile,'SiteKey,Selected');
     new (pSite);

     for iCount := 1 to iSiteCount do
     begin
          SelectedArray.rtnValue(iCount,@fSelected);
          SiteArr.rtnValue(iCount,pSite);

          sLine := IntToStr(pSite^.iKey) + ',';
          if fSelected then
             sLine := sLine + 'True'
          else
              sLine := sLine + 'False';
          writeln(ReportFile,sLine);
     end;

     CloseFile(ReportFile);
     dispose(pSite);
end;

procedure TRandomSelectForm.ReportIteration(const iBoundCount,iIterationCount : integer;
                                            const fReportSites, fReportFeatures : boolean);
var
   sReportDir, sReportName : string;
begin
     // run a target report for this bound and iteration
     sReportDir := ControlRes^.sWorkingDirectory +
                   '\random' +
                   IntToStr(iBoundCount);
     ForceDirectories(sReportDir);
     sReportName := IntToStr(iBoundCount) +
                    '_' +
                    IntToStr(iIterationCount) + '.csv';

     // report the list of sites selected
     if fReportSites then
        ReportListOfSites(sReportDir + '\Sites' + sReportName);

     // generate the feature target report
     if fReportFeatures then
        ReportFeatures(sReportDir + '\Features' + sReportName,
                       'sites ' + IntToStr(iBoundCount) + '  iteration ' + IntToStr(iIterationCount),
                       FALSE,
                       ControlForm.UseFeatCutOffs.Checked,
                       FeatArr,
                       iFeatureCount,
                       rPercentage,
                       '');
end;

procedure TRandomSelectForm.ResetSelections;
var
   iCount : integer;
   fSelected : boolean;
   pSite : sitepointer;
begin
     new(pSite);
     // reset the selections so we can do some more

     // now de-select all the sites whose flag is true in SelectedArray
     for iCount := 1 to iSiteCount do
     begin
          SelectedArray.rtnValue(iCount,@fSelected);
          if fSelected then
          begin
               // add this site to the list of sites to select
               SiteArr.rtnValue(iCount,pSite);

               CalcUnDeferrSite(pSite);
          end;
     end;

     dispose(pSite);
end;

procedure TRandomSelectForm.BitBtn1Click(Sender: TObject);
begin
     Screen.Cursor := crHourglass;

     Memo1.Visible := False;
     lblProgress.Caption := 'Starting...';
     //lblProgress.Update;
     Update;

     //Randomize;

     RunRandomSelections(SpinEdit1.Value,
                         SpinEdit2.Value,
                         SpinEdit3.Value,
                         CheckSites.Checked,
                         CheckFeatures.Checked);

     lblProgress.Caption := 'Finished!';
     lblProgress.Update;

     Screen.Cursor := crDefault;
end;

end.
