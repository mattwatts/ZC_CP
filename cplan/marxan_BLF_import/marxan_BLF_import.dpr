program marxan_BLF_import;

uses
  Forms,
  marxan_BLF_import_u1 in 'marxan_BLF_import_u1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
