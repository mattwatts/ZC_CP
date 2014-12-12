program cp32reg;

uses
  Forms,
  reg in 'reg.pas' {RegisterForm},
  Global in '\software\EMRTOOL\Global.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TRegisterForm, RegisterForm);
  Application.Run;
end.
