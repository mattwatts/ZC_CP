unit In_order;

{$I STD_DEF.PAS}

{$UNDEF DEBUG_CALC_DEFERR}

{$UNDEF DEBUG_LOG_LIST}

interface

uses
    Global, Em_newu1, Control, Forms,
    Controls,
    ds;


procedure BuildStageList(var StageList : Array_T);
procedure UpdateLog2ListBoxes;
procedure BuildLogList(var iListLen : integer;
                       const fDebug : boolean);
function FindFollowingDeSelect(const iGeo, iFrom, iTo : integer) : boolean;

{******************************************************************************}
procedure InOrderContrib(const iListLen : integer;
                         const fShowProgress : boolean);
{traverses the log list and Deferrs and Deselects site
 also returns result set which is Contrib of all sites
 remaining as deferred}

{$IFDEF SPARSE_MATRIX_2}
{$ELSE}
function CalcDeferr(var ASCust : SiteCust_T;
                    const iKey : integer) : FeatureCust_T;
{defers a site and calculates its contribution,
 adjusts targetarea based on this (targetarea can be negative)}
function CalcPartDeferr(var ASCust : SiteCust_T;
                        const iKey : integer) : FeatureCust_T;
{partially defers a site and calculates its partial contribution
 and potential contribution of non-deferred features}
procedure CalcDeSelect(const iKey : integer);
{de-selects a site , works for excluded sites,
 works for partial deferral by adjusting only features flagged,
 adjusts targetarea (can be negative)}
procedure BuildDeferralStageList(var DeferralStageList, StageList : Array_T);
{$ENDIF}
function RepdFeaturePercent : extended;
procedure BuildSelectionList(var SelectionList : Array_t;
                             var iListLen : integer);

var
   iPCUSEDCutOff, iDebugLogList : integer;


implementation

uses
    Contribu, Dialogs, Choices, Toolmisc,
    SysUtils, StdCtrls,
    opt1;

function FindFollowingDeSelect(const iGeo, iFrom, iTo : integer) : boolean;
var
   iCnt : integer;
   sToFind : string;
begin
     Result := False;

     sToFind := CHOICE_CODE_DESELECT + IntToStr(iGeo);

     {iLogPos is zero referenced}

     {traverse remainder of log looking for
      de-select choice for sGeo}
     if (iFrom < iTo) then
        for iCnt := iFrom to iTo do
            if (sToFind =
                ChoiceForm.ChoiceLog.Items.Strings[iCnt]) then
               Result := True;
end;

procedure BuildStageList(var StageList : Array_T);
{
Procedure : BuildStageList
Author : Matthew Watts

Purpose : To extract a list of stages from the selection log

Method : Traverse the Selection Log and build up a list of the stages
         which are assigned to each selection and the frequency of each
         stage in the Selection Log

Date : Fri Nov 7th 1997
}

var
   iCount, iStageListLength : integer;
   sStage : string;

   function AddStage(const sStage : string) : boolean;
   {Returns : TRUE if sStage was already in the list and was incremented
              FALSE if sStage was not in the list and was added to the list}
   var
      iCnt : integer;
      AEntry : StageEntry_T;
   begin
        Result := False;

        {test if sStage is already in the StageList}
        if (iStageListLength > 0) then
           for iCnt := 1 to iStageListLength do
           begin
                StageList.rtnValue(iCnt,@AEntry);

                if (AEntry.sStageName = sStage) then
                begin
                     {increment iSelectionsInStage for this stage
                      which is already in the StageList}
                     Result := True;
                     Inc(AEntry.iSelectionsInStage);
                     StageList.setValue(iCnt,@AEntry);
                end;
           end;

        if (not result) then
        begin
             {we need to add this stage to the end of the list and set its
              frequency to 1}
             AEntry.sStageName := sStage;
             AEntry.iSelectionsInStage := 1;
             Inc(iStageListLength);
             if (iStageListLength > StageList.lMaxSize) then
                StageList.resize(StageList.lMaxSize + ARR_STEP_SIZE);
             StageList.setValue(iStageListLength,@AEntry);
        end;
   end;


