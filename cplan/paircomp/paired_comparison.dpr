program paired_comparison;

uses
  Forms,
  paired in 'paired.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
