unit tparse;

{
 Author : Matthew Watts
 Date : Wed 15 Mar 1998
 Job : class to read/write data from CSV tables and DBF tables
 Purpose : Primarily for use with Table Editor functions for reading/writing data from such
           tables which are linked to by the Table Editor (rather than loaded into a grid)
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Db, DBTables, grids,
  ds;

const
     MAXCSVTMPFILES = 500;

type

    {NOTE : These are the currently supported file types for linking}

    TTableType = (CSV,   {comma delimited ascii file}
                  DBF,   {dBase file}
                  None); {no file}

  TTableParser = class(TForm)
    DBFTable: TTable;
    function initfile(const sFilename : string) : boolean;
    function seekfile(const iRow : integer) : boolean;
    procedure donefile;
    function rtnColumnId(const sFieldName : string) : integer;
    function rtnRowValue(const iColumn : integer) : string;
    function CurrentTableType : TTableType;
    function rtnFieldFromString(const sString : string;
                                const iColumnToReturn : integer) : string;
    function rtnTableType : TTableType;

    {methods needed for reading/writing new columns in CSV/DBF tables}
    function initTmpFiles(const sTemporaryDirectory : string;
                          const iTemporaryFilesToCreate : integer) : boolean;
    procedure doneTmpFiles;
    {method for writing to CSV and DBF tables}
    function SetCellValue(const sValueToSet, sFieldName : string;
                          const iColumnToSet, iRowToSet : integer) : boolean;
    procedure FlushCSVColumn(const iColumnToFlush : integer); {write a blank link to one of the temporary CSV files
                                                               (meaning, there is no value for this cell)}
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure ReadRowValues;
    procedure DebugDumpRow;

  private
    { Private declarations }
    TableType : TTableType;
    CSVTable : Text;
    iCurrentRow, iCSVSeekCount, iCSVRewindCount, iCSVColumnCount : integer;
	sCurrentCSVRow, sTableFilename, sCSVFieldRow : string;

    TempFiles : array [1..MAXCSVTMPFILES] of TextFile;
    iTempFileCount, iPreviousColumn, iPreviousPosition : integer;
    sTempFileDirectory : string;

	fRowValuesCreated : boolean;
    RowValues : Array_t;
  public
    { Public declarations }
    fOptimiseColumnAccess : boolean;
  end;

var
  TableParser: TTableParser;

implementation

uses
    global,
    itools, {for procedure CountColumnsInCSVFile so we can set iCSVColumnCount}
    FileCtrl;


{$R *.DFM}

procedure TTableParser.FlushCSVColumn(const iColumnToFlush : integer);
var
   iCount : integer;
begin
     if (TableType = CSV) then
     try
        {write a blank link to one of the temporary CSV files
         (meaning, there is no value for this cell)}
        writeln(TempFiles[iColumnToFlush]);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TTableParser.FlushCSVRow',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


function TTableParser.rtnTableType : TTableType;
begin
     Result := TableType;
end;

function TTableParser.initTmpFiles(const sTemporaryDirectory : string;
                                   const iTemporaryFilesToCreate : integer) : boolean;
var
   iCount : integer;
   sTemporaryFile : string;
begin
     try
        Result := True;

        case TableType of
             CSV : begin
                        iTempFileCount := iTemporaryFilesToCreate;
                        sTempFileDirectory := sTemporaryDirectory;
                        {create the temporary files in the temporary directory}
                        if ((iTemporaryFilesToCreate) <= MAXCSVTMPFILES) then
                           for iCount := 1 to iTemporaryFilesToCreate do
                           begin
                                sTemporaryFile := sTemporaryDirectory + '~tmp' + IntToStr(iCount-1) + '.txt';
                                assignfile(TempFiles[iCount],sTemporaryFile);
                                rewrite(TempFiles[iCount]);
                           end
                        else
                        begin
                             Screen.Cursor := crDefault;
                             MessageDlg('C-Plan can only join up to ' + IntToStr(MAXCSVTMPFILES) +
                                        ' columns into a table',mtError,[mbOk],0);
                             Result := False;
                        end;
                   end;
             DBF : begin
                        {}
                   end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TTableParser.initTmpCSVFiles',
                      mtError,[mbOk],0);
     end;
end;

