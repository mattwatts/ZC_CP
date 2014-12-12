unit rules;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, StdCtrls, Buttons, Spin, DBTables, Db, ds,
  Global;

type
  TRulesForm = class(TForm)
    Panel1: TPanel;
    RuleBox: TListBox;
    btnDelete: TButton;
    Button2: TButton;
    btnEdit: TButton;
    Button4: TButton;
    UpDown1: TUpDown;
    Label1: TLabel;
    ValueBox: TComboBox;
    OperatorGroup: TRadioGroup;
    VariableBox: TListBox;
    Label2: TLabel;
    OpenRules: TOpenDialog;
    SaveRules: TSaveDialog;
    btnAddRule: TButton;
    btnExecute: TBitBtn;
    BitBtn3: TBitBtn;
    checkLoadValues: TCheckBox;
    checkSortValues: TCheckBox;
    QueryTable: TTable;
    SQLQuery: TQuery;
    SpinDistance: TSpinEdit;
    Label3: TLabel;
    DatabaseVariableBox: TListBox;
    AdjacencyTimer: TTimer;
    ProximityTimer: TTimer;
    btnOptions: TButton;
    SortBox: TListBox;
    MultiPanel: TPanel;
    btnLoadSpec: TButton;
    btnClone: TButton;
    btnSaveSpec: TButton;
    btnExecuteMinsets: TButton;
    Label4: TLabel;
    ComboOf: TComboBox;
    lblOf: TLabel;
    SaveSequenceDialog: TSaveDialog;
    OpenSequenceDialog: TOpenDialog;
    btnDeleteMinset: TButton;
    Label5: TLabel;
    procedure OperatorGroupClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure RuleBoxClick(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    function rtnSelectedSite : integer;
    procedure Button1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LoadValues(const sTheField : string);
    procedure SortIntFields;
    procedure SortFloatFields;
    function rtnSelectedVariable : integer;
    procedure VariableBoxClick(Sender: TObject);
    procedure checkLoadValuesClick(Sender: TObject);
    procedure checkSortValuesClick(Sender: TObject);
    procedure RuleBoxDblClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure btnExecuteClick(Sender: TObject);
    procedure btnStopThreadClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure SaveMinsetSpecification(const sFilename : string);
    procedure LoadMinsetSpecification(const sFilename : string);
    procedure AdjacencyTimerTimer(Sender: TObject);
    procedure ProximityTimerTimer(Sender: TObject);
    procedure btnOptionsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    function ScanRuleList : boolean;
    procedure btnLoadSpecClick(Sender: TObject);
    procedure btnSaveSpecClick(Sender: TObject);
    procedure btnCloneClick(Sender: TObject);
    procedure LoadSequence(const sFilename : string);
    procedure SaveSequence(const sFilename : string);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MoveToMinset(const iMinsetToMoveTo : integer);
    procedure ComboOfChange(Sender: TObject);
    procedure btnDeleteMinsetClick(Sender: TObject);
    procedure DeleteCurrentMinset;
    procedure btnExecuteMinsetsClick(Sender: TObject);
    procedure ExecuteSequence(fShowEndDialog : boolean);
    procedure AutosaveSequence;
    procedure SpinDistanceChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  RulesForm: TRulesForm;
  iNumberOfMinsets, iCurrentMinset,
  iMinsetFlag : integer;
  CurrentFieldType : TFieldType;
  fClicking : boolean;
  rTotalResource, rDeferred, rPartDeferred : extended;
  iResArrCount : integer;
  ResArray : Array_t;
  fAdjProxArithOnly : boolean;
  ClassesToTest : ClassDetail_T;
  SelectLog : TextFile;
  Hotspots_Area_Indices,
  CacheSelectRule, CacheArithmeticRule, CacheVuln,
  StoreComplementarityTarget, CrownLandSites : Array_t;
  fCrownLandSitesCreated,
  fHotspots_Area_Indices_Created : boolean;

{these functions are used by TMinsetThread in unit mthread}
procedure LoadResourceArray(const sField : string);
function SiteStatusOk(const sStatus : string) : boolean;
procedure ExtractRule(const sRule : string;
                      var sType, sField,sOperator,sValue : string);
function ApplyRule(const iCurrentRule : integer;
                   SitesChosen, ValuesChosen : Array_t;
                   const sType, sField, sOperator, sValue : string;
                   const iSelectionsPerIteration : integer;
                   var fSuspendExecution : boolean;
                   const fDebug : boolean;
                   const iCurrentIteration : integer;
                   const fApplyComplementarity, fRecalculateComplementarity, fComplementarity : boolean) : boolean;
function IsResourceLimitExceeded(const iBestCount : integer;
                                 const BestArray : Array_t;
                                 const iPercentWeCanDeferr : integer) : boolean;
procedure MinsetSelectSites(SitesChosen : Array_t;
                            const fComplementarity : boolean;
                            var rAreaOfSitesChosen : extended);
function StoppingConditionReached(const iIterationCount : integer;
                                  const fStop : boolean;
                                  const iSitesSelected : integer;
                                  const fDebug : boolean) : boolean;
procedure UpdateDatabaseGIS;

function SitesWriteToFile(const sFilename : string;
                          SitesToFile : Array_t) : boolean;
function SitesReadFromFile(const sFilename : string;
                           SitesFromFile : Array_t) : boolean;
procedure ProcessArcViewResult;


procedure NormaliseValues(var Values : Array_t;
                          const SiteInputKeys : Array_t;
                          const rHi, rLo, rNormaliseLo, rNormaliseHi : extended{;
                          const fDebug : boolean});
procedure NormaliseIDValues(var Values : Array_t;
                            const SiteInputKeys : Array_t;
                            const rHi, rLo, rNormaliseLo, rNormaliseHi : extended{;
                            const fDebug : boolean});
procedure GetWavVuln(var WavVuln : Array_t;
                     const SiteInputKeys : Array_t;
                     var rHi : extended;
                     const {fDebug,} fComplementarityTarget : boolean);
procedure GetMaxVuln(var MaxVuln : Array_t;
                     const SiteInputKeys : Array_t;
                     var rHi : extended;
                     const {fDebug,} fComplementarityTarget : boolean);
procedure NormaliseMaxVuln(var InputValues : Array_t;
                           var rInputHi,rInputLo : extended;
                           const SiteInputKeys : Array_t;
                           const fDebug,fApplyComplementarity,fRecalculateComplementarity : boolean);
procedure NormaliseWavVuln(var InputValues : Array_t;
                           var rInputHi,rInputLo : extended;
                           const SiteInputKeys : Array_t;
                           const fDebug,fApplyComplementarity,fRecalculateComplementarity : boolean);
procedure RestrictVuln({var} InputValues : Array_t;
                       const SiteInputKeys : Array_t;
                       {const fDebug : boolean;}
                       var rHi, rLo : extended;
                       const fApplyComplementarity, fRecalculateComplementarity : boolean);
function GetIDMaxVuln(var IDMaxVuln : Array_t;
                      var rHi : extended;
                      const SiteInputKeys : Array_t;
                      const {fDebug,} fComplementarityTarget : boolean) : integer;

procedure InitSelectionLog;
procedure CloseSelectionLog;
function rtnFieldIndex(const sName : string;
                       TheTable : TTable) : integer;
procedure DebugSumirrWeightings(const iIterationCounter : integer);
procedure DumpSumirrWeightings(const sDir : string);

// added 050700 to implement hotspots no compl, destruct area rules
function DetectMinsetAreaRule : boolean;
procedure Init_Hotspots_Area_Indices;
procedure LoadLogFile(const sFilename : string;
                      const CombinationSizeCondition : CombinationSizeCondition_T);
procedure DebugWavVuln(WavVuln : Array_t;
                       const fDebug : boolean);
procedure DebugMaxVuln(MaxVuln : Array_t;
                       const fDebug : boolean);

implementation

uses
    editrule, Control,
    Arr2lbox, Sorts, Choosere, Dll_u1,
    Contribu, Minset, Sf_irrep, Em_newu1,
    Highligh, mthread, minstop, Toolmisc,
    av1, arithrle, spatio, reallist,
    msetexpt, destruct,
    FileCtrl, inifiles,
    ordclass, msetinf,
    opt1, reinit, choosedbf,
    options,
    hotspots_nocomplementarity_areaindices,
    FirstSiteReport, validate,
    getuservalidatefile{,destruct},
    reports;

{$R *.DFM}

function DetectMinsetAreaRule : boolean;
begin
     //
end;

procedure Init_Hotspots_Area_Indices;
var
   iCount : integer;
   HAI, initHAI : Hotspots_Area_Indices_T;
   pSite : sitepointer;
   fCalculateArithmeticVariables : boolean;
begin
     try
        new(pSite);
        // prepare and initialise the data structure
        if not fHotspots_Area_Indices_Created then
        begin
             Hotspots_Area_Indices := Array_T.Create;
             Hotspots_Area_Indices.init(SizeOf(Hotspots_Area_Indices_T),iSiteCount);

             fHotspots_Area_Indices_Created := True;

             initHAI.rWeightedPercentTarget := 0;
             initHAI.rMaxRarity := 0;
             initHAI.rRichness := 0;
             initHAI.rSummedRarity := 0;
             initHAI.rIrreplaceability := 0;
             initHAI.rSumirr := 0;

             for iCount := 1 to iSiteCount do
             begin
                  // init the values for this site
                  Hotspots_Area_Indices.setValue(iCount,@initHAI);
             end;
        end;

        dispose(pSite);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Init_Hotspots_Area_Indices',mtError,[mbOk],0);
     end;
end;

procedure DebugSumirrWeightings(const iIterationCounter : integer);
var
   DebugFile : TextFile;
   pSite : sitepointer;
   iCount : integer;
   WS : WeightedSumirr_T;
   MSW : MinsetSumirrWeightings_T;
   sLine : string;
begin
     try
        if ControlRes^.fValidateMode then
           if ControlRes^.fCalculateAllVariations
           or ControlRes^.fCalculateBobsExtraVariations then
           begin
                assignfile(DebugFile,ControlRes^.sWorkingDirectory +
                                     '\' + 
                                     IntToStr(iIterationCounter) +
                                     '\sumirr_weighting' +
                                     IntToStr(iIterationCounter) +
                                     '.csv');
                rewrite(DebugFile);
                // write header row to the file
                write(DebugFile,'SiteKey');
                if ControlRes^.fCalculateAllVariations then
                   write(DebugFile,',SUM_PA,SUM_IT,SUM_VU,SUM_PAIT,SUM_PAVU,SUM_ITVU,SUM_PAITVU');
                if ControlRes^.fCalculateBobsExtraVariations then
                   write(DebugFile,',SUM_CR,SUM_PT,SUM_CRIT,SUM_CRVU,SUM_CRITVU,SUM_SA,SUM_SAPA,SUM_SAPT,SUM_PAPT');
                writeln(DebugFile);
                new(pSite);
                for iCount := 1 to iSiteCount do
                begin
                     SiteArr.rtnValue(iCount,pSite);
                     write(DebugFile,IntToStr(pSite^.iKey));

                     if ControlRes^.fCalculateAllVariations then
                     begin
                          WeightedSumirr.rtnValue(iCount,@WS);
                          write(DebugFile,',' +
                                          FloatToStr(WS.r_a) + ',' +
                                          FloatToStr(WS.r_t) + ',' +
                                          FloatToStr(WS.r_v) + ',' +
                                          FloatToStr(WS.r_at) + ',' +
                                          FloatToStr(WS.r_av) + ',' +
                                          FloatToStr(WS.r_tv) + ',' +
                                          FloatToStr(WS.r_atv));
                     end;
                     if ControlRes^.fCalculateBobsExtraVariations then
                     begin
                          MinsetSumirrWeightings.rtnValue(iCount,@MSW);
                          sLine := ',' +
                                          FloatToStr(MSW.rWcr) + ',' +
                                          FloatToStr(MSW.rWpt) + ',' +
                                          FloatToStr(MSW.rWcrWit) + ',' +
                                          FloatToStr(MSW.rWcrWvu) + ',' +
                                          FloatToStr(MSW.rWcrWitWvu) + ',' +
                                          FloatToStr(MSW.rWsa) + ',' +
                                          FloatToStr(MSW.rWsaWpa) + ',' +
                                          FloatToStr(MSW.rWsaWpt) + ',' +
                                          FloatToStr(MSW.rWpaWpt);
                          write(DebugFile,sLine);
                     end;
                     writeln(DebugFile);
                end;
                dispose(pSite);
                closefile(DebugFile);
           end;

     except
     end;
end;

procedure DumpSumirrWeightings(const sDir : string);
var
   DebugFile : TextFile;
   pSite : sitepointer;
   iCount : integer;
   WS : WeightedSumirr_T;
   MSW : MinsetSumirrWeightings_T;
   sLine : string;
begin
     try
        if ControlRes^.fCalculateAllVariations
        or ControlRes^.fCalculateBobsExtraVariations then
        begin
             ForceDirectories(sDir);

             assignfile(DebugFile,sDir + '\sumirr_weighting.csv');
             rewrite(DebugFile);
             // write header row to the file
             write(DebugFile,'SiteKey');
             if ControlRes^.fCalculateAllVariations then
                write(DebugFile,',SUM_PA,SUM_IT,SUM_VU,SUM_PAIT,SUM_PAVU,SUM_ITVU,SUM_PAITVU');
             if ControlRes^.fCalculateBobsExtraVariations then
                write(DebugFile,',SUM_CR,SUM_PT,SUM_CRIT,SUM_CRVU,SUM_CRITVU,SUM_SA,SUM_SAPA,SUM_SAPT,SUM_PAPT');
             writeln(DebugFile);
             new(pSite);
             for iCount := 1 to iSiteCount do
             begin
                  SiteArr.rtnValue(iCount,pSite);
                  write(DebugFile,IntToStr(pSite^.iKey));

                  if ControlRes^.fCalculateAllVariations then
                  begin
                       WeightedSumirr.rtnValue(iCount,@WS);
                       write(DebugFile,',' +
                                       FloatToStr(WS.r_a) + ',' +
                                       FloatToStr(WS.r_t) + ',' +
                                       FloatToStr(WS.r_v) + ',' +
                                       FloatToStr(WS.r_at) + ',' +
                                       FloatToStr(WS.r_av) + ',' +
                                       FloatToStr(WS.r_tv) + ',' +
                                       FloatToStr(WS.r_atv));
                  end;
                  if ControlRes^.fCalculateBobsExtraVariations then
                  begin
                       MinsetSumirrWeightings.rtnValue(iCount,@MSW);
                       sLine := ',' +
                                       FloatToStr(MSW.rWcr) + ',' +
                                       FloatToStr(MSW.rWpt) + ',' +
                                       FloatToStr(MSW.rWcrWit) + ',' +
                                       FloatToStr(MSW.rWcrWvu) + ',' +
                                       FloatToStr(MSW.rWcrWitWvu) + ',' +
                                       FloatToStr(MSW.rWsa) + ',' +
                                       FloatToStr(MSW.rWsaWpa) + ',' +
                                       FloatToStr(MSW.rWsaWpt) + ',' +
                                       FloatToStr(MSW.rWpaWpt);
                       write(DebugFile,sLine);
                  end;
                  writeln(DebugFile);
             end;
             dispose(pSite);
             closefile(DebugFile);
        end;

     except
     end;
end;

procedure CombineNormalValues(const Vuln : Array_t;
                              var InputValues : Array_t;
                              const SiteInputKeys : Array_t;
                              {const fDebug : boolean;}
                              var rHi,rLo : extended);
{Vuln is an array_t of extended values in order, 1 for each site
 InputValues in an array_t of trueFloatType, 1 for each available site

 Both arrays have been normalised to zero to one.

 Add values from Vuln to InputValues and return InputValues as the result}
var
   iCount, iSiteIndex, iSiteKey, iInput : integer;
   Value : trueFloatType;
   pSite : sitepointer;
   rValue, rSUMIRR{, rVulnerabilityWeighting} : extended;
   DebugFile, DumpFile : TextFile;
   fDebug, fDumpNormalisedValues : boolean;
begin
     try
        fDebug := fValidateIteration;
        if fDebug then
        begin
             assignfile(DebugFile,sIteration + '\CombineNormalValues.csv');
             rewrite(DebugFile);
             writeln(DebugFile,'SiteIndex,NormalisedX,NormalisedY,Destination');
        end;

        fDumpNormalisedValues := False;
        if fDumpNormalisedValues then
        begin
             assignfile(DumpFile,ControlRes^.sWorkingDirectory + '\DumpNormalValues.csv');
             rewrite(DumpFile);
             writeln(DumpFile,'SiteKey,SUMIRR,VULN,Normalised');
        end;
        
        rHi := 0;
        rLo := 100000;

        //rVulnerabilityWeighting := StrToFloat(MinsetExpertForm.EditVulnWeight.Text);

        iInput := 1;
        if fDebug then
           for iCount := 1 to iSiteCount do
           begin
                if (iInput <= InputValues.lMaxSize) then
                begin
                     InputValues.rtnValue(iInput,@Value);
                     // get the value for this site from Vuln
                     SiteInputKeys.rtnValue(Value.iIndex,@iSiteKey);
                     iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
                end
                else
                    iSiteIndex := 0;

                if (iSiteIndex = iCount) then
                begin
                     if fDebug then
                        write(DebugFile,IntToStr(iCount) + ',' +
                                        FloatToStr(Value.rValue) + ',');
                     Vuln.rtnValue(iSiteIndex,@rValue);

                     // apply the weighting for vulnerability
                     rValue := rValue * rVulnerabilityWeighting;

                     if (Value.rValue > 0) then
                        Value.rValue := Value.rValue + rValue;

                     InputValues.setValue(iInput,@Value);

                     if (Value.rValue > rHi) then
                        rHi := Value.rValue;

                     if (Value.rValue < rLo) then
                        rLo := Value.rValue;

                     if fDebug then
                        writeln(DebugFile,FloatToStr(rValue) + ',' +
                                          FloatToStr(Value.rValue));

                     Inc(iInput);
                end
                else
                begin
                     writeln(DebugFile,IntToStr(iCount) + ',0,0,0');
                end;
           end
        else
            for iCount := 1 to InputValues.lMaxSize do
            begin
                 InputValues.rtnValue(iCount,@Value);
                 rSUMIRR := Value.rValue;

                 // get the value for this site from Vuln
                 SiteInputKeys.rtnValue(Value.iIndex,@iSiteKey);
                 iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);

                 Vuln.rtnValue(iSiteIndex,@rValue);

                 // apply the weighting for vulnerability
                 rValue := rValue * rVulnerabilityWeighting;

                 Value.rValue := Value.rValue + rValue;

                 InputValues.setValue(iCount,@Value);

                 if (Value.rValue > rHi) then
                    rHi := Value.rValue;

                 if (Value.rValue < rLo) then
                    rLo := Value.rValue;

                 if fDumpNormalisedValues then
                 begin
                      writeln(DumpFile,IntToStr(iSiteKey) + ',' + FloatToStr(rSUMIRR) + ',' + FloatToStr(rValue) + ',' + FloatToStr(Value.rValue));
                 end;
            end;

        if fDebug then
           closefile(DebugFile);

        if fDumpNormalisedValues then
        begin
             closefile(DumpFile);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CombineNormalValues',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure StoreVuln(const Vuln : Array_t);
var
   iCount : integer;
   rValue : extended;
begin
     // store the calculated vuln values in the cache array
     for iCount := 1 to iSiteCount do
     begin
          Vuln.rtnValue(iCount,@rValue);
          CacheVuln.setValue(iCount,@rValue);
     end;
end;

procedure RecoverVuln(var Vuln : Array_t;
                      const SiteInputKeys : Array_t;
                      var rHi : extended);
var
   iCount, iInput, iKey : integer;
   rValue : extended;
   pSite : sitepointer;
begin
     //
     new(pSite);
     iInput := 1;
     SiteInputKeys.rtnValue(1,@iKey);
     rHi := 0;

     Vuln := Array_t.Create;
     Vuln.init(SizeOf(extended),iSiteCount);

     for iCount := 1 to iSiteCount do
     begin
          rValue := 0;
          SiteArr.rtnValue(iCount,pSite);
          if (pSite^.iKey = iKey) then
          begin
               CacheVuln.rtnValue(iCount,@rValue);
               Inc(iInput);
               if (iInput <= SiteInputKeys.lMaxSize) then
                  SiteInputKeys.rtnValue(iInput,@iKey);
          end;

          if (rValue > rHi) then
             rHi := rValue;

          Vuln.setValue(iCount,@rValue);
     end;

     dispose(pSite);
end;


procedure StoreIDVuln(const Vuln : Array_t;
                      const SiteInputKeys : Array_t);
var
   iCount, iKey, iSiteIndex : integer;
   Value : trueFloatType;
begin
     // store the calculated vuln values in the cache array
     for iCount := 1 to Vuln.lMaxSize do
     begin
          Vuln.rtnValue(iCount,@Value);
          SiteInputKeys.rtnValue(iCount,@iKey);
          iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);

          CacheVuln.setValue(iSiteIndex,@Value.rValue);
     end;
end;

function RecoverIDVuln(var Vuln : Array_t;
                       const SiteInputKeys : Array_t;
                       var rHi : extended) : integer;
var
   iCount, iInput, iKey : integer;
   rValue : extended;
   pSite : sitepointer;
   Value : trueFloatType;
   fCrown : boolean;
begin
     if ControlRes^.fReportMinsetMemSize then
        AddMemoryReportRow('RecoverIDVuln begin');
     //
     new(pSite);
     iInput := 1;
     SiteInputKeys.rtnValue(1,@iKey);

     Vuln := Array_t.Create;
     Vuln.init(SizeOf(Value),SiteInputKeys.lMaxSize);

     Result := 0;
     for iCount := 1 to iSiteCount do
     begin
          rValue := 0;
          SiteArr.rtnValue(iCount,pSite);
          if (pSite^.iKey = iKey) then
          begin
               CrownLandSites.rtnValue(iCount,@fCrown);
               if not fCrown then
                  Inc(Result);
               CacheVuln.rtnValue(iCount,@rValue);
               Vuln.setValue(iInput,@rValue);

               Inc(iInput);
               if (iInput <= SiteInputKeys.lMaxSize) then
                  SiteInputKeys.rtnValue(iInput,@iKey);
          end;
     end;

     dispose(pSite);

     if ControlRes^.fReportMinsetMemSize then
        AddMemoryReportRow('RecoverIDVuln end');
end;

procedure NormaliseMaxVuln(var InputValues : Array_t;
                           var rInputHi,rInputLo : extended;
                           const SiteInputKeys : Array_t;
                           const fDebug,fApplyComplementarity,fRecalculateComplementarity : boolean);
var
   MaxVuln : Array_t;
   rHi, rLo : extended;
   fRecalc : boolean;
begin
     try
        rLo := 100000;

        if fApplyComplementarity then
           GetMaxVuln(MaxVuln,SiteInputKeys,rHi{,fDebug},MinsetExpertForm.CheckEnableComplementarity.Checked)
        else
        begin
             if MinsetExpertForm.CheckEnableDestruction.Checked{ControlRes^.fDestructObjectsCreated} then
                fRecalc := fDestructionJustRun
             else
                 fRecalc := fRecalculateComplementarity;
                 
             if fRecalc{fRecalculateComplementarity} then
             begin
                  GetMaxVuln(MaxVuln,SiteInputKeys,rHi{,fDebug},MinsetExpertForm.CheckEnableComplementarity.Checked);
                  StoreVuln(MaxVuln);
             end
             else
             begin
                  RecoverVuln(MaxVuln,SiteInputKeys,rHi);
                  DebugMaxVuln(MaxVuln,fDebug)
             end;
        end;

        NormaliseValues(MaxVuln,SiteInputKeys,rHi,rLo,
                        0,
                        1{,
                        false});

        NormaliseIDValues(InputValues,SiteInputKeys,rInputHi,rInputLo,
                          0,
                          1{,
                          FALSE});

        CombineNormalValues(MaxVuln,InputValues,SiteInputKeys,
                            rInputHi,rInputLo);

        MaxVuln.Destroy;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in NormaliseMaxVuln',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure NormaliseWavVuln(var InputValues : Array_t;
                           var rInputHi,rInputLo : extended;
                           const SiteInputKeys : Array_t;
                           const fDebug,fApplyComplementarity,fRecalculateComplementarity : boolean);
var
   WavVuln : Array_t;
   rHi, rLo : extended;
   fRecalc : boolean;
begin
     try
        if fApplyComplementarity then
           GetWavVuln(WavVuln,SiteInputKeys,rHi{,fDebug},MinsetExpertForm.CheckEnableComplementarity.Checked)
        else
        begin
             if MinsetExpertForm.CheckEnableDestruction.Checked{ControlRes^.fDestructObjectsCreated} then
                fRecalc := fDestructionJustRun
             else
                 fRecalc := fRecalculateComplementarity;

             if fRecalc{fRecalculateComplementarity} then
             begin
                  GetWavVuln(WavVuln,SiteInputKeys,rHi{,fDebug},MinsetExpertForm.CheckEnableComplementarity.Checked);
                  StoreVuln(WavVuln);
             end
             else
             begin
                  RecoverVuln(WavVuln,SiteInputKeys,rHi);
                  DebugWavVuln(WavVuln,fDebug)
             end;
        end;

        rLo := 100000;
        //GetWavVuln(WavVuln,SiteInputKeys,rHi{,fDebug},MinsetExpertForm.CheckEnableComplementarity.Checked);
        // GetWavVuln was being called twice.  This was probably the cause of memory leak in this module
        // Matt 051100
        NormaliseValues(WavVuln,SiteInputKeys,rHi,rLo,
                        0,
                        1{,
                        false});

        NormaliseIDValues(InputValues,SiteInputKeys,rInputHi,rInputLo,
                          0,
                          1{,
                          FALSE});

        CombineNormalValues(WavVuln,InputValues,SiteInputKeys,
                            rInputHi,rInputLo);

        WavVuln.Destroy;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in NormaliseWavVuln',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure RestrictVuln({var} InputValues : Array_t;
                       const SiteInputKeys : Array_t;
                       {const }
                       var rHi, rLo : extended;
                       const fApplyComplementarity, fRecalculateComplementarity : boolean);
var
   IDMaxVuln, SortedIDMaxVuln, SiteFilter : Array_t;
   rXHi, rXLo, rVulnCutOff : extended;
   iPrivateSiteCount,
   iNumberOfSites, iCount, iReturnSites, iKey, iSiteIndex : integer;
   Value, Value2 : trueFloatType;
   ValidateFile : TextFile;
   fFilter : boolean;
   fDebug : boolean;
