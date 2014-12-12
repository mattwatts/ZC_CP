unit Marxan_interface;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Grids, DdeMan, Db, DBTables,
  ds, Menus;

type
  TMarxanInterfaceForm = class(TForm)
    GroupBoxMarxanDatabaseOptions: TGroupBox;
    EditMarxanDatabasePath: TEdit;
    ParameterGrid: TStringGrid;
    PanelEditParameter: TPanel;
    Label1: TLabel;
    LabelEditValue: TLabel;
    ComboParameterToEdit: TComboBox;
    EditValue: TEdit;
    PanelUpdate: TPanel;
    LabelOutputToMap: TLabel;
    BitBtnClose: TBitBtn;
    ComboOutputToMap: TComboBox;
    CheckStoreUpdates: TCheckBox;
    GroupBoxGIS: TGroupBox;
    OpenDialog1: TOpenDialog;
    ButtonSaveParameter: TButton;
    TimerMarxan: TTimer;
    CheckEditAllRows: TCheckBox;
    PopupMenu1: TPopupMenu;
    Update1: TMenuItem;
    ButtonSave: TButton;
    ButtonLoad: TButton;
    Label2: TLabel;
    ComboPUShapefile: TComboBox;
    LabelKeyField: TLabel;
    ComboKeyField: TComboBox;
    ThemeTable: TTable;
    ThemeQuery: TQuery;
    ZoneNames: TListBox;
    InputDat: TListBox;
    CostNames: TListBox;
    FeatureNames: TListBox;
    ButtonUpdate: TButton;
    procedure BitBtnCloseClick(Sender: TObject);
    procedure btnBrowseDatabaseClick(Sender: TObject);
    procedure AutoloadPathname;
    procedure AutosavePathname;
    procedure LoadParameter;
    procedure SaveParameter;
    procedure FormCreate(Sender: TObject);
    procedure ButtonSaveParameterClick(Sender: TObject);
    procedure EditValueChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ComboParameterToEditChange(Sender: TObject);
    procedure ButtonUpdateClick(Sender: TObject);
    procedure UpdateMarxan;
    procedure TimerMarxanTimer(Sender: TObject);
    procedure LoadTableToGrid(sInputFile : string);
    procedure SaveTableFromGrid(sOutputFile : string);
    procedure SetEditElement;
    procedure ParameterGridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LoadInputParameter;
    procedure UpdateInputParameter(const sParameter, sValue : string);
    procedure DeleteInputParameter(const sParameter : string);
    procedure AddInputParameter(const sParameter : string);
    procedure WriteMarxanResult(iSSOLNPUCount,iSSOLNZoneCount,iNumberOfSolutions : integer);
    procedure WriteDefaultMarxanResult(iSSOLNPUCount,iSSOLNZoneCount, iNumberOfSolutions : integer);
    procedure RefreshGISDisplay;
    procedure ComboOutputToMapChange(Sender: TObject);
    procedure Update1Click(Sender: TObject);
    procedure ExecuteCalibration;
    procedure RefreshRunNumber;
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonLoadClick(Sender: TObject);
    procedure SendResultsToGIS;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure InitDatabase;
    procedure ForceFields;
    procedure ForceAField(const sFieldName : string);
    procedure FormActivate(Sender: TObject);
    procedure InitSingleSolutionColours(const iZones : integer);
    function ReturnMarxanParameter(const sParameter : string) : string;
    function ReturnMarxanOutputFileExt(const sParameter : string) : string;
    function ReturnMarxanIntParameter(const sParameter : string) : integer;
    function Return_MZ_Filename(const s_MZ_file : string;var fFound : boolean) : string;
    function ReturnZoneName(const iZone : integer) : string;
    function ReturnCostName(const iCost : integer) : string;
    function ReturnFeatureName(const iFeature : integer) : string;
    procedure UpdateSelectedPuLock(const iLockZone : integer;SelectedPus : Array_t);
    procedure SaveScenario(sScenario : string;fForceOverWrite : boolean);
    procedure Load_Scenario(sScenario : string);
    procedure PopulateParameterList;
    procedure ReadShapeFields;
    procedure ComputeValidation;
    procedure LoadZoneCost(const sFilename : string);
    procedure SaveZoneCost(const sFilename : string);
    procedure LoadZoneBoundCost(const sFilename : string);
    procedure SaveZoneBoundCost(const sFilename : string);
    procedure LoadZoneTarget(const sFilename : string);
    procedure SaveZoneTarget(const sFilename : string);
    procedure LoadZoneContrib(const sFilename : string);
    procedure SaveZoneContrib(const sFilename : string);
    procedure ParameterGridKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SummariseFeaturesMPM(const sOutputFilename : string);
    procedure ForceClusterAnalysisOutput;
    procedure Create_R_Script(sOutput_R_script, sSolutionsFileName, sSaveName : string;
                              iClusterCount : integer);
    procedure GenerateAllConfigurations(const sOutputFilename : string);
    procedure CheckEditAllRowsClick(Sender: TObject);
    procedure DropFields;
  private
    { Private declarations }
  public
    { Public declarations }
    fSingleSolutionColours : boolean;
    SingleSolutionColours : Array_t;
    fValidateAnnealing, fValidateIterativeImprovement : boolean;
    fMarxanRunning : boolean;
    iCurrentRunExecute : integer;
  end;

  typebinsearch = record
                        iIndex : integer;
                        iPUID : integer;
                  end;

function ReturnSolutionCount(sInputDatFilename : string) : integer;

function ReturnRecordCount(sDatFilename : string) : integer;

var
   MarxanInterfaceForm: TMarxanInterfaceForm;
   sParameterLoaded, sRestoreParameter, sParameterFileLoaded, sCalibrationVariable : string;
   SSOLN, PUIDSSOLN, BESTSOLN, PUIDBEST, SOLUTIONPUCOUNT, SOLUTIONS, PUIDSOLUTIONS : Array_t;
   fUpdatedOnce, fUseDefaultMarxanResult, fCreatedSSOLN, fCreatedPUIDSSOLN, fCreatedBESTSOLN, fCreatedPUIDBEST,
   fCreatedSOLUTIONPUCOUNT, fCreatedSOLUTIONS, fCreatedPUIDSOLUTIONS, fParameterChanged, fSettingParameter,
   fCalibrationRunning, fCalibrationCheckExponent, fActiveCalibrationRunning, fActiveCalibrationOpen : boolean;
   iDDEMessageMode, iNumberOfZones, iNumberOfCosts, iNumberOfFeatures, iNumberOfPlanningUnits,
   iCalibrationNumber, iCurrentCalibrationNumber, iCalibrationInput, iExportMapDPI : integer;
   iSolutionCount : integer; // number of Marxan solutions
   iNumberOfRuns : integer; // number of Marxan solutions, limited to a maximum of 100
   rCalibrationMinimum, rCalibrationMaximum, rCalibrationCurrentValue : extended;

implementation

uses
    IniFiles, calibration, FileCtrl, LoadScenario, Math,
    GIS, SCP_Main, Miscellaneous, progress_form, MZ_system_test,
    adaptive_calibration, EditConfigurations, MapWinGIS_TLB;

{$R *.DFM}

procedure TMarxanInterfaceForm.GenerateAllConfigurations(const sOutputFilename : string);
var
   OutFile : TextFile;
   iNumberOfPUs, iNumberOfConfigurations, i, j,
   iInterval, iCount, iSwitch : integer;
begin
     assignfile(OutFile,sOutputFilename);
     rewrite(OutFile);

     iNumberOfPUs := 10;
     iNumberOfConfigurations := Floor(Power(2,iNumberOfPUs));

     write(OutFile,'Configurations');
     for i := 1 to iNumberOfConfigurations do
         write(OutFile,',' + IntToStr(i));
     writeln(OutFile);

     for i := 1 to iNumberOfPUs do
     begin
          write(OutFile,IntToStr(i));

          iInterval := Floor(Power(2,i-1));
          iCount := 0;
          iSwitch := 1;

          for j := 1 to iNumberOfConfigurations do
          begin
               Inc(iCount);

               if (iCount > iInterval) then
               begin
                    // switch
                    iCount := 1;
                    if (iSwitch = 0) then
                       iSwitch := 1
                    else
                        iSwitch := 0;
               end;

               write(OutFile,',' + IntToStr(iSwitch));
          end;

          writeln(OutFile);
     end;

     closefile(OutFile);
end;

procedure TMarxanInterfaceForm.SummariseFeaturesMPM(const sOutputFilename : string);
var
   sInFile, sTemp : string;
   InFile, OutFile : TextFile;
   iFieldCount, iCount, iMPM_Field, iFileCount : integer;
   sLine : string;
   rMPM, rTestMPM : extended;
   MPM_Values : Array_t;
