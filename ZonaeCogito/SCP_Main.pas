unit SCP_Main;

interface

uses
    Marxan_interface, GIS,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, CSV_Child, DBF_Child, jpeg, ExtCtrls, StdCtrls, DdeMan, ds;

type
  TSCPForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    Applications1: TMenuItem;
    CPlan1: TMenuItem;
    Marxan1: TMenuItem;
    DatabaseManagement1: TMenuItem;
    DecisionSupport1: TMenuItem;
    Classic1: TMenuItem;
    WithZoning1: TMenuItem;
    ThreatProbability1: TMenuItem;
    DecisionSupport2: TMenuItem;
    Simulation1: TMenuItem;
    GIS1: TMenuItem;
    Import1: TMenuItem;
    Window1: TMenuItem;
    Arrange1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    ValidateMarxan1: TMenuItem;
    ConverData1: TMenuItem;
    CSVtoDBF1: TMenuItem;
    SHPtoGRID1: TMenuItem;
    SHPtoIMAGE1: TMenuItem;
    DBFtoCSV1: TMenuItem;
    MarxantoCPlan1: TMenuItem;
    CPlantoMarxan1: TMenuItem;
    Tables1: TMenuItem;
    GIS2: TMenuItem;
    ConservationPlanning1: TMenuItem;
    BuildNewMarxanDatabase1: TMenuItem;
    BuildNewCPlanDatabase1: TMenuItem;
    Transpose1: TMenuItem;
    GIS3: TMenuItem;
    Zoom1: TMenuItem;
    Extent1: TMenuItem;
    Previous1: TMenuItem;
    Selection1: TMenuItem;
    SelectWith1: TMenuItem;
    Mouse1: TMenuItem;
    Query1: TMenuItem;
    Colour1: TMenuItem;
    AddShape1: TMenuItem;
    RemoveAllShapes1: TMenuItem;
    Layer1: TMenuItem;
    SetZoomPercentage1: TMenuItem;
    CursorMode1: TMenuItem;
    ZoomIn1: TMenuItem;
    ZoomOut1: TMenuItem;
    Pan2: TMenuItem;
    Select1: TMenuItem;
    Selection2: TMenuItem;
    ChangeStatus1: TMenuItem;
    ClearSelection1: TMenuItem;
    InvertSelection1: TMenuItem;
    SelectMode1: TMenuItem;
    Intersection1: TMenuItem;
    Inclusion1: TMenuItem;
    Marxan2: TMenuItem;
    BrowseMarxanDataset1: TMenuItem;
    RunMarxan1: TMenuItem;
    SaveRun1: TMenuItem;
    LoadRun1: TMenuItem;
    RunCalibration1: TMenuItem;
    ViewOutput1: TMenuItem;
    CalibrationReport1: TMenuItem;
    SummaryReport1: TMenuItem;
    TextTable1: TMenuItem;
    AutoFit1: TMenuItem;
    Selection3: TMenuItem;
    EntireTable1: TMenuItem;
    ExportMap1: TMenuItem;
    SaveBMP: TSaveDialog;
    Savenonzerorowsandcolumns1: TMenuItem;
    SaveCSV: TSaveDialog;
    InputEditor1: TMenuItem;
    R1: TMenuItem;
    BestSolutionFeatures1: TMenuItem;
    ZoomtoExtentonResize1: TMenuItem;
    N1: TMenuItem;
    Marxan3: TMenuItem;
    GIS4: TMenuItem;
    Validation1: TMenuItem;
    GraphTable1: TMenuItem;
    HideMarxanConsole1: TMenuItem;
    ShapeOutlines1: TMenuItem;
    AdaptiveCalibrationFPF1: TMenuItem;
    SummariseFeaturesMPM1: TMenuItem;
    DoClusterAnalysis1: TMenuItem;
    OpenRecent1: TMenuItem;
    Recent1: TMenuItem;
    Recent2: TMenuItem;
    Recent3: TMenuItem;
    Recent4: TMenuItem;
    Recent5: TMenuItem;
    Recent6: TMenuItem;
    Recent7: TMenuItem;
    Recent8: TMenuItem;
    Recent9: TMenuItem;
    Recent10: TMenuItem;
    RecentFileList: TListBox;
    Recent11: TMenuItem;
    Recent12: TMenuItem;
    Recent13: TMenuItem;
    Recent14: TMenuItem;
    Recent15: TMenuItem;
    Recent16: TMenuItem;
    Recent17: TMenuItem;
    Recent18: TMenuItem;
    Recent19: TMenuItem;
    Recent20: TMenuItem;
    RecentMore: TMenuItem;
    RunRScripts1: TMenuItem;
    GenerateAllConfigurations1: TMenuItem;
    TransposeCSV1: TMenuItem;
    ZCSelectDDE: TDdeClientConv;
    DdeClientItem1: TDdeClientItem;
    ZCServerConv: TDdeServerConv;
    ZCServer: TDdeServerItem;
    TestSelectDDEcmd1: TMenuItem;
    NewProject1: TMenuItem;
    BuildDistanceTable1: TMenuItem;
    BrowseAnnealingOutput1: TMenuItem;
    BatchRunProjects1: TMenuItem;
    EditConfigurations1: TMenuItem;
    ReportConfigurations1: TMenuItem;
    EditConfigurations2: TMenuItem;
    OpenFile1: TMenuItem;
    OpenFile2: TMenuItem;
    OpenFile3: TMenuItem;
    OpenFile4: TMenuItem;
    OpenFile5: TMenuItem;
    OpenFile6: TMenuItem;
    OpenFile7: TMenuItem;
    OpenFile8: TMenuItem;
    OpenFile9: TMenuItem;
    OpenFile10: TMenuItem;
    OpenMore: TMenuItem;
    CompactMarxanMatrix1: TMenuItem;
    ExtractAquaMapsSpecies1: TMenuItem;
    ExportSelectedShapes1: TMenuItem;
    SaveKML: TSaveDialog;
    JoinDBFTables1: TMenuItem;
    SummariseTable1: TMenuItem;
    ConvertZSTATStables1: TMenuItem;
    RegionsExtract1: TMenuItem;
    SummariseZones1: TMenuItem;
    OpenFromMarxanMatrix1: TMenuItem;
    OpenDialog2: TOpenDialog;
    SaveToMarxanMatrix1: TMenuItem;
    BitmapBMP1: TMenuItem;
    ShapefileSHP1: TMenuItem;
    KeyholeMarkupLanguageKML1: TMenuItem;
    SaveSHP: TSaveDialog;
    ESRIShapefileSHP1: TMenuItem;
    KeyholeMarkupLanguageKML2: TMenuItem;
    AllShapes1: TMenuItem;
    SelectedShapes1: TMenuItem;
    BestSolution1: TMenuItem;
    SummedSolution1: TMenuItem;
    Transparency1: TMenuItem;
    BuildCPlanDataset1: TMenuItem;
    SummaryBarGraph1: TMenuItem;
    BestSolutionBarGraph1: TMenuItem;
    BestSolution2: TMenuItem;
    Summary1: TMenuItem;
    BuildBoundaryLengthFile1: TMenuItem;
    OpenFromMarxanProb2DMatrix1: TMenuItem;
    Image1: TImage;
    eFlows1: TMenuItem;
    eFlows2: TMenuItem;
    RuneFlows1: TMenuItem;
    HideExcelInterface1: TMenuItem;
    SaveXLSonexit1: TMenuItem;
    Image2: TImage;
    GenerateTimeSeriesAnimation1: TMenuItem;
    ViewOutput2: TMenuItem;
    TargByRun1: TMenuItem;
    AllocTrack1: TMenuItem;
    labeltowns1: TMenuItem;
    MissingValuesBarGraph1: TMenuItem;
    BestSolution3: TMenuItem;
    AllSolutions1: TMenuItem;
    BestSolution4: TMenuItem;
    AllSolutions2: TMenuItem;
    TotalSummary1: TMenuItem;
    Wateredwetlands1: TMenuItem;
    BestSolution5: TMenuItem;
    Solution11: TMenuItem;
    Solution21: TMenuItem;
    Solution31: TMenuItem;
    Solution41: TMenuItem;
    Solution51: TMenuItem;
    Solution61: TMenuItem;
    Solution71: TMenuItem;
    Solution81: TMenuItem;
    Solution91: TMenuItem;
    Solution101: TMenuItem;
    BestSolution6: TMenuItem;
    Solution12: TMenuItem;
    Solution22: TMenuItem;
    Solution32: TMenuItem;
    Solution42: TMenuItem;
    Solution52: TMenuItem;
    Solution62: TMenuItem;
    Solution72: TMenuItem;
    Solution82: TMenuItem;
    Solution92: TMenuItem;
    Solution102: TMenuItem;
    Arrangesidebyside1: TMenuItem;
    Arrangetoptobottom1: TMenuItem;
    Cascade1: TMenuItem;
    PurgeDBF1: TMenuItem;
    PurgeDBF2: TMenuItem;
    BoxWhiskerPlot1: TMenuItem;
    ConvertLayer1: TMenuItem;
    SHPtoSHP1: TMenuItem;
    SHPtoBMP1: TMenuItem;
    Maximise1: TMenuItem;
    Restore1: TMenuItem;
    ClearRecentFiles1: TMenuItem;
    procedure About1Click(Sender: TObject);
    procedure Arrange1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure DecisionSupport1Click(Sender: TObject);
    procedure GIS1Click(Sender: TObject);
    procedure TileVertical;
    procedure TileHorizontal;
    procedure Open1Click(Sender: TObject);
    function ReturnNamedMarxanChildIndex(const sName : string) : integer;
    function ReturnNamedGISChildIndex(const sName : string) : integer;
    function ReturnNamedDBFTableChildIndex(const sName : string) : integer;
    function ReturnNamedCSVTableChildIndex(const sName : string) : integer;
    function ReturnNamedChildIndex(const iTag : integer; const sName : string) : integer;
    function ReturnMarxanChildIndex : integer;
    function ReturneFlowsChildIndex : integer;
    function ReturnGISChildIndex : integer;
    function ReturnDBFTableChildIndex : integer;
    function ReturnCSVTableChildIndex : integer;
    function ReturnChildIndex(const iTag : integer) : integer;
    function ReturnNamedChild(const sName : string) : TForm;
    procedure Open_ZCP_Project(const sFilename : string);
    function CreateCSVChild(const sFilename : string; const iFixedColumns : integer) : TCSVChild;
    function CreateHiddenCSVChild(const sFilename : string; const iFixedColumns : integer) : TCSVChild;
    procedure CreateDBFChild(const sFilename : string;const fSelectedShapesOnly, fAllowUserToSelectSubsetOfFields : boolean);
    function CreateShapeChild(const sFilename : string) : TGIS_Child;
    function CreateImageChild(const sFilename : string) : TGIS_Child;
    function CreateGridChild(const sFilename : string) : TGIS_Child;
    procedure CreateMarxanChild(const sFilename : string);
    procedure CreateBuildChild(const sFilename : string);
    function TransposeCSVChild(AChild : TCSVChild; const fReverseDataFields : boolean) : string;
    procedure ValidateMarxan1Click(Sender: TObject);
    procedure Transpose1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure BuildNewMarxanDatabase1Click(Sender: TObject);
    procedure AddShape1Click(Sender: TObject);
    procedure RemoveAllShapes1Click(Sender: TObject);
    procedure Extent1Click(Sender: TObject);
    procedure Layer1Click(Sender: TObject);
    procedure Previous1Click(Sender: TObject);
    procedure ZoomIn1Click(Sender: TObject);
    procedure ZoomOut1Click(Sender: TObject);
    procedure Pan2Click(Sender: TObject);
    procedure Select1Click(Sender: TObject);
    procedure Mouse1Click(Sender: TObject);
    procedure Inclusion1Click(Sender: TObject);
    procedure Intersection1Click(Sender: TObject);
    procedure ClearSelection1Click(Sender: TObject);
    procedure SwitchChildFocus;
    procedure FormActivate(Sender: TObject);
    procedure BrowseMarxanDataset1Click(Sender: TObject);
    procedure RunMarxan1Click(Sender: TObject);
    procedure SaveRun1Click(Sender: TObject);
    procedure LoadRun1Click(Sender: TObject);
    procedure RunCalibration1Click(Sender: TObject);
    procedure CalibrationReport1Click(Sender: TObject);
    procedure DisplayMarxanCalibrationReport;
    procedure DisplayMarxanSummaryReport;
    procedure DisplayBestSolutionFeaturesReport;
    procedure SummaryReport1Click(Sender: TObject);
    procedure AutoFitCSVChild(const fFitEntireGrid : boolean);
    procedure EntireTable1Click(Sender: TObject);
    procedure Selection3Click(Sender: TObject);
    procedure Query1Click(Sender: TObject);
    procedure InvertSelection1Click(Sender: TObject);
    procedure SetZoomPercentage1Click(Sender: TObject);
    procedure Colour1Click(Sender: TObject);
    procedure EditMarxanMapColours(iItemIndex : integer);
    procedure ChangeStatus1Click(Sender: TObject);
    procedure Savenonzerorowsandcolumns1Click(Sender: TObject);
    procedure InputEditor1Click(Sender: TObject);
    procedure R1Click(Sender: TObject);
    procedure BestSolutionFeatures1Click(Sender: TObject);
    procedure Save_ZCP_Project(const sFilename : string; const iGISChildIndex,iMarxanChildIndex : integer);
    procedure ZoomtoExtentonResize1Click(Sender: TObject);
    procedure Validation1Click(Sender: TObject);
    procedure GraphTable1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HideMarxanConsole1Click(Sender: TObject);
    procedure ShapeOutlines1Click(Sender: TObject);
    procedure Marxan3Click(Sender: TObject);
    procedure GIS4Click(Sender: TObject);
    procedure AdaptiveCalibrationFPF1Click(Sender: TObject);
    procedure SummariseFeaturesMPM1Click(Sender: TObject);
    procedure DoClusterAnalysis1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure UpdateRecent(const sFilename : string);
    procedure Recent1Click(Sender: TObject);
    procedure FileOpen(const sFilename : string);
    procedure CSVFileOpen(const sFilename : string);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Recent2Click(Sender: TObject);
    procedure Recent3Click(Sender: TObject);
    procedure Recent4Click(Sender: TObject);
    procedure Recent5Click(Sender: TObject);
    procedure Recent6Click(Sender: TObject);
    procedure Recent7Click(Sender: TObject);
    procedure Recent8Click(Sender: TObject);
    procedure Recent9Click(Sender: TObject);
    procedure Recent10Click(Sender: TObject);
    procedure Recent11Click(Sender: TObject);
    procedure Recent12Click(Sender: TObject);
    procedure Recent13Click(Sender: TObject);
    procedure Recent14Click(Sender: TObject);
    procedure Recent15Click(Sender: TObject);
    procedure Recent16Click(Sender: TObject);
    procedure Recent17Click(Sender: TObject);
    procedure Recent18Click(Sender: TObject);
    procedure Recent19Click(Sender: TObject);
    procedure Recent20Click(Sender: TObject);
    procedure RecentMoreClick(Sender: TObject);
    procedure RunRScripts1Click(Sender: TObject);
    procedure GenerateAllConfigurations1Click(Sender: TObject);
    procedure TransposeCSV1Click(Sender: TObject);
    procedure ZCServerConvExecuteMacro(Sender: TObject; Msg: TStrings);
    procedure TestSelectDDEcmd1Click(Sender: TObject);
    procedure NewProject1Click(Sender: TObject);
    procedure Nexion;
    procedure SetDDEProject(const sProject : string);
    procedure SetDDESourceTable(const sSourceTable : string);
    procedure SetDDESourceKey(const sSourceKey : string);
    procedure SetDDEPULayer(const sPULayer : string);
    procedure SetDDEPUKey(const sPUKey : string);
    procedure SetDDESaveProject(const sProject : string);
    procedure DDEUpdateGIS(const sParameters : string);
    procedure SetDDEName(const sName : string);
    procedure ZCSelectDDEOpen(Sender: TObject);
    procedure ZCSelectDDEClose(Sender: TObject);
    procedure BuildDistanceTable1Click(Sender: TObject);
    procedure DDERedrawMap(const sParameters : string);
    procedure BrowseAnnealingOutput1Click(Sender: TObject);
    procedure BatchRunProjects1Click(Sender: TObject);
    procedure EditConfigurations1Click(Sender: TObject);
    procedure ReportConfigurations1Click(Sender: TObject);
    procedure EditConfigurations2Click(Sender: TObject);
    procedure GiveWindowFocus(const sWindow : string);
    procedure UpdateOpenFiles;
    procedure UnlockDebug(const sChar : string);
    procedure OpenFile1Click(Sender: TObject);
    procedure OpenFile2Click(Sender: TObject);
    procedure OpenFile3Click(Sender: TObject);
    procedure OpenFile4Click(Sender: TObject);
    procedure OpenFile5Click(Sender: TObject);
    procedure OpenFile6Click(Sender: TObject);
    procedure OpenFile7Click(Sender: TObject);
    procedure OpenFile8Click(Sender: TObject);
    procedure OpenFile9Click(Sender: TObject);
    procedure OpenFile10Click(Sender: TObject);
    procedure OpenMoreClick(Sender: TObject);
    procedure ExtractAquaMapsSpecies1Click(Sender: TObject);
    procedure JoinDBFTables1Click(Sender: TObject);
    procedure SummariseTable1Click(Sender: TObject);
    procedure ConvertZSTATStables1Click(Sender: TObject);
    procedure MaskLoadZSTATSDBF(const sFilename, sFieldname : string);
    procedure RegionsExtract1Click(Sender: TObject);
    procedure SummariseZones1Click(Sender: TObject);
    procedure OpenFromMarxanMatrix1Click(Sender: TObject);
    procedure SaveToMarxanMatrix1Click(Sender: TObject);
    procedure BitmapBMP1Click(Sender: TObject);
    procedure ShapefileSHP1Click(Sender: TObject);
    procedure ESRIShapefileSHP1Click(Sender: TObject);
    procedure KeyholeMarkupLanguageKML2Click(Sender: TObject);
    procedure AllShapes1Click(Sender: TObject);
    procedure SelectedShapes1Click(Sender: TObject);
    procedure BestSolution1Click(Sender: TObject);
    procedure SummedSolution1Click(Sender: TObject);
    procedure Transparency1Click(Sender: TObject);
    procedure BuildCPlanDataset1Click(Sender: TObject);
    procedure SummaryBarGraph1Click(Sender: TObject);
    procedure BestSolutionBarGraph1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BuildBoundaryLengthFile1Click(Sender: TObject);
    procedure OpenFromMarxanProb2DMatrix1Click(Sender: TObject);
    procedure eFlows1Click(Sender: TObject);
    procedure RuneFlows1Click(Sender: TObject);
    procedure HideExcelInterface1Click(Sender: TObject);
    procedure GenerateTimeSeriesAnimation1Click(Sender: TObject);
    procedure MissingValuesBarGraph1Click(Sender: TObject);
    procedure AllSolutions1Click(Sender: TObject);
    procedure BestSolution3Click(Sender: TObject);
    procedure BestSolution4Click(Sender: TObject);
    procedure AllSolutions2Click(Sender: TObject);
    procedure BestSolution5Click(Sender: TObject);
    procedure Solution11Click(Sender: TObject);
    procedure Solution21Click(Sender: TObject);
    procedure Solution31Click(Sender: TObject);
    procedure Solution41Click(Sender: TObject);
    procedure Solution51Click(Sender: TObject);
    procedure Solution61Click(Sender: TObject);
    procedure Solution71Click(Sender: TObject);
    procedure Solution81Click(Sender: TObject);
    procedure Solution91Click(Sender: TObject);
    procedure Solution101Click(Sender: TObject);
    procedure BestSolution6Click(Sender: TObject);
    procedure Solution12Click(Sender: TObject);
    procedure Solution22Click(Sender: TObject);
    procedure Solution32Click(Sender: TObject);
    procedure Solution42Click(Sender: TObject);
    procedure Solution52Click(Sender: TObject);
    procedure Solution62Click(Sender: TObject);
    procedure Solution72Click(Sender: TObject);
    procedure Solution82Click(Sender: TObject);
    procedure Solution92Click(Sender: TObject);
    procedure Solution102Click(Sender: TObject);
    procedure Arrangesidebyside1Click(Sender: TObject);
    procedure Arrangetoptobottom1Click(Sender: TObject);
    procedure Cascade1Click(Sender: TObject);
    procedure PurgeDBF1Click(Sender: TObject);
    function ReturneFlowsTableIndex(const sName : string) : integer;
    procedure PurgeDBF2Click(Sender: TObject);
    procedure BoxWhiskerPlot1Click(Sender: TObject);
    procedure SHPtoSHP1Click(Sender: TObject);
    procedure SHPtoBMP1Click(Sender: TObject);
    procedure Maximise1Click(Sender: TObject);
    procedure Restore1Click(Sender: TObject);
    procedure ClearRecent;
    procedure ClearRecentFiles1Click(Sender: TObject);
    function GenerateAndRunRScripts : boolean;
  private
    { Private declarations }
  public
    { Public declarations }
    sRestoreProjectFileName : string;
    fMarxanActivated, feFlowsActivated, fEditConfigurationsForm : boolean;
    sDDESourceTable, sDDESourceKey, sDDEPULayer, sDDEPUKey, sDDEName : string;
  end;

