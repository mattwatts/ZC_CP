unit map_legend;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Buttons, StdCtrls, Grids, ExtCtrls, ColorGrd,
  GIS, Db, DBTables;

type
  TMapLegendForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    ColorGrid1: TColorGrid;
    Label1: TLabel;
    ComboDisplayField: TComboBox;
    Label2: TLabel;
    EditIntervalCount: TEdit;
    RadioLegendType: TRadioGroup;
    ColorGrid2: TColorGrid;
    StringGridValues: TDrawGrid;
    btnDeleteInterval: TButton;
    btnAddInterval: TButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Table1: TTable;
    ListBoxValues: TListBox;
    ColorDialog1: TColorDialog;
    btnCustomColour: TButton;
    CustomPanel1: TPanel;
    procedure BitBtn1Click(Sender: TObject);
    procedure RadioColourTypeClick(Sender: TObject);
    procedure ReadShapeFieldNames;
    procedure ReadShapeFieldValues;
    procedure StringGridValuesDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure ComboDisplayFieldChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ReadShapeFieldMinMax;
    procedure EditIntervalCountChange(Sender: TObject);
    procedure btnDeleteIntervalClick(Sender: TObject);
    procedure btnCustomColourClick(Sender: TObject);
    procedure ColorGrid1Change(Sender: TObject);
    procedure CustomPanel1Click(Sender: TObject);
    procedure ColorGrid1Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    iMapLayer : integer;
    sMapLayer : string;
    rMinValue, rMaxValue : extended;
    fFieldNotNumber : boolean;
    Active_GIS_Child : TGIS_Child;
  end;

var
  MapLegendForm: TMapLegendForm;

implementation

uses
    Miscellaneous, SCP_Main;

{$R *.DFM}
procedure TMapLegendForm.BitBtn1Click(Sender: TObject);
var
   AColour : TColor;
begin
     if (PageControl1.ActivePage = TabSheet1) then
     begin
          if ColorGrid1.ForegroundEnabled then
             //AColour := IndexToColour(MapLegendForm.ColorGrid1.ForegroundIndex)
             AColour := MapLegendForm.ColorGrid1.ForegroundColor
          else
              AColour := CustomPanel1.Color;

          Active_GIS_Child.Map1.ShapeLayerFillColor[iMapLayer] := AColour;
          if not SCPForm.ShapeOutlines1.Checked then
             Active_GIS_Child.Map1.ShapeLayerLineColor[iMapLayer] := Active_GIS_Child.Map1.ShapeLayerFillColor[iMapLayer]
          else
              Active_GIS_Child.Map1.ShapeLayerLineColor[iMapLayer] := clBlack;
     end;
end;

procedure TMapLegendForm.ReadShapeFieldNames;
var
   iCount : integer;
