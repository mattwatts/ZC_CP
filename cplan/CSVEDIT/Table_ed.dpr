program table_ed;

uses
  Forms,
  About in 'about.pas' {AboutForm},
  Global in '..\cplan\Global.pas',
  join in 'join.pas' {JoinForm},
  import in 'import.pas' {ImportDataFieldForm},
  editcvrt in 'editcvrt.pas' {EditConvertForm},
  xdata in 'xdata.pas',
  Ds in '..\DPARRAY\Ds.pas',
  genrand in 'genrand.pas' {GenRandForm},
  impexp in 'impexp.pas' {ImportMatrixForm},
  randdel in 'randdel.pas' {HowManyForm},
  tparse in 'tparse.pas' {TableParser},
  fieldimp in 'fieldimp.pas' {FieldImportForm},
  itools in 'itools.pas',
  qmtx in 'qmtx.pas' {QMtxForm},
  Sitelist in '..\LISTTYPE\Sitelist.pas',
  fldadd in '..\cplan\fldadd.pas' {FieldAdder: TDataModule},
  trpt in '..\cplan\trpt.pas',
  userkey in 'userkey.pas' {SelectKeyForm},
  loadtype in 'loadtype.pas' {LoadTypeForm},
  browsed in '..\cplan\browsed.pas' {BrowseDirForm},
  edits in '..\cplan\edits.pas' {EnterStrForm},
  edittype in '..\table_ed\edittype.pas' {EditTypeForm},
  comptbl in '..\table_ed\comptbl.pas' {CompareTablesForm},
  save_sub in 'save_sub.pas' {SaveSubsetForm},
  remove in 'remove.pas' {RemoveCharForm},
  paste_sp in 'paste_sp.pas' {PasteSpecialForm},
  copy_sel in 'copy_sel.pas' {CopySelectionForm},
  Dbmisc in '..\cplan\Dbmisc.pas',
  reg in '..\REGISTER\reg.pas' {RegisterForm},
  sql_tool in 'sql_tool.pas' {SQLToolForm},
  operate in 'operate.pas' {OperationForm},
  sortdata in 'sortdata.pas' {SortDataForm},
  reallist in '..\cplan\reallist.pas',
  desttest in 'desttest.pas' {DestructTestForm},
  adddata in 'adddata.pas' {AddDataForm},
  csv_link_percent_edit in 'csv_link_percent_edit.pas' {CSVLinkEdit},
  hotspots_accumulation in 'hotspots_accumulation.pas' {HotspotsAnalysisForm},
  QryEndPoint in 'QryEndPoint.pas' {QryEndPointForm},
  dbf_header in 'dbf_header.pas',
  mtx_arith in 'mtx_arith.pas' {MtxArithForm},
  savedbf in '..\CPLAN\savedbf.pas' {SaveDBFModule: TDataModule},
  new_tbl in 'new_tbl.pas' {NewTableForm},
  destanal in 'destanal.pas' {DestructAnalyseForm},
  extract_sensitivity_graphs in 'extract_sensitivity_graphs.pas' {ExtractSensitivityGraphsForm},
  rndmtx in 'rndmtx.pas' {RndMtxForm},
  process_retention in 'process_retention.pas' {ProcessRetentionForm},
  version in '..\CPLAN\version.pas',
  wyong_feat in 'wyong_feat.pas' {WyongFeatureForm},
  CombineRegions in 'CombineRegions.pas' {CombineRegionsForm},
  combineDEHveg in 'combineDEHveg.pas' {CombineDEHVegForm},
  mask_pu in 'mask_pu.pas' {MaskPuForm},
  dbms_child in '..\dbase_editor\dbms_child.pas' {DBMSForm},
  MZ_system_test in 'MZ_system_test.pas' {MarZoneSystemTestForm},
  Main in 'Main.pas' {MainForm};

{$R *.RES}

begin
  Application.Title := 'C-Plan Table Editor';
  Application.CreateForm(TMarZoneSystemTestForm, MarZoneSystemTestForm);
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
