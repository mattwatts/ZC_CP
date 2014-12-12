unit converter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBTables, Db, ds,
  StdCtrls, ExtCtrls, Buttons, grids;

const
     LINE_MAX = 32768; {maximum length of LongLine_T input text line}
type
    // these types are used for reading ascii delimited files
    LongLine_T = array [1..LINE_MAX] of Char;

    FDType_T = (DBaseFloat,
                DBaseInt,
                DBaseStr);
    str255 = string[255];
    FieldDataType_T = record
                    DBDataType : FDType_T;
                    sName, sLegalDbfName : str255;
                    iSize : integer; {length of string if DBaseStr is string}
                    iDigit2 : integer; {added 28 july 1998}
                      end;
    FieldToImport_T = record
          DBDataType : FDType_T;
          sName, sNewName, sTable, sPath, sKeyField  : str255;
          iSize : integer;
          ArrayOfValues : Array_t
                      end;

    // these types are for the sparse matrix implementation
    KeyFile_T = record
                  iSiteKey : integer;
                  iRichness : word;
                end;
    SingleValueFile_T = record
                    iFeatKey : word;
                    rAmount : single;
                  end;
    JoinedMtx_T = record
                    iSiteKey : integer;
                    iFeatKey : word;
                    rAmount : single;
                  end;


  TConvertModule = class(TDataModule)
    Query1: TQuery;
    Table1: TTable;
    Table2: TTable;
    function MTX2DBF(const sMtxFile, sMtxColumnNameFile, sDbfFile : string) : boolean;
    function Delimited2DBF(const sDelimitedFile, sDbfFile, sDelimiter : string) : boolean;
    procedure DBF2MTX(const sDbfFile, sMtxFile : string);
    procedure DBF2Delimited(const sDbfFile, sDelimitedFile, sDelimiter : string);
    procedure ScanDelimitedFileFieldTypes(const sDelimitedFile, sDelimiter : string;
                                          const iCheckType, iCheckCount : integer;
                                          var TypeInfo : Array_t);
    procedure ScanDBaseFileFieldTypes(const sDBFFile : string;
                                      var TypeInfo : Array_t);
    procedure CreateDestinationDbfTable(const sDbfFile : string;
                                        const TypeInfo : Array_t);
    procedure CreateIndexTable(const sDbfFile : string;
                               const iNameSize : integer);
    procedure CreateIdxDestinationDbfTable(const sDbfFile : string;
                                           const TypeInfo : Array_t);
    procedure PopulateDbfTable(const sDelimitedFile,sDbfFile,sDelimiter : string;
                               const TypeInfo : Array_t);
    procedure PopulateIndexTable(const sDbfFile : string;
                                 const TypeInfo : Array_t);
    procedure PopulateIdxDbfTable(const sDelimitedFile,sDbfFile,sDelimiter : string;
                                  const TypeInfo : Array_t);
    function GetNameSize(const TypeInfo : Array_t) : integer;
    procedure PopulateMtxIndexTable(const sDbfFile, sFeatureDbfFile : string;
                                    const iRowsToCreate : integer);
    procedure JoinMtxFiles(const sInKey1, sInMtx1, sInKey2, sInMtx2, sOutKey, sOutMtx : string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;



//
// perl cgi databases chris hutchinson 6771 5897
//
procedure AutoFitGrid(AGrid : TStringGrid;
                      Canvas : TCanvas;
                      const fFitEntireGrid : boolean);
function TrimTrailingSlashes(const sLine : string) : string;
function IsDBaseFieldNameValid(const sField : string) : boolean;
function IsLocalSQLReserveWord(const sWord : string) : boolean;

var
  ConvertModule: TConvertModule;

implementation

uses Main, inifiles, sort_joined_mtx;

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

{$R *.DFM}

procedure DumpMatrix2File(Matrix : Array_t;
                          const sFilename : string);
var
   iCount : integer;
   Element : JoinedMtx_T;
   OutFile : TextFile;
begin
     assignfile(OutFile,sFilename);
     rewrite(OutFile);
     writeln(OutFile,'index,SiteKey,FeatKey,Amount');

     for iCount := 1 to Matrix.lMaxSize do
     begin
          Matrix.rtnValue(iCount,@Element);
          writeln(OutFile,IntToStr(iCount) + ',' +
                          IntToStr(Element.iSiteKey) + ',' +
                          IntToStr(Element.iFeatKey) + ',' +
                          FloatToStr(Element.rAmount));
     end;

     closefile(OutFile);
end;


procedure TConvertModule.JoinMtxFiles(const sInKey1, sInMtx1, sInKey2, sInMtx2, sOutKey, sOutMtx : string);
var
   InKey1, InMtx1, InKey2, InMtx2, OutKey, OutMtx : file;
   Key : KeyFile_T;
   Value : SingleValueFile_T;
   CombinedMatrix, SortedMatrix : Array_t;
   Element : JoinedMtx_T;
   iCombinedMatrixSize, iElement, iCount, iIn1MaxFeatKey : integer;
   OutKeyText, OutMtxText, InKeyText1, InMtxText1, InKeyText2, InMtxText2 : TextFile;
   sOutKeyText, sOutMtxText, sInKeyText1, sInMtxText1, sInKeyText2, sInMtxText2 : string;
begin
     try
        // open the 4 file input files
        assignfile(InKey1,sInKey1);
        assignfile(InKey2,sInKey2);
        assignfile(InMtx1,sInMtx1);
        assignfile(InMtx2,sInMtx2);
        reset(InKey1,1);
        reset(InKey2,1);
        reset(InMtx1,1);
        reset(InMtx2,1);
        // create the 2 output files
        assignfile(OutKey,sOutKey);
        assignfile(OutMtx,sOutMtx);
        rewrite(OutKey,1);
        rewrite(OutMtx,1);
        // create output text files
        sOutKeyText := ExtractFilePath(sOutKey) + 'out_key.csv';
        sOutMtxText := ExtractFilePath(sOutMtx) + 'out_mtx.csv';
        assignfile(OutKeyText,sOutKeyText);
        assignfile(OutMtxText,sOutMtxText);
        rewrite(OutKeyText);
        rewrite(OutMtxText);
        writeln(OutKeyText,'sitekey,richness');
        writeln(OutMtxText,'featkey,amount');
        // in text 1
        sInKeyText1 := ExtractFilePath(sOutKey) + 'in_key1.csv';
        sInMtxText1 := ExtractFilePath(sOutMtx) + 'in_mtx1.csv';
        assignfile(InKeyText1,sInKeyText1);
        assignfile(InMtxText1,sInMtxText1);
        rewrite(InKeyText1);
        rewrite(InMtxText1);
        writeln(InKeyText1,'sitekey,richness');
        writeln(InMtxText1,'featkey,amount');
        // in text 2
        sInKeyText2 := ExtractFilePath(sOutKey) + 'in_key2.csv';
        sInMtxText2 := ExtractFilePath(sOutMtx) + 'in_mtx2.csv';
        assignfile(InKeyText2,sInKeyText2);
        assignfile(InMtxText2,sInMtxText2);
        rewrite(InKeyText2);
        rewrite(InMtxText2);
        writeln(InKeyText2,'sitekey,richness');
        writeln(InMtxText2,'featkey,amount');

        // create the temporary array that will hold the contents of the input files
        iCombinedMatrixSize := Round((FileSize(InMtx1) + FileSize(InMtx2)) / SizeOf(SingleValueFile_T) {* SizeOf(JoinedMtx_T)});
        CombinedMatrix := Array_t.Create;
        CombinedMatrix.init(SizeOf(JoinedMtx_T),iCombinedMatrixSize);
        //  JoinedMtx_T = record
        //                  iSiteKey : integer;
        //                  iFeatKey : word;
        //                  rAmount : single;
        //                end;
        // load the contents of In1 to the matrix
        iElement := 0;
        iIn1MaxFeatKey := 0;
        repeat
              BlockRead(InKey1,Key,SizeOf(Key));

              writeln(InKeyText1,IntToStr(Key.iSiteKey) + ',' + IntToStr(Key.iRichness));

              // add this site key to the master site list
              if (Key.iRichness > 0) then
                 for iCount := 1 to Key.iRichness do
                 begin
                      BlockRead(InMtx1,Value,SizeOf(Value));
                      Inc(iElement);
                      Element.iSiteKey := Key.iSiteKey;
                      Element.iFeatKey := Value.iFeatKey;
                      Element.rAmount := Value.rAmount;
                      CombinedMatrix.setValue(iElement,@Element);
                      // remember the max feature key
                      if (Value.iFeatKey > iIn1MaxFeatKey) then
                         iIn1MaxFeatKey := Value.iFeatKey;

                      writeln(InMtxText1,IntToStr(Value.iFeatKey) + ',' + FloatToStr(Value.rAmount));
                 end;
        until Eof(InKey1);
        // load the contents of In2 to the matrix
        // NOTE : we have to make the base FeatKey from In2 be the max FeatKey from In1 + 1
        //        ie. add iIn1MaxFeatKey to each featkey from In2 as it is read from the mtx file
        repeat
              BlockRead(InKey2,Key,SizeOf(Key));

              writeln(InKeyText2,IntToStr(Key.iSiteKey) + ',' + IntToStr(Key.iRichness));

              // add this site key to the master site list
              if (Key.iRichness > 0) then
                 for iCount := 1 to Key.iRichness do
                 begin
                      BlockRead(InMtx2,Value,SizeOf(Value));
                      Inc(iElement);
                      Element.iSiteKey := Key.iSiteKey;
                      Element.iFeatKey := Value.iFeatKey + iIn1MaxFeatKey;
                      Element.rAmount := Value.rAmount;
                      CombinedMatrix.setValue(iElement,@Element);

                      writeln(InMtxText2,IntToStr(Value.iFeatKey) + ',' + FloatToStr(Value.rAmount));
                 end;
        until Eof(InKey2);

        // sort the CombinedMatrix and write it to the 2 output files
        //DumpMatrix2File(CombinedMatrix,MainForm.sWorkingDirectory + '\combined_matrix.csv');
        SortedMatrix := SortJoinedMtxArray(CombinedMatrix);
        //DumpMatrix2File(SortedMatrix,MainForm.sWorkingDirectory + '\sorted_matrix.csv');
        // sort the master site list
        Key.iSiteKey := -1;
        Key.iRichness := 0;
        for iCount := 1 to SortedMatrix.lMaxSize do
        begin
             SortedMatrix.rtnValue(iCount,@Element);
             if (Element.iSiteKey <> Key.iSiteKey) then
             begin
                  // we have encountered another site or the first site
                  // write the previous site to the key file
                  if (Key.iSiteKey <> -1) then
                  begin
                       BlockWrite(OutKey,Key,SizeOf(Key));
                       writeln(OutKeyText,IntToStr(Key.iSiteKey) + ',' + IntToStr(Key.iRichness));
                  end;
                  // initialise the new site
                  Key.iSiteKey := Element.iSiteKey;
                  Key.iRichness := 0;
                  // WE COULD
                  // sort array of feature keys and values and write them all to OutMtx
             end;
             // write this feature area to the mtx file
             Inc(Key.iRichness);
             // we may need to substitute feature keys here
             Value.iFeatKey := Element.iFeatKey;
             Value.rAmount := Element.rAmount;
             BlockWrite(OutMtx,Value,SizeOf(Value));
             writeln(OutMtxText,IntToStr(Value.iFeatKey) + ',' + FloatToStr(Value.rAmount));
             // WE COULD
             // add feature to array of feature keys and values instead of writing it here
        end;
        // write the last site to the key file
        BlockWrite(OutKey,Key,SizeOf(Key));
        writeln(OutKeyText,IntToStr(Key.iSiteKey) + ',' + IntToStr(Key.iRichness));

        // close the 4 input and 2 output files
        closefile(InKey1);
        closefile(InKey2);
        closefile(InMtx1);
        closefile(InMtx2);
        closefile(OutKey);
        closefile(OutMtx);
        closefile(OutKeyText);
        closefile(OutMtxText);
        closefile(InKeyText1);
        closefile(InMtxText1);
        closefile(InKeyText2);
        closefile(InMtxText2);
        // destroy the temporary arrays used
        CombinedMatrix.Destroy;
        SortedMatrix.Destroy;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in JoinMtxFiles',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function TConvertModule.MTX2DBF(const sMtxFile, sMtxColumnNameFile, sDbfFile : string) : boolean;
var
   InMatrix,InKey : File;
   Key : KeyFile_T;
   Value : SingleValueFile_T;
   iSites, iFeatures, iSizeOfKey, iSizeOfValue,
   iCount, iBytesRead : integer;
   sKeyFile, sMatrixName, sExtension, sPath, sFeatureDbfFile, sIndexFile : string;
   fStop, fMtxExists, fKeyExists : boolean;
   AIni : TIniFile;
begin
     // converts a C-Plan MTX format sparse matrix file into a dBase file
     // parameters : sMtxFile             mtx file to convert
     //              sMtxColumnNameFile   feature summary table with names from matrix file, use '' if none
     //              sDbfFile             name of file to create

     // 1289.
     //   280301  See if there is a feature table in the same directory as the mtx file that
     //           matches it.  If there is, a file
     //                           fields ORDER_
     //                                  NEW_NAME
     //                                  OLD_NAME
     //                        else
     //                            fields ORDER_
     //                                   NEW_NAME
     //                        It there is a file & it contains legal dbase names
     //                            don't create a fieldname index table
     //                            just use them as names in the dbase table
     try
        sMatrixName := ExtractFileName(sMtxFile);
        sExtension := ExtractFileExt(sMtxFile);
        sPath := ExtractFileDir(sMtxFile);
        Delete(sMatrixName,Pos(sExtension,sMatrixName),Length(sExtension));

        sKeyFile := sPath + '\' + sMatrixName + '.key';

        assignfile(InMatrix,sMtxFile);
        assignfile(InKey,sKeyFile);
        fStop := False;
        try
           reset(InMatrix,1);
           fMtxExists := True;
        except
              fMtxExists := False;
              fStop := True;
        end;
        try
           reset(InKey,1);
           fKeyExists := True;
        except
              fKeyExists := False;
              fStop := True;
        end;

        if fStop then
        begin
             if fMtxExists
             and (not fKeyExists) then
                 MessageDlg('Mtx file must be accompanied by a Key file which cannot be accessed',mtInformation,[mbOk],0);
             if (not fMtxExists)
             and fKeyExists then
                 MessageDlg('Mtx file cannot be accessed',mtInformation,[mbOk],0);
             if (not fMtxExists)
             and (not fKeyExists) then
                 MessageDlg('Mtx file and accompaning Key file cannot be accessed',mtInformation,[mbOk],0);
        end
        else
        begin
             iSizeOfKey := SizeOf(Key);
             iSizeOfValue := SizeOf(Value);

             // count number of sites by dividing size of InKey file by size of InKey record
             iSites := Round(FileSize(InKey) / iSizeOfKey);
             // count number of features by traversing InMatrix and examining each record
             iFeatures := 0;
             repeat
                   BlockRead(InMatrix,Value,iSizeOfValue,iBytesRead);
                   if (Value.iFeatKey > iFeatures) then
                      iFeatures := Value.iFeatKey;
             until (iBytesRead < iSizeOfValue);
             closefile(InMatrix);
             reset(InMatrix,1);

             // create the new dbf file by executing an SQL query
             with Query1.SQL do
             begin
                  Clear;
                  Add('create table "' + sDbfFile + '"');
                  Add('(');
                  Add('SITEKEY NUMERIC(10,0),');
                  // add each field from the matrix file
                  // make data column fields named from 1 to N
                  for iCount := 1 to iFeatures do
                      if (iCount = iFeatures) then
                         Add('F' + IntToStr(iCount) + ' NUMERIC(10,5)')
                      else
                          Add('F' + IntToStr(iCount) + ' NUMERIC(10,5),');
                  Add(')');

                  try
                     Query1.ExecSQL;
                     Query1.Close;
                  except
                        SaveToFile('c:\error_in_query.sql');
                        Screen.Cursor := crDefault;
                        MessageDlg('Exception in MTX2DBF converting file ' + sMtxFile,mtError,[mbOk],0);
                  end;
             end;

             // parse the input file and write the site keys and data elements to the
             // newly created dBase file
             Table1.DatabaseName := TrimTrailingSlashes(ExtractFilePath(sDbfFile));
             Table1.TableName := ExtractFileName(sDbfFile);
             Table1.Open;
             repeat
                   BlockRead(InKey,Key,iSizeOfKey,iBytesRead);

                   if (iBytesRead = iSizeOfKey) then
                   begin
                        // append a row to the table and write the site key to it
                        Table1.Append;
                        Table1.FieldByName('SITEKEY').AsInteger := Key.iSiteKey;
                        if (iBytesRead = iSizeOfKey) then
                        begin
                             if (Key.iRichness > 0) then
                                for iCount := 1 to Key.iRichness do
                                begin
                                     BlockRead(InMatrix,Value,iSizeOfValue);
                                     Table1.FieldByName('F' + IntToStr(Value.iFeatKey)).AsFloat := Value.rAmount;
                                end;
                        end;
                        Table1.Post;
                   end;

             until  (iBytesRead < iSizeOfKey);

             Table1.Close;

             closefile(InMatrix);
             closefile(InKey);
        end;
        // now create an index table to accompany the site x feature table
        CreateIndexTable(sDbfFile,254);
        // deduce the feature table name and see if it exists
        // cplan.ini
        // [Database1]
        // FeatureSummaryTable
        try
           AIni := TIniFile.Create(TrimTrailingSlashes(ExtractFilePath(sDbfFile)) + '\cplan.ini');
           sFeatureDbfFile := AIni.ReadString('Database1','FeatureSummaryTable','');
           if (sFeatureDbfFile <> '') then
              sFeatureDbfFile := TrimTrailingSlashes(ExtractFilePath(sDbfFile)) + '\' + sFeatureDbfFile;
           if not fileexists(sFeatureDbfFile) then
              sFeatureDbfFile := '';
           AIni.Free;
        except
              sFeatureDbfFile := '';
        end;
        sIndexFile := TrimTrailingSlashes(ExtractFilePath(sDbfFile)) +
                      '\fieldnames_' +
                      ExtractFileName(sDbfFile);
        PopulateMtxIndexTable(sDbfFile{name of site x feature dbf file},
                              sFeatureDbfFile{name of feature file, blank if it is not there},
                              iFeatures);
        // load the index table into the program as a child
        MainForm.CreateMDIChild(sIndexFile,'',False);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in MTX2DBF converting file ' + sMtxFile,mtError,[mbOk],0);
     end;

end;

procedure TrimTrailSpaces(var sLine : string);
var
   iPos : integer;
begin
     iPos := Length(sLine);

     if (Length(sLine) > 1) then
        while (sLine[iPos] = ' ')
        and (iPos > 1) do
            Dec(iPos);

     if (iPos < Length(sLine)) then
        sLine := Copy(sLine,1,iPos);
end;

procedure TrimLeadSpaces(var sLine : string);
var
   iPos : integer;
begin
     iPos := 1;

     if (Length(sLine) > 1) then
        while (sLine[iPos] = ' ') do
              Inc(iPos);

     if (iPos < Length(sLine)) then
        sLine := Copy(sLine,iPos,Length(sLine)-iPos+1);
end;

function CountDelimitersInRow(const sRow, sDelimiter : string) : integer;
var
   iCount : integer;
begin
     Result := 0;
     if (Length(sRow) > 0) then
        for iCount := 1 to Length(sRow) do
            if (sRow[iCount] = sDelimiter) then
               Inc(Result);
end;

function GetDelimitedAsciiElement(const sLine, sDelimiter : string;
                                  const iColumn : integer) : string;
// returns the element at 1-based-index column iColumn
// returns blank string if the column does not exist in sLine
// NOTE : the function needs to return a blank string in the case where 2
//        delimiters occur as adjacent characters in the input line.
//        ie. the case of blank cells in the input file
var
   sTrimLine : string;
   iPos, iTrim, iCount : integer;
begin
     Result := '';

     sTrimLine := sLine;
     iTrim := iColumn-1;
     if (iTrim > 0) then
        for iCount := 1 to iTrim do // trim the required number of columns from the start of the string
        begin
             iPos := Pos(sDelimiter,sTrimLine);
             if (iPos > 0) then
                sTrimLine := Copy(sTrimLine,iPos+1,Length(sTrimLine)-iPos)
             else
                 // there are not enough delimiters in the line,
                 // assume blank cells have been truncated from file
                 sTrimLine := '';
        end;
     iPos := Pos(sDelimiter,sTrimLine);
     if (iPos = 1) then
     begin
          // there is a delimiter at the start of the line we must trim first
          {sTrimLine := Copy(sTrimLine,2,Length(sTrimLine)-1);
          iPos := Pos(sDelimiter,sTrimLine);
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;}
          // WRONG !  What we must actually do is return the blank string
          //          ie. this is a blank cell in the input file
          Result := '';
     end
     else
     begin
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;
     end;
end;


procedure TConvertModule.ScanDelimitedFileFieldTypes(const sDelimitedFile, sDelimiter : string;
                                                     const iCheckType, iCheckCount : integer;
                                                     var TypeInfo : Array_t);
var
   InFile : TextFile;
   sHeaderRow, sRow : string;
   rTest : extended;
   iRow, iTest, iPos, iCount, iFieldCount : integer;
   FieldData : FieldDataType_T;
   fStop : boolean;
   // This procedure retrieves type information from a delimited ascii file so that a DBF file
   // can be created with fields of the correct type to receive all the information from the
   // delimited file.
   // The allowable types are STRING (up to 254 characters, more than this amount of characters will be truncated)
   //                         FLOAT  (use a fixed floating point type)
   //                         INTEGER (determine number of digits needed)
   //
   // There are 3 different levels of type checking that can be done
   // case iCheckType of
   //   1) check all rows in the file
   //   2) check the first iCheckCount rows in the file
   //   3) check 1 in every iCheckCount rows randomly in the file
   procedure InitTypeInformation;
   var
      iCount : integer;
   begin
        iFieldCount := CountDelimitersInRow(sHeaderRow,sDelimiter) + 1;

        FieldData.DBDataType := DBaseInt;
        FieldData.sName := '';
        FieldData.iSize := 0;
        FieldData.iDigit2 := 0;

        TypeInfo := Array_t.Create;
        TypeInfo.init(SizeOf(FieldData),iFieldCount);

        for iCount := 1 to iFieldCount do
            TypeInfo.setValue(iCount,@FieldData);
   end;

   procedure GetFieldNames;
   var
      iCount : integer;
      sTmp : string;
   begin
        // find the field names from this header row
        for iCount := 1 to iFieldCount do
        begin
             FieldData.sName := GetDelimitedAsciiElement(sHeaderRow,sDelimiter,iCount);
             TypeInfo.setValue(iCount,@FieldData);
        end;
   end;

   function UpdateTypeInformation(var FD : FieldDataType_T;
                                  const sCell : string) : boolean;
   begin
        Result := False;

        if (Length(sCell) > FD.iSize) then
        begin
             FD.iSize := Length(sCell);
             Result := True;
        end;

        if (sCell <> '') then
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

   function CheckThisRow(var fStopNow : boolean) : boolean;
   begin
        fStopNow := Eof(InFile); // stop parsing if we have reached end of file

        case iCheckType of
             1 : Result := True;
             2 : if (iRow <= iCheckCount) then
                    Result := True
                 else
                 begin
                      fStopNow := True; // stop parsing the file if we have looked at the specified number of rows
                      Result := False;
                 end;
             3 : Result := (Random(iCheckCount) = 0);
             //   1) check all rows in the file
             //   2) check the first iCheckCount rows in the file
             //   3) check 1 in every iCheckCount rows randomly in the file
        end;

   end;

begin
     try
        assignfile(InFile,sDelimitedFile);
        reset(InFile);

        readln(InFile,sHeaderRow);
        InitTypeInformation;
        GetFieldNames;

        iRow := 0;
        repeat
              Inc(iRow);
              readln(InFile,sRow);

              if CheckThisRow(fStop) then
              begin
                   for iCount := 1 to iFieldCount do
                   begin
                        TypeInfo.rtnValue(iCount,@FieldData);
                        if UpdateTypeInformation(FieldData,GetDelimitedAsciiElement(sRow,sDelimiter,iCount)) then
                           TypeInfo.setValue(iCount,@FieldData);
                   end;
              end;

        until fStop;

        closefile(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TConvertModule.ScanDelimitedFileFieldTypes scanning file ' + sDelimitedFile,
                      mtError,[mbOk],0);
     end;
end;

function rtnDBFFieldDataType(DataType : TFieldType) : FDType_T;
begin
     case DataType of
          ftSmallint,ftInteger,ftWord,ftBoolean : Result := DBaseInt;
          ftFloat : Result := DBaseFloat;
     else
         Result := DBaseStr;
     end;
end;

procedure TConvertModule.ScanDBaseFileFieldTypes(const sDBFFile : string;
                                                 var TypeInfo : Array_t);
var
   InFile : TextFile;
   sHeaderRow, sRow : string;
   rTest : extended;
   iRow, iTest, iPos, iCount, iFieldCount : integer;
   FieldData : FieldDataType_T;
   fStop : boolean;
   // This procedure retrieves type information from an existing DBF file so that a new DBF
   // file can be created with fields of the correct type to receive information from the
   // existing DBF file.
   // The allowable types are STRING (up to 254 characters)
   //                         FLOAT  (use a fixed floating point type)
   //                         INTEGER (determine number of digits needed)

   procedure InitTypeInformation;
   var
      iCount : integer;
   begin
        iFieldCount := Table1.FieldCount;

        FieldData.DBDataType := DBaseInt;
        FieldData.sName := '';
        FieldData.iSize := 0;
        FieldData.iDigit2 := 0;

        TypeInfo := Array_t.Create;
        TypeInfo.init(SizeOf(FieldData),iFieldCount);

        for iCount := 1 to iFieldCount do
            TypeInfo.setValue(iCount,@FieldData);
   end;

   procedure GetFieldInformation;
   var
      iCount : integer;
      sTmp : string;
   begin
        // find the field names from this header row
        for iCount := 0 to (Table1.FieldDefs.Count - 1) do
        begin
             FieldData.DBDataType := rtnDBFFieldDataType(Table1.FieldDefs.Items[iCount].DataType);
             FieldData.sName := Table1.FieldDefs.Items[iCount].Name;
             FieldData.iSize := Table1.FieldDefs.Items[iCount].Size;
             FieldData.iDigit2 := Table1.FieldDefs.Items[iCount].Precision;

             TypeInfo.setValue(iCount+1,@FieldData);
        end;
   end;

begin
     try
        Table1.DatabaseName := TrimTrailingSlashes(ExtractFilePath(sDbfFile));
        Table1.TableName := ExtractFileName(sDbfFile);
        Table1.Open;

        InitTypeInformation;
        GetFieldInformation;

        Table1.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TConvertModule.ScanDBaseFileFieldTypes scanning file ' + sDBFFile,
                      mtError,[mbOk],0);
     end;
