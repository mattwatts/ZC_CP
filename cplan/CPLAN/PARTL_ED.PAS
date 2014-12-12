unit Partl_ed;
{for editing and viewing partially deferred sites}

{
  Sparse matrix to represent partial deferral,

  same number of records and same indexing system as FeatureAmount,

  data type of boolean,

  set all values to zero at startup,


}

{$I STD_DEF.PAS}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, StdCtrls, ExtCtrls, Buttons,
  {$IFDEF bit16}
  Arrayt16;
  {$ELSE}
  ds;
  {$ENDIF}

type
  TPartEdForm = class(TForm)
    Panel1: TPanel;
    SiteBox: TListBox;
    FeatGrid: TStringGrid;
    SiteCodeBox: TListBox;
    BitBtn1: TBitBtn;
    lblInfo: TLabel;
    Button1: TButton;
    btnReserveAll: TButton;
    procedure SiteBoxClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FeatGridClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnReserveAllClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PartEdForm: TPartEdForm;
  iCurrGeocode : integer;
  wPartEdFlag : word;
  fUseContribData, fInitDone,
  fASiteClicked : boolean;
  SparsePartial : Array_t;


procedure SortGrid(var AGrid : TStringGrid;
                   const iRowStartIndex, iColIndex : integer;
                   const wSortType, wSortDirection : word);
{sorts a TStringGrid object}

procedure Partial2PBox(var PBox : TListBox);
procedure PBox2Partial(var PBox : TListBox);
function CustCompare(const sOne, sTwo : string;
                     const wSortType, wSortDirection : word) : boolean;

procedure TestPartialSites(var aSitesToTest : Array_T);
procedure TestPartialSitesToDeselect(var aSitesToTest : Array_T);
procedure InitSparsePartialStructure;
procedure FreeSparsePartialStructure;

implementation

uses
    Em_newu1, Global, Contribu, Control,
    Sf_irrep, Pred_sf4, Opt1, Calcdef,
    Pred_sf3, Dbmisc,
    auto_fit;

{$R *.DFM}

procedure InitSparsePartialStructure;
var
   iCount : integer;
   fFlag : boolean;
begin
     // call this at startup to create and initialise the sparse partial structure

     // NOTE : Must be called after sparse matrix loaded as it reads its dimensions from that.

     try
        SparsePartial := Array_t.Create;
        SparsePartial.init(SizeOf(boolean),FeatureAmount.lMaxSize);
        fFlag := False;
        for iCount := 1 to SparsePartial.lMaxSize do
            SparsePartial.setValue(iCount,@fFlag);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in InitSparsePartialStructure',mtError,[mbOk],0);
     end;
end;

procedure FreeSparsePartialStructure;
begin
     // call this at shutdown to dispose of the sparse partial structure
     try
        SparsePartial.Destroy;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in FreeSparsePartialStructure',mtError,[mbOk],0);
     end;
end;

procedure TestPartialSites(var aSitesToTest : Array_T);
var
   lResultLen, lCount, lSiteIndex, lFeatCount : longint;
   iValue : integer;
   pSite : sitepointer;
   fNoDeferrals, fReserved : boolean;
   aResultArr : Array_T;

   procedure AddToArr(const iGeocode : integer);
   begin
        Inc(lResultLen);
        if (lResultLen > aResultArr.lMaxSize) then
           aResultArr.resize(aResultArr.lMaxSize + ARR_STEP_SIZE);
        aResultArr.setValue(lResultLen,@iGeocode);
   end;

