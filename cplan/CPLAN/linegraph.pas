unit linegraph;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  ds;

type
    Point_T = record
            r_X, r_Y : extended;
              end;
    IntPoint_T = record
            i_X, i_Y : integer;
              end;

  TLineGraphForm = class(TForm)
    Panel1: TPanel;
    GraphImage: TImage;
    ComboTarget: TComboBox;
    BitBtnOk: TBitBtn;
    btnSaveGraph: TButton;
    btnSaveTable: TButton;
    Label1: TLabel;
    Timer1: TTimer;
    SaveGraphic: TSaveDialog;
    btnPrint: TButton;
    lblSubsetField: TLabel;
    lblFieldName: TLabel;
    ComboSubset: TComboBox;
    lblSubset: TLabel;
    lblMouseMove: TLabel;
    procedure CalculateGraphPoints;
    procedure LineGraph;
    procedure Timer1Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnSaveGraphClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DrawBlueLine(const iFromX,iFromY,iToX,iToY : integer);
    procedure btnSaveTableClick(Sender: TObject);
    procedure SaveGraphFile(const sFilename : string);
    procedure GraphImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure DrawGrayLine(const iFromX,iFromY,iToX,iToY : integer);
    procedure ComboSubsetChange(Sender: TObject);
    procedure CheckDontTrimTargetClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
   LineGraphForm: TLineGraphForm;
   Points, IntPoints, UntrimmedPoints, UntrimmedIntPoints : Array_T;
   iMeasure2Count, iAdjustTgtCount : integer;

implementation

uses Choices, Contribu, global, control, in_order, opt1;

{$R *.DFM}

procedure DumpFloatVuln(const sFilename : string);
var
   OutFile : TextFile;
   iCount, iIndex : integer;
   AFeat : featureoccurrence;
begin
     assignfile(OutFile,sFilename);
     rewrite(OutFile);
     writeln(OutFile,'featidx,floatvuln');
     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,@AFeat);

          iIndex := round(AFeat.rFloatVulnerability);
          if (iIndex < 1) then
             iIndex := 1;
          if (iIndex > 5) then
             iIndex := 5;
             
          writeln(OutFile,IntToStr(iCount) + ',' + FloatToStr(AFeat.rFloatVulnerability) + ',' + FloatToStr(ControlRes^.VulnerabilityWeightings[iIndex]));
     end;
     closefile(OutFile);
end;

procedure CalcMeasure2(const ActiveTarget, ReservedArea : Array_T;
                       var rReturnValue : extended);
var
   iCount, iIndex : integer;
   AFeat : featureoccurrence;
   rTarget, rReserved, rValue, rTmp, rElement : extended;
   fDebug : boolean;
   DebugFile : TextFile;
begin
     Inc(iMeasure2Count);
     fDebug := True;
     if fDebug then
     begin
          assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\calc_measure_2_ITN' + IntToStr(iMeasure2Count) + '.csv');
          rewrite(DebugFile);
          writeln(DebugFile,'featidx,target,reserved,fvuln,element');
     end;

     {Measure_2                   = sum of ([1-TgtMetFeatureX]*VulnFeatureX)}
     rTmp := 0;
     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,@AFeat);
          ActiveTarget.rtnValue(iCount,@rTarget);
          ReservedArea.rtnValue(iCount,@rReserved);

          if (not AFeat.fRestrict) then
          begin
               if (rTarget > 0) then
                  rValue := rTarget / (rTarget + rReserved)
               else
                   rValue := 0;
               if (rValue > 1) then
                  rValue := 1;
               if (rValue < 0) then
                  rValue := 0;

               iIndex := round(AFeat.rFloatVulnerability);
               if (iIndex < 1) then
                  iIndex := 1;
               if (iIndex > 5) then
                  iIndex := 5;
               rElement := (rValue)*ControlRes^.VulnerabilityWeightings[iIndex];
               rTmp := rTmp + rElement;
               if fDebug then
                  writeln(DebugFile,IntToStr(iCount) + ',' + FloatToStr(rTarget) + ',' + FloatToStr(rReserved) + ',' + FloatToStr(ControlRes^.VulnerabilityWeightings[iIndex]) + ',' + FloatToStr(rElement));
          end;
     end;

     rReturnValue := rTmp;

     if fDebug then
        closefile(DebugFile);
end;

