unit displaysites;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, Grids, ExtCtrls, StdCtrls,
  ds;

type
  TDisplaySitesForm = class(TForm)
    Panel1: TPanel;
    SiteGrid: TStringGrid;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Save1: TMenuItem;
    Exit1: TMenuItem;
    Copy1: TMenuItem;
    AutoFit1: TMenuItem;
    Select1: TMenuItem;
    SelectDeSelectAll1: TMenuItem;
    InvertSelection1: TMenuItem;
    SelectedSitesTo1: TMenuItem;
    Av1: TMenuItem;
    Ne1: TMenuItem;
    Ma1: TMenuItem;
    Pd1: TMenuItem;
    Fl1: TMenuItem;
    Ex1: TMenuItem;
    Lookup1: TMenuItem;
    Features1: TMenuItem;
    Matrix1: TMenuItem;
    DisplayFields: TListBox;
    SaveCSV: TSaveDialog;
    Sites1: TMenuItem;
    Contribution1: TMenuItem;
    SelectionLog1: TMenuItem;
    PartiallyReservedSites1: TMenuItem;
    MapRedundantSites1: TMenuItem;
    ReplacementSites1: TMenuItem;
    Resource1: TMenuItem;
    Search1: TMenuItem;
    Minset1: TMenuItem;
    Options1: TMenuItem;
    SelectAs1: TMenuItem;
    DeSelectFrom1: TMenuItem;
    N1: TMenuItem;
    Lookup2: TMenuItem;
    Map1: TMenuItem;
    AddToMap1: TMenuItem;
    NegotiatedReserve1: TMenuItem;
    MandatoryReserve1: TMenuItem;
    PartiallyReserved1: TMenuItem;
    N2: TMenuItem;
    Flagged1: TMenuItem;
    Excluded1: TMenuItem;
    NegotiatedReserve2: TMenuItem;
    MandatoryReserve2: TMenuItem;
    PartiallyReserved2: TMenuItem;
    N3: TMenuItem;
    ReservedNRMR1: TMenuItem;
    ReservedNRMRPR1: TMenuItem;
    N4: TMenuItem;
    Flagged2: TMenuItem;
    Excluded2: TMenuItem;
    N5: TMenuItem;
    SelectAs2: TMenuItem;
    DeSelectFrom2: TMenuItem;
    N6: TMenuItem;
    Lookup3: TMenuItem;
    N7: TMenuItem;
    Map2: TMenuItem;
    AddToMap2: TMenuItem;
    NegotiatedReserve3: TMenuItem;
    MandatoryReserve3: TMenuItem;
    NegotiatedReserve4: TMenuItem;
    MandatoryReserve4: TMenuItem;
    PartiallyReserved3: TMenuItem;
    N8: TMenuItem;
    ReservedNRMR2: TMenuItem;
    ReservedNRMRPR2: TMenuItem;
    LookupFields1: TMenuItem;
    N9: TMenuItem;
    GIS1: TMenuItem;
    Display1: TMenuItem;
    Files1: TMenuItem;
    ExtendedFunctions1: TMenuItem;
    Validate1: TMenuItem;
    CombinationSize1: TMenuItem;
    SpatialModule1: TMenuItem;
    N10: TMenuItem;
    SaveOptionsNow1: TMenuItem;
    RestoreDefaultOptions1: TMenuItem;
    Tools1: TMenuItem;
    LaunchTableEditor1: TMenuItem;
    LaunchTableEditorOldVersion1: TMenuItem;
    N11: TMenuItem;
    MatrixReport1: TMenuItem;
    FeatureAmount1: TMenuItem;
    PartialStatus1: TMenuItem;
    FeatureIrreplaceability1: TMenuItem;
    toTarget1: TMenuItem;
    AllMatrixReports1: TMenuItem;
    N12: TMenuItem;
    FastMinset1: TMenuItem;
    VariableCombsizeReport1: TMenuItem;
    PerformSFpredictorvalidation1: TMenuItem;
    ArcViewDDEForm1: TMenuItem;
    SaveSparseMatrix1: TMenuItem;
    ReportEMSFiles1: TMenuItem;
    ReportSpatialConfig1: TMenuItem;
    SendPrepareSpread1: TMenuItem;
    ReportSpatialSpread1: TMenuItem;
    RandomSiteSelection1: TMenuItem;
    IterateTillSatisfied1: TMenuItem;
    RandomTest1: TMenuItem;
    A1: TMenuItem;
    About1: TMenuItem;
    N13: TMenuItem;
    OpenSelections1: TMenuItem;
    SaveSelectionsAs1: TMenuItem;
    ClearSelections1: TMenuItem;
    AddSelections1: TMenuItem;
    N14: TMenuItem;
    SetWorkingDirectory1: TMenuItem;
    N15: TMenuItem;
    Exit2: TMenuItem;
    N16: TMenuItem;
    DisplayFields1: TMenuItem;
    DisplayRows1: TMenuItem;
    SortField1: TMenuItem;
    lblStatus: TLabel;
    Openversion3XLOGfile1: TMenuItem;
    AvailableSites1: TMenuItem;
    ReservedSites1: TMenuItem;
    AllSites1: TMenuItem;
    a_r3: TMenuItem;
    a_r4: TMenuItem;
    a_r5: TMenuItem;
    b_r3: TMenuItem;
    b_r4: TMenuItem;
    b_r5: TMenuItem;
    c_r3: TMenuItem;
    c_r4: TMenuItem;
    c_r5: TMenuItem;
    d_r3: TMenuItem;
    d_r4: TMenuItem;
    d_r5: TMenuItem;
    e_r3: TMenuItem;
    e_r4: TMenuItem;
    e_r5: TMenuItem;
    OpenSelectionsolderversions1: TMenuItem;
    Marxan1: TMenuItem;
    MarxanPrototype1: TMenuItem;
    SelectRows1: TMenuItem;
    N17: TMenuItem;
    BuildDatabase1: TMenuItem;
    Options2: TMenuItem;
    N18: TMenuItem;
    DisplayMarxanSiteValues1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure DisplayAllSites;
    procedure LoadDisplayFields;
    procedure LabelDisplayFields;
    procedure InitAllSites;
    procedure SiteGridSelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    procedure Exit1Click(Sender: TObject);
    procedure SelectDeSelectAll1Click(Sender: TObject);
    procedure InvertSelection1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure AutoFit1Click(Sender: TObject);
    procedure Av1Click(Sender: TObject);
    procedure Selected2Arr(var SelectedSites : Array_t);
    procedure Ne1Click(Sender: TObject);
    procedure Ma1Click(Sender: TObject);
    procedure Pd1Click(Sender: TObject);
    procedure Fl1Click(Sender: TObject);
    procedure Ex1Click(Sender: TObject);
    procedure Features1Click(Sender: TObject);
    procedure Contribution1Click(Sender: TObject);
    procedure SelectionLog1Click(Sender: TObject);
    procedure PartiallyReservedSites1Click(Sender: TObject);
    procedure MapRedundantSites1Click(Sender: TObject);
    procedure ReplacementSites1Click(Sender: TObject);
    procedure Resource1Click(Sender: TObject);
    procedure NegotiatedReserve1Click(Sender: TObject);
    procedure MandatoryReserve1Click(Sender: TObject);
    procedure PartiallyReserved1Click(Sender: TObject);
    procedure Flagged1Click(Sender: TObject);
    procedure Excluded1Click(Sender: TObject);
    procedure NegotiatedReserve2Click(Sender: TObject);
    procedure MandatoryReserve2Click(Sender: TObject);
    procedure PartiallyReserved2Click(Sender: TObject);
    procedure ReservedNRMR1Click(Sender: TObject);
    procedure ReservedNRMRPR1Click(Sender: TObject);
    procedure Flagged2Click(Sender: TObject);
    procedure Excluded2Click(Sender: TObject);
    procedure Lookup2Click(Sender: TObject);
    procedure Map1Click(Sender: TObject);
    procedure AddToMap1Click(Sender: TObject);
    procedure Lookup3Click(Sender: TObject);
    procedure Map2Click(Sender: TObject);
    procedure AddToMap2Click(Sender: TObject);
    procedure NegotiatedReserve3Click(Sender: TObject);
    procedure MandatoryReserve3Click(Sender: TObject);
    procedure NegotiatedReserve4Click(Sender: TObject);
    procedure MandatoryReserve4Click(Sender: TObject);
    procedure PartiallyReserved3Click(Sender: TObject);
    procedure ReservedNRMR2Click(Sender: TObject);
    procedure ReservedNRMRPR2Click(Sender: TObject);
    procedure LookupFields1Click(Sender: TObject);
    procedure GIS1Click(Sender: TObject);
    procedure Display1Click(Sender: TObject);
    procedure Files1Click(Sender: TObject);
    procedure ExtendedFunctions1Click(Sender: TObject);
    procedure Validate1Click(Sender: TObject);
    procedure CombinationSize1Click(Sender: TObject);
    procedure SpatialModule1Click(Sender: TObject);
    procedure SaveOptionsNow1Click(Sender: TObject);
    procedure RestoreDefaultOptions1Click(Sender: TObject);
    procedure LaunchTableEditor1Click(Sender: TObject);
    procedure LaunchTableEditorOldVersion1Click(Sender: TObject);
    procedure FeatureAmount1Click(Sender: TObject);
    procedure PartialStatus1Click(Sender: TObject);
    procedure FeatureIrreplaceability1Click(Sender: TObject);
    procedure toTarget1Click(Sender: TObject);
    procedure AllMatrixReports1Click(Sender: TObject);
    procedure FastMinset1Click(Sender: TObject);
    procedure VariableCombsizeReport1Click(Sender: TObject);
    procedure PerformSFpredictorvalidation1Click(Sender: TObject);
    procedure ArcViewDDEForm1Click(Sender: TObject);
    procedure SaveSparseMatrix1Click(Sender: TObject);
    procedure ReportEMSFiles1Click(Sender: TObject);
    procedure ReportSpatialConfig1Click(Sender: TObject);
    procedure SendPrepareSpread1Click(Sender: TObject);
    procedure ReportSpatialSpread1Click(Sender: TObject);
    procedure RandomSiteSelection1Click(Sender: TObject);
    procedure IterateTillSatisfied1Click(Sender: TObject);
    procedure RandomTest1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure OpenSelections1Click(Sender: TObject);
    procedure SaveSelectionsAs1Click(Sender: TObject);
    procedure ClearSelections1Click(Sender: TObject);
    procedure AddSelections1Click(Sender: TObject);
    procedure SetWorkingDirectory1Click(Sender: TObject);
    procedure Exit2Click(Sender: TObject);
    procedure DisplayFields1Click(Sender: TObject);
    procedure LoadPositionSize;
    procedure SavePositionSize;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Matrix1Click(Sender: TObject);
    procedure LabelNeMa;
    procedure FormShow(Sender: TObject);
    procedure SortField1Click(Sender: TObject);
    procedure Openversion3XLOGfile1Click(Sender: TObject);
    procedure e_r3Click(Sender: TObject);
    procedure e_r4Click(Sender: TObject);
    procedure e_r5Click(Sender: TObject);
    procedure a_r3Click(Sender: TObject);
    procedure a_r4Click(Sender: TObject);
    procedure a_r5Click(Sender: TObject);
    procedure b_r3Click(Sender: TObject);
    procedure b_r4Click(Sender: TObject);
    procedure b_r5Click(Sender: TObject);
    procedure c_r3Click(Sender: TObject);
    procedure c_r4Click(Sender: TObject);
    procedure c_r5Click(Sender: TObject);
    procedure d_r3Click(Sender: TObject);
    procedure d_r4Click(Sender: TObject);
    procedure d_r5Click(Sender: TObject);
    procedure OpenSelectionsolderversions1Click(Sender: TObject);
    procedure SelectRows1Click(Sender: TObject);
    procedure MarxanPrototype1Click(Sender: TObject);
    procedure Options2Click(Sender: TObject);
    procedure BuildDatabase1Click(Sender: TObject);
    procedure DisplayMarxanSiteValues1Click(Sender: TObject);
  private
    { Private declarations }
    fQuery, fSort : boolean;
    sQueryField, sQueryOperator, sQueryValue,
    sSortField : string;
    iSortOrder : integer;
  public
    { Public declarations }
  end;

