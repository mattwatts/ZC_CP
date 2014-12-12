unit Contribu;

{$I STD_DEF.PAS}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Em_newu1, StdCtrls, ExtCtrls, Printers, Clipbrd, Buttons,
  Menus, Global, Spin, ds;


type
  TContributionForm = class(TForm)
    GraphImage: TImage;
    Panel1: TPanel;
    CanvasFont: TFontDialog;
    selectGradient: TRadioGroup;
    selectPlotData: TRadioGroup;
    checkVertGrid: TCheckBox;
    checkHorzGrid: TCheckBox;
    labelSiteName: TLabel;
    labelValue: TLabel;
    SaveGraphic: TSaveDialog;
    BitBtn1: TBitBtn;
    MainMenu1: TMainMenu;
    Image1: TMenuItem;
    Save1: TMenuItem;
    Copy1: TMenuItem;
    Font1: TMenuItem;
    Colour1: TMenuItem;
    N1: TMenuItem;
    Lines1: TMenuItem;
    Plot1: TMenuItem;
    N11: TMenuItem;
    N21: TMenuItem;
    N51: TMenuItem;
    N101: TMenuItem;
    Target1: TMenuItem;
    Area1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    VerticalGrid1: TMenuItem;
    HorizontalGrid1: TMenuItem;
    btnFeatTable: TButton;
    shRes: TShape;
    shNeg: TShape;
    shMan: TShape;
    shPar: TShape;
    shLow: TShape;
    shFull: TShape;
    BarColor: TColorDialog;
    shAvail: TShape;
    N3: TMenuItem;
    Print1: TMenuItem;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    btnPrev: TButton;
    btnNext: TButton;
    SpinNumSites: TSpinEdit;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    //{$IFNDEF SPARSE_MATRIX_2}
    procedure Button1Click(Sender: TObject);
    procedure GraphImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnPrintClick(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure selectPlotDataClick(Sender: TObject);
    procedure selectGradientClick(Sender: TObject);
    procedure GraphImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure btnColorClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure N21Click(Sender: TObject);
    procedure N51Click(Sender: TObject);
    procedure N101Click(Sender: TObject);
    procedure Target1Click(Sender: TObject);
    procedure Area1Click(Sender: TObject);
    procedure VerticalGrid1Click(Sender: TObject);
    procedure HorizontalGrid1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure btnFeatTableClick(Sender: TObject);
    procedure shResMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shNegMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shManMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shParMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shLowMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shFullMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shAvailMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Print1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    //{$ENDIF}
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  ContributionForm: TContributionForm;
  iGraphState, iSiteIndex, iTruncStep,
  iSiteGroupSize, iSiteGroup, iSiteGroupCount : integer;
  fTruncated : boolean;
  SparseContribution, SiteContribution, GraphSites : Array_T;

  rReservedContrib : extended;
  {rReservedContrib stores the percentage of features
   satisfied by (existing) Reserved sites}

function FindSiteName(const iSiteGeocode : integer) : string;
function LoadPCUSEDCutOff : integer;
procedure StartContributionGraph{(const iNumMan,iNumSel : integer)};
//{$IFNDEF SPARSE_MATRIX_2}
function FindFeature(const iFeature : integer) : integer;
{this function returns the index of iFeature in Farray}
function FindSite(const iGeocode : integer) : integer;
procedure DrawSiteBars;
function RepdFeatPercentB(const LocalFeatures : Array_T) : extended;
function PartialFeatPercent(const LocalFeatures : Array_T) : extended;
{calculates contribution relative to previous sites and dependant on order}
function FindSiteGeocode(const sSiteName : string) : integer;
procedure NewCalcPotential(const ThisSiteArr, ThisFeatArr : Array_T;
                           const fShowProgress : boolean);
procedure DrawFeatureBars(const iSiteIndex : integer);
//{$ENDIF}
procedure InitContribData(const iSelections : integer);


implementation

{$R *.DFM}


uses
    Colors, Lookup, Featrepd, IniFiles,
    Control, F1find, In_order, Opt1,
    Toolmisc, Ini_misc,
    partl_ed;

procedure InitContribData(const iSelections : integer);
var
   iCount, iValue : integer;
   rValue : extended;
   SiteValue : SiteCust_T;
   pSite : sitepointer;
begin
     // init SparseContribution and SiteContribution
     try
        SparseContribution := Array_t.Create;
        SiteContribution := Array_t.Create;
        GraphSites := Array_t.Create;
        SparseContribution.init(SizeOf(extended),FeatureAmount.lMaxSize);
        SiteContribution.init(SizeOf(SiteCust_T),iSiteCount);
        GraphSites.init(SizeOf(integer),iSelections);
        rValue := 0;
        for iCount := 1 to SparseContribution.lMaxSize do
            SparseContribution.setValue(iCount,@rValue);
        SiteValue.rPercentUsed := 0;
        SiteValue.rValue2 := 0;
        new(pSite);
        for iCount := 1 to SiteContribution.lMaxSize do
        begin
             SiteArr.rtnValue(iCount,pSite);
             SiteValue.iCode := pSite^.iKey;
             SiteContribution.setValue(iCount,@SiteValue);
        end;
        dispose(pSite);
        iValue := 0;
        for iCount := 1 to GraphSites.lMaxSize do
            GraphSites.setValue(iCount,@iValue);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in InitContribData',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure FreeContribData;
begin
     //
     try
        SparseContribution.Destroy;
        SiteContribution.Destroy;
        GraphSites.Destroy;
        GraphSites := nil;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in FreeContribData',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


function LoadPCUSEDCutOff : integer;
var
   AIni : TIniFile;
begin
     try
	if ControlRes^.fOldIni then
	   AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
	else
	    AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);

        Result := AIni.ReadInteger('Database' + IntToStr(iDBLoaded),
                                   'PCUSEDCutOff',-1);
        if (Result = -1) then
           Result := AIni.ReadInteger('Database' + IntToStr(iDBLoaded),
                                   'PCCONTRCutOff',iFeatureCount);
        AIni.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Load Percent Contribution Cutoff',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function FindSiteName(const iSiteGeocode : integer) : string;
{this function returns the name of a site in either the
 selected/mandatory/excluded/reserved/ignored list boxes of the ControlForm}
var
   iSiteIndex : integer;
   pSite : sitepointer;
begin
     try
        new(pSite);

        iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteGeocode);

        if (iSiteIndex > 0) then
        begin
             SiteArr.rtnValue(iSiteIndex,pSite);
             Result := pSite^.sName;
        end
        else
            Result := 'site name not found';

     finally
            dispose(pSite);
     end;
