program cat;

uses
  Forms,
  cat_u1 in 'cat_u1.pas' {JoinForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TJoinForm, JoinForm);
  Application.Run;
end.