var
  DisplaySitesForm: TDisplaySitesForm;

implementation

uses
    inifiles, global, control, featgrid, lookup, auto_fit, highligh,
    sf_irrep, sql_unit, sitelookupfields,
    dde_unit, choosesiterows, selectsitesortfield,
    partl_ed, marxan_files, marxan;

{$R *.DFM}

function rtnFieldType(const sField : string) : integer;
var
   iCount : integer;
begin
     // 0=str, 1=number
     Result := 0;
     if (UpperCase(sField) = 'SITEKEY')
     or (UpperCase(sField) = 'AREA')
     or (UpperCase(sField) = 'PCCONTR')
     or (UpperCase(sField) = 'SUMIRR')
     or (UpperCase(sField) = 'WAVIRR')
     or (UpperCase(sField) = 'IRREPL') then
        Result := 1;

     if ControlRes^.fMarxanDatabaseExists
     and fMarxanResultCreated then
     begin
          if {(UpperCase(sField) = 'MARXANINBESTSOLUTION')
          or} (UpperCase(sField) = 'MARXANSUMMEDSOLUTION') then
             Result := 1;

          //for iCount := 1 to iMarxanScenarios do
          //begin
          //     if (UpperCase(sField) = 'MARXANINSOLUTION' + IntToStr(iCount)) then
          //        Result := 1;
          //end;
     end;
