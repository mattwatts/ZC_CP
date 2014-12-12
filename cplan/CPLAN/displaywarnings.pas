unit displaywarnings;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TDisplayWarningsForm = class(TForm)
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DisplayWarningsForm: TDisplayWarningsForm;

implementation

uses Control;

{$R *.DFM}

procedure TDisplayWarningsForm.FormCreate(Sender: TObject);
begin
     Listbox1.Items := ControlForm.Warnings.Items;
end;

end.
