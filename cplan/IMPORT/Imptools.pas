unit Imptools;

{$I IMP_DEF.DEF}

interface

uses
    Grids, Global, Sysutils, Forms, Controls, Dialogs,
    Dbtables;

procedure LoadCSV2StringGrid(AGrid : TStringGrid;
                             const sFile : string;
                             const fTrimInvertedCommas : boolean);
procedure LoadCSVDimensions(const sFilename : string;
                             var iRows,iColumns : integer);
procedure LoadCSVDimensions2Grid(const sFilename : string;
                                 var iRows,iColumns : integer;
                                 TargetGrid : TStringGrid);
procedure SaveStringGrid2CSV(AGrid : TStringGrid;
                             const sFile : string);
procedure LoadTRN2StringGrid(AGrid : TStringGrid;
                             const sFile : string);
procedure SaveStringGrid2TRN(AGrid : TStringGrid;
                             const sFile : string);

{added for table editor to read/write MAT matrix file format (same as C-Plan uses)}
procedure LoadMAT2StringGrid(AGrid : TStringGrid;
                             const sFile : string);
procedure SaveStringGrid2MAT(AGrid : TStringGrid;
                             const sFile : string;
                             const iRichness, iKeyColumn : integer);

function SortTrimInput(CSVGrid, TRNGrid : TStringGrid) : boolean;

function NewSiteSummary(const sTableName, sPath : string;
                         NewTable : TTable) : boolean;
function NewFeatSummary(const sTableName, sPath : string;
                         NewTable : TTable) : boolean;

procedure Parse2File(const sInFile : string;
                     var sLabel : string;
                     const sOutPath : string;
                     SS_Table, FS_Table : TTable;
                     var sOutMatrixFile : string;
                     var iOutFeatureCount : integer);
{for importing very large matrices}

procedure Parse2FileV2(const sInFile : string;
                       var sLabel : string;
                       const sOutPath : string;
                       SS_Table, FS_Table : TTable;
                       var sOutMatrixFile : string;
                       var iOutFeatureCount : integer);

procedure CSV2Matrix(CSVGrid : TStringGrid;
                     FSTable : TTable;
                     const sLabel, sOutPath : string;
                     const iStartCol : integer);
procedure CSV2SiteSummary(CSVGrid : TStringGrid;
                          SSTable : TTable;
                          const sLabel, sOutPath : string);
procedure TRN2SiteSummary(TRNGrid : TStringGrid;
                          SSTable : TTable;
                          const sLabel, sOutPath : string);
function CopyDBFile(const sSourceFile, sDestFile : string) : boolean;
function CheckImportSize(CSVGrid, TRNGrid : TStringGrid) : boolean;


{Count the Columns In a CSV File}
procedure CountColumnsInCSVFile(const sFilename : string;
                            var iColumns : integer);


implementation

uses
    DB, Dbms_man,
     Dbmisc, IniFiles, Control,
    ds;



function GenerateUniqueLabel(const sLabel, sOutPath : string) : string;
var
   sLocalLabel, sFileName : string;
   iInc : integer;

   function IncLabel(const iInt : integer) : string;
   begin
        {this works for iInt = 0..99}

        if (iInt < 10) then
           Result := '0' + IntToStr(iInt)
        else
            Result := IntToStr(iInt);
   end;

   function IncName(const sALabel : string) : string;
   begin
        Result := sALabel;

        if (iInc > 0) then
        begin
             if (Length(Result) > 3) then
                Result := Copy(Result,1,3);

             Result := Result + IncLabel(iInc);
        end;

        Inc(iInc);
   end;

begin
     iInc := 0;

     repeat
           sLocalLabel := IncName(sLabel);

           sFileName := sOutPath + '\features_' + sLocalLabel + '.DBF';

     until not FileExists(sFileName);

     Result := sLocalLabel;
end;

function TestSSIni(const sOutPath : string;
                   var sExistingTable : string) : boolean;
var
   AnIni : TIniFile;
begin
     AnIni := TIniFile.Create(sOutPath + INI_FILE_NAME);

     sExistingTable := AnIni.ReadString('Options','SiteSummaryTable','NOT FOUND');

     if (sExistingTable = 'NOT FOUND') then
        Result := True
     else
         Result := False;
end;

procedure Parse2File(const sInFile : string;
                     var sLabel : string;
                     const sOutPath : string;
                     SS_Table, FS_Table : TTable;
                     var sOutMatrixFile : string;
                     var iOutFeatureCount : integer);
var
   InFile : Text;
   LargeOutFile : file of LargeBuff_T;
   SmallOutFile : file of Buff_T;

   ThisLine : array [1..LINE_MAX] of Char;
   cCurrChar, cFirstChar : char;
   sGeocode, sExtractArea, sSiteName,
   sMatrixFile, sSSTable, sFSTable,
   sLocalLabel, sExistSSTable : string;

   ALargeBuff : LargeBuff_T;
   ASmallBuff : Buff_T;

   iLength,iCount,iCount2,iRichness,
   iFeatCount,iSiteCount,iMatCount,
   iPos : integer;

   fFilesOk, fUseLargeBuff,
   fCreateSSTable : boolean;

   rRichness, rExtractArea : real;

   {$IFDEF DBG_ROW_TOTALS}
   rDbgRowTotal : real;
   {$ENDIF}

