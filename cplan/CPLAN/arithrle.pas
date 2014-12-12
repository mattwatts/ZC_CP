unit
    arithrle;

{$DEFINE EXCEPTION_CHECKING}
{$DEFINE ENABLE_DEBUG}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ds;

type
  TArithmeticRuleForm = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }

  end;

function RunArithmeticRule(const iRule, iSelectionsPerIteration : integer;
                           SitesToSelectFrom : Array_t;
                           const SitesToSelect : Array_t;
                           const fDebug, fDestruct, fApplyComplementarity, fRecalculateComplementarity : boolean;
                           const iCurrentIteration : integer) : boolean;
function OutputArithmeticRule(SitesToSelectFrom : Array_t;
                              const fDebug : boolean) : boolean;
function IsWithinTolerance(const rA, rB, rTolerance : extended) : boolean;



var
  ArithmeticRuleForm: TArithmeticRuleForm;
  RichnessArr : Array_t;
  fRichnessArrBuilt : boolean;

implementation

uses Global, Control, Contribu,
     reallist, rules, mthread,
     msetexpt, destruct, opt1,
     validate, filectrl,
     hotspots_nocomplementarity_areaindices,
     getuservalidatefile;

{$R *.DFM}

function TransformVector(Vector, SitesToSelectFrom : Array_t) : Array_t;
var
   iCount, iSiteIndex, iSiteKey : integer;
   rValue : extended;
   aValue : trueFloattype;
begin
     Result := Array_t.Create;
     Result.Init(SizeOf(extended),iSiteCount);
     rValue := 0;
     for iCount := 1 to iSiteCount do
         Result.setValue(iCount,@rValue);

     for iCount := 1 to Vector.lMaxSize do
     begin
          Vector.rtnValue(iCount,@aValue);
          SitesToSelectFrom.rtnValue(aValue.iIndex,@iSiteKey);
          iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
          rValue := aValue.rValue;
          Result.setValue(iSiteIndex,@rValue);
     end;

     //Vector.Destroy;
end;

procedure CreateArithmeticRulesDebugFile(const sFilename : string;
                                         Values1, Values2, Values3,
                                         Values4, Values5, Values6,
                                         Values7, Values8, Values9,
                                         Values10, {Values11,}
                                         SitesToSelectFrom : Array_t);
var
   OutFile : TextFile;
   Vector1, Vector2, Vector3,
   Vector4, Vector5, Vector6,
   Vector7, Vector8, Vector9,
   Vector10{, Vector11} : Array_t;
   iCount : integer;
   rValue : extended;
   sLine : string;
begin
     try
        // create the debug file listing the arithmetic rules
        assignfile(OutFile,sFilename);
        rewrite(OutFile);
        write(OutFile,'SiteIndex,richness,features met,feature rarity,summed rarity,contrib,pccontrib,rarcontrib,');
        writeln(OutFile,'weighted contrib,weighted propcontrib,weighted pccontrib');

        Vector1 := TransformVector(Values1,SitesToSelectFrom);
        Vector2 := TransformVector(Values2,SitesToSelectFrom);
        Vector3 := TransformVector(Values3,SitesToSelectFrom);
        Vector4 := TransformVector(Values4,SitesToSelectFrom);
        Vector5 := TransformVector(Values5,SitesToSelectFrom);
        Vector6 := TransformVector(Values6,SitesToSelectFrom);
        Vector7 := TransformVector(Values7,SitesToSelectFrom);
        Vector8 := TransformVector(Values8,SitesToSelectFrom);
        Vector9 := TransformVector(Values9,SitesToSelectFrom);
        Vector10 := TransformVector(Values10,SitesToSelectFrom);
        //Vector11 := TransformVector(Values11,SitesToSelectFrom);

        for iCount := 1 to iSiteCount do
        begin
             sLine := IntToStr(iCount) + ',';

             Vector1.rtnValue(iCount,@rValue);
             sLine := sLine + FloatToStr(rValue) + ',';
             Vector2.rtnValue(iCount,@rValue);
             sLine := sLine + FloatToStr(rValue) + ',';
             Vector3.rtnValue(iCount,@rValue);
             sLine := sLine + FloatToStr(rValue) + ',';
             Vector4.rtnValue(iCount,@rValue);
             sLine := sLine + FloatToStr(rValue) + ',';
             Vector5.rtnValue(iCount,@rValue);
             sLine := sLine + FloatToStr(rValue) + ',';
             Vector6.rtnValue(iCount,@rValue);
             sLine := sLine + FloatToStr(rValue) + ',';
             Vector7.rtnValue(iCount,@rValue);
             sLine := sLine + FloatToStr(rValue) + ',';
             Vector8.rtnValue(iCount,@rValue);
             sLine := sLine + FloatToStr(rValue) + ',';
             Vector9.rtnValue(iCount,@rValue);
             sLine := sLine + FloatToStr(rValue) + ',';
             Vector10.rtnValue(iCount,@rValue);
             sLine := sLine + FloatToStr(rValue);// + ',';
             //Vector11.rtnValue(iCount,@rValue);
             //sLine := sLine + FloatToStr(rValue);

             writeln(OutFile,sLine);
        end;

        closefile(OutFile);

        Vector1.Destroy;
        Vector2.Destroy;
        Vector3.Destroy;
        Vector4.Destroy;
        Vector5.Destroy;
        Vector6.Destroy;
        Vector7.Destroy;
        Vector8.Destroy;
        Vector9.Destroy;
        Vector10.Destroy;
        //Vector11.Destroy;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CreateArithmeticRulesDebugFile ' + sFilename,mtError,[mbOk],0);
     end;
end;

