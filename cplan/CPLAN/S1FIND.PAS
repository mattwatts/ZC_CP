unit S1find;

{$I STD_DEF.PAS}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Global, Buttons, Grids,
  Menus,
  ds, Dll_u1, lbox;

type
  TAvailableSitesForm = class(TForm)
    Panel1: TPanel;
    S1Box: TListBox;
    LocalClick: TRadioGroup;
    BitBtn1: TBitBtn;
    c: TButton;
    t: TButton;
    a: TButton;
    Label1: TLabel;
    MapGrid: TStringGrid;
    VisibleCodes: TListBox;
    ModifiedGrid: TStringGrid;
    lblGridSpec: TLabel;
    MainMenu1: TMainMenu;
    Grid1: TMenuItem;
    AutoFit1: TMenuItem;
    Edit1: TMenuItem;
    Copy1: TMenuItem;
    Filter1: TMenuItem;
    Sort1: TMenuItem;
    CancelFilterSort1: TMenuItem;
    SaveDialog1: TSaveDialog;
    Save1: TMenuItem;
    Map1: TMenuItem;
    procedure BitBtn1Click(Sender: TObject);
    procedure cClick(Sender: TObject);
    procedure aClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure S1BoxDblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure LocalClickClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure InheritCycleToggle;
    procedure ToggleSelect(const iRow : integer);
    procedure ModifiedGridSelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    procedure AutoFit1Click(Sender: TObject);
    procedure Filter1Click(Sender: TObject);
    procedure Sort1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure CancelFilterSort1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Map1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AvailableSitesForm: TAvailableSitesForm;
  FGridList : Array_T;
  fWideGrid : boolean;

  iGridCols, iCharSize, iNumCharsWide, iGridFieldLen,
  iGeocodeColumn : integer;


procedure ApplyFilterToGrid(InGrid, OutGrid : TStringGrid;
                            const iOperator : integer;
                            const sField, sValue : string);
procedure ApplySortToGrid(InGrid, OutGrid : TStringGrid;
                          const iDirection : integer;
                          const sField : string);
procedure CancelFilterAndSort(InGrid,OutGrid : TStringGrid);


implementation

uses
    Control, Em_newu1, Sct_grid, Contribu,
    Sql_unit, Dde_unit, F1Find, Opt1,
    Toolmisc, Sf_irrep,
    Lookup, auto_fit, filter, sortoptions,
    partl_ed, dbmisc, featgrid;

{$R *.DFM}

procedure TAvailableSitesForm.InheritCycleToggle;
begin
     LocalClick.Font := ControlForm.ClickGroup.Font;

     LocalClick.Left := (2 * a.Left) + a.Width;

     //LocalClick.Height := ControlForm.ClickGroup.Height;
     LocalClick.Width := ControlForm.ClickGroup.Width;
     LocalClick.Caption := ControlForm.ClickGroup.Caption;

     //LocalClick.Top := ControlForm.ClickGroup.Top;

     Panel1.Height := Label1.Top + Label1.Height + BitBtn1.Top;

     if (Width<(LocalClick.Left+LocalClick.Width)) then
        Width := LocalClick.Left + LocalClick.Width + TOOL_DIVIDE_SPACE;
end;

procedure TAvailableSitesForm.BitBtn1Click(Sender: TObject);
begin
     ModalResult := mrOK;
end;

procedure TAvailableSitesForm.cClick(Sender: TObject);
begin
     if (LocalClick.ItemIndex = LocalClick.Items.Count-1) then
        LocalClick.ItemIndex := 0
     else
         LocalClick.ItemIndex := LocalClick.ItemIndex + 1;
end;

procedure TAvailableSitesForm.aClick(Sender: TObject);
var
   UserSites : Array_t;
   iUserSites, iUserSite, iCount : integer;
