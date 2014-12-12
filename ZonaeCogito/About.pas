unit About;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, jpeg, ExtCtrls;

type
  TAboutForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    Label4: TLabel;
    Label5: TLabel;
    EditWebsite: TEdit;
    BitBtn1: TBitBtn;
    Image1: TImage;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

uses
    Miscellaneous;

{$R *.DFM}

procedure TAboutForm.FormCreate(Sender: TObject);
begin
     Label1.Caption := 'Zonae Cogito ' + sVersionString;
     Label3.Caption := sCopyrightString;
end;

end.