begin {of BuildStageList}

     {build a log list from the choice log}
     try
        StageList := Array_t.Create;
        StageList.init(SizeOf(StageEntry_T),ARR_STEP_SIZE);
        iStageListLength := 0;

        with ChoiceForm.ChoiceLog.Items do
             if (Count > 0) then
                for iCount := 0 to (Count-1) do
                begin
                     if (Strings[iCount][1] = CHOICE_MESSAGE) then
                     begin
                          {this is a message line and may be a stage name}

                          if (Length(Strings[iCount])>7) then
                             if (Copy(Strings[iCount],2,6) = 'stage ') then
                             begin
                                  sStage := Copy(Strings[iCount],8,Length(Strings[iCount])-7);
                                  if (sStage <> 'no stage specified') then
                                     AddStage(sStage);
                             end;
                     end;
                end;

        if (iStageListLength = 0) then
        begin
             {resize array to 1 to save on memory}
             StageList.resize(1);
             {set lMaxSize to 0 if there are no elements,
              calling function will dispose of StageList}
             StageList.lMaxSize := 0;
        end
        else
            {set lMaxSize to reflect the actual number of stages found in the log}
            if (iStageListLength <> StageList.lMaxSize) then
               StageList.resize(iStageListLength);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in BuildStageList',mtError,[mbOk],0);
     end;

end; {of BuildStageList}

procedure UpdateLog2ListBoxes;
var
   iAGeo, iCount, iSiteIndex, iListLen : integer;
   fInsert : boolean;
   iDummy : integer;
   sCompare, sLine, sLineToTest : string;
   pSite : sitepointer;

   function CustSearchLog(const iGeo : integer;
                          const StatusToSearch : Status_T) : boolean;

      function SearchFor(ABox : TListbox) : boolean;
      var
         iCnt : integer;
      begin
           Result := False;
           if (ABox.Items.Count > 0) then
              for iCnt := 0 to (ABox.Items.Count-1) do
                  if (IntToStr(iGeo) = ABox.Items.Strings[iCnt]) then
                     Result := True;
      end;

   begin
        Result := False;

        case StatusToSearch of

             _R1 : Result := SearchFor(ControlForm.R1Key);
             _R2 : Result := SearchFor(ControlForm.R2Key);
             _R3 : Result := SearchFor(ControlForm.R3Key);
             _R4 : Result := SearchFor(ControlForm.R4Key);
             _R5 : Result := SearchFor(ControlForm.R5Key);
             Pd : Result := SearchFor(ControlForm.PartialKey);
             Fl : Result := SearchFor(ControlForm.FlaggedKey);
             Ex : Result := SearchFor(ControlForm.ExcludedKey);
             Av : Result := SearchFor(ControlForm.AvailableKey);
        end;
   end;

