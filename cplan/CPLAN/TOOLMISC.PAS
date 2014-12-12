unit Toolmisc;

{$I STD_DEF.PAS}

interface

uses
    Global, SysUtils,
  {$IFDEF bit16}
  Arrayt16;
  {$ELSE}
  ds;
  {$ENDIF}

var
   sGlobalHigh, sGlobalStep : extended;


procedure MapMemoryVariable2Display(const iVariableFlag, iSubset, iTenure2DisplayValuesFor, iCategoryCount : integer;
                                    const ASiteArr : Array_T;
                                    const iS_Count : integer;
                                      var iIr1Count, i001Count, i002Count,
                                          i003Count, i004Count, i005Count,
                                          i0CoCount : integer);
procedure MapMarxan2Display(const iVariableFlag, iSubset, iTenure2DisplayValuesFor,
                                          iCategoryCount : integer;
                                    const ASiteArr : Array_T;
                                    const iS_Count : integer;
                                      var iIr1Count, i001Count, i002Count,
                                          i003Count, i004Count, i005Count,
                                          i0CoCount : integer);

procedure RptErrorStop(const sMsg : string);
function OrdStr(const iEmrCat : integer) : string;

procedure MapSites(const SiteKeys : Array_t;
                   const fAddToMap : boolean);

implementation


uses
    Dialogs, spatio, Control, Forms,
    Controls, Sf_irrep, Contribu,
    av1, reallist, opt1,
    inifiles,
    marxan, sql_unit;
            

function OrdStr(const iEmrCat : integer) : string;
begin
     Result := IntToStr(iEmrCat);

     if (iEmrCat < 10) then
        Result := '00' + Result
     else
         if (iEmrCat < 100) then
            Result := '0' + Result;
end;

procedure MapSites(const SiteKeys : Array_t;
                   const fAddToMap : boolean);
var
   iSiteKey : integer;
   ASite : site;

   procedure ApplyMapSites;
   var
      iSiteKey, iSiteIndex, iCount : integer;
      fMapped : boolean;
   begin
        if not fAddToMap then
        begin
             // flush MappedSites array in case there are 1 or more selected sites in it
             fMapped := False;
             for iCount := 1 to iSiteCount do
                 MappedSites.setValue(iCount,@fMapped);
        end;

        if (SiteKeys.lMaxSize > 0) then
        begin
             fMapped := True;

             for iCount := 1 to SiteKeys.lMaxSize do
             begin
                  SiteKeys.rtnValue(iCount,@iSiteKey);
                  iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
                  // mark this site as mapped
                  MappedSites.setValue(iSiteIndex,@fMapped);
             end;
        end;

        // now display all mapped sites
        for iCount := 1 to iSiteCount do
        begin
             MappedSites.rtnValue(iCount,@fMapped);
             if fMapped then
             begin
                  SiteArr.rtnValue(iCount,@ASite);
                  ASite.sDisplay := 'SQL';
                  SiteArr.setValue(iCount,@ASite);
             end;
       end;
   end;

   procedure RefreshDatabaseGIS;
   var
      fSelect : boolean;
      sCmd : string;
   begin
        ControlForm.UpdateDatabase(TRUE);
        ControlForm.InformGIS;
        if (ControlRes^.GISLink = ArcView) then
        try
           {apply ControlRes^.iSelectSites
                  0 = select
                  1 = don't select
                  2 = ask user in they want to select}
           case ControlRes^.iSelectMapSites of
                0 : fSelect := True;
                1 : fSelect := False;
                2 : begin
                         if (mrYes = MessageDlg('Do you want the group of mapped sites selected in ArcView?',
                                                mtConfirmation,[mbYes,mbNo],0)) then
                            fSelect := True
                         else
                             fSelect := False;
                    end;
           end;

           {send CPlan.ZoomToValues command to ArcView which selects identified sites and zooms to them .DoNothing}
           if fSelect then
           begin
                sCmd := 'av.run("CPlan.ZoomToValues",{"' + ControlRes^.sAVView +
                        '","' + ControlRes^.sAVTheme + '","DISPLAY","SQL",';
                if ControlRes^.fZoomOnSelect then
                   sCmd := sCmd + '"True"})'
                else
                    sCmd := sCmd + '"False"})';
                ArcViewExecCmd(sCmd);
           end;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Error sending ArcView command' + sCmd,
                         mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;
   end;

