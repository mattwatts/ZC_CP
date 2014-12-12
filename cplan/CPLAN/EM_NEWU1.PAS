unit Em_newu1;

{$I STD_DEF.PAS}

{$DEFINE StrToFloatBUG} {This is to work around a bug in StrToFloat}

{$UNDEF RPT_SUM_IRR} {report summed irreplaceability}

{$UNDEF SDTEST}

{$UNDEF DEBUG_CET}

{$UNDEF DEBUG_INITDEFEXCSUM}


{This is a modified version of EMRPRDLL (modified to run
 within DELPHI) which is itself a modified version of EMRPA5;

 EMRPRDLL and EMRPA5 were written by Bob Pressey.
 The Irreplaceability predictors in use now, SF_3 and SF_4, were
 written by Simon Ferrier.

 the main data structures derived from site data are arrays
 of pointers to records; written to be linked to the GIS Programs
    Windows E-RMS
    ArcView}

interface


uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DB, DBTables, StdCtrls, Buttons{, Em_newu2, Arrayt},
  DBCtrls, Global,
  {$IFDEF bit16}
  Arrayt16;
  {$ELSE}
  ds, Dll_u1;
  {$ENDIF}


type
  TTestForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Edit1: TEdit;
    ListBox1: TListBox;
    Edit2: TEdit;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure SparseCombsizePrep;
procedure SparseTargetsStart;
procedure SparseMatrixStart;
procedure IrrepStart;
procedure PrepIrrepData(const fNoProgressUpdate : boolean); {to be called by Simons Irreplacability algorithm}
procedure RePrepIrrepData;
procedure InitialPrepIrrepData;
procedure GetExcManSel;

{$IFNDEF SPARSE_MATRIX_2}
procedure MapPCUSED2Array;
function FindContribSite(const iGeocode : integer) : integer;
function FindSiteInContrib(const iGeocode : integer) : integer;
{returns 0 if site not found in GraphContribution.Sites
 else returns index to site (> 0)}
{$ENDIF}
procedure ReptSumIrr(const iFlag : word; const S : string);

procedure DumpAverageSite(pred_comb : Array_t);

PROCEDURE InitDefExcSum;
procedure ZeroTotalArea;


var
  StartCode:integer;
  InitCode:integer;
  RunCode:integer;
  databasepath:string[80];
  datafile:string[100]; {dos name plus backslash}
  outputfile:string[100]; {dos name plus backslash}
  {sitearray : sitearray_T;
  numfeatures:integer;
  numsites:integer;
  featurearray:featurearray_T;}
  maxrf:extended;
  {GraphContribution : GraphData_T;}

  {ProgressForm: TProgressForm;}
  TestForm : TTestForm;

  LogList : Array_T;

{--------------------------------------------------------------------------------}

//procedure DumpFeatures(const sId : string);


implementation

{$R *.DFM}

uses Control, {allow access to objects within Control form}
     Contribu, Sf_irrep, Featlist, In_order,
     Opt1, Toolmisc, reports, partl_ed,
     msetinf;



procedure ReptSumIrr(const iFlag : word; const S : string);
{$IFDEF RPT_SUM_IRR}
var errfile : Text;
{$ENDIF}
begin
     {$IFDEF RPT_SUM_IRR}

     {iFlag = 0 rewrites file, any other value appends to file}

     if (S <> '0') then
     begin
          assign(errfile,'c:\sumirr.txt');

          if (iFlag = 0) then
          begin
               rewrite(errfile);
               {new the DBG_FILE}
          end
          else
              append(errfile);

          writeln(errfile,S);

          close(errfile);
     end;

     {$ENDIF}
end;


 {---------------------------------------------------------------------------}


PROCEDURE FeatureList;
{Produces a list of features for the region}
var
   n, i, j, featurenumber, iFCode, iTmp : integer;
   newfeature:featureoccurrence;
   featurefound:boolean;
   pSite : sitepointer;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     ControlForm.ProgressOn;
     ControlForm.ProcLabelOn('Finding Features');

     new(pSite);

     with newfeature do
     begin
          totalarea := 0; {sets totalarea for all features to 0}
          //rTrimmedArea := 0;
          rInitialAvailable := 0;
          rDeferredArea := 0;
          rSumArea := 0;
          rCurrentAreaSqr := 0;
          rAreaSqr := 0;
          rExcluded := 0;
          reservedarea := 0;
          fRestrict := False;
     end;

     FeatArr := Array_t.Create;
     FeatCodes := Array_t.Create;
     FeatArr.init(SizeOf(featureoccurrence),ARR_STEP_SIZE);
     FeatCodes.init(SizeOf(integer),ARR_STEP_SIZE);
     iFeatureCount := 0;

     SiteArr.rtnValue(1,pSite);

     if (pSite^.richness > 0) then
        for i:=1 to pSite^.richness do
        begin
             {$IFDEF SPARSE_MATRIX}
             FeatureAmount.rtnValue(pSite^.iOffset + i,@Value);
             iTmp := Value.iFeatKey;
             {$ELSE}
             iTmp := pSite^.feature[i];
             {$ENDIF}
             newfeature.code := iTmp;

             Inc(iFeatureCount);

             if (iFeatureCount > FeatArr.lMaxSize) then
             begin
                  FeatArr.resize(FeatArr.lMaxSize + ARR_STEP_SIZE);
                  FeatCodes.resize(FeatArr.lMaxSize + ARR_STEP_SIZE);
            end;

             FeatArr.setValue(iFeatureCount,@newfeature);
             iFCode := newfeature.code;
             FeatCodes.setValue(iFeatureCount,@iFCode);
        end;

     ControlForm.ProgressUpdate(1);

     {scan through the list of feature codes in the first
      site; for each feature, increment numfeatures and write the
      code to the appropriate place in the array of records
      created to store all codes and associated information}

     for n:=2 to iSiteCount do
     begin
          SiteArr.rtnValue(n,pSite);

          if (pSite^.richness > 0) then
             for j:=1 to pSite^.richness do
             begin
                  {$IFDEF SPARSE_MATRIX}
                  FeatureAmount.rtnValue(pSite^.iOffset + j,@Value);
                  {$ENDIF}
                  featurefound:=false;
                  featurenumber:=1;
                  if (iFeatureCount > 0) then
                  repeat
                        FeatCodes.rtnValue(featurenumber,@newfeature.code);

                        {$IFDEF SPARSE_MATRIX}
                        if Value.iFeatKey=newfeature.code then
                        {$ELSE}
                        if pSite^.feature[j]=newfeature.code then
                        {$ENDIF}
                           featurefound:=true
                        else
                            featurenumber:=featurenumber+1;

                  until (featurefound=true) or (featurenumber>iFeatureCount);

                    {for each of the other site records in the array,
                     scan through the list of feature codes; compare each code
                     with the list of codes already produced in featurearray;
                     if there is a match, change the boolean variable to 'true'
                     and start again for the next code in the site being
                     considered; if there is no match, increment
                     the variable featurenumber and compare the same code
                     with the next one on the existing list until the
                     end of the list}

                  if not featurefound then
                  begin
                       {$IFDEF SPARSE_MATRIX}
                       newfeature.code := Value.iFeatKey;
                       {$ELSE}
                       newfeature.code := pSite^.feature[j];
                       {$ENDIF}
                       Inc(iFeatureCount);

                       if (iFeatureCount > FeatArr.lMaxSize) then
                       begin
                            FeatArr.resize(FeatArr.lMaxSize + ARR_STEP_SIZE);
                            FeatCodes.resize(FeatCodes.lMaxSize + ARR_STEP_SIZE);
                       end;

                       FeatArr.setValue(iFeatureCount,@newfeature);
                       FeatCodes.setValue(iFeatureCount,@newfeature.code);
                       {add the new feature to the feature array}
                  end;
             end;

              {if the end of the code list is reached and a match
               has not been found, increment the variable numfeatures,
               go to the end of code list and add the new one}
          ControlForm.ProgressUpdate(Round(n/iSiteCount*100));
     end;

     ControlForm.ProgressOff;
     ControlForm.ProcLabelOff;

     if (FeatArr.lMaxSize <> iFeatureCount) then
        FeatArr.resize(iFeatureCount);

     if (FeatCodes.lMaxSize <> iFeatureCount) then
        FeatCodes.resize(iFeatureCount);
     {adjust the size of our feature data set
      to the number of loaded features}

     OrdFeatArr := SortFeatArray(FeatCodes);

     dispose(pSite);

