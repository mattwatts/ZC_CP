unit process_retention;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ds, Grids, Db, DBTables, Gauges;

type
  TProcessRetentionForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ComboBaseDirectorys: TComboBox;
    Label5: TLabel;
    OutputGrid: TStringGrid;
    Label1: TLabel;
    ComboPUShape: TComboBox;
    Label2: TLabel;
    ComboPUKey: TComboBox;
    ATable: TTable;
    AQuery: TQuery;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Gauge1: TGauge;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    function ExtractRetention(const iScenarioFeatureCount : integer;
                              const sFeatureReport, sHotspotsReport : string;
                              var sRetentionLine : string;
                              const sBaseDirectory : string) : extended;
    procedure ScanPUFields;
    procedure ExtractResults;
    procedure PopulateSelectionOrder(const sLogFile, sShapeName, sShapeKey, sFieldName : string);
    procedure ComboPUShapeChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ProcessRetentionForm: TProcessRetentionForm;
  ExtantArea, OrigAvTgt : Array_t;

implementation

uses math, SCP_Main, CSV_Child, FileCtrl, Miscellaneous, GIS;
// Childwin, hotspots_accumulation, autofit, MAIN
{$R *.DFM}

function LoadChildHandle(const sName : string) : TCSVChild;
begin
     try
        with SCPForm do
        begin
             // create a new CSV child window
             CreateCSVChild(sName,0);
             Result := TCSVChild(MDIChildren[ReturnNamedChildIndex(4,sName)]);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadChildHandle',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure StartAnalysis(const sBaseDir : string);
var
   LogFile : TextFile;
