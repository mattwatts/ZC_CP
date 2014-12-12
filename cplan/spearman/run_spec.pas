unit run_spec;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TRunSpecForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    EditFile: TEdit;
    Button1: TButton;
    OpenSPFile: TOpenDialog;
    EditTests: TEdit;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RunSpecForm: TRunSpecForm;

implementation

{$R *.DFM}


procedure TRunSpecForm.Button1Click(Sender: TObject);
begin
     OpenSPFile.InitialDir := ExtractFilePath(EditFile.Text);
     OpenSPFile.Filename := ExtractFileName(EditFile.Text);

     if OpenSPFile.Execute then
        EditFile.Text := OpenSPFile.Filename;
end;

end.