procedure AdjustTargetReserves(const ActiveTarget,ReservedArea : Array_T);
var
   iCount : integer;
   AFeat : featureoccurrence;
   rTarget, rReserved : extended;
begin
     // adjust the target and reserved area amounts to take
     // into account existing reserves
     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,@AFeat);
          ActiveTarget.rtnValue(iCount,@rTarget);
          ReservedArea.rtnValue(iCount,@rReserved);

          rTarget := rTarget - AFeat.reservedarea;
          rReserved := rReserved + AFeat.reservedarea;

          ActiveTarget.setValue(iCount,@rTarget);
          ReservedArea.setValue(iCount,@rReserved);
     end;
end;

procedure AdjustTargetSelection(const iIndex : integer;
                                const SelectionList,ActiveTarget,ReservedArea : Array_T);
var
   iCount, iSiteIndex, iFeatures : integer;
   rTarget, rReserved : extended;
   SelectionEntry : SelectionEntry_T;
   ASite : site;
   AFeat : featureoccurrence;
   Value : ValueFile_T;
   fDebug : boolean;
   DebugFile : TextFile;
begin
     Inc(iAdjustTgtCount);
     fDebug := True;
     if fDebug then
     begin
          assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\adjust_tgt_' + IntToStr(iAdjustTgtCount) + '.csv');
          rewrite(DebugFile);
          writeln(DebugFile,'sitekey');
     end;
     // iIndex is 1-based selection index
     // Adjust the target and reserved area amounts to take
     // into account the addition of selection N
     for iCount := 1 to SelectionList.lMaxSize do
     begin
          SelectionList.rtnValue(iCount,@SelectionEntry);
          if (SelectionEntry.iSelection = iIndex) then
          begin
               if fDebug then
                  writeln(DebugFile,IntToStr(SelectionEntry.iKey));
               // perform a selection of the site in the log
               iSiteIndex := FindFeatMatch(OrdSiteArr,SelectionEntry.iKey);
               SiteArr.rtnValue(iSiteIndex,@ASite);
                  if (ASite.richness > 0) then
                     for iFeatures := 1 to ASite.richness do
                     begin
                          FeatureAmount.rtnValue(ASite.iOffset + iFeatures,@Value);
                          FeatArr.rtnValue(Value.iFeatKey,@AFeat);
                          ActiveTarget.rtnValue(Value.iFeatKey,@rTarget);
                          ReservedArea.rtnValue(Value.iFeatKey,@rReserved);

                          rTarget := rTarget - Value.rAmount;
                          rReserved := rReserved + Value.rAmount;

                          ActiveTarget.setValue(Value.iFeatKey,@rTarget);
                          ReservedArea.setValue(Value.iFeatKey,@rReserved);
                     end;
          end;
     end;
     if fDebug then
        closefile(DebugFile);
end;

procedure DumpTarget(const Tgt : Array_t;
                     sFilename : string);
var
   OutFile : TextFile;
   iCount : integer;
   rTarget : extended;
begin
     assignfile(OutFile,sFilename);
     rewrite(OutFile);
     writeln(OutFile,'index,target');

     for iCount := 1 to Tgt.lMaxSize do
     begin
          Tgt.rtnValue(iCount,@rTarget);
          writeln(OutFile,IntToStr(iCount) + ',' + FloatToStr(rTarget));
     end;

     closefile(OutFile);
end;

procedure DumpReserved(const Res : Array_t;
                       sFilename : string);
var
   OutFile : TextFile;
   iCount : integer;
   rReserved : extended;
begin
     assignfile(OutFile,sFilename);
     rewrite(OutFile);
     writeln(OutFile,'index,reserved');

     for iCount := 1 to Res.lMaxSize do
     begin
          Res.rtnValue(iCount,@rReserved);
          writeln(OutFile,IntToStr(iCount) + ',' + FloatToStr(rReserved));
     end;

     closefile(OutFile);
end;

procedure TLineGraphForm.CalculateGraphPoints;
var
   Point : Point_T;
   iPoints, iSelections, iCount, iSelectionListLength : integer;
   fDebug : boolean;
   DebugFile : TextFile;
   ActiveTarget, UntrimmedActiveTarget, ReservedArea, SelectionList : Array_T;
   rTarget, rUntrimmedTarget, rReserved, rMeasure2, rUntrimmedMeasure2 : extended;
   AFeat : featureoccurrence;
