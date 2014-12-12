unit Marxan_system_test;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, Childwin, ExtCtrls;

type
  TMarZoneSystemTestForm = class(TForm)
    Label1: TLabel;
    EditInputDat: TEdit;
    btnBrowse: TButton;
    Label2: TLabel;
    ComboTestConfigurations: TComboBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OpenDialog1: TOpenDialog;
    InputDatListBox: TListBox;
    RadioSoftwareTestType: TRadioGroup;
    CheckTranspose: TCheckBox;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure ExecuteMarZoneTest(sInputDat, sTestConfigurations : string);
    procedure ExecuteMarxanTest(sInputDat, sTestConfigurations : string);
    procedure ExecuteMarProbThreatTest(sInputDat, sTestConfigurations : string);
    function ScanInputDat(const sScanString : string) : string;
    function ComputeMarZoneCost(const iConfiguration : integer; TestConfigurationChild,
                         PuChild, CostsChild, ZoneCostChild : TMDIChild) : extended;
    function ComputeMarZoneConnectivity(const iConfiguration : integer; TestConfigurationChild,
                                 PuChild, BoundChild, ZoneBoundCostChild : TMDIChild) : extended;
    function ComputeMarZonePenalty(const iConfiguration,iTargetField,iPropField : integer;
                            TestConfigurationChild, PuChild, SpecChild, PuvsprChild, ZonesChild, ZoneTargetChild, ZoneContribChild, PenaltyChild : TMDIChild;
                            const fZones, fZoneTarget, fZoneContrib, fPenalty, fZoneTargetsInUse, fOverallTargetsInUse : boolean;
                            var rShortfall : extended) : extended;
    function ComputeMarxanCost(const iConfiguration : integer; TestConfigurationChild,
                               PuChild : TMDIChild) : extended;
    function ComputeMarxanConnectivity(const iConfiguration : integer;
                                       const rBLM : extended;
                                       TestConfigurationChild, PuChild, BoundChild : TMDIChild) : extended;
    function ComputeMarxanPenalty(const iConfiguration,iTargetField,iPropField : integer;
                            TestConfigurationChild, PuChild, SpecChild, PuvsprChild, PenaltyChild : TMDIChild;
                            const fPenalty, fOverallTargetsInUse : boolean;
                            var rShortfall : extended) : extended;
    function ComputeMarProbPenaltyAndProbability(const iConfiguration,iTargetField,iPropField : integer;
                            TestConfigurationChild, PuChild, SpecChild, PuvsprChild, PenaltyChild : TMDIChild;
                            const fPenalty, fOverallTargetsInUse : boolean;
                            const rProbabilityWeighting : extended;
                            var rShortfall, rSummedProbability : extended) : extended;
    function FindChildIdLookupMatch(AChild : TMDIChild; iMatch : integer) : integer;
    function Find_ZBC_Element(ZoneBoundCostChild : TMDIChild; iPUID1Zone, iPUID2Zone : integer) : extended;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MarZoneSystemTestForm: TMarZoneSystemTestForm;

implementation

uses MAIN, Dbmisc, Math, ds;

{$R *.DFM}


function TMarZoneSystemTestForm.ComputeMarZoneCost(const iConfiguration : integer; TestConfigurationChild,
                                            PuChild, CostsChild, ZoneCostChild : TMDIChild) : extended;
var
   iCount, iZCCount, iZone, iMatchZone, iCost : integer;
   rCost, rCostMultiplier, rCostValue : extended;
begin
     // compute the cost of this zonation system
     rCost := 0;

     for iCount := 1 to (TestConfigurationChild.aGrid.RowCount - 1) do
     begin
          iZone := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iCount]);

          for iZCCount := 1 to (ZoneCostChild.aGrid.RowCount - 1) do
          begin
               iMatchZone := StrToInt(ZoneCostChild.aGrid.Cells[0,iZCCount]);

               if (iMatchZone = iZone) then
               begin
                    iCost := StrToInt(ZoneCostChild.aGrid.Cells[1,iZCCount]);
                    rCostMultiplier := StrToFloat(ZoneCostChild.aGrid.Cells[2,iZCCount]);

                    rCostValue := StrToFloat(PuChild.aGrid.Cells[iCost,iCount]);

                    rCost := rCost + (rCostMultiplier * rCostValue);
               end;
          end;
     end;

     Result := rCost;
end;

function TMarZoneSystemTestForm.ComputeMarxanCost(const iConfiguration : integer; TestConfigurationChild,
                                                  PuChild : TMDIChild) : extended;
var
   iCount, iStatus, iCostField : integer;
   rCost, rCostValue : extended;
begin
     // compute the cost of this reserve system
     rCost := 0;

     // find cost field
     iCostField := 0;
     for iCount := 1 to (PuChild.aGrid.ColCount - 1) do
     begin
          if (PuChild.aGrid.Cells[iCount,0] = 'cost') then
             iCostField := iCount;
     end;

     if (iCostField > 0) then
        for iCount := 1 to (TestConfigurationChild.aGrid.RowCount - 1) do
        begin
             iStatus := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iCount]);

             if (iStatus = 1) then
             begin
                  rCostValue := StrToFloat(PuChild.aGrid.Cells[iCostField,iCount]);

                  rCost := rCost + rCostValue;
             end;
        end;

     Result := rCost;
end;

function TMarZoneSystemTestForm.FindChildIdLookupMatch(AChild : TMDIChild; iMatch : integer) : integer;
var
   iCentre, iCount, iCentreValue, iTop, iBottom : integer;
   fLoop : boolean;
begin
     // use a binary search to find the index of planning unit iMatch in PuChild
     // assumes id field of PuChild is in numeric order

     iTop := 1;
     iBottom := AChild.aGrid.RowCount - 1;

     iCentre := iTop + floor((iBottom - iTop) / 2);

     iCentreValue := StrToInt(AChild.aGrid.Cells[0,iCentre]);

     fLoop := True;

     while ((iTop <= iBottom) and (iCentreValue <> iMatch) and fLoop) do
     begin
          if (iMatch < iCentreValue) then
          begin
               iBottom := iCentre - 1;
               if (iBottom < iTop) then
               begin
                    iBottom := iTop;
                    fLoop := False;
               end;
               iCount := iBottom - iTop + 1;
               iCentre := iTop + floor(iCount / 2);
          end
          else
          begin
               iTop := iCentre + 1;
               if (iTop > iBottom) then
               begin
                    iTop := iBottom;
                    fLoop := False;
               end;
               iCount := iBottom - iTop + 1;
               iCentre := iTop + floor(iCount / 2);
          end;

          iCentreValue := StrToInt(AChild.aGrid.Cells[0,iCentre]);
     end;

     if (iCentreValue = iMatch) then
        Result := iCentre
     else
         Result := -1;
end;


function TMarZoneSystemTestForm.Find_ZBC_Element(ZoneBoundCostChild : TMDIChild; iPUID1Zone, iPUID2Zone : integer) : extended;
var
   iCount, iZone1, iZone2 : integer;
   rMatch : extended;
begin
     // find a matching boundary entry for this pair of zones else return 0
     rMatch := 0;

     for iCount := 1 to (ZoneBoundCostChild.aGrid.RowCount - 1) do
     begin
          iZone1 := StrToInt(ZoneBoundCostChild.aGrid.Cells[0,iCount]);
          iZone2 := StrToInt(ZoneBoundCostChild.aGrid.Cells[1,iCount]);

          if ((iZone1 = iPUID1Zone) and (iZone2 = iPUID2Zone)) or ((iZone1 = iPUID2Zone) and (iZone2 = iPUID1Zone)) then
             rMatch := StrToFloat(ZoneBoundCostChild.aGrid.Cells[2,iCount]);
     end;

     Result := rMatch;
end;

function TMarZoneSystemTestForm.ComputeMarZoneConnectivity(const iConfiguration : integer; TestConfigurationChild,
                                                    PuChild, BoundChild, ZoneBoundCostChild : TMDIChild) : extended;
var
   rConnectivity, rBoundary, rZoneBoundCost : extended;
   iCount, iId1Index, iId2Index, iPUID1, iPUID2, iPUID1Zone, iPUID2Zone : integer;
