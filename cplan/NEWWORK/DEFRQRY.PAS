unit Defrqry;

{$I \SOFTWARE\cplan\cplan\STD_DEF.PAS}

{$define DEVELOP}
interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, em_newu1, {defrfl,} StdCtrls, Menus, Grids, ExtCtrls,
  {$IFDEF bit16}
  Arrayt16, Cpng_imp;
  {$ELSE}
  ds, Dll_u1;
  {$ENDIF}

type
  TDeferral_Query = class(TForm)
    Panel1: TPanel;
    OK: TButton;
    btnRemoveSite: TButton;
    checkWatchUnDef: TCheckBox;
    PopupRemove: TPopupMenu;
    PopupAccept: TPopupMenu;
    ThisSite1: TMenuItem;
    RemainingSites1: TMenuItem;
    ThisSite2: TMenuItem;
    RemainingSites2: TMenuItem;
    AllSitesincludepreviousAccepts1: TMenuItem;
    btnOk: TButton;
    btnCancel: TButton;
    AGrid: TStringGrid;
    BGrid: TStringGrid;
    procedure OKClick(Sender: TObject);
    procedure btnRemoveSiteClick(Sender: TObject);
    procedure ThisSite1Click(Sender: TObject);
    procedure RemainingSites1Click(Sender: TObject);
    procedure ThisSite2Click(Sender: TObject);
    procedure RemainingSites2Click(Sender: TObject);
    procedure AllSitesincludepreviousAccepts1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PrepShowCulm;
    procedure btnOkClick(Sender: TObject);
    procedure checkWatchUnDefClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  MetaCuml_T = record
      FeatRef : integer;
      FailAmt : extended;
  end;

(*procedure defrqryInit;*)
{  This function is a semi blank stub designed for test purposes only - the hard
wired geocodes used for the subsequent functions can be built and passed within
this stub.}

{3a}procedure TestToUnDeferSites(var ProposedGeoCodes : array_t);
    {  Examines an array_t of geocodes representing sites that have already been
    deferred.  Then tabulate results with respect to features that would, as a
    result, no longer achieve target.
       Returns user choices}

{3b}(*function ProposeReplacementSites(ProposedGeoCodes : array_t;
                                     const fShowSites : boolean) : array_t;*)
    {  Propose GeoCodes for replacement following operation on
    "ProposedGeoCodes".}
{3c}procedure RedundancyCheck(DeferredGeoCodes : array_t; switch : integer);
    {  highlights sites that may be dropped depending on a given
    "switch".}
{3e}function WhyImpFeat(Degree : integer; ImpFeats : array_t) : array_t;
    {  Rtns the GeoCodes containing feature(s) ("ImpFeats") that were met to the
    given "Degree" _> expressed as a percentage.}
var
   Deferral_Query: TDeferral_Query; {The output/test form}
   CurrentDefRef : integer;         {An obsolete counter ?}

   iTestResult, iFailByCount, iFurtherFailByCount : integer;


implementation

{$R *.DFM}

uses
    control{So we have featarr and sitearr},
    choices{Giving us the ability to update the reasoning box},
    global {For the max # of features},
    Highligh, Contribu, Dbmisc, Opt1,
    Lookup, Sct_grid, Sql_unit, Sf_irrep,
    Exclqry,
    Toolmisc, partl_ed;


procedure TDeferral_Query.PrepShowCulm;
begin
     OK.Visible := False;
     btnRemoveSite.Visible := False;
     checkWatchUnDef.Visible := False;

     btnOk.Visible := True;
     btnCancel.Visible :=  True;
end;

function ScanFeatures(SiteGeoCode : integer;
                      var aUserSelectSites : Array_t;
                      var iUserSiteCount : integer) : integer;
{
 The purpose of the function is to display a variety of messages wrt Feature
 failure and site exclusion.
}
var
   x,y : integer;
   testSite : site;
   AFeat : featureoccurrence;
   flag, fUseSite, fConsiderFeature, fReserved : boolean;
   iTest, iLineCount,
   iColCount, iRowCount : integer;
   sLine : string;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}

   function UserChooseSite : boolean;
   begin
        Result := False;

        Deferral_Query.ShowModal;

        if (iTestResult = TEST_ACCEPT_THIS) then
           Result := True;
   end;

