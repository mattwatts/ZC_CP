unit summarise_sites;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids;

type
  TSummariseSitesForm = class(TForm)
    aGrid: TStringGrid;
    Panel1: TPanel;
    btnFinish: TButton;
    Label1: TLabel;
    btnSave: TButton;
    SaveDialog1: TSaveDialog;
    procedure btnFinishClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SummariseSitesForm: TSummariseSitesForm;

implementation

uses
    ds, global, control, Featgrid, opt1, dbmisc;

{$R *.DFM}

procedure TSummariseSitesForm.btnFinishClick(Sender: TObject);
begin
     ModalResult := mrOk;
end;

procedure TSummariseSitesForm.FormActivate(Sender: TObject);
var
   AvFeatureAmount, PreFeatureAmount, PropFeatureAmount : Array_t;
   rAvAmount, rPreAmount, rPropAmount : extended;
   iCount, iSite, iFeatures, iRow : integer;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   Value : ValueFile_T;
   sTmp : string;
begin
     // parse sites in Featgrid
     // summarise all features for the sites
     // display info in grid for features at the sites

     // the 4 fields are feature,irr,amount,%totgt
     // we only need to remember cumulative amount (amounts greater than 0 mean feature occurs in the group of sites)
     // irr is not meaningful, so will not be displayed
     // %totgt will be calculated from amount during display

     // init temporary variables
     new(pSite);
     new(pFeat);
     //AvFeatureAmount, OtherFeatureAmount
     AvFeatureAmount := Array_t.Create;
     AvFeatureAmount.init(SizeOf(extended),iFeatureCount);
     PreFeatureAmount := Array_t.Create;
     PreFeatureAmount.init(SizeOf(extended),iFeatureCount);
     PropFeatureAmount := Array_t.Create;
     PropFeatureAmount.init(SizeOf(extended),iFeatureCount);
     rAvAmount := 0;
     rPreAmount := 0;
     rPropAmount := 0;
     for iCount := 1 to iFeatureCount do
     begin
          AvFeatureAmount.setValue(iCount,@rAvAmount);
          PreFeatureAmount.setValue(iCount,@rPreAmount);
          PropFeatureAmount.setValue(iCount,@rPropAmount);
     end;

     // traverse the selected sites
     // distinguish between available and not available
     for iSite := 1 to FeatGridForm.SitesToDisplay.Items.Count do
     begin
          //iSiteIndex := FindSite(StrToInt(FeatGridForm.SitesToDisplayKey.Items.Strings[iSite-1]));
          SiteArr.rtnValue(FindFeatMatch(OrdSiteArr,StrToInt(FeatGridForm.SitesToDisplayKey.Items.Strings[iSite-1])),pSite);
          // traverse each feature at the site
          if (pSite^.richness > 0) then
             for iCount := 1 to pSite^.richness do
             begin
                  FeatureAmount.rtnValue(pSite^.iOffset + iCount,@Value);

                  if (pSite^.status = _R1)
                  or (pSite^.status = _R2)
                  or (pSite^.status = _R3)
                  or (pSite^.status = _R4)
                  or (pSite^.status = _R5)
                  or (pSite^.status = Pd) then
                  begin // proposed reserve
                       PropFeatureAmount.rtnValue(Value.iFeatKey,@rPropAmount);
                       rPropAmount := rPropAmount + Value.rAmount;
                       PropFeatureAmount.setValue(Value.iFeatKey,@rPropAmount);
                  end
                  else
                  begin
                       if (pSite^.status = Re) then
                       begin // pre-existing reserve
                            PreFeatureAmount.rtnValue(Value.iFeatKey,@rPreAmount);
                            rPreAmount := rPreAmount + Value.rAmount;
                            PreFeatureAmount.setValue(Value.iFeatKey,@rPreAmount);
                       end
                       else
                       begin // available
                            AvFeatureAmount.rtnValue(Value.iFeatKey,@rAvAmount);
                            rAvAmount := rAvAmount + Value.rAmount;
                            AvFeatureAmount.setValue(Value.iFeatKey,@rAvAmount);
                       end;
                  end;
             end;
     end;

     // count how many featues
     iFeatures := 0;
     for iCount := 1 to iFeatureCount do
     begin
          AvFeatureAmount.rtnValue(iCount,@rAvAmount);
          PreFeatureAmount.rtnValue(iCount,@rPreAmount);
          PropFeatureAmount.rtnValue(iCount,@rPropAmount);
          if (rAvAmount > 0)
          or (rPreAmount > 0)
          or (rPropAmount > 0) then
             Inc(iFeatures);
     end;

     // display features in the grid
     aGrid.RowCount := iFeatures + 1;
     aGrid.ColCount := 5;
     aGrid.Cells[0,0] := 'Feature';
     aGrid.Cells[1,0] := 'Available';
     aGrid.Cells[2,0] := 'Reserved';
     aGrid.Cells[3,0] := 'Total';
     aGrid.Cells[4,0] := '% of Avail. Target';
     iRow := 0;
     for iCount := 1 to iFeatureCount do
     begin
          AvFeatureAmount.rtnValue(iCount,@rAvAmount);
          PreFeatureAmount.rtnValue(iCount,@rPreAmount);
          PropFeatureAmount.rtnValue(iCount,@rPropAmount);

          if (rAvAmount > 0)
          or (rPreAmount > 0)
          or (rPropAmount > 0) then
          begin
               Inc(iRow);
               FeatArr.rtnValue(iCount,pFeat);

               // Feature
               aGrid.Cells[0,iRow] := pFeat^.sId;
               // Available
               if (rAvAmount > 0) then
                  Str(rAvAmount:6:2,sTmp)
               else
                   sTmp := '0';
               TrimLeadSpaces(sTmp);
               aGrid.Cells[1,iRow] := sTmp;
               // Reserved
               if ((rPreAmount + rPropAmount) > 0) then
                  Str((rPreAmount + rPropAmount):6:2,sTmp)
               else
                   sTmp := '0';
               TrimLeadSpaces(sTmp);
               aGrid.Cells[2,iRow] := sTmp;
               // Total
               if ((rAvAmount + rPreAmount + rPropAmount) > 0) then
                  Str((rAvAmount + rPreAmount + rPropAmount):6:2,sTmp)
               else
                   sTmp := '0';
               TrimLeadSpaces(sTmp);
               aGrid.Cells[3,iRow] := sTmp;
               // % of Avail. Target
               if ((pFeat^.targetarea + rPropAmount) > 0) then
                  Str((rAvAmount + rPropAmount)/(pFeat^.targetarea + rPropAmount)*100:6:2,sTmp)
               else
                   sTmp := '0';
               TrimLeadSpaces(sTmp);
               if (sTmp = '0.00') then
                  sTmp := '0';
               aGrid.Cells[4,iRow] := sTmp;
          end;
     end;

     dispose(pSite);
     dispose(pFeat);
     AvFeatureAmount.Destroy;
     PreFeatureAmount.Destroy;
     PropFeatureAmount.Destroy;

     with aGrid do
     begin
          DefaultColWidth := (ClientWidth -
                              ((ColCount+1) * GridLineWidth))
                             div ColCount;

          if DefaultColWidth < MIN_GRID_WIDTH then
             DefaultColWidth := MIN_GRID_WIDTH;
     end;

     SaveDialog1.InitialDir := ControlRes^.sWorkingDirectory;
end;


procedure TSummariseSitesForm.btnSaveClick(Sender: TObject);
begin
     if SaveDialog1.Execute then
        SaveStringGrid2CSV(aGrid,SaveDialog1.Filename);
end;

end.
