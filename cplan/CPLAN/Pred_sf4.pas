unit Pred_sf4;

{$I STD_DEF.PAS}

interface

{$DEFINE CALC_DEF_IRR} {flag for calculating irreplaceability of deferred sites}

{$UNDEF VALIDATE_DEFERRED_IRREPLACEABILITY} {create VALIDATE file for testing DEFERRED IRREPLACEABILITY
                                              file is: sWorkingDirectory/vdi.csv}

{$UNDEF DEBUG_WAVIRR}

{$UNDEF SUMIRR_IS_TV}

uses
    Global,
    {$IFDEF bit16}
    Arrayt16;
    {$ELSE}
    ds;
    {$ENDIF}


function predict_sf4 (const lSite: longint;
                      var FeatureIrrep : Array_T;
                      const fDebug : boolean;
                      var fBreakExecution : boolean;
                      const fComprehensiveDebug,
                            fIncludeFeatureArea : boolean;
                      const sComprehensiveDebugFile : string;
                      const fStoreSiteValues :  boolean) : extended;
{Simon Ferrier's Irreplaceability predictor version 4
 (re-written into Delphi by Matthew Watts)}
function click_predict_sf4 (lSite: longint) : Array_T;
{same predictor for mouse click calls,
 uses predict_sf4}

// put here for use by reinit.pas
function CalcSumWeightVariations(const iSite, iFeature,
                                       iSubsetContainingThisFeature : integer;
                                 const rFeatureIrreplaceability,
                                       rFeatureArea, rSiteArea,
                                       rResArea, rDefArea, rITarget : extended;
                                 const rFloatVulnerability : single;
                                       iVuln : integer;
                                 const fArea,
                                       fTarget,
                                       fVuln,
                                       fDebugCell : boolean) : extended;

procedure AppendCombsizeLog(const sCallingType : string);

implementation

uses
    Em_newu1, Control, Contribu, Sf_irrep,
    In_order, Dialogs, SysUtils, Toolmisc,
    pred_sf3, Forms, Controls, validate,
    partl_ed, msetinf;


{----------------------------------------------------------------------------}

procedure InitCombsizeLog(const sLogFile : string);
var
   LogFile : TextFile;
begin
     try
        assignfile(LogFile,sLogFile);
        rewrite(LogFile);
        writeln(LogFile,'available sites, selected sites, combsize, date/time, called by');
        closefile(LogFile);
     except
     end;
end;

procedure AppendCombsizeLog(const sCallingType : string);
var
   sLogFile : string;
   LogFile : TextFile;
begin
     try
        WriteCombsizeDebug(sCallingType);


        {sLogFile := ControlRes^.sWorkingDirectory + '\combsize_log.csv';
        if not fileexists(sLogFile) then
           InitCombsizeLog(sLogFile);

        assignfile(LogFile,sLogFile);
        append(LogFile);
        writeln(LogFile,IntToStr(ControlForm.Available.Items.Count) + ',' +
                        IntToStr(ControlForm.Negotiated.Items.Count + ControlForm.Mandatory.Items.Count + ControlForm.Partial.Items.Count) + ',' +
                        IntToStr(iComb) + ',' +
                        FormatDateTime('dddd" "mmmm d yyyy ' + '"  " hh:mm AM/PM', Now) + ',' +
                        sCallingType);
                        //'available sites, selected sites, combsize, date/time, called by');
        closefile(LogFile);}

     except

     end;
end;


procedure CalculateBobsExtraSumWeightVariations
                                (const iSiteIndex, iFeatureKey,
                                       iSubsetContainingThisFeature : integer;
                                 const rFeatureIrreplaceability,
                                       rFeatureArea, rSiteArea,
                                       rResArea, rDefArea, rITarget, rOrigAvTarg : extended;
                                 const rFloatVulnerability : single;
                                       iVuln : integer;
                                 const fArea,
                                       fTarget,
                                       fVuln,
                                       fDebugCell : boolean;
                                 const iWeightScalingType : integer);
var
   MSW : MinsetSumirrWeightings_T;
   rIAC, rPLR, rMAA,
   r_Wcr, r_Wpt, r_Wit, r_Wvu,
   r_Wsa, r_Wpa, rTmp, rContributingArea : extended;
   DebugFile : TextFile;
   iDebugFile : integer;
begin
     try
        // calculate the weightings
        // crown weighting
        InitialAvailableCrown.rtnValue(iFeatureKey,@rIAC);
        PrivateLandReserved.rtnValue(iFeatureKey,@rPLR);

        // iWeightScalingType     scale
        //
        //       0                scale from 0 to 1
        //       1                scale from 1 to 10

        if (rITarget > 0) then
        begin
             rContributingArea := rFeatureArea;
             if (rContributingArea > rITarget) then
                rContributingArea := rITarget;
        end
        else
            rContributingArea := 0;

        case iWeightScalingType of
             0 : // scale from 0 to 1
             begin
                  // NOTE : for crown weighting,
                  //        use initial available target instead of rITarget

                  if (rOrigAvTarg > 0) then // crown weighting
                  begin
                       rTmp := ((rOrigAvTarg - rIAC - rPLR)/rOrigAvTarg);
                       if (rTmp < 0) then
                          rTmp := 0;
                       r_Wcr := rTmp;
                  end
                  else
                      r_Wcr := 0;

                  if (rITarget > 0) then // proportional target weighting
                  begin
                       rTmp := ((rResArea + rDefArea)/rITarget) * (1 - ControlRes^.rSummedMinimumWeight);
                       if (rTmp < 0) then
                          rTmp := 0;
                       r_Wpt := rTmp;
                  end
                  else
                      r_Wpt := 0;

                  if (rITarget > 0) then // inverse target weighting
                  begin
                       rTmp := (1 - ( (rResArea + rDefArea)/rITarget)
                                   * (1 - ControlRes^.rSummedMinimumWeight) );
                       if (rTmp < 0) then
                          rTmp := 0;
                       r_Wit := rTmp;
                  end
                  else
                      r_Wit := 0;
                  // vulnerability weighting
                  r_Wvu := 0;
                  if ControlRes^.fVulnerabilityLoaded then
                  begin
                       if ControlRes^.fUseContinuousVuln then
                          r_Wvu := rFloatVulnerability
                       else
                       begin
                            if (iVuln > 0) then
                               r_Wvu := ControlRes^.VulnerabilityWeightings[iVuln];
                       end;
                  end;
                  // Toms standardised area weighting
                  MaximumAvailableArea.rtnValue(iFeatureKey,@rMAA);
                  if (rMAA > 0) then
                     r_Wsa := rContributingArea / rMAA
                  else
                      r_Wsa := 0;
                  // proportional area weighting
                  if (rSiteArea > 0) then
                     r_Wpa := rContributingArea / rSiteArea
                  else
                      r_Wpa := 0;
             end;
             1 : // scale from 1 to 10
             begin
                  {if (iSiteIndex = 2)
                  and (iFeatureKey = 1) then
                      MessageDlg('bang!',mtInformation,[mbOk],0);}

                  if (rOrigAvTarg > 0) then
                  begin
                       rTmp := 1 + (9 * ((rOrigAvTarg - rIAC - rPLR)/rOrigAvTarg));
                       if (rTmp < 1) then
                          rTmp := 1;
                       r_Wcr := rTmp;

                       {if (iActiveMinset = 2)
                       and (iSiteIndex = 2) then
                          MessageDlg('site 2 feature ' + IntToStr(iFeatureKey) +
                                     ' orig.av.targ ' + FloatToStr(rOrigAvTarg) +
                                     ' iac ' + FloatToStr(rIAC) +
                                     ' plr ' + FloatToStr(rPLR),mtInformation,[mbOk],0);}
                  end
                  else
                      r_Wcr := 1;
                  // proportional target weighting
                  if (rITarget > 0) then
                  begin
                       rTmp := 1 + (9 * ((rResArea + rDefArea)/rITarget) * (1 - ControlRes^.rSummedMinimumWeight));
                       if (rTmp < 1) then
                          rTmp := 1;
                       r_Wpt := rTmp;
                  end
                  else
                      r_Wpt := 1;
                  // inverse target weighting
                  if (rITarget > 0) then
                  begin
                       rTmp := 1 + (9 * (1 - ( (rResArea + rDefArea)/rITarget)
                                   * (1 - ControlRes^.rSummedMinimumWeight) ));
                       if (rTmp < 1) then
                          rTmp := 1;
                       r_Wit := rTmp;
                  end
                  else
                      r_Wit := 1;
                  // vulnerability weighting
                  r_Wvu := 1;
                  if ControlRes^.fVulnerabilityLoaded then
                  begin
                       if ControlRes^.fUseContinuousVuln then
                          r_Wvu := 1 + (9 * rFloatVulnerability)
                       else
                       begin
                            if (iVuln > 0) then
                               r_Wvu := 1 + (9 * ControlRes^.VulnerabilityWeightings[iVuln]);
                       end;
                  end;
                  // Toms standardised area weighting
                  MaximumAvailableArea.rtnValue(iFeatureKey,@rMAA);
                  if (rMAA > 0) then
                  begin
                       rTmp := 1 + (9 * rContributingArea / rMAA);
                       if (rTmp < 1) then
                          rTmp := 1;
                       r_Wsa := rTmp;
                  end
                  else
                      r_Wsa := 1;
                  // proportional area weighting
                  if (rSiteArea > 0) then
                  begin
                       rTmp := 1 + (9 * rContributingArea / rSiteArea);
                       if (rTmp < 1) then
                          rTmp := 1;
                       r_Wpa := rTmp;
                  end
                  else
                      r_Wpa := 1;
             end;
        end;

        MinsetSumirrWeightings.rtnValue(iSiteIndex,@MSW);

        // calculate and store bob's extra sumirr variations
        MSW.rWcr := MSW.rWcr + (rFeatureIrreplaceability * r_Wcr);
        MSW.rWpt := MSW.rWpt + (rFeatureIrreplaceability * r_Wpt);
        MSW.rWcrWit := MSW.rWcrWit + (rFeatureIrreplaceability * r_Wcr * r_Wit);
        MSW.rWcrWvu := MSW.rWcrWvu + (rFeatureIrreplaceability * r_Wcr * r_Wvu);
        MSW.rWcrWitWvu := MSW.rWcrWitWvu + (rFeatureIrreplaceability * r_Wcr * r_Wit * r_Wvu);
        MSW.rWsa := MSW.rWsa + (rFeatureIrreplaceability * r_Wsa);
        MSW.rWsaWpa := MSW.rWsaWpa + (rFeatureIrreplaceability * r_Wsa * r_Wpa);
        // store 2 new values, added 3may00
        MSW.rWsaWpt := MSW.rWsaWpt + (rFeatureIrreplaceability * r_Wsa * r_Wpt);
        MSW.rWpaWpt := MSW.rWpaWpt + (rFeatureIrreplaceability * r_Wpa * r_Wpt);


        MinsetSumirrWeightings.setValue(iSiteIndex,@MSW);

        if ControlRes^.fValidateMode
        and ControlRes^.fCalculateBobsExtraVariations then
        begin
             {iDebugFile := 0;
             repeat
                   Inc(iDebugFile);

             until not fileexists(ControlRes^.sWorkingDirectory +
                                  '\ExtraSumirrWeightings' +
                                  IntToStr(iDebugFile) +
                                  '.csv');}
             if fileexists(ControlRes^.sWorkingDirectory +
                                  '\ExtraSumirrWeightings' +
                                  IntToStr(iMinsetIterationCount) +
                                  '.csv') then
             begin
                  assignfile(DebugFile,ControlRes^.sWorkingDirectory +
                                       '\ExtraSumirrWeightings' +
                                       IntToStr(iMinsetIterationCount) +
                                       '.csv');
                  append(DebugFile);
                  writeln(DebugFile,IntToStr(iSiteIndex) + ',' +
                                    IntToStr(iFeatureKey) + ',' +
                                    FloatToStr(rIAC) + ',' +
                                    FloatToStr(rPLR) + ',' +
                                    FloatToStr(rMAA) + ',' +
                                    FloatToStr(r_Wcr) + ',' +
                                    FloatToStr(r_Wpt) + ',' +
                                    FloatToStr(r_Wit) + ',' +
                                    FloatToStr(r_Wvu) + ',' +
                                    FloatToStr(r_Wsa) + ',' +
                                    FloatToStr(r_Wpa) + ',_,' +
                                    FloatToStr(MSW.rWcr) + ',' +
                                    FloatToStr(MSW.rWpt) + ',' +
                                    FloatToStr(MSW.rWcrWit) + ',' +
                                    FloatToStr(MSW.rWcrWvu) + ',' +
                                    FloatToStr(MSW.rWcrWitWvu) + ',' +
                                    FloatToStr(MSW.rWsa) + ',' +
                                    FloatToStr(MSW.rWsaWpa) + ',' +
                                    FloatToStr(MSW.rWsaWpt) + ',' +
                                    FloatToStr(MSW.rWpaWpt));
                  closefile(DebugFile);
             end;
        end;

     except
     end;
