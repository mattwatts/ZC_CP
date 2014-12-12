{
 Unit : destruct.pas
 Version : 1.0
 Author : Matthew Watts
 Date : 29 Dec 1998
 Purpose : Destruction routines which emulate the destruction methods
           in James Sheltons Hotspots program.
}

unit destruct;

interface

uses
    ds,
    mthread, {for sIteration debug output directory}
    SysUtils,
    bin_io, binfile;

const
     MINIMUM_TOTAL_AREA = 0.01;

var
   DestructAmount,
   MinimumDestructArea,
   {DestructStatus,}
   DestructRate, DestructArea, TotalDestructArea : Array_t;
   fDestructionApplied,
   fFeatureCompletelyDestroyed, fDestructionJustRun : boolean;
   iDestructionYear,
   iFeaturesInitiallyDestroyed : integer;

procedure StartDestructReports;
procedure AppendDestructReports;
procedure DumpRetention(const iYearToReport : integer);
procedure DumpStatusVector(const iYearToReport : integer);
procedure DestroyAvailableFeatures(var fFeatureDestroyed : boolean);
procedure InitDestroy(const fDebug : boolean);
procedure WriteInitDestroyFile(const fDebug : boolean);
procedure FreeDestroy(const fDebug : boolean);
procedure RecoverMatrix(const fDebug : boolean);
procedure LoadCrownStatus(const fDebug : boolean);
procedure DebugCrownStatus;
procedure ReInitDestructArea;
procedure  EndDestructReports;
procedure ValidateAreaPerDestruction;
procedure EndDestructAreaFile;


implementation

uses
    forms, controls,
    dialogs, global,
    control, contribu,
    reports, FileCtrl,
    validate,
    inifiles, rules, em_newu1,
    msetexpt,
    sql_unit;

{
 Method for destroying features at sites

 - only available sites can have features destroyed at each iteration
 - destruction rate is specified seperately for each feature,
   ie. fs table field DESTRATE
   the rate is specified as % of cell per cycle
 - destruction status of sites is specified in ss table field
   DESTRUCT, a value of 1 = allow destruction
                        0 = do not allow destruction
   Absence of DESTRUCT field means, all sites are allowed
   destruction.

 - recover original matrix contents at the end of a minset run
}

var
   AreaDestroyedFile, AreaReservedFile, RetentionFile : TextFile;
   sAreaDestroyed, sAreaReserved, sRetention : string;
   iDestructAreaFileUpdateCount : integer;

procedure InitDestructAreaFile;
var
   sLine : string;
   iCount : integer;
   rTotalDestructArea : extended;
   OutputDestructFile : TextFile;
begin
     try
        iDestructAreaFileUpdateCount := 0;


        TotalDestructArea := Array_t.Create;
        TotalDestructArea.init(SizeOf(extended),iFeatureCount);
        rTotalDestructArea := 0;

        for iCount := 1 to iFeatureCount do
        begin
             TotalDestructArea.setValue(iCount,@rTotalDestructArea);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in InitDestructAreaFile',mtError,[mbOk],0);
     end;
end;

procedure UpdateDestructAreaFile;
var
   sLine : string;
   iCount : integer;
   rDestructArea, rTotalDestructArea : extended;
   OutputDestructFile : TextFile;
begin
     try
        Inc(iDestructAreaFileUpdateCount);

        for iCount := 1 to iFeatureCount do
        begin
             TotalDestructArea.rtnValue(iCount,@rTotalDestructArea);
             DestructArea.rtnValue(iCount,@rDestructArea);
             rTotalDestructArea := rTotalDestructArea + rDestructArea;
             TotalDestructArea.setValue(iCount,@rTotalDestructArea);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in UpdateDestructAreaFile',mtError,[mbOk],0);
     end;
end;

procedure EndDestructAreaFile;
var
   TotalDestructAreaFile : TextFile;
   rTotalDestructArea : extended;
   iCount : integer;
   sLine : string;
begin
     try
        assignfile(TotalDestructAreaFile,ControlRes^.sWorkingDirectory + '\total_destruct_area.csv');
        rewrite(TotalDestructAreaFile);
        sLine := 'Year';
        for iCount := 1 to iFeatureCount do
        begin
             sLine := sLine + ',' + IntToStr(iCount);
        end;
        writeln(TotalDestructAreaFile,sLine);
        sLine := 'end';
        for iCount := 1 to iFeatureCount do
        begin
             TotalDestructArea.rtnValue(iCount,@rTotalDestructArea);
             sLine := sLine + ',' + FloatToStr(rTotalDestructArea);
        end;
        writeln(TotalDestructAreaFile,sLine);
        closefile(TotalDestructAreaFile);

        TotalDestructArea.Destroy;

        iDestructAreaFileUpdateCount := 20;

     except
           Screen.Cursor := crDefault;
           //MessageDlg('Exception in EndDestructAreaFile',mtError,[mbOk],0);
     end;
