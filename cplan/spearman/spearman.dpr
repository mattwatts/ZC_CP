program spearman;

uses
  Forms,
  sp_u1 in 'sp_u1.pas' {Form1},
  Spman in 'Spman.pas',
  batch in 'batch.pas' {BatchForm},
  run_spec in 'run_spec.pas' {RunSpecForm},
  sp_optimise_maths in 'sp_optimise_maths.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