begin
     fDebug := True;
     //DumpFloatVuln('c:\floatvuln.csv');

     // count how many selections
     iSelections := ChoiceForm.CountExistingSelections;
     iPoints := iSelections + 2;
     // there is one point for starting condition of no sites reserved
     // and one point for condition of existing reserves
     // there is one additional point for each selection
     Point.r_X := 0;
     Point.r_Y := 0;
     for iCount := 1 to iPoints do
     begin
          Points.setValue(iCount,@Point);
          UntrimmedPoints.setValue(iCount,@Point);
     end;

     // choose and set target and initialise reserved areas to zero
     ActiveTarget := Array_T.Create;
     ActiveTarget.init(SizeOf(extended),iFeatureCount);
     UntrimmedActiveTarget := Array_T.Create;
     UntrimmedActiveTarget.init(SizeOf(extended),iFeatureCount);
     ReservedArea := Array_T.Create;
     ReservedArea.init(SizeOf(extended),iFeatureCount);
     rReserved := 0;
     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,@AFeat);
          // adjust feature targets to only the required subset
          if (ComboSubset.Text <> 'All Features') then
          begin
                if (AFeat.iOrdinalClass = StrToInt(ComboSubset.Text)) then
                begin
                     rUntrimmedTarget := AFeat.rCutOff;
                     rTarget := AFeat.rTrimmedTarget;
                end
                else
                begin
                     rUntrimmedTarget := 0;
                     rTarget := 0;
                end;
          end
          else
          begin
               rUntrimmedTarget := AFeat.rCutOff;
               rTarget := AFeat.rTrimmedTarget;
          end;

          ActiveTarget.setValue(iCount,@rTarget);
          UntrimmedActiveTarget.setValue(iCount,@rUntrimmedTarget);
          ReservedArea.setValue(iCount,@rReserved);
     end;
     // calculate measure2 with no existing reserves
     rMeasure2 := 0;
     rUntrimmedMeasure2 := 0;
     CalcMeasure2(ActiveTarget,ReservedArea,rMeasure2);
     CalcMeasure2(UntrimmedActiveTarget,ReservedArea,rUntrimmedMeasure2);
     // dump target and reserved area
     if fDebug then
     begin
          DumpTarget(ActiveTarget,ControlRes^.sWorkingDirectory + '\tgt_none.csv');
          DumpReserved(ReservedArea,ControlRes^.sWorkingDirectory + '\res_none.csv');
     end;
     //rMeasure2 := CalcMeasure2(ActiveTarget,ReservedArea);
     Point.r_X := 1;
     Point.r_Y := rMeasure2;
     Points.setValue(1,@Point);
     Point.r_X := 1;
     Point.r_Y := rUntrimmedMeasure2;
     UntrimmedPoints.setValue(1,@Point);
     // adjust target to take into account existing reserves
     AdjustTargetReserves(ActiveTarget,ReservedArea);
     AdjustTargetReserves(UntrimmedActiveTarget,ReservedArea);
     // calculate measure2 with existing reserves
     CalcMeasure2(ActiveTarget,ReservedArea,rMeasure2);
     CalcMeasure2(UntrimmedActiveTarget,ReservedArea,rUntrimmedMeasure2);
     // calling this twice seems to produce a different result !!!!!!!!!!!!!!!!!!!!!???????????????????
     if fDebug then
     begin
          DumpTarget(ActiveTarget,ControlRes^.sWorkingDirectory + '\tgt_existing.csv');
          DumpReserved(ReservedArea,ControlRes^.sWorkingDirectory + '\res_existing.csv');
     end;

     Point.r_X := 2;
     Point.r_Y := rMeasure2;
     Points.setValue(2,@Point);
     Point.r_X := 2;
     Point.r_Y := rUntrimmedMeasure2;
     UntrimmedPoints.setValue(2,@Point);
     // for each selection
     if (iSelections > 0) then
     begin
          BuildSelectionList(SelectionList,iSelectionListLength);

          for iCount := 1 to iSelections do
          begin
               // adjust target to take into account this selection
               AdjustTargetSelection(iCount,SelectionList,ActiveTarget,ReservedArea);
               AdjustTargetSelection(iCount,SelectionList,UntrimmedActiveTarget,ReservedArea);
               // calculate measure2 with the addition of this selection
               CalcMeasure2(ActiveTarget,ReservedArea,rMeasure2);
               CalcMeasure2(UntrimmedActiveTarget,ReservedArea,rUntrimmedMeasure2);
               Point.r_X := iCount + 2;
               Point.r_Y := rMeasure2;
               Points.setValue(iCount + 2,@Point);
               Point.r_X := iCount + 2;
               Point.r_Y := rUntrimmedMeasure2;
               UntrimmedPoints.setValue(iCount + 2,@Point);
          end;

          SelectionList.Destroy;
     end;
     if fDebug then
     begin
          DumpTarget(ActiveTarget,ControlRes^.sWorkingDirectory + '\tgt_selections.csv');
          DumpReserved(ReservedArea,ControlRes^.sWorkingDirectory + '\res_selections.csv');

          assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\dbg_points.csv');
          rewrite(DebugFile);
          writeln(DebugFile,'index,X,Y,untrimmedX,untrimmedY');
          for iCount := 1 to Points.lMaxSize do
          begin
               Points.rtnValue(iCount,@Point);
               write(DebugFile,IntToStr(iCount) + ',' +
                               FloatToStr(Point.r_X) + ',' +
                               FloatToStr(Point.r_Y) + ',');
               UntrimmedPoints.rtnValue(iCount,@Point);
               writeln(DebugFile,FloatToStr(Point.r_X) + ',' +
                                 FloatToStr(Point.r_Y));
          end;
          closefile(DebugFile);
     end;

     ActiveTarget.Destroy;
     UntrimmedActiveTarget.Destroy;
     ReservedArea.Destroy;
