unit hotspots_nocomplementarity_areaindices;

interface

uses
    ds;

var
   fUseHotspotsNoComplValues,
   fNoComplementarityRichnessArrBuilt : boolean;

procedure ExecuteIrrepNoComplementarity(const iIc : integer;
                                        const {fComprehensiveDebug,}
                                              fIncludeFeatureArea,
                                              fUserUpdates,
                                              fComplementarity : boolean;
                                        {const sDebugFileName : string;}
                                        const fCalculateArithmeticVariables,
                                              fRecalculatePresenceRules : boolean);
procedure WriteMsgToFile(const sFile, sMsg : string);

implementation

uses
    sysutils, forms, controls, dialogs, FileCtrl,
    global, control, sf_irrep, in_order, Em_newu1,
    mthread, trpt, rules, validate, destruct,
    getuservalidatefile;

var
   NoComplementarityRichnessArr : Array_t;
   iNoComplAvailableSiteCount : integer;


procedure ReportNoComplementarityTarget(const sReportFile : string);
var
   iFeature : integer;
   pFeat : featureoccurrencepointer;
   ReportFile : TextFile;
   rDestructArea, rTargetArea : Extended;
begin
     try
        new(pFeat);
        assignfile(ReportFile,sReportFile);
        rewrite(ReportFile);
        writeln(ReportFile,'FeatureKey,FeatureTarget');

        for iFeature := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iFeature,pFeat);

             // this is 'Initial Achievable Target' in the feature report
             //rTargetArea := pFeat^.rTrimmedTarget;

             // 'Initial Available Target'
             rTargetArea := pFeat^.rInitialAvailableTarget;

             // if destruction is on, we may need to reduce this target
             if (iDestructionYear > -1) then
             begin
                  DestructArea.rtnValue(iFeature,@rDestructArea);
                  if (rTargetArea > (pFeat^.rInitialAvailable - rDestructArea)) then
                     rTargetArea := pFeat^.rInitialAvailable - rDestructArea;
             end;
             if (rTargetArea < 0) then
                rTargetArea := 0;

             writeln(ReportFile,IntToStr(iFeature) +
                                ',' +
                                FloatToStr(rTargetArea));
        end;

        dispose(pFeat);
        closefile(ReportFile);

     except
     end;
end;


//--------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------
// 050700
// Calculates irreplaceability & summed irreplaceability for a site
// using the hotspots no complementarity method.
// Restricted Av or Fl sites.
//
// doesn't calculate :
//   subsets
//   weightings
procedure predict_sf4_hotspots_no_complementarity(const lSite: longint;
                                                  var FeatureIrrep : Array_T;
                                                  const fDebug, fComprehensiveDebug, fIncludeFeatureArea : boolean;
                                                  var fBreakExecution : boolean;
                                                  const sComprehensiveDebugFile : string;
                                                  var rIrreplaceability,
                                                      rSummedIrreplaceability,
                                                      rWeightedPercentTarget,
                                                      rMaxRarity,
                                                      rRichness,
                                                      rSummedRarity : extended;
                                                  const fCalculateArithmeticVariables,
                                                        fRecalculatePresenceRules : boolean);

