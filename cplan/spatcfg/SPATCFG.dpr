program SPATCFG;

uses
  Forms,
  spatcfg_u1 in 'spatcfg_u1.pas' {SPATCFGForm},
  FmxUtils in '..\dbase_editor\Fmxutils.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Spatial Software Configuration Utility';
  Application.CreateForm(TSPATCFGForm, SPATCFGForm);
  Application.Run;
end.
