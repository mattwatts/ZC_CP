unit reinit;

interface

uses
    Global;

procedure ReInitializeInitialValues(const CombinationSizeCondition : CombinationSizeCondition_T);

implementation

uses
    Forms, Controls, SysUtils, Dialogs,
    Ds, Control, Trpt, Sf_irrep, Em_newu1, Pred_sf4,
    Av1, Spatio, Contribu, In_order;


procedure ReInitializeInitialValues(const CombinationSizeCondition : CombinationSizeCondition_T);
// This procedure is for recalculating and storing the initial values for
var
   dDouble : extended;
   lLocalSite : longint;
   fBreakExecution,
   fCancel : boolean;
   iRestOfSites, iReserved : integer;
   FeatureIrreplaceability : Array_T;
   rValue : extended;
   DebugFile : TextFile;

{MAIN procedure for Simon's Irreplaceability run}
begin
     try
        Screen.Cursor := crHourglass;

        {$IFDEF REPORTTIME}
        if ControlRes^.fReportTime then
           InitTimeReport(ControlRes^.sDatabase);
        {$ENDIF}

        ControlForm.Update;

        if fContrDoneOnce then
           {$IFNDEF SPARSE_MATRIX_2}
           FreeContrib(GraphContribution)
           {$ENDIF}
        else
        begin
             LocalRepr := Array_t.Create;
             LocalRepr.init(SizeOf(Repr),iFeatureCount);

        end;

        {$IFDEF REPORTTIME}
        if ControlRes^.fReportTime then
           ReportTime('before PrepIrrepData');
        {$ENDIF}

        // call this instead of PrepIrrepData in order to set feature targets, etc
        // in the initial state
        InitialPrepIrrepData;
        InitDefExcSum;
        GetExcManSel;
        PrepIrrepData(True);

        {$IFDEF SPARSE_MATRIX_2}
        fContrDataDone := True;
        fContrDoneOnce := True;
        {$ENDIF}

        fCancel := False;

        iAvailableSiteCount := ControlForm.Available.Items.Count +
                       ControlForm.Flagged.Items.Count +
                       ControlForm.Partial.Items.Count +
                       ControlForm.R1.Items.Count +
                       ControlForm.R2.Items.Count +
                       ControlForm.R3.Items.Count +
                       ControlForm.R4.Items.Count +
                       ControlForm.R5.Items.Count;

        iReserved := 0;

        iRestOfSites := iReserved +
                        ControlForm.Excluded.Items.Count;

        {$IFDEF REPORTTIME}
        if ControlRes^.fReportTime then
           ReportTime('before select combsize');
        {$ENDIF}

        // calculate the combination size
        combsize.iActiveCombinationSize:=select_combination_size(AverageSite,FeatArr,LocalRepr,
                                               iFeatureCount,
                                               False,ControlRes^.fValidateCombsize,ControlRes^.fPartialValidateCombsize,
                                               CombinationSizeCondition);

        {case CombinationSizeCondition of
             Startup, ExclusionChange, TargetChange,
             UserLoadLog, OverrideChange : combsize.iSelectedCombinationSize := combsize.iActiveCombinationSize;
             MinsetLoadLog, TriggerTargetCannotBeMet,
             TriggerZeroAvSumirr :
             begin

             end;

        end;
        combsize.iActiveCombinationSize := combsize.iSelectedCombinationSize;}
        AdjustCombinationSizeForReserves(ControlRes^.LastCombinationSizeCondition);

        WriteCombsizeDebug('ReInitializeInitialValues');

        init_irr_variables(combsize.iActiveCombinationSize,iAvailableSiteCount);

        ControlForm.ProgressOn;
        ControlForm.ProcLabelOn('Initial Irreplaceability');

        {$IFDEF REPORTTIME}
        if ControlRes^.fReportTime then
           ReportTime('before Initial Irreplaceability');
        {$ENDIF}

        fBreakExecution := False;

        {$IFDEF SPARSE_MATRIX_2}
        rValue := 0;
        FeatureIrreplaceability := Array_t.Create;
        FeatureIrreplaceability.init(SizeOf(extended),iFeatureCount);
        for lLocalSite := 1 to iFeatureCount do
            FeatureIrreplaceability.setValue(lLocalSite,@rValue);
        {$ENDIF}

        try
           for lLocalSite:=1 to iSiteCount do
           begin
                ControlForm.ProgressUpdate(Round(lLocalSite/iSiteCount*100));

                dDouble := predict_sf4(lLocalSite,
                                       {$IFDEF SPARSE_MATRIX_2}
                                       FeatureIrreplaceability,
                                       {$ELSE}
                                       FeatureIrrep,
                                       {$ENDIF}
                                       ControlRes^.fValidateIrreplaceability,
                                       fBreakExecution,
                                       False,
                                       False,
                                       '',
                                       True);
                {if fBreakExecution then
                   Break;}
           end;

        finally

        end;

        {$IFDEF SPARSE_MATRIX_2}
        FeatureIrreplaceability.Destroy;
        {$ENDIF}

        ControlForm.ProgressOff;
        ControlForm.ProcLabelOff;

        {$IFDEF REPORTTIME}
        if ControlRes^.fReportTime then
           FreeTimeReport;
        {$ENDIF}

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception while calculating initial indices',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


end.
