unit BrowseAnnealingOutput;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, Buttons,
  CSV_Child, MapWinGIS_TLB, MPlayer;

type
  TBrowseAnnealingOutputForm = class(TForm)
    LabelIterations: TLabel;
    ScrollBar1: TScrollBar;
    Label2: TLabel;
    BitBtn1: TBitBtn;
    Image1: TImage;
    Timer1: TTimer;
    Label1: TLabel;
    Label3: TLabel;
    ScrollBarIteration: TScrollBar;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Timer2: TTimer;
    Label4: TLabel;
    ComboMarxanRun: TComboBox;
    procedure InitMap;
    procedure UpdateMap;
    procedure UpdateMapSingleStep;
    procedure InitGraph;
    procedure UpdateGraph;
    procedure UpdateAnnealingStep;
    procedure InitBrowser;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure ScrollBarIterationChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure ForceParamters;
    procedure Timer2Timer(Sender: TObject);
    procedure InitSolutionCount;
    procedure ComboMarxanRunChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    sZonesFileName, sObjectiveFileName : string;
    fZonesChild, fObjectiveChild, fSinglePUStep : boolean;
    ZonesChild, ObjectiveChild : TCSVChild;
    rTotalMin, rTotalMax, rCostMin, rCostMax, rConnectivityMin, rConnectivityMax, rPenaltyMin, rPenaltyMax : extended;
    iUpdateLayer, iUpdateMap, iLastSingleStep, iLastSingleStepStatus : integer;
    sf: MapWinGIS_TLB.Shapefile;
    fForward : boolean;
    iSolutionToBrowse : integer;
  end;

var
  BrowseAnnealingOutputForm: TBrowseAnnealingOutputForm;

implementation

uses Marxan_interface, Miscellaneous, SCP_Main, GIS;

{$R *.DFM}

procedure TBrowseAnnealingOutputForm.InitMap;
var
   iCount, iStatus, iPUIndex : integer;
   AColour : TColor;
begin
     // read planning unit configuration from row (iUpdateMap + 1) and write it to GIS
     for iCount := 1 to sf.NumShapes do
     begin
          iStatus := StrToInt(ZonesChild.aGrid.Cells[ZonesChild.aGrid.ColCount-iCount,1]);
          if (iStatus = 0) then
             AColour := clWhite
          else
              AColour := clBlue;

          GIS_Child.Map1.ShapeFillColor[iUpdateLayer,iCount-1] := AColour;

          if SCPForm.ShapeOutlines1.Checked then
             GIS_Child.Map1.ShapeLineColor[iUpdateLayer,iCount-1] := clBlack
          else
              GIS_Child.Map1.ShapeLineColor[iUpdateLayer,iCount-1] := AColour;
     end;
end;

procedure TBrowseAnnealingOutputForm.UpdateMap;
var
   iCount, iStatus, iPUIndex : integer;
   AColour : TColor;
   fPaintStep : boolean;
begin
     // read planning unit configuration from row (iUpdateMap + 1) and write it to GIS
     for iCount := 1 to sf.NumShapes do
     begin
          iStatus := StrToInt(ZonesChild.aGrid.Cells[ZonesChild.aGrid.ColCount-iCount,iUpdateMap+1]);

          AColour := GIS_Child.rtnZoneColour(iStatus);

          GIS_Child.Map1.ShapeFillColor[iUpdateLayer,iCount-1] := AColour;

          if SCPForm.ShapeOutlines1.Checked then
             GIS_Child.Map1.ShapeLineColor[iUpdateLayer,iCount-1] := clBlack
          else
              GIS_Child.Map1.ShapeLineColor[iUpdateLayer,iCount-1] := AColour;
     end;

     if fForward then
        fPaintStep := (iUpdateMap < (ObjectiveChild.aGrid.RowCount-1))
     else
         fPaintStep := (iUpdateMap > 1);

     (*if fPaintStep then
     begin
          // paint planning unit that is under consideration
          if (ObjectiveChild.AGrid.ColCount < 10) then
             iPUIndex := StrToInt(ObjectiveChild.AGrid.Cells[8,iUpdateMap])
          else
              iPUIndex := StrToInt(ObjectiveChild.AGrid.Cells[9,iUpdateMap]);
          //GIS_Child.Map1.ShapeFillColor[iUpdateLayer,iPUIndex] := clRed;
          GIS_Child.Map1.ShapeFillColor[iUpdateLayer,sf.NumShapes-iPUIndex-1] := GIS_Child.SelectionColour;
          if SCPForm.ShapeOutlines1.Checked then
             GIS_Child.Map1.ShapeLineColor[iUpdateLayer,sf.NumShapes-iPUIndex-1] := clBlack
          else
              GIS_Child.Map1.ShapeLineColor[iUpdateLayer,sf.NumShapes-iPUIndex-1] := GIS_Child.SelectionColour;
     end;*)
