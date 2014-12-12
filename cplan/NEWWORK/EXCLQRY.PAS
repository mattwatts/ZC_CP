unit Exclqry;

{$I \SOFTWARE\cplan\cplan\STD_DEF.PAS}

{$define develop}
{$define Combdevelop}

interface

uses
  SysUtils, Messages, Classes, Graphics, Controls,
  Forms, Dialogs,em_newu1, StdCtrls, excludfl
  ,Wintypes, winprocs, ExtCtrls,
  {$IFDEF bit16}
  Arrayt16;
  {$ELSE}
  ds;
  {$ENDIF}

type
    EvalFeatResult = integer;

{DEBUG FORM}
  TFeature_Query = class(TForm)
    ListBox1: TListBox;
    Panel1: TPanel;
    Button1: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Feature_Query: TFeature_Query;

(*procedure FQInit;*)
{This function is a semi blank stub designed for test purposes only - the hard
wired geocodes used for the subsequent functions can be built and passed within
this stub}

procedure TestToExcludeSites(var ProposedGeoCodes : array_t);
{Recieves a list of geocodes of sites that are proposed to be excluded.
 We must then determine if any features will now be unable to reach target and
 if so notify the user - the result of this notification will determine whether
 or not the site will be added to the return list.  The examination of features
 happens in two cases - the firts of direct examination of the features
 contained in a single sites and determine it's exclusion affect on the
 remaining data set - the second technique is to examine the sites as a single
 event and again examining over the features.}


function TrimFloatForGrid(const rValue : extended) : string;
{format a float to write into a Grid Cell}

var
   aExcludedSites : array_t;
   CurrentExcRef : integer;

implementation
uses
    control{So we have featarr and sitearr},
    choices{Giving us the ability to update the reasoning box},
    global {For the max # of features},
    contribu, Dbmisc, Opt1, toolmisc,
    Sct_grid, Lookup;

{$R *.DFM}

function TrimFloatForGrid(const rValue : extended) : string;
begin
     Str(rValue:7:1,Result);
     TrimLeadSpaces(Result);
end;

function ScanFeatures(SiteGeoCode, iThisSite, iAllSites : integer) : EvalFeatResult;
{Test for excluding a single site.
Test the features contained within athe passed site's geocode to see if any
targets would be unsatisfied -> allow them to not be excluded}
var
   x, iGridCharCount, iGridFieldLength : integer;
   testSite : site;
   AFeat : featureoccurrence;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     FailExSites.lblInfo.Caption := '(Site ' + IntToStr(iThisSite) + ' of ' + IntToStr(iAllSites) + ')';

     SiteArr.rtnValue(findIntegerMatch(OrdSiteArr,SiteGeoCode),@testSite);

     {FailExSites.listbox1.items.clear;
     FailExSites.listbox1.items.add('Site ' + FindSiteName(testSite.iKey));}

     FailExSites.AGrid.ColCount := 6;
     FailExSites.AGrid.RowCount := 2;
     FailExSites.AGrid.Cells[0,0] := 'Site ' + FindSiteName(testSite.iKey);

     {write title row to grid}
     FailExSites.AGrid.Cells[0,1] := 'Features';
     FailExSites.AGrid.Cells[1,1] := 'Orig. Eff. Target';
     FailExSites.AGrid.Cells[2,1] := 'Available';
     FailExSites.AGrid.Cells[3,1] := 'Deferred';
     FailExSites.AGrid.Cells[4,1] := 'Area at Site';
     FailExSites.AGrid.Cells[5,1] := 'Fails By';

     if (TestSite.richness > 0) then
     begin
          for x := 1 to TestSite.richness do
          begin
               {$IFDEF SPARSE_MATRIX}
               FeatureAmount.rtnValue(TestSite.iOffset + x,@Value);
               FeatArr.rtnValue(findIntegerMatch(OrdFeatArr,Value.iFeatKey),@AFeat);
               if ((AFeat.rSumArea - Value.rAmount) < AFeat.TargetArea) then
               {$ELSE}
               FeatArr.rtnValue(findIntegerMatch(OrdFeatArr,testSite.Feature[x]),@AFeat);
               if ((AFeat.rSumArea - TestSite.FeatureArea[x]) < AFeat.TargetArea) then
               {$ENDIF}
               begin
                    FailExSites.AGrid.RowCount := FailExSites.AGrid.RowCount + 1;

                    FailExSites.AGrid.Cells[0,FailExSites.AGrid.RowCount-1] := AFeat.sID;
                    FailExSites.AGrid.Cells[1,FailExSites.AGrid.RowCount-1] :=
                           TrimFloatForGrid(AFeat.rTrimmedTarget);
                    FailExSites.AGrid.Cells[2,FailExSites.AGrid.RowCount-1] :=
                           TrimFloatForGrid(AFeat.rSumArea-AFeat.rExcluded-AFeat.rDeferredArea);
                    FailExSites.AGrid.Cells[3,FailExSites.AGrid.RowCount-1] :=
                           TrimFloatForGrid(AFeat.rDeferredArea);
                    FailExSites.AGrid.Cells[4,FailExSites.AGrid.RowCount-1] :=
                           {$IFDEF SPARSE_MATRIX}
                           TrimFloatForGrid(Value.rAmount);
                           {$ELSE}
                           TrimFloatForGrid(TestSite.FeatureArea[x]);
                           {$ENDIF}
                    FailExSites.AGrid.Cells[5,FailExSites.AGrid.RowCount-1] :=
                           TrimFloatForGrid(AFeat.TargetArea -
                           {$IFDEF SPARSE_MATRIX}
                              (AFeat.rCurrentSumArea - Value.rAmount));
                           {$ELSE}
                              (AFeat.rCurrentSumArea - TestSite.FeatureArea[x]));
                           {$ENDIF}
               end;
          end;

          iFailExSitesResult := TEST_ACCEPT_THIS;

          if (FailExSites.AGrid.RowCount > 2) then
          begin
               {we are displaying features for this site}
               FailExSites.AGrid.FixedRows := 2;

               FailExSites.showModal;
          end;

          if (iFailExSitesResult = TEST_ACCEPT_THIS) then
          begin
               inc(CurrentExcRef);
               aExcludedSites.setValue(CurrentExcRef,@TestSite.iKey);
          end;
     end;