end;

procedure DumpPoints;
var
   Point : Point_T;
   iCount : integer;
   fDebug : boolean;
   DebugFile : TextFile;
begin
     fDebug := True;
     if fDebug then
     begin
          assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\dump_points.csv');
          rewrite(DebugFile);
          writeln(DebugFile,'index,X,Y');
     end;

     for iCount := 1 to Points.lMaxSize do
     begin
          Points.rtnValue(iCount,@Point);
          if fDebug then
             writeln(DebugFile,IntToStr(iCount) + ',' +
                               FloatToStr(Point.r_X) + ',' +
                               FloatToStr(Point.r_Y));
     end;
     if fDebug then
        closefile(DebugFile);
end;

procedure EmptyCanvas;
var
   MyRect : TRect;
begin
     MyRect := Rect(0,0,(LineGraphForm.GraphImage.Width-1)
                    ,(LineGraphForm.GraphImage.Height-1));

     LineGraphForm.GraphImage.Canvas.Brush.Color := clWhite;
     LineGraphForm.GraphImage.Canvas.FillRect(MyRect);
end;

procedure TLineGraphForm.DrawBlueLine(const iFromX,iFromY,iToX,iToY : integer);
var
   iCount : integer;
   APoint : TPoint;
begin
     //
     LineGraphForm.GraphImage.Canvas.Pen.Color := clBlue;

     APoint.x := iFromX;
     APoint.y := iFromY;

     GraphImage.Canvas.PenPos := APoint;
     GraphImage.Canvas.LineTo(iToX,iToY);

     //LineGraphForm.GraphImage.Canvas.Brush.Color := clBlack;
     LineGraphForm.GraphImage.Canvas.Pen.Color := clBlack;
end;

procedure TLineGraphForm.DrawGrayLine(const iFromX,iFromY,iToX,iToY : integer);
var
   iCount : integer;
   APoint : TPoint;
begin
     //
     LineGraphForm.GraphImage.Canvas.Pen.Color := clGray;

     APoint.x := iFromX;
     APoint.y := iFromY;

     GraphImage.Canvas.PenPos := APoint;
     GraphImage.Canvas.LineTo(iToX,iToY);

     LineGraphForm.GraphImage.Canvas.Pen.Color := clBlack;
end;

procedure TLineGraphForm.LineGraph;
var
   Point, ToPoint : Point_T;
   IntPoint, IntToPoint : TPoint;
   rMinX, rMinY, rMaxX, rMaxY : extended;
   iXLGap,iXRGap,iYTGap,iYBGap,iXDisplay,iYDisplay,
   iCount : integer;
   fDebug : boolean;
   DebugFile : TextFile;
