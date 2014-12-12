program Cp16reg;

uses
  Forms,
  reg in 'REG.PAS' {RegisterForm},
  Global in '\SOFTWARE\EMRTOOL\GLOBAL.PAS';

{$R *.RES}

begin
  Application.CreateForm(TRegisterForm, RegisterForm);
  Application.Run;
end.
