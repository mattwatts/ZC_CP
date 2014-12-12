unit Lbox;

interface

uses
    StdCtrls, Grids;

procedure CopyLBox2Clip(AListBox : TListBox); export;
procedure CopySGrid2Clip(AGrid : TStringGrid); export;

implementation

uses
    ClipBrd, SysUtils;

procedure CopyLBox2Clip(AListBox : TListBox);
var
   pStart : PChar;
   iCount, iCount3, iDataSize, iCurrChar : integer;
begin
     {copy any highlighted fields as text to the clipboard}
     if (AListBox.SelCount > 0) then
     begin
          iDataSize := 0;

          {find the size of data block to create}
          for iCount := 0 to (AListBox.Items.Count-1) do
              if AListBox.Selected[iCount] then
                 Inc(iDataSize,Length(AListBox.Items.Strings[iCount])+2);
                 {add space for string contents + CR/LF,
                  block ends with CR/LF/#0}

          Inc(iDataSize,1); {make 1 space for the null character}

          pStart := StrAlloc(iDataSize);

          iCurrChar := 0;
          {create null terminated string list}
          for iCount := 0 to (AListBox.Items.Count-1) do
              if AListBox.Selected[iCount] then
              begin
                   if (Length(AListBox.Items.Strings[iCount])>0) then
                   for iCount3 := 1 to Length(AListBox.Items.Strings[iCount]) do
                   begin
                         {add in each character from the string}

                         pStart[iCurrChar] := AListBox.Items.Strings[iCount][iCount3];
                         Inc(iCurrChar);
                   end;

                   pStart[iCurrChar] := Chr(13); {add CR}
                   Inc(iCurrChar);
                   pStart[iCurrChar] := Chr(10); {add LF}
                   Inc(iCurrChar);
               end;

          pStart[iCurrChar] := #0; {add null character to terminate PChar}

          Clipboard.SetTextBuf(pStart);
     end;
end;

procedure CopySGrid2Clip(AGrid : TStringGrid);
var
   pStart : PChar;
   iRow, iCol, iDataSize, iCurrChar, iCount : integer;
begin
     {copy any highlighted fields as text to the clipboard}
     iDataSize := 0;

     {find the size of data block to create}
     for iRow := AGrid.Selection.Top to AGrid.Selection.Bottom do
     begin
          for iCol := AGrid.Selection.Left to AGrid.Selection.Right do
              Inc(iDataSize,Length(AGrid.Cells[iCol,iRow])+1);
              {leave space for a comma}
          Inc(iDataSize,1);
          {add space for line terminating CR/LF
           block ends with CR/LF/#0}
     end;

     Inc(iDataSize,1); {make 1 space for the null character}

     pStart := StrAlloc(iDataSize);

     iCurrChar := 0;
     {create null terminated string list}
     for iRow := AGrid.Selection.Top to AGrid.Selection.Bottom do
     begin
          for iCol := AGrid.Selection.Left to AGrid.Selection.Right do
          begin
               if (Length(AGrid.Cells[iCol,iRow])>0) then
               for iCount := 1 to Length(AGrid.Cells[iCol,iRow]) do
               begin
                     {add in each character from the string}

                     pStart[iCurrChar] := AGrid.Cells[iCol,iRow][iCount];
                     Inc(iCurrChar);
               end;

               if (iCol <> AGrid.Selection.Right) then
               begin
                    pStart[iCurrChar] := ','; {add comma}
                    Inc(iCurrChar);
               end
               else
               begin
                    pStart[iCurrChar] := Chr(13); {add CR}
                    Inc(iCurrChar);
                    pStart[iCurrChar] := Chr(10); {add LF}
                    Inc(iCurrChar);
               end;
           end;
     end;

     pStart[iCurrChar] := #0; {add null character to terminate PChar}

     Clipboard.SetTextBuf(pStart);
end;

end.