begin
     // ASSUMES ALL X & Y VALUES ARE >= 0
     fDebug := True;
     if fDebug then
     begin
          assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\dbg_lines.csv');
          rewrite(DebugFile);
          writeln(DebugFile,'index,Xf,Yf,toXf,toYf,X,Y,toX,toY');
     end;
     // find max and min values for the points
     rMinX := 99999;
     rMinY := 99999;
     rMaxX := 0;
     rMaxY := 0;
     for iCount := 1 to Points.lMaxSize do
     begin
          Points.rtnValue(iCount,@Point);
          if (Point.r_X < rMinX) then
             rMinX := Point.r_X;
          if (Point.r_X > rMaxX) then
             rMaxX := Point.r_X;
          if (Point.r_Y < rMinY) then
             rMinY := Point.r_Y;
          if (Point.r_Y > rMaxY) then
             rMaxY := Point.r_Y;
          UntrimmedPoints.rtnValue(iCount,@Point);
     end;
     // force Y Minimum to be zero
     rMinY := 0;
     // calculate scaling factors for the display
     iXLGap := 50;
     iXRGap := 20;
     iYBGap := 30;
     iYTGap := 20;
     iXDisplay := GraphImage.Width-iXLGap-iXRGap-1;
     iYDisplay := GraphImage.Height-iYTGap-iYBGap-1;
     EmptyCanvas;
     GraphImage.Canvas.Brush.Color := clBlack;
     // display X-Y axes
     IntPoint.X := iXLGap;
     IntPoint.Y := iYTGap;
     GraphImage.Canvas.PenPos := IntPoint;
     GraphImage.Canvas.LineTo(iXLGap,iYTGap + iYDisplay);
     IntPoint.X := iXLGap;
     IntPoint.Y := iYTGap + iYDisplay;
     GraphImage.Canvas.PenPos := IntPoint;
     GraphImage.Canvas.LineTo(iXLGap + iXDisplay,iYTGap + iYDisplay);
     // display grey maximum value line
     DrawGrayLine(iXLGap,iYTGap,iXLGap+iXDisplay,iYTGap);
     // display X-Y values
     // display X-Y labels
     GraphImage.Canvas.Brush.Color := clWhite;
     GraphImage.Canvas.TextOut(5,(GraphImage.Height - GraphImage.Canvas.TextWidth('Y')) div 2,'Measure');
     GraphImage.Canvas.TextOut((GraphImage.Width - GraphImage.Canvas.TextWidth('Selections')) div 2,GraphImage.Height-20,'Selections');

     // draw line to indicate existing reserve sites contribution
     Points.rtnValue(2,@Point);
     IntPoint.X := iXLGap + round((Point.r_X-rMinX)/(rMaxX-rMinX)*iXDisplay);
     DrawBlueLine(IntPoint.X,iYTGap,IntPoint.X,iYTGap + iYDisplay);

     // store the pixel (integer) value for the first element of Points
     Points.rtnValue(1,@Point);
     IntPoint.X := iXLGap + round((Point.r_X-rMinX)/(rMaxX-rMinX)*iXDisplay);
     IntPoint.Y := iYTGap + round((Point.r_Y-rMinY)/(rMaxY-rMinY)*iYDisplay);
     IntPoints.setValue(1,@IntPoint);

     if (Points.lMaxSize > 1) then
        for iCount := 2 to Points.lMaxSize do
        begin
             Points.rtnValue(iCount-1,@Point);
             Points.rtnValue(iCount,@ToPoint);
             // convert these floating point values to integer equivalent
             IntPoint.X := iXLGap + round((Point.r_X-rMinX)/(rMaxX-rMinX)*iXDisplay);
             IntPoint.Y := iYTGap + round((Point.r_Y-rMinY)/(rMaxY-rMinY)*iYDisplay);
             IntToPoint.X := iXLGap + round((ToPoint.r_X-rMinX)/(rMaxX-rMinX)*iXDisplay);
             IntToPoint.Y := iYTGap + round((ToPoint.r_Y-rMinY)/(rMaxY-rMinY)*iYDisplay);
             // store the pixel (integer) value for each additional element of Points
             IntPoints.setValue(iCount,@IntToPoint);
             // draw a circle over the point
             GraphImage.Canvas.Ellipse(IntToPoint.X-5,IntToPoint.Y-5,IntToPoint.X+5,IntToPoint.Y+5);
             // display the line segment
             GraphImage.Canvas.PenPos := IntPoint;
             GraphImage.Canvas.LineTo(IntToPoint.X,IntToPoint.Y);

             if fDebug then
                writeln(DebugFile,IntToStr(iCount) + ',' +
                                  FloatToStr(Point.r_X) + ',' +
                                  FloatToStr(Point.r_Y) + ',' +
                                  FloatToStr(ToPoint.r_X) + ',' +
                                  FloatToStr(ToPoint.r_Y) + ',' +
                                  IntToStr(IntPoint.X) + ',' +
                                  IntToStr(IntPoint.Y) + ',' +
                                  IntToStr(IntToPoint.X) + ',' +
                                  IntToStr(IntToPoint.Y));
        end;
     if fDebug then
        closefile(DebugFile);
