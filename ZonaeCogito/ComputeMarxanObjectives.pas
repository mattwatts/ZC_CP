unit ComputeMarxanObjectives;

interface

uses CSV_Child, DBF_Child, ds;

procedure ExecuteMarZoneTest(sTestConfigurations : string; const rBLM : extended; const iValidation : integer);
procedure ExecuteMarxanTest(sTestConfigurations : string; const rBLM : extended; const iValidation : integer);
procedure ExecuteMarProb1DTest(sTestConfigurations : string; const rBLM : extended; const iValidation : integer);
procedure ExecuteMarProb2DTest(sTestConfigurations : string; const rBLM : extended; const iValidation : integer);
procedure ExecuteMarConTest(sTestConfigurations : string; const rBLM : extended; const iValidation : integer);
function ScanInputDat(const sScanString : string) : string;
function ComputeMarZoneCost(const iConfiguration : integer; TestConfigurationChild,
                            PuChild, CostsChild, ZoneCostChild : TCSVChild) : extended;
function ComputeMarZoneConnectivity(const iConfiguration : integer; TestConfigurationChild,
                                    PuChild, BoundChild, ZoneBoundCostChild : TCSVChild) : extended;
function ComputeMarZonePenalty(const iConfiguration,iTargetField,iPropField : integer;
                               TestConfigurationChild, PuChild, SpecChild, ZonesChild, ZoneTargetChild, ZoneContribChild, PenaltyChild : TCSVChild;
                               const fZones, fZoneTarget, fZoneContrib, fZoneContrib2, fPenalty, fZoneTargetsInUse, fOverallTargetsInUse : boolean;
                               var rShortfall : extended; const iValidation : integer) : extended;
function ComputeMarxanCost(const iConfiguration : integer; TestConfigurationChild,
                           PuChild : TCSVChild) : extended;
function ComputeMarxanAsymmetricConnectivity(const iConfiguration : integer;
                                             const rBLM : extended;
                                             TestConfigurationChild, PuChild, BoundChild : TCSVChild) : extended;
function ComputeMarxanConnectivity(const iConfiguration : integer;
                                   const rBLM : extended;
                                   TestConfigurationChild, PuChild, BoundChild : TCSVChild;
                                   const fConnectivityInMetric : boolean) : extended;
function ComputeMarxanPenalty(const iConfiguration,iTargetField,iPropField : integer;
                              TestConfigurationChild, PuChild, SpecChild, PenaltyChild : TCSVChild;
                              const fPenalty, fOverallTargetsInUse : boolean;
                              var rShortfall : extended; const iValidation : integer) : extended;
function ComputeMarProb1D_PenaltyAndProbability(const iConfiguration,iTargetField,iPropField : integer;
                                                TestConfigurationChild, PuChild, SpecChild, PenaltyChild : TCSVChild;
                                                const fPenalty, fOverallTargetsInUse : boolean;
                                                const rProbabilityWeighting : extended;
                                                var rShortfall, rSummedProbability : extended; const iValidation : integer) : extended;
function ComputeMarProb2D_PenaltyAndProbability(const iConfiguration : integer;
                                                TestConfigurationChild, PuChild, SpecChild, PenaltyChild : TCSVChild;
                                                const fPenalty, fOverallTargetsInUse : boolean;
                                                const rProbabilityWeighting : extended;
                                                var rShortfall, rSummedProbability : extended; const iValidation : integer) : extended;

function FindChildIdLookupMatch(AChild : TCSVChild; iMatch : integer; fAscendingOrder : boolean) : integer;
function Find_ZBC_Element(ZoneBoundCostChild : TCSVChild; iPUID1Zone, iPUID2Zone : integer) : extended;

type
    typePuvsprRecord = record
                             iPUID, iSPID : integer;
                             rAmount : extended;
                       end;
    typePuvsprProb2dRecord = record
                                   iPUID, iSPID : integer;
                                   rAmount, rProb : extended;
                             end;

var
   fCMOSortOrder, fCMOProduceDetail, fCMOTargetAchievement, fCMOCheckSummary, fCMOProducePUDetail : boolean;
   sCMOInputDat : string;
   PuvsprArray, PuvsprProb2dArray : Array_t;

implementation

uses SCP_Main, Math, Miscellaneous, Marxan_interface, Sysutils, Dialogs, Forms, BarGraph;

procedure InitPuvsprArray(const sInputFile : string);
var
   InputFile : TextFile;
   iPuvsprArrayCount, iCount : integer;
   sLine : string;
   ARecord : typePuvsprRecord;
