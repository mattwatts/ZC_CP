unit mthread;

{$UNDEF DEBUG_DESTRUCTION}

interface

uses
    ds, Classes;

type
  {declaration of TMinsetThread}
  TMinsetThread = class(TThread)
  protected
    procedure Execute; override;
  end;

var
   MinsetThread : TMinsetThread;
   iChoiceLogLength : integer;
   fStopExecutingMinset : boolean;

   sWhatStoppedMinset,
   sIteration,
   sSuspendInputFile, sSuspendOutputFile, sSuspendSyncFile : string;
   iReportMem,
   iSuspendRule, iSuspendIterationCount : integer;
   SuspendSitesChosen : Array_t;
   rTotalVegetatedArea : extended;
   fValidateIteration,
   fNoComplementarityAreaRule, fNoComplementarityPresenceRule : boolean;
   RegionField, RegionResRate, RegionName, RegionResYear, RegionSitesChosen, RegionPriority : Array_t;
   iRegionCount, iCurrentRegion,
   iEvaluateReAllocTableCount,
   iCountRegionSitesChosenCount,
   iUpdateReAllocTableCount,
   iMaskSitesChosenCount,
   iCountTotalAllocationCount,
   iCountRegionsWithAllocationCount,
   iReAllocateScenario12Count,
   iFindNextRegionCount,
   iReAllocateScenario3Count,
   iReAllocateScenario4Count : integer;
   fDebugReAlloc : boolean;
   rVulnerabilityWeighting : extended;

procedure ExecuteMinset(const fRestore, fExtraDebug, fUser : boolean);
procedure SetNoComplementarityTargets;
procedure UnSetNoComplementarityTargets;
procedure InitMemoryReportFile;
procedure AddMemoryReportRow(const sJob : string);
procedure AppendDebugLog(const sLine : string);

var
   rTotalAreaDestroyed, rAreaSinceDestruction : extended;
   
implementation

uses
    global, rules, control,
    minset, dll_u1, minstop,
    forms, controls, dialogs, sysutils,
    choices, sql_unit, sf_irrep,
    Toolmisc, msetinf,
    filectrl, reports, msetexpt,
    destruct, validate,
    RedundancyCheck, options,
    hotspots_nocomplementarity_areaindices,
    FirstSiteReport,
    getuservalidatefile,
    override_combsize;


procedure InitMemoryReportFile;
var
   MemoryReport : TextFile;
begin
     if ControlRes^.fReportMinsetMemSize then
     begin
          assignfile(MemoryReport,ControlRes^.sWorkingDirectory + '\memsize.csv');
          rewrite(MemoryReport);
          writeln(MemoryReport,'iteration,job,memsize,diff');
          closefile(MemoryReport);
     end;
end;

procedure AddMemoryReportRow(const sJob : string);
var
   MemoryReport : TextFile;
   iAllocMemSize : integer;
begin
     if ControlRes^.fReportMinsetMemSize then
     begin
          if not fileexists(ControlRes^.sWorkingDirectory + '\memsize.csv') then
             InitMemoryReportFile;

          assignfile(MemoryReport,ControlRes^.sWorkingDirectory + '\memsize.csv');
          append(MemoryReport);
          iAllocMemSize := AllocMemSize;
          writeln(MemoryReport,IntToStr(iMinsetIterationCount) + ',' +
                               sJob + ',' +
                               IntToStr(iAllocMemSize) + ',' +
                               IntToStr(iAllocMemSize - iReportMem));
          iReportMem := iAllocMemSize;
          closefile(MemoryReport);
     end;
end;

procedure SetNoComplementarityTargets;
var
   iCount : integer;
   rValue : extended;
   pFeat : featureoccurrencepointer;
begin
     // Store the target area and replace it with the 'no complementarity' target.
     // NOTE : The 'no complementarity' target is the original available target with
     //        destruction taken into account but no deferrals taken into account.
     //        ie. This is equivalent to 'trimmed target'
     new(pFeat);

     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,pFeat);
          rValue := pFeat^.targetarea;
          StoreComplementarityTarget.setValue(iCount,@rValue);
          pFeat^.targetarea := pFeat^.rTrimmedTarget;
          FeatArr.setValue(iCount,pFeat);
     end;

     dispose(pFeat);
end;

procedure UnSetNoComplementarityTargets;
var
   iCount : integer;
   rValue : extended;
   pFeat : featureoccurrencepointer;
begin
     // Restore the target area.
     new(pFeat);

     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,pFeat);
          StoreComplementarityTarget.rtnValue(iCount,@rValue);
          pFeat^.targetarea := rValue;
          FeatArr.setValue(iCount,pFeat);
     end;

     dispose(pFeat);
end;

procedure TMinsetThread.Execute;
begin
end;

procedure DebugCyclicReports(const iIteration : integer;
                             SitesChosen, ValuesChosen : Array_t);
var
   sReportDirectory, sValue : string;
   OutFile : TextFile;
   iSiteKey, iCount : integer;
   rValue : extended;
   fValidateIteration : boolean;