end;


procedure TConvertModule.CreateDestinationDbfTable(const sDbfFile : string;
                                                   const TypeInfo : Array_t);
var
   FieldData : FieldDataType_T;
   sTypeSpecification : string;
   iCount : integer;
begin
     try
        with Query1.SQL do
        begin
             Clear;
             Add('create table "' + sDbfFile + '"');
             Add('(');
             for iCount := 1 to TypeInfo.lMaxSize do
             begin
                  TypeInfo.rtnValue(iCount,@FieldData);
                  if (FieldData.iSize < 1) then
                     FieldData.iSize := 1;

                  case FieldData.DBDataType of
                       DBaseFloat : sTypeSpecification := 'NUMERIC(10,5)';
                       DBaseInt : sTypeSpecification := 'NUMERIC(' + IntToStr(FieldData.iSize) + ',0)';
                       DBaseStr : if (FieldData.iSize <= 254) then
                                     sTypeSpecification := 'CHAR(' + IntToStr(FieldData.iSize) + ')'
                                  else
                                      sTypeSpecification := 'CHAR(254)'; // truncate to 254 char string
                  end;

                  if (iCount = TypeInfo.lMaxSize) then
                     Add(FieldData.sName + ' ' + sTypeSpecification)
                  else
                      Add(FieldData.sName + ' ' + sTypeSpecification + ',');
             end;
             Add(')');

             try
                Query1.ExecSQL;
                Query1.Close;
             except
                   SaveToFile('c:\error_in_query.sql');
                   Screen.Cursor := crDefault;
                   MessageDlg('Exception in CreateDestinationTable on file ' + sDbfFile,mtError,[mbOk],0);
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CreateDestinationTable on file ' + sDbfFile,mtError,[mbOk],0);
     end;
