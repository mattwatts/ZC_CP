unit sql_tool;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Menus, Db, DBTables,
  childwin;

type
  TSQLToolForm = class(TForm)
    Panel1: TPanel;
    SQLMemo: TMemo;
    btnCancel: TBitBtn;
    btnLoad: TButton;
    btnSave: TButton;
    MainMenu1: TMainMenu;
    OpenMinsetFile: TOpenDialog;
    SaveMinsetFile: TSaveDialog;
    Template1: TMenuItem;
    Add1: TMenuItem;
    DropFields1: TMenuItem;
    SelectData1: TMenuItem;
    CreateTable1: TMenuItem;
    SQLQuery: TQuery;
    btnExecute: TButton;
    OpenDBFTable: TOpenDialog;
    btnLocateTbl: TButton;
    Label1: TLabel;
    lblActiveTable: TLabel;
    CheckSaveToFile: TCheckBox;
    procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure Add1Click(Sender: TObject);
    procedure DropFields1Click(Sender: TObject);
    procedure SelectData1Click(Sender: TObject);
    procedure CreateTable1Click(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
    procedure rtnDBFDataTypes(Child : TMDIChild);
    procedure btnLocateTblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SQLToolForm: TSQLToolForm;

implementation

uses
    main, global, ds;

{$R *.DFM}

procedure TSQLToolForm.btnLoadClick(Sender: TObject);
begin
     //OpenMinsetFile.InitialDir
     //OpenMinsetFile.FileName
     if OpenMinsetFile.Execute then
     begin
          SQLMemo.Lines.Clear;
          SQLMemo.Lines.LoadFromFile(OpenMinsetFile.FileName);
     end;
end;

procedure TSQLToolForm.btnSaveClick(Sender: TObject);
begin
     if SaveMinsetFile.Execute then
     begin
          SQLMemo.Lines.SaveToFile(SaveMinsetFile.FileName);
     end;
end;

procedure TSQLToolForm.Add1Click(Sender: TObject);
var
   sTbl : string;
begin
     if ('None' = lblActiveTable.Caption) then
        sTbl := 'c:\test.dbf'
     else
         sTbl := lblActiveTable.Caption;
     SQLMemo.Lines.Clear;
     SQLMemo.Lines.Add('alter table "' + sTbl + '"');
     SQLMemo.Lines.Add('  add field5 NUMERIC(10,5),');
     SQLMemo.Lines.Add('  add field6 CHAR(5)');
end;

procedure TSQLToolForm.DropFields1Click(Sender: TObject);
var
   sTbl : string;
begin
     if ('None' = lblActiveTable.Caption) then
        sTbl := 'c:\test.dbf'
     else
         sTbl := lblActiveTable.Caption;
     SQLMemo.Lines.Clear;
     SQLMemo.Lines.Add('alter table "' + sTbl + '"');
     SQLMemo.Lines.Add('  drop field1,');
     SQLMemo.Lines.Add('  drop field2');
end;

procedure TSQLToolForm.SelectData1Click(Sender: TObject);
var
   sTbl : string;
begin
     if ('None' = lblActiveTable.Caption) then
        sTbl := 'c:\test.dbf'
     else
         sTbl := lblActiveTable.Caption;
     SQLMemo.Lines.Clear;
     SQLMemo.Lines.Add('select field1 from "' + sTbl + '" where');
     SQLMemo.Lines.Add('  (field2 = "xyz")');
     SQLMemo.Lines.Add(' AND');
     SQLMemo.Lines.Add('  (field1 = 2.1)');
end;

procedure TSQLToolForm.CreateTable1Click(Sender: TObject);
begin
     SQLMemo.Lines.Clear;
     SQLMemo.Lines.Add('create table "c:\test.dbf"');
     SQLMemo.Lines.Add('(');
     SQLMemo.Lines.Add('  field1 NUMERIC(10,5),');
     SQLMemo.Lines.Add('  field2 CHAR(10),');
     SQLMemo.Lines.Add('  field3 NUMERIC(10,5),');
     SQLMemo.Lines.Add('  field4 CHAR(5)');
     SQLMemo.Lines.Add(')');
end;

procedure TSQLToolForm.rtnDBFDataTypes(Child : TMDIChild);
var
   iCount : integer;
   AFDType : FDType_T;
   AType : FieldDataType_T;
begin
     {store the data field types for the dbf table in .DataFieldTypes}
     with Child do
     try
        DataFieldTypes := Array_T.Create;
        DataFieldTypes.init(SizeOf(FieldDataType_T),SQLQuery.FieldDefs.Count);
        for iCount := 1 to DataFieldTypes.lMaxSize do
        begin
             AFDType := rtnDataType(SQLQuery.FieldDefs.Items[iCount-1].DataType,
                                    SQLQuery.FieldDefs.Items[iCount-1].Precision);

             AType.DBDataType := AFDType;

             {if the field is a string, this is the length of the string}
             AType.iSize := SQLQuery.FieldDefs.Items[iCount-1].Size;

             DataFieldTypes.setValue(iCount,@AType);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in rtnDBFDataTypes',mtError,[mbOk],0);
     end;
end;


procedure TSQLToolForm.btnExecuteClick(Sender: TObject);
var
   ResultChild : TMDIChild;
   iRowCount, iColumnCount : integer;
   sResultTable, sLine : string;
   OutputFile : TextFile;

   function rtnResultTableName : string;
   var
      iResult, iCount : integer;
   begin
        iCount := 1;
        repeat
              Result := 'SQL Result ' + IntToStr(iCount);
              iResult := SCPForm.rtnTableId(Result);
              Inc(iCount);

        until (iResult = -1);
   end;
begin
     SQLQuery.SQL.Clear;
     SQLQuery.SQL := SQLMemo.Lines;

     try
        Screen.Cursor := crHourglass;
        SQLQuery.Prepare;
        SQLQuery.ExecSQL;

        try
           // write the result to a new blank child if necessary
           SQLQuery.Open;

           // create result table with required dimensions
           if CheckSaveToFile.Checked then
           begin
                assignfile(OutputFile,'c:\result.csv');
                rewrite(OutputFile);
                //writeln(OutputFile,'');
                sLine := '';
                // write field names to first row
                for iColumnCount := 0 to (SQLQuery.FieldCount-1) do
                begin
                     sLine := sLine + SQLQuery.FieldDefs.Items[iColumnCount].Name;
                     if (iColumnCount <> SQLQuery.FieldCount-1) then
                        sLine := sLine + ',';
                end;
                writeln(OutputFile,sLine);

                // populate file with rows from the query
                for iRowCount := 1 to SQLQuery.RecordCount do
                begin
                     sLine := '';                                        
                     for iColumnCount := 0 to (SQLQuery.FieldCount-1) do
                     begin
                          sLine := sLine + SQLQuery.FieldByName(SQLQuery.FieldDefs.Items[iColumnCount].Name).AsString;
                          if (iColumnCount <> SQLQuery.FieldCount-1) then
                             sLine := sLine + ',';
                     end;
                     writeln(OutputFile,sLine);
                     SQLQuery.Next;
                end;

                closefile(OutputFile);
           end
           else
           begin
                ResultChild := TMDIChild.Create(Application);
                sResultTable := rtnResultTableName;
                ResultChild.Caption := sResultTable;
                ResultChild.aGrid.ColCount := SQLQuery.FieldCount;
                ResultChild.aGrid.RowCount := SQLQuery.RecordCount + 1;
                ResultChild.CheckLoadFileData.Checked := True;
                ResultChild.KeyFieldGroup.Items.Clear;
                ResultChild.KeyCombo.Items.Clear;
                ResultChild.lblDimensions.Caption := 'Rows : ' +
                                                     IntToStr(ResultChild.aGrid.RowCount) +
                                                     ' Columns: ' +
                                                     IntToStr(ResultChild.aGrid.ColCount);
                if (ResultChild.aGrid.RowCount > 1) then
                   ResultChild.aGrid.FixedRows := 1
                else
                    ResultChild.CheckLockFirstRow.Checked := False;

                // write field names to first columns
                for iColumnCount := 0 to (SQLQuery.FieldCount-1) do
                begin
                     ResultChild.KeyFieldGroup.Items.Add(SQLQuery.FieldDefs.Items[iColumnCount].Name);
                     ResultChild.KeyCombo.Items.Add(SQLQuery.FieldDefs.Items[iColumnCount].Name);

                     ResultChild.aGrid.Cells[iColumnCount,0] := SQLQuery.FieldDefs.Items[iColumnCount].Name;
                end;

                // populate grid with rows from the query
                for iRowCount := 1 to SQLQuery.RecordCount do
                begin
                     for iColumnCount := 0 to (SQLQuery.FieldCount-1) do
                         ResultChild.aGrid.Cells[iColumnCount,iRowCount] := SQLQuery.FieldByName(SQLQuery.FieldDefs.Items[iColumnCount].Name).AsString;

                     SQLQuery.Next;
                end;

                // update key field information for the child
                ResultChild.KeyFieldGroup.ItemIndex := 0;
                ResultChild.KeyCombo.Text := ResultChild.KeyCombo.Items.Strings[0];

                // update type information for the child
                rtnDBFDataTypes(ResultChild);
           end;

           SQLQuery.Close;
           Screen.Cursor := crDefault;

           MessageDlg('Query executed successfully.  Selection was written to ' + sResultTable,
                      mtInformation,[mbOk],0);

        except
              // there was no result set for this query
              Screen.Cursor := crDefault;
              MessageDlg('Query executed successfully',
                         mtInformation,[mbOk],0);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception executing query.  Please check syntax and try again.',
                      mtInformation,[mbOk],0);
     end;
end;

procedure TSQLToolForm.btnLocateTblClick(Sender: TObject);
begin
     if OpenDBFTable.Execute then
        lblActiveTable.Caption := OpenDBFTable.Filename;
end;

end.