end;

function rtnSiteValue(const pSite : sitepointer;
                      const MarxanSiteResult : MarxanSiteResult_T;
                      const sField : string) : string;
var
   iCount : integer;
   fInSolution : boolean;
begin
     Result := '';

     if (UpperCase(sField) = 'SITEKEY') then
        Result := IntToStr(pSite^.iKey)
     else
     if (UpperCase(sField) = 'SITENAME') then
        Result := pSite^.sName
     else
     if (UpperCase(sField) = 'STATUS') then
        Result := Status2Str(pSite^.status)
     else
     if (UpperCase(sField) = 'I_STATUS') then
        case pSite^.status of
             Av,_R1,_R2,_R3,_R4,_R5,Pd,Fl,Ex : Result := 'Initial Available';
             Ig : Result := 'Initial Excluded';
             Re : Result := 'Initial Reserve';
        end
     else
     if (UpperCase(sField) = 'AREA') then
        Result := FloatToStr(pSite^.area)
     else
     if (UpperCase(sField) = 'PCCONTR') then
        Result := FloatToStr(pSite^.rPCUSED)
     else
     if (UpperCase(sField) = 'SUMIRR') then
        Result := FloatToStr(pSite^.rSummedIrr)
     else
     if (UpperCase(sField) = 'WAVIRR') then
        Result := FloatToStr(pSite^.rWAVIRR)
     else
     if (UpperCase(sField) = 'IRREPL') then
        Result := FloatToStr(pSite^.rIrreplaceability)
     else
     if (UpperCase(sField) = 'DISPLAY') then
        Result := pSite^.sDisplay
     else
         if ControlRes^.fMarxanDatabaseExists
         and fMarxanResultCreated then
         begin
              if (UpperCase(sField) = 'MARXANINBESTSOLUTION') then
                 Result := Bool2String(MarxanSiteResult.fInBestSolution)
              else
              if (UpperCase(sField) = 'MARXANSUMMEDSOLUTION') then
                 Result := IntToStr(MarxanSiteResult.iSummedSolution)
              else
                  for iCount := 1 to iMarxanScenarios do
                  begin
                       if (UpperCase(sField) = 'MARXANINSOLUTION' + IntToStr(iCount)) then
                       begin
                            MarxanSiteResult.InSolution.rtnValue(iCount,@fInSolution);
                            Result := Bool2String(fInSolution);
                       end;
                  end;
         end;
{'SITEKEY'
'SITENAME'
'STATUS'
'I_STATUS'
'AREA'
'PCCONTR'
'SUMIRR'
'WAVIRR'
'IRREPL'
'DISPLAY'}
end;

procedure TDisplaySitesForm.DisplayAllSites;
var
   iCount, iField, iSiteRows, iQueryFieldType, iSortFieldType, iSortField : integer;
   pSite : sitepointer;
   fInclude : boolean;
   wSortType, wSortDirection : word;
   sTmp : string;
   MarxanSiteResult : MarxanSiteResult_T;

   function EvaluateQuery : boolean;
   var
      sValue : string;
   begin
        Result := True;
        sValue := rtnSiteValue(pSite,MarxanSiteResult,sQueryField);
        case iQueryFieldType of
             0 :
             begin
                  //str  operators = <> > < >= <=
                  if (sQueryOperator = '=') then
                     Result := (sValue = sQueryValue)
                  else
                      if (sQueryOperator = '<>') then
                         Result := (sValue <> sQueryValue)
                      else
                          if (sQueryOperator = '>') then
                             Result := (sValue > sQueryValue)
                          else
                              if (sQueryOperator = '<') then
                                 Result := (sValue < sQueryValue)
                              else
                                  if (sQueryOperator = '>=') then
                                     Result := (sValue >= sQueryValue)
                                  else
                                      if (sQueryOperator = '<=') then
                                         Result := (sValue <= sQueryValue);
             end;
             1 :
             begin
                  //number operators = <> > < >= <=
                  if (sQueryOperator = '=') then
                     Result := (StrToFloat(sValue) = StrToFloat(sQueryValue))
                  else
                      if (sQueryOperator = '<>') then
                         Result := (StrToFloat(sValue) <> StrToFloat(sQueryValue))
                      else
                          if (sQueryOperator = '>') then
                             Result := (StrToFloat(sValue) > StrToFloat(sQueryValue))
                          else
                              if (sQueryOperator = '<') then
                                 Result := (StrToFloat(sValue) < StrToFloat(sQueryValue))
                              else
                                  if (sQueryOperator = '>=') then
                                     Result := (StrToFloat(sValue) >= StrToFloat(sQueryValue))
                                  else
                                      if (sQueryOperator = '<=') then
                                         Result := (StrToFloat(sValue) <= StrToFloat(sQueryValue));
             end;
        end;

   end;