var
  SCPForm: TSCPForm;
  sParameterCalled, sKeyInput : string;
  fCPlanSelectDDELink, fTransparencyStored, f64BitOS, fMarZone, fBarGraphStarting : boolean;
  TransparencyArray : Array_t;

implementation

uses About, arrange, IniFiles, MZ_system_test,
  User_Select_Fields, Grids, Miscellaneous, Build_Child, SelectMapQuery,
  Shape_Legend_Editor, Change_status, ineditp, R_access,
  validation_parameters, graph, adaptive_calibration, MoreRecentFiles,
  new_project, MapWinGIS_TLB, BuildDistanceTable, BrowseAnnealingOutput,
  EditConfigurations, ReportConfigurations, OpenWindowsMore,
  ExtractAquaMapsSpecies, JoinDBFTables_puvspr, SummariseTable,
  ConvertZSTATS, process_retention, ReportOnConfiguration, SaveMarxanMatrix,
  SetGISDisplayOptions, GraphSelector, ConvertCPlan, BarGraph,
  BoundaryFileMaker, BoundaryFileMakerGUI, eFlows,
  BoxWhiskerPlot, ConvertLayer;//, BatchRunProjects;

{$R *.DFM}

// key to mdi child types
// we use the form "Tag" to identify the class of an mdi child form at runtime
// TAG CHILD
// 1   Marxan
// 2   GIS
// 3   DBF
// 4   CSV
// 5   Build
// 6   Edit Congifurations
// 7   eFlows


procedure TSCPForm.ClearRecent;
var
   AIni : TIniFile;
   iCount, iDuplicateIndex : integer;
begin
     try
        // erase recent file list
        AIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'UserSettings.ini');
        AIni.EraseSection('FileOpen');
        AIni.Free;
        RecentFileList.Items.Clear;
     except
     end;

     // hide recent file list in menu
     OpenRecent1.Visible := False;
     Recent1.Visible := False;
     Recent2.Visible := False;
     Recent3.Visible := False;
     Recent4.Visible := False;
     Recent5.Visible := False;
     Recent6.Visible := False;
     Recent7.Visible := False;
     Recent8.Visible := False;
     Recent9.Visible := False;
     Recent10.Visible := False;
     Recent11.Visible := False;
     Recent12.Visible := False;
     Recent13.Visible := False;
     Recent14.Visible := False;
     Recent15.Visible := False;
     Recent16.Visible := False;
     Recent17.Visible := False;
     Recent18.Visible := False;
     Recent19.Visible := False;
     Recent20.Visible := False;
     RecentMore.Visible := False;
     ClearRecentFiles1.Visible := False;
end;

procedure TSCPForm.UpdateRecent(const sFilename : string);
var
   AIni : TIniFile;
   iCount, iDuplicateIndex : integer;
begin
     if (sFilename <> '') then
     begin
          try
             // save filename to recent file list
             AIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'UserSettings.ini');
             AIni.ReadSection('FileOpen',RecentFileList.Items);
             AIni.EraseSection('FileOpen');

             // remove duplicate entry
             iDuplicateIndex := RecentFileList.Items.IndexOf(sFilename);
             if (iDuplicateIndex > -1) then
                RecentFileList.Items.Delete(iDuplicateIndex);
             RecentFileList.Items.Insert(0,sFilename);

             // write entries to the file
             for iCount := 1 to RecentFileList.Items.Count do
                 if fileexists(RecentFileList.Items.Strings[iCount-1]) then
                    AIni.WriteString('FileOpen',RecentFileList.Items.Strings[iCount-1],'');
             AIni.Free;
             RecentFileList.Items.Clear;
          except
          end;
     end;

     // load recent file list to menu
     OpenRecent1.Visible := False;
     Recent1.Visible := False;
     Recent2.Visible := False;
     Recent3.Visible := False;
     Recent4.Visible := False;
     Recent5.Visible := False;
     Recent6.Visible := False;
     Recent7.Visible := False;
     Recent8.Visible := False;
     Recent9.Visible := False;
     Recent10.Visible := False;
     Recent11.Visible := False;
     Recent12.Visible := False;
     Recent13.Visible := False;
     Recent14.Visible := False;
     Recent15.Visible := False;
     Recent16.Visible := False;
     Recent17.Visible := False;
     Recent18.Visible := False;
     Recent19.Visible := False;
     Recent20.Visible := False;
     RecentMore.Visible := False;

     try
        AIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'UserSettings.ini');
        AIni.ReadSection('FileOpen',RecentFileList.Items);
        AIni.EraseSection('FileOpen');
        for iCount := 1 to RecentFileList.Items.Count do
            if fileexists(RecentFileList.Items.Strings[iCount-1]) then
               AIni.WriteString('FileOpen',RecentFileList.Items.Strings[iCount-1],'');
        AIni.ReadSection('FileOpen',RecentFileList.Items);
        AIni.Free;

        if (RecentFileList.Items.Count>0) then
        begin
             Recent1.Visible := True;
             Recent1.Caption := RecentFileList.Items.Strings[0];
             OpenRecent1.Visible := True;
             ClearRecentFiles1.Visible := True;
        end;
        if (RecentFileList.Items.Count>1) then
        begin
             Recent2.Visible := True;
             Recent2.Caption := RecentFileList.Items.Strings[1];
        end;
        if (RecentFileList.Items.Count>2) then
        begin
             Recent3.Visible := True;
             Recent3.Caption := RecentFileList.Items.Strings[2];
        end;
        if (RecentFileList.Items.Count>3) then
        begin
             Recent4.Visible := True;
             Recent4.Caption := RecentFileList.Items.Strings[3];
        end;
        if (RecentFileList.Items.Count>4) then
        begin
             Recent5.Visible := True;
             Recent5.Caption := RecentFileList.Items.Strings[4];
        end;
        if (RecentFileList.Items.Count>5) then
        begin
             Recent6.Visible := True;
             Recent6.Caption := RecentFileList.Items.Strings[5];
        end;
        if (RecentFileList.Items.Count>6) then
        begin
             Recent7.Visible := True;
             Recent7.Caption := RecentFileList.Items.Strings[6];
        end;
        if (RecentFileList.Items.Count>7) then
        begin
             Recent8.Visible := True;
             Recent8.Caption := RecentFileList.Items.Strings[7];
        end;
        if (RecentFileList.Items.Count>8) then
        begin
             Recent9.Visible := True;
             Recent9.Caption := RecentFileList.Items.Strings[8];
        end;
        if (RecentFileList.Items.Count>9) then
        begin
             Recent10.Visible := True;
             Recent10.Caption := RecentFileList.Items.Strings[9];
        end;
        if (RecentFileList.Items.Count>10) then
        begin
             Recent11.Visible := True;
             Recent11.Caption := RecentFileList.Items.Strings[10];
        end;
        if (RecentFileList.Items.Count>11) then
        begin
             Recent12.Visible := True;
             Recent12.Caption := RecentFileList.Items.Strings[11];
        end;
        if (RecentFileList.Items.Count>12) then
        begin
             Recent13.Visible := True;
             Recent13.Caption := RecentFileList.Items.Strings[12];
        end;
        if (RecentFileList.Items.Count>13) then
        begin
             Recent14.Visible := True;
             Recent14.Caption := RecentFileList.Items.Strings[13];
        end;
        if (RecentFileList.Items.Count>14) then
        begin
             Recent15.Visible := True;
             Recent15.Caption := RecentFileList.Items.Strings[14];
        end;
        if (RecentFileList.Items.Count>15) then
        begin
             Recent16.Visible := True;
             Recent16.Caption := RecentFileList.Items.Strings[15];
        end;
        if (RecentFileList.Items.Count>16) then
        begin
             Recent17.Visible := True;
             Recent17.Caption := RecentFileList.Items.Strings[16];
        end;
        if (RecentFileList.Items.Count>17) then
        begin
             Recent18.Visible := True;
             Recent18.Caption := RecentFileList.Items.Strings[17];
        end;
        if (RecentFileList.Items.Count>18) then
        begin
             Recent19.Visible := True;
             Recent19.Caption := RecentFileList.Items.Strings[18];
        end;
        if (RecentFileList.Items.Count>19) then
        begin
             Recent20.Visible := True;
             Recent20.Caption := RecentFileList.Items.Strings[19];
        end;
        if (RecentFileList.Items.Count>20) then
           RecentMore.Visible := True;
           
        RecentFileList.Items.Clear;
     except
     end;
end;

function unobfs(const s: string): string;
var
   i: Integer;
begin
     SetLength(Result,Length(s));
     for i := Length(s) downto 1 do
         Result[Length(s) - i + 1] := s[i];
end;

procedure TSCPForm.SwitchChildFocus;
var
   iCount : integer;
begin
     if (MDIChildCount > 0) then
     begin
          GIS3.Visible := False;
          Marxan2.Visible := (ReturnMarxanChildIndex > -1);
          eFlows2.Visible := (ReturneFlowsChildIndex > -1);
          TextTable1.Visible := False;

          case ActiveMDIChild.Tag of
               1,2,6,7 : GIS3.Visible := True;
               4 : TextTable1.Visible := True;
          end;

          UpdateOpenFiles;
     end;
end;

function TSCPForm.ReturnNamedMarxanChildIndex(const sName : string) : integer;
begin
     // Marxan children have Tag 1
     Result := ReturnNamedChildIndex(1,sName);
end;

function TSCPForm.ReturnNamedGISChildIndex(const sName : string) : integer;
begin
     // GIS children have Tag 2
     Result := ReturnNamedChildIndex(2,sName);
end;

function TSCPForm.ReturnNamedDBFTableChildIndex(const sName : string) : integer;
begin
     // DBF children have Tag 3
     Result := ReturnNamedChildIndex(3,sName);
end;

function TSCPForm.ReturnNamedCSVTableChildIndex(const sName : string) : integer;
begin
     // CSV children have Tag 4
     Result := ReturnNamedChildIndex(4,sName);
end;

function TSCPForm.ReturnNamedChildIndex(const iTag : integer; const sName : string) : integer;
var
   iResult, iCount : integer;
begin
     iResult := -1;

     for iCount := 0 to (MDIChildCount - 1) do
         if (MDIChildren[iCount].Tag = iTag) and (MDIChildren[iCount].Caption = sName) then
            iResult := iCount;

     Result := iResult;
end;

function TSCPForm.ReturneFlowsTableIndex(const sName : string) : integer;
var
   iResult, iCount : integer;
begin
     iResult := -1;

     for iCount := 0 to (MDIChildCount - 1) do
         if (MDIChildren[iCount].Caption = sName) then
            iResult := iCount;

     Result := iResult;
end;

function TSCPForm.ReturnNamedChild(const sName : string) : TForm;
var
   iCount : integer;
begin
     Result := nil;

     for iCount := 0 to (MDIChildCount - 1) do
         if (MDIChildren[iCount].Caption = sName) then
            Result := MDIChildren[iCount];
end;

function TSCPForm.ReturnMarxanChildIndex : integer;
begin
     Result := ReturnChildIndex(1);
end;

function TSCPForm.ReturneFlowsChildIndex : integer;
begin
     Result := ReturnChildIndex(7);
end;

function TSCPForm.ReturnGISChildIndex : integer;
begin
     // GIS children have Tag 2
     Result := ReturnChildIndex(2);
end;

function TSCPForm.ReturnDBFTableChildIndex : integer;
begin
     // DBF children have Tag 3
     Result := ReturnChildIndex(3);
end;

function TSCPForm.ReturnCSVTableChildIndex : integer;
begin
     // CSV children have Tag 4
     Result := ReturnChildIndex(4);
end;

function TSCPForm.ReturnChildIndex(const iTag : integer) : integer;
var
   iResult, iCount : integer;
begin
     iResult := -1;

     for iCount := 0 to (MDIChildCount - 1) do
         if (MDIChildren[iCount].Tag = iTag) then
            iResult := iCount;

     Result := iResult;
end;

procedure TSCPForm.About1Click(Sender: TObject);
begin
     AboutForm := TAboutForm.Create(Application);
     AboutForm.ShowModal;
     AboutForm.Free;
end;

procedure TSCPForm.Arrange1Click(Sender: TObject);
begin
     ArrangeForm := TArrangeForm.Create(Application);
     ArrangeForm.ShowModal;
     ArrangeForm.Free;
end;

procedure TSCPForm.Exit1Click(Sender: TObject);
begin
     Close;
end;

procedure TSCPForm.DecisionSupport1Click(Sender: TObject);
begin
     MarxanInterfaceForm := TMarxanInterfaceForm.Create(Application);
     MarxanInterfaceForm.Show;
     MarxanInterfaceForm.FormResize(Sender);
end;

procedure TSCPForm.GIS1Click(Sender: TObject);
begin
     GIS_Child := TGIS_Child.Create(Application);
     GIS_Child.Show;
end;

procedure TSCPForm.TileVertical;
var
   iCount : integer;
begin
     TileMode  := tbVertical;
     for iCount := 0 to (MDIChildCount - 1) do
         MDIChildren[iCount].TileMode  := tbVertical;

     Tile;
end;
procedure TSCPForm.TileHorizontal;
var
   iCount : integer;
begin
     TileMode  := tbHorizontal;
     for iCount := 0 to (MDIChildCount - 1) do
         MDIChildren[iCount].TileMode  := tbHorizontal;

     Tile;
end;

function AdaptiveFilePath(const sFilePathName, sProjectPathFileName : string;
                          var fAdaptivePathTriggered : boolean) : string;
var
   sProjectPath, sSearchFile, sTestFile, sTestDirectory : string;
