unit loadtype;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TLoadTypeForm = class(TForm)
    RadioButtonLink: TRadioButton;
    RadioButtonLoad: TRadioButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure RadioButtonLinkClick(Sender: TObject);
    procedure RadioButtonLoadClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LoadTypeForm: TLoadTypeForm;

implementation

{$R *.DFM}

procedure TLoadTypeForm.RadioButtonLinkClick(Sender: TObject);
begin
     RadioButtonLoad.Checked := not RadioButtonLink.Checked;
end;

procedure TLoadTypeForm.RadioButtonLoadClick(Sender: TObject);
begin
     RadioButtonLink.Checked := not RadioButtonLoad.Checked;
end;

end.
