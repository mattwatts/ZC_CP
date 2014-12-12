program jazi;

uses
  Forms,
  jaz1 in 'jaz1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