begin
     Screen.Cursor := crHourglass;
     try
        new(pSite);

        if (fQuery) then
           iQueryFieldType := rtnFieldType(sQueryField);
        if (fSort) then
           iSortFieldType := rtnFieldType(sSortField);

        // set number of rows in the grid
        SiteGrid.RowCount := iSiteCount + 1;
        iSiteRows := 0;
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);

             if (pSite^.status <> Re)
             and (pSite^.status <> Ig) then
             begin
                  if ControlRes^.fMarxanDatabaseExists
                  and fMarxanResultCreated then
                      MarxanSites.rtnValue(iCount,@MarxanSiteResult);

                  if fQuery then
                  begin
                       // check if this row should be included
                       fInclude := EvaluateQuery;
                  end
                  else
                      // no query, include all rows
                      fInclude := True;

                  if fInclude then
                  begin
                       Inc(iSiteRows);
                       SiteGrid.Cells[0,iSiteRows] := '';

                       for iField := 1 to DisplayFields.Items.Count do
                           SiteGrid.Cells[iField,iSiteRows] := rtnSiteValue(pSite,MarxanSiteResult,DisplayFields.Items.Strings[iField-1]);
                  end;
             end;
        end;
        SiteGrid.RowCount := iSiteRows + 1;

        if (SiteGrid.RowCount > 1) then
           SiteGrid.FixedRows := 1;

        dispose(pSite);

        AutoFit1Click(Self);

        if fSort then
        begin
             wSortDirection := iSortOrder;

             iSortField := 0;
             for iCount := 0 to (SiteGrid.ColCount - 1) do
                 if (sSortField = SiteGrid.Cells[iCount,0]) then
                    iSortField := iCount;

             case iSortFieldType of
                  0 : wSortType := SORT_TYPE_STRING;
                  1 : wSortType := SORT_TYPE_REAL;
             end;

             SortGrid(SiteGrid,1,iSortField,wSortType,wSortDirection);
        end;

        lblStatus.Caption := IntToStr(iSiteRows) + ' sites   ';
        if fQuery then
           lblStatus.Caption := lblStatus.Caption + 'QUERY ' + sQueryField + ' ' + sQueryOperator + ' ' + sQueryValue + '   ';
        if fSort then
        begin
             case iSortOrder of
                  0 : sTmp := 'descending';
                  1 : sTmp := 'ascending';
             end;
             lblStatus.Caption := lblStatus.Caption + 'SORT ' + sSortField + ' ' + sTmp;
        end;
     except
     end;
     Screen.Cursor := crDefault;
end;

procedure TDisplaySitesForm.LoadDisplayFields;
var
   AIni : TIniFile;
begin
     // load display field names from the ini file
     AIni := TIniFile.Create(ControlRes^.sDatabase + '\cplan.ini');
     DisplayFields.Items.Clear;
     AIni.ReadSection('Site Info Fields',DisplayFields.Items);
     AIni.Free;
     // use default field names if none present
     if (DisplayFields.Items.Count = 0) then
     begin
          DisplayFields.Items.Add('SITEKEY');
          DisplayFields.Items.Add('SITENAME');
          DisplayFields.Items.Add('STATUS');
     end;
     // add SITEKEY if it is not already present
     if (DisplayFields.Items.IndexOf('SITEKEY') = -1) then
        DisplayFields.Items.Insert(0,'SITEKEY');
end;

procedure TDisplaySitesForm.LabelDisplayFields;
var
   iCount : integer;
begin
     // set number of columns and label columns
     SiteGrid.ColCount := DisplayFields.Items.Count + 1;
     SiteGrid.Cells[0,0] := 'Select';
     for iCount := 1 to DisplayFields.Items.Count do
         SiteGrid.Cells[iCount,0] := DisplayFields.Items.Strings[iCount-1];
end;

procedure TDisplaySitesForm.InitAllSites;
begin
     // load display field names from the ini file
     LoadDisplayFields;
     LabelDisplayFields;
     // display fields for all sites
     DisplayAllSites;
end;

procedure TDisplaySitesForm.FormCreate(Sender: TObject);
begin
     fQuery := False;
     sQueryField := '';
     sQueryOperator := '';
     sQueryValue := '';
     LoadPositionSize;
     InitAllSites;
end;

procedure TDisplaySitesForm.SiteGridSelectCell(Sender: TObject; Col,
  Row: Integer; var CanSelect: Boolean);
begin
     if (Col = 0)
     and (Row > 0) then
         if (SiteGrid.Cells[Col,Row] = '') then
            SiteGrid.Cells[Col,Row] := 'Select'
         else
             SiteGrid.Cells[Col,Row] := '';
end;

procedure TDisplaySitesForm.Exit1Click(Sender: TObject);
begin
     ModalResult := mrOK;
end;

procedure TDisplaySitesForm.SelectDeSelectAll1Click(Sender: TObject);
var
   iCount : integer;
   sCell : string;
begin
     if (SiteGrid.Cells[0,1] = '') then
        sCell := 'Select'
     else
         sCell := '';

     for iCount := 1 to (SiteGrid.RowCount-1) do
         SiteGrid.Cells[0,iCount] := sCell;
end;

procedure TDisplaySitesForm.InvertSelection1Click(Sender: TObject);
var
   iCount : integer;
begin
     for iCount := 1 to (SiteGrid.RowCount-1) do
         if (SiteGrid.Cells[0,iCount] = '') then
            SiteGrid.Cells[0,iCount] := 'Select'
         else
             SiteGrid.Cells[0,iCount] := '';
end;

procedure TDisplaySitesForm.Save1Click(Sender: TObject);
begin
     SaveCSV.InitialDir := ControlRes^.sWorkingDirectory;
     SaveCSV.FileName := 'siteinfo.csv';

     if SaveCSV.Execute then
     begin
          if FileExists(SaveCSV.Filename) then
          begin
               if (mrYes = MessageDlg('File ' + SaveCSV.Filename + ' exists.  Overwrite?',
                                      mtConfirmation,[mbYes,mbNo],0)) then
                  SaveStringGrid2CSV(SiteGrid,SaveCSV.Filename);
          end
          else
              SaveStringGrid2CSV(SiteGrid,SaveCSV.Filename);
     end;
end;

procedure TDisplaySitesForm.Copy1Click(Sender: TObject);
begin
     CopyGridSelectionToClipboard(SiteGrid);
end;

procedure TDisplaySitesForm.AutoFit1Click(Sender: TObject);
begin
     AutoFitGrid(SiteGrid,
                 Canvas,
                 True {fit entire grid});
end;

procedure TDisplaySitesForm.Selected2Arr(var SelectedSites : Array_t);
var
   iSITEKEYColumn, iCount, iSelectedSites, iSiteKey : integer;
begin
     SelectedSites := Array_t.Create;
     SelectedSites.init(SizeOf(integer),ARR_STEP_SIZE);
     iSelectedSites := 0;
     iSITEKEYColumn := DisplayFields.Items.IndexOf('SITEKEY') + 1;

     for iCount := 1 to (SiteGrid.RowCount-1) do
         if (SiteGrid.Cells[0,iCount] = 'Select') then
         begin
              Inc(iSelectedSites);
              if (iSelectedSites > SelectedSites.lMaxsize) then
                 SelectedSites.resize(SelectedSites.lMaxSize + ARR_STEP_SIZE);
              iSiteKey := StrToInt(SiteGrid.Cells[iSITEKEYColumn,iCount]);
              SelectedSites.setValue(iSelectedSites,@iSiteKey);
         end;

     if (iSelectedSites = 0) then
     begin
          SelectedSites.resize(1);
          SelectedSites.lMaxSize := 0;
     end
     else
         if (iSelectedSites <> SelectedSites.lMaxSize) then
            SelectedSites.resize(iSelectedSites);
