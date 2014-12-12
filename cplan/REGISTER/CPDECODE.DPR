program cpdecode;

uses
  Forms,
  checkr in 'checkr.pas' {DispenseForm},
  reg in 'reg.pas' {RegisterForm},
  Global in '..\CPLAN\Global.pas',
  Ds in '..\DPARRAY\Ds.pas',
  displayrego in 'displayrego.pas' {DisplayRegoForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDispenseForm, DispenseForm);
  Application.Run;
end.
