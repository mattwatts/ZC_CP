unit randdel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Spin;

type
  THowManyForm = class(TForm)
    lblQuestion: TLabel;
    SpinHowMany: TSpinEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HowManyForm: THowManyForm;

implementation

{$R *.DFM}

end.