end;

procedure TDisplaySitesForm.Av1Click(Sender: TObject);
var
   SitesChosen : Array_t;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
begin
     // clear all site selections in ControlForm
     ControlForm.AllClasses1Click(Sender);
     // get list of selected sites
     Selected2Arr(SitesChosen);
     // select list of selected sites in ControlForm
     // SitesChosen is destroyed by call to Arr2Highlight
     Arr2Highlight(SitesChosen,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);

     // call movegroup for the list of selected sites to Av
     with ControlForm do
     begin
          {de-select to Available from ALL classes}
          {try R1}
          if (R1.SelCount > 0) then
                MoveGroup(R1,R1Key,
                          Available,AvailableKey,TRUE,True);
          {try R2}
          if (R2.SelCount > 0) then
                MoveGroup(R2,R2Key,
                          Available,AvailableKey,TRUE,True);
          {try R3}
          if (R3.SelCount > 0) then
                MoveGroup(R3,R3Key,
                          Available,AvailableKey,TRUE,True);
          {try R4}
          if (R4.SelCount > 0) then
                MoveGroup(R4,R4Key,
                          Available,AvailableKey,TRUE,True);
          {try R5}
          if (R5.SelCount > 0) then
                MoveGroup(R5,R5Key,
                          Available,AvailableKey,TRUE,True);
          {try Partial}
          if (Partial.SelCount > 0) then
                MoveGroup(Partial,PartialKey,
                          Available,AvailableKey,TRUE,True);
          {try Flagged}
          if (Flagged.SelCount > 0) then
                MoveGroup(Flagged,FlaggedKey,
                          Available,AvailableKey,TRUE,True);
          {try Excluded}
          if (Excluded.SelCount > 0) then
                MoveGroup(Excluded,ExcludedKey,
                          Available,AvailableKey,TRUE,True);
     end;
     // recalculate irreplaceability
     ExecuteIrreplaceability(-1,False,False,True,True,'');
     // update site display form
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Ne1Click(Sender: TObject);
var
   SitesChosen : Array_t;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
begin
     // clear all site selections in ControlForm
     ControlForm.AllClasses1Click(Sender);
     // get list of selected sites
     Selected2Arr(SitesChosen);
     // select list of selected sites in ControlForm
     // SitesChosen is destroyed by call to Arr2Highlight
     Arr2Highlight(SitesChosen,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);

     // call movegroup for the list of selected sites to R1
     with ControlForm do
     begin
          if (Available.SelCount > 0) then
                MoveGroup(Available,AvailableKey,
                          R1,R1Key,TRUE,True);
     end;
     // recalculate irreplaceability
     ExecuteIrreplaceability(-1,False,False,True,True,'');
     // update site display form
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Ma1Click(Sender: TObject);
var
   SitesChosen : Array_t;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
begin
     // clear all site selections in ControlForm
     ControlForm.AllClasses1Click(Sender);
     // get list of selected sites
     Selected2Arr(SitesChosen);
     // select list of selected sites in ControlForm
     // SitesChosen is destroyed by call to Arr2Highlight
     Arr2Highlight(SitesChosen,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);

     // call movegroup for the list of selected sites to R2
     with ControlForm do
     begin
          if (Available.SelCount > 0) then
                MoveGroup(Available,AvailableKey,
                          R2,R2Key,TRUE,True);
     end;
     // recalculate irreplaceability
     ExecuteIrreplaceability(-1,False,False,True,True,'');
     // update site display form
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Pd1Click(Sender: TObject);
var
   SitesChosen : Array_t;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
begin
     // clear all site selections in ControlForm
     ControlForm.AllClasses1Click(Sender);
     // get list of selected sites
     Selected2Arr(SitesChosen);
     // select list of selected sites in ControlForm
     // SitesChosen is destroyed by call to Arr2Highlight
     Arr2Highlight(SitesChosen,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);

     // call movegroup for the list of selected sites to Pd
     with ControlForm do
     begin
          if (Available.SelCount > 0) then
                MoveGroup(Available,AvailableKey,
                          Partial,PartialKey,TRUE,True);
     end;
     // recalculate irreplaceability
     ExecuteIrreplaceability(-1,False,False,True,True,'');
     // update site display form
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Fl1Click(Sender: TObject);
var
   SitesChosen : Array_t;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
begin
     // clear all site selections in ControlForm
     ControlForm.AllClasses1Click(Sender);
     // get list of selected sites
     Selected2Arr(SitesChosen);
     // select list of selected sites in ControlForm
     // SitesChosen is destroyed by call to Arr2Highlight
     Arr2Highlight(SitesChosen,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);

     // call movegroup for the list of selected sites to Fl
     with ControlForm do
     begin
          if (Available.SelCount > 0) then
                MoveGroup(Available,AvailableKey,
                          Flagged,FlaggedKey,TRUE,True);
     end;
     // recalculate irreplaceability
     ExecuteIrreplaceability(-1,False,False,True,True,'');
     // update site display form
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Ex1Click(Sender: TObject);
var
   SitesChosen : Array_t;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
begin
     // clear all site selections in ControlForm
     ControlForm.AllClasses1Click(Sender);
     // get list of selected sites
     Selected2Arr(SitesChosen);
     // select list of selected sites in ControlForm
     // SitesChosen is destroyed by call to Arr2Highlight
     Arr2Highlight(SitesChosen,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);

     // call movegroup for the list of selected sites to Ex
     with ControlForm do
     begin
          if (Available.SelCount > 0) then
                MoveGroup(Available,AvailableKey,
                          Excluded,ExcludedKey,TRUE,True);
     end;
     // recalculate irreplaceability
     ExecuteIrreplaceability(-1,False,False,True,True,'');
     // update site display form
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Features1Click(Sender: TObject);
begin
     // close the display sites form
     ModalResult := mrOk;
     // display the display featues form
     ControlForm.FeatureInfo1Click(Sender);
end;

procedure TDisplaySitesForm.Contribution1Click(Sender: TObject);
begin
     ControlForm.Contribution1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.SelectionLog1Click(Sender: TObject);
begin
     ControlForm.Reasoning1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.PartiallyReservedSites1Click(Sender: TObject);
begin
     ControlForm.PartialDeferral1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.MapRedundantSites1Click(Sender: TObject);
begin
     ControlForm.MapRedundantSites1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.ReplacementSites1Click(Sender: TObject);
var
   SitesChosen : Array_t;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
