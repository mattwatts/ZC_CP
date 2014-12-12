unit use_dll;


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TUseDLLForm = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UseDLLForm: TUseDLLForm;

implementation

{$R *.DFM}


procedure TUseDLLForm.Button1Click(Sender: TObject);
begin
     //Edit1.Text := FloatToStr(multby5(StrToFloat(Edit1.Text)));
end;

end.
