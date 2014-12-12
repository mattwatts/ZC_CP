unit Childwin;

interface

uses Windows, Classes, Graphics, Forms, Controls, Grids, DBGrids, DBCtrls,
  ExtCtrls, Db, DBTables, ds;

type
  TMDIChild = class(TForm)
    DataSource1: TDataSource;
    Query1: TQuery;
    Panel1: TPanel;
    DBNavigator: TDBNavigator;
    DBGrid1: TDBGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AutoFitTable(const iFitWhat : integer);
    procedure SaveDelimitedFile(const sNewFileName, sDelimiter : string);
    procedure SaveAs(const sNewFileName : string;
                     const fOverwrite : boolean);
    procedure Save;
    procedure CopyDBaseFile(const sNewFileName : string);
    procedure SavePortionOfDBaseFile(const sNewFileName : string);
    procedure SaveDBaseFile(const sNewFileName : string);
    procedure TrimTypeInfoArray(var TypeInfo : Array_t);
    procedure CountFieldSize(var FieldSize : Array_t);
    procedure UpdateTypeInfoSize(var TypeInfo, FieldSize : Array_t);
    procedure PopulateDBFTable(const sNewFileName : string);
  private
    { Private declarations }
  public
    { Public declarations }
    sFilename : string;
    fAllOriginalFieldsUsed : boolean;
  end;

var
   MDIChild : TMDIChild;

implementation

uses
    Dialogs, SysUtils, FMXUtils,
    converter;

{$R *.DFM}

procedure TMDIChild.AutoFitTable(const iFitWhat : integer);
var
   iColumnCount,
   iMaxColumnWidth,
   iCurrentColumnWidth : integer;
begin
     // auto fit the table with user parameters
     try
        iMaxColumnWidth := 0;
        if (iFitWhat = 0) then
        begin
             // auto fit entire table
             // for each column, determine the maximum width by scanning all cells in the column
             for iColumnCount := 0 to (DBGrid1.FieldCount-1) do
             begin
                  iCurrentColumnWidth := Canvas.TextWidth('abc');//AChild.AGrid.Cells[iColumnCount,iRowCount]);
                  if (iCurrentColumnWidth > iMaxColumnWidth) then
                     iMaxColumnWidth := iCurrentColumnWidth;
             end;
        end
        else
        begin
             // auto fit selected rows and columns

        end;
        if (iMaxColumnWidth > 0) then
           ;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TAutoFitForm.AutoFitTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


procedure TMDIChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TMDIChild.SaveDelimitedFile(const sNewFileName, sDelimiter : string);
var
   OutFile : TextFile;
   sLine, sCell : string;
   fEnd : boolean;
   iCount : integer;
