unit SummariseClumps;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TSummariseClumpsForm = class(TForm)
    ComboClumpField: TComboBox;
    Label1: TLabel;
    RadioReportType: TRadioGroup;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    Label2: TLabel;
    EditOutputFileName: TEdit;
    ButtonBrowse: TButton;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure ButtonBrowseClick(Sender: TObject);
    procedure BitBtnOkClick(Sender: TObject);
    procedure ReportSummariseClumps;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SummariseClumpsForm: TSummariseClumpsForm;

implementation

uses
    Control, global, ds;

{$R *.DFM}

procedure TSummariseClumpsForm.FormCreate(Sender: TObject);
var
   iCount : integer;
begin
     // load the available fields from the site table for user to choose from
     ComboClumpField.Items.Clear;
     ControlForm.OutTable.Open;
     for iCount := 1 to ControlForm.OutTable.FieldCount do
     begin
          ComboClumpField.Items.Add(ControlForm.OutTable.FieldDefs.Items[iCount-1].Name);
     end;
     ControlForm.OutTable.Close;
     ComboClumpField.Text := ComboClumpField.Items.Strings[0];
end;

procedure TSummariseClumpsForm.ButtonBrowseClick(Sender: TObject);
begin
     SaveDialog1.InitialDir := ControlRes^.sWorkingDirectory;
     if SaveDialog1.Execute then
     begin
          EditOutputFileName.Text := SaveDialog1.FileName;
          // add a .csv extension if it doesn't exist
          if (ExtractFileExt(EditOutputFileName.Text) = '') then
             EditOutputFileName.Text := EditOutputFileName.Text + '.csv';
     end;
end;

procedure TSummariseClumpsForm.ReportSummariseClumps;
var
   OutFile : TextFile;
   ClumpNames, ClumpAmount : Array_t;
   rClumpAmount : extended;
   iClumpNumber, iCount, iClumpCount, iFCount : integer;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   sClumpName, sClump : string[255];
   Value : ValueFile_T;

   function ClumpNameKnown : boolean;
   var
      iClumpCount : integer;
   begin
        Result := False;
        if (iClumpNumber > 0) then
        begin
             for iClumpCount := 1 to iClumpNumber do
             begin
                  ClumpNames.rtnValue(iClumpCount,@sClumpName);
                  if (sClumpName = sClump) then
                     Result := True;
             end;
        end;
   end;

   procedure InitClumpAmount;
   var
      iClumpCount : integer;
   begin
        rClumpAmount := 0;
        for iClumpCount := 1 to iFeatureCount do
            ClumpAmount.setValue(iClumpCount,@rClumpAmount);
   end;

begin
     // make array of clumps and label each one
     iClumpNumber := 0;
     ClumpNames := Array_t.Create;
     ClumpNames.init(sizeof(sClumpName),iSiteCount);

     ClumpAmount := Array_t.Create;
     ClumpAmount.init(SizeOf(extended),iFeatureCount);

     ControlForm.OutTable.Open;
     repeat
           sClump := ControlForm.OutTable.FieldByName(ComboClumpField.Text).AsString;
           if not ClumpNameKnown then
           begin
                // add this clump name to the list of clumps because it is not yet known
                Inc(iClumpNumber);
                ClumpNames.setValue(iClumpNumber,@sClump);
           end;
           ControlForm.OutTable.Next;

     until ControlForm.OutTable.EOF;
     ControlForm.OutTable.Close;
     if (iClumpNumber < ClumpNames.lMaxSize) then
        ClumpNames.resize(iClumpNumber);

     // create and populate the output file
     assignfile(OutFile,EditOutputFileName.Text);
     rewrite(OutFile);
     // write the header row of the file
     write(OutFile,'ClumpName');
     new(pFeat);
     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,pFeat);
          write(OutFile,',' + pFeat^.sID);
     end;
     writeln(OutFile);

     new(pSite);
     for iClumpCount := 1 to iClumpNumber do // for each clump
     begin
          InitClumpAmount; // init clump amount before processing each clump
          ClumpNames.rtnValue(iClumpCount,@sClump);
          ControlForm.OutTable.Open;
          for iCount := 1 to iSiteCount do // for each site
          begin
               sClumpName := ControlForm.OutTable.FieldByName(ComboClumpField.Text).AsString;
               if (sClumpName = sClump) then
               begin
                    SiteArr.rtnValue(iCount,pSite);
                    if (pSite^.richness > 0) then
                       for iFCount := 1 to pSite^.richness do // for each feature at each site
                       begin
                            FeatureAmount.rtnValue(pSite^.iOffSet + iFCount,@Value);  // accumulate the feature amount
                            ClumpAmount.rtnValue(Value.iFeatKey,@rClumpAmount);
                            rClumpAmount := rClumpAmount + Value.rAmount;
                            ClumpAmount.setValue(Value.iFeatKey,@rClumpAmount);
                       end;
               end;
               ControlForm.OutTable.Next;
          end;
          // write this clumps feature amount row to the output matrix
          write(OutFile,sClump);
          for iFCount := 1 to iFeatureCount do
          begin
               ClumpAmount.rtnValue(iFCount,@rClumpAmount);

               // determine whether presence/abscence or hectare report
               if (rClumpAmount > 0) then
               begin
                    if (RadioReportType.ItemIndex = 0) then // express as presence/abscence
                       rClumpAmount := 1;
                    if (RadioReportType.ItemIndex = 2) then // express as percentage of target
                    begin
                         FeatArr.rtnValue(iFCount,pFeat);
                         if (pFeat^.rCutOff > 0) then
                            rClumpAmount := rClumpAmount / pFeat^.rCutOff * 100;
                    end;
               end;

               write(OutFile,',' + FloatToStr(rClumpAmount));
          end;
          writeln(OutFile);
          ControlForm.OutTable.Close;
     end;

     // close output file and destroy temporary objects used
     dispose(pSite);
     dispose(pFeat);
     closefile(OutFile);
     ClumpNames.Destroy;
     ClumpAmount.Destroy;
end;

procedure TSummariseClumpsForm.BitBtnOkClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;

        ReportSummariseClumps;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Report Clump Summary',mtError,[mbOk],0);
     end;
end;

end.
