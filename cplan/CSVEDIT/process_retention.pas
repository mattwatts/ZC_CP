unit process_retention;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TProcessRetentionForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ComboBaseDirectorys: TComboBox;
    Label5: TLabel;
    CheckJoinRegions: TCheckBox;
    Label1: TLabel;
    ComboMasterFeatureReport: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    function ExtractRetention(const iScenarioFeatureCount : integer;
                              const sFeatureReport, sHotspotsReport : string;
                              var sRetentionLine : string;
                              const sBaseDirectory : string) : extended;
    procedure CheckJoinRegionsClick(Sender: TObject);
    procedure ProcessJoinRegions;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ProcessRetentionForm: TProcessRetentionForm;

implementation

uses MAIN, Childwin, hotspots_accumulation, ds, autofit, math;

{$R *.DFM}

procedure TProcessRetentionForm.FormCreate(Sender: TObject);
var
   iCount : integer;
begin
     with SCPForm do
          if (MDIChildCount > 0) then
          begin
               for iCount := 0 to (MDIChildCount-1) do
               begin
                    ComboBaseDirectorys.Items.Add(MDIChildren[iCount].Caption);
                    ComboMasterFeatureReport.Items.Add(MDIChildren[iCount].Caption);
               end;
          end;
end;

function TProcessRetentionForm.ExtractRetention(const iScenarioFeatureCount : integer;
                                                const sFeatureReport, sHotspotsReport : string;
                                                var sRetentionLine : string;
                                                const sBaseDirectory : string) : extended;
var
   OutFile : TextFile;
   HotspotsChild, ReportChild : TMDIChild;
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

        HotspotsChild := TMDIChild(SCPForm.rtnChild(sHotspotsReport));
        SCPForm.CreateMDIChild(sFeatureReport,True,False);
        ReportChild := TMDIChild(SCPForm.rtnChild(sFeatureReport));

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
     end;
end;

procedure TProcessRetentionForm.BitBtn1Click(Sender: TObject);
var
   sTmpFile, sBaseDirectory, sFeatureReport, sRetentionLine, sOutputDirectory, sOutputName, sExt : string;
   iCount, iScenarioFeatureCount : integer;
   rAreaCompromised : extended;
   ScenarioChild : TMDIChild;
   AreaCompromisedFile, RetentionFile : TextFile;
begin
     if CheckJoinRegions.Checked then
        ProcessJoinRegions
     else
         // For each base diretory in the list, extract base directory, feature number & report name
         // which are 1-based columns 1, 2 & 3 respectively.
         if (ComboBaseDirectorys.Text <> '') then
         begin
              Screen.Cursor := crHourglass;

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

              ScenarioChild := SCPForm.rtnChild(ComboBaseDirectorys.Text);
              for iCount := 1 to (ScenarioChild.aGrid.RowCount-1) do
              begin
                   sBaseDirectory := ScenarioChild.aGrid.Cells[0,iCount];

                   if fileexists(sBaseDirectory + '\minset_end.txt')
                   and fileexists(sBaseDirectory + '\Retention_.csv') then
                   begin
                        iScenarioFeatureCount := StrToInt(ScenarioChild.aGrid.Cells[1,iCount]);
                        sFeatureReport := ScenarioChild.aGrid.Cells[2,iCount];

                        try
                           sTmpFile := HotspotsAnalysisForm.AnalyseHotspotsListOfBaseDirs(iScenarioFeatureCount,sFeatureReport,sBaseDirectory);

                           rAreaCompromised := ExtractRetention(iScenarioFeatureCount,sFeatureReport,sTmpFile,sRetentionLine,sBaseDirectory);

                        except
                              Screen.Cursor := crDefault;
                              MessageDlg('Exception while analysing hotspots',mtError,[mbOk],0);
                        end;
                   end
                   else
                   begin
                        rAreaCompromised := -1;
                        sRetentionLine := 'scenario not present';
                   end;

                   writeln(AreaCompromisedFile,sBaseDirectory + ',' + FloatToStr(rAreaCompromised));
                   writeln(RetentionFile,sBaseDirectory + ',' + sRetentionLine);
              end;

              closefile(AreaCompromisedFile);
              closefile(RetentionFile);

              Screen.Cursor := crDefault;
         end;
end;

procedure TProcessRetentionForm.CheckJoinRegionsClick(Sender: TObject);
begin
     Label1.Enabled := CheckJoinRegions.Checked;
     ComboMasterFeatureReport.Enabled := CheckJoinRegions.Checked;
end;

