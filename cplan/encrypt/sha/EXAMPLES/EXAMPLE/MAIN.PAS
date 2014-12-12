unit Main;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Menus, SHA;

type
  TMainForm = class(TForm)
    InputString: TEdit;
    Button1: TButton;
    Hashed: TEdit;
    SHA1: TSHA;
    procedure Button1Click(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.Button1Click(Sender: TObject);
begin
     SHA1.Init;
     SHA1.HashProcessString(InputString.Text);
     SHA1.Finish;
     Hashed.Text := SHA1.GetHashString;
end;

end.
