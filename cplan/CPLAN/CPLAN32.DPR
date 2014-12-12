program cplan32;

uses
  Forms,
  cp_u1 in 'cp_u1.pas' {CPlanForm},
  edit_str in 'edit_str.pas' {EditStrForm},
  ed_entry in 'ed_entry.pas' {EditEntryForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'C-Plan Manager 32 Bit';
  Application.CreateForm(TCPlanForm, CPlanForm);
  Application.Run;
end.