end;{ScanFeatures}

procedure testsitecomb(TestSet : array_t);
{Test the affect of excluding a set of sites - allowing for non exclusion}
var
   x,y : integer;
   CumlSite : site;
   ThisSite : site;
   aFeat : featureoccurrence;
   SiteRef : integer;
   szSiteList : string;
   tested : boolean;
   rValue : extended;
   {$IFDEF SPARSE_MATRIX_2}
   CumulativeArea : Array_t;
   {$ELSE}
   CumlArea : featurearea_T;
   {$ENDIF}
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}

   procedure IncCumulativeArea(const iFeatureIndex : integer;
                               const rFeatureArea : single);
   begin
        {$IFDEF SPARSE_MATRIX_2}
        CumulativeArea.rtnValue(iFeatureIndex,@rValue);
        rValue := rValue + rFeatureArea;
        CumulativeArea.setValue(iFeatureIndex,@rValue);
        {$ELSE}
        CumlArea[iFeatureIndex] := CumlArea[iFeatureIndex] + rFeatureArea;
        {$ENDIF}
   end;
begin
     try
   {Reset all Values to zero}
        szsitelist := '';
        {$IFDEF SPARSE_MATRIX_2}
        CumulativeArea := Array_t.Create;
        CumulativeArea.init(SizeOf(extended),iFeatureCount);
        rValue := 0;
        for x := 1 to iFeatureCount do
            CumulativeArea.setValue(x,@rValue);
        {$ELSE}
        for x := 1 to max do
            CumlArea[x] := 0.0;
        {$ENDIF}

   {Add all the appropriate feature areas from those sites that are about to
   be excluded}
        for x := 1 to TestSet.lMaxSize do
        begin
             TestSet.rtnValue(x,@SiteRef);
             SiteArr.rtnValue(findIntegerMatch(OrdSiteArr,SiteRef),@ThisSite);
             szsiteList := szsiteList + IntToStr(ThisSite.iKey) + ' ';
             for y := 1 to ThisSite.Richness do
             begin
                  {$IFDEF SPARSE_MATRIX}
                  FeatureAmount.rtnValue(ThisSite.iOffset + y,@Value);
                  IncCumulativeArea(Value.iFeatKey,Value.rAmount);
                  {CumlArea[Value.iFeatKey] := CumlArea[Value.iFeatKey] +
                                              Value.rAmount;}
                  {$ELSE}
                  IncCumulativeArea(FindFeature(ThisSite.feature[y]),ThisSite.FeatureArea[y]);
                  {CumlArea[ThisSite.feature[y]] := CumlArea[ThisSite.feature[y]] +
                                                   ThisSite.FeatureArea[y];}
                  {$ENDIF}
             end;
        end;

   {Now test to see if this total combination will prevent features from achieving
   targets}
        tested := FALSE;
        {$IFDEF SPARSE_MATRIX_2}
        for x := 1 to iFeatureCount do
        {$ELSE}
        for x := 1 to max do
        {$ENDIF}
        begin
             {$IFDEF SPARSE_MATRIX_2}
             CumulativeArea.rtnValue(x,@rValue);
             if rValue > 0 then
             {$ELSE}
             rValue := CumlArea[x];
             if CumlArea[x] > 0 then
             {$ENDIF}
             begin
                  FeatArr.rtnValue(findIntegerMatch(OrdFeatArr,x),@AFeat);
                  if ((AFeat.rSumArea - rValue) < AFeat.TargetArea) then
                  with FailExSites.AGrid do
                  begin
                       {The combination will fail for this feature}

                       RowCount := FailExSites.AGrid.RowCount + 1;
                       {Cells[0,RowCount-1] := szSitelist;}
                       Cells[0,RowCount-1] := AFeat.sID;
                       Cells[1,RowCount-1] :=
                         TrimFloatForGrid(AFeat.TargetArea -
                           (AFeat.rCurrentSumArea - rValue));
                  end;
             end;
        end;

        {$IFDEF SPARSE_MATRIX_2}
        CumulativeArea.Destroy;
        {$ENDIF}

     except
           Screen.Cursor := crDefault;
           RptErrorStop('Exception in testsitecomb');
     end;