end;

function TConvertModule.GetNameSize(const TypeInfo : Array_t) : integer;
var
   iCount : integer;
   FieldData : FieldDataType_T;
begin
     try
        Result := 1;
        for iCount := 1 to TypeInfo.lMaxSize do
        begin
             TypeInfo.rtnValue(iCount,@FieldData);
             if (Length(FieldData.sName) > Result) then
                Result := Length(FieldData.sName);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetNameSize',mtError,[mbOk],0);
     end;
end;


procedure TConvertModule.CreateIndexTable(const sDbfFile : string;
                                          const iNameSize : integer);
var
   sTypeSpecification, sIndexFile : string;
begin
     try
        sIndexFile := TrimTrailingSlashes(ExtractFilePath(sDbfFile)) +
                      '\fieldnames_' +
                      ExtractFileName(sDbfFile);
        if fileexists(sIndexFile) then
           deletefile(sIndexFile);

        with Query1.SQL do
        begin
             Clear;
             Add('create table "' + sIndexFile + '"');
             Add('(');
             Add('ORDER_ NUMERIC(10),');
             Add('NEW_NAME CHAR(10),');
             Add('OLD_NAME CHAR(' + IntToStr(iNameSize) + ')');
             Add(')');

             try
                Query1.ExecSQL;
                Query1.Close;
             except
                   SaveToFile('c:\error_in_query.sql');
                   Screen.Cursor := crDefault;
                   MessageDlg('Exception in CreateDestinationTable on file ' + sDbfFile,mtError,[mbOk],0);
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CreateIndexTable on file ' + sDbfFile,mtError,[mbOk],0);
     end;
