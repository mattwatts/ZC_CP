program Reg16usr;

uses
  Forms,
  checkr in 'CHECKR.PAS' {DispenseForm},
  Global in '\SOFTWARE\EMRTOOL\GLOBAL.PAS';

{$R *.RES}

begin
  Application.CreateForm(TDispenseForm, DispenseForm);
  Application.Run;
end.
