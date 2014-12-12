unit S2show;

{$I STD_DEF.PAS}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, ExtCtrls, StdCtrls, Spin, Buttons, Menus,
  {$IFDEF bit16}
  Arrayt16, Cpng_imp;
  {$ELSE}
  ds, lbox;
  {$ENDIF}

type
  TReservedSitesForm = class(TForm)
    Panel1: TPanel;
    S2Grid: TStringGrid;
    BitBtn1: TBitBtn;
    Label2: TLabel;
    ModifiedGrid: TStringGrid;
    lblGridSpec: TLabel;
    MainMenu1: TMainMenu;
    Grid1: TMenuItem;
    AutoFit1: TMenuItem;
    Filter1: TMenuItem;
    Sort1: TMenuItem;
    CancelFilterSort1: TMenuItem;
    Edit1: TMenuItem;
    Copy1: TMenuItem;
    VisibleCodes: TListBox;
    SaveDialog1: TSaveDialog;
    Save1: TMenuItem;
    Map1: TMenuItem;
    RadioTarget: TRadioGroup;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure AutoFit1Click(Sender: TObject);
    procedure Filter1Click(Sender: TObject);
    procedure Sort1Click(Sender: TObject);
    procedure CancelFilterSort1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Map1Click(Sender: TObject);
    procedure RadioTargetClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ReservedSitesForm: TReservedSitesForm;
  aLocalFeat : Array_t;

procedure ShowWhyImpFeat(SomeFeatures : Array_t);

implementation

uses
    Global, Em_newu1,
    {$IFDEF CPLAN_EXE}
    Defrqry,
    {$ENDIF}
    Contribu,
    Control, F1find, Dbmisc,
    auto_fit,
    opt1, filter, sortoptions,
    s1find, toolmisc, featgrid;

{$R *.DFM}

procedure TReservedSitesForm.FormResize(Sender: TObject);
begin
     S2Grid.DefaultColWidth := (ClientWidth div S2Grid.ColCount) -
                               S2Grid.GridLineWidth - 1;
end;

procedure TReservedSitesForm.FormCreate(Sender: TObject);
begin
     FormResize(self);
end;

procedure ViewSites(SomeFeatures : Array_t;
                    iPercent : integer);
var
   aSites : Array_t;
   iGeo, iFCode, iCount, iCount2, iCount3, iSIdx : integer;
   sCellLabel : string;
   rCalc, rTarget : extended;
   pFeat : featureoccurrencepointer;
   pSite : sitepointer;
   Value : ValueFile_T;
begin
     {$IFDEF CPLAN_EXE}
     try Screen.Cursor := crHourglass;

     aSites := WhyImpFeat(iPercent,SomeFeatures);
     with ReservedSitesForm.S2Grid do
     begin
          new(pFeat);
          new(pSite);
          RowCount := 1;
          ColCount := 1 + SomeFeatures.lMaxSize;
          Cells[0,0] := 'Site/Feature';

          if (SomeFeatures.lMaxSize > 0) then
             for iCount := 1 to SomeFeatures.lMaxSize do
             begin
                  SomeFeatures.rtnValue(iCount,@iFCode);
                  FeatArr.rtnValue(iFCode,pFeat);
                  Cells[iCount,0] := pFeat^.sID;
             end;

          ReservedSitesForm.VisibleCodes.Items.Clear;

          if (aSites.lMaxSize > 0) then
             for iCount := 1 to aSites.lMaxSize do
             begin
                  RowCount := RowCount + 1;
                  aSites.rtnValue(iCount,@iGeo);
                  iSIdx := FindFeatMatch(OrdSiteArr,iGeo);
                  SiteArr.rtnValue(iSIdx,pSite);

                  ReservedSitesForm.VisibleCodes.Items.Add(IntToStr(pSite^.iKey));
                  Cells[0,RowCount-1] := pSite^.sName;
                  if (SomeFeatures.lMaxSize > 0) then
                     for iCount2 := 1 to SomeFeatures.lMaxSize do
                     begin
                          SomeFeatures.rtnValue(iCount2,@iFCode);
                          FeatArr.rtnValue(iFCode,pFeat);
                          Cells[iCount2,0] := pFeat^.sID;
                          Cells[iCount2,RowCount-1] := '';
                          if (pSite^.richness > 0) then
                             for iCount3 := 1 to pSite^.richness do
                             begin
                                  FeatureAmount.rtnValue(pSite^.iOffset + iCount3,@Value);
                                  if (Value.iFeatKey = iFCode) then
                                  begin
                                       if (ReservedSitesForm.RadioTarget.ItemIndex = 0) then
                                       begin // unreserved target
                                            rTarget := pFeat^.targetarea + Value.rAmount;
                                            if (rTarget > 0) then
                                               rCalc := Value.rAmount/
                                                        rTarget * 100
                                            else
                                                rCalc := 0;
                                       end
                                       else
                                       begin // initial achievable target
                                            if (pFeat^.rInitialAvailableTarget > 0) then
                                               rCalc := Value.rAmount/
                                                        pFeat^.rInitialAvailableTarget * 100
                                            else
                                                rCalc := 0;
                                       end;

                                       Str(rCalc:6:1,sCellLabel);
                                       TrimLeadSpaces(sCellLabel);

                                       Cells[iCount2,RowCount-1] := sCellLabel;
                                  end;
                             end;
                     end;
             end;
          dispose(pSite);
          dispose(pFeat);
     end;

     finally Screen.Cursor := crDefault;
     end;
     {$ENDIF}
