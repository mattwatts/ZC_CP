program IMPORT32;

uses
  Forms,
  Dbms_man in 'DBMS_MAN.PAS',
  Fieldimp in 'FIELDIMP.PAS' {ImpOptionsForm},
  Imptools in 'IMPTOOLS.PAS',
  Mk_irr in 'MK_IRR.PAS',
  Showimp in 'SHOWIMP.PAS' {ShowImpForm},
  Test_imp in 'TEST_IMP.PAS' {DBManForm},
  Global in '..\EMRTOOL\GLOBAL.PAS',
  Linklist in '..\CYBERSFE\LLIST\LINKLIST.PAS',
  Dbmisc in '..\EMRTOOL\DBMISC.PAS',
  Addfield in 'ADDFIELD.PAS' {BtnBottomDlg},
  Datastru in '..\CYBERSFE\tools\DS\Datastru.pas',
  Os_lims in '..\CYBERSFE\tools\OS\Os_lims.pas',
  Dsdebug in '..\CYBERSFE\tools\DS\Dsdebug.pas' {DataStructDEBUG},
  Arraydb in '..\CYBERSFE\tools\DS\ARRAY\Arraydb.pas' {ArrayDebug},
  reg in '..\register\Reg.pas' {RegisterForm},
  ds in '..\CYBERSFE\tools\DS\ARRAY\ds.pas';

{$R *.RES}

begin
  Application.CreateForm(TDBManForm, DBManForm);
  Application.Run;
end.
