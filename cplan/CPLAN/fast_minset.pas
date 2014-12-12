unit fast_minset;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls;

type
  TFastMinsetForm = class(TForm)
    CheckRedCheck: TCheckBox;
    RadioMinset: TRadioGroup;
    Panel1: TPanel;
    btnLoadMinset: TButton;
    btnSaveMinset: TButton;
    btnLoadSequence: TButton;
    btnSaveSequence: TButton;
    btnCloneMinset: TButton;
    btnPreviousMinset: TButton;
    btnNextMinset: TButton;
    lblWhichMinset: TLabel;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    MemoInfoOnMinset: TMemo;
    CheckCreateValidateOutput: TCheckBox;
    checkAreaStopCond: TCheckBox;
    EditAreaCutoff: TEdit;
    Label1: TLabel;
    CheckDebugZeroMaxValue: TCheckBox;
    procedure BitBtnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  SiteInfo_t = record
                 iRichness,
                 iOffset : integer;
               end;

var
  FastMinsetForm: TFastMinsetForm;

implementation

uses
    ds, global, control, sql_unit, opt1, sitelist, math;

{$R *.DFM}

function IsSiteRedundant(const iSiteIndex : integer;
                         FeatureTargets : Array_t;
                         const fDebug : boolean) : boolean;
// returns TRUE if site is redundant
//         FALSE if site is not redundant
var
   iCount : integer;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   Value : ValueFile_T;
   DebugFile : TextFile;
   rTarget : extended;
begin
     try
        // determine if this site is redundant
        // ie. for each feature in the site
        //       subtract amount in site from reserved amount for the feature
        //       is the feature now satisfied ?

        // True (redundant) is the default
        Result := True;

        new(pSite);
        new(pFeat);
        SiteArr.rtnValue(iSiteIndex,pSite);

        if (pSite^.richness > 0) then
           for iCount := 1 to pSite^.richness do
           begin
                // examine a feature at the site
                FeatureAmount.rtnValue(pSite^.iOffset + iCount,@Value);
                FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                FeatArr.rtnValue(Value.iFeatKey,pFeat);
                // if (the target with this site deselected is above zero)
                // then (we need this site ,ie. it is not redundant)
                if ((rTarget + Value.rAmount) > 0) then
                   // this site is needed for this feature
                   Result := False;

                if fDebug then
                begin
                     // append information to the debug file
                     assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\MinimumSetRedundancyCheck_debug.csv');
                     append(DebugFile);
                     writeln(DebugFile,IntToStr(pSite^.iKey) + ',' +
                                       IntToStr(Value.iFeatKey) + ',' +
                                       FloatToStr(rTarget) + ',' +
                                       FloatToStr(Value.rAmount) + ',' +
                                       FloatToStr(rTarget + Value.rAmount) + ',' +
                                       Bool2String(Result));
                     closefile(DebugFile);
                end;
           end;

        dispose(pSite);
        dispose(pFeat);

        // see if irr is 0

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Minimum Set redundancy check at site ' + IntToStr(iSiteIndex),
                      mtError,[mbOk],0);
     end;
end;

(*
procedure FastMinSetRedundancyCheck(const fDebug, fRedundancyCheckOrder, fExcludeSites : boolean);
// method : parse the list of sites that have been selected (negotiated and mandatory sites),
//          deselecting each redundant sites in turn as we come to it (and adjusting targets)
//          then continuing through the list of sites.
//
// fRedundancyCheckOrder = FALSE means downto
//                         TRUE        to
var
   ListOfSelectedSites : Array_t;
   iListOfSelectedSites, iCount, iKey, iSiteIndex : integer;
   fRedundant, fExclude : boolean;
   DebugFile : TextFile;

   procedure AddKeyToList(const iSiteKey : integer);
   begin
        Inc(iListOfSelectedSites);
        if (ListOfSelectedSites.lMaxSize < iListOfSelectedSites) then
           ListOfSelectedSites.resize(ListOfSelectedSites.lMaxSize + ARR_STEP_SIZE);
        ListOfSelectedSites.setValue(iListOfSelectedSites,@iSiteKey);
   end;

begin
     try
        if fDebug then
           if (not FileExists(ControlRes^.sWorkingDirectory + '\MinimumSetRedundancyCheck_debug.csv')) then
           begin
                // create the debug file for the redundancy check if it doesn't exist
                assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\MinimumSetRedundancyCheck_debug.csv');
                rewrite(DebugFile);
                writeln(DebugFile,'SiteKey,FeatKey,targetarea,amount,targetarea+amount,is redundant');
                closefile(DebugFile);
           end;

        iListOfSelectedSites := 0;
        // make a list of selected sites (negotiated and mandatory)
        if (ControlForm.Negotiated.Items.Count > 0)
        or (ControlForm.Mandatory.Items.Count > 0) then
        begin
             ListOfSelectedSites := Array_t.Create;
             ListOfSelectedSites.init(SizeOf(integer),ARR_STEP_SIZE);

             if (ControlForm.Mandatory.Items.Count > 0) then
                for iCount := 0 to (ControlForm.Mandatory.Items.Count-1) do
                    AddKeyToList(StrToInt(ControlForm.MandatoryKey.Items.Strings[iCount]));

             if (ControlForm.Negotiated.Items.Count > 0) then
                for iCount := 0 to (ControlForm.Negotiated.Items.Count-1) do
                    AddKeyToList(StrToInt(ControlForm.NegotiatedKey.Items.Strings[iCount]));

             // parse the list of selected sites
             if fRedundancyCheckOrder then
                for iCount := 1 to iListOfSelectedSites do
                begin
                     // test if site is redundant and needs to be deselected
                     ListOfSelectedSites.rtnValue(iCount,@iKey);
                     if fExcludeSites then
                     begin
                          // we need to test if this site is excluded
                          iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
                          RedCheckExcludeSites.rtnValue(iSiteIndex,@fExclude);
                     end
                     else
                         fExclude := False;
                     if not fExclude then
                        if IsSiteRedundant(iKey,fDebug) then
                           // site is redundant, so deselect it
                           DeSelectThisSite(iKey);
                end
             else
                 for iCount := iListOfSelectedSites downto 1 do
                 begin
                      // test if site is redundant and needs to be deselected
                      ListOfSelectedSites.rtnValue(iCount,@iKey);
                      if fExcludeSites then
                      begin
                           // we need to test if this site is excluded
                           iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
                           RedCheckExcludeSites.rtnValue(iSiteIndex,@fExclude);
                      end
                      else
                          fExclude := False;
                      if not fExclude then
                         if IsSiteRedundant(iKey,fDebug) then
                            // site is redundant, so deselect it
                            DeSelectThisSite(iKey);
                 end;

             ListOfSelectedSites.Destroy;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Minimum Set redundancy check',
                      mtError,[mbOk],0);
     end;
end;
*)

function MakeTargetsArray(var iFeaturesSatisfied : integer) : Array_t;
var
   iCount : integer;
   rTarget : extended;
   AFeat : featureoccurrence;
begin
     Result := Array_t.Create;
     Result.init(SizeOf(extended),iFeatureCount);
     iFeaturesSatisfied := 0;
     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,@AFeat);
          rTarget := AFeat.targetarea;
          Result.setValue(iCount,@rTarget);
          if (rTarget <= 0) then
             Inc(iFeaturesSatisfied);
     end;
end;

function MakeFeatureReservedArray : Array_t;
var
   iCount : integer;
   rReserved : extended;
   AFeat : featureoccurrence;
begin
     Result := Array_t.Create;
     Result.init(SizeOf(extended),iFeatureCount);
     rReserved := 0;
     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,@AFeat);
          rReserved := AFeat.rR1 + AFeat.rR2 + AFeat.rR3 + AFeat.rR4 + AFeat.rR5 + AFeat.reservedarea;
          Result.setValue(iCount,@rReserved);
     end;
end;

function MakeFeatureRichness : Array_t;
var
   iCount, iRichness : integer;
begin
     Result := Array_t.Create;
     Result.init(SizeOf(integer),iFeatureCount);
     iRichness := 0;
     for iCount := 1 to iFeatureCount do
         Result.setValue(iCount,@iRichness);
end;

function  MakeReachedTargetArray : Array_t;
var
   iCount : integer;
   fReached : boolean;
begin
     Result := Array_t.Create;
     Result.init(SizeOf(boolean),iFeatureCount);
     fReached := False;
     for iCount := 1 to iFeatureCount do
         Result.setValue(iCount,@fReached);
end;

procedure ResetReachedTarget(ReachedTarget : Array_t);
var
   iCount : integer;
   fReached : boolean;
begin
     fReached := False;
     for iCount := 1 to ReachedTarget.lMaxSize do
         ReachedTarget.setValue(iCount,@fReached);
end;

function MakeSiteInfoArray : Array_t;
var
   iCount : integer;
   ASiteInfo : SiteInfo_t;
   ASite : site;
begin
     Result := Array_t.Create;
     Result.init(SizeOf(SiteInfo_t),iSiteCount);
     for iCount := 1 to iSiteCount do
     begin
          SiteArr.rtnValue(iCount,@ASite);

          ASiteInfo.iRichness := ASite.richness;
          ASiteInfo.iOffset := ASite.iOffset;

          Result.setValue(iCount,@ASiteInfo);
     end;
end;

function MakeSitesContainingFeatureArray : Array_t;
var
   iCount, iSite, iSiteIndex, iSize : integer;
   SiteArray : Array_t;
   ASite : site;
   Value : ValueFile_T;
   ResultSize : Array_t;
begin
     Result := Array_t.Create;
     Result.init(SizeOf(Array_t),iFeatureCount);
     ResultSize := Array_t.Create;
     ResultSize.init(SizeOf(integer),iFeatureCount);
     iSiteIndex := 0;
     iSize := 0;
     // create and initialise the data structure
     // this datastructure is much larger than we will need, but making it this size
     //   means we don't have to resize while adding elements to it
     for iCount := 1 to iFeatureCount do
     begin
          SiteArray := Array_t.Create;
          SiteArray.init(SizeOf(integer),iSiteCount);
          for iSite := 1 to iSiteCount do
              SiteArray.setValue(iSite,@iSiteIndex);
          Result.setValue(iCount,@SiteArray);
          ResultSize.setValue(iCount,@iSize);
     end;
     // traverse the matrix, writing site keys to the feature lists
     for iSite := 1 to iSiteCount do
     begin
          SiteArr.rtnValue(iSite,@ASite);
          if (ASite.status = Av)
          or (ASite.status = Fl) then
             if (ASite.richness > 0) then
                for iCount := 1 to ASite.richness do
                begin
                     FeatureAmount.rtnValue(ASite.iOffset + iCount,@Value);
                     ResultSize.rtnValue(Value.iFeatKey,@iSize);
                     Inc(iSize);
                     Result.rtnValue(Value.iFeatKey,@SiteArray);
                     iSiteIndex := iSite;
                     SiteArray.setValue(iSize,@iSiteIndex);
                     Result.setValue(Value.iFeatKey,@SiteArray);
                     ResultSize.setValue(Value.iFeatKey,@iSize);
                end;
     end;
     // compact the datastructure
     for iCount := 1 to iFeatureCount do
     begin
          Result.rtnValue(iCount,@SiteArray);
          ResultSize.rtnValue(iCount,@iSize);
          if (iSize > 0) then
             SiteArray.resize(iSize)
          else
          begin
               SiteArray.resize(1);
               SiteArray.lMaxSize := 0;
          end;
          Result.setValue(iCount,@SiteArray);
     end;
     ResultSize.Destroy;