end;

procedure DumpStatusVector(const iYearToReport : integer);
var
   StatusFile : TextFile;
   iCount : integer;
   pSite : sitepointer;
begin
     if (iYearToReport = 0) then
        assignfile(StatusFile,ControlRes^.sWorkingDirectory + '\finalstatus.csv')
     else
         assignfile(StatusFile,ControlRes^.sWorkingDirectory + '\status_year' + IntToStr(iYearToReport) + '.csv');
     rewrite(StatusFile);
     writeln(StatusFile,'SiteKey,Status');
     new(pSite);
     for iCount := 1 to iSiteCount do
     begin
          SiteArr.rtnValue(iCount,pSite);
          writeln(StatusFile,IntToStr(pSite^.iKey) + ',' + Status2Str(pSite^.status));
     end;
     dispose(pSite);
     closefile(StatusFile);
end;


procedure DumpRetention(const iYearToReport : integer);
var
   iCount : integer;
   pFeat : featureoccurrencepointer;
   DestroyedFile_, ReservedFile_, RetentionFile_, InputsFile : TextFile;
   sDest_, sRes_, sRet_ : string;
   rValue : extended;
begin
     // init output files

     if (iYearToReport = 0) then
     begin
          assignfile(DestroyedFile_,ControlRes^.sWorkingDirectory + '\AreaDestroyed_.csv');
          assignfile(ReservedFile_,ControlRes^.sWorkingDirectory + '\AreaReserved_.csv');
          assignfile(RetentionFile_,ControlRes^.sWorkingDirectory + '\Retention_.csv');
          assignfile(InputsFile,ControlRes^.sWorkingDirectory + '\inputs.csv');
     end
     else
     begin
          assignfile(DestroyedFile_,ControlRes^.sWorkingDirectory + '\AreaDestroyed_year_' + IntToStr(iYearToReport) + '.csv');
          assignfile(ReservedFile_,ControlRes^.sWorkingDirectory + '\AreaReserved_year_' + IntToStr(iYearToReport) + '.csv');
          assignfile(RetentionFile_,ControlRes^.sWorkingDirectory + '\Retention_year_' + IntToStr(iYearToReport) + '.csv');
          assignfile(InputsFile,ControlRes^.sWorkingDirectory + '\inputs_year_' + IntToStr(iYearToReport) + '.csv');
     end;
     rewrite(DestroyedFile_);
     rewrite(ReservedFile_);
     rewrite(RetentionFile_);
     rewrite(InputsFile);

     new(pFeat);

     sDest_ := 'Year,';

     for iCount := 1 to (iFeatureCount - 1) do
     begin
          FeatArr.rtnValue(iCount,pFeat);
          sDest_ := sDest_ + IntToStr(pFeat^.code) + ',';
     end;
     FeatArr.rtnValue(iFeatureCount,pFeat);
     sDest_ := sDest_ + IntToStr(pFeat^.code);

     writeln(DestroyedFile_,sDest_);
     writeln(ReservedFile_,sDest_);
     writeln(RetentionFile_,sDest_);
     writeln(InputsFile,'key,total,target');

     // write to output files
     sDest_ := IntToStr(iYearToReport) + ',';
     sRes_ := sDest_;
     sRet_ := sDest_;

     for iCount := 1 to (iFeatureCount - 1) do
     begin
          FeatArr.rtnValue(iCount,pFeat);
          DestructArea.rtnValue(iCount,@rValue);

          sDest_ := sDest_ + FloatToStr(rValue) + ',';
          sRes_ := sRes_ + FloatToStr(pFeat^.rDeferredArea + pFeat^.reservedarea) + ',';

          if (pFeat^.rInitialTrimmedTarget > 0) then
             rValue := 100 * (pFeat^.totalarea / pFeat^.rInitialTrimmedTarget)
          else
              rValue := 0;

          sRet_ := sRet_ + FloatToStr(rValue) + ',';

          writeln(InputsFile,IntToStr(pFeat^.code) + ',' +
                             FloatToStr(pFeat^.totalarea) + ',' +
                             FloatToStr(pFeat^.rInitialTrimmedTarget));
     end;
     FeatArr.rtnValue(iFeatureCount,pFeat);
     DestructArea.rtnValue(iFeatureCount,@rValue);

     sDest_ := sDest_ + FloatToStr(rValue);
     sRes_ := sRes_ + FloatToStr(pFeat^.rDeferredArea + pFeat^.reservedarea);
     if (pFeat^.rInitialTrimmedTarget > 0) then
        rValue := 100 * (pFeat^.totalarea / pFeat^.rInitialTrimmedTarget)
     else
         rValue := 0;
     sRet_ := sRet_ + FloatToStr(rValue);
     writeln(InputsFile,IntToStr(pFeat^.code) + ',' +
                        FloatToStr(pFeat^.totalarea) + ',' +
                        FloatToStr(pFeat^.rInitialTrimmedTarget));

     dispose(pFeat);

     writeln(DestroyedFile_,sDest_);
     writeln(ReservedFile_,sRes_);
     writeln(RetentionFile_,sRet_);

     // close the files
     closefile(DestroyedFile_);
     closefile(ReservedFile_);
     closefile(RetentionFile_);
     closefile(InputsFile);