begin
     if fileexists(sFilePathName) then
        Result := sFilePathName
     else
     begin
          // attempt to manufacture a new string
          fAdaptivePathTriggered := True;

          // take the subdirectory from the project file
          // look in this directory for the file from the file name.
          // if it doesn't exist look in this directory for the last directory in the path
          // if it doesn't exist look in this directory for the next directory in the path

          sProjectPath := ExtractFilePath(sProjectPathFileName);
          sSearchFile := ExtractFileName(sFilePathName);

          if fileexists(sProjectPath + sSearchFile) then
             Result := sProjectPath + sSearchFile
          else
          begin
               sProjectPath := Copy(sProjectPath,1,Length(sProjectPath)-1);
               sTestDirectory := ExtractFilePath(sFilePathName);
               sTestDirectory := Copy(sTestDirectory,1,Length(sTestDirectory)-1);
               sTestFile := ExtractFileName(sTestDirectory);

               if fileexists(sProjectPath + '\' + sTestFile + '\' + sSearchFile) then
                  Result := sProjectPath + '\' + sTestFile + '\' + sSearchFile
               else
                   Result := '';
          end;
     end;
end;

procedure TSCPForm.Open_ZCP_Project(const sFilename : string);
var
   iChildIndex, iTest, iNumLayers, iCount, iNumZones,
   iGISChildIndex, iMarxanChildIndex,
   iTop, iLeft, iHeight, iWidth, iLayerHandle, iFontSize : integer;
   AIni : TIniFile;
   sLayerColour, sLayerName, sTemporaryFilePath, sTemp, sWindowState : string;
   fLayerVisible, fStop, fAdaptivePathTriggered, fLoadingMarxan, fLoadingeFlows, feFlowsPuLayer : boolean;
   TempColour : TColor;
   myExtents: MapWinGIS_TLB.Extents;
   xMin, yMin, zMin, xMax, yMax, zMax : Double;
   rTransparency, rSize : extended;
   ALDO : LabelDisplayOption_T;
begin
     try
        fStop := False;
        fAdaptivePathTriggered := False;
        AIni := TIniFile.Create(sFilename);

        // if any GIS children are open, close them
        iChildIndex := ReturnGISChildIndex;
        if (iChildIndex > -1) then
           TGIS_Child(MDIChildren[iChildIndex]).Free;
        // if any Marxan children are open, close them
        iChildIndex := ReturnMarxanChildIndex;
        if (iChildIndex > -1) then
           TMarxanInterfaceForm(MDIChildren[iChildIndex]).Free;
        // if any eFlows children are open, close them
        iChildIndex := ReturneFlowsChildIndex;
        if (iChildIndex > -1) then
           TeFlowsForm(MDIChildren[iChildIndex]).Free;
        // if edit config form is open, close it
        if fEditConfigurationsForm then
           EditConfigurationsForm.Close;

        // load GIS child and add planning unit layer
        GIS_Child := TGIS_Child.Create(Application);

        // load Marxan child and open dataset
        fMarxanActivated := False;
        fLoadingMarxan := False;
        sTemp := AIni.ReadString('Marxan','name','');
        if (sTemp <> '') then
           fLoadingMarxan := True;

        if fLoadingMarxan then
        begin
             MarxanInterfaceForm := TMarxanInterfaceForm.Create(Application);
             MarxanInterfaceForm.Show;
             MarxanInterfaceForm.FormResize(Self);
             MarxanInterfaceForm.Name := AIni.ReadString('Marxan','name','Marxan');
             with MarxanInterfaceForm do
             begin
                  sTemporaryFilePath := AIni.ReadString('Marxan','input','GIS');

                  EditMarxanDatabasePath.Text := AdaptiveFilePath(sTemporaryFilePath,sFilename,fAdaptivePathTriggered);

                  if (EditMarxanDatabasePath.Text = '') then
                  begin
                       fStop := True;
                       MessageDlg('Cannot find file ' + sTemporaryFilePath,mtInformation,[mbOk],0);
                  end
                  else
                  begin
                       HideMarxanConsole1.Checked := AIni.ReadBool('Marxan','HideConsole',HideMarxanConsole1.Checked);
                       DoClusterAnalysis1.Checked := AIni.ReadBool('Marxan','ClusterAnalysis',DoClusterAnalysis1.Checked);

                       ComboPUShapefile.Items.Clear;
                       ComboPUShapefile.Items.Add(AIni.ReadString('GIS','pulayer',''));
                       ComboPUShapefile.Text := AIni.ReadString('GIS','pulayer','');
                       ComboKeyField.Items.Clear;
                       ComboKeyField.Items.Add(AIni.ReadString('GIS','KeyField',''));
                       ComboKeyField.Text := AIni.ReadString('GIS','KeyField','');
                       InitDatabase;

                       // cause a redisplay of the gis
                       try
                          sTemporaryFilePath := AIni.ReadString('GIS','pulayer','');
                          sTemporaryFilePath := AdaptiveFilePath(sTemporaryFilePath,sFilename,fAdaptivePathTriggered);

                          if (sTemporaryFilePath = '') then
                          begin
                               fStop := True;
                               MessageDlg('Cannot find file ' + sTemporaryFilePath,mtInformation,[mbOk],0);
                          end
                          else
                          begin
                               // read in the contextual GIS layers and their selected colour
                               iNumLayers := AIni.ReadInteger('GIS','Layers',1);
                               if (iNumLayers > 1) then
                               begin
                                    for iCount := 0 to (iNumLayers-1) do
                                    begin
                                         sTemporaryFilePath := AIni.ReadString('GIS',
                                                                               'Layer' + IntToStr(iCount+1),
                                                                               '');
                                         sTemporaryFilePath := AdaptiveFilePath(sTemporaryFilePath,sFilename,fAdaptivePathTriggered);

                                         if (sTemporaryFilePath = '') then
                                         begin
                                              fStop := True;
                                              MessageDlg('Cannot find file ' + sTemporaryFilePath,mtInformation,[mbOk],0);
                                              Break;
                                         end
                                         else
                                         begin
                                              sLayerName := sTemporaryFilePath;

                                              sLayerColour := AIni.ReadString('GIS',
                                                                               'Layer' + IntToStr(iCount+1) + 'Colour',
                                                                               '0000FF');
                                              fLayerVisible := AIni.ReadBool('GIS',
                                                                             'Layer' + IntToStr(iCount+1) + 'Selected',
                                                                             True);

                                              ComboPUShapefile.Items.Add(sLayerName);
                                              if (LowerCase(ExtractFileExt(sLayerName)) = '.shp') then
                                              begin
                                                   if (sLayerName = ComboPUShapefile.Text) then
                                                      iLayerHandle := GIS_Child.AddShape(sLayerName)
                                                   else
                                                       iLayerHandle := GIS_Child.AddShapeColour(sLayerName,SmartOpenColour(sLayerColour),fLayerVisible);

                                                   rTransparency := AIni.ReadFloat('GIS',
                                                                                   'Layer' + IntToStr(iCount+1) +'Transparency',
                                                                                   1);
                                                   GIS_Child.Map1.ShapeLayerFillTransparency[iLayerHandle] := rTransparency;
                                                   // apply size option
                                                   case IShapefile(GIS_Child.Map1.GetObject[iLayerHandle]).ShapefileType of
                                                        SHP_POINT, SHP_POINTZ, SHP_POINTM :
                                                        begin
                                                             GIS_Child.Map1.ShapeLayerPointSize[iLayerHandle] := AIni.ReadFloat('GIS',
                                                                                                                         'Layer' + IntToStr(iCount+1) +'Size',
                                                                                                                         GIS_Child.iDefaultPointSize);
                                                             StoreLayerSizeOption(iLayerHandle+1,GIS_Child.Map1.ShapeLayerPointSize[iLayerHandle]);

                                                             GIS_Child.Map1.ShapeLayerPointColor[iLayerHandle] := GIS_Child.Map1.ShapeLayerFillColor[iLayerHandle];
                                                        end;
                                                        SHP_POLYLINE, SHP_POLYLINEZ, SHP_POLYLINEM :
                                                        begin
                                                             GIS_Child.Map1.ShapeLayerLineWidth[iLayerHandle] := AIni.ReadFloat('GIS',
                                                                                                                         'Layer' + IntToStr(iCount+1) +'Size',
                                                                                                                          GIS_Child.iDefaultLineWidth);

                                                             StoreLayerSizeOption(iLayerHandle+1,GIS_Child.Map1.ShapeLayerLineWidth[iLayerHandle]);
                                                        end;
                                                        SHP_POLYGON, SHP_POLYGONZ, SHP_POLYGONM :
                                                        begin
                                                             GIS_Child.Map1.ShapeLayerLineWidth[iLayerHandle] := AIni.ReadFloat('GIS',
                                                                                                                         'Layer' + IntToStr(iCount+1) +'Size',
                                                                                                                          GIS_Child.iDefaultPolygonLineWidth);
                                                             StoreLayerSizeOption(iLayerHandle+1,GIS_Child.Map1.ShapeLayerLineWidth[iLayerHandle]);
                                                        end;
                                                   end;

                                                   ALDO.sField := AIni.ReadString('GIS','Layer' + IntToStr(iCount+1) + 'Label','');
                                                   if (ALDO.sField <> '') then
                                                   begin
                                                        ALDO.fDisplayLabel := True;
                                                        ALDO.AJustify := StringToJustification(AIni.ReadString('GIS','Layer' + IntToStr(iCount+1) + 'LabelJustify',''));
                                                        StoreLabelDisplayOption(iLayerHandle+1,ALDO.fDisplayLabel,ALDO.sField,ALDO.AJustify);
                                                        iFontSize := AIni.ReadInteger('GIS','Layer' + IntToStr(iCount+1) + 'FontSize',0);
                                                        if (iFontSize <> 0) then
                                                           StoreLayerFontSizeOption(iLayerHandle+1,iFontSize);
                                                   end;
                                              end
                                              else
                                                  GIS_Child.AddImage(sLayerName);
                                         end;
                                    end;
                               end;
                               // now read in the planning unit layer
                               if (LowerCase(ExtractFileExt(sTemporaryFilePath)) = '.shp') then
                                  iLayerHandle := GIS_Child.AddShape(sTemporaryFilePath)
                               else
                                   GIS_Child.AddImage(sTemporaryFilePath);
                               GIS_Child.Caption := AIni.ReadString('GIS','name','GIS');
                               if (GIS_Child.Caption = '') then
                                  GIS_Child.Caption := 'GIS';
                               if not fStop then
                               begin
                                    // read colour options for the Marxan planning units GIS display
                                    iNumZones := AIni.ReadInteger('GIS','Zones',MarxanInterfaceForm.SingleSolutionColours.lMaxSize);
                                    if (iNumZones = MarxanInterfaceForm.SingleSolutionColours.lMaxSize) then
                                       for iCount := 1 to iNumZones do
                                       begin
                                            MarxanInterfaceForm.SingleSolutionColours.rtnValue(iCount,@TempColour);
                                            sLayerColour := AIni.ReadString('GIS','Zone' + IntToStr(iCount) + 'Colour',TColourToHex(TempColour));
                                            TempColour := SmartOpenColour(sLayerColour);
                                            MarxanInterfaceForm.SingleSolutionColours.setValue(iCount,@TempColour);
                                       end;
                                    sLayerColour := AIni.ReadString('GIS','SelectionColour',TColourToHex(GIS_Child.SelectionColour));
                                    GIS_Child.SelectionColour := SmartOpenColour(sLayerColour);
                                    sLayerColour := AIni.ReadString('GIS','SummedSolutionColour',TColourToHex(GIS_Child.SummedSolutionColour));
                                    GIS_Child.SummedSolutionColour := SmartOpenColour(sLayerColour);
                                    ShapeOutlines1.Checked := AIni.ReadBool('GIS','ShapeOutlines',False);

                                    GIS_Child.Map1.ShapeLayerFillTransparency[iLayerHandle] := 1;

                                    GIS_Child.Show;
                                    RefreshGISDisplay;
                               end;
                          end;
                       except
                       end;
                  end;
             end;

             if (AIni.ReadString('Edit Configurations Window','Active','False') = 'True') then
             begin
                  EditConfigurationsForm := TEditConfigurationsForm.Create(Application);
                  fEditConfigurationsForm := True;
                  EditConfigurationsForm.Tag := 6;

                  EditConfigurationsForm.Top := AIni.ReadInteger('Edit Configurations Window','Top',MarxanInterfaceForm.Top);
                  EditConfigurationsForm.Left := AIni.ReadInteger('Edit Configurations Window','Left',MarxanInterfaceForm.Left);
                  EditConfigurationsForm.Height := AIni.ReadInteger('Edit Configurations Window','Height',MarxanInterfaceForm.Height);
                  EditConfigurationsForm.Width := AIni.ReadInteger('Edit Configurations Window','Width',MarxanInterfaceForm.Width);

                  EditConfigurationsForm.Width := 454;
                  EditConfigurationsForm.Height := 327;
                  EditConfigurations2.Enabled := True;
                  EditConfigurations2.Visible := True;

                  EditConfigurationsForm.Show;
             end;
        end;

        // load eFlows child and open dataset
        fLoadingeFlows := False;
        sTemp := AIni.ReadString('eFlows','name','');
        if (sTemp <> '') then
           fLoadingeFlows := True;

        if fLoadingeFlows then
        begin
             eFlowsForm := TeFlowsForm.Create(Application);
             eFlowsForm.FormStyle := fsMDIChild;
             eFlowsForm.Show;
             eFlowsForm.FormResize(Self);
             with eFlowsForm do
             begin
                  Name := AIni.ReadString('eFlows','name','eFlows');
                  sTemporaryFilePath := AIni.ReadString('eFlows','input','GIS');

                  EditeFlowSpreadsheetPathName.Text := AdaptiveFilePath(sTemporaryFilePath,sFilename,fAdaptivePathTriggered);

                  if (EditeFlowSpreadsheetPathName.Text = '') then
                  begin
                       fStop := True;
                       MessageDlg('Cannot find file ' + sTemporaryFilePath,mtInformation,[mbOk],0);
                  end
                  else
                  begin
                       InitialiseeFlowsGUI(EditeFlowSpreadsheetPathName.Text);
                  end;

                  eFlowsForm.ComboOutputToMap.Text := AIni.ReadString('eFlows','output',eFlowsForm.ComboOutputToMap.Text);

                  sWindowState := AIni.ReadString('eFlows Window','State','Normal');
                  if (sWindowState = 'Normal') then
                  begin
                       WindowState := wsNormal;
                       Top := AIni.ReadInteger('eFlows Window','Top',Top);
                       Left := AIni.ReadInteger('eFlows Window','Left',Left);
                       Height := AIni.ReadInteger('eFlows Window','Height',Height);
                       Width := AIni.ReadInteger('eFlows Window','Width',Width);
                  end
                  else
                      if (sWindowState = 'Maximized') then
                         WindowState := wsMaximized
                      else
                          if (sWindowState = 'Minimized') then
                             WindowState := wsMinimized;

                  seFlowsPuLayer := AIni.ReadString('GIS','pulayer','');
                  GIS_Child.sPuFileName := seFlowsPuLayer;
                  seFlowsKeyField := AIni.ReadString('GIS','KeyField','');
             end;

             HideExcelInterface1.Checked := AIni.ReadBool('eFlows','HideExcelInterface',HideExcelInterface1.Checked);
             SaveXLSonexit1.Checked := AIni.ReadBool('eFlows','SaveXLSOnExit',SaveXLSonexit1.Checked);

             GIS_Child.btnPostDDESelection.Visible := False;
        end;

        if not fLoadingMarxan then
        begin
             // cause a redisplay of the gis
             try
                GIS_Child.Caption := AIni.ReadString('GIS','name','GIS');
                if (GIS_Child.Caption = '') then
                   GIS_Child.Caption := 'GIS';
                // read in the contextual GIS layers and their selected colour
                iNumLayers := AIni.ReadInteger('GIS','Layers',1);
                if (iNumLayers > 0) then
                begin
                     for iCount := 0 to (iNumLayers-1) do
                     begin
                          sTemporaryFilePath := AIni.ReadString('GIS',
                                                                'Layer' + IntToStr(iCount+1),
                                                                '');
                          sTemporaryFilePath := AdaptiveFilePath(sTemporaryFilePath,sFilename,fAdaptivePathTriggered);

                          if (sTemporaryFilePath = '') then
                          begin
                               fStop := True;
                               MessageDlg('Cannot find file ' + sTemporaryFilePath,mtInformation,[mbOk],0);
                               Break;
                          end
                          else
                          begin
                               sLayerName := sTemporaryFilePath;

                               sLayerColour := AIni.ReadString('GIS',
                                                               'Layer' + IntToStr(iCount+1) + 'Colour',
                                                               '0000FF');
                               fLayerVisible := AIni.ReadBool('GIS',
                                                              'Layer' + IntToStr(iCount+1) + 'Selected',
                                                              True);

                               if (LowerCase(ExtractFileExt(sLayerName)) = '.shp') then
                               begin
                                    feFlowsPuLayer := (fLoadingeFlows and (sLayerName = eFlowsForm.seFlowsPuLayer));

                                    if (feFlowsPuLayer) then
                                       iLayerHandle := GIS_Child.AddShape(sLayerName)
                                    else
                                        iLayerHandle := GIS_Child.AddShapeColour(sLayerName,SmartOpenColour(sLayerColour),fLayerVisible);

                                    // apply size option
                                    case IShapefile(GIS_Child.Map1.GetObject[iLayerHandle]).ShapefileType of
                                         SHP_POINT, SHP_POINTZ, SHP_POINTM :
                                         begin
                                              GIS_Child.Map1.ShapeLayerPointSize[iLayerHandle] := AIni.ReadFloat('GIS',
                                                                                                          'Layer' + IntToStr(iCount+1) +'Size',
                                                                                                          GIS_Child.iDefaultPointSize);
                                              StoreLayerSizeOption(iLayerHandle+1,GIS_Child.Map1.ShapeLayerPointSize[iLayerHandle]);

                                              GIS_Child.Map1.ShapeLayerPointColor[iLayerHandle] := GIS_Child.Map1.ShapeLayerFillColor[iLayerHandle];
                                         end;
                                         SHP_POLYLINE, SHP_POLYLINEZ, SHP_POLYLINEM :
                                         begin
                                             GIS_Child.Map1.ShapeLayerLineWidth[iLayerHandle] := AIni.ReadFloat('GIS',
                                                                                                          'Layer' + IntToStr(iCount+1) +'Size',
                                                                                                           GIS_Child.iDefaultLineWidth);
                                              StoreLayerSizeOption(iLayerHandle+1,GIS_Child.Map1.ShapeLayerLineWidth[iLayerHandle]);
                                         end;
                                         SHP_POLYGON, SHP_POLYGONZ, SHP_POLYGONM :
                                         begin
                                             GIS_Child.Map1.ShapeLayerLineWidth[iLayerHandle] := AIni.ReadFloat('GIS',
                                                                                                          'Layer' + IntToStr(iCount+1) +'Size',
                                                                                                           GIS_Child.iDefaultPolygonLineWidth);
                                              StoreLayerSizeOption(iLayerHandle+1,GIS_Child.Map1.ShapeLayerLineWidth[iLayerHandle]);
                                         end;
                                    end;
                                    // apply transparency option
                                    rTransparency := AIni.ReadFloat('GIS',
                                                                    'Layer' + IntToStr(iCount+1) +'Transparency',
                                                                    1);
                                    GIS_Child.Map1.ShapeLayerFillTransparency[iLayerHandle] := rTransparency;

                                    ALDO.sField := AIni.ReadString('GIS','Layer' + IntToStr(iCount+1) + 'Label','');
                                    if (ALDO.sField <> '') then
                                    begin
                                         ALDO.fDisplayLabel := True;
                                         ALDO.AJustify := StringToJustification(AIni.ReadString('GIS','Layer' + IntToStr(iCount+1) + 'LabelJustify',''));
                                         StoreLabelDisplayOption(iLayerHandle+1,ALDO.fDisplayLabel,ALDO.sField,ALDO.AJustify);
                                         GIS_Child.LabelShapeLayer(sLayerName,ALDO.sField,ALDO.AJustify);
                                         iFontSize := AIni.ReadInteger('GIS','Layer' + IntToStr(iCount+1) + 'FontSize',0);
                                         if (iFontSize <> 0) then
                                         begin
                                              StoreLayerFontSizeOption(iLayerHandle+1,iFontSize);
                                              GIS_Child.Map1.LayerFont(iLayerHandle,'Arial',iFontSize);
                                         end;
                                    end;
                               end
                               else
                                   GIS_Child.AddImage(sLayerName);
                          end;
                     end;
                end;

                if not fStop then
                begin
                     sLayerColour := AIni.ReadString('GIS','SelectionColour',TColourToHex(GIS_Child.SelectionColour));
                     GIS_Child.SelectionColour := SmartOpenColour(sLayerColour);
                     ShapeOutlines1.Checked := AIni.ReadBool('GIS','ShapeOutlines',False);

                     GIS_Child.Show;
                     if fLoadingeFlows then
                        GIS_Child.ComboOutputToMapChange(Self);
                end;
             except
             end;
        end;

        if fStop then
        begin
             GIS_Child.Free;
             if fLoadingMarxan then
                MarxanInterfaceForm.Free;
             if fLoadingeFlows then
                eFlowsForm.Free;
        end
        else
        begin
             sTemp := AIni.ReadString('GIS','CursorMode','ZoomIn');
             if (sTemp = 'ZoomIn') then
                GIS_Child.ChangeMode(0);
             if (sTemp = 'ZoomOut') then
                GIS_Child.ChangeMode(1);
             if (sTemp = 'Pan') then
                GIS_Child.ChangeMode(2);
             if (sTemp = 'Select') then
                GIS_Child.ChangeMode(3);

             sTemp := AIni.ReadString('GIS','ZoomToLayerOnResize','Yes');
             ZoomtoExtentonResize1.Checked := (sTemp = 'Yes');

             xMin := AIni.ReadFloat('GIS','Bounds_xMin',0);
             yMin := AIni.ReadFloat('GIS','Bounds_yMin',0);
             zMin := AIni.ReadFloat('GIS','Bounds_zMin',0);
             xMax := AIni.ReadFloat('GIS','Bounds_xMax',0);
             yMax := AIni.ReadFloat('GIS','Bounds_yMax',0);
             zMax := AIni.ReadFloat('GIS','Bounds_zMax',0);
             //if (xMin <> 0) and (xMax <> 0) then
             //   myExtents.SetBounds(xMin, yMin, zMin, xMax, yMax, zMax);
             if (xMin <> 0) and (xMax <> 0) then
             begin
                  myExtents := CoExtents.Create();
                  myExtents.SetBounds(xMin, yMin, zMin, xMax, yMax, zMax);

                  GIS_Child.Map1.Extents := myExtents;

                  //IExtents(GIS_Child.Map1.Extents).SetBounds(xMin, yMin, zMin, xMax, yMax, zMax);
             end;

             // restore DDE settings if present
             sDDEName := AIni.ReadString('DDE','Name','');
             sDDEPULayer := AIni.ReadString('DDE','PULayer','');
             sDDEPUKey := AIni.ReadString('DDE','PUKey','');
             sDDESourceTable := AIni.ReadString('DDE','SourceTable','');
             sDDESourceKey := AIni.ReadString('DDE','SourceKey','');

             N1.Enabled := True;
             N1.Visible := True;
             if fLoadingMarxan then
             begin
                  Marxan3.Enabled := True;
                  Marxan3.Visible := True;
                  Marxan3.Caption := MarxanInterfaceForm.Name;
             end;
             GIS4.Enabled := True;
             GIS4.Visible := True;
             GIS4.Caption := GIS_Child.Caption;

             iTest := AIni.ReadInteger('ZC Window','Top',-99);

             iTop := AIni.ReadInteger('ZC Window','Top',Top);
             iLeft := AIni.ReadInteger('ZC Window','Left',Left);
             iHeight := AIni.ReadInteger('ZC Window','Height',Height);
             iWidth := AIni.ReadInteger('ZC Window','Width',Width);

             if (iLeft + iWidth) > (Screen.Width + 5) then
             begin
                  iTest := -99;
             end;

             if (iTop + iHeight) > (Screen.Height + 5) then
             begin
                  iTest := -99;
             end;

             if (iTest = -99) then
             begin
                  if (Screen.Height > Screen.Width) then
                     TileHorizontal
                  else
                      TileVertical;
             end
             else
             begin
                  Top := iTest;
                  Left := AIni.ReadInteger('ZC Window','Left',Left);
                  Height := AIni.ReadInteger('ZC Window','Height',Height);
                  Width := AIni.ReadInteger('ZC Window','Width',Width);

                  sWindowState := AIni.ReadString('GIS Window','State','Normal');

                  if (sWindowState = 'Normal') then
                  begin
                       GIS_Child.WindowState := wsNormal;
                       GIS_Child.Top := AIni.ReadInteger('GIS Window','Top',GIS_Child.Top);
                       GIS_Child.Left := AIni.ReadInteger('GIS Window','Left',GIS_Child.Left);
                       GIS_Child.Height := AIni.ReadInteger('GIS Window','Height',GIS_Child.Height);
                       GIS_Child.Width := AIni.ReadInteger('GIS Window','Width',GIS_Child.Width);
                  end
                  else
                      if (sWindowState = 'Maximized') then
                         GIS_Child.WindowState := wsMaximized
                      else
                          if (sWindowState = 'Minimized') then
                             GIS_Child.WindowState := wsMinimized;

                  if fLoadingMarxan then
                  begin
                       sWindowState := AIni.ReadString('Marxan Window','State','Normal');

                       if (sWindowState = 'Normal') then
                       begin
                            MarxanInterfaceForm.WindowState := wsNormal;
                            MarxanInterfaceForm.Top := AIni.ReadInteger('Marxan Window','Top',MarxanInterfaceForm.Top);
                            MarxanInterfaceForm.Left := AIni.ReadInteger('Marxan Window','Left',MarxanInterfaceForm.Left);
                            MarxanInterfaceForm.Height := AIni.ReadInteger('Marxan Window','Height',MarxanInterfaceForm.Height);
                            MarxanInterfaceForm.Width := AIni.ReadInteger('Marxan Window','Width',MarxanInterfaceForm.Width);
                       end
                       else
                           if (sWindowState = 'Maximized') then
                              MarxanInterfaceForm.WindowState := wsMaximized
                           else
                               if (sWindowState = 'Minimized') then
                                  MarxanInterfaceForm.WindowState := wsMinimized;
                  end;
             end;

             GIS_Child.ZoomToTimer.Enabled := True;

             if fAdaptivePathTriggered then
             begin
                  // backup existing project file
                  ACopyFile(sFilename,sFilename + '~');
                  // create new project file
                  iGISChildIndex := ReturnGISChildIndex;
                  iMarxanChildIndex := ReturnMarxanChildIndex;

                  if (iGISChildIndex > -1) then
                  begin
                       Save_ZCP_Project(sFilename,iGISChildIndex,iMarxanChildIndex);
                       Open_ZCP_Project(sFilename);
                  end;
             end;
        end;

        AIni.Free;
        SwitchChildFocus;

     except
           MessageDlg('Exception in Open Project',mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

function TSCPForm.CreateCSVChild(const sFilename : string; const iFixedColumns : integer) : TCSVChild;
var
   Child : TCSVChild;
begin
     // load file if it exists, else create blank table
     Child := TCSVChild.Create(Application);
     Child.Caption := sFilename;
     Child.Show;
     Child.NewChild;
     if (iFixedColumns > 0) then
        if (Child.aGrid.ColCount > iFixedColumns) then
           Child.aGrid.FixedCols := iFixedColumns;
end;

function TSCPForm.CreateHiddenCSVChild(const sFilename : string; const iFixedColumns : integer) : TCSVChild;
var
   Child : TCSVChild;
begin
     // load file if it exists, else create blank table
     Child := TCSVChild.Create(Application);
     Child.Caption := sFilename;
     Child.Show;
     Child.NewChild;
     if (iFixedColumns > 0) then
        if (Child.aGrid.ColCount > iFixedColumns) then
           Child.aGrid.FixedCols := iFixedColumns;
     Child.WindowState := wsMinimized;
end;



procedure TSCPForm.CreateDBFChild(const sFilename : string;
                                  const fSelectedShapesOnly, fAllowUserToSelectSubsetOfFields : boolean);
var
   Child : TDBFChild;
   sFile, sExt, sTmp : string;
   iCount : integer;
   fContinue : boolean;
begin
     // load file if it exists
     if fileexists(sFilename) then
     begin
          fContinue := False;
          UserSelectFieldsForm := TUserSelectFieldsForm.Create(Application);
          UserSelectFieldsForm.InitForm(sFilename);
          if fAllowUserToSelectSubsetOfFields then
          begin
               if (UserSelectFieldsForm.ShowModal = mrOk)
               and (UserSelectFieldsForm.OutputFields.Items.Count > 0) then
                   fContinue := True;
          end
          else
          begin
               fContinue := True;
               UserSelectFieldsForm.AddAllClick(SCPForm);
          end;

          if fContinue then
          begin
              Child := TDBFChild.Create(Application);
              Child.Caption := sFilename;

              with Child.Query1 do
              try
                 SQL.Clear;
                 SQL.Add('Select');
                 // list fields from table to select
                 sFile := ExtractFileName(sFilename);
                 sExt := ExtractFileExt(sFilename);
                 sTmp := Copy(sFile,
                              1,
                              Length(sFile)- Length(sExt));
                 for iCount := 0 to (UserSelectFieldsForm.OutputFields.Items.Count - 1) do
                 begin
                      if (iCount = (UserSelectFieldsForm.OutputFields.Items.Count - 1)) then
                         SQL.Add('"' + sTmp + '".' + '"' + UserSelectFieldsForm.OutputFields.Items.Strings[iCount] + '"')
                      else
                          SQL.Add('"' + sTmp + '".' + '"' + UserSelectFieldsForm.OutputFields.Items.Strings[iCount] + '",');
                 end;
                 SQL.Add('From "' + sFilename + '"');

                 if fSelectedShapesOnly then
                    SQL.Add('where ZCSELECT = 1');

                 SQL.Add('As ' + sTmp);

                 Active := False;
                 Active := True;

                 Child.lblDimensions.Caption := 'records ' + IntToStr(RecordCount) +
                                                ' fields ' + IntToStr(FieldCount) +
                                                ' data elements ' + IntToStr(RecordCount * FieldCount);

                 Child.Show;

              except
                    Screen.Cursor := crDefault;
                    MessageDlg('Could not open table ' + sFile + '.  It may be in use by another program.',mtInformation,[mbOk],0);
                    SQL.SaveToFile('c:\exception_in_select.sql');
                    Child.Free;
              end;
          end;
          UserSelectFieldsForm.Free;
     end;
end;

procedure TSCPForm.MaskLoadZSTATSDBF(const sFilename, sFieldname : string);
var
   Child : TDBFChild;
   sFile, sExt, sTmp : string;
   iCount : integer;
   fContinue : boolean;
begin
     // load file if it exists
     if fileexists(sFilename) then
     begin
          Child := TDBFChild.Create(Application);
          Child.Caption := sFilename;

          with Child.Query1 do
          try
             sFile := ExtractFileName(sFilename);
             sExt := ExtractFileExt(sFilename);
             sTmp := Copy(sFile,
                          1,
                          Length(sFile)- Length(sExt));
             SQL.Clear;
             SQL.Add('Select');

             SQL.Add('"' + sTmp + '".' + '"VALUE",');
             //SQL.Add('"' + sTmp + '".' + '"SUM"');
             SQL.Add('"' + sTmp + '".' + '"' + sFieldname + '"');

             SQL.Add('From "' + sFilename + '"');

             SQL.Add('As ' + sTmp);

             Active := False;
             Active := True;

             Child.lblDimensions.Caption := 'records ' + IntToStr(RecordCount) +
                                            ' fields ' + IntToStr(FieldCount) +
                                            ' data elements ' + IntToStr(RecordCount * FieldCount);

             Child.Show;

          except
                Screen.Cursor := crDefault;
                MessageDlg('Could not open table ' + sFile + '.  It may be in use by another program.',mtInformation,[mbOk],0);
                Child.Free;
          end;
     end;
end;

function TSCPForm.CreateShapeChild(const sFilename : string) : TGIS_Child;
var
   iMarxanChildIndex, iShapeHandle : integer;
begin
     GIS_Child := TGIS_Child.Create(Application);
     GIS_Child.Show;
     iShapeHandle := GIS_Child.AddShapeColour(sFilename,clBlue,True);
     GIS_Child.ZoomTo(1);
     GIS_Child.Caption := 'GIS';

     // if marxan child exists, populate the
     iMarxanChildIndex := ReturnMarxanChildIndex;
     if (iMarxanChildIndex > -1) then
        with TMarxanInterfaceForm(MDIChildren[iMarxanChildIndex]) do
        begin
             ComboPUShapefile.Items.Clear;
             ComboPUShapefile.Items.Add(sFilename);
             ComboPUShapefile.Text := sFilename;

             GIS_Child.ReturnShapeFields(iShapeHandle,ComboKeyField.Items);
             ComboKeyField.Text := ComboKeyField.Items.Strings[0];

             Marxan3.Enabled := True;
             Marxan3.Visible := True;
             Marxan3.Caption := MarxanInterfaceForm.Name;
        end;

     N1.Enabled := True;
     N1.Visible := True;

     Result := GIS_Child;
end;

function TSCPForm.CreateImageChild(const sFilename : string) : TGIS_Child;
var
   iMarxanChildIndex, iImageHandle : integer;
begin
     GIS_Child := TGIS_Child.Create(Application);
     GIS_Child.Show;
     iImageHandle := GIS_Child.AddImage(sFilename);
     GIS_Child.Caption := 'GIS';

     N1.Enabled := True;
     N1.Visible := True;

     Result := GIS_Child;
end;

function TSCPForm.CreateGridChild(const sFilename : string) : TGIS_Child;
begin
     GIS_Child := TGIS_Child.Create(Application);
     GIS_Child.Show;
     GIS_Child.AddGrid(sFilename);
     GIS_Child.Caption := 'GIS';

     N1.Enabled := True;
     N1.Visible := True;
     GIS4.Enabled := True;
     GIS4.Visible := True;
     GIS4.Caption := GIS_Child.Caption;

     Result := GIS_Child;
end;

procedure TSCPForm.Nexion;
begin
     if (sKeyInput = unobfs(sEE1))
     or (sKeyInput = unobfs(sEE2)) then
     begin
          sKeyInput := '';
          Image1.Align := alClient;
          Image1.Visible := True;
     end;

     if (sKeyInput = unobfs(sEE3))
     or (sKeyInput = unobfs(sEE4)) then
     begin
          sKeyInput := '';
          Image2.Align := alClient;
          Image2.Visible := True;
     end;
end;

procedure TSCPForm.CreateMarxanChild(const sFilename : string);
var
   iGISChildIndex, iCount, iNumLayers : integer;
   A_GIS_Child : TGIS_Child;
   sLayerName : string;
begin
     MarxanInterfaceForm := TMarxanInterfaceForm.Create(Application);
     MarxanInterfaceForm.Show;

     MarxanInterfaceForm.EditMarxanDatabasePath.Text := OpenDialog1.Filename;
     MarxanInterfaceForm.InitDatabase;

     MarxanInterfaceForm.FormResize(self);

     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
        with TGIS_Child(MDIChildren[iGISChildIndex]) do
        begin
             //A_GIS_Child := TGIS_Child(MDIChildren[iGISChildIndex]);

             MarxanInterfaceForm.ComboPUShapefile.Items.Clear;
             MarxanInterfaceForm.ComboPUShapefile.Items.Add(sPuFileName);
             MarxanInterfaceForm.ComboPUShapefile.Text := sPuFileName;

             //iNumLayers := TGIS_Child(MDIChildren[iGISChildIndex]).Map1.NumLayers;
             iNumLayers := GIS_Child.Map1.NumLayers;
             for iCount := 0 to (iNumLayers-1) do
             begin
                  //sLayerName := TGIS_Child(MDIChildren[iGISChildIndex]).Map1.LayerName[iCount];
                  sLayerName := GIS_Child.Map1.LayerName[iCount];

                 if (sPuFileName <> sLayerName) then
                    MarxanInterfaceForm.ComboPUShapefile.Items.Add(sLayerName);
             end;

             ReturnShapeFields(iPULayerHandle,MarxanInterfaceForm.ComboKeyField.Items);
             MarxanInterfaceForm.ComboKeyField.Text := MarxanInterfaceForm.ComboKeyField.Items.Strings[0];
        end;

     N1.Enabled := True;
     N1.Visible := True;
     Marxan3.Enabled := True;
     Marxan3.Visible := True;
     Marxan3.Caption := MarxanInterfaceForm.Name;
end;

procedure TSCPForm.CreateBuildChild(const sFilename : string);
begin
     BuildChild := TBuildChild.Create(Application);
     BuildChild.Show;
     BuildChild.LoadProfile(sFilename);
     //BuildChild.Caption := 'GIS';
end;

procedure TSCPForm.Open1Click(Sender: TObject);
var
   iCount : integer;
begin
     if OpenDialog1.Execute then
     begin
          if (OpenDialog1.Files.Count > 1) then
          begin
               for iCount := 1 to (OpenDialog1.Files.Count-1) do
                   FileOpen(OpenDialog1.Files.Strings[iCount]);
          end
          else
              FileOpen(OpenDialog1.Filename);
     end;
end;

procedure TSCPForm.FileOpen(const sFilename : string);
var
   sExtension, sLocalFileName : string;
   iGISChildIndex, iPos, iCount : integer;
   AChild : TGIS_Child;
begin
     try
        FormStyle := fsMDIForm;
        iPos := Pos('&',sFilename);
        if (iPos > 0) then
        begin
             sLocalFileName := '';
             for iCount := 1 to Length(sFilename) do
                 if (sFilename[iCount] <> '&') then
                    sLocalFileName := sLocalFileName + sFilename[iCount];
        end
        else
            sLocalFileName := sFilename;

        if fileexists(sLocalFileName) then
        try
           // spawn the relevant child type depending on file type
           sExtension := LowerCase(ExtractFileExt(sLocalFileName));

           if (sExtension = '.zcp') then
              Open_ZCP_Project(sLocalFileName);

           if (sExtension = '.csv') then
              CreateCSVChild(sLocalFileName,0);

           if (sExtension = '.dbf') then
              CreateDBFChild(sLocalFileName,False,True);

           if (sExtension = '.shp') then
           begin
                iGISChildIndex := ReturnGISChildIndex;
                if (iGISChildIndex > -1) then
                begin
                     AChild := TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]);
                     AChild.AddShapeColour(sLocalFileName,IndexToColour(AChild.Map1.NumLayers),True);
                     AChild.ZoomTo(1);
                end
                else
                begin
                     AChild := CreateShapeChild(sLocalFileName);
                     AChild.ZoomTo(0);
                end;
           end;

           if (sExtension = '.tif')
           or (sExtension = '.bmp') then
           begin
                iGISChildIndex := ReturnGISChildIndex;
                if (iGISChildIndex > -1) then
                begin
                     AChild := TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]);
                     AChild.AddImage(sLocalFileName);
                     AChild.ZoomTo(1);
                end
                else
                    AChild := CreateImageChild(sLocalFileName);
           end;

           if (sExtension = '.adf') then
           begin
                iGISChildIndex := ReturnGISChildIndex;
                if (iGISChildIndex > -1) then
                begin
                     AChild := TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]);
                     AChild.AddGrid(sLocalFileName);
                     AChild.ZoomTo(1);
                end
                else
                    AChild := CreateGridChild(sLocalFileName);

                sLocalFileName := ChangeFileExt(sLocalFileName,'.bmp');
           end;

           if (sExtension = '.dat') then
              CreateMarxanChild(sLocalFileName);

           if (sExtension = '.mbp') then
              CreateBuildChild(sLocalFileName);

           UpdateRecent(sLocalFileName);

        except
              MessageDlg('Exception in File Open',mtError,[mbOk],0);
              Application.Terminate;
        end
        else
            MessageDlg('Cannot open file ' + sFilename + ', does not exist.',mtInformation,[mbOk],0);

     except
           MessageDlg('Exception in File Open',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TSCPForm.CSVFileOpen(const sFilename : string);
var
   sExtension, sLocalFileName : string;
   iGISChildIndex, iPos, iCount : integer;
   AChild : TGIS_Child;
begin
     try
        iPos := Pos('&',sFilename);
        if (iPos > 0) then
        begin
             sLocalFileName := '';
             for iCount := 1 to Length(sFilename) do
                 if (sFilename[iCount] <> '&') then
                    sLocalFileName := sLocalFileName + sFilename[iCount];
        end
        else
            sLocalFileName := sFilename;

        if fileexists(sLocalFileName) then
        try
           // spawn the relevant child type depending on file type
           sExtension := LowerCase(ExtractFileExt(sLocalFileName));
           if (sExtension = '.csv') then
              CreateCSVChild(sLocalFileName,0);

        except
              MessageDlg('Exception in CSV File Open',mtError,[mbOk],0);
              Application.Terminate;
        end
        else
            MessageDlg('Cannot open file ' + sFilename + ', does not exist.',mtInformation,[mbOk],0);

     except
           MessageDlg('Exception in CSV File Open',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TSCPForm.ValidateMarxan1Click(Sender: TObject);
var
   iCount : integer;
begin
     MarxanSystemTestForm := TMarxanSystemTestForm.Create(Application);
     MarxanSystemTestForm.ComboTestConfigurations.Items.Clear;
     for iCount := 0 to (MDIChildCount - 1) do
         if (MDIChildren[iCount].Tag = 4) then
            MarxanSystemTestForm.ComboTestConfigurations.Items.Add(MDIChildren[iCount].Caption);

     if (MarxanSystemTestForm.ComboTestConfigurations.Items.Count > 0) then
     begin
          MarxanSystemTestForm.ShowModal;
          MarxanSystemTestForm.ComboTestConfigurations.Text := MarxanSystemTestForm.ComboTestConfigurations.Items.Strings[0];
     end
     else
         MessageDlg('A csv file containing the planning unit configurations to test must be open.',mtInformation,[mbOk],0);

     MarxanSystemTestForm.Free;
end;

function TSCPForm.TransposeCSVChild(AChild : TCSVChild; const fReverseDataFields : boolean) : string;
var
   NewChild : TCSVChild;
   sTable : string;
   iColumnCount, iRowCount : integer;
begin
     try
        Screen.Cursor := crHourglass;

        // create a new child
        sTable := 'Table ' + IntToStr(MDIChildCount + 1);
        CreateCSVChild(sTable,0);
        Screen.Cursor := crHourglass;
        NewChild := TCSVChild(ReturnNamedChild(sTable));
        // set the dimensions of the new child
        NewChild.aGrid.RowCount := AChild.aGrid.ColCount;
        NewChild.aGrid.ColCount := AChild.aGrid.RowCount;
        NewChild.AGrid.Options := NewChild.AGrid.Options + [goColMoving];
        NewChild.lblDimensions.Caption := 'rows ' + IntToStr(NewChild.AGrid.RowCount) +
                                          ' fields ' + IntToStr(NewChild.AGrid.ColCount) +
                                          ' data elements ' + IntToStr(NewChild.AGrid.RowCount * NewChild.AGrid.ColCount);
        if (NewChild.aGrid.RowCount > 1) then
           NewChild.aGrid.FixedRows := 1;

        // populate the new child with cell values from the old child
        if fReverseDataFields then
        begin
             // map first column to header row
             for iRowCount := 0 to (AChild.aGrid.RowCount-1) do
                 NewChild.aGrid.Cells[iRowCount,0] := AChild.aGrid.Cells[0,iRowCount];

             // take column from input table and map to rows of output table, reversing their order
             for iRowCount := 0 to (AChild.aGrid.RowCount-1) do
                 for iColumnCount := 1 to (AChild.aGrid.ColCount-1) do
                     NewChild.aGrid.Cells[iRowCount,iColumnCount] := AChild.aGrid.Cells[(AChild.aGrid.ColCount-iColumnCount),iRowCount];
        end
        else
        begin
             for iColumnCount := 0 to (AChild.aGrid.ColCount-1) do
                 for iRowCount := 0 to (AChild.aGrid.RowCount-1) do
                     NewChild.aGrid.Cells[iRowCount,iColumnCount] := AChild.aGrid.Cells[iColumnCount,iRowCount];
        end;

        // generate a new filename for the transposed table and save it to file
        NewChild.Caption := ChangeFileExt(AChild.Caption,'_transpose.csv');
        SaveStringGrid2CSV(NewChild.aGrid,NewChild.Caption);

        Result := NewChild.Caption;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSCPForm.TransposeTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSCPForm.Transpose1Click(Sender: TObject);
var
   sNewTable : string;
begin
     if (ActiveMDIChild.Tag = 4) then
        sNewTable := SCPForm.TransposeCSVChild(TCSVChild(ActiveMDIChild),True);
end;

procedure TSCPForm.Save_ZCP_Project(const sFilename : string; const iGISChildIndex,iMarxanChildIndex : integer);
var
   AIni : TIniFile;
   iCount, iFontSize : integer;
   OutFile : TextFile;
   sTemp : string;
   TempColour : TColor;
   myExtents: MapWinGIS_TLB.Extents;
   xMin, yMin, zMin, xMax, yMax, zMax, mMin, mMax : Double;
   ALDO : LabelDisplayOption_T;
begin
     try
        assignfile(OutFile,sFilename);
        rewrite(OutFile);
        writeln(OutFile,'[GIS]');
        writeln(OutFile,'name='+GIS_Child.Caption);
        writeln(OutFile,'SelectionColour=' + TColourToHex(GIS_Child.SelectionColour));
        if ShapeOutlines1.Checked then
           writeln(OutFile,'ShapeOutlines=1')
        else
            writeln(OutFile,'ShapeOutlines=0');
        if (GIS_Child.Map1.CursorMode = cmZoomIn) then
           writeln(OutFile,'CursorMode=ZoomIn');
        if (GIS_Child.Map1.CursorMode = cmZoomOut) then
           writeln(OutFile,'CursorMode=ZoomOut');
        if (GIS_Child.Map1.CursorMode = cmPan) then
           writeln(OutFile,'CursorMode=Pan');
        if (GIS_Child.Map1.CursorMode = cmSelection) then
           writeln(OutFile,'CursorMode=Select');

        if (ZoomtoExtentonResize1.Checked) then
           writeln(OutFile,'ZoomToLayerOnResize=Yes');

        myExtents := IExtents(GIS_Child.Map1.Extents);
        myExtents.GetBounds(xMin, yMin, zMin, xMax, yMax, zMax);
        myExtents.GetMeasureBounds(mMin, mMax);
        writeln(OutFile,'Bounds_xMin=' + FloatToStr(xMin));
        writeln(OutFile,'Bounds_yMin=' + FloatToStr(yMin));
        writeln(OutFile,'Bounds_zMin=' + FloatToStr(zMin));
        writeln(OutFile,'Bounds_xMax=' + FloatToStr(xMax));
        writeln(OutFile,'Bounds_yMax=' + FloatToStr(yMax));
        writeln(OutFile,'Bounds_zMax=' + FloatToStr(zMax));
        writeln(OutFile,'Bounds_mMin=' + FloatToStr(mMin));
        writeln(OutFile,'Bounds_mMax=' + FloatToStr(mMax));

        if SCPForm.fMarxanActivated then
        begin
             writeln(OutFile,'SummedSolutionColour=' + TColourToHex(GIS_Child.SummedSolutionColour));
             writeln(OutFile,'pulayer='+GIS_Child.sPuFileName);
             writeln(OutFile,'KeyField='+MarxanInterfaceForm.ComboKeyField.Text);
             if (GIS_Child.Map1.NumLayers > 1) then
             begin
                  writeln(OutFile,'Layers='+IntToStr(GIS_Child.Map1.NumLayers));

                  for iCount := 0 to (GIS_Child.Map1.NumLayers-1) do
                  begin
                       sTemp := GIS_Child.Map1.LayerName[iCount];
                       writeln(OutFile,'Layer' + IntToStr(iCount+1) + '=' + sTemp);
                       writeln(OutFile,'Layer' + IntToStr(iCount+1) + 'Colour=' + TColourToHex(GIS_Child.Map1.ShapeLayerFillColor[iCount]));

                       if GIS_Child.CheckListBox1.Checked[iCount] then
                          writeln(OutFile,'Layer' + IntToStr(iCount+1) + 'Selected=1')
                       else
                           writeln(OutFile,'Layer' + IntToStr(iCount+1) + 'Selected=0');

                       if (pos('.shp',LowerCase(GIS_Child.Map1.LayerName[iCount])) > 0) then
                       begin
                            writeln(OutFile,'Layer' + IntToStr(iCount+1) +'Transparency=' + FloatToStr(GIS_Child.Map1.ShapeLayerFillTransparency[iCount]));

                            case IShapefile(GIS_Child.Map1.GetObject[iCount]).ShapefileType of
                                 SHP_POINT, SHP_POINTZ, SHP_POINTM :
                                     writeln(OutFile,'Layer' + IntToStr(iCount+1) +'Size=' +FloatToStr(GIS_Child.Map1.ShapeLayerPointSize[iCount]));
                                 SHP_POLYLINE, SHP_POLYLINEZ, SHP_POLYLINEM, SHP_POLYGON, SHP_POLYGONZ, SHP_POLYGONM :
                                     writeln(OutFile,'Layer' + IntToStr(iCount+1) +'Size=' +FloatToStr(GIS_Child.Map1.ShapeLayerLineWidth[iCount]));
                            end;

                            if fLabelDisplayOption then
                            begin
                                 LabelDisplayOption.rtnValue(iCount+1,@ALDO);
                                 if ALDO.fDisplayLabel then
                                 begin
                                      writeln(OutFile,'Layer' + IntToStr(iCount+1) + 'Label=' + ALDO.sField);
                                      writeln(OutFile,'Layer' + IntToStr(iCount+1) + 'LabelJustify=' + JustificationToString(ALDO.AJustify));

                                      if (fLayerFontSizeOption) then
                                      begin
                                           LayerFontSizeOption.rtnValue(iCount+1,@iFontSize);
                                           writeln(OutFile,'Layer' + IntToStr(iCount+1) + 'FontSize=' + IntToStr(iFontSize));
                                      end;
                                 end;
                            end;
                       end;
                  end;
             end;

             writeln(OutFile,'Zones=' + IntToStr(MarxanInterfaceForm.SingleSolutionColours.lMaxSize));
             for iCount := 1 to MarxanInterfaceForm.SingleSolutionColours.lMaxSize do
             begin
                  MarxanInterfaceForm.SingleSolutionColours.rtnValue(iCount,@TempColour);
                  writeln(OutFile,'Zone' + IntToStr(iCount) + 'Colour=' + TColourToHex(TempColour));
             end;

             writeln(OutFile);
             writeln(OutFile,'[Marxan]');
             writeln(OutFile,'name='+MarxanInterfaceForm.Name);
             writeln(OutFile,'input='+MarxanInterfaceForm.EditMarxanDatabasePath.Text);
             writeln(OutFile,'output='+MarxanInterfaceForm.ComboOutputToMap.Text);
             if HideMarxanConsole1.Checked then
                writeln(OutFile,'HideConsole=1')
             else
                 writeln(OutFile,'HideConsole=0');
             if DoClusterAnalysis1.Checked then
                writeln(OutFile,'ClusterAnalysis=1')
             else
                 writeln(OutFile,'ClusterAnalysis=0');
             writeln(OutFile);

             writeln(OutFile,'[Marxan Window]');
             if (MarxanInterfaceForm.WindowState = wsMinimized) then
                writeln(OutFile,'State=Minimized')
             else
             begin
                  if (MarxanInterfaceForm.WindowState = wsMaximized) then
                     writeln(OutFile,'State=Maximized')
                  else
                  begin
                       writeln(OutFile,'State=Normal');
                       writeln(OutFile,'Top='+IntToStr(MarxanInterfaceForm.Top));
                       writeln(OutFile,'Left='+IntToStr(MarxanInterfaceForm.Left));
                       writeln(OutFile,'Height='+IntToStr(MarxanInterfaceForm.Height));
                       writeln(OutFile,'Width='+IntToStr(MarxanInterfaceForm.Width));
                  end;
             end;
             writeln(OutFile);

             if fEditConfigurationsForm then
             begin
                  writeln(OutFile,'[Edit Configurations Window]');
                  writeln(OutFile,'Active=True');
                  writeln(OutFile,'Top='+IntToStr(EditConfigurationsForm.Top));
                  writeln(OutFile,'Left='+IntToStr(EditConfigurationsForm.Left));
                  writeln(OutFile,'Height='+IntToStr(EditConfigurationsForm.Height));
                  writeln(OutFile,'Width='+IntToStr(EditConfigurationsForm.Width));
                  writeln(OutFile);
             end;
        end
        else
        begin
             if (GIS_Child.Map1.NumLayers > 0) then
             begin
                  writeln(OutFile,'Layers='+IntToStr(GIS_Child.Map1.NumLayers));

                  for iCount := 0 to (GIS_Child.Map1.NumLayers-1) do
                  begin
                       sTemp := GIS_Child.Map1.LayerName[iCount];
                       writeln(OutFile,'Layer' + IntToStr(iCount+1) + '=' + sTemp);
                       writeln(OutFile,'Layer' + IntToStr(iCount+1) + 'Colour=' + TColourToHex(GIS_Child.Map1.ShapeLayerFillColor[iCount]));

                       if GIS_Child.CheckListBox1.Checked[iCount] then
                          writeln(OutFile,'Layer' + IntToStr(iCount+1) + 'Selected=1')
                       else
                           writeln(OutFile,'Layer' + IntToStr(iCount+1) + 'Selected=0');

                       if (pos('.shp',LowerCase(GIS_Child.Map1.LayerName[iCount])) > 0) then
                       begin
                            writeln(OutFile,'Layer' + IntToStr(iCount+1) +'Transparency=' + FloatToStr(GIS_Child.Map1.ShapeLayerFillTransparency[iCount]));

                            case IShapefile(GIS_Child.Map1.GetObject[iCount]).ShapefileType of
                                 SHP_POINT, SHP_POINTZ, SHP_POINTM :
                                     writeln(OutFile,'Layer' + IntToStr(iCount+1) +'Size=' +FloatToStr(GIS_Child.Map1.ShapeLayerPointSize[iCount]));
                                 SHP_POLYLINE, SHP_POLYLINEZ, SHP_POLYLINEM, SHP_POLYGON, SHP_POLYGONZ, SHP_POLYGONM :
                                     writeln(OutFile,'Layer' + IntToStr(iCount+1) +'Size=' +FloatToStr(GIS_Child.Map1.ShapeLayerLineWidth[iCount]));
                            end;

                            if fLabelDisplayOption then
                            begin
                                 LabelDisplayOption.rtnValue(iCount+1,@ALDO);
                                 if ALDO.fDisplayLabel then
                                 begin
                                      writeln(OutFile,'Layer' + IntToStr(iCount+1) + 'Label=' + ALDO.sField);
                                      writeln(OutFile,'Layer' + IntToStr(iCount+1) + 'LabelJustify=' + JustificationToString(ALDO.AJustify));

                                      if (fLayerFontSizeOption) then
                                      begin
                                           LayerFontSizeOption.rtnValue(iCount+1,@iFontSize);
                                           writeln(OutFile,'Layer' + IntToStr(iCount+1) + 'FontSize=' + IntToStr(iFontSize));
                                      end;
                                 end;
                            end;
                       end;
                  end;
             end;
        end;

        if SCPForm.feFlowsActivated then
        begin
             writeln(OutFile,'pulayer='+GIS_Child.sPuFileName);
             writeln(OutFile,'KeyField='+eFlowsForm.seFlowsKeyField);
             writeln(OutFile);
             writeln(OutFile,'[eFlows]');
             writeln(OutFile,'name='+eFlowsForm.Name);
             writeln(OutFile,'input='+eFlowsForm.EditeFlowSpreadsheetPathName.Text);
             writeln(OutFile,'output='+eFlowsForm.ComboOutputToMap.Text);
             if HideExcelInterface1.Checked then
                writeln(OutFile,'HideExcelInterface=1')
             else
                 writeln(OutFile,'HideExcelInterface=0');
             if SaveXLSonexit1.Checked then
                writeln(OutFile,'SaveXLSOnExit=1')
             else
                 writeln(OutFile,'SaveXLSOnExit=0');
             writeln(OutFile);

             writeln(OutFile,'[eFlows Window]');
             if (eFlowsForm.WindowState = wsMinimized) then
                writeln(OutFile,'State=Minimized')
             else
             begin
                  if (eFlowsForm.WindowState = wsMaximized) then
                     writeln(OutFile,'State=Maximized')
                  else
                  begin
                       writeln(OutFile,'State=Normal');
                       writeln(OutFile,'Top='+IntToStr(eFlowsForm.Top));
                       writeln(OutFile,'Left='+IntToStr(eFlowsForm.Left));
                       writeln(OutFile,'Height='+IntToStr(eFlowsForm.Height));
                       writeln(OutFile,'Width='+IntToStr(eFlowsForm.Width));
                  end;
             end;
        end;

        writeln(OutFile);

        if (sDDEPULayer <> '') then
        begin
             writeln(OutFile,'[DDE]');

             if (sDDEName <> '') then
                writeln(OutFile,'Name='+sDDEName);

             writeln(OutFile,'PULayer='+sDDEPULayer);

             if (sDDEPUKey <> '') then
                writeln(OutFile,'PUKey='+sDDEPUKey);

             if (sDDESourceTable <> '') then
                writeln(OutFile,'SourceTable='+sDDESourceTable);

             if (sDDESourceKey <> '') then
                writeln(OutFile,'SourceKey='+sDDESourceKey);

             writeln(OutFile);
        end;

        writeln(OutFile,'[ZC Window]');
        writeln(OutFile,'Top='+IntToStr(Top));
        writeln(OutFile,'Left='+IntToStr(Left));
        writeln(OutFile,'Height='+IntToStr(Height));
        writeln(OutFile,'Width='+IntToStr(Width));
        writeln(OutFile);

        writeln(OutFile,'[GIS Window]');
        if (GIS_Child.WindowState = wsMinimized) then
           writeln(OutFile,'State=Minimized')
        else
        begin
             if (GIS_Child.WindowState = wsMaximized) then
                writeln(OutFile,'State=Maximized')
             else
             begin
                  writeln(OutFile,'State=Normal');
                  writeln(OutFile,'Top='+IntToStr(GIS_Child.Top));
                  writeln(OutFile,'Left='+IntToStr(GIS_Child.Left));
                  writeln(OutFile,'Height='+IntToStr(GIS_Child.Height));
                  writeln(OutFile,'Width='+IntToStr(GIS_Child.Width));
             end;
        end;

        closefile(OutFile);

     except
           MessageDlg('Exception in Save ZC Project',mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TSCPForm.Save1Click(Sender: TObject);
var
   iGISChildIndex, iMarxanChildIndex : integer;
begin
     if (MDIChildCount > 0) then
        case ActiveMDIChild.Tag of
             1,2,6,7 :
                 begin
                      iGISChildIndex := ReturnGISChildIndex;
                      iMarxanChildIndex := ReturnMarxanChildIndex;

                      if (iGISChildIndex > -1) then
                      begin
                           SaveDialog1.Filter := 'Zonae Congito project (*.zcp)|*.zcp';
                           if SaveDialog1.Execute then
                           begin // save a ZC project to file
                                Save_ZCP_Project(SaveDialog1.Filename,iGISChildIndex,iMarxanChildIndex);
                                UpdateRecent(SaveDialog1.Filename);
                           end;
                      end;
                 end;
             3 : begin
                      SaveDialog1.Filter := 'dBase Table (*.dbf)|*.dbf';
                      if SaveDialog1.Execute then
                      begin // save a table to a dbf file
                           TDBFChild(ActiveMDIChild).SaveDBFChild2DBF(SaveDialog1.Filename);
                           ActiveMDIChild.Caption := SaveDialog1.Filename;
                           UpdateRecent(SaveDialog1.Filename);
                      end;
                 end;
             4 : begin
                      SaveDialog1.Filter := 'Comma Delimited Ascii (*.csv)|*.csv';
                      if SaveDialog1.Execute then
                      begin // save a table to a csv file
                           SaveStringGrid2CSV(TCSVChild(ActiveMDIChild).aGrid,SaveDialog1.Filename);
                           ActiveMDIChild.Caption := SaveDialog1.Filename;
                           UpdateRecent(SaveDialog1.Filename);
                      end;
                 end;
        end;
end;

procedure TSCPForm.BuildNewMarxanDatabase1Click(Sender: TObject);
begin
     BuildChild := TBuildChild.Create(Application);
     BuildChild.ResizeTheForm;
     BuildChild.Show;
end;

procedure TSCPForm.AddShape1Click(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
        with TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]) do
        begin
             if OpenTheme.Execute then
                AddShape(OpenTheme.Filename);
        end;
end;

procedure TSCPForm.RemoveAllShapes1Click(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
        with TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]) do
             if (MessageDlg('Are you sure you want to remove all shapes?',mtConfirmation,[mbYes,mbNo],0) = mrYes) then
                Map1.RemoveAllLayers;
end;

procedure TSCPForm.Extent1Click(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
        TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]).ZoomTo(0);