procedure TProcessRetentionForm.ProcessJoinRegions;
var
   JoinChild, JoinChildSummary, JoinChildSummary2, MasterFeatureChild, ScenarioChild, DestroyedChild, FeatureChild : TMDIChild;
   iCount, iScenarioFeatureCount, iCountFeatures, iOutputRow : integer;
   sBaseDirectory, sFeatureReport, sFeatureName, sDestroyedArea, sLogDir : string;
   rRemainingTotal, rDestroyedFeatureArea, rAreaCompromised, rRetention, rTarget,
   rTotalAreaCompromised, rMinRetention, rMaxRetention,
   rMean, rStdDev, rFifthPercentile, rTenthPercentile: extended;
   DestroyedFeatureArea : Array_t;
   //RetentionArray : Variant;
begin
     try
        Screen.Cursor := crHourglass;
        // scenario/AreaDestroyed_.csv contains area destroyed vector
        // feature report contains feature key,

        // Create a new blank spreadsheet.  Put feature name, feature target, total area from master feature report into it.
        // for each scenario, add area destroyed vector to this table using feature name from feature report as key

        // get handle on master feature report
        MasterFeatureChild := TMDIChild(SCPForm.rtnChild(ComboMasterFeatureReport.Text));

        // create new output grid and initialise it ready to be populated
        SCPForm.CreateMDIChild('join_regions',False,False);
        JoinChild := SCPForm.rtnChild('join_regions');
        JoinChild.aGrid.ColCount := 3;
        JoinChild.aGrid.RowCount := MasterFeatureChild.aGrid.RowCount;
        JoinChild.SpinCol.Value := JoinChild.aGrid.ColCount;
        JoinChild.SpinRow.Value := JoinChild.aGrid.RowCount;
        JoinChild.lblDimensions.Caption := 'Rows : ' + IntToStr(JoinChild.aGrid.RowCount) + ' Columns : ' + IntToStr(JoinChild.aGrid.ColCount);
        JoinChild.aGrid.Cells[0,0] := 'feature name';
        JoinChild.aGrid.Cells[1,0] := 'target';
        JoinChild.aGrid.Cells[2,0] := 'total area';

        // create DestroyedFeatureArea
        DestroyedFeatureArea := Array_t.Create;
        DestroyedFeatureArea.init(SizeOf(extended),(MasterFeatureChild.aGrid.RowCount - 1));
        rDestroyedFeatureArea := 0;
        for iCountFeatures := 1 to (MasterFeatureChild.aGrid.RowCount - 1) do
            DestroyedFeatureArea.setValue(iCountFeatures,@rDestroyedFeatureArea);

        // populate output grid with info from master feature report
        for iCount := 1 to (MasterFeatureChild.aGrid.RowCount - 1) do
        begin
             // feature name
             JoinChild.aGrid.Cells[0,iCount] := MasterFeatureChild.aGrid.Cells[0,iCount];
             // feature target
             JoinChild.aGrid.Cells[1,iCount] := MasterFeatureChild.aGrid.Cells[6,iCount];
             // total area
             JoinChild.aGrid.Cells[2,iCount] := MasterFeatureChild.aGrid.Cells[5,iCount];
        end;

        // traverse through the input tables, adding the destroyed area from each one to our output grid
        ScenarioChild := SCPForm.rtnChild(ComboBaseDirectorys.Text);
        for iCount := 1 to (ScenarioChild.aGrid.RowCount-1) do
        begin
             sBaseDirectory := ScenarioChild.aGrid.Cells[0,iCount];
             iScenarioFeatureCount := StrToInt(ScenarioChild.aGrid.Cells[1,iCount]);
             sFeatureReport := ScenarioChild.aGrid.Cells[2,iCount];

             // add 1 extra output column to the output grid
             JoinChild.aGrid.ColCount := JoinChild.aGrid.ColCount + 1;
             JoinChild.SpinCol.Value := JoinChild.aGrid.ColCount;
             JoinChild.lblDimensions.Caption := 'Rows : ' + IntToStr(JoinChild.aGrid.RowCount) + ' Columns : ' + IntToStr(JoinChild.aGrid.ColCount);
             JoinChild.aGrid.Cells[JoinChild.aGrid.ColCount-1,0] := sBaseDirectory;

             // initialise destination row
             iOutputRow := 1;

             if fileexists(sBaseDirectory + '\minset_end.txt')
             and fileexists(sBaseDirectory + '\Retention_.csv') then
             begin

                  // get a handle on the 'AreaDestroyed_.csv' report for this scenario
                  SCPForm.CreateMDIChild(sBaseDirectory + '\total_destruct_area.csv',True,False);
                  DestroyedChild := TMDIChild(SCPForm.rtnChild(sBaseDirectory + '\total_destruct_area.csv'));

                  SCPForm.CreateMDIChild(sFeatureReport,True,False);
                  FeatureChild := TMDIChild(SCPForm.rtnChild(sFeatureReport));

                  // Traverse through the feature names in FeatureChild and the destroyed amounts in DestroyedChild.
                  // Use the feature name to decide which row in JoinChild to insert the destroyed area
                  for iCountFeatures := 1 to (FeatureChild.aGrid.RowCount-1) do
                  begin
                       sFeatureName := FeatureChild.aGrid.Cells[0,iCountFeatures];
                       sDestroyedArea := DestroyedChild.aGrid.Cells[iCountFeatures,1];

                       // seek to the correct output row in JoinChild
                       while sFeatureName <> JoinChild.aGrid.Cells[0,iOutputRow] do
                             Inc(iOutputRow);

                       // update DestroyedFeatureArea
                       DestroyedFeatureArea.rtnValue(iOutputRow,@rDestroyedFeatureArea);
                       rDestroyedFeatureArea := rDestroyedFeatureArea + StrToFloat(sDestroyedArea);
                       DestroyedFeatureArea.setValue(iOutputRow,@rDestroyedFeatureArea);

                       JoinChild.aGrid.Cells[JoinChild.aGrid.ColCount-1,iOutputRow] := sDestroyedArea;
                  end;

                  DestroyedChild.Free;
                  FeatureChild.Free;
             end
             else
             begin
                  JoinChild.aGrid.Cells[JoinChild.aGrid.ColCount-1,1] := 'scenario not present';
             end;
        end;

        // create new retention summary output grid and initialise it ready to be populated
        SCPForm.CreateMDIChild('join_regions_retention',False,False);
        JoinChildSummary := SCPForm.rtnChild('join_regions_retention');
        JoinChildSummary.aGrid.ColCount := 3;
        JoinChildSummary.aGrid.RowCount := JoinChild.aGrid.RowCount;
        JoinChildSummary.SpinCol.Value := JoinChildSummary.aGrid.ColCount;
        JoinChildSummary.SpinRow.Value := JoinChildSummary.aGrid.RowCount;
        JoinChildSummary.lblDimensions.Caption := 'Rows : ' + IntToStr(JoinChildSummary.aGrid.RowCount) + ' Columns : ' + IntToStr(JoinChildSummary.aGrid.ColCount);
        JoinChildSummary.aGrid.Cells[0,0] := 'feature name';
        JoinChildSummary.aGrid.Cells[1,0] := 'area compromised';
        JoinChildSummary.aGrid.Cells[2,0] := 'retention';
        // create new summary output grid and initialise it ready to be populated
        SCPForm.CreateMDIChild('join_regions_summary',False,False);
        JoinChildSummary2 := SCPForm.rtnChild('join_regions_summary');
        JoinChildSummary2.aGrid.ColCount := 2;
        JoinChildSummary2.aGrid.RowCount := 5;
        JoinChildSummary2.SpinCol.Value := JoinChildSummary2.aGrid.ColCount;
        JoinChildSummary2.SpinRow.Value := JoinChildSummary2.aGrid.RowCount;
        JoinChildSummary2.lblDimensions.Caption := 'Rows : ' + IntToStr(JoinChildSummary2.aGrid.RowCount) + ' Columns : ' + IntToStr(JoinChildSummary2.aGrid.ColCount);
        JoinChildSummary2.aGrid.Cells[0,0] := 'minimum retention';
        JoinChildSummary2.aGrid.Cells[0,1] := 'maximum retention';
        JoinChildSummary2.aGrid.Cells[0,2] := '5th percentile retention';
        JoinChildSummary2.aGrid.Cells[0,3] := '10th percentile retention';
        JoinChildSummary2.aGrid.Cells[0,4] := 'total area compromised';
        JoinChildSummary2.CheckLockFirstRow.Checked := False;
        JoinChildSummary2.CheckLockFirstColumn.Checked := False;

        // add columns for "total destroyed", "remaining total", "area compromised" & "retention"
        JoinChild.aGrid.ColCount := JoinChild.aGrid.ColCount + 4;
        JoinChild.SpinCol.Value := JoinChild.aGrid.ColCount;
        JoinChild.lblDimensions.Caption := 'Rows : ' + IntToStr(JoinChild.aGrid.RowCount) + ' Columns : ' + IntToStr(JoinChild.aGrid.ColCount);
        JoinChild.aGrid.Cells[JoinChild.aGrid.ColCount-4,0] := 'total destroyed';
        JoinChild.aGrid.Cells[JoinChild.aGrid.ColCount-3,0] := 'total remaining';
        JoinChild.aGrid.Cells[JoinChild.aGrid.ColCount-2,0] := 'area compromised';
        JoinChild.aGrid.Cells[JoinChild.aGrid.ColCount-1,0] := 'retention';
        rTotalAreaCompromised := 0;
        rMinRetention := 10000;
        rMaxRetention := 0;
        // create the retention array
        //RetentionArray := VarArrayCreate([0,MasterFeatureChild.aGrid.RowCount-2],varDouble);
        for iCountFeatures := 1 to (MasterFeatureChild.aGrid.RowCount - 1) do
        begin
             DestroyedFeatureArea.rtnValue(iCountFeatures,@rDestroyedFeatureArea);

             rRemainingTotal := StrToFloat(JoinChild.aGrid.Cells[2,iCountFeatures]) - rDestroyedFeatureArea;
             rTarget := StrToFloat(JoinChild.aGrid.Cells[1,iCountFeatures]);

             if (rTarget > 0) then
             begin
                  rAreaCompromised := rTarget - rRemainingTotal;
                  if (rAreaCompromised < 0) then
                     rAreaCompromised := 0;

                  rRetention := 100 * rRemainingTotal / rTarget
             end
             else
             begin
                  rAreaCompromised := 0;
                  rRetention := 0;
             end;

             //RetentionArray[iCountFeatures-1] := rRetention;

             rTotalAreaCompromised := rTotalAreaCompromised + rAreaCompromised;
             if (rRetention < rMinRetention) then
                rMinRetention := rRetention;
             if (rRetention > rMaxRetention) then
                rMaxRetention := rRetention;

             JoinChild.aGrid.Cells[JoinChild.aGrid.ColCount-4,iCountFeatures] := FloatToStr(rDestroyedFeatureArea);
             JoinChild.aGrid.Cells[JoinChild.aGrid.ColCount-3,iCountFeatures] := FloatToStr(rRemainingTotal);
             JoinChild.aGrid.Cells[JoinChild.aGrid.ColCount-2,iCountFeatures] := FloatToStr(rAreaCompromised);
             JoinChild.aGrid.Cells[JoinChild.aGrid.ColCount-1,iCountFeatures] := FloatToStr(rRetention);
             JoinChildSummary.aGrid.Cells[0,iCountFeatures] := JoinChild.aGrid.Cells[0,iCountFeatures];
             JoinChildSummary.aGrid.Cells[1,iCountFeatures] := FloatToStr(rAreaCompromised);
             JoinChildSummary.aGrid.Cells[2,iCountFeatures] := FloatToStr(rRetention);
        end;

        //MeanAndStdDev(RetentionArray,rMean,rStdDev);
        rFifthPercentile := 0;//rMean - (1.64 * rStdDev);
        rTenthPercentile := 0;//rMean - (1.28 * rStdDev);

        JoinChildSummary2.aGrid.Cells[1,0] := FloatToStr(rMinRetention);
        JoinChildSummary2.aGrid.Cells[1,1] := FloatToStr(rMaxRetention);
        JoinChildSummary2.aGrid.Cells[1,2] := FloatToStr(rFifthPercentile);
        JoinChildSummary2.aGrid.Cells[1,3] := FloatToStr(rTenthPercentile);
        JoinChildSummary2.aGrid.Cells[1,4] := FloatToStr(rTotalAreaCompromised);
        // auto fit this table
        AutoFitForm := TAutoFitForm.Create(Application);
        AutoFitForm.sTable := JoinChildSummary2.Caption;
        AutoFitForm.AutoFitTable;
        AutoFitForm.Free;

        // save the JoinChild table to a file
        sLogDir := ExtractFilePath(ComboBaseDirectorys.Text);
        JoinChild.Caption := sLogDir + JoinChild.Caption + '.csv';
        if fileexists(JoinChild.Caption) then
           deletefile(JoinChild.Caption);
        SCPForm.SaveTable(SCPForm.rtnTableID(JoinChild.Caption));
        // save JoinChildSummary
        JoinChildSummary.Caption := sLogDir + JoinChildSummary.Caption + '.csv';
        if fileexists(JoinChildSummary.Caption) then
           deletefile(JoinChildSummary.Caption);
        SCPForm.SaveTable(SCPForm.rtnTableID(JoinChildSummary.Caption));
        // save JoinChildSummary2
        JoinChildSummary2.Caption := sLogDir + JoinChildSummary2.Caption + '.csv';
        if fileexists(JoinChildSummary2.Caption) then
           deletefile(JoinChildSummary2.Caption);
        SCPForm.SaveTable(SCPForm.rtnTableID(JoinChildSummary2.Caption));

        DestroyedFeatureArea.Destroy;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ProcessJoinRegions dir : ' + sBaseDirectory + ' feature : ' + sFeatureName,mtError,[mbOk],0);
     end;
end;

end.