end;{procedure FeatureList}


PROCEDURE TotalArea;
{Calculates the total area of each feature in the region}
var
   iCount, iCount2, iFeatIndex : integer;
   ASite : site;
   AFeat : featureoccurrence;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     AverageSite := Array_t.Create;
     AverageSite.init(SizeOf(extended),iFeatureCount);
     AverageInitialSite := Array_t.Create;
     AverageInitialSite.init(SizeOf(extended),iFeatureCount);
     fAverageSiteCreated := True;
     {traverse sites and features for each site and find totalarea for features}
     for iCount := 1 to iSiteCount do
     begin
          SiteArr.rtnValue(iCount,@ASite);

          if (ASite.status <> Ig)
          and (ASite.richness > 0) then
             for iCount2 := 1 to ASite.richness do
             begin
                  {$IFDEF SPARSE_MATRIX}
                  FeatureAmount.rtnValue(ASite.iOffset + iCount2,@Value);
                  iFeatIndex := Value.iFeatKey;
                  {$ELSE}
                  iFeatIndex := FindFeature(ASite.feature[iCount2]);
                  {$ENDIF}
                  FeatArr.rtnValue(iFeatIndex,@AFeat);

                  try
                     {$IFDEF SPARSE_MATRIX}
                     AFeat.totalarea:=AFeat.totalarea+Value.rAmount;
                     {$ELSE}
                     AFeat.totalarea:=AFeat.totalarea+ASite.featurearea[iCount2];
                     {$ENDIF}
                     if (ASite.status = Av) then
                        AFeat.rInitialAvailable := AFeat.rInitialAvailable + Value.rAmount;
                        {summate areas within original Avialable sites}

                  except
                        MessageDlg('exception in TotalArea',mtInformation,[mbOK],0);
                  end;

                  FeatArr.setValue(iFeatIndex,@AFeat);
             end;
     end;
     {look for all occurrences of each feature in the
      array of sites and accumulate the area of each}

end; {procedure TotalArea}

procedure SparseTargetsStart;
var
  a:integer;
  pFeat : featureoccurrencepointer;
begin
     try
        try
           rPercentage := RegionSafeStrToFloat(ControlForm.TargetPercent.Text);
        except
              rPercentage := rPercentage;
        end;

        ControlForm.Warnings.Items.Clear;

        new(pFeat);
        for a:=1 to iFeatureCount do
        begin
             FeatArr.rtnValue(a,pFeat);

             // do the job of InitialGetPercentage
             if ControlForm.UseFeatCutOffs.Checked then
                pFeat^.targetarea := pFeat^.rCutOff
             else
                 pFeat^.targetarea:=pFeat^.totalarea*rPercentage/100;
             if (pFeat^.targetarea > pFeat^.totalarea) then
             begin
                  // we are reducing the ITARGET for this feature
                  ControlForm.Warnings.Items.Add('feature: ' + IntToStr(a) + '  ITARGET: ' + FloatToStr(pFeat^.targetarea) +  '  reduced target: ' + FloatToStr(pFeat^.totalarea) + '  trim amount: ' + FloatToStr(pFeat^.targetarea - pFeat^.totalarea));

                  pFeat^.targetarea := pFeat^.totalarea;
             end;
             if pFeat^.fRestrict then
                pFeat^.targetarea := 0;
             pFeat^.rTrimmedTarget := pFeat^.targetarea;
             pFeat^.rInitialTrimmedTarget := pFeat^.targetarea;

             // do the job of InitialTrimFeatTargets
             pFeat^.targetarea := pFeat^.targetarea - pFeat^.reservedarea;
             if (pFeat^.targetarea > pFeat^.rSumArea) then
                pFeat^.targetarea := pFeat^.rSumArea;
             pFeat^.rInitialAvailableTarget := pFeat^.targetarea;
             pFeat^.iOrdinalClass := 0;

             FeatArr.setValue(a,pFeat);
        end;
        dispose(pFeat);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception calculating targets',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure SparseCombsizePrep;
var
   iCount, iFeatIndex : integer;
   pFeat : featureoccurrencepointer;
   eAverageSite : extended;
begin
     try
        new(pFeat);
        for iFeatIndex := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iFeatIndex,pFeat);
             eAverageSite := (pFeat^.rCurrentSumArea - pFeat^.rExcluded)*1.0/(ControlForm.Available.Items.Count+
                                                                              ControlForm.Flagged.Items.Count);
             AverageSite.setValue(iFeatIndex,@eAverageSite);
        end;
        dispose(pFeat);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in SparseCombsizePrep',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure ZeroTotalArea;
var
   iCount : integer;
   pFeat : featureoccurrencepointer;
   fSummateOriginalAvailable : boolean;
begin
     new(pFeat);

     if (iActiveMinset < 1) then
        fSummateOriginalAvailable := True
     else
         fSummateOriginalAvailable := False;

     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,pFeat);

          if fSummateOriginalAvailable then
             pFeat^.rInitialAvailable := 0;

          pFeat^.totalarea := 0;
          pFeat^.rSumArea := 0;
          pFeat^.rCurrentSumArea := 0;
          pFeat^.rAreaSqr := 0;
          pFeat^.rCurrentAreaSqr := 0;
          pFeat^.reservedarea := 0;

          FeatArr.setValue(iCount,pFeat);
     end;

     dispose(pFeat);
end;

PROCEDURE SparseTotalArea(const fSummateOriginalAvailable : boolean);
{Calculates the total area of each feature in the region}
var
   iCount, iCount2, iFeatIndex : integer;
   ASite : site;
   AFeat : featureoccurrence;
   Value : ValueFile_T;
   eAverageSite : extended;
   DebugFile : TextFile;
