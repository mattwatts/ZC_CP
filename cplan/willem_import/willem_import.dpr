program willem_import;

uses
  Forms,
  willem_import1 in 'willem_import1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
