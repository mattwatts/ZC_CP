unit displayfeatures;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, Grids, ExtCtrls, StdCtrls;

type
  TDisplayFeaturesForm = class(TForm)
    Panel1: TPanel;
    FeatGrid: TStringGrid;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Save1: TMenuItem;
    Exit1: TMenuItem;
    Table1: TMenuItem;
    Copy1: TMenuItem;
    AutoFit1: TMenuItem;
    Select1: TMenuItem;
    SelectDeSelectAll1: TMenuItem;
    InvertSelection1: TMenuItem;
    Lookup1: TMenuItem;
    Sites1: TMenuItem;
    FeaturesInUse1: TMenuItem;
    DisplayFields: TListBox;
    SaveCSV: TSaveDialog;
    Features1: TMenuItem;
    EditTargets1: TMenuItem;
    ToggleITARGETPCTARGET1: TMenuItem;
    ApplySubsetClassification1: TMenuItem;
    DisplayFields1: TMenuItem;
    N1: TMenuItem;
    Exit2: TMenuItem;
    N2: TMenuItem;
    DisplayRows1: TMenuItem;
    SortField1: TMenuItem;
    lblStatus: TLabel;
    Appearance1: TMenuItem;
    FeaturesToTarget1: TMenuItem;
    AvailableSites1: TMenuItem;
    ReservedSites1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure DisplayAllFeatures;
    procedure LoadDisplayFields;
    procedure LabelDisplayFields;
    procedure InitAllFeatures;
    procedure Save1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure AutoFit1Click(Sender: TObject);
    procedure SelectDeSelectAll1Click(Sender: TObject);
    procedure InvertSelection1Click(Sender: TObject);
    procedure Sites1Click(Sender: TObject);
    procedure FeaturesInUse1Click(Sender: TObject);
    procedure FeatGridSelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    procedure EditTargets1Click(Sender: TObject);
    procedure ToggleITARGETPCTARGET1Click(Sender: TObject);
    procedure ApplySubsetClassification1Click(Sender: TObject);
    procedure DisplayFields1Click(Sender: TObject);
    procedure Exit2Click(Sender: TObject);
    procedure LoadPositionSize;
    procedure SavePositionSize;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DisplayRows1Click(Sender: TObject);
    procedure SortField1Click(Sender: TObject);
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
  DisplayFeaturesForm: TDisplayFeaturesForm;

implementation

uses
    global, inifiles, control, featgrid, lookup, auto_fit, featlookupfields,
    ChooseFeatureRows, SelectFeatureSortField, partl_ed,
    marxan;

{$R *.DFM}

function rtnFieldType(const sField : string) : integer;
var
   iCount : integer;
begin
     // 0=str, 1=number
     Result := 1;
     if (UpperCase(sField) = 'FEATNAME')
     or (UpperCase(sField) = 'IN USE')
     or (UpperCase(sField) = 'EXCLUDE TRIM') then
        Result := 0;

     if ControlRes^.fMarxanDatabaseExists
     and fMarxanResultCreated then
     begin
         if (UpperCase(sField) = 'MARXANBESTTARGETMET') then
            Result := 0;

          for iCount := 1 to iMarxanScenarios do
          begin
               if (UpperCase(sField) = 'MARXANTARGETMET' + IntToStr(iCount)) then
                  Result := 0;
          end;
     end;
end;

function rtnFeatureValue(const pFeat : featureoccurrencepointer;
                         const sField : string) : string;
