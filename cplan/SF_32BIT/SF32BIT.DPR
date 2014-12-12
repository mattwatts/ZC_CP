program sf32bit;

uses
  Forms,
  sf_32 in 'sf_32.pas' {SF32Form};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TSF32Form, SF32Form);
  Application.Run;
end.
