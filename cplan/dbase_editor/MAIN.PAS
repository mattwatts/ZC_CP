unit Main;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileCloseItem: TMenuItem;
    Window1: TMenuItem;
    Help1: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    WindowCascadeItem: TMenuItem;
    WindowTileItem: TMenuItem;
    WindowArrangeItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    OpenDialog: TOpenDialog;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    WindowMinimizeItem: TMenuItem;
    SpeedPanel: TPanel;
    OpenBtn: TSpeedButton;
    SaveBtn: TSpeedButton;
    CutBtn: TSpeedButton;
    CopyBtn: TSpeedButton;
    PasteBtn: TSpeedButton;
    ExitBtn: TSpeedButton;
    StatusBar: TStatusBar;
    AutoFitTable1: TMenuItem;
    TemporaryFiles: TListBox;
    Wizards1: TMenuItem;
    BuildCPlanDatabase1: TMenuItem;
    SaveDialog: TSaveDialog;
    Importintotable1: TMenuItem;
    JoinTable1: TMenuItem;
    Table1: TMenuItem;
    FieldProperties1: TMenuItem;
    SetWorkingDirectory1: TMenuItem;
    ImportDialog: TOpenDialog;
    ExportDialog: TSaveDialog;
    Import1: TMenuItem;
    Export1: TMenuItem;
    Utilities: TMenuItem;
    JoinMtxFiles1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FileNewItemClick(Sender: TObject);
    procedure WindowCascadeItemClick(Sender: TObject);
    procedure UpdateMenuItems(Sender: TObject);
    procedure WindowTileItemClick(Sender: TObject);
    procedure WindowArrangeItemClick(Sender: TObject);
    procedure FileCloseItemClick(Sender: TObject);
    procedure FileOpenItemClick(Sender: TObject);
    procedure FileExitItemClick(Sender: TObject);
    procedure FileSaveItemClick(Sender: TObject);
    procedure FileSaveAsItemClick(Sender: TObject);
    procedure CutItemClick(Sender: TObject);
    procedure CopyItemClick(Sender: TObject);
    procedure PasteItemClick(Sender: TObject);
    procedure WindowMinimizeItemClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpAboutItemClick(Sender: TObject);
    procedure FormDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure AutoFitTable1Click(Sender: TObject);
    procedure ConvertCsvFile(const sInputFile : string;
                             var sOutputFile : string);
    procedure ConvertMtxFile(const sInputFile : string;
                             var sOutputFile : string);
    function AssignTempFile(const sExt : string) : string;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BuildCPlanDatabase1Click(Sender: TObject);
    procedure SaveActiveChild;
    procedure SaveAsActiveChild;
    procedure Importintotable1Click(Sender: TObject);
    procedure FieldProperties1Click(Sender: TObject);
    function ReturnChildIndex(const sChild : string) : integer;
    procedure FormActivate(Sender: TObject);
    procedure CreateMDIChild(const Name, sNewName: string;
                             const fAllowUserToSelectSubsetOfFields : boolean);
    procedure SetWorkingDirectory1Click(Sender: TObject);
    procedure Import1Click(Sender: TObject);
    procedure Export1Click(Sender: TObject);
    function rtnUniqueDbfName(const sPath, sFile : string) : string;
    procedure LoadWIZFile(const sWIZFileName : string);
    procedure JoinMtxFiles1Click(Sender: TObject);
  private
    { Private declarations }
    procedure ShowHint(Sender: TObject);
    procedure LoadWorkingDirectory;
    procedure SaveWorkingDirectory;
  public
    { Public declarations }
    fStarting,
    fUseDefaultImportNames : boolean;
    sWorkingDirectory : string;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

uses ChildWin, About, UserSelectFields, converter, buildcplanwizard,
  importintotablewizard, ds, fieldproperties, workdir,
  FileCtrl, inifiles, reg, import_file, joinmtx;

function TMainForm.ReturnChildIndex(const sChild : string) : integer;
var
   iCount : integer;