begin
     iDummy := 0;

     try
        new(pSite);

        {clear the site Name and Key listboxes}
        ControlForm.R1.Items.Clear;
        ControlForm.R1Key.Items.Clear;
        ControlForm.R2.Items.Clear;
        ControlForm.R2Key.Items.Clear;
        ControlForm.R3.Items.Clear;
        ControlForm.R3Key.Items.Clear;
        ControlForm.R4.Items.Clear;
        ControlForm.R4Key.Items.Clear;
        ControlForm.R5.Items.Clear;
        ControlForm.R5Key.Items.Clear;
        ControlForm.Partial.Items.Clear;
        ControlForm.PartialKey.Items.Clear;
        ControlForm.Flagged.Items.Clear;
        ControlForm.FlaggedKey.Items.Clear;
        ControlForm.Excluded.Items.Clear;
        ControlForm.ExcludedKey.Items.Clear;
        ControlForm.Available.Items.Clear;
        ControlForm.AvailableKey.Items.Clear;

        {change all sites with Tenure Available to Status Ur}
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);
             if (pSite^.status <> Re)
             and (pSite^.status <> Ig) then
                 pSite^.status := Av;
             SiteArr.setValue(iCount,pSite);
        end;

        with ChoiceForm.ChoiceLog.Items do
             if (Count > 0) then
                for iCount := 0 to (Count-1) do
                {iterate the choice log line by line}
                begin
                     fInsert := False;

                     sLine := Strings[iCount];
                     sCompare := Copy(sLine,1,1);

                     if (sCompare = CHOICE_CODE_DEFERR) then
                     begin
                          fInsert := True;

                          iAGeo := StrToInt(Copy(sLine,
                                            2,
                                            Length(sLine)-1));

                          iSiteIndex := FindFeatMatch(OrdSiteArr,iAGeo);
                          SiteArr.rtnValue(iSiteIndex,pSite);

                          pSite^.status := rtnLogStatus(sLineToTest{sLine});

                          SiteArr.setValue(iSiteIndex,pSite);

                          if fInsert then
                             fInsert := not CustSearchLog(iAGeo,pSite^.status);

                          if fInsert then
                             fInsert := not FindFollowingDeSelect(iAGeo,iCount+1,Count-1);

                          if fInsert then
                          begin
                               Inc(iListLen);

                               {add pSite to }
                               case pSite^.status of
                                    _R1 :
                                    begin
                                         ControlForm.R1.Items.Add(pSite^.sName);
                                         ControlForm.R1Key.Items.Add(IntToStr(pSite^.iKey));
                                    end;
                                    _R2 :
                                    begin
                                         ControlForm.R2.Items.Add(pSite^.sName);
                                         ControlForm.R2Key.Items.Add(IntToStr(pSite^.iKey));
                                    end;
                                    _R3 :
                                    begin
                                         ControlForm.R3.Items.Add(pSite^.sName);
                                         ControlForm.R3Key.Items.Add(IntToStr(pSite^.iKey));
                                    end;
                                    _R4 :
                                    begin
                                         ControlForm.R4.Items.Add(pSite^.sName);
                                         ControlForm.R4Key.Items.Add(IntToStr(pSite^.iKey));
                                    end;
                                    _R5 :
                                    begin
                                         ControlForm.R5.Items.Add(pSite^.sName);
                                         ControlForm.R5Key.Items.Add(IntToStr(pSite^.iKey));
                                    end;
                                    Pd :
                                    begin
                                         ControlForm.Partial.Items.Add(pSite^.sName);
                                         ControlForm.PartialKey.Items.Add(IntToStr(pSite^.iKey));
                                    end;
                                    Fl :
                                    begin
                                         ControlForm.Flagged.Items.Add(pSite^.sName);
                                         ControlForm.FlaggedKey.Items.Add(IntToStr(pSite^.iKey));
                                    end;
                                    Ex :
                                    begin
                                         ControlForm.Excluded.Items.Add(pSite^.sName);
                                         ControlForm.ExcludedKey.Items.Add(IntToStr(pSite^.iKey));
                                    end;
                                    (*Av :
                                    begin
                                         {MessageDlg('error in Log UpdateLog2ListBoxes',mtError,[mbOk],0);}
                                         {ControlForm.Available.Items.Add(pSite^.sName);
                                         ControlForm.AvailableKey.Items.Add(IntToStr(pSite^.iKey));}
                                    end;*)
                               end;
                          end
                          else
                          begin
                               {ControlForm.Available.Items.Add(pSite^.sName);
                               ControlForm.AvailableKey.Items.Add(IntToStr(pSite^.iKey));}
                          end;
                     end
                     else
                     if (sCompare = CHOICE_MESSAGE) then
                     begin
                          if (iCount > 0) then
                          begin
                               if (Copy(Strings[iCount-1],1,1) <> CHOICE_MESSAGE) then
                                  sLineToTest := Strings[iCount+1];
                          end
                          else
                          begin
                               sLineToTest := Strings[iCount+1];
                          end;
                     end;
                end;


        {add all available sites to the Available listboxes}
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);
             if (pSite^.status = Av) then
             begin
                  ControlForm.Available.Items.Add(pSite^.sName);
                  ControlForm.AvailableKey.Items.Add(IntToStr(pSite^.iKey));
            end;
        end;

     except
           MessageDlg('Exception in UpdateLog2ListBoxes',mtError,[mbOk],0);
     end;

     dispose(pSite);
end;

procedure BuildSelectionList(var SelectionList : Array_t;
                             var iListLen : integer);
var
   LogEntry : SelectionEntry_T;
   iAGeo, iCount, iSiteIndex, iSelection : integer;
   fInsert : boolean;
   iDummy : integer;
   sCompare, sLine, sPrevious : string;
   pSite : sitepointer;
   DebugFile : TextFile;

   function CustSearchLog(const iKey : integer) : boolean;
   var
      iCnt : integer;
      AEntry : LogEntry_T;
   begin
        Result := False;
        if (iListLen > 0) then
           for iCnt := 1 to iListLen do
           begin
                SelectionList.rtnValue(iCnt,@AEntry);
                if (AEntry.iKey = iKey) then
                   Result := True;
           end;
   end;