end;

procedure TSCPForm.Layer1Click(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
        TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]).ZoomTo(1);
end;

procedure TSCPForm.Previous1Click(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
        TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]).ZoomTo(2);
end;

procedure TSCPForm.ZoomIn1Click(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
        TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]).ChangeMode(0);
end;

procedure TSCPForm.ZoomOut1Click(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
        TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]).ChangeMode(1);
end;

procedure TSCPForm.Pan2Click(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
        TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]).ChangeMode(2);
end;

procedure TSCPForm.Select1Click(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
        TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]).ChangeMode(3);
end;

procedure TSCPForm.Mouse1Click(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
        TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]).ChangeMode(3);
end;

procedure TSCPForm.UnlockDebug(const sChar : string);
begin
     sKeyInput := sKeyInput + sChar;

     if (sKeyInput = 'debug') then
     begin
          sKeyInput := '';
          eFlows1.Visible := True;
          BuildBoundaryLengthFile1.Visible := True;
     end;

     if (Pos('off',sKeyInput) > 0) then
     //if (sKeyInput = 'off') then
     begin
          sKeyInput := '';
          eFlows1.Visible := False;
          BuildBoundaryLengthFile1.Visible := False;
          Image1.Visible := False;
          Image2.Visible := False;

          fDisplayeFlowsGUI := False;
     end;

     if (Pos('eflows',lowercase(sKeyInput)) > 0) then
     begin
          fDisplayeFlowsGUI := True;
     end;

     Nexion;