begin
     try
        // test if file is comma delimited
        if not FileContainsCommas(sInputFile) then
           ConvertFileDelimiter_TabToComma(sInputFile);

        // parse input file, count the number of records in the file
        assignfile(InputFile,sInputFile);
        reset(InputFile);
        readln(InputFile,sLine);
        iPuvsprArrayCount := 0;
        repeat
              readln(InputFile,sLine);
              Inc(iPuvsprArrayCount);
        until eof(InputFile);
        closefile(InputFile);

        // create the datastructure
        PuvsprArray := Array_t.Create;
        PuvsprArray.init(SizeOf(ARecord),iPuvsprArrayCount);

        // parse input file, read elements into datastructure
        assignfile(InputFile,sInputFile);
        reset(InputFile);
        readln(InputFile,sLine);
        iCount := 0;
        repeat
              readln(InputFile,sLine);
              Inc(iCount);

              // store this record in the array
              ARecord.iSPID := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
              ARecord.iPUID := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
              ARecord.rAmount := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));

              PuvsprArray.setValue(iCount,@ARecord);

        until eof(InputFile);
        closefile(InputFile);

     except
           MessageDlg('Exception in InitPuvsprArray',mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure InitPuvsprProb2dArray(const sInputFile : string);
var
   InputFile : TextFile;
   iPuvsprArrayCount, iCount : integer;
   sLine : string;
   ARecord : typePuvsprProb2dRecord;
begin
     try
        // test if file is comma delimited
        if not FileContainsCommas(sInputFile) then
           ConvertFileDelimiter_TabToComma(sInputFile);

        // parse input file, count the number of records in the file
        assignfile(InputFile,sInputFile);
        reset(InputFile);
        readln(InputFile,sLine);
        iPuvsprArrayCount := 0;
        repeat
              readln(InputFile,sLine);
              Inc(iPuvsprArrayCount);
        until eof(InputFile);
        closefile(InputFile);

        // create the datastructure
        PuvsprProb2dArray := Array_t.Create;
        PuvsprProb2dArray.init(SizeOf(ARecord),iPuvsprArrayCount);

        // parse input file, read elements into datastructure
        assignfile(InputFile,sInputFile);
        reset(InputFile);
        readln(InputFile,sLine);
        iCount := 0;
        repeat
              readln(InputFile,sLine);
              Inc(iCount);

              // store this record in the array
              ARecord.iSPID := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
              ARecord.iPUID := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
              ARecord.rAmount := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));
              ARecord.rProb := StrToFloat(GetDelimitedAsciiElement(sLine,',',4));

              PuvsprProb2dArray.setValue(iCount,@ARecord);

        until eof(InputFile);
        closefile(InputFile);

     except
           MessageDlg('Exception in InitPuvsprProb2dArray',mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

function ComputeMarZoneCost(const iConfiguration : integer; TestConfigurationChild,
                            PuChild, CostsChild, ZoneCostChild : TCSVChild) : extended;
var
   iCount, iZCCount, iZone, iMatchZone, iCost : integer;
   rCost, rCostMultiplier, rCostValue, rPUCost : extended;
   CostFile, CostFile2 : TextFile;
   sCostFile, sCostFile2 : string;
   fProduceDetailedOutput : boolean;
begin
     try
        // compute the cost of this zonation system
        rCost := 0;

        fProduceDetailedOutput := False;
        if fCMOProduceDetail then
           if (iConfiguration = 1) then
              fProduceDetailedOutput := True;

        if fProduceDetailedOutput then
        begin
             sCostFile := Copy(TestConfigurationChild.Caption,1,
                               Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                               '_cost_' + IntToStr(iConfiguration) + '.csv';
             assignfile(CostFile,sCostFile);
             rewrite(CostFile);
             writeln(CostFile,'puid,total cost');

             sCostFile2 := Copy(TestConfigurationChild.Caption,1,
                               Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                               '_costdetail_' + IntToStr(iConfiguration) + '.csv';
             assignfile(CostFile2,sCostFile2);
             rewrite(CostFile2);
             writeln(CostFile2,'puid,iZone,iCost,value,mult,cost');
        end;

        for iCount := 1 to (TestConfigurationChild.aGrid.RowCount - 1) do
        begin
             iZone := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iCount]);

             rPUCost := 0;

             for iZCCount := 1 to (ZoneCostChild.aGrid.RowCount - 1) do
             begin
                  iMatchZone := StrToInt(ZoneCostChild.aGrid.Cells[0,iZCCount]);

                  if (iMatchZone = iZone) then
                  begin
                       iCost := StrToInt(ZoneCostChild.aGrid.Cells[1,iZCCount]);
                       rCostMultiplier := StrToFloat(ZoneCostChild.aGrid.Cells[2,iZCCount]);

                       rCostValue := StrToFloat(PuChild.aGrid.Cells[iCost,iCount]);

                       rPUCost := rPUCost + (rCostMultiplier * rCostValue);

                       if fProduceDetailedOutput then
                          writeln(CostFile2,TestConfigurationChild.aGrid.Cells[0,iCount] + ',' +
                                            IntToStr(iZone) + ',' +
                                            IntToStr(iCost) + ',' +
                                            FloatToStr(rCostValue) + ',' +
                                            FloatToStr(rCostMultiplier) + ',' +
                                            FloatToStr(rCostMultiplier * rCostValue));
                  end;
             end;

             if fProduceDetailedOutput then
                writeln(CostFile,TestConfigurationChild.aGrid.Cells[0,iCount] + ',' +
                                 FloatToStr(rPUCost));

             rCost := rCost + rPUCost;
        end;

        if fProduceDetailedOutput then
        begin
             closefile(CostFile);
             closefile(CostFile2);
        end;

        Result := rCost;

     except
           MessageDlg('Exception in ComputeMarZoneCost',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

function ComputeMarxanCost(const iConfiguration : integer; TestConfigurationChild,
                           PuChild : TCSVChild) : extended;
var
   iCount, iStatus, iCostField, iIdIndex : integer;
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

             if (iStatus = 1) or (iStatus = 2) then
             begin
                  iIdIndex := FindChildIdLookupMatch(PuChild,StrToInt(TestConfigurationChild.aGrid.Cells[0,iCount]),True);

                  rCostValue := StrToFloat(PuChild.aGrid.Cells[iCostField,iIdIndex]);

                  rCost := rCost + rCostValue;
             end;
        end;

     Result := rCost;
end;

function FindChildIdLookupMatch(AChild : TCSVChild; iMatch : integer; fAscendingOrder : boolean) : integer;
var
   iCentre, iCount, iCentreValue, iTop, iBottom : integer;
   fLoop : boolean;
begin
     try
        // use a binary search to find the index of planning unit iMatch in PuChild
        // assumes id field of PuChild is in numeric order
        Result := -1;

        iTop := 1;
        iBottom := AChild.aGrid.RowCount - 1;

        iCentre := iTop + floor((iBottom - iTop) / 2);

        iCentreValue := StrToInt(AChild.aGrid.Cells[0,iCentre]);

        fLoop := True;

        if fAscendingOrder then
        begin // ascending order
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
        end
        else
        begin // descending order
             while ((iTop >= iBottom) and (iCentreValue <> iMatch) and fLoop) do
             begin
                  if (iMatch > iCentreValue) then
                  begin
                       iBottom := iCentre - 1;
                       if (iBottom > iTop) then
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
                       if (iTop < iBottom) then
                       begin
                            iTop := iBottom;
                            fLoop := False;
                       end;
                       iCount := iBottom - iTop + 1;
                       iCentre := iTop + floor(iCount / 2);
                  end;

                  iCentreValue := StrToInt(AChild.aGrid.Cells[0,iCentre]);
             end;
        end;

        if (iCentreValue = iMatch) then
           Result := iCentre;

     except
           MessageDlg('Exception in FindChildIdLookupMatch match ' + IntToStr(iMatch) + ' child ' + AChild.Caption,mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;


function Find_ZBC_Element(ZoneBoundCostChild : TCSVChild; iPUID1Zone, iPUID2Zone : integer) : extended;
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

function ComputeMarZoneConnectivity(const iConfiguration : integer; TestConfigurationChild,
                                    PuChild, BoundChild, ZoneBoundCostChild : TCSVChild) : extended;
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
               iId1Index := FindChildIdLookupMatch(TestConfigurationChild,iPUID1,fCMOSortOrder);
               iId2Index := FindChildIdLookupMatch(TestConfigurationChild,iPUID2,fCMOSortOrder);

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

function ComputeMarxanAsymmetricConnectivity(const iConfiguration : integer;
                                             const rBLM : extended;
                                             TestConfigurationChild, PuChild, BoundChild : TCSVChild) : extended;
var
   rConnectivity, rBoundary : extended;
   iCount, iId1Index, iId2Index, iPUID1, iPUID2, iPUID1Status, iPUID2Status : integer;
begin
     // With asymmetric connectivity, the cost applies if;
     //   - puid1 and puid2 are both in the reserve
     //   - puid1 is not in the reserve and puid2 is in the reserve
     // the cost does not apply if;
     //   - puid1 and puid2 are both not in the reserve
     //   - puid1 is in the reserve and puid2 is not in the reserve
     //
     // We consider puid1 to be the source of the connection, and puid2 to be the destination of the connection.
     // Our objective is to capture propagules dispersed from sources in the reserve network.

     try
        // compute the connectivity of this reserve system
        rConnectivity := 0;

        for iCount := 1 to (BoundChild.aGrid.RowCount - 1) do
        begin
             iPUID1 := StrToInt(BoundChild.aGrid.Cells[0,iCount]);
             iPUID2 := StrToInt(BoundChild.aGrid.Cells[1,iCount]);
             rBoundary := StrToFloat(BoundChild.aGrid.Cells[2,iCount]);

             // lookup indices for planning units in the connection
             iId1Index := FindChildIdLookupMatch(TestConfigurationChild,iPUID1,fCMOSortOrder);
             iId2Index := FindChildIdLookupMatch(TestConfigurationChild,iPUID2,fCMOSortOrder);

             // find status for these planning units in the configuration
             if (iId1Index > -1) and (iId1Index < TestConfigurationChild.aGrid.RowCount) then
                iPUID1Status := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iId1Index])
             else
                 iId1Index := 0;
             if (iId2Index > -1) and (iId2Index < TestConfigurationChild.aGrid.RowCount) then
                iPUID2Status := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iId2Index])
             else
                 iId2Index := 0;

             if (iPUID1Status = 1)
             and (iPUID2Status = 0) then
                rConnectivity := rConnectivity + rBoundary;
        end;

        Result := rConnectivity * rBLM;

     except
           MessageDlg('Exception in ComputeMarxanAsymmetricConnectivity iCount ' + IntToStr(iCount),mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

function ComputeMarxanConnectivity(const iConfiguration : integer;
                                   const rBLM : extended;
                                   TestConfigurationChild, PuChild, BoundChild : TCSVChild;
                                   const fConnectivityInMetric : boolean) : extended;
var
   rConnectivity, rBoundary : extended;
   iCount, iId1Index, iId2Index, iPUID1, iPUID2, iPUID1Status, iPUID2Status : integer;
begin
     try
        // compute the connectivity of this reserve system
        rConnectivity := 0;

        for iCount := 1 to (BoundChild.aGrid.RowCount - 1) do
        begin
             iPUID1 := StrToInt(BoundChild.aGrid.Cells[0,iCount]);
             iPUID2 := StrToInt(BoundChild.aGrid.Cells[1,iCount]);
             rBoundary := StrToFloat(BoundChild.aGrid.Cells[2,iCount]);

             if (iPUID1 = iPUID2) then
             begin
                  iId1Index := FindChildIdLookupMatch(TestConfigurationChild,iPUID1,fCMOSortOrder);
                  if (iId1Index > -1) and (iId1Index < TestConfigurationChild.aGrid.RowCount) then
                     iPUID1Status := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iId1Index])
                  else
                      iPUID1Status := 0;

                  if (iPUID1Status = 1) then
                     rConnectivity := rConnectivity + rBoundary;
             end
             else
             begin
                  // lookup indices for planning units in the connection
                  iId1Index := FindChildIdLookupMatch(TestConfigurationChild,iPUID1,fCMOSortOrder);
                  iId2Index := FindChildIdLookupMatch(TestConfigurationChild,iPUID2,fCMOSortOrder);

                  // find status for these planning units in the configuration
                  if (iId1Index > -1) and (iId1Index < TestConfigurationChild.aGrid.RowCount) then
                     iPUID1Status := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iId1Index])
                  else
                      iId1Index := 0;
                  if (iId2Index > -1) and (iId2Index < TestConfigurationChild.aGrid.RowCount) then
                     iPUID2Status := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iId2Index])
                  else
                      iId2Index := 0;

                  if fConnectivityInMetric then
                  begin
                       if (iPUID1Status > 0) and (iPUID2Status > 0) then
                          // connection is within reserve, with both pu's in
                          rConnectivity := rConnectivity + rBoundary;
                  end
                  else
                  begin
                       if (iPUID1Status <> iPUID2Status) then
                          // connection is on edge of reserve, with one pu in and one pu out
                          rConnectivity := rConnectivity + rBoundary;
                  end;
             end;
        end;

        Result := rConnectivity * rBLM;

     except
           MessageDlg('Exception in ComputeMarxanConnectivity iCount ' + IntToStr(iCount),mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

function ComputeMarZonePenalty(const iConfiguration,iTargetField,iPropField : integer;
                               TestConfigurationChild, PuChild, SpecChild, ZonesChild, ZoneTargetChild, ZoneContribChild, PenaltyChild : TCSVChild;
                               const fZones, fZoneTarget, fZoneContrib, fZoneContrib2, fPenalty, fZoneTargetsInUse, fOverallTargetsInUse : boolean;
                               var rShortfall : extended; const iValidation : integer) : extended;
var
   rPenalty, rMarxanPenalty, rSPF, rFeaturePenalty, rTA, rTA_zones, rtarg,
   rtarg_zones, rZC, rAmount, rShortfallFraction, rFeatureShortfallFraction,
   rTargetField, rFeatureShortfall, rContribAmount, rTargetPercentage,
   rPercentTargetInMPA, rMissedTargetAmount, rInitialReserved,
   rMissedTargetPercentage : extended;
   iCount, iCount2, iSpeciesCount, iZoneCount, iArraySize, iSPID, iPUID, iPUID_index, iPU_index,
   iZoneId, iSP_index, iArrayIndex, iTargetType, iShortfall, iSPF_Field : integer;
   TA, TA_zones, targ, targ_zones, ZC, Pen, CA : Array_t;
   sSummaryFileName, sTargetAchievementFileName, sConfigurationName : string;
   SummaryFile, ShortFallFile, ZoneContribFile, TargetAchievementFile : TextFile;
   ARecord : typePuvsprRecord;
   fProduceDetailedOutput : boolean;
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

     sConfigurationName := TestConfigurationChild.AGrid.Cells[iConfiguration,0];

     fProduceDetailedOutput := False;
     if fCMOProduceDetail then
        if (iConfiguration = 1) then
           fProduceDetailedOutput := True;

     // init configuration output file
     if fProduceDetailedOutput then
     begin
          sSummaryFileName := Copy(TestConfigurationChild.Caption,1,
                                   Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                                   '_summary_' + sConfigurationName + '.csv';
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
     end;

     // init target achievement output file
     if fCMOTargetAchievement then
     begin
          sTargetAchievementFileName := Copy(TestConfigurationChild.Caption,1,
                                        Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                                        '_targetachievement_' + sConfigurationName + '.csv';
          sReportConfigurationsFileName := sTargetAchievementFileName;
          assignfile(TargetAchievementFile,sTargetAchievementFileName);
          rewrite(TargetAchievementFile);
          writeln(TargetAchievementFile,'Feature Name,Feature Key,Initial Reserved,Total in region'
                                        + ',Target %,Target Amount,% Target in MPA,Amount in MPA'
                                        + ',Missed Target %,Missed Target Amount');
     end;

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
     if fZoneContrib then
     begin
          for iCount := 1 to (ZoneContribChild.aGrid.RowCount - 1) do
          begin
               iZoneId := StrToInt(ZoneContribChild.aGrid.Cells[0,iCount]);
               iSPID := StrToInt(ZoneContribChild.aGrid.Cells[1,iCount]);
               rZC := StrToFloat(ZoneContribChild.aGrid.Cells[2,iCount]);

               iSP_index := FindChildIdLookupMatch(SpecChild,iSPID,True);

               iArrayIndex := (iSpeciesCount * (iZoneId - 1)) + iSP_index;

               ZC.setValue(iArrayIndex,@rZC);
          end;
     end
     else
         if fZoneContrib2 then
            for iCount := 1 to (ZoneContribChild.aGrid.RowCount - 1) do
            begin
                 iZoneId := StrToInt(ZoneContribChild.aGrid.Cells[0,iCount]);
                 rZC := StrToFloat(ZoneContribChild.aGrid.Cells[1,iCount]);

                 for iCount2 := 1 to iSpeciesCount do
                 begin
                      iArrayIndex := (iSpeciesCount * (iZoneId - 1)) + iCount2;

                      ZC.setValue(iArrayIndex,@rZC);
                 end;
            end;
            
     if fProduceDetailedOutput then
     begin
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
     end;

     // parse penalty
     if fPenalty then
        for iCount := 1 to (PenaltyChild.aGrid.RowCount - 1) do
        begin
             iSPID := StrToInt(PenaltyChild.aGrid.Cells[0,iCount]);
             rMarxanPenalty := StrToFloat(PenaltyChild.aGrid.Cells[1,iCount]);

             iSP_index := FindChildIdLookupMatch(SpecChild,iSPID,True);

             Pen.setValue(iSP_index,@rMarxanPenalty);
        end;

     // compute total areas
     for iCount := 1 to PuvsprArray.lMaxSize do
     begin
          PuvsprArray.rtnValue(iCount,@ARecord);

          iSPID := ARecord.iSPID;
          iPUID := ARecord.iPUID;
          rAmount := ARecord.rAmount;

          if (iPUID_index <> iPUID) then
          begin
               // lookup index and zone of this planning unit
               iPU_index := FindChildIdLookupMatch(TestConfigurationChild,iPUID,fCMOSortOrder);
               iPUID_index := iPUID;
               iZoneId := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iPU_index]);
          end;

          // find species index
          iSP_index := FindChildIdLookupMatch(SpecChild,iSPID,True);

          if (iSP_index < 1) or (iSP_index > TA.lMaxSize) then
             MessageDlg('iSP_index out of bounds ' + IntToStr(iSP_index),mtInformation,[mbOk],0);

          TA.rtnValue(iSP_index,@rTA);
          rTA := rTA + rAmount;
          TA.setValue(iSP_index,@rTA);

          iArrayIndex := (iSpeciesCount * (iZoneId - 1)) + iSP_index;

          if (iArrayIndex < 1) or (iArrayIndex > TA_zones.lMaxSize) then
             MessageDlg('iArrayIndex out of bounds ' + IntToStr(iArrayIndex),mtInformation,[mbOk],0);

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

             iSP_index := FindChildIdLookupMatch(SpecChild,iSPID,True);
             iArrayIndex := (iSpeciesCount * (iZoneId - 1)) + iSP_index;

             if (iTargetType = 0) then  // 0 areal
             begin
                  targ_zones.setValue(iArrayIndex,@rTargetField);
             end;

             if (iTargetType = 1) then  // 1 proportion
             begin
                  TA.rtnValue(iSP_index,@rTA);

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
          rFeatureShortfall := 0;

          for iCount2 := 1 to iZoneCount do
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
               end;
          end;

          if fProduceDetailedOutput then
             writeln(ShortFallFile,SpecChild.aGrid.Cells[0,iCount] + ',' +
                                   '0,' +
                                   FloatToStr(rContribAmount) + ',' +
                                   FloatToStr(rtarg) + ',' +
                                   FloatToStr(rFeatureShortfall));
                                   //'SPID,zone,area,target,shortfall');

          CA.setValue(iCount,@rContribAmount);

          for iCount2 := 1 to iZoneCount do
          begin
               iArrayIndex := (iSpeciesCount * (iCount2 - 1)) + iCount;
               TA_zones.rtnValue(iArrayIndex,@rTA_zones);
               targ_zones.rtnValue(iArrayIndex,@rtarg_zones);
               rFeatureShortfall := 0;

               if (rtarg_zones > 0) then
               begin
                    if (rtarg_zones > rTA_zones) then
                    begin
                         rFeatureShortfall := rtarg_zones - rTA_zones;

                         rShortfall := rShortfall + rFeatureShortfall;
                         rFeatureShortfallFraction := rFeatureShortfall / rtarg_zones;
                         rShortfallFraction := rShortfallFraction + rFeatureShortfallFraction;
                         iShortfall := iShortfall + 1;
                    end;
               end;

               if fProduceDetailedOutput then
                  writeln(ShortFallFile,SpecChild.aGrid.Cells[0,iCount] + ',' +
                                        IntToStr(iCount2) + ',' +
                                        FloatToStr(rTA_zones) + ',' +
                                        FloatToStr(rtarg_zones) + ',' +
                                        FloatToStr(rFeatureShortfall));
                                        //'SPID,zone,area,target,shortfall');
          end;

          Pen.rtnValue(iCount,@rMarxanPenalty);
          rSPF := StrToFloat(SpecChild.aGrid.Cells[iSPF_Field,iCount]);

          // compute penalty for this target shortfall
          if (iShortfall > 1) then
             rFeaturePenalty := (rShortfallFraction / iShortfall) * rMarxanPenalty * rSPF
          else
              rFeaturePenalty := 0;

          rPenalty := rPenalty + rFeaturePenalty;

          if fCMOTargetAchievement then
          begin
               rInitialReserved := 0;
               TA.rtnValue(iCount,@rTA);

               // compute target percentage
               if (rTA > 0) then
                  rTargetPercentage := rtarg / rTA * 100
               else
                   rTargetPercentage := 0;
               // compute percent target in MPA
               if (rtarg > 0) then
                  rPercentTargetInMPA := rContribAmount / rtarg * 100
               else
                   rPercentTargetInMPA := 0;
               // compute missed target amount & percentage
               rMissedTargetAmount := rtarg - rInitialReserved - rContribAmount;
               if (rMissedTargetAmount < 0) then
                  rMissedTargetAmount := 0;
               if (rTA > 0) then
                  rMissedTargetPercentage := rMissedTargetAmount / rTA
               else
                   rMissedTargetPercentage := 0;

               writeln(TargetAchievementFile,IntToStr(iCount) + ',' +
                                             IntToStr(iCount) + ',' +
                                             FloatToStr(rInitialReserved) + ',' +
                                             FloatToStr(rTA) + ',' +
                                             FloatToStr(rTargetPercentage) + ',' +
                                             FloatToStr(rtarg) + ',' +
                                             FloatToStr(rPercentTargetInMPA) + ',' +
                                             FloatToStr(rContribAmount) + ',' +
                                             FloatToStr(rMissedTargetPercentage) + ',' +
                                             FloatToStr(rMissedTargetAmount));
          end;
     end;

     if fProduceDetailedOutput then
     begin
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
     end;

     if fCMOTargetAchievement then
     begin
          CloseFile(TargetAchievementFile);
          if (iValidation = 0) then
             SCPForm.CSVFileOpen(sTargetAchievementFileName);
     end;

     TA.Destroy;
     TA_zones.Destroy;
     targ.Destroy;
     targ_zones.Destroy;
     ZC.Destroy;
     Pen.Destroy;
     CA.Destroy;

     Result := rPenalty;
end;

function CustomFloatToStr(const rNumber : extended) : string;
begin
     result := FloatToStrF(rNumber,ffFixed,15,2);
end;

function ComputeMarxanPenalty(const iConfiguration,iTargetField,iPropField : integer;
                              TestConfigurationChild, PuChild, SpecChild, PenaltyChild : TCSVChild;
                              const fPenalty, fOverallTargetsInUse : boolean;
                              var rShortfall : extended; const iValidation : integer) : extended;
var
   rPenalty, rMarxanPenalty, rSPF, rFeaturePenalty, rTA, rTA_zones, rtarg,
   rtarg_zones, rAmount, rShortfallFraction, rFeatureShortfallFraction,
   rTargetField, rFeatureShortfall, rContribAmount, rInitialReserved,
   rTargetPercentage, rPercentTargetInMPA, rMissedTargetPercentage,
   rMissedTargetAmount, rPercentTotalInMPA : extended;
   iCount, iCount2, iSpeciesCount, iSPID, iPUID, iPUID_index, iPU_index,
   iStatus, iSP_index, iTargetType, iShortfall, iSPF_Field : integer;
   TA, targ, Pen, CA, IR : Array_t;
   sSummaryFileName, sTargetAchievementFileName, sConfigurationName : string;
   SummaryFile, ShortFallFile, TargetAchievementFile : TextFile;
   ARecord : typePuvsprRecord;
begin
     // compute the penalty of this zonation system
     rPenalty := 0;
     rMarxanPenalty := 1;
     rTA := 0;
     rTA_zones := 0;
     rtarg := 0;
     rtarg_zones := 0;
     rContribAmount := 0;
     rInitialReserved := 0;
     iPUID_index := -1;
     iStatus := 0;
     iSpeciesCount := SpecChild.aGrid.RowCount - 1;

     sConfigurationName := TestConfigurationChild.AGrid.Cells[iConfiguration,0];

     // init configuration output file
     if fCMOProduceDetail then
     begin
          sSummaryFileName := Copy(TestConfigurationChild.Caption,1,
                                   Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                                   '_summary_' + sConfigurationName + '.csv';
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
     end;

     // init target achievement output file
     if fCMOTargetAchievement then
     begin
          sTargetAchievementFileName := Copy(TestConfigurationChild.Caption,1,
                                        Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                                        '_targetachievement_' + sConfigurationName + '.csv'; //+ IntToStr(iConfiguration) + '.csv';
          sReportConfigurationsFileName := sTargetAchievementFileName;
          assignfile(TargetAchievementFile,sTargetAchievementFileName);
          rewrite(TargetAchievementFile);
          writeln(TargetAchievementFile,'Feature Name,Feature Key,Initial Reserved,Total in region'
                                        + ',Target %,Target Amount,% Target in MPA,% Total in MPA,Amount in MPA'
                                        //+ ',Target %,Target Amount,% Target in MPA,Amount in MPA,'
                                        + ',Missed Target %,Missed Target Amount');
     end;

     // init totalareas, targets, zone contrib, contrib area & penalty arrays
     TA := Array_t.Create;
     TA.init(SizeOf(extended),iSpeciesCount);
     targ := Array_t.Create;
     targ.init(SizeOf(extended),iSpeciesCount);
     Pen := Array_t.Create;
     Pen.init(SizeOf(extended),iSpeciesCount);
     CA := Array_t.Create;
     CA.init(SizeOf(extended),iSpeciesCount);
     IR := Array_t.Create;
     IR.init(SizeOf(extended),iSpeciesCount);

     for iCount := 1 to iSpeciesCount do
     begin
          TA.setValue(iCount,@rTA);
          targ.setValue(iCount,@rtarg);
          Pen.setValue(iCount,@rMarxanPenalty);
          CA.setValue(iCount,@rContribAmount);
          IR.setValue(iCount,@rInitialReserved);
     end;

     // parse penalty
     if fPenalty then
        for iCount := 1 to (PenaltyChild.aGrid.RowCount - 1) do
        begin
             iSPID := StrToInt(PenaltyChild.aGrid.Cells[0,iCount]);
             rMarxanPenalty := StrToFloat(PenaltyChild.aGrid.Cells[1,iCount]);

             iSP_index := FindChildIdLookupMatch(SpecChild,iSPID,True);

             Pen.setValue(iSP_index,@rMarxanPenalty);
        end;

     // compute total areas and contributing area
     //for iCount := 1 to (PuvsprChild.aGrid.RowCount - 1) do
     for iCount := 1 to PuvsprArray.lMaxSize do
     begin
          PuvsprArray.rtnValue(iCount,@ARecord);

          //iSPID := StrToInt(PuvsprChild.aGrid.Cells[0,iCount]);
          //iPUID := StrToInt(PuvsprChild.aGrid.Cells[1,iCount]);
          //rAmount := StrToFloat(PuvsprChild.aGrid.Cells[2,iCount]);
          iSPID := ARecord.iSPID;
          iPUID := ARecord.iPUID;
          rAmount := ARecord.rAmount;

          if (iPUID_index <> iPUID) then
          begin
               // lookup index and status of this planning unit
               iPU_index := FindChildIdLookupMatch(TestConfigurationChild,iPUID,fCMOSortOrder);
               iPUID_index := iPUID;
               if (iPU_index > -1) and (iPU_index < TestConfigurationChild.aGrid.RowCount) then
                  iStatus := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iPU_index])
               else
                   iStatus := 0;
          end;

          // find species index
          iSP_index := FindChildIdLookupMatch(SpecChild,iSPID,True);

          if (iSP_index = -1) then
          begin
               MessageDlg('Error in ComputeMarxanPenalty: SP index ' + IntToStr(iSP_index) +
                          ' count ' + IntToStr(iCount) +
                          ' SPID ' + IntToStr(iSPID) +
                          ' PUID ' + IntToStr(iPUID) +
                          ' Amount ' + FloatToStr(rAmount),
                          mtError,[mbOk],0);
               Application.Terminate;
          end;

          TA.rtnValue(iSP_index,@rTA);
          rTA := rTA + rAmount;
          TA.setValue(iSP_index,@rTA);

          if (iStatus = 1) then
          begin
               CA.rtnValue(iSP_index,@rContribAmount);
               rContribAmount := rContribAmount + rAmount;
               CA.setValue(iSP_index,@rContribAmount);
          end;

          if (iStatus = 2) then
          begin
               IR.rtnValue(iSP_index,@rInitialReserved);
               rInitialReserved := rInitialReserved + rAmount;
               IR.setValue(iSP_index,@rInitialReserved);
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
          IR.rtnValue(iCount,@rInitialReserved);
          TA.rtnValue(iCount,@rTA);
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

                    if fCMOProduceDetail then
                       writeln(ShortFallFile,SpecChild.aGrid.Cells[0,iCount] + ',' +
                                             FloatToStr(rContribAmount) + ',' +
                                             FloatToStr(rtarg) + ',' +
                                             FloatToStr(rFeatureShortfall));
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

          if fCMOTargetAchievement then
          begin
               // compute target percentage
               if (rTA > 0) then
               begin
                    rTargetPercentage := rtarg / rTA * 100;
                    rPercentTotalInMPA := rContribAmount / rTA * 100;
               end
               else
               begin
                    rTargetPercentage := 0;
                    rPercentTotalInMPA := 0;
               end;
               // compute percent target in MPA
               if (rtarg > 0) then
                  //rPercentTargetInMPA := (1 - (rContribAmount / rtarg)) * 100
                  rPercentTargetInMPA := rContribAmount / rtarg * 100
               else
                   rPercentTargetInMPA := 0;
               // compute missed target amount & percentage
               rMissedTargetAmount := rtarg - rInitialReserved - rContribAmount;
               if (rMissedTargetAmount < 0) then
                  rMissedTargetAmount := 0;
               if (rTA > 0) then
                  rMissedTargetPercentage := rMissedTargetAmount / rTA * 100
               else
                   rMissedTargetPercentage := 0;

               writeln(TargetAchievementFile,IntToStr(iCount) + ',' +
                                             IntToStr(iCount) + ',' +
                                             CustomFloatToStr(rInitialReserved) + ',' +
                                             CustomFloatToStr(rTA) + ',' +
                                             CustomFloatToStr(rTargetPercentage) + ',' +
                                             CustomFloatToStr(rtarg) + ',' +
                                             CustomFloatToStr(rPercentTargetInMPA) + ',' +
                                             CustomFloatToStr(rPercentTotalInMPA) + ',' +
                                             CustomFloatToStr(rContribAmount) + ',' +
                                             //FloatToStr(rInitialReserved) + ',' +
                                             CustomFloatToStr(rMissedTargetPercentage) + ',' +
                                             CustomFloatToStr(rMissedTargetAmount));
               //writeln(TargetAchievementFile,MarxanInterfaceForm.ReturnFeatureName(iCount) + ',' +
               (*writeln(TargetAchievementFile,IntToStr(iCount) + ',' +
                                             IntToStr(iCount) + ',' +
                                             FloatToStrF(rInitialReserved,ffCurrency,15,2) + ',' +
                                             FloatToStrF(rTA,ffCurrency,15,2) + ',' +
                                             FloatToStrF(rTargetPercentage,ffCurrency,15,2) + ',' +
                                             FloatToStrF(rtarg,ffCurrency,15,2) + ',' +
                                             FloatToStrF(rPercentTargetInMPA,ffCurrency,15,2) + ',' +
                                             FloatToStrF(rPercentTotalInMPA,ffCurrency,15,2) + ',' +
                                             FloatToStrF(rContribAmount,ffCurrency,15,2) + ',' +
                                             //FloatToStr(rInitialReserved) + ',' +
                                             FloatToStrF(rMissedTargetPercentage,ffCurrency,15,2) + ',' +
                                             FloatToStrF(rMissedTargetAmount,ffCurrency,15,2));*)
          end;
     end;

     if fCMOProduceDetail then
     begin
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
     end;

     if fCMOTargetAchievement then
     begin
          CloseFile(TargetAchievementFile);
          if (iValidation = 0) then
             SCPForm.CSVFileOpen(sTargetAchievementFileName);
     end;

     TA.Destroy;
     targ.Destroy;
     Pen.Destroy;
     CA.Destroy;
     IR.Destroy;

     Result := rPenalty;
end;

function ComputeMarProb1D_PenaltyAndProbability(const iConfiguration,iTargetField,iPropField : integer;
                                                TestConfigurationChild, PuChild, SpecChild, PenaltyChild : TCSVChild;
                                                const fPenalty, fOverallTargetsInUse : boolean;
                                                const rProbabilityWeighting : extended;
                                                var rShortfall, rSummedProbability : extended; const iValidation : integer) : extended;
var
   rPenalty, rMarxanPenalty, rSPF, rFeaturePenalty, rTA, rTA_zones, rtarg,
   rtarg_zones, rAmount, rShortfallFraction, rFeatureShortfallFraction,
   rTargetField, rFeatureShortfall, rContribAmount,
   rExpectedAmount, rVarianceInExpectedAmount, rProb, rRawProbability, rProbability, rZScore,
   rShortfallPenalty, r_ptarget1d : extended;
   iCount, iCount2, iSpeciesCount, iSPID, iPUID, iPUID_index, iPU_index,
   iStatus, iSP_index, iTargetType, iShortfall, iSPF_Field, iProbField,
   iHeavisideStepFunction, i_ptarget1d_Field : integer;
   TA, targ, Pen, CA, EA, VIEA, PR, RawPR, HSF, SFP, ptarg1d : Array_t;
   sSummaryFileName, sConfigurationName : string;
   SummaryFile, ShortFallFile : TextFile;
   ARecord : typePuvsprRecord;
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
     iHeavisideStepFunction := 0;
     rShortfallPenalty := 0;
     r_ptarget1d := 0;

     sConfigurationName := TestConfigurationChild.AGrid.Cells[iConfiguration,0];

     // init configuration output file
     if fCMOProduceDetail then
     begin
          sSummaryFileName := Copy(TestConfigurationChild.Caption,1,
                                   Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                                   '_summary_' + sConfigurationName + '.csv';
          assignfile(SummaryFile,sSummaryFileName);
          rewrite(SummaryFile);
          writeln(SummaryFile,'SPID,total area,target,contributing area,expected amount,variance in expected amount,RawP,HeavisideSF,ShortfallP,probability');
          // init shortfall output file
          sSummaryFileName := Copy(TestConfigurationChild.Caption,1,
                                   Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                                   '_shortfall_' + IntToStr(iConfiguration) + '.csv';
          assignfile(ShortFallFile,sSummaryFileName);
          rewrite(ShortFallFile);
          writeln(ShortFallFile,'SPID,contributing area,target,shortfall');
     end;

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
     HSF := Array_t.Create;
     HSF.init(SizeOf(integer),iSpeciesCount);
     SFP := Array_t.Create;
     SFP.init(SizeOf(extended),iSpeciesCount);
     ptarg1d := Array_t.Create;
     ptarg1d.init(SizeOf(extended),iSpeciesCount);
     RawPR := Array_t.Create;
     RawPR.init(SizeOf(extended),iSpeciesCount);

     for iCount := 1 to iSpeciesCount do
     begin
          TA.setValue(iCount,@rTA);
          targ.setValue(iCount,@rtarg);
          Pen.setValue(iCount,@rMarxanPenalty);
          CA.setValue(iCount,@rContribAmount);
          EA.setValue(iCount,@rExpectedAmount);
          VIEA.setValue(iCount,@rVarianceInExpectedAmount);
          PR.setValue(iCount,@rProbability);
          HSF.setValue(iCount,@iHeavisideStepFunction);
          SFP.setValue(iCount,@rShortfallPenalty);
          ptarg1d.setValue(iCount,@r_ptarget1d);
          RawPR.setValue(iCount,@rProbability);
     end;

     // parse penalty
     if fPenalty then
        for iCount := 1 to (PenaltyChild.aGrid.RowCount - 1) do
        begin
             iSPID := StrToInt(PenaltyChild.aGrid.Cells[0,iCount]);
             rMarxanPenalty := StrToFloat(PenaltyChild.aGrid.Cells[1,iCount]);

             iSP_index := FindChildIdLookupMatch(SpecChild,iSPID,True);

             Pen.setValue(iSP_index,@rMarxanPenalty);
        end;

     // which field is PROB
     iProbField := 0;
     for iCount := 1 to (PuChild.aGrid.ColCount - 1) do
         if (PuChild.aGrid.Cells[iCount,0] = 'prob') then
            iProbField := iCount;

     // compute total areas and contributing area
     for iCount := 1 to PuvsprArray.lMaxSize do
     begin
          PuvsprArray.rtnValue(iCount,@ARecord);

          iSPID := ARecord.iSPID;
          iPUID := ARecord.iPUID;
          rAmount := ARecord.rAmount;

          if (iPUID_index <> iPUID) then
          begin
               // lookup index, status & probability of this planning unit
               iPU_index := FindChildIdLookupMatch(TestConfigurationChild,iPUID,fCMOSortOrder);
               iPUID_index := iPUID;
               iStatus := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iPU_index]);
               iPU_index := FindChildIdLookupMatch(PuChild,iPUID,True);
               rProb := StrToFloat(PuChild.aGrid.Cells[iProbField,iPU_index]);
          end;

          // find species index
          iSP_index := FindChildIdLookupMatch(SpecChild,iSPID,True);

          TA.rtnValue(iSP_index,@rTA);
          rTA := rTA + rAmount;
          TA.setValue(iSP_index,@rTA);

          if (iStatus = 1) then
          begin
               CA.rtnValue(iSP_index,@rContribAmount);
               rContribAmount := rContribAmount + rAmount;
               CA.setValue(iSP_index,@rContribAmount);

               EA.rtnValue(iSP_index,@rExpectedAmount);
               rExpectedAmount := rExpectedAmount + (rAmount * (1 - rProb));
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
     // which spec field is ptarget1d
     iSPF_Field := 0;
     i_ptarget1d_Field := 0;
     for iCount := 1 to (SpecChild.aGrid.ColCount - 1) do
     begin
          if (SpecChild.aGrid.Cells[iCount,0] = 'spf') then
             iSPF_Field := iCount;
          if (SpecChild.aGrid.Cells[iCount,0] = 'ptarget1d') then
             i_ptarget1d_Field := iCount;
     end;

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

                    if fCMOProduceDetail then
                       writeln(ShortFallFile,SpecChild.aGrid.Cells[0,iCount] + ',' +
                                             FloatToStr(rContribAmount) + ',' +
                                             FloatToStr(rtarg) + ',' +
                                             FloatToStr(rFeatureShortfall));
               end;
          end;

          Pen.rtnValue(iCount,@rMarxanPenalty);
          rSPF := StrToFloat(SpecChild.aGrid.Cells[iSPF_Field,iCount]);

          if (i_ptarget1d_Field > 0) then
          begin
               r_ptarget1d := StrToFloat(SpecChild.aGrid.Cells[i_ptarget1d_Field,iCount]);
               ptarg1d.setValue(iCount,@r_ptarget1d);
          end;

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
                  rRawProbability := probZUT(rZScore)
               else
                   rRawProbability := 1 - probZUT(-1 * rZScore);

               RawPR.setValue(iCount,@rRawProbability);

               if (r_ptarget1d > rRawProbability) then
               begin
                    iHeavisideStepFunction := 1;
                    HSF.setValue(iCount,@iHeavisideStepFunction);
               end;

               if (r_ptarget1d > 0) then
               begin
                    rShortfallPenalty := (r_ptarget1d - rRawProbability) / r_ptarget1d;
                    SFP.setValue(iCount,@rShortfallPenalty);
               end;

               HSF.rtnValue(iCount,@iHeavisideStepFunction);
               SFP.rtnValue(iCount,@rShortfallPenalty);

               rProbability := iHeavisideStepFunction * rShortfallPenalty;

               rSummedProbability := rSummedProbability + rProbability;

               PR.setValue(iCount,@rProbability);
          end;
     end;

     if fCMOProduceDetail then
     begin
          closefile(ShortFallFile);

          // write total areas and targets to summary file
          for iCount := 1 to iSpeciesCount do
          begin
               TA.rtnValue(iCount,@rTA);
               targ.rtnValue(iCount,@rtarg);
               CA.rtnValue(iCount,@rContribAmount);
               EA.rtnValue(iCount,@rExpectedAmount);
               VIEA.rtnValue(iCount,@rVarianceInExpectedAmount);
               RawPR.rtnValue(iCount,@rRawProbability);
               PR.rtnValue(iCount,@rProbability);
               HSF.rtnValue(iCount,@iHeavisideStepFunction);
               SFP.rtnValue(iCount,@rShortfallPenalty);

               writeln(SummaryFile,SpecChild.aGrid.Cells[0,iCount] + ',' +
                                   FloatToStr(rTA) + ',' +
                                   FloatToStr(rtarg) + ',' +
                                   FloatToStr(rContribAmount) + ',' +
                                   FloatToStr(rExpectedAmount) + ',' +
                                   FloatToStr(rVarianceInExpectedAmount) + ',' +
                                   FloatToStr(rRawProbability) + ',' +
                                   IntToStr(iHeavisideStepFunction) + ',' +
                                   FloatToStr(rShortfallPenalty) + ',' +
                                   FloatToStr(rProbability));
          end;
          closefile(SummaryFile);
     end;

     TA.Destroy;
     targ.Destroy;
     Pen.Destroy;
     CA.Destroy;
     EA.Destroy;
     VIEA.Destroy;
     PR.Destroy;
     HSF.Destroy;
     SFP.Destroy;
     ptarg1d.Destroy;
     RawPR.Destroy;

     Result := rPenalty;
end;

function ComputeMarProb2D_PenaltyAndProbability(const iConfiguration : integer;
                                                TestConfigurationChild, PuChild, SpecChild, PenaltyChild : TCSVChild;
                                                const fPenalty, fOverallTargetsInUse : boolean;
                                                const rProbabilityWeighting : extended;
                                                var rShortfall, rSummedProbability : extended; const iValidation : integer) : extended;
var
   rPenalty, rMarxanPenalty, rSPF, rFeaturePenalty, rTA, rTA_zones, rtarg,
   rtarg_zones, rShortfallFraction, rFeatureShortfallFraction,
   rTargetField, rFeatureShortfall, rContribAmount,
   rExpectedAmount, rVarianceInExpectedAmount, rProbability, rRawProbability, rZScore,
   rShortfallPenalty, r_ptarget2d : extended;
   iCount, iCount2, iSpeciesCount, iSPID, iPUID, iPUID_index, iPU_index, iPropField,
   iStatus, iSP_index, iShortfall, iSPF_Field, iTargetOcc_Field,
   i_ptarget2d_Field, iHeavisideStepFunction : integer;
   TA, targ, Pen, CA, EA, VIEA, PR, RawPR, ptarg2d, HSF, SFP : Array_t;
   sSummaryFileName : string;
   SummaryFile, ShortFallFile, PUDetailFile : TextFile;
   ARecord : typePuvsprProb2dRecord;
   fProduceDetailedOutput, fProduceDetailedPuOutput, fRecordWritten : boolean;
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
     rRawProbability := 0;
     iPUID_index := -1;
     iStatus := 0;
     iSpeciesCount := SpecChild.aGrid.RowCount - 1;
     iHeavisideStepFunction := 0;
     rShortfallPenalty := 0;
     r_ptarget2d := 0;

     fProduceDetailedOutput := False;
     if fCMOProduceDetail then
        if (iConfiguration = 1) then
           fProduceDetailedOutput := True;

     // init configuration output file
     if fProduceDetailedOutput then
     begin
          sSummaryFileName := Copy(TestConfigurationChild.Caption,1,
                                   Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                                   '_summary_' + IntToStr(iConfiguration) + '.csv';
          assignfile(SummaryFile,sSummaryFileName);
          rewrite(SummaryFile);
          writeln(SummaryFile,'SPID,total area,target,contributing area,expected amount,variance in expected amount,RawP,HeavisideSF,ShortfallP,probability,Z score');
          // init shortfall output file
          sSummaryFileName := Copy(TestConfigurationChild.Caption,1,
                                   Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                                   '_shortfall_' + IntToStr(iConfiguration) + '.csv';
          assignfile(ShortFallFile,sSummaryFileName);
          rewrite(ShortFallFile);
          writeln(ShortFallFile,'SPID,contributing area,target,shortfall');
     end;

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
     RawPR := Array_t.Create;
     RawPR.init(SizeOf(extended),iSpeciesCount);
     HSF := Array_t.Create;
     HSF.init(SizeOf(integer),iSpeciesCount);
     SFP := Array_t.Create;
     SFP.init(SizeOf(extended),iSpeciesCount);
     ptarg2d := Array_t.Create;
     ptarg2d.init(SizeOf(extended),iSpeciesCount);

     for iCount := 1 to iSpeciesCount do
     begin
          TA.setValue(iCount,@rTA);
          targ.setValue(iCount,@rtarg);
          Pen.setValue(iCount,@rMarxanPenalty);
          CA.setValue(iCount,@rContribAmount);
          EA.setValue(iCount,@rExpectedAmount);
          VIEA.setValue(iCount,@rVarianceInExpectedAmount);
          PR.setValue(iCount,@rProbability);
          RawPR.setValue(iCount,@rRawProbability);
          HSF.setValue(iCount,@iHeavisideStepFunction);
          SFP.setValue(iCount,@rShortfallPenalty);
          ptarg2d.setValue(iCount,@r_ptarget2d);
     end;

     // parse penalty
     if fPenalty then
        for iCount := 1 to (PenaltyChild.aGrid.RowCount - 1) do
        begin
             iSPID := StrToInt(PenaltyChild.aGrid.Cells[0,iCount]);
             rMarxanPenalty := StrToFloat(PenaltyChild.aGrid.Cells[1,iCount]);

             iSP_index := FindChildIdLookupMatch(SpecChild,iSPID,True);

             Pen.setValue(iSP_index,@rMarxanPenalty);
        end;

     // which fields are ptarget2d, SPF, TARGETOCC
     // which spec field is SPF
     // which spec field is ptarget1d
     i_ptarget2d_Field := 0;
     iSPF_Field := 0;
     iTargetOcc_Field := 0;
     iPropField := 0;
     for iCount := 1 to (SpecChild.aGrid.ColCount - 1) do
     begin
          if (SpecChild.aGrid.Cells[iCount,0] = 'spf') then
             iSPF_Field := iCount;
          if (SpecChild.aGrid.Cells[iCount,0] = 'target') then
             iTargetOcc_Field := iCount;
          if (SpecChild.aGrid.Cells[iCount,0] = 'prop') then
             iPropField := iCount;
          if (SpecChild.aGrid.Cells[iCount,0] = 'ptarget2d') then
             i_ptarget2d_Field := iCount;
     end;

     fProduceDetailedPuOutput := False;
     if fCMOProducePUDetail then
        if (iConfiguration = 1) then
           fProduceDetailedPuOutput := True;

     if fProduceDetailedPuOutput then
     begin
          assignfile(PUDetailFile,Copy(TestConfigurationChild.Caption,1,
                                   Length(TestConfigurationChild.Caption) - Length(ExtractFileExt(TestConfigurationChild.Caption))) +
                                   '_pu_produce_detail_' + IntToStr(iConfiguration) + '.csv');
          rewrite(PUDetailFile);
          writeln(PUDetailFile,'i,PUID,SPID,status,amount,P,CA,EA,VIEA');
     end;

     // compute total areas and contributing area
     for iCount := 1 to PuvsprProb2dArray.lMaxSize do
     begin
          PuvsprProb2dArray.rtnValue(iCount,@ARecord);

          if (iPUID_index <> ARecord.iPUID) then
          begin
               // lookup index, status of this planning unit
               iPU_index := FindChildIdLookupMatch(TestConfigurationChild,ARecord.iPUID,fCMOSortOrder);
               iPUID_index := ARecord.iPUID;
               iStatus := StrToInt(TestConfigurationChild.aGrid.Cells[iConfiguration,iPU_index]);
               iPU_index := FindChildIdLookupMatch(PuChild,ARecord.iPUID,True);
          end;

          // find species index
          iSP_index := FindChildIdLookupMatch(SpecChild,ARecord.iSPID,True);

          TA.rtnValue(iSP_index,@rTA);
          rTA := rTA + ARecord.rAmount;
          TA.setValue(iSP_index,@rTA);

          if (iStatus = 1) or (iStatus = 2) then
          begin
               CA.rtnValue(iSP_index,@rContribAmount);
               rContribAmount := rContribAmount + ARecord.rAmount;
               CA.setValue(iSP_index,@rContribAmount);

               EA.rtnValue(iSP_index,@rExpectedAmount);
               rExpectedAmount := rExpectedAmount + (ARecord.rAmount * ARecord.rProb);
               EA.setValue(iSP_index,@rExpectedAmount);

               VIEA.rtnValue(iSP_index,@rVarianceInExpectedAmount);
               rVarianceInExpectedAmount := rVarianceInExpectedAmount + (ARecord.rAmount * ARecord.rAmount * ARecord.rProb * (1 - ARecord.rProb));
               VIEA.setValue(iSP_index,@rVarianceInExpectedAmount);
          end;

          if fProduceDetailedPuOutput then
          begin
               // 'i,PUID,SPID,status,target,amount,P,CA,EA,VIEA'
               write(PUDetailFile,IntToStr(iCount) + ',' +
                                    IntToStr(ARecord.iPUID) + ',' +
                                    IntToStr(ARecord.iSPID) + ',' +
                                    IntToStr(iStatus) + ',' +
                                    FloatToStr(ARecord.rAmount) + ',' +
                                    FloatToStr(ARecord.rProb) + ',');
               if (iStatus = 1) or (iStatus = 2) then
                  writeln(PUDetailFile,FloatToStr(ARecord.rAmount) + ',' +
                                       FloatToStr(ARecord.rAmount * ARecord.rProb) + ',' +
                                       FloatToStr(ARecord.rAmount * ARecord.rAmount * ARecord.rProb * (1 - ARecord.rProb)))
               else
                   writeln(PUDetailFile,'0,0,0');
          end;
     end;

     if fProduceDetailedPuOutput then
        closefile(PUDetailFile);

     // fetch targets & compute target shortfall and probability
     rShortfall := 0;
     rShortfallFraction := 0;
     for iCount := 1 to iSpeciesCount do
     begin
          // fetch targets
          if (iTargetOcc_Field = 0) then
          begin
               TA.rtnValue(iCount,@rTA);
               rtarg := StrToFloat(SpecChild.aGrid.Cells[iPropField,iCount]) * rTA;
               targ.setValue(iCount,@rtarg);
          end
          else
          begin
               rtarg := StrToFloat(SpecChild.aGrid.Cells[iTargetOcc_Field,iCount]);
               targ.setValue(iCount,@rtarg);
          end;

          if (i_ptarget2d_Field > 0) then
          begin
               r_ptarget2d := StrToFloat(SpecChild.aGrid.Cells[i_ptarget2d_Field,iCount]);
               ptarg2d.setValue(iCount,@r_ptarget2d);
          end;

          // compute target shortfall and probability
          iShortfall := 0;

          CA.rtnValue(iCount,@rContribAmount);

          fRecordWritten := False;

          if (rtarg > 0) then
          begin
               if (rtarg > rContribAmount) then
               begin
                    rFeatureShortfall := rtarg - rContribAmount;

                    rShortfall := rShortfall + rFeatureShortfall;
                    rFeatureShortfallFraction := rFeatureShortfall / rtarg;
                    rShortfallFraction := rShortfallFraction + rFeatureShortfallFraction;
                    iShortfall := iShortfall + 1;

                    fRecordWritten := True;

                    if fProduceDetailedOutput then
                       writeln(ShortFallFile,SpecChild.aGrid.Cells[0,iCount] + ',' +
                                             FloatToStr(rContribAmount) + ',' +
                                             FloatToStr(rtarg) + ',' +
                                             FloatToStr(rFeatureShortfall));
               end;
          end;

          if fProduceDetailedOutput then
             if not fRecordWritten then
                writeln(ShortFallFile,SpecChild.aGrid.Cells[0,iCount] + ',' +
                                             FloatToStr(rContribAmount) + ',' +
                                             FloatToStr(rtarg) + ',0');

          Pen.rtnValue(iCount,@rMarxanPenalty);
          rSPF := StrToFloat(SpecChild.aGrid.Cells[iSPF_Field,iCount]);

          // compute penalty for this target shortfall
          if (iShortfall > 1) then
             rFeaturePenalty := (rShortfallFraction / iShortfall) * rMarxanPenalty * rSPF
          else
              rFeaturePenalty := 0;

          rPenalty := rPenalty + rFeaturePenalty;

          rRawProbability := -999;
          rProbability := -999;
          rVarianceInExpectedAmount := -999;
          rExpectedAmount := -999;
          rZScore := -999;
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
                  rRawProbability := probZUT(rZScore)
               else
                   rRawProbability := 1 - probZUT(-1 * rZScore);
               RawPR.setValue(iCount,@rRawProbability);

               if (r_ptarget2d > rRawProbability) then
               begin
                    iHeavisideStepFunction := 1;
                    HSF.setValue(iCount,@iHeavisideStepFunction);
               end;

               if (r_ptarget2d > 0) then
               begin
                    rShortfallPenalty := (r_ptarget2d - rRawProbability) / r_ptarget2d;
                    SFP.setValue(iCount,@rShortfallPenalty);
               end;

               HSF.rtnValue(iCount,@iHeavisideStepFunction);
               SFP.rtnValue(iCount,@rShortfallPenalty);

               rProbability := iHeavisideStepFunction * rShortfallPenalty;

               rSummedProbability := rSummedProbability + rProbability;

               PR.setValue(iCount,@rProbability);
          end;

          if fProduceDetailedOutput then
          begin
               // write total areas and targets to summary file
               TA.rtnValue(iCount,@rTA);
               EA.rtnValue(iCount,@rExpectedAmount);
               VIEA.rtnValue(iCount,@rVarianceInExpectedAmount);
               RawPR.rtnValue(iCount,@rRawProbability);
               PR.rtnValue(iCount,@rProbability);
               HSF.rtnValue(iCount,@iHeavisideStepFunction);
               SFP.rtnValue(iCount,@rShortfallPenalty);

               writeln(SummaryFile,SpecChild.aGrid.Cells[0,iCount] + ',' +
                                   FloatToStr(rTA) + ',' +
                                   FloatToStr(rtarg) + ',' +
                                   FloatToStr(rContribAmount) + ',' +
                                   FloatToStr(rExpectedAmount) + ',' +
                                   FloatToStr(rVarianceInExpectedAmount) + ',' +
                                   FloatToStr(rRawProbability) + ',' +
                                   IntToStr(iHeavisideStepFunction) + ',' +
                                   FloatToStr(rShortfallPenalty) + ',' +
                                   FloatToStr(rProbability) + ',' +
                                   FloatToStr(rZScore));
          end;
     end;

     if fProduceDetailedOutput then
     begin
          closefile(ShortFallFile);
          closefile(SummaryFile);
     end;

     TA.Destroy;
     targ.Destroy;
     Pen.Destroy;
     CA.Destroy;
     EA.Destroy;
     VIEA.Destroy;
     PR.Destroy;
     RawPR.Destroy;
     HSF.Destroy;
     SFP.Destroy;
     ptarg2d.Destroy;

     Result := rPenalty;
end;

function ScanInputDat(const sScanString : string) : string;
var
   iCount, iLengthRow, iLengthScanString : integer;
   sResult, sLine : string;
   CMOInputDat : TextFile;
begin
     sResult := '';
     assignfile(CMOInputDat,sCMOInputDat);
     reset(CMOInputDat);

     repeat
           readln(CMOInputDat,sLine);

           if (Pos(sScanString,sLine) > 0) then
           begin
                iLengthRow := Length(sLine);
                iLengthScanString := Length(sScanString);

                sResult := Copy(sLine,iLengthScanString+1,iLengthRow-iLengthScanString);
                sResult := TrimLeadSpaces(sResult);
           end;

     until Eof(CMOInputDat);

     closefile(CMOInputDat);

     Result := sResult;
end;

function AreZoneTargetsInUse(ZoneTargetChild : TCSVChild) : boolean;
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

function AreOverallTargetsInUse(SpecChild : TCSVChild; var iTargetField, iPropField : integer) : boolean;
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

function CheckLockZoneEnforcement(const fPuLock,fPuZone : boolean;
                                  PuLockChild,PuZoneChild : TCSVChild) : integer;
begin
     try
        Result := 0;
     except
     end;
end;

procedure ExecuteMarZoneTest(sTestConfigurations : string; const rBLM : extended; const iValidation : integer);
var
   sInputDir, sPuName, sSpecName, sPuvsprName, sBoundName,
   sZonesName, sCostsName, sZoneTargetName, sZoneCostName, sZoneBoundCostName, sZoneContribName,
   sInputDirectory, sTestResultFileName, sOutputDir, sScenName, sPenaltyFileName,
   sPuZoneName, sPuLockName : string;
   fBound, fZones, fCosts, fZoneTarget, fZoneCost, fZoneBoundCost, fZoneContrib, fZoneContrib2,
   fZoneTargetsInUse, fOverallTargetsInUse, fPenalty, fPuZone, fPuLock : boolean;
   TestConfigurationChild, PuChild, SpecChild, BoundChild, ZonesChild, CostsChild,
   ZoneTargetChild, ZoneCostChild, ZoneBoundCostChild, ZoneContribChild, PenaltyChild,
   PuLockChild, PuZoneChild : TCSVChild;
   iCount, iNumberOfConfigurations, iTargetField, iPropField, iZoneEnforcement : integer;
   TestResults : TextFile;
   rConnectivity, rCost, rPenalty, rShortfall : extended;
begin
     try
        // scan input.dat to find parameters of interest
        sInputDir := ScanInputDat('INPUTDIR');
        sPuName := ScanInputDat('PUNAME');
        sSpecName := ScanInputDat('SPECNAME');
        if (sSpecName = '') then
           sSpecName := ScanInputDat('FEATNAME');
        sPuvsprName := ScanInputDat('PUVSPRNAME');
        if (sPuvsprName = '') then
           sPuvsprName := ScanInputDat('PUVFEATNAME');
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
        sZoneContribName := ScanInputDat('ZONECONTRIBNAME');
        fZoneContrib := (sZoneContribName <> '');
        if not fZoneContrib then
        begin
             sZoneContribName := ScanInputDat('ZONECONTRIB2NAME');
             fZoneContrib2 := (sZoneContribName <> '');
        end;
        sPuLockName := ScanInputDat('PULOCKNAME');
        fPuLock := (sPuLockName <> '');
        sPuZoneName := ScanInputDat('PUZONENAME');
        fPuZone := (sPuZoneName <> '');

        sInputDirectory := ExtractFilePath(sCMOInputDat) + sInputDir + '\';

        // open each input file
        // pu.dat
        SCPForm.CreateCSVChild(sInputDirectory + sPuName,0);
        PuChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sPuName));
        // spec.dat
        SCPForm.CreateCSVChild(sInputDirectory + sSpecName,0);
        SpecChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sSpecName));
        // puvspr2.dat
        //SCPForm.CreateCSVChild(sInputDirectory + sPuvsprName,0);
        //PuvsprChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sPuvsprName));
        InitPuvsprArray(sInputDirectory + sPuvsprName);
        // bound.dat
        if fBound then
        begin
             SCPForm.CreateCSVChild(sInputDirectory + sBoundName,0);
             BoundChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sBoundName));
        end;
        // zones.dat
        if fZones then
        begin
             SCPForm.CreateCSVChild(sInputDirectory + sZonesName,0);
             ZonesChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sZonesName));
        end;
        // costs.dat
        if fCosts then
        begin
             SCPForm.CreateCSVChild(sInputDirectory + sCostsName,0);
             CostsChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sCostsName));
        end;
        // zonetarget.dat
        if fZoneTarget then
        begin
             SCPForm.CreateCSVChild(sInputDirectory + sZoneTargetName,0);
             ZoneTargetChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sZoneTargetName));
        end;
        // zonecost.dat
        if fZoneCost then
        begin
             SCPForm.CreateCSVChild(sInputDirectory + sZoneCostName,0);
             ZoneCostChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sZoneCostName));
        end;
        // zoneboundcost.dat
        if fZoneBoundCost then
        begin
             SCPForm.CreateCSVChild(sInputDirectory + sZoneBoundCostName,0);
             ZoneBoundCostChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sZoneBoundCostName));
        end;
        // zonecontrib.dat
        if fZoneContrib then
        begin
             SCPForm.CreateCSVChild(sInputDirectory + sZoneContribName,0);
             ZoneContribChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sZoneContribName));
        end;
        if fZoneContrib2 then
        begin
             SCPForm.CreateCSVChild(sInputDirectory + sZoneContribName,0);
             ZoneContribChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sZoneContribName));
        end;
        if fPuLock then
        begin
             SCPForm.CreateCSVChild(sInputDirectory + sPuLockName,0);
             PuLockChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sPuLockName));
        end;
        if fPuZone then
        begin
             SCPForm.CreateCSVChild(sInputDirectory + sPuZoneName,0);
             PuZoneChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sPuZoneName));
        end;
        if fZoneTarget then
           fZoneTargetsInUse := AreZoneTargetsInUse(ZoneTargetChild)
        else
            fZoneTargetsInUse := False;

        // load output penalty file if it exists
        sPenaltyFileName := ExtractFilePath(sCMOInputDat) + sOutputDir + '\' + sScenName + '_penalty.csv';
        fPenalty := fileexists(sPenaltyFileName);
        if fPenalty then
        begin
             SCPForm.CreateCSVChild(sPenaltyFileName,0);
             PenaltyChild := TCSVChild(SCPForm.ReturnNamedChild(sPenaltyFileName));
        end;

        fOverallTargetsInUse := AreOverallTargetsInUse(SpecChild,iTargetField,iPropField);

        // perform tests on zoning configurations
        TestConfigurationChild := TCSVChild(SCPForm.ReturnNamedChild(sTestConfigurations));
        iNumberOfConfigurations := TestConfigurationChild.aGrid.ColCount - 1;

        sTestResultFileName := Copy(sTestConfigurations,1,Length(sTestConfigurations) - Length(ExtractFileExt(sTestConfigurations))) + '_summary.csv';
        assignfile(TestResults,sTestResultFileName);
        rewrite(TestResults);
        writeln(TestResults,'test,cost,connectivity,shortfall,zoneenforcement');

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
             //if fZones and fZoneTarget and fZoneContrib then
             if fZones then
                rPenalty := ComputeMarZonePenalty(iCount,iTargetField,iPropField,
                                        TestConfigurationChild, PuChild, SpecChild, ZonesChild, ZoneTargetChild, ZoneContribChild, PenaltyChild,
                                        fZones, fZoneTarget, fZoneContrib, fZoneContrib2, fPenalty, fZoneTargetsInUse, fOverallTargetsInUse,
                                        rShortfall,iValidation)
             else
                 rPenalty := 0;

             if fPuLock or fPuZone then
                iZoneEnforcement := CheckLockZoneEnforcement(fPuLock,fPuZone,PuLockChild,PuZoneChild)
             else
                 iZoneEnforcement := 0;

             writeln(TestResults,TestConfigurationChild.aGrid.Cells[iCount,0] + ',' +
                                 FloatToStr(rCost) + ',' +
                                 FloatToStr(rConnectivity) + ',' +
                                 FloatToStr(rShortfall) + ',' +
                                 IntToStr(iZoneEnforcement));
        end;

        closefile(TestResults);

        PuChild.Close;
        SpecChild.Close;
        //PuvsprChild.Close;
        PuvsprArray.Destroy;
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
        if fZoneContrib2 then
           ZoneContribChild.Close;
        if fPenalty then
           PenaltyChild.Close;
        if fPuLock then
           PuLockChild.Close;
        if fPuZone then
           PuZoneChild.Close;

        if fCMOCheckSummary then
           SCPForm.CreateCSVChild(sTestResultFileName,0);

     except
           MessageDlg('Exception in ExecuteMarZoneTest',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure ExecuteMarxanTest(sTestConfigurations : string; const rBLM : extended; const iValidation : integer);
var
   sInputDir, sPuName, sSpecName, sPuvsprName, sBoundName,
   sInputDirectory, sTestResultFileName, sOutputDir, sScenName, sPenaltyFileName,
   sConnectivityIn : string;
   fBound, fOverallTargetsInUse, fPenalty : boolean;
   TestConfigurationChild, PuChild, SpecChild, BoundChild, PenaltyChild : TCSVChild;
   iCount, iNumberOfConfigurations, iTargetField, iPropField : integer;
   TestResults : TextFile;
   rConnectivity, rCost, rPenalty, rShortfall : extended;
   fConnectivityIn : boolean;
begin
     // scan input.dat to find parameters of interest
     sInputDir := ScanInputDat('INPUTDIR');
     sPuName := ScanInputDat('PUNAME');
     sSpecName := ScanInputDat('SPECNAME');
     if (sSpecName = '') then
        sSpecName := ScanInputDat('FEATNAME');
     sPuvsprName := ScanInputDat('PUVSPRNAME');
     if (sPuvsprName = '') then
        sPuvsprName := ScanInputDat('PUVFEATNAME');
     sOutputDir := ScanInputDat('OUTPUTDIR');
     sScenName := ScanInputDat('SCENNAME');
     //rBLM := StrToFloat(ScanInputDat('BLM'));
     sConnectivityIn := ScanInputDat('CONNECTIVITYIN');
     fConnectivityIn := (CompareStr(sConnectivityIn,'1') = 0);

     sBoundName := ScanInputDat('BOUNDNAME');
     fBound := (sBoundName <> '');

     sInputDirectory := ExtractFilePath(sCMOInputDat) + sInputDir + '\';

     // open each input file
     // pu.dat
     SCPForm.CreateCSVChild(sInputDirectory + sPuName,0);
     PuChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sPuName));
     // spec.dat
     SCPForm.CreateCSVChild(sInputDirectory + sSpecName,0);
     SpecChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sSpecName));
     // puvspr2.dat
     //SCPForm.CreateCSVChild(sInputDirectory + sPuvsprName,0);
     //PuvsprChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sPuvsprName));
     InitPuvsprArray(sInputDirectory + sPuvsprName);
     // bound.dat
     if fBound then
     begin
          SCPForm.CreateCSVChild(sInputDirectory + sBoundName,0);
          BoundChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sBoundName));
     end;

     // load output penalty file if it exists
     sPenaltyFileName := ExtractFilePath(sCMOInputDat) + sOutputDir + '\' + sScenName + '_penalty.csv';
     fPenalty := fileexists(sPenaltyFileName);
     if fPenalty then
     begin
          SCPForm.CreateCSVChild(sPenaltyFileName,0);
          PenaltyChild := TCSVChild(SCPForm.ReturnNamedChild(sPenaltyFileName));
     end;

     fOverallTargetsInUse := AreOverallTargetsInUse(SpecChild,iTargetField,iPropField);

     // perform tests on reserve configurations
     TestConfigurationChild := TCSVChild(SCPForm.ReturnNamedChild(sTestConfigurations));
     iNumberOfConfigurations := TestConfigurationChild.aGrid.ColCount - 1;

     sTestResultFileName := Copy(sTestConfigurations,1,Length(sTestConfigurations) - Length(ExtractFileExt(sTestConfigurations))) + '_summary.csv';
     assignfile(TestResults,sTestResultFileName);
     rewrite(TestResults);
     writeln(TestResults,'summary,cost,connectivity,shortfall');

     for iCount := 1 to iNumberOfConfigurations do
     begin
          // compute cost
          rCost := ComputeMarxanCost(iCount, TestConfigurationChild, PuChild);

          // compute Connectivity
          if fBound then
             rConnectivity := ComputeMarxanConnectivity(iCount, rBLM, TestConfigurationChild, PuChild, BoundChild, fConnectivityIn)
          else
              rConnectivity := 0;

          // compute penalty
          rPenalty := ComputeMarxanPenalty(iCount,iTargetField,iPropField,
                                           TestConfigurationChild, PuChild, SpecChild, PenaltyChild,
                                           fPenalty, fOverallTargetsInUse, rShortfall, iValidation);

          writeln(TestResults,TestConfigurationChild.aGrid.Cells[iCount,0] + ',' +
                              FloatToStr(rCost) + ',' +
                              FloatToStr(rConnectivity) + ',' +
                              FloatToStr(rShortfall));
     end;

     closefile(TestResults);

     PuChild.Close;
     SpecChild.Close;
     //PuvsprChild.Close;
     PuvsprArray.Destroy;
     if fBound then
        BoundChild.Close;
     if fPenalty then
        PenaltyChild.Close;

     if fCMOCheckSummary then
        SCPForm.CreateCSVChild(sTestResultFileName,0);
