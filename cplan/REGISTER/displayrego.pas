unit displayrego;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TDisplayRegoForm = class(TForm)
    BitBtn1: TBitBtn;
    EditRegoCode: TEdit;
    procedure SetRegoCode(const sRegoCode : string);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DisplayRegoForm: TDisplayRegoForm;

implementation

{$R *.DFM}

procedure TDisplayRegoForm.SetRegoCode(const sRegoCode : string);
begin
     //
     EditRegoCode.Text := sRegoCode;
end;

procedure TDisplayRegoForm.BitBtn1Click(Sender: TObject);
begin
     ModalResult := mrOk;
end;

end.