end;

function CalcSumWeightVariations(const iSite, iFeature,
                                       iSubsetContainingThisFeature : integer;
                                 const rFeatureIrreplaceability,
                                       rFeatureArea, rSiteArea,
                                       rResArea, rDefArea, rITarget : extended;
                                 const rFloatVulnerability : single;
                                       iVuln : integer;
                                 const fArea,
                                       fTarget,
                                       fVuln,
                                       fDebugCell : boolean) : extended;

   function ApplySumirrWeightings(const rFeatureIrreplaceability,
                                        rFeatureArea, rSiteArea,
                                        rResArea, rDefArea, rITarget, rContributingArea : extended;
                                        iVuln : integer;
                                  const fArea,
                                        fTarget,
                                        fVuln : boolean;
                                  const iWeightScalingType : integer) : extended;
   var
      rTmp : extended;
   begin
        {}
        try
           Result := rFeatureIrreplaceability;

           case iWeightScalingType of
                0 :
                begin
                     if fArea then {apply Area weight}
                     begin
                          if (rSiteArea > 0) then
                             Result := Result * (rContributingArea/rSiteArea)
                          else
                              Result := 0;
                     end;
                     if fTarget then {apply Target weight}
                     begin
                          if (rITarget > 0) then
                          begin
                               rTmp := (1 - ( (rResArea + rDefArea)/rITarget)
                                       * (1 - ControlRes^.rSummedMinimumWeight) );
                               if (rTmp < 0) then
                                  rTmp := 0;
                               Result := Result * rTmp;
                          end
                          else
                              Result := 0;
                     end;
                     if fVuln {apply Vuln weight}
                     and ControlRes^.fVulnerabilityLoaded then
                     begin
                          // rFloatVulnerability
                          if ControlRes^.fUseContinuousVuln then
                             Result := Result * rFloatVulnerability
                          else
                          begin
                               if (iVuln = 0) then
                                  Result := 0
                               else
                                   Result := Result * ControlRes^.VulnerabilityWeightings[iVuln];
                          end;
                     end;
                end;
                1 :
                begin
                     if fArea then {apply Area weight}
                     begin
                          if (rSiteArea > 0) then
                          begin
                               rTmp := 1 + (9 * (rContributingArea/rSiteArea));
                               if (rTmp >= 1) then
                                  Result := Result * rTmp;
                          end;
                     end;
                     if fTarget then {apply Target weight}
                     begin
                          if (rITarget > 0) then
                          begin
                               rTmp := (1 + (9 *
                                                          (1 - ( (rResArea + rDefArea)/rITarget)
                                                           * (1 - ControlRes^.rSummedMinimumWeight) )));
                               if (rTmp >= 1) then
                                  Result := Result * rTmp;
                          end;
                     end;
                     if fVuln {apply Vuln weight}
                     and ControlRes^.fVulnerabilityLoaded then
                     begin
                          // rFloatVulnerability
                          if ControlRes^.fUseContinuousVuln then
                          begin
                               rTmp := 1 + (9 * rFloatVulnerability);
                               if (rTmp >= 1) then
                                  Result := Result * rTmp;
                          end
                          else
                          begin
                               if (iVuln > 0) then
                                  Result := Result * (1 + (9 * ControlRes^.VulnerabilityWeightings[iVuln]));
                          end;
                     end;
                end;
           end;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in ApplySumirrWeightings',mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;
   end;

var
   WS : WeightedSumirr_T;
   iCount : integer;
   rResult, rContributingArea : extended;
   iVulnerabilityRank : integer;
   DebugFile : TextFile;
