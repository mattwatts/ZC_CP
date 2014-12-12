program emr;

uses
  Forms,
  emrpr_U1 in 'emrpr_U1.pas' {EMRTestForm},
  EMRPR in 'Emrpr.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TEMRTestForm, EMRTestForm);
  Application.Run;
end.