end;










procedure StartDestructReports;
var
   iCount : integer;
   pFeat : featureoccurrencepointer;
begin
     if not ControlRes^.fStartDestructReportsRun then
     begin
          assignfile(AreaDestroyedFile,ControlRes^.sWorkingDirectory + '\AreaDestroyed.csv');
          assignfile(AreaReservedFile,ControlRes^.sWorkingDirectory + '\AreaReserved.csv');
          assignfile(RetentionFile,ControlRes^.sWorkingDirectory + '\Retention.csv');
          rewrite(AreaDestroyedFile);
          rewrite(AreaReservedFile);
          rewrite(RetentionFile);

          new(pFeat);

          sAreaDestroyed := 'Year,';

          for iCount := 1 to (iFeatureCount - 1) do
          begin
               FeatArr.rtnValue(iCount,pFeat);
               sAreaDestroyed := sAreaDestroyed + IntToStr(pFeat^.code) + ',';
          end;
          FeatArr.rtnValue(iFeatureCount,pFeat);
          sAreaDestroyed := sAreaDestroyed + IntToStr(pFeat^.code);

          writeln(AreaDestroyedFile,sAreaDestroyed);
          writeln(AreaReservedFile,sAreaDestroyed);
          writeln(RetentionFile,sAreaDestroyed);
     end;
     //
     ControlRes^.fStartDestructReportsRun := True;
end;

procedure AppendDestructReports;
var
   iCount : integer;
   pFeat : featureoccurrencepointer;
   rValue : extended;
begin
     // Calculate the rows we are going to write to each of the destruction
     // reports.

     Inc(iDestructionYear);
     sAreaDestroyed := IntToStr(iDestructionYear) + ',';
     sAreaReserved := sAreaDestroyed;
     sRetention := sAreaDestroyed;

     new(pFeat);

     for iCount := 1 to (iFeatureCount - 1) do
     begin
          FeatArr.rtnValue(iCount,pFeat);
          DestructArea.rtnValue(iCount,@rValue);

          sAreaDestroyed := sAreaDestroyed + FloatToStr(rValue) + ',';
          sAreaReserved := sAreaReserved + FloatToStr(pFeat^.rDeferredArea + pFeat^.reservedarea) + ',';

          if (pFeat^.rInitialTrimmedTarget > 0) then
             rValue := 100 * (pFeat^.totalarea / pFeat^.rInitialTrimmedTarget)
          else
              rValue := 0;

          sRetention := sRetention + FloatToStr(rValue) + ',';
     end;
     FeatArr.rtnValue(iFeatureCount,pFeat);
     DestructArea.rtnValue(iFeatureCount,@rValue);

     sAreaDestroyed := sAreaDestroyed + FloatToStr(rValue);
     sAreaReserved := sAreaReserved + FloatToStr(pFeat^.rDeferredArea + pFeat^.reservedarea);
     if (pFeat^.rInitialTrimmedTarget > 0) then
        rValue := 100 * (pFeat^.totalarea / pFeat^.rInitialTrimmedTarget)
     else
         rValue := 0;
     sRetention := sRetention + FloatToStr(rValue);

     dispose(pFeat);

     writeln(AreaDestroyedFile,sAreaDestroyed);
     writeln(AreaReservedFile,sAreaReserved);
     writeln(RetentionFile,sRetention);
end;

procedure EndDestructReports;
begin
     if ControlRes^.fStartDestructReportsRun then
     try
        closefile(AreaDestroyedFile);
        closefile(AreaReservedFile);
        closefile(RetentionFile);
        ControlRes^.fStartDestructReportsRun := False;
     except
     end;
end;

