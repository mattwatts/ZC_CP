// Purpose : To analyse the runs outputted by cplan-hotspots accumulation and destruction.
// Author : Matthew Watts
// Date : 19/9/1999


// note : accumulation needs fast file reading routine to scan feature file (as opt as possible)
// for each file, write :
//    number of features satisfied
//    vegetated area
//    reserved area

unit hotspots_accumulation;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls,
  childwin, ds;

type
  THotspotsAnalysisForm = class(TForm)
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    BitBtn1: TBitBtn;
    procedure AnalyseHotspots(const sBaseDir : string;
                              const iNumberOfFeatures : integer;
                              const sInfoTable : string);
    // same as AnalyseHotspots except for a list of base dirs (customised for Kerrie Wilsons simulations)
    function AnalyseHotspotsListOfBaseDirs(const iNumberOfFeatures : integer;
                                           const sInfoTable, sScenarioName : string) : string;
    // same as AnalyseHotspots except for a specific year
    procedure AnalyseHotspotsYear(const sBaseDir : string;
                                  const iNumberOfFeatures : integer;
                                  const sInfoTable : string;
                                  const iYear : integer);
    procedure Accumulate_Run(const sScenario : string);
    procedure Destroy_ExtractCycle(const sBaseDir, sLogDir, sScenario : string;
                                   const iCycle, iOutputColumn : integer;
                                   OutputChild, InfoChild : TMDIChild;
                                   const fInfoChild : boolean);
    procedure StartAnalysis(const sBaseDir : string);
    procedure UpdateLog(const sBaseDir, sInfo : string);
    procedure UpdateCalculateLog(const sBaseDir, sInfo : string);
    procedure EndAnalysis(const sBaseDir : string);
    function Destroy_GetLastCycleNumber(const sScenario, sBaseDir, sLogDir : string) : integer;
    procedure LoadInfoChildData(InfoChild : TMDIChild;
                                const iNumberOfFeatures : integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HotspotsAnalysisForm: THotspotsAnalysisForm;
  ExtantArea, OrigAvTgt : Array_t;

function LoadChildHandle(const sName : string) : TMDIChild;


implementation

uses MAIN, FileCtrl, QryEndPoint;

{$R *.DFM}


function LoadChildHandle(const sName : string) : TMDIChild;
var
   iCount : integer;
begin
     try
        with SCPForm do
        begin
             {create a new MDI child window }
             Result := TMDIChild.Create(Application);
             Result.Caption := sName;

             Result.LoadFile;
             Result.fDataHasChanged := False;

             Result.KeyFieldGroup.Items.Clear;
             for iCount := 0 to (Result.aGrid.ColCount-1) do
                 Result.KeyFieldGroup.Items.Add(Result.aGrid.Cells[iCount,0]);
             Result.KeyCombo.Items := Result.KeyFieldGroup.Items;
             Result.KeyCombo.Text := Result.KeyFieldGroup.Items.Strings[0];
             Result.KeyFieldGroup.ItemIndex := 0;
             {set default key field to be first field in the grid}

             UpdateMenus;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadChildHandle',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure THotspotsAnalysisForm.StartAnalysis(const sBaseDir : string);
var
   LogFile : TextFile;
begin
     try
        //
        //if (RadioAnalysisType.ItemIndex = 0) then
           // accumulation run
        //else
        begin
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

        end; // destruction run

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in StartAnalysis',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure THotspotsAnalysisForm.UpdateLog(const sBaseDir, sInfo : string);
var
   LogFile : TextFile;
begin
     try
        //
        //if (RadioAnalysisType.ItemIndex = 0) then
           // accumulation run
        //else
        begin
             // create destruction output files
             assignfile(LogFile,sBaseDir + '\analysis_log.csv');
             append(LogFile);
             writeln(LogFile,sInfo);
             closefile(LogFile);

        end; // destruction run

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in UpdateLog',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure THotspotsAnalysisForm.EndAnalysis(const sBaseDir : string);
begin
     try
        //
        //if (RadioAnalysisType.ItemIndex = 0) then
           // accumulation run
        //else
        //begin
             // finalise destruction output files

        //end; // destruction run

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in EndAnalysis',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure THotspotsAnalysisForm.Accumulate_Run(const sScenario : string);
begin
     try

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Accumulate_Run',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function THotspotsAnalysisForm.Destroy_GetLastCycleNumber(const sScenario, sBaseDir, sLogDir : string) : integer;
var
   DestroyedChild, ReservedChild, RetentionChild : TMDIChild;
   //iIteration : integer;
   //fEnd : boolean;
   LogFile : TextFile;
begin
     try
        // load the 3 files for this run
        // AreaDestroyed.csv
        // AreaReserved.csv
        // Retention.csv
        DestroyedChild := LoadChildHandle(sScenario + '\total_destruct_area.csv');
        //ReservedChild := LoadChildHandle(sScenario + '\AreaReserved.csv');
        //RetentionChild := LoadChildHandle(sScenario + '\Retention.csv');

        // determine cycle number (row id) of the last cycle
        Result := DestroyedChild.SpinRow.Value - 1;

        DestroyedChild.Free;
        //ReservedChild.Free;
        //RetentionChild.Free;

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

procedure THotspotsAnalysisForm.UpdateCalculateLog(const sBaseDir, sInfo : string);
var
   LogFile : TextFile;
begin
     try
        //
        //if (RadioAnalysisType.ItemIndex = 0) then
           // accumulation run
        //else
        begin
             // create destruction output files
             assignfile(LogFile,sBaseDir + '\calculate_log.csv');
             append(LogFile);
             writeln(LogFile,sInfo);
             closefile(LogFile);

        end; // destruction run

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in UpdateLog',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure THotspotsAnalysisForm.Destroy_ExtractCycle(const sBaseDir, sLogDir, sScenario : string;
                                                     const iCycle, iOutputColumn : integer;
                                                     OutputChild, InfoChild : TMDIChild;
                                                     const fInfoChild : boolean);
