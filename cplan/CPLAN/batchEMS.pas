unit batchEMS;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Menus;

const
     DEFAULT_PANEL_WIDTH = 41;

type
  TBatchEMSForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OpenSelections: TOpenDialog;
    SelectionFileBox: TListBox;
    CheckShapeFile: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure ParseFromFile(const sFile : string);
    procedure Report;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BatchEMSForm: TBatchEMSForm;

implementation

uses
    Global, Control, Choices, Highligh,
    Sf_irrep, em_newu1, FileCtrl, reports,
    Dll_u1;

{$R *.DFM}

procedure TBatchEMSForm.ParseFromFile(const sFile : string);
var
   InFile : TextFile;
   sLine : string;
begin
     // add to SelectionFileBox
     assignfile(InFile,sFile);
     reset(InFile);

     SelectionFileBox.Items.Clear;

     repeat
           readln(InFile,sLine);
           // add file to the list if it doesn't already exist in the list
           if (SelectionFileBox.Items.IndexOf(sLine) = -1) then
              SelectionFileBox.Items.Add(sLine);

     until Eof(InFile);

     CloseFile(InFile);
end;

procedure TBatchEMSForm.Button1Click(Sender: TObject);
begin
     // load a list of selection files
     OpenSelections.InitialDir := ControlRes^.sWorkingDirectory;
     if OpenSelections.Execute then
        SelectionFileBox.Items.LoadFromFile(OpenSelections.Filename);
end;

procedure TBatchEMSForm.BitBtn1Click(Sender: TObject);
begin
     Report;
end;

function ExtractSelectionName(const sSelectionFileName : string) : string;
var
   iPos : integer;
begin
     // Selection file name needs to have the leading path and trailing extension removed
     // ie. the name of the EMS file or selection file

     // trim the path
     Result := ExtractFileName(sSelectionFileName);
     // trim the extension
     iPos := Pos('.',Result);
     if (iPos > 0) then
        Result := Copy(Result,1,iPos-1);
end;

procedure TBatchEMSForm.Report;
var
   iCount : integer;
   sCurrentOutputDirectory, sSelectionName, sDescr,
   sExtension, sSelectionFile, sBackupFile : string;
begin
     // generate a set of reports for each selection file specified in the list
     try
        // save a backup file of current state
        sBackupFile := ControlRes^.sWorkingDirectory + '\backup_selections.log';
        SaveSelections(sBackupFile,False);

        if (SelectionFileBox.Items.Count > 0) then
           for iCount := 0 to (SelectionFileBox.Items.Count-1) do
           begin
                sSelectionFile := SelectionFileBox.Items.Strings[iCount];

                if FileExists(sSelectionFile) then
                begin
                     // re-init C-Plan with no selections
                     //ChoiceForm.ChoiceLog.Items.Clear;

                     // load selections from specified selection file
                     if (Length(sSelectionFile) > 4) then
                        sExtension := LowerCase(Copy(sSelectionFile,Length(sSelectionFile)-2,3))
                     else
                         sExtension := '';
                     if (sExtension = 'ems')
                     or (sExtension = 'log') then
                     begin
                          // file is a LOG file
                          LoadSelections(sSelectionFile);
                          LabelCountUpdate;
                          CheckSelections;
                     end
                     else
                     with ControlForm do
                     begin
                          // de-select all sites before doing a load highlight
                          MoveAll(R1,R1Key,Available,AvailableKey,False);
                          MoveAll(R2,R2Key,Available,AvailableKey,False);
                          MoveAll(R3,R3Key,Available,AvailableKey,False);
                          MoveAll(R4,R4Key,Available,AvailableKey,False);
                          MoveAll(R5,R5Key,Available,AvailableKey,False);
                          MoveAll(Excluded,ExcludedKey,Available,AvailableKey,False);
                          MoveAll(Flagged,FlaggedKey,Available,AvailableKey,False);
                          MoveAll(Partial,PartialKey,Available,AvailableKey,False);

                          // file is an ascii file
                          LoadHighlight(sSelectionFile,LOAD_GEOCODE,False);
                          ControlRes^.sLastChoiceType := 'Highlight from file ' + sSelectionFile;
                          MoveGroup(Available,AvailableKey,R1,R1Key,False,True);
                     end;

                     // recalc irreplaceability
                     RePrepIrrepData;
                     ExecuteIrreplaceability(-1,False,False,True,True,'');

                     // report all reports for this set of selections
                     // Output directory will be :
                     //    working directory\selection name\
                     //
                     // where selection name has had the leading path and trailing extension removed
                     // ie. the name of the EMS file or selection file
                     sDescr := 'Selection ' + sSelectionName;
                     sSelectionName := ExtractSelectionName(sSelectionFile);
                     sCurrentOutputDirectory := ControlRes^.sWorkingDirectory + '\' +
                                                sSelectionName;
                     ForceDirectories(sCurrentOutputDirectory);
                     if not FileExists(sCurrentOutputDirectory + '\' + sSelectionName + '_count.CSV') then
                     begin
                          ReportTotals(sCurrentOutputDirectory + '\' + sSelectionName + '_count.CSV',sDescr,TRUE,
                                       ControlForm.ReportBox, SiteArr, iSiteCount,
                                       iIr1Count,i001Count,i002Count,i003Count,
                                       i004Count,i005Count,i0CoCount,
                                       ControlForm.Available.Items.Count,
                                       ControlForm.Flagged.Items.Count,
                                       ControlForm.Reserved.Items.Count,
                                       ControlForm.Ignored.Items.Count,
                                       ControlForm.R1.Items.Count,
                                       ControlForm.R2.Items.Count,
                                       ControlForm.R3.Items.Count,
                                       ControlForm.R4.Items.Count,
                                       ControlForm.R5.Items.Count,
                                       ControlForm.Partial.Items.Count,
                                       ControlForm.Excluded.Items.Count);
                          ReportSites(sCurrentOutputDirectory + '\' + sSelectionName + '_site.CSV',sDescr,TRUE,
                                       ControlForm.OutTable, iSiteCount, SiteArr, ControlRes,'');
                          ReportFeatures(sCurrentOutputDirectory + '\' + sSelectionName + '_feature.CSV',sDescr,TRUE,
                                        ControlForm.UseFeatCutOffs.Checked, FeatArr, iFeatureCount,
                                        rPercentage,
                                        '');
                          if (ControlForm.Partial.Items.Count > 0) then
                             ReportPartial(sCurrentOutputDirectory + '\' + sSelectionName + '_partial.TXT',sDescr,TRUE,
                                        ControlForm.ReportBox, ControlForm.PartialKey,
                                        SiteArr, FeatArr, OrdSiteArr, OrdFeatArr);
                          SaveSelections(sCurrentOutputDirectory + '\' + sSelectionName + '.log',FALSE);
                          // copy the shape file dbf to this subdirectory if we are linked to ArcView
                          if CheckShapeFile.Checked then
                             if (ControlRes^.GISLink = ArcView) then
                                ACopyFile(ControlRes^.sDatabase + '\' + ControlRes^.sShpTable,
                                          sCurrentOutputDirectory + '\' + ControlRes^.sShpTable);
                     end;
                end;
           end;

        // restore state that existed before list of stages were loaded
        LoadSelections(sBackupFile);
        LabelCountUpdate;
        RePrepIrrepData;
        ExecuteIrreplaceability(-1,False,False,True,True,'');
        DeleteFile(sBackupFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TBatchEMSForm.Report',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

end.
