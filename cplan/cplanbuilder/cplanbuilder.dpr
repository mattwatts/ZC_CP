program cplanbuilder;

uses
  Forms,
  cplanbuilder1 in 'cplanbuilder1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