begin
     if (aSitesToTest.lMaxSize > 0) then
     begin
          try
             aResultArr := Array_T.Create;
             aResultArr.init(SizeOf(integer),ARR_STEP_SIZE);
             lResultLen := 0;
             new(pSite);

             for lCount := 1 to aSitesToTest.lMaxSize do
             begin
                  aSitesToTest.rtnValue(lCount,@iValue);
                  lSiteIndex := FindFeatMatch(OrdSiteArr,iValue);
                  SiteArr.rtnValue(lSiteIndex,pSite);
                  fNoDeferrals := True;

                  if (pSite^.richness > 0) then
                     for lFeatCount := 1 to pSite^.richness do
                     begin
                          SparsePartial.rtnValue(pSite^.iOffset + lFeatCount,@fReserved);
                          if fReserved then
                             fNoDeferrals := False;
                     end;

                  if not fNoDeferrals then
                     AddToArr(iValue);
             end;

             if (lResultLen <= 0) then
             begin
                  aSitesToTest.resize(1);
                  aSitesToTest.lMaxSize := 0;
             end
             else
                 if (aResultArr.lMaxSize > lResultLen) then
                 begin
                      aSitesToTest.resize(lResultLen);
                      aResultArr.resize(lResultLen);
                 end;

             if (lResultLen > 0) then
             begin
                  for lCount := 1 to lResultLen do
                  begin
                       aResultArr.rtnValue(lCount,@iValue);
                       aSitesToTest.setValue(lCount,@iValue);
                  end;
             end;

             aResultArr.Destroy;

          except on exception do
                 begin
                      Screen.Cursor := crDefault;
                      MessageDlg('Exception in TestPartialSites',mtError,[mbOk],0);
                 end;
          end;

          dispose(pSite);
     end;
end;

procedure TestPartialSitesToDeselect(var aSitesToTest : Array_T);
var
   lResultLen, lCount, lSiteIndex, lFeatCount : longint;
   iValue : integer;
   pSite : sitepointer;
   fNoDeferrals, fReserved : boolean;
   aResultArr : Array_T;

   procedure AddToArr(const iGeocode : integer);
   begin
        Inc(lResultLen);
        if (lResultLen > aResultArr.lMaxSize) then
           aResultArr.resize(aResultArr.lMaxSize + ARR_STEP_SIZE);
        aResultArr.setValue(lResultLen,@iGeocode);
   end;

begin
     if (aSitesToTest.lMaxSize > 0) then
     begin
          try
             aResultArr := Array_T.Create;
             aResultArr.init(SizeOf(integer),ARR_STEP_SIZE);
             lResultLen := 0;
             new(pSite);

             for lCount := 1 to aSitesToTest.lMaxSize do
             begin
                  aSitesToTest.rtnValue(lCount,@iValue);
                  lSiteIndex := FindFeatMatch(OrdSiteArr,iValue);
                  SiteArr.rtnValue(lSiteIndex,pSite);
                  fNoDeferrals := True;

                  if (pSite^.richness > 0) then
                     for lFeatCount := 1 to pSite^.richness do
                     begin
                          SparsePartial.rtnValue(pSite^.iOffset + lFeatCount,@fReserved);
                          if fReserved then
                             fNoDeferrals := False;
                     end;

                  if fNoDeferrals then
                     AddToArr(iValue);
             end;

             if (lResultLen <= 0) then
             begin
                  aSitesToTest.resize(1);
                  aSitesToTest.lMaxSize := 0;
             end
             else
                 if (aResultArr.lMaxSize > lResultLen) then
                 begin
                      aSitesToTest.resize(lResultLen);
                      aResultArr.resize(lResultLen);
                 end;

             if (lResultLen > 0) then
             begin
                  for lCount := 1 to lResultLen do
                  begin
                       aResultArr.rtnValue(lCount,@iValue);
                       aSitesToTest.setValue(lCount,@iValue);
                  end;
             end;

             aResultArr.Destroy;

          except on exception do
                 begin
                      Screen.Cursor := crDefault;
                      MessageDlg('Exception in TestPartialSites',mtError,[mbOk],0);
                 end;
          end;

          dispose(pSite);
     end;
end;

procedure Partial2PBox(var PBox : TListBox);
var
   iCount, iSiteIndex : integer;
   ASite : site;