procedure BuildRichnessArr{(const fDebug : boolean)};
var
   iSite, iFeature, iSiteRichness, iFeatureIndex : integer;
   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   DbgFile : Text;
   fDebug : boolean;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     try
        fDebug := fValidateIteration;

        if not fRichnessArrBuilt then
        begin
             RichnessArr := Array_T.create;
             RichnessArr.init(SizeOf(integer),iFeatureCount);
             fRichnessArrBuilt := True;
             iSiteRichness := 0;
             for iFeature := 1 to iFeatureCount do
                 RichnessArr.setValue(iFeature,@iSiteRichness);
        end;

        new(pSite);
        new(pFeature);

        // recalculate the StaticFeatureRichness array
        iSiteRichness := 0;
        for iFeature := 1 to iFeatureCount do
        begin
             RichnessArr.setValue(iFeature,@iSiteRichness);
        end;

        for iSite := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iSite,pSite);

             if ((pSite^.status = Av) or (pSite^.status = Fl))
             and (pSite^.richness > 0) then
                 for iFeature := 1 to pSite.richness do
                 begin
                      FeatureAmount.rtnValue(pSite^.iOffset + iFeature,@Value);
                      iFeatureIndex := Value.iFeatKey;
                      FeatArr.rtnValue(iFeatureIndex,pFeature);
                      if not pFeature^.fRestrict
                      and (pFeature^.targetarea > 0)
                      and (Value.rAmount > 0) then
                      begin
                           RichnessArr.rtnValue(iFeatureIndex,@iSiteRichness);
                           Inc(iSiteRichness);
                           RichnessArr.setValue(iFeatureIndex,@iSiteRichness);
                      end;
                 end;
        end;

        dispose(pSite);
        dispose(pFeature);

        if fDebug then
        begin
             assignfile(DbgFile,sIteration + '\BuildRichnessArr.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'FeatureIdx,Richness');
             for iFeature := 1 to iFeatureCount do
             begin
                  RichnessArr.rtnValue(iFeature,@iSiteRichness);
                  writeln(DbgFile,IntToStr(iFeature) + ',' + IntToStr(iSiteRichness));
             end;

             closefile(DbgFile);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in BuildRichnessArr',mtError,[mbOk],0);
     end;
end;

// ------------------------------------------------------------------------
// ------------------------------------------------------------------------
// ------------------------------------------------------------------------
// ------------------------------------------------------------------------
// ------------------------------------------------------------------------
// ------------------------------------------------------------------------

function GetAverageRarity(SitesToSelectFrom : Array_t;
                          var AverageRarity : Array_t{;
                          const fDebug : boolean}) : boolean;
{returns an array of Average Rarity for the sites nominated}
var
   iSiteId, iSiteIndex,
   iFeatureRichness, iFeatureIndex,
   iSite, iFeature,
   iUnderRepresentedFeatures : integer;
   rTotalSiteRarity, rRarityOfFeature,
   rAverageRarityFraction : extended;
   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   DbgFile : Text;
   aValue : trueFloattype;
   fDebug : boolean;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     {R. L. Pressey et al book chapter method:

      "highest average rarity fraction (100/frequency in the data set) of all
      under represented features"}

     try
        new(pSite);
        new(pFeature);

        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(DbgFile,sIteration + '\GetAverageRarity.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'SiteKey,SiteAverageRarity');
        end;

        AverageRarity := Array_t.Create;
        AverageRarity.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

        for iSite := 1 to SitesToSelectFrom.lMaxSize do
        begin
             SitesToSelectFrom.rtnValue(iSite,@iSiteId);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteId);
             rTotalSiteRarity := 0;
             iUnderRepresentedFeatures := 0;

             SiteArr.rtnValue(iSiteIndex,pSite);

             if (pSite^.richness > 0) then
                for iFeature := 1 to pSite.richness do
                begin
                     {get feature richness from RichnessArr}
                     FeatureAmount.rtnValue(pSite^.iOffset + iFeature,@Value);
                     RichnessArr.rtnValue(Value.iFeatKey,
                                          @iFeatureRichness);
                     if (Value.rAmount > 0) then
                     begin
                          rRarityOfFeature := 100 / iFeatureRichness;
                          rTotalSiteRarity := rTotalSiteRarity + rRarityOfFeature;
                          Inc(iUnderRepresentedFeatures);
                     end;
                end;

             if (iUnderRepresentedFeatures > 0) then
                rAverageRarityFraction := rTotalSiteRarity / iUnderRepresentedFeatures
             else
                 rAverageRarityFraction := 0;

             if fDebug then
                writeln(DbgFile,IntToStr(pSite^.iKey) + ',' + FloatToStr(rAverageRarityFraction));

             aValue.rValue := rAverageRarityFraction;
             aValue.iIndex := iSite;
             AverageRarity.setValue(iSite,@aValue);
        end;

        dispose(pSite);
        dispose(pFeature);

        if fDebug then
           closefile(DbgFile);


     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetAverageRarity',mtError,[mbOk],0);
     end;
end;

procedure GetNoComplValues(const iIndex : integer;
                           SitesToSelectFrom : Array_t;
                           var NoComplValues : Array_t;
                           var rHi, rLo : extended{;
                           const fDebug : boolean});
var
   iSite, iSiteId, iSiteIndex, iDbg : integer;
   HAI : Hotspots_Area_Indices_T;
   aValue : trueFloattype;
   DbgFile : TextFile;
   pSite : sitepointer;
   fDebug : boolean;
begin
     try
        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('GetNoComplValues before create NoComplValues');

        NoComplValues := Array_t.Create;
        NoComplValues.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('GetNoComplValues after create NoComplValues');

        new(pSite);

        fDebug := fValidateIteration;

        if fDebug then
        begin
             if (iMinsetIterationCount = -1) then
                iDbg := 0
             else
                 iDbg := iMinsetIterationCount;

             ForceDirectories(ControlRes^.sWorkingDirectory +
                              '\' + IntToStr(iDbg));

             assignfile(DbgFile,ControlRes^.sWorkingDirectory +
                                '\' + IntToStr(iDbg) +
                                '\no_compl_values' + IntToStr(iDbg) +
                                '.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'SiteKey,Richness,MaxRarity,SummedRarity,Weighted%Target');
        end;

        rHi := 0;
        rLo := 0;

        for iSite := 1 to SitesToSelectFrom.lMaxSize do
        begin
             SitesToSelectFrom.rtnValue(iSite,@iSiteId);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteId);

             SiteArr.rtnValue(iSiteIndex,pSite);

             Hotspots_Area_Indices.rtnValue(iSiteIndex,@HAI);

             case iIndex of
                  1 :  aValue.rValue := HAI.rRichness;              // richness
                  2 :  aValue.rValue := HAI.rMaxRarity;             // rarity
                  3 :  aValue.rValue := HAI.rSummedRarity;          // summed rarity
                  4 :  aValue.rValue := HAI.rWeightedPercentTarget; // weighted %target
             end;

             aValue.iIndex := iSite;

             NoComplValues.setValue(iSite,@aValue);

             if (aValue.rValue > rHi) then
                rHi := aValue.rValue;
             if (aValue.rValue < rLo) then
                rLo := aValue.rValue;

             if fDebug then
                writeln(DbgFile,IntToStr(pSite^.iKey) +
                                ',' + FloatToStr(HAI.rRichness) +
                                ',' + FloatToStr(HAI.rMaxRarity) +
                                ',' + FloatToStr(HAI.rSummedRarity) +
                                ',' + FloatToStr(HAI.rWeightedPercentTarget));

        end;

        dispose(pSite);

        if fDebug then
           closefile(DbgFile);

     except

     end;
end;

// ------------------------------------------------------------------------
function GetSummedRarity(SitesToSelectFrom : Array_t;
                         var SummedRarity : Array_t;
                         var rHi, rLo : extended{;
                         const fDebug : boolean}) : boolean;
                         {returns an array of Summed Rarity for the sites nominated}
var
   iSiteId, iSiteIndex,
   iFeatureRichness, iFeatureIndex,
   iSite, iFeature : integer;
   rTotalSiteRarity, rRarityOfFeature : extended;
   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   DbgFile : Text;
   aValue : trueFloattype;
   fDebug : boolean;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     {R. L. Pressey et al book chapter method:

      "summed average rarity fraction (100/frequency in the data set) of all
      under represented features"

      This method uses a variation, summed rarity instead of as above.
      }

     try
        new(pSite);
        new(pFeature);

        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(DbgFile,sIteration + '\GetSummedRarity.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'SiteKey,SiteSummedRarity');
        end;

        SummedRarity := Array_t.Create;
        SummedRarity.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

        rHi := 0;
        rLo := 0;

        for iSite := 1 to SitesToSelectFrom.lMaxSize do
        begin
             SitesToSelectFrom.rtnValue(iSite,@iSiteId);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteId);
             rTotalSiteRarity := 0;

             SiteArr.rtnValue(iSiteIndex,pSite);

             if (pSite^.richness > 0) then
                for iFeature := 1 to pSite^.richness do
                begin
                     {get feature richness from RichnessArr}
                     FeatureAmount.rtnValue(pSite^.iOffset + iFeature,@Value);
                     RichnessArr.rtnValue(Value.iFeatKey,
                                          @iFeatureRichness);

                     if (iFeatureRichness > 0)
                     and (Value.rAmount > 0) then
                     begin
                          rRarityOfFeature := 100 / iFeatureRichness;
                          rTotalSiteRarity := rTotalSiteRarity + rRarityOfFeature;
                     end;
                end;

             if fDebug then
                writeln(DbgFile,IntToStr(pSite^.iKey) + ',' + FloatToStr(rTotalSiteRarity));

             aValue.rValue := rTotalSiteRarity;
             aValue.iIndex := iSite;

             if (aValue.rValue > rHi) then
                rHi := aValue.rValue;
             if (aValue.rValue < rLo) then
                rLo := aValue.rValue;

             SummedRarity.setValue(iSite,@aValue);
        end;

        dispose(pSite);
        dispose(pFeature);

        if fDebug then
           closefile(DbgFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetSummedRarity',mtError,[mbOk],0);
     end;
end;
// ------------------------------------------------------------------------
function GetRarity(SitesToSelectFrom : Array_t;
                   var Rarity : Array_t;
                   var rHi, rLo : extended{;
                   const fDebug : boolean}) : boolean;
{returns an array of max Rarity for the sites nominated}
var
   iSiteId, iSiteIndex,
   iFeatureRichness, iFeatureIndex,
   iSite, iFeature : integer;
   rTotalSiteRarity, rRarityOfFeature : extended;
   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   DbgFile : Text;
   aValue : trueFloattype;
   Value : ValueFile_T;
   fDebug : boolean;
begin
     {R. L. Pressey et al book chapter method:

      "maximum average rarity fraction (100/frequency in the data set) of all
      under represented features"
      }

     try
        new(pSite);
        new(pFeature);

        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(DbgFile,sIteration + '\GetRarity.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'SiteKey,SiteRarity');
        end;

        Rarity := Array_t.Create;
        Rarity.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

        rHi := 0;
        rLo := 0;

        for iSite := 1 to SitesToSelectFrom.lMaxSize do
        begin
             SitesToSelectFrom.rtnValue(iSite,@iSiteId);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteId);
             rTotalSiteRarity := 0;

             SiteArr.rtnValue(iSiteIndex,pSite);

             if (pSite^.richness > 0) then
                for iFeature := 1 to pSite.richness do
                begin
                     {get feature richness from RichnessArr}
                     FeatureAmount.rtnValue(pSite^.iOffset + iFeature,@Value);

                     RichnessArr.rtnValue(Value.iFeatKey,
                                          @iFeatureRichness);

                     if (Value.rAmount > 0) then
                     begin
                          if (iFeatureRichness > 0) then
                             rRarityOfFeature := 100 / iFeatureRichness
                          else
                              rRarityOfFeature := 0;
                          if (rRarityOfFeature > rTotalSiteRarity) then
                             rTotalSiteRarity := rRarityOfFeature;
                     end;
                end;

             if fDebug then
                writeln(DbgFile,IntToStr(pSite^.iKey) + ',' + FloatToStr(rTotalSiteRarity));

             aValue.rValue := rTotalSiteRarity;
             aValue.iIndex := iSite;

             if (aValue.rValue > rHi) then
                rHi := aValue.rValue;
             if (aValue.rValue < rLo) then
                rLo := aValue.rValue;

             Rarity.setValue(iSite,@aValue);
        end;

        dispose(pSite);
        dispose(pFeature);

        if fDebug then
           closefile(DbgFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetRarity',mtError,[mbOk],0);
     end;
end;
// ------------------------------------------------------------------------
function GetRichness(SitesToSelectFrom : Array_t;
                     var Richness : Array_t;
                     var rHi, rLo : extended{;
                     const fDebug : boolean}) : boolean;
// returns an array of indicating the number of un represented features for the sites nominated
var
   iSiteId, iSiteIndex, iSiteRichness,
   iFeatureRichness, iFeatureIndex,
   iSite, iFeature : integer;
   rTotalSiteRarity, rRarityOfFeature : extended;
   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   DbgFile : Text;
   aValue : trueFloattype;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
   fDebug : boolean;
begin
     try
        new(pSite);
        new(pFeature);

        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(DbgFile,sIteration + '\GetRichness.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'SiteKey,SiteRichness');
        end;

        Richness := Array_t.Create;
        Richness.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

        rHi := 0;
        rLo := 0;

        for iSite := 1 to SitesToSelectFrom.lMaxSize do
        begin
             SitesToSelectFrom.rtnValue(iSite,@iSiteId);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteId);
             rTotalSiteRarity := 0;

             SiteArr.rtnValue(iSiteIndex,pSite);

             if (pSite^.richness > 0) then
                for iFeature := 1 to pSite^.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffset + iFeature,@Value);
                     iFeatureIndex := Value.iFeatKey;
                     FeatArr.rtnValue(iFeatureIndex,pFeature);
                     if (pFeature^.targetarea > 0)
                     and (Value.rAmount > 0) then
                         rTotalSiteRarity := rTotalSiteRarity + 1;
                end;

             aValue.rValue := rTotalSiteRarity;

             if fDebug then
             begin
                  writeln(DbgFile,IntToStr(pSite^.iKey) + ',' + FloatToStr(aValue.rValue));
             end;

             if (aValue.rValue > rHi) then
                rHi := aValue.rValue;
             if (aValue.rValue < rLo) then
                rLo := aValue.rValue;

             aValue.iIndex := iSite;
             Richness.setValue(iSite,@aValue);
        end;

        dispose(pSite);
        dispose(pFeature);

        if fDebug then
           closefile(DbgFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetRichness',mtError,[mbOk],0);
     end;
end;

// ------------------------------------------------------------------------

function GetRandom(SitesToSelectFrom : Array_t;
                   var RandomArr : Array_t;
                   var rHi, rLo : extended{;
                     const fDebug : boolean}) : boolean;
// returns an array of random values between 0 <= X < 1
var
   iSiteId, iSiteIndex, iSiteRichness,
   iFeatureRichness, iFeatureIndex,
   iSite, iFeature : integer;
   rTotalSiteRarity, rRarityOfFeature : extended;
   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   aValue : trueFloattype;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     try
        new(pSite);
        new(pFeature);

        RandomArr := Array_t.Create;
        RandomArr.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

        rHi := 0;
        rLo := 0;

        for iSite := 1 to SitesToSelectFrom.lMaxSize do
        begin
             SitesToSelectFrom.rtnValue(iSite,@iSiteId);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteId);
             rTotalSiteRarity := 0;

             SiteArr.rtnValue(iSiteIndex,pSite);

             aValue.rValue := random;

             if (aValue.rValue > rHi) then
                rHi := aValue.rValue;
             if (aValue.rValue < rLo) then
                rLo := aValue.rValue;

             aValue.iIndex := iSite;
             RandomArr.setValue(iSite,@aValue);
        end;

        dispose(pSite);
        dispose(pFeature);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetRandom',mtError,[mbOk],0);
     end;
end;

// ------------------------------------------------------------------------


function GetMaxContrib(SitesToSelectFrom : Array_t;
                       var MaxContrib : Array_t;
                       var rHi, rLo : extended{;
                       const fDebug : boolean}) : boolean;
{returns array of MaxContrib of sites passed in}
var
   iSiteId, iSiteIndex,
   iFeatureRichness, iFeatureIndex,
   iSite, iFeature : integer;

   rFeatureContrib,
   rTotalSiteContrib, rRarityOfFeature : extended;

   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   DbgFile : Text;
   aValue : trueFloatType;
   Value : ValueFile_T;
   fDebug : boolean;
begin
     {R. L. Pressey et al book chapter method:

      "highest sum of contributions to full representation
      (contribution = area of each feature that would narrow the gap
       between the target area and the currently represented area)"
      }

     try
        new(pSite);
        new(pFeature);

        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(DbgFile,sIteration + '\GetMaxContrib.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'SiteKey,SiteContrib');
        end;

        MaxContrib := Array_t.Create;
        MaxContrib.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

        rHi := 0;
        rLo := 0;

        for iSite := 1 to SitesToSelectFrom.lMaxSize do
        begin
             SitesToSelectFrom.rtnValue(iSite,@iSiteId);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteId);
             SiteArr.rtnValue(iSiteIndex,pSite);
             rTotalSiteContrib := 0;

             if (pSite^.richness > 0) then
                for iFeature := 1 to pSite.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffset + iFeature,@Value);
                     iFeatureIndex := Value.iFeatKey;
                     FeatArr.rtnValue(iFeatureIndex,pFeature);
                     if (pFeature^.targetarea > 0)
                     and (Value.rAmount > 0) then
                     begin
                          if (Value.rAmount > pFeature^.targetarea) then
                             rFeatureContrib := pFeature^.targetarea
                          else
                              rFeatureContrib := Value.rAmount;
                     end
                     else
                         rFeatureContrib := 0;

                     rTotalSiteContrib := rTotalSiteContrib + rFeatureContrib;
                end;

             if fDebug then
                writeln(DbgFile,IntToStr(pSite^.iKey) + ',' + FloatToStr(rTotalSiteContrib));

             aValue.rValue := rTotalSiteContrib;
             aValue.iIndex := iSite;

             if (aValue.rValue > rHi) then
                rHi := aValue.rValue;
             if (aValue.rValue < rLo) then
                rLo := aValue.rValue;

             MaxContrib.setValue(iSite,@aValue);
        end;

        dispose(pSite);
        dispose(pFeature);

        if fDebug then
           closefile(DbgFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetMaxContrib',mtError,[mbOk],0);
     end;
end;
// ------------------------------------------------------------------------
function GetMax_PcContrib(SitesToSelectFrom : Array_t;
                          var Max_PcContrib : Array_t;
                          var rHi, rLo : extended{;
                          const fDebug : boolean}) : boolean;
var
   iSiteId, iSiteIndex,
   iFeatureRichness, iFeatureIndex,
   iSite, iFeature : integer;

   rFeatureContrib,
   rTotalSiteContrib, rRarityOfFeature : extended;

   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   DbgFile : Text;
   aValue : trueFloatType;
   Value : ValueFile_T;
   fDebug : boolean;
begin
     {R. L. Pressey et al book chapter method:

      "highest sum of contributions (as in maxcontrib) expressed as
       percentages of site area"
      }
     try
        new(pSite);
        new(pFeature);

        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(DbgFile,sIteration + '\GetMax_PcContrib.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'SiteKey,SitePCContrib');
        end;

        Max_PcContrib := Array_t.Create;
        Max_PcContrib.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

        rHi := 0;
        rLo := 0;

        for iSite := 1 to SitesToSelectFrom.lMaxSize do
        begin
             SitesToSelectFrom.rtnValue(iSite,@iSiteId);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteId);
             SiteArr.rtnValue(iSiteIndex,pSite);
             rTotalSiteContrib := 0;

             if (pSite^.richness > 0) then
                for iFeature := 1 to pSite.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffset + iFeature,@Value);
                     iFeatureIndex := Value.iFeatKey;
                     FeatArr.rtnValue(iFeatureIndex,pFeature);
                     if (pFeature^.targetarea > 0)
                     and (Value.rAmount > 0) then
                     begin
                          if (Value.rAmount > pFeature^.targetarea) then
                             rFeatureContrib := pFeature^.targetarea
                          else
                              rFeatureContrib := Value.rAmount;
                     end
                     else
                         rFeatureContrib := 0;

                     {express rFeatureContrib as a percentage of site area}
                     if (pSite^.area <> 0) then
                        rFeatureContrib := rFeatureContrib / pSite^.area * 100
                     else
                         rFeatureContrib := 0;

                     rTotalSiteContrib := rTotalSiteContrib + rFeatureContrib;
                end;

             if fDebug then
                writeln(DbgFile,IntToStr(pSite^.iKey) + ',' + FloatToStr(rTotalSiteContrib));

             aValue.rValue := rTotalSiteContrib;
             aValue.iIndex := iSite;

             if (aValue.rValue > rHi) then
                rHi := aValue.rValue;
             if (aValue.rValue < rLo) then
                rLo := aValue.rValue;

             Max_PcContrib.setValue(iSite,@aValue);
        end;

        dispose(pSite);
        dispose(pFeature);

        if fDebug then
           closefile(DbgFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetMax_PcContrib',mtError,[mbOk],0);
     end;
end;
// ------------------------------------------------------------------------
function GetWeighted_Max_PcContrib(SitesToSelectFrom : Array_t;
                                   var Weighted_Max_PcContrib : Array_t;
                                   var rHi, rLo : extended{;
                                   const fDebug : boolean}) : boolean;
var
   iSiteId, iSiteIndex,
   iFeatureRichness, iFeatureIndex,
   iSite, iFeature : integer;

   rFeatureContrib,
   rTotalSiteContrib, rRarityOfFeature : extended;

   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   DbgFile : Text;
   aValue : trueFloatType;
   Value : ValueFile_T;
   fDebug : boolean;
begin
     {R. L. Pressey et al book chapter method:

      "highest sum of contributions (as in maxcontrib) expressed as
       percentages of site area"

      And weight each value by feature richness before accumulating it for each site.
     }
     try
        new(pSite);
        new(pFeature);

        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(DbgFile,sIteration + '\GetWeighted_Max_PcContrib.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'SiteKey,SiteWeighted_Max_PcContrib');
        end;

        Weighted_Max_PcContrib := Array_t.Create;
        Weighted_Max_PcContrib.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

        rHi := 0;
        rLo := 0;

        for iSite := 1 to SitesToSelectFrom.lMaxSize do
        begin
             SitesToSelectFrom.rtnValue(iSite,@iSiteId);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteId);
             SiteArr.rtnValue(iSiteIndex,pSite);
             rTotalSiteContrib := 0;

             if (pSite^.richness > 0) then
                for iFeature := 1 to pSite.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffset + iFeature,@Value);
                     iFeatureIndex := Value.iFeatKey;
                     FeatArr.rtnValue(iFeatureIndex,pFeature);
                     if (pFeature^.targetarea > 0)
                     and (Value.rAmount > 0) then
                     begin
                          if (Value.rAmount > pFeature^.targetarea) then
                             rFeatureContrib := pFeature^.targetarea
                          else
                              rFeatureContrib := Value.rAmount;
                     end
                     else
                         rFeatureContrib := 0;

                     {express rFeatureContrib as a percentage of site area}
                     if (pSite^.area <> 0) then
                        rFeatureContrib := rFeatureContrib / pSite^.area * 100
                     else
                         rFeatureContrib := 0;

                     {weight this feature contrib value with feature richness}
                     RichnessArr.rtnValue(iFeatureIndex,@iFeatureRichness);
                     if (iFeatureRichness > 0) then
                        rFeatureContrib := rFeatureContrib * 100 / iFeatureRichness
                     else
                         rFeatureContrib := 0;

                     rTotalSiteContrib := rTotalSiteContrib + rFeatureContrib;
                end;

             if fDebug then
                writeln(DbgFile,IntToStr(pSite^.iKey) + ',' + FloatToStr(rTotalSiteContrib));

             aValue.rValue := rTotalSiteContrib;
             aValue.iIndex := iSite;

             if (aValue.rValue > rHi) then
                rHi := aValue.rValue;
             if (aValue.rValue < rLo) then
                rLo := aValue.rValue;

             Weighted_Max_PcContrib.setValue(iSite,@aValue);
        end;

        dispose(pSite);
        dispose(pFeature);

        if fDebug then
           closefile(DbgFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetWeighted_Max_PcContrib',mtError,[mbOk],0);
     end;
end;
// ------------------------------------------------------------------------
function GetWeighted_PercentTarget(SitesToSelectFrom : Array_t;
                                   var Weighted_PercentTarget : Array_t;
                                   var rHi, rLo : extended{;
                                   const fDebug : boolean}) : boolean;
var
   iSiteId, iSiteIndex,
   iFeatureRichness, iFeatureIndex,
   iSite, iFeature : integer;

   rFeatureContrib,
   rTotalSiteContrib, rRarityOfFeature : extended;

   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   DbgFile : Text;
   aValue : trueFloatType;
   Value : ValueFile_T;
   fDebug : boolean;
begin
     {R. L. Pressey paper method:

        Weighted %Target is :

          Sum (T * R) for each feature in the site where

          T is ... 'the percentage of the outstanding conservation target for the'
            ... feature ... 'occurring in the' ... site ... ', updated as
            conservation' proceeds.

          R is ... 'the rarity fraction of the' ... feature

     }
     try
        new(pSite);
        new(pFeature);

        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(DbgFile,sIteration + '\GetWeighted_PercentTarget.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'SiteKey,SiteWeighted_PercentTarget');
        end;

        Weighted_PercentTarget := Array_t.Create;
        Weighted_PercentTarget.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

        rHi := 0;
        rLo := 0;

        for iSite := 1 to SitesToSelectFrom.lMaxSize do
        begin
             SitesToSelectFrom.rtnValue(iSite,@iSiteId);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteId);
             SiteArr.rtnValue(iSiteIndex,pSite);
             rTotalSiteContrib := 0;

             if (pSite^.richness > 0) then
                for iFeature := 1 to pSite.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffset + iFeature,@Value);
                     iFeatureIndex := Value.iFeatKey;
                     FeatArr.rtnValue(iFeatureIndex,pFeature);
                     if (pFeature^.targetarea > 0)
                     and (Value.rAmount > 0) then
                     begin
                          if (Value.rAmount > pFeature^.targetarea) then
                             rFeatureContrib := pFeature^.targetarea
                          else
                              rFeatureContrib := Value.rAmount;
                     end
                     else
                         rFeatureContrib := 0;

                     {express rFeatureContrib as a percentage of target area}
                     if (pFeature^.targetarea <> 0) then
                        rFeatureContrib := rFeatureContrib / pFeature^.targetarea * 100
                     else
                         rFeatureContrib := 0;

                     {weight this feature contrib value with feature richness}
                     RichnessArr.rtnValue(iFeatureIndex,@iFeatureRichness);
                     if (iFeatureRichness > 0) then
                        rFeatureContrib := rFeatureContrib * 100 / iFeatureRichness
                     else
                         rFeatureContrib := 0;

                     rTotalSiteContrib := rTotalSiteContrib + rFeatureContrib;
                end;

             if fDebug then
                writeln(DbgFile,IntToStr(pSite^.iKey) + ',' + FloatToStr(rTotalSiteContrib));

             aValue.rValue := rTotalSiteContrib;
             aValue.iIndex := iSite;

             if (aValue.rValue > rHi) then
                rHi := aValue.rValue;
             if (aValue.rValue < rLo) then
                rLo := aValue.rValue;

             Weighted_PercentTarget.setValue(iSite,@aValue);
        end;

        dispose(pSite);
        dispose(pFeature);

        if fDebug then
           closefile(DbgFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetWeighted_PercentTarget',mtError,[mbOk],0);
     end;
end;
// ------------------------------------------------------------------------
function GetMostContrib(SitesToSelectFrom : Array_t;
                        var MostContrib : Array_t;
                        var rHi, rLo : extended{;
                        const fDebug : boolean}) : boolean;
var
   iSiteId, iSiteIndex,
   iFeatureRichness, iFeatureIndex,
   iSite, iFeature : integer;

   rFeatureContrib,
   rTotalSiteContrib, rRarityOfFeature : extended;

   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   DbgFile : Text;
   aValue : trueFloatType;
   Value : ValueFile_T;
   fDebug : boolean;
begin
     {R. L. Pressey et al book chapter method:

      "highest number of under-represented features that would be fully
       represented with the notional reservation of the sites"
      }
     try
        new(pSite);
        new(pFeature);

        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(DbgFile,sIteration + '\GetMostContrib.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'SiteKey,SiteContrib');
        end;

        MostContrib := Array_t.Create;
        MostContrib.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

        rHi := 0;
        rLo := 0;

        for iSite := 1 to SitesToSelectFrom.lMaxSize do
        begin
             SitesToSelectFrom.rtnValue(iSite,@iSiteId);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteId);
             SiteArr.rtnValue(iSiteIndex,pSite);
             rTotalSiteContrib := 0;
             if (pSite^.richness > 0) then
                for iFeature := 1 to pSite.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffset + iFeature,@Value);
                     iFeatureIndex := Value.iFeatKey;
                     FeatArr.rtnValue(iFeatureIndex,pFeature);
                     if (pFeature^.targetarea > 0)
                     and (pFeature^.targetarea <= Value.rAmount)
                     and (Value.rAmount > 0) then
                     begin
                          rTotalSiteContrib := rTotalSiteContrib + 1;
                     end;

                end;

             if fDebug then
                writeln(DbgFile,IntToStr(pSite^.iKey) + ',' + FloatToStr(rTotalSiteContrib));

             aValue.rValue := rTotalSiteContrib;
             aValue.iIndex := iSite;

             if (aValue.rValue > rHi) then
                rHi := aValue.rValue;
             if (aValue.rValue < rLo) then
                rLo := aValue.rValue;

             MostContrib.setValue(iSite,@aValue);
        end;

        dispose(pSite);
        dispose(pFeature);

        if fDebug then
           closefile(DbgFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetMostContrib',mtError,[mbOk],0);
     end;
end;
// ------------------------------------------------------------------------
function GetWeighted_MaxContrib(SitesToSelectFrom : Array_t;
                                var Weighted_MaxContrib : Array_t;
                                var rHi, rLo : extended{;
                                const fDebug : boolean}) : boolean;
var
   iSiteId, iSiteIndex,
   iFeatureRichness, iFeatureIndex,
   iSite, iFeature : integer;

   rFeatureContrib,
   rTotalSiteContrib, rRarityOfFeature : extended;

   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   DbgFile : Text;
   aValue : trueFloatType;
   Value : ValueFile_T;
   fDebug : boolean;
begin
     {R. L. Pressey et al book chapter method:

      "highest sum of contributions (as in maxcontrib) weighted by the rarity
       fraction (100/frequency in the data set) of each feature"
      }
     try
        new(pSite);
        new(pFeature);

        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(DbgFile,sIteration + '\GetWeighted_MaxContrib.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'SiteKey,SiteContrib');
        end;

        Weighted_MaxContrib := Array_t.Create;
        Weighted_MaxContrib.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

        rHi := 0;
        rLo := 0;

        for iSite := 1 to SitesToSelectFrom.lMaxSize do
        begin
             SitesToSelectFrom.rtnValue(iSite,@iSiteId);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteId);
             SiteArr.rtnValue(iSiteIndex,pSite);
             rTotalSiteContrib := 0;

             if (pSite^.richness > 0) then
                for iFeature := 1 to pSite.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffset + iFeature,@Value);
                     iFeatureIndex := Value.iFeatKey;
                     FeatArr.rtnValue(iFeatureIndex,pFeature);
                     if (pFeature^.targetarea > 0)
                     and (Value.rAmount > 0) then
                     begin
                          if (Value.rAmount > pFeature^.targetarea) then
                             rFeatureContrib := pFeature^.targetarea
                          else
                              rFeatureContrib := Value.rAmount;
                     end
                     else
                         rFeatureContrib := 0;

                     RichnessArr.rtnValue(iFeatureIndex,@iFeatureRichness);
                     if (iFeatureRichness > 0) then
                        rFeatureContrib := rFeatureContrib * 100 / iFeatureRichness
                     else
                         rFeatureContrib := 0;

                     rTotalSiteContrib := rTotalSiteContrib + rFeatureContrib;
                end;

             if fDebug then
                writeln(DbgFile,IntToStr(pSite^.iKey) + ',' + FloatToStr(rTotalSiteContrib));

             aValue.rValue := rTotalSiteContrib;
             aValue.iIndex := iSite;

             if (aValue.rValue > rHi) then
                rHi := aValue.rValue;
             if (aValue.rValue < rLo) then
                rLo := aValue.rValue;
                
             Weighted_MaxContrib.setValue(iSite,@aValue);
        end;

        dispose(pSite);
        dispose(pFeature);

        if fDebug then
           closefile(DbgFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetWeighted_MaxContrib',mtError,[mbOk],0);
     end;
end;
// ------------------------------------------------------------------------
// ------------------------------------------------------------------------
// ------------------------------------------------------------------------
// ------------------------------------------------------------------------
// ------------------------------------------------------------------------
// ------------------------------------------------------------------------



// ------------------------------------------------------------------------
function Get_RarContrib(SitesToSelectFrom : Array_t;
                        var Max_RarContrib : Array_t;
                        var rHi, rLo : extended{;
                        const fDebug : boolean}) : boolean;
var
   DbgFile : Text;
   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   aValue : trueFloatType;
   iSite, iFeature, iSiteIndex, iFeatureIndex, iSiteId,
   iFeatureRichness, iMaxRarity : integer;
   rRarContrib, rFeatureContrib : extended;
   Value : ValueFile_T;
   fDebug : boolean;
begin
     {
      R. L. Pressey et al book chapter method:

      "highest sum of contributions (as in maxcontrib) for under-represented
       feature(s) with highest rarity fractions (100/frequency in the data set)"

      Method used by Matt to implement this slightly ambiguous rule :
      (Contribution (not sum) of feature with highest rarity fraction)

        For each feature (that has a contributing area) at a site, find :
          the contributing area
          the rarity fraction

        RarContrib for the site is contributing area of rarest feature
        that remains un-represented, ie. "rarest contribution".
      }

     {$IFDEF EXCEPTION_CHECKING}
     try
     {$ENDIF}
        Max_RarContrib := Array_t.Create;
        Max_RarContrib.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

        rHi := 0;
        rLo := 0;

        new(pSite);
        new(pFeature);

        fDebug := fValidateIteration;

        {$IFDEF ENABLE_DEBUG}
        if fDebug then
        begin
             assignfile(DbgFile,sIteration + '\RarContrib.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'Site Key,RarContrib');
        end;
        {$ENDIF}

        for iSite := 1 to SitesToSelectFrom.lMaxSize do
        begin
             SitesToSelectFrom.rtnValue(iSite,@iSiteId);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteId);
             SiteArr.rtnValue(iSiteIndex,pSite);

             iMaxRarity := 0;
             rRarContrib := 0;

             if (pSite^.richness > 0) then
             begin
                  // first, find what the maximum feature rarity is for contributing features
                  for iFeature := 1 to pSite.richness do
                  begin
                       FeatureAmount.rtnValue(pSite^.iOffset + iFeature,@Value);
                       iFeatureIndex := Value.iFeatKey;
                       FeatArr.rtnValue(iFeatureIndex,pFeature);
                       if (pFeature^.targetarea > 0)
                       and (Value.rAmount > 0) then
                       begin
                            RichnessArr.rtnValue(iFeatureIndex,@iFeatureRichness);
                            if (iFeatureRichness > iMaxRarity) then
                               iMaxRarity := iFeatureRichness;
                       end;

                  end;

                  // now, find the highest contribution from feature(s) that have this rarity
                  for iFeature := 1 to pSite.richness do
                  begin
                       FeatureAmount.rtnValue(pSite^.iOffset + iFeature,@Value);
                       iFeatureIndex := Value.iFeatKey;
                       FeatArr.rtnValue(iFeatureIndex,pFeature);
                       if (pFeature^.targetarea > 0)
                       and (Value.rAmount > 0) then
                       begin
                            if (Value.rAmount > pFeature^.targetarea) then
                               rFeatureContrib := pFeature^.targetarea
                            else
                                rFeatureContrib := Value.rAmount;

                            RichnessArr.rtnValue(iFeatureIndex,@iFeatureRichness);
                            if (iFeatureRichness = iMaxRarity)
                            and (rFeatureContrib > rRarContrib) then
                                rRarContrib := rFeatureContrib;
                       end;
                  end;
             end;

             {$IFDEF ENABLE_DEBUG}
             if fDebug then
                writeln(DbgFile,IntToStr(pSite^.iKey) + ',' + FloatToStr(rRarContrib));
             {$ENDIF}

             aValue.rValue := rRarContrib;
             aValue.iIndex := iSite;

             if (aValue.rValue > rHi) then
                rHi := aValue.rValue;
             if (aValue.rValue < rLo) then
                rLo := aValue.rValue;

             Max_RarContrib.setValue(iSite,@aValue);
        end;

        dispose(pSite);
        dispose(pFeature);

        {$IFDEF ENABLE_DEBUG}
        if fDebug then
           CloseFile(DbgFile);
        {$ENDIF}

     {$IFDEF EXCEPTION_CHECKING}
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Get_RarContrib',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
     {$ENDIF}
end;

// ------------------------------------------------------------------------
// ------------------------------------------------------------------------

function GetWeighted_PropContrib(SitesToSelectFrom : Array_t;
                                 var Weighted_PropContrib : Array_t;
                                 var rHi, rLo : extended{;
                                 const fDebug : boolean}) : boolean;
var
   iSiteId, iSiteIndex,
   iFeatureRichness, iFeatureIndex,
   iSite, iFeature : integer;

   rFeatureContrib,
   rTotalSiteContrib, rRarityOfFeature : extended;

   pSite : sitepointer;
   pFeature : featureoccurrencepointer;
   DbgFile : Text;
   aValue : trueFloatType;
   Value : ValueFile_T;
   fDebug : boolean;
begin
     {
      R. L. Pressey et al book chapter method:

      "highest sum of weighted contributions (as in weighted maxcontrib) but
       with contributions expressed as a percentage of the remaining area
       of each feature still to be represented"
     }
     try
        new(pSite);
        new(pFeature);

        fDebug := fValidateIteration;

        if fDebug then
        begin
             assignfile(DbgFile,sIteration + '\GetWeighted_PropContrib.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'SiteKey,SiteWeighted_PropContrib');
        end;

        Weighted_PropContrib := Array_t.Create;
        Weighted_PropContrib.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

        rHi := 0;
        rLo := 0;

        for iSite := 1 to SitesToSelectFrom.lMaxSize do
        begin
             SitesToSelectFrom.rtnValue(iSite,@iSiteId);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteId);
             SiteArr.rtnValue(iSiteIndex,pSite);
             rTotalSiteContrib := 0;

             if (pSite^.richness > 0) then
                for iFeature := 1 to pSite.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffset + iFeature,@Value);
                     iFeatureIndex := Value.iFeatKey;
                     FeatArr.rtnValue(iFeatureIndex,pFeature);
                     if (pFeature^.targetarea > 0)
                     and (Value.rAmount > 0) then
                     begin
                          if (Value.rAmount > pFeature^.targetarea) then
                             rFeatureContrib := pFeature^.targetarea
                          else
                              rFeatureContrib := Value.rAmount;
                          // express feature contrib as a percentage of remaining target
                          rFeatureContrib := rFeatureContrib / pFeature^.targetarea * 100;
                     end
                     else
                         rFeatureContrib := 0;

                     RichnessArr.rtnValue(iFeatureIndex,@iFeatureRichness);
                     if (iFeatureRichness > 0) then
                        rFeatureContrib := rFeatureContrib * 100 / iFeatureRichness
                     else
                         rFeatureContrib := 0;

                     rTotalSiteContrib := rTotalSiteContrib + rFeatureContrib;
                end;

             if fDebug then
                writeln(DbgFile,IntToStr(pSite^.iKey) + ',' + FloatToStr(rTotalSiteContrib));

             aValue.rValue := rTotalSiteContrib;
             aValue.iIndex := iSite;

             if (aValue.rValue > rHi) then
                rHi := aValue.rValue;
             if (aValue.rValue < rLo) then
                rLo := aValue.rValue;

             Weighted_PropContrib.setValue(iSite,@aValue);
        end;

        dispose(pSite);
        dispose(pFeature);

        if fDebug then
           closefile(DbgFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetWeighted_PropContrib at site ' + IntToStr(iSite),mtError,[mbOk],0);
     end;
end;

// ------------------------------------------------------------------------

procedure StoreArithmeticValues(const SiteKeys, SiteValues : Array_t;
                                const fDebug : boolean);
var
   iCount, iKey : integer;
   rValue : extended;
   aValue : trueFloatType;
   DebugFile : TextFile;
   sFile : string;
begin
     // store the calculated values in the cache array because complementarity
     // is switched off and we may need to use the values for subsequent iterations
     if ControlRes^.fValidateMinset then
     begin
          iCount := 0;
          repeat
                sFile := ControlRes^.sWorkingDirectory + '\' + IntToStr(iCount) + '_store_arith_values.csv';
                Inc(iCount);

          until (not FileExists(sFile));

          assignfile(DebugFile,sFile);
          rewrite(DebugFile);
          writeln(DebugFile,'key,value');
     end;

     for iCount := 1 to SiteValues.lMaxSize do
     begin
          SiteValues.rtnValue(iCount,@aValue);
          SiteKeys.rtnValue(aValue.iIndex,@iKey);
          iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);

          CacheArithmeticRule.setValue(iSiteIndex,@aValue.rValue);

          if ControlRes^.fValidateMinset then
             writeln(DebugFile,IntToStr(iKey) + ',' + FloatToStr(aValue.rValue));
     end;

     if ControlRes^.fValidateMinset then
        CloseFile(DebugFile);
end;
// ------------------------------------------------------------------------

procedure RecoverArithmeticValues(const SiteKeys : Array_t;
                                  var SiteValues : Array_t;
                                  var rHi : extended;
                                  const fDebug : boolean);
var
   iCount, iKey : integer;
   rValue : extended;
   aValue : trueFloatType;
   DebugFile : TextFile;
   sFile : string;
begin
     // store the calculated values in the cache array because complementarity
     // is switched off and we may need to use the values for subsequent iterations
     if fDebug then
     begin
          iCount := 0;
          repeat
                sFile := ControlRes^.sWorkingDirectory + '\' + IntToStr(iCount) + '_recover_arith_values.csv';
                Inc(iCount);

          until (not FileExists(sFile));

          assignfile(DebugFile,sFile);
          rewrite(DebugFile);
          writeln(DebugFile,'key,value');
     end;

     SiteValues := Array_t.Create;
     SiteValues.init(SizeOf(trueFloatType),SiteKeys.lMaxSize);

     for iCount := 1 to SiteKeys.lMaxSize do
     begin
          SiteKeys.rtnValue(iCount,@iKey);
          iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);

          CacheArithmeticRule.rtnValue(iSiteIndex,@aValue.rValue);
          aValue.iIndex := iCount;

          if (aValue.rValue > rHi) then
             rHi := aValue.rValue;

          SiteValues.setValue(iCount,@aValue);

          if fDebug then
             writeln(DebugFile,IntToStr(iKey) + ',' + FloatToStr(aValue.rValue));
     end;

     if fDebug then
        CloseFile(DebugFile);
end;

// ------------------------------------------------------------------------

function IsWithinTolerance(const rA, rB, rTolerance : extended) : boolean;
begin
     if (rA < (rB + rTolerance))
     and (rA > (rB - rTolerance)) then
     begin
          Result := True;
          if (rA = 0)
          and (rB <> 0) then
              Result := False;
          if (rB = 0)
          and (rA <> 0) then
              Result := False;
     end
     else
         Result := False;
end;

function OutputArithmeticRule(SitesToSelectFrom : Array_t;
                              const fDebug : boolean) : boolean;
var
   Values1, Values2, Values3, Values4, Values5, Values6,
   Values7, Values8, Values9, Values10//, Values11
   {,UnsortedValues, SortedValues} : Array_t;
   iKey, iCount, iSitesSelected, iTestKey : integer;
   aValue : trueFloatType;
   rHi, rLo, rDebugHi,rDebugLo : extended;
   fRecalculate, fArithmeticNCOn : boolean;
begin
     try
        Result := False;
        if fDebug
        and ValidateThisIteration(iMinsetIterationCount) then
        begin
             if ControlRes^.fReportMinsetMemSize then
                AddMemoryReportRow('OutputArithmeticRule begin');

             // we must create debug output for the minset rules
             BuildRichnessArr;

             if ControlRes^.fReportMinsetMemSize then
                AddMemoryReportRow('OutputArithmeticRule after BuildRichnessArr');

             //Values1 := Array_t.Create;
             //Values1.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

             GetRichness(SitesToSelectFrom,Values1,rDebugHi,rDebugLo);
             GetMostContrib(SitesToSelectFrom,Values2,rDebugHi,rDebugLo);
             GetRarity(SitesToSelectFrom,Values3,rDebugHi,rDebugLo);
             GetSummedRarity(SitesToSelectFrom,Values4,rDebugHi,rDebugLo);
             GetMaxContrib(SitesToSelectFrom,Values5,rDebugHi,rDebugLo);
             GetMax_PcContrib(SitesToSelectFrom,Values6,rDebugHi,rDebugLo);
             Get_RarContrib(SitesToSelectFrom,Values7,rDebugHi,rDebugLo);
             GetWeighted_MaxContrib(SitesToSelectFrom,Values8,rDebugHi,rDebugLo);
             GetWeighted_PropContrib(SitesToSelectFrom,Values9,rDebugHi,rDebugLo);
             GetWeighted_Max_PcContrib(SitesToSelectFrom,Values10,rDebugHi,rDebugLo);
             //GetWeighted_PercentTarget(SitesToSelectFrom,Values11,rDebugHi,rDebugLo);
             ForceDirectories(sIteration);

             if ControlRes^.fReportMinsetMemSize then
                AddMemoryReportRow('OutputArithmeticRule after Get vectors');

             CreateArithmeticRulesDebugFile(sIteration + '\ArithmeticCalculations.csv',
                                            Values1, Values2, Values3,
                                            Values4, Values5, Values6,
                                            Values7, Values8, Values9,
                                            Values10, //Values11,
                                            SitesToSelectFrom);
             Values1.Destroy;
             Values2.Destroy;
             Values3.Destroy;
             Values4.Destroy;
             Values5.Destroy;
             Values6.Destroy;
             Values7.Destroy;
             Values8.Destroy;
             Values9.Destroy;
             Values10.Destroy;
             //Values11.Destroy;

             Result := True;

             if ControlRes^.fReportMinsetMemSize then
                AddMemoryReportRow('OutputArithmeticRule end');
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in OutputArithmeticRule',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function RunArithmeticRule(const iRule, iSelectionsPerIteration : integer;
                           SitesToSelectFrom : Array_t;
                           const SitesToSelect : Array_t;
                           const fDebug, fDestruct, fApplyComplementarity, fRecalculateComplementarity : boolean;
                           const iCurrentIteration : integer) : boolean;
var
   Values1, Values2, Values3, Values4, Values5, Values6,
   Values7, Values8, Values9, Values10, //Values11,
   UnsortedValues, SortedValues : Array_t;
   iKey, iCount, iSitesSelected, iTestKey : integer;
   aValue : trueFloatType;
   rHi, rLo, rDebugHi,rDebugLo : extended;
   fRecalculate, fArithmeticNCOn : boolean;
begin
     try
        {
         run Arithmetic Minset Rule
         iRule corresponds to;

         1  richness
         2  features met
         3  feature rarity
         4  summed rarity
         5  contrib
         6  pccontrib
         7  rarcontrib
         8  weighted contrib
         9  weighted propcontrib
         10 weighted pccontrib
         11 weighted %target
         12 RANDOM
        }
        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('RunArithmeticRule begin');

        if fValidateIteration then
           ForceDirectories(sIteration);

        //SitesToSelect := Array_t.Create;
        //SitesToSelect.init(SizeOf(integer),ARR_STEP_SIZE);
        Result := False;
        rHi := 0;

        // with these variables, it is possible to select more than 1 value at a time
        // ie. the top N values
        if fApplyComplementarity then
        case iRule of
             1 :
             begin
                  // Hotspots rule
                  // richness
                  //UnsortedValues := Array_t.Create;
                  //UnsortedValues.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);

                  GetRichness(SitesToSelectFrom,UnsortedValues,rHi,rLo);
             end;
             2 : // features met
                 GetMostContrib(SitesToSelectFrom,UnsortedValues,rHi,rLo);
             3 :
             begin
                  // Hotspots rule
                  // rarity
                  BuildRichnessArr;
                  GetRarity(SitesToSelectFrom,UnsortedValues,rHi,rLo);
             end;
             4 :
             begin
                  // Hotspots rule
                  BuildRichnessArr;
                  GetSummedRarity(SitesToSelectFrom,UnsortedValues,rHi,rLo);
             end;
             5 : GetMaxContrib(SitesToSelectFrom,UnsortedValues,rHi,rLo);
             6 : GetMax_PcContrib(SitesToSelectFrom,UnsortedValues,rHi,rLo);
             7 :
             begin
                  BuildRichnessArr;
                  Get_RarContrib(SitesToSelectFrom,UnsortedValues,rHi,rLo);
             end;
             8 :
             begin
                  BuildRichnessArr;
                  GetWeighted_MaxContrib(SitesToSelectFrom,UnsortedValues,rHi,rLo);
             end;
             9 :
             begin
                  BuildRichnessArr;
                  GetWeighted_PropContrib(SitesToSelectFrom,UnsortedValues,rHi,rLo);
             end;
             10 :
             begin
                  BuildRichnessArr;
                  GetWeighted_Max_PcContrib(SitesToSelectFrom,UnsortedValues,rHi,rLo);
             end;
             11 :
             begin
                  // Hotspots rule
                  BuildRichnessArr;
                  GetWeighted_PercentTarget(SitesToSelectFrom,UnsortedValues,rHi,rLo);
             end;
             12 : GetRANDOM(SitesToSelectFrom,UnsortedValues,rHi,rLo);
        end
        else
        begin
             // complementarity is off
             {if fRecalculateComplementarity then
             begin}
             // recalculate values
             case iRule of
                  12 : GetRANDOM(SitesToSelectFrom,UnsortedValues,rHi,rLo);
                  1 :
                  begin
                       if fUseHotspotsNoComplValues then
                       begin
                            // read richness from the no complmentarity data structure
                            if ControlRes^.fReportMinsetMemSize then
                               AddMemoryReportRow('RunArithmeticRule before GetNoComplValues');

                            GetNoComplValues(1,SitesToSelectFrom,UnsortedValues,rHi,rLo{,ControlRes^.fGenerateCompRpt});
                       end
                       else
                       begin
                            //UnsortedValues := Array_t.Create;
                            //UnsortedValues.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);
                            if ControlRes^.fReportMinsetMemSize then
                               AddMemoryReportRow('RunArithmeticRule before GetRichness');

                            GetRichness(SitesToSelectFrom,UnsortedValues,rHi,rLo);
                       end;
                  end;
                  2 : GetMostContrib(SitesToSelectFrom,UnsortedValues,rHi,rLo);
                  5 : GetMaxContrib(SitesToSelectFrom,UnsortedValues,rHi,rLo);
                  6 : GetMax_PcContrib(SitesToSelectFrom,UnsortedValues,rHi,rLo);
                  3,4,7,8,9,10,11 :
                  begin
                       BuildRichnessArr;
                       case iRule of
                            3 :
                            begin
                                 if fUseHotspotsNoComplValues then
                                    GetNoComplValues(2,SitesToSelectFrom,UnsortedValues,rHi,rLo{,ControlRes^.fGenerateCompRpt})
                                 else
                                     GetRarity(SitesToSelectFrom,UnsortedValues,rHi,rLo);
                            end;
                            4 :
                            begin
                                 if fUseHotspotsNoComplValues then
                                    GetNoComplValues(3,SitesToSelectFrom,UnsortedValues,rHi,rLo{,ControlRes^.fGenerateCompRpt})
                                 else
                                     GetSummedRarity(SitesToSelectFrom,UnsortedValues,rHi,rLo);
                            end;
                            7 : Get_RarContrib(SitesToSelectFrom,UnsortedValues,rHi,rLo);
                            8 : GetWeighted_MaxContrib(SitesToSelectFrom,UnsortedValues,rHi,rLo);
                            9 : GetWeighted_PropContrib(SitesToSelectFrom,UnsortedValues,rHi,rLo);
                            10 : GetWeighted_Max_PcContrib(SitesToSelectFrom,UnsortedValues,rHi,rLo);
                            11 :
                            begin
                                 if fUseHotspotsNoComplValues then
                                    GetNoComplValues(4,SitesToSelectFrom,UnsortedValues,rHi,rLo{,ControlRes^.fGenerateCompRpt})
                                 else
                                     GetWeighted_PercentTarget(SitesToSelectFrom,UnsortedValues,rHi,rLo);
                            end;
                       end;
                  end;
             end;

             if ControlRes^.fReportMinsetMemSize then
                AddMemoryReportRow('RunArithmeticRule before StoreArithmeticValues');

             StoreArithmeticValues(SitesToSelectFrom,UnsortedValues,fDebug);
             (*end;
             else
             begin
                  // use previously calculated values
                  RecoverArithmeticValues(SitesToSelectFrom,UnsortedValues,rHi,fDebug);
             end;*)
        end;

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('RunArithmeticRule after calc vector/before validate itn');

        if fDebug
        and ValidateThisIteration(iMinsetIterationCount) then
        begin
             // we must create debug output for the minset rules
             BuildRichnessArr;
             //Values1 := Array_t.Create;
             //Values1.init(SizeOf(aValue),SitesToSelectFrom.lMaxSize);
             GetRichness(SitesToSelectFrom,Values1,rDebugHi,rDebugLo);
             GetMostContrib(SitesToSelectFrom,Values2,rDebugHi,rDebugLo);
             GetRarity(SitesToSelectFrom,Values3,rDebugHi,rDebugLo);
             GetSummedRarity(SitesToSelectFrom,Values4,rDebugHi,rDebugLo);
             GetMaxContrib(SitesToSelectFrom,Values5,rDebugHi,rDebugLo);
             GetMax_PcContrib(SitesToSelectFrom,Values6,rDebugHi,rDebugLo);
             Get_RarContrib(SitesToSelectFrom,Values7,rDebugHi,rDebugLo);
             GetWeighted_MaxContrib(SitesToSelectFrom,Values8,rDebugHi,rDebugLo);
             GetWeighted_PropContrib(SitesToSelectFrom,Values9,rDebugHi,rDebugLo);
             GetWeighted_Max_PcContrib(SitesToSelectFrom,Values10,rDebugHi,rDebugLo);
             //GetWeighted_PercentTarget(SitesToSelectFrom,Values11,rDebugHi,rDebugLo);

             CreateArithmeticRulesDebugFile(sIteration + '\ArithmeticCalculations.csv',
                                            Values1, Values2, Values3,
                                            Values4, Values5, Values6,
                                            Values7, Values8, Values9,
                                            Values10,// Values11,
                                            SitesToSelectFrom);
             Values1.Destroy;
             Values2.Destroy;
             Values3.Destroy;
             Values4.Destroy;
             Values5.Destroy;
             Values6.Destroy;
             Values7.Destroy;
             Values8.Destroy;
             Values9.Destroy;
             Values10.Destroy;
             //Values11.Destroy;
        end;

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('RunArithmeticRule after validate itn/before Vuln adjustment');

        // do any vulnerability adjustments here
        case MinsetExpertForm.CombineVuln.ItemIndex of
             1 : {Normalise with Maximum Vulnerability}
                 NormaliseMaxVuln(UnsortedValues,rHi,rLo,SitesToSelectFrom,fDebug or ControlRes^.fGenerateCompRpt,
                                  fApplyComplementarity,fRecalculateComplementarity);
             2 : {Normalise with Weighted Average Vulnerability}
                 NormaliseWavVuln(UnsortedValues,rHi,rLo,SitesToSelectFrom,fDebug or ControlRes^.fGenerateCompRpt,
                                  fApplyComplementarity,fRecalculateComplementarity);
             3 : {Restrict to maximum X% of vulnerable sites}
                 RestrictVuln(UnsortedValues,SitesToSelectFrom{,fDebug or ControlRes^.fGenerateCompRpt},rHi,rLo,
                              fApplyComplementarity,fRecalculateComplementarity);
        end;

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('RunArithmeticRule before write results');

        iSitesSelected := 0;
        for iCount := 1 to UnsortedValues.lMaxSize do
        begin
             UnsortedValues.rtnValue(iCount,@aValue);
             if aValue.rValue = rHi then//IsWithinTolerance(aValue.rValue,rHi,0.000000000001) then
             begin
                  // now add to SitesToSelect
                  Inc(iSitesSelected);
                  if (iSitesSelected > SitesToSelect.lMaxSize) then
                     SitesToSelect.resize(SitesToSelect.lMaxSize + ARR_STEP_SIZE);
                  SitesToSelectFrom.rtnValue(aValue.iIndex,@iTestKey);
                  SitesToSelect.setValue(iSitesSelected,@iTestKey);
             end;
        end;
        if (iSitesSelected > 0) then
        begin
             if (iSitesSelected <> SitesToSelect.lMaxSize) then
                SitesToSelect.resize(iSitesSelected);
        end
        else
        begin
             SitesToSelect.resize(1);
             SitesToSelect.lMaxSize := 0;
        end;

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('RunArithmeticRule before UnsortedValues.Destroy');

        UnsortedValues.Destroy;

        Result := True;

        //if (Result = False) then
        //   SitesToSelect.Destroy;

        if ControlRes^.fReportMinsetMemSize then
           AddMemoryReportRow('RunArithmeticRule end');

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RunArithmeticRule',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


end.