end;

procedure TSCPForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
     UnlockDebug(Key);
end;

procedure TSCPForm.Inclusion1Click(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
     begin
          TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]).ChangeMode(3);
          Intersection1.Checked := False;
          Inclusion1.Checked := True;
     end;
end;

procedure TSCPForm.Intersection1Click(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
     begin
          TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]).ChangeMode(3);
          Intersection1.Checked := True;
          Inclusion1.Checked := False;
     end;
end;

procedure TSCPForm.ClearSelection1Click(Sender: TObject);
var
   iGISChildIndex, iMarxanChildIndex : integer;
   GChild : TGIS_Child;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
     begin
          GChild := TGIS_Child(MDIChildren[iGISChildIndex]);

          if GIS_Child.fShapeSelection then
          begin
               GIS_Child.ShapeSelection.Destroy;
               GIS_Child.fShapeSelection := False;

               iMarxanChildIndex := ReturnMarxanChildIndex;
               if (iMarxanChildIndex > -1) then
                  MarxanInterfaceForm.RefreshGISDisplay;

               if (SCPForm.feFlowsActivated) then
                  eFlowsForm.RefreshGISDisplay;
          end;
     end;
end;

procedure TSCPForm.FormActivate(Sender: TObject);
begin
     SwitchChildFocus;
end;

procedure TSCPForm.BrowseMarxanDataset1Click(Sender: TObject);
var
   iMarxanChildIndex : integer;
begin
     iMarxanChildIndex := ReturnMarxanChildIndex;
     if (iMarxanChildIndex > -1) then
        TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).btnBrowseDatabaseClick(Sender);
end;

procedure TSCPForm.RunMarxan1Click(Sender: TObject);
var
   iMarxanChildIndex : integer;
begin
     iMarxanChildIndex := ReturnMarxanChildIndex;
     if (iMarxanChildIndex > -1) then
        TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).ButtonUpdateClick(Sender);
end;

procedure TSCPForm.SaveRun1Click(Sender: TObject);
var
   iMarxanChildIndex : integer;
begin
     iMarxanChildIndex := ReturnMarxanChildIndex;
     if (iMarxanChildIndex > -1) then
        TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).ButtonSaveClick(Sender);
end;

procedure TSCPForm.LoadRun1Click(Sender: TObject);
var
   iMarxanChildIndex : integer;
begin
     iMarxanChildIndex := ReturnMarxanChildIndex;
     if (iMarxanChildIndex > -1) then
        TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).ButtonLoadClick(Sender);
end;

procedure TSCPForm.RunCalibration1Click(Sender: TObject);
var
   iMarxanChildIndex : integer;
begin
     iMarxanChildIndex := ReturnMarxanChildIndex;
     if (iMarxanChildIndex > -1) then
        TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).ExecuteCalibration;
end;

procedure TSCPForm.DisplayMarxanCalibrationReport;
var
   iMarxanChildIndex : integer;
   sFilename : string;
begin
     iMarxanChildIndex := ReturnMarxanChildIndex;
     if (iMarxanChildIndex > -1) then
     begin
          sFilename := ExtractFilePath(TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).EditMarxanDatabasePath.Text) +
                       TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).ReturnMarxanParameter('OUTPUTDIR') +
                       '\calibrate.csv';

          if fileexists(sFilename) then
          begin
               CreateCSVChild(sFilename,0);

               AutoFitCSVChild(True);
          end;
     end;
end;

procedure TSCPForm.CalibrationReport1Click(Sender: TObject);
begin
     DisplayMarxanCalibrationReport;
end;

procedure TSCPForm.DisplayMarxanSummaryReport;
var
   iMarxanChildIndex : integer;
   sFilename : string;