begin
     PBox.Items.Clear;

     with ControlForm.PartialKey do
          for iCount := 1 to Items.Count do
          begin
               iSiteIndex := FindFeatMatch(OrdSiteArr,StrToInt(Items.Strings[iCount]));
               SiteArr.rtnValue(iSiteIndex,@ASite);

          end;
end;

procedure PBox2Partial(var PBox : TListBox);
begin
end;

{------------------------------------------------------------------}

function CustCompare(const sOne, sTwo : string;
                     const wSortType, wSortDirection : word) : boolean;
var
   rOne, rTwo : extended;
begin
     case wSortType of
          SORT_TYPE_REAL:
          begin
               try
                  Result := False;
                  if (sOne = '') then
                     rOne := -9999 // make blank string equivalent to -9999
                  else
                      rOne := RegionSafeStrToFloat(sOne);

                  if (sTwo = '') then
                     rTwo := -9999 // make blank string equivalent to zero
                  else
                      rTwo := RegionSafeStrToFloat(sTwo);

                  case wSortDirection of
                       0 : {Descending order}
                           if (rOne < rTwo) then
                              Result := True;
                       1 : {Ascending order}
                           if (rOne > rTwo) then
                              Result := True;
                  end;

               except on exception do;
               end;
          end;
          SORT_TYPE_STRING:
          begin
               Result := False;

               case wSortDirection of
                    0 : {Descending order}
                        if (sOne < sTwo) then
                           Result := True;
                    1 : {Ascending order}
                        if (sOne > sTwo) then
                           Result := True;
               end;
          end;
     end;
end;

procedure SortGrid(var AGrid : TStringGrid;
                   const iRowStartIndex, iColIndex : integer;
                   const wSortType, wSortDirection : word);
var
   iCount, iDBGCount : integer;
   fSwap : boolean;
   sLow,sHigh : string;
begin
     iDBGCount := 0;

     if (iRowStartIndex < (AGrid.RowCount-2))
     and (iColIndex < AGrid.ColCount) then
     begin
          AGrid.RowCount := AGrid.RowCount + 1;

          fSwap := True;
          while fSwap do
          begin
               fSwap := False;

               for iCount := iRowStartIndex to (AGrid.RowCount-3) do
                   begin
                        sLow := AGrid.Cells[iColIndex,iCount];
                        sHigh := AGrid.Cells[iColIndex,iCount + 1];

                        if CustCompare(sLow,sHigh,
                                       wSortType,
                                       wSortDirection {0 is descending, 1 is ascending}
                                       ) then
                        with AGrid do
                        begin
                             Rows[RowCount-1] := Rows[iCount];
                             Rows[iCount] := Rows[iCount+1];
                             Rows[iCount+1] := Rows[RowCount-1];

                             fSwap := True;
                        end;
                   end;

               Inc(iDbgCount);
          end;

          AGrid.RowCount := AGrid.RowCount - 1;
     end;
end;


procedure ShowSiteInfo(const iGeocode : integer);
var
   iCount, iSiteIndex, iFeatIndex, iContribIndex,
   iZeroRowEnd, iZeroRowStart : integer;
   ASite : site;
   AFeat : featureoccurrence;
   {$IFDEF SPARSE_MATRIX_2}
   ClickValues : Array_t;
   rValue : extended;
   {$ELSE}
   ClickRepr : ClickRepr_T;
   AFCust : FeatureCust_T;
   {$ENDIF}
   sIrr,sTmp : string;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
   fReserved : boolean;