end;

procedure StartContributionGraph;
var
   iNumContrib : integer;
begin
     try
        InitialPrepIrrepData;
        BuildLogList(iNumContrib,(ControlRes^.fValidateMode and ControlRes^.fGenerateCompRpt));
        InOrderContrib(iNumContrib,True);
        LogList.Destroy;

        ContributionForm := TContributionForm.Create(Application);
        ContributionForm.ShowModal;
     finally
            ContributionForm.Free;
     end;
end;

//{$IFNDEF SPARSE_MATRIX_2}
function FindSiteGeocode(const sSiteName : string) : integer;
var
   iCount : integer;
   fFound : boolean;
   sResult : string;
begin
     sResult := 'site Key not found';
     fFound := False;

     if (ControlForm.Available.Items.Count > 0) then
     for iCount := 0 to (ControlForm.AvailableKey.Items.Count-1) do
         if ((ControlForm.Available.Items.Strings[iCount]) = sSiteName) then
         begin
              sResult := ControlForm.AvailableKey.Items.Strings[iCount];
              fFound := True;
         end;

     if not fFound
     and (ControlForm.R1.Items.Count > 0) then
     for iCount := 0 to (ControlForm.R1Key.Items.Count-1) do
         if ((ControlForm.R1.Items.Strings[iCount]) = sSiteName) then
         begin
              sResult := ControlForm.R1Key.Items.Strings[iCount];
              fFound := True;
         end;

     if not fFound
     and (ControlForm.R2.Items.Count > 0) then
     for iCount := 0 to (ControlForm.R2Key.Items.Count-1) do
         if ((ControlForm.R2.Items.Strings[iCount]) = sSiteName) then
         begin
              sResult := ControlForm.R2Key.Items.Strings[iCount];
              fFound := True;
         end;

     if not fFound
     and (ControlForm.R3.Items.Count > 0) then
     for iCount := 0 to (ControlForm.R3Key.Items.Count-1) do
         if ((ControlForm.R3.Items.Strings[iCount]) = sSiteName) then
         begin
              sResult := ControlForm.R3Key.Items.Strings[iCount];
              fFound := True;
         end;

     if not fFound
     and (ControlForm.R4.Items.Count > 0) then
     for iCount := 0 to (ControlForm.R4Key.Items.Count-1) do
         if ((ControlForm.R4.Items.Strings[iCount]) = sSiteName) then
         begin
              sResult := ControlForm.R4Key.Items.Strings[iCount];
              fFound := True;
         end;

     if not fFound
     and (ControlForm.R5.Items.Count > 0) then
     for iCount := 0 to (ControlForm.R5Key.Items.Count-1) do
         if ((ControlForm.R5.Items.Strings[iCount]) = sSiteName) then
         begin
              sResult := ControlForm.R5Key.Items.Strings[iCount];
              fFound := True;
         end;

     if not fFound
     and (ControlForm.Partial.Items.Count > 0) then
     for iCount := 0 to (ControlForm.PartialKey.Items.Count-1) do
         if ((ControlForm.Partial.Items.Strings[iCount]) = sSiteName) then
         begin
              sResult := ControlForm.PartialKey.Items.Strings[iCount];
              fFound := True;
         end;

     if not fFound
     and (ControlForm.Flagged.Items.Count > 0) then
     for iCount := 0 to (ControlForm.FlaggedKey.Items.Count-1) do
         if ((ControlForm.Flagged.Items.Strings[iCount]) = sSiteName) then
         begin
              sResult := ControlForm.FlaggedKey.Items.Strings[iCount];
              fFound := True;
         end;

     if not fFound
     and (ControlForm.Excluded.Items.Count > 0) then
     for iCount := 0 to (ControlForm.ExcludedKey.Items.Count-1) do
         if ((ControlForm.Excluded.Items.Strings[iCount]) = sSiteName) then
         begin
              sResult := ControlForm.ExcludedKey.Items.Strings[iCount];
              fFound := True;
         end;

     if not fFound
     and (ControlForm.Reserved.Items.Count > 0) then
     for iCount := 0 to (ControlForm.ReservedKey.Items.Count-1) do
         if ((ControlForm.Reserved.Items.Strings[iCount]) = sSiteName) then
         begin
              sResult := ControlForm.ReservedKey.Items.Strings[iCount];
              fFound := True;
         end;

     if not fFound
     and (ControlForm.Ignored.Items.Count > 0) then
     for iCount := 0 to (ControlForm.IgnoredKey.Items.Count-1) do
         if ((ControlForm.Ignored.Items.Strings[iCount]) = sSiteName) then
         begin
              sResult := ControlForm.IgnoredKey.Items.Strings[iCount];
              fFound := True;
         end;

     Result := StrToInt(sResult);
end;

function FindSite(const iGeocode : integer) : integer;
{this function returns the index of Sgeo in SiteList}
begin
     try
        Result := FindFeatMatch(OrdSiteArr,iGeocode);

     except
           MessageDlg('Exception in FindSite Key is ' + IntToStr(iGeocode),
                      mtError,[mbOk],0);
     end;
end;

function FindFeature(const iFeature : integer) : integer;
{this function returns the index of iFeature in Farray}
begin
     try
        Result := iFeature;

     except
           MessageDlg('Exception in FindFeatMatch iFeature ' +
                      IntToStr(iFeature),mtError,[mbOk],0);
     end;
end;

procedure NewCalcPotential(const ThisSiteArr, ThisFeatArr : Array_T;
                           const fShowProgress : boolean);
var
   iCount, iCount2, iNumAvail,
   iSiteIndex, iFeatIndex, iNumFlg,
   iNumDeferred, iNumPotential, iThisGeocode : integer;
   rValue,
   rInSite, rStillNeeded : extended;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   ASiteCust : SiteCust_T;
   fDebug : boolean;
   Value : ValueFile_T;