begin
     try
        if ControlRes^.fDumpAverageSite then
        begin
             assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\Summate_AverageSite.csv');
             rewrite(DebugFile);
             writeln(DebugFile,'SiteKey,FeatKey,AverageSite,AverageInitialSite,SumArea,Excluded,AvSiteCount,InitialAvSiteCount');
        end;

        if not fAverageSiteCreated then
        begin
             AverageSite := Array_t.Create;
             AverageSite.init(SizeOf(extended),iFeatureCount);
             AverageInitialSite := Array_t.Create;
             AverageInitialSite.init(SizeOf(extended),iFeatureCount);
             fAverageSiteCreated := True;
        end;

        eAverageSite := 0;
        for iCount := 1 to iFeatureCount do
        begin
             AverageSite.setValue(iCount,@eAverageSite);
             AverageInitialSite.setValue(iCount,@eAverageSite);
        end;
        {traverse sites and features for each site and find totalarea for features}
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,@ASite);

             if (ASite.status <> Ig)
             and (ASite.richness > 0) then
                for iCount2 := 1 to ASite.richness do
                begin
                     FeatureAmount.rtnValue(ASite.iOffset + iCount2,@Value);
                     iFeatIndex := Value.iFeatKey;
                     FeatArr.rtnValue(iFeatIndex,@AFeat);

                     AFeat.totalarea:=AFeat.totalarea+Value.rAmount;
                     if (ASite.status = Av) or (ASite.status = Fl) then
                     begin
                          if fSummateOriginalAvailable then
                             AFeat.rInitialAvailable := AFeat.rInitialAvailable +
                                                        Value.rAmount;
                          {summate areas within original Avialable sites}
                          AFeat.rSumArea:=AFeat.rSumArea + Value.rAmount;
                          AFeat.rCurrentSumArea := AFeat.rCurrentSumArea + Value.rAmount;
                          AFeat.rAreaSqr := AFeat.rAreaSqr + sqr(Value.rAmount);
                          AFeat.rCurrentAreaSqr := AFeat.rCurrentAreaSqr + sqr(Value.rAmount);
                          eAverageSite := (AFeat.rCurrentSumArea - AFeat.rExcluded)*1.0/(ControlForm.Available.Items.Count+
                                                                                ControlForm.Flagged.Items.Count);
                          if ControlRes^.fDumpAverageSite then
                             write(DebugFile,IntToStr(ASite.iKey) + ',' +
                                             IntToStr(iFeatIndex) + ',' +
                                             FloatToStr(eAverageSite) + ',');
                          AverageSite.setValue(iFeatIndex,@eAverageSite);
                          eAverageSite := (AFeat.rSumArea - AFeat.rExcluded)*1.0/(ControlForm.Available.Items.Count +
                                                                                ControlForm.Flagged.Items.Count +
                                                                                ControlForm.R1.Items.Count +
                                                                                ControlForm.R2.Items.Count +
                                                                                ControlForm.R3.Items.Count +
                                                                                ControlForm.R4.Items.Count +
                                                                                ControlForm.R5.Items.Count +
                                                                                ControlForm.Partial.Items.Count);
                          AverageInitialSite.setValue(iFeatIndex,@eAverageSite);

                          if ControlRes^.fDumpAverageSite then
                             writeln(DebugFile,FloatToStr(eAverageSite) + ',' +
                                               FloatToStr(AFeat.rSumArea) + ',' +
                                               FloatToStr(AFeat.rExcluded) + ',' +
                                               IntToStr(ControlForm.Available.Items.Count +
                                                        ControlForm.Flagged.Items.Count) + ',' +
                                               IntToStr(ControlForm.Available.Items.Count +
                                                        ControlForm.Flagged.Items.Count +
                                                        ControlForm.R1.Items.Count +
                                                        ControlForm.R2.Items.Count +
                                                        ControlForm.R3.Items.Count +
                                                        ControlForm.R4.Items.Count +
                                                        ControlForm.R5.Items.Count +
                                                        ControlForm.Partial.Items.Count));
                     end
                     else
                     begin
                          if (ASite.status = _R1) or (ASite.status = _R2)
                              or (ASite.status = _R3) or (ASite.status = _R4) or (ASite.status = _R5)
                              or (ASite.status = Pd) then
                          begin
                               if fSummateOriginalAvailable then
                                  AFeat.rInitialAvailable := AFeat.rInitialAvailable +
                                                             Value.rAmount;
                               {summate areas within original Avialable sites}
                               AFeat.rSumArea:=AFeat.rSumArea + Value.rAmount;
                               AFeat.rAreaSqr := AFeat.rAreaSqr + sqr(Value.rAmount);
                               eAverageSite := (AFeat.rSumArea - AFeat.rExcluded)*1.0/(ControlForm.Available.Items.Count +
                                                                                       ControlForm.Flagged.Items.Count +
                                                                                       ControlForm.R1.Items.Count +
                                                                                       ControlForm.R2.Items.Count +
                                                                                       ControlForm.R3.Items.Count +
                                                                                       ControlForm.R4.Items.Count +
                                                                                       ControlForm.R5.Items.Count +
                                                                                       ControlForm.Partial.Items.Count);
                               AverageInitialSite.setValue(iFeatIndex,@eAverageSite);

                               if ControlRes^.fDumpAverageSite then
                                  writeln(DebugFile,IntToStr(ASite.iKey) + ',' +
                                                    IntToStr(iFeatIndex) + ',' +
                                                    ',' +
                                                    FloatToStr(eAverageSite) + ',' +
                                                    FloatToStr(AFeat.rSumArea) + ',' +
                                                    FloatToStr(AFeat.rExcluded) + ',' +
                                                    ',' +
                                                    IntToStr(ControlForm.Available.Items.Count +
                                                             ControlForm.Flagged.Items.Count +
                                                             ControlForm.R1.Items.Count +
                                                             ControlForm.R2.Items.Count +
                                                             ControlForm.R3.Items.Count +
                                                             ControlForm.R4.Items.Count +
                                                             ControlForm.R5.Items.Count +
                                                             ControlForm.Partial.Items.Count));
                          end
                          else
                          if (ASite.status = Re) then
                          begin
                               // summate areas within Reserved sites
                               AFeat.reservedarea := AFeat.reservedarea + Value.rAmount;
                          end;
                     end;
                     FeatArr.setValue(iFeatIndex,@AFeat);
                end;
        end;

        if ControlRes^.fDumpAverageSite then
           closefile(DebugFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in SparseTotalArea',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end; {procedure SparseTotalArea}


procedure IrrepStart;
begin
     StartCode:=1;

     FeatureList;
     TotalArea;

end; {Function IrrepStart}

procedure SparseMatrixStart;
var
   fSummateOriginalAvailable : boolean;
begin
     if (iActiveMinset < 1) then
        fSummateOriginalAvailable := True
     else
         fSummateOriginalAvailable := False;

     SparseTotalArea(fSummateOriginalAvailable);
end;


  {____________________________________________________________}


PROCEDURE InitialGetPercentage;
{Reads the overall target percentage for representation
 of features; calculates target area for each
 feature}
var
  a:integer;
  pFeat : featureoccurrencepointer;
begin
     try
        try
           rPercentage := RegionSafeStrToFloat(ControlForm.TargetPercent.Text);
        except
              rPercentage := rPercentage;
        end;
        {check if user has modified overall target percentage}

        new(pFeat);
        iZeroTrimmedTargetCount := 0;

        for a:=1 to iFeatureCount do
        begin
             FeatArr.rtnValue(a,pFeat);

             if ControlForm.UseFeatCutOffs.Checked then
             begin
                  pFeat^.targetarea := pFeat^.rCutOff;
             end
             else
                 pFeat^.targetarea:=pFeat^.totalarea*rPercentage/100;

             if (pFeat^.targetarea > pFeat^.totalarea) then
                pFeat^.targetarea := pFeat^.totalarea;
             {logic for multiple or single cut off points}

             if pFeat^.fRestrict then
                pFeat^.targetarea := 0;
             {restrict this target if selected by user}

             pFeat^.rTrimmedTarget := pFeat^.targetarea;
             pFeat^.rInitialTrimmedTarget := pFeat^.targetarea;

             if (pFeat^.rTrimmedTarget = 0) then
             begin
                  Inc(iZeroTrimmedTargetCount);
             end;

             FeatArr.setValue(a,pFeat);
        end;

        dispose(pFeat);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception calculating targets',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;

end; {procedure InitialGetPercentage}

{____________________________________________________________}



procedure GetExcManSel;
{find Excluded, Mandatory, Selected,
 Partial, Flagged sites}
var
   lCount, lSiteIndex,
   lCount2, lFeatIndex : longint;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   iSiteRichness, iGeocode,x : integer;
   fReserved : boolean;
   Value : ValueFile_T;
begin
     try
        new(pSite);
        new(pFeat);

        with ControlForm do
        begin
             try
             if (Available.Items.Count > 0) then
                for lCount := 0 to (Available.Items.Count-1) do
                begin
                     {Available site}
                     lSiteIndex := FindFeatMatch(OrdSiteArr,StrToInt(AvailableKey.Items.Strings[lCount]));

                     SiteArr.rtnValue(lSiteIndex,pSite);

                     pSite^.status := Av;
                     pSite^.rPCUSED := 0;
                     iSiteRichness := 0;

                     if (pSite^.richness > 0) then
                        for lCount2 := 1 to pSite^.richness do
                        begin
                             FeatureAmount.rtnValue(pSite^.iOffset + lCount2,@Value);
                             lFeatIndex := Value.iFeatKey;
                             FeatArr.rtnValue(lFeatIndex,pFeat);

                             if not pFeat^.fRestrict then
                                Inc(iSiteRichness);

                             pFeat^.rCurrentSumArea := pFeat^.rCurrentSumArea +
                                                       Value.rAmount;
                             pFeat^.rCurrentAreaSqr := pFeat^.rCurrentAreaSqr +
                                                       Sqr(Value.rAmount);
                             FeatArr.setValue(lFeatIndex,pFeat);
                        end;
                     SiteRichness.setValue(lSiteIndex,@iSiteRichness);
                     SiteArr.setValue(lSiteIndex,pSite);
                end;
             except
                   MessageDlg('Exception Av',mtInformation,[mbOk],0);
             end;

             try
             if (Excluded.Items.Count > 0) then
                for lCount := 0 to (Excluded.Items.Count-1) do
                begin
                     {excluded site}
                     lSiteIndex := FindFeatMatch(OrdSiteArr,StrToInt(ExcludedKey.Items.Strings[lCount]));

                     SiteArr.rtnValue(lSiteIndex,pSite);

                     pSite^.status := Ex;
                     pSite^.rPCUSED := 0;
                     iSiteRichness := 0;

                     if (pSite^.richness > 0) then
                        for lCount2 := 1 to pSite^.richness do
                        begin
                             {excluded feature at site}
                             FeatureAmount.rtnValue(pSite^.iOffset + lCount2,@Value);
                             lFeatIndex := Value.iFeatKey;
                             FeatArr.rtnValue(lFeatIndex,pFeat);

                             if not pFeat^.fRestrict then
                                Inc(iSiteRichness);

                             pFeat^.rExcluded := pFeat^.rExcluded + Value.rAmount;
                             FeatArr.setValue(lFeatIndex,pFeat);
                        end;
                     SiteRichness.setValue(lSiteIndex,@iSiteRichness);
                     SiteArr.setValue(lSiteIndex,pSite);
                end;
             except
                   MessageDlg('Exception Ex',mtInformation,[mbOk],0);
             end;

             try
             if (R1.Items.Count > 0) then
                for lCount := 0 to (R1.Items.Count-1) do
                begin
                     {negotiated site}
                     iGeocode := StrToInt(R1Key.Items.Strings[lCount]);
                     lSiteIndex := FindFeatMatch(OrdSiteArr,iGeocode);

                     SiteArr.rtnValue(lSiteIndex,pSite);

                     pSite^.rPCUSED := 0;
                     pSite^.status := _R1;
                     iSiteRichness := 0;

                     if (pSite^.richness > 0) then
                        for lCount2 := 1 to pSite^.richness do
                        begin
                             {negotiated feature at site}

                             FeatureAmount.rtnValue(pSite^.iOffset + lCount2,@Value);
                             lFeatIndex := Value.iFeatKey;
                             FeatArr.rtnValue(lFeatIndex,pFeat);
                             if not pFeat^.fRestrict then
                                Inc(iSiteRichness);

                             pFeat^.rDeferredArea := pFeat^.rDeferredArea + Value.rAmount;
                             pFeat^.rR1 := pFeat^.rR1 + Value.rAmount;
                             pFeat^.targetarea := pFeat^.targetarea - Value.rAmount;

                             FeatArr.setValue(lFeatIndex,pFeat);
                        end;
                     SiteRichness.setValue(lSiteIndex,@iSiteRichness);
                     SiteArr.setValue(lSiteIndex,pSite);
                end;
             except
                   MessageDlg('Exception R1',mtInformation,[mbOk],0);
             end;

             try
             if (R2.Items.Count > 0) then
                for lCount := 0 to (R2.Items.Count-1) do
                begin
                     {R2 site}
                     lSiteIndex := FindFeatMatch(OrdSiteArr,StrToInt(R2Key.Items.Strings[lCount]));

                     SiteArr.rtnValue(lSiteIndex,pSite);

                     pSite^.status := _R2;
                     pSite^.rPCUSED := 0;
                     iSiteRichness := 0;

                     if (pSite^.richness > 0) then
                        for lCount2 := 1 to pSite^.richness do
                        begin
                             {Mandatory feature at site}
                             FeatureAmount.rtnValue(pSite^.iOffset + lCount2,@Value);
                             lFeatIndex := Value.iFeatKey;
                             FeatArr.rtnValue(lFeatIndex,pFeat);
                             if not pFeat^.fRestrict then
                                Inc(iSiteRichness);
                             pFeat^.rDeferredArea := pFeat^.rDeferredArea + Value.rAmount;
                             pFeat^.rR2 := pFeat^.rR2 + Value.rAmount;
                             pFeat^.targetarea := pFeat^.targetarea - Value.rAmount;

                             FeatArr.setValue(lFeatIndex,pFeat);
                        end;
                     SiteRichness.setValue(lSiteIndex,@iSiteRichness);
                     SiteArr.setValue(lSiteIndex,pSite);
                end;
             except
                   MessageDlg('Exception R2',mtInformation,[mbOk],0);
             end;

             try
             if (R3.Items.Count > 0) then
                for lCount := 0 to (R3.Items.Count-1) do
                begin
                     lSiteIndex := FindFeatMatch(OrdSiteArr,StrToInt(R3Key.Items.Strings[lCount]));
                     SiteArr.rtnValue(lSiteIndex,pSite);
                     pSite^.status := _R3;
                     pSite^.rPCUSED := 0;
                     iSiteRichness := 0;
                     if (pSite^.richness > 0) then
                        for lCount2 := 1 to pSite^.richness do
                        begin
                             FeatureAmount.rtnValue(pSite^.iOffset + lCount2,@Value);
                             lFeatIndex := Value.iFeatKey;
                             FeatArr.rtnValue(lFeatIndex,pFeat);
                             if not pFeat^.fRestrict then
                                Inc(iSiteRichness);
                             pFeat^.rDeferredArea := pFeat^.rDeferredArea + Value.rAmount;
                             pFeat^.rR3 := pFeat^.rR3 + Value.rAmount;
                             pFeat^.targetarea := pFeat^.targetarea - Value.rAmount;
                             FeatArr.setValue(lFeatIndex,pFeat);
                        end;
                     SiteRichness.setValue(lSiteIndex,@iSiteRichness);
                     SiteArr.setValue(lSiteIndex,pSite);
                end;
             except
                   MessageDlg('Exception R3',mtInformation,[mbOk],0);
             end;

             try
             if (R4.Items.Count > 0) then
                for lCount := 0 to (R4.Items.Count-1) do
                begin
                     lSiteIndex := FindFeatMatch(OrdSiteArr,StrToInt(R4Key.Items.Strings[lCount]));
                     SiteArr.rtnValue(lSiteIndex,pSite);
                     pSite^.status := _R4;
                     pSite^.rPCUSED := 0;
                     iSiteRichness := 0;
                     if (pSite^.richness > 0) then
                        for lCount2 := 1 to pSite^.richness do
                        begin
                             FeatureAmount.rtnValue(pSite^.iOffset + lCount2,@Value);
                             lFeatIndex := Value.iFeatKey;
                             FeatArr.rtnValue(lFeatIndex,pFeat);
                             if not pFeat^.fRestrict then
                                Inc(iSiteRichness);
                             pFeat^.rDeferredArea := pFeat^.rDeferredArea + Value.rAmount;
                             pFeat^.rR4 := pFeat^.rR4 + Value.rAmount;
                             pFeat^.targetarea := pFeat^.targetarea - Value.rAmount;
                             FeatArr.setValue(lFeatIndex,pFeat);
                        end;
                     SiteRichness.setValue(lSiteIndex,@iSiteRichness);
                     SiteArr.setValue(lSiteIndex,pSite);
                end;
             except
                   MessageDlg('Exception R4',mtInformation,[mbOk],0);
             end;

             try
             if (R5.Items.Count > 0) then
                for lCount := 0 to (R5.Items.Count-1) do
                begin
                     lSiteIndex := FindFeatMatch(OrdSiteArr,StrToInt(R5Key.Items.Strings[lCount]));
                     SiteArr.rtnValue(lSiteIndex,pSite);
                     pSite^.status := _R5;
                     pSite^.rPCUSED := 0;
                     iSiteRichness := 0;
                     if (pSite^.richness > 0) then
                        for lCount2 := 1 to pSite^.richness do
                        begin
                             FeatureAmount.rtnValue(pSite^.iOffset + lCount2,@Value);
                             lFeatIndex := Value.iFeatKey;
                             FeatArr.rtnValue(lFeatIndex,pFeat);
                             if not pFeat^.fRestrict then
                                Inc(iSiteRichness);
                             pFeat^.rDeferredArea := pFeat^.rDeferredArea + Value.rAmount;
                             pFeat^.rR5 := pFeat^.rR5 + Value.rAmount;
                             pFeat^.targetarea := pFeat^.targetarea - Value.rAmount;
                             FeatArr.setValue(lFeatIndex,pFeat);
                        end;
                     SiteRichness.setValue(lSiteIndex,@iSiteRichness);
                     SiteArr.setValue(lSiteIndex,pSite);
                end;
             except
                   MessageDlg('Exception R5',mtInformation,[mbOk],0);
             end;

             try
             if (Partial.Items.Count > 0) then
                for lCount := 0 to (Partial.Items.Count-1) do
                begin
                     {Partial site}
                     lSiteIndex := FindFeatMatch(OrdSiteArr,StrToInt(PartialKey.Items.Strings[lCount]));

                     SiteArr.rtnValue(lSiteIndex,pSite);

                     pSite^.status := Pd;
                     pSite^.rPCUSED := 0;
                     iSiteRichness := 0;

                     if (pSite^.richness > 0) then
                        for lCount2 := 1 to pSite^.richness do
                        begin
                             // determine if this feature is reserved at this site
                             SparsePartial.rtnValue(pSite^.iOffset + lCount2,@fReserved);

                             if fReserved then
                             begin
                                  {this feature is deferred at this site}
                                  FeatureAmount.rtnValue(pSite^.iOffset + lCount2,@Value);
                                  lFeatIndex := Value.iFeatKey;
                                  FeatArr.rtnValue(lFeatIndex,pFeat);
                                  if not pFeat^.fRestrict then
                                     Inc(iSiteRichness);
                                  pFeat^.rDeferredArea := pFeat^.rDeferredArea + Value.rAmount;
                                  pFeat^.rPartial := pFeat^.rPartial + Value.rAmount;
                                  // adjust target for this feature which is reserved at this site
                                  pFeat^.targetarea := pFeat^.targetarea - Value.rAmount;
                                  FeatArr.setValue(lFeatIndex,pFeat);
                             end
                             else
                             begin
                                  {this feature is not deferred at this site}
                                  FeatureAmount.rtnValue(pSite^.iOffset + lCount2,@Value);
                                  lFeatIndex := Value.iFeatKey;
                                  FeatArr.rtnValue(lFeatIndex,pFeat);
                                  if not pFeat^.fRestrict then
                                     Inc(iSiteRichness);
                                  pFeat^.rCurrentSumArea := pFeat^.rCurrentSumArea +
                                                            Value.rAmount;
                                  pFeat^.rCurrentAreaSqr := pFeat^.rCurrentAreaSqr +
                                                            Sqr(Value.rAmount);
                                  // adjust target for this feature which is not reserved at this site
                                  // pFeat^.targetarea := pFeat^.targetarea + Value.rAmount;
                                  FeatArr.setValue(lFeatIndex,pFeat);
                             end;
                        end;
                     SiteRichness.setValue(lSiteIndex,@iSiteRichness);
                     SiteArr.setValue(lSiteIndex,pSite);
                end;
             except
                   MessageDlg('Exception Pd',mtInformation,[mbOk],0);
             end;

             try
             if (Flagged.Items.Count > 0) then
                for lCount := 0 to (Flagged.Items.Count-1) do
                begin
                     {Flagged site}
                     lSiteIndex := FindFeatMatch(OrdSiteArr,StrToInt(FlaggedKey.Items.Strings[lCount]));

                     SiteArr.rtnValue(lSiteIndex,pSite);

                     pSite^.status := Fl;
                     pSite^.rPCUSED := 0;
                     iSiteRichness := 0;

                     if (pSite^.richness > 0) then
                        for lCount2 := 1 to pSite^.richness do
                        begin
                             {Flagged feature at site}
                             FeatureAmount.rtnValue(pSite^.iOffset + lCount2,@Value);
                             lFeatIndex := Value.iFeatKey;
                             FeatArr.rtnValue(lFeatIndex,pFeat);
                             if not pFeat^.fRestrict then
                                Inc(iSiteRichness);

                             pFeat^.rCurrentSumArea := pFeat^.rCurrentSumArea +
                                                       Value.rAmount;
                             pFeat^.rCurrentAreaSqr := pFeat^.rCurrentAreaSqr +
                                                       Sqr(Value.rAmount);
                             FeatArr.setValue(lFeatIndex,pFeat);
                        end;
                     SiteRichness.setValue(lSiteIndex,@iSiteRichness);
                     SiteArr.setValue(lSiteIndex,pSite);
                end;
             except
                   MessageDlg('Exception Fl',mtInformation,[mbOk],0);
             end;
        end;

        dispose(pSite);
        dispose(pFeat);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetExcManSel',mtError,[mbOk],0);
     end;

end; {of Procedure GetManExc}

procedure CountReservedArea;
var
   iGeocode, iCount, iSite, iCount2, iFeat : integer;
   ASite : site;
   AFeat : featureoccurrence;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     try
        {find total area within reserved sites}
        if (ControlForm.Reserved.Items.Count > 0) then
           for iCount := 1 to ControlForm.Reserved.Items.Count do
           begin
                iGeocode := StrToInt(ControlForm.ReservedKey.Items.Strings[iCount-1]);

                {find this geocode in the SiteArr}
                iSite := FindFeatMatch(OrdSiteArr,iGeocode);
                SiteArr.rtnValue(iSite,@ASite);

                if (ASite.richness > 0) then
                   for iCount2 := 1 to ASite.richness do
                   begin
                        {$IFDEF SPARSE_MATRIX}
                        FeatureAmount.rtnValue(ASite.iOffset + iCount2,@Value);
                        iFeat := Value.iFeatKey;
                        {$ELSE}
                        iFeat := FindFeature(ASite.feature[iCount2]);
                        {$ENDIF}
                        FeatArr.rtnValue(iFeat,@AFeat);
                        {$IFDEF SPARSE_MATRIX}
                        AFeat.reservedarea := AFeat.reservedarea + Value.rAmount;
                        {$ELSE}
                        AFeat.reservedarea := AFeat.reservedarea + ASite.featurearea[iCount2];
                        {$ENDIF}
                        FeatArr.setValue(iFeat,@AFeat);
                   end;
           end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CountReservedArea',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure InitialTrimFeatTargets;
var
   iGeocode, iCount, iSite, iCount2, iFeat : integer;
   ASite : site;
   AFeat : featureoccurrence;
begin
     try

     {trim feature targets to rSumArea}
     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,@AFeat);

          AFeat.targetarea := AFeat.targetarea - AFeat.reservedarea;

          if (AFeat.targetarea > AFeat.rSumArea) then
             AFeat.targetarea := AFeat.rSumArea;

          AFeat.rInitialAvailableTarget := AFeat.targetarea;

          AFeat.iOrdinalClass := 0;

          FeatArr.setValue(iCount,@AFeat);
     end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in InitialTrimFeatTargets',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