begin
     {}
     try
        if (rITarget > 0) then
        begin
             rContributingArea := rFeatureArea;
             if (rContributingArea > rITarget) then
                rContributingArea := rITarget;
        end
        else
            rContributingArea := 0;

        {$IFNDEF SUMIRR_IS_TV}
        if ControlRes^.fCalculateAllVariations then
        {$ENDIF}
        begin
             // for this feature at this site, write debug output indicating :
             // site index, feature index, irreplaceability, area weight, target weight, vuln weight
             if fDebugCell then
             begin
                  assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\sumirr_weightings_test.csv');
                  append(DebugFile);
                  write(DebugFile,IntToStr(iSite) + ',' +
                                    IntToStr(iFeature) + ',');
                  if (rSiteArea > 0) then
                     write(DebugFile,FloatToStr(rFeatureArea/rSiteArea) + ',')
                  else
                      write(DebugFile,'0,');
                  if (rITarget > 0) then
                     write(DebugFile,FloatToStr(1 - ( (rResArea + rDefArea)/rITarget)
                                                 * (1 - ControlRes^.rSummedMinimumWeight) ) + ',')
                  else
                      write(DebugFile,'0,');
                  if ControlRes^.fVulnerabilityLoaded
                  and (iVuln <> 0) then
                      writeln(DebugFile,FloatToStr(ControlRes^.VulnerabilityWeightings[iVuln]))
                  else
                      writeln(DebugFile,'0,');
                  closefile(DebugFile);
             end;

             WeightedSumirr.rtnValue(iSite,@WS);

             {initialise WS}
             {WS is one record of WeightedSumirr}
             rResult := ApplySumirrWeightings(rFeatureIrreplaceability,rFeatureArea,rSiteArea,rResArea,rDefArea,rITarget,rContributingArea,iVuln,
                                                      True{Area},
                                                      False{Target},
                                                      False{Vuln},
                                              ControlRes^.iScalingType);
             WS.r_a := WS.r_a + rResult;
             if (iSubsetContainingThisFeature > 0) then
                WS.r_sub_a[iSubsetContainingThisFeature] := WS.r_sub_a[iSubsetContainingThisFeature] + rResult;

             rResult := ApplySumirrWeightings(rFeatureIrreplaceability,rFeatureArea,rSiteArea,rResArea,rDefArea,rITarget,rContributingArea,iVuln,
                                                      False{Area},
                                                      True{Target},
                                                      False{Vuln},
                                              ControlRes^.iScalingType);
             WS.r_t := WS.r_t + rResult;

             if (iSubsetContainingThisFeature > 0) then
                WS.r_sub_t[iSubsetContainingThisFeature] := WS.r_sub_t[iSubsetContainingThisFeature] + rResult;

             rResult := ApplySumirrWeightings(rFeatureIrreplaceability,rFeatureArea,rSiteArea,rResArea,rDefArea,rITarget,rContributingArea,iVuln,
                                                      False{Area},
                                                      False{Target},
                                                      True{Vuln},
                                              ControlRes^.iScalingType);
             WS.r_v := WS.r_v + rResult;
             if (iSubsetContainingThisFeature > 0) then
                WS.r_sub_v[iSubsetContainingThisFeature] := WS.r_sub_v[iSubsetContainingThisFeature] + rResult;

             rResult := ApplySumirrWeightings(rFeatureIrreplaceability,rFeatureArea,rSiteArea,rResArea,rDefArea,rITarget,rContributingArea,iVuln,
                                                      True{Area},True{Target},False{Vuln},
                                              ControlRes^.iScalingType);
             WS.r_at := WS.r_at + rResult;
             if (iSubsetContainingThisFeature > 0) then
                WS.r_sub_at[iSubsetContainingThisFeature] := WS.r_sub_at[iSubsetContainingThisFeature] + rResult;

             rResult := ApplySumirrWeightings(rFeatureIrreplaceability,rFeatureArea,rSiteArea,rResArea,rDefArea,rITarget,rContributingArea,iVuln,
                                                True{Area},False{Target},True{Vuln},
                                              ControlRes^.iScalingType);
             WS.r_av := WS.r_av + rResult;
             if (iSubsetContainingThisFeature > 0) then
                WS.r_sub_av[iSubsetContainingThisFeature] := WS.r_sub_av[iSubsetContainingThisFeature] + rResult;

             rResult := ApplySumirrWeightings(rFeatureIrreplaceability,rFeatureArea,rSiteArea,rResArea,rDefArea,rITarget,rContributingArea,iVuln,
                                                False{Area},True{Target},True{Vuln},
                                              ControlRes^.iScalingType);
             WS.r_tv := WS.r_tv + rResult;
             if (iSubsetContainingThisFeature > 0) then
                WS.r_sub_tv[iSubsetContainingThisFeature] := WS.r_sub_tv[iSubsetContainingThisFeature] + rResult;

             rResult := ApplySumirrWeightings(rFeatureIrreplaceability,rFeatureArea,rSiteArea,rResArea,rDefArea,rITarget,rContributingArea,iVuln,
                                                 True{Area},True{Target},True{Vuln},
                                              ControlRes^.iScalingType);
             WS.r_atv := WS.r_atv + rResult;
             if (iSubsetContainingThisFeature > 0) then
                WS.r_sub_atv[iSubsetContainingThisFeature] := WS.r_sub_atv[iSubsetContainingThisFeature] + rResult;

             WeightedSumirr.setValue(iSite,@WS);
        end;

        Result := ApplySumirrWeightings(rFeatureIrreplaceability,rFeatureArea,rSiteArea,rResArea,rDefArea,rITarget,rContributingArea,iVuln,
                                        fArea,
                                        fTarget,
                                        fVuln,
                                        ControlRes^.iScalingType);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CalcSumWeightVariations',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function predict_sf4 (const lSite: longint;
                      var FeatureIrrep : Array_T;
                      const fDebug : boolean;
                      var fBreakExecution : boolean;
                      const fComprehensiveDebug,
                            fIncludeFeatureArea : boolean;
                      const sComprehensiveDebugFile : string;
                      const fStoreSiteValues :  boolean) : extended;

