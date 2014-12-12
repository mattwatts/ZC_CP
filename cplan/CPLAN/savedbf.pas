unit savedbf;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ds, DBTables, Db, grids;

type
  TSaveDBFModule = class(TDataModule)
    SQLQuery: TQuery;
    DBFTable: TTable;
    procedure WriteGridToFile(const sFilename : string;
                              SourceGrid : TStringGrid;
                              DataTypes : Array_T);
    procedure CreateBlankDBFTable(const sFilename : string;
                                  SourceGrid : TStringGrid;
                                  DataTypes : Array_T);
    procedure PostGrid(const sFilename : string;
                       SourceGrid : TStringGrid);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SaveDBFModule: TSaveDBFModule;

implementation

uses
    MAIN, FileCtrl, fldadd,
    global, childwin;

{$R *.DFM}

procedure TSaveDBFModule.WriteGridToFile(const sFilename : string;
                                         SourceGrid : TStringGrid;
                                         DataTypes : Array_T);
begin
     try
        {we must write the contents of a grid to a dBaseIV table}

        {create path if it doesn't exist}
        ForceDirectories(ExtractFilePath(sFilename));

        {delete file if it exists}
        if FileExists(sFilename) then
           DeleteFile(sFilename);

        {create new table with SQL query}
        CreateBlankDBFTable(sFilename,SourceGrid,DataTypes);

        {traverse grid and write its contents to the dbase file}
        PostGrid(sFilename,SourceGrid);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSaveDBFModule.WriteGridToFile',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSaveDBFModule.PostGrid(const sFilename : string;
                                  SourceGrid : TStringGrid);
var
   iRowCount, iColCount : integer;
begin
     {}
     try
        DBFTable.DatabaseName := ExtractFilePath(sFilename);
        DBFTable.TableName := ExtractFileName(sFilename);

        DBFTable.Open;

        for iRowCount := 1 to (SourceGrid.RowCount - 1) do
        begin
             DBFTable.Append;

             for iColCount := 0 to (SourceGrid.ColCount - 1) do
             begin
                  DBFTable.FieldByName(SourceGrid.Cells[iColCount,0]).AsString := SourceGrid.Cells[iColCount,iRowCount];
             end;

             DBFTable.Post;
        end;

        DBFTable.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSaveDBFModule.PostGrid',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSaveDBFModule.CreateBlankDBFTable(const sFilename : string;
                                             SourceGrid : TStringGrid;
                                             DataTypes : Array_T);
var
   FieldAdder : TFieldAdder;
   FieldsToAdd : Array_T;
   FieldType : AddFieldType_T; {C or N}
   FieldSpec : FieldSpec_T;
               {.sName
                .FieldType : AddFieldType_T;
                .iDigit1,
                .iDigit2 : integer;}
   iIndex, iCount : integer;
   ChildContainingField : TMDIChild;
   FieldDataType : FieldDataType_T;

   sFieldName : string;

   function ReadGridStringLength(const iField : integer) : integer;
   var
      iRowCounter, iLength : integer;
   begin
        // grid is source grid
        Result := 0;

        for iRowCounter := 1 to (SourceGrid.RowCount - 1) do
        begin
             iLength := Length(SourceGrid.Cells[iField-1,iRowCounter]);
             if (iLength > Result) then
                Result := iLength;
        end;

        if (Result = 0)
        or (Result > 254) then
           Result := 254;
   end;

begin
     try
        FieldAdder := TFieldAdder.Create(Application);
        FieldsToAdd := Array_T.Create;
        FieldsToAdd.init(SizeOf(FieldSpec),DataTypes.lMaxSize);
        for iCount := 1 to DataTypes.lMaxSize do
        begin
             sFieldName := SourceGrid.Cells[iCount-1,0];

             FieldSpec.sName := sFieldName;
             DataTypes.rtnValue(iCount,@FieldDataType);

             case FieldDataType.DBDataType of
                  DBaseInt : begin
                                  FieldSpec.FieldType := N;
                                  FieldSpec.iDigit1 := 10;
                                  FieldSpec.iDigit2 := 0;
                             end;
                  DBaseFloat : begin
                                  FieldSpec.FieldType := N;
                                  FieldSpec.iDigit1 := 10;
                                  FieldSpec.iDigit2 := 5;
                               end;
                  DBaseStr : begin
                                  FieldSpec.FieldType := C;
                                  if (FieldDataType.iSize = 0) then
                                     // read the string length for this field by traversing the grid
                                     FieldSpec.iDigit1 := ReadGridStringLength(iCount)//254
                                  else
                                      FieldSpec.iDigit1 := FieldDataType.iSize;
                                  FieldSpec.iDigit2 := 0;
                             end;
             end;
             {set FieldType, iDigit1 and iDigit2 for FieldSpec}

             FieldsToAdd.setValue(iCount,@FieldSpec);
        end;

        FieldAdder.NewTable(FieldsToAdd,
                            ExtractFileName(sFilename),
                            ExtractFilePath(sFilename));
        FieldsToAdd.Destroy;
        FieldAdder.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSaveDBFModule.CreateBlankDBFTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

end.
