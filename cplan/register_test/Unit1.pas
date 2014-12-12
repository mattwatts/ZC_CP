unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Outline, ExtCtrls, FileCtrl, StdCtrls, Grids, DirOutln;

type
  TForm1 = class(TForm)
    DirectoryOutline1: TDirectoryOutline;
    FilterComboBox1: TFilterComboBox;
    DriveComboBox1: TDriveComboBox;
    DirectoryListBox1: TDirectoryListBox;
    FileListBox1: TFileListBox;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure WriteBatFile(const sWindowsDrive, sCPlanInstallPath : string);
var
   BatFile : TextFile;
begin
     // This procedure assumes that the 2 parameters passed contain a trailing back slash character.

     assignfile(BatFile,sCPlanInstallPath + 'cr.bat');
     rewrite(BatFile);

     writeln(BatFile,'dir ' +
                     sWindowsDrive +
                     ' > ' +
                     sCPlanInstallPath +
                     'crout');

     closefile(BatFile);
end;

function RunApp(const sApp, sParam : string) : boolean;
var
   sRunFile, sPath, sCmd : string;
   PCmd : PChar;
   //AIniFile : TIniFile;
begin
     //AIniFile := TIniFile.Create(DB_INI_FILENAME);

     // sPath := ExtractFilePath(Application.ExeName);
     // sPath := AIniFile.ReadString('Paths','32bit','');
     sRunFile := {sPath +} sApp {+ '.exe'};

     if (sParam <> '') then
        sCmd := sRunFile + ' ' + sParam
     else
         sCmd := sRunFile;

     //AIniFile.Free;

     GetMem(PCmd,Length(sCmd)+1);
     StrPCopy(PCmd,sCmd);
     WinEXEC(PCmd,SW_HIDE{SW_SHOW});
     FreeMem(PCmd,Length(sCmd)+1);

     Result := True;
end;

function ReadDirOutFile(const sFile : string) : string;
// return the volumn id stripped from the given file
var
   InFile : TextFile;
   sLine : string;
   iPos : integer;
begin
     assignfile(InFile,sFile);
     reset(InFile);
     // skip first line
     readln(InFile);
     // second line contains volume id
     // the line looks like this : ' Volume Serial Number is 246F-D6CD'
     readln(InFile,sLine);
     repeat
           iPos := Pos(' ',sLine);
           if (iPos > 0) then
              sLine := Copy(sLine,iPos+1,Length(sLine)-iPos);

     until (iPos = 0);
     closefile(InFile);
     
     Result := sLine;
end;

function ReturnWindowsVolumnId{(const cDriveLetter : char)} : string;
var
   sWinDir, sVolumeId : String;
   iLength : Integer;
   fFileRead : boolean;
begin
     // returns the volumn id of the drive specified

     // make .bat file in the C-Plan program files directory
     // using a cmd like this in the .bat file :
     //   dir c:\ > d:\xyz1.txt
     //
     // substitute the drive windows is installed on for c:\
     // substitute the c-plan install drive & directory for d:\
     // GetWindowsDirectory
     iLength := 255;
     setLength(sWinDir, iLength);
     iLength := GetWindowsDirectory(PChar(sWinDir), iLength);
     setLength(sWinDir, iLength);
     // get C-Plan directory
     WriteBatFile(sWinDir + '\','c:\');

     // execute the .bat file and send the output to the C-Plan program files directory
     RunApp('c:\cr.bat','');

     // we must wait a little while until the output file can be read
     fFileRead := False;
     repeat
           try// read the output file and get the volumn id from it
              Result := ReadDirOutFile('c:\crout');
              fFileRead := True;
           except

           end;

     until fFileRead;

     
     

     // delete the .bat file and the output file
     DeleteFile('c:\crout');
     DeleteFile('c:\cr.bat');
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   sTmp : string;
begin
     RunApp('d:\dir.bat','');
     sTmp := ReturnWindowsVolumnId;
     MessageDlg('volume id is ' + sTmp,mtInformation,[mbOk],0);
end;

end.
