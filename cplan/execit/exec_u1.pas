unit exec_u1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

function RunAnAppAnyPath(const sApp, sCmdLine : string) : boolean;
var
   sRunFile, sExeFile : string;
   PCmd : PChar;
begin
     sExeFile := sApp;
     sRunFile := sExeFile + ' ' + sCmdLine;

     if FileExists(sExeFile) then
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


procedure TForm1.Timer1Timer(Sender: TObject);
begin
     Timer1.Enabled := False;
     RunAnAppAnyPath('c:\program files\cplan32\gmtest0.exe',
                     ParamStr(1));
     Application.Terminate;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
     Timer1.Enabled := True;
end;

end.