end;

procedure TLineGraphForm.Timer1Timer(Sender: TObject);
begin
     Timer1.Enabled := False;

     try
        Screen.Cursor := crHourglass;

        // calculate the graph points
        CalculateGraphPoints;

        // graph the points to the GraphImage
        LineGraph;
        //Points.Destroy;
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception when drawing graph',mtInformation,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
end;

procedure TLineGraphForm.FormResize(Sender: TObject);
begin
     Timer1.Enabled := True;
end;

procedure TLineGraphForm.btnSaveGraphClick(Sender: TObject);
begin
     SaveGraphic.InitialDir := ControlRes^.sWorkingDirectory;
     SaveGraphic.FileName := 'graph.bmp';
     SaveGraphic.Title := 'Save Graph Image';

     if SaveGraphic.Execute then
     begin
          GraphImage.Picture.SaveToFile(SaveGraphic.FileName);
     end;
end;

procedure TLineGraphForm.btnPrintClick(Sender: TObject);
begin
     PrintScale := poPrintToFit;
     Print;
end;

procedure TLineGraphForm.FormCreate(Sender: TObject);
var
   iCount, iSelections, iPoints : integer;
begin
     if ControlRes^.fFeatureClassesApplied then
     begin
          lblFieldName.Caption := ControlRes^.sFeatureClassField;
          ComboSubset.Items.Clear;
          for iCount := 1 to 10 do
              if ControlRes^.ClassDetail[iCount] then
                 ComboSubset.Items.Add(IntToStr(iCount));
          ComboSubset.Items.Add('All Features');
     end
     else
     begin
          lblSubsetField.Visible := False;
          lblFieldName.Visible := False;
          lblSubset.Visible := False;
          ComboSubset.Visible := False;
     end;

     ControlForm.LoadTargetFields(ComboTarget.Items);
     ComboTarget.Items.Insert(0,'Available Target');

     iSelections := ChoiceForm.CountExistingSelections;
     iPoints := iSelections + 2;
     // There is one point for starting condition of no sites reserved
     // and one point for condition of existing reserves
     // and there is one additional point for each selection.
     Points := Array_T.Create;
     Points.init(SizeOf(Point_T),iPoints);
     IntPoints := Array_T.Create;
     IntPoints.init(SizeOf(IntPoint_T),iPoints);
     UntrimmedPoints := Array_T.Create;
     UntrimmedPoints.init(SizeOf(Point_T),iPoints);
     UntrimmedIntPoints := Array_T.Create;
     UntrimmedIntPoints.init(SizeOf(IntPoint_T),iPoints);

     iMeasure2Count := 0;
     iAdjustTgtCount := 0;
end;

procedure TLineGraphForm.SaveGraphFile(const sFilename : string);
var
   OutFile : TextFile;
   Point : Point_T;
   iCount : integer;
   rMaximumValue, rUntrimmedMaximumValue, rTmp : extended;
   sTmp : string;
