unit keeptbled;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
    inifiles;

{$R *.DFM}

procedure RenameOldTableEditor;
var
   sPath : string;
   AIniFile : TIniFile;
begin
     AIniFile := TIniFile.Create('cplandb.ini');
     sPath := AIniFile.ReadString('Paths','32bit','');
     AIniFile.Free;

     if fileexists(sPath + '\table_ed.exe') then
        renamefile(sPath + '\table_ed.exe',sPath + '\table_ed_old.exe');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     RenameOldTableEditor;
     Application.Terminate;
end;

end.
