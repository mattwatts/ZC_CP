program ZonaeCogito;

uses
  Forms,
  SCP_Main in 'SCP_Main.pas' {SCPForm},
  About in 'About.pas' {AboutForm},
  arrange in 'arrange.pas' {ArrangeForm},
  Marxan_interface in 'Marxan_interface.pas' {MarxanInterfaceForm},
  calibration in 'calibration.pas' {CalibrationForm},
  LoadScenario in 'LoadScenario.pas' {LoadScenarioForm},
  Ds in 'DPARRAY\Ds.pas',
  DSCanvas in 'DPARRAY\DSCANVAS.PAS' {Form2},
  GIS in 'GIS.pas' {GIS_Child},
  MZ_system_test in 'MZ_system_test.pas' {MarxanSystemTestForm},
  CSV_Child in 'CSV_Child.pas' {CSVChild},
  Miscellaneous in 'Miscellaneous.pas',
  DBF_Child in 'DBF_Child.pas' {DBFChild},
  User_Select_Fields in 'User_Select_Fields.pas' {UserSelectFieldsForm},
  Shape_Legend_Editor in 'Shape_Legend_Editor.pas' {MarxanLegendEditorForm},
  Build_Child in 'Build_Child.pas' {BuildChild},
  Edit_Profile_Element in 'Edit_Profile_Element.pas' {ProfileElementForm},
  Change_status in 'Change_status.pas' {ChangeStatusForm},
  ineditp in 'ineditp.pas' {InEditForm},
  inedit_browse in 'inedit_browse.pas' {InEditBrowseForm},
  R_access in 'R_access.pas' {R_Form},
  SelectMapQuery in 'SelectMapQuery.pas' {MapQueryForm},
  validation_parameters in 'validation_parameters.pas' {ValidationParamForm},
  progress_form in 'progress_form.pas' {ProgressForm},
  graph in 'graph.pas' {GraphForm},
  EditShapeLegend in 'EditShapeLegend.pas' {EditShapeLegendForm},
  adaptive_calibration in 'adaptive_calibration.pas' {AdaptiveCalibrationForm},
  MoreRecentFiles in 'MoreRecentFiles.pas' {RecentMoreForm},
  new_project in 'new_project.pas' {NewProjectForm},
  BuildDistanceTable in 'BuildDistanceTable.pas' {BuildDistanceTableForm},
  BrowseAnnealingOutput in 'BrowseAnnealingOutput.pas' {BrowseAnnealingOutputForm},
  EditConfigurations in 'EditConfigurations.pas' {EditConfigurationsForm},
  NewConfiguration in 'NewConfiguration.pas' {NewConfigurationForm},
  ReportConfigurations in 'ReportConfigurations.pas' {ReportConfigurationsForm},
  OpenWindowsMore in 'OpenWindowsMore.pas' {OpenMoreForm},
  ComputeMarxanObjectives in 'ComputeMarxanObjectives.pas',
  ExtractAquaMapsSpecies in 'ExtractAquaMapsSpecies.pas' {ExtractAquaMapSpeciesForm},
  JoinDBFTables_puvspr in 'JoinDBFTables_puvspr.pas' {JoinDBFTablesForm},
  BrowseForFolderU in 'BrowseForFolderU.pas',
  SummariseTable in 'SummariseTable.pas' {SummariseTableForm},
  ConvertZSTATS in 'ConvertZSTATS.pas' {ConvertZSTATSForm},
  process_retention in 'process_retention.pas' {ProcessRetentionForm},
  ReportOnConfiguration in 'ReportOnConfiguration.pas' {SummariseZonesForm},
  SaveMarxanMatrix in 'SaveMarxanMatrix.pas' {SaveMarxanMatrixForm},
  SetGISDisplayOptions in 'SetGISDisplayOptions.pas' {GISOptionsForm},
  map_legend in 'map_legend.pas' {MapLegendForm},
  GraphSelector in 'GraphSelector.pas' {GraphSelectorForm},
  BarGraph in 'BarGraph.pas' {BarGraphForm},
  ConvertCPlan in 'ConvertCPlan.pas' {ConvertCPlanForm},
  BoundaryFileMaker in 'BoundaryFileMaker.pas',
  BoundaryFileMakerGUI in 'BoundaryFileMakerGUI.pas' {BoundaryFileMakerForm},
  eFlows in 'eFlows.pas' {eFlowsForm},
  BoxWhiskerPlot in 'BoxWhiskerPlot.pas' {BoxWhiskerPlotForm},
  eFlows_progress in 'eFlows_progress.pas' {eFlowsProgressForm},
  ConvertLayer in 'ConvertLayer.pas' {ConvertLayerForm},
  MessageForm in 'MessageForm.pas' {MsgForm};

{$R *.RES}


begin
  Application.Initialize;
  Application.Title := 'Zonae Cogito';

  sParameterCalled := '';
  if (ParamCount > 0) then
     sParameterCalled := ParamStr(1);

  Application.CreateForm(TSCPForm, SCPForm);
  Application.Run;
end.
