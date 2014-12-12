unit Sf_irrep;
{Author: Matthew Watts
 Date:
 Purpose: Simon Ferriers predictor version 3 and other code.
 }

{$I STD_DEF.PAS}

{$UNDEF DBG_SUMIRR}

{$UNDEF DBG_COMBSIZE}

{$UNDEF DEBUG_COMB}

{$DEFINE REPORTTIME}  {use to report execution time of irreplaceability components}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Em_newu1, Global,
  {$IFDEF bit16}
  Arrayt16, Cpng_imp;
  {$ELSE}
  ds, Dll_u1;
  {$ENDIF}


type
  TIrrepForm = class(TForm)
    Panel1: TPanel;
    OutputBox: TListBox;
    btnTest: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
   IrrepForm: TIrrepForm;
   LocalRepr : Array_T;
   combsize : CombinationSize_T;
   lSite,feature : longint;
   pcomb,qcomb,mult,wt_include,wt_exclude : extended;
   total_repr_include,
   total_repr_exclude,
   total_repr_incexc : ElevenExtendedArr_T;
   iAvailableSiteCount : integer;
   AverageSite, AverageInitialSite : Array_T;
   fAverageSiteCreated : boolean;
   iBreakSiteKey, iBreakFeatureKey,
   iIr1Count,i001Count,i002Count,i003Count,
   i004Count,i005Count,i0CoCount : integer;
   fSiteBreakExecution : boolean;
   rMaxAvFlSumirr : extended;

function select_combination_size (const SDArr, FArr : Array_T;
                                  var ReprArr : Array_T;
                                  const iNumFeat{, iNumAvail} : integer;
                                  const fShowProgress, fDebug, fPartialDebug : boolean;
                                  const CombinationSizeCondition : CombinationSizeCondition_T) : longint;
procedure init_irr_variables (const iCombinationSize : longint;
                              const iNumAvail : integer);
function CountSQL : integer;
function zprob (x: double) : double;//extended) : extended;{----------------------------------------------------------------------------}
function SPathIni : extended;
procedure AdjustCombinationSizeForReserves(const CombinationSizeCondition : CombinationSizeCondition_T);
procedure ExecuteIrreplaceability(const iIc : integer;
                                  const fComprehensiveDebug,
                                        fIncludeFeatureArea,
                                        fUserUpdates,
                                        fComplementarity : boolean;
                                  const sDebugFileName : string);
procedure RunIrrepVariComb(const iCurrentCombsize : integer);

procedure WriteCombsizeDebug(const sCodeVersion : string);
function CombinationSizeCondition2String(const CombinationSizeCondition : CombinationSizeCondition_T) : string;


implementation

uses Control, Contribu, Inifiles, In_order,
     Pred_sf4, Combfile, Opt1, Toolmisc,
     Start, Pred_sf3, trpt, spatio,
     Av1, mthread, validate,
     override_combsize,
     UpdateAverageSite, RedundancyCheck,
     reports, hotspots_nocomplementarity_areaindices;

{$R *.DFM}

{-------------------------------------------------------------------------}

function CombinationSizeCondition2String(const CombinationSizeCondition : CombinationSizeCondition_T) : string;
begin
     case CombinationSizeCondition of
          Startup : Result := 'Startup';
          ExclusionChange : Result := 'ExclusionChange';
          TargetChange : Result := 'TargetChange';
          UserLoadLog : Result := 'UserLoadLog';
          OverrideChange : Result := 'OverrideChange';
          MinsetLoadLog : Result := 'MinsetLoadLog';
          TriggerTargetCannotBeMet : Result := 'TriggerTargetCannotBeMet';
          TriggerZeroAvSumirr : Result := 'TriggerZeroAvSumirr';
          TriggerExcludedSite : Result := 'TriggerExcludedSite';
     else
         Result := 'not known';
     end;
end;

