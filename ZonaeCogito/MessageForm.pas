unit MessageForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TMsgForm = class(TForm)
    MsgLabel: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MsgForm: TMsgForm;

implementation

{$R *.DFM}

end.
