unit random_selection;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TRandomSelectionForm = class(TForm)
    RadioStoppingCondition: TRadioGroup;
    EditIterations: TEdit;
    LabelIterations: TLabel;
    EditResourceLimit: TEdit;
    LabelResourceLimit: TLabel;
    LabelResourceField: TLabel;
    ComboResourceField: TComboBox;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    Label1: TLabel;
    EditRuns: TEdit;
    procedure RadioStoppingConditionClick(Sender: TObject);
    procedure BitBtnOkClick(Sender: TObject);
    procedure ExecuteRandomSelection;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RandomSelectionForm: TRandomSelectionForm;

implementation

uses
    Control, Em_newu1, OrdClass, Sf_irrep, Reports, Global,
    Dll_u1;

{$R *.DFM}

procedure PopulateResourceField;
var
   iCount : integer;
begin
     // add all the fields from the site summary table to the drop down list box
     ControlForm.OutTable.Open;

     for iCount := 1 to ControlForm.OutTable.FieldCount do
         RandomSelectionForm.ComboResourceField.Items.Add(ControlForm.OutTable.FieldDefs.Items[iCount-1].Name);
     RandomSelectionForm.ComboResourceField.Text := ControlForm.OutTable.FieldDefs.Items[0].Name;

     ControlForm.OutTable.Close;
end;

procedure TRandomSelectionForm.RadioStoppingConditionClick(
  Sender: TObject);
begin
     LabelIterations.Visible := False;
     EditIterations.Visible := False;
     EditResourceLimit.Visible := False;
     LabelResourceLimit.Visible := False;
     LabelResourceField.Visible := False;
     ComboResourceField.Visible := False;

     case RadioStoppingCondition.ItemIndex of
          0 : begin
              end;
          1 : begin
                   LabelIterations.Visible := True;
                   EditIterations.Visible := True;
              end;
          2 : begin
                   EditResourceLimit.Visible := True;
                   LabelResourceLimit.Visible := True;
                   LabelResourceField.Visible := True;
                   PopulateResourceField;
                   ComboResourceField.Visible := True;
              end;
     end;
end;

procedure RestoreStartingSelections;
var
   fCancel, fRetainClass, fCancelPressed : boolean;
   wTmp : integer;
   sRetainClass : string;
begin
     fRetainClass := ControlRes^.fFeatureClassesApplied;
     sRetainClass := ControlRes^.sFeatureClassField;

     fSelectionChange := False;
     fFlagSelectionChange := False;
     {selections do not need to be saved}
     fContrDataDone := False;
     {data in contribution objects needs to be updated}

     LoadSelections(ControlRes^.sWorkingDirectory + '\random_selection_start.log');
     LabelCountUpdate;

     RePrepIrrepData;

     if fRetainClass then
     begin
          LoadOrdinalClass(sRetainClass,ControLRes^.ClassDetail);
          ControlRes^.fFeatureClassesApplied := True;
          ControlRes^.sFeatureClassField := sRetainClass;
     end;

     ExecuteIrreplaceability(-1,False,False,True,True,'');
end;

procedure InitSiteStatusReport;
var
   SiteStatusReport : TextFile;
   iCount : integer;
   pSite : sitepointer;
begin
     new(pSite);

     assignfile(SiteStatusReport,ControlRes^.sWorkingDirectory + '\sites_all_runs.csv');
     rewrite(SiteStatusReport);
     writeln(SiteStatusReport,'SITEKEY');

     for iCount := 1 to iSiteCount do
     begin
          SiteArr.rtnValue(iCount,pSite);
          writeln(SiteStatusReport,IntToStr(pSite^.iKey));
     end;

     closefile(SiteStatusReport);

     dispose(pSite);
end;

procedure UpdateSiteStatusReport(const iRun : integer);
var
   SiteStatusReport, TmpFile : TextFile;
   iCount : integer;
   pSite : sitepointer;
   sLine : string;
begin
     new(pSite);

     assignfile(SiteStatusReport,ControlRes^.sWorkingDirectory + '\sites_all_runs.csv');
     reset(SiteStatusReport);
     readln(SiteStatusReport,sLine);

     assignfile(TmpFile,ControlRes^.sWorkingDirectory + '\tmp1.csv');
     rewrite(TmpFile);
     writeln(TmpFile,sLine + ',Status Run ' + IntToStr(iRun));

     for iCount := 1 to iSiteCount do
     begin
          SiteArr.rtnValue(iCount,pSite);
          readln(SiteStatusReport,sLine);
          writeln(TmpFile,sLine + ',' + Status2Str(pSite^.status));
     end;

     closefile(SiteStatusReport);
     closefile(TmpFile);

     DeleteFile(ControlRes^.sWorkingDirectory + '\sites_all_runs.csv');
     RenameFile(ControlRes^.sWorkingDirectory + '\tmp1.csv',ControlRes^.sWorkingDirectory + '\sites_all_runs.csv');

     dispose(pSite);