end;

procedure ShowWhyImpFeat(SomeFeatures : Array_t);
begin
     if (SomeFeatures.lMaxSize > 0) then
     begin
          ReservedSitesForm := TReservedSitesForm.Create(Application);

          {call ViewSites to refresh display}
          ViewSites(SomeFeatures,0);
          aLocalFeat := SomeFeatures;

          // display unfiltered and unsorted grid
          CancelFilterAndSort(ReservedSitesForm.S2Grid,ReservedSitesForm.ModifiedGrid);

          Screen.Cursor := crDefault;

          if (ReservedSitesForm.S2Grid.RowCount > 1) then
             ReservedSitesForm.ShowModal
          else
          begin
               ViewSites(SomeFeatures,0);

               if (ReservedSitesForm.S2Grid.RowCount > 1) then
                  ReservedSitesForm.ShowModal
               else
                   MessageDlg('No Contributing Sites Found',
                              mtInformation,[mbOk],0);
          end;
     end;

     // SomeFeatures.Destroy;
end;

procedure TReservedSitesForm.BitBtn1Click(Sender: TObject);
begin
     ModalResult := mrOK;
end;

procedure TReservedSitesForm.FormActivate(Sender: TObject);
begin
     if ControlRes^.fRandomTest then
        ModalResult := mrOk;
end;

procedure TReservedSitesForm.AutoFit1Click(Sender: TObject);
begin
     AutoFitGrid(ModifiedGrid,
                 Canvas,
                 True {fit entire grid});
end;

procedure TReservedSitesForm.Filter1Click(Sender: TObject);
var
   iCount : integer;
begin
     FilterForm := TFilterForm.Create(Application);
     // prepare filter form
     FilterForm.ComboField.Text := S2Grid.Cells[0,0];
     for iCount := 0 to (S2Grid.ColCount - 1) do
         FilterForm.ComboField.Items.Add(S2Grid.Cells[iCount,0]);
     FilterStringGrid := S2Grid;
     if (FilterForm.ShowModal = mrOk) then
     begin
          // perform filter
          ApplyFilterToGrid(S2Grid,ModifiedGrid,            // in and out grids
                            FilterForm.RadioOperator.ItemIndex, // operator
                            FilterForm.ComboField.Text,      // field
                            FilterForm.ComboValue.Text);     // value

          lblGridSpec.Caption := 'Filter (' +
                                 FilterForm.ComboField.Text +
                                 ' ' +
                                 FilterForm.RadioOperator.Items.Strings[FilterForm.RadioOperator.ItemIndex] +
                                 ' ' +
                                 FilterForm.ComboValue.Text +
                                 ')';
     end
     else
     begin
          // cancel any existing filter
          CancelFilterAndSort(S2Grid,ModifiedGrid);

          lblGridSpec.Caption := '';
     end;
     FilterForm.Free;
end;

procedure TReservedSitesForm.Sort1Click(Sender: TObject);
var
   iCount : integer;
begin
     SortForm := TSortForm.Create(Application);
     // prepare sort form
     SortForm.ComboField.Text := S2Grid.Cells[0,0];
     for iCount := 0 to (S2Grid.ColCount - 1) do
         SortForm.ComboField.Items.Add(S2Grid.Cells[iCount,0]);
     if (SortForm.ShowModal = mrOk) then
     begin
          // perform sort
          ApplySortToGrid(S2Grid,ModifiedGrid,
                          SortForm.RadioDirection.ItemIndex,
                          SortForm.ComboField.Text);

          lblGridSpec.Caption := 'Sort ' +
                                 SortForm.RadioDirection.Items.Strings[SortForm.RadioDirection.ItemIndex] +
                                 ' ' +
                                 SortForm.ComboField.Text;
     end
     else
     begin
          // cancel any existing sort
          CancelFilterAndSort(S2Grid,ModifiedGrid);

          lblGridSpec.Caption := '';
     end;
     SortForm.Free;
end;

procedure TReservedSitesForm.CancelFilterSort1Click(Sender: TObject);
begin
     CancelFilterAndSort(S2Grid,ModifiedGrid);

     lblGridSpec.Caption := '';
end;

procedure TReservedSitesForm.Copy1Click(Sender: TObject);
begin
     CopySGrid2Clip(ModifiedGrid);