end;

procedure TBrowseAnnealingOutputForm.UpdateMapSingleStep;
var
   iCount, iStatus, iPUIndex : integer;
   AColour : TColor;
begin
     if (iLastSingleStep > -1) then
     begin
          if (iLastSingleStepStatus = 0) then
             AColour := clWhite
          else
              AColour := clBlue;

          GIS_Child.Map1.ShapeFillColor[iUpdateLayer,iLastSingleStep] := AColour;
          if SCPForm.ShapeOutlines1.Checked then
             GIS_Child.Map1.ShapeLineColor[iUpdateLayer,iLastSingleStep] := clBlack
          else
              GIS_Child.Map1.ShapeLineColor[iUpdateLayer,iLastSingleStep] := AColour;
     end;

     // paint planning unit that is under consideration
     iPUIndex := StrToInt(ObjectiveChild.AGrid.Cells[9,iUpdateMap]);
     //GIS_Child.Map1.ShapeFillColor[iUpdateLayer,iPUIndex] := clRed;
     GIS_Child.Map1.ShapeFillColor[iUpdateLayer,sf.NumShapes-iPUIndex-1] := clRed;
     if SCPForm.ShapeOutlines1.Checked then
        GIS_Child.Map1.ShapeLineColor[iUpdateLayer,sf.NumShapes-iPUIndex-1] := clBlack
     else
         GIS_Child.Map1.ShapeLineColor[iUpdateLayer,sf.NumShapes-iPUIndex-1] := clRed;

     iLastSingleStep := sf.NumShapes-iPUIndex-1;
     iLastSingleStepStatus := StrToInt(ZonesChild.aGrid.Cells[iPUIndex,iUpdateMap]);
end;

function ValueToTopCoord(const rValue,rMax,rMin : extended) : integer;
var
   iValue : integer;
begin
     // returns; 160 if at min
     //           10 if at max
     if (rValue = rMin) then
        Result := 161
     else
         if (rValue = rMax) then
            Result := 10
         else
         begin
              iValue := Round(150 * (rValue - rMin) / (rMax - rMin));
              if (iValue = 0) then
                 iValue := 1;
              Result := 160 - iValue;
         end;

     if (rValue = 0) then
        Result := 160;
end;

procedure TBrowseAnnealingOutputForm.InitGraph;
var
   ARectangle : TRect;
begin
     with Image1.Canvas do
     begin
          // paint canvas white
          ARectangle := Rect(0,0,Width-1,Height-1);
          Brush.Color := clWhite;
          Brush.Style := bsSolid;
          FillRect(ARectangle);

          // write labels
          TextOut(10,165,'Score');
          TextOut(110,165,'Cost');
          TextOut(210,165,'Connectivity');
          TextOut(310,165,'Penalty');
     end;
end;

procedure TBrowseAnnealingOutputForm.UpdateGraph;
var
   rTotal, rCost, rConnectivity, rPenalty : extended;
   ARectangle : TRect;
