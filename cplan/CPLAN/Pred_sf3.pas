unit Pred_sf3;

interface

uses
    Global,ds;

function comb_predict_sf3 (const FArr : Array_T;
                           var ReprArr : Array_T;
                           {const iNumFeat,} iSpaceToTest : integer;
                           const fDebug, fPartialDebug : boolean;
                           const CombinationSizeCondition : CombinationSizeCondition_T) : extended;

implementation

uses
    Control, Contribu, Sf_irrep, SysUtils,
    Dialogs, In_Order, Opt1, Forms, Controls,
    partl_ed, validate;

function predict_sf3(const lSite: longint;
                      {$IFDEF SPARSE_MATRIX_2}
                      FeatureIrrep : Array_T
                      {$ELSE}
                      var FeatureIrrep : ClickRepr_T
                      {$ENDIF}
                     ) : extended;
label
   skip1,skip2;
var
   feature : longint;
   mean_site,sd,z,area_site,area2_site,sumarea,sumarea2,mean_target,
   combadj : extended;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   ARepr : Repr;
   {$IFDEF SPARSE_MATRIX_2}
   ContribArea : Array_t;
   {$ELSE}
   pCArea : ^featurearea_T;
   {$ENDIF}
   rSumProduct : extended;
   fPartialOn, fReserved : boolean;
   rTmp : extended;
   geo : integer;
   carea : extended;
   fTrace : boolean;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}