begin
(*
     assignfile(OutFile,sOutputFilename);
     rewrite(OutFile);

     MPM_Values := Array_t.Create;
     MPM_Values.init(SizeOf(extended),

     rMPM := 1;
     for iCount := 1 to iNumberOfFeatures do
         MPM_.setValue(iCount,@rMPM);

     for iFileCount := 1 to iSolutionCount do
     begin
          sInFile := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
                     MarxanInterfaceForm.ReturnMarxanParameter('OUTPUTDIR') +
                     '\' +
                     MarxanInterfaceForm.ReturnMarxanParameter('SCENNAME') +
                     '_mv' + PadInt(iFileCount,5) +
                     MarxanInterfaceForm.ReturnMarxanOutputFileExt('SAVETARGMET');

          assignfile(InFile,sInFile);
          reset(InFile);
          readln(InFile,sLine);

          iMPM_Field := -1;
          iFieldCount := CountDelimitersInRow(sLine,',') + 1;
          for iCount := 1 to iFieldCount do
          begin
               sTemp := UpperCase(GetDelimitedAsciiElement(sLine,',',iCount));
               if (sTemp = 'MPM') then
                  iMPM_Field := iCount;
          end;

          iCount := 0;
          while not Eof(InFile) do
          begin
               Inc(iCount);
               readln(InFile,sLine);

               rTestMPM := StrToFloat(GetDelimitedAsciiElement(sLine,',',iMPM_Field));
               MPM_.rtnValue(iCount,@rMPM);
               if (rTestMPM < rMPM) then
                  MPM_.setValue(iCount,@rTestMPM);
          end;

          closefile(InFile);
     end;

     closefile(OutFile);  *)
end;

procedure TMarxanInterfaceForm.UpdateSelectedPuLock(const iLockZone : integer;SelectedPus : Array_t);
var
   f_pulock_FileExists, fFound, fSelected : boolean;
   sPuDatName, sPuLockFileName, sTempFileName, sLine : string;
   PuDatFile, PuLockFile, TempFile : TextFile;
   iCount, iPUID, iZone, iPUIDField, iPUIDIndex : integer;
   PUID_pudat : Array_t;
begin
     // read planning unit array from pu.dat
     PUID_pudat := Array_t.Create;
     PUID_pudat.init(SizeOf(integer),SelectedPus.lMaxSize);
     sPuDatName := Return_MZ_Filename('pu',fFound);
     if fFound and fileexists(sPuDatName) then
     begin
          assignfile(PuDatFile,sPuDatName);
          reset(PuDatFile);
          readln(PuDatFile,sLine);
          iPUIDField := ReturnFieldIndex('id', sLine);
          for iCount := 1 to SelectedPus.lMaxSize do
          begin
               readln(PuDatFile,sLine);
               iPUID := StrToInt(GetDelimitedAsciiElement(sLine,',',iPUIDField));
               PUID_pudat.setValue(iCount,@iPUID);
          end;
     end;

     sPuLockFileName := Return_MZ_Filename('pulock',fFound);
     f_pulock_FileExists := fileexists(sPuLockFileName);

     sTempFileName := ExtractFilePath(EditMarxanDatabasePath.Text) +
                      ReturnMarxanParameter('INPUTDIR') + '\temp1.dat';
     assignfile(TempFile,sTempFileName);
     rewrite(TempFile);
     writeln(TempFile,'puid,zoneid');

     // Unlock selected planning units.
     if fFound and f_pulock_FileExists then
     begin
          assignfile(PuLockFile,sPuLockFileName);
          reset(PuLockFile);
          readln(PuLockFile,sLine);

          while not Eof(PuLockFile) do
          begin
               readln(PuLockFile,sLine);
               iPUID := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
               iZone := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
               // find index of this planning unit in the global list of planning units
               iPUIDIndex := BinaryLookup_Integer(PUID_pudat,iPUID,1,PUID_pudat.lMaxSize);
               SelectedPus.rtnValue(iPUIDIndex,@fSelected);
               if not fSelected then
                  writeln(TempFile,IntToStr(iPUID) + ',' + IntToStr(iZone));
          end;

          closefile(PuLockFile);
     end;

     // Lock selected planning units to the designated zone.
     // If zone is zero, we are not locking the selected planning units.
     if (iLockZone > 0) then
        for iCount := 1 to SelectedPus.lMaxSize do
        begin
             SelectedPus.rtnValue(iCount,@fSelected);
             if fSelected then
             begin
                  PUID_pudat.rtnValue(iCount,@iPUID);
                  writeln(TempFile,IntToStr(iPUID) + ',' + IntToStr(iLockZone));
             end;
        end;

     closefile(TempFile);
     PUID_pudat.Destroy;
end;

function TMarxanInterfaceForm.ReturnMarxanIntParameter(const sParameter : string) : integer;
var
   sParameterValue : string;
   iParameterValue : integer;
begin
     sParameterValue := ReturnMarxanParameter(sParameter);    

     try
        iParameterValue := StrToInt(sParameterValue);

     except
           iParameterValue := -999;
     end;

     Result := iParameterValue;
end;

function TMarxanInterfaceForm.ReturnMarxanParameter(const sParameter : string) : string;
var
   iCount, iLengthRow, iLengthScanString : integer;
   sResult : string;
begin
     if (InputDat.Items.Count = 0) then
        InputDat.Items.LoadFromFile(EditMarxanDatabasePath.Text);

     sResult := '';
     for iCount := 0 to (InputDat.Items.Count - 1) do
         if (Pos(sParameter,InputDat.Items.Strings[iCount]) = 1) then
         begin
              iLengthRow := Length(InputDat.Items.Strings[iCount]);
              iLengthScanString := Length(sParameter);

              sResult := Copy(InputDat.Items.Strings[iCount],iLengthScanString+1,iLengthRow-iLengthScanString);
              sResult := TrimLeadSpaces(sResult);
         end;

     Result := sResult;
end;

function TMarxanInterfaceForm.ReturnMarxanOutputFileExt(const sParameter : string) : string;
var
   sResult : string;
begin
     sResult := ReturnMarxanParameter(sParameter);

     if (sResult = '1') then
        Result := '.dat'
     else
     if (sResult = '2') then
        Result := '.txt'
     else
     if (sResult = '3') then
        Result := '.csv'
     else
         Result := '';
end;

function TMarxanInterfaceForm.Return_MZ_Filename(const s_MZ_file : string;var fFound : boolean) : string;
var
   sInputDir : string;
begin
     sInputDir := ReturnMarxanParameter('INPUTDIR');
     fFound := False;

     if (s_MZ_file = 'zones') then
     begin
          Result := ExtractFilePath(EditMarxanDatabasePath.Text) +
                    sInputDir + '\' +
                    ReturnMarxanParameter('ZONESNAME');
          fFound := True;
     end;

     if (s_MZ_file = 'costs') then
     begin
          Result := ExtractFilePath(EditMarxanDatabasePath.Text) +
                    sInputDir + '\' +
                    ReturnMarxanParameter('COSTSNAME');
          fFound := True;
     end;

     if (s_MZ_file = 'pu') then
     begin
          Result := ExtractFilePath(EditMarxanDatabasePath.Text) +
                    sInputDir + '\' +
                    ReturnMarxanParameter('PUNAME');
          fFound := True;
     end;

     if (s_MZ_file = 'spec') then
     begin
          Result := ExtractFilePath(EditMarxanDatabasePath.Text) +
                    sInputDir + '\' +
                    ReturnMarxanParameter('SPECNAME');
          fFound := True;
     end;

     if (s_MZ_file = 'pulock') then
     begin
          Result := ExtractFilePath(EditMarxanDatabasePath.Text) +
                    sInputDir + '\' +
                    ReturnMarxanParameter('PULOCKNAME');
          fFound := True;
     end;
end;

function TMarxanInterfaceForm.ReturnZoneName(const iZone : integer) : string;
var
   sInFile, sLine : string;
   InFile : TextFile;
   fFound : boolean;
begin
     // returns the name of the zone with 1-based index iZone
     if (ZoneNames.Items.Count = 0) then
     begin
          sInFile := Return_MZ_Filename('zones',fFound);

          if fileexists(sInFile) then
          begin
               assignfile(InFile,sInFile);
               reset(InFile);
               readln(InFile);
               while not Eof(InFile) do
               begin
                    readln(InFile,sLine);

                    ZoneNames.Items.Add(GetDelimitedAsciiElement(sLine,',',2));
               end;
               closefile(InFile);
          end
          else
          begin
               ZoneNames.Items.Add('Available');
               ZoneNames.Items.Add('Reserved');
          end;
     end;

     if (ZoneNames.Items.Count = 0) then
        Result := ''
     else
         Result := ZoneNames.Items.Strings[iZone-1];
end;

function TMarxanInterfaceForm.ReturnCostName(const iCost : integer) : string;
var
   sInFile, sLine : string;
   InFile : TextFile;
   fFound : boolean;
begin
     // returns the name of the cost with 1-based index iCost
     if (CostNames.Items.Count = 0) then
     begin
          sInFile := Return_MZ_Filename('costs',fFound);

          if fileexists(sInFile) then
          begin
               assignfile(InFile,sInFile);
               reset(InFile);
               readln(InFile);
               while not Eof(InFile) do
               begin
                    readln(InFile,sLine);

                    CostNames.Items.Add(GetDelimitedAsciiElement(sLine,',',2));
               end;
               closefile(InFile);
          end
          else
          begin
               CostNames.Items.Add('cost');
          end;
     end;

     if (CostNames.Items.Count = 0) then
        Result := ''
     else
         Result := CostNames.Items.Strings[iCost-1];
end;

function TMarxanInterfaceForm.ReturnFeatureName(const iFeature : integer) : string;
var
   sInFile, sLine : string;
   InFile : TextFile;
   fFound : boolean;
   iNameField, iPos : integer;
begin
     // returns the name of the Feature with 1-based index iFeature
     if (FeatureNames.Items.Count = 0) then
     begin
          sInFile := Return_MZ_Filename('spec',fFound);

          if fileexists(sInFile) then
          begin
               assignfile(InFile,sInFile);
               reset(InFile);
               readln(InFile,sLine);
               // find the field id of the name field

               iPos := Pos('name',sLine);
               sLine := Copy(sLine,1,iPos-1);
               iNameField := CountDelimitersInRow(sLine,',') + 1;

               while not Eof(InFile) do
               begin
                    readln(InFile,sLine);

                    FeatureNames.Items.Add(GetDelimitedAsciiElement(sLine,',',iNameField));
               end;
               closefile(InFile);
          end;
     end;

     if (FeatureNames.Items.Count = 0) then
        Result := ''
     else
         Result := FeatureNames.Items.Strings[iFeature-1];
end;

procedure TMarxanInterfaceForm.InitSingleSolutionColours(const iZones : integer);
var
   AColor : TColor;
   iCount : integer;
begin
     if fSingleSolutionColours then
        SingleSolutionColours.Destroy;

     fSingleSolutionColours := True;

     SingleSolutionColours := Array_t.Create;
     SingleSolutionColours.init(SizeOf(TColor),iZones);

     if (iZones = 4) then
     begin
          AColor := clWhite;
          SingleSolutionColours.setValue(1,@AColor);
          AColor := clLime;
          SingleSolutionColours.setValue(2,@AColor);
          AColor := clBlue;
          SingleSolutionColours.setValue(3,@AColor);
          AColor := clFuchsia;
          SingleSolutionColours.setValue(4,@AColor);
     end
     else
     begin
          for iCount := 1 to iZones do
          begin
               if (iCount = 1) then
                  AColor := clWhite
               else
                   AColor := IndexToColour(iCount);

               SingleSolutionColours.setValue(iCount,@AColor);
          end;
     end;
end;

function ReturnDisplayZoneIndex : integer;
begin
     if fMarZone then
        ReturnDisplayZoneIndex := 1
     else
         ReturnDisplayZoneIndex := 2;
end;

procedure TMarxanInterfaceForm.RefreshRunNumber;
var
   iCount, iGISChild : integer;
   sComboText : string;
   AChild : TGIS_Child;
begin
     sComboText := ComboOutputToMap.Text;

     ComboOutputToMap.Items.Clear;
     if (iNumberOfZones < 2) then
     //   ComboOutputToMap.Items.Add('Zone');
        AChild.ComboOutputToMap.Items.Add('Selection Frequency ' + ReturnZoneName(1) + ' Zone');
     for iCount := 1 to iNumberOfZones do
         ComboOutputToMap.Items.Add('Selection Frequency ' + ReturnZoneName(iCount) + ' Zone');
     ComboOutputToMap.Items.Add('Best Solution');
     for iCount := 1 to iNumberOfRuns do
         ComboOutputToMap.Items.Add('Solution ' + IntToStr(iCount));

     if (ComboOutputToMap.Items.IndexOf(sComboText) > -1) then
        ComboOutputToMap.Text := sComboText
     else
         ComboOutputToMap.Text := 'Selection Frequency ' + ReturnZoneName(ReturnDisplayZoneIndex) + ' Zone';

     iGISChild := SCPForm.ReturnGISChildIndex;
     if (iGISChild > -1) then
     begin
          AChild := TGIS_Child(SCPForm.MDIChildren[iGISChild]);

          if (AChild <> nil) then
          begin
               AChild.ComboOutputToMap.Items.Clear;
               if (iNumberOfZones < 2) then
               //   AChild.ComboOutputToMap.Items.Add('Zone');
                  AChild.ComboOutputToMap.Items.Add('Selection Frequency ' + ReturnZoneName(1) + ' Zone');
               for iCount := 1 to iNumberOfZones do
                   AChild.ComboOutputToMap.Items.Add('Selection Frequency ' + ReturnZoneName(iCount) + ' Zone');
               AChild.ComboOutputToMap.Items.Add('Best Solution');
               for iCount := 1 to iNumberOfRuns do
                   AChild.ComboOutputToMap.Items.Add('Solution ' + IntToStr(iCount));

               if (AChild.ComboOutputToMap.Items.IndexOf(sComboText) > -1) then
                  AChild.ComboOutputToMap.Text := sComboText
               else
                   AChild.ComboOutputToMap.Text := 'Selection Frequency ' + ReturnZoneName(ReturnDisplayZoneIndex) + ' Zone';
          end;
     end;
end;

procedure TMarxanInterfaceForm.AutoloadPathname;
var
   AIniFile : TIniFile;
   sBaseDirectory : string;
   iGISChild : integer;
begin
     sBaseDirectory := ExtractFilePath(Application.Exename);
     AIniFile := TIniFile.Create(sBaseDirectory + 'ZonaeCogito.ini');

     sRestoreParameter := AIniFile.ReadString('ZonaeCogito','defaultpathname','');
     ComboPUShapefile.Text := AIniFile.ReadString('GIS','PlanningUnitShapefile',ComboPUShapefile.Text);
     ComboKeyField.Text := AIniFile.ReadString('GIS','KeyField',ComboKeyField.Text);

     iExportMapDPI := AIniFile.ReadInteger('GIS','ExportMapDPI',150);

     ComboParameterToEdit.Text := AIniFile.ReadString('GIS','ParameterLoaded','pu');
     ComboOutputToMap.Text := AIniFile.ReadString('GIS','OutputToMap','Selection Frequency Zone 2');

     iGISChild := SCPForm.ReturnGISChildIndex;
     if (iGISChild > -1) then
        TGIS_Child(MDIChildren[iGISChild]).ComboOutputToMap.Text := AIniFile.ReadString('GIS','OutputToMap','Selection Frequency Zone 2');

     AIniFile.Free;
end;

procedure TMarxanInterfaceForm.AutosavePathname;
var
   AIniFile : TIniFile;
   sBaseDirectory : string;
begin
     sBaseDirectory := ExtractFilePath(Application.Exename);
     AIniFile := TIniFile.Create(sBaseDirectory + 'ZonaeCogito.ini');

     if (EditMarxanDatabasePath.Text <> '') then
        AIniFile.WriteString('ZonaeCogito','defaultpathname',EditMarxanDatabasePath.Text);

     if (ComboPUShapefile.Text <> '') then
     begin
          AIniFile.WriteString('GIS','PlanningUnitShapefile',ComboPUShapefile.Text);
          AIniFile.WriteString('GIS','KeyField',ComboKeyField.Text);
          AIniFile.WriteString('GIS','ParameterLoaded',ComboParameterToEdit.Text);
          AIniFile.WriteString('GIS','OutputToMap',ComboOutputToMap.Text);
     end;

     AIniFile.Free;
end;

procedure TMarxanInterfaceForm.LoadTableToGrid(sInputFile : string);
begin
     FasterLoadCSV2StringGrid(ParameterGrid,sInputFile);

     ParameterGrid.FixedRows := 1;
     ParameterGrid.FixedCols := 1;

     AutoFitGrid(ParameterGrid,Canvas,True);
end;

procedure TMarxanInterfaceForm.LoadParameter;
var
   sFilename : string;
begin
     try
        Screen.Cursor := crHourglass;

        fParameterChanged := False;
        sParameterLoaded := ComboParameterToEdit.Text;

        if (sParameterLoaded = 'BLM')
        or (sParameterLoaded = 'NUMREPS')
        or (sParameterLoaded = 'PROBABILITYWEIGHTING')
        or (sParameterLoaded = 'NUMITNS')
        or (sParameterLoaded = 'ASYMMETRICCONNECTIVITY') then
        begin
             sParameterFileLoaded := '';
             LoadInputParameter;
             ParameterGrid.ColCount := 1;
             ParameterGrid.RowCount := 1;
             AutoFitGrid(ParameterGrid,Canvas,True);
        end
        else
        begin
             sFilename := ExtractFilePath(EditMarxanDatabasePath.Text) +
                          ReturnMarxanParameter('INPUTDIR') + '\' +
                          ReturnMarxanParameter(sParameterLoaded + 'NAME');

             if fileexists(sFilename) then
             begin
                  sParameterFileLoaded := sFilename;
                  if (sParameterLoaded = 'ZONECOST') then
                     LoadZoneCost(sFilename)
                  else
                      if (sParameterLoaded = 'ZONEBOUNDCOST') then
                         LoadZoneBoundCost(sFilename)
                      else
                          if (sParameterLoaded = 'ZONETARGET') then
                             LoadZoneTarget(sFilename)
                          else
                              if (sParameterLoaded = 'ZONECONTRIB')
                              or (sParameterLoaded = 'ZONECONTRIB2') then
                                 LoadZoneContrib(sFilename)
                              else
                                  LoadTableToGrid(sFilename);
             end;
        end;

        Screen.Cursor := crDefault;
        
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadParameter',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMarxanInterfaceForm.SaveTableFromGrid(sOutputFile : string);
var
   OutputFile : TextFile;
   sOutputLine : string;
   iRowCount,iColCount : integer;
begin
     assignfile(OutputFile,sOutputFile);
     rewrite(OutputFile);

     for iRowCount := 0 to (ParameterGrid.RowCount-1) do
     begin
          sOutputLine := ParameterGrid.Cells[0,iRowCount];
          for iColCount := 1 to (ParameterGrid.ColCount-1) do
              sOutputLine := sOutputLine + ',' + ParameterGrid.Cells[iColCount,iRowCount];
          writeln(OutputFile,sOutputLine);
     end;

     closefile(OutputFile);
end;

procedure TMarxanInterfaceForm.LoadInputParameter;
var
   InputFile : TextFile;
   sInputLine, sParameterToEdit, sTmp : string;
   iLengthParameterToEdit : integer;
begin
     assignfile(InputFile,EditMarxanDatabasePath.Text);
     reset(InputFile);

     repeat
           readln(InputFile,sInputLine);

           if (Pos(UpperCase(ComboParameterToEdit.Text),UpperCase(sInputLine)) = 1) then
           begin
                sParameterToEdit := ComboParameterToEdit.Text;
                iLengthParameterToEdit := Length(sParameterToEdit);

                sTmp := Copy(sInputLine,iLengthParameterToEdit+1,Length(sInputLine)-iLengthParameterToEdit);

                sTmp := TrimLeadSpaces(sTmp);

                ParameterGrid.Cells[0,0] := sTmp;
                SetEditElement;
           end;

     until Eof(InputFile);

     closefile(InputFile);
end;

procedure TMarxanInterfaceForm.DeleteInputParameter(const sParameter : string);
var
   InputFile, OutputFile : TextFile;
   sInputLine : string;
begin
     assignfile(InputFile,EditMarxanDatabasePath.Text);
     reset(InputFile);
     assignfile(OutputFile,EditMarxanDatabasePath.Text + '~');
     rewrite(OutputFile);

     repeat
           readln(InputFile,sInputLine);

           if not (Pos(UpperCase(sParameter),UpperCase(sInputLine)) = 1) then
              writeln(OutputFile,sInputLine);

     until Eof(InputFile);

     closefile(InputFile);
     closefile(OutputFile);

     deletefile(EditMarxanDatabasePath.Text);
     ACopyFile(EditMarxanDatabasePath.Text + '~',EditMarxanDatabasePath.Text);
     deletefile(EditMarxanDatabasePath.Text + '~');
end;

procedure TMarxanInterfaceForm.AddInputParameter(const sParameter : string);
var
   InputFile, OutputFile : TextFile;
   sInputLine : string;
begin
     assignfile(InputFile,EditMarxanDatabasePath.Text);
     reset(InputFile);
     assignfile(OutputFile,EditMarxanDatabasePath.Text + '~');
     rewrite(OutputFile);

     repeat
           readln(InputFile,sInputLine);
           writeln(OutputFile,sInputLine);

     until Eof(InputFile);

     writeln(OutputFile,sParameter);

     closefile(InputFile);
     closefile(OutputFile);

     deletefile(EditMarxanDatabasePath.Text);
     ACopyFile(EditMarxanDatabasePath.Text + '~',EditMarxanDatabasePath.Text);
     deletefile(EditMarxanDatabasePath.Text + '~');
end;

procedure TMarxanInterfaceForm.UpdateInputParameter(const sParameter, sValue : string);
// parse the input.dat file (writing it to another file) until finding a line that contains sParameterLoaded.  Substitute the new value.
var
   InputFile, OutputFile : TextFile;
   sInputLine : string;
begin
     assignfile(InputFile,EditMarxanDatabasePath.Text);
     reset(InputFile);
     assignfile(OutputFile,EditMarxanDatabasePath.Text + '~');
     rewrite(OutputFile);

     repeat
           readln(InputFile,sInputLine);

           if (Pos(UpperCase(sParameterLoaded),UpperCase(sInputLine)) = 1) then
              writeln(OutputFile,UpperCase(sParameterLoaded) + ' ' + sValue)
           else
               writeln(OutputFile,sInputLine);

     until Eof(InputFile);

     closefile(InputFile);
     closefile(OutputFile);

     deletefile(EditMarxanDatabasePath.Text);
     ACopyFile(EditMarxanDatabasePath.Text + '~',EditMarxanDatabasePath.Text);
     deletefile(EditMarxanDatabasePath.Text + '~');
end;

procedure TMarxanInterfaceForm.SaveParameter;
begin
     fParameterChanged := False;
     if (sParameterFileLoaded <> '') then
     begin
          if (sParameterLoaded = 'ZONECOST') then
             SaveZoneCost(sParameterFileLoaded)
          else
              if (sParameterLoaded = 'ZONEBOUNDCOST') then
                 SaveZoneBoundCost(sParameterFileLoaded)
              else
                  if (sParameterLoaded = 'ZONETARGET') then
                     SaveZoneTarget(sParameterFileLoaded)
                  else
                      if (sParameterLoaded = 'ZONECONTRIB')
                      or (sParameterLoaded = 'ZONECONTRIB2') then
                         SaveZoneContrib(sParameterFileLoaded)
                      else
                          SaveTableFromGrid(sParameterFileLoaded);
     end
     else
         UpdateInputParameter(sParameterLoaded,EditValue.Text);

     iSolutionCount := ReturnSolutionCount(EditMarxanDatabasePath.Text);
     if (iSolutionCount > 100) then
        iNumberOfRuns := 100
     else
         iNumberOfRuns := iSolutionCount;

     RefreshRunNumber;
end;

procedure TMarxanInterfaceForm.BitBtnCloseClick(Sender: TObject);
begin
     AutosavePathname;
     Close;
end;

procedure TMarxanInterfaceForm.InitDatabase;
begin
     try
        if (EditMarxanDatabasePath.Text <> '') then
        begin
             PopulateParameterList;
             LoadParameter;
             SetEditElement;

             iSolutionCount := ReturnSolutionCount(EditMarxanDatabasePath.Text);
             if (iSolutionCount > 100) then
                iNumberOfRuns := 100
             else
                 iNumberOfRuns := iSolutionCount;

             iNumberOfZones := ReturnRecordCount(ExtractFilePath(EditMarxanDatabasePath.Text) +
                               ReturnMarxanParameter('INPUTDIR') + '\' +
                               ReturnMarxanParameter('ZONESNAME'));

             //fMarZone := (iNumberOfZones > 2);
             fMarZone := (ReturnMarxanParameter('ZONESNAME') <> '');

             iNumberOfCosts := ReturnRecordCount(ExtractFilePath(EditMarxanDatabasePath.Text) +
                               ReturnMarxanParameter('INPUTDIR') + '\' +
                               ReturnMarxanParameter('COSTSNAME'));
             iNumberOfFeatures := ReturnRecordCount(ExtractFilePath(EditMarxanDatabasePath.Text) +
                                  ReturnMarxanParameter('INPUTDIR') + '\' +
                                  ReturnMarxanParameter('SPECNAME'));
             RefreshRunNumber;

             ButtonUpdate.Enabled := True;
             ButtonSave.Enabled := True;
             ComboParameterToEdit.Enabled := True;
             ButtonSaveParameter.Enabled := True;
             EditValue.Enabled := True;
             //ScrollValue.Enabled := True;

             InitSingleSolutionColours(iNumberOfZones);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Initialise Marxan Database',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMarxanInterfaceForm.btnBrowseDatabaseClick(Sender: TObject);
begin
     if (EditMarxanDatabasePath.Text = '') then
        OpenDialog1.Filename := sRestoreParameter;

     if OpenDialog1.Execute then
     begin
          EditMarxanDatabasePath.Text := OpenDialog1.Filename;
          //\;
     end;
end;

procedure TMarxanInterfaceForm.FormCreate(Sender: TObject);
begin
     fParameterChanged := False;
     fSettingParameter := False;
     fUpdatedOnce := False;
     fCalibrationRunning := False;
     fCalibrationCheckExponent := False;
     fValidateAnnealing := False;
     fValidateIterativeImprovement := False;
     fSingleSolutionColours := False;
     fMarxanRunning := False;
     fActiveCalibrationRunning := False;
     fActiveCalibrationOpen := False;

     iCalibrationNumber := 0;
     iCurrentCalibrationNumber := 0;
     iCalibrationInput := 0;
     iDDEMessageMode := 0;
     iNumberOfZones := 0;
     iNumberOfCosts := 0;
     iNumberOfRuns := 0;
     iExportMapDPI := 150;

     rCalibrationMinimum := 0;
     rCalibrationMaximum := 0;
     rCalibrationCurrentValue := 0;

     sCalibrationVariable := '';

     SCPForm.fMarxanActivated := True;
end;


procedure TMarxanInterfaceForm.ButtonSaveParameterClick(Sender: TObject);
begin
     if fParameterChanged then
        SaveParameter;
end;

procedure TMarxanInterfaceForm.EditValueChange(Sender: TObject);
var
   iValue, iCount, iCurrentColumnWidth, iMaxColumnWidth, iAcross : integer;
begin
     if not fSettingParameter then
     begin
          fParameterChanged := True;

          fSettingParameter := True;

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

               if (ComboParameterToEdit.Text = 'ZONEBOUNDCOST') then
                  for iCount := 1 to (ParameterGrid.RowCount-1) do
                      for iAcross := ParameterGrid.Selection.Left to ParameterGrid.Selection.Right do
                          ParameterGrid.Cells[iCount,iAcross] := EditValue.Text;
          end
          else
          begin
               for iCount := ParameterGrid.Selection.Top to ParameterGrid.Selection.Bottom do
                   for iAcross := ParameterGrid.Selection.Left to ParameterGrid.Selection.Right do
                       ParameterGrid.Cells[iAcross,iCount] := EditValue.Text;

               if (ComboParameterToEdit.Text = 'ZONEBOUNDCOST') then
                  for iCount := ParameterGrid.Selection.Top to ParameterGrid.Selection.Bottom do
                      for iAcross := ParameterGrid.Selection.Left to ParameterGrid.Selection.Right do
                          ParameterGrid.Cells[iCount,iAcross] := EditValue.Text;
          end;

          try
             iValue := Round(StrToFloat(EditValue.Text));
          except
                iValue := 0;
          end;

          fSettingParameter := False;
     end;
end;

procedure TMarxanInterfaceForm.FormResize(Sender: TObject);
begin
     // resize components on "MarZone Database Path" group
     EditMarxanDatabasePath.Width := GroupBoxMarxanDatabaseOptions.Width - (3 * EditMarxanDatabasePath.Left) - ButtonUpdate.Width;
     ButtonUpdate.Left := (2 * EditMarxanDatabasePath.Left) + EditMarxanDatabasePath.Width;
     // resize components on ArcView 3.X group
     ComboPUShapefile.Width := Round(GroupBoxGIS.Width - (ComboPUShapefile.Left * 3) - ComboKeyField.Width);
     //ComboKeyField.Width := ComboPUShapefile.Width;
     ComboKeyField.Left := ComboPUShapefile.Left + ComboPUShapefile.Width + ComboPUShapefile.Left;
     LabelKeyField.Left := ComboKeyField.Left + 8;
     // resize components on PanelEditParameter panel
     ComboParameterToEdit.Width := Round((PanelEditParameter.Width - (2 * ComboParameterToEdit.Left) - ButtonSaveParameter.Width) / 2) - ComboParameterToEdit.Left;
     EditValue.Width := ComboParameterToEdit.Width;
     //ScrollValue.Width := ComboParameterToEdit.Width;
     ButtonSaveParameter.Left := ComboParameterToEdit.Width + (ComboParameterToEdit.Left * 2);
     CheckEditAllRows.Left := ButtonSaveParameter.Left;
     EditValue.Left := ButtonSaveParameter.Left + ButtonSaveParameter.Width + ComboParameterToEdit.Left;
     LabelEditValue.Left := EditValue.Left + 8;
     //ScrollValue.Left := EditValue.Left + EditValue.Width + ComboParameterToEdit.Left;
     //LabelSlideValue.Left := ScrollValue.Left + 8;
     // resize components on PanelUpdate panel
     //CheckStoreUpdates.Left := (2 * ButtonUpdate.Left) + ButtonUpdate.Width;
     ComboOutputToMap.Left := ButtonLoad.Left + ButtonLoad.Width + ButtonUpdate.Left;
     LabelOutputToMap.Left := ComboOutputToMap.Left + 8;
     //ComboOutputToMap.Width := PanelUpdate.Width - (5 * ButtonUpdate.Left) - ButtonUpdate.Width - CheckStoreUpdates.Width - BitBtnClose.Width;
     ComboOutputToMap.Width := PanelUpdate.Width - ButtonLoad.Left - ButtonLoad.Width - (3 * ButtonUpdate.Left) - BitBtnClose.Width;
     BitBtnClose.Left := PanelUpdate.Width - ButtonUpdate.Left - BitBtnClose.Width;
end;

procedure TMarxanInterfaceForm.ComboParameterToEditChange(
  Sender: TObject);
begin
     if fParameterChanged then
        if (mrYes = MessageDlg('Save parameter before loading ' + ComboParameterToEdit.Text + '?',mtConfirmation,[mbYes,mbNo],0)) then
           SaveParameter;
     LoadParameter;
     SetEditElement;
end;

procedure TMarxanInterfaceForm.ButtonUpdateClick(Sender: TObject);
begin
     if fParameterChanged then
        if (mrYes = MessageDlg('Save parameter before run?',mtConfirmation,[mbYes,mbNo],0)) then
           SaveParameter;

     Screen.Cursor := crHourglass;

     fUpdatedOnce := True;
     iCurrentRunExecute := 1;
     UpdateMarxan;

     ProgressForm := TProgressForm.Create(Application);
     with ProgressForm do
     begin
          LabelCalibration.Visible := False;
          ProgressBarCalibration.Visible := False;
          BitBtnCancel.Top := BitBtnCancel.Top - 48;
          ProgressForm.Height := ProgressForm.Height - 48;

          ProgressForm.Show;
          LabelMarxan.Caption := 'Marxan';
          ProgressBarMarxan.Max := iSolutionCount;
     end;
end;

procedure TMarxanInterfaceForm.ForceClusterAnalysisOutput;
begin
     //
     DeleteInputParameter('SAVESOLUTIONSMATRIX');
     AddInputParameter('SAVESOLUTIONSMATRIX 3');
end;

procedure TMarxanInterfaceForm.UpdateMarxan;
var
   sExecuteString, sMarxanExecutable, sR_Install_Path : string;
   iCount : integer;
begin
     if (EditMarxanDatabasePath.Text <> '') then
     begin
          // f64BitOS
          if f64BitOS then
          begin
               if fMarZone then
                  sMarxanExecutable := 'MarZone_x64.exe'
               else
                   sMarxanExecutable := 'Marxan_x64.exe';
          end
          else
          begin
               if fMarZone then
                  sMarxanExecutable := 'MarZone.exe'
               else
                   sMarxanExecutable := 'Marxan.exe';
          end;

          sExecuteString := ExtractFilePath(EditMarxanDatabasePath.Text) + sMarxanExecutable + ' -s';

          if not fileexists(ExtractFilePath(EditMarxanDatabasePath.Text) + sMarxanExecutable) then
             // copy marxan.exe from the ZC program folder
             ACopyFile(ExtractFilePath(Application.Exename) + sMarxanExecutable,
                       ExtractFilePath(EditMarxanDatabasePath.Text) + sMarxanExecutable);

          // force DoClusterAnalysis1
          if SCPForm.DoClusterAnalysis1.Checked then
          begin
               sR_Install_Path := Return_R_InstallPath;

               if (sR_Install_Path <> '') then
                  ForceClusterAnalysisOutput;
          end;

          if FileExists(ExtractFilePath(EditMarxanDatabasePath.Text) + sMarxanExecutable) then
          begin
               ButtonUpdate.Enabled := False;

               DeleteFile(ExtractFilePath(EditMarxanDatabasePath.Text) + 'sync');
               for iCount := 1 to iSolutionCount do
                   DeleteFile(ExtractFilePath(EditMarxanDatabasePath.Text) + 'sync' + IntToStr(iCount));
               DeleteFile(ExtractFilePath(EditMarxanDatabasePath.Text) + 'stop_error.txt');

               TimerMarxan.Enabled := False;

               fMarxanRunning := True;
               ProgramRunWait(sExecuteString,
                              ExtractFilePath(EditMarxanDatabasePath.Text),
                              False,
                              SCPForm.HideMarxanConsole1.Checked);
               fMarxanRunning := False;

               // wait for MarZone to finish executing
               TimerMarxan.Enabled := True;
          end
          else
          begin
               Screen.Cursor := crDefault;
               MessageDlg('Cannot find Marxan software',mtError,[mbOk],0);
          end;
     end;
end;

function ReturnRecordCount(sDatFilename : string) : integer;
var
   InputFile : TextFile;
   sLine : string;
begin
     if fileexists(sDatFilename) then
     begin
          assignfile(InputFile,sDatFilename);
          reset(InputFile);
          readln(InputFile);
          Result := 0;
          repeat
                readln(InputFile,sLine);

                Inc(Result);

          until Eof(InputFile);
          closefile(InputFile);
     end
     else
         Result := 2;
end;

function ReturnSolutionCount(sInputDatFilename : string) : integer;
var
   InputFile : TextFile;
   sLine, sTmp : string;
   iPos : integer;
begin
     // read the number of runs from the input.dat parameter file
     // NUMREPS 2
     assignfile(InputFile,sInputDatFilename);
     reset(InputFile);
     repeat
           readln(InputFile,sLine);

           iPos := Pos('NUMREPS',UpperCase(sLine));
           if (iPos > 0) then
           begin
                sTmp := Copy(sLine,8,Length(sLine)-7);

                sTmp := TrimLeadSpaces(sTmp);

                Result := StrToInt(sTmp);
           end;

     until Eof(InputFile);
     closefile(InputFile);
end;

procedure DebugReadMarxanResult(const sDatabasePath, sOutputDirName, sOutputFileName : string);
var
   iCount, iValue : integer;
   Debugfile : TextFile;
   fDebug : boolean;
   sLine, sInFile, sOutFile : string;
begin
     try
        fDebug := False;

        if fDebug then
        begin
             // dump Selection Frequency arrays to file
             sOutFile := ExtractFilePath(sDatabasePath) + sOutputDirName + '\' + sOutputFileName + '_ssoln_check_puid.txt';
             assignfile(Debugfile,sOutFile);
             rewrite(DebugFile);
             for iCount := 1 to PUIDSSOLN.lMaxSize do
             begin
                  PUIDSSOLN.rtnValue(iCount,@iValue);
                  writeln(DebugFile,IntToStr(iValue));
             end;
             closefile(DebugFile);
             sOutFile := ExtractFilePath(sDatabasePath) + sOutputDirName + '\' + sOutputFileName + '_ssoln_check_ssoln.txt';
             assignfile(Debugfile,sOutFile);
             rewrite(DebugFile);
             for iCount := 1 to SSOLN.lMaxSize do
             begin
                  SSOLN.rtnValue(iCount,@iValue);
                  writeln(DebugFile,IntToStr(iValue));
             end;
             closefile(DebugFile);

             // dump best solution arrays to file
             sOutFile := ExtractFilePath(sDatabasePath) + sOutputDirName + '\' + sOutputFileName + '_best_check_puid.txt';
             assignfile(Debugfile,sOutFile);
             rewrite(DebugFile);
             for iCount := 1 to PUIDBEST.lMaxSize do
             begin
                  PUIDBEST.rtnValue(iCount,@iValue);
                  writeln(DebugFile,IntToStr(iValue));
             end;
             closefile(DebugFile);
             sOutFile := ExtractFilePath(sDatabasePath) + sOutputDirName + '\' + sOutputFileName + '_best_check_soln.txt';
             assignfile(Debugfile,sOutFile);
             rewrite(DebugFile);
             for iCount := 1 to BESTSOLN.lMaxSize do
             begin
                  BESTSOLN.rtnValue(iCount,@iValue);
                  writeln(DebugFile,IntToStr(iValue));
             end;
             closefile(DebugFile);

             // dump all solution arrays to file
             sOutFile := ExtractFilePath(sDatabasePath) + sOutputDirName + '\' + sOutputFileName + '_solutions_check_pucount.txt';
             assignfile(Debugfile,sOutFile);
             rewrite(DebugFile);
             writeln(DebugFile,'solution,pucount');
             for iCount := 1 to SOLUTIONPUCOUNT.lMaxSize do
             begin
                  SOLUTIONPUCOUNT.rtnValue(iCount,@iValue);
                  writeln(DebugFile,IntToStr(iCount) + ',' + IntToStr(iValue));
             end;
             closefile(DebugFile);
             sOutFile := ExtractFilePath(sDatabasePath) + sOutputDirName + '\' + sOutputFileName + '_solutions_check_puid.txt';
             assignfile(Debugfile,sOutFile);
             rewrite(DebugFile);
             for iCount := 1 to PUIDSOLUTIONS.lMaxSize do
             begin
                  PUIDSOLUTIONS.rtnValue(iCount,@iValue);
                  writeln(DebugFile,IntToStr(iValue));
             end;
             closefile(DebugFile);
             sOutFile := ExtractFilePath(sDatabasePath) + sOutputDirName + '\' + sOutputFileName + '_solutions_check_soln.txt';
             assignfile(Debugfile,sOutFile);
             rewrite(DebugFile);
             for iCount := 1 to SOLUTIONS.lMaxSize do
             begin
                  SOLUTIONS.rtnValue(iCount,@iValue);
                  writeln(DebugFile,IntToStr(iValue));
             end;
             closefile(DebugFile);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DebugReadMarxanResult',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure ReadMarxanResult(const sDatabasePath, sOutputDirName, sOutputFileName : string;
                           var iSSOLNPUCount,iSSOLNZoneCount,iNumberOfSolutions : integer);