var
   DestroyedChild, ReservedChild, RetentionChild : TMDIChild;
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
        DestroyedChild := LoadChildHandle(sScenario + '\total_destruct_area.csv');
        ReservedChild := LoadChildHandle(sScenario + '\AreaReserved_.csv');
        RetentionChild := LoadChildHandle(sScenario + '\Retention_.csv');

        OutputChild.aGrid.Cells[iOutputColumn,1] := 'conserved';
        OutputChild.aGrid.Cells[iOutputColumn + 1,1] := 'destroyed';
        OutputChild.aGrid.Cells[iOutputColumn + 2,1] := 'retained';

        // extract cycle iCycle from these files
        for iCount := 1 to (DestroyedChild.aGrid.ColCount - 1) do
        begin
             OutputChild.aGrid.Cells[iOutputColumn,iCount + 1] := ReservedChild.aGrid.Cells[iCount,iCycle];
             OutputChild.aGrid.Cells[iOutputColumn + 1,iCount + 1] := DestroyedChild.aGrid.Cells[iCount,iCycle];

             if fInfoChild then
             begin
                  ExtantArea.rtnValue(iCount,@rExtant);
                  OrigAvTgt.rtnValue(iCount,@rTarget);
                  rDestroyed := StrToFloat(DestroyedChild.aGrid.Cells[iCount,iCycle]);

                  if (rTarget > 0) then
                     OutputChild.aGrid.Cells[iOutputColumn + 2,iCount + 1] := FloatToStr((rExtant - rDestroyed) / rTarget * 100)
                  else
                      OutputChild.aGrid.Cells[iOutputColumn + 2,iCount + 1] := '0';

                  UpdateCalculateLog(sLogDir,//'column,extant,destroyed,target,retention'
                                              IntToStr(iCount) + ',' +
                                              FloatToStr(rExtant) + ',' +
                                              FloatToStr(rDestroyed) + ',' +
                                              FloatToStr(rTarget) + ',' +
                                              OutputChild.aGrid.Cells[iOutputColumn + 2,iCount + 1]
                                              );
             end
             else
                 OutputChild.aGrid.Cells[iOutputColumn + 2,iCount + 1] := RetentionChild.aGrid.Cells[iCount,iCycle];
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