begin
     try
        // store array of old 'SQL' sites
        // StoreOldSQLSites;

        // call MapMemoryVariable2Display
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

        // apply list of new 'SQL' sites (and old 'SQL' sites if 'Add to Map' is true
        ApplyMapSites;

        // refresh the database and gis if we are linked
        RefreshDatabaseGIS;


     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in MapSites',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure WriteSortedValuesToFile(const SortedValues : array_t;
                                  const sFilename : string);
var
   OutFile : TextFile;
   iCount : integer;
   aValue : trueFloatType;
begin
     assignfile(OutFile,sFilename);
     rewrite(OutFile);
     writeln(OutFile,'index,value');
     for iCount := 1 to SortedValues.lMaxSize do
     begin
          SortedValues.rtnValue(iCount,@aValue);
          writeln(OutFile,IntToStr(aValue.iIndex) + ',' + FloatToStr(aValue.rValue));
     end;
     closefile(OutFile);
end;

function rtnLastNonZeroValue(const SortedValues : array_t) : extended;
var
   iCount : integer;
   aValue : trueFloatType;
begin
     iCount := SortedValues.lMaxSize;
     repeat
           SortedValues.rtnValue(iCount,@aValue);
           Result := aValue.rValue;

           Dec(iCount);

     until (iCount = 0)
     or (Result > 0);
end;

procedure DumpMarxanSiteValues;
var
   iCount : integer;
   pSite : sitepointer;
   MarxanSiteResult : MarxanSiteResult_T;
   OutFile : TextFile;
begin
     //
     new(pSite);
     assignfile(OutFile,ControlRes^.sWorkingDirectory + '\marxan_gis.csv');
     rewrite(OutFile);
     writeln(OutFile,'SiteKey,Status,Irrep,MSUMMED,DISPLAY');

     for iCount := 1 to iSiteCount do
     begin
          SiteArr.rtnValue(iCount,pSite);
          MarxanSites.rtnValue(iCount,@MarxanSiteResult);

          writeln(OutFile,IntToStr(pSite^.iKey) + ',' + Status2Str(pSite^.status) + ',' +
                          FloatToStr(pSite^.rIrreplaceability) + ',' +
                          FloatToStr(MarxanSiteResult.iSummedSolution) + ',' + pSite^.sDisplay);
     end;

     dispose(pSite);
     closefile(OutFile);
end;

procedure MapMemoryVariable2Display(const iVariableFlag, iSubset, iTenure2DisplayValuesFor,
                                          iCategoryCount : integer;
                                    const ASiteArr : Array_T;
                                    const iS_Count : integer;
                                      var iIr1Count, i001Count, i002Count,
                                          i003Count, i004Count, i005Count,
                                          i0CoCount : integer);
