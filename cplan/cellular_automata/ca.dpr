program ca;

uses
  Forms,
  cells in 'cells.pas' {CAForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TCAForm, CAForm);
  Application.Run;
end.
