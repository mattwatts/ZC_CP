unit Reports;

{$I STD_DEF.PAS}

interface


uses
  {Control,} Global, StdCtrls, DBTables,
  {$IFDEF bit16}
  Arrayt16, Cpng_imp;
  {$ELSE}
  ds, Dll_u1;
  {$ENDIF}




procedure ReportFeatures(const sFile, sDescr : string; const fTestFileExists : boolean;
                        const fUseITarget : boolean; const FArr : Array_t;
                        const  iFCount : integer;
                        const rPC : extended;
                        const sTerminologyType : string); export;
procedure ReportTotals(const sFile, sDescr : string; const fTestFileExists : boolean;
                       const RptBox : TListbox; const SArr : Array_t;
                       const iSCount, iIr1Count,i001Count,i002Count,i003Count,
                       i004Count,i005Count,i0CoCount,
                       iAv, iFl, iRe, iIg, iR1, iR2, iR3, iR4, iR5, iPd, iEx : integer); export;
procedure ReportMissingFeatures(const sFile,sDescr : string; const fTestFileExists : boolean;
                                const RptBox : TListbox; const CTable : TTable;
                                const  CRes : ControlResPointer_T;
                                const OFArr, FArr : Array_t); export;
procedure ReportPartial(const sFile, sDescr : string; const fTestFileExists : boolean;
                        const RptBox, PGeocode : TListbox; const SArr : Array_t;
                        const  FArr : Array_t;
                        const OSArr, OFArr : Array_t); export;
procedure ReportSites(const sFile, sDescr : string; const fTestFileExists : boolean;
                       const OTable : TTable; const iSCount : integer;
                       const  SArr : Array_t;
                       const CRes : ControlResPointer_T;
                       const sTerminologyType : string);  export;
procedure ReportSiteSumirr(const sFile : string);
procedure DebugReportFArr;

procedure ReportProposedReserve(const sFile : string);
procedure ReportHotspotsFeatures(const sFile : string);
procedure ReportAverageAvailableFeatureArea(const sFile : string);
procedure ReportMeasure2Summary(const sFilename : string);
procedure ReportMeasure2SummaryToListBox(TheListBox : TListBox);

procedure ConvertAutosaveLog;
function GenerateCFIMAX : extended;
function GenerateUntrimmedCFIMAX : extended;
// call this after writing the autosave.log file at the end of a minset run
// It will create the file SelectionOrder.csv in the working directory
// that the Validate Macro (version 10) uses to replicate the selection order
// in cases where iterations to validate is used
//
// so, only call this if :
//   1) validate is on
//   2) iterations to validate is used

implementation

uses
    {Em_newu1, }Contribu, SysUtils,
    {Comb_run,}
    Controls, Dialogs, Forms,
    Opt1, IniFiles, Control,
    spatio, partl_ed,
    destruct;

var
   SiteKeyArray : array_t;
   fSiteKeyArrayCreated : boolean;
   iSiteKeyArraySize : integer;


{here are the  reporting functions   }
{----------------------------------------------------------}

function GetOutFileName(const sFile : string) : string;
begin
     Result := ExtractFilePath(sFile) + 'SelectionOrder.csv';
end;

procedure LoadSiteKeyArray(const sFile : string);
var
   InFile : TextFile;
   iSiteKey, iPos : integer;
   sLine, sTmp : string;
begin
     //
     iSiteKeyArraySize := 0;
     if not fSiteKeyArrayCreated then
     begin
          SiteKeyArray := Array_t.Create;
          SiteKeyArray.init(SizeOf(integer),10000);
     end;

     assignfile(InFile,sFile);
     reset(InFile);

     readln(InFile);
     readln(InFile);

     repeat
           readln(InFile,sLine);
           if (sLine <> '') then
           begin
                // extract column 2 from this line
                iPos := Pos(',',sLine);
                sTmp := Copy(sLine,iPos + 1,Length(sLine)-iPos);
                iPos := Pos(',',sTmp);
                sTmp := Copy(sTmp,1,iPos - 1);
                iSiteKey := StrToInt(sTmp);
                Inc(iSiteKeyArraySize);
                if (iSiteKeyArraySize > SiteKeyArray.lMaxSize) then
                   SiteKeyArray.resize(SiteKeyArray.lMaxSize + 10000);
                SiteKeyArray.setValue(iSiteKeyArraySize,@iSiteKey);
           end;

     until EOF(InFile);

     closefile(InFile);

     if (iSiteKeyArraySize <> SiteKeyArray.lMaxSize)
     and (iSiteKeyArraySize > 0) then
         SiteKeyArray.resize(iSiteKeyArraySize);
end;

procedure ConvertFile(const sFile : string);
var
   InFile, OutFile : TextFile;
   sOutFile, sLine : string;
   iSiteKey : integer;
   OrdinalSiteArr : Array_t;
begin
     assignfile(InFile,sFile);
     reset(InFile);

     repeat
           readln(InFile,sLine);

     until (sLine = '***-----------separator-----------*** AvailKey End');

     sOutFile := GetOutFileName(sFile);
     assignfile(OutFile,sOutFile);
     rewrite(OutFile);
     writeln(OutFile,'SiteIndex');

     LoadSiteKeyArray(ExtractFilePath(sFile) + '0\sites0.csv');
     OrdinalSiteArr := SortFeatArray(SiteKeyArray);

     repeat
           readln(InFile,sLine);
           if (sLine <> '***-----------separator-----------*** NegotKey End') then
           begin
                // do a lookup to convert the site key to a site index
                iSiteKey := StrToInt(sLine);
                writeln(OutFile,IntToStr(findFeatMatch(OrdinalSiteArr,iSiteKey)));
           end;

     until (sLine = '***-----------separator-----------*** NegotKey End');

     OrdinalSiteArr.Destroy;

     closefile(InFile);
     closefile(OutFile);
end;

procedure ConvertAutosaveLog;
var
   iCount : integer;
begin
     try
        Screen.Cursor := crHourglass;

        //fSiteKeyArrayCreated := False;

        //ConvertFile(ControlRes^.sWorkingDirectory + '\autosave.log');

        //if fSiteKeyArrayCreated then
        //   SiteKeyArray.Destroy;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception performing file conversion',mtError,[mbOk],0);
     end;
end;


procedure ReportAverageAvailableFeatureArea(const sFile : string);
var
   OutFile : TextFile;
   pSite : sitepointer;
   Value : ValueFile_T;
   iCount, iFeatures : integer;
   FeatureFrequency, FeatureTotal, FeatureMinimum, FeatureMaximum : Array_t;
   iFrequency : integer;
   rTotal, rAverage, rMinimum, rMaximum : extended;
begin
     // create and init arrays
     FeatureFrequency := Array_t.Create;
     FeatureTotal := Array_t.Create;
     FeatureMinimum := Array_t.Create;
     FeatureMaximum := Array_t.Create;
     FeatureFrequency.init(SizeOf(integer),iFeatureCount);
     FeatureTotal.init(SizeOf(extended),iFeatureCount);
     FeatureMinimum.init(SizeOf(extended),iFeatureCount);
     FeatureMaximum.init(SizeOf(extended),iFeatureCount);
     iFrequency := 0;
     rTotal := 0;
     rMinimum := 10000;
     rMaximum := 0;
     for iCount := 1 to iFeatureCount do
     begin
          FeatureFrequency.setValue(iCount,@iFrequency);
          FeatureTotal.setValue(iCount,@rTotal);
          FeatureMinimum.setValue(iCount,@rMinimum);
          FeatureMaximum.setValue(iCount,@rMaximum);
     end;

     new(pSite);

     // traverse sites adding up values
     for iCount := 1 to iSiteCount do
	begin
          SiteArr.rtnValue(iCount,pSite);
          if ((pSite^.status = Av) or (pSite^.status = Fl))
          and (pSite^.richness > 0) then
              for iFeatures := 1 to pSite^.richness do
              begin
                   FeatureAmount.rtnValue(pSite^.iOffSet + iFeatures,@Value);
                   if (Value.rAmount > 0) then
                   begin
                        FeatureFrequency.rtnValue(Value.iFeatKey,@iFrequency);
                        Inc(iFrequency);
                        FeatureFrequency.setValue(Value.iFeatKey,@iFrequency);
                        FeatureTotal.rtnValue(Value.iFeatKey,@rTotal);
                        rTotal := rTotal + Value.rAmount;
                        FeatureTotal.setValue(Value.iFeatKey,@rTotal);
                        FeatureMinimum.rtnValue(Value.iFeatKey,@rMinimum);
                        if (Value.rAmount < rMinimum) then
                        begin
                             rMinimum := Value.rAmount;
                             FeatureMinimum.setValue(Value.iFeatKey,@rMinimum);
                        end;
                        FeatureMaximum.rtnValue(Value.iFeatKey,@rMaximum);
                        if (Value.rAmount > rMaximum) then
                        begin
                             rMaximum := Value.rAmount;
                             FeatureMaximum.setValue(Value.iFeatKey,@rMaximum);
                        end;
                   end;
              end;
     end;

     // write report file
     assignfile(OutFile,sFile);
     rewrite(OutFile);
     writeln(OutFile,'FeatKey,FeatFrequency,FeatTotal,NonZeroFeatAverage,FeatMinimum,FeatMaximum');
     for iCount := 1 to iFeatureCount do
     begin
          FeatureFrequency.rtnValue(iCount,@iFrequency);
          FeatureTotal.rtnValue(iCount,@rTotal);
          FeatureMinimum.rtnValue(iCount,@rMinimum);
          FeatureMaximum.rtnValue(iCount,@rMaximum);
          if (iFrequency = 0) then
             rAverage := 0
          else
              rAverage := rTotal/iFrequency;
          writeln(OutFile,IntToStr(iCount) + ',' +
                          IntToStr(iFrequency) + ',' +
                          FloatToStr(rTotal) + ',' +
                          FloatToStr(rAverage) + ',' +
                          FloatToStr(rMinimum) + ',' +
                          FloatToStr(rMaximum)
                  );
     end;
     closefile(OutFile);

     // destroy arrays
     FeatureFrequency.Destroy;
     FeatureTotal.Destroy;

     dispose(pSite);
end;

procedure ReportSiteSumirr(const sFile : string);
var
   iCount : integer;
   pSite : sitepointer;
   OutFile : TextFile;
begin
     assignfile(OutFile,sFile);
     rewrite(OutFile);
     writeln(OutFile,'SiteKey,Status,Sumirr');

     new(pSite);
     for iCount := 1 to iSiteCount do
     begin
          SiteArr.rtnValue(iCount,pSite);
          writeln(OutFile,IntToStr(pSite^.iKey) + ',' + Status2Str(pSite^.status) + ',' + FloatToStr(pSite^.rSummedIrr));
     end;
     dispose(pSite);

     closefile(OutFile);
end;

procedure ReportProposedReserve(const sFile : string);
var
   iCount : integer;
   pFeat : featureoccurrencepointer;
   DebugFile : TextFile;
   rReportTarget : extended;