begin
     iCurrGeocode := iGeocode;

     with PartEdForm.FeatGrid do
     begin
          ColCount := 5;

          iSiteIndex := findIntegerMatch(OrdSiteArr,iGeocode);
          SiteArr.rtnValue(iSiteIndex,@ASite);
          RowCount := ASite.richness + 1;

          {$IFDEF SPARSE_MATRIX_2}
          {$ELSE}
          if fUseContribData then
          begin
               {attempt to find contib data for this site}
               iContribIndex := FindContribSite(iGeocode);
               if (iContribIndex > 0)
               and (iContribIndex <= GraphContribution.Sites.lMaxSize)
               and (iContribIndex <= GraphContribution.Features.lMaxSize) then
                   GraphContribution.Features.rtnValue(iContribIndex,@AFCust)
               else
                   fUseContribData := False;
          end;
          {$ENDIF}

          Cells[0,0] := 'Feature Key';
          Cells[1,0] := 'Feature Name';
          Cells[2,0] := 'State';
          Cells[3,0] := 'Irreplaceability';
          Cells[4,0] := '% of Avail. Tgt.';

          {$IFDEF SPARSE_MATRIX_2}
          ClickValues := click_predict_sf4(iSiteIndex);
          {$ELSE}
          ClickRepr := click_predict_sf4(iSiteIndex);
          {$ENDIF}

          if (ASite.richness > 0) then
          for iCount := 1 to ASite.richness do
          begin
               {$IFDEF SPARSE_MATRIX}
               FeatureAmount.rtnValue(ASite.iOffset + iCount,@Value);
               iFeatIndex := Value.iFeatKey;
               {$ELSE}
               iFeatIndex := FindFeature(ASite.feature[iCount]);
               {$ENDIF}
               FeatArr.rtnValue(iFeatIndex,@AFeat);

               Cells[0,iCount] := IntToStr(AFeat.code);
               Cells[1,iCount] := AFeat.sID;

               if (wPartEdFlag = READ_PARTIAL)
               or fInitDone then
               begin
                    SparsePartial.rtnValue(ASite.iOffset + iCount,@fReserved);
                    if fReserved then
                       Cells[2,iCount] := 'Reserved'
                    else
                        Cells[2,iCount] := '';
               end
               else
               begin
                    Cells[2,iCount] := '';
                    fInitDone := True;
               end;

               {$IFDEF SPARSE_MATRIX_2}
               if (wPartEdFlag = READ_PARTIAL) then
               begin
                    // use propose unreserve % to tgt
                    if ((AFeat.targetarea - Value.rAmount) > 0) then
                       Str((Value.rAmount / (AFeat.targetarea - Value.rAmount) * 100):10:2,sTmp)
                    else
                        sTmp := '0';
               end
               else
               begin
                    // use available % to tgt
                    if (AFeat.targetarea > 0) then
                       Str((Value.rAmount / AFeat.targetarea * 100):10:2,sTmp)
                    else
                        sTmp := '0';
               end;
               ClickValues.rtnValue(iCount,@rValue);
               Str(rValue:10:2,sIrr);
               {$ELSE}
               if fUseContribData then
                  Str(AFCust.rValue[iCount]:10:2,sTmp)
               else
               begin
                    if (AFeat.targetarea > 0) then
                       Str((Value.rAmount / AFeat.targetarea * 100):10:2,sTmp)
                    else
                        sTmp := '0';
               end;
               Str(ClickRepr[iCount]:10:2,sIrr);
               {$ENDIF}
               TrimLeadSpaces(sIrr);
               Cells[3,iCount] := sIrr;
               TrimLeadSpaces(sTmp);
               Cells[4,iCount] := sTmp;
          end;

          if (wPartEdFlag = READ_AVAIL) then
             SiteArr.setValue(iSiteIndex,@ASite);
             {post this new sites initialised PFlag data (in case it has been previously deferred)}

          {now sort the cells according to their irrepl.
           which is Cells[2,x]}
          if (ASite.richness > 0) then
          begin
               SortGrid(PartEdForm.FeatGrid,
                        1{start row},
                        3{column to sort},
                        SORT_TYPE_REAL,
                        0);

               iZeroRowStart := RowCount-1;

               if (RegionSafeStrToFloat(Cells[4,iZeroRowStart]) = 0) then
               begin
                    iZeroRowEnd := 1;

                    while (iZeroRowEnd < RowCount)
                    and (RegionSafeStrToFloat(Cells[3,iZeroRowEnd]) <> 0) do
                        Inc(iZeroRowEnd);

                    if (iZeroRowEnd < iZeroRowStart) then
                       SortGrid(PartEdForm.FeatGrid,
                                iZeroRowEnd,
                                4,
                                SORT_TYPE_REAL,0);
               end;
          end;
          {$IFDEF SPARSE_MATRIX_2}
          ClickValues.Destroy;
          {$ENDIF}
     end;