procedure WriteCombsizeDebug(const sCodeVersion : string);
var
   sDebugFile : string;
   DebugFile : TextFile;

   procedure AttemptWrite;
   begin
        sDebugFile := ControlRes^.sWorkingDirectory + '\CombinationSizeLog.csv';

        if not FileExists(sDebugFile) then
        begin
             // create the file if it doesn't exist
            assignfile(DebugFile,sDebugFile);
            rewrite(DebugFile);
            write(DebugFile,'minset iteration,code version,condition,available sites,selected sites,redundant sites,');
            write(DebugFile,'SelectedCombinationSize,CurrentSelectedCombinationSize,');
            write(DebugFile,'CurrentSitesUsed,CustomCombinationSize,ActiveCombinationSize,');
            writeln(DebugFile,'ActiveNoComplCombinationSize,date and time,AllocMemSize');
            closefile(DebugFile);
        end;

        // append a row to the file
        assignfile(DebugFile,sDebugFile);
        append(DebugFile);
        writeln(DebugFile,IntToStr(iMinsetIterationCount) + ',' +
                          sCodeVersion + ',' +
                          CombinationSizeCondition2String(ControlRes^.LastCombinationSizeCondition) + ',' +
                          IntToStr(ControlForm.Available.Items.Count + ControlForm.Flagged.Items.Count) + ',' +
                          IntToStr(ControlForm.R1.Items.Count + ControlForm.R2.Items.Count + ControlForm.R3.Items.Count + ControlForm.R4.Items.Count + ControlForm.R5.Items.Count + ControlForm.Partial.Items.Count) + ',' +
                          IntToStr(iRedundantSites) + ',' +
                          IntToStr(combsize.iSelectedCombinationSize) + ',' +
                          IntToStr(combsize.iCurrentSelectedCombinationSize) + ',' +
                          IntToStr(combsize.iCurrentSitesUsed) + ',' +
                          IntToStr(combsize.iCustomCombinationSize) + ',' +
                          IntToStr(combsize.iActiveCombinationSize) + ',' +
                          IntToStr(combsize.iActiveNoComplCombinationSize) + ',' +
                          FormatDateTime('hh:nn:ss AM/PM  ddd mmm d yyyy', Now) + ',' +
                          IntToStr(AllocMemSize));
        closefile(DebugFile);
   end;

begin
     if ControlRes^.fLogCombsizeRecalc then
     try
        AttemptWrite;

     except
           Screen.Cursor := crDefault;
           if (mrYes = MessageDlg(
                      'Could not write to Combination Size Log.' +
                      Chr(10) + Chr(13) +
                      'It may be in use by another program' +
                      Chr(10) + Chr(13) +
                      'Do you want to retry?' +
                      Chr(10) + Chr(13) +
                      Chr(10) + Chr(13) +
                      'Press Yes to retry and No to ignore',
                      mtConfirmation,[mbYes,mbNo],0)) then
           try
              AttemptWrite;
           except
           end;
     end;
end;

procedure HighlightSite(iGeo : integer);
begin
     with ControlForm do
          _HighlightSite(iGeo,
                         Available, R1, R2, R3, R4, R5,
                         Partial, Excluded, Flagged,
                         AvailableKey, R1Key, R2Key, R3Key, R4Key, R5Key,
                         PartialKey,
                         ExcludedKey, FlaggedKey);
end;

function CountSQL : integer;
begin
     with ControlForm do
          _CountSQL(Available, R1, R2, R3, R4, R5,
                    Partial, Excluded, Flagged,
                    AvailableKey, R1Key, R2Key, R3Key, R4Key, R5Key,
                    PartialKey, ExcludedKey, FlaggedKey,
                    SiteArr, iSiteCount, fKeepHighlight);

end;
{-------------------------------------------------------------------------}

function zprob (x: double) : double;//extended) : extended;
var
   z,t,q,m : double;//extended;
   negative : boolean;
begin
   if x < 0 then
   begin
      negative:=true;
      x:=0-x;
   end
   else
      negative:=false;
   if x > 50 then
      x:=50;
   z:=0.3989*exp((0-sqr(x))/2);
   t:=1/(1+0.23164*x);
   m:=t;
   q:=0.31938*m;
   m:=m*t;
   q:=q-0.35656*m;
   m:=m*t;
   q:=q+1.78148*m;
   m:=m*t;
   q:=q-1.82126*m;
   m:=m*t;
   q:=q+1.33027*m;
   if negative then
      zprob:=1-q*z
   else
      zprob:=q*z;
end;

{----------------------------------------------------------------------------}

function predict_repr_comb (iCombinationSize: longint) : extended;
var
   feature : longint;
   mean_site,mean_target,sd,z,sumarea,sumarea2,repr_comb,combadj : extended;
   pFeat : featureoccurrencepointer;
   TmpFeat : featureoccurrence;