begin
     // Build a list of selected sites from the grid and pass
     // the list to the Accept handler
     try
        UserSites := Array_t.Create;
        UserSites.init(SizeOf(integer),ARR_STEP_SIZE);
        iUserSites := 0;

        if (MapGrid.RowCount > 1) then
           for iCount := 1 to (MapGrid.RowCount-1) do
               if (MapGrid.Cells[0,iCount] <> '') then
               begin
                    inc(iUserSites);
                    if (iUserSites > UserSites.lMaxSize) then
                       UserSites.resize(UserSites.lMaxSize + ARR_STEP_SIZE);
                    iUserSite := StrToInt(VisibleCodes.Items.Strings[iCount-1]);
                    UserSites.setValue(iUserSites,@iUserSite);
               end;


        // Pass the array to UseGISKeys
        if (iUserSites > 0) then
        begin
             if (iUserSites <> UserSites.lMaxSize) then
                UserSites.resize(iUserSites);
             UseGISKeys(UserSites);
        end;
        UserSites.Destroy;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Accept Available Sites',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TAvailableSitesForm.FormActivate(Sender: TObject);
begin
     LocalClick.ItemIndex := ControlForm.ClickGroup.ItemIndex;

     if ControlRes^.fRandomTest then
        ModalResult := mrOk;
end;

procedure TAvailableSitesForm.S1BoxDblClick(Sender: TObject);
var
   iCodesToUse, iCode, iCount : integer;
   CodesToUse : Array_t;
begin
     try
        if (S1Box.Items.Count > 1)
        and (S1Box.SelCount >= 1) then
        begin
             iCodesToUse := 0;
             CodesToUse := Array_t.Create;
             CodesToUse.init(SizeOf(integer),ARR_STEP_SIZE);
             for iCount := 1 to (S1Box.Items.Count-1) do
                 if S1Box.Selected[iCount] then
                 begin
                      Inc(iCodesToUse);
                      if (iCodesToUse > CodesToUse.lMaxSize) then
                         CodesToUse.resize(CodesToUse.lMaxSize + ARR_STEP_SIZE);
                      iCode := StrToInt(MapGrid.Cells[0,iCount]);
                      CodesToUse.setValue(iCodesToUse,@iCode);
                 end;
             if (iCodesToUse > 0) then
             begin
                  if (iCodesToUse <> CodesToUse.lMaxSize) then
                     CodesToUse.resize(iCodesToUse);
                  UseGISKeys(CodesToUse);
             end;
             CodesToUse.Destroy;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('exception in BoxDblClick',
                      mtError,[mbOK],0);
     end;
end;

