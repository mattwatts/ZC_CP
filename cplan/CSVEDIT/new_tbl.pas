unit new_tbl;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Spin;

type
  TNewTableForm = class(TForm)
    SpinRows: TSpinEdit;
    SpinCols: TSpinEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewTableForm: TNewTableForm;

implementation

{$R *.DFM}

end.