begin
     new(pSite);
     new(pFeat);

     SiteArr.rtnValue(lSite,pSite);
     pSite^.rSummedIrr := 0;
     pSite^.rSummedIrrVuln2 := 0;
     pSite^.rWAVIRR := 0;
     pSite^.rPCUSED := 0;
     pSite^.fSiteHasUse := False;

     {$IFDEF SPARSE_MATRIX_2}
     {$ELSE}
     new(pCArea);
     //ContribArea.rtnValue(lSite,pCArea);
     {$ENDIF}

     try

     if ((pSite^.status = Av)
         or (pSite^.status = Pd)
         or (pSite^.status = Fl))
     and (pSite^.richness > 0) then
     begin
          for feature := 1 to pSite^.richness do
          begin
               fPartialOn := True;

               if (pSite^.status = Pd) then
               begin
                    SparsePartial.rtnValue(pSite^.iOffset + feature,@fReserved);
                    if fReserved then
                       fPartialOn := False;

                   {this feature is deferred at this site,
                    so it is not included in the calculations
                    of irreplaceability}
               end;
               {$IFDEF SPARSE_MATRIX}
               FeatureAmount.rtnValue(pSite^.iOffset + feature,@Value);
               area_site:= Value.rAmount;
               {$ELSE}
               area_site:= pSite^.featurearea[feature];
               {$ENDIF}
               area2_site:=sqr(area_site);

               FeatArr.rtnValue(Value.iFeatKey,pFeat);
                       
               if (not fPartialOn)
               or (pFeat^.targetarea <= 0) then
               begin
                    ARepr.repr_exclude := 1;
                    ARepr.repr_include := 1;
                    goto skip2;
               end;

               pSite^.fSiteHasUse := True;

               sumarea:=(pFeat^.rCurrentSumArea - area_site)*mult;
               sumarea2:=(pFeat^.rCurrentAreaSqr - area2_site)*mult;
               mean_site:=sumarea/iAvailableSiteCount{sites};

               if (combsize.iActiveCombinationSize-1) > (iAvailableSiteCount-1)/2.0 then
                  combadj:=sqrt((iAvailableSiteCount-1)-(combsize.iActiveCombinationSize-1))/(combsize.iActiveCombinationSize-1)
               else
                  combadj:=sqrt(combsize.iActiveCombinationSize-1)/(combsize.iActiveCombinationSize-1);

               try
                  rTmp := (sumarea2-(sqr(sumarea) / iAvailableSiteCount)) / iAvailableSiteCount;
                  if (rTmp >= 0) then
                     rTmp := sqrt(rTmp)
                  else
                      rTmp := 0;
                  sd := rTmp * combadj;

               except on exception do
                      sd := 0;
               end;

               LocalRepr.rtnValue(Value.iFeatKey,@ARepr);

               if (pFeat^.rCurrentSumArea - area_site) < pFeat^.targetarea then
               begin
                  ARepr.repr_exclude :=0;
                  goto skip1;
               end;
               mean_target:=pFeat^.targetarea/(combsize.iActiveCombinationSize-1);
               if sd < 0.00000000001 then
               begin
                  if mean_site < mean_target then
                     ARepr.repr_exclude:=0
                  else
                     ARepr.repr_exclude:=1;
               end
               else
               begin
                  z:=(mean_target-mean_site)/sd;
                  ARepr.repr_exclude:=zprob(z);
               end;
       skip1:
               if area_site >= pFeat^.targetarea then
               begin
                  ARepr.repr_include:=1;
                  goto skip2;
               end;
               mean_target:=(pFeat^.targetarea-area_site)/(combsize.iActiveCombinationSize-1);
               if sd < 0.00000000001 then
               begin
                  if mean_site < mean_target then
                  begin
                       ARepr.repr_include:=1;
                       ARepr.repr_exclude:=1;
                  end
                  else
                     ARepr.repr_include:=1;
               end
               else
               begin
                  z:=(mean_target-mean_site)/sd;
                  if z>35 then
                  begin
                       ARepr.repr_include:=1;
                       ARepr.repr_exclude:=1;
                  end
                  else
                      ARepr.repr_include:=zprob(z);
               end;
       skip2:
               if (ARepr.repr_include = 0) and (area_site > 0) then
                  ARepr.repr_include:=1;
               if ARepr.repr_include = 0 then
                  ARepr.irr_feature:=0
               else
                  ARepr.irr_feature:=(ARepr.repr_include-ARepr.repr_exclude) /
                                     ARepr.repr_include;

               LocalRepr.setValue(Value.iFeatKey,@ARepr);
               {post representation data for this feature}
          end;
          total_repr_include[11]:=1;
          total_repr_exclude[11]:=1;

          rSumProduct := 0;

          if (pSite^.richness > 0) then
          for feature := 1 to pSite^.richness do
          begin
               FeatureAmount.rtnValue(pSite^.iOffset + feature,@Value);
               LocalRepr.rtnValue(Value.iFeatKey,@ARepr);
               FeatArr.rtnValue(Value.iFeatKey,pFeat);

               FeatureIrrep.setValue(feature,@ARepr.irr_feature);
               ContribArea.rtnValue(feature,@carea);

               pSite^.rSummedIrr := pSite^.rSummedIrr + ARepr.irr_feature;

               geo := pSite^.iKey;

               if (Value.iFeatKey <= iPCUSEDCutOff) then
               begin
                    rSumProduct := rSumProduct +
                              (ARepr.irr_feature * carea);
               end;

               total_repr_include[11]:=total_repr_include[11] * ARepr.repr_include;
               total_repr_exclude[11]:=total_repr_exclude[11] * ARepr.repr_exclude;
          end;

          if (pSite^.area > 0) then
             pSite^.rWAVIRR := rSumProduct / pSite^.area
          else
              pSite^.rWAVIRR := 0;

          if (pSite^.rWAVIRR > 1) then
             pSite^.rWAVIRR := 1;

          if total_repr_include[11] = 0 then
             predict_sf3:=0
          else
             predict_sf3:=(total_repr_include[11]-total_repr_exclude[11]) /
                                           total_repr_include[11];
     end
     else
         predict_sf3 := 0;

     except
           on EZeroDivide do
            begin
                 predict_sf3 := 0;
                 pSite^.rWAVIRR := 0;
                 pSite^.rSummedIrr := 0;
                 pSite^.rSummedIrrVuln2 := 0;
            end;
           on EInvalidOp do
            begin
                 predict_sf3 := 0;
                 pSite^.rWAVIRR := 0;
                 pSite^.rSummedIrr := 0;
                 pSite^.rSummedIrrVuln2 := 0;
            end;
     end;

     SiteArr.setValue(lSite,pSite);

     {$IFNDEF SPARSE_MATRIX_2}
     dispose(pCArea);
     {$ENDIF}
     dispose(pSite);
     dispose(pFeat);

end; {function predict_sf3}

{----------------------------------------------------------------------------}
function comb_predict_sf3 (const FArr : Array_T;
                           var ReprArr : Array_T;
                           {const iNumFeat,} iSpaceToTest : integer;
                           const fDebug, fPartialDebug : boolean;
                           const CombinationSizeCondition : CombinationSizeCondition_T) : extended;
label
   skip1,skip2;