begin
     try
        new(pFeat);
        assignfile(DebugFile,sFile);
        rewrite(DebugFile);
        writeln(DebugFile,'FeatureKey,ProposedReserve,ReportTarget');

        for iCount := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iCount,pFeat);
             ReportTarget.rtnValue(iCount,@rReportTarget);
             writeln(DebugFile,IntToStr(iCount) + ',' +
                               FloatToStr(pFeat^.rDeferredArea) + ',' +
                               FloatToStr(rReportTarget));
        end;

        dispose(pFeat);
        closefile(DebugFile);

     except

     end;
end;

procedure ReportHotspotsFeatures(const sFile : string);
var
   iCount : integer;
   pFeat : featureoccurrencepointer;
   DebugFile : TextFile;
   rPCOrigEff, rDestructArea : extended;
begin
     try
        new(pFeat);
        assignfile(DebugFile,sFile);
        rewrite(DebugFile);
        writeln(DebugFile,'FeatureKey,ProposedReserve,DestructArea,current tgt,% init achievable tgt');

        for iCount := 1 to iFeatureCount do
        begin
             if ControlRes^.fDestructObjectsCreated then
                try
                   DestructArea.rtnValue(iCount,@rDestructArea);
                except
                      rDestructArea := 0;
                end
             else
                 rDestructArea := 0;

             FeatArr.rtnValue(iCount,pFeat);
             if (pFeat^.rInitialAvailableTarget > 0) then
                rPCOrigEff := pFeat^.rDeferredArea / pFeat^.rInitialAvailableTarget * 100
             else
                 rPCOrigEff := 100;
             writeln(DebugFile,IntToStr(iCount) + ',' +
                               FloatToStr(pFeat^.rDeferredArea) + ',' +
                               FloatToStr(rDestructArea) + ',' +
                               FloatToStr(pFeat^.targetarea) + ',' +
                               FloatToStr(rPCOrigEff));
        end;

        dispose(pFeat);
        closefile(DebugFile);

     except

     end;
end;

procedure DebugReportFArr;
var
   DebugFile : Text;
   iCount, iFeatureKey : integer;
   aFeat : featureoccurrence;
begin
     {debug routing to dump info from feature array to a csv file}
     assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\dbg_farr.csv');
     rewrite(DebugFile);
     writeln(DebugFile,'FName,FCode,total area,original available,target,key from FeatCodes');

     for iCount := 1 to iFeatureCount do
     begin
          FeatCodes.rtnValue(iCount,@iFeatureKey);
          FeatArr.rtnValue(iCount,@aFeat);
          writeln(DebugFile,aFeat.sID + ',' + IntToStr(aFeat.code) + ',' + FloatToStr(aFeat.totalarea) +
                  ',' + FloatToStr(aFeat.rInitialAvailable) + ',' + FloatToStr(aFeat.targetarea) +
                  ',' + IntToStr(iFeatureKey));
     end;

     closefile(DebugFile);
end;

function CustFileExists(const sFile,sType : string) : boolean;
var
   iFileHandle, iCursor : integer;

   fResult : boolean;
   PFileName : PChar;

   {allows user to choose whether or not to overwrite an existing file
    (except one that is in use already by another program)}

begin
     Result := FileExists(sFile);

     if Result then
     begin
          iFileHandle := FileOpen(sFile,fmOpenWrite);
          if (iFileHandle > 0) then
          begin
               FileClose(iFileHandle);

               Screen.Cursor := crDefault;

               if (mrYes =
                   MessageDlg(sType + ' Report, File ' + sFile + ' exists.  Overwrite?',
                              mtConfirmation,[mbYes,mbNo],0)) then
                  Result := False
               else
                   MessageDlg(sType + ' Report Aborted',mtInformation,[mbOk],0);
          end
          else
          begin
               Screen.Cursor := crDefault;
               MessageDlg('File ' + sFile + ' is in use.' + Chr(13) + Chr(10) +
                          'Cannot create ' + sType + ' report.',
                          mtWarning,[mbOk],0);
          end;
     end;

     if not Result then
     begin
          {$IFDEF VER90}
          //PFileName := StrAlloc(Length(sFile) + 1);
          //StrPCopy(PFileName,sFile);
          //fResult := DeleteFile(PFileName);
          fResult := DeleteFile(sFile);
          //StrDispose(PFileName);
          {$ELSE}
          fResult := DeleteFile(sFile);
          {$ENDIF}
     end;
end;

function Bool2String(const fValue : boolean) : string;
begin
     if (fValue = True) then
        Result := 'True'
     else
         Result := 'False';
end;

procedure ReportMeasure2SummaryToListBox(TheListBox : TListBox);
var
   iCount : integer;
   rBIOIDX, rUntrimmedBIOIDX, rTGTGAP, rUntrimmedTGTGAP,
   rTotalBIOIDX, rTotalUntrimmedBIOIDX, rTotalBIOIDX_, rTotalUntrimmedBIOIDX_,
   rCFIMAX, rUntrimmedCFIMax, rCurrentTargetArea : extended;
   pFeat : featureoccurrencepointer;
   DebugFile : TextFile;
begin
     rTotalBIOIDX := 0;
     rTotalUntrimmedBIOIDX := 0;
     new(pFeat);

     rCFIMAX := GenerateCFIMAX;
     rUntrimmedCFIMax := GenerateUntrimmedCFIMAX;

     assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\current_debug.csv');
     rewrite(DebugFile);
     //writeln(DebugFile,'FeatKey,UntrimTGTGAP,UntrimCFI,rCutOff,rDeferredArea,reservedarea,TGTGAP,CFI,targetarea,rFV,VW[rFV]');
     writeln(DebugFile,'FeatKey,Untrim T,Untrim BIOIDX,untrimmed target,proposed reserve,initial reserve,trimmed T,trimmed BIOIDX,trimmed target - (initial + proposed reserve),V');

     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,pFeat);

          // T is target gap (TGTGAP)   T = (target - reserved) / target  where target is original target and reserved is initial + proposed reserve
          // V is floating point vulnerability


          // calculate TGTGAP and BIOIDX
          // UN-TRIMMED
          if (pFeat^.rCutOff = 0) then
             rUntrimmedTGTGAP := 0
          else
          begin
               if (pFeat^.rCutOff > 0) then
                  rUntrimmedTGTGAP := ((pFeat^.rCutOff - pFeat^.rDeferredArea - pFeat^.reservedarea) / pFeat^.rCutOff)
               else
                   rUntrimmedTGTGAP := 0;
          end;

          if (rUntrimmedTGTGAP < 0) then
             rUntrimmedTGTGAP := 0;

          if ((1 - rUnTrimmedTGTGAP) = 1) then
             rUntrimmedBIOIDX := (1 - rUntrimmedTGTGAP)
          else
              rUntrimmedBIOIDX := (1 - rUntrimmedTGTGAP) * (1 - pFeat^.rFloatVulnerability);

          rCurrentTargetArea := pFeat^.targetarea;
          if (rCurrentTargetArea < 0) then
             rCurrentTargetArea := 0;

          // TRIMMED
          if ((rCurrentTargetArea + pFeat^.rDeferredArea + pFeat^.reservedarea) > 0) then
             rTGTGAP := (rCurrentTargetArea / (rCurrentTargetArea + pFeat^.rDeferredArea + pFeat^.reservedarea))
          else
              rTGTGAP := 0;

          if (rTGTGAP < 0) then
             rTGTGAP := 0;

          if ((1 - rTGTGAP) = 1) then
             rBIOIDX := (1 - rTGTGAP)
          else
              rBIOIDX := (1 - rTGTGAP) * (1 - pFeat^.rFloatVulnerability);

          // accumulate totals for all features
          rTotalBIOIDX := rTotalBIOIDX + rBIOIDX;
          rTotalUntrimmedBIOIDX := rTotalUntrimmedBIOIDX + rUntrimmedBIOIDX;

             writeln(DebugFile,IntToStr(iCount) + ',' + FloatToStr(rUntrimmedTGTGAP) + ',' + FloatToStr(rUntrimmedBIOIDX) + ',' +
                               FloatToStr(pFeat^.rCutOff) + ',' + FloatToStr(pFeat^.rDeferredArea) + ',' + FloatToStr(pFeat^.reservedarea) + ',' +
                               FloatToStr(rTGTGAP) + ',' + FloatToStr(rBIOIDX) + ',' + FloatToStr(rCurrentTargetArea) + ',' +
                               FloatToStr(pFeat^.rFloatVulnerability));
     end;

     if (rCFIMAX > 0) then
        rTotalBIOIDX_ := 100 - (rTotalBIOIDX/rCFIMAX*100)
     else
         rTotalBIOIDX_ := 0;

     if (rUntrimmedCFIMax > 0) then
        rTotalUntrimmedBIOIDX_ := 100 - (rTotalUntrimmedBIOIDX/rUntrimmedCFIMax*100)
     else
         rTotalUntrimmedBIOIDX_ := 0;

     TheListBox.Items.Clear;
     TheListBox.Items.Add('BIOIDX = ' + FloatToStr(rTotalBIOIDX));
     TheListBox.Items.Add('BIOIDX max = ' + FloatToStr(rCFIMAX));
     TheListBox.Items.Add('Untrimmed BIOIDX = ' + FloatToStr(rTotalUntrimmedBIOIDX));
     TheListBox.Items.Add('Untrimmed BIOIDX max = ' + FloatToStr(rUntrimmedCFIMax));
     TheListBox.Items.Add('CFI trimmed = ' + FloatToStr(rTotalBIOIDX_));
     TheListBox.Items.Add('CFI Untrimmed = ' + FloatToStr(rTotalUntrimmedBIOIDX_));

     closefile(DebugFile);

     dispose(pFeat);
end;

function GenerateCFIMAX : extended;
var
   iCount : integer;
   rTGTGAP, rCurrentTargetArea : extended;
   pFeat : featureoccurrencepointer;
   DebugFile : TextFile;
begin
     new(pFeat);

     Result := 0;

     assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\debug_trimmed_CFIMAX.csv');
     rewrite(DebugFile);
     writeln(DebugFile,'FEATKEY,MAX trimmed T,V,current target area');

     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,pFeat);

          rCurrentTargetArea := pFeat^.targetarea;
          if (rCurrentTargetArea < 0) then
             rCurrentTargetArea := 0;
             
          if ((rCurrentTargetArea + pFeat^.rDeferredArea + pFeat^.reservedarea) > 0) then
             rTGTGAP := (rCurrentTargetArea / (rCurrentTargetArea + pFeat^.rDeferredArea + pFeat^.reservedarea))
          else
              rTGTGAP := 0;

          if (rTGTGAP < 0) then
             rTGTGAP := 0;

          if ((1 - rTGTGAP) = 1) then
             Result := Result + (1 - rTGTGAP)
          else
              Result := Result + ((1 - rTGTGAP) * (1 - pFeat^.rFloatVulnerability));

          writeln(DebugFile,IntToStr(pFeat^.code) + ',' + FloatToStr(rTGTGAP) + ',' + FloatToStr(pFeat^.rFloatVulnerability) + ',' + FloatToStr(rCurrentTargetArea));
     end;

     closefile(DebugFile);

     dispose(pFeat);