var
   iNumber, iNonZeroValues : integer;
   iCount, iCount2 : integer;
   TmpSite : site;

   {rAllX, rAllXsqr, rSTDDEV, rMEAN,}
   sHigh,sStep,sCutOff : extended;

   rValue : extended;
   WS : WeightedSumirr_T;
   rSpatialValue : single;
   ClassCutOffPoints : array [1..50] of extended;

   ValueElement : trueFloatType;
   Values, SortedValues : Array_t;

   fWRADisplayCategories : boolean;

   MarxanSiteResult : MarxanSiteResult_T;

   // iVariableFlag = 10 means we are mapping marxan summed solution

   function rtnCurrentValue : extended;
   begin
        case iVariableFlag of
             0 :
             begin
                  if (iSubset = 0) then
                     Result := TmpSite.rIrreplaceability
                  else
                      Result := TmpSite.rSubsetIrr[iSubset];
             end;
             2 :
             begin
                  if (iSubset = 0) then
                     Result := TmpSite.rWAVIRR
                  else
                      Result := TmpSite.rSubsetWav[iSubset];
             end;
             1 :
             begin
                  {we need to determine which weightings to apply to sumirr}
                  if ControlRes^.fCalculateAllVariations then
                  begin
                       if ControlRes^.fSumirrWeightArea
                       or ControlRes^.fSumirrWeightTarget
                       or ControlRes^.fSumirrWeightVuln then
                       begin
                            {get weighted sum results because we need to use one of its values}
                            WeightedSumirr.rtnValue(iCount,@WS);
                            if (iSubset = 0) then
                            begin
                                 if ControlRes^.fSumirrWeightArea then
                                 begin
                                      if ControlRes^.fSumirrWeightTarget then
                                      begin
                                           if ControlRes^.fSumirrWeightVuln then
                                              Result := WS.r_atv
                                           else
                                               Result := WS.r_at;
                                      end
                                      else
                                      begin
                                           if ControlRes^.fSumirrWeightVuln then
                                              Result := WS.r_av
                                           else
                                               Result := WS.r_a;
                                      end;
                                 end
                                 else
                                 begin
                                      if ControlRes^.fSumirrWeightTarget then
                                      begin
                                           if ControlRes^.fSumirrWeightVuln then
                                              Result := WS.r_tv
                                           else
                                               Result := WS.r_t;
                                      end
                                      else
                                          if ControlRes^.fSumirrWeightVuln then
                                              Result := WS.r_v;
                                 end;
                            end
                            else
                            begin
                                 if ControlRes^.fSumirrWeightArea then
                                 begin
                                      if ControlRes^.fSumirrWeightTarget then
                                      begin
                                           if ControlRes^.fSumirrWeightVuln then
                                              Result := WS.r_sub_atv[iSubset]
                                           else
                                               Result := WS.r_sub_at[iSubset];
                                      end
                                      else
                                      begin
                                           if ControlRes^.fSumirrWeightVuln then
                                              Result := WS.r_sub_av[iSubset]
                                           else
                                               Result := WS.r_sub_a[iSubset];
                                      end;
                                 end
                                 else
                                 begin
                                      if ControlRes^.fSumirrWeightTarget then
                                      begin
                                           if ControlRes^.fSumirrWeightVuln then
                                              Result := WS.r_sub_tv[iSubset]
                                           else
                                               Result := WS.r_sub_t[iSubset];
                                      end
                                      else
                                          if ControlRes^.fSumirrWeightVuln then
                                              Result := WS.r_sub_v[iSubset];
                                 end;
                            end;
                       end
                       else
                       begin
                            if (iSubset = 0) then
                               Result := TmpSite.rSummedIrr
                            else
                                Result := TmpSite.rSubsetSum[iSubset];
                            end;
                  end
                  else
                  begin
                       {sumirr weighting variations are not being calculated, we
                        will just have to return the main values}
                       if (iSubset = 0) then
                          Result := TmpSite.rSummedIrr
                       else
                           Result := TmpSite.rSubsetSum[iSubset];
                  end;
             end;
             3 :
             begin
                  if (iSubset = 0) then
                     Result := TmpSite.rPCUSED
                  else
                      Result := TmpSite.rSubsetPCUsed[iSubset];
             end;
             10 :
             begin
                  // Marxan summed irreplaceability
                  // check if result exists
                  // return result for this site
                  Result := MarxanSiteResult.iSummedSolution;
             end;
        else
            // We need to return the value for one of the spatial values
            //     iCount is the 1 based current site
            //     (iVariableFlag - 3) is the 1 based current spatial variable
            //     iS_Count is the total number of sites
            try
               SpatResult.rtnValue(((iVariableFlag-4)*iS_Count)+iCount,@rSpatialValue);
               Result := rSpatialValue;
            except
                  // we are trying to access a value that is not stored
                  Result := 0;
            end;
        end;
   end; {of function rtnCurrentValue}

   procedure ClassSiteByValue;
   var
      iCatCount : integer;
   begin
        if (TmpSite.richness = 0)
        or (rValue = 0) then
        begin
             if TmpSite.fSiteHasUse
             and (not (iVariableFlag=10)) then
             begin
                  TmpSite.sDisplay := '005';
                  Inc(i005Count);
             end
             else
             begin
                  TmpSite.sDisplay := '0Co';
                  Inc(i0CoCount);
             end;
        end
        else
        if (rValue = sHigh) then
        begin
             if (iVariableFlag = 0) then
             begin
                  TmpSite.sDisplay := 'Ir1';
                  Inc(iIr1Count);
             end
             else
             begin
                  if (iVariableFlag=10) then
                     TmpSite.sDisplay := 'Max'
                  else
                      TmpSite.sDisplay := '001';
             end;
        end
        else
        for iCatCount := (iCategoryCount-1) downto 1 do
        begin
             //sCutOff := sHigh - (iCatCount * sStep);
             sCutOff := ClassCutOffPoints[iCatCount];

             if (rValue >= sCutOff) then
             begin
                  TmpSite.sDisplay := OrdStr(iCatCount);
             end;
        end;

        case TmpSite.sDisplay[3] of
             '1' : inc(i001Count);
             '2' : inc(i002Count);
             '3' : inc(i003Count);
             '4' : inc(i004Count);
             '5' : inc(i005Count);
        end;

   end; {of procedure ClassSiteByValue}

   procedure DetermineValueCutOffPoints;
   var
      iSitesIn001, iSitesIn002, iSitesIn003, iSitesIn004, iSitesIn005 : integer;
   begin
        // using the sorted value array, set the cut-off points for the display classes
        // top 1% of sites by number in 001
        iSitesIn001 := Round(iNonZeroValues * 0.01);
        if (iSitesIn001 = 0) then
           iSitesIn001 := 1;
        SortedValues.rtnValue(iSitesIn001,@ValueElement);
        ClassCutOffPoints[1] := ValueElement.rValue;
        // top 6% in 002
        iSitesIn002 := Round(iNonZeroValues * 0.06);
        if (iSitesIn002 = 0) then
           iSitesIn002 := 1;
        SortedValues.rtnValue(iSitesIn002,@ValueElement);
        ClassCutOffPoints[2] := ValueElement.rValue;
        // top 20% in 003
        iSitesIn003 := Round(iNonZeroValues * 0.20);
        if (iSitesIn003 = 0) then
           iSitesIn003 := 1;
        SortedValues.rtnValue(iSitesIn003,@ValueElement);
        ClassCutOffPoints[3] := ValueElement.rValue;
        // top 50% in 004
        iSitesIn004 := Round(iNonZeroValues * 0.50);
        if (iSitesIn004 = 0) then
           iSitesIn004 := 1;
        SortedValues.rtnValue(iSitesIn004,@ValueElement);
        ClassCutOffPoints[4] := ValueElement.rValue;
        // find first non zero value in the list to assign to class 005
        ClassCutOffPoints[5] := rtnLastNonZeroValue(SortedValues);
        // if last non-zero value is in one of the classes 001 to 004, adjust 005 cut-off accordingly
        if (ClassCutOffPoints[5] > ClassCutOffPoints[4]) then
           ClassCutOffPoints[5] := 0;
   end;

   procedure DetermineValueCutOffPointsWRA;
   var
      iSitesIn001, iSitesIn002, iSitesIn003, iSitesIn004, iSitesIn005 : integer;
   begin
        // using the sorted value array, set the cut-off points for the display classes
        // top 5% of sites by number in 001
        iSitesIn001 := Round(iNonZeroValues * 0.05);
        if (iSitesIn001 = 0) then
           iSitesIn001 := 1;
        SortedValues.rtnValue(iSitesIn001,@ValueElement);
        ClassCutOffPoints[1] := ValueElement.rValue;
        // top 10% in 002
        iSitesIn002 := Round(iNonZeroValues * 0.10);
        if (iSitesIn002 = 0) then
           iSitesIn002 := 1;
        SortedValues.rtnValue(iSitesIn002,@ValueElement);
        ClassCutOffPoints[2] := ValueElement.rValue;
        // top 20% in 003
        iSitesIn003 := Round(iNonZeroValues * 0.20);
        if (iSitesIn003 = 0) then
           iSitesIn003 := 1;
        SortedValues.rtnValue(iSitesIn003,@ValueElement);
        ClassCutOffPoints[3] := ValueElement.rValue;
        // top 50% in 004
        iSitesIn004 := Round(iNonZeroValues * 0.50);
        if (iSitesIn004 = 0) then
           iSitesIn004 := 1;
        SortedValues.rtnValue(iSitesIn004,@ValueElement);
        ClassCutOffPoints[4] := ValueElement.rValue;
        // find first non zero value in the list to assign to class 005
        ClassCutOffPoints[5] := rtnLastNonZeroValue(SortedValues);
        // if last non-zero value is in one of the classes 001 to 004, adjust 005 cut-off accordingly
        if (ClassCutOffPoints[5] > ClassCutOffPoints[4]) then
           ClassCutOffPoints[5] := 0;
   end;

   function ScanIniWRASettings : boolean;
   var
      AIni : TIniFile;
   begin
        AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
        AIni.ReadBool('WRA Display Categories','WRA Display Categories',False);
        AIni.Free;
   end;