begin
     // generate debug reports for a iteration
     try
        GenerateIterationReports;

        // determine if we need to validate this iteration
        fValidateIteration := True;
        if fValidateIterationsCreated then
        begin
             if (ControlRes^.iSelectIterationCount < 1) then
                fValidateIteration := True
             else
             begin
                  if (ControlRes^.iSelectIterationCount <= ValidateIterations.lMaxSize) then
                     ValidateIterations.rtnValue(ControlRes^.iSelectIterationCount,@fValidateIteration)
                  else
                      fValidateIteration := False;
             end;
        end;
        sReportDirectory := ControlRes^.sWorkingDirectory;
        // report hotspots feature report
        if MinsetExpertForm.CheckHotspotsFeatures.Checked then
        begin
             ForceDirectories(sReportDirectory);
             ReportHotspotsFeatures(sReportDirectory + '\hotspots_feature' + IntToStr(iIteration) + '.csv');
        end;

        if fValidateIteration then
        begin
             // now generate minset reports
             if MinsetExpertForm.CheckExtraDetail.Checked then
             begin
                  ForceDirectories(sReportDirectory);

                  // report sites chosen
                  assignfile(OutFile,sReportDirectory + '\sites_chosen' + IntToStr(iIteration) + '.csv');
                  rewrite(OutFile);
                  writeln(OutFile,'Site Key,Site Value');
                  for iCount := 1 to SitesChosen.lMaxSize do
                  begin
                       SitesChosen.rtnValue(iCount,@iSiteKey);
                       try
                          ValuesChosen.rtnValue(iCount,@rValue);
                          sValue := FloatToStr(rValue);
                       except
                             sValue := 'unknown';
                       end;
                       writeln(OutFile,IntToStr(iSiteKey) + ',' + sValue);
                  end;
                  closefile(OutFile);
             end;

             // report proposed reserve
             if MinsetExpertForm.CheckProposedReserve.Checked then
             begin
                  ForceDirectories(sReportDirectory);
                  ReportProposedReserve(sReportDirectory + '\proposed_reserve' + IntToStr(iIteration) + '.csv');
             end;

             // report features
             if MinsetExpertForm.CheckDebugFeatures.Checked then
             begin
                  ForceDirectories(sReportDirectory);
                  ReportFeatures(sReportDirectory + '\features' + IntToStr(iIteration) + '.csv',
                                 'REPORT Features iteration ' + IntToStr(iIteration),
                                 FALSE,
                                 ControlForm.UseFeatCutOffs.Checked,
                                 FeatArr, iFeatureCount, rPercentage,
                                 '');
             end;

             // report sites
             if MinsetExpertForm.CheckDebugSites.Checked then
             begin
                  ForceDirectories(sReportDirectory);
                  ReportSites(sReportDirectory + '\sites' + IntToStr(iIteration) + '.csv',
                              'REPORT Sites iteration ' + IntToStr(iIteration),
                              FALSE ,
                              ControlForm.OutTable,
                              iSiteCount,
                              SiteArr,
                              ControlRes,
                              '');
             end;

             if ControlRes^.fValidateMinset then
             begin
                  ReportSiteSumirr(sReportDirectory + '\sites_sumirr' + IntToStr(iIteration) + '.csv');

                  ReportAverageAvailableFeatureArea(sReportDirectory + '\average_feature_area' + IntToStr(iIteration) + '.csv');
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DebugCyclicReports iteration ' + IntToStr(iIteration),
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure InitRuleHistory;
var
   OutFile : TextFile;
begin
     assignfile(OutFile,ControlRes^.sWorkingDirectory + '\RuleHistory.csv');
     rewrite(OutFile);
     writeln(OutFile,'iteration,rule,sites selected');
     closefile(OutFile);
end;

procedure UpdateRuleHistory(const iIteration, iRule, iSitesChosen : integer);
var
   OutFile : TextFile;
begin
     assignfile(OutFile,ControlRes^.sWorkingDirectory + '\RuleHistory.csv');
     append(OutFile);
     writeln(OutFile,IntToStr(iIteration) + ',' + IntToStr(iRule) + ',' + IntToStr(iSitesChosen));
     closefile(OutFile);
end;

procedure LoadRegionField;
var
   sRegionName : str255;
   iCount : integer;
begin
     ControlForm.OutTable.Open;

     for iCount := 1 to iSiteCount do
     begin
          sRegionName := ControlForm.OutTable.FieldByName(MinsetExpertForm.ComboRegionField.Text).AsString;
          RegionField.setValue(iCount,@sRegionName);
          ControlForm.OutTable.Next;
     end;

     ControlForm.OutTable.Close;
end;

procedure LoadRegionResRate;
var
   InFile : TextFile;
   iCount : integer;
   sLine : string;
   sRegionName : str255;
   rRegionResRate, rRegionPriority : extended;
begin
     assignfile(InFile,MinsetExpertForm.EditRegionResRateTable.Text);
     reset(InFile);
     readln(InFile);
     iRegionCount := 0;
     repeat // count the number of regions in the file

           readln(InFile);
           Inc(iRegionCount);

     until Eof(InFile);
     closefile(InFile);

     // init the arrays
     RegionName := Array_t.Create;
     RegionName.init(SizeOf(str255),iRegionCount);
     RegionResRate := Array_t.Create;
     RegionResRate.init(SizeOf(extended),iRegionCount);
     RegionPriority := Array_t.Create;
     RegionPriority.init(SizeOf(extended),iRegionCount);

     reset(InFile);
     readln(InFile);
     iCount := 0;
     repeat // load the region names and reservation rates from the file

           Inc(iCount);
           readln(InFile,sLine);

           sRegionName := GetDelimitedAsciiElement(sLine,',',1);
           rRegionResRate := StrToFloat(GetDelimitedAsciiElement(sLine,',',2));
           rRegionPriority := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));

           RegionName.setValue(iCount,@sRegionName);
           RegionResRate.setValue(iCount,@rRegionResRate);
           RegionPriority.setValue(iCount,@rRegionPriority);

     until Eof(InFile);
     closefile(InFile);