procedure TTableParser.doneTmpFiles;
var
   iCount : integer;
   DestinationFile : TextFile;
   sDestinationFile, sOriginal, sLine : string;

   function rtnTempFileName(const sPath : string) : string;
   var
      iInc : integer;
   begin
        iInc := 0;

        repeat
              Result := sPath + '~~' + IntToStr(iInc) + '.txt';

              Inc(iInc);

        until not FileExists(Result);
   end;

begin
     try
        case TableType of
             CSV : begin
                        {stitch the temporary files back together and delete them}
                        for iCount := 1 to iTempFileCount do
                        begin
                             CloseFile(TempFiles[iCount]);
                             reset(TempFiles[iCount]);
                        end;

                        {create temporary destination table}
                        sDestinationFile := rtnTempFileName(sTempFileDirectory);
                        assignfile(DestinationFile,sDestinationFile);
                        rewrite(DestinationFile);

                        closefile(CSVTable);
                        reset(CSVTable);

                        repeat
                              readln(CSVTable,sOriginal);
                              write(DestinationFile,sOriginal + ',');

                              for iCount := 1 to iTempFileCount do
                              begin
                                   readln(TempFiles[iCount],sLine);
                                   if (iCount <> iTempFileCount) then
                                      write(DestinationFile,sLine + ',')
                                   else
                                       writeln(DestinationFile,sLine);
                              end;

                        until EOF(CSVTable);

                        closefile(CSVTable);
                        closefile(DestinationFile);


                        {DeleteFile(sTableFilename);} {delete old table}
                        CopyFile(PChar(sDestinationFile),
                                 PChar(sTableFilename),
                                 False {fail if exists, ie. overwrite if exists, which it does}
                                 ); {copy DestinationFile to CSVTable and re-init it}
                        initfile(sTableFilename);

                        {delete temporary destination file}
                        DeleteFile(sDestinationFile);

                        {delete the temporary file(s)}
                        for iCount := 1 to iTempFileCount do
                        begin
                             closefile(TempFiles[iCount]);
                             sDestinationFile := sTempFileDirectory + '~tmp' + IntToStr(iCount-1) + '.txt';
                             DeleteFile(sDestinationFile);
                        end;
                   end;
             DBF : begin

                   end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TTableParser.doneTmpCSVFiles',
                      mtError,[mbOk],0);
     end;
end;

function TTableParser.SetCellValue(const sValueToSet, sFieldName : string;
                                   const iColumnToSet, iRowToSet : integer) : boolean;
begin
     try
        case TableType of
             CSV : writeln(TempFiles[iColumnToSet],sValueToSet);
             DBF : DBFTable.FieldByName(sFieldName).AsString := sValueToSet;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TTableParser.SetCellValue value' + sValueToSet +
                      ' field ' + sFieldName +
                      ' column ' + IntToStr(iColumnToSet) +
                      ' row ' + IntToStr(iRowToSet),
                      mtError,[mbOk],0);
     end;
end;

function TTableParser.initfile(const sFilename : string) : boolean;
begin
     if FileExists(sFilename) then
     try
        iPreviousColumn := -1; {indicate that no column value has been returned}
        iPreviousPosition := 0;

        {determine type of sFilename and set File Type read only internal variable}
        TableType := CSV;
        if (Length(sFilename) > 4) then
           if (UpperCase(Copy(sFilename,Length(sFilename)-2,3))='DBF') then
              TableType := DBF;
        {assume file is Comma Delimited Ascii (CSV) if its extension is not DBF}

        {open the file ready for reading on the first row}
        case TableType of
             DBF : begin
                        DBFTable.DatabaseName := ExtractFilePath(sFilename);
                        DBFTable.TableName := ExtractFileName(sFilename);
                        DBFTable.Open;
                   end;
             CSV : begin
                        {set the column count}
                        CountColumnsInCSVFile(sFilename,iCSVColumnCount);

                        assignfile(CSVTable,sFilename);
                        reset(CSVTable);

                        {read the first line from the CSV file}
                        readln(CSVTable,sCurrentCSVRow);
                        sCSVFieldRow := sCurrentCSVRow;
                   end;
        end;

        iCurrentRow := 0;
        iCSVRewindCount := 0;

        sTableFilename := sFilename;

        Result := True;

     except
           MessageDlg('Exception in TParseTable.initfile opening file ' + sFilename,
                      mtError,[mbOk],0);
           Result := False;
     end
     else
     begin
          {file does not exist}
          Result := False;
          TableType := None;
     end;

