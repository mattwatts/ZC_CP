unit cp_u1;

interface

uses
  {$IFDEF VER90}
  Windows,
  {$ELSE}
  WinProcs, WinTypes,
  {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

const
     DB_INI_FILENAME : string = 'cplandb.ini';


type
  TCPlanForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    btnLocate: TButton;
    btnImport: TButton;
    DatabasesBox: TListBox;
    Button3: TButton;
    OpenDatabase: TOpenDialog;
    Button1: TButton;
    Button2: TButton;
    Button4: TButton;
    procedure Button3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DatabasesBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnImportClick(Sender: TObject);
    procedure btnLocateClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DatabasesBoxDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CPlanForm: TCPlanForm;


procedure DatabaseImported(const sPath : string);
{to be called by external unit to add a database to list}


implementation

{$R *.DFM}

uses IniFiles, edit_str, ed_entry;

procedure DatabaseImported(const sPath : string);
var
   sName : string;
   AIni : TIniFile;
begin
     sName := rtnUserStr('Enter a name for database ' + sPath,
                         'Name:',sPath);

     AIni := TIniFile.Create(DB_INI_FILENAME);
     AIni.WriteString('Databases',sName,sPath);
     AIni.Free;
end;

procedure TCPlanForm.Button3Click(Sender: TObject);
begin
     Application.Terminate;
end;

procedure TCPlanForm.FormShow(Sender: TObject);
var
   AIni : TIniFile;
   iCount, iDeleted : integer;
   sPath : string;
begin
     {parse the INI file and display available databases}

     AIni := TIniFile.Create(DB_INI_FILENAME);
     DatabasesBox.Items.Clear;
     AIni.ReadSection('Databases',DatabasesBox.Items);

     if (DatabasesBox.Items.Count > 0) then
        for iCount := (DatabasesBox.Items.Count - 1) downto 0 do
        begin
             sPath := AIni.ReadString('Databases',
                                      DatabasesBox.Items.Strings[iCount],
                                      '');

             if (not FileExists(sPath + '\CPLAN.INI'))
             and (not FileExists(sPath + '\EMRTOOL.INI')) then
             begin
                  AIni.DeleteKey('Databases',DatabasesBox.Items.Strings[iCount]);
                  DatabasesBox.Items.Delete(iCount);
                  Inc(iDeleted);
             end;
        end;

     if (iDeleted > 0) then
     begin
          MessageDlg('There are ' + IntToStr(iDeleted) + ' invalid databases listed which have been removed',
                     mtInformation,[mbOk],0);
          {AIni.EraseSection('Databases');
          if (DatabasesBox.Items.Count > 0) then
             for iCount := 0 to (DatabasesBox.Items.Count-1) do
                 AIni.WriteString(Databases}
     end;

     AIni.Free;

     {$IFDEF VER80}
     Caption := 'C-Plan Manager 16 Bit';
     {$ELSE}
     Caption := 'C-Plan Manager 32 Bit';
     {$ENDIF}
end;

procedure TCPlanForm.DatabasesBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     if (DatabasesBox.Items.Count = 0) then
        MessageDlg('There are no C-Plan Databases Available.' + chr(10) + chr(13) +
                    'Use "Locate Database" after using "Import New Data".',
                    mtInformation,[mbOk],0);
end;

procedure TCPlanForm.btnImportClick(Sender: TObject);
var
   sRunFile, sExePath : string;
   PCmd : PChar;
   AIni : TIniFile;
begin
     AIni := TIniFile.Create(DB_INI_FILENAME);

     sExePath := AIni.ReadString('Paths','32bit','');
     sRunFile := sExePath + '\table_ed.exe';

     AIni.Free;

     if FileExists(sRunFile) then
     begin
          GetMem(PCmd,Length(sRunFile)+1);
          StrPCopy(PCmd,sRunFile);

          WinEXEC(PCmd,SW_SHOW);

          FreeMem(PCmd,Length(sRunFile)+1);
     end
     else
         MessageDlg('Cannot find Table Editor ' + sRunFile,mtInformation,[mbOk],0);
end;

procedure TCPlanForm.btnLocateClick(Sender: TObject);
var
   sName, sPath : string;
   AIni : TIniFile;
begin
     {locate a C-Plan database and add it to the list}

     OpenDatabase.InitialDir := '';
     if OpenDatabase.Execute
     and FileExists(OpenDatabase.FileName) then
     begin
          {add Database to list if file exists}

          sName := rtnUserStr('Enter a name for database ' + OpenDatabase.FileName,
                              'Name:',OpenDatabase.FileName);

          AIni := TIniFile.Create(DB_INI_FILENAME);

          {$IFDEF VER80}
          sPath := ExtractFilePath(OpenDatabase.FileName);
          if (Length(sPath)>0) then
             sPath := Copy(sPath,1,Length(sPath)-1);
             {trim last \}
          {$ELSE}
          sPath := ExtractFileDir(OpenDatabase.FileName);
          {$ENDIF}
          AIni.WriteString('Databases',sName,sPath);

          AIni.Free;

          FormShow(self);
     end;
end;


procedure TCPlanForm.Button4Click(Sender: TObject);
var
   sRunFile, sCmdPath, sExePath : string;
   PCmd : PChar;
   AIni : TIniFile;
   iMemToAllocate, iCount, iMax : integer;

   function FindMaximumFeatures(const sPath : string) : integer;
   var
      iDb, iValue : integer;
      sDb : string;
      XIni : TIniFile;
   begin
        try
           if FileExists(sPath + '\emrtool.ini') then
              XIni := TIniFile.Create(sPath + '\emrtool.ini')
           else
               XIni := TIniFile.Create(sPath + '\cplan.ini');

           iDb := 0;
           Result := 0;
           repeat
                 Inc(iDb);
                 sDb := 'Database' + IntToStr(iDb);
                 iValue := XIni.ReadInteger(sDb,
                                            'MatrixSize',
                                            -1);
                 if (iValue > Result) then
                    Result := iValue;

           until (iValue = -1);

           XIni.Free;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception finding feature count from database ' + sPath,
                         mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;
   end;
begin
     try
        {Start C-Plan}

        if (DatabasesBox.Items.Count > 0) then
        begin
             sCmdPath := '';
             AIni := TIniFile.Create(DB_INI_FILENAME);
             {launch Conservation Tool with appropriate database}
             for iCount := 0 to (DatabasesBox.Items.Count-1) do
                 if DatabasesBox.Selected[iCount] then
                 begin
                      sCmdPath := AIni.ReadString('Databases',
                                                  DatabasesBox.Items.Strings[iCount],
                                                  '');
                 end;

             sExePath := AIni.ReadString('Paths','32bit','');
             sRunFile := sExePath + '\cplan.exe';

             AIni.Free;

             if FileExists(sRunFile) then
             begin
                  iMemToAllocate := Length(sRunFile)+5+Length(sCmdPath);

                  GetMem(PCmd,iMemToAllocate);
                  StrPCopy(PCmd,sRunFile + ' ' + '"' + sCmdPath + '"');

                  WinEXEC(PCmd,SW_SHOW);

                  try
                     FreeMem(PCmd,iMemToAllocate);
                  except
                  end;

                  Application.Terminate;
             end
             else
             begin
                  // C-Plan base version is not installed correctly
                  MessageDlg('Cannot find C-Plan Application ' + sRunFile + Chr(10) + Chr(13) +
                             'C-Plan is not installed correctly, please re-install' + Chr(10) + Chr(13) +
                             'the C-Plan installation set.',mtInformation,[mbOk],0);
                  Application.Terminate;
                  Exit;
             end;

        end
        else
            MessageDlg('No databases are listed.' + chr(10) + chr(13) +
                       'Use "Locate Database" or "Import New Data" first',
                       mtInformation,[mbOk],0);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Start C-Plan',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TCPlanForm.Button1Click(Sender: TObject);
var
   iCount : integer;
   AIni : TIniFile;
begin
     {delete entry}

     if (DatabasesBox.Items.Count > 0) then
     begin
          iCount := 0;
          AIni := TIniFile.Create(DB_INI_FILENAME);

          repeat
                if DatabasesBox.Selected[iCount] then
                begin
                     {delete this entry which is currently highlighted by the user}

                     AIni.DeleteKey('Databases',DatabasesBox.Items.Strings[iCount]);
                     DatabasesBox.Items.Delete(iCount);
                end;

                Inc(iCount);

          until (iCount >= DatabasesBox.Items.Count);

          AIni.Free;
     end;
end;

procedure TCPlanForm.Button2Click(Sender: TObject);
var
   iCount, iFileHandle : integer;
   AIni, EntryIni : TIniFile;
   sFilename, sMatrixFile : string;
begin
     {edit entry}

     if (DatabasesBox.Items.Count > 0) then
     begin
          iCount := 0;
          AIni := TIniFile.Create(DB_INI_FILENAME);

          repeat
                if DatabasesBox.Selected[iCount] then
                begin
                     {edit this entry which is currently highlighted by the user}

                     EditEntryForm := TEditEntryForm.Create(Application);
                     EditEntryForm.Edit1.Text := DatabasesBox.Items.Strings[iCount];
                     EditEntryForm.Label5.Caption := AIni.ReadString('Databases',
                                                                     DatabasesBox.Items.Strings[iCount],
                                                                     '');
                     if FileExists(EditEntryForm.Label5.Caption + '\EMRTOOL.INI') then
                        EntryIni := TIniFile.Create(EditEntryForm.Label5.Caption + '\EMRTOOL.INI')
                     else
                         EntryIni := TIniFile.Create(EditEntryForm.Label5.Caption + '\CPLAN.INI');

                     sMatrixFile := EntryIni.ReadString('Database1',
                                                        'MatrixFile',
                                                        '');
                     if (sMatrixFile = '') then
                        sMatrixFile := EntryIni.ReadString('Options',
                                                           'SparseMatrix',
                                                           '');
                     sFilename := EditEntryForm.Label5.Caption + '\' + sMatrixFile;

                     EntryIni.Free;

                     if FileExists(sFilename) then
                     begin
                          iFileHandle := FileOpen(sFilename,fmOpenRead);
                          EditEntryForm.Label4.Caption := DateTimeToStr(
                                                           FileDateToDateTime(
                                                            FileGetDate(iFileHandle)));
                          FileClose(iFileHandle);
                     end
                     else
                         EditEntryForm.Label4.Caption := 'unknown';

                     if (EditEntryForm.ShowModal = mrOk) then
                     begin
                          {adjust this entrys title}

                          AIni.DeleteKey('Databases',DatabasesBox.Items.Strings[iCount]);
                          AIni.WriteString('Databases',
                                           EditEntryForm.Edit1.Text,
                                           EditEntryForm.Label5.Caption);

                          DatabasesBox.Items.Delete(iCount);
                          DatabasesBox.Items.Insert(iCount,EditEntryForm.Edit1.Text);
                          DatabasesBox.ItemIndex := iCount;
                     end;

                     EditEntryForm.Free;
                end;

                Inc(iCount);

          until (iCount >= DatabasesBox.Items.Count);

          AIni.Free;
     end;
end;

procedure TCPlanForm.DatabasesBoxDblClick(Sender: TObject);
begin
     {start C-Plan}
     Button4Click(self);
end;

end.