begin
     Result := '';
{'FEATKEY'
'FEATNAME'
'IN USE'
'SUBSET'
'SRADIUS'
'PATCHCON'
'VULN'
'EXTANT'
'NEGOTIATED'
'MANDATORY'
'PARTIAL'
'CURRENT TARGET'
'% ORIGINAL EFFECTIVE TARGET'
'ITARGET'
'AVAILABLE'
'EXCLUDED'
'INITIAL TRIMMED TARGET'
'TRIMMED TARGET'
'INITIAL AVAILABLE'
'INITIAL AVAILABLE TARGET'
'DEFERRED'
'TOTAL'
'INITIAL RESERVED'
'TOTAL RESERVED'}
     if (sField = 'FEATKEY') then
        Result := IntToStr(pFeat^.code)
     else
     if (sField = 'FEATNAME') then
        Result := pFeat^.sID
     else
     if (sField = 'IN USE') then
        Result := bool2string(not pFeat^.fRestrict)
     else
     if (sField = 'SUBSET') then
        Result := IntToStr(pFeat^.iOrdinalClass)
     else
     if (sField = 'SRADIUS') then
        Result := FloatToStr(pFeat^.rSRADIUS)
     else
     if (sField = 'PATCHCON') then
        Result := FloatToStr(pFeat^.rPATCHCON)
     else
     if (sField = 'VULN') then
        Result := FloatToStr(pFeat^.rVulnerability)
     else
     if (sField = 'EXTANT') then
        Result := FloatToStr(pFeat^.rExtantArea)
     else
     if (sField = 'NEGOTIATED')
     or (sField = ControlRes^.sR1Label) then
        Result := FloatToStr(pFeat^.rR1)
     else
     if (sField = 'MANDATORY')
     or (sField = ControlRes^.sR2Label) then
        Result := FloatToStr(pFeat^.rR2)
     else
     if (sField = ControlRes^.sR3Label) then
        Result := FloatToStr(pFeat^.rR3)
     else
     if (sField = ControlRes^.sR4Label) then
        Result := FloatToStr(pFeat^.rR4)
     else
     if (sField = ControlRes^.sR5Label) then
        Result := FloatToStr(pFeat^.rR5)
     else
     if (sField = 'PARTIAL') then
        Result := FloatToStr(pFeat^.rPartial)
     else
     if (sField = 'CURRENT TARGET') then
        Result := FloatToStr(pFeat^.targetarea)
     else
     if (sField = '% ORIGINAL EFFECTIVE TARGET') then
        Result := FloatToStr(pFeat^.rCurrentEffTarg)
     else
     if (sField = 'ITARGET') then
        Result := FloatToStr(pFeat^.rCutOff)
     else
     if (sField = 'AVAILABLE') then
        Result := FloatToStr(pFeat^.rSumArea)
     else
     if (sField = 'EXCLUDED') then
        Result := FloatToStr(pFeat^.rExcluded)
     else
     if (sField = 'INITIAL TRIMMED TARGET') then
        Result := FloatToStr(pFeat^.rInitialTrimmedTarget)
     else
     if (sField = 'TRIMMED TARGET') then
        Result := FloatToStr(pFeat^.rTrimmedTarget)
     else
     if (sField = 'INITIAL AVAILABLE') then
        Result := FloatToStr(pFeat^.rInitialAvailable)
     else
     if (sField = 'INITIAL AVAILABLE TARGET') then
        Result := FloatToStr(pFeat^.rInitialAvailableTarget)
     else
     if (sField = 'DEFERRED') then
        Result := FloatToStr(pFeat^.rDeferredArea)
     else
     if (sField = 'TOTAL') then
        Result := FloatToStr(pFeat^.totalarea)
     else
     if (sField = 'INITIAL RESERVED') then
        Result := FloatToStr(pFeat^.reservedarea)
     else
     if (sField = 'TOTAL RESERVED') then
        Result := FloatToStr(pFeat^.reservedarea + pFeat^.rDeferredArea)
     else
     if (sField = 'EXCLUDE TRIM') then
     begin
          if (pFeat^.rTrimmedArea > 0) then
             Result := 'YES'
          else
              Result := '';
     end
     else
     if (sField = 'EXCLUDE TRIM AMOUNT') then
        Result := FloatToStr(pFeat^.rTrimmedArea)
     else
     if (sField = 'EXCLUDE TRIM %') then
     begin
          if ((pFeat^.rInitialTrimmedTarget) > 0) then
             Result := FloatToStr(pFeat^.rTrimmedArea/(pFeat^.rInitialTrimmedTarget)*100)
          else
              Result := '0';
     end;