end; {end of TTableParser.initfile}


function TTableParser.seekfile(const iRow : integer) : boolean;
begin
     {seek to row iRow:
                      (iRow is 0 referenced for CSV and 1 referenced for DBF,
                        0 is the field names (assuming first line of CSV files is field names)
                        1..(Rows-1) contain the data elements

      if RowCount exceeded
         Result is false (ie. last row has previously been read)
      else
          Result is true}

     Result := False;

     try
        iPreviousColumn := -1; {indicate that no column value has been returned}

        case TableType of
             DBF :
             begin
                  {check if row count is exceeded}
                  if (iRow <= DBFTable.RecordCount) then
                  begin

                       if (iRow > 0) then
                       begin
                            if (iRow <> DBFTable.RecNo) then
                               DBFTable.MoveBy(iRow - DBFTable.RecNo);

                       end;

                       Result := True;
                  end;
             end;
             CSV :
             begin
                  if not EOF(CSVTable) then
                     Result := True;

                  if (iRow = iCurrentRow) then
                     {we already have the correct line in the buffer, do nothing}
                  else
                  begin {we need to seek to the correct line and read it into the buffer}

                       Inc(iCSVSeekCount);

                       if (iRow < iCurrentRow)
                       or EOF(CSVTable) then
                       begin
                            Inc(iCSVRewindCount);

                            {we have to rewind the file}
                            CloseFile(CSVTable);
                            reset(CSVTable);
                            iCurrentRow := 0;
                            ReadLn(CSVTable,sCurrentCSVRow);
                            {now seek until we get to iSeekRow}
                       end;

                       {we have to move forward until we get to iSeekRow}
                       if (iRow > 0) then
                       repeat
                             ReadLn(CSVTable,sCurrentCSVRow);
                             Inc(iCurrentRow);

                       until (iCurrentRow >= iRow);

                       if fOptimiseColumnAccess then
                          // read the contents of the row into RowValues
                          ReadRowValues;
                  end;
             end;

        end; {of case statement}

     except
           MessageDlg('Exception in TTableParser.seekfile file ' + sTableFilename,
                      mtError,[mbOk],0);
     end;

end; {of TTableParser.seekfile}

function TTableParser.rtnFieldFromString(const sString : string;
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

        iPreviousColumn := iColumnToReturn; {indicate that no column value has been returned}

     except
           Result := '0';
           iPreviousColumn := -1;
           iPreviousPosition := 0;
           //MessageDlg('Exception in TTableParser.rtnFieldFromString',mtError,[mbOk],0);
     end;
end;

function TTableParser.rtnColumnId(const sFieldName : string) : integer;
var
   iCount : integer;
begin
     {returns column index of field sFieldName

      result is 0 referenced, ie. columns go from 0 to (Columns - 1)

      result of -1 means field not found or table not open}
     try
        Result := -1;

        case TableType of
             DBF : begin
                        {iterate through fields in the dbf file looking for sFieldName}
                        for iCount := 0 to (DBFTable.FieldCount - 1) do
                            if (DBFTable.Fields[iCount].FieldName = sFieldName) then
                               Result := iCount;
                   end;
             CSV : begin
                        {sCSVFieldRow contains first line of csv file}
                        for iCount := 0 to iCSVColumnCount do
                        begin
                             if (rtnFieldFromString(sCSVFieldRow,iCount) = sFieldName) then
                                Result := iCount;
                        end;
                   end;
        end;

     except
           MessageDlg('Exception in TTableParser.rtnColumnId',mtError,[mbOk],0);
     end;
end;

function TTableParser.rtnRowValue(const iColumn : integer) : string;
var
   sCell : str255;
begin
     {return the string value of column iColumn from the current row
                      iColumn is 0 referenced
                      ie. columns go from 0..(Columns-1)}
     try
        Result := '';

        case TableType of
             DBF : Result := DBFTable.Fields[iColumn].AsString;
             CSV : if fOptimiseColumnAccess then
                   begin
                        // we have these values stored in an array, return the element from the array
                        RowValues.rtnValue(iColumn+1,@sCell);
                        Result := sCell;
                   end
                   else
                       Result := rtnFieldFromString(sCurrentCSVRow,iColumn);
        end;

     except
           MessageDlg('Exception in TTableParser.rtnRowValue',mtError,[mbOk],0);
     end;
end;

function TTableParser.CurrentTableType : TTableType;
begin
     {returns the ordinal datatype of the table (returns None if table not inited,
      or init called for table that could not be opened}

     Result := TableType;
end;

procedure TTableParser.FormCreate(Sender: TObject);
begin
     {NOTE : the FormCreate would be substituted for a class creation method called
             prior to initfile}

     TableType := None; {set default value for TableType}

     //fOptimiseColumnAccess := False;
     fOptimiseColumnAccess := True;
end;

procedure TTableParser.donefile;
begin
     {we must close the table file if we have one open}
     case TableType of
          DBF : DBFTable.Close;
          CSV : CloseFile(CSVTable);
     end;
     TableType := None;
end;

procedure TTableParser.FormDestroy(Sender: TObject);
begin
     if fRowValuesCreated then
        RowValues.Destroy;
end;

procedure TTableParser.DebugDumpRow;
var
   DebugFile : TextFile;
   iCount : integer;
   sCell : str255;
begin
     //

     ForceDirectories('c:\rowdump');

     assignfile(DebugFile,'c:\rowdump\' + IntToStr(iCurrentRow) + '.txt');
     rewrite(DebugFile);

     writeln(DebugFile,'BEGIN');

     if (RowValues.lMaxSize > 0) then
        for iCount := 1 to RowValues.lMaxSize do
        begin
             RowValues.rtnValue(iCount,@sCell);
             writeln(DebugFile,sCell);
        end;

     writeln(DebugFile,'END');

     closefile(DebugFile);
end;

procedure TTableParser.ReadRowValues;
var
   fEnd : boolean;
   iPosition,
   iCount, iRowValuesCount, iColumn : integer;
   sTmp : string;
   sCell : str255;
begin
     try
        if not fRowValuesCreated then
        begin		
             RowValues := Array_t.Create;
             RowValues.init(SizeOf(str255),ARR_STEP_SIZE);
		end;
        fRowValuesCreated := True;
        iRowValuesCount := 0;
        iColumn := 0;
        sTmp := sCurrentCSVRow;
        fEnd := False;

        if (sTmp <> '') then
        repeat
              if (sTmp[1] = '"') then
              begin
                   // this cell delimited by "
                   iPosition := Pos('"',sTmp);
                   Inc(iPosition);
              end
              else
                  // this cell delimited by ,
                  iPosition := Pos(',',sTmp);

              if (iPosition < Length(sTmp))
              and (iPosition > 0) then
              begin
                   if (iPosition = 1) then
                   begin
                        //if (Length(sTmp) > 1) then
                        //   sTmp := Copy(sTmp,2,Length(sTmp))
                        //else
                        //    sTmp := '';
                        sCell := '';

                   end
                   else
                   begin
                        sCell := Copy(sTmp,1,iPosition-1);
                        //if (sTmp
                   end;
              end
              else
                  sCell := sTmp;

              // REMOVE trailing comma if it exists
              if (Length(sCell) > 0) then
                 if (sCell[Length(sCell)] = ',') then
                    sCell := Copy(sCell,1,Length(sCell)-1);

              Inc(iColumn);
              if (iColumn > RowValues.lMaxSize) then
                 RowValues.resize(RowValues.lMaxSize + ARR_STEP_SIZE);
              RowValues.setValue(iColumn,@sCell);

              //end;

              // set sTmp to be the rest of the line - this cell
              if ((iPosition+1) <= Length(sTmp))
              and (iPosition > 0) then
                  sTmp := Copy(sTmp,iPosition+1,Length(sTmp)-iPosition)
              else
                  sTmp := '';

        until (sTmp = '');

        // adjust the size of the array we have just created
        if (iColumn = 0) then
        begin
             RowValues.resize(1);
             RowValues.lMaxSize := 0;
        end
        else
        begin
             if (iColumn <> RowValues.lMaxSize) then
                RowValues.resize(iColumn);
        end;

        // dump the array we have just created to an ascii file with the name of this row
        // DebugDumpRow;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TTableParser.ReadRowValues',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

end.
