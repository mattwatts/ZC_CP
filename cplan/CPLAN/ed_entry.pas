unit ed_entry;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TEditEntryForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EditEntryForm: TEditEntryForm;

implementation

{$R *.DFM}

procedure TEditEntryForm.FormResize(Sender: TObject);
begin
     Edit1.Width := Width - (Edit1.Left + Label1.Left);
end;

end.