procedure RecoverMatrix(const fDebug : boolean);
var
   iCount, iValueElements : integer;
   pSite : sitepointer;
   Value : ValueFile_T;
   SingleValue : SingleValueFile_T;
   ValueFile : file;
begin
     // recover original contents of site X feature matrix
     // after one or more applications of Destruction
     if fDestructionApplied then
     try
        AppendDebugLog('RecoverMatrix start');

        fFeatureCompletelyDestroyed := False;

        new(pSite);

        assignfile(ValueFile,ControlRes^.sDatabase + '\' + ControlRes^.sSparseMatrix);
        reset(ValueFile,1);
        iValueElements := FileSize(ValueFile) div SizeOf(SingleValueFile_T);
        for iCount := 1 to iValueElements do
        begin
             BlockRead(ValueFile,SingleValue,SizeOf(SingleValueFile_T));
             Value.iFeatKey := SingleValue.iFeatKey;
             Value.rAmount := SingleValue.rAmount;
             FeatureAmount.setValue(iCount,@Value);
        end;
        closefile(ValueFile);

        dispose(pSite);

        ZeroTotalArea;
        SparseMatrixStart;
        SparseTargetsStart;

        AppendDebugLog('RecoverMatrix end');

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RecoverMatrix',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure LoadCrownStatus(const fDebug : boolean{;
                          const sDir : string});
// Added 20 mar 2000 for hotspots Crown land sumirr weighting.
// Also load site string field for CROWN land identification,
// specified in the ini file :
//   [Minset]
//   Crown Field=CR
var
   iCount, iDestructStatus : integer;
   fDestructStatus, fStop, fReadCrownLandField,
   fCrownLand : boolean;
   DebugFile, CrownFile : TextFile;
   pSite : sitepointer;
   AIni : TIniFile;
   sCrownLandField, sCrownLandValue : string;
begin
     try
        AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
        sCrownLandField := AIni.ReadString('Minset','Crown Field','');
        AIni.Free;
        if (sCrownLandField = '') then
           fReadCrownLandField := False
        else
            fReadCrownLandField := True;

        CrownLandSites := Array_t.Create;
        CrownLandSites.init(SizeOf(boolean),iSiteCount);
        fCrownLandSitesCreated := True;
        with ControlForm.OutTable do
        begin
             Open;

             // see if the field exist
             if fReadCrownLandField then
             try
                sCrownLandValue := FieldByName(sCrownLandField).AsString;
             except
                   fReadCrownLandField := False;
                   // initialise CrownLandSites to false
                   fCrownLand := False;
                   for iCount := 1 to iSiteCount do
                       CrownLandSites.setValue(iCount,@fCrownLand);
             end;

             fStop := False;
             if (not fReadCrownLandField) then
                fStop := True;
                // stop if field doesn't exist

             if not fStop then
             begin
                  for iCount := 1 to iSiteCount do
                  begin
                       if fReadCrownLandField then
                       begin
                            sCrownLandValue := FieldByName(sCrownLandField).AsString;

                            if (LowerCase(sCrownLandValue) = 'crown') then
                               fCrownLand := True
                            else
                                fCrownLand := False;

                            CrownLandSites.setValue(iCount,@fCrownLand);
                       end;

                       Next;
                  end;
             end;

             Close;
        end;

        if fDebug then
        begin
             // write contents of crown file
             new(pSite);
             assignfile(CrownFile,ControlRes^.sWorkingDirectory + '\crown_land_field.csv');
             rewrite(CrownFile);
             writeln(CrownFile,'SiteKey,Tenure_' + sCrownLandField);
             for iCount := 1 to iSiteCount do
             begin
                  SiteArr.rtnValue(iCount,pSite);
                  CrownLandSites.rtnValue(iCount,@fCrownLand);
                  if fCrownLand then
                     writeln(CrownFile,IntToStr(pSite^.iKey) + ',CROWN')
                  else
                      writeln(CrownFile,IntToStr(pSite^.iKey) + ',PRIVATE');
             end;
             closefile(CrownFile);
             dispose(pSite);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadCrownStatus',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure DebugCrownStatus;
// Added 2 may 2000 for hotspots Crown land sumirr weighting.
// Also load site string field for CROWN land identification,
// specified in the ini file :
//   [Minset]
//   Crown Field=CR
var
   iCount : integer;
   fCrownLand : boolean;
   CrownFile : TextFile;
   pSite : sitepointer;
