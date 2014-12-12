program ci_import;

uses
  Forms,
  ci_import1 in 'ci_import1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
