program picalc;

uses
  Forms,
  pi_calc in 'pi_calc.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
