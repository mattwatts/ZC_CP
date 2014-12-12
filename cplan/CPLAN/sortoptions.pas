unit sortoptions;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TSortForm = class(TForm)
    Label1: TLabel;
    RadioDirection: TRadioGroup;
    Label2: TLabel;
    ComboField: TComboBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SortForm: TSortForm;

implementation

{$R *.DFM}


end.