begin
     {if ControlRes^.fCalculateAllVariations
     or ControlRes^.fCalculateBobsExtraVariations then}
     try
        // write contents of crown file
        new(pSite);
        assignfile(CrownFile,ControlRes^.sWorkingDirectory + '\crown_land_field.csv');
        rewrite(CrownFile);
        writeln(CrownFile,'SiteKey,CrownField');
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);
             try
                CrownLandSites.rtnValue(iCount,@fCrownLand);
             except
                   // load crown sites
                   closefile(CrownFile);
                   LoadCrownStatus(True);
                   dispose(pSite);
                   Exit;
             end;

             if fCrownLand then
                writeln(CrownFile,IntToStr(pSite^.iKey) + ',CROWN')
             else
                 writeln(CrownFile,IntToStr(pSite^.iKey) + ',PRIVATE');
        end;
        closefile(CrownFile);
        dispose(pSite);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DebugCrownStatus',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure ValidateAreaPerDestruction;
var
   ValFile : TextFile;
   sValFile : string;
begin
     Inc(ControlRes^.iSimulationYear);
     sValFile := ControlRes^.sWorkingDirectory + '\val_area_per_destruction' + IntToStr(iMinsetIterationCount) + '.txt';
     rewrite(ValFile,sValFile);
     writeln(ValFile,'iMinsetIterationCount ' + IntToStr(iMinsetIterationCount));
     writeln(ValFile,'rAreaSinceDestruction ' + FloatToStr(rAreaSinceDestruction));
     writeln(ValFile,'rTotalAreaDestroyed ' + FloatToStr(rTotalAreaDestroyed));
     closefile(ValFile);
end;

procedure ReInitRegionResYear;
var
   iCount : integer;
   rAmount : extended;
begin
     rAmount := 0;
     for iCount := 1 to iRegionCount do
         RegionResYear.setValue(iCount,@rAmount);
end;

procedure DestroyAvailableFeatures(var fFeatureDestroyed : boolean);
var
   iCount, iFeatureTraverse,
   iFeatureIndex, iFeaturesDestroyed : integer;
   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   rTargetReduceAmount,
   rMinimumDestructArea,
   rDestructRate, rDestructArea, rDestructAmount,
   rFeatureAreaBeforeDestruction : extended;
   fDebug,
   fStoreFeature,
   fFirstDestruction,
   fDestructStatus : boolean;
   DebugFile : TextFile;
   Value : ValueFile_T;
