program avdde;

uses
  Forms,
  av1 in 'av1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TAVDDEForm, AVDDEForm);
  Application.Run;
end.