end;

procedure TDisplayFeaturesForm.DisplayAllFeatures;
var
   iCount, iField, iFeatureRows, iQueryFieldType, iSortFieldType, iSortField : integer;
   pFeat : featureoccurrencepointer;
   sTmp : string;
   fInclude : boolean;
   wSortType, wSortDirection : word;

   function EvaluateQuery : boolean;
   var
      sValue : string;
   begin
        Result := True;
        sValue := rtnFeatureValue(pFeat,sQueryField);
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
        new(pFeat);

        if (fQuery) then
           iQueryFieldType := rtnFieldType(sQueryField);
        if (fSort) then
           iSortFieldType := rtnFieldType(sSortField);


        // set number of rows in the grid
        FeatGrid.RowCount := iFeatureCount + 1;
        iFeatureRows := 0;
        for iCount := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iCount,pFeat);

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
                  Inc(iFeatureRows);
                  FeatGrid.Cells[0,iFeatureRows] := '';

                  for iField := 1 to DisplayFields.Items.Count do
                      FeatGrid.Cells[iField,iFeatureRows] := rtnFeatureValue(pFeat,DisplayFields.Items.Strings[iField-1]);
             end;
        end;

        dispose(pFeat);

        if (FeatGrid.RowCount > iFeatureRows+1) then
           FeatGrid.RowCount := iFeatureRows+1;

        AutoFit1Click(Self);

        if fSort then
        begin
             wSortDirection := iSortOrder;

             iSortField := 0;
             for iCount := 0 to (FeatGrid.ColCount - 1) do
                 if (sSortField = FeatGrid.Cells[iCount,0]) then
                    iSortField := iCount;

             case iSortFieldType of
                  0 : wSortType := SORT_TYPE_STRING;
                  1 : wSortType := SORT_TYPE_REAL;
             end;

             SortGrid(FeatGrid,1,iSortField,wSortType,wSortDirection);
        end;


        lblStatus.Caption := IntToStr(iFeatureRows) + ' features   ';
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

procedure TDisplayFeaturesForm.LoadDisplayFields;
var
   AIni : TIniFile;
begin
     // load display field names from the ini file
     AIni := TIniFile.Create(ControlRes^.sDatabase + '\cplan.ini');
     DisplayFields.Items.Clear;
     AIni.ReadSection('Feature Info Fields',DisplayFields.Items);
     AIni.Free;

     // use default field names if none present
     if (DisplayFields.Items.Count = 0) then
     begin
          DisplayFields.Items.Add('FEATKEY');
          DisplayFields.Items.Add('FEATNAME');
          DisplayFields.Items.Add('IN USE');
     end;
     // add FEATKEY if it is not already present, because this is the feature identifier
     if (DisplayFields.Items.IndexOf('FEATKEY') = -1) then
        DisplayFields.Items.Insert(0,'FEATKEY');
end;

procedure TDisplayFeaturesForm.LabelDisplayFields;
var
   iCount : integer;
begin
     // set number of columns and label columns
     FeatGrid.ColCount := DisplayFields.Items.Count + 1;
     FeatGrid.Cells[0,0] := 'Select';
     for iCount := 1 to DisplayFields.Items.Count do
         FeatGrid.Cells[iCount,0] := DisplayFields.Items.Strings[iCount-1];
end;

procedure TDisplayFeaturesForm.InitAllFeatures;
begin
     // load display field names from the ini file
     LoadDisplayFields;
     LabelDisplayFields;
     // display fields for all features
     DisplayAllFeatures;
end;

procedure TDisplayFeaturesForm.FormCreate(Sender: TObject);
begin
     fQuery := False;
     fSort := False;
     sQueryField := '';
     sQueryOperator := '';
     sQueryValue := '';
     sSortField := '';
     iSortOrder := 0;

     //LoadPositionSize;
     if ControlForm.UseFeatCutOffs.Checked then
        ToggleITARGETPCTARGET1.Caption := 'User Defined target'
     else
         ToggleITARGETPCTARGET1.Caption := 'Percentage Target';
     InitAllFeatures;