begin
     // compute the connectivity of this zonation system
     rConnectivity := 0;

     for iCount := 1 to (BoundChild.aGrid.RowCount - 1) do
     begin
          iPUID1 := StrToInt(BoundChild.aGrid.Cells[0,iCount]);
          iPUID2 := StrToInt(BoundChild.aGrid.Cells[1,iCount]);
          rBoundary := StrToFloat(BoundChild.aGrid.Cells[2,iCount]);

          if (iPUID1 = iPUID2) then
             rZoneBoundCost := 1 // don't apply zone boundary cost for fixed boundaries
          else
          begin
               // lookup indices for planning units in the connection
               iId1Index := FindChildIdLookupMatch(PuChild,iPUID1);
               iId2Index := FindChildIdLookupMatch(PuChild,iPUID2);

               // find zone for these planning units in the configuration
               iPUID1Zone := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iId1Index]);
               iPUID2Zone := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iId2Index]);

               // find appropriate zone boundary cost weighting for this pair of zones
               rZoneBoundCost := Find_ZBC_Element(ZoneBoundCostChild,iPUID1Zone,iPUID2Zone);
          end;

          if (rZoneBoundCost > 0) then
             rConnectivity := rConnectivity + (rBoundary * rZoneBoundCost);
     end;

     Result := rConnectivity;
end;

function TMarZoneSystemTestForm.ComputeMarxanConnectivity(const iConfiguration : integer;
                                                          const rBLM : extended;
                                                          TestConfigurationChild, PuChild, BoundChild : TMDIChild) : extended;
var
   rConnectivity, rBoundary : extended;
   iCount, iId1Index, iId2Index, iPUID1, iPUID2, iPUID1Status, iPUID2Status : integer;
begin
     // compute the connectivity of this reserve system
     rConnectivity := 0;

     for iCount := 1 to (BoundChild.aGrid.RowCount - 1) do
     begin
          iPUID1 := StrToInt(BoundChild.aGrid.Cells[0,iCount]);
          iPUID2 := StrToInt(BoundChild.aGrid.Cells[1,iCount]);
          rBoundary := StrToFloat(BoundChild.aGrid.Cells[2,iCount]);

          if (iPUID1 = iPUID2) then
          begin
               iId1Index := FindChildIdLookupMatch(PuChild,iPUID1);
               iPUID1Status := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iId1Index]);

               if (iPUID1Status = 1) then
                  rConnectivity := rConnectivity + rBoundary;
          end
          else
          begin
               // lookup indices for planning units in the connection
               iId1Index := FindChildIdLookupMatch(PuChild,iPUID1);
               iId2Index := FindChildIdLookupMatch(PuChild,iPUID2);

               // find status for these planning units in the configuration
               iPUID1Status := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iId1Index]);
               iPUID2Status := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iId2Index]);

               if (iPUID1Status <> iPUID2Status) then
                  rConnectivity := rConnectivity + rBoundary;
          end;
     end;

     Result := rConnectivity * rBLM;
end;

function TMarZoneSystemTestForm.ComputeMarZonePenalty(const iConfiguration,iTargetField,iPropField : integer;
                            TestConfigurationChild, PuChild, SpecChild, PuvsprChild, ZonesChild, ZoneTargetChild, ZoneContribChild, PenaltyChild : TMDIChild;
                            const fZones, fZoneTarget, fZoneContrib, fPenalty, fZoneTargetsInUse, fOverallTargetsInUse : boolean;
                            var rShortfall : extended) : extended;
var
   rPenalty, rMarxanPenalty, rSPF, rFeaturePenalty, rTA, rTA_zones, rtarg,
   rtarg_zones, rZC, rAmount, rShortfallFraction, rFeatureShortfallFraction,
   rTargetField, rFeatureShortfall, rContribAmount : extended;
   iCount, iCount2, iSpeciesCount, iZoneCount, iArraySize, iSPID, iPUID, iPUID_index, iPU_index,
   iZoneId, iSP_index, iArrayIndex, iTargetType, iShortfall, iSPF_Field : integer;
   TA, TA_zones, targ, targ_zones, ZC, Pen, CA : Array_t;
   sSummaryFileName : string;
   SummaryFile, ShortFallFile, ZoneContribFile : TextFile;