begin
     try

        if (iVariableFlag = 10)
        and ControlRes^.fMarxanDatabaseExists
        and fMarxanResultCreated then
            MapMarxan2Display(iVariableFlag, iSubset, iTenure2DisplayValuesFor,
                              iCategoryCount,ASiteArr,iS_Count,
                              iIr1Count, i001Count, i002Count,
                              i003Count, i004Count, i005Count,
                              i0CoCount)
        else
        begin
             {iTenure2DisplayValuesFor indicates whether we
              are displaying irreplaceability values for:
              0 Available Sites
              1 Deferred Sites}

             fWRADisplayCategories := ScanIniWRASettings;

             sHigh := 0;
             sStep := 0.2;

             Values := Array_t.Create;
             Values.init(SizeOf(ValueElement),iSiteCount);

             iNonZeroValues := 0;

             {first parse to find}
             iNumber := 0;
             for iCount := 1 to iS_Count do
             begin
                  ASiteArr.rtnValue(iCount,@TmpSite);

                  if ControlRes^.fMarxanDatabaseExists
                  and fMarxanResultCreated then
                      MarxanSites.rtnValue(iCount,@MarxanSiteResult);

                  {need to screen status before we assess value}
                  case TmpSite.status of
                       Av{, Fl} : {Available Site}
                                  if (iTenure2DisplayValuesFor = 0) then
                                  begin
                                       rValue := rtnCurrentValue;

                                       if (rValue > sHigh) then
                                          sHigh := rValue;

                                       if (rValue > 0) then
                                          Inc(iNonZeroValues);

                                       Inc(iNumber);
                                       ValueElement.iIndex := iCount;
                                       ValueElement.rValue := rValue;
                                       Values.setValue(iNumber,@ValueElement);
                                  end
                                  else
                                      rValue := 0;
                       _R1, _R2, _R3, _R4, _R5 : {Deferred Site}
                                if (iTenure2DisplayValuesFor = 1) then
                                begin
                                     rValue := rtnCurrentValue;

                                     if (rValue > sHigh) then
                                        sHigh := rValue;

                                     if (rValue > 0) then
                                        Inc(iNonZeroValues);

                                     Inc(iNumber);
                                     ValueElement.iIndex := iCount;
                                     ValueElement.rValue := rValue;
                                     Values.setValue(iNumber,@ValueElement);
                                end
                                else
                                    rValue := 0;
                  end;
             end;

             if (iNonZeroValues = 0) then
                iNonZeroValues := 1;

             if (iNumber > 0) then
             begin
                  if (iNumber <> Values.lMaxSize) then
                     Values.resize(iNumber);

                  SortedValues := SortFloatArray(Values);

                  if fWRADisplayCategories then
                     DetermineValueCutOffPointsWRA
                  else
                      DetermineValueCutOffPoints;

                  SortedValues.Destroy;
             end
             else
             begin
                  ClassCutOffPoints[1] := 0;
                  ClassCutOffPoints[2] := 0;
                  ClassCutOffPoints[3] := 0;
                  ClassCutOffPoints[4] := 0;
                  ClassCutOffPoints[5] := 0;
             end;

             {iCategoryCount is the number of intermediate categories below the high and low values,
              ie. 5 corresponds to 001, 002, 003, 004, 005}
             {set the step size for scaling values}
             sStep := sHigh / iCategoryCount;

             // make sure Irrep Ir1 values are for 1 only
             case iVariableFlag of
                  1 :
                  if ControlRes^.fDisplayAbsSumirr then
                  begin
                       ClassCutOffPoints[1] := sHigh - sStep;
                       ClassCutOffPoints[2] := sHigh - (sStep * 2);
                       ClassCutOffPoints[3] := sHigh - (sStep * 3);
                       ClassCutOffPoints[4] := sHigh - (sStep * 4);
                       ClassCutOffPoints[5] := 0;
                  end;
                  0, 2 :
                  begin
                       sHigh := 1;
                       sStep := 0.2;
                       ClassCutOffPoints[1] := 0.8;
                       ClassCutOffPoints[2] := 0.6;
                       ClassCutOffPoints[3] := 0.4;
                       ClassCutOffPoints[4] := 0.2;
                       ClassCutOffPoints[5] := 0;
                  end;
                  3 :
                  begin
                       sHigh := 100;
                       sStep := 20;
                       ClassCutOffPoints[1] := 80;
                       ClassCutOffPoints[2] := 60;
                       ClassCutOffPoints[3] := 40;
                       ClassCutOffPoints[4] := 20;
                       ClassCutOffPoints[5] := 0;
                  end;
             else
                 ClassCutOffPoints[1] := sHigh - sStep;
                 ClassCutOffPoints[2] := sHigh - (sStep * 2);
                 ClassCutOffPoints[3] := sHigh - (sStep * 3);
                 ClassCutOffPoints[4] := sHigh - (sStep * 4);
                 ClassCutOffPoints[5] := 0;
             end;

             sGlobalHigh := sHigh;
             sGlobalStep := sStep;

             iIr1Count := 0;
             i001Count := 0;
             i002Count := 0;
             i003Count := 0;
             i004Count := 0;
             i005Count := 0;
             i0CoCount := 0;

             for iCount := 1 to iS_Count do
             {second parse to apply cutoffs}
             begin
                  ASiteArr.rtnValue(iCount,@TmpSite);
                  if ControlRes^.fMarxanDatabaseExists
                  and fMarxanResultCreated then
                      MarxanSites.rtnValue(iCount,@MarxanSiteResult);

                  if (iVariableFlag=10) then
                     TmpSite.sDisplay := '0Co'
                  else
                      TmpSite.sDisplay := '005'; {lowest irreplacability cat by default}
                  //TmpSite.rIrreplaceability := dDouble;

                  rValue := rtnCurrentValue;
                  GISSiteValues.setValue(iCount,@rValue);

                  case TmpSite.status of
                       Pd : TmpSite.sDisplay := 'PDe';
                       Fl : TmpSite.sDisplay := 'Flg';
                       Ex : TmpSite.sDisplay := 'Exc';
                       Ig : TmpSite.sDisplay := 'Ign';
                       Re : TmpSite.sDisplay := 'Res';

                       _R1, _R2, _R3, _R4, _R5 : if (iTenure2DisplayValuesFor = 0) then
                                   {displaying values for Available Sites}
                                   begin
                                        case TmpSite.status of
                                             {_R1 : TmpSite.sDisplay := 'Neg';
                                             _R2,_R3,_R4,_R5 : TmpSite.sDisplay := 'Man';}
                                             _R1 : TmpSite.sDisplay := 'R1';
                                             _R2 : TmpSite.sDisplay := 'R2';
                                             _R3 : TmpSite.sDisplay := 'R3';
                                             _R4 : TmpSite.sDisplay := 'R4';
                                             _R5 : TmpSite.sDisplay := 'R5';
                                        end;
                                   end
                                else
                                    {displaying values for Deferred Sites}
                                    ClassSiteByValue;

                       Av : if (iTenure2DisplayValuesFor = 0) then
                               ClassSiteByValue
                            else
                                TmpSite.sDisplay := 'Ava';
                  end;

                  ASiteArr.setValue(iCount,@TmpSite);
             end;

             Values.Destroy;

             ControlRes^.rDisplayMaximumValue := sHigh;

             //if ControlRes^.fMarxanDatabaseExists
             //and fMarxanResultCreated then
             //    DumpMarxanSiteValues;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in MapMemoryVariable2Display',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure MapMarxan2Display(const iVariableFlag, iSubset, iTenure2DisplayValuesFor,
                                          iCategoryCount : integer;
                                    const ASiteArr : Array_T;
                                    const iS_Count : integer;
                                      var iIr1Count, i001Count, i002Count,
                                          i003Count, i004Count, i005Count,
                                          i0CoCount : integer);