var
   mean_site,sd,z,area_site,area2_site,sumarea,sumarea2,mean_target,zmin,
   combadj : extended;
   {variables to facilitate calculation on deferred sites as if they were available}
   rContributingArea, {rInSite,}
   rSiteIrreplaceability,
   rDeducedTarget, rDeducedSumArea, rDeducedAreaSqr,
   rDeducedMult,
   rDeducedWt_include, rDeducedWt_exclude : extended;
   iDeducedAvailCount, iDeducedCombSize : integer;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   pRepr : ReprPointer;
   ContributingArea : array [1..5] of extended;
   SumProduct : ElevenExtendedArr_T;
   rTmp : extended;
   fValidateSite, fValidateFeature,
   fDebugWeightings,
   fPartialOn, fReserved : boolean;
   validatefile, comprehensivefile : text;
   rSumContributingArea,
   rWeight : extended;
   //InitialValue : InitialValues_T;
   fStoreInitialValues : boolean;
   iTest : integer;
   {$IFDEF DEBUG_WAVIRR}
   WavirrFile : TextFile;
   {$ENDIF}
   Value : ValueFile_T;
   DebugFile : TextFile;
   MSW : MinsetSumirrWeightings_T;
   WS : WeightedSumirr_T;
   //sSumArea, sSumArea2, smean_site : string;

   procedure InitIrrep;
   var
      iInit : integer;
   begin
        // set this to true if we have found the condition that necesitates
        // re-calculating combination size so that the calling process will know
        // to do so

        if ControlRes^.fFloatVulnerabilityLoaded
        and (ControlRes^.iVulnWeightingType = 1) then
            // use continuous vuln
            ControlRes^.fUseContinuousVuln := True
        else
            // use 5 ordinal classes vuln
            ControlRes^.fUseContinuousVuln := False;

        fDebugWeightings := False;

        fBreakExecution := False;
        fStoreInitialValues := False;
        iTest := ControlForm.R1.Items.Count + ControlForm.R2.Items.Count +
                 ControlForm.R3.Items.Count + ControlForm.R4.Items.Count + ControlForm.R5.Items.Count +
                 ControlForm.Partial.Items.Count + ControlForm.Excluded.Items.Count;
        if (iTest = 0) then
        begin
             fStoreInitialValues := True;
        end;

        new(pSite);
        new(pFeat);
        new(pRepr);

        SiteArr.rtnValue(lSite,pSite);
        pSite^.rSummedIrr := 0;
        pSite^.rSummedIrrVuln2 := 0;
        pSite^.rWAVIRR := 0;
        pSite^.rPCUSED := 0;
        pSite^.fSiteHasUse := False;
        rSiteIrreplaceability := 0;

        if ControlRes^.fCalculateAllVariations then
        begin
             WS.r_a := 0;
             WS.r_t := 0;
             WS.r_v := 0;
             WS.r_at := 0;
             WS.r_av := 0;
             WS.r_atv := 0;
             WS.r_tv := 0;
             for iInit := 1 to 10 do
             begin
                  WS.r_sub_a[iInit] := 0;
                  WS.r_sub_t[iInit] := 0;
                  WS.r_sub_v[iInit] := 0;
                  WS.r_sub_at[iInit] := 0;
                  WS.r_sub_av[iInit] := 0;
                  WS.r_sub_atv[iInit] := 0;
                  WS.r_sub_tv[iInit] := 0;
             end;
             WeightedSumirr.setValue(lSite,@WS);
        end;

        if ControlRes^.fCalculateBobsExtraVariations then
        begin
             // initialise values for this site to zero
             MSW.rWcr := 0;
             MSW.rWpt := 0;
             MSW.rWcrWit := 0;
             MSW.rWcrWvu := 0;
             MSW.rWcrWitWvu := 0;
             MSW.rWsa := 0;
             MSW.rWsaWpa := 0;
             MSW.rWsaWpt := 0;
             MSW.rWpaWpt := 0;
             MinsetSumirrWeightings.setValue(lSite,@MSW);
        end;

        {$IFDEF SPARSE_MATRIX_2}
        {$ELSE}
        new(pCArea);
        //ContribArea.rtnValue(lSite,pCArea);
        {$ENDIF}

        if fDebug then
        begin
             {we are in debug mode, create output VALIDATE file for this site}
             if ((pSite^.status = _R1) or (pSite^.status = _R2) or (pSite^.status = _R3) or (pSite^.status = _R4) or (pSite^.status = _R5) or (pSite^.status = Pd)) then
                assignfile(validatefile,ControlRes^.sWorkingDirectory + '\____' + IntToStr(pSite^.iKey) + 'd_vdi.csv')
             else
                 assignfile(validatefile,ControlRes^.sWorkingDirectory + '\' + IntToStr(pSite^.iKey) + '_vdi.csv');
             rewrite(validatefile);

             write(validatefile,'Feature Code,Original Effective Target,area_site,area2_site,sumarea,sumarea2,');
             writeln(validatefile,'mean_site,irr_feature,repr_include,repr_exclude,repr_incexc,available site count');
        end;

        if fDebugWeightings then
        begin
             {assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\sumirr_weightings_test.csv');
             rewrite(DebugFile);
             writeln(DebugFile,'site index, feature index, irreplaceability, area weight, target weight, vuln weight');
             closefile(DebugFile);}
        end;

        if fComprehensiveDebug then
        begin
             assignfile(comprehensivefile,sComprehensiveDebugFile);
             append(comprehensivefile);
        end;

        {$IFDEF DEBUG_WAVIRR}
        // site key, feat key, feat irr, contrib area, sum product, sum contrib area
        assignfile(WavirrFile,ControlRes^.sWorkingDirectory + '\debug_wavirr' + IntToStr(iMinsetIterationCount) + '.csv');
        if (lSite = 1) then
        begin
             rewrite(WavirrFile);
             writeln(WavirrFile,'site key,feat key,feat irr,contrib area,sum product,sum contrib area');
        end
        else
            append(WavirrFile);
        {$ENDIF}
   end;

   procedure FreeIrrep;
   begin
        pSite^.rIrreplaceability := rSiteIrreplaceability;
        // do the Initial Value adjustment before storing the values
        (*
        if fStoreInitialValues then
        begin
             // store the InitialValues array if
             InitialValue.rIrr := pSite^.rIrreplaceability ;
             InitialValue.rSumIrr := pSite^.rSummedIrr;
             InitialValue.rWavIrr := pSite^.rWAVIRR;
             InitialValues.setValue(lSite,@InitialValue);
             ControlRes^.fInitialValuesCreated := True;
        end
        else
            if ControlRes^.fInitialValuesCreated
            and (not ControlRes^.fDestructObjectsCreated) then
            begin
                 // use the initial values
                 InitialValues.rtnValue(lSite,@InitialValue);
                 if (pSite^.rIrreplaceability > InitialValue.rIrr)then
                    pSite^.rIrreplaceability := InitialValue.rIrr;
                 if (pSite^.rSummedIrr > InitialValue.rSumIrr)then
                    pSite^.rSummedIrr := InitialValue.rSumIrr;
                 if (pSite^.rWAVIRR > InitialValue.rWavIrr)then
                    pSite^.rWAVIRR := InitialValue.rWavIrr;
            end;
        *)
        if fStoreSiteValues then
           SiteArr.setValue(lSite,pSite);

        dispose(pSite);
        dispose(pFeat);
        dispose(pRepr);
        {$IFNDEF SPARSE_MATRIX_2}
        dispose(pCArea);
        {$ENDIF}

        if fDebug then
           CloseFile(validatefile);

        if fComprehensiveDebug then
           closefile(comprehensivefile);

        {$IFDEF DEBUG_WAVIRR}
        closefile(WavirrFile);
        {$ENDIF}
   end;

   procedure IrrepAvFl;
   label
        skip1,skip2,skip3;
   var
      feature, iCount : integer;
   begin
        try
           for feature:=1 to pSite^.richness do
           begin
                //fPartialOn := True;

                FeatureAmount.rtnValue(pSite^.iOffset + feature,@Value);
                area_site := Value.rAmount;
                FeatArr.rtnValue(Value.iFeatKey,pFeat);

                area2_site:=sqr(area_site);

                if {(not fPartialOn)
                or} (pFeat^.targetarea <= 0)
                or (Value.rAmount <= 0) then
                begin
                     pRepr^.repr_incexc := 1{0}; {? or 1}
                     pRepr^.repr_exclude := 1;
                     pRepr^.repr_include := 1;
                     sumarea := 0;
                     sumarea2 := 0;
                     mean_site := 0;
                     goto skip3;
                end;

                pSite^.fSiteHasUse := True;

                sumarea := (pFeat^.rCurrentSumArea - area_site)*mult;
                sumarea2 := (pFeat^.rCurrentAreaSqr - area2_site)*mult;
                mean_site := sumarea/iAvailableSiteCount;
                try
                   if ((combsize.iActiveCombinationSize-1) > (iAvailableSiteCount-1)/2.0)
                   // the following lines could cause an error if combsize = 1
                   and (iAvailableSiteCount > combsize.iActiveCombinationSize) then
                       combadj := sqrt((iAvailableSiteCount-1)-(combsize.iActiveCombinationSize-1))/(combsize.iActiveCombinationSize-1)
                   else
                       combadj:=sqrt(combsize.iActiveCombinationSize-1)/(combsize.iActiveCombinationSize-1);
                except
                      combadj := 0;
                end;

                rTmp := (sumarea2-(sqr(sumarea)/iAvailableSiteCount))/(iAvailableSiteCount);
                if (rTmp >= 0) then
                   rTmp := sqrt(rTmp)
                else
                    rTmp := 0;
                sd := rTmp * combadj;

                if (pFeat^.rCurrentSumArea - area_site) < pFeat^.targetarea then
                begin
                     pRepr^.repr_incexc:=0;
                     goto skip1;
                end;
                mean_target:=pFeat^.targetarea/(combsize.iActiveCombinationSize-1);
                if sd < 0.00000000001 then
                begin
                     if mean_site < mean_target then
                        pRepr^.repr_incexc:=0
                     else
                         pRepr^.repr_incexc:=1;
                end
                else
                begin
                     z:=(mean_target-mean_site)/sd;
                     pRepr^.repr_incexc:=zprob(z);
                end;
         skip1:
                if area_site >= pFeat^.targetarea then
                begin
                     pRepr^.repr_include:=1;
                     goto skip2;
                end;
                try
                   mean_target:=(pFeat^.targetarea-area_site)/(combsize.iActiveCombinationSize-1);
                except // this exception handler added for the case when combsize = 1, 1June00
                      mean_target := (pFeat^.targetarea-area_site);
                end;

                if sd < 0.00000000001 then
                begin
                     if mean_site < mean_target then
                        pRepr^.repr_include:=0
                     else
                         pRepr^.repr_include:=1;
                end
                else
                begin
                     z:=(mean_target-mean_site)/sd;
                     pRepr^.repr_include:=zprob(z);
                end;
         skip2:
                if ((combsize.iActiveCombinationSize) > (iAvailableSiteCount-1)/2.0)
                and ((iAvailableSiteCount-1) > combsize.iActiveCombinationSize) then
                    combadj:=sqrt((iAvailableSiteCount-1)-(combsize.iActiveCombinationSize))/(combsize.iActiveCombinationSize)
                else
                    combadj:=sqrt(combsize.iActiveCombinationSize)/(combsize.iActiveCombinationSize);

                rTmp := (sumarea2-(sqr(sumarea)/iAvailableSiteCount))/(iAvailableSiteCount);
                if (rTmp >= 0) then
                   rTmp := sqrt(rTmp)
                else
                    rTmp := 0;
                sd := rTmp * combadj;

                if (pFeat^.rCurrentSumArea - area_site) < pFeat^.targetarea then
                begin
                     pRepr^.repr_exclude:=0;
                     goto skip3;
                end;
                mean_target:=pFeat^.targetarea/(combsize.iActiveCombinationSize);
                if sd < 0.00000000001 then
                begin
                     if mean_site < mean_target then
                        pRepr^.repr_exclude:=0
                     else
                         pRepr^.repr_exclude:=1;
                end
                else
                begin
                     z:=(mean_target-mean_site)/sd;
                     pRepr^.repr_exclude:=zprob(z);
                end;
        skip3:
                // this the trigger for the condition where combination size is too SMALL for this feature
                if (pRepr^.repr_include = 0)
                and (pRepr^.repr_exclude = 0) then
                begin
                     if (pFeat^.targetarea < pFeat^.rCurrentSumArea) then
                     begin
                          fBreakExecution := True;
                          iBreakSiteKey := pSite^.iKey;
                          iBreakFeatureKey := Value.iFeatKey;
                     end;
                end;
                    // if this feature needs all remaining available area then don't break
                    // and instead make irr = 1

                    // Break Execution and recalculate combination size

                if (pRepr^.repr_include = 0)
                and (Value.rAmount > 0) then
                    pRepr^.repr_include:=1;
                if (pRepr^.repr_include + pRepr^.repr_exclude) = 0 then
                   pRepr^.irr_feature:=0
                else
                    pRepr^.irr_feature:=((pRepr^.repr_include-pRepr^.repr_incexc)*wt_include)
                       /(pRepr^.repr_include*wt_include+pRepr^.repr_exclude*wt_exclude);

                LocalRepr.setValue(Value.iFeatKey,pRepr);

                // this the trigger for the condition where combination size is too LARGE for this feature
                {if (pFeat^.targetarea > 0)
                and (pRepr^.irr_feature = 0) then
                    fBreakExecution := True;}
                    // Break Execution and recalculate combination size

                if fDebug then
                begin
                     write(validatefile,IntToStr(pFeat^.code) + ',' + FloatToStr(pFeat^.targetarea) + ',' +
                           FloatToStr(area_site) + ',' + FloatToStr(area2_site) + ',' + FloatToStr(sumarea) + ',' +
                           FloatToStr(sumarea2) + ',');
                     writeln(validatefile,FloatToStr(mean_site) + ',' + FloatToStr(pRepr^.irr_feature) + ',' + FloatToStr(pRepr^.repr_include) + ',' +
                             FloatToStr(pRepr^.repr_exclude) + ',' + FloatToStr(pRepr^.repr_incexc) + ',' + IntToStr(iAvailableSiteCount));

                end;

                if fComprehensiveDebug then
                begin
                     // need to check if we are to include this site & feature
                     // fValidateSite, fValidateFeature
                     ValidateSite.rtnValue(lSite,@fValidateSite);
                     ValidateFeature.rtnValue(pFeat^.code,@fValidateFeature);

                     if fValidateSite
                     and fValidateFeature then
                     begin
                          {   try
                                sSumArea := FloatToStr(sumarea);
                             except
                                   sSumArea := '';
                             end;
                             try
                                sSumArea2 := FloatToStr(sumarea2);
                             except
                                   sSumArea2 := '';
                             end;
                             try
                                smean_site := FloatToStr(mean_site);
                             except
                                   smean_site := '';
                             end;
                          write(comprehensivefile,IntToStr(pFeat^.code) + ',' + FloatToStr(pFeat^.targetarea) + ',' +
                                FloatToStr(area_site) + ',' + FloatToStr(area2_site) + ',' + sSumArea + ',' +
                                sSumArea2 + ',');
                          writeln(comprehensivefile,smean_site + ',' + FloatToStr(pRepr^.irr_feature) + ',' + FloatToStr(pRepr^.repr_include) + ',' +
                                  FloatToStr(pRepr^.repr_exclude) + ',' + FloatToStr(pRepr^.repr_incexc) + ',' + IntToStr(iAvailableSiteCount));}
                          write(comprehensivefile,IntToStr(pFeat^.code) + ',' + FloatToStr(pFeat^.targetarea) + ',' +
                                FloatToStr(area_site) + ',' + FloatToStr(area2_site) + ',' + FloatToStr(sumarea) + ',' +
                                FloatToStr(sumarea2) + ',');
                          writeln(comprehensivefile,FloatToStr(mean_site) + ',' + FloatToStr(pRepr^.irr_feature) + ',' + FloatToStr(pRepr^.repr_include) + ',' +
                                  FloatToStr(pRepr^.repr_exclude) + ',' + FloatToStr(pRepr^.repr_incexc) + ',' + IntToStr(iAvailableSiteCount));
                         (*
                         write(comprehensivefile,IntToStr(lSite) + ',' +
                                                 IntToStr(pFeat^.code) + ',');

                         if fIncludeFeatureArea then
                            write(comprehensivefile,FloatToStr(area_site) + ',');

                         write(comprehensivefile,'0,' + FloatToStr(pRepr^.irr_feature) + ',');

                         if (pFeat^.targetarea > 0)
                         and (area_site > 0) then
                         begin
                              {if (pFeat^.targetarea < area_site) then
                                 writeln(comprehensivefile,'100')
                              else}
                                  writeln(comprehensivefile,FloatToStr(area_site/pFeat^.targetarea*100));
                         end
                         else
                             writeln(comprehensivefile,'0');  *)
                     end;
                end;
           end;

           rSumContributingArea := 0;

           if ControlRes^.fFeatureClassesApplied then
           begin
                {initialise variables for use}
                for iCount := 1 to 11 do
                begin
                     total_repr_include[iCount]:=1;
                     total_repr_exclude[iCount]:=1;
                     total_repr_incexc[iCount]:=1;
                     SumProduct[iCount] := 0;
                end;
                for iCount := 1 to 10 do
                begin
                     pSite^.rSubsetIrr[iCount] := 0;
                     pSite^.rSubsetSum[iCount] := 0;
                end;
                for iCount := 1 to 5 do
                begin
                     pSite^.rSubsetWav[iCount] := 0;
                     pSite^.rSubsetPCUsed[iCount] := 0;
                     ContributingArea[iCount] := 0;
                end;

                {traverse features adding up values}
                if (pSite^.richness > 0) then
                for feature:=1 to pSite^.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffset + feature,@Value);
                     LocalRepr.rtnValue(Value.iFeatKey,pRepr);
                     FeatArr.rtnValue(Value.iFeatKey,pFeat);

                     {$IFDEF SPARSE_MATRIX_2}
                     FeatureIrrep.setValue(feature,@pRepr^.irr_feature);
                     //ContribArea.rtnValue(feature,@rContributingArea);
                     {$ELSE}
                     FeatureIrrep[feature] := pRepr^.irr_feature;
                     rContributingArea := 0;//pCArea^[feature];
                     {$ENDIF}

                     {$IFDEF TRUNCATE_VULNERABILITY}
                     {pFeat.rVulnerability := Trunc(pFeat.rVulnerability);
                     if (pFeat.rVulnerability > 5) then
                        pFeat.rVulnerability := 5;
                     if (pFeat.rVulnerability < 0) then
                        pFeat.rVulnerability := 0;}
                     {$ENDIF}

                     rWeight := CalcSumWeightVariations(lSite,feature,pFeat^.iOrdinalClass,
                                pRepr^.irr_feature,
                                {$IFDEF SPARSE_MATRIX}
                                Value.rAmount,
                                {$ELSE}
                                pSite^.featurearea[feature],
                                {$ENDIF}
                                pSite^.area,
                                pFeat^.reservedarea,
                                pFeat^.rDeferredArea,
                                pFeat^.rCutOff,
                                pFeat^.rFloatVulnerability,
                                Trunc(pFeat^.rVulnerability),
                                False,False,False,
                                fDebugWeightings);

                     pSite^.rSummedIrr := pSite^.rSummedIrr + rWeight;

                     pSite^.rSummedIrrVuln2 := pSite^.rSummedIrrVuln2 + (pFeat^.rFloatVulnerability * pRepr^.irr_feature);

                     if ControlRes^.fCalculateBobsExtraVariations then
                        CalculateBobsExtraSumWeightVariations(lSite,
                                                              Value.iFeatKey,
                                                              pFeat^.iOrdinalClass,
                                                              pRepr^.irr_feature,
                                                              Value.rAmount,
                                                              pSite^.area,
                                                              pFeat^.reservedarea,
                                                              pFeat^.rDeferredArea,
                                                              pFeat^.rCutOff,
                                                              pFeat^.rInitialAvailableTarget,
                                                              pFeat^.rFloatVulnerability,
                                                              Trunc(pFeat^.rVulnerability),
                                                              False,False,False,
                                                              fDebugWeightings,
                                                              ControlRes^.iScalingType);

                     // calculate Contributing Area
                     {$IFDEF SPARSE_MATRIX}
                     {rInSite := Value.rAmount; }
                     {$ELSE}
                     {rInSite := pSite^.featurearea[iCount]; }
                     {$ENDIF}
                     rContributingArea := pFeat^.targetarea;
                     if (pFeat^.targetarea > Value.rAmount) then
                        rContributingArea := Value.rAmount;
                     if (rContributingArea < 0) then
                        rContributingArea := 0;
                            
                     {$IFDEF SPARSE_MATRIX}
                     if (Value.iFeatKey <= iPCUsedCutOff) then
                     {$ELSE}
                     if (pSite^.feature[feature] <= iPCUsedCutOff) then
                     {$ENDIF}
                     begin
                          SumProduct[11] := SumProduct[11] + (pRepr^.irr_feature * rContributingArea);
                          rSumContributingArea := rSumContributingArea + rContributingArea;
                     end;

                     total_repr_include[11]:=total_repr_include[11]*pRepr^.repr_include;
                     total_repr_exclude[11]:=total_repr_exclude[11]*pRepr^.repr_exclude;
                     total_repr_incexc[11]:=total_repr_incexc[11]*pRepr^.repr_incexc;

                     if (pFeat^.iOrdinalClass > 0) then
                     begin
                          pSite^.rSubsetSum[pFeat^.iOrdinalClass] := pSite^.rSubsetSum[pFeat^.iOrdinalClass] +
                                                                     rWeight;
                          total_repr_include[pFeat^.iOrdinalClass]:=total_repr_include[pFeat^.iOrdinalClass]*pRepr^.repr_include;
                          total_repr_exclude[pFeat^.iOrdinalClass]:=total_repr_exclude[pFeat^.iOrdinalClass]*pRepr^.repr_exclude;
                          total_repr_incexc[pFeat^.iOrdinalClass]:=total_repr_incexc[pFeat^.iOrdinalClass]*pRepr^.repr_incexc;
                          if (pFeat^.iOrdinalClass <= 5) then
                          begin
                               ContributingArea[pFeat^.iOrdinalClass] := ContributingArea[pFeat^.iOrdinalClass] + rContributingArea;
                               SumProduct[pFeat^.iOrdinalClass] := SumProduct[pFeat^.iOrdinalClass] + (pRepr^.irr_feature * rContributingArea);
                          end;
                     end;
                end;

                {calculate Wavirr and PCUsed for 5 feature subsets}
                for iCount := 1 to 5 do
                    if (pSite^.area > 0) then
                    begin
                         pSite^.rSubsetWav[iCount] := SumProduct[iCount] / pSite^.area;
                         pSite^.rSubsetPCUsed[iCount] := ContributingArea[iCount] / pSite^.area * 100;
                    end
                    else
                    begin
                         pSite^.rSubsetWav[iCount] := 0;
                         pSite^.rSubsetPCUsed[iCount] := 0;
                    end;

                {calculate Irr for 10 feature subsets}
                for iCount := 1 to 10 do
                    if (total_repr_include[iCount] + total_repr_exclude[iCount]) = 0 then
                       pSite^.rSubsetIrr[iCount]:=0
                    else
                        pSite^.rSubsetIrr[iCount]:=((total_repr_include[iCount]-total_repr_incexc[iCount])*wt_include)
                                                   /(total_repr_include[iCount]*wt_include+total_repr_exclude[iCount]*wt_exclude);
           end
           else  // feature classes are not applied
           begin
                total_repr_include[11]:=1;
                total_repr_exclude[11]:=1;
                total_repr_incexc[11]:=1;

                SumProduct[11] := 0;

                if (pSite^.richness > 0) then
                for feature:=1 to pSite^.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffset + feature,@Value);
                     LocalRepr.rtnValue(Value.iFeatKey,pRepr);
                     FeatArr.rtnValue(Value.iFeatKey,pFeat);

                     // calculate Contributing Area
                     //rInSite := Value.rAmount;
                     rContributingArea := pFeat^.targetarea;
                     if (pFeat^.targetarea > Value.rAmount) then
                        rContributingArea := Value.rAmount;

                     if (rContributingArea < 0) then
                        rContributingArea := 0;

                     FeatureIrrep.setValue(feature,@pRepr^.irr_feature);

                     {$IFDEF TRUNCATE_VULNERABILITY}
                     {pFeat.rVulnerability := Trunc(pFeat.rVulnerability);
                     if (pFeat.rVulnerability > 5) then
                        pFeat.rVulnerability := 5;
                     if (pFeat.rVulnerability < 0) then
                        pFeat.rVulnerability := 0;}
                     {$ENDIF}

                     rWeight := CalcSumWeightVariations(lSite,feature,0,
                                pRepr^.irr_feature,
                                {$IFDEF SPARSE_MATRIX}
                                Value.rAmount,
                                {$ELSE}
                                pSite^.featurearea[feature],
                                {$ENDIF}
                                pSite^.area,
                                pFeat^.reservedarea,
                                pFeat^.rDeferredArea,
                                pFeat^.rCutOff,
                                pFeat^.rFloatVulnerability,
                                Trunc(pFeat^.rVulnerability),
                                False,False,False,
                                fDebugWeightings);

                     pSite^.rSummedIrr := pSite^.rSummedIrr + rWeight;

                     pSite^.rSummedIrrVuln2 := pSite^.rSummedIrrVuln2 + (pFeat^.rFloatVulnerability * pRepr^.irr_feature);

                     if ControlRes^.fCalculateBobsExtraVariations then
                        CalculateBobsExtraSumWeightVariations(lSite,
                                                              Value.iFeatKey,
                                                              pFeat^.iOrdinalClass,
                                                              pRepr^.irr_feature,
                                                              Value.rAmount,
                                                              pSite^.area,
                                                              pFeat^.reservedarea,
                                                              pFeat^.rDeferredArea,
                                                              pFeat^.rCutOff,
                                                              pFeat^.rInitialAvailableTarget,
                                                              pFeat^.rFloatVulnerability,
                                                              Trunc(pFeat^.rVulnerability),
                                                              False,False,False,
                                                              fDebugWeightings,
                                                              ControlRes^.iScalingType);

                     {$IFDEF SPARSE_MATRIX}
                     if (Value.iFeatKey <= iPCUsedCutOff) then
                     {$ELSE}
                     if (pSite^.feature[feature] <= iPCUsedCutOff) then
                     {$ENDIF}
                     begin
                          SumProduct[11] := SumProduct[11] + (pRepr^.irr_feature * rContributingArea);
                          rSumContributingArea := rSumContributingArea + rContributingArea;
                          {$IFDEF DEBUG_WAVIRR}
                          // site key, feat key, feat irr, contrib area, sum product, sum contrib area
                          writeln(WavirrFile,IntToStr(pSite^.iKey) + ',' +
                                             IntToStr(Value.iFeatKey) + ',' +
                                             FloatToStr(pRepr^.irr_feature) + ',' +
                                             FloatToStr(rContributingArea) + ',' +
                                             FloatToStr(SumProduct[11]) + ',' +
                                             FloatToStr(rSumContributingArea));
                          {$ENDIF}
                     end;

                     total_repr_include[11]:=total_repr_include[11]*pRepr^.repr_include;
                     total_repr_exclude[11]:=total_repr_exclude[11]*pRepr^.repr_exclude;
                     total_repr_incexc[11]:=total_repr_incexc[11]*pRepr^.repr_incexc;
                end;
           end;

           {$IFDEF SUMIRR_IS_TV}
           // make sumirr weighted by target and vuln by default
           WeightedSumirr.rtnValue(lSite,@WS);
           pSite^.rSummedIrr := WS.r_tv;
           {$ENDIF}

           if (pSite^.area > 0) then
           begin
                pSite^.rWAVIRR := SumProduct[11] / pSite^.area;
                pSite^.rPCUSED := rSumContributingArea / pSite^.area * 100;
           end
           else
           begin
                pSite^.rWAVIRR := 0;
                pSite^.rPCUSED := 0;
           end;


           if (pSite^.rWAVIRR > 1) then
              pSite^.rWAVIRR := 1;

           if (total_repr_include[11] + total_repr_exclude[11]) = 0 then
              rSiteIrreplaceability:=0
           else
               rSiteIrreplaceability:=((total_repr_include[11]-total_repr_incexc[11])*wt_include)
                     /(total_repr_include[11]*wt_include+total_repr_exclude[11]*wt_exclude);

           // test if combination size is too large for feature(s) at this site
           if pSite^.fSiteHasUse
           and (pSite^.rSummedIrr = 0) then
               // this the trigger for the condition where combination size is too LARGE for feature(s) at this site
               fSiteBreakExecution := True;
               // Break Execution and recalculate combination size;

           if (pSite^.rSummedIrr > rMaxAvFlSumirr) then
              rMaxAvFlSumirr := pSite^.rSummedIrr;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in Irreplaceability of Available or Flagged site ' +
                         IntToStr(pSite^.iKey),
                         mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;
   end;

   procedure IrrepNeMaPd;
   label
        skip4,skip5,skip6;
   var
      feature, iCount : integer;
   begin
        try
           {we need to calculate irreplaceability of R1, R2 and Pd sites.
            frame the target as if this site was available,
            ie. target = C.E.T - area at site}