end;

procedure ExecuteMarConTest(sTestConfigurations : string; const rBLM : extended; const iValidation : integer);
var
   sInputDir, sPuName, sSpecName, sPuvsprName, sBoundName,
   sInputDirectory, sTestResultFileName, sOutputDir, sScenName, sPenaltyFileName : string;
   fBound, fOverallTargetsInUse, fPenalty : boolean;
   TestConfigurationChild, PuChild, SpecChild, BoundChild, PenaltyChild : TCSVChild;
   iCount, iNumberOfConfigurations, iTargetField, iPropField : integer;
   TestResults : TextFile;
   rConnectivity, rCost, rPenalty, rShortfall : extended;
begin
     // scan input.dat to find parameters of interest
     sInputDir := ScanInputDat('INPUTDIR');
     sPuName := ScanInputDat('PUNAME');
     sSpecName := ScanInputDat('SPECNAME');
     if (sSpecName = '') then
        sSpecName := ScanInputDat('FEATNAME');
     sPuvsprName := ScanInputDat('PUVSPRNAME');
     if (sPuvsprName = '') then
        sPuvsprName := ScanInputDat('PUVFEATNAME');
     sOutputDir := ScanInputDat('OUTPUTDIR');
     sScenName := ScanInputDat('SCENNAME');
     //rBLM := StrToFloat(ScanInputDat('BLM'));

     sBoundName := ScanInputDat('BOUNDNAME');
     fBound := (sBoundName <> '');

     sInputDirectory := ExtractFilePath(sCMOInputDat) + sInputDir + '\';

     // open each input file
     // pu.dat
     SCPForm.CreateCSVChild(sInputDirectory + sPuName,0);
     PuChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sPuName));
     // spec.dat
     SCPForm.CreateCSVChild(sInputDirectory + sSpecName,0);
     SpecChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sSpecName));
     // puvspr2.dat
     InitPuvsprArray(sInputDirectory + sPuvsprName);
     // bound.dat
     if fBound then
     begin
          SCPForm.CreateCSVChild(sInputDirectory + sBoundName,0);
          BoundChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sBoundName));
     end;

     // load output penalty file if it exists
     sPenaltyFileName := ExtractFilePath(sCMOInputDat) + sOutputDir + '\' + sScenName + '_penalty.csv';
     fPenalty := fileexists(sPenaltyFileName);
     if fPenalty then
     begin
          SCPForm.CreateCSVChild(sPenaltyFileName,0);
          PenaltyChild := TCSVChild(SCPForm.ReturnNamedChild(sPenaltyFileName));
     end;

     fOverallTargetsInUse := AreOverallTargetsInUse(SpecChild,iTargetField,iPropField);

     // perform tests on reserve configurations
     TestConfigurationChild := TCSVChild(SCPForm.ReturnNamedChild(sTestConfigurations));
     iNumberOfConfigurations := TestConfigurationChild.aGrid.ColCount - 1;

     sTestResultFileName := Copy(sTestConfigurations,1,Length(sTestConfigurations) - Length(ExtractFileExt(sTestConfigurations))) + '_summary.csv';
     assignfile(TestResults,sTestResultFileName);
     rewrite(TestResults);
     writeln(TestResults,'test,cost,connectivity,shortfall');

     for iCount := 1 to iNumberOfConfigurations do
     begin
          // compute cost
          rCost := ComputeMarxanCost(iCount, TestConfigurationChild, PuChild);

          // compute Connectivity
          if fBound then
             rConnectivity := ComputeMarxanAsymmetricConnectivity(iCount, rBLM, TestConfigurationChild, PuChild, BoundChild)
          else
              rConnectivity := 0;

          // compute penalty
          rPenalty := ComputeMarxanPenalty(iCount,iTargetField,iPropField,
                                           TestConfigurationChild, PuChild, SpecChild, PenaltyChild,
                                           fPenalty, fOverallTargetsInUse, rShortfall, iValidation);

          writeln(TestResults,TestConfigurationChild.aGrid.Cells[iCount,0] + ',' +
                              FloatToStr(rCost) + ',' +
                              FloatToStr(rConnectivity) + ',' +
                              FloatToStr(rShortfall));
     end;

     closefile(TestResults);

     PuChild.Close;
     SpecChild.Close;
     PuvsprArray.Destroy;
     if fBound then
        BoundChild.Close;
     if fPenalty then
        PenaltyChild.Close;

     if fCMOCheckSummary then
        SCPForm.CreateCSVChild(sTestResultFileName,0);