procedure THotspotsAnalysisForm.LoadInfoChildData(InfoChild : TMDIChild;
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

procedure THotspotsAnalysisForm.AnalyseHotspots(const sBaseDir : string;
                                                const iNumberOfFeatures : integer;
                                                const sInfoTable : string);
var
   Destruction, Complementarity : array [1..2] of string[2];
   Vulnerability : array [1..4] of string[3];
   Variable : array [1..8] of string[4];
   sScenario, sLogDir : string;
   FeatureReportChild,
   InfoChild,
   OutputChild : TMDIChild;
   iFeatureReportChildId,
   iOutputColumn, iCount, iScenario, iChildId,
   iDestruction, iComplementarity, iVulnerability, iVariable, iCycle, iLastCycle : integer;
   fInfoChild, fContinue,
   fAnalyse : boolean;
begin
     try
        sLogDir := 'C:\';// SPECIFY OUTPUT DIRECTORY FOR CASE WHERE INPUT DIRECTORY IS READ ONLY
        fInfoChild := False;
        if (sInfoTable <> '') then
        begin
             iChildId := SCPForm.rtnTableId(sInfoTable);
             if (iChildId <> -1) then
             begin
                  InfoChild := TMDIChild(SCPForm.MDIChildren[iChildId]);
                  fInfoChild := True;
                  LoadInfoChildData(InfoChild,iNumberOfFeatures);
             end;
        end;

        Destruction[1] := 'D0';
        Destruction[2] := 'D1';

        Complementarity[1] := 'C0';
        Complementarity[2] := 'C1';

        Vulnerability[1] := '1v0';
        Vulnerability[2] := '2vm';
        Vulnerability[3] := '3vw';
        Vulnerability[4] := '4vr';

        Variable[1] := '1ri';
        Variable[2] := '2fr';
        Variable[3] := '3sr';
        Variable[4] := '4wt';
        Variable[5] := '5ir';
        Variable[6] := '6si';
        Variable[7] := '7one';
        Variable[8] := 'null';

        // accumulation
        // D0 C0
        // D0 C1
        // destruction
        // D1 C0
        // D1 C1

        {if (RadioAnalysisType.ItemIndex = 0) then
           iDestruction := 1 // accumulation run
        else}
        // only the destruction run is supported
        iDestruction := 2; // destruction run

        // create output child with the required dimensions and populate it
        SCPForm.CreateMDIChild('hotspots_analysis',False,False);
        OutputChild := SCPForm.rtnChild('hotspots_analysis');
        OutputChild.aGrid.ColCount := 158{145};
        // 3 outputs columns for each of 52{was 48} scenarios +
        // 1 index column +
        // 1 feature target column
        OutputChild.aGrid.RowCount := iNumberOfFeatures + 2;
        // 1 header row for analysis identifier +
        // 1 header row for value identifier +
        // iNumberOfFeatures rows, one for each feature
        OutputChild.SpinCol.Value := OutputChild.aGrid.ColCount;
        OutputChild.SpinRow.Value := OutputChild.aGrid.RowCount;
        OutputChild.aGrid.Cells[0,0] := 'scenario ->';
        OutputChild.aGrid.Cells[0,1] := 'feature name';

        // write feature name to first column, copying from feature report
        // Write feature rInitialTrimmedTarget to column 2, copying from feature report.
        // This means we must move all the other columns to the right by 1 column.
        // It also means we must real all the other column from the right by 1 column later when we parse them.
        iFeatureReportChildId := SCPForm.rtnTableId(sInfoTable);
        if (iFeatureReportChildId <> -1) then
        begin
             FeatureReportChild := TMDIChild(SCPForm.MDIChildren[iFeatureReportChildId]);
             for iCount := 1 to (OutputChild.aGrid.RowCount - 1) do
             begin
                  OutputChild.aGrid.Cells[0,iCount+1] := FeatureReportChild.aGrid.Cells[0,iCount+1];
                  OutputChild.aGrid.Cells[1,iCount+1] := FeatureReportChild.aGrid.Cells[7,iCount+1];
             end;
        end;

        StartAnalysis(sLogDir);

        iLastCycle := 1000000;

        UpdateLog(sLogDir,'start pre-parse');

        iScenario := 1;

        // do a first parse to determine the lowest last cycle number
        for iComplementarity := 1 to 2 do
            for iVulnerability := 1 to 4 do
                for iVariable := 1 to 8 do
                begin

                     sScenario := sBaseDir + '\' +
                                  Destruction[iDestruction] + '\' +
                                  Complementarity[iComplementarity] + '\' +
                                  Vulnerability[iVulnerability] + '\' +
                                  Variable[iVariable];

                     fAnalyse := False;

                     try
                        if fileexists(sScenario + '\hotspots_feature1.csv') then
                        begin
                             // examine this scenario
                             fAnalyse := True;
                             Inc(iScenario);
                        end;
                     except
                     end;

                     if fAnalyse then
                        UpdateLog(sLogDir,'pre-parse scenario ' + sScenario + ' found')
                     else
                         UpdateLog(sLogDir,'pre-parse scenario ' + sScenario + ' not found ***');

                     if fAnalyse then
                     begin
                          if (iDestruction = 1) then
                             Accumulate_Run(sScenario)
                          else
                          begin
                               iCycle := Destroy_GetLastCycleNumber(sScenario,sBaseDir,sLogDir);
                               if (iCycle < iLastCycle) then
                                  iLastCycle := iCycle;
                          end;
                     end
                     else
                         ;
                end;

        UpdateLog(sLogDir,'end pre-parse');

        // now we must query the user with the End Point (iLastCycle)
        QryEndPointForm := TQryEndPointForm.Create(Application);
        QryEndPointForm.EditEndPoint.Text := IntToStr(iLastCycle);
        fContinue := (mrOk = QryEndPointForm.ShowModal);
        try
           iLastCycle := StrToInt(QryEndPointForm.EditEndPoint.Text);
        except
        end;
        QryEndPointForm.Free;

        UpdateLog(sLogDir,'');
        UpdateLog(sLogDir,'');
        UpdateLog(sLogDir,'start parse');

        //iOutputColumn := 1;
        iOutputColumn := 2; // we have moved all the output columns to the right by one column

        iScenario := 1;
        // analyse this cycle for each of the runs
        if fContinue then
           for iComplementarity := 1 to 2 do
               for iVulnerability := 1 to 4 do
                   for iVariable := 1 to 8 do
                   begin
                        sScenario := sBaseDir + '\' +
                                     Destruction[iDestruction] + '\' +
                                     Complementarity[iComplementarity] + '\' +
                                     Vulnerability[iVulnerability] + '\' +
                                     Variable[iVariable];

                        fAnalyse := False;

                        try
                           if fileexists(sScenario + '\hotspots_feature1.csv') then
                           begin
                                // examine this scenario
                                fAnalyse := True;
                                Inc(iScenario);
                                OutputChild.aGrid.Cells[iOutputColumn,0] := Destruction[iDestruction] + '\' +
                                                                            Complementarity[iComplementarity] + '\' +
                                                                            Vulnerability[iVulnerability] + '\' +
                                                                            Variable[iVariable];
                           end;
                        except
                        end;

                        if fAnalyse then
                           UpdateLog(sLogDir,'parse scenario ' + sScenario + ' found')
                        else
                            UpdateLog(sLogDir,'parse scenario ' + sScenario + ' not found ***');

                        if fAnalyse then
                        begin
                             if (iDestruction = 1) then
                                Accumulate_Run(sScenario)
                             else
                             begin
                                  Destroy_ExtractCycle(sBaseDir,sLogDir,sScenario,iLastCycle,
                                                       iOutputColumn,OutputChild,
                                                       InfoChild,fInfoChild);
                             end;
                        end
                        else
                            //
                            ;
                        if fAnalyse then
                        begin
                             Inc(iOutputColumn,3);

                             if ((iOutputColumn + 3) > OutputChild.aGrid.ColCount) then
                                OutputChild.aGrid.ColCount := iOutputColumn + 3;
                        end;
                   end;

        UpdateLog(sLogDir,'end parse');

        EndAnalysis(sLogDir);

        if fInfoChild then
        begin
             ExtantArea.Destroy;
             OrigAvTgt.Destroy;
        end;

        // load the temporary files we have created
        //SCPForm.CreateMDIChild(sLogDir + '\LastCycleNumber.csv',True,False);
        //SCPForm.CreateMDIChild(sLogDir + '\analysis_log.csv',True,False);
        //SCPForm.CreateMDIChild(sLogDir + '\calculate_log.csv',True,False);
        // save the OutputChild to a file
        OutputChild.Caption := sLogDir + '\hotspots_destruction_analysis.csv';
        if fileexists(OutputChild.Caption) then
           deletefile(OutputChild.Caption);
        SCPForm.SaveTable(SCPForm.rtnTableID(OutputChild.Caption));
        OutputChild.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in AnalyseHotspots',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function GetDelimitedAsciiElement(const sLine, sDelimiter : string;
                                  const iColumn : integer) : string;
