unit auto_fit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, grids;

procedure AutoFitGrid(AGrid : TStringGrid;
                      Canvas : TCanvas;
                      const fFitEntireGrid : boolean);

implementation

procedure AutoFitGrid(AGrid : TStringGrid;
                      Canvas : TCanvas;
                      const fFitEntireGrid : boolean);
// fFitEntireGrid = True   means fit entire grid
//                  False  means fit selected area
//
// Canvas is the Canvas of the form containing AGrid
var
   iRowCount,
   iColumnCount,
   iMaxColumnWidth,
   iCurrentColumnWidth : integer;
begin
     // auto fit the table with user parameters
     try
        if fFitEntireGrid then
        begin
             // auto fit entire table
             // for each column, determine the maximum width by scanning all cells in the column
             for iColumnCount := 0 to (AGrid.ColCount-1) do
             begin
                  iMaxColumnWidth := 0;
                  for iRowCount := 0 to (AGrid.RowCount-1) do
                  begin
                       iCurrentColumnWidth := Canvas.TextWidth(AGrid.Cells[iColumnCount,iRowCount]);
                       if (iCurrentColumnWidth > iMaxColumnWidth) then
                          iMaxColumnWidth := iCurrentColumnWidth;
                  end;
                  // set ColWidths for this column
                  AGrid.ColWidths[iColumnCount] := iMaxColumnWidth + 4;
             end;
        end
        else
        begin
             // auto fit selected rows and columns
             for iColumnCount := AGrid.Selection.Left to AGrid.Selection.Right do
             begin
                  iMaxColumnWidth := 0;
                  for iRowCount := AGrid.Selection.Top to AGrid.Selection.Bottom do
                  begin
                       iCurrentColumnWidth := Canvas.TextWidth(AGrid.Cells[iColumnCount,iRowCount]);
                       if (iCurrentColumnWidth > iMaxColumnWidth) then
                          iMaxColumnWidth := iCurrentColumnWidth;
                  end;
                  AGrid.ColWidths[iColumnCount] := iMaxColumnWidth + 4;
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception AutoFitGrid',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


end.