end;

procedure InitRegionResYearSitesChosen;
var
   iCount, iAmount : integer;
   rAmount : extended;
begin
     RegionResYear := Array_t.Create;
     RegionResYear.init(SizeOf(extended),iRegionCount);
     RegionSitesChosen := Array_t.Create;
     RegionSitesChosen.init(SizeOf(integer),iRegionCount);
     rAmount := 0;
     iAmount := 0;
     for iCount := 1 to iRegionCount do
     begin
          RegionResYear.setValue(iCount,@rAmount);
          RegionSitesChosen.setValue(iCount,@iAmount);
     end;
end;

procedure InitRegionResRealloc;
begin
     // create and load RegionField (has a value for each site)
     RegionField := Array_t.Create;
     RegionField.init(SizeOf(str255),iSiteCount);
     LoadRegionField;

     // create and load RegionName and RegionResRate (has a value for each region)
     LoadRegionResRate;

     // create and init RegionResYear and RegionSitesChosen
     InitRegionResYearSitesChosen;
end;

procedure FreeRegionResRealloc;
begin
     RegionField.Destroy;
     RegionName.Destroy;
     RegionResRate.Destroy;
     RegionResYear.Destroy;
     RegionSitesChosen.Destroy;
     RegionPriority.Destroy;
end;

procedure InitDebugLog;
var
   DebugFile : TextFile;
begin
     assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\debuglog.txt');
     rewrite(DebugFile);
     writeln(DebugFile,'begin');
     closefile(DebugFile);
end;

procedure AppendDebugLog(const sLine : string);
var
   DebugFile : TextFile;
begin
     if MinsetExpertForm.CheckReAllocate.Checked then
     begin
          assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\debuglog.txt');
          append(DebugFile);
          writeln(DebugFile,sLine);
          flush(DebugFile);
          closefile(DebugFile);
     end;
end;