var
   iNumber, iNonZeroValues : integer;
   iCount, iCount2 : integer;
   TmpSite : site;

   {rAllX, rAllXsqr, rSTDDEV, rMEAN,}
   sHigh,sStep,sCutOff : extended;

   rValue : extended;
   WS : WeightedSumirr_T;
   rSpatialValue : single;
   ClassCutOffPoints : array [1..50] of extended;

   ValueElement : trueFloatType;
   Values, SortedValues : Array_t;

   fWRADisplayCategories : boolean;

   MarxanSiteResult : MarxanSiteResult_T;

   procedure ClassSiteByValue;
   var
      iCatCount : integer;
   begin
        if (rValue = 0) then
        begin
             TmpSite.sDisplay := '0Co';
             Inc(i0CoCount);
        end
        else
        if (rValue = sHigh) then
        begin
             TmpSite.sDisplay := 'Max';
             Inc(iIr1Count);
        end
        else
        for iCatCount := iCategoryCount downto 1 do
        begin
             sCutOff := ClassCutOffPoints[iCatCount];

             if (rValue > sCutOff) then
             begin
                  TmpSite.sDisplay := OrdStr(iCatCount);
             end;
        end;

        case TmpSite.sDisplay[3] of
             '1' : inc(i001Count);
             '2' : inc(i002Count);
             '3' : inc(i003Count);
             '4' : inc(i004Count);
             '5' : inc(i005Count);
        end;

   end; {of procedure ClassSiteByValue}

