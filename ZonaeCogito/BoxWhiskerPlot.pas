unit BoxWhiskerPlot;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Buttons;

type
  TBoxWhiskerPlotForm = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    btnSave: TButton;
    Image1: TImage;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure InitGraph;
    procedure Compute_AllocTrack_Values;
    procedure Plot;
    procedure Compute_Marxan_Values;
    procedure btnSaveClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Medians, UpperMedians, LowerMedians, Smallests, Largests : array of extended;
    rMax : extended;
    iBestSolution : integer;
    fAutoClose : boolean;
  end;

var
  BoxWhiskerPlotForm: TBoxWhiskerPlotForm;
  iBWPFDisplayMode : integer;

implementation

uses eFlows, BarGraph, Math, Marxan_interface, Miscellaneous;

{$R *.DFM}

procedure TBoxWhiskerPlotForm.InitGraph;
begin
     try
        case iBWPFDisplayMode of
             0 : Caption := 'AllocTrack Box Whisker Plot';
             1 : Caption := 'AllocTrack Best Solution';
             2 : Caption := 'Summary Box Whisker Plot';
        end;

        if (iBWPFDisplayMode < 2) then
        begin
             iBestSolution := eFlowsForm.ReturnBestRun_OFS;
             Compute_AllocTrack_Values;
             Plot;
        end
        else
        begin
             iBestSolution := 0;
             Compute_Marxan_Values;
             Plot;
        end;


     except
           MessageDlg('Exception in TBoxWhiskerPlotForm.InitGraph',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

function GetMedian (const SortedX : array of extended): extended;
// Returns the Median for a Sorted Array of Extended.
var
   N: integer;
begin
     N := High (SortedX) + 1;
     if N <= 0 then
        raise Exception.Create ('Array is Empty!')
     else if N = 1 then // Only a Single Value
             Result := SortedX [0]
     else if Odd (N) then // Handle Odd Number of Values
             Result := SortedX [N div 2]
     else // Handle Even Number of Values
         Result := (SortedX [N div 2 - 1] + SortedX [N div 2]) / 2;
end;

procedure ButtomUpHeapsort(var Data: array of extended);

   procedure Sink(Index, Arraylength: integer);
   var
      item : extended;
      leftChild, sinkIndex, rightChild, parent: integer;
      done: boolean;
   begin
      sinkIndex := index;
      item := Data[index];
      done := False;

      while not done do begin // search sink-path and move up all items
         leftChild := ((sinkIndex) * 2) + 1;
         rightChild := ((sinkIndex + 1) * 2);

         if rightChild <= Arraylength then begin
            if Data[leftChild] < Data[rightChild] then begin
               Data[sinkIndex] := Data[rightChild];
               sinkIndex := rightChild;
            end
            else begin
               Data[sinkIndex] := Data[leftChild];
               sinkIndex := leftChild;
            end;
         end
         else begin
            done := True;

            if leftChild <= Arraylength then begin
               Data[sinkIndex] := Data[leftChild];
               sinkIndex := leftChild;
            end;
         end;
      end;

      // move up current Item
      Data[sinkIndex] := item;
      done := False;

      while not done do begin
         parent := Trunc((sinkIndex - 1) / 2);
         if (Data[parent] < Data[sinkIndex]) and (parent >= Index) then begin
            item := Data[parent];
            Data[parent] := Data[sinkIndex];
            Data[sinkIndex] := item;
            sinkIndex := parent;
         end
         else
            done := True;
      end;
   end;

var
   x : integer;
   b : extended;
begin
   // first make it a Heap
   for x := Trunc((High(Data) - 1) / 2) downto Low(Data) do
      sink(x, High(Data));

   // do the ButtomUpHeap sort
   for x := High(Data) downto Low(Data) + 1 do begin
      b := Data[x];
      Data[x] := Data[Low(Data)];
      Data[Low(Data)] := b;
      sink(Low(Data), x - 1);
   end;
end;

procedure TBoxWhiskerPlotForm.Compute_AllocTrack_Values;
var
   i, j, iLower, iUpper : integer;
   AllocArray, UpperArray, LowerArray : array of extended;
begin
     try
        ieFlowsNoOfSeasons := eFlowsForm.ReturnNoOfSeasons;
        ieFlowsTotalRun := eFlowsForm.ReturnTotalRun;

        setLength(Medians,ieFlowsNoOfSeasons);
        setLength(UpperMedians,ieFlowsNoOfSeasons);
        setLength(LowerMedians,ieFlowsNoOfSeasons);
        setLength(Smallests,ieFlowsNoOfSeasons);
        setLength(Largests,ieFlowsNoOfSeasons);

        if (iBWPFDisplayMode = 0) then
           setLength(AllocArray,ieFlowsTotalRun)
        else
            setLength(AllocArray,1);
        rMax := 0;

        for i := 0 to (ieFlowsNoOfSeasons-1) do
        begin
             // build array of values for this season
             if (iBWPFDisplayMode = 0) then
             begin
                  // all solutions
                  for j := 0 to (ieFlowsTotalRun-1) do
                  begin
                       AllocArray[j] := StrToFloat(eFlowsWBk.Worksheets.Item['AllocTrack'].Cells.Item[j+2,i+2].Value);
                       if (AllocArray[j] > rMax) then
                          rMax := AllocArray[j];
                  end;
                  // sort array
                  ButtomUpHeapsort(AllocArray);

                  // compute median, lower median, upper median, smallest, largest
                  Medians[i] := GetMedian(AllocArray);
                  Smallests[i] := AllocArray[0];
                  if (iBWPFDisplayMode = 0) then
                     Largests[i] := AllocArray[ieFlowsTotalRun-1]
                  else
                      Largests[i] := AllocArray[0];
                  // count lower & upper
                  iLower := 0;
                  iUpper := 0;
                  for j := 0 to (ieFlowsTotalRun-1) do
                  begin
                       if (AllocArray[j] < Medians[i]) then
                          Inc(iLower);
                       if (AllocArray[j] > Medians[i]) then
                          Inc(iUpper);
                  end;
                  setLength(LowerArray,iLower);
                  setLength(UpperArray,iUpper);
                  // build lower & upper arrays
                  iLower := 0;
                  iUpper := 0;
                  for j := 0 to (ieFlowsTotalRun-1) do
                  begin
                       if (AllocArray[j] < Medians[i]) then
                       begin
                            LowerArray[iLower] := AllocArray[j];
                            Inc(iLower);
                       end;
                       if (AllocArray[j] > Medians[i]) then
                       begin
                            UpperArray[iUpper] := AllocArray[j];
                            Inc(iUpper);
                       end;
                  end;
                  // compute lower & upper median
                  ButtomUpHeapsort(LowerArray);
                  ButtomUpHeapsort(UpperArray);
                  LowerMedians[i] := GetMedian(LowerArray);
                  UpperMedians[i] := GetMedian(UpperArray);
             end
             else
             begin
                  // best solution
                  Medians[i] := StrToFloat(eFlowsWBk.Worksheets.Item['AllocTrack'].Cells.Item[iBestSolution+1,i+2].Value);
                  if (Medians[i] > rMax) then
                     rMax := Medians[i];
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TBoxWhiskerPlotForm.Compute_AllocTrack_Values',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

function Return_Summary_Filename : string;
var
   sSAVESUMMARY, sFileExtension : string;
begin
     sSAVESUMMARY := MarxanInterfaceForm.ReturnMarxanParameter('SAVESUMMARY');
     if (sSAVESUMMARY = '3') then
        sFileExtension := '.csv'
     else
         sFileExtension := '.txt';

     Result := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
               MarxanInterfaceForm.ReturnMarxanParameter('OUTPUTDIR') + '\' +
               MarxanInterfaceForm.ReturnMarxanParameter('SCENNAME') +
               '_sum' +
               sFileExtension;
end;

procedure TBoxWhiskerPlotForm.Compute_Marxan_Values;
var
   i, j, iLower, iUpper, iNumberOfVariables : integer;
   AllocArray, UpperArray, LowerArray : array of extended;
   sInputFile, sLine : string;
   fProceed, fFileExists : boolean;
   InFile : TextFile;
begin
     try
        // we are using 4 variables; total, cost, connectivity & penalty
        iNumberOfVariables := 4;

        setLength(Medians,iNumberOfVariables);
        setLength(UpperMedians,iNumberOfVariables);
        setLength(LowerMedians,iNumberOfVariables);
        setLength(Smallests,iNumberOfVariables);
        setLength(Largests,iNumberOfVariables);

        setLength(AllocArray,iNumberOfRuns);
        rMax := 0;

        sInputFile := Return_Summary_Filename;

        fProceed := True;
        fFileExists := FileExists(sInputFile);
        if not fFileExists then
           fProceed := False;
        if (sInputFile = '') then
           fProceed := False;

        if not fProceed then
        begin
             MessageDlg('No current output file',mtInformation,[mbOk],0);
             fAutoClose := True;
        end
        else
        begin
             for i := 0 to (iNumberOfVariables-1) do
             begin
                  assignfile(InFile,sInputFile);
                  reset(InFile);
                  readln(InFile);

                  // build array of values for this variable
                  // all solutions
                  for j := 0 to (iNumberOfRuns-1) do
                  begin
                       readln(InFile,sLine);

                       case i of
                            0 : AllocArray[j] := StrToFloat(GetDelimitedAsciiElement(sLine,',',2)); // score
                            1 : AllocArray[j] := StrToFloat(GetDelimitedAsciiElement(sLine,',',3)); // cost
                            2 : AllocArray[j] := StrToFloat(GetDelimitedAsciiElement(sLine,',',5)); // connectivity
                            3 : AllocArray[j] := StrToFloat(GetDelimitedAsciiElement(sLine,',',11)); // penalty
                       end;
                       if (AllocArray[j] > rMax) then
                          rMax := AllocArray[j];
                  end;
                  // sort array
                  ButtomUpHeapsort(AllocArray);

                  // compute median, lower median, upper median, smallest, largest
                  Medians[i] := GetMedian(AllocArray);
                  Smallests[i] := AllocArray[0];
                  Largests[i] := AllocArray[iNumberOfRuns-1];
                  // count lower & upper
                  iLower := 0;
                  iUpper := 0;
                  for j := 0 to (iNumberOfRuns-1) do
                  begin
                       if (AllocArray[j] < Medians[i]) then
                          Inc(iLower);
                       if (AllocArray[j] > Medians[i]) then
                          Inc(iUpper);
                  end;
                  setLength(LowerArray,iLower);
                  setLength(UpperArray,iUpper);
                  // build lower & upper arrays
                  iLower := 0;
                  iUpper := 0;
                  for j := 0 to (iNumberOfRuns-1) do
                  begin
                       if (AllocArray[j] < Medians[i]) then
                       begin
                            LowerArray[iLower] := AllocArray[j];
                            Inc(iLower);
                       end;
                       if (AllocArray[j] > Medians[i]) then
                       begin
                            UpperArray[iUpper] := AllocArray[j];
                            Inc(iUpper);
                       end;
                  end;
                  // compute lower & upper median
                  ButtomUpHeapsort(LowerArray);
                  ButtomUpHeapsort(UpperArray);
                  if (iLower = 0) then
                     LowerMedians[i] := 0
                  else
                      LowerMedians[i] := GetMedian(LowerArray);
                  if (iUpper = 0) then
                     UpperMedians[i] := 0
                  else
                      UpperMedians[i] := GetMedian(UpperArray);

                  closefile(InFile);
             end;
        end;


     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TBoxWhiskerPlotForm.Compute_Marxan_Values',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TBoxWhiskerPlotForm.Plot;
var
   ARectangle : TRect;
   iCount, iSegmentSize, iRectangleTop, iRectangleBottom, iRectangleLeft,
   iSpace, iHeight, iGraphWidth, iLeft, iFeatureIndex,
   iXPos, iYPos, iLoopCounter : integer;
   rScore, rCost, rBoundaryLength, rPenalty : extended;
   sTextLabel : string;

   function ValueToHeight(const rValue : extended) : integer;
   var
      iPixels : integer;
   begin
        // rMax gives iSpace-1
        // 0 gives Height-iSpace-1
        if (rMax > 0) then
           iPixels := Floor((Image1.Height-iSpace-iSpace)/rMax*rValue*0.9)
        else
            iPixels := 0;
        Result := Image1.Height - iSpace - iPixels - 1;
   end;

   procedure Y_Axis_Label_Line(rValue : extended);
   var
      rTemp : extended;
   begin
        with Image1.Canvas do
        begin
             rTemp := Round(rValue * 100)/100;
             sTextLabel := FloatToStr(rTemp);
             iHeight := ValueToHeight(rValue);
             Brush.Color := clWhite;
             TextOut((iSpace div 2) -(TextWidth(sTextLabel) div 2),
                     iHeight - (TextHeight(sTextLabel) div 2),
                     sTextLabel);
             PenPos := Point(iSpace-4,iHeight);
             LineTo(Image1.Width-iSpace-1,iHeight);
        end;
   end;

   procedure DrawKey(const sLabel : string;const AColour : TColor;const rFactor : extended);
   begin
        with Image1.Canvas do
        begin
             Brush.Color := clWhite;
             iLeft := iSpace + Floor(iGraphWidth * rFactor) - (TextWidth(sLabel) div 2);
             TextOut(iLeft,
                     (iSpace div 2) - (TextHeight(sLabel) div 2) - 1,
                     sLabel);
             ARectangle := Rect(iLeft - 25,
                                (iSpace div 2) - 1 - 10,
                                iLeft - 5,
                                (iSpace div 2) - 1 + 10);
             Brush.Color := AColour;
             Rectangle(ARectangle);
        end;
   end;

begin
     try
        with Image1.Canvas do
        begin
             iSpace := 80;

             // paint canvas white
             ARectangle := Rect(0,0,Width-1,Height-1);
             Brush.Color := clWhite;
             Brush.Style := bsSolid;
             FillRect(ARectangle);
             // draw border with flood fill
             ARectangle := Rect(iSpace-1,iSpace-1,Image1.Width-iSpace-1,Image1.Height-iSpace);
             Brush.Color := clLtGray;
             Rectangle(ARectangle);

             if (iBWPFDisplayMode < 2) then
                iLoopCounter := ieFlowsNoOfSeasons
             else
                 iLoopCounter := 4;

             iGraphWidth := Width - iSpace - iSpace;
             iSegmentSize := Floor(iGraphWidth/iLoopCounter)-1;

             // Y axis labels and lines
             Y_Axis_Label_Line(0);
             Y_Axis_Label_Line(rMax*0.25);
             Y_Axis_Label_Line(rMax*0.5);
             Y_Axis_Label_Line(rMax*0.75);
             Y_Axis_Label_Line(rMax);

             for iCount := 1 to iLoopCounter do
             begin
                  iRectangleLeft := iSpace + ((iCount-1)*iSegmentSize);
                  if (rMax > 0) then
                  begin
                       if (iBWPFDisplayMode = 1) then
                       begin
                            Brush.Color := clBlack;
                            iXPos := iRectangleLeft+(iSegmentSize div 2);
                            iYPos := ValueToHeight(Medians[iCount-1]);
                            Rectangle(Rect(iXPos-2,iYPos-2,iXPos+3,iYPos+3));
                       end
                       else
                       begin
                            // draw rectangle between upper median line and median line
                            iRectangleTop := ValueToHeight(UpperMedians[iCount-1]);
                            iRectangleBottom := ValueToHeight(Medians[iCount-1]);
                            ARectangle := Rect(iRectangleLeft,
                                               iRectangleTop,
                                               iRectangleLeft+iSegmentSize,
                                               iRectangleBottom);
                            Brush.Color := clNavy;
                            Rectangle(ARectangle);

                            // draw rectangle between median line and lower median line
                            iRectangleTop := ValueToHeight(Medians[iCount-1]);
                            iRectangleBottom := ValueToHeight(LowerMedians[iCount-1]);
                            ARectangle := Rect(iRectangleLeft,
                                               iRectangleTop,
                                               iRectangleLeft+iSegmentSize,
                                               iRectangleBottom);
                            Brush.Color := clGreen;
                            Rectangle(ARectangle);

                            // draw highest whisker
                            Brush.Color := clBlack;
                            Color := clBlack;
                            Brush.Style := bsSolid;
                            iXPos := iRectangleLeft+(iSegmentSize div 2);
                            iYPos := ValueToHeight(Largests[iCount-1]);
                            PenPos := Point(iXPos,ValueToHeight(UpperMedians[iCount-1]));
                            LineTo(iXPos,iYPos);
                            Rectangle(Rect(iXPos-2,iYPos-2,iXPos+3,iYPos+3));

                            // draw lowest whisker
                            iYPos := ValueToHeight(Smallests[iCount-1]);
                            PenPos := Point(iXPos, ValueToHeight(LowerMedians[iCount-1]));
                            LineTo(iXPos,iYPos);
                            Rectangle(Rect(iXPos-2,iYPos-2,iXPos+3,iYPos+3));
                       end;
                  end;

                  // label under bars
                  sTextLabel := IntToStr(iCount);
                  Brush.Color := clWhite;

                  if (iBWPFDisplayMode < 2) then
                     sTextLabel := SeasonToMonthStringAbbreviated(StrToInt(sTextLabel))
                  else
                      case iCount of
                           1 : sTextLabel := 'Score';
                           2 : sTextLabel := 'Cost';
                           3 : sTextLabel := 'Connectivity';
                           4 : sTextLabel := 'Penalty';
                      end;

                  TextOut(iRectangleLeft+(iSegmentSize div 2)-(TextWidth(sTextLabel) div 2),
                          Image1.Height-(iSpace div 2) - (TextHeight(sTextLabel) div 2) - 1,
                          sTextLabel);
             end;
        end;

     except
           MessageDlg('Exception in TBoxWhiskerPlotForm.Plot',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TBoxWhiskerPlotForm.FormCreate(Sender: TObject);
begin
     // draw the box whisker plot from the AllocTrack sheet
     fAutoClose := False;
     InitGraph;
end;

procedure TBoxWhiskerPlotForm.btnSaveClick(Sender: TObject);
var
   fWriteFile : boolean;
begin
     if SaveDialog1.Execute then
     begin
          fWriteFile := True;

          if fileexists(SaveDialog1.Filename) then
             fWriteFile := (mrYes = MessageDlg('File exists. Overwrite?',mtConfirmation,[mbYes,mbNo],0));

          if fWriteFile then
            Image1.Picture.SaveToFile(SaveDialog1.Filename);
     end;
end;

procedure TBoxWhiskerPlotForm.FormResize(Sender: TObject);
begin
     try
        Image1.Align := alNone;
        Image1.Align := alClient;
        Image1.Picture.Graphic.Width := Image1.Width;
        Image1.Picture.Graphic.Height := Image1.Height;
        Plot;

     except
           MessageDlg('Exception in TBoxWhiskerPlotForm.FormResize',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

end.