end;

procedure DumpSitesContainingFeatureArray(SitesContainingFeature :Array_t);
var
   iCount, iSite, iSiteIndex, iSize : integer;
   SiteArray : Array_t;
   OutFile : TextFile;
begin
     assignfile(OutFile,ControlRes^.sWorkingDirectory + '\sitescontainingfeatures.csv');
     rewrite(OutFile);

     for iCount := 1 to iFeatureCount do
     begin
          SitesContainingFeature.rtnValue(iCount,@SiteArray);
          if (SiteArray.lMaxSize > 0) then
             for iSite := 1 to SiteArray.lMaxSize do
             begin
                  SiteArray.rtnValue(iSite,@iSiteIndex);
                  write(OutFile,IntToStr(iSiteIndex) + ',');
             end;

          writeln(OutFile);
     end;

     closefile(OutFile)
end;

function MakeStatusArray(var iSitesReserved : integer) : Array_t;
var
   iCount : integer;
   AStatus : status_t;
   ASite : site;
begin
     Result := Array_t.Create;
     Result.init(SizeOf(Status_T),iSiteCount);
     iSitesReserved := 0;
     for iCount := 1 to iSiteCount do
     begin
          SiteArr.rtnValue(iCount,@ASite);
          AStatus := ASite.status;
          Result.setValue(iCount,@AStatus);
          // Status_T = (Av,R1,R2,Pd,Fl,Ex,Ig,Re);
          if (AStatus = _R1)
          or (AStatus = _R2)
          or (AStatus = _R3)
          or (AStatus = _R4)
          or (AStatus = _R5)
          or (AStatus = Pd)
          or (AStatus = Re) then
             Inc(iSitesReserved);
     end;
end;

function MakeSelectedSites : Array_t;
var
   iCount, iSite : integer;
begin
     Result := Array_t.Create;
     Result.init(SizeOf(integer),1000);
     iSite := 0;
     for iCount := 1 to 1000 do
         Result.setValue(iCount,@iSite);
end;

function MakeSiteValue : Array_t;
var
   iCount, iSite : integer;
   rValue : extended;
begin
     Result := Array_t.Create;
     Result.init(SizeOf(extended),iSiteCount);
     rValue := 0;
     for iCount := 1 to iSiteCount do
         Result.setValue(iCount,@rValue);
end;

function ReturnNumberOfFeatureTargetsSatisfied(FeatureTargets : Array_t) : integer;
var
   iCount : integer;
   rTarget : extended;
begin
     Result := 0;
     for iCount := 1 to FeatureTargets.lMaxSize do
     begin
          FeatureTargets.rtnValue(iCount,@rTarget);
          if (rTarget <= 0) then
             Inc(Result);
     end;
end;

function ReturnReportTargetFeaturesSatisfied(FeatureReserved : Array_t) : integer;
var
   iCount : integer;
   rTarget, rReserved, rTotal : extended;
   AFeat : featureoccurrence;
begin
     Result := 0;
     for iCount := 1 to ReportTarget.lMaxSize do
     begin
          ReportTarget.rtnValue(iCount,@rTarget);
          FeatureReserved.rtnValue(iCount,@rReserved);
          FeatArr.rtnValue(iCount,@AFeat);
          //if (rTarget > AFeat.totalarea) then
          //   rTarget := AFeat.totalarea;
          rTarget := rTarget - rReserved;
          if (rTarget <= 0) then
             Inc(Result);
     end;
end;

function ReturnNumberOfSitesReserved(SiteStatus : Array_t;
                                     var iSitesAvailable : integer) : integer;
var
   iCount : integer;
   AStatus : status_t;
begin
     Result := 0;
     iSitesAvailable := 0;
     for iCount := 1 to SiteStatus.lMaxSize do
     begin
          SiteStatus.rtnValue(iCount,@AStatus);
          if (AStatus = _R1)
          or (AStatus = _R2)
          or (AStatus = _R3)
          or (AStatus = _R4)
          or (AStatus = _R5)
          or (AStatus = Pd)
          or (AStatus = Re) then
             Inc(Result);

          if (AStatus = Av)
          or (AStatus = Fl) then
             Inc(iSitesAvailable);
     end;
end;

procedure UpdateFeatureRichness(FeatureRichness, FeatureTargets, SiteStatus, SiteInfo : Array_t);
var
   iSite, iFeature, iRichness : integer;
   ASiteInfo : SiteInfo_t;
   AStatus : status_t;
   Value : ValueFile_T;
   rTarget : extended;
begin
     // update the feature richness array
     iRichness := 0;
     for iFeature := 1 to iFeatureCount do
         FeatureRichness.setValue(iFeature,@iRichness);
     for iSite := 1 to iSiteCount do
     begin
          SiteStatus.rtnValue(iSite,@AStatus);

          if (AStatus = Av)
          or (AStatus = Fl) then
          begin
               SiteInfo.rtnValue(iSite,@ASiteInfo);
               if (ASiteInfo.iRichness > 0) then
                  for iFeature := 1 to ASiteInfo.iRichness do
                  begin
                       FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                       FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                       if (rTarget > 0)
                       and (Value.rAmount > 0) then
                       begin
                            FeatureRichness.rtnValue(Value.iFeatKey,@iRichness);
                            Inc(iRichness);
                            FeatureRichness.setValue(Value.iFeatKey,@iRichness);
                       end;
                  end;
          end;
     end;
end;

function DebugSiteValueAndReturnFirstHighestSite(SiteValue,SiteStatus,FeatureTargets,SiteInfo,FeatureRichness,FeatureReserved : Array_t;
                                                  const iMinsetRule, iIteration : integer;
                                                  var rMaximumValue, rSumReservedMeasure2 : extended;
                                                  var iTiedSites : integer) : integer;