{if (lSite = 1)
and (iMinsetIterationCount > 9) then
    MessageDlg('IrrepNeMaPd site 1 at itn ' + IntToStr(iMinsetIterationCount),
               mtInformation,[mbOk],0);}

           for feature:=1 to pSite^.richness do
           begin
                fPartialOn := True;
                if (pSite^.status = Pd)then
                begin
                     SparsePartial.rtnValue(pSite^.iOffset + feature,@fReserved);
                     if fReserved then
                        fPartialOn := False;
                end;

                FeatureAmount.rtnValue(pSite^.iOffset + feature,@Value);
                area_site := Value.rAmount;
                area2_site:=sqr(area_site);

                FeatArr.rtnValue(Value.iFeatKey,pFeat);

                {set values as if this site is available for calculation of irreplaceability}
                rDeducedTarget := pFeat^.targetarea + Value.rAmount;
                rDeducedSumArea := pFeat^.rCurrentSumArea + Value.rAmount;
                rDeducedAreaSqr := pFeat^.rCurrentAreaSqr + Sqr(Value.rAmount);
                iDeducedAvailCount := iAvailableSiteCount + 1;
                iDeducedCombsize := combsize.iActiveCombinationSize + 1;
                try
                   if (iDeducedAvailCount = 1) then
                      rDeducedmult := 0
                   else
                       rDeducedmult:=iDeducedAvailCount/(iDeducedAvailCount-1);
                except
                      rDeducedmult := 0;
                end;
                try
                   if (iDeducedAvailCount = 0) then
                      rDeducedwt_include := 0
                   else
                       rDeducedwt_include:=iDeducedCombsize/iDeducedAvailCount;
                except
                      rDeducedwt_include := 0;
                end;
                rDeducedwt_exclude:=1-rDeducedwt_include;


                if (not fPartialOn)
                or (rDeducedTarget <= 0)
                or (Value.rAmount <= 0) then
                begin
                     pRepr^.repr_incexc := 1{0}; {? or 1}
                     pRepr^.repr_exclude := 1;
                     pRepr^.repr_include := 1;
                     sumarea := 0;
                     sumarea2 := 0;
                     mean_site := 0;
                     goto skip6;
                end;

                pSite^.fSiteHasUse := True;

                sumarea := (rDeducedSumArea - area_site)*rDeducedmult;
                sumarea2 := (rDeducedAreaSqr - area2_site)*rDeducedmult;
                mean_site := sumarea/iDeducedAvailCount;
                try
                   if ((iDeducedCombsize-1) > (iDeducedAvailCount-1)/2.0)
                   and (iDeducedAvailCount > iDeducedCombsize) then
                      combadj := sqrt((iDeducedAvailCount-1)-(iDeducedCombsize-1))/(iDeducedCombsize-1)
                   else
                       combadj:=sqrt(iDeducedCombsize-1)/(iDeducedCombsize-1);
                except
                      combadj := 0;
                end;

                rTmp := (sumarea2-(sqr(sumarea)/iDeducedAvailCount))/(iDeducedAvailCount);
                if (rTmp >= 0) then
                   rTmp := sqrt(rTmp)
                else
                    rTmp := 0;
                sd := rTmp * combadj;

                if (rDeducedSumArea - area_site) < rDeducedTarget then
                begin
                     pRepr^.repr_incexc:=0;
                     goto skip4;
                end;
                mean_target:=rDeducedTarget/(iDeducedCombsize-1);
                if sd < 0.00000000001 then
                begin
                     if mean_site < mean_target then
                        pRepr^.repr_incexc:=0
                     else
                         pRepr^.repr_incexc:=1;
                end
                else
                begin
                     z:=(mean_target-mean_site)/sd;
                     pRepr^.repr_incexc:=zprob(z);
                end;
         skip4:
                if area_site >= rDeducedTarget then
                begin
                     pRepr^.repr_include:=1;
                     goto skip5;
                end;
                try
                   mean_target:=(rDeducedTarget-area_site)/(iDeducedCombsize-1);
                except
                      mean_target:=(rDeducedTarget-area_site);
                end;
                if sd < 0.00000000001 then
                begin
                     if mean_site < mean_target then
                        pRepr^.repr_include:=0
                     else
                         pRepr^.repr_include:=1;
                end
                else
                begin
                     z:=(mean_target-mean_site)/sd;
                     pRepr^.repr_include:=zprob(z);
                end;
         skip5:
                if ((iDeducedCombsize) > (iDeducedAvailCount-1)/2.0)
                and (iDeducedCombsize < (iDeducedAvailCount - 1)) then
                    combadj:=sqrt((iDeducedAvailCount-1)-(iDeducedCombsize))/(iDeducedCombsize)
                else
                    combadj:=sqrt(iDeducedCombsize)/(iDeducedCombsize);

                rTmp := (sumarea2-(sqr(sumarea)/iDeducedAvailCount))/(iDeducedAvailCount);
                if (rTmp >= 0) then
                   rTmp := sqrt(rTmp)
                else
                    rTmp := 0;
                sd := rTmp * combadj;

                if (rDeducedSumArea - area_site) < rDeducedTarget then
                begin
                     pRepr^.repr_exclude:=0;
                     goto skip6;
                end;
                mean_target:=rDeducedTarget/(iDeducedCombsize);
                if sd < 0.00000000001 then
                begin
                     if mean_site < mean_target then
                        pRepr^.repr_exclude:=0
                     else
                         pRepr^.repr_exclude:=1;
                end
                else
                begin
                     z:=(mean_target-mean_site)/sd;
                     pRepr^.repr_exclude:=zprob(z);
                end;
        skip6:
                {if (pRepr^.repr_include = 0)
                and (pRepr^.repr_exclude = 0) then
                    fBreakExecution := True;}
                    // Break Execution and recalculate combination size

                if (pRepr^.repr_include = 0)
                {$IFDEF SPARSE_MATRIX}
                and (Value.rAmount > 0) then
                {$ELSE}
                and (pSite^.featurearea[feature] > 0) then
                {$ENDIF}
                    pRepr^.repr_include:=1;
                if (pRepr^.repr_include + pRepr^.repr_exclude) = 0 then
                   pRepr^.irr_feature:=0
                else
                    pRepr^.irr_feature:=((pRepr^.repr_include-pRepr^.repr_incexc)*rDeducedwt_include)
                       /(pRepr^.repr_include*rDeducedwt_include+pRepr^.repr_exclude*rDeducedwt_exclude);

                LocalRepr.setValue(Value.iFeatKey,pRepr);

                if fDebug then
                begin
                     write(validatefile,IntToStr(pFeat^.code) + ',' + FloatToStr(rDeducedTarget) + ',' +
                           FloatToStr(area_site) + ',' + FloatToStr(area2_site) + ',' + FloatToStr(sumarea) + ',' +
                           FloatToStr(sumarea2) + ',');
                     writeln(validatefile,FloatToStr(mean_site) + ',' + FloatToStr(pRepr^.irr_feature) + ',' + FloatToStr(pRepr^.repr_include) + ',' +
                             FloatToStr(pRepr^.repr_exclude) + ',' + FloatToStr(pRepr^.repr_incexc) + ',' + IntToStr(iDeducedAvailCount));

                end;

                if fComprehensiveDebug then
                begin
                     // need to check if we are to include this site & feature
                     // fValidateSite, fValidateFeature
                     ValidateSite.rtnValue(lSite,@fValidateSite);
                     ValidateFeature.rtnValue(pFeat^.code,@fValidateFeature);

                     if fValidateSite
                     and fValidateFeature then
                     begin
                          {   try
                                sSumArea := FloatToStr(sumarea);
                             except
                                   sSumArea := '';
                             end;
                             try
                                sSumArea2 := FloatToStr(sumarea2);
                             except
                                   sSumArea2 := '';
                             end;
                             try
                                smean_site := FloatToStr(mean_site);
                             except
                                   smean_site := '';
                             end;
                          write(comprehensivefile,IntToStr(pFeat^.code) + ',' + FloatToStr(pFeat^.targetarea) + ',' +
                                FloatToStr(area_site) + ',' + FloatToStr(area2_site) + ',' + sSumArea + ',' +
                                sSumArea2 + ',');
                          writeln(comprehensivefile,smean_site + ',' + FloatToStr(pRepr^.irr_feature) + ',' + FloatToStr(pRepr^.repr_include) + ',' +
                                  FloatToStr(pRepr^.repr_exclude) + ',' + FloatToStr(pRepr^.repr_incexc) + ',' + IntToStr(iAvailableSiteCount));}

                         write(comprehensivefile,IntToStr(pFeat^.code) + ',' + FloatToStr(rDeducedTarget) + ',' +
                           FloatToStr(area_site) + ',' + FloatToStr(area2_site) + ',' + FloatToStr(sumarea) + ',' +
                           FloatToStr(sumarea2) + ',');
                         writeln(comprehensivefile,FloatToStr(mean_site) + ',' + FloatToStr(pRepr^.irr_feature) + ',' + FloatToStr(pRepr^.repr_include) + ',' +
                             FloatToStr(pRepr^.repr_exclude) + ',' + FloatToStr(pRepr^.repr_incexc) + ',' + IntToStr(iDeducedAvailCount));
                         (*
                         write(comprehensivefile,IntToStr(lSite) + ',' +
                                                 IntToStr(pFeat^.code) + ',');

                         if fIncludeFeatureArea then
                            write(comprehensivefile,FloatToStr(area_site) + ',');

                         if fPartialOn then
                            write(comprehensivefile,'1,')
                         else
                             write(comprehensivefile,'0,');

                         write(comprehensivefile,FloatToStr(pRepr^.irr_feature) + ',');

                         if (rDeducedTarget > 0) then
                            writeln(comprehensivefile,FloatToStr(area_site/rDeducedTarget*100))
                         else
                             writeln(comprehensivefile,'0');*)
                     end;
                end;
           end;

           rSumContributingArea := 0;

           if ControlRes^.fFeatureClassesApplied then
           begin
                {initialise variables for use}
                for iCount := 1 to 11 do
                begin
                     total_repr_include[iCount]:=1;
                     total_repr_exclude[iCount]:=1;
                     total_repr_incexc[iCount]:=1;
                     SumProduct[iCount] := 0;
                end;
                for iCount := 1 to 10 do
                begin
                     pSite^.rSubsetIrr[iCount] := 0;
                     pSite^.rSubsetSum[iCount] := 0;
                end;
                for iCount := 1 to 5 do
                begin
                     pSite^.rSubsetWav[iCount] := 0;
                     pSite^.rSubsetPCUsed[iCount] := 0;
                     ContributingArea[iCount] := 0;
                end;

                {traverse features adding up values}
                if (pSite^.richness > 0) then
                for feature:=1 to pSite^.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffset + feature,@Value);
                     LocalRepr.rtnValue(Value.iFeatKey,pRepr);
                     FeatArr.rtnValue(Value.iFeatKey,pFeat);

                     {$IFDEF SPARSE_MATRIX_2}
                     FeatureIrrep.setValue(feature,@pRepr^.irr_feature);
                     {$ELSE}
                     FeatureIrrep[feature] := pRepr^.irr_feature;
                     {$ENDIF}

                     {$IFDEF TRUNCATE_VULNERABILITY}
                     {pFeat.rVulnerability := Trunc(pFeat.rVulnerability);
                     if (pFeat.rVulnerability > 5) then
                        pFeat.rVulnerability := 5;
                     if (pFeat.rVulnerability < 0) then
                        pFeat.rVulnerability := 0;}
                     {$ENDIF}

                     rWeight := CalcSumWeightVariations(lSite,feature,pFeat^.iOrdinalClass,
                           pRepr^.irr_feature,
                           {$IFDEF SPARSE_MATRIX}
                           Value.rAmount,
                           {$ELSE}
                           pSite^.featurearea[feature],
                           {$ENDIF}
                           pSite^.area,
                           pFeat^.reservedarea,
                           pFeat^.rDeferredArea,
                           pFeat^.rCutOff,
                           pFeat^.rFloatVulnerability,
                           Trunc(pFeat^.rVulnerability),
                           False,False,False,
                           fDebugWeightings);

                     pSite^.rSummedIrr := pSite^.rSummedIrr + rWeight;

                     if ControlRes^.fCalculateBobsExtraVariations then
                        CalculateBobsExtraSumWeightVariations(lSite,
                                                              Value.iFeatKey,
                                                              pFeat^.iOrdinalClass,
                                                              pRepr^.irr_feature,
                                                              Value.rAmount,
                                                              pSite^.area,
                                                              pFeat^.reservedarea,
                                                              pFeat^.rDeferredArea,
                                                              pFeat^.rCutOff,
                                                              pFeat^.rInitialAvailableTarget,
                                                              pFeat^.rFloatVulnerability,
                                                              Trunc(pFeat^.rVulnerability),
                                                              False,False,False,
                                                              fDebugWeightings,
                                                              ControlRes^.iScalingType);

                     rDeducedTarget := pFeat^.targetarea + Value.rAmount;
                     rContributingArea := rDeducedTarget; //pFeat^.targetarea;
                     if (rDeducedTarget > Value.rAmount) then
                        rContributingArea := Value.rAmount;
                     if (rContributingArea < 0) then
                        rContributingArea := 0;

                     {$IFDEF SPARSE_MATRIX}
                     if (Value.iFeatKey <= iPCUsedCutOff) then
                     {$ELSE}
                     if (pSite^.feature[feature] <= iPCUsedCutOff) then
                     {$ENDIF}
                     begin
                          SumProduct[11] := SumProduct[11] + (pRepr^.irr_feature * rContributingArea);
                          rSumContributingArea := rSumContributingArea + rContributingArea;
                     end;

                     total_repr_include[11]:=total_repr_include[11]*pRepr^.repr_include;
                     total_repr_exclude[11]:=total_repr_exclude[11]*pRepr^.repr_exclude;
                     total_repr_incexc[11]:=total_repr_incexc[11]*pRepr^.repr_incexc;

                     if (pFeat^.iOrdinalClass > 0) then
                     begin
                          // need to calculate 7 different weightings for this feature
                          pSite^.rSubsetSum[pFeat^.iOrdinalClass] := pSite^.rSubsetSum[pFeat^.iOrdinalClass] +
                                                                     rWeight;
                          total_repr_include[pFeat^.iOrdinalClass]:=total_repr_include[pFeat^.iOrdinalClass]*pRepr^.repr_include;
                          total_repr_exclude[pFeat^.iOrdinalClass]:=total_repr_exclude[pFeat^.iOrdinalClass]*pRepr^.repr_exclude;
                          total_repr_incexc[pFeat^.iOrdinalClass]:=total_repr_incexc[pFeat^.iOrdinalClass]*pRepr^.repr_incexc;
                          if (pFeat^.iOrdinalClass <= 5) then
                          begin
                               ContributingArea[pFeat^.iOrdinalClass] := ContributingArea[pFeat^.iOrdinalClass] + rContributingArea;
                               SumProduct[pFeat^.iOrdinalClass] := SumProduct[pFeat^.iOrdinalClass] + (pRepr^.irr_feature * rContributingArea);
                          end;
                     end;
                end;

                {calculate Wavirr for 5 feature subsets}
                for iCount := 1 to 5 do
                    if (pSite^.area > 0) then
                    begin
                         pSite^.rSubsetWav[iCount] := SumProduct[iCount] / pSite^.area;
                         pSite^.rSubsetPCUsed[iCount] := ContributingArea[iCount] / pSite^.area * 100;
                    end
                    else
                    begin
                         pSite^.rSubsetWav[iCount] := 0;
                         pSite^.rSubsetPCUsed[iCount] := 0;
                    end;

                {calculate Irr for 10 feature subsets}
                for iCount := 1 to 10 do
                    if (total_repr_include[iCount] + total_repr_exclude[iCount]) = 0 then
                       pSite^.rSubsetIrr[iCount]:=0
                    else
                        pSite^.rSubsetIrr[iCount]:=((total_repr_include[iCount]-total_repr_incexc[iCount])*rDeducedwt_include)
                                                   /(total_repr_include[iCount]*rDeducedwt_include+total_repr_exclude[iCount]*rDeducedwt_exclude);
           end
           else
           begin
                total_repr_include[11]:=1;
                total_repr_exclude[11]:=1;
                total_repr_incexc[11]:=1;

                SumProduct[11] := 0;

                if (pSite^.richness > 0) then
                for feature:=1 to pSite^.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffset + feature,@Value);
                     LocalRepr.rtnValue(Value.iFeatKey,pRepr);
                     FeatArr.rtnValue(Value.iFeatKey,pFeat);

                     {record irreplaceability of this feature for return as var parameter to calling function}
                     FeatureIrrep.setValue(feature,@pRepr^.irr_feature);

                     {$IFDEF TRUNCATE_VULNERABILITY}
                     {pFeat.rVulnerability := Trunc(pFeat.rVulnerability);
                     if (pFeat.rVulnerability > 5) then
                        pFeat.rVulnerability := 5;
                     if (pFeat.rVulnerability < 0) then
                        pFeat.rVulnerability := 0;}
                     {$ENDIF}

                     rWeight := CalcSumWeightVariations(lSite,feature,0,
                                      pRepr^.irr_feature,
                                      Value.rAmount,
                                      pSite^.area,
                                      pFeat^.reservedarea,
                                      pFeat^.rDeferredArea,
                                      pFeat^.rCutOff,
                                      pFeat^.rFloatVulnerability,
                                      Trunc(pFeat^.rVulnerability),
                                      False,False,False,
                                      fDebugWeightings);
                     pSite^.rSummedIrr := pSite^.rSummedIrr + rWeight;

                     if ControlRes^.fCalculateBobsExtraVariations then
                        CalculateBobsExtraSumWeightVariations(lSite,
                                                              Value.iFeatKey,
                                                              pFeat^.iOrdinalClass,
                                                              pRepr^.irr_feature,
                                                              Value.rAmount,
                                                              pSite^.area,
                                                              pFeat^.reservedarea,
                                                              pFeat^.rDeferredArea,
                                                              pFeat^.rCutOff,
                                                              pFeat^.rInitialAvailableTarget,
                                                              pFeat^.rFloatVulnerability,
                                                              Trunc(pFeat^.rVulnerability),
                                                              False,False,False,
                                                              fDebugWeightings,
                                                              ControlRes^.iScalingType);

                     rDeducedTarget := pFeat^.targetarea + Value.rAmount;
                     rContributingArea := rDeducedTarget;
                     if (rDeducedTarget > Value.rAmount) then
                        rContributingArea := Value.rAmount;
                     if (rContributingArea < 0) then
                        rContributingArea := 0;

                     if (Value.iFeatKey <= iPCUsedCutOff) then
                     begin
                          SumProduct[11] := SumProduct[11] + (pRepr^.irr_feature * rContributingArea);
                          rSumContributingArea := rSumContributingArea + rContributingArea;
                     end;

                     total_repr_include[11]:=total_repr_include[11]*pRepr^.repr_include;
                     total_repr_exclude[11]:=total_repr_exclude[11]*pRepr^.repr_exclude;
                     total_repr_incexc[11]:=total_repr_incexc[11]*pRepr^.repr_incexc;
                end;

           end;

           if (pSite^.area > 0) then
           begin
                pSite^.rWAVIRR := SumProduct[11] / pSite^.area;
                pSite^.rPCUSED := rSumContributingArea / pSite^.area * 100;
           end
           else
           begin
                pSite^.rWAVIRR := 0;
                pSite^.rPCUSED := 0;
           end;

           if (pSite^.rWAVIRR > 1) then
              pSite^.rWAVIRR := 1;

           if (total_repr_include[11] + total_repr_exclude[11]) = 0 then
              rSiteIrreplaceability:=0
           else
               try
                  rSiteIrreplaceability:=((total_repr_include[11]-total_repr_incexc[11])*rDeducedwt_include)
                     /(total_repr_include[11]*rDeducedwt_include+total_repr_exclude[11]*rDeducedwt_exclude);
               except
                     rSiteIrreplaceability:=0;
               end;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in Irreplaceability of R1, R2 or Pd site ' +
                         IntToStr(pSite^.iKey),
                         mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;
   end;