begin
     try
        assignfile(OutFile,sNewFileName);
        rewrite(OutFile);
        // traverse the TQuery and write its contents to a file
        DBGrid1.Visible := False;
        Query1.First;

        // write the field names to the header row of the file
        sLine := '';
        for iCount := 0 to (Query1.FieldDefs.Count - 1) do
        begin
             sCell := Query1.FieldDefs.Items[iCount].Name;
             sLine := sLine + sCell;
             if (iCount <> (Query1.FieldDefs.Count - 1)) then
                sLine := sLine + sDelimiter;
        end;
        writeln(OutFile,sLine);

        fEnd := False;
        while (not fEnd) do
        begin
             // write the field values for each row to a file
             sLine := '';
             for iCount := 0 to (Query1.FieldDefs.Count - 1) do
             begin
                  sCell := Query1.FieldByName(Query1.FieldDefs.Items[iCount].Name).AsString;
                  sLine := sLine + sCell;
                  if (iCount <> (Query1.FieldDefs.Count - 1)) then
                     sLine := sLine + sDelimiter;
             end;
             writeln(OutFile,sLine);

             if not fEnd then
             begin
                  Query1.Next;

                  if Query1.EOF then
                     fEnd := True;
             end;
        end;

        Query1.First;
        DBGrid1.Visible := True;
        closefile(OutFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TMDIChild.SaveDelimitedFile on file ' + sFilename,mtError,[mbOk],0);
     end;
end;

procedure TMDIChild.CopyDBaseFile(const sNewFileName : string);
begin
     try
        CopyFile(sFilename,sNewFileName);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TMDIChild.CopyDBaseFile on file ' + sFilename,mtError,[mbOk],0);
     end;
end;

procedure TMDIChild.UpdateTypeInfoSize(var TypeInfo, FieldSize : Array_t);
var
   iCount, iFieldSize : integer;
   FieldData : FieldDataType_T;
begin
     try
        for iCount := 1 to TypeInfo.lMaxSize do
        begin
             FieldSize.rtnValue(iCount,@iFieldSize);
             TypeInfo.rtnValue(iCount,@FieldData);

             FieldData.iSize := iFieldSize;

             TypeInfo.setValue(iCount,@FieldData);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TMDIChild.UpdateTypeInfoSize',mtError,[mbOk],0);
     end;
end;

procedure TMDIChild.PopulateDBFTable(const sNewFileName : string);
var
   iCount : integer;
   sField : string;
begin
     try
        ConvertModule.Table1.DatabaseName := TrimTrailingSlashes(ExtractFilePath(sNewFileName));
        ConvertModule.Table1.TableName := ExtractFileName(sNewFileName);
        ConvertModule.Table1.Open;

        DBGrid1.Visible := False;
        Query1.First;

        repeat
              ConvertModule.Table1.Append;

              for iCount := 1 to Query1.FieldDefs.Count do
              begin
                   ConvertModule.Table1.FieldByName(Query1.FieldDefs.Items[iCount-1].Name).AsString := Query1.FieldByName(Query1.FieldDefs.Items[iCount-1].Name).AsString;
              end;

              ConvertModule.Table1.Post;
              Query1.Next;

        until Query1.EOF;


        Query1.First;
        DBGrid1.Visible := True;

        ConvertModule.Table1.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TMDIChild.SavePortionOfDBaseFile on file ' + sFilename,mtError,[mbOk],0);
     end;
end;

procedure TMDIChild.SavePortionOfDBaseFile(const sNewFileName : string);
var
   TypeInfo, FieldSize : Array_t;
begin
     try
        ConvertModule.ScanDBaseFileFieldTypes(sFilename,
                                              TypeInfo);

        TrimTypeInfoArray(TypeInfo);

        CountFieldSize(FieldSize);

        // use TypeInfo and FieldSize to create a blank dbf using an SQL query
        UpdateTypeInfoSize(TypeInfo,FieldSize);
        ConvertModule.CreateDestinationDbfTable(sNewFileName,TypeInfo);

        // populate the dbf table
        PopulateDBFTable(sNewFileName);

        TypeInfo.Destroy;
        FieldSize.Destroy;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TMDIChild.SavePortionOfDBaseFile on file ' + sFilename,mtError,[mbOk],0);
     end;
end;

procedure TMDIChild.SaveDBaseFile(const sNewFileName : string);
begin
     try
        //if fAllOriginalFieldsUsed then
           // make a copy of the file
           //CopyDBaseFile(sNewFileName)
        //else
            // create an empty dbf table with only the fields used by the user, then populate those fields
            SavePortionOfDBaseFile(sNewFileName);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TMDIChild.SaveDBaseFile on file ' + sFilename,mtError,[mbOk],0);
     end;
end;

function rtnUniqueFilename(const sPath, sExt : string) : string;
var
   iCount, iCharacters : integer;
   sRandomString : string;
begin
     try
        repeat
              iCharacters := Random(6) + 1;
              sRandomString := '';
              for iCount := 1 to iCharacters do
                  sRandomString := sRandomString + Chr(Random(26) + Ord('a'));
              Result := sPath + '\' + sRandomString + sExt;

        until (not FileExists(Result));

     except
     end;
end;


procedure TMDIChild.Save;
var
   sTemporaryFile : string;
begin
     // save to a temporary filename,
     sTemporaryFile := rtnUniqueFilename(TrimTrailingSlashes(ExtractFilePath(sFilename)),'.dbf');
     SaveAs(sTemporaryFile,True);
     // delete old file
     DeleteFile(sFilename);
     // rename new file
     MoveFile(sTemporaryFile,sFilename);
end;

procedure TMDIChild.SaveAs(const sNewFileName : string;
                           const fOverwrite : boolean);
var
   sExtension : string;
   fConfirmOverwrite : boolean;
begin
     try
        // save this dbf table to another file
        // possible file types are dbf (dbase),
        //                         csv (comma delimited) and
        //                         txt (space delimited)
        fConfirmOverwrite := True;

        if not fOverwrite then
           // ask the user if they want to overwrite the file,
           // fOverwrite : TRUE if Save called, FALSE if SaveAs called
           if fileexists(sNewFileName) then
              fConfirmOverwrite := (mrYes = MessageDlg('File ' + sFilename + ' exists.  Overwrite?',mtConfirmation,[mbYes,mbNo],0));

        if fConfirmOverwrite then
        begin
             sExtension := LowerCase(ExtractFileExt(sNewFileName));

             if (sExtension = '.txt') then
                // space delimited
                SaveDelimitedFile(sNewFileName,' ');

             if (sExtension = '.csv') then
                // comma delimited
                SaveDelimitedFile(sNewFileName,',');

             if (sExtension = '.dbf')
             or (sExtension = '.db') then
                // dBase file
                // Make a copy of the dbf file if all fields have been used,
                // otherwise create and populate a table that has the correct
                // subset of fields included.
                SaveDBaseFile(sNewFileName);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TMDIChild.SaveAs',mtError,[mbOk],0);
     end;
end;

procedure TMDIChild.TrimTypeInfoArray(var TypeInfo : Array_t);
var
   iCount, iFields : integer;
   NewTypeInfo : Array_t;
   FieldData : FieldDataType_T;

   function IsFieldLoaded(const sFld : string) : boolean;
   var
      iFld : integer;
   begin
        Result := False;
        for iFld := 0 to (Query1.FieldDefs.Count - 1) do
            if (sFld = Query1.FieldDefs.Items[iFld].Name) then
               Result := True;
   end;

begin
     try
        // remove the fields from the TypeInfo array that user has not loaded into the grid
        iFields := 0;

        NewTypeInfo := Array_t.Create;
        NewTypeInfo.init(SizeOf(FieldData),TypeInfo.lMaxSize);

        for iCount := 1 to TypeInfo.lMaxSize do
        begin
             TypeInfo.rtnValue(iCount,@FieldData);
             if IsFieldLoaded(FieldData.sName) then
             begin
                  Inc(iFields);
                  NewTypeInfo.setValue(iFields,@FieldData);
             end;
        end;

        if (iFields <> TypeInfo.lMaxSize) then
           NewTypeInfo.resize(iFields);

        TypeInfo.Destroy;
        TypeInfo := NewTypeInfo;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TMDIChild.TrimTypeInfoArray',mtError,[mbOk],0);
     end;
end;

procedure TMDIChild.CountFieldSize(var FieldSize : Array_t);
var
   iCount, iFieldSize : integer;
   sField : string;
begin
     try
        DBGrid1.Visible := False;
        Query1.First;
        // init FieldSize
        FieldSize := Array_t.Create;
        FieldSize.init(SizeOf(integer),Query1.FieldDefs.Count);
        iFieldSize := 0;
        for iCount := 1 to Query1.FieldDefs.Count do
            FieldSize.setValue(iCount,@iFieldSize);

        repeat
              for iCount := 1 to Query1.FieldDefs.Count do
              begin
                   FieldSize.rtnValue(iCount,@iFieldSize);

                   sField := Query1.FieldByName(Query1.FieldDefs.Items[iCount-1].Name).AsString;

                   if (Length(sField) > iFieldSize) then
                   begin
                        iFieldSize := Length(sField);
                        FieldSize.setValue(iCount,@iFieldSize);
                   end;
              end;

              Query1.Next;

        until Query1.EOF;

        Query1.First;
        DBGrid1.Visible := True;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TMDIChild.CountFieldSize',mtError,[mbOk],0);
     end;
end;

end.