var
   iCount, iCount2, iValue, iSumCount : integer;
   Infile,Debugfile : TextFile;
   sLine, sInFile, sOutFile : string;
begin
     try
        // iSSOLNPUCount is the number of rows - 1 in Selection Frequency file
        // iSSOLNZoneCount is the number of columns - 2 in the Selection Frequency file

        // traverse Selection Frequency file to find counts
        sInFile := ExtractFilePath(sDatabasePath) + sOutputDirName + '\' + sOutputFileName + '_ssoln.txt';
        if not fileexists(sInFile) then
           sInFile := ExtractFilePath(sDatabasePath) + sOutputDirName + '\' + sOutputFileName + '_ssoln.csv';
        if fileexists(sInFile) then
        begin
             assignfile(InFile,sInFile);
             reset(InFile);
             readln(InFile,sLine);
             iSSOLNZoneCount := CountDelimitersInRow(sLine,',') - 1;
             iSSOLNPUCount := 0;
             repeat
                   readln(InFile);
                   Inc(iSSOLNPUCount)

             until Eof(InFile);
             closefile(InFile);

             // create SSOLN arrays
             SSOLN := Array_t.Create;
             if (iSSOLNZoneCount = 1) then
                SSOLN.init(SizeOf(integer),iSSOLNPUCount)
             else
                 SSOLN.init(SizeOf(integer),iSSOLNPUCount * (iSSOLNZoneCount+1));
             PUIDSSOLN := Array_t.Create;
             PUIDSSOLN.init(SizeOf(integer),iSSOLNPUCount);
             fCreatedSSOLN := True;
             fCreatedPUIDSSOLN := True;

             // traverse Selection Frequency file to populate arrays
             assignfile(InFile,sInFile);
             reset(InFile);
             readln(InFile,sLine);
             iCount := 0;
             repeat
                   readln(InFile,sLine);
                   Inc(iCount);

                   iValue := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
                   PUIDSSOLN.setValue(iCount,@iValue);

                   iValue := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
                   SSOLN.setValue(iCount,@iValue);

                   if (iSSOLNZoneCount > 1) then
                      for iCount2 := 1 to iSSOLNZoneCount do
                      begin
                           iValue := StrToInt(GetDelimitedAsciiElement(sLine,',',2 + iCount2));
                           SSOLN.setValue(iCount + (iCount2 * iSSOLNPUCount),@iValue);
                      end;

             until Eof(InFile);
             closefile(InFile);
        end
        else
            fUseDefaultMarxanResult := True;
            //MessageDlg('ReadMarxanResult, file ' + sInFile + ' does not exist.',mtError,[mbOk],0);;

        // traverse best solution file to find pu count
        sInFile := ExtractFilePath(sDatabasePath) + sOutputDirName + '\' + sOutputFileName + '_best.txt';
        if not fileexists(sInFile) then
           sInFile := ExtractFilePath(sDatabasePath) + sOutputDirName + '\' + sOutputFileName + '_best.csv';
        if fileexists(sInFile) then
        begin
             assignfile(InFile,sInFile);
             reset(InFile);
             readln(InFile,sLine);
             iCount := 0;
             repeat
                   readln(InFile);
                   Inc(iCount)

             until Eof(InFile);
             closefile(InFile);

             // create best arrays
             BESTSOLN := Array_t.Create;
             BESTSOLN.init(SizeOf(integer),iCount);
             PUIDBEST := Array_t.Create;
             PUIDBEST.init(SizeOf(integer),iCount);
             fCreatedBESTSOLN := True;
             fCreatedPUIDBEST := True;

             // traverse best solution file to populate arrays
             assignfile(InFile,sInFile);
             reset(InFile);
             readln(InFile,sLine);
             iCount := 0;
             repeat
                   readln(InFile,sLine);
                   Inc(iCount);

                   iValue := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
                   PUIDBEST.setValue(iCount,@iValue);

                   iValue := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
                   if not fMarZone then
                      iValue := iValue + 1;
                   BESTSOLN.setValue(iCount,@iValue);

             until Eof(InFile);
             closefile(InFile);
        end
        else
            fUseDefaultMarxanResult := True;
            //MessageDlg('ReadMarxanResult, file ' + sInFile + ' does not exist.',mtError,[mbOk],0);

        // create solution pu count array
        iNumberOfSolutions := ReturnSolutionCount(sDatabasePath);
        if (iNumberOfSolutions > 100) then
           iNumberOfSolutions := 100;
        SOLUTIONPUCOUNT := Array_t.create;
        SOLUTIONPUCOUNT.init(SizeOf(integer),iNumberOfSolutions);
        fCreatedSOLUTIONPUCOUNT := True;

        // traverse solution files to find pu counts
        iSumCount := 0;
        for iCount := 1 to iNumberOfSolutions do
        begin
             // output_r00001.txt
             sInFile := ExtractFilePath(sDatabasePath) + sOutputDirName + '\' + sOutputFileName + '_r' + PadInt(iCount,5) + '.txt';
             if not fileexists(sInFile) then
                sInFile := ExtractFilePath(sDatabasePath) + sOutputDirName + '\' + sOutputFileName + '_r' + PadInt(iCount,5) + '.csv';
             if fileexists(sInFile) then
             begin
                  assignfile(InFile,sInFile);
                  reset(InFile);
                  readln(InFile,sLine);
                  iCount2 := 0;
                  repeat
                        readln(InFile);
                        Inc(iCount2)

                  until Eof(InFile);
                  closefile(InFile);

                  SOLUTIONPUCOUNT.setValue(iCount,@iCount2);
                  iSumCount := iSumCount + iCount2;
             end
             else
                 fUseDefaultMarxanResult := True;
                 //MessageDlg('ReadMarxanResult, file ' + sInFile + ' does not exist.',mtError,[mbOk],0);
        end;
        // create solution arrays
        SOLUTIONS := Array_t.Create;
        SOLUTIONS.init(SizeOf(integer),iSumCount);
        PUIDSOLUTIONS := Array_t.Create;
        PUIDSOLUTIONS.init(SizeOf(integer),iSumCount);
        fCreatedSOLUTIONS := True;
        fCreatedPUIDSOLUTIONS := True;

        // traverse solution files to populate arrays
        iCount2 := 0;
        for iCount := 1 to iNumberOfSolutions do
        begin
             sInFile := ExtractFilePath(sDatabasePath) + sOutputDirName + '\' + sOutputFileName + '_r' + PadInt(iCount,5) + '.txt';
             if not fileexists(sInFile) then
                sInFile := ExtractFilePath(sDatabasePath) + sOutputDirName + '\' + sOutputFileName + '_r' + PadInt(iCount,5) + '.csv';
             if fileexists(sInFile) then
             begin
                  assignfile(InFile,sInFile);
                  reset(InFile);
                  readln(InFile,sLine);
                  repeat
                        readln(InFile,sLine);
                        Inc(iCount2);

                        iValue := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
                        PUIDSOLUTIONS.setValue(iCount2,@iValue);

                        iValue := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
                        if not fMarZone then
                           iValue := iValue + 1;
                        SOLUTIONS.setValue(iCount2,@iValue);

                  until Eof(InFile);
                  closefile(InFile);
             end
             else
                 fUseDefaultMarxanResult := True;
                 //MessageDlg('ReadMarxanResult, file ' + sInFile + ' does not exist.',mtError,[mbOk],0);
        end;

        if not fUseDefaultMarxanResult then
           DebugReadMarxanResult(sDatabasePath, sOutputDirName, sOutputFileName);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReadMarxanResult',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure ReturnRangeForSolution(iSolution : integer; var iStart,iEnd : integer);