begin
     repr_comb:=1;
     pFeat := @TmpFeat;

     for feature:=1 to iFeatureCount do
     begin
          FeatArr.rtnValue(feature,pFeat);

          mean_target:=TmpFeat.targetarea /iCombinationSize;
          sumarea:=TmpFeat.rSumArea;
          sumarea2:=TmpFeat.rAreaSqr;
          mean_site:=sumarea/iAvailableSiteCount;
          if iCombinationSize > iAvailableSiteCount/2 then
             combadj:=sqrt(iAvailableSiteCount-iCombinationSize)/iCombinationSize
          else
             combadj:=sqrt(iCombinationSize)/iCombinationSize;
          sd:=(sqrt((sumarea2-sqr(sumarea)/iAvailableSiteCount) /
              (iAvailableSiteCount)))*combadj;
          if sd < 0.00000000001 then
             z:=-50
          else
             z:=(mean_target-mean_site)/sd;
          repr_comb:=repr_comb*zprob(z);
     end;
     predict_repr_comb:=repr_comb;
end;


{----------------------------------------------------------------------------}

{$IFDEF DEBUG_COMB}
procedure RptPredComb(pred_comb : array_t);
var
   dValue : extended;
   RptFile : text;
   iCount : integer;
begin
     assign(RptFile,'c:\comb.txt');
     rewrite(RptFile);

     if (pred_comb.lMaxSize > 0) then
        for iCount := 1 to pred_comb.lMaxSize do
        begin
             pred_comb.rtnValue(iCount,@dValue);

             writeln(RptFile,FloatToStr(dValue));
        end;

     close(RptFile);
end;
{$ENDIF}

function select_combination_size (const SDArr, FArr : Array_T;
                                  var ReprArr : Array_T;
                                  const iNumFeat{, iNumAvail} : integer;
                                  const fShowProgress, fDebug, fPartialDebug : boolean;
                                  const CombinationSizeCondition : CombinationSizeCondition_T) : longint;
var
   lCombsize, lCount, lCombCount : longint;
   pred_comb : Array_T;
   min_repr,max_repr : extended;
   dComb, dBest : extended;
   fAutoLoad, fWasGreaterThanHalf, fCSSet : boolean;
   rIrrTarget : extended;
   iRangeToTest, iSneakCS,
   iOldCursor : integer;
   DbgFile, PartialDebugFile : Text;