begin
     try
        {build a log list from the choice log}

        SelectionList := Array_t.Create;
        SelectionList.init(SizeOf(LogEntry),ARR_STEP_SIZE);
        iDummy := 0;
        iListLen := 0;
        iSelection := 0;

        LogEntry.wType := 0;
        LogEntry.iKey := -1;
        LogEntry.iSelection := -1;

        new(pSite);

        with ChoiceForm.ChoiceLog.Items do
             if (Count > 0) then
                for iCount := 0 to (Count-1) do
                begin
                     fInsert := False;

                     sLine := Strings[iCount];
                     sCompare := Copy(sLine,1,1);

                     // the status of the selections is being confused
                     // R1/R2 are being confused with Ex, and maybe other classes
                     // sites may be being duplicated in the list when they are subsequent de-selected or re-selected
                     if (sCompare = CHOICE_CODE_DEFERR) then
                     begin
                          // selection is being incremented to 1, then not incremented at all from there
                          // ie. all selections are being scored as selection 1
                          if (sCompare <> sPrevious) then
                             Inc(iSelection);

                          sPrevious := sCompare;

                          LogEntry.wType := LOG_DEFERR;
                          fInsert := True;

                          iAGeo := StrToInt(Copy(sLine,
                                        2,
                                        Length(sLine)-1));

                          iSiteIndex := FindFeatMatch(OrdSiteArr,iAGeo);
                          SiteArr.rtnValue(iSiteIndex,pSite);

                          if fInsert then
                             fInsert := not CustSearchLog(iAGeo);

                          if fInsert then
                             fInsert := not FindFollowingDeSelect(iAGeo,iCount+1,Count-1);

                          if fInsert then
                          begin
                               Inc(iListLen);

                               if (iListLen > SelectionList.lMaxSize) then
                                  SelectionList.resize(SelectionList.lMaxSize + ARR_STEP_SIZE);
                               LogEntry.iSelection := iSelection;
                               LogEntry.iKey := iAGeo;
                               SelectionList.setValue(iListLen,@LogEntry);
                          end;
                     end;
                end;
        if (iListLen > 0) then
        begin
             if (iListLen <> SelectionList.lMaxSize) then
                SelectionList.resize(iListLen);
        end;
        dispose(pSite);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in BuildSelectionList',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure BuildLogList(var iListLen : integer;
                       const fDebug : boolean);
var
   LogEntry : LogEntry_T;
   iAGeo, iCount, iSiteIndex : integer;
   fInsert : boolean;
   iDummy : integer;
   sCompare, sLine : string;
   pSite : sitepointer;
   DebugFile : TextFile;

   function CustSearchLog(const iGeo : integer) : boolean;
   var
      iCnt : integer;
      AEntry : LogEntry_T;
   begin
        Result := False;

        if (iListLen > 0) then
           for iCnt := 1 to iListLen do
           begin
                LogList.rtnValue(iCnt,@AEntry);

                if (AEntry.iKey = iGeo) then
                   Result := True;
           end;
   end;


