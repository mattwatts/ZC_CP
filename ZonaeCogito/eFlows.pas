unit eFlows;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OleServer, Excel97, Grids, ExtCtrls, DBTables, Db;

type
  TeFlowsForm = class(TForm)
    ExcelApplication1: TExcelApplication;
    ExcelWorksheet1: TExcelWorksheet;
    GroupBoxeFlowSpreadsheetOptions: TGroupBox;
    EditeFlowSpreadsheetPathName: TEdit;
    ButtonUpdate: TButton;
    GroupBoxDebuggingControls: TGroupBox;
    btnLaunch: TButton;
    CheckLaunchVisible: TCheckBox;
    btnclose: TButton;
    CheckSaveChanges: TCheckBox;
    btnSpreadsheet: TButton;
    btnTracker: TButton;
    btnWrite: TButton;
    btnRead: TButton;
    btnRunAllocate: TButton;
    ExcelWorkbook1: TExcelWorkbook;
    PanelEditParameter: TPanel;
    Label1: TLabel;
    LabelEditValue: TLabel;
    ComboParameterToEdit: TComboBox;
    EditValue: TEdit;
    ButtonSaveParameter: TButton;
    CheckEditAllRows: TCheckBox;
    ParameterGrid: TStringGrid;
    GroupBoxGIS: TGroupBox;
    Label2: TLabel;
    LabelKeyField: TLabel;
    ComboPUShapefile: TComboBox;
    ComboKeyField: TComboBox;
    ComboOutputToMap: TComboBox;
    ThemeTable: TTable;
    ThemeQuery: TQuery;
    PUIDGrid: TStringGrid;
    Timer1: TTimer;
    Timer2: TTimer;
    Timer3: TTimer;
    LabelDescriptive: TLabel;
    ComboEditValue: TComboBox;
    DescriptionGrid: TStringGrid;
    procedure btnLaunchClick(Sender: TObject);
    procedure btnSpreadsheetClick(Sender: TObject);
    procedure btnRunAllocateClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ComboParameterToEditChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetEditElement;
    procedure LoadSpecies;
    procedure SaveSpecies;
    procedure SaveParameter;
    procedure LoadParameter;
    procedure ButtonSaveParameterClick(Sender: TObject);
    function ReturnNoOfSpecies : integer;
    function ReturnNoOfSeasons : integer;
    function ReturnTotalRun : integer;
    function ReturneFlowsPuCount : integer;
    procedure EditValueChange(Sender: TObject);
    procedure ParameterGridKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ParameterGridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure InitialiseeFlowsGUI(const sXLSPathFileName : string);
    procedure ButtonUpdateClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DropFields(const sShpFileName : string);
    procedure ForceFields(const sShpFileName : string);
    function ReturnParameterIndex(const sParameter : string) : integer;
    procedure ExecuteeFlowsThread;
    procedure CaptureeFlowsPuOutput;
    procedure RefreshOutputToMap;
    procedure ComboOutputToMapChange(Sender: TObject);
    procedure RefreshGISDisplay;
    procedure GenerateTimeSeriesKML(const sOutputFileName : string;
                                    const iRunToUse : integer;
                                    const fReverseClockwise : boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure LoadFlowScenario;
    procedure SaveFlowScenario;
    procedure ComboEditValueChange(Sender: TObject);
    procedure LoadPUSelector;
    procedure SavePUSelector;
    function ReturnBestRun_OFS : integer;
    function ReturnBestRun_HH : integer;
    procedure RetrieveTotalSummary(const iRun : integer);
    procedure RetrieveScenariosAnnotation;
    procedure RetrieveOutsheet(const iRun : integer);
    procedure AllocationSummaryMenuItems;
  private
    { Private declarations }
  public
    { Public declarations }
    seFlowsPuLayer, seFlowsKeyField : string;
  end;

function SeasonToMonthStringAbbreviated(const iSeason : integer) : string;

var
  eFlowsForm: TeFlowsForm;
  eFlowsExcelObject: Variant;
  eFlowsWBk {, eFlowsWS}: OleVariant;
  feFlowsParameterChanged, feFlowsSettingParameter : boolean;
  seFlowsParameterLoaded : string;
  ieFlowsNoOfSpecies, ieFlowsNoOfSeasons, ieFlowsTotalRun, ieFlowsPuCount, ieFlowsTableIndex : integer;
  eFlowsRowColour : array [1..100,1..10000] of boolean;

implementation

uses
    ComObj, Miscellaneous, SCP_Main, GIS, MapWinGIS_TLB, ds,
    eFlows_progress, CSV_Child;

{$R *.DFM}


function SeasonToMonthStringAbbreviated(const iSeason : integer) : string;
begin
     Result := eFlowsWBk.Worksheets.Item['SeasonLookup'].Cells.Item[iSeason+1,1].Value;
end;

function SeasonToMonthString(const iSeason : integer) : string;
begin
     Result := eFlowsWBk.Worksheets.Item['SeasonLookup'].Cells.Item[iSeason+1,2].Value;
end;

function MonthStringToSeason(const sSeason : string) : integer;
var
   iCount, iResult : integer;
begin
     iResult := 1;
     ieFlowsNoOfSeasons := eFlowsForm.ReturnNoOfSeasons;

     for iCount := 1 to ieFlowsNoOfSeasons do
         if (sSeason = eFlowsWBk.Worksheets.Item['SeasonLookup'].Cells.Item[iCount+1,2].Value) then
            iResult := iCount;

     Result := iResult;
end;

procedure TeFlowsForm.RetrieveOutsheet(const iRun : integer);
var
   iRowCount, iRCount, iCCount, iBestRun, iBestRowStart, iBestRowEnd, iBestRowCount, iChildIndex : integer;
   NewChild : TCSVChild;
   AForm : TForm;
   sTable, sValue, sOldValue : string;
   fSwapper, fStop : boolean;
begin
     try
        Screen.Cursor := crHourglass;
        iRowCount := eFlowsWBk.Worksheets.Item['Outsheet'].UsedRange.Rows.Count;

        // if iRun is 0, we are using the best run
        if (iRun = 0) then
           iBestRun := ReturnBestRun_OFS
        else
            iBestRun := iRun;

        //iBestRowStart, iBestRowEnd, iBestRowCount
        iBestRowStart := 0;
        for iRCount := iRowCount downto 2 do
        begin
             sValue := eFlowsWBk.Worksheets.Item['Outsheet'].Cells.Item[iRCount,2].Value;
             if (sValue = IntToStr(iBestRun)) then
                iBestRowStart := iRCount;
        end;

        iBestRowEnd := iRowCount;
        fStop := False;
        for iRCount := 2 to iRowCount do
        begin
             // if we find iBestRun+1, set iBestRowEnd to iRCount-1
             if not fStop then
             begin
                  sValue := eFlowsWBk.Worksheets.Item['Outsheet'].Cells.Item[iRCount,2].Value;
                  if (sValue = IntToStr(iBestRun+1)) then
                  begin
                       iBestRowEnd := iRCount-1;
                       fStop := True;
                  end;
             end;
        end;
        iBestRowCount := iBestRowEnd - iBestRowStart + 2;

        // create a new child
        if (iRun = 0) then
           sTable := 'List of watered wetlands Best Solution'
        else
            sTable := 'List of watered wetlands Run ' + IntToStr(iRun);

        AForm := SCPForm.ReturnNamedChild(sTable);
        if (AForm = nil) then
        begin
             SCPForm.CreateCSVChild(sTable,0);
             Inc(ieFlowsTableIndex);
             if (ieFlowsTableIndex > 100) then
                ieFlowsTableIndex := 1;

             iChildIndex := SCPForm.ReturneFlowsTableIndex(sTable);
             TCSVChild(SCPForm.MDIChildren[iChildIndex]).iTableIndex := ieFlowsTableIndex;
        end;

        iChildIndex := SCPForm.ReturneFlowsTableIndex(sTable);
           
        Screen.Cursor := crHourglass;
        NewChild := TCSVChild(SCPForm.MDIChildren[iChildIndex]);
        NewChild.BringToFront;

        // set colour swapper array for drawing grid
        fSwapper := False;
        eFlowsRowColour[NewChild.iTableIndex,1] := fSwapper;
        sOldValue := eFlowsWBk.Worksheets.Item['Outsheet'].Cells.Item[iBestRowStart,4].Value;
        for iRCount := (iBestRowStart+1) to iRowCount do
        begin
             sValue := eFlowsWBk.Worksheets.Item['Outsheet'].Cells.Item[iRCount,4].Value;
             // toggle swapper when we encounter new season
             if (sValue <> sOldValue) then
             begin
                  fSwapper := not fSwapper;
                  sOldValue := sValue;
             end;
             eFlowsRowColour[NewChild.iTableIndex,iRCount-iBestRowStart+1] := fSwapper;
        end;


        feFlowsSummary := True;

        // set the dimensions of the new child
        NewChild.aGrid.RowCount := iBestRowCount;
        NewChild.aGrid.ColCount := 3;
        NewChild.lblDimensions.Caption := 'rows ' + IntToStr(NewChild.AGrid.RowCount) +
                                          ' fields ' + IntToStr(NewChild.AGrid.ColCount) +
                                          ' data elements ' + IntToStr(NewChild.AGrid.RowCount * NewChild.AGrid.ColCount);
        if (NewChild.aGrid.RowCount > 1) then
           NewChild.aGrid.FixedRows := 1;

        // header row
        NewChild.aGrid.Cells[0,0] := eFlowsWBk.Worksheets.Item['Outsheet'].Cells.Item[1,3].Value;
        NewChild.aGrid.Cells[1,0] := eFlowsWBk.Worksheets.Item['Outsheet'].Cells.Item[1,4].Value;
        NewChild.aGrid.Cells[2,0] := eFlowsWBk.Worksheets.Item['Outsheet'].Cells.Item[1,6].Value;
        // best solution
        for iRCount := iBestRowStart to iBestRowEnd do
        begin
             NewChild.aGrid.Cells[0,iRCount-iBestRowStart+1] := eFlowsWBk.Worksheets.Item['Outsheet'].Cells.Item[iRCount,3].Value;
             NewChild.aGrid.Cells[1,iRCount-iBestRowStart+1] := SeasonToMonthString(StrToInt(eFlowsWBk.Worksheets.Item['Outsheet'].Cells.Item[iRCount,4].Value));
             NewChild.aGrid.Cells[2,iRCount-iBestRowStart+1] := eFlowsWBk.Worksheets.Item['Outsheet'].Cells.Item[iRCount,6].Value;
        end;

        AutoFitGrid(NewChild.aGrid,Canvas,True);

        // generate a new filename for the transposed table and save it to file
        NewChild.Caption := sTable;
        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RetrieveOutsheet',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TeFlowsForm.RetrieveScenariosAnnotation;
var
   iRowCount, iColCount, iRCount, iCCount : integer;
   sTable : string;
begin
     try
        Screen.Cursor := crHourglass;
        iRowCount := eFlowsWBk.Worksheets.Item['ScenariosAnnotation'].UsedRange.Rows.Count;
        iColCount := eFlowsWBk.Worksheets.Item['ScenariosAnnotation'].UsedRange.Columns.Count;

        Screen.Cursor := crHourglass;

        DescriptionGrid.Visible := True;
        // set the dimensions of the new child
        DescriptionGrid.RowCount := iRowCount;
        DescriptionGrid.ColCount := iColCount;
        if (DescriptionGrid.RowCount > 1) then
           DescriptionGrid.FixedRows := 1;
        DescriptionGrid.FixedCols := 0;

        // populate the grid with cell values from the worksheet
        for iCCount := 0 to (DescriptionGrid.ColCount-1) do
            for iRCount := 0 to (DescriptionGrid.RowCount-1) do
                DescriptionGrid.Cells[iCCount,iRCount] := eFlowsWBk.Worksheets.Item['ScenariosAnnotation'].Cells.Item[iRCount+1,iCCount+1].Value;

        AutoFitGrid(DescriptionGrid,Canvas,True);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RetrieveScenariosAnnotation',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

function ReformatScientificNotation(const sInputString : string) : string;
var
   rValue : extended;
begin
     rValue := StrToFloat(sInputString);

     Result := FloatToStrF(rValue,ffFixed,8,8);
end;

procedure TeFlowsForm.RetrieveTotalSummary(const iRun : integer);
var
   iRowCount, iColCount, iRCount, iCCount, iBestRun, iBestRowStart, iBestRowEnd, iBestRowCount, iChildIndex : integer;
   NewChild : TCSVChild;
   AForm : TForm;
   sTable, sValue : string;
   fSwapper, fStop : boolean;
begin
     try
        Screen.Cursor := crHourglass;
        iRowCount := eFlowsWBk.Worksheets.Item['TotalSummary'].UsedRange.Rows.Count;
        iColCount := eFlowsWBk.Worksheets.Item['TotalSummary'].UsedRange.Columns.Count;

        // if iRun is 0, we are using the best run
        if (iRun = 0) then
           iBestRun := ReturnBestRun_OFS
        else
            iBestRun := iRun;

        //iBestRowStart, iBestRowEnd, iBestRowCount
        iBestRowStart := 0;
        for iRCount := iRowCount downto 2 do
        begin
             sValue := eFlowsWBk.Worksheets.Item['TotalSummary'].Cells.Item[iRCount,1].Value;
             if (sValue = IntToStr(iBestRun)) then
                iBestRowStart := iRCount;
        end;

        iBestRowEnd := iRowCount;
        fStop := False;
        for iRCount := iBestRowStart to iRowCount do
        begin
             if not fStop then
             begin
                  // if we find iBestRun+1, set iBestRowEnd to iRCount-1
                  sValue := eFlowsWBk.Worksheets.Item['TotalSummary'].Cells.Item[iRCount,1].Value;
                  if (sValue = IntToStr(iBestRun+1)) then
                  begin
                       iBestRowEnd := iRCount-1;
                       fStop := True;
                  end;
             end;
        end;
        iBestRowCount := iBestRowEnd - iBestRowStart + 2;

        // create a new child
        if (iRun = 0) then
           sTable := 'Allocation Summary Best Solution'
        else
            sTable := 'Allocation Summary Run ' + IntToStr(iRun);

        AForm := SCPForm.ReturnNamedChild(sTable);
        if (AForm = nil) then
        begin
             SCPForm.CreateCSVChild(sTable,0);
             Inc(ieFlowsTableIndex);
             if (ieFlowsTableIndex > 100) then
                ieFlowsTableIndex := 1;

             iChildIndex := SCPForm.ReturneFlowsTableIndex(sTable);
             TCSVChild(SCPForm.MDIChildren[iChildIndex]).iTableIndex := ieFlowsTableIndex;
        end;
        iChildIndex := SCPForm.ReturneFlowsTableIndex(sTable);

        Screen.Cursor := crHourglass;
        NewChild := TCSVChild(SCPForm.MDIChildren[iChildIndex]);
        NewChild.BringToFront;

        // set colour swapper array for drawing grid
        fSwapper := False;
        eFlowsRowColour[NewChild.iTableIndex,1] := fSwapper;
        for iRCount := (iBestRowStart+1) to iRowCount do
        begin
             sValue := eFlowsWBk.Worksheets.Item['TotalSummary'].Cells.Item[iRCount,1].Value;
             // toggle swapper when we encounter non-blank cell
             if (sValue <> '') then
                fSwapper := not fSwapper;
             eFlowsRowColour[NewChild.iTableIndex,iRCount-iBestRowStart+1] := fSwapper;
        end;

        // set the dimensions of the new child

        feFlowsSummary := True;

        NewChild.aGrid.RowCount := iBestRowCount;
        NewChild.aGrid.ColCount := iColCount-1;
        NewChild.lblDimensions.Caption := 'rows ' + IntToStr(NewChild.AGrid.RowCount) +
                                          ' fields ' + IntToStr(NewChild.AGrid.ColCount) +
                                          ' data elements ' + IntToStr(NewChild.AGrid.RowCount * NewChild.AGrid.ColCount);
        if (NewChild.aGrid.RowCount > 1) then
           NewChild.aGrid.FixedRows := 1;

        // header row
        for iCCount := 0 to (NewChild.aGrid.ColCount-1) do
        begin
            NewChild.aGrid.Cells[iCCount,0] := eFlowsWBk.Worksheets.Item['TotalSummary'].Cells.Item[1,iCCount+2].Value;
            // best solution
            for iRCount := iBestRowStart to iBestRowEnd do
            begin
                 if (iCCount = 0) then
                 begin
                      sValue := eFlowsWBk.Worksheets.Item['TotalSummary'].Cells.Item[iRCount,iCCount+2].Value;
                      if (sValue <> '') then
                         // convert to string month if we have a month cell
                         sValue := SeasonToMonthString(StrToInt(sValue));

                      NewChild.aGrid.Cells[iCCount,iRCount-iBestRowStart+1] := sValue;
                 end
                 else
                 begin
                      sValue := eFlowsWBk.Worksheets.Item['TotalSummary'].Cells.Item[iRCount,iCCount+2].Value;
                      // if sValue containg . E - it is a floating point number in scientific notation so we must reformat it
                      if (Pos('.',sValue) > 0) then
                         if (Pos('E',sValue) > 0) then
                            if (Pos('-',sValue) > 0) then
                               sValue := ReformatScientificNotation(sValue);
                      NewChild.aGrid.Cells[iCCount,iRCount-iBestRowStart+1] := sValue;
                 end;
            end;
        end;

        AutoFitGrid(NewChild.aGrid,Canvas,True);

        // generate a new filename for the transposed table and save it to file
        NewChild.Caption := sTable;
        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RetrieveTotalSummary',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TeFlowsForm.RefreshOutputToMap;
var
   sComboText : string;
   i, j, iGISChild : integer;
   AChild : TGIS_Child;
begin
     try
        ieFlowsNoOfSeasons := ReturnNoOfSeasons;
        ieFlowsTotalRun := ReturnTotalRun;
        sComboText := ComboOutputToMap.Text;
        ComboOutputToMap.Items.Clear;

        for j := 1 to ieFlowsNoOfSeasons do
            ComboOutputToMap.Items.Add('Best ' + SeasonToMonthString(j));

        for i := 1 to ieFlowsTotalRun do
            for j := 1 to ieFlowsNoOfSeasons do
                ComboOutputToMap.Items.Add('Run ' + IntToStr(i) + ' ' + SeasonToMonthString(j));

        if (ComboOutputToMap.Items.IndexOf(sComboText) > -1) then
           ComboOutputToMap.Text := sComboText
        else
            ComboOutputToMap.Text := ComboOutputToMap.Items.Strings[0];

        iGISChild := SCPForm.ReturnGISChildIndex;
        if (iGISChild > -1) then
        begin
             AChild := TGIS_Child(SCPForm.MDIChildren[iGISChild]);

             if (AChild <> nil) then
             begin
                  AChild.ComboOutputToMap.Items.Clear;

                  for i := 0 to (ComboOutputToMap.Items.Count - 1) do
                      AChild.ComboOutputToMap.Items.Add(ComboOutputToMap.Items.Strings[i]);

                  AChild.ComboOutputToMap.Text := ComboOutputToMap.Text;
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RefreshOutputToMap',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TeFlowsForm.ForceFields(const sShpFileName : string);
var
   iFieldsToAdd, i, j : integer;
   sTableName : string;

   function DoesFieldExist(sField : string) : boolean;
   var
      iCount : integer;
      fResult : boolean;
   begin
        fResult := False;

        for iCount := 0 to (ThemeTable.FieldDefs.Count-1) do
            if (sField = ThemeTable.FieldDefs.Items[iCount].Name) then
               fResult := True;

        Result := fResult;
   end;

   procedure AddAField(sField : string);
   begin
        if not DoesFieldExist(sField) then
        begin
             Inc(iFieldsToAdd);
             if (iFieldsToAdd > 1) then
                ThemeQuery.SQL.Add(', ADD ' + sField + ' NUMERIC(10,0)')
             else
                 ThemeQuery.SQL.Add('ADD ' + sField + ' NUMERIC(10,0)');
        end;
   end;

begin
     // if relevant fields do not exist in the shape file, create them with an sql query
     try
        ieFlowsNoOfSeasons := ReturnNoOfSeasons;
        ieFlowsTotalRun := ReturnTotalRun;

        ThemeTable.DatabaseName := ExtractFilePath(sShpFileName);
        sTableName := ExtractFileName(sShpFileName);
        sTableName := Copy(sTableName,1,Length(sTableName) - Length(ExtractFileExt(sTableName))) + '.dbf';
        ThemeTable.TableName := sTableName;

        ThemeQuery.SQL.Clear;
        ThemeQuery.SQL.Add('ALTER TABLE "' + ThemeTable.DatabaseName + '\' + sTableName + '"');

        ThemeTable.Open;

        iFieldsToAdd := 0;
        for i := 1 to ieFlowsTotalRun do
            for j := 1 to ieFlowsNoOfSeasons do
                AddAField('R' + IntToStr(i) + 'S' + IntToStr(j));

        ThemeTable.Close;

        if (iFieldsToAdd > 0) then
        begin
             ThemeQuery.Prepare;
             ThemeQuery.ExecSQL;
             ThemeQuery.Close;
        end;

     except
           ThemeQuery.SQL.SaveToFile(ThemeTable.DatabaseName + '\error.sql');
           MessageDlg('Exception in ForceFields theme ' + sShpFileName + '.',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TeFlowsForm.DropFields(const sShpFileName : string);
var
   iFieldsToAdd, i, j : integer;
   sTableName : string;

   function DoesFieldExist(sField : string) : boolean;
   var
      iCount : integer;
      fResult : boolean;
   begin
        fResult := False;

        for iCount := 0 to (ThemeTable.FieldDefs.Count-1) do
            if (sField = ThemeTable.FieldDefs.Items[iCount].Name) then
               fResult := True;

        Result := fResult;
   end;

   procedure AddAField(sField : string);
   begin
        if DoesFieldExist(sField) then
        begin
             Inc(iFieldsToAdd);
             if (iFieldsToAdd > 1) then
                ThemeQuery.SQL.Add(', DROP ' + sField)
             else
                 ThemeQuery.SQL.Add('DROP ' + sField);
        end;
   end;

begin
     // if relevant fields do not exist in the shape file, create them with an sql query
     try
        ieFlowsNoOfSeasons := ReturnNoOfSeasons;
        ieFlowsTotalRun := ReturnTotalRun;

        ThemeTable.DatabaseName := ExtractFilePath(sShpFileName);
        sTableName := ExtractFileName(sShpFileName);
        sTableName := Copy(sTableName,1,Length(sTableName) - Length(ExtractFileExt(sTableName))) + '.dbf';
        ThemeTable.TableName := sTableName;

        ThemeQuery.SQL.Clear;
        ThemeQuery.SQL.Add('ALTER TABLE "' + ThemeTable.DatabaseName + '\' + sTableName + '"');

        ThemeTable.Open;

        iFieldsToAdd := 0;
        for i := 1 to 100 do
            for j := 1 to 12 do
                AddAField('R' + IntToStr(i) + 'S' + IntToStr(j));

        ThemeTable.Close;

        if (iFieldsToAdd > 0) then
        begin
             ThemeQuery.Prepare;
             ThemeQuery.ExecSQL;
             ThemeQuery.Close;
        end;

     except
           ThemeQuery.SQL.SaveToFile(ThemeTable.DatabaseName + '\error.sql');
           MessageDlg('Exception in DropFields theme ' + sShpFileName + '.',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TeFlowsForm.AllocationSummaryMenuItems;
begin
     ieFlowsTotalRun := eFlowsForm.ReturnTotalRun;

     SCPForm.Solution11.Visible := (ieFlowsTotalRun > 0);
     SCPForm.Solution21.Visible := (ieFlowsTotalRun > 1);
     SCPForm.Solution31.Visible := (ieFlowsTotalRun > 2);
     SCPForm.Solution41.Visible := (ieFlowsTotalRun > 3);
     SCPForm.Solution51.Visible := (ieFlowsTotalRun > 4);
     SCPForm.Solution61.Visible := (ieFlowsTotalRun > 5);
     SCPForm.Solution71.Visible := (ieFlowsTotalRun > 6);
     SCPForm.Solution81.Visible := (ieFlowsTotalRun > 7);
     SCPForm.Solution91.Visible := (ieFlowsTotalRun > 8);
     SCPForm.Solution101.Visible := (ieFlowsTotalRun > 9);

     SCPForm.Solution12.Visible := (ieFlowsTotalRun > 0);
     SCPForm.Solution22.Visible := (ieFlowsTotalRun > 1);
     SCPForm.Solution32.Visible := (ieFlowsTotalRun > 2);
     SCPForm.Solution42.Visible := (ieFlowsTotalRun > 3);
     SCPForm.Solution52.Visible := (ieFlowsTotalRun > 4);
     SCPForm.Solution62.Visible := (ieFlowsTotalRun > 5);
     SCPForm.Solution72.Visible := (ieFlowsTotalRun > 6);
     SCPForm.Solution82.Visible := (ieFlowsTotalRun > 7);
     SCPForm.Solution92.Visible := (ieFlowsTotalRun > 8);
     SCPForm.Solution102.Visible := (ieFlowsTotalRun > 9);
end;

procedure TeFlowsForm.InitialiseeFlowsGUI(const sXLSPathFileName : string);
begin
     try
        GroupBoxDebuggingControls.Visible := False;
        BorderIcons := BorderIcons - [biSystemMenu];
        BorderIcons := BorderIcons - [biMinimize];
        BorderIcons := BorderIcons - [biMaximize];

        // launch Excel
        try
           eFlowsExcelObject := GetActiveOleObject('Excel.Application');
           eFlowsExcelObject.Quit;
           eFlowsExcelObject := Unassigned;
        except
        end;
        eFlowsExcelObject := CreateOleObject('Excel.Application');
        eFlowsExcelObject.Visible := not SCPForm.HideExcelInterface1.Checked;

        // open the workbook in Excel
        eFlowsWBk := eFlowsExcelObject.Workbooks.Open(sXLSPathFileName);

        // initialise the GUI for the workbook
        LoadParameter;    
        ComboParameterToEdit.Enabled := True;
        EditValue.Enabled := True;
        LabelEditValue.Enabled := True;
        ButtonSaveParameter.Enabled := True;
        ButtonUpdate.Enabled := True;

        // initialise GIS display options
        RefreshOutputToMap;
        ComboOutputToMapChange(Self);
        AllocationSummaryMenuItems;

     except
           MessageDlg('Exception in InitialiseeFlowsGUI',mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TeFlowsForm.SetEditElement;
var
   iValue, iScenario : integer;
   ARect: TGridRect;
begin
     try
        feFlowsSettingParameter := True;

        if (ComboParameterToEdit.Text = 'flow scenario') then
        begin
             ComboEditValue.Items.Clear;
             for iValue := 1 to 6 do
                 ComboEditValue.Items.Add(IntToStr(iValue));
             ComboEditValue.Visible := True;
             ComboEditValue.Left := EditValue.Left;
             ComboEditValue.Top := EditValue.Top;
             ComboEditValue.Width := EditValue.Width;
             ComboEditValue.ItemIndex := ComboEditValue.Items.IndexOf(ParameterGrid.Cells[ParameterGrid.Selection.Left,ParameterGrid.Selection.Top]);
             if (ComboEditValue.Enabled) and (ComboEditValue.Visible) then
                ComboEditValue.SetFocus;

             iScenario := StrToInt(ComboEditValue.Text);
             ARect.Left := 0;
             ARect.Top := 1 + ((iScenario-1) * 2);
             ARect.Right := 1;
             ARect.Bottom := ARect.Top + 1;

             DescriptionGrid.Selection := ARect;
        end
        else
        if (ComboParameterToEdit.Text = 'planning unit selector') then
        begin
             ComboEditValue.Items.Clear;
             ComboEditValue.Items.Add('0');
             ComboEditValue.Items.Add('1');
             ComboEditValue.Visible := True;
             ComboEditValue.Left := EditValue.Left;
             ComboEditValue.Top := EditValue.Top;
             ComboEditValue.Width := EditValue.Width;
             ComboEditValue.ItemIndex := ComboEditValue.Items.IndexOf(ParameterGrid.Cells[ParameterGrid.Selection.Left,ParameterGrid.Selection.Top]);
             if (ComboEditValue.Enabled) and (ComboEditValue.Visible) then
                ComboEditValue.SetFocus;
        end
        else
        begin
             ComboEditValue.Visible := False;
             EditValue.Text := ParameterGrid.Cells[ParameterGrid.Selection.Left,ParameterGrid.Selection.Top];
             if (EditValue.Enabled) and (EditValue.Visible) then
                EditValue.SetFocus;
        end;

        feFlowsSettingParameter := False;

     except
           MessageDlg('Exception in SetEditElement',mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TeFlowsForm.btnLaunchClick(Sender: TObject);
begin
     try
        eFlowsExcelObject := GetActiveOleObject('Excel.Application');
     except
           eFlowsExcelObject := CreateOleObject('Excel.Application');
     end;
     eFlowsExcelObject.Visible := CheckLaunchVisible.Checked;
end;

procedure TeFlowsForm.btnSpreadsheetClick(Sender: TObject);
begin
     eFlowsWBk := eFlowsExcelObject.Workbooks.Open('C:\software\eFlows\GUI_rev0\eFlows_rev0.xls');

     LoadParameter;

     ComboParameterToEdit.Enabled := True;
     EditValue.Enabled := True;
     LabelEditValue.Enabled := True;
     ButtonSaveParameter.Enabled := True;
end;

procedure TeFlowsForm.btnRunAllocateClick(Sender: TObject);
begin
     Screen.Cursor := crHourglass;

     eFlowsExcelObject.Run('allocate');

     eFlowsProgressForm.Timer1.Enabled := False;
     eFlowsProgressForm.Free;

     Screen.Cursor := crDefault;
end;

procedure TeFlowsForm.FormResize(Sender: TObject);
begin
     // resize components on "MarZone Database Path" group
     EditeFlowSpreadsheetPathName.Width := GroupBoxeFlowSpreadsheetOptions.Width - (3 * EditeFlowSpreadsheetPathName.Left) - ButtonUpdate.Width;
     ButtonUpdate.Left := (2 * EditeFlowSpreadsheetPathName.Left) + EditeFlowSpreadsheetPathName.Width;
     // resize components on ArcView 3.X group
     ComboPUShapefile.Width := Round(GroupBoxGIS.Width - (ComboPUShapefile.Left * 3) - ComboKeyField.Width);
     //ComboKeyField.Width := ComboPUShapefile.Width;
     ComboKeyField.Left := ComboPUShapefile.Left + ComboPUShapefile.Width + ComboPUShapefile.Left;
     LabelKeyField.Left := ComboKeyField.Left + 8;
     // resize components on PanelEditParameter panel
     ComboParameterToEdit.Width := Round((PanelEditParameter.Width - (2 * ComboParameterToEdit.Left) - ButtonSaveParameter.Width) / 2) - ComboParameterToEdit.Left;
     EditValue.Width := ComboParameterToEdit.Width;
     ButtonSaveParameter.Left := ComboParameterToEdit.Width + (ComboParameterToEdit.Left * 2);
     CheckEditAllRows.Left := ButtonSaveParameter.Left;
     EditValue.Left := ButtonSaveParameter.Left + ButtonSaveParameter.Width + ComboParameterToEdit.Left;
     LabelEditValue.Left := EditValue.Left + 8;
     if LabelDescriptive.Visible then
        LabelDescriptive.Left := EditValue.Left;
end;

function TeFlowsForm.ReturnNoOfSpecies : integer;
begin
     try
        Result := StrToInt(eFlowsWBk.Worksheets.Item['Parameters'].Cells.Item[ReturnParameterIndex('NoOfSpecies'),2].Value);

     except
           MessageDlg('Exception in ReturnNoOfSpecies',mtError,[mbOk],0);
     end;
end;

function TeFlowsForm.ReturnNoOfSeasons : integer;
begin
     try
        Result := StrToInt(eFlowsWBk.Worksheets.Item['Parameters'].Cells.Item[ReturnParameterIndex('NoOfSeasons'),2].Value);

     except
           MessageDlg('Exception in ReturnNoOfSeasons',mtError,[mbOk],0);
     end;
end;

function TeFlowsForm.ReturnTotalRun : integer;
begin
     try
        Result := StrToInt(eFlowsWBk.Worksheets.Item['Parameters'].Cells.Item[ReturnParameterIndex('TotalRun'),2].Value);

     except
           MessageDlg('Exception in ReturnTotalRun',mtError,[mbOk],0);
     end;
end;

function TeFlowsForm.ReturneFlowsPuCount : integer;
begin
     try
        Result := StrToInt(eFlowsWBk.Worksheets.Item['Parameters'].Cells.Item[ReturnParameterIndex('NoOfUnreg'),2].Value) +
                  StrToInt(eFlowsWBk.Worksheets.Item['Parameters'].Cells.Item[ReturnParameterIndex('NoOfReg'),2].Value);

     except
           MessageDlg('Exception in ReturneFlowsPuCount',mtError,[mbOk],0);
     end;
end;

function TeFlowsForm.ReturnBestRun_OFS : integer;
begin
     try
        Result := StrToInt(eFlowsWBk.Worksheets.Item['AllocTrack'].Cells.Item[7,20].Value);

     except
           MessageDlg('Exception in ReturnBestRun_OFS',mtError,[mbOk],0);
     end;
end;

function TeFlowsForm.ReturnBestRun_HH : integer;
begin
     try
        Result := StrToInt(eFlowsWBk.Worksheets.Item['AllocTrack'].Cells.Item[8,20].Value);

     except
           MessageDlg('Exception in ReturnBestRun_HH',mtError,[mbOk],0);
     end;
end;

procedure TeFlowsForm.LoadFlowScenario;
var
   iCount, iCount2 : integer;
begin
     // pull the parameters from excel
     try
        ieFlowsNoOfSeasons := ReturnNoOfSeasons;

        ParameterGrid.RowCount := ieFlowsNoOfSeasons + 1;
        ParameterGrid.ColCount := 2;
        ParameterGrid.Cells[0,0] := 'season';
        ParameterGrid.Cells[1,0] := 'scenario';
        for iCount2 := 1 to ieFlowsNoOfSeasons do
        begin
             ParameterGrid.Cells[0,iCount2] := eFlowsWBk.Worksheets.Item['SeasWetflows'].Cells.Item[1,iCount2+2].Value;
             ParameterGrid.Cells[1,iCount2] := eFlowsWBk.Worksheets.Item['SeasWetflows'].Cells.Item[2,iCount2+2].Value;
        end;
        ParameterGrid.FixedCols := 1;
        ParameterGrid.FixedRows := 1;

        CheckEditAllRows.Visible := True;
        LabelDescriptive.Visible := False;

        RetrieveScenariosAnnotation;


     except
           MessageDlg('Exception in LoadFlowScenario',mtError,[mbOk],0);
     end;
end;

procedure TeFlowsForm.SaveFlowScenario;
var
   iCount, iCount2 : integer;
begin
     // pull the parameters from excel
     try
        ieFlowsNoOfSeasons := ReturnNoOfSeasons;

        for iCount2 := 1 to ieFlowsNoOfSeasons do
            eFlowsWBk.Worksheets.Item['SeasWetflows'].Cells.Item[2,iCount2+2].Value := ParameterGrid.Cells[1,iCount2];

     except
           MessageDlg('Exception in SaveFlowScenario',mtError,[mbOk],0);
     end;
end;

procedure TeFlowsForm.LoadPUSelector;
var
   iCount, iCount2 : integer;
begin
     // pull the parameters from excel
     try
        ieFlowsPuCount := ReturneFlowsPuCount;

        ParameterGrid.RowCount := ieFlowsPuCount + 1;
        ParameterGrid.ColCount := 3;
        ParameterGrid.Cells[0,0] := 'PUID';
        ParameterGrid.Cells[1,0] := 'Name';
        ParameterGrid.Cells[2,0] := 'in use';
        ParameterGrid.FixedCols := 2;
        ParameterGrid.FixedRows := 1;

        for iCount := 1 to ieFlowsPuCount do
        begin
             ParameterGrid.Cells[0,iCount] := eFlowsWBk.Worksheets.Item['Selecta'].Cells.Item[iCount+1,3].Value;
             ParameterGrid.Cells[1,iCount] := eFlowsWBk.Worksheets.Item['Selecta'].Cells.Item[iCount+1,4].Value;
             ParameterGrid.Cells[2,iCount] := eFlowsWBk.Worksheets.Item['Selecta'].Cells.Item[iCount+1,2].Value;
        end;

        CheckEditAllRows.Visible := True;

        LabelDescriptive.Left := ComboParameterToEdit.Left;
        LabelDescriptive.Visible := True;
        LabelDescriptive.Caption := 'Planning unit is switched off if "in use" is "0"';


     except
           MessageDlg('Exception in LoadPUSelector',mtError,[mbOk],0);
     end;
end;

procedure TeFlowsForm.SavePUSelector;
var
   iCount, iCount2 : integer;
begin
     // push the parameters to excel
     try
        for iCount := 1 to ieFlowsPuCount do
            eFlowsWBk.Worksheets.Item['Selecta'].Cells.Item[iCount+1,2].Value := ParameterGrid.Cells[2,iCount];

     except
           MessageDlg('Exception in SavePUSelector',mtError,[mbOk],0);
     end;
end;

procedure TeFlowsForm.LoadSpecies;
var
   iCount, iCount2 : integer;
begin
     // pull the parameters from excel
     try
        ieFlowsNoOfSpecies := ReturnNoOfSpecies;
        ieFlowsNoOfSeasons := ReturnNoOfSeasons;

        ParameterGrid.RowCount := ieFlowsNoOfSpecies + 1;
        ParameterGrid.ColCount := 4 + ieFlowsNoOfSeasons;
        ParameterGrid.Cells[0,0] := 'Latin name';
        ParameterGrid.Cells[1,0] := 'Common name';
        ParameterGrid.Cells[2,0] := 'in use';
        ParameterGrid.Cells[3,0] := 'target';
        for iCount2 := 1 to ieFlowsNoOfSeasons do
            ParameterGrid.Cells[iCount2+3,0] := eFlowsWBk.Worksheets.Item['SpecReq'].Cells.Item[iCount2+1,1].Value;
        ParameterGrid.FixedCols := 2;
        ParameterGrid.FixedRows := 1;

        for iCount := 1 to ieFlowsNoOfSpecies do
        begin
             ParameterGrid.Cells[0,iCount] := eFlowsWBk.Worksheets.Item['SpeciesFlag'].Cells.Item[4,iCount+1].Value;
             ParameterGrid.Cells[1,iCount] := eFlowsWBk.Worksheets.Item['SpeciesFlag'].Cells.Item[5,iCount+1].Value;
             ParameterGrid.Cells[2,iCount] := eFlowsWBk.Worksheets.Item['SpeciesFlag'].Cells.Item[2,iCount+1].Value;
             ParameterGrid.Cells[3,iCount] := eFlowsWBk.Worksheets.Item['SpeciesFlag'].Cells.Item[3,iCount+1].Value;

             for iCount2 := 1 to ieFlowsNoOfSeasons do
                 ParameterGrid.Cells[iCount2+3,iCount] := eFlowsWBk.Worksheets.Item['SpecReq'].Cells.Item[iCount2+1,iCount+1].Value;
        end;

        CheckEditAllRows.Visible := True;

        LabelDescriptive.Left := ComboParameterToEdit.Left;
        LabelDescriptive.Visible := True;
        LabelDescriptive.Caption := 'Species prefers watering in this month';


     except
           MessageDlg('Exception in LoadSpecies',mtError,[mbOk],0);
     end;
end;

procedure TeFlowsForm.SaveSpecies;
var
   iCount, iCount2 : integer;
begin
     // push the parameters to excel
     try
        for iCount := 1 to ieFlowsNoOfSpecies do
        begin
             eFlowsWBk.Worksheets.Item['SpeciesFlag'].Cells.Item[2,iCount+1].Value := ParameterGrid.Cells[2,iCount];
             eFlowsWBk.Worksheets.Item['SpeciesFlag'].Cells.Item[3,iCount+1].Value := ParameterGrid.Cells[3,iCount];

             // ignore user edits for SpecReq tab and restore values if user edits them
             for iCount2 := 1 to ieFlowsNoOfSeasons do
                 ParameterGrid.Cells[iCount2+3,iCount] := eFlowsWBk.Worksheets.Item['SpecReq'].Cells.Item[iCount2+1,iCount+1].Value;
        end;

     except
           MessageDlg('Exception in SaveSpecies',mtError,[mbOk],0);
     end;
end;

procedure TeFlowsForm.SaveParameter;

  procedure AttemptUnLoadParameter(const sParam, sParamName : string);
  begin
        if (seFlowsParameterLoaded = sParam) then
           eFlowsWBk.Worksheets.Item['Parameters'].Cells.Item[ReturnParameterIndex(sParamName),2].Value := ParameterGrid.Cells[0,0]
  end;

begin
     try
        Screen.Cursor := crHourglass;

        // push the parameter to Excel with a call to the active X control
        feFlowsParameterChanged := False;

        AttemptUnLoadParameter('NoOfUnreg','NoOfUnreg');
        AttemptUnLoadParameter('NoOfReg','NoOfReg');
        AttemptUnLoadParameter('TotalVol','TotalVol');
        AttemptUnLoadParameter('NoOfSeasons','NoOfSeasons');
        AttemptUnLoadParameter('NoOfScenarios','NoOfScenarios');
        AttemptUnLoadParameter('NoOfSpecies','NoOfSpecies');
        AttemptUnLoadParameter('Temp','StartTemp');
        AttemptUnLoadParameter('BenefitThresh','BenefitThresh');
        AttemptUnLoadParameter('Iters','Iters');
        AttemptUnLoadParameter('TotalRun','TotalRun');

        if (seFlowsParameterLoaded = 'species') then
           SaveSpecies;

        if (seFlowsParameterLoaded = 'flow scenario') then
           SaveFlowScenario;

        if (seFlowsParameterLoaded = 'planning unit selector') then
           SavePUSelector;

        (*if (seFlowsParameterLoaded = 'TotalRun') then
        begin
             AllocationSummaryMenuItems;

             if (seFlowsParameterLoaded = 'NoOfSeasons') then
                RefreshOutputToMap;
        end;*)

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in SaveParameter',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

function TeFlowsForm.ReturnParameterIndex(const sParameter : string) : integer;
var
   iCount : integer;
begin
     try
        // Scan the excel worksheet to find the row index for a named parameter.
        // We scan the first 10 rows only because a blank row in the Excel sheet will trigger a runtime error.
        Result := -1;
        for iCount := 1 to 10 do
            if (eFlowsWBk.Worksheets.Item['Parameters'].Cells.Item[iCount,1].Value = sParameter) then
               Result := iCount;

        if (Result = -1) then
        begin
             Screen.Cursor := crDefault;
             MessageDlg('Cannot find eFlows parameter ' + sParameter + ' in Parameters sheet',mtError,[mbOk],0);
             Application.Terminate;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadParameter',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TeFlowsForm.LoadParameter;

  procedure AttemptLoadParameter(const sParam, sParamName : string);
  begin
        if (seFlowsParameterLoaded = sParam) then
        begin
            ParameterGrid.Cells[0,0] := eFlowsWBk.Worksheets.Item['Parameters'].Cells.Item[ReturnParameterIndex(sParamName),2].Value;

            LabelDescriptive.Left := ComboParameterToEdit.Left;
            LabelDescriptive.Visible := True;
            LabelDescriptive.Caption := eFlowsWBk.Worksheets.Item['Parameters'].Cells.Item[ReturnParameterIndex(sParamName),3].Value;

        end;
  end;

begin
     try
        Screen.Cursor := crHourglass;

        LabelDescriptive.Visible := False;
        DescriptionGrid.Visible := False;

        // pull the parameter from Excel with a call to the active X control
        feFlowsParameterChanged := False;
        seFlowsParameterLoaded := ComboParameterToEdit.Text;

        ParameterGrid.RowCount := 1;
        ParameterGrid.ColCount := 1;
        ParameterGrid.FixedCols := 0;
        ParameterGrid.FixedRows := 0;
        CheckEditAllRows.Visible := False;

        AttemptLoadParameter('NoOfUnreg','NoOfUnreg');
        AttemptLoadParameter('NoOfReg','NoOfReg');
        AttemptLoadParameter('TotalVol','TotalVol');
        AttemptLoadParameter('NoOfSeasons','NoOfSeasons');
        AttemptLoadParameter('NoOfScenarios','NoOfScenarios');
        AttemptLoadParameter('NoOfSpecies','NoOfSpecies');
        AttemptLoadParameter('Temp','StartTemp');
        AttemptLoadParameter('BenefitThresh','BenefitThresh');
        AttemptLoadParameter('Iters','Iters');
        AttemptLoadParameter('TotalRun','TotalRun');

        if (seFlowsParameterLoaded = 'species') then
           LoadSpecies;

        if (seFlowsParameterLoaded = 'flow scenario') then
           LoadFlowScenario;

        if (seFlowsParameterLoaded = 'planning unit selector') then
           LoadPUSelector;

        SetEditElement;
        AutoFitGrid(ParameterGrid,Canvas,True);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadParameter',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TeFlowsForm.ComboParameterToEditChange(Sender: TObject);
begin
     if feFlowsParameterChanged then
        if (mrYes = MessageDlg('Save parameter before loading ' + ComboParameterToEdit.Text + '?',mtConfirmation,[mbYes,mbNo],0)) then
           SaveParameter;
     LoadParameter;
     SetEditElement;
end;

procedure TeFlowsForm.FormCreate(Sender: TObject);
begin
     feFlowsParameterChanged := False;
     feFlowsSettingParameter := False;
     SCPForm.feFlowsActivated := True;

     SendMessage(GetWindow(EditeFlowSpreadsheetPathName.Handle,GW_CHILD), EM_SETREADONLY, 1, 0);
     ComboParameterToEdit.ItemIndex := 0;
     ieFlowsTableIndex := 0;
end;

procedure TeFlowsForm.ButtonSaveParameterClick(Sender: TObject);
begin
     SaveParameter;
end;

procedure TeFlowsForm.EditValueChange(Sender: TObject);
var
   iValue, iCount, iCurrentColumnWidth, iMaxColumnWidth, iAcross : integer;
begin
     if not feFlowsSettingParameter then
     begin
          feFlowsParameterChanged := True;

          feFlowsSettingParameter := True;

          // check if grid column is wide enough
          iMaxColumnWidth := ParameterGrid.ColWidths[ParameterGrid.Selection.Left];
          iCurrentColumnWidth := Canvas.TextWidth(EditValue.Text);
          if (iCurrentColumnWidth >= iMaxColumnWidth) then
             ParameterGrid.ColWidths[ParameterGrid.Selection.Left] := iMaxColumnWidth + 10;

          // update grid and scroll
          if CheckEditAllRows.Checked and (ParameterGrid.RowCount > 1) then
          begin
               for iCount := 1 to (ParameterGrid.RowCount-1) do
                   for iAcross := ParameterGrid.Selection.Left to ParameterGrid.Selection.Right do
                       ParameterGrid.Cells[iAcross,iCount] := EditValue.Text;
          end
          else
          begin
               for iCount := ParameterGrid.Selection.Top to ParameterGrid.Selection.Bottom do
                   for iAcross := ParameterGrid.Selection.Left to ParameterGrid.Selection.Right do
                       ParameterGrid.Cells[iAcross,iCount] := EditValue.Text;
          end;

          try
             iValue := Round(StrToFloat(EditValue.Text));
          except
                iValue := 0;
          end;

          feFlowsSettingParameter := False;
     end;
end;

procedure TeFlowsForm.ParameterGridKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     SetEditElement;
end;

procedure TeFlowsForm.ParameterGridMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     SetEditElement;
end;

procedure TeFlowsForm.ButtonUpdateClick(Sender: TObject);
var
   myExtents: MapWinGIS_TLB.Extents;
begin
     try
        ExecuteeFlowsThread;

        CaptureeFlowsPuOutput;

        AllocationSummaryMenuItems;
        RefreshOutputToMap;
        
        GIS_Child.ComboOutputToMapChange(Sender);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ButtonUpdateClick',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TeFlowsForm.ExecuteeFlowsThread;
var
   myExtents: MapWinGIS_TLB.Extents;
begin
     try
        if feFlowsParameterChanged then
           if (mrYes = MessageDlg('Save parameter before run?',mtConfirmation,[mbYes,mbNo],0)) then
              SaveParameter;

        Screen.Cursor := crHourglass;

        eFlowsExcelObject.Run('allocate');

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ExecuteeFlowsThread',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure ReturnTimeSpanStrings(const iSeason : integer;var sTimeSpanBegin, sTimeSpanEnd : string);
begin
     case iSeason of
          1 : sTimeSpanBegin := '2011-07-01T00:00:00+00:00';
          2 : sTimeSpanBegin := '2011-08-01T00:00:00+00:00';
          3 : sTimeSpanBegin := '2011-09-01T00:00:00+00:00';
          4 : sTimeSpanBegin := '2011-10-01T00:00:00+00:00';
          5 : sTimeSpanBegin := '2011-11-01T00:00:00+00:00';
          6 : sTimeSpanBegin := '2011-12-01T00:00:00+00:00';
          7 : sTimeSpanBegin := '2012-01-01T00:00:00+00:00';
          8 : sTimeSpanBegin := '2012-02-01T00:00:00+00:00';
          9 : sTimeSpanBegin := '2012-03-01T00:00:00+00:00';
          10 : sTimeSpanBegin := '2012-04-01T00:00:00+00:00';
          11 : sTimeSpanBegin := '2012-05-01T00:00:00+00:00';
          12 : sTimeSpanBegin := '2012-06-01T00:00:00+00:00';
     end;
     case iSeason of
          1 : sTimeSpanEnd := '2011-07-31T23:59:59+00:00';
          2 : sTimeSpanEnd := '2011-08-31T23:59:59+00:00';
          3 : sTimeSpanEnd := '2011-09-30T23:59:59+00:00';
          4 : sTimeSpanEnd := '2011-10-31T23:59:59+00:00';
          5 : sTimeSpanEnd := '2011-11-30T23:59:59+00:00';
          6 : sTimeSpanEnd := '2011-12-31T23:59:59+00:00';
          7 : sTimeSpanEnd := '2012-01-31T23:59:59+00:00';
          8 : sTimeSpanEnd := '2012-02-28T23:59:59+00:00';
          9 : sTimeSpanEnd := '2012-03-31T23:59:59+00:00';
          10 : sTimeSpanEnd := '2012-04-30T23:59:59+00:00';
          11 : sTimeSpanEnd := '2012-05-31T23:59:59+00:00';
          12 : sTimeSpanEnd := '2012-06-30T23:59:59+00:00';
     end;
end;

procedure TeFlowsForm.GenerateTimeSeriesKML(const sOutputFileName : string;
                                            const iRunToUse : integer;
                                            const fReverseClockwise : boolean);
var
   OutFile : TextFile;
   InputSF : MapWinGIS_TLB.Shapefile;
   InputShape : MapWinGIS_TLB.Shape;
   iCount, iCount2, iDisplayIndex, iNumPoints, iSeason, iDisplayValue, iPUIDIndex, iPUID : integer;
   fShapeSelected, fUseThisShape, fBlackOutlines : boolean;
   sDisplayFieldName, sTimeSpanBegin, sTimeSpanEnd, sDisplayValue : string;
   vDisplayValue : variant;
begin
     try
        Screen.Cursor := crHourglass;

        InputSF := IShapefile(GIS_Child.Map1.GetObject[GIS_Child.iPULayerHandle]);
             
        assignfile(OutFile,sOutputFileName);
        rewrite(OutFile);
        writeln(OutFile,'<?xml version="1.0" encoding="UTF-8"?>');
        writeln(OutFile,'<kml xmlns="http://www.opengis.net/kml/2.2">');
        writeln(OutFile,'  <Document>');
        writeln(OutFile,'    <Style id="transBluePoly">');
        writeln(OutFile,'      <LineStyle>');
        writeln(OutFile,'        <width>0</width>');
        writeln(OutFile,'      </LineStyle>');
        writeln(OutFile,'      <PolyStyle>');
        writeln(OutFile,'        <color>7dff0000</color>');
        writeln(OutFile,'      </PolyStyle>');
        writeln(OutFile,'    </Style>');

        // loop through shapes, adding selected shapes to new shapefile
        ieFlowsNoOfSeasons := ReturnNoOfSeasons;
        for iSeason := 1 to ieFlowsNoOfSeasons do
        begin
             // find the field index for this season in this run
             iDisplayIndex := -1;
             sDisplayFieldName := 'R' + IntToStr(iRunToUse) + 'S' + IntToStr(iSeason);
             for iCount := 0 to (InputSF.NumFields-1) do
             begin
                  if (InputSF.Field[iCount].Name = sDisplayFieldName) then
                     iDisplayIndex := iCount;
                  if (InputSF.Field[iCount].Name = seFlowsKeyField) then
                     iPUIDIndex := iCount;
             end;

             ReturnTimeSpanStrings(iSeason,sTimeSpanBegin,sTimeSpanEnd);

             for iCount := 1 to InputSF.NumShapes do
             begin
                  // extract the field value for iRunToUse
                  vDisplayValue := InputSF.CellValue[iDisplayIndex,iCount-1];
                  if (vDisplayValue <> NULL) then
                  begin
                  iDisplayValue := vDisplayValue;
                  if (iDisplayValue = 1) then
                  begin      
                       iNumPoints := InputSF.Shape[iCount-1].numPoints;
                       InputShape := InputSF.Shape[iCount-1];

                       writeln(OutFile,'    <Placemark>');
                       iPUID := InputSF.CellValue[iPUIDIndex,iCount-1];
                       writeln(OutFile,'      <name>PUID' + IntToStr(iPUID) + ' ' + SeasonToMonthString(iSeason) + '</name>');
                       writeln(OutFile,'      <TimeSpan>');
                       writeln(OutFile,'        <begin>' + sTimeSpanBegin + '</begin>');
                       writeln(OutFile,'        <begin>' + sTimeSpanEnd + '</begin>');
                       writeln(OutFile,'      </TimeSpan>');
                       writeln(OutFile,'      <styleUrl>#transBluePoly</styleUrl>');
                       writeln(OutFile,'      <Polygon>');
                       writeln(OutFile,'        <extrude>1</extrude>');
                       writeln(OutFile,'        <altitudeMode>relativeToGround</altitudeMode>');
                       writeln(OutFile,'        <outerBoundaryIs>');
                       writeln(OutFile,'          <LinearRing>');
                       writeln(OutFile,'            <coordinates>');
                       if (fReverseClockwise) then
                       begin
                            for iCount2 := iNumPoints downto 1 do
                            begin
                                 write(OutFile,'              ');
                                 write(OutFile,FloatToStr(InputShape.Point[iCount2-1].x) + ',');
                                 write(OutFile,FloatToStr(InputShape.Point[iCount2-1].y) + ',');
                                 writeln(OutFile,FloatToStr(InputShape.Point[iCount2-1].Z));
                            end;
                       end
                       else
                       begin
                            for iCount2 := 1 to iNumPoints do
                            begin
                                 write(OutFile,'              ');
                                 write(OutFile,FloatToStr(InputShape.Point[iCount2-1].x) + ',');
                                 write(OutFile,FloatToStr(InputShape.Point[iCount2-1].y) + ',');
                                 writeln(OutFile,FloatToStr(InputShape.Point[iCount2-1].Z));
                            end;
                       end;
                       writeln(OutFile,'            </coordinates>');
                       writeln(OutFile,'          </LinearRing>');
                       writeln(OutFile,'        </outerBoundaryIs>');
                       writeln(OutFile,'      </Polygon>');
                       writeln(OutFile,'    </Placemark>');
                  end;
                  end;
             end;
        end;

        writeln(OutFile,'  </Document>');
        writeln(OutFile,'</kml>');
        closefile(OutFile);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GenerateTimeSeriesKML',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TeFlowsForm.CaptureeFlowsPuOutput;
var
   myExtents: MapWinGIS_TLB.Extents;
   sTableName, sCellValue : string;
   iCount, i, j, iPUID, iPUIndex, iRowIndex, iColumnIndex, iCellValue : integer;
begin
     try
        Screen.Cursor := crHourglass;

        // Prepare SHP DBP with the correct fields
        myExtents := IExtents(GIS_Child.Map1.Extents);
        GIS_Child.RemoveAllShapes;
        DropFields(seFlowsPuLayer);
        ForceFields(seFlowsPuLayer);

        // create binary lookup grid for PUID in the excel sheet
        ieFlowsPuCount := ReturneFlowsPuCount;
        PUIDGrid.RowCount := ieFlowsPuCount;
        PUIDGrid.ColCount := 2;
        PUIDGrid.Cells[0,0] := 'PUID';
        PUIDGrid.Cells[1,0] := 'index';
        for iCount := 1 to ieFlowsPuCount do
        begin
             PUIDGrid.Cells[0,iCount-1] := eFlowsWBk.Worksheets.Item['Pu_Out'].Cells.Item[iCount+1,1].Value;
             PUIDGrid.Cells[1,iCount-1] := IntToStr(iCount);
        end;
        SortGrid(PUIDGrid,0,0,SORT_TYPE_REAL,1);

        // traverse the SHP file, writing a record for each PUID
        ThemeTable.DatabaseName := ExtractFilePath(seFlowsPuLayer);
        sTableName := ExtractFileName(seFlowsPuLayer);
        sTableName := Copy(sTableName,1,Length(sTableName) - Length(ExtractFileExt(sTableName))) + '.dbf';
        ThemeTable.TableName := sTableName;
        ThemeTable.Open;
        ieFlowsNoOfSeasons := ReturnNoOfSeasons;
        ieFlowsTotalRun := ReturnTotalRun;

        for iCount := 1 to ThemeTable.RecordCount do
        begin
             iPUID := ThemeTable.FieldByName(seFlowsKeyField).AsInteger;

             // find the matching index in the Excel sheet for this PUID using the binary lookup array
             iPUIndex := BinaryLookupGrid_Integer(PUIDGrid,iPUID,0,0,PUIDGrid.RowCount-1);
             if (iPUIndex <> -1) then
             begin
                  ThemeTable.Edit;

                  for i := 1 to ieFlowsTotalRun do
                      for j := 1 to ieFlowsNoOfSeasons do
                      begin
                           iColumnIndex := 1 + ((i - 1) * ieFlowsNoOfSeasons) + j;
                           iRowIndex := StrToInt(PUIDGrid.Cells[1,iPUIndex]) + 1;
                           sCellValue := eFlowsWBk.Worksheets.Item['Pu_Out'].Cells.Item[iRowIndex,iColumnIndex].Value;
                           if (sCellValue = '1') then
                              iCellValue := 1
                           else
                               iCellValue := 0;

                           ThemeTable.FieldByName('R' + IntToStr(i) + 'S' + IntToStr(j)).AsInteger := iCellValue;
                      end;
             end
             else
             begin
                  ThemeTable.Edit;

                  for i := 1 to ieFlowsTotalRun do
                      for j := 1 to ieFlowsNoOfSeasons do
                      begin
                           ThemeTable.FieldByName('R' + IntToStr(i) + 'S' + IntToStr(j)).AsInteger := 0;
                      end;

             end;;

             ThemeTable.Next;
        end;

        ThemeTable.Close;
        GIS_Child.RestoreAllShapes;
        GIS_Child.Map1.Extents := myExtents;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CaptureeFlowsPuOutput',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TeFlowsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     try
        eFlowsExcelObject.DisplayAlerts:= FALSE;
        if (SCPForm.SaveXLSonexit1.Checked) then
           eFlowsExcelObject.Save;
        eFlowsExcelObject.DisplayAlerts:= FALSE;
        eFlowsExcelObject.Quit;
        SCPForm.feFlowsActivated := False;
        feFlowsSummary := False;

     except
     end;
end;

procedure TeFlowsForm.RefreshGISDisplay;
var
   sFieldToMap, sTemp : string;
   iRun, iSeason, iPos : integer;
begin
     try
        ButtonUpdate.Enabled := True;
        // ComboOutputToMap.Text
        // 'Run 1 Season 1'
        // 'Run July'
        //  12345
        //      1234567890
        // R1S1
        // 'Best Season 1'
        // 'Best July'
        //  1234567890123
        if (ComboOutputToMap.Text[1] = 'B') then
        begin
             sTemp := Copy(ComboOutputToMap.Text,6,Length(ComboOutputToMap.Text)-5);
             iSeason := MonthStringToSeason(sTemp);
             iRun := ReturnBestRun_OFS;
        end
        else
        begin
             sTemp := Copy(ComboOutputToMap.Text,5,Length(ComboOutputToMap.Text)-4);
             iPos := Pos(' ',sTemp);
             iRun := StrToInt(Copy(sTemp,1,iPos-1));
             iSeason := MonthStringToSeason(Copy(sTemp,iPos+1,Length(sTemp) - iPos));
        end;

        sFieldToMap := 'R' + IntToStr(iRun) + 'S' + IntToStr(iSeason);

        GIS_Child.UpdateMap(0, 1, sFieldToMap, False, False, nil);
        // redisplay labels
        GIS_Child.RestoreLabels;

     except
           MessageDlg('Exception in RefreshGISDisplay',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TeFlowsForm.ComboOutputToMapChange(Sender: TObject);
begin
     RefreshGISDisplay;
     GIS_Child.RedrawSelection;
end;

procedure TeFlowsForm.Timer1Timer(Sender: TObject);
begin
     Timer1.Enabled := False;
     
     eFlowsProgressForm := TeFlowsProgressForm.Create(Application);
     eFlowsProgressForm.Show;
     eFlowsProgressForm.Timer1.Enabled := True;


end;

procedure TeFlowsForm.Timer2Timer(Sender: TObject);
begin
        Timer2.Enabled := False;

        eFlowsExcelObject.Run('allocate');

        eFlowsProgressForm.Timer1.Enabled := False;
        eFlowsProgressForm.Free;

        Timer3.Enabled := True;

end;

procedure TeFlowsForm.Timer3Timer(Sender: TObject);
begin
     Timer3.Enabled := False;

        CaptureeFlowsPuOutput;

        GIS_Child.ComboOutputToMapChange(Sender);
end;

procedure TeFlowsForm.ComboEditValueChange(Sender: TObject);
var
   iValue, iCount, iCurrentColumnWidth, iMaxColumnWidth, iAcross, iScenario : integer;
   ARect: TGridRect;
begin
     if not feFlowsSettingParameter then
     begin
          feFlowsParameterChanged := True;

          feFlowsSettingParameter := True;

          // check if grid column is wide enough
          iMaxColumnWidth := ParameterGrid.ColWidths[ParameterGrid.Selection.Left];
          iCurrentColumnWidth := Canvas.TextWidth(ComboEditValue.Text);
          if (iCurrentColumnWidth >= iMaxColumnWidth) then
             ParameterGrid.ColWidths[ParameterGrid.Selection.Left] := iMaxColumnWidth + 10;

          // update grid and scroll
          if CheckEditAllRows.Checked and (ParameterGrid.RowCount > 1) then
          begin
               for iCount := 1 to (ParameterGrid.RowCount-1) do
                   for iAcross := ParameterGrid.Selection.Left to ParameterGrid.Selection.Right do
                       ParameterGrid.Cells[iAcross,iCount] := ComboEditValue.Text;
          end
          else
          begin
               for iCount := ParameterGrid.Selection.Top to ParameterGrid.Selection.Bottom do
                   for iAcross := ParameterGrid.Selection.Left to ParameterGrid.Selection.Right do
                       ParameterGrid.Cells[iAcross,iCount] := ComboEditValue.Text;
          end;

          try
             iValue := Round(StrToFloat(ComboEditValue.Text));
          except
                iValue := 0;
          end;

          if (ComboParameterToEdit.Text = 'flow scenario') then
          begin
               iScenario := StrToInt(ComboEditValue.Text);
               ARect.Left := 0;
               ARect.Top := 1 + ((iScenario-1) * 2);
               ARect.Right := 1;
               ARect.Bottom := ARect.Top + 1;

               DescriptionGrid.Selection := ARect;
          end;

          feFlowsSettingParameter := False;
     end;
end;

end.