begin
     try
        ComboDisplayField.Items.Clear;

        Table1.DatabaseName := ExtractFilePath(sMapLayer);
        Table1.TableName := Copy(ExtractFileName(sMapLayer),1,Length(ExtractFileName(sMapLayer)) - Length(ExtractFileExt(ExtractFileName(sMapLayer)))) + '.dbf';

        Table1.Open;
        // read the fields from the table
        for iCount := 0 to (Table1.FieldCount - 1) do
             ComboDisplayField.Items.Add(Table1.FieldDefs.Items[iCount].Name);
        ComboDisplayField.ItemIndex := 0;

        Table1.Close;

     except
           MessageDlg('Exception in TMapLegendForm.ReadShapeFieldNames',mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMapLegendForm.ReadShapeFieldValues;
var
   sFieldName, sValue : string;
   iCount : integer;
begin
     try
        ListBoxValues.Items.Clear;

        Table1.Open;

        ListBoxValues.Sorted := True;

        sFieldName := ComboDisplayField.Text;

        ListBoxValues.Items.Add(Table1.FieldByName(sFieldName).AsString);
        while not Table1.Eof do
        begin
             Table1.Next;
             sValue := Table1.FieldByName(sFieldName).AsString;
             if (sValue <> '') then
                if (ListBoxValues.Items.IndexOf(sValue) = -1) then
                   ListBoxValues.Items.Add(sValue);
        end;

        Table1.Close;

        StringGridValues.RowCount := ListBoxValues.Items.Count;
        StringGridValues.Repaint;

     except
           MessageDlg('Exception in UpdateValueList',mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMapLegendForm.ReadShapeFieldMinMax;
var
   sFieldName, sValue : string;
   iCount, iIntervals : integer;
   rValue : extended;
begin
     try
        Table1.Open;

        sFieldName := ComboDisplayField.Text;

        rMinValue := 1000000;
        rMaxValue := -1000000;

        sValue := Table1.FieldByName(sFieldName).AsString;
        try
           rValue := StrToFloat(sValue);
           fFieldNotNumber := False;
        except
              fFieldNotNumber := True;
        end;

        while not Table1.Eof do
        begin
             Table1.Next;

             if (not fFieldNotNumber) then
             begin
                  sValue := Table1.FieldByName(sFieldName).AsString;
                  try
                     rValue := StrToFloat(sValue);
                     fFieldNotNumber := False;

                     if (rValue < rMinValue) then
                        rValue := rMinValue;
                     if (rValue > rMaxValue) then
                        rValue := rMaxValue;

                  except
                        fFieldNotNumber := True;
                  end;
             end;
        end;

        Table1.Close;

        //if (RadioColourType.ItemIndex = 2) then
        if (PageControl1.ActivePage = TabSheet2) then
        begin
             try
                iIntervals := StrToInt(EditIntervalCount.Text);
             except
                   iIntervals := 10;
             end;

             StringGridValues.RowCount := iIntervals;
        end
        else
            StringGridValues.RowCount := ListBoxValues.Items.Count;
        StringGridValues.Repaint;

     except
           MessageDlg('Exception in UpdateValueList',mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMapLegendForm.RadioColourTypeClick(Sender: TObject);
var
   iIntervals : integer;
begin
     (*case RadioColourType.ItemIndex of
     case RadioColourType.ItemIndex of
          0 :
          begin
               Label1.Enabled := False;
               ComboDisplayField.Enabled := False;
               Label2.Enabled := False;
               EditIntervalCount.Enabled := False;
               StringGridValues.Enabled := False;
               ComboDisplayField.Items.Clear;
               ComboDisplayField.Text := '';
               StringGridValues.RowCount := 2;
               StringGridValues.Repaint;
          end;
          1 :
          begin
               Label1.Enabled := True;
               ComboDisplayField.Enabled := True;
               Label2.Enabled := True;
               EditIntervalCount.Enabled := True;
               StringGridValues.Enabled := True;
               ReadShapeFieldNames;
               ReadShapeFieldMinMax;
               try
                  iIntervals := StrToInt(EditIntervalCount.Text);
               except
                     iIntervals := 10;
               end;
               StringGridValues.RowCount := iIntervals;
               StringGridValues.Repaint;
          end;
          2 :
          begin
               Label1.Enabled := True;
               ComboDisplayField.Enabled := True;
               Label2.Enabled := False;
               EditIntervalCount.Enabled := False;
               StringGridValues.Enabled := True;
               ReadShapeFieldNames;
               ReadShapeFieldValues;
          end;
     end;*)
end;

procedure TMapLegendForm.StringGridValuesDrawCell(Sender: TObject;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
   sCellValue : string;
   rCellMin, rCellMax : extended;
begin
     if (ACol = 1) then
     begin
          //TempColour := DrawGrid1.Canvas.Brush.Color;
          //LocalSingleSolutionColours.rtnValue(ARow+1,@DrawColour);
          //DrawGrid1.Canvas.Brush.Color := DrawColour;
          //DrawGrid1.Canvas.FillRect(Rect);
          //DrawGrid1.Canvas.Brush.Color := TempColour;
     end
     else
     begin
          //if (RadioColourType.ItemIndex = 1) then
          if (PageControl1.ActivePage = TabSheet2) then
          begin
               if fFieldNotNumber then
               begin
                    if (ARow = 0) then
                       StringGridValues.Canvas.TextOut(Rect.Left+5, Rect.Top+5, 'not a number');
               end
               else
               begin
                    rCellMin := rMinValue;
                    rCellMax := rMaxValue;

                    sCellValue := FloatToStr(rCellMin) + ' to ' + FloatToStr(rCellMax);

                    StringGridValues.Canvas.TextOut(Rect.Left+5, Rect.Top+5, sCellValue);
               end;
          end;

          //if (RadioColourType.ItemIndex = 2) then
          //begin
          //     sCellValue := ListBoxValues.Items.Strings[ARow];
          //
          //     StringGridValues.Canvas.TextOut(Rect.Left+5, Rect.Top+5, sCellValue);
          //end;
     end;
end;

procedure TMapLegendForm.ComboDisplayFieldChange(Sender: TObject);
begin     
     //if (RadioColourType.ItemIndex = 1) then
     if (PageControl1.ActivePage = TabSheet2) then
        ReadShapeFieldMinMax;
     //if (RadioColourType.ItemIndex = 2) then
     //   ReadShapeFieldValues;
end;

procedure TMapLegendForm.FormCreate(Sender: TObject);
begin
     rMinValue := 0;
     rMaxValue := 0;
     fFieldNotNumber := True;

     //RadioColourTypeClick(Sender);
end;

procedure TMapLegendForm.EditIntervalCountChange(Sender: TObject);
var
   iIntervals : integer;
begin
     try
        iIntervals := StrToInt(EditIntervalCount.Text);
        StringGridValues.RowCount := iIntervals;
        
     except
     end;
end;

procedure TMapLegendForm.btnDeleteIntervalClick(Sender: TObject);
var
   iRowsToDelete, iCount : integer;
begin
     // how many rows are we deleting?
     iRowsToDelete := StringGridValues.Selection.Bottom - StringGridValues.Selection.Top + 1;
     // copy the rows from below up
     if (StringGridValues.Selection.Bottom < (StringGridValues.RowCount-1)) then
        for iCount := (StringGridValues.Selection.Bottom+1) to (StringGridValues.RowCount-1) do
        begin
             //StringGridValues.Cells[0,iCount-iRowsToDelete] := StringGridValues.Cells[0,iCount];
             //StringGridValues.Cells[1,iCount-iRowsToDelete] := StringGridValues.Cells[1,iCount];
        end;
     // delete rows from the end of grid
     StringGridValues.RowCount := StringGridValues.RowCount - iRowsToDelete;
end;

procedure TMapLegendForm.btnCustomColourClick(Sender: TObject);
begin
     if ColorDialog1.Execute then
     begin
          CustomPanel1.Color := ColorDialog1.Color;
          CustomPanel1.Visible := True;
          ColorGrid1.ForeGroundEnabled := False;
     end;
end;

procedure TMapLegendForm.ColorGrid1Change(Sender: TObject);
begin
     CustomPanel1.Color := clBtnFace;
     CustomPanel1.Visible := False;
end;

procedure TMapLegendForm.CustomPanel1Click(Sender: TObject);
begin
     btnCustomColourClick(Sender);
end;

procedure TMapLegendForm.ColorGrid1Click(Sender: TObject);
begin
     ColorGrid1.ForeGroundEnabled := True;
end;

procedure TMapLegendForm.PageControl1Change(Sender: TObject);
begin
     if (PageControl1.ActivePage = TabSheet2) then
        PageControl1.ActivePage := TabSheet1;
end;

end.