begin
     // read objective function values from row (iUpdateMap) and write to graph
     rTotal := StrToFloat(ObjectiveChild.AGrid.Cells[3,iUpdateMap]);
     rCost := StrToFloat(ObjectiveChild.AGrid.Cells[5,iUpdateMap]);
     rConnectivity := StrToFloat(ObjectiveChild.AGrid.Cells[6,iUpdateMap]);
     rPenalty := StrToFloat(ObjectiveChild.AGrid.Cells[7,iUpdateMap]);

     with Image1.Canvas do
     begin
          // paint score bar section of canvas white
          ARectangle := Rect(10,10,350,160);
          Brush.Color := clWhite;
          Brush.Style := bsSolid;
          FillRect(ARectangle);

          // draw score bars from 10 to 110 pixels
          // Rect(ALeft, ATop, ARight, ABottom: Integer)
          Brush.Color := clBlue;
          Brush.Style := bsSolid;
          // score
          ARectangle := Rect(10,ValueToTopCoord(rTotal,rTotalMax,rTotalMin),50,160);
          FillRect(ARectangle);
          // cost
          ARectangle := Rect(110,ValueToTopCoord(rCost,rCostMax,rCostMin),150,160);
          FillRect(ARectangle);
          // connectivity
          ARectangle := Rect(210,ValueToTopCoord(rConnectivity,rConnectivityMax,rConnectivityMin),250,160);
          FillRect(ARectangle);
          // penalty
          ARectangle := Rect(310,ValueToTopCoord(rPenalty,rPenaltyMax,rPenaltyMin),350,160);
          FillRect(ARectangle);
     end;
end;

procedure TBrowseAnnealingOutputForm.UpdateAnnealingStep;
begin
     Timer1.Enabled := False;
     if fForward then
     begin
          Inc(iUpdateMap);

          if (iUpdateMap >= ObjectiveChild.aGrid.RowCount-1) then
             LabelIterations.Caption := 'Finished'
          else
              LabelIterations.Caption := 'Iteration ' + IntToStr(iUpdateMap) + ' of ' + IntToStr(ObjectiveChild.aGrid.RowCount-1);
     end
     else
     begin
          if (iUpdateMap > 1) then
             Dec(iUpdateMap);

          if (iUpdateMap = 1) then
             LabelIterations.Caption := 'Start'
          else
              LabelIterations.Caption := 'Iteration ' + IntToStr(iUpdateMap) + ' of ' + IntToStr(ObjectiveChild.aGrid.RowCount-1);
     end;

     ScrollBarIteration.Position := iUpdateMap;

     if (iUpdateMap < ObjectiveChild.aGrid.RowCount) then
     begin
          // display objective function values in graph
          // display current step in GIS
          UpdateGraph;
          //if fSinglePUStep then
          //   UpdateMapSingleStep
          //else
          UpdateMap;

          Timer1.Enabled := True;
     end;
end;

procedure TBrowseAnnealingOutputForm.InitBrowser;
var
   iNumItns, iSaveAnnealingTrace, iAnnealingTraceRows, iNumReps, iCount : integer;
   fForceParameters : boolean;
   rTotal, rCost, rConnectivity, rPenalty : extended;