end;

function GenerateUntrimmedCFIMAX : extended;
var
   iCount, iIndex : integer;
   rUntrimmedTGTGAP : extended;
   pFeat : featureoccurrencepointer;
   DebugFile : TextFile;
begin
     new(pFeat);

     Result := 0;

     assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\debug_untrimmed_CFIMAX.csv');
     rewrite(DebugFile);
     writeln(DebugFile,'FEATKEY,MAX untrimmed T,V,totalarea,untrimmed target');

     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,pFeat);

          if (pFeat^.rCutOff > 0) then
             rUntrimmedTGTGAP := ((pFeat^.rCutOff - pFeat^.totalarea) / pFeat^.rCutOff)
          else
              rUntrimmedTGTGAP := 0;

          if (rUntrimmedTGTGAP < 0) then
             rUntrimmedTGTGAP := 0;

          if ((1 - rUntrimmedTGTGAP) = 1) then
             Result := Result + (1 - rUntrimmedTGTGAP)
          else
              Result := Result + ((1 - rUntrimmedTGTGAP) * (1 - pFeat^.rFloatVulnerability));

          writeln(DebugFile,IntToStr(pFeat^.code) + ',' + FloatToStr(rUntrimmedTGTGAP) + ',' + FloatToStr(pFeat^.rFloatVulnerability) + ',' +
                            FloatToStr(pFeat^.totalarea) + ',' + FloatToStr(pFeat^.rCutOff));
     end;

     closefile(DebugFile);

     dispose(pFeat);
end;



procedure ReportMeasure2Summary(const sFilename : string);
var
   ReportFile : TextFile;
   iCount, iIndex : integer;
   rBIOIDX, rUntrimmedBIOIDX, rTGTGAP, rUntrimmedTGTGAP,
   rTotalBIOIDX, rTotalUntrimmedBIOIDX, rTotalBIOIDX_, rTotalUntrimmedBIOIDX_, rCFIMAX, rUntrimmedCFIMax : extended;
   pFeat : featureoccurrencepointer;
   fDebug : boolean;
   DebugFile : TextFile;
begin
     fDebug := True;
     if fDebug then
     begin
          assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\ReportMeasure2Debug.csv');
          rewrite(DebugFile);
          writeln(DebugFile,'FeatKey,UntrimTGTGAP,UntrimCFI,rCutOff,rDeferredArea,reservedarea,TGTGAP,CFI,targetarea,rFV,VW[rFV]');
     end;

     assignfile(ReportFile,sFilename);
     rewrite(ReportFile);
     writeln(ReportFile,'BIOIDX Summary');
     writeln(ReportFile,'');

     rTotalBIOIDX := 0;
     rTotalUntrimmedBIOIDX := 0;
     new(pFeat);

     rCFIMAX := GenerateCFIMAX;
     rUntrimmedCFIMax := GenerateUntrimmedCFIMAX;

     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,pFeat);

          // calculate TGTGAP and BIOIDX
          // UN-TRIMMED
          if (pFeat^.rCutOff = 0) then
             rUntrimmedTGTGAP := 0
          else
          begin
               if (pFeat^.rCutOff > 0) then
                  rUntrimmedTGTGAP := 1 - ((pFeat^.rCutOff - pFeat^.rDeferredArea - pFeat^.reservedarea) / pFeat^.rCutOff)
               else
                   rUntrimmedTGTGAP := 0;
               if (rUntrimmedTGTGAP > 1) then
                  rUntrimmedTGTGAP := 1;
               if (rUntrimmedTGTGAP < 0) then
                  rUntrimmedTGTGAP := 0;
          end;
          iIndex := round(pFeat^.rFloatVulnerability);
          if (iIndex < 1) then
             iIndex := 1;
          if (iIndex > 5) then
             iIndex := 5;
          rUntrimmedBIOIDX := rUntrimmedTGTGAP * ControlRes^.VulnerabilityWeightings[iIndex];
          // TRIMMED
          if (pFeat^.rInitialTrimmedTarget = 0) then
             rTGTGAP := 0
          else
          begin
               if (pFeat^.targetarea > 0) then
                  rTGTGAP := 1 - (pFeat^.targetarea / (pFeat^.targetarea + pFeat^.rDeferredArea + pFeat^.reservedarea))
               else
                   rTGTGAP := 0;
               if (rTGTGAP > 1) then
                  rTGTGAP := 1;
               if (rTGTGAP < 0) then
                  rTGTGAP := 0;
          end;
          rBIOIDX := rTGTGAP * ControlRes^.VulnerabilityWeightings[iIndex];
          // accumulate totals for all features
          rTotalBIOIDX := rTotalBIOIDX + rBIOIDX;
          rTotalUntrimmedBIOIDX := rTotalUntrimmedBIOIDX + rUntrimmedBIOIDX;
          if fDebug then
             writeln(DebugFile,IntToStr(iCount) + ',' + FloatToStr(rUntrimmedTGTGAP) + ',' + FloatToStr(rUntrimmedBIOIDX) + ',' +
                               FloatToStr(pFeat^.rCutOff) + ',' + FloatToStr(pFeat^.rDeferredArea) + ',' + FloatToStr(pFeat^.reservedarea) + ',' +
                               FloatToStr(rTGTGAP) + ',' + FloatToStr(rBIOIDX) + ',' + FloatToStr(pFeat^.targetarea) + ',' +
                               FloatToStr(pFeat^.rFloatVulnerability) + ',' + FloatToStr(ControlRes^.VulnerabilityWeightings[iIndex]));
     end;

     if (rCFIMAX > 0) then
        rTotalBIOIDX_ := 100 - (rTotalBIOIDX/rCFIMAX*100)
     else
         rTotalBIOIDX_ := 0;

     if (rUntrimmedCFIMax > 0) then
        rTotalUntrimmedBIOIDX_ := 100 - (rTotalUntrimmedBIOIDX/rUntrimmedCFIMax*100)
     else
         rTotalUntrimmedBIOIDX_ := 0;

     writeln(ReportFile,'BIOIDX = ' + FloatToStr(rTotalBIOIDX));
     writeln(ReportFile,'Untrimmed BIOIDX = ' + FloatToStr(rTotalUntrimmedBIOIDX));
     writeln(ReportFile,'Normalised BIOIDX = ' + FloatToStr(rTotalBIOIDX_));
     writeln(ReportFile,'Normalised Untrimmed BIOIDX = ' + FloatToStr(rTotalUntrimmedBIOIDX_));
     closefile(ReportFile);

     if fDebug then
        closefile(DebugFile);

     dispose(pFeat);
end;

procedure ReportFeatures(const sFile, sDescr : string; const fTestFileExists : boolean;
                        const fUseITarget : boolean; const FArr : Array_t;
                        const  iFCount : integer;
                        const rPC : extended;
                        const sTerminologyType : string);
var
   RptFile : Text;

   iCount, iCount2, iIndex : integer;
   pFeat : featureoccurrencepointer;

   rContribArea, rPCTrim, rPCOrigEff, rBIOIDX, rTGTGAP : extended;
   fRun : boolean;
   sFlatTarget,sPCFlat,sPCOrig,sCutOff,
   sTrimmedTarget,sPCTrim,sInUse,
   sOriginalEffectiveTarget, sCurrentEffectiveTarget, sPCOrigEff : string;

   PFileName : PChar;

   AIni : TIniFile;

