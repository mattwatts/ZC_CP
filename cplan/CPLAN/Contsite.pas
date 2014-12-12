unit Contsite;

{$I STD_DEF.PAS}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Grids,
  Global,
  {$IFDEF bit16}
  Arrayt16;
  {$ELSE}
  ds;
  {$ENDIF}

type
  TPossibleSitesForm = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    LocalClick: TRadioGroup;
    a: TButton;
    btnMap: TButton;
    c: TButton;
    t: TButton;
    PossibleSitesBox: TListBox;
    procedure BitBtn1Click(Sender: TObject);
    procedure LocalClickClick(Sender: TObject);
    procedure aClick(Sender: TObject);
    procedure btnMapClick(Sender: TObject);
    procedure cClick(Sender: TObject);
    procedure PossibleSitesBoxDblClick(Sender: TObject);
    procedure PossibleSitesBoxClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure InheritCycleToggle;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PossibleSitesForm: TPossibleSitesForm;
  iLocalFeatCode,
  iGridCols, iGridFieldLen : integer;


procedure FindContributingSites(const iFeatCode : integer);
{called for single feature search}

procedure SiteFeatGrid(const FList {, AFeatArr, AFCArr,
                       ASiteArr, ASCArr} : Array_T{;
                       const iSCount, iFCount : integer});
{called for multiple feature search}

{procedure PossibleSites;}


implementation

uses
    Em_newu1, Control, Contribu, Dde_unit,
    Sql_unit, Sct_grid, Toolmisc;

{$R *.DFM}

procedure TPossibleSitesForm.InheritCycleToggle;
begin
     LocalClick.Font := ControlForm.ClickGroup.Font;

     LocalClick.Left := (2 * BitBtn1.Left) + BitBtn1.Width;

     LocalClick.Height := ControlForm.ClickGroup.Height;
     LocalClick.Width := ControlForm.ClickGroup.Width;
     LocalClick.Caption := ControlForm.ClickGroup.Caption;

     LocalClick.Top := ControlForm.ClickGroup.Top;

     Panel1.Height := (3 * LocalClick.Top) + LocalClick.Height;
end;

procedure FindContributingSites(const iFeatCode : integer);
begin
     try
        iLocalFeatCode := iFeatCode;

        PossibleSitesForm := TPossibleSitesForm.Create(Application);
        PossibleSitesForm.ShowModal;

     finally
            PossibleSitesForm.Free;
     end;
end;

procedure SiteFeatGrid(const FList{, AFeatArr, AFCArr,
                       ASiteArr, ASCArr} : Array_T{;
                       const iSCount, iFCount : integer});
var
   iCount, iCount2, iCount3, iFeatIndex,
   iFCode,
   iCharSize, iNumCharsWide : integer;
   ASite : site;
   AFeat : featureoccurrence{FeatureOccurrenceSubset_T};
   wOldCursor : integer;
   fSiteUsed : boolean;
   rCurrValue : real;
   sCurrValue, sALine : string;
   SiteContrib : StrArr;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     if (FList.lMaxSize < GRID_MAX_COLUMNS) then
     {if we have room in our temporary array of size
      GRID_MAX_COLUMNS elements}
     begin
          try
          iLocalFeatCode := -1;
          PossibleSitesForm := TPossibleSitesForm.Create(Application);

          with PossibleSitesForm do
          begin
               {load site contributions for features to PossibleSitesGrid}
               wOldCursor := Screen.Cursor;
               Screen.Cursor := crHourglass;

               {iFeatIndex := FindFeature(iLocalFeatCode);
               FeatArr.rtnValue(iFeatIndex,@AFeat);}

               Caption := 'Available Sites For Features';

               LocalClick.Items := ControlForm.ClickGroup.Items;
               LocalClick.ItemIndex := ControlForm.ClickGroup.ItemIndex;

               iGridCols := FList.lMaxSize + 1;
               iCharSize := Canvas.TextWidth(' ');
               iNumCharsWide := ClientWidth div iCharSize;
               iGridFieldLen := (iNumCharsWide div iGridCols) - 1;

               sALine := BuildField('Site/Feature',iGridFieldLen);

               for iCount := 1 to FList.lMaxSize do
               begin
                    if (iCount <> FList.lMaxSize) then
                       sALine := sALine + ' ';

                    FList.rtnValue(iCount,@iFCode);

                    sALine := sALine + BuildField(IntToStr(iFCode),iGridFieldLen);
               end;
               {write Feature Search Codes along first row}

               PossibleSitesForm.PossibleSitesBox.Items.Add(sALine);

               for iCount := 1 to iSiteCount do
               begin
                    SiteArr.rtnValue(iCount,@ASite);

                    if (ASite.status = Av)
                    and (ASite.richness > 0) then
                    {if the site is available and it has some features}
                    begin
                         fSiteUsed := False;
                         {make a space in matrix for this site and write geocode}

                         sALine := BuildField(IntToStr(ASite.iKey),iGridFieldLen);

                         for iCount3 := 1 to GRID_MAX_COLUMNS do
                             SiteContrib[iCount3] := ' ';
                             {initialise the strings in the
                              SiteContrib variable}

                         for iCount2 := 1 to ASite.richness do
                         begin
                              {match ASite.feature[iCount2] to our FList codes
                               and display contribution to target value}
                              {$IFDEF SPARSE_MATRIX}
                              FeatureAmount.rtnValue(ASite.iOffset + iCount2,@Value);
                              iFeatIndex := Value.iFeatKey;
                              {$ELSE}
                              iFeatIndex := FindFeature(ASite.feature[iCount2]);
                              {$ENDIF}

                              FeatArr.rtnValue(iFeatIndex,@AFeat);

                              for iCount3 := 1 to FList.lMaxSize do
                              begin
                                   FList.rtnValue(iCount3,@iFCode);
                                   {$IFDEF SPARSE_MATRIX}
                                   if (Value.iFeatKey = iFCode)
                                   {$ELSE}
                                   if (ASite.feature[iCount2] = iFCode)
                                   {$ENDIF}
                                   and (AFeat.targetarea > 0) then
                                   begin
                                        fSiteUsed := True;

                                        try
                                           {$IFDEF SPARSE_MATRIX}
                                           rCurrValue := Value.rAmount /
                                           {$ELSE}
                                           rCurrValue := ASite.featurearea[iCount2] /
                                           {$ENDIF}
                                                         AFeat.targetarea * 100;
                                        except
                                              rCurrValue := 0;
                                        end;
                                        if (rCurrValue >= 100) then
                                           sCurrValue := '100'
                                        else
                                            Str(rCurrValue:5:2,sCurrValue);

                                        if (Length(sCurrValue) > 3)
                                        and (Copy(sCurrValue,Length(sCurrValue)-2,3) = '.00') then
                                            sCurrValue := '   ' + Copy(sCurrValue,1,Length(sCurrValue)-3);

                                        SiteContrib[iCount3] := sCurrValue;
                                   end;
                              end;
                         end;

                         if fSiteUsed then
                         begin
                              for iCount3 := 1 to FList.lMaxSize do
                              begin
                                   sALine := sALine +
                                      BuildField(SiteContrib[iCount3],iGridFieldLen);

                                   if (iCount3 <> FList.lMaxSize) then
                                      sALine := sALine + ' ';
                              end;

                              PossibleSitesForm.PossibleSitesBox.Items.Add(sALine);
                         end;
                    end;
               end;

               Screen.Cursor := crDefault;
               PossibleSitesForm.ShowModal;
          end;

          except on exception do
                 MessageDlg('exception in SiteFeatGrid',mtError,[mbOK],0);
          end;

          PossibleSitesForm.Free;
     end;