begin
     // compute the penalty of this zonation system
     rPenalty := 0;
     rMarxanPenalty := 1;
     rTA := 0;
     rTA_zones := 0;
     rtarg := 0;
     rtarg_zones := 0;
     rZC := 0;
     rContribAmount := 0;
     iPUID_index := -1;
     iZoneId := 0;
     iSpeciesCount := SpecChild.aGrid.RowCount - 1;
     iZoneCount := ZonesChild.aGrid.RowCount - 1;
     iArraySize := iSpeciesCount * iZoneCount;

     // init configuration output file
     sSummaryFileName := Copy(TestConfigurationChild.Caption,1,
                              Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                              '_summary_' + IntToStr(iConfiguration) + '.csv';
     assignfile(SummaryFile,sSummaryFileName);
     rewrite(SummaryFile);
     write(SummaryFile,'SPID,area,target');
     for iCount := 1 to iZoneCount do
         write(SummaryFile,',area_' + ZonesChild.aGrid.Cells[1,iCount] + ',target_' + ZonesChild.aGrid.Cells[1,iCount]);
     writeln(SummaryFile,',area_contrib');
     // init shortfall output file
     sSummaryFileName := Copy(TestConfigurationChild.Caption,1,
                              Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                              '_shortfall_' + IntToStr(iConfiguration) + '.csv';
     assignfile(ShortFallFile,sSummaryFileName);
     rewrite(ShortFallFile);
     writeln(ShortFallFile,'SPID,zone,area,target,shortfall');
     // init zone contrib output file
     sSummaryFileName := Copy(TestConfigurationChild.Caption,1,
                              Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                              '_zonecontrib_' + IntToStr(iConfiguration) + '.csv';
     assignfile(ZoneContribFile,sSummaryFileName);
     rewrite(ZoneContribFile);
     write(ZoneContribFile,'zoneid');
     for iCount := 1 to iZoneCount do
         write(ZoneContribFile,',fraction_' + ZonesChild.aGrid.Cells[1,iCount]);
     writeln(ZoneContribFile);

     // init totalareas, targets, zone contrib, contrib area & penalty arrays
     TA := Array_t.Create;
     TA.init(SizeOf(extended),iSpeciesCount);
     targ := Array_t.Create;
     targ.init(SizeOf(extended),iSpeciesCount);
     TA_zones := Array_t.Create;
     TA_zones.init(SizeOf(extended),iArraySize);
     targ_zones := Array_t.Create;
     targ_zones.init(SizeOf(extended),iArraySize);
     ZC := Array_t.Create;
     ZC.init(SizeOf(extended),iArraySize);
     Pen := Array_t.Create;
     Pen.init(SizeOf(extended),iSpeciesCount);
     CA := Array_t.Create;
     CA.init(SizeOf(extended),iSpeciesCount);

     for iCount := 1 to iSpeciesCount do
     begin
          TA.setValue(iCount,@rTA);
          targ.setValue(iCount,@rtarg);
          Pen.setValue(iCount,@rMarxanPenalty);
          CA.setValue(iCount,@rContribAmount);
     end;
     for iCount := 1 to iArraySize do
     begin
          TA_zones.setValue(iCount,@rTA_zones);
          targ_zones.setValue(iCount,@rtarg_zones);
          ZC.setValue(iCount,@rZC);
     end;

     // parse zone contrib
     for iCount := 1 to (ZoneContribChild.aGrid.RowCount - 1) do
     begin
          iZoneId := StrToInt(ZoneContribChild.aGrid.Cells[0,iCount]);
          iSPID := StrToInt(ZoneContribChild.aGrid.Cells[1,iCount]);
          rZC := StrToFloat(ZoneContribChild.aGrid.Cells[2,iCount]);

          iSP_index := FindChildIdLookupMatch(SpecChild,iSPID);

          iArrayIndex := (iSpeciesCount * (iZoneId - 1)) + iSP_index;

          ZC.setValue(iArrayIndex,@rZC);
     end;
     // dump zone contrib debug file
     for iCount := 1 to iSpeciesCount do
     begin
          iSP_index := StrToInt(SpecChild.aGrid.Cells[0,iCount]);

          write(ZoneContribFile,IntToStr(iSP_index));
          for iCount2 := 1 to iZoneCount do
          begin
               iArrayIndex := (iSpeciesCount * (iCount2 - 1)) + iSP_index;
               ZC.rtnValue(iArrayIndex,@rZC);

               write(ZoneContribFile,',' + FloatToStr(rZC));
          end;
          writeln(ZoneContribFile);
     end;
     closefile(ZoneContribFile);

     // parse penalty
     if fPenalty then
        for iCount := 1 to (PenaltyChild.aGrid.RowCount - 1) do
        begin
             iSPID := StrToInt(PenaltyChild.aGrid.Cells[0,iCount]);
             rMarxanPenalty := StrToFloat(PenaltyChild.aGrid.Cells[1,iCount]);

             iSP_index := FindChildIdLookupMatch(SpecChild,iSPID);

             Pen.setValue(iSP_index,@rMarxanPenalty);
        end;

     // compute total areas
     for iCount := 1 to (PuvsprChild.aGrid.RowCount - 1) do
     begin
          iSPID := StrToInt(PuvsprChild.aGrid.Cells[0,iCount]);
          iPUID := StrToInt(PuvsprChild.aGrid.Cells[1,iCount]);
          rAmount := StrToFloat(PuvsprChild.aGrid.Cells[2,iCount]);

          if (iPUID_index <> iPUID) then
          begin
               // lookup index and zone of this planning unit
               iPU_index := FindChildIdLookupMatch(PuChild,iPUID);
               iPUID_index := iPUID;
               iZoneId := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iPU_index]);
          end;

          // find species index
          iSP_index := FindChildIdLookupMatch(SpecChild,iSPID);

          TA.rtnValue(iSP_index,@rTA);
          rTA := rTA + rAmount;
          TA.setValue(iSP_index,@rTA);

          iArrayIndex := (iSpeciesCount * (iZoneId - 1)) + iSP_index;
          TA_zones.rtnValue(iArrayIndex,@rTA_zones);
          rTA_zones := rTA_zones + rAmount;
          TA_zones.setValue(iArrayIndex,@rTA_zones);
     end;

     // compute targets
     // if prop field is in spec.dat or targettype in zonetarget.dat is #####
     if fOverallTargetsInUse then
        for iCount := 1 to iSpeciesCount do
        begin
             rtarg := 0;

             if (iTargetField > 0) then
                rtarg := StrToFloat(SpecChild.aGrid.Cells[iTargetField,iCount]);

             if (iPropField > 0) then
             begin
                  rTargetField := StrToFloat(SpecChild.aGrid.Cells[iPropField,iCount]);
                  TA.rtnValue(iCount,@rTA);

                  rtarg := rTA * rTargetField;
             end;

             targ.setValue(iCount,@rtarg);
        end;

     if fZoneTargetsInUse then
        for iCount := 1 to (ZoneTargetChild.aGrid.RowCount - 1) do
        begin
             // traverse zonetarget.dat
             iZoneId := StrToInt(ZoneTargetChild.aGrid.Cells[0,iCount]);
             iSPID := StrToInt(ZoneTargetChild.aGrid.Cells[1,iCount]);
             rTargetField := StrToFloat(ZoneTargetChild.aGrid.Cells[2,iCount]);
             if (ZoneTargetChild.aGrid.ColCount > 3) then
                iTargetType := StrToInt(ZoneTargetChild.aGrid.Cells[3,iCount])
             else
                 iTargetType := 0;

             iSP_index := FindChildIdLookupMatch(SpecChild,iSPID);
             iArrayIndex := (iSpeciesCount * (iZoneId - 1)) + iSP_index;

             if (iTargetType = 0) then  // 0 areal
             begin
                  targ_zones.setValue(iArrayIndex,@rTargetField);
             end;

             if (iTargetType = 1) then  // 1 proportion
             begin
                  //TA_zones.rtnValue(iArrayIndex,@rTA_zones);
                  TA.rtnValue(iSP_index,@rTA);

                  //rtarg_zones := rTA_zones * rTargetField;
                  rtarg_zones := rTA * rTargetField;

                  targ_zones.setValue(iArrayIndex,@rtarg_zones);
             end;
        end;

     // which spec field is SPF
     for iCount := 1 to (SpecChild.aGrid.ColCount - 1) do
         if (SpecChild.aGrid.Cells[iCount,0] = 'spf') then
            iSPF_Field := iCount;

     // compute target shortfall
     rShortfall := 0;
     rShortfallFraction := 0;
     rPenalty := 0;
     for iCount := 1 to iSpeciesCount do
     begin
          iShortfall := 0;
          rContribAmount := 0;

          for iCount2 := 2 to iZoneCount do
          begin
               iArrayIndex := (iSpeciesCount * (iCount2 - 1)) + iCount;
               ZC.rtnValue(iArrayIndex,@rZC);
               TA_zones.rtnValue(iArrayIndex,@rTA_zones);

               rContribAmount := rContribAmount + (rZC * rTA_zones);
          end;

          targ.rtnValue(iCount,@rtarg);
          if (rtarg > 0) then
          begin
               if (rtarg > rContribAmount) then
               begin
                    rFeatureShortfall := rtarg - rContribAmount;

                    rShortfall := rShortfall + rFeatureShortfall;
                    rFeatureShortfallFraction := rFeatureShortfall / rtarg;
                    rShortfallFraction := rShortfallFraction + rFeatureShortfallFraction;
                    iShortfall := iShortfall + 1;

                    writeln(ShortFallFile,SpecChild.aGrid.Cells[0,iCount] + ',' +
                                          '0,' +
                                          FloatToStr(rContribAmount) + ',' +
                                          FloatToStr(rtarg) + ',' +
                                          FloatToStr(rFeatureShortfall));
                                          //'SPID,zone,area,target,shortfall');
               end;
          end;

          CA.setValue(iCount,@rContribAmount);

          for iCount2 := 1 to iZoneCount do
          begin
               iArrayIndex := (iSpeciesCount * (iCount2 - 1)) + iCount;
               TA_zones.rtnValue(iArrayIndex,@rTA_zones);
               targ_zones.rtnValue(iArrayIndex,@rtarg_zones);

               if (rtarg_zones > 0) then
               begin
                    if (rtarg_zones > rTA_zones) then
                    begin
                         rFeatureShortfall := rtarg_zones - rTA_zones;

                         rShortfall := rShortfall + rFeatureShortfall;
                         rFeatureShortfallFraction := rFeatureShortfall / rtarg_zones;
                         rShortfallFraction := rShortfallFraction + rFeatureShortfallFraction;
                         iShortfall := iShortfall + 1;

                         writeln(ShortFallFile,SpecChild.aGrid.Cells[0,iCount] + ',' +
                                               IntToStr(iCount2) + ',' +
                                               FloatToStr(rTA_zones) + ',' +
                                               FloatToStr(rtarg_zones) + ',' +
                                               FloatToStr(rFeatureShortfall));
                                               //'SPID,zone,area,target,shortfall');
                    end;
               end;
          end;

          Pen.rtnValue(iCount,@rMarxanPenalty);
          rSPF := StrToFloat(SpecChild.aGrid.Cells[iSPF_Field,iCount]);

          // compute penalty for this target shortfall
          if (iShortfall > 1) then
             rFeaturePenalty := (rShortfallFraction / iShortfall) * rMarxanPenalty * rSPF
          else
              rFeaturePenalty := 0;

          rPenalty := rPenalty + rFeaturePenalty;
     end;
     closefile(ShortFallFile);

     // write total areas and targets to summary file
     for iCount := 1 to iSpeciesCount do
     begin
          TA.rtnValue(iCount,@rTA);
          targ.rtnValue(iCount,@rtarg);

          write(SummaryFile,SpecChild.aGrid.Cells[0,iCount] + ',' + FloatToStr(rTA) + ',' + FloatToStr(rtarg));

          for iCount2 := 1 to iZoneCount do
          begin
               iArrayIndex := (iSpeciesCount * (iCount2 - 1)) + iCount;
               TA_zones.rtnValue(iArrayIndex,@rTA_zones);
               targ_zones.rtnValue(iArrayIndex,@rtarg_zones);

               write(SummaryFile,',' + FloatToStr(rTA_zones) + ',' + FloatToStr(rtarg_zones));
          end;

          CA.rtnValue(iCount,@rContribAmount);

          writeln(SummaryFile,',' + FloatToStr(rContribAmount));
     end;
     closefile(SummaryFile);

     TA.Destroy;
     TA_zones.Destroy;
     targ.Destroy;
     targ_zones.Destroy;
     ZC.Destroy;
     Pen.Destroy;
     CA.Destroy;

     Result := rPenalty;
end;

function TMarZoneSystemTestForm.ComputeMarxanPenalty(const iConfiguration,iTargetField,iPropField : integer;
                            TestConfigurationChild, PuChild, SpecChild, PuvsprChild, PenaltyChild : TMDIChild;
                            const fPenalty, fOverallTargetsInUse : boolean;
                            var rShortfall : extended) : extended;
var
   rPenalty, rMarxanPenalty, rSPF, rFeaturePenalty, rTA, rTA_zones, rtarg,
   rtarg_zones, rAmount, rShortfallFraction, rFeatureShortfallFraction,
   rTargetField, rFeatureShortfall, rContribAmount : extended;
   iCount, iCount2, iSpeciesCount, iSPID, iPUID, iPUID_index, iPU_index,
   iStatus, iSP_index, iTargetType, iShortfall, iSPF_Field : integer;
   TA, targ, Pen, CA : Array_t;
   sSummaryFileName : string;
   SummaryFile, ShortFallFile : TextFile;
begin
     // compute the penalty of this zonation system
     rPenalty := 0;
     rMarxanPenalty := 1;
     rTA := 0;
     rTA_zones := 0;
     rtarg := 0;
     rtarg_zones := 0;
     rContribAmount := 0;
     iPUID_index := -1;
     iStatus := 0;
     iSpeciesCount := SpecChild.aGrid.RowCount - 1;

     // init configuration output file
     sSummaryFileName := Copy(TestConfigurationChild.Caption,1,
                              Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                              '_summary_' + IntToStr(iConfiguration) + '.csv';
     assignfile(SummaryFile,sSummaryFileName);
     rewrite(SummaryFile);
     writeln(SummaryFile,'SPID,total area,target,contributing area');
     // init shortfall output file
     sSummaryFileName := Copy(TestConfigurationChild.Caption,1,
                              Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                              '_shortfall_' + IntToStr(iConfiguration) + '.csv';
     assignfile(ShortFallFile,sSummaryFileName);
     rewrite(ShortFallFile);
     writeln(ShortFallFile,'SPID,contributing area,target,shortfall');

     // init totalareas, targets, zone contrib, contrib area & penalty arrays
     TA := Array_t.Create;
     TA.init(SizeOf(extended),iSpeciesCount);
     targ := Array_t.Create;
     targ.init(SizeOf(extended),iSpeciesCount);
     Pen := Array_t.Create;
     Pen.init(SizeOf(extended),iSpeciesCount);
     CA := Array_t.Create;
     CA.init(SizeOf(extended),iSpeciesCount);

     for iCount := 1 to iSpeciesCount do
     begin
          TA.setValue(iCount,@rTA);
          targ.setValue(iCount,@rtarg);
          Pen.setValue(iCount,@rMarxanPenalty);
          CA.setValue(iCount,@rContribAmount);
     end;

     // parse penalty
     if fPenalty then
        for iCount := 1 to (PenaltyChild.aGrid.RowCount - 1) do
        begin
             iSPID := StrToInt(PenaltyChild.aGrid.Cells[0,iCount]);
             rMarxanPenalty := StrToFloat(PenaltyChild.aGrid.Cells[1,iCount]);

             iSP_index := FindChildIdLookupMatch(SpecChild,iSPID);

             Pen.setValue(iSP_index,@rMarxanPenalty);
        end;

     // compute total areas and contributing area
     for iCount := 1 to (PuvsprChild.aGrid.RowCount - 1) do
     begin
          iSPID := StrToInt(PuvsprChild.aGrid.Cells[0,iCount]);
          iPUID := StrToInt(PuvsprChild.aGrid.Cells[1,iCount]);
          rAmount := StrToFloat(PuvsprChild.aGrid.Cells[2,iCount]);

          if (iPUID_index <> iPUID) then
          begin
               // lookup index and status of this planning unit
               iPU_index := FindChildIdLookupMatch(PuChild,iPUID);
               iPUID_index := iPUID;
               iStatus := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iPU_index]);
          end;

          // find species index
          iSP_index := FindChildIdLookupMatch(SpecChild,iSPID);

          TA.rtnValue(iSP_index,@rTA);
          rTA := rTA + rAmount;
          TA.setValue(iSP_index,@rTA);

          if (iStatus = 1) then
          begin
               CA.rtnValue(iSP_index,@rContribAmount);
               rContribAmount := rContribAmount + rAmount;
               CA.setValue(iSP_index,@rContribAmount);
          end;
     end;

     // compute targets
     // if prop field is in spec.dat or targettype in zonetarget.dat is #####
     if fOverallTargetsInUse then
        for iCount := 1 to iSpeciesCount do
        begin
             rtarg := 0;

             if (iTargetField > 0) then
                rtarg := StrToFloat(SpecChild.aGrid.Cells[iTargetField,iCount]);

             if (iPropField > 0) then
             begin
                  rTargetField := StrToFloat(SpecChild.aGrid.Cells[iPropField,iCount]);
                  TA.rtnValue(iCount,@rTA);

                  rtarg := rTA * rTargetField;
             end;

             targ.setValue(iCount,@rtarg);
        end;

     // which spec field is SPF
     iSPF_Field := 0;
     for iCount := 1 to (SpecChild.aGrid.ColCount - 1) do
         if (SpecChild.aGrid.Cells[iCount,0] = 'spf') then
            iSPF_Field := iCount;

     // compute target shortfall
     rShortfall := 0;
     rShortfallFraction := 0;
     for iCount := 1 to iSpeciesCount do
     begin
          iShortfall := 0;

          CA.rtnValue(iCount,@rContribAmount);

          targ.rtnValue(iCount,@rtarg);
          if (rtarg > 0) then
          begin
               if (rtarg > rContribAmount) then
               begin
                    rFeatureShortfall := rtarg - rContribAmount;

                    rShortfall := rShortfall + rFeatureShortfall;
                    rFeatureShortfallFraction := rFeatureShortfall / rtarg;
                    rShortfallFraction := rShortfallFraction + rFeatureShortfallFraction;
                    iShortfall := iShortfall + 1;

                    writeln(ShortFallFile,SpecChild.aGrid.Cells[0,iCount] + ',' +
                                          FloatToStr(rContribAmount) + ',' +
                                          FloatToStr(rtarg) + ',' +
                                          FloatToStr(rFeatureShortfall));
                                          //'SPID,zone,area,target,shortfall');
               end;
          end;

          Pen.rtnValue(iCount,@rMarxanPenalty);
          rSPF := StrToFloat(SpecChild.aGrid.Cells[iSPF_Field,iCount]);

          // compute penalty for this target shortfall
          if (iShortfall > 1) then
             rFeaturePenalty := (rShortfallFraction / iShortfall) * rMarxanPenalty * rSPF
          else
              rFeaturePenalty := 0;

          rPenalty := rPenalty + rFeaturePenalty;
     end;
     closefile(ShortFallFile);

     // write total areas and targets to summary file
     for iCount := 1 to iSpeciesCount do
     begin
          TA.rtnValue(iCount,@rTA);
          targ.rtnValue(iCount,@rtarg);
          CA.rtnValue(iCount,@rContribAmount);

          writeln(SummaryFile,SpecChild.aGrid.Cells[0,iCount] + ',' +
                              FloatToStr(rTA) + ',' +
                              FloatToStr(rtarg) + ',' +
                              FloatToStr(rContribAmount));
     end;
     closefile(SummaryFile);

     TA.Destroy;
     targ.Destroy;
     Pen.Destroy;
     CA.Destroy;

     Result := rPenalty;
end;

function probZUT(const z : extended) : extended;
// Probability that a standard normal random variable has value >= z
// (i.e. the area under the standard normal curve for Z in [z,+inf]

// Originally adapted by Gary Perlman from a polynomial approximation in:
// Ibbetson D, Algorithm 209
// Collected Algorithms of the CACM 1963 p. 616
// Adapted (returns upper tail instead of lower tail)

// This function is not copyrighted
var
   Z_MAX, y, x, w, rResult : extended;
begin
     Z_MAX := 5;

     if (z = 0) then
        x := 0
     else
     begin
          y := 0.5 * abs (z);
          if (y >= (Z_MAX * 0.5)) then
             x := 1
          else
              if (y < 1) then
              begin
                   w := y*y;
                   x := ((((((((0.000124818987 * w
                         -0.001075204047) * w +0.005198775019) * w
                         -0.019198292004) * w +0.059054035642) * w
                         -0.151968751364) * w +0.319152932694) * w
                         -0.531923007300) * w +0.797884560593) * y * 2.0;
              end
              else
              begin
                   y := y - 2;
                   x := (((((((((((((-0.000045255659 * y
                         +0.000152529290) * y -0.000019538132) * y
                         -0.000676904986) * y +0.001390604284) * y
                         -0.000794620820) * y -0.002034254874) * y
                         +0.006549791214) * y -0.010557625006) * y
                         +0.011630447319) * y -0.009279453341) * y
                         +0.005353579108) * y -0.002141268741) * y
                         +0.000535310849) * y +0.999936657524;
              end;
     end;

     if (z < 0) then
        rResult := ((x + 1) * 0.5)
     else
         rResult := ((1 - x) * 0.5);

     Result := rResult;
end;

function TMarZoneSystemTestForm.ComputeMarProbPenaltyAndProbability(const iConfiguration,iTargetField,iPropField : integer;
                            TestConfigurationChild, PuChild, SpecChild, PuvsprChild, PenaltyChild : TMDIChild;
                            const fPenalty, fOverallTargetsInUse : boolean;
                            const rProbabilityWeighting : extended;
                            var rShortfall, rSummedProbability : extended) : extended;
var
   rPenalty, rMarxanPenalty, rSPF, rFeaturePenalty, rTA, rTA_zones, rtarg,
   rtarg_zones, rAmount, rShortfallFraction, rFeatureShortfallFraction,
   rTargetField, rFeatureShortfall, rContribAmount,
   rExpectedAmount, rVarianceInExpectedAmount, rProb, rProbability, rZScore : extended;
   iCount, iCount2, iSpeciesCount, iSPID, iPUID, iPUID_index, iPU_index,
   iStatus, iSP_index, iTargetType, iShortfall, iSPF_Field, iProbField : integer;
   TA, targ, Pen, CA, EA, VIEA, PR : Array_t;
   sSummaryFileName : string;
   SummaryFile, ShortFallFile : TextFile;
begin
     // compute the penalty of this zonation system
     rPenalty := 0;
     rMarxanPenalty := 1;
     rTA := 0;
     rTA_zones := 0;
     rtarg := 0;
     rtarg_zones := 0;
     rContribAmount := 0;
     rExpectedAmount := 0;
     rVarianceInExpectedAmount := 0;
     rSummedProbability := 0;
     rProbability := 0;
     iPUID_index := -1;
     iStatus := 0;
     iSpeciesCount := SpecChild.aGrid.RowCount - 1;

     // init configuration output file
     sSummaryFileName := Copy(TestConfigurationChild.Caption,1,
                              Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                              '_summary_' + IntToStr(iConfiguration) + '.csv';
     assignfile(SummaryFile,sSummaryFileName);
     rewrite(SummaryFile);
     writeln(SummaryFile,'SPID,total area,target,contributing area,expected amount,variance in expected amount,probability');
     // init shortfall output file
     sSummaryFileName := Copy(TestConfigurationChild.Caption,1,
                              Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                              '_shortfall_' + IntToStr(iConfiguration) + '.csv';
     assignfile(ShortFallFile,sSummaryFileName);
     rewrite(ShortFallFile);
     writeln(ShortFallFile,'SPID,contributing area,target,shortfall');

     // init totalareas, targets, zone contrib, contrib area & penalty arrays
     TA := Array_t.Create;
     TA.init(SizeOf(extended),iSpeciesCount);
     targ := Array_t.Create;
     targ.init(SizeOf(extended),iSpeciesCount);
     Pen := Array_t.Create;
     Pen.init(SizeOf(extended),iSpeciesCount);
     CA := Array_t.Create;
     CA.init(SizeOf(extended),iSpeciesCount);
     EA := Array_t.Create;
     EA.init(SizeOf(extended),iSpeciesCount);
     VIEA := Array_t.Create;
     VIEA.init(SizeOf(extended),iSpeciesCount);
     PR := Array_t.Create;
     PR.init(SizeOf(extended),iSpeciesCount);

     for iCount := 1 to iSpeciesCount do
     begin
          TA.setValue(iCount,@rTA);
          targ.setValue(iCount,@rtarg);
          Pen.setValue(iCount,@rMarxanPenalty);
          CA.setValue(iCount,@rContribAmount);
          EA.setValue(iCount,@rExpectedAmount);
          VIEA.setValue(iCount,@rVarianceInExpectedAmount);
          PR.setValue(iCount,@rProbability);
     end;

     // parse penalty
     if fPenalty then
        for iCount := 1 to (PenaltyChild.aGrid.RowCount - 1) do
        begin
             iSPID := StrToInt(PenaltyChild.aGrid.Cells[0,iCount]);
             rMarxanPenalty := StrToFloat(PenaltyChild.aGrid.Cells[1,iCount]);

             iSP_index := FindChildIdLookupMatch(SpecChild,iSPID);

             Pen.setValue(iSP_index,@rMarxanPenalty);
        end;

     // which field is PROB
     iProbField := 0;
     for iCount := 1 to (PuChild.aGrid.ColCount - 1) do
         if (PuChild.aGrid.Cells[iCount,0] = 'prob') then
            iProbField := iCount;

     // compute total areas and contributing area
     for iCount := 1 to (PuvsprChild.aGrid.RowCount - 1) do
     begin
          iSPID := StrToInt(PuvsprChild.aGrid.Cells[0,iCount]);
          iPUID := StrToInt(PuvsprChild.aGrid.Cells[1,iCount]);
          rAmount := StrToFloat(PuvsprChild.aGrid.Cells[2,iCount]);

          if (iPUID_index <> iPUID) then
          begin
               // lookup index, status & probability of this planning unit
               iPU_index := FindChildIdLookupMatch(PuChild,iPUID);
               iPUID_index := iPUID;
               iStatus := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iPU_index]);
               rProb := StrToFloat(PuChild.aGrid.Cells[iProbField,iPU_index]);
          end;

          // find species index
          iSP_index := FindChildIdLookupMatch(SpecChild,iSPID);

          TA.rtnValue(iSP_index,@rTA);
          rTA := rTA + rAmount;
          TA.setValue(iSP_index,@rTA);

          if (iStatus = 1) then
          begin
               CA.rtnValue(iSP_index,@rContribAmount);
               rContribAmount := rContribAmount + rAmount;
               CA.setValue(iSP_index,@rContribAmount);

               EA.rtnValue(iSP_index,@rExpectedAmount);
               rExpectedAmount := rExpectedAmount + (rAmount * rProb);
               EA.setValue(iSP_index,@rExpectedAmount);

               VIEA.rtnValue(iSP_index,@rVarianceInExpectedAmount);
               rVarianceInExpectedAmount := rVarianceInExpectedAmount + (rAmount * rAmount * rProb * (1 - rProb));
               VIEA.setValue(iSP_index,@rVarianceInExpectedAmount);
          end;
     end;

     // compute targets
     // if prop field is in spec.dat or targettype in zonetarget.dat is #####
     if fOverallTargetsInUse then
        for iCount := 1 to iSpeciesCount do
        begin
             rtarg := 0;

             if (iTargetField > 0) then
                rtarg := StrToFloat(SpecChild.aGrid.Cells[iTargetField,iCount]);

             if (iPropField > 0) then
             begin
                  rTargetField := StrToFloat(SpecChild.aGrid.Cells[iPropField,iCount]);
                  TA.rtnValue(iCount,@rTA);

                  rtarg := rTA * rTargetField;
             end;

             targ.setValue(iCount,@rtarg);
        end;

     // which spec field is SPF
     iSPF_Field := 0;
     for iCount := 1 to (SpecChild.aGrid.ColCount - 1) do
         if (SpecChild.aGrid.Cells[iCount,0] = 'spf') then
            iSPF_Field := iCount;

     // compute target shortfall and probability
     rShortfall := 0;
     rShortfallFraction := 0;
     for iCount := 1 to iSpeciesCount do
     begin
          iShortfall := 0;

          CA.rtnValue(iCount,@rContribAmount);

          targ.rtnValue(iCount,@rtarg);
          if (rtarg > 0) then
          begin
               if (rtarg > rContribAmount) then
               begin
                    rFeatureShortfall := rtarg - rContribAmount;

                    rShortfall := rShortfall + rFeatureShortfall;
                    rFeatureShortfallFraction := rFeatureShortfall / rtarg;
                    rShortfallFraction := rShortfallFraction + rFeatureShortfallFraction;
                    iShortfall := iShortfall + 1;

                    writeln(ShortFallFile,SpecChild.aGrid.Cells[0,iCount] + ',' +
                                          FloatToStr(rContribAmount) + ',' +
                                          FloatToStr(rtarg) + ',' +
                                          FloatToStr(rFeatureShortfall));
                                          //'SPID,zone,area,target,shortfall');
               end;
          end;

          Pen.rtnValue(iCount,@rMarxanPenalty);
          rSPF := StrToFloat(SpecChild.aGrid.Cells[iSPF_Field,iCount]);

          // compute penalty for this target shortfall
          if (iShortfall > 1) then
             rFeaturePenalty := (rShortfallFraction / iShortfall) * rMarxanPenalty * rSPF
          else
              rFeaturePenalty := 0;

          rPenalty := rPenalty + rFeaturePenalty;

          // compute probability for this species
          if (rtarg > 0) then
          begin
               EA.rtnValue(iCount,@rExpectedAmount);
               VIEA.rtnValue(iCount,@rVarianceInExpectedAmount);

               if (rVarianceInExpectedAmount > 0) then
                  rZScore := (rtarg - rExpectedAmount) / sqrt(rVarianceInExpectedAmount)
               else
                   rZScore := 4;

               if (rZScore >= 0) then
                  rProbability := probZUT(rZScore)
               else
                   rProbability := 1 - probZUT(-1 * rZScore);

               //rSumProbability += (1 - rProbability);
               rSummedProbability := rSummedProbability + rProbability;

               PR.setValue(iCount,@rProbability);
          end;
     end;
     closefile(ShortFallFile);

     // write total areas and targets to summary file
     for iCount := 1 to iSpeciesCount do
     begin
          TA.rtnValue(iCount,@rTA);
          targ.rtnValue(iCount,@rtarg);
          CA.rtnValue(iCount,@rContribAmount);
          EA.rtnValue(iCount,@rExpectedAmount);
          VIEA.rtnValue(iCount,@rVarianceInExpectedAmount);
          PR.rtnValue(iCount,@rProbability);

          writeln(SummaryFile,SpecChild.aGrid.Cells[0,iCount] + ',' +
                              FloatToStr(rTA) + ',' +
                              FloatToStr(rtarg) + ',' +
                              FloatToStr(rContribAmount) + ',' +
                              FloatToStr(rExpectedAmount) + ',' +
                              FloatToStr(rVarianceInExpectedAmount) + ',' +
                              FloatToStr(rProbability));
     end;
     closefile(SummaryFile);

     TA.Destroy;
     targ.Destroy;
     Pen.Destroy;
     CA.Destroy;
     EA.Destroy;
     VIEA.Destroy;
     PR.Destroy;

     Result := rPenalty;
end;

function TMarZoneSystemTestForm.ScanInputDat(const sScanString : string) : string;
var
   iCount, iLengthRow, iLengthScanString : integer;
   sResult : string;
begin
     sResult := '';
     for iCount := 0 to (InputDatListBox.Items.Count - 1) do
         if (Pos(sScanString,InputDatListBox.Items.Strings[iCount]) > 0) then
         begin
              iLengthRow := Length(InputDatListBox.Items.Strings[iCount]);
              iLengthScanString := Length(sScanString);

              sResult := Copy(InputDatListBox.Items.Strings[iCount],iLengthScanString+1,iLengthRow-iLengthScanString);
              TrimLeadSpaces(sResult);
         end;

     Result := sResult;
end;

function AreZoneTargetsInUse(ZoneTargetChild : TMDIChild) : boolean;
var
   iCount : integer;
   rTarget : extended;
   fInUse : boolean;
begin
     fInUse := False;

     for iCount := 1 to (ZoneTargetChild.aGrid.RowCount - 1) do
     begin
          rTarget := StrToFloat(ZoneTargetChild.aGrid.Cells[2,iCount]);

          if (rTarget > 0) then
             fInUse := True;
     end;

     Result := fInUse;
end;

function AreOverallTargetsInUse(SpecChild : TMDIChild; var iTargetField, iPropField : integer) : boolean;
var
   iCount : integer;
   rTarget : extended;
   fInUse : boolean;
begin
     iTargetField := 0;
     iPropField := 0;
     fInUse := False;

     for iCount := 1 to (SpecChild.aGrid.ColCount - 1) do
     begin
          if (SpecChild.aGrid.Cells[iCount,0] = 'prop') then
             iPropField := iCount;

          if (SpecChild.aGrid.Cells[iCount,0] = 'target') then
             iTargetField := iCount;
     end;

     for iCount := 1 to (SpecChild.aGrid.RowCount - 1) do
     begin
          if (iPropField > 0) then
          begin
               rTarget := StrToFloat(SpecChild.aGrid.Cells[iPropField,iCount]);
               if (rTarget > 0) then
                  fInUse := True;
          end;

          if (iTargetField > 0) then
          begin
               rTarget := StrToFloat(SpecChild.aGrid.Cells[iTargetField,iCount]);
               if (rTarget > 0) then
                  fInUse := True;
          end;
     end;

     Result := fInUse;
end;

procedure TMarZoneSystemTestForm.ExecuteMarZoneTest(sInputDat, sTestConfigurations : string);
var
   sInputDir, sPuName, sSpecName, sPuvsprName, sBoundName,
   sZonesName, sCostsName, sZoneTargetName, sZoneCostName, sZoneBoundCostName, sZoneContribName,
   sInputDirectory, sTestResultFileName, sOutputDir, sScenName, sPenaltyFileName : string;
   fBound, fZones, fCosts, fZoneTarget, fZoneCost, fZoneBoundCost, fZoneContrib,
   fZoneTargetsInUse, fOverallTargetsInUse, fPenalty : boolean;
   TestConfigurationChild, PuChild, SpecChild, PuvsprChild, BoundChild, ZonesChild, CostsChild,
   ZoneTargetChild, ZoneCostChild, ZoneBoundCostChild, ZoneContribChild, PenaltyChild : TMDIChild;
   iCount, iNumberOfConfigurations, iTargetField, iPropField : integer;
   TestResults : TextFile;
   rConnectivity, rCost, rPenalty, rShortfall : extended;
begin
     InputDatListBox.Items.LoadFromFile(sInputDat);
     // scan input.dat to find parameters of interest
     sInputDir := ScanInputDat('INPUTDIR');
     sPuName := ScanInputDat('PUNAME');
     sSpecName := ScanInputDat('SPECNAME');
     sPuvsprName := ScanInputDat('PUVSPRNAME');
     sOutputDir := ScanInputDat('OUTPUTDIR');
     sScenName := ScanInputDat('SCENNAME');

     sBoundName := ScanInputDat('BOUNDNAME');
     fBound := (sBoundName <> '');
     sZonesName := ScanInputDat('ZONESNAME');
     fZones := (sZonesName <> '');
     sCostsName := ScanInputDat('COSTSNAME');
     fCosts := (sCostsName <> '');
     sZoneTargetName := ScanInputDat('ZONETARGETNAME');
     fZoneTarget := (sZoneTargetName <> '');
     sZoneCostName := ScanInputDat('ZONECOSTNAME');
     fZoneCost := (sZoneCostName <> '');
     sZoneBoundCostName := ScanInputDat('ZONEBOUNDCOSTNAME');
     fZoneBoundCost := (sZoneBoundCostName <> '');
     sZoneContribName := ScanInputDat('ZONECONTRIBNAME');
     fZoneContrib := (sZoneContribName <> '');

     sInputDirectory := ExtractFilePath(sInputDat) + sInputDir + '\';

     // open each input file
     // pu.dat
     SCPForm.CreateMDIChild(sInputDirectory + sPuName,True,False);
     PuChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sPuName));
     // spec.dat
     SCPForm.CreateMDIChild(sInputDirectory + sSpecName,True,False);
     SpecChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sSpecName));
     // puvspr2.dat
     SCPForm.CreateMDIChild(sInputDirectory + sPuvsprName,True,False);
     PuvsprChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sPuvsprName));
     // bound.dat
     if fBound then
     begin
          SCPForm.CreateMDIChild(sInputDirectory + sBoundName,True,False);
          BoundChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sBoundName));
     end;
     // zones.dat
     if fZones then
     begin
          SCPForm.CreateMDIChild(sInputDirectory + sZonesName,True,False);
          ZonesChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sZonesName));
     end;
     // costs.dat
     if fCosts then
     begin
          SCPForm.CreateMDIChild(sInputDirectory + sCostsName,True,False);
          CostsChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sCostsName));
     end;
     // zonetarget.dat
     if fZoneTarget then
     begin
          SCPForm.CreateMDIChild(sInputDirectory + sZoneTargetName,True,False);
          ZoneTargetChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sZoneTargetName));
     end;
     // zonecost.dat
     if fZoneCost then
     begin
          SCPForm.CreateMDIChild(sInputDirectory + sZoneCostName,True,False);
          ZoneCostChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sZoneCostName));
     end;
     // zoneboundcost.dat
     if fZoneBoundCost then
     begin
          SCPForm.CreateMDIChild(sInputDirectory + sZoneBoundCostName,True,False);
          ZoneBoundCostChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sZoneBoundCostName));
     end;
     // zonecontrib.dat
     if fZoneContrib then
     begin
          SCPForm.CreateMDIChild(sInputDirectory + sZoneContribName,True,False);
          ZoneContribChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sZoneContribName));
     end;
     if fZoneTarget then
        fZoneTargetsInUse := AreZoneTargetsInUse(ZoneTargetChild)
     else
         fZoneTargetsInUse := False;

     // load output penalty file if it exists
     sPenaltyFileName := ExtractFilePath(sInputDat) + sOutputDir + '\' + sScenName + '_penalty.csv';
     fPenalty := fileexists(sPenaltyFileName);
     if fPenalty then
     begin
          SCPForm.CreateMDIChild(sPenaltyFileName,True,False);
          PenaltyChild := TMDIChild(SCPForm.rtnChild(sPenaltyFileName));
     end;

     fOverallTargetsInUse := AreOverallTargetsInUse(SpecChild,iTargetField,iPropField);

     // perform tests on zoning configurations
     TestConfigurationChild := TMDIChild(SCPForm.rtnChild(sTestConfigurations));
     iNumberOfConfigurations := TestConfigurationChild.aGrid.ColCount - 1;

     sTestResultFileName := Copy(sTestConfigurations,1,Length(sTestConfigurations) - Length(ExtractFileExt(sTestConfigurations))) + '_test_results.csv';
     assignfile(TestResults,sTestResultFileName);
     rewrite(TestResults);
     writeln(TestResults,'test,score,cost,connectivity,penalty,shortfall');

     for iCount := 1 to iNumberOfConfigurations do
     begin
          // compute cost
          if fZones and fCosts and fZoneCost then
             rCost := ComputeMarZoneCost(iCount, TestConfigurationChild, PuChild, CostsChild, ZoneCostChild)
          else
              rCost := 0;

          // compute Connectivity
          if fZones and fBound and fZoneBoundCost then
             rConnectivity := ComputeMarZoneConnectivity(iCount, TestConfigurationChild, PuChild, BoundChild, ZoneBoundCostChild)
          else
              rConnectivity := 0;

          // compute penalty
          if fZones and fZoneTarget and fZoneContrib then
             rPenalty := ComputeMarZonePenalty(iCount,iTargetField,iPropField,
                                     TestConfigurationChild, PuChild, SpecChild, PuvsprChild, ZonesChild, ZoneTargetChild, ZoneContribChild, PenaltyChild,
                                     fZones, fZoneTarget, fZoneContrib, fPenalty, fZoneTargetsInUse, fOverallTargetsInUse,
                                     rShortfall)
          else
              rPenalty := 0;;

          writeln(TestResults,TestConfigurationChild.aGrid.Cells[iCount,0] + ',' +
                              FloatToStr(rCost + rConnectivity + rPenalty) + ',' +
                              FloatToStr(rCost) + ',' + FloatToStr(rConnectivity) + ',' + FloatToStr(rPenalty) + ',' +
                              FloatToStr(rShortfall));
     end;

     closefile(TestResults);

     TestConfigurationChild.Close;
     PuChild.Close;
     SpecChild.Close;
     PuvsprChild.Close;
     if fBound then
        BoundChild.Close;
     if fZones then
        ZonesChild.Close;
     if fCosts then
        CostsChild.Close;
     if fZoneTarget then
        ZoneTargetChild.Close;
     if fZoneCost then
        ZoneCostChild.Close;
     if fZoneBoundCost then
        ZoneBoundCostChild.Close;
     if fZoneContrib then
        ZoneContribChild.Close;
     if fPenalty then
        PenaltyChild.Close;

     SCPForm.CreateMDIChild(sTestResultFileName,True,False);
