unit itools;

interface

uses
    Grids,
    ds;

procedure LoadMATNoHeader2StringGrid(AGrid : TStringGrid;
                                     const sFile : string;
                                     var DataFieldTypes : Array_T);
procedure SaveStringGrid2CSV(AGrid : TStringGrid;
                             const sFile : string);
procedure SaveStringGrid2MAT(AGrid : TStringGrid;
                             const sFile : string;
                             const iRichness, iKeyColumn : integer);
procedure CountColumnsInCSVFile(const sFilename : string;
                                var iColumns : integer);
procedure LoadCSV2StringGrid(AGrid : TStringGrid;
                             const sFile : string;
                             const fTrimInvertedCommas : boolean;
                             var DataFieldTypes : Array_T;
                             const fFindDataTypes : boolean);
procedure LoadMAT2StringGrid(AGrid : TStringGrid;
                             const sFile : string;
                             var fResult : boolean;
                             var DataFieldTypes : Array_T);
procedure LoadMTX2StringGrid(AGrid : TStringGrid;
                             const sFile : string;
                             var fResult : boolean;
                             var DataFieldTypes : Array_T);
procedure LoadCSVDimensions2Grid(const sFilename : string;
                                 var iRows,iColumns : integer;
                                 TargetGrid : TStringGrid;
                                 var DataFieldTypes : Array_T;
                                 const fFindDataTypes : boolean;
                                 const rFractionOfFileToScan : extended);

implementation

uses
    Global, SysUtils, Forms, Dialogs, Controls,
    dbmisc,
    qmtx, inifiles, tparse;


{added for table editor to read/write MAT matrix file format (same format as James Shelton/Frank Sobora uses)}
procedure LoadMATNoHeader2StringGrid(AGrid : TStringGrid;
                                     const sFile : string;
                                     var DataFieldTypes : Array_T);
var
   InFile : File;
   wWord : word;
   bByte : byte;

   iFieldCount,
   iColumn, iRow, wResult, iCount : integer;
   fBreak : boolean;
   rValue : extended;

   MtxForm : TQMtxForm;

   FieldData : FieldDataType_T;

   procedure GetNextValue(var fStopIterating : boolean);
   var
      iDataSize : integer;
   begin
        fStopIterating := False;

        {read the next value from the file}
        case MtxForm.DataTypeGroup.ItemIndex of
             0 : begin
                      iDataSize := SizeOf(byte);
                      BlockRead(InFile,bByte,iDataSize,wResult);
                 end;
             1 : begin
                      iDataSize := SizeOf(word);
                      BlockRead(InFile,wWord,iDataSize,wResult);
                 end;
        end;

        {fStopIterating is true when all data has been read from file
         ie. amount of data read by BlockRead will be < iDataSize (==0) when end of file reached}
        if (wResult < iDataSize) then
           fStopIterating := True;
   end;

   procedure PopulateCell;
   begin
        {populate cell with value}
        case MtxForm.DataTypeGroup.ItemIndex of
             0 : AGrid.Cells[iColumn,iRow] := IntToStr(bByte);
             1 : AGrid.Cells[iColumn,iRow] := IntToStr(wWord);
        end;

        {move iColumn,iRow to next data element}
        case MtxForm.OrientationGroup.ItemIndex of
             0 : {sites in 1st column}
                 begin
                      {we are moving across then down}
                      {ie. source file is same orientation as grid}
                      Inc(iColumn);
                      if (iColumn >= AGrid.ColCount) then
                      begin
                           Inc(iRow);
                           iColumn := 1;
                      end;
                 end;
             1 : {features in 1st column}
                 begin
                      {we are moving down then across}
                      {ie. source file is opposite orientation to grid}
                      Inc(iRow);
                      if (iRow >= AGrid.RowCount) then
                      begin
                           Inc(iColumn);
                           iRow := 1;
                      end;
                 end;
        end;
   end;

begin
     if FileExists(sFile) then
     try
        {determine from user dialog whether this matrix is;
                   1) byte/word
                   2) number of features/sites
                   3) orientation of matrix data}

        MtxForm := TQMtxForm.Create(Application);

        MtxForm.initmtxfile(sFile);

        if (MtxForm.ShowModal = mrOk) then
        begin
             {create DataFieldTypes for child we are loading to
              ie. array of field types which will be:
                  Int Int Int Int ... Int
                  where the size of the array is the number of columns in the grid}
             DataFieldTypes := Array_T.Create;

             assignfile(InFile,sFile);

             reset(InFile,1);
             (*
             case MtxForm.DataTypeGroup.ItemIndex of
                  0 : {byte} reset(InFile,1{SizeOf(byte)});
                  1 : {word} reset(InFile,1{SizeOf(word)});
             end;
             *)

             iColumn := 1;
             iRow := 1;

             AGrid.ColCount := MtxForm.SpinFeatures.Value + 1;
             AGrid.RowCount := MtxForm.SpinSites.Value + 1;

             {write default identifiers to first row}
             AGrid.Cells[0,0] := 'Sites';
             for iCount := 1 to (AGrid.ColCount-1) do
                 AGrid.Cells[iCount,0] := 'f' + IntToStr(iCount);
             {write default identifiers to first column}
             for iCount := 1 to (AGrid.RowCount-1) do
                 AGrid.Cells[0,iCount] := IntToStr(iCount);

             {now read the matrix data elements into the grid}
             fBreak := False;
             repeat
                   GetNextValue(fBreak);

                   if not fBreak then
                      {use value to populate the next cell}
                      PopulateCell;

             until fBreak;

             closefile(InFile);

             {write data field type array}
             DataFieldTypes.init(SizeOf(FieldDataType_T),AGrid.ColCount);
             for iFieldCount := 1 to AGrid.ColCount do
             begin
                  FieldData.DBDataType := DBaseInt;
                  FieldData.iSize := 0; {iSize has no meaning for DBaseInt, init to zero}
                  DataFieldTypes.SetValue(iFieldCount,@FieldData);
             end;
        end;

        MtxForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadMAT2StringGrid ' + sFile,mtError,[mbOk],0);
     end
     else
     begin
          Screen.Cursor := crDefault;
          MessageDlg('LoadMAT2StringGrid file ' + sFile + ' does not exist',
                     mtError,[mbOk],0);
     end;