end;

procedure TPossibleSitesForm.BitBtn1Click(Sender: TObject);
begin
     ModalResult := mrOK;
end;

procedure TPossibleSitesForm.LocalClickClick(Sender: TObject);
begin
     ControlForm.ClickGroup.ItemIndex := LocalClick.ItemIndex;
end;

procedure TPossibleSitesForm.aClick(Sender: TObject);
begin
     ControlForm.btnAcceptClick(self);
end;

procedure TPossibleSitesForm.btnMapClick(Sender: TObject);
var
   OurSites : Array_T;
   sAGeo : string;
   iCount,iCurrSite, iNumSelected : integer;
begin
     try

     Screen.Cursor := crHourglass;

     if (PossibleSitesBox.SelCount > 0) then
     if not PossibleSitesBox.Selected[0] then
     begin
          OurSites := Array_t.Create;

          iNumSelected := PossibleSitesBox.SelCount;
          OurSites.init(SizeOf(sAGeo),iNumSelected);

          iCurrSite := 0;

          for iCount := 1 to (PossibleSitesBox.Items.Count-1) do
              if PossibleSitesBox.Selected[iCount] then
              begin
                   Inc(iCurrSite);

                   sAGeo := ExtractCode(PossibleSitesBox.Items.Strings[iCount],
                                        iGridFieldLen,1);
                   OurSites.setValue(iCurrSite,@sAGeo);
              end;
          MapSites(OurSites,TRUE);
          OurSites.Destroy;
     end;

     except on exception do
            MessageDlg('exception in btnMapClick',mtError,[mbOK],0);
     end;

     Screen.Cursor := crDefault;
end;

procedure TPossibleSitesForm.cClick(Sender: TObject);
begin
     if (LocalClick.ItemIndex = LocalClick.Items.Count-1) then
        LocalClick.ItemIndex := 0
     else
         LocalClick.ItemIndex := LocalClick.ItemIndex + 1;

     ControlForm.ClickGroup.ItemIndex := LocalClick.ItemIndex;
end;

procedure TPossibleSitesForm.PossibleSitesBoxDblClick(Sender: TObject);
var
   iCount : integer;
begin
     try

     {emulate a dde click message for site
      double clicked on}
     if (PossibleSitesBox.SelCount = 1) then
        for iCount := 1 to (PossibleSitesBox.Items.Count-1) do
            if PossibleSitesBox.Selected[iCount] then
               UseGISKey(StrToInt(ExtractCode(
                  PossibleSitesBox.Items.Strings[iCount],
                  iGridFieldLen,1 {column 1 is geocode field})),
                                 TRUE {fMinimiseControl});

     except on exception do
            MessageDlg('exception in BoxDblClick',mtError,[mbOK],0);
     end;
end;

procedure TPossibleSitesForm.PossibleSitesBoxClick(Sender: TObject);
begin
     PossibleSitesBox.Update;
end;

procedure TPossibleSitesForm.FormCreate(Sender: TObject);
begin
     InheritCycleToggle;
end;

end.