// returns the element at 1-based-index column iColumn
// returns blank string if the column does not exist in sLine
var
   sTrimLine : string;
   iPos, iTrim, iCount : integer;
begin
     Result := '';

     sTrimLine := sLine;
     iTrim := iColumn-1;
     if (iTrim > 0) then
        for iCount := 1 to iTrim do // trim the required number of columns from the start of the string
        begin
             iPos := Pos(sDelimiter,sTrimLine);
             sTrimLine := Copy(sTrimLine,iPos+1,Length(sTrimLine)-iPos);
        end;
     iPos := Pos(sDelimiter,sTrimLine);
     if (iPos = 1) then
     begin
          // there is a delimiter at the start of the line we must trim first
          sTrimLine := Copy(sTrimLine,2,Length(sTrimLine)-1);
          iPos := Pos(sDelimiter,sTrimLine);
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;
     end
     else
     begin
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;
     end;
end;

function CountDelimitersInRow(const sRow, sDelimiter : string) : integer;
var
   iCount : integer;
begin
     Result := 0;
     if (Length(sRow) > 0) then
        for iCount := 1 to Length(sRow) do
            if (sRow[iCount] = sDelimiter) then
               Inc(Result);
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

function THotspotsAnalysisForm.AnalyseHotspotsListOfBaseDirs(const iNumberOfFeatures : integer;
                                                             const sInfoTable, sScenarioName : string) : string;
