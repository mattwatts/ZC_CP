program register;

uses
  Forms,
  reg in 'reg.pas' {RegisterForm},
  Global in '..\CPLAN\Global.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TRegisterForm, RegisterForm);
  Application.Run;
end.