begin
     iMarxanChildIndex := ReturnMarxanChildIndex;
     if (iMarxanChildIndex > -1) then
     begin
          sFilename := ExtractFilePath(TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).EditMarxanDatabasePath.Text) +
                       TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).ReturnMarxanParameter('OUTPUTDIR') +
                       '\' +
                       TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).ReturnMarxanParameter('SCENNAME') +
                       '_sum.txt';

          if not fileexists(sFilename) then
             sFilename := ExtractFilePath(TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).EditMarxanDatabasePath.Text) +
                          TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).ReturnMarxanParameter('OUTPUTDIR') +
                          '\' +
                          TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).ReturnMarxanParameter('SCENNAME') +
                          '_sum.csv';

          if fileexists(sFilename) then
          begin
               CreateCSVChild(sFilename,0);

               AutoFitCSVChild(True);
          end;
     end;
end;

procedure TSCPForm.DisplayBestSolutionFeaturesReport;
var
   iMarxanChildIndex : integer;
   sFilename : string;
   A_CSVChild : TCSVChild;
begin
     iMarxanChildIndex := ReturnMarxanChildIndex;
     if (iMarxanChildIndex > -1) then
     begin
          sFilename := ExtractFilePath(TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).EditMarxanDatabasePath.Text) +
                       TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).ReturnMarxanParameter('OUTPUTDIR') +
                       '\' +
                       TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).ReturnMarxanParameter('SCENNAME') +
                       '_mvbest.txt';

          if not fileexists(sFilename) then
             sFilename := ExtractFilePath(TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).EditMarxanDatabasePath.Text) +
                          TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).ReturnMarxanParameter('OUTPUTDIR') +
                          '\' +
                          TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).ReturnMarxanParameter('SCENNAME') +
                          '_mvbest.csv';

          if fileexists(sFilename) then
          begin
               A_CSVChild := CreateCSVChild(sFilename,2);

               AutoFitCSVChild(True);
          end;
     end;
end;

procedure TSCPForm.SummaryReport1Click(Sender: TObject);
begin
     DisplayMarxanSummaryReport;
end;

procedure TSCPForm.AutoFitCSVChild(const fFitEntireGrid : boolean);
begin
     if (ActiveMDIChild.Tag = 4) then
        if fileexists(TCSVChild(ActiveMDIChild).Caption) then
            AutoFitGrid(TCSVChild(ActiveMDIChild).aGrid,
                        TCSVChild(ActiveMDIChild).Canvas,
                        fFitEntireGrid);
end;

procedure TSCPForm.EntireTable1Click(Sender: TObject);
begin
     AutoFitCSVChild(True);
end;

procedure TSCPForm.Selection3Click(Sender: TObject);
begin
     AutoFitCSVChild(False);
end;

procedure TSCPForm.Query1Click(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
     begin
          MapQueryForm := TMapQueryForm.Create(Application);
          MapQueryForm.PrepareQueryForm(TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]));
          MapQueryForm.ShowModal;
          MapQueryForm.Free;
     end;
end;

procedure TSCPForm.InvertSelection1Click(Sender: TObject);
var
   iGISChildIndex, iMarxanChildIndex, iCount : integer;
   GChild : TGIS_Child;
   fSelected : boolean;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
     begin
          GChild := TGIS_Child(MDIChildren[iGISChildIndex]);

          if GChild.fShapeSelection then
          begin
               for iCount := 1 to GChild.ShapeSelection.lMaxSize do
               begin
                    GChild.ShapeSelection.rtnValue(iCount,@fSelected);

                    fSelected := not fSelected;

                    GChild.ShapeSelection.setValue(iCount,@fSelected);
               end;

               iMarxanChildIndex := ReturnMarxanChildIndex;
               if (iMarxanChildIndex > -1) then
                  GIS_Child.RedrawSelection;
          end;
     end;
end;

procedure TSCPForm.SetZoomPercentage1Click(Sender: TObject);
var
   iGISChildIndex : integer;
   GChild : TGIS_Child;
   sPercentage, sReturn : string;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
     begin
          GChild := TGIS_Child(MDIChildren[iGISChildIndex]);

          sPercentage := FloatToStr(GChild.Map1.ZoomPercent * 100);

          sReturn := InputBox('Enter New Zoom Percentage','Percentage',sPercentage);

          if (sReturn <> sPercentage) then
             try
                GChild.Map1.ZoomPercent := StrToFloat(sPercentage) / 100;
             except
             end;
     end;
end;

procedure TSCPForm.Colour1Click(Sender: TObject);
begin
     EditMarxanMapColours(0);
end;

procedure TSCPForm.EditMarxanMapColours(iItemIndex : integer);
var
   iGISChildIndex, iMarxanChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     iMarxanChildIndex := ReturnMarxanChildIndex;
     if (iGISChildIndex > -1) and (iMarxanChildIndex > -1) then
     begin
          MarxanLegendEditorForm := TMarxanLegendEditorForm.Create(Application);

          MarxanLegendEditorForm.GChild := TGIS_Child(MDIChildren[iGISChildIndex]);
          MarxanLegendEditorForm.MChild := TMarxanInterfaceForm(MDIChildren[iMarxanChildIndex]);
          MarxanLegendEditorForm.PrepareForm;
          MarxanLegendEditorForm.RadioType.ItemIndex := iItemIndex;

          MarxanLegendEditorForm.ShowModal;
          MarxanLegendEditorForm.Free;
     end;
end;

procedure TSCPForm.ChangeStatus1Click(Sender: TObject);
var
   iGISChildIndex, iMarxanChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     iMarxanChildIndex := ReturnMarxanChildIndex;
     if (iGISChildIndex > -1) and (iMarxanChildIndex > -1) then
        if TGIS_Child(MDIChildren[iGISChildIndex]).fShapeSelection then
        begin
             ChangeStatusForm := TChangeStatusForm.Create(Application);

             ChangeStatusForm.GChild := TGIS_Child(MDIChildren[iGISChildIndex]);
             ChangeStatusForm.MChild := TMarxanInterfaceForm(MDIChildren[iMarxanChildIndex]);
             ChangeStatusForm.PrepareForm;

             ChangeStatusForm.ShowModal;
             ChangeStatusForm.Free;
        end;
end;

procedure TSCPForm.Savenonzerorowsandcolumns1Click(Sender: TObject);
var
   iCSVChildIndex : integer;
begin
     iCSVChildIndex := ReturnCSVTableChildIndex;
     if (iCSVChildIndex > -1) then
         if SaveCSV.Execute then
            TCSVChild(SCPForm.MDIChildren[iCSVChildIndex]).SaveNonZeroRowsAndColumns(SaveCSV.FileName);
end;

procedure TSCPForm.InputEditor1Click(Sender: TObject);
var
   iMarxanChildIndex : integer;
begin
     iMarxanChildIndex := ReturnMarxanChildIndex;
     if (iMarxanChildIndex > -1) then
     begin
           InEditForm := TInEditForm.Create(Application);
           InEditForm.LoadFile2(TMarxanInterfaceForm(MDIChildren[iMarxanChildIndex]).EditMarxanDatabasePath.Text);
           InEditForm.ShowModal;
           InEditForm.Free;
     end;
end;

procedure TSCPForm.R1Click(Sender: TObject);
var
   sR_Install_Path, sR_Exe_File : string;
begin
     //
     sR_Install_Path := Return_R_InstallPath;
     sR_Exe_File := sR_Install_Path + '\bin\Rgui.exe';

     if f64BitOS then
     begin
          if fileexists(sR_Install_Path + '\bin\x64\Rgui.exe') then
             sR_Exe_File := sR_Install_Path + '\bin\x64\Rgui.exe';
     end
     else
     begin
          if not fileexists(sR_Exe_File) then
             sR_Exe_File := sR_Install_Path + '\bin\i386\Rgui.exe';
     end;

     if (sR_Install_Path = '') and fileexists(sR_Exe_File) then
        MessageDlg('R is not installed.',mtInformation,[mbOk],0)
     else
         ProgramRunWait(sR_Exe_File,
                        '',
                        False,
                        True);

     //R_Form := TR_Form.Create(Application);
     //R_Form.ShowModal;
     //R_Form.Free;
end;

procedure TSCPForm.BestSolutionFeatures1Click(Sender: TObject);
begin
     DisplayBestSolutionFeaturesReport;
end;

procedure TSCPForm.ZoomtoExtentonResize1Click(Sender: TObject);
begin
     ZoomtoExtentonResize1.Checked := not ZoomtoExtentonResize1.Checked;
end;

procedure TSCPForm.Validation1Click(Sender: TObject);
begin
     // display form and select parameters for validation

     // set marxan parameters to create validation output
     // run marxan
     // run validation analysis

     ValidationParamForm := TValidationParamForm.Create(Application);
     ValidationParamForm.ShowModal;
     ValidationParamForm.Free;
end;

procedure TSCPForm.GraphTable1Click(Sender: TObject);
begin
     try
        GraphSelectorForm := TGraphSelectorForm.Create(Application);
        GraphSelectorForm.ShowModal;
        GraphSelectorForm.Free;

     except
           MessageDlg('Exception in TSCPForm.GraphTable1Click',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TSCPForm.FormCreate(Sender: TObject);
begin
     Randomize;
     sRestoreProjectFileName := '';
     sDDESourceTable := '';
     sDDESourceKey := '';
     sDDEPULayer := '';
     sDDEPUKey := '';
     sDDEName := '';
     sReportConfigurationsFileName := '';
     fMarxanActivated := False;
     feFlowsActivated := False;
     fCPlanSelectDDELink := False;
     fEditConfigurationsForm := False;

     fTransparencyStored := False;

     UpdateRecent('');

     if (sParameterCalled <> '') then
        FileOpen(sParameterCalled);

     Caption := 'Zonae Cogito ' + sVersionString;

     f64BitOS := Detect64BitOS;
     fMarZone := False;

     sKeyInput := '';
     KeyPreview := True;

     fLabelDisplayOption := False;
     fLayerSizeOption := False;
     fLayerFontSizeOption := False;

     fDisplayeFlowsGUI := fDisplayeFlowsGUI_Default;
end;

procedure TSCPForm.HideMarxanConsole1Click(Sender: TObject);
begin
     HideMarxanConsole1.Checked := not HideMarxanConsole1.Checked;
end;

procedure TSCPForm.ShapeOutlines1Click(Sender: TObject);
var
   iCount : integer;
begin
     ShapeOutlines1.Checked := not ShapeOutlines1.Checked;
     GIS_Child.ComboOutputToMapChange(Sender);
end;

procedure TSCPForm.Marxan3Click(Sender: TObject);
var
   iMarxanChildIndex : integer;
begin
     iMarxanChildIndex := ReturnMarxanChildIndex;
     if (iMarxanChildIndex > -1) then
     begin
          SCPForm.MDIChildren[iMarxanChildIndex].BringToFront;

          if (SCPForm.MDIChildren[iMarxanChildIndex].WindowState = wsMinimized) then
             SCPForm.MDIChildren[iMarxanChildIndex].WindowState := wsNormal;
     end;
end;

procedure TSCPForm.GIS4Click(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
     begin
          SCPForm.MDIChildren[iGISChildIndex].BringToFront;

          if (SCPForm.MDIChildren[iGISChildIndex].WindowState = wsMinimized) then
             SCPForm.MDIChildren[iGISChildIndex].WindowState := wsNormal;
     end;
end;

procedure TSCPForm.AdaptiveCalibrationFPF1Click(Sender: TObject);
begin
     AdaptiveCalibrationForm := TAdaptiveCalibrationForm.Create(Application);
     AdaptiveCalibrationForm.Show;
end;

procedure TSCPForm.SummariseFeaturesMPM1Click(Sender: TObject);
var
   sOutputFile : string;
begin
     // summarise the Minimum Proportion Met across all our runs for all our features.
     sOutputFile := '';
     MarxanInterfaceForm.SummariseFeaturesMPM(sOutputFile);

     // display the CSV table
     if fileexists(sOutputFile) then
     begin
          CreateCSVChild(sOutputFile,0);

          AutoFitCSVChild(True);
     end;            
end;

procedure TSCPForm.DoClusterAnalysis1Click(Sender: TObject);
begin
     DoClusterAnalysis1.Checked := not DoClusterAnalysis1.Checked;
end;

procedure TSCPForm.New1Click(Sender: TObject);
begin
     // launch a new zonae cogito window
     ProgramRunWait(Application.ExeName,
                    '',
                    False,
                    True);      
end;

procedure TSCPForm.Recent1Click(Sender: TObject);
begin
     FileOpen(Recent1.Caption);
end;

procedure TSCPForm.Recent2Click(Sender: TObject);
begin
     FileOpen(Recent2.Caption);
end;

procedure TSCPForm.Recent3Click(Sender: TObject);
begin
     FileOpen(Recent3.Caption);
end;

procedure TSCPForm.Recent4Click(Sender: TObject);
begin
     FileOpen(Recent4.Caption);
end;

procedure TSCPForm.Recent5Click(Sender: TObject);
begin
     FileOpen(Recent5.Caption);
end;

procedure TSCPForm.Recent6Click(Sender: TObject);
begin
     FileOpen(Recent6.Caption);
end;

procedure TSCPForm.Recent7Click(Sender: TObject);
begin
     FileOpen(Recent7.Caption);
end;

procedure TSCPForm.Recent8Click(Sender: TObject);
begin
     FileOpen(Recent8.Caption);
end;

procedure TSCPForm.Recent9Click(Sender: TObject);
begin
     FileOpen(Recent9.Caption);
end;

procedure TSCPForm.Recent10Click(Sender: TObject);
begin
     FileOpen(Recent10.Caption);
end;

procedure TSCPForm.Recent11Click(Sender: TObject);
begin
     FileOpen(Recent11.Caption);
end;

procedure TSCPForm.Recent12Click(Sender: TObject);
begin
     FileOpen(Recent12.Caption);
end;

procedure TSCPForm.Recent13Click(Sender: TObject);
begin
     FileOpen(Recent13.Caption);
end;

procedure TSCPForm.Recent14Click(Sender: TObject);
begin
     FileOpen(Recent14.Caption);
end;

procedure TSCPForm.Recent15Click(Sender: TObject);
begin
     FileOpen(Recent15.Caption);
end;

procedure TSCPForm.Recent16Click(Sender: TObject);
begin
     FileOpen(Recent16.Caption);
end;

procedure TSCPForm.Recent17Click(Sender: TObject);
begin
     FileOpen(Recent17.Caption);
end;

procedure TSCPForm.Recent18Click(Sender: TObject);
begin
     FileOpen(Recent18.Caption);
end;

procedure TSCPForm.Recent19Click(Sender: TObject);
begin
     FileOpen(Recent19.Caption);
end;

procedure TSCPForm.Recent20Click(Sender: TObject);
begin
     FileOpen(Recent20.Caption);
end;

procedure TSCPForm.RecentMoreClick(Sender: TObject);
begin
     RecentMoreForm := TRecentMoreForm.Create(Application);
     RecentMoreForm.ShowModal;
     RecentMoreForm.Free;
end;

function TSCPForm.GenerateAndRunRScripts : boolean;
var
   iMarxanChildIndex : integer;
   sR_Install_Path, sR_Exe_File, sCommand, sCmdFileName, sR_script_file, sSaveName, sSolutionsFileName : string;
   CmdFile : TextFile;
   fResult : boolean;
begin
     fResult := True;
     iMarxanChildIndex := ReturnMarxanChildIndex;
     if (iMarxanChildIndex > -1) then
     begin
          sR_Install_Path := Return_R_InstallPath;

          sSaveName := ExtractFilePath(TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).EditMarxanDatabasePath.Text) +
                       TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).ReturnMarxanParameter('OUTPUTDIR') + '\' +
                       TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).ReturnMarxanParameter('SCENNAME');

          sR_script_file := sSaveName + '_script.R';
          //sR_script_file := ExtractFilePath(TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).EditMarxanDatabasePath.Text) +
          //                  'script.R';
          sR_Exe_File := sR_Install_Path + '\bin\R.exe';

          if f64BitOS then
          begin
               if fileexists(sR_Install_Path + '\bin\x64\R.exe') then
                  sR_Exe_File := sR_Install_Path + '\bin\x64\R.exe';
          end
          else
          begin
               if not fileexists(sR_Exe_File) then
                  sR_Exe_File := sR_Install_Path + '\bin\i386\R.exe';
          end;


          sCommand := 'type "' +
                      sR_script_file +
                      '" | "' +
                      sR_Exe_File +
                      '" --slave --vanilla';

          sCmdFileName := sSaveName + '_scriptR.bat';
          //sCmdFileName := ExtractFilePath(TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).EditMarxanDatabasePath.Text) +
          //                'scriptR.bat';
          assignfile(CmdFile,sCmdFileName);
          rewrite(CmdFile);
          writeln(CmdFile,sCommand);
          closefile(CmdFile);

          sSolutionsFileName := '_solutionsmatrix.csv';

          TMarxanInterfaceForm(SCPForm.MDIChildren[iMarxanChildIndex]).Create_R_Script(sR_script_file,sSolutionsFileName,sSaveName,3);

          if (sR_Install_Path <> '') then
          begin
               if fileexists(sR_Exe_File)
               and fileexists(sR_script_file)
               and fileexists(sSaveName + sSolutionsFileName) then
                   ProgramRunWait(sCmdFileName,
                                  '',
                                  False,
                                  True);
          end
          else
          begin
               fResult := False;
               MessageDlg('R is not installed.',mtInformation,[mbOk],0);
          end;
     end;

     Result := fResult;
end;

procedure TSCPForm.RunRScripts1Click(Sender: TObject);
begin
     GenerateAndRunRScripts;
end;

procedure TSCPForm.GenerateAllConfigurations1Click(Sender: TObject);
begin
     SaveDialog1.Filter := 'Comma Delimited Ascii (*.csv)|*.csv';
     if SaveDialog1.Execute then
     begin // save a table to a csv file
          MarxanInterfaceForm.GenerateAllConfigurations(SaveDialog1.Filename);
          UpdateRecent(SaveDialog1.Filename);
     end;
end;

procedure TSCPForm.TransposeCSV1Click(Sender: TObject);
var
   sNewTable : string;
begin
     if (ActiveMDIChild.Tag = 4) then
        sNewTable := SCPForm.TransposeCSVChild(TCSVChild(ActiveMDIChild),False);
end;


procedure TSCPForm.SetDDEName(const sName : string);
begin
     sDDEName := sName;
end;

procedure TSCPForm.SetDDEProject(const sProject : string);
var
   iGISChildIndex : integer;
begin
     if (sProject <> '') then
        if FileExists(sProject) then
        begin
             FileOpen(sProject);

             iGISChildIndex := ReturnGISChildIndex;
             if (iGISChildIndex = -1) then
                TGIS_Child(MDIChildren[iGISChildIndex]).iDDEPULayerHandle := 0
        end;
end;

procedure TSCPForm.SetDDESaveProject(const sProject : string);
var
   iGISChildIndex, iMarxanChildIndex : integer;
begin
     iGISChildIndex := ReturnGISChildIndex;
     iMarxanChildIndex := ReturnMarxanChildIndex;

     if (iGISChildIndex > -1) then
     begin
          Save_ZCP_Project(sProject,iGISChildIndex,iMarxanChildIndex);
          TGIS_Child(MDIChildren[iGISChildIndex]).Close;
     end;
end;

procedure TSCPForm.SetDDESourceTable(const sSourceTable : string);
begin
     sDDESourceTable := sSourceTable;
end;

procedure TSCPForm.SetDDESourceKey(const sSourceKey : string);
begin
     sDDESourceKey := sSourceKey;
end;

procedure TSCPForm.SetDDEPULayer(const sPULayer : string);
var
   iGISChildIndex : integer;
begin
     try
        sDDEPULayer := sPULayer;

        // if a GIS window is not open, open one and maximise it
        iGISChildIndex := ReturnGISChildIndex;
        if (iGISChildIndex = -1) then
        begin
             FileOpen(sDDEPULayer);
             iGISChildIndex := ReturnGISChildIndex;
             TGIS_Child(MDIChildren[iGISChildIndex]).WindowState := wsMaximized;
             if (sDDEName <> '') then
                TGIS_Child(MDIChildren[iGISChildIndex]).Caption := sDDEName;

             TGIS_Child(MDIChildren[iGISChildIndex]).iDDEPULayerHandle := 0;
        end;

     except
     end;
end;

procedure TSCPForm.SetDDEPUKey(const sPUKey : string);
begin
     sDDEPUKey := sPUKey;
end;


procedure TSCPForm.DDERedrawMap(const sParameters : string);
var
   iGISChildIndex : integer;
