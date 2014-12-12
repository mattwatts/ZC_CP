unit DBF_Child;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, Grids, DBGrids, DBCtrls, ExtCtrls, StdCtrls;

type
  TDBFChild = class(TForm)
    Panel1: TPanel;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    Query1: TQuery;
    lblDimensions: TLabel;
    Query2: TQuery;
    Table1: TTable;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SaveDBFChild2DBF(const sFilename : string);
    procedure SaveZSTATSDBFChild2DBF(const sFilename, sFieldname : string);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DBFChild: TDBFChild;

implementation

uses SCP_Main;

{$R *.DFM}

procedure TDBFChild.SaveDBFChild2DBF(const sFilename : string);
var
   iFieldCount, iRecordCount : integer;
   sFieldDefinition : string;
begin
     // create blank dbf table with appropriate fields
     if fileexists(sFilename) then
        deletefile(sFilename);
     with Query2 do
     begin
          SQL.Clear;
          SQL.Add('create table "' + sFilename + '"');
          SQL.Add('(');

          for iFieldCount := 0 to (Query1.Fields.Count-1) do
          begin
               sFieldDefinition := ' table.' + Query1.Fields.Fields[iFieldCount].FieldName + ' ';
               case Query1.Fields.Fields[iFieldCount].DataType of
                    ftString : sFieldDefinition := sFieldDefinition + 'CHAR(' + IntToStr(Query1.Fields.Fields[iFieldCount].Size) + ')';
                    ftInteger : sFieldDefinition := sFieldDefinition + 'NUMERIC(10,0)';
                    ftFloat : sFieldDefinition := sFieldDefinition + 'NUMERIC(10,5)';
               end;

               if (iFieldCount < (Query1.Fields.Count-1)) then
                  sFieldDefinition := sFieldDefinition + ',';

               SQL.Add(sFieldDefinition);
          end;

          SQL.Add(')');
          //SQL.SaveToFile('c:\create.sql');

          Prepare;
          ExecSQL;
     end;
     // write records to the dbf table
     Table1.DatabaseName := ExtractFilePath(sFilename);
     Table1.TableName := ExtractFileName(sFilename);
     Table1.Open;
     Table1.Edit;
     Query1.First;
     for iRecordCount := 0 to Query1.RecordCount do
     //while Query1.RecNo < Query1.RecordCount do
     begin
          Table1.Append;

          for iFieldCount := 0 to (Query1.Fields.Count-1) do
              case Query1.Fields.Fields[iFieldCount].DataType of
                   ftString : Table1.Fields.Fields[iFieldCount].AsString := Query1.Fields.Fields[iFieldCount].AsString;
                   ftInteger : Table1.Fields.Fields[iFieldCount].AsInteger := Query1.Fields.Fields[iFieldCount].AsInteger;
                   ftFloat : Table1.Fields.Fields[iFieldCount].AsFloat := Query1.Fields.Fields[iFieldCount].AsFloat;
              end;
                                                  
          Query1.Next;
     end;

     Table1.Close;
end;

procedure TDBFChild.SaveZSTATSDBFChild2DBF(const sFilename, sFieldname : string);
var
   iFieldCount, iRecordCount : integer;
   sFieldDefinition : string;
begin
     // create blank dbf table with appropriate fields
     if fileexists(sFilename) then
        deletefile(sFilename);
     with Query2 do
     begin
          SQL.Clear;
          SQL.Add('create table "' + sFilename + '"');
          SQL.Add('(');
          SQL.Add(' AVALUE NUMERIC(10,0),');
          SQL.Add(' A' + sFieldname + ' NUMERIC(10,0)');
          SQL.Add(')');
          //SQL.SaveToFile('c:\create.sql');

          Prepare;
          ExecSQL;
     end;
     // write records to the dbf table
     Table1.DatabaseName := ExtractFilePath(sFilename);
     Table1.TableName := ExtractFileName(sFilename);
     Table1.Open;
     Table1.Edit;
     Query1.First;
     for iRecordCount := 0 to Query1.RecordCount do
     //while Query1.RecNo < Query1.RecordCount do
     begin
          Table1.Append;

          for iFieldCount := 0 to (Query1.Fields.Count-1) do
              case Query1.Fields.Fields[iFieldCount].DataType of
                   ftString : Table1.Fields.Fields[iFieldCount].AsString := Query1.Fields.Fields[iFieldCount].AsString;
                   ftInteger : Table1.Fields.Fields[iFieldCount].AsInteger := Query1.Fields.Fields[iFieldCount].AsInteger;
                   ftFloat : Table1.Fields.Fields[iFieldCount].AsFloat := Query1.Fields.Fields[iFieldCount].AsFloat;
              end;
                                                  
          Query1.Next;
     end;

     Table1.Close;
end;

procedure TDBFChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     Action := caFree;
end;

procedure TDBFChild.FormActivate(Sender: TObject);
begin
     SCPForm.SwitchChildFocus;
end;

end.
