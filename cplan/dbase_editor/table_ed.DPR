program table_ed;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm},
  Childwin in 'CHILDWIN.PAS' {MDIChild},
  UserSelectFields in 'UserSelectFields.pas' {UserSelectFieldsForm},
  converter in 'converter.pas' {ConvertModule: TDataModule},
  Ds in '..\DPARRAY\Ds.pas',
  buildcplanwizard in 'buildcplanwizard.pas' {BuildCPlanWizardForm},
  importintotablewizard in 'importintotablewizard.pas' {ImportIntoTableForm},
  FmxUtils in 'Fmxutils.pas',
  fieldproperties in 'fieldproperties.pas' {FieldPropertiesForm},
  listsort in 'listsort.pas',
  reallist in 'reallist.pas',
  browsed in '..\CPLAN\browsed.pas' {BrowseDirForm},
  edits in '..\CPLAN\edits.pas' {EnterStrForm},
  About in '..\CSVEDIT\about.pas' {AboutBox},
  workdir in '..\CPLAN\workdir.pas' {WorkingDirForm},
  reg in '..\REGISTER\reg.pas' {RegisterForm},
  import_file in 'import_file.pas' {ImportFileForm},
  sort_joined_mtx in 'sort_joined_mtx.pas';

{$R *.RES}

begin
  Application.Title := 'C-Plan Database Tool';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TConvertModule, ConvertModule);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TWorkingDirForm, WorkingDirForm);
  Application.Run;
end.
