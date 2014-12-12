unit Control;

{$I STD_DEF.PAS}

{This is the Control unit for the NPWS C-Plan application.
 The main Control Form lives here.
                                        
 Author: Matthew Watts
 Date: 21st July 1995     }

{$UNDEF ADD_EDEN_SITES}

{$UNDEF DUMP_MEM_INFO}
{$UNDEF DBG_ROW_TOTALS}
{$UNDEF DBG_SUMIRR}

{$IFDEF VER90}
{$DEFINE FASTINIT}
{$ELSE}
{$UNDEF FASTINIT}
{$ENDIF}

{/$///IFDEF VER90}
{$UNDEF PAGING_ARRAY}
{/$///ENDIF}


interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Em_newu1, Menus, DB, DBTables,
  Gauges, About, Options, Dde_unit, Sql_unit, Contribu, Lookup,
  Choices, DBCtrls, Global, Grids,
  Bin_io, Exclarea, Comb_run, IniFiles,
  {Dde32,}ds,Av1, DdeMan;


type
  TControlForm = class(TForm)
    Available: TListBox;
    ToolPanel: TPanel;
    R1: TListBox;
    AvailableLabel: TLabel;
    SelectedLabel: TLabel;
    MidPanel: TPanel;
    UnSelectGroup: TButton;
    SelectGroup: TButton;
    UnSelectAll: TButton;
    ManGroup: TButton;
    UnManGroup: TButton;
    UnManAll: TButton;
    SplitPanelMan: TPanel;
    R2: TListBox;
    MandatoryLabel: TLabel;
    TargetPercent: TEdit;
    Label4: TLabel;
    AvailableKey: TListBox;
    R1Key: TListBox;
    R2Key: TListBox;
    MainMenu1: TMainMenu;
    Help1: TMenuItem;
    About1: TMenuItem;
    InTable: TTable;
    OutTable: TTable;
    File1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    Exit1: TMenuItem;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    Contents1: TMenuItem;
    Search1: TMenuItem;
    divider1: TMenuItem;
    N2: TMenuItem;
    Options1: TMenuItem;
    Display1: TMenuItem;
    Irreplacability2: TMenuItem;
    Defaults1: TMenuItem;
    N3: TMenuItem;
    OpenOptions1: TMenuItem;
    SaveOptions1: TMenuItem;
    IniBox: TListBox;
    Proximity1: TMenuItem;
    Graph1: TMenuItem;
    Contribution1: TMenuItem;
    Both1: TMenuItem;
    StatusPanel: TPanel;
    ProgressGauge: TGauge;
    ProcLabel: TLabel;
    DDEActivate: TCheckBox;
    checkShowLookup: TCheckBox;
    LookupSites1: TMenuItem;
    ClickGroup: TRadioGroup;
    N4: TMenuItem;
    Reasoning1: TMenuItem;
    Dehighlight1: TMenuItem;
    LeftPanel: TPanel;
    RightPanel: TPanel;
    LookupDisplayList: TListBox;
    N7: TMenuItem;
    DBMSFields1: TMenuItem;
    SplitPanelExc: TPanel;
    ExcludedLabel: TLabel;
    Excluded: TListBox;
    ExcGroup: TButton;
    UnExcGroup: TButton;
    UnExcAll: TButton;
    ExcludedKey: TListBox;
    Choose1: TMenuItem;
    N8: TMenuItem;
    btnCycle: TButton;
    btnToggle: TButton;
    btnAccept: TButton;
    Tools1: TMenuItem;
    UseFeatCutOffs: TCheckBox;
    CutOffTable: TTable;
    btnIrrep: TButton;
    ReportBox: TListBox;
    Report1: TMenuItem;
    N11: TMenuItem;
    TimberResource1: TMenuItem;
    SQLLookup1: TMenuItem;
    SQLMap1: TMenuItem;
    N12: TMenuItem;
    SubTable: TTable;
    Reserved: TListBox;
    ReservedKey: TListBox;
    Ignored: TListBox;
    IgnoredKey: TListBox;
    Report2: TMenuItem;
    Targets1: TMenuItem;
    CountSites1: TMenuItem;
    RptSave: TSaveDialog;
    FeaturesToTarget1: TMenuItem;
    CurrentFile: TMenuItem;
    EMSReason: TListBox;
    StageDescription1: TMenuItem;
    BrowseEMSReason: TListBox;
    Browse1: TMenuItem;
    btnImportTools: TButton;
    EditTargets1: TMenuItem;
    TestTable: TTable;
    PartialKey: TListBox;
    FlaggedKey: TListBox;
    Flagged: TListBox;
    Partial: TListBox;
    PartialDeferral1: TMenuItem;
    InitialDisplayState1: TMenuItem;
    RestrictTargets1: TMenuItem;
    SaveCombSize1: TMenuItem;
    OpenCombsize1: TMenuItem;
    OpenComb: TOpenDialog;
    PopUpOptions: TPopupMenu;
    AcceptSelections: TMenuItem;
    Cycle1: TMenuItem;
    SQLMap2: TMenuItem;
    PartialDeferral2: TMenuItem;
    RunIrreplaceability1: TMenuItem;
    ParGroup: TButton;
    UnParGroup: TButton;
    UnParAll: TButton;
    FlgGroup: TButton;
    UnFlgGroup: TButton;
    UnFlgAll: TButton;
    SplitPanelPar: TPanel;
    ParLabel: TLabel;
    SplitPanelFlg: TPanel;
    FlgLabel: TLabel;
    MissingFeatures1: TMenuItem;
    AllReports1: TMenuItem;
    N18: TMenuItem;
    LoadSiteNAME1: TMenuItem;
    LoadSiteGEOCODE1: TMenuItem;
    N19: TMenuItem;
    TestDiskArrayt1: TMenuItem;
    LoadDiskArrayt1: TMenuItem;
    test1: TMenuItem;
    ToolView1: TMenuItem;
    SetToolView1: TMenuItem;
    N17: TMenuItem;
    OpenSiteText: TOpenDialog;
    currFile: TMenuItem;
    N5: TMenuItem;
    Defer1: TMenuItem;
    UnDefer1: TMenuItem;
    N10: TMenuItem;
    N21: TMenuItem;
    PopupSearch: TPopupMenu;
    Negotiated1: TMenuItem;
    Mandatory2: TMenuItem;
    Partial2: TMenuItem;
    Flagged2: TMenuItem;
    Excluded2: TMenuItem;
    N23: TMenuItem;
    Negotiated2: TMenuItem;
    Mandatory3: TMenuItem;
    Partial3: TMenuItem;
    N24: TMenuItem;
    N25: TMenuItem;
    Deferred1: TMenuItem;
    Flagged3: TMenuItem;
    Excluded3: TMenuItem;
    HighlightAll1: TMenuItem;
    Available2: TMenuItem;
    Negotiated3: TMenuItem;
    Mandatory4: TMenuItem;
    Excluded4: TMenuItem;
    ClearAll1: TMenuItem;
    Available3: TMenuItem;
    Negotiated4: TMenuItem;
    Mandatory5: TMenuItem;
    Excluded5: TMenuItem;
    Partial1: TMenuItem;
    Flagged1: TMenuItem;
    Partial4: TMenuItem;
    Flagged4: TMenuItem;
    N9: TMenuItem;
    AllClasses1: TMenuItem;
    VariRunCombsize1: TMenuItem;
    N13: TMenuItem;
    ImportData2: TMenuItem;
    DeferredNeMaPd1: TMenuItem;
    MatrixReport1: TMenuItem;
    N15: TMenuItem;
    ExtendedFunctions1: TMenuItem;
    ExtraTools1: TMenuItem;
    N20: TMenuItem;
    btnSelect: TMenuItem;
    RestoreDefaultOptions1: TMenuItem;
    Single1: TMenuItem;
    AvailablePanel: TPanel;
    ShapeTable: TTable;
    ArcViewDDEForm1: TMenuItem;
    N14: TMenuItem;
    IterateTillSatisfied1: TMenuItem;
    Hide1: TMenuItem;
    HideMandatory1: TMenuItem;
    HidePartial1: TMenuItem;
    HideFlagged1: TMenuItem;
    HideExcluded1: TMenuItem;
    ScriptEditor1: TMenuItem;
    SaveSiteGEOCODE1: TMenuItem;
    SaveSiteText: TSaveDialog;
    Minset1: TMenuItem;
    SaveToFileNAME1: TMenuItem;
    Area1: TMenuItem;
    PartialStatus1: TMenuItem;
    FeatureIrrep1: TMenuItem;
    toTarget1: TMenuItem;
    mins1: TMenuItem;
    AllFeatures1: TMenuItem;
    ExtantFeatures1: TMenuItem;
    FeatureAmount1: TMenuItem;
    PartialStatus2: TMenuItem;
    FeatureIrreplaceability1: TMenuItem;
    toTarget2: TMenuItem;
    AllMatrixReports1: TMenuItem;
    AllMatrixReports2: TMenuItem;
    Reserved1: TMenuItem;
    Ignored1: TMenuItem;
    N16: TMenuItem;
    SelectAs1: TMenuItem;
    DeSelectFrom1: TMenuItem;
    Negotiated5: TMenuItem;
    Mandatory1: TMenuItem;
    Negotiated6: TMenuItem;
    Mandatory6: TMenuItem;
    N22: TMenuItem;
    DeferredNeMa1: TMenuItem;
    DeferredNeMaPd2: TMenuItem;
    Partial5: TMenuItem;
    N6: TMenuItem;
    N26: TMenuItem;
    N27: TMenuItem;
    SetWorkingDirectory1: TMenuItem;
    N29: TMenuItem;
    ApplyFeatureClasses1: TMenuItem;
    SubsetGroup: TRadioGroup;
    IdentifyLowValueDeferrals1: TMenuItem;
    RptFieldBox: TListBox;
    RptFieldValueBox: TListBox;
    AddSelectionsfromfile1: TMenuItem;
    N28: TMenuItem;
    LaunchTableEditor1: TMenuItem;
    CheckTenureOfSelections1: TMenuItem;
    N30: TMenuItem;
    Lookup1: TMenuItem;
    Map1: TMenuItem;
    AddToMap1: TMenuItem;
    Default1: TMenuItem;
    Default2: TMenuItem;
    SiteRptBlank1: TMenuItem;
    SiteRptBlank2: TMenuItem;
    SiteRptBlank3: TMenuItem;
    SiteRptBlank4: TMenuItem;
    SiteRptBlank5: TMenuItem;
    SiteRptBlank6: TMenuItem;
    SiteRptBlank7: TMenuItem;
    SiteRptBlank8: TMenuItem;
    SiteRptBlank9: TMenuItem;
    FeatureRptBlank1: TMenuItem;
    FeatureRptBlank2: TMenuItem;
    FeatureRptBlank3: TMenuItem;
    FeatureRptBlank4: TMenuItem;
    FeatureRptBlank5: TMenuItem;
    FeatureRptBlank6: TMenuItem;
    FeatureRptBlank7: TMenuItem;
    FeatureRptBlank8: TMenuItem;
    FeatureRptBlank9: TMenuItem;
    N31: TMenuItem;
    TblEdClientItem: TDdeClientItem;
    TblEdClientConv: TDdeClientConv;
    UseDLL1: TMenuItem;
    CPlanSpatClient: TDdeClientConv;
    DdeClientItem1: TDdeClientItem;
    CPlanSpatServer: TDdeServerConv;
    DdeServerItem1: TDdeServerItem;
    AddFieldsQuery: TQuery;
    lblA: TLabel;
    ReportSpatialConfig1: TMenuItem;
    SpatialModule1: TMenuItem;
    FeatureRptBlank10: TMenuItem;
    SiteRptBlank10: TMenuItem;
    IniSectionBox: TListBox;
    ReportEMSFiles1: TMenuItem;
    ReportSpatialSpread1: TMenuItem;
    N1: TMenuItem;
    Stages1: TMenuItem;
    FSTable: TTable;
    SparseAmountTable: TTable;
    SparseKeyTable: TTable;
    SaveSparseMatrix1: TMenuItem;
    N32: TMenuItem;
    N33: TMenuItem;
    CombinationSizeOptions1: TMenuItem;
    RandomSiteSelection1: TMenuItem;
    Sites1: TMenuItem;
    Features1: TMenuItem;
    S1: TMenuItem;
    ClearSelections1: TMenuItem;
    AddStageToSHPFile1: TMenuItem;
    ProduceSFvalidationmatrix1: TMenuItem;
    MapRedundantSites1: TMenuItem;
    SFTimer: TTimer;
    Validate1: TMenuItem;
    FastMinset1: TMenuItem;
    LaunchTableEditorOldVersion1: TMenuItem;
    ReplacementSites1: TMenuItem;
    SendPrepareSpread1: TMenuItem;
    SiteFeatureLookup1: TMenuItem;
    TargetProgress1: TMenuItem;
    CPlanFeatureIndexCFI1: TMenuItem;
    SiteInfo1: TMenuItem;
    FeatureInfo1: TMenuItem;
    R3: TListBox;
    R4: TListBox;
    R5: TListBox;
    R3Key: TListBox;
    R4Key: TListBox;
    R5Key: TListBox;
    OpenLOGfilepreversion351: TMenuItem;
    a_r3: TMenuItem;
    a_r4: TMenuItem;
    a_r5: TMenuItem;
    b_r3: TMenuItem;
    b_r4: TMenuItem;
    b_r5: TMenuItem;
    c_r3: TMenuItem;
    c_r4: TMenuItem;
    c_r5: TMenuItem;
    d_r3: TMenuItem;
    d_r4: TMenuItem;
    d_r5: TMenuItem;
    Warnings: TListBox;
    DisplayWarnings: TMenuItem;
    OpenSelectionsolderversions1: TMenuItem;
    MarxanPrototype1: TMenuItem;
    Marxan1: TMenuItem;
    BuildDatabase1: TMenuItem;
    Options2: TMenuItem;
    EditReserveClasses1: TMenuItem;
    CIBulkSitePartialProtection1: TMenuItem;
    BLFConverter1: TMenuItem;
    DumpMatrixwithSiteNameaskey1: TMenuItem;
    MalRandomSiteSelection1: TMenuItem;
    EditAllTargets1: TMenuItem;
    ImportTargetField1: TMenuItem;
    Summaris1: TMenuItem;
    procedure LoadSiteMatrix;
    procedure LoadSiteMatrixV2;
    procedure CloseTool;
    procedure MoveGroup(var Source,Sgeo : TListBox; var Dest,Dgeo : TListBox;
                        const fUser, fComplementarity : boolean);
    procedure MoveSome(var Source,Sgeo : TListBox; var Dest, Dgeo : TListBox;
                       const iNumCodes : integer; const Codes : Array_T);
    procedure MoveAll(var Source,Sgeo : TListBox; var Dest,Dgeo : TListBox;
                      const fUser : boolean);
    procedure SelectGroupClick(Sender: TObject);
    procedure UnSelectGroupClick(Sender: TObject);
    procedure UnSelectAllClick(Sender: TObject);
    procedure ManGroupClick(Sender: TObject);
    procedure UnManGroupClick(Sender: TObject);
    procedure UnManAllClick(Sender: TObject);
    procedure UpdateDatabase(const fWriteDisplay : boolean);
    procedure RefreshGIS;
    procedure UpdateTenure;
    procedure About1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject; var fCancel, fCancelPressed : boolean);
    procedure SaveAs1Click(Sender: TObject; var fCancel : boolean);
    procedure ProgressOn;
    procedure ProgressUpdate(const iCurrVal : integer);
    procedure ProgressOff;
    procedure ProcLabelOn(const sLabel : string);
    procedure ProcLabelUpdate(const sLabel : string);
    procedure ProcLabelOff;
    procedure Display1Click(Sender: TObject);
    procedure Irreplacability2Click(Sender: TObject);
    procedure Defaults1Click(Sender: TObject);
    procedure InformGIS;
    procedure LoadIni(Sender: TObject);
    procedure SaveIni(Sender: TObject;
                      const sFilename : string);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MapItemChange(Sender: TObject);
    procedure checkShowLookupClick(Sender: TObject);
    procedure Contribution1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure LookupSites1Click(Sender: TObject);
    procedure SystemItemChange(Sender: TObject);
    procedure TryDDEConnect;
    procedure Reasoning1Click(Sender: TObject);
    procedure SaveNoParam(Sender: TObject);
    procedure SaveAsNoClick(Sender: TObject);
    procedure DBMSFields1Click(Sender: TObject);
    procedure ExcGroupClick(Sender: TObject);
    procedure UnExcGroupClick(Sender: TObject);
    procedure UnExcAllClick(Sender: TObject);
    procedure ClickGroupClick(Sender: TObject);
    procedure ClickGroupEnter(Sender: TObject);
    procedure btnCycleClick(Sender: TObject);
    procedure btnAcceptClick(Sender: TObject);
    procedure UseFeatCutOffsClick(Sender: TObject);
    procedure LoadFeatureTable;
    procedure IrrepSimon1Click(Sender: TObject);
    procedure SustainableYield1Click(Sender: TObject);
    procedure TimberResource1Click(Sender: TObject);
    procedure SQLLookup1Click(Sender: TObject);
    procedure SQLMap1Click(Sender: TObject);
    procedure CountSites1Click(Sender: TObject);
    procedure FeaturesToTarget1Click(Sender: TObject);
    procedure StageDescription1Click(Sender: TObject);
    procedure Browse1Click(Sender: TObject);
    procedure EditTargets1Click(Sender: TObject);
    procedure PartialDeferral1Click(Sender: TObject);
    procedure InitialDisplayState1Click(Sender: TObject);
    procedure CreateGIS;
    procedure RestrictTargets1Click(Sender: TObject);
    procedure SQLMap2Click(Sender: TObject);
    procedure PartialDeferral2Click(Sender: TObject);
    procedure WinERMSDisconnect(Sender: TObject);
    procedure WERMSDisconnect;
    procedure ParGroupClick(Sender: TObject);
    procedure UnParGroupClick(Sender: TObject);
    procedure UnParAllClick(Sender: TObject);
    procedure FlgGroupClick(Sender: TObject);
    procedure UnFlgGroupClick(Sender: TObject);
    procedure UnFlgAllClick(Sender: TObject);
    procedure HideFlagged1Click(Sender: TObject);
    procedure Replot1Click(Sender: TObject);
    procedure MissingFeatures1Click(Sender: TObject);
    procedure AllReports1Click(Sender: TObject);
    procedure LoadSiteNAME1Click(Sender: TObject);
    procedure LoadSiteGEOCODE1Click(Sender: TObject);
    procedure ToolView1Click(Sender: TObject);
    procedure SetToolView1Click(Sender: TObject);
    function CanAccept : boolean;
    procedure LoadSiteNames;
    procedure FormCreate(Sender: TObject);
    procedure ReLoadIni(Sender: TObject);
    procedure OpenOptions1Click(Sender: TObject);
    function GetMatrixVer : integer;
    procedure LoadSiteMatrixV3;
    procedure Negotiated1Click(Sender: TObject);
    procedure Mandatory2Click(Sender: TObject);
    procedure Partial2Click(Sender: TObject);
    procedure Flagged2Click(Sender: TObject);
    procedure Excluded2Click(Sender: TObject);
    procedure Negotiated2Click(Sender: TObject);
    procedure Mandatory3Click(Sender: TObject);
    procedure Partial3Click(Sender: TObject);
    procedure Flagged3Click(Sender: TObject);
    procedure Excluded3Click(Sender: TObject);
    procedure Deferred1Click(Sender: TObject);
    procedure Available2Click(Sender: TObject);
    procedure Available3Click(Sender: TObject);
    procedure Negotiated3Click(Sender: TObject);
    procedure Negotiated4Click(Sender: TObject);
    procedure Mandatory4Click(Sender: TObject);
    procedure Mandatory5Click(Sender: TObject);
    procedure Excluded4Click(Sender: TObject);
    procedure Excluded5Click(Sender: TObject);
    procedure AllClasses1Click(Sender: TObject);
    procedure Partial1Click(Sender: TObject);
    procedure Flagged1Click(Sender: TObject);
    procedure Partial4Click(Sender: TObject);
    procedure Flagged4Click(Sender: TObject);
    procedure VariRunCombsize1Click(Sender: TObject);
    procedure ImportData2Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DeferredNeMaPd1Click(Sender: TObject);
    procedure AvailableDblClick(Sender: TObject);
    procedure R1DblClick(Sender: TObject);
    procedure R2DblClick(Sender: TObject);
    procedure PartialDblClick(Sender: TObject);
    procedure FlaggedDblClick(Sender: TObject);
    procedure ExcludedDblClick(Sender: TObject);
    procedure ExtendedFunctions1Click(Sender: TObject);
    procedure TryShowExtraTools;
    procedure btnSelectClick(Sender: TObject);
    procedure RestoreDefaultOptions1Click(Sender: TObject);
    procedure RestoreDefaultOptions;
    procedure SaveOptions1Click(Sender: TObject);
    procedure ArcViewDDEForm1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IterateTillSatisfied1Click(Sender: TObject);
    procedure HidePartial1Click(Sender: TObject);
    procedure HideExcluded1Click(Sender: TObject);
    procedure SaveSiteGEOCODE1Click(Sender: TObject);
    procedure SaveToFileNAME1Click(Sender: TObject);
    procedure TargetPercentMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure toTarget1Click(Sender: TObject);
    procedure Area1Click(Sender: TObject);
    procedure PartialStatus1Click(Sender: TObject);
    procedure FeatureIrrep1Click(Sender: TObject);
    procedure mins1Click(Sender: TObject);
    procedure FeatureAmount1Click(Sender: TObject);
    procedure PartialStatus2Click(Sender: TObject);
    procedure FeatureIrreplaceability1Click(Sender: TObject);
    procedure toTarget2Click(Sender: TObject);
    procedure AllMatrixReports1Click(Sender: TObject);
    procedure AllMatrixReports2Click(Sender: TObject);
    procedure Reserved1Click(Sender: TObject);
    procedure Ignored1Click(Sender: TObject);
    procedure Negotiated5Click(Sender: TObject);
    procedure Mandatory1Click(Sender: TObject);
    procedure Negotiated6Click(Sender: TObject);
    procedure Mandatory6Click(Sender: TObject);
    procedure Partial5Click(Sender: TObject);
    procedure DeferredNeMa1Click(Sender: TObject);
    procedure DeferredNeMaPd2Click(Sender: TObject);
    procedure SetWorkingDirectory1Click(Sender: TObject);
    procedure Map1Click(Sender: TObject);
    procedure AddToMap1Click(Sender: TObject);
    procedure HideMandatory1Click(Sender: TObject);
    procedure ApplyFeatureClasses1Click(Sender: TObject);
    procedure IdentifyLowValueDeferrals1Click(Sender: TObject);
    procedure AddSelectionsfromfile1Click(Sender: TObject);
    procedure LaunchTableEditor1Click(Sender: TObject);
    procedure CheckTenureOfSelections1Click(Sender: TObject);
    function CheckTenure : boolean;
    procedure LoadSiteMatrixV4;
    procedure Lookup1Click(Sender: TObject);
    procedure Default2Click(Sender: TObject);
    procedure Default1Click(Sender: TObject);
    function rtnExeInstallPath : string;
    procedure ImportIStatusToShp;
    procedure UseDLL1Click(Sender: TObject);
    procedure ReportSpatialConfig1Click(Sender: TObject);
    procedure SpatialModule1Click(Sender: TObject);
    procedure LoadCustomizedReports(AIniFile : TIniFile);
    procedure ProcessFeatureRptClick(const sReportClicked : string);
    procedure ProcessSiteRptClick(const sReportClicked : string);
    procedure SiteRptBlank1Click(Sender: TObject);
    procedure SiteRptBlank2Click(Sender: TObject);
    procedure SiteRptBlank3Click(Sender: TObject);
    procedure SiteRptBlank4Click(Sender: TObject);
    procedure SiteRptBlank5Click(Sender: TObject);
    procedure SiteRptBlank6Click(Sender: TObject);
    procedure SiteRptBlank7Click(Sender: TObject);
    procedure SiteRptBlank8Click(Sender: TObject);
    procedure SiteRptBlank9Click(Sender: TObject);
    procedure SiteRptBlank10Click(Sender: TObject);
    procedure FeatureRptBlank1Click(Sender: TObject);
    procedure FeatureRptBlank2Click(Sender: TObject);
    procedure FeatureRptBlank3Click(Sender: TObject);
    procedure FeatureRptBlank4Click(Sender: TObject);
    procedure FeatureRptBlank5Click(Sender: TObject);
    procedure FeatureRptBlank6Click(Sender: TObject);
    procedure FeatureRptBlank7Click(Sender: TObject);
    procedure FeatureRptBlank8Click(Sender: TObject);
    procedure FeatureRptBlank9Click(Sender: TObject);
    procedure FeatureRptBlank10Click(Sender: TObject);
    procedure CleanDatabase;
    procedure ReportEMSFiles1Click(Sender: TObject);
    procedure ReportSpatialSpread1Click(Sender: TObject);
    procedure Stages1Click(Sender: TObject);
    procedure LoadVegArea;
    procedure SaveSparseMatrix;
    procedure SaveSparseMatrix1Click(Sender: TObject);
    {$IFDEF SPARSE_MATRIX}
    procedure LoadSparseMatrix(const sKeyFile, sValueFile : string;
                               const fPopulateSiteListboxes : boolean);
    procedure SaveSparseMatrixBinary(const sKeyFile, sValueFile : string);
    procedure Convert2Sparse(const iSites, iFeatures : integer);
    procedure ConvertV1Matrix2Sparse(const iSites, iFeatures : integer);
    procedure ConvertV3Matrix2Sparse(const iSites, iFeatures : integer);
    procedure ConvertV4Matrix2Sparse(const iSites, iFeatures : integer);
    {$ELSE}
    procedure SaveSparseBinMatrix;
    {$ENDIF}
    procedure SparseInitArrays;
    procedure SparsePostInitArrays;
    procedure LoadFeatureInformation;
    procedure CombinationSizeOptions1Click(Sender: TObject);
    procedure ResetSelections;
    procedure RandomSiteSelection1Click(Sender: TObject);
    procedure Sites1Click(Sender: TObject);
    procedure Features1Click(Sender: TObject);
    procedure S1Click(Sender: TObject);
    procedure ClearSelections1Click(Sender: TObject);
    procedure AddStageToSHPFile1Click(Sender: TObject);
    procedure ProduceSFvalidationmatrix1Click(Sender: TObject);
    procedure MapRedundantSites1Click(Sender: TObject);
    procedure SFTimerTimer(Sender: TObject);
    procedure ChangeTargetField(const sField : string);
    procedure ReadFeatureTarget(const sField : string);
    procedure LoadTargetFields(SomeItems : TStrings);
    procedure LoadSiteFields(SomeItems : TStrings);
    procedure Create_shpfields;
    procedure Validate1Click(Sender: TObject);
    procedure FastMinset1Click(Sender: TObject);
    procedure LaunchTableEditorOldVersion1Click(Sender: TObject);
    procedure FindReplacementSites;
    procedure ReplacementSites1Click(Sender: TObject);
    procedure SendPrepareSpread1Click(Sender: TObject);
    procedure TargetProgress1Click(Sender: TObject);
    procedure CPlanFeatureIndexCFI1Click(Sender: TObject);
    procedure FeatureInfo1Click(Sender: TObject);
    procedure SiteInfo1Click(Sender: TObject);
    procedure LabelNeMa;
    procedure OpenLOGfilepreversion351Click(Sender: TObject);
    procedure a_r3Click(Sender: TObject);
    procedure a_r4Click(Sender: TObject);
    procedure a_r5Click(Sender: TObject);
    procedure b_r3Click(Sender: TObject);
    procedure b_r4Click(Sender: TObject);
    procedure b_r5Click(Sender: TObject);
    procedure c_r3Click(Sender: TObject);
    procedure c_r4Click(Sender: TObject);
    procedure c_r5Click(Sender: TObject);
    procedure d_r3Click(Sender: TObject);
    procedure d_r4Click(Sender: TObject);
    procedure d_r5Click(Sender: TObject);
    procedure DisplayWarningsClick(Sender: TObject);
    procedure FindReplacementSitesAllAv(const sFilename, sFilename2 : string;
                                        const fOutFile, fOutFile2 : boolean);
    procedure OpenSelectionsolderversions1Click(Sender: TObject);
    procedure MarxanPrototype1Click(Sender: TObject);
    procedure Options2Click(Sender: TObject);
    procedure BuildDatabase1Click(Sender: TObject);
    procedure EditReserveClasses1Click(Sender: TObject);
    procedure CIBulkSitePartialProtection1Click(Sender: TObject);
    procedure CleanDatabaseMarxanRuns;
    procedure BLFConverter1Click(Sender: TObject);
    procedure DumpMatrixwithSiteNameaskey1Click(Sender: TObject);
    procedure MalRandomSiteSelection1Click(Sender: TObject);
    procedure EditAllTargets1Click(Sender: TObject);
    procedure ImportTargetField1Click(Sender: TObject);
    procedure Summaris1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }


    {$IFDEF VER80}
    SystemConv : TNPWSDdeClientConv;
    SystemItem : TNPWSDdeClientItem;
    MapConv : TNPWSDdeClientConv;
    MapItem : TNPWSDdeClientItem;
    {$ELSE}
    SystemConv : TDdeClientConv;
    SystemItem : TDdeClientItem;
    MapConv : TDdeClientConv;
    MapItem : TDdeClientItem;
    {$ENDIF}

end;

function ExecuteCPlanApplication(const hParent : THandle; const sDatabase, sTopic : string) : integer; export;
{forward declaration, WinERMS calls this function to start the Conservation module}

procedure AddEMSDate;

procedure HintsOn;
procedure HintsOff;

function Bool2String(const fValue : boolean) : string;
{function Float2String(const rValue : extended; const iDigits : integer) : string;
{Float2String, iDigits is the number of digits to leave after the decimal point}

{$IFNDEF SPARSE_MATRIX_2}
procedure FreeContrib(var Contrib : GraphData_T);
{$ENDIF}
{frees up memory used by a contribution object}

function BrowseSelection(const sFileName : string) : boolean;
{load.s EMSReason from sFileName to BrowseEMSReason,
 for use in browsing reasons on saved .ems files}



{$IFDEF FASTINIT}
procedure ArcViewFInit;
{$ENDIF}

procedure LoadDBMSDisplayFields;
procedure HighlightMemo(var ThisMemo : TMemo);
procedure UnHighlightMemo(var ThisMemo : TMemo);
procedure LabelCountUpdate;
procedure SetControlCaption;

procedure Autosave;
function SaveSelections(const sFileName : string;
                        const fReadOnly : boolean) : boolean;

procedure DumpMemInfo(const s:string);

procedure ReInitMem(const fFreeControl : boolean);
{called to dispose all memory objects and forms ready for another database run}

procedure InitPrep01;

function RunCPlanApp(const sApp, sParam : string) : boolean;
{run an application in the C-Plan install directory}

function IsSeperator(const sLine : string) : boolean;
{determines whether line is EMS file seperator}

procedure ReInitWeightedSumirr;


procedure LoadConfigSubsets;  // Load the subsets we want to 'calculate config' with from the INI file
procedure InitConfigSubsets;  // Initialise all 'calculate config' subsets to false

function LoadSelections(const sFileName : string) : boolean;
function LoadSelectionsOldVersion(const sFileName : string) : boolean;
function CheckSelections : boolean;
function LoadIniMatSize : boolean;

procedure InitMinsetSumirrWeightings;
procedure FreeMinsetSumirrWeightings;
procedure ExceptionDebug(const sMsg : string);
procedure UpdateMinsetSumirrWeightingArrays;
function IsLegalFileCharacter(const cChar : char) : boolean;
function TableContainsField(const ATable : TTable;
                            const sFieldName : string) : boolean;
function RegionSafeStrToFloat(const sCell : string) : extended;
function RegionSafeFloatToStr(const rValue : extended) : string;
procedure CalcExcludeTrimAmount;
procedure _DisplayWarnings;
function Bool2Int(const fBool : boolean) : integer;

var
  ControlForm: TControlForm;
  ControlRes : ControlResPointer_T;
  {$IFNDEF SPARSE_MATRIX_2}
  GraphContribution : GraphData_T;
  {$ENDIF}
  ermsHandle : THandle;
  {variable for storing weighted summed irreplaceability variables}
  WeightedSumirr,
  {InitialValues,}
  VegArea, SiteRichness, {ContribArea,} {contributing versus available area for all sites features}
  SiteArr, SiteCodes, OrdSiteArr,
  FeatArr, FeatCodes, OrdFeatArr,
  ValidateSite, ValidateFeature : Array_T;

  iSFTimerSites, iSFTimerFeatures,
  iIrrepStartResult, iRandomMan, iRandomSel, iDBToLoad,
  iZeroTrimmedTargetCount, iPrevUpdate,
  iFeatureCount, iSiteCount,
  iDBLoaded, iSubLayer, {variable number of subcompartment layer (if available)}
  iWinermsKeyClick, {holds the geocode of the last site clicked on in WinERMS}
  iLastCodeGrabbed : integer; {holds the last WinERMS geocode used (for comparison)}

  fHedleySimulatorDebug,
  fDDEConnected, fMinimiseOnDone,
  fShowHints,
  fSelectionChange,
  fFlagSelectionChange,
  fIniChange, fContrDataDone, fContrDoneOnce,
  fFirstStart, fCaptionProgress, fSubCompts, fKeepHighlight, fUsingFeat,
  fLinkToArcView, {indicates whether parameter to indicate linkage with ArcView has been used in CPlan call}
  fReallyExit, fProposeSites, fWatchUnDef, fWatchExc : boolean;

  pDDESelectionInfo : PChar;
  hDDESelectionInfo : THandle;

  //ExcludedSiteArea : ExcludedSiteArea_T;

  ProgressLastUpdate, One_Sec : TDateTime;

  rPercentage : extended;

  ReportTarget,
  PointFeatures,
  FeatureAmount,
  GISSiteValues,
  MappedSites,
  MinsetSumirrWeightings, InitialAvailableCrown,
  PrivateLandReserved, MaximumAvailableArea,
  SiteVuln, SiteCost : Array_t;

  fExecuteIrreplaceabilityAndDie, fExecuteMinsetAndDie : boolean;
  sExecuteMinsetFileName : string;

{-------------------------------------------------------------------------------------}

implementation

uses Rununit, Editstr, Choosefi, Start,
     Sf_irrep, Calcfld,
     Choosere, Featrepd, Sitelist,
     Sct_grid, F1find, Edit,
     Partl_ed,
     Defrqry, Exclqry,
     Resttarg, Combfile, Resize,
     Highligh, Convert, Toolview,
     Choosedb, Opt1, Toolmisc, Binfile,
     Randtest, Editcoun, Calcdef, reg,
     Validate, Rules, FileCtrl, comp2coo,
     OrdClass, Arr2Lbox, arithrle,
     spatio,
     reports,
     trimini,
     destruct, reinit, in_order,
     Dll_u1, itersear, minset, pctarg, editrule, workdir, chooseoc,
     svalue, use_dll, saverpt, batchEMS, randinfo,
     choosedbf, RedundancyCheck, select_tgt_field,
     mthread, fast_minset, sitefeatlookup, featlookupfields, linegraph,
  rptMeasure2, displayfeatures, displaysites, displaywarnings, marxan_files,
  marxan, BLF_process, random_selection, EasyEditTargets,
  import_target_field, SummariseClumps,
     ZCDDE_unit, version;

{$R *.DFM}

procedure InitGISSiteValues;
var
   iCount : integer;
   rValue : extended;
begin
     GISSiteValues := Array_t.Create;
     GISSiteValues.init(SizeOf(extended),iSiteCount);
     rValue := 0;
     for iCount := 1 to iSiteCount do
         GISSiteValues.setValue(iCount,@rValue);
end;

function IsLegalFileCharacter(const cChar : char) : boolean;
begin
     case cChar of
          '\', '/', ';', '*', '?', '"', '<', '>', '|' : Result := False;
     else
         Result := True;
     end;
end;

function FieldIsNotRecognised(const sFieldName : string) : boolean;
var
   sUpperCase : string;
begin
     // test if field name is a recognised feature field
     Result := True;
     sUpperCase := UpperCase(sFieldName);

     if (sUpperCase = 'FEATKEY') then
        Result := False;
     if (sUpperCase = 'FEATNAME') then
        Result := False;
     if (sUpperCase = 'VULN') then
        Result := False;

     // FEATKEY FEATNAME VULN DESTRATE
end;

procedure TControlForm.LoadSiteFields(SomeItems : TStrings);
var
   iCount : integer;
begin
     try
        try
           OutTable.Open;
        except
              Screen.Cursor := crDefault;

              MessageDlg('Could not access Site Table - ' +
                         OutTable.DatabaseName + '\' +
                         OutTable.TableName,mtWarning,[mbOK],0);
              Exit;
        end;

        // now extract the list of field names from the table, adding them to the list

        SomeItems.Clear;
        if (OutTable.FieldCount > 0) then
           for iCount := 0 to (OutTable.FieldCount-1) do
               SomeItems.Add(OutTable.FieldDefs.Items[iCount].Name);

        OutTable.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadSiteFields',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TControlForm.LoadTargetFields(SomeItems : TStrings);
var
   pFeat : featureoccurrencepointer;
   iCount : integer;
   sFieldName : string;
begin
     try
        try
           CutOffTable.Open;
        except
              Screen.Cursor := crDefault;

              MessageDlg('Could not access Feature Table - ' +
                         CutOffTable.DatabaseName + '\' +
                         CutOffTable.TableName,mtWarning,[mbOK],0);
              Exit;
        end;

        // now extract the list of field names from the table, adding them to the
        // list if they are not one of our regular field names

        SomeItems.Clear;
        if (CutOffTable.FieldCount > 0) then
           for iCount := 0 to (CutOffTable.FieldCount-1) do
           begin
                sFieldName := CutOffTable.FieldDefs.Items[iCount].Name;
                if FieldIsNotRecognised(sFieldName) then
                   SomeItems.Add(sFieldName);
           end;

        CutOffTable.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadTargetFields',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TControlForm.ReadFeatureTarget(const sField : string);
var
   iCount : integer;
   pFeat : featureoccurrencepointer;
begin
     // load the specified field from the feature table and use
     // it as the ITARGET for C-Plan
     try
        new(pFeat);
        ControlRes^.sFeatureTargetField := sField;
        try
           CutOffTable.Open;
        except
              Screen.Cursor := crDefault;

              MessageDlg('Could not access Feature Table - ' +
                         CutOffTable.DatabaseName + '\' +
                         CutOffTable.TableName,mtWarning,[mbOK],0);
              Exit;
        end;

        while not CutOffTable.EOF do
        begin
             for iCount := 1 to iFeatureCount do
             begin
                  FeatArr.rtnValue(iCount,pFeat);

                  if (pFeat^.code = CutOffTable.FieldByName(ControlRes^.sFeatureKeyField).AsInteger) then
                  begin
                       pFeat^.rCutOff := CutOffTable.FieldByName(sField).AsFloat * ControlRes^.rTargetMultiplyFactor;

                       FeatArr.setValue(iCount,pFeat);
                  end;
             end;
             CutOffTable.Next;
        end;
        CutOffTable.Close;
        dispose(pFeat);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReadFeatureTarget',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TControlForm.ChangeTargetField(const sField : string);
var
   fStop : boolean;
begin
     try
        ReadFeatureTarget(sField);

        FitComponents2Form;
        ReInitializeInitialValues(TargetChange);

        ExecuteIrreplaceability(-1,False,False,True,True,'');

     except
           MessageDlg('Exception in ChangeTargetField',mtError,[mbOk],0);
     end;
end;

procedure ExceptionDebug(const sMsg : string);
begin
     // write log file
     //SaveSelections(ControlRes^.sWorkingDirectory + '\exception.log',False);
     // the log file is now written by GenerateDebugReports

     // write ini file
     ControlForm.SaveIni(ControlForm,ControlRes^.sWorkingDirectory + '\exception.ini');

     // display error message
     MessageDlg(sMsg + Chr(10) + Chr(13) +
                'exception.log and exception.ini have been created in the working directory.',mtError,[mbOk],0);

     // terminate application
     Application.Terminate;
end;

procedure SetMinsetSumirrWeightingArrays;
var
   iCount, iFeatures : integer;
   pSite : sitepointer;
   rIAC, rPLR, rMAA : extended;
   Value : ValueFile_T;
   fCrown, fReserved : boolean;
begin
     // Initialise values for :
     //   InitialAvailableCrown
     //   PrivateLandReserved
     //   MaximumAvailableArea
     try
        LoadCrownStatus(False);

        new(pSite);

        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);
             CrownLandSites.rtnValue(iCount,@fCrown);
             if (pSite^.richness > 0) then
                for iFeatures := 1 to pSite^.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffSet + iFeatures,@Value);
                     SparsePartial.rtnValue(pSite^.iOffset + iFeatures,@fReserved);

                     // accumulate initial available crown land
                     if (pSite^.status <> Re)
                     and (pSite^.status <> Ig)
                     and fCrown then
                     begin
                          InitialAvailableCrown.rtnValue(Value.iFeatKey,@rIAC);
                          rIAC := rIAC + Value.rAmount;
                          InitialAvailableCrown.setValue(Value.iFeatKey,@rIAC);
                     end;

                     // accumulate reserved private land
                     if (pSite^.status = _R1)
                     or (pSite^.status = _R2)
                     or (pSite^.status = _R3)
                     or (pSite^.status = _R4)
                     or (pSite^.status = _R5)
                     or ((pSite^.status = Pd)
                         and fReserved) then
                        if not fCrown then
                        begin
                             PrivateLandReserved.rtnValue(Value.iFeatKey,@rPLR);
                             rPLR := rPLR + Value.rAmount;
                             PrivateLandReserved.setValue(Value.iFeatKey,@rPLR);
                        end;

                     // determine maximum available area
                     if (pSite^.status = Av)
                     or (pSite^.status = Fl) then
                     begin
                          MaximumAvailableArea.rtnValue(Value.iFeatKey,@rMAA);
                          if (Value.rAmount > rMAA) then
                          begin
                               rMAA := Value.rAmount;
                               MaximumAvailableArea.setValue(Value.iFeatKey,@rMAA);
                          end;
                     end;
                end;
        end;

        dispose(pSite);

     except

     end;
end;

procedure UpdateMinsetSumirrWeightingArrays;
var
   iCount, iFeatures : integer;
   rPLR, rMAA : extended;
   pSite : sitepointer;
   fCrown, fReserved : boolean;
   Value : ValueFile_T;
begin
     // Update values for :
     //   PrivateLandReserved
     //   MaximumAvailableArea
     try
        rPLR := 0;
        rMAA := 0;
        for iCount := 1 to iFeatureCount do
        begin // init the arrays to zero so values can be accumulated
             PrivateLandReserved.setValue(iCount,@rPLR);
             MaximumAvailableArea.setValue(iCount,@rMAA);
        end;

        new(pSite);

        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);
             CrownLandSites.rtnValue(iCount,@fCrown);
             if (pSite^.richness > 0) then
                for iFeatures := 1 to pSite^.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffSet + iFeatures,@Value);
                     SparsePartial.rtnValue(pSite^.iOffset + iFeatures,@fReserved);

                     // accumulate reserved private land
                     if (pSite^.status = _R1)
                     or (pSite^.status = _R2)
                     or (pSite^.status = _R3)
                     or (pSite^.status = _R4)
                     or (pSite^.status = _R5)
                     or ((pSite^.status = Pd)
                         and fReserved) then
                        if not fCrown then
                        begin
                             PrivateLandReserved.rtnValue(Value.iFeatKey,@rPLR);
                             rPLR := rPLR + Value.rAmount;
                             PrivateLandReserved.setValue(Value.iFeatKey,@rPLR);
                        end;

                     // determine maximum available area
                     if (pSite^.status = Av)
                     or (pSite^.status = Fl) then
                     begin
                          MaximumAvailableArea.rtnValue(Value.iFeatKey,@rMAA);
                          if (Value.rAmount > rMAA) then
                          begin
                               rMAA := Value.rAmount;
                               MaximumAvailableArea.setValue(Value.iFeatKey,@rMAA);
                          end;
                     end;
                end;
        end;

        dispose(pSite);

     except
     end;
end;

procedure InitMinsetSumirrWeightings;
var
   iCount : integer;
   MSW : MinsetSumirrWeightings_T;
   rValue : extended;
begin
     try
        // create MinsetSumirrWeightings and initialise it
        MinsetSumirrWeightings := Array_t.Create;
        MinsetSumirrWeightings.init(SizeOf(MinsetSumirrWeightings_T),iSiteCount);
        MSW.rWcr := 0;
        MSW.rWpt := 0;
        MSW.rWcrWit := 0;
        MSW.rWcrWvu := 0;
        MSW.rWcrWitWvu := 0;
        MSW.rWsa := 0;
        MSW.rWsaWpa := 0;
        MSW.rWsaWpt := 0;
        MSW.rWpaWpt := 0;
        for iCount := 1 to iSiteCount do
            MinsetSumirrWeightings.setValue(iCount,@MSW);

        // create the 3 associated data structures we need to maintain for the
        // new weightings
        InitialAvailableCrown := Array_t.Create;
        PrivateLandReserved := Array_t.Create;
        MaximumAvailableArea := Array_t.Create;
        InitialAvailableCrown.init(SizeOf(extended),iFeatureCount);
        PrivateLandReserved.init(SizeOf(extended),iFeatureCount);
        MaximumAvailableArea.init(SizeOf(extended),iFeatureCount);
        rValue := 0;
        for iCount := 1 to iFeatureCount do
        begin // init the arrays to zero so values can be accumulated
             InitialAvailableCrown.setValue(iCount,@rValue);
             PrivateLandReserved.setValue(iCount,@rValue);
             MaximumAvailableArea.setValue(iCount,@rValue);
        end;

        SetMinsetSumirrWeightingArrays

     except
     end;
end;

procedure FreeMinsetSumirrWeightings;
begin
     try
        // dispose MinsetSumirrWeightings
        MinsetSumirrWeightings.destroy;
        // dispose the 3 associated data structures
        InitialAvailableCrown.destroy;
        PrivateLandReserved.destroy;
        MaximumAvailableArea.destroy;
     except
     end;
end;

procedure TControlForm.ResetSelections;
begin
     // de-select all selected sites and adjust settings so it is
     // just as if we just restarted C-Plan
end;

procedure RemoveIniSpaces;
var
   IniForm : TTrimIniForm;
   sIniFile : string;
begin
     IniForm := TTrimIniForm.Create(Application);

     if ControlRes^.fOldIni then
        sIniFile := ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME
     else
         sIniFile := ControlRes^.sDatabase + '\' + INI_FILE_NAME;

     IniForm.DeleteRedundantBlankLines(sIniFile);
     IniForm.Free;
end;

procedure LoadConfigSubsets;
var
   iCount : integer;
   MyIni : TIniFile;
begin
     try
        if ControlRes^.fOldIni then
           MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
        else
            MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);

        {load Spatial Configuration Tool settings}
        ControlRes^.fConnectSPATTOOL := MyIni.ReadBool('Spatial Tool','ConnectSpatialTool',FALSE);
        //ControlRes^.sSpatialDistanceFile := MyIni.ReadString('Spatial Tool','SpatialDistanceFile','');
        ControlRes^.iSpatialVariableToPass := MyIni.ReadInteger('Spatial Tool','SpatialVariableToPass',0);

        ControlRes^.rSpatContribReservedWeight := RegionSafeStrToFloat(MyIni.ReadString('Spatial Tool',
                                                                              'SpatialContribReservedWeighting',
                                                                              '1'));
        ControlRes^.iSpatialContribRadius := StrToInt(MyIni.ReadString('Spatial Tool','SpatialContribRadius','1000'));
        ControlRes^.rSpatialContribExponent := RegionSafeStrToFloat(MyIni.ReadString('Spatial Tool','SpatialContribExponent','0.5'));

        ControlRes^.rSpatialConfigAreaWeighting := MyIni.ReadInteger('Spatial Tool',
                                                                     'SpatialConfigAreaWeighting',
                                                                     5000);
        ControlRes^.iSpatialVectorsToPass := 0;
        if ControlRes^.fFeatureClassesApplied then
           for iCount := 1 to 10 do
           begin
                ControlRes^.fDoConfigOnSubset[iCount] := MyIni.ReadBool(
                                                                 'Spatial Tool',
                                                                 'ConfigSubset' + IntToStr(iCount),
                                                                 False);

                if ControlRes^.fDoConfigOnSubset[iCount] then
                begin
                     ControlRes^.fDoConfigOnSubset[iCount] := ControlRes^.ClassDetail[iCount];
                     if ControlRes^.fDoConfigOnSubset[iCount] then
                        Inc(ControlRes^.iSpatialVectorsToPass);
                end;
           end;

        MyIni.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Load Spatial Config Settings',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure InitConfigSubsets;
var
   iCount : integer;
begin
     for iCount := 1 to 10 do
         ControlRes^.fDoConfigOnSubset[iCount] := False;
     ControlRes^.iSpatialVectorsToPass := 0;
end;

{$IFDEF SPARSE_MATRIX}
procedure TControlForm.LoadSparseMatrix(const sKeyFile, sValueFile : string;
                                        const fPopulateSiteListboxes : boolean);
var
   iCount, iIndex, iValueElements, iOffset : integer;
   pSite : sitepointer;
   Key : KeyFile_T;
   Value : ValueFile_T;
   SingleValue : SingleValueFile_T;
   KeyFile, ValueFile : file;
   sI_STATUS, sTest : string;
   fValidate, fLoadValidateField, fLoadSubclassField, fTENUREpresent : boolean;
   iValidate : integer;
   procedure InitSiteValues;
   var
      iI : integer;
   begin
        with pSite^ do
        begin
             status := Av;
             fSiteHasUse := False;
             sName := '';
             sDisplay := '';
             iKey := 0;
             area := 0;
             richness := 0;
             rPCUSED := 0;
             rSummedIrr := 0;
             rSummedIrrVuln2 := 0;
             rWAVIRR := 0;
             rIrreplaceability := 0;
             for iI := 1 to 10 do
             begin
                  rSubsetIrr[iI] := 0;
                  rSubsetSum[iI] := 0;
             end;
             for iI := 1 to 5 do
             begin
                  rSubsetWav[iI] := 0;
                  rSubsetPCUsed[iI] := 0;
             end;
        end;
   end;

begin
     try
        // create validate site array
        ValidateSite := Array_t.Create;
        ValidateSite.init(SizeOf(boolean),iSiteCount);
        fValidate := True;
        for iCount := 1 to iSiteCount do
                ValidateSite.setValue(iCount,@fValidate);
        ValidateFeature := Array_t.Create;
        ValidateFeature.init(SizeOf(boolean),iFeatureCount);
        for iCount := 1 to iFeatureCount do
                ValidateFeature.setValue(iCount,@fValidate);

        assignfile(KeyFile,sKeyFile);
        reset(KeyFile,1);
        assignfile(ValueFile,sValueFile);
        reset(ValueFile,1);

        iValueElements := FileSize(ValueFile) div SizeOf(SingleValueFile_T);

        FeatureAmount := Array_t.Create;
        FeatureAmount.init(SizeOf(ValueFile_T),iValueElements);

        // read feature values from the feature value file
        for iCount := 1 to iValueElements do
        begin
             BlockRead(ValueFile,SingleValue,SizeOf(SingleValueFile_T));
             Value.iFeatKey := SingleValue.iFeatKey;
             Value.rAmount := SingleValue.rAmount;
             FeatureAmount.setValue(iCount,@Value);
        end;

        iValueElements := FileSize(KeyFile) div SizeOf(KeyFile_T);

        OutTable.Open;
        {try I_STATUS, if this doesn't exist use TENURE}
        if not ControlRes^.fStatusTested then
        begin
             ControlRes^.fStatusTested := True;
             try
                sTest := OutTable.FieldByName('I_STATUS').AsString;
                ControlRes^.sI_STATUSField := 'I_STATUS';
             except
                   ControlRes^.sI_STATUSField := 'TENURE';
             end;
        end;
        try
           fLoadValidateField := TableContainsField(OutTable,'VALIDATE');
           //sTest := OutTable.FieldByName('VALIDATE').AsString;
           //fLoadValidateField := True;
        except
              //fLoadValidateField := False;
        end;

        fTENUREpresent:= TableContainsField(OutTable,'TENURE');

        try
           fLoadSubclassField := TableContainsField(OutTable,'SUBCLASS');
        except
        end;
        new(pSite);
        InitSiteValues;
        iOffset := 0;
        // read feature richness and offset from the key file
        for iCount := 1 to iSiteCount do
            if (iCount <= iValueElements) then
            begin
                 //SiteArr.rtnValue(iCount,pSite);
                 BlockRead(KeyFile,Key,SizeOf(KeyFile_T));
                 pSite^.iOffset := iOffset;
                 pSite^.richness := Key.iRichness;
                 Inc(iOffset,Key.iRichness);

                 if fLoadValidateField then
                 begin
                      try
                         iValidate := OutTable.FieldByName('VALIDATE').AsInteger;
                         if (iValidate = 1) then
                            fValidate := True
                         else
                             fValidate := False;
                      except
                            fValidate := False;
                      end;
                      ValidateSite.setValue(iCount,@fValidate);
                 end;

                 // read Site NAME, SITEKEY, I_STATUS & AREA
                 try
                    pSite^.sName := OutTable.FieldByName('NAME').AsString;
                 except
                       pSite^.sName := OutTable.FieldByName(ControlRes^.sKeyField).AsString;
                 end;
                 pSite^.iKey := OutTable.FieldByName(ControlRes^.sKeyField).AsInteger;
                 pSite^.area := OutTable.FieldByName('AREA').AsFloat;
                 sI_STATUS := OutTable.FieldByName(ControlRes^.sI_STATUSField).AsString;
                 if fLoadSubclassField then
                    pSite^.sSubclass := OutTable.FieldByName('SUBCLASS').AsString
                 else
                     pSite^.sSubclass := '';
                 if (sI_STATUS = 'Initial Reserve')
                 or (sI_STATUS = 'Reserved') then
                 begin
                      pSite^.status := Re;
                      if fPopulateSiteListboxes then
                      begin
                           Reserved.Items.Add(pSite^.sName);
                           ReservedKey.Items.Add(IntToStr(pSite^.iKey))
                      end;
                 end
                 else
                     if (sI_STATUS = 'Initial Excluded')
                     or (sI_STATUS = 'Ignored') then
                     begin
                          pSite^.status := Ig;
                          if fPopulateSiteListboxes then
                          begin
                               Ignored.Items.Add(pSite^.sName);
                               IgnoredKey.Items.Add(IntToStr(pSite^.iKey))
                          end;
                     end
                     else
                     begin
                          pSite^.status := Av;
                          if fPopulateSiteListboxes then
                          begin
                               Available.Items.Add(pSite^.sName);
                               AvailableKey.Items.Add(IntToStr(pSite^.iKey))
                          end;
                     end;
                 if fTENUREpresent then
                 begin
                      if (OutTable.FieldByName('TENURE').AsString = 'Partial Protection') then
                         pSite^.fPartialProtection := True
                      else
                          pSite^.fPartialProtection := False;
                 end
                 else
                     pSite^.fPartialProtection := False;

                 SiteArr.setValue(iCount,pSite);
                 SiteCodes.setValue(iCount,@pSite^.iKey);
                 OutTable.Next;
            end;
        OutTable.Close;
        dispose(pSite);
        closefile(KeyFile);
        closefile(ValueFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception loading sparse matrix',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TControlForm.SaveSparseMatrixBinary(const sKeyFile, sValueFile : string);
var
   iCount, iIndex, iOffset : integer;
   pSite : sitepointer;
   Key : KeyFile_T;
   Value : ValueFile_T;
   SingleValue : SingleValueFile_T;
   KeyFile, ValueFile : file;
   sI_STATUS, sTest : string;
   fValidate, fLoadValidateField, fLoadSubclassField, fTENUREpresent : boolean;
   iValidate : integer;
begin
     try
        assignfile(KeyFile,sKeyFile);
        rewrite(KeyFile,1);
        assignfile(ValueFile,sValueFile);
        rewrite(ValueFile,1);

        // write feature values to the feature value file
        for iCount := 1 to FeatureAmount.lMaxSize do
        begin
             // need to check if feature amount is > 0 before writing

             FeatureAmount.rtnValue(iCount,@Value);
             SingleValue.iFeatKey := Value.iFeatKey;
             SingleValue.rAmount := Value.rAmount;

             BlockWrite(ValueFile,SingleValue,SizeOf(SingleValueFile_T));
        end;

        // write offset and richness to the key file


        iOffset := 0;
        new(pSite);
        // read feature richness and offset from the key file
        for iCount := 1 to iSiteCount do
        begin
             // need to check if feature amount is > 0 before incrementing site richness and writing
             // need to recompute offset in case 0 elements have been deleted

             SiteArr.rtnValue(iCount,pSite);
             Key.iRichness := pSite^.richness;
             Key.iSiteKey := pSite^.iKey;

             BlockWrite(KeyFile,Key,SizeOf(KeyFile_T));
        end;
        dispose(pSite);
        closefile(KeyFile);
        closefile(ValueFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in SaveSparseMatrix',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TryDeleteFile(sFile : string);
begin
     if FileExists(sFile) then
        DeleteFile(PChar(sFile));
end;

procedure TControlForm.Convert2Sparse(const iSites, iFeatures : integer);
var
   iMatrixVersion : integer;
   sMatrixName, sExtension : string;
begin
     try
        // convert the MAT file into a MTX and KEY file
        if (ControlRes^.sSparseMatrix = '') then
           if FileExists(ControlRes^.sDatabase +
                         '\' +
                         ControlRes^.sSiteFeatureTable) then
              begin
                   sMatrixName := ExtractFileName(ControlRes^.sSiteFeatureTable);
                   sExtension := ExtractFileExt(ControlRes^.sSiteFeatureTable);
                   Delete(sMatrixName,Pos(sExtension,sMatrixName),Length(sExtension));

                   ControlRes^.sSparseMatrix := sMatrixName + '.mtx';
                   ControlRes^.sSparseKey := sMatrixName + '.key';

                   iMatrixVersion := GetMatrixVer;
                   case iMatrixVersion of
                        1 : ConvertV1Matrix2Sparse(iSites, iFeatures);
                        3 : ConvertV3Matrix2Sparse(iSites, iFeatures);
                        4 : ConvertV4Matrix2Sparse(iSites, iFeatures);
                        2 :
                        begin
                             Screen.Cursor := crDefault;
                             MessageDlg('You cannot load 16 bit MAT files.' +
                                        Chr(10) + Chr(13) +
                                        'Use Table_ed to build a new database.',
                                        mtError,[mbOk],0);
                             Application.Terminate;
                             exit;
                        end;
                   end;
              end;

        // now delete the original matrix file
        //TryDeleteFile(PChar(ControlRes^.sDatabase+'\'+ControlRes^.sSiteFeatureTable));
        //At the moment, we are leaving this file, just in case of unforseen problems

        // Now delete the 8 .bin files that may be left behind from a previous version
        // of C-Plan and are now redundant
        TryDeleteFile(PChar(ControlRes^.sDatabase +
                            '\' +
                            Copy(ControlRes^.sSiteFeatureTable,
                                 1,
                                 Length(ControlRes^.sSiteFeatureTable)-4) +
                            '.bin'));
        TryDeleteFile(PChar(ControlRes^.sDatabase +
                            '\' +
                            Copy(ControlRes^.sFeatCutOffsTable,
                                 1,
                                 Length(ControlRes^.sFeatCutOffsTable)-4) +
                            '.bin'));
        TryDeleteFile(PChar(ControlRes^.sDatabase +
                            '\av.bin'));
        TryDeleteFile(PChar(ControlRes^.sDatabase +
                            '\avg.bin'));
        TryDeleteFile(PChar(ControlRes^.sDatabase +
                            '\ig.bin'));
        TryDeleteFile(PChar(ControlRes^.sDatabase +
                            '\igg.bin'));
        TryDeleteFile(PChar(ControlRes^.sDatabase +
                            '\re.bin'));
        TryDeleteFile(PChar(ControlRes^.sDatabase +
                            '\reg.bin'));
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception converting matrix to sparse matrix',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


procedure TControlForm.ConvertV1Matrix2Sparse(const iSites, iFeatures : integer);
var
   OutputMatrix, OutputKey : file;
   iIndex, iBuffPos, iRichness, iReadResult : integer;
   wBytesRead, wResult : word;
   rValue : extended;
   Key : KeyFile_T;
   //SingleValue : SingleValueFile_T;
   Value : SingleValueFile_T;
   MyIni : TIniFile;

   // LoadSiteMatrix
   MatrixFile : file of Buff_T;
   MatrixFile2 : file of LargeBuff_T;
   iCount, wOldCursor, iSitesInFile : integer;
   ThisSite : site;
   ABuff : Buff_T;
   ALargeBuff : LargeBuff_T;
   fEOF, fUseLargeBuff, fTrace : boolean;

begin
     try
        fUseLargeBuff := LoadIniMatSize;
        if fUseLargeBuff then
        begin
             assignfile(MatrixFile2,ControlRes^.sDatabase+'\'+ControlRes^.sSiteFeatureTable);
             reset(MatrixFile2);
             read(MatrixFile2,ALargeBuff);
        end
        else
        begin
             assignfile(MatrixFile,ControlRes^.sDatabase+'\'+ControlRes^.sSiteFeatureTable);
             reset(MatrixFile);
             read(MatrixFile,ABuff);
        end;
        OutTable.Open;
        // convert the MAT file into a MTX and KEY file
        assignfile(OutputMatrix,ControlRes^.sDatabase + '\' + ControlRes^.sSparseMatrix);
        rewrite(OutputMatrix,1);
        assignfile(OutputKey,ControlRes^.sDatabase + '\' + ControlRes^.sSparseKey);
        rewrite(OutputKey,1);
        iBuffPos := 0;

        for iCount := 1 to iSites do
        begin
             if fUseLargeBuff then
                read(MatrixFile2,ALargeBuff)
             else
                 read(MatrixFile,ABuff);

             iRichness := 0;
             // read the site key for this row
             Key.iSiteKey := OutTable.FieldByName(ControlRes^.sKeyField).AsInteger;
             for iIndex := 1 to iFeatures do
             begin
                  if fUseLargeBuff then
                     rValue := ALargeBuff[iIndex]
                  else
                      rValue := ABuff[iIndex];

                  if (rValue > 0) then
                  begin
                       Value.iFeatKey := iIndex;
                       Value.rAmount := rValue;
                       BlockWrite(OutputMatrix,Value,SizeOf(Value));
                       Inc(iRichness);
                  end;
             end;
             Key.iRichness := iRichness;
             BlockWrite(OutputKey,Key,SizeOf(Key));
             OutTable.Next;
        end;

        closefile(OutputMatrix);
        closefile(OutputKey);
        if fUseLargeBuff then
           closefile(MatrixFile2)
        else
            closefile(MatrixFile);
        OutTable.Close;

        // save the file names to the ini file
        if ControlRes^.fOldIni then
           MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
        else
            MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
        MyIni.WriteString('Options','SparseMatrix',ControlRes^.sSparseMatrix);
        MyIni.WriteString('Options','SparseKey',ControlRes^.sSparseKey);
        MyIni.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception converting version 1 matrix to sparse matrix',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TControlForm.ConvertV3Matrix2Sparse(const iSites, iFeatures : integer);
var
   OutputMatrix, OutputKey : file;
   iIndex, iRichness, iReadResult : integer;
   rValue : extended;
   Key : KeyFile_T;
   Value : SingleValueFile_T;
   MyIni : TIniFile;

   // LoadSiteMatrixV3
   MatrixFile2 : file;
   wBytesRead, wResult, wOldCursor, iCount, iInitFeatCount, iBuffPos : integer;
   ALargeBuff : LargeBuff_T;
   AHeader : MatFileHeader_T;
   wAWord : word;

   function GetNextReal : extended;
   begin
        if (iBuffPos = 0)
        or (iBuffPos > LARGE_BUFF_ARR_SIZE) then
        begin
             {read a block}
             BlockRead(MatrixFile2,ALargeBuff,SizeOf(ALargeBuff),iReadResult);
             if (iReadResult < SizeOf(ALargeBuff)) then
             begin
                  MessageDlg('EOF exceeded, matrix invalid',mtError,[mbOk],0);
                  Application.Terminate;
                  exit;
             end;
             iBuffPos := 1;
             Result := ALargeBuff[iBuffPos];
        end
        else
            Result := ALargeBuff[iBuffPos];
        Inc(iBuffPos);
   end;

begin
     iBuffPos := 0;
     try
        assignfile(MatrixFile2,ControlRes^.sDatabase+'\'+InTable.TableName);
        reset(MatrixFile2,1);
        BlockRead(MatrixFile2,AHeader,SizeOf(AHeader),wBytesRead);
        // convert the MAT file into a MTX and KEY file
        assignfile(OutputMatrix,ControlRes^.sDatabase + '\' + ControlRes^.sSparseMatrix);
        rewrite(OutputMatrix,1);
        assignfile(OutputKey,ControlRes^.sDatabase + '\' + ControlRes^.sSparseKey);
        rewrite(OutputKey,1);
        iBuffPos := 0;

        for iCount := 1 to iSites do
        begin
             iRichness := 0;
             rValue := GetNextReal; // read the site key for this row
             Key.iSiteKey := Round(rValue);
             for iIndex := 1 to iFeatures do
             begin
                  rValue := GetNextReal;
                  if (rValue > 0) then
                  begin
                       Value.iFeatKey := iIndex;
                       Value.rAmount := rValue;
                       BlockWrite(OutputMatrix,Value,SizeOf(Value));
                       Inc(iRichness);
                  end;
             end;
             Key.iRichness := iRichness;
             BlockWrite(OutputKey,Key,SizeOf(Key));
        end;

        closefile(OutputMatrix);
        closefile(OutputKey);
        closefile(MatrixFile2);

        // save the file names to the ini file
        if ControlRes^.fOldIni then
           MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
        else
            MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
        MyIni.WriteString('Options','SparseMatrix',ControlRes^.sSparseMatrix);
        MyIni.WriteString('Options','SparseKey',ControlRes^.sSparseKey);
        MyIni.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception converting version 3 matrix to sparse matrix',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TControlForm.ConvertV4Matrix2Sparse(const iSites, iFeatures : integer);
var
   InputMatrix, OutputMatrix, OutputKey : file;
   iCount, iIndex, iBuffPos, iRichness, iReadResult : integer;
   ALargeBuff : BuffV4_T;
   AHeader : MatFileHeader_T;
   wBytesRead, wResult : word;
   rValue : extended;
   Key : KeyFile_T;
   Value : SingleValueFile_T;
   MyIni : TIniFile;

   function GetNextReal : extended;
   begin
        if (iBuffPos = 0)
        or (iBuffPos > LARGE_BUFF_ARR_SIZE) then
        begin
             {read a block}
             BlockRead(InputMatrix,ALargeBuff,SizeOf(ALargeBuff),iReadResult);
             if (iReadResult < SizeOf(ALargeBuff)) then
             begin
                  MessageDlg('EOF exceeded, matrix invalid',mtError,[mbOk],0);
                  Application.Terminate;
                  exit;
             end;
             iBuffPos := 1;
             Result := ALargeBuff[iBuffPos];
        end
        else
            Result := ALargeBuff[iBuffPos];
        Inc(iBuffPos);
   end;

begin
     try
        // convert the MAT file into a MTX and KEY file
        assignfile(OutputMatrix,ControlRes^.sDatabase + '\' + ControlRes^.sSparseMatrix);
        rewrite(OutputMatrix,1);
        assignfile(OutputKey,ControlRes^.sDatabase + '\' + ControlRes^.sSparseKey);
        rewrite(OutputKey,1);
        assignfile(InputMatrix,ControlRes^.sDatabase + '\' + ControlRes^.sSiteFeatureTable);
        reset(InputMatrix,1);
        iBuffPos := 0;

        BlockRead(InputMatrix,AHeader,SizeOf(AHeader));

        for iCount := 1 to iSites do
        begin
             iRichness := 0;
             rValue := GetNextReal; // read the site key for this row
             Key.iSiteKey := Round(rValue);
             for iIndex := 1 to iFeatures do
             begin
                  rValue := GetNextReal;
                  if (rValue > 0) then
                  begin
                       Value.iFeatKey := iIndex;
                       Value.rAmount := rValue;
                       BlockWrite(OutputMatrix,Value,SizeOf(Value));
                       Inc(iRichness);
                  end;
             end;
             Key.iRichness := iRichness;
             BlockWrite(OutputKey,Key,SizeOf(Key));
        end;

        closefile(InputMatrix);
        closefile(OutputMatrix);
        closefile(OutputKey);

        // save the file names to the ini file
        if ControlRes^.fOldIni then
           MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
        else
            MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
        MyIni.WriteString('Options','SparseMatrix',ControlRes^.sSparseMatrix);
        MyIni.WriteString('Options','SparseKey',ControlRes^.sSparseKey);
        MyIni.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception converting version 4 matrix to sparse matrix',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

{$ENDIF}

procedure TControlForm.SaveSparseMatrix;
var
   iOffSet, iIndex,
   iCount : integer;
   pSite : sitepointer;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     // create the empty tables
     try
        with AddFieldsQuery.SQL do
        begin
             Clear;
             Add('CREATE TABLE "' + ControlRes^.sDatabase + '\SparseKey.dbf"');
             Add('(');
             // sitekey range 0..9999999999
             Add('SITEKEY NUMERIC(10,0),');
             // richness range 0..9999
             Add('RICHNESS NUMERIC(4,0)');
             // offset range 0..9999999999
             //Add('OFFSET NUMERIC(10,0)');
             Add(')');
             try
                AddFieldsQuery.Prepare;
                AddFieldsQuery.ExecSQL;
             except
                   SaveToFile('c:\SparseKey.sql');
                   Screen.Cursor := crDefault;
                   MessageDlg('Exception creating table in SaveSparseMatrix',
                              mtInformation,[mbOk],0);
                   Application.Terminate;
                   Exit;
             end;
             Clear;
             Add('CREATE TABLE "' + ControlRes^.sDatabase + '\SparseAmount.dbf"');
             Add('(');
             // featkey range 0..9999
             Add('FEATKEY NUMERIC(4,0),');
             // amount range 8 digits, 2 after decimal
             Add('AMOUNT NUMERIC(8,2)');
             Add(')');
             try
                AddFieldsQuery.Prepare;
                AddFieldsQuery.ExecSQL;
             except
                   SaveToFile('c:\SparseAmount.sql');
                   Screen.Cursor := crDefault;
                   MessageDlg('Exception creating table in SaveSparseMatrix',
                              mtInformation,[mbOk],0);
                   Application.Terminate;
                   Exit;
             end;
        end;

        // now populate the tables
        SparseKeyTable.DatabaseName := ControlRes^.sDatabase;
        SparseKeyTable.TableName := 'SparseKey.dbf';
        SparseKeyTable.Open;
        SparseAmountTable.DatabaseName := ControlRes^.sDatabase;
        SparseAmountTable.TableName := 'SparseAmount.dbf';
        SparseAmountTable.Open;
        new(pSite);
        iOffSet := 1;

        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);

             // write a row to the SparseKey table
             SparseKeyTable.Append;
             SparseKeyTable.FieldByName('SITEKEY').AsInteger := pSite^.iKey;
             SparseKeyTable.FieldByName('RICHNESS').AsInteger := pSite^.richness;
             //SparseKeyTable.FieldByName('OFFSET').AsInteger := iOffSet;
             SparseKeyTable.Post;

             Inc(iOffSet,pSite^.richness);

             if (pSite^.richness > 0) then
                for iIndex := 1 to pSite^.richness do
                begin
                     // write a row to the SparseAmount table
                     SparseAmountTable.Append;
                     {$IFDEF SPARSE_MATRIX}
                     FeatureAmount.rtnValue(pSite^.iOffset + iIndex,@Value);
                     SparseAmountTable.FieldByName('FEATKEY').AsInteger := Value.iFeatKey;
                     SparseAmountTable.FieldByName('AMOUNT').AsFloat := Value.rAmount;
                     {$ELSE}
                     SparseAmountTable.FieldByName('FEATKEY').AsInteger := pSite^.feature[iIndex];
                     SparseAmountTable.FieldByName('AMOUNT').AsFloat := pSite^.featurearea[iIndex];
                     {$ENDIF}
                     SparseAmountTable.Post;
                end;
        end;
        SparseKeyTable.Close;
        SparseAmountTable.Close;
        dispose(pSite);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception saving sparse matrix',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

{$IFDEF SPARSE_MATRIX}
{$ELSE}
procedure TControlForm.SaveSparseBinMatrix;
var
   iOffSet, iIndex,
   iCount : integer;
   pSite : sitepointer;
   KeyFile, ValueFile : file;
   Key : KeyFile_T;
   Value : ValueFile_T;
begin
     // create the empty tables
     try
        AssignFile(KeyFile,ControlRes^.sDatabase + '\SparseKey.mtx');
        rewrite(KeyFile,1);
        AssignFile(ValueFile,ControlRes^.sDatabase + '\SparseAmount.mtx');
        rewrite(ValueFile,1);

        // now populate the tables
        new(pSite);
        iOffSet := 1;

        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);

             // write a row to the SparseKey table
             Key.iSiteKey := pSite^.iKey;
             Key.iRichness := pSite^.richness;
             Blockwrite(KeyFile,Key,SizeOf(Key));

             Inc(iOffSet,pSite^.richness);

             if (pSite^.richness > 0) then
                for iIndex := 1 to pSite^.richness do
                begin
                     // write a row to the SparseAmount table
                     Value.iFeatKey := pSite^.feature[iIndex];
                     Value.rAmount := pSite^.featurearea[iIndex];
                     Blockwrite(ValueFile,Value,SizeOf(Value));
                end;
        end;
        CloseFile(KeyFile);
        CloseFile(ValueFile);
        dispose(pSite);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception saving sparse matrix',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;
{$ENDIF}

function FieldPositionInTable(ATable : TTable;
                              const sName : string) : integer;
var
   iCount : integer;
begin   //    OutTable.FieldDefs.Items[0..n-1].Name
     Result := -1;
     if (ATable.FieldDefs.Count > 0) then
        for iCount := 0 to (ATable.FieldDefs.Count - 1) do
            if (sName = ATable.FieldDefs.Items[iCount].Name) then
               Result := iCount;
end;

procedure TControlForm.CleanDatabase;
var
   sValue : string;
   ListOfFields : Array_t;
   iListOfFieldsCount, iCount : integer;
   sCurrentField : string[30];

   function TryAField(const sFieldName : string) : boolean;
   begin
        try
           if (FieldPositionInTable(OutTable,sFieldName) <> -1) then
           begin
                //sValue := OutTable.FieldByName(sFieldName).AsString;
                Result := True;
                // add this field name to the list of fields to remove
                Inc(iListOfFieldsCount);
                if (iListOfFieldsCount > ListOfFields.lMaxSize) then
                   ListOfFields.resize(ListOfFields.lMaxSize + 50);
                sCurrentField := sFieldName;
                ListOfFields.setValue(iListOfFieldsCount,@sCurrentField);
           end
           else
                Result := False;
        except
              Result := False;
        end;
   end;

begin
     try
        // build a list of fields to remove from the database file
        {
         variables to test for are:
         SPAT1..10
         IRR1..10
         SUM1..10
         WAV1..5
         SUM_...1..10 (sumirr subset weightings)

         W_CR
         W_PT
         W_CRIT
         W_CRVU
         W_CRITVU
         W_SA
         W_SAPA
         (extra sumirr weightings)
        }
        try
        ListOfFields := Array_t.Create;
        ListOfFields.init(SizeOf(sCurrentField),50);
        iListOfFieldsCount := 0;
        OutTable.Open;
        for iCount := 1 to 10 do
        begin
             TryAField('SPAT' + IntToStr(iCount));
             TryAField('IRR' + IntToStr(iCount));
             TryAField('SUM' + IntToStr(iCount));
             TryAField('PC' + IntToStr(iCount));
             TryAField('WAV' + IntToStr(iCount));
             TryAField('SUM_A' + IntToStr(iCount));
             TryAField('SUM_T' + IntToStr(iCount));
             TryAField('SUM_V' + IntToStr(iCount));
             TryAField('SUM_AT' + IntToStr(iCount));
             TryAField('SUM_AV' + IntToStr(iCount));
             TryAField('SUM_TV' + IntToStr(iCount));
             TryAField('SUM_ATV' + IntToStr(iCount));
        end;

        TryAField('W_CR');
        TryAField('W_PT');
        TryAField('W_CRIT');
        TryAField('W_CRVU');
        TryAField('W_CRITVU');
        TryAField('W_SA');
        TryAField('W_SAPA');

        if ControlRes^.fMarxanDatabaseExists then
        begin
             TryAField('MBEST');
             TryAField('MSUMMED');
             if ControlRes^.fRetrieveMarxanDetailToSiteTable then
                for iCount := 1 to iMarxanScenarios do
                    TryAField('MSOLN' + IntToStr(iCount+ControlRes^.iRetrieveMarxanDetailStart-1));
        end;

        OutTable.Close;

        except
              MessageDlg('Exception in CleanDatabase position A',mtError,[mbOk],0);
        end;

        // if there is 1 or more items in the list we have just built,
        // drop the list of fields from the table using an SQL query
        if (iListOfFieldsCount > 0) then
           with AddFieldsQuery.SQL do
           begin
                Clear;
                Add('ALTER TABLE "' + OutTable.DatabaseName + '\' + OutTable.TableName + '"');
                for iCount := 1 to iListOfFieldsCount do
                begin
                     ListOfFields.rtnValue(iCount,@sCurrentField);
                     if (iCount = iListOfFieldsCount) then
                        Add('DROP ' + sCurrentField)
                     else
                         Add('DROP ' + sCurrentField + ',');
                end;
                try
                   AddFieldsQuery.Prepare;
                   AddFieldsQuery.ExecSQL;
                except
                      SaveToFile('c:\drop_sst.sql');
                      Screen.Cursor := crDefault;
                      MessageDlg('Exception executing drop query in TControlForm.CleanDatabase',mtInformation,[mbOk],0);
                      Application.Terminate;
                      Exit;
                end;
           end;

        try
        ListOfFields.Destroy;
        except
              MessageDlg('Exception in CleanDatabase position B',mtError,[mbOk],0);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TControlForm.CleanDatabase' + Chr(10) + Chr(13) +
                      'Please install the Borland Database Engine before running C-Plan.',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TControlForm.CleanDatabaseMarxanRuns;
var
   sValue : string;
   ListOfFields : Array_t;
   iListOfFieldsCount, iCount : integer;
   sCurrentField : string[30];

   function TryAField(const sFieldName : string) : boolean;
   begin
        try
           if (FieldPositionInTable(OutTable,sFieldName) <> -1) then
           begin
                //sValue := OutTable.FieldByName(sFieldName).AsString;
                Result := True;
                // add this field name to the list of fields to remove
                Inc(iListOfFieldsCount);
                if (iListOfFieldsCount > ListOfFields.lMaxSize) then
                   ListOfFields.resize(ListOfFields.lMaxSize + 50);
                sCurrentField := sFieldName;
                ListOfFields.setValue(iListOfFieldsCount,@sCurrentField);
           end
           else
                Result := False;
        except
              Result := False;
        end;
   end;

begin
     try
        // build a list of fields to remove from the database file
        try
        ListOfFields := Array_t.Create;
        ListOfFields.init(SizeOf(sCurrentField),50);
        iListOfFieldsCount := 0;
        OutTable.Open;

        if ControlRes^.fMarxanDatabaseExists then
        begin
             TryAField('MBEST');
             TryAField('MSUMMED');
             if ControlRes^.fRetrieveMarxanDetailToSiteTable then
                for iCount := 1 to iMarxanScenarios do
                    TryAField('MSOLN' + IntToStr(iCount+ControlRes^.iRetrieveMarxanDetailStart-1));
        end;

        OutTable.Close;

        except
              MessageDlg('Exception in CleanDatabaseMarxanRuns position A',mtError,[mbOk],0);
        end;

        // if there is 1 or more items in the list we have just built,
        // drop the list of fields from the table using an SQL query
        if (iListOfFieldsCount > 0) then
           with AddFieldsQuery.SQL do
           begin
                Clear;
                Add('ALTER TABLE "' + OutTable.DatabaseName + '\' + OutTable.TableName + '"');
                for iCount := 1 to iListOfFieldsCount do
                begin
                     ListOfFields.rtnValue(iCount,@sCurrentField);
                     if (iCount = iListOfFieldsCount) then
                        Add('DROP ' + sCurrentField)
                     else
                         Add('DROP ' + sCurrentField + ',');
                end;
                try
                   AddFieldsQuery.Prepare;
                   AddFieldsQuery.ExecSQL;
                except
                      SaveToFile('c:\drop_sst.sql');
                      Screen.Cursor := crDefault;
                      MessageDlg('Exception executing drop query in TControlForm.CleanDatabase',mtInformation,[mbOk],0);
                      Application.Terminate;
                      Exit;
                end;
           end;

        try
        ListOfFields.Destroy;
        except
              MessageDlg('Exception in CleanDatabaseMarxanRuns position B',mtError,[mbOk],0);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TControlForm.CleanDatabaseMarxanRuns' + Chr(10) + Chr(13) +
                      'Please install the Borland Database Engine before running C-Plan.',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TControlForm.LoadCustomizedReports(AIniFile : TIniFile);
var
   iReports, iCount : integer;

   procedure LabelFeatureMenuItem;
   begin
        case iReports of
             1 : begin
                      FeatureRptBlank1.Visible := True;
                      FeatureRptBlank1.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             2 : begin
                      FeatureRptBlank2.Visible := True;
                      FeatureRptBlank2.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             3 : begin
                      FeatureRptBlank3.Visible := True;
                      FeatureRptBlank3.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             4 : begin
                      FeatureRptBlank4.Visible := True;
                      FeatureRptBlank4.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             5 : begin
                      FeatureRptBlank5.Visible := True;
                      FeatureRptBlank5.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             6 : begin
                      FeatureRptBlank6.Visible := True;
                      FeatureRptBlank6.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             7 : begin
                      FeatureRptBlank7.Visible := True;
                      FeatureRptBlank7.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             8 : begin
                      FeatureRptBlank8.Visible := True;
                      FeatureRptBlank8.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             9 : begin
                      FeatureRptBlank9.Visible := True;
                      FeatureRptBlank9.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             10 : begin
                       FeatureRptBlank10.Visible := True;
                       FeatureRptBlank10.Caption := IniSectionBox.Items.Strings[iCount];
                  end;
        end;
   end;

   procedure LabelSiteMenuItem;
   begin
        case iReports of
             1 : begin
                      SiteRptBlank1.Visible := True;
                      SiteRptBlank1.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             2 : begin
                      SiteRptBlank2.Visible := True;
                      SiteRptBlank2.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             3 : begin
                      SiteRptBlank3.Visible := True;
                      SiteRptBlank3.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             4 : begin
                      SiteRptBlank4.Visible := True;
                      SiteRptBlank4.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             5 : begin
                      SiteRptBlank5.Visible := True;
                      SiteRptBlank5.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             6 : begin
                      SiteRptBlank6.Visible := True;
                      SiteRptBlank6.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             7 : begin
                      SiteRptBlank7.Visible := True;
                      SiteRptBlank7.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             8 : begin
                      SiteRptBlank8.Visible := True;
                      SiteRptBlank8.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             9 : begin
                      SiteRptBlank9.Visible := True;
                      SiteRptBlank9.Caption := IniSectionBox.Items.Strings[iCount];
                 end;
             10 : begin
                       SiteRptBlank10.Visible := True;
                       SiteRptBlank10.Caption := IniSectionBox.Items.Strings[iCount];
                  end;
        end;
   end;

begin
     // load user settings about customized site and/or feature reports from the INI file
     try
        // get Feature Reports info
        AIniFile.ReadSection('Feature Reports',IniSectionBox.Items);
        iReports := 0;
        if (IniSectionBox.Items.Count > 0) then
           for iCount := 0 to (IniSectionBox.Items.Count-1) do
           if (AIniFile.ReadString('Feature Report ' + IniSectionBox.Items.Strings[iCount],
                                   'NAME',
                                   'noname') <> 'noname') then
           begin
                // activate this feature report
                Inc(iReports);
                if (iReports <= 10) then
                   LabelFeatureMenuItem;
           end;
        if (iReports > 0) then
        begin
             // there are 1 or more custom feature reports
             features1.visible := False;
             targets1.visible := True;
        end
        else
        begin
             // there are no custom feature reports
             features1.visible := True;
             targets1.visible := False;
        end;

        // get Site Reports info
        AIniFile.ReadSection('Site Reports',IniSectionBox.Items);
        iReports := 0;
        if (IniSectionBox.Items.Count > 0) then
           for iCount := 0 to (IniSectionBox.Items.Count-1) do
           if (AIniFile.ReadString('Site Report ' + IniSectionBox.Items.Strings[iCount],
                                   'NAME',
                                   'noname') <> 'noname') then
           begin
                // activate this feature report
                Inc(iReports);
                if (iReports <= 10) then
                   LabelSiteMenuItem;
           end;
        if (iReports > 0) then
        begin
             // there are 1 or more custom site reports
             sites1.visible := False;
             report1.visible := True;
        end
        else
        begin
             // there are no custom site reports
             sites1.visible := True;
             report1.visible := False;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TControlForm.LoadCustomizedReports',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function TrimAmpersand(const sName : string) : string;
var
   iPos : integer;
begin
     iPos := Pos('&',sName);
     if (iPos > 0) then
     begin
          if (iPos = 1) then
          begin
               // ampersand at start of string
               Result := Copy(sName,2,Length(sName)-1);
          end
          else
          if (iPos = Length(sName)) then
          begin
               // ampersand at end of string
               Result := Copy(sName,1,Length(sName)-1);
          end
          else
          begin
               // ampersand in middle of at end of string
               Result := Copy(sName,1,iPos-1) +
                         Copy(sName,iPos+1,Length(sName)-iPos);
          end;
     end
     else
         Result := sName;
end;

procedure TControlForm.ProcessFeatureRptClick(const sReportClicked : string);
var
   sDescription, sReportTrim : string;
   iCount : integer;
begin
     // user wants to generate sReportClicked feature report
     try
        sReportTrim := TrimAmpersand(sReportClicked);

        // get user to select an output filename for the report
        SaveRptForm := TSaveRptForm.Create(Application);
        SaveRptForm.PrepFeatures(sReportTrim);
        if (SaveRptForm.ShowModal = mrOk) then
        begin
             sDescription := '';
             if (SaveRptForm.Metadata.Lines.Count > 0) then
                for iCount := 0 to (SaveRptForm.Metadata.Lines.Count-1) do
                begin
                     sDescription := sDescription + SaveRptForm.Metadata.Lines.Strings[iCount];
                     if (iCount <> (SaveRptForm.Metadata.Lines.Count-1)) then
                        sDescription := sDescription + ' ';
                end;

             RecurseRemoveCommas(sDescription);

             if (sDescription = '') then
                sDescription := 'no metadata specified';
             ReportFeatures(SaveRptForm.OutputFile.Text,
                            sDescription,
                            TRUE,
                            ControlForm.UseFeatCutOffs.Checked,
                            FeatArr,
                            iFeatureCount,
                            rPercentage,
                            sReportTrim
                            );
        end;

        SaveRptForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TControlForm.ProcessFeatureRptClick',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TControlForm.ProcessSiteRptClick(const sReportClicked : string);
var
   sDescription, sReportTrim : string;
   iCount : integer;
begin
     // user wants to generate sReportClicked site report
     try
        sReportTrim := TrimAmpersand(sReportClicked);

        // get user to select an output filename for the report
        SaveRptForm := TSaveRptForm.Create(Application);
        SaveRptForm.PrepSites(sReportTrim);
        if (SaveRptForm.ShowModal = mrOk) then
        begin
             sDescription := '';
             if (SaveRptForm.Metadata.Lines.Count > 0) then
                for iCount := 0 to (SaveRptForm.Metadata.Lines.Count-1) do
                begin
                     sDescription := sDescription + SaveRptForm.Metadata.Lines.Strings[iCount];
                     if (iCount <> (SaveRptForm.Metadata.Lines.Count-1)) then
                        sDescription := sDescription + ' ';
                end;

             RecurseRemoveCommas(sDescription);

             if (sDescription = '') then
                sDescription := 'no metadata specified';

             if not fContrDataDone then
                ExecuteIrreplaceability(-1,False,False,True,True,'');

             ReportSites(SaveRptForm.OutputFile.Text,
                         sDescription,
                         TRUE,
                         ControlForm.OutTable,
                         iSiteCount,
                         SiteArr,
                         ControlRes,
                         sReportTrim
                         );
        end;

        SaveRptForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TControlForm.ProcessSiteRptClick',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TControlForm.ImportIStatusToShp;
var
   iCount : integer;
   fImport, fLink : boolean;
begin
     {test if the I_STATUS field occurs in the shape table,
      if it doesn't, import it from the site summary table}
     try
        fImport := True;

        ShapeTable.DatabaseName := OutTable.DatabaseName;
        ShapeTable.TableName := ExtractFileName(ControlRes^.sShpTable);

        ShapeTable.Open;

        for iCount := 0 to (ShapeTable.FieldCount-1) do
            if (UpperCase(ShapeTable.Fields[iCount].Name) = 'I_STATUS') then
               fImport := False;

        ShapeTable.Close;

        if fImport then
        begin
             fLink := False;
             {attempt to open dde conv with arcview}
             if TblEdClientConv.SetLink('table_ed','cmdconv') then
                fLink := True
             else
                 {exec table ed}
                 RunCPlanApp('table_ed','');

             if not fLink then
                fLink := TblEdClientConv.SetLink('table_ed','cmdconv');

             if fLink then
             begin
                  {send DDE commands to import I_STATUS}
                  DDESendCmd(TblEdClientConv,'link ' +
                                             OutTable.Databasename + '\' + OutTable.TableName);
                  DDESendCmd(TblEdClientConv,'link ' +
                                             ControlRes^.sShpTable);
                  DDESendCmd(TblEdClientConv,'set ' +
                                             ControlRes^.sShpKeyField + ' ' +
                                             ControlRes^.sShpTable);
                  DDESendCmd(TblEdClientConv,'set ' +
                                             ControlRes^.sKeyField +
                                             OutTable.Databasename + '\' + OutTable.TableName);
                  DDESendCmd(TblEdClientConv,'import I_STATUS ' +
                                             OutTable.Databasename + '\' + OutTable.TableName + ' ' +
                                             ControlRes^.sShpTable);
                  DDESendCmd(TblEdClientConv,'exit');
             end;
        end;

     except

     end;
end;

procedure TControlForm.TryShowExtraTools;
begin
     if ControlRes^.fShowExtraTools then
     begin
          ExtraTools1.Visible := True;
          N20.Visible := True;
          Validate1.Visible := True;
     end
     else
     begin
          ExtraTools1.Visible := False;
          N20.Visible := False;
          Validate1.Visible := False;
     end;
end;

function TControlForm.CanAccept : boolean;
begin
     Result := False;

     if (Available.SelCount > 0)
     or (R1.SelCount > 0)
     or (R2.SelCount > 0)
     or (R3.SelCount > 0)
     or (R4.SelCount > 0)
     or (R5.SelCount > 0)
     or (Flagged.SelCount > 0)
     or (Partial.SelCount > 0)
     or (Excluded.SelCount > 0)
     or (Reserved.SelCount > 0)
     or (Ignored.SelCount > 0) then
        Result := True;
end;

procedure ReInitMem(const fFreeControl : boolean);
begin
     try
        {free any memory objects}
        DDECloseLinks; {close DDE connection}
        EndChoices; {free the choice object in unit Chc_data}

        SiteArr.Destroy;
        SiteCodes.Destroy;
        OrdSiteArr.Destroy;
        FeatArr.Destroy;
        FeatCodes.Destroy;
        OrdFeatArr.Destroy;
        AverageSite.Destroy;
        AverageInitialSite.Destroy;

        ValidateSite.Destroy;
        ValidateFeature.Destroy;

        SiteRichness.Destroy;
        VegArea.Destroy;

        if fRichnessArrBuilt then
           RichnessArr.Destroy;

        LookupOff;  {free the lookup form}

        if fFreeControl then
           ControlForm.Free;  {free control form}

        dispose(ControlRes);
        {dispose of Weighted Sumirr variables if in use}
        if ControlRes^.fCalculateAllVariations then
           WeightedSumirr.Destroy;

        {dispose of SpatIOModule if we are connected to SPATTOOL}
        if ControlRes^.fConnectedToSPATTOOL then
        begin
             DDESendCmd(SpatIOModule.CPlanClient,'x');;
             SpatIOModule.Free;
             //ReceiveDataExtended.Destroy;
        end;
        if (ControlRes^.sSpatialDistanceFile <> '') then
           DisposeOldTempFiles(ControlRes^.sSpatialDistanceFile);

        if ControlRes^.fSpatResultCreated then
           SpatResult.Destroy;

        //if ControlRes^.fDestructObjectsCreated then
        //   FreeDestroy(FALSE);

        //InitialValues.Destroy;

        FreeSparsePartialStructure;

        if ControlRes^.fRedCheckExcludeSitesCreated then
           RedCheckExcludeSites.Destroy;

        GISSiteValues.Destroy;

        FeatureAmount.Destroy;

        if ControlRes^.fPointFeaturesSpecified then
           PointFeatures.Destroy;

        if fMarxanResultCreated then
           DisposeMarxanResult;

        if ControlRes^.fLoadSiteVuln then
           SiteVuln.Destroy;

        if ControlRes^.fLoadSiteCost then
           SiteCost.Destroy;

     except
           {no need to say any error message here as we are exiting anyway}
     end;
end;

procedure DumpReportTarget;
var
   OutFile : TextFile;
   rTarget : extended;
   iCount : integer;
begin
     assignfile(OutFile,'c:\reporttarget.csv');
     rewrite(OutFile);
     writeln(OutFile,'feature index,' + ControlRes^.sReportTargetField);
     for iCount := 1 to iFeatureCount do
     begin
          ReportTarget.rtnValue(iCount,@rTarget);
          writeln(OutFile,IntToStr(iCount) + ',' + FloatToStr(rTarget));
     end;
     closefile(OutFile);
end;

procedure DestroyControlForm(const fFreeControl : boolean);
{this method is the destructor for the Conservation Tool,
 written to be called after files have been saved}
begin
     try
        if ControlRes^.fConnectedToSpattool then
           SpatIOModule.SendTerminateRequest;
        ReportTarget.Destroy;

        if fileexists(ControlRes^.sDatabase + '\empty.log') then
           deletefile(pchar(ControlRes^.sDatabase + '\empty.log'));

        ReInitMem(fFreeControl);

        ControlForm.CleanDatabase;

        try
           StartForm.Free;

        except
              Screen.Cursor := crDefault;
              MessageDlg('exception in StartForm.Free',mtError,[mbOk],0);
        end;

        try
           //ExcludedSiteArea.done;

        except
              Screen.Cursor := crDefault;
              MessageDlg('exception in ExcludedSiteArea.done',mtError,[mbOk],0);
        end;

        if fStageListCreated then
        try
           StageList.Destroy;
        except
              Screen.Cursor := crDefault;
              MessageDlg('exception in StageList.Destory',mtError,[mbOk],0);
        end;

        MappedSites.Destroy;
        if ControlRes^.fCalculateBobsExtraVariations then
           FreeMinsetSumirrWeightings;

        try
           if fCrownLandSitesCreated then
              CrownLandSites.Destroy;
        except
        end;

     finally
            Application.Terminate;
     end;
end;

procedure Autosave;
begin
     SaveSelections(ControlRes^.sWorkingDirectory + '\' + AUTOSAVE_FILE,False);
end;

procedure AddEMSDate;
var
   sDate : string;
begin
     if (ControlForm.EMSReason.Items.Count = 0) then
     begin
          sDate := CustDateStr; {FormatDateTime('"Date is "dddd," "mmmm d, yyyy ' +
                                  '"at" hh:mm AM/PM', Now);}

          ControlForm.EMSReason.Items.Add(sDate);
     end
     else
         if (ControlForm.EMSReason.Items.Count >= 1) then
         begin
              ControlForm.EMSReason.Items.Delete(0);
              sDate := CustDateStr;
              ControlForm.EMSReason.Items.Insert(0,sDate);
         end;
end;


procedure HighlightMemo(var ThisMemo : TMemo);
begin
     ThisMemo.SelectAll;
     ThisMemo.Refresh;
end;

procedure UnHighlightMemo(var ThisMemo : TMemo);
begin
     ThisMemo.SelLength := 0;
end;


procedure CreateControlForm;
begin
     ControlForm := TControlForm.Create(Application);
end;

procedure FreeControlForm;
begin
     ControlForm.Free;
end;

procedure HintsOn;
begin
     with ControlForm do
     begin
          Available.ShowHint := True;
          R1.ShowHint := True;
          R2.ShowHint := True;
          Excluded.ShowHint := True;
          Partial.ShowHint := True;
          Flagged.ShowHint := True;
          btnIrrep.ShowHint := True;
          ParGroup.ShowHint := True;
          UnParGroup.ShowHint := True;
          UnParAll.ShowHint := True;
          FlgGroup.ShowHint := True;
          UnFlgGroup.ShowHint := True;
          UnFlgAll.ShowHint := True;
          TargetPercent.ShowHint := True;
          SelectGroup.ShowHint := True;
          UnSelectGroup.ShowHint := True;
          UnSelectAll.ShowHint := True;
          ManGroup.ShowHint := True;
          UnManGroup.ShowHint := True;
          UnManAll.ShowHint := True;
          ExcGroup.ShowHint := True;
          UnExcGroup.ShowHint := True;
          UnExcAll.ShowHint := True;
          StatusPanel.ShowHint := True;
          ClickGroup.ShowHint := True;
          UseFeatCutOffs.ShowHint := True;
     end;
end;

procedure HintsOff;
begin
     with ControlForm do
     begin
          Available.ShowHint := False;
          R1.ShowHint := False;
          R2.ShowHint := False;
          Excluded.ShowHint := False;
          Partial.ShowHint := False;
          Flagged.ShowHint := False;
          btnIrrep.ShowHint := False;
          ParGroup.ShowHint := False;
          UnParGroup.ShowHint := False;
          UnParAll.ShowHint := False;
          FlgGroup.ShowHint := False;
          UnFlgGroup.ShowHint := False;
          UnFlgAll.ShowHint := False;
          TargetPercent.ShowHint := False;
          SelectGroup.ShowHint := False;
          UnSelectGroup.ShowHint := False;
          UnSelectAll.ShowHint := False;
          ManGroup.ShowHint := False;
          UnManGroup.ShowHint := False;
          UnManAll.ShowHint := False;
          ExcGroup.ShowHint := False;
          UnExcGroup.ShowHint := False;
          UnExcAll.ShowHint := False;
          StatusPanel.ShowHint := False;
          ClickGroup.ShowHint := False;
          UseFeatCutOffs.ShowHint := False;
     end;
end;

procedure TControlForm.CloseTool;
begin
     fReallyExit := True;
     Exit1Click(self);
end;

function TControlForm.rtnExeInstallPath : string;
var
   GlobalIni : TIniFile;
begin
     {}
     try
        GlobalIni := TIniFile.Create(DB_INI_FILENAME);

        Result := GlobalIni.ReadString('Paths','32bit','');

        GlobalIni.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TControlForm.rtnExeInstallPath',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function CountReserveClasses : integer;
begin
     Result := 1;
     if (ControlRes^.sR2Label <> '') then
        Inc(Result);
     if (ControlRes^.sR3Label <> '') then
        Inc(Result);
     if (ControlRes^.sR4Label <> '') then
        Inc(Result);
     if (ControlRes^.sR5Label <> '') then
        Inc(Result);
end;

procedure TControlForm.InformGIS;
var
   sCmd, sAVL_File : string;
   fExtraParameter, fDef, fAbs : boolean;
   rMaximumValue : extended;
begin
     if (ControlRes^.GISLink = ArcView) then
     begin
          fExtraParameter := False;

          {attempt to reload ControlRes^.sAVView, sAVTheme from INI file in case
           ArcView has updated these settings for us}
          LoadAVIni;
          fAbs := False;
          fDef := (ControlRes^.iDisplayValuesFor <> 0);

          case ControlRes^.iGISPlotField of
               0 : if (ControlRes^.iDisplayValuesFor = 0) then
                      sAVL_File := 'Irr_Site.avl'
                   else
                       sAVL_File := 'Irr_Site_def.avl';
               1 : if ControlRes^.fDisplayAbsSumirr then
                   begin
                        if (ControlRes^.iDisplayValuesFor = 0) then
                           sAVL_File := 'irr_sum_abs.avl'
                        else
                            sAVL_File := 'irr_sum_abs_def.avl';

                        // we need to pass an extra parameter
                        fExtraParameter := True;

                        fAbs := True;
                   end
                   else
                   begin
                        if (ControlRes^.iDisplayValuesFor = 0) then
                           sAVL_File := 'Irr_Sum.avl'
                        else
                            sAVL_File := 'Irr_Sum_def.avl';
                   end;
               2 : if (ControlRes^.iDisplayValuesFor = 0) then
                      sAVL_File := 'Irr_Wav.avl'
                   else
                       sAVL_File := 'Irr_Wav_def.avl';
               3 : if (ControlRes^.iDisplayValuesFor = 0) then
                      sAVL_File := 'PCUsed.avl'
                   else
                       sAVL_File := 'PCUsed_def.avl';
               10 : if (ControlRes^.iDisplayValuesFor = 0) then
                       sAVL_File := 'marxan.avl'
                    else
                        sAVL_File := 'marxan_def.avl';
          else
              if (ControlRes^.iDisplayValuesFor = 0) then
                 sAVL_File := 'Irr_Spat.avl'
              else
                  sAVL_File := 'Irr_Spat_def.avl';;
          end;

          if fExtraParameter then
          begin
               // fAbs fDef

               if fDef then
                  sCmd := 'av.run("CPlan.ThemeRedrawDefAbs",{"' + ControlRes^.sAVView +
                          '","' + ControlRes^.sAVTheme +
                          '","'
               else
               begin
                    // add 5 extra parameters
                    sCmd := 'av.run("CPlan.ThemeRedrawAbs",{"' + ControlRes^.sAVView +
                            '","' + ControlRes^.sAVTheme +
                            '","' + IntToStr(CountReserveClasses) +
                            '","' + ControlRes^.sR1Label +
                            '","' + ControlRes^.sR2Label +
                            '","' + ControlRes^.sR3Label +
                            '","' + ControlRes^.sR4Label +
                            '","' + ControlRes^.sR5Label +
                            '","';
               end;

               case ControlRes^.iDisplayScheme of
                    0 : sCmd := sCmd + rtnExeInstallPath + '\arcview\Scheme 1 (red-green)\' + sAVL_File + '"';
                    1 : sCmd := sCmd + rtnExeInstallPath + '\arcview\Scheme 2 (red-blue)\' + sAVL_File + '"';
                    2 : sCmd := sCmd + rtnExeInstallPath + '\arcview\Scheme 3 (user defined)\' + sAVL_File + '"';
               end;

               // note rMaximumValue is maximum value for the variable in the display
               rMaximumValue := ControlRes^.rDisplayMaximumValue;
               if not ControlRes^.fGISRegionalSettingIsEnglish then
                  sCmd := sCmd + ',"' + FloatToStr(rMaximumValue) + '","' + IntToStr(ControlRes^.iDisplayValuesFor) + '"})'
               else
                   sCmd := sCmd + ',"' + RegionSafeFloatToStr(rMaximumValue) + '","' + IntToStr(ControlRes^.iDisplayValuesFor) + '"})';
          end
          else
          begin
               // fAbs fDef

               if fDef then
                  sCmd := 'av.run("CPlan.ThemeRedrawDef",{"' + ControlRes^.sAVView +
                          '","' + ControlRes^.sAVTheme +
                          '","'
               else
               begin
                    // add 5 extra parameters
                    sCmd := 'av.run("CPlan.ThemeRedraw",{"' + ControlRes^.sAVView +
                            '","' + ControlRes^.sAVTheme +
                            '","' + IntToStr(CountReserveClasses) +
                            '","' + ControlRes^.sR1Label +
                            '","' + ControlRes^.sR2Label +
                            '","' + ControlRes^.sR3Label +
                            '","' + ControlRes^.sR4Label +
                            '","' + ControlRes^.sR5Label +
                            '","';
               end;

               case ControlRes^.iDisplayScheme of
                    0 : sCmd := sCmd + rtnExeInstallPath + '\arcview\Scheme 1 (red-green)\' + sAVL_File + '"})';
                    1 : sCmd := sCmd + rtnExeInstallPath + '\arcview\Scheme 2 (red-blue)\' + sAVL_File + '"})';
                    2 : sCmd := sCmd + rtnExeInstallPath + '\arcview\Scheme 3 (user defined)\' + sAVL_File + '"})';
               end;
          end;

          ArcViewExecCmd(sCmd);

          if fMinimiseOnDone
          and (not ControlRes^.fToolView) then
              WindowState := wsMinimized;
     end;

     if (ControlRes^.GISLink = ZonaeCogito) then
     begin
          //LoadZCIni;
          fExtraParameter := False;
          fAbs := False;
          fDef := (ControlRes^.iDisplayValuesFor <> 0);

          case ControlRes^.iGISPlotField of
               0 : if (ControlRes^.iDisplayValuesFor = 0) then
                      sCmd := 'Irr_Site'
                   else
                       sCmd := 'Irr_Site_def';
               1 : if ControlRes^.fDisplayAbsSumirr then
                   begin
                        if (ControlRes^.iDisplayValuesFor = 0) then
                           sCmd := 'irr_sum_abs'
                        else
                            sCmd := 'irr_sum_abs_def';
                        fExtraParameter := True;
                        fAbs := True;
                   end
                   else
                   begin
                        if (ControlRes^.iDisplayValuesFor = 0) then
                           sCmd := 'Irr_Sum'
                        else
                            sCmd := 'Irr_Sum_def';
                   end;
               2 : if (ControlRes^.iDisplayValuesFor = 0) then
                      sCmd := 'Irr_Wav'
                   else
                       sCmd := 'Irr_Wav_def';
               3 : if (ControlRes^.iDisplayValuesFor = 0) then
                      sCmd := 'PCUsed.avl'
                   else
                       sCmd := 'PCUsed_def';
               10 : if (ControlRes^.iDisplayValuesFor = 0) then
                       sCmd := 'marxan.avl'
                    else
                        sCmd := 'marxan_def';
          else
              if (ControlRes^.iDisplayValuesFor = 0) then
                 sCmd := 'Irr_Spat'
              else
                  sCmd := 'Irr_Spat_def';
          end;

          if fExtraParameter then
             sCmd := sCmd + ' ' + RegionSafeFloatToStr(ControlRes^.rDisplayMaximumValue);

          case ControlRes^.iDisplayScheme of
               0 : sCmd := sCmd + ' red-green';
               1 : sCmd := sCmd + ' red-blue';
               2 : sCmd := sCmd + ' user-defined';
          end;

          sCmd := 'InformGIS ' + sCmd;

          ZonaeCogitoExecCmd(sCmd);

          if fMinimiseOnDone
          and (not ControlRes^.fToolView) then
              WindowState := wsMinimized;
     end;
end;

procedure TControlForm.CreateGIS;
var
   sCmd : string;
begin
     if (ControlRes^.GISLink = ArcView) then
     begin
          {if I_STATUS field does not exist in the shape table dbf file, import it from the site summary table
           by sending DDE commands to ArcView}
          {CPlan.ThemeRedraw parameters are :
                              view
                              theme
                              avl path and file name}

          LoadAVIni;
          sCmd := 'av.run("CPlan.ThemeRedrawDef",{"' + ControlRes^.sAVView + '","' +
                                                  ControlRes^.sAVTheme + '","' +
                                                  rtnExeInstallPath + '\arcview\initial.avl"})';
          ArcViewExecCmd(sCmd);
     end;
end;

procedure TControlForm.ProcLabelOn(const sLabel : string);
begin
     ProcLabel.Visible := True;
     ProcLabelUpdate(sLabel);
end;

procedure TControlForm.ProcLabelUpdate(const sLabel : string);
begin
     ProcLabel.Alignment := taCenter;
     ProcLabel.Caption := sLabel;
     ProcLabel.Width := Trunc((StatusPanel.Width div 2) - (TOOL_DIVIDE_SPACE * 2));
     ProcLabel.Left := TOOL_DIVIDE_SPACE div 2;
     ProcLabel.Refresh;
end;

procedure TControlForm.ProcLabelOff;
begin
     ProcLabel.Caption := '';
     ProcLabel.Visible := False;

     ProcLabel.Refresh;
end;

{------ start DBMS Stuff ------------------------------------------}

procedure CutPathFile(const sLine : string; var sDB, sTable : string);
var
   iCount : integer;
begin
     iCount := Length(sLine);

     while (sLine[iCount] <> '\') do Dec(iCount);

     sDB := Copy (sLine,(iCount + 1),(Length(sLine) - iCount));
     sTable := Copy (sLine,1,(iCount - 1));
end;

procedure TControlForm.RefreshGIS;
var
   iShpIndex, iAttribute : integer;
   pShpSite : sitepointer;
   fStop : boolean;
begin
     fStop := False;

     if (ControlRes^.GISLink = ArcView) then
     try
        try
           {loads shape file key field from initialisation file
            so we can use it to look up key values}
           LoadAVIni;

           ShapeTable.TableName := ControlRes^.sShpTable;
           ShapeTable.DatabaseName := ControlRes^.sDatabase;
           ShapeTable.Open;
           new(pShpSite);

           {test to see if the key field setting is correct, call
            CPlan.GetUserSettings to get user to set it, and reload if it isn't}
           try
              iAttribute := ShapeTable.FieldByName(ControlRes^.sShpKeyField).AsInteger;

           except
                 ArcViewExecCmd('av.run("CPlan.GetUserSettingsAndUpdate",{' + ControlRes^.sDatabase + '}');
                 {exit UpdateDatabase method}
                 exit;

           end;

        except on exception do
               begin
                    fStop := True;
                    Screen.Cursor := crDefault;
                    MessageDlg('RefreshGIS cannot open ' + ShapeTable.DatabaseName +
                               '\' + ShapeTable.TableName,mtInformation,[mbOk],0);
               end;
        end;

        if not fStop then
        begin
             // if we are linked to ArcView and
             // not yet at the end of the ShapeTable, traverse it finish updating it
             if (ControlRes^.GISLink = ArcView) then
                while not ShapeTable.EOF do
                begin
                     ShapeTable.Edit;

                     iAttribute := ShapeTable.FieldByName(ControlRes^.sShpKeyField).AsInteger;

                     iShpIndex := findIntegerMatch(OrdSiteArr,iAttribute);
                     if (iShpIndex > 0) then
                        SiteArr.rtnValue(iShpIndex,pShpSite)
                     else
                         pShpSite^.iKey := -1;

                     if (pShpSite^.iKey <> iAttribute) then
                        ShapeTable.FieldByName('DISPLAY').AsString := '' // site does not exist in SiteArr
                     else
                         ShapeTable.FieldByName('DISPLAY').AsString := pShpSite^.sDisplay;

                     ShapeTable.Next;
                end;
        end;

        if not fStop then
        begin
             ShapeTable.Close;
             dispose(pShpSite);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Refresh GIS',
                      mtError,
                      [mbOk],
                      0);

           if not fStop then
           begin
                ShapeTable.Close;
                dispose(pShpSite);
           end;
     end; {of try..except}

end; {of procedure TControlForm.RefreshGIS}

procedure TControlForm.Create_shpfields;
var
   sFilename : string;
begin
     // use an SQL query to create shpfields.dbf which is needed by ArcView as a template
     try
        sFilename := ExtractFilePath(Application.ExeName) + 'ArcView\shpfields.dbf';
        if not fileexists(sFilename) then
           with AddFieldsQuery.SQL do
           begin
                Clear;
                Add('CREATE TABLE "' + sFilename + '"');
                Add('(');
                Add(' DISPLAY CHAR(3),');
                Add(' I_STATUS CHAR(17),');
                Add(' ' + SHAPE_VALUE_FIELD + ' NUMERIC(10,5)');
                Add(')');
                
                try
                   AddFieldsQuery.Prepare;
                   AddFieldsQuery.ExecSQL;
                except
                      SaveToFile(ControlRes^.sWorkingDirectory + '\Create_shpfields.sql');
                      Screen.Cursor := crDefault;
                      MessageDlg('Exception in Create_shpfields',mtInformation,[mbOk],0);
                      Application.Terminate;
                      Exit;
                end;
           end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Create_shpfields',mtError,[mbOk],0);
     end;
end;

function Bool2Int(const fBool : boolean) : integer;
begin
     if fBool then
        Result := 1
     else
         Result := 0;
end;

procedure TControlForm.UpdateDatabase(const fWriteDisplay : boolean);
  {Writes the results of an Irreplaceability run
   to a database file which can be read by WERMS}
var
   iSubsetVariable,
   iCount, iShpIndex, iAttribute, iWriteCount : integer;

   TmpSite : site;
   {TmpSiteCust : SiteCust_T;}
   pShpSite : sitepointer;

   fUpdInitIrrepl, fStop, fStopSkip : boolean;
   //iBreak : integer;
   //fBreak : boolean;
   rSpatialValue : single;

   function InitExtraFields : boolean;
   var
      rTest : extended;
      sTest : string;
      iSubsetCount : integer;

      procedure StartAddFields;
      begin
           AddFieldsQuery.SQL.Clear;
           AddFieldsQuery.SQL.Add('ALTER TABLE "' +
                                  OutTable.DatabaseName +
                                  '\' +
                                  OutTable.TableName +
                                  '"');
      end;

      procedure EndAddFields;
      begin
           //
           if (AddFieldsQuery.SQL.Count > 1) then
           begin
                OutTable.Close;
                try
                   AddFieldsQuery.Prepare;
                   AddFieldsQuery.ExecSQL;
                except
                      Screen.Cursor := crDefault;
                      AddFieldsQuery.SQL.SaveToFile('c:\add_fld.sql');
                      MessageDlg('Exception adding fields to the site summary table',mtInformation,[mbOk],0);
                end;
                OutTable.Open;
           end;
      end;

      procedure AddAField(sFld : string);
      begin
           try rTest := OutTable.FieldByName(sFld).AsFloat;

           except
                 if (AddFieldsQuery.SQL.Count > 1) then
                 begin
                      // add a comma before add command
                      AddFieldsQuery.SQL.Add(', ADD ' + sFld + ' NUMERIC(10,5)');
                 end
                 else
                 begin
                      // don't add a comma before add command
                      AddFieldsQuery.SQL.Add('ADD ' + sFld + ' NUMERIC(10,5)');
                 end;
           end;
      end;

      procedure AddAFieldString(sFld : string);
      begin
           try sTest := OutTable.FieldByName(sFld).AsString;

           except
                 if (AddFieldsQuery.SQL.Count > 1) then
                 begin
                      // add a comma before add command
                      AddFieldsQuery.SQL.Add(', ADD ' + sFld + ' CHAR(5)');
                 end
                 else
                 begin
                      // don't add a comma before add command
                      AddFieldsQuery.SQL.Add('ADD ' + sFld + ' CHAR(5)');
                 end;
           end;
      end;

   begin
        {Checks if necessary fields exist in the table, adding them with an
         SQL Query if necessary.
         Result is true if fields added, false if no fields added.}

        {Fields to Test:
                if .fCalculateAllVariations:
                   SUM_A, T, V, AT, AV, TV, ATV

                if .fFeatureClassesApplied:
                   IRR, SUM, WAV extra fields for subsets in use
                   if .fCalculateAllVariations:
                      subset SUM_A, T, V, AT, AV, TV, ATV }

        StartAddFields;

        AddAFieldString('DISPLAY');
        AddAFieldString('STATUS');
        AddAField('IRREPL');
        AddAField('I_IRREPL');
        AddAField('SUMIRR');
        AddAField('I_SUMIRR');
        AddAField('WAVIRR');
        AddAField('I_WAVIRR');
        AddAField('PCCONTR');
        AddAField('I_PCCONTR');

        if ControlRes^.fCalculateAllVariations then
        begin
             AddAField('SUM_PA');
             AddAField('SUM_IT');
             AddAField('SUM_VU');
             AddAField('SUM_PAIT');
             AddAField('SUM_PAVU');
             AddAField('SUM_ITVU');
             AddAField('SUM_PAITVU');
        end;

        if ControlRes^.fCalculateBobsExtraVariations then
        begin
             AddAField('SUM_CR');
             AddAField('SUM_PT');
             AddAField('SUM_CRIT');
             AddAField('SUM_CRVU');
             AddAField('SUM_CRITVU');
             AddAField('SUM_SA');
             AddAField('SUM_SAPA');
             AddAField('SUM_SAPT');
             AddAField('SUM_PAPT');
        end;

        if ControlRes^.fFeatureClassesApplied then
        begin
             for iSubsetCount := 1 to 10 do
                 if ControlRes^.ClassDetail[iSubsetCount] then
                 begin
                      {subset iSubsetCount is in use}
                      if UserSubsetChoices._first[iSubsetCount].fIrr then
                         AddAField('IRR' + IntToStr(iSubsetCount));
                      if UserSubsetChoices._first[iSubsetCount].fSum then
                         AddAField('SUM' + IntToStr(iSubsetCount));

                      if ControlRes^.fCalculateAllVariations then
                      begin
                           if UserSubsetChoices._first[iSubsetCount].fSum_A then
                              AddAField('SUM_A' + IntToStr(iSubsetCount));
                           if UserSubsetChoices._first[iSubsetCount].fSum_T then
                              AddAField('SUM_T' + IntToStr(iSubsetCount));
                           if UserSubsetChoices._first[iSubsetCount].fSum_V then
                              AddAField('SUM_V' + IntToStr(iSubsetCount));
                           if UserSubsetChoices._first[iSubsetCount].fSum_AT then
                              AddAField('SUM_AT' + IntToStr(iSubsetCount));
                           if UserSubsetChoices._first[iSubsetCount].fSum_AV then
                              AddAField('SUM_AV' + IntToStr(iSubsetCount));
                           if UserSubsetChoices._first[iSubsetCount].fSum_TV then
                              AddAField('SUM_TV' + IntToStr(iSubsetCount));
                           if UserSubsetChoices._first[iSubsetCount].fSum_ATV then
                              AddAField('SUM_ATV' + IntToStr(iSubsetCount));
                      end;
                 end;

             for iSubsetCount := 1 to 5 do
                 if ControlRes^.ClassDetail[iSubsetCount] then
                 begin
                      if UserSubsetChoices._second[iSubsetCount].fWav then
                         AddAField('WAV' + IntToStr(iSubsetCount));
                      if UserSubsetChoices._second[iSubsetCount].fPC then
                         AddAField('PC' + IntToStr(iSubsetCount));
                 end;
        end;

        if ControlRes^.fSpatResultCreated then
        begin
             for iSubsetCount := 1 to 10 do
                 if ControlRes^.fDoConfigOnSubset[iSubsetCount] then
                    AddAField('SPAT' + IntToStr(iSubsetCount));
             AddAField('SPAT');
        end;

        if ControlRes^.fMarxanDatabaseExists then
        begin
             AddAField('MBEST');
             AddAField('MSUMMED');
             if ControlRes^.fRetrieveMarxanDetailToSiteTable then
                for iSubsetCount := 1 to iMarxanScenarios do
                    AddAField('MSOLN' + IntToStr(iSubsetCount+ControlRes^.iRetrieveMarxanDetailStart-1));
        end;

        EndAddFields;
   end;

   procedure PopulateExtraFields;
   var
      WS : WeightedSumirr_T;
      MSW : MinsetSumirrWeightings_T;
      iSubsetCount : integer;
      MarxanSiteResult : MarxanSiteResult_t;
      fInSiteResult :  boolean;
   begin
        try
        {populate:
            sumirr weightings
            subset irr,sum,wav & sumirr weightings}

        if ControlRes^.fCalculateAllVariations then
        begin
             WeightedSumirr.rtnValue(iCount,@WS);

             OutTable.FieldByName('SUM_PA').AsFloat := WS.r_a;
             OutTable.FieldByName('SUM_IT').AsFloat := WS.r_t;
             OutTable.FieldByName('SUM_VU').AsFloat := WS.r_v;
             OutTable.FieldByName('SUM_PAIT').AsFloat := WS.r_at;
             OutTable.FieldByName('SUM_PAVU').AsFloat := WS.r_av;
             OutTable.FieldByName('SUM_ITVU').AsFloat := WS.r_tv;
             OutTable.FieldByName('SUM_PAITVU').AsFloat := WS.r_atv;
        end;
        if ControlRes^.fCalculateBobsExtraVariations then
        begin
             MinsetSumirrWeightings.rtnValue(iCount,@MSW);

             OutTable.FieldByName('SUM_CR').AsFloat := MSW.rWcr;
             OutTable.FieldByName('SUM_PT').AsFloat := MSW.rWpt;
             OutTable.FieldByName('SUM_CRIT').AsFloat := MSW.rWcrWit;
             OutTable.FieldByName('SUM_CRVU').AsFloat := MSW.rWcrWvu;
             OutTable.FieldByName('SUM_CRITVU').AsFloat := MSW.rWcrWitWvu;
             OutTable.FieldByName('SUM_SA').AsFloat := MSW.rWsa;
             OutTable.FieldByName('SUM_SAPA').AsFloat := MSW.rWsaWpa;
             OutTable.FieldByName('SUM_SAPT').AsFloat := MSW.rWsaWpt;
             OutTable.FieldByName('SUM_PAPT').AsFloat := MSW.rWpaWpt;
        end;

        if ControlRes^.fFeatureClassesApplied then
        begin
             for iSubsetCount := 1 to 10 do
                 if ControlRes^.ClassDetail[iSubsetCount] then
                    begin
                         if UserSubsetChoices._first[iSubsetCount].fIrr then
                            OutTable.FieldByName('IRR' + IntToStr(iSubsetCount)).AsFloat := TmpSite.rSubsetIrr[iSubsetCount];
                         if UserSubsetChoices._first[iSubsetCount].fSum then
                            OutTable.FieldByName('SUM' + IntToStr(iSubsetCount)).AsFloat := TmpSite.rSubsetSum[iSubsetCount];
                         if ControlRes^.fCalculateAllVariations then
                         begin
                              if UserSubsetChoices._first[iSubsetCount].fSum_A then
                                 OutTable.FieldByName('SUM_A' + IntToStr(iSubsetCount)).AsFloat := WS.r_sub_a[iSubsetCount];
                              if UserSubsetChoices._first[iSubsetCount].fSum_T then
                                 OutTable.FieldByName('SUM_T' + IntToStr(iSubsetCount)).AsFloat := WS.r_sub_t[iSubsetCount];
                              if UserSubsetChoices._first[iSubsetCount].fSum_V then
                                 OutTable.FieldByName('SUM_V' + IntToStr(iSubsetCount)).AsFloat := WS.r_sub_v[iSubsetCount];
                              if UserSubsetChoices._first[iSubsetCount].fSum_AT then
                                 OutTable.FieldByName('SUM_AT' + IntToStr(iSubsetCount)).AsFloat := WS.r_sub_at[iSubsetCount];                              if UserSubsetChoices._first[iSubsetCount].fSum_AV then
                                 OutTable.FieldByName('SUM_AV' + IntToStr(iSubsetCount)).AsFloat :=WS.r_sub_av[iSubsetCount];                              if UserSubsetChoices._first[iSubsetCount].fSum_TV then
                                 OutTable.FieldByName('SUM_TV' + IntToStr(iSubsetCount)).AsFloat :=WS.r_sub_tv[iSubsetCount];                              if UserSubsetChoices._first[iSubsetCount].fSum_ATV then
                                 OutTable.FieldByName('SUM_ATV' + IntToStr(iSubsetCount)).AsFloat :=WS.r_sub_atv[iSubsetCount];                         end;
                    end;

             for iSubsetCount := 1 to 5 do
                 if ControlRes^.ClassDetail[iSubsetCount] then
                 begin
                      if UserSubsetChoices._second[iSubsetCount].fWav then
                         OutTable.FieldByName('WAV' + IntToStr(iSubsetCount)).AsFloat := TmpSite.rSubsetWav[iSubsetCount];
                      if UserSubsetChoices._second[iSubsetCount].fPC then
                         OutTable.FieldByName('PC' + IntToStr(iSubsetCount)).AsFloat := TmpSite.rSubsetPCUsed[iSubsetCount];
                 end;
        end;
        if ControlRes^.fSpatResultCreated then
        begin
             iSubsetVariable := 0;
             for iSubsetCount := 1 to 10 do
                 if ControlRes^.fDoConfigOnSubset[iSubsetCount] then
                 begin
                      Inc(iSubsetVariable);
                      // return value for this site and variable so we can write it to the site table
                      SpatResult.rtnValue(((iSubsetVariable-1)*iSiteCount)+iCount,@rSpatialValue);
                      OutTable.FieldByName('SPAT' + IntToStr(iSubsetCount)).AsFloat := rSpatialValue;
                 end;
             SpatResult.rtnValue((iSubsetVariable*iSiteCount)+iCount,@rSpatialValue);
             OutTable.FieldByName('SPAT').AsFloat := rSpatialValue;
        end;

        if ControlRes^.fMarxanDatabaseExists
        and fMarxanResultCreated then
        begin
             MarxanSites.rtnValue(iCount,@MarxanSiteResult);

             OutTable.FieldByName('MBEST').AsFloat := Bool2Int(MarxanSiteResult.fInBestSolution);
             OutTable.FieldByName('MSUMMED').AsFloat := MarxanSiteResult.iSummedSolution;
             if (iMarxanScenarios > 0) and ControlRes^.fRetrieveMarxanDetailToSiteTable then
                for iSubsetCount := 1 to iMarxanScenarios do
                begin
                     MarxanSiteResult.InSolution.rtnValue(iSubsetCount,@fInSiteResult);
                     OutTable.FieldByName('MSOLN' + IntToStr(iSubsetCount+ControlRes^.iRetrieveMarxanDetailStart-1)).AsFloat := Bool2Int(fInSiteResult);
                end;
        end;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in PopulateExtraFields',mtInformation,[mbOk],0);
        end;
   end;

begin
     fStop := False;

     if ((R1.Items.Count + R2.Items.Count + R3.Items.Count + R4.Items.Count + R5.Items.Count +
          Excluded.Items.Count) > 0) then
        fUpdInitIrrepl := False
     else
         fUpdInitIrrepl := True;

     try
        ProgressOn;
        ProcLabelOn('Updating Database');

        try
           OutTable.Open; {initialises DB on first Line of Table}

           InitExtraFields;

        except on exception do
               begin
                    fStop := True;
                    Screen.Cursor := crDefault;
                    MessageDlg('UpdateDatabase cannot open ' + OutTable.DatabaseName +
                               '\' + OutTable.TableName,mtInformation,[mbOk],0);
               end;
        end;

        if not fStop then
        {if (ControlRes^.sShpTable <> '') then}
        if (ControlRes^.GISLink = ArcView) then
        try
           {loads shape file key field from initialisation file
            so we can use it to look up key values}
           LoadAVIni;

           if (ControlRes^.sShpTable = '') then
              fStop := True
           else
           begin
                ShapeTable.TableName := ControlRes^.sShpTable;
                ShapeTable.DatabaseName := ControlRes^.sDatabase;
                ShapeTable.Open;
                new(pShpSite);

                {test to see if the key field setting is correct, call
                 CPlan.GetUserSettings to get user to set it, and reload if it isn't}
                try
                   iAttribute := ShapeTable.FieldByName(ControlRes^.sShpKeyField).AsInteger;

                except
                      ArcViewExecCmd('av.run("CPlan.GetUserSettingsAndUpdate",{' + ControlRes^.sDatabase + '}');
                      {exit UpdateDatabase method}
                      exit;
                end;
           end;

        except on exception do
               begin
                    fStop := True;
                    Screen.Cursor := crDefault;
                    //MessageDlg('UpdateDatabase cannot open ' + ShapeTable.DatabaseName +
                    //           '\' + ShapeTable.TableName,mtInformation,[mbOk],0);
               end;
        end;

        if (not OutTable.BOF) then
        begin
             OutTable.Close;
             OutTable.Open;
        end;

        if not fStop then
        begin
             iCount := 1;

             while not(OutTable.EOF) do
             begin
                  if (iCount <= iSiteCount) then
                  begin
                       ProgressUpdate(Round((iCount/iSiteCount)*100));
                       SiteArr.rtnValue(iCount,@TmpSite);

                       if (ControlRes^.GISLink = ArcView) then
                       begin
                            ShapeTable.Edit;
                            iAttribute := ShapeTable.FieldByName(ControlRes^.sShpKeyField).AsInteger;

                            iShpIndex := findIntegerMatch(OrdSiteArr,iAttribute);
                            if (iShpIndex > 0) then
                               SiteArr.rtnValue(iShpIndex,pShpSite)
                            else
                                pShpSite^.iKey := -1;

                            try
                            if (pShpSite^.iKey <> iAttribute) then
                               ShapeTable.FieldByName('DISPLAY').AsString := '' // site does not exist in SiteArr
                            else
                                ShapeTable.FieldByName('DISPLAY').AsString := pShpSite^.sDisplay;
                            except
                            end;
                       end;

                       if (OutTable.FieldByName(ControlRes^.sKeyField).AsInteger = TmpSite.iKey) then
                       begin {DB index,geocode matches array index,geocode}

                            OutTable.Edit;

                            try
                               if ControlRes^.fUseNewDBLABELS then
                               begin
                                    OutTable.FieldByName(NEW_DISP_DBLABEL).AsString := TmpSite.sDisplay;
                                    OutTable.FieldByName(SUMMED_IRREPL_DBLABEL).AsFloat := TmpSite.rSummedIrr;
                                    OutTable.FieldByName(STATUS_DBLABEL).AsString := Status2Str(TmpSite.status);
                                    OutTable.FieldByName(NEW_PERCENT_AREA_DBLABEL).AsFloat := TmpSite.rPCUSED;
                                    OutTable.FieldByName(WAVIRR_DBLABEL).AsFloat := TmpSite.rWAVIRR;

                                    if fUpdInitIrrepl then
                                    begin
                                         OutTable.FieldByName(NEW_INITIRR_DBLABEL).AsString :=
                                                    FloatToStr(TmpSite.rIrreplaceability);
                                         {map new SUBSEMR to INITEMR}

                                         OutTable.FieldByName('I_SUMIRR').AsFloat := TmpSite.rSummedIrr;
                                         OutTable.FieldByName('I_WAVIRR').AsFloat := TmpSite.rWAVIRR;
                                         OutTable.FieldByName('I_PCCONTR').AsFloat := TmpSite.rPCUSED;
                                    end;
                                    OutTable.FieldByName(NEW_IRREPL_DBLABEL).AsFloat := TmpSite.rIrreplaceability;

                                    PopulateExtraFields;
                               end
                               else
                               begin
                                    OutTable.FieldByName(
                                                 IRREPLACEABILITY_DISPLAY_CLASS_DBLABEL).AsString :=
                                                      TmpSite.sDisplay;
                                    OutTable.FieldByName(SUMMED_IRREPL_DBLABEL).AsFloat := TmpSite.rSummedIrr;
                                    OutTable.FieldByName(STATUS_DBLABEL).AsString := Status2Str(TmpSite.status);
                                    OutTable.FieldByName(PERCENT_AREA_USED_DBLABEL).AsFloat := TmpSite.rPCUSED;
                                    OutTable.FieldByName(WAVIRR_DBLABEL).AsFloat := TmpSite.rWAVIRR;

                                    if fUpdInitIrrepl then
                                    begin
                                         OutTable.FieldByName(INITIAL_IRREPLACEABILITY_DBLABEL).AsString :=
                                                    FloatToStr(TmpSite.rIrreplaceability);
                                         {map new SUBSEMR to INITEMR}

                                         OutTable.FieldByName('I_SUMIRR').AsFloat := TmpSite.rSummedIrr;
                                         OutTable.FieldByName('I_WAVIRR').AsFloat := TmpSite.rWAVIRR;
                                    end;
                                    OutTable.FieldByName(IRREPLACEABILITY_DBLABEL).AsString :=FloatToStr(TmpSite.rIrreplaceability);                               end;

                            except on EDBEngineError do
                                   begin
                                        // Its Errors property contains TDBError.Message objects
                                        {OutTable.FieldByName(IRREPLACEABILITY_DBLABEL).AsFloat := 0;}
                                        // >' + EDBEngineError.Errors[0].Message + '<
                                        MessageDlg('UpdateDatabase translate error, key: ' + IntToStr(TmpSite.iKey)
                                              ,mtInformation,[mbOK],0);
                                   end;
                            end;

                            Inc(iCount);
                            OutTable.Next; {move to next DB Line}
                            if (ControlRes^.GISLink = ArcView) then
                               ShapeTable.Next;
                       end
                       else
                       begin
                            InitCode := -1;
                            messagedlg
                              ('Key mismatch in Site Summary Table >' +
                               OutTable.FieldByName(ControlRes^.sKeyField).AsString +
                               '< In Memory >' + IntToStr(TmpSite.iKey) +
                               '< In File >' + IntToStr(iCount) +
                               ' Order of Table has become invalid',
                               mtError,[mbOk],0);

                            Application.Terminate;
                            Exit;
                       end;
                  end
                  else
                  begin
                       OutTable.Next;
                       if (ControlRes^.GISLink = ArcView) then
                          ShapeTable.Next;
                  end;
             end;

             // if we are linked to ArcView and
             // not yet at the end of the ShapeTable, traverse it finish updating it
             if (ControlRes^.GISLink = ArcView) then
                while not ShapeTable.EOF do
                begin
                     ShapeTable.Edit;

                     iAttribute := ShapeTable.FieldByName(ControlRes^.sShpKeyField).AsInteger;

                     iShpIndex := findIntegerMatch(OrdSiteArr,iAttribute);
                     if (iShpIndex > 0) then
                        SiteArr.rtnValue(iShpIndex,pShpSite)
                     else
                         pShpSite^.iKey := -1;

                     try
                     if (pShpSite^.iKey <> iAttribute) then
                        ShapeTable.FieldByName('DISPLAY').AsString := '' // site does not exist in SiteArr
                     else
                         ShapeTable.FieldByName('DISPLAY').AsString := pShpSite^.sDisplay;
                     except
                     end;
                     ShapeTable.Next;
                end;
        end;

        if not fStop then
        begin
             OutTable.Close;
             if (ControlRes^.GISLink = ArcView) then
             begin
                  ShapeTable.Close;
                  dispose(pShpSite);
             end;
        end;

        ProgressOff;
        ProcLabelOff;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Update Database at row ' + IntToStr(iCount),
                      mtError,
                      [mbOk],
                      0);

           if not fStop then
           begin
                OutTable.Close;
                if (ControlRes^.GISLink = ArcView) then
                begin
                     ShapeTable.Close;
                     dispose(pShpSite);
                end;
           end;
           ProgressOff;
           ProcLabelOff;
     end; {of try..except}

end; {of procedure TControlForm.UpdateDatabase}

procedure TControlForm.UpdateTenure;
// write tenure to the shape file dbf table
var
   iCount, iShpIndex, iAttribute, iWriteCount : integer;
   pShpSite : sitepointer;
   fStop, fStopSkip : boolean;
begin
     fStop := False;

     if (ControlRes^.GISLink = ArcView) then
     try
        ProgressOn;
        ProcLabelOn('Updating Tenure');

        try
           {loads shape file key field from initialisation file
            so we can use it to look up key values}
           LoadAVIni;

           ShapeTable.TableName := ControlRes^.sShpTable;
           ShapeTable.DatabaseName := ControlRes^.sDatabase;
           ShapeTable.Open;
           new(pShpSite);

           {test to see if the key field setting is correct, call
            CPlan.GetUserSettings to get user to set it, and reload if it isn't}
           try
              iAttribute := ShapeTable.FieldByName(ControlRes^.sShpKeyField).AsInteger;

           except
                 ArcViewExecCmd('av.run("CPlan.GetSettingsTenure",{' + ControlRes^.sDatabase + '}');
                 {exit UpdateTenure method}
                 exit;

           end;

        except on exception do
               begin
                    fStop := True;
                    Screen.Cursor := crDefault;
                    MessageDlg('UpdateTenure cannot open ' + ShapeTable.DatabaseName +
                               '\' + ShapeTable.TableName,mtInformation,[mbOk],0);
               end;
        end;

        if not fStop then
        begin
             iCount := 1;

             while not ShapeTable.EOF do
             begin
                  ProgressUpdate(Round((iCount/ShapeTable.RecordCount)*100));

                  ShapeTable.Edit;

                  iAttribute := ShapeTable.FieldByName(ControlRes^.sShpKeyField).AsInteger;

                  iShpIndex := findIntegerMatch(OrdSiteArr,iAttribute);
                  if (iShpIndex > 0) then
                     SiteArr.rtnValue(iShpIndex,pShpSite)
                  else
                      pShpSite^.iKey := -1;

                  try
                  if (pShpSite^.iKey <> iAttribute) then
                     ShapeTable.FieldByName('TENURE').AsString := '' // site does not exist in SiteArr
                  else
                      case pShpSite^.status of
                           Ig : ShapeTable.FieldByName('TENURE').AsString := 'Initial Excluded';
                           Re : ShapeTable.FieldByName('TENURE').AsString := 'Initial Reserve';
                      else
                          ShapeTable.FieldByName('TENURE').AsString := 'Initial Available';

                      end;
                  except
                  end;

                  ShapeTable.Next;

                  Inc(iCount);
             end;
        end;

     finally
            if not fStop then
            begin
                 ShapeTable.Close;
                 dispose(pShpSite);
            end;
            ProgressOff;
            ProcLabelOff;
     end; {of try..finally}

end; {of procedure TControlForm.UpdateTenure}

procedure TControlForm.LoadVegArea;
// read VegArea from the site summary table
var
   iCount : integer;
   rVegArea : extended;
   fStop : boolean;
begin
     fStop := False;

     try
        OutTable.Open;
        fStop := not TableContainsField(OutTable,'VEGAREA');
        iCount := 1;

        if not fStop then
        while not OutTable.EOF do
        begin
             rVegArea := OutTable.FieldByName('VEGAREA').AsFloat;
             VegArea.setValue(iCount,@rVegArea);

             OutTable.Next;

             Inc(iCount);
        end;

     finally
            OutTable.Close;
     end; {of try..finally}

end; {of procedure TControlForm.LoadVegArea}

procedure ParseShapeTable;
var
   iCount : integer;
   sDisplay : string;
   fInitField, fInitSet : boolean;
begin
     with ControlForm do
     begin
          try
             ShapeTable.TableName := ControlRes^.sShpTable;
             ShapeTable.DatabaseName := ControlRes^.sDatabase;
             ShapeTable.Open;


          except on exception do
                 begin
                      Screen.Cursor := crDefault;
                      MessageDlg('InitDisplay2DB cannot open ' + ShapeTable.DatabaseName +
                                 '\' + ShapeTable.TableName,mtInformation,[mbOk],0);
                 end;
          end;

          iCount := 1;

          {we must set display}
          while not(ShapeTable.EOF) do
          begin
               if (iCount <= ShapeTable.RecordCount) then
               begin
                    ProgressUpdate(Round((iCount/ShapeTable.RecordCount)*100));

                    try
                       sDisplay := ShapeTable.FieldByName('DISPLAY').AsString;

                       if (sDisplay <> 'Res')
                       and (sDisplay <> 'Ign') then

                       sDisplay := '0Co';

                       ShapeTable.Edit;
                       ShapeTable.FieldByName('DISPLAY').AsString := sDisplay;
                    except
                    end;
               end;
               Inc(iCount);

               ShapeTable.Next; {move to next DB Line}
          end;

          ShapeTable.Close;
     end;
end;


procedure ParseSiteSummaryTable;
var
   iCount : integer;
   sDBClass, sTenure : string;
begin
     with ControlForm do
     begin
          OutTable.Open;

          iCount := 1;

          while not(OutTable.EOF) do
          begin
               if (iCount <= OutTable.RecordCount) then
               begin
                    ProgressUpdate(Round((iCount/OutTable.RecordCount)*100));

                    try
                       sTenure := OutTable.FieldByName(ControlRes^.sI_STATUSField).AsString;

                       if (sTenure = 'Reserved') then
                          sDBClass := 'Res'
                       else
                           if (sTenure = 'Ignored') then
                              sDBClass := 'Ign'
                           else
                               sDBClass := '0Co';

                       OutTable.Edit;

                       if ControlRes^.fUseNewDBLABELS then
                       begin
                            OutTable.FieldByName(NEW_DISP_DBLABEL).AsString := sDBClass;
                            OutTable.FieldByName(NEW_PREV_DISP_DBLABEL).AsString := sDBClass;
                       end
                       else
                       begin
                            OutTable.FieldByName(IRREPLACEABILITY_DISPLAY_CLASS_DBLABEL).AsString := sDBClass;
                            OutTable.FieldByName(PREVIOUS_DISPLAY_CLASS_DBLABEL).AsString := sDBClass;
                       end;


                    except on EDBEngineError do
                           begin
                                MessageDlg('InitDisplay2DB translate error',
                                           mtInformation,[mbOK],0);
                           end;
                    end;

               end;

               Inc(iCount);

               OutTable.Next; {move to next DB Line}
          end;

          OutTable.Close;
     end;
end;

{-------- end DBMS Stuff ------------------------------------------}

procedure TControlForm.ProgressOn;
begin
     if (WindowState = wsMinimized)
     or ControlRes^.fToolView then
     begin
          ControlRes^.sOldCaption := Caption;
          fCaptionProgress := True;
     end
     else
         fCaptionProgress := False;

     ProgressGauge.Progress := 0;
     ProgressGauge.Visible := True;
     ProgressGauge.Refresh;

     iPrevUpdate := 0;
end;

procedure TControlForm.ProgressUpdate(const iCurrVal : integer);
var
   sTmp : string;
begin
     if (Time > (ProgressLastUpdate+One_Sec)) then
        if (iCurrVal > ProgressGauge.Progress) then
        begin
             if fCaptionProgress then
             begin
                  sTmp := IntToStr(iCurrVal) + '%';
                  if ProcLabel.Visible then
                     sTmp := sTmp + ' ' + ProcLabel.Caption;

                  Caption := sTmp;
             end;

             if ControlRes^.fToolView then
                ToolForm.UpdateCaption
             else
             begin
                  ProgressGauge.Progress := iCurrVal;
                  Refresh;
             end;

             ProgressLastUpdate := Time;
        end;
end;

procedure TControlForm.ProgressOff;
begin
     if fCaptionProgress then
        Caption := ControlRes^.sOldCaption;

     if ControlRes^.fToolView then
        ToolForm.UpdateCaption;

     ProgressGauge.Visible := False;
     ProgressGauge.Refresh;
end;

procedure SetOption(const MyIni : TIniFile; const sOption : string);
var
   sStr : string;
   iIndex : integer;
begin
     try
        if (sOption = 'UpdateGISValues') then
           ControlRes^.fUpdateGISValues := MyIni.ReadBool('Options','UpdateGISValues',False)
        else
        if (sOption = 'DisplayAbsSumirr') then
           ControlRes^.fDisplayAbsSumirr := MyIni.ReadBool('Options','DisplayAbsSumirr',False)
        else
        if (sOption = 'DisplayScheme') then
           ControlRes^.iDisplayScheme := MyIni.ReadInteger('Options','DisplayScheme',0)
        else
        if (sOption = 'SparseMatrix') then
           ControlRes^.sSparseMatrix := MyIni.ReadString('Options','SparseMatrix','')
        else
        if (sOption = 'SparseKey') then
           ControlRes^.sSparseKey := MyIni.ReadString('Options','SparseKey','')
        else
        if (sOption = 'Key') then
           ControlRes^.sKeyField := MyIni.ReadString('Options','Key','GEOCODE')
        else
        if (sOption = 'SelectMapSites') then
        begin
             sStr := MyIni.ReadString('Options','SelectMapSites','Yes');
             if (sStr = 'Ask') then
                ControlRes^.iSelectMapSites := 2
             else
                 if (sStr = 'No') then
                    ControlRes^.iSelectMapSites := 1
                 else
                     ControlRes^.iSelectMapSites := 0;
        end
        else
        if (sOption = 'ZoomOnSelect') then
           ControlRes^.fZoomOnSelect := MyIni.ReadBool('Options','ZoomOnSelect',True)
        else
        if (sOption = 'Display Values') then
        begin
             ControlRes^.iDisplayValuesFor := MyIni.ReadInteger('Options',
                                                                'DisplayValues',
                                                                0 {default is Available Sites});
        end
        else
        {$IFDEF PAGING_ARRAY}
        if (sOption = 'PagingDirectory') then
        begin
             basedir := MyIni.ReadString('Options','PagingDirectory',ControlRes^.sDatabase);
             baselocation := basedir + '\' + DARRAYT_PAGEFILE;

             ForceDirectories(baselocation);
        end
        else
        {$ENDIF}
        if (sOption = 'WorkingDirectory') then
        begin
             ControlRes^.sWorkingDirectory := MyIni.ReadString('Options','WorkingDirectory',ControlRes^.sDatabase);

             if not DirectoryExists(ControlRes^.sWorkingDirectory) then
             begin
                  ControlRes^.sWorkingDirectory := ControlRes^.sDatabase;
                  fIniChange := True;

                  try
                     WorkingDirForm := TWorkingDirForm.Create(Application);

                     WorkingDirForm.EditPath.Text := ControlRes^.sWorkingDirectory;

                     if (mrOk = WorkingDirForm.ShowModal)
                     and (ControlRes^.sWorkingDirectory <> WorkingDirForm.EditPath.Text) then
                     begin
                          ControlRes^.sWorkingDirectory := WorkingDirForm.EditPath.Text;
                          fIniChange := True;

                          ForceDirectories(ControlRes^.sWorkingDirectory);
                     end;

                  finally
                         WorkingDirForm.Free;
                  end;
             end;
        end
        else
        if (sOption = 'InitialiseGISDisplay') then
        begin
             ControlRes^.fInitialiseGIS := MyIni.ReadBool('Options','InitialiseGISDisplay',True);
        end
        else
        if (sOption = 'UseImportedTargets') then
        begin
             ControlForm.UseFeatCutOffs.Checked := MyIni.ReadBool('Options','UseImportedTargets',False);
        end
        else
        if (sOption = 'LinkToGIS') then
        begin
             if fLinkToArcView then
             begin
                  {override the INI file settings and link to ArcView anyway,
                   CPlan has been launched from ArcView}
                  ControlRes^.GisLink := ArcView;

                  {prompt user to change settings in INI file if ArcView is
                   not the default GIS already}
                  sStr := MyIni.ReadString('Options',sOption,'None');
                  if (sStr <> 'ArcView') then
                     fIniChange := True;
             end
             else
             begin
                  sStr := MyIni.ReadString('Options',sOption,'None');

                  ControlRes^.fLinkToWinERMS := FALSE;
                  ControlRes^.GisLink := None;

                  if (sStr = 'ArcView') then
                     ControlRes^.GisLink := ArcView;
                     
                  if (sStr = 'ZonaeCogito') then
                     DDE_TryOpenZonaeCogito;
             end;
        end
        else
        if (sOption = 'PlotField') then
        begin
             sStr := MyIni.ReadString('Options',sOption,'Irreplaceability');
             case sStr[1] of
                  'I' : iIndex := 0;
                  'S' : iIndex := 1;
                  'W' : iIndex := 2;
                  'P' : iIndex := 3;
             else
                 // Default to Irreplaceabilty as plot field if not specified correctly
                 iIndex := 0;
             end;
             ControlRes^.iGISPlotField := iIndex;
        end
        else
        if (sOption = 'ProposeReplacementSites') then
           fProposeSites := MyIni.ReadBool('Options',sOption,True)
        else
        if (sOption = 'MinimiseOnDone') then
           fMinimiseOnDone := False
        else
        if (sOption = 'DDEOn') then
           ControlForm.DDEActivate.Checked := MyIni.ReadBool('Options',sOption,True)
        else
        if (sOption = 'DefaultTargetPercent') then
        begin
             try
                rPercentage := RegionSafeStrToFloat(MyIni.ReadString('Options',sOption,IntToStr(DEFAULT_PERCENT)));
             except
                   rPercentage := DEFAULT_PERCENT;
             end;
             ControlForm.TargetPercent.Text := FloatToStr(rPercentage);
             ControlForm.TargetPercent.Refresh;
        end
        else
        if (sOption = 'ShowHints') then
           fShowHints := MyIni.ReadBool('Options',sOption,True)
        else
        if (sOption = 'SiteSummaryTable') then
           ControlRes^.sSiteSummaryTable := MyIni.ReadString('Options',sOption,'noname.dbf');

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in SetOption ' + sOption,mtError,[mbOk],0);
     end;
end;

procedure ReadToolViewOptions(AIni : TIniFile);
var
   iIndex : integer;
   sCycle, sSctn : string;
begin
     sSctn := 'Tool View';

     if (AIni.ReadString(sSctn,'ShowToolView','ERROR') = 'ERROR') then
        sSctn := 'Tool Bar';

     ControlRes^.fToolView := AIni.ReadBool(sSctn,'ShowToolView',False);
     ControlRes^.fShowIrrep := AIni.ReadBool(sSctn,'IrrepButton',True);
     ControlRes^.fShowAccept := AIni.ReadBool(sSctn,'AcceptButton',True);
     ControlRes^.fShowCycle := AIni.ReadBool(sSctn,'CycleButton',True);
     ControlRes^.fShowF2Targ := AIni.ReadBool(sSctn,'F2TargButton',True);
     ControlRes^.fShowContrib := AIni.ReadBool(sSctn,'ContribButton',True);
     ControlRes^.fShowSelLog := AIni.ReadBool(sSctn,'SelLogButton',True);
     ControlRes^.fShowPartDef := AIni.ReadBool(sSctn,'PartDefButton',True);
     ControlRes^.fShowOpen := AIni.ReadBool(sSctn,'OpenButton',True);
     ControlRes^.fShowSave := AIni.ReadBool(sSctn,'SaveButton',True);
     ControlRes^.fShowSaveAs := AIni.ReadBool(sSctn,'SaveAsButton',True);
     ControlRes^.fShowRestTarg := AIni.ReadBool(sSctn,'RestTargButton',True);
     ControlRes^.fShowBrowse := AIni.ReadBool(sSctn,'BrowseButton',True);
     ControlRes^.fShowPopUp := AIni.ReadBool(sSctn,'ShowPopUpHints',True);
     ControlRes^.fShowExit := AIni.ReadBool(sSctn,'ExitButton',True);
     ControlForm.HideMandatory1.Checked := AIni.ReadBool('Hide','Mandatory',False) or AIni.ReadBool('Hide',ControlRes^.sR2Label,False);
     ControlForm.HidePartial1.Checked := AIni.ReadBool('Hide','Partial',True);
     ControlForm.HideFlagged1.Checked := AIni.ReadBool('Hide','Flagged',True);
     ControlForm.HideExcluded1.Checked := AIni.ReadBool('Hide','Excluded',False);

     ApplyHide;

     sCycle := AIni.ReadString('Options','Click Action','Lookup');


     iIndex := ControlForm.ClickGroup.Items.IndexOf(sCycle);
     if (iIndex >= 0) then
        ControlForm.ClickGroup.ItemIndex := iIndex;
end;

procedure TryLoadFormSize(AIni : TIniFile);
begin
     if (AIni.ReadInteger('ControlForm','Top',-100) <> -100) then
     begin
          ControlRes^.iControlTop := AIni.ReadInteger('ControlForm','Top',1);
          ControlRes^.iControlLeft := AIni.ReadInteger('ControlForm','Left',1);
          ControlRes^.iControlHeight := AIni.ReadInteger('ControlForm','Height',600);
          ControlRes^.iControlWidth := AIni.ReadInteger('ControlForm','Width',400);

          ControlRes^.fSizeControl := True;
     end
     else
         ControlRes^.fSizeControl := False;

     if (AIni.ReadInteger('LookupForm','Top',-100) <> -100) then
     begin
          ControlRes^.iLookupTop := AIni.ReadInteger('LookupForm','Top',1);
          ControlRes^.iLookupLeft := AIni.ReadInteger('LookupForm','Left',1);
          ControlRes^.iLookupHeight := AIni.ReadInteger('LookupForm','Height',600);
          ControlRes^.iLookupWidth := AIni.ReadInteger('LookupForm','Width',400);

          ControlRes^.fSizeLookup := True;
     end
     else
         ControlRes^.fSizeLookup := False;
end;

function RegionSafeStrToFloat(const sCell : string) : extended;
var
   iPos : integer;
begin
     // safely reads a float with a . as DecimalSeperator when the DecimalSeperator
     // is other that .
     try
        Result := StrToFloat(sCell);

     except
           // StrToFloat has failed, so substitute DecimalSeperator for . in sCell and try again
           iPos := Pos('.',sCell);
           if (iPos > 1) then
              Result := StrToFloat(Copy(sCell,1,iPos-1) + DecimalSeparator + Copy(sCell,iPos+1,Length(sCell)-iPos));
     end;
end;

function RegionSafeFloatToStr(const rValue : extended) : string;
var
   iPos : integer;
begin
     // makes a float with . as DecimalSeperator safe to send to ArcView which
     // is not region specific ???? maybe overseas versions will be
     if (DecimalSeparator = '.') then
        Result := FloatToStr(rValue)
     else
     begin
          Result := FloatToStr(rValue);
          iPos := Pos(DecimalSeparator,Result);
          if (iPos > 1) then
             Result := Copy(Result,1,iPos-1) + '.' + Copy(Result,iPos+1,Length(Result)-iPos);
     end;
end;

procedure TControlForm.LoadIni(Sender: TObject);
var
   sTmp, sThisDB, sSST : string;
   rTmp : extended;
   iCount : integer;

   wOldCursor : integer;

   MyIni : TIniFile;

   fStop : boolean;
begin
     try
        sTmp := '';
        fStop := False;

        if FileExists(ControlRes^.sDatabase + '\' + INI_FILE_NAME) then
           ControlRes^.fOldIni := False
        else
            ControlRes^.fOldIni := True;

        if ControlRes^.fOldIni then
           MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
        else
            MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);

        ChooseDBForm := TChooseDBForm.Create(Application);
        ChooseDBForm.DBBox.Items.Clear;

        iCount := 1;
        repeat
              sThisDB := MyIni.ReadString('Database' + IntToStr(iCount),
                                          'Name',ERROR_STRING);

              if (sThisDB <> ERROR_STRING) then
                 ChooseDBForm.DBBox.Items.Add(sThisDB);

              Inc(iCount);

        until (sThisDB = ERROR_STRING);

        if (ChooseDBForm.DBBox.Items.Count > 1) then
        begin
             iDBToLoad := 0;
             wOldCursor := Screen.Cursor;
             Screen.Cursor := crDefault;

             ChooseDBForm.ShowModal;

             if (ChooseDBForm.DBBox.SelCount = 0) then
             begin
                  fStop := True;
                  iDBToLoad := -1;
             end;

             Screen.Cursor := wOldCursor;
             ChooseDBForm.Free;

             iDBLoaded := iDBToLoad;

             if not fStop then
             begin
                  ControlRes^.sSiteFeatureTable := MyIni.ReadString('Database'+IntToStr(iDBToLoad),
                                                        'MatrixFile',
                                                        ERROR_STRING);
                  if (ControlRes^.sSiteFeatureTable = ERROR_STRING) then
                     ControlRes^.sSiteFeatureTable := MyIni.ReadString('Database'+IntToStr(iDBToLoad),
                                                           'SiteFeatureTable',
                                                           ERROR_STRING);
                  {'SiteFeatureTable' is now called 'MatrixFile'}

                  ControlRes^.sFeatCutOffsTable := MyIni.ReadString('Database'+IntToStr(iDBToLoad),
                                                        'FeatureSummaryTable',
                                                        ERROR_STRING);
                  if (ControlRes^.sFeatCutOffsTable = ERROR_STRING) then
                     ControlRes^.sFeatCutOffsTable := MyIni.ReadString('Database'+IntToStr(iDBToLoad),
                                                           'FeatureCutOffsTable',
                                                           ERROR_STRING);
                  sSST := MyIni.ReadString('Database'+IntToStr(iDBToLoad),
                                           'SiteSummaryTable',ERROR_STRING);
                  if (sSST <> ERROR_STRING) then
                     ControlRes^.sSiteSummaryTable := sSST;
             end;
        end
        else
        begin
             if (ChooseDBForm.DBBox.Items.Count = 1) then
             begin
                  iDBLoaded := 1;

                  ControlRes^.sSiteFeatureTable := MyIni.ReadString('Database1',
                                                                    'MatrixFile',
                                                                    ERROR_STRING);
                  if (ControlRes^.sSiteFeatureTable = ERROR_STRING) then
                     ControlRes^.sSiteFeatureTable := MyIni.ReadString('Database1',
                                                                       'SiteFeatureTable',
                                                                       ERROR_STRING);
                  ControlRes^.sFeatCutOffsTable := MyIni.ReadString('Database1',
                                                                    'FeatureSummaryTable',
                                                                    ERROR_STRING);
                  if (ControlRes^.sFeatCutOffsTable = ERROR_STRING) then
                     ControlRes^.sFeatCutOffsTable := MyIni.ReadString('Database1',
                                                                       'FeatureCutOffsTable',
                                                                       ERROR_STRING);

                  sSST := MyIni.ReadString('Database1',
                                           'SiteSummaryTable',ERROR_STRING);
                  if (sSST <> ERROR_STRING) then
                     ControlRes^.sSiteSummaryTable := sSST;
             end
             else
             begin
                  if ControlRes^.fOldIni then
                                      MessageDlg('No Database Entries Found in ' + ControlRes^.sDatabase +
                                '\' + OLD_INI_FILE_NAME,mtError,[mbOK],0)
                  else
                                   MessageDlg('No Database Entries Found in ' + ControlRes^.sDatabase +
                                 '\' + INI_FILE_NAME,mtError,[mbOK],0);
             end;

             ChooseDBForm.Free;
        end;

        ControlRes^.sDatabaseName := MyIni.ReadString('Database'+IntToStr(iDBLoaded),
                                                      'Name','no name');


        MyIni.ReadSection('Options',IniBox.Items);

        if IniBox.Items.Count > 0 then
           for iCount := 0 to (IniBox.Items.Count-1) do
               SetOption(MyIni,IniBox.Items.Strings[iCount]);

        MyIni.ReadSection('Display Fields',LookupDisplayList.Items);

        ControlRes^.fShowExtraTools := MyIni.ReadBool('Extended Functions','ShowExtraTools',False);

        TryShowExtraTools;

        ReadToolViewOptions(MyIni);

        TryLoadFormSize(MyIni);

        {load Summed Irreplaceability weighting options}
        ControlRes^.fCalculateAllVariations := MyIni.ReadBool('Sumirr Weightings','CalculateAllVariations',True);
        ControlRes^.fSumirrWeightArea := MyIni.ReadBool('Sumirr Weightings','Area',False);
        ControlRes^.fSumirrWeightTarget := MyIni.ReadBool('Sumirr Weightings','Target',False);
        ControlRes^.fSumirrWeightVuln := MyIni.ReadBool('Sumirr Weightings','Vulnerability',False);
        ControlRes^.rSummedMinimumWeight := RegionSafeStrToFloat(MyIni.ReadString('Sumirr Weightings','Minimum Weight','0' + DecimalSeparator + '2'));
        ControlRes^.fCalculateBobsExtraVariations := MyIni.ReadBool('Sumirr Weightings','CalculateBobsExtraVariations',False);
        sTmp := MyIni.ReadString('Sumirr Weightings','ScalingRange','0 to 1');
        if (sTmp = '0 to 1') then
           ControlRes^.iScalingType := 0
        else
            ControlRes^.iScalingType := 1;
        // 'Sumirr Weightings','VulnerabilityType'
        if ControlRes^.fFloatVulnerabilityLoaded then
        begin
             sTmp := MyIni.ReadString('Sumirr Weightings','VulnerabilityType','continuous values');
             if (sTmp = 'continuous values') then
                ControlRes^.iVulnWeightingType := 1
             else
                 ControlRes^.iVulnWeightingType := 0;
        end
        else
            // no float vulnerability field available, set to default '5 ordinal classes'
            ControlRes^.iVulnWeightingType := 0;

        {load vulnerability weightings}
        ControlRes^.VulnerabilityWeightings[1] := RegionSafeStrToFloat(MyIni.ReadString('Vulnerability','1','0'));
        ControlRes^.VulnerabilityWeightings[2] := RegionSafeStrToFloat(MyIni.ReadString('Vulnerability','2','0'));
        ControlRes^.VulnerabilityWeightings[3] := RegionSafeStrToFloat(MyIni.ReadString('Vulnerability','3','0'));
        ControlRes^.VulnerabilityWeightings[4] := RegionSafeStrToFloat(MyIni.ReadString('Vulnerability','4','0'));
        ControlRes^.VulnerabilityWeightings[5] := RegionSafeStrToFloat(MyIni.ReadString('Vulnerability','5','0'));
        if (ControlRes^.VulnerabilityWeightings[1] = 0) then
           ControlRes^.VulnerabilityWeightings[1] := RegionSafeStrToFloat(MyIni.ReadString('Sumirr Vulnerability Weightings','1','1'));
        if (ControlRes^.VulnerabilityWeightings[2] = 0) then
           ControlRes^.VulnerabilityWeightings[2] := RegionSafeStrToFloat(MyIni.ReadString('Sumirr Vulnerability Weightings','2','0.8'));
        if (ControlRes^.VulnerabilityWeightings[3] = 0) then
           ControlRes^.VulnerabilityWeightings[3] := RegionSafeStrToFloat(MyIni.ReadString('Sumirr Vulnerability Weightings','3','0.6'));
        if (ControlRes^.VulnerabilityWeightings[4] = 0) then
           ControlRes^.VulnerabilityWeightings[4] := RegionSafeStrToFloat(MyIni.ReadString('Sumirr Vulnerability Weightings','4','0.4'));
        if (ControlRes^.VulnerabilityWeightings[5] = 0) then
           ControlRes^.VulnerabilityWeightings[5] := RegionSafeStrToFloat(MyIni.ReadString('Sumirr Vulnerability Weightings','5','0.2'));
        {load Spatial Configuration Tool settings}
        ControlRes^.fConnectSPATTOOL := MyIni.ReadBool('Spatial Tool','ConnectSpatialTool',FALSE);
        ControlRes^.sSpatialDistanceFile := MyIni.ReadString('Spatial Tool','SpatialDatabase','');
        ControlRes^.iSpatialVariableToPass := MyIni.ReadInteger('Spatial Tool','SpatialVariableToPass',0);
        ControlRes^.fRecalcSpatialCONTRIB := MyIni.ReadBool('Spatial Tool','RecalculateSpatialContrib',True);

        // Set custom reports
        LoadCustomizedReports(MyIni);

        // load combination size options
        ControlRes^.fDisplayCSTriggerPopup := MyIni.ReadBool('CombinationSize','DisplayTriggerPopup',True);

        combsize.iCustomCombinationSize := MyIni.ReadInteger('CombinationSize',
                                                             'Custom',
                                                             2);
        ControlRes^.fLogCombsizeRecalc := MyIni.ReadBool('CombinationSize','KeepALogFile',False);

        ControlRes^.fPartialValidateCombsize := MyIni.ReadBool('CombinationSize','PartialValidate',False);
        ControlRes^.fSuppressCSExclusionRecalc := MyIni.ReadBool('CombinationSize','SuppressCSExclusionRecalc',False);
        ControlRes^.sPointFeatureField := MyIni.ReadString('Exclude Point Features From Combination Size','field','');
        ControlRes^.fPointFeaturesSpecified := (ControlRes^.sPointFeatureField = '');

        ControlRes^.sReportTargetField := MyIni.ReadString('Report Target','Field','ITARGET');

        ControlRes^.sR1Label := MyIni.ReadString('Reserve Class','Class 1 Label','Negotiated');
        if (ControlRes^.sR1Label = 'Negotiated') then
           ControlRes^.sR2Label := MyIni.ReadString('Reserve Class','Class 2 Label','Mandatory')
        else
            ControlRes^.sR2Label := MyIni.ReadString('Reserve Class','Class 2 Label','');
        ControlRes^.fR2Visible := not (ControlRes^.sR2Label = '');
        ControlRes^.sR3Label := MyIni.ReadString('Reserve Class','Class 3 Label','');
        ControlRes^.fR3Visible := not (ControlRes^.sR3Label = '');
        ControlRes^.sR4Label := MyIni.ReadString('Reserve Class','Class 4 Label','');
        ControlRes^.fR4Visible := not (ControlRes^.sR4Label = '');
        ControlRes^.sR5Label := MyIni.ReadString('Reserve Class','Class 5 Label','');
        ControlRes^.fR5Visible := not (ControlRes^.sR5Label = '');

        ControlRes^.sMarxanDatabasePath := MyIni.ReadString('Marxan','MarxanDatabasePath','');
        //ControlRes^.sMarxanOutputPath := MyIni.ReadString('Marxan','MarxanOutputPath','');
        if (ControlRes^.sMarxanDatabasePath <> '') then
            ControlRes^.fMarxanDatabaseExists := True;
        ControlRes^.fLockReserve := MyIni.ReadBool('Marxan','LockSelectedAsReserve',True);

        ControlRes^.fGenerate_TXT_DBF_log := MyIni.ReadBool('Log File','Generate TXT DBF',False);

        ControlRes^.iRetrieveMarxanDetailNumber := MyIni.ReadInteger('Marxan','RetrieveDetailCount',50);
        ControlRes^.iRetrieveMarxanDetailStart := MyIni.ReadInteger('Marxan','RetrieveDetailStart',1);
        ControlRes^.fRetrieveMarxanDetailToSiteTable := MyIni.ReadBool('Marxan','RetrieveDetailToSiteTable',True);
        ControlRes^.sMarxanCostField := MyIni.ReadString('Marxan','COST','COST');
        ControlRes^.fOptimisedMarxan := MyIni.ReadBool('Marxan','UseOptimisedMarxan',False);

        // load destruction rate field
        ControlRes^.sDESTRATEField := MyIni.ReadString('Destruction','Destruction Rate','DESTRATE');

        ControlRes^.sSiteVulnFieldName := MyIni.ReadString('Options','SiteVulnField','');
        if (ControlRes^.sSiteVulnFieldName <> '') then
           ControlRes^.fLoadSiteVuln := True;
        ControlRes^.sSiteCostFieldName := MyIni.ReadString('Options','SiteCostField','');
        if (ControlRes^.sSiteCostFieldName <> '') then
           ControlRes^.fLoadSiteCost := True;

        LabelNeMa;

        MyIni.Free;

        fIniChange := False;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception loading ini file',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TControlForm.ReLoadIni(Sender: TObject);
var
   sTmp : string;
   iCount : integer;

   MyIni : TIniFile;
begin
     sTmp := '';

     if ControlRes^.fOldIni then
		  	 MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
		  else
		      MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);


     ControlRes^.sSiteFeatureTable := MyIni.ReadString('Database'+IntToStr(iDBLoaded),
                                                       'MatrixFile',
                                                       ERROR_STRING);
     if (ControlRes^.sSiteFeatureTable = ERROR_STRING) then
        ControlRes^.sSiteFeatureTable := MyIni.ReadString('Database'+IntToStr(iDBLoaded),
                                                          'SiteFeatureTable',
                                                          ERROR_STRING);

     ControlRes^.sFeatCutOffsTable := MyIni.ReadString('Database'+IntToStr(iDBLoaded),
                                                       'FeatureSummaryTable',
                                                       ERROR_STRING);
     if (ControlRes^.sFeatCutOffsTable = ERROR_STRING) then
        ControlRes^.sFeatCutOffsTable := MyIni.ReadString('Database'+IntToStr(iDBLoaded),
                                                          'FeatureCutOffsTable',
                                                          ERROR_STRING);

     MyIni.ReadSection('Options',IniBox.Items);

     if IniBox.Items.Count > 0 then
        for iCount := 0 to (IniBox.Items.Count-1) do
            SetOption(MyIni,IniBox.Items.Strings[iCount]);

     MyIni.ReadSection('Display Fields',LookupDisplayList.Items);

     ReadToolViewOptions(MyIni);

     TryLoadFormSize(MyIni);

     MyIni.Free;
end;


function Bool2String(const fValue : boolean) : string;
begin
     if (fValue = True) then
        Result := 'True'
     else
         Result := 'False';
end;

procedure WriteToolViewOptions(AIni : TIniFile);
begin
     AIni.WriteBool('Tool Bar','ShowToolView',ControlRes^.fToolView);
     AIni.WriteBool('Tool Bar','OpenButton',ControlRes^.fShowOpen);
     AIni.WriteBool('Tool Bar','BrowseButton',ControlRes^.fShowBrowse);
     AIni.WriteBool('Tool Bar','SaveButton',ControlRes^.fShowSave);
     AIni.WriteBool('Tool Bar','SaveAsButton',ControlRes^.fShowSaveAs);
     AIni.WriteBool('Tool Bar','IrrepButton',ControlRes^.fShowIrrep);
     AIni.WriteBool('Tool Bar','AcceptButton',ControlRes^.fShowAccept);
     AIni.WriteBool('Tool Bar','CycleButton',ControlRes^.fShowCycle);
     AIni.WriteBool('Tool Bar','ContribButton',ControlRes^.fShowContrib);
     AIni.WriteBool('Tool Bar','F2TargButton',ControlRes^.fShowF2Targ);
     AIni.WriteBool('Tool Bar','PartDefButton',ControlRes^.fShowPartDef);
     AIni.WriteBool('Tool Bar','RestTargButton',ControlRes^.fShowRestTarg);
     AIni.WriteBool('Tool Bar','SelLogButton',ControlRes^.fShowSelLog);
     AIni.WriteBool('Tool Bar','ExitButton',ControlRes^.fShowExit);
     AIni.WriteBool('Tool Bar','ShowPopUpHints',ControlRes^.fShowPopUp);
     AIni.WriteBool('Hide',ControlRes^.sR2Label,ControlForm.HideMandatory1.Checked);
     AIni.WriteBool('Hide','Partial',ControlForm.HidePartial1.Checked);
     AIni.WriteBool('Hide','Flagged',ControlForm.HideFlagged1.Checked);
     AIni.WriteBool('Hide','Excluded',ControlForm.HideExcluded1.Checked);

     AIni.WriteString('Options','Click Action',
                      ControlForm.ClickGroup.Items[ControlForm.ClickGroup.ItemIndex]);
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



procedure TControlForm.SaveIni(Sender: TObject;
                               const sFilename : string);
var
   iCount : integer;
   sTmp : string;

   MyIni : TIniFile;
begin
     try
        if ControlRes^.fOldIni then
        begin
             ACopyFile(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME,
                       ControlRes^.sDatabase + '\' +
                       Copy(OLD_INI_FILE_NAME,1,Length(OLD_INI_FILE_NAME)-3) + '~IN');

             MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME);
        end
        else
        begin
             ACopyFile(ControlRes^.sDatabase + '\' + INI_FILE_NAME,
                       ControlRes^.sDatabase + '\' +
                       Copy(INI_FILE_NAME,1,Length(INI_FILE_NAME)-3) + '~IN');

             if (sFilename = '') then
                MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME)
             else
                 // use sFilename
                 MyIni := TIniFile.Create(sFilename);
        end;

        with MyIni do
        begin
             EraseSection('Options');
             EraseSection('Available Fields');
             EraseSection('Display Fields');
             EraseSection('Tool View');
             EraseSection('Tool Bar');
             EraseSection('Extended Functions');

             WriteBool('Extended Functions','ShowExtraTools',ControlRes^.fShowExtraTools);
             WriteString('Options','Key',ControlRes^.sKeyField);

             case ControlRes^.iGISPlotField of
                  0 : sTmp := 'Irreplaceability';
                  1 : sTmp := 'SUMIRR';
                  2 : sTmp := 'WAVIRR';
                  3 : sTmp := 'PCUSED';
                  10 : sTmp := 'MSummedSoln';
             else
                 // we are displaying one of the spatial subset fields, just write sumirr
                 sTmp := 'SUMIRR';
             end;

             WriteString('Options','PlotField',sTmp);

             if (ControlRes^.GISLink = ArcView) then
                sTmp := 'ArcView'
             else
                 if (ControlRes^.GISLink = ZonaeCogito) then
                 begin
                      sTmp := 'ZonaeCogito';

                      if (ControlRes^.sZCProject = '') then
                      begin
                           ControlRes^.sZCProject := ControlRes^.sDatabase + '\' + ReturnProjectName(ControlRes^.sDatabase);

                           ZonaeCogitoExecCmd('saveproject ' + ControlRes^.sZCProject); 
                      end;

                      WriteString('ZonaeCogito','Project',ControlRes^.sZCProject);
                      WriteString('ZonaeCogito','ShapeTable',ControlRes^.sShpTable);
                      WriteString('ZonaeCogito','Key',ControlRes^.sShpKeyField);
                 end
                 else
                     sTmp := 'None';

             WriteString('Options','LinkToGIS',sTmp);

             if (ControlRes^.sShpTable <> '') then
                WriteString('Options','ShapeTable',ControlRes^.sShpTable);

             WriteBool('Options','UpdateGISValues',ControlRes^.fUpdateGISValues);

             {insert new options}
             WriteBool('Options','DDEOn',ControlForm.DDEActivate.Checked);
             WriteString('Options','DefaultTargetPercent',FloatToStr(rPercentage));
             WriteBool('Options','ShowHints',fShowHints);
             WriteString('Options','SparseKey',ControlRes^.sSparseKey);
             WriteString('Options','SparseMatrix',ControlRes^.sSparseMatrix);
             WriteString('Options','SiteSummaryTable',ControlRes^.sSiteSummaryTable);
             WriteBool('Options','UseImportedTargets',UseFeatCutOffs.Checked);
             WriteBool('Options','InitialiseGISDisplay',ControlRes^.fInitialiseGIS);

             if (ControlRes^.sDatabase <> ControlRes^.sWorkingDirectory) then
                WriteString('Options','WorkingDirectory',ControlRes^.sWorkingDirectory);

        {$IFDEF PAGING_ARRAY}
             WriteString('Options','PagingDirectory',basedir);
             {write the PagingDirectory for the arrayt}
        {$ENDIF}

             WriteInteger('Options','Display Values',ControlRes^.iDisplayValuesFor);

             case ControlRes^.iSelectMapSites of
                  0 : WriteString('Options','SelectMapSites','Yes');
                  1 : WriteString('Options','SelectMapSites','No');
                  2 : WriteString('Options','SelectMapSites','Ask');
             end;

             WriteInteger('Options','DisplayScheme',ControlRes^.iDisplayScheme);

             WriteBool('Options','ZoomOnSelect',ControlRes^.fZoomOnSelect);

             WriteBool('Options','DisplayAbsSumirr',ControlRes^.fDisplayAbsSumirr);

             if (LookupDisplayList.Items.Count > 0) then
                for iCount := 0 to (LookupDisplayList.Items.Count-1) do
                    WriteString('Display Fields',LookupDisplayList.Items.Strings[iCount],'');

             WriteToolViewOptions(MyIni);

             EraseSection('ControlForm');
             EraseSection('LookupForm');

             WriteInteger('ControlForm','Top',ControlForm.Top);
             WriteInteger('ControlForm','Left',ControlForm.Left);
             WriteInteger('ControlForm','Height',ControlForm.Height);
             WriteInteger('ControlForm','Width',ControlForm.Width);

             WriteInteger('LookupForm','Top',LookupForm.Top);
             WriteInteger('LookupForm','Left',LookupForm.Left);
             WriteInteger('LookupForm','Height',LookupForm.Height);
             WriteInteger('LookupForm','Width',LookupForm.Width);

             WriteBool('Sumirr Weightings','Area',ControlRes^.fSumirrWeightArea);
             WriteBool('Sumirr Weightings','Target',ControlRes^.fSumirrWeightTarget);
             WriteBool('Sumirr Weightings','Vulnerability',ControlRes^.fSumirrWeightVuln);
             WriteString('Sumirr Weightings',
                         'Minimum Weight',
                         FloatToStr(ControlRes^.rSummedMinimumWeight));
             WriteBool('Sumirr Weightings','CalculateAllVariations',ControlRes^.fCalculateAllVariations);
             WriteBool('Sumirr Weightings','CalculateBobsExtraVariations',ControlRes^.fCalculateBobsExtraVariations);
             case ControlRes^.iScalingType of
                  0 : WriteString('Sumirr Weightings','ScalingRange','0 to 1');
                  1 : WriteString('Sumirr Weightings','ScalingRange','1 to 10');
             end;
             case ControlRes^.iVulnWeightingType of
                  0 : WriteString('Sumirr Weightings','VulnerabilityType','5 ordinal classes');
                  1 : WriteString('Sumirr Weightings','VulnerabilityType','continuous values');
             end;

             // write the users spatial settings to the ini file
             WriteInteger('Spatial Tool','SpatialVariableToPass',ControlRes^.iSpatialVariableToPass);
             WriteString('Spatial Tool','SpatialContribReservedWeighting',FloatToStr(ControlRes^.rSpatContribReservedWeight));
             WriteInteger('Spatial Tool','SpatialContribRadius',ControlRes^.iSpatialContribRadius);
             WriteString('Spatial Tool','SpatialContribExponent',FloatToStr(ControlRes^.rSpatialContribExponent));
             WriteBool('Spatial Tool','RecalculateSpatialCONTRIB',ControlRes^.fRecalcSpatialCONTRIB);

             WriteBool('CombinationSize','DisplayTriggerPopup',ControlRes^.fDisplayCSTriggerPopup);
             WriteBool('CombinationSize','KeepALogFile',ControlRes^.fLogCombsizeRecalc);
             WriteBool('CombinationSize','PartialValidate',ControlRes^.fPartialValidateCombsize);
             WriteBool('CombinationSize','SuppressCSExclusionRecalc',ControlRes^.fSuppressCSExclusionRecalc);

             if ControlRes^.fMarxanDatabaseExists then
             begin
                  WriteString('Marxan','MarxanDatabasePath',ControlRes^.sMarxanDatabasePath);
                  WriteBool('Marxan','LockSelectedAsReserve',ControlRes^.fLockReserve);

                  WriteInteger('Marxan','RetrieveDetailCount',ControlRes^.iRetrieveMarxanDetailNumber);
                  WriteInteger('Marxan','RetrieveDetailStart',ControlRes^.iRetrieveMarxanDetailStart);
                  WriteBool('Marxan','RetrieveDetailToSiteTable',ControlRes^.fRetrieveMarxanDetailToSiteTable);
                  WriteString('Marxan','COST',ControlRes^.sMarxanCostField);
                  WriteBool('Marxan','UseOptimisedMarxan',ControlRes^.fOptimisedMarxan);
             end;

             WriteBool('Log File','Generate TXT DBF',ControlRes^.fGenerate_TXT_DBF_log);

             Free;
        end;
        RemoveIniSpaces;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception Saving ini file',mtError,[mbOk],0);
     end;

end; {of procedure TControlForm.SaveIni}

procedure TrimPathName(const sLine : string;
                       var sPath, sAppName : string);
{TrimPathName trims the Application name (without .exe) for opening a DDE
 conversation with this application and the path name for loading the
 initialistion file (cplan.ini)}
var
   iDot, iSlash : integer;
begin
     iDot := Length(sLine); {start at end of sLine}
     while (sLine[iDot] <> '.') do Dec(iDot); {find .(exe)}

     iSlash := iDot - 1;
     while (sLine[iSlash] <> '\') do Dec(iSlash); {find last \ in sLine}

     sPath := Copy(sLine,1,(iSlash-1));
     sAppName := Copy(sLine,(iSlash + 1),(iDot - iSlash - 1));
end;

procedure SetDBNames;
begin
     with ControlForm do
     begin
          InTable.DatabaseName := ControlRes^.sDatabase;
          InTable.TableName := ControlRes^.sSiteFeatureTable;

          OutTable.DatabaseName := ControlRes^.sDatabase;
          OutTable.TableName := ControlRes^.sSiteSummaryTable;

          CutOffTable.DatabaseName := ControlRes^.sDatabase;
          CutOffTable.TableName := ControlRes^.sFeatCutOffsTable;
     end;
end;

function ChopVarDir(const sLine : string) : string;
var
   iCount : integer;
begin
     {this function chops the variable directory from the Database path
      passed by WinERMS}
     iCount := Length(sLine);
     while (sLine[iCount] <> '\') do
           Dec(iCount);
     Result := Copy(sLine,1,iCount-1);
end;

procedure InitRes;
{initialises our control resources located in ControlRes}
begin
     try
        ResetUserSubsetChoices;

        rAreaSinceDestruction := 0;
        rTotalAreaDestroyed := 0;

        sJob := '';
        sValidateIterationsFile := '';

        fCreatingMarxanPrototypeForm := False;
        fMarxanResultCreated := False;
        fReceiveDataExtended := False;
        fStopExecutingMinset := False;
        fValidateIterationsCreated := False;
        fAverageSiteCreated := False;
        fStartingOptionsForm := False;
        fStartingCombsizeOptionsForm := False;
        fStageListCreated := False;
        fRichnessArrBuilt := False;
        fUsingFeat := False;
        fKeepHighlight := False;
        fProposeSites := False;
        fWatchUnDef := False;
        fWatchExc := False;
        fContrDataDone := False;
        fContrDoneOnce := False;
        fIniChange := False;
        fDestructionApplied := False;
        fCrownLandSitesCreated := False;

        fHedleySimulatorDebug := True;
        fFirstStart := True;

        ProgressLastUpdate := Time;

        iSpattoolRequest := -1;
        iLooper := 1;
        iReceiveDataExtended := 0;
        iSpattoolProcess := 0; // no active spattool process
        iOldNumCodes := 0;
        iDebugLogList := 0;
        iReportMem := 0;

        sGlobalHigh := 1;
        sGlobalStep := 0.2;
        iLastCodeGrabbed := -1;
        iMinsetIterationCount := -1;
        // 1 eighth of a second
        One_Sec := StrToTime('0:0:1')/5;
        iDestructionYear := -1;

        combsize.iSelectedCombinationSize := 0;
        combsize.iCurrentSelectedCombinationSize := 0;
        combsize.iCurrentSitesUsed := 0;
        combsize.iCustomCombinationSize := 0;
        combsize.iActiveCombinationSize := 0;
        combsize.iActiveNoComplCombinationSize := 0;

        new(ControlRes); {allocate the Control Resource object}
        InitConfigSubsets;

        with ControlRes^ do
        begin
             LastCombinationSizeCondition := Startup;

             fReportMinsetMemSize := False;
             InitMemoryReportFile;

             fLoadSiteVuln := False;
             fLoadSiteCost := False;
             fOptimisedMarxan := False;
             fStartDestructReportsRun := False;
             fLockReserve := True;
             fGenerate_TXT_DBF_log := False;
             fDisplayCSTriggerPopup := True;
             fR2Visible := False;
             fR3Visible := False;
             fR4Visible := False;
             fR5Visible := False;
             fMarxanDatabaseExists := False;
             fSuppressCSExclusionRecalc := False;
             fNullHotspotsSimulation := False;
             fGISRegionalSettingIsEnglish := True;
             fPointFeaturesSpecified := False;
             fValidateMinset := False;
             fLockUserDefinedCombinationSize := False;
             fValidateIterationsFileSpecified := False;
             fPartialValidateCombsize := False;
             fUpdateGISValues := False;
             fRedCheckExcludeSitesCreated := False;
             fLogCombsizeRecalc := False;
             fCalculateBobsExtraVariations := False;
             fMinsetIsRunning := False;
             fCSSelectChange := False;
             fDisplayAbsSumirr := False;
             fCustomCombSize := False;
             fInitialValuesCreated := False;
             fDebugLookup := False;
             fDestructObjectsCreated := False;
             fPrepareSpreadRun := False;
             fRecalcContrib := False;
             fDebugSPATTOOL := False;
             fSpatResultCreated := False;
             fConnectSPATTOOL := False;
             fConnectedToSPATTOOL := False;
             fOptionCreate := False;
             fSRADIUSLoaded := False;
             fPATCHCONLoaded := False;
             fCalculateAllVariations := False;
             fVulnerabilityLoaded := False;
             fSumirrWeightArea := False;
             fSumirrWeightTarget := False;
             fSumirrWeightVuln := False;
             fStatusTested := False;
             fKeyTested := False;
             fExtantLoaded := False;
             fFeatureKeyTested := False;
             fReportTime := False;
             fValidateIrreplaceability := False;
             fMultiDDESelect := False;
             fFeatureFormUp := False;
             fFeatureClassesApplied := False;
             fValidateCombsize := False;
             fGenerateCompRpt := False;
             fValidateMode := False;
             fToolView := False;
             fLinkToWinERMS := False;
             fFeatureFormUp := False;
             fDeSelectSite := False;
             fShowExtraTools := False;
             fDisplayAbsSumirr := False;
             fRandomTest := False;
             fStayOnTop := False;

             fDumpAverageSite := False;

             fRetrieveMarxanDetailToSiteTable := True;
             fShowIrrep := True;
             fShowAccept := True;
             fShowCycle := True;
             fShowF2Targ := True;
             fShowContrib := True;
             fShowSelLog := True;
             fShowStageMemo := True;
             fShowPartDef := True;
             fShowOpen := True;
             fShowSave := True;
             fShowSaveAs := True;
             fShowRestTarg := True;
             fShowRedCheck := True;
             fShowBrowse := True;
             fCheckMatrixOrder := True;
             fRecalcSpatialCONTRIB := True;
             fZoomOnSelect := True;
             fRunIrrBefRpt := True;
             fStatusOk := True;
             fStarting := True;
             fPersistControl := True;
             fPersistDBMS := True;
             fPersistFeat := True;
             fPersistTool := True;
             fPersistF2Targ := True;
             fInitialiseGIS := True;

             iSimulationYear := 0;
             iRetrieveMarxanDetailNumber := 50;
             iRetrieveMarxanDetailStart := 1;
             iCombinationSizeRange := 0;
             iVulnWeightingType := 0;
             iScalingType := 0;
             iDisplayScheme := 0;
             iLookupDebugReports := 0;
             iSiteAREAFeature := 0;
             iFeaturesWithPATCHCON := 0;
             iFeaturesWithSRADIUS := 0;
             iGISPlotField := 0;
             iSpatialVariableToPass := 0;
             iSelectMapSites := 0;
             iValidateCount := 0;
             iDisplayValuesFor := 0;
             iStatusLayer := 0;
             iEMRLayer := 0;
             rDisplayMaximumValue := 0;
             iSelectIterationCount := 0;
             iExecuteIrreplaceabilityCount := 0;

             rTargetMultiplyFactor := 1;
             rSpatialContribExponent := 0.5;
             rSpatialConfigAreaWeighting := 5000;
             iSpatialContribRadius := 1000;
             rSpatContribReservedWeight := 1;
             rSummedMinimumWeight := 0.2;
             VulnerabilityWeightings[1] := 1;
             VulnerabilityWeightings[2] := 0.8;
             VulnerabilityWeightings[3] := 0.6;
             VulnerabilityWeightings[4] := 0.4;
             VulnerabilityWeightings[5] := 0.2;

             sSiteVulnFieldName := '';
             sSiteCostFieldName := '';
             sMarxanDatabasePath := '';
             sMarxanOutputPath := '';
             sPointFeatureField := '';
             sSparseMatrix := '';
             sSparseKey := '';
             sSpatialDistanceFile := '';
             sPrevCaption := '';
             sShpTable := '';
             sSQLQuery := '';
             sFloatVulnerabilityField := '';

             sDESTRATEField := 'DESTRATE';
             sMarxanCostField := 'COST';
             sReportTargetField := 'ITARGET';
             sKeyField := 'GEOCODE';
             sShpKeyField := 'ATTRIBUTE';
             sCompGeoField := 'COMPGEO';
             sCompNameField := 'COMPNAME';
             sLastChoiceType := 'None';
             sStatusLayer := 'none';
             sEMRLayer := 'none';
             sSiteFeatureTable := 'NOTFOUND.MAT';
             sSiteSummaryTable := 'NOTFOUND.DBF';
             sFeatCutOffsTable := 'NOTFOUND.DBF';
             sFeatureTargetField := 'ITARGET';
             sR1Label := 'Class 1';
             sR2Label := 'Class 2';
             sR3Label := 'Class 3';
             sR4Label := 'Class 4';
             sR5Label := 'Class 5';
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in InitRes',mtError,[mbOk],0);
     end;
end;

procedure AutoLoadLog;
var
   AIni : TIniFile;
   sAutoLoadLog : string;
begin
     AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
     sAutoLoadLog := AIni.ReadString('AutoLoadLog','AutoLoadLog','');
     AIni.Free;
     if (sAutoLoadLog <> '') then
        if fileexists(sAutoLoadLog) then
           LoadSelections(sAutoLoadLog);   
end;

function ExecuteCPlanApplication (const hParent : THandle; const sDatabase, sTopic : string) : integer;
var
   PIniPath : PChar;
   iCount : integer;
begin
     if IsValidRegFile then
     begin
          //MessageDlg('C-Plan has been system tested.' +
          //           Chr(13) + Chr(10) + 'Please report any bugs to C-Plan support.',
          //           mtWarning,[mbOk],0);

          Result := 1;

          DumpMemInfo('ExecuteCPlanApplication start');

          try
             arrayt_initialization;

             Screen.Cursor := crHourglass;

             InitRes; {sets initial values for variables}

             DumpMemInfo('ExecuteCPlanApplication after InitRes');

             {extract inverted commas paramaters from sDatabase if present}
             if (sDatabase[1] = '"') then
                ControlRes^.sDatabase := Copy(sDatabase,2,Length(sDatabase)-2)
             else
                 ControlRes^.sDatabase := sDatabase;
             ControlRes^.sWorkingDirectory := ControlRes^.sDatabase;
             ControlRes^.sTopic := sTopic;

          {$IFDEF PAGING_ARRAY}
             basedir := ControlRes^.sDatabase;
             baselocation := basedir + '\' + DARRAYT_PAGEFILE;
             {set default paging directory for the arrayt}
          {$ENDIF}

             ermsHandle := hParent; {get handle on parent process}
             TrimPathName(Application.ExeName,ControlRes^.sAppPath,ControlRes^.sService);
             {get Service for DDE and path for application tools}

             Application.HintPause := 0;

             GetMem(PIniPath,PATH_MAX);
             GetWindowsDirectory(PIniPath,PATH_MAX);
             ControlRes^.sIniPath := StrPas(PIniPath);

             CreateControlForm;

             LookupOn;
             {start the dbms lookup object}

             FitComponents2Form;
             {adjust position of components on form}

             DumpMemInfo('ExecuteCPlanApplication before scan INI');

             {if Local Ini file exists, load it}

             if FileExists(ControlRes^.sDatabase + '\' + INI_FILE_NAME)
             or FileExists(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME) then
                ControlForm.LoadIni(ControlForm) {loads details from Local cplan.ini}
             else
             begin
                  Screen.Cursor := crDefault;

                  MessageDlg('ini file not found',mtError,[mbOk],0);

                  Application.Terminate;

                  exit;
             end;

             if (iDBLoaded < 0) then
             begin
                  Application.Terminate;
                  exit;
             end;


             DumpMemInfo('ExecuteCPlanApplication after scan INI');

             if fUseParams then
             begin
                  {after loading the ini file, we need to apply (override) these options
                   with our previously scanned command line parameters}
                  ControlForm.UseFeatCutOffs.Checked := not fFlatTarg;
                  {target flag   fFlatTarg true when flat targets engaged by command line}
                  {
                  for iCount := 0 to (ControlForm.IrrGroup.Items.Count-1) do
                      if (sUsePred = ControlForm.IrrGroup.Items.Strings[iCount]) then
                         ControlForm.IrrGroup.ItemIndex := iCount;
                  }
                  {predictor flag}
             end;

             (*EnableMandatory;       {allow mandatory/excluded user choices}
             EnableExcluded;
             EnablePartial;
             EnableFlagged;*)
             SetDBNames;
             // clean the site database of any accumulated fields before we start using it
             ControlForm.CleanDatabase;
             LoadDBMSDisplayFields;
             
             SetControlCaption;

          finally
                 Screen.Cursor := crDefault;
          end;

          if ControlRes^.fToolView then
             ToolForm := TToolForm.Create(Application)
          else
              ControlForm.Show;

          DumpMemInfo('ExecuteCPlanApplication before InitPrep01');

          {this is where we call code to set up the control form and data structures}
          InitPrep01;

          if not ControlForm.TargetPercent.Enabled then
             ControlForm.UseFeatCutOffs.Hint := 'Click to apply Percentage targets'
          else
              ControlForm.UseFeatCutOffs.Hint := 'Click to apply User-Defined targets';


          DumpMemInfo('ExecuteCPlanApplication end');

          ControlRes^.fStarting := False;

     end
     else
     begin
          {MessageDlg('Please register C-Plan',mtError,[mbOk],0);}

          {start the registration program}
          if not RunCPlanApp('register','') then
             MessageDlg('Please reinstall C-Plan',mtError,[mbOk],0);

          Application.Terminate;
          exit;
     end;

end;  {of function ExecuteCPlanApplication}

procedure LabelCountUpdate;
var
   sLine : string;
begin
     with ControlForm do
     begin
          sLine := 'Available Sites (' + IntToStr(Available.Items.Count) + ')';
          AvailableLabel.Caption := sLine;
          sLine :=  ControlRes^.sR1Label + ' Sites (' + IntToStr(R1.Items.Count) + ')';
          SelectedLabel.Caption := sLine;
          sLine :=  ControlRes^.sR2Label + ' Sites (' + IntToStr(R2.Items.Count) + ')';
          MandatoryLabel.Caption := sLine;
          sLine :=  'Partially Selected Sites (' + IntToStr(Partial.Items.Count) + ')';
          ParLabel.Caption := sLine;
          sLine :=  'Flagged Sites (' + IntToStr(Flagged.Items.Count) + ')';
          FlgLabel.Caption := sLine;
          sLine :=  'Excluded Sites (' + IntToStr(Excluded.Items.Count) + ')';
          ExcludedLabel.Caption := sLine;

          AvailableLabel.Refresh;
          SelectedLabel.Refresh;
          MandatoryLabel.Refresh;
          ParLabel.Refresh;
          FlgLabel.Refresh;
          ExcludedLabel.Refresh;
     end;
end;

procedure CalcExcludeTrimAmount;
var
   pFeat : featureoccurrencepointer;
   iCount : integer;
   rTarget, rTotalArea, rAvailableArea : extended;
begin
     new(pFeat);

     for iCount := 1 to iFeatureCount do
     begin
          // ignore feature if it is switched off
          FeatArr.rtnValue(iCount,pFeat);
          if (not pFeat^.fRestrict) then
          begin
               // set target to original target
               rTarget := pFeat^.rCutOff;
               // trim for totalarea
               rTotalArea := pFeat^.totalarea;
               if (rTarget > rTotalArea) then
                  rTarget := rTotalArea;
               // trim for existing reserves
               rTarget := rTarget - pFeat^.reservedarea;
               // trim for proposed reserves
               rTarget := rTarget - pFeat^.rDeferredArea;
               // if target is greater than available sum area then trimmedarea is the difference
               // (and target > 0)
               pFeat^.rTrimmedArea := 0;
               if (rTarget > 0) then
                  if (rTarget > pFeat^.rCurrentSumArea) then
                  begin
                       pFeat^.rTrimmedArea := rTarget - pFeat^.rCurrentSumArea;
                       FeatArr.setValue(iCount,pFeat);
                  end;
          end;
     end;
     dispose(pFeat);
end;

procedure TControlForm.MoveGroup(var Source,Sgeo : TListBox;
                                 var Dest,Dgeo : TListBox;
                                 const fUser, fComplementarity : boolean);
var
   iKey, iCount, iPDCount : integer;
   lSiteIndex : longint;
   pSite : sitepointer;
   DestStatus, SourceStatus : Status_T;
   wOldCursor : integer;
   sType : string;
   fShowStageSelect, fMoveOk, fReserved : boolean;
   cChoiceCode : char;
   aUserSites,
   aProposedSites, aForProposeSites : Array_t;
   fSourceVisible, fDestVisible,
   fSourceOrDestIsFlagged,
   fLocalProposeSites, fDeferral : boolean;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
begin
     try
        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('MoveGroup begin');

        fSourceVisible := Source.Visible;
        fDestVisible := Dest.Visible;
        Source.Visible := False;
        Dest.Visible := False;

        wOldCursor := Screen.Cursor;
        Screen.Cursor := crHourglass;
        fMoveOk := True;
        iCount := 0;
        fSourceOrDestIsFlagged := False;

        cChoiceCode := CHOICE_CODE_DEFERR;

        fLocalProposeSites := False;

        if (Source.SelCount > 0) then
        begin
             if (Source.Hint = Available.Hint) then
                SourceStatus := Av
             else
             if (Source.Hint = R1.Hint) then
                SourceStatus := _R1
             else
             if (Source.Hint = R2.Hint) then
                SourceStatus := _R2
             else
             if (Source.Hint = R3.Hint) then
                SourceStatus := _R3
             else
             if (Source.Hint = R4.Hint) then
                SourceStatus := _R4
             else
             if (Source.Hint = R5.Hint) then
                SourceStatus := _R5
             else
             if (Source.Hint = Partial.Hint) then
                SourceStatus := Pd
             else
             if (Source.Hint = Flagged.Hint) then
             begin
                  SourceStatus := Fl;
                  fSourceOrDestIsFlagged := True;
             end
             else
             if (Source.Hint = Excluded.Hint) then
                SourceStatus := Ex;

             //fShowStageSelect := False;
             fShowStageSelect := True;

             if (Dest.Hint = R1.Hint) then
             begin
                  sType := ControlRes^.sR1Label;
                  DestStatus := _R1;
                  fShowStageSelect := True;
             end
             else
                 if (Dest.Hint = R2.Hint) then
                 begin
                      sType := ControlRes^.sR2Label;
                      DestStatus := _R2;
                      fShowStageSelect := True;
                 end
                 else
                 if (Dest.Hint = R3.Hint) then
                 begin
                      sType := ControlRes^.sR3Label;
                      DestStatus := _R3;
                      fShowStageSelect := True;
                 end
                 else
                 if (Dest.Hint = R4.Hint) then
                 begin
                      sType := ControlRes^.sR4Label;
                      DestStatus := _R4;
                      fShowStageSelect := True;
                 end
                 else
                 if (Dest.Hint = R5.Hint) then
                 begin
                      sType := ControlRes^.sR5Label;
                      DestStatus := _R5;
                      fShowStageSelect := True;
                 end
                 else
                     if (Dest.Hint = Excluded.Hint) then
                     begin
                          sType := 'Excluded';
                          DestStatus := Ex;

                          if fUser then
                             {we may need TestToExcludeSites}
                             if fWatchExc then
                                if HighlightBox2Arr(Source,Sgeo,aUserSites) then
                                begin
                                     Screen.Cursor := crDefault;
                                     TestToExcludeSites(aUserSites);
                                     UnHighlight(Source,fKeepHighlight);
                                     Arr2Highlight(aUserSites,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);
                                     aUserSites.Destroy;
                                     Screen.Cursor := crHourglass;
                                end;
                     end
                     else
                         if (Dest.Hint = Available.Hint) then
                         begin
                              sType := 'De-Select';
                              DestStatus := Av;
                              cChoiceCode := CHOICE_CODE_DESELECT;

                              if fUser then
                                 if (Source.Hint = R1.Hint)
                                 or (Source.Hint = R2.Hint)
                                 or (Source.Hint = R3.Hint)
                                 or (Source.Hint = R4.Hint)
                                 or (Source.Hint = R5.Hint)
                                 or (Source.Hint = Partial.Hint) then
                                 begin
                                      {we may need TestToUnDeferrSites}
                                      if fWatchUnDef then
                                         if HighlightBox2Arr(Source,Sgeo,aUserSites) then
                                         begin
                                              Deferral_Query := TDeferral_Query.Create(Application);
                                              Screen.Cursor := crDefault;
                                              TestToUnDeferSites(aUserSites);
                                              {displays aMetaCulm and allows users to adjust
                                               site list and see new aMetaCulm}
                                              Screen.Cursor := crHourglass;

                                              {dehighlight and highlight aUserSites}
                                              UnHighlight(Source,fKeepHighlight);
                                              Arr2Highlight(aUserSites,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);

                                              aUserSites.Destroy;
                                         end;

                                      {we may need to ProposeReplacementSites}
                                      {if not ControlRes^.fDeSelectSite then
                                         if fProposeSites then
                                            if HighlightBox2Arr(Source,Sgeo,aForProposeSites) then
                                               fLocalProposeSites := True;}
                                 end;
                         end
                         else
                             if (Dest.Hint = Partial.Hint) then
                             begin
                                  Screen.Cursor := crDefault;
                                  if not fContrDataDone then
                                     if (mrYes = MessageDlg(
                                        'Contribution Data Not Current.  Recalculate and Partially Reserve Site(s)?',
                                         mtConfirmation,[mbYes,mbNo],0)) then
                                     begin
                                          Screen.Cursor := crHourglass;
                                          ExecuteIrreplaceability(-1,False,False,True,True,'');
                                     end;

                                  if fContrDataDone then
                                  begin
                                       sType := 'Partial Deferral';
                                       DestStatus := Pd;
                                       wPartEdFlag := READ_AVAIL;
                                       Screen.Cursor := crDefault;

                                       try
                                          PartEdForm := TPartEdForm.Create(Application);
                                          PartEdForm.ShowModal;
                                       finally
                                              PartEdForm.Free;
                                       end;

                                       {test partial flags of sites}
                                       if HighlightBox2Arr(Source,Sgeo,aUserSites) then
                                       begin
                                            Screen.Cursor := crDefault;
                                            TestPartialSites(aUserSites);
                                            UnHighlight(Source,fKeepHighlight);
                                            Arr2Highlight(aUserSites,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);

                                            if (aUserSites.lMaxSize = 0) then
                                               fMoveOk := False;

                                            aUserSites.Destroy;
                                            Screen.Cursor := crHourglass;

                                            fShowStageSelect := True;
                                       end;
                                  end
                                  else
                                      fMoveOk := False;
                            end
                             else
                                 if (Dest.Hint = Flagged.Hint) then
                                 begin
                                      sType := 'Flagged';
                                      DestStatus := Fl;
                                      fSourceOrDestIsFlagged := True;
                                 end;

             if (Source.SelCount = 0) then
                fMoveOk := False;

             if fUser then
             begin
                if fMoveOk then
                   fMoveOk := EditReason(sType,
                                         SourceStatus,
                                         DestStatus,
                                         fShowStageSelect {boolean show stage select, ie. are we reserving a site}
                                         );
                {fMoveOk set to False if user cancels}
             end
             else
                 AutoSelectReason(sType);
                 {automatic selection, record this in the Selection Log}

             if not fMoveOk then
                UnHighlight(Source,fKeepHighlight);
                {user has cancelled the MoveGroup}
        end;

     except
           Screen.Cursor := crDefault;
           RptErrorStop('exception in MoveGroup init');
     end;

     if fMoveOk then
     try
        while (Source.SelCount > 0) do {while some selected sites}
        begin
             iCount := 0;
             new(pSite);
             while (iCount < Sgeo.Items.Count) do
             begin
                  if Source.Selected[iCount] then
                  begin
                       try
                          ChoiceForm.AddCode(cChoiceCode,Sgeo.Items.Strings[iCount]);

                       except
                             Screen.Cursor := crDefault;
                             MessageDlg('Exception in MoveGroup (adding site ' + Sgeo.Items.Strings[iCount] +
                                        ' to log)',mtError,[mbOk],0);
                       end;

                       //if ControlRes^.fValidateMode then
                       //   ValidateZeroSiteRpt;

                       try
                          Dest.Items.Add(Source.Items.Strings[iCount]);
                          Source.Items.Delete(iCount);

                          iKey := StrToInt(Sgeo.Items.Strings[iCount]);

                          Dgeo.Items.Add(Sgeo.Items.Strings[iCount]);
                          Sgeo.Items.Delete(iCount);

                       except
                             Screen.Cursor := crDefault;
                             MessageDlg('Exception in MoveGroup (moving site between listboxes)',
                                        mtError,[mbOk],0);
                       end;

                       try
                          {adjust site status to reflect this selection}
                          lSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
                          SiteArr.rtnValue(lSiteIndex,pSite);

                          pSite^.status := DestStatus;

                          SiteArr.setValue(lSiteIndex,pSite);

                          {now look up features at this site and adjust targets accordingly}
                          fDeferral := False;
                          case DestStatus of
                               _R1, _R2, _R3, _R4, _R5 :
                               begin
                                    if ControlRes^.fReportMinsetMemSize then
                                       AddMemoryReportRow('MoveGroup before CalcDeferrSite');

                                    CalcDeferrSite(pSite) {deferr all feature areas at this site};

                                    if ControlRes^.fReportMinsetMemSize then
                                       AddMemoryReportRow('MoveGroup after CalcDeferrSite');

                                    fDeferral := True;
                               end;
                               Pd :
                               begin
                                    CalcPartDeferrSite(pSite) {deferr user selected subset of features};
                                    fDeferral := True;
                               end;
                               Fl :  {don't need to deferr any features};
                               Ex : CalcExcludeSite(pSite) {may need to trim feature areas};
                               Av :
                               begin
                                    case SourceStatus of
                                         _R1, _R2, _R3, _R4, _R5 : CalcUnDeferrSite(pSite);
                                         Pd :
                                         begin
                                              CalcUnPartDeferrSite(pSite);
                                              if (pSite^.richness > 0) then
                                                 for iPDCount := 1 to pSite^.richness do
                                                 begin
                                                      fReserved := False;
                                                      SparsePartial.setValue(pSite^.iOffset + iPDCount,@fReserved);
                                                 end;
                                              SiteArr.setValue(lSiteIndex,pSite);
                                         end;
                                         Fl : ;
                                         Ex : CalcUnExcludeSite(pSite);
                                    else
                                        MessageDlg('MoveGroup cannot establish SourceStatus',
                                                   mtError,[mbOk],0);
                                    end;
                               end;
                          else
                              MessageDlg('MoveGroup cannot establish DestStatus',
                                         mtError,[mbOk],0);
                          end;

                       except
                             Screen.Cursor := crDefault;
                             MessageDlg('Exception in MoveGroup (updating targets and status)',
                                        mtError,[mbOk],0);
                       end;

                       if ControlRes^.fValidateMode then
                          ValidateDeferrSiteRpt(fDeferral,IntToStr(pSite^.iKey),fComplementarity);
                       {generate validation reports for this selection if we are in validation mode}

                       // update the arrays of data used as input into Bobs extra sumirr weightings
                       if not ControlRes^.fMinsetIsRunning then
                          if ControlRes^.fCalculateBobsExtraVariations then
                             UpdateMinsetSumirrWeightingArrays;
                  end
                  else
                      Inc(iCount);
             end;
             dispose(pSite);

             try
                if fUser then
                   Autosave;
             except
                   Screen.Cursor := crDefault;
                   MessageDlg('Exception in MoveGroup (autosave failed)',mtError,[mbOk],0);
             end;

             if fSourceOrDestIsFlagged then
             begin
                  fFlagSelectionChange := True;
                  fContrDataDone := False;
             end
             else
             begin
                  fSelectionChange := True; {indicates choice made by user}
                  fContrDataDone := False;
             end;

             {now update labels to show item count in list boxes}
             try
                LabelCountUpdate;
             except
                   Screen.Cursor := crDefault;
                   MessageDlg('Exception in MoveGroup (autosave failed)',mtError,[mbOk],0);
             end;
        end;
        CalcExcludeTrimAmount;
        // trigger ExclusionChange event to recalculate combination size
        if (DestStatus = Ex)
        or (SourceStatus = Ex) then
        begin
             {ZeroTotalArea;
             SparseMatrixStart;
             SparseTargetsStart;}

             ReInitializeInitialValues(ExclusionChange);
             ExecuteIrreplaceability(-1,False,False,True,True,'');
        end;

        if (SourceStatus = _R1)
        or (SourceStatus = _R2)
        or (SourceStatus = _R3)
        or (SourceStatus = _R4)
        or (SourceStatus = _R5)
        or (SourceStatus = Pd) then
           if (ControlRes^.LastCombinationSizeCondition = MinsetLoadLog)
           or (ControlRes^.LastCombinationSizeCondition = TriggerTargetCannotBeMet)
           or (ControlRes^.LastCombinationSizeCondition = TriggerZeroAvSumirr) then
           begin // we are de-selecting from a reserved class and Condition is a trigger
                {ZeroTotalArea;
                SparseMatrixStart;
                SparseTargetsStart;}
                ReInitializeInitialValues(Startup);
                ExecuteIrreplaceability(-1,False,False,True,True,'');
           end;

           Source.Visible := fSourceVisible;
           Dest.Visible := fDestVisible;


           if ControlRes^.fReportMinsetMemSize then
              AddMemoryReportRow('MoveGroup end');

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in MoveGroup',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;

     try
        ApplyHide; {sees if selected/mandatory/partial/flagged/excluded site lists empty,
                    de/activates controls}
        FitComponents2Form;

        ControlRes^.sSQLQuery := '';

     except
           Screen.Cursor := crDefault;
           RptErrorStop('exception in movegroup end');
     end;

     Screen.Cursor := wOldCursor;
end;

procedure TControlForm.MoveSome(var Source,Sgeo : TListBox; var Dest, Dgeo : TListBox;
                                const iNumCodes : integer; const Codes : Array_T);
var
   iBoxCount, iCount, iCount2, iCode : integer;
   SearchArr : Array_t;
begin
     try
        {highlight elements of Source listbox}
        if (Codes.lMaxSize <> iNumCodes) then
           Codes.resize(iNumCodes);
        SearchArr := SortFeatArray(Codes);
        Arr2SiteStatus(Codes,SearchArr,Source,Sgeo);

        {iBoxCount := Sgeo.Items.Count;
        for iCount := 0 to (iBoxCount-1) do
            for iCount2 := 1 to iNumCodes do
            begin
                 Codes.rtnValue(iCount2,@iCode);
                 if (Sgeo.Items.Strings[iCount] = IntToStr(iCode)) then
                    Source.Selected[iCount] := True;
            end;}

        if (Source.SelCount > 0) then
           MoveGroup(Source,Sgeo,Dest,Dgeo,TRUE,True);

        SearchArr.Destroy;
        Codes.Destroy;
        {free up memory object that has been passed from
         calling method}

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TControlForm.MoveSome',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TControlForm.MoveAll(var Source,Sgeo : TListBox; var Dest,Dgeo : TListBox;
                               const fUser : boolean);
var
   iCount, iNumStrings : integer;
begin
     {select all sites in Source}
     iNumStrings := Source.Items.Count;
     if (iNumStrings > 0) then
     begin
          for iCount := 0 to (iNumStrings - 1) do
              Source.Selected[iCount] := TRUE;
          MoveGroup(Source,Sgeo,Dest,Dgeo,fUser,True);
     end;
end;

procedure TControlForm.LoadFeatureTable;
var
   TmpFeat : featureoccurrence;
   pFeat : featureoccurrencepointer;
   wOldCursor : integer;
   iCount, iFeatureTestKey : integer;
   rTest : extended;

begin
     try
        try
           CutOffTable.Open;
        except on EDBEngineError do
               begin
                    for iCount := 1 to iFeatureCount do
                    begin
                         FeatArr.rtnValue(iCount,@TmpFeat);
                         TmpFeat.sID := IntToStr(TmpFeat.code);
                         //TmpFeat.fRestrict := False;
                         FeatArr.setValue(iCount,@TmpFeat);
                    end;

                    {new_code_added_27/9/96}
                    if TargetPercent.Enabled then
                       UseFeatCutOffs.Hint := 'Click to apply Percentage targets'
                    else
                        UseFeatCutOffs.Hint := 'Click to apply User-Defined targets';

                    TargetPercent.Enabled := not UseFeatCutOffs.Checked;

                    {UseFeatCutOffs.Enabled := False;
                    UseFeatCutOffs.Checked := False;}
                    {UseFeatCutOffsClick(self);
                    UseFeatCutOffsClick(self);}

                    wOldCursor := Screen.Cursor;
                    Screen.Cursor := crDefault;

                    MessageDlg('Feature Cut-Off Database file not found - ' +
                               CutOffTable.DatabaseName + '\' +
                               CutOffTable.TableName +
                               '.  Using overall cut-off percentage',mtWarning,[mbOK],0);

                    Screen.Cursor := wOldCursor;
                    Exit;
               end;
        end;

        pFeat := @TmpFeat;

        // test for existence of DESTRATE
        try
           rTest := CutOffTable.FieldByName(ControlRes^.sDESTRATEField).AsFloat;
           ControlRes^.fDESTRATELoaded := True;
        except
              ControlRes^.fDESTRATELoaded := False;
        end;
        {test for existence of EXTANT in the table}
        if not ControlRes^.fExtantLoaded then
        try
           rTest := CutOffTable.FieldByName('EXTANT').AsFloat;
           ControlRes^.fExtantLoaded := True;
        except
              ControlRes^.fExtantLoaded := False;
        end;
        {test for existence of VULN in the table}
        try
           rTest := CutOffTable.FieldByName('VULN').AsFloat;
           ControlRes^.fVulnerabilityLoaded := True;
        except
              ControlRes^.fVulnerabilityLoaded := False;
        end;
        {test for existence of SRADIUS}
        try
           rTest := CutOffTable.FieldByName('SRADIUS').AsFloat;
           ControlRes^.fSRADIUSLoaded := True;
        except
              ControlRes^.fSRADIUSLoaded := False;
        end;
        {test for existence of PATCHCON}
        try
           rTest := CutOffTable.FieldByName('PATCHCON').AsFloat;
           ControlRes^.fPATCHCONLoaded := True;
        except
              ControlRes^.fPATCHCONLoaded := False;
        end;

        while not CutOffTable.EOF do
        begin
             for iCount := 1 to iFeatureCount do
             begin
                  FeatArr.rtnValue(iCount,pFeat);

                  if not ControlRes^.fFeatureKeyTested then
                  try
                     ControlRes^.fFeatureKeyTested := True;
                     iFeatureTestKey := CutOffTable.FieldByName('FEATKEY').AsInteger;
                     ControlRes^.sFeatureKeyField := 'FEATKEY';
                  except
                        ControlRes^.sFeatureKeyField := 'FEATID';
                  end;

                  if (TmpFeat.code = CutOffTable.FieldByName(ControlRes^.sFeatureKeyField).AsInteger) then
                  begin
                       if ControlRes^.fExtantLoaded then
                          TmpFeat.rExtantArea := CutOffTable.FieldByName('EXTANT').AsFloat
                       else
                           TmpFeat.rExtantArea := 0;
                       if ControlRes^.fVulnerabilityLoaded then
                       begin
                            TmpFeat.rVulnerability := CutOffTable.FieldByName('VULN').AsFloat;
                            {$IFDEF TRUNCATE_VULNERABILITY}
                            {TmpFeat.rVulnerability := Trunc(TmpFeat.rVulnerability);
                            if (TmpFeat.rVulnerability > 5) then
                               TmpFeat.rVulnerability := 5;
                            if (TmpFeat.rVulnerability < 0) then
                               TmpFeat.rVulnerability := 0;}
                            {$ENDIF}
                       end
                       else
                           TmpFeat.rVulnerability := 0;
                       if ControlRes^.fSRADIUSLoaded then
                       begin
                            TmpFeat.rSRADIUS := CutOffTable.FieldByName('SRADIUS').AsFloat;
                            if (TmpFeat.rSRADIUS <> 0) then
                               Inc(ControlRes^.iFeaturesWithSRADIUS);
                       end
                       else
                           TmpFeat.rSRADIUS := 0;
                       if ControlRes^.fPATCHCONLoaded then
                       begin
                            TmpFeat.rPATCHCON := CutOffTable.FieldByName('PATCHCON').AsFloat;

                            if (TmpFeat.rPATCHCON <> 0) then
                               Inc(ControlRes^.iFeaturesWithPATCHCON);
                       end
                       else
                           TmpFeat.rPATCHCON := 0;

                       if ControlRes^.fUseNewDBLABELS then
                       begin
                            TmpFeat.rCutOff := CutOffTable.FieldByName('ITARGET').AsFloat;
                            TmpFeat.sID := CutOffTable.FieldByName('FEATNAME').AsString;

                            // detemine if this feature is an AREA feature
                            (*if (TmpFeat.sID = 'AREA') then
                            begin
                                 // record the feature key of the site AREA feature
                                 ControlRes^.iSiteAREAFeature := TmpFeat.code;
                                 TmpFeat.fRestrict := True;
                            end
                            else
                                TmpFeat.fRestrict := False;*)
                       end
                       else
                       begin
                            TmpFeat.rCutOff := CutOffTable.FieldByName('CUTOFF').AsFloat;
                            TmpFeat.sID := CutOffTable.FieldByName('CODE').AsString;
                            //TmpFeat.fRestrict := False;
                       end;

                       FeatArr.setValue(iCount,pFeat);

                  end;
             end;
             CutOffTable.Next;
        end;

        CutOffTable.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadFeatureTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function TableContainsField(const ATable : TTable;
                            const sFieldName : string) : boolean;
var
   iCount : integer;
begin
     //
     Result := False;
     for iCount := 1 to ATable.FieldCount do
         if (sFieldName = ATable.FieldDefs.Items[iCount-1].Name) then
            Result := True;
end;

procedure InitPointFeatures;
var
   iCount : integer;
   fPointFeature : boolean;
begin
     PointFeatures := Array_t.Create;
     PointFeatures.init(SizeOf(boolean),iFeatureCount);
     fPointFeature := False;
     for iCount := 1 to iFeatureCount do
         PointFeatures.setValue(iCount,@fPointFeature);
end;

procedure TControlForm.LoadFeatureInformation;
var
   pFeat : featureoccurrencepointer;
   wOldCursor : integer;
   iCount, iFeatureTestKey : integer;
   rTmp, rTest : extended;
   AIni : TIniFile;
   iValidate : integer;
   fValidate, fLoadValidateField, fSIZEpresent : boolean;
begin
     try
        // dump feature information to a file to see what we have
        new(pFeat);
        try
           CutOffTable.Open;
        except on EDBEngineError do
               begin
                    for iCount := 1 to iFeatureCount do
                    begin
                         FeatArr.rtnValue(iCount,pFeat);
                         pFeat^.sID := IntToStr(pFeat^.code);
                         //pFeat^.fRestrict := False;
                         FeatArr.setValue(iCount,pFeat);
                    end;

                    {new_code_added_27/9/96}
                    if TargetPercent.Enabled then
                       UseFeatCutOffs.Hint := 'Click to apply Percentage targets'
                    else
                        UseFeatCutOffs.Hint := 'Click to apply User-Defined targets';

                    TargetPercent.Enabled := not UseFeatCutOffs.Checked;

                    wOldCursor := Screen.Cursor;
                    Screen.Cursor := crDefault;

                    MessageDlg('Feature Cut-Off Database file not found - ' +
                               CutOffTable.DatabaseName + '\' +
                               CutOffTable.TableName +
                               '.  Using overall cut-off percentage',mtWarning,[mbOK],0);

                    Screen.Cursor := wOldCursor;
                    Exit;
               end;
        end;

        // see if there is a Float Vulnerability field loaded
        AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
        ControlRes^.sFloatVulnerabilityField := AIni.ReadString('Sumirr Weightings','FloatVulnerabilityField','VULN');
        ControlRes^.fFloatVulnerabilityLoaded := TableContainsField(CutOffTable,ControlRes^.sFloatVulnerabilityField);
        AIni.Free;

        if ControlRes^.fPointFeaturesSpecified then
           InitPointFeatures;

        // test for existence of DESTRATE
        ControlRes^.fDESTRATELoaded:= TableContainsField(CutOffTable,ControlRes^.sDESTRATEField);
        // test for existence of EXTANT in the table
        if not ControlRes^.fExtantLoaded then
           ControlRes^.fExtantLoaded := TableContainsField(CutOffTable,'EXTANT');
        // test for existence of VULN in the table
        ControlRes^.fVulnerabilityLoaded:= TableContainsField(CutOffTable,'VULN');
        // test for existence of SRADIUS
        ControlRes^.fSRADIUSLoaded:= TableContainsField(CutOffTable,'SRADIUS');
        // test for existence of PATCHCON
        ControlRes^.fPATCHCONLoaded:= TableContainsField(CutOffTable,'PATCHCON');
        ControlRes^.fReportTargetFieldLoaded := TableContainsField(CutOffTable,ControlRes^.sReportTargetField);
        fSIZEpresent := TableContainsField(CutOffTable,'SIZE');

        fLoadValidateField := TableContainsField(CutOffTable,'VALIDATE');

        while not CutOffTable.EOF do
        begin
             for iCount := 1 to iFeatureCount do
             begin
                  FeatArr.rtnValue(iCount,pFeat);

                  if not ControlRes^.fFeatureKeyTested then
                  try
                     ControlRes^.fFeatureKeyTested := True;
                     iFeatureTestKey := CutOffTable.FieldByName('FEATKEY').AsInteger;
                     ControlRes^.sFeatureKeyField := 'FEATKEY';
                  except
                        ControlRes^.sFeatureKeyField := 'FEATID';
                  end;

                  if (pFeat^.code = CutOffTable.FieldByName(ControlRes^.sFeatureKeyField).AsInteger) then
                  begin
                       if ControlRes^.fReportTargetFieldLoaded then
                       begin
                            rTmp := CutOffTable.FieldByName(ControlRes^.sReportTargetField).AsFloat;
                            ReportTarget.setValue(iCount,@rTmp);
                       end;

                       if fLoadValidateField then
                       begin
                            iValidate := CutOffTable.FieldByName('VALIDATE').AsInteger;
                            if iValidate = 1 then
                                fValidate := True
                            else
                                fValidate := False;
                            ValidateFeature.setValue(iCount,@fValidate);
                       end;

                       if ControlRes^.fExtantLoaded then
                          pFeat^.rExtantArea := CutOffTable.FieldByName('EXTANT').AsFloat
                       else
                           pFeat^.rExtantArea := 0;
                       if ControlRes^.fVulnerabilityLoaded then
                       begin
                            pFeat^.rVulnerability := CutOffTable.FieldByName('VULN').AsFloat;
                            {$IFDEF TRUNCATE_VULNERABILITY}
                            {pFeat^.rVulnerability := Trunc(pFeat^.rVulnerability);
                            if (pFeat^.rVulnerability > 5) then
                               pFeat^.rVulnerability := 5;
                            if (pFeat^.rVulnerability < 0) then
                               pFeat^.rVulnerability := 0;}
                            {$ENDIF}
                       end
                       else
                           pFeat^.rVulnerability := 0;
                       if ControlRes^.fSRADIUSLoaded then
                       begin
                            pFeat^.rSRADIUS := CutOffTable.FieldByName('SRADIUS').AsFloat;
                            if (pFeat^.rSRADIUS <> 0) then
                               Inc(ControlRes^.iFeaturesWithSRADIUS);
                       end
                       else
                           pFeat^.rSRADIUS := 0;
                       if ControlRes^.fPATCHCONLoaded then
                       begin
                            pFeat^.rPATCHCON := CutOffTable.FieldByName('PATCHCON').AsFloat;

                            if (pFeat^.rPATCHCON <> 0) then
                               Inc(ControlRes^.iFeaturesWithPATCHCON);
                       end
                       else
                           pFeat^.rPATCHCON := 0;

                       if ControlRes^.fUseNewDBLABELS then
                       begin
                            pFeat^.rCutOff := CutOffTable.FieldByName('ITARGET').AsFloat;
                            pFeat^.sID := CutOffTable.FieldByName('FEATNAME').AsString;
                       end
                       else
                       begin
                            pFeat^.rCutOff := CutOffTable.FieldByName('CUTOFF').AsFloat;
                            pFeat^.sID := CutOffTable.FieldByName('CODE').AsString;
                       end;

                       // read and store float vulnerability value
                       if ControlRes^.fFloatVulnerabilityLoaded then
                          pFeat^.rFloatVulnerability := CutOffTable.FieldByName(ControlRes^.sFloatVulnerabilityField).AsFloat;

                       if fSIZEpresent then
                          pFeat^.sSIZE := CutOffTable.FieldByName('SIZE').AsString
                       else
                           pFeat^.sSize := '';

                       FeatArr.setValue(iCount,pFeat);
                  end;
             end;
             CutOffTable.Next;
        end;
        CutOffTable.Close;
        dispose(pFeat);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadFeatureInformation',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function LoadIniMatSize : boolean;
var
   AIni : TIniFile;
   iMatSize : integer;
begin
     if ControlRes^.fOldIni then
        AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
     else
         AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);

     iMatSize := AIni.ReadInteger('Database' + IntToStr(iDBLoaded),
                                  S_MATRIX_SIZE,BUFF_ARR_SIZE);
     Result := False;

     if (iMatSize > BUFF_ARR_SIZE) then
     begin
          if (iMatSize <= LARGE_BUFF_ARR_SIZE) then
             Result := True
          else
              MessageDlg('Matrix Size too large, current max is ' +
                         IntToStr(LARGE_BUFF_ARR_SIZE),mtError,[mbOK],0);
     end;
end;


procedure TControlForm.LoadSiteMatrix;
begin
end; {of procedure TControlForm.LoadSiteMatrix}

procedure TControlForm.LoadSiteMatrixV2;
begin
end; {of procedure TControlForm.LoadSiteMatrixV2}

procedure TControlForm.LoadSiteMatrixV3;
begin
end; {of procedure TControlForm.LoadSiteMatrixV3}

procedure TControlForm.LoadSiteMatrixV4;
begin
end; {of procedure TControlForm.LoadSiteMatrixV4}


function TControlForm.GetMatrixVer : integer;
var
   MatrixFile2 : file;
   iBytesRead : integer;
   AHeader : MatFileHeader_T;

begin
     Result := 1;

     try
        assignfile(MatrixFile2,ControlRes^.sDatabase+'\'+InTable.TableName);
        reset(MatrixFile2,1);

        BlockRead(MatrixFile2,AHeader,SizeOf(AHeader),iBytesRead);

        if (AHeader.wVersionNum = 4) then
           Result := 4
        else
            if (AHeader.wVersionNum = 3) then
               Result := 3
            else
                if (AHeader.wVersionNum = 2) then
                   Result := 2;
     finally
            closefile(MatrixFile2);
     end;

end; {of function TControlForm.GetMatrixVer}


procedure TControlForm.TryDDEConnect;
begin
     fDDEConnected := DDEOpenSystemLink;
     {attempt to open system conversation with WinERMS}

     if fDDEConnected then
     begin
          DDEGetSystemInfo;

          DDEOpenMapLink;
          {attempt to open map conversation with WinERMS}

          DDEGetLayerInfo(BASE_LAYER,ControlRes^.sEMRLayer,ControlRes^.iEMRLayer);
          DDEGetLayerInfo(TOP_LAYER,ControlRes^.sStatusLayer,ControlRes^.iStatusLayer);
     end
     else
     begin
          ControlRes^.sEMRLayer := 'none';
          ControlRes^.iEMRLayer := 0;
          ControlRes^.sStatusLayer := 'none';
          ControlRes^.iStatusLayer := 0;
          ControlRes^.fLinkToWinERMS := False;
     end;

     DDEActivate.Checked := fDDEConnected; {switch off DDE if no link}

     SetControlCaption;

     SaveIni(self,'');
end;

procedure SetControlCaption;
var
   sLine : string;
begin
     with ControlForm do
     begin
          if (ClickGroup.ItemIndex = -1) then
             Caption := 'C-Plan'
          else
              Caption := 'C-Plan '+
                         CPLAN_VERSION + ' - ' +
                         ClickGroup.Items.Strings[ClickGroup.ItemIndex] + ' - ' +
                         ControlRes^.sDatabaseName;

          if ControlRes^.fToolView then
             ToolForm.UpdateCaption;

          if (ControlRes^.sPrevCaption <> '') then
             if (sLine <> ControlRes^.sPrevCaption) then
                fIniChange := True;

          ControlRes^.sPrevCaption := sLine;
     end;
end;

procedure TControlForm.SelectGroupClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        ControlRes^.sLastChoiceType := 'Highlight Group';

        MoveGroup(Available,AvailableKey,R1,R1Key,TRUE,True);

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.UnSelectGroupClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        ControlRes^.sLastChoiceType := 'Highlight Group';

        MoveGroup(R1,R1Key,Available,AvailableKey,TRUE,True);

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.UnSelectAllClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        ControlRes^.sLastChoiceType := 'Highlight Group';

        MoveAll(R1,R1Key,Available,AvailableKey,True);

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.ManGroupClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        ControlRes^.sLastChoiceType := 'Highlight Group';

        MoveGroup(Available,AvailableKey,R2,R2Key,TRUE,True);

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.UnManGroupClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        ControlRes^.sLastChoiceType := 'Highlight Group';

        MoveGroup(R2,R2Key,Available,AvailableKey,TRUE,True);

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.UnManAllClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        ControlRes^.sLastChoiceType := 'Highlight Group';

        MoveAll(R2,R2Key,Available,AvailableKey,True);

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure SaveIniCutOff(const iPC : integer);
var
   AIni : TIniFile;
begin
     if ControlRes^.fOldIni then
        AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
     else
         AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
     AIni.WriteInteger('Options','DefaultTargetPercent',iPC);
     AIni.Free;
end;

procedure TControlForm.About1Click(Sender: TObject);
begin
     {show about box}
     //AboutBox := TAboutBox.Create(Application);
     //AboutBox.ShowModal;
     //AboutBox.Free;
end;

procedure TControlForm.Exit1Click(Sender: TObject);
var
   wTmp : word;
   fCancel, fCancelPressed : boolean;
begin
     {exit program}
     fCancel := False;

     if (fSelectionChange or fFlagSelectionChange)
     and ((R1.Items.Count > 0)
          or (R2.Items.Count > 0)
          or (R3.Items.Count > 0)
          or (R4.Items.Count > 0)
          or (R5.Items.Count > 0)
          or (Excluded.Items.Count > 0)
          or (Flagged.Items.Count > 0)
          or (Partial.Items.Count > 0)) then
     {if choices have changed and there are some items currently chosen}
     begin
          wTmp := MessageDlg
             ('Save current site choices before exit?',mtConfirmation,[mbYes,mbNo,mbCancel],0);

          case wTmp of
               mrYes : Save1Click(Self,fCancel,fCancelPressed);
               mrCancel : fCancel := True;
          end;
     end;

     if (not fCancel) then
        if fIniChange then
        begin
             wTmp := MessageDlg
                 ('Save local initialization file before exit?',mtConfirmation,[mbYes,mbNo,mbCancel],0);

             case wTmp of
                  mrYes : SaveIni(self,'');
                  mrCancel : fCancel := True;
             end;
        end;

     DumpMemInfo('Exit1Click before DestroyControlForm');

     if (not fCancel) then
        DestroyControlForm(fReallyExit);

     fReallyExit := not fCancel;

     DumpMemInfo('Exit1Click end');
end;

procedure TControlForm.WinERMSDisconnect(Sender: TObject);
var
   wTmp : word;
   fFlag : boolean;
begin
     (*
     {exit program when WinERMS Disconnects}

     with ControlForm do
     if fSelectionChange
     and ((Mandatory.Items.Count > 0)
          or (Negotiated.Items.Count > 0)
          or (Excluded.Items.Count > 0)
          or (Flagged.Items.Count > 0)
          or (Partial.Items.Count > 0)) then
     {if choices have changed and there are some items currently chosen}
     begin
          wTmp := MessageDlg
             ('Save current site choices before exit?',mtConfirmation,[mbYes,mbNo],0);

          case wTmp of
               mrYes : Save1Click(Self,fFlag);
          end;
     end;

     if fIniChange then
     begin
          wTmp := MessageDlg
              ('Save local initialization file before exit?',mtConfirmation,[mbYes,mbNo],0);

          case wTmp of
               mrYes : SaveIni(self);
          end;
     end;

     {DestroyControlForm(true);}
     Application.Terminate;
     *)
end;

function IsSeperator(const sLine : string) : boolean;
begin
     Result := False;
     if (Length(sLine) >= Length(EMS_SEPARATOR)) then
     begin
          if (Copy(sLine,1,Length(EMS_SEPARATOR)) = EMS_SEPARATOR)
          or (Copy(sLine,1,Length(EMS_SEPERATOR)) = EMS_SEPERATOR)
             {allow user to load old EMS file with incorrect spelling} then
             Result := True;
     end;
end;

function BrowseSelection(const sFileName : string) : boolean;
var
   InFile : text;
   sTmp : string;

   procedure GetBox(var Box : TListBox);
   begin
          Box.Clear;
          repeat
                readln(InFile,sTmp);
                Box.Items.Add(sTmp);
          until EOF(InFile) or IsSeperator(sTmp);
          Box.Items.Delete(Box.Items.Count - 1);
   end;

begin
     Result := True;

     assign(InFile,sFileName);
     reset(InFile);
     readln(InFile);
     GetBox(ControlForm.BrowseEMSReason);
     close(InFile);
end;

function LoadSelections(const sFileName : string) : boolean;
var
   InFile : text;
   sTmp : string;
   fReserved : boolean;

   procedure GetBox(var Box : TListBox);
   begin
          Box.Clear;
          repeat
                readln(InFile,sTmp);
                Box.Items.Add(sTmp);
          until EOF(InFile) or IsSeperator(sTmp);
          Box.Items.Delete(Box.Items.Count - 1);
   end;

   procedure GetPartial;
   var
      iCount, iSiteIndex, iFCount : integer;
      ASite : site;
      cRead : char;
   begin
        with ControlForm.PartialKey do
        if (Items.Count > 0) then
             for iCount := 0 to (Items.Count-1) do
             begin
                  iSiteIndex := FindFeatMatch(OrdSiteArr,StrToInt(Items.Strings[iCount]));
                  SiteArr.rtnValue(iSiteIndex,@ASite);
                  if (ASite.richness > 0) then
                  begin
                       for iFCount := 1 to ASite.richness do
                       begin
                            read(InFile,cRead);

                            if (cRead = '1') then
                               fReserved := True
                            else
                                fReserved := False;
                            SparsePartial.setValue(ASite.iOffset + iFCount,@fReserved);
                       end;

                  end;
                  readln(InFile);
                  SiteArr.setValue(iSiteIndex,@ASite);
             end;
   end;

begin
     Result := True;

     ControlForm.currFile.Visible := True;
     ControlForm.currFile.Caption := 'Current File: ' + ExtractFileName(sFileName);

     assign(InFile,sFileName);
     reset(InFile);
     with ControlForm do
     begin
          readln(InFile,sTmp); {load target percentage}
          {TargetPercent.Text := Copy(sTmp,Length(EMS_PERCENT)+1,
                                     Length(sTmp)-Length(EMS_PERCENT));}

          readln(InFile,sTmp);{read in the date stamp}

          GetBox(EMSReason); {load description of this file}
          GetBox(Available); {load site lists}
          GetBox(R1);
          GetBox(R2);
          GetBox(R3);
          GetBox(R4);
          GetBox(R5);
          GetBox(Excluded);
          GetBox(Reserved);
          GetBox(Ignored);
          GetBox(Partial);
          GetBox(Flagged);
          GetBox(AvailableKey);
          GetBox(R1Key);
          GetBox(R2Key);
          GetBox(R3Key);
          GetBox(R4Key);
          GetBox(R5Key);
          GetBox(ExcludedKey);
          GetBox(ReservedKey);
          GetBox(IgnoredKey);
          GetBox(PartialKey);
          GetBox(FlaggedKey);
          GetBox(ChoiceForm.ChoiceLog);
          GetPartial; {load partial deferral details}


          ApplyHide;  {sees if
           site lists empty, de/activates controls}
          FitComponents2Form;
     end;
     close(InFile);
end;

function LoadSelectionsOldVersion(const sFileName : string) : boolean;
var
   InFile : text;
   sTmp : string;
   fReserved : boolean;

   procedure GetBox(var Box : TListBox);
   begin
          Box.Clear;
          repeat
                readln(InFile,sTmp);
                Box.Items.Add(sTmp);
          until EOF(InFile) or IsSeperator(sTmp);
          Box.Items.Delete(Box.Items.Count - 1);
   end;

   procedure GetPartial;
   var
      iCount, iSiteIndex, iFCount : integer;
      ASite : site;
      cRead : char;
   begin
        with ControlForm.PartialKey do
        if (Items.Count > 0) then
             for iCount := 0 to (Items.Count-1) do
             begin
                  iSiteIndex := FindFeatMatch(OrdSiteArr,StrToInt(Items.Strings[iCount]));
                  SiteArr.rtnValue(iSiteIndex,@ASite);
                  if (ASite.richness > 0) then
                  begin
                       for iFCount := 1 to ASite.richness do
                       begin
                            read(InFile,cRead);

                            if (cRead = '1') then
                               fReserved := True
                            else
                                fReserved := False;
                            SparsePartial.setValue(ASite.iOffset + iFCount,@fReserved);
                       end;

                  end;
                  readln(InFile);
                  SiteArr.setValue(iSiteIndex,@ASite);
             end;
   end;

begin
     Result := True;

     ControlForm.currFile.Visible := True;
     ControlForm.currFile.Caption := 'Current File: ' + ExtractFileName(sFileName);

     assign(InFile,sFileName);
     reset(InFile);
     with ControlForm do
     begin
          readln(InFile,sTmp); {load target percentage}
          {TargetPercent.Text := Copy(sTmp,Length(EMS_PERCENT)+1,
                                     Length(sTmp)-Length(EMS_PERCENT));}

          readln(InFile,sTmp);{read in the date stamp}

          GetBox(EMSReason); {load description of this file}
          GetBox(Available); {load site lists}
          GetBox(R1);
          GetBox(R2);
          GetBox(Excluded);
          GetBox(Reserved);
          GetBox(Ignored);
          GetBox(Partial);
          GetBox(Flagged);
          GetBox(AvailableKey);
          GetBox(R1Key);
          GetBox(R2Key);
          GetBox(ExcludedKey);
          GetBox(ReservedKey);
          GetBox(IgnoredKey);
          GetBox(PartialKey);
          GetBox(FlaggedKey);
          GetBox(ChoiceForm.ChoiceLog);
          GetPartial; {load partial deferral details}


          ApplyHide;  {sees if
           site lists empty, de/activates controls}
          FitComponents2Form;
     end;
     close(InFile);
end;

function AddSelections(const sFileName : string;
                       const fOldStyleLogFile : boolean) : boolean;
{this function adds any selected sites that are not currently selected}
var
   InFile : text;
   sTmp : string;
   SitesInClass : Array_t;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;

   procedure GetBox(var Box : TListBox);
   begin
          Box.Clear;
          repeat
                readln(InFile,sTmp);
                Box.Items.Add(sTmp);
          until EOF(InFile) or IsSeperator(sTmp);
          Box.Items.Delete(Box.Items.Count - 1);
   end;

   procedure GetNextSelectionBox(SiteName,SiteKey:TListBox);
   begin
        GetBox(ControlForm.RptFieldBox);
        if (ControlForm.RptFieldBox.Items.Count > 0) then
        begin
             ListBox2IntArr(ControlForm.RptFieldBox,SitesInClass);
             UnHighlight(ControlForm.Available,fKeepHighlight);
             UnHighlight(ControlForm.R1,fKeepHighlight);
             UnHighlight(ControlForm.R2,fKeepHighlight);
             UnHighlight(ControlForm.R3,fKeepHighlight);
             UnHighlight(ControlForm.R4,fKeepHighlight);
             UnHighlight(ControlForm.R5,fKeepHighlight);
             UnHighlight(ControlForm.Excluded,fKeepHighlight);
             UnHighlight(ControlForm.Partial,fKeepHighlight);
             UnHighlight(ControlForm.Flagged,fKeepHighlight);
             UnHighlight(ControlForm.Reserved,fKeepHighlight);
             UnHighlight(ControlForm.Ignored,fKeepHighlight);
             Arr2Highlight(SitesInClass,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);
             SitesInClass.Destroy;
             ControlForm.MoveGroup(ControlForm.Available,ControlForm.AvailableKey,
                                   SiteName,SiteKey,
                                   FALSE,True);
        end;
   end;

begin
     try
        Result := True;

        assign(InFile,sFileName);
        reset(InFile);
        with ControlForm do
        begin
             {ignore target percentage}
             readln(InFile,sTmp);
             {ignore date stamp}
             readln(InFile,sTmp);

             {ignore all the site names in the EMS file, we will process sites using geocode}
             GetBox(ControlForm.RptFieldBox);
             GetBox(ControlForm.RptFieldBox);
             GetBox(ControlForm.RptFieldBox);
             GetBox(ControlForm.RptFieldBox);
             GetBox(ControlForm.RptFieldBox);
             GetBox(ControlForm.RptFieldBox);
             GetBox(ControlForm.RptFieldBox);
             GetBox(ControlForm.RptFieldBox);
             GetBox(ControlForm.RptFieldBox);
             GetBox(ControlForm.RptFieldBox);

             ControlRes^.sLastChoiceType := 'Select from file ' + sFileName;

             GetNextSelectionBox(R1,R1Key);
             GetNextSelectionBox(R2,R2Key);
             if not fOldStyleLogFile then
             begin
                  GetNextSelectionBox(R3,R3Key);
                  GetNextSelectionBox(R4,R4Key);
                  GetNextSelectionBox(R5,R5Key);
             end;

             GetNextSelectionBox(Excluded,ExcludedKey);

             {ignore reserved and ignored as they will not have changed}
             GetBox(ControlForm.RptFieldBox);
             GetBox(ControlForm.RptFieldBox);
             {ignore partially deferred sites, they must be selected manually using
              information contained in the Partial Deferral report}
             GetBox(ControlForm.RptFieldBox);

             GetNextSelectionBox(Flagged,FlaggedKey);

             {ignore choice log}
             GetBox(ControlForm.RptFieldBox);

             {ignore partial deferral flags}

             ApplyHide;  {sees if
              site lists empty, de/activates controls}
             FitComponents2Form;
        end;
        close(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in AddSelections',mtError,[mbOk],0);
     end;
end;


function CheckSelections : boolean;
begin
     // True means the selections are ok
     // False means the selections are invalid
     Result := True;

     with ControlForm do
     begin
          if (Available.Items.Count <> AvailableKey.Items.Count)
          or (R1.Items.Count <> R1Key.Items.Count)
          or (R2.Items.Count <> R2Key.Items.Count)
          or (R3.Items.Count <> R3Key.Items.Count)
          or (R4.Items.Count <> R4Key.Items.Count)
          or (R5.Items.Count <> R5Key.Items.Count)
          or (Excluded.Items.Count <> ExcludedKey.Items.Count)
          or (Reserved.Items.Count <> ReservedKey.Items.Count)
          or (Ignored.Items.Count <> IgnoredKey.Items.Count)
          or (Partial.Items.Count <> PartialKey.Items.Count)
          or (Flagged.Items.Count <> FlaggedKey.Items.Count)
          or ((Available.Items.Count +
               R1.Items.Count +
               R2.Items.Count +
               R3.Items.Count +
               R4.Items.Count +
               R5.Items.Count +
               Excluded.Items.Count +
               Reserved.Items.Count +
               Ignored.Items.Count +
               Partial.Items.Count +
               Flagged.Items.Count) <> iSiteCount) then
          begin
               {$IFDEF ADD_EDEN_SITES}
               {we may need to add some sites}
               Available.Items.Add('600931');
               AvailableKey.Items.Add('600931');
               Available.Items.Add('600939');
               AvailableKey.Items.Add('600939');
               Available.Items.Add('600956');
               AvailableKey.Items.Add('600956');
               Available.Items.Add('601003');
               AvailableKey.Items.Add('601003');
               Available.Items.Add('601004');
               AvailableKey.Items.Add('601004');
               Available.Items.Add('601023');
               AvailableKey.Items.Add('601023');
               Available.Items.Add('601846');
               AvailableKey.Items.Add('601846');
               Available.Items.Add('602023');
               AvailableKey.Items.Add('602023');
               Available.Items.Add('SF Plantation');
               AvailableKey.Items.Add('905166');
               LabelCountUpdate;
               if ((Available.Items.Count +
                    Negotiated.Items.Count +
                    Mandatory.Items.Count +
                    Excluded.Items.Count +
                    Reserved.Items.Count +
                    Ignored.Items.Count +
                    Partial.Items.Count +
                    Flagged.Items.Count) <> iSiteCount) then
               {$ENDIF}
                  begin
                       MessageDlg('Invalid selection file, exiting',mtInformation,[mbOK],0);
                       // DestroyControlForm(true);
                       Result := False;
                  end;
          end
          else
              Result := CheckTenure;
     end;
end;

procedure TControlForm.Open1Click(Sender: TObject);
var
   wTmp : word;
   fCancel, fCancelPressed,
   fRetainClass : boolean;
   sRetainClass : string;
begin
     {load choice file}
     fCancel := False;

     if fSelectionChange
     or fFlagSelectionChange then
     begin
          wTmp := MessageDlg
             ('Save changes before load?',mtConfirmation,[mbYes,mbNo,mbCancel],0);
          case wTmp of
               mrYes : Save1Click(Self,fCancel,fCancelPressed);
               mrCancel : fCancel := True;
          end;
     end;

     if not fCancel then
     begin
          OpenDialog.FileName := 'sample.log';
          OpenDialog.InitialDir := ControlRes^.sWorkingDirectory;

          OpenDialog.Title := 'Open Selection File';

          if OpenDialog.Execute then
          begin
               fRetainClass := ControlRes^.fFeatureClassesApplied;
               sRetainClass := ControlRes^.sFeatureClassField;

               fSelectionChange := False;
               fFlagSelectionChange := False;
               {selections do not need to be saved}
               fContrDataDone := False;
               {data in contribution objects needs to be updated}

               LoadSelections(OpenDialog.FileName);
               if not CheckSelections then
               begin
                    //
                    LoadSelections(ControlRes^.sDatabase + '\empty.log');
                    AddSelections(OpenDialog.FileName,False);
               end;
               LabelCountUpdate;

               RePrepIrrepData;

               // if there are excluded items, recalculate combination size here
               if (Excluded.Items.Count > 0) then
                  ReInitializeInitialValues(ExclusionChange);

               if fRetainClass then
               begin
                    if (mrYes = MessageDlg('Retain Feature Subset ' +
                                           sRetainClass,
                                           mtConfirmation,
                                           [mbYes,mbNo],0)) then
                    begin
                         LoadOrdinalClass(sRetainClass,ControLRes^.ClassDetail);
                         ControlRes^.fFeatureClassesApplied := True;
                         ControlRes^.sFeatureClassField := sRetainClass;
                    end
               end;
               CalcExcludeTrimAmount;
               ExecuteIrreplaceability(-1,False,False,True,True,'');

               SaveDialog.Filename := ExtractFileName(OpenDialog.Filename);
               SaveDialog.InitialDir := ExtractFilePath(OpenDialog.Filename);
          end;
     end;
end;

function ExtractFileNameNoExt(const sFileName : string) : string;
var
   iPos : integer;
begin
     Result := ExtractFileName(sFileName);
     iPos := Pos('.',Result);
     if (iPos > 1) then
        // trim file extension from the result
        Result := Copy(Result,1,iPos-1);
end;

function SubstituteSubString(const sString, sSearch, sReplace : string) : string;
var
   iPos, iLen, iSubLen : integer;
begin
     iPos := Pos(sSearch,sString);
     if (iPos > 0) then
     begin
          iLen := Length(sString);
          iSubLen := Length(sSearch);

          if (iPos = 1) then
             // sub-string is at start of string
             Result := sReplace + Copy(sString,iPos + iSubLen,iLen-iSubLen-iPos+1)
          else
          begin
               if (iPos = (iLen - iSubLen + 1)) then
                  // sub-string is at end of string
                  Result := Copy(sString,1,iPos-1) + sReplace
               else
                   // sub-string is within the string
                   Result := Copy(sString,1,iPos-1) +
                             sReplace +
                             Copy(sString,iPos + iSubLen,iLen-iSubLen-iPos+1);
          end;
     end
     else
         Result := sString;
end;

function RemoveSubString(const sString, sSubString : string) : string;
var
   iPos, iLen, iSubLen : integer;
begin
     iPos := Pos(sSubString,sString);
     if (iPos > 0) then
     begin
          iLen := Length(sString);
          iSubLen := Length(sSubString);

          if (iPos = 1) then
             // sub-string is at start of string
             Result := Copy(sString,iPos + iSubLen,iLen-iSubLen-iPos+1)
          else
          begin
               if (iPos = (iLen - iSubLen + 1)) then
                  // sub-string is at end of string
                  Result := Copy(sString,1,iPos-1)
               else
                   // sub-string is within the string
                   Result := Copy(sString,1,iPos-1) +
                             Copy(sString,iPos + iSubLen,iLen-iSubLen-iPos+1);
          end;
     end
     else
         Result := sString;
end;

function TrimDestriptField(const sDescript, sStage : string) : string;
begin
     // remove the commonly appearing bits that are not the actual description
     // entered by the user

     Result := RemoveSubString(sDescript,'stage no stage specified');
     Result := RemoveSubString(Result,'stage no stage specified');
     Result := RemoveSubString(Result,'stage ' + sStage);
     Result := RemoveSubString(Result,'stage ' + sStage);
     Result := RemoveSubString(Result,'Highlight Group,');
     Result := RemoveSubString(Result,'Negotiated,');
     Result := RemoveSubString(Result,ControlRes^.sR1Label + ',');
     Result := RemoveSubString(Result,'Mandatory,');
     Result := RemoveSubString(Result,ControlRes^.sR2Label+',');
     Result := RemoveSubString(Result,ControlRes^.sR3Label+',');
     Result := RemoveSubString(Result,ControlRes^.sR4Label+',');
     Result := RemoveSubString(Result,ControlRes^.sR5Label+',');
     Result := RemoveSubString(Result,'Partial Deferral,');
     Result := RemoveSubString(Result,'Flagged,');
     Result := RemoveSubString(Result,'Excluded,');
     Result := RemoveSubString(Result,'De-Select,');
     // remove double spacing
     if (Pos('  ',Result) > 0) then
        repeat
              Result := RemoveSubString(Result,'  ');

        until Pos('  ',Result) = 0;
end;

function SubstituteSpaceForTab(const sInput : string) : string;
begin
     Result := sInput;

     if (Pos(Chr(9),Result) > 0) then
        repeat
              Result := SubstituteSubString(Result,Chr(9),' ');

        until Pos(Chr(9),Result) = 0;
end;

function SaveSelections(const sFileName : string;
                        const fReadOnly : boolean) : boolean;
var
   OutFile : text;
   fReserved : boolean;
   sDbfFileName, sTXTFileName, sTmp : string;

   procedure PutBox(var Box : TListBox;
                    const sLabel : string);
   var
      iCount : integer;
   begin
          for iCount := 0 to (Box.Items.Count - 1) do
              writeln(OutFile,Box.Items.Strings[iCount]);

          writeln(OutFile,EMS_SEPARATOR + ' ' + sLabel + ' End');
   end;

   procedure PutPartial;
   var
      iCount, iSiteIndex, iFCount : integer;
      ASite : site;
      cToWrite : char;
   begin
        with ControlForm.PartialKey do
        if (Items.Count > 0) then
             for iCount := 0 to (Items.Count-1) do
             begin
                  iSiteIndex := FindFeatMatch(OrdSiteArr,StrToInt(Items.Strings[iCount]));
                  SiteArr.rtnValue(iSiteIndex,@ASite);
                  if (ASite.richness > 0) then
                  begin
                       for iFCount := 1 to ASite.richness do
                       begin
                            SparsePartial.rtnValue(ASite.iOffset + iFCount,@fReserved);
                            if fReserved then
                               cToWrite := '1'
                            else
                                cToWrite := '0';

                           write(OutFile,cToWrite);
                       end;

                       writeln(OutFile);
                  end;
             end;

        writeln(OutFile,EMS_SEPARATOR + ' PartialFlags End');
   end;

   procedure CreateSelectionDBF;
   begin
        try
           sDbfFileName := ExtractFilePath(sFilename) + ExtractFileNameNoExt(sFilename) + '.dbf';
           if fileexists(sDbfFileName) then
              DeleteFile(PChar(sDbfFileName));

           with ControlForm.AddFieldsQuery.SQL do
           begin
                Clear;
                Add('CREATE TABLE "' + sDbfFileName + '"');
                Add('(');
                Add('INDEX_ NUMERIC(10,0),');
                Add('SEL_NUMB NUMERIC(10,0),');
                Add('SITEKEY NUMERIC(10,0),');
                Add('DATE_ CHAR(30),');
                Add('DESCRIPT CHAR(250),');
                Add('TYPE CHAR(16),');
                Add('STAGE CHAR(20),');
                Add('SUBCLASS CHAR(10),');
                Add('CURRENT_ NUMERIC(1,0)');
                Add(')');
                try
                   ControlForm.AddFieldsQuery.Prepare;
                   ControlForm.AddFieldsQuery.ExecSQL;
                except
                      SaveToFile('c:\error.sql');
                      Screen.Cursor := crDefault;
                      MessageDlg('Could not create ' + sDbfFileName + '.  File may be in use.',
                                 mtInformation,[mbOk],0);
                end;
                Clear;
           end;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Could not create ' + sDbfFileName + '.  File may be in use.',
                         mtInformation,[mbOk],0);
        end;
   end;

   procedure ExtractStage(const sLine : string;
                          var sStage : string);
   var
      iPos : integer;
   begin
        iPos := Pos('stage ',sLine);
        if (iPos = 2) then
           sStage := copy(sLine,iPos+6,Length(sLine) - iPos - 5);
        // Xstage no stage specified
        // 1234567890123456789012345
        // iPos = 2
        // length = 25
        // start = 8 (iPos + 6)
        // copylength = 18 (length - 7) ~ (length - iPos - 5)
        // actualcopylength is 10
   end;

   procedure ExtractTypeDate(const sLine : string;
                             var sType, sDate : string);
   var
      iPos : integer;
      sTmp : string;
   begin
        // sType is one of : Negotiated, Mandatory, Partial Deferral, Flagged, Excluded, De-Select

        iPos := 0;
        if (Pos('Negotiated',sLine) > 0) then
        begin
             sType := 'Negotiated';
             iPos := Pos('Negotiated',sLine) + 10;
        end;
        if (Pos(ControlRes^.sR1Label,sLine) > 0) then
        begin
             sType := ControlRes^.sR1Label;
             iPos := Pos(ControlRes^.sR1Label,sLine) + Length(ControlRes^.sR1Label);
        end;
        if (Pos('Mandatory',sLine) > 0) then
        begin
             sType := 'Mandatory';
             iPos := Pos('Mandatory',sLine) + 9;
        end;
        if (Pos(ControlRes^.sR2Label,sLine) > 0) then
        begin
             sType := ControlRes^.sR2Label;
             iPos := Pos(ControlRes^.sR2Label,sLine) + Length(ControlRes^.sR2Label);
        end;
        if (Pos(ControlRes^.sR3Label,sLine) > 0) then
        begin
             sType := ControlRes^.sR3Label;
             iPos := Pos(ControlRes^.sR3Label,sLine) + Length(ControlRes^.sR3Label);
        end;
        if (Pos(ControlRes^.sR4Label,sLine) > 0) then
        begin
             sType := ControlRes^.sR4Label;
             iPos := Pos(ControlRes^.sR4Label,sLine) + Length(ControlRes^.sR4Label);
        end;
        if (Pos(ControlRes^.sR2Label,sLine) > 0) then
        begin
             sType := ControlRes^.sR5Label;
             iPos := Pos(ControlRes^.sR5Label,sLine) + Length(ControlRes^.sR5Label);
        end;
        if (Pos('Partial Deferral',sLine) > 0) then
        begin
             sType := 'Partial Deferral';
             iPos := Pos('Partial Deferral',sLine) + 16;
        end;
        if (Pos('Flagged',sLine) > 0) then
        begin
             sType := 'Flagged';
             iPos := Pos('Flagged',sLine) + 7;
        end;
        if (Pos('Excluded',sLine) > 0) then
        begin
             sType := 'Excluded';
             iPos := Pos('Excluded',sLine) + 8;
        end;
        //De-Select
        if (Pos('De-Select',sLine) > 0) then
        begin
             sType := 'De-Select';
             iPos := Pos('De-Select',sLine) + 9;
        end;
        // sDate occurs immediately after sType, terminated by AM or PM
        if (iPos > 0) then
        begin
             // extract the date from sLine
             // abcdef
             // 123456
             sTmp := Copy(sLine,iPos+1,Length(sLine)-iPos);
             iPos := Pos('AM',sTmp);
             if (iPos = 0) then
                iPos := Pos('PM',sTmp);
             if (iPos > 0) then
                sDate := Copy(sTmp,1,iPos+1);
        end;
   end;


   procedure PopulateSelectionTXT;
   var
      iCount, iSelection, iIndex : integer;
      sDescription, sLine, sPreviousDelimiter, sType, sDate, sStage, sOutLine : string;
      TXTFile : TextFile;
   begin
        // iterate ChoiceForm.ChoiceLog, writing each site in the choice log as a row to the dbf table
        try
           sTXTFileName := ExtractFilePath(sFilename) + ExtractFileNameNoExt(sFilename) + '.txt';
           if fileexists(sTXTFileName) then
              DeleteFile(PChar(sTXTFileName));

           assignfile(TXTFile,sTXTFileName);
           rewrite(TXTFile);

           writeln(TXTFile,'Index' + Chr(9) + 'Selection Number' + Chr(9) + 'SITEKEY' + Chr(9) +
                           'DATE' + Chr(9) + 'Description' + Chr(9) + 'TYPE' + Chr(9) +
                           'STAGE' + Chr(9) + 'SUBCLASS' + Chr(9) + 'CURRENT');

           iSelection := 1;
           iIndex := 0;
           sDescription := '';
           sPreviousDelimiter := '';
           sType := '';
           sDate := '';
           sStage := '';
           // sType has possible values : Negotiated, ...
           // for each row of the choice log
           for iCount := 0 to (ChoiceForm.ChoiceLog.Items.Count-1) do
           begin
                sLine := ChoiceForm.ChoiceLog.Items.Strings[iCount];

                if (sLine[1] = 'Y')
                or (sLine[1] = 'Z') then
                begin
                     Inc(iIndex);

                     // trim DATA, from DESCRIPT
                     sDescription := RemoveSubString(sDescription,sDate + ',');
                     sDescription := RemoveSubString(sDescription,sDate);
                     // trim other extraneous bits from DESCRIPT
                     sDescription := TrimDestriptField(sDescription,sStage);

                     // construct a tab delimited line with the 9 fields
                     sOutLine := IntToStr(iIndex) + Chr(9) + IntToStr(iSelection) + Chr(9) + SubstituteSpaceForTab(Copy(sLine,2,Length(sLine)-1)) + Chr(9) +
                                 SubstituteSpaceForTab(sDate) + Chr(9) + SubstituteSpaceForTab(sDescription) + Chr(9) + SubstituteSpaceForTab(sType) + Chr(9) + SubstituteSpaceForTab(sStage) + Chr(9) + Chr(9);

                     writeln(TXTFile,sOutLine);
                end
                else
                begin
                     if (sPreviousDelimiter = 'Y')
                     or (sPreviousDelimiter = 'Z') then
                     begin
                          // initialise the description because we are moving to another 'selection'
                          sDescription := Copy(sLine,2,Length(sLine)-1);
                          Inc(iSelection);
                     end
                     else
                     begin
                          if (sDescription = '') then
                             sDescription := Copy(sLine,2,Length(sLine)-1)
                          else
                              sDescription := sDescription + {' ' +} Copy(sLine,2,Length(sLine)-1);
                     end;
                     // extract site type & selection time from sLine
                     ExtractTypeDate(sLine,sType,sDate);
                     // extract selection stage from sLine
                     ExtractStage(sLine,sStage);
                end;

                sPreviousDelimiter := sLine[1];
           end;

           closefile(TXTFile);

        except
        end;
   end;

   procedure PopulateSelectionDBF;
   var
      iCount, iSelection, iIndex : integer;
      sDescription, sLine, sPreviousDelimiter, sType, sDate, sStage : string;
   begin
        // iterate ChoiceForm.ChoiceLog, writing each site in the choice log as a row to the dbf table
        try
           ControlForm.SparseKeyTable.DatabaseName := ExtractFilePath(sDbfFileName);
           ControlForm.SparseKeyTable.TableName := ExtractFileName(sDbfFileName);
           ControlForm.SparseKeyTable.Open;

           iSelection := 1;
           iIndex := 0;
           sDescription := '';
           sPreviousDelimiter := '';
           sType := '';
           sDate := '';
           sStage := '';
           // sType has possible values : Negotiated, ...
           // for each row of the choice log
           for iCount := 0 to (ChoiceForm.ChoiceLog.Items.Count-1) do
           begin
                sLine := ChoiceForm.ChoiceLog.Items.Strings[iCount];

                if (sLine[1] = 'Y')
                or (sLine[1] = 'Z') then
                begin
                     Inc(iIndex);

                     // trim DATA, from DESCRIPT
                     sDescription := RemoveSubString(sDescription,sDate + ',');
                     sDescription := RemoveSubString(sDescription,sDate);
                     // trim other extraneous bits from DESCRIPT
                     sDescription := TrimDestriptField(sDescription,sStage);

                     ControlForm.SparseKeyTable.Append;
                     ControlForm.SparseKeyTable.FieldByName('INDEX_').AsInteger := iIndex;
                     ControlForm.SparseKeyTable.FieldByName('SEL_NUMB').AsInteger := iSelection;
                     // extract site key from sLine
                     ControlForm.SparseKeyTable.FieldByName('SITEKEY').AsString := Copy(sLine,2,Length(sLine)-1);
                     // DATE_ DESCRIPT TYPE STAGE
                     ControlForm.SparseKeyTable.FieldByName('STAGE').AsString := sStage;
                     ControlForm.SparseKeyTable.FieldByName('TYPE').AsString := sType;
                     ControlForm.SparseKeyTable.FieldByName('DESCRIPT').AsString := sDescription;
                     ControlForm.SparseKeyTable.FieldByName('DATE_').AsString := sDate;
                     ControlForm.SparseKeyTable.Post;

                end
                else
                begin
                     if (sPreviousDelimiter = 'Y')
                     or (sPreviousDelimiter = 'Z') then
                     begin
                          // initialise the description because we are moving to another 'selection'
                          sDescription := Copy(sLine,2,Length(sLine)-1);
                          Inc(iSelection);
                     end
                     else
                     begin
                          if (sDescription = '') then
                             sDescription := Copy(sLine,2,Length(sLine)-1)
                          else
                              sDescription := sDescription + {' ' +} Copy(sLine,2,Length(sLine)-1);
                     end;
                     // extract site type & selection time from sLine
                     ExtractTypeDate(sLine,sType,sDate);
                     // extract selection stage from sLine
                     ExtractStage(sLine,sStage);
                end;

                sPreviousDelimiter := sLine[1];
           end;

           ControlForm.SparseKeyTable.Close;

        except
        end;
   end;

begin
     try
        fSelectionChange := False;
        fFlagSelectionChange := False;
        Result := True;

        if FileExists(sFileName) then
        begin
             {try
                if (FileGetAttr(sFileName) = (faReadOnly + faArchive)) then
                begin
                     Result := False;
                     MessageDlg('Cannot save ' + sFileName + ', it exists and is read only',mtInformation,[mbOk],0);
                end;

             except
                   Screen.Cursor := crDefault;
                   MessageDlg('Exception in SaveSelections (FileGetAttr failed)',
                              mtError,[mbOk],0);
             end;}
        end;

        if Result then
        begin
             if (sFileName <> (ControlRes^.sWorkingDirectory + '\' + AUTOSAVE_FILE)) then
             begin
                  ControlForm.currFile.Visible := True;
                  ControlForm.currFile.Caption := 'Current File: ' + ExtractFileName(sFileName);
             end;

             try
                assign(OutFile,sFileName);
                rewrite(OutFile);
                with ControlForm do
                begin
                     if UseFeatCutOffs.Checked then
                        writeln(OutFile,'Imported Targets')
                     else
                         writeln(OutFile,EMS_PERCENT + TargetPercent.Text); {save target percent}

                     writeln(OutFile,CustDateStr); {adds date if EMSReason is empty}
                     PutBox(EMSReason,'EMSReason'); {save description of this file}

                     PutBox(Available,'Available'); {save site Name lists}
                     sTmp := ControlRes^.sR1Label;
                     if (sTmp = '') then
                        sTmp := 'R1';
                     PutBox(R1,sTmp);
                     sTmp := ControlRes^.sR2Label;
                     if (sTmp = '') then
                        sTmp := 'R2';
                     PutBox(R2,sTmp);
                     sTmp := ControlRes^.sR3Label;
                     if (sTmp = '') then
                        sTmp := 'R3';
                     PutBox(R3,sTmp);
                     sTmp := ControlRes^.sR4Label;
                     if (sTmp = '') then
                        sTmp := 'R4';
                     PutBox(R4,sTmp);
                     sTmp := ControlRes^.sR5Label;
                     if (sTmp = '') then
                        sTmp := 'R5';
                     PutBox(R5,sTmp);
                     PutBox(Excluded,'Excluded');
                     PutBox(Reserved,'Reserved');
                     PutBox(Ignored,'Ignored');
                     PutBox(Partial,'Partially Deferred');
                     PutBox(Flagged,'Flagged');
                     PutBox(AvailableKey,'AvailKey'); {save site Key lists}
                     PutBox(R1Key,'R1Key');
                     PutBox(R2Key,'R2Key');
                     PutBox(R3Key,'R3Key');
                     PutBox(R4Key,'R4Key');
                     PutBox(R5Key,'R5Key');
                     PutBox(ExcludedKey,'ExcluKey');
                     PutBox(ReservedKey,'ReserKey');
                     PutBox(IgnoredKey,'IgnorKey');
                     PutBox(PartialKey,'PartialKey');
                     PutBox(FlaggedKey,'FlaggedKey');
                     PutBox(ChoiceForm.ChoiceLog,'ChoiceLog'); {save selection log}
                     PutPartial; {store partial deferral flags}
                end;

                close(OutFile);

             except
                   Screen.Cursor := crDefault;
                   MessageDlg('Exception in SaveSelections (writing data to file)',
                              mtError,[mbOk],0);
             end;

             if ControlRes^.fGenerate_TXT_DBF_log then
             begin
                  CreateSelectionDBF;
                  PopulateSelectionDBF;
                  PopulateSelectionTXT;
             end;
             
             {try
                if fReadOnly then
                   FileSetAttr(sFileName,(faArchive + faReadOnly));
             except
                   Screen.Cursor := crDefault;
                   MessageDlg('Exception in SaveSelections (FileSetAttr failed)',
                              mtError,[mbOk],0);
             end;}
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in SaveSelections ' + sFileName,
                      mtError,[mbOk],0);
     end;
end;

procedure TControlForm.Save1Click(Sender: TObject; var fCancel, fCancelPressed : boolean);
var
   fEnd, fRdOnly : boolean;
   wDlgResult : word;

begin
     fCancelPressed := False;

     {save choice file}
     if (SaveDialog.FileName = '') then
        SaveAs1Click(self,fCancel)
     else
     begin
          fEnd := False;

          if FileExists(SaveDialog.FileName) then
          begin
               wDlgResult := MessageDlg('File ' + SaveDialog.FileName +
                                        ' Exists, Overwrite?',
                                        mtConfirmation,
                                        [mbYes,mbNo,mbCancel],0);

               if (wDlgResult = mrNo) then
               begin
                    fEnd := True;
                    SaveAs1Click(self,fCancel);
               end
               else
                   if (wDlgResult = mrCancel) then
                   begin
                        fEnd := True;
                        fCancelPressed := True;
                   end;
          end;

          if SaveDialog.Options = [ofReadOnly] then
             fRdOnly := True
          else
              fRdOnly := False;

          if not fEnd then
             SaveSelections(SaveDialog.FileName,fRdOnly);
     end;
end;

procedure TControlForm.SaveAs1Click(Sender: TObject; var fCancel : boolean);
var
   fEnd, fSaveDlg, fRdOnly : boolean;
   wDlgResult : word;

begin
     {save choice file with new filename}

     SaveDialog.FileName := 'sample.log';
     SaveDialog.InitialDir := ControlRes^.sWorkingDirectory;

     repeat
           fSaveDlg := SaveDialog.Execute;
           fEnd := True;

           if fSaveDlg
           and FileExists(SaveDialog.FileName) then
           begin
                wDlgResult := MessageDlg('File ' + SaveDialog.FileName +
                                         ' Exists, Overwrite?',
                                         mtConfirmation,
                                         [mbYes,mbNo,mbCancel],0);

                if (wDlgResult = mrNo) then
                   fEnd := False
                else
                    if (wDlgResult = mrCancel) then
                       fSaveDlg := False;
           end;

     until fEnd;

     if fSaveDlg then
     begin
          if SaveDialog.Options = [ofReadOnly] then
             fRdOnly := True
          else
              fRdOnly := False;

          SaveEditStageMemo(SaveDialog.FileName);
          SaveSelections(SaveDialog.FileName,fRdOnly);
     end;
end;

procedure TControlForm.Display1Click(Sender: TObject);
begin
     try
        OptionsForm := TOptionsForm.Create(Application);

        OptionsForm.TabSet1.TabIndex := 0;
        OptionsForm.ShowModal;

     finally
            OptionsForm.Free;
     end;
end;

procedure TControlForm.Irreplacability2Click(Sender: TObject);
begin
     try
        OptionsForm := TOptionsForm.Create(Application);

        OptionsForm.TabSet1.TabIndex := 1; {Irreplaceability options page}
        OptionsForm.ShowModal;

     finally
            OptionsForm.Free;
     end;         
end;

procedure TControlForm.Defaults1Click(Sender: TObject);
begin
     try
        OptionsForm := TOptionsForm.Create(Application);

        OptionsForm.TabSet1.TabIndex := 2;
        OptionsForm.ShowModal;

     finally
            OptionsForm.Free;
     end;
end;

procedure TControlForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
     fReallyExit := False;

     Exit1Click(sender); {uses and modifys fReallyExit}

     if not fReallyExit then
        Action := caNone;
end;

procedure TControlForm.MapItemChange(Sender: TObject);
begin
     DdeSelectionDataChange;
end;

procedure TControlForm.checkShowLookupClick(Sender: TObject);
begin
     DDEShowLookup(checkShowLookup.Checked);
end;

procedure TControlForm.Contribution1Click(Sender: TObject);
begin
     {build a contribution graph for current mandatory
      and selected sites}

     if ((R1Key.Items.Count +
          R2Key.Items.Count +
          R3Key.Items.Count +
          R4Key.Items.Count +
          R5Key.Items.Count +
          Partial.Items.Count) > 0) then
     begin
          Screen.Cursor := crHourglass;
          if not fContrDataDone then
             ExecuteIrreplaceability(-1,False,False,True,True,'');

          StartContributionGraph;

          Screen.Cursor := crDefault;
     end
     else
     begin
          Screen.Cursor := crDefault;
          MessageDlg('You must select Deferred sites to activate this function' +
                     Chr(13) + Chr(10) +
                     '(' + ControlRes^.sR1Label + ', ' + ControlRes^.sR2Label + ', ' + ControlRes^.sR3Label + ', ' + ControlRes^.sR4Label + ', ' + ControlRes^.sR5Label + ' or Partially Deferred)',
                     mtInformation,[mbOk],0);
     end;
end;

procedure TControlForm.FormResize(Sender: TObject);
begin
     FitComponents2Form;
end;

procedure TControlForm.LookupSites1Click(Sender: TObject);
var
   LookupSites : Array_t;
begin
     Screen.Cursor := crHourglass;

     if Highlight2Arr(LookupSites) then
        StartLookupArr(LookupSites)
     else
     begin
          Screen.Cursor := crDefault;
          MessageDlg('You must highlight sites to activate this function',
                     mtInformation,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
end;


procedure TControlForm.SystemItemChange(Sender: TObject);
var
   sTmp : string;
   iTmp : integer;
begin
     sTmp := SystemItem.Text;
     iTmp := SystemItem.Lines.Count;
end;

procedure TControlForm.Reasoning1Click(Sender: TObject);
begin
     if (ChoiceForm.ChoiceLog.Items.Count > 0) then
     begin
          iCurrChoice := 1;
          iPrevChoice := -1;
          ChoiceForm.ReloadStageList;
          ChoiceForm.ShowModal;
     end
     else
         MessageDlg('No Selections have been recorded',
                    mtInformation,[mbOk],0);
end;

procedure TControlForm.SaveNoParam(Sender: TObject);
var
   fCancel, fCancelPressed : boolean;
begin
     Save1Click(Self,fCancel,fCancelPressed);
end;

procedure TControlForm.SaveAsNoClick(Sender: TObject);
var
   fCancel : boolean;
begin
     SaveAs1Click(self,fCancel);
end;

procedure TControlForm.WERMSDisconnect;
begin
     ControlForm.WinERMSDisconnect(self);
end;

procedure LoadDBMSDisplayFields;
{must be called after ControlForm created and DBMS names set}
var
   iCount,iCount2 : integer;
   sToMatch : string;
   fMatch : boolean;
begin
     try
        ControlForm.OutTable.Open;

        //ControlRes^.fUseNewDBLABELS := False;
        //for iCount2 := 0 to (ControlForm.OutTable.FieldDefs.Count-1) do
        //    if (NEW_IRREPL_DBLABEL = ControlForm.OutTable.FieldDefs.Items[iCount2].Name) then
        ControlRes^.fUseNewDBLABELS := True;

        iCount := 0;
        while (iCount < ControlForm.LookupDisplayList.Items.Count) do
        begin
             sToMatch := ControlForm.LookupDisplayList.Items.Strings[iCount];
             fMatch := False;
             for iCount2 := 0 to (ControlForm.OutTable.FieldDefs.Count-1) do
                 if (sToMatch = ControlForm.OutTable.FieldDefs.Items[iCount2].Name) then
                    fMatch := True;

             if fMatch then
                Inc(iCount)
             else
                 ControlForm.LookupDisplayList.Items.Delete(iCount);
        end;
        {match all fields in LookupDisplayList to the DB file,
         deleting any that don't match}

     finally
            ControlForm.OutTable.Close;
     end;
end;

procedure TControlForm.DBMSFields1Click(Sender: TObject);
begin
     {get user selections for Display fields}
     ChooseFields({LookupAvailableList,}LookupDisplayList,
                  'Choose Lookup Display Fields',
                  'Available','Displayed');

     LookupForm.DBMSFieldChange;
end;

procedure TControlForm.ExcGroupClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        ControlRes^.sLastChoiceType := 'Highlight Group';

        MoveGroup(Available,AvailableKey,Excluded,ExcludedKey,TRUE,True);

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.UnExcGroupClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        ControlRes^.sLastChoiceType := 'Highlight Group';

        MoveGroup(Excluded,ExcludedKey,Available,AvailableKey,TRUE,True);

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.UnExcAllClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        ControlRes^.sLastChoiceType := 'Highlight Group';

        MoveAll(Excluded,ExcludedKey,Available,AvailableKey,True);

     finally
            Screen.Cursor := crDefault;
     end;
end;


procedure TControlForm.ClickGroupClick(Sender: TObject);
begin
     SetControlCaption;
     LookupForm.ChangeCycleToggle;
end;

procedure CycleClickGroup;
begin
     with ControlForm do
     begin
          if (ClickGroup.ItemIndex = (ClickGroup.Items.Count-1)) then
             ClickGroup.ItemIndex := 0
          else
              ClickGroup.ItemIndex := ClickGroup.ItemIndex + 1;

          if LookupForm.Visible then
             LookupForm.LocalClick.ItemIndex := ClickGroup.ItemIndex;
     end;

     LookupForm.ChangeCycleToggle;
end;

procedure TControlForm.ClickGroupEnter(Sender: TObject);
begin
     CycleClickGroup;
end;

procedure TControlForm.btnCycleClick(Sender: TObject);
begin
     CycleClickGroup;

     fIniChange := True;
end;

procedure ReInitWeightedSumirr;
var
   WS : WeightedSumirr_T;
   iCount : integer;
begin
     try
        {initialise WS}
        {WS is one record of WeightedSumirr}
        WS.r_a := 0;
        WS.r_t := 0;
        WS.r_v := 0;
        WS.r_at := 0;
        WS.r_av := 0;
        WS.r_tv := 0;
        WS.r_atv := 0;
        for iCount := 1 to 10 do
        begin
             WS.r_sub_a[iCount] := 0;
             WS.r_sub_t[iCount] := 0;
             WS.r_sub_v[iCount] := 0;
             WS.r_sub_at[iCount] := 0;
             WS.r_sub_av[iCount] := 0;
             WS.r_sub_tv[iCount] := 0;
             WS.r_sub_atv[iCount] := 0;
        end;

        {write WS to WeightedSumirr}
        for iCount := 1 to iSiteCount do
            WeightedSumirr.setValue(iCount,@WS);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReInitWeightedSumirr',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure InitWeightedSumirr;
var
   WS : WeightedSumirr_T;
   iCount : integer;
begin
     try
        {initialises Weighted Sumirr variable}
        WeightedSumirr := Array_t.Create;
        WeightedSumirr.init(SizeOf(WS),iSiteCount);

        ReInitWeightedSumirr;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in InitWeightedSumirr',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TryOpenSPATTOOL;
begin
     try
        SpatIOModule := TSpatIOModule.Create(Application);

        if (SpatIOModule.ConnectToSPATTOOL) then
        begin
             // connected successfully to SPATTOOL
             ControlRes^.fConnectedToSPATTOOL := TRUE;

        end
        else
        begin
             // could not connect to SPATTOOL
             ControlRes^.fConnectedToSPATTOOL := FALSE;
             SpatIOModule.Free;
             //MessageDlg('The Spatial Configuration Tool (SPATTOOL) could not be invoked',
             //           mtWarning,[mbOk],0);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TryOpenSPATTOOL',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure InitSiteRichness;
var
   iCount, iSiteRichness : integer;
   pSite : sitepointer;
   rVegArea : extended;
begin
     try
        new(pSite);

        SiteRichness := Array_t.Create;
        SiteRichness.init(SizeOf(integer),iSiteCount);

        VegArea := Array_t.Create;
        VegArea.init(SizeOf(extended),iSiteCount);
        rVegArea := 0;

        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);
             iSiteRichness := pSite^.richness;
             SiteRichness.setValue(iCount,@iSiteRichness);

             VegArea.setValue(iCount,@rVegArea);
        end;

        dispose(pSite);

        // load VegArea from the site summary table if it exists there
        ControlForm.LoadVegArea;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in InitSiteRichness',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;



procedure TControlForm.SparseInitArrays;
var
   iCount : integer;
   pFeat : featureoccurrencepointer;
begin
     try
        OutTable.Open;
        iSiteCount := OutTable.RecordCount;
        OutTable.Close;
        CutOffTable.Open;
        iFeatureCount := CutOffTable.RecordCount;
        CutOffTable.Close;

        SiteArr := Array_T.Create;
        SiteArr.init(SizeOf(site),iSiteCount);
        FeatArr := Array_T.Create;
        FeatArr.init(SizeOf(featureoccurrence),iFeatureCount);
        SiteCodes := Array_T.Create;
        SiteCodes.init(SizeOf(integer),iSiteCount);
        FeatCodes := Array_T.Create;
        FeatCodes.init(SizeOf(integer),iFeatureCount);

        new(pFeat);
        // initialise the values for the feature
        with pFeat^ do
        begin
             rSRADIUS := 0;
             rPATCHCON := 0;
             rVulnerability := 0;
             rFloatVulnerability := 0;
             iOrdinalClass := 0;
             code := 0;
             rTrimmedArea := 0;
             rExtantArea := 0;
             rR1 := 0;
             rR2 := 0;
             rR3 := 0;
             rR4 := 0;
             rR5 := 0;
             rPartial := 0;
             rCurrentEffTarg := 0;
             rCutOff := 0;
             rSumArea := 0;
             rAreaSqr := 0;
             rCurrentSumArea := 0;
             rCurrentAreaSqr := 0;
             rExcluded := 0;
             rTrimmedTarget := 0;
             rInitialTrimmedTarget := 0;
             rInitialAvailable := 0;
             rInitialAvailableTarget := 0;
             rDeferredArea := 0;
             totalarea := 0;
             targetarea := 0;
             reservedarea := 0;
             fRestrict := False;
             repd := False;
             sID := '';
        end;
        // set the feature key which is the same as the feature index and store the initialised values
        for iCount := 1 to iFeatureCount do
        begin
             pFeat^.code := iCount; // set the feature key which is the same as the feature index
             FeatArr.setValue(iCount,pFeat);
             FeatCodes.setValue(iCount,@iCount);
        end;
        dispose(pFeat);

        // create the feature lookup array
        OrdFeatArr := Array_T.Create;
        OrdFeatArr := SortIntegerArray(FeatCodes);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in SparseInitArrays',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TControlForm.SparsePostInitArrays;
begin
     try
        // site and feature keys have been loaded,
        // create the simon data variable for combination size

        AverageSite := Array_T.Create;
        AverageSite.init(SizeOf(extended),iFeatureCount);
        AverageInitialSite := Array_T.Create;
        AverageInitialSite.init(SizeOf(extended),iFeatureCount);
        fAverageSiteCreated := True;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in SparsePostInitArrays',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure InitReportTarget;
var
   iCount : integer;
   rTarget : extended;
begin
     try
        ReportTarget := Array_t.Create;
        ReportTarget.init(SizeOf(extended),iFeatureCount);
        rTarget := 0;
        for iCount := 1 to iFeatureCount do
            ReportTarget.setValue(iCount,@rTarget);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in InitReportTarget',mtError,[mbOk],0);
     end;
end;

procedure LoadSiteCost;
var
   iCount, iSiteIndex : integer;
   rSiteCost : extended;
begin
     try
        SiteCost := Array_t.Create;
        SiteCost.init(SizeOf(extended),iSiteCount);

        rSiteCost := 0;
        for iCount := 1 to iSiteCount do
            SiteCost.setValue(iCount,@rSiteCost);

        ControlForm.OutTable.Open;

        while not ControlForm.OutTable.EOF do
        begin
             rSiteCost := ControlForm.OutTable.FieldByName(ControlRes^.sSiteCostFieldName).AsFloat;

             iSiteIndex := FindFeatMatch(OrdSiteArr,ControlForm.OutTable.FieldByName(ControlRes^.sKeyField).AsInteger);

             SiteCost.setValue(iSiteIndex,@rSiteCost);

             ControlForm.OutTable.Next;
        end;

        ControlForm.OutTable.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadSiteCost',mtError,[mbOk],0);
     end;
end;

procedure DumpSiteCost;
var
   iCount : integer;
   rSiteCost : extended;
   DebugFile : TextFile;
begin
     try
        assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\DumpSiteCost.csv');
        rewrite(DebugFile);
        writeln(DebugFile,'SiteIndex,SiteCost');
        for iCount := 1 to iSiteCount do
        begin
             SiteCost.rtnValue(iCount,@rSiteCost);
             writeln(DebugFile,IntToStr(iCount) + ',' + FloatToStr(rSiteCost));
        end;
        closefile(DebugFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DumpSiteCost',mtError,[mbOk],0);
     end;
end;

procedure LoadSiteVuln;
var
   iCount, iSiteIndex : integer;
   rSiteVuln : extended;
begin
     try
        SiteVuln := Array_t.Create;
        SiteVuln.init(SizeOf(extended),iSiteCount);

        rSiteVuln := 0;
        for iCount := 1 to iSiteCount do
            SiteCost.setValue(iCount,@rSiteVuln);

        ControlForm.OutTable.Open;

        while not ControlForm.OutTable.EOF do
        begin
             rSiteVuln := ControlForm.OutTable.FieldByName(ControlRes^.sSiteVulnFieldName).AsFloat;

             iSiteIndex := FindFeatMatch(OrdSiteArr,ControlForm.OutTable.FieldByName(ControlRes^.sKeyField).AsInteger);

             SiteVuln.setValue(iSiteIndex,@rSiteVuln);

             ControlForm.OutTable.Next;
        end;

        ControlForm.OutTable.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadSiteVuln',mtError,[mbOk],0);
     end;
end;

procedure DumpSiteVuln;
var
   iCount : integer;
   rSiteVuln : extended;
   DebugFile : TextFile;
begin
     try
        assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\DumpSiteVuln.csv');
        rewrite(DebugFile);
        writeln(DebugFile,'SiteIndex,SiteVuln');
        for iCount := 1 to iSiteCount do
        begin
             SiteVuln.rtnValue(iCount,@rSiteVuln);
             writeln(DebugFile,IntToStr(iCount) + ',' + FloatToStr(rSiteVuln));
        end;
        closefile(DebugFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DumpSiteVuln',mtError,[mbOk],0);
     end;
end;

procedure InitPrep01;
var
   wOldCursor : integer;
   sExt : string;
   lSCount, lFCount : longint;
   iMatrixVersion, iAv, iRe, iIg, iCount : integer;
   fMapped : boolean;
begin
     //RunAnApp('dir','> c:\dir.txt');

     with ControlForm do
     begin
          Refresh;

          wOldCursor := Screen.Cursor;
          Screen.Cursor := crHourglass;

          fFirstStart := False;

          StartChoices;
          {get the choice object up and running}
          //ExcludedSiteArea.init;
          {start the Excluded Site Area recorder object}
          if fShowHints then
             HintsOn
          else
              HintsOff;
          TargetPercent.Text := FloatToStr(rPercentage);
          ProgressGauge.Visible := False;
          SaveDialog.FileName := '';
          sExt := ExtractFileExt(InTable.TableName);
          TargetPercent.Enabled := not UseFeatCutOffs.Checked;

          SparseInitArrays;
          //SparsePostInitArrays;
          Convert2Sparse(iSiteCount,iFeatureCount);
          LoadSparseMatrix(ControlRes^.sDatabase + '\' + ControlRes^.sSparseKey,
                           ControlRes^.sDatabase + '\' + ControlRes^.sSparseMatrix,
                           True);
          // create site lookup array after loading site keys
          OrdSiteArr := Array_T.Create;
          OrdSiteArr := SortIntegerArray(SiteCodes);

          SparseMatrixStart;
          //LoadSiteNames;
          InitReportTarget;
          LoadFeatureInformation;
          if (ControlRes^.sFeatureTargetField <> 'ITARGET')
          and ControlForm.UseFeatCutOffs.Checked then
          begin
               // read the feature traget if necessary
               ReadFeatureTarget(ControlRes^.sFeatureTargetField);
               //UseFeatCutOffs.Caption := 'Use ' + ControlRes^.sFeatureTargetField;
          end;
          SparseTargetsStart;
          //SparseCombsizePrep;

          ControlRes^.fLinkToWinERMS := False;
          //MessageDlg('After InitialPrepIrrepData',mtInformation,[mbOk],0);

          // clean the site database of any accumulated fields before we start using it
          //CleanDatabase;

          InitConfigSubsets;
          LoadConfigSubsets;
          if (ControlRes^.fConnectSPATTOOL) then
             TryOpenSPATTOOL;

          fSelectionChange := False; {no user selections made}
          fFlagSelectionChange := False; {no flagged user selections made}

          CheckSelEmpty; {sees if selected/mandatory site lists empty, de/activates controls}
          CheckManEmpty;

          DDEToggleLookup;

          {initialise Weighted Summed Irr variables if they are in use}
          if ControlRes^.fCalculateAllVariations then
             InitWeightedSumirr;

          InitSiteRichness;

          //InitialValues := Array_t.create;
          //InitialValues.init(SizeOf(InitialValues_t),iSiteCount);

          iPCUSEDCutOff := LoadPCUSEDCutOff;

          InitSparsePartialStructure;

          //if ControlRes^.fCalculateBobsExtraVariations then
          //   InitMinsetSumirrWeightings;

          InitMinsetSumirrWeightings;
          ReInitializeInitialValues(Startup);

          if (ControlRes^.GISLink = ArcView) then
          begin
               DDE_TryOpenArcView;

               if (ControlRes^.GISLink <> ArcView) then
                  fIniChange := True;
          end;

          if (ControlRes^.GISLink = ZonaeCogito) then
          begin
               DDE_TryOpenZonaeCogito;

               if (ControlRes^.GISLink <> ZonaeCogito) then
                  fIniChange := True;
          end;

          InitGISSiteValues;
          MapMemoryVariable2Display(ControlRes^.iGISPlotField,
                                    0,
                                    ControlRes^.iDisplayValuesFor, {option for display Available/Deferred}
                                    5, {divide middle values into 5 categories}
                                    SiteArr, iSiteCount,
                                    iIr1Count, i001Count, i002Count,
                                    i003Count, i004Count, i005Count,
                                    i0CoCount);
          ControlForm.UpdateDatabase(True);

          if (ControlRes^.GISLink = ArcView) then
          begin
               if (ControlRes^.GISLink = ArcView)
               and ControlRes^.fInitialiseGIS then
                   ControlForm.InformGIS;
          end;

          MappedSites := Array_t.Create;
          MappedSites.init(SizeOf(boolean),iSiteCount);
          fMapped := False;
          for iCount := 1 to iSiteCount do
              MappedSites.setValue(iCount,@fMapped);

          if ControlRes^.fLoadSiteVuln then
          begin
               LoadSiteVuln;
               if fHedleySimulatorDebug then
                  DumpSiteVuln;
          end;

          if ControlRes^.fLoadSiteCost then
          begin
               LoadSiteCost;
               if fHedleySimulatorDebug then
                  DumpSiteCost;
          end;

          // save the empty.log file
          SaveSelections(ControlRes^.sDatabase + '\empty.log',false);

          AutoLoadLog;
          LabelCountUpdate;

          // display warnings to user if any
          if (Warnings.Items.Count > 0) then
             if (mrYes = MessageDlg('There are warnings.  Display them?',mtInformation,[mbYes,mbNo],0)) then
                _DisplayWarnings;

          Screen.Cursor := wOldCursor;
     end;
end;

function boolean2shortstr(const fBool : boolean) : string;
begin
     if fBool then
        Result := '1'
     else
         Result := '0';
end;

procedure TControlForm.FindReplacementSitesAllAv(const sFilename, sFilename2 : string;
                                                 const fOutFile, fOutFile2 : boolean);
var
   NumberOfReplacementSites, ReplacementSiteIndex,
   ReplacementSites, FeaturesAtSingleSite, FeaturesAtReplacementSite,
   TargetFallBelow, IrreplaceableFeature, FeaturesNotSatisfied : Array_t;
   rContributingArea, rTarget, rValue, rValue2 : extended;
   iNumber, iAvSiteCount,
   iTargetFallBelow, iIrreplaceableFeatures, iFeaturesNotSatisfied,
   iSiteKey, iReplaceSiteKey, iReplacementSites, iCount, iCount2,
   iFCount, i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
   ASite, AReplacementSite : site;
   Value : ValueFile_T;
   fReplacementSite,
   fAdd : boolean;
   sFeatures,
   sTmp,
   sKey : string;
   AFeat : featureoccurrence;
   fAllFeaturesAtSiteSatisfied, fTargetFallBelow, fIrreplaceableSite, fIrreplaceableFeature,
   fContinue, fFeatureNotSatisfied : boolean;
   OutFile, OutFile2 : TextFile;
   sOutFile2 : string;
begin
     // find replacement sites for each available or flagged site in turn

     try
        NumberOfReplacementSites := Array_t.Create;
        NumberOfReplacementSites.init(SizeOf(integer),iSiteCount);
        iNumber := 0;
        for iCount := 1 to iSiteCount do
            NumberOfReplacementSites.setValue(iCount,@iNumber);

        iReplacementSites := 0;
        ReplacementSites := Array_t.Create;
        ReplacementSites.init(SizeOf(integer),iSiteCount);

        // init features at sites
        FeaturesAtSingleSite := Array_t.Create;
        FeaturesAtSingleSite.init(SizeOf(extended),iFeatureCount);
        FeaturesAtReplacementSite := Array_t.Create;
        FeaturesAtReplacementSite.init(SizeOf(extended),iFeatureCount);
        TargetFallBelow := Array_t.Create;
        TargetFallBelow.init(SizeOf(boolean),iFeatureCount);
        fTargetFallBelow := False;
        iTargetFallBelow := 0;
        fIrreplaceableSite := False;
        IrreplaceableFeature := Array_t.Create;
        IrreplaceableFeature.init(SizeOf(boolean),iFeatureCount);
        fIrreplaceableFeature := False;
        iIrreplaceableFeatures := 0;
        FeaturesNotSatisfied := Array_t.Create;
        FeaturesNotSatisfied.init(SizeOf(boolean),iFeatureCount);
        fFeatureNotSatisfied := False;
        iFeaturesNotSatisfied := 0;
        rValue := 0;
        for iCount := 1 to iFeatureCount do
        begin
             FeaturesAtSingleSite.setValue(iCount,@rValue);
             FeaturesAtReplacementSite.setValue(iCount,@rValue);
             TargetFallBelow.setValue(iCount,@fTargetFallBelow);
             IrreplaceableFeature.setValue(iCount,@fIrreplaceableFeature);
             FeaturesNotSatisfied.setValue(iCount,@fFeatureNotSatisfied);
        end;
        //
        ReplacementSiteIndex := Array_t.Create;
        ReplacementSiteIndex.init(SizeOf(boolean),iSiteCount);

        if fOutFile2 then
        begin
             assignfile(OutFile2,sFilename2);
             rewrite(OutFile2);
             sOutFile2 := 'SiteKey';
             for iCount := 1 to iSiteCount do
             begin
                  SiteArr.rtnValue(iCount,@ASite);
                  if (ASite.status = Av)
                  or (ASite.status = Fl) then
                     sOutFile2 := sOutFile2 + ',' + IntToStr(ASite.iKey);
             end;
             write(OutFile2,sOutFile2);
        end;

        for iAvSiteCount := 1 to iSiteCount do
        begin
             fAllFeaturesAtSiteSatisfied := True;
             SiteArr.rtnValue(iAvSiteCount,@ASite);
             iReplaceSiteKey := ASite.iKey;
             fContinue := ((ASite.status = Av) or (ASite.status = Fl));

             if fContinue then
             begin
                  fReplacementSite := False;
                  for iCount := 1 to iSiteCount do
                      ReplacementSiteIndex.setValue(iCount,@fReplacementSite);

                  iReplacementSites := 0;
                  // set FeaturesAtSingleSite
                  rValue := 0;
                  for iCount2 := 1 to iFeatureCount do
                      FeaturesAtSingleSite.setValue(iCount2,@rValue);
                  if (ASite.richness > 0) then
                     for iCount2 := 1 to ASite.richness do
                     begin
                          FeatureAmount.rtnValue(ASite.iOffset + iCount2,@Value);
                          FeatArr.rtnValue(Value.iFeatKey,@AFeat);
                          if ((ASite.status = Av) or (ASite.status = Fl)) then
                             rTarget := AFeat.targetarea
                          else
                              rTarget := AFeat.targetarea + Value.rAmount;
                          if (rTarget > 0) then
                             rContributingArea := rTarget
                          else
                              rContributingArea := 0;
                          if (rContributingArea > 0)
                          and (Value.rAmount < rContributingArea) then
                              rContributingArea := Value.rAmount;
                          FeaturesAtSingleSite.setValue(Value.iFeatKey,@rContributingArea);
                     end;

                  // parse sites looking for replacement sites, comparing each of the available sites
                  for iCount := 1 to AvailableKey.Items.Count do
                  begin
                       sKey := AvailableKey.Items.Strings[iCount-1];
                       iSiteKey := StrToInt(sKey);
                       iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
                       SiteArr.rtnValue(iSiteIndex,@AReplacementSite);
                       if (AReplacementSite.iKey <> iReplaceSiteKey)
                       and ((AReplacementSite.status = Av) or (AReplacementSite.status = Fl)) then
                       begin
                            // set FeaturesAtReplacementSite
                            rValue := 0;
                            for iCount2 := 1 to iFeatureCount do
                                FeaturesAtReplacementSite.setValue(iCount2,@rValue);
                            if (AReplacementSite.richness > 0) then
                               for iCount2 := 1 to AReplacementSite.richness do
                               begin
                                    FeatureAmount.rtnValue(AReplacementSite.iOffset + iCount2,@Value);
                                    rValue := Value.rAmount;
                                    FeaturesAtReplacementSite.setValue(Value.iFeatKey,@rValue);
                               end;

                            // test if as good as single site, add to list if true
                            fAdd := True;
                            for iFCount := 1 to iFeatureCount do
                            begin
                                 FeaturesAtSingleSite.rtnValue(iFCount,@rValue);
                                 FeaturesAtReplacementSite.rtnValue(iFCount,@rValue2);
                                 if (rValue > rValue2) then
                                    fAdd := False;
                            end;
                            if fAdd then
                            begin
                                 Inc(iReplacementSites);
                                 ReplacementSites.setValue(iReplacementSites,@iSiteKey);
                                 iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
                                 fReplacementSite := True;
                                 ReplacementSiteIndex.setValue(iSiteIndex,@fReplacementSite);
                            end;
                       end;
                  end;

                  if (iReplacementSites > 0) then
                     NumberOfReplacementSites.setValue(iAvSiteCount,@iReplacementSites);
                  // write the replacement site key row out to the file
                  if fOutFile2 then
                  begin
                       sOutFile2 := IntToStr(iReplaceSiteKey);
                       for iCount := 1 to iSiteCount do
                       begin
                            ReplacementSiteIndex.rtnValue(iCount,@fReplacementSite);
                            SiteArr.rtnValue(iCount,@ASite);
                            if (ASite.status = Av)
                            or (ASite.status = Fl) then
                               sOutFile2 := sOutFile2 + ',' + boolean2shortstr(fReplacementSite);
                       end;
                       writeln(OutFile2,sOutFile2);
                  end;
             end;
        end;
        if fOutFile2 then
           closefile(OutFile2);

        // write NumberOfReplacementSites to a file
        if fOutFile then
        begin
             assignfile(OutFile,sFilename);
             rewrite(OutFile);
             writeln(OutFile,'SiteKey,status,display,irreplaceability,replacements');
             for iCount := 1 to iSiteCount do
             begin
                  SiteArr.rtnValue(iCount,@ASite);
                  if (ASite.status = Av)
                  or (ASite.status = Fl) then
                  begin
                       NumberOfReplacementSites.rtnValue(iCount,@iReplacementSites);
                       writeln(OutFile,IntToStr(ASite.iKey) + ',' +
                                       status2str(ASite.status) + ',' +
                                       ASite.sDisplay + ',' +
                                       FloatToStr(ASite.rIrreplaceability) + ',' +
                                       IntToStr(iReplacementSites));
                  end;
             end;
             closefile(OutFile);
        end;

        ReplacementSites.Destroy;
        FeaturesAtSingleSite.Destroy;
        FeaturesAtReplacementSite.Destroy;
        TargetFallBelow.Destroy;
        IrreplaceableFeature.Destroy;
        FeaturesNotSatisfied.Destroy;
        NumberOfReplacementSites.Destroy;
        ReplacementSiteIndex.Destroy;

     except
           MessageDlg('Exception in FindReplacementSitesAllAv',mtInformation,[mbOk],0);
     end;
end;

procedure TControlForm.FindReplacementSites;
var
   SingleSite, ReplacementSites, FeaturesAtSingleSite, FeaturesAtReplacementSite,
   TargetFallBelow, IrreplaceableFeature, FeaturesNotSatisfied : Array_t;
   rContributingArea, rTarget, rValue, rValue2 : extended;
   iTargetFallBelow, iIrreplaceableFeatures, iFeaturesNotSatisfied,
   iSiteKey, iReplaceSiteKey, iReplacementSites, iCount, iCount2, iFCount, i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
   ASite : site;
   Value : ValueFile_T;
   fAdd : boolean;
   sFeatures,
   sTmp,
   sKey : string;
   AFeat : featureoccurrence;
   fAllFeaturesAtSiteSatisfied, fTargetFallBelow, fIrreplaceableSite, fIrreplaceableFeature,
   fContinue, fFeatureNotSatisfied : boolean;
begin
     try
        {if ((Available.SelCount +
             Flagged.SelCount +
             R1.SelCount +
             R2.SelCount +
             R3.SelCount +
             R4.SelCount +
             R5.SelCount +
             Partial.SelCount) = 1) then}
        begin
             Highlight2Arr(SingleSite);
             SingleSite.rtnValue(1,@iReplaceSiteKey);

             iReplacementSites := 0;
             ReplacementSites := Array_t.Create;
             ReplacementSites.init(SizeOf(integer),iSiteCount);

             // init features at sites
             FeaturesAtSingleSite := Array_t.Create;
             FeaturesAtSingleSite.init(SizeOf(extended),iFeatureCount);
             FeaturesAtReplacementSite := Array_t.Create;
             FeaturesAtReplacementSite.init(SizeOf(extended),iFeatureCount);
             TargetFallBelow := Array_t.Create;
             TargetFallBelow.init(SizeOf(boolean),iFeatureCount);
             fTargetFallBelow := False;
             iTargetFallBelow := 0;
             fIrreplaceableSite := False;
             IrreplaceableFeature := Array_t.Create;
             IrreplaceableFeature.init(SizeOf(boolean),iFeatureCount);
             fIrreplaceableFeature := False;
             iIrreplaceableFeatures := 0;
             FeaturesNotSatisfied := Array_t.Create;
             FeaturesNotSatisfied.init(SizeOf(boolean),iFeatureCount);
             fFeatureNotSatisfied := False;
             iFeaturesNotSatisfied := 0;
             rValue := 0;
             for iCount := 1 to iFeatureCount do
             begin
                  FeaturesAtSingleSite.setValue(iCount,@rValue);
                  FeaturesAtReplacementSite.setValue(iCount,@rValue);
                  TargetFallBelow.setValue(iCount,@fTargetFallBelow);
                  IrreplaceableFeature.setValue(iCount,@fIrreplaceableFeature);
                  FeaturesNotSatisfied.setValue(iCount,@fFeatureNotSatisfied);
             end;
             // init FeaturesAtSingleSite
             fAllFeaturesAtSiteSatisfied := True;
             iSiteIndex := FindFeatMatch(OrdSiteArr,iReplaceSiteKey);
             SiteArr.rtnValue(iSiteIndex,@ASite);
             if (ASite.richness > 0) then
                for iCount := 1 to ASite.richness do
                begin
                     // ((ASite.status = Av) or (ASite.status = Fl))
                     // distinguish between available or reserved site
                     // if site is available, target does not include amount at site
                     // if site is reserved, target does include amount at site

                     FeatureAmount.rtnValue(ASite.iOffset + iCount,@Value);
                     // store the area of this feature that is contributing to targets
                     FeatArr.rtnValue(Value.iFeatKey,@AFeat);
                     if (AFeat.targetarea > 0) then
                     begin
                          fAllFeaturesAtSiteSatisfied := False;
                          fFeatureNotSatisfied := True;
                          FeaturesNotSatisfied.setValue(Value.iFeatKey,@fFeatureNotSatisfied);
                          Inc(iFeaturesNotSatisfied);
                     end;
                     if ((ASite.status = Av) or (ASite.status = Fl)) then
                        rTarget := AFeat.targetarea
                     else
                         rTarget := AFeat.targetarea + Value.rAmount;
                     if (rTarget > 0) then
                        rContributingArea := rTarget
                     else
                         rContributingArea := 0;
                     if (rContributingArea > 0)
                     and (Value.rAmount < rContributingArea) then
                         rContributingArea := Value.rAmount;
                     FeaturesAtSingleSite.setValue(Value.iFeatKey,@rContributingArea);

                     // will target fall below
                     if (AFeat.targetarea <= 0)
                     and (rTarget > 0) then
                     begin
                          fTargetFallBelow := True;
                          Inc(iTargetFallBelow);
                     end
                     else
                         fTargetFallBelow := False;
                     TargetFallBelow.setValue(Value.iFeatKey,@fTargetFallBelow);

                     // is site irreplaceable for the feature ?
                     if (AFeat.rCurrentSumArea < rTarget) then
                     begin
                          fIrreplaceableSite := True;
                          fIrreplaceableFeature := True;
                          IrreplaceableFeature.setValue(Value.iFeatKey,@fIrreplaceableFeature);
                          Inc(iIrreplaceableFeatures);
                     end;
                end;

             fContinue := True;

             if (not fAllFeaturesAtSiteSatisfied) then
             begin
                  if (iFeaturesNotSatisfied = 1) then
                     sTmp := 'one feature at the site is'
                  else
                      sTmp := IntToStr(iFeaturesNotSatisfied) + ' features at the site are';
                  sFeatures := Chr(10) + Chr(13);
                  for iCount := 1 to iFeatureCount do
                  begin
                       FeaturesNotSatisfied.rtnValue(iCount,@fFeatureNotSatisfied);
                       if fFeatureNotSatisfied then
                       begin
                            FeatArr.rtnValue(iCount,@AFeat);
                            sFeatures := sFeatures + Chr(10) + Chr(13) + '    ' + AFeat.sID;
                       end;
                  end;
                  fContinue := (mrYes = MessageDlg('The target for ' + sTmp + ' not satisfied.  Continue?' + sFeatures,mtConfirmation,[mbYes,mbNo],0));
             end;

             //if fContinue then
             //   if (iTargetFallBelow > 0) then
             //   begin
             //        if (iTargetFallBelow = 1) then
             //           sTmp := 'One feature'
             //        else
             //            sTmp := IntToStr(iTargetFallBelow) + ' features';
             //        fContinue := (mrYes = MessageDlg(sTmp + ' will fall below target.  Continue?',mtConfirmation,[mbYes,mbNo],0));
             //   end;

             if fContinue then
                if fIrreplaceableSite then
                begin
                     if (iIrreplaceableFeatures = 1) then
                        sTmp := 'One feature'
                     else
                         sTmp := IntToStr(iIrreplaceableFeatures) + ' features';
                     sFeatures := Chr(10) + Chr(13);
                     for iCount := 1 to iFeatureCount do
                     begin
                          IrreplaceableFeature.rtnValue(iCount,@fFeatureNotSatisfied);
                          if fFeatureNotSatisfied then
                          begin
                               FeatArr.rtnValue(iCount,@AFeat);
                               sFeatures := sFeatures + Chr(10) + Chr(13) + '    ' + AFeat.sID;
                          end;
                     end;
                     fContinue := (mrYes = MessageDlg(sTmp + ' are irreplaceable at this site.  Continue?' + sFeatures,mtConfirmation,[mbYes,mbNo],0));
                end;

             if fContinue then
             begin
                  // parse sites looking for replacement sites, comparing each of the available sites
                  for iCount := 1 to AvailableKey.Items.Count do
                  begin
                       sKey := AvailableKey.Items.Strings[iCount-1];
                       iSiteKey := StrToInt(sKey);
                       iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
                       SiteArr.rtnValue(iSiteIndex,@ASite);
                       if (ASite.iKey <> iReplaceSiteKey)
                       and ((ASite.status = Av) or (ASite.status = Fl)) then
                       begin
                            // set FeaturesAtReplacementSite
                            rValue := 0;
                            for iCount2 := 1 to iFeatureCount do
                                FeaturesAtReplacementSite.setValue(iCount2,@rValue);
                            if (ASite.richness > 0) then
                               for iCount2 := 1 to ASite.richness do
                               begin
                                    FeatureAmount.rtnValue(ASite.iOffset + iCount2,@Value);
                                    rValue := Value.rAmount;
                                    FeaturesAtReplacementSite.setValue(Value.iFeatKey,@rValue);
                               end;

                            // test if as good as single site, add to list if true
                            fAdd := True;
                            for iFCount := 1 to iFeatureCount do
                            begin
                                 FeaturesAtSingleSite.rtnValue(iFCount,@rValue);
                                 FeaturesAtReplacementSite.rtnValue(iFCount,@rValue2);
                                 if (rValue > rValue2) then
                                    fAdd := False;
                            end;
                            if fAdd then
                            begin
                                 Inc(iReplacementSites);
                                 ReplacementSites.setValue(iReplacementSites,@iSiteKey);
                            end;
                       end;
                  end;

                  if (iReplacementSites > 0) then
                  begin
                       if (iReplacementSites = 1) then
                          MessageDlg('There is 1 replacement site',mtInformation,[mbOk],0)
                       else
                           MessageDlg('There are ' + IntToStr(iReplacementSites) + ' replacement sites',mtInformation,[mbOk],0);
                       ReplacementSites.resize(iReplacementSites);

                       Arr2Highlight(ReplacementSites,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);

                       MapSites(ReplacementSites,False);
                       Screen.Cursor := crDefault;
                  end
                  else
                  begin
                       ReplacementSites.Destroy;
                       MessageDlg('There are no replacement sites',mtInformation,[mbOk],0);
                  end;
             end
             else
                 ReplacementSites.Destroy;

             FeaturesAtSingleSite.Destroy;
             FeaturesAtReplacementSite.Destroy;
             SingleSite.Destroy;
             TargetFallBelow.Destroy;
             IrreplaceableFeature.Destroy;
             FeaturesNotSatisfied.Destroy;
             //ReplacementSites.Destroy;
        end
        {else
            MessageDlg('Select a single '+ControlRes^.sR1Label+', '+ControlRes^.sR2Label
                       +', '+ControlRes^.sR3Label+', '+ControlRes^.sR4Label+', '+ControlRes^.sR5Label
                       +' or Partially Reserved site to use this function',mtInformation,[mbOk],0)};

     except
           MessageDlg('Exception in FindReplacementSites',mtInformation,[mbOk],0);
     end;
end;

procedure TControlForm.btnAcceptClick(Sender: TObject);
var
   LookupSites : Array_t;
   fWatchChange, fOldWatchUnDef, fNotDone : boolean;
   iKey : integer;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
   sItem : string;
begin
     try
        {we are in multiple select mode}
        if (Available.SelCount > 0)
        or (R1.SelCount > 0)
        or (R2.SelCount > 0)
        or (R3.SelCount > 0)
        or (R4.SelCount > 0)
        or (R5.SelCount > 0)
        or (Excluded.SelCount > 0)
        or (Partial.SelCount > 0)
        or (Flagged.SelCount > 0)
        or (Reserved.SelCount > 0)
        or (Ignored.SelCount > 0) then
        begin
             {we have a multiple DDE selection stored}

             sItem := ClickGroup.Items.Strings[ClickGroup.ItemIndex];
             if (sItem = 'Lookup') then
             begin
                  if Highlight2Arr(LookupSites) then
                     StartLookupArr(LookupSites);
             end
             else
             if (sItem = 'Features') then
                ShowFeatureForm(NULL_SITE_GEOCODE)
             else
             if (sItem = 'Available') then
             begin
                  {de-select to Available from ALL classes}
                  if (R1.SelCount > 0) then
                     MoveGroup(R1,R1Key,Available,AvailableKey,TRUE,True);
                  if (R2.SelCount > 0) then
                     MoveGroup(R2,R2Key,Available,AvailableKey,TRUE,True);
                  if (R3.SelCount > 0) then
                     MoveGroup(R3,R3Key,Available,AvailableKey,TRUE,True);
                  if (R4.SelCount > 0) then
                     MoveGroup(R4,R4Key,Available,AvailableKey,TRUE,True);
                  if (R5.SelCount > 0) then
                     MoveGroup(R5,R5Key,Available,AvailableKey,TRUE,True);
                  if (Partial.SelCount > 0) then
                     MoveGroup(Partial,PartialKey,Available,AvailableKey,TRUE,True);
                  if (Flagged.SelCount > 0) then
                     MoveGroup(Flagged,FlaggedKey,Available,AvailableKey,TRUE,True);
                  if (Excluded.SelCount > 0) then
                     MoveGroup(Excluded,ExcludedKey,Available,AvailableKey,TRUE,True);
             end
             else
             begin
                  if Highlight2Arr(LookupSites) then
                  begin
                       UnHighlight(Available,fKeepHighlight);
                       UnHighlight(R1,fKeepHighlight);
                       UnHighlight(R2,fKeepHighlight);
                       UnHighlight(R3,fKeepHighlight);
                       UnHighlight(R4,fKeepHighlight);
                       UnHighlight(R5,fKeepHighlight);
                       UnHighlight(Partial,fKeepHighlight);
                       UnHighlight(Flagged,fKeepHighlight);
                       UnHighlight(Excluded,fKeepHighlight);
                       Arr2Highlight(LookupSites,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);
                       fWatchChange := False;
                       if (sItem = ControlRes^.sR1label) or (sItem = ControlRes^.sR2label) or (sItem = ControlRes^.sR3label) or (sItem = ControlRes^.sR4label) or (sItem = ControlRes^.sR5label) then
                       begin
                            {reselecting to R1,R2,R3,R4 or R5}
                            fWatchChange := True;
                            fOldWatchUnDef := fWatchUnDef;
                            fWatchUnDef := False;
                       end;

                       {de-select to Available from ALL classes}
                       if (sItem <> ControlRes^.sR1Label) then
                          if (R1.SelCount > 0) then
                             MoveGroup(R1,R1Key,Available,AvailableKey,TRUE,True);
                       if (sItem <> ControlRes^.sR2Label) then
                          if (R2.SelCount > 0) then
                             MoveGroup(R2,R2Key,Available,AvailableKey,TRUE,True);
                       if (sItem <> ControlRes^.sR3Label) then
                          if (R3.SelCount > 0) then
                             MoveGroup(R3,R3Key,Available,AvailableKey,TRUE,True);
                       if (sItem <> ControlRes^.sR4Label) then
                          if (R4.SelCount > 0) then
                             MoveGroup(R4,R4Key,Available,AvailableKey,TRUE,True);
                       if (sItem <> ControlRes^.sR5Label) then
                          if (R5.SelCount > 0) then
                             MoveGroup(R5,R5Key,Available,AvailableKey,TRUE,True);
                       if (sItem <> 'Partial') then
                          if (Partial.SelCount > 0) then
                             MoveGroup(Partial,PartialKey,Available,AvailableKey,TRUE,True);
                       if (sItem <> 'Flagged') then
                          if (Flagged.SelCount > 0) then
                             MoveGroup(Flagged,FlaggedKey,Available,AvailableKey,TRUE,True);
                       if (sItem <> 'Excluded') then
                          if (Excluded.SelCount > 0) then
                             MoveGroup(Excluded,ExcludedKey,Available,AvailableKey,TRUE,True);

                       Arr2Highlight(LookupSites,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);
                       if fWatchChange then
                          fWatchUnDef := fOldWatchUnDef;
                       if (sItem = ControlRes^.sR1Label) then
                          MoveGroup(Available,AvailableKey,
                                    R1,R1Key,TRUE,True);
                       if (sItem = ControlRes^.sR2Label) then
                          MoveGroup(Available,AvailableKey,
                                    R2,R2Key,TRUE,True);
                       if (sItem = ControlRes^.sR3Label) then
                          MoveGroup(Available,AvailableKey,
                                    R3,R3Key,TRUE,True);
                       if (sItem = ControlRes^.sR4Label) then
                          MoveGroup(Available,AvailableKey,
                                    R4,R4Key,TRUE,True);
                       if (sItem = ControlRes^.sR5Label) then
                          MoveGroup(Available,AvailableKey,
                                    R5,R5Key,TRUE,True);
                       if (sItem = 'Partial') then
                          MoveGroup(Available,AvailableKey,
                                    Partial,PartialKey,TRUE,True);
                       if (sItem = 'Flagged') then
                          MoveGroup(Available,AvailableKey,
                                    Flagged,FlaggedKey,TRUE,True);
                       if (sItem = 'Excluded') then
                          MoveGroup(Available,AvailableKey,
                                    Excluded,ExcludedKey,TRUE,True);
                       LookupSites.Destroy;
                  end;
             end;
             UnHighlight(Available,fKeepHighlight);
             UnHighlight(R1,fKeepHighlight);
             UnHighlight(R2,fKeepHighlight);
             UnHighlight(R3,fKeepHighlight);
             UnHighlight(R4,fKeepHighlight);
             UnHighlight(R5,fKeepHighlight);
             UnHighlight(Partial,fKeepHighlight);
             UnHighlight(Flagged,fKeepHighlight);
             UnHighlight(Excluded,fKeepHighlight);
        end
        else
            MessageDlg('You must highlight sites to activate this function',
                       mtInformation,[mbOk],0);
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in btnAcceptClick',mtError,[mbOk],0);
     end;
end;

procedure DumpMemInfo(const s:string);
begin
     {$IFDEF DUMP_MEM_INFO}
     Debug2File(1,'DumpMemInfo ' + IntToStr(MemAvail) +
                ' maxavail ' + IntToStr(MaxAvail) +
                ' ' + s);
     {$ENDIF}
end;

procedure TControlForm.UseFeatCutOffsClick(Sender: TObject);
var
   fStop, fRetainClass : boolean;
   sRetainClass : string;
   iResult : integer;
begin
     fStop := False;

     if (not ControlRes^.fStarting)
     and (not fUsingFeat)then
     begin
          fUsingFeat := True;

          fRetainClass := ControlRes^.fFeatureClassesApplied;
          sRetainClass := ControlRes^.sFeatureClassField;

          if (UseFeatCutOffs.Checked) then
          begin
               UseFeatCutOffs.Hint := 'Click to apply User-Defined targets';

               SelectTargetFieldForm := TSelectTargetFieldForm.Create(Application);
               if (mrOk = SelectTargetFieldForm.ShowModal) then
               begin
                    // apply the new target field
                    if (SelectTargetFieldForm.TgtField.Text <> ControlRes^.sFeatureTargetField) then
                       ControlRes^.sFeatureTargetField := SelectTargetFieldForm.TgtField.Text;
                    ReadFeatureTarget(SelectTargetFieldForm.TgtField.Text);
               end;
               //UseFeatCutOffs.Caption := 'Use ' + ControlRes^.sFeatureTargetField;
               SelectTargetFieldForm.Free;
          end
          else
          begin
               UseFeatCutOffs.Hint := 'Click to apply Percentage targets';

               try
                  PCTargForm := TPCTargForm.Create(Application);
                  iResult := PCTargForm.ShowModal;
                  if (mrCancel = iResult) then
                  begin
                       fStop := True;
                       UseFeatCutOffs.Checked := True;
                  end;
                  if (mrNo = iResult) then
                  begin
                       // Select a Target field instead
                       UseFeatCutOffs.Checked := True;
                       UseFeatCutOffs.Hint := 'Click to apply User-Defined targets';

                       SelectTargetFieldForm := TSelectTargetFieldForm.Create(Application);
                       if (mrOk = SelectTargetFieldForm.ShowModal) then
                       begin
                            // apply the new target field
                            if (SelectTargetFieldForm.TgtField.Text <> ControlRes^.sFeatureTargetField) then
                               ControlRes^.sFeatureTargetField := SelectTargetFieldForm.TgtField.Text;
                            ReadFeatureTarget(SelectTargetFieldForm.TgtField.Text);
                       end;
                       //UseFeatCutOffs.Caption := 'Use ' + ControlRes^.sFeatureTargetField;
                       SelectTargetFieldForm.Free;
                       //fStop := True;
                  end;
                  if (mrNone = iResult) then
                     UseFeatCutOffs.Caption := 'User-Defined';
               finally
                      PCTargForm.Free;
               end;
               //UseFeatCutOffs.Caption := 'Use ITARGET';
          end;

          TargetPercent.Enabled := not UseFeatCutOffs.Checked;

          if not fStop then
          try
             Screen.Cursor := crHourglass;

             FitComponents2Form;
             ReInitializeInitialValues(TargetChange);

             if fRetainClass then
             begin
                  LoadOrdinalClass(sRetainClass,ControLRes^.ClassDetail);
                  ControlRes^.fFeatureClassesApplied := True;
                  ControlRes^.sFeatureClassField := sRetainClass;
             end;

             ExecuteIrreplaceability(-1,False,False,True,True,'');

             fIniChange := True;

          finally
                 Screen.Cursor := crDefault;
          end
          else;

          fUsingFeat := False;
     end;
end;

procedure TControlForm.IrrepSimon1Click(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;

        DumpMemInfo('before simonirrep');

        try
           ExecuteIrreplaceability(-1,False,False,True,True,'');

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in ExecuteIrreplaceability',
                         mtError,[mbOk],0);
        end;

        DumpMemInfo('after simonirrep');

     finally
            //Screen.Cursor := crDefault;
     end;
end;

function FeatVal(const ASite : site; const iIndex : integer) : extended;
var
   iCount : integer;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     Result := 0;

     if (ASite.richness > 0) then
     for iCount := 1 to ASite.richness do
     begin
          {$IFDEF SPARSE_MATRIX}
          FeatureAmount.rtnValue(ASite.iOffset + iCount,@Value);
          if (Value.iFeatKey = iIndex) then
             Result := Value.rAmount;
          {$ELSE}
          if (ASite.feature[iCount] = iIndex) then
             Result := ASite.featurearea[iCount];
          {$ENDIF}
     end;
end;


procedure TControlForm.SustainableYield1Click(Sender: TObject);
begin
     FindSustainableYield;
end;

function ResourceFieldsOk(ABox : TListBox;
                          var iFailCount : integer) : boolean;
var
   fStop, fMatch : boolean;
   iCount, iCount2 : integer;
begin
     {scan the site summary table fields and reports
      how many of the fields in ABox are present}

     Result := False;
     iFailCount := 0;

     try
        fStop := False;
        ControlForm.OutTable.Open; {initialises DB on first Line of Table}

     except on exception do
            begin
                 fStop := True;
                 Screen.Cursor := crDefault;
                 MessageDlg('ResourceFieldsOk cannot open ' + ControlForm.OutTable.DatabaseName +
                            '\' + ControlForm.OutTable.TableName,mtInformation,[mbOk],0);
            end;
     end;

     if not fStop then
     try
        if (ABox.Items.Count > 0) then
           for iCount := 0 to (ABox.Items.Count-1) do
           begin
                fMatch := False;
                for iCount2 := 0 to (ControlForm.OutTable.FieldDefs.Count-1) do
                    if (ABox.Items.Strings[iCount] =
                        ControlForm.OutTable.FieldDefs.Items[iCount2].Name) then
                       fMatch := True;

                if not fMatch then
                   Inc(iFailCount);
           end;

        if (iFailCount = 0) then
           Result := True;

     finally
            ControlForm.OutTable.Close;
     end;
end;

procedure TControlForm.TimberResource1Click(Sender: TObject);
var
   iFailCount : integer;
   sLbl : string;
begin
     try
        ChooseResForm := TChooseResForm.Create(Application);

        if (ChooseResForm.CResBox.Items.Count > 0) then
           ChooseResForm.ShowModal
        else
        begin
             if ControlRes^.fOldIni then
                sLbl := OLD_INI_FILE_NAME
             else
                 sLbl := INI_FILE_NAME;

             MessageDlg('You must specify [Resource] fields in the Options file ' +
                        Chr(10) + Chr(13) + sLbl + ' to activate this function.' +
                        Chr(10) + Chr(13) + 'Consult the Documentation for more information.',
                        mtInformation,[mbOk],0);
        end;

     finally
            ChooseResForm.Free;
     end;
end;

procedure TControlForm.SQLLookup1Click(Sender: TObject);
begin
     RunSQL(SQL_LOOKUP);
end;

procedure TControlForm.SQLMap1Click(Sender: TObject);
begin
     RunSQL(SQL_ADD_MAP);
end;

procedure CustTrimExt(var sFileToCreate : string;
                      const sSuffix : string);
var
   iDotPos, iCount : integer;
begin
     iDotPos := 0;

     for iCount := 1 to Length(sFileToCreate) do
         if (sFileToCreate[iCount] = '.') then
            iDotPos := iCount;

     if (iDotPos = 1) then
        sFileToCreate[1] := '_'
     else
         if (iDotPos > 1) then
            sFileToCreate := Copy(sFileToCreate,1,iDotPos-1);

     if (Length(sFileToCreate) > (8 - Length(sSuffix))) then
        sFileToCreate := Copy(sFileToCreate,1,(8 - Length(sSuffix)));

     sFileToCreate := sFileToCreate + sSuffix;
end;

function GetReptPath(const sLabel, sDef, sSuffix, sExtension : string;
                     var sFile, sDescr : string) : boolean;
var
   fEnd : boolean;
   wDlgResult : word;
   sFileToCreate : string;

begin
     with ControlForm.RptSave do
     begin
          Title := 'Enter File and Path for ' + sLabel + ' Report.';
          InitialDir := ControlRes^.sWorkingDirectory;
          FileName := sDef;

          repeat
                Result := Execute;

                if (FileName = '') then
                   FileName := 'no_name';

                fEnd := True;

                sFileToCreate := ExtractFileName(FileName);

                CustTrimExt(sFileToCreate,sSuffix);

                sFileToCreate := ExtractFilePath(FileName) +
                                 sFileToCreate + sExtension;

                if Result
                and FileExists(sFileToCreate) then
                begin
                     wDlgResult := MessageDlg('File ' + sFileToCreate +
                                              ' Exists, Overwrite?',
                                              mtConfirmation,
                                              [mbYes,mbNo,mbCancel],0);

                     if (wDlgResult = mrNo) then
                        fEnd := False
                     else
                         if (wDlgResult = mrCancel) then
                            Result := False;
                end;


          until fEnd;

          if Result then
          begin
               sFile := sFileToCreate;

               sDescr := RptDescribe(sLabel);

               if (sDescr = '') then
                  Result := False;
          end;
     end;
end;

procedure TControlForm.CountSites1Click(Sender: TObject);
var
   sFile, sDescr : string;
begin
     Screen.Cursor := crHourglass;

     if not fContrDataDone then
        ExecuteIrreplaceability(-1,False,False,True,True,'');

     Screen.Cursor := crDefault;


     try
        iReportFlag := RPT_SITE_COUNT;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;

end;

procedure TControlForm.FeaturesToTarget1Click(Sender: TObject);
begin
     Screen.Cursor := crHourglass;

     if not fContrDataDone then
        ExecuteIrreplaceability(-1,False,False,True,True,'');

     Screen.Cursor := crDefault;

     try
        FeaturesToTargetForm := TFeaturesToTargetForm.Create(Application);
        FeaturesToTargetForm.ShowModal;

     finally
            FeaturesToTargetForm.Free;
     end;
end;

procedure TControlForm.StageDescription1Click(Sender: TObject);
begin
     EditViewStageMemo;
end;

procedure TControlForm.Browse1Click(Sender: TObject);
var
   wDlgResult, wBrowseResult : word;
   fCancel, fCancelPressed, fRetainClass : boolean;
   sRetainClass : string;
begin
     OpenDialog.FileName := 'sample.log';
     OpenDialog.InitialDir := ControlRes^.sWorkingDirectory;
     OpenDialog.Title := 'Browse Selection File';

     if OpenDialog.Execute then
     begin
          fRetainClass := ControlRes^.fFeatureClassesApplied;
          sRetainClass := ControlRes^.sFeatureClassField;

          wBrowseResult := BrowseSelectionMemo(OpenDialog.FileName);

          case wBrowseResult of
               RESULT_CANCEL : ;
               RESULT_OPEN :
                   begin
                        fCancel := False;
                        if fSelectionChange
                        or fFlagSelectionChange then
                        begin
                             wDlgResult := MessageDlg
                                ('Save changes before load?',mtConfirmation,[mbYes,mbNo,mbCancel],0);
                             case wDlgResult of
                                  mrYes : Save1Click(Self,fCancel,fCancelPressed);
                                  mrCancel : fCancel := True;
                             end;
                        end;
                        if not fCancel then
                        begin
                             fSelectionChange := False;
                             fFlagSelectionChange := False;
                             {selections do not need to be saved}
                             fContrDataDone := False;
                             {data in contribution objects needs to be updated}

                             LoadSelections(OpenDialog.FileName);
                             if not CheckSelections then
                             begin
                                  //
                                  LoadSelections(ControlRes^.sDatabase + '\empty.log');
                                  AddSelections(OpenDialog.FileName,False);
                             end;
                             LabelCountUpdate;
                             RePrepIrrepData;

                             if fRetainClass then
                             begin
                                  if (mrYes = MessageDlg('Retain Feature Subset ' +
                                                         sRetainClass,
                                                         mtConfirmation,
                                                         [mbYes,mbNo],0)) then
                                  begin
                                       LoadOrdinalClass(sRetainClass,ControLRes^.ClassDetail);
                                       ControlRes^.fFeatureClassesApplied := True;
                                       ControlRes^.sFeatureClassField := sRetainClass;
                                  end;
                             end;

                             ExecuteIrreplaceability(-1,False,False,True,True,'');

                             SaveDialog.Filename := ExtractFileName(OpenDialog.Filename);
                             SaveDialog.InitialDir := ExtractFilePath(OpenDialog.Filename);
                        end;
                   end;
               RESULT_BROWSE : Browse1Click(self);
          end;
     end;
end;

procedure TControlForm.EditTargets1Click(Sender: TObject);
var
   iCount : integer;
   rEditedTarget : extended;
begin
     try
        fEditTargets := False;

        Screen.Cursor := crHourglass;
        EditForm := TEditForm.Create(Application);
        //EasyEditTargetsForm := TEasyEditTargetsForm.Create(Application);
        Screen.Cursor := crDefault;

        if (EditForm.ShowModal <> mrCancel) then
           fEditTargets := True;
        //if (EasyEditTargetsForm.ShowModal <> mrCancel) then
        //   fEditTargets := True;

        if (not UseFeatCutOffs.Checked) then
           fEditTargets := False;

     finally
            Screen.Cursor := crHourglass;

            EditForm.Free;

            if fEditTargets then
            begin
                 // Save feature targets to the feature table
                 (*EasyEditTargetsForm.Table1.DatabaseName := ControlRes^.sDatabase;
                 EasyEditTargetsForm.Table1.TableName := ControlRes^.sFeatCutOffsTable;
                 EasyEditTargetsForm.Table1.Open;

                 for iCount := 1 to iFeatureCount do
                 begin
                      try
                         rEditedTarget := StrToFloat(EasyEditTargetsForm.StringGrid1.Cells[2,iCount]);
                         EasyEditTargetsForm.Table1.Edit;
                         EasyEditTargetsForm.Table1.FieldByName(ControlRes^.sFeatureTargetField).AsFloat := rEditedTarget;

                      except
                      end;

                      EasyEditTargetsForm.Table1.Next;
                 end;

                 EasyEditTargetsForm.Table1.Close;

                 EasyEditTargetsForm.Free;*)

                 LoadFeatureTable;

                 if UseFeatCutOffs.Checked then
                 begin
                      {we are using imported targets, so we must run irrep}
                      ReInitializeInitialValues(TargetChange);

                      ExecuteIrreplaceability(-1,False,False,True,True,'');
                 end;
            end;

            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.PartialDeferral1Click(Sender: TObject);
var
   aUserSites : Array_T;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
begin
     if (Partial.Items.Count > 0) then
     begin
          if not fContrDataDone then
             ExecuteIrreplaceability(-1,False,False,True,True,'');

          try
             wPartEdFlag := READ_PARTIAL;
             PartEdForm := TPartEdForm.Create(Application);
             PartEdForm.ShowModal;

          finally
                 PartEdForm.Free;
          end;

          try
             Screen.Cursor := crHourglass;

             if (Partial.Items.Count > 0) then
             begin
                  Box2Arr(Partial,PartialKey,aUserSites);
                  Screen.Cursor := crDefault;

                  TestPartialSitesToDeselect(aUserSites);

                  UnHighlight(Partial,fKeepHighlight);

                  if (aUserSites.lMaxSize > 0) then
                  begin
                       Arr2Highlight(aUserSites,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);
                       MoveGroup(Partial,PartialKey,
                                 Available,AvailableKey,False,True);
                  end;
                  aUserSites.Destroy;

                  Screen.Cursor := crHourglass;
             end;

          finally
                 Screen.Cursor := crDefault;
          end;
     end
     else
     begin
          {there are no partially reserved sites}
          MessageDlg('There are no partially selected sites',mtInformation,[mbOk],0);
     end;
end;

{$IFDEF FASTINIT}
procedure ArcViewFInit;
var
   sCmd :  string;
begin
     ControlForm.CreateGIS;
end;
{$ENDIF}

procedure TControlForm.InitialDisplayState1Click(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        {$IFDEF FASTINIT}
        {code to fast init ArcView}
        if (ControlRes^.GISLink = ArcView) then
        begin
             ArcViewFInit;
        end
        {else
            if ControlRes^.GISLink = WinERMS then
            begin
                 InitDisplay2DB;
                 CreateWinERMS;
            end};
        {$ELSE}
        InitDisplay2DB;


        if ControlRes^.GISLink = WinERMS then
           CreateWinERMS;

        if fStatusLayerOn
        or fEMRLayerOn then
           DDEUpdate;
        {$ENDIF}

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.RestrictTargets1Click(Sender: TObject);
begin
     try
        try
           RestTargForm := TRestTargForm.Create(Application);
           RestTargForm.ShowModal;

        finally
               RestTargForm.Free;
        end;

     except
           Screen.Cursor := crDefault;
           RptErrorStop('Exception in RestrictTargetsClick');
     end;
end;

procedure TControlForm.SQLMap2Click(Sender: TObject);
begin
     RunSQL(SQL_MAP);
end;

procedure TControlForm.PartialDeferral2Click(Sender: TObject);
var
   sFile, sDescr : string;
begin
     Screen.Cursor := crHourglass;

     if (ControlForm.Partial.Items.Count > 0) then
        if not fContrDataDone then
           ExecuteIrreplaceability(-1,False,False,True,True,'');

     Screen.Cursor := crDefault;

     if (ControlForm.Partial.Items.Count > 0) then
     try
        iReportFlag := RPT_PART_DEF;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end
     else
         MessageDlg('You must select Partially Deferred sites to activate this function',
                     mtInformation,[mbOk],0);
end;

procedure TControlForm.ParGroupClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        ControlRes^.sLastChoiceType := 'Highlight Group';

        MoveGroup(Available,AvailableKey,Partial,PartialKey,TRUE,True);

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.UnParGroupClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        ControlRes^.sLastChoiceType := 'Highlight Group';

        MoveGroup(Partial,PartialKey,Available,AvailableKey,TRUE,True);

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.UnParAllClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        ControlRes^.sLastChoiceType := 'Highlight Group';

        MoveAll(Partial,PartialKey,Available,AvailableKey,True);

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.FlgGroupClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        ControlRes^.sLastChoiceType := 'Highlight Group';

        MoveGroup(Available,AvailableKey,Flagged,FlaggedKey,TRUE,True);

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.UnFlgGroupClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        ControlRes^.sLastChoiceType := 'Highlight Group';

        MoveGroup(Flagged,FlaggedKey,Available,AvailableKey,TRUE,True);

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.UnFlgAllClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        ControlRes^.sLastChoiceType := 'Highlight Group';

        MoveAll(Flagged,FlaggedKey,Available,AvailableKey,True);

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.HideFlagged1Click(Sender: TObject);
begin
     if HideFlagged1.Checked then
     begin
          {un-hide flg}
          EnableFlagged;
          HideFlagged1.Checked := False;
          FlgGroup.Visible := True;
     end
     else
     begin
          {hide flg}
          DisableFlagged;
          HideFlagged1.Checked := True;
          FlgGroup.Visible := False;
     end;

     CheckFlgEmpty;

     fIniChange := True;

     FitComponents2Form;
end;

procedure TControlForm.Replot1Click(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;

        if not fContrDataDone then
           ExecuteIrreplaceability(-1,False,False,True,True,'');

        CreateGIS;

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.MissingFeatures1Click(Sender: TObject);
var
   sFile, sDescr : string;
begin
     try
        iReportFlag := RPT_MISS_FEAT;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;
end;

procedure TControlForm.AllReports1Click(Sender: TObject);
var
   sFile, sDescr : string;
begin
     Screen.Cursor := crHourglass;

     if not fContrDataDone then
        ExecuteIrreplaceability(-1,False,False,True,True,'');

     Screen.Cursor := crDefault;

     try
        iReportFlag := RPT_ALL_MAIN;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;
end;

procedure TControlForm.LoadSiteNAME1Click(Sender: TObject);
begin
     Screen.Cursor := crHourglass;

     OpenSiteText.InitialDir := ControlRes^.sWorkingDirectory;
     OpenSiteText.Title := 'Locate Site NAME File';
     OpenSiteText.FileName := '';

     if OpenSiteText.Execute then
     begin
          if FileExists(OpenSiteText.FileName) then
             LoadHighlight(OpenSiteText.FileName,LOAD_NAME,True)
          else
          begin
               Screen.Cursor := crDefault;
               MessageDlg('File not found - ' + OpenSiteText.FileName,
                          mtInformation,[mbOk],0);
          end;
     end;

     Screen.Cursor := crDefault;
end;

procedure TControlForm.LoadSiteGEOCODE1Click(Sender: TObject);
begin
     Screen.Cursor := crHourglass;

     OpenSiteText.InitialDir := ControlRes^.sWorkingDirectory;
     OpenSiteText.Title := 'Locate Site KEY File';
     OpenSiteText.FileName := '';

     if OpenSiteText.Execute then
     begin
          if FileExists(OpenSiteText.FileName) then
             LoadHighlight(OpenSiteText.FileName,LOAD_GEOCODE,True)
          else
          begin
               Screen.Cursor := crDefault;
               MessageDlg('File not found - ' + OpenSiteText.FileName,
                          mtInformation,[mbOk],0);
          end;
     end;

     Screen.Cursor := crDefault;
end;

procedure TControlForm.ToolView1Click(Sender: TObject);
begin
     ControlForm.Visible := False;
     ControlRes^.fToolView := True;
     ToolForm := TToolForm.Create(Application);
end;

procedure TControlForm.SetToolView1Click(Sender: TObject);
begin
     {try
        OptionsForm := TOptionsForm.Create(Application);

        //OptionsForm.TabSet1.TabIndex := 3;
        OptionsForm.ShowModal;

     finally
            OptionsForm.Free;
     end;}
end;


procedure TControlForm.LoadSiteNames;
var
   fStop : boolean;
   wOldCursor : integer;

   pSite : sitepointer;
   iSiteGeoCode, iProgressCount : integer;
   lSiteIndex : longint;

   sTest : string;

begin
     ProcLabelOn('Loading Site Names');

     fStop := False;
     iProgressCount := 0;

     try
        OutTable.Open;
     except
           on EDBEngineError do
           begin
                wOldCursor := Screen.Cursor;
                Screen.Cursor := crDefault;

                MessageDlg('Database file not found - ' + OutTable.DatabaseName
                           + '\' + OutTable.TableName, mtWarning, [mbOK], 0);

                Screen.Cursor := wOldCursor;

                fStop := true {LoadNewFile(InTable.DatabaseName,InTable.TableName)};
           end;
           {load and test DB file}
     end;

     Reserved.Items.Clear;
     ReservedKey.Items.Clear;
     Ignored.Items.Clear;
     IgnoredKey.Items.Clear;
     Available.Items.Clear;
     AvailableKey.Items.Clear;

     new(pSite);

     AvailablePanel.Top := Available.Top;
     AvailablePanel.Left := Available.Left;
     AvailablePanel.Height := Available.Height;
     AvailablePanel.Width := Available.Width;
     AvailablePanel.Visible := True;
     Available.Visible := False;

     if FileExists(ControlRes^.sDatabase + '\' + 'av.bin')
     and FileExists(ControlRes^.sDatabase + '\' + 'avg.bin')
     and FileExists(ControlRes^.sDatabase + '\' + 're.bin')
     and FileExists(ControlRes^.sDatabase + '\' + 'reg.bin')
     and FileExists(ControlRes^.sDatabase + '\' + 'ig.bin')
     and FileExists(ControlRes^.sDatabase + '\' + 'igg.bin') then
     begin
          Available.Items.LoadFromFile(ControlRes^.sDatabase + '\' + 'av.bin');
          AvailableKey.Items.LoadFromFile(ControlRes^.sDatabase + '\' + 'avg.bin');
          Reserved.Items.LoadFromFile(ControlRes^.sDatabase + '\' + 're.bin');
          ReservedKey.Items.LoadFromFile(ControlRes^.sDatabase + '\' + 'reg.bin');
          Ignored.Items.LoadFromFile(ControlRes^.sDatabase + '\' + 'ig.bin');
          IgnoredKey.Items.LoadFromFile(ControlRes^.sDatabase + '\' + 'igg.bin');
     end
     else
     if not fStop then
     repeat
           iSiteGeoCode := OutTable.FieldByName(ControlRes^.sKeyField).AsInteger;
           lSiteIndex := FindFeatMatch(OrdSiteArr,iSiteGeoCode);
           SiteArr.rtnValue(lSiteIndex,pSite);

           pSite^.area := OutTable.FieldByName(AREA_DBLABEL).AsFloat;

           if not ControlRes^.fStatusTested then
           begin
                ControlRes^.fStatusTested := True;

                try
                   sTest := OutTable.FieldByName('I_STATUS').AsString;
                   ControlRes^.sI_STATUSField := 'I_STATUS';
                except
                      ControlRes^.sI_STATUSField := 'TENURE';
                end;
           end;

           if (OutTable.FieldByName(ControlRes^.sI_STATUSField).AsString = 'Reserved') then
           begin
                Reserved.Items.Add(OutTable.FieldByName(NAME_DBLABEL).AsString);
                ReservedKey.Items.Add(OutTable.FieldByName(ControlRes^.sKeyField).AsString);

                pSite^.status := Re;
           end
           else
           if (OutTable.FieldByName(ControlRes^.sI_STATUSField).AsString = 'Ignored') then
           begin
                Ignored.Items.Add(OutTable.FieldByName(NAME_DBLABEL).AsString);
                IgnoredKey.Items.Add(OutTable.FieldByName(ControlRes^.sKeyField).AsString);

                pSite^.status := Ig;
           end
           else
           begin
                Available.Items.Add(OutTable.FieldByName(NAME_DBLABEL).AsString);
                AvailableKey.Items.Add(OutTable.FieldByName(ControlRes^.sKeyField).AsString);

                pSite^.status := Av;
           end;

           SiteArr.setValue(lSiteIndex,pSite);

           ProgressUpdate(Round(iProgressCount/OutTable.RecordCount*100));
           Inc(iProgressCount);

           OutTable.Next;

     until OutTable.EOF;

     Available.Visible := True;
     AvailablePanel.Visible := False;

     dispose(pSite);

     OutTable.Close;

     ProcLabelOff;
end;

procedure TControlForm.FormCreate(Sender: TObject);
begin
     SystemConv := TDdeClientConv.Create(Self);
     SystemItem := TDdeClientItem.Create(Self);
     MapConv := TDdeClientConv.Create(Self);
     MapItem := TDdeClientItem.Create(Self);

     SystemConv.ConnectMode := ddeManual;
     SystemConv.FormatChars := True;

     SystemItem.DdeConv := SystemConv;
     SystemItem.DdeItem := 'Selection';

     MapConv.ConnectMode := ddeManual;
     MapConv.FormatChars := True;

     MapItem.DdeConv := MapConv;
     MapItem.DdeItem := 'Selection';
end;

procedure TControlForm.OpenOptions1Click(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;

        ReLoadIni(self);

        fIniChange := False;

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.Negotiated1Click(Sender: TObject);
begin
     RunSQL(SQL_R1);
end;

procedure TControlForm.Mandatory2Click(Sender: TObject);
begin
     RunSQL(SQL_R2);
end;

procedure TControlForm.Partial2Click(Sender: TObject);
begin
     RunSQL(SQL_PAR);
end;

procedure TControlForm.Flagged2Click(Sender: TObject);
begin
     RunSQL(SQL_FLG);
end;

procedure TControlForm.Excluded2Click(Sender: TObject);
begin
     RunSQL(SQL_EXC);
end;

procedure TControlForm.Negotiated2Click(Sender: TObject);
begin
     RunSQL(SQL_UNR1);
end;

procedure TControlForm.Mandatory3Click(Sender: TObject);
begin
     RunSQL(SQL_UNR2);
end;

procedure TControlForm.Partial3Click(Sender: TObject);
begin
     RunSQL(SQL_UNPAR);
end;

procedure TControlForm.Flagged3Click(Sender: TObject);
begin
     RunSQL(SQL_UNFLG);
end;

procedure TControlForm.Excluded3Click(Sender: TObject);
begin
     RunSQL(SQL_UNEXC);
end;

procedure TControlForm.Deferred1Click(Sender: TObject);
begin
     RunSQL(SQL_UNDEFER);
end;

procedure TControlForm.Available2Click(Sender: TObject);
begin
     Highlight(Available);
end;

procedure TControlForm.Available3Click(Sender: TObject);
begin
     UnHighlight(Available,fKeepHighlight);
end;

procedure TControlForm.Negotiated3Click(Sender: TObject);
begin
     Highlight(R1);
end;

procedure TControlForm.Negotiated4Click(Sender: TObject);
begin
     UnHighlight(R1,fKeepHighlight);
end;

procedure TControlForm.Mandatory4Click(Sender: TObject);
begin
     Highlight(R2);
end;

procedure TControlForm.Mandatory5Click(Sender: TObject);
begin
     UnHighlight(R2,fKeepHighlight);
end;

procedure TControlForm.Excluded4Click(Sender: TObject);
begin
     Highlight(Excluded);
end;

procedure TControlForm.Excluded5Click(Sender: TObject);
begin
     UnHighlight(Excluded,fKeepHighlight);
end;

procedure TControlForm.AllClasses1Click(Sender: TObject);
begin
     UnHighlight(Available,fKeepHighlight);
     UnHighlight(R1,fKeepHighlight);
     UnHighlight(R2,fKeepHighlight);
     UnHighlight(R3,fKeepHighlight);
     UnHighlight(R4,fKeepHighlight);
     UnHighlight(R5,fKeepHighlight);
     UnHighlight(Excluded,fKeepHighlight);
     UnHighlight(Partial,fKeepHighlight);
     UnHighlight(Flagged,fKeepHighlight);
     UnHighlight(Reserved,fKeepHighlight);
     UnHighlight(Ignored,fKeepHighlight);
end;

procedure TControlForm.Partial1Click(Sender: TObject);
begin
     Highlight(Partial);
end;

procedure TControlForm.Flagged1Click(Sender: TObject);
begin
     Highlight(Flagged);
end;

procedure TControlForm.Partial4Click(Sender: TObject);
begin
     UnHighlight(Partial,fKeepHighlight);
end;

procedure TControlForm.Flagged4Click(Sender: TObject);
begin
     UnHighlight(Flagged,fKeepHighlight);
end;

procedure TControlForm.VariRunCombsize1Click(Sender: TObject);
begin
{$IFDEF VER90}
     try
        iReportFlag := RPT_VARI_COMB;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;
{$ENDIF}
end;

procedure TControlForm.ImportData2Click(Sender: TObject);
begin
     if not RunCPlanApp('import32','') then
        MessageDlg('Cannot find Import Utility',mtInformation,[mbOk],0);
end;

function RunCPlanApp(const sApp, sParam : string) : boolean;
var
   sRunFile, sPath, sCmd : string;
   PCmd : PChar;
   //AIniFile : TIniFile;
begin
     //AIniFile := TIniFile.Create(DB_INI_FILENAME);

     sPath := ExtractFilePath(Application.ExeName);
     // sPath := AIniFile.ReadString('Paths','32bit','');
     sRunFile := sPath + sApp + '.exe';

     if (sParam <> '') then
        sCmd := sRunFile + ' ' + sParam
     else
         sCmd := sRunFile;

     //AIniFile.Free;

     if FileExists(sRunFile) then
     begin
          GetMem(PCmd,Length(sCmd)+1);
          StrPCopy(PCmd,sCmd);

          WinEXEC(PCmd,SW_SHOW);

          FreeMem(PCmd,Length(sCmd)+1);

          Result := True;
     end
     else
         Result := False;
end;

procedure TControlForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if (VK_ESCAPE = Key) then
        ControlRes^.fEscapePressed := True
     else
         ControlRes^.fEscapePressed := False;;
end;

procedure TControlForm.DeferredNeMaPd1Click(Sender: TObject);
begin
     RunSQL(SQL_UNDEF_NOPAR);
end;

procedure SiteBoxDblClick(Box,GeoBox:TListBox);
var
   iCount : integer;
   fEnd : boolean;
begin
     if (Box.Items.Count > 0) then
     begin
          iCount := 0;
          fEnd := False;
          repeat
                if Box.Selected[iCount] then
                begin
                     UseGISKey(StrToInt(GeoBox.Items.Strings[iCount]),
                                       FALSE {do not minimise Control});
                     fEnd := True;
                end;

                Inc(iCount);

          until fEnd
          or (iCount>=Box.Items.Count);
     end;
end;

procedure TControlForm.AvailableDblClick(Sender: TObject);
begin
     //SiteBoxDblClick(Available,AvailableKey);
     btnAcceptClick(Sender);
end;

procedure TControlForm.R1DblClick(Sender: TObject);
begin
     //SiteBoxDblClick(Negotiated,NegotiatedKey);
     btnAcceptClick(Sender);
end;

procedure TControlForm.R2DblClick(Sender: TObject);
begin
     //SiteBoxDblClick(Mandatory,MandatoryKey);
     btnAcceptClick(Sender);
end;

procedure TControlForm.PartialDblClick(Sender: TObject);
begin
     btnAcceptClick(Sender);
     //SiteBoxDblClick(Partial,PartialKey);
end;

procedure TControlForm.FlaggedDblClick(Sender: TObject);
begin
     btnAcceptClick(Sender);
     //SiteBoxDblClick(Flagged,FlaggedKey);
end;

procedure TControlForm.ExcludedDblClick(Sender: TObject);
begin
     btnAcceptClick(Sender);
     //SiteBoxDblClick(Excluded,ExcludedKey);
end;

procedure TControlForm.ExtendedFunctions1Click(Sender: TObject);
begin
     try
        OptionsForm := TOptionsForm.Create(Application);

        OptionsForm.TabSet1.TabIndex := 3;
        OptionsForm.ShowModal;

     finally
            OptionsForm.Free;
     end;
end;

procedure TControlForm.btnSelectClick(Sender: TObject);
var
   lIterCount : longint;
begin
     Screen.Cursor := crHourglass;

     try
        {if GetUserCount('Random Test','Iteration Count','&Start','&Cancel',
                        1,1000,lIterCount) then
        begin
        end;}

        RunRandomTest(1);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RandomTestClick',
                      mtError,[mbOk],0);
     end;
end;

procedure TControlForm.RestoreDefaultOptions;
var
   MyIni : TIniFile;
begin
     {code to rename EMRTOOL.INI to CPLAN.INI, cannot be used with WinERMS
      as it only recognises EMRTOOL.INI}
     {if ControlRes^.fOldIni then
     begin
          ACopyFile(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME,
                    ControlRes^.sDatabase + '\' + INI_FILE_NAME);
          DeleteFile(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME);

          ControlRes^.fOldIni := False;
     end;}

     if ControlRes^.fOldIni then
     begin
          ACopyFile(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME,
                    ControlRes^.sDatabase + '\' +
                    Copy(OLD_INI_FILE_NAME,1,Length(OLD_INI_FILE_NAME)-3) + '~IN');

          MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME);
     end
     else
     begin
          ACopyFile(ControlRes^.sDatabase + '\' + INI_FILE_NAME,
                    ControlRes^.sDatabase + '\' +
                    Copy(INI_FILE_NAME,1,Length(INI_FILE_NAME)-3) + '~IN');

          MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
     end;

     with MyIni do
     begin
          EraseSection('Options');

          {WriteBool('Options','UpdateBaseLayer',fEMRLayerOn);
          WriteBool('Options','UpdateTopLayer',fStatusLayerOn);}
          WriteString('Options','SiteSummaryTable',ControlRes^.sSiteSummaryTable);
          WriteString('Options','Key',ControlRes^.sKeyField);

          if (ControlRes^.sShpTable <> '') then
             WriteString('Options','ShapeTable',ControlRes^.sShpTable);

          EraseSection('Available Fields');

          EraseSection('Tool View');
          EraseSection('Tool Bar');
          EraseSection('Extended Functions');

          EraseSection('Hide');
     end;

     MyIni.Free;
     ReLoadIni(self);
     fIniChange := False;
end;

procedure TControlForm.RestoreDefaultOptions1Click(Sender: TObject);
begin
     RestoreDefaultOptions;
end;

procedure TControlForm.SaveOptions1Click(Sender: TObject);
begin
     SaveIni(self,'');
     fIniChange := False;
end;

procedure TControlForm.ArcViewDDEForm1Click(Sender: TObject);
begin
     {$IFDEF VER90}
     AVDDEForm.ShowModal;
     {$ENDIF}
end;

procedure TControlForm.LabelNeMa;
var
   iItemIndex, iInsert, iPos : integer;
   sItemIndex : string;
begin
     Negotiated1.Caption := ControlRes^.sR1Label;
     Negotiated2.Caption := ControlRes^.sR1Label;
     Negotiated5.Caption := ControlRes^.sR1Label;
     Negotiated6.Caption := ControlRes^.sR1Label;
     Negotiated3.Caption := ControlRes^.sR1Label;
     Negotiated4.Caption := ControlRes^.sR1Label;

     HideMandatory1.Caption := ControlRes^.sR2Label;
     Mandatory2.Caption := ControlRes^.sR2Label;
     Mandatory3.Caption := ControlRes^.sR2Label;
     Mandatory1.Caption := ControlRes^.sR2Label;
     Mandatory6.Caption := ControlRes^.sR2Label;
     Mandatory4.Caption := ControlRes^.sR2Label;
     Mandatory5.Caption := ControlRes^.sR2Label;

     HideMandatory1.Visible := ControlRes^.fR2Visible;
     Mandatory2.Visible := ControlRes^.fR2Visible;
     Mandatory3.Visible := ControlRes^.fR2Visible;
     Mandatory1.Visible := ControlRes^.fR2Visible;
     Mandatory6.Visible := ControlRes^.fR2Visible;
     Mandatory4.Visible := ControlRes^.fR2Visible;
     Mandatory5.Visible := ControlRes^.fR2Visible;

     DeferredNeMaPd1.Caption := 'Selected not including Partial';
     Deferred1.Caption := 'Selected including Partial';
     DeferredNeMa1.Caption := 'Selected not including Partial';
     DeferredNeMaPd2.Caption := 'Selected including Partial';

     sItemIndex := ClickGroup.Items.Strings[ClickGroup.ItemIndex];
     ClickGroup.Items.Delete(3);
     ClickGroup.Items.Insert(3,ControlRes^.sR1Label);

     iInsert := 4;
     if (ControlRes^.sR2Label <> '') then
     begin
          // delete label if already in list
          iPos := ClickGroup.Items.IndexOf(ControlRes^.sR2Label);
          if (iPos <> -1) then
             ClickGroup.Items.Delete(iPos);
          ClickGroup.Items.Insert(iInsert,ControlRes^.sR2Label);
          Inc(iInsert);
     end;
     if (ControlRes^.sR3Label <> '') then
     begin
          // delete label if already in list
          iPos := ClickGroup.Items.IndexOf(ControlRes^.sR3Label);
          if (iPos <> -1) then
             ClickGroup.Items.Delete(iPos);
          ClickGroup.Items.Insert(iInsert,ControlRes^.sR3Label);
          Inc(iInsert);
     end;
     if (ControlRes^.sR4Label <> '') then
     begin
          // delete label if already in list
          iPos := ClickGroup.Items.IndexOf(ControlRes^.sR4Label);
          if (iPos <> -1) then
             ClickGroup.Items.Delete(iPos);
          ClickGroup.Items.Insert(iInsert,ControlRes^.sR4Label);
          Inc(iInsert);
     end;
     if (ControlRes^.sR5Label <> '') then
     begin
          // delete label if already in list
          iPos := ClickGroup.Items.IndexOf(ControlRes^.sR5Label);
          if (iPos <> -1) then
             ClickGroup.Items.Delete(iPos);
          ClickGroup.Items.Insert(iInsert,ControlRes^.sR5Label);
          Inc(iInsert);
     end;

     iItemIndex := ClickGroup.Items.IndexOf(sItemIndex);
     if (iItemIndex <> -1) then
        iItemIndex := 0;
     ClickGroup.ItemIndex := iItemIndex;

     SelectedLabel.Caption := ControlRes^.sR1Label + ' Sites';
     MandatoryLabel.Caption := ControlRes^.sR2Label + ' Sites';

     if ControlRes^.fR3Visible then
     begin
          a_R3.Caption := ControlRes^.sR3Label;
          b_R3.Caption := ControlRes^.sR3Label;
          c_R3.Caption := ControlRes^.sR3Label;
          d_R3.Caption := ControlRes^.sR3Label;
     end;
     a_R3.Visible := ControlRes^.fR3Visible;
     b_R3.Visible := ControlRes^.fR3Visible;
     c_R3.Visible := ControlRes^.fR3Visible;
     d_R3.Visible := ControlRes^.fR3Visible;
     if ControlRes^.fR4Visible then
     begin
          a_R4.Caption := ControlRes^.sR4Label;
          b_R4.Caption := ControlRes^.sR4Label;
          c_R4.Caption := ControlRes^.sR4Label;
          d_R4.Caption := ControlRes^.sR4Label;
     end;
     a_R4.Visible := ControlRes^.fR4Visible;
     b_R4.Visible := ControlRes^.fR4Visible;
     c_R4.Visible := ControlRes^.fR4Visible;
     d_R4.Visible := ControlRes^.fR4Visible;
     if ControlRes^.fR5Visible then
     begin
          a_R5.Caption := ControlRes^.sR5Label;
          b_R5.Caption := ControlRes^.sR5Label;
          c_R5.Caption := ControlRes^.sR5Label;
          d_R5.Caption := ControlRes^.sR5Label;
     end;
     a_R5.Visible := ControlRes^.fR5Visible;
     b_R5.Visible := ControlRes^.fR5Visible;
     c_R5.Visible := ControlRes^.fR5Visible;
     d_R5.Visible := ControlRes^.fR5Visible;
end;

procedure TControlForm.FormShow(Sender: TObject);
begin
     if ControlRes^.fSizeControl then
     begin
          ControlForm.Top := ControlRes^.iControlTop;
          ControlForm.Left := ControlRes^.iControlLeft;
          ControlForm.Height := ControlRes^.iControlHeight;
          ControlForm.Width := ControlRes^.iControlWidth;

          if (ControlForm.Left > 500) then
             ControlForm.Left := 500;

          if (ControlForm.Top > 500) then
             ControlForm.Top := 500;

          ControlRes^.fSizeControl := False;
     end;

     LabelNeMa;
end;

procedure TControlForm.IterateTillSatisfied1Click(Sender: TObject);
begin
     {$IFDEF VER90}
     IterateTillSatisfied('SUMIRR','IRREPL');
     {$ENDIF}
end;

procedure TControlForm.HidePartial1Click(Sender: TObject);
begin
     if HidePartial1.Checked then
     begin
          {un-hide par}
          EnablePartial;
          HidePartial1.Checked := False;
          ParGroup.Visible := True;
     end
     else
     begin
         {hide par}
         DisablePartial;
         HidePartial1.Checked := True;
         ParGroup.Visible := False;
     end;

     CheckParEmpty;

     fIniChange := True;

     FitComponents2Form;

end;

procedure TControlForm.HideExcluded1Click(Sender: TObject);
begin
     if HideExcluded1.Checked then
     begin
          {un-hide exc}
          EnableExcluded;
          HideExcluded1.Checked := False;
     end
     else
     begin
          {hide exc}
          DisableExcluded;
          HideExcluded1.Checked := True;
     end;

     fIniChange := True;

     FitComponents2Form;
end;

procedure TControlForm.SaveSiteGEOCODE1Click(Sender: TObject);
begin
     Screen.Cursor := crHourglass;

     SaveSiteText.InitialDir := ControlRes^.sWorkingDirectory;
     SaveSiteText.Title := 'Save Site KEY File';
     SaveSiteText.FileName := '';

     if SaveSiteText.Execute then
        SaveHighlight(SaveSiteText.FileName,LOAD_GEOCODE,TRUE);

     Screen.Cursor := crDefault;
end;

procedure TControlForm.SaveToFileNAME1Click(Sender: TObject);
begin
     Screen.Cursor := crHourglass;

     SaveSiteText.InitialDir := ControlRes^.sWorkingDirectory;
     SaveSiteText.Title := 'Save Site NAME File';
     SaveSiteText.FileName := '';

     if SaveSiteText.Execute then
        SaveHighlight(SaveSiteText.FileName,LOAD_NAME,TRUE);

     Screen.Cursor := crDefault;
end;

procedure TControlForm.TargetPercentMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   fStop : boolean;
   iNew : integer;
begin
     if not UseFeatCutOffs.Checked then
        if not ControlRes^.fStarting then
        begin
             fStop := False;
             {change percentage target}
             try
                PCTargForm := TPCTargForm.Create(Application);
                if (mrCancel = PCTargForm.ShowModal) then
                   fStop := True;
             finally
                    PCTargForm.Free;
             end;

             if not fStop then
             begin
                  ReInitializeInitialValues(TargetChange);

                  ExecuteIrreplaceability(-1,False,False,True,True,'');

                  fIniChange := True;
             end;
        end;
end;

procedure TControlForm.toTarget1Click(Sender: TObject);
begin
     try
        iReportFlag := RPT_MATRIX_PTT;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;
end;

procedure TControlForm.Area1Click(Sender: TObject);
begin
     try
        iReportFlag := RPT_MATRIX;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;
end;

procedure TControlForm.PartialStatus1Click(Sender: TObject);
begin
     try
        iReportFlag := RPT_MATRIX_PAR;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;
end;

procedure TControlForm.FeatureIrrep1Click(Sender: TObject);
begin
     try
        iReportFlag := RPT_MATRIX_IRR;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;
end;

procedure TControlForm.mins1Click(Sender: TObject);
begin
     try
        MinsetForm := TMinsetForm.Create(Application);
        MinsetForm.ShowModal;
     finally
            MinsetForm.Free;
     end;
end;

procedure TControlForm.FeatureAmount1Click(Sender: TObject);
begin
     try
        iReportFlag := RPT_MATRIX_EXT;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;
end;

procedure TControlForm.PartialStatus2Click(Sender: TObject);
begin
     try
        iReportFlag := RPT_MATRIX_EXT_PAR;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;
end;

procedure TControlForm.FeatureIrreplaceability1Click(Sender: TObject);
begin
     try
        iReportFlag := RPT_MATRIX_EXT_IRR;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;
end;

procedure TControlForm.toTarget2Click(Sender: TObject);
begin
     try
        iReportFlag := RPT_MATRIX_EXT_PTT;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;
end;

procedure TControlForm.AllMatrixReports1Click(Sender: TObject);
begin
     try
        iReportFlag := RPT_MATRIX_ALL;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;
end;

procedure TControlForm.AllMatrixReports2Click(Sender: TObject);
begin
     try
        iReportFlag := RPT_MATRIX_EXT_ALL;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;
end;

procedure TControlForm.Reserved1Click(Sender: TObject);
begin
     UnHighlight(Reserved,fKeepHighlight);
end;

procedure TControlForm.Ignored1Click(Sender: TObject);
begin
     UnHighlight(Ignored,fKeepHighlight);
end;

procedure TControlForm.Negotiated5Click(Sender: TObject);
begin
     try
        iMinsetFlag := MINSET_R1;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure TControlForm.Mandatory1Click(Sender: TObject);
begin
     try
        iMinsetFlag := MINSET_R2;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure TControlForm.Negotiated6Click(Sender: TObject);
begin
     try
        iMinsetFlag := MINSET_UNR1;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure TControlForm.Mandatory6Click(Sender: TObject);
begin
     try
        iMinsetFlag := MINSET_UNR2;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure TControlForm.Partial5Click(Sender: TObject);
begin
     try
        iMinsetFlag := MINSET_UNPAR;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure TControlForm.DeferredNeMa1Click(Sender: TObject);
begin
     try
        iMinsetFlag := MINSET_UNR1R2R3R4R5;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure TControlForm.DeferredNeMaPd2Click(Sender: TObject);
begin
     try
        iMinsetFlag := MINSET_UNR1R2R3R4R5PD;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure TControlForm.SetWorkingDirectory1Click(Sender: TObject);
begin
     try
        WorkingDirForm := TWorkingDirForm.Create(Application);

        WorkingDirForm.EditPath.Text := ControlRes^.sWorkingDirectory;

        if (mrOk = WorkingDirForm.ShowModal)
        and (ControlRes^.sWorkingDirectory <> WorkingDirForm.EditPath.Text) then
        begin
             ControlRes^.sWorkingDirectory := WorkingDirForm.EditPath.Text;
             fIniChange := True;

             ForceDirectories(ControlRes^.sWorkingDirectory);
        end;

     finally
            WorkingDirForm.Free;
     end;
end;

procedure TControlForm.Map1Click(Sender: TObject);
begin
     try
        iMinsetFlag := MINSET_MAP;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure TControlForm.AddToMap1Click(Sender: TObject);
begin
     try
        iMinsetFlag := MINSET_ADD_TO_MAP;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure TControlForm.HideMandatory1Click(Sender: TObject);
begin
     if HideMandatory1.Checked then
     begin
          {un-hide Man}
          EnableMandatory;
          HideMandatory1.Checked := False;
          ManGroup.Visible := True;
     end
     else
     begin
         {hide Man}
         DisableMandatory;
         HideMandatory1.Checked := True;
         ManGroup.Visible := False;
     end;

     CheckManEmpty;

     fIniChange := True;

     FitComponents2Form;

end;

procedure TControlForm.ApplyFeatureClasses1Click(Sender: TObject);
var
   FormResult : TModalResult;
   iCount : integer;
begin
     try
        OrdClassForm := TOrdClassForm.Create(Application);
        if (OrdClassForm.FieldList.Items.Count > 0) then
        begin
             {we have some extra fields}

             // remove any accumulated fields from the site database
             CleanDatabase;

             if ControlRes^.fFeatureClassesApplied then
             begin
                  // highlight the previously chosen subset in the list
                  OrdClassForm.btnUsePreviousClass.Hint := OrdClassForm.btnUsePreviousClass.Hint +
                                                           ControlRes^.sFeatureClassField;

                  for iCount := 0 to (OrdClassForm.FieldList.Items.Count-1) do
                      if (ControlRes^.sFeatureClassField = OrdClassForm.FieldList.Items.Strings[iCount]) then
                         OrdClassForm.FieldList.ItemIndex := iCount;
             end
             else
             begin
                  // no feature in the list is highlighted (selected)
                  //OrdClassForm.btnUseClass.Enabled := False;
                  OrdClassForm.btnUsePreviousClass.Hint := OrdClassForm.btnUsePreviousClass.Hint +
                                                           'no class';
             end;

             FormResult := OrdClassForm.ShowModal;

             case FormResult of
                  mrOk :     // use class selected by user
                             with OrdClassForm.FieldList do
                             begin
                                  {user has chosen a field}
                                  if LoadOrdinalClass(Items.Strings[ItemIndex],ControlRes^.ClassDetail) then
                                  begin
                                       ControlRes^.fFeatureClassesApplied := True;
                                       ControlRes^.sFeatureClassField := Items.Strings[ItemIndex];

                                       // allow user to choose subset fields before running irrep
                                       EditUserSubsetChoices;
                                       ControlForm.S1.Visible := True;
                                       {run irreplaceability so the values will be updated for the newly
                                        selected feature class field}
                                       ExecuteIrreplaceability(-1,False,False,True,True,'');
                                  end;
                             end;
                  mrRetry :  // use no class
                             ControlRes^.fFeatureClassesApplied := False;
                  mrCancel : // use previous class
                             // do nothing
                             ;
             end;
        end
        else
            {there are no extra fields}
            MessageDlg('There are no Class fields in the Feature Summary Table',
                       mtInformation,[mbOk],0);

        OrdClassForm.Free;

     except
           MessageDlg('Exception in Apply Feature Classes',mtError,[mbOk],0);
     end;
end;

procedure TControlForm.IdentifyLowValueDeferrals1Click(Sender: TObject);
begin
     if ((R1.Items.Count + R2.Items.Count + R3.Items.Count + R4.Items.Count + R5.Items.Count) > 0) then
     try
        SiteValueForm := TSiteValueForm.Create(Application);
        SiteValueForm.ShowModal;

     finally
            SiteValueForm.Free;
     end
     else
         MessageDlg('You must select '+ControlRes^.sR1Label+', '+ControlRes^.sR2Label+', '+ControlRes^.sR3Label+', '+ControlRes^.sR4Label+' or '+ControlRes^.sR5Label+' sites to activate this function',
                    mtInformation,[mbOk],0);
end;

procedure TControlForm.AddSelectionsfromfile1Click(Sender: TObject);
var
   wTmp : word;
   fCancel, fCancelPressed,
   fRetainClass : boolean;
   sRetainClass : string;
begin
     {load choice file}
     fCancel := False;

     if fSelectionChange
     or fFlagSelectionChange then
     begin
          wTmp := MessageDlg
             ('Save changes before adding selections?',mtConfirmation,[mbYes,mbNo,mbCancel],0);
          case wTmp of
               mrYes : Save1Click(Self,fCancel,fCancelPressed);
               mrCancel : fCancel := True;
          end;
     end;

     if not fCancel then
     begin
        {EnableMandatory;
        EnableExcluded;
        EnablePartial;
        EnableFlagged;}

        if (OpenDialog.Filename = '') then
        begin
             OpenDialog.FileName := 'sample.log';
             OpenDialog.InitialDir := ControlRes^.sWorkingDirectory;
        end;

        OpenDialog.Title := 'Add Selections from LOG file';

        if OpenDialog.Execute then
        begin
             fRetainClass := ControlRes^.fFeatureClassesApplied;
             sRetainClass := ControlRes^.sFeatureClassField;

             fSelectionChange := True;
             {selections will need to be saved after adding selections}

             fContrDataDone := False;
             {data in contribution objects needs to be updated}

             AddSelections(OpenDialog.FileName,False);
             LabelCountUpdate;
             CheckSelections;

             RePrepIrrepData;

             if fRetainClass then
             begin
                  if (mrYes = MessageDlg('Retain Feature Subset ' +
                                         sRetainClass,
                                         mtConfirmation,
                                         [mbYes,mbNo],0)) then
                  begin
                       LoadOrdinalClass(sRetainClass,ControLRes^.ClassDetail);
                       ControlRes^.fFeatureClassesApplied := True;
                       ControlRes^.sFeatureClassField := sRetainClass;
                  end;
             end;

             ExecuteIrreplaceability(-1,False,False,True,True,'');

             SaveDialog.Filename := ExtractFileName(OpenDialog.Filename);
             SaveDialog.InitialDir := ExtractFilePath(OpenDialog.Filename);
        end;
     end;
end;

procedure TControlForm.LaunchTableEditor1Click(Sender: TObject);
begin
     //if not RunCPlanApp('table_ed','') then
     if not RunCPlanApp('database_tool','') then
        MessageDlg('Cannot find Table Editor Utility',mtInformation,[mbOk],0);
end;

function TControlForm.CheckTenure : boolean;
var
   pSite : sitepointer;
   fFail : boolean;

   procedure IterateItems(Box : TListBox;
                          const Tenure : Tenure_T);
   var
      iCount, iSiteIndex : integer;
   begin
        {}
        if (Box.Items.Count > 0) then
        try
           for iCount := 0 to (Box.Items.Count - 1) do
           begin
                iSiteIndex := FindFeatMatch(OrdSiteArr,StrToInt(Box.Items.Strings[iCount]));
                SiteArr.rtnValue(iSiteIndex,pSite);

                case Tenure of
                     Ava : if ((pSite^.status = Ig) or
                               (pSite^.status = Re)) then
                              fFail := True;
                     Ign : if (pSite^.status <> Ig) then
                              fFail := True;
                     Res : if (pSite^.status <> Re) then
                              fFail := True;
                end;
           end;

        except
              MessageDlg('Exception in IterateItems',mtError,[mbOk],0);
        end;
   end;

begin
     // True means tenure is ok
     // False means tenure is invalid
     Result := True;

     {check each;
              Avaiable, Flagged,
              Negotiated, Mandatory, Partially Deferred, Excluded,
              Ignored, Reserved}
     try
        fFail := False;
        new (pSite);

        IterateItems(AvailableKey,Ava);
        IterateItems(FlaggedKey,Ava);
        IterateItems(R1Key,Ava);
        IterateItems(R2Key,Ava);
        IterateItems(R3Key,Ava);
        IterateItems(R4Key,Ava);
        IterateItems(R5Key,Ava);
        IterateItems(PartialKey,Ava);
        IterateItems(ExcludedKey,Ava);

        IterateItems(IgnoredKey,Ign);
        IterateItems(ReservedKey,Res);

        dispose (pSite);

        if fFail then
        begin
             {tenure failed}
             // MessageDlg('Error in tenure of selections (invalid EMS file loaded) Terminating',mtError,[mbOk],0);
             // DestroyControlForm(True);
             Result := False;
        end;

     except
           MessageDlg('Exception in CheckTenure',mtError,[mbOk],0);
     end;
end;

procedure TControlForm.CheckTenureOfSelections1Click(Sender: TObject);
begin
     CheckTenure;
end;

procedure TControlForm.Lookup1Click(Sender: TObject);
begin
     {minset lookup function}
     try
        iMinsetFlag := MINSET_LOOKUP;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure TControlForm.Default2Click(Sender: TObject);
var
   wOldCursor : integer;
   sFile, sDescr : string;
begin
     {generate Default site report}

     Screen.Cursor := crHourglass;

     if not fContrDataDone then
        ExecuteIrreplaceability(-1,False,False,True,True,'');

     Screen.Cursor := crDefault;

     try
        iReportFlag := RPT_IRREPL;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;

     Screen.Cursor := crDefault;
end;

procedure TControlForm.Default1Click(Sender: TObject);
var
   wOldCursor : integer;
   sFile, sDescr : string;
begin
     {generate default feature report}

     try
        iReportFlag := RPT_TARGETS;

        CombRunForm := TCombRunForm.Create(Application);

        CombRunForm.ShowModal;

     finally
            CombRunForm.Free;
     end;

     Screen.Cursor := crDefault;
end;

procedure TControlForm.UseDLL1Click(Sender: TObject);
begin
     try
        UseDLLForm := TUseDLLForm.Create(Application);
        UseDLLForm.ShowModal;
        UseDLLForm.Free;
     except

     end;
end;

procedure TControlForm.ReportSpatialConfig1Click(Sender: TObject);
begin
     if ControlRes^.fConnectedToSPATTOOL
     and (ControlRes^.iFeaturesWithPATCHCON > 0)  then
     begin
          //if (ControlForm.Negotiated.Items.Count > 0)
          //or (ControlForm.Mandatory.Items.Count > 0) then
             SpatIOModule.SendConfigRequest;
          //else
              //MessageDlg('There must be 1 or more Negotiated or Mandatory sites to activate this function.',mtInformation,[mbOk],0);
     end
     else
     begin
          if ControlRes^.fConnectedToSPATTOOL then
             MessageDlg('No features with PATCHCON so cannot do Spatial CONFIG.',mtInformation,[mbOk],0)
          else
              MessageDlg('Not connected to SPATTOOL so cannot do Spatial CONFIG.',mtInformation,[mbOk],0)
     end;
end;

procedure TControlForm.SpatialModule1Click(Sender: TObject);
begin
     try
        OptionsForm := TOptionsForm.Create(Application);

        OptionsForm.TabSet1.Visible := False;
        OptionsForm.Notebook1.PageIndex := 5;
        OptionsForm.Caption := 'Spatial Module Options';
        OptionsForm.ShowModal;

     finally
            OptionsForm.Free;
     end;    
end;

procedure TControlForm.SiteRptBlank1Click(Sender: TObject);
begin
     ProcessSiteRptClick(SiteRptBlank1.Caption);
end;

procedure TControlForm.SiteRptBlank2Click(Sender: TObject);
begin
     ProcessSiteRptClick(SiteRptBlank2.Caption);
end;

procedure TControlForm.SiteRptBlank3Click(Sender: TObject);
begin
     ProcessSiteRptClick(SiteRptBlank3.Caption);
end;

procedure TControlForm.SiteRptBlank4Click(Sender: TObject);
begin
     ProcessSiteRptClick(SiteRptBlank4.Caption);
end;

procedure TControlForm.SiteRptBlank5Click(Sender: TObject);
begin
     ProcessSiteRptClick(SiteRptBlank5.Caption);
end;

procedure TControlForm.SiteRptBlank6Click(Sender: TObject);
begin
     ProcessSiteRptClick(SiteRptBlank6.Caption);
end;

procedure TControlForm.SiteRptBlank7Click(Sender: TObject);
begin
     ProcessSiteRptClick(SiteRptBlank7.Caption);
end;

procedure TControlForm.SiteRptBlank8Click(Sender: TObject);
begin
     ProcessSiteRptClick(SiteRptBlank8.Caption);
end;

procedure TControlForm.SiteRptBlank9Click(Sender: TObject);
begin
     ProcessSiteRptClick(SiteRptBlank9.Caption);
end;

procedure TControlForm.SiteRptBlank10Click(Sender: TObject);
begin
     ProcessSiteRptClick(SiteRptBlank10.Caption);
end;

procedure TControlForm.FeatureRptBlank1Click(Sender: TObject);
begin
     ProcessFeatureRptClick(FeatureRptBlank1.Caption);
end;

procedure TControlForm.FeatureRptBlank2Click(Sender: TObject);
begin
     ProcessFeatureRptClick(FeatureRptBlank2.Caption);
end;

procedure TControlForm.FeatureRptBlank3Click(Sender: TObject);
begin
     ProcessFeatureRptClick(FeatureRptBlank3.Caption);
end;

procedure TControlForm.FeatureRptBlank4Click(Sender: TObject);
begin
     ProcessFeatureRptClick(FeatureRptBlank4.Caption);
end;

procedure TControlForm.FeatureRptBlank5Click(Sender: TObject);
begin
     ProcessFeatureRptClick(FeatureRptBlank5.Caption);
end;

procedure TControlForm.FeatureRptBlank6Click(Sender: TObject);
begin
     ProcessFeatureRptClick(FeatureRptBlank6.Caption);
end;

procedure TControlForm.FeatureRptBlank7Click(Sender: TObject);
begin
     ProcessFeatureRptClick(FeatureRptBlank7.Caption);
end;

procedure TControlForm.FeatureRptBlank8Click(Sender: TObject);
begin
     ProcessFeatureRptClick(FeatureRptBlank8.Caption);
end;

procedure TControlForm.FeatureRptBlank9Click(Sender: TObject);
begin
     ProcessFeatureRptClick(FeatureRptBlank9.Caption);
end;

procedure TControlForm.FeatureRptBlank10Click(Sender: TObject);
begin
     ProcessFeatureRptClick(FeatureRptBlank10.Caption);
end;

procedure TControlForm.ReportEMSFiles1Click(Sender: TObject);
begin
     BatchEMSForm := TBatchEMSForm.Create(Application);
     BatchEMSForm.ShowModal;
     BatchEMSForm.Free;
end;

procedure TControlForm.ReportSpatialSpread1Click(Sender: TObject);
begin
     if ControlRes^.fConnectedToSPATTOOL
     and (ControlRes^.iFeaturesWithSRADIUS > 0) then
     begin
          {if ControlRes^.fPrepareSpreadRun then
             SpatIOModule.SendSpreadRequest
          else}
              //SpatIOModule.SendPrepareSpreadRequest;

              SpatIOModule.ReceivePrepareSpreadResult;
     end
     else
     begin
          MessageDlg('No features with PATCHCON so cannot do Spatial CONFIG.',
                     mtInformation,[mbOk],0);
     end;
end;

procedure TControlForm.Stages1Click(Sender: TObject);
begin
     try
        ChoiceForm.SaveStageSelections;

        BatchEMSForm := TBatchEMSForm.Create(Application);
        //BatchEMSForm.SelectionFileBox.Items.LoadFromFile(ControlRes^.sWorkingDirectory + '\stages.txt');
        BatchEMSForm.ParseFromFile(ControlRes^.sWorkingDirectory + '\stages.txt');
        BatchEMSForm.Report;
        BatchEMSForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Report Stages',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TControlForm.SaveSparseMatrix1Click(Sender: TObject);
begin
     Screen.Cursor := crHourglass;

     {$IFDEF SPARSE_MATRIX}
     {$ELSE}
     SaveSparseBinMatrix;
     {$ENDIF}

     SaveSparseMatrix;

     Screen.Cursor := crDefault;
end;

procedure TControlForm.CombinationSizeOptions1Click(Sender: TObject);
var
   iAvailableSites, iSelectedSites, iValue : integer;
begin
     try
        fStartingOptionsForm := True;
        fStartingCombsizeOptionsForm := True;

        OptionsForm := TOptionsForm.Create(Application);

        with OptionsForm do
        begin
             iAvailableSites := ControlForm.Available.Items.Count +
                                ControlForm.Flagged.Items.Count;
             if ControlRes^.fSuppressCSExclusionRecalc then
                iSelectedSites := ControlForm.R1.Items.Count +
                                  ControlForm.R2.Items.Count +
                                  ControlForm.R3.Items.Count +
                                  ControlForm.R4.Items.Count +
                                  ControlForm.R5.Items.Count +
                                  ControlForm.Excluded.Items.Count +
                                  ControlForm.Partial.Items.Count
             else
                 iSelectedSites := ControlForm.R1.Items.Count +
                                   ControlForm.R2.Items.Count +
                                   ControlForm.R3.Items.Count +
                                   ControlForm.R4.Items.Count +
                                   ControlForm.R5.Items.Count +
                                   ControlForm.Partial.Items.Count;

             // set initial properties on the combination size options form
             EditOriginal.Text := IntToStr(combsize.iSelectedCombinationSize);
             //lblSelectedSites.Caption := IntToStr(iSelectedSites) +
             //                            ' sites are provisionally reserved';
             Memo1.Lines.Add('');
             Memo1.Lines.Add(IntToStr(ControlForm.R1.Items.Count +
                                   ControlForm.R2.Items.Count +
                                   ControlForm.R3.Items.Count +
                                   ControlForm.R4.Items.Count +
                                   ControlForm.R5.Items.Count +
                                   ControlForm.Partial.Items.Count) + ' sites are provisionally reserved');
             SpinCombSize.MaxValue := iAvailableSites +
                                      iSelectedSites;
             SpinCombSize.MinValue := 2;

             Notebook1.PageIndex := 6;
             TabSet1.Visible := False;
             Caption := 'Combination Size Options';

             if ControlRes^.fCustomCombSize then
             begin
                  RadioCombType.ItemIndex := 1;
                  if ControlRes^.fLockUserDefinedCombinationSize then
                     iValue := combsize.iCustomCombinationSize
                  else
                      iValue := combsize.iCustomCombinationSize -
                                iSelectedSites;

                  if (iValue < 2) then
                     EditCombSize.Text := 'less than 2'
                  else
                      EditCombSize.Text := IntToStr(iValue);
             end
             else
             begin
                  RadioCombType.ItemIndex := 0;
                  iValue := combsize.iSelectedCombinationSize - iSelectedSites;

                  if (iValue < 2) then
                     EditCombSize.Text := 'less than 2'
                  else
                      EditCombSize.Text := IntToStr(combsize.iSelectedCombinationSize - iSelectedSites);
             end;
             SpinCombSize.Value := combsize.iCustomCombinationSize;
             if (SpinCombSize.Value = 0) then
                SpinCombSize.Value := 2 + ((iAvailableSites-2) div 2);
             //fStartingOptionsForm := False;
             fStartingCombsizeOptionsForm := False;
             ShowModal;
        end;

        fStartingOptionsForm := False;

     finally
            OptionsForm.Free;
     end;
end;

procedure TControlForm.RandomSiteSelection1Click(Sender: TObject);
begin
     RandomSelectForm := TRandomSelectForm.Create(Application);
     RandomSelectForm.ShowModal;
     RandomSelectForm.Free;
end;

procedure TControlForm.Sites1Click(Sender: TObject);
begin
     // execute default site report
     Default2Click(Sender);
end;

procedure TControlForm.Features1Click(Sender: TObject);
begin
     // execute default feature report
     Default1Click(Sender);
end;

procedure TControlForm.S1Click(Sender: TObject);
begin
     EditUserSubsetChoices;
end;

procedure TControlForm.ClearSelections1Click(Sender: TObject);
var
   fCancel, fRetainClass, fCancelPressed : boolean;
   wTmp : integer;
   sRetainClass : string;
begin
     fCancel := False;

     if fSelectionChange
     or fFlagSelectionChange then
     begin
          wTmp := MessageDlg
             ('Save changes before clearing?',mtConfirmation,[mbYes,mbNo,mbCancel],0);
          case wTmp of
               mrYes : Save1Click(Self,fCancel,fCancelPressed);
               mrCancel : fCancel := True;
          end;
     end;

     if not fCancel then
     begin
          fRetainClass := ControlRes^.fFeatureClassesApplied;
          sRetainClass := ControlRes^.sFeatureClassField;

          fSelectionChange := False;
          fFlagSelectionChange := False;
          {selections do not need to be saved}
          fContrDataDone := False;
          {data in contribution objects needs to be updated}

          LoadSelections(ControlRes^.sDatabase + '\empty.log');
          LabelCountUpdate;

          RePrepIrrepData;

          if fRetainClass then
          begin
               if (mrYes = MessageDlg('Retain Feature Subset ' +
                                      sRetainClass,
                                      mtConfirmation,
                                      [mbYes,mbNo],0)) then
               begin
                    LoadOrdinalClass(sRetainClass,ControLRes^.ClassDetail);
                    ControlRes^.fFeatureClassesApplied := True;
                    ControlRes^.sFeatureClassField := sRetainClass;
               end
          end;

          ExecuteIrreplaceability(-1,False,False,True,True,'');

          SaveDialog.Filename := ExtractFileName(OpenDialog.Filename);
          SaveDialog.InitialDir := ExtractFilePath(OpenDialog.Filename);

     end;
end;

procedure TControlForm.AddStageToSHPFile1Click(Sender: TObject);
begin
     if (ControlRes^.GisLink = ArcView) then
     begin
          // add stage to SHP file

          // 1. ask user for a name for the field
          // 2. add relevant field to SHP file (go back to step 1 if the field already exists
          // 3. populate relevant field with status vector
     end
     else
     begin
          // no GIS link, cannot add stage
          MessageDlg('C-Plan is not linked to ArcView, so you cannot add a stage.',mtInformation,[mbOk],0);
     end;
end;

function Start_SF_Predictor(const iSites, iFeatures : integer) : boolean;
var
   sParam : string;
begin
     // paramaters are :
     //   combination size
     //   site count
     //   feature count

     //   matrix & target & output & sync file name are determined by the program

     sParam := IntToStr(combsize.iActiveCombinationSize) +  ' ' +
               IntToStr(iSites) + ' ' +
               IntToStr(iFeatures);

     Result := RunCPlanApp('sf32bit',sParam);
end;

procedure CountSitesAndFeatures(var iSites, iFeatures : integer);
var
   iSCount, iFCount, iIndex : integer;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   Value : ValueFile_T;
   sPath : string;

   function SiteHasFeaturesUnderTarget : boolean;
   var
      iCount : integer;
   begin
        Result := False;
        {if (pSite^.richness > 0) then}
        for iCount := 1 to pSite^.richness do
        begin
             FeatureAmount.rtnValue(pSite^.iOffset + iCount,@Value);
             FeatArr.rtnValue(Value.iFeatKey,pFeat);
             if (pFeat^.targetarea > 0) then
                // this site has a feature below target
                Result := True;
        end;
   end;

begin
     //
     try
        new(pSite);
        new(pFeat);

        sPath := ExtractFilePath(Application.ExeName);

        // count features under target
        iFeatures := 0;
        for iFCount := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iFCount,pFeat);
             if (pFeat^.targetarea > 0) then
                Inc(iFeatures);
        end;

        if (iFeatures > 0) then
        begin
             // count available sites containing features under target
             iSites := 0;
             for iSCount := 1 to iSiteCount do
             begin
                  SiteArr.rtnValue(iSCount,pSite);
                  if ((pSite^.status = Av)
                      or (pSite^.status = Fl))
                  and (pSite^.richness > 0) then
                      if SiteHasFeaturesUnderTarget then
                         Inc(iSites);
             end;
        end;

        dispose(pSite);
        dispose(pFeat);

     except
     end;
end;

procedure ProduceSFDebugReport(const iSites, iFeatures : integer);
var
   PassedCombFile, SelectCombFile, ReportFile : textfile;
   //MatrixFile, TargetFile, SiteKeyFile, FeatKeyFile : textfile;
   iSCount, iFCount, iIndex, iPos : integer;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   Value : ValueFile_T;
   sPath, sPass, sPass1, sPass2, sSelect, sSelect1, sSelect2 : string;

   function SiteHasFeaturesUnderTarget : boolean;
   var
      iCount : integer;
   begin
        Result := False;
        if (pSite^.richness > 0) then
           for iCount := 1 to pSite^.richness do
           begin
                FeatureAmount.rtnValue(pSite^.iOffset + iCount,@Value);
                FeatArr.rtnValue(Value.iFeatKey,pFeat);
                if (pFeat^.targetarea > 0) then
                   // this site has a feature below target
                   Result := True;
           end;
   end;

   function IndexOfFeatureAtSite : integer;
   var
      iCount : integer;
   begin
        Result := 0;
        for iCount := 1 to pSite^.richness do
        begin
             FeatureAmount.rtnValue(pSite^.iOffset + iCount,@Value);
             if (iFCount = Value.iFeatKey) then
                Result := iCount;
        end;
   end;

begin
     //
     try
        new(pSite);
        new(pFeat);

        sPath := ExtractFilePath(Application.ExeName);

        assignfile(PassedCombFile,sPath + '\' +
                                  IntToStr(iSites) + 'x' +
                                  IntToStr(iFeatures) + '_passed_combsize.csv');
        assignfile(SelectCombFile,sPath + '\' +
                                  IntToStr(iSites) + 'x' +
                                  IntToStr(iFeatures) + '_selected_combsize.csv');
        assignfile(ReportFile,sPath + '\' +
                              IntToStr(iSites) + 'x' +
                              IntToStr(iFeatures) + '_validation_report.csv');
        reset(PassedCombFile);
        readln(PassedCombFile);
        reset(SelectCombFile);
        readln(SelectCombFile);
        rewrite(ReportFile);
        writeln(ReportFile,'SiteKey,Irrep,Sumirr,SFpass_combIrr,SFpass_combSum,SFselect_combIrr,SFselect_combSum');

        // write matrix file and site key file
        for iSCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iSCount,pSite);
             if ((pSite^.status = Av)
                 or (pSite^.status = Fl))
             and SiteHasFeaturesUnderTarget then
             begin
                  readln(PassedCombFile,sPass);
                  iPos := Pos(',',sPass);
                  sPass := Copy(sPass,iPos+1,Length(sPass)-iPos);
                  iPos := Pos(',',sPass);
                  sPass1 := Copy(sPass,1,iPos-1);
                  sPass2 := Copy(sPass,iPos+1,Length(sPass)-iPos);

                  readln(SelectCombFile,sSelect);
                  iPos := Pos(',',sSelect);
                  sSelect := Copy(sSelect,iPos+1,Length(sSelect)-iPos);
                  iPos := Pos(',',sSelect);
                  sSelect1 := Copy(sSelect,1,iPos-1);
                  sSelect2 := Copy(sSelect,iPos+1,Length(sSelect)-iPos);

                  // display the value for this site
                  writeln(ReportFile,IntToStr(pSite^.iKey) + ',' +
                                     FloatToStr(pSite^.rIrreplaceability) + ',' +
                                     FloatToStr(pSite^.rSummedIrr) + ',' +
                                     sPass1  + ',' +
                                     sPass2  + ',' +
                                     sSelect1  + ',' +
                                     sSelect2);
             end
             else
                 // display zero values because this site is not available
                 writeln(ReportFile,IntToStr(pSite^.iKey) + ',0,0,0,0,0,0');
        end;

        closefile(PassedCombFile);
        closefile(SelectCombFile);
        closefile(ReportFile);

        dispose(pSite);
        dispose(pFeat);

     except
     end;
end;


function Produce_SF_Validation_Matrix(var iSites, iFeatures : integer) : boolean;
var
   MatrixFile, TargetFile, SiteKeyFile, FeatKeyFile : textfile;
   iSCount, iFCount, iIndex : integer;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   Value : ValueFile_T;
   sPath : string;

   function SiteHasFeaturesUnderTarget : boolean;
   var
      iCount : integer;
   begin
        Result := False;
        for iCount := 1 to pSite^.richness do
        begin
             FeatureAmount.rtnValue(pSite^.iOffset + iCount,@Value);
             FeatArr.rtnValue(Value.iFeatKey,pFeat);
             if (pFeat^.targetarea > 0) then
                // this site has a feature below target
                Result := True;
        end;
   end;

   function IndexOfFeatureAtSite : integer;
   var
      iCount : integer;
   begin
        Result := 0;
        for iCount := 1 to pSite^.richness do
        begin
             FeatureAmount.rtnValue(pSite^.iOffset + iCount,@Value);
             if (iFCount = Value.iFeatKey) then
                Result := iCount;
        end;
   end;

begin
     //
     try
        Result := True;
        new(pSite);
        new(pFeat);

        CountSitesAndFeatures(iSites,iFeatures);

        if (iFeatures = 0) then
           Result := False
        else
        begin
             sPath := ExtractFilePath(Application.ExeName);

             assignfile(MatrixFile,sPath + '\' +
                               IntToStr(iSites) + 'x' +
                               IntToStr(iFeatures) + 'matrix.txt');
             rewrite(MatrixFile);
             assignfile(TargetFile,sPath + '\' +
                               IntToStr(iSites) + 'x' +
                               IntToStr(iFeatures) + 'target.txt');
             rewrite(TargetFile);
             assignfile(SiteKeyFile,sPath + '\' +
                                IntToStr(iSites) + 'x' +
                                IntToStr(iFeatures) + 'sitekey.txt');
             rewrite(SiteKeyFile);
             assignfile(FeatKeyFile,sPath + '\' +
                                IntToStr(iSites) + 'x' +
                                IntToStr(iFeatures) + 'featkey.txt');
             rewrite(FeatKeyFile);

             // write feature targets and keys of features under target
             for iFCount := 1 to iFeatureCount do
             begin
                  FeatArr.rtnValue(iFCount,pFeat);
                  if (pFeat^.targetarea > 0) then
                  begin
                       writeln(TargetFile,FloatToStr(pFeat^.targetarea));
                       writeln(FeatKeyFile,IntToStr(iFCount));
                  end;
             end;

             // write matrix file and site key file
             for iSCount := 1 to iSiteCount do
             begin
                  SiteArr.rtnValue(iSCount,pSite);
                  if ((pSite^.status = Av)
                      or (pSite^.status = Fl))
                  and (pSite^.richness > 0) then
                      if SiteHasFeaturesUnderTarget then
                      begin
                           for iFCount := 1 to iFeatureCount do
                           begin
                                iIndex := IndexOfFeatureAtSite;
                                if (iIndex > 0) then
                                begin
                                     FeatureAmount.rtnValue(pSite^.iOffset + iIndex,@Value);

                                     write(MatrixFile,' ' + FloatToStr(Value.rAmount));
                                end
                                else
                                    write(MatrixFile,' 0');
                           end;

                           writeln(MatrixFile);
                           writeln(SiteKeyFile,IntToStr(pSite^.iKey));
                      end;
             end;

             closefile(MatrixFile);
             closefile(TargetFile);
             closefile(SiteKeyFile);
             closefile(FeatKeyFile);
        end;

        dispose(pSite);
        dispose(pFeat);

     except
     end;
end;

procedure TControlForm.ProduceSFvalidationmatrix1Click(Sender: TObject);
var
   iSites, iFeatures : integer;
begin
     // Produce a matrix that can be loaded into simon ferriers irreplaceability
     // program that replicates the current conditions in the matrix
     try
        Screen.Cursor := crHourglass;

        if Produce_SF_Validation_Matrix(iSites,iFeatures) then
        begin
             // call simons predictor program with command line inputs
             if Start_SF_Predictor(iSites,iFeatures) then
                // start a timer
                // (which will check when the sync file has been created then read and process the results)
             begin
                  iSFTimerSites := iSites;
                  iSFTimerFeatures := iFeatures;

                  SFTimer.Enabled := True;
             end;
        end
        else
            MessageDlg('There are no features under target',mtInformation,[mbOk],0);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in SF validation',mtError,[mbOk],0);
     end;
end;

procedure TControlForm.MapRedundantSites1Click(Sender: TObject);
begin
     MapRedundancyCheck;
end;

procedure TControlForm.SFTimerTimer(Sender: TObject);
begin
     // check if file has been created
     if FileExists(ExtractFilePath(Application.ExeName) +
                   IntToStr(iSFTimerSites) + 'x' +
                   IntToStr(iSFTimerFeatures) + 'sync') then
     begin
          // process has finished
          SFTimer.Enabled := False;
          // analyse the results and create a csv report and display it in the table editor
          ProduceSFDebugReport(iSFTimerSites,iSFTimerFeatures);

          // display report in the table editor
          RunCPlanApp('table_ed',
                      '"' + ExtractFilePath(Application.ExeName) +
                            IntToStr(iSFTimerSites) + 'x' +
                            IntToStr(iSFTimerFeatures) + '_validation_report.csv"');
     end;
end;

procedure TControlForm.Validate1Click(Sender: TObject);
begin
     try
        OptionsForm := TOptionsForm.Create(Application);

        OptionsForm.TabSet1.TabIndex := 4;
        OptionsForm.ShowModal;

     finally
            OptionsForm.Free;
     end;      
end;

procedure TControlForm.FastMinset1Click(Sender: TObject);
begin
     FastMinsetForm := TFastMinsetForm.Create(Application);
     FastMinsetForm.ShowModal;
     FastMinsetForm.Free;
end;

procedure TControlForm.LaunchTableEditorOldVersion1Click(Sender: TObject);
begin
     if not RunCPlanApp('table_ed','') then
        MessageDlg('Cannot find Table Editor Utility',mtInformation,[mbOk],0);
end;

procedure TControlForm.ReplacementSites1Click(Sender: TObject);
begin
     FindReplacementSites;
     FindReplacementSitesAllAv(ControlRes^.sWorkingDirectory + '\ReplacementSiteCount.csv',
                               ControlRes^.sWorkingDirectory + '\ReplacementSiteKeys.csv',
                               true,false);
end;

procedure TControlForm.SendPrepareSpread1Click(Sender: TObject);
begin
     if ControlRes^.fConnectedToSPATTOOL
     and (ControlRes^.iFeaturesWithSRADIUS > 0) then
     begin
          SpatIOModule.SendPrepareSpreadRequest;
     end
     else
     begin
          MessageDlg('No features with PATCHCON so cannot do Spatial CONFIG.',
                     mtInformation,[mbOk],0);
     end;
end;

procedure TControlForm.TargetProgress1Click(Sender: TObject);
begin
     LineGraphForm := TLineGraphForm.Create(Application);
     LineGraphForm.ShowModal;
     LineGraphForm.Free;
end;

procedure TControlForm.CPlanFeatureIndexCFI1Click(Sender: TObject);
begin
     ReportMeasure2Form := TReportMeasure2Form.Create(Application);
     ReportMeasure2Form.ShowModal;
     ReportMeasure2Form.Free;
end;

procedure TControlForm.FeatureInfo1Click(Sender: TObject);
begin
     Visible := False;

     DisplayFeaturesForm := TDisplayFeaturesForm.Create(Application);
     DisplayFeaturesForm.ShowModal;
     try
        DisplayFeaturesForm.Free;
     except
     end;

     Visible := True;
end;

procedure TControlForm.SiteInfo1Click(Sender: TObject);
begin
     Visible := False;

     DisplaySitesForm := TDisplaySitesForm.Create(Application);
     DisplaySitesForm.ShowModal;
     try
        DisplaySitesForm.Free;
     except
     end;

     Visible := True;
end;

procedure TControlForm.OpenLOGfilepreversion351Click(Sender: TObject);
var
   wTmp : word;
   fCancel, fCancelPressed,
   fRetainClass : boolean;
   sRetainClass : string;
begin
     {load choice file}
     fCancel := False;

     if fSelectionChange
     or fFlagSelectionChange then
     begin
          wTmp := MessageDlg
             ('Save changes before load?',mtConfirmation,[mbYes,mbNo,mbCancel],0);
          case wTmp of
               mrYes : Save1Click(Self,fCancel,fCancelPressed);
               mrCancel : fCancel := True;
          end;
     end;

     if not fCancel then
     begin
          OpenDialog.FileName := 'sample.log';
          OpenDialog.InitialDir := ControlRes^.sWorkingDirectory;

          OpenDialog.Title := 'Open Version 3.X Selection File';

          if OpenDialog.Execute then
          begin
               fRetainClass := ControlRes^.fFeatureClassesApplied;
               sRetainClass := ControlRes^.sFeatureClassField;

               fSelectionChange := False;
               fFlagSelectionChange := False;
               {selections do not need to be saved}
               fContrDataDone := False;
               {data in contribution objects needs to be updated}

               LoadSelections(OpenDialog.FileName);
               if not CheckSelections then
               begin
                    //
                    LoadSelections(ControlRes^.sDatabase + '\empty.log');
                    AddSelections(OpenDialog.FileName,True);
               end;
               LabelCountUpdate;

               RePrepIrrepData;

               // if there are excluded items, recalculate combination size here
               if (Excluded.Items.Count > 0) then
                  ReInitializeInitialValues(ExclusionChange);

               if fRetainClass then
               begin
                    if (mrYes = MessageDlg('Retain Feature Subset ' +
                                           sRetainClass,
                                           mtConfirmation,
                                           [mbYes,mbNo],0)) then
                    begin
                         LoadOrdinalClass(sRetainClass,ControLRes^.ClassDetail);
                         ControlRes^.fFeatureClassesApplied := True;
                         ControlRes^.sFeatureClassField := sRetainClass;
                    end
               end;

               ExecuteIrreplaceability(-1,False,False,True,True,'');

               SaveDialog.Filename := ExtractFileName(OpenDialog.Filename);
               SaveDialog.InitialDir := ExtractFilePath(OpenDialog.Filename);
          end;
     end;
end;

procedure TControlForm.a_r3Click(Sender: TObject);
begin
     RunSQL(SQL_R3);     
end;

procedure TControlForm.a_r4Click(Sender: TObject);
begin
     RunSQL(SQL_R4);
end;

procedure TControlForm.a_r5Click(Sender: TObject);
begin
     RunSQL(SQL_R5);
end;

procedure TControlForm.b_r3Click(Sender: TObject);
begin
     RunSQL(SQL_UNR3);
end;

procedure TControlForm.b_r4Click(Sender: TObject);
begin
     RunSQL(SQL_UNR4);
end;

procedure TControlForm.b_r5Click(Sender: TObject);
begin
     RunSQL(SQL_UNR5);
end;

procedure TControlForm.c_r3Click(Sender: TObject);
begin
     try
        iMinsetFlag := MINSET_R3;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure TControlForm.c_r4Click(Sender: TObject);
begin
     try
        iMinsetFlag := MINSET_R4;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure TControlForm.c_r5Click(Sender: TObject);
begin
     try
        iMinsetFlag := MINSET_R5;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure TControlForm.d_r3Click(Sender: TObject);
begin
     try
        iMinsetFlag := MINSET_UNR3;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure TControlForm.d_r4Click(Sender: TObject);
begin
     try
        iMinsetFlag := MINSET_UNR4;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure TControlForm.d_r5Click(Sender: TObject);
begin
     try
        iMinsetFlag := MINSET_UNR5;
        RulesForm := TRulesForm.Create(Application);
        RulesForm.ShowModal;
     finally
            RulesForm.Free;
     end;
end;

procedure _DisplayWarnings;
begin
     //
     DisplayWarningsForm := TDisplayWarningsForm.Create(Application);
     DisplayWarningsForm.ShowModal;
     DisplayWarningsForm.Free;
end;

procedure TControlForm.DisplayWarningsClick(Sender: TObject);
begin
     // display warnings form
     if (Warnings.Items.Count > 0) then
        _DisplayWarnings
     else
         MessageDlg('There are no warnings.',mtInformation,[mbOk],0);
end;

procedure TControlForm.OpenSelectionsolderversions1Click(Sender: TObject);
var
   wTmp : word;
   fCancel, fCancelPressed,
   fRetainClass : boolean;
   sRetainClass : string;
begin
     {load choice file}
     fCancel := False;

     if fSelectionChange
     or fFlagSelectionChange then
     begin
          wTmp := MessageDlg
             ('Save changes before load?',mtConfirmation,[mbYes,mbNo,mbCancel],0);
          case wTmp of
               mrYes : Save1Click(Self,fCancel,fCancelPressed);
               mrCancel : fCancel := True;
          end;
     end;

     if not fCancel then
     begin
          OpenDialog.FileName := 'sample.log';
          OpenDialog.InitialDir := ControlRes^.sWorkingDirectory;

          OpenDialog.Title := 'Open Selection File';

          if OpenDialog.Execute then
          begin
               fRetainClass := ControlRes^.fFeatureClassesApplied;
               sRetainClass := ControlRes^.sFeatureClassField;

               fSelectionChange := False;
               fFlagSelectionChange := False;
               {selections do not need to be saved}
               fContrDataDone := False;
               {data in contribution objects needs to be updated}

               LoadSelectionsOldVersion(OpenDialog.FileName);
               if not CheckSelections then
               begin
                    //
                    LoadSelectionsOldVersion(ControlRes^.sDatabase + '\empty.log');
                    AddSelections(OpenDialog.FileName,False);
               end;
               LabelCountUpdate;

               RePrepIrrepData;

               // if there are excluded items, recalculate combination size here
               if (Excluded.Items.Count > 0) then
                  ReInitializeInitialValues(ExclusionChange);

               if fRetainClass then
               begin
                    if (mrYes = MessageDlg('Retain Feature Subset ' +
                                           sRetainClass,
                                           mtConfirmation,
                                           [mbYes,mbNo],0)) then
                    begin
                         LoadOrdinalClass(sRetainClass,ControLRes^.ClassDetail);
                         ControlRes^.fFeatureClassesApplied := True;
                         ControlRes^.sFeatureClassField := sRetainClass;
                    end
               end;
               CalcExcludeTrimAmount;
               ExecuteIrreplaceability(-1,False,False,True,True,'');

               SaveDialog.Filename := ExtractFileName(OpenDialog.Filename);
               SaveDialog.InitialDir := ExtractFilePath(OpenDialog.Filename);
          end;
     end;
end;

procedure TControlForm.MarxanPrototype1Click(Sender: TObject);
begin
     MarxanPrototypeForm := TMarxanPrototypeForm.Create(Application);
     MarxanPrototypeForm.ShowModal;
     MarxanPrototypeForm.Free;
end;

procedure TControlForm.Options2Click(Sender: TObject);
begin
     if ControlRes^.fMarxanDatabaseExists then
     begin
          CopyFile(PChar('c:\marxan\inedit.exe'),PChar(ControlRes^.sMarxanDatabasePath + '\inedit.exe'),True);
          RunAnAppAnyPath(ControlRes^.sMarxanDatabasePath + '\inedit.exe','',ControlRes^.sMarxanDatabasePath);
     end;
end;

procedure TControlForm.BuildDatabase1Click(Sender: TObject);
begin
     CreateMarxanDatabaseClick;
end;

procedure TControlForm.EditReserveClasses1Click(Sender: TObject);
begin
     RunCPlanApp('reserveclass',ControlRes^.sDatabase);

     MessageDlg('Restart C-Plan to use new reserve classes',mtInformation,[mbOk],0);
     
     Exit1Click(Sender);
end;

procedure TControlForm.CIBulkSitePartialProtection1Click(Sender: TObject);
begin
     // select sites as partial protected,
     // sites with fPartialProtection are partially selected,
     // its features with a sSize of "small" are Available, the rest being reserved
     
end;

procedure TControlForm.BLFConverter1Click(Sender: TObject);
begin
     BLFProcessForm := TBLFProcessForm.Create(Application);
     BLFProcessForm.ShowModal;
     BLFProcessForm.Free;
end;

procedure DumpAsciiMatrixSiteNameAsKey;
var
   OutFile : TextFile;
   iBaseFeatureKey, iCount, iFeatureCount : integer;
   pSite : sitepointer;
   Value : ValueFile_T;
begin
     assignfile(OutFile,'c:\matrix_nameaskey.csv');
     rewrite(OutFile);
     //writeln(OutFile,'SITENAME,FEATKEY,AMOUNT');
     new(pSite);
     iBaseFeatureKey := 11470;

     for iCount := 1 to iSiteCount do
     begin
          SiteArr.rtnValue(iCount,pSite);
          if (pSite^.richness > 0) then
             for iFeatureCount := 1 to pSite^.richness do
             begin
                  FeatureAmount.rtnValue(pSite^.iOffset + iFeatureCount,@Value);

                  writeln(OutFile,pSite^.sName + ',' + IntToStr(Value.iFeatKey + iBaseFeatureKey) + ',' + FloatToStr(Value.rAmount));
             end;
     end;

     closefile(OutFile);
     dispose(pSite);
end;

procedure TControlForm.DumpMatrixwithSiteNameaskey1Click(Sender: TObject);
begin
     DumpAsciiMatrixSiteNameAsKey;
end;

procedure TControlForm.MalRandomSiteSelection1Click(Sender: TObject);
begin
     RandomSelectionForm := TRandomSelectionForm.Create(Application);
     RandomSelectionForm.ShowModal;
     RandomSelectionForm.Free;
end;

procedure TControlForm.EditAllTargets1Click(Sender: TObject);
var
   iCount : integer;
   rEditedTarget : extended;
begin
     try
        fEditTargets := False;

        Screen.Cursor := crHourglass;
        //EditForm := TEditForm.Create(Application);
        EasyEditTargetsForm := TEasyEditTargetsForm.Create(Application);
        Screen.Cursor := crDefault;

        //if (EditForm.ShowModal <> mrCancel) then
        //   fEditTargets := True;
        if (EasyEditTargetsForm.ShowModal <> mrCancel) then
           fEditTargets := True;

        if (not UseFeatCutOffs.Checked) then
           fEditTargets := False;

     finally
            Screen.Cursor := crHourglass;

            //EditForm.Free;

            if fEditTargets then
            begin
                 // Save feature targets to the feature table
                 EasyEditTargetsForm.Table1.DatabaseName := ControlRes^.sDatabase;
                 EasyEditTargetsForm.Table1.TableName := ControlRes^.sFeatCutOffsTable;
                 EasyEditTargetsForm.Table1.Open;

                 for iCount := 1 to iFeatureCount do
                 begin
                      try
                         rEditedTarget := StrToFloat(EasyEditTargetsForm.StringGrid1.Cells[2,iCount]);
                         EasyEditTargetsForm.Table1.Edit;
                         EasyEditTargetsForm.Table1.FieldByName(ControlRes^.sFeatureTargetField).AsFloat := rEditedTarget;

                      except
                      end;

                      EasyEditTargetsForm.Table1.Next;
                 end;

                 EasyEditTargetsForm.Table1.Close;

                 EasyEditTargetsForm.Free;

                 LoadFeatureTable;

                 if UseFeatCutOffs.Checked then
                 begin
                      {we are using imported targets, so we must run irrep}
                      ReInitializeInitialValues(TargetChange);

                      ExecuteIrreplaceability(-1,False,False,True,True,'');
                 end;
            end;

            Screen.Cursor := crDefault;
     end;
end;

procedure TControlForm.ImportTargetField1Click(Sender: TObject);
begin
     ImportTargetFieldForm := TImportTargetFieldForm.Create(Application);
     ImportTargetFieldForm.ShowModal;
     ImportTargetFieldForm.Free;
end;

procedure TControlForm.Summaris1Click(Sender: TObject);
begin
     SummariseClumpsForm := TSummariseClumpsForm.Create(Application);
     SummariseClumpsForm.ShowModal;
     SummariseClumpsForm.Free;
end;

initialization

end.

