program execit;

uses
  Forms,
  exec_u1 in 'exec_u1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
