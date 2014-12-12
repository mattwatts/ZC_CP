unit autofit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TAutoFitForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    AutoFitWhat: TRadioGroup;
    procedure BitBtn1Click(Sender: TObject);
    procedure AutoFitTable;
  private
    { Private declarations }
  public
    { Public declarations }
    sTable : string;
  end;

var
  AutoFitForm: TAutoFitForm;

implementation

uses MAIN, Childwin, db_ed_child;

{$R *.DFM}

procedure TAutoFitForm.AutoFitTable;
var
   AChild : TMDIChild;
   iRowCount,
   iColumnCount,
   iMaxColumnWidth,
   iCurrentColumnWidth : integer;
begin
     // auto fit the table with user parameters
     try
        AChild := SCPForm.rtnChild(sTable);
        if (AutoFitWhat.ItemIndex = 0) then
        begin
             // auto fit entire table
             // for each column, determine the maximum width by scanning all cells in the column
             for iColumnCount := 0 to (AChild.AGrid.ColCount-1) do
             begin
                  iMaxColumnWidth := 0;
                  for iRowCount := 0 to (AChild.AGrid.RowCount-1) do
                  begin
                       iCurrentColumnWidth := AChild.Canvas.TextWidth(AChild.AGrid.Cells[iColumnCount,iRowCount]);
                       if (iCurrentColumnWidth > iMaxColumnWidth) then
                          iMaxColumnWidth := iCurrentColumnWidth;
                  end;
                  // set ColWidths for this column
                  AChild.AGrid.ColWidths[iColumnCount] := iMaxColumnWidth + 4;
             end;
        end
        else
        begin
             // auto fit selected rows and columns
             for iColumnCount := AChild.AGrid.Selection.Left to AChild.AGrid.Selection.Right do
             begin
                  iMaxColumnWidth := 0;
                  for iRowCount := AChild.AGrid.Selection.Top to AChild.AGrid.Selection.Bottom do
                  begin
                       iCurrentColumnWidth := AChild.Canvas.TextWidth(AChild.AGrid.Cells[iColumnCount,iRowCount]);
                       if (iCurrentColumnWidth > iMaxColumnWidth) then
                          iMaxColumnWidth := iCurrentColumnWidth;
                  end;
                  AChild.AGrid.ColWidths[iColumnCount] := iMaxColumnWidth + 4;
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TAutoFitForm.AutoFitTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TAutoFitForm.BitBtn1Click(Sender: TObject);
begin
     AutoFitTable;
end;

end.