end;

procedure TMarZoneSystemTestForm.ExecuteMarxanTest(sInputDat, sTestConfigurations : string);
var
   sInputDir, sPuName, sSpecName, sPuvsprName, sBoundName,
   sInputDirectory, sTestResultFileName, sOutputDir, sScenName, sPenaltyFileName : string;
   fBound, fOverallTargetsInUse, fPenalty : boolean;
   TestConfigurationChild, PuChild, SpecChild, PuvsprChild, BoundChild, PenaltyChild : TMDIChild;
   iCount, iNumberOfConfigurations, iTargetField, iPropField : integer;
   TestResults : TextFile;
   rConnectivity, rCost, rPenalty, rShortfall, rBLM : extended;
begin
     InputDatListBox.Items.LoadFromFile(sInputDat);
     // scan input.dat to find parameters of interest
     sInputDir := ScanInputDat('INPUTDIR');
     sPuName := ScanInputDat('PUNAME');
     sSpecName := ScanInputDat('SPECNAME');
     sPuvsprName := ScanInputDat('PUVSPRNAME');
     sOutputDir := ScanInputDat('OUTPUTDIR');
     sScenName := ScanInputDat('SCENNAME');
     rBLM := StrToFloat(ScanInputDat('BLM'));

     sBoundName := ScanInputDat('BOUNDNAME');
     fBound := (sBoundName <> '');

     sInputDirectory := ExtractFilePath(sInputDat) + sInputDir + '\';

     // open each input file
     // pu.dat
     SCPForm.CreateMDIChild(sInputDirectory + sPuName,True,False);
     PuChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sPuName));
     // spec.dat
     SCPForm.CreateMDIChild(sInputDirectory + sSpecName,True,False);
     SpecChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sSpecName));
     // puvspr2.dat
     SCPForm.CreateMDIChild(sInputDirectory + sPuvsprName,True,False);
     PuvsprChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sPuvsprName));
     // bound.dat
     if fBound then
     begin
          SCPForm.CreateMDIChild(sInputDirectory + sBoundName,True,False);
          BoundChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sBoundName));
     end;

     // load output penalty file if it exists
     sPenaltyFileName := ExtractFilePath(sInputDat) + sOutputDir + '\' + sScenName + '_penalty.csv';
     fPenalty := fileexists(sPenaltyFileName);
     if fPenalty then
     begin
          SCPForm.CreateMDIChild(sPenaltyFileName,True,False);
          PenaltyChild := TMDIChild(SCPForm.rtnChild(sPenaltyFileName));
     end;

     fOverallTargetsInUse := AreOverallTargetsInUse(SpecChild,iTargetField,iPropField);

     // perform tests on reserve configurations
     TestConfigurationChild := TMDIChild(SCPForm.rtnChild(sTestConfigurations));
     iNumberOfConfigurations := TestConfigurationChild.aGrid.ColCount - 1;

     sTestResultFileName := Copy(sTestConfigurations,1,Length(sTestConfigurations) - Length(ExtractFileExt(sTestConfigurations))) + '_test_results.csv';
     assignfile(TestResults,sTestResultFileName);
     rewrite(TestResults);
     writeln(TestResults,'test,score,cost,connectivity,penalty,shortfall');

     for iCount := 1 to iNumberOfConfigurations do
     begin
          // compute cost
          rCost := ComputeMarxanCost(iCount, TestConfigurationChild, PuChild);

          // compute Connectivity
          if fBound then
             rConnectivity := ComputeMarxanConnectivity(iCount, rBLM, TestConfigurationChild, PuChild, BoundChild)
          else
              rConnectivity := 0;

          // compute penalty
          rPenalty := ComputeMarxanPenalty(iCount,iTargetField,iPropField,
                                           TestConfigurationChild, PuChild, SpecChild, PuvsprChild, PenaltyChild,
                                           fPenalty, fOverallTargetsInUse, rShortfall);

          writeln(TestResults,TestConfigurationChild.aGrid.Cells[iCount,0] + ',' +
                              FloatToStr(rCost + rConnectivity + rPenalty) + ',' +
                              FloatToStr(rCost) + ',' + FloatToStr(rConnectivity) + ',' + FloatToStr(rPenalty) + ',' +
                              FloatToStr(rShortfall));
     end;

     closefile(TestResults);

     TestConfigurationChild.Close;
     PuChild.Close;
     SpecChild.Close;
     PuvsprChild.Close;
     if fBound then
        BoundChild.Close;
     if fPenalty then
        PenaltyChild.Close;

     SCPForm.CreateMDIChild(sTestResultFileName,True,False);