var
   iCount, iFeatureRichness, iRichness : integer;
   rTarget, rFeatureContrib, rReserved,
   rValue, rHighest, rMeasure2 : extended;
   AStatus : status_t;
   ASiteInfo : SiteInfo_t;
   Value : ValueFile_T;
   AFeat : featureoccurrence;
   SiteValidationFile, FeatureValidationFile : TextFile;

   function Return_Measure1_Possibility1 : extended;
   var
      iFeature : integer;
   begin
        {Measure1_Possibility1       = Weighted_propcontrib}
        Result := 0;

        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                if (rTarget > 0)
                and (Value.rAmount > 0) then
                begin
                     if (Value.rAmount > rTarget) then
                        rFeatureContrib := rTarget
                     else
                         rFeatureContrib := Value.rAmount;
                     // express feature contrib as a percentage of remaining target
                     rFeatureContrib := rFeatureContrib / rTarget * 100;
                end
                else
                    rFeatureContrib := 0;
                FeatureRichness.rtnValue(Value.iFeatKey,@iFeatureRichness);
                if (iFeatureRichness > 0) then
                   rFeatureContrib := rFeatureContrib * 100 / iFeatureRichness
                else
                    rFeatureContrib := 0;

                Result := Result + rFeatureContrib;
           end;
   end;

   function Return_Measure1_Possibility2 : extended;
   var

      iFeature : integer;
      rSum, rContrib : extended;
   begin
        {Measure1_Possibility2       = sum of ([TgtContribFeatureX])}

        rSum := 0;

        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                FeatArr.rtnValue(Value.iFeatKey,@AFeat);
                if (rTarget > 0)
                and (Value.rAmount > 0) then
                begin
                     rContrib := rTarget;
                     if (rContrib > Value.rAmount) then
                        rContrib := Value.rAmount;
                     rSum := rSum + ((rContrib/rTarget));
                end;
           end;

        Result := rSum;
   end;

   function Return_Measure1_Possibility3 : extended;
   var
      iFeature : integer;
      rSum, rContrib : extended;
   begin
        {Measure1_Possibility3       = sum of ([TgtContribFeatureX]*[TgtMetFeatureX])}

        rSum := 0;

        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                FeatArr.rtnValue(Value.iFeatKey,@AFeat);
                if (rTarget > 0)
                and (Value.rAmount > 0) then
                begin
                     FeatureReserved.rtnValue(Value.iFeatKey,@rReserved);

                     rContrib := rTarget;
                     if (rContrib > Value.rAmount) then
                        rContrib := Value.rAmount;
                     rSum := rSum + (((rReserved/AFeat.rInitialTrimmedTarget)) *
                                     ((rContrib/rTarget)));
                end;
           end;

        Result := rSum;
   end;

   function Return_Measure2 : extended;
   var
      iFeature : integer;
      rSum, rP_weight, rP_initial, rP_current, r_A, r_B, r_X_initial, r_X_current : extended;
   begin
        {Measure_2                   = sum of ([1-TgtMetFeatureX]*VulnFeatureX)}
        rSum := 0;

        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                FeatArr.rtnValue(Value.iFeatKey,@AFeat);
                if (rTarget > 0)
                and (Value.rAmount > 0) then
                begin
                     FeatureReserved.rtnValue(Value.iFeatKey,@rReserved);

                     r_A := -ln(0.005/0.995);
                     r_B := ln(0.005/0.995)/50;

                     r_X_initial := rReserved/AFeat.rInitialTrimmedTarget*100;
                     if (r_X_initial > 100) then
                        r_X_initial := 100;

                     rP_initial := Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50)))/
                                   (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50))))*
                                   2;

                     r_X_current := (rReserved+Value.rAmount)/AFeat.rInitialTrimmedTarget*100;
                     if (r_X_current > 100) then
                        r_X_current := 100;

                     rP_current := Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50)))/
                                   (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50))))*
                                   2;

                     rP_weight := rP_initial - rP_current;

                     rSum := rSum + (AFeat.rVulnerability * rP_weight);

                     {p is a weighting applied to measure 2

                      p = (e^(a+bx)))/(1 + e^(a+bx))*2

                      where a and b are constants,
                            x is % of target met}
                end;
           end;

        Result := rSum;
   end;

   function Return_bpressey_Measure2 : extended;
   var
      iFeature, iIndex : integer;
      rSum, rP_weight, rP_initial, rP_current, r_A, r_B, r_X_initial, r_X_current,
      rValue, rElement : extended;
   begin
        {Measure_2                   = sum of ([1-TgtMetFeatureX]*VulnFeatureX)}
        rSum := 0;

        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                FeatArr.rtnValue(Value.iFeatKey,@AFeat);
                if (rTarget > 0)
                and (Value.rAmount > 0) then
                begin
                     FeatureReserved.rtnValue(Value.iFeatKey,@rReserved);

                     if (rTarget > 0) then
                        rValue := rTarget / (rTarget + rReserved)
                        // T-resd/T       targ / targ + reserve
                     else
                         rValue := 0;

                     if (rValue > 1) then
                        rValue := 1;
                     if (rValue < 0) then
                        rValue := 0;

                     iIndex := round(AFeat.rFloatVulnerability);
                     if (iIndex < 1) then
                        iIndex := 1;
                     if (iIndex > 5) then
                        iIndex := 5;

                     rElement := ({1 -} rValue)*ControlRes^.VulnerabilityWeightings[iIndex];
                     rSum := rSum + rElement;
                end;
           end;

        Result := rSum;
   end;

   function Return_Reporting_Measure2 : extended;
   var
      iFeature : integer;
      rSum, rP_initial, rP_current, rP_weight, r_A, r_B, r_X_initial, r_X_current, rAmount : extended;
      SiteContents : Array_T;
      Reporting_Measure2_File : TextFile;
   begin
        {Measure_2                   = sum of (VulnFeatureX * delta P)}
        rSum := 0;
        //if FastMinsetForm.CheckCreateValidateOutput.Checked then
        begin
             AssignFile(Reporting_Measure2_File,ControlRes^.sWorkingDirectory +'\Reporting_Measure2_' + IntToStr(iIteration) + '.csv');
             rewrite(Reporting_Measure2_File);
             writeln(Reporting_Measure2_File,'FeatureIndex,target,amount,reserved,initial target,Vulnerability,' +
                                             'A,B,X initial,P initial,X current,P current,P delta');
        end;
        // make feature array of how much is at each site
        SiteContents := Array_T.Create;
        SiteContents.init(SizeOf(extended),iFeatureCount);
        rAmount := 0;
        for iFeature := 1 to iFeatureCount do
            SiteContents.setValue(iFeature,@rAmount);
        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                rAmount := Value.rAmount;
                SiteContents.setValue(Value.iFeatKey,@rAmount);
           end;
        // traverse the features, calculating as we go
        for iFeature := 1 to iFeatureCount do
        begin
             SiteContents.rtnValue(iFeature,@rAmount);
             FeatureTargets.rtnValue(iFeature,@rTarget);
             FeatArr.rtnValue(iFeature,@AFeat);
             if (AFeat.rInitialTrimmedTarget > 0) then
             begin
                  FeatureReserved.rtnValue(iFeature,@rReserved);

                  r_A := -ln(0.005/0.995);
                  r_B := ln(0.005/0.995)/50;
                  r_X_initial := rReserved/AFeat.rInitialTrimmedTarget*100;
                  if (r_X_initial > 100) then
                     r_X_initial := 100;

                  rP_initial := Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50)))/
                                (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50))))*
                                2;

                  r_X_current := (rReserved+rAmount)/AFeat.rInitialTrimmedTarget*100;
                  if (r_X_current > 100) then
                     r_X_current := 100;

                  rP_current := Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50)))/
                                (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50))))*
                                2;

                  //rP_weight := rP_initial - rP_current;

                  rSum := rSum + (AFeat.rVulnerability * rP_current{rP_weight});

                  {p is a weighting applied to measure 2

                   p = (e^(a+bx)))/(1 + e^(a+bx))*2

                   where a and b are constants,
                         x is % of target met}

                  //'FeatureIndex,target,amount,reserved,initial target,Vulnerability,' +
                  //'A,B,X initial,P initial,X current,P current,P delta');

                  //if FastMinsetForm.CheckCreateValidateOutput.Checked then
                     writeln(Reporting_Measure2_File,IntToStr(iFeature) + ',' +
                                                   FloatToStr(rTarget) + ',' +
                                                   FloatToStr(rAmount) + ',' +
                                                   FloatToStr(rReserved) + ',' +
                                                   FloatToStr(AFeat.rInitialTrimmedTarget) + ',' +
                                                   FloatToStr(AFeat.rVulnerability) + ',' +
                                                   FloatToStr(r_A) + ',' +
                                                   FloatToStr(r_B) + ',' +
                                                   FloatToStr(r_X_initial) + ',' +
                                                   FloatToStr(rP_initial) + ',' +
                                                   FloatToStr(r_X_current) + ',' +
                                                   FloatToStr(rP_current) + ',' +
                                                   FloatToStr(rP_weight));
             end;
        end;

        SiteContents.Destroy;
        Result := rSum;

        //if FastMinsetForm.CheckCreateValidateOutput.Checked then
           closefile(Reporting_Measure2_File);
   end;

   procedure AppendValidateFile;
   var
      iFeature, iIndex : integer;
      rContrib, r_A, r_B, r_X_initial, r_X_current, r_P_initial ,r_P_current, r_P_delta : extended;
   begin
        // SiteValidationFile, FeatureValidationFile
        writeln(SiteValidationFile,IntToStr(iCount) +
                                   ',' + FloatToStr(Return_Measure1_Possibility1) +
                                   ',' + FloatToStr(Return_Measure1_Possibility2) +
                                   ',' + FloatToStr(Return_Measure1_Possibility3) +
                                   ',' + FloatToStr(Return_Measure2) +
                                   ',' + FloatToStr(Return_bpressey_Measure2));

        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                FeatArr.rtnValue(Value.iFeatKey,@AFeat);

                if (rTarget > 0) then
                begin
                     FeatureReserved.rtnValue(Value.iFeatKey,@rReserved);

                     rContrib := rTarget;
                     if (rContrib > Value.rAmount) then
                        rContrib := Value.rAmount;

                     r_A := -ln(0.005/0.995);
                     r_B := ln(0.005/0.995)/50;
                     // r_X_initial, r_X_current, r_P_initial ,r_P_current, r_P_delta
                     r_X_initial := (rReserved)/AFeat.rInitialTrimmedTarget*100;
                     if (r_X_initial > 100) then
                        r_X_initial := 100;
                     r_P_initial := Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50)))/
                                    (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50))))*
                                    2;
                     r_X_current := (rReserved+Value.rAmount)/AFeat.rInitialTrimmedTarget*100;
                     if (r_X_current > 100) then
                        r_X_current := 100;
                     r_P_current := Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50)))/
                                   (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50))))*
                                   2;
                     r_P_delta := r_P_initial - r_P_current;

                     iIndex := round(AFeat.rFloatVulnerability);
                     if (iIndex < 1) then
                        iIndex := 1;
                     if (iIndex > 5) then
                        iIndex := 5;

                     writeln(FeatureValidationFile,IntToStr(iCount) + ',' +
                                                   Status2Str(AStatus) + ',' +
                                                   IntToStr(Value.iFeatKey) + ',' +
                                                   FloatToStr(rTarget) + ',' +
                                                   FloatToStr(Value.rAmount) + ',' +
                                                   FloatToStr(rContrib) + ',' +
                                                   FloatToStr(rReserved) + ',' +
                                                   FloatToStr(AFeat.rInitialTrimmedTarget) + ',' +
                                                   FloatToStr(AFeat.rVulnerability) + ',' +
                                                   FloatToStr(ControlRes^.VulnerabilityWeightings[iIndex]) + ',' +
                                                   FloatToStr(1-(rContrib/rTarget)) + ',' +
                                                   FloatToStr(1-(rReserved/AFeat.rInitialTrimmedTarget)) + ',' +
                                                   FloatToStr(rReserved/AFeat.rInitialTrimmedTarget) + ',' +
                                                   FloatToStr(r_A) + ',' +
                                                   FloatToStr(r_B) + ',' +
                                                   FloatToStr(r_X_initial) + ',' +
                                                   FloatToStr(r_P_initial) + ',' +
                                                   FloatToStr(r_X_current) + ',' +
                                                   FloatToStr(r_P_current) + ',' +
                                                   FloatToStr(r_P_delta)
                             );

                     //'SiteIndex,FeatureIndex,target,amount,contrib,reserved,initial target,'
                     //'Vulnerability,[1-TgtContribFeatureX],[1-TgtMetFeatureX],[TgtMetFeatureX],'
                     //'A,B,X initial,P initial,X current,P current,P delta'
                end;
           end;
   end;

begin
     // return the 1-based index of the first site with the highest value
     // select the site with the highest value
     // select the first site with the highest value if there are ties for highest value
     Result := 1;
     rHighest := -1;
     rSumReservedMeasure2 := 0;
     // create validation file for this iteration
     //if FastMinsetForm.CheckCreateValidateOutput.Checked then
     begin
          AssignFile(SiteValidationFile,ControlRes^.sWorkingDirectory +'\site_values_' + IntToStr(iIteration) + '.csv');
          rewrite(SiteValidationFile);
          AssignFile(FeatureValidationFile,ControlRes^.sWorkingDirectory +'\site_X_feature_values_' + IntToStr(iIteration) + '.csv');
          rewrite(FeatureValidationFile);
          writeln(SiteValidationFile,'SiteIndex,Measure1_Possibility1,Measure1_Possibility2' +
                                     ',Measure1_Possibility3,Measure2');
          writeln(FeatureValidationFile,'SiteIndex,SiteStatus,FeatureIndex,target,amount,contrib,reserved,initial target,Vulnerability,FVuln,' +
                                        '[1-TgtContribFeatureX],[1-TgtMetFeatureX],[TgtMetFeatureX],' +
                                        'A,B,X initial,P initial,X current,P current,P delta');
          // SiteValidationFile, FeatureValidationFile
     end;

     // deduce a new value for each site based on SiteStatus, FeatureTargets and iMinsetRule
     for iCount := 1 to SiteValue.lMaxSize do
     begin
          rValue := 0;
          SiteStatus.rtnValue(iCount,@AStatus);
          if (AStatus = Av)
          or (AStatus = Fl) then
          begin
               // calculate a value for this available site
               SiteInfo.rtnValue(iCount,@ASiteInfo);
               case iMinsetRule of
                    0 : rValue := Return_Measure1_Possibility1;
                    1 : rValue := Return_Measure1_Possibility2;
                    2 : rValue := Return_Measure1_Possibility3;
                    3 : rValue := Return_Measure2;
                    4 : rValue := Return_bpressey_Measure2;
               end;
               {Measure1_Possibility1       = Weighted_propcontrib}
               {Measure1_Possibility2       = sum of ([TgtContribFeatureX])}
               {Measure1_Possibility3       = sum of ([TgtContribFeatureX]*[TgtMetFeatureX])}
               {Measure_2                   = sum of ([1-TgtMetFeatureX]*VulnFeatureX)}

               if (rValue > rHighest) then
               begin
                    Result := iCount;
                    rHighest := rValue;
               end;

               //if FastMinsetForm.CheckCreateValidateOutput.Checked then
                  AppendValidateFile;
          end;

          SiteValue.setValue(iCount,@rValue);
     end;

     // reparse SiteValue to see if there were any ties
     iTiedSites := 0;
     for iCount := 1 to SiteValue.lMaxSize do
     begin
          SiteValue.rtnValue(iCount,@rValue);
          if (rValue = rHighest) then
             Inc(iTiedSites);
     end;

     SiteInfo.rtnValue(Result,@ASiteInfo);
     // using site index Result, propose reserve that site
     rSumReservedMeasure2 := Return_Reporting_Measure2;

     // close validation file
     //if FastMinsetForm.CheckCreateValidateOutput.Checked then
     begin
          closefile(SiteValidationFile);
          closefile(FeatureValidationFile);
          // SiteValidationFile, FeatureValidationFile
     end;

     rMaximumValue := rHighest;
end;