begin
     try
        if fShowProgress then
        begin
             ControlForm.ProgressOn; {switch on progress % bar}
             ControlForm.ProcLabelOn('Potential Contribution');
        end;

        new(pSite);
        new(pFeat);

        iNumAvail := ControlForm.Available.Items.Count;
        iNumFlg := ControlForm.Flagged.Items.Count;

        iNumPotential := iNumAvail + iNumFlg;

        InitContribData(iNumPotential);

        if iNumPotential > 0 then
        for iCount := 1 to iNumPotential do
        {iterate Available, Excluded and Flagged sites}
        begin
             if fShowProgress then
                ControlForm.ProgressUpdate(Round((iCount / (iNumAvail + iNumFlg)) * 100));
             {update the % in the % progress gauge}

             if (iCount <= iNumAvail) then
                iThisGeocode := StrToInt(ControlForm.AvailableKey.Items.Strings[iCount-1])
             else
                 iThisGeocode := StrToInt(ControlForm.FlaggedKey.Items.Strings[
                                          iCount-1-iNumAvail]);
             {find current sites geocode}

             // store the site key for this site to be graphed
             GraphSites.setValue(iCount,@iThisGeocode);

             iSiteIndex := FindFeatMatch(OrdSiteArr,iThisGeocode);
             ThisSiteArr.rtnValue(iSiteIndex,pSite);

             ASiteCust.iCode := iThisGeocode;
             ASiteCust.rPercentUsed := 0;
             {set initial contribution values for current site}

             if (pSite^.iKey = 1) then
                fDebug := True;

             {iterate this sites features}
             if (pSite^.richness > 0) then
             for iCount2 := 1 to pSite^.richness do
             begin
                  FeatureAmount.rtnValue(pSite^.iOffset + iCount2,@Value);
                  iFeatIndex := FindFeature(Value.iFeatKey);
                  ThisFeatArr.rtnValue(iFeatIndex,pFeat);

                  if (pFeat^.targetarea > 0) then
                  begin
                       rInSite := Value.rAmount;
                       rStillNeeded := pFeat^.targetarea;
                       if (rStillNeeded > rInSite) then
                          rStillNeeded := rInSite;

                       if (pFeat^.code <= iPCUSEDCutOff) then
                       begin
                            ASiteCust.rPercentUsed := ASiteCust.rPercentUsed +
                                                 rStillNeeded;

                            rValue := rStillNeeded;
                       end
                       else
                           rValue := 0;

                       SparseContribution.setValue(pSite^.iOffSet + iCount2,@rValue);
                  end;
             end;

             if (pSite^.area > 0) then
                ASiteCust.rPercentUsed := ASiteCust.rPercentUsed /
                                          pSite^.area * 100
             else
                 ASiteCust.rPercentUsed := 0;

             if (ASiteCust.rPercentUsed > 100) then
                ASiteCust.rPercentUsed := 100;

             with ControlForm do
                  iNumDeferred := R1.Items.Count +
                                  R2.Items.Count +
                                  R3.Items.Count +
                                  R4.Items.Count +
                                  R5.Items.Count +
                                  Partial.Items.Count;

             SiteContribution.setValue(iSiteIndex,@ASiteCust);
        end;

        dispose(pSite);
        dispose(pFeat);

        if fShowProgress then
        begin
             ControlForm.ProgressOff; {switch off progress % bar}
             ControlForm.ProcLabelOff; {switch off progress label}
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Calculate Potential Contribution',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


function RepdFeatPercentB(const LocalFeatures : Array_T) : extended;
{this function counts how many features are represented and returns a extended value
 indicating the percentage of features that are represented}
var
   iCount, iNumRepd : integer;

   iTotalNonZeroFeats : integer;

   pFeatSubset : FeatureSubsetPointer;
   TmpFeatSubset : FeatureOccurrenceSubset_T;
   AFeat : featureoccurrence;
begin
     iNumRepd := 0;
     pFeatSubset := @TmpFeatSubset;

     for iCount := 1 to LocalFeatures.lMaxSize do
     begin
          LocalFeatures.rtnValue(iCount,pFeatSubset);
          FeatArr.rtnValue(iCount,@AFeat);

          if (AFeat.rTrimmedTarget <> 0)
          and ((TmpFeatSubset.reservedarea + AFeat.reservedarea) >=
                AFeat.rTrimmedTarget) then
              Inc(iNumRepd);
     end;

     iTotalNonZeroFeats := LocalFeatures.lMaxSize -
                           iZeroTrimmedTargetCount;

     if (iTotalNonZeroFeats > 0) then
        Result := (iNumRepd / iTotalNonZeroFeats) * 100
     else
         Result := 0;
end;

function PartialFeatPercent(const LocalFeatures : Array_T) : extended;
{this function returns a measure of average representation percentage
 for all features which is order dependant}
var
   iCount : integer;
   rTotal, rThisPercent : extended;

   TmpFeatSubset : FeatureOccurrenceSubset_T;
   pFeatSubset : FeatureSubsetPointer;
begin
     rTotal := 0;
     pFeatSubset := @TmpFeatSubset;

     for iCount := 1 to LocalFeatures.lMaxSize do
     begin
          LocalFeatures.rtnValue(iCount,pFeatSubset);

          {if (TmpFeatSubset.targetarea <= 0) then
             rThisPercent := 100
          else}

          if (TmpFeatSubset.targetarea > 0) then
             rThisPercent := ( TmpFeatSubset.reservedarea /
                               TmpFeatSubset.targetarea ) * 100
          else
              rThisPercent := 0;

          if (rThisPercent > 100) then
             rThisPercent := 100;

          rTotal := rTotal + rThisPercent;
     end;

     if (LocalFeatures.lMaxSize > 0) then
        Result := rTotal / LocalFeatures.lMaxSize
     else
         Result := 0;
end;

procedure TContributionForm.Button1Click(Sender: TObject);
begin
     SaveGraphic.InitialDir := ControlRes^.sWorkingDirectory;
     SaveGraphic.FileName := 'sample.bmp';

     if SaveGraphic.Execute then
     begin
          GraphImage.Picture.SaveToFile(SaveGraphic.FileName);
     end;
end;

function GetTop(const rScaleFactor, rValue : extended;
                const iHeight : integer) : integer;
begin
     if (rScaleFactor > 0) then
        Result := iHeight
           - Round(((rValue / 100) / rScaleFactor) * (iHeight-(2*GRAPH_EDGE_SPACE)))
           - GRAPH_EDGE_SPACE
     else
         Result := iHeight - GRAPH_EDGE_SPACE;
         {rScaleFactor is zero}
end;

procedure EmptyCanvas;
var
   MyRect : TRect;
begin
     MyRect := Rect(0,0,(ContributionForm.GraphImage.Width-1)
                    ,(ContributionForm.GraphImage.Height-1));

     ContributionForm.GraphImage.Canvas.Brush.Color := clWhite;
     ContributionForm.GraphImage.Canvas.FillRect(MyRect);
end;