begin
     Result := 0;
     fUseSite := True;

     iTestResult := TEST_ACCEPT_THIS;

     {Get the Site Data}
     SiteArr.rtnValue(findIntegerMatch(OrdSiteArr,SiteGeoCode),@testSite);

     {init the 'Fails By' grid for user to edit choices}
     Deferral_Query.AGrid.ColCount := 5;
     Deferral_Query.AGrid.RowCount := 2;
     Deferral_Query.AGrid.Cells[0,0] := 'Site ' + FindSiteName(testSite.iKey);
     {init the 'Further Fails By' grid for user to edit choices}
     Deferral_Query.BGrid.ColCount := 5;
     Deferral_Query.BGrid.RowCount := 1;

     iFailByCount := 0;
     iFurtherFailByCount := 0;

     {Over all Possible Features}
     if (testSite.richness > 0) then
     for x := 1 to testSite.richness do
     begin
          fConsiderFeature := True;
          if (testSite.status = Pd) then
          begin
               SparsePartial.rtnValue(testSite.iOffset + x,@fReserved);
               if not fReserved then
                  fConsiderFeature := False;
          end;

          if fConsiderFeature then
          begin
               {Get the appropriate data reference}
               {$IFDEF SPARSE_MATRIX}
               FeatureAmount.rtnValue(testSite.iOffset + x,@Value);
               iTest := findIntegerMatch(OrdFeatArr,Value.iFeatKey);
               {$ELSE}
               iTest := findIntegerMatch(OrdFeatArr,testSite.feature[x]);
               {$ENDIF}

               if (iTest <= 0) then
               begin
                    MessageDlg('error in ScanFeatures',mtError,[mbOk],0);
               end;

               FeatArr.rtnValue(iTest,@AFeat);

               {Is the target met?}
               if (aFeat.TargetArea <= 0) then
               {True}
               begin
                    {If x is part of the features in this site}
                    flag := false;
                    for y := 1 to testSite.richness do
                    begin
                         {$IFDEF SPARSE_MATRIX}
                         FeatureAmount.rtnValue(testSite.iOffset + y,@Value);
                         if aFeat.Code = Value.iFeatKey then
                         {$ELSE}
                         if aFeat.Code = testSite.feature[y] then
                         {$ENDIF}
                         begin
                              flag := true;
                              break;
                         end;
                    end;

                    {If the feature exists in this site and it's nonDeferral would cause a target,
                     that once had been achieved ,to now fail then display a message}
                    {$IFDEF SPARSE_MATRIX}
                    FeatureAmount.rtnValue(testSite.iOffset + x,@Value);
                    if flag
                    and ((AFeat.rDeferredArea - Value.rAmount) <
                    {$ELSE}
                    if flag
                    and ((AFeat.rDeferredArea - TestSite.FeatureArea[x]) <
                    {$ENDIF}
                         AFeat.rInitialAvailableTarget) then
                    begin
                         Deferral_Query.AGrid.RowCount := Deferral_Query.AGrid.RowCount + 1;

                         Deferral_Query.AGrid.Cells[0,(Deferral_Query.AGrid.RowCount - 1)] := AFeat.sID;

                         Deferral_Query.AGrid.Cells[1,(Deferral_Query.AGrid.RowCount - 1)] :=
                             TrimFloatForGrid(AFeat.rInitialAvailableTarget);

                         {$IFDEF SPARSE_MATRIX}
                         Deferral_Query.AGrid.Cells[2,(Deferral_Query.AGrid.RowCount - 1)] :=
                             TrimFloatForGrid((Value.rAmount/AFeat.rDeferredArea)*100);
                         Deferral_Query.AGrid.Cells[3,(Deferral_Query.AGrid.RowCount - 1)] :=
                             TrimFloatForGrid(Value.rAmount);
                         Deferral_Query.AGrid.Cells[4,(Deferral_Query.AGrid.RowCount - 1)] :=
                             TrimFloatForGrid(AFeat.rInitialAvailableTarget -
                                               (AFeat.rDeferredArea - Value.rAmount));
                         {$ELSE}
                         Deferral_Query.AGrid.Cells[2,(Deferral_Query.AGrid.RowCount - 1)] :=
                             TrimFloatForGrid((TestSite.FeatureArea[x]/AFeat.rDeferredArea)*100);
                         Deferral_Query.AGrid.Cells[3,(Deferral_Query.AGrid.RowCount - 1)] :=
                             TrimFloatForGrid(TestSite.FeatureArea[x]);
                         Deferral_Query.AGrid.Cells[4,(Deferral_Query.AGrid.RowCount - 1)] :=
                             TrimFloatForGrid(AFeat.rInitialAvailableTarget -
                                               (AFeat.rDeferredArea - TestSite.FeatureArea[x]));
                         {$ENDIF}
                         Inc(iFailByCount);
                    end;
               end
               else
               {If target Not met}
               begin
                    {Test to see if it exists in this site}
                    flag := false;
                    for y := 1 to testSite.richness do
                    begin
                         {$IFDEF SPARSE_MATRIX}
                         FeatureAmount.rtnValue(testSite.iOffset + y,@Value);
                         if aFeat.code = Value.iFeatKey then
                         {$ELSE}
                         if aFeat.Code = testSite.feature[y] then
                         {$ENDIF}
                         begin
                              flag := true;
                              break;
                         end;
                    end;

                    {Feature exists in Site}
                    if flag then
                    begin
                         Inc(iFurtherFailByCount);

                         Deferral_Query.BGrid.RowCount := Deferral_Query.BGrid.RowCount + 1;

                         Deferral_Query.BGrid.Cells[0,(Deferral_Query.BGrid.RowCount-1)] := AFeat.sID;

                         Deferral_Query.BGrid.Cells[1,(Deferral_Query.BGrid.RowCount-1)] :=
                            TrimFloatForGrid(AFeat.rInitialAvailableTarget);

                         {$IFDEF SPARSE_MATRIX}
                         FeatureAmount.rtnValue(testSite.iOffset + x,@Value);
                         Deferral_Query.BGrid.Cells[2,(Deferral_Query.BGrid.RowCount-1)] :=
                             TrimFloatForGrid((Value.rAmount/AFeat.rDeferredArea)*100);
                         Deferral_Query.BGrid.Cells[3,(Deferral_Query.BGrid.RowCount-1)] :=
                             TrimFloatForGrid(Value.rAmount);
                         Deferral_Query.BGrid.Cells[4,(Deferral_Query.BGrid.RowCount-1)] :=
                             TrimFloatForGrid(AFeat.rInitialAvailableTarget -
                                              (AFeat.rDeferredArea - Value.rAmount));
                         {$ELSE}
                         Deferral_Query.BGrid.Cells[2,(Deferral_Query.BGrid.RowCount-1)] :=
                             TrimFloatForGrid((TestSite.FeatureArea[x]/AFeat.rDeferredArea)*100);
                         Deferral_Query.BGrid.Cells[3,(Deferral_Query.BGrid.RowCount-1)] :=
                             TrimFloatForGrid(TestSite.FeatureArea[x]);
                         Deferral_Query.BGrid.Cells[4,(Deferral_Query.BGrid.RowCount-1)] :=
                             TrimFloatForGrid(AFeat.rInitialAvailableTarget -
                                              (AFeat.rDeferredArea - TestSite.FeatureArea[x]));
                         {$ENDIF}
                    end
                    else
                    begin
                         {Feature Doesn't exist in Site}
                    end;

               end;
          end;

     end;


     if (Deferral_Query.AGrid.RowCount > 2) then
     begin
          Deferral_Query.AGrid.FixedRows := 2;

          Deferral_Query.AGrid.Cells[0,1] := 'Features';
          Deferral_Query.AGrid.Cells[1,1] := 'Orig. Eff. Target';
          Deferral_Query.AGrid.Cells[2,1] := '% of Total Deferred';
          Deferral_Query.AGrid.Cells[3,1] := 'Area at Site';
          Deferral_Query.AGrid.Cells[4,1] := 'Below Target';

          if (iFurtherFailByCount>0) then
          begin
               Deferral_Query.BGrid.FixedRows := 1;
               Deferral_Query.BGrid.Cells[0,0] := 'Features';
               Deferral_Query.BGrid.Cells[1,0] := 'Orig. Eff. Target';
               Deferral_Query.BGrid.Cells[2,0] := '% of Total Deferred';
               Deferral_Query.BGrid.Cells[3,0] := 'Area at Site';
               Deferral_Query.BGrid.Cells[4,0] := 'Below Target';
          end
          else
          begin
               Deferral_Query.BGrid.Visible := False;
               Deferral_Query.AGrid.Color := clWindow;
          end;

          fUseSite := UserChooseSite;
     end;

     if (iTestResult = TEST_ACCEPT_THIS) then
      begin
           {accept this site}
           Inc(iUserSiteCount);
           if (iUserSiteCount > aUserSelectSites.lMaxSize) then
              aUserSelectSites.resize(aUserSelectSites.lMaxSize + ARR_STEP_SIZE);
           aUserSelectSites.setValue(iUserSiteCount,@SiteGeoCode);
      end;

     Result := iTestResult;   {pass the form result which is the user choice}

end; {ScanFeatures}

procedure testsitecomb(TestSet : array_t; var aMetaData : array_t);
{  Tests to see if the set of GeoCodes past will, in combination, stop features
that are already at target from now achieving target.
   Rtns an array of MetaData -> giving a feature reference <integre> and the
amount it will fail by <intger> (rounded from real).}
var
   x,y : integer;
   resCount : integer;
   ThisSite : site;
   aFeat : featureoccurrence;
   SiteRef : integer;
   szSiteList : string;
   tested, fConsiderFeature, fReserved : boolean;
   MetaData : MetaCuml_T;
   iTest : integer;
   {$IFNDEF SPARSE_MATRIX_2}
   CumlArea : featurearea_T;
   {$ENDIF}
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     {Result := Array_t.Create;
     Result.init(sizeof(MetaCuml_T),max);}

     {Reset all Values to zero}
     szsitelist := '';
     {$IFNDEF SPARSE_MATRIX_2}
     for x := 1 to max do
     begin
          CumlArea[x] := 0.0;
     end;
     {$ENDIF}

     {Add all the appropriate feature areas from those sites that are about to
     be excluded}
     for x := 1 to TestSet.lMaxSize do
     begin
          TestSet.rtnValue(x,@SiteRef);
          SiteArr.rtnValue(findIntegerMatch(OrdSiteArr,SiteRef),@ThisSite);
          szsiteList := szsiteList + IntToStr(ThisSite.iKey) + ' ';
          if (ThisSite.richness > 0) then
          for y := 1 to ThisSite.Richness do
          begin
               fConsiderFeature := True;
               if (ThisSite.status = Pd) then
               begin
                    SparsePartial.rtnValue(ThisSite.iOffset + x,@fReserved);
                    if not fReserved then
                       fConsiderFeature := False;
               end;

               (*
               if fConsiderFeature then
                  {$IFDEF SPARSE_MATRIX}
                  FeatureAmount.rtnValue(ThisSite.iOffset + y,@Value);
                  CumlArea[Value.iFeatKey] := CumlArea[Value.iFeatKey] + Value.rAmount;
                  {$ELSE}
                  CumlArea[ThisSite.feature[y]] :=
                   CumlArea[ThisSite.feature[y]] + ThisSite.FeatureArea[y];
                  {$ENDIF}
               *)
          end;
     end;

{Now test to see if this total combination will prevent features from achieving
targets}
     tested := FALSE;
     resCount := 0;
     {$IFNDEF SPARSE_MATRIX_2}
     for x := 1 to max do
     begin
{          if CumlSite.FeatureArea[x] > 0.0 then}
          begin
               itest := findIntegerMatch(OrdFeatArr,x);
               if itest = -1 then break;
               FeatArr.rtnValue(itest,@AFeat);

{Ensures that only those features already at target are examined}
               if (AFeat.targetarea <= 0) then
               begin
                    if ((AFeat.rDeferredArea - CumlArea[x]) <
                         AFeat.rInitialAvailableTarget) then
                    begin
{The combination will fail for this feature}
                         if CumlArea[x] > 0.0 then
                         begin
                              inc(resCount);
                              MetaData.Featref := AFeat.code{x};
                              MetaData.FailAmt := AFeat.rInitialAvailableTarget -
                                         (AFeat.rDeferredArea - CumlArea[x]);

                              aMetaData.setValue(resCount,@MetaData)
                         end;
                    end;
               end;
          end;
     end;
     {$ENDIF}
     if ResCount <> 0 then
        aMetaData.resize(resCount)
     else
     begin
          aMetaData.Resize(1);
          aMetaData.lMaxSize := 0;
     end;
end;{TestSiteComb}


procedure RedundancyCheck(DeferredGeoCodes : array_t; switch : integer);
{The switch :
             1 : Rtn GeoCodes of sites that individually do not affect the
             attainment of targets.

             2 : Gives a longest list of possible sites GeoCodes that in
             combination do not affect feature targets}
var
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
   x,y : integer;
   CurSize : integer;
   aSite : site;
   iGeo : integer;
   fail : boolean;
   aFeat : featureoccurrence;
   {$IFNDEF SPARSE_MATRIX_2}
   CumlArea : featurearea_T;
   {$ENDIF}
   aResult : array_t;
   sMessage : string;
   {added 3/3/97 by Matt}
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}

   function score(siteCode : integer) : integer;
   {Scores a Site by how much it affects achieving target - expressed as a
   summation of percentage affects or -1 if a feature would no longer achive
   target}
   var
      y : integer;
   begin
        Result := 0;
        SiteArr.rtnValue(findIntegerMatch(OrdSiteArr,siteCode),@aSite);
        fail := false;
        for y := 1 to aSite.Richness do
        begin
             {$IFDEF SPARSE_MATRIX}
             FeatureAmount.rtnValue(aSite.iOffset + y,@Value);
             FeatArr.rtnValue(findIntegerMatch(OrdFeatArr,Value.iFeatKey),@aFeat);
             if ((aFeat.rDeferredArea - aFeat.rInitialAvailableTarget)
                 < Value.rAmount) then
             {$ELSE}
             FeatArr.rtnValue(findIntegerMatch(OrdFeatArr,aSite.feature[y]),@aFeat);
             if ((aFeat.rDeferredArea - aFeat.rInitialAvailableTarget)
                 < aSite.featureArea[y]) then
             {$ENDIF}
             begin
                  fail := true;
                  break;
             end
             else
             begin
                  {$IFDEF SPARSE_MATRIX}
                  inc(Result,round(Value.rAmount*100/aFeat.rDeferredArea));
                  {$ELSE}
                  inc(Result,round(aSite.FeatureArea[y]*100/aFeat.rDeferredArea));
                  {$ENDIF}
             end;
        end;

        if not(fail) then
        begin
        end
        else
            Result := -1;

   end; {RedundancyCheck.score}

   function findworstsite : integer;
   {Rtns the GeoCode of the Site that affects (percentage wise) attainment of
   targets least}
   var
      x : integer;
      sz : integer;
      rtnScore : integer;
      minScore : integer;

   begin
        Result := -2;
        minScore := 9999;
        for x := 1 to DeferredGeoCodes.lMaxSize do
        begin
             DeferredGeoCodes.rtnValue(x,@sz);
             if sz <> -1 then
             begin
                  rtnScore := score(sz);
                  if rtnScore <> -1 then
                  begin
                       if rtnScore < minScore then
                       begin
                            minScore := rtnScore;
                            Result := sz;
                       end;
                  end;
             end;
        end;

        for x := 1 to DeferredGeoCodes.lMaxSize do
        begin
             DeferredGeoCodes.rtnValue(x,@sz);
             if sz = Result then
             begin
                  sz := -1;
                  DeferredGeoCodes.setValue(x,@sz);
                  break;
             end;
        end;
   end; {RedundancyCheck->FindWorstSite}

begin
     aResult := Array_t.Create;
     aResult.init(sizeof(integer),DeferredGeoCodes.lMaxSize);
     CurSize := 0;

{Result  is either:}
     case switch of
{Need to check each site individually}
          1 : begin
                   for x := 1 to DeferredGeoCodes.lMaxSize do
                   begin
                        DeferredGeoCodes.rtnValue(x,@iGeo);
                        SiteArr.rtnValue(findIntegerMatch(OrdSiteArr,iGeo),@aSite);
                        fail := false;
                        for y := 1 to aSite.Richness do
                        begin
                             {$IFDEF SPARSE_MATRIX}
                             FeatureAmount.rtnValue(aSite.iOffset + y,@Value);
                             FeatArr.rtnValue(findIntegerMatch(OrdFeatArr,Value.iFeatKey),@aFeat);
                             if ((aFeat.rDeferredArea - aFeat.rInitialAvailableTarget)
                                  < Value.rAmount) then
                             {$ELSE}
                             FeatArr.rtnValue(findIntegerMatch(OrdFeatArr,aSite.feature[y]),@aFeat);
                             if ((aFeat.rDeferredArea - aFeat.rInitialAvailableTarget)
                                  < aSite.featureArea[y]) then
                             {$ENDIF}
                             begin
                                  fail := true;
                                  break;
                             end;
                        end;

                        if not(fail) then
                        begin
                             inc(CurSize);
                             aResult.setValue(CurSize,@iGeo);
                        end;
                   end;
              end;

{Need to propose the best combination - ie longest path}
          2 : begin
                   {$IFNDEF SPARSE_MATRIX_2}
                   for x := 1 to max do
                   begin
                        CumlArea[x] := 0.0;
                   end;
                   {$ENDIF}
                   
                   repeat
                         {Find Worst Site - only return a geoCode if a site
                         can be found that doesn't exceed the feature targets
                         wrt cumulation of features - data stored in CumlSites}
                         iGeo := findworstSite;
                         if iGeo <> -2 then
                         begin
                              inc(CurSize);
                              aResult.setValue(CurSize,@iGeo);
                         end;
                   until iGeo = -2
                   {No more geocodes rtned}
              end;
          else
              begin

              end;
     end;

     {Need to resize the result}
     if CurSize > 0 then
        aResult.resize(curSize)
     else
     begin
          aResult.resize(1);
          aResult.lMaxSize := 0;
     end;

     if (aResult.lMaxSize = 0) then
        sMessage := 'No redundant sites found'
     else
         if (aResult.lMaxSize = 1) then
            sMessage := 'site'
         else
             sMessage := 'sites';

     if (aResult.lMaxSize > 0) then
     begin
          UnHighlight(ControlForm.Available,fKeepHighlight);
          UnHighlight(ControlForm.R1,fKeepHighlight);
          UnHighlight(ControlForm.R2,fKeepHighlight);
          UnHighlight(ControlForm.R3,fKeepHighlight);
          UnHighlight(ControlForm.R4,fKeepHighlight);
          UnHighlight(ControlForm.R5,fKeepHighlight);
          UnHighlight(ControlForm.Excluded,fKeepHighlight);
          UnHighlight(ControlForm.Partial,fKeepHighlight);
          UnHighlight(ControlForm.Flagged,fKeepHighlight);

          if (mrYes = MessageDlg(IntToStr(aResult.lMaxSize) + ' redundant ' + sMessage +
                                '.' + Chr(13) + Chr(10) + 'Map ' + sMessage + ' to GIS?',
                                mtConfirmation,[mbYes,mbNo],0)) then
          begin
               //ClearOldSQL;
               //MapSQL(aResult.lMaxSize,aResult,False);
               MapSites(aResult,FALSE);
          end
          else
              Arr2Highlight(aResult,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);
     end
     else
         MessageDlg(sMessage,mtInformation,[mbOk],0);

     aResult.Destroy;

     {highlight resulting sites in whatever box they appear}
     {Deferral_Query.listbox1.items.add('Redundant sites');
     for x := 1 to aResult.lMaxSize do
     begin
          aResult.rtnValue(x,@iGeo);
          Deferral_Query.ListBox1.items.add('  ' + FindSiteName(iGeo));
     end;
     if (aResult.lMaxSize = 0) then
        Deferral_Query.ListBox1.Items.Add('  no Redundant sites');
     Deferral_Query.Caption := 'Redundant Sites';
     Deferral_Query.showModal;
     Deferral_Query.destroy;}
end; {RedundancyCheck}


procedure TestToUnDeferSites(var ProposedGeoCodes : array_t);
var
   x : integer;
   testGeoCode : integer;
   {aToBeDeferredSites,} aMetaData : array_t;
   rtnData : MetaCuml_T;
   pFeat : featureoccurrencepointer;

   {added by Matt 16/7/96}
   aUserSelectSites : Array_t;
   iUserSiteCount : integer;

   {added by Matt 4/2/97}
   fStop : boolean;
   iScanResult, iCount : integer;

begin
     {aToBeDeferredSites := Array_t.Create;}
     CurrentDefRef := 0;

     {create and initialize aUserSelectSites which is added to
      by user selections in ScanFeatures}
     aUserSelectSites := Array_t.Create;
     aUserSelectSites.init(SizeOf(integer),ARR_STEP_SIZE);
     iUserSiteCount := 0;

     {Deferral_Query.listbox1.font := LookupForm.font;}

{Test the sites singly}
     x := 1;
     fStop := False;
     repeat

           ProposedGeoCodes.rtnValue(x,@testGeoCode);
           iScanResult := ScanFeatures(TestGeoCode,aUserSelectSites,iUserSiteCount);

           if (iScanResult = TEST_ACCEPT_THIS)
           or (iScanResult = TEST_REMOVE_THIS) then
              {continue loop scanning sites}
              Inc(x)
           else
               {drop out of loop and scan no more sites}
               fStop := True;

           if (x>ProposedGeoCodes.lMaxSize) then
              {finished scanning sites}
              fStop := True;

     until fStop;

     case iScanResult of
          TEST_ACCEPT_ALL :
          begin
               if (x<=ProposedGeoCodes.lMaxSize) then
                  for iCount := x to ProposedGeoCodes.lMaxSize do
                  begin
                       ProposedGeoCodes.rtnValue(iCount,@testGeoCode);

                       Inc(iUserSiteCount);
                       if (iUserSiteCount > aUserSelectSites.lMaxSize) then
                          aUserSelectSites.resize(aUserSelectSites.lMaxSize + ARR_STEP_SIZE);
                       aUserSelectSites.setValue(iUserSiteCount,@testGeoCode);

                  end;
          end;
          TEST_REMOVE_ALL : iUserSiteCount := 0;
          TEST_REMOVE_REST : ;
     end;

     {resize aUserSelectSites for use by TestSiteComb}
     if (iUserSiteCount > 0) then
        aUserSelectSites.resize(iUserSiteCount)
     else
     begin
          aUserSelectSites.resize(1);
          aUserSelectSites.lMaxSize := 0;
     end;

{Test the sites in combination}
     aMetaData := Array_t.Create;
     aMetaData.init(SizeOf(MetaCuml_T),ARR_STEP_SIZE);

     testSiteComb(aUserSelectSites,aMetaData);

     {Deferral_Query.listbox1.items.Clear;}
     Deferral_Query.AGrid.RowCount := 1;
     Deferral_Query.AGrid.ColCount := 2;
     Deferral_Query.AGrid.Color := clWindow;
     Deferral_Query.AGrid.DefaultColWidth := 295;
     Deferral_Query.BGrid.Visible := False;
     {make the 'Further Fails By' grid invisible}

{$ifdef Develop}
     new(pFeat);

     Deferral_Query.AGrid.Cells[0,0] := 'Features effected';
     Deferral_Query.AGrid.Cells[1,0] := 'Fail Amount';
     if (aMetaData.lMaxSize > 0) then
     begin
          for x := 1 to aMetaData.lMaxSize do
          begin
               aMetaData.rtnValue(x,@rtnData);
               FeatArr.rtnValue(findIntegerMatch(OrdFeatArr,rtnData.FeatRef),pFeat);

               Deferral_Query.AGrid.RowCount := Deferral_Query.AGrid.RowCount + 1;
               Deferral_Query.AGrid.Cells[0,(Deferral_Query.AGrid.RowCount-1)] := pFeat^.sID;
               Deferral_Query.AGrid.Cells[1,(Deferral_Query.AGrid.RowCount-1)] := TrimFloatForGrid(rtnData.FailAmt);
          end;

          Deferral_Query.AGrid.FixedRows := 1;
     end
     else
     begin
          Deferral_Query.AGrid.ColCount := 1;
          Deferral_Query.AGrid.DefaultColWidth := 590;
          Deferral_Query.AGrid.Cells[0,0] := 'No Features Effected';
          {Deferral_Query.listbox1.items.add('  no Features effected');}
     end;

     dispose(pFeat);
{$endif}

     aMetaData.Destroy;

     Deferral_Query.PrepShowCulm;

     if (iUserSiteCount > 0) then
     begin
          if (Deferral_Query.AGrid.RowCount > 1) then
             Deferral_Query.AGrid.FixedRows := 1;

          if (Deferral_Query.ShowModal = mrOk) then
          begin
               {if user clicks ok, copy aUserSelectSites to return array ProposedGeoCodes}
               if (iUserSiteCount > 0) then
               begin
                    if (iUserSiteCount < ProposedGeoCodes.lMaxSize) then
                       ProposedGeoCodes.resize(iUserSiteCount);

                    for x := 1 to iUserSiteCount do
                    begin
                         aUserSelectSites.rtnValue(x,@testGeoCode);
                         ProposedGeoCodes.setValue(x,@testGeoCode);
                    end;
               end;

          end
          else
          begin
               ProposedGeoCodes.resize(1);
               ProposedGeoCodes.lMaxSize := 0;
          end;
     end
     else
     begin
          {user has cancelled all selections}
          ProposedGeoCodes.resize(1);
          ProposedGeoCodes.lMaxSize := 0;
     end;

     {ProposedGeoCodes.Destroy;}
     aUserSelectSites.Destroy;
     Deferral_Query.destroy;

end; {TestToUndeferSites}


function WhyImpFeat(Degree : integer; ImpFeats : array_t) : array_t;
const
     stdSize = 100;
var
   x,y,z : integer;
   aSite : site;
   aFeat : featureoccurrence;
   iFeatRef : integer;
   CurSize : integer;
   found : boolean;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     Result := Array_t.Create;

     Result.init(sizeof(integer),stdSize);
     curSize := 0;

     for x := 1 to SiteArr.lMaxSize do
     begin
          SiteArr.rtnValue(x,@aSite);
          found := false;
          if (aSite.Status = _R1) or (aSite.Status = _R2) or (aSite.Status = _R3) or (aSite.Status = _R4) or (aSite.Status = _R5) then
          begin
               for y := 1 to ImpFeats.lMaxSize do
               begin
                    ImpFeats.rtnValue(y,@iFeatRef);
                    FeatArr.rtnValue(findIntegerMatch(OrdFeatArr,iFeatRef),@aFeat);
                    for z := 1 to aSite.richness do
                    begin
                         {$IFDEF SPARSE_MATRIX}
                         FeatureAmount.rtnValue(aSite.iOffset + z,@Value);
                         if iFeatRef = Value.iFeatKey then
                         {$ELSE}
                         if iFeatRef = aSite.feature[z] then
                         {$ENDIF}
                         begin
                              {Test for Importance}
                              {$IFDEF SPARSE_MATRIX}
                              if ((Value.rAmount*100/aFeat.rInitialAvailableTarget) > Degree ) then
                              {$ELSE}
                              if ((aSite.featureArea[z]*100/aFeat.rInitialAvailableTarget) > Degree ) then
                              {$ENDIF}
                              begin
                                   found := true;
                                   break;
                              end;
                         end;
                    end;
                    if found then break;
               end;
          end;

          if found then
          begin
               inc(CurSize);
               if CurSize > Result.lMaxSize then
                  Result.resize(Result.lMaxSize+stdSize);
               Result.setValue(CurSize,@aSite.iKey);
          end;
     end;

     if CurSize = 0 then
     begin
          Result.resize(1);
          Result.lMaxSize := 0;
     end
     else
         Result.resize(CurSize);
end; {WhyImpFeat}

(*
procedure defrqryInit;
{Builds a test Assumes simons small data with sites 5 and 8 not already
negotiated and no Mand}
var
   ProposedSites : array_t;
   szGeo : MyShortString;

begin
     ProposedSites := Array_t.Create;
     ProposedSites.init(sizeof(MyshortString),8);
     szGeo := '1';
     ProposedSites.setValue(1,@szGeo);
     szGeo := '2';
     ProposedSites.setValue(2,@szGeo);
     szGeo := '4';
     ProposedSites.setValue(3,@szGeo);
     szGeo := '6';
     ProposedSites.setValue(4,@szGeo);
     szGeo := '7';
     ProposedSites.setValue(5,@szGeo);
     szGeo := '8';
     ProposedSites.setValue(6,@szGeo);
     szGeo := '9';
     ProposedSites.setValue(7,@szGeo);
     szGeo := '13';
     ProposedSites.setValue(8,@szGeo);
     Deferral_Query := TDeferral_Query.create(Application);
     RedundancyCheck(ProposedSites,1);
     Deferral_Query := TDeferral_Query.create(Application);
     TestToUndeferSites(ProposedSites);
     Deferral_Query := TDeferral_Query.create(Application);
     ProposeReplacementSites(ProposedSites,True);
end;
*)

procedure TDeferral_Query.OKClick(Sender: TObject);
begin
     PopupAccept.Popup(Left + OK.Left + OK.Width,
                       Top + Ok.Height);
end;

procedure TDeferral_Query.btnRemoveSiteClick(Sender: TObject);
begin
     PopupRemove.Popup(Left + btnRemoveSite.Left + btnRemoveSite.Width,
                       Top + btnRemoveSite.Height);
end;

procedure TDeferral_Query.ThisSite1Click(Sender: TObject);
begin
     iTestResult := TEST_ACCEPT_THIS;
     ModalResult := mrOk;
end;

procedure TDeferral_Query.RemainingSites1Click(Sender: TObject);
begin
     iTestResult := TEST_ACCEPT_ALL;
     ModalResult := mrOk;
end;

procedure TDeferral_Query.ThisSite2Click(Sender: TObject);
begin
     iTestResult := TEST_REMOVE_THIS;
     ModalResult := mrOk;
end;

procedure TDeferral_Query.RemainingSites2Click(Sender: TObject);
begin
     iTestResult := TEST_REMOVE_REST;
     ModalResult := mrOk;
end;

procedure TDeferral_Query.AllSitesincludepreviousAccepts1Click(
  Sender: TObject);
begin
     iTestResult := TEST_REMOVE_ALL;
     ModalResult := mrOk;
end;

procedure TDeferral_Query.FormCreate(Sender: TObject);
begin
     iTestResult := TEST_ACCEPT_THIS;
end;

procedure TDeferral_Query.btnOkClick(Sender: TObject);
begin
     ModalResult := mrOk;
end;

procedure TDeferral_Query.checkWatchUnDefClick(Sender: TObject);
begin
     iTestResult := TEST_ACCEPT_ALL;
     ModalResult := mrOk;
     fWatchUnDef := False;
end;

procedure TDeferral_Query.btnCancelClick(Sender: TObject);
begin
     iTestResult := TEST_REMOVE_ALL;
     ModalResult := mrCancel;
end;

procedure TDeferral_Query.FormResize(Sender: TObject);
begin
     {resize the grids to fit into the screen}
     try
        AGrid.DefaultColWidth := (ClientWidth div AGrid.ColCount) - 2 +
                                 Trunc((ClientWidth mod AGrid.ColCount)/AGrid.ColCount);

     except
           AGrid.DefaultColWidth := 1;
     end;

     if BGrid.Visible then
     begin
          BGrid.DefaultColWidth := AGrid.DefaultColWidth;

          try
             BGrid.Height := (ClientHeight div 2) - AGrid.DefaultRowHeight;
          except
                BGrid.Height := 0;
          end;
     end;
end;

end.
