program move_avx;

uses
  Forms,
  move_u1 in 'move_u1.pas' {LocateArcViewForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TLocateArcViewForm, LocateArcViewForm);
  Application.Run;
end.