begin
     try
        iGISChildIndex := ReturnGISChildIndex;
        if (iGISChildIndex > -1) then
           TGIS_Child(MDIChildren[iGISChildIndex]).UpdateDDEMap;

     except
           //MessageDlg('Exception in DDEUpdateGIS',mtError,[mbOk],0);
     end;
end;

procedure TSCPForm.DDEUpdateGIS(const sParameters : string);
var
   iGISChildIndex : integer;
begin
     try
        // if a GIS window is not open, open one and maximise it
        iGISChildIndex := ReturnGISChildIndex;
        if (iGISChildIndex = -1) then
        begin
             FileOpen(sDDEPULayer);
             iGISChildIndex := ReturnGISChildIndex;
             TGIS_Child(MDIChildren[iGISChildIndex]).WindowState := wsMaximized;
             if (sDDEName <> '') then
                TGIS_Child(MDIChildren[iGISChildIndex]).Caption := sDDEName;
        end;

        // display DDE output in the GIS
        if (iGISChildIndex > -1) then
        begin
             TGIS_Child(MDIChildren[iGISChildIndex]).UpdateDDETable;
             TGIS_Child(MDIChildren[iGISChildIndex]).UpdateDDEMap;
        end;

     except
           //MessageDlg('Exception in DDEUpdateGIS',mtError,[mbOk],0);
     end;
end;

procedure AppendDDECommandLog(const sLine : string);
var
   sLogFileName : string;
   LogFile : TextFile;
begin
     try
        sLogFileName := ExtractFilePath(Application.ExeName) + 'DDECommands.csv';
        if fileexists(sLogFileName) then
        begin
             assignfile(LogFile,sLogFileName);
             append(LogFile)
        end
        else
        begin
             assignfile(LogFile,sLogFileName);
             rewrite(LogFile);
             writeln(LogFile,'Date,Time,Command');
        end;
        writeln(LogFile,DateToStr(Date) + ',' + TimeToStr(Time) + ',' + sLine);
        closefile(LogFile);

     except
     end;
end;

procedure TSCPForm.ZCServerConvExecuteMacro(Sender: TObject; Msg: TStrings);
var
   sParameter, sCommand : string;
   iPos : integer;
begin
     try
        // Handles commands passed from other applications with DDE.
        AppendDDECommandLog(Msg.Strings[0]);

        iPos := Pos(' ',Msg.Strings[0]);
        sCommand := Copy(Msg.Strings[0],1,iPos-1);
        sParameter := Copy(Msg.Strings[0],iPos+1,Length(Msg.Strings[0])-iPos);

        if (sCommand = 'InformGIS') then
           DDEUpdateGIS(sParameter);

        if (sCommand = 'redrawmap') then
           DDERedrawMap(sParameter);

        if (sCommand = 'name') then
           SetDDEName(sParameter);

        if (sCommand = 'project') then
           SetDDEProject(sParameter);

        if (sCommand = 'saveproject') then
           SetDDESaveProject(sParameter);

        if (sCommand = 'sourcetable') then
           SetDDESourceTable(sParameter);

        if (sCommand = 'sourcekey') then
           SetDDESourceKey(sParameter);

        if (sCommand = 'pulayer') then
           SetDDEPULayer(sParameter);

        if (sCommand = 'pukey') then
           SetDDEPUKey(sParameter);

     except
     end;
end;

procedure TSCPForm.TestSelectDDEcmd1Click(Sender: TObject);
var
   iGISChildIndex, iFieldIndex, iCount : integer;
   sf : MapWinGIS_TLB.Shapefile;
   fSelected : boolean;
   sValue, sCellValue : string;
begin
     with ZCSelectDDE do
     begin
          if not fCPlanSelectDDELink then
          begin
               DdeService := 'cplan';
               DdeTopic := 'SelectDDE';

               if OpenLink then
                  fCPlanSelectDDELink := True
               else
                   Caption := 'Unable to link to ' + DDeService + ' ' + DdeTopic;
          end;

          if fCPlanSelectDDELink then
          begin
               // if we have a gis window open, send the selected planning units to the DDE server

               iGISChildIndex := ReturnGISChildIndex;
               if (iGISChildIndex > -1) then
                  if TGIS_Child(MDIChildren[iGISChildIndex]).fShapeSelection then
                  begin
                       // sf object reads key field value for each planning unit
                       // sDDEPULayer sDDEPUKey sDDESourceTable sDDESourceKey
                       sf := CoShapefile.Create();
                       sf.Open(sDDEPULayer, nil);

                       // find index for field
                       iFieldIndex := -1;
                       for iCount := 0 to (sf.Get_NumFields-1) do
                       begin
                            if (sf.Get_Field(iCount).Name = sDDEPUKey) then
                               iFieldIndex := iCount;
                       end;

                       DDESendCmd(ZCSelectDDE,'start select');

                       for iCount := 1 to sf.NumShapes do
                       begin
                            TGIS_Child(MDIChildren[iGISChildIndex]).ShapeSelection.rtnValue(iCount,@fSelected);

                            if (fSelected) then
                            begin
                                 sCellValue := sf.Get_CellValue(iFieldIndex,iCount);

                                 if (sCellValue <> '') then
                                    DDESendCmd(ZCSelectDDE,sCellValue);
                            end;
                       end;

                       DDESendCmd(ZCSelectDDE,'end select');

                       sf.Close;
                  end;
          end;
     end;
end;

function ReturnProjectName(const sProjectFilePath : string) : string;
var
   iCount : integer;
   sProjectFileName : string;
begin
     iCount := 0;

     repeat
           Inc(iCount);

           sProjectFileName := 'project' + IntToStr(iCount) + '.zcp';

     until (not FileExists(sProjectFilePath + sProjectFileName));

     Result := sProjectFileName;
end;

procedure TSCPForm.NewProject1Click(Sender: TObject);
var
   sProjectFilePath, sProjectFileName : string;
   ProjectFile : TextFile;
   iCount : integer;
