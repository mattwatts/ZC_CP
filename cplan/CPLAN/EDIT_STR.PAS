unit edit_str;

interface

uses
  {$IFDEF VER90}
  Windows,
  {$ELSE}

  {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TEditStrForm = class(TForm)
    BitBtn1: TBitBtn;
    Label1: TLabel;
    Edit1: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EditStrForm: TEditStrForm;


function rtnUserStr(const sCaption, sLabel, sDefault : string) : string;


implementation

{$R *.DFM}

function rtnUserStr(const sCaption, sLabel, sDefault : string) : string;
begin
     EditStrForm := TEditStrForm.Create(Application);

     with EditStrForm do
     begin
          Caption := sCaption;
          Label1.Caption := sLabel;
          Edit1.Text := sDefault;

          ShowModal;

          Result := Edit1.Text;

          Free;
     end;
end;

end.
