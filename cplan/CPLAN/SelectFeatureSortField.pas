unit SelectFeatureSortField;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TSelectFeatureSortFieldForm = class(TForm)
    SortGroup: TRadioGroup;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    VariableBox: TListBox;
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SelectFeatureSortFieldForm: TSelectFeatureSortFieldForm;

implementation

{$R *.DFM}


end.