end;

procedure TReservedSitesForm.Save1Click(Sender: TObject);
begin
     SaveDialog1.InitialDir := ControlRes^.sWorkingDirectory;
     if SaveDialog1.Execute then
        SaveStringGrid2CSV(ModifiedGrid,SaveDialog1.Filename);
end;

procedure TReservedSitesForm.Map1Click(Sender: TObject);
var
   UserSites : Array_t;
   iUserSites, iUserSite, iCount : integer;
begin
     // map all the sites on this form
     // Build a list of all sites from the grid and pass the list to the handler
     try
        Screen.Cursor := crHourglass;

        UserSites := Array_t.Create;
        UserSites.init(SizeOf(integer),ARR_STEP_SIZE);
        iUserSites := 0;

        if (VisibleCodes.Items.Count > 0) then
        begin
             for iCount := 0 to (VisibleCodes.Items.Count-1) do
             begin
                  inc(iUserSites);
                  if (iUserSites > UserSites.lMaxSize) then
                     UserSites.resize(UserSites.lMaxSize + ARR_STEP_SIZE);
                  iUserSite := StrToInt(VisibleCodes.Items.Strings[iCount]);
                  UserSites.setValue(iUserSites,@iUserSite);
             end;

             if (iUserSites <> UserSites.lMaxSize) then
                UserSites.Resize(iUserSites);

             MapSites(UserSites,FALSE);

             ControlForm.AllClasses1Click(self);
        end;

        UserSites.Destroy;

     except
           Screen.Cursor := crDefault;
           RptErrorStop('exception in btnMapClick');
     end;

     Screen.Cursor := crDefault;
end;

procedure TReservedSitesForm.RadioTargetClick(Sender: TObject);
var
   iOperator : integer;
   sOperator, sField, sValue : string;
begin
     // we must recalc the grid of values and then reapply sort/filter if necessary

     //ShowWhyImpFeat(aLocalFeat);
     ViewSites(aLocalFeat,0);

     if (lblGridSpec.Caption = '') then
        // display unfiltered and unsorted grid
        CancelFilterAndSort(ReservedSitesForm.S2Grid,ReservedSitesForm.ModifiedGrid)
     else
     begin
          if (Copy(lblGridSpec.Caption,1,4) = 'Sort') then
          begin
               // extract sort parameters from caption
               sOperator := Copy(lblGridSpec.Caption,
                                 6,
                                 Length(lblGridSpec.Caption)-5);
               sField := Copy(sOperator,
                              Pos(' ',sOperator)+1,
                              Length(sOperator)-Pos(' ',sOperator));
               sOperator := Copy(sOperator,
                                 1,
                                 Pos(' ',sOperator)-1);
               if (sOperator = 'Descending') then
                  iOperator := 0
               else
                   iOperator := 1;

               // perform sort
               ApplySortToGrid(S2Grid,ModifiedGrid,
                               iOperator,
                               sField);
          end
          else
          if (Copy(lblGridSpec.Caption,1,6) = 'Filter') then
          begin
               // extract filter parameters from caption
               // trim 'Filter()' from caption
               sOperator := Copy(lblGridSpec.Caption,
                                 9,
                                 Length(lblGridSpec.Caption)-9);
               // extract field
               sField := Copy(sOperator,
                              1,
                              Pos(' ',sOperator)-1);
               // trim field from caption
               sOperator := Copy(sOperator,
                                 Pos(' ',sOperator) + 1,
                                 Length(sOperator) - Pos(' ',sOperator));
               // extract value
               sValue := Copy(sOperator,
                              Pos(' ',sOperator) + 1,
                              Length(sOperator) - Pos(' ',sOperator));
               // extract operator
               sOperator := Copy(sOperator,
                                 1,
                                 Pos(' ',sOperator)-1);

               case sOperator[1] of
                    '=' : iOperator := 0;
                    '<' : if (Length(sOperator) = 2) then
                             case sOperator[2] of
                                  '>' : iOperator := 1;
                                  '=' : iOperator := 5;
                             end
                          else
                              iOperator := 3;
                    '>' : if (Length(sOperator) = 2) then
                             iOperator := 4
                          else
                              iOperator := 2;
               end;

               lblGridSpec.Caption := 'Filter (' +
                                 FilterForm.ComboField.Text +
                                 ' ' +
                                 FilterForm.RadioOperator.Items.Strings[FilterForm.RadioOperator.ItemIndex] +
                                 ' ' +
                                 FilterForm.ComboValue.Text +
                                 ')';

               // perform filter
               ApplyFilterToGrid(S2Grid,ModifiedGrid, // in and out grids
                                 iOperator, // operator
                                 sField,    // field
                                 sValue);   // value
          end;
     end;
end;

procedure TReservedSitesForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     aLocalFeat.Destroy;
end;

end.