begin
     // returns zero-based index of the child specified
     // if child not loaded, returns -1
     // NOTE : could be modified to load the file in this case and then return the index
     Result := -1;
     if (MDIChildCount > 0) then
        for iCount := 0 to (MDIChildCount - 1) do
            if (TMDIChild(MDIChildren[iCount]).sFilename = sChild) then
               Result := iCount;
end;

function TMainForm.AssignTempFile(const sExt : string) : string;
var
   sPath, sRandomString : string;
   iCount, iCharacters : integer;
begin
     try
        sPath := 'c:\';

        repeat
              iCharacters := Random(6) + 1;
              sRandomString := '';
              for iCount := 1 to iCharacters do
                  sRandomString := sRandomString + Chr(Random(26) + Ord('a'));
              Result := sPath + sRandomString + sExt;

        until (not FileExists(Result));

        // add this temporary file name to the list so we can delete it later
        TemporaryFiles.Items.Add(Result);

     except
     end;
end;

procedure TMainForm.LoadWIZFile(const sWIZFileName : string);
var
   AIni : TIniFile;
   sTmp, sShpFile, sShpKey, sGridFile, sGridKey : string;
   iGrid : integer;
begin
     try
        AIni := TIniFile.Create(sWIZFileName);

        sShpFile := AIni.ReadString('Build C-Plan Database','UserShpName','');
        sShpKey := AIni.ReadString('Build C-Plan Database','UserShpKey','');

        iGrid := 1;
        repeat
              sTmp := AIni.ReadString('Build C-Plan Database','Feature' + IntToStr(iGrid) + 'Name','');
              if (sTmp <> '') then
              begin
                   sGridFile := AIni.ReadString('Build C-Plan Database','Feature' + IntToStr(iGrid) + 'TabulateAreaFile','');
                   sGridKey := AIni.ReadString('Build C-Plan Database','Feature' + IntToStr(iGrid) + 'Key','');

                   // load the dbf tabulate area report into the database tool
                   CreateMDIChild(sGridFile,'',False);

                   Inc(iGrid);
              end;

        until (sTmp = '');

        // create Build C-Plan Database Wizard form
        BuildCPlanWizardForm := TBuildCPlanWizardForm.Create(Application);

        BuildCPlanWizardForm.WizardParamCall;

        // instruct user to finish entering Wizard settings and complete build
        MessageDlg('Complete the steps in the wizard to finish building your database',mtInformation,[mbOk],0);
        BuildCPlanWizardForm.ShowModal;
        BuildCPlanWizardForm.Free;

        AIni.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in BuildCPlanDatabase',mtError,[mbOk],0);
     end;
end;

procedure TMainForm.LoadWorkingDirectory;
var
   AIni : TIniFile;
begin
     // load working directory
     AIni := TIniFile.Create('database_tool.ini');
     sWorkingDirectory := AIni.ReadString('Database Tool','Working Directory',sWorkingDirectory);
     AIni.Free
end;

procedure TMainForm.SaveWorkingDirectory;
var
   AIni : TIniFile;
begin
     // save working directory
     AIni := TIniFile.Create('database_tool.ini');
     AIni.WriteString('Database Tool','Working Directory',sWorkingDirectory);
     AIni.Free
end;

function RunCPlanApp(const sApp : string) : boolean;
var
   sRunFile, sPath : string;
   PCmd : PChar;
   AIniFile : TIniFile;
begin
     AIniFile := TIniFile.Create('cplandb.ini');

     sPath := AIniFile.ReadString('Paths','32bit','');
     sRunFile := sPath + '\' + sApp + '.exe';

     AIniFile.Free;

     if FileExists(sRunFile) then
     begin
          GetMem(PCmd,Length(sRunFile)+1);
          StrPCopy(PCmd,sRunFile);

          WinEXEC(PCmd,SW_SHOW);

          FreeMem(PCmd,Length(sRunFile)+1);

          Result := True;
     end
     else
         Result := False;
end;


