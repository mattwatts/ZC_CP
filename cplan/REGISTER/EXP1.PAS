unit exp1;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, Forms, DBCtrls, DB, DBTables, Mask, ExtCtrls;

type
  TForm1 = class(TForm)
    Table1USERID: TFloatField;
    Table1USER: TStringField;
    Table1ORG: TStringField;
    Table1VERSION: TStringField;
    Table1PROGRAM: TStringField;
    Table1USERKEY: TFloatField;
    Table1COMMENT: TStringField;
    Table1DATE: TDateField;
    ScrollBox: TScrollBox;
    Label1: TLabel;
    EditUSERID: TDBEdit;
    Label2: TLabel;
    EditUSER: TDBEdit;
    Label3: TLabel;
    EditORG: TDBEdit;
    Label4: TLabel;
    EditVERSION: TDBEdit;
    Label5: TLabel;
    EditPROGRAM: TDBEdit;
    Label6: TLabel;
    EditUSERKEY: TDBEdit;
    Label7: TLabel;
    EditCOMMENT: TDBEdit;
    Label8: TLabel;
    EditDATE: TDBEdit;
    DBNavigator: TDBNavigator;
    Panel1: TPanel;
    DataSource1: TDataSource;
    Panel2: TPanel;
    Table1: TTable;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Table1.Open;
end;

end.