{$IFNDEF SPARSE_MATRIX_2}
function FindContribSite(const iGeocode : integer) : integer;
var
   ASCust : SiteCust_T;
   iCount : integer;
begin
     Result := -1;
     iCount := 1;

     repeat
           GraphContribution.Sites.rtnValue(iCount,@ASCust);
           if (iGeocode = ASCust.iCode) then
              Result := iCount;

           Inc(iCount);

     until (Result > 0)
     or (iCount > GraphContribution.Sites.lMaxSize);

     if (Result = -1) then
        MessageDlg('FindContribSite cannot find requested site',mtError,[mbOk],0);
end;
{$ENDIF}

{$IFNDEF SPARSE_MATRIX_2}
procedure CalcPartialValues;
var
   ASite : site;
   AFeat : featureoccurrence;
   iSIdx, iFIdx, iContribIdx, iCount, iFCount : integer;
   rNewValue : extended;

   AFCust : FeatureCust_T;
   Value : ValueFile_T;
   fReserved : boolean;
begin
     try
        with ControlForm do
            if (Partial.Items.Count > 0) then
               for iCount := 0 to (PartialKey.Items.Count-1) do
               begin
                    iSIdx := FindFeatMatch(OrdSiteArr,StrToInt(PartialKey.Items.Strings[iCount]));
                    SiteArr.rtnValue(iSIdx,@ASite);

                    if (ASite.richness > 0) then
                    begin
                         iContribIdx := FindContribSite(ASite.iKey);
                         if (iContribIdx > 0) then
                         begin
                              GraphContribution.Features.rtnValue(iContribIdx,@AFCust);

                              for iFCount := 1 to ASite.richness do
                              begin
                                   SparsePartial.rtnValue(ASite.iOffset + iFCount,@fReserved);
                                   if not fReserved then
                                   begin
                                        FeatureAmount.rtnValue(ASite.iOffset + iFCount,@Value);
                                        iFIdx := Value.iFeatKey;
                                        FeatArr.rtnValue(iFIdx,@AFeat);

                                        if (AFeat.targetarea > 0) then
                                           rNewValue := Value.rAmount /
                                                        AFeat.targetarea * 100
                                        else
                                            rNewValue := 0;

                                        AFCust.rValue[iFCount] := rNewValue
                                   end;
                              end;

                              GraphContribution.Features.setValue(iContribIdx,@AFCust);
                         end
                         else
                             MessageDlg('CalcPartialValues index beyond range GraphContribution.Feature',mtError,[mbOk],0);
                    end;
               end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Calculate Partial Reserve Values',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;
{$ENDIF}