begin
     try
        if ControlRes^.fDumpAverageSite then
           DumpAverageSiteValues(ControlRes^.sWorkingDirectory + '\AverageSite.csv');
        {$IFDEF DBG_SHOW_ALLOC}
        MessageDlg('TestMem before pred_comb MaxAvail ' +
                   IntToStr(MaxAvail) + ' MemAvail ' +
                   IntToStr(MemAvail),mtInformation,[mbOK],0);
        {$ENDIF}

        if fDebug then
        begin
             assign(DbgFile,ControlRes^.sWorkingDirectory + '\select_combsize_sf3.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'combsize,dComb');
        end;

        if fPartialDebug then
        begin
             assignfile(PartialDebugFile,ControlRes^.sWorkingDirectory +
                                         '\select_combsize_' +
                                         IntToStr(iMinsetIterationCount) +
                                         '.csv');
             rewrite(PartialDebugFile);
             writeln(PartialDebugFile,'combsize,dComb');
        end;

        if fShowProgress then
        begin
             ControlForm.ProgressOn;
             ControlForm.ProcLabelOn('Select Combination Size');
        end;

        {$IFDEF DBG_SHOW_ALLOC}
        MessageDlg('TestMem after pred_comb MaxAvail ' +
                   IntToStr(MaxAvail) + ' MemAvail ' +
                   IntToStr(MemAvail),mtInformation,[mbOK],0);
        {$ENDIF}

        lCombsize := 0;
        min_repr:=1;
        max_repr:=0;

        ControlRes^.LastCombinationSizeCondition := CombinationSizeCondition;

        case CombinationSizeCondition of
             OverrideChange,
             Startup,
             ExclusionChange,
             TargetChange,
             UserLoadLog : iRangeToTest := ControlForm.Available.Items.Count +
                                           ControlForm.Flagged.Items.Count +
                                           ControlForm.R1.Items.Count +
                                           ControlForm.R2.Items.Count +
                                           ControlForm.R3.Items.Count +
                                           ControlForm.R4.Items.Count +
                                           ControlForm.R5.Items.Count +
                                           ControlForm.Partial.Items.Count {+
                                           ControlForm.Excluded.Items.Count};
        else
            iRangeToTest := ControlForm.Available.Items.Count +
                            ControlForm.Flagged.Items.Count;
            ControlRes^.fCustomCombSize := False;
             // The else statement applies to MinsetLoadLog & TriggerTargetCannotBeMet & TriggerZeroAvSumirr
             // We need to update AverageSite
             //
             {ZeroTotalArea;
             SparseMatrixStart;
             SparseTargetsStart;
             SparseCombsizePrep;}
             RefreshAverageSite;

             if ControlRes^.fValidateMinset then
             begin
                  // output feature report
                  ReportFeatures(ControlRes^.sWorkingDirectory + '\trigger_features_' + IntToStr(iMinsetIterationCount) + '.csv',
                                 'Validate Trigger',
                                 FALSE,
                                 ControlForm.UseFeatCutOffs.Checked,
                                 FeatArr,
                                 iFeatureCount,
                                 rPercentage,
                                 '');
                  // output average site
                  DumpAverageSiteValues(ControlRes^.sWorkingDirectory + '\trigger_average_site_' + IntToStr(iMinsetIterationCount) + '.csv');
             end;
        end;

        ControlRes^.iCombinationSizeRange := iRangeToTest;

        pred_comb := Array_t.Create;
        pred_comb.init(SizeOf(extended),iRangeToTest-2);

        for lCombCount:=2 to (iRangeToTest-1) do
        begin
             {case CombinationSizeCondition of
                  MinsetLoadLog, TriggerTargetCannotBeMet, TriggerZeroAvSumirr :
                             combsize.iSelectedCombinationSize := lCombCount;
             end;}
             combsize.iActiveCombinationSize := lCombCount;

             if fShowProgress then
                ControlForm.ProgressUpdate(round(combsize.iActiveCombinationSize/(iRangeToTest-1)*100));

             init_irr_variables(combsize.iActiveCombinationSize,iRangeToTest);

             dComb := comb_predict_sf3(FeatArr,LocalRepr,
                                       iRangeToTest,
                                       ControlRes^.fValidateCombsize,
                                       ControlRes^.fPartialValidateCombsize,
                                       CombinationSizeCondition);

             pred_comb.setValue(lCombCount-1,@dComb);

             if fDebug then
             begin
                  writeln(DbgFile,IntToStr(lCombCount) + ',' + FloatToStr(dComb));
             end;

             if fPartialDebug then
                writeln(PartialDebugFile,IntToStr(lCombCount) + ',' + FloatToStr(dComb));
        end;

        fWasGreaterThanHalf := False;
        fCSSet := False;
        dBest := 1000;
        iSneakCS := 2;
        for lCount := 2 to (iRangeToTest-1) do
        begin
             pred_comb.rtnValue(lCount-1,@dComb);

             if abs(dComb - 0.5) <= dBest then
             begin
                  lCombsize := lCount;
                  dBest := abs(dComb - 0.5);
             end;

             if not fCSSet then
             begin
                  if fWasGreaterThanHalf
                  and (dComb < 0.5) then
                  begin // we have just crossed 0.5 going down
                       fCSSet := True;
                       iSneakCS := lCount;
                  end;
             end;
             fWasGreaterThanHalf := (dComb >= 0.5);
        end;

        {$IFDEF DEBUG_COMB}
        RptPredComb(pred_comb);
        {$ENDIF}

        lCombsize := iSneakCS;
        
        if (lCombsize <= 2) then
           lCombsize := 2;

        if fShowProgress then
        begin
             ControlForm.ProgressOff;
             ControlForm.ProcLabelOff;
        end;

        if fDebug then
           CloseFile(DbgFile);

        if fPartialDebug then
           closefile(PartialDebugFile);

        select_combination_size := lCombsize;

        case CombinationSizeCondition of
             OverrideChange,
             Startup,
             ExclusionChange,
             TargetChange,
             UserLoadLog : combsize.iSelectedCombinationSize := lCombsize;
        else
            combsize.iCurrentSelectedCombinationSize := lCombsize;
            combsize.iCurrentSitesUsed := iRangeToTest;
            // The else statement applies to MinsetLoadLog & TriggerTargetCannotBeMet & TriggerZeroAvSumirr
        end;
        combsize.iActiveCombinationSize := lCombsize;

        //if not fAutoLoad then
           pred_comb.Destroy;

        AppendCombsizeLog('select_combination_size');

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in select combination size',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

{----------------------------------------------------------------------------}
{----------------------------------------------------------------------------}

procedure init_irr_variables (const iCombinationSize: longint;
                              const iNumAvail : integer);
begin
     try
        pcomb:=1/iCombinationSize;
     except
           pcomb := 0;
     end;

     qcomb:=1-pcomb;
     pcomb:=pcomb*iNumAvail;

     try
        if (iNumAvail = 1) then
           mult := 0
        else
            mult:=iNumAvail/(iNumAvail-1);
     except
           mult := 0;
     end;

     try
        if (iNumAvail = 0) then
           wt_include := 0
        else
            wt_include:=iCombinationSize/iNumAvail;
     except
           wt_include := 0;
     end;

     wt_exclude:=1-wt_include;
end;

function SPathIni : extended;
var
   AnIni : TIniFile;
begin
     {load path fractional length from ini file}

     if ControlRes^.fOldIni then
        AnIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
     else
         AnIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
     Result := RegionSafeStrToFloat(AnIni.ReadString('IrrTarget','Value','0.5'));

     {MessageDlg('result ' + FloatToStr(Result) +
                ' ControlRes^.sDatabase ' + ControlRes^.sDatabase,
                mtInformation,[mbOK],0);}

     AnIni.Free;
end;

procedure AdjustCombinationSizeForReserves(const CombinationSizeCondition : CombinationSizeCondition_T);
begin
     if ControlRes^.fCustomCombSize then
     begin
          if ControlRes^.fLockUserDefinedCombinationSize then
          begin
               if ControlRes^.fSuppressCSExclusionRecalc then
                  combsize.iActiveCombinationSize := combsize.iCustomCombinationSize -
                                                               ControlForm.R1.Items.Count -
                                                               ControlForm.R2.Items.Count -
                                                               ControlForm.R3.Items.Count -
                                                               ControlForm.R4.Items.Count -
                                                               ControlForm.R5.Items.Count -
                                                               ControlForm.Excluded.Items.Count -
                                                               ControlForm.Partial.Items.Count
               else
                   combsize.iActiveCombinationSize := combsize.iCustomCombinationSize -
                                                               ControlForm.R1.Items.Count -
                                                               ControlForm.R2.Items.Count -
                                                               ControlForm.R3.Items.Count -
                                                               ControlForm.R4.Items.Count -
                                                               ControlForm.R5.Items.Count -
                                                               ControlForm.Partial.Items.Count;
          end
          else
               combsize.iActiveCombinationSize := combsize.iCustomCombinationSize;
     end
     else
     case CombinationSizeCondition of
          TargetChange : begin
                              if ControlRes^.fSuppressCSExclusionRecalc then
                                  combsize.iActiveCombinationSize := combsize.iSelectedCombinationSize -
                                                               ControlForm.R1.Items.Count -
                                                               ControlForm.R2.Items.Count -
                                                               ControlForm.R3.Items.Count -
                                                               ControlForm.R4.Items.Count -
                                                               ControlForm.R5.Items.Count -
                                                               ControlForm.Excluded.Items.Count -
                                                               ControlForm.Partial.Items.Count
                              else
                                  combsize.iActiveCombinationSize := combsize.iSelectedCombinationSize -
                                                               ControlForm.R1.Items.Count -
                                                               ControlForm.R2.Items.Count -
                                                               ControlForm.R3.Items.Count -
                                                               ControlForm.R4.Items.Count -
                                                               ControlForm.R5.Items.Count -
                                                               ControlForm.Partial.Items.Count;
                         end;
          OverrideChange, Startup, ExclusionChange, {TargetChange,} UserLoadLog :
            if ControlRes^.fSuppressCSExclusionRecalc then
                combsize.iActiveCombinationSize := combsize.iSelectedCombinationSize -
                                               ControlForm.R1.Items.Count -
                                               ControlForm.R2.Items.Count -
                                               ControlForm.R3.Items.Count -
                                               ControlForm.R4.Items.Count -
                                               ControlForm.R5.Items.Count -
                                               ControlForm.Excluded.Items.Count -
                                               ControlForm.Partial.Items.Count
            else
                combsize.iActiveCombinationSize := combsize.iSelectedCombinationSize -
                                               ControlForm.R1.Items.Count -
                                               ControlForm.R2.Items.Count -
                                               ControlForm.R3.Items.Count -
                                               ControlForm.R4.Items.Count -
                                               ControlForm.R5.Items.Count -
                                               ControlForm.Partial.Items.Count;
     else
         combsize.iActiveCombinationSize := combsize.iCurrentSelectedCombinationSize +
                                            ControlForm.Available.Items.Count +
                                            ControlForm.Flagged.Items.Count -
                                            combsize.iCurrentSitesUsed;
         // MinsetLoadLog, TriggerTargetCannotBeMet, TriggerZeroAvSumirr
     end;

     if (combsize.iActiveCombinationSize < 2) then
        combsize.iActiveCombinationSize := 2;
end;

{----------------------------------------------------------}

procedure ExecuteIrreplaceability(const iIc : integer;
                                  const fComprehensiveDebug,
                                        fIncludeFeatureArea,
                                        fUserUpdates,
                                        fComplementarity : boolean;
                                  const sDebugFileName : string);
var
   dDouble : extended;
   lLocalSite : longint;
   fBreakExecution,
   fCancel, fValidateIteration : boolean;
   iOldCS, iRestOfSites, iReserved : integer;
   FeatureIrrep : Array_T;
   rValue : extended;
   comprehensivefile, DebugFile : textfile;
   //iDebugFile : integer;
   Trigger : CombinationSizeCondition_T;
   sValidateFileName : string;
{MAIN procedure for Simon's Irreplaceability run}
begin
     try
        Screen.Cursor := crHourglass;

        if ControlRes^.fValidateMode
        and ControlRes^.fCalculateBobsExtraVariations then
        begin // create validation file for extra sumirr weightings
             {iDebugFile := 0;
             repeat
                   Inc(iDebugFile);

             until not fileexists(ControlRes^.sWorkingDirectory +
                                  '\ExtraSumirrWeightings' +
                                  IntToStr(iDebugFile) +
                                  '.csv');}
             assignfile(DebugFile,ControlRes^.sWorkingDirectory +
                                  '\ExtraSumirrWeightings' +
                                  IntToStr(iMinsetIterationCount) +
                                  '.csv');
             rewrite(DebugFile);
             write(DebugFile,'SiteIndex,FeatureIndex,InitialAvailableCrown,PrivateLandReserved,MaximumAvailableArea,');
             write(DebugFile,'r_Wcr,r_Wpt,r_Wit,r_Wvu,r_Wsa,r_Wpa,_,rWcr,rWpt,rWcrWit,rWcrWvu,');
             writeln(DebugFile,'rWcrWitWvu,rWsa,rWsaWpa,rWsaWpt,rWpaWpt');
             closefile(DebugFile);
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
             // If we run this during a minset, it will ignore any possible
             // destruction and stuff up the destruction calcs.

             InitDefExcSum;
             GetExcManSel;
             PrepIrrepData(True);
        end;

        if (not fComplementarity) then
           SetNoComplementarityTargets;

        fCancel := False;

        iAvailableSiteCount := ControlForm.Available.Items.Count +
                               ControlForm.Flagged.Items.Count;

        iReserved := ControlForm.Partial.Items.Count +
                     ControlForm.R1.Items.Count +
                     ControlForm.R2.Items.Count +
                     ControlForm.R3.Items.Count +
                     ControlForm.R4.Items.Count +
                     ControlForm.R5.Items.Count;
        iRestOfSites := iReserved +
                        ControlForm.Excluded.Items.Count;

        AdjustCombinationSizeForReserves(ControlRes^.LastCombinationSizeCondition);
        iOldCS := combsize.iActiveCombinationSize;

        WriteCombsizeDebug('ExecuteIrreplaceability');

        // take into account effect of excluded sites
        {if (combsize > (ControlForm.Available.Items.Count + ControlForm.Flagged.Items.Count)) then
           combsize := ControlForm.Available.Items.Count + ControlForm.Flagged.Items.Count;}

        init_irr_variables(combsize.iActiveCombinationSize,iAvailableSiteCount);

        if fUserUpdates then
        begin
             ControlForm.ProgressOn;
             ControlForm.ProcLabelOn('Irreplaceability');
        end;

        {$IFDEF REPORTTIME}
        if ControlRes^.fReportTime then
           ReportTime('before Irreplaceability');
        {$ENDIF}

        fBreakExecution := False;
        fSiteBreakExecution := False;
        rMaxAvFlSumirr := 0;

        fValidateIteration := False;

        {$IFDEF SPARSE_MATRIX_2}
        rValue := 0;
        FeatureIrrep := Array_t.Create;
        FeatureIrrep.init(SizeOf(extended),iFeatureCount);
        for lLocalSite := 1 to iFeatureCount do
            FeatureIrrep.setValue(lLocalSite,@rValue);
        {$ENDIF}

        // trigger cs recalc for excluded sites if required
        if (ControlForm.Excluded.Items.Count > 0)
        and (not ControlRes^.fSuppressCSExclusionRecalc) then
        begin
             Trigger := TriggerExcludedSite;
             fBreakExecution := True;
        end
        else
        try
           iBreakSiteKey := 0;
           iBreakFeatureKey := 0;

           for lLocalSite:=1 to iSiteCount do
           begin
                if fUserUpdates then
                   ControlForm.ProgressUpdate(Round(lLocalSite/iSiteCount*100));

                dDouble := predict_sf4(lLocalSite,FeatureIrrep,ControlRes^.fValidateIrreplaceability,
                                       fBreakExecution,
                                       fValidateIteration{fComprehensiveDebug},
                                       fIncludeFeatureArea,
                                       sValidateFileName{sDebugFileName},
                                       True);
                if fBreakExecution then
                   Break;
           end;

        finally

        end;

        if fSiteBreakExecution
        and (rMaxAvFlSumirr = 0) then
            fBreakExecution := True;

        if fBreakExecution then
        begin
             if fUserUpdates then
             begin
                  ControlForm.ProgressOff;
                  ControlForm.ProcLabelOff;
             end;
             // Execution was stopped in the irreplaceability run.
             // We must recalculate combination size using the current
             // effective targets.

             if (Trigger <> TriggerExcludedSite)
             and fSiteBreakExecution
             and (rMaxAvFlSumirr = 0) then
                 Trigger := TriggerZeroAvSumirr
             else
                 Trigger := TriggerTargetCannotBeMet;

             //if ControlRes^.fValidateMinset then
                WriteMsgToFile(ControlRes^.sWorkingDirectory + '\trigger_' + IntToStr(iMinsetIterationCount) + '.txt',
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

             init_irr_variables(combsize.iActiveCombinationSize,iAvailableSiteCount);

//current combination size = X
//new current combination size = Y
//original pre-reserve combination size = Z
//new pre-reserve combination size = T
               
             if ControlRes^.fDisplayCSTriggerPopup then
                // popup window
                if (mrCancel = MessageDlg('Combination size override from ' + IntToStr(iOldCS) + ' to ' + IntToStr(combsize.iCurrentSelectedCombinationSize) + Chr(10) + Chr(13) + 'Press cancel if you don''t want these warnings anymore.',mtInformation,[mbOk,mbCancel],0)) then
                begin
                     ControlRes^.fDisplayCSTriggerPopup := False;
                     fIniChange := True;
                end;
             WriteCombsizeDebug('ExecuteIrreplaceability_Break');

             // make custom cs
             ControlRes^.fCustomCombSize := True;
             combsize.iCustomCombinationSize := combsize.iActiveCombinationSize +
                                                ControlForm.R1.Items.Count +
                                                ControlForm.R2.Items.Count +
                                                ControlForm.R3.Items.Count +
                                                ControlForm.R4.Items.Count +
                                                ControlForm.R5.Items.Count +
                                                ControlForm.Partial.Items.Count +
                                                ControlForm.Excluded.Items.Count;
             // make reduce by reserves true
             ControlRes^.fLockUserDefinedCombinationSize := False;

             // Now rerun irreplaceability
             ControlForm.ProgressOn;
             ControlForm.ProcLabelOn('Irreplaceability');
             fBreakExecution := False;
             for lLocalSite:=1 to iSiteCount do
             begin
                  if fUserUpdates then
                     ControlForm.ProgressUpdate(Round(lLocalSite/iSiteCount*100));

                  dDouble := predict_sf4(lLocalSite,FeatureIrrep,ControlRes^.fValidateIrreplaceability,
                                         fBreakExecution,
                                         fValidateIteration,
                                         fIncludeFeatureArea,
                                         sValidateFileName,
                                         True);
             end;
        end;

        {$IFDEF SPARSE_MATRIX_2}
        FeatureIrrep.Destroy;
        {$ENDIF}

        if fUserUpdates then
        begin
             ControlForm.ProgressOff;
             ControlForm.ProcLabelOff;

             if ControlRes^.fConnectedToSPATTOOL then
             begin
                  ControlForm.ProcLabel.Visible := True;
                  ControlForm.ProcLabel.Caption := 'Calculating Spatial Context Indices';
                  ControlForm.ProcLabel.Update;

                  // set the radius and exponent in the SPATTOOL
                  //DDESendCmd(SpatIOModule.CPlanSpatClient,
                  //           'radius ' + IntToStr(ControlRes^.iSpatialContribRadius));
                  //DDESendCmd(SpatIOModule.CPlanSpatClient,
                  //           'exponent ' + FloatToStr(ControlRes^.rSpatialContribExponent));

                  // Send the contrib request to SPATTOOL
                  SpatIOModule.SendContribRequest;

                  // Exit now, because C-Plan will update the database after receiving
                  // the result from SPATTOOL
                  Exit;
             end;

             if not fCancel then
             begin
                  {$IFNDEF SPARSE_MATRIX_2}
                  MapPCUSED2Array;
                  {$ENDIF}

                  if ControlRes^.fFeatureClassesApplied then
                     MapMemoryVariable2Display(ControlRes^.iGISPlotField,
                                               ControlForm.SubsetGroup.ItemIndex,
                                               ControlRes^.iDisplayValuesFor, {option for display Available/Deferred}
                                               5, {divide middle values into 5 categories}
                                               SiteArr, iSiteCount,
                                               iIr1Count, i001Count, i002Count,
                                               i003Count, i004Count, i005Count,
                                               i0CoCount)
                  else
                      MapMemoryVariable2Display(ControlRes^.iGISPlotField,
                                                0,
                                                ControlRes^.iDisplayValuesFor, {option for display Available/Deferred}
                                                5, {divide middle values into 5 categories}
                                                SiteArr, iSiteCount,
                                                iIr1Count, i001Count, i002Count,
                                                i003Count, i004Count, i005Count,
                                                i0CoCount);

                  ControlForm.UpdateDatabase(True);
                  ControlForm.InformGIS;
             end;
        end;

        if (not fComplementarity) then
           SetNoComplementarityTargets;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception while recalculating indices',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure RunIrrepVariComb(const iCurrentCombsize : integer);
var
   dDouble : extended;
   lLocalSite, iLocalFeat : longint;
   FeatureIrrep : Array_T;
   rValue : extended;
   fBreakExecution : boolean;
   iVariableCombinationSize : integer;
begin
     if fContrDoneOnce then
     else
     begin
          {we need to allocate fixed size memory objects that will
           be used for 1 or more iterations to store data,
           namely LocalRepr}

          LocalRepr := Array_t.Create;
          LocalRepr.init(SizeOf(Repr),iFeatureCount);
     end;

     InitDefExcSum;
     GetExcManSel;

     PrepIrrepData(False);

     iAvailableSiteCount := ControlForm.Available.Items.Count +
                    ControlForm.Flagged.Items.Count;

     combsize.iActiveCombinationSize := iCurrentCombsize;

     init_irr_variables(combsize.iActiveCombinationSize,iAvailableSiteCount);

     {$IFDEF RPT_SUM_IRR}
     ReptSumIrr(0,'SumIrr start');
     {$ENDIF}

     {$IFDEF SPARSE_MATRIX_2}
     FeatureIrrep := Array_t.Create;
     FeatureIrrep.init(SizeOf(extended),iFeatureCount);
     rValue := 0;
     for iLocalFeat:=1 to iFeatureCount do
         FeatureIrrep.setValue(iLocalFeat,@rValue);
     {$ENDIF}

     ControlForm.ProgressOn;
     ControlForm.ProcLabelOn('Irreplaceability');
     fBreakExecution := False;

     for lLocalSite:=1 to iSiteCount do
     begin
          ControlForm.ProgressUpdate(Round(lLocalSite/iSiteCount*100));

          dDouble := predict_sf4(lLocalSite,FeatureIrrep,ControlRes^.fValidateIrreplaceability,
                                 fBreakExecution,False,False,'',
                                 True);
     end;

     {$IFDEF SPARSE_MATRIX_2}
     FeatureIrrep.Destroy;
     {$ENDIF}

     ControlForm.ProgressOff;
     ControlForm.ProcLabelOff;

     {$IFNDEF SPARSE_MATRIX_2}
     MapPCUSED2Array;
     {$ENDIF}
     if ControlRes^.fFeatureClassesApplied then
        MapMemoryVariable2Display(ControlRes^.iGISPlotField,
                                  ControlForm.SubsetGroup.ItemIndex,
                                  ControlRes^.iDisplayValuesFor, {option for display Available/Deferred}
                                  5, {divide middle values into 5 categories}
                                  SiteArr, iSiteCount,
                                  iIr1Count, i001Count, i002Count,
                                  i003Count, i004Count, i005Count,
                                  i0CoCount)
     else
         MapMemoryVariable2Display(ControlRes^.iGISPlotField,
                                   0,
                                   ControlRes^.iDisplayValuesFor, {option for display Available/Deferred}
                                   5, {divide middle values into 5 categories}
                                   SiteArr, iSiteCount,
                                   iIr1Count, i001Count, i002Count,
                                   i003Count, i004Count, i005Count,
                                   i0CoCount);
end;

end.