begin
     // clear all site selections in ControlForm
     ControlForm.AllClasses1Click(Sender);
     // get list of selected sites
     Selected2Arr(SitesChosen);
     // select list of selected sites in ControlForm
     // SitesChosen is destroyed by call to Arr2Highlight
     Arr2Highlight(SitesChosen,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);
     ControlForm.ReplacementSites1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Resource1Click(Sender: TObject);
begin
     ControlForm.TimberResource1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.NegotiatedReserve1Click(Sender: TObject);
begin
     ControlForm.Negotiated1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.MandatoryReserve1Click(Sender: TObject);
begin
     ControlForm.Mandatory2Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.PartiallyReserved1Click(Sender: TObject);
begin
     ControlForm.Partial2Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Flagged1Click(Sender: TObject);
begin
     ControlForm.Flagged2Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Excluded1Click(Sender: TObject);
begin
     ControlForm.Excluded2Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.NegotiatedReserve2Click(Sender: TObject);
begin
     ControlForm.Negotiated2Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.MandatoryReserve2Click(Sender: TObject);
begin
     ControlForm.Mandatory3Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.PartiallyReserved2Click(Sender: TObject);
begin
     ControlForm.Partial3Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.ReservedNRMR1Click(Sender: TObject);
begin
     ControlForm.DeferredNeMaPd1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.ReservedNRMRPR1Click(Sender: TObject);
begin
     ControlForm.Deferred1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Flagged2Click(Sender: TObject);
begin
     ControlForm.Flagged3Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Excluded2Click(Sender: TObject);
begin
     ControlForm.Excluded3Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Lookup2Click(Sender: TObject);
begin
     ControlForm.Lookup1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Map1Click(Sender: TObject);
begin
     ControlForm.SQLMap2Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.AddToMap1Click(Sender: TObject);
begin
     ControlForm.SQLMap1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Lookup3Click(Sender: TObject);
begin
     ControlForm.Lookup1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Map2Click(Sender: TObject);
begin
     ControlForm.Map1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.AddToMap2Click(Sender: TObject);
begin
     ControlForm.AddToMap1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.NegotiatedReserve3Click(Sender: TObject);
begin
     ControlForm.Negotiated5Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.MandatoryReserve3Click(Sender: TObject);
begin
     ControlForm.Mandatory1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.NegotiatedReserve4Click(Sender: TObject);
begin
     ControlForm.Negotiated6Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.MandatoryReserve4Click(Sender: TObject);
begin
     ControlForm.Mandatory6Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.PartiallyReserved3Click(Sender: TObject);
begin
     ControlForm.Partial5Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.ReservedNRMR2Click(Sender: TObject);
begin
     ControlForm.DeferredNeMa1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.ReservedNRMRPR2Click(Sender: TObject);
begin
     ControlForm.DeferredNeMaPd2Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.LookupFields1Click(Sender: TObject);
begin
     ControlForm.DBMSFields1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.GIS1Click(Sender: TObject);
begin
     ControlForm.Display1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Display1Click(Sender: TObject);
begin
     ControlForm.Irreplacability2Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Files1Click(Sender: TObject);
begin
     ControlForm.Defaults1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.ExtendedFunctions1Click(Sender: TObject);
begin
     ControlForm.ExtendedFunctions1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.Validate1Click(Sender: TObject);
begin
     ControlForm.Validate1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.CombinationSize1Click(Sender: TObject);
begin
     ControlForm.CombinationSizeOptions1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.SpatialModule1Click(Sender: TObject);
begin
     ControlForm.SpatialModule1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.SaveOptionsNow1Click(Sender: TObject);
begin
     ControlForm.SaveOptions1Click(Sender);
end;

procedure TDisplaySitesForm.RestoreDefaultOptions1Click(Sender: TObject);
begin
     ControlForm.RestoreDefaultOptions1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.LaunchTableEditor1Click(Sender: TObject);
begin
     ControlForm.LaunchTableEditor1Click(Sender);
end;

procedure TDisplaySitesForm.LaunchTableEditorOldVersion1Click(
  Sender: TObject);
begin
     ControlForm.LaunchTableEditorOldVersion1Click(Sender);
end;

procedure TDisplaySitesForm.FeatureAmount1Click(Sender: TObject);
begin
     ControlForm.FeatureAmount1Click(Sender);
end;

procedure TDisplaySitesForm.PartialStatus1Click(Sender: TObject);
begin
     ControlForm.PartialStatus2Click(Sender);
end;

procedure TDisplaySitesForm.FeatureIrreplaceability1Click(Sender: TObject);
begin
     ControlForm.FeatureIrreplaceability1Click(Sender);
end;

procedure TDisplaySitesForm.toTarget1Click(Sender: TObject);
begin
     ControlForm.toTarget2Click(Sender);
end;

procedure TDisplaySitesForm.AllMatrixReports1Click(Sender: TObject);
begin
     ControlForm.AllMatrixReports2Click(Sender);
end;

procedure TDisplaySitesForm.FastMinset1Click(Sender: TObject);
begin
     ControlForm.FastMinset1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.VariableCombsizeReport1Click(Sender: TObject);
begin
     ControlForm.VariRunCombsize1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.PerformSFpredictorvalidation1Click(
  Sender: TObject);
begin
     ControlForm.ProduceSFvalidationmatrix1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.ArcViewDDEForm1Click(Sender: TObject);
begin
     ControlForm.ArcViewDDEForm1Click(Sender);
end;

procedure TDisplaySitesForm.SaveSparseMatrix1Click(Sender: TObject);
begin
     ControlForm.SaveSparseMatrix1Click(Sender);
end;

procedure TDisplaySitesForm.ReportEMSFiles1Click(Sender: TObject);
begin
     ControlForm.ReportEMSFiles1Click(Sender);
end;

procedure TDisplaySitesForm.ReportSpatialConfig1Click(Sender: TObject);
begin
     ControlForm.ReportSpatialConfig1Click(Sender);
end;

procedure TDisplaySitesForm.SendPrepareSpread1Click(Sender: TObject);
begin
     ControlForm.SendPrepareSpread1Click(Sender);
end;

procedure TDisplaySitesForm.ReportSpatialSpread1Click(Sender: TObject);
begin
     ControlForm.ReportSpatialSpread1Click(Sender);
end;

procedure TDisplaySitesForm.RandomSiteSelection1Click(Sender: TObject);
begin
     ControlForm.RandomSiteSelection1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.IterateTillSatisfied1Click(Sender: TObject);
begin
     ControlForm.IterateTillSatisfied1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.RandomTest1Click(Sender: TObject);