end;{testsitecomb}


procedure TestToExcludeSites(var ProposedGeoCodes : array_t);
var
   fStop, fFail : boolean;
   iCount, x : integer;
   testGeoCode : integer;
begin
     try
        aExcludedSites := Array_t.Create;

        aExcludedSites.init(sizeof(integer),ProposedGeoCodes.lMaxSize);
        CurrentExcRef := 0;

        FailExSites := TFailExSites.create(Feature_Query);

        fStop := False;
        x := 1;
        repeat
              ProposedGeoCodes.rtnValue(x,@testGeoCode);
              ScanFeatures(TestGeoCode,x,ProposedGeocodes.lMaxSize);

              if (iFailExSitesResult = TEST_ACCEPT_THIS)
              or (iFailExSitesResult = TEST_REMOVE_THIS) then
                 Inc(x)
              else
                  fStop := True;

              if (x>ProposedGeocodes.lMaxSize) then
                 fStop := True;

        until fStop;

        case iFailExSitesResult of
             TEST_ACCEPT_ALL :
             begin
                  if (x<=ProposedGeoCodes.lMaxSize) then
                     for iCount := x to ProposedGeoCodes.lMaxSize do
                     begin
                          ProposedGeoCodes.rtnValue(iCount,@testGeoCode);

                          inc(CurrentExcRef);

                          if (CurrentExcRef > aExcludedSites.lMaxSize) then
                             aExcludedSites.resize(aExcludedSites.lMaxSize + ARR_STEP_SIZE);

                          aExcludedSites.setValue(CurrentExcRef,@testGeoCode);
                     end;
             end;
             TEST_REMOVE_ALL :
             begin
                  CurrentExcRef := 0;
             end;
        end;

        {end;}

        if CurrentExcRef <> 0 then
        begin
             aExcludedSites.resize(CurrentExcRef);
             if (CurrentExcRef < ProposedGeoCodes.lMaxSize) then
                ProposedGeoCodes.resize(CurrentExcRef);
        end
        else
        begin
            aExcludedSites.resize(1);
            aExcludedSites.lMaxSize := 0;
            ProposedGeoCodes.resize(1);
            ProposedGeoCodes.lMaxSize := 0;
        end;


   {More than a single site is being excluded so test the combination of all
        proposed excluded sites to see if any should not be excluded}
        if CurrentExcRef > 0 then
        with FailExSites.AGrid do
        begin
             {prepare AGrid}
             RowCount := 1;
             ColCount := 2;
             DefaultColWidth := 297;

             Cells[0,0] := 'Feature';
             Cells[1,0] := 'will miss target by';

             testSiteComb(aExcludedSites);
        end;

        aExcludedSites.Destroy;

        FailExSites.btnRemove.Visible := False;
        FailExSites.btnAccept.Visible := False;
        FailExSites.CheckBox1.Visible := False;
        FailExSites.btnOk.Visible := True;
        FailExSites.btnCancel.Visible := True;
        FailExSites.lblInfo.Caption := '';

        fFail := False;

        if (FailExSites.AGrid.RowCount > 1) then
        begin
             if CurrentExcRef > 0 then
             begin
                  FailExSites.AGrid.FixedRows := 1;

                  if not (FailExSites.showmodal = mrOk) then
                     fFail := True;
             end
             else
                 fFail := True;
        end
        else
        begin
             FailExSites.AGrid.ColCount := 1;
             FailExSites.AGrid.Cells[0,0] := 'No Features Effected';
             FailExSites.AGrid.DefaultColWidth := FailExSites.ClientWidth - 5;
             if not (FailExSites.ShowModal = mrOk) then
                fFail := True;
        end;

        if fFail then
        begin
             ProposedGeoCodes.resize(1);
             ProposedGeoCodes.lMaxSize := 0;
        end;

        FailExSites.destroy;

     except
           Screen.Cursor := crDefault;
           RptErrorStop('Exception in TestToExcludeSites');
     end;

end;{testtoexclude sites}


end.