procedure TopCaption(const sLine : string);
begin
     ContributionForm.GraphImage.Canvas.Brush.Color := clWhite;

     ContributionForm.GraphImage.Canvas.TextOut(
             (ContributionForm.GraphImage.Width
              - ContributionForm.GraphImage.Canvas.TextWidth(sLine)) div 2, 1, sLine );
end;

procedure DrawDashes(const lX,lY1,lY2 : longint);
{plots on yaxis for lX>0
          xaxis for lX<0}
var
   lCount, lSteps : longint;
begin
     lSteps := lY1 - lY2;
     if (lSteps < 0) then
        lSteps := -lSteps;
     lSteps := lSteps div (DASH_STEP_SIZE*2);
     Inc(lSteps);

     if (lSteps > 0) then
        for lCount := 0 to (lSteps-1) do
            if (lX > 0) then
            begin
                 ContributionForm.GraphImage.Canvas.PenPos :=
                       Point(lX,lY1-(lCount*DASH_STEP_SIZE*2));
                 ContributionForm.GraphImage.Canvas.LineTo(
                       lX,lY1-(lCount*DASH_STEP_SIZE*2)-DASH_STEP_SIZE);
            end
            else
            begin
                 ContributionForm.GraphImage.Canvas.PenPos :=
                       Point(lY1+(lCount*DASH_STEP_SIZE*2),-lX);
                 ContributionForm.GraphImage.Canvas.LineTo(
                       lY1+(lCount*DASH_STEP_SIZE*2)+DASH_STEP_SIZE,-lX);
            end;
end;


procedure PercentLine(const rPercent, rScaleFactor : extended;
                      const iWidth : integer);
var
   iY, iPercent : integer;
   sPercent : string;
   rMappedValue : extended;
begin
     rMappedValue := rPercent * rScaleFactor;

     with ContributionForm.GraphImage do
     begin
          iY := GetTop(rScaleFactor, rMappedValue, Height);

          if ContributionForm.checkHorzGrid.Checked then
             DrawDashes(-iY,GRAPH_EDGE_SPACE,iWidth+GRAPH_EDGE_SPACE)
          else
          begin
               ContributionForm.GraphImage.Canvas.PenPos :=
                       Point(GRAPH_EDGE_SPACE,iY+1);
               ContributionForm.GraphImage.Canvas.LineTo(
                       iWidth+GRAPH_EDGE_SPACE,iY+1);
          end;

          Canvas.Brush.Color := clWhite;

          iPercent := Round(rPercent*rScaleFactor);

          sPercent := IntToStr(iPercent) + '%';

          Canvas.TextOut(
               (GRAPH_EDGE_SPACE - 1 - Canvas.TextWidth(sPercent)),
               (iY - (Canvas.TextHeight(sPercent) div 2)), sPercent);
     end;
end;

procedure PlotLines(const rScaleFactor : extended; const iWidth : integer);
var
   iNumLines, iCount : integer;
   rLineValue : extended;
begin
     iNumLines := 1;

     case ContributionForm.selectGradient.ItemIndex of
          0 : iNumLines := 1;
          1 : iNumLines := 2;
          2 : iNumLines := 5;
          3 : iNumLines := 10;
     end;

     for iCount := 1 to iNumLines do
     begin
          rLineValue := iCount*(100/iNumLines);
          PercentLine(rLineValue,rScaleFactor,iWidth);
     end;
end;

procedure DrawBarNameText(sToDraw:string; iTextY, iStep, iLeft : integer);
var
   iLength, iTextX : integer;
   fStop : boolean;
   sCut : string;
begin
     iLength := Length(sToDraw);
     fStop := False;

     if (iLength > 0) then
        repeat
              sCut := Copy(sToDraw,1,iLength);

              if (ContributionForm.GraphImage.Canvas.TextWidth(sCut) <= iStep) then
              begin
                   iTextX := iLeft + (iStep div 2)
                             - (ContributionForm.GraphImage.Canvas.TextWidth(sCut) div 2);

                   fStop := True;
                   ContributionForm.GraphImage.Canvas.TextOut(iTextX,iTextY,sCut);
              end;

              Dec(iLength);

        until fStop or (iLength<1);
end;

procedure DrawFeatureBars(const iSiteIndex : integer);
var
   iCount, wNumBars, iStep, iLeft, iSiteKey,
   iRight, iTop, iBottom, iTextX, iTextY, iSIdx, iFIdx: integer;
   sText, sCaption : string;
   rMaxVal, rScaleFactor, rValue : extended;
   MyRect : TRect;
   TmpSiteCust : SiteCust_T;
   ASite : site;
   AFeat : featureoccurrence;
   fPartialOff, fReserved : boolean;
   Value : ValueFile_t;

