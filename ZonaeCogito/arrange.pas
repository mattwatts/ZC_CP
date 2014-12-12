unit arrange;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TArrangeForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    RadioArrange: TRadioGroup;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ArrangeForm: TArrangeForm;

implementation

uses SCP_Main;

{$R *.DFM}

procedure TArrangeForm.BitBtn1Click(Sender: TObject);
begin
     case RadioArrange.ItemIndex of
          0 : SCPForm.TileVertical;
          1 : SCPForm.TileHorizontal;
          2 : SCPForm.Cascade;
     end;
end;

end.