function UpdateSiteValueAndReturnFirstHighestSite(SiteValue,SiteStatus,FeatureTargets,SiteInfo,FeatureRichness,FeatureReserved : Array_t;
                                                  const iMinsetRule, iIteration : integer;
                                                  var rMaximumValue, rSumReservedMeasure2 : extended;
                                                  var iTiedSites : integer) : integer;
var
   iCount, iFeatureRichness, iRichness : integer;
   rTarget, rFeatureContrib, rReserved,
   rValue, rHighest, rMeasure2 : extended;
   AStatus : status_t;
   ASiteInfo : SiteInfo_t;
   Value : ValueFile_T;
   AFeat : featureoccurrence;
   SiteValidationFile, FeatureValidationFile : TextFile;

   function Return_Measure1_Possibility1 : extended;
   var
      iFeature : integer;
   begin
        {Measure1_Possibility1       = Weighted_propcontrib}
        Result := 0;

        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                if (rTarget > 0)
                and (Value.rAmount > 0) then
                begin
                     if (Value.rAmount > rTarget) then
                        rFeatureContrib := rTarget
                     else
                         rFeatureContrib := Value.rAmount;
                     // express feature contrib as a percentage of remaining target
                     rFeatureContrib := rFeatureContrib / rTarget * 100;
                end
                else
                    rFeatureContrib := 0;
                FeatureRichness.rtnValue(Value.iFeatKey,@iFeatureRichness);
                if (iFeatureRichness > 0) then
                   rFeatureContrib := rFeatureContrib * 100 / iFeatureRichness
                else
                    rFeatureContrib := 0;

                Result := Result + rFeatureContrib;
           end;
   end;

   function Return_Measure1_Possibility2 : extended;
   var

      iFeature : integer;
      rSum, rContrib : extended;
   begin
        {Measure1_Possibility2       = sum of ([TgtContribFeatureX])}

        rSum := 0;

        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                FeatArr.rtnValue(Value.iFeatKey,@AFeat);
                if (rTarget > 0)
                and (Value.rAmount > 0) then
                begin
                     rContrib := rTarget;
                     if (rContrib > Value.rAmount) then
                        rContrib := Value.rAmount;
                     rSum := rSum + ((rContrib/rTarget));
                end;
           end;

        Result := rSum;
   end;

   function Return_Measure1_Possibility3 : extended;
   var
      iFeature : integer;
      rSum, rContrib : extended;
   begin
        {Measure1_Possibility3       = sum of ([TgtContribFeatureX]*[TgtMetFeatureX])}

        rSum := 0;

        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                FeatArr.rtnValue(Value.iFeatKey,@AFeat);
                if (rTarget > 0)
                and (Value.rAmount > 0) then
                begin
                     FeatureReserved.rtnValue(Value.iFeatKey,@rReserved);

                     rContrib := rTarget;
                     if (rContrib > Value.rAmount) then
                        rContrib := Value.rAmount;
                     rSum := rSum + (((rReserved/AFeat.rInitialTrimmedTarget)) *
                                     ((rContrib/rTarget)));
                end;
           end;

        Result := rSum;
   end;

   function Return_Measure2 : extended;
   var
      iFeature : integer;
      rSum, rP_weight, rP_initial, rP_current, r_A, r_B, r_X_initial, r_X_current : extended;
   begin
        {Measure_2                   = sum of ([1-TgtMetFeatureX]*VulnFeatureX)}
        rSum := 0;

        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                FeatArr.rtnValue(Value.iFeatKey,@AFeat);
                if (rTarget > 0)
                and (Value.rAmount > 0) then
                begin
                     FeatureReserved.rtnValue(Value.iFeatKey,@rReserved);

                     r_A := -ln(0.005/0.995);
                     r_B := ln(0.005/0.995)/50;

                     r_X_initial := rReserved/AFeat.rInitialTrimmedTarget*100;
                     if (r_X_initial > 100) then
                        r_X_initial := 100;

                     rP_initial := Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50)))/
                                   (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50))))*
                                   2;

                     r_X_current := (rReserved+Value.rAmount)/AFeat.rInitialTrimmedTarget*100;
                     if (r_X_current > 100) then
                        r_X_current := 100;

                     rP_current := Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50)))/
                                   (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50))))*
                                   2;

                     rP_weight := rP_initial - rP_current;

                     rSum := rSum + (AFeat.rVulnerability * rP_weight);

                     {p is a weighting applied to measure 2

                      p = (e^(a+bx)))/(1 + e^(a+bx))*2

                      where a and b are constants,
                            x is % of target met}
                end;
           end;

        Result := rSum;
   end;

   function Return_bpressey_Measure2 : extended;
   var
      iFeature, iIndex : integer;
      rSum, rP_weight, rP_initial, rP_current, r_A, r_B, r_X_initial, r_X_current,
      rValue, rElement : extended;
   begin
        {Measure_2                   = sum of ([1-TgtMetFeatureX]*VulnFeatureX)}
        rSum := 0;

        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                FeatArr.rtnValue(Value.iFeatKey,@AFeat);
                if (rTarget > 0)
                and (Value.rAmount > 0) then
                begin
                     FeatureReserved.rtnValue(Value.iFeatKey,@rReserved);

                     if (rTarget > 0) then
                        rValue := rReserved / rTarget
                     else
                         rValue := 0;
                     if (rValue > 1) then
                        rValue := 1;

                     iIndex := round(AFeat.rFloatVulnerability);
                     if (iIndex < 1) then
                        iIndex := 1;
                     if (iIndex > 5) then
                        iIndex := 5;

                     rElement := (1 - rValue)*ControlRes^.VulnerabilityWeightings[iIndex];
                     rSum := rSum + rElement;
                end;
           end;

        Result := rSum;
   end;

   function Return_Reporting_Measure2 : extended;
   var
      iFeature : integer;
      rSum, rP_initial, rP_current, rP_weight, r_A, r_B, r_X_initial, r_X_current, rAmount : extended;
      SiteContents : Array_T;
      Reporting_Measure2_File : TextFile;
   begin
        {Measure_2                   = sum of (VulnFeatureX * delta P)}
        rSum := 0;
        if FastMinsetForm.CheckCreateValidateOutput.Checked then
        begin
             AssignFile(Reporting_Measure2_File,ControlRes^.sWorkingDirectory +'\Reporting_Measure2_' + IntToStr(iIteration) + '.csv');
             rewrite(Reporting_Measure2_File);
             writeln(Reporting_Measure2_File,'FeatureIndex,target,amount,reserved,initial target,Vulnerability,' +
                                             'A,B,X initial,P initial,X current,P current,P delta');
        end;
        // make feature array of how much is at each site
        SiteContents := Array_T.Create;
        SiteContents.init(SizeOf(extended),iFeatureCount);
        rAmount := 0;
        for iFeature := 1 to iFeatureCount do
            SiteContents.setValue(iFeature,@rAmount);
        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                rAmount := Value.rAmount;
                SiteContents.setValue(Value.iFeatKey,@rAmount);
           end;
        // traverse the features, calculating as we go
        for iFeature := 1 to iFeatureCount do
        begin
             SiteContents.rtnValue(iFeature,@rAmount);
             FeatureTargets.rtnValue(iFeature,@rTarget);
             FeatArr.rtnValue(iFeature,@AFeat);
             if (AFeat.rInitialTrimmedTarget > 0) then
             begin
                  FeatureReserved.rtnValue(iFeature,@rReserved);

                  r_A := -ln(0.005/0.995);
                  r_B := ln(0.005/0.995)/50;
                  r_X_initial := rReserved/AFeat.rInitialTrimmedTarget*100;
                  if (r_X_initial > 100) then
                     r_X_initial := 100;

                  rP_initial := Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50)))/
                                (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50))))*
                                2;

                  r_X_current := (rReserved+rAmount)/AFeat.rInitialTrimmedTarget*100;
                  if (r_X_current > 100) then
                     r_X_current := 100;

                  rP_current := Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50)))/
                                (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50))))*
                                2;

                  //rP_weight := rP_initial - rP_current;

                  rSum := rSum + (AFeat.rVulnerability * rP_current{rP_weight});

                  {p is a weighting applied to measure 2

                   p = (e^(a+bx)))/(1 + e^(a+bx))*2

                   where a and b are constants,
                         x is % of target met}

                  //'FeatureIndex,target,amount,reserved,initial target,Vulnerability,' +
                  //'A,B,X initial,P initial,X current,P current,P delta');

                  if FastMinsetForm.CheckCreateValidateOutput.Checked then
                     writeln(Reporting_Measure2_File,IntToStr(iFeature) + ',' +
                                                   FloatToStr(rTarget) + ',' +
                                                   FloatToStr(rAmount) + ',' +
                                                   FloatToStr(rReserved) + ',' +
                                                   FloatToStr(AFeat.rInitialTrimmedTarget) + ',' +
                                                   FloatToStr(AFeat.rVulnerability) + ',' +
                                                   FloatToStr(r_A) + ',' +
                                                   FloatToStr(r_B) + ',' +
                                                   FloatToStr(r_X_initial) + ',' +
                                                   FloatToStr(rP_initial) + ',' +
                                                   FloatToStr(r_X_current) + ',' +
                                                   FloatToStr(rP_current) + ',' +
                                                   FloatToStr(rP_weight));
             end;
        end;

        SiteContents.Destroy;
        Result := rSum;

        if FastMinsetForm.CheckCreateValidateOutput.Checked then
           closefile(Reporting_Measure2_File);
   end;

   procedure AppendValidateFile;
   var
      iFeature : integer;
      rContrib, r_A, r_B, r_X_initial, r_X_current, r_P_initial ,r_P_current, r_P_delta : extended;
   begin
        // SiteValidationFile, FeatureValidationFile
        writeln(SiteValidationFile,IntToStr(iCount) +
                                   ',' + FloatToStr(Return_Measure1_Possibility1) +
                                   ',' + FloatToStr(Return_Measure1_Possibility2) +
                                   ',' + FloatToStr(Return_Measure1_Possibility3) +
                                   ',' + FloatToStr(Return_Measure2));

        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                FeatArr.rtnValue(Value.iFeatKey,@AFeat);

                if (rTarget > 0) then
                begin
                     FeatureReserved.rtnValue(Value.iFeatKey,@rReserved);

                     rContrib := rTarget;
                     if (rContrib > Value.rAmount) then
                        rContrib := Value.rAmount;

                     r_A := -ln(0.005/0.995);
                     r_B := ln(0.005/0.995)/50;
                     // r_X_initial, r_X_current, r_P_initial ,r_P_current, r_P_delta
                     r_X_initial := (rReserved)/AFeat.rInitialTrimmedTarget*100;
                     if (r_X_initial > 100) then
                        r_X_initial := 100;
                     r_P_initial := Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50)))/
                                    (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50))))*
                                    2;
                     r_X_current := (rReserved+Value.rAmount)/AFeat.rInitialTrimmedTarget*100;
                     if (r_X_current > 100) then
                        r_X_current := 100;
                     r_P_current := Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50)))/
                                   (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50))))*
                                   2;
                     r_P_delta := r_P_initial - r_P_current;

                     writeln(FeatureValidationFile,IntToStr(iCount) + ',' +
                                                   Status2Str(AStatus) + ',' +
                                                   IntToStr(Value.iFeatKey) + ',' +
                                                   FloatToStr(rTarget) + ',' +
                                                   FloatToStr(Value.rAmount) + ',' +
                                                   FloatToStr(rContrib) + ',' +
                                                   FloatToStr(rReserved) + ',' +
                                                   FloatToStr(AFeat.rInitialTrimmedTarget) + ',' +
                                                   FloatToStr(AFeat.rVulnerability) + ',' +
                                                   FloatToStr(1-(rContrib/rTarget)) + ',' +
                                                   FloatToStr(1-(rReserved/AFeat.rInitialTrimmedTarget)) + ',' +
                                                   FloatToStr(rReserved/AFeat.rInitialTrimmedTarget) + ',' +
                                                   FloatToStr(r_A) + ',' +
                                                   FloatToStr(r_B) + ',' +
                                                   FloatToStr(r_X_initial) + ',' +
                                                   FloatToStr(r_P_initial) + ',' +
                                                   FloatToStr(r_X_current) + ',' +
                                                   FloatToStr(r_P_current) + ',' +
                                                   FloatToStr(r_P_delta)
                             );
                     //'SiteIndex,FeatureIndex,target,amount,contrib,reserved,initial target,'
                     //'Vulnerability,[1-TgtContribFeatureX],[1-TgtMetFeatureX],[TgtMetFeatureX],'
                     //'A,B,X initial,P initial,X current,P current,P delta'
                end;
           end;
   end;