begin
     try
        if fDebug then
        begin
             Inc(iDebugLogList);
             assignfile(DebugFile,ControlRes^.sWorkingDirectory +
                                  '\debug_log_list_' +
                                  IntToStr(iDebugLogList) +
                                  '.csv');
             rewrite(DebugFile);
             writeln(DebugFile,'LogIndex,SiteKey,LogType');
        end;

        {build a log list from the choice log}

        LogList := Array_t.Create;
        LogList.init(SizeOf(LogEntry),ARR_STEP_SIZE);
        iDummy := 0;
        iListLen := 0;

        LogEntry.wType := 0;
        LogEntry.iKey := -1;

        new(pSite);

        with ChoiceForm.ChoiceLog.Items do
             if (Count > 0) then
                for iCount := 0 to (Count-1) do
                begin
                     fInsert := False;

                     sLine := Strings[iCount];
                     sCompare := Copy(sLine,1,1);

                     if (sCompare = CHOICE_CODE_DEFERR) then
                     begin
                          LogEntry.wType := LOG_DEFERR;
                          fInsert := True;

                          iAGeo := StrToInt(Copy(sLine,
                                        2,
                                        Length(sLine)-1));

                          iSiteIndex := FindFeatMatch(OrdSiteArr,iAGeo);
                          SiteArr.rtnValue(iSiteIndex,pSite);

                          if fInsert then
                             fInsert := not CustSearchLog(iAGeo);

                          if fInsert then
                             fInsert := not FindFollowingDeSelect(iAGeo,iCount+1,Count-1);

                          if fInsert then
                          begin
                               Inc(iListLen);

                               if (iListLen > LogList.lMaxSize) then
                                  LogList.resize(LogList.lMaxSize + ARR_STEP_SIZE);

                               LogEntry.iKey := iAGeo;
                               LogList.setValue(iListLen,@LogEntry);

                               if fDebug then
                               begin
                                    if (LogEntry.wType = LOG_DEFERR) then
                                       writeln(DebugFile,IntToStr(iCount+1) + ',' + IntToStr(LogEntry.iKey) + ',LOG_DEFERR')
                                    else
                                        writeln(DebugFile,IntToStr(iCount+1) + ',' + IntToStr(LogEntry.iKey) + ',other');
                               end;
                          end;
                     end;
                end;

        if (iListLen > 0) then
        begin
             if (iListLen <> LogList.lMaxSize) then
                LogList.resize(iListLen);
        end;

        {traverse the choice log building a loglist}
        dispose(pSite);

        if fDebug then
           closefile(DebugFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in BuildLogList',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

{******************************************************************************}

function CalcDeferr(var ASCust : SiteCust_T;
                    const iKey : integer) : boolean;
{defers a site and calculates its contribution,
 adjusts targetarea for the sites features
 based on deferral (targetarea can be negative)
 does not adjust site status}
var
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   iSiteIndex, iFeatIndex, iCount : integer;
   rInSite,rStillNeeded : extended;
   iAmountIndex : integer;
   Value : ValueFile_T;
   rValue : extended;
begin
     new(pSite);
     new(pFeat);

     iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
     SiteArr.rtnValue(iSiteIndex,pSite);

     ASCust.iCode := pSite^.iKey;
     ASCust.rPercentUsed := 0;

     if (pSite^.richness > 0) then
        for iCount := 1 to pSite^.richness do
        begin
             FeatureAmount.rtnValue(pSite^.iOffset + iCount,@Value);
             iFeatIndex := FindFeature(Value.iFeatKey);
             FeatArr.rtnValue(iFeatIndex,pFeat);

             if (pFeat^.targetarea > 0) then
             begin
                  rInSite := Value.rAmount;
                  rStillNeeded := pFeat^.targetarea;
                  if (rStillNeeded > rInSite) then
                     rStillNeeded := rInSite;

                  if (pFeat^.code <= iPCUSEDCutOff) then
                     ASCust.rPercentUsed := ASCust.rPercentUsed +
                                            rStillNeeded;

                  rValue := rInSite / pFeat^.targetarea * 100;
                  SparseContribution.setValue(pSite^.iOffSet + iCount,@rValue);
             end;

             pFeat^.targetarea := pFeat^.targetarea -
                                  Value.rAmount;
             FeatArr.setValue(iFeatIndex,pFeat);
        end;

     if (pSite^.area > 0) then
        ASCust.rPercentUsed := ASCust.rPercentUsed / pSite^.area * 100;

     if (ASCust.rPercentUsed > 100) then
        ASCust.rPercentUsed := 100;

     ASCust.rValue2 := RepdFeaturePercent;

     dispose(pSite);
     dispose(pFeat);
end;

function CalcPartDeferr(var ASCust : SiteCust_T;
                        const iKey : integer) : boolean;
{partially defers a site and calculates its partial contribution
 and potential contribution of non-deferred features}
var
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   iSiteIndex, iFeatIndex, iCount : integer;
   rValue, rStillNeeded : extended;
   Value : ValueFile_T;
begin
     new(pSite);
     new(pFeat);

     iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
     SiteArr.rtnValue(iSiteIndex,pSite);

     ASCust.iCode := pSite^.iKey;
     ASCust.rPercentUsed := 0;

     if (pSite^.richness > 0) then
        for iCount := 1 to pSite^.richness do
        begin
             FeatureAmount.rtnValue(pSite^.iOffset + iCount,@Value);
             iFeatIndex := Value.iFeatKey;
             FeatArr.rtnValue(iFeatIndex,pFeat);

             if true then
             begin
                  {this feature is deferred, use targetarea}
                  if (pFeat^.targetarea > 0) then
                  begin
                       rValue := Value.rAmount / pFeat^.targetarea * 100;
                       SparseContribution.setValue(pSite^.iOffSet + iCount,@rValue);
                  end;

                  pFeat^.targetarea := pFeat^.targetarea -
                                       Value.rAmount;

                  FeatArr.setValue(iFeatIndex,pFeat);
             end
             else
             begin
                  {this feature is available, use rCurrentEffTarg}
                  if (pFeat^.rCurrentEffTarg > 0) then
                  begin
                       rStillNeeded := pFeat^.rCurrentEffTarg;
                       if (rStillNeeded > Value.rAmount) then
                          rStillNeeded := Value.rAmount;

                       if (pFeat^.code <= iPCUSEDCutOff) then
                          ASCust.rPercentUsed := ASCust.rPercentUsed +
                                                 rStillNeeded;

                       rValue := Value.rAmount / pFeat^.rCurrentEffTarg * 100;
                       SparseContribution.setValue(pSite^.iOffSet + iCount,@rValue);
                  end;
             end;
        end;

     if (pSite^.area > 0) then
        ASCust.rPercentUsed := ASCust.rPercentUsed / pSite^.area * 100;

     if (ASCust.rPercentUsed > 100) then
        ASCust.rPercentUsed := 100;

     ASCust.rValue2 := RepdFeaturePercent;

     dispose(pSite);
     dispose(pFeat);
end;

procedure CalcExcludeSites;
var
   pFeat : featureoccurrencepointer;
   iCount,x : integer;
   fDebug : boolean;
   fTrace : boolean;
   iTrace : integer;
begin
     if (ControlForm.Excluded.Items.Count > 0) then
     try
        new(pFeat);

        for iCount := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iCount,pFeat);

             {if rCurrentSumArea is less than targetarea, reduce targetarea to }

             if (pFeat^.rExcluded > 0)
             and (pFeat^.targetarea > 0)
             and ((pFeat^.rCurrentSumArea + pFeat^.rDeferredArea) < pFeat^.targetarea) then
             begin
                  pFeat^.targetarea := pFeat^.rCurrentSumArea + pFeat^.rDeferredArea;
                  FeatArr.setValue(iCount,pFeat);
             end;
        end;

        dispose(pFeat);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CalcExcludeSites',mtError,[mbOk],0);
     end;