begin
     fZonesChild := False;
     fObjectiveChild := False;
     rTotalMin := 1000000;
     rTotalMax := 0;
     rCostMin := 1000000;
     rCostMax := 0;
     rConnectivityMin := 1000000;
     rConnectivityMax := 0;
     rPenaltyMin := 1000000;
     rPenaltyMax := 0;
     iUpdateMap := 0;
     fForward := True;
     iLastSingleStep := -1;
     iLastSingleStepStatus := -1;

     if fZonesChild then
        ZonesChild.Free;

     if fObjectiveChild then
        ObjectiveChild.Free;

     MarxanInterfaceForm.InputDat.Items.LoadFromFile(MarxanInterfaceForm.EditMarxanDatabasePath.Text);

     // see if files exist
     iNumItns := MarxanInterfaceForm.ReturnMarxanIntParameter('NUMITNS');
     iSaveAnnealingTrace := MarxanInterfaceForm.ReturnMarxanIntParameter('SAVEANNEALINGTRACE');
     iAnnealingTraceRows := MarxanInterfaceForm.ReturnMarxanIntParameter('ANNEALINGTRACEROWS');
     iNumReps := MarxanInterfaceForm.ReturnMarxanIntParameter('NUMREPS');

     fSinglePUStep := (iNumItns = iAnnealingTraceRows);

     if (iSaveAnnealingTrace = 3) then
     begin
          // output_anneal_zones00001.csv
          sZonesFileName := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
                            MarxanInterfaceForm.ReturnMarxanParameter('OUTPUTDIR') +
                            '\' +
                            MarxanInterfaceForm.ReturnMarxanParameter('SCENNAME') +
                            '_anneal_zones' + PadInt(iSolutionToBrowse,5) +
                            MarxanInterfaceForm.ReturnMarxanOutputFileExt('SAVEANNEALINGTRACE');
          // output_anneal_objective00001.csv
          sObjectiveFileName := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
                                MarxanInterfaceForm.ReturnMarxanParameter('OUTPUTDIR') +
                                '\' +
                                MarxanInterfaceForm.ReturnMarxanParameter('SCENNAME') +
                                '_anneal_objective' + PadInt(iSolutionToBrowse,5) +
                                MarxanInterfaceForm.ReturnMarxanOutputFileExt('SAVEANNEALINGTRACE');

         if fileexists(sZonesFileName)
         and fileexists(sObjectiveFileName) then
         begin
              fForceParameters := False;

              SCPForm.CreateHiddenCSVChild(sZonesFileName,0);
              ZonesChild := TCSVChild(SCPForm.ReturnNamedChild(sZonesFileName));
              SCPForm.CreateHiddenCSVChild(sObjectiveFileName,0);
              ObjectiveChild := TCSVChild(SCPForm.ReturnNamedChild(sObjectiveFileName));
              fZonesChild := True;
              fObjectiveChild := True;

              // parse objective file and find max and min
              // total D
              // cost F
              // connectivity G
              // penalty H

              for iCount := 1 to (ObjectiveChild.AGrid.RowCount-1) do
              begin
                   rTotal := StrToFloat(ObjectiveChild.AGrid.Cells[3,iCount]);
                   if (rTotal < rTotalMin) then
                      rTotalMin := rTotal;
                   if (rTotal > rTotalMax) then
                      rTotalMax := rTotal;

                   rCost := StrToFloat(ObjectiveChild.AGrid.Cells[5,iCount]);
                   if (rCost < rCostMin) then
                      rCostMin := rCost;
                   if (rCost > rCostMax) then
                      rCostMax := rCost;

                   rConnectivity := StrToFloat(ObjectiveChild.AGrid.Cells[6,iCount]);
                   if (rConnectivity < rConnectivityMin) then
                      rConnectivityMin := rConnectivity;
                   if (rConnectivity > rConnectivityMax) then
                      rConnectivityMax := rConnectivity;

                   rPenalty := StrToFloat(ObjectiveChild.AGrid.Cells[7,iCount]);
                   if (rPenalty < rPenaltyMin) then
                      rPenaltyMin := rPenalty;
                   if (rPenalty > rPenaltyMax) then
                      rPenaltyMax := rPenalty;
              end;

              // detect correct GIS layer to draw to
              iUpdateLayer := -1;
              for iCount := 0 to (GIS_Child.Map1.NumLayers-1) do
                  if (GIS_Child.Map1.LayerName[iCount] = GIS_Child.sPuFileName) then
                     iUpdateLayer := iCount;
              sf := IShapefile(GIS_Child.Map1.GetObject[GIS_Child.Map1.LayerHandle[iUpdateLayer]]);

              ScrollBarIteration.Position := 1;
              ScrollBarIteration.Min := 1;
              ScrollBarIteration.Max := ObjectiveChild.aGrid.RowCount-1;

              InitGraph;
              //if fSinglePUStep then
              //   InitMap;
              UpdateAnnealingStep;
         end
         else
             fForceParameters := True;
     end
     else
         fForceParameters := True;

     if fForceParameters then
     begin
          // force parameters
          if (mrYes = MessageDlg('Marxan parameters not set to browse annealing output. Do you to set the parameters? (you will be able to use this function after you next run Marxan)',
              mtConfirmation,[mbYes,mbNo],0)) then
             ForceParamters;

          Timer2.Enabled := True;
     end;