{this report is for detailing target areas for features.
 default fields are;
      1 = Name
      2 = Code
      3 = Reserved
      4 = Orig Av.
      5 = Total
      6 = ITARGET
      7 = Trimmed ITARGET
      8 = PCTARGET
      9 = Orig. Effective Target
      10 = Deferred
      11 = Excluded
      12 = Current Available
      13 = Current Effective Target
      14 = % ITARGET Met
      15 = % Trimmed ITARGET Met
      16 = % PCTARGET Met
      17 = % Orig. Effective Target Met
      18 = Feature In Use
      19 = Mandatory
      20 = Negotiated
      21 = Partial
      22 = Ordinal Class
      23 = Vulnerability
}

   function rtnValueOfVariable(const sVariable : string) : string;
   begin
        try
           {return the string value of the variable specified by sVariable}
           Result := '';
           iIndex := round(pFeat^.rFloatVulnerability);
           if (iIndex < 1) then
              iIndex := 1;
           if (iIndex > 5) then
              iIndex := 5;
           if ('NAME' = sVariable) then
              Result := pFeat^.sID
           else
           if ('R1' = sVariable) then
              Result := FloatToStr(pFeat^.rR1)
           else
           if ('R2' = sVariable) then
              Result := FloatToStr(pFeat^.rR2)
           else
           if ('R3' = sVariable) then
              Result := FloatToStr(pFeat^.rR3)
           else
           if ('R4' = sVariable) then
              Result := FloatToStr(pFeat^.rR4)
           else
           if ('R5' = sVariable) then
              Result := FloatToStr(pFeat^.rR5)
           else
           if ('KEY' = sVariable) then
              Result := IntToStr(pFeat^.code)
           else
           if ('CURRAVAIL' = sVariable) then
              Result := FloatToStr(pFeat^.rCurrentSumArea)
           else
           if ('CURREFFTARG' = sVariable) then
              Result := sCurrentEffectiveTarget
           else
           if ('RESERVED' = sVariable) then
              Result := FloatToStr(pFeat^.reservedarea)
           else
           if ('ORIGAV' = sVariable) then
              Result := FloatToStr(pFeat^.rInitialAvailable)
           else
           if ('EXTANT' = sVariable) then
           begin
                if ControlRes^.fExtantLoaded then
                   Result := FloatToStr(pFeat^.rExtantArea)
                else
                    Result := '';
           end
           else
           if ('ORIGEFFTARG' = sVariable) then
              Result := sOriginalEffectiveTarget
           else
           if ('ORD' = sVariable) then
              Result := IntToStr(pFeat^.iOrdinalClass)
           else
           if ('TOTAL' = sVariable) then
              Result := FloatToStr(pFeat^.totalarea)
           else
           if ('TRIMMEDITARG' = sVariable) then
              Result := sTrimmedTarget
           else
           if ('INUSE' = sVariable) then
              Result := sInUse
           else
           if ('ITARGET' = sVariable) then
              Result := sCutOff
           else
           if ('PAR' = sVariable) then
              Result := FloatToStr(pFeat^.rPartial)
           else
           if ('PCTARGET' = sVariable) then
              Result := sFlatTarget
           else
           if ('PROPOSEDRES' = sVariable) then
              Result := FloatToStr(pFeat^.rDeferredArea)
           else
           if ('EXCLUDED' = sVariable) then
              Result := FloatToStr(pFeat^.rExcluded)
           else
           if ('%ITARGMET'  = sVariable) then
              Result := sPCOrig
           else
           if ('%TRIMITMET' = sVariable) then
              Result := sPCTrim
           else
           if ('%PCTARGMET' = sVariable) then
              Result := sPCFlat
           else
           if ('%OETMET' = sVariable) then
              Result := sPCOrigEff
           else
           if ('VULN' = sVariable) then
              Result := FloatToStr(pFeat^.rVulnerability);
           if ('TGTGAP2' = sVariable) then
           begin
                if (pFeat^.rInitialTrimmedTarget = 0) then
                   Result := '0'
                else
                begin
                     if (pFeat^.targetarea > 0) then
                        rTGTGAP := pFeat^.targetarea / (pFeat^.targetarea + pFeat^.rDeferredArea + pFeat^.reservedarea)
                     else
                         rTGTGAP := 0;
                     if (rTGTGAP > 1) then
                        rTGTGAP := 1;
                     if (rTGTGAP < 0) then
                        rTGTGAP := 0;
                     Result := FloatToStr(1 - rTGTGAP);
                end;
           end;
           if ('BIOIDX2' = sVariable) then
           begin
                if (pFeat^.rInitialTrimmedTarget = 0) then
                   Result := '0'
                else
                begin
                     if (pFeat^.targetarea > 0) then
                        rTGTGAP := pFeat^.targetarea / (pFeat^.targetarea + pFeat^.rDeferredArea + pFeat^.reservedarea)
                     else
                         rTGTGAP := 0;
                     if (rTGTGAP > 1) then
                        rTGTGAP := 1;
                     if (rTGTGAP < 0) then
                        rTGTGAP := 0;
                     if (rTGTGAP = 0) then
                        rBIOIDX := 1
                     else
                     begin
                          rBIOIDX := (1 - rTGTGAP) * (1 - ControlRes^.VulnerabilityWeightings[iIndex]);
                     end;
                     Result := FloatToStr(rBIOIDX);
                end;
           end;
           if ('TGTGAP' = sVariable) then
           begin
                if (pFeat^.rInitialTrimmedTarget = 0) then
                   Result := '0'
                else
                begin
                     if (pFeat^.targetarea > 0) then
                        rTGTGAP := pFeat^.targetarea / (pFeat^.targetarea + pFeat^.rDeferredArea + pFeat^.reservedarea)
                     else
                         rTGTGAP := 0;
                     if (rTGTGAP > 1) then
                        rTGTGAP := 1;
                     if (rTGTGAP < 0) then
                        rTGTGAP := 0;
                     Result := FloatToStr(rTGTGAP);
                end;
           end;
           if ('BIOIDX' = sVariable) then
           begin
                if (pFeat^.rInitialTrimmedTarget = 0) then
                   Result := '0'
                else
                begin
                     if (pFeat^.targetarea > 0) then
                        rTGTGAP := pFeat^.targetarea / (pFeat^.targetarea + pFeat^.rDeferredArea + pFeat^.reservedarea)
                     else
                         rTGTGAP := 0;
                     if (rTGTGAP > 1) then
                        rTGTGAP := 1;
                     if (rTGTGAP < 0) then
                        rTGTGAP := 0;
                     rBIOIDX := rTGTGAP * ControlRes^.VulnerabilityWeightings[iIndex];
                     Result := FloatToStr(rBIOIDX);
                end;
           end;
           if ('TGTGAP3' = sVariable) then
           begin
                if (pFeat^.rCutOff = 0) then
                   Result := '0'
                else
                begin
                     if (pFeat^.rCutOff > 0) then
                        rTGTGAP := (pFeat^.rCutOff - pFeat^.rDeferredArea - pFeat^.reservedarea) / pFeat^.rCutOff
                     else
                         rTGTGAP := 0;
                     if (rTGTGAP > 1) then
                        rTGTGAP := 1;
                     if (rTGTGAP < 0) then
                        rTGTGAP := 0;
                     Result := FloatToStr(rTGTGAP);
                end;
           end;
           if ('BIOIDX3' = sVariable) then
           begin
                if (pFeat^.rCutOff = 0) then
                   Result := '0'
                else
                begin
                     if (pFeat^.rCutOff > 0) then
                        rTGTGAP := (pFeat^.rCutOff - pFeat^.rDeferredArea - pFeat^.reservedarea) / pFeat^.rCutOff
                     else
                         rTGTGAP := 0;
                     if (rTGTGAP > 1) then
                        rTGTGAP := 1;
                     if (rTGTGAP < 0) then
                        rTGTGAP := 0;
                     rBIOIDX := rTGTGAP * ControlRes^.VulnerabilityWeightings[iIndex];
                     Result := FloatToStr(rBIOIDX);
                end;
           end;
           if ('FVULN' = sVariable) then
           begin
                Result := FloatToStr(ControlRes^.VulnerabilityWeightings[iIndex]);
           end;
           if ('ONEminusFVULN' = sVariable) then
           begin
                Result := FloatToStr(1 - ControlRes^.VulnerabilityWeightings[iIndex]);
           end;
           if (sVariable = 'EXCLUDE TRIM') then
           begin
                if (pFeat^.rTrimmedArea > 0) then
                   Result := 'YES'
                else
                    Result := '';
           end;
           if (sVariable = 'EXCLUDE TRIM AMOUNT') then
              Result := FloatToStr(pFeat^.rTrimmedArea);
           if (sVariable = 'EXCLUDE TRIM %') then
           begin
                if ((pFeat^.rInitialTrimmedTarget) > 0) then
                   Result := FloatToStr(pFeat^.rTrimmedArea/(pFeat^.rInitialTrimmedTarget)*100)
                else
                    Result := '0';
           end;

        except
              Result := '0';
              //Screen.Cursor := crDefault;
              //MessageDlg('Exception in rtnValueOfVariable ' + sVariable,
              //           mtError,[mbOk],0);
              //Application.Terminate;
              //Exit;
        end;
   end;

   procedure AddItems(const sField,sFieldValue : string);
   begin
        ControlForm.RptFieldBox.Items.Add(sField);
        ControlForm.RptFieldValueBox.Items.Add(sFieldValue);
   end;

   procedure PopulateDefaultFields;
   begin
        {populate listbox objects with default field order and names}

        AddItems('NAME','Feature Name');
        AddItems('KEY','Feature Key');
        AddItems('RESERVED','Initial Reserved');
        AddItems('ORIGAV','Initial Av.');
        AddItems('EXTANT','Extant');
        AddItems('TOTAL','Total in Database');
        AddItems('ITARGET','Original Target');
        AddItems('TRIMMEDITARG','Initial Achievable Target');
        AddItems('PCTARGET','Original Target (%)');
        AddItems('ORIGEFFTARG','Initial Available Target');
        AddItems('PROPOSEDRES','Proposed Reserved');
        AddItems('EXCLUDED','Excluded');
        AddItems('CURRAVAIL','Available');
        AddItems('CURREFFTARG','Available Target');
        AddItems('%ITARGMET','% Original Target Met');
        AddItems('%TRIMITMET','% Initial Achievable Target Met');
        AddItems('%PCTARGMET','% Original Target (%) Met');
        AddItems('%OETMET','% Initial Available Target Met');
        AddItems('INUSE','Feature In Use');
        AddItems('R1',ControlRes^.sR1Label);
        if ControlRes^.fR2Visible then
           AddItems('R2',ControlRes^.sR2Label);
        if ControlRes^.fR3Visible then
           AddItems('R3',ControlRes^.sR3Label);
        if ControlRes^.fR4Visible then
           AddItems('R4',ControlRes^.sR4Label);
        if ControlRes^.fR5Visible then
           AddItems('R5',ControlRes^.sR5Label);
        AddItems('PAR','Partial Selection');
        AddItems('VULN','Vulnerability');
        AddItems('ORD','Ordinal Class');
        AddItems('TGTGAP','Target Gap');
        AddItems('FVULN','Floating Point Vulnerability');
        AddItems('ONEminusFVULN','One Minus Floating Point Vulnerability');
        AddItems('BIOIDX','C-Plan Feature Index (CFI)');
        AddItems('TGTGAP2','One Minus Target Gap');
        AddItems('BIOIDX2','"One Minus" CFI');
        AddItems('TGTGAP3','Untrimmed Target Gap');
        AddItems('BIOIDX3','"Untrimmed Target" CFI');
        AddItems('EXCLUDE TRIM','Target Trimmed for exclusions');
        AddItems('EXCLUDE TRIM AMOUNT','Target Trimmed for exclusions (amount)');
        AddItems('EXCLUDE TRIM %','Target Trimmed for exclusions (%)');
       {
        CRA field definition :

        AddItems('NAME','Feature Name');
        AddItems('KEY','Feature Key');
        AddItems('RESERVED','Reserved');
        AddItems('ORIGAV','Initial Av.');
        AddItems('TOTAL','Total in Database');
        AddItems('ITARGET','JANIS Target');
        AddItems('TRIMMEDITARG','Crown Target');
        AddItems('ORIGEFFTARG','Initial Available Crown Target');
        AddItems('PROPOSEDRES','C-Plan Reserve');
        AddItems('EXCLUDED','Excluded');
        AddItems('CURRAVAIL','Available');
        AddItems('CURREFFTARG','Available Crown Target');
        AddItems('%ITARGMET','% JANIS Target Met');
        AddItems('%TRIMITMET','% Crown Target Met');
        AddItems('%OETMET','% Initial Available Crown Target Met');
        AddItems('INUSE','Feature In Use');
        AddItems('MAN','Mandatory Reserve');
        AddItems('NEG','Negotiated Reserve');
        AddItems('PAR','Partial Reserve');
        }
   end;

   procedure TrimValueBox;
   var
      iTrimCount, iEqualsPos : integer;
      sTrimValue : string;
   begin
        if (ControlForm.RptFieldValueBox.Items.Count > 0) then
           for iTrimCount := 0 to (ControlForm.RptFieldValueBox.Items.Count-1) do
           begin
                sTrimValue := ControlForm.RptFieldValueBox.Items.Strings[iTrimCount];
                ControlForm.RptFieldValueBox.Items.Delete(iTrimCount);
                iEqualsPos := Pos('=',sTrimValue);
                sTrimValue := Copy(sTrimValue,iEqualsPos+1,Length(sTrimValue)-iEqualsPos);
                ControlForm.RptFieldValueBox.Items.Insert(iTrimCount,sTrimValue);
           end;
   end;

   procedure PopulateUserDefinedFields(const sUseDefinition : string);
   begin
        {populate listbox objects with user defined field order and names}
        if ControlRes^.fOldIni then
           AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
        else
            AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);

        AIni.ReadSection('Feature Report ' + sUseDefinition,
                         ControlForm.RptFieldBox.Items);
        AIni.ReadSectionValues('Feature Report ' + sUseDefinition,
                               ControlForm.RptFieldValueBox.Items);
        //trim values in RptFieldValueBox
        TrimValueBox;
        AIni.Free;
   end;