begin
     try
        fDebug := fValidateIteration;

        if not ControlRes^.fDestructObjectsCreated then
        begin
             InitDestroy(True);
             fFirstDestruction := True;
             InitDestructAreaFile;
        end
        else
        begin
             fFirstDestruction := False;
             // are we using "Selections Per Destruction" or "Area Per Destruction"
             if (MinsetExpertForm.RadioPerDestruction.ItemIndex = 0) then
             begin
                  // we are using "Selections Per Destruction"
                  if (iMinsetIterationCount = MinsetExpertForm.SpinSelectionsPerDestruction.Value) then
                  begin
                       //ValidateAreaPerDestruction;

                       //StartDestructReports;
                       ReInitDestructArea;
                       iDestructionYear := 0;
                       fFirstDestruction := True;
                       WriteInitDestroyFile(fDebug);
                  end;
             end
             else
             begin
                  // we are using "Area Per Destruction"
                  if (rTotalAreaDestroyed >= StrToFloat(MinsetExpertForm.EditAreaPerDestruction.Text)) then
                  begin
                       //ValidateAreaPerDestruction;

                       //StartDestructReports;
                       ReInitDestructArea;
                       iDestructionYear := 0;
                       fFirstDestruction := True;
                       WriteInitDestroyFile(fDebug);
                  end;
             end;
        end;

        new(pSite);
        new(pFeature);

        fFeatureDestroyed := False;

        if fDebug then
        begin
             ForceDirectories(ControlRes^.sWorkingDirectory + '\' + IntToStr(iMinsetIterationCount) + '\rule2');
             assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\' + IntToStr(iMinsetIterationCount) + '\rule2\DestroyAvailableFeatures.csv');
             rewrite(DebugFile);
             writeln(DebugFile,'SiteKey,FeatureKey,prev farea,prev DestArea,DestRate,new DestArea,new farea,prev tgt,new tgt,prev trim tgt,new trim tgt');
        end;

        // parse and destroy the available sites
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);

             MinimumDestructArea.rtnValue(iCount,@rMinimumDestructArea);

             CrownLandSites.rtnValue(iCount,@fDestructStatus);
             fDestructStatus := not fDestructStatus;
             if (pSite^.status = Av)
             and fDestructStatus then
             // if site is available and destruction is allowed for this site
             begin
                  fDestructionApplied := True;
                  if (pSite^.richness > 0) then
                  begin
                       for iFeatureTraverse := 1 to pSite^.richness do
                       begin
                            FeatureAmount.rtnValue(pSite^.iOffset + iFeatureTraverse,@Value);
                            iFeatureIndex := Value.iFeatKey;
                            if (Value.rAmount > 0) then
                            begin
                                 FeatArr.rtnValue(iFeatureIndex,pFeature);

                                 DestructRate.rtnValue(iFeatureIndex,@rDestructRate);
                                 DestructArea.rtnValue(iFeatureIndex,@rDestructArea);

                                 if fDebug then
                                    write(DebugFile,IntToStr(pSite^.iKey) + ',' +
                                                    IntToStr(Value.iFeatKey) + ',' +
                                                    FloatToStr(Value.rAmount) + ',' +
                                                    FloatToStr(rDestructArea) + ',');
                                    // write SiteKey,FeatureKey,orig featurearea,orig DestructArea to the debug file

                                 rFeatureAreaBeforeDestruction := Value.rAmount;

                                 if fFirstDestruction then
                                 begin
                                      // this is the first destruction iteration
                                      // calculate destruct amount for this matrix cell and store it
                                      rDestructAmount := Value.rAmount *
                                                         rDestructRate / 100;
                                      DestructAmount.setValue(pSite^.iOffset + iFeatureTraverse,@rDestructAmount);
                                 end
                                 else
                                 begin
                                      // this is not the first destruction iteration
                                      // use stored destruct amount for this matrix cell
                                      DestructAmount.rtnValue(pSite^.iOffset + iFeatureTraverse,@rDestructAmount);
                                 end;
                                 if ((Value.rAmount - rDestructAmount) <= rMinimumDestructArea) then
                                 begin
                                      rDestructAmount := Value.rAmount;
                                      Value.rAmount := 0;
                                 end
                                 else
                                     Value.rAmount := Value.rAmount - rDestructAmount;

                                 // determine if this "cell" has been destroyed
                                 if (Value.rAmount = 0)
                                 and (rDestructAmount > 0) then
                                     fFeatureDestroyed := True;
                                     // indicate that a cell has been destroyed
                                 FeatureAmount.setValue(pSite^.iOffset + iFeatureTraverse,@Value);

                                 rDestructArea := rDestructArea + rDestructAmount;
                                 DestructArea.setValue(iFeatureIndex,@rDestructArea);

                                 if fDebug then
                                    write(DebugFile,FloatToStr(rDestructRate) + ',' +
                                                    FloatToStr(rDestructArea) + ',' +
                                                    FloatToStr(Value.rAmount) + ',' +
                                                    FloatToStr(pFeature^.targetarea) + ',');
                                    // write DestructRate,new featurearea, new DestructArea,to the debug file

                                 // decriment rCurrentSumArea and totalarea by the amount that has been destroyed
                                 pFeature^.rCurrentSumArea := pFeature^.rCurrentSumArea - rDestructAmount;
                                 pFeature^.totalarea := pFeature^.totalarea - rDestructAmount;
                                 // decriment rCurrentAreaSqr by square of rFeatureAreaBeforeDestruction
                                 // then increment it by square of the new feature area
                                 pFeature^.rCurrentAreaSqr := pFeature^.rCurrentAreaSqr -
                                                              sqr(rFeatureAreaBeforeDestruction) +
                                                              sqr(rFeatureAreaBeforeDestruction - rDestructAmount);

                                 if (pFeature^.rCurrentSumArea <= rMinimumDestructArea) then
                                 begin
                                      pFeature^.rCurrentSumArea := 0;
                                      pFeature^.rCurrentAreaSqr := 0;
                                 end;
                                 if (pFeature^.totalarea <= rMinimumDestructArea) then
                                    pFeature^.totalarea := 0;

                                 // trim rCurrentEffTarg and targetarea if they are unreachable as
                                 // a result of this destruction
                                 rTargetReduceAmount := 0;
                                 if (pFeature^.rCurrentSumArea < pFeature^.targetarea) then
                                 begin
                                      // we need to reduce targets
                                      rTargetReduceAmount := pFeature^.targetarea - pFeature^.rCurrentSumArea;

                                      pFeature^.targetarea := pFeature^.targetarea - rTargetReduceAmount;
                                      pFeature^.rCurrentEffTarg := pFeature^.rCurrentEffTarg - rTargetReduceAmount;
                                      pFeature^.rTrimmedTarget := pFeature^.rTrimmedTarget - rTargetReduceAmount;

                                      if (pFeature^.targetarea > 0)
                                      and (pFeature^.targetarea <= rMinimumDestructArea) then
                                      begin
                                           pFeature^.targetarea := 0;
                                           pFeature^.rCurrentEffTarg := 0;
                                      end;
                                 end;

                                 if fDebug then
                                    writeln(DebugFile,FloatToStr(pFeature^.targetarea) + ',' +
                                                      FloatToStr(pFeature^.rTrimmedTarget + rTargetReduceAmount) + ',' +
                                                      FloatToStr(pFeature^.rTrimmedTarget));
                                 {
                                 These variables must be adjusted after doing a destruction run

                                 rCurrentEffTarg,
                                 rCurrentSumArea, rCurrentAreaSqr,
                                 totalarea,
                                 targetarea,
                                 }
                                 FeatArr.setValue(iFeatureIndex,pFeature);
                            end;

                            SiteArr.setValue(iCount,pSite);
                       end;
                  end;
             end;
        end;

        UpdateDestructAreaFile;

        // check how many features have zero area so we can see if
        // any additional features have been completely destroyed
        iFeaturesDestroyed := 0;
        fFeatureCompletelyDestroyed := False;
        for iCount := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iCount,pFeature);
             if (pFeature^.totalarea <= 0) then
                Inc(iFeaturesDestroyed);

             fStoreFeature := False;
             // round rCurrentSumArea to zero if it is close to zero
             if (pFeature^.rCurrentSumArea < 0.001)
             and (pFeature^.rCurrentSumArea > -0.001) then
             begin
                  pFeature^.rCurrentSumArea := 0;
                  pFeature^.rCurrentAreaSqr := 0;
                  fStoreFeature := True;
             end;
             // round targetarea
             if (pFeature^.targetarea < 0.001)
             and (pFeature^.targetarea > -0.001) then
             begin
                  pFeature^.targetarea := 0;
                  pFeature^.rCurrentEffTarg := 0;
                  fStoreFeature := True;
             end;
             if fStoreFeature then
                FeatArr.setValue(iCount,pFeature);
        end;
        if (iFeaturesDestroyed > iFeaturesInitiallyDestroyed) then
        begin
             fFeatureCompletelyDestroyed := True;
             iFeaturesInitiallyDestroyed := iFeaturesDestroyed;
        end;

        if fDebug then
        begin
             CloseFile(DebugFile);
             if fFirstDestruction then
             begin
                  // write the calculated destruction amount matrix to a file
                  assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\destruct_amount_matrix.csv');
                  rewrite(DebugFile);
                  writeln(DebugFile,'SiteKey,FeatureKey,DestructAmount');
                  for iCount := 1 to iSiteCount do
                  begin
                       SiteArr.rtnValue(iCount,pSite);
                       if (pSite^.richness > 0) then
                          for iFeatureTraverse := 1 to pSite^.richness do
                          begin
                               DestructAmount.rtnValue(pSite^.iOffset + iFeatureTraverse,@rDestructAmount);
                               FeatureAmount.rtnValue(pSite^.iOffset + iFeatureTraverse,@Value);
                               writeln(DebugFile,IntToStr(pSite^.iKey) + ',' +
                                                 IntToStr(Value.iFeatKey) + ',' +
                                                 FloatToStr(rDestructAmount));
                          end;
                  end;
                  closefile(DebugFile);
             end;
        end;

        dispose(pSite);
        dispose(pFeature);

        if MinsetExpertForm.CheckReAllocate.Checked then
           ReInitRegionResYear;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DestroyAvailableFeatures',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure InitMinimumDestructArea(const fDebug : boolean);