// also calculate MaxRar, Rich, SumRar
var
   mean_site,sd,z,area_site,area2_site,sumarea,sumarea2,mean_target,zmin,
   combadj : extended;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   pRepr : ReprPointer;
   fPartialOn, fReserved : boolean;
   iFeatureRichness, iTest, feature : integer;
   Value : ValueFile_T;
   DebugFile : TextFile;
   validatefile, comprehensivefile : text;
   rDestructArea,
   rRarityOfFeature,
   rFeatureContrib,
   rTotal_repr_include,
   rTotal_repr_exclude,
   rTotal_repr_incexc,
   rContributingArea,
   rSiteIrreplaceability,
   rSumProduct,
   rTmp,
   rSumContributingArea,
   rWeight,
   rTargetArea : extended;

   procedure InitIrrep;
   var
      iInit : integer;
   begin
        fBreakExecution := False;
        iTest := ControlForm.R1.Items.Count +
                 ControlForm.R2.Items.Count +
                 ControlForm.R3.Items.Count +
                 ControlForm.R4.Items.Count +
                 ControlForm.R5.Items.Count +
                 ControlForm.Partial.Items.Count + ControlForm.Excluded.Items.Count;

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
        rWeightedPercentTarget := 0;
        if fRecalculatePresenceRules then
        begin
             rMaxRarity := 0;
             rRichness := 0;
             rSummedRarity := 0;
        end;

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

        if fComprehensiveDebug
        and ValidateThisIteration(iMinsetIterationCount) then
        begin
             assignfile(comprehensivefile,sComprehensiveDebugFile);
             append(comprehensivefile);
        end;
   end;

   procedure FreeIrrep;
   begin
        // do not set the site array value as we do not want to update it with this operation
        pSite^.rIrreplaceability := rSiteIrreplaceability;
        SiteArr.setValue(lSite,pSite);

        dispose(pSite);
        dispose(pFeat);
        dispose(pRepr);

        if fDebug then
           CloseFile(validatefile);

        if fComprehensiveDebug
        and ValidateThisIteration(iMinsetIterationCount) then
            closefile(comprehensivefile);
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
                FeatureAmount.rtnValue(pSite^.iOffset + feature,@Value);
                FeatArr.rtnValue(Value.iFeatKey,pFeat);

                // this is 'Initial Achievable Target' in the feature report
                //rTargetArea := pFeat^.rTrimmedTarget;

                // 'Initial Available Target'
                rTargetArea := pFeat^.rInitialAvailableTarget;

                // if destruction is on, we may need to reduce this target
                if (iDestructionYear > -1) then
                begin
                     DestructArea.rtnValue(Value.iFeatKey,@rDestructArea);
                     if (rTargetArea > (pFeat^.rInitialAvailable - rDestructArea)) then
                        rTargetArea := pFeat^.rInitialAvailable - rDestructArea;
                end;
                if (rTargetArea < 0) then
                   rTargetArea := 0;
                //if tgt > init av with destruct taken into account then
                //   tgt = init av ...
                //if tgt < 0 then
                //   tgt = 0

                if fCalculateArithmeticVariables
                and (Value.rAmount > 0)
                and (rTargetArea > 0) then
                begin
                     NoComplementarityRichnessArr.rtnValue(Value.iFeatKey,@iFeatureRichness);
                     // calculate the arithmetic variable rWeightedPercentTarget
                     if (rTargetArea > 0) then
                     begin
                          if (Value.rAmount > rTargetArea) then
                             rFeatureContrib := rTargetArea
                          else
                              rFeatureContrib := Value.rAmount;
                          rFeatureContrib := rFeatureContrib / rTargetArea * 100;
                     end
                     else
                         rFeatureContrib := 0;
                     if (iFeatureRichness > 0) then
                        rFeatureContrib := rFeatureContrib * 100 / iFeatureRichness
                     else
                         rFeatureContrib := 0;
                     rWeightedPercentTarget := rWeightedPercentTarget + rFeatureContrib;
                     if fRecalculatePresenceRules then
                     begin
                          // rMaxRarity
                          if (iFeatureRichness > 0) then
                             rRarityOfFeature := 100 / iFeatureRichness
                          else
                              rRarityOfFeature := 0;
                          if (rRarityOfFeature > rMaxRarity) then
                             rMaxRarity := rRarityOfFeature;
                          // rRichness
                          if (rTargetArea{pFeat^.targetarea} > 0) then
                             rRichness := rRichness + 1;
                          // rSummedRarity
                          if (iFeatureRichness > 0) then
                          begin
                               rRarityOfFeature := 100 / iFeatureRichness;
                               rSummedRarity := rSummedRarity + rRarityOfFeature;
                          end;
                     end;
                end;


                area_site := Value.rAmount;
                area2_site:=sqr(area_site);

                if (rTargetArea <= 0)
                or (Value.rAmount <= 0) then
                begin
                     pRepr^.repr_incexc := 1;
                     pRepr^.repr_exclude := 1;
                     pRepr^.repr_include := 1;
                     goto skip3;
                end;

                pSite^.fSiteHasUse := True;

                sumarea := (pFeat^.rSumArea - area_site)*mult;
                sumarea2 := (pFeat^.rAreaSqr - area2_site)*mult;
                mean_site := sumarea/iNoComplAvailableSiteCount;
                try
                   if ((combsize.iActiveNoComplCombinationSize-1) > (iNoComplAvailableSiteCount-1)/2.0)
                   // the following lines could cause an error if combsize = 1
                   and (iNoComplAvailableSiteCount > combsize.iActiveNoComplCombinationSize) then
                       combadj := sqrt((iNoComplAvailableSiteCount-1)-(combsize.iActiveNoComplCombinationSize-1))/(combsize.iActiveNoComplCombinationSize-1)
                   else
                       combadj:=sqrt(combsize.iActiveNoComplCombinationSize-1)/(combsize.iActiveNoComplCombinationSize-1);
                except
                      combadj := 0;
                end;

                rTmp := (sumarea2-(sqr(sumarea)/iNoComplAvailableSiteCount))/(iNoComplAvailableSiteCount);
                if (rTmp >= 0) then
                   rTmp := sqrt(rTmp)
                else
                    rTmp := 0;
                sd := rTmp * combadj;

                if (pFeat^.rSumArea - area_site) < rTargetArea then
                begin
                     pRepr^.repr_incexc:=0;
                     goto skip1;
                end;
                mean_target:=rTargetArea/(combsize.iActiveNoComplCombinationSize-1);
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
                if area_site >= rTargetArea then
                begin
                     pRepr^.repr_include:=1;
                     goto skip2;
                end;
                try
                   mean_target:=(rTargetArea-area_site)/(combsize.iActiveNoComplCombinationSize-1);
                except // this exception handler added for the case when combsize = 1, 1June00
                      mean_target := (rTargetArea-area_site);
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
                if ((combsize.iActiveNoComplCombinationSize) > (iNoComplAvailableSiteCount-1)/2.0)
                and ((iNoComplAvailableSiteCount-1) > combsize.iActiveNoComplCombinationSize) then
                    combadj:=sqrt((iNoComplAvailableSiteCount-1)-(combsize.iActiveNoComplCombinationSize))/(combsize.iActiveNoComplCombinationSize)
                else
                    combadj:=sqrt(combsize.iActiveNoComplCombinationSize)/(combsize.iActiveNoComplCombinationSize);

                rTmp := (sumarea2-(sqr(sumarea)/iNoComplAvailableSiteCount))/(iNoComplAvailableSiteCount);
                if (rTmp >= 0) then
                   rTmp := sqrt(rTmp)
                else
                    rTmp := 0;
                sd := rTmp * combadj;

                if (pFeat^.rSumArea - area_site) < rTargetArea then
                begin
                     pRepr^.repr_exclude:=0;
                     goto skip3;
                end;
                mean_target:=rTargetArea/(combsize.iActiveNoComplCombinationSize);
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
                     if (rTargetArea < pFeat^.rSumArea) then
                     begin
                          fBreakExecution := True;
                          // Break Execution and recalculate combination size
                          iBreakSiteKey := pSite^.iKey;
                          iBreakFeatureKey := Value.iFeatKey;
                     end;
                end;

                if (pRepr^.repr_include = 0)
                and (Value.rAmount > 0) then
                    pRepr^.repr_include:=1;
                if (pRepr^.repr_include + pRepr^.repr_exclude) = 0 then
                   pRepr^.irr_feature:=0
                else
                    pRepr^.irr_feature:=((pRepr^.repr_include-pRepr^.repr_incexc)*wt_include)
                       /(pRepr^.repr_include*wt_include+pRepr^.repr_exclude*wt_exclude);

                LocalRepr.setValue(Value.iFeatKey,pRepr);

                if fDebug then
                begin
                     write(validatefile,IntToStr(pFeat^.code) + ',' + FloatToStr(rTargetArea) + ',' +
                           FloatToStr(area_site) + ',' + FloatToStr(area2_site) + ',' + FloatToStr(sumarea) + ',' +
                           FloatToStr(sumarea2) + ',');
                     writeln(validatefile,FloatToStr(mean_site) + ',' + FloatToStr(pRepr^.irr_feature) + ',' + FloatToStr(pRepr^.repr_include) + ',' +
                             FloatToStr(pRepr^.repr_exclude) + ',' + FloatToStr(pRepr^.repr_incexc) + ',' + IntToStr(iNoComplAvailableSiteCount));

                end;

                if fComprehensiveDebug
                and ValidateThisIteration(iMinsetIterationCount) then
                begin
                     write(comprehensivefile,IntToStr(lSite) + ',' +
                                             IntToStr(pFeat^.code) + ',');

                     write(comprehensivefile,'0,' + FloatToStr(pRepr^.irr_feature) + ',');

                     if (rTargetArea > 0)
                     and (area_site > 0) then
                         write(comprehensivefile,FloatToStr(area_site/rTargetArea*100))
                     else
                         write(comprehensivefile,'0');

                     if fIncludeFeatureArea then
                        writeln(comprehensivefile,',' + FloatToStr(area_site));
                end;
           end;

           rSumContributingArea := 0;

           // feature classes are not applied
           rTotal_repr_include :=1;
           rTotal_repr_exclude :=1;
           rTotal_repr_incexc :=1;

           rSumProduct := 0;

           if (pSite^.richness > 0) then
           for feature:=1 to pSite^.richness do
           begin
                FeatureAmount.rtnValue(pSite^.iOffset + feature,@Value);
                LocalRepr.rtnValue(Value.iFeatKey,pRepr);
                FeatArr.rtnValue(Value.iFeatKey,pFeat);

                rTargetArea := pFeat^.rInitialAvailableTarget;

                rContributingArea := rTargetArea;
                if (rTargetArea > Value.rAmount) then
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

                pSite^.rSummedIrr := pSite^.rSummedIrr + pRepr^.irr_feature;

                if (Value.iFeatKey <= iPCUsedCutOff) then
                begin
                     rSumProduct := rSumProduct + (pRepr^.irr_feature * rContributingArea);
                     rSumContributingArea := rSumContributingArea + rContributingArea;
                end;

                rTotal_repr_include :=rTotal_repr_include *pRepr^.repr_include;
                rTotal_repr_exclude :=rTotal_repr_exclude *pRepr^.repr_exclude;
                rTotal_repr_incexc :=rTotal_repr_incexc *pRepr^.repr_incexc;
           end;

           if (pSite^.area > 0) then
           begin
                pSite^.rWAVIRR := rSumProduct / pSite^.area;
                pSite^.rPCUSED := rSumContributingArea / pSite^.area * 100;
           end
           else
           begin
                pSite^.rWAVIRR := 0;
                pSite^.rPCUSED := 0;
           end;

           if (pSite^.rWAVIRR > 1) then
              pSite^.rWAVIRR := 1;

           if (rTotal_repr_include + rTotal_repr_exclude) = 0 then
              rSiteIrreplaceability:=0
           else
               rSiteIrreplaceability:=((rTotal_repr_include-rTotal_repr_incexc)*wt_include)
                     /(rTotal_repr_include*wt_include+rTotal_repr_exclude*wt_exclude);

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
              MessageDlg('Exception in Hotspots No Complementarity Irreplaceability at site ' +
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
          rIrreplaceability := rSiteIrreplaceability;
          rSummedIrreplaceability := pSite^.rSummedIrr;
     end
     else
     begin
          rWeightedPercentTarget := 0;
          rIrreplaceability := 0;
          rSummedIrreplaceability := 0;
          // site is not av or fl, so set its value to zero

          if fComprehensiveDebug
          and ValidateThisIteration(iMinsetIterationCount) then
              for feature:=1 to pSite^.richness do
              begin
                   FeatureAmount.rtnValue(pSite^.iOffset + feature,@Value);
                   FeatArr.rtnValue(Value.iFeatKey,pFeat);

                   write(comprehensivefile,IntToStr(lSite) + ',' +
                                           IntToStr(pFeat^.code) + ',0,0,0');
                   if fIncludeFeatureArea then
                      write(comprehensivefile,',' + FloatToStr(Value.rAmount));
                   writeln(comprehensivefile);
              end;
     end;

     FreeIrrep;
end;

procedure MakeRichnessArr_NoCompl(const fDebug, fRecalculateComplementarity : boolean);
var
   iSite, iFeature, iSiteRichness, iFeatureIndex : integer;
   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   DbgFile : Text;
   Value : ValueFile_T;
   rTargetArea, rDestructArea : extended;
begin
     try
        if (not fNoComplementarityRichnessArrBuilt)
        or fRecalculateComplementarity {one or more cells (features at a site) destroyed} then
        begin
             fNoComplementarityRichnessArrBuilt := True;

             NoComplementarityRichnessArr := Array_T.create;
             NoComplementarityRichnessArr.init(SizeOf(integer),iFeatureCount);
             iSiteRichness := 0;
             for iFeature := 1 to iFeatureCount do
                 NoComplementarityRichnessArr.setValue(iFeature,@iSiteRichness);

             new(pSite);
             new(pFeature);

             for iSite := 1 to iSiteCount do
             begin
                  SiteArr.rtnValue(iSite,pSite);

                  if (pSite^.status <> Ig)
                  and (pSite^.status <> Re)
                  and (pSite^.richness > 0) then
                      for iFeature := 1 to pSite.richness do
                      begin
                           FeatureAmount.rtnValue(pSite^.iOffset + iFeature,@Value);
                           iFeatureIndex := Value.iFeatKey;
                           FeatArr.rtnValue(iFeatureIndex,pFeature);

                           rTargetArea := pFeature^.rInitialAvailableTarget;
                           if (iDestructionYear > -1) then
                           begin
                                DestructArea.rtnValue(Value.iFeatKey,@rDestructArea);
                                if (rTargetArea > (pFeature^.rInitialAvailable - rDestructArea)) then
                                   rTargetArea := pFeature^.rInitialAvailable - rDestructArea;
                           end;

                           if not pFeature^.fRestrict
                           and (rTargetArea > 0)
                           and (Value.rAmount > 0) then
                           begin
                                NoComplementarityRichnessArr.rtnValue(iFeatureIndex,@iSiteRichness);
                                Inc(iSiteRichness);
                                NoComplementarityRichnessArr.setValue(iFeatureIndex,@iSiteRichness);
                           end;
                      end;
             end;

             dispose(pSite);
             dispose(pFeature);

             if fDebug then
             begin
                  ForceDirectories(ControlRes^.sWorkingDirectory +
                                   '\' + IntToStr(iMinsetIterationCount));
                  assignfile(DbgFile,ControlRes^.sWorkingDirectory +
                                     '\' + IntToStr(iMinsetIterationCount) +
                                      '\BuildRichnessArr_no_compl.csv');
                  rewrite(DbgFile);
                  writeln(DbgFile,'FeatureIdx,Richness');
                  for iFeature := 1 to iFeatureCount do
                  begin
                       NoComplementarityRichnessArr.rtnValue(iFeature,@iSiteRichness);
                       writeln(DbgFile,IntToStr(iFeature) + ',' + IntToStr(iSiteRichness));
                  end;

                  closefile(DbgFile);
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in MakeRichnessArr_NoCompl',mtError,[mbOk],0);
     end;
end;

procedure ReportNoComplSites(const sReportFile : string);
var
   ReportFile : TextFile;
   HAI : Hotspots_Area_Indices_T;
   pSite : sitepointer;
   iCount : integer;
begin
     assignfile(ReportFile,sReportFile);
     rewrite(ReportFile);
     writeln(ReportFile,'SiteKey,Irrepl,Sumirr,Weighted%Target,MaxRarity,Richness,SummedRarity');
     new(pSite);

     for iCount := 1 to iSiteCount do
     begin
          SiteArr.rtnValue(iCount,pSite);
          Hotspots_Area_Indices.rtnValue(iCount,@HAI);
          writeln(ReportFile,IntToStr(pSite^.iKey) + ',' +
                             FloatToStr(HAI.rIrreplaceability) + ',' +
                             FloatToStr(HAI.rSumirr) + ',' +
                             FloatToStr(HAI.rWeightedPercentTarget) + ',' +
                             FloatToStr(HAI.rMaxRarity) + ',' +
                             FloatToStr(HAI.rRichness) + ',' +
                             FloatToStr(HAI.rSummedRarity));
     end;

     closefile(ReportFile);
     dispose(pSite);
end;


procedure SetNoComplCombinationSize;
// set no complementarity combination size
begin
     if ControlRes^.fCustomCombSize then
        combsize.iActiveNoComplCombinationSize := combsize.iCustomCombinationSize
     else
     case ControlRes^.LastCombinationSizeCondition of
          OverrideChange, Startup, ExclusionChange, TargetChange, UserLoadLog :
            combsize.iActiveNoComplCombinationSize := combsize.iSelectedCombinationSize;
     else
         combsize.iActiveNoComplCombinationSize := combsize.iCurrentSelectedCombinationSize;
         // MinsetLoadLog, TriggerTargetCannotBeMet, TriggerZeroAvSumirr
     end;

     if (combsize.iActiveNoComplCombinationSize < 2) then
        combsize.iActiveNoComplCombinationSize := 2;
end;

procedure WriteMsgToFile(const sFile, sMsg : string);
var
   OutFile : TextFile;
begin
     assignfile(OutFile,sFile);
     rewrite(OutFile);
     writeln(OutFile,sMsg);
     closefile(OutFile);     
end;

procedure ExecuteIrrepNoComplementarity(const iIc : integer;
                                        const {fComprehensiveDebug,}
                                              fIncludeFeatureArea,
                                              fUserUpdates,
                                              fComplementarity : boolean;
                                        {const sDebugFileName : string;}
                                        const fCalculateArithmeticVariables,
                                              fRecalculatePresenceRules : boolean);
var
   dDouble : extended;
   lLocalSite : longint;
   fBreakExecution,
   fCancel : boolean;
   FeatureIrrep : Array_T;
   rValue,
   rIrr, rSummedIrr : extended;
   comprehensivefile, DebugFile : textfile;
   iDir,
   iDebugFile : integer;
   HAI : Hotspots_Area_Indices_T;
   iInc : integer;
   sDebugFileName : string;
   fComprehensiveDebug : boolean;
   Trigger : CombinationSizeCondition_T;
{MAIN procedure for Simon's Irreplaceability run}
begin
     try
        Screen.Cursor := crHourglass;

        if fCalculateArithmeticVariables then
        begin
             // calculate feature richness which is used by
             MakeRichnessArr_NoCompl(fComprehensiveDebug,fRecalculatePresenceRules);
        end;

        if (not fComplementarity) then
        begin
             Init_Hotspots_Area_Indices;
             // report the targets
             if ControlRes^.fGenerateCompRpt
             and ControlRes^.fValidateMode
             and ValidateThisIteration(iMinsetIterationCount) then
             begin
                  if (iMinsetIterationCount = -1) then
                     iDir := 0
                  else
                      iDir := iMinsetIterationCount;
                  ForceDirectories(ControlRes^.sWorkingDirectory +
                                   '\' + IntToStr(iDir));
                  ReportNoComplementarityTarget(ControlRes^.sWorkingDirectory +
                                                '\' + IntToStr(iDir) +
                                                '\no_compl_tgt' + IntToStr(iDir) +
                                                '.csv' );
             end;
        end;

        ControlForm.Update;

        if not fContrDoneOnce then
        begin
             LocalRepr := Array_t.Create;
             LocalRepr.init(SizeOf(Repr),iFeatureCount);
        end;

        if (iIc < 1) then
        begin
             // This block gets executed when :
             //    1) we are not running a minset (iIc = -1)
             //    2) we are running the pre iteration of a minset (iIc = 0)
             //
             // When we are in a subsequent iteration of the minset, iIc > 1
             //
             // If we run this during a minset, it will override any possible
             // destruction and stuff up the destruction calcs.

             InitDefExcSum;
             GetExcManSel;
             PrepIrrepData(True);
        end;

        {if (not fComplementarity) then
           SetNoComplementarityTargets;}

        fCancel := False;

        iNoComplAvailableSiteCount := ControlForm.Available.Items.Count +
                                      ControlForm.Flagged.Items.Count +
                                      ControlForm.Partial.Items.Count +
                                      ControlForm.R1.Items.Count +
                                      ControlForm.R2.Items.Count +
                                      ControlForm.R3.Items.Count +
                                      ControlForm.R4.Items.Count +
                                      ControlForm.R5.Items.Count;

        AdjustCombinationSizeForReserves(ControlRes^.LastCombinationSizeCondition);

        // set no complementarity combination size
        SetNoComplCombinationSize;

        WriteCombsizeDebug('ExecuteIrrepNoComplementarity');

        init_irr_variables(combsize.iActiveNoComplCombinationSize,iNoComplAvailableSiteCount);

        {$IFDEF REPORTTIME}
        if ControlRes^.fReportTime then
           ReportTime('before Irreplaceability');
        {$ENDIF}

        fBreakExecution := False;
        fSiteBreakExecution := False;
        rMaxAvFlSumirr := 0;

        fComprehensiveDebug := False;
        if ControlRes^.fGenerateCompRpt
        and ControlRes^.fValidateMode then
        begin
             // iMinsetIterationCount
             {if (iMinsetIterationCount > -1) then}
                fComprehensiveDebug := True;
        end;
        sDebugFileName := '';
        if fComprehensiveDebug
        and ValidateThisIteration(iMinsetIterationCount) then
        begin
             if (iMinsetIterationCount = -1) then
                iDir := 0
             else
                 iDir := iMinsetIterationCount;
             ForceDirectories(ControlRes^.sWorkingDirectory +
                              '\' + IntToStr(iDir));
             sDebugFileName := ControlRes^.sWorkingDirectory +
                               '\' + IntToStr(iDir) +
                               '\debugmatrix' + IntToStr(iDir) +
                               '_no_compl.csv';
             assignfile(comprehensivefile,sDebugFileName);
             rewrite(comprehensivefile);
             if fIncludeFeatureArea then
                writeln(comprehensivefile,'SiteIndex,FeatureKey,PartialStatus,FeatureIrreplaceability,Feature%ToTarget,FeatureAmount')
             else
                 writeln(comprehensivefile,'SiteIndex,FeatureKey,PartialStatus,FeatureIrreplaceability,Feature%ToTarget');
             closefile(comprehensivefile);
        end;

        {$IFDEF SPARSE_MATRIX_2}
        rValue := 0;
        FeatureIrrep := Array_t.Create;
        FeatureIrrep.init(SizeOf(extended),iFeatureCount);
        for lLocalSite := 1 to iFeatureCount do
            FeatureIrrep.setValue(lLocalSite,@rValue);
        {$ENDIF}

        try
           iBreakSiteKey := 0;
           iBreakFeatureKey := 0;

           for lLocalSite:=1 to iSiteCount do
           begin
                Hotspots_Area_Indices.rtnValue(lLocalSite,@HAI);

                predict_sf4_hotspots_no_complementarity(lLocalSite,
                                                        FeatureIrrep,
                                                        ControlRes^.fValidateIrreplaceability,fComprehensiveDebug,fIncludeFeatureArea,
                                                        fBreakExecution,
                                                        sDebugFileName,
                                                        HAI.rIrreplaceability,
                                                        HAI.rSumirr,
                                                        HAI.rWeightedPercentTarget,
                                                        HAI.rMaxRarity,
                                                        HAI.rRichness,
                                                        HAI.rSummedRarity,
                                                        fCalculateArithmeticVariables,
                                                        fRecalculatePresenceRules);

                Hotspots_Area_Indices.setValue(lLocalSite,@HAI);

                //if fBreakExecution then
                //   Break;
           end;

        finally
        end;

        if fSiteBreakExecution
        and (rMaxAvFlSumirr = 0) then
            fBreakExecution := True;

        if fBreakExecution
        and ControlRes^.fValidateMinset then
            WriteMsgToFile(ControlRes^.sWorkingDirectory + '\no_compl_trigger.txt',
                           'condition ' + CombinationSizeCondition2String(Trigger) +
                           ' iteration ' + IntToStr(iMinsetIterationCount) +
                           ' site ' + IntToStr(iBreakSiteKey) +
                           ' feature ' + IntToStr(iBreakFeatureKey));

        fBreakExecution := False;

        if fBreakExecution then
        begin
             // Execution was stopped in the irreplaceability run.
             // We must recalculate combination size using the current
             // effective targets.
             if fSiteBreakExecution
             and (rMaxAvFlSumirr = 0) then
                 Trigger := TriggerZeroAvSumirr
             else
                 Trigger := TriggerTargetCannotBeMet;

             Beep;
             Beep;
             Beep;
             Beep;
             Beep;
             Beep; // 6 beeps

             if ControlRes^.fValidateMinset then
                WriteMsgToFile(ControlRes^.sWorkingDirectory + '\no_compl_trigger.txt',
                               'condition ' + CombinationSizeCondition2String(Trigger) +
                               ' iteration ' + IntToStr(iMinsetIterationCount) +
                               ' site ' + IntToStr(iBreakSiteKey) +
                               ' feature ' + IntToStr(iBreakFeatureKey));

             combsize.iCurrentSelectedCombinationSize:=select_combination_size(AverageSite,FeatArr,LocalRepr,
                                               iFeatureCount,
                                               fUserUpdates,ControlRes^.fValidateCombsize,ControlRes^.fPartialValidateCombsize,
                                               Trigger);
             //combsize.iCurrentSitesUsed := ControlForm.Available.Items.Count + ControlForm.Flagged.Items.Count;
             combsize.iActiveCombinationSize := combsize.iCurrentSelectedCombinationSize;
             WriteCombsizeDebug('ExecuteIrrepNoComplementarity_Break');

             // Now rerun irreplaceability
             if fComprehensiveDebug
             and ValidateThisIteration(iMinsetIterationCount) then
             begin
                  if (iMinsetIterationCount = -1) then
                     iDir := 0
                  else
                      iDir := iMinsetIterationCount;
                  ForceDirectories(ControlRes^.sWorkingDirectory +
                                   '\' + IntToStr(iDir));
                  sDebugFileName := ControlRes^.sWorkingDirectory +
                                    '\' + IntToStr(iDir) +
                                    '\debugmatrix' + IntToStr(iDir) +
                                    '_no_compl.csv';
                  assignfile(comprehensivefile,sDebugFileName);
                  rewrite(comprehensivefile);
                  if fIncludeFeatureArea then
                     writeln(comprehensivefile,'SiteIndex,FeatureKey,PartialStatus,FeatureIrreplaceability,Feature%ToTarget,FeatureAmount')
                  else
                      writeln(comprehensivefile,'SiteIndex,FeatureKey,PartialStatus,FeatureIrreplaceability,Feature%ToTarget');
                  closefile(comprehensivefile);
             end;

             fBreakExecution := False;
             for lLocalSite:=1 to iSiteCount do
             begin
                  Hotspots_Area_Indices.rtnValue(lLocalSite,@HAI);

                  predict_sf4_hotspots_no_complementarity(lLocalSite,
                                                          FeatureIrrep,
                                                          ControlRes^.fValidateIrreplaceability,fComprehensiveDebug,fIncludeFeatureArea,
                                                          fBreakExecution,
                                                          sDebugFileName,
                                                          HAI.rIrreplaceability,
                                                          HAI.rSumirr,
                                                          HAI.rWeightedPercentTarget,
                                                          HAI.rMaxRarity,
                                                          HAI.rRichness,
                                                          HAI.rSummedRarity,
                                                          fCalculateArithmeticVariables,
                                                          fRecalculatePresenceRules);

                  Hotspots_Area_Indices.setValue(lLocalSite,@HAI);
             end;
        end;

        FeatureIrrep.Destroy;

        {if (not fComplementarity) then
           SetNoComplementarityTargets;}


        // create a debug file for the no complementarity arithmetic values
        if ControlRes^.fGenerateCompRpt
        and ControlRes^.fValidateMode
        and (ValidateThisIteration(iMinsetIterationCount) or (iMinsetIterationCount <= 0)) then
        begin
             if (iMinsetIterationCount = -1) then
                iDir := 0
             else
                 iDir := iMinsetIterationCount;

             ForceDirectories(ControlRes^.sWorkingDirectory +
                              '\' + IntToStr(iDir));

             ReportNoComplSites(ControlRes^.sWorkingDirectory +
                                '\' + IntToStr(iDir) +
                                '\sites' + IntToStr(iDir) +
                                '_no_compl.csv');
             //Hotspots_Area_Indices.setValue(lLocalSite,@HAI);
        end;
        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ExecuteIrrepNoComplementarity',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;



end.