end;

procedure ExecuteMarProb2DTest(sTestConfigurations : string; const rBLM : extended; const iValidation : integer);
var
   sInputDir, sPuName, sSpecName, sPuvsprName, sBoundName,
   sInputDirectory, sTestResultFileName, sOutputDir, sScenName, sPenaltyFileName,
   sConnectivityIn : string;
   fBound, fOverallTargetsInUse, fPenalty : boolean;
   TestConfigurationChild, PuChild, SpecChild, BoundChild, PenaltyChild : TCSVChild;
   iCount, iNumberOfConfigurations, iTargetField, iPropField : integer;
   TestResults : TextFile;
   rConnectivity, rCost, rPenalty, rShortfall, rProbability, rProbabilityWeighting : extended;
   fConnectivityIn : boolean;
begin
     // scan input.dat to find parameters of interest
     sInputDir := ScanInputDat('INPUTDIR');
     sPuName := ScanInputDat('PUNAME');
     sSpecName := ScanInputDat('SPECNAME');
     if (sSpecName = '') then
        sSpecName := ScanInputDat('FEATNAME');
     sPuvsprName := ScanInputDat('PUVSPRNAME');
     if (sPuvsprName = '') then
        sPuvsprName := ScanInputDat('PUVFEATNAME');
     sOutputDir := ScanInputDat('OUTPUTDIR');
     sScenName := ScanInputDat('SCENNAME');
     rProbabilityWeighting := StrToFloat(ScanInputDat('PROBABILITYWEIGHTING'));
     sConnectivityIn := ScanInputDat('CONNECTIVITYIN');
     fConnectivityIn := (CompareStr(sConnectivityIn,'1') = 0);

     sBoundName := ScanInputDat('BOUNDNAME');
     fBound := (sBoundName <> '');

     sInputDirectory := ExtractFilePath(sCMOInputDat) + sInputDir + '\';

     // open each input file
     // pu.dat
     SCPForm.CreateCSVChild(sInputDirectory + sPuName,0);
     PuChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sPuName));
     // spec.dat
     SCPForm.CreateCSVChild(sInputDirectory + sSpecName,0);
     SpecChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sSpecName));
     // puvspr2.dat
     InitPuvsprProb2dArray(sInputDirectory + sPuvsprName);
     // bound.dat
     if fBound then
     begin
          SCPForm.CreateCSVChild(sInputDirectory + sBoundName,0);
          BoundChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sBoundName));
     end;

     // load output penalty file if it exists
     sPenaltyFileName := ExtractFilePath(sCMOInputDat) + sOutputDir + '\' + sScenName + '_penalty.csv';
     fPenalty := fileexists(sPenaltyFileName);
     if fPenalty then
     begin
          SCPForm.CreateCSVChild(sPenaltyFileName,0);
          PenaltyChild := TCSVChild(SCPForm.ReturnNamedChild(sPenaltyFileName));
     end;

     fOverallTargetsInUse := AreOverallTargetsInUse(SpecChild,iTargetField,iPropField);

     // perform tests on reserve configurations
     TestConfigurationChild := TCSVChild(SCPForm.ReturnNamedChild(sTestConfigurations));
     iNumberOfConfigurations := TestConfigurationChild.aGrid.ColCount - 1;

     sTestResultFileName := Copy(sTestConfigurations,1,Length(sTestConfigurations) - Length(ExtractFileExt(sTestConfigurations))) + '_summary.csv';
     assignfile(TestResults,sTestResultFileName);
     rewrite(TestResults);
     writeln(TestResults,'test,cost,connectivity,shortfall,probability');

     for iCount := 1 to iNumberOfConfigurations do
     begin
          // compute cost
          rCost := ComputeMarxanCost(iCount, TestConfigurationChild, PuChild);

          // compute Connectivity
          if fBound then
             rConnectivity := ComputeMarxanConnectivity(iCount, rBLM, TestConfigurationChild, PuChild, BoundChild, fConnectivityIn)
          else
              rConnectivity := 0;

          // compute penalty and probability
          rPenalty := ComputeMarProb2D_PenaltyAndProbability(iCount,
                                                             TestConfigurationChild, PuChild, SpecChild, PenaltyChild,
                                                             fPenalty, fOverallTargetsInUse,
                                                             rProbabilityWeighting,
                                                             rShortfall,rProbability,iValidation);

          writeln(TestResults,TestConfigurationChild.aGrid.Cells[iCount,0] + ',' +
                              FloatToStr(rCost) + ',' +
                              FloatToStr(rConnectivity) + ',' +
                              FloatToStr(rShortfall) + ',' +
                              FloatToStr(rProbability));
     end;

     closefile(TestResults);

     PuChild.Close;
     SpecChild.Close;
     PuvsprProb2dArray.Destroy;
     if fBound then
        BoundChild.Close;
     if fPenalty then
        PenaltyChild.Close;

     if fCMOCheckSummary then
        SCPForm.CreateCSVChild(sTestResultFileName,0);
