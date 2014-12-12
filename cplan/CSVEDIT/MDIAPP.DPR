program Mdiapp;

uses
  Forms,
  MAIN in '..\mdi_app\MAIN.PAS' {MainForm},
  Childwin in 'CHILDWIN.PAS' {MDIChild},
  About in 'about.pas' {AboutBox},
  Imptools in '..\IMPORT\Imptools.pas',
  Global in '..\EMRTOOL\Global.pas',
  join in 'join.pas' {JoinForm},
  import in 'import.pas' {ImportForm},
  editcvrt in 'editcvrt.pas' {EditConvertForm},
  xdata in 'xdata.pas',
  Ds in '..\DPARRAY\Ds.pas',
  genrand in 'genrand.pas' {GenRandForm},
  impexp in 'impexp.pas' {ImportExpertForm};

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