procedure TrimFeatTargets(const fShowProgress : boolean);
var
   iNumContrib : integer;
begin
     try
        with ControlForm do
        begin
             DumpMemInfo('before Build LogList');

             iPCUSEDCutOff := LoadPCUSEDCutOff;                  
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TrimFeatTargets',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

PROCEDURE InitDefExcSum;
{}
var
  iCount, iFCount, iFeat : integer;

  ASite : site;
  AFeat : featureoccurrence;
  {$IFDEF DEBUG_INITDEFEXCSUM}
  DebugFile : TextFile;
  {$ENDIF}

begin
     {$IFDEF DEBUG_INITDEFEXCSUM}
     assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\debug_initdefexcsum.csv');
     rewrite(DebugFile);
     writeln(DebugFile,'FName,FKey,FTarg');
     {$ENDIF}
     for iFCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iFCount,@AFeat);

          //AFeat.rTrimmedArea := 0;
          AFeat.rDeferredArea := 0;
          AFeat.rExcluded := 0;
          AFeat.rCurrentSumArea := 0;
          AFeat.rCurrentAreaSqr := 0;

          AFeat.rR1 := 0;
          AFeat.rR2 := 0;
          AFeat.rR3 := 0;
          AFeat.rR4 := 0;
          AFeat.rR5 := 0;
          AFeat.rPartial := 0;

          AFeat.targetarea := AFeat.rInitialAvailableTarget;

          {$IFDEF DEBUG_INITDEFEXCSUM}
          writeln(DebugFile,AFeat.sID + ',' +
                            IntToStr(AFeat.code) + ',' +
                            FloatToStr(AFeat.targetarea));
          {$ENDIF}

          FeatArr.setValue(iFCount,@AFeat);
     end;
     {$IFDEF DEBUG_INITDEFEXCSUM}
     closefile(DebugFile);
     {$ENDIF}