end;

procedure TPartEdForm.SiteBoxClick(Sender: TObject);
var
   iCount : integer;
begin
     fASiteClicked := True;

     try
        if fContrDoneOnce then
        begin
             Screen.Cursor := crHourglass;
             if (SiteBox.Items.Count > 0) then
                for iCount := 0 to (SiteBox.Items.Count-1) do
                    if SiteBox.Selected[iCount] then
                       ShowSiteInfo(StrToInt(SiteCodeBox.Items.Strings[iCount]));
        end
        else
            MessageDlg('Run Irreplaceability first',mtInformation,[mbOk],0); 

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TPartEdForm.BitBtn1Click(Sender: TObject);
begin
     ModalResult := mrOK;
end;

function CustFindFeature(const ASite : site;
                         const iFeatCode : integer) : integer;
var
   iCount : integer;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     Result := 0;
     if (ASite.richness > 0) then
        for iCount := 1 to ASite.richness do
        begin
             {$IFDEF SPARSE_MATRIX}
             FeatureAmount.rtnValue(ASite.iOffset + iCount,@Value);
             if (Value.iFeatKey = iFeatCode) then
             {$ELSE}
             if (ASite.feature[iCount] = iFeatCode) then
             {$ENDIF}
                Result := iCount;
        end;
end;


function CustExtract(const sLine : string) : integer;
var
   iCount : integer;
begin
     iCount := Length(sLine);

     while (sLine[iCount] <> ',')
     and (iCount > 1) do
         Dec(iCount);

     try
        Result := StrToInt(Copy(sLine,iCount+1,Length(sLine)-iCount));
     except on exception do
            Result := -1;
     end;
end;

procedure TPartEdForm.FeatGridClick(Sender: TObject);
var
   iSiteIndex, iFeatIndex, iFeatCode : integer;
   pSite : sitepointer;
   sTmp : string;
   fReserved : boolean;
begin
     if fASiteClicked then
     begin
          {toggle the deferral state of the feature that has been clicked}

          new(pSite);

          if fContrDoneOnce then
          try
             Screen.Cursor := crHourglass;

             if (FeatGrid.Selection.Top > 0) then
             begin
                  iFeatCode := StrToInt(FeatGrid.Cells[0,FeatGrid.Selection.Top]);

                  if (iFeatCode > 0) then
                  begin
                       iSiteIndex := FindFeatMatch(OrdSiteArr,iCurrGeocode);
                       SiteArr.rtnValue(iSiteIndex,pSite);

                       iFeatIndex := CustFindFeature(pSite^,iFeatCode);
                       if (iFeatIndex > 0)
                       and (iFeatIndex <= pSite^.richness) then
                       begin
                            if (wPartEdFlag = READ_PARTIAL) then
                               CalcUnPartDeferrSite(pSite);
                            {un defer this site before adjusting the PFlag}

                            SparsePartial.rtnValue(pSite^.iOffset + iFeatIndex,@fReserved);
                            fReserved := not fReserved;
                            SparsePartial.setValue(pSite^.iOffset + iFeatIndex,@fReserved);
                            if fReserved then
                               FeatGrid.Cells[2,FeatGrid.Selection.Top] := 'Reserved'
                            else
                                FeatGrid.Cells[2,FeatGrid.Selection.Top] := '';

                            SiteArr.setValue(iSiteIndex,pSite);

                            if (wPartEdFlag = READ_PARTIAL) then
                            begin
                                 CalcPartDeferrSite(pSite);
                                 {defer this site after adjusting the PFlag}

                                 fSelectionChange := True;
                                 fContrDataDone := False;
                            end;
                       end;
                  end;
             end;

          finally
                 Screen.Cursor := crDefault;
                 dispose(pSite);
          end;
     end
     else
         MessageDlg('Click a Site in the list box to the Left to display Features',mtInformation,[mbOk],0);
