program reserveclass;

uses
  Forms,
  reserve_class in 'reserve_class.pas' {SpecifyReserveClassesForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TSpecifyReserveClassesForm, SpecifyReserveClassesForm);
  Application.Run;
end.