begin
     ControlForm.btnSelectClick(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.About1Click(Sender: TObject);
begin
     ControlForm.About1Click(Sender);
end;

procedure TDisplaySitesForm.OpenSelections1Click(Sender: TObject);
begin
     ControlForm.Open1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.SaveSelectionsAs1Click(Sender: TObject);
begin
     ControlForm.SaveAsNoClick(Sender);
end;

procedure TDisplaySitesForm.ClearSelections1Click(Sender: TObject);
begin
     ControlForm.ClearSelections1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.AddSelections1Click(Sender: TObject);
begin
     ControlForm.AddSelectionsfromfile1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.SetWorkingDirectory1Click(Sender: TObject);
begin
     ControlForm.SetWorkingDirectory1Click(Sender);
end;

procedure TDisplaySitesForm.Exit2Click(Sender: TObject);
begin
     ModalResult := mrOK;
     ControlForm.Exit1Click(Sender);
end;

procedure TDisplaySitesForm.DisplayFields1Click(Sender: TObject);
begin
     SelectSiteFieldsForm := TSelectSiteFieldsForm.Create(Application);
     SelectSiteFieldsForm.ShowModal;
     SelectSiteFieldsForm.Free;

     InitAllSites;
end;

procedure TDisplaySitesForm.LoadPositionSize;
var
   AIni : TIniFile;
   iTop, iLeft, iWidth, iHeight : integer;
begin
     AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
     iTop := AIni.ReadInteger('Site Info Form','Top',0);
     iLeft := AIni.ReadInteger('Site Info Form','Left',0);
     iWidth := AIni.ReadInteger('Site Info Form','Width',0);
     iHeight := AIni.ReadInteger('Site Info Form','Height',0);

     if (iTop <> 0) then
     begin
          Position := poDefault;

          Top := iTop;
          Left := iLeft;
          Width := iWidth;
          Height := iHeight;
     end;

     AIni.Free;
end;

procedure TDisplaySitesForm.SavePositionSize;
var
   AIni : TIniFile;
begin
     AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
     AIni.WriteInteger('Site Info Form','Top',Top);
     AIni.WriteInteger('Site Info Form','Left',Left);
     AIni.WriteInteger('Site Info Form','Width',Width);
     AIni.WriteInteger('Site Info Form','Height',Height);
     AIni.Free;
end;

procedure TDisplaySitesForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
     SavePositionSize;
end;

procedure TDisplaySitesForm.Matrix1Click(Sender: TObject);
var
   SitesChosen : Array_t;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
begin
     // clear all site selections in ControlForm
     ControlForm.AllClasses1Click(Sender);
     // get list of selected sites
     Selected2Arr(SitesChosen);
     // select list of selected sites in ControlForm
     // SitesChosen is destroyed by call to Arr2Highlight
     Arr2Highlight(SitesChosen,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);

     if (SitesChosen.lMaxSize > 0) then
     begin
          // Show Feature matrix Form
          ShowFeatureForm(NULL_SITE_GEOCODE);

          DisplayAllSites;
     end
     else
         MessageDlg('Select 1 or more sites to activate this function',mtInformation,[mbOk],0);
end;

procedure TDisplaySitesForm.LabelNeMa;
begin
     Ne1.Caption := ControlRes^.sR1Label;
     NegotiatedReserve1.Caption := ControlRes^.sR1Label;
     NegotiatedReserve2.Caption := ControlRes^.sR1Label;
     ReservedNRMR1.Caption := 'Selected not including Partial';
     ReservedNRMRPR1.Caption := 'Selected including Partial';
     NegotiatedReserve3.Caption := ControlRes^.sR1Label;
     NegotiatedReserve4.Caption := ControlRes^.sR1Label;
     ReservedNRMR2.Caption := 'Selected not including Partial';
     ReservedNRMRPR2.Caption := 'Selected including Partial';

     if ControlRes^.fR2Visible then
     begin
          Ma1.Caption := ControlRes^.sR2Label;
          MandatoryReserve1.Caption := ControlRes^.sR2Label;
          MandatoryReserve2.Caption := ControlRes^.sR2Label;
          MandatoryReserve3.Caption := ControlRes^.sR2Label;
          MandatoryReserve4.Caption := ControlRes^.sR2Label;
     end;
     Ma1.Visible := ControlRes^.fR2Visible;
     MandatoryReserve1.Visible := ControlRes^.fR2Visible;
     MandatoryReserve2.Visible := ControlRes^.fR2Visible;
     MandatoryReserve3.Visible := ControlRes^.fR2Visible;
     MandatoryReserve4.Visible := ControlRes^.fR2Visible;

     if ControlRes^.fR3Visible then
     begin
          a_R3.Caption := ControlRes^.sR3Label;
          b_R3.Caption := ControlRes^.sR3Label;
          c_R3.Caption := ControlRes^.sR3Label;
          d_R3.Caption := ControlRes^.sR3Label;
          e_R3.Caption := ControlRes^.sR3Label;
     end;
     a_R3.Visible := ControlRes^.fR3Visible;
     b_R3.Visible := ControlRes^.fR3Visible;
     c_R3.Visible := ControlRes^.fR3Visible;
     d_R3.Visible := ControlRes^.fR3Visible;
     e_R3.Visible := ControlRes^.fR3Visible;
     if ControlRes^.fR4Visible then
     begin
          a_R4.Caption := ControlRes^.sR4Label;
          b_R4.Caption := ControlRes^.sR4Label;
          c_R4.Caption := ControlRes^.sR4Label;
          d_R4.Caption := ControlRes^.sR4Label;
          e_R4.Caption := ControlRes^.sR4Label;
     end;
     a_R4.Visible := ControlRes^.fR4Visible;
     b_R4.Visible := ControlRes^.fR4Visible;
     c_R4.Visible := ControlRes^.fR4Visible;
     d_R4.Visible := ControlRes^.fR4Visible;
     e_R4.Visible := ControlRes^.fR4Visible;
     if ControlRes^.fR5Visible then
     begin
          a_R5.Caption := ControlRes^.sR5Label;
          b_R5.Caption := ControlRes^.sR5Label;
          c_R5.Caption := ControlRes^.sR5Label;
          d_R5.Caption := ControlRes^.sR5Label;
          e_R5.Caption := ControlRes^.sR5Label;
     end;
     a_R5.Visible := ControlRes^.fR5Visible;
     b_R5.Visible := ControlRes^.fR5Visible;
     c_R5.Visible := ControlRes^.fR5Visible;
     d_R5.Visible := ControlRes^.fR5Visible;
     e_R5.Visible := ControlRes^.fR5Visible;
end;

procedure TDisplaySitesForm.FormShow(Sender: TObject);
begin
     LabelNeMa;
end;

procedure TDisplaySitesForm.SortField1Click(Sender: TObject);
var
   iCount : integer;
begin
     Screen.Cursor := crHourglass;
     try
        SelectSiteSortFieldForm := TSelectSiteSortFieldForm.Create(Application);

        with SelectSiteSortFieldForm.VariableBox.Items do
        begin
             Clear;
             // add field names from grid
             for iCount := 0 to (SiteGrid.ColCount-1) do
                 Add(SiteGrid.Cells[iCount,0]);
        end;
        SelectSiteSortFieldForm.VariableBox.ItemIndex := 0;

        if (SelectSiteSortFieldForm.ShowModal = mrOk) then
        begin
             fSort := True;
             sSortField := SelectSiteSortFieldForm.VariableBox.Items.Strings[SelectSiteSortFieldForm.VariableBox.ItemIndex];
             iSortOrder := SelectSiteSortFieldForm.SortGroup.ItemIndex;
             // 0=desc,1=asce
        end
        else
        begin
             fSort := False;
             sSortField := '';
             iSortOrder := 0;
        end;

        SelectSiteSortFieldForm.Free;

        DisplayAllSites;
     except
     end;
     Screen.Cursor := crDefault;
end;

procedure TDisplaySitesForm.Openversion3XLOGfile1Click(Sender: TObject);
begin
     ControlForm.OpenLOGfilepreversion351Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.e_r3Click(Sender: TObject);
var
   SitesChosen : Array_t;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
begin
     ControlForm.AllClasses1Click(Sender);
     Selected2Arr(SitesChosen);
     Arr2Highlight(SitesChosen,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);
     with ControlForm do
     begin
          if (Available.SelCount > 0) then
                MoveGroup(Available,AvailableKey,
                          R3,R3Key,TRUE,True);
     end;
     ExecuteIrreplaceability(-1,False,False,True,True,'');
     DisplayAllSites;
end;

procedure TDisplaySitesForm.e_r4Click(Sender: TObject);
var
   SitesChosen : Array_t;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
begin
     ControlForm.AllClasses1Click(Sender);
     Selected2Arr(SitesChosen);
     Arr2Highlight(SitesChosen,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);
     with ControlForm do
     begin
          if (Available.SelCount > 0) then
                MoveGroup(Available,AvailableKey,
                          R4,R4Key,TRUE,True);
     end;
     ExecuteIrreplaceability(-1,False,False,True,True,'');
     DisplayAllSites;
end;

procedure TDisplaySitesForm.e_r5Click(Sender: TObject);
var
   SitesChosen : Array_t;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
begin
     ControlForm.AllClasses1Click(Sender);
     Selected2Arr(SitesChosen);
     Arr2Highlight(SitesChosen,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);
     with ControlForm do
     begin
          if (Available.SelCount > 0) then
                MoveGroup(Available,AvailableKey,
                          R5,R5Key,TRUE,True);
     end;
     ExecuteIrreplaceability(-1,False,False,True,True,'');
     DisplayAllSites;
end;

procedure TDisplaySitesForm.a_r3Click(Sender: TObject);
begin
     ControlForm.a_r3Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.a_r4Click(Sender: TObject);
begin
     ControlForm.a_r4Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.a_r5Click(Sender: TObject);
begin
     ControlForm.a_r5Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.b_r3Click(Sender: TObject);
begin
     ControlForm.b_r3Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.b_r4Click(Sender: TObject);
begin
     ControlForm.b_r4Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.b_r5Click(Sender: TObject);
begin
     ControlForm.b_r5Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.c_r3Click(Sender: TObject);
begin
     ControlForm.c_r3Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.c_r4Click(Sender: TObject);
begin
     ControlForm.c_r4Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.c_r5Click(Sender: TObject);
begin
     ControlForm.c_r5Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.d_r3Click(Sender: TObject);
begin
     ControlForm.d_r3Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.d_r4Click(Sender: TObject);
begin
     ControlForm.d_r4Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.d_r5Click(Sender: TObject);
begin
     ControlForm.d_r5Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.OpenSelectionsolderversions1Click(
  Sender: TObject);
begin
     ControlForm.OpenSelectionsolderversions1Click(Sender);
     DisplayAllSites;
end;

procedure TDisplaySitesForm.SelectRows1Click(Sender: TObject);
var
   iCount : integer;
begin
     ChooseSiteRowsForm := TChooseSiteRowsForm.Create(Application);
     // add visible fields to listbox for user to select from
     with ChooseSiteRowsForm.VariableBox.Items do
     begin
          Clear;
          for iCount := 1 to (SiteGrid.ColCount-1) do
              Add(SiteGrid.Cells[iCount,0]);
     end;
     ChooseSiteRowsForm.VariableBox.ItemIndex := 0;
     if (ChooseSiteRowsForm.ShowModal = mrOk)
     and (ChooseSiteRowsForm.ValueBox.Text <> '') then
     begin
          // user has selected a query, read it
          fQuery := TRUE;
          sQueryField := ChooseSiteRowsForm.VariableBox.Items[ChooseSiteRowsForm.VariableBox.ItemIndex];
          sQueryOperator := ChooseSiteRowsForm.OperatorGroup.Items[ChooseSiteRowsForm.OperatorGroup.ItemIndex];
          sQueryValue := ChooseSiteRowsForm.ValueBox.Text;
     end
     else
     begin
          // user has cancelled query, set it to ''
          fQuery := FALSE;
          sQueryField := '';
          sQueryOperator := '';
          sQueryValue := '';
     end;

     ChooseSiteRowsForm.Free;

     DisplayAllSites;
end;

procedure TDisplaySitesForm.MarxanPrototype1Click(Sender: TObject);
begin
     ControlForm.MarxanPrototype1Click(Sender);
end;

procedure TDisplaySitesForm.Options2Click(Sender: TObject);
begin
     if ControlRes^.fMarxanDatabaseExists then
     begin
          CopyFile(PChar('c:\marxan\inedit.exe'),PChar(ControlRes^.sMarxanDatabasePath + '\inedit.exe'),True);
          RunAnAppAnyPath(ControlRes^.sMarxanDatabasePath + '\inedit.exe','',ControlRes^.sMarxanDatabasePath);
     end;
end;

procedure TDisplaySitesForm.BuildDatabase1Click(Sender: TObject);
begin
     CreateMarxanDatabaseClick;
end;

procedure TDisplaySitesForm.DisplayMarxanSiteValues1Click(Sender: TObject);
begin
     // set marxan site fields to display

     // re-display site form
end;

end.
