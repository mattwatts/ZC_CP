unit Passtest;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, SHA;

type
  TfrmPasswordTest = class(TForm)
    edtStorePassword: TEdit;
    btnSetPassword: TButton;
    SHA1: TSHA;
    lblPassword: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    lblPasswordHashStore: TLabel;
    mmoSetExplanation: TMemo;
    Bevel3: TBevel;
    btnCheckPassword: TButton;
    mmoCheckExplanation: TMemo;
    lblPasswordHashCheck: TLabel;
    Bevel4: TBevel;
    Label1: TLabel;
    edtCheckPassword: TEdit;
    procedure btnSetPasswordClick(Sender: TObject);
    procedure btnCheckPasswordClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPasswordTest: TfrmPasswordTest;

implementation

{$R *.DFM}

procedure TfrmPasswordTest.btnSetPasswordClick(Sender: TObject);
begin
     SHA1.Init;
     SHA1.HashProcessString(edtStorePassword.Text);
     SHA1.Finish;
     lblPasswordHashStore.Caption := SHA1.GetHashString;
end; {btnSetPasswordClick}

procedure TfrmPasswordTest.btnCheckPasswordClick(Sender: TObject);
begin
     SHA1.Init;
     SHA1.HashProcessString(edtCheckPassword.Text);
     SHA1.Finish;
     lblPasswordHashCheck.Caption := SHA1.GetHashString;
     if lblPasswordHashCheck.Caption = lblPasswordHashStore.Caption then
     begin
          ShowMessage('The Password is correct!');
     end
     else
     begin
          ShowMessage('The Passwords do not match');
     end; {if}
end; {btnCheckPasswordClick}

end.
