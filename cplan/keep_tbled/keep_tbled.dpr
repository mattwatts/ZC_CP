program keep_tbled;

uses
  Forms,
  keeptbled in 'keeptbled.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
