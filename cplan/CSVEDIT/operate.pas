unit operate;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  childwin;

type
  TOperationForm = class(TForm)
    RadioData: TRadioGroup;
    btnCancel: TBitBtn;
    btnProcess: TButton;
    ResultBox: TListBox;
    btnOk: TBitBtn;
    btnSave: TButton;
    procedure btnProcessClick(Sender: TObject);
    procedure ResultBoxClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OperationForm: TOperationForm;
  OperationChild : TMDIChild;

implementation

{$R *.DFM}

procedure TOperationForm.btnProcessClick(Sender: TObject);
var
   iCountRow, iCountColumn, iElements,
   iStartRow, iEndRow, iStartColumn, iEndColumn : integer;
   rTotal, rTotalSquared, rSTDDEV, rMEAN : extended;
begin
     try
        // note : this operation not performed on the header row
        // We are operating on OperationChild
        case RadioData.ItemIndex of
             0 :
             begin
                  iStartRow := OperationChild.aGrid.Selection.Top;
                  iEndRow := OperationChild.aGrid.Selection.Bottom;
                  iStartColumn := OperationChild.aGrid.Selection.Left;
                  iEndColumn := OperationChild.aGrid.Selection.Right;
             end; // selected cells
             1 :
             begin
                  iStartRow := OperationChild.aGrid.Selection.Top;
                  iEndRow := OperationChild.aGrid.Selection.Bottom;
                  iStartColumn := 0;
                  iEndColumn := OperationChild.SpinCol.Value-1;
             end; // selected rows
             2 :
             begin
                  iStartRow := 1;
                  iEndRow := OperationChild.SpinRow.Value-1;
                  iStartColumn := OperationChild.aGrid.Selection.Left;
                  iEndColumn := OperationChild.aGrid.Selection.Right;
             end; // selected columns
             3 :
             begin
                  iStartRow := 1;
                  iEndRow := OperationChild.SpinRow.Value-1;
                  iStartColumn := 0;
                  iEndColumn := OperationChild.SpinCol.Value-1;
             end; // entire grid
        end;

        if (iStartRow = 0) then
        begin
             iStartRow := 1;
             if (iEndRow = 0) then
                iEndRow := 1;
        end;
        ResultBox.Items.Clear;
        ResultBox.Visible := True;
        for iCountColumn := iStartColumn to iEndColumn do
        begin
             try
                rTotal := 0;
                rTotalSquared := 0;
                iElements := 0;
                for iCountRow := iStartRow to iEndRow do
                begin
                     rTotal := rTotal + StrToFloat(OperationChild.aGrid.Cells[iCountColumn,iCountRow]);
                     rTotalSquared := rTotalSquared + sqr(StrToFloat(OperationChild.aGrid.Cells[iCountColumn,iCountRow]));
                     Inc(iElements);
                end;
                // add this total to the listbox
                rMEAN := rTotal / iElements;
                rSTDDEV := sqrt(((iElements*rTotalSquared)-(rTotal*rTotal))
                           /
                           (iElements*(iElements-1)));
                ResultBox.Items.Add(OperationChild.KeyFieldGroup.Items[iCountColumn] +
                                    ' = ' + FloatToStr(rTotal));
                ResultBox.Items.Add('  MEAN = ' + FloatToStr(rMEAN));
                ResultBox.Items.Add('  STDDEV = ' + FloatToStr(rSTDDEV));

             except
                   Screen.Cursor := crDefault;
                   MessageDlg('Exception doing operation on field ' +
                              OperationChild.KeyFieldGroup.Items[iCountColumn],
                              mtError,[mbOk],0);
                   btnOk.Visible := True;
             end;
        end;
        btnOk.Visible := True;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception doing operation',mtError,[mbOk],0);
           btnOk.Visible := True;
     end;
end;

procedure TOperationForm.ResultBoxClick(Sender: TObject);
begin
     ResultBox.ShowHint := True;
     ResultBox.Hint := ResultBox.Items[ResultBox.ItemIndex];
end;

procedure TOperationForm.btnSaveClick(Sender: TObject);
begin
     ResultBox.Items.SaveToFile('c:\sum_of_cells.txt');
end;

end.