var
   mean_site,sd,z,area_site,area2_site,sumarea,sumarea2,mean_target,
   combadj : extended;

   AFeat : featureoccurrence;
   ARepr : Repr;

   eAverageSite : extended;

   iCount : integer;
   rTarget,
   rTmp : extended;
   DbgFile : text;
   fPointFeatures,
   fTriggerDebug : boolean;
   sTriggerDebugFile : string;
   TriggerDebugFile : TextFile;
begin
     try
        if fDebug then
        begin
             {create debug file}
             assign(DbgFile,ControlRes^.sWorkingDirectory + '\comb' + IntToStr(combsize.iActiveCombinationSize) + '_sf3.csv');
             rewrite(DbgFile);
             {write feature code as first column
              write variable names as names of other columns}

             write(DbgFile,'Feature Code,Original Effective Target,area_site,area2_site,sumarea,sumarea2,');
             writeln(DbgFile,'mean_site,irr_feature,repr_include,repr_exclude');
        end;

        fTriggerDebug := False;
        if (CombinationSizeCondition = TriggerTargetCannotBeMet)
        and (combsize.iActiveCombinationSize = 2) then
        begin
             fTriggerDebug := ControlRes^.fValidateMinset;
             if fTriggerDebug then
             begin
                  sTriggerDebugFile := ControlRes^.sWorkingDirectory +
                                       '\comb2_trigger_' +
                                       IntToStr(iMinsetIterationCount) +
                                       '.csv';
                  assignfile(TriggerDebugFile,sTriggerDebugFile);
                  rewrite(TriggerDebugFile);
                  write(TriggerDebugFile,'Feature Code,Original Effective Target,initial available area,current available area,area_site,area2_site,sumarea,sumarea2,');
                  writeln(TriggerDebugFile,'mean_site,irr_feature,repr_include,repr_exclude');
             end;
        end;

        for iCount := 1 to iFeatureCount do
        begin
             FArr.rtnValue(iCount,@AFeat);

             case CombinationSizeCondition of
                  Startup,
                  ExclusionChange,
                  TargetChange,
                  UserLoadLog,
                  OverrideChange : AverageInitialSite.rtnValue(iCount,@eAverageSite);
             else
                 AverageSite.rtnValue(iCount,@eAverageSite);
             end;

             try
                area_site:= eAverageSite;
                area2_site:=sqr(area_site);

                case CombinationSizeCondition of
                     OverrideChange,
                     Startup,
                     ExclusionChange,
                     TargetChange,
                     UserLoadLog :
                     begin
                          // we may have to take exclusions into account
                          if (AFeat.rInitialAvailable - AFeat.rExcluded) < AFeat.rInitialAvailableTarget then
                             rTarget := AFeat.rInitialAvailable - AFeat.rExcluded
                          else
                              rTarget := AFeat.rInitialAvailableTarget;
                          //sumarea:=(AFeat.rSumArea-area_site)*mult;
                          //sumarea2:=(AFeat.rAreaSqr-area2_site)*mult;
                     end;
                else
                    rTarget := AFeat.targetarea;
                    // This case applies to MinsetLoadLog & TriggerTargetCannotBeMet & TriggerZeroAvSumirr
                    //sumarea:=(AFeat.rCurrentSumArea-area_site)*mult;
                    //sumarea2:=(AFeat.rCurrentAreaSqr-area2_site)*mult;
                    //sumarea:=(AFeat.rSumArea-area_site)*mult;
                    //sumarea2:=(AFeat.rAreaSqr-area2_site)*mult;
                end;

                if ControlRes^.fPointFeaturesSpecified then
                   PointFeatures.rtnValue(iCount,@fPointFeatures)
                else
                    fPointFeatures := False;
                    
                if fPointFeatures then
                   rTarget := 0;
                  // This is a point feature so we must ignore it for the purposes of combination size.
                  // This is equivalent to temporarily setting the target to zero.

             except
                   area_site := 0;
                   area2_site := 0;
             end;

             ReprArr.rtnValue(iCount,@ARepr);

             sumarea := 0;
             sumarea2 := 0;
             mean_site := 0;
             mean_target := 0;

             if (rTarget <= 0) then
             begin
                  ARepr.repr_exclude := 1;
                  ARepr.repr_include := 1;
                  goto skip2;
             end;

             sumarea:=(AFeat.rSumArea-area_site)*mult;
             sumarea2:=(AFeat.rAreaSqr-area2_site)*mult;
             //sumarea:=(AFeat.rCurrentSumArea-area_site)*mult;
             //sumarea2:=(AFeat.rCurrentAreaSqr-area2_site)*mult;
             mean_site:=sumarea/iSpaceToTest;
             if (combsize.iActiveCombinationSize-1) > (iSpaceToTest-1)/2.0 then
                combadj:=sqrt((iSpaceToTest-1)-(combsize.iActiveCombinationSize-1))/(combsize.iActiveCombinationSize-1)
             else
                combadj:=sqrt(combsize.iActiveCombinationSize-1)/(combsize.iActiveCombinationSize-1);
             try
                rTmp := (sumarea2-(sqr(sumarea) / iSpaceToTest)) / iSpaceToTest;

                if (rTmp >= 0) then
                   rTmp := sqrt(rTmp)
                else
                    rTmp := 0;
                sd := rTmp * combadj;

             except on EInvalidOp do
                    sd := 0;
             end;
             mean_target:=rTarget/(combsize.iActiveCombinationSize-1);

             if sd < 0.00000000001 then
             begin
                if mean_site < mean_target then
                   ARepr.repr_exclude:=0
                else
                   ARepr.repr_exclude:=1;
             end
             else
             begin
                z:=(mean_target-mean_site)/sd;
                ARepr.repr_exclude:=zprob(z);
             end;
     skip1:
             if area_site >= rTarget then
             begin
                ARepr.repr_include:=1;
                goto skip2;
             end;
             mean_target:=(rTarget-area_site)/(combsize.iActiveCombinationSize-1);
             if sd < 0.00000000001 then
             begin
                if mean_site < mean_target then
                begin
                     ARepr.repr_include:=0;
                end
                else
                   ARepr.repr_include:=1;
             end
             else
             begin
                z:=(mean_target-mean_site)/sd;
                if z>35 then
                begin
                     ARepr.repr_include:=0;
                end
                else
                    ARepr.repr_include:=zprob(z);
             end;
     skip2:
             if (ARepr.repr_include = 0) then
             begin
                  if (area_site > 0) then
                     ARepr.irr_feature:=1
                  else
                      ARepr.irr_feature:=0;
             end
             else
                ARepr.irr_feature:=(ARepr.repr_include-ARepr.repr_exclude) /
                                   ARepr.repr_include;

             ReprArr.setValue(iCount,@ARepr);
             {post representation data for this feature}

             if fDebug then
             begin
                  write(DbgFile,IntToStr(AFeat.code) + ',' + FloatToStr(rTarget) + ',' +
                        FloatToStr(area_site) + ',' + FloatToStr(area2_site) + ',' + FloatToStr(sumarea) + ',' +
                        FloatToStr(sumarea2) + ',');
                  writeln(DbgFile,FloatToStr(mean_site) + ',' + FloatToStr(ARepr.irr_feature) + ',' + FloatToStr(ARepr.repr_include) + ',' +
                          FloatToStr(ARepr.repr_exclude));

             end;

             if fTriggerDebug then
             begin
                  //try
                  write(TriggerDebugFile,IntToStr(AFeat.code) + ',' + FloatToStr(rTarget) + ',' + FloatToStr(AFeat.rSumArea) + ',' + FloatToStr(AFeat.rCurrentSumArea) + ',' +
                        FloatToStr(area_site) + ',' + FloatToStr(area2_site) + ',' + FloatToStr(sumarea) + ',' +
                        FloatToStr(sumarea2) + ',');
                  writeln(TriggerDebugFile,FloatToStr(mean_site) + ',' + FloatToStr(ARepr.irr_feature) + ',' + FloatToStr(ARepr.repr_include) + ',' +
                          FloatToStr(ARepr.repr_exclude));
             end;
       end;

       if fDebug then
          CloseFile(DbgFile);
       if fTriggerDebug then
          closefile(TriggerDebugFile);

       total_repr_include[11]:=1;
       total_repr_exclude[11]:=1;

       for iCount := 1 to iFeatureCount do
       begin
            ReprArr.rtnValue(iCount,@ARepr);

            total_repr_include[11]:=total_repr_include[11] * ARepr.repr_include;
            total_repr_exclude[11]:=total_repr_exclude[11] * ARepr.repr_exclude;
       end;

       if total_repr_include[11] = 0 then
          comb_predict_sf3:=1
       else
          comb_predict_sf3:=(total_repr_include[11]-total_repr_exclude[11]) /
                                        total_repr_include[11];

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception predicting combination size',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;

end; {function comb_predict_sf3}

{----------------------------------------------------------------------------}
end.