var
   sBaseDir,
   sScenario, sLogDir : string;
   //ScenarioChild,
   FeatureReportChild,
   InfoChild,
   OutputChild : TMDIChild;
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
             iChildId := SCPForm.rtnTableId(sInfoTable);
             if (iChildId <> -1) then
             begin
                  InfoChild := TMDIChild(SCPForm.MDIChildren[iChildId]);
                  fInfoChild := True;
                  LoadInfoChildData(InfoChild,iNumberOfFeatures);
             end;
        end;

        // create output child with the required dimensions and populate it
        SCPForm.CreateMDIChild('hotspots_analysis',False,False);
        OutputChild := SCPForm.rtnChild('hotspots_analysis');
        // 1 feature name column + 1 feature target column
        OutputChild.aGrid.ColCount := 2;
        OutputChild.aGrid.RowCount := iNumberOfFeatures + 2;
        OutputChild.SpinCol.Value := OutputChild.aGrid.ColCount;
        OutputChild.SpinRow.Value := OutputChild.aGrid.RowCount;
        OutputChild.lblDimensions.Caption := 'Rows : ' + IntToStr(OutputChild.aGrid.RowCount) + ' Columns : ' + IntToStr(OutputChild.aGrid.ColCount);
        // 1 header row for analysis identifier +
        // 1 header row for value identifier +
        // iNumberOfFeatures rows, one for each feature
        OutputChild.SpinCol.Value := OutputChild.aGrid.ColCount;
        OutputChild.SpinRow.Value := OutputChild.aGrid.RowCount;
        OutputChild.aGrid.Cells[0,0] := 'scenario ->';
        OutputChild.aGrid.Cells[0,1] := 'feature name';
        OutputChild.aGrid.Cells[1,1] := 'feature target';

        // write feature name to first column, copying from feature report
        // Write feature rInitialTrimmedTarget to column 2, copying from feature report.
        // This means we must move all the other columns to the right by 1 column.
        // It also means we must real all the other column from the right by 1 column later when we parse them.
        iFeatureReportChildId := SCPForm.rtnTableId(sInfoTable);
        if (iFeatureReportChildId <> -1) then
        begin
             FeatureReportChild := TMDIChild(SCPForm.MDIChildren[iFeatureReportChildId]);
             for iCount := 1 to OutputChild.aGrid.RowCount do
             begin
                  OutputChild.aGrid.Cells[0,iCount+1] := FeatureReportChild.aGrid.Cells[0,iCount];
                  OutputChild.aGrid.Cells[1,iCount+1] := FeatureReportChild.aGrid.Cells[7,iCount];
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

        // now we must query the user with the End Point (iLastCycle)
        //QryEndPointForm := TQryEndPointForm.Create(Application);
        //QryEndPointForm.EditEndPoint.Text := IntToStr(iLastCycle);
        //fContinue := (mrOk = QryEndPointForm.ShowModal);
        //try
        //   iLastCycle := StrToInt(QryEndPointForm.EditEndPoint.Text);
        //except
        //end;
        //QryEndPointForm.Free;
        iLastCycle := 1;
        fContinue := True;

        UpdateLog(sLogDir,'');
        UpdateLog(sLogDir,'');
        UpdateLog(sLogDir,'start parse');

        iOutputColumn := 2;

        // analyse this cycle for each of the runs
        if fContinue then
           //for iScenario := 1 to (ScenarioChild.aGrid.RowCount-1) do
           begin
                //sBaseDir := ScenarioChild.aGrid.Cells[0,iScenario];
                //lblScenario.Caption := 'parse ' + IntToStr(iScenario) + ' of ' + IntToStr(ScenarioChild.aGrid.RowCount);
                //lblScenario.Update;

                // add 3 extra columns to store the results for this this scenario
                OutputChild.aGrid.ColCount := OutputChild.aGrid.ColCount + 3;
                OutputChild.aGrid.Cells[OutputChild.aGrid.ColCount-1,0] := '_';
                OutputChild.aGrid.Cells[OutputChild.aGrid.ColCount-2,0] := '_';
                OutputChild.aGrid.Cells[OutputChild.aGrid.ColCount-3,0] := '_';
                sScenario := sBaseDir;
                // write scenario name to output table
                OutputChild.aGrid.Cells[iOutputColumn,0] := TrimScenarioName(sScenario);
                UpdateLog(sLogDir,'parse scenario ' + sScenario + ' found');
                Destroy_ExtractCycle(sBaseDir,sLogDir,sScenario,iLastCycle,
                                     iOutputColumn,OutputChild,
                                     InfoChild,fInfoChild);
                OutputChild.SpinCol.Value := OutputChild.aGrid.ColCount;
                OutputChild.SpinRow.Value := OutputChild.aGrid.RowCount;
                OutputChild.lblDimensions.Caption := 'Rows : ' + IntToStr(OutputChild.aGrid.RowCount) + ' Columns : ' + IntToStr(OutputChild.aGrid.ColCount);
                Inc(iOutputColumn,3);
           end;

        UpdateLog(sLogDir,'end parse');

        EndAnalysis(sLogDir);

        //lblScenario.Caption := '';
        //lblScenario.Update;

        if fInfoChild then
        begin
             ExtantArea.Destroy;
             OrigAvTgt.Destroy;
        end;

        // load the temporary files we have created
        //SCPForm.CreateMDIChild(sLogDir + '\LastCycleNumber.csv',True,False);
        //SCPForm.CreateMDIChild(sLogDir + '\analysis_log.csv',True,False);
        //SCPForm.CreateMDIChild(sLogDir + '\calculate_log.csv',True,False);
        // save the OutputChild to a file
        OutputChild.Caption := sLogDir + '\hotspots_destruction_analysis.csv';
        if fileexists(OutputChild.Caption) then
           deletefile(OutputChild.Caption);
        SCPForm.SaveTable(SCPForm.rtnTableID(OutputChild.Caption));
        //OutputChild.Close;

        Result := OutputChild.Caption;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in AnalyseHotspotsListOfBaseDirs',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure THotspotsAnalysisForm.AnalyseHotspotsYear(const sBaseDir : string;
                                                    const iNumberOfFeatures : integer;
                                                    const sInfoTable : string;
                                                    const iYear : integer);
var
   Destruction, Complementarity : array [1..2] of string[2];
   Vulnerability : array [1..4] of string[3];
   Variable : array [1..8] of string[4];
   sScenario, sLogDir : string;
   InfoChild,
   OutputChild : TMDIChild;
   iOutputColumn, iCount, iScenario, iChildId,
   iDestruction, iComplementarity, iVulnerability, iVariable, iCycle, iLastCycle : integer;
   fInfoChild, fContinue,
   fAnalyse : boolean;
begin
     //
end;

end.