begin
     try
        {iTenure2DisplayValuesFor indicates whether we
         are displaying irreplaceability values for:
         0 Available Sites
         1 Deferred Sites}

        sHigh := 0;
        sStep := 0.2;

        Values := Array_t.Create;
        Values.init(SizeOf(ValueElement),iSiteCount);

        iNonZeroValues := 0;

        {first parse to find}
        iNumber := 0;
        for iCount := 1 to iS_Count do
        begin
             ASiteArr.rtnValue(iCount,@TmpSite);

             MarxanSites.rtnValue(iCount,@MarxanSiteResult);

             {need to screen status before we assess value}
             case TmpSite.status of
                  Av{, Fl} : {Available Site}
                             if (iTenure2DisplayValuesFor = 0) then
                             begin
                                  rValue := MarxanSiteResult.iSummedSolution;

                                  if (rValue > sHigh) then
                                     sHigh := rValue;

                                  if (rValue > 0) then
                                     Inc(iNonZeroValues);

                                  Inc(iNumber);
                                  ValueElement.iIndex := iCount;
                                  ValueElement.rValue := rValue;
                                  Values.setValue(iNumber,@ValueElement);
                             end
                             else
                                 rValue := 0;
                  _R1, _R2, _R3, _R4, _R5 : {Deferred Site}
                           if (iTenure2DisplayValuesFor = 1) then
                           begin
                                rValue := MarxanSiteResult.iSummedSolution;

                                if (rValue > sHigh) then
                                   sHigh := rValue;

                                if (rValue > 0) then
                                   Inc(iNonZeroValues);

                                Inc(iNumber);
                                ValueElement.iIndex := iCount;
                                ValueElement.rValue := rValue;
                                Values.setValue(iNumber,@ValueElement);
                           end
                           else
                               rValue := 0;
             end;
        end;

        if (iNonZeroValues = 0) then
           iNonZeroValues := 1;

        {iCategoryCount is the number of intermediate categories below the high and low values,
         ie. 5 corresponds to 001, 002, 003, 004, 005}
        {set the step size for scaling values}
        sStep := sHigh / iCategoryCount;

        ClassCutOffPoints[1] := sHigh - sStep;
        ClassCutOffPoints[2] := sHigh - (sStep * 2);
        ClassCutOffPoints[3] := sHigh - (sStep * 3);
        ClassCutOffPoints[4] := sHigh - (sStep * 4);
        ClassCutOffPoints[5] := 0;

        sGlobalHigh := sHigh;
        sGlobalStep := sStep;

        iIr1Count := 0;
        i001Count := 0;
        i002Count := 0;
        i003Count := 0;
        i004Count := 0;
        i005Count := 0;
        i0CoCount := 0;

        for iCount := 1 to iS_Count do
        {second parse to apply cutoffs}
        begin
             ASiteArr.rtnValue(iCount,@TmpSite);
             MarxanSites.rtnValue(iCount,@MarxanSiteResult);

             TmpSite.sDisplay := '005';

             rValue := MarxanSiteResult.iSummedSolution;
             GISSiteValues.setValue(iCount,@rValue);

             case TmpSite.status of
                  Pd : TmpSite.sDisplay := 'PDe';
                  Fl : TmpSite.sDisplay := 'Flg';
                  Ex : TmpSite.sDisplay := 'Exc';
                  Ig : TmpSite.sDisplay := 'Ign';
                  Re : TmpSite.sDisplay := 'Res';

                  _R1, _R2, _R3, _R4, _R5 : if (iTenure2DisplayValuesFor = 0) then
                              {displaying values for Available Sites}
                              begin
                                   case TmpSite.status of
                                        {_R1 : TmpSite.sDisplay := 'Neg';
                                        _R2,_R3,_R4,_R5 : TmpSite.sDisplay := 'Man';}
                                        _R1 : TmpSite.sDisplay := 'R1';
                                        _R2 : TmpSite.sDisplay := 'R2';
                                        _R3 : TmpSite.sDisplay := 'R3';
                                        _R4 : TmpSite.sDisplay := 'R4';
                                        _R5 : TmpSite.sDisplay := 'R5';
                                   end;
                              end
                           else
                               {displaying values for Deferred Sites}
                               ClassSiteByValue;

                  Av : if (iTenure2DisplayValuesFor = 0) then
                          ClassSiteByValue
                       else
                           TmpSite.sDisplay := 'Ava';
             end;

             ASiteArr.setValue(iCount,@TmpSite);
        end;

        Values.Destroy;

        ControlRes^.rDisplayMaximumValue := sHigh;

        //if ControlRes^.fMarxanDatabaseExists
        //and fMarxanResultCreated then
        //    DumpMarxanSiteValues;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in MapMarxan2Display',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


procedure RptErrorStop(const sMsg : string);
begin
     MessageDlg(sMsg + ' - Error',mtError,[mbOK],0);
end;

end.