end;

PROCEDURE Set_CET;
{}
var
  iCount : integer;
  AFeat : featureoccurrence;
  rUnReachable : extended;
  {$IFDEF DEBUG_CET}
  BeforeFile, AfterFile : TextFile;
  {$ENDIF}
begin
     {set current effective target for features so we can calculate contribution of available
      features at partly deferred sites}

     {$IFDEF DEBUG_CET}
     assignfile(BeforeFile,ControlRes^.sWorkingDirectory + '\before_Set_CET.csv');
     assignfile(AfterFile,ControlRes^.sWorkingDirectory + '\after_Set_CET.csv');
     rewrite(BeforeFile);
     rewrite(AfterFile);
     writeln(BeforeFile,'FName,FKey,OriginalEffectiveTarget,DeferredArea,CurrentSumArea,UnReachable,CurrentEffTarg');
     writeln(AfterFile,'FName,FKey,OriginalEffectiveTarget,DeferredArea,CurrentSumArea,UnReachable,CurrentEffTarg');
     {$ENDIF}

     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,@AFeat);

          // dump values to debug before adjusting CET
          {$IFDEF DEBUG_CET}
          writeln(BeforeFile,AFeat.sID + ',' +
                             IntToStr(AFeat.code) + ',' +
                             FloatToStr(AFeat.rInitialAvailableTarget) + ',' +
                             FloatToStr(AFeat.rDeferredArea) + ',' +
                             FloatToStr(AFeat.rCurrentSumArea) + ',' +
                             FloatToStr(rUnReachable) + ',' +
                             FloatToStr(AFeat.rCurrentEffTarg));
          {$ENDIF}

          {determine whether exclusions make orig.eff.targ unreachable}
          if ((AFeat.rInitialAvailableTarget - AFeat.rDeferredArea) > AFeat.rCurrentSumArea) then
             rUnReachable := AFeat.rInitialAvailableTarget - AFeat.rDeferredArea - AFeat.rCurrentSumArea
          else
              rUnReachable := 0;

          {rUnReachable is amount target has to be reduced because of exclusions}

          AFeat.rCurrentEffTarg := AFeat.rInitialAvailableTarget - AFeat.rDeferredArea - rUnReachable;

          // dump values to debug after adjusting CET
          {$IFDEF DEBUG_CET}
          writeln(AfterFile,AFeat.sID + ',' +
                            IntToStr(AFeat.code) + ',' +
                            FloatToStr(AFeat.rInitialAvailableTarget) + ',' +
                            FloatToStr(AFeat.rDeferredArea) + ',' +
                            FloatToStr(AFeat.rCurrentSumArea) + ',' +
                            FloatToStr(rUnReachable)+ ',' +
                             FloatToStr(AFeat.rCurrentEffTarg));
          {$ENDIF}

          FeatArr.setValue(iCount,@AFeat);
     end;

     {$IFDEF DEBUG_CET}
     closefile(BeforeFile);
     closefile(AfterFile);
     {$ENDIF}