procedure TAvailableSitesForm.FormCreate(Sender: TObject);
var

   iCount, iCountRichness,
   iCountF, iFCode, iFeatIndex : integer;
   fSiteUsed : boolean;
   {rDeducedTarget,} rContributingArea,
   rCurrValue : extended;
   sCurrValue : string;
   AFeat : featureoccurrence;
   ASite : site;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     fWideGrid := False;

     ControlForm.ProgressOn;
     ControlForm.ProcLabelOn('Find Available Sites');

     //if (FGridList.lMaxSize < GRID_MAX_COLUMNS) then
     try
        Screen.Cursor := crHourglass;

        BitBtn1.Font := ControlForm.Font;
        a.Font := ControlForm.Font;
        Label1.Font := ControlForm.Font;

        Caption := 'Available Sites';

        InheritCycleToggle;

        LocalClick.Items := ControlForm.ClickGroup.Items;
        LocalClick.ItemIndex := ControlForm.ClickGroup.ItemIndex;

        iGeocodeColumn := 1;

        with MapGrid do
        begin
             RowCount := 1;
             ColCount := FGridList.lMaxSize + 2;
             Cells[0,0] := 'Selected';
             Cells[1,0] := 'Site/Feature';
        end;

        for iCount := 1 to FGridList.lMaxSize do
        begin
             FGridList.rtnValue(iCount,@iFCode);

             // write the name of the feature to the grid cell
             iFeatIndex := findIntegerMatch(OrdFeatArr,iFCode);
             FeatArr.rtnValue(iFeatIndex,@AFeat);
             MapGrid.Cells[iCount+1,0] := AFeat.sID;
        end;

        for iCount := 1 to iSiteCount do
        begin
             ControlForm.ProgressUpdate(Round(iCount/iSiteCount*100));

             SiteArr.rtnValue(iCount,@ASite);

             if ((ASite.status = Av)
                 or (ASite.status = Fl))
             and (ASite.richness > 0) then
             begin
                  MapGrid.RowCount := MapGrid.RowCount + 1;
                  fSiteUsed := False;

                  MapGrid.Cells[1,MapGrid.RowCount-1] := ASite.sName;

                  for iCountRichness := 1 to ASite.richness do
                  begin
                       {$IFDEF SPARSE_MATRIX}
                       FeatureAmount.rtnValue(ASite.iOffset + iCountRichness,@Value);
                       iFeatIndex := findIntegerMatch(OrdFeatArr,Value.iFeatKey);
                       {$ELSE}
                       iFeatIndex := findIntegerMatch(OrdFeatArr,ASite.feature[iCountRichness]);
                       {$ENDIF}
                       FeatArr.rtnValue(iFeatIndex,@AFeat);
                       for iCountF := 1 to FGridList.lMaxSize do
                       begin
                            FGridList.rtnValue(iCountF,@iFCode);
                            {$IFDEF SPARSE_MATRIX}
                            if (Value.iFeatKey = iFCode)
                            {$ELSE}
                            if (ASite.feature[iCountRichness] = iFCode)
                            {$ENDIF}
                            and (AFeat.targetarea > 0) then
                            begin
                                 fSiteUsed := True;

                                 //rDeducedTarget := AFeat.targetarea + Value.rAmount;

                                 if (AFeat.targetarea < Value.rAmount) then
                                    rContributingArea := AFeat.targetarea
                                 else
                                     rContributingArea := Value.rAmount;

                                 rCurrValue := Value.rAmount{rContributingArea} /
                                               AFeat.targetarea * 100;
                                 {if (rCurrValue >= 100) then
                                    sCurrValue := '100'
                                 else}
                                     Str(rCurrValue:5:2,sCurrValue);

                                 if (Length(sCurrValue) > 3)
                                 and (Copy(sCurrValue,Length(sCurrValue)-2,3) = '.00') then
                                     sCurrValue := {'   ' +} Copy(sCurrValue,1,Length(sCurrValue)-3);
                                 TrimLeadSpaces(sCurrValue);
                                 MapGrid.Cells[iCountF+1,MapGrid.RowCount-1] := sCurrValue;
                            end;
                       end;
                  end;

                  if fSiteUsed then
                     VisibleCodes.Items.Add(IntToStr(ASite.iKey))
                  else
                      MapGrid.RowCount := MapGrid.RowCount - 1;
             end;
        end;

        if (MapGrid.RowCount > 1) then
           MapGrid.FixedRows := 1;

        // display unfiltered and unsorted grid to the user
        CancelFilterAndSort(MapGrid,ModifiedGrid);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TS1GridForm.FormCreate',
                      mtError,[mbOK],0);
     end;

     ControlForm.ProgressOff;
     ControlForm.ProcLabelOff;
end;

procedure TAvailableSitesForm.LocalClickClick(Sender: TObject);
begin
     ControlForm.ClickGroup.ItemIndex := LocalClick.ItemIndex;
end;

procedure TAvailableSitesForm.FormResize(Sender: TObject);
var
   iCount, iCountF, iFCode, iFeatIndex, iSiteKey : integer;
   sALine, sSiteName : string;
   pFeat : featureoccurrencepointer;

begin
     if (MapGrid.ColCount < GRID_MAX_COLUMNS)
     {and not fWideGrid} then
     try
        //Screen.Cursor := crHourglass;

        S1Box.Items.Clear;

        Caption := 'Available Sites';

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception resizing Available Sites form',
                      mtError,[mbOK],0);
     end;
end;

procedure TAvailableSitesForm.ToggleSelect(const iRow : integer);
var
   iRows : integer;
begin
     // toggle the selection status of this row
     if (ModifiedGrid.Cells[0,iRow] = '') then
        ModifiedGrid.Cells[0,iRow] := 'Select'
     else
         ModifiedGrid.Cells[0,iRow] := '';

     // now toggle the selection status in MapGrid
     // find this site key in the MapGrid
     for iRows := 1 to (MapGrid.RowCount - 1) do
         if (MapGrid.Cells[1,{site key column}
                           iRows] = ModifiedGrid.Cells[1,iRow]) then
         begin
              // toggle row iRows in MapGrid
              MapGrid.Cells[0,iRows] := ModifiedGrid.Cells[0,iRow];
         end;
end;

procedure CancelFilterAndSort(InGrid,OutGrid : TStringGrid);
var
   iRows, iColumns : integer;
begin
     try
        OutGrid.ColCount := InGrid.ColCount;
        OutGrid.RowCount := InGrid.RowCount;
        for iRows := 0 to (InGrid.RowCount - 1) do
            for iColumns := 0 to (InGrid.ColCount - 1) do
                OutGrid.Cells[iColumns,iRows] := InGrid.Cells[iColumns,iRows];

     except

     end;