begin
     try
        fRun := True;
        if fTestFileExists then
           fRun := not CustFileExists(sFile,'Report Features');

        if fRun then
        begin
             {$IFDEF PROGRESS_RPT}
             ProgressOn;
             ProcLabelOn('Report Features');
             {$ENDIF}

             if FileExists(sFile) then
             begin
                  {$IFDEF VER90}
                  //PFileName := StrAlloc(Length(sFile) + 1);
                  //StrPCopy(PFileName,sFile);
                  //DeleteFile(PFileName);
                  DeleteFile(sFile);
                  //StrDispose(PFileName);
                  {$ELSE}
                  DeleteFile(sFile);
                  {$ENDIF}
             end;

             ControlForm.RptFieldBox.Items.Clear;
             ControlForm.RptFieldValueBox.Items.Clear;

             if (sTerminologyType = '') then
                PopulateDefaultFields
             else
                 PopulateUserDefinedFields(sTerminologyType);

             if (ControlForm.RptFieldBox.Items.Count > 0) then
             begin
                  AssignFile(RptFile,sFile);
                  Rewrite(RptFile);

                  WriteLn(RptFile,(Cust2DateStr + ' - ' + sDescr));

                  for iCount := 0 to (ControlForm.RptFieldBox.Items.Count - 1) do
                  begin
                       if (iCount = (ControlForm.RptFieldBox.Items.Count - 1)) then
                          writeln(RptFile,ControlForm.RptFieldValueBox.Items.Strings[iCount])
                       else
                           write(RptFile,ControlForm.RptFieldValueBox.Items.Strings[iCount] + ',');
                  end;

                  new(pFeat);

                  for iCount := 1 to iFCount do
                  begin
                       {$IFDEF PROGRESS_RPT}
                       ProgressUpdate(Round(iCount/iFCount*100));
                       {$ENDIF}

                       FArr.rtnValue(iCount,pFeat);
                       {LocalRepr.rtnValue(iCount,@ARepr);}

                       rContribArea := pFeat^.reservedarea + pFeat^.rDeferredArea;

                       if (pFeat^.rTrimmedTarget > 0) then
                          rPCTrim := rContribArea / pFeat^.rTrimmedTarget * 100
                       else
                           rPCTrim := 100;
                       if (pFeat^.rTrimmedTarget <= 0) then
                          rPCTrim := 0;

                       if (pFeat^.rInitialAvailableTarget > 0) then
                          rPCOrigEff := pFeat^.rDeferredArea / pFeat^.rInitialAvailableTarget * 100
                       else
                           rPCOrigEff := 100;
                       if (pFeat^.rInitialAvailableTarget <= 0) then
                          rPCOrigEff := 0;

                       if fUseITarget then
                       begin
                            sFlatTarget := '';
                            sPCFlat := '';

                            sCutOff := FloatToStr(pFeat^.rCutOff);
                            if (pFeat^.rCutOff > 0) then
                               sPCOrig := FloatToStr(rContribArea / pFeat^.rCutOff * 100)
                            else
                                sPCOrig := '100';
                            if (pFeat^.rCutOff <= 0) then
                               sPCOrig := '0';
                            sTrimmedTarget := FloatToStr(pFeat^.rTrimmedTarget);
                            sPCTrim := FloatToStr(rPCTrim);
                       end
                       else
                       begin
                            sPCOrig := '';
                            sCutOff := '';
                            sTrimmedTarget := '';
                            sPCTrim := '';

                            sFlatTarget := FloatToStr(pFeat^.totalarea*rPC/100);
                            if ((pFeat^.totalarea*rPC/100) > 0) then
                               sPCFlat := FloatToStr(rContribArea / (pFeat^.totalarea*rPC/100) * 100)
                            else
                                sPCFlat := '100';
                            if ((pFeat^.totalarea*rPC/100) <= 0) then
                               sPCFlat := '0';
                       end;

                       if pFeat^.fRestrict then
                       begin
                            sInUse := 'False';

                            {columns 7, 8, 9, 13, 14, 15, 16, 17 should be empty}
                            sTrimmedTarget := '';
                            sFlatTarget := '';
                            sOriginalEffectiveTarget := ''; {9}

                            sCurrentEffectiveTarget := '';  {13}
                            sPCOrig := '';
                            sPCTrim := '';
                            sPCFlat := '';
                            sPCOrigEff := '';  {17}
                       end
                       else
                       begin
                            sInUse := 'True';

                            sOriginalEffectiveTarget := FloatToStr(pFeat^.rInitialAvailableTarget); {9}
                            sCurrentEffectiveTarget := FloatToStr(pFeat^.targetarea); {13}
                            sPCOrigEff := FloatToStr(rPCOrigEff); {17}
                       end;


                       for iCount2 := 0 to (ControlForm.RptFieldBox.Items.Count - 1) do
                       begin
                            if (iCount2 = (ControlForm.RptFieldBox.Items.Count - 1)) then
                               writeln(RptFile,rtnValueOfVariable(ControlForm.RptFieldBox.Items.Strings[iCount2]))
                            else
                                write(RptFile,rtnValueOfVariable(ControlForm.RptFieldBox.Items.Strings[iCount2]) + ',');
                       end;
                  end;

                  dispose(pFeat);

                  CloseFile(RptFile);
             end;

             {$IFDEF PROGRESS_RPT}
             ProgressOff;
             ProcLabelOff;
             {$ENDIF}
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReportFeatures',mtError,[mbOk],0);
     end;
end;

{----------------------------------------------------------}

procedure CountTotalAreas(var rUr,rIr1,r001,r002,r003,r004,r005,r0Co,
                          rFl,rRe,rIg,rR1,rR2,rR3,rR4,rR5,rPd,rEx{,rTotal} : extended;
                          const SArr : Array_t; const iSCount : integer);
var
   iCount : integer;
   pSite : sitepointer;
begin
     {$IFDEF PROGRESS_RPT}
     CForm.ProgressOn;
     CForm.ProcLabelOn('Counting Total Areas');
     {$ENDIF}

     rUr := 0;
     rIr1 := 0;
     r001 := 0;
     r002 := 0;
     r003 := 0;
     r004 := 0;
     r005 := 0;
     r0Co := 0;
     rFl := 0;
     rRe := 0;
     rIg := 0;
     rR1 := 0;
     rR2 := 0;
     rR3 := 0;
     rR4 := 0;
     rR5 := 0;
     rPd := 0;
     rEx := 0;
     {rTotal := 0;}

     new(pSite);

     for iCount := 1 to iSCount do
     begin
          {$IFDEF PROGRESS_RPT}
          CForm.ProgressUpdate(Round(iCount/iSCount*100));
          {$ENDIF}

          SArr.rtnValue(iCount,pSite);

          {rTotal := rTotal + pSite^.area;}

          if (pSite^.status = Av)
          or (pSite^.status = Fl) then
          begin
               if (pSite^.status = Fl) then
                  rFl := rFl + pSite^.area;

               if (pSite^.status = Av) then
                  rUr := rUr + pSite^.area;

               if (pSite^.sDisplay = 'Ir1') then
                  rIr1 := rIr1 + pSite^.area
               else
               if (pSite^.sDisplay = '001') then
                  r001 := r001 + pSite^.area
               else
               if (pSite^.sDisplay = '002') then
                  r002 := r002 + pSite^.area
               else
               if (pSite^.sDisplay = '003') then
                  r003 := r003 + pSite^.area
               else
               if (pSite^.sDisplay = '004') then
                  r004 := r004 + pSite^.area
               else
               if (pSite^.sDisplay = '005') then
                  r005 := r005 + pSite^.area
               else
               if (pSite^.sDisplay = '0Co') then
                  r0Co := r0Co + pSite^.area;
          end
          else
          if (pSite^.status = Re) then
             rRe := rRe + pSite^.area
          else
          if (pSite^.status = Ig) then
             rIg := rIg + pSite^.area
          else
          if (pSite^.status = _R1) then
             rR1 := rR1 + pSite^.area
          else
          if (pSite^.status = _R2) then
             rR2 := rR2 + pSite^.area
          else
          if (pSite^.status = _R3) then
             rR3 := rR3 + pSite^.area
          else
          if (pSite^.status = _R4) then
             rR4 := rR4 + pSite^.area
          else
          if (pSite^.status = _R5) then
             rR5 := rR5 + pSite^.area
          else
          if (pSite^.status = Pd) then
             rPd := rPd + pSite^.area
          else
          if (pSite^.status = Ex) then
             rEx := rEx + pSite^.area;
     end;

     dispose(pSite);

     {$IFDEF PROGRESS_RPT}
     CForm.ProgressOff;
     CForm.ProcLabelOff;
     {$ENDIF}
end;

function Cust1FloatToStr(const rNum : real) : string;
var
   sReal : string;
begin
     Str(rNum:12:1,sReal);
     Result := sReal;
end;

procedure ReportTotals(const sFile, sDescr : string; const fTestFileExists : boolean;
                       const RptBox : TListbox; const SArr : Array_t;
                       const iSCount, iIr1Count,i001Count,i002Count,i003Count,
                       i004Count,i005Count,i0CoCount,
                       iAv, iFl, iRe, iIg, iR1, iR2, iR3, iR4, iR5, iPd, iEx : integer);
var
   rUr,rIr1,r001,r002,r003,r004,r005,
   r0Co,rFl,rRe,rIg,rR1,rR2,rR3,rR4,rR5,rPd,rEx,rTotal : extended;
   fRun, fResult : boolean;
   sCount, sValue : string;
   PFileName : PChar;