end;

procedure InitTargetAreaReport;
var
   TargetAreaReport : TextFile;
   iCount : integer;
   pFeat : featureoccurrencepointer;
begin
     new(pFeat);

     assignfile(TargetAreaReport,ControlRes^.sWorkingDirectory + '\features_all_runs.csv');
     rewrite(TargetAreaReport);
     writeln(TargetAreaReport,'FEATKEY');

     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,pFeat);
          writeln(TargetAreaReport,IntToStr(pFeat^.code));
     end;

     closefile(TargetAreaReport);

     dispose(pFeat);
end;

procedure UpdateTargetAreaReport(const iRun : integer);
var
   TargetAreaReport, TmpFile : TextFile;
   iCount : integer;
   pFeat : featureoccurrencepointer;
   sLine : string;
begin
     new(pFeat);

     assignfile(TargetAreaReport,ControlRes^.sWorkingDirectory + '\features_all_runs.csv');
     reset(TargetAreaReport);
     readln(TargetAreaReport,sLine);

     assignfile(TmpFile,ControlRes^.sWorkingDirectory + '\tmp1.csv');
     rewrite(TmpFile);
     writeln(TmpFile,sLine + ',Target Run ' + IntToStr(iRun));

     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,pFeat);
          readln(TargetAreaReport,sLine);
          writeln(TmpFile,sLine + ',' + FloatToStr(pFeat^.targetarea));
     end;

     closefile(TargetAreaReport);
     closefile(TmpFile);

     DeleteFile(ControlRes^.sWorkingDirectory + '\features_all_runs.csv');
     RenameFile(ControlRes^.sWorkingDirectory + '\tmp1.csv',ControlRes^.sWorkingDirectory + '\features_all_runs.csv');

     dispose(pFeat);
end;

procedure TRandomSelectionForm.ExecuteRandomSelection;
var
   iNumberOfRuns, iCount : integer;

   procedure SelectASite;
   begin
        // highlight a random available site
        ControlForm.Available.Selected[Random(ControlForm.Available.Items.Count)] := True;

        // select the available site into the R1 reserve class
        ControlRes^.sLastChoiceType := 'Random Selection';
        ControlForm.MoveGroup(ControlForm.Available,ControlForm.AvailableKey,ControlForm.R1,ControlForm.R1Key,False,True);
   end;

   function StoppingConditionReached : boolean;
   begin
        // Return True if stopping condition reached
        Result := False;

        case RadioStoppingCondition.ItemIndex of
             0 : ; // all features met
             1 : ; // number of iterations
             2 : ; // resource limit
        end;
   end;

begin
     try
        Screen.Cursor := crHourglass;

        // save starting log file
        SaveSelections(ControlRes^.sWorkingDirectory + '\random_selection_start.log',False);
        try
           iNumberOfRuns := StrToInt(EditRuns.Text);
        except
              iNumberOfRuns := 1;
        end;

        // start the site and feature summary reports
        InitTargetAreaReport;
        InitSiteStatusReport;

        // clear any highlighted sites in the control form
        UnHighlight(ControlForm.Available,False);
        UnHighlight(ControlForm.R1,False);
        UnHighlight(ControlForm.R2,False);
        UnHighlight(ControlForm.R3,False);
        UnHighlight(ControlForm.R4,False);
        UnHighlight(ControlForm.R5,False);
        UnHighlight(ControlForm.Excluded,False);
        UnHighlight(ControlForm.Partial,False);
        UnHighlight(ControlForm.Flagged,False);
        UnHighlight(ControlForm.Reserved,False);
        UnHighlight(ControlForm.Ignored,False);

        for iCount := 1 to iNumberOfRuns do
        begin
             // perform random selections until the stopping condition is reached
             repeat
                   SelectASite;

             until StoppingConditionReached;

             // save log file
             SaveSelections(ControlRes^.sWorkingDirectory + '\run' + IntToStr(iCount) + '.log',False);
             // generate the comprehensive feature report file
             ReportFeatures(ControlRes^.sWorkingDirectory + '\features_run' + IntToStr(iCount) + '.csv',
                            'Run ' + IntToStr(iCount),
                            TRUE,
                            ControlForm.UseFeatCutOffs.Checked,
                            FeatArr,
                            iFeatureCount,
                            rPercentage,
                            '');
             // update the site and feature summary reports
             UpdateTargetAreaReport(iCount);
             UpdateSiteStatusReport(iCount);
             // restore starting log file
             RestoreStartingSelections;
        end;

        // delete starting log file
        //DeleteFile(ControlRes^.sWorkingDirectory + '\random_selection_start.log');

        Screen.Cursor := crDefault;

        MessageDlg('Random Selection Executed Ok',mtInformation,[mbOk],0);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Random Selection',mtError,[mbOk],0);
     end;
end;

procedure TRandomSelectionForm.BitBtnOkClick(Sender: TObject);
begin
     ExecuteRandomSelection;
end;

end.