begin
     // return the 1-based index of the first site with the highest value
     // select the site with the highest value
     // select the first site with the highest value if there are ties for highest value
     Result := 1;
     rHighest := -1;
     rSumReservedMeasure2 := 0;
     // create validation file for this iteration
     if FastMinsetForm.CheckCreateValidateOutput.Checked then
     begin
          AssignFile(SiteValidationFile,ControlRes^.sWorkingDirectory +'\site_values_' + IntToStr(iIteration) + '.csv');
          rewrite(SiteValidationFile);
          AssignFile(FeatureValidationFile,ControlRes^.sWorkingDirectory +'\site_X_feature_values_' + IntToStr(iIteration) + '.csv');
          rewrite(FeatureValidationFile);
          writeln(SiteValidationFile,'SiteIndex,Measure1_Possibility1,Measure1_Possibility2' +
                                     ',Measure1_Possibility3,Measure2');
          writeln(FeatureValidationFile,'SiteIndex,SiteStatus,FeatureIndex,target,amount,contrib,reserved,initial target,Vulnerability,' +
                                        '[1-TgtContribFeatureX],[1-TgtMetFeatureX],[TgtMetFeatureX],' +
                                        'A,B,X initial,P initial,X current,P current,P delta');
          // SiteValidationFile, FeatureValidationFile
     end;

     // deduce a new value for each site based on SiteStatus, FeatureTargets and iMinsetRule
     for iCount := 1 to SiteValue.lMaxSize do
     begin
          rValue := 0;
          SiteStatus.rtnValue(iCount,@AStatus);
          if (AStatus = Av)
          or (AStatus = Fl) then
          begin
               // calculate a value for this available site
               SiteInfo.rtnValue(iCount,@ASiteInfo);
               case iMinsetRule of
                    0 : rValue := Return_Measure1_Possibility1;
                    1 : rValue := Return_Measure1_Possibility2;
                    2 : rValue := Return_Measure1_Possibility3;
                    3 : rValue := Return_Measure2;
                    4 : rValue := Return_bpressey_Measure2;
               end;
               {Measure1_Possibility1       = Weighted_propcontrib}
               {Measure1_Possibility2       = sum of ([TgtContribFeatureX])}
               {Measure1_Possibility3       = sum of ([TgtContribFeatureX]*[TgtMetFeatureX])}
               {Measure_2                   = sum of ([1-TgtMetFeatureX]*VulnFeatureX)}

               if (rValue > rHighest) then
               begin
                    Result := iCount;
                    rHighest := rValue;
               end;

               if FastMinsetForm.CheckCreateValidateOutput.Checked then
                  AppendValidateFile;
          end;

          SiteValue.setValue(iCount,@rValue);
     end;

     // reparse SiteValue to see if there were any ties
     iTiedSites := 0;
     for iCount := 1 to SiteValue.lMaxSize do
     begin
          SiteValue.rtnValue(iCount,@rValue);
          if (rValue = rHighest) then
             Inc(iTiedSites);
     end;

     SiteInfo.rtnValue(Result,@ASiteInfo);
     // using site index Result, propose reserve that site
     rSumReservedMeasure2 := Return_Reporting_Measure2;

     // close validation file
     if FastMinsetForm.CheckCreateValidateOutput.Checked then
     begin
          closefile(SiteValidationFile);
          closefile(FeatureValidationFile);
          // SiteValidationFile, FeatureValidationFile
     end;

     rMaximumValue := rHighest;
end;

function rtnReportTargetSumReservedMeasure2(SiteValue,SiteStatus,FeatureTargets,SiteInfo,FeatureRichness,FeatureReserved : Array_t;
                                            const iMinsetRule, iIteration : integer;
                                            var rMaximumValue, rSumReservedMeasure2 : extended;
                                            var iTiedSites : integer;
                                            const iFirstSite : integer) : extended;
var
   iCount, iFeatureRichness, iRichness : integer;
   rTarget, rFeatureContrib, rReserved,
   rValue, rHighest, rMeasure2 : extended;
   AStatus : status_t;
   ASiteInfo : SiteInfo_t;
   Value : ValueFile_T;
   AFeat : featureoccurrence;
   SiteValidationFile, FeatureValidationFile : TextFile;

   function Return_Reporting_Measure2 : extended;
   var
      iFeature : integer;
      rReportTrimmedTarget, rSum, rP_initial, rP_current, rP_weight,
      r_A, r_B, r_X_initial, r_X_current, rAmount : extended;
      SiteContents : Array_T;
      Reporting_Measure2_File : TextFile;
   begin
        if FastMinsetForm.CheckCreateValidateOutput.Checked then
        begin
             AssignFile(Reporting_Measure2_File,ControlRes^.sWorkingDirectory +'\Reporting_Measure2_RT_' + IntToStr(iIteration) + '.csv');
             rewrite(Reporting_Measure2_File);
             writeln(Reporting_Measure2_File,'FeatureIndex,target,amount,reserved,initial target,Vulnerability,' +
                                             'A,B,X initial,P initial,X current,P current,P delta');
        end;
        {Measure_2                   = sum of (VulnFeatureX * delta P)}
        rSum := 0;
        // make feature array of how much is at each site
        SiteContents := Array_T.Create;
        SiteContents.init(SizeOf(extended),iFeatureCount);
        rAmount := 0;
        for iFeature := 1 to iFeatureCount do
            SiteContents.setValue(iFeature,@rAmount);
        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                rAmount := Value.rAmount;
                SiteContents.setValue(Value.iFeatKey,@rAmount);
           end;
        // traverse the features, calculating as we go
        for iFeature := 1 to iFeatureCount do
        begin
             SiteContents.rtnValue(iFeature,@rAmount);
             ReportTarget.rtnValue(iFeature,@rTarget);
             FeatArr.rtnValue(iFeature,@AFeat);
             rReportTrimmedTarget := rTarget;
             //if (rReportTrimmedTarget > AFeat.totalarea) then
             //   rReportTrimmedTarget := AFeat.totalarea;

             if (rReportTrimmedTarget > 0) then
             begin
                  FeatureReserved.rtnValue(iFeature,@rReserved);

                  rTarget := rTarget - rReserved;
                  r_A := -ln(0.005/0.995);
                  r_B := ln(0.005/0.995)/50;
                  r_X_initial := rReserved/rReportTrimmedTarget*100;
                  if (r_X_initial > 100) then
                     r_X_initial := 100;

                  rP_initial := Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50)))/
                                (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50))))*
                                2;

                  r_X_current := (rReserved+rAmount)/rReportTrimmedTarget*100;
                  if (r_X_current > 100) then
                     r_X_current := 100;

                  rP_current := Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50)))/
                                (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50))))*
                                2;

                  rSum := rSum + (AFeat.rVulnerability * rP_current{rP_weight});

                  if FastMinsetForm.CheckCreateValidateOutput.Checked then
                     writeln(Reporting_Measure2_File,IntToStr(iFeature) + ',' +
                                                   FloatToStr(rTarget) + ',' +
                                                   FloatToStr(rAmount) + ',' +
                                                   FloatToStr(rReserved) + ',' +
                                                   FloatToStr(rReportTrimmedTarget) + ',' +
                                                   FloatToStr(AFeat.rVulnerability) + ',' +
                                                   FloatToStr(r_A) + ',' +
                                                   FloatToStr(r_B) + ',' +
                                                   FloatToStr(r_X_initial) + ',' +
                                                   FloatToStr(rP_initial) + ',' +
                                                   FloatToStr(r_X_current) + ',' +
                                                   FloatToStr(rP_current) + ',' +
                                                   FloatToStr(rP_weight));
             end;
        end;

        SiteContents.Destroy;
        Result := rSum;

        if FastMinsetForm.CheckCreateValidateOutput.Checked then
           closefile(Reporting_Measure2_File);
   end;

begin
     SiteInfo.rtnValue(iFirstSite,@ASiteInfo);
     Result := Return_Reporting_Measure2;
end;

function UpdateM1P3AndReturnFirstHighestSite(SiteValue,SiteStatus,FeatureTargets,SiteInfo,FeatureRichness,FeatureReserved : Array_t;
                                             const iMinsetRule, iIteration : integer;
                                             var rMaximumValue, rSumReservedMeasure2 : extended;
                                             var iTiedSites : integer) : integer;
