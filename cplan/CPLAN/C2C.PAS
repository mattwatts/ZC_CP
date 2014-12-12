unit c2c;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Db, DBTables, Buttons;

type
  TC2CForm = class(TForm)
    C2Box: TListBox;
    DestBox: TListBox;
    EMSQuery: TQuery;
    QueryMemo: TMemo;
    BitBtn1: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  C2CForm: TC2CForm;

implementation

{$R *.DFM}

end.
