unit filter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Grids;

type
  TFilterForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    RadioOperator: TRadioGroup;
    ComboField: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ComboValue: TComboBox;
    procedure ComboFieldChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FilterForm: TFilterForm;
  FilterStringGrid : TStringGrid;

implementation

{$R *.DFM}

procedure TFilterForm.ComboFieldChange(Sender: TObject);
var
   iColumns, iRows, iColumnIndex : integer;
begin
     // must load all unique values of field into value drop down box
     try
        Screen.Cursor := crHourglass;

        // ComboField.Text is the field within FilterStringGrid that contains the values
        // find key column index
        iColumnIndex := 0;
        for iColumns := 0 to (FilterStringGrid.ColCount - 1) do
            if (FilterStringGrid.Cells[iColumns,0] = ComboField.Text) then
               iColumnIndex := iColumns;
        // traverse the values for this column and add them to the drop down box
        ComboValue.Items.Clear;
        for iRows := 1 to (FilterStringGrid.RowCount - 1) do
            if (ComboValue.Items.IndexOf(FilterStringGrid.Cells[iColumnIndex,iRows]) = -1) then
               ComboValue.Items.Add(FilterStringGrid.Cells[iColumnIndex,iRows]);
        ComboValue.Text := ComboValue.Items.Strings[0];

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
     end;
end;

end.
