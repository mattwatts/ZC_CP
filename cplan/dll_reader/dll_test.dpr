program dll_test;

uses
  Forms,
  dll_reader in 'dll_reader.pas' {TestReadMSDLLForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TTestReadMSDLLForm, TestReadMSDLLForm);
  Application.Run;
end.