procedure ExecuteMinset(const fRestore, fExtraDebug, fUser : boolean);
{execute the minset}
// when fRestore = False, we are starting a minset run
//               = True, we are restoring a minset run after a call to ArcView Adjacency or Proximity
var
   iTotalSitesSelected, iSitesForCurrentRule,
   iRule, iSitesChosen, iCount, iIterationCount, iRuleUsed, iRuleTmp,
   iSelectionsSinceDestruction, iKey : integer;
   rAreaOfSitesChosen : extended;
   SitesFromSelectionLog,
   ValuesChosen,
   SitesChosen, RulesUsed : Array_t;
   pSite : sitepointer;
   sType, sField, sOperator, sValue, sMessage : string;
   fStop, fApply, fTerminated,
   fSuspendExecution, fUnSuspendExecution,
   fRecalculateComplementarity,
   fComplementarity : boolean;
   RegionLogFile : TextFile;

   procedure SetEditVulnWeight;
   var
      VulnWeightFile : TextFile;
   begin
        if (MinsetExpertForm.CombineVuln.ItemIndex > 0) then
        begin
             rVulnerabilityWeighting := StrToFloat(MinsetExpertForm.EditVulnWeight.Text);

             assignfile(VulnWeightFile,ControlRes^.sWorkingDirectory + '\vulnweight.txt');
             rewrite(VulnWeightFile);
             writeln(VulnWeightFile,'VulnWeight=' + FloatToStr(rVulnerabilityWeighting));
             closefile(VulnWeightFile);
        end;
   end;


   procedure InitMinsetRun;
   var
      iCount : integer;
      rValue : extended;
   begin
        with RulesForm do
        try
           Screen.Cursor := crHourglass;
           fStop := False;
           new(pSite);

           iRedundantSites := 0;
           ControlRes^.fMinsetIsRunning := True;

           {record the length of the selection log so we can rewind it for Lookup, Map and Add to Map}
           iChoiceLogLength := ChoiceForm.ChoiceLog.Items.Count;

           {initialise the Resource array if we are applying a resource limit}
           if MinsetExpertForm.CheckResourceLimit.Checked then
              LoadResourceArray(MinsetExpertForm.ComboResource.Text);

           {initialise record of which rules have been selected}
           try
              RulesUsed := Array_t.Create;
              RulesUsed.init(SizeOf(integer),RuleBox.Items.Count);
           except
                 Screen.Cursor := crDefault;
                 MessageDlg('Exception in RulesUsed.init',mtError,[mbOk],0);
                 Application.Terminate;
                 Exit;
           end;
           iRuleUsed := 0;
           for iCount := 1 to RuleBox.Items.Count do
               RulesUsed.SetValue(iCount,@iRuleUsed);

           {build array of sites that are included in appropriate status}
           try
              SitesChosen := Array_t.Create;
              SitesChosen.init(SizeOf(integer),ARR_STEP_SIZE);
              ValuesChosen := Array_t.Create;
              ValuesChosen.init(SizeOf(extended),ARR_STEP_SIZE);
           except
                 Screen.Cursor := crDefault;
                 MessageDlg('Exception in SitesChosen.init',mtError,[mbOk],0);
                 Application.Terminate;
                 Exit;
           end;
           iIterationCount := 0;
           fTerminated := False;

           iTotalSitesSelected := 0;

           if fExtraDebug then
              ForceDirectories(ControlRes^.sWorkingDirectory + '\1\rule2');
           //LoadSiteDestructStatus(fExtraDebug,ControlRes^.sWorkingDirectory + '\1\rule2');

           if (not MinsetExpertForm.CheckEnableComplementarity.Checked) then
           begin
                // create the 'no complementarity' datastructures
                CacheSelectRule := Array_t.Create;
                CacheSelectRule.init(SizeOf(extended),iSiteCount);
                CacheArithmeticRule := Array_t.Create;
                CacheArithmeticRule.init(SizeOf(extended),iSiteCount);
                CacheVuln := Array_t.Create;
                CacheVuln.init(SizeOf(extended),iSiteCount);
                rValue := 0;

                for iCount := 1 to iSiteCount do
                begin
                     CacheSelectRule.setValue(iCount,@rValue);
                     CacheArithmeticRule.setValue(iCount,@rValue);
                     CacheVuln.setValue(iCount,@rValue);
                end;
           end;

           fRecalculateComplementarity := True;

           if MinsetExpertForm.CheckEnableDestruction.Checked
           and (not MinsetExpertForm.CheckEnableComplementarity.Checked) then
           begin
                StoreComplementarityTarget := Array_t.Create;
                StoreComplementarityTarget.init(SizeOf(extended),iFeatureCount);
                rValue := 0;
                for iCount := 1 to iFeatureCount do
                    StoreComplementarityTarget.setValue(iCount,@rValue);
           end;

           // fComplementarity
           fComplementarity := True;
           if ((not MinsetExpertForm.CheckEnableComplementarity.Checked) and
               MinsetExpertForm.CheckEnableDestruction.Checked) then
              fComplementarity := False;

           {if ControlRes^.fValidateMode
           or (MinsetExpertForm.CheckExtraDetail.Checked) then}
              // write destruction debug files
              DebugCrownStatus;

           {if ControlRes^.fDestructObjectsCreated then
              WriteInitDestroyFile(True);}

           fHotspots_Area_Indices_Created := False;

           fUseHotspotsNoComplValues := False;
           // set fNoComplementarityAreaRule
           if ((RulesForm.RuleBox.Items.Strings[0] = '1. Select SUMIRR Highest')
               or (RulesForm.RuleBox.Items.Strings[0] = '1. Select IRREPL Highest')
               or (RulesForm.RuleBox.Items.Strings[0] = '1. weighted pccontrib')
               or (RulesForm.RuleBox.Items.Strings[0] = '1. weighted target'))
           and (not MinsetExpertForm.CheckEnableComplementarity.Checked) then
               fNoComplementarityAreaRule := True
           else
               fNoComplementarityAreaRule := False;
           // set fNoComplementarityPresenceRule
           if ((RulesForm.RuleBox.Items.Strings[0] = '1. richness')
               or (RulesForm.RuleBox.Items.Strings[0] = '1. feature rarity')
               or (RulesForm.RuleBox.Items.Strings[0] = '1. summed rarity')
               or (RulesForm.RuleBox.Items.Strings[0] = '1. Select SUMIRR Highest')
               or (RulesForm.RuleBox.Items.Strings[0] = '1. Select IRREPL Highest')
               or (RulesForm.RuleBox.Items.Strings[0] = '1. weighted pccontrib')
               or (RulesForm.RuleBox.Items.Strings[0] = '1. weighted target'))
           and (not MinsetExpertForm.CheckEnableComplementarity.Checked) then
               fNoComplementarityPresenceRule := True
           else
               fNoComplementarityPresenceRule := False;

           if fNoComplementarityAreaRule
           or fNoComplementarityPresenceRule then
              if (not MinsetExpertForm.CheckEnableComplementarity.Checked) then
              // no complementarity
                 fUseHotspotsNoComplValues := True;

           // load the starting condition log file here if there is one specified
           if (MinsetExpertForm.RadioStartingCondition.ItemIndex = 1)
           and fileexists(MinsetExpertForm.EditLogFile.Text) then
               LoadLogFile(MinsetExpertForm.EditLogFile.Text,MinsetLoadLog);

           if MinsetExpertForm.RedCheckExclude.Checked then
              InitRedCheckExcludeSites;

           // init the first site report in case there are ties
           if MinsetExpertForm.CheckReportSelectFirstSites.Checked then
              InitFirstSiteReport;

           //ControlRes^.fReportMinsetMemSize := ControlRes^.fShowExtraTools;
           //InitMemoryReportFile;

           SaveItnValidateFile;

           //fDestructionJustRun := False;
           fDestructionJustRun := True;

           sWhatStoppedMinset := '';

           InitRuleHistory;

           if MinsetExpertForm.CheckReAllocate.Checked then
           begin
                InitDebugLog;

                assignfile(RegionLogFile,ControlRes^.sWorkingDirectory + '\RegionLogFile.csv');
                rewrite(RegionLogFile);
                writeln(RegionLogFile,'year,region,site key,reserved/region/year');
                closefile(RegionLogFile);

                InitRegionResRealloc;
           end;
           rAreaOfSitesChosen := 0;
           iCurrentRegion := 0;

           SetEditVulnWeight;

           iEvaluateReAllocTableCount := 0;
           iCountRegionSitesChosenCount := 0;
           iUpdateReAllocTableCount := 0;
           iMaskSitesChosenCount := 0;
           iCountTotalAllocationCount := 0;
           iCountRegionsWithAllocationCount := 0;
           iReAllocateScenario12Count := 0;
           iFindNextRegionCount := 0;
           iReAllocateScenario3Count := 0;
           iReAllocateScenario4Count := 0;
           fDebugReAlloc := True;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in InitMinsetRun',
                         mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;
   end;

   procedure FreeMinsetRun;
   var
      iRule : integer;
      EndFile : TextFile;
   begin
        AppendDebugLog('FreeMinsetRun start');

        with RulesForm do
        try
           ControlRes^.fMinsetIsRunning := False;

           {display History message of rules used}
           assignfile(EndFile,ControlRes^.sWorkingDirectory + '\minset_end.txt');
           rewrite(EndFile);

           if fStopExecutingMinset then
              writeln(EndFile,'Termination caused by : User pressed stop')
           else
               writeln(EndFile,'Termination caused by : ' + sWhatStoppedMinset);

           if fStopExecutingMinset then
              sMessage := 'Termination caused by : User pressed stop' + Chr(13) + Chr(10)
           else
               sMessage := 'Termination caused by : ' + sWhatStoppedMinset + Chr(13) + Chr(10);

           sMessage := sMessage + 'Minset Finished ' + IntToStr(iIterationCount) + ' iterations' +
                       Chr(13)+Chr(10)+Chr(13)+Chr(10) + 'Rule History:' + Chr(13)+Chr(10);

           writeln(EndFile,'Minset Finished ' + IntToStr(iIterationCount) + ' iterations.');
           if (MinsetExpertForm.RedundancySetting.ItemIndex > 0) then
           begin
                writeln(EndFile,'Remaining Selected Sites: ' +
                                IntToStr(ControlForm.R1.Items.Count +
                                         ControlForm.R2.Items.Count +
                                         ControlForm.R3.Items.Count +
                                         ControlForm.R4.Items.Count +
                                         ControlForm.R5.Items.Count));
                writeln(EndFile,'Redundant Sites: ' + IntToStr(iRedundantSites));
           end;

           writeln(EndFile);
           writeln(EndFile,'Date is ' + FormatDateTime('dddd," "mmmm d, yyyy',Now));
           writeln(EndFile,'Time is ' + FormatDateTime('hh:mm AM/PM', Now));

           writeln(EndFile);
           writeln(EndFile,'Rule History:');

           for iRule := 1 to RuleBox.Items.Count do
           begin
                RulesUsed.rtnValue(iRule,@iRuleTmp);
                sMessage := sMessage + IntToStr(iRule) + ' (' + IntToStr(iRuleTmp) + ' times)';

                if (iRule <> RuleBox.Items.Count) then
                   sMessage := sMessage + Chr(13) + Chr(10);

                writeln(EndFile,IntToStr(iRule) + ' (' + IntToStr(iRuleTmp) + ' times)');
           end;

           closefile(EndFile);

           if fUser then
              MessageDlg(sMessage,mtInformation,[mbOk],0);

           {dispose of site selection arrays used during iterations}
           SitesChosen.Destroy;
           ValuesChosen.Destroy;
           RulesUsed.Destroy;

           if MinsetExpertForm.CheckResourceLimit.Checked then
              ResArray.Destroy;

           if (iMinsetFlag = MINSET_LOOKUP)
           or (iMinsetFlag = MINSET_MAP)
           or (iMinsetFlag = MINSET_ADD_TO_MAP) then
           begin
                SitesFromSelectionLog := ChoiceForm.RewindLog(iChoiceLogLength);

                UpdateDatabaseGIS;

                if (SitesFromSelectionLog.lMaxSize > 0) then
                   case iMinsetFlag of
                        MINSET_LOOKUP : LookupSQL(SitesFromSelectionLog.lMaxSize,
                                                  SitesFromSelectionLog);
                        MINSET_MAP :
                        begin
                             //ClearOldSQL;
                             //MapSQL(SitesFromSelectionLog.lMaxSize,
                             //       SitesFromSelectionLog,True);
                             MapSites(SitesFromSelectionLog,FALSE);
                             SitesFromSelectionLog.Destroy;
                        end;
                        MINSET_ADD_TO_MAP :
                        begin
                             //MapSQL(SitesFromSelectionLog.lMaxSize,
                             //       SitesFromSelectionLog,True);
                             MapSites(SitesFromSelectionLog,TRUE);
                             SitesFromSelectionLog.Destroy;
                        end;
                   end;
           end
           else
               UpdateDatabaseGIS;

           Autosave;{autosame EMS selection file to save selections}

           if ControlRes^.fValidateMode then
              ConvertAutosaveLog;

           ModalResult := mrOk;

           //if fExtraDebug then
           //   DestructStatus.Destroy;

           iMinsetIterationCount := -1;

           if (not MinsetExpertForm.CheckEnableComplementarity.Checked) then
           begin
                // create the 'no complementarity' datastructures
                CacheSelectRule.Destroy;
                CacheArithmeticRule.Destroy;
                CacheVuln.Destroy;
           end;

           if (MinsetExpertForm.CheckEnableDestruction.Checked
           and (not MinsetExpertForm.CheckEnableComplementarity.Checked)) then
               StoreComplementarityTarget.Destroy;

           {try
              CrownLandSites.Destroy;
           except
           end;}

           if fHotspots_Area_Indices_Created then
              Hotspots_Area_Indices.Destroy;

           iDestructionYear := -1;

           if MinsetExpertForm.CheckEnableDestruction.Checked
           {and ControlRes^.fGenerateCompRpt} then
               EndDestructReports;

           if MinsetExpertForm.CheckReAllocate.Checked then
              FreeRegionResRealloc;

          if ControlRes^.fDestructObjectsCreated then
             FreeDestroy(FALSE);


        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in FreeMinsetRun',
                         mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;

        AppendDebugLog('FreeMinsetRun end');
   end;