end;

procedure ApplyFilterToGrid(InGrid, OutGrid : TStringGrid;
                            const iOperator : integer;
                            const sField, sValue : string);
var
   iRows, iColumns, iOutRow, iFilterColumn : integer;
   fDataIsFloatingPoint, fAddRow : boolean;

   function AnalyseFloatValue : boolean;
   var
      rValue : extended;
   begin
        Result := False;
        if (InGrid.Cells[iFilterColumn,iRows] = '') then
           rValue := 0 // treat a blank cell as a zero for the purposes of a float sort
        else
            rValue := RegionSafeStrToFloat(InGrid.Cells[iFilterColumn,iRows]);
        case iOperator of
             0 : Result := (RegionSafeStrToFloat(sValue) = rValue);
             1 : Result := (RegionSafeStrToFloat(sValue) <> rValue);
             3 : Result := (RegionSafeStrToFloat(sValue) > rValue);
             2 : Result := (RegionSafeStrToFloat(sValue) < rValue);
             5 : Result := (RegionSafeStrToFloat(sValue) >= rValue);
             4 : Result := (RegionSafeStrToFloat(sValue) <= rValue);
        end;
   end;

   function AnalyseStringValue : boolean;
   begin
        Result := False;
        case iOperator of
             0 : Result := (sValue = InGrid.Cells[iFilterColumn,iRows]);
             1 : Result := (sValue <> InGrid.Cells[iFilterColumn,iRows]);
             3 : Result := (sValue > InGrid.Cells[iFilterColumn,iRows]);
             2 : Result := (sValue < InGrid.Cells[iFilterColumn,iRows]);
             5 : Result := (sValue >= InGrid.Cells[iFilterColumn,iRows]);
             4 : Result := (sValue <= InGrid.Cells[iFilterColumn,iRows]);
        end;
   end;

begin
     try
        // apply filter to grid
        // find index of the field to filter
        iFilterColumn := 0;
        for iColumns := 0 to (InGrid.ColCount - 1) do
            if (sField = InGrid.Cells[iColumns,0]) then
               iFilterColumn := iColumns;
        fDataIsFloatingPoint := True;
        iOutRow := 1;
        OutGrid.ColCount := InGrid.ColCount;
        OutGrid.RowCount := InGrid.RowCount;
        // copy column names
        for iColumns := 0 to (InGrid.ColCount - 1) do
            OutGrid.Cells[iColumns,0] := InGrid.Cells[iColumns,0];
        // add rows that satisfy the criteria
        for iRows := 1 to (InGrid.RowCount - 1) do
        begin
             fAddRow := False;

             if fDataIsFloatingPoint then
             try
                // try to process the values as floating point numbers
                fAddRow := AnalyseFloatValue;

             except
                   fDataIsFloatingPoint := False;
             end;

             if not fDataIsFloatingPoint then
                // process the data as string
                fAddRow := AnalyseStringValue;

             if fAddRow then
             begin
                  for iColumns := 0 to (InGrid.ColCount - 1) do
                      OutGrid.Cells[iColumns,iOutRow] := InGrid.Cells[iColumns,iRows];

                  Inc(iOutRow);
             end
             else
                 OutGrid.RowCount := OutGrid.RowCount - 1;
        end;

     except

     end;
end;

procedure ApplySortToGrid(InGrid, OutGrid : TStringGrid;
                          const iDirection : integer;
                          const sField : string);
var
   iRows, iColumns, iSortColumn : integer;
   fFieldIsFloat : boolean;
   rTestValue : extended;
begin
     try
        // apply sort to grid
        // fill out grid with all the cell values
        CancelFilterAndSort(InGrid,OutGrid);
        // find index of the field to sort
        iSortColumn := 0;
        for iColumns := 0 to (OutGrid.ColCount - 1) do
            if (sField = OutGrid.Cells[iColumns,0]) then
               iSortColumn := iColumns;

        // determine field type for the field to sort
        fFieldIsFloat := True;
        for iRows := 1 to (OutGrid.RowCount - 1) do
            try
               if fFieldIsFloat then
                  if (OutGrid.Cells[iSortColumn,iRows] <> '') then
                     rTestValue := RegionSafeStrToFloat(OutGrid.Cells[iSortColumn,iRows])
            except
                  fFieldIsFloat := False;
            end;

        // call a sorting function on OutGrid
        if fFieldIsFloat then
           SortGrid(OutGrid,
                    1,                        // row to start sorting from
                    iSortColumn,              // column to sort by
                    SORT_TYPE_REAL,           // sort type
                    SortForm.RadioDirection.ItemIndex) // sort direction ; 0 is descending, 1 is ascending
        else
            SortGrid(OutGrid,
                     1,
                     iSortColumn,
                     SORT_TYPE_STRING,
                     SortForm.RadioDirection.ItemIndex);

     except

     end;
