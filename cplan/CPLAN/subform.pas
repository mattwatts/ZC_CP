unit subform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, Spin, ExtCtrls, Buttons, Menus;

type
  TSelectSubsetForm = class(TForm)
    Label1: TLabel;
    YesNoMutex: TRadioGroup;
    SpinSubset: TSpinEdit;
    AvailGrid: TStringGrid;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    btnResetFeatures: TButton;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    StringGrid3: TStringGrid;
    StringGrid4: TStringGrid;
    StringGrid5: TStringGrid;
    StringGrid6: TStringGrid;
    StringGrid7: TStringGrid;
    StringGrid8: TStringGrid;
    StringGrid9: TStringGrid;
    StringGrid10: TStringGrid;
    SelectFeatures: TSpeedButton;
    EditFeatureSubset: TEdit;
    DeSelectFeatures: TSpeedButton;
    DeSelectAllFeatures: TSpeedButton;
    MainMenu1: TMainMenu;
    EditScenarioName: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    File1: TMenuItem;
    LoadScenario1: TMenuItem;
    SaveScenario1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure YesNoMutexClick(Sender: TObject);
    procedure DisplaySubsetSelector;
    procedure btnResetFeaturesClick(Sender: TObject);
    procedure SelectFeaturesClick(Sender: TObject);
    procedure MoveSelectedFeatures(SourceGrid, DestinationGrid : TStringGrid);
    procedure MoveAllFeatures(SourceGrid, DestinationGrid : TStringGrid);
    procedure SpinSubsetChange(Sender: TObject);
    procedure DeSelectFeaturesClick(Sender: TObject);
    procedure DeSelectAllFeaturesClick(Sender: TObject);
    procedure LoadScenario;
    procedure SaveScenario;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SelectSubsetForm: TSelectSubsetForm;

implementation

uses
    Global, Control;

{$R *.DFM}

procedure TSelectSubsetForm.LoadScenario;
begin
     {load an existing scenario from the Feature Summary Table}
end;

procedure TSelectSubsetForm.SaveScenario;
begin
     {save selections on form to a scenario in the Feature Summary Table}
end;

procedure TSelectSubsetForm.MoveAllFeatures(SourceGrid,
                                            DestinationGrid : TStringGrid);
begin
     {}
     try
        {select all feature in SourceGrid}
        if (SourceGrid.RowCount > 1) then
           with SourceGrid.Selection do
           begin
                Left := 0;
                Right := 1;
                Top := 1;
                Bottom := SourceGrid.RowCount - 1;
           end;
        {call MoveSelectedFeatures}
        MoveSelectedFeatures(SourceGrid,DestinationGrid);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSelectSubsetForm.MoveAllFeatures',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSelectSubsetForm.MoveSelectedFeatures(SourceGrid,
                                                 DestinationGrid : TStringGrid);
var
   iCount, iDestinationLastExistingRow,
   iBottom, iTop, iEnd,
   iDestinationRow, iRowsToSelect : integer;
begin
     {}
     try
        if (SourceGrid.RowCount > 1) then
        begin
             {copy all the selected rows to the destination grid}
             iDestinationLastExistingRow := DestinationGrid.RowCount;
             DestinationGrid.RowCount := DestinationGrid.RowCount +
                                         1 +
                                         SourceGrid.Selection.Bottom -
                                         SourceGrid.Selection.Top;
             DestinationGrid.FixedRows := 1;
             for iCount := SourceGrid.Selection.Top to SourceGrid.Selection.Bottom do
             begin
                  iDestinationRow := iDestinationLastExistingRow + iCount - SourceGrid.Selection.Top;

                  DestinationGrid.Cells[0,iDestinationRow] := SourceGrid.Cells[0,iCount];
                  DestinationGrid.Cells[1,iDestinationRow] := SourceGrid.Cells[1,iCount];
             end;
             {if selection.bottom is not last row in source grid}
               {for each row in source grid from last to row after selection.bottom}
                 {copy contents of row to row above}
             iEnd := SourceGrid.RowCount-1;
             iBottom := SourceGrid.Selection.Bottom;
             iTop := SourceGrid.Selection.Top;
             if (iEnd <> iBottom) then
                for iCount := (iBottom+1) to iEnd do
                begin
                     SourceGrid.Cells[0,iCount-1] := SourceGrid.Cells[0,iCount];
                     SourceGrid.Cells[1,iCount-1] := SourceGrid.Cells[1,iCount];
                end;

             {remove iBottom-iTop+1 selected rows from the source grid}
             SourceGrid.FixedRows := 0;
             SourceGrid.RowCount := SourceGrid.RowCount - (iBottom-iTop+1);
             if (SourceGrid.RowCount > 1) then
                SourceGrid.FixedRows := 1;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSelectSubsetForm.MoveSelectedFeatures',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSelectSubsetForm.DisplaySubsetSelector;
begin
     {SpinSubset.Value in the number of the subset to select (1 to 10)}
     StringGrid1.Visible := False;
     StringGrid2.Visible := False;
     StringGrid3.Visible := False;
     StringGrid4.Visible := False;
     StringGrid5.Visible := False;
     StringGrid6.Visible := False;
     StringGrid7.Visible := False;
     StringGrid8.Visible := False;
     StringGrid9.Visible := False;
     StringGrid10.Visible := False;

     case SpinSubset.Value of
          1 :  StringGrid1.Visible := True;
          2 :  StringGrid2.Visible := True;
          3 :  StringGrid3.Visible := True;
          4 :  StringGrid4.Visible := True;
          5 :  StringGrid5.Visible := True;
          6 :  StringGrid6.Visible := True;
          7 :  StringGrid7.Visible := True;
          8 :  StringGrid8.Visible := True;
          9 :  StringGrid9.Visible := True;
          10 : StringGrid10.Visible := True;
     end;
