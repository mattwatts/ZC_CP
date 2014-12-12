program ci_mtx2csv;

uses
  Forms,
  ci_mtx2_1 in 'ci_mtx2_1.pas' {Mtx2CsvForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMtx2CsvForm, Mtx2CsvForm);
  Application.Run;
end.