procedure TMainForm.FormCreate(Sender: TObject);
begin
     if IsValidRegFile then
     begin
          // set a default working directory
          sWorkingDirectory := ExtractFileDir(Application.ExeName);
          // attempt to load a user defined working directory from the ini file
          LoadWorkingDirectory;                       
          Application.OnHint := ShowHint;
          Screen.OnActiveFormChange := UpdateMenuItems;
          Randomize;
          fStarting := True;
          fUseDefaultImportNames := False;
     end
     else
     begin
          if not RunCPlanApp('register') then
          begin

          end;

          Application.Terminate;
          exit;
     end;
end;

procedure TMainForm.ShowHint(Sender: TObject);
begin
  StatusBar.SimpleText := Application.Hint;
end;


procedure TMainForm.ConvertCsvFile(const sInputFile : string;
                                   var sOutputFile : string);
begin
     try
        // if sOutputFile = '' make up a temporary filename, or else
        // use the one passed

        if (sOutputFile = '') then
           sOutputFile := AssignTempFile('.dbf');

        //ConvertModule := TConvertModule.Create(Application);
        ConvertModule.Delimited2DBF(sInputFile, sOutputFile,',');
        //ConvertModule.Free;

     except
     end;
end;

procedure TMainForm.ConvertMtxFile(const sInputFile : string;
                                   var sOutputFile : string);
begin
     try
        // if sOutputFile = '' make up a temporary filename, or else
        // use the one passed

        if (sOutputFile = '') then
           sOutputFile := rtnUniqueDbfName(TrimTrailingSlashes(ExtractFilePath(sInputFile)),
                                           ExtractFileName(sInputFile));

        //ConvertModule := TConvertModule.Create(Application);
        ConvertModule.MTX2DBF(sInputFile,',',sOutputFile);
        //ConvertModule.Free;

     except
     end;
end;

procedure ReplaceSpaceWithUnderscore(var sItem : string);
var
   iPos : integer;
begin
     repeat
           iPos := Pos(' ',sItem);

           if (iPos > 0) then
              // replace the space with an underscore
              sItem[iPos] := '_';
     until (iPos = 0);
end;

function TMainForm.rtnUniqueDbfName(const sPath, sFile : string) : string;
var
   iCount, iPos : integer;
   sFileToTry, sFileNoExt, sUniquePathFile : string;
begin
     iPos := Pos('.',sFile);
     if (iPos > 0) then
     begin
          sFileNoExt := Copy(sFile,1,iPos-1);
          ReplaceSpaceWithUnderscore(sFileNoExt);

          iCount := -1;
          // determine unique file name in case we need it
          repeat
                Inc(iCount);
                sUniquePathFile := TrimTrailingSlashes(sPath) + '\' + sFileNoExt + IntToStr(iCount) + '.dbf';

          until not fileexists(sUniquePathFile);

          sFileToTry := TrimTrailingSlashes(sPath) + '\' + sFileNoExt + '.dbf';
          if fileexists(sFileToTry) then
          begin
               // ask user if they want to overwrite the file
               {if (mrYes = MessageDlg('While importing the file ' + sFile +
                                      ', a temporary file needs to be created (' + sFileToTry +
                                      ') but a file with this name already exists.' +
                                      '  Overwrite it or use  ' +
                                      sUniquePathFile + ' ?',
                                      mtConfirmation,[mbYes,mbNo],0)) then
               begin
                    // the file already exists, but the user wants to overwrite it
                    deletefile(sFileToTry);
                    Result := sFileToTry;
               end
               else}
               begin
                    // use the unique filename we have generated above
                    Result := sUniquePathFile;
               end;
          end
          else
          begin
               // the import filename does not exist, so use it
               Result := sFileToTry;
          end;
     end
     else
     begin
          // there is no extension in the file
          Result := TrimTrailingSlashes(sPath) + '\' + sFile + '.dbf';
     end;

     TemporaryFiles.Items.Add(Result);
end;

function FilenameContainsSpace(const sPathAndFilename : string) : boolean;
var
   sTmp : string;
