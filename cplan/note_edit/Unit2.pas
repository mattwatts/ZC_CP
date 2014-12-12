unit Unit2;

interface

uses
  SysUtils, Windows, Classes, Graphics, Controls,
  Forms, Dialogs, DB, DBTables;

type
  TDataModule2 = class(TDataModule)
    Table1INDEX: TFloatField;
    Table1DATENEW: TDateField;
    Table1DATEEDIT: TDateField;
    Table1TEXT: TMemoField;
    Table1RELINDEX: TFloatField;
    DataSource1: TDataSource;
    Table1: TTable;
    procedure DataModuleCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  DataModule2: TDataModule2;

implementation

{$R *.DFM}

procedure TDataModule2.DataModuleCreate(Sender: TObject);
begin
  Table1.Open;
end;

end.