end;

PROCEDURE InitialAvailSum;
{Calculates the total feature area within Available sites}
var
   iCount, iFCount, iFeat, x : integer;
   ASite : site;
   AFeat : featureoccurrence;
   eAverageSite : extended;
   Value : ValueFile_T;
begin
     eAverageSite := 0;

     for iFCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iFCount,@AFeat);
          //AFeat.rTrimmedArea := 0;
          AFeat.rSumArea := 0;
          AFeat.rCurrentSumArea := 0;
          AFeat.rCurrentAreaSqr := 0;
          AFeat.rAreaSqr := 0;
          AFeat.rExcluded := 0;
          AFeat.reservedarea := 0;

          FeatArr.setValue(iFCount,@AFeat);
          AverageSite.setValue(iFCount,@eAverageSite);
          //AverageInitialSite.setValue(iFCount,@eAverageSite);
     end;

     for iCount := 1 to iSiteCount do
     begin
          SiteArr.rtnValue(iCount,@ASite);

          if ((ASite.status <> Ig) and (ASite.status <> Re))
          and (ASite.richness > 0) then
              for iFCount := 1 to ASite.richness do
              begin
                   FeatureAmount.rtnValue(ASite.iOffset + iFCount,@Value);
                   iFeat := Value.iFeatKey;
                   FeatArr.rtnValue(iFeat,@AFeat);

                   AFeat.rSumArea:=AFeat.rSumArea + Value.rAmount;
                   AFeat.rCurrentSumArea := AFeat.rCurrentSumArea + Value.rAmount;
                   AFeat.rAreaSqr := AFeat.rAreaSqr + sqr(Value.rAmount);
                   AFeat.rCurrentAreaSqr := AFeat.rCurrentAreaSqr + sqr(Value.rAmount);
                   if (ControlForm.Available.Items.Count+ControlForm.Flagged.Items.Count) > 0 then
                      eAverageSite := AFeat.rSumArea*1.0/(ControlForm.Available.Items.Count+
                                                     ControlForm.Flagged.Items.Count)
                   else
                       eAverageSite := AFeat.rSumArea;
                   {keeps updating this value as rSumArea and rAreaSqr
                    for each feature are incremented}

                   AverageSite.setValue(iFeat,@eAverageSite);
                   //AverageInitialSite.setValue(iFeat,@eAverageSite);
                   FeatArr.setValue(iFeat,@AFeat);
              end;
     end;

end; {procedure InitialAvailSum}

{$IFNDEF SPARSE_MATRIX_2}
function FindSiteInContrib(const iGeocode : integer) : integer;
{returns 0 if site not found in GraphContribution.Sites
 else returns index to site (> 0)}