begin
     try
        NewProjectForm := TNewProjectForm.Create(Application);
        // allow user to select project parameters
        if (NewProjectForm.Showmodal = mrOk) then
           if (NewProjectForm.ListBoxShapefiles.Items.Count > 0) then
           begin
                // save project parameters to a file
                sProjectFilePath := '';

                if (NewProjectForm.EditMarxan.Text <> '') then
                   sProjectFilePath := ExtractFilePath(NewProjectForm.EditMarxan.Text);

                if (sProjectFilePath = '') then
                   if (NewProjectForm.EditCPlan.Text <> '') then
                      sProjectFilePath := ExtractFilePath(NewProjectForm.EditCPlan.Text);

                if (sProjectFilePath = '') then
                    sProjectFilePath := ExtractFilePath(NewProjectForm.ListBoxShapefiles.Items.Strings[0]);

                sProjectFileName := sProjectFilePath + ReturnProjectName(sProjectFilePath);

                assignfile(ProjectFile,sProjectFileName);
                rewrite(ProjectFile);
                writeln(ProjectFile,'[GIS]');
                writeln(ProjectFile,'name=' + NewProjectForm.EditProjectName.Text);
                if NewProjectForm.ComboPUShape.Enabled then
                begin
                     writeln(ProjectFile,'pulayer=' + NewProjectForm.ComboPUShape.Text);
                     writeln(ProjectFile,'KeyField=' + NewProjectForm.ComboPUKey.Text);
                end;
                writeln(ProjectFile,'Layers=' + IntToStr(NewProjectForm.ListBoxShapefiles.Items.Count));
                for iCount := 1 to NewProjectForm.ListBoxShapefiles.Items.Count do
                begin
                     writeln(ProjectFile,'Layer' + IntToStr(iCount) + '=' + NewProjectForm.ListBoxShapefiles.Items.Strings[iCount-1]);
                     writeln(ProjectFile,'Layer' + IntToStr(iCount) + 'Colour=' + IntToStr(iCount-1));
                     writeln(ProjectFile,'Layer' + IntToStr(iCount) + 'Selected=1');
                end;
                if NewProjectForm.CheckMarxan.Checked then
                begin
                     writeln(ProjectFile,'');
                     writeln(ProjectFile,'[Marxan]');
                     writeln(ProjectFile,'name=Marxan');
                     writeln(ProjectFile,'input=' + NewProjectForm.EditMarxan.Text);
                end;
                if NewProjectForm.CheckCPlan.Checked then
                begin
                     writeln(ProjectFile,'');
                     writeln(ProjectFile,'[C-Plan]');
                     writeln(ProjectFile,'name=C-Plan');
                     writeln(ProjectFile,'input=' + NewProjectForm.EditCPlan.Text);
                end;
                if NewProjectForm.CheckeFlows.Checked then
                begin
                     writeln(ProjectFile,'');
                     writeln(ProjectFile,'[eFlows]');
                     writeln(ProjectFile,'name=eFlows');
                     writeln(ProjectFile,'input=' + NewProjectForm.EditeFlows.Text);
                end;
                closefile(ProjectFile);

                // load project from file
                FileOpen(sProjectFileName);
           end;

        NewProjectForm.Free;

     except
           MessageDlg('Exception in NewProject. Likely cause: Map Window Active X control not installed or registered correctly. Consult Zonae Cogito documentation for information.',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TSCPForm.ZCSelectDDEOpen(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     TestSelectDDEcmd1.Visible := True;

     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
        TGIS_Child(MDIChildren[iGISChildIndex]).btnPostDDESelection.Visible := True;
end;

procedure TSCPForm.ZCSelectDDEClose(Sender: TObject);
var
   iGISChildIndex : integer;
begin
     TestSelectDDEcmd1.Visible := False;

     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
        TGIS_Child(MDIChildren[iGISChildIndex]).btnPostDDESelection.Visible := False;
end;

procedure TSCPForm.BuildDistanceTable1Click(Sender: TObject);
begin
     // build distance table for C-Plan SPATTOOL
     BuildDistanceTableForm := TBuildDistanceTableForm.Create(Application);

     if (BuildDistanceTableForm.ShowModal = mrOk) then
        GIS_Child.BuildDistanceTable(BuildDistanceTableForm.EditOutputFilename.Text,
                                     BuildDistanceTableForm.ComboPULayer.Text,
                                     BuildDistanceTableForm.ComboKeyField.Text,
                                     StrToFloat(BuildDistanceTableForm.EditRadius.Text));

     BuildDistanceTableForm.Free;
end;

procedure TSCPForm.BrowseAnnealingOutput1Click(Sender: TObject);
begin
     BrowseAnnealingOutputForm := TBrowseAnnealingOutputForm.Create(Application);
     //BrowseAnnealingOutputForm.Top := MarxanInterfaceForm.Top;
     //BrowseAnnealingOutputForm.Left := MarxanInterfaceForm.Left;
     //BrowseAnnealingOutputForm.Height := MarxanInterfaceForm.Height;
     //BrowseAnnealingOutputForm.Width := MarxanInterfaceForm.Width;
     BrowseAnnealingOutputForm.ShowModal;
     BrowseAnnealingOutputForm.Free;
end;

procedure TSCPForm.BatchRunProjects1Click(Sender: TObject);
begin
     //BatchProjectForm := TBatchProjectForm.Create(Application);
     //BatchProjectForm.ShowModal;
     //BatchProjectForm.Free;
end;

procedure TSCPForm.EditConfigurations1Click(Sender: TObject);
begin
     if fEditConfigurationsForm then
     begin
          // restore the edit configurations form to focus
          EditConfigurations2Click(Sender);
     end
     else
     begin
          EditConfigurationsForm := TEditConfigurationsForm.Create(Application);
          fEditConfigurationsForm := True;
          EditConfigurationsForm.Tag := 6;
          EditConfigurationsForm.Top := MarxanInterfaceForm.Top;
          EditConfigurationsForm.Left := MarxanInterfaceForm.Left;
          //EditConfigurationsForm.Width := MarxanInterfaceForm.Width;
          //EditConfigurationsForm.Height := MarxanInterfaceForm.Height;
          EditConfigurationsForm.Width := 454;
          EditConfigurationsForm.Height := 327;
          EditConfigurations2.Enabled := True;
          EditConfigurations2.Visible := True;

          EditConfigurationsForm.Show;
     end;
end;

procedure TSCPForm.ReportConfigurations1Click(Sender: TObject);
begin
     ReportConfigurationsForm := TReportConfigurationsForm.Create(Application);
     ReportConfigurationsForm.ShowModal;
     ReportConfigurationsForm.Free;
end;

procedure TSCPForm.EditConfigurations2Click(Sender: TObject);
var
   iEditChildIndex : integer;
begin
     iEditChildIndex := ReturnChildIndex(6); // find edit configuration child
     if (iEditChildIndex > -1) then
     begin
          SCPForm.MDIChildren[iEditChildIndex].BringToFront;

          if (SCPForm.MDIChildren[iEditChildIndex].WindowState = wsMinimized) then
             SCPForm.MDIChildren[iEditChildIndex].WindowState := wsNormal;
     end;
end;

procedure TSCPForm.GiveWindowFocus(const sWindow : string);
var
   iCount, iPos : integer;
   sLocalWindow : string;
begin
     iPos := Pos('&',sWindow);
     if (iPos > 0) then
     begin
          sLocalWindow := '';
          for iCount := 1 to Length(sWindow) do
              if (sWindow[iCount] <> '&') then
                 sLocalWindow := sLocalWindow + sWindow[iCount];
     end
     else
         sLocalWindow := sWindow;

     if (MDIChildCount > 0) then
        for iCount := 0 to (MDIChildCount - 1) do
            if (MDIChildren[iCount].Caption = sLocalWindow) then
            begin
                 SCPForm.MDIChildren[iCount].BringToFront;

                 if (SCPForm.MDIChildren[iCount].WindowState = wsMinimized) then
                    SCPForm.MDIChildren[iCount].WindowState := wsNormal;
            end;
end;

procedure TSCPForm.UpdateOpenFiles;
var
   iCount, iChildIndex, iOpenFileCount : integer;

   procedure DisplayOpenFile;
   begin
        if (iOpenFileCount = 1) then
        begin
             OpenFile1.Visible := True;
             OpenFile1.Caption := MDIChildren[iCount].Caption;
        end;
        if (iOpenFileCount = 2) then
        begin
             OpenFile2.Visible := True;
             OpenFile2.Caption := MDIChildren[iCount].Caption;
        end;
        if (iOpenFileCount = 3) then
        begin
             OpenFile3.Visible := True;
             OpenFile3.Caption := MDIChildren[iCount].Caption;
        end;
        if (iOpenFileCount = 4) then
        begin
             OpenFile4.Visible := True;
             OpenFile4.Caption := MDIChildren[iCount].Caption;
        end;
        if (iOpenFileCount = 5) then
        begin
             OpenFile5.Visible := True;
             OpenFile5.Caption := MDIChildren[iCount].Caption;
        end;
        if (iOpenFileCount = 6) then
        begin
             OpenFile6.Visible := True;
             OpenFile6.Caption := MDIChildren[iCount].Caption;
        end;
        if (iOpenFileCount = 7) then
        begin
             OpenFile7.Visible := True;
             OpenFile7.Caption := MDIChildren[iCount].Caption;
        end;
        if (iOpenFileCount = 8) then
        begin
             OpenFile8.Visible := True;
             OpenFile8.Caption := MDIChildren[iCount].Caption;
        end;
        if (iOpenFileCount = 9) then
        begin
             OpenFile9.Visible := True;
             OpenFile9.Caption := MDIChildren[iCount].Caption;
        end;
        if (iOpenFileCount = 10) then
        begin
             OpenFile10.Visible := True;
             OpenFile10.Caption := MDIChildren[iCount].Caption;
        end;
   end;

begin
     //
     OpenFile1.Visible := False;
     OpenFile2.Visible := False;
     OpenFile3.Visible := False;
     OpenFile4.Visible := False;
     OpenFile5.Visible := False;
     OpenFile6.Visible := False;
     OpenFile7.Visible := False;
     OpenFile8.Visible := False;
     OpenFile9.Visible := False;
     OpenFile10.Visible := False;
     OpenMore.Visible := False;
     N1.Visible := False;

     iOpenFileCount := 0;
     if (MDIChildCount > 0) then
        for iCount := 0 to (MDIChildCount - 1) do
            if (MDIChildren[iCount].Tag <> 1)
            and (MDIChildren[iCount].Tag <> 2)
            and (MDIChildren[iCount].Tag <> 6) then
            begin
                 Inc(iOpenFileCount);

                 if (iOpenFileCount <= 10) then
                    DisplayOpenFile
                 else
                     OpenMore.Visible := True;
            end;

     if Marxan3.Visible then
        Inc(iOpenFileCount);

     if GIS4.Visible then
        Inc(iOpenFileCount);

     if (iOpenFileCount > 0) then
     begin
          N1.Enabled := True;
          N1.Visible := True;
     end;
end;

procedure TSCPForm.OpenFile1Click(Sender: TObject);
begin
     GiveWindowFocus(OpenFile1.Caption);
end;

procedure TSCPForm.OpenFile2Click(Sender: TObject);
begin
     GiveWindowFocus(OpenFile2.Caption);
end;

procedure TSCPForm.OpenFile3Click(Sender: TObject);
begin
     GiveWindowFocus(OpenFile3.Caption);
end;

procedure TSCPForm.OpenFile4Click(Sender: TObject);
begin
     GiveWindowFocus(OpenFile4.Caption);
end;

procedure TSCPForm.OpenFile5Click(Sender: TObject);
begin
     GiveWindowFocus(OpenFile5.Caption);
end;

procedure TSCPForm.OpenFile6Click(Sender: TObject);
begin
     GiveWindowFocus(OpenFile6.Caption);
end;

procedure TSCPForm.OpenFile7Click(Sender: TObject);
begin
     GiveWindowFocus(OpenFile7.Caption);
end;

procedure TSCPForm.OpenFile8Click(Sender: TObject);
begin
     GiveWindowFocus(OpenFile8.Caption);
end;

procedure TSCPForm.OpenFile9Click(Sender: TObject);
begin
     GiveWindowFocus(OpenFile9.Caption);
end;

procedure TSCPForm.OpenFile10Click(Sender: TObject);
begin
     GiveWindowFocus(OpenFile10.Caption);
end;

procedure TSCPForm.OpenMoreClick(Sender: TObject);
begin
     OpenMoreForm := TOpenMoreForm.Create(Application);
     OpenMoreForm.ShowModal;
     OpenMoreForm.Free;
end;

procedure TSCPForm.ExtractAquaMapsSpecies1Click(Sender: TObject);
begin
     ExtractAquaMapSpeciesForm := TExtractAquaMapSpeciesForm.Create(Application);
     ExtractAquaMapSpeciesForm.ShowModal;
     ExtractAquaMapSpeciesForm.Free;
end;

procedure TSCPForm.JoinDBFTables1Click(Sender: TObject);
begin
        FormStyle := fsMDIForm;
     JoinDBFTablesForm := TJoinDBFTablesForm.Create(Application);
     JoinDBFTablesForm.ShowModal;
     JoinDBFTablesForm.Free;
end;

procedure TSCPForm.SummariseTable1Click(Sender: TObject);
var
   iCSVChildIndex, iCount : integer;
   AChild : TCSVChild;
begin
     try
        iCSVChildIndex := ReturnCSVTableChildIndex;
        if (iCSVChildIndex > -1) then
           begin
                AChild := TCSVChild(SCPForm.MDIChildren[iCSVChildIndex]);

                SummariseTableForm := TSummariseTableForm.Create(Application);
                SummariseTableForm.ComboField.Items.Clear;
                SummariseTableForm.ComboField.Text := '';

                for iCount := 0 to (AChild.aGrid.ColCount - 1) do
                    SummariseTableForm.ComboField.Items.Add(AChild.aGrid.Cells[iCount,0]);

                SummariseTableForm.ComboField.Text := SummariseTableForm.ComboField.Items.Strings[0];

                SummariseTableForm.SummariseChild := AChild;
                SummariseTableForm.ShowModal;
                SummariseTableForm.Free;
           end;
     except
     end;
end;

procedure TSCPForm.ConvertZSTATStables1Click(Sender: TObject);
begin
        FormStyle := fsMDIForm;
     ConvertZSTATSForm := TConvertZSTATSForm.Create(Application);
     ConvertZSTATSForm.ShowModal;
     ConvertZSTATSForm.Free;
end;

procedure TSCPForm.RegionsExtract1Click(Sender: TObject);
begin
     ProcessRetentionForm := TProcessRetentionForm.Create(Application);
     ProcessRetentionForm.ShowModal;
     ProcessRetentionForm.Free;
end;

procedure TSCPForm.SummariseZones1Click(Sender: TObject);
begin
     SummariseZonesForm := TSummariseZonesForm.Create(Application);
     SummariseZonesForm.ShowModal;
     SummariseZonesForm.Free;
end;

procedure LoadMarxanMatrix(const sFilename : string);
var
   InputFile : TextFile;
   iMaxFeature,iMinSite,iMaxSite, iValue, iCount, iPUID, iSPID, iSPindex, iPUindex : integer;
   sLine : string;
   i_I, i_J, iStartingFeatureIndex : integer;
   Child, ChildPr : TCSVChild;
   sValue, sInputString : string;
   rValue : extended;
   fHeaderRow, fConvertM2ToHa, fProb2DMatrix : boolean;
begin
     // parse matrix filename and find max and min sitekey, max featkey
     assignfile(InputFile,sFilename);
     reset(InputFile);
     readln(InputFile,sLine);

     // does the matrix contain probability data?
     fProb2DMatrix := (CountDelimitersInRow(sLine,',') = 3);

     iMaxFeature := 0;
     iMinSite := 1000000;
     iMaxSite := 0;

     repeat
           readln(InputFile,sLine);

           // species,pu,amount
           iValue := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
           if (iValue > iMaxFeature) then
              iMaxFeature := iValue;

           iValue := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
           if (iValue > iMaxSite) then
              iMaxSite := iValue;
           if (iValue < iMinSite) then
              iMinSite := iValue;

     until Eof(InputFile);
     closefile(InputFile);

     // create destination child
     Child := TCSVChild.Create(Application);
     Child.Caption := 'load marxan amounts';
     Child.Show;
     Child.NewChild;
     with Child.aGrid do
     begin
          RowCount := iMaxSite - iMinSite + 2;
          ColCount := iMaxFeature + 1;
          Cells[0,0] := 'marxan amounts';
          for iCount := 1 to RowCount do
              Cells[0,iCount] := IntToStr(iMinSite + iCount - 1);
          for iCount := 1 to ColCount do
              Cells[iCount,0] := IntToStr(iCount);
     end;
     if fProb2DMatrix then
     begin
          // create destination child for PR data
          ChildPr := TCSVChild.Create(Application);
          ChildPr.Caption := 'load marxan probabilities';
          ChildPr.Show;
          ChildPr.NewChild;
          with ChildPr.aGrid do
          begin
               RowCount := iMaxSite - iMinSite + 2;
               ColCount := iMaxFeature + 1;
               Cells[0,0] := 'marxan probabilities';
               for iCount := 1 to RowCount do
                   Cells[0,iCount] := IntToStr(iMinSite + iCount - 1);
               for iCount := 1 to ColCount do
                   Cells[iCount,0] := IntToStr(iCount);
          end;
     end;

     // parse matrix file, writing each row as an element in the destination child
     reset(InputFile);
     readln(InputFile);
     repeat
           readln(InputFile,sLine);

           // species,pu,amount
           iSPID := StrToInt(GetDelimitedAsciiElement(sLine,',',1));

           iPUID := StrToInt(GetDelimitedAsciiElement(sLine,',',2));

           iSPindex := iSPID;
           iPUindex := 1 + iPUID - iMinSite;

           Child.aGrid.Cells[iSPindex,iPUindex] := GetDelimitedAsciiElement(sLine,',',3);

           if fProb2DMatrix then
              ChildPr.aGrid.Cells[iSPindex,iPUindex] := GetDelimitedAsciiElement(sLine,',',4);

     until Eof(InputFile);
     closefile(InputFile);
end;

procedure TSCPForm.OpenFromMarxanMatrix1Click(Sender: TObject);
begin
     if OpenDialog2.Execute then
        LoadMarxanMatrix(OpenDialog2.Filename);
end;

procedure TSCPForm.SaveToMarxanMatrix1Click(Sender: TObject);
begin
     SaveMarxanMatrixForm := TSaveMarxanMatrixForm.Create(Application);
     SaveMarxanMatrixForm.ShowModal;
     SaveMarxanMatrixForm.Free;
end;

procedure TSCPForm.BitmapBMP1Click(Sender: TObject);
var
   iGISChildIndex : integer;
   fWriteFile : boolean;
begin
     iGISChildIndex := ReturnGISChildIndex;
     if (iGISChildIndex > -1) then
     begin
          if fileexists(TGIS_Child(MDIChildren[iGISChildIndex]).sPuFileName) then
             SaveBMP.InitialDir := ExtractFilePath(TGIS_Child(MDIChildren[iGISChildIndex]).sPuFileName);

        if SaveBMP.Execute then
        begin
             fWriteFile := True;

             if fileexists(SaveBMP.Filename) then
                fWriteFile := (mrYes = MessageDlg('File exists. Overwrite?',mtConfirmation,[mbYes,mbNo],0));

             if fWriteFile then
             begin
                  Application.ProcessMessages;
                  TGIS_Child(MDIChildren[iGISChildIndex]).SaveMapToBmpFile(SaveBMP.Filename);
             end;
        end;
     end;
end;

procedure TSCPForm.ShapefileSHP1Click(Sender: TObject);
var
   fWriteFile : boolean;
begin
     if SaveSHP.Execute then
     begin
          fWriteFile := True;

          if fileexists(SaveSHP.Filename) then
             fWriteFile := (mrYes = MessageDlg('File exists. Overwrite?',mtConfirmation,[mbYes,mbNo],0));

          if fWriteFile then
             GIS_Child.ExportShapesForSelection(SaveSHP.Filename,False);
     end;
end;

procedure TSCPForm.ESRIShapefileSHP1Click(Sender: TObject);
var
   fWriteFile : boolean;
begin
     if SaveSHP.Execute then
     begin
          fWriteFile := True;

          if fileexists(SaveSHP.Filename) then
             fWriteFile := (mrYes = MessageDlg('File exists. Overwrite?',mtConfirmation,[mbYes,mbNo],0));

          if fWriteFile then
             GIS_Child.ExportShapesForSelection(SaveSHP.Filename,True);
     end;
end;

procedure TSCPForm.KeyholeMarkupLanguageKML2Click(Sender: TObject);
var
   fWriteFile : boolean;
begin
     if SaveKML.Execute then
     begin
          fWriteFile := True;

          if fileexists(SaveKML.Filename) then
             fWriteFile := (mrYes = MessageDlg('File exists. Overwrite?',mtConfirmation,[mbYes,mbNo],0));

          if fWriteFile then
             GIS_Child.ExportShapesToKML(SaveKML.Filename,True,ShapeOutlines1.Checked);
     end;
end;

procedure TSCPForm.AllShapes1Click(Sender: TObject);
var
   fWriteFile : boolean;
begin
     if SaveKML.Execute then
     begin
          fWriteFile := True;

          if fileexists(SaveKML.Filename) then
             fWriteFile := (mrYes = MessageDlg('File exists. Overwrite?',mtConfirmation,[mbYes,mbNo],0));

          if fWriteFile then
             GIS_Child.ExportAllShapesToKML(SaveKML.Filename,False);
          //GIS_Child.ExportAllShapesToKML(Copy(SaveKML.Filename,1,length(SaveKML.Filename)-4) + '_clockwise.KML',False);
          //GIS_Child.ExportAllShapesToKML(Copy(SaveKML.Filename,1,length(SaveKML.Filename)-4) + '_anticlockwise.KML',True);
     end;
end;

procedure TSCPForm.SelectedShapes1Click(Sender: TObject);
var
   fWriteFile : boolean;
begin
     if SaveKML.Execute then
     begin
          fWriteFile := True;

          if fileexists(SaveKML.Filename) then
             fWriteFile := (mrYes = MessageDlg('File exists. Overwrite?',mtConfirmation,[mbYes,mbNo],0));

          if fWriteFile then
             GIS_Child.ExportShapesToKML(SaveKML.Filename,True,ShapeOutlines1.Checked);
     end;
end;

procedure TSCPForm.BestSolution1Click(Sender: TObject);
var
   fWriteFile : boolean;
begin
     if SaveKML.Execute then
     begin
          fWriteFile := True;

          if fileexists(SaveKML.Filename) then
             fWriteFile := (mrYes = MessageDlg('File exists. Overwrite?',mtConfirmation,[mbYes,mbNo],0));

          if fWriteFile then
             GIS_Child.ExportShapesToKML_MARXANSINGLESOLUTION(SaveKML.Filename,'BESTSOLN',ShapeOutlines1.Checked,255);
     end;
end;

procedure TSCPForm.SummedSolution1Click(Sender: TObject);
var
   iMaxDisplayValue : integer;
   fWriteFile : boolean;
begin
     if SaveKML.Execute then
     begin
          fWriteFile := True;

          if fileexists(SaveKML.Filename) then
             fWriteFile := (mrYes = MessageDlg('File exists. Overwrite?',mtConfirmation,[mbYes,mbNo],0));

          if fWriteFile then
          begin
               iMaxDisplayValue := MarxanInterfaceForm.ReturnMarxanIntParameter('NUMREPS');;
               GIS_Child.ExportShapesToKML_MARXANSUMMEDSOLUTION(SaveKML.Filename,'SSOLN',ShapeOutlines1.Checked,iMaxDisplayValue,255);
          end;
     end;
end;

procedure TSCPForm.Transparency1Click(Sender: TObject);
begin
     GISOptionsForm := TGISOptionsForm.Create(Application);
     GISOptionsForm.ShowModal;

     GISOptionsForm.Free;
end;

procedure TSCPForm.BuildCPlanDataset1Click(Sender: TObject);
begin
     ConvertCPlanForm := TConvertCPlanForm.Create(Application);
     ConvertCPlanForm.ShowModal;
     ConvertCPlanForm.Free;
end;

procedure TSCPForm.SummaryBarGraph1Click(Sender: TObject);
begin
     try
     fBarGraphStarting := True;
        BarGraphForm := TBarGraphForm.Create(Application);
        BarGraphForm.InitGraph(3);
        BarGraphForm.ShowModal;
        BarGraphForm.Free;

     except
           MessageDlg('Exception in TSCPForm.SummaryBarGraph1Click',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TSCPForm.BestSolutionBarGraph1Click(Sender: TObject);
begin
     try
     fBarGraphStarting := True;
        BarGraphForm := TBarGraphForm.Create(Application);
        BarGraphForm.InitGraph(1);
        BarGraphForm.ShowModal;
        BarGraphForm.Free;

     except
           MessageDlg('Exception in TSCPForm.BestSolutionBarGraph1Click',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TSCPForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     if (SCPForm.feFlowsActivated) then
        eFlowsForm.FormClose(Sender,Action);

     if fTransparencyStored then
     begin
          TransparencyArray.Destroy;
          fTransparencyStored := False;
     end;
end;

procedure TSCPForm.BuildBoundaryLengthFile1Click(Sender: TObject);
var
   fContinue : boolean;
begin
     BoundaryFileMakerForm := TBoundaryFileMakerForm.Create(Application);
     if (BoundaryFileMakerForm.ShowModal = mrOk) then
     begin
          fContinue := True;

          if FileExists(BoundaryFileMakerForm.EditOutputFileName.Text) then
          begin
               fContinue := (MessageDlg('Output file exists. Overwrite?',mtConfirmation,[mbYes,mbNo],0) = mrYes);
          end;

          MakeBoundaryLengthFile(BoundaryFileMakerForm.ComboPulayer.Text,
                                 BoundaryFileMakerForm.ComboPUIDField.Text,
                                 BoundaryFileMakerForm.EditOutputFileName.Text,
                                 BoundaryFileMakerForm.CheckIncludeEdges.Checked);

     end;
     BoundaryFileMakerForm.Free;
end;

procedure TSCPForm.OpenFromMarxanProb2DMatrix1Click(Sender: TObject);
begin
     if OpenDialog2.Execute then
        LoadMarxanMatrix(OpenDialog2.Filename);
end;

procedure TSCPForm.eFlows1Click(Sender: TObject);
begin
     eFlowsForm := TeFlowsForm.Create(Application);
     eFlowsForm.ShowModal;
     eFlowsForm.Free;
end;

procedure TSCPForm.RuneFlows1Click(Sender: TObject);
begin
     eFlowsForm.ButtonUpdateClick(Sender);
end;

procedure TSCPForm.HideExcelInterface1Click(Sender: TObject);
begin
     eFlowsExcelObject.Visible := not HideExcelInterface1.Checked;
end;

procedure TSCPForm.GenerateTimeSeriesAnimation1Click(Sender: TObject);
var
   fWriteFile : boolean;
begin
     if SaveKML.Execute then
     begin
          fWriteFile := True;

          if fileexists(SaveKML.Filename) then
             fWriteFile := (mrYes = MessageDlg('File exists. Overwrite?',mtConfirmation,[mbYes,mbNo],0));

          if fWriteFile then
             eFlowsForm.GenerateTimeSeriesKML(SaveKML.Filename,1,True);
     end;
end;

procedure TSCPForm.MissingValuesBarGraph1Click(Sender: TObject);
begin
     try
     fBarGraphStarting := True;
        BarGraphForm := TBarGraphForm.Create(Application);
        BarGraphForm.InitGraph(5);
        BarGraphForm.ShowModal;
        BarGraphForm.Free;

     except
           MessageDlg('Exception in TSCPForm.MissingValuesBarGraph1Click',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TSCPForm.AllSolutions1Click(Sender: TObject);
begin
     iBWPFDisplayMode := 0;
     BoxWhiskerPlotForm := TBoxWhiskerPlotForm.Create(Application);
     BoxWhiskerPlotForm.ShowModal;
     BoxWhiskerPlotForm.Free
end;

procedure TSCPForm.BestSolution3Click(Sender: TObject);
begin
     iBWPFDisplayMode := 1;
     BoxWhiskerPlotForm := TBoxWhiskerPlotForm.Create(Application);
     BoxWhiskerPlotForm.ShowModal;
     BoxWhiskerPlotForm.Free
end;

procedure TSCPForm.BestSolution4Click(Sender: TObject);
begin
     try
     fBarGraphStarting := True;
        BarGraphForm := TBarGraphForm.Create(Application);
        BarGraphForm.InitGraph(6);
        BarGraphForm.ShowModal;
        BarGraphForm.Free;

     except
           MessageDlg('Exception in TSCPForm.BestSolution4Click',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TSCPForm.AllSolutions2Click(Sender: TObject);
begin
     try
        BarGraphForm := TBarGraphForm.Create(Application);
        BarGraphForm.InitGraph(4);
        BarGraphForm.ShowModal;
        BarGraphForm.Free;

     except
           MessageDlg('Exception in TSCPForm.AllSolutions2Click',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TSCPForm.BestSolution5Click(Sender: TObject);
begin
     eFlowsForm.RetrieveTotalSummary(0);
end;

procedure TSCPForm.Solution11Click(Sender: TObject);
begin
     eFlowsForm.RetrieveTotalSummary(1);
end;

procedure TSCPForm.Solution21Click(Sender: TObject);
begin
     eFlowsForm.RetrieveTotalSummary(2);
end;

procedure TSCPForm.Solution31Click(Sender: TObject);
begin
     eFlowsForm.RetrieveTotalSummary(3);
end;

procedure TSCPForm.Solution41Click(Sender: TObject);
begin
     eFlowsForm.RetrieveTotalSummary(4);
end;

procedure TSCPForm.Solution51Click(Sender: TObject);
begin
     eFlowsForm.RetrieveTotalSummary(5);
end;

procedure TSCPForm.Solution61Click(Sender: TObject);
begin
     eFlowsForm.RetrieveTotalSummary(6);
end;

procedure TSCPForm.Solution71Click(Sender: TObject);
begin
     eFlowsForm.RetrieveTotalSummary(7);
end;

procedure TSCPForm.Solution81Click(Sender: TObject);
begin
     eFlowsForm.RetrieveTotalSummary(8);
end;

procedure TSCPForm.Solution91Click(Sender: TObject);
begin
     eFlowsForm.RetrieveTotalSummary(9);
end;

procedure TSCPForm.Solution101Click(Sender: TObject);
begin
     eFlowsForm.RetrieveTotalSummary(10);
end;

procedure TSCPForm.BestSolution6Click(Sender: TObject);
begin
     eFlowsForm.RetrieveOutsheet(0);
end;

procedure TSCPForm.Solution12Click(Sender: TObject);
begin
     eFlowsForm.RetrieveOutsheet(1);
end;

procedure TSCPForm.Solution22Click(Sender: TObject);
begin
     eFlowsForm.RetrieveOutsheet(2);
end;

procedure TSCPForm.Solution32Click(Sender: TObject);
begin
     eFlowsForm.RetrieveOutsheet(3);
end;

procedure TSCPForm.Solution42Click(Sender: TObject);
begin
     eFlowsForm.RetrieveOutsheet(4);
end;

procedure TSCPForm.Solution52Click(Sender: TObject);
begin
     eFlowsForm.RetrieveOutsheet(5);
end;

procedure TSCPForm.Solution62Click(Sender: TObject);
begin
     eFlowsForm.RetrieveOutsheet(6);
end;

procedure TSCPForm.Solution72Click(Sender: TObject);
begin
     eFlowsForm.RetrieveOutsheet(7);
end;

procedure TSCPForm.Solution82Click(Sender: TObject);
begin
     eFlowsForm.RetrieveOutsheet(8);
end;

procedure TSCPForm.Solution92Click(Sender: TObject);
begin
     eFlowsForm.RetrieveOutsheet(9);
end;

procedure TSCPForm.Solution102Click(Sender: TObject);
begin
     eFlowsForm.RetrieveOutsheet(10);
end;

procedure TSCPForm.Arrangesidebyside1Click(Sender: TObject);
begin
     SCPForm.TileVertical;
end;

procedure TSCPForm.Arrangetoptobottom1Click(Sender: TObject);
begin
     SCPForm.TileHorizontal;
end;

procedure TSCPForm.Cascade1Click(Sender: TObject);
begin
     SCPForm.Cascade;
end;

procedure TSCPForm.PurgeDBF1Click(Sender: TObject);
var
   myExtents: MapWinGIS_TLB.Extents;
begin
     myExtents := IExtents(GIS_Child.Map1.Extents);
     GIS_Child.RemoveAllShapes;
     eFlowsForm.DropFields(eFlowsForm.seFlowsPuLayer);
     GIS_Child.RestoreAllShapes;
     GIS_Child.Map1.Extents := myExtents;
end;

procedure TSCPForm.PurgeDBF2Click(Sender: TObject);
var
   myExtents: MapWinGIS_TLB.Extents;
begin
     myExtents := IExtents(GIS_Child.Map1.Extents);
     GIS_Child.RemoveAllShapes;
     MarxanInterfaceForm.DropFields;
     GIS_Child.RestoreAllShapes;
     GIS_Child.Map1.Extents := myExtents;
end;

procedure TSCPForm.BoxWhiskerPlot1Click(Sender: TObject);
begin
     iBWPFDisplayMode := 2;
     BoxWhiskerPlotForm := TBoxWhiskerPlotForm.Create(Application);
     BoxWhiskerPlotForm.ShowModal;
     BoxWhiskerPlotForm.Free
end;

procedure TSCPForm.SHPtoSHP1Click(Sender: TObject);
begin
     ConvertLayerForm := TConvertLayerForm.Create(Application);
     ConvertLayerForm.PrepareTheForm('.shp','SHPtoSHP','.shp');
     ConvertLayerForm.ShowModal;
     ConvertLayerForm.Free;
end;

procedure TSCPForm.SHPtoBMP1Click(Sender: TObject);
begin
     ConvertLayerForm := TConvertLayerForm.Create(Application);
     ConvertLayerForm.PrepareTheForm('.shp','SHPtoBMP','.bmp');
     ConvertLayerForm.ShowModal;
     ConvertLayerForm.Free;
end;

procedure TSCPForm.Maximise1Click(Sender: TObject);
begin
     if (ActiveMDIChild <> nil) then
        ActiveMDIChild.WindowState := wsMaximized;
end;

procedure TSCPForm.Restore1Click(Sender: TObject);
begin
     if (ActiveMDIChild <> nil) then
        ActiveMDIChild.WindowState := wsNormal;
end;

procedure TSCPForm.ClearRecentFiles1Click(Sender: TObject);
begin
     if (mrYes = MessageDlg('Are you sure you want to permanently erase your list of recent files?',mtConfirmation,[mbYes,mbNo],0)) then
        ClearRecent;
end;

end.