end;

procedure TPartEdForm.FormCreate(Sender: TObject);
var
   iCount : integer;
begin
     try
        Screen.Cursor := crHourglass;

        fInitDone := False;

        SiteBox.Items.Clear;
        SiteCodeBox.Items.Clear;

        case wPartEdFlag of
             READ_PARTIAL :
             begin
                  if fContrDoneOnce then
                     fUseContribData := True
                  else
                      fUseContribData := False;

                  SiteBox.Items := ControlForm.Partial.Items;
                  SiteCodeBox.Items := ControlForm.PartialKey.Items;
                  if (SiteBox.Items.Count = 1) then
                     lblInfo.Caption := '1 Partially Selected Site'
                  else
                      lblInfo.Caption := IntToStr(SiteBox.Items.Count) +
                                         ' Partially Selected Sites';
             end;
             READ_AVAIL :
             begin
                  fUseContribData := False;

                  if (ControlForm.Available.SelCount > 0) then
                     for iCount := 0 to (ControlForm.Available.Items.Count-1) do
                         if ControlForm.Available.Selected[iCount] then
                         begin
                              SiteBox.Items.Add(ControlForm.Available.Items.Strings[iCount]);
                              SiteCodeBox.Items.Add(ControlForm.AvailableKey.Items.Strings[iCount]);
                         end;

                  if (SiteBox.Items.Count = 1) then
                     lblInfo.Caption := 'There is 1 Potential Partially Selected Site'
                  else
                      lblInfo.Caption := 'There are ' +
                                         IntToStr(SiteBox.Items.Count) +
                                         ' Potential Partially Selected Sites';

                  if ControlRes^.fShowExtraTools then
                  begin
                       Panel1.Height := 73; // original value of 41
                       btnReserveAll.Visible := True;
                  end;
             end;
        end;

        fASiteClicked := False;

        with FeatGrid do
        begin
             DefaultColWidth := (ClientWidth-
                                 (ColCount*GridLineWidth))
                                div (ColCount);
        end;

     finally
            Screen.Cursor := crDefault;
     end;
end;

procedure TPartEdForm.FormShow(Sender: TObject);
begin
     if (SiteBox.Items.Count > 0) then
     begin
          SiteBox.ItemIndex := 0;
          ShowSiteInfo(StrToInt(SiteCodeBox.Items.Strings[0]));
          fASiteClicked := True;
     end;
end;

procedure TPartEdForm.Button1Click(Sender: TObject);
begin
     AutoFitGrid(FeatGrid,
                 Canvas,
                 True {fit entire grid});
end;

procedure TPartEdForm.btnReserveAllClick(Sender: TObject);
var
   iCount, iSiteIndex, iFeature : integer;
   pSite : sitepointer;
   fReserved : boolean;
begin
     // reserve all features at all sites
     try
        new(pSite);

        for iCount := 0 to (SiteCodeBox.Items.Count - 1) do
        begin
             iSiteIndex := FindFeatMatch(OrdSiteArr,StrToInt(SiteCodeBox.Items.Strings[iCount]));
             SiteArr.rtnValue(iSiteIndex,pSite);

             if (pSite^.richness > 0) then
                for iFeature := 1 to pSite^.richness do
                begin
                     fReserved := True;
                     SparsePartial.setValue(pSite^.iOffset + iFeature,@fReserved);
                end;

             SiteArr.setValue(iSiteIndex,pSite);
        end;

        dispose(pSite);

        SiteBoxClick(Sender);
        ModalResult := mrOK;

     except
     end;
end;

end.
