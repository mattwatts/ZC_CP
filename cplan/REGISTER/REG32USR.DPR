program reg32usr;

uses
  Forms,
  checkr in 'checkr.pas' {DispenseForm},
  reg in 'reg.pas' {RegisterForm},
  Global in '\software\EMRTOOL\Global.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDispenseForm, DispenseForm);
  Application.CreateForm(TRegisterForm, RegisterForm);
  Application.Run;
end.
