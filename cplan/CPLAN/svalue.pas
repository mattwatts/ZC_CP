unit svalue;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, Gauges, ExtCtrls, Buttons;

type
  TSiteValueForm = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    PCTargGroup: TRadioGroup;
    Gauge1: TGauge;
    PCTarg: TSpinEdit;
    Targ: TSpinEdit;
    TargGroup: TRadioGroup;
    GroupBox3: TGroupBox;
    CheckMapSites: TCheckBox;
    MatchGroup: TRadioGroup;
    Match: TSpinEdit;
    procedure IdentifySites;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SiteValueForm: TSiteValueForm;

implementation

uses
    ds, global, control, highligh,
    contribu, sf_irrep, sql_unit,
    Toolmisc;

{$R *.DFM}

procedure TSiteValueForm.IdentifySites;
var
   iCount, iSitesChosen, iLoopCount, iFeatIndex, iLastUpdate, iUpdate,
   iContributingFeatures, iLowFeatures : integer;
   SitesChosen : Array_t;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   sMsg : string;
   rRevisedTarget, rPCToTarg, rToTarg : extended;
   fHasLowValue : boolean;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}

   procedure AddASite(const iGeocode : integer);
   begin
        Inc(iSitesChosen);

        if (iSitesChosen > SitesChosen.lMaxSize) then
           SitesChosen.resize(SitesChosen.lMaxSize + ARR_STEP_SIZE);

        SitesChosen.setValue(iSitesChosen,@iGeocode);
   end;

begin
     {identify deferred sites which have the desired characteristics}
     try
        Screen.Cursor := crHourglass;
        CheckMapSites.Visible := False;
        Gauge1.Visible := True;
        iLastUpdate := 0;
        {initialise variables}
        iSitesChosen := 0;
        SitesChosen := Array_T.Create;
        SitesChosen.init(SizeOf(integer),ARR_STEP_SIZE);
        new(pSite);
        new(pFeat);

        {loop through all sites looking for deferred sites}
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);
             if (pSite^.status = _R1)
             or (pSite^.status = _R2)
             or (pSite^.status = _R3)
             or (pSite^.status = _R4)
             or (pSite^.status = _R5) then
             begin
                  iContributingFeatures := 0;
                  iLowFeatures := 0;

                  iUpdate := Round(iCount / iSiteCount * 100);
                  if (iUpdate <> iLastUpdate) then
                  begin
                       {update progress gauge}
                       Gauge1.Progress := iUpdate;
                       iLastUpdate := iUpdate;
                       Gauge1.Refresh;
                  end;

                  {evaluate this deferred site}
                  if (pSite^.richness > 0) then
                     for iLoopCount := 1 to pSite^.richness do
                     begin
                          {$IFDEF SPARSE_MATRIX}
                          FeatureAmount.rtnValue(pSite^.iOffset + iLoopCount,@Value);
                          iFeatIndex := Value.iFeatKey;
                          {$ELSE}
                          iFeatIndex := FindFeature(pSite^.feature[iLoopCount]);
                          {$ENDIF}
                          FeatArr.rtnValue(iFeatIndex,pFeat);

                          {$IFDEF SPARSE_MATRIX}
                          rRevisedTarget := pFeat^.targetarea - Value.rAmount;
                          {$ELSE}
                          rRevisedTarget := pFeat^.targetarea - pSite^.featurearea[iLoopCount];
                          {$ENDIF}

                          Inc(iContributingFeatures);
                          rPCToTarg := 0;

                          case PCTargGroup.ItemIndex of
                               0 : {trimmed target}
                                   if (pFeat^.rTrimmedTarget > 0) then
                                      {$IFDEF SPARSE_MATRIX}
                                      rPCToTarg := Value.rAmount / pFeat^.rTrimmedTarget * 100;
                                      {$ELSE}
                                      rPCToTarg := pSite^.featurearea[iLoopCount] / pFeat^.rTrimmedTarget * 100;
                                      {$ENDIF}
                               1 : {revised Current Effective Target}
                                   if (rRevisedTarget > 0) then
                                      {$IFDEF SPARSE_MATRIX}
                                      rPCToTarg := Value.rAmount / rRevisedTarget * 100;
                                      {$ELSE}
                                      rPCToTarg := pSite^.featurearea[iLoopCount] / rRevisedTarget * 100;
                                      {$ENDIF}
                          end;

                          case TargGroup.ItemIndex of
                               0 : rToTarg := pFeat^.rTrimmedTarget;
                               1 : rToTarg := rRevisedTarget;
                          end;

                          if (PCTarg.Value > rPCToTarg)
                          and (Targ.Value > rToTarg) then
                              Inc(iLowFeatures);
                     end;

                  {now determine whether this site has a Low Value}
                  fHasLowValue := False;
                  case MatchGroup.ItemIndex of
                       0 : {X or more features}
                           if (iLowFeatures >= Match.Value) then
                              fHasLowValue := True;
                       1 : {X or more % of features}
                           if (iContributingFeatures > 0) then
                              if (Round(iLowFeatures / iContributingFeatures * 100) >= Match.Value) then
                                 fHasLowValue := True;
                  end;

                  if fHasLowValue then
                     AddASite(pSite^.iKey);
             end;
        end;

        {use SitesChosen}
        if (iSitesChosen > 0) then
        begin
             if (iSitesChosen <> SitesChosen.lMaxSize) then
                SitesChosen.resize(iSitesChosen);

             {highlight the sites}
             Arr2Highlight(SitesChosen,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);
             {map the sites if applicable}
             if CheckMapSites.Checked then
             begin
                  //ClearOldSQL;
                  //MapSQL(iSitesChosen,SitesChosen,False);
                  MapSites(SitesChosen,FALSE);
             end;
        end;

        {display user info}
        if (iSitesChosen = 1) then
           sMsg := '1 site'
        else
            sMsg := IntToStr(iSitesChosen) + ' sites';
        Screen.Cursor := crDefault;
        MessageDlg(sMsg + ' found that match profile',
                    mtInformation,[mbOk],0);

        {dispose of variables}
        SitesChosen.Destroy;
        dispose(pSite);
        dispose(pFeat);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in IdentifySites',
                      mtError,[mbOk],0);
     end;
end;

procedure TSiteValueForm.BitBtn1Click(Sender: TObject);
begin
     IdentifySites;
end;

end.