begin
     InitIrrep;

     if ((pSite^.status = Av)
         or (pSite^.status = Fl))
     and (pSite^.richness > 0) then
     begin
          {calculate irreplaceability of available/flagged site}
          IrrepAvFl;
     end
     else
     begin
          {$IFDEF CALC_DEF_IRR}
          if ((pSite^.status = _R1)
              or (pSite^.status = _R2)
              or (pSite^.status = _R3)
              or (pSite^.status = _R4)
              or (pSite^.status = _R5)
              or (pSite^.status = Pd))
          and (pSite^.richness > 0) then
          begin
               {calculate irreplaceability of deferred or partly deferred site}
               IrrepNeMaPd;
          end
          else
              rSiteIrreplaceability := 0;
              {this site is Ex, Ig or Re, so set its value to zero}
          {$ELSE}
          rSiteIrreplaceability := 0;
          {$ENDIF}
     end;

     predict_sf4 := rSiteIrreplaceability;

     FreeIrrep;
end;

{----------------------------------------------------------------------------}


function click_predict_sf4 (lSite: longint) : Array_T;
var
   iCount, iRestOfSites, iR : integer;
   FeatureIrrep : Array_T;
   rValue : extended;
   fBreakExecution : boolean;
begin
     iAvailableSiteCount := ControlForm.Available.Items.Count +
                    ControlForm.Flagged.Items.Count;

     iR := ControlForm.Partial.Items.Count +
           ControlForm.R1.Items.Count +
           ControlForm.R2.Items.Count +
           ControlForm.R3.Items.Count +
           ControlForm.R4.Items.Count +
           ControlForm.R5.Items.Count;
     iRestOfSites := iR +
                     ControlForm.Excluded.Items.Count;

     AdjustCombinationSizeForReserves(ControlRes^.LastCombinationSizeCondition);
     init_irr_variables(combsize.iActiveCombinationSize,iAvailableSiteCount);

     rValue := 0;
     FeatureIrrep := Array_t.Create;
     FeatureIrrep.init(SizeOf(extended),iFeatureCount);
     for iCount := 1 to iFeatureCount do
         FeatureIrrep.setValue(iCount,@rValue);

     predict_sf4(lSite,FeatureIrrep,ControlRes^.fValidateIrreplaceability,
                 fBreakExecution,False,False,'',False);

     Result := Array_t.Create;
     Result.init(SizeOf(extended),iFeatureCount);
     for iCount := 1 to iFeatureCount do
     begin
          FeatureIrrep.rtnValue(iCount,@rValue);
          Result.setValue(iCount,@rValue);
     end;
     FeatureIrrep.Destroy;
end;

{----------------------------------------------------------------------------}

end.