begin
     // Result TRUE means filename contains space
     //        FALSE doesn't
     Result := (Pos(' ',ExtractFileName(sPathAndFilename)) > 0);
end;

procedure TMainForm.CreateMDIChild(const Name, sNewName: string;
                                   const fAllowUserToSelectSubsetOfFields : boolean);
var
  AChild: TMDIChild;
  iCount : integer;
  sName, sFilename, sExt, sTmp, sDbfFile : string;
  fContinue : boolean;
begin
     //.DB	Paradox
     //.DBF	dBASE
     //.TXT	ASCII text
     sName := Name;
     sExt := LowerCase(ExtractFileExt(sName));
     { create a new MDI child window }
     if FileExists(sName) then
     begin
          if (sExt = '.csv') then
          begin
               Screen.Cursor := crHourglass;

               sDbfFile := rtnUniqueDbfName(TrimTrailingSlashes(ExtractFilePath(sName)),
                                            ExtractFileName(sName));

               //ConvertModule := TConvertModule.Create(Application);
               if ConvertModule.Delimited2DBF(sName, sDbfFile,',') then
               begin
                    //ConvertModule.Free;
                    //Screen.Cursor := crDefault;
                    CreateMDIChild(sDbfFile,'',False);
               end
               else
               begin
                    //ConvertModule.Free;
                    Screen.Cursor := crDefault;
               end;
               Exit;
          end;

          if (sExt = '.txt') then
          begin
               Screen.Cursor := crHourglass;

               sDbfFile := rtnUniqueDbfName(TrimTrailingSlashes(ExtractFilePath(sName)),
                                            ExtractFileName(sName));

               //ConvertModule := TConvertModule.Create(Application);
               if ConvertModule.Delimited2DBF(sName, sDbfFile,',') then
               begin
                    //ConvertModule.Free;
                    //Screen.Cursor := crDefault;
                    CreateMDIChild(sDbfFile,'',False);
               end
               else
               begin
                    //ConvertModule.Free;
                    Screen.Cursor := crDefault;
               end;
               Exit;
          end;

          if (sExt = '.mtx') then
          begin
               Screen.Cursor := crHourglass;
               sName := '';
               ConvertMtxFile(Name,sName);
               sExt := LowerCase(ExtractFileExt(sName));
               //Screen.Cursor := crDefault;
          end;

          if (sExt = '.db')
          or (sExt = '.dbf')
          {or (sExt = '.txt')} then
             // see if the filename contains a space
             if FilenameContainsSpace(sName) then
             begin
                  MessageDlg('Due to a syntax constraint of the local SQL server, the file ' + Chr(10) + Chr(13) +
                             '"' + ExtractFileName(sName) + Chr(10) + Chr(13) + '"' +
                             'has a space in its name so it cannot be read with this program.' + Chr(10) + Chr(13) +
                             'Please rename the file and then open it.',
                             mtInformation,[mbOk],0);
             end
             else
                 try
                    // get user to select fields from the file
                    fContinue := False;
                    UserSelectFieldsForm := TUserSelectFieldsForm.Create(Application);
                    UserSelectFieldsForm.InitForm(sName);
                    if fAllowUserToSelectSubsetOfFields then
                    begin
                         if (UserSelectFieldsForm.ShowModal = mrOk)
                         and (UserSelectFieldsForm.OutputFields.Items.Count > 0) then
                             fContinue := True;
                    end
                    else
                    begin
                         fContinue := True;
                         UserSelectFieldsForm.AddAllClick(MainForm);
                    end;

                    if fContinue then
                    begin
                         Screen.Cursor := crHourglass;

                         AChild := TMDIChild.Create(Application);
                         AChild.Caption := sName;
                         AChild.sFilename := sName;
                         // remember whether user chose "use all fields" or not
                         AChild.fAllOriginalFieldsUsed := UserSelectFieldsForm.fAllOriginalFieldsUsed;

                         // add the fields the user has selected to the SQL query and make it active
                         with AChild.Query1 do
                         try
                            SQL.Clear;
                            SQL.Add('Select');
                            // list fields from table to select
                            sFilename := ExtractFileName(AChild.Caption);
                            sExt := ExtractFileExt(AChild.Caption);
                            sTmp := Copy(sFilename,
                                         1,
                                         Length(sFilename)- Length(sExt));
                            for iCount := 0 to (UserSelectFieldsForm.OutputFields.Items.Count - 1) do
                            begin
                                 if (iCount = (UserSelectFieldsForm.OutputFields.Items.Count - 1)) then
                                    SQL.Add('"' + sTmp + '".' + '"' + UserSelectFieldsForm.OutputFields.Items.Strings[iCount] + '"')
                                 else
                                     SQL.Add('"' + sTmp + '".' + '"' + UserSelectFieldsForm.OutputFields.Items.Strings[iCount] + '",');
                            end;
                            SQL.Add('From "' + AChild.Caption + '"');
                            SQL.Add('As ' + sTmp);
                            //SQL.Add('order by SITEKEY');

                            Active := False;
                            Active := True;

                         except
                               Screen.Cursor := crDefault;
                               MessageDlg('Could not open table ' + ExtractFileName(sName) + '.  It may be in use by another program.',mtInformation,[mbOk],0);
                               SQL.SaveToFile('c:\exception_in_select.sql');
                               AChild.Free;
                         end;

                         Screen.Cursor := crDefault;
                    end;
                    UserSelectFieldsForm.Free;

                 except
                       Screen.Cursor := crDefault;
                       MessageDlg('Could not open table ' + ExtractFileName(sName) + '.  It may be in use by another program.',mtInformation,[mbOk],0);
                       try
                          AChild.Free;
                       except
                       end;
                 end;
     end;