end;




function TestCellContainsComma(sLine : string) : string;
begin
     {}
     if (Pos(',',sLine) > 0) then
        Result := '"' + sLine + '"'
     else
         Result := sLine;
end;


procedure SaveStringGrid2CSV(AGrid : TStringGrid;
                             const sFile : string);
var
   OutFile : Text;

   iCountRows,iCountCols : integer;

   fFilesOk : boolean;

begin
     fFilesOk := True;

     Assign(OutFile,sFile);

     try
        Rewrite(OutFile);

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not create output CSV file ' + sFile,
                            mtError,[mbOk],0);

                  fFilesOk := False;
            end;
     end;

     if fFilesOk then
     begin
          {now create the datafile}
          for iCountRows := 0 to (AGrid.RowCount-1) do
          begin
               for iCountCols := 0 to (AGrid.ColCount-2) do
                   write(OutFile,TestCellContainsComma(AGrid.Cells[iCountCols,iCountRows]) + ',');
               writeln(OutFile,TestCellContainsComma(AGrid.Cells[AGrid.ColCount-1,iCountRows]));
          end;

          close(OutFile);
     end;
end;


procedure SaveStringGrid2MAT(AGrid : TStringGrid;
                             const sFile : string;
                             const iRichness, iKeyColumn : integer);
var
   OutFile : File;

   iCountRows,iCountCols, iBuffPos, iInitCount, wBytesWritten : integer;

   fFilesOk : boolean;

   AHeader : MatFileHeader_T;
   ALargeBuff : LargeBuff_T;

   procedure PutNextReal(const rValue : real);
   begin
        inc(iBuffPos);

        if (iBuffPos <= LARGE_BUFF_ARR_SIZE) then
           ALargeBuff[iBuffPos] := rValue
        else
        begin
             BlockWrite(OutFile,ALargeBuff,SizeOf(ALargeBuff),wBytesWritten);
             iBuffPos := 1;
             ALargeBuff[iBuffPos] := rValue;
        end;
   end;

   procedure WriteFinalBlock;
   begin
        repeat
              PutNextReal(0);

        until (iBuffPos = 1);

        {fill up the last block with zero's
         iBuffPos = 1 indicates BlockJustWritten}
   end;

begin
     fFilesOk := True;
     iBuffPos := 0;
     AHeader.wVersionNum := 3;
     AHeader.lFeatureCount := iRichness;
     for iInitCount := 1 to MAT_SPACE_COUNT do
         AHeader.EmptySpace[iInitCount] := 0;

     Assign(OutFile,sFile);

     try
        Rewrite(OutFile,1);

        BlockWrite(OutFile,AHeader,SizeOf(AHeader),wBytesWritten);

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not create output MAT file ' + sFile,
                            mtError,[mbOk],0);

                  fFilesOk := False;
            end;
     end;

     if fFilesOk then
     begin
          {now create the datafile}
          for iCountRows := 1 to (AGrid.RowCount-1) do
          begin
               {write the site geocode which will be in column iKeyColumn}
               PutNextReal(StrToFloat(AGrid.Cells[iKeyColumn,iCountRows])); {cell col,row}
               {write iRichness numbers of feature data}
               for iCountCols := (AGrid.ColCount - iRichness) to (AGrid.ColCount-1) do
                   PutNextReal(StrToFloat(AGrid.Cells[iCountCols,iCountRows]));
          end;

          WriteFinalBlock;
          close(OutFile);
     end;
end;


procedure CountColumnsInCSVFile(const sFilename : string;
                                var iColumns : integer);
var
   fFilesOk, fInQuotes : boolean;
   ThisLine : LongLine_T;
   iLength, iCount : integer;
   cCurrChar : char;

   sFieldName : string;

   InFile : Text;
begin
     {}
     fFilesOk := True;
     iColumns := 1;

     Assign(InFile,sFilename);

     try
        Reset(InFile);

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not find input CSV file ' + sFilename,
                            mtError,[mbOk],0);

                  fFilesOk := False;
            end;
     end;

     if fFilesOk then
     try
        Screen.Cursor := crHourglass;

        iLength := 1;

        Read(InFile,cCurrChar);
        ThisLine[iLength] := cCurrChar;
        Inc(iLength);

        while not Eoln(InFile) do
        begin
             Read(InFile,cCurrChar);
             ThisLine[iLength] := cCurrChar;
             Inc(iLength);
        end;
        Dec(iLength);
        Readln(InFile);

        {count how many fields (commas) are in ThisLine (ignore commas contained in inverted commas)}
        iCount := 1;
        fInQuotes := False;
        sFieldName := '';
        repeat
              if (ThisLine[iCount] = '"') then
              begin
                   fInQuotes := not fInQuotes;

              end
              else
              begin
                   if not fInQuotes
                   and (ThisLine[iCount] = ',') then
                       Inc(iColumns);

                   if (ThisLine[iCount] <> ',') then
                      sFieldName := sFieldName + ThisLine[iCount]
                   else
                   begin
                        sFieldName := '';
                   end;
              end;

              Inc(iCount);

        until (iCount > iLength);

        CloseFile(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exceptin in LoadCSVDimensions2Grid ' + sFilename,
                      mtError,[mbOk],0);

           iColumns := 0;
     end;

     Screen.Cursor := crDefault;
end;

function CountCommasInLine(const sLine : string) : integer;
var
     iCount, iLength : integer;
begin
     Result := 0;
     iLength := Length(sLine);
     if (iLength > 0) then
          for iCount := 1 to iLength do
               if sLine[iCount] = ',' then
                    Inc(Result);
end;