begin
     fRun := True;
     if fTestFileExists then
        fRun := not CustFileExists(sFile,'Site Count');

     if fRun then
     begin
          CountTotalAreas(rUr,rIr1,r001,r002,r003,r004,r005,r0Co,
                          rFl,rRe,rIg,rR1,rR2,rR3,rR4,rR5,rPd,rEx,
                          SArr, iSCount);

          rTotal := rUr + rFl + rRe + rIg + rR1 + rR2 + rR3 + rR4 + rR5 + rPd + rEx;

          RptBox.Items.Clear;
          RptBox.Items.Add('Site Count For Each Class,' +
                              Cust2DateStr + ',' + sDescr);
          RptBox.Items.Add('');
          RptBox.Items.Add('Site Class,Site Count,Site Class Total Area');
          Str(iAv:6,sCount);
          Str(rUr:11:2,sValue);
          RptBox.Items.Add('Available,' + sCount + ',' + sValue);


          Str(iFl:6,sCount);
          Str(rFl:11:2,sValue);
          RptBox.Items.Add('Flagged,' + sCount + ',' + sValue);

          Str(iRe:6,sCount);
          Str(rRe:11:2,sValue);
          RptBox.Items.Add('Initial Reserved,' + sCount + ',' + sValue);

          Str(iIg:6,sCount);
          Str(rIg:11:2,sValue);
          RptBox.Items.Add('Initial Excluded,' + sCount + ',' + sValue);

          Str(iR1:6,sCount);
          Str(rR1:11:2,sValue);
          RptBox.Items.Add(ControlRes^.sR1Label+',' + sCount + ',' + sValue);

          if (ControlRes^.sR2Label <> '') then
          begin
               Str(iR2:6,sCount);
               Str(rR2:11:2,sValue);
               RptBox.Items.Add(ControlRes^.sR2Label+',' + sCount + ',' + sValue);
          end;

          if (ControlRes^.sR3Label <> '') then
          begin
               Str(iR3:6,sCount);
               Str(rR3:11:2,sValue);
               RptBox.Items.Add(ControlRes^.sR3Label+',' + sCount + ',' + sValue);
          end;

          if (ControlRes^.sR4Label <> '') then
          begin
               Str(iR4:6,sCount);
               Str(rR4:11:2,sValue);
               RptBox.Items.Add(ControlRes^.sR4Label+',' + sCount + ',' + sValue);
          end;

          if (ControlRes^.sR5Label <> '') then
          begin
               Str(iR5:6,sCount);
               Str(rR5:11:2,sValue);
               RptBox.Items.Add(ControlRes^.sR5Label+',' + sCount + ',' + sValue);
          end;
          
          Str(iPd:6,sCount);
          Str(rPd:11:2,sValue);
          RptBox.Items.Add('Partially Reserved,' + sCount + ',' + sValue);

          Str(iEx:6,sCount);
          Str(rEx:11:2,sValue);
          RptBox.Items.Add('Excluded,' + sCount + ',' + sValue);
          RptBox.Items.Add('');

          Str(iSCount:6,sCount);
          Str(rTotal:11:2,sValue);
          RptBox.Items.Add('Total,' + sCount + ',' + sValue);

          RptBox.Items.Add('');
          RptBox.Items.Add('');

          RptBox.Items.Add('Available Irreplaceability Categories Are:');

          Str(iIr1Count:6,sCount);
          Str(rIr1:11:2,sValue);

          RptBox.Items.Add('');
          RptBox.Items.Add('Site Categories,Site Count,Category Total Area');
          RptBox.Items.Add('Ir1,' + sCount + ',' + sValue);

          Str(i001Count:6,sCount);
          Str(r001:11:2,sValue);
          RptBox.Items.Add('001,' + sCount + ',' + sValue);

          Str(i002Count:6,sCount);
          Str(r002:11:2,sValue);
          RptBox.Items.Add('002,' + sCount + ',' + sValue);
          Str(i003Count:6,sCount);
          Str(r003:11:2,sValue);
          RptBox.Items.Add('003,' + sCount + ',' + sValue);

          Str(i004Count:6,sCount);
          Str(r004:11:2,sValue);
          RptBox.Items.Add('004,' + sCount + ',' + sValue);

          Str(i005Count:6,sCount);
          Str(r005:11:2,sValue);
          RptBox.Items.Add('005,' + sCount + ',' + sValue);

          Str(i0CoCount:6,sCount);
          Str(r0Co:11:2,sValue);
          RptBox.Items.Add('0Co,' + sCount + ',' + sValue);

          if FileExists(sFile) then
          begin
               {$IFDEF VER90}
               //PFileName := StrAlloc(Length(sFile) + 1);

               //StrPCopy(PFileName,sFile);
               //fResult := DeleteFile(PFileName);
               fResult := DeleteFile(sFile);

               //StrDispose(PFileName);
               {$ELSE}
               fResult := DeleteFile(sFile);
               {$ENDIF}
          end;

          RptBox.Items.SaveToFile(sFile);
          RptBox.Items.Clear;
     end;
end;

procedure ReportMissingFeatures(const sFile,sDescr : string; const fTestFileExists : boolean;
                                const RptBox : TListbox; const CTable : TTable;
                                const CRes : ControlResPointer_T;
                                const OFArr, FArr : Array_t);
var
   iCount, iFCount, iFeatIdx, iFCode : integer;
   {pFeat : featureoccurrencepointer; }
   fFail, fRun : boolean;
   sTest : string;
   pFeat : featureoccurrencepointer;
begin
     try
        new(pFeat);

        fRun := True;
        if fTestFileExists then
           fRun := not CustFileExists(sFile,'Missing Features');

        if fRun then
        begin
             {$IFDEF PROGRESS_RPT}
             ProgressOn;
             ProcLabelOn('Report Missing Features');
             {$ENDIF}

             RptBox.Items.Clear;
             RptBox.Items.Add('Missing Features - ' +
                                        Cust2DateStr + ' - ' + sDescr);
             RptBox.Items.Add(' ');
             RptBox.Items.Add('    FEATNAME, ' + ControlRes^.sFeatureKeyField + ', ITARGET');

             try
                Screen.Cursor := crHourglass;

                fFail := False;
                CTable.Open;

             except on exception do
                    begin
                         Screen.Cursor := crDefault;
                         MessageDlg('Cannot find feature cut-offs table',
                                    mtError,[mbOK],0);
                         fFail := True;
                    end;
             end;

             iFCount := 0;
             iCount := 0;

             if not fFail then
             begin
                  while not CTable.EOF do
                  begin
                       Inc(iCount);
                       {$IFDEF PROGRESS_RPT}
                       ProgressUpdate(Round(iCount/
                                        CTable.RecordCount*100));
                       {$ENDIF}

                       iFCode := CTable.FieldByName(ControlRes^.sFeatureKeyField).AsInteger;
                       iFeatIdx := iFCode;

                       if (iFeatIdx > 0) then
                       begin
                            FArr.rtnValue(iFeatIdx,pFeat);

                            if (pFeat^.code <> iFCode) then
                            begin
                                 Inc(iFCount);

                                 if not CRes^.fUseNewDBLABELS then
                                    RptBox.Items.Add('    "' +
                                       CTable.FieldByName('CODE').AsString + '", ' +
                                       CTable.FieldByName(ControlRes^.sFeatureKeyField).AsString + ', ' +
                                       CTable.FieldByName('CUTOFF').AsString)
                                 else
                                     RptBox.Items.Add('    "' +
                                         CTable.FieldByName('FEATNAME').AsString + '", ' +
                                         CTable.FieldByName(ControlRes^.sFeatureKeyField).AsString + ', ' +
                                         CTable.FieldByName('ITARGET').AsString);
                            end;
                       end
                       else
                       begin
                            Inc(iFCount);

                            if not CRes^.fUseNewDBLABELS then
                               RptBox.Items.Add('    "' +
                                  CTable.FieldByName('CODE').AsString + '", ' +
                                  CTable.FieldByName(ControlRes^.sFeatureKeyField).AsString + ', ' +
                                  CTable.FieldByName('CUTOFF').AsString)
                            else
                                RptBox.Items.Add('    "' +
                                    CTable.FieldByName('FEATNAME').AsString + '", ' +
                                    CTable.FieldByName(ControlRes^.sFeatureKeyField).AsString + ', ' +
                                    CTable.FieldByName('ITARGET').AsString);
                       end;

                       CTable.Next;
                  end;
             end;

             {dispose(pFeat);}

             if (iFCount = 0) then
             begin
                  RptBox.Items.Add(' ');
                  RptBox.Items.Add('No Missing Features found in Region');
             end;

             CTable.Close;

             RptBox.Items.SaveToFile(sFile);
             RptBox.Items.Clear;

             {$IFDEF PROGRESS_RPT}
             ProgressOff;
             ProcLabelOff;
             {$ENDIF}
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Missing Features Report',mtError,[mbOk],0);
     end;

     dispose(pFeat);
end;

procedure ReportPartial(const sFile, sDescr : string; const fTestFileExists : boolean;
                        const RptBox, PGeocode : TListbox; const SArr : Array_t;
                        const FArr : Array_t; const OSArr, OFArr : Array_t);
var
   iCount, iCount2, iFeatIndex, iSiteIndex : integer;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   fRun, fReserved : boolean;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     fRun := True;
     if fTestFileExists then
        fRun := not CustFileExists(sFile,'Partial Selection');

     if fRun then
     begin
          RptBox.Items.Clear;
          RptBox.Items.Add('Partially Reserved - ' + Cust2DateStr + ' - ' + sDescr);
          RptBox.Items.Add('  ');

          new(pSite);
          new(pFeat);

          for iCount := 0 to (PGeocode.Items.Count-1) do
          begin
               iSiteIndex := FindFeatMatch(OSArr,StrToInt(PGeocode.Items.Strings[iCount]));
               SArr.rtnValue(iSiteIndex,pSite);

               RptBox.Items.Add(pSite^.sName);

               if (pSite^.richness > 0) then
               begin
                    {write deferred features}
                    RptBox.Items.Add('  Reserved');
                    for iCount2 := 1 to pSite^.richness do
                    begin
                         SparsePartial.rtnValue(pSite^.iOffset + iCount2,@fReserved);
                         if fReserved then
                         begin
                              FeatureAmount.rtnValue(pSite^.iOffset + iCount2,@Value);
                              iFeatIndex := Value.iFeatKey;
                              FArr.rtnValue(iFeatIndex,pFeat);

                              RptBox.Items.Add('    ' + IntToStr(pFeat^.code) +
                                                  ', ' + pFeat^.sID);
                         end;
                    end;

                    {write non-deferred features}
                    RptBox.Items.Add('  Not Reserved');
                    for iCount2 := 1 to pSite^.richness do
                    begin
                         SparsePartial.rtnValue(pSite^.iOffset + iCount2,@fReserved);
                         if fReserved then
                         begin
                              FeatureAmount.rtnValue(pSite^.iOffset + iCount2,@Value);
                              iFeatIndex := Value.iFeatKey;
                              FArr.rtnValue(iFeatIndex,pFeat);

                              RptBox.Items.Add('    ' + IntToStr(pFeat^.code) +
                                                  ', ' + pFeat^.sID);
                         end;
                    end;
               end
               else
                   RptBox.Items.Add('  ' + 'no features available');

               RptBox.Items.Add('  ');
          end;

          dispose(pSite);
          dispose(pFeat);

          RptBox.Items.SaveToFile(sFile);
          RptBox.Items.Clear;
     end;
end;

{----------------------------------------------------------}

procedure TrimValues(const ABox : TListbox);
var
   iEqualsPos,
   iCount : integer;
   sAdjust : string;
begin
     if (ABox.Items.Count > 0) then
        for iCount := 0 to (ABox.Items.Count-1) do
        begin
             sAdjust := ABox.Items.Strings[iCount];

             iEqualsPos := Pos('=',sAdjust);
             if (iEqualsPos > 0) then
             begin
                  ABox.Items.Delete(iCount);
                  sAdjust := Copy(sAdjust,iEqualsPos+1,Length(sAdjust)-iEqualsPos);
                  ABox.Items.Insert(iCount,sAdjust);
             end;
        end;
end;

function FieldIsDefaultSiteField(const sField : string) : boolean;
begin
     Result := False;
     if (sField = 'NAME') then
        Result := True;