end;

procedure TBrowseAnnealingOutputForm.ForceParamters;
begin
     MarxanInterfaceForm.DeleteInputParameter('SAVEANNEALINGTRACE');
     MarxanInterfaceForm.AddInputParameter('SAVEANNEALINGTRACE 3');
     MarxanInterfaceForm.DeleteInputParameter('ANNEALINGTRACEROWS');
     MarxanInterfaceForm.AddInputParameter('ANNEALINGTRACEROWS 1000');
end;

procedure TBrowseAnnealingOutputForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
     if fZonesChild then
        ZonesChild.Free;

     if fObjectiveChild then
        ObjectiveChild.Free;
end;

procedure TBrowseAnnealingOutputForm.Timer1Timer(Sender: TObject);
begin
     UpdateAnnealingStep;
end;

procedure TBrowseAnnealingOutputForm.BitBtn1Click(Sender: TObject);
begin
     Timer1.Enabled := False;
end;

procedure TBrowseAnnealingOutputForm.ScrollBar1Change(Sender: TObject);
begin
     Timer1.Interval := 1 + Round((100 - ScrollBar1.Position)/100*2000);

     // Position 0 Interval 2001
     // Position 100 Interval 1
end;

procedure TBrowseAnnealingOutputForm.ScrollBarIterationChange(
  Sender: TObject);
begin
     iUpdateMap := ScrollBarIteration.Position;

     if (iUpdateMap < (ObjectiveChild.aGrid.RowCount-1)) then
        Timer1.Enabled := True;
end;

procedure TBrowseAnnealingOutputForm.SpeedButton1Click(Sender: TObject);
begin
     Timer1.Enabled := False;
end;

procedure TBrowseAnnealingOutputForm.SpeedButton2Click(Sender: TObject);
begin
     Timer1.Enabled := True;
end;

procedure TBrowseAnnealingOutputForm.SpeedButton3Click(Sender: TObject);
begin
     fForward := True;
     Timer1.Enabled := True;
end;

procedure TBrowseAnnealingOutputForm.SpeedButton4Click(Sender: TObject);
begin
     fForward := False;
     Timer1.Enabled := True;
end;

procedure TBrowseAnnealingOutputForm.Timer2Timer(Sender: TObject);
begin
     ModalResult := mrOk;
end;

procedure TBrowseAnnealingOutputForm.InitSolutionCount;
var
   iCount : integer;
begin
     ComboMarxanRun.Items.Clear;
     for iCount := 1 to iNumberOfRuns do
         ComboMarxanRun.Items.Add('Solution ' + IntToStr(iCount));
     ComboMarxanRun.Text := ComboMarxanRun.Items.Strings[0];    
end;

procedure TBrowseAnnealingOutputForm.ComboMarxanRunChange(Sender: TObject);
var
   iPos : integer;
begin
     iPos := ComboMarxanRun.Items.IndexOf(ComboMarxanRun.Text);

     if (iPos > -1) then
        if ((iPos + 1) <> iSolutionToBrowse) then
        begin
             iSolutionToBrowse := iPos + 1;

             InitBrowser;
        end;
end;

procedure TBrowseAnnealingOutputForm.FormCreate(Sender: TObject);
begin
     InitSolutionCount;
     iSolutionToBrowse := 1;
     InitBrowser;
end;

end.