begin
     try
        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('RestrictVuln begin');
        // We need to write a vector indicating which values have been selected
        // according to Max Vuln.
        fDebug := fValidateIteration;
        if fDebug then
        begin
             // initialise the vector of sites filtered
             // 0 = site filtered out or not in original list
             // 1 = site filtered in
             SiteFilter := Array_t.Create;
             SiteFilter.init(SizeOf(boolean),iSiteCount);
             fFilter := False;
             for iCount := 1 to iSiteCount do
                 SiteFilter.setValue(iCount,@fFilter);

             assignfile(ValidateFile,sIteration + '\RestrictVulnValue.csv');
             rewrite(ValidateFile);
             writeln(ValidateFile,'SiteKey,Vuln');
        end;

        rXLo := 0;
        if fApplyComplementarity then
        begin
             if ControlRes^.fReportMinsetMemSize then
                AddMemoryReportRow('RestrictVuln before GetIDMaxVuln');

             iPrivateSiteCount := GetIDMaxVuln(IDMaxVuln,rXHi,SiteInputKeys{,fDebug},MinsetExpertForm.CheckEnableComplementarity.Checked);
        end
        else
        begin
             if fRecalculateComplementarity then
             begin
                  if ControlRes^.fReportMinsetMemSize then
                     AddMemoryReportRow('RestrictVuln before GetIDMaxVuln/StoreIDVuln');

                  iPrivateSiteCount := GetIDMaxVuln(IDMaxVuln,rXHi,SiteInputKeys{,fDebug},MinsetExpertForm.CheckEnableComplementarity.Checked);
                  StoreIDVuln(IDMaxVuln,SiteInputKeys);
             end
             else
             begin
                  if ControlRes^.fReportMinsetMemSize then
                     AddMemoryReportRow('RestrictVuln before RecoverIDVuln');

                  iPrivateSiteCount := RecoverIDVuln(IDMaxVuln,SiteInputKeys,rHi);
             end;
        end;

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('RestrictVuln before SortFloatArray');

        SortedIDMaxVuln := SortFloatArray(IDMaxVuln);

        if (iPrivateSiteCount > 0) then
           iNumberOfSites := Round(MinsetExpertForm.SpinVuln.Value / 100 * iPrivateSiteCount)
        else
            iNumberOfSites := Round(MinsetExpertForm.SpinVuln.Value / 100 * IDMaxVuln.lMaxSize);
        if (iNumberOfSites = 0) then
           iNumberOfSites := 1;

        SortedIDMaxVuln.rtnValue(iNumberOfSites,@Value);
        rVulnCutOff := Value.rValue;

        iReturnSites := 0;

        rHi := 0;
        rLo := 100000;

        // now that we have the cut-off, rewrite the InputValues
        // so we only use the sites whose vuln is above the cut-off
        for iCount := 1 to SiteInputKeys.lMaxSize do
        begin
             IDMaxVuln.rtnValue(iCount,@Value);
             if (Value.rValue >= rVulnCutOff) then
             begin
                  Inc(iReturnSites);
                  InputValues.rtnValue(iCount,@Value2);
                  InputValues.setValue(iReturnSites,@Value2);

                  if (Value2.rValue > rHi) then
                     rHi := Value2.rValue;

                  if (Value2.rValue < rLo) then
                     rLo := Value2.rValue;

                  if fDebug then
                  begin
                       SiteInputKeys.rtnValue(iCount,@iKey);
                       fFilter := True;
                       iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
                       SiteFilter.setValue(iSiteIndex,@fFilter);
                       writeln(ValidateFile,IntToStr(iKey) + ',' + FloatToStr(Value.rValue));
                  end;
             end;
        end;

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('RestrictVuln before InputValues.resize');

        if (iReturnSites < InputValues.lMaxSize) then
           InputValues.resize(iReturnSites);

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('RestrictVuln after InputValues.resize');

        if fDebug then
        begin
             closefile(ValidateFile);
             assignfile(ValidateFile,sIteration + '\RestrictVuln.csv');
             rewrite(ValidateFile);
             writeln(ValidateFile,'SiteIndex,Restrict');
             for iCount := 1 to iSiteCount do
             begin
                  SiteFilter.rtnValue(iCount,@fFilter);
                  if fFilter then
                     writeln(ValidateFile,IntToStr(iCount) + ',1' )
                  else
                      writeln(ValidateFile,IntToStr(iCount) + ',0' );
             end;
             closefile(ValidateFile);

             SiteFilter.destroy;
        end;

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('RestrictVuln before IDMaxVuln.Destroy');

        IDMaxVuln.Destroy;

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('RestrictVuln before SortedIDMaxVuln.Destroy');

        SortedIDMaxVuln.Destroy;

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('RestrictVuln end');

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RestrictVuln',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure DebugWavVuln(WavVuln : Array_t;
                       const fDebug : boolean);
var
   iCount : integer;
   ValidateFile : TextFile;
   rValue : extended;
begin
     if fValidateIteration then
     begin
          assignfile(ValidateFile,sIteration + '\GetWavVuln.csv');
          rewrite(ValidateFile);
          writeln(ValidateFile,'SiteIndex,Value');
          for iCount := 1 to iSiteCount do
          begin
               WavVuln.rtnValue(iCount,@rValue);
               writeln(ValidateFile,IntToStr(iCount) + ',' +
                                    FloatToStr(rValue));
          end;
          closefile(ValidateFile);
     end;
end;

procedure GetWavVuln(var WavVuln : Array_t;
                     const SiteInputKeys : Array_t;
                     var rHi : extended;
                     const {fDebug,} fComplementarityTarget : boolean);
var
   iCount, iTraverseFeatures, iInput, iInputKey : integer;
   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   rValue, rSumProduct, rSumCArea, rCArea, rTarget, rDestructArea : extended;
   ValidateFile : TextFile;
   fDebug,
   fCrownLand : boolean;
   Value : ValueFile_T;
begin
     try
        fDestructionJustRun := False;

        new(pSite);
        new(pFeature);

        WavVuln := Array_t.Create;
        WavVuln.init(SizeOf(rValue),iSiteCount);

        rHi := 0;

        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(ValidateFile,sIteration + '\GetWavVuln.csv');
             rewrite(ValidateFile);
             writeln(ValidateFile,'SiteIndex,Value');
        end;

        iInput := 1;
        SiteInputKeys.rtnValue(iInput,@iInputKey);
        for iCount := 1 to iSiteCount do
        begin
             CrownLandSites.rtnValue(iCount,@fCrownLand);
             SiteArr.rtnValue(iCount,pSite);
             if (pSite^.iKey = iInputKey) then
             begin
                  Inc(iInput);
                  if (iInput <= SiteInputKeys.lMaxSize) then
                     // fetch the next input key if there are any more
                     SiteInputKeys.rtnValue(iInput,@iInputKey);

                  // sum product is the sum of (contributing area * vuln) for each feature under target
                  rSumProduct := 0;
                  // sum Contributing Area is the sum of contributing area for each feature under target
                  rSumCArea := 0;
                  if (pSite^.richness > 0)
                  and (not fCrownLand) then
                      for iTraverseFeatures := 1 to pSite^.richness do
                      begin
                           FeatureAmount.rtnValue(pSite^.iOffset + iTraverseFeatures,@Value);
                           FeatArr.rtnValue(Value.iFeatKey,pFeature);

                           if fComplementarityTarget then
                              rTarget := pFeature^.targetarea
                           else
                           begin
                                rTarget := pFeature^.rInitialAvailableTarget;
                                if (iDestructionYear > -1) then
                                begin
                                     DestructArea.rtnValue(Value.iFeatKey,@rDestructArea);
                                     if (rTarget > (pFeature^.rInitialAvailable - rDestructArea)) then
                                        rTarget := pFeature^.rInitialAvailable - rDestructArea;
                                end;
                           end;

                           if (rTarget > 0)
                           and (Value.rAmount > 0) then
                           begin
                                if (Value.rAmount <= rTarget) then
                                   rCArea := Value.rAmount
                                else
                                    rCArea := rTarget;

                                rSumCArea := rSumCArea + rCArea;
                                rSumProduct := rSumProduct + (rCArea * pFeature^.rVulnerability);
                           end;
                      end;

                  if (rSumCArea > 0) then
                     rValue := rSumProduct / rSumCArea
                  else
                      rValue := 0;

                  if (rValue > rHi) then
                     rHi := rValue;
             end
             else
                 rValue := 0;

             if fDebug then
                writeln(ValidateFile,IntToStr(iCount) + ',' +
                                     FloatToStr(rValue));

             WavVuln.setValue(iCount,@rValue);
        end;

        if fDebug then
           closefile(ValidateFile);

        dispose(pSite);
        dispose(pFeature);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetWavVuln',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure DebugMaxVuln(MaxVuln : Array_t;
                       const fDebug : boolean);
var
   iCount : integer;
   ValidateFile : TextFile;
   rValue : extended;
begin
     if fValidateIteration then
     begin
          assignfile(ValidateFile,sIteration + '\GetMaxVuln.csv');
          rewrite(ValidateFile);
          writeln(ValidateFile,'SiteIndex,Value');
          for iCount := 1 to iSiteCount do
          begin
               MaxVuln.rtnValue(iCount,@rValue);
               writeln(ValidateFile,IntToStr(iCount) + ',' +
                                    FloatToStr(rValue));
          end;
          closefile(ValidateFile);
     end;
end;

procedure GetMaxVuln(var MaxVuln : Array_t;
                     const SiteInputKeys : Array_t;
                     var rHi : extended;
                     const {fDebug,} fComplementarityTarget : boolean);
var
   iCount, iTraverseFeatures, iInput, iInputKey : integer;
   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   rValue, rTarget, rDestructArea : extended;
   ValidateFile : TextFile;
   fDebug,
   fCrownLand : boolean;
   Value : ValueFile_T;
begin
     try
        new(pSite);
        new(pFeature);

        MaxVuln := Array_t.Create;
        MaxVuln.init(SizeOf(rValue),iSiteCount);

        rHi := 0;
        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(ValidateFile,sIteration + '\GetMaxVuln.csv');
             rewrite(ValidateFile);
             writeln(ValidateFile,'SiteIndex,Value');
        end;

        iInput := 1;
        SiteInputKeys.rtnValue(iInput,@iInputKey);
        for iCount := 1 to iSiteCount do
        begin
             rValue := 0;
             CrownLandSites.rtnValue(iCount,@fCrownLand);

             SiteArr.rtnValue(iCount,pSite);
             if (pSite^.iKey = iInputKey) then
             begin
                  Inc(iInput);
                  if (iInput <= SiteInputKeys.lMaxSize) then
                     // fetch the next input key if there are any more
                     SiteInputKeys.rtnValue(iInput,@iInputKey);

                  if (pSite^.richness > 0)
                  and (not fCrownLand) then
                      for iTraverseFeatures := 1 to pSite^.richness do
                      begin
                           FeatureAmount.rtnValue(pSite^.iOffset + iTraverseFeatures,@Value);
                           FeatArr.rtnValue(Value.iFeatKey,pFeature);

                           if fComplementarityTarget then
                              rTarget := pFeature^.targetarea
                           else
                           begin
                                rTarget := pFeature^.rInitialAvailableTarget;
                                if (iDestructionYear > -1) then
                                begin
                                     DestructArea.rtnValue(Value.iFeatKey,@rDestructArea);
                                     if (rTarget > (pFeature^.rInitialAvailable - rDestructArea)) then
                                        rTarget := pFeature^.rInitialAvailable - rDestructArea;
                                end;
                           end;

                           if (rTarget > 0)
                           and (Value.rAmount > 0) then
                               if (pFeature^.rVulnerability > rValue) then
                                  rValue := pFeature^.rVulnerability;
                      end;

                  if (rValue > rHi) then
                     rHi := rValue;
             end;

             if fDebug then
                writeln(ValidateFile,IntToStr(iCount) + ',' +
                                     FloatToStr(rValue));

             MaxVuln.setValue(iCount,@rValue);
        end;

        if fDebug then
           closefile(ValidateFile);

        dispose(pSite);
        dispose(pFeature);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetMaxVuln',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function GetIDMaxVuln(var IDMaxVuln : Array_t;
                      var rHi : extended;
                      const SiteInputKeys : Array_t;
                      const {fDebug,} fComplementarityTarget : boolean) : integer;
var
   iCount, iTraverseFeatures, iFeatureIndex, iIDMaxVulnCount,
   iInput, iInputKey : integer;
   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   rTarget, rDestructArea,
   rValue : extended;
   Value : trueFloatType;
   ValidateFile : TextFile;
   fDebug,
   fCrown : boolean;
   ValueElement : ValueFile_T;
begin
     try
        new(pSite);
        new(pFeature);

        IDMaxVuln := Array_t.Create;
        IDMaxVuln.init(SizeOf(Value),SiteInputKeys.lMaxSize);

        rHi := 0;

        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(ValidateFile,sIteration + '\GetIDMaxVuln.csv');
             rewrite(ValidateFile);
             writeln(ValidateFile,'SiteIndex,Value');
        end;

        Result := 0;
        iInput := 1;
        SiteInputKeys.rtnValue(iInput,@iInputKey);
        for iCount := 1 to iSiteCount do
        begin
             rValue := 0;
             CrownLandSites.rtnValue(iCount,@fCrown);

             SiteArr.rtnValue(iCount,pSite);
             if (pSite^.iKey = iInputKey) then
             begin
                  if (not fCrown)
                  and (pSite^.richness > 0) then
                  begin
                       Inc(Result);
                       for iTraverseFeatures := 1 to pSite^.richness do
                       begin
                            FeatureAmount.rtnValue(pSite^.iOffset + iTraverseFeatures,@ValueElement);
                            iFeatureIndex := ValueElement.iFeatKey;
                            FeatArr.rtnValue(iFeatureIndex,pFeature);

                            if fComplementarityTarget then
                               rTarget := pFeature^.targetarea
                            else
                            begin
                                 rTarget := pFeature^.rInitialAvailableTarget;
                                 if (iDestructionYear > -1) then
                                 begin
                                      DestructArea.rtnValue(ValueElement.iFeatKey,@rDestructArea);
                                      if (rTarget > (pFeature^.rInitialAvailable - rDestructArea)) then
                                         rTarget := pFeature^.rInitialAvailable - rDestructArea;
                                 end;
                            end;

                            if (rTarget > 0)
                            and (ValueElement.rAmount > 0) then
                                if (pFeature^.rVulnerability > rValue) then
                                   rValue := pFeature^.rVulnerability;
                       end;
                  end;

                  if (rValue > rHi) then
                     rHi := rValue;

                  Value.rValue := rValue;
                  Value.iIndex := iInput;

                  if fDebug then
                     writeln(ValidateFile,IntToStr(iCount) + ',' +
                                          FloatToStr(rValue));

                  IDMaxVuln.setValue(iInput,@Value);

                  Inc(iInput);
                  if (iInput <= SiteInputKeys.lMaxSize) then
                     // fetch the next input key if there are any more
                     SiteInputKeys.rtnValue(iInput,@iInputKey);
             end
             else
             begin
                  if fDebug then
                     writeln(ValidateFile,IntToStr(iCount) + ',0');
             end;
        end;

        if fDebug then
           closefile(ValidateFile);

        dispose(pSite);
        dispose(pFeature);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetIDMaxVuln',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure NormaliseIDValues(var Values : Array_t;
                            const SiteInputKeys : Array_t;
                            const rHi, rLo, rNormaliseLo, rNormaliseHi : extended{;
                            const fDebug : boolean});
{Input and Output : Values is an array_t of extended containing the values to normalise,
                    whose elements are of type trueFloatType

 Input : rHi is maximum value of input data,
         rLo is minimum value of input data
         rNormaliseLo is minimum value in the new range
         rNormaliseHi is the maximum value in the new range
 }
var
   fDebug : boolean;
   iCount, iInput, iKey, iIndex : integer;
   rValue, rDelta, rNormaliseDelta, rRatio : extended;
   Value : trueFloatType;
   ValidateFile : TextFile;
begin
     try
        if (rHi > 0) then
           rRatio := rNormaliseHi / rHi
        else
            rRatio := 1;

        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(ValidateFile,sIteration + '\NormaliseIDValues.csv');
             rewrite(ValidateFile);
             writeln(ValidateFile,'SiteIndex,Value at ratio ' + FloatToStr(rRatio));

             iInput := 1;
             for iCount := 1 to iSiteCount do
             begin
                  if (iInput <= Values.lMaxSize) then
                  begin
                       Values.rtnValue(iInput,@Value);
                       SiteInputKeys.rtnValue(Value.iIndex,@iKey);
                       iIndex := FindFeatMatch(OrdSiteArr,iKey);
                  end
                  else
                      iIndex := 0;

                  if (iIndex = iCount) then
                  begin
                       // adjust the value of this element
                       Value.rValue := Value.rValue * rRatio;

                       writeln(ValidateFile,IntToStr(iCount) + ',' +
                                            FloatToStr(Value.rValue));

                       Values.setValue(iInput,@Value);
                       Inc(iInput);
                  end
                  else
                      writeln(ValidateFile,IntToStr(iCount) + ',0');
             end;
             closefile(ValidateFile);
        end
        else
            for iCount := 1 to Values.lMaxSize do
            begin
                 Values.rtnValue(iCount,@Value);
                 // adjust the value of this element
                 Value.rValue := Value.rValue * rRatio;
                 Values.setValue(iCount,@Value);
            end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in NormaliseIDValues',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;



procedure NormaliseValues(var Values : Array_t;
                          const SiteInputKeys : Array_t;
                          const rHi, rLo, rNormaliseLo, rNormaliseHi : extended{;
                          const fDebug : boolean});
{Input and Output : Values is an array_t of extended containing the values to normalise.

 Input : rHi is maximum value of input data,
         rLo is minimum value of input data
         rNormaliseLo is minimum value in the new range
         rNormaliseHi is the maximum value in the new range
 }
var
   iCount, iInput, iKey, iIndex : integer;
   rValue, rDelta, rNormaliseDelta, rRatio : extended;
   ValidateFile : TextFile;
   fDebug : boolean;
begin
     try
        if (rHi > 0) then
           rRatio := rNormaliseHi / rHi
        else
            rRatio := 1;

        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(ValidateFile,{ControlRes^.sWorkingDirectory + '\' +} sIteration + '_NormaliseValues.csv');
             rewrite(ValidateFile);
             writeln(ValidateFile,'SiteIndex,Value at ratio ' + FloatToStr(rRatio));

             for iCount := 1 to Values.lMaxSize do
             begin
                  Values.rtnValue(iCount,@rValue);
                  // adjust the value of this element
                  rValue := rValue * rRatio;
                  Values.setValue(iCount,@rValue);

                  writeln(ValidateFile,IntToStr(iCount) + ',' +
                                            FloatToStr(rValue));
             end;
             (*iInput := 1;
             for iCount := 1 to iSiteCount do
             begin
                  if (iInput <= SiteInputKeys.lMaxSize) then
                  begin
                       SiteInputKeys.rtnValue(iInput,@iKey);
                       iIndex := FindFeatMatch(OrdSiteArr,iKey);
                  end
                  else
                      iIndex := 0;

                  if (iIndex > 0{iCount}) then
                  begin
                       // adjust the value of this element
                       Values.rtnValue(iInput,@rValue);
                       rValue := rValue * rRatio;

                       writeln(ValidateFile,IntToStr(iCount) + ',' +
                                            FloatToStr(rValue));

                       Values.setValue(iInput,@rValue);
                       Inc(iInput);
                  end
                  else
                      writeln(ValidateFile,IntToStr(iCount) + ',0');
             end;*)
             closefile(ValidateFile);
        end
        else
        for iCount := 1 to Values.lMaxSize do
        begin
             Values.rtnValue(iCount,@rValue);
             // adjust the value of this element
             rValue := rValue * rRatio;
             Values.setValue(iCount,@rValue);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in NormaliseValues',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function SitesWriteToFile(const sFilename : string;
                          SitesToFile : Array_t) : boolean;
var
   OutFile : Text;
   sLine : string;
   iValue, iSites : integer;
begin
     try
        Result := True;
        assignfile(OutFile,sFilename);
        rewrite(OutFile);

        for iSites := 1 to SitesToFile.lMaxSize do
        begin
             SitesToFile.rtnValue(iSites,@iValue);
             writeln(OutFile,IntToStr(iValue));
        end;

        closefile(OutFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in SitesWriteToFile',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function SitesReadFromFile(const sFilename : string;
                           SitesFromFile : Array_t) : boolean;
var
   InFile : Text;
   sLine : string;
   iValue, iSites : integer;
   fFail : boolean;
begin
     try
        Result := False;
        if FileExists(sFilename) then
        begin
             assignfile(InFile,sFilename);
             reset(InFile);

             iSites := 0;
             repeat
                   readln(InFile,sLine);

                   try
                      fFail := False;
                      iValue := StrToInt(sLine);

                   except
                         fFail := True;
                   end;

                   if not fFail then
                   begin
                        Inc(iSites);
                        if (iSites > SitesFromFile.lMaxSize) then
                           SitesFromFile.resize(SitesFromFile.lMaxSize + ARR_STEP_SIZE);
                        SitesFromFile.setValue(iSites,@iValue);
                   end;

             until EOF(InFile);

             if (iSites > 0) then
             begin
                  if (iSites <> SitesFromFile.lMaxSize) then
                     SitesFromFile.resize(iSites);
                  Result := True;
             end
             else
             begin
                  SitesFromFile.resize(1);
                  SitesFromFile.lMaxSize := 0;
             end;

             closefile(InFile);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in SitesReadFromFile',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure ProcessArcViewResult;
var
   AVRSearchArr, SCSearchArr, ArcViewResult : Array_t;
   iCount, iCount2, iKey, iChosen : integer;
   fAdd : boolean;
begin
     try
        try
           ArcViewResult := Array_t.create;
           ArcViewResult.init(SizeOf(integer),ARR_STEP_SIZE);
        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in ArcViewResult.init',mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;
        SitesReadFromFile(sSuspendOutputFile,ArcViewResult);


        (*
        {now select to ResultSites sites from AdjResult that are in SitesChosen}
        if (ArcViewResult.lMaxSize > 0) then
           for iCount := 1 to ArcViewResult.lMaxsize do
           begin
                {}
                ArcViewResult.rtnValue(iCount,@iKey);
                fAdd := False;
                for iCount2 := 1 to SuspendSitesChosen.lMaxsize do
                begin
                     SuspendSitesChosen.rtnValue(iCount2,@iChosen);
                     if (iKey = iChosen) then
                        fAdd := True;
                end;
                if fAdd then
                begin
                     Inc(iResultSites);
                     if (iResultSites > ResultSites.lMaxSize) then
                        ResultSites.resize(ResultSites.lMaxSize + ARR_STEP_SIZE);
                     ResultSites.setValue(iResultSites,@iAdj);
                end;
           end
        else
        begin
             {}
             ResultSites.resize(1);
             ResultSites.lMaxSize := 0;
             iResultSites := 0;
        end;
        *)
        ArcViewResult.Destroy;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ProcessArcViewResult',mtError,[mbOk],0);
     end;
end;

function IsSubsetField(const sField : string) : boolean;
var
   iCount : integer;
begin
     try
        Result := False;

        for iCount := 1 to 10 do
        begin
             if (sField = 'IRR' + IntToStr(iCount)) then
                Result := True;

             if (sField = 'SUM' + IntToStr(iCount)) then
                Result := True;

             if (iCount <= 5) then
             begin
                  if (sField = 'WAV' + IntToStr(iCount)) then
                     Result := True;
                  if (sField = 'PC' + IntToStr(iCount)) then
                     Result := True;
             end;
        end;

        {if ControlRes^.fCalculateAllVariations then
           if (sField[4] = '_') then
              Result := True;}
        {begin
             if (sField = 'SUM_A') then
                Result := True;
             if (sField = 'SUM_T') then
                Result := True;
             if (sField = 'SUM_V') then
                Result := True;
             if (sField = 'SUM_AT') then
                Result := True;
             if (sField = 'SUM_AV') then
                Result := True;
             if (sField = 'SUM_TV') then
                Result := True;
             if (sField = 'SUM_ATV') then
                Result := True;
        end;}

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in IsSubsetField',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function rtnSubsetValue(const sField : string;
                        pSite : sitepointer;
                        const iSiteIndex : integer) : extended;
var
   WS : WeightedSumirr_T;
begin
     try
        case sField[1] of
             'I' : Result := pSite^.rSubsetIrr[StrToInt(Copy(sField,4,Length(sField)-3))];
             'S' : {if ControlRes^.fCalculateAllVariations then
                   begin
                        WeightedSumirr.rtnValue(iSiteIndex,@WS);

                        if (sField = 'SUM_A') then
                           Result := WS.r_a;
                        if (sField = 'SUM_T') then
                           Result := WS.r_t;
                        if (sField = 'SUM_V') then
                           Result := WS.r_v;
                        if (sField = 'SUM_AT') then
                           Result := WS.r_at;
                        if (sField = 'SUM_AV') then
                           Result := WS.r_av;
                        if (sField = 'SUM_TV') then
                           Result := WS.r_tv;
                        if (sField = 'SUM_ATV') then
                           Result := WS.r_atv;
                   end
                   else}
                       Result := pSite^.rSubsetSum[StrToInt(Copy(sField,4,Length(sField)-3))];
             'W' : Result := pSite^.rSubsetWav[StrToInt(Copy(sField,4,Length(sField)-3))];
             'P' : Result := pSite^.rSubsetPCUsed[StrToInt(Copy(sField,3,Length(sField)-2))];
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in rtnSubsetValue',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function YesNo2Bool(const sYesNo : string) : boolean;
begin
     if (LowerCase(sYesNo) = 'yes') then
        Result := True
     else
         Result := False;
end;

procedure TRulesForm.LoadMinsetSpecification(const sFilename : string);
var
   SpecIni : TIniFile;
   sSection, sTemp : string;
   SpecFile : TextFile;
   iCount, iPos : integer;
   fStop : boolean;