end;

procedure TMainForm.FileNewItemClick(Sender: TObject);
begin
  CreateMDIChild('NONAME' + IntToStr(MDIChildCount + 1),'',False);
end;

procedure TMainForm.FileOpenItemClick(Sender: TObject);
var
   iCount : integer;
begin
     OpenDialog.InitialDir := sWorkingDirectory;

     if OpenDialog.Execute then
        if (OpenDialog.Files.Count > 0) then
           for iCount := 0 to (OpenDialog.Files.Count - 1) do
               CreateMDIChild(OpenDialog.Files.Strings[iCount],'',False);

  //if OpenDialog.Execute then
  //  CreateMDIChild(OpenDialog.FileName);
end;

procedure TMainForm.FileCloseItemClick(Sender: TObject);
begin
  if ActiveMDIChild <> nil then
    ActiveMDIChild.Close;
end;

procedure TMainForm.FileSaveItemClick(Sender: TObject);
begin
  { save current file (ActiveMDIChild points to the window) }
  SaveActiveChild;
end;

procedure TMainForm.FileSaveAsItemClick(Sender: TObject);
begin
  { save current file under new name }
  SaveAsActiveChild;
end;
 
procedure TMainForm.FileExitItemClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.CutItemClick(Sender: TObject);
begin
  {cut selection to clipboard}
end;

procedure TMainForm.CopyItemClick(Sender: TObject);
begin
  {copy selection to clipboard}
end;

procedure TMainForm.PasteItemClick(Sender: TObject);
begin
  {paste from clipboard}
end;

procedure TMainForm.WindowCascadeItemClick(Sender: TObject);
begin
  Cascade;
end;

procedure TMainForm.WindowTileItemClick(Sender: TObject);
begin
  Tile;
end;

procedure TMainForm.WindowArrangeItemClick(Sender: TObject);
begin
  ArrangeIcons;
end;

procedure TMainForm.WindowMinimizeItemClick(Sender: TObject);
var
  I: Integer;
begin
  { Must be done backwards through the MDIChildren array }
  for I := MDIChildCount - 1 downto 0 do
    MDIChildren[I].WindowState := wsMinimized;
end;

