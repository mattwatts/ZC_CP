unit Loadunit;

interface

{$DEFINE LOAD16}

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TForm1 = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function ermsRunTool(const ThisHandle : THandle; const PDatabase, PTopic : PChar) : integer; export;

var
  Form1: TForm1;

implementation

uses
    IniFiles;

{$R *.DFM}

function ermsRunTool(const ThisHandle : THandle; const PDatabase, PTopic : PChar) : integer;
var
   sTopic, sDatabase, sPath : string;
   PCmdLine : PChar;
   AIni : TIniFile;
begin
     sDatabase := StrPas(PDatabase);
     sTopic := StrPas(PTopic);

     AIni := TIniFile.Create('cplandb.ini');


     GetMem(PCmdLine,250);
     {$IFDEF LOAD16}
     sPath := AIni.ReadString('Paths','16bit','');
     StrPCopy(PCmdLine,sPath + '\TOOL16.EXE ' + sDatabase + ' ' + sTopic);
     {$ELSE}
     sPath := AIni.ReadString('Paths','32bit','');
     StrPCopy(PCmdLine,sPath + '\TOOL32.EXE ' + sDatabase + ' ' + sTopic);
     {$ENDIF}


     AIni.Free;
     {MessageDlg('I am about to call WinEXEC >' + StrPas(pCmdLine) + '<',
                mtInformation,[mbOK],0);}

     WinEXEC(PCmdLine,{SW_HIDE} SW_SHOW);
     FreeMem(PCmdLine,250);
end;

end.
