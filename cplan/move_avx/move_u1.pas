unit move_u1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TLocateArcViewForm = class(TForm)
    Label3: TLabel;
    Timer1: TTimer;
    function rtnArcViewPath(var sPath : string) : boolean;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LocateArcViewForm: TLocateArcViewForm;

implementation

uses
    registry, filectrl, inifiles;

{$R *.DFM}

function TLocateArcViewForm.rtnArcViewPath(var sPath : string) : boolean;
var
   ARegistry : TRegistry;
   sCurrentPath, sValue, sReg : string;
begin
     {}
     try
        Result := True;

        ARegistry := TRegistry.Create;
        ARegistry.RootKey := HKEY_LOCAL_MACHINE;

        ARegistry.OpenKey('SOFTWARE',FALSE);
        ARegistry.OpenKey('Classes',FALSE);
        ARegistry.OpenKey('ArcView Project',FALSE);
        ARegistry.OpenKey('shell',FALSE);
        ARegistry.OpenKey('open',FALSE);
        ARegistry.OpenKey('command',FALSE);

        //sCurrentPath := ARegistry.CurrentPath;

        {if (ARegistry.GetDataType('') = rdString) then
           label2.Caption := 'type is string'
        else
            label2.Caption := 'type is not string';}

        sPath := '';
        sReg := ARegistry.ReadString('');
        if (sReg <> '')
        and (Length(sReg) > 25) then
        begin
             sPath := Copy(sReg,1,Length(sReg)-20) +
                      'ext32';
             ForceDirectories(sPath);
        end;


        ARegistry.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TLocateArcViewForm.rtnArcViewPath',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function ACopyFile(const sSourceFile, sDestFile : string) : boolean;
var
   iHInFile, iHOutFile, iFilePos,
   iSeekInPos, iSeekOutPos,
   iBytesRead, iBytesWritten : integer;
   wWord : word;
begin
     if FileExists(sDestFile) then
        DeleteFile(sDestFile);

     Result := True;
     iHInFile := FileOpen(sSourceFile,fmOpenRead);
     iBytesWritten := 0;

     if (iHInFile > 0) then
     begin
          iHOutFile := FileCreate(sDestFile);

          if (iHOutFile > 0) then
          begin
               iFilePos := 0;

               repeat
                     iSeekInPos := FileSeek(iHInFile,iFilePos,0);

                     iBytesRead := FileRead(iHInFile,wWord,1);

                     if (iBytesRead = 1) then
                     begin
                          iSeekOutPos := FileSeek(iHOutFile,iFilePos,0);
                          Inc(iFilePos);
                          iBytesWritten := FileWrite(iHOutFile,wWord,1);
                     end;

               until (iBytesWritten < 1)
               or (iBytesRead < 1);

               FileClose(iHOutFile);
          end
          else
              Result := False;

          FileClose(iHInFile);

          if (iBytesWritten < 1) then
             Result := False;
             {MessageDlg('CopyDBFile, ' + sSourceFile +
                        ' to ' + sDestFile,mtError,[mbOK],0);}
     end
     else
     begin

          MessageDlg('Cannot find ' + sSourceFile + '  Please contact software support',
                     mtError,[mbOk],0);

          Result := False;
     end;
end;


procedure TLocateArcViewForm.FormCreate(Sender: TObject);
var
   sS, sP : string;
   AIni : TIniFile;
begin
     if rtnArcViewPath(sS) then
     begin
          {}
          label3.caption := 'Copying ' + sP + ' to ' + sS;

          AIni := TIniFile.Create('cplandb.ini');
          sP := AIni.ReadString('Paths','32bit','');
          AIni.Free;

          sP := sP + '\ArcView\cplan.avx';
          sS := sS + '\cplan.avx';

          ACopyFile(sP,
                    sS
                   );
     end
     else
     begin
          label3.Caption := 'path not found';
     end;

     Timer1.Enabled := True;
end;

procedure TLocateArcViewForm.Timer1Timer(Sender: TObject);
begin
     if (label3.Caption = 'path not found') then
     begin
          Visible := False;
          MessageDlg('ArcView 3 is not installed on your system.' + Chr(10) + Chr(13) +
                     'You will have to re-install C-Plan after installing' + Chr(10) + Chr(13) +
                     'ArcView 3 in order for the ArcView 3 C-Plan Extension' + Chr(10) + Chr(13) +
                     'to work correctly.',
                     mtInformation,[mbOk],0);

     end;

     Application.Terminate;
     Timer1.Enabled := False;
end;

end.