end;

procedure TDisplayFeaturesForm.Save1Click(Sender: TObject);
begin
     SaveCSV.InitialDir := ControlRes^.sWorkingDirectory;
     SaveCSV.FileName := 'featureinfo.csv';

     if SaveCSV.Execute then
     begin
          if FileExists(SaveCSV.Filename) then
          begin
               if (mrYes = MessageDlg('File ' + SaveCSV.Filename + ' exists.  Overwrite?',
                                      mtConfirmation,[mbYes,mbNo],0)) then
                  SaveStringGrid2CSV(FeatGrid,SaveCSV.Filename);
          end
          else
              SaveStringGrid2CSV(FeatGrid,SaveCSV.Filename);
     end;
end;

procedure TDisplayFeaturesForm.Exit1Click(Sender: TObject);
begin
     ModalResult := mrOK;
end;

procedure TDisplayFeaturesForm.Copy1Click(Sender: TObject);
begin
     CopyGridSelectionToClipboard(FeatGrid);
end;

procedure TDisplayFeaturesForm.AutoFit1Click(Sender: TObject);
begin
     AutoFitGrid(FeatGrid,
                 Canvas,
                 True {fit entire grid});
end;

procedure TDisplayFeaturesForm.SelectDeSelectAll1Click(Sender: TObject);
var
   iCount : integer;
   sCell : string;
begin
     if (FeatGrid.Cells[0,1] = '') then
        sCell := 'Select'
     else
         sCell := '';

     for iCount := 1 to (FeatGrid.RowCount-1) do
         FeatGrid.Cells[0,iCount] := sCell;
end;

procedure TDisplayFeaturesForm.InvertSelection1Click(Sender: TObject);
var
   iCount : integer;
begin
     for iCount := 1 to (FeatGrid.RowCount-1) do
         if (FeatGrid.Cells[0,iCount] = '') then
            FeatGrid.Cells[0,iCount] := 'Select'
         else
             FeatGrid.Cells[0,iCount] := '';
end;

procedure TDisplayFeaturesForm.Sites1Click(Sender: TObject);
begin
     // close the display sites form
     ModalResult := mrOk;
     // display the display featues form
     ControlForm.SiteInfo1Click(Sender);
end;

procedure TDisplayFeaturesForm.FeaturesInUse1Click(Sender: TObject);
begin
     // bring up features in use form
     ControlForm.RestrictTargets1Click(Sender);
     // refresh features form
     DisplayAllFeatures;
end;

procedure TDisplayFeaturesForm.FeatGridSelectCell(Sender: TObject; Col,
  Row: Integer; var CanSelect: Boolean);
begin
     if (Col = 0)
     and (Row > 0) then
         if (FeatGrid.Cells[Col,Row] = '') then
            FeatGrid.Cells[Col,Row] := 'Select'
         else
             FeatGrid.Cells[Col,Row] := '';
end;

procedure TDisplayFeaturesForm.EditTargets1Click(Sender: TObject);
begin
     ControlForm.EditTargets1Click(Sender);
     // refresh features form
     DisplayAllFeatures;
end;

procedure TDisplayFeaturesForm.ToggleITARGETPCTARGET1Click(
  Sender: TObject);
begin
     ControlForm.UseFeatCutOffsClick(Sender);
     // refresh features form
     DisplayAllFeatures;

     if ControlForm.UseFeatCutOffs.Checked then
        ToggleITARGETPCTARGET1.Caption := 'User Defined target'
     else
         ToggleITARGETPCTARGET1.Caption := 'Percentage Target';
end;

procedure TDisplayFeaturesForm.ApplySubsetClassification1Click(
  Sender: TObject);
begin
     ControlForm.ApplyFeatureClasses1Click(Sender);
     DisplayAllFeatures;
end;