(*
NAME
SITEKEY
STATUS
I_STATUS
TENURE
AREA
IRREPL
I_IRREPL
SUMIRR
I_SUMIRR
WAVIRR
I_WAVIRR
PCCONTR
I_PCCONTR
DISPLAY
CROWN
SUM_PA
SUM_IT
SUM_VU
SUM_PAIT
SUM_PAVU
SUM_ITVU
SUM_PAITVU
SUM_CR
SUM_PT
SUM_CRIT
SUM_CRVU
SUM_CRITVU
SUM_SA
SUM_SAPA
SUM_SAPT
SUM_PAPT

        if ControlRes^.fFeatureClassesApplied then
        begin
             for iSubsetCount := 1 to 10 do
                 if ControlRes^.ClassDetail[iSubsetCount] then
                 begin
                      {subset iSubsetCount is in use}
                      if UserSubsetChoices._first[iSubsetCount].fIrr then
                         AddAField('IRR' + IntToStr(iSubsetCount));
                      if UserSubsetChoices._first[iSubsetCount].fSum then
                         AddAField('SUM' + IntToStr(iSubsetCount));

                      if ControlRes^.fCalculateAllVariations then
                      begin
                           if UserSubsetChoices._first[iSubsetCount].fSum_A then
                              AddAField('SUM_A' + IntToStr(iSubsetCount));
                           if UserSubsetChoices._first[iSubsetCount].fSum_T then
                              AddAField('SUM_T' + IntToStr(iSubsetCount));
                           if UserSubsetChoices._first[iSubsetCount].fSum_V then
                              AddAField('SUM_V' + IntToStr(iSubsetCount));
                           if UserSubsetChoices._first[iSubsetCount].fSum_AT then
                              AddAField('SUM_AT' + IntToStr(iSubsetCount));
                           if UserSubsetChoices._first[iSubsetCount].fSum_AV then
                              AddAField('SUM_AV' + IntToStr(iSubsetCount));
                           if UserSubsetChoices._first[iSubsetCount].fSum_TV then
                              AddAField('SUM_TV' + IntToStr(iSubsetCount));
                           if UserSubsetChoices._first[iSubsetCount].fSum_ATV then
                              AddAField('SUM_ATV' + IntToStr(iSubsetCount));
                      end;
                 end;

             for iSubsetCount := 1 to 5 do
                 if ControlRes^.ClassDetail[iSubsetCount] then
                 begin
                      if UserSubsetChoices._second[iSubsetCount].fWav then
                         AddAField('WAV' + IntToStr(iSubsetCount));
                      if UserSubsetChoices._second[iSubsetCount].fPC then
                         AddAField('PC' + IntToStr(iSubsetCount));
                 end;
        end;

        if ControlRes^.fSpatResultCreated then
        begin
             for iSubsetCount := 1 to 10 do
                 if ControlRes^.fDoConfigOnSubset[iSubsetCount] then
                    AddAField('SPAT' + IntToStr(iSubsetCount));
             AddAField('SPAT');
        end;

*)

end;
//function IsUserDefinedSiteField(const sField : string;
//                                ATable : TTable
function ListUserDefinedSiteFields(var UserDefinedFields : Array_t) : integer;
var
   iCount : integer;
   sField : str255;
begin
     Result := 0;
     UserDefinedFields := Array_T.Create;
     UserDefinedFields.init(SizeOf(str255),10);

     ControlForm.OutTable.Open;

     // loop through the fields in the table, adding them to the list if they are user defined
     // (that is, is they are not one of the in built fields)
     for iCount := 0 to (ControlForm.OutTable.FieldDefs.Count - 1) do
     begin
          sField := ControlForm.OutTable.FieldDefs.Items[iCount].Name;
          if not FieldIsDefaultSiteField(sField) then
          begin
               // add the field to the list of user defined fields
               Inc(Result);
               if (Result > UserDefinedFields.lMaxSize) then
                  UserDefinedFields.resize(UserDefinedFields.lMaxSize + 10);
               UserDefinedFields.setValue(Result,@sField);
          end;
     end;

     ControlForm.OutTable.Close;

     if (Result > 0) then
     begin
          if (Result <> UserDefinedFields.lMaxSize) then
             UserDefinedFields.resize(Result);
     end
     else
     begin
          UserDefinedFields.resize(1);
          UserDefinedFields.lMaxSize := 0;
     end;
end;

procedure ReportSites(const sFile, sDescr : string; const fTestFileExists : boolean;
                      const OTable : TTable; const iSCount : integer;
                      const SArr : Array_t; const CRes : ControlResPointer_T;
                      const sTerminologyType : string);