end;

procedure TSelectSubsetForm.FormCreate(Sender: TObject);
var
   iCount : integer;
   pFeat : FeatureOccurrencePointer;

   procedure PrepareSubsetGrid(AGrid : TStringGrid);
   begin
        AGrid.RowCount := 2;
        AGrid.Cells[0,0] := 'Name';
        AGrid.Cells[1,0] := 'Vulnerability';
        AGrid.Visible := False;
   end;

begin
     try
        new(pFeat);

        AvailGrid.Cells[0,0] := 'Name';
        AvailGrid.Cells[1,0] := 'Vulnerability';
        AvailGrid.RowCount := iFeatureCount + 1;

        {populate AvailGrid with all available features}
        for iCount := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iCount,@pFeat);

             AvailGrid.Cells[0,iCount] := pFeat^.sId;
             AvailGrid.Cells[1,iCount] := '0';
        end;

        dispose(pFeat);

        PrepareSubsetGrid(StringGrid1);
        PrepareSubsetGrid(StringGrid2);
        PrepareSubsetGrid(StringGrid3);
        PrepareSubsetGrid(StringGrid4);
        PrepareSubsetGrid(StringGrid5);
        PrepareSubsetGrid(StringGrid6);
        PrepareSubsetGrid(StringGrid7);
        PrepareSubsetGrid(StringGrid8);
        PrepareSubsetGrid(StringGrid9);
        PrepareSubsetGrid(StringGrid10);

        StringGrid1.Visible := True;

        DisplaySubsetSelector;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSelectSubsetForm.FormCreate',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSelectSubsetForm.YesNoMutexClick(Sender: TObject);
begin
     if (YesNoMutex.ItemIndex = 0) then
     begin
          SpinSubset.MinValue := 6;
          SpinSubset.MaxValue := 10;
          SpinSubset.Value := 6;
     end
     else
     begin
          SpinSubset.MinValue := 1;
          SpinSubset.MaxValue := 5;
          SpinSubset.Value := 1;
     end;

     DisplaySubsetSelector;
end;

procedure TSelectSubsetForm.btnResetFeaturesClick(Sender: TObject);
begin
     FormCreate(self);
end;

procedure TSelectSubsetForm.SelectFeaturesClick(Sender: TObject);
begin
     {select any highlighted features from Available Features to
      Feature Subset indicated by SpinSubset.Value}
     case SpinSubset.Value of
          1 : MoveSelectedFeatures(AvailGrid,StringGrid1);
          2 : MoveSelectedFeatures(AvailGrid,StringGrid2);
          3 : MoveSelectedFeatures(AvailGrid,StringGrid3);
          4 : MoveSelectedFeatures(AvailGrid,StringGrid4);
          5 : MoveSelectedFeatures(AvailGrid,StringGrid5);
          6 : MoveSelectedFeatures(AvailGrid,StringGrid6);
          7 : MoveSelectedFeatures(AvailGrid,StringGrid7);
          8 : MoveSelectedFeatures(AvailGrid,StringGrid8);
          9 : MoveSelectedFeatures(AvailGrid,StringGrid9);
          10 : MoveSelectedFeatures(AvailGrid,StringGrid10);
     end;
end;

procedure TSelectSubsetForm.SpinSubsetChange(Sender: TObject);
begin
     DisplaySubsetSelector;
end;

procedure TSelectSubsetForm.DeSelectFeaturesClick(Sender: TObject);
begin
     case SpinSubset.Value of
          1 : MoveSelectedFeatures(StringGrid1,AvailGrid);
          2 : MoveSelectedFeatures(StringGrid2,AvailGrid);
          3 : MoveSelectedFeatures(StringGrid3,AvailGrid);
          4 : MoveSelectedFeatures(StringGrid4,AvailGrid);
          5 : MoveSelectedFeatures(StringGrid5,AvailGrid);
          6 : MoveSelectedFeatures(StringGrid6,AvailGrid);
          7 : MoveSelectedFeatures(StringGrid7,AvailGrid);
          8 : MoveSelectedFeatures(StringGrid8,AvailGrid);
          9 : MoveSelectedFeatures(StringGrid9,AvailGrid);
          10 : MoveSelectedFeatures(StringGrid10,AvailGrid);
     end;    
end;

procedure TSelectSubsetForm.DeSelectAllFeaturesClick(Sender: TObject);
begin
     case SpinSubset.Value of
          1 : MoveAllFeatures(StringGrid1,AvailGrid);
          2 : MoveAllFeatures(StringGrid2,AvailGrid);
          3 : MoveAllFeatures(StringGrid3,AvailGrid);
          4 : MoveAllFeatures(StringGrid4,AvailGrid);
          5 : MoveAllFeatures(StringGrid5,AvailGrid);
          6 : MoveAllFeatures(StringGrid6,AvailGrid);
          7 : MoveAllFeatures(StringGrid7,AvailGrid);
          8 : MoveAllFeatures(StringGrid8,AvailGrid);
          9 : MoveAllFeatures(StringGrid9,AvailGrid);
          10 : MoveAllFeatures(StringGrid10,AvailGrid);
     end;
end;

end.