var
   iCount, iFeatureRichness, iRichness : integer;
   M1P3_CONSTANT,
   rTarget, rFeatureContrib, rReserved,
   rValue, rHighest, rMeasure2 : extended;
   AStatus : status_t;
   ASiteInfo : SiteInfo_t;
   Value : ValueFile_T;
   AFeat : featureoccurrence;
   SiteValidationFile, FeatureValidationFile : TextFile;

   function Return_Measure1_Possibility3 : extended;
   var
      iFeature : integer;
      rSum, rContrib : extended;
   begin
        {Measure1_Possibility3       = sum of ([TgtContribFeatureX]*[TgtMetFeatureX])}

        rSum := 0;

        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                FeatArr.rtnValue(Value.iFeatKey,@AFeat);
                if (rTarget > 0)
                and (Value.rAmount > 0) then
                begin
                     FeatureReserved.rtnValue(Value.iFeatKey,@rReserved);

                     rContrib := rTarget;
                     if (rContrib > Value.rAmount) then
                        rContrib := Value.rAmount;
                     rSum := rSum + ((((rReserved+M1P3_CONSTANT)/AFeat.rInitialTrimmedTarget)) *
                                     ((rContrib/rTarget)));
                end;
           end;

        Result := rSum;
   end;

   function Return_Reporting_Measure2 : extended;
   var
      iFeature : integer;
      rSum, rP_initial, rP_current, rP_weight, r_A, r_B, r_X_initial, r_X_current, rAmount : extended;
      SiteContents : Array_T;
      Reporting_Measure2_File : TextFile;
   begin
        {Measure_2                   = sum of (VulnFeatureX * delta P)}
        rSum := 0;
        if FastMinsetForm.CheckCreateValidateOutput.Checked then
        begin
             AssignFile(Reporting_Measure2_File,ControlRes^.sWorkingDirectory +'\Reporting_Measure2_' + IntToStr(iIteration) + '.csv');
             rewrite(Reporting_Measure2_File);
             writeln(Reporting_Measure2_File,'FeatureIndex,target,amount,reserved,initial target,Vulnerability,' +
                                             'A,B,X initial,P initial,X current,P current,P delta');
        end;
        // make feature array of how much is at each site
        SiteContents := Array_T.Create;
        SiteContents.init(SizeOf(extended),iFeatureCount);
        rAmount := 0;
        for iFeature := 1 to iFeatureCount do
            SiteContents.setValue(iFeature,@rAmount);
        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                rAmount := Value.rAmount;
                SiteContents.setValue(Value.iFeatKey,@rAmount);
           end;
        // traverse the features, calculating as we go
        for iFeature := 1 to iFeatureCount do
        begin
             SiteContents.rtnValue(iFeature,@rAmount);
             FeatureTargets.rtnValue(iFeature,@rTarget);
             FeatArr.rtnValue(iFeature,@AFeat);
             if (AFeat.rInitialTrimmedTarget > 0) then
             begin
                  FeatureReserved.rtnValue(iFeature,@rReserved);
                  rReserved := rReserved + M1P3_CONSTANT;
                  r_A := -ln(0.005/0.995);
                  r_B := ln(0.005/0.995)/50;
                  r_X_initial := rReserved/AFeat.rInitialTrimmedTarget*100;
                  if (r_X_initial > 100) then
                     r_X_initial := 100;

                  rP_initial := Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50)))/
                                (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50))))*
                                2;

                  r_X_current := (rReserved+rAmount)/AFeat.rInitialTrimmedTarget*100;
                  if (r_X_current > 100) then
                     r_X_current := 100;

                  rP_current := Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50)))/
                                (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50))))*
                                2;

                  //rP_weight := rP_initial - rP_current;

                  rSum := rSum + (AFeat.rVulnerability * rP_current{rP_weight});

                  {p is a weighting applied to measure 2

                   p = (e^(a+bx)))/(1 + e^(a+bx))*2

                   where a and b are constants,
                         x is % of target met}

                  //'FeatureIndex,target,amount,reserved,initial target,Vulnerability,' +
                  //'A,B,X initial,P initial,X current,P current,P delta');

                  if FastMinsetForm.CheckCreateValidateOutput.Checked then
                     writeln(Reporting_Measure2_File,IntToStr(iFeature) + ',' +
                                                   FloatToStr(rTarget) + ',' +
                                                   FloatToStr(rAmount) + ',' +
                                                   FloatToStr(rReserved) + ',' +
                                                   FloatToStr(AFeat.rInitialTrimmedTarget) + ',' +
                                                   FloatToStr(AFeat.rVulnerability) + ',' +
                                                   FloatToStr(r_A) + ',' +
                                                   FloatToStr(r_B) + ',' +
                                                   FloatToStr(r_X_initial) + ',' +
                                                   FloatToStr(rP_initial) + ',' +
                                                   FloatToStr(r_X_current) + ',' +
                                                   FloatToStr(rP_current) + ',' +
                                                   FloatToStr(rP_weight));
             end;
        end;

        SiteContents.Destroy;
        Result := rSum;

        if FastMinsetForm.CheckCreateValidateOutput.Checked then
           closefile(Reporting_Measure2_File);
   end;

   procedure AppendValidateFile;
   var
      iFeature : integer;
      rContrib, r_A, r_B, r_X_initial, r_X_current, r_P_initial ,r_P_current, r_P_delta : extended;
   begin
        // SiteValidationFile, FeatureValidationFile
        writeln(SiteValidationFile,IntToStr(iCount) +
                                   ',0' +
                                   ',0' +
                                   ',' + FloatToStr(Return_Measure1_Possibility3) +
                                   ',0');

        if (ASiteInfo.iRichness > 0) then
           for iFeature := 1 to ASiteInfo.iRichness do
           begin
                FeatureAmount.rtnValue(ASiteInfo.iOffset + iFeature,@Value);
                FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
                FeatArr.rtnValue(Value.iFeatKey,@AFeat);

                if (rTarget > 0) then
                begin
                     FeatureReserved.rtnValue(Value.iFeatKey,@rReserved);
                     rReserved := rReserved + M1P3_CONSTANT;
                     rContrib := rTarget;
                     if (rContrib > Value.rAmount) then
                        rContrib := Value.rAmount;

                     r_A := -ln(0.005/0.995);
                     r_B := ln(0.005/0.995)/50;
                     // r_X_initial, r_X_current, r_P_initial ,r_P_current, r_P_delta
                     r_X_initial := (rReserved)/AFeat.rInitialTrimmedTarget*100;
                     if (r_X_initial > 100) then
                        r_X_initial := 100;
                     r_P_initial := Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50)))/
                                    (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_initial)/100)+50))))*
                                    2;
                     r_X_current := (rReserved+Value.rAmount)/AFeat.rInitialTrimmedTarget*100;
                     if (r_X_current > 100) then
                        r_X_current := 100;
                     r_P_current := Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50)))/
                                   (1+Power(Exp(1.0),r_A+(r_B*(((50*r_X_current)/100)+50))))*
                                   2;
                     r_P_delta := r_P_initial - r_P_current;

                     writeln(FeatureValidationFile,IntToStr(iCount) + ',' +
                                                   Status2Str(AStatus) + ',' +
                                                   IntToStr(Value.iFeatKey) + ',' +
                                                   FloatToStr(rTarget) + ',' +
                                                   FloatToStr(Value.rAmount) + ',' +
                                                   FloatToStr(rContrib) + ',' +
                                                   FloatToStr(rReserved) + ',' +
                                                   FloatToStr(AFeat.rInitialTrimmedTarget) + ',' +
                                                   FloatToStr(AFeat.rVulnerability) + ',' +
                                                   FloatToStr(1-(rContrib/rTarget)) + ',' +
                                                   FloatToStr(1-(rReserved/AFeat.rInitialTrimmedTarget)) + ',' +
                                                   FloatToStr(rReserved/AFeat.rInitialTrimmedTarget) + ',' +
                                                   FloatToStr(r_A) + ',' +
                                                   FloatToStr(r_B) + ',' +
                                                   FloatToStr(r_X_initial) + ',' +
                                                   FloatToStr(r_P_initial) + ',' +
                                                   FloatToStr(r_X_current) + ',' +
                                                   FloatToStr(r_P_current) + ',' +
                                                   FloatToStr(r_P_delta)
                             );
                     //'SiteIndex,FeatureIndex,target,amount,contrib,reserved,initial target,'
                     //'Vulnerability,[1-TgtContribFeatureX],[1-TgtMetFeatureX],[TgtMetFeatureX],'
                     //'A,B,X initial,P initial,X current,P current,P delta'
                end;
           end;
   end;

begin
     // return the 1-based index of the first site with the highest value
     // select the site with the highest value
     // select the first site with the highest value if there are ties for highest value
     Result := 1;
     rHighest := -1;
     rSumReservedMeasure2 := 0;
     M1P3_CONSTANT := 0.0000001;
     // create validation file for this iteration
     if FastMinsetForm.CheckCreateValidateOutput.Checked then
     begin
          AssignFile(SiteValidationFile,ControlRes^.sWorkingDirectory +'\site_values_M1P3_' + IntToStr(iIteration) + '.csv');
          rewrite(SiteValidationFile);
          AssignFile(FeatureValidationFile,ControlRes^.sWorkingDirectory +'\site_X_feature_values_M1P3_' + IntToStr(iIteration) + '.csv');
          rewrite(FeatureValidationFile);
          writeln(SiteValidationFile,'SiteIndex,Measure1_Possibility1,Measure1_Possibility2' +
                                     ',Measure1_Possibility3,Measure2');
          writeln(FeatureValidationFile,'SiteIndex,SiteStatus,FeatureIndex,target,amount,contrib,reserved,initial target,Vulnerability,' +
                                        '[1-TgtContribFeatureX],[1-TgtMetFeatureX],[TgtMetFeatureX],' +
                                        'A,B,X initial,P initial,X current,P current,P delta');
          // SiteValidationFile, FeatureValidationFile
     end;

     // deduce a new value for each site based on SiteStatus, FeatureTargets and iMinsetRule
     for iCount := 1 to SiteValue.lMaxSize do
     begin
          rValue := 0;
          SiteStatus.rtnValue(iCount,@AStatus);
          if (AStatus = Av)
          or (AStatus = Fl) then
          begin
               // calculate a value for this available site
               SiteInfo.rtnValue(iCount,@ASiteInfo);
               rValue := Return_Measure1_Possibility3;

               if (rValue > rHighest) then
               begin
                    Result := iCount;
                    rHighest := rValue;
               end;

               if FastMinsetForm.CheckCreateValidateOutput.Checked then
                  AppendValidateFile;
          end;

          SiteValue.setValue(iCount,@rValue);
     end;

     // reparse SiteValue to see if there were any ties
     iTiedSites := 0;
     for iCount := 1 to SiteValue.lMaxSize do
     begin
          SiteValue.rtnValue(iCount,@rValue);
          if (rValue = rHighest) then
             Inc(iTiedSites);
     end;

     SiteInfo.rtnValue(Result,@ASiteInfo);
     // using site index Result, propose reserve that site
     rSumReservedMeasure2 := Return_Reporting_Measure2;

     // close validation file
     if FastMinsetForm.CheckCreateValidateOutput.Checked then
     begin
          closefile(SiteValidationFile);
          closefile(FeatureValidationFile);
          // SiteValidationFile, FeatureValidationFile
     end;

     rMaximumValue := rHighest;
end;

procedure DumpSortedSites(SortedSites : Array_t);
var
   iCount, iSiteIndex : integer;
   OutFile : TextFile;
   Value : trueFeattype;
begin
     assignfile(OutFile,'c:\sortedsites.csv');
     rewrite(OutFile);

     for iCount := 1 to SortedSites.lMaxSize do
     begin
          SortedSites.rtnValue(iCount,@Value);
          writeln(OutFile,IntToStr(Value.iCode));
     end;

     closefile(OutFile);
end;

procedure AddSiteIndex(const iSiteIndex : integer;
                       var iSelectedSites : integer;
                       SelectedSites : Array_t);
begin
     // add the site index to the array of selected sites
     Inc(iSelectedSites);
     if (iSelectedSites > SelectedSites.lMaxSize) then
        SelectedSites.resize(SelectedSites.lMaxSize + 1000);
     SelectedSites.setValue(iSelectedSites,@iSiteIndex);
end;

procedure ReserveSite(const iSiteIndex : integer;
                      FeatureTargets, SiteStatus, FeatureRichness, ReachedTarget, SiteInfo, FeatureReserved : Array_t);