end;

function ResFeaturePercent : extended;
var
   iCount, iNumRepd : integer;

   iTotalNonZeroFeats : integer;

   AFeat : featureoccurrence;
begin
     iNumRepd := 0;

     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,@AFeat);

          if (AFeat.rTrimmedTarget <> 0)
          and (AFeat.rInitialAvailableTarget <= 0) then
              Inc(iNumRepd);
     end;

     iTotalNonZeroFeats := iFeatureCount -
                           iZeroTrimmedTargetCount;

     if (iTotalNonZeroFeats > 0) then
        Result := (iNumRepd / iTotalNonZeroFeats) * 100
     else
         Result := 0;
end;

procedure CalcDeSelect(const iKey : integer);
{de-selects a site ,
 works for partial deferral by adjusting only features flagged,
 adjusts targetarea (can be negative)}
var
   ASite : site;
   AFeat : featureoccurrence;
   iSiteIndex, iFeatIndex, iCount : integer;
   Value : ValueFile_T;
begin
     iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
     SiteArr.rtnValue(iSiteIndex,@ASite);

     if (ASite.richness > 0) then
        for iCount := 1 to ASite.richness do
        begin
             FeatureAmount.rtnValue(ASite.iOffset + iCount,@Value);
             iFeatIndex := FindFeature(Value.iFeatKey);
             FeatArr.rtnValue(iFeatIndex,@AFeat);

             AFeat.targetarea := AFeat.targetarea +
                                 Value.rAmount;
             FeatArr.setValue(iFeatIndex,@AFeat);
        end;
end;

{$IFDEF SPARSE_MATRIX_2}
{$ELSE}
procedure BuildDeferralStageList(var DeferralStageList, StageList : Array_T);
{
Author : Matthew Watts

Purpose : To determine which stage each deferred site was selected in

Method :

Date : Fri Nov 7th 1997
}