begin
     // Load the minset specification from a file
     try
        SpecIni := TIniFile.Create(sFilename);

        sSection := 'Minset Specification';

        // Target setting
        if ControlForm.UseFeatCutOffs.Checked then
        begin
             sTemp := SpecIni.ReadString(sSection,'TargetField','ITARGET');
             MinsetExpertForm.TgtField.Text := sTemp;
             MinsetExpertForm.TgtField2.Text := sTemp;
        end
        else
        begin
             // using pctarget setting
             MinsetExpertForm.TgtField.Text := 'ITARGET';
             MinsetExpertForm.TgtField2.Text := 'ITARGET';
        end;

        sTemp := SpecIni.ReadString(sSection,'StartingCondition','use selected sites');
        if (sTemp <> 'use selected sites') then
        begin
             MinsetExpertForm.EditLogFile.Text := sTemp;
             MinsetExpertForm.Edit1.Text := sTemp;
             MinsetExpertForm.RadioStartingCondition.ItemIndex := 1;
             MinsetExpertForm.RadioGroup3.ItemIndex := 1;
        end;
        {end
        else
            MinsetExpertForm.RadioStartingCondition.ItemIndex := 0;}

        // WorkingDirectory
        ControlRes^.sWorkingDirectory := SpecIni.ReadString(sSection,'WorkingDirectory',ControlRes^.sWorkingDirectory);
        ForceDirectories(ControlRes^.sWorkingDirectory);
        // starting condition
        sTemp := SpecIni.ReadString(sSection,'StartingCondition','');
        if (sTemp = 'use selected sites') then
        begin
             // use selected sites
             MinsetExpertForm.EditLogFile.Text := '';
             MinsetExpertForm.Edit1.Text := '';
             MinsetExpertForm.RadioStartingCondition.ItemIndex := 0;
             MinsetExpertForm.RadioGroup3.ItemIndex := 0;
        end
        else
        if fileexists(sTemp) then
        begin
             // using a log file
             MinsetExpertForm.EditLogFile.Text := sTemp;
             MinsetExpertForm.Edit1.Text := sTemp;
             MinsetExpertForm.RadioStartingCondition.ItemIndex := 1;
             MinsetExpertForm.RadioGroup3.ItemIndex := 1;
        end
        else
        begin
             // use selected sites
             MinsetExpertForm.EditLogFile.Text := '';
             MinsetExpertForm.Edit1.Text := '';
             MinsetExpertForm.RadioStartingCondition.ItemIndex := 0;
             MinsetExpertForm.RadioGroup3.ItemIndex := 0;
        end;
        // StoppingCondition
        sTemp := SpecIni.ReadString(sSection,'StoppingCondition','');
        //All Feature Targets (in use) are Met.
        //One or More Subsets of Feature Targets (in use) are Met.

        if (sTemp = '')
        or (sTemp = 'All Features Satisfied')
        or (sTemp = 'All Feature Targets (in use) are Met.') then
           MinsetExpertForm.LoopGroup.ItemIndex := 0
        else
            if (sTemp = '1 or more Subsets of Features Satisfied')
            or (sTemp = 'One or More Subsets of Feature Targets (in use) are Met.') then
            begin
                 MinsetExpertForm.LoopGroup.ItemIndex := 1;
                 for iCount := 1 to 10 do
                     ClassesToTest[iCount] := SpecIni.ReadBool(sSection,'Subset' + IntToStr(iCount),False);
            end
            else
            begin
                 MinsetExpertForm.LoopGroup.ItemIndex := 2;
                 if (sTemp[1] = '1')
                 and (Length(sTemp) = 6) then
                     // 1 Site
                     MinsetExpertForm.SpinIter.Value := 1
                 else
                     // X Sites
                     MinsetExpertForm.SpinIter.Value := StrToInt(Copy(sTemp,1,Length(sTemp)-6));
            end;
        {
        sTemp = 'All Features Satisfied' OR
        '1 or more Subsets of Features Satisfied' OR
            'Subset1=True/False'
            ...
            'Subset1=True/False'
        '1 Site' OR
        'X Sites'
        }

        // SelectionsPerIteration
        MinsetExpertForm.SpinSelect.Value := SpecIni.ReadInteger(sSection,'SelectionsPerIteration',MinsetExpertForm.SpinSelect.Value);
        // ResourceLimit
        sTemp := SpecIni.ReadString(sSection,'ResourceLimit','None');
        if (sTemp = 'None') then
           MinsetExpertForm.CheckResourceLimit.Checked := False
        else
        begin
             MinsetExpertForm.CheckResourceLimit.Checked := True;
             iPos := Pos(' ',sTemp);
             MinsetExpertForm.ComboResource.Text := Copy(sTemp,1,iPos-1);
             MinsetExpertForm.SpinResource.Value := StrToInt(Copy(sTemp,iPos+1,Length(sTemp)-iPos-1));
        end;
        {
        sTemp = 'None'
        'FIELD X%'
        }

        // Report ProposedReserve
        if ('Yes' = SpecIni.ReadString(sSection,'ReportProposedReserve','')) then
           MinsetExpertForm.CheckProposedReserve.Checked := True
        else
            MinsetExpertForm.CheckProposedReserve.Checked := False;

        // Report hotspots features
        if ('Yes' = SpecIni.ReadString(sSection,'ReportHotspotsFeatures','')) then
           MinsetExpertForm.CheckHotspotsFeatures.Checked := True
        else
            MinsetExpertForm.CheckHotspotsFeatures.Checked := False;

        // ReportSites
        if ('Yes' = SpecIni.ReadString(sSection,'ReportSites','')) then
           MinsetExpertForm.CheckDebugSites.Checked := True
        else
            MinsetExpertForm.CheckDebugSites.Checked := False;
        // ReportFeatures
        if ('Yes' = SpecIni.ReadString(sSection,'ReportFeatures','')) then
           MinsetExpertForm.CheckDebugFeatures.Checked := True
        else
            MinsetExpertForm.CheckDebugFeatures.Checked := False;
        // ReportExtraDetail
        SpecIni.ReadString(sSection,'ReportExtraDetail','');
        if ('Yes' = SpecIni.ReadString(sSection,'ReportExtraDetail','')) then
           MinsetExpertForm.CheckExtraDetail.Checked := True
        else
            MinsetExpertForm.CheckExtraDetail.Checked := False;

        if ControlRes^.fShowExtraTools then
        begin
             // Vulnerability
             sTemp := SpecIni.ReadString(sSection,'Vulnerability','');
             if (sTemp = 'No') then
                MinsetExpertForm.CombineVuln.ItemIndex := 0
             else
             begin
                  if (sTemp = 'Normalise with Maximum') then
                     MinsetExpertForm.CombineVuln.ItemIndex := 1
                  else
                  begin
                       if (sTemp = 'Normalise with Weighted Average') then
                          MinsetExpertForm.CombineVuln.ItemIndex := 2
                       else
                       begin
                            MinsetExpertForm.CombineVuln.ItemIndex := 3;
                            // 'Restrict to Maximum 50%'
                            //  12345678901234567890123
                            MinsetExpertForm.SpinVuln.Value := StrToInt(Copy(sTemp,21,Length(sTemp)-21));
                       end;
                  end;
             end;
             MinsetExpertForm.EditVulnWeight.Text := SpecIni.ReadString(sSection,'VulnerabilityWeighting','1');
             // Destruction
             MinsetExpertForm.CheckEnableDestruction.Checked := ('Yes' = SpecIni.ReadString(sSection,'EnableDestruction',''));
             if MinsetExpertForm.CheckEnableDestruction.Checked then
             begin
                  if (SpecIni.ReadString(sSection,'Per Destruction','Selections') = 'Selections') then
                  begin
                       MinsetExpertForm.SpinSelectionsPerDestruction.Value := SpecIni.ReadInteger(sSection,'SelectionsPerDestruction',1);
                       MinsetExpertForm.RadioPerDestruction.ItemIndex := 0;
                  end
                  else
                  begin
                       MinsetExpertForm.EditAreaPerDestruction.Text := SpecIni.ReadString(sSection,'AreaPerDestruction','10000');
                       MinsetExpertForm.RadioPerDestruction.ItemIndex := 1;
                  end;
                  ControlRes^.sDESTRATEField := SpecIni.ReadString(sSection,'Destruction Rate',ControlRes^.sDESTRATEField);
                  MinsetExpertForm.EditYearsToSimulate.Text := SpecIni.ReadString(sSection,'Years To Simulate','0');       
             end;
             // Reallocate reserves between regions
             MinsetExpertForm.CheckReAllocate.Checked := ('Yes' = SpecIni.ReadString(sSection,'ReallocateReservesBetweenRegions',''));
             if MinsetExpertForm.CheckReAllocate.Checked then
             begin
                  MinsetExpertForm.ComboRegionField.Text := SpecIni.ReadString(sSection,'RegionField','');
                  MinsetExpertForm.EditRegionResRateTable.Text := SpecIni.ReadString(sSection,'RegionalReservationRatesTable','');
                  MinsetExpertForm.RadioReAllocLogic.ItemIndex := MinsetExpertForm.RadioReAllocLogic.Items.IndexOf(SpecIni.ReadString(sSection,'ReallocationLogic',''));
                  MinsetExpertForm.EditReAllocUnitSize.Text := SpecIni.ReadString(sSection,'ReallocationUnitSize','');
             end;
             // Complementarity
             MinsetExpertForm.CheckEnableComplementarity.Checked := ('Yes' = SpecIni.ReadString(sSection,'Complementarity','Yes'));
             // Redundancy
             sTemp := SpecIni.ReadString(sSection,'RedundancyCheck','No');
             if (sTemp = 'No') then
                MinsetExpertForm.RedundancySetting.ItemIndex := 0
             else
                 if (sTemp = 'Yes') then
                    MinsetExpertForm.RedundancySetting.ItemIndex := 1
                 else
                 begin
                      MinsetExpertForm.RedundancySetting.ItemIndex := 2;
                      MinsetExpertForm.RedundancyTiming.Value := StrToInt(Copy(sTemp,1,Length(sTemp)-11));
                 end;
             MinsetExpertForm.RedCheckOrder.Checked := YesNo2Bool(SpecIni.ReadString(sSection,'RedundancyCheckOrder','No'));
             MinsetExpertForm.RedCheckExclude.Checked := YesNo2Bool(SpecIni.ReadString(sSection,'RedundancyCheckExclude','No'));
             MinsetExpertForm.RedCheckEnd.Checked := YesNo2Bool(SpecIni.ReadString(sSection,'RedundancyCheckEnd','No'));

             // null simulation
             MinsetExpertForm.CheckNull.Checked := YesNo2Bool(SpecIni.ReadString(sSection,'NullSimulation','No'));
             ControlRes^.fNullHotspotsSimulation := MinsetExpertForm.CheckNull.Checked;
        end
        else
        begin
             // Vulnerability
             MinsetExpertForm.CombineVuln.ItemIndex := 0;
             // Destruction
             MinsetExpertForm.CheckEnableDestruction.Checked := False;
             // Complementarity
             MinsetExpertForm.CheckEnableComplementarity.Checked := False;
             // Redundancy
             MinsetExpertForm.RedundancySetting.ItemIndex := 0;
             MinsetExpertForm.RedCheckOrder.Checked := False;
             MinsetExpertForm.RedCheckExclude.Checked := False;
             MinsetExpertForm.RedCheckEnd.Checked := False;

             // Set properties for controls on TabbedNotebook2
             with MinsetExpertForm do
             begin
                  // stopping condition
                  RadioGroup1.ItemIndex := LoopGroup.ItemIndex;
                  // iterations
                  SpinEdit1.MaxValue := SpinIter.MaxValue;
                  SpinEdit1.Value := SpinIter.Value;
                  // selections per iteration
                  SpinEdit2.MaxValue := SpinSelect.MaxValue;
                  SpinEdit2.Value := SpinSelect.Value;
                  // sites to pass to next rule
                  RadioGroup2.ItemIndex := SitesBetweenRules.ItemIndex;
                  // resource limit
                  CheckBox1.Checked := CheckResourceLimit.Checked;
                  ComboBox1.Items := ComboResource.Items;
                  ComboBox1.Text := ComboResource.Text;
                  SpinEdit3.Value := SpinResource.Value;
                  // reports
                  CheckBox4.Checked := CheckDebugFeatures.Checked;
                  CheckBox2.Checked := CheckDebugSites.Checked;
             end;
        end;

        SpecIni.Free;

        // now read the [Rule List] section from the file
        assignfile(SpecFile,sFilename);
        reset(SpecFile);

        readln(SpecFile,sTemp);
        fStop := False;
        repeat
              readln(SpecFile,sTemp);

              fStop := (sTemp = '[Rule List]');

        until fStop;

        RuleBox.Items.Clear;
        fStop := False;
        repeat
              if Eof(SpecFile) then
                 fStop := True;
              readln(SpecFile,sTemp);

              if (sTemp <> '') then
                 RuleBox.Items.Add(sTemp);

        until fStop;

        closefile(SpecFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TRulesForm.LoadMinsetSpecification',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function Bool2YesNo(const fBool : boolean) : string;
begin
     if fBool then
        Result := 'Yes'
     else
         Result := 'No';
end;

procedure TRulesForm.SaveMinsetSpecification(const sFilename : string);
var
   SpecFile : TextFile;
   iCount : integer;
begin
     // Save the minset specification to a file
     try
        //assignfile(SpecFile,rtnUniqueFileName(ControlRes^.sWorkingDirectory + '\minset','mst'));
        assignfile(SpecFile,sFilename);
        rewrite(SpecFile);

        writeln(SpecFile,'[Minset Specification]');
        writeln(SpecFile,'Database=' + ControlRes^.sDatabase);
        writeln(SpecFile,'WorkingDirectory=' + ControlRes^.sWorkingDirectory);
        writeln(SpecFile,'Date=' + FormatDateTime('dddd," "mmmm d, yyyy',Now));
        writeln(SpecFile,'Time=' + FormatDateTime('hh:mm AM/PM', Now));

        if ControlForm.UseFeatCutOffs.Checked then
           writeln(SpecFile,'TargetField=',MinsetExpertForm.TgtField.Text);

        if (MinsetExpertForm.RadioStartingCondition.ItemIndex = 0) then
           writeln(SpecFile,'StartingCondition=use selected sites')
        else
            writeln(SpecFile,'StartingCondition=' + MinsetExpertForm.EditLogFile.Text);

        //All Feature Targets (in use) are Met.
        //One or More Subsets of Feature Targets (in use) are Met.
        if (MinsetExpertForm.LoopGroup.ItemIndex = 0) then
           writeln(SpecFile,'StoppingCondition=All Feature Targets (in use) are Met.')//All Features Satisfied')
        else
        begin
             if (MinsetExpertForm.LoopGroup.ItemIndex = 1) then
             begin
                  // one or more feature subsets
                  writeln(SpecFile,'StoppingCondition=One or More Subsets of Feature Targets (in use) are Met.');//1 or more Subsets of Features Satisfied');
                  for iCount := 1 to 10 do
                      if ClassesToTest[iCount] then
                         writeln(SpecFile,'Subset ' + IntToStr(iCount) + '=True')
                      else
                          writeln(SpecFile,'Subset ' + IntToStr(iCount) + '=False');
             end
             else
             begin
                  if (MinsetExpertForm.SpinIter.Value = 1) then
                     writeln(SpecFile,'StoppingCondition=1 Site')
                  else
                      writeln(SpecFile,'StoppingCondition=' + IntToStr(MinsetExpertForm.SpinIter.Value) + ' Sites');
             end;
        end;
        writeln(SpecFile,'SelectionsPerIteration=' + IntToStr(MinsetExpertForm.SpinSelect.Value));
        if MinsetExpertForm.CheckResourceLimit.Checked then
           writeln(SpecFile,'ResourceLimit=' + MinsetExpertForm.ComboResource.Text + ' ' + IntTostr(MinsetExpertForm.SpinResource.Value) + '%')
        else
            writeln(SpecFile,'ResourceLimit=None');

        if MinsetExpertForm.CheckDebugSites.Checked then
           writeln(SpecFile,'ReportSites=Yes')
        else
            writeln(SpecFile,'ReportSites=No');

        if MinsetExpertForm.CheckDebugFeatures.Checked then
           writeln(SpecFile,'ReportFeatures=Yes')
        else
            writeln(SpecFile,'ReportFeatures=No');

        if MinsetExpertForm.CheckProposedReserve.Checked then
           writeln(SpecFile,'ReportProposedReserve=Yes')
        else
            writeln(SpecFile,'ReportProposedReserve=No');

        if MinsetExpertForm.CheckHotspotsFeatures.Checked then
           writeln(SpecFile,'ReportHotspotsFeatures=Yes')
        else
            writeln(SpecFile,'ReportHotspotsFeatures=No');

        if MinsetExpertForm.CheckExtraDetail.Checked then
           writeln(SpecFile,'ReportExtraDetail=Yes');

        if fValidateIterationsCreated then
           writeln(SpecFile,'IterationsToValidateFile=' + sValidateIterationsFile);

        if ControlRes^.fShowExtraTools then
        begin
             // destruction
             if MinsetExpertForm.CheckEnableDestruction.Checked then
             begin
                  writeln(SpecFile,'EnableDestruction=Yes');
                  if (MinsetExpertForm.RadioPerDestruction.ItemIndex = 0) then
                  begin
                       writeln(SpecFile,'Per Destruction=','Selections');
                       writeln(SpecFile,'SelectionsPerDestruction=' + IntToStr(MinsetExpertForm.SpinSelectionsPerDestruction.Value));
                  end
                  else
                  begin
                       writeln(SpecFile,'Per Destruction=','Area');
                       writeln(SpecFile,'AreaPerDestruction=' + MinsetExpertForm.EditAreaPerDestruction.Text);
                  end;
                  writeln(SpecFile,'Destruction Rate=' + ControlRes^.sDESTRATEField);
                  writeln(SpecFile,'Years To Simulate=' + MinsetExpertForm.EditYearsToSimulate.Text);
             end
             else
                 writeln(SpecFile,'EnableDestruction=No');
             // Reallocate reserves between regions
             if MinsetExpertForm.CheckReAllocate.Checked then
             begin
                  writeln(SpecFile,'ReallocateReservesBetweenRegions=Yes');
                  writeln(SpecFile,'RegionField=' + MinsetExpertForm.ComboRegionField.Text);
                  writeln(SpecFile,'RegionalReservationRatesTable=' + MinsetExpertForm.EditRegionResRateTable.Text);
                  writeln(SpecFile,'ReallocationLogic=' + MinsetExpertForm.RadioReAllocLogic.Items.Strings[MinsetExpertForm.RadioReAllocLogic.ItemIndex]);
                  writeln(SpecFile,'ReallocationUnitSize=' + MinsetExpertForm.EditReAllocUnitSize.Text);
             end
             else
                 writeln(SpecFile,'ReallocateReservesBetweenRegions=No');
             // Complementarity
             if MinsetExpertForm.CheckEnableComplementarity.Checked then
                writeln(SpecFile,'Complementarity=Yes')
             else
                 writeln(SpecFile,'Complementarity=No');
             // vulnerability
             writeln(SpecFile,'Vulnerability=' +
                              MinsetExpertForm.CombineVuln.Items.Strings[MinsetExpertForm.CombineVuln.ItemIndex]);
             writeln(SpecFile,'VulnerabilityWeighting=' + MinsetExpertForm.EditVulnWeight.Text);
             // redundancy
             case MinsetExpertForm.RedundancySetting.ItemIndex of
                  0 : writeln(SpecFile,'RedundancyCheck=No');
                  1 : writeln(SpecFile,'RedundancyCheck=Yes');
                  2 : writeln(SpecFile,'RedundancyCheck=' +
                                       IntToStr(MinsetExpertForm.RedundancyTiming.Value) +
                                       ' Iterations');
             end;
             writeln(SpecFile,'RedundancyCheckOrder=' + Bool2YesNo(MinsetExpertForm.RedCheckOrder.Checked));
             writeln(SpecFile,'RedundancyCheckExclude=' + Bool2YesNo(MinsetExpertForm.RedCheckExclude.Checked));
             writeln(SpecFile,'RedundancyCheckEnd=' + Bool2YesNo(MinsetExpertForm.RedCheckEnd.Checked));

             // null simulation
             writeln(SpecFile,'NullSimulation=' + Bool2YesNo(ControlRes^.fNullHotspotsSimulation));
        end;

        writeln(SpecFile,'');

        writeln(SpecFile,'[Rule List]');
        for iCount := 0 to (RuleBox.Items.Count-1) do
            writeln(SpecFile,RuleBox.Items.Strings[iCount]);

        closefile(SpecFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TRulesForm.SaveMinsetSpecification',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function TRulesForm.rtnSelectedVariable : integer;
var
   iSCount : integer;
begin
     Result := -1;

     for iSCount := 0 to (VariableBox.Items.Count-1) do
         if VariableBox.Selected[iSCount]  then
            Result := iSCount;
end;

function TRulesForm.rtnSelectedSite : integer;
var
   iSCount : integer;
begin
     Result := -1;

     for iSCount := 0 to (RuleBox.Items.Count-1) do
         if RuleBox.Selected[iSCount]  then
            Result := iSCount;
end;

function SiteStatusOk(const sStatus : string) : boolean;
var
   sFlag : string;
begin
     Result := False;

     sFlag := '';

     case iMinsetFlag of
          MINSET_UNR1 : sFlag := 'R1';
          MINSET_UNR2 : sFlag := 'R2';
          MINSET_UNR3 : sFlag := 'R3';
          MINSET_UNR4 : sFlag := 'R4';
          MINSET_UNR5 : sFlag := 'N5';
          MINSET_UNPAR : sFlag := 'PR';
     end;

     if (sStatus = sFlag) then
        Result := True
     else
     if (sFlag = '') then {flag has not been found yet}
     begin
          case iMinsetFlag of
               MINSET_UNR1R2R3R4R5PD : if (sStatus = 'R1')
                                       or (sStatus = 'R2')
                                       or (sStatus = 'R3')
                                       or (sStatus = 'R4')
                                       or (sStatus = 'R5')
                                       or (sStatus = 'PR') then
                                          Result := True;
               MINSET_UNR1R2R3R4R5 : if (sStatus = 'R1')
                                    or (sStatus = 'R2')
                                    or (sStatus = 'R3')
                                    or (sStatus = 'R4')
                                    or (sStatus = 'R5') then
                                       Result := True;
               {MINSET_LOOKUP,
               MINSET_MAP,
               MINSET_ADD_TO_MAP : Result := True;}
          else
              if (sStatus = 'Av') then
                 Result := True;
          end;
     end;
end;

procedure TRulesForm.SortIntFields;
var
   OrigArr : Array_t;
begin
     SortBox.Items := ValueBox.Items;

     if ListBox2IntArr(SortBox,OrigArr) then
     begin
          SelectionSortIntArr(OrigArr);

          IntArr2ListBox(SortBox,OrigArr);
          OrigArr.destroy;

          ValueBox.Items := SortBox.Items;
          ValueBox.Text := ValueBox.Items[0];
     end;

     SortBox.Items.Clear;
end;

procedure TRulesForm.SortFloatFields;
var
   OrigArr : Array_t;
begin
     SortBox.Items := ValueBox.Items;

     if ListBox2FloatArr(SortBox,OrigArr) then
     begin
          SelectionSortFloatArr(OrigArr);

          FloatArr2ListBox(SortBox,OrigArr);
          OrigArr.destroy;

          ValueBox.Items := SortBox.Items;
          ValueBox.Text := ValueBox.Items[0];
     end;

     SortBox.Items.Clear;
end;

procedure TRulesForm.LoadValues(const sTheField : string);
{this procedure loads and sorts the appropriate field,
 loading min and max only for ints & reals if sort not
 specified}
var
   sTmp, sField : string;
   fUniqueSTR, fLoadAll, fEnd : boolean;
   rTmp, rMin, rMax, rValue : extended;
   iTmp, iMin, iMax, iSelectedVariable, iCount : integer;
   pSite : sitepointer;
begin
     Screen.Cursor := crHourglass;
     ValueBox.Clear;
     fLoadAll := checkSortValues.Checked;
     iMin := 0; iMax := 0; rMin := 0; rMax := 0;
     fEnd := False;

     fUniqueSTR := False;
     if (sField = 'NAME')
     or (sField = 'KEY') then
        fUniqueSTR := True;

     ValueBox.Sorted := False;

     iSelectedVariable := rtnSelectedVariable;
     if (iSelectedVariable < 5)
     or IsSubsetField(VariableBox.Items.Strings[iSelectedVariable]) then
     begin
          new(pSite);

          {we can scan SiteArr to find range of values}
          for iCount := 1 to iSiteCount do
          begin
               SiteArr.rtnValue(iCount,pSite);
               if SiteStatusOk(Status2Str(pSite^.status)) then
               begin
                    case iSelectedVariable of
                         0 : rValue := pSite^.rIrreplaceability;
                         1 : rValue := pSite^.rSummedIrr;
                         2 : rValue := pSite^.rWAVIRR;
                         3 : rValue := pSite^.rPCUSED;
                         4 : rValue := pSite^.area;
                    else
                        rValue := rtnSubsetValue(VariableBox.Items.Strings[iSelectedVariable],
                                                 pSite,iCount);
                    end;

                    if (rValue > rMax) then
                       rMax := rValue;

                    if (rValue < rMin) then
                       rMin := rValue;

                    if fLoadAll then
                       ValueBox.Items.Add(FloatToStr(rValue));
               end;

          end;

          if fLoadAll then
          begin
               Label2.Caption := 'Values';
               SortFloatFields;
          end
          else
          begin
               Label2.Caption := 'Max and Min';
               ValueBox.Items.Add(FloatToStr(rMax));
               ValueBox.Items.Add(FloatToStr(rMin));
               ValueBox.Text := FloatToStr(rMax);
          end;

          dispose(pSite);
     end
     else
     if (iSelectedVariable >= 8)
     and (iSelectedVariable <= 18) then
     begin
          {clicking on one of the new rules, Arithmetic and Spatial}
     end
     else
     try
        {we need to scan SSTable field to find range of values}

        case iSelectedVariable of
             5 : sField := 'I_IRREPL';
             6 : sField := 'I_SUMIRR';
             7 : sField := 'I_WAVIRR';
        else
            sField := sTheField;
        end;

        QueryTable.Open;
        while not fEnd do
        begin
             if SiteStatusOk(QueryTable.FieldByName(STATUS_DBLABEL).AsString) then
             case CurrentFieldType of
                  ftSmallInt, ftInteger :
                  begin
                       iTmp := QueryTable.FieldByName(sField).AsInteger;
                       if fLoadAll then
                          ValueBox.Items.Add(IntToStr(iTmp))
                       else
                       begin
                            {type is Integer and we are loading Max/Min values}

                            if (iTmp < iMin) then
                               iMin := iTmp
                            else
                                if (iTmp > iMax) then
                                   iMax := iTmp;
                       end;
                  end;
                  ftFloat :
                  begin
                       rTmp := QueryTable.FieldByName(sField).AsFloat;
                       sTmp := QueryTable.FieldByName(sField).AsString;

                       if fLoadAll then
                          ValueBox.Items.Add(sTmp)
                       else
                       begin
                            {type is Real and we are loading Max/Min values}

                            if (rTmp < rMin) then
                               rMin := rTmp
                            else
                                if (rTmp > rMax) then
                                   rMax := rTmp;
                       end;
                  end;
                  ftString :
                  begin
                       sTmp := QueryTable.FieldByName(sField).AsString;

                       if fUniqueSTR then
                          ValueBox.Items.Add(sTmp)
                       else
                           if (ValueBox.Items.IndexOf(sTmp) = -1) then
                              ValueBox.Items.Add(sTmp);
                  end;
             end;

             if QueryTable.EOF then
                fEnd := True;

             QueryTable.Next;
        end;

        {now if Real or Int we need to display min/max
                            OR sort and display all}

        case CurrentFieldType of
             ftSmallint, ftInteger :
                                begin
                                     if fLoadAll then
                                        SortIntFields
                                     else
                                     begin
                                          {add min and max to display}
                                          Label2.Caption := 'Max and Min';
                                          {Values.Items.Add('Max:');}
                                          ValueBox.Items.Add(IntToStr(iMax));
                                          {Values.Items.Add('Min:');}
                                          ValueBox.Items.Add(IntToStr(iMin));
                                          ValueBox.Text := IntToStr(iMax);
                                     end;
                                end;
             ftFloat :
                  begin
                       if fLoadAll then
                          SortFloatFields
                       else
                       begin
                            {add min and max to display}
                            Label2.Caption := 'Max and Min';
                            {Values.Items.Add('Max:');}
                            ValueBox.Items.Add(FloatToStr(rMax));
                            {Values.Items.Add('Min:');}
                            ValueBox.Items.Add(FloatToStr(rMin));
                            ValueBox.Text := FloatToStr(rMax);
                       end;
                  end;
             ftString : ValueBox.Text := ValueBox.Items.Strings[0];
        else
            MessageDlg('Unknown Sort Type',mtError,[mbOk],0);
        end;

        if fLoadAll
        and (CurrentFieldType = ftString) then
            ValueBox.Sorted := True;

     finally
            QueryTable.Close;

     end;
     Screen.Cursor := crDefault;
end;


procedure TRulesForm.OperatorGroupClick(Sender: TObject);
begin
     fClicking := True;
     VariableBoxClick(self);
end;

procedure UpdateRuleNumber(const iRowCount : integer;
                           var sRow : string);
var
   iDotPos : integer;
begin
     iDotPos := Pos('.',sRow);
     sRow := IntToStr(iRowCount) + Copy(sRow,iDotPos,Length(sRow)-iDotPos+1);
end;

procedure TRulesForm.btnDeleteClick(Sender: TObject);
var
   iCount, iRowCount : integer;
   sRow : string;
begin
     if (RuleBox.Items.Count > 1) then
        for iCount := 0 to (RuleBox.Items.Count-2) do
            if RuleBox.Selected[iCount] then
            begin
                 {delete line number iCount}
                 RuleBox.Items.Delete(iCount);
                 {update rule number in all the remaining rows}
                 for iRowCount := iCount to (RuleBox.Items.Count - 1) do
                 begin
                      sRow := RuleBox.Items.Strings[iRowCount];
                      UpdateRuleNumber(iRowCount+1,sRow);

                      RuleBox.Items.Delete(iRowCount);
                      RuleBox.Items.Insert(iRowCount,sRow);
                 end;
            end;
end;

procedure ExtractRule(const sRule : string;
                      var sType, sField, sOperator, sValue : string);
var
   iDotPos, iSpacePos, iSecondSpacePos : integer;
   sLine : string;
begin
     iDotPos := Pos('.',sRule);
     sLine := Copy(sRule,iDotPos+2,Length(sRule)-iDotPos-1);

     sField := '';
     sOperator := '';
     sValue := '';

     iSpacePos := Pos(' ',sLine);
     if (iSpacePos > 0) then
     begin
          sType := Copy(sLine,1,iSpacePos-1);
          sLine := Copy(sLine,iSpacePos+1,Length(sLine)-iSpacePos);
          iSpacePos := Pos(' ',sLine);
          if (iSpacePos > 0) then
          begin
               sField := Copy(sLine,1,iSpacePos-1);
               sLine := Copy(sLine,iSpacePos+1,Length(sLine)-iSpacePos);
               iSecondSpacePos := Pos(' ',sLine);
               if (iSecondSpacePos > 0) then
               begin {there is a value}
                    sOperator := Copy(sLine,1,iSecondSpacePos-1);
                    sValue := Copy(sLine,iSecondSpacePos+1,Length(sLine)-iSecondSpacePos);
               end
               else
               begin {there is no value}
                    sValue := '';
                    sOperator := sLine;
               end;
          end
          else
              sField := sLine;
     end
     else
         sType := sLine;
end;

procedure TRulesForm.btnEditClick(Sender: TObject);
var
   sType, sRule, sField, sOperator, sValue : string;
   iCount, iDotPos, iVarCount : integer;
   fFinished : boolean;

   function IsAdjProxArithmeticRules(const sType, sField : string): boolean;
   var
      iBase : integer;
   begin
        Result := False;

        {if (sType = 'Adjacency') then
        begin
             Result := True;
             EditRuleForm.VariableBox.ItemIndex := 8;
        end
        else
        if (sType = 'Proximity') then
        begin
             Result := True;
             EditRuleForm.VariableBox.ItemIndex := 9;
        end
        else}
        {
        richness
        features met
        feature rarity
        summed rarity
        contrib
        pccontrib
        rarcontrib
        weighted contrib
        weighted propcontrib
        weighted pccontrib
        weighted %target
        }

        iBase := 8;
        if (sType = 'richness') then
        begin
             Result := True;
             EditRuleForm.VariableBox.ItemIndex := iBase;
        end
        else
        if (sType = 'features') then
        begin
             Result := True;
             EditRuleForm.VariableBox.ItemIndex := iBase + 1;
        end
        else
        if (sType = 'feature') then
        begin
             Result := True;
             EditRuleForm.VariableBox.ItemIndex := iBase + 2;
        end
        else
        if (sType = 'summed') then
        begin
             Result := True;
             EditRuleForm.VariableBox.ItemIndex := iBase + 3;
        end
        else
        if (sType = 'contrib') then
        begin
             Result := True;
             EditRuleForm.VariableBox.ItemIndex := iBase + 4;
        end
        else
        if (sType = 'pccontrib') then
        begin
             Result := True;
             EditRuleForm.VariableBox.ItemIndex := iBase + 5;
        end
        else
        if (sType = 'rarcontrib') then
        begin
             Result := True;
             EditRuleForm.VariableBox.ItemIndex := iBase + 6;
        end
        else
        if (sType = 'weighted') then
        begin
             Result := True;
             if (sField = 'contrib') then
                EditRuleForm.VariableBox.ItemIndex := iBase + 7
             else
                 if (sField = 'propcontrib') then
                    EditRuleForm.VariableBox.ItemIndex := iBase + 8
                 else
                     EditRuleForm.VariableBox.ItemIndex := iBase + 9;
        end;
   end;
begin
     if (RuleBox.Items.Count > 1) then
        for iCount := 0 to (RuleBox.Items.Count-2) do
            if RuleBox.Selected[iCount] then
            begin
                 try
                    EditRuleForm := TEditRuleForm.Create(Application);

                    {update Variable, Operator and Value}
                    with EditRuleForm do
                    begin
                         sRule := RuleBox.Items.Strings[iCount];

                         ExtractRule(sRule,sType,sField,sOperator,sValue);

                         if IsAdjProxArithmeticRules(sType,sField) then
                         begin
                              EditRuleForm.OperatorGroup.Visible := False;
                              EditRuleForm.CheckLoadValues.Visible := False;
                              EditRuleForm.CheckSortValues.Visible := False;
                              EditRuleForm.Label2.Visible := False;
                              EditRuleForm.ValueBox.Visible := False;

                              if (EditRuleForm.VariableBox.ItemIndex = 9) then
                              begin
                                   EditRuleForm.Caption := 'Enter Proximity Distance';
                                   EditRuleForm.Label3.Visible := True;
                                   EditRuleForm.SpinDistance.Value := StrToInt(sField);
                                   EditRuleForm.SpinDistance.Visible := True;
                              end;
                         end
                         else
                         begin
                              EditRuleForm.OperatorGroup.Visible := True;
                              EditRuleForm.CheckLoadValues.Visible := True;
                              EditRuleForm.CheckSortValues.Visible := True;
                              EditRuleForm.Label2.Visible := True;
                              EditRuleForm.ValueBox.Visible := True;
                              EditRuleForm.Label3.Visible := False;
                              EditRuleForm.SpinDistance.Visible := False;

                              OperatorGroup.ItemIndex := OperatorGroup.Items.IndexOf(sOperator);
                              if (OperatorGroup.ItemIndex > 1) then
                                 ValueBox.Text := sValue;

                              {sField is Variable that has been selected}
                              if (sField = 'IRREPL') then
                                 VariableBox.ItemIndex := 0
                              else
                                  if (sField = 'SUMIRR') then
                                     VariableBox.ItemIndex := 1
                                  else
                                      if (sField = 'WAVIRR') then
                                         VariableBox.ItemIndex := 2
                                      else
                                          if (sField = 'PCCONTR') then
                                             VariableBox.ItemIndex := 3
                                          else
                                              if (sField = 'AREA') then
                                                 VariableBox.ItemIndex := 4
                                              else
                                                  if (sField = 'I_IRREPL') then
                                                     VariableBox.ItemIndex := 5
                                                  else
                                                      if (sField = 'I_SUMIRR') then
                                                         VariableBox.ItemIndex := 6
                                                      else
                                                          if (sField = 'I_WAVIRR') then
                                                             VariableBox.ItemIndex := 7
                                                          else
                                                              {highlight element which is same as sField}
                                                              VariableBox.ItemIndex := VariableBox.Items.IndexOf(sField);

                              {sType not used at present as only one allowed is select}
                         end;

                         {display the edit form}
                         if (ShowModal = mrOk) then
                         begin
                              {update this rule}
                              iDotPos := Pos('.',sRule);
                              sRule := Copy(sRule,1,iDotPos) + ' Select ';

                              fFinished := False;
                              {determine field}
                              for iVarCount := 0 to (EditRuleForm.VariableBox.Items.Count-1) do
                                  if EditRuleForm.VariableBox.Selected[iVarCount] then
                                  begin
                                       case iVarCount of
                                            0 : sField := 'IRREPL';
                                            1 : sField := 'SUMIRR';
                                            2 : sField := 'WAVIRR';
                                            3 : sField := 'PCCONTR';
                                            4 : sField := 'AREA';
                                            5 : sField := 'I_IRREPL';
                                            6 : sField := 'I_SUMIRR';
                                            7 : sField := 'I_WAVIRR';
                                            8,9,10,11,12,13,14,15,16,17,18 :
                                            begin
                                                 sField := EditRuleForm.VariableBox.Items.Strings[iVarCount];

                                                 sRule := '1. ' + sField;
                                                 if (iVarCount = 9) then
                                                    sRule := sRule + ' ' + IntToStr(EditRuleForm.SpinDistance.Value);
                                                 fFinished := True;
                                            end;
                                       else
                                           sField := EditRuleForm.VariableBox.Items.Strings[iVarCount];
                                       end
                                  end;

                              if (not fFinished) then
                              begin
                                   {determine operator}
                                   sOperator := OperatorGroup.Items.Strings[OperatorGroup.ItemIndex];

                                   sValue := ValueBox.text;

                                   sRule := '1. Select ' + sField + ' ' + sOperator;

                                   if (OperatorGroup.ItemIndex > 1) then
                                      sRule := sRule + ' ' + sValue;
                              end;

                              {now replace existing rule in the rule list with sRule}
                              UpdateRuleNumber(iCount+1,sRule);
                              RuleBox.Items.Delete(iCount);
                              RuleBox.Items.Insert(iCount,sRule);
                              RuleBox.ItemIndex := iCount;
                         end;
                    end;

                 finally
                        EditRuleForm.Free;
                 end;
            end;
end;

function IsResourceLimitExceeded(const iBestCount : integer;
                                 const BestArray : Array_t;
                                 const iPercentWeCanDeferr : integer) : boolean;
var
   iKey, iCount, iResCount : integer;
   ResElement : ResourceElement_t;
   rProposedDeferred,
   rAmountWeCanDeferr : extended;
begin
     {determines whether rDeferred with the addition of the
      resource (stored in ResArray) contained by the sites
      in BestArray will exceed the limit which has been set}
     rProposedDeferred := 0;
     rAmountWeCanDeferr := rTotalResource * iPercentWeCanDeferr / 100;

     for iResCount := 1 to iResArrCount do
     begin
          ResArray.rtnValue(iResCount,@ResElement);

          for iCount := 1 to iBestCount do
          begin
               BestArray.rtnValue(iCount,@iKey);

               if (iKey = ResElement.iKey) then
                  rProposedDeferred := rProposedDeferred + ResElement.rResource;
          end;
     end;

     if ((rProposedDeferred + rDeferred) > rAmountWeCanDeferr) then
        Result := True
     else
     begin
          Result := False;
          rDeferred := rDeferred + rProposedDeferred;
     end;
end;

procedure LoadResourceArray(const sField : string);
var
   sStatus : string;
   rValue : extended;
   fEndResourceTable : boolean;
   AResElement : ResourceElement_T;
begin
     {we are using a resource limit and we must calculate
      how much of the selected resource is already deferred
      and load Resource for available sites into an array
      so that we can keep a cumulative total during deferral
      of sites}
     rTotalResource := 0;
     rDeferred := 0;
     rPartDeferred := 0;
     fEndResourceTable := False;
     iResArrCount := 0;

     ControlForm.OutTable.Open;

     repeat
           try
              rValue := ControlForm.OutTable.FieldByName(sField).AsFloat;
           except
                 rValue := 0;
           end;

           sStatus := ControlForm.OutTable.FieldByName(STATUS_DBLABEL).AsString;

           if (sStatus <> 'IE')
           and (sStatus <> 'IR') then
               rTotalResource := rTotalResource + rValue;

           if (sStatus = 'NR')
           or (sStatus = 'MR') then
              rDeferred := rDeferred + rValue;

           if SiteStatusOk(sStatus) then
           begin
                if (sStatus = 'PR') then
                   rPartDeferred := rPartDeferred + rValue
                else
                    if (sStatus = 'Av')
                    or (sStatus = 'Fl') then
                    begin
                         {add this site Key and Resource value
                          to the array}
                          AResElement.iKey := ControlForm.OutTable.FieldByName(ControlRes^.sKeyField).AsInteger;
                          AResElement.rResource := rValue;

                          Inc(iResArrCount);

                          if (iResArrCount = 1) then
                          begin
                               try
                                  ResArray := Array_t.Create;
                                  ResArray.init(SizeOf(ResourceElement_T),ARR_STEP_SIZE);
                               except
                                     Screen.Cursor := crDefault;
                                     MessageDlg('Exception in ResArray.init',mtError,[mbOk],0);
                                     Application.Terminate;
                                     Exit;
                               end;
                          end;

                          if (iResArrCount > ResArray.lMaxSize) then
                             ResArray.resize(ResArray.lMaxSize + ARR_STEP_SIZE);

                          ResArray.SetValue(iResArrCount,@AResElement);
                    end;
           end;

           if ControlForm.OutTable.EOF then
              fEndResourceTable := True;

           ControlForm.OutTable.Next;

     until fEndResourceTable;

     if (iResArrCount > 0) then
        if (ResArray.lMaxSize <> iResArrCount) then
           ResArray.Resize(iResArrCount);

end; {end of LoadResourceArray}

procedure InitSelectionLog;
begin
     assignfile(SelectLog,ControlRes^.sWorkingDirectory + '\SelectionLog.csv');
     rewrite(SelectLog);
     writeln(SelectLog,'Sites Selected,Vegetated Area,Features Satisfied');
end;

procedure AppendSelectionLog(sLine : string);
begin
     writeln(SelectLog,sLine);
end;

procedure CloseSelectionLog;
begin
     closefile(SelectLog);
end;

function StoppingConditionReached(const iIterationCount : integer;
                                  const fStop : boolean;
                                  const iSitesSelected : integer;
                                  const fDebug : boolean) : boolean;
var
   iFeaturesSatisfied : integer;
begin
     try
        // test MinsetExpertForm.CheckDebugMode.Checked
        // and write to SelectionLog.csv
        AppendDebugLog('StoppingConditionReached start');
        
        iFeaturesSatisfied := -1;

        case MinsetExpertForm.LoopGroup.ItemIndex of
             0 : {test to see if All Features Satisfied}
             begin
                  Result := AreFeaturesSatisfied(iFeaturesSatisfied,False,ClassesToTest);
                  if Result then
                     if not fStop then
                     begin
                          sWhatStoppedMinset := 'All features satisfied';
                          ControlForm.SaveSparseMatrixBinary(ControlRes^.sWorkingDirectory + '\end.key',ControlRes^.sWorkingDirectory + '\end.mtx');
                     end;
             end;
             1 : {1 or more subsets of features satisfied}
             begin
                  Result := AreFeaturesSatisfied(iFeaturesSatisfied,True,ClassesToTest);
                  if Result then
                     if not fStop then
                        sWhatStoppedMinset := '1 or more subsets of features satisfied';
             end;
             2 :
             begin
                  {test to see if Iteration Count exceeded}
                  if (iIterationCount >= MinsetExpertForm.SpinIter.Value) then
                  begin
                       Result := True;
                       if not fStop then
                          sWhatStoppedMinset := 'Iteration count met';
                  end
                  else
                      Result := False;

                  {if Iteration Count not exceeded, test to see if features are satisfied}
                  if (not Result) then
                  begin
                       Result := AreFeaturesSatisfied(iFeaturesSatisfied,False,ClassesToTest);
                       if Result then
                          if not fStop then
                             sWhatStoppedMinset := 'All features satisfied';
                  end;
             end;
        end;

        // stop after 20 years
        if MinsetExpertForm.CheckEnableDestruction.Checked and (not Result) then
        begin
             if (ControlRes^.iSimulationYear >= StrToInt(MinsetExpertForm.EditYearsToSimulate.Text)) then
             begin
                  Result := True;
                  if not fStop then
                  begin
                       sWhatStoppedMinset := MinsetExpertForm.EditYearsToSimulate.Text + ' years reached';

                       DumpRetention(0);
                       DumpStatusVector(0);
                       DumpRetention(ControlRes^.iSimulationYear);
                       DumpStatusVector(ControlRes^.iSimulationYear);
                       ControlForm.SaveSparseMatrixBinary(ControlRes^.sWorkingDirectory + '\year' + MinsetExpertForm.EditYearsToSimulate.Text + '.key',
                                                          ControlRes^.sWorkingDirectory + '\year' + MinsetExpertForm.EditYearsToSimulate.Text + '.mtx');
                       ReportFeatures(ControlRes^.sWorkingDirectory + '\sample' + MinsetExpertForm.EditYearsToSimulate.Text + '_features.csv',
                                      'finished ' + MinsetExpertForm.EditYearsToSimulate.Text + ' years',
                                      FALSE,
                                      ControlForm.UseFeatCutOffs.Checked,
                                      FeatArr,
                                      iFeatureCount,
                                      rPercentage,
                                      '');
                       //StartDestructReports;
                       //AppendDestructReports;
                  end;
             end
             else
                 //if (DestructArea <> nil) then
                 begin
                 //     DumpRetention(ControlRes^.iSimulationYear);
                 //     DumpStatusVector(ControlRes^.iSimulationYear);
                 end;
        end;

        if (not Result) then
           Result := fStop;

        if Result
        and (TotalDestructArea <> nil) then
           EndDestructAreaFile;

        if fDebug then
        begin
             if (iFeaturesSatisfied = -1) then
                // find how many features are satisfied
                AreFeaturesSatisfied(iFeaturesSatisfied,False,ClassesToTest);

             // write to the selection log debug file
             AppendSelectionLog(
                                IntToStr(iSitesSelected) + ',' +
                                FloatToStr(rTotalVegetatedArea) + ',' +
                                IntToStr(iFeaturesSatisfied)
                               );
        end;

        AppendDebugLog('StoppingConditionReached end');

     except
          MessageDlg('Exception in StoppingConditionReached',mtError,[mbOk],0); 
     end;
end;

procedure TRulesForm.RuleBoxClick(Sender: TObject);
var
   iCount,iSel : integer;
   fOn : boolean;
begin
     fOn := False;

     if (RuleBox.Items.Count > 1) then
        for iCount := 0 to (RuleBox.Items.Count-2) do
            if RuleBox.Selected[iCount] then
            begin
                 fOn := True;
                 {enable buttons}
                 iSel := iCount;
            end;

     btnEdit.Enabled := fOn;
     btnDelete.Enabled := fOn;
     UpDown1.Enabled := fOn;
     if fOn then
     begin
          UpDown1.Min := -30000;
          UpDown1.Max := +30000;
          UpDown1.Increment := 1;
     end;
end;

procedure TRulesForm.UpDown1Click(Sender: TObject; Button: TUDBtnType);
var
   iCount, iSelectedSite : integer;
   sLine : string;

begin
     if (RuleBox.Items.Count > 2) then
        case Button of
             btNext :
             begin
                  {up}

                  {move selected rule up if not last or first element}
                  iSelectedSite := rtnSelectedSite;
                  if (iSelectedSite > 0)
                  and (iSelectedSite < (RuleBox.Items.Count-1)) then
                  begin
                       RuleBox.Items.Exchange(iSelectedSite,iSelectedSite-1);

                       sLine := RuleBox.Items.Strings[iSelectedSite];
                       UpdateRuleNumber(iSelectedSite+1,sLine);
                       RuleBox.Items.Delete(iSelectedSite);
                       RuleBox.Items.Insert(iSelectedSite,sLine);

                       sLine := RuleBox.Items.Strings[iSelectedSite-1];
                       UpdateRuleNumber(iSelectedSite,sLine);
                       RuleBox.Items.Delete(iSelectedSite-1);
                       RuleBox.Items.Insert(iSelectedSite-1,sLine);

                       {swap the elements then change number for each in turn}
                  end;

                  RuleBox.ItemIndex := iSelectedSite-1;
                  {RuleBox.Selected[iSelectedSite-1] := True;}
                  {reselect the site which has just been moved}
             end;
             btPrev :
             begin
                  {down}

                  {move selected rule down if not last or second last element}
                  iSelectedSite := rtnSelectedSite;
                  if (iSelectedSite >= 0)
                  and (iSelectedSite < (RuleBox.Items.Count-2))then
                  begin
                       RuleBox.Items.Exchange(iSelectedSite,iSelectedSite+1);

                       sLine := RuleBox.Items.Strings[iSelectedSite];
                       UpdateRuleNumber(iSelectedSite+1,sLine);
                       RuleBox.Items.Delete(iSelectedSite);
                       RuleBox.Items.Insert(iSelectedSite,sLine);

                       sLine := RuleBox.Items.Strings[iSelectedSite+1];
                       UpdateRuleNumber(iSelectedSite+2,sLine);
                       RuleBox.Items.Delete(iSelectedSite+1);
                       RuleBox.Items.Insert(iSelectedSite+1,sLine);

                       RuleBox.ItemIndex := iSelectedSite+1;
                       {swap the elements then change number for each in turn}
                  end;

                  {reselect the site which has just been moved}
             end;
        end;
end;

procedure TRulesForm.Button4Click(Sender: TObject);
begin
     if (OpenRules.InitialDir = '') then
     begin
          OpenRules.InitialDir := ControlRes^.sWorkingDirectory;
     end
     else
     begin
          OpenRules.InitialDir := ExtractFilePath(OpenRules.Filename);
     end;

     if OpenRules.Execute then
        LoadMinsetSpecification(OpenRules.Filename);
end;

procedure TRulesForm.Button2Click(Sender: TObject);
begin
     //SaveRules.Create(Application);

     if (SaveRules.InitialDir = '') then
     begin
          SaveRules.InitialDir := ControlRes^.sWorkingDirectory;
          //SaveRules.Filename := 'sample.mst';
     end
     else
     begin
          SaveRules.InitialDir := ExtractFilePath(SaveRules.Filename);
          //SaveRules.Filename := ExtractFileName(SaveRules.Filename);
     end;

     if SaveRules.Execute then
        SaveMinsetSpecification(SaveRules.Filename);

     //SaveRules.Destroy;
end;

procedure TRulesForm.Button1Click(Sender: TObject);
var
   sRule : string;
   iCount, iUpperBound : integer;
   fAdjProxIncluded, fFinished : boolean;
begin
     // add a rule to the Minset

     fFinished := False;
     fAdjProxIncluded := False;
     //if (ControlRes^.GISLink = ArcView) then
     //   fAdjProxIncluded := True;
     for iCount := 0 to (VariableBox.Items.Count-1) do
         if VariableBox.Selected[iCount] then
         case iCount of
              0 : sRule := 'IRREPL';
              1 : sRule := 'SUMIRR';
              2 : sRule := 'WAVIRR';
              3 : sRule := 'PCCONTR';
              4 : sRule := 'AREA';
              5 : sRule := 'I_IRREPL';
              6 : sRule := 'I_SUMIRR';
              7 : sRule := 'I_WAVIRR';
              8,9,10,11,12,13,14,15,16,17,18 :
              begin
                   sRule := VariableBox.Items.Strings[iCount];
                   fFinished := True;
                   if (iCount = 9) then
                      if (VariableBox.Items.Strings[iCount-1] = 'Proximity') then
                         sRule := sRule + ' ' + IntToStr(SpinDistance.Value);
              end;
         else
             sRule := VariableBox.Items.Strings[iCount];
         end;

     if not fFinished
     and (OperatorGroup.ItemIndex >= 0) then
     begin
          {add operator to rule}
          sRule := 'Select ' + sRule + ' ' + OperatorGroup.Items.Strings[OperatorGroup.ItemIndex];
          if (OperatorGroup.ItemIndex > 1)
          and (OperatorGroup.ItemIndex < 8) then
              sRule := sRule + ' ' + ValueBox.Text;
     end;

     {add rule number to rule}
     sRule := IntToStr(RuleBox.Items.Count) + '. ' + sRule;
     RuleBox.Items.Delete(RuleBox.Items.Count-1);
     RuleBox.Items.Add(sRule);
     RuleBox.Items.Add(IntToStr(RuleBox.Items.Count+1) + '. Select First Sites');
     {
     sRule := IntToStr(RuleBox.Items.Count) + '. ' + sRule;
     RuleBox.Items.Insert(RuleBox.Items.Count-1,sRule);
     RuleBox.Items.Delete(RuleBox.Items.Count-1);
     RuleBox.Items.Add(IntToStr(RuleBox.Items.Count+1) + '. Select First Sites');
     }
end;

procedure NormaliseExtendedPrecisionValues(TheValues : Array_t; var rMax, rMin : extended);
var
   iCount : integer;
   aValue : trueFloattype;
begin
     for iCount := 1 to TheValues.lMaxSize do
     begin
          TheValues.rtnValue(iCount,@aValue);
          aValue.rValue := aValue.rValue / rMax;
          TheValues.setValue(iCount,@aValue);
     end;
     rMin := rMin / rMax;
     rMax := 1;
end;

procedure CountRegionSitesChosen(SitesChosen, RegionFlag : Array_t);
var
   iCount, iCount2, iSiteKey, iSiteIndex, iRegionIndex, iRegionSitesChosen : integer;
   sThisSitesRegion, sMatchRegion : str255;
   DebugFile : TextFile;
   sLine, sCandidate : string;
   fScenario2, fRegionFlag, fAllTargetsMet, fSiteContainsAFeature, fCandidate : boolean;
   rRegionResRate, rRegionResYear : extended;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   Value : ValueFile_T;
begin
     Inc(iCountRegionSitesChosenCount);
     AppendDebugLog('CountRegionSitesChosen start ' + IntToStr(iCountRegionSitesChosenCount));

     // set RegionSitesChosen to zero
     iRegionSitesChosen := 0;
     fRegionFlag := False;
     for iCount := 1 to iRegionCount do
     begin
          RegionFlag.setValue(iCount,@fRegionFlag);
          RegionSitesChosen.setValue(iCount,@iRegionSitesChosen);
     end;

     fScenario2 := (MinsetExpertForm.RadioReAllocLogic.ItemIndex = 1);
     new(pSite);
     new(pFeat);

     if fDebugReAlloc then
     begin
          assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\SitesChosen' + IntToStr(iCountRegionSitesChosenCount) + '.csv');
          rewrite(DebugFile);
          writeln(DebugFile,'sitekey,region,candidate site');
     end;

     fRegionFlag := True;
     // parse SitesChosen, counting how many in each region
     for iCount := 1 to SitesChosen.lMaxSize do
     begin
          SitesChosen.rtnValue(iCount,@iSiteKey);
          iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
          RegionField.rtnValue(iSiteIndex,@sThisSitesRegion);
          SiteArr.rtnValue(iSiteIndex,pSite);

          iRegionIndex := 0;
          for iCount2 := 1 to iRegionCount do
          begin
               RegionName.rtnValue(iCount2,@sMatchRegion);
               if (sMatchRegion = sThisSitesRegion) then
                  iRegionIndex := iCount2;
          end;

          if (iRegionIndex > 0) then
          begin
               RegionResRate.rtnValue(iRegionIndex,@rRegionResRate);
               RegionResYear.rtnValue(iRegionIndex,@rRegionResYear);

               if (rRegionResRate > 0) then
                  RegionFlag.setValue(iRegionIndex,@fRegionFlag);

               if (rRegionResRate > 0) and (rRegionResYear < rRegionResRate) then
               begin
                    if fScenario2 then
                       fCandidate := True
                    else
                    begin
                         fAllTargetsMet := True;
                         fSiteContainsAFeature := False;

                         if (pSite^.richness > 0) then
                            for iCount2 := 1 to pSite^.richness do
                            begin
                                 FeatureAmount.rtnValue(pSite^.iOffSet + iCount2,@Value);
                                 if (Value.rAmount > 0) then
                                 begin
                                      fSiteContainsAFeature := True;
                                      FeatArr.rtnValue(Value.iFeatKey,pFeat);
                                      if (pFeat^.targetarea > 0) then
                                         fAllTargetsMet := False;
                                 end;
                            end;

                         fCandidate := (fSiteContainsAFeature and (not fAllTargetsMet));
                    end;

                    if fCandidate then
                    begin
                         RegionSitesChosen.rtnValue(iRegionIndex,@iRegionSitesChosen);
                         Inc(iRegionSitesChosen);
                         RegionSitesChosen.setValue(iRegionIndex,@iRegionSitesChosen);
                    end;
               end
               else
                   fCandidate := False;
          end
          else
              fCandidate := False;

          if fDebugReAlloc then
          begin
               if fCandidate then
                  sCandidate := 'yes'
               else
                   sCandidate := 'no';

               writeln(DebugFile,IntToStr(iSiteKey) + ',' + IntToStr(iRegionIndex) + ',' + sCandidate);
          end;
     end;

     if fDebugReAlloc then
     begin
          closefile(DebugFile);
          assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\CountRegionSitesChosen.csv');
          if (iCountRegionSitesChosenCount = 1) then
          begin
               rewrite(DebugFile);
               sLine := 'index';
               for iCount := 1 to iRegionCount do
               begin
                    RegionName.rtnValue(iCount,@sMatchRegion);
                    sLine := sLine + ',' + sMatchRegion;
               end;
               writeln(DebugFile,sLine);
          end
          else
              append(DebugFile);

          sLine := IntToStr(iCountRegionSitesChosenCount);

          for iCount := 1 to iRegionCount do
          begin
               RegionSitesChosen.rtnValue(iCount,@iRegionSitesChosen);
               sLine := sLine + ',' + IntToStr(iRegionSitesChosen);
          end;
          writeln(DebugFile,sLine);
          closefile(DebugFile);
          if fileexists(ControlRes^.sWorkingDirectory + '\RegionFlag.csv') then
          begin
               assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\RegionFlag.csv');
               append(DebugFile);
          end
          else
          begin
               assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\RegionFlag.csv');
               rewrite(DebugFile);
               sLine := 'index';
               for iCount := 1 to iRegionCount do
               begin
                    RegionName.rtnValue(iCount,@sMatchRegion);
                    sLine := sLine + ',' + sMatchRegion;
               end;
               writeln(DebugFile,sLine);
          end;

          sLine := IntToStr(iCountRegionSitesChosenCount);

          for iCount := 1 to iRegionCount do
          begin
               RegionFlag.rtnValue(iCount,@fRegionFlag);
               if fRegionFlag then
                  sLine := sLine + ',yes'
               else
                   sLine := sLine + ',no';
          end;
          writeln(DebugFile,sLine);
          closefile(DebugFile);
     end;

     dispose(pFeat);
     dispose(pSite);
     AppendDebugLog('CountRegionSitesChosen end ' + IntToStr(iCountRegionSitesChosenCount));
end;

procedure MaskSitesChosen(SitesChosen : Array_t; const iNumberOfSites : integer);
var
   sCurrentRegion, sThisSitesRegion : str255;
   iCount, iCount2, iSiteKey, iSiteIndex : integer;
   TempSites : Array_t;
begin
     RegionName.rtnValue(iCurrentRegion,@sCurrentRegion);

     TempSites := Array_t.Create;
     TempSites.init(SizeOf(integer),iNumberOfSites);

     iCount2 := 0;
     for iCount := 1 to SitesChosen.lMaxSize do
     begin
          SitesChosen.rtnValue(iCount,@iSiteKey);
          iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
          RegionField.rtnValue(iSiteIndex,@sThisSitesRegion);

          if (sCurrentRegion = sThisSitesRegion) then
          begin
               Inc(iCount2);
               TempSites.setValue(iCount2,@iSiteKey);
          end;
     end;

     SitesChosen.Destroy;
     SitesChosen := Array_t.Create;
     SitesChosen.init(SizeOf(integer),iNumberOfSites);
     for iCount := 1 to iNumberOfSites do
     begin
          TempSites.rtnValue(iCount,@iSiteKey);
          SitesChosen.setValue(iCount,@iSiteKey);
     end;
     TempSites.Destroy;
end;

function CountTotalAllocation : extended;
var
   iCount : integer;
   rAllocation : extended;
begin
     Result := 0;
     for iCount := 1 to iRegionCount do
     begin
          RegionResRate.rtnValue(iCount,@rAllocation);
          Result := Result + rAllocation;
     end;
end;

procedure ReAllocateScenario12(RegionFlag : Array_t;
                               const iNumberOfRegionsWithAllocation,iRegionAllocation,iRandomAllocation : integer;
                               const rAllocationSize : extended);
var
   iCount, iRandomRegion, iRegionWithAllocationCount, iRegionSitesChosen : integer;
   rAllocation, rRegionResRate, rRegionResYear : extended;
begin
     iRandomRegion := Random(iNumberOfRegionsWithAllocation) + 1;
     iRegionWithAllocationCount := 0;

     for iCount := 1 to iRegionCount do
     begin
          RegionResRate.rtnValue(iCount,@rRegionResRate);
          RegionResYear.rtnValue(iCount,@rRegionResYear);

          if (rRegionResRate > 0) and (rRegionResYear >= rRegionResRate) then // this region has an allocation that has been reached for the year
          begin
               // assign allocation
               rAllocation := iRegionAllocation * rAllocationSize;
               Inc(iRegionWithAllocationCount);
               if (iRegionWithAllocationCount = iRandomRegion) then
                  rAllocation := rAllocation + (iRandomAllocation * rAllocationSize);
               RegionResRate.setValue(iCount,@rAllocation);
          end
          else
          begin
               // zero regions where all targets for species are met
               rAllocation := 0;
               RegionResRate.setValue(iCount,@rAllocation);
          end;
     end;
end;

function FindNextRegion(RegionFlag : Array_t) : integer;
var
   iCount, iCurrentRegion : integer;
   fRegionFlag : boolean;
   rCurrentPriority, rMaxPriority, rNextPriority : extended;
begin
     // what is current region priority
     rCurrentPriority := 0;
     for iCount := 1 to iRegionCount do
     begin
          RegionFlag.rtnValue(iCount,@fRegionFlag);
          if fRegionFlag then
          begin
               RegionPriority.rtnValue(iCount,@rCurrentPriority);
          end;
     end;
     // find next priority and region
     rMaxPriority := 0;
     for iCount := 1 to iRegionCount do
     begin
          RegionPriority.rtnValue(iCount,@rNextPriority);
          if (rNextPriority < rCurrentPriority) then
          begin
               if (rNextPriority > rMaxPriority) then
               begin
                    Result := iCount;
                    rMaxPriority := rNextPriority;
               end;
          end;
     end;
end;

procedure ReAllocateScenario3(const iTotalAllocation,iNextRegion : integer; const rAllocationSize : extended);
var
   iCount : integer;
   rAllocation : extended;
begin
     for iCount := 1 to iRegionCount do
         if (iCount = iNextRegion) then
         begin
              rAllocation := iTotalAllocation * rAllocationSize;
              RegionResRate.setValue(iCount,@rAllocation);
         end
         else
         begin
              rAllocation := 0;
              RegionResRate.setValue(iCount,@rAllocation);
         end;
end;

procedure ReAllocateScenario4(RegionFlag : Array_t; const iTotalAllocation : integer; const rAllocationSize : extended);
var
   rTotalPriority, rRegionResRate, rRegionPriority : extended;
   iCount, iRegionAllocation, iAllocationSum : integer;
   fRegionFlag : boolean;
   RegionAllocation : Array_t;
begin
     // init RegionAllocation
     RegionAllocation := Array_t.Create;
     RegionAllocation.init(SizeOf(integer),iRegionCount);
     // find the total priority of regions with allocation
     rTotalPriority := 0;
     for iCount := 1 to iRegionCount do
     begin
          RegionFlag.rtnValue(iCount,@fRegionFlag);
          RegionResRate.rtnValue(iCount,@rRegionResRate);
          if (rRegionResRate > 0) and (not fRegionFlag) then
          begin
               RegionPriority.rtnValue(iCount,@rRegionPriority);
               rTotalPriority := rTotalPriority + rRegionPriority;
          end;
     end;
     // assign allocation relative to this priority truncated
     for iCount := 1 to iRegionCount do
     begin
          RegionFlag.rtnValue(iCount,@fRegionFlag);
          RegionResRate.rtnValue(iCount,@rRegionResRate);
          if (rRegionResRate > 0) and (not fRegionFlag) then
          begin
               RegionPriority.rtnValue(iCount,@rRegionPriority);

               iRegionAllocation := trunc(rTotalPriority / rRegionPriority);
               RegionAllocation.setValue(iCount,@iRegionAllocation);
               Inc(iAllocationSum,iRegionAllocation);
          end;
     end;
     // round allocation up starting from the top down if the total is not used yet
     if (iAllocationSum < iTotalAllocation) then
        for iCount := 1 to (iTotalAllocation - iAllocationSum) do
        begin
             RegionFlag.rtnValue(iCount,@fRegionFlag);
             RegionResRate.rtnValue(iCount,@rRegionResRate);
             if (rRegionResRate > 0) and (not fRegionFlag) then
             begin
                  RegionAllocation.rtnValue(iCount,@iRegionAllocation);
                  Inc(iRegionAllocation);
                  RegionAllocation.setValue(iCount,@iRegionAllocation);
             end;
        end;
     // allocate reservation rate to regions
     for iCount := 1 to iRegionCount do
     begin
          RegionAllocation.rtnValue(iCount,@iRegionAllocation);
          if (iRegionAllocation > 0) then
          begin
               rRegionResRate := iRegionAllocation * rAllocationSize;
               RegionResRate.setValue(iCount,@rRegionResRate);
          end;
     end;

     RegionAllocation.Destroy;
end;

procedure UpdateReAllocTable(SitesChosen : Array_t; RegionFlag : Array_t);
var
   iCount, iTotalAllocation, iRegionAllocation, iRandomAllocation,
   iNumberOfRegionsWithAllocation, iNextRegion, iRegionSitesChosen : integer;
   fRegionFlag, fAnyRegionFlagged, fAllTargetsMet, fSiteContainsAFeature, fScenario2 : boolean;
   rTotalAllocation, rRegionAllocation, rRandomAllocation, rAllocationSize, rRegionResRate, rRegionResYear : extended;
   DebugFile : TextFile;
   sCurrentRegion : str255;
   sLine, sLine2 : string;
begin
     Inc(iUpdateReAllocTableCount);
     AppendDebugLog('UpdateReAllocTable start ' + IntToStr(iUpdateReAllocTableCount));

     // parse regions to see if 'active' regions have no candidate sites
     fAnyRegionFlagged := False;
     iNumberOfRegionsWithAllocation := 0;
     for iCount := 1 to iRegionCount do
     begin
          RegionResRate.rtnValue(iCount,@rRegionResRate);
          RegionResYear.rtnValue(iCount,@rRegionResYear);
          RegionSitesChosen.rtnValue(iCount,@iRegionSitesChosen);

          if (rRegionResRate > 0) then
          begin
               Inc(iNumberOfRegionsWithAllocation);

               if (rRegionResYear < rRegionResRate)then
               begin
                    if (iRegionSitesChosen = 0) then
                    begin
                         fAnyRegionFlagged := True;
                         Dec(iNumberOfRegionsWithAllocation);
                    end;
               end;
          end;
     end;

     // Reallocate reserves for these regions to the other regions with a
     // non-zero allocation remaining for the year and some targets for species still to be met.
     // The method of reallocation depends on the reallocation logic that
     // has been selected.
     if fAnyRegionFlagged then
     begin
          rAllocationSize := StrToFloat(MinsetExpertForm.EditReAllocUnitSize.Text);
          rTotalAllocation := CountTotalAllocation;
          iTotalAllocation := trunc(rTotalAllocation / rAllocationSize);

          case MinsetExpertForm.RadioReAllocLogic.ItemIndex of
               0,1:begin // Scenario 1 and 2
                      // Evenly allocate the total reserve allocation between
                      // regions with a non-zero allocation and some targets for
                      // species still to be met.  The amount left over that cannot
                      // be evenly allocated is randomly assigned to one of these
                      // regions.  Allocation is in chunks of planning unit size.

                      iRegionAllocation := iTotalAllocation div iNumberOfRegionsWithAllocation;
                      iRandomAllocation := iTotalAllocation mod iNumberOfRegionsWithAllocation;

                      ReAllocateScenario12(RegionFlag,iNumberOfRegionsWithAllocation,iRegionAllocation,iRandomAllocation,rAllocationSize);
                 end;
               2:begin // Scenario 3
                      // All reserves are allocated to the next highest priority
                      // region in turn.  Refer to the RegionPriority array to
                      // identify which is the next region.
                      iNextRegion := FindNextRegion(RegionFlag);

                      ReAllocateScenario3(iTotalAllocation,iNextRegion,rAllocationSize);
                 end;
               3:begin // Scenario 4
                      // Proportionally allocate the total reserve allocation between
                      // regions with a non-zero allocation and some targets for
                      // species still to be met.  The proportion is their relative
                      // reservation rate.  Round up to the nearest multiple of
                      // planning unit size, beginning with the region with the
                      // highest reservation rate.
                      ReAllocateScenario4(RegionFlag,iTotalAllocation,rAllocationSize);
                 end;
          end;

          if fDebugReAlloc then
          begin
               if fileexists(ControlRes^.sWorkingDirectory + '\ReAlloc.csv') then
               begin
                    assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\ReAlloc.csv');
                    append(DebugFile);
               end
               else
               begin
                    assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\ReAlloc.csv');
                    rewrite(DebugFile);
                    sLine := 'index,value';
                    for iCount := 1 to iRegionCount do
                    begin
                         RegionName.rtnValue(iCount,@sCurrentRegion);
                         sLine := sLine + ',' + sCurrentRegion;
                    end;
                    writeln(DebugFile,sLine);
               end;

               sLine := IntToStr(iUpdateReAllocTableCount) + ',RegionResYear';
               sLine2 := IntToStr(iUpdateReAllocTableCount) + ',RegionResRate';
               for iCount := 1 to iRegionCount do
               begin
                    RegionResRate.rtnValue(iCount,@rRegionResRate);
                    RegionResYear.rtnValue(iCount,@rRegionResYear);
                    RegionName.rtnValue(iCount,@sCurrentRegion);

                    sLine := sLine + ',' + FloatToStr(rRegionResYear);
                    sLine2 := sLine2 + ',' + FloatToStr(rRegionResRate);
               end;
               writeln(DebugFile,sLine);
               writeln(DebugFile,sLine2);

               closefile(DebugFile);
          end;

          CountRegionSitesChosen(SitesChosen,RegionFlag);
     end;

     AppendDebugLog('UpdateReAllocTable end ' + IntToStr(iUpdateReAllocTableCount));
end;

procedure EvaluateReAllocTable(SitesChosen : Array_t);
var
   rRegionResRate, rRegionResYear : extended;
   iRegionSitesChosen, iSitesAvailableForSelection : integer;
   iCount, iCount2, iCount3, iSiteKey, iSiteIndex, iSitesAdded : integer;
   fSitesAvailableForSelection, fScenario2, fCandidate, fAllTargetsMet, fSiteContainsAFeature : boolean;
   sCurrentRegion, sThisSitesRegion : str255;
   TempSites, RegionFlag : Array_t;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   Value : ValueFile_T;
begin
     Inc(iEvaluateReAllocTableCount);

     AppendDebugLog('EvaluateReAllocTable start ' + IntToStr(iEvaluateReAllocTableCount));

     new(pSite);
     new(pFeat);
     RegionFlag := Array_t.Create;
     RegionFlag.init(SizeOf(boolean),iRegionCount);
     fScenario2 := (MinsetExpertForm.RadioReAllocLogic.ItemIndex = 1);

     // Count how many of SitesChosen are each region so we know this for the next step.
     CountRegionSitesChosen(SitesChosen,RegionFlag);

     UpdateReAllocTable(SitesChosen,RegionFlag); // Reallocate reserves for any region where all the targets
                                                 // for species are met.

     fSitesAvailableForSelection := False;
     iSitesAvailableForSelection := 0;

     // Move to the next region to automatically cycle through regions each iteration.
     // If the region we are targeting has no quota, skip it.
     // If the region we are targeting has already received its quota for the year, skip it.
     // If there are no SitesChosen for the region we are targeting, skip it.
     // If we pass through all regions without finding a match, trap ERROR CONDITION.
     for iCount := 1 to iRegionCount do
     begin
          RegionResRate.rtnValue(iCount,@rRegionResRate);
          RegionResYear.rtnValue(iCount,@rRegionResYear);
          RegionSitesChosen.rtnValue(iCount,@iRegionSitesChosen);

          if (rRegionResRate > 0) and (rRegionResYear < rRegionResRate) and (iRegionSitesChosen > 0) then
          begin
               fSitesAvailableForSelection := True;
               iSitesAvailableForSelection := iSitesAvailableForSelection + iRegionSitesChosen;
          end;
     end;

     if fSitesAvailableForSelection then
     begin
          TempSites := Array_t.Create;
          TempSites.init(SizeOf(integer),SitesChosen.lMaxSize);
          iSitesAdded := 0;

          for iCount := 1 to SitesChosen.lMaxSize do
          begin
               SitesChosen.rtnValue(iCount,@iSiteKey);
               iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
               RegionField.rtnValue(iSiteIndex,@sThisSitesRegion);

               for iCount2 := 1 to iRegionCount do
               begin
                    RegionResRate.rtnValue(iCount2,@rRegionResRate);
                    RegionResYear.rtnValue(iCount2,@rRegionResYear);
                    RegionSitesChosen.rtnValue(iCount2,@iRegionSitesChosen);

                    if (rRegionResRate > 0) and (rRegionResYear < rRegionResRate) and (iRegionSitesChosen > 0) then
                    begin
                         RegionName.rtnValue(iCount2,@sCurrentRegion);

                         if (sCurrentRegion = sThisSitesRegion) then
                         begin
                              if fScenario2 then
                                 fCandidate := True
                              else
                              begin
                                   fAllTargetsMet := True;
                                   fSiteContainsAFeature := False;

                                   SiteArr.rtnValue(iSiteIndex,pSite);

                                   if (pSite^.richness > 0) then
                                      for iCount3 := 1 to pSite^.richness do
                                      begin
                                           FeatureAmount.rtnValue(pSite^.iOffSet + iCount3,@Value);
                                           if (Value.rAmount > 0) then
                                           begin
                                                fSiteContainsAFeature := True;
                                                FeatArr.rtnValue(Value.iFeatKey,pFeat);
                                                if (pFeat^.targetarea > 0) then
                                                   fAllTargetsMet := False;
                                           end;
                                      end;

                                   fCandidate := (fSiteContainsAFeature and (not fAllTargetsMet));
                              end;

                              if fCandidate then
                              begin
                                   Inc(iSitesAdded);
                                   TempSites.setValue(iSitesAdded,@iSiteKey);
                              end;
                         end;
                    end;
               end;
          end;

          if (TempSites.lMaxSize <> iSitesAdded) then
             TempSites.resize(iSitesAdded);

          //SitesChosen.Destroy;
          //SitesChosen := Array_t.Create;
          if (SitesChosen.lMaxSize <> iSitesAdded) then
             SitesChosen.resize(iSitesAdded);
          SitesChosen.init(SizeOf(integer),iSitesAdded);
          for iCount := 1 to iSitesAdded do
          begin
               TempSites.rtnValue(iCount,@iSiteKey);
               SitesChosen.setValue(iCount,@iSiteKey);
          end;
          TempSites.Destroy;
     end
     else
         // no regions have an allocation
         SitesChosen.lMaxSize := 0;

     RegionFlag.Destroy;
     dispose(pSite);
     dispose(pFeat);

     AppendDebugLog('EvaluateReAllocTable end ' + IntToStr(iEvaluateReAllocTableCount));
end;

procedure HedleyDebugAnalyseValues(SitesToReport : Array_t;iActiveRule,iActiveIteration : integer);
var
   DebugFile : TextFile;
   iCount, iSiteKey, iSiteIndex : integer;
   pSite : sitepointer;
   rSiteVuln, rSiteCost, rSVC : extended;
begin
     try
        new(pSite);
        assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\DebugAnalyseValues_' + IntToStr(iActiveIteration) + '_' + IntToStr(iActiveRule) + '.csv');
        rewrite(DebugFile);
        writeln(DebugFile,'SiteKey,SumIrr,SiteVuln,SiteCost,S * V / C');

        for iCount := 1 to SitesToReport.lMaxSize do
        begin
             SitesToReport.rtnValue(iCount,@iSiteKey);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
             SiteArr.rtnValue(iSiteIndex,@pSite);

             SiteVuln.rtnValue(iSiteIndex,@rSiteVuln);
             SiteCost.rtnValue(iSiteIndex,@rSiteCost);

             if (rSiteCost > 0) then
                rSVC := pSite^.rSummedIrr * rSiteVuln / rSiteCost
             else
                 rSVC := 0;

             writeln(DebugFile,IntToStr(iSiteKey) + ',' +
                               FloatToStr(pSite^.rSummedIrr) + ',' +
                               FloatToStr(rSiteVuln) + ',' +
                               FloatToStr(rSiteCost) + ',' +
                               FloatToStr(rSVC));
        end;

        dispose(pSite);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in HedleyDebugAnalyseValues',mtError,[mbOk],0);
     end;
end;


function ApplyRule(const iCurrentRule : integer;
                   SitesChosen, ValuesChosen : Array_t;
                   const sType, sField, sOperator, sValue : string;
                   const iSelectionsPerIteration : integer;
                   var fSuspendExecution : boolean;
                   const fDebug : boolean;
                   const iCurrentIteration : integer;
                   const fApplyComplementarity, fRecalculateComplementarity, fComplementarity : boolean) : boolean;
//
// fSuspendExecution = False when called, set it to True to tell the calling
//                                        process to halt
//
// fApplyComplementarity = True,  apply complementarity (original method)
//                         False, no complementarity (new hotspots method)
//
var
   ResultSites : Array_t;
   iResultSites, iCount, iCount2, iKey, iSiteIndex : integer;
   pSite : sitepointer;
   rRegionResYear : extended;
   sSitesRegionName, sSearchRegionName : str255;
   iRegionIndex : integer;

   procedure AddASite(const iChosenKey : integer;
                      const rValue : extended);
   begin
        try
           if (iChosenKey <> -1) then
           begin
                {add this site to the list of selected sites}

                inc(iResultSites);
                if (iResultSites > ResultSites.lMaxSize) then
                   ResultSites.resize(ResultSites.lMaxSize + ARR_STEP_SIZE);

                ResultSites.setValue(iResultSites,@iChosenKey);

                if (iCurrentRule = 1) then
                begin
                     if (iResultSites > ValuesChosen.lMaxSize) then
                        ValuesChosen.resize(ValuesChosen.lMaxSize + ARR_STEP_SIZE);
                     ValuesChosen.setValue(iResultSites,@rValue);
                end;
           end;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in AddASite',mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;
   end;

   function IsInSitesChosen(const iKey : integer) : boolean;
   var
      iCount, iTestKey : integer;
   begin
        try
           Result := False;

           for iCount := 1 to SitesChosen.lMaxSize do
           begin
                SitesChosen.rtnValue(iCount,@iTestKey);
                if (iKey = iTestKey) then
                   Result := True;
           end;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in IsInSitesChosen',mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;
   end;

   procedure ReParseHiLo(const rExtremeValue : extended);
   var
      iCount, iSiteIndex, iKey, iLocalCount : integer;
      pSite : sitepointer;
      rValue : extended;
   begin
        try
           new(pSite);
           iLocalCount := 0;
           if (iResultSites > 0) then
           begin
                for iCount := 1 to iResultSites do
                begin
                     ResultSites.rtnValue(iCount,@iKey);
                     iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
                     SiteArr.rtnValue(iSiteIndex,pSite);

                     if (sField = 'IRREPL') then
                        rValue := pSite^.rIrreplaceability
                     else
                         if (sField = 'SUMIRR') then
                            rValue := pSite^.rSummedIrr
                         else
                             if (sField = 'WAVIRR') then
                                rValue := pSite^.rWAVIRR
                             else
                                 if (sField = 'PCCONTR') then
                                    rValue := pSite^.rPCUSED
                                 else
                                     if (sField = 'AREA') then
                                        rValue := pSite^.area
                                     else
                                         rValue := rtnSubsetValue(sField,pSite,iSiteIndex);

                     if (rValue = rExtremeValue)
                     or ((rValue >= (rExtremeValue-0.000001))
                         and (rValue <= (rExtremeValue+0.000001))) then
                     begin
                          {add this site to the ResultSites array}
                          Inc(iLocalCount);
                          ResultSites.setValue(iLocalCount,@iKey);
                     end;
                end;

                iResultSites := iLocalCount;
           end;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in ReParseHiLo',mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;

        dispose(pSite);
   end;

   procedure ReParseHiLoDB(const rExtremeValue : extended);
   var
      iCount, iSiteIndex, iKey, iTestKey, iLocalCount : integer;
      rValue : extended;
      fEnd{, fTrace} : boolean;
   begin
        try
           iLocalCount := 0;
           if (iResultSites > 0) then
           begin
                RulesForm.QueryTable.Open;
                fEnd := False;

                repeat
                      iKey := RulesForm.QueryTable.FieldByName(ControlRes^.sKeyField).AsInteger;

                      {if (iKey = 17)
                      or (iKey = 25) then
                         fTrace := True;}

                      for iCount := 1 to iResultSites do
                      begin
                           ResultSites.rtnValue(iCount,@iTestKey);
                           if (iTestKey = iKey) then
                           begin
                                try
                                   rValue := RulesForm.QueryTable.FieldByName(sField).AsFloat;
                                except
                                      rValue := 0;
                                end;

                                if (rValue = rExtremeValue)
                                or ((rValue >= (rExtremeValue-0.000001))
                                    and (rValue <= (rExtremeValue+0.000001))) then
                                begin
                                     {add this site to the ResultSites array}
                                     Inc(iLocalCount);
                                     if (iLocalCount > ResultSites.lMaxSize) then
                                        ResultSites.resize(ResultSites.lMaxSize + ARR_STEP_SIZE);
                                     ResultSites.setValue(iLocalCount,@iKey);
                                end;
                           end;
                      end;

                      fEnd := RulesForm.QueryTable.EOF;
                      RulesForm.QueryTable.Next;

                until fEnd;

                iResultSites := iLocalCount;

                RulesForm.QueryTable.Close;
           end;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in ReParseHiLo',mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;
   end;

   procedure AnalyseValues(const fHighestValues : boolean);
   var
      UnsortedValues, SortedValues, SingleValues : Array_t;
      aValue : trueFloattype;
      iPercentage, iNumberOfSites,
      iCount, iKey : integer;
      ASite : site;
      rHi, rLo, rSingle : single;
      rSiteVuln, rSiteCost,
      rHighest, rLowest,
      rEHi, rELo : extended;
      DebugFile : TextFile;
      fIsSubsetField, fValidateIteration : boolean;
      WS : WeightedSumirr_T;
      MSW : MinsetSumirrWeightings_T;
      //iHighestFile : integer;
      HighestFile, AvailableFile : File of trueFloattype;
      //sHighestFile : string;
   begin
        // if fHighestValues = True then select highest values else select lowest values
        try
           if MinsetExpertForm.CheckReAllocate.Checked then
           begin
                // We are reallocating reserves between regions, and need to check
                // how many hectares have been reserved in each region already this
                // 'year' in case we need to update prioritys.
                EvaluateReAllocTable(SitesChosen);
           end;

           if fHedleySimulatorDebug then
              if ControlRes^.fLoadSiteVuln and ControlRes^.fLoadSiteCost then
                 HedleyDebugAnalyseValues(SitesChosen,iCurrentRule,iCurrentIteration);

           if (SitesChosen.lMaxSize > 0) then // We need to fall gracefully out of the loop if SitesChosen.lMaxSize = 0
           begin
                // build an array of unsorted values, recording the
                // maximum and minimum as it is built
                UnsortedValues := Array_t.Create;
                UnsortedValues.init(SizeOf(aValue),SitesChosen.lMaxSize);
                rEHi := 0;
                rELo := 100000;
                if fApplyComplementarity then
                begin
                     try

                     except
                           Screen.Cursor := crDefault;
                           MessageDlg('Exception in UnsortedValues.init',mtError,[mbOk],0);
                           Application.Terminate;
                           Exit;
                     end;

                     fIsSubsetField := IsSubsetField(sField);

                     for iCount := 1 to SitesChosen.lMaxSize do
                     begin
                          SitesChosen.rtnValue(iCount,@iKey);
                          iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
                          SiteArr.rtnValue(iSiteIndex,@ASite);

                          if fIsSubsetField then
                             aValue.rValue := rtnSubsetValue(sField,@ASite,iSiteIndex)
                          else
                              case sField[1] of
                                   'I' : aValue.rValue := ASite.rIrreplaceability;
                                   'W' : aValue.rValue := ASite.rWAVIRR;
                                   'S' :
                                   begin
                                        aValue.rValue := ASite.rSummedIrr;
                                        if (sField[4] <> 'I') then
                                        begin
                                             if (sField = 'SUM_V2') then
                                                aValue.rValue := ASite.rSummedIrrVuln2
                                             else
                                             begin
                                                  if ControlRes^.fCalculateBobsExtraVariations then
                                                  begin
                                                       MinsetSumirrWeightings.rtnValue(iSiteIndex,@MSW);

                                                       if (sField = 'SUM_CR') then
                                                          aValue.rValue := MSW.rWcr
                                                       else
                                                           if (sField = 'SUM_PT') then
                                                              aValue.rValue := MSW.rWpt
                                                           else
                                                               if (sField = 'SUM_CRIT') then
                                                                  aValue.rValue := MSW.rWcrWit
                                                               else
                                                                   if (sField = 'SUM_CRVU') then
                                                                      aValue.rValue := MSW.rWcrWvu
                                                                   else
                                                                       if (sField = 'SUM_CRITVU') then
                                                                          aValue.rValue := MSW.rWcrWitWvu
                                                                       else
                                                                           if (sField = 'SUM_SA') then
                                                                              aValue.rValue := MSW.rWsa
                                                                           else
                                                                               if (sField = 'SUM_SAPA') then
                                                                                  aValue.rValue := MSW.rWsaWpa
                                                                               else
                                                                                   if (sField = 'SUM_SAPT') then
                                                                                      aValue.rValue := MSW.rWsaWpt
                                                                                   else
                                                                                       if (sField = 'SUM_PAPT') then
                                                                                          aValue.rValue := MSW.rWpaWpt
                                                                                       else
                                                                                           if (sField = 'Site Vulnerability') then
                                                                                           begin
                                                                                                if ControlRes^.fLoadSiteVuln then
                                                                                                begin
                                                                                                     SiteVuln.rtnValue(iSiteIndex,@rSiteVuln);
                                                                                                     aValue.rValue := rSiteVuln;
                                                                                                end
                                                                                                else
                                                                                                    aValue.rValue := 0;
                                                                                           end
                                                                                           else
                                                                                           if (sField = 'Site Cost') then
                                                                                           begin
                                                                                                if ControlRes^.fLoadSiteCost then
                                                                                                begin
                                                                                                     SiteCost.rtnValue(iSiteIndex,@rSiteCost);
                                                                                                     aValue.rValue := rSiteCost;
                                                                                                end
                                                                                                else
                                                                                                    aValue.rValue := 0;
                                                                                           end
                                                                                           else
                                                                                           if (sField = 'S * V / C') then
                                                                                           begin
                                                                                                if ControlRes^.fLoadSiteVuln and ControlRes^.fLoadSiteCost then
                                                                                                begin
                                                                                                     SiteVuln.rtnValue(iSiteIndex,@rSiteVuln);
                                                                                                     SiteCost.rtnValue(iSiteIndex,@rSiteCost);
                                                                                                     if (rSiteCost > 0) then
                                                                                                        aValue.rValue := ASite.rSummedIrr * rSiteVuln / rSiteCost
                                                                                                     else
                                                                                                         aValue.rValue := 0;
                                                                                                end
                                                                                                else
                                                                                                    aValue.rValue := 0;
                                                                                           end;
                                                  end;
                                                  if ControlRes^.fCalculateAllVariations then
                                                  begin
                                                       WeightedSumirr.rtnValue(iSiteIndex,@WS);
                                                       if (sField = 'SUM_PA') then
                                                          aValue.rValue := WS.r_a
                                                       else
                                                       if (sField = 'SUM_IT') then
                                                          aValue.rValue := WS.r_t
                                                       else
                                                       if (sField = 'SUM_VU') then
                                                          aValue.rValue := WS.r_v
                                                       else
                                                       if (sField = 'SUM_PAIT') then
                                                          aValue.rValue := WS.r_at
                                                       else
                                                       if (sField = 'SUM_PAVU') then
                                                          aValue.rValue := WS.r_av
                                                       else
                                                       if (sField = 'SUM_ITVU') then
                                                          aValue.rValue := WS.r_tv
                                                       else
                                                       if (sField = 'SUM_PAITVU') then
                                                          aValue.rValue := WS.r_atv;
                                                  end;
                                             end;
                                        end;
                                   end;
                                   'P' : aValue.rValue := ASite.rPCUSED;
                                   'A' : aValue.rValue := ASite.area;
                              end;

                          aValue.iIndex := iCount;

                          if (aValue.rValue > rEHi) then
                             rEHi := aValue.rValue;
                          if (aValue.rValue < rELo) then
                             rELo := aValue.rValue;

                          UnsortedValues.setValue(iCount,@aValue);
                     end;
                end
                else
                begin
                     // complementarity is off
                     //if fRecalculateComplementarity then
                     for iCount := 1 to SitesChosen.lMaxSize do
                     begin
                          // we need to recalculate and refresh the values
                          SitesChosen.rtnValue(iCount,@iKey);
                          iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
                          SiteArr.rtnValue(iSiteIndex,@ASite);

                          case sField[1] of
                               'I' : aValue.rValue := ASite.rIrreplaceability;
                               'S' : aValue.rValue := ASite.rSummedIrr;
                               'W' : aValue.rValue := ASite.rWAVIRR;
                               'P' : aValue.rValue := ASite.rPCUSED;
                               'A' : aValue.rValue := ASite.area;
                          end;

                          aValue.iIndex := iCount;
                          if (aValue.rValue > rEHi) then
                             rEHi := aValue.rValue;
                          if (aValue.rValue < rELo) then
                             rELo := aValue.rValue;
                          UnsortedValues.setValue(iCount,@aValue);
                          CacheSelectRule.setValue(iSiteIndex,@aValue.rValue);
                     end;
                end;

                if (rEHi < 0.00000001)
                and (rEHi > 0) then
                    NormaliseExtendedPrecisionValues(UnsortedValues,rEHi,rELo);

                // do any vulnerability adjustments here
                case MinsetExpertForm.CombineVuln.ItemIndex of
                     1 : {Normalise with Maximum Vulnerability}
                         NormaliseMaxVuln(UnsortedValues,rEHi,rELo,SitesChosen,fDebug or ControlRes^.fGenerateCompRpt,
                                          fApplyComplementarity,fRecalculateComplementarity);
                     2 : {Normalise with Weighted Average Vulnerability}
                         NormaliseWavVuln(UnsortedValues,rEHi,rELo,SitesChosen,fDebug or ControlRes^.fGenerateCompRpt,
                                          fApplyComplementarity,fRecalculateComplementarity);
                     3 : {Restrict to maximum X% of vulnerable sites}
                         RestrictVuln(UnsortedValues,SitesChosen{,fDebug or ControlRes^.fGenerateCompRpt},rEHi,rELo,
                                      fApplyComplementarity,fRecalculateComplementarity);
                end;

                // now convert UnsortedValues to a single precision type
                rHi := 0;
                rLo := 100000;
                SingleValues := Array_t.Create;
                SingleValues.init(SizeOf(single),UnsortedValues.lMaxSize);
                for iCount := 1 to UnsortedValues.lMaxSize do
                begin
                     UnsortedValues.rtnValue(iCount,@aValue);
                     rSingle := aValue.rValue;
                     SingleValues.setValue(iCount,@rSingle);

                     if (rSingle > rHi) then
                        rHi := rSingle;
                     if (rSingle < rLo) then
                        rLo := rSingle;
                end;

                // dump the values to a file
                if fDebug
                and ValidateThisIteration(iMinsetIterationCount) then
                begin
                     assignfile(DebugFile,sIteration + '\AvailableValues.csv');
                     rewrite(DebugFile);
                     writeln(DebugFile,'SiteIndex,ExtendedValue,SingleValue');
                     for iCount := 1 to UnsortedValues.lMaxSize do
                     begin
                          UnsortedValues.rtnValue(iCount,@aValue);
                          SingleValues.rtnValue(iCount,@rSingle);
                          SitesChosen.rtnValue(iCount,@iKey);
                          writeln(DebugFile,IntToStr(iKey) + ',' +
                                            FloatToStr{F}(aValue.rValue{,ffGeneral,18,1}) + ',' +
                                            FloatToStr(rSingle));
                     end;
                     closefile(DebugFile);
                end;

                // determine if we need to validate this iteration
                fValidateIteration := False;
                if ControlRes^.fValidateMode then
                begin
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
                end;

                // if we are selecting the highest or lowest X%, do so here
                if (Pos('%',sValue) > 0) then
                begin
                     iPercentage := StrToInt(Copy(sValue,1,Length(sValue)-1));
                     // sort the values
                     SortedValues := SortFloatArray(UnsortedValues);
                     // highest values first, lowest values last
                     //SortedValues.rtnValue(1,@aValue);
                     //rHighest := aValue.rValue;
                     //SortedValues.rtnValue(UnsortedValues.lMaxSize,@aValue);
                     //rLowest := aValue.rValue;
                     //MessageDlg('Highest ' + FloatToStr(rHighest) + ' Lowest ' + FloatToStr(rLowest),mtInformation,[mbOk],0);
                     // alternatively, find mean and standard deviation
                     // number of standard deviations above mean

                     if fHighestValues then
                     begin
                          // Highest
                          // determine appropriate index, and get value at that point
                          iNumberOfSites := Trunc(iPercentage * SortedValues.lMaxSize / 100);
                          SortedValues.rtnValue(iNumberOfSites,@aValue);
                          rHighest := aValue.rValue;
                          // select everything in list >= value at point
                          for iCount := 1 to SortedValues.lMaxSize do
                          begin
                               SortedValues.rtnValue(iCount,@aValue);

                               if (aValue.rValue >= rHighest) then
                               begin
                                    SitesChosen.rtnValue(aValue.iIndex,@iKey);
                                    AddASite(iKey,rSingle);
                               end;
                          end;
                     end
                     else
                     begin
                          // Lowest
                          iNumberOfSites := Trunc(iPercentage * SortedValues.lMaxSize / 100);
                          iNumberOfSites := SortedValues.lMaxSize - iNumberOfSites;
                          SortedValues.rtnValue(iNumberOfSites,@aValue);
                          rLowest := aValue.rValue;
                          // select everything in list <= value at point
                          for iCount := 1 to SortedValues.lMaxSize do
                          begin
                               SortedValues.rtnValue(iCount,@aValue);

                               if (aValue.rValue <= rLowest) then
                               begin
                                    SitesChosen.rtnValue(aValue.iIndex,@iKey);
                                    AddASite(iKey,rSingle);
                               end;
                          end;
                     end;

                     SortedValues.Destroy;
                end
                else
                begin
                     // reparse the unsorted values, building a list
                     // of maximum or minimum values as we parse
                     if fHighestValues then
                     begin
                          // init highest file
                          if fValidateIteration then
                          begin
                               assignfile(HighestFile,ControlRes^.sWorkingDirectory +
                                               '\highest_value' +
                                               IntToStr(iMinsetIterationCount) +
                                               '.bin');
                               rewrite(HighestFile);
                               assignfile(AvailableFile,ControlRes^.sWorkingDirectory +
                                               '\available_value' +
                                               IntToStr(iMinsetIterationCount) +
                                               '.bin');
                               rewrite(AvailableFile);
                          end;

                          for iCount := 1 to UnsortedValues.lMaxSize do
                          begin
                               UnsortedValues.rtnValue(iCount,@aValue);
                               SingleValues.rtnValue(iCount,@rSingle);

                               if rSingle = rHi then
                               begin
                                    SitesChosen.rtnValue(aValue.iIndex,@iKey);
                                    AddASite(iKey,rSingle);

                                    // add entry to highest file
                                    if fValidateIteration then
                                       write(HighestFile,aValue);
                               end;

                               if fValidateIteration then
                                  write(AvailableFile,aValue);
                          end;

                          // close highest file
                          if fValidateIteration then
                          begin
                               closefile(HighestFile);
                               closefile(AvailableFile);
                          end;
                     end
                     else
                     begin
                          for iCount := 1 to UnsortedValues.lMaxSize do
                          begin
                               UnsortedValues.rtnValue(iCount,@aValue);
                               SingleValues.rtnValue(iCount,@rSingle);

                               if rSingle = rLo then
                               begin
                                    SitesChosen.rtnValue(aValue.iIndex,@iKey);
                                    AddASite(iKey,rSingle);
                               end;
                          end;
                     end;
                end;

                UnsortedValues.Destroy;
                SingleValues.Destroy;
           end;

        except
              Screen.Cursor := crDefault;
              GenerateDebugReports(ControlRes^.sWorkingDirectory + '\exception');
              ExceptionDebug('Exception in AnalyseValues with field ' + sField);
              Application.Terminate;
              Exit;
        end;
   end;

   procedure AnalyseOneValues(const fHighest : boolean);
   var
      UnsortedValues, SortedValues, SingleValues : Array_t;
      aValue : trueFloattype;
      iCount, iKey : integer;
      ASite : site;
      rHi, rLo, rSingle : single;
      rEHi, rELo : extended;
      DebugFile : TextFile;
      fIsSubsetField, fValidateIteration : boolean;
      WS : WeightedSumirr_T;
      MSW : MinsetSumirrWeightings_T;
      HighestFile, LowestFile, AvailableFile : File of trueFloattype;
   begin
        try
           // build an array of unsorted values, recording the
           // maximum and minimum as it is built
           UnsortedValues := Array_t.Create;
           UnsortedValues.init(SizeOf(aValue),SitesChosen.lMaxSize);
           rEHi := 0;
           rELo := 100000;
           try
           except
                 Screen.Cursor := crDefault;
                 MessageDlg('Exception in UnsortedValues.init',mtError,[mbOk],0);
                 Application.Terminate;
                 Exit;
           end;

           fIsSubsetField := IsSubsetField(sField);

           for iCount := 1 to SitesChosen.lMaxSize do
           begin
                SitesChosen.rtnValue(iCount,@iKey);
                iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
                SiteArr.rtnValue(iSiteIndex,@ASite);

                aValue.rValue := 1;

                aValue.iIndex := iCount;

                if (aValue.rValue > rEHi) then
                   rEHi := aValue.rValue;
                if (aValue.rValue < rELo) then
                   rELo := aValue.rValue;

                UnsortedValues.setValue(iCount,@aValue);
           end;

           // do any vulnerability adjustments here
           case MinsetExpertForm.CombineVuln.ItemIndex of
                1 : {Normalise with Maximum Vulnerability}
                    NormaliseMaxVuln(UnsortedValues,rEHi,rELo,SitesChosen,fDebug or ControlRes^.fGenerateCompRpt,
                                     fApplyComplementarity,fRecalculateComplementarity);
                2 : {Normalise with Weighted Average Vulnerability}
                    NormaliseWavVuln(UnsortedValues,rEHi,rELo,SitesChosen,fDebug or ControlRes^.fGenerateCompRpt,
                                     fApplyComplementarity,fRecalculateComplementarity);
                3 : {Restrict to maximum X% of vulnerable sites}
                    RestrictVuln(UnsortedValues,SitesChosen{,fDebug or ControlRes^.fGenerateCompRpt},rEHi,rELo,
                                 fApplyComplementarity,fRecalculateComplementarity);
           end;

           // now convert UnsortedValues to a single precision type
           rHi := 0;
           rLo := 100000;
           SingleValues := Array_t.Create;
           SingleValues.init(SizeOf(single),UnsortedValues.lMaxSize);
           for iCount := 1 to UnsortedValues.lMaxSize do
           begin
                UnsortedValues.rtnValue(iCount,@aValue);
                rSingle := aValue.rValue;
                SingleValues.setValue(iCount,@rSingle);

                if (rSingle > rHi) then
                   rHi := rSingle;
                if (rSingle < rLo) then
                   rLo := rSingle;
           end;

           // dump the values to a file
           if fDebug
           and ValidateThisIteration(iMinsetIterationCount) then
           begin
                assignfile(DebugFile,sIteration + '\AvailableValues.csv');
                rewrite(DebugFile);
                writeln(DebugFile,'SiteIndex,ExtendedValue,SingleValue');
                for iCount := 1 to UnsortedValues.lMaxSize do
                begin
                     UnsortedValues.rtnValue(iCount,@aValue);
                     SingleValues.rtnValue(iCount,@rSingle);
                     SitesChosen.rtnValue(iCount,@iKey);
                     writeln(DebugFile,IntToStr(iKey) + ',' +
                                       FloatToStr{F}(aValue.rValue{,ffGeneral,18,1}) + ',' +
                                       FloatToStr(rSingle));
                end;
                closefile(DebugFile);
           end;

           // determine if we need to validate this iteration
           fValidateIteration := False;
           if ControlRes^.fValidateMode then
           begin
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
           end;

           // reparse the unsorted values, building a list
           // of maximum or minimum values as we parse
           if fValidateIteration then
           begin
                assignfile(HighestFile,ControlRes^.sWorkingDirectory +
                                '\highest_value' +
                                IntToStr(iMinsetIterationCount) +
                                '.bin');
                rewrite(HighestFile);
                assignfile(LowestFile,ControlRes^.sWorkingDirectory +
                                      '\lowest_value' +
                                      IntToStr(iMinsetIterationCount) +
                                      '.bin');
                rewrite(LowestFile);
                assignfile(AvailableFile,ControlRes^.sWorkingDirectory +
                                '\available_value' +
                                IntToStr(iMinsetIterationCount) +
                                '.bin');
                rewrite(AvailableFile);
           end;

           for iCount := 1 to UnsortedValues.lMaxSize do
           begin
                UnsortedValues.rtnValue(iCount,@aValue);
                SingleValues.rtnValue(iCount,@rSingle);

                if fHighest then
                begin
                     if rSingle = rHi then//IsWithinTolerance(aValue.rValue,rHi,0.000000000001) then
                     begin
                          SitesChosen.rtnValue(aValue.iIndex,@iKey);
                          AddASite(iKey,rSingle);

                          // add entry to highest file
                          if fValidateIteration then
                             write(HighestFile,aValue);
                     end;
                end
                else
                begin
                     if rSingle = rLo then//IsWithinTolerance(aValue.rValue,rHi,0.000000000001) then
                     begin
                          SitesChosen.rtnValue(aValue.iIndex,@iKey);
                          AddASite(iKey,rSingle);

                          // add entry to lowest file
                          if fValidateIteration then
                             write(LowestFile,aValue);
                     end;
                end;

                if fValidateIteration then
                   write(AvailableFile,aValue);
           end;

           // close highest file
           if fValidateIteration then
           begin
                closefile(HighestFile);
                closefile(LowestFile);
                closefile(AvailableFile);
           end;

           UnsortedValues.Destroy;
           SingleValues.Destroy;

        except
              Screen.Cursor := crDefault;
              GenerateDebugReports(ControlRes^.sWorkingDirectory + '\exception');
              ExceptionDebug('Exception in AnalyseValues with field ' + sField);
              Application.Terminate;
              Exit;
        end;
   end;

   procedure SelectFirstSites;
   var
      iCount : integer;
   begin
        // 'Select First Sites' rule
        // if (SitesChosen.lMaxSize > MinsetExpertForm.SpinSelect.Value) then
        if MinsetExpertForm.CheckReportSelectFirstSites.Checked then
           AppendFirstSiteReport(SitesChosen);
        for iCount := 1 to MinsetExpertForm.SpinSelect.Value do
        begin
             SitesChosen.rtnValue(iCount,@iKey);
             AddASite(iKey,0);
        end;
   end;

   function IsSumWeighting(const sFld : string) : boolean;
   begin
        Result := False;
        if (Length(sFld) > 4)
        and (LowerCase(Copy(sFld,1,4)) = 'sum_') then
            Result := True;
   end;

   procedure SelectRule;
   var
      iCount, iKey, iSiteIndex, iChosenKey : integer;
      pSite : sitepointer;
      rValue, rTestValue, rToMatchValue, rChosenSiteValue : real;
      fEnd : boolean;
   begin
        try
           new(pSite);

           {apply the select rule}
           if (sField = 'IRREPL')
           or (sField = 'SUMIRR')
           or (sField = 'WAVIRR')
           or (sField = 'PCCONTR')
           or (sField = 'AREA')
           or (sField = 'Site Vulnerability')
           or (sField = 'Site Cost')
           or (sField = 'S * V / C')
           or IsSubsetField(sField)
           or IsSumWeighting(sField) then
           begin
                {MemoryVariable}

                rTestValue := -1;

                if (sValue <> '') then
                   rToMatchValue := RegionSafeStrToFloat(sValue);

                iChosenKey := -1;

                if (sOperator = 'Highest') then
                   AnalyseValues(True)
                else
                if (sOperator = 'Lowest') then
                   AnalyseValues(False)
                else
                for iCount := 1 to SitesChosen.lMaxSize do
                begin
                     SitesChosen.rtnValue(iCount,@iKey);
                     iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
                     SiteArr.rtnValue(iSiteIndex,pSite);

                     if (sField = 'First') then
                     begin
                          if (iCount < MinsetExpertForm.SpinSelect.Value) then
                             AddASite(pSite^.iKey,0);
                     end
                     else
                     begin
                          if (sField = 'IRREPL') then
                             rValue := pSite^.rIrreplaceability
                          else
                              if (sField = 'SUMIRR') then
                                 rValue := pSite^.rSummedIrr
                              else
                                  if (sField = 'WAVIRR') then
                                     rValue := pSite^.rWAVIRR
                                  else
                                      if (sField = 'PCCONTR') then
                                         rValue := pSite^.rPCUSED
                                      else
                                          if (sField = 'AREA') then
                                             rValue := pSite^.area
                                          else
                                              if (sField = '') then
                                                 rValue := pSite^.rSummedIrrVuln2
                                              else
                                                  rValue := rtnSubsetValue(sField,pSite,iSiteIndex);

                          {operator}
                          if (sOperator = 'Highest') then
                          begin
                               if (rTestValue = -1) then
                               begin
                                    rTestValue := rValue;
                                    iChosenKey := iKey;
                               end
                               else
                               begin
                                    if (rValue >= rTestValue) then
                                    begin
                                         rTestValue := rValue;
                                         iChosenKey := iKey;
                                    end;
                               end;
                          end
                          else
                          if (sOperator = 'Lowest') then
                          begin
                               if (rTestValue = -1) then
                               begin
                                    rTestValue := rValue;
                                    iChosenKey := iKey;
                               end
                               else
                               begin
                                    if (rValue <= rTestValue) then
                                    begin
                                         rTestValue := rValue;
                                         iChosenKey := iKey;
                                    end;
                               end;
                          end
                          else
                          begin
                               iChosenKey := -1;

                               if (sOperator = '=') then
                               begin
                                    if (rValue = rToMatchValue) then
                                       iChosenKey := iKey;
                               end
                               else
                               if (sOperator = '<>') then
                               begin
                                    if (rValue <> rToMatchValue) then
                                       iChosenKey := iKey;
                               end
                               else
                               if (sOperator = '>') then
                               begin
                                    if (rValue > rToMatchValue) then
                                       iChosenKey := iKey;
                               end
                               else
                               if (sOperator = '<') then
                               begin
                                    if (rValue < rToMatchValue) then
                                       iChosenKey := iKey;
                               end
                               else
                               if (sOperator = '>=') then
                               begin
                                    if (rValue >= rToMatchValue) then
                                       iChosenKey := iKey;
                               end
                               else
                               if (sOperator = '<=') then
                               begin
                                    if (rValue <= rToMatchValue) then
                                       iChosenKey := iKey;
                               end;

                               {iChosenKey is the site that has been selected}
                               if (iChosenKey <> -1) then
                                  AddASite(iChosenKey,rValue);
                          end;

                          if (iKey = iChosenKey)
                          and ((sOperator = 'Highest')
                               or (sOperator = 'Lowest')) then
                              AddASite(iChosenKey,rValue);
                     end;
                end;
           end
           else
           if (sField = 'First') then
              SelectFirstSites
           else
           begin
                {DatabaseVariable}
                if (lowercase(sField) = 'one') then
                begin
                     if (sOperator = 'Highest') then
                        AnalyseOneValues(True)
                     else
                         if (sOperator = 'Lowest') then
                            AnalyseOneValues(False);
                end
                else
                begin  
                     {we are choosing from SitesChosen}

                     {if operator <> (Highest or Lowest) then
                         ...
                         parse table and find highest value from one or more SitesChosen

                     else
                         execute SQL query to find resultant sites}

                     RulesForm.QueryTable.Open;
                     fEnd := False;
                     rTestValue := -1;

                     if (sValue <> '') then
                        rToMatchValue := RegionSafeStrToFloat(sValue);

                     repeat
                           {examine this element of the table if Key is in SitesChosen}
                           iKey := RulesForm.QueryTable.FieldByName(ControlRes^.sKeyField).AsInteger;

                           if IsInSitesChosen(iKey) then
                           begin
                                if (sField = 'First') then
                                begin
                                     {select first n sites from the list}
                                     if (iResultSites < MinsetExpertForm.SpinSelect.Value) then
                                        AddASite(iKey,0);
                                end
                                else
                                begin
                                     try
                                        rValue := RulesForm.QueryTable.FieldByName(sField).AsFloat;
                                     except
                                           rValue := 0;
                                     end;

                                     {now apply the operator for this field}
                                     {operator}
                                     iChosenKey := -1;
                                     if (sOperator = 'Highest') then
                                     begin
                                          if (rTestValue = -1) then
                                          begin
                                               rTestValue := rValue;
                                               iChosenKey := iKey;
                                          end
                                          else
                                          begin
                                               if (rValue >= rTestValue) then
                                               begin
                                                    rTestValue := rValue;
                                                    iChosenKey := iKey;
                                               end;
                                          end;
                                     end
                                     else
                                     if (sOperator = 'Lowest') then
                                     begin
                                          if (rTestValue = -1) then
                                          begin
                                               rTestValue := rValue;
                                               iChosenKey := iKey;
                                          end
                                          else
                                          begin
                                               if (rValue <= rTestValue) then
                                               begin
                                                    rTestValue := rValue;
                                                    iChosenKey := iKey;
                                               end;
                                          end;
                                     end
                                     else
                                     begin
                                          if (sOperator = '=') then
                                          begin
                                               if (rValue = rToMatchValue) then
                                                  iChosenKey := iKey;
                                          end
                                          else
                                          if (sOperator = '<>') then
                                          begin
                                               if (rValue <> rToMatchValue) then
                                                  iChosenKey := iKey;
                                          end
                                          else
                                          if (sOperator = '>') then
                                          begin
                                               if (rValue > rToMatchValue) then
                                                  iChosenKey := iKey;
                                          end
                                          else
                                          if (sOperator = '<') then
                                          begin
                                               if (rValue < rToMatchValue) then
                                                  iChosenKey := iKey;
                                          end
                                          else
                                          if (sOperator = '>=') then
                                          begin
                                               if (rValue >= rToMatchValue) then
                                                  iChosenKey := iKey;
                                          end
                                          else
                                          if (sOperator = '<=') then
                                          begin
                                               if (rValue <= rToMatchValue) then
                                                  iChosenKey := iKey;
                                          end;


                                          {iChosenKey is the site that has been selected}
                                          if (iChosenKey <> -1) then
                                             AddASite(iChosenKey,rValue);
                                     end;

                                     if (iKey = iChosenKey)
                                     and ((sOperator = 'Highest')
                                          or (sOperator = 'Lowest')) then
                                         AddASite(iChosenKey,rValue);
                                end;


                           end;

                           fEnd := RulesForm.QueryTable.EOF;
                           RulesForm.QueryTable.Next;

                     until fEnd;

                     RulesForm.QueryTable.Close;

                     {reparse array for Highest and Lowest and trim values that are not highest}
                     if (sOperator = 'Highest')
                     or (sOperator = 'Lowest') then
                        ReParseHiLoDB(rTestValue);
                end;
           end;

           dispose(pSite);

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in SelectRule',mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;
   end;

   procedure ArithmeticRule(const sStr1, sStr2 : string);
   var
      iRule : integer;

      function rtnRule(const s1,s2 : string) : integer;
      begin
           Result := 0;

           {richness
            features met
            feature rarity
            summed rarity
            contrib
            pccontrib
            rarcontrib
            weighted contrib
            weighted propcontrib
            weighted pccontrib}

           Result := 11;
           case s1[1] of
                'r' : case s1[2] of
                           'i' : Result := 1;
                           'a' : Result := 7;
                      end;
                'f' : case s2[1] of
                           'm' : Result := 2;
                           'r' : Result := 3;
                      end;
                's' : Result := 4;
                'c' : Result := 5;
                'p' : Result := 6;
                'w' : case s2[2] of
                           'o' : Result := 8;
                           'r' : Result := 9;
                           'c' : Result := 10;
                      end;
                'R' : Result := 12;  // RANDOM rule
           end;
      end;

   begin
        {}
        try
           if ControlRes^.fReportMinsetMemSize then
              AddMemoryReportRow('ArithmeticRule begin');

           iRule := rtnRule(sStr1,sStr2);

           if (not fComplementarity) then
              SetNoComplementarityTargets;

           RunArithmeticRule(iRule,
                             iSelectionsPerIteration,
                             SitesChosen,
                             ResultSites,
                             (MinsetExpertForm.CheckExtraDetail.Checked or
                             ControlRes^.fGenerateCompRpt),
                             MinsetExpertForm.CheckEnableDestruction.Checked,
                             MinsetExpertForm.CheckEnableComplementarity.Checked,
                             fRecalculateComplementarity,
                             iCurrentIteration);
           iResultSites := ResultSites.lMaxSize;

           if (not fComplementarity) then
              UnSetNoComplementarityTargets;

           {run Arithmetic Minset Rule

            SitesChosen  source sites
            ResultSites  destination dites}

           if ControlRes^.fReportMinsetMemSize then
              AddMemoryReportRow('ArithmeticRule end');

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in ArithmeticRule',mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;
   end;


begin
     {apply rule to SitesChosen then
      store result of the rule in
      SitesChosen}

     if ControlRes^.fReportMinsetMemSize then
        AddMemoryReportRow('ApplyRule begin');

     Result := False;

     try
        iResultSites := 0;
        try
           ResultSites := Array_t.Create;
           ResultSites.init(SizeOf(integer),ARR_STEP_SIZE);
        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in ResultSites.init',mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('ApplyRule after ResultSites init');

        if (sType = 'Select') then
        begin
             SelectRule;

             if (SitesChosen.lMaxSize > 0) then // We need to fall gracefully out of the loop if SitesChosen.lMaxSize = 0
             begin
                  fAdjProxArithOnly := False;

                  if ControlRes^.fReportMinsetMemSize then
                     AddMemoryReportRow('ApplyRule after SelectRule');

                  // debug arithmetic rule here if applicable
                  OutputArithmeticRule(SitesChosen,
                                       (MinsetExpertForm.CheckExtraDetail.Checked or
                                       ControlRes^.fGenerateCompRpt));

                  if ControlRes^.fReportMinsetMemSize then
                     AddMemoryReportRow('ApplyRule after OutputArithmeticRule');
             end;
        end
        else
        begin
             ArithmeticRule(sType,sField);

             if ControlRes^.fReportMinsetMemSize then
                AddMemoryReportRow('ApplyRule after ArithmeticRule');
        end;
        {add site selection code for other rules here
         and declare core methods above as sub-procedures}

        if (SitesChosen.lMaxSize > 0) then // We need to fall gracefully out of the loop if SitesChosen.lMaxSize = 0
        begin
             {if result is 0 sites, then make result original SitesChosen}
             if (iResultSites > 0) then
             begin
                  Result := True;

                  {copy ResultSites to SitesChosen}
                  if (SitesChosen.lMaxSize <> iResultSites) then
                     SitesChosen.resize(iResultSites);

                  new(pSite);
                  for iCount := 1 to iResultSites do
                  begin
                       ResultSites.rtnValue(iCount,@iKey);
                       SitesChosen.setValue(iCount,@iKey);
                  end;
                  dispose(pSite);
             end
             else
             begin
                  {we may have to select no sites}
                  SitesChosen.lMaxSize := 0;
             end;
             {else the SitesChosen are already correct, because this rule returns
              0 sites.}

             if ControlRes^.fReportMinsetMemSize then
                AddMemoryReportRow('ApplyRule after update SitesChosen');

             ResultSites.Destroy;
        end;

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('ApplyRule end');

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ApplyRule',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure UpdateDatabaseGIS;
begin
     try
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

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in UpdateDatabaseGIS',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure MinsetSelectSites(SitesChosen : Array_t;
                            const fComplementarity : boolean;
                            var rAreaOfSitesChosen : extended);
var
   iCount, iCount2, iSiteKey, iSiteIndex,
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
   rVegetatedArea : extended;
   pSite : sitepointer;
   rRegionResYear : extended;
   sSitesRegionName, sSearchRegionName : str255;
   iRegionIndex : integer;
   RegionLogFile : TextFile;
begin
     {select SitesChosen using iMinsetFlag}
     try
        new(pSite);
        rAreaOfSitesChosen := 0;
        for iCount := 1 to SitesChosen.lMaxSize do
        begin
             // increment rTotalVegetatedArea
             SitesChosen.rtnValue(iCount,@iSiteKey);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
             VegArea.rtnValue(iSiteIndex,@rVegetatedArea);

             rTotalVegetatedArea := rTotalVegetatedArea + rVegetatedArea;

             // update area of sites chosen
             SiteArr.rtnValue(iSiteIndex,pSite);
             rAreaOfSitesChosen := rAreaOfSitesChosen + pSite^.area;

             // update area of RegionResYear
             if MinsetExpertForm.CheckReAllocate.Checked then
             begin
                  // return the region name of this site
                  RegionField.rtnValue(iSiteIndex,@sSitesRegionName);
                  iRegionIndex := 0;
                  // find the index of the region
                  for iCount2 := 1 to iRegionCount do
                  begin
                       RegionName.rtnValue(iCount2,@sSearchRegionName);
                       if (sSitesRegionName = sSearchRegionName) then
                          iRegionIndex := iCount2;
                  end;

                  if (iRegionIndex > 0) then
                  begin
                       // increment the region res year of the region this site is from
                       RegionResYear.rtnValue(iRegionIndex,@rRegionResYear);
                       rRegionResYear := rRegionResYear + pSite^.area;
                       RegionResYear.setValue(iRegionIndex,@rRegionResYear);
                  end
                  else
                      rRegionResYear := 0;

                  assignfile(RegionLogFile,ControlRes^.sWorkingDirectory + '\RegionLogFile.csv');
                  append(RegionLogFile);
                  writeln(RegionLogFile,IntToStr(ControlRes^.iSimulationYear) + ',' + sSitesRegionName + ',' + IntToStr(iSiteKey) + ',' + FloatToStr(rRegionResYear));
                  closefile(RegionLogFile);
             end;
        end;

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('MinsetSelectSites before Arr2Highlight');

        Arr2Highlight(SitesChosen,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('MinsetSelectSites after Arr2Highlight and before MoveGroup');

        with ControlForm do
             case iMinsetFlag of
                  MINSET_LOOKUP,
                  MINSET_MAP,
                  MINSET_ADD_TO_MAP, {Lookup, Map, Add to Map sites are selected to negotiated
                                      as they are chosen, then the log is rewound to get the list
                                      of sites selected}
                  MINSET_R1 : MoveGroup(Available,AvailableKey,
                                        R1,R1Key,
                                        FALSE,fComplementarity);
                  MINSET_R2 : MoveGroup(Available,AvailableKey,
                                        R2,R2Key,
                                        FALSE,fComplementarity);
                  MINSET_R3 : MoveGroup(Available,AvailableKey,
                                        R3,R3Key,
                                        FALSE,fComplementarity);
                  MINSET_R4 : MoveGroup(Available,AvailableKey,
                                        R4,R4Key,
                                        FALSE,fComplementarity);
                  MINSET_R5 : MoveGroup(Available,AvailableKey,
                                        R5,R5Key,
                                        FALSE,fComplementarity);
                  MINSET_UNR1 : MoveGroup(R1,R1Key,
                                          Available,AvailableKey,
                                          FALSE,True);
                  MINSET_UNR2 : MoveGroup(R2,R2Key,
                                          Available,AvailableKey,
                                          FALSE,True);
                  MINSET_UNR3 : MoveGroup(R3,R3Key,
                                          Available,AvailableKey,
                                          FALSE,True);
                  MINSET_UNR4 : MoveGroup(R4,R4Key,
                                          Available,AvailableKey,
                                          FALSE,True);
                  MINSET_UNR5 : MoveGroup(R5,R5Key,
                                          Available,AvailableKey,
                                          FALSE,True);
                  MINSET_UNPAR : MoveGroup(Partial,PartialKey,
                                           Available,AvailableKey,
                                           FALSE,True);
                  MINSET_UNR1R2R3R4R5 :
                  begin
                       MoveGroup(R1,R1Key,
                                 Available,AvailableKey,
                                 FALSE,True);
                       MoveGroup(R2,R2Key,
                                 Available,AvailableKey,
                                 FALSE,True);
                       MoveGroup(R3,R3Key,
                                 Available,AvailableKey,
                                 FALSE,True);
                       MoveGroup(R4,R4Key,
                                 Available,AvailableKey,
                                 FALSE,True);
                       MoveGroup(R5,R5Key,
                                 Available,AvailableKey,
                                 FALSE,True);
                  end;
                  MINSET_UNR1R2R3R4R5PD :
                  begin
                       MoveGroup(R1,R1Key,
                                 Available,AvailableKey,
                                 FALSE,True);
                       MoveGroup(R2,R2Key,
                                 Available,AvailableKey,
                                 FALSE,True);
                       MoveGroup(R3,R3Key,
                                 Available,AvailableKey,
                                 FALSE,True);
                       MoveGroup(R4,R4Key,
                                 Available,AvailableKey,
                                 FALSE,True);
                       MoveGroup(R5,R5Key,
                                 Available,AvailableKey,
                                 FALSE,True);
                       MoveGroup(Partial,PartialKey,
                                 Available,AvailableKey,
                                 FALSE,True);
                  end;
             end;

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('MinsetSelectSites after MoveGroup');
        dispose(pSite);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in MinsetSelectSites',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TRulesForm.FormResize(Sender: TObject);
begin
     MultiPanel.Width := ClientWidth;
     Panel1.Width := ClientWidth;
     RuleBox.Height := ClientHeight - (Panel1.Top + Panel1.Height);
end;

procedure TRulesForm.FormCreate(Sender: TObject);
var
   iCount : integer;
begin
     try
        ClientWidth := Panel1.Width;
        ClientHeight := Panel1.Top + (2 * Panel1.Height);

        fFeatureCompletelyDestroyed := False;

        // create the MinsetExpertForm
        MinsetExpertForm := TMinsetExpertForm.Create(Application);

        ClassesToTest[1] := False;
        ClassesToTest[2] := False;
        ClassesToTest[3] := False;
        ClassesToTest[4] := False;
        ClassesToTest[5] := False;
        ClassesToTest[6] := False;
        ClassesToTest[7] := False;
        ClassesToTest[8] := False;
        ClassesToTest[9] := False;
        ClassesToTest[10] := False;                                    

        fClicking := False;

        VariableBox.Items.Add('SUM_V2');

        // add summed irreplaceability weightings if we are using them
        if ControlRes^.fCalculateAllVariations then
        begin
             VariableBox.Items.Add('SUM_PA');
             VariableBox.Items.Add('SUM_IT');
             VariableBox.Items.Add('SUM_VU');
             VariableBox.Items.Add('SUM_PAIT');
             VariableBox.Items.Add('SUM_PAVU');
             VariableBox.Items.Add('SUM_ITVU');              
             VariableBox.Items.Add('SUM_PAITVU');
        end;

        if ControlRes^.fCalculateBobsExtraVariations then
        begin
             VariableBox.Items.Add('SUM_CR');
             VariableBox.Items.Add('SUM_PT');
             VariableBox.Items.Add('SUM_CRIT');
             VariableBox.Items.Add('SUM_CRVU');
             VariableBox.Items.Add('SUM_CRITVU');
             VariableBox.Items.Add('SUM_SA');
             VariableBox.Items.Add('SUM_SAPA');
             VariableBox.Items.Add('SUM_SAPT');
             VariableBox.Items.Add('SUM_PAPT');
        end;

        {add subset irreplaceability fields if we are using subsets}
        if ControlRes^.fFeatureClassesApplied then
        begin
             for iCount := 1 to 10 do
                 if ControlRes^.ClassDetail[iCount] then
                 begin
                      // UserSubsetChoices
                      if UserSubsetChoices._first[iCount].fIrr then
                         VariableBox.Items.Add('IRR' + IntToStr(iCount));
                      if UserSubsetChoices._first[iCount].fSum then
                         VariableBox.Items.Add('SUM' + IntToStr(iCount));
                      if (iCount <= 5) then
                      begin
                           if UserSubsetChoices._second[iCount].fWav then
                              VariableBox.Items.Add('WAV' + IntToStr(iCount));
                           if UserSubsetChoices._second[iCount].fPC then
                              VariableBox.Items.Add('PC' + IntToStr(iCount));
                      end;
                 end;
        end;

        {add resource fields to VariableBox}
        try
           ChooseResForm := TChooseResForm.Create(Application);

           if (ChooseResForm.CResBox.Items.Count > 0) then
           begin
                for iCount := 0 to (ChooseResForm.CResBox.Items.Count-1) do
                    VariableBox.Items.Add(ChooseResForm.CResBox.Items.Strings[iCount]);

                MinsetExpertForm.ComboResource.Items := ChooseResForm.CResBox.Items;
                MinsetExpertForm.ComboResource.Text := MinsetExpertForm.ComboResource.Items.Strings[0];
                MinsetExpertForm.ComboBox1.Items := ChooseResForm.CResBox.Items;
                MinsetExpertForm.ComboBox1.Text := MinsetExpertForm.ComboResource.Items.Strings[0];
           end
           else
           begin
                {there are no resource fields}
                MinsetExpertForm.GroupBox2.Enabled := False;
                MinsetExpertForm.checkResourceLimit.Enabled := False;
                MinsetExpertForm.SpinResource.Enabled := False;
                MinsetExpertForm.ComboResource.Enabled := False;
           end;

        finally
               ChooseResForm.Free;
        end;

        {set caption and minset-type dependant starting conditions}
        MinsetExpertForm.SpinIter.MinValue := 1;
        case iMinsetFlag of
             MINSET_R1 :
             begin
                  Caption := 'Minset - Select Sites As '+ControlRes^.sR1Label;
                  MinsetExpertForm.SpinIter.MaxValue := ControlForm.Available.Items.Count +
                                       ControlForm.Flagged.Items.Count;
             end;
             MINSET_R2 :
             begin
                  Caption := 'Minset - Select Sites As '+ControlRes^.sR2Label;
                  MinsetExpertForm.SpinIter.MaxValue := ControlForm.Available.Items.Count +
                                       ControlForm.Flagged.Items.Count;
             end;
             MINSET_R3 :
             begin
                  Caption := 'Minset - Select Sites As '+ControlRes^.sR3Label;
                  MinsetExpertForm.SpinIter.MaxValue := ControlForm.Available.Items.Count +
                                       ControlForm.Flagged.Items.Count;
             end;
             MINSET_R4 :
             begin
                  Caption := 'Minset - Select Sites As '+ControlRes^.sR4Label;
                  MinsetExpertForm.SpinIter.MaxValue := ControlForm.Available.Items.Count +
                                       ControlForm.Flagged.Items.Count;
             end;
             MINSET_R5 :
             begin
                  Caption := 'Minset - Select Sites As '+ControlRes^.sR5Label;
                  MinsetExpertForm.SpinIter.MaxValue := ControlForm.Available.Items.Count +
                                       ControlForm.Flagged.Items.Count;
             end;
             MINSET_UNR1 :
             begin
                  Caption := 'Minset - DeSelect '+ControlRes^.sR1Label+' Sites';
                  MinsetExpertForm.SpinIter.MaxValue := ControlForm.R1.Items.Count;
             end;
             MINSET_UNR2 :
             begin
                  Caption := 'Minset - DeSelect '+ControlRes^.sR2Label+' Sites';
                  MinsetExpertForm.SpinIter.MaxValue := ControlForm.R2.Items.Count;
             end;
             MINSET_UNR3 :
             begin
                  Caption := 'Minset - DeSelect '+ControlRes^.sR3Label+' Sites';
                  MinsetExpertForm.SpinIter.MaxValue := ControlForm.R3.Items.Count;
             end;
             MINSET_UNR4 :
             begin
                  Caption := 'Minset - DeSelect '+ControlRes^.sR4Label+' Sites';
                  MinsetExpertForm.SpinIter.MaxValue := ControlForm.R4.Items.Count;
             end;
             MINSET_UNR5 :
             begin
                  Caption := 'Minset - DeSelect '+ControlRes^.sR5Label+' Sites';
                  MinsetExpertForm.SpinIter.MaxValue := ControlForm.R5.Items.Count;
             end;
             MINSET_UNPAR :
             begin
                  Caption := 'Minset - DeSelect Partially Deferred Sites';
                  MinsetExpertForm.SpinIter.MaxValue := ControlForm.Partial.Items.Count;
             end;
             MINSET_UNR1R2R3R4R5 :
             begin
                  Caption := 'Minset - DeSelect '+ControlRes^.sR1Label+', '+ControlRes^.sR2Label+', '+
                             ControlRes^.sR3Label + ', ' + ControlRes^.sR4Label + ' and ' +
                             ControlRes^.sR5Label + ' Sites';
                  MinsetExpertForm.SpinIter.MaxValue := ControlForm.R1.Items.Count +
                                                        ControlForm.R2.Items.Count +
                                                        ControlForm.R3.Items.Count +
                                                        ControlForm.R4.Items.Count +
                                                        ControlForm.R5.Items.Count;
             end;
             MINSET_UNR1R2R3R4R5PD :
             begin
                  Caption := 'Minset - DeSelect '+ControlRes^.sR1Label+', '+ControlRes^.sR2Label+', '+
                             ControlRes^.sR3Label + ', ' + ControlRes^.sR4Label + ', ' +
                             ControlRes^.sR5Label + ' and Partial Sites';
                  MinsetExpertForm.SpinIter.MaxValue := ControlForm.R1.Items.Count +
                                                        ControlForm.R2.Items.Count +
                                                        ControlForm.R3.Items.Count +
                                                        ControlForm.R4.Items.Count +
                                                        ControlForm.R5.Items.Count +
                                                        ControlForm.Partial.Items.Count;
             end;
             MINSET_LOOKUP :
             begin
                  Caption := 'Minset - Lookup Sites';
                  MinsetExpertForm.SpinIter.MaxValue := iSiteCount;
             end;
             MINSET_MAP :
             begin
                  Caption := 'Minset - Map Sites';
                  MinsetExpertForm.SpinIter.MaxValue := iSiteCount;
             end;
             MINSET_ADD_TO_MAP :
             begin
                  Caption := 'Minset - Add Sites to Map';
                  MinsetExpertForm.SpinIter.MaxValue := iSiteCount;
             end;
        end;

        if (MinsetExpertForm.SpinIter.MaxValue < MinsetExpertForm.SpinIter.Value) then
           MinsetExpertForm.SpinIter.Value := MinsetExpertForm.SpinIter.MaxValue;

        QueryTable.DatabaseName := ControlRes^.sDatabase;
        QueryTable.TableName := ControlRes^.sSiteSummaryTable;
        SQLQuery.DatabaseName := ControlRes^.sDatabase;

        VariableBox.ItemIndex := 1;

        //ClientWidth := Panel1.Width;
        Panel1.Width := ClientWidth;
        ClientHeight := Panel1.Top + Panel1.Height + 90 {90 pixels for RulesBox};

        // add adjacency and proximity to the rule list if we are connected to ArcView
        {if (ControlRes^.GISLink = ArcView) then
        begin
             VariableBox.Items.Insert(8,'Proximity');
             VariableBox.Items.Insert(8,'Adjacency');
        end;}

        iNumberOfMinsets := 1;
        iCurrentMinset := 1;

        if not ControlRes^.fShowExtraTools then
        begin
             // make the multiple minset editor invisible
             MultiPanel.Visible := False;
             Panel1.Top := MultiPanel.Top;
             RuleBox.Height := RuleBox.Height + MultiPanel.Height;
        end;

        if ControlRes^.fLoadSiteVuln then
           VariableBox.Items.Add('Site Vulnerability');

        if ControlRes^.fLoadSiteCost then
           VariableBox.Items.Add('Site Cost');

        if ControlRes^.fLoadSiteVuln and ControlRes^.fLoadSiteCost then
           VariableBox.Items.Add('S * V / C');

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TRulesForm.FormCreate',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function rtnFieldIndex(const sName : string;
                       TheTable : TTable) : integer;
var
   iCount : integer;
begin
     Result := -1;
     for iCount := 0 to (TheTable.FieldCount-1) do
         if (sName = TheTable.FieldDefs.Items[iCount].Name) then
            Result := iCount;
end;

procedure TRulesForm.VariableBoxClick(Sender: TObject);
var
   iCount, iBoxLen, iPercentage : integer;
   fFinished : boolean;
   sTmp : string;
begin
     try
        iBoxLen := VariableBox.Items.Count;
        fFinished := False;

        SpinDistance.Visible := False;
        Label3.Visible := False;

        if checkLoadValues.Checked then
           for iCount := 1 to iBoxLen do
               if VariableBox.Selected[iCount-1] then
               begin
                  if (iCount > 8)
                  and (iCount <= 19) then
                  begin
                       fFinished := True;

                       if (VariableBox.Items.Strings[iCount-1] = 'Proximity') then
                          if (iCount = 10) then
                          begin
                               {need to edit proximity distance}
                               SpinDistance.Visible := True;
                               EditRuleForm.Caption := 'Enter Proximity Distance';
                               Label3.Visible := True;
                          end;
                  end
                  else
                  begin
                       QueryTable.Open;
                       try
                          CurrentFieldType := QueryTable.FieldDefs.Items[iCount-1].DataType;
                       except
                             CurrentFieldType := QueryTable.FieldDefs.Items[rtnFieldIndex(VariableBox.Items.Strings[iCount-1],QueryTable)].DataType;
                       end;
                       QueryTable.Close;
                       LoadValues(VariableBox.Items[iCount-1]);
                  end;
               end;

        if fFinished then
        begin
             OperatorGroup.Visible := False;
             ValueBox.Visible := False;
             Label2.Visible := False;
             checkLoadValues.Visible := False;
             checkSortValues.Visible := False;
        end
        else
        begin
             if (OperatorGroup.ItemIndex > 7) then
             begin
                  // operator is top or bottom X%
                  OperatorGroup.Visible := True;
                  SpinDistance.Visible := True;
                  Label3.Visible := True;
                  Label3.Caption := 'Specify Percentage';
                  if (OperatorGroup.ItemIndex = 8) then
                  begin
                       // top X%
                       sTmp := OperatorGroup.Items.Strings[8];
                       try
                          // 9th character to length-1 character
                          iPercentage := StrToInt(Copy(sTmp,9,Length(sTmp)-9));
                       except
                       end;
                  end
                  else
                  begin
                       // bottom X%
                       sTmp := OperatorGroup.Items.Strings[9];
                       try
                          // 9th character to length-1 character
                          iPercentage := StrToInt(Copy(sTmp,8,Length(sTmp)-8));
                       except
                       end;
                  end;
                  SpinDistance.Value := iPercentage;
             end
             else
             begin
                  OperatorGroup.Visible := True;
                  ValueBox.Visible := True;
                  Label2.Visible := True;
                  checkLoadValues.Visible := True;
                  checkSortValues.Visible := True;

                  if (OperatorGroup.ItemIndex > 1) then
                  begin
                       Label2.Enabled := True;
                       ValueBox.Enabled := True;

                       fClicking := True;
                       checkLoadValues.Enabled := True;
                       checkSortValues.Enabled := True;

                       {load and sort the values and output
                        max to ValueBox.Text and Descending order in ValueBox.Items}
                  end
                  else
                  begin
                       Label2.Enabled := False;
                       ValueBox.Enabled := False;
                       ValueBox.Text := '';
                       ValueBox.Items.Clear;

                       fClicking := True;
                       checkLoadValues.Enabled := False;
                       checkSortValues.Enabled := False;
                  end;
             end;
        end;

        fClicking := False;

     except
           Screen.Cursor := crDefault;
           if (MessageDlg('Values are not available.  Recalculate them?',mtConfirmation,[mbYes,mbNo],0) = mrYes) then
           begin
                ExecuteIrreplaceability(-1,False,False,True,True,'');
                VariableBoxClick(Sender);
           end;
     end;
end;

procedure TRulesForm.checkLoadValuesClick(Sender: TObject);
begin
     {checkSortValues.Enabled := checkLoadValues.Checked;}
     ValueBox.Items.Clear;
     ValueBox.Text := '';

     if not fClicking then
        VariableBoxClick(self);
end;

procedure TRulesForm.checkSortValuesClick(Sender: TObject);
begin
     if not fClicking then
        VariableBoxClick(self);
end;

procedure TRulesForm.RuleBoxDblClick(Sender: TObject);
begin
     btnEditClick(self);
end;

procedure TRulesForm.FormKeyPress(Sender: TObject; var Key: Char);
var
   fTrace : boolean;
begin
     fTrace := True;
end;

procedure TRulesForm.btnExecuteClick(Sender: TObject);
var
   fExecute : boolean;
   wDialogResult : word;
   sOldFeatureTargetField : string;
begin
     if (RuleBox.Items.Count > 1) then
     begin
          // see if there is more than 1 minset,
          // if there is, ask user if they want to run multiple minset instead
          fExecute := True;
          if (iNumberOfMinsets > 1) then
          begin
               wDialogResult := MessageDlg('There are ' + IntToStr(iNumberOfMinsets) +
                                           ' minsets specified. ' + Chr(10) + Chr(13) +
                                           'Do you want to execute a sequence of minsets instead?',
                                           mtConfirmation,[mbYes,mbNo],0);
               if (wDialogResult = mrYes) then
               begin
                    fExecute := False;
                    btnExecuteMinsetsClick(Sender);
               end;
          end;

          // We need to see if any rules are used which may select
          // zero sites.  If so, ask user what they want to do in
          // this case.
          if fExecute then
             if ScanRuleList then
             begin
                  // apply tgt field at minset start
                  sOldFeatureTargetField := '';
                  if ControlForm.UseFeatCutOffs.Checked
                  and (MinsetExpertForm.TgtField.Text <> ControlRes^.sFeatureTargetField) then
                  begin
                       sOldFeatureTargetField := ControlRes^.sFeatureTargetField;
                       ControlForm.ChangeTargetField(MinsetExpertForm.TgtField.Text);
                  end;

                  fAdjProxArithOnly := True;

                  SaveMinsetSpecification(rtnUniqueFileName(ControlRes^.sWorkingDirectory + '\minset','mst'));

                  ExecuteMinset(False,MinsetExpertForm.CheckExtraDetail.Checked or ControlRes^.fGenerateCompRpt,True);

                  // restore old tgt field after minset run
                  if (sOldFeatureTargetField <> '') then
                     ControlForm.ChangeTargetField(sOldFeatureTargetField);
                  ModalResult := mrOk;
             end;
     end;
end;

procedure TRulesForm.btnStopThreadClick(Sender: TObject);
begin
     StopMinsetForm := TStopMinsetForm.Create(Application);
     StopMinsetForm.Show;
     MinsetThread.Terminate;
end;

procedure TRulesForm.BitBtn1Click(Sender: TObject);
begin
     findadjacentsites('d:\minset\x.txt','d:\minset\out.txt','');
end;

procedure TRulesForm.AdjacencyTimerTimer(Sender: TObject);
begin
     // check if the adjacency run sync file has been created yet
     if FileExists(ControlRes^.sWorkingDirectory + '\adj_sync.txt') then
     begin
          AdjacencyTimer.Enabled := False;

          // process the adjacency result
     end;
end;

procedure TRulesForm.ProximityTimerTimer(Sender: TObject);
begin
     // check if the proximity run sync file has been created yet
     if FileExists(ControlRes^.sWorkingDirectory + '\pro_sync.txt') then
     begin
          ProximityTimer.Enabled := False;

          // process the proximity result
     end;
end;


procedure TRulesForm.btnOptionsClick(Sender: TObject);
begin
     // view the Minset Options form
     MinsetExpertForm.ShowModal;
end;

procedure TRulesForm.FormDestroy(Sender: TObject);
begin
     // destroy the MinsetExpertForm
     MinsetExpertForm.Destroy;
end;

function TRulesForm.ScanRuleList : boolean;
var
   iCount : integer;
   fResult : boolean;

   procedure TestCell(sCell : string);
   begin
        if (Pos('Adjacency',sCell) > -1) then
           fResult := False;
        if (Pos('Proximity',sCell) > -1) then
           fResult := False;
        if (Pos('=',sCell) > -1) then
           fResult := False;
        if (Pos('<>',sCell) > -1) then
           fResult := False;
        if (Pos('>',sCell) > -1) then
           fResult := False;
        if (Pos('<',sCell) > -1) then
           fResult := False;
        if (Pos('>=',sCell) > -1) then
           fResult := False;
        if (Pos('<=',sCell) > -1) then
           fResult := False;
   end;

begin
     // scan the rule list
     // We need to see if any rules are used which may select
     // zero sites.  If so, ask user what they want to do in
     // this case.

     try (*
        fResult := True;

        if (RuleBox.Items.Count > 1) then
           for iCount := 1 to RuleBox.Items.Count do
           begin
                // test RuleBox.Items.Strings[iCount]
                TestCell(RuleBox.Items.Strings[iCount]);
                {
                   items to look for :
                         Adjacency
                         Proximity
                         =
                         <>
                         >
                         <
                         >=
                         <=

                   These are the rules which may result in zero sites
                }
           end;

        Result := fResult;
         *)

        Result := True;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TRulesForm.ScanRuleList',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TRulesForm.btnLoadSpecClick(Sender: TObject);
begin
     // load sequence of minsets
     if (OpenSequenceDialog.InitialDir = '') then
        OpenSequenceDialog.InitialDir := ControlRes^.sWorkingDirectory
     else
         OpenSequenceDialog.InitialDir := ExtractFilePath(OpenSequenceDialog.Filename);

     if OpenSequenceDialog.Execute then
        LoadSequence(OpenSequenceDialog.Filename);
end;

procedure TRulesForm.btnSaveSpecClick(Sender: TObject);
begin
     // save sequence of minsets
     if (SaveSequenceDialog.InitialDir = '') then
     begin
          SaveSequenceDialog.InitialDir := ControlRes^.sWorkingDirectory;
          SaveSequenceDialog.Filename := 'sample.seq';
     end
     else
     begin
          SaveSequenceDialog.InitialDir := ExtractFilePath(SaveSequenceDialog.Filename);
          SaveSequenceDialog.Filename := ExtractFileName(SaveSequenceDialog.Filename);
     end;

     if SaveSequenceDialog.Execute then
        SaveSequence(SaveSequenceDialog.Filename);
end;
procedure TRulesForm.LoadSequence(const sFilename : string);
var
   iCount, iMinset : integer;
   OutFile, InFile : TextFile;
   fStopOut, fStopIn : boolean;
   sLine : string;
begin
     try
        // first, delete the existing sequence if we have one
        if (iNumberOfMinsets > 1) then
           for iCount := 1 to iNumberOfMinsets do
               if (iCount <> iCurrentMinset) then
                  DeleteFile(ControlRes^.sDatabase + '\' + IntToStr(iCount) + '_temp.min');

        // load a sequence of minsets from a file
        assignfile(InFile,sFilename);
        reset(InFile);
        iMinset := 1;

        assignfile(OutFile,ControlRes^.sDatabase + '\1_temp.min');
        rewrite(OutFile);

        repeat
              fStopIn := Eof(InFile);
              readln(InFile,sLine);

              if (sLine = EMS_SEPARATOR) then
              begin
                   closefile(OutFile);
                   Inc(iMinset);
                   assignfile(OutFile,ControlRes^.sDatabase + '\' + IntToStr(iMinset) + '_temp.min');
                   rewrite(OutFile);
              end
              else
                  writeln(OutFile,sLine);

        until fStopIn;

        closefile(OutFile);
        closefile(InFile);

        iNumberOfMinsets := iMinset;
        iCurrentMinset := 1;
        LoadMinsetSpecification(ControlRes^.sDatabase + '\1_temp.min');
        DeleteFile(ControlRes^.sDatabase + '\1_temp.min');

        // update label and combo list
        lblOf.Caption := 'of ' + IntToStr(iNumberOfMinsets);
        ComboOf.Items.Clear;
        for iCount := 1 to iNumberOfMinsets do
            ComboOf.Items.Add(IntToStr(iCount));
        ComboOf.Text := '1';

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadSequence ' + sFilename,
                      mtError,[mbOk],0);
     end;
end;

procedure TRulesForm.SaveSequence(const sFilename : string);
var
   iCount : integer;
   OutFile, InFile : TextFile;
   fStop : boolean;
   sLine : string;
begin
     try
        // save a sequence of minsets to a file
        assignfile(OutFile,sFilename);
        rewrite(OutFile);

        SaveMinsetSpecification(ControlRes^.sDatabase + '\' + IntToStr(iCurrentMinset) + '_temp.min');

        for iCount := 1 to iNumberOfMinsets do
        begin
             // write contents of minset file to sequence file
             assignfile(InFile,ControlRes^.sDatabase + '\' + IntToStr(iCount) + '_temp.min');
             reset(InFile);
             repeat
                   fStop := Eof(InFile);

                   readln(InFile,sLine);
                   writeln(OutFile,sLine);

             until fStop;
             closefile(InFile);

             if (iCount <> iNumberOfMinsets) then
                // write seperator to file
                writeln(OutFile,EMS_SEPARATOR);
        end;

        DeleteFile(ControlRes^.sDatabase + '\' + IntToStr(iCurrentMinset) + '_temp.min');

        closefile(OutFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in SaveSequence ' + sFilename,
                      mtError,[mbOk],0);
     end;
end;

procedure TRulesForm.btnCloneClick(Sender: TObject);
var
   iCount : integer;
begin
     try
        if (iCurrentMinset < iNumberOfMinsets) then
           // rename temporary minset files to make a place for the clone
           for iCount := iNumberOfMinsets downto (iCurrentMinset + 1) do
               RenameFile(ControlRes^.sDatabase + '\' + IntToStr(iCount) + '_temp.min',
                          ControlRes^.sDatabase + '\' + IntToStr(iCount + 1) + '_temp.min');

        // save the current minset to a file to 'clone' it
        SaveMinsetSpecification(ControlRes^.sDatabase + '\' + IntToStr(iCurrentMinset + 1) + '_temp.min');

        // increment the number of active minsets
        Inc(iNumberOfMinsets);

        // update label and combo list
        lblOf.Caption := 'of ' + IntToStr(iNumberOfMinsets);
        ComboOf.Items.Clear;
        for iCount := 1 to iNumberOfMinsets do
            ComboOf.Items.Add(IntToStr(iCount));
        ComboOf.Text := IntToStr(iCurrentMinset);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Clone',
                      mtError,[mbOk],0);
     end;
end;

procedure TRulesForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
   iCount : integer;
begin
     try
        // remove temporary minset files if they have been created
        for iCount := 1 to iNumberOfMinsets do
            if (iCount <> iCurrentMinset) then
               DeleteFile(ControlRes^.sDatabase + '\' + IntToStr(iCount) + '_temp.min');

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in FormClose',
                      mtError,[mbOk],0);
     end;
end;

procedure TRulesForm.MoveToMinset(const iMinsetToMoveTo : integer);
begin
     // move to another minset
     if (iMinsetToMoveTo <> iCurrentMinset)
     and (iMinsetToMoveTo > 0)
     and (iMinsetToMoveTo <= iNumberOfMinsets) then
     begin
          // save the current minset
          SaveMinsetSpecification(ControlRes^.sDatabase + '\' + IntToStr(iCurrentMinset) + '_temp.min');
          // load the new minset
          LoadMinsetSpecification(ControlRes^.sDatabase + '\' + IntToStr(iMinsetToMoveTo) + '_temp.min');
          // remove the new minset from disk
          DeleteFile(ControlRes^.sDatabase + '\' + IntToStr(iMinsetToMoveTo) + '_temp.min');

          iCurrentMinset := iMinsetToMoveTo;
          // update label and combo list
          lblOf.Caption := 'of ' + IntToStr(iNumberOfMinsets);
          ComboOf.Text := IntToStr(iCurrentMinset);
     end;
end;

procedure TRulesForm.ComboOfChange(Sender: TObject);
var
   iToMoveTo : integer;
begin
     // combo change event
     try
        iToMoveTo := StrToInt(ComboOf.Text);;

        MoveToMinset(iToMoveTo);

     except
           ComboOf.Text := IntToStr(iCurrentMinset);
     end;
end;

procedure TRulesForm.DeleteCurrentMinset;
var
   iCount : integer;
begin
     // delete the current minset, if we have more than one
     if (iNumberOfMinsets > 1) then
     begin
          //
          if (iCurrentMinset = iNumberOfMinsets) then
          begin
               LoadMinsetSpecification(ControlRes^.sDatabase + '\' + IntToStr(iCurrentMinset-1) + '_temp.min');
               DeleteFile(ControlRes^.sDatabase + '\' + IntToStr(iCurrentMinset-1) + '_temp.min');
               Dec(iCurrentMinset);
          end
          else
          begin
               LoadMinsetSpecification(ControlRes^.sDatabase + '\' + IntToStr(iCurrentMinset+1) + '_temp.min');
               DeleteFile(ControlRes^.sDatabase + '\' + IntToStr(iCurrentMinset+1) + '_temp.min');
               // shuffle files from (iCurrentMinset+1) to iNumberOfMinsets
               for iCount := (iCurrentMinset+1) to iNumberOfMinsets do
                   // OldName  iCount
                   // NewName  iCount-1
                   RenameFile(ControlRes^.sDatabase + '\' + IntToStr(iCount) + '_temp.min',
                              ControlRes^.sDatabase + '\' + IntToStr(iCount-1) + '_temp.min');
          end;
          Dec(iNumberOfMinsets);
          // update label and combo list
          lblOf.Caption := 'of ' + IntToStr(iNumberOfMinsets);
          ComboOf.Text := IntToStr(iCurrentMinset);
     end;
end;

procedure TRulesForm.btnDeleteMinsetClick(Sender: TObject);
begin
     DeleteCurrentMinset;
end;

procedure TRulesForm.btnExecuteMinsetsClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        RulesForm.Visible := False;
        ControlForm.Visible := False;

        ExecuteSequence(True);

        Screen.Cursor := crDefault;
        RulesForm.Visible := True;
        ControlForm.Visible := True;

     except
           Screen.Cursor := crDefault;
           RulesForm.Visible := True;
           ControlForm.Visible := True;
     end;
end;

procedure LoadLogFile(const sFilename : string;
                      const CombinationSizeCondition : CombinationSizeCondition_T);
var
   fRetainClass : boolean;
   sRetainClass : string;
begin
     try
        fRetainClass := ControlRes^.fFeatureClassesApplied;
        sRetainClass := ControlRes^.sFeatureClassField;
        LoadSelections(sFileName);
        LabelCountUpdate;
        CheckSelections;

        // this was added to counter an error in multiple minset runs
        RePrepIrrepData;

        if ControlRes^.fCalculateBobsExtraVariations then
           UpdateMinsetSumirrWeightingArrays;

        ReInitializeInitialValues(CombinationSizeCondition);

        if fRetainClass then
        begin
             LoadOrdinalClass(sRetainClass,ControLRes^.ClassDetail);
             ControlRes^.fFeatureClassesApplied := True;
             ControlRes^.sFeatureClassField := sRetainClass;
        end;

        ExecuteIrreplaceability(-1,False,False,True,True,'');

        {
        // this is the method used when opening a log file in the interface
        LoadSelections(OpenDialog.FileName);
        LabelCountUpdate;

        RePrepIrrepData;

        if fRetainClass then
        begin
             LoadOrdinalClass(sRetainClass,ControLRes^.ClassDetail);
             ControlRes^.fFeatureClassesApplied := True;
             ControlRes^.sFeatureClassField := sRetainClass;
             end
        end;
          }

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadLogFile ' + sFilename,
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TRulesForm.AutosaveSequence;
var
   sFile : string;
   iCount : integer;
begin
     iCount := 0;
     repeat
           sFile := ControlRes^.sWorkingDirectory + '\sequence' + IntToStr(iCount) + '.seq';

           Inc(iCount);

     until not fileexists(sFile);

     ForceDirectories(ControlRes^.sWorkingDirectory);

     SaveSequence(sFile);
end;

procedure TRulesForm.ExecuteSequence(fShowEndDialog : boolean);
var
   sLogFile, sMinsetFile, sOldFeatureTargetField : string;
   iCount : integer;
   StartingTime, ElapsedTime : TDateTime;
begin
     try
        // autosave the sequence of minsets
        AutosaveSequence;

        StartingTime := Now;

        // save the starting point to a temporary LOG file
        sLogFile := ControlRes^.sDatabase + '\_temp_.log';
        SaveSelections(sLogFile,False);

        // save the current minset to a file
        sMinsetFile := ControlRes^.sDatabase + '\' + IntToStr(iCurrentMinset) + '_temp.min';
        SaveMinsetSpecification(sMinsetFile);

        sOldFeatureTargetField := ControlRes^.sFeatureTargetField;

        // iterate through the minsets one at a time
        for iCount := 1 to iNumberOfMinsets do
        begin
             iActiveMinset := iCount;

             // load the LOG file
             if (iCount <> 1) then
                LoadLogFile(sLogFile,UserLoadLog);

             // load the minset
             LoadMinsetSpecification(ControlRes^.sDatabase + '\' + IntToStr(iCount) + '_temp.min');

             // change feature target field if necessary
             if ControlForm.UseFeatCutOffs.Checked then
                ControlForm.ChangeTargetField(MinsetExpertForm.TgtField.Text);

             // before running this minset, restart validation reports
             // if we are in validation mode
             if ControlRes^.fValidateMode
             and (iCount <> 1) then
             begin
                  {if ControlRes^.fCalculateBobsExtraVariations then
                     UpdateMinsetSumirrWeightingArrays;}

                  GenerateStartReports;
             end;

             // execute the minset
             if (RuleBox.Items.Count > 1)
             and ScanRuleList then
             begin
                  fAdjProxArithOnly := True;
                  SaveMinsetSpecification(rtnUniqueFileName(ControlRes^.sWorkingDirectory + '\minset','mst'));
                  ExecuteMinset(False,MinsetExpertForm.CheckExtraDetail.Checked or ControlRes^.fGenerateCompRpt,False);
                  ModalResult := mrOk;

                  if fStopExecutingMinset then
                  begin
                       // user has stopped this minset, so we must stop all minsets
                       // and return to the starting LOG file
                       LoadLogFile(sLogFile,UserLoadLog);
                       if ControlForm.UseFeatCutOffs.Checked then
                          ControlForm.ChangeTargetField(sOldFeatureTargetField);
                       DeleteFile(sLogFile);
                       LoadMinsetSpecification(sMinsetFile);
                       DeleteFile(sMinsetFile);
                       ElapsedTime := Now - StartingTime;
                       if fShowEndDialog then
                          MessageDlg('User stopped at minset ' +
                                     IntToStr(iActiveMinset) + ' of ' +
                                     IntToStr(iNumberOfMinsets) + ' minsets.',
                                     mtInformation,[mbOk],0);
                       Exit;
                  end;
             end;
        end;

        // return to the starting LOG file
        LoadLogFile(sLogFile,UserLoadLog);
        // restore original target settings
        if ControlForm.UseFeatCutOffs.Checked then
           ControlForm.ChangeTargetField(sOldFeatureTargetField);
        // delete temporary LOG file
        DeleteFile(sLogFile);
        // return to the starting minset file
        LoadMinsetSpecification(sMinsetFile);
        // delete current minset file
        DeleteFile(sMinsetFile);

        ElapsedTime := Now - StartingTime;

        if fShowEndDialog then
           MessageDlg('Finished ' + IntToStr(iNumberOfMinsets) + ' minset runs.'{ + Chr(10) + Chr(13) +
                      'Elapsed time ' + DateTimeToStr(ElapsedTime)},
                      mtInformation,[mbOk],0);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Execute Minset Sequence',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TRulesForm.SpinDistanceChange(Sender: TObject);
var
   iPercentage : integer;
begin
     // user has edited top or bottom X%
     iPercentage := SpinDistance.Value;
     if (OperatorGroup.ItemIndex = 8) then
     begin
          // highest
          OperatorGroup.Items.Delete(8);
          OperatorGroup.Items.Insert(8,'Highest ' + IntToStr(iPercentage) + '%');
          OperatorGroup.ItemIndex := 8;
     end
     else
     begin
          // lowest
          OperatorGroup.Items.Delete(9);
          OperatorGroup.Items.Insert(9,'Lowest ' + IntToStr(iPercentage) + '%');
          OperatorGroup.ItemIndex := 9;
     end;
end;

end.
