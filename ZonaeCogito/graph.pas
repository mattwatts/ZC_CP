unit graph;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons,
  CSV_Child, ds;

type
  TGraphForm = class(TForm)
    Image1: TImage;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    btnSave: TButton;
    ComboXAxis: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    ComboYAxis: TComboBox;
    SaveDialog1: TSaveDialog;
    CheckZero: TCheckBox;
    CheckSquares: TCheckBox;
    Label3: TLabel;
    EditSquareSize: TEdit;
    labelInfo: TLabel;
    procedure DrawLineGraph;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ComboXAxisChange(Sender: TObject);
    procedure ComboYAxisChange(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure CheckZeroClick(Sender: TObject);
    procedure CheckSquaresClick(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditSquareSizeChange(Sender: TObject);
    function IsWithinPoint(iX, iY : integer) : integer;
  private
    { Private declarations }
  public
    { Public declarations }
    sCsvChildName, sXField, sYField : string;
    GraphCSVChild : TCSVChild;
    iNumberOfPoints, iSquareSize, iSquareValue,
    iXField, iYField : integer;
    PointsArray : Array_t;
  end;

var
  GraphForm: TGraphForm;

implementation

{$R *.DFM}

procedure TGraphForm.DrawLineGraph;
var
   ARectangle : TRect;
   APoint : TPoint;
   rXMax, rXMin, rYMax, rYMin, rXValue, rYValue : extended;
   iCount, iSpace,
   iXMax, iXMin, iYMax, iYMin, iXValue, iYValue : integer;

   procedure MapValuesToPoint(const rX_Value, rY_Value : extended;
                              var iX_Value, iY_Value : integer);
   begin
        // x max is width-1
        // x min is 0
        // y max is 0
        // y min is height-1

        iX_Value := Round((rX_Value - rXMin) / (rXMax - rXMin) * (iXMax - iXMin)) + iXMin;
        iY_Value := Round((rY_Value - rYMin) / (rYMax - rYMin) * (iYMax - iYMin)) + iYMin;
   end;
begin
     if (sCsvChildName <> '') then
        with Image1.Canvas do
        begin
             iSpace := 15;

             // paint canvas white
             ARectangle := Rect(0,0,Width-1,Height-1);
             Brush.Color := clWhite;
             Brush.Style := bsSolid;
             FillRect(ARectangle);

             // write axis labels
             TextOut(iSpace,
                     (Image1.Height div 2) - (TextHeight(sYField) div 2),
                     sYField);

             TextOut((Image1.Width div 2) - (TextWidth(sXField) div 2),
                     Image1.Height - TextHeight(sXField)- iSpace,
                     sXField);
             // draw axis lines
             //Brush.Color := clBlue;
             //Brush.Style := bsSolid;
             iXMax := Image1.Width - iSpace;
             iXMin := TextWidth(sYField) + iSpace + iSpace;
             iYMax := iSpace;
             iYMin := Image1.Height - TextHeight(sXField) - iSpace - iSpace;
             PolyLine([Point(iXMin,iYMax),
                       Point(iXMin,iYMin),
                       Point(iXMax,iYMin)]);

             // detect x&y field indices
             iXField := 0;
             iYField := 0;
             for iCount := 0 to (GraphCSVChild.aGrid.ColCount - 1) do
             begin
                  if (GraphCSVChild.aGrid.Cells[iCount,0] = sXField) then
                     iXField := iCount;
                  if (GraphCSVChild.aGrid.Cells[iCount,0] = sYField) then
                     iYField := iCount;
             end;
             // detect minimum/maximum axis values
             try
                rXMax := StrToFloat(GraphCSVChild.aGrid.Cells[iXField,1]);
             except
                   rXMax := 0;
             end;
             rXMin := rXMax;
             try
                rYMax := StrToFloat(GraphCSVChild.aGrid.Cells[iYField,1]);
             except
                   rYMax := 0;
             end;
             rYMin := rYMax;
             for iCount := 1 to (GraphCSVChild.aGrid.RowCount - 1) do
             begin
                  try
                     rXValue := StrToFloat(GraphCSVChild.aGrid.Cells[iXField,iCount]);
                  except
                        rXValue := 0;
                  end;
                  if (rXValue > rXMax) then
                     rXMax := rXValue;
                  if (rXValue < rXMin) then
                     rXMin := rXValue;
                  try
                     rYValue := StrToFloat(GraphCSVChild.aGrid.Cells[iYField,iCount]);
                  except
                        rYValue := 0;
                  end;
                  if (rYValue > rYMax) then
                     rYMax := rYValue;
                  if (rYValue < rYMin) then
                     rYMin := rYValue;
             end;
             if CheckZero.Checked then
             begin
                  if (rXMin > 0) then
                     rXMin := 0;
                  if (rYMin > 0) then
                     rYMin := 0;
             end;
             // write x&y minimum/maximum values
             // y max
             TextOut(iXMin - (iSpace div 2) - TextWidth(FloatToStr(rYMax)),
                     iYMax - (TextHeight(FloatToStr(rYMax)) div 2),
                     FloatToStr(rYMax));
             PenPos := Point(iXMin,iYMax);
             LineTo(iXMin - (iSpace div 2),iYMax);
             // y min
             TextOut(iXMin - (iSpace div 2) - TextWidth(FloatToStr(rYMin)),
                     iYMin - (TextHeight(FloatToStr(rYMin)) div 2),
                     FloatToStr(rYMin));
             PenPos := Point(iXMin,iYMin);
             LineTo(iXMin - (iSpace div 2),iYMin);
             // x max
             TextOut(iXMax - (TextWidth(FloatToStr(rXMax)) div 2),
                     iYMin  + (iSpace div 2),
                     FloatToStr(rXMax));
             PenPos := Point(iXMax,iYMin);
             LineTo(iXMax,iYMin + (iSpace div 2));
             // x min
             TextOut(iXMin - (TextWidth(FloatToStr(rXMin)) div 2),
                     iYMin  + (iSpace div 2),
                     FloatToStr(rXMin));
             PenPos := Point(iXMin,iYMin);
             LineTo(iXMin,iYMin + (iSpace div 2));

             // plot the values to the graph
             //Brush.Color := clBlack;
             for iCount := 1 to (GraphCSVChild.aGrid.RowCount - 1) do
             begin
                  try
                     rXValue := StrToFloat(GraphCSVChild.aGrid.Cells[iXField,iCount]);
                  except
                        rXValue := 0;
                  end;
                  try
                     rYValue := StrToFloat(GraphCSVChild.aGrid.Cells[iYField,iCount]);
                  except
                        rYValue := 0;
                  end;

                  MapValuesToPoint(rXValue,rYValue,
                                   iXValue,iYValue);

                  if (iCount = 1) then
                     PenPos := Point(iXValue,iYValue)
                  else
                      LineTo(iXValue,iYValue);
             end;
             // draw a square around each point
             if (iNumberOfPoints = 0) then
             begin
                  PointsArray := Array_t.Create;
                  PointsArray.init(SizeOf(TPoint),GraphCSVChild.aGrid.RowCount);
             end;
             iNumberOfPoints := GraphCSVChild.aGrid.RowCount;
             iSquareValue := iSquareSize div 2;
             for iCount := 1 to (GraphCSVChild.aGrid.RowCount - 1) do
             begin
                  try
                     rXValue := StrToFloat(GraphCSVChild.aGrid.Cells[iXField,iCount]);
                  except
                        rXValue := 0;
                  end;
                  try
                     rYValue := StrToFloat(GraphCSVChild.aGrid.Cells[iYField,iCount]);
                  except
                        rYValue := 0;
                  end;

                  MapValuesToPoint(rXValue,rYValue,
                                   iXValue,iYValue);

                  APoint.x := iXValue;
                  APoint.y := iYValue;
                  PointsArray.setValue(iCount,@APoint);

                  if CheckSquares.Checked then
                  begin
                       PenPos := Point(iXValue-iSquareValue,iYValue-iSquareValue);
                       LineTo(iXValue-iSquareValue,iYValue+iSquareValue);
                       LineTo(iXValue+iSquareValue,iYValue+iSquareValue);
                       LineTo(iXValue+iSquareValue,iYValue-iSquareValue);
                       LineTo(iXValue-iSquareValue,iYValue-iSquareValue);
                  end;
             end;
        end;
end;

procedure TGraphForm.FormCreate(Sender: TObject);
begin
     sCsvChildName := '';
     iNumberOfPoints := 0;
     iSquareSize := 10;
     iSquareValue := 5;
     iXField := 0;
     iYField := 1;
end;

procedure TGraphForm.FormResize(Sender: TObject);
begin
     Image1.Align := alNone;
     Image1.Align := alClient;
     DrawLineGraph;
end;

procedure TGraphForm.ComboXAxisChange(Sender: TObject);
begin
     sXField := ComboXAxis.Text;
     DrawLineGraph;
end;

procedure TGraphForm.ComboYAxisChange(Sender: TObject);
begin
     sYField := ComboYAxis.Text;
     DrawLineGraph;
end;

procedure TGraphForm.btnSaveClick(Sender: TObject);
begin
     SaveDialog1.InitialDir := ExtractFilePath(sCsvChildName);
     if SaveDialog1.Execute then
        Image1.Picture.SaveToFile(SaveDialog1.Filename);
end;

procedure TGraphForm.CheckZeroClick(Sender: TObject);
begin
     DrawLineGraph;
end;

procedure TGraphForm.CheckSquaresClick(Sender: TObject);
begin
     DrawLineGraph;
end;

function TGraphForm.IsWithinPoint(iX, iY : integer) : integer;
var
   iCount : integer;
   APoint : TPoint;
begin
     Result := 0;

     for iCount := 1 to PointsArray.lMaxSize do
     begin
          PointsArray.rtnValue(iCount,@APoint);

          if (iX >= (APoint.x - iSquareValue))
          and (iX <= (APoint.x + iSquareValue)) then
              if (iY >= (APoint.y - iSquareValue))
              and (iY <= (APoint.y + iSquareValue)) then
                  Result := iCount;
     end;  
end;

procedure TGraphForm.Image1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
   iPoint : integer;
begin
     if (iNumberOfPoints > 0) then
     begin
          iPoint := IsWithinPoint(X,Y);
          if (iPoint > 0) then
          begin
               // display information for this point
               labelInfo.Caption := 'Point ' + IntToStr(iPoint) +
                                    ' ' + ComboXAxis.Text + ' ' + GraphCSVChild.aGrid.Cells[iXField,iPoint] +
                                    ' ' + ComboYAxis.Text + ' ' + GraphCSVChild.aGrid.Cells[iYField,iPoint];
               labelInfo.Visible := True;
          end
          else
              labelInfo.Visible := False;
     end;
end;

procedure TGraphForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     if (iNumberOfPoints > 0) then
        PointsArray.Destroy;
end;

procedure TGraphForm.EditSquareSizeChange(Sender: TObject);
begin
     try
        iSquareSize := StrToInt(EditSquareSize.Text);

        if (iSquareSize > 0) then
           DrawLineGraph;

     except
           iSquareSize := 10;
           DrawLineGraph;
     end;
end;

end.