end;

procedure TMarZoneSystemTestForm.ExecuteMarProbThreatTest(sInputDat, sTestConfigurations : string);
var
   sInputDir, sPuName, sSpecName, sPuvsprName, sBoundName,
   sInputDirectory, sTestResultFileName, sOutputDir, sScenName, sPenaltyFileName : string;
   fBound, fOverallTargetsInUse, fPenalty : boolean;
   TestConfigurationChild, PuChild, SpecChild, PuvsprChild, BoundChild, PenaltyChild : TMDIChild;
   iCount, iNumberOfConfigurations, iTargetField, iPropField : integer;
   TestResults : TextFile;
   rConnectivity, rCost, rPenalty, rProbability, rShortfall, rBLM, rProbabilityWeighting : extended;
begin
     InputDatListBox.Items.LoadFromFile(sInputDat);
     // scan input.dat to find parameters of interest
     sInputDir := ScanInputDat('INPUTDIR');
     sPuName := ScanInputDat('PUNAME');
     sSpecName := ScanInputDat('SPECNAME');
     sPuvsprName := ScanInputDat('PUVSPRNAME');
     sOutputDir := ScanInputDat('OUTPUTDIR');
     sScenName := ScanInputDat('SCENNAME');
     rBLM := StrToFloat(ScanInputDat('BLM'));
     rProbabilityWeighting := StrToFloat(ScanInputDat('PROBABILITYWEIGHTING'));

     sBoundName := ScanInputDat('BOUNDNAME');
     fBound := (sBoundName <> '');

     sInputDirectory := ExtractFilePath(sInputDat) + sInputDir + '\';

     // open each input file
     // pu.dat
     SCPForm.CreateMDIChild(sInputDirectory + sPuName,True,False);
     PuChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sPuName));
     // spec.dat
     SCPForm.CreateMDIChild(sInputDirectory + sSpecName,True,False);
     SpecChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sSpecName));
     // puvspr2.dat
     SCPForm.CreateMDIChild(sInputDirectory + sPuvsprName,True,False);
     PuvsprChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sPuvsprName));
     // bound.dat
     if fBound then
     begin
          SCPForm.CreateMDIChild(sInputDirectory + sBoundName,True,False);
          BoundChild := TMDIChild(SCPForm.rtnChild(sInputDirectory + sBoundName));
     end;

     // load output penalty file if it exists
     sPenaltyFileName := ExtractFilePath(sInputDat) + sOutputDir + '\' + sScenName + '_penalty.csv';
     fPenalty := fileexists(sPenaltyFileName);
     if fPenalty then
     begin
          SCPForm.CreateMDIChild(sPenaltyFileName,True,False);
          PenaltyChild := TMDIChild(SCPForm.rtnChild(sPenaltyFileName));
     end;

     fOverallTargetsInUse := AreOverallTargetsInUse(SpecChild,iTargetField,iPropField);

     // perform tests on reserve configurations
     TestConfigurationChild := TMDIChild(SCPForm.rtnChild(sTestConfigurations));
     iNumberOfConfigurations := TestConfigurationChild.aGrid.ColCount - 1;

     sTestResultFileName := Copy(sTestConfigurations,1,Length(sTestConfigurations) - Length(ExtractFileExt(sTestConfigurations))) + '_test_results.csv';
     assignfile(TestResults,sTestResultFileName);
     rewrite(TestResults);
     writeln(TestResults,'test,score,cost,connectivity,penalty,shortfall');

     for iCount := 1 to iNumberOfConfigurations do
     begin
          // compute cost
          rCost := ComputeMarxanCost(iCount, TestConfigurationChild, PuChild);

          // compute Connectivity
          if fBound then
             rConnectivity := ComputeMarxanConnectivity(iCount, rBLM, TestConfigurationChild, PuChild, BoundChild)
          else
              rConnectivity := 0;

          // compute penalty and probability
          rPenalty := ComputeMarProbPenaltyAndProbability(iCount,iTargetField,iPropField,
                                           TestConfigurationChild, PuChild, SpecChild, PuvsprChild, PenaltyChild,
                                           fPenalty, fOverallTargetsInUse,
                                           rProbabilityWeighting,
                                           rShortfall,rProbability);

          writeln(TestResults,TestConfigurationChild.aGrid.Cells[iCount,0] + ',' +
                              FloatToStr(rCost + rConnectivity + rPenalty) + ',' +
                              FloatToStr(rCost) + ',' + FloatToStr(rConnectivity) + ',' + FloatToStr(rPenalty) + ',' +
                              FloatToStr(rShortfall));
     end;

     closefile(TestResults);

     TestConfigurationChild.Close;
     PuChild.Close;
     SpecChild.Close;
     PuvsprChild.Close;
     if fBound then
        BoundChild.Close;
     if fPenalty then
        PenaltyChild.Close;

     SCPForm.CreateMDIChild(sTestResultFileName,True,False);