procedure TMainForm.UpdateMenuItems(Sender: TObject);
begin
  FileCloseItem.Enabled := MDIChildCount > 0;
  FileSaveItem.Enabled := MDIChildCount > 0;
  Export1.Enabled := MDIChildCount > 0;
  FileSaveAsItem.Enabled := MDIChildCount > 0;
  CutItem.Enabled := MDIChildCount > 0;
  CopyItem.Enabled := MDIChildCount > 0;
  PasteItem.Enabled := MDIChildCount > 0;
  SaveBtn.Enabled := MDIChildCount > 0;
  CutBtn.Enabled := MDIChildCount > 0;
  CopyBtn.Enabled := MDIChildCount > 0;
  PasteBtn.Enabled := MDIChildCount > 0;
  WindowCascadeItem.Enabled := MDIChildCount > 0;
  WindowTileItem.Enabled := MDIChildCount > 0;
  WindowArrangeItem.Enabled := MDIChildCount > 0;
  WindowMinimizeItem.Enabled := MDIChildCount > 0;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Screen.OnActiveFormChange := nil;
end;

procedure TMainForm.HelpAboutItemClick(Sender: TObject);
begin
  //AboutBox.ShowModal;
end;

procedure TMainForm.FormDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
     // (Sender, Source: TObject; X, Y: Integer) of object;
     MessageDlg('sender ' + Sender.ClassName +
                '  source ' + Source.ClassName,
                mtInformation,[mbYes],0);


end;

procedure TMainForm.FormDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
     MessageDlg('sender ' + Sender.ClassName +
                '  source ' + Source.ClassName,
                mtInformation,[mbYes],0);



end;

procedure TMainForm.AutoFitTable1Click(Sender: TObject);
var
   AChild : TMDIChild;
begin
     {AChild := TMDIChild(ActiveMDIChild);
     if (AChild <> nil) then
        AChild.AutoFitTable(0);}
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
   iCount : integer;
begin
     (*if (TemporaryFiles.Items.Count > 0) then
        {if (mrYes = MessageDlg('Delete files imported while program was running? ' +
                               '(Note: Any changes made to these files will be lost)',
                               mtConfirmation,[mbYes,mbNo],0)) then}
           for iCount := 0 to (TemporaryFiles.Items.Count - 1) do
               if FileExists(TemporaryFiles.Items.Strings[iCount]) then
                  if (mrYes = MessageDlg('Delete file ' + TemporaryFiles.Items.Strings[iCount] + ' imported while program was running? ' +
                               '(Note: Any changes made to this file will be lost)',
                               mtConfirmation,[mbYes,mbNo],0)) then
                     try
                        if not deletefile(TemporaryFiles.Items.Strings[iCount]) then
                           MessageDlg('Cannot delete ' + TemporaryFiles.Items.Strings[iCount] + Chr(10) + Chr(13) +
                                      'File may be in use.',mtInformation,[mbOk],0);
                     except
                           MessageDlg('Cannot delete ' + TemporaryFiles.Items.Strings[iCount] + Chr(10) + Chr(13) +
                                      'File may be in use.',mtInformation,[mbOk],0);
                     end;*)
end;

procedure TMainForm.BuildCPlanDatabase1Click(Sender: TObject);
begin
     try
        BuildCPlanWizardForm := TBuildCPlanWizardForm.Create(Application);
        BuildCPlanWizardForm.ShowModal;
        BuildCPlanWizardForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in BuildCPlanDatabase',mtError,[mbOk],0);
     end;
end;

procedure TMainForm.SaveActiveChild;
begin
     if ActiveMDIChild <> nil then
        //if SaveDialog.Execute then
        TMDIChild(ActiveMDIChild).Save{(SaveDialog.FileName)};
end;

procedure TMainForm.SaveAsActiveChild;
begin
     if ActiveMDIChild <> nil then
     begin
          SaveDialog.InitialDir := sWorkingDirectory;
          if SaveDialog.Execute then
             TMDIChild(ActiveMDIChild).SaveAs(SaveDialog.FileName,False);
     end;
end;