var
   iCount, iSumCount, iTmp : integer;
begin
     if (iSolution > 1) then
     begin
          iSumCount := 0;
          for iCount := 1 to (iSolution - 1) do
          begin
               SOLUTIONPUCOUNT.rtnValue(iCount,@iTmp);
               iSumCount := iSumCount + iTmp;
          end;
          iStart := iSumCount + 1;
          SOLUTIONPUCOUNT.rtnValue(iSolution,@iTmp);
          iEnd := iSumCount + iTmp;
     end
     else
     begin
          iStart := 1;
          SOLUTIONPUCOUNT.rtnValue(1,@iEnd);
     end;
end;

procedure TMarxanInterfaceForm.ForceFields;
var
   iFieldsToAdd, iCount : integer;
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
        ThemeTable.DatabaseName := ExtractFilePath(ComboPUShapefile.Text);
        sTableName := ExtractFileName(ComboPUShapefile.Text);
        sTableName := Copy(sTableName,1,Length(sTableName) - Length(ExtractFileExt(sTableName))) + '.dbf';
        ThemeTable.TableName := sTableName;

        ThemeQuery.SQL.Clear;
        ThemeQuery.SQL.Add('ALTER TABLE "' + ThemeTable.DatabaseName + '\' + sTableName + '"');

        ThemeTable.Open;

        iFieldsToAdd := 0;
        AddAField('SSOLN');
        AddAField('BESTSOLN');
        for iCount := 1 to iNumberOfZones do
            AddAField('SSOLN' + IntToStr(iCount));
        for iCount := 1 to iNumberOfRuns do
            AddAField('SOLN' + IntToStr(iCount));

        ThemeTable.Close;

        if (iFieldsToAdd > 0) then
        begin
             ThemeQuery.Prepare;
             ThemeQuery.ExecSQL;
             ThemeQuery.Close;
        end;

     except
           ThemeQuery.SQL.SaveToFile(ThemeTable.DatabaseName + '\error.sql');
           MessageDlg('Exception in ForceFields theme ' + ComboPUShapefile.Text + '.',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMarxanInterfaceForm.DropFields;
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
        ThemeTable.DatabaseName := ExtractFilePath(ComboPUShapefile.Text);
        sTableName := ExtractFileName(ComboPUShapefile.Text);
        sTableName := Copy(sTableName,1,Length(sTableName) - Length(ExtractFileExt(sTableName))) + '.dbf';
        ThemeTable.TableName := sTableName;

        ThemeQuery.SQL.Clear;
        ThemeQuery.SQL.Add('ALTER TABLE "' + ThemeTable.DatabaseName + '\' + sTableName + '"');

        ThemeTable.Open;

        iFieldsToAdd := 0;
        AddAField('SSOLN');
        AddAField('BESTSOLN');
        for i := 1 to 20 do
            AddAField('SSOLN' + IntToStr(i));
        for i := 1 to 100 do
            AddAField('SOLN' + IntToStr(i));

        ThemeTable.Close;

        if (iFieldsToAdd > 0) then
        begin
             ThemeQuery.Prepare;
             ThemeQuery.ExecSQL;
             ThemeQuery.Close;
        end;

     except
           ThemeQuery.SQL.SaveToFile(ThemeTable.DatabaseName + '\error.sql');
           MessageDlg('Exception in DropFields theme ' + ComboPUShapefile.Text + '.',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMarxanInterfaceForm.ForceAField(const sFieldName : string);
var
   iFieldsToAdd, iCount : integer;
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
        ThemeTable.DatabaseName := ExtractFilePath(ComboPUShapefile.Text);
        sTableName := ExtractFileName(ComboPUShapefile.Text);
        sTableName := Copy(sTableName,1,Length(sTableName) - Length(ExtractFileExt(sTableName))) + '.dbf';
        ThemeTable.TableName := sTableName;

        ThemeQuery.SQL.Clear;
        ThemeQuery.SQL.Add('ALTER TABLE "' + ThemeTable.DatabaseName + '\' + sTableName + '"');

        ThemeTable.Open;

        iFieldsToAdd := 0;
        AddAField(sFieldName);

        ThemeTable.Close;

        if (iFieldsToAdd > 0) then
        begin
             ThemeQuery.Prepare;
             ThemeQuery.ExecSQL;
             ThemeQuery.Close;
        end;

     except
           ThemeQuery.SQL.SaveToFile(ThemeTable.DatabaseName + '\error.sql');
           MessageDlg('Exception in ForceAField theme ' + ComboPUShapefile.Text + '.',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMarxanInterfaceForm.WriteDefaultMarxanResult(iSSOLNPUCount,iSSOLNZoneCount, iNumberOfSolutions : integer);
var
   iCount, iCount3, iPUID, iValue, iStart, iEnd, iPUIndex :  integer;
   sTableName : string;
   myExtents: MapWinGIS_TLB.Extents;
begin
     try
        // remove the theme from GIS display
        myExtents := IExtents(GIS_Child.Map1.Extents);
        GIS_Child.RemoveAllShapes;

        DropFields;
        ForceFields;

        ThemeTable.DatabaseName := ExtractFilePath(ComboPUShapefile.Text);
        sTableName := ExtractFileName(ComboPUShapefile.Text);
        sTableName := Copy(sTableName,1,Length(sTableName) - Length(ExtractFileExt(sTableName))) + '.dbf';
        ThemeTable.TableName := sTableName;

        ThemeTable.Open;

        for iCount := 1 to ThemeTable.RecordCount do
        begin
             iPUID := ThemeTable.FieldByName(ComboKeyField.Text).AsInteger;

             ThemeTable.Edit;
             ThemeTable.FieldByName('SSOLN').AsInteger := 0;
             ThemeTable.FieldByName('BESTSOLN').AsInteger := 0;
             for iCount3 := 1 to iNumberOfSolutions do
                 ThemeTable.FieldByName('SOLN' + IntToStr(iCount3)).AsInteger := 0;
             if (iSSOLNZoneCount < 2) then
             begin
                  ThemeTable.FieldByName('SSOLN2').AsInteger := 0;
                  ThemeTable.FieldByName('SSOLN1').AsInteger := 0;
             end
             else
                 for iCount3 := 1 to iSSOLNZoneCount do
                     ThemeTable.FieldByName('SSOLN' + IntToStr(iCount3)).AsInteger := 0;

             ThemeTable.Next;
        end;

        ThemeTable.Close;

        // add theme back to the GIS display
        //GIS_Child.AddShape(ComboPUShapefile.Text);
        GIS_Child.RestoreAllShapes;
        GIS_Child.Map1.Extents := myExtents;

     except
           MessageDlg('Exception in WriteDefaultMarxanResult theme ' + ComboPUShapefile.Text + '.',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMarxanInterfaceForm.WriteMarxanResult(iSSOLNPUCount,iSSOLNZoneCount, iNumberOfSolutions : integer);
var
   iCount, iCount3, iPUID, iValue, iStart, iEnd, iPUIndex :  integer;
   sTableName : string;
   myExtents: MapWinGIS_TLB.Extents;
begin
     try
        // remove the theme from GIS display
        myExtents := IExtents(GIS_Child.Map1.Extents);
        GIS_Child.RemoveAllShapes;

        DropFields;
        ForceFields;

        ThemeTable.DatabaseName := ExtractFilePath(ComboPUShapefile.Text);
        sTableName := ExtractFileName(ComboPUShapefile.Text);
        sTableName := Copy(sTableName,1,Length(sTableName) - Length(ExtractFileExt(sTableName))) + '.dbf';
        ThemeTable.TableName := sTableName;

        ThemeTable.Open;

        for iCount := 1 to ThemeTable.RecordCount do
        begin
             iPUID := ThemeTable.FieldByName(ComboKeyField.Text).AsInteger;

             ThemeTable.Edit;
             ThemeTable.FieldByName('SSOLN').AsInteger := 0;
             ThemeTable.FieldByName('BESTSOLN').AsInteger := 0;
             for iCount3 := 1 to iNumberOfSolutions do
                 ThemeTable.FieldByName('SOLN' + IntToStr(iCount3)).AsInteger := 0;

             // find this puid in PUIDSSOLN
             iPUIndex := ReserveOrder_BinaryLookup_Integer(PUIDSSOLN,iPUID,1,PUIDSSOLN.lMaxSize);
             if (iPUIndex <> -1) then
             begin
                  PUIDSSOLN.rtnValue(iPUIndex,@iValue);
                  if (iPUID = iValue) then
                  begin
                       // update Selection Frequency fields
                       SSOLN.rtnValue(iPUIndex,@iValue);
                       ThemeTable.FieldByName('SSOLN').AsInteger := iValue;

                       if (iSSOLNZoneCount < 2) then
                       begin
                            ThemeTable.FieldByName('SSOLN2').AsInteger := iValue;
                            ThemeTable.FieldByName('SSOLN1').AsInteger := iSolutionCount - iValue;
                       end
                       else
                       begin
                            for iCount3 := 1 to iSSOLNZoneCount do
                            begin
                                 SSOLN.rtnValue(iPUIndex + (iCount3 * iSSOLNPUCount),@iValue);
                                 ThemeTable.FieldByName('SSOLN' + IntToStr(iCount3)).AsInteger := iValue;
                            end;
                       end;
                  end;
             end;

             // find this puid in PUIDBEST
             iPUIndex := BinaryLookup_Integer(PUIDBEST,iPUID,1,PUIDBEST.lMaxSize);
             if (iPUIndex <> -1) then
             begin
                  PUIDBEST.rtnValue(iPUIndex,@iValue);
                  if (iPUID = iValue) then
                  begin
                       // update best field
                       BESTSOLN.rtnValue(iPUIndex,@iValue);
                       ThemeTable.FieldByName('BESTSOLN').AsInteger := iValue;
                  end;
             end;

             for iCount3 := 1 to iNumberOfSolutions do
             begin
                  // find this puid in PUIDSOLUTIONS
                  ReturnRangeForSolution(iCount3,iStart,iEnd);
                  iPUIndex := BinaryLookup_Integer(PUIDSOLUTIONS,iPUID,iStart,iEnd);
                  if (iPUIndex <> -1) then
                  begin
                       PUIDSOLUTIONS.rtnValue(iPUIndex,@iValue);
                       if (iPUID = iValue) then
                       begin
                            // update best field
                            SOLUTIONS.rtnValue(iPUIndex,@iValue);
                            ThemeTable.FieldByName('SOLN' + IntToStr(iCount3)).AsInteger := iValue;
                       end;
                  end;
             end;

             ThemeTable.Next;
        end;

        ThemeTable.Close;

        // add theme back to the GIS display
        //GIS_Child.AddShape(ComboPUShapefile.Text);
        GIS_Child.RestoreAllShapes;
        GIS_Child.Map1.Extents := myExtents;

     except
           MessageDlg('Exception in WriteMarxanResult theme ' + ComboPUShapefile.Text + '.',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMarxanInterfaceForm.RefreshGISDisplay;
var
   sFieldToMap : string;
   iZoneToMap, iMinValue, iMaxValue, iGISChildIndex : integer;
   GISChild : TGIS_Child;
   fSummedSolution, fEditConfigurationsFormHasFocus : boolean;
begin
     try
        ButtonUpdate.Enabled := True;
        fSummedSolution := True;

        if (Pos('Zone',ComboOutputToMap.Text)>0) then
        begin
             iZoneToMap := ComboOutputToMap.Items.IndexOf(ComboOutputToMap.Text) + 1;
             //iZoneToMap := StrToInt(Copy(ComboOutputToMap.Text,22,Length(ComboOutputToMap.Text)-21));
             //if (iZoneToMap = 2) and (iNumberOfZones < 3) then
             //   sFieldToMap := 'SSOLN'
             //else
                 sFieldToMap := 'SSOLN' + IntToStr(iZoneToMap);

             iMinValue := 0;
             iMaxValue := iSolutionCount;
        end
        else
        begin
             if (ComboOutputToMap.Text = 'Best Solution') then
                sFieldToMap := 'BESTSOLN'
             else
                 sFieldToMap := 'SOLN' + Copy(ComboOutputToMap.Text,10,Length(ComboOutputToMap.Text)-9);

             iMinValue := 0;
             iMaxValue := iNumberOfZones-1;

             fSummedSolution :=  False;
        end;

        iGISChildIndex := SCPForm.ReturnGISChildIndex;
        if (iGISChildIndex > -1) then
        begin
             GISChild := TGIS_Child(SCPForm.MDIChildren[iGISChildIndex]);

             fEditConfigurationsFormHasFocus := False;
             if SCPForm.fEditConfigurationsForm then
                //if (SCPForm.MDIChildren[0].Caption = EditConfigurationsForm.Caption) then
                   fEditConfigurationsFormHasFocus := True;

             if fEditConfigurationsFormHasFocus then
                GIS_Child.UpdateMap(0, iNumberOfZones-1, EditConfigurationsForm.sConfigField, False, True, Self)
             else
                 GISChild.UpdateMap(iMinValue, iMaxValue, sFieldToMap, fSummedSolution, False, Self);
        end;

     except
           MessageDlg('Exception in RefreshGISDisplay',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMarxanInterfaceForm.SendResultsToGIS;
var
   iSSOLNPUCount,iSSOLNZoneCount,iNumberOfSolutions : integer;
begin
     try
        Screen.Cursor := crHourglass;
        // read the Marxan results to some arrays
        fUseDefaultMarxanResult := False;
        fCreatedSSOLN := False;
        fCreatedPUIDSSOLN := False;
        fCreatedBESTSOLN := False;
        fCreatedPUIDBEST := False;
        fCreatedSOLUTIONPUCOUNT := False;
        fCreatedSOLUTIONS := False;
        fCreatedPUIDSOLUTIONS := False;

        ReadMarxanResult(EditMarxanDatabasePath.Text,
                         ReturnMarxanParameter('OUTPUTDIR'),
                         ReturnMarxanParameter('SCENNAME'),
                         iSSOLNPUCount,iSSOLNZoneCount,iNumberOfSolutions);

        // write the result to the dbf table
        if fUseDefaultMarxanResult then
           WriteDefaultMarxanResult(iSSOLNPUCount,iSSOLNZoneCount,iNumberOfSolutions)
        else
        begin
             WriteMarxanResult(iSSOLNPUCount,iSSOLNZoneCount,iNumberOfSolutions);
        end;

        if fCreatedSSOLN then
           SSOLN.Destroy;

        if fCreatedPUIDSSOLN then
           PUIDSSOLN.Destroy;

        if fCreatedBESTSOLN then
           BESTSOLN.Destroy;

        if fCreatedPUIDBEST then
           PUIDBEST.Destroy;

        if fCreatedSOLUTIONPUCOUNT then
           SOLUTIONPUCOUNT.Destroy;

        if fCreatedSOLUTIONS then
           SOLUTIONS.Destroy;

        if fCreatedPUIDSOLUTIONS then
           PUIDSOLUTIONS.Destroy;

        RefreshGISDisplay;

        Screen.Cursor := crDefault;

     except
           MessageDlg('Exception in SendResultsToGIS',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMarxanInterfaceForm.ComputeValidation;
var
   sSyncFile, sValidationFileName : string;
   iCount : integer;
begin
     MarxanSystemTestForm := TMarxanSystemTestForm.Create(Application);
     
     MarxanSystemTestForm.Visible := False;
     MarxanSystemTestForm.EditInputDat.Text := EditMarxanDatabasePath.Text;

     if fValidateAnnealing then
     begin
          with MarxanSystemTestForm do
          begin
               // detect marxan type (MarZone, Marxan, MarProbSpec, MarProbThreat
               RadioSoftwareTestType.ItemIndex := 0;

               for iCount := 1 to iSolutionCount do
               begin
                    // load validation table
                    // test if file is comma delimited
                    sValidationFileName := ExtractFilePath(EditMarxanDatabasePath.Text) +
                                           ReturnMarxanParameter('OUTPUTDIR') +
                                           '\' +
                                           ReturnMarxanParameter('SCENNAME') +
                                           '_anneal_zones' +
                                           PadInt(iCount,5) +
                                           '.csv';
                                           // MarZone and MarOpt files
                                           // "%s_anneal_objective%05i.csv"
                                           // "%s_anneal_zones%05i.txt"

                    SCPForm.CreateCSVChild(sValidationFileName,0);

                    ComboTestConfigurations.Text := sValidationFileName;
                    CheckTranspose.Checked := True;

                    ExecuteValidation;

                    SCPForm.ReturnNamedChild(sValidationFileName).Free;

                    // display validation comparison
               end;
          end;

          fValidateAnnealing := False;
     end;

     if fValidateIterativeImprovement then
     begin
          with MarxanSystemTestForm do
          begin
               // detect marxan type (MarZone, Marxan, MarProbSpec, MarProbThreat
               RadioSoftwareTestType.ItemIndex := 0;

               for iCount := 1 to iSolutionCount do
               begin
                    // load validation table
                    // test if file is comma delimited
                    sValidationFileName := ExtractFilePath(EditMarxanDatabasePath.Text) +
                                           ReturnMarxanParameter('OUTPUTDIR') +
                                           '\' +
                                           ReturnMarxanParameter('SCENNAME') +
                                           '_itimp_zones' +
                                           PadInt(iCount,5) +
                                           '.csv';
                    SCPForm.CreateCSVChild(sValidationFileName,0);

                    // load validation table

                    // MarOpt files
                    // "%s_itimp_objective%05i.csv"
                    // "%s_itimp_zones%05i.csv"

                    ComboTestConfigurations.Text := '';

                    CheckTranspose.Checked := True;

                    ExecuteValidation;

                    SCPForm.ReturnNamedChild(sValidationFileName).Free;

                    // display validation comparison
               end;
          end;

          fValidateIterativeImprovement := False;
     end;

     MarxanSystemTestForm.Free;

     // remove the marxan validation parameters from the input.dat file
     DeleteInputParameter('SAVEANNEALINGTRACE');
     DeleteInputParameter('ANNEALINGTRACEROWS');
     DeleteInputParameter('SAVEITIMPTRACE');
     DeleteInputParameter('ITIMPTRACEROWS');
end;

function R_safe_pathnames(const sInputLine : string) : string;
var
   sOutLine : string;
   i, iLineLength : integer;
begin
     iLineLength := Length(sInputLine);
     sOutLine := '';

     if (sInputLine <> '') then
     begin
          for i := 1 to iLineLength do
	  begin
               // 47 /
               // 92 \
	       if (Ord(sInputLine[i]) = 92) then
		  sOutLine := sOutLine + Chr(47)
               else
                   sOutLine := sOutLine + sInputLine[i];
	  end;
     end;

     Result := sOutLine;
end;

procedure TMarxanInterfaceForm.Create_R_Script(sOutput_R_script, sSolutionsFileName, sSaveName : string;
                                               iClusterCount : integer);
var
   OutputFile : TextFile;
   iCount : integer;
   sZoneSolutionsFileName, sR_safe_SaveName : string;
begin
     try  
        assignfile(OutputFile,sOutput_R_script);
        rewrite(OutputFile);

        sR_safe_SaveName := R_safe_pathnames(sSaveName);

        writeln(OutputFile,'sWorkingName <- "' + sR_safe_SaveName + '"');
        writeln(OutputFile,'');
        writeln(OutputFile,'');
        writeln(OutputFile,'library(rgl)');
        writeln(OutputFile,'library(vegan)');
        writeln(OutputFile,'library(labdsv)');
        writeln(OutputFile,'');
        writeln(OutputFile,'solutions_raw<-read.table(paste(sWorkingName,"' + sSolutionsFileName + '",sep=""),header=TRUE, row.name=1, sep=",")');
        writeln(OutputFile,'solutions <- unique(solutions_raw)');

        writeln(OutputFile,'iUniqueSolutions <- dim(solutions)[1]');
        writeln(OutputFile,'if (iUniqueSolutions < dim(solutions_raw)[1])');
        writeln(OutputFile,'{');
        writeln(OutputFile,'    duplicates <- duplicated(solutions_raw)');
        writeln(OutputFile,'    write("solution,duplicated",file=paste(sWorkingName,"_duplicates.csv",sep=""))');
        writeln(OutputFile,'    for (i in 1:' + IntToStr(iSolutionCount) + ')');
        writeln(OutputFile,'    {');
        writeln(OutputFile,'        cat(row.names(solutions_raw)[i],file=paste(sWorkingName,"_duplicates.csv",sep=""),append=TRUE)');
        writeln(OutputFile,'        cat(",",file=paste(sWorkingName,"_duplicates.csv",sep=""),append=TRUE)');
        writeln(OutputFile,'        write(duplicates[i],file=paste(sWorkingName,"_duplicates.csv",sep=""),append=TRUE)');
        writeln(OutputFile,'    }');
        writeln(OutputFile,'}');

        writeln(OutputFile,'soldist<-vegdist(solutions,distance="bray")');
        writeln(OutputFile,'sol.mds<-nmds(soldist,2)');
        writeln(OutputFile,'');
        writeln(OutputFile,'bmp(file=paste(sWorkingName,"_2d_plot.bmp",sep="")' +
                           ',width=' + IntToStr(Screen.Width-20) + ',height=' + IntToStr(Screen.Height-20) + ',pointsize=10)');
        writeln(OutputFile,'');
        if (iNumberOfZones > 2) then
           writeln(OutputFile,'plot(sol.mds$points, type="n", xlab="", ylab="", main="NMDS of zones and solutions")')
        else
            writeln(OutputFile,'plot(sol.mds$points, type=''n'', xlab='''', ylab='''', main=''NMDS of solutions'')');
        writeln(OutputFile,'text(sol.mds$points, labels=row.names(solutions))');
        writeln(OutputFile,'');
        writeln(OutputFile,'dev.off()');
        writeln(OutputFile,'');
        writeln(OutputFile,'h<-hclust(soldist, method="complete")');
        writeln(OutputFile,'');
        writeln(OutputFile,'bmp(file=paste(sWorkingName,"_dendogram.bmp",sep="")' +
                           ',width=' + IntToStr(Screen.Width-20) + ',height=' + IntToStr(Screen.Height-20) + ',pointsize=10)');
        writeln(OutputFile,'');
        if (iNumberOfZones > 2) then
           writeln(OutputFile,'plot(h, xlab="Solutions", ylab="Disimilarity", main="Bray-Curtis dissimilarity of zones and solutions")')
        else
            writeln(OutputFile,'plot(h, xlab="Solutions", ylab="Disimilarity", main="Bray-Curtis dissimilarity of solutions")');
        writeln(OutputFile,'');
        writeln(OutputFile,'dev.off()');
        writeln(OutputFile,'');
        writeln(OutputFile,'usercut<-cutree(h,k=' +
                           IntToStr(iClusterCount) +
                           ')');
        writeln(OutputFile,'');
        writeln(OutputFile,'write("solution,cluster",file=paste(sWorkingName,"_cluster.csv",sep=""))');
        writeln(OutputFile,'');
        writeln(OutputFile,'for (i in 1:iUniqueSolutions)');
        writeln(OutputFile,'{');
        writeln(OutputFile,'    cat(row.names(solutions)[i],file=paste(sWorkingName,"_cluster.csv",sep=""),append=TRUE)');
        writeln(OutputFile,'    cat(",",file=paste(sWorkingName,"_cluster.csv",sep=""),append=TRUE)');
        writeln(OutputFile,'    write(usercut[i],file=paste(sWorkingName,"_cluster.csv",sep=""),append=TRUE)');
        writeln(OutputFile,'}');
        writeln(OutputFile,'');

        if (iNumberOfZones > 2) then
           for iCount := 1 to iNumberOfZones do
           begin
                sZoneSolutionsFileName := Copy(sSolutionsFileName,1,Length(sSolutionsFileName) - 4) +
                                          '_zone' + IntToStr(iCount) +
                                          Copy(sSolutionsFileName,Length(sSolutionsFileName) - 3,4);

                writeln(OutputFile,'solutions' + IntToStr(iCount) + '<-read.table(paste(sWorkingName,"' + sZoneSolutionsFileName + '",sep="")' +
                                   ',header=TRUE, row.name=1, sep=",")');
                writeln(OutputFile,'soldist' + IntToStr(iCount) + '<-vegdist(solutions' + IntToStr(iCount) + ',distance=''bray'')');
                writeln(OutputFile,'sol.mds<-nmds(soldist' + IntToStr(iCount) + ',2)');
                writeln(OutputFile,'');
                writeln(OutputFile,'bmp(file=paste(sWorkingName,"_zone' + IntToStr(iCount) + '_2d_plot.bmp",sep="")' +
                                   ',width=' + IntToStr(Screen.Width-20) + ',height=' + IntToStr(Screen.Height-20) + ',pointsize=10)');
                writeln(OutputFile,'');
                writeln(OutputFile,'plot(sol.mds$points, type=''n'', xlab='''', ylab='''', main=''NMDS of zone ' + IntToStr(iCount) + ' across all solutions'')');
                writeln(OutputFile,'text(sol.mds$points, labels=row.names(solutions' + IntToStr(iCount) + '))');
                writeln(OutputFile,'');
                writeln(OutputFile,'dev.off()');
                writeln(OutputFile,'');
                writeln(OutputFile,'h' + IntToStr(iCount) + '<-hclust(soldist' + IntToStr(iCount) + ', method=''complete'')');
                writeln(OutputFile,'');
                writeln(OutputFile,'bmp(file=paste(sWorkingName,"_zone' + IntToStr(iCount) + '_dendogram.bmp",sep="")' +
                                   ',width=' + IntToStr(Screen.Width-20) + ',height=' + IntToStr(Screen.Height-20) + ',pointsize=10)');
                writeln(OutputFile,'');
                writeln(OutputFile,'plot(h' + IntToStr(iCount) + ', xlab=''Solutions'', ylab=''Disimilarity'', main=''Bray-Curtis dissimilarity of zone ' + IntToStr(iCount) + ' across all solutions'')');
                writeln(OutputFile,'');
                writeln(OutputFile,'dev.off()');
                writeln(OutputFile,'');
                writeln(OutputFile,'usercut' + IntToStr(iCount) + '<-cutree(h' + IntToStr(iCount) + ',k=' +
                                   IntToStr(iClusterCount) +
                                   ')');
                writeln(OutputFile,'');
                writeln(OutputFile,'write(''solution,cluster'',file=paste(sWorkingName,"_zone' + IntToStr(iCount) + '_cluster.csv",sep=""))');
                writeln(OutputFile,'');
                writeln(OutputFile,'for(i in 1:iUniqueSolutions)');
                writeln(OutputFile,'{');
                writeln(OutputFile,'   cat(row.names(solutions)[i],file=paste(sWorkingName,"_zone' + IntToStr(iCount) + '_cluster.csv",sep=""),append=TRUE)');
                writeln(OutputFile,'   cat('','',file=paste(sWorkingName,"_zone' + IntToStr(iCount) + '_cluster.csv",sep=""),append=TRUE)');
                writeln(OutputFile,'   write(usercut' + IntToStr(iCount) + '[i],file=paste(sWorkingName,"_zone' + IntToStr(iCount) + '_cluster.csv",sep=""),append=TRUE)');
                writeln(OutputFile,'}');
                writeln(OutputFile,'');
           end;

        writeln(OutputFile,'sol3d.mds<-nmds(soldist,3)');
        writeln(OutputFile,'');
        if (iNumberOfZones > 2) then
           writeln(OutputFile,'plot3d(sol3d.mds$points, xlab = "x", ylab = "y", zlab = "z", type="n", theta=40, phi=30, ticktype="detailed", main="NMDS of zones and solutions")')
        else
            writeln(OutputFile,'plot3d(sol3d.mds$points, xlab = "x", ylab = "y", zlab = "z", type="n", theta=40, phi=30, ticktype="detailed", main="NMDS of solutions")');
        writeln(OutputFile,'text3d(sol3d.mds$points,texts=row.names(solutions),pretty="TRUE")');
        writeln(OutputFile,'play3d(spin3d(axis=c(1,0,0), rpm=3), duration=10)');
        writeln(OutputFile,'play3d(spin3d(axis=c(0,1,0), rpm=3), duration=10)');
        writeln(OutputFile,'play3d(spin3d(axis=c(0,0,1), rpm=3), duration=10)');
        writeln(OutputFile,'');

        if (iNumberOfZones > 2) then
           for iCount := 1 to iNumberOfZones do
           begin
                writeln(OutputFile,'sol3d.mds<-nmds(soldist' + IntToStr(iCount) + ',3)');
                writeln(OutputFile,'');
                writeln(OutputFile,'plot3d(sol3d.mds$points, xlab = "x", ylab = "y", zlab = "z", type="n", theta=40, phi=30, ticktype="detailed", main="NMDS of zone ' + IntToStr(iCount) + ' across all solutions")');
                writeln(OutputFile,'text3d(sol3d.mds$points,texts=row.names(solutions' + IntToStr(iCount) + '),pretty="TRUE")');
                writeln(OutputFile,'play3d(spin3d(axis=c(1,0,0), rpm=3), duration=10)');
                writeln(OutputFile,'play3d(spin3d(axis=c(0,1,0), rpm=3), duration=10)');
                writeln(OutputFile,'play3d(spin3d(axis=c(0,0,1), rpm=3), duration=10)');
                writeln(OutputFile,'');
           end;

        Flush(OutputFile);
        closefile(OutputFile);

     except
           MessageDlg('Exception in Create_R_Script',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMarxanInterfaceForm.TimerMarxanTimer(Sender: TObject);
var
   sSyncFile, sValidationFileName, sExecuteString, sR_Install_Path,
   sOutput_R_script, sSolutionsFileName, sSaveName,
   sCommand, sCmdFileName : string;
   OutFile, CmdFile : TextFile;
   iCount : integer;
   fResult : boolean;
begin
     try
     // check to see if sync file exists
     if not ProgressForm.BitBtnCancel.Enabled then
        if fMarxanRunning then
        begin
             //TerminateProcess(hMarxanProcess,0);
             assignfile(OutFile,ExtractFilePath(EditMarxanDatabasePath.Text) + 'sync');
             rewrite(OutFile);
             writeln(OutFile,'sync');
             closefile(OutFile);
        end;

     sSyncFile := ExtractFilePath(EditMarxanDatabasePath.Text) + 'stop_error.txt';
     if fileexists(sSyncFile) then
     begin
          // Marxan has produced a stop error message
          TimerMarxan.Enabled := False;
          DeleteFile(sSyncFile);
          ProgressForm.Close;
          Screen.Cursor := crDefault;

          if fActiveCalibrationRunning then
             AdaptiveCalibrationForm.Close;
          fCalibrationRunning := False;

          MessageDlg('Marxan has encountered an error and stopped.',mtInformation,[mbOk],0);
     end;

     for iCount := 1 to iSolutionCount do
     begin
          sSyncFile := ExtractFilePath(EditMarxanDatabasePath.Text) + 'sync' + IntToStr(iCount);
          if fileexists(sSyncFile) then
          begin
               DeleteFile(sSyncFile);

               ProgressForm.UpdateMarxanRun(iCount);
          end;
     end;

     //sSyncFile := ExtractFilePath(EditMarxanDatabasePath.Text) + 'sync' + IntToStr(iCurrentRunExecute);
     //if fileexists(sSyncFile) then
     //begin
     //     DeleteFile(sSyncFile);
     //
     //     ProgressForm.UpdateMarxanRun(iCurrentRunExecute);
     //     ProgressForm.BringToFront;
     //     Inc(iCurrentRunExecute);
     //
     //     if fActiveCalibrationRunning then
     //        AdaptiveCalibrationForm.BringToFront;
     //end;

     sSyncFile := ExtractFilePath(EditMarxanDatabasePath.Text) + 'sync';

     if fileexists(sSyncFile) then
     begin
          TimerMarxan.Enabled := False;
          DeleteFile(sSyncFile);

          for iCount := 1 to iSolutionCount do
          begin
               sSyncFile := ExtractFilePath(EditMarxanDatabasePath.Text) + 'sync' + IntToStr(iCount);
               if fileexists(sSyncFile) then
                  DeleteFile(sSyncFile);
          end;

          SendResultsToGIS;

          if ProgressForm.BitBtnCancel.Enabled and fCalibrationRunning then
          begin
               SaveScenario('calibrate' + IntToStr(iCurrentCalibrationNumber),True);

               // we are running a calibration and need to fetch the result and possibly trigger the next run
               CollectNextCalibrationResult;

               if (iCurrentCalibrationNumber = iCalibrationNumber) then
               begin
                    fCalibrationRunning := False;
                    RetrieveInputDatFiles;
                    ProgressForm.Close;

                    DisplayAllCalibrationResults;
               end
               else
               begin
                    Inc(iCurrentCalibrationNumber);
                    iCurrentRunExecute := 1;
                    StartNextCalibrationJob;

                    ProgressForm.UpdateMarxanRun(0);
                    ProgressForm.ProgressBarCalibration.Position := Trunc((iCurrentCalibrationNumber - 1) / iCalibrationNumber * 100);
               end;
          end
          else
          begin
               if not ProgressForm.BitBtnCancel.Enabled then
                  if fMarxanRunning then
                     TerminateProcess(hMarxanProcess,0);

               fCalibrationRunning := False;
               ProgressForm.Close;
          end;

          // Run R interactive analysis
          if SCPForm.DoClusterAnalysis1.Checked then
          begin
               fResult := SCPForm.GenerateAndRunRScripts;

               if not fResult then
                  SCPForm.DoClusterAnalysis1.Checked := False;                         
          end;

           // perform validation on specified output table(s)
          if fValidateAnnealing or fValidateIterativeImprovement then
             ComputeValidation;

          Screen.Cursor := crDefault;

          if fActiveCalibrationOpen then
             if not fActiveCalibrationRunning then
             begin
                  AdaptiveCalibrationForm.Free;
                  fActiveCalibrationOpen := False;
             end;

          if fActiveCalibrationRunning then
          begin
               AdaptiveCalibrationForm.ExecuteNextStep;
               ButtonUpdateClick(Sender);
          end;
     end;
     except
           MessageDlg('Exception in TimerMarxanTimer',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMarxanInterfaceForm.SetEditElement;
var
   iValue : integer;
begin
     try
        fSettingParameter := True;

        EditValue.Text := ParameterGrid.Cells[ParameterGrid.Selection.Left,ParameterGrid.Selection.Top];
        if (EditValue.Enabled) and (EditValue.Visible) then
           EditValue.SetFocus;

        fSettingParameter := False;

     except
           MessageDlg('Exception in SetEditElement',mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMarxanInterfaceForm.ParameterGridMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     SetEditElement;
end;

procedure TMarxanInterfaceForm.ComboOutputToMapChange(Sender: TObject);
begin
     RefreshGISDisplay;
     GIS_Child.RedrawSelection;
end;

procedure TMarxanInterfaceForm.Update1Click(Sender: TObject);
begin
     ButtonUpdateClick(Sender);
end;

procedure TMarxanInterfaceForm.ExecuteCalibration;
begin
     CalibrationForm := TCalibrationForm.Create(Application);

     if (mrOk = CalibrationForm.ShowModal) then
     begin
          iCurrentRunExecute := 1;
          ProgressForm := TProgressForm.Create(Application);
          ProgressForm.Show;
          ProgressForm.LabelMarxan.Caption := 'Marxan';
          ProgressForm.ProgressBarMarxan.Max := iSolutionCount;
          ProgressForm.LabelCalibration.Caption := 'Calibration';
     end;

     CalibrationForm.Free;
end;

procedure TMarxanInterfaceForm.SaveScenario(sScenario : string;fForceOverWrite : boolean);
var
   ScenarioIni : TIniFile;
   fScenarioExists : boolean;
   sBaseDirectory, sInputDir, sOutputDir, sScenName : string;
   iCount : integer;
begin
     try
        sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);
        ScenarioIni := TIniFile.Create(sBaseDirectory + 'scenarios.ini');
        if (ScenarioIni.ReadString('Scenario',sScenario,'not present') = 'not present') or fForceOverWrite then
        begin
             fScenarioExists := False;
        end
        else
        begin
             fScenarioExists := True;
             if (MessageDlg('Scenario Exists.  Overwrite?',mtConfirmation,[mbOk,mbCancel],0) = mrOk) then
                fScenarioExists := False;
        end;
        if not fScenarioExists then
        begin
             sInputDir := ReturnMarxanParameter('INPUTDIR');
             sOutputDir := ReturnMarxanParameter('OUTPUTDIR');
             sScenName := ReturnMarxanParameter('SCENNAME');

             // save the current scenario
             ScenarioIni.WriteString('Scenario',sScenario,'present');
             ScenarioIni.Free;
             ForceDirectories(sBaseDirectory + 'scenarios\' + sScenario);
             ForceDirectories(sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             ForceDirectories(sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir);
             // copy base input files
             CopyIfExists('input.dat',sBaseDirectory, sBaseDirectory + 'scenarios\' + sScenario);
             CopyIfExists(ReturnMarxanParameter('PUNAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             CopyIfExists(ReturnMarxanParameter('SPECNAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             CopyIfExists(ReturnMarxanParameter('FEATNAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             CopyIfExists(ReturnMarxanParameter('PUVSPRNAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             CopyIfExists(ReturnMarxanParameter('PUVFEATNAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             // copy extra input files if they exist
             CopyIfExists(ReturnMarxanParameter('BOUNDNAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             CopyIfExists(ReturnMarxanParameter('ZONESNAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             CopyIfExists(ReturnMarxanParameter('COSTSNAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             CopyIfExists(ReturnMarxanParameter('ZONECOSTNAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             CopyIfExists(ReturnMarxanParameter('ZONEBOUNDCOSTNAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             CopyIfExists(ReturnMarxanParameter('ZONETARGETNAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             CopyIfExists(ReturnMarxanParameter('ZONETARGET2NAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             CopyIfExists(ReturnMarxanParameter('ZONECONTRIBNAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             CopyIfExists(ReturnMarxanParameter('ZONECONTRIB2NAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             CopyIfExists(ReturnMarxanParameter('PULOCKNAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             CopyIfExists(ReturnMarxanParameter('PUZONENAME'),
                          sBaseDirectory + sInputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir);
             // copy output files if they exist
             CopyIfExists(sScenName + '_sum' + ReturnMarxanOutputFileExt('SAVESUMMARY'),
                          sBaseDirectory + sOutputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir);
             CopyIfExists(sScenName + '_log' + ReturnMarxanOutputFileExt('SAVELOG'),
                          sBaseDirectory + sOutputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir);
             CopyIfExists(sScenName + '_sen' + ReturnMarxanOutputFileExt('SAVESCEN'),
                          sBaseDirectory + sOutputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir);
             CopyIfExists(sScenName + '_ssoln' + ReturnMarxanOutputFileExt('SAVESUMSOLN'),
                          sBaseDirectory + sOutputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir);
             CopyIfExists(sScenName + '_mvbest' + ReturnMarxanOutputFileExt('SAVETARGMET'),
                          sBaseDirectory + sOutputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir);
             CopyIfExists(sScenName + '_best' + ReturnMarxanOutputFileExt('SAVEBEST'),
                          sBaseDirectory + sOutputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir);
             CopyIfExists(sScenName + '_solutionsmatrix' + ReturnMarxanOutputFileExt('SAVESOLUTIONSMATRIX'),
                          sBaseDirectory + sOutputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir);
             CopyIfExists(sScenName + '_penalty' + ReturnMarxanOutputFileExt('SAVEPENALTY'),
                          sBaseDirectory + sOutputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir);
             CopyIfExists(sScenName + '_penalty_planning_units' + ReturnMarxanOutputFileExt('SAVEPENALTY'),
                          sBaseDirectory + sOutputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir);
             CopyIfExists('calibrate.csv',
                          sBaseDirectory + sOutputDir,
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir);
             // copy output files for each scenario if they exist
             for iCount := 1 to iSolutionCount do
             begin
                  CopyIfExists(sScenName + '_r' + PadInt(iCount,5) + ReturnMarxanOutputFileExt('SAVERUN'),
                               sBaseDirectory + sOutputDir,
                               sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir);
                  CopyIfExists(sScenName + '_mv' + PadInt(iCount,5) + ReturnMarxanOutputFileExt('SAVETARGMET'),
                               sBaseDirectory + sOutputDir,
                               sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir);
                  CopyIfExists('map' + IntToStr(iCount) + '.JPG',
                               sBaseDirectory + sOutputDir,
                               sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir);
             end;
        end;

     except
           MessageDlg('Exception in SaveScenario',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMarxanInterfaceForm.ButtonSaveClick(Sender: TObject);
var
   sScenario : string;
begin
     if fParameterChanged then
        if (mrYes = MessageDlg('Save parameter before saving run?',mtConfirmation,[mbYes,mbNo],0)) then
           SaveParameter;

     sScenario := '';
     if InputQuery('Save Scenario','Enter Scenario Name',sScenario) then
        if (sScenario <> '') then
           SaveScenario(sScenario,False);
end;

procedure TMarxanInterfaceForm.Load_Scenario(sScenario : string);
var
   sBaseDirectory, sInputDir, sOutputDir, sScenName : string;
   iCount : integer;
begin
     try
        sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);
        sInputDir := ReturnMarxanParameter('INPUTDIR');
        sOutputDir := ReturnMarxanParameter('OUTPUTDIR');
        sScenName := ReturnMarxanParameter('SCENNAME');
        // load the scenario
        // copy base input files
        CopyIfExists('input.dat',sBaseDirectory + 'scenarios\' + sScenario,sBaseDirectory);
        CopyIfExists(ReturnMarxanParameter('PUNAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        CopyIfExists(ReturnMarxanParameter('SPECNAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        CopyIfExists(ReturnMarxanParameter('FEATNAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        CopyIfExists(ReturnMarxanParameter('PUVSPRNAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        CopyIfExists(ReturnMarxanParameter('PUVFEATNAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        // copy extra input files if they exist
        CopyIfExists(ReturnMarxanParameter('BOUNDNAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        CopyIfExists(ReturnMarxanParameter('ZONESNAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        CopyIfExists(ReturnMarxanParameter('COSTSNAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        CopyIfExists(ReturnMarxanParameter('ZONECOSTNAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        CopyIfExists(ReturnMarxanParameter('ZONEBOUNDCOSTNAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        CopyIfExists(ReturnMarxanParameter('ZONETARGETNAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        CopyIfExists(ReturnMarxanParameter('ZONETARGET2NAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        CopyIfExists(ReturnMarxanParameter('ZONECONTRIBNAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        CopyIfExists(ReturnMarxanParameter('ZONECONTRIB2NAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        CopyIfExists(ReturnMarxanParameter('PULOCKNAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        CopyIfExists(ReturnMarxanParameter('PUZONENAME'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sInputDir,
                     sBaseDirectory + sInputDir);
        // copy output files if they exist
        CopyIfExists(sScenName + '_sum' + ReturnMarxanOutputFileExt('SAVESUMMARY'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir,
                     sBaseDirectory + sOutputDir);
        CopyIfExists(sScenName + '_log' + ReturnMarxanOutputFileExt('SAVELOG'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir,
                     sBaseDirectory + sOutputDir);
        CopyIfExists(sScenName + '_sen' + ReturnMarxanOutputFileExt('SAVESCEN'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir,
                     sBaseDirectory + sOutputDir);
        CopyIfExists(sScenName + '_ssoln' + ReturnMarxanOutputFileExt('SAVESUMSOLN'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir,
                     sBaseDirectory + sOutputDir);
        CopyIfExists(sScenName + '_mvbest' + ReturnMarxanOutputFileExt('SAVETARGMET'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir,
                     sBaseDirectory + sOutputDir);
        CopyIfExists(sScenName + '_best' + ReturnMarxanOutputFileExt('SAVEBEST'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir,
                     sBaseDirectory + sOutputDir);           
        CopyIfExists(sScenName + '_solutionsmatrix' + ReturnMarxanOutputFileExt('SAVESOLUTIONSMATRIX'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir,
                     sBaseDirectory + sOutputDir);
        CopyIfExists(sScenName + '_penalty' + ReturnMarxanOutputFileExt('SAVEPENALTY'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir,
                     sBaseDirectory + sOutputDir);
        CopyIfExists(sScenName + '_penalty_planning_units' + ReturnMarxanOutputFileExt('SAVEPENALTY'),
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir,
                     sBaseDirectory + sOutputDir);
        CopyIfExists('calibrate.csv',
                     sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir,
                     sBaseDirectory + sOutputDir);
        // copy output files for each run if they exist
        for iCount := 1 to iSolutionCount do
        begin
             CopyIfExists(sScenName + '_r' + PadInt(iCount,5) + ReturnMarxanOutputFileExt('SAVERUN'),
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir,
                          sBaseDirectory + sOutputDir);
             CopyIfExists(sScenName + '_mv' + PadInt(iCount,5) + ReturnMarxanOutputFileExt('SAVETARGMET'),
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir,
                          sBaseDirectory + sOutputDir);
             CopyIfExists('map' + IntToStr(iCount) + '.JPG',
                          sBaseDirectory + 'scenarios\' + sScenario + '\' + sOutputDir,
                          sBaseDirectory + sOutputDir);
        end;

     except
           MessageDlg('Exception in Load_Scenario',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMarxanInterfaceForm.ButtonLoadClick(Sender: TObject);
begin
     LoadScenarioForm := TLoadScenarioForm.Create(Application);
     if (LoadScenarioForm.ScenarioListBox.Items.Count > 0) then
     begin
          LoadScenarioForm.ShowModal;
          Load_Scenario(LoadScenarioForm.ScenarioListBox.Items.Strings[LoadScenarioForm.ScenarioListBox.ItemIndex]);

          // refresh interface for the new scenario
          LoadParameter;
          SetEditElement;
          fParameterChanged := False;

          iSolutionCount := ReturnSolutionCount(EditMarxanDatabasePath.Text);
          if (iSolutionCount > 100) then
             iNumberOfRuns := 100
          else
              iNumberOfRuns := iSolutionCount;

          iNumberOfZones := ReturnRecordCount(ExtractFilePath(EditMarxanDatabasePath.Text) + 'input\zones.dat');
          iNumberOfCosts := ReturnRecordCount(ExtractFilePath(EditMarxanDatabasePath.Text) + 'input\costs.dat');
          iNumberOfFeatures := ReturnRecordCount(ExtractFilePath(EditMarxanDatabasePath.Text) + 'input\spec.dat');
          //iNumberOfPlanningUnits := ReturnRecordCount(ExtractFilePath(EditMarxanDatabasePath.Text) + 'input\spec.dat');
          RefreshRunNumber;

          // refresh GIS results
          MarxanInterfaceForm.SendResultsToGIS;
          fUpdatedOnce := True;
     end
     else
         MessageDlg('There are no scenarios to save',mtInformation,[mbOk],0);

     LoadScenarioForm.Free;
end;

procedure TMarxanInterfaceForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
     if fSingleSolutionColours then
     begin
          SingleSolutionColours.Destroy;
          fSingleSolutionColours := False;
     end;

     Action := caFree;

     SCPForm.Marxan3.Enabled := False;
     SCPForm.Marxan3.Visible := False;

     SCPForm.fMarxanActivated := False;
end;

procedure TMarxanInterfaceForm.ReadShapeFields;
begin
     // fetch list of fields for this shape from the GIS
end;

procedure TMarxanInterfaceForm.FormActivate(Sender: TObject);
begin
     SCPForm.SwitchChildFocus;
end;

procedure TMarxanInterfaceForm.PopulateParameterList;
var
   sInputDir : string;

   procedure IfNameParameterExistsAdd(const sParam : string);
   var
      sFileName, sParamValue : string;
   begin
        sParamValue := ReturnMarxanParameter(sParam + 'NAME');

        if (sParamValue <> '') then
        begin
             ComboParameterToEdit.Items.Add(sParam);

             // test if file is comma delimited
             sFileName := ExtractFilePath(EditMarxanDatabasePath.Text) +
                          ReturnMarxanParameter('INPUTDIR') +
                          '\' +
                          sParamValue;

             if not FileContainsCommas(sFileName) then
                ConvertFileDelimiter_TabToComma(sFileName);
        end;
   end;

   procedure IfParameterExistsAdd(const sParam : string);
   begin
        if (ReturnMarxanParameter(sParam) <> '') then
           ComboParameterToEdit.Items.Add(sParam);
   end;

begin
     ComboParameterToEdit.Items.Clear;
     sInputDir := ReturnMarxanParameter('INPUTDIR');

     // add filename parameters
     IfNameParameterExistsAdd('PU');
     IfNameParameterExistsAdd('SPEC');
     IfNameParameterExistsAdd('FEAT');
     //IfNameParameterExistsAdd('PUVSPR');
     //IfNameParameterExistsAdd('PUVFEAT');
     //IfNameParameterExistsAdd('BOUND');
     IfNameParameterExistsAdd('ZONES');
     IfNameParameterExistsAdd('COSTS');
     IfNameParameterExistsAdd('ZONECOST');
     IfNameParameterExistsAdd('CONNECTIVITYFILESNAME');
     IfNameParameterExistsAdd('ZONEBOUNDCOST');
     IfNameParameterExistsAdd('ZONETARGET');
     IfNameParameterExistsAdd('ZONETARGET2');
     IfNameParameterExistsAdd('ZONECONTRIB');
     IfNameParameterExistsAdd('ZONECONTRIB2');
     IfNameParameterExistsAdd('PULOCK');
     IfNameParameterExistsAdd('PUZONE');

     // add single variable parameters
     IfParameterExistsAdd('BLM');
     IfParameterExistsAdd('NUMREPS');
     IfParameterExistsAdd('NUMITNS');
     IfParameterExistsAdd('PROBABILITYWEIGHTING');
     IfParameterExistsAdd('ASYMMETRICCONNECTIVITY');

     //ComboParameterToEdit.Text := ComboParameterToEdit.Items.Strings[1];
     ComboParameterToEdit.ItemIndex := 0;
end;

procedure TMarxanInterfaceForm.LoadZoneCost(const sFilename : string);
var
   InFile : TextFile;
   sLine : string;
   iZoneId, iCostId, iCount, iCount2 : integer;
   rMultiplier : extended;
begin
     ParameterGrid.ColCount := iNumberOfZones + 1;
     ParameterGrid.RowCount := iNumberOfCosts + 1;
     ParameterGrid.FixedRows := 1;
     ParameterGrid.FixedCols := 1;

     ParameterGrid.Cells[0,0] := '';
     for iCount := 1 to (ParameterGrid.ColCount-1) do
         ParameterGrid.Cells[iCount,0] := ReturnZoneName(iCount);
     for iCount := 1 to (ParameterGrid.RowCount-1) do
         ParameterGrid.Cells[0,iCount] := ReturnCostName(iCount);

     for iCount := 1 to (ParameterGrid.ColCount-1) do
         for iCount2 := 1 to (ParameterGrid.RowCount-1) do
             ParameterGrid.Cells[iCount,iCount2] := '0';

     assignfile(InFile,sFilename);
     reset(InFile);
     readln(InFile);

     while not Eof(InFile) do
     begin
          readln(InFile,sLine);
          try
             iZoneId := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
             iCostId := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
             rMultiplier := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));

             ParameterGrid.Cells[iZoneId,iCostId] := FloatToStr(rMultiplier);
          except
          end;
     end;

     closefile(InFile);

     AutoFitGrid(ParameterGrid,Canvas,True);
end;

procedure TMarxanInterfaceForm.SaveZoneCost(const sFilename : string);
var
   OutFile : TextFile;
   iCount, iCount2 : integer;
   rValue : extended;
begin
     assignfile(OutFile,sFilename);
     rewrite(OutFile);
     writeln(OutFile,'zoneid,costid,multiplier');
     for iCount := 1 to (ParameterGrid.ColCount-1) do
         for iCount2 := 1 to (ParameterGrid.RowCount-1) do
         begin
              try
                 rValue := StrToFloat(ParameterGrid.Cells[iCount,iCount2]);

                 if (rValue <> 0) then
                    writeln(OutFile,IntToStr(iCount) + ',' +
                                    IntToStr(iCount2) + ',' +
                                    FloatToStr(rValue));
              except
              end;
         end;
     closefile(OutFile);
end;

procedure TMarxanInterfaceForm.LoadZoneBoundCost(const sFilename : string);
var
   InFile : TextFile;
   sLine : string;
   iZoneId1, iZoneId2, iCount, iCount2 : integer;
   rCost : extended;
begin
     ParameterGrid.ColCount := iNumberOfZones + 1;
     ParameterGrid.RowCount := ParameterGrid.ColCount;
     ParameterGrid.FixedRows := 1;
     ParameterGrid.FixedCols := 1;

     ParameterGrid.Cells[0,0] := '';
     for iCount := 1 to (ParameterGrid.ColCount-1) do
     begin
          ParameterGrid.Cells[iCount,0] := ReturnZoneName(iCount);
          ParameterGrid.Cells[0,iCount] := ParameterGrid.Cells[iCount,0];
     end;

     for iCount := 1 to (ParameterGrid.ColCount-1) do
         for iCount2 := 1 to (ParameterGrid.RowCount-1) do
             ParameterGrid.Cells[iCount,iCount2] := '0';

     assignfile(InFile,sFilename);
     reset(InFile);
     readln(InFile);

     while not Eof(InFile) do
     begin
          readln(InFile,sLine);
          try
             iZoneId1 := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
             iZoneId2 := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
             rCost := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));

             ParameterGrid.Cells[iZoneId1,iZoneId2] := FloatToStr(rCost);
             ParameterGrid.Cells[iZoneId2,iZoneId1] := FloatToStr(rCost);
          except
          end;
     end;

     closefile(InFile);

     AutoFitGrid(ParameterGrid,Canvas,True);
end;

procedure TMarxanInterfaceForm.SaveZoneBoundCost(const sFilename : string);
var
   OutFile : TextFile;
   iCount, iCount2 : integer;
   rValue : extended;
begin
     assignfile(OutFile,sFilename);
     rewrite(OutFile);
     writeln(OutFile,'zoneid,costid,multiplier');
     for iCount := 1 to (ParameterGrid.ColCount-1) do
         for iCount2 := iCount to (ParameterGrid.RowCount-1) do
         begin
              try
                 rValue := StrToFloat(ParameterGrid.Cells[iCount,iCount2]);

                 if (rValue <> 0) then
                    writeln(OutFile,IntToStr(iCount) + ',' +
                                    IntToStr(iCount2) + ',' +
                                    FloatToStr(rValue));
              except
              end;
         end;
     closefile(OutFile);
end;

procedure TMarxanInterfaceForm.LoadZoneTarget(const sFilename : string);
var
   InFile : TextFile;
   sLine : string;
   iZoneId, iFeatureId, iCount, iCount2 : integer;
   rTarget : extended;
begin
     // we assume all zone targets are type 1 (proportional target)
     ParameterGrid.ColCount := iNumberOfZones + 1;
     ParameterGrid.RowCount := iNumberOfFeatures + 1;
     ParameterGrid.FixedRows := 1;
     ParameterGrid.FixedCols := 1;

     ParameterGrid.Cells[0,0] := '';
     for iCount := 1 to (ParameterGrid.ColCount-1) do
         ParameterGrid.Cells[iCount,0] := ReturnZoneName(iCount);
     for iCount := 1 to (ParameterGrid.RowCount-1) do
         ParameterGrid.Cells[0,iCount] := ReturnFeatureName(iCount);

     for iCount := 1 to (ParameterGrid.ColCount-1) do
         for iCount2 := 1 to (ParameterGrid.RowCount-1) do
             ParameterGrid.Cells[iCount,iCount2] := '0';

     assignfile(InFile,sFilename);
     reset(InFile);
     readln(InFile);

     while not Eof(InFile) do
     begin
          readln(InFile,sLine);
          try
             iZoneId := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
             iFeatureId := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
             rTarget := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));

             ParameterGrid.Cells[iZoneId,iFeatureId] := FloatToStr(rTarget);
          except
          end;
     end;

     closefile(InFile);

     AutoFitGrid(ParameterGrid,Canvas,True);
end;

procedure TMarxanInterfaceForm.SaveZoneTarget(const sFilename : string);
var
   OutFile : TextFile;
   iCount, iCount2 : integer;
   rValue : extended;
begin
     // we assume all zone targets are type 1 (proportional target)
     assignfile(OutFile,sFilename);
     rewrite(OutFile);
     writeln(OutFile,'zoneid,specid,target,targttype');
     for iCount := 1 to (ParameterGrid.ColCount-1) do
         for iCount2 := 1 to (ParameterGrid.RowCount-1) do
         begin
              try
                 rValue := StrToFloat(ParameterGrid.Cells[iCount,iCount2]);

                 if (rValue <> 0) then
                    writeln(OutFile,IntToStr(iCount) + ',' +
                                    IntToStr(iCount2) + ',' +
                                    FloatToStr(rValue) + ',1');
              except
              end;
         end;
     closefile(OutFile);
end;

procedure TMarxanInterfaceForm.LoadZoneContrib(const sFilename : string);
var
   InFile : TextFile;
   sLine : string;
   iZoneId, iFeatureId, iCount, iCount2 : integer;
   rContribution : extended;
   fZoneContribFile : boolean;
begin
     // we detect if this is a zonecontrib or zonecontrib2 file
     assignfile(InFile,sFilename);
     reset(InFile);
     readln(InFile,sLine);
     fZoneContribFile :=  (CountDelimitersInRow(sLine,',') > 1);

     ParameterGrid.ColCount := iNumberOfZones + 1;
     if fZoneContribFile then
        ParameterGrid.RowCount := iNumberOfFeatures + 1
     else
         ParameterGrid.RowCount := 2;
     ParameterGrid.FixedRows := 1;
     ParameterGrid.FixedCols := 1;

     ParameterGrid.Cells[0,0] := '';
     for iCount := 1 to (ParameterGrid.ColCount-1) do
         ParameterGrid.Cells[iCount,0] := ReturnZoneName(iCount);
     if fZoneContribFile then
     begin
          for iCount := 1 to (ParameterGrid.RowCount-1) do
              ParameterGrid.Cells[0,iCount] := ReturnFeatureName(iCount);
     end
     else
         ParameterGrid.Cells[0,1] := 'all features';

     for iCount := 1 to (ParameterGrid.ColCount-1) do
         for iCount2 := 1 to (ParameterGrid.RowCount-1) do
             ParameterGrid.Cells[iCount,iCount2] := '0';

     while not Eof(InFile) do
     begin
          readln(InFile,sLine);
          try
             iZoneId := StrToInt(GetDelimitedAsciiElement(sLine,',',1));

             if fZoneContribFile then
             begin
                  iFeatureId := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
                  rContribution := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));
             end
             else
             begin
                  iFeatureId := 1;
                  rContribution := StrToFloat(GetDelimitedAsciiElement(sLine,',',2));
             end;

             ParameterGrid.Cells[iZoneId,iFeatureId] := FloatToStr(rContribution);
          except
          end;
     end;

     closefile(InFile);

     AutoFitGrid(ParameterGrid,Canvas,True);
end;

procedure TMarxanInterfaceForm.SaveZoneContrib(const sFilename : string);
var
   OutFile : TextFile;
   iCount, iCount2 : integer;
   rValue : extended;
   fZoneContribFile : boolean;
begin
     // we detect if this is a zonecontrib or zonecontrib2 file
     fZoneContribFile := (ParameterGrid.RowCount > 2);

     assignfile(OutFile,sFilename);
     rewrite(OutFile);
     if fZoneContribFile then
        writeln(OutFile,'zoneid,specid,fraction')
     else
         writeln(OutFile,'zoneid,fraction');

     for iCount := 1 to (ParameterGrid.ColCount-1) do
         for iCount2 := 1 to (ParameterGrid.RowCount-1) do
         begin
              try
                 rValue := StrToFloat(ParameterGrid.Cells[iCount,iCount2]);

                 if (rValue <> 0) then
                 begin
                      if fZoneContribFile then
                         writeln(OutFile,IntToStr(iCount) + ',' +
                                         IntToStr(iCount2) + ',' +
                                         FloatToStr(rValue) + ',1')
                      else
                          writeln(OutFile,IntToStr(iCount) + ',' +
                                         FloatToStr(rValue) + ',1');
                 end;

              except
              end;
         end;

     closefile(OutFile);
end;

procedure TMarxanInterfaceForm.ParameterGridKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
     SetEditElement;
end;

procedure TMarxanInterfaceForm.CheckEditAllRowsClick(Sender: TObject);
begin
     if fParameterChanged then
     begin
          if (mrYes = MessageDlg('Save parameter before switching edit mode?',mtConfirmation,[mbYes,mbNo],0)) then
             SaveParameter
          else
          begin
               LoadParameter;
               SetEditElement;
          end;
     end;
end;

end.