end;

procedure TMarZoneSystemTestForm.BitBtn1Click(Sender: TObject);
var
   sTestConfigurations : string;
   AChild : TMDIChild;
begin
     if CheckTranspose.Checked then
     begin
          AChild := SCPForm.rtnChild(ComboTestConfigurations.Text);
          sTestConfigurations := SCPForm.TransposeTable(AChild);
     end
     else
         sTestConfigurations := ComboTestConfigurations.Text;

     case RadioSoftwareTestType.ItemIndex of
          0 : ExecuteMarZoneTest(EditInputDat.Text,sTestConfigurations);
          1 : ExecuteMarxanTest(EditInputDat.Text,sTestConfigurations);
          2 : ExecuteMarProbThreatTest(EditInputDat.Text,sTestConfigurations);
     end;
end;

procedure TMarZoneSystemTestForm.FormCreate(Sender: TObject);
var
   iCount : integer;
begin
     ComboTestConfigurations.Items.Clear;

     if (SCPForm.MDIChildCount > 0) then
        for iCount := 0 to (SCPForm.MDIChildCount-1) do
            ComboTestConfigurations.Items.Add(SCPForm.MDIChildren[iCount].Caption);

     ComboTestConfigurations.Text := ComboTestConfigurations.Items.Strings[0];
end;

procedure TMarZoneSystemTestForm.btnBrowseClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
        EditInputDat.Text := OpenDialog1.Filename;
end;

end.