procedure TMainForm.Importintotable1Click(Sender: TObject);
begin
     try
        ImportIntoTableForm := TImportIntoTableForm.Create(Application);
        ImportIntoTableForm.ShowModal;
        ImportIntoTableForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ImportIntoTable',mtError,[mbOk],0);
     end;
end;

procedure TMainForm.FieldProperties1Click(Sender: TObject);
var
   TypeInfo, FieldSize : Array_t;
begin
     if ActiveMDIChild <> nil then
     begin
          // retrieve the field properties from the dbf table
          ConvertModule.ScanDBaseFileFieldTypes(TMDIChild(ActiveMDIChild).sFilename,
                                                TypeInfo);

          TMDIChild(ActiveMDIChild).TrimTypeInfoArray(TypeInfo);

          TMDIChild(ActiveMDIChild).CountFieldSize(FieldSize);

          // display in a grid the subset of fields from the table that are being displayed
          FieldPropertiesForm := TFieldPropertiesForm.Create(Application);
          FieldPropertiesForm.Caption := 'Field Properties ' + ExtractFileName(TMDIChild(ActiveMDIChild).sFilename);
          FieldPropertiesForm.DisplayFieldProperties(TypeInfo,FieldSize);
          FieldPropertiesForm.ShowModal;
          FieldPropertiesForm.Free;

          TypeInfo.Destroy;
          FieldSize.Destroy;
     end;
end;

procedure TMainForm.FormActivate(Sender: TObject);
var
   iCount : integer;
begin
     if fStarting then
        {load any files that have been passed to us as parameters}
        if (ParamCount > 0) then
           for iCount := 1 to ParamCount do
               if FileExists(ParamStr(iCount)) then
                  if (LowerCase(ExtractFileExt(ParamStr(iCount))) = '.wiz') then
                     // file is a wizard parameter file
                     LoadWIZFile(ParamStr(iCount))
                  else
                      // file is a table
                      CreateMDIChild(ParamStr(iCount),'',False); {load table contents into the grid}
     fStarting := False;
end;

procedure TMainForm.SetWorkingDirectory1Click(Sender: TObject);
begin
     // get the user to edit the working directory
     try
        WorkingDirForm := TWorkingDirForm.Create(Application);

        WorkingDirForm.EditPath.Text := sWorkingDirectory;

        if (mrOk = WorkingDirForm.ShowModal)
        and (sWorkingDirectory <> WorkingDirForm.EditPath.Text) then
        begin
             sWorkingDirectory := WorkingDirForm.EditPath.Text;
             //fIniChange := True;
             // write the working directory to the ini file
             SaveWorkingDirectory;
             // read the working dir from the ini file at startup
             // (or set it to a default value if ini file not present)

             ForceDirectories(sWorkingDirectory);
        end;

     finally
            WorkingDirForm.Free;
     end;
end;

procedure TMainForm.Import1Click(Sender: TObject);
var
   iCount : integer;
begin
     if fUseDefaultImportNames then
     begin
          ImportDialog.InitialDir := sWorkingDirectory;
          if ImportDialog.Execute then
             if (ImportDialog.Files.Count > 0) then
                for iCount := 0 to (ImportDialog.Files.Count - 1) do
                    CreateMDIChild(ImportDialog.Files.Strings[iCount],'',False);
     end
     else
     begin
          ImportFileForm := TImportFileForm.Create(Application);
          ImportFileForm.ShowModal;
          ImportFileForm.Free;
     end;
end;

procedure TMainForm.Export1Click(Sender: TObject);
begin
     if ActiveMDIChild <> nil then
     begin
          ExportDialog.InitialDir := sWorkingDirectory;
          if ExportDialog.Execute then
             TMDIChild(ActiveMDIChild).SaveAs(ExportDialog.FileName,False);
     end;
end;

procedure TMainForm.JoinMtxFiles1Click(Sender: TObject);
begin
     JoinMtxForm := TJoinMtxForm.Create(Application);
     JoinMtxForm.ShowModal;
     JoinMtxForm.Free;
end;

end.