procedure TDisplayFeaturesForm.DisplayFields1Click(Sender: TObject);
begin
     SelectFieldsForm := TSelectFieldsForm.Create(Application);
     SelectFieldsForm.ShowModal;
     SelectFieldsForm.Free;

     // load the new fields and display them
     InitAllFeatures;
end;

procedure TDisplayFeaturesForm.Exit2Click(Sender: TObject);
begin
     ModalResult := mrOK;
     ControlForm.Exit1Click(Sender);
end;

procedure TDisplayFeaturesForm.LoadPositionSize;
var
   AIni : TIniFile;
   iTop, iLeft, iWidth, iHeight : integer;
begin
     AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
     iTop := AIni.ReadInteger('Feature Info Form','Top',0);
     iLeft := AIni.ReadInteger('Feature Info Form','Left',0);
     iWidth := AIni.ReadInteger('Feature Info Form','Width',0);
     iHeight := AIni.ReadInteger('Feature Info Form','Height',0);

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

procedure TDisplayFeaturesForm.SavePositionSize;
var
   AIni : TIniFile;
begin
     AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
     AIni.WriteInteger('Feature Info Form','Top',Top);
     AIni.WriteInteger('Feature Info Form','Left',Left);
     AIni.WriteInteger('Feature Info Form','Width',Width);
     AIni.WriteInteger('Feature Info Form','Height',Height);
     AIni.Free;
end;

procedure TDisplayFeaturesForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
     SavePositionSize;
end;

procedure TDisplayFeaturesForm.DisplayRows1Click(Sender: TObject);
var
   iCount : integer;
begin
     ChooseFeatureRowsForm := TChooseFeatureRowsForm.Create(Application);
     with ChooseFeatureRowsForm.VariableBox.Items do
     begin
          Clear;
          for iCount := 1 to (FeatGrid.ColCount-1) do
              Add(FeatGrid.Cells[iCount,0]);
     end;
     ChooseFeatureRowsForm.VariableBox.ItemIndex := 0;
     if (ChooseFeatureRowsForm.ShowModal = mrOk)
     and (ChooseFeatureRowsForm.ValueBox.Text <> '') then
     begin
          // user has selected a query, read it
          fQuery := TRUE;
          sQueryField := ChooseFeatureRowsForm.VariableBox.Items[ChooseFeatureRowsForm.VariableBox.ItemIndex];
          sQueryOperator := ChooseFeatureRowsForm.OperatorGroup.Items[ChooseFeatureRowsForm.OperatorGroup.ItemIndex];
          sQueryValue := ChooseFeatureRowsForm.ValueBox.Text;
     end
     else
     begin
          // user has cancelled query, set it to ''
          fQuery := FALSE;
          sQueryField := '';
          sQueryOperator := '';
          sQueryValue := '';
     end;

     ChooseFeatureRowsForm.Free;

     DisplayAllFeatures;
end;

procedure TDisplayFeaturesForm.SortField1Click(Sender: TObject);
var
   iCount : integer;
begin
     Screen.Cursor := crHourglass;
     try
        SelectFeatureSortFieldForm := TSelectFeatureSortFieldForm.Create(Application);

        with SelectFeatureSortFieldForm.VariableBox.Items do
        begin
             Clear;
             // add field names from grid
             for iCount := 0 to (FeatGrid.ColCount-1) do
                 Add(FeatGrid.Cells[iCount,0]);
        end;
        SelectFeatureSortFieldForm.VariableBox.ItemIndex := 0;

        if (SelectFeatureSortFieldForm.ShowModal = mrOk) then
        begin
             fSort := True;
             sSortField := SelectFeatureSortFieldForm.VariableBox.Items.Strings[SelectFeatureSortFieldForm.VariableBox.ItemIndex];
             iSortOrder := SelectFeatureSortFieldForm.SortGroup.ItemIndex;
             // 0=desc,1=asce
        end
        else
        begin
             fSort := False;
             sSortField := '';
             iSortOrder := 0;
        end;

        SelectFeatureSortFieldForm.Free;

        DisplayAllFeatures;
     except
     end;
     Screen.Cursor := crDefault;
end;


end.