end;

procedure TAvailableSitesForm.ModifiedGridSelectCell(Sender: TObject; Col,
  Row: Integer; var CanSelect: Boolean);
begin
     ModifiedGrid.Hint := ModifiedGrid.Cells[Col,Row];

     // toggle the selection of this row
     if (Row > 0) then
        ToggleSelect(Row);
end;

procedure TAvailableSitesForm.AutoFit1Click(Sender: TObject);
begin
     AutoFitGrid(ModifiedGrid,
                 Canvas,
                 True {fit entire grid});
end;

procedure TAvailableSitesForm.Filter1Click(Sender: TObject);
var
   iCount : integer;
begin
     FilterForm := TFilterForm.Create(Application);
     // prepare filter form
     FilterForm.ComboField.Text := MapGrid.Cells[0,0];
     for iCount := 0 to (MapGrid.ColCount - 1) do
         FilterForm.ComboField.Items.Add(MapGrid.Cells[iCount,0]);
     FilterStringGrid := MapGrid;
     if (FilterForm.ShowModal = mrOk) then
     begin
          // perform filter
          ApplyFilterToGrid(MapGrid,ModifiedGrid,            // in and out grids
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
          CancelFilterAndSort(MapGrid,ModifiedGrid);
          lblGridSpec.Caption := '';
     end;
     FilterForm.Free;
end;

procedure TAvailableSitesForm.Sort1Click(Sender: TObject);
var
   iCount : integer;
begin
     SortForm := TSortForm.Create(Application);
     // prepare sort form
     SortForm.ComboField.Text := MapGrid.Cells[0,0];
     for iCount := 0 to (MapGrid.ColCount - 1) do
         SortForm.ComboField.Items.Add(MapGrid.Cells[iCount,0]);
     if (SortForm.ShowModal = mrOk) then
     begin
          // perform sort
          ApplySortToGrid(MapGrid,ModifiedGrid,
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
          CancelFilterAndSort(MapGrid,ModifiedGrid);

          lblGridSpec.Caption := '';
     end;
     SortForm.Free;
end;

procedure TAvailableSitesForm.Copy1Click(Sender: TObject);
begin
     CopyGridSelectionToClipboard(ModifiedGrid);
end;

procedure TAvailableSitesForm.CancelFilterSort1Click(Sender: TObject);
begin
     CancelFilterAndSort(MapGrid,ModifiedGrid);
     lblGridSpec.Caption := '';
end;

procedure TAvailableSitesForm.Save1Click(Sender: TObject);
begin
     SaveDialog1.InitialDir := ControlRes^.sWorkingDirectory;
     if SaveDialog1.Execute then
        SaveStringGrid2CSV(ModifiedGrid,SaveDialog1.Filename);
end;

procedure TAvailableSitesForm.Map1Click(Sender: TObject);
var
   UserSites : Array_t;
   iUserSites, iUserSite, iCount : integer;
begin
     // Build a list of selected sites from the grid and pass
     // the list to the handler
     try
        Screen.Cursor := crHourglass;

        UserSites := Array_t.Create;
        UserSites.init(SizeOf(integer),ARR_STEP_SIZE);
        iUserSites := 0;

        if (MapGrid.RowCount > 1) then
           for iCount := 1 to (MapGrid.RowCount-1) do
               if (MapGrid.Cells[0,iCount] <> '') then
               begin
                    inc(iUserSites);
                    if (iUserSites > UserSites.lMaxSize) then
                       UserSites.resize(UserSites.lMaxSize + ARR_STEP_SIZE);
                    iUserSite := StrToInt(VisibleCodes.Items.Strings[iCount-1]);
                    UserSites.setValue(iUserSites,@iUserSite);
               end;

       if (iUserSites > 0) then
       begin
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

end.