var
   iCount, iRichness : integer;
   ASiteInfo : SiteInfo_t;
   AStatus : status_t;
   rTarget, rReserved : extended;
   Value : ValueFile_T;
   fTargetAlreadyMet, fReachedTarget : boolean;
begin
     // adjust the FeatureTargets to indicate that this site is now reserved
     fReachedTarget := True;
     SiteInfo.rtnValue(iSiteIndex,@ASiteInfo);
     if (ASiteInfo.iRichness > 0) then
        for iCount := 1 to ASiteInfo.iRichness do
        begin
             FeatureAmount.rtnValue(ASiteInfo.iOffset + iCount,@Value);
             FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);
             // TRUE = target not met
             // FALSE = target already met
             fTargetAlreadyMet := (rTarget <= 0);
             rTarget := rTarget - Value.rAmount;
             //fReachedTarget := (rTarget <= 0);
             //if (not fTargetAlreadyMet)
             //and fReachedTarget then
                 // mark this target as just met
             //    ReachedTarget.setValue(Value.iFeatKey,@fReachedTarget);
             FeatureTargets.setValue(Value.iFeatKey,@rTarget);

             if not fTargetAlreadyMet then
             begin
                  //fReachedTarget := True;
                  ReachedTarget.setValue(Value.iFeatKey,@fReachedTarget);
             end;

             // reduce the feature richness for this feature
             FeatureRichness.rtnValue(Value.iFeatKey,@iRichness);
             Dec(iRichness);
             FeatureRichness.setValue(Value.iFeatKey,@iRichness);

             // update feature reserved
             FeatureReserved.rtnValue(Value.iFeatKey,@rReserved);
             rReserved := rReserved + Value.rAmount;
             FeatureReserved.setValue(Value.iFeatKey,@rReserved);
        end;
     // adjust status, make the status of iSiteIndex R1
     AStatus := _R1;
     SiteStatus.setValue(iSiteIndex,@AStatus);
end;

procedure UnReserveSite(const iSiteIndex : integer;
                        FeatureTargets, SiteStatus, FeatureRichness, SiteInfo, FeatureReserved : Array_t);
var
   iCount, iRichness : integer;
   ASiteInfo : SiteInfo_t;
   AStatus : status_t;
   rTarget, rReserved : extended;
   Value : ValueFile_T;
begin
     // adjust the FeatureTargets to indicate that this site is now reserved
     SiteInfo.rtnValue(iSiteIndex,@ASiteInfo);
     if (ASiteInfo.iRichness > 0) then
        for iCount := 1 to ASiteInfo.iRichness do
        begin
             FeatureAmount.rtnValue(ASiteInfo.iOffset + iCount,@Value);
             FeatureTargets.rtnValue(Value.iFeatKey,@rTarget);

             rTarget := rTarget + Value.rAmount;

             // increase the feature richness for this feature
             FeatureRichness.rtnValue(Value.iFeatKey,@iRichness);
             Inc(iRichness);
             FeatureRichness.setValue(Value.iFeatKey,@iRichness);

             FeatureTargets.setValue(Value.iFeatKey,@rTarget);

             // update feature reserved
             FeatureReserved.rtnValue(Value.iFeatKey,@rReserved);
             rReserved := rReserved - Value.rAmount;
             FeatureReserved.setValue(Value.iFeatKey,@rReserved);
        end;
     // adjust status, make the status of iSiteIndex R1
     AStatus := Av;
     SiteStatus.setValue(iSiteIndex,@AStatus);
end;

procedure WriteSelectedSites(const iSelectedSites : integer;
                             SelectedSites : Array_t);
var
   OutFile : TextFile;
   iCount, iSiteIndex : integer;
   ASite : site;
begin
     assignfile(OutFile,ControlRes^.sWorkingDirectory + '\FastMinsetOutput_SelectedSiteKeys.txt');
     rewrite(OutFile);

     for iCount := 1 to iSelectedSites do
     begin
          SelectedSites.rtnValue(iCount,@iSiteIndex);
          SiteArr.rtnValue(iSiteIndex,@ASite);
          writeln(OutFile,IntToStr(ASite.iKey));
     end;

     closefile(OutFile);
end;

procedure DestroySitesContainingFeatureSubArrays(SitesContainingFeature : Array_t);
var
   iCount : integer;
   SiteArray : Array_t;
begin
     for iCount := 1 to SitesContainingFeature.lMaxSize do
     begin
          SitesContainingFeature.rtnValue(iCount,@SiteArray);
          SiteArray.Destroy;
     end;
end;

procedure DumpSites(SiteStatus,SiteValue : Array_t;
                    iIteration : integer);
var
   iCount : integer;
   OutFile : TextFile;
   AStatus : status_t;
   rValue : extended;
begin
     assignfile(OutFile,ControlRes^.sWorkingDirectory + '\dump_sites' + IntToStr(iIteration) + '.csv');
     rewrite(OutFile);
     writeln(OutFile,'SiteIndex,Status,Value');

     for iCount := 1 to SiteStatus.lMaxSize do
     begin
          SiteStatus.rtnValue(iCount,@AStatus);
          SiteValue.rtnValue(iCount,@rValue);
          writeln(OutFile,IntToStr(iCount) + ',' + Status2Str(AStatus) + ',' + FloatToStr(rValue));
     end;

     closefile(OutFile);
end;

procedure DumpFeatures(FeatureTargets : Array_t;
                       iIteration : integer);
var
   iCount : integer;
   OutFile : TextFile;
   rValue : extended;
begin
     assignfile(OutFile,ControlRes^.sWorkingDirectory + '\dump_features' + IntToStr(iIteration) + '.csv');
     rewrite(OutFile);
     writeln(OutFile,'FeatureIndex,Status,Value');

     for iCount := 1 to FeatureTargets.lMaxSize do
     begin
          FeatureTargets.rtnValue(iCount,@rValue);
          writeln(OutFile,IntToStr(iCount) + ',' + FloatToStr(rValue));
     end;

     closefile(OutFile);
end;

procedure InitSiteIndexSetArray(SiteIndexSet : Array_t);
var
   iCount : integer;
   fValue : boolean;
begin
     fValue := False;
     for iCount := 1 to iSiteCount do
         SiteIndexSet.setValue(iCount,@fValue);
end;

function MakeSiteIndexSetArray : Array_t;
begin
     Result := Array_T.Create;
     Result.init(SizeOf(boolean),iSiteCount);
     InitSiteIndexSetArray(Result);
end;

procedure InitJoinedSitesArray(JoinedSites : Array_t);
var
   iCount, iValue : integer;
begin
     iValue := 0;
     for iCount := 1 to iSiteCount do
         JoinedSites.setValue(iCount,@iValue);
end;

function MakeJoinedSitesArray : Array_t;
begin
     Result := Array_T.Create;
     Result.init(SizeOf(integer),iSiteCount);
     InitJoinedSitesArray(Result);
end;

function ProcessRedundantSites(FeatureTargets,SiteStatus, FeatureRichness, SiteInfo, FeatureReserved : Array_t) : integer;
var
   iCount : integer;
   rTarget : extended;
   AStatus : Status_T;
begin
     Result := 0;

     for iCount := 1 to SiteStatus.lMaxSize do
     begin
          SiteStatus.rtnValue(iCount,@AStatus);
          if (AStatus = _R1)
          or (AStatus = _R2)
          or (AStatus = _R3)
          or (AStatus = _R4)
          or (AStatus = _R5) then
          begin
               // test if this reserved site is redundant
               // de-select it if it is redundant
               if IsSiteRedundant(iCount,FeatureTargets,False) then
               begin
                    Inc(Result);
                    UnReserveSite(iCount, FeatureTargets, SiteStatus, FeatureRichness, SiteInfo, FeatureReserved);
               end;
          end;
     end;
end;

function WouldTargetsBeReached(const iSiteIndex : integer;
                               FeatureTargets, SiteInfo : Array_t) : boolean;
var
   ASite : site;
   ProposedTargets : Array_t;
   Value : ValueFile_T;
   rTarget : extended;
   iCount : integer;
   ASiteInfo : SiteInfo_t;
begin
     // create a target array
     ProposedTargets := Array_T.Create;
     ProposedTargets.init(SizeOf(extended),iFeatureCount);
     for iCount := 1 to iFeatureCount do
     begin
          FeatureTargets.rtnValue(iCount,@rTarget);
          ProposedTargets.setValue(iCount,@rTarget);
     end;

     // calculate what the target would be if this site was reserved
     SiteInfo.rtnValue(iSiteIndex,@ASiteInfo);
     if (ASiteInfo.iRichness > 0) then
        for iCount := 1 to ASiteInfo.iRichness do
        begin
             FeatureAmount.rtnValue(ASiteInfo.iOffset + iCount,@Value);
             ProposedTargets.rtnValue(Value.iFeatKey,@rTarget);

             rTarget := rTarget - Value.rAmount;

             ProposedTargets.setValue(Value.iFeatKey,@rTarget);
        end;

     // are all targets satisfied with the addition of this site ?
     Result := True;
     for iCount := 1 to iFeatureCount do
     begin
          ProposedTargets.rtnValue(iCount,@rTarget);
          if (rTarget > 0) then
             Result := False;
     end;

     ProposedTargets.Destroy;
end;

procedure ExecuteFastMinset(const iMinsetRule : integer;
                            const fRedundancyCheckEachIteration : boolean;
                            const fProfileExecution : boolean;
                            const fUseAreaStoppingCondition : boolean;
                            const rAreaStop : extended;
                            const fDebugZeroMaxValue : boolean);
var
   SiteIndexSet, JoinedSites,
   FeatureTargets, FeatureRichness, FeatureReserved, SiteStatus, SelectedSites,
   SiteValue, SiteInfo, SitesContainingFeature, ReachedTarget : Array_T;
   iSitesAvailable, iSitesRedundant, iSelectedSites, iFeaturesSatisfied, iReportTargetFeaturesSatisfied,
   iSitesReserved, iIteration, iSiteIndex, iTiedSites : integer;
   OutFile, LogFile, ProfileFile : textfile;
   Present, Hour, Min, Sec, MSec : word;
   iTotalFeaturesBelowTgt,iTotalFeaturesChangeTgt : integer;
   fProfileV4, fAreaStop : boolean;
   ProfileV4 : TextFile;
   rMaximumValue, rSumReservedMeasure2, rReportTargetSumReservedMeasure2, rTotalArea : extended;
   ASite : site;

   procedure AddProfileEntry(const sMsg : string);
   begin
        DecodeTime(Now, Hour, Min, Sec, MSec);
        writeln(ProfileFile,sMsg + ' ' + IntToStr(Hour) + ':' + IntToStr(Min) + ':' + IntToStr(Sec) + ':' + IntToStr(MSec));
   end;