var
   iCount, iStageListLength, iStageDeferred, iIndexOfStage, iIndexOfSite : integer;
   sStage : string;
   pSite : sitepointer;

   function AddStage(const sStage : string;
                     var iStageIndex : integer) : boolean;
   {Returns : TRUE if sStage was already in the list and was incremented
              FALSE if sStage was not in the list and was added to the list}
   var
      iCnt : integer;
      AEntry : StageEntry_T;
   begin
        Result := False;

        {test if sStage is already in the StageList}
        if (iStageListLength > 0) then
           for iCnt := 1 to iStageListLength do
           begin
                StageList.rtnValue(iCnt,@AEntry);

                if (AEntry.sStageName = sStage) then
                begin
                     {increment iSelectionsInStage for this stage
                      which is already in the StageList}
                     Result := True;
                     Inc(AEntry.iSelectionsInStage);
                     StageList.setValue(iCnt,@AEntry);
                     iStageIndex := iCnt;
                end;
           end;

        if (not result) then
        begin
             {we need to add this stage to the end of the list and set its
              frequency to 1}
             AEntry.sStageName := sStage;
             AEntry.iSelectionsInStage := 1;
             Inc(iStageListLength);
             if (iStageListLength > StageList.lMaxSize) then
                StageList.resize(StageList.lMaxSize + ARR_STEP_SIZE);
             StageList.setValue(iStageListLength,@AEntry);
             iStageIndex := iStageListLength;
        end;
   end;

   procedure UpdateKeysInSelection(const iPositionInLog, iIndexInStageList : integer);
   var
      iIndexOfSite, iCurrentPos : integer;
      fFound, fPastReason : boolean;
   begin
        {
         - move down in the log from iPositionInLog to end of log or beginning of next selection in log (whichever is first)
         - look up index of each site key found, and change its value in DeferralStageList to iIndexInStageList
        }

        {move past reason in log}
        with ChoiceForm.ChoiceLog.Items do
             if (Count > 0) then
             begin
                  iCurrentPos := 0;
                  fPastReason := False;

                  repeat

                        for iCurrentPos := 0 to (Count-1) do
                        begin
                             if (Strings[iCurrentPos][1] = CHOICE_MESSAGE) then
                             begin
                                  {this is a message line and may be a stage name}
                                  
                             end;
                        end;

                        Inc(iCurrentPos);

                  until fPastReason;
             end;

        {move past site keys in log, processing each key in turn}


   end;


begin {of BuildDeferralStageList}

     {build a log list from the choice log}
     try
        DeferralStageList := Array_t.Create;
        DeferralStageList.init(SizeOf(integer),iSiteCount);

        iStageDeferred := 0;
        for iCount := 1 to iSiteCount do
            DeferralStageList.setValue(iCount,@iStageDeferred);

        iStageListLength := 0;

        with ChoiceForm.ChoiceLog.Items do
             if (Count > 0) then
                for iCount := 0 to (Count-1) do
                begin
                     if (Strings[iCount][1] = CHOICE_MESSAGE) then
                     begin
                          {this is a message line and may be a stage name}

                          if (Length(Strings[iCount])>7) then
                             if (Copy(Strings[iCount],2,6) = 'stage ') then
                             begin
                                  sStage := Copy(Strings[iCount],8,Length(Strings[iCount])-7);
                                  if (sStage <> 'no stage specified') then
                                     AddStage(sStage,iIndexOfStage);

                                  {find all site keys in this selection, look them up,
                                   and set there element to equal the index of sStage in StageList(iIndexOfStage)}
                                  UpdateKeysInSelection(iCount,        {position of stage row in log}
                                                        iIndexOfStage  {index of stage in stage log}
                                                        );
                             end;
                     end;
                end;

        if (iStageListLength = 0) then
        begin
             {resize array to 1 to save on memory}
             StageList.resize(1);
             {set lMaxSize to 0 if there are no elements,
              calling function will dispose of StageList}
             StageList.lMaxSize := 0;
        end
        else
            {set lMaxSize to reflect the actual number of stages found in the log}
            if (iStageListLength <> StageList.lMaxSize) then
               StageList.resize(iStageListLength);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in BuildDeferralStageList',mtError,[mbOk],0);
     end;

end; {of BuildDeferralStageList}
{$ENDIF}

procedure InOrderContrib(const iListLen : integer;
                         const fShowProgress : boolean);
{traverses the loglist and Deferrs and Deselects sites
 also returns result set which is Contrib of all sites
 remaining as deferred}
var
   iCount, iNumForContrib, iSiteIndex, iNumDef : integer;
   LogEntry : LogEntry_T;
   pSite : sitepointer;
   pASCust : ^SiteCust_T;
   DebugFile : TextFile;