var
   iCount : integer;
   fFound : boolean;
   pCustSite : ^SiteCust_T;
begin
     Result := 0;
     iCount := 1;
     fFound := False;
     new(pCustSite);

     with GraphContribution.Sites do
          if (lMaxSize > 0) then
             repeat
                   rtnValue(iCount,pCustSite);

                   if (pCustSite^.iCode = iGeocode) then
                   begin
                        Result := iCount;
                        fFound := True;
                   end;

                   Inc(iCount);

             until fFound or (iCount > lMaxSize);

     dispose(pCustSite);
end;

procedure MapPCUSED2Array;
var
   iCount,iSiteIndex : integer;
   ASite : site;
   ACustSite : SiteCust_T;
   fDebug, fFail : boolean;
begin
     fFail := True;

     if (GraphContribution.Sites <> nil) then
        for iCount := 1 to GraphContribution.Sites.lMaxSize do
        begin
             GraphContribution.Sites.rtnValue(iCount,@ACustSite);

             iSiteIndex := FindFeatMatch(OrdSiteArr,ACustSite.iCode);

             if (iSiteIndex > 0) then
             begin
                  SiteArr.rtnValue(iSiteIndex,@ASite);

                  if (ACustSite.iCode = ASite.iKey) then
                  begin
                       ASite.rPCUSED := ACustSite.rPercentUsed;

                       if (ASite.rPCUSED > 100) then
                          ASite.rPCUSED := 0;

                       SiteArr.setValue(iSiteIndex,@ASite);

                       fFail := False;
                  end
                  else
                      fDebug := True; 
             end;
        end;

     if fFail then
        MessageDlg('MapPCUSED2Array failed',mtError,[mbOk],0);
end;
{$ENDIF}

PROCEDURE DeferredSum;
var
   iCount, iFCount, iFeat : integer;
   ASite : site;
   AFeat : featureoccurrence;
   Value : ValueFile_T;
   fReserved : boolean;
begin
     for iCount := 1 to iSiteCount do
     begin
          SiteArr.rtnValue(iCount,@ASite);
          if ((ASite.status = _R1)
              or (ASite.status = _R2)
              or (ASite.status = _R3)
              or (ASite.status = _R4)
              or (ASite.status = _R5)
              or (ASite.status = Pd))
          and (ASite.richness > 0) then
              for iFCount := 1 to ASite.richness do
              begin
                   SparsePartial.rtnValue(ASite.iOffset + iFCount,@fReserved);
                   if (ASite.status = Pd)
                   and not fReserved then
                   begin
                        {this feature is available at this site}
                   end
                   else
                   begin
                        FeatureAmount.rtnValue(ASite.iOffset + iFCount,@Value);
                        iFeat := Value.iFeatKey;
                        FeatArr.rtnValue(iFeat,@AFeat);

                        AFeat.rDeferredArea:=AFeat.rDeferredArea + Value.rAmount;

                        FeatArr.setValue(iFeat,@AFeat);
                   end;
              end;
     end;

     {look for all occurrences of each feature in the
      'Deferred' (Negotiated, Mandatory and Partly Deferred) sites and
      accumulate the area of each}

end; {procedure DeferredSum}

PROCEDURE ExcludedSum;
var
   iCount, iFCount, iFeat : integer;
   ASite : site;
   AFeat : featureoccurrence;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     for iCount := 1 to iSiteCount do
     begin
          SiteArr.rtnValue(iCount,@ASite);

          if (ASite.status = Ex)
          and (ASite.richness > 0) then
              for iFCount := 1 to ASite.richness do
              begin
                   FeatureAmount.rtnValue(ASite.iOffset + iFCount,@Value);
                   iFeat := Value.iFeatKey;
                   FeatArr.rtnValue(iFeat,@AFeat);

                   AFeat.rExcluded:=AFeat.rExcluded + Value.rAmount;

                   FeatArr.setValue(iFeat,@AFeat);
              end;
     end;

     {look for all occurrences of each feature in the
      'Deferred' (Selected and Mandatory) sites and
      accumulate the area of each}

end; {procedure ExcludedSum}


procedure RePrepIrrepData;
begin
     InitialGetPercentage;
     InitialTrimFeatTargets;

     InitDefExcSum;
     GetExcManSel;
end;

procedure DumpAverageSite(pred_comb : Array_t);
var
   iCount : integer;
   dValue, dPredComb : extended;
   ErrFile : text;
   pFeat : featureoccurrencepointer;
begin
     AssignFile(ErrFile,ControlRes^.sWorkingDirectory + '\sd.csv');
     Rewrite(ErrFile);
     writeln(ErrFile,'Feature Key,Simon Data Value,Predicted Comb Value');
     new(pFeat);
     for iCount := 1 to iFeatureCount do
     begin
          AverageSite.rtnValue(iCount,@dValue);
          FeatArr.rtnValue(iCount,pFeat);
          pred_comb.rtnValue(iCount,@dPredComb);
          writeln(ErrFile,IntToStr(pFeat^.code) + ',' +
                          FloatToStr(dValue) + ',' +
                          FloatToStr(dPredComb));
     end;
     dispose(pFeat);
     Closefile(ErrFile);
end;

procedure InitialPrepIrrepData;
begin
     try
        InitialAvailSum;

        InitialGetPercentage;

        CountReservedArea;

        InitialTrimFeatTargets;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception during initial preperation of data',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

{
procedure DumpFeatures(const sId : string);
var
   AFeat : featureoccurrence;
   iCount : integer;
   OutFile : TextFile;
begin
     assignfile(OutFile,ControlRes^.sWorkingDirectory + '\' + sId + 'dumpfeatures.csv');
     rewrite(OutFile);
     writeln(OutFile,'FName,FKey,FTarget');

     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,@AFeat);
          writeln(OutFile,AFeat.sID + ',' +
                          IntToStr(AFeat.code) + ',' +
                          FloatToStr(AFeat.targetarea));
     end;

     closefile(OutFile);
end;
}

procedure ReduceTargetByExclustions;
var
   iCount : integer;
   pFeat : featureoccurrencepointer;
begin
     new(pFeat);

     // we need to reduce the available target to take exclustions into account
     // ie. if (available target > 0)
     //     and (available target > available) then
     //         available target = available
     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,pFeat);

          if (pFeat^.targetarea > 0)
          and (pFeat^.targetarea > pFeat^.rCurrentSumArea) then
          begin
               pFeat^.targetarea := pFeat^.rCurrentSumArea;
               FeatArr.setValue(iCount,pFeat);
          end;
     end;

     dispose(pFeat);
end;

procedure PrepIrrepData(const fNoProgressUpdate : boolean); {to be called by Simons Irreplacability algorithm}
{called by Simon Ferrier's irreplacability algorithm to
 set up fresh data structures for an irreplacability run}
begin
     fContrDataDone := True;
     fContrDoneOnce := True;

     // we need to reduce the available target to take exclustions into account
     // ie. if (available target > 0)
     //     and (available target > available) then
     //         available target = available
     ReduceTargetByExclustions;
end;

{____________________________________________________________}

end.
