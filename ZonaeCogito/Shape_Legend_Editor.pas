unit Shape_Legend_Editor;

interface

uses
  ds, GIS, Marxan_interface,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ColorGrd, Grids, StdCtrls, ExtCtrls, Buttons;

type
  TMarxanLegendEditorForm = class(TForm)
    RadioType: TRadioGroup;
    ColorGrid1: TColorGrid;
    Shape1: TShape;
    LabelToEdit: TLabel;
    MemoColour: TMemo;
    DrawGrid1: TDrawGrid;
    BitBtnAcceptChanges: TBitBtn;
    BitBtn2: TBitBtn;
    procedure RadioTypeClick(Sender: TObject);
    procedure DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ColorGrid1Change(Sender: TObject);
    procedure PrepareForm;
    procedure BitBtnAcceptChangesClick(Sender: TObject);
    procedure DrawGrid1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DrawGrid1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    GChild : TGIS_Child;
    MChild : TMarxanInterfaceForm;
    LocalSingleSolutionColours : Array_t;
    LocalSelectionColour, LocalSummedSolutionColour : TColor;
  end;

var
  MarxanLegendEditorForm: TMarxanLegendEditorForm;

implementation

{$R *.DFM}

uses
    SCP_Main, Miscellaneous;

procedure TMarxanLegendEditorForm.RadioTypeClick(Sender: TObject);
var
   TempColour : TColor;
   //iCount : integer;
begin
     case RadioType.ItemIndex of
          0 : begin
                   LabelToEdit.Caption := 'Selection Colour';
                   MemoColour.Visible := False;
                   Shape1.Brush.Color := LocalSelectionColour;
                   DrawGrid1.Visible := False;
                   //ColorGrid1.ForegroundIndex := ColourToIndex(LocalSelectionColour);
              end;
          1 : begin
                   LabelToEdit.Caption := 'Selection Frequency Colour';
                   MemoColour.Visible := True;
                   MemoColour.Lines.Clear;
                   MemoColour.Lines.Add('Colours will be ramped from white (Selection Frequency = 0) to colour specified (Selection Frequency = number of runs).');
                   Shape1.Brush.Color := LocalSummedSolutionColour;
                   DrawGrid1.Visible := False;
                   //ColorGrid1.ForegroundIndex := ColourToIndex(LocalSummedSolutionColour);
              end;
          2 : begin
                   LabelToEdit.Caption := 'Single Solution Colour';
                   MemoColour.Visible := True;
                   MemoColour.Lines.Clear;
                   MemoColour.Lines.Add('Specify a colour for each zone.');
                   DrawGrid1.Visible := True;
                   LocalSingleSolutionColours.rtnValue(1,@TempColour);
                   //ColorGrid1.ForegroundIndex := ColourToIndex(TempColour);

                   //for iCount := 1 to LocalSingleSolutionColours.lMaxSize do
                   //    DrawGrid1.Cells[1,iCount-1] := MChild.ReturnZoneName(iCount);
              end;
   end;
end;

procedure TMarxanLegendEditorForm.DrawGrid1DrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
   TempColour, DrawColour : TColor;
begin
     if (ACol = 0) then
     begin
          TempColour := DrawGrid1.Canvas.Brush.Color;

          LocalSingleSolutionColours.rtnValue(ARow+1,@DrawColour);

          DrawGrid1.Canvas.Brush.Color := DrawColour;

          DrawGrid1.Canvas.FillRect(Rect);

          DrawGrid1.Canvas.Brush.Color := TempColour;
     end
     else
         DrawGrid1.Canvas.TextOut(Rect.Left+5, Rect.Top+5, MChild.ReturnZoneName(ARow+1));
end;

procedure TMarxanLegendEditorForm.ColorGrid1Change(Sender: TObject);
var
   TempColour : TColor;
begin
     case RadioType.ItemIndex of
          0 : begin
                   Shape1.Brush.Color := ColorGrid1.ForegroundColor;
                   LocalSelectionColour := ColorGrid1.ForegroundColor;
              end;
          1 : begin
                   Shape1.Brush.Color := ColorGrid1.ForegroundColor;
                   LocalSummedSolutionColour := Shape1.Brush.Color;
              end;
          2 : begin
                   TempColour := ColorGrid1.ForegroundColor;
                   LocalSingleSolutionColours.setValue(DrawGrid1.Selection.Top+1,@TempColour);
                   DrawGrid1.Invalidate;
                   DrawGrid1.Update;
              end;
     end;
end;

procedure TMarxanLegendEditorForm.PrepareForm;
var
   iCount : integer;
   TempColour : TColor;
begin
     LocalSingleSolutionColours := Array_t.Create;
     LocalSingleSolutionColours.init(SizeOf(TColor),MChild.SingleSolutionColours.lMaxSize);

     for iCount := 1 to MChild.SingleSolutionColours.lMaxSize do
     begin
          MChild.SingleSolutionColours.rtnValue(iCount,@TempColour);
          LocalSingleSolutionColours.setValue(iCount,@TempColour);
     end;

     DrawGrid1.RowCount := LocalSingleSolutionColours.lMaxSize;

     LocalSelectionColour := GChild.SelectionColour;
     LocalSummedSolutionColour := GChild.SummedSolutionColour;

     LabelToEdit.Caption := 'Selection Colour';
     MemoColour.Visible := False;
     Shape1.Brush.Color := LocalSelectionColour;
     DrawGrid1.Visible := False;
     //ColorGrid1.ForegroundIndex := ColourToIndex(LocalSelectionColour);
end;

procedure TMarxanLegendEditorForm.BitBtnAcceptChangesClick(Sender: TObject);
var
   iCount : integer;
   TempColour : TColor;
begin
     for iCount := 1 to LocalSingleSolutionColours.lMaxSize do
     begin
          LocalSingleSolutionColours.rtnValue(iCount,@TempColour);
          MChild.SingleSolutionColours.setValue(iCount,@TempColour);
     end;

     GChild.SelectionColour := LocalSelectionColour;
     GChild.SummedSolutionColour := LocalSummedSolutionColour;

     // update map
     MChild.RefreshGISDisplay;
end;

procedure TMarxanLegendEditorForm.DrawGrid1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   TempColour : TColor;
begin
     LocalSingleSolutionColours.rtnValue(DrawGrid1.Selection.Top+1,@TempColour);
     //ColorGrid1.ForegroundIndex := ColourToIndex(TempColour);
end;

procedure TMarxanLegendEditorForm.DrawGrid1KeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
   TempColour : TColor;
begin
     LocalSingleSolutionColours.rtnValue(DrawGrid1.Selection.Top+1,@TempColour);
     //ColorGrid1.ForegroundIndex := ColourToIndex(TempColour);
end;

end.