{
procedure FastLoadCSV2StringGrid(AGrid : TStringGrid;
                                 const sFile : string);
var
     InFile : TextFile;
     sHeader, sLine, sScratch : string;
     iRows, iColumns, iRow, iPos : integer;

     procedure PopulateRow(const iR : integer;
                           const sL : string);
     var
          iCount : integer;
     begin
          sScratch := sL;
          for iCount := 1 to iColumns do
          begin
               iPos := Pos(',',sScratch);
               if (iPos > 0) then
               begin
                    AGrid.Cells[iCount-1,iR] := Copy(sScratch,1,iPos-1);
                    sScratch := Copy(sScratch,iPos+1,Length(sScratch)-iPos);
               end
               else
               begin
                    AGrid.Cells[iCount-1,iR] := sScratch;
                    sScratch := '';
               end;
          end;
     end;

begin
     try
        // parse file and find dimensions
        assignfile(InFile,sFile);
        reset(InFile);
        readln(InFile,sHeader);
        iColumns := CountCommasInLine(sHeader) + 1;
        iRows := 1;
        repeat
               readln(InFile,sLine);
               Inc(iRows);

        until Eof(InFile);
        closefile(InFile);
        // resize the grid
        AGrid.RowCount := iRows;
        AGrid.ColCount := iCols;
        // parse file and load into grid
        assignfile(InFile,sFile);
        reset(InFile);
        readln(InFile,sHeader);
        PopulateRow(0,sHeader);
        iRow := 1;
        repeat
               readln(InFile,sLine);
               PopulateRow(0,sLine);
               Inc(iRow);

        until Eof(InFile);
        closefile(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in fast load CSV file',mtError,[mbOk],0);
     end;
end;
}
procedure LoadCSV2StringGrid(AGrid : TStringGrid;
                             const sFile : string;
                             const fTrimInvertedCommas : boolean;
                             var DataFieldTypes : Array_T;
                             const fFindDataTypes : boolean);
var
   InFile : Text;

   ThisLine : LongLine_T;
   cCurrChar, cFirstChar : char;

   sThisCode, sExtractArea : string;

   iLength,iCount,iCount2,iRichness,
   iFeatCount,iSiteCount, iRowCount, iColCount : integer;

   fFilesOk : boolean;

   FieldData : FieldDataType_T;
   iFieldCount : integer;
   rTest : extended;
   iTest : integer;

   function UpdateTypeInformation(var FD : FieldDataType_T;
                                  const sCell : string) : boolean;
   begin
        Result := False;

        if (Length(sCell) > FD.iSize) then
        begin
             FD.iSize := Length(sCell);
             Result := True;
        end;

        if (FD.DBDataType <> DBaseStr) then
        begin
             if (FD.DBDataType = DBaseFloat) then
                try
                   {attempt float convert on sCell}
                   rTest := StrToFloat(sCell);
                except
                      FD.DBDataType := DBaseStr;
                      Result := True;
                end
             else
                 try
                    {attempt int convert}
                    iTest := StrToInt(sCell);
                 except
                       Result := True;
                       try
                          {attempt float convert}
                          rTest := StrToFloat(sCell);
                          FD.DBDataType := DBaseFloat;
                       except
                             FD.DBDataType := DBaseStr;
                       end;
                 end;
        end;
   end;

begin
     fFilesOk := True;
     iSiteCount := 0;

     Assign(InFile,sFile);

     try
        Reset(InFile);

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not find input CSV file ' + sFile,
                            mtError,[mbOk],0);

                  fFilesOk := False;
            end;
     end;

     if fFilesOk then
     begin
          {now parse the datafile}
          iLength := 1;
          iRichness := 0;

          {ImportForm.lblNumFeatures.Caption := IntToStr(iRichness);
          ImportForm.Update;}

          Read(InFile,cFirstChar);
          ThisLine[iLength] := cFirstChar;
          Inc(iLength);

          while not Eoln(InFile) do
          begin
               Read(InFile,cCurrChar);
               ThisLine[iLength] := cCurrChar;
               Inc(iLength);
          end;
          Readln(InFile);

          iCount := 1;

          sThisCode := '';

          if (cFirstChar = '"') then
          {we have inverted commas around some/all elements in CSV file}
          begin
               if (not fTrimInvertedCommas) then
                  sThisCode := ThisLine[iCount];

               Inc(iCount); {advance past first "}
               while (iCount < iLength)
               and (ThisLine[iCount] <> '"') do
               begin
                    sThisCode := sThisCode + ThisLine[iCount];
                    Inc(iCount); {seek second "}
               end;
               if (not fTrimInvertedCommas) then
                  sThisCode := sThisCode + ThisLine[iCount];
               Inc(iCount); {advance past first ,}
          end
          else
          begin
               while (iCount < iLength)
               and (ThisLine[iCount] <> ',') do
               begin
                    sThisCode := sThisCode + ThisLine[iCount];
                    Inc(iCount); {find second "}
               end;
               Inc(iCount); {advance past first ,}
          end;
          {advance past name which is first string in report}

          AGrid.RowCount := 10000;
          iRowCount := 1;
          AGrid.ColCount := 1000;
          iColCount := 1;

          TrimTrailSpaces(sThisCode);
          AGrid.Cells[0,0] := sThisCode;

          repeat
                sThisCode := '';
                cFirstChar := ThisLine[iCount];

                if (cFirstChar = '"') then
                begin
                     if (not fTrimInvertedCommas) then
                        sThisCode := ThisLine[iCount];
                     Inc(iCount); {advance past first "}
                     while (iCount < iLength)
                     and (ThisLine[iCount] <> '"') do
                     begin
                          sThisCode := sThisCode + ThisLine[iCount];
                          Inc(iCount);
                     end;
                     if (not fTrimInvertedCommas) then
                        sThisCode := sThisCode + ThisLine[iCount];
                     Inc(iCount); {advance past ,}
                end
                else
                begin
                     while (iCount < iLength)
                     and (ThisLine[iCount] <> ',') do
                     begin
                          sThisCode := sThisCode + ThisLine[iCount];
                          Inc(iCount);
                     end;
                end;



                {if (cFirstChar = '"') then
                   sThisCode := Copy(sThisCode,2,Length(sThisCode)-2);}
                {trim inverted commas from string if they are in it}

                TrimTrailSpaces(sThisCode);

                Inc(iCount); {advance past comma}

                if (sThisCode <> 'Row Total')
                and (sThisCode <> '') then
                begin
                     Inc(iRichness);

                     if (iRichness >= iColCount) then
                        iColCount := iColCount + 1;
                     if (iColCount > AGrid.ColCount) then
                        AGrid.ColCount := AGrid.ColCount + 1000;

                     {ImportForm.lblNumFeatures.Caption := IntToStr(iRichness);
                     ImportForm.Update;}

                     AGrid.Cells[iRichness,iRowCount-1] := sThisCode;
                end;

          until (iCount >= iLength) or (sThisCode = 'Row Total');

          if (iColCount <> AGrid.ColCount) then
             AGrid.ColCount := iColCount;

          if fFindDataTypes then
          begin
               {init type information to Int}
               FieldData.DBDataType := DBaseInt;
               FieldData.iSize := 0;
               DataFieldTypes := Array_T.Create;
               DataFieldTypes.init(SizeOf(FieldData),iRichness+1);
               for iFieldCount := 1 to DataFieldTypes.lMaxSize do
                   DataFieldTypes.setValue(iFieldCount,@FieldData);
          end;

          while not Eof(InFile) do
          begin
               {read each subsequent line from text file}
               Inc(iSiteCount);
               {ImportForm.lblNumSites.Caption := IntToStr(iSiteCount);}
               {ImportForm.Update;}
               iLength := 1;
               while not Eoln(InFile) do
               begin
                    Read(InFile,cCurrChar);
                    ThisLine[iLength] := cCurrChar;
                    Inc(iLength);
               end;
               Readln(InFile);

               iRowCount := iRowCount + 1;
               if (iRowCount > AGrid.RowCount) then
                  AGrid.RowCount := AGrid.RowCount + 10000;

               {extract site name from the current line}
               iCount2 := 1;
               sThisCode := '';
               cFirstChar := ThisLine[iCount2];

               if (cFirstChar = '"') then
               begin
                    if (not fTrimInvertedCommas) then
                       sThisCode := ThisLine[iCount2];
                    Inc(iCount2);
                    {advance to second inverted comma, adding characters
                     to the name string as we go}
                    while (iCount2 < iLength)
                    and (ThisLine[iCount2] <> '"') do
                    begin
                         sThisCode := sThisCode + ThisLine[iCount2];
                         Inc(iCount2);
                    end;

                    if (not fTrimInvertedCommas) then
                       sThisCode := sThisCode + ThisLine[iCount2];
                    Inc(iCount2);
               end
               else
               begin
                    while (iCount2 < iLength)
                    and (ThisLine[iCount2] <> ',') do
                    begin
                         sThisCode := sThisCode + ThisLine[iCount2];
                         Inc(iCount2);
                    end;
               end;
               Inc(iCount2); {advance past first comma}

               TrimTrailSpaces(sThisCode);
               AGrid.Cells[0,iRowCount-1] := sThisCode;

               if fFindDataTypes then
                  if (iRowCount <= 500) then
                  begin
                       {update type information for this field (column 1)}
                       DataFieldTypes.rtnValue(1,@FieldData);
                       if UpdateTypeInformation(FieldData,sThisCode) then
                          DataFieldTypes.setValue(1,@FieldData);
                  end;

               for iFeatCount := 1 to iRichness do
               begin
                    sExtractArea := '';
                    if (ThisLine[iCount2] = '"') then
                    begin
                         if (not fTrimInvertedCommas) then
                            sExtractArea := ThisLine[iCount2];
                         Inc(iCount2);

                         while(iCount2 < iLength)
                         and (ThisLine[iCount2] <> '"') do
                         begin
                              sExtractArea := sExtractArea + ThisLine[iCount2];
                              Inc(iCount2);
                         end;

                         if (not fTrimInvertedCommas) then
                            sExtractArea := sExtractArea + ThisLine[iCount2];
                         Inc(iCount2);
                    end
                    else
                    begin
                         while (iCount2 < iLength)
                         and (ThisLine[iCount2] <> ',') do
                         begin
                              sExtractArea := sExtractArea + ThisLine[iCount2];
                              Inc(iCount2);
                         end;
                    end;
                    Inc(iCount2); {advance past next comma}

                    if (sExtractArea = '') then
                       //AGrid.Cells[iFeatCount,iRowCount-1] := '0'
                    else
                    begin
                         TrimTrailSpaces(sExtractArea);

                         AGrid.Cells[iFeatCount,iRowCount-1] := sExtractArea;

                         if fFindDataTypes then
                            if (iRowCount <= 500) then
                            begin
                                 {update type information for this field (column iFeatCount + 1)}
                                 DataFieldTypes.rtnValue(iFeatCount + 1,@FieldData);
                                 if UpdateTypeInformation(FieldData,sExtractArea) then
                                    DataFieldTypes.setValue(iFeatCount + 1,@FieldData);
                            end;
                    end;
               end;
          end;

          if (iRowCount <> AGrid.RowCount) then
             AGrid.RowCount := iRowCount;
     end;

     if fFilesOk then
     begin
          Close(InFile);
     end;
end;

{added for table editor to read/write MAT matrix file format (same as C-Plan uses)}
procedure LoadMAT2StringGrid(AGrid : TStringGrid;
                             const sFile : string;
                             var fResult : boolean;
                             var DataFieldTypes : Array_T);
var
   InFile : File;
   AHeader : MatFileHeader_T;
   ALargeBuff : LargeBuff_T;
   iFieldCount,
   iBuffPos, wBytesWritten, iColumn, iRow, wResult, iCount : integer;
   fBreak : boolean;
   rValue : extended;
   FieldData : FieldDataType_T;
   BuffV4 : BuffV4_T;
   sSingle : single;

   sIniFile, sDBFFile : string;
   Parser : TTableParser;
   AnIni : TIniFile;

   function GetNextReal(var fResult : boolean) : extended;
   begin
        fResult := False;
        if (iBuffPos = 0)
        or (iBuffPos > LARGE_BUFF_ARR_SIZE) then
        begin
             {read a block}
             BlockRead(InFile,ALargeBuff,SizeOf(ALargeBuff),wResult);

             if (wResult < SizeOf(ALargeBuff)) then
             begin
                  fResult := True;
             end;

             iBuffPos := 1;
             Result := ALargeBuff[iBuffPos];
        end
        else
        begin
             {return value from loaded block}
             Result := ALargeBuff[iBuffPos];
        end;

        Inc(iBuffPos);
   end;

   function GetNextV4Real(var fResult : boolean) : single;
   begin
        fResult := False;
        if (iBuffPos = 0) or (iBuffPos > LARGE_BUFF_ARR_SIZE) then
        begin
             BlockRead(InFile,BuffV4,SizeOf(BuffV4),wResult);
             if (wResult < SizeOf(BuffV4)) then
                fResult := True;
             iBuffPos := 1;
             Result := BuffV4[iBuffPos];
        end
        else
            Result := BuffV4[iBuffPos]; {return value from loaded block}
        Inc(iBuffPos);
   end;

   procedure PopulateCell(const rValueToAdd : extended);
   begin
        if (iColumn = 0)
        and (rValueToAdd = 0) then
        begin
             {we have read the end of the last selection units features,
              rValueToAdd = 0 indicates this is contents of the final block written to disk}

             fBreak := True;
             Dec(iRow);
        end
        else
        begin
             {increase number of rows if necessary}
             if (iRow > (AGrid.RowCount-1)) then
                AGrid.RowCount := AGrid.RowCount + 1000;

             AGrid.Cells[iColumn,iRow] := FloatToStr(rValueToAdd);

             {increment column and row counters}
             Inc(iColumn);
             if (iColumn >= AGrid.ColCount) then
             begin
                  Inc(iRow);
                  iColumn := 0;
             end;
        end;
   end;

begin
     if FileExists(sFile) then
     try
        assignfile(InFile,sFile);
        reset(InFile,1);
        iBuffPos := 0;
        iColumn := 0;
        iRow := 1;
        BlockRead(InFile,AHeader,SizeOf(AHeader),wBytesWritten);

        if (AHeader.wVersionNum = 3) then
        begin
             {create DataFieldTypes for child we are loading to
              ie. array of field types which will be:
                  Int Int Int Int ... Int
                  where the size of the array is the number of columns in the grid}
             DataFieldTypes := Array_T.Create;

             fResult := True;
             AGrid.ColCount := AHeader.lFeatureCount + 1;
             AGrid.RowCount := 1000;

             AGrid.Cells[0,0] := 'Sites';
             // write column identifiers to the first row of the grid
             // read the feature names from the feature table if it is present
             sIniFile := ExtractFileDir(sFile) + '\cplan.ini';
             sDbfFile := '';
             if FileExists(sIniFile) then
             begin
                  AnIni := TIniFile.Create(sIniFile);
                  sDbfFile := AnIni.ReadString('Database1','FeatureSummaryTable','');
                  AnIni.Free;
             end;
             if (sDbfFile = '') then
             begin
                  // there is no associated feature summary table for this matrix
                  for iCount := 1 to (AGrid.ColCount-1) do
                      AGrid.Cells[iCount,0] := IntToStr(iCount);
             end
             else
             begin
                  // there is a feature summary table for this matrix
                  try
                     Parser := TTableParser.Create(Application);
                     Parser.initfile(ExtractFileDir(sFile) + '\' + sDbfFile);

                     for iCount := 1 to AHeader.lFeatureCount do
                     begin
                          AGrid.Cells[iCount,0] := Parser.DBFTable.FieldByName('FEATNAME').AsString;
                          Parser.DBFTable.Next;
                     end;

                     Parser.donefile;
                     Parser.Free;

                  except
                        //for iCount := 1 to (AGrid.ColCount-1) do
                        //    AGrid.Cells[iCount,0] := IntToStr(iCount);
                  end;
             end;

             fBreak := False;
             repeat
                   rValue := GetNextReal(fBreak);

                   if not fBreak then
                      {use rValue to populate the next cell}
                      PopulateCell(rValue);

             until fBreak;

             if (iColumn <> 0) then
                {we have loaded some null data from the last block of the file and need to delete a row
                 we have written to the table}
                Dec(iRow);

             if (AGrid.RowCount <> (iRow + 1)) then
                AGrid.RowCount := iRow + 1;

             closefile(InFile);

             {write data field type array}
             DataFieldTypes.init(SizeOf(FieldDataType_T),AGrid.ColCount);
             FieldData.DBDataType := DBaseInt;
             FieldData.iSize := 0; {iSize has no meaning for DBaseInt and DBaseFloat, init to zero}
             DataFieldTypes.SetValue(1,@FieldData);
             for iFieldCount := 2 to AGrid.ColCount do
             begin
                  FieldData.DBDataType := DBaseFloat;
                  DataFieldTypes.SetValue(iFieldCount,@FieldData);
             end;
        end
        else
        if (AHeader.wVersionNum = 4) then
        begin
             {create DataFieldTypes for child we are loading to
              ie. array of field types which will be:
                  Int Int Int Int ... Int
                  where the size of the array is the number of columns in the grid}
             DataFieldTypes := Array_T.Create;

             fResult := True;
             AGrid.ColCount := AHeader.lFeatureCount + 1;
             AGrid.RowCount := 1000;

             {write default identifiers to first row}
             AGrid.Cells[0,0] := 'Sites';
             sIniFile := ExtractFileDir(sFile) + '\cplan.ini';
             sDbfFile := '';
             if FileExists(sIniFile) then
             begin
                  AnIni := TIniFile.Create(sIniFile);
                  sDbfFile := AnIni.ReadString('Database1','FeatureSummaryTable','');
                  AnIni.Free;
             end;
             if (sDbfFile = '') then
             begin
                  // there is no associated feature summary table for this matrix
                  for iCount := 1 to (AGrid.ColCount-1) do
                      AGrid.Cells[iCount,0] := IntToStr(iCount);
             end
             else
             begin
                  // there is a feature summary table for this matrix
                  try
                     Parser := TTableParser.Create(Application);
                     Parser.initfile(ExtractFileDir(sFile) + '\' + sDbfFile);

                     for iCount := 1 to AHeader.lFeatureCount do
                     begin
                          AGrid.Cells[iCount,0] := Parser.DBFTable.FieldByName('FEATNAME').AsString;
                          Parser.DBFTable.Next;
                     end;

                     Parser.donefile;
                     Parser.Free;

                  except
                        //for iCount := 1 to (AGrid.ColCount-1) do
                        //    AGrid.Cells[iCount,0] := IntToStr(iCount);
                  end;
             end;

             fBreak := False;
             repeat
                   sSingle := GetNextV4Real(fBreak);

                   if not fBreak then
                      {use rValue to populate the next cell}
                      PopulateCell(sSingle);

             until fBreak;

             if (iColumn <> 0) then
                {we have loaded some null data from the last block of the file and need to delete a row
                 we have written to the table}
                Dec(iRow);

             if (AGrid.RowCount <> (iRow + 1)) then
                AGrid.RowCount := iRow + 1;

             closefile(InFile);

             {write data field type array}
             DataFieldTypes.init(SizeOf(FieldDataType_T),AGrid.ColCount);
             FieldData.DBDataType := DBaseInt;
             FieldData.iSize := 0; {iSize has no meaning for DBaseInt and DBaseFloat, init to zero}
             DataFieldTypes.SetValue(1,@FieldData);
             for iFieldCount := 2 to AGrid.ColCount do
             begin
                  FieldData.DBDataType := DBaseFloat;
                  DataFieldTypes.SetValue(iFieldCount,@FieldData);
             end;
        end
        else
        begin
             Screen.Cursor := crDefault;
             MessageDlg('Can only open C-Plan version 3 or 4 MAT files',mtInformation,[mbOk],0);
        end;

     except
           Screen.Cursor := crDefault;
           fResult := False;
           MessageDlg('Exception in LoadMAT2StringGrid ' + sFile,mtError,[mbOk],0);
     end
     else
     begin
          Screen.Cursor := crDefault;
          MessageDlg('LoadMAT2StringGrid file ' + sFile + ' does not exist',
                     mtError,[mbOk],0);
     end;
end;

{added for table editor to read MTX matrix file format (same as C-Plan uses)}
procedure LoadMTX2StringGrid(AGrid : TStringGrid;
                             const sFile : string;
                             var fResult : boolean;
                             var DataFieldTypes : Array_T);
var
   InMatrix,InKey : File;
   Key : KeyFile_T;
   Value : SingleValueFile_T;
   iSites, iFeatures, iSite,
   iFieldCount, iSizeOfKey, iSizeOfValue,
   iColumn, iRow,
   wResult, iCount, iBytesRead : integer;
   rValue : extended;
   FieldData : FieldDataType_T;
   sSingle : single;
   sKeyFile, sDbfFile, sIniFile,
   sMatrixName, sExtension, sPath : string;
   AnIni : TIniFile;
   Parser : TTableParser;
begin
     if FileExists(sFile) then
     try
        // sKeyFile, sDbfFile, sIniFile


        sMatrixName := ExtractFileName(sFile);
        sExtension := ExtractFileExt(sFile);
        sPath := ExtractFileDir(sFile);
        Delete(sMatrixName,Pos(sExtension,sMatrixName),Length(sExtension));

        sKeyFile := sPath + '\' + sMatrixName + '.key';

        //InitProgressForm('Load MTX file ' + sMatrixName,'parse file to find grid dimensions');

        assignfile(InMatrix,sFile);
        assignfile(InKey,sKeyFile);
        reset(InMatrix,1);
        reset(InKey,1);

        // parse the MTX & KEY file to read the number of sites and features
        // so we can create a grid of the correct dimensions
        iSizeOfKey := SizeOf(Key);
        iSizeOfValue := SizeOf(Value);
        iSites := 1;
        iFeatures := 0;
        repeat
              // read the sites from the key file one at a time
              BlockRead(InKey,Key,iSizeOfKey,iBytesRead);

              if (iBytesRead = iSizeOfKey) then
              begin
                   // read the features at this site from the values file
                   if (Key.iRichness > 0) then
                      for iCount := 1 to Key.iRichness do
                      begin
                           BlockRead(InMatrix,Value,iSizeOfValue);

                           if (Value.iFeatKey > iFeatures) then
                              iFeatures := Value.iFeatKey;
                      end;
                   Inc(iSites);
              end;

        until (iBytesRead < iSizeOfKey);
        Dec(iSites);

        //LoadProgressForm.DisplayLabel('resize grid');

        AGrid.RowCount := iSites + 1;
        AGrid.ColCount := iFeatures + 1;

        if (mrYes = MessageDlg('Populate blank cells with zeros?',mtConfirmation,[mbYes,mbNo],0)) then
        begin
             //LoadProgressForm.DisplayLabel('populate cells with zeros');

             // populate blank cells in the grid with zeros
             for iColumn := 1 to (AGrid.ColCount-1) do
                 for iRow := 1 to (AGrid.RowCount-1) do
                     AGrid.Cells[iColumn,iRow] := '0';
        end;

        //LoadProgressForm.DisplayLabel('load data to the grid');

        // close & reopen the files
        closefile(InMatrix);
        closefile(InKey);
        assignfile(InMatrix,sFile);
        assignfile(InKey,sKeyFile);
        reset(InMatrix,1);
        reset(InKey,1);

        iColumn := 0;
        iRow := 1;

        DataFieldTypes := Array_T.Create;

        fResult := True;

        AGrid.Cells[0,0] := 'Sites';
        iSite := 0;
        repeat
              // read the sites from the key file one at a time
              BlockRead(InKey,Key,iSizeOfKey,iBytesRead);

              if (iBytesRead = iSizeOfKey) then
              begin
                    Inc(iSite);
                   // write site key to the first column of the row
                   AGrid.Cells[0,iSite] := IntToStr(Key.iSiteKey);

                   // read the features at this site from the values file
                   if (Key.iRichness > 0) then
                      for iCount := 1 to Key.iRichness do
                      begin
                           BlockRead(InMatrix,Value,iSizeOfValue);

                           // write to Cells[Value.iFeatKey,iSites]
                           if (AGrid.ColCount < Value.iFeatKey) then
                           repeat
                                 AGrid.ColCount := AGrid.ColCount + 100;
                           until (AGrid.ColCount >= Value.iFeatKey);
                           AGrid.Cells[Value.iFeatKey,iSite] := FloatToStr(Value.rAmount);
                      end;
              end;

        until (iBytesRead < iSizeOfKey);

        //LoadProgressForm.DisplayLabel('read feature names');

        // write column identifiers to the first row of the grid
        // read the feature names from the feature table if it is present
        sIniFile := sPath + '\cplan.ini';
        sDbfFile := '';
        if FileExists(sIniFile) then
        begin
             AnIni := TIniFile.Create(sIniFile);
             sDbfFile := AnIni.ReadString('Database1','FeatureSummaryTable','');
             AnIni.Free;
        end;
        if (sDbfFile = '') then
        begin
             // there is no associated feature summary table for this matrix
             for iCount := 1 to (AGrid.ColCount-1) do
                 AGrid.Cells[iCount,0] := IntToStr(iCount);
        end
        else
        begin
             // there is a feature summary table for this matrix
             try
                Parser := TTableParser.Create(Application);
                Parser.initfile(sPath + '\' + sDbfFile);

                for iCount := 1 to iFeatures do
                begin
                     AGrid.Cells[iCount,0] := Parser.DBFTable.FieldByName('FEATNAME').AsString;
                     Parser.DBFTable.Next;
                end;

                Parser.donefile;
                Parser.Free;

             except
                   //for iCount := 1 to (AGrid.ColCount-1) do
                   //    AGrid.Cells[iCount,0] := IntToStr(iCount);
             end;
        end;

        closefile(InMatrix);
        closefile(InKey);

        {write data field type array}
        DataFieldTypes.init(SizeOf(FieldDataType_T),AGrid.ColCount);
        FieldData.DBDataType := DBaseInt;
        FieldData.iSize := 0; {iSize has no meaning for DBaseInt and DBaseFloat, init to zero}
        DataFieldTypes.SetValue(1,@FieldData);
        FieldData.DBDataType := DBaseFloat;
        for iFieldCount := 2 to AGrid.ColCount do
            DataFieldTypes.SetValue(iFieldCount,@FieldData);

        //LoadProgressForm.Free;

     except
           Screen.Cursor := crDefault;
           fResult := False;
           MessageDlg('Exception in LoadMTX2StringGrid ' + sFile,mtError,[mbOk],0);
     end
     else
     begin
          Screen.Cursor := crDefault;
          MessageDlg('LoadMTX2StringGrid file ' + sFile + ' does not exist',
                     mtError,[mbOk],0);
     end;
end;

(*
function rtnCellFromLine(const sLine : string;
                         const iCell : integer) : string;
var
   iLength, iCount, iColumns : integer;
   fInQuotes : boolean;
   sFieldName : string;
begin
     try
        iLength := Length(sLine);
        iCount := 1;
        iColumns := 0;
        fInQuotes := False;
        sFieldName := '';
        repeat
              if (sLine[iCount] = '"') then
              begin
                   fInQuotes := not fInQuotes;

              end
              else
              begin
                   if not fInQuotes
                   and (sLine[iCount] = ',') then
                   begin
                        Inc(iColumns);
                        if (iColumns = iCell) then
                           Continue;
                   end;

                   if (sLine[iCount] <> ',') then
                      sFieldName := sFieldName + sLine[iCount]
                   else
                   begin
                        sFieldName := '';
                   end;
              end;

              Inc(iCount);

        until (iCount > iLength);

     finally
            Result := sFieldName;
     end;
end;
*)

function rtnCSVFieldFromString(const sString : string;
                               const iColumnToReturn : integer) : string;
var
   iAtColumn, iCount, iColumn : integer;
   fInQuotes : boolean;
   sResult : string;
begin
     {return field from a line of a CSV file
      iColumn is zero referenced, ie;
      iColumn  element to return
        0        1
        1        2
        2        3
        ...}

     Result := '';
     iColumn := iColumnToReturn + 1;

     if (sString <> '') then
     try
        iCount := 1;
        iAtColumn := 1;
        fInQuotes := False;
        if (iColumn > 1) then
        repeat
              if (sString[iCount] = '"') then
              begin
                   fInQuotes := not fInQuotes;

              end
              else
              begin
                   if not fInQuotes
                   and (sString[iCount] = ',') then
                       Inc(iAtColumn);
              end;

              if (iAtColumn < iColumn) then
                 Inc(iCount);



        until (iAtColumn >= iColumn);

        {iterate from iCount to end of column
         (may be contained by "")
         (will end with , or EOLN)}
        if (sString[iCount] = '"') then
        begin
             {cell is enclosed in double quotes}
             sResult := sString[iCount];

             repeat
                   Inc(iCount);
                   sResult := sResult + sString[iCount];

             until (sString[iCount] = '"');

             if (sResult[Length(sResult)] <> '"') then
                sResult := sResult + '"';
        end
        else
        begin
             {cell is not enclosed in double quotes}
             sResult := sString[iCount];

             repeat
                   Inc(iCount);

                   if (iCount <= Length(sString)) then
                   begin
                        if (sString[iCount] <> ',') then
                           sResult := sResult + sString[iCount]
                        else
                            iCount := Length(sString);
                   end;

             until (iCount >= Length(sString));
        end;

        if (sResult[1] = ',') then
           sResult := Copy(sResult,2,Length(sResult)-1);
        {TrimInvertedCommas from the result if there are any}
        if (sResult[1] = '"') then
           sResult := Copy(sResult,2,Length(sResult)-2);

        Result := sResult;


     except
           Result := '0';
           //MessageDlg('Exception in rtnCSVFieldFromString at column ' + IntToStr(iColumnToReturn) +
           //           ' of line >' + sString + '<' ,
           //           mtError,[mbOk],0);
     end;
end;


procedure LoadCSVDimensions2Grid(const sFilename : string;
                                 var iRows,iColumns : integer;
                                 TargetGrid : TStringGrid;
                                 var DataFieldTypes : Array_T;
                                 const fFindDataTypes : boolean;
                                 const rFractionOfFileToScan : extended);
var
   fFilesOk, fInQuotes : boolean;
   ThisLine : LongLine_T;
   iLength, iCount, iFileSize, iFileBytesRead, iBytesToScan : integer;
   cCurrChar : char;

   sFieldName, sLine, sCell : string;

   InFile : Text;

   FieldData : FieldDataType_T;
   iFieldCount : integer;
   rTest : extended;
   iTest : integer;

   function UpdateTypeInformation(var FD : FieldDataType_T;
                                  const sCell : string) : boolean;
   begin
        Result := False;

        if (Length(sCell) > FD.iSize) then
        begin
             FD.iSize := Length(sCell);
             Result := True;
        end;

        if (FD.DBDataType <> DBaseStr) then
        begin
             if (FD.DBDataType = DBaseFloat) then
                try
                   {attempt float convert on sCell}
                   rTest := StrToFloat(sCell);
                except
                      FD.DBDataType := DBaseStr;
                      Result := True;
                end
             else
                 try
                    {attempt int convert}
                    iTest := StrToInt(sCell);
                 except
                       Result := True;
                       try
                          {attempt float convert}
                          rTest := StrToFloat(sCell);
                          FD.DBDataType := DBaseFloat;
                       except
                             FD.DBDataType := DBaseStr;
                       end;
                 end;
        end;
   end;

begin
     {}
     fFilesOk := True;
     iRows := 1;
     iColumns := 1;

     Assign(InFile,sFilename);

     try
        Reset(InFile);
        iFileSize := FileSize(InFile);
        iFileBytesRead := 0;

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not find input CSV file ' + sFilename,
                            mtError,[mbOk],0);

                  fFilesOk := False;
            end;
     end;

     if fFilesOk then
     try
        Screen.Cursor := crHourglass;

        iLength := 1;

        Read(InFile,cCurrChar);
        ThisLine[iLength] := cCurrChar;
        Inc(iLength);
        Inc(iFileBytesRead);

        while not Eoln(InFile) do
        begin
             Read(InFile,cCurrChar);
             ThisLine[iLength] := cCurrChar;
             Inc(iLength);
             Inc(iFileBytesRead);
        end;
        Dec(iLength);
        Readln(InFile);
        Inc(iFileBytesRead);

        {count how many fields (commas) are in ThisLine (ignore commas contained in inverted commas)}
        iCount := 1;
        fInQuotes := False;
        sFieldName := '';
        TargetGrid.ColCount := 1;
        TargetGrid.RowCount := 1;
        repeat
              if (ThisLine[iCount] = '"') then
              begin
                   fInQuotes := not fInQuotes;

              end
              else
              begin
                   if not fInQuotes
                   and (ThisLine[iCount] = ',') then
                       Inc(iColumns);

                   if (ThisLine[iCount] <> ',') then
                      sFieldName := sFieldName + ThisLine[iCount]
                   else
                   begin
                        TargetGrid.ColCount := iColumns;
                        TargetGrid.Cells[iColumns-2,0] := sFieldName;

                        sFieldName := '';
                   end;
              end;

              Inc(iCount);

        until (iCount > iLength);

        TargetGrid.ColCount := iColumns;
        TargetGrid.Cells[iColumns-1,0] := sFieldName;

        {init type information to Int}
        if fFindDataTypes then
        begin
             FieldData.DBDataType := DBaseInt;
             FieldData.iSize := 0;
             DataFieldTypes := Array_T.Create;
             DataFieldTypes.init(SizeOf(FieldData),iColumns);
             for iFieldCount := 1 to DataFieldTypes.lMaxSize do
                 DataFieldTypes.setValue(iFieldCount,@FieldData);
        end;

        iBytesToScan := Round(iFileSize * rFractionOfFileToScan);

        {count how many lines remain in the file, add to iRows}
        repeat
              Inc(iRows);
              readln(InFile,sLine);

              Inc(iFileBytesRead,SizeOf(sLine));

              if fFindDataTypes then
                 if (iFileBytesRead <= iBytesToScan) then
                 //if (iRows < iRowsToScan{CSV_TYPESCAN_LINES}) then
                 begin
                      {for each field in sLine}
                      for iFieldCount := 1 to DataFieldTypes.lMaxSize do
                      begin
                           {extract cell iFieldCount from sLine}
                           sCell := rtnCSVFieldFromString(sLine,        {current line from CSV file}
                                                          iFieldCount-1 {field to extract from line, 0 referenced
                                                                         hence the -1 on the index}
                                                          );
                           {update type information for this field (column iFieldCount)}
                           DataFieldTypes.rtnValue(iFieldCount,@FieldData);
                           if UpdateTypeInformation(FieldData,sCell) then
                              DataFieldTypes.setValue(iFieldCount,@FieldData);
                      end;
                 end;
        until Eof(InFile);

        CloseFile(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadCSVDimensions2Grid ' + sFilename,
                      mtError,[mbOk],0);

           iRows := 0;
           iColumns := 0;
     end;

     Screen.Cursor := crDefault;
end;

end.