begin
     fFilesOk := True;
     iSiteCount := 0;

     iOutFeatureCount := 0;
     {init to zero in case no features found in parse}

     sLocalLabel := GenerateUniqueLabel(sLabel,sOutPath);
     sLabel := sLocalLabel;

     Assign(InFile,sInFile);

     try
        Reset(InFile);

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not find input TEXT file',
                            mtError,[mbOk],0);
                 fFilesOk := False;
            end;
     end;


     if fFilesOk then
     begin
          sSSTable := 'sites_' + sLocalLabel + '.DBF';
          sFSTable := 'features_' + sLocalLabel + '.DBF';

          fCreateSSTable := TestSSIni(sOutPath,sExistSSTable);

          if fCreateSSTable then
             fFilesOK := NewSiteSummary(sSSTable,sOutPath,SS_Table)
             {we need to create a new site summary table}
          else
          begin
               SS_Table.TableName := sExistSSTable;
               SS_Table.DatabaseName := sOutPath;
               {we will open an existing site summary table}
          end;

          if fFilesOK then
             fFilesOK := NewFeatSummary(sFSTable,sOutPath,
                                        FS_Table);
     end;

     if fFilesOk then
     try
        SS_Table.Open;

     except on EDBEngineError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not find existing Site file',
                            mtError,[mbOK],0);
                 fFilesOk := False;
                 Close(InFile);
                 {Close(OutFile);}
            end;
     end;

     if fFilesOk then
     try
        FS_Table.Open;

     except on EDBEngineError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not find output Feature Cut-Off file',
                            mtError,[mbOK],0);
                 fFilesOk := False;
                 Close(InFile);
                 {Close(OutFile);}
                 SS_Table.Close;
            end;
     end;

     if fFilesOk then
     begin
          {now parse the datafile}
          iLength := 1;
          iRichness := 0;

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

          if (cFirstChar = '"') then
          begin
               while (iCount < iLength)
               and (ThisLine[iCount] <> '"') do
                   Inc(iCount); {find first "}
               Inc(iCount); {advance past first "}
               while (iCount < iLength)
               and (ThisLine[iCount] <> ',') do
                   Inc(iCount); {find second "}
               Inc(iCount,2); {advance past second " and first ,}
          end
          else
          begin
               while (iCount < iLength)
               and (ThisLine[iCount] <> ',') do
                   Inc(iCount);
               Inc(iCount); {advance past first ,}
          end;
          {advance past Key which is first string in report}

          if (cFirstChar = '"') then
          begin
               while (iCount < iLength)
               and (ThisLine[iCount] <> '"') do
                   Inc(iCount); {find first "}
               Inc(iCount); {advance past first "}
               while (iCount < iLength)
               and (ThisLine[iCount] <> ',') do
                   Inc(iCount); {find second "}
               Inc(iCount,2); {advance past second " and first ,}
          end
          else
          begin
               while (iCount < iLength)
               and (ThisLine[iCount] <> ',') do
                   Inc(iCount);
               Inc(iCount); {advance past first ,}
          end;
          {advance past Label which is second string in report}

          repeat
                {now build the feature list from this line}

                sGeocode := '';
                while (iCount < iLength)
                and (ThisLine[iCount] <> ',') do
                begin
                     sGeocode := sGeocode + ThisLine[iCount];
                     Inc(iCount);
                end;

                Inc(iCount); {advance past comma}

                if (sGeocode <> 'Row Total')
                and (sGeocode <> '') then
                begin
                     {add this feature code to the feature list}
                     Inc(iRichness);

                     with FS_Table do
                     begin
                          Append;
                          FieldByName(ControlRes^.sFeatureKeyField).AsInteger := iRichness;
                          FieldByName('CODE').AsString := sGeocode;
                          FieldByName('CUTOFF').AsInteger := DEFAULT_CUTOFF;
                          Post;
                     end;
                end;

          until (iCount >= iLength) or (sGeocode = 'Row Total');

          iOutFeatureCount := iRichness;
          {set return value for feature count}

          rRichness := iRichness*1.0;

          fUseLargeBuff := False;
          if (iRichness > BUFF_ARR_SIZE) then
          begin
               if (iRichness > LARGE_BUFF_ARR_SIZE) then
               begin
                    fFilesOk := False;
                    MessageDlg('Too many features, max is ' +
                               IntToStr(LARGE_BUFF_ARR_SIZE) +
                               ', Input file is ' + IntToStr(iRichness),
                               mtError,[mbOK],0);
               end
               else
                   fUseLargeBuff := True;
          end;

          {now that we know the feature count, create the output file}
          try
             sMatrixFile := sOutPath + '\F_' + sLocalLabel + '.MAT';

             sOutMatrixFile := sMatrixFile;
             {set return value for filename}

             if fUseLargeBuff then
             begin
                  Assign(LargeOutFile,sMatrixFile);
                  rewrite(LargeOutFile);
             end
             else
             begin
                  Assign(SmallOutFile,sMatrixFile);
                  rewrite(SmallOutFile);
             end;

          except on EInOutError do
                 begin
                      Screen.Cursor := crDefault;

                      MessageDlg('Could not create output Matrix file',
                                 mtError,[mbOK],0);
                      fFilesOk := False;
                      Close(InFile);
                      exit;
                 end;
          end;

          if fUseLargeBuff then
          begin
               ALargeBuff[1] := rRichness;
               for iMatCount := 2 to LARGE_BUFF_ARR_SIZE do
                   ALargeBuff[iMatCount] := -1;

               write(LargeOutFile,ALargeBuff);
               {write richness to start of matrix}
          end
          else
          begin
               ASmallBuff[1] := rRichness;
               for iMatCount := 2 to BUFF_ARR_SIZE do
                   ASmallBuff[iMatCount] := -1;

               write(SmallOutFile,ASmallBuff);
               {write richness to start of matrix}
          end;

          FS_Table.Close;
          {close the Feature Summary Table}

          {now we must move through each site line in the rest of the text file
           and write that sites feature info to the database file}
          while not Eof(InFile) do
          begin
               {read current line from text file}
               Inc(iSiteCount);
               iLength := 1;
               while not Eoln(InFile) do
               begin
                    Read(InFile,cCurrChar);
                    ThisLine[iLength] := cCurrChar;
                    Inc(iLength);
               end;
               Readln(InFile);

               {extract key from the current line}
               iCount2 := 1;
               sGeocode := '';

               if (cFirstChar = '"') then
               begin
                    while(iCount2<iLength)
                    and (ThisLine[iCount2] <> '"') do
                        Inc(iCount2); {advance to first inverted comma}
                    Inc(iCount2); {advance past it}

                    {advance to second inverted comma, adding characters
                     to the name string as we go}
                    while (iCount2 < iLength)
                    and (ThisLine[iCount2] <> '"') do
                    begin
                         sGeocode := sGeocode + ThisLine[iCount2];
                         Inc(iCount2);
                    end;

                    Inc(iCount2); {advance past second inverted comma}
               end
               else
               begin
                    while (iCount2 < iLength)
                    and (ThisLine[iCount2] <> ',') do
                    begin
                         sGeocode := sGeocode + ThisLine[iCount2];
                         Inc(iCount2);
                    end;
               end;

               Inc(iCount2); {advance past first comma}
               sSiteName := '';

               if (cFirstChar = '"') then
               begin
                    while(iCount2<iLength)
                    and (ThisLine[iCount2] <> '"') do
                        Inc(iCount2); {advance to first inverted comma}
                    Inc(iCount2); {advance past it}

                    {advance to second inverted comma, adding characters
                     to the name string as we go}
                    while (iCount2 < iLength)
                    and (ThisLine[iCount2] <> '"') do
                    begin
                         sSiteName := sSiteName + ThisLine[iCount2];
                         Inc(iCount2);
                    end;

                    Inc(iCount2); {advance past second inverted comma}
               end
               else
               begin
                    while (iCount2 < iLength)
                    and (ThisLine[iCount2] <> ',') do
                    begin
                         sSiteName := sSiteName + ThisLine[iCount2];
                         Inc(iCount2);
                    end;
               end;
               Inc(iCount2); {advance past first comma}

               {now trim spaces from the end of the site name}
               iPos := Length(sSiteName);
               while (sSiteName[iPos] = ' ') do
                     Dec(iPos);
               sSiteName := Copy(sSiteName,1,iPos);

               iPos := Length(sGeocode);
               while (sGeocode[iPos] = ' ') do
                     Dec(iPos);
               sGeocode := Copy(sGeocode,1,iPos);

               with SS_Table do
               begin
                    if fCreateSSTable then
                    begin
                         Append;
                         FieldByName('NAME').AsString := sSiteName;
                         FieldByName('KEY').AsString := sGeocode;
                         Post;
                    end
                    else
                    begin
                         if (FieldByName('KEY').AsString <> sGeocode) then
                         begin
                              Screen.Cursor := crDefault;
                              MessageDlg('Cannot find KEY ' + sGeocode +
                                         ' in existing Site Summary Table',
                                         mtError,[mbOk],0);

                              SS_Table.Close;
                              FS_Table.Close;
                              closefile(InFile);

                              Exit;
                         end;

                         Next;
                    end;
               end;

               {$IFDEF DBG_ROW_TOTALS}
               rDbgRowTotal := 0;
               {$ENDIF}

               {extract present features from the current line}
               if (iRichness < LARGE_BUFF_ARR_SIZE-2) then
               begin
                    for iFeatCount := 1 to iRichness do
                    begin
                         sExtractArea := '';
                         while (iCount2 < iLength)
                         and (ThisLine[iCount2] <> ',') do
                         begin
                              sExtractArea := sExtractArea + ThisLine[iCount2];
                              Inc(iCount2);
                         end;
                         Inc(iCount2); {advance past next comma}

                         if (sExtractArea = '') then
                            rExtractArea := 0
                         else
                             rExtractArea := StrToFloat(sExtractArea);

                         if fUseLargeBuff then
                            ALargeBuff[iFeatCount] := rExtractArea
                         else
                             ASmallBuff[iFeatCount] := rExtractArea;

                         {$IFDEF DBG_ROW_TOTALS}
                         rDbgRowTotal := rDbgRowTotal + rExtractArea;
                         {$ENDIF}
                    end;

                    if fUseLargeBuff then
                    begin
                         if (iRichness < LARGE_BUFF_ARR_SIZE) then
                            for iMatCount := iRichness+1 to LARGE_BUFF_ARR_SIZE do
                                ALargeBuff[iMatCount] := -1;
                    end
                    else
                    begin
                         if (iRichness < BUFF_ARR_SIZE) then
                            for iMatCount := iRichness+1 to BUFF_ARR_SIZE do
                                ASmallBuff[iMatCount] := -1;
                    end;
               end
               else
                   MessageDlg('Richness > LARGE_BUFF_ARR_SIZE',mtError,[mbOK],0);

               {$IFDEF DBG_ROW_TOTALS}
               Debug2File(1,'iSiteCount ' + IntToStr(iSiteCount) +
                          ' DBG_ROW_TOTALS ' + FloatToStr(rDbgRowTotal));
               {$ENDIF}

               if fUseLargeBuff then
                  write(LargeOutFile,ALargeBuff)
               else
                   write(SmallOutFile,ASmallBuff);
               {write current extracted areas to matrix}
          end;
     end;

     if fFilesOk then
     begin
          Close(InFile);
          if fUseLargeBuff then
             Close(LargeOutFile)
          else
              Close(SmallOutFile);
          SS_Table.Close;
     end;

end; {end procedure Parse2File}

procedure Parse2FileV2(const sInFile : string;
                       var sLabel : string;
                       const sOutPath : string;
                       SS_Table, FS_Table : TTable;
                       var sOutMatrixFile : string;
                       var iOutFeatureCount : integer);
var
   InFile : Text;
   LargeOutFile : file;
   AHeader : MatFileHeader_T;

   ThisLine : array [1..LINE_MAX] of Char;
   cCurrChar, cFirstChar : char;
   sGeocode, sExtractArea, sSiteName,
   sMatrixFile, sSSTable, sFSTable,
   sLocalLabel, sExistSSTable, sMsg : string;

   ALargeBuff : LargeBuff_T;
   ASmallBuff : Buff_T;

   iLength,iCount,iCount2,iRichness,
   iFeatCount,iSiteCount,iMatCount,
   iPos, iInitCount : integer;

   fFilesOk, fCreateSSTable : boolean;

   rExtractArea : real;

   iGeocode,
   iBuffPos, iSeekPos : integer;
   wBytesWritten :
   {$IFDEF bit16}
   word
   {$ELSE}
   integer
   {$ENDIF};

   {$IFDEF DBG_ROW_TOTALS}
   rDbgRowTotal : real;
   {$ENDIF}


   procedure PutNextReal(const rValue : real);
   begin
        inc(iBuffPos);

        if (iBuffPos <= LARGE_BUFF_ARR_SIZE) then
           ALargeBuff[iBuffPos] := rValue
        else
        begin
             BlockWrite(LargeOutFile,ALargeBuff,SizeOf(ALargeBuff),wBytesWritten);
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
     try

        fFilesOk := True;
        iSiteCount := 0;
        iBuffPos := 0;

        iOutFeatureCount := 0;
        {init to zero in case no features found in parse}

        sLocalLabel := GenerateUniqueLabel(sLabel,sOutPath);
        sLabel := sLocalLabel;

        Assign(InFile,sInFile);

        try
           Reset(InFile);

        except on EInOutError do
               begin
                    Screen.Cursor := crDefault;

                    MessageDlg('Could not find input TEXT file',
                               mtError,[mbOk],0);
                    fFilesOk := False;
               end;
        end;


        if fFilesOk then
        begin
             sSSTable := UpperCase('sites_' + sLocalLabel + '.DBF');
             sFSTable := UpperCase('features_' + sLocalLabel + '.DBF');

             fCreateSSTable := TestSSIni(sOutPath,sExistSSTable);

             if fCreateSSTable then
                fFilesOK := NewSiteSummary(sSSTable,sOutPath,SS_Table)
                {we need to create a new site summary table}
             else
             begin
                  SS_Table.TableName := sExistSSTable;
                  SS_Table.DatabaseName := sOutPath;
                  {we will open an existing site summary table}
             end;

             if fFilesOK then
                fFilesOK := NewFeatSummary(sFSTable,sOutPath,
                                           FS_Table);
        end;

        if fFilesOk then
        try
           SS_Table.Open;

        except on EDBEngineError do
               begin
                    Screen.Cursor := crDefault;

                    MessageDlg('Could not find existing Site file',
                               mtError,[mbOK],0);
                    fFilesOk := False;
                    Close(InFile);
                    {Close(OutFile);}
               end;
        end;

        if fFilesOk then
        try
           FS_Table.Open;

        except on EDBEngineError do
               begin
                    Screen.Cursor := crDefault;

                    MessageDlg('Could not find output Feature Cut-Off file',
                               mtError,[mbOK],0);
                    fFilesOk := False;
                    Close(InFile);
                    {Close(OutFile);}
                    SS_Table.Close;
               end;
        end;

        if fFilesOk then
        begin
             {now parse the datafile}
             iLength := 1;
             iRichness := 0;

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

             if (cFirstChar = '"') then
             begin
                  Inc(iCount); {advance past first "}
                  while (iCount < iLength)
                  and (ThisLine[iCount] <> '"') do
                      Inc(iCount); {find second "}
                  Inc(iCount); {advance past ,}
             end
             else
             begin
                  while (iCount < iLength)
                  and (ThisLine[iCount] <> ',') do
                      Inc(iCount);
                  Inc(iCount); {advance past first ,}
             end;
             {advance past Key which is first string in report}

             cFirstChar := ThisLine[iCount];
             if (cFirstChar = '"') then
             begin
                  Inc(iCount); {advance past first "}
                  while (iCount < iLength)
                  and (ThisLine[iCount] <> '"') do
                      Inc(iCount); {find second "}
                  Inc(iCount); {advance past ,}
             end
             else
             begin
                  while (iCount < iLength)
                  and (ThisLine[iCount] <> ',') do
                      Inc(iCount);
                  Inc(iCount); {advance past first ,}
             end;
             {advance past Label which is second string in report}

             repeat
                   {now build the feature list from this line}

                   sGeocode := '';
                   cFirstChar := ThisLine[iCount];
                   if (cFirstChar = '"') then
                   begin
                        Inc(iCount);
                        while (iCount < iLength)
                        and (ThisLine[iCount] <> '"') do
                        begin
                             sGeocode := sGeocode + ThisLine[iCount];
                             Inc(iCount);
                        end;
                        Inc(iCount);
                   end
                   else
                       while (iCount < iLength)
                       and (ThisLine[iCount] <> ',') do
                       begin
                            sGeocode := sGeocode + ThisLine[iCount];
                            Inc(iCount);
                       end;

                   Inc(iCount); {advance past comma}

                   if (sGeocode <> 'Row Total')
                   and (sGeocode <> '') then
                   begin
                        {add this feature code to the feature list}
                        Inc(iRichness);

                        with FS_Table do
                        begin
                             Append;
                             FieldByName(ControlRes^.sFeatureKeyField).AsInteger := iRichness;
                             FieldByName('FEATNAME').AsString := sGeocode;
                             FieldByName('ITARGET').AsInteger := DEFAULT_CUTOFF;
                             Post;
                        end;
                   end;

             until (iCount >= iLength) or (sGeocode = 'Row Total');

             iOutFeatureCount := iRichness;
             {set return value for feature count}

             {now that we know the feature count, create the output file}
             try
                sMatrixFile := sOutPath + '\F_' + sLocalLabel + '.MAT';

                sOutMatrixFile := sMatrixFile;
                {set return value for filename}

                Assign(LargeOutFile,sMatrixFile);
                rewrite(LargeOutFile,1);

             except on EInOutError do
                    begin
                         Screen.Cursor := crDefault;

                         MessageDlg('Could not create output Matrix file',
                                    mtError,[mbOK],0);
                         fFilesOk := False;
                         Close(InFile);
                         exit;
                    end;
             end;

             {$IFDEF bit16}
             AHeader.wVersionNum := 2;
             {$ELSE}
             AHeader.wVersionNum := 3;
             {$ENDIF}


             AHeader.lFeatureCount := iRichness;
             for iInitCount := 1 to MAT_SPACE_COUNT do
                 AHeader.EmptySpace[iInitCount] := 0;
                 {initialise empty space in header}

             {sMsg := 'sizeof header ' + IntToStr(SizeOf(AHeader)) +
                     ' word ' + IntToStr(SizeOf(word)) +
                     ' longint ' + IntToStr(SizeOf(longint));
             MessageDlg(sMsg,mtInformation,[mbOk],0);}

             BlockWrite(LargeOutFile,AHeader,SizeOf(AHeader),wBytesWritten);
             {write richness to start of matrix}

             FS_Table.Close;
             {close the Feature Summary Table}

             {now we must move through each site line in the rest of the text file
              and write that sites feature info to the database file}
             while not Eof(InFile) do
             begin
                  {read current line from text file}
                  Inc(iSiteCount);

                  {$IFDEF DBbuild}
                  DBManForm.lblProgress.Caption := 'Processing Site ' + IntToStr(iSiteCount) {+
                                         ' of ' + IntToStr()};
                  {$ENDIF}

                  iLength := 1;
                  while not Eoln(InFile) do
                  begin
                       Read(InFile,cCurrChar);
                       ThisLine[iLength] := cCurrChar;
                       Inc(iLength);
                  end;
                  Readln(InFile);

                  {extract key from the current line}
                  iCount2 := 1;
                  sGeocode := '';

                  cFirstChar := ThisLine[iCount2];
                  if (cFirstChar = '"') then
                  begin
                       Inc(iCount2);

                       {advance to second inverted comma, adding characters
                        to the name string as we go}
                       while (iCount2 < iLength)
                       and (ThisLine[iCount2] <> '"') do
                       begin
                            sGeocode := sGeocode + ThisLine[iCount2];
                            Inc(iCount2);
                       end;

                       Inc(iCount2); {advance past second inverted comma}
                  end
                  else
                  begin
                       while (iCount2 < iLength)
                       and (ThisLine[iCount2] <> ',') do
                       begin
                            sGeocode := sGeocode + ThisLine[iCount2];
                            Inc(iCount2);
                       end;
                  end;

                  Inc(iCount2); {advance past first comma}


                  {extract name from current line}

                  sSiteName := '';

                  cFirstChar := ThisLine[iCount2];
                  if (cFirstChar = '"') then
                  begin
                       Inc(iCount2);

                       {advance to second inverted comma, adding characters
                        to the name string as we go}
                       while (iCount2 < iLength)
                       and (ThisLine[iCount2] <> '"') do
                       begin
                            sSiteName := sSiteName + ThisLine[iCount2];
                            Inc(iCount2);
                       end;
                  end
                  else
                  begin
                       while (iCount2 < iLength)
                       and (ThisLine[iCount2] <> ',') do
                       begin
                            sSiteName := sSiteName + ThisLine[iCount2];
                            Inc(iCount2);
                       end;
                  end;
                  Inc(iCount2); {advance past first comma}

                  {now trim spaces from the end of the site name}
                  iPos := Length(sSiteName);
                  if (iPos > 0) then
                  while (sSiteName[iPos] = ' ') do
                        Dec(iPos);
                  sSiteName := Copy(sSiteName,1,iPos);

                  iPos := Length(sGeocode);
                  if (iPos > 0) then
                  while (sGeocode[iPos] = ' ') do
                        Dec(iPos);
                  sGeocode := Copy(sGeocode,1,iPos);

                  with SS_Table do
                  begin
                       if fCreateSSTable then
                       begin
                            Append;
                            FieldByName('NAME').AsString := sSiteName;

                            iGeocode := StrToInt(sGeocode);

                            FieldByName('KEY').AsInteger := iGeocode;
                            Post;
                       end
                       else
                       begin
                            if (FieldByName('KEY').AsString <> sGeocode) then
                            begin
                                 Screen.Cursor := crDefault;
                                 MessageDlg('Cannot find KEY ' + sGeocode +
                                            ' in existing Site Summary Table',
                                            mtError,[mbOk],0);

                                 SS_Table.Close;
                                 FS_Table.Close;
                                 closefile(InFile);

                                 Exit;
                            end;

                            iGeocode := StrToInt(sGeocode);
                            Next;
                       end;
                  end;

                  {$IFDEF DBG_ROW_TOTALS}
                  rDbgRowTotal := 0;
                  {$ENDIF}

                  {write each sites geocode before its matrix
                   information for validation of site order on reload}
                  PutNextReal(iGeocode);

                  {extract present features from the current line}
                  if (iRichness < LARGE_BUFF_ARR_SIZE-2) then
                  begin
                       for iFeatCount := 1 to iRichness do
                       begin
                            sExtractArea := '';
                            while (iCount2 < iLength)
                            and (ThisLine[iCount2] <> ',') do
                            begin
                                 sExtractArea := sExtractArea + ThisLine[iCount2];
                                 Inc(iCount2);
                            end;
                            Inc(iCount2); {advance past next comma}

                            if (sExtractArea = '') then
                               rExtractArea := 0
                            else
                                try
                                   rExtractArea := StrToFloat(sExtractArea);
                                except
                                      Screen.Cursor := crDefault;
                                      MessageDlg('Exception in Parse2FileV2 at site ' + IntToStr(iSiteCount) +
                                                 ' when converting feature ' + IntToStr(iFeatCount),
                                                 mtError,[mbOk],0);
                                end;

                            PutNextReal(rExtractArea);

                            {$IFDEF DBG_ROW_TOTALS}
                            rDbgRowTotal := rDbgRowTotal + rExtractArea;
                            {$ENDIF}
                       end;
                  end
                  else
                      MessageDlg('Richness > LARGE_BUFF_ARR_SIZE',mtError,[mbOK],0);

                  {$IFDEF DBG_ROW_TOTALS}
                  Debug2File(1,'iSiteCount ' + IntToStr(iSiteCount) +
                             ' DBG_ROW_TOTALS ' + FloatToStr(rDbgRowTotal));
                  {$ENDIF}
             end;
        end;

        if fFilesOk then
        begin
             Close(InFile);

             WriteFinalBlock;
             Close(LargeOutFile);

             SS_Table.Close;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Parse2FileV2 at site ' + IntToStr(iSiteCount),
                      mtError,[mbOk],0);
     end;

end; {end procedure Parse2FileV2}


procedure CSV2Matrix(CSVGrid : TStringGrid;
                     FSTable : TTable;
                     const sLabel, sOutPath : string;
                     const iStartCol : integer);
var
   OutFile : file of Buff_T;
   OutFile2 : file of LargeBuff_T;

   iCount, iMatCount : integer;
   fFilesOk : boolean;
   wOldCursor : word;
   rRichness, rExtractArea : real;
   sMatrix : string;

   ABuff : Buff_T;
   ALargeBuff : LargeBuff_T;

   fUseLargeBuff : boolean;

   {$IFDEF DBG_ROW_TOTALS}
   rRowTotal : real;
   {$ENDIF}

begin
     fFilesOk := True;
     fUseLargeBuff := False;
     if ((CSVGrid.ColCount - (iStartCol+1)) > BUFF_ARR_SIZE) then
     begin
          if ((CSVGrid.ColCount - (iStartCol+1)) > LARGE_BUFF_ARR_SIZE) then
          begin
               fFilesOk := False;
               MessageDlg('Too many features, max is ' +
                          IntToStr(LARGE_BUFF_ARR_SIZE) +
                          ' yours is ' + IntToStr(CSVGrid.ColCount-(iStartCol+1)),
                          mtError,[mbOK],0);
          end
          else
              fUseLargeBuff := True;
     end;

     {initialise the buffers}
     for iCount := 1 to BUFF_ARR_SIZE do
         ABuff[iCount] := 0;
     for iCount := 1 to LARGE_BUFF_ARR_SIZE do
         ALargeBuff[iCount] := 0;

     {$IFDEF DBbuild}
     DBManForm.lblProcess.Caption := 'Saving Matrix...';
     DBManForm.Update;
     {$ENDIF}

     sMatrix := sOutPath + '\f_' + sLabel +'.mat';

     try
        if fUseLargeBuff then
        begin
             Assign(OutFile2,sMatrix);
             rewrite(OutFile2);
        end
        else
        begin
             Assign(OutFile,sMatrix);
             rewrite(OutFile);
        end;

     except on EInOutError do
            begin
                 wOldCursor := Screen.Cursor;
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not create output Feature Matrix file',
                            mtError,[mbOK],0);

                 Screen.Cursor := wOldCursor;
                 fFilesOk := False;
            end;
     end;

     if fFilesOk then
     try
        fFilesOk := NewFeatSummary('features_' + sLabel + '.dbf',sOutPath,FSTable);
        FSTable.Open;
     except on EDBEngineError do
            begin
                 wOldCursor := Screen.Cursor;
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not create output Feature Cut-Off file',
                            mtError,[mbOK],0);

                 Screen.Cursor := wOldCursor;
                 fFilesOk := False;
                 Close(OutFile);
            end;
     end;

     if fFilesOk then
     begin
          {now build the feature list from the first row of CSVGrid}
          for iCount := iStartCol to (CSVGrid.ColCount-1) do
              with FSTable do
              begin
                   Append;
                   FieldByName(ControlRes^.sFeatureKeyField).AsInteger := (iCount-iStartCol+1);
                   FieldByName('CODE').AsString := CSVGrid.Cells[iCount,0];
                   FieldByName('CUTOFF').AsInteger := DEFAULT_CUTOFF;
                   Post;
              end;

          rRichness := (CSVGrid.ColCount-iStartCol)*1.0;

          if fUseLargeBuff then
          begin
               ALargeBuff[1] := rRichness;
               {for iMatCount := 2 to LARGE_BUFF_ARR_SIZE do
                   ALargeBuff[iMatCount] := -1;}

               write(OutFile2,ALargeBuff);
          end
          else
          begin
               ABuff[1] := rRichness;
               {for iMatCount := 2 to BUFF_ARR_SIZE do
                   ABuff[iMatCount] := -1;}

               write(OutFile,ABuff);
          end;
          {write richness to start of matrix}

          FSTable.Close;
          {close the Feature Summary Table}

          {now we must move through each site line
           and write that sites feature info to the database file}

          {if ((CSVGRID.ColCount-1) >= BUFF_ARR_SIZE-2) then
             MessageDlg('Richness > BUFF_ARR_SIZE',mtError,[mbOK],0)
          else}

          {$IFDEF DBG_ROW_TOTALS}
          Debug2File(0,'');
          {$ENDIF}

          for iCount := 1 to (CSVGrid.RowCount-1) do
          begin
               {$IFDEF DBG_ROW_TOTALS}
               rRowTotal := 0;
               {$ENDIF}

               for iMatCount := 2{iStartCol} to (CSVGrid.ColCount-1) do
               begin
                    try
                       rExtractArea := StrToFloat(CSVGrid.Cells[iMatCount,iCount]);

                    except on exception do
                           begin
                                rExtractArea := 0;
                                MessageDlg('exception in GridConvert, col ' +
                                           IntToStr(iMatCount) + ' row ' +
                                           IntToStr(iCount),mtError,[mbOK],0);
                           end;
                    end;

                    {$IFDEF DBG_ROW_TOTALS}
                    rRowTotal := rRowTotal + rExtractArea;

                    if (iMatCount = 2) then
                       Debug2File(1,'RFval ' + FloatToStr(rExtractArea) +
                                  ' siteidx ' + IntToStr(iCount));
                    {$ENDIF}

                    if fUseLargeBuff then
                       ALargeBuff[iMatCount-1] := rExtractArea
                    else
                        ABuff[iMatCount-1] := rExtractArea;
               end;

               {$IFDEF DBG_ROW_TOTALS}
               Debug2File(1,'DBG_ROW_TOTALS  site index ' +
                          IntToStr(iCount) + ' ' +
                          FloatToStr(rRowTotal));
               {$ENDIF}


               {if (CSVGrid.ColCount < BUFF_ARR_SIZE) then
                  for iMatCount := CSVGrid.ColCount to BUFF_ARR_SIZE do
                      if fUseLargeBuff then
                         ALargeBuff[iMatCount] := -1
                      else
                          ABuff[iMatCount] := -1;}

               if fUseLargeBuff then
                  write(OutFile2,ALargeBuff)
               else
                   write(OutFile,ABuff);
               {write current extracted areas to matrix}
          end;
     end;

     if fFilesOk then
     begin
          if fUseLargeBuff then
             Close(OutFile2)
          else
              Close(OutFile);

          FSTable.Close;

          sMatrix := ExtractFileName(sMatrix);

          {$IFDEF DBbuild}
          AddMatrixIni(sOutPath + '\' + INI_FILE_NAME,sLabel,
                       sMatrix,FSTable.TableName,0,
                       (DBManForm.CSVFile.ColCount - 2));
          {$ENDIF}
          {update the cplan.ini file with the new matrix}
     end;
end;


procedure TRN2SiteSummary(TRNGrid : TStringGrid;
                          SSTable : TTable;
                          const sLabel, sOutPath : string);
var
   fFilesOk : boolean;
   wOldCursor : word;
   iCount : integer;

begin
     fFilesOk := True;

     if fFilesOk then
     try
        fFilesOk := NewSiteSummary('sites_' + sLabel + '.dbf',sOutPath,SSTable);
        SSTable.Open;

     except on EDBEngineError do
            begin
                 fFilesOk := False;

                 wOldCursor := Screen.Cursor;
                 Screen.Cursor := crDefault;

                 MessageDlg('Cannot create Sites file',mtError,[mbOK],0);

                 Screen.Cursor := wOldCursor;
            end;
     end;

     if fFilesOk then
     begin
          {now transfer the site data}
          for iCount := 0 to (TRNGrid.RowCount-1) do
          begin
               with SSTable do
               begin
                    Append;
                    FieldByName('KEY').AsString := TRNGrid.Cells[1,iCount];
                    FieldByName('NAME').AsString := TRNGrid.Cells[0,iCount];
                    Post;
               end;
          end;

          SSTable.Close;

          NewIni(sOutPath + INI_FILE_NAME,SSTable.TableName);
     end;
end;

procedure CSV2SiteSummary(CSVGrid : TStringGrid;
                          SSTable : TTable;
                          const sLabel, sOutPath : string);
var
   fFilesOk : boolean;
   wOldCursor : word;
   iCount : integer;

begin
     fFilesOk := True;

     if fFilesOk then
     try
        fFilesOk := NewSiteSummary('sites_' + sLabel + '.dbf',sOutPath,SSTable);
        SSTable.Open;

     except on EDBEngineError do
            begin
                 fFilesOk := False;

                 wOldCursor := Screen.Cursor;
                 Screen.Cursor := crDefault;

                 MessageDlg('Cannot create Sites file',mtError,[mbOK],0);

                 Screen.Cursor := wOldCursor;
            end;
     end;

     if fFilesOk then
     begin
          {now transfer the site data}
          for iCount := 1 to (CSVGrid.RowCount-1) do
          begin
               with SSTable do
               begin
                    Append;
                    FieldByName('KEY').AsString := CSVGrid.Cells[0,iCount];
                    {geocode (key) is column 0}
                    FieldByName('NAME').AsString := CSVGrid.Cells[1,iCount];
                    {name (label) is column 1}
                    Post;
               end;
          end;

          SSTable.Close;

          NewIni(sOutPath + INI_FILE_NAME,SSTable.TableName);
     end;
end;

function SortTrimInput(CSVGrid, TRNGrid : TStringGrid) : boolean;
var
   iCount, iRedundantSites, iCountShuffle,
   iIterCount, iCSVCount : integer;
   wDlgResult : word;
   sCSVSite, sTRNSite : string;
begin
     Result := True;

     iCSVCount := 0;
     iIterCount := 0;
     {procedure SortGrid(var AGrid : TStringGrid;
                   const iRowStartIndex, iColIndex : integer;
                   const wSortType : word);}

     {sort the CSVGrid}
     {SortGrid(CSVGrid,1,0,SORT_TYPE_REAL);}

     (*
     Form2.lblProcess.Caption := 'Sorting CSV...';
     Form2.Update;

     CSVGrid.RowCount := CSVGrid.RowCount + 1;
     repeat
           fUnsorted := False;

           {CSV Grid has field line in line 0}
           for iCount := 2 to (CSVGrid.RowCount-2) do
           begin
                try
                   if (CompareStr(CSVGrid.Cells[0,iCount-1],
                                  CSVGrid.Cells[0,iCount]) > 0) then
                   begin
                        {swap rows iCount and iCount-1}

                        CSVGrid.Rows[CSVGrid.RowCount-1] := CSVGrid.Rows[iCount];
                        CSVGrid.Rows[iCount] := CSVGrid.Rows[iCount-1];
                        CSVGrid.Rows[iCount-1] := CSVGrid.Rows[CSVGrid.RowCount-1];

                        fUnsorted := True;
                   end;
                except on exception do;
                end;
           end;

           Inc(iIterCount);

           Form2.lblCount.Caption := IntToStr(iIterCount);
           Form2.Update;

     until not fUnsorted;
     CSVGrid.RowCount := CSVGrid.RowCount - 1;

     {SortGrid(TRNGrid,0,0,SORT_TYPE_REAL);}
     {sort the TRNGrid}
     Form2.lblProcess.Caption := 'Sorting TRN...';
     Form2.Update;

     TRNGrid.RowCount := TRNGrid.RowCount + 1;
     repeat
           fUnsorted := False;

           for iCount := 1 to (TRNGrid.RowCount-2) do
               if (CompareStr(TRNGrid.Cells[0,iCount-1],
                              TRNGrid.Cells[0,iCount]) > 0) then
               begin
                    {swap rows iCount and iCount-1}

                    TRNGrid.Rows[TRNGrid.RowCount-1] := TRNGrid.Rows[iCount];
                    TRNGrid.Rows[iCount] := TRNGrid.Rows[iCount-1];
                    TRNGrid.Rows[iCount-1] := TRNGrid.Rows[TRNGrid.RowCount-1];

                    fUnsorted := True;
               end;

           Inc(iCSVCount);

           Form2.lblCount.Caption := IntToStr(iCSVCount);
           Form2.Update;

     until not fUnsorted;
     TRNGrid.RowCount := TRNGrid.RowCount - 1;


     SaveStringGrid2CSV(CSVGrid,'c:\sorted.csv');
     SaveStringGrid2TRN(TRNGrid,'c:\sorted.trn');
     *)

     {check if we need to trim any sites}
     if (TRNGrid.RowCount > (CSVGrid.RowCount-1)) then
     begin
          iRedundantSites := TRNGrid.RowCount -
                             CSVGrid.RowCount + 1;

          Screen.Cursor := crDefault;

          wDlgResult := MessageDlg(
             'There is ' + IntToStr(iRedundantSites) +
             ' redundant site(s) in the TRN file.  ' +
             ' Insert null site(s) to Matrix?',mtConfirmation,
             [mbYes,mbNo],0);

          Screen.Cursor := crHourglass;

          if (wDlgResult = mrNo) then
             Result := False
          else
          begin
               {insert null sites to CSVGrid
                matching from the TRNGrid}

               {$IFDEF DBbuild}
               DBManForm.lblCount.Caption := '';
               DBManForm.lblProcess.Caption := 'Inserting Null Sites...';
               DBManForm.Update;
               {$ENDIF}

               for iCount := 0 to (TRNGrid.RowCount-1) do
               begin
                    sCSVSite := CSVGrid.Cells[0,iCount+1];


                    {sTRNSite := TRNGrid.Cells[0,iCount];} {column 0 is Name}
                    sTRNSite := TRNGrid.Cells[1,iCount];   {column 1 is Geocode}

                    if (CompareStr(sCSVSite,sTRNSite) <> 0) then
                    begin
                         CSVGrid.RowCount := CSVGrid.RowCount + 1;

                         for iCountShuffle := (CSVGrid.RowCount-1) downto (iCount + 1) do
                             CSVGrid.Rows[iCountShuffle] := CSVGrid.Rows[iCountShuffle-1];

                         CSVGrid.Cells[0,iCount+1] := sTRNSite;
                         for iCountShuffle := 1 to (CSVGrid.ColCount-1) do
                             CSVGrid.Cells[iCountShuffle,iCount+1] := '0';
                    end;
               end;
          end;
     end
     {else
         if (TRNGrid.RowCount <> (CSVGrid.RowCount-1)) then
         begin
              wDlgResult := MessageDlg('Mismatch in input site count, TRN ' +
                                       IntToStr(TRNGrid.RowCount) +
                                       ' CSV ' + IntToStr(CSVGrid.RowCount-1),
                                       mtError,[mbOK],0);
              Result := False;
         end};
end;

function CheckImportSize(CSVGrid, TRNGrid : TStringGrid) : boolean;
var
   iCount, iRedundantSites, iCountShuffle,
   iIterCount, iCSVCount : integer;
   wDlgResult : word;
   sCSVSite, sTRNSite : string;
begin
     Result := True;

     iCSVCount := 0;
     iIterCount := 0;

     {check if we need to trim any sites}
     if (TRNGrid.RowCount > CSVGrid.RowCount) then
     begin
          iRedundantSites := TRNGrid.RowCount -
                             CSVGrid.RowCount + 1;

          Screen.Cursor := crDefault;

          wDlgResult := MessageDlg(
             'There is ' + IntToStr(iRedundantSites) +
             ' redundant site(s) in the TRN file.  ' +
             ' Insert null site(s) to Matrix?',mtConfirmation,
             [mbYes,mbNo],0);

          Screen.Cursor := crHourglass;

          if (wDlgResult = mrNo) then
             Result := False
          else
          begin
               {insert null sites to CSVGrid
                matching from the TRNGrid}

               {$IFDEF DBbuild}
               DBManForm.lblCount.Caption := '';
               DBManForm.lblProcess.Caption := 'Inserting Null Sites...';
               DBManForm.Update;
               {$ENDIF}

               for iCount := 0 to (TRNGrid.RowCount-1) do
               begin
                    sCSVSite := CSVGrid.Cells[0,iCount+1];

                    sTRNSite := TRNGrid.Cells[0,iCount];   {column 0 is Geocode}

                    if (CompareStr(sCSVSite,sTRNSite) <> 0) then
                    begin
                         CSVGrid.RowCount := CSVGrid.RowCount + 1;

                         for iCountShuffle := (CSVGrid.RowCount-1) downto (iCount + 1) do
                             CSVGrid.Rows[iCountShuffle] := CSVGrid.Rows[iCountShuffle-1];

                         CSVGrid.Cells[0,iCount+1] := sTRNSite;
                         for iCountShuffle := 1 to (CSVGrid.ColCount-1) do
                             CSVGrid.Cells[iCountShuffle,iCount+1] := '0';
                    end;
               end;
          end;
     end
     else{
         if (TRNGrid.RowCount <> (CSVGrid.RowCount)) then
         begin
              wDlgResult := MessageDlg('Mismatch in input site count, TRN ' +
                                       IntToStr(TRNGrid.RowCount) +
                                       ' CSV ' + IntToStr(CSVGrid.RowCount-1),
                                       mtError,[mbOK],0);
              Result := False;
         end};
end;

function CopyDBFile(const sSourceFile, sDestFile : string) : boolean;
var
   iHInFile, iHOutFile, iFilePos,
   iSeekInPos, iSeekOutPos,
   iBytesRead, iBytesWritten : integer;
   wWord : word;
begin
     Result := True;
     iHInFile := FileOpen(sSourceFile,fmOpenRead);
     iBytesWritten := 0;

     if (iHInFile > 0) then
     begin
          iHOutFile := FileCreate(sDestFile);

          if (iHOutFile > 0) then
          begin
               iFilePos := 0;

               repeat
                     iSeekInPos := FileSeek(iHInFile,iFilePos,0);

                     iBytesRead := FileRead(iHInFile,wWord,1);

                     if (iBytesRead = 1) then
                     begin
                          iSeekOutPos := FileSeek(iHOutFile,iFilePos,0);
                          Inc(iFilePos);
                          iBytesWritten := FileWrite(iHOutFile,wWord,1);
                     end;

               until (iBytesWritten < 1)
               or (iBytesRead < 1);

               FileClose(iHOutFile);
          end
          else
              Result := False;

          FileClose(iHInFile);

          if (iBytesWritten < 1) then
             Result := False;
             {MessageDlg('CopyDBFile, ' + sSourceFile +
                        ' to ' + sDestFile,mtError,[mbOK],0);}
     end
     else
     begin
          Screen.Cursor := crDefault;

          MessageDlg('Cannot find ' + sSourceFile + '  Please contact software support',
                     mtError,[mbOk],0);

          Result := False;
     end;
end;

function NewSiteSummary(const sTableName, sPath : string;
                         NewTable : TTable) : boolean;
begin
     Result := CopyDBFile(ExtractFilePath(Application.ExeName) + DEFAULT_SITE_SUMMARY,sPath + '\' + sTableName);

     with NewTable do
     begin
          DatabaseName := sPath;
          TableName := sTableName;
     end;
end;

function NewFeatSummary(const sTableName, sPath : string;
                         NewTable : TTable) : boolean;
begin
     Result := CopyDBFile(ExtractFilePath(Application.ExeName) + DEFAULT_FEAT_SUMMARY,sPath + '\' + sTableName);

     with NewTable do
     begin
          DatabaseName := sPath;
          TableName := sTableName;
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

{added for table editor to read/write MAT matrix file format (same as C-Plan uses)}
procedure LoadMAT2StringGrid(AGrid : TStringGrid;
                             const sFile : string);
var
   InFile : File;
   AHeader : MatFileHeader_T;
   ALargeBuff : LargeBuff_T;
   iBuffPos, wBytesWritten, iColumn, iRow, wResult, iCount : integer;
   fBreak : boolean;
   rValue : extended;

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

        AGrid.ColCount := AHeader.lFeatureCount + 1;
        AGrid.RowCount := 1000;

        {write default identifiers to first row}
        AGrid.Cells[0,0] := 'Sites';
        for iCount := 1 to (AGrid.ColCount-1) do
            AGrid.Cells[iCount,0] := 'f' + IntToStr(iCount);

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

procedure SaveStringGrid2TRN(AGrid : TStringGrid;
                             const sFile : string);
var
   OutFile : Text;
   iCountRows,iCountPadd : integer;
   sSiteName : string;
   fFilesOk : boolean;

begin
     fFilesOk := True;

     Assign(OutFile,sFile);

     try
        Rewrite(OutFile);

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not create output TRN file ' + sFile,
                            mtError,[mbOk],0);

                 fFilesOk := False;
            end;
     end;

     if fFilesOk then
     begin
          writeln(OutFile);

          {now create the datafile}
          for iCountRows := 0 to (AGrid.RowCount-1) do
          begin
               sSiteName := AGrid.Cells[0,iCountRows];

               if (Length(sSiteName) < LEN_SITE_NAME) then
                  for iCountPadd := Length(sSiteName)+1 to LEN_SITE_NAME do
                      sSiteName := sSiteName + ' '
               else
                   sSiteName := Copy(sSiteName,1,LEN_SITE_NAME);


               writeln(OutFile,sSiteName +
                               AGrid.Cells[1,iCountRows] +
                               ' 1');
          end;

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

                 MessageDlg('Could not find input CSV file',
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


procedure LoadCSVDimensions2Grid(const sFilename : string;
                                 var iRows,iColumns : integer;
                                 TargetGrid : TStringGrid);
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
     iRows := 1;
     iColumns := 1;

     Assign(InFile,sFilename);

     try
        Reset(InFile);

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not find input CSV file',
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

        {count how many lines remain in the file, add to iRows}
        repeat
              Inc(iRows);
              readln(InFile);

        until Eof(InFile);

        CloseFile(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exceptin in LoadCSVDimensions2Grid ' + sFilename,
                      mtError,[mbOk],0);

           iRows := 0;
           iColumns := 0;
     end;

     Screen.Cursor := crDefault;
end;

procedure LoadCSVDimensions(const sFilename : string;
                             var iRows,iColumns : integer);
var
   fFilesOk, fInQuotes : boolean;
   ThisLine : LongLine_T;
   iLength, iCount : integer;
   cCurrChar : char;

   InFile : Text;
begin
     {}
     fFilesOk := True;
     iRows := 1;
     iColumns := 1;

     Assign(InFile,sFilename);

     try
        Reset(InFile);

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not find input CSV file',
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
              end;

              Inc(iCount);

        until (iCount > iLength);

        {count how many lines remain in the file, add to iRows}
        repeat
              Inc(iRows);
              readln(InFile);

        until Eof(InFile);

        CloseFile(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exceptin in LoadCSVDimensions ' + sFilename,
                      mtError,[mbOk],0);

           iRows := 0;
           iColumns := 0;
     end;

     Screen.Cursor := crDefault;
end;

procedure LoadCSV2StringGrid(AGrid : TStringGrid;
                             const sFile : string;
                             const fTrimInvertedCommas : boolean);
var
   InFile : Text;

   ThisLine : LongLine_T;
   cCurrChar, cFirstChar : char;

   sThisCode, sExtractArea : string;

   iLength,iCount,iCount2,iRichness,
   iFeatCount,iSiteCount : integer;

   fFilesOk : boolean;

begin
     fFilesOk := True;
     iSiteCount := 0;

     Assign(InFile,sFile);

     try
        Reset(InFile);

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not find input CSV file',
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

          AGrid.RowCount := 1;
          AGrid.ColCount := 1;

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

                     if (iRichness >= AGrid.ColCount) then
                        AGrid.ColCount := AGrid.ColCount + 1;

                     {ImportForm.lblNumFeatures.Caption := IntToStr(iRichness);
                     ImportForm.Update;}

                     AGrid.Cells[iRichness,AGrid.RowCount-1] := sThisCode;
                end;

          until (iCount >= iLength) or (sThisCode = 'Row Total');


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

               AGrid.RowCount := AGrid.RowCount + 1;

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
               AGrid.Cells[0,AGrid.RowCount-1] := sThisCode;

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
                       AGrid.Cells[iFeatCount,AGrid.RowCount-1] := '0'
                    else
                    begin
                         TrimTrailSpaces(sExtractArea);
                         AGrid.Cells[iFeatCount,AGrid.RowCount-1] := sExtractArea;
                    end;
               end;
          end;
     end;

     if fFilesOk then
     begin
          Close(InFile);
     end;
end;



procedure LoadTRN2StringGrid(AGrid : TStringGrid;
                             const sFile : string);
var
   InFile : Text;

   sName, sGeocode, sInLine : string;

   iGeoEnd : integer;

   fFilesOk, fFirstLine : boolean;

begin
     fFilesOk := True;

     Assign(InFile,sFile);

     try
        Reset(InFile);

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not find input TRN file',
                            mtError,[mbOk],0);

                  fFilesOk := False;
            end;
     end;

     if fFilesOk then
     begin
          {now parse the datafile}

          Readln(InFile);
          {first line of input file is blank}

          AGrid.RowCount := 1;
          fFirstLine := True;
          AGrid.ColCount := 2;

          while not Eof(InFile) do
          begin
               Readln(InFile,sInLine);
               {read each subsequent line from text file}

               if (Length(sInLine) > 32) then
               begin
                    if fFirstLine then
                       fFirstLine := False
                    else
                        AGrid.RowCount := AGrid.RowCount + 1;

                    sName := Copy(sInLine,1,32);

                    {trim spaces from end of sName}
                    while (sName[Length(sName)] = ' ') do
                          sName := Copy(sName,1,Length(sName)-1);

                    {find end of geocode in sInLine}
                    iGeoEnd := Length(sInLine);
                    while (sInLine[iGeoEnd] <> ' ') do
                          Dec(iGeoEnd);

                    sGeocode := Copy(sInLine,33,iGeoEnd-33);

                    AGrid.Cells[0,AGrid.RowCount-1] := sName;
                    AGrid.Cells[1,AGrid.RowCount-1] := sGeocode;
               end;
          end;
     end;

     if fFilesOk then
     begin
          Close(InFile);
     end;
end;

end.