end;

procedure TConvertModule.CreateIdxDestinationDbfTable(const sDbfFile : string;
                                                      const TypeInfo : Array_t);
var
   FieldData : FieldDataType_T;
   sTypeSpecification : string;
   iCount : integer;
begin
     try
        with Query1.SQL do
        begin
             Clear;
             Add('create table "' + sDbfFile + '"');
             Add('(');
             for iCount := 1 to TypeInfo.lMaxSize do
             begin
                  // substitute F1...FN for the field names, beginning with the first field
                  TypeInfo.rtnValue(iCount,@FieldData);
                  if (FieldData.iSize < 1) then
                     FieldData.iSize := 1;

                  case FieldData.DBDataType of
                       DBaseFloat : sTypeSpecification := 'NUMERIC(10,5)';
                       DBaseInt : sTypeSpecification := 'NUMERIC(' + IntToStr(FieldData.iSize) + ',0)';
                       DBaseStr : if (FieldData.iSize <= 254) then
                                     sTypeSpecification := 'CHAR(' + IntToStr(FieldData.iSize) + ')'
                                  else
                                      sTypeSpecification := 'CHAR(254)'; // truncate to 254 char string
                  end;

                  if (iCount = TypeInfo.lMaxSize) then
                     Add('F' + IntToStr(iCount) + ' ' + sTypeSpecification)
                  else
                      Add('F' + IntToStr(iCount) + ' ' + sTypeSpecification + ',');
             end;
             Add(')');

             try
                Query1.ExecSQL;
                Query1.Close;
             except
                   SaveToFile('c:\error_in_query.sql');
                   Screen.Cursor := crDefault;
                   MessageDlg('Exception in CreateDestinationTable on file ' + sDbfFile,mtError,[mbOk],0);
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CreateIdxDestinationDbfTable on file ' + sDbfFile,mtError,[mbOk],0);
     end;
