unit edits;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TEnterStrForm = class(TForm)
    Edit1: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EnterStrForm: TEnterStrForm;

implementation

{$R *.DFM}

procedure TEnterStrForm.FormCreate(Sender: TObject);
begin
     ClientWidth := Edit1.Width + (2 * Edit1.Left);
     ClientHeight := BitBtn1.Top + BitBtn1.Height + Edit1.Height;
end;

end.
