unit db_note_taker;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, Forms, DBCtrls, DB, Mask, ExtCtrls;

type
  TForm3 = class(TForm)
    ScrollBox: TScrollBox;
    Label1: TLabel;
    EditINDEX: TDBEdit;
    Label2: TLabel;
    EditDATENEW: TDBEdit;
    Label3: TLabel;
    EditDATEEDIT: TDBEdit;
    Label4: TLabel;
    MemoTEXT: TDBMemo;
    Label5: TLabel;
    EditRELINDEX: TDBEdit;
    DBNavigator: TDBNavigator;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure DBNavigatorClick(Sender: TObject; Button: TNavigateBtn);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.DFM}

uses Unit2;

procedure TForm3.DBNavigatorClick(Sender: TObject; Button: TNavigateBtn);
begin
     if (nbInsert = Button) then
        // insert button pressed, add current date to the database row
        DataModule2.Table1.FieldByName('DATENEW').AsString := DateTimeToStr(Now);
        //TDateTime
end;

end.