var
   iCount2, iCount, iWriteCount, iEqualPos, iUserDefinedCount : integer;
   sLabel, sValue : string;
   ASite : site;

   OutFile : text;
   sALine : string;

   fStop : boolean;

   AIni : TIniFile;

   cSpatChar,
   aChar, bChar, cChar : char;
   iSpatSubset, iSpatSubsetVector,
   iLength : integer;
   sSingle : single;

   WS : WeightedSumirr_T;

   function rtnATVSubsetValue(const sWeightings : string;
                              const iSubset : integer) : string;
   begin
        if (iSubset = 0) then
        begin
             if (sWeightings = 'A') then
                Result := FloatToStr(WS.r_a)
             else
             if (sWeightings = 'T') then
                Result := FloatToStr(WS.r_t)
             else
             if (sWeightings = 'V') then
                Result := FloatToStr(WS.r_v)
             else
             if (sWeightings = 'AT') then
                Result := FloatToStr(WS.r_at)
             else
             if (sWeightings = 'AV') then
                Result := FloatToStr(WS.r_av)
             else
             if (sWeightings = 'TV') then
                Result := FloatToStr(WS.r_tv)
             else
                 Result := FloatToStr(WS.r_atv);
        end
        else
        begin
             if (sWeightings = 'A') then
                Result := FloatToStr(WS.r_sub_a[iSubset])
             else
             if (sWeightings = 'T') then
                Result := FloatToStr(WS.r_sub_t[iSubset])
             else
             if (sWeightings = 'V') then
                Result := FloatToStr(WS.r_sub_v[iSubset])
             else
             if (sWeightings = 'AT') then
                Result := FloatToStr(WS.r_sub_at[iSubset])
             else
             if (sWeightings = 'AV') then
                Result := FloatToStr(WS.r_sub_av[iSubset])
             else
             if (sWeightings = 'TV') then
                Result := FloatToStr(WS.r_sub_tv[iSubset])
             else
                 Result := FloatToStr(WS.r_sub_atv[iSubset]);
        end;
   end;

   function rtnSumATVVariation(const sV : string) : string;
   var
      cLastChar : char;
   begin
        if ControlRes^.fCalculateAllVariations then
        begin
             Result := '';
             {SUM_ A, T, V, variations and subsets 1..10 = 77 variables}
                                      {SUM_A, SUM_T, SUM_V, SUM_AT, SUM_AV, SUM_TV, SUM_ATV
                                       SUM_A1, ...
                                       ...
                                       SUM_A10, ...}
                                      {length 5 = SUM_A, SUM_T, SUM_V
                                              6 = SUM_AT, SUM_AV, SUM_TV, SUM_A1..9, SUM_T1..9,
                                              7
                                              8
                                              9}
             cLastChar := sV[Length(sV)];
             case cLastChar of
                  '1' : {subset 1}Result := rtnATVSubsetValue(Copy(sV,5,Length(sV)-5),1);
                  '2' : {subset 2}Result := rtnATVSubsetValue(Copy(sV,5,Length(sV)-5),2);
                  '3' : {subset 3}Result := rtnATVSubsetValue(Copy(sV,5,Length(sV)-5),3);
                  '4' : {subset 4}Result := rtnATVSubsetValue(Copy(sV,5,Length(sV)-5),4);
                  '5' : {subset 5}Result := rtnATVSubsetValue(Copy(sV,5,Length(sV)-5),5);
                  '6' : {subset 6}Result := rtnATVSubsetValue(Copy(sV,5,Length(sV)-5),6);
                  '7' : {subset 7}Result := rtnATVSubsetValue(Copy(sV,5,Length(sV)-5),7);
                  '8' : {subset 8}Result := rtnATVSubsetValue(Copy(sV,5,Length(sV)-5),8);
                  '9' : {subset 9}Result := rtnATVSubsetValue(Copy(sV,5,Length(sV)-5),9);
                  '0' : {subset 10}Result := rtnATVSubsetValue(Copy(sV,5,Length(sV)-6),10);
             else
                 {all features}Result := rtnATVSubsetValue(Copy(sV,5,Length(sV)-4),0);
             end;
        end
        else
            Result := '';
   end;

   function rtnValueOfVariable(const sVariable : string) : string;
   var
      iSpatCount : integer;
   begin
        try
           {return the string value of the variable specified by sVariable}
           Result := '';

           aChar := sVariable[1];
           try
           if (Length(sVariable) > 3) then
                bChar := sVariable[4];
           except

           end;
           cChar := sVariable[3];
           iLength  := Length(sVariable);
           case aChar of
                'N' : {NAME}                Result := ASite.sName;
                'K' : {KEY}                 Result := IntToStr(ASite.iKey);
                'S' : {STATUS, SUMIRR, SUM1, SUM2, ... , SUM10}
                      case bChar of
                           'T' : {STATUS as well as SPAT and SPAT1..10}
                                 if (iLength = 6) then
                                    Result := Status2Str(ASite.status)
                                 else
                                     if (iLength = 4) then
                                     begin
                                          // SPAT
                                          if ControlRes^.fSpatResultCreated then
                                          begin
                                               SpatResult.rtnValue((ControlRes^.iSpatialVectorsToPass * iSiteCount) + iCount,@sSingle);
                                               Result := FloatToStr(sSingle);
                                          end
                                          else
                                              Result := '';
                                     end
                                     else
                                     begin
                                          // SPAT 1..10
                                          if ControlRes^.fSpatResultCreated then
                                          begin
                                               cSpatChar := sVariable[5];
                                               case cSpatChar of
                                                    '1' : if (iLength = 5) then
                                                             // SPAT1
                                                             iSpatSubset := 1
                                                          else
                                                              // SPAT10
                                                              iSpatSubset := 10;
                                                    '2' : iSpatSubset := 2;
                                                    '3' : iSpatSubset := 3;
                                                    '4' : iSpatSubset := 4;
                                                    '5' : iSpatSubset := 5;
                                                    '6' : iSpatSubset := 6;
                                                    '7' : iSpatSubset := 7;
                                                    '8' : iSpatSubset := 8;
                                                    '9' : iSpatSubset := 9;
                                               end;
                                               // convert iSpatSubset to iSpatSubsetVector,
                                               // iSpatSubsetVector=0 means this vector is not in use
                                               iSpatSubsetVector := 0;
                                               for iSpatCount := 1 to 10 do
                                                   if (iSpatCount <= iSpatSubset) then
                                                      if ControlRes^.fDoConfigOnSubset[iSpatCount] then
                                                         Inc(iSpatSubsetVector);
                                               if (iSpatSubsetVector = 0) then
                                                  Result := ''
                                               else
                                               begin
                                                    SpatResult.rtnValue(((iSpatSubsetVector-1) * iSiteCount) + iCount,@sSingle);
                                                    Result := FloatToStr(sSingle);
                                               end;
                                          end
                                          else
                                              Result := '';
                                     end;
                           'I' : {SUMIRR}   Result := FloatToStr(ASite.rSummedIrr);
                           '1' : if (iLength = 4) then
                                    {SUM1}  Result := FloatToStr(ASite.rSubsetSum[1])
                                 else
                                     {SUM10}Result := FloatToStr(ASite.rSubsetSum[10]);
                           '2' : {SUM2}     Result := FloatToStr(ASite.rSubsetSum[2]);
                           '3' : {SUM3}     Result := FloatToStr(ASite.rSubsetSum[3]);
                           '4' : {SUM4}     Result := FloatToStr(ASite.rSubsetSum[4]);
                           '5' : {SUM5}     Result := FloatToStr(ASite.rSubsetSum[5]);
                           '6' : {SUM6}     Result := FloatToStr(ASite.rSubsetSum[6]);
                           '7' : {SUM7}     Result := FloatToStr(ASite.rSubsetSum[7]);
                           '8' : {SUM8}     Result := FloatToStr(ASite.rSubsetSum[8]);
                           '9' : {SUM9}     Result := FloatToStr(ASite.rSubsetSum[9]);
                           '_' : Result := rtnSumATVVariation(sVariable);

                      end;
                'I' : {I_STATUS, IRREPL, I_IRREPL, I_SUMIRR, I_WAVIRR, I_PCCONTR, IRR1, ..., IRR10}
                      case bChar of
                           'T' : {I_STATUS} try
                                               Result := OTable.FieldByName('I_STATUS').AsString;
                                            except
                                                  Result := OTable.FieldByName('TENURE').AsString; {backward compatability with earlier version databases}
                                            end;
                           'E' : {IRREPL}   Result := FloatToStr(ASite.rIrreplaceability);
                           'R' : {I_IRREPL}
                                            if CRes^.fUseNewDBLABELS then
                                               Result := OTable.FieldByName('I_IRREPL').AsString
                                            else
                                                Result := OTable.FieldByName('INITEMR').AsString;  {backward compatability with earlier version databases}
                           'U' : {I_SUMIRR} Result := OTable.FieldByName('I_SUMIRR').AsString;
                           'A' : {I_WAVIRR} Result := OTable.FieldByName('I_WAVIRR').AsString;
                           'C' : {I_PCCONTR}try
                                               Result := OTable.FieldByName('I_PCCONTR').AsString;
                                            except
                                                  Result := '';
                                            end;
                           '1' : if (iLength = 4) then
                                    {IRR1}  Result := FloatToStr(ASite.rSubsetIrr[1])
                                 else
                                     {IRR10}Result := FloatToStr(ASite.rSubsetIrr[10]);
                           '2' : {IRR2}     Result := FloatToStr(ASite.rSubsetIrr[2]);
                           '3' : {IRR3}     Result := FloatToStr(ASite.rSubsetIrr[3]);
                           '4' : {IRR4}     Result := FloatToStr(ASite.rSubsetIrr[4]);
                           '5' : {IRR5}     Result := FloatToStr(ASite.rSubsetIrr[5]);
                           '6' : {IRR6}     Result := FloatToStr(ASite.rSubsetIrr[6]);
                           '7' : {IRR7}     Result := FloatToStr(ASite.rSubsetIrr[7]);
                           '8' : {IRR8}     Result := FloatToStr(ASite.rSubsetIrr[8]);
                           '9' : {IRR9}     Result := FloatToStr(ASite.rSubsetIrr[9]);
                      end;
                'A' : {AREA}                Result := FloatToStr(ASite.area);
                'W' : {WAVIRR, WAV1, ... , WAV5}
                      case bChar of
                           'I' : {WAVIRR}   Result := FloatToStr(ASite.rWAVIRR);
                           '1' : {WAV1}     Result := FloatToStr(ASite.rSubsetWav[1]);
                           '2' : {WAV2}     Result := FloatToStr(ASite.rSubsetWav[2]);
                           '3' : {WAV3}     Result := FloatToStr(ASite.rSubsetWav[3]);
                           '4' : {WAV4}     Result := FloatToStr(ASite.rSubsetWav[4]);
                           '5' : {WAV5}     Result := FloatToStr(ASite.rSubsetWav[5]);
                      end;
                'P' : {PCCONTR, PC1, ... , PC5}
                      case cChar of
                           'C' : {PCCONTR}  Result := FloatToStr(ASite.rPCUSED);
                           '1' : Result := FloatToStr(ASite.rSubsetPCUsed[1]);
                           '2' : Result := FloatToStr(ASite.rSubsetPCUsed[2]);
                           '3' : Result := FloatToStr(ASite.rSubsetPCUsed[3]);
                           '4' : Result := FloatToStr(ASite.rSubsetPCUsed[4]);
                           '5' : Result := FloatToStr(ASite.rSubsetPCUsed[5]);
                           {PC1, PC2, PC3, PC4, PC5}
                      end;
                'D' : {DISPLAY}
                                            Result := OTable.FieldByName('DISPLAY').AsString;

                // Variables we need to add
                {
                Date : Tue 29 Sept 1998
                Purpose : Spatial contrib variable(s) and sumirr weightings and subsets added to site report


                SPAT
                SPAT1..10
                SUM_A
                SUM_A1..10
                SUM_T
                SUM_T1..10
                SUM_V
                SUM_V1..10
                SUM_AT
                SUM_AT1..10
                SUM_AV
                SUM_AV1..10
                SUM_TV
                SUM_TV1..10
                SUM_ATV
                SUM_ATV1..10

                total of (8 * 10) + 8 = 88 variables to add
                we must return '' (blank string) if any or all of the subsets requested are not in use

                }
           end;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in rtnValueOfVariable ' + sVariable,
                         mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;
   end;

   procedure PopulateDefaultFields;

      procedure AddItems(const sField,sFieldValue : string);
      begin
           ControlForm.RptFieldBox.Items.Add(sField);
           ControlForm.RptFieldValueBox.Items.Add(sFieldValue);
      end;

   begin
        {populate listbox objects with default field order and names}
        AddItems('NAME','NAME');
        AddItems('KEY',ControlRes^.sKeyField);
        AddItems('STATUS','STATUS');
        AddItems('I_STATUS','I_STATUS');
        AddItems('AREA','AREA');
        AddItems('IRREPL','IRREPL');
        AddItems('I_IRREPL','I_IRREPL');
        AddItems('SUMIRR','SUMIRR');
        AddItems('I_SUMIRR','I_SUMIRR');
        AddItems('WAVIRR','WAVIRR');
        AddItems('I_WAVIRR','I_WAVIRR');
        AddItems('PCCONTR','PCCONTR');
        AddItems('I_PCCONTR','I_PCCONTR');
        AddItems('DISPLAY','DISPLAY');
   end;

   function rtnSection(const iUseIthDefinition : integer) : string;
   var
      iInc, iIniPos : integer;
      fInc : boolean;
   begin
        {read all lines from the ini file}

        if ControlRes^.fOldIni then
           ControlForm.RptFieldBox.Items.LoadFromFile(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
        else
            ControlForm.RptFieldBox.Items.LoadFromFile(ControlRes^.sDatabase + '\' + INI_FILE_NAME);

        iInc := iUseIthDefinition;
        iIniPos := 0;
        Result := '';
        if (ControlForm.RptFieldBox.Items.Count > 0) then
           repeat
                 {find the line which has '[Site Report ****]'}
                 fInc := False;
                 repeat
                       if (Length(ControlForm.RptFieldBox.Items.Strings[iIniPos]) >
                           Length('[Site Report ]')) then
                          if (Copy(ControlForm.RptFieldBox.Items.Strings[iIniPos],1,Length('[Site Report '))
                              = '[Site Report ')
                          and (Copy(ControlForm.RptFieldBox.Items.Strings[iIniPos],Length(ControlForm.RptFieldBox.Items.Strings[iIniPos]),1)
                               = ']') then
                          begin
                               {}
                               Result := Copy(ControlForm.RptFieldBox.Items.Strings[iIniPos],
                                              Length('[Site Report ') + 1,
                                              Length(ControlForm.RptFieldBox.Items.Strings[iIniPos]) - Length('[Site Report ]'));
                               fInc := True;
                          end;

                       Inc(iIniPos);
                       if (iIniPos >= ControlForm.RptFieldBox.Items.Count) then
                          fInc := True;

                 until fInc;

                 Dec(iInc);

           until (iInc <= 0);
           {seek until we find the iUstIthDefinition instance of
            '[Site Report ****]'

            **** is returned as the result}

   end;

   procedure PopulateUserDefinedFields(const sUseDefinition : string);
   begin
        {populate listbox objects with user defined field order and names}
        if ControlRes^.fOldIni then
           AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
        else
            AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);

        AIni.ReadSection('Site Report ' + sUseDefinition,
                         ControlForm.RptFieldBox.Items);
        AIni.ReadSectionValues('Site Report ' + sUseDefinition,
                               ControlForm.RptFieldValueBox.Items);

        TrimValues(ControlForm.RptFieldValueBox);

        AIni.Free;
   end;

begin
     try
        fStop := False;

        if fTestFileExists{
        and (not fNoUser)} then
           fStop := CustFileExists(sFile,'Site Irreplaceability');

        if not fStop then
        begin
             {we need to check which (if any) user defined fields to include in the report}
             ControlForm.RptFieldBox.Items.Clear;
             ControlForm.RptFieldValueBox.Items.Clear;

             {}
             if (sTerminologyType = '') then
                PopulateDefaultFields
             else
                 PopulateUserDefinedFields(sTerminologyType);

             {$IFDEF PROGRESS_RPT}
             ControlForm.ProgressOn;
             ControlForm.ProcLabelOn('Report Sites');
             ControlForm.Update;
             {$ENDIF}

             if (ControlForm.RptFieldBox.Items.Count > 0) then
             begin
                  assign(OutFile,sFile);
                  rewrite(OutFile);

                  writeln(OutFile,Cust2DateStr + ' - ' + sDescr);

                  for iCount := 0 to (ControlForm.RptFieldBox.Items.Count - 1) do
                  begin
                       if (iCount = (ControlForm.RptFieldBox.Items.Count - 1)) then
                          writeln(OutFile,ControlForm.RptFieldValueBox.Items.Strings[iCount])
                       else
                           write(OutFile,ControlForm.RptFieldValueBox.Items.Strings[iCount] + ',');
                  end;

                  OTable.Open;

                  for iCount := 1 to iSCount do
                  begin
                       {$IFDEF PROGRESS_RPT}
                       ControlForm.ProgressUpdate(Round(iCount /iSCount*100));
                       {$ENDIF}

                       SArr.rtnValue(iCount,@ASite);

                       if ControlRes^.fCalculateAllVariations then
                          WeightedSumirr.rtnValue(iCount,@WS);

                       for iCount2 := 0 to (ControlForm.RptFieldBox.Items.Count - 1) do
                       begin
                            if (iCount2 = (ControlForm.RptFieldBox.Items.Count - 1)) then
                               writeln(OutFile,rtnValueOfVariable(ControlForm.RptFieldBox.Items.Strings[iCount2]))
                            else
                                write(OutFile,rtnValueOfVariable(ControlForm.RptFieldBox.Items.Strings[iCount2]) + ',');
                       end;

                       OTable.Next;
                  end;

                  close(OutFile);

                  OTable.Close;

                  {$IFDEF PROGRESS_RPT}
                  ControlForm.ProgressOff;
                  ControlForm.ProcLabelOff;
                  {$ENDIF}
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReportSites',mtError,[mbOk],0);
     end;
end;

{----------------------------------------------------------}


end.
