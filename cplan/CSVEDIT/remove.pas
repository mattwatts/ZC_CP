unit remove;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  Childwin;

type
  TRemoveCharForm = class(TForm)
    btnSearchAndReplace: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    ScanWhat: TRadioGroup;
    EditSearch: TEdit;
    Label2: TLabel;
    EditReplace: TEdit;
    CellPos: TRadioGroup;
    CheckConfirm: TCheckBox;
    procedure btnSearchAndReplaceClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RemoveCharForm: TRemoveCharForm;
  RemoveChild : TMDIChild;

implementation

uses
    Grids;

{$R *.DFM}

procedure TRemoveCharForm.btnSearchAndReplaceClick(Sender: TObject);
var
   sToFind, sCell : string;
   iRowCount, iColCount,
   iUpperRow, iLowerRow,
   iStartCol, iEndCol,
   iOriginalLeftCol, iOriginalTopRow,
   iPos : integer;
   fConfirm : boolean;
   wResult : word;
   //Child : TMDIChild;
   //SRect : TGridRect;
   ARectangle : TGridRect;
begin
     try
        if (EditSearch.Text <> '') then
        begin
             if RemoveChild.CheckLoadFileData.Checked then
             begin
                  sToFind := EditSearch.Text;
                  case ScanWhat.ItemIndex of
                       0 : // Selected Cells
                       begin
                            iUpperRow := RemoveChild.AGrid.Selection.Top;
                            iLowerRow := RemoveChild.AGrid.Selection.Bottom;
                            iStartCol := RemoveChild.AGrid.Selection.Left;
                            iEndCol := RemoveChild.AGrid.Selection.Right;
                       end;
                       1 :  // Selected Columns
                       begin
                            iUpperRow := 0;
                            iLowerRow := RemoveChild.SpinRow.Value - 1;
                            iStartCol := RemoveChild.AGrid.Selection.Left;
                            iEndCol := RemoveChild.AGrid.Selection.Right;
                       end;
                       2 :  // Selected Rows
                       begin
                            iUpperRow := RemoveChild.AGrid.Selection.Top;
                            iLowerRow := RemoveChild.AGrid.Selection.Bottom;
                            iStartCol := 0;
                            iEndCol := RemoveChild.SpinCol.Value - 1;
                       end;
                       3 :  // Entire Grid
                       begin
                            iUpperRow := 0;
                            iLowerRow := RemoveChild.SpinRow.Value - 1;
                            iStartCol := 0;
                            iEndCol := RemoveChild.SpinCol.Value - 1;
                       end;
                  end;
                  iOriginalLeftCol := RemoveChild.AGrid.LeftCol;
                  iOriginalTopRow := RemoveChild.AGrid.TopRow;
                  for iRowCount := iUpperRow to iLowerRow do
                      for iColCount := iStartCol to iEndCol do
                      begin
                           sCell := RemoveChild.aGrid.Cells[iColCount,iRowCount];
                           iPos := Pos(sToFind,sCell);
                           if (iPos > -1) then
                           begin
                                // highlight this cell and query user
                                fConfirm := True;
                                if CheckConfirm.Checked then
                                begin
                                     // zoom to cell
                                     {
                                     ARectangle.Top := iRowCount;
                                     ARectangle.Bottom := iRowCount;
                                     ARectangle.Left := iColCount;
                                     ARectangle.Right := iColCount;
                                     RemoveChild.AGrid.Selection := Rectangle;
                                     }
                                     if (RemoveChild.AGrid.FixedCols <= iColCount) then
                                        RemoveChild.AGrid.LeftCol := iColCount
                                     else
                                         RemoveChild.AGrid.LeftCol := RemoveChild.AGrid.FixedCols;
                                     if (RemoveChild.AGrid.FixedRows <= iRowCount) then
                                        RemoveChild.AGrid.TopRow := iRowCount
                                     else
                                         RemoveChild.AGrid.TopRow := RemoveChild.AGrid.FixedRows;

                                     wResult := MessageDlg('Replace ' + RemoveChild.aGrid.Cells[iColCount,iRowCount] + '?',
                                                           mtConfirmation,[mbYes,mbNo,mbCancel],0);
                                     if (wResult = mrNo) then
                                        fConfirm := False;
                                     if (wResult = mrCancel) then
                                        Exit;
                                end;

                                if fConfirm then
                                begin
                                     RemoveChild.fDataHasChanged := True;

                                     if (CellPos.ItemIndex = 0) then
                                     begin
                                          if (iPos > 1) then
                                          begin
                                               if (iPos = (Length(sCell) - Length(sToFind) + 1)) then
                                                  // data is at end of cell
                                                  RemoveChild.aGrid.Cells[iColCount,iRowCount] := Copy(sCell,
                                                                                                       1,
                                                                                                       iPos-1) +
                                                                                                  EditReplace.Text
                                               else
                                                   // data is in middle of cell
                                                   RemoveChild.aGrid.Cells[iColCount,iRowCount] := Copy(sCell,
                                                                                                        1,
                                                                                                        iPos-1) +
                                                                                                   EditReplace.Text +
                                                                                                   Copy(sCell,
                                                                                                        iPos + Length(EditReplace.Text),
                                                                                                        Length(sCell) - iPos - Length(EditReplace.Text) + 1);
                                          end
                                          else
                                              if (iPos = 1) then
                                                 // data is at start of cell
                                                 RemoveChild.aGrid.Cells[iColCount,iRowCount] := EditReplace.Text +
                                                                                             Copy(sCell,
                                                                                                  Length(sToFind)+1,
                                                                                                  Length(sCell) - Length(sToFind));
                                     end
                                     else
                                     begin
                                          // start of cell only
                                          if (iPos = 1) then
                                             RemoveChild.aGrid.Cells[iColCount,iRowCount] := EditReplace.Text +
                                                                                             Copy(sCell,
                                                                                                  Length(sToFind)+1,
                                                                                                  Length(sCell) - Length(sToFind));
                                     end;
                                end;
                           end;
                      end;

                  RemoveChild.AGrid.LeftCol := iOriginalLeftCol;
                  RemoveChild.AGrid.TopRow := iOriginalTopRow;
                  
                  with RemoveChild do
                  begin
                       {remap key field selection components because we may have just deleted column(s)}
                       KeyFieldGroup.Items.Clear;
                       KeyCombo.Items.Clear;
                       for iColCount := 0 to (aGrid.ColCount - 1) do
                       begin
                            KeyFieldGroup.Items.Add(aGrid.Cells[iColCount,0]);
                            KeyCombo.Items.Add(aGrid.Cells[iColCount,0]);
                       end;
                       iPos := KeyFieldGroup.Items.IndexOf(KeyCombo.Text);
                       if (iPos >= 0) then
                          KeyFieldGroup.ItemIndex := iPos
                       else
                       begin
                            KeyFieldGroup.ItemIndex := 0;
                            KeyCombo.Text := KeyCombo.Items.Strings[0];
                       end;

                       SpinCol.Value := aGrid.ColCount;
                  end;
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Search and Replace',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

end.