begin     {draw the appropriate sites feature bars, depending on mouse position on X Site graph}
     try
        if (iSiteIndex > 0)
        {and (iSiteIndex <= GraphContribution.Sites.lMaxSize)
        and (iSiteIndex <= GraphContribution.Features.lMaxSize) then}
        and (iSiteIndex <= GraphSites.lMaxSize) then
        begin
             iGraphState := BY_FEATURE;
             EmptyCanvas;
             ContributionForm.GraphImage.Hint := 'Click to return to %  X  Site view';

             //GraphContribution.Features.rtnValue(iSiteIndex,pFeatCust);
             //GraphContribution.Sites.rtnValue(iSiteIndex,pSiteCust);
             GraphSites.rtnValue(iSiteIndex,@iSiteKey);
             iSIdx := FindFeatMatch(OrdSiteArr,iSiteKey);
             SiteArr.rtnValue(iSIdx,@ASite);
             SiteContribution.rtnValue(iSIdx,@TmpSiteCust);

             //wNumBars := TmpFeatCust.iCount;
             wNumBars := ASite.richness;

             if (wNumBars > 0) then
                iStep := (ContributionForm.GraphImage.Width-(2*GRAPH_EDGE_SPACE)) div wNumBars
             else
                 iStep := 0;

             fTruncated := False;
             if (iStep > (ContributionForm.GraphImage.Width div 5)) then
             begin
                  iStep := ContributionForm.GraphImage.Width div 5;
                  iTruncStep := iStep;
                  fTruncated := True;
             end;

             rMaxVal := 0;
             for iCount := 1 to wNumBars do
             begin
                  SparseContribution.rtnValue(ASite.iOffSet + iCount,@rValue);
                  if (rValue > 100) then
                  begin
                       rValue := 100;
                       SparseContribution.setValue(ASite.iOffSet + iCount,@rValue);
                  end;
                  if (rValue > rMaxVal) then
                     rMaxVal := rValue;
                  {
                  if (TmpFeatCust.rValue[iCount] > 100) then
                     TmpFeatCust.rValue[iCount] := 100;

                  if (TmpFeatCust.rValue[iCount] > rMaxVal) then
                     rMaxVal := TmpFeatCust.rValue[iCount];
                  }
             end;

             rScaleFactor := rMaxVal / 100;

             if (iStep > 0) then {if width large enough}
                for iCount := 1 to wNumBars do
                begin
                     {if site is partially deferred
                      and feature is not deferred}
                     SparsePartial.rtnValue(ASite.iOffset + iCount,@fReserved);
                     if (ASite.status = Pd)
                     and fReserved then
                     begin
                          fPartialOff := True;
                     end
                     else
                     begin
                          fPartialOff := False;
                     end;

                     SparseContribution.rtnValue(ASite.iOffSet + iCount,@rValue);

                     {draw bar iCount}
                     iLeft := (iCount-1)*iStep + 1 + GRAPH_EDGE_SPACE;
                     iTop := GetTop(rScaleFactor,
                                    rValue{TmpFeatCust.rValue[iCount]},
                                    ContributionForm.GraphImage.Height);
                     iRight := iCount*iStep + GRAPH_EDGE_SPACE;
                     iBottom := ContributionForm.GraphImage.Height - GRAPH_EDGE_SPACE;

                     MyRect := Rect(iLeft,iTop,iRight,iBottom);
                     {left,top,right,bottom}

                     with ContributionForm.GraphImage.Canvas do
                     begin
                          if fPartialOff then
                          begin
                               Brush := ContributionForm.shAvail.Brush;
                          end
                          else
                          begin
                               //if (TmpFeatCust.rValue[iCount] >= 100) then
                               if (rValue >= 100) then
                                  Brush := ContributionForm.shFull.Brush
                               else
                                   Brush := ContributionForm.shLow.Brush;
                          end;
                     end;

                     ContributionForm.GraphImage.Canvas.FillRect(MyRect);

                     ContributionForm.GraphImage.Canvas.Brush.Style := bsSolid;
                     ContributionForm.GraphImage.Canvas.Brush.Color := clWhite;
                     if ContributionForm.checkVertGrid.checked
                     and (iCount <> wNumBars) then
                         {draw vertical line on grid}
                         DrawDashes(iRight,iBottom,GRAPH_EDGE_SPACE);

                     {write the feature NAME under the bar}
                     //iFIdx := FindFeature(integer(TmpFeatCust.wCode[iCount]));
                     FeatureAmount.rtnValue(ASite.iOffSet + iCount,@Value);
                     FeatArr.rtnValue(Value.iFeatKey,@AFeat);
                     sText := AFeat.sID;
                     {iTextX := iLeft + (iStep div 2)
                        - (ContributionForm.GraphImage.Canvas.TextWidth(sText) div 2);  }
                     iTextY := iBottom + 1;

                     DrawBarNameText(sText, iTextY, iStep, iLeft);
                     {if (ContributionForm.GraphImage.Canvas.TextWidth(sText) <= iStep) then
                        ContributionForm.GraphImage.Canvas.TextOut(iTextX,iTextY,sText);}
                end;

             if (wNumBars = 0) then
             begin
                  sCaption := FindSiteName(TmpSiteCust.iCode) + ' - NO FEATURES AVAILABLE';
                  TopCaption(sCaption);
             end
             else
             begin
                  sCaption := 'Features at site ' + ASite.sName;
                  TopCaption('% contribution to remaining target for features  at  site ' +
                             ASite.sName);
             end;

             ContributionForm.Caption := sCaption;
             PlotLines(rScaleFactor, iStep*wNumBars);
        end
        else
        begin
             Screen.Cursor := crDefault;
             MessageDlg('DrawFeatureBars iSiteIndex out of range ' + IntToStr(iSiteIndex),
                        mtError,[mbOk],0);
        end;
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DrawFeatureBars',
                      mtError,[mbOk],0);
     end;
end;


procedure DrawSiteBars;
var
   iCount, wNumBars : integer;
   iStep, iLeft, iRight, iTop, iBottom, iTextX, iTextY : integer;
   sText, sCaption : string;
   rMaxVal, rScaleFactor, rToPlot : extended;
   MyRect : TRect;
   TmpSiteCust : SiteCust_T;
   ASite : site;
   iSiteIndex, iSiteKey : integer;
