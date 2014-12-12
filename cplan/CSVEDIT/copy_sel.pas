unit copy_sel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TCopySelectionForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    SelectWhat: TRadioGroup;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CopySelectionForm: TCopySelectionForm;

implementation

{$R *.DFM}

end.
