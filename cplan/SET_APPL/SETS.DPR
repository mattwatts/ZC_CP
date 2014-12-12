program sets;

uses
  Forms,
  set_u1 in 'set_u1.pas' {SetForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TSetForm, SetForm);
  Application.Run;
end.