begin
     try
        fAreaStop := False;
        rTotalArea := 0;
        assignfile(LogFile,ControlRes^.sWorkingDirectory + '\FastMinsetOutput.txt');
        rewrite(LogFile);
        DecodeTime(Now, Hour, Min, Sec, MSec);
        writeln(LogFile,'Minset started ' + FormatDateTime('dddd," "mmmm d, yyyy',Now) + ' ' +
                        IntToStr(Hour) + ':' + IntToStr(Min) + ':' + IntToStr(Sec) + ':' + IntToStr(MSec));
        writeln(LogFile,'Minset = ' + IntToStr(iMinsetRule));
        writeln(LogFile,'Redundancy Check = ' + Bool2String(fRedundancyCheckEachIteration));
        writeln(LogFile,'');
        if fProfileExecution then
        begin
             assignfile(ProfileFile,ControlRes^.sWorkingDirectory + '\FastMinsetProfile.txt');
             rewrite(ProfileFile);
             AddProfileEntry('begin');
        end;
        // added for V3
        FeatureReserved := MakeFeatureReservedArray;
        SiteIndexSet := MakeSiteIndexSetArray;
        JoinedSites := MakeJoinedSitesArray;
        // stopping condition = all features satisfied
        // make a site status array and make changes to this as we proceed
        SiteStatus := MakeStatusArray(iSitesReserved);
        // make an array of selected sites
        iSelectedSites := 0;
        SelectedSites := MakeSelectedSites;
        SiteValue := MakeSiteValue;
        SiteInfo := MakeSiteInfoArray;
        SitesContainingFeature := MakeSitesContainingFeatureArray;
        //DumpSitesContainingFeatureArray(SitesContainingFeature);
        // make a feature target array and make changes to this as we proceed
        FeatureTargets := MakeTargetsArray(iFeaturesSatisfied);
        FeatureRichness := MakeFeatureRichness;
        UpdateFeatureRichness(FeatureRichness,FeatureTargets,SiteStatus,SiteInfo);
        ReachedTarget := MakeReachedTargetArray;
        ResetReachedTarget(ReachedTarget);
        // ie. do not modify C-Plan data structures
        // create and initialise OutFile
        iSitesAvailable := ControlForm.Available.Items.Count +
                           ControlForm.Flagged.Items.Count;
        iIteration := 0;
        iSiteIndex := UpdateSiteValueAndReturnFirstHighestSite(SiteValue,SiteStatus,FeatureTargets,SiteInfo,FeatureRichness,FeatureReserved,iMinsetRule,iIteration,rMaximumValue,rSumReservedMeasure2,iTiedSites);
        //if (rMaximumValue = 0)
        //and fDebugZeroMaxValue then
        //    DebugSiteValueAndReturnFirstHighestSite(SiteValue,SiteStatus,FeatureTargets,SiteInfo,FeatureRichness,FeatureReserved,iMinsetRule,iIteration,rMaximumValue,rSumReservedMeasure2,iTiedSites);
        rReportTargetSumReservedMeasure2 := rtnReportTargetSumReservedMeasure2(SiteValue,SiteStatus,FeatureTargets,SiteInfo,FeatureRichness,FeatureReserved,iMinsetRule,iIteration,rMaximumValue,rSumReservedMeasure2,iTiedSites,iSiteIndex);
        iReportTargetFeaturesSatisfied := ReturnReportTargetFeaturesSatisfied(FeatureReserved);
        assignfile(OutFile,ControlRes^.sWorkingDirectory + '\FastMinsetOutput.csv');
        rewrite(OutFile);
        writeln(OutFile,'Iteration,Sites Reserved,Sites Available,Sites Redundant,Features Satisfied,ReportTarget Features Satisfied,% of Features Satisfied,ReportTarget % of Features Satisfied,Measure2,ReportTarget Measure2,TiedSites,maximum value');
        writeln(OutFile,'0,' +
                        IntToStr(iSitesReserved) + ',' +
                        IntToStr(iSitesAvailable) + ',' +
                        '0,' +
                        IntToStr(iFeaturesSatisfied) + ',' +
                        IntToStr(iReportTargetFeaturesSatisfied) + ',' +
                        FloatToStr(iFeaturesSatisfied/iFeatureCount*100) + ',' +
                        FloatToStr(iReportTargetFeaturesSatisfied/iFeatureCount*100) + ',' +
                        FloatToStr(rSumReservedMeasure2) + ',' +
                        FloatToStr(rReportTargetSumReservedMeasure2) + ',' +
                        IntToStr(iTiedSites) + ',' +
                        FloatToStr(rMaximumValue));
        iSitesRedundant := 0;
        //DumpSites(SiteStatus,SiteValue,0);
        //DumpFeatures(FeatureTargets,0);
        // repeat selecting sites until all features are satisfied
        fProfileV4 := False;
        if fProfileV4 then
        begin
             assignfile(ProfileV4,ControlRes^.sWorkingDirectory + '\profile_V4.csv');
             rewrite(ProfileV4);
             writeln(ProfileV4,'Iteration,TotalFeaturesBelowTgt,TotalFeaturesChangeTgt');
        end;

        if (iFeaturesSatisfied < iFeatureCount) then
           repeat
                 Inc(iIteration);
                 // calculate value
                 // select site with first highest value in the list
                 if fProfileExecution then
                    AddProfileEntry('before UpdateSiteValueAndReturnFirstHighestSite');

                 if (iIteration > 1) then
                 begin
                      iSiteIndex := UpdateSiteValueAndReturnFirstHighestSite(SiteValue,SiteStatus,FeatureTargets,
                                                                             SiteInfo,FeatureRichness,FeatureReserved,iMinsetRule,iIteration,
                                                                             rMaximumValue,rSumReservedMeasure2,iTiedSites);
                      if (rMaximumValue = 0)
                      and fDebugZeroMaxValue then
                          DebugSiteValueAndReturnFirstHighestSite(SiteValue,SiteStatus,FeatureTargets,SiteInfo,FeatureRichness,FeatureReserved,iMinsetRule,iIteration,rMaximumValue,rSumReservedMeasure2,iTiedSites);

                      rReportTargetSumReservedMeasure2 := rtnReportTargetSumReservedMeasure2(SiteValue,SiteStatus,FeatureTargets,SiteInfo,FeatureRichness,FeatureReserved,iMinsetRule,iIteration,rMaximumValue,rSumReservedMeasure2,iTiedSites,iSiteIndex);
                 end;

                 // if iMinsetRule = 2   (ie. Measure 1 Possibility 3 is in use)
                 // and rMaximumValue = 0
                 // and (Reserving this site would leave 1 or more features below target) then
                 //     Recalculate Measure 1 Possibility 3 with a constant and find the highest site
                 if (iMinsetRule = 2) then
                    if (rMaximumValue = 0) then
                       if (not WouldTargetsBeReached(iSiteIndex,FeatureTargets,SiteInfo)) then
                          iSiteIndex := UpdateM1P3AndReturnFirstHighestSite(SiteValue,SiteStatus,FeatureTargets,
                                                                            SiteInfo,FeatureRichness,FeatureReserved,iMinsetRule,iIteration,
                                                                            rMaximumValue,rSumReservedMeasure2,iTiedSites);

                 if fProfileExecution then
                    AddProfileEntry('after UpdateSiteValueAndReturnFirstHighestSite');

                 // add site index to SelectedSites
                 AddSiteIndex(iSiteIndex,iSelectedSites,SelectedSites);
                 // adjust status, make the status of iSiteIndex R1
                 // adjust target
                 ResetReachedTarget(ReachedTarget);
                 ReserveSite(iSiteIndex,FeatureTargets,SiteStatus,FeatureRichness,ReachedTarget,SiteInfo,FeatureReserved);

                 // perform redundancy check if necessary
                 // adjust status of redundant site(s) if necessary
                 // mark redundant sites(s) in SelectedSites array if necessary (change their index to -1)
                 if FastMinsetForm.CheckRedCheck.Checked then
                    iSitesRedundant := iSitesRedundant +
                                       ProcessRedundantSites(FeatureTargets,SiteStatus,FeatureRichness,SiteInfo,FeatureReserved);

                 iFeaturesSatisfied := ReturnNumberOfFeatureTargetsSatisfied(FeatureTargets);
                 iReportTargetFeaturesSatisfied := ReturnReportTargetFeaturesSatisfied(FeatureReserved);
                 iSitesReserved := ReturnNumberOfSitesReserved(SiteStatus,iSitesAvailable);

                 // append a row to the output file
                 writeln(OutFile,IntToStr(iIteration) + ',' +
                                 IntToStr(iSitesReserved) + ',' +
                                 IntToStr(iSitesAvailable) + ',' +
                                 IntToStr(iSitesRedundant) + ',' +
                                 IntToStr(iFeaturesSatisfied) + ',' +
                                 IntToStr(iReportTargetFeaturesSatisfied) + ',' +
                                 FloatToStr(iFeaturesSatisfied/iFeatureCount*100) + ',' +
                                 FloatToStr(iReportTargetFeaturesSatisfied/iFeatureCount*100) + ',' +
                                 FloatToStr(rSumReservedMeasure2) + ',' +
                                 FloatToStr(rReportTargetSumReservedMeasure2) + ',' +
                                 IntToStr(iTiedSites) + ',' +
                                 FloatToStr(rMaximumValue));
                 if fProfileExecution then
                    AddProfileEntry('after ReturnNumberOfSitesReserved');

                 SiteArr.rtnValue(iSiteIndex,@ASite);
                 rTotalArea := rTotalArea + ASite.area;
                 if fUseAreaStoppingCondition then
                 begin
                      if (rTotalArea >= rAreaStop) then
                         fAreaStop := True;
                 end;

           until ((iFeaturesSatisfied = iFeatureCount)
                  or (iSitesAvailable = 0)
                  or (rMaximumValue <= 0)
                  or fAreaStop);

        // write the selected sites array to a file (it contains a list of site indexes selected)
        // redundant sites in this array have an index of -1, so skip over them
        WriteSelectedSites(iSelectedSites,SelectedSites);
        // free datastructures used
        FeatureReserved.Destroy;
        FeatureTargets.Destroy;
        FeatureRichness.Destroy;
        ReachedTarget.Destroy;
        SiteStatus.Destroy;
        SelectedSites.Destroy;
        SiteValue.Destroy;
        SiteInfo.Destroy;
        DestroySitesContainingFeatureSubArrays(SitesContainingFeature);
        SitesContainingFeature.Destroy;
        SiteIndexSet.Destroy;
        JoinedSites.Destroy;

        closefile(OutFile);
        writeln(LogFile,'');
        DecodeTime(Now, Hour, Min, Sec, MSec);
        writeln(LogFile,'Minset finished ' + FormatDateTime('dddd," "mmmm d, yyyy',Now) + ' ' +
                        IntToStr(Hour) + ':' + IntToStr(Min) + ':' + IntToStr(Sec) + ':' + IntToStr(MSec));
        closefile(LogFile);
        if fProfileExecution then
        begin
             AddProfileEntry('end');
             closefile(ProfileFile);
        end;

        if fProfileV4 then
           closefile(ProfileV4);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ExecuteFastMinset',mtError,[mbOk],0);
     end;
end;

procedure TFastMinsetForm.BitBtnOkClick(Sender: TObject);
begin
     Screen.Cursor := crHourglass;

     ExecuteFastMinset(RadioMinset.ItemIndex,CheckRedCheck.Checked,False,
                       checkAreaStopCond.Checked,StrToFloat(EditAreaCutoff.Text),
                       CheckDebugZeroMaxValue.Checked);

     Screen.Cursor := crDefault;
end;

end.