begin
     // find the maximum value for measure2
     Points.rtnValue(1,@Point);
     rMaximumValue := Point.r_Y;
     UntrimmedPoints.rtnValue(1,@Point);
     rUntrimmedMaximumValue := Point.r_Y;
     // create and populate the graph file
     assignfile(OutFile,sFilename);
     rewrite(OutFile);
     writeln(OutFile,'Selection,C-Plan Feature Index,C-Plan Feature Index %,Untrimmed C-Plan Feature Index,Untrimmed C-Plan Feature Index %');
     Points.rtnValue(1,@Point);
     rTmp := 100 - (Point.r_Y/rMaximumValue*100);
     if (rTmp = 0) then
        sTmp := '0'
     else
         Str(rTmp:6:2,sTmp);
     write(OutFile,'no sites reserved,' + FloatToStr(Point.r_Y) + ',' + sTmp);
     UntrimmedPoints.rtnValue(1,@Point);
     rTmp := 100 - (Point.r_Y/rUntrimmedMaximumValue*100);
     if (rTmp = 0) then
        sTmp := '0'
     else
         Str(rTmp:6:2,sTmp);
     writeln(OutFile,',' + FloatToStr(Point.r_Y) + ',' + sTmp);

     Points.rtnValue(2,@Point);
     rTmp := 100 - (Point.r_Y/rMaximumValue*100);
     if (rTmp = 0) then
        sTmp := '0'
     else
         Str(rTmp:6:2,sTmp);
     write(OutFile,'pre-existing reserves,' + FloatToStr(Point.r_Y) + ',' + sTmp);
     UntrimmedPoints.rtnValue(2,@Point);
     rTmp := 100 - (Point.r_Y/rUntrimmedMaximumValue*100);
     if (rTmp = 0) then
        sTmp := '0'
     else
         Str(rTmp:6:2,sTmp);
     writeln(OutFile,',' + FloatToStr(Point.r_Y) + ',' + sTmp);

     if (Points.lMaxSize > 2) then
        for iCount := 3 to Points.lMaxSize do
        begin
             Points.rtnValue(iCount,@Point);
             rTmp := 100 - (Point.r_Y/rMaximumValue*100);
             if (rTmp = 0) then
                sTmp := '0'
             else
                 Str(rTmp:6:2,sTmp);
             write(OutFile,'selection ' + IntToStr(iCount-2) + ',' + FloatToStr(Point.r_Y) + ',' + sTmp);
             UntrimmedPoints.rtnValue(iCount,@Point);
             rTmp := 100 - (Point.r_Y/rUntrimmedMaximumValue*100);
             if (rTmp = 0) then
                sTmp := '0'
             else
                 Str(rTmp:6:2,sTmp);
             writeln(OutFile,',' + FloatToStr(Point.r_Y) + ',' + sTmp);
        end;
     closefile(OutFile);
end;

procedure TLineGraphForm.btnSaveTableClick(Sender: TObject);
begin
     SaveGraphic.InitialDir := ControlRes^.sWorkingDirectory;
     SaveGraphic.FileName := 'graph.csv';
     SaveGraphic.Title := 'Save Graph Table';
     if SaveGraphic.Execute then
     begin
          // save the points to a text file
          SaveGraphFile(SaveGraphic.Filename);
     end;
end;

procedure TLineGraphForm.GraphImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
   iCorresponding_X_Value, iCount : integer;
   IntPoint : IntPoint_T;
   Point : Point_T;
   rMaximumValue, rTmp : extended;
   sTmp : string;
begin
     // see which point the x value corresponds to and display it
     iCorresponding_X_Value := 0;
     // traverse each of the points, seeing if the mouse is sitting over it
     for iCount := 1 to IntPoints.lMaxSize do
     begin
          IntPoints.rtnValue(iCount,@IntPoint);

          if (X > (IntPoint.i_X - 5))
          and (X < (IntPoint.i_X + 5)) then
              iCorresponding_X_Value := iCount;
     end;
     // find the maximum value for measure2
     Points.rtnValue(1,@Point);
     rMaximumValue := Point.r_Y;

     if (iCorresponding_X_Value > 0) then
     begin
          Points.rtnValue(iCorresponding_X_Value,@Point);
          rTmp := 100 - (Point.r_Y/rMaximumValue*100);
          if (rTmp = 0) then
             sTmp := '0'
          else
              Str(rTmp:6:2,sTmp);
          if (iCorresponding_X_Value = 1) then
             lblMouseMove.Caption := 'no sites reserved, ' + sTmp + '%';
          if (iCorresponding_X_Value = 2) then
             lblMouseMove.Caption := 'pre-existing reserves, ' + sTmp + '%';
          if (iCorresponding_X_Value > 2) then
             lblMouseMove.Caption := 'selection ' + IntToStr(iCorresponding_X_Value-2) + ', ' + sTmp + '%';
     end
     else
     begin
          lblMouseMove.Caption := '';
     end;
end;

procedure TLineGraphForm.FormDestroy(Sender: TObject);
begin
     Points.Destroy;
     IntPoints.Destroy;
     UntrimmedPoints.Destroy;
     UntrimmedIntPoints.Destroy;
end;

procedure TLineGraphForm.ComboSubsetChange(Sender: TObject);
begin
     // change the subset
     Timer1.Enabled := True;
end;

procedure TLineGraphForm.CheckDontTrimTargetClick(Sender: TObject);
begin
     Timer1.Enabled := True;
end;

end.