end;

procedure ExecuteMarProb1DTest(sTestConfigurations : string; const rBLM : extended; const iValidation : integer);
var
   sInputDir, sPuName, sSpecName, sPuvsprName, sBoundName,
   sInputDirectory, sTestResultFileName, sOutputDir, sScenName, sPenaltyFileName,
   sConnectivityIn : string;
   fBound, fOverallTargetsInUse, fPenalty : boolean;
   TestConfigurationChild, PuChild, SpecChild, BoundChild, PenaltyChild : TCSVChild;
   iCount, iNumberOfConfigurations, iTargetField, iPropField : integer;
   TestResults : TextFile;
   rConnectivity, rCost, rPenalty, rProbability, rShortfall, rProbabilityWeighting : extended;
   fConnectivityIn : boolean;
begin
     // scan input.dat to find parameters of interest
     sInputDir := ScanInputDat('INPUTDIR');
     sPuName := ScanInputDat('PUNAME');
     sSpecName := ScanInputDat('SPECNAME');
     if (sSpecName = '') then
        sSpecName := ScanInputDat('FEATNAME');
     sPuvsprName := ScanInputDat('PUVSPRNAME');
     if (sPuvsprName = '') then
        sPuvsprName := ScanInputDat('PUVFEATNAME');
     sOutputDir := ScanInputDat('OUTPUTDIR');
     sScenName := ScanInputDat('SCENNAME');
     //rBLM := StrToFloat(ScanInputDat('BLM'));
     rProbabilityWeighting := StrToFloat(ScanInputDat('PROBABILITYWEIGHTING'));
     sConnectivityIn := ScanInputDat('CONNECTIVITYIN');
     fConnectivityIn := (CompareStr(sConnectivityIn,'1') = 0);

     sBoundName := ScanInputDat('BOUNDNAME');
     fBound := (sBoundName <> '');

     sInputDirectory := ExtractFilePath(sCMOInputDat) + sInputDir + '\';

     // open each input file
     // pu.dat
     SCPForm.CreateCSVChild(sInputDirectory + sPuName,0);
     PuChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sPuName));
     // spec.dat
     SCPForm.CreateCSVChild(sInputDirectory + sSpecName,0);
     SpecChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sSpecName));
     // puvspr2.dat
     //SCPForm.CreateCSVChild(sInputDirectory + sPuvsprName,0);
     //PuvsprChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sPuvsprName));
     InitPuvsprArray(sInputDirectory + sPuvsprName);
     // bound.dat
     if fBound then
     begin
          SCPForm.CreateCSVChild(sInputDirectory + sBoundName,0);
          BoundChild := TCSVChild(SCPForm.ReturnNamedChild(sInputDirectory + sBoundName));
     end;

     // load output penalty file if it exists
     sPenaltyFileName := ExtractFilePath(sCMOInputDat) + sOutputDir + '\' + sScenName + '_penalty.csv';
     fPenalty := fileexists(sPenaltyFileName);
     if fPenalty then
     begin
          SCPForm.CreateCSVChild(sPenaltyFileName,0);
          PenaltyChild := TCSVChild(SCPForm.ReturnNamedChild(sPenaltyFileName));
     end;

     fOverallTargetsInUse := AreOverallTargetsInUse(SpecChild,iTargetField,iPropField);

     // perform tests on reserve configurations
     TestConfigurationChild := TCSVChild(SCPForm.ReturnNamedChild(sTestConfigurations));
     iNumberOfConfigurations := TestConfigurationChild.aGrid.ColCount - 1;

     sTestResultFileName := Copy(sTestConfigurations,1,Length(sTestConfigurations) - Length(ExtractFileExt(sTestConfigurations))) + '_summary.csv';
     assignfile(TestResults,sTestResultFileName);
     rewrite(TestResults);
     writeln(TestResults,'test,cost,connectivity,shortfall,probability');

     for iCount := 1 to iNumberOfConfigurations do
     begin
          // compute cost
          rCost := ComputeMarxanCost(iCount, TestConfigurationChild, PuChild);

          // compute Connectivity
          if fBound then
             rConnectivity := ComputeMarxanConnectivity(iCount, rBLM, TestConfigurationChild, PuChild, BoundChild, fConnectivityIn)
          else
              rConnectivity := 0;

          // compute penalty and probability
          rPenalty := ComputeMarProb1D_PenaltyAndProbability(iCount,iTargetField,iPropField,
                                           TestConfigurationChild, PuChild, SpecChild, PenaltyChild,
                                           fPenalty, fOverallTargetsInUse,
                                           rProbabilityWeighting,
                                           rShortfall,rProbability, iValidation);

          writeln(TestResults,TestConfigurationChild.aGrid.Cells[iCount,0] + ',' +
                              FloatToStr(rCost) + ',' +
                              FloatToStr(rConnectivity) + ',' +
                              FloatToStr(rShortfall) + ',' +
                              FloatToStr(rProbability));
     end;

     closefile(TestResults);

     PuChild.Close;
     SpecChild.Close;
     //PuvsprChild.Close;
     PuvsprArray.Destroy;
     if fBound then
        BoundChild.Close;
     if fPenalty then
        PenaltyChild.Close;

     if fCMOCheckSummary then
        SCPForm.CreateCSVChild(sTestResultFileName,0);
end;

end.