begin
     try
        // create destruction output files
        ForceDirectories(sBaseDir);

        assignfile(LogFile,sBaseDir + '\analysis_log.csv');
        rewrite(LogFile);
        writeln(LogFile,'Analysis started in path ' + sBaseDir);
        closefile(LogFile);

        assignfile(LogFile,sBaseDir + '\calculate_log.csv');
        rewrite(LogFile);
        writeln(LogFile,'column,extant,destroyed,target,retention');
        closefile(LogFile);

        // create LastCycleNumber log
        assignfile(LogFile,sBaseDir + '\LastCycleNumber.csv');
        rewrite(LogFile);
        writeln(LogFile,'scenario,last cycle');
        closefile(LogFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in StartAnalysis',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure UpdateLog(const sBaseDir, sInfo : string);
var
   LogFile : TextFile;
begin
     try
        // create destruction output files
        assignfile(LogFile,sBaseDir + '\analysis_log.csv');
        append(LogFile);
        writeln(LogFile,sInfo);
        closefile(LogFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in UpdateLog',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function Destroy_GetLastCycleNumber(const sScenario, sBaseDir, sLogDir : string) : integer;
var
   DestroyedChild, ReservedChild, RetentionChild : TCSVChild;
   LogFile : TextFile;
begin
     try
        DestroyedChild := LoadChildHandle(sScenario + '\total_destruct_area.csv');

        // determine cycle number (row id) of the last cycle
        Result := DestroyedChild.aGrid.RowCount - 1;

        DestroyedChild.Free;

        assignfile(LogFile,sLogDir + '\LastCycleNumber.csv');
        append(LogFile);
        writeln(LogFile,sScenario + ',' + IntToStr(Result));
        closefile(LogFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Destroy_GetLastCycleNumber',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure UpdateCalculateLog(const sBaseDir, sInfo : string);
var
   LogFile : TextFile;
begin
     try
        // create destruction output files
        assignfile(LogFile,sBaseDir + '\calculate_log.csv');
        append(LogFile);
        writeln(LogFile,sInfo);
        closefile(LogFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in UpdateLog',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure Destroy_ExtractCycle(const sBaseDir, sLogDir, sScenario : string;
                               const iCycle, iOutputColumn : integer;
                               OutputGrid : TStringGrid;
                               InfoChild : TCSVChild;
                               const fInfoChild : boolean);
var
   DestroyedChild, ReservedChild, RetentionChild : TCSVChild;
   iCount : integer;
   rExtant, rTarget, rDestroyed : extended;
begin
     try
        // We must get row iCycle from each the 3 files and write them cumulatively
        // as columns to OutputChild.
        // If there is an exception, write the contents of OutputChild to a debug file
        // and notify the user where the file is.

        // load the 3 files for this run
        // AreaDestroyed.csv
        // AreaReserved.csv
        // Retention.csv
        //DestroyedChild := LoadChildHandle(sScenario + '\total_destruct_area.csv');
        DestroyedChild := LoadChildHandle(sScenario + '\AreaDestroyed_.csv');
        ReservedChild := LoadChildHandle(sScenario + '\AreaReserved_.csv');
        RetentionChild := LoadChildHandle(sScenario + '\Retention_.csv');

        OutputGrid.Cells[iOutputColumn,1] := 'conserved';
        OutputGrid.Cells[iOutputColumn + 1,1] := 'destroyed';
        OutputGrid.Cells[iOutputColumn + 2,1] := 'retained';

        // extract cycle iCycle from these files
        for iCount := 1 to (DestroyedChild.aGrid.ColCount - 1) do
        begin
             OutputGrid.Cells[iOutputColumn,iCount + 1] := ReservedChild.aGrid.Cells[iCount,iCycle];
             OutputGrid.Cells[iOutputColumn + 1,iCount + 1] := DestroyedChild.aGrid.Cells[iCount,iCycle];

             if fInfoChild then
             begin
                  ExtantArea.rtnValue(iCount,@rExtant);
                  OrigAvTgt.rtnValue(iCount,@rTarget);
                  rDestroyed := StrToFloat(DestroyedChild.aGrid.Cells[iCount,iCycle]);

                  if (rTarget > 0) then
                     OutputGrid.Cells[iOutputColumn + 2,iCount + 1] := FloatToStr((rExtant - rDestroyed) / rTarget * 100)
                  else
                      OutputGrid.Cells[iOutputColumn + 2,iCount + 1] := '0';

                  UpdateCalculateLog(sLogDir,//'column,extant,destroyed,target,retention'
                                              IntToStr(iCount) + ',' +
                                              FloatToStr(rExtant) + ',' +
                                              FloatToStr(rDestroyed) + ',' +
                                              FloatToStr(rTarget) + ',' +
                                              OutputGrid.Cells[iOutputColumn + 2,iCount + 1]
                                              );
             end
             else
                 OutputGrid.Cells[iOutputColumn + 2,iCount + 1] := RetentionChild.aGrid.Cells[iCount,iCycle];
        end;

        DestroyedChild.Free;
        ReservedChild.Free;
        RetentionChild.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Destroy_ExtractCycle',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure LoadInfoChildData(InfoChild : TCSVChild;
                            const iNumberOfFeatures : integer);
var
   rValue : extended;
   iCount : integer;
begin
     try
        ExtantArea := Array_t.Create;
        ExtantArea.init(SizeOf(extended),iNumberOfFeatures);
        OrigAvTgt := Array_t.Create;
        OrigAvTgt.init(SizeOf(extended),iNumberOfFeatures);

        for iCount := 1 to iNumberOfFeatures do
        begin
             rValue := StrToFloat(InfoChild.aGrid.Cells[5,iCount]);
             ExtantArea.setValue(iCount,@rValue);
             rValue := StrToFloat(InfoChild.aGrid.Cells[6,iCount]);
             OrigAvTgt.setValue(iCount,@rValue);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadInfoChildData',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function TrimScenarioName(const sScenarioName : string) : string;
var
   iDelimiters : integer;
begin
     // use only last portion of path name for scenario name, eg. naderwar\scenario1 out of D:\mwatts\28Oct2005\databases2\naderwar\scenario1
     iDelimiters := CountDelimitersInRow(sScenarioName,'\');
     // there are N delimiters, which means N+1 elements
     // we need element N and element N+1
     Result := GetDelimitedAsciiElement(sScenarioName,'\',iDelimiters) + ' ' + GetDelimitedAsciiElement(sScenarioName,'\',iDelimiters + 1);
end;

function AnalyseHotspotsListOfBaseDirs(const iNumberOfFeatures : integer;
                                       const sInfoTable, sScenarioName : string;
                                       OutputGrid : TStringGrid) : string;
var
   sBaseDir,
   sScenario, sLogDir : string;
   FeatureReportChild,
   InfoChild : TCSVChild;
   iFeatureReportChildId,
   iOutputColumn, iCount, iScenario, iChildId,
   iDestruction, iComplementarity, iVulnerability, iVariable, iCycle, iLastCycle : integer;
   fInfoChild, fContinue,
   fAnalyse : boolean;
begin
     try
        fInfoChild := False;
        if (sInfoTable <> '') then
        begin
             iChildId := SCPForm.ReturnNamedChildIndex(4,sInfoTable);
             if (iChildId <> -1) then
             begin
                  InfoChild := TCSVChild(SCPForm.MDIChildren[iChildId]);
                  fInfoChild := True;
                  LoadInfoChildData(InfoChild,iNumberOfFeatures);
             end;
        end;

        // create output grid with the required dimensions and populate it
        // 1 feature name column + 1 feature target column
        OutputGrid.ColCount := 2;
        OutputGrid.RowCount := iNumberOfFeatures + 2;
        // 1 header row for analysis identifier +
        // 1 header row for value identifier +
        // iNumberOfFeatures rows, one for each feature
        OutputGrid.Cells[0,0] := 'scenario ->';
        OutputGrid.Cells[0,1] := 'feature name';
        OutputGrid.Cells[1,1] := 'feature target';

        // write feature name to first column, copying from feature report
        // Write feature rInitialTrimmedTarget to column 2, copying from feature report.
        // This means we must move all the other columns to the right by 1 column.
        // It also means we must real all the other column from the right by 1 column later when we parse them.
        iFeatureReportChildId := SCPForm.ReturnNamedChildIndex(4,sInfoTable);
        if (iFeatureReportChildId <> -1) then
        begin
             FeatureReportChild := TCSVChild(SCPForm.MDIChildren[iFeatureReportChildId]);
             for iCount := 1 to OutputGrid.RowCount do
             begin
                  OutputGrid.Cells[0,iCount+1] := FeatureReportChild.aGrid.Cells[0,iCount];
                  OutputGrid.Cells[1,iCount+1] := FeatureReportChild.aGrid.Cells[7,iCount];
             end;
             sLogDir := ExtractFilePath(sInfoTable);
        end
        else
            sLogDir := 'C:\';

        StartAnalysis(sLogDir);

        iLastCycle := 1000000;

        UpdateLog(sLogDir,'start pre-parse');

        sBaseDir := sScenarioName;
        sScenario := sBaseDir;
        UpdateLog(sLogDir,'pre-parse scenario ' + sScenario + ' found');
        iCycle := Destroy_GetLastCycleNumber(sScenario,sBaseDir,sLogDir);
        if (iCycle < iLastCycle) then
           iLastCycle := iCycle;

        UpdateLog(sLogDir,'end pre-parse');

        iLastCycle := 1;
        fContinue := True;

        UpdateLog(sLogDir,'');
        UpdateLog(sLogDir,'');
        UpdateLog(sLogDir,'start parse');

        iOutputColumn := 2;

        // analyse this cycle for each of the runs
        if fContinue then
        begin
             // add 3 extra columns to store the results for this this scenario
             OutputGrid.ColCount := OutputGrid.ColCount + 3;
             OutputGrid.Cells[OutputGrid.ColCount-1,0] := '_';
             OutputGrid.Cells[OutputGrid.ColCount-2,0] := '_';
             OutputGrid.Cells[OutputGrid.ColCount-3,0] := '_';
             sScenario := sBaseDir;
             // write scenario name to output table
             OutputGrid.Cells[iOutputColumn,0] := TrimScenarioName(sScenario);
             UpdateLog(sLogDir,'parse scenario ' + sScenario + ' found');
             Destroy_ExtractCycle(sBaseDir,sLogDir,sScenario,iLastCycle,
                                  iOutputColumn,OutputGrid,
                                  InfoChild,fInfoChild);
             Inc(iOutputColumn,3);
        end;

        UpdateLog(sLogDir,'end parse');

        if fInfoChild then
        begin
             ExtantArea.Destroy;
             OrigAvTgt.Destroy;
        end;

        // save the OutputGrid to a file
        SaveStringGrid2CSV(OutputGrid,sLogDir + '\hotspots_destruction_analysis.csv');
        SCPForm.CreateCSVChild(sLogDir + '\hotspots_destruction_analysis.csv',0);

        Result := sLogDir + '\hotspots_destruction_analysis.csv';

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in AnalyseHotspotsListOfBaseDirs',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TProcessRetentionForm.FormCreate(Sender: TObject);
var
   iCount : integer;
   AGIS : TGIS_Child;
begin
     with SCPForm do
          if (MDIChildCount > 0) then
          begin
               ComboBaseDirectorys.Items.Clear;
               ComboPUShape.Items.Clear;

               for iCount := 0 to (MDIChildCount-1) do
               begin
                    if (MDIChildren[iCount].tag = 4) then
                       ComboBaseDirectorys.Items.Add(MDIChildren[iCount].Caption);
                    if (MDIChildren[iCount].tag = 2) then
                    begin
                         AGIS := TGIS_Child(MDIChildren[iCount]);
                         ComboPUShape.Items.Add(AGIS.Map1.LayerName[AGIS.iLastLayerHandle]);
                    end;
               end;

               if (ComboBaseDirectorys.Items.Count > 0) then
                  ComboBaseDirectorys.Text := ComboBaseDirectorys.Items.Strings[0];

               if (ComboPUShape.Items.Count > 0) then
               begin
                    ComboPUShape.Text := ComboPUShape.Items.Strings[0];
                    ScanPUFields;
               end;
          end;
end;

function TProcessRetentionForm.ExtractRetention(const iScenarioFeatureCount : integer;
                                                const sFeatureReport, sHotspotsReport : string;
                                                var sRetentionLine : string;
                                                const sBaseDirectory : string) : extended;
var
   OutFile : TextFile;
   HotspotsChild, ReportChild : TCSVChild;
   rMinimumRetention, rMaximumRetention, rRetention, rAreaCompromised, rCompromised,
   rTarget, rTotal, rDestroyed, rRemainingTotal : extended;
   iNumberOfFeatures, iNumberOfScenarios,
   iScenarioCount, iFeatureCount : integer;
   sScenarioName : string;
begin
     try
        Screen.Cursor := crHourglass;
        // create destination file for results to go in
        assignfile(OutFile,'c:\extract_retention.csv');
        rewrite(OutFile);
        writeln(OutFile,'scenario,Minimum Retention,Maximum Retention,Area Compromised');

        HotspotsChild := TCSVChild(SCPForm.MDIChildren[SCPForm.ReturnNamedChildIndex(4,sHotspotsReport)]);
        SCPForm.CreateCSVChild(sFeatureReport,0);
        ReportChild := TCSVChild(SCPForm.MDIChildren[SCPForm.ReturnNamedChildIndex(4,sFeatureReport)]);

        iNumberOfFeatures := iScenarioFeatureCount;
        iNumberOfScenarios := 1;

        // traverse scenarios
        iScenarioCount := 1;

        sScenarioName := HotspotsChild.aGrid.Cells[(2*(iScenarioCount+1))+iScenarioCount-4,0] + '__' +
                         HotspotsChild.aGrid.Cells[(2*(iScenarioCount+1))+iScenarioCount-4,1];
        rMinimumRetention := 10000;
        rMaximumRetention := 0;
        rAreaCompromised := 0;

        sRetentionLine := '';

        // traverse features
        for iFeatureCount := 1 to iNumberOfFeatures do
        begin
             // does feature have minimum retention
             rRetention := StrToFloat(HotspotsChild.aGrid.Cells[(2*(iScenarioCount+1))+iScenarioCount-1,iFeatureCount+1]);
             if (rRetention < rMinimumRetention) then
                rMinimumRetention := rRetention;
             if (rRetention > rMaximumRetention) then
                rMaximumRetention := rRetention;

             sRetentionLine := sRetentionLine + HotspotsChild.aGrid.Cells[(2*(iScenarioCount+1))+iScenarioCount-1,iFeatureCount+1];
             if (iFeatureCount < iNumberOfFeatures) then
                sRetentionLine := sRetentionLine + ',';
             // calculate area compromised
             rTarget := StrToFloat(ReportChild.aGrid.Cells[7,iFeatureCount]);
             rTotal := StrToFloat(ReportChild.aGrid.Cells[5,iFeatureCount]);
             rDestroyed := StrToFloat(HotspotsChild.aGrid.Cells[(2*(iScenarioCount+1))+iScenarioCount-2,iFeatureCount+1]);
             rRemainingTotal := rTotal - rDestroyed;
             if (rRemainingTotal < rTarget)
             and (rTarget > 0) then
                 rCompromised := rTarget - rRemainingTotal
             else
                 rCompromised := 0;
             rAreaCompromised := rAreaCompromised + rCompromised;
        end;

        Result := rAreaCompromised;

        // write scenario result to file
        writeln(OutFile,sScenarioName + ',' + FloatToStr(rMinimumRetention) + ',' + FloatToStr(rMaximumRetention) + ',' + FloatToStr(rAreaCompromised));

        ReportChild.Free;
        HotspotsChild.Free;

        closefile(OutFile);
        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Extract Retention base dir : ' + sBaseDirectory + ' feature count : ' + IntToStr(iFeatureCount),mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TProcessRetentionForm.BitBtn1Click(Sender: TObject);
begin
     try
        ExtractResults;
     except
     end;
end;

procedure TProcessRetentionForm.PopulateSelectionOrder(const sLogFile, sShapeName, sShapeKey, sFieldName : string);
var
   InFile : TextFile;
   iArraySize, iPUID, iMatchPUID, iCount, iCount2 : integer;
   SelectionArray : Array_t;
   sLine : string;
begin
     try
        // parse the log file, counting selections
        iArraySize := 0;
        assignfile(InFile,sLogFile);
        reset(InFile);
        repeat
              readln(InFile,sLine);

        until (sLine = '***-----------separator-----------*** Available End');
        repeat
              readln(InFile,sLine);
              if (sLine <> '***-----------separator-----------*** Negotiated End') then
                 Inc(iArraySize);

        until (sLine = '***-----------separator-----------*** Negotiated End');
        closefile(InFile);

        if (iArraySize > 0) then
        begin
             // create array to store selections
             SelectionArray := Array_t.Create;
             SelectionArray.init(SizeOf(integer),iArraySize);

             // parse the log file, storing selections
             iArraySize := 0;
             assignfile(InFile,sLogFile);
             reset(InFile);
             repeat
                   readln(InFile,sLine);

             until (sLine = '***-----------separator-----------*** Available End');
             repeat
                   readln(InFile,sLine);
                   if (sLine <> '***-----------separator-----------*** Negotiated End') then
                   begin
                        Inc(iArraySize);
                        iPUID := StrToInt(sLine);
                        SelectionArray.setValue(iArraySize,@iPUID);
                   end;

             until (sLine = '***-----------separator-----------*** Negotiated End');
             closefile(InFile);

             // parse the dbf table
             ATable.DatabaseName := ExtractFilePath(sShapeName);
             ATable.TableName := ExtractFileName(ChangeFileExt(sShapeName,'.dbf'));;
             ATable.Open;
             // for each record
             for iCount := 1 to ATable.RecordCount do
             begin
                  iMatchPUID := ATable.FieldByName(sShapeKey).AsInteger;
                  // find PUID match in array
                  for iCount2 := 1 to SelectionArray.lMaxSize do
                  begin
                       SelectionArray.rtnValue(iCount2,@iPUID);
                       if iMatchPUID = iPUID then
                       begin
                            // write selection order for PUID match
                            ATable.Edit;
                            ATable.FieldByName(sFieldName).AsInteger := iCount2;
                       end;
                  end;
                  ATable.Next;
             end;

             ATable.Close;
             SelectionArray.Destroy;
        end;          
     except
     end;
end;

procedure TProcessRetentionForm.ExtractResults;
var
   sTmpFile, sBaseDirectory, sFeatureReport, sRetentionLine, sOutputDirectory, sOutputName, sExt, sFieldName, sShapeName, sShapeKey : string;
   iCount, iScenarioFeatureCount : integer;
   rAreaCompromised : extended;
   ScenarioChild : TCSVChild;
   AreaCompromisedFile, RetentionFile : TextFile;
begin
     try
        // For each base diretory in the list, extract base directory, feature number & report name
        // which are 1-based columns 1, 2 & 3 respectively.
        if (ComboBaseDirectorys.Text <> '') then
        begin
             Screen.Cursor := crHourglass;

             // close the GIS child if it is open
             if (GIS_Child <> nil) then
             begin
                  GIS_Child.Free;
             end;

             sOutputDirectory := ExtractFilePath(ComboBaseDirectorys.Text);
             sOutputName := ExtractFileName(ComboBaseDirectorys.Text);
             sExt := ExtractFileExt(ComboBaseDirectorys.Text);
             if Length(sExt) > 0 then
                sOutputName := Copy(sOutputName,1,Length(sOutputName) - Length(sExt));

             assignfile(AreaCompromisedFile,sOutputDirectory + sOutputName + '_area_compromised.csv');
             rewrite(AreaCompromisedFile);
             writeln(AreaCompromisedFile,'scenario,area compromised');

             assignfile(RetentionFile,sOutputDirectory + sOutputName + '_retention.csv');
             rewrite(RetentionFile);

             Gauge1.Visible := True;
             Gauge1.Refresh;

             ScenarioChild := TCSVChild(SCPForm.MDIChildren[SCPForm.ReturnNamedChildIndex(4,ComboBaseDirectorys.Text)]);
             for iCount := 1 to (ScenarioChild.aGrid.RowCount-1) do
             begin
                  sBaseDirectory := ScenarioChild.aGrid.Cells[0,iCount];

                  if fileexists(sBaseDirectory + '\minset_end.txt')
                  and fileexists(sBaseDirectory + '\Retention_.csv') then
                  begin
                       iScenarioFeatureCount := StrToInt(ScenarioChild.aGrid.Cells[1,iCount]);
                       sFeatureReport := ScenarioChild.aGrid.Cells[2,iCount];

                       try
                          sTmpFile := AnalyseHotspotsListOfBaseDirs(iScenarioFeatureCount,sFeatureReport,sBaseDirectory,OutputGrid);

                          rAreaCompromised := ExtractRetention(iScenarioFeatureCount,sFeatureReport,sTmpFile,sRetentionLine,sBaseDirectory);

                       except
                             Screen.Cursor := crDefault;
                             MessageDlg('Exception while analysing hotspots',mtError,[mbOk],0);
                             Application.Terminate;
                       end;
                  end
                  else
                  begin
                       rAreaCompromised := -1;
                       sRetentionLine := 'scenario not present';
                  end;

                  if (ScenarioChild.aGrid.ColCount > 3) then
                     if fileexists(sBaseDirectory + '\autosave.log') then
                     begin

                          // add a field for this scenario
                          sFieldName := ScenarioChild.aGrid.Cells[3,iCount];
                          sShapeName := ScenarioChild.aGrid.Cells[4,iCount];
                          sShapeKey := ScenarioChild.aGrid.Cells[5,iCount];

                          ForceDBFIntegerField(ATable,AQuery,ChangeFileExt(sShapeName,'.dbf'),sFieldName);

                          // populate the field with selection order for this scenario
                          PopulateSelectionOrder(sBaseDirectory + '\autosave.log',sShapeName,sShapeKey,sFieldName);

                     end;

                  writeln(AreaCompromisedFile,sBaseDirectory + ',' + FloatToStr(rAreaCompromised));
                  writeln(RetentionFile,sBaseDirectory + ',' + sRetentionLine);

                  Gauge1.Progress := Round(iCount / ScenarioChild.aGrid.RowCount * 100);
                  Gauge1.Refresh;
             end;

             closefile(AreaCompromisedFile);
             closefile(RetentionFile);

             // relaunch the GIS child with the layer present
             // activate browse control of GIS child to select scenarios added

             Screen.Cursor := crDefault;
        end;
     except
     end;
end;

procedure TProcessRetentionForm.ScanPUFields;
var
   sTableName : string;
   iCount : integer;
begin
     if (ComboPUShape.Text <> '') then
        if fileexists(ComboPUShape.Text) then
        begin
             ATable.DatabaseName := ExtractFilePath(ComboPUShape.Text);
             sTableName := ExtractFileName(ComboPUShape.Text);
             sTableName := Copy(sTableName,1,Length(sTableName)-4);
             ATable.TableName := sTableName + '.dbf';

             if fileexists(ExtractFilePath(ComboPUShape.Text) + sTableName + '.dbf') then
             begin
                  ATable.Open;

                  ComboPUKey.Items.Clear;
                  ComboPUKey.Text := '';
                  for iCount := 0 to (ATable.FieldCount - 1) do
                      ComboPUKey.Items.Add(ATable.FieldDefs.Items[iCount].Name);
                  ComboPUKey.Text := ComboPUKey.Items.Strings[0];

                  ATable.Close;
             end;
        end;
end;
     
procedure TProcessRetentionForm.ComboPUShapeChange(Sender: TObject);
begin
     if (ComboPUShape.Text <> '') then
        ScanPUFields;
end;

end.