begin
     iGraphState := BY_SITE;
     EmptyCanvas;
     ContributionForm.GraphImage.Hint := 'Click on a site to see its feature breakdown';

     wNumBars := GraphSites.lMaxSize;

     if (ContributionForm.selectPlotData.ItemIndex = 1) then
        Inc(wNumBars);
        {make space for 'Reserved Sites' bar}

     iStep := (ContributionForm.GraphImage.Width-(2*GRAPH_EDGE_SPACE)) div wNumBars;
     fTruncated := False;
     if (iStep > (ContributionForm.GraphImage.Width div 5)) then
     begin
          iStep := ContributionForm.GraphImage.Width div 5;
          iTruncStep := iStep;
          fTruncated := True;
     end;

     if (iStep <= 2) then
     begin
          Screen.Cursor := crDefault;
          MessageDlg('You have too many deferred sites to display',
                     mtInformation,[mbOk],0);
     end
     else
     begin
          try
             if (ContributionForm.selectPlotData.ItemIndex = 1) then
                rMaxVal := rReservedContrib
             else
                 rMaxVal := 0;
             {set the minimum value for display height to start}

             for iCount := 1 to GraphSites.lMaxSize do
             begin
                  {checks the users selection for Plot Data Type
                   and finds the largest value in the dataset for
                   scaling the image and gridlines with}
                  GraphSites.rtnValue(iCount,@iSiteKey);
                  iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
                  SiteContribution.rtnValue(iSiteIndex,@TmpSiteCust);

                  rToPlot := 0;
                  case ContributionForm.selectPlotData.ItemIndex of
                       0 : rToPlot := TmpSiteCust.rPercentUsed;
                       1 : rToPlot := TmpSiteCust.rValue2;
                  end;

                  if (rToPlot > rMaxVal) then
                     rMaxVal := rToPlot;

                  if (rToPlot < 0) then
                  begin
                       rToPlot := 0;
                  end;
             end;

             rScaleFactor := rMaxVal / 100;
             if (rScaleFactor = 0) then
                rScaleFactor := 1;
             {if scale factor is 0, it will trigger a divide by zero error}

             if (iStep > 0) then {if width large enough}
                for iCount := 1 to wNumBars do
                begin
                     {draw bar iCount}
                     case ContributionForm.selectPlotData.ItemIndex of
                          1 :
                          begin
                               if (iCount > 1) then
                               begin
                                    GraphSites.rtnValue(iCount-1,@iSiteKey);
                                    iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
                                    SiteContribution.rtnValue(iSiteIndex,@TmpSiteCust);

                                    rToPlot := TmpSiteCust.rValue2;
                               end

                               else
                                   rToPlot := rReservedContrib;
                          end;
                          0 :
                          begin
                               GraphSites.rtnValue(iCount,@iSiteKey);
                               iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
                               SiteContribution.rtnValue(iSiteIndex,@TmpSiteCust);

                               rToPlot := TmpSiteCust.rPercentUsed;
                          end;
                     end;

                     if (rToPlot < 0) then
                        rToPlot := 0;
                     {select which variable to plot}

                     iLeft := (iCount-1)*iStep + 1 + GRAPH_EDGE_SPACE;
                     iTop := GetTop(rScaleFactor,rToPlot,ContributionForm.GraphImage.Height);
                     iRight := iCount*iStep + GRAPH_EDGE_SPACE;
                     iBottom := ContributionForm.GraphImage.Height - GRAPH_EDGE_SPACE;

                     MyRect := Rect(iLeft,iTop,iRight,iBottom);
                     {left,top,right,bottom}

                     iSiteIndex := FindFeatMatch(OrdSiteArr,TmpSiteCust.iCode);
                     SiteArr.rtnValue(iSiteIndex,@ASite);

                     with ContributionForm.GraphImage.Canvas do
                     if (ContributionForm.selectPlotData.ItemIndex = 1) then
                     begin
                          if (iCount = 1) then
                              Brush := ContributionForm.shRes.Brush
                          else
                              if (ASite.status = _R2) then
                                 Brush := ContributionForm.shMan.Brush
                              else
                                  if (ASite.status = _R1) then
                                     Brush := ContributionForm.shNeg.Brush
                                  else
                                      if (ASite.status = Pd) then
                                         Brush := ContributionForm.shPar.Brush
                                      else
                                          Brush.Color := clBlack;
                     end
                     else
                     begin
                          if (ASite.status = _R2) then
                             Brush := ContributionForm.shMan.Brush
                          else
                              if (ASite.status = _R1) then
                                 Brush := ContributionForm.shNeg.Brush
                              else
                                  if (ASite.status = Pd) then
                                     Brush := ContributionForm.shPar.Brush
                                  else
                                      Brush.Color := clBlack;
                     end;

                     ContributionForm.GraphImage.Canvas.FillRect(MyRect);

                     ContributionForm.GraphImage.Canvas.Brush.Style := bsSolid;
                     ContributionForm.GraphImage.Canvas.Brush.Color := clWhite;
                     if ContributionForm.checkVertGrid.checked
                     and (iCount <> wNumBars) then
                         {draw vertical line on grid}
                         DrawDashes(iRight,iBottom,GRAPH_EDGE_SPACE);

                     if (ContributionForm.selectPlotData.ItemIndex = 1)
                     and (iCount = 1) then
                     begin
                          {don't print a site NAME under the reserved sites bar}
                     end
                     else
                     begin
                          {write the site NAME under the bar}
                          sText := ASite.sName;
                          iTextX := iLeft + (iStep div 2)
                             - (ContributionForm.GraphImage.Canvas.TextWidth(sText) div 2);
                          iTextY := iBottom + 1;

                          DrawBarNameText(sText,iTextY,iStep,iLeft);

                          {if (ContributionForm.GraphImage.Canvas.TextWidth(sText) <= iStep) then
                             ContributionForm.GraphImage.Canvas.TextOut(iTextX,iTextY,sText);}
                     end;
                end;


             case ContributionForm.selectPlotData.ItemIndex of
                  0 : begin
                           sCaption := ControlRes^.sR1Label+', '+ControlRes^.sR2Label
                                       +', '+ControlRes^.sR3Label+', '+ControlRes^.sR4Label+', '+ControlRes^.sR5Label
                                       +' and Partial sites';
                           TopCaption('% of site area contributing to representation  at  ' + sCaption);
                      end;
                  1 : begin
                           sCaption := 'Reserved, '+ControlRes^.sR1Label+', '+ControlRes^.sR2Label
                                       +', '+ControlRes^.sR3Label+', '+ControlRes^.sR4Label+', '+ControlRes^.sR5Label
                                       +' and Partial sites';
                           TopCaption('% of features satisfied  by  ' + sCaption);
                      end;
             end;

             ContributionForm.Caption := sCaption;

             PlotLines(rScaleFactor, iStep*wNumBars);

          except
                Screen.Cursor := crDefault;
                MessageDlg('Exception in DrawSiteBars',mtError,[mbOk],0);
          end;
     end;
end;

procedure TContributionForm.GraphImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   wOldCursor : integer;
   iNumBars : integer;
begin
     {this is where we swap between site graphs
      and feature graphs on the users click}
     try
     wOldCursor := Screen.Cursor;
     Screen.Cursor := crHourglass;

     if (iGraphState = BY_FEATURE) then
        iGraphState := BY_SITE
     else
         iGraphState := BY_FEATURE;

     case iGraphState of
          BY_FEATURE : begin
                         //iNumBars := GraphContribution.Features.lMaxSize;
                         iNumBars := GraphSites.lMaxSize;
                         if (selectPlotData.ItemIndex = 1) then
                            Inc(iNumBars);

                         if fTruncated then
                            iSiteIndex := ((X - GRAPH_EDGE_SPACE) div iTruncStep) + 1
                         else
                             iSiteIndex := ((X - GRAPH_EDGE_SPACE)
                                div ((ContributionForm.GraphImage.Width-(2*GRAPH_EDGE_SPACE))
                                div iNumBars)) + 1;
                         if (X < GRAPH_EDGE_SPACE) then
                            iSiteIndex := 0;

                         if (ContributionForm.selectPlotData.ItemIndex = 1) then
                            Dec(iSiteIndex);
                         {this is to take into account the Reserved sites
                          contribution bar}

                         if (X >= GRAPH_EDGE_SPACE)
                         and (iSiteIndex > 0)
                         {and (iSiteIndex <= GraphContribution.Features.lMaxSize) }
                         and (Y >= GRAPH_EDGE_SPACE)
                         and (Y <= (ContributionForm.GraphImage.Height - GRAPH_EDGE_SPACE)) then
                            FormResize(self)
                         else
                         begin
                             iGraphState := BY_SITE;
                             {change back to site view because no site was selected}
                         end;
                       end;
          BY_SITE : FormResize(self);
     end;

     finally
            Screen.Cursor := wOldCursor;
     end;
end;

procedure TContributionForm.btnPrintClick(Sender: TObject);
var
   MyGraphic : TGraphic;
begin
     {print the current image}

     MyGraphic := TGraphic.Create;

     GraphImage.Picture.SaveToFile('c:\x.bmp');
     MyGraphic.LoadFromFile('c:\x.bmp');

     with Printer do
     begin
          BeginDoc;
          Canvas.Draw(0,0,MyGraphic);
          EndDoc;
     end;

     MyGraphic.Free;
end;

procedure TContributionForm.btnFontClick(Sender: TObject);
begin
     CanvasFont.Font := GraphImage.Canvas.Font;
     if CanvasFont.Execute then
     begin
          GraphImage.Canvas.Font := CanvasFont.Font;

          {trigger screen repaint}
          selectPlotDataClick(self);
     end;
end;

procedure TContributionForm.selectPlotDataClick(Sender: TObject);
var
   wOldCursor : integer;
begin
     wOldCursor := Screen.Cursor;
     Screen.Cursor := crHourglass;

     FormResize(self);

     Screen.Cursor := wOldCursor;
end;

procedure TContributionForm.selectGradientClick(Sender: TObject);
var
   wOldCursor : integer;
begin
     wOldCursor := Screen.Cursor;
     Screen.Cursor := crHourglass;

     FormResize(self);

     Screen.Cursor := wOldCursor;
end;

procedure TContributionForm.GraphImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
   iFeatIndex, iNumBars, iFPos, iSiteKey, iSIdx : integer;
   TmpSiteCust : SiteCust_T;
   //pSiteCust : SiteCustPointer;
   //TmpFeatCust : FeatureCust_T;
   //pFeatCust : FeatureCustPointer;
   pFeat : featureoccurrencepointer;
   pSite : sitepointer;
   sTmp : string;
   Value : ValueFile_T;
   rValue : extended;
begin
     try
     if (iGraphState = BY_SITE) then
     begin
          {user is moving over site graph}

          //iNumBars := GraphContribution.Features.lMaxSize;
          iNumBars := GraphSites.lMaxSize;
          if (ContributionForm.selectPlotData.ItemIndex = 1) then
             Inc(iNumBars);

          if fTruncated then
             iSiteIndex := ((X - GRAPH_EDGE_SPACE) div iTruncStep) + 1
          else
              iSiteIndex := ((X - GRAPH_EDGE_SPACE)
                  div ((ContributionForm.GraphImage.Width-(2*GRAPH_EDGE_SPACE))
                  div iNumBars)) + 1;

          if (ContributionForm.selectPlotData.ItemIndex = 1) then
             Dec(iSiteIndex);

          if (X >= GRAPH_EDGE_SPACE)
          {and (iSiteIndex <= GraphContribution.Features.lMaxSize)}
          and (iSiteIndex <= GraphSites.lMaxSize)
          and (Y >= GRAPH_EDGE_SPACE)
          and (Y <= (ContributionForm.GraphImage.Height - GRAPH_EDGE_SPACE)) then
          begin
               if (iSiteIndex = 0) then
               begin
                    labelSiteName.Caption := 'Selected Sites';
                    Str(rReservedContrib:8:1,sTmp);
                    labelValue.Caption := 'Value: ' + sTmp + ' %';
                    labelSiteName.Width := 240;
                    labelValue.Width := 240;
               end
               else
               if (iSiteIndex <= GraphSites.lMaxSize) then
               begin
                    {GraphContribution.Sites.sCode[iSiteIndex] is the geocode for this site}

                    //pSiteCust := @TmpSiteCust;
                    //GraphContribution.Sites.rtnValue(iSiteIndex,pSiteCust);
                    GraphSites.rtnValue(iSiteIndex,@iSiteKey);
                    iSIdx := FindFeatMatch(OrdSiteArr,iSiteKey);
                    SiteContribution.rtnValue(iSIdx,@TmpSiteCust);

                    labelSiteName.Caption :=
                       'Site: ' + FindSiteName(TmpSiteCust.iCode);

                    {now display the value for this site}
                    case ContributionForm.selectPlotData.ItemIndex of
                         {0 : labelValue.Caption := Float2String( TmpSiteCust.rValue, 1 ) + ' %';}
                         0 :
                         begin
                              Str(TmpSiteCust.rPercentUsed:8:1,sTmp);
                              labelValue.Caption := 'Value: ' + sTmp + ' %';
                         end;
                         1 :
                         begin
                              Str(TmpSiteCust.rValue2:8:1,sTmp);
                              labelValue.Caption := 'Value: ' + sTmp + ' %';
                         end;
                    end;
                    {select which variable for this site to display (rValue or rPercentUsed)
                     based on the user selection}

                    labelSiteName.Width := 240;
                    labelValue.Width := 240;
               end;
          end
          else
          begin
               labelSiteName.Caption := '';
               labelValue.Caption := '';
          end;
     end
     else
     begin
          {display the value of the feature under pointer,
           we must be on a feature graph}

          //pFeatCust := @TmpFeatCust;
          //GraphContribution.Features.rtnValue(iSiteIndex,pFeatCust);
          GraphSites.rtnValue(iSiteIndex,@iSiteKey);
          iSIdx := FindFeatMatch(OrdSiteArr,iSiteKey);
          new(pSite);
          SiteArr.rtnValue(iSIdx,pSite);

          //if (TmpFeatCust.iCount > 0) then
          if (pSite^.richness > 0) then
          begin
               if fTruncated then
                  iFeatIndex := ((X - GRAPH_EDGE_SPACE) div iTruncStep) + 1
               else
                   iFeatIndex := ((X - GRAPH_EDGE_SPACE)
                       div ((ContributionForm.GraphImage.Width-(2*GRAPH_EDGE_SPACE))
                       div pSite^.richness)) + 1;
                   {iFeatIndex := ((X - GRAPH_EDGE_SPACE)
                       div ((ContributionForm.GraphImage.Width-(2*GRAPH_EDGE_SPACE))
                       div TmpFeatCust.iCount)) + 1}

               if (X >= GRAPH_EDGE_SPACE)
               and (iFeatIndex > 0)
               //and (iFeatIndex <= TmpFeatCust.iCount)
               and (iFeatIndex <= pSite^.richness)
               and (Y >= GRAPH_EDGE_SPACE)
               and (Y <= (ContributionForm.GraphImage.Height - GRAPH_EDGE_SPACE)) then
               begin
                    new(pFeat);

                    FeatureAmount.rtnValue(pSite^.iOffset + iFeatIndex,@Value);

                    //iFPos := FindFeature(integer(TmpFeatCust.wCode[iFeatIndex]));
                    FeatArr.rtnValue(Value.iFeatKey,pFeat);
                    labelSiteName.Caption := 'Feature: ' + pFeat^.sID;
                    //Str(TmpFeatCust.rValue[iFeatIndex]:8:1,sTmp);
                    SparseContribution.rtnValue(pSite^.iOffSet + iFeatIndex,@rValue);
                    Str(rValue:8:1,sTmp);
                    labelValue.Caption := 'Value: ' + sTmp + ' %';

                    dispose(pFeat);
               end
               else
               begin
                    labelValue.Caption := '';
                    labelSiteName.Caption := '';
               end;
          end
          else
          begin
               labelValue.Caption := 'NO FEATURES';
          end;

          dispose(pSite);
     end;
     except
     end;
end;

procedure TContributionForm.FormResize(Sender: TObject);
begin
     Panel1.Width := ClientWidth;
     GraphImage.Width := ClientWidth;
     GraphImage.Height := ClientHeight - Panel1.Height;

     {This is where we must repaint the screen}

     labelSiteName.Caption := '';
     labelValue.Caption := '';
     {reset labels which track mouse movement over canvas}

     if (GraphSites <> nil) then
        case iGraphState of
             BY_FEATURE : DrawFeatureBars(iSiteIndex);
             BY_SITE : DrawSiteBars;
        end;
end;

procedure TContributionForm.btnCopyClick(Sender: TObject);
begin
     Clipboard.Assign(GraphImage.Picture);
end;

procedure TContributionForm.btnColorClick(Sender: TObject);
begin
     ColorForm.ShowModal;
     selectGradientClick(self);
end;

procedure TContributionForm.Exit1Click(Sender: TObject);
begin
     BitBtn1Click(self);
     ModalResult := mrOK;
end;

procedure TContributionForm.N11Click(Sender: TObject);
begin
     SelectGradient.ItemIndex := 0;
     selectGradientClick(self);
end;

procedure TContributionForm.N21Click(Sender: TObject);
begin
     SelectGradient.ItemIndex := 1;
     selectGradientClick(self);
end;

procedure TContributionForm.N51Click(Sender: TObject);
begin
     SelectGradient.ItemIndex := 2;
     selectGradientClick(self);
end;

procedure TContributionForm.N101Click(Sender: TObject);
begin
     SelectGradient.ItemIndex := 3;
     selectGradientClick(self);
end;

procedure TContributionForm.Target1Click(Sender: TObject);
begin
     selectPlotData.ItemIndex := 1;
     selectGradientClick(self);
end;

procedure TContributionForm.Area1Click(Sender: TObject);
begin
     selectPlotData.ItemIndex := 0;
     selectGradientClick(self);
end;

procedure TContributionForm.VerticalGrid1Click(Sender: TObject);
begin
     checkVertGrid.Checked := not checkVertGrid.Checked;
     VerticalGrid1.Checked := checkVertGrid.Checked;
     selectGradientClick(self);
end;

procedure TContributionForm.HorizontalGrid1Click(Sender: TObject);
begin
     checkHorzGrid.Checked := not checkHorzGrid.Checked;
     HorizontalGrid1.Checked := checkHorzGrid.Checked;
     selectGradientClick(self);
end;

procedure TContributionForm.BitBtn1Click(Sender: TObject);
begin
     //FreeContribData;
     //ColorForm.Free;
     {frees color form}
end;

procedure TContributionForm.btnFeatTableClick(Sender: TObject);
begin
     try
        FeaturesToTargetForm := TFeaturesToTargetForm.Create(Application);
        Visible := False;
        FeaturesToTargetForm.ShowModal;
     finally
            Visible := True;
            FeaturesToTargetForm.Free;
     end;
end;

procedure TContributionForm.shResMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     BarColor.Color := shRes.Brush.Color;
     if BarColor.Execute then
        shRes.Brush.Color := BarColor.Color;

end;

procedure TContributionForm.shNegMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     BarColor.Color := shMan.Brush.Color;
     if BarColor.Execute then
        shMan.Brush.Color := BarColor.Color;

end;

procedure TContributionForm.shManMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     BarColor.Color := shNeg.Brush.Color;
     if BarColor.Execute then
        shNeg.Brush.Color := BarColor.Color;
end;

procedure TContributionForm.shParMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     BarColor.Color := shPar.Brush.Color;
     if BarColor.Execute then
        shPar.Brush.Color := BarColor.Color;
end;

procedure TContributionForm.shLowMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     BarColor.Color := shLow.Brush.Color;
     if BarColor.Execute then
        shLow.Brush.Color := BarColor.Color;
end;

procedure TContributionForm.shFullMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     BarColor.Color := shFull.Brush.Color;
     if BarColor.Execute then
        shFull.Brush.Color := BarColor.Color;
end;

procedure TContributionForm.shAvailMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     BarColor.Color := shAvail.Brush.Color;
     if BarColor.Execute then
        shAvail.Brush.Color := BarColor.Color;

end;

procedure TContributionForm.Print1Click(Sender: TObject);
begin
     PrintScale := poPrintToFit;
     Print;
end;

procedure TContributionForm.FormActivate(Sender: TObject);
begin
     FormResize(self);
end;

procedure TContributionForm.FormCreate(Sender: TObject);
var
   iDisplaySiteCount : integer;
begin
     shAvail.Brush.Color := clLime;

     iGraphState := BY_SITE;
     iSiteIndex := 1;

     GraphImage.Canvas.Font.Name := 'SmallFonts';
     GraphImage.Canvas.Font.Size := 7;

     ColorForm := TColorForm.Create(Application);
     {create colour form for user-selectable colours}

     //SpinNumSites.MaxValue := GraphContribution.Features.lMaxSize + 1;
     SpinNumSites.MinValue := 1;

     iDisplaySiteCount := LoadDisplaySiteCount;

     if (iDisplaySiteCount <= SpinNumSites.MaxValue) then
        SpinNumSites.Value := iDisplaySiteCount
     else
         SpinNumSites.Value := SpinNumSites.MaxValue;
end;
//{$ENDIF}

procedure TContributionForm.FormDestroy(Sender: TObject);
begin
     FreeContribData;
     ColorForm.Free;
end;

end.