var
   DebugFile : TextFile;
   iCount : integer;
   pSite : sitepointer;
   rValue : extended;
begin
     try
        if fDebug then
        begin
             ForceDirectories(ControlRes^.sWorkingDirectory + '\' + IntToStr(iMinsetIterationCount) + '\rule2');
             assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\' + IntToStr(iMinsetIterationCount) + '\MinimumDestructArea.csv');
             rewrite(DebugFile);
             writeln(DebugFile,'SiteIndex,MinimumDestructArea');
        end;

        MinimumDestructArea := Array_t.Create;
        MinimumDestructArea.init(SizeOf(extended),iSiteCount);

        new(pSite);

        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);
             if (pSite^.area = 0) then
                rValue := 0.2
             else
                 rValue := 0.001 * pSite^.area;    // 0.1 % = 0.001  of site area
             MinimumDestructArea.setValue(iCount,@rValue);
        end;

        dispose(pSite);

        if fDebug then
           CloseFile(DebugFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in InitMinimumDestructArea',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure InitDestructAmount;
var
   iCount : integer;
   rValue : extended;
begin
     try
        DestructAmount := Array_t.Create;
        DestructAmount.init(SizeOf(extended),FeatureAmount.lMaxSize);
        rValue := 0;
        for iCount := 1 to DestructAmount.lMaxSize do
            DestructAmount.setValue(iCount,@rValue);

     except
     end;
end;

procedure ReInitDestructArea;
var
   rValue : extended;
   iCount : integer;
begin
     try
        rValue := 0;
        for iCount := 1 to iFeatureCount do
            DestructArea.setValue(iCount,@rValue);

     except

     end;
end;

procedure WriteInitDestroyFile(const fDebug : boolean);
var
   iCount, iFeatureKey, iFeatureIndex : integer;
   rValue : extended;
   pFeature : featureoccurrencepointer;
   fEnd : boolean;

   DebugFile : TextFile;
begin
     try
        new(pFeature);

        if fDebug then
        begin
             assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\InitDestroy.csv');
             rewrite(DebugFile);
             writeln(DebugFile,'FeatureKey,DestructRate');

             for iCount := 1 to iFeatureCount do
             begin
                  FeatArr.rtnValue(iCount,pFeature);
                  DestructRate.rtnValue(iCount,@rValue);
                  writeln(DebugFile,IntToStr(pFeature^.code) + ',' + FloatToStr(rValue));
             end;

             CloseFile(DebugFile);
        end;

        dispose(pFeature);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in WriteInitDestroyFile',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure InitDestroy(const fDebug : boolean);
var
   iCount, iFeatureKey, iFeatureIndex : integer;
   rValue : extended;
   pFeature : featureoccurrencepointer;
   fEnd : boolean;

   DebugFile : TextFile;
begin
     try
        fFeatureCompletelyDestroyed := False;

        fDestructionApplied := False;

        new(pFeature);
        ControlRes^.fDestructObjectsCreated := True;

        // count how many features have zero area before we
        // start destruction
        iFeaturesInitiallyDestroyed := 0;
        for iCount := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iCount,pFeature);
             if (pFeature^.totalarea = 0) then
                Inc(iFeaturesInitiallyDestroyed);
        end;

        // load DESTRATE from the feature summary table
        DestructRate := Array_t.Create;
        DestructRate.init(SizeOf(extended),iFeatureCount);

        DestructArea := Array_t.Create;
        DestructArea.init(SizeOf(extended),iFeatureCount);

        rValue := 0;
        for iCount := 1 to iFeatureCount do
        begin
             DestructRate.setValue(iCount,@rValue);
             DestructArea.setValue(iCount,@rValue);
        end;

        with ControlForm.FSTable do
        begin
             DatabaseName := ControlRes^.sDatabase;
             TableName := ControlRes^.sFeatCutOffsTable;

             try
                Open;
                fEnd := False;
                repeat
                      iFeatureKey := FieldByName('FEATKEY').AsInteger;
                      iFeatureIndex := iFeatureKey;
                      FeatArr.rtnValue(iFeatureIndex,pFeature);
                      if (pFeature^.code = iFeatureKey) then
                      begin
                           rValue := FieldByName(ControlRes^.sDESTRATEField).AsFloat;
                           DestructRate.setValue(iFeatureIndex,@rValue);
                      end;

                      if Eof then
                         fEnd := True;

                      Next;

                until fEnd;

                Close;

             except
                   // exception acessing table data, just use default value of 1%
                   rValue := 1;
                   for iCount := 1 to iFeatureCount do
                       DestructRate.setValue(iCount,@rValue);
             end;
        end;

        if fDebug then
        begin
             assignfile(DebugFile,ControlRes^.sWorkingDirectory + {'\' + IntToStr(iMinsetIterationCount) +} '\InitDestroy.csv');
             rewrite(DebugFile);
             writeln(DebugFile,'FeatureKey,DestructRate');

             for iCount := 1 to iFeatureCount do
             begin
                  FeatArr.rtnValue(iCount,pFeature);
                  DestructRate.rtnValue(iCount,@rValue);
                  writeln(DebugFile,IntToStr(pFeature^.code) + ',' + FloatToStr(rValue));
             end;

             CloseFile(DebugFile);
        end;

        dispose(pFeature);

        InitMinimumDestructArea(fDebug);

        iDestructionYear := 0;

        // init DestructAmount array
        InitDestructAmount;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in InitDestroy',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure FreeDestroy(const fDebug : boolean);
begin
     try
        ControlRes^.fDestructObjectsCreated := False;

        DestructRate.Destroy;
        DestructArea.Destroy;
        MinimumDestructArea.Destroy;

        // dispose DestructAmount
        DestructAmount.Destroy;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in FreeDestroy',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

end.