end;

function TrimTrailingSlashes(const sLine : string) : string;
var
   sResult : string;
begin
     sResult := sLine;
     repeat
           if (sResult[Length(sResult)] = '\') then
              sResult := Copy(sResult,1,Length(sResult)-1);

     until (sResult[Length(sResult)] <> '\');

     Result := sResult;
end;

procedure TConvertModule.PopulateDbfTable(const sDelimitedFile,sDbfFile,sDelimiter : string;
                                          const TypeInfo : Array_t);
var
   FieldData : FieldDataType_T;
   InFile : TextFile;
   sLine, sValue : string;
   iCount : integer;
begin
     try
        assignfile(InFile,sDelimitedFile);
        reset(InFile);
        readln(InFile);

        Table1.DatabaseName := TrimTrailingSlashes(ExtractFilePath(sDbfFile));
        Table1.TableName := ExtractFileName(sDbfFile);
        Table1.Open;

        repeat
              readln(InFile,sLine);
              Table1.Append;

              for iCount := 1 to TypeInfo.lMaxSize do
              begin
                   TypeInfo.rtnValue(iCount,@FieldData);
                   sValue := GetDelimitedAsciiElement(sLine,sDelimiter,iCount);
                   if (sValue <> '') then
                      Table1.FieldByName(FieldData.sName).AsString := sValue;
              end;

              Table1.Post;

        until Eof(InFile);

        closefile(InFile);

        Table1.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TConvertModule.PopulateDbfTable converting file ' + sDelimitedFile,mtError,[mbOk],0);
     end;
end;

procedure TConvertModule.PopulateIndexTable(const sDbfFile : string;
                                            const TypeInfo : Array_t);
var
   FieldData : FieldDataType_T;
   iCount : integer;
begin
     try
        Table1.DatabaseName := TrimTrailingSlashes(ExtractFilePath(sDbfFile));
        Table1.TableName := 'fieldnames_' + ExtractFileName(sDbfFile);
        Table1.Open;

        // for each field name in the header row, put 1 row into
        // we don't need to open the delimited file, we already have the field names in the TypeInfo array
        for iCount := 1 to TypeInfo.lMaxSize do
        begin
             Table1.Append;

             Table1.FieldByName('ORDER_').AsInteger := iCount;
             Table1.FieldByName('NEW_NAME').AsString := 'F' + IntToStr(iCount);

             TypeInfo.rtnValue(iCount,@FieldData);
             Table1.FieldByName('OLD_NAME').AsString := FieldData.sName;

             Table1.Post;
        end;

        Table1.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TConvertModule.PopulateIndexTable on table ' + sDbfFile,mtError,[mbOk],0);
     end;
end;
procedure TConvertModule.PopulateMtxIndexTable(const sDbfFile, sFeatureDbfFile : string;
                                               const iRowsToCreate : integer);
var
   FieldData : FieldDataType_T;
   iCount : integer;
begin
     try
        if (sFeatureDbfFile = '') then
           // there is no feature table to match the mtx file we are loading
        else
        begin
             // there is a feature table to match the mtx file we are loading,
             // so load the FEATNAME field from it
             Table2.DatabaseName := TrimTrailingSlashes(ExtractFilePath(sFeatureDbfFile));
             Table2.TableName := ExtractFileName(sFeatureDbfFile);
             Table2.Open;
        end;

        Table1.DatabaseName := TrimTrailingSlashes(ExtractFilePath(sDbfFile));
        Table1.TableName := 'fieldnames_' + ExtractFileName(sDbfFile);
        Table1.Open;

        // for each field name in the header row, put 1 row into
        // we don't need to open the delimited file, we already have the field names in the TypeInfo array
        Table1.Append;
        Table1.FieldByName('ORDER_').AsInteger := 1;
        Table1.FieldByName('NEW_NAME').AsString := 'SITEKEY';
        Table1.FieldByName('OLD_NAME').AsString := 'SITEKEY';
        Table1.Post;
        for iCount := 1 to iRowsToCreate do
        begin
             Table1.Append;

             Table1.FieldByName('ORDER_').AsInteger := iCount + 1;
             Table1.FieldByName('NEW_NAME').AsString := 'F' + IntToStr(iCount);

             if (sFeatureDbfFile = '') then
                Table1.FieldByName('OLD_NAME').AsString := IntToStr(iCount)
             else
             begin
                  Table1.FieldByName('OLD_NAME').AsString := Table2.FieldByName('FEATNAME').AsString;
                  Table2.Next;
             end;

             Table1.Post;
        end;

        Table1.Close;

        if (sFeatureDbfFile <> '') then
           Table2.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TConvertModule.PopulateMtxIndexTable on table ' + sDbfFile,mtError,[mbOk],0);
     end;
end;

procedure TConvertModule.PopulateIdxDbfTable(const sDelimitedFile,sDbfFile,sDelimiter : string;
                                             const TypeInfo : Array_t);
var
   FieldData : FieldDataType_T;
   InFile : TextFile;
   sLine, sValue : string;
   iCount : integer;
begin
     try
        assignfile(InFile,sDelimitedFile);
        reset(InFile);
        readln(InFile);

        Table1.DatabaseName := TrimTrailingSlashes(ExtractFilePath(sDbfFile));
        Table1.TableName := ExtractFileName(sDbfFile);
        Table1.Open;

        repeat
              readln(InFile,sLine);
              Table1.Append;

              for iCount := 1 to TypeInfo.lMaxSize do
              begin
                   TypeInfo.rtnValue(iCount,@FieldData);
                   sValue := GetDelimitedAsciiElement(sLine,sDelimiter,iCount);
                   if (sValue <> '') then
                      Table1.FieldByName('F' + IntToStr(iCount)).AsString := sValue;
              end;

              Table1.Post;

        until Eof(InFile);

        closefile(InFile);

        Table1.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TConvertModule.PopulateIdxDbfTable converting file ' + sDelimitedFile,mtError,[mbOk],0);
     end;
end;

function IsLegalChar(const cChar : char) : boolean;
var
   iCount : char;
begin
     // Result is false if char is not legal.
     // Result is true if char is legal.
     Result := False;
     for iCount := 'A' to 'Z' do
         if (cChar = iCount) then
            Result := True;
     for iCount := '0' to '9' do
         if (cChar = iCount) then
            Result := True;
     if (cChar = '_') then
        Result := True;
end;

function ContainsIllegalCharacters(const sField : string) : boolean;
var
   iCount : integer;
begin
     // Result is true if string contains 1 or more illegal characters.
     // Result is false if string contains no illegal characters.

     Result := False;

     for iCount := 1 to Length(sField) do
     begin
          if not IsLegalChar(sField[iCount]) then
             Result := True;
     end;
end;

function IsDBaseFieldNameValid(const sField : string) : boolean;
var
   sTest : string;
begin
     // Determines if the name passed is valid to use as a dBase field name.

     // 1. field is 10 characters or less
     // 2. field starts with a..z
     // 3. field constains only a..z,0..9,_
     //    (and no other characters including space)

     Result := True;
     sTest := UpperCase(sField);

     if (Length(sTest) > 10)
     or (Length(sTest) = 0) then
        // 1. name fails because of length
        Result := False
     else
     begin
          if (sTest[1] < 'A')
          or (sTest[1] > 'Z') then
             // 2. name fails because of starting character
             Result := False
          else
          begin
               // 3. test if field contains illegal characters
               Result := not ContainsIllegalCharacters(sTest);
          end;
     end;
end;

function AreDbfFieldNamesValid(const TypeInfo : Array_t;
                               var fContainsLocalSQLReserveWord : boolean;
                               var sLocalSQLReserveWords : string;
                               var iLocalSQLReserveWords : integer) :  boolean;
var
   iCount : integer;
   FieldData : FieldDataType_T;
begin
     Result := True;
     fContainsLocalSQLReserveWord := False;
     sLocalSQLReserveWords := '';
     for iCount := 1 to TypeInfo.lMaxSize do
     begin
          TypeInfo.rtnValue(iCount,@FieldData);

          // check the number of characters in the field name
          if (Length(FieldData.sName) > 10) then
             Result := False;

          // check it doesn't contain illegal characters
          if Result then
          begin
               Result := IsDBaseFieldNameValid(FieldData.sName);

               // check if field name is a local sql reserve word
               if IsLocalSQLReserveWord(FieldData.sName) then
               begin
                    // add field name to list of local sql reserve words
                    if (sLocalSQLReserveWords = '') then
                       sLocalSQLReserveWords := FieldData.sName
                    else
                        sLocalSQLReserveWords := sLocalSQLReserveWords + ', ' + FieldData.sName;
                    Result := False;
                    fContainsLocalSQLReserveWord := True;
               end;
          end;

          // add the ability for user to rename fields with illegal names
     end;
end;

function TConvertModule.Delimited2DBF(const sDelimitedFile, sDbfFile, sDelimiter : string) : boolean;
var
   TypeInfo : Array_t;
   fContainsLocalSQLReserveWord : boolean;
   sLocalSQLReserveWords, sIndexFile : string;
   iLocalSQLReserveWords : integer;
begin
     try
        Result := False;

        ScanDelimitedFileFieldTypes(sDelimitedFile,sDelimiter,1,0,TypeInfo);

        if AreDbfFieldNamesValid(TypeInfo,fContainsLocalSQLReserveWord,sLocalSQLReserveWords,iLocalSQLReserveWords) then
        begin
             CreateDestinationDbfTable(sDbfFile,TypeInfo);

             PopulateDbfTable(sDelimitedFile,sDbfFile,sDelimiter,TypeInfo);

             TypeInfo.Destroy;

             Result := True;
        end
        else
        begin
             sIndexFile := TrimTrailingSlashes(ExtractFilePath(sDbfFile)) +
                           '\fieldnames_' +
                           ExtractFileName(sDbfFile);

             if fContainsLocalSQLReserveWord then
             begin
                  // the field names contain 1 or more local sql reserve words
                  if (iLocalSQLReserveWords = 1) then
                     MessageDlg('The file ' + ExtractFileName(sDelimitedFile) + ' does not have valid dBase field names,' + Chr(10) + Chr(13) +
                                'so the fields will be renamed and an index file ' + ExtractFileName(sIndexFile) + ' will be created.' + Chr(10) + Chr(13) +
                                '(Reason : The field name "' + sLocalSQLReserveWords + '" is an SQL reserved word.)',
                                mtInformation,[mbOk],0)
                  else
                      MessageDlg('The file ' + ExtractFileName(sDelimitedFile) + ' does not have valid dBase field names,' + Chr(10) + Chr(13) +
                                 'so the fields will be renamed and an index file ' + ExtractFileName(sIndexFile) + ' will be created.' + Chr(10) + Chr(13) +
                                 '(Reason : The field names "' + sLocalSQLReserveWords + '" are SQL reserved words.)',
                                 mtInformation,[mbOk],0);
             end
             else
                 // the field names contain 1 or more illegal characters
                 MessageDlg('The file ' + ExtractFileName(sDelimitedFile) + ' does not have valid dBase field names,' + Chr(10) + Chr(13) +
                            'so the fields will be renamed and an index file ' + ExtractFileName(sIndexFile) + ' will be created.' + Chr(10) + Chr(13) +
                            '(Reason : The field names must have 10 or less characters, begin with a letter of the alphabet, and only contain alphanumeric characters or underscores.)',
                            mtInformation,[mbOk],0);

             // in either of these cases above, we will now create a lookup table
             // called tablename_FieldNames.dbf with fields
             //   ORDER_   (ascending integer from 1..N)
             //   NEW_NAME (F1..FN)
             //   OLD_NAME (original name from delimited file header row as an appropriately length string max 254)
             CreateIndexTable(sDbfFile,GetNameSize(TypeInfo));
             PopulateIndexTable(sDbfFile,TypeInfo);
             CreateIdxDestinationDbfTable(sDbfFile,TypeInfo);
             PopulateIdxDbfTable(sDelimitedFile,sDbfFile,sDelimiter,TypeInfo);
             TypeInfo.Destroy;
             Result := True;

             // load the index table as a child itself
             MainForm.CreateMDIChild(sIndexFile,'',False);
             MainForm.TemporaryFiles.Items.Add(sIndexFile);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TConvertModule.Delimited2DBF converting file ' + sDelimitedFile,mtError,[mbOk],0);
           Result := False;
     end;
end;

procedure TConvertModule.DBF2MTX(const sDbfFile, sMtxFile : string);
begin
     // converts a dBase file into a C-Plan MTX format sparse matrix file
     // parameters : sDbfFile             dbf file to convert
     //              sMtxFile             name of mtx file to create
     //
     // NOTE : The dBase file must have the following :
     //          first field is an integer field
     //          all other fields are integer or floating point fields
     try
        // open tables and init procedure
        Table1.DatabaseName := ExtractFilePath(sDbfFile);
        Table1.TableName := ExtractFileName(sDbfFile);
        Table1.Open;



        // close files and dispose procedure
        Table1.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DBF2MTX converting file ' + sDbfFile,mtError,[mbOk],0);
     end;
end;

procedure TConvertModule.DBF2Delimited(const sDbfFile, sDelimitedFile, sDelimiter : string);
var
   OutputFile : TextFile;
   iRow, iColumn : integer;
begin
     // converts a dBase file into a delimited ascii file
     try
        // open tables and init procedure
        Table1.DatabaseName := ExtractFilePath(sDbfFile);
        Table1.TableName := ExtractFileName(sDbfFile);
        Table1.Open;
        assignfile(OutputFile,sDelimitedFile);
        rewrite(OutputFile);

        // write field names as first row in the delimited ascii file
        for iColumn := 0 to (Table1.FieldCount - 1) do
        begin
             write(OutputFile,Table1.FieldDefs.Items[iColumn].Name);
             if (iColumn < (Table1.FieldCount - 1)) then
                write(OutputFile,sDelimiter);
        end;
        writeln(OutputFile);
        // write table date as other rows
        for iRow := 0 to (Table1.RecordCount - 1) do
        begin
             for iColumn := 0 to (Table1.FieldCount - 1) do
             begin
                  write(OutputFile,Table1.FieldByName(Table1.FieldDefs.Items[iColumn].Name).AsString);
                  if (iColumn < (Table1.FieldCount - 1)) then
                     write(OutputFile,sDelimiter);
             end;
             writeln(OutputFile);
             Table1.Next;
        end;

        // close files and dispose procedure
        Table1.Close;
        closefile(OutputFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DBF2Delimited converting file ' + sDbfFile,mtError,[mbOk],0);
     end;
end;

function IsLocalSQLReserveWord(const sWord : string) : boolean;
begin
     Result := False;
     if (sWord = 'ACTIVE') then
        Result := True;
     if (sWord = 'ADD') then
        Result := True;
     if (sWord = 'ALL') then
        Result := True;
     if (sWord = 'AFTER') then
        Result := True;
     if (sWord = 'ALTER') then
        Result := True;
     if (sWord = 'AND') then
        Result := True;
     if (sWord = 'ANY') then
        Result := True;
     if (sWord = 'AS') then
        Result := True;
     if (sWord = 'ASC') then
        Result := True;
     if (sWord = 'ASCENDING') then
        Result := True;
     if (sWord = 'AT') then
        Result := True;
     if (sWord = 'AUTO') then
        Result := True;
     if (sWord = 'AUTOINC') then
        Result := True;
     if (sWord = 'AVG') then
        Result := True;
     if (sWord = 'BASE_NAME') then
        Result := True;
     if (sWord = 'BEFORE') then
        Result := True;
     if (sWord = 'BEGIN') then
        Result := True;
     if (sWord = 'BETWEEN') then
        Result := True;
     if (sWord = 'BLOB') then
        Result := True;
     if (sWord = 'BOOLEAN') then
        Result := True;
     if (sWord = 'BOTH') then
        Result := True;
     if (sWord = 'BY') then
        Result := True;
     if (sWord = 'BYTES') then
        Result := True;
     if (sWord = 'CACHE') then
        Result := True;
     if (sWord = 'CAST') then
        Result := True;
     if (sWord = 'CHAR') then
        Result := True;
     if (sWord = 'CHARACTER') then
        Result := True;
     if (sWord = 'CHECK') then
        Result := True;
     if (sWord = 'CHECK_POINT_LENGTH') then
        Result := True;
     if (sWord = 'COLLATE') then
        Result := True;
     if (sWord = 'COLUMN') then
        Result := True;
     if (sWord = 'COMMIT') then
        Result := True;
     if (sWord = 'COMMITTED') then
        Result := True;
     if (sWord = 'COMPUTED') then
        Result := True;
     if (sWord = 'CONDITIONAL') then
        Result := True;
     if (sWord = 'CONSTRAINT') then
        Result := True;
     if (sWord = 'CONTAINING') then
        Result := True;
     if (sWord = 'COUNT') then
        Result := True;
     if (sWord = 'CREATE') then
        Result := True;
     if (sWord = 'CSTRING') then
        Result := True;
     if (sWord = 'CURRENT') then
        Result := True;
     if (sWord = 'CURSOR') then
        Result := True;
     if (sWord = 'DATABASE') then
        Result := True;
     if (sWord = 'DATE') then
        Result := True;
     if (sWord = 'DAY') then
        Result := True;
     if (sWord = 'DEBUG') then
        Result := True;
     if (sWord = 'DEC') then
        Result := True;
     if (sWord = 'DECIMAL') then
        Result := True;
     if (sWord = 'DECLARE') then
        Result := True;
     if (sWord = 'DEFAULT') then
        Result := True;
     if (sWord = 'DELETE') then
        Result := True;
     if (sWord = 'DESC') then
        Result := True;
     if (sWord = 'DESCENDING') then
        Result := True;
     if (sWord = 'DISTINCT') then
        Result := True;
     if (sWord = 'DO') then
        Result := True;
     if (sWord = 'DOMAIN') then
        Result := True;
     if (sWord = 'DOUBLE') then
        Result := True;
     if (sWord = 'DROP') then
        Result := True;
     if (sWord = 'ELSE') then
        Result := True;
     if (sWord = 'END') then
        Result := True;
     if (sWord = 'ENTRY_POINT') then
        Result := True;
     if (sWord = 'ESCAPE') then
        Result := True;
     if (sWord = 'EXCEPTION') then
        Result := True;
     if (sWord = 'EXECUTE') then
        Result := True;
     if (sWord = 'EXISTS') then
        Result := True;
     if (sWord = 'EXIT') then
        Result := True;
     if (sWord = 'EXTERNAL') then
        Result := True;
     if (sWord = 'EXTRACT') then
        Result := True;
     if (sWord = 'FILE') then
        Result := True;
     if (sWord = 'FILTER') then
        Result := True;
     if (sWord = 'FLOAT') then
        Result := True;
     if (sWord = 'FOR') then
        Result := True;
     if (sWord = 'FOREIGN') then
        Result := True;
     if (sWord = 'FROM') then
        Result := True;
     if (sWord = 'FULL') then
        Result := True;
     if (sWord = 'FUNCTION') then
        Result := True;
     if (sWord = 'GDSCODE') then
        Result := True;
     if (sWord = 'GENERATOR') then
        Result := True;
     if (sWord = 'GEN_ID') then
        Result := True;
     if (sWord = 'GRANT') then
        Result := True;
     if (sWord = 'GROUP') then
        Result := True;
     if (sWord = 'GROUP_COMMIT_WAIT_TIME') then
        Result := True;
     if (sWord = 'HAVING') then
        Result := True;
     if (sWord = 'HOUR') then
        Result := True;
     if (sWord = 'IF') then
        Result := True;
     if (sWord = 'IN') then
        Result := True;
     if (sWord = 'INT') then
        Result := True;
     if (sWord = 'INACTIVE') then
        Result := True;
     if (sWord = 'INDEX') then
        Result := True;
     if (sWord = 'INNER') then
        Result := True;
     if (sWord = 'INPUT_TYPE') then
        Result := True;
     if (sWord = 'INSERT') then
        Result := True;
     if (sWord = 'INTEGER') then
        Result := True;
     if (sWord = 'INTO') then
        Result := True;
     if (sWord = 'IS') then
        Result := True;
     if (sWord = 'ISOLATION') then
        Result := True;
     if (sWord = 'JOIN') then
        Result := True;
     if (sWord = 'KEY') then
        Result := True;
     if (sWord = 'LONG') then
        Result := True;
     if (sWord = 'LENGTH') then
        Result := True;
     if (sWord = 'LOGFILE') then
        Result := True;
     if (sWord = 'LOWER') then
        Result := True;
     if (sWord = 'LEADING') then
        Result := True;
     if (sWord = 'LEFT') then
        Result := True;
     if (sWord = 'LEVEL') then
        Result := True;
     if (sWord = 'LIKE') then
        Result := True;
     if (sWord = 'LOG_BUFFER_SIZE') then
        Result := True;
     if (sWord = 'MANUAL') then
        Result := True;
     if (sWord = 'MAX') then
        Result := True;
     if (sWord = 'MAXIMUM_SEGMENT') then
        Result := True;
     if (sWord = 'MERGE') then
        Result := True;
     if (sWord = 'MESSAGE') then
        Result := True;
     if (sWord = 'MIN') then
        Result := True;
     if (sWord = 'MINUTE') then
        Result := True;
     if (sWord = 'MODULE_NAME') then
        Result := True;
     if (sWord = 'MONEY') then
        Result := True;
     if (sWord = 'MONTH') then
        Result := True;
     if (sWord = 'NAMES') then
        Result := True;
     if (sWord = 'NATIONAL') then
        Result := True;
     if (sWord = 'NATURAL') then
        Result := True;
     if (sWord = 'NCHAR') then
        Result := True;
     if (sWord = 'NO') then
        Result := True;
     if (sWord = 'NOT') then
        Result := True;
     if (sWord = 'NULL') then
        Result := True;
     if (sWord = 'NUM_LOG_BUFFERS') then
        Result := True;
     if (sWord = 'NUMERIC') then
        Result := True;
     if (sWord = 'OF') then
        Result := True;
     if (sWord = 'ON') then
        Result := True;
     if (sWord = 'ONLY') then
        Result := True;
     if (sWord = 'OPTION') then
        Result := True;
     if (sWord = 'OR') then
        Result := True;
     if (sWord = 'ORDER') then
        Result := True;
     if (sWord = 'OUTER') then
        Result := True;
     if (sWord = 'OUTPUT_TYPE') then
        Result := True;
     if (sWord = 'OVERFLOW') then
        Result := True;
     if (sWord = 'PAGE_SIZE') then
        Result := True;
     if (sWord = 'PAGE') then
        Result := True;
     if (sWord = 'PAGES') then
        Result := True;
     if (sWord = 'PARAMETER') then
        Result := True;
     if (sWord = 'PASSWORD') then
        Result := True;
     if (sWord = 'PLAN') then
        Result := True;
     if (sWord = 'POSITION') then
        Result := True;
     if (sWord = 'POST_EVENT') then
        Result := True;
     if (sWord = 'PRECISION') then
        Result := True;
     if (sWord = 'PROCEDURE') then
        Result := True;
     if (sWord = 'PROTECTED') then
        Result := True;
     if (sWord = 'PRIMARY') then
        Result := True;
     if (sWord = 'PRIVILEGES') then
        Result := True;
     if (sWord = 'RAW_PARTITIONS') then
        Result := True;
     if (sWord = 'RDB$DB_KEY') then
        Result := True;
     if (sWord = 'READ') then
        Result := True;
     if (sWord = 'REAL') then
        Result := True;
     if (sWord = 'RECORD_VERSION') then
        Result := True;
     if (sWord = 'REFERENCES') then
        Result := True;
     if (sWord = 'RESERV') then
        Result := True;
     if (sWord = 'RESERVING') then
        Result := True;
     if (sWord = 'RETAIN') then
        Result := True;
     if (sWord = 'RETURNING_VALUES') then
        Result := True;
     if (sWord = 'RETURNS') then
        Result := True;
     if (sWord = 'REVOKE') then
        Result := True;
     if (sWord = 'RIGHT') then
        Result := True;
     if (sWord = 'ROLLBACK') then
        Result := True;
     if (sWord = 'SECOND') then
        Result := True;
     if (sWord = 'SEGMENT') then
        Result := True;
     if (sWord = 'SELECT') then
        Result := True;
     if (sWord = 'SET') then
        Result := True;
     if (sWord = 'SHARED') then
        Result := True;
     if (sWord = 'SHADOW') then
        Result := True;
     if (sWord = 'SCHEMA') then
        Result := True;
     if (sWord = 'SINGULAR') then
        Result := True;
     if (sWord = 'SIZE') then
        Result := True;
     if (sWord = 'SMALLINT') then
        Result := True;
     if (sWord = 'SNAPSHOT') then
        Result := True;
     if (sWord = 'SOME') then
        Result := True;
     if (sWord = 'SORT') then
        Result := True;
     if (sWord = 'SQLCODE') then
        Result := True;
     if (sWord = 'STABILITY') then
        Result := True;
     if (sWord = 'STARTING') then
        Result := True;
     if (sWord = 'STARTS') then
        Result := True;
     if (sWord = 'STATISTICS') then
        Result := True;
     if (sWord = 'SUB_TYPE') then
        Result := True;
     if (sWord = 'SUBSTRING') then
        Result := True;
     if (sWord = 'SUM') then
        Result := True;
     if (sWord = 'SUSPEND') then
        Result := True;
     if (sWord = 'TABLE') then
        Result := True;
     if (sWord = 'THEN') then
        Result := True;
     if (sWord = 'TIME') then
        Result := True;
     if (sWord = 'TIMESTAMP') then
        Result := True;
     if (sWord = 'TIMEZONE_HOUR') then
        Result := True;
     if (sWord = 'TIMEZONE_MINUTE') then
        Result := True;
     if (sWord = 'TO') then
        Result := True;
     if (sWord = 'TRAILING') then
        Result := True;
     if (sWord = 'TRANSACTION') then
        Result := True;
     if (sWord = 'TRIGGER') then
        Result := True;
     if (sWord = 'TRIM') then
        Result := True;
     if (sWord = 'UNCOMMITTED') then
        Result := True;
     if (sWord = 'UNION') then
        Result := True;
     if (sWord = 'UNIQUE') then
        Result := True;
     if (sWord = 'UPDATE') then
        Result := True;
     if (sWord = 'UPPER') then
        Result := True;
     if (sWord = 'USER') then
        Result := True;
     if (sWord = 'VALUE') then
        Result := True;
     if (sWord = 'VALUES') then
        Result := True;
     if (sWord = 'VARCHAR') then
        Result := True;
     if (sWord = 'VARIABLE') then
        Result := True;
     if (sWord = 'VARYING') then
        Result := True;
     if (sWord = 'VIEW') then
        Result := True;
     if (sWord = 'WAIT') then
        Result := True;
     if (sWord = 'WHEN') then
        Result := True;
     if (sWord = 'WHERE') then
        Result := True;
     if (sWord = 'WHILE') then
        Result := True;
     if (sWord = 'WITH') then
        Result := True;
     if (sWord = 'WORK') then
        Result := True;
     if (sWord = 'WRITE') then
        Result := True;
     if (sWord = 'YEAR') then
        Result := True;
end;

end.