begin
     try
        if fShowProgress then
        begin
             ControlForm.ProgressOn;
             ControlForm.ProcLabelOn('In Order Contribution');
        end;

        new(pSite);
        new(pASCust);

        fContrDataDone := True;
        fContrDoneOnce := True;

        CalcExcludeSites; {adjust targetarea for possible excluded sites}
        CalcExcludeTrimAmount;

        with ControlForm do
             iNumForContrib := R1.Items.Count +
                               R2.Items.Count +
                               R3.Items.Count +
                               R4.Items.Count +
                               R5.Items.Count +
                               Partial.Items.Count;
                               {added by InOrderContrib}
        iNumDef := 0;

        rReservedContrib := ResFeaturePercent;

        InitContribData(iListLen);

        if (iListLen > 0) then
        for iCount := 1 to iListLen do
        begin
             if fShowProgress then
                ControlForm.ProgressUpdate(Round((iCount / iListLen) * 100));

             LogList.rtnValue(iCount,@LogEntry);

             iSiteIndex := FindFeatMatch(OrdSiteArr,LogEntry.iKey);
             SiteArr.rtnValue(iSiteIndex,pSite);

             if (pSite^.status = _R1) {current status previously set by GetExcManSel}
             or (pSite^.status = _R2)
             or (pSite^.status = _R3)
             or (pSite^.status = _R4)
             or (pSite^.status = _R5)
             or (pSite^.status = Pd)
             or (pSite^.status = Ex) then
             begin
                  case LogEntry.wType of
                       LOG_DEFERR :
                          begin
                               if (pSite^.status <> Ex) then

                               {CalcExclude(LogEntry.iKey)else}
                               {CalcExclude is redundant,
                                replaced by earlier call to CalcExcludeSites}

                               begin
                                    Inc(iNumDef);

                                    GraphSites.setValue(iNumDef,@LogEntry.iKey);

                                    if (pSite^.status = Pd) then
                                       {pAFCust^ :=} CalcPartDeferr(pASCust^,LogEntry.iKey)
                                    else
                                        {pAFCust^ :=}  CalcDeferr(pASCust^,LogEntry.iKey);

                                    SiteContribution.setValue(iSiteIndex,pASCust);
                                    //GraphContribution.Sites.setValue(iNumDef,pASCust);
                                    //GraphContribution.Features.setValue(iNumDef,pAFCust);
                               end;
                          end;
                       LOG_DESELECT : CalcDeSelect(LogEntry.iKey);
                  else
                      MessageDlg('Unknown flag in InOrderContrib',
                                 mtError,[mbOK],0);
                  end;
             end;
        end;

        if (iNumDef < iListLen)
        and (iNumDef > 0) then
            GraphSites.resize(iNumDef);

        dispose(pSite);
        dispose(pASCust);

        if fShowProgress then
        begin
             ControlForm.ProgressOff;
             ControlForm.ProcLabelOff;
        end;

     except
           Screen.Cursor := crDefault;

           try
              SaveSelections(ControlRes^.sWorkingDirectory + '\in_order_exception.log',False);

              assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\in_order_exception.txt');
              rewrite(DebugFile);

              writeln(DebugFile,'Exception raised.');
              writeln(DebugFile,'');
              writeln(DebugFile,'iCount ' + IntToStr(iCount));
              writeln(DebugFile,'iListLen ' + IntToStr(iListLen));
              writeln(DebugFile,'iSiteIndex ' + IntToStr(iSiteIndex));
              writeln(DebugFile,'iNumDef ' + IntToStr(iNumDef));
              writeln(DebugFile,'');
              writeln(DebugFile,'index,LogEntry.wType,LogEntry.iKey');
              for iCount := 1 to iListLen do
                  writeln(DebugFile,IntToStr(iCount) + ',' +
                                    IntToStr(LogEntry.wType) + ',' +
                                    IntToStr(LogEntry.iKey));
              writeln(DebugFile,'End Of File');

              closefile(DebugFile);
           except
           end;

           MessageDlg('Exception in In Order Contribution',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function RepdFeaturePercent : extended;
{this function counts how many features are represented and returns a real value
 indicating the percentage of features that are represented}
var
   iCount, iNumRepd : integer;
   iTotalNonZeroFeats : integer;
   AFeat : featureoccurrence;
begin
     iNumRepd := 0;

     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,@AFeat);

          if (AFeat.rTrimmedTarget <> 0)
          and (AFeat.targetarea <= 0) then
              Inc(iNumRepd);
     end;

     iTotalNonZeroFeats := iFeatureCount -
                           iZeroTrimmedTargetCount;

     if (iTotalNonZeroFeats > 0) then
        Result := (iNumRepd / iTotalNonZeroFeats) * 100
     else
         Result := 0;
end;

end.