begin
     with RulesForm do
     try
        {execute the minset with the specified parameters}

        fStopExecutingMinset := False;
        fSuspendExecution := False;
        rTotalVegetatedArea := 0;

        ControlRes^.iSimulationYear := 0;

        if fRestore then
        begin
             // we are restoring a previously suspended minset run
             fUnSuspendExecution := True;
             fStop := False;
        end
        else
        begin
             // we are starting a minset run
             fUnSuspendExecution := False;
             iSelectionsSinceDestruction := 0;
             rAreaSinceDestruction := 0;
             rTotalAreaDestroyed := 0;
             MinsetUserForm := TMinsetUserForm.Create(Application);
             MinsetUserForm.Show;
             MinsetUserForm.Visible := True;
             if not fUser then
                MinsetUserForm.UpdateMinsetLabel;
             MinsetUserForm.Update;
             Application.ProcessMessages;
             {initialise variables for minset iterations}
             InitMinsetRun;

             {recalculate if necessary here}
             if (not fContrDataDone) then
             begin
                  if (not MinsetExpertForm.CheckEnableComplementarity.Checked) then
                  {if fNoComplementarityAreaRule
                  or fNoComplementarityPresenceRule then}
                  begin
                       ExecuteIrrepNoComplementarity(iIterationCount,TRUE,False,MinsetExpertForm.CheckEnableComplementarity.Checked,{'',}
                                                     True,
                                                     True);
                  end
                  else
                      ExecuteIrreplaceability(iIterationCount,
                                              False{True{fComprehensiveDebug},
                                              False,False,fComplementarity,
                                              ControlRes^.sWorkingDirectory + '\' + 'execute_irreplaceability_' +
                                              ''{IntToStr(iMinsetIterationCount) + '.csv'{sDebugFileName});
             end;

             if (not MinsetExpertForm.CheckEnableComplementarity.Checked) then
             begin
                  {if fNoComplementarityAreaRule
                  or fNoComplementarityPresenceRule then}
                     ExecuteIrrepNoComplementarity(iIterationCount,TRUE,False,MinsetExpertForm.CheckEnableComplementarity.Checked,
                                                   True,
                                                   True);
             end;

             if fExtraDebug then
                InitSelectionLog;
        end;
        // test  StoppingCondition before we start minset iterations
        fStop := StoppingConditionReached(iIterationCount,fTerminated,iTotalSitesSelected,fExtraDebug);

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('ExecuteMinset start iterations');

        if not fStop then
        repeat
              AppendDebugLog('ExecuteMinset iteration ' + IntToStr(iIterationCount) + ' start');

              sIteration := IntToStr(iIterationCount);
              if fExtraDebug
              and ValidateThisIteration(iIterationCount) then
                  ForceDirectories(ControlRes^.sWorkingDirectory + '\' + sIteration);

              fApply := True;

              if not fUnSuspendExecution then
              begin
                   iSitesChosen := 0;

                   for iCount := 1 to iSiteCount do
                   begin
                        SiteArr.rtnValue(iCount,pSite);

                        if SiteStatusOk(Status2Str(pSite^.status)) then
                        begin
                             Inc(iSitesChosen);

                             if (iSitesChosen > SitesChosen.lMaxSize) then
                                SitesChosen.resize(SitesChosen.lMaxSize + ARR_STEP_SIZE);

                             iKey := pSite^.iKey;
                             SitesChosen.setValue(iSitesChosen,@iKey);
                        end;
                   end;

                   if (iSitesChosen = 0) then
                   begin
                        fApply := False;
                        Screen.Cursor := crDefault;
                        MessageDlg('No sites for minset to select from',mtInformation,[mbOk],0);
                        try
                           if MinsetExpertForm.CheckEnableDestruction.Checked then
                              RecoverMatrix(MinsetExpertForm.CheckExtraDetail.Checked);
                           FreeMinsetRun;
                           if fExtraDebug then
                              CloseSelectionLog;
                           MinsetUserForm.Free;
                        except
                        end;
                        Exit;
                   end
                   else
                       if (iSitesChosen <> SitesChosen.lMaxSize) then
                          SitesChosen.resize(iSitesChosen);

                   iRule := 1;
              end;

              {iterate the rules 1 at a time}
              //fDestructionJustRun := False;
              repeat
                    AppendDebugLog('ExecuteMinset iteration ' + IntToStr(iIterationCount) + ' rule ' + IntToStr(iRule) + ' start');

                    fValidateIteration := False;
                    if fExtraDebug
                    or ControlRes^.fGenerateCompRpt then
                       if ValidateThisIteration(iIterationCount) then
                       begin
                            sIteration := ControlRes^.sWorkingDirectory + '\' +
                                          IntToStr(iIterationCount) + '\' +
                                          'rule' + IntToStr(iRule);
                            // set validation output directory for this rule
                            ForceDirectories(sIteration);
                            fValidateIteration := True;
                       end;

                    if (iRule < RuleBox.Items.Count) then
                       iSitesForCurrentRule := (RuleBox.Items.Count - iRule) * MinsetExpertForm.SpinSelect.Value
                    else
                        iSitesForCurrentRule := MinsetExpertForm.SpinSelect.Value;

                    if fApply then
                    begin
                         if fUnSuspendExecution then
                         begin
                              // read the selected sites from a file
                              fApply := SitesReadFromFile(sSuspendOutputFile,SitesChosen);
                              fUnSuspendExecution := False;
                         end
                         else
                         begin
                              ExtractRule(RuleBox.Items.Strings[iRule-1],
                                          sType, sField, sOperator, sValue);

                              {build array of sites selected from SitesChosen by rule}
                              {stop applying rules when one returns 0 sites}

                              if ControlRes^.fReportMinsetMemSize then
                                 AddMemoryReportRow('ExecuteMinset before ApplyRule rule ' + IntToStr(iRule));

                              fSuspendExecution := False;
                              fApply := ApplyRule(iRule,
                                                  SitesChosen,
                                                  ValuesChosen,
                                                  sType,
                                                  sField,
                                                  sOperator,
                                                  sValue,
                                                  iSitesForCurrentRule,//SpinSelect.Value,
                                                  fSuspendExecution,
                                                  fExtraDebug,
                                                  iIterationCount,
                                                  MinsetExpertForm.CheckEnableComplementarity.Checked,
                                                  fRecalculateComplementarity,
                                                  fComplementarity);

                              // We need to fall gracefully out of the loop if SitesChosen.lMaxSize = 0

                              fRecalculateComplementarity := False;

                              if fSuspendExecution then
                              begin
                                   // store the variables we need before suspending
                                   iSuspendRule := iRule;
                                   iSuspendIterationCount := iIterationCount;
                              end;
                         end;

                         if not fApply then
                            iRuleUsed := iRule;

                         {if rule returns n or less sites,
                          select these and skip rest of rules}
                         if (SitesChosen.lMaxSize = 0) then
                         begin
                              {}
                              Screen.Cursor := crDefault;
                              MessageDlg('zero sites returned by rule ' + IntToStr(iRule),mtInformation,[mbOk],0);
                              iRuleUsed := -1;
                              fApply := False;
                              fTerminated := True;
                         end
                         else
                             if (SitesChosen.lMaxSize <= MinsetExpertForm.SpinSelect.Value) then
                             begin
                                  fApply := False;
                                  iRuleUsed := iRule;
                             end
                             else
                                 {there were more sites chosen than we need,
                                  we will apply the next rule to select a subset
                                  of these sites}
                                 ;

                         MinsetUserForm.lblIteration.Caption := IntToStr(iIterationCount+1);
                         MinsetUserForm.lblRule.Caption := IntToStr(iRule);
                         MinsetUserForm.lblSitesSelected.Caption := IntToStr(SitesChosen.lMaxSize);
                         MinsetUserForm.BringToFront;
                         if not fUser then
                            MinsetUserForm.UpdateMinsetLabel;
                         MinsetUserForm.Update;

                         UpdateRuleHistory(iIterationCount+1,iRule,SitesChosen.lMaxSize);
                    end;

                    if ControlRes^.fReportMinsetMemSize then
                       AddMemoryReportRow('ExecuteMinset end rule ' + IntToStr(iRule));

                    AppendDebugLog('ExecuteMinset iteration ' + IntToStr(iIterationCount) + ' rule ' + IntToStr(iRule) + ' end');


                    Inc(iRule);

              until (iRule > RuleBox.Items.Count);

              if MinsetExpertForm.CheckResourceLimit.Checked then
              begin
                   if IsResourceLimitExceeded(SitesChosen.lMaxSize,
                                              SitesChosen,
                                              MinsetExpertForm.SpinResource.Value) then
                   begin
                        fTerminated := True;
                        //Screen.Cursor := crDefault;
                        //MessageDlg('Resource limit will be exceeded',
                        //           mtInformation,[mbOk],0);
                        sWhatStoppedMinset := 'Minset stopped before exceeding the specified resource limit.';
                        //'Resource limit will be exceeded';
                   end;
              end;


              {select the sites and make them deferred}
              if (not fTerminated) then
              begin
                   Inc(iIterationCount);

                   iTotalSitesSelected := iTotalSitesSelected + SitesChosen.lMaxSize;
                   MinsetUserForm.lblTotalSitesSelected.Caption := IntToStr(iTotalSitesSelected);
                   MinsetUserForm.BringToFront;
                   if not fUser then
                      MinsetUserForm.UpdateMinsetLabel;

                   iMinsetIterationCount := iIterationCount;

                   if (iRuleUsed > 0) then
                   begin
                        RulesUsed.rtnValue(iRuleUsed,@iRuleTmp);
                        Inc(iRuleTmp);
                        RulesUsed.setValue(iRuleUsed,@iRuleTmp);
                   end;

                   if ControlRes^.fReportMinsetMemSize then
                      AddMemoryReportRow('ExecuteMinset before MinsetSelectSites');

                   AppendDebugLog('ExecuteMinset iteration ' + IntToStr(iIterationCount) + ' before MinsetSelectSites');

                   if not ControlRes^.fNullHotspotsSimulation then
                      MinsetSelectSites(SitesChosen,fComplementarity,rAreaOfSitesChosen);

                   AppendDebugLog('ExecuteMinset iteration ' + IntToStr(iIterationCount) + ' after MinsetSelectSites');

                   if ControlRes^.fReportMinsetMemSize then
                      AddMemoryReportRow('ExecuteMinset after MinsetSelectSites');

                   // apply the redundancy check after selecting sites if applicable
                   case MinsetExpertForm.RedundancySetting.ItemIndex of
                        1 : MinimumSetRedundancyCheck(False,MinsetExpertForm.RedCheckOrder.Checked,MinsetExpertForm.RedCheckExclude.Checked);
                        2 : if (iIterationCount > (MinsetExpertForm.RedundancyTiming.Value-1)) then
                               if ((iIterationCount mod MinsetExpertForm.RedundancyTiming.Value) = 0) then
                                  MinimumSetRedundancyCheck(False,MinsetExpertForm.RedCheckOrder.Checked,MinsetExpertForm.RedCheckExclude.Checked);
                   end;
              end;

              if (MinsetExpertForm.RedundancySetting.ItemIndex > 0) then
                 MinsetUserForm.UpdateRedundancyLabel;
              MinsetUserForm.Update;

              {refresh rules form}
              Refresh;

              if not fUser then
                 MinsetUserForm.UpdateMinsetLabel;
              MinsetUserForm.Update;
              Application.ProcessMessages;

              if fStopExecutingMinset then
                 fTerminated := True;

              // do a destruction cycle if applicable
              fDestructionJustRun := False;
              if MinsetExpertForm.CheckEnableDestruction.Checked then
              begin
                   Inc(iSelectionsSinceDestruction,SitesChosen.lMaxSize);
                   rAreaSinceDestruction := rAreaSinceDestruction + rAreaOfSitesChosen;
                   rTotalAreaDestroyed := rTotalAreaDestroyed + rAreaOfSitesChosen;
                   // check whether we are using "Selections Per Destruction" or "Area Per Destruction"

                   AppendDebugLog('ExecuteMinset iteration ' + IntToStr(iIterationCount) + ' before DestroyAvailableFeatures');

                   if (MinsetExpertForm.RadioPerDestruction.ItemIndex = 0) then
                   begin
                        // we are using "Selections Per Destruction"
                        if (iSelectionsSinceDestruction >= MinsetExpertForm.SpinSelectionsPerDestruction.Value) then
                        begin
                             ValidateAreaPerDestruction;

                             DestroyAvailableFeatures(fRecalculateComplementarity);
                             iSelectionsSinceDestruction := 0;
                             rAreaSinceDestruction := 0;
                             fDestructionJustRun := True;
                        end;
                   end
                   else
                   begin
                        // we are using "Area Per Destruction"
                        if (rAreaSinceDestruction >= StrToFloat(MinsetExpertForm.EditAreaPerDestruction.Text)) then
                        begin
                             ValidateAreaPerDestruction;

                             DestroyAvailableFeatures(fRecalculateComplementarity);
                             iSelectionsSinceDestruction := 0;
                             rAreaSinceDestruction := 0;
                             fDestructionJustRun := True;
                        end;
                   end;

                   AppendDebugLog('ExecuteMinset iteration ' + IntToStr(iIterationCount) + ' after DestroyAvailableFeatures');
              end;

              // update minset weighting arrays if we are using them
              if ControlRes^.fCalculateBobsExtraVariations then
                 UpdateMinsetSumirrWeightingArrays;

              if ControlRes^.fReportMinsetMemSize then
                 AddMemoryReportRow('ExecuteMinset before ExecuteIrreplaceability');

              {recalculate if necessary here}
              if (not fAdjProxArithOnly)
              or ControlRes^.fValidateMode then {do not recalc if we are only using adjacency,proximity and arithmetic rules}
                 if (not fContrDataDone) then
                 begin
                      if fNoComplementarityAreaRule then

                      else
                          ExecuteIrreplaceability(iIterationCount,
                                                  True{False{fComprehensiveDebug},
                                                  False,False,fComplementarity,
                                                  ControlRes^.sWorkingDirectory + '\' + 'execute_irreplaceability_' +
                                                  ''{IntToStr(iMinsetIterationCount) + '.csv'{sDebugFileName});
                 end;

              if (not MinsetExpertForm.CheckEnableComplementarity.Checked) then
                 {if fNoComplementarityAreaRule
                 or fNoComplementarityPresenceRule then}
                 begin
                      if MinsetExpertForm.CheckEnableDestruction.Checked
                      and fRecalculateComplementarity
                      and fNoComplementarityPresenceRule then

                      else
                          fRecalculateComplementarity := False;

                      ExecuteIrrepNoComplementarity(iIterationCount,TRUE,False,MinsetExpertForm.CheckEnableComplementarity.Checked,{'',}
                                                    True,
                                                    fRecalculateComplementarity);
                 end;

              // generate debug reports for this cycle
              DebugCyclicReports(iIterationCount,SitesChosen,ValuesChosen);

              AppendDebugLog('ExecuteMinset iteration ' + IntToStr(iIterationCount) + ' end');

        until StoppingConditionReached(iIterationCount,fTerminated,iTotalSitesSelected,fExtraDebug);
        {until stopping condition}

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('ExecuteMinset stopping condition reached');

        // do a final redundancy check if applicable
        if MinsetExpertForm.RedCheckEnd.Checked then
           MinimumSetRedundancyCheck(False,MinsetExpertForm.RedCheckOrder.Checked,MinsetExpertForm.RedCheckExclude.Checked);

        // recover matrix if destruction has been applied
        if MinsetExpertForm.CheckEnableDestruction.Checked then
           RecoverMatrix(MinsetExpertForm.CheckExtraDetail.Checked);

        {use results and free variables from the minset iterations}
        FreeMinsetRun;

        if fExtraDebug then
           CloseSelectionLog;

        MinsetUserForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ExecuteMinset',mtError,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
     dispose(pSite);
end;

end.
