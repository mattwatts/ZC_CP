unit dbms_child;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DdeMan, Menus, StdCtrls, ComCtrls, Buttons, ExtCtrls;

type
  TDBMSForm = class(TForm)
    SpeedPanel: TPanel;
    OpenBtn: TSpeedButton;
    SaveBtn: TSpeedButton;
    CutBtn: TSpeedButton;
    CopyBtn: TSpeedButton;
    PasteBtn: TSpeedButton;
    ExitBtn: TSpeedButton;
    SpeedButton1: TSpeedButton;
    StatusBar: TStatusBar;
    ProjectBox: TListBox;
    PasteMemo: TMemo;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    Link1: TMenuItem;
    FileOpenItem: TMenuItem;
    ConvertandOpen1: TMenuItem;
    CPlanReports1: TMenuItem;
    ConvertandLink1: TMenuItem;
    FileCloseItem: TMenuItem;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    OpenFromMarxanMatrix1: TMenuItem;
    OpenFromMarxanMatrixMaskPU1: TMenuItem;
    SaveToMarxanMatrix1: TMenuItem;
    N3: TMenuItem;
    OpenProject1: TMenuItem;
    SaveProject1: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    PasteSpecial1: TMenuItem;
    N6: TMenuItem;
    DeleteRows1: TMenuItem;
    DeleteColumns1: TMenuItem;
    AddCells1: TMenuItem;
    N2: TMenuItem;
    EditValues1: TMenuItem;
    RemoveLeadingCharacter1: TMenuItem;
    Fields1: TMenuItem;
    LoadERMSFieldNames1: TMenuItem;
    Wizards1: TMenuItem;
    ImportResourceWizard1: TMenuItem;
    JoinTables1: TMenuItem;
    ImportMatrix1: TMenuItem;
    Table1: TMenuItem;
    Find1: TMenuItem;
    SaveSubsetofRowsColumns1: TMenuItem;
    CompareContentsofTwoTables1: TMenuItem;
    AutoFit1: TMenuItem;
    Transpose1: TMenuItem;
    FieldProperties1: TMenuItem;
    RandomizeMatrix1: TMenuItem;
    SaveExcelChunks1: TMenuItem;
    SumColumns1: TMenuItem;
    SumRows1: TMenuItem;
    SummariseHighestColumn1: TMenuItem;
    CoverttoPresenceAbsence1: TMenuItem;
    Tools1: TMenuItem;
    LoadFeatureToTargetReports1: TMenuItem;
    Window1: TMenuItem;
    WindowCascadeItem: TMenuItem;
    WindowTileItem: TMenuItem;
    WindowArrangeItem: TMenuItem;
    WindowMinimizeItem: TMenuItem;
    Debug1: TMenuItem;
    AnalyseHotspots1: TMenuItem;
    ProcessHotspots1: TMenuItem;
    ProcessRetention1: TMenuItem;
    HotspotsSensitivityGraphs1: TMenuItem;
    TestDestruction1: TMenuItem;
    MinsetTestA1: TMenuItem;
    MinsetTestB1: TMenuItem;
    SumFields1: TMenuItem;
    SQL1: TMenuItem;
    WyongFeatureSummarise1: TMenuItem;
    CombineSimulationRegions1: TMenuItem;
    CombineDEHVeglayers1: TMenuItem;
    SplitTabareaReport1: TMenuItem;
    DeconstructPUZONE1: TMenuItem;
    N5: TMenuItem;
    GenerateRandom1: TMenuItem;
    RandomDelete1: TMenuItem;
    Rows1: TMenuItem;
    Columns1: TMenuItem;
    SystemTest1: TMenuItem;
    Marxanwithzoning1: TMenuItem;
    Help1: TMenuItem;
    HelpAboutItem: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    OpenIND: TOpenDialog;
    OpenFeaturesToTarget: TOpenDialog;
    OpenProject: TOpenDialog;
    SaveProject: TSaveDialog;
    LinkDialog: TOpenDialog;
    CmdConv: TDdeServerConv;
    CmdItem: TDdeServerItem;
    LinkReport: TOpenDialog;
    OpenReport: TOpenDialog;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DBMSForm: TDBMSForm;

implementation

{$R *.DFM}

end.
