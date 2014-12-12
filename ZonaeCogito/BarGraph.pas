unit BarGraph;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, ds, ComCtrls;

type
  TBarGraphForm = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    btnSave: TButton;
    Image1: TImage;
    SaveDialog1: TSaveDialog;
    Timer1: TTimer;
    UpDown1: TUpDown;
    LabelPageNumber: TLabel;
    UpDown2: TUpDown;
    LabelObjectsPerPage: TLabel;
    Label1: TLabel;
    ComboBoxSortBy: TComboBox;
    Label2: TLabel;
    ComboBoxYAxisScale: TComboBox;
    CheckUseName: TCheckBox;
    CheckFractions: TCheckBox;
    UpDown3: TUpDown;
    LabelRunNumber: TLabel;
    procedure InitGraph(const iGraphType : integer);
    procedure BarGraphMissingValues;
    procedure BarGraphMissingValues2;
    procedure BarGraphConfigurations;
    procedure BarGraphSummary;
    procedure PlotMissingValues(rMax : extended;TargArray, AmntHldArray, NameArray, IdArray, ReservedArray, TotalArray : Array_t);
    procedure PlotConfigurations(rMax : extended;
                                 IRArray,TIRArray,TAArray,AIMPAArray,MTAArray,IdArray,NameArray : Array_t;
                                 const fDisplayInitialReserve : boolean);
    procedure PlotSummary(rMax : extended;ScoreArray, CostArray, BoundaryLengthArray, PenaltyArray : Array_t);
    procedure btnSaveClick(Sender: TObject);
    procedure ResizeTheImage;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown2Click(Sender: TObject; Button: TUDBtnType);
    procedure RefreshTheGraph;
    procedure CheckUseNameClick(Sender: TObject);
    procedure CheckFractionsClick(Sender: TObject);
    procedure BarGrapheFlowTargByRuns;
    procedure BarGrapheFlowTargByRuns_best;
    procedure PloteFlowTargByRuns(rMax : extended; TargArray,AmntHldArray, NameArray, TotalArray : Array_t);
    procedure UpDown3Click(Sender: TObject; Button: TUDBtnType);
  private
    { Private declarations }
  public
    { Public declarations }
    fAutoClose : boolean;
    iNumberOfPages, iPageNumber, iObjectsPerPage, iRunToDisplay : integer
  end;


var
  BarGraphForm: TBarGraphForm;
  iBarGraphType : integer;
  sReportConfigurationsFileName : string;
  

implementation

uses Marxan_interface, miscellaneous, Math, eFlows, SCP_Main;

{$R *.DFM}

function Return_MVBEST_Filename : string;
var
   sSAVETARGMET, sFileExtension : string;
begin
     sSAVETARGMET := MarxanInterfaceForm.ReturnMarxanParameter('SAVETARGMET');
     if (sSAVETARGMET = '3') then
        sFileExtension := '.csv'
     else
         sFileExtension := '.txt';

     Result := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
               MarxanInterfaceForm.ReturnMarxanParameter('OUTPUTDIR') + '\' +
               MarxanInterfaceForm.ReturnMarxanParameter('SCENNAME') +
               '_mvbest' +
               sFileExtension;
end;

function Return_MV_Filename(const iRun : integer) : string;
var
   sSAVETARGMET, sFileExtension : string;
begin
     sSAVETARGMET := MarxanInterfaceForm.ReturnMarxanParameter('SAVETARGMET');
     if (sSAVETARGMET = '3') then
        sFileExtension := '.csv'
     else
         sFileExtension := '.txt';

     Result := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
               MarxanInterfaceForm.ReturnMarxanParameter('OUTPUTDIR') + '\' +
               MarxanInterfaceForm.ReturnMarxanParameter('SCENNAME') +
               '_mv' + PadInt(iRun,5) +
               sFileExtension;
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

function Return_Configuration_Filename : string;
var
   sSAVETARGMET, sFileExtension : string;
begin
     Result := sReportConfigurationsFileName;
end;

function Return_TotalArea_Filename : string;
begin
     if fMarZone then
        Result := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
                  'MarZoneTotalAreas.csv'
     else
         Result := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
                   'MarOptTotalAreas.csv';
end;

procedure TBarGraphForm.ResizeTheImage;
begin
     try
        case iBarGraphType of
             1 : BarGraphMissingValues;
             2 : BarGraphConfigurations;
             3 : BarGraphSummary;
             4 : BarGrapheFlowTargByRuns;
             5 : BarGraphMissingValues2;
             6 : BarGrapheFlowTargByRuns_Best;
        end;

     except
           MessageDlg('Exception in TBarGraphForm.ResizeTheImage',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TBarGraphForm.RefreshTheGraph;
begin
     try
        case iBarGraphType of
             1 : begin
                      BarGraphForm.Caption := 'Bar Graph Missing Values';
                      if (iNumberOfFeatures < iObjectsPerPage) then
                      begin
                           iNumberOfPages := 1;
                           iObjectsPerPage := iNumberOfFeatures;
                      end
                      else
                          iNumberOfPages := iNumberOfFeatures div iObjectsPerPage;
                      UpDown2.Max := iNumberOfFeatures;
                      LabelObjectsPerPage.Caption := IntToStr(iObjectsPerPage) + ' features per page';
                 end;
             2 : begin
                      BarGraphForm.Caption := 'Bar Graph Report Configurations';
                      if (iNumberOfFeatures < iObjectsPerPage) then
                      begin
                           iNumberOfPages := 1;
                           iObjectsPerPage := iNumberOfFeatures;
                      end
                      else
                          iNumberOfPages := iNumberOfFeatures div iObjectsPerPage;
                      UpDown2.Max := iNumberOfFeatures;
                      LabelObjectsPerPage.Caption := IntToStr(iObjectsPerPage) + ' features per page';
                      if (iNumberOfPages = 1) then
                         iObjectsPerPage := iNumberOfFeatures;
                 end;
             3 : begin
                      BarGraphForm.Caption := 'Bar Graph Summary File';
                      CheckFractions.Visible := False;
                      CheckUseName.Visible := False;

                      if (iNumberOfRuns < iObjectsPerPage) then
                      begin
                           iNumberOfPages := 1;
                           iObjectsPerPage := iNumberOfRuns;
                      end
                      else
                          iNumberOfPages := iNumberOfRuns div iObjectsPerPage;
                      UpDown2.Max := iNumberOfRuns;
                      LabelObjectsPerPage.Caption := IntToStr(iObjectsPerPage) + ' runs per page';
                      if (iNumberOfPages = 1) then
                         iObjectsPerPage := iNumberOfRuns;
                 end;
             4 : begin
                      BarGraphForm.Caption := 'Bar Graph eFlows Amount of Habitat';
                      ieFlowsNoOfSpecies := eFlowsForm.ReturnNoOfSpecies;
                      ieFlowsTotalRun := eFlowsForm.ReturnTotalRun;
                      if (ieFlowsNoOfSpecies < iObjectsPerPage) then
                      begin
                           iNumberOfPages := 1;
                           iObjectsPerPage := ieFlowsNoOfSpecies;
                      end
                      else
                          iNumberOfPages := ieFlowsNoOfSpecies div iObjectsPerPage;
                      UpDown2.Max := ieFlowsNoOfSpecies;
                      LabelObjectsPerPage.Caption := IntToStr(iObjectsPerPage) + ' species per page';
                      UpDown3.Max := ieFlowsTotalRun;
                      UpDown3.Visible := True;
                      LabelRunNumber.Caption := 'Run ' + IntToStr(iRunToDisplay);
                      LabelRunNumber.Visible := True;
                 end;
             5 : begin
                      BarGraphForm.Caption := 'Bar Graph Missing Values';
                      if (iNumberOfFeatures < iObjectsPerPage) then
                      begin
                           iNumberOfPages := 1;
                           iObjectsPerPage := iNumberOfFeatures;
                      end
                      else
                          iNumberOfPages := iNumberOfFeatures div iObjectsPerPage;
                      UpDown2.Max := iNumberOfFeatures;
                      LabelObjectsPerPage.Caption := IntToStr(iObjectsPerPage) + ' features per page';

                      iSolutionCount := ReturnSolutionCount(MarxanInterfaceForm.EditMarxanDatabasePath.Text);
                      UpDown3.Max := iSolutionCount;
                      UpDown3.Visible := True;
                      LabelRunNumber.Caption := 'Run ' + IntToStr(iRunToDisplay);
                      LabelRunNumber.Visible := True;
                 end;
             6 : begin
                      BarGraphForm.Caption := 'Bar Graph eFlows Best Solution Amount of Habitat';
                      ieFlowsNoOfSpecies := eFlowsForm.ReturnNoOfSpecies;
                      ieFlowsTotalRun := eFlowsForm.ReturnTotalRun;
                      if (ieFlowsNoOfSpecies < iObjectsPerPage) then
                      begin
                           iNumberOfPages := 1;
                           iObjectsPerPage := ieFlowsNoOfSpecies;
                      end
                      else
                          iNumberOfPages := ieFlowsNoOfSpecies div iObjectsPerPage;
                      UpDown2.Max := ieFlowsNoOfSpecies;
                      LabelObjectsPerPage.Caption := IntToStr(iObjectsPerPage) + ' species per page';
                      UpDown3.Visible := False;
                      LabelRunNumber.Visible := False;
                 end;
        end;

        if (iNumberOfPages > 1) then
        begin
             LabelPageNumber.Visible := True;
             LabelObjectsPerPage.Visible := True;
             UpDown1.Max := iNumberOfPages;
             LabelPageNumber.Caption := 'Page ' + IntToStr(iPageNumber) + ' of ' + IntToStr(iNumberOfPages);
             UpDown1.Visible := True;
             UpDown2.Position := iObjectsPerPage;
             UpDown2.Visible := True;
        end;

        ResizeTheImage;

     except
           MessageDlg('Exception in TBarGraphForm.RefreshTheGraph',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TBarGraphForm.InitGraph(const iGraphType : integer);
begin
     try
        iBarGraphType := iGraphType;
        iNumberOfPages := 1;
        iPageNumber := 1;
        iObjectsPerPage := 5;
        if (iBarGraphType = 6) then
           iRunToDisplay := eFlowsForm.ReturnBestRun_HH
        else
            iRunToDisplay := 1;

        RefreshTheGraph;

     except
           MessageDlg('Exception in TBarGraphForm.InitGraph',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TBarGraphForm.PlotMissingValues(rMax : extended;
                                          TargArray, AmntHldArray, NameArray, IdArray, ReservedArray, TotalArray : Array_t);
var
   ARectangle : TRect;
   iCount, iSegments, iSegmentSize, iRectangleTop, iRectangleLeft, iSpace, iHeight, iGraphWidth,
   iLeft, iFeatureIndex, iFeatureID : integer;
   rTarg, rAmntHld, rReserved, rTotal : extended;
   sTextLabel : string;
   sFeatureName255 : str255;

   function ValueToHeight(const rValue : extended) : integer;
   var
      iPixels : integer;
   begin
        // rMax gives iSpace-1
        // 0 gives Height-iSpace-1        
        if CheckFractions.Checked then
        begin
             if (rTotal > 0) then
                iPixels := Floor((Image1.Height-iSpace-iSpace)/rTotal*rValue*0.9)
             else
                 iPixels := 0;
        end
        else
        begin
             if (rMax > 0) then
                iPixels := Floor((Image1.Height-iSpace-iSpace)/rMax*rValue*0.9)
             else
                 iPixels := 0;
        end;

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

             iSegments := Round(iObjectsPerPage*4) + 1;
             iGraphWidth := Width - iSpace - iSpace;
             iSegmentSize := Floor(iGraphWidth/iSegments);

             // Y axis labels and lines
             if CheckFractions.Checked then
             begin
                  rTotal := 1;
                  Y_Axis_Label_Line(0);
                  Y_Axis_Label_Line(0.25);
                  Y_Axis_Label_Line(0.5);
                  Y_Axis_Label_Line(0.75);
                  Y_Axis_Label_Line(1);
             end
             else
             begin
                  Y_Axis_Label_Line(0);
                  Y_Axis_Label_Line(rMax*0.25);
                  Y_Axis_Label_Line(rMax*0.5);
                  Y_Axis_Label_Line(rMax*0.75);
                  Y_Axis_Label_Line(rMax);
             end;

             // key for X axis
             // target
             sTextLabel := 'Target';
             Brush.Color := clWhite;
             iLeft := iSpace + Floor(iGraphWidth * 0.25) - (TextWidth(sTextLabel) div 2);
             TextOut(iLeft,
                     (iSpace div 2) - (TextHeight(sTextLabel) div 2) - 1,
                     sTextLabel);
             ARectangle := Rect(iLeft - 25,
                                (iSpace div 2) - 1 - 10,
                                iLeft - 5,
                                (iSpace div 2) - 1 + 10);
             Brush.Color := clNavy;
             Rectangle(ARectangle);
             // amount held
             sTextLabel := 'Amount Held';
             Brush.Color := clWhite;
             iLeft := iSpace + Floor(iGraphWidth * 0.5) - (TextWidth(sTextLabel) div 2);
             TextOut(iLeft,
                     (iSpace div 2) - (TextHeight(sTextLabel) div 2) - 1,
                     sTextLabel);
             ARectangle := Rect(iLeft - 25,
                                (iSpace div 2) - 1 - 10,
                                iLeft - 5,
                                (iSpace div 2) - 1 + 10);
             Brush.Color := clGreen;
             Rectangle(ARectangle);
             // amount held
             sTextLabel := 'Existing Reserve';
             Brush.Color := clWhite;
             iLeft := iSpace + Floor(iGraphWidth * 0.75) - (TextWidth(sTextLabel) div 2);
             TextOut(iLeft,
                     (iSpace div 2) - (TextHeight(sTextLabel) div 2) - 1,
                     sTextLabel);
             ARectangle := Rect(iLeft - 25,
                                (iSpace div 2) - 1 - 10,
                                iLeft - 5,
                                (iSpace div 2) - 1 + 10);
             Brush.Color := clMaroon;
             Rectangle(ARectangle);

             for iCount := 1 to iObjectsPerPage do
             begin
                  iFeatureIndex := ((iPageNumber-1) * iObjectsPerPage) + iCount;
                  if (iFeatureIndex <= iNumberOfFeatures) then
                  begin
                       iRectangleLeft := iSpace + ((iCount-1)*iSegmentSize*4)+ iSegmentSize;
                       if (rMax > 0) then
                       begin
                            TotalArray.rtnValue(iFeatureIndex,@rTotal);

                            // draw target rectangle
                            TargArray.rtnValue(iFeatureIndex,@rTarg);
                            iRectangleTop := ValueToHeight(rTarg);
                            ARectangle := Rect(iRectangleLeft,iRectangleTop,iRectangleLeft+iSegmentSize,Image1.Height-iSpace);
                            Brush.Color := clNavy;
                            Rectangle(ARectangle);

                            // draw amount held rectangle
                            AmntHldArray.rtnValue(iFeatureIndex,@rAmntHld);
                            iRectangleTop := ValueToHeight(rAmntHld);
                            ARectangle := Rect(iRectangleLeft+iSegmentSize,iRectangleTop,iRectangleLeft+iSegmentSize+iSegmentSize,Image1.Height-iSpace);
                            Brush.Color := clGreen;
                            Rectangle(ARectangle);

                            // draw existing reserve rectangle
                            ReservedArray.rtnValue(iFeatureIndex,@rReserved);
                            iRectangleTop := ValueToHeight(rReserved);
                            ARectangle := Rect(iRectangleLeft+iSegmentSize+iSegmentSize,iRectangleTop,iRectangleLeft+iSegmentSize+iSegmentSize+iSegmentSize,Image1.Height-iSpace);
                            Brush.Color := clMaroon;
                            Rectangle(ARectangle);
                       end;

                       // label under bars
                       if CheckUseName.Checked then
                       begin
                            NameArray.rtnValue(iFeatureIndex,@sFeatureName255);
                            sTextLabel := sFeatureName255;
                       end
                       else
                       begin
                            IdArray.rtnValue(iFeatureIndex,@iFeatureID);
                            sTextLabel := IntToStr(iFeatureID);
                       end;
                       Brush.Color := clWhite;
                       TextOut(iRectangleLeft+iSegmentSize-(TextWidth(sTextLabel) div 2),
                               Image1.Height-(iSpace div 2) - (TextHeight(sTextLabel) div 2) - 1,
                               sTextLabel);
                  end;
             end;
        end;

     except
           MessageDlg('Exception in TBarGraphForm.PlotMissingValues',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TBarGraphForm.PlotConfigurations(rMax : extended;
                                           IRArray,TIRArray,TAArray,AIMPAArray,MTAArray,IdArray,NameArray : Array_t;
                                           const fDisplayInitialReserve : boolean);
var
   ARectangle : TRect;
   iCount, iSegments, iSegmentSize, iRectangleTop, iRectangleLeft, iSpace, iHeight, iGraphWidth,
   iLeft, iFeatureIndex, iFeatureID : integer;
   rIR, rTIR, rTA, rAIMPA, rMTA, rTotal : extended;
   sTextLabel : string;
   sFeatureName255 : str255;

   function ValueToHeight(const rValue : extended) : integer;
   var
      iPixels : integer;
   begin
        // rMax gives iSpace-1
        // 0 gives Height-iSpace-1
        if CheckFractions.Checked then
        begin
             if (rTotal > 0) then
                iPixels := Floor((Image1.Height-iSpace-iSpace)/rTotal*rValue*0.9)
             else
                 iPixels := 0;
        end
        else
        begin
             if (rMax > 0) then
                iPixels := Floor((Image1.Height-iSpace-iSpace)/rMax*rValue*0.9)
             else
                 iPixels := 0;
        end;
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


             if CheckFractions.Checked then
             begin
                  iSegments := Round(iObjectsPerPage*5) + 1;
                  iGraphWidth := Width - iSpace - iSpace;
                  iSegmentSize := Floor(iGraphWidth/iSegments);
                  // Y axis labels and lines
                  rTotal := 1;
                  Y_Axis_Label_Line(0);
                  Y_Axis_Label_Line(0.25);
                  Y_Axis_Label_Line(0.5);
                  Y_Axis_Label_Line(0.75);
                  Y_Axis_Label_Line(1);
                  // key for X axis
                  DrawKey('Initial Reserved',clMaroon,0.2);
                  DrawKey('Target Amount',clOlive,0.4);
                  DrawKey('Amount in MPA',clNavy,0.6);
                  DrawKey('Missed Target Amount',clPurple,0.83);
             end
             else
             begin
                  iSegments := Round(iObjectsPerPage*6) + 1;
                  iGraphWidth := Width - iSpace - iSpace;
                  iSegmentSize := Floor(iGraphWidth/iSegments);
                  // Y axis labels and lines
                  Y_Axis_Label_Line(0);
                  Y_Axis_Label_Line(rMax*0.25);
                  Y_Axis_Label_Line(rMax*0.5);
                  Y_Axis_Label_Line(rMax*0.75);
                  Y_Axis_Label_Line(rMax);
                  // key for X axis
                  DrawKey('Initial Reserved',clMaroon,0.167);
                  DrawKey('Total in region',clGreen,0.333);
                  DrawKey('Target Amount',clOlive,0.5);
                  DrawKey('Amount in MPA',clNavy,0.667);
                  DrawKey('Missed Target Amount',clPurple,0.833);
             end;


             for iCount := 1 to iObjectsPerPage do
             begin
                  iFeatureIndex := ((iPageNumber-1) * iObjectsPerPage) + iCount;
                  if (iFeatureIndex <= iNumberOfFeatures) then
                  begin
                       if CheckFractions.Checked then
                          iRectangleLeft := iSpace + ((iCount-1)*iSegmentSize*5)+ iSegmentSize
                       else
                           iRectangleLeft := iSpace + ((iCount-1)*iSegmentSize*6)+ iSegmentSize;
                           
                       if (rMax > 0) then
                       begin
                            TIRArray.rtnValue(iFeatureIndex,@rTotal);

                            // draw Initial Reserved rectangle
                            IRArray.rtnValue(iFeatureIndex,@rIR);
                            iRectangleTop := ValueToHeight(rIR);
                            ARectangle := Rect(iRectangleLeft,iRectangleTop,iRectangleLeft+iSegmentSize,Image1.Height-iSpace);
                            Brush.Color := clMaroon;
                            Rectangle(ARectangle);
                            if CheckFractions.Checked then
                            begin
                                 // draw Target Amount rectangle
                                 TAArray.rtnValue(iFeatureIndex,@rTA);
                                 iRectangleTop := ValueToHeight(rTA);
                                 ARectangle := Rect(iRectangleLeft+iSegmentSize,iRectangleTop,iRectangleLeft+iSegmentSize+iSegmentSize,Image1.Height-iSpace);
                                 Brush.Color := clOlive;
                                 Rectangle(ARectangle);
                                 // draw Amount in MPA rectangle
                                 AIMPAArray.rtnValue(iFeatureIndex,@rAIMPA);
                                 iRectangleTop := ValueToHeight(rAIMPA);
                                 ARectangle := Rect(iRectangleLeft+iSegmentSize+iSegmentSize,iRectangleTop,iRectangleLeft+iSegmentSize+iSegmentSize+iSegmentSize,Image1.Height-iSpace);
                                 Brush.Color := clNavy;
                                 Rectangle(ARectangle);
                                 // draw Missed Target Amount rectangle
                                 MTAArray.rtnValue(iFeatureIndex,@rMTA);
                                 iRectangleTop := ValueToHeight(rMTA);
                                 ARectangle := Rect(iRectangleLeft+iSegmentSize+iSegmentSize+iSegmentSize,iRectangleTop,iRectangleLeft+iSegmentSize+iSegmentSize+iSegmentSize+iSegmentSize,Image1.Height-iSpace);
                                 Brush.Color := clPurple;
                                 Rectangle(ARectangle);
                            end
                            else
                            begin
                                 // draw Total in region rectangle
                                 TIRArray.rtnValue(iFeatureIndex,@rTIR);
                                 iRectangleTop := ValueToHeight(rTIR);
                                 ARectangle := Rect(iRectangleLeft+iSegmentSize,iRectangleTop,iRectangleLeft+iSegmentSize+iSegmentSize,Image1.Height-iSpace);
                                 Brush.Color := clGreen;
                                 Rectangle(ARectangle);
                                 // draw Target Amount rectangle
                                 TAArray.rtnValue(iFeatureIndex,@rTA);
                                 iRectangleTop := ValueToHeight(rTA);
                                 ARectangle := Rect(iRectangleLeft+iSegmentSize+iSegmentSize,iRectangleTop,iRectangleLeft+iSegmentSize+iSegmentSize+iSegmentSize,Image1.Height-iSpace);
                                 Brush.Color := clOlive;
                                 Rectangle(ARectangle);
                                 // draw Amount in MPA rectangle
                                 AIMPAArray.rtnValue(iFeatureIndex,@rAIMPA);
                                 iRectangleTop := ValueToHeight(rAIMPA);
                                 ARectangle := Rect(iRectangleLeft+iSegmentSize+iSegmentSize+iSegmentSize,iRectangleTop,iRectangleLeft+iSegmentSize+iSegmentSize+iSegmentSize+iSegmentSize,Image1.Height-iSpace);
                                 Brush.Color := clNavy;
                                 Rectangle(ARectangle);
                                 // draw Missed Target Amount rectangle
                                 MTAArray.rtnValue(iFeatureIndex,@rMTA);
                                 iRectangleTop := ValueToHeight(rMTA);
                                 ARectangle := Rect(iRectangleLeft+iSegmentSize+iSegmentSize+iSegmentSize+iSegmentSize,iRectangleTop,iRectangleLeft+iSegmentSize+iSegmentSize+iSegmentSize+iSegmentSize+iSegmentSize,Image1.Height-iSpace);
                                 Brush.Color := clPurple;
                                 Rectangle(ARectangle);
                            end;
                       end;

                       // label under bars
                       if CheckUseName.Checked then
                       begin
                            NameArray.rtnValue(iFeatureIndex,@sFeatureName255);
                            sTextLabel := sFeatureName255;
                       end
                       else
                       begin
                            IdArray.rtnValue(iFeatureIndex,@iFeatureID);
                            sTextLabel := IntToStr(iFeatureID);
                       end;
                       Brush.Color := clWhite;
                       TextOut(iRectangleLeft+iSegmentSize+iSegmentSize+iSegmentSize-(TextWidth(sTextLabel) div 2),
                               Image1.Height-(iSpace div 2) - (TextHeight(sTextLabel) div 2) - 1,
                               sTextLabel);
                  end;
             end;
        end;

     except
           MessageDlg('Exception in TBarGraphForm.PlotConfigurations',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TBarGraphForm.PlotSummary(rMax : extended;ScoreArray, CostArray, BoundaryLengthArray, PenaltyArray : Array_t);
var
   ARectangle : TRect;
   iCount, iSegments, iSegmentSize, iRectangleTop, iRectangleLeft, iSpace, iHeight, iGraphWidth, iLeft, iFeatureIndex : integer;
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

             iSegments := Round(iObjectsPerPage*5) + 1;
             iGraphWidth := Width - iSpace - iSpace;
             iSegmentSize := Floor(iGraphWidth/iSegments);

             // Y axis labels and lines
             Y_Axis_Label_Line(0);
             Y_Axis_Label_Line(rMax*0.25);
             Y_Axis_Label_Line(rMax*0.5);
             Y_Axis_Label_Line(rMax*0.75);
             Y_Axis_Label_Line(rMax);

             // key for X axis
             DrawKey('Score',clMaroon,0.2);
             DrawKey('Cost',clGreen,0.4);
             DrawKey('Boundary Length',clOlive,0.6);
             DrawKey('Penalty',clNavy,0.8);

             for iCount := 1 to iObjectsPerPage do
             begin
                  iFeatureIndex := ((iPageNumber-1) * iObjectsPerPage) + iCount;
                  if (iFeatureIndex <= iNumberOfRuns) then
                  begin
                       iRectangleLeft := iSpace + ((iCount-1)*iSegmentSize*5)+ iSegmentSize;
                       if (rMax > 0) then
                       begin
                            // draw Score rectangle
                            ScoreArray.rtnValue(iFeatureIndex,@rScore);
                            iRectangleTop := ValueToHeight(rScore);
                            ARectangle := Rect(iRectangleLeft,iRectangleTop,iRectangleLeft+iSegmentSize,Image1.Height-iSpace);
                            Brush.Color := clMaroon;
                            Rectangle(ARectangle);
                            // draw Cost rectangle
                            CostArray.rtnValue(iFeatureIndex,@rCost);
                            iRectangleTop := ValueToHeight(rCost);
                            ARectangle := Rect(iRectangleLeft+iSegmentSize,iRectangleTop,iRectangleLeft+iSegmentSize+iSegmentSize,Image1.Height-iSpace);
                            Brush.Color := clGreen;
                            Rectangle(ARectangle);
                            // draw Boundary Length rectangle
                            BoundaryLengthArray.rtnValue(iFeatureIndex,@rBoundaryLength);
                            iRectangleTop := ValueToHeight(rBoundaryLength);
                            ARectangle := Rect(iRectangleLeft+iSegmentSize+iSegmentSize,iRectangleTop,iRectangleLeft+iSegmentSize+iSegmentSize+iSegmentSize,Image1.Height-iSpace);
                            Brush.Color := clOlive;
                            Rectangle(ARectangle);
                            // draw Penalty rectangle
                            PenaltyArray.rtnValue(iFeatureIndex,@rPenalty);
                            iRectangleTop := ValueToHeight(rPenalty);
                            ARectangle := Rect(iRectangleLeft+iSegmentSize+iSegmentSize+iSegmentSize,iRectangleTop,iRectangleLeft+iSegmentSize+iSegmentSize+iSegmentSize+iSegmentSize,Image1.Height-iSpace);
                            Brush.Color := clNavy;
                            Rectangle(ARectangle);
                       end;

                       // label under bars
                       sTextLabel := IntToStr(iFeatureIndex);
                       Brush.Color := clWhite;
                       TextOut(iRectangleLeft+iSegmentSize+iSegmentSize-(TextWidth(sTextLabel) div 2),
                               Image1.Height-(iSpace div 2) - (TextHeight(sTextLabel) div 2) - 1,
                               sTextLabel);
                  end;
             end;
        end;

     except
           MessageDlg('Exception in TBarGraphForm.PlotSummary',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TBarGraphForm.PloteFlowTargByRuns(rMax : extended; TargArray, AmntHldArray, NameArray, TotalArray : Array_t);
var
   ARectangle : TRect;
   iCount, iSegments, iSegmentSize, iRectangleTop, iRectangleLeft, iSpace, iHeight, iGraphWidth,
   iLeft, iFeatureIndex, iFeatureID, iLabelY : integer;
   rTarg, rAmntHld, rReserved, rTotal : extended;
   sTextLabel : string;
   sFeatureName255 : str255;
   fLabelsOverlap : boolean;

   function ValueToHeight(const rValue : extended) : integer;
   var
      iPixels : integer;
   begin
        // rMax gives iSpace-1
        // 0 gives Height-iSpace-1        
        if CheckFractions.Checked then
        begin
             if (rTotal > 0) then
                iPixels := Floor((Image1.Height-iSpace-iSpace)/rTotal*rValue*0.9)
             else
                 iPixels := 0;
        end
        else
        begin
             if (rMax > 0) then
                iPixels := Floor((Image1.Height-iSpace-iSpace)/rMax*rValue*0.9)
             else
                 iPixels := 0;
        end;

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

   procedure Y_Axis_Label;
   var
      sLabel : string;
   begin
        with Image1.Canvas do
        begin
             Brush.Color := clWhite;

             Font.Size := 12;
             Font.Style := Font.Style + [fsBold];

             sLabel := 'Habitat Hectares per Species';

             TextOut(10,
                     (iSpace div 2) - (TextHeight(sLabel) div 2) - 1,
                     sLabel);

             Font.Size := 10;
             Font.Style := Font.Style - [fsBold];
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

             iSegments := Round(iObjectsPerPage*3) + 1;
             iGraphWidth := Width - iSpace - iSpace;
             iSegmentSize := Floor(iGraphWidth/iSegments);

             // Y axis labels and lines
             if CheckFractions.Checked then
             begin
                  rTotal := 1;
                  Y_Axis_Label_Line(0);
                  Y_Axis_Label_Line(0.25);
                  Y_Axis_Label_Line(0.5);
                  Y_Axis_Label_Line(0.75);
                  Y_Axis_Label_Line(1);
                  Y_Axis_Label;
             end
             else
             begin
                  Y_Axis_Label_Line(0);
                  Y_Axis_Label_Line(rMax*0.25);
                  Y_Axis_Label_Line(rMax*0.5);
                  Y_Axis_Label_Line(rMax*0.75);
                  Y_Axis_Label_Line(rMax);
                  Y_Axis_Label;
             end;

             // key for X axis
             // target
             sTextLabel := 'target';
             Brush.Color := clWhite;
             iLeft := iSpace + Floor(iGraphWidth * 0.6) - (TextWidth(sTextLabel) div 2);
             TextOut(iLeft,
                     (iSpace div 2) - (TextHeight(sTextLabel) div 2) - 1,
                     sTextLabel);
             ARectangle := Rect(iLeft - 25,
                                (iSpace div 2) - 1 - 10,
                                iLeft - 5,
                                (iSpace div 2) - 1 + 10);
             Brush.Color := clNavy;
             Rectangle(ARectangle);
             // amount held
             sTextLabel := 'ha in solution';
             Brush.Color := clWhite;
             iLeft := iSpace + Floor(iGraphWidth * 0.9) - (TextWidth(sTextLabel) div 2);
             TextOut(iLeft,
                     (iSpace div 2) - (TextHeight(sTextLabel) div 2) - 1,
                     sTextLabel);
             ARectangle := Rect(iLeft - 25,
                                (iSpace div 2) - 1 - 10,
                                iLeft - 5,
                                (iSpace div 2) - 1 + 10);
             Brush.Color := clGreen;
             Rectangle(ARectangle);
             // existing reserve
             (*sTextLabel := 'Existing Reserve';
             Brush.Color := clWhite;
             iLeft := iSpace + Floor(iGraphWidth * 0.75) - (TextWidth(sTextLabel) div 2);
             TextOut(iLeft,
                     (iSpace div 2) - (TextHeight(sTextLabel) div 2) - 1,
                     sTextLabel);
             ARectangle := Rect(iLeft - 25,
                                (iSpace div 2) - 1 - 10,
                                iLeft - 5,
                                (iSpace div 2) - 1 + 10);
             Brush.Color := clMaroon;
             Rectangle(ARectangle);*)

             // detect if labels will overlap
             fLabelsOverlap := False;
             for iCount := 1 to iObjectsPerPage do
             begin
                  iFeatureIndex := ((iPageNumber-1) * iObjectsPerPage) + iCount;
                  if (iFeatureIndex <= ieFlowsNoOfSpecies) then
                  begin
                       if CheckUseName.Checked then
                       begin
                            NameArray.rtnValue(iFeatureIndex,@sFeatureName255);
                            sTextLabel := sFeatureName255;
                       end
                       else
                           sTextLabel := IntToStr(iFeatureIndex);

                       if (TextWidth(sTextLabel) >= iSegmentSize) then
                          fLabelsOverlap := True;
                  end;
             end;

             for iCount := 1 to iObjectsPerPage do
             begin
                  iFeatureIndex := ((iPageNumber-1) * iObjectsPerPage) + iCount;
                  if (iFeatureIndex <= ieFlowsNoOfSpecies) then
                  begin
                       iRectangleLeft := iSpace + ((iCount-1)*iSegmentSize*3)+ iSegmentSize;
                       if (rMax > 0) then
                       begin
                            TotalArray.rtnValue(iFeatureIndex,@rTotal);

                            // draw target rectangle
                            TargArray.rtnValue(iFeatureIndex,@rTarg);
                            iRectangleTop := ValueToHeight(rTarg);
                            ARectangle := Rect(iRectangleLeft,iRectangleTop,iRectangleLeft+iSegmentSize,Image1.Height-iSpace);
                            Brush.Color := clNavy;
                            Rectangle(ARectangle);

                            // draw amount held rectangle
                            AmntHldArray.rtnValue(iFeatureIndex,@rAmntHld);
                            iRectangleTop := ValueToHeight(rAmntHld);
                            ARectangle := Rect(iRectangleLeft+iSegmentSize,iRectangleTop,iRectangleLeft+iSegmentSize+iSegmentSize,Image1.Height-iSpace);
                            Brush.Color := clGreen;
                            Rectangle(ARectangle);
                       end;

                       // label under bars
                       if CheckUseName.Checked then
                       begin
                            NameArray.rtnValue(iFeatureIndex,@sFeatureName255);
                            sTextLabel := sFeatureName255;
                       end
                       else
                       begin
                            sTextLabel := IntToStr(iFeatureIndex);
                       end;

                       //sTextLabel := SeasonToMonthString(StrToInt(sTextLabel));

                       iLabelY := Image1.Height-(iSpace div 2) - (TextHeight(sTextLabel) div 2) - 1;
                       if (fLabelsOverlap) then
                       begin
                            if ((iCount mod 2) = 1) then
                               iLabelY := iLabelY - (TextHeight(sTextLabel) div 2) - 1
                            else
                                iLabelY := iLabelY + (TextHeight(sTextLabel) div 2) + 1;
                       end;

                       Brush.Color := clWhite;
                       TextOut(iRectangleLeft+iSegmentSize-(TextWidth(sTextLabel) div 2),
                               iLabelY,
                               sTextLabel);
                  end;
             end;
        end;

     except
           MessageDlg('Exception in TBarGraphForm.PloteFlowTargByRuns',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TBarGraphForm.BarGrapheFlowTargByRuns_best;
var
   TargetArray, AmountHeldArray, NameArray, TotalArray : Array_t;
   iCount : integer;
   rTarget, rAmountHeld, rTotal, rMaximum : extended;
   sFeatureName255 : str255;
begin
     try
        ieFlowsNoOfSpecies := eFlowsForm.ReturnNoOfSpecies;

        TargetArray := Array_t.Create;
        TargetArray.init(SizeOf(extended),ieFlowsNoOfSpecies);
        AmountHeldArray := Array_t.Create;
        AmountHeldArray.init(SizeOf(extended),ieFlowsNoOfSpecies);
        NameArray := Array_t.Create;
        NameArray.init(SizeOf(str255),ieFlowsNoOfSpecies);
        TotalArray := Array_t.Create;
        TotalArray.init(SizeOf(extended),ieFlowsNoOfSpecies);
        rMaximum := 0;

        for iCount := 1 to ieFlowsNoOfSpecies do
        begin
             rTarget := StrToFloat(eFlowsWBk.Worksheets.Item['SpeciesFlag'].Cells.Item[3,iCount+1].Value);
             rAmountHeld := StrToFloat(eFlowsWBk.Worksheets.Item['TargByRun'].Cells.Item[iRunToDisplay+1,iCount+1].Value);
             rTotal := StrToFloat(eFlowsWBk.Worksheets.Item['TotalArea'].Cells.Item[3,iCount+1].Value);
             sFeatureName255 := eFlowsWBk.Worksheets.Item['SpeciesFlag'].Cells.Item[1,iCount+1].Value;

             TargetArray.setValue(iCount,@rTarget);
             AmountHeldArray.setValue(iCount,@rAmountHeld);
             NameArray.setValue(iCount,@sFeatureName255);
             TotalArray.setValue(iCount,@rTotal);

             if (rTarget > rMaximum) then
                rMaximum := rTarget;
             if (rAmountHeld > rMaximum) then
                rMaximum := rAmountHeld;
        end;

        PloteFlowTargByRuns(rMaximum,TargetArray,AmountHeldArray,NameArray,TotalArray);

        TargetArray.Destroy;
        AmountHeldArray.Destroy;
        NameArray.Destroy;
        TotalArray.Destroy;

     except
           MessageDlg('Exception in TBarGraphForm.BarGrapheFlowTargByRuns_best',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TBarGraphForm.BarGrapheFlowTargByRuns;
var
   TargetArray, AmountHeldArray, NameArray, TotalArray : Array_t;
   iCount : integer;
   rTarget, rAmountHeld, rTotal, rMaximum : extended;
   sFeatureName255 : str255;
begin
     try
        ieFlowsNoOfSpecies := eFlowsForm.ReturnNoOfSpecies;

        TargetArray := Array_t.Create;
        TargetArray.init(SizeOf(extended),ieFlowsNoOfSpecies);
        AmountHeldArray := Array_t.Create;
        AmountHeldArray.init(SizeOf(extended),ieFlowsNoOfSpecies);
        NameArray := Array_t.Create;
        NameArray.init(SizeOf(str255),ieFlowsNoOfSpecies);
        TotalArray := Array_t.Create;
        TotalArray.init(SizeOf(extended),ieFlowsNoOfSpecies);
        rMaximum := 0;

        for iCount := 1 to ieFlowsNoOfSpecies do
        begin
             rTarget := StrToFloat(eFlowsWBk.Worksheets.Item['SpeciesFlag'].Cells.Item[3,iCount+1].Value);
             rAmountHeld := StrToFloat(eFlowsWBk.Worksheets.Item['TargByRun'].Cells.Item[iRunToDisplay+1,iCount+1].Value);
             rTotal := StrToFloat(eFlowsWBk.Worksheets.Item['TotalArea'].Cells.Item[3,iCount+1].Value);
             sFeatureName255 := eFlowsWBk.Worksheets.Item['SpeciesFlag'].Cells.Item[1,iCount+1].Value;

             TargetArray.setValue(iCount,@rTarget);
             AmountHeldArray.setValue(iCount,@rAmountHeld);
             NameArray.setValue(iCount,@sFeatureName255);
             TotalArray.setValue(iCount,@rTotal);

             if (rTarget > rMaximum) then
                rMaximum := rTarget;
             if (rAmountHeld > rMaximum) then
                rMaximum := rAmountHeld;
        end;

        PloteFlowTargByRuns(rMaximum,TargetArray,AmountHeldArray,NameArray,TotalArray);

        TargetArray.Destroy;
        AmountHeldArray.Destroy;
        NameArray.Destroy;
        TotalArray.Destroy;

     except
           MessageDlg('Exception in TBarGraphForm.BarGrapheFlowTargByRuns',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TBarGraphForm.BarGraphMissingValues;
var
   sInputFile, sLine, sFeatureName, sTotalAreaFilename : string;
   sFeatureName255 : str255;
   InFile, TotalAreaFile : TextFile;
   iCount, iFeatureID : integer;
   TargetArray, AmountHeldArray, NameArray, IdArray, ReservedArray, TotalArray : Array_t;
   rTarget, rAmountHeld, rMaximum, rReserved, rTotal : extended;
   fFileExists, fProceed : boolean;
begin
     try
        sInputFile := Return_MVBEST_Filename;

        fProceed := True;
        fFileExists := FileExists(sInputFile);
        if not fFileExists then
           fProceed := False;
        if (sInputFile = '') then
           fProceed := False;

        sTotalAreaFilename := Return_TotalArea_Filename;

        fFileExists := FileExists(sTotalAreaFilename);
        if not fFileExists then
           fProceed := False;
        if (sTotalAreaFilename = '') then
           fProceed := False;

        if not fProceed then
        begin
             MessageDlg('No current output file',mtInformation,[mbOk],0);
             //ModalResult := mrOk;
             fAutoClose := True;
        end
        else
        begin
             assignfile(InFile,sInputFile);
             reset(InFile);
             readln(InFile);

             assignfile(TotalAreaFile,sTotalAreaFilename);
             reset(TotalAreaFile);
             readln(TotalAreaFile);

             // init the data structures
             TargetArray := Array_t.Create;
             TargetArray.init(SizeOf(extended),iNumberOfFeatures);
             AmountHeldArray := Array_t.Create;
             AmountHeldArray.init(SizeOf(extended),iNumberOfFeatures);
             NameArray := Array_t.Create;
             NameArray.init(SizeOf(str255),iNumberOfFeatures);
             IdArray := Array_t.Create;
             IdArray.init(SizeOf(integer),iNumberOfFeatures);
             ReservedArray := Array_t.Create;
             ReservedArray.init(SizeOf(extended),iNumberOfFeatures);
             TotalArray := Array_t.Create;
             TotalArray.init(SizeOf(extended),iNumberOfFeatures);
             rTarget := 0;
             rAmountHeld := 0;
             rMaximum := 0;
             iFeatureID := 0;
             sFeatureName255 := '';
             rReserved := 0;
             rTotal := 0;
             for iCount := 1 to iNumberOfFeatures do
             begin
                  IdArray.setValue(iCount,@iFeatureID);
                  NameArray.setValue(iCount,@sFeatureName255);
                  TargetArray.setValue(iCount,@rTarget);
                  AmountHeldArray.setValue(iCount,@rAmountHeld);
                  ReservedArray.setValue(iCount,@rReserved);
                  TotalArray.setValue(iCount,@rTotal);
             end;

             // read data from the missing values file
             for iCount := iNumberOfFeatures downto 1 do
             begin
                  readln(InFile,sLine);
                  iFeatureID := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
                  sFeatureName := GetDelimitedAsciiElement(sLine,',',2);
                  rTarget := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));
                  rAmountHeld := StrToFloat(GetDelimitedAsciiElement(sLine,',',4));

                  if (Length(sFeatureName) > 250) then
                     sFeatureName255 := Copy(sFeatureName,1,250)
                  else
                      sFeatureName255 := sFeatureName;

                  readln(TotalAreaFile,sLine);
                  rTotal := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));
                  rReserved := StrToFloat(GetDelimitedAsciiElement(sLine,',',4));

                  IdArray.setValue(iCount,@iFeatureID);
                  NameArray.setValue(iCount,@sFeatureName255);
                  TargetArray.setValue(iCount,@rTarget);
                  AmountHeldArray.setValue(iCount,@rAmountHeld);
                  TotalArray.setValue(iCount,@rTotal);
                  ReservedArray.setValue(iCount,@rReserved);

                  if (rTarget > rMaximum) then
                     rMaximum := rTarget;
                  if (rAmountHeld > rMaximum) then
                     rMaximum := rAmountHeld;
                  if (rReserved > rMaximum) then
                     rMaximum := rReserved;
             end;
             closefile(InFile);
             closefile(TotalAreaFile);

             // plot the data to a bar graph
             PlotMissingValues(rMaximum,TargetArray,AmountHeldArray,NameArray,IdArray,ReservedArray,TotalArray);

             TargetArray.Destroy;
             AmountHeldArray.Destroy;
             NameArray.Destroy;
             IdArray.Destroy;
             ReservedArray.Destroy;
             TotalArray.Destroy;
        end;

     except
           MessageDlg('Exception in TBarGraphForm.BarGraphMissingValues',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TBarGraphForm.BarGraphMissingValues2;
var
   sInputFile, sLine, sFeatureName, sTotalAreaFilename : string;
   sFeatureName255 : str255;
   InFile, TotalAreaFile : TextFile;
   iCount, iFeatureID : integer;
   TargetArray, AmountHeldArray, NameArray, IdArray, ReservedArray, TotalArray : Array_t;
   rTarget, rAmountHeld, rMaximum, rReserved, rTotal : extended;
   fFileExists, fProceed : boolean;
begin
     try
        sInputFile := Return_MV_Filename(iRunToDisplay);

        fProceed := True;
        fFileExists := FileExists(sInputFile);
        if not fFileExists then
           fProceed := False;
        if (sInputFile = '') then
           fProceed := False;

        sTotalAreaFilename := Return_TotalArea_Filename;

        fFileExists := FileExists(sTotalAreaFilename);
        if not fFileExists then
           fProceed := False;
        if (sTotalAreaFilename = '') then
           fProceed := False;

        if not fProceed then
        begin
             MessageDlg('No current output file',mtInformation,[mbOk],0);
             //ModalResult := mrOk;
             fAutoClose := True;
        end
        else
        begin
             assignfile(InFile,sInputFile);
             reset(InFile);
             readln(InFile);

             assignfile(TotalAreaFile,sTotalAreaFilename);
             reset(TotalAreaFile);
             readln(TotalAreaFile);

             // init the data structures
             TargetArray := Array_t.Create;
             TargetArray.init(SizeOf(extended),iNumberOfFeatures);
             AmountHeldArray := Array_t.Create;
             AmountHeldArray.init(SizeOf(extended),iNumberOfFeatures);
             NameArray := Array_t.Create;
             NameArray.init(SizeOf(str255),iNumberOfFeatures);
             IdArray := Array_t.Create;
             IdArray.init(SizeOf(integer),iNumberOfFeatures);
             ReservedArray := Array_t.Create;
             ReservedArray.init(SizeOf(extended),iNumberOfFeatures);
             TotalArray := Array_t.Create;
             TotalArray.init(SizeOf(extended),iNumberOfFeatures);
             rTarget := 0;
             rAmountHeld := 0;
             rMaximum := 0;
             iFeatureID := 0;
             sFeatureName255 := '';
             rReserved := 0;
             rTotal := 0;
             for iCount := 1 to iNumberOfFeatures do
             begin
                  IdArray.setValue(iCount,@iFeatureID);
                  NameArray.setValue(iCount,@sFeatureName255);
                  TargetArray.setValue(iCount,@rTarget);
                  AmountHeldArray.setValue(iCount,@rAmountHeld);
                  ReservedArray.setValue(iCount,@rReserved);
                  TotalArray.setValue(iCount,@rTotal);
             end;

             // read data from the missing values file
             for iCount := iNumberOfFeatures downto 1 do
             begin
                  readln(InFile,sLine);
                  iFeatureID := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
                  sFeatureName := GetDelimitedAsciiElement(sLine,',',2);
                  rTarget := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));
                  rAmountHeld := StrToFloat(GetDelimitedAsciiElement(sLine,',',4));

                  if (Length(sFeatureName) > 250) then
                     sFeatureName255 := Copy(sFeatureName,1,250)
                  else
                      sFeatureName255 := sFeatureName;

                  readln(TotalAreaFile,sLine);
                  rTotal := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));
                  rReserved := StrToFloat(GetDelimitedAsciiElement(sLine,',',4));

                  IdArray.setValue(iCount,@iFeatureID);
                  NameArray.setValue(iCount,@sFeatureName255);
                  TargetArray.setValue(iCount,@rTarget);
                  AmountHeldArray.setValue(iCount,@rAmountHeld);
                  TotalArray.setValue(iCount,@rTotal);
                  ReservedArray.setValue(iCount,@rReserved);

                  if (rTarget > rMaximum) then
                     rMaximum := rTarget;
                  if (rAmountHeld > rMaximum) then
                     rMaximum := rAmountHeld;
                  if (rReserved > rMaximum) then
                     rMaximum := rReserved;
             end;
             closefile(InFile);
             closefile(TotalAreaFile);

             // plot the data to a bar graph
             PlotMissingValues(rMaximum,TargetArray,AmountHeldArray,NameArray,IdArray,ReservedArray,TotalArray);

             TargetArray.Destroy;
             AmountHeldArray.Destroy;
             NameArray.Destroy;
             IdArray.Destroy;
             ReservedArray.Destroy;
             TotalArray.Destroy;
        end;

     except
           MessageDlg('Exception in TBarGraphForm.BarGraphMissingValues2',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TBarGraphForm.BarGraphConfigurations;
var
   sInputFile, sLine, sFeatureName : string;
   sFeatureName255 : str255;
   InFile, MVBestFile : TextFile;
   iCount, iFeatureID : integer;
   IRArray, TIRArray, TAArray, AIMPAArray, MTAArray, NameArray, IdArray : Array_t;
   rIR, rTIR, rTA, rAIMPA, rMTA, rMaximum : extended;
   fFileExists, fProceed : boolean;
begin
     try
        sInputFile := Return_Configuration_Filename;

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
             assignfile(InFile,sInputFile);
             reset(InFile);
             readln(InFile);

             assignfile(MVBestFile,Return_MVBEST_Filename);
             reset(MVBestFile);
             readln(MVBestFile);

             // init the data structures
             IRArray := Array_t.Create;
             IRArray.init(SizeOf(extended),iNumberOfFeatures);
             TIRArray := Array_t.Create;
             TIRArray.init(SizeOf(extended),iNumberOfFeatures);
             TAArray := Array_t.Create;
             TAArray.init(SizeOf(extended),iNumberOfFeatures);
             AIMPAArray := Array_t.Create;
             AIMPAArray.init(SizeOf(extended),iNumberOfFeatures);
             MTAArray := Array_t.Create;
             MTAArray.init(SizeOf(extended),iNumberOfFeatures);
             NameArray := Array_t.Create;
             NameArray.init(SizeOf(str255),iNumberOfFeatures);
             IdArray := Array_t.Create;
             IdArray.init(SizeOf(integer),iNumberOfFeatures);
             rIR := 0;
             rTIR := 0;
             rTA := 0;
             rAIMPA := 0;
             rMTA := 0;
             rMaximum := 0;
             iFeatureID := 0;
             sFeatureName255 := '';
             for iCount := 1 to iNumberOfFeatures do
             begin
                  IdArray.setValue(iCount,@iFeatureID);
                  NameArray.setValue(iCount,@sFeatureName255);
                  IRArray.setValue(iCount,@rIR);
                  TIRArray.setValue(iCount,@rTIR);
                  TAArray.setValue(iCount,@rTA);
                  AIMPAArray.setValue(iCount,@rAIMPA);
                  MTAArray.setValue(iCount,@rMTA);
             end;

             // read data from the file
             for iCount := 1 to iNumberOfFeatures do
             begin
                  readln(InFile,sLine);

                  rIR := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));
                  rTIR := StrToFloat(GetDelimitedAsciiElement(sLine,',',4));
                  rTA := StrToFloat(GetDelimitedAsciiElement(sLine,',',6));
                  rAIMPA := StrToFloat(GetDelimitedAsciiElement(sLine,',',9));
                  rMTA := StrToFloat(GetDelimitedAsciiElement(sLine,',',11));

                  IRArray.setValue(iCount,@rIR);
                  TIRArray.setValue(iCount,@rTIR);
                  TAArray.setValue(iCount,@rTA);
                  AIMPAArray.setValue(iCount,@rAIMPA);
                  MTAArray.setValue(iCount,@rMTA);

                  if (rIR > rMaximum) then
                     rMaximum := rIR;
                  if (rTIR > rMaximum) then
                     rMaximum := rTIR;
                  if (rTA > rMaximum) then
                     rMaximum := rTA;
                  if (rAIMPA > rMaximum) then
                     rMaximum := rAIMPA;
                  if (rMTA > rMaximum) then
                     rMaximum := rMTA;
             end;
             closefile(InFile);
             for iCount := iNumberOfFeatures downto 1 do
             begin
                  readln(MVBestFile,sLine);

                  iFeatureID := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
                  sFeatureName := GetDelimitedAsciiElement(sLine,',',2);

                  if (Length(sFeatureName) > 250) then
                     sFeatureName255 := Copy(sFeatureName,1,250)
                  else
                      sFeatureName255 := sFeatureName;

                  IdArray.setValue(iCount,@iFeatureID);
                  NameArray.setValue(iCount,@sFeatureName255);
             end;
             closefile(MVBestFile);

             // plot the data to a bar graph
             PlotConfigurations(rMaximum,IRArray,TIRArray,TAArray,AIMPAArray,MTAArray,IdArray,NameArray,True);

             IRArray.Destroy;
             TIRArray.Destroy;
             TAArray.Destroy;
             AIMPAArray.Destroy;
             MTAArray.Destroy;
             NameArray.Destroy;
             IdArray.Destroy;
        end;

     except
           MessageDlg('Exception in TBarGraphForm.BarGraphConfigurations',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TBarGraphForm.BarGraphSummary;
var
   sInputFile, sLine : string;
   InFile : TextFile;
   iCount : integer;
   ScoreArray, CostArray, BoundaryLengthArray, PenaltyArray : Array_t;
   rScore, rCost, rBoundaryLength, rPenalty, rMaximum : extended;
   fFileExists, fProceed : boolean;
begin
     try
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
             assignfile(InFile,sInputFile);
             reset(InFile);
             readln(InFile);

             // init the data structures
             ScoreArray := Array_t.Create;
             ScoreArray.init(SizeOf(extended),iNumberOfRuns);
             CostArray := Array_t.Create;
             CostArray.init(SizeOf(extended),iNumberOfRuns);
             BoundaryLengthArray := Array_t.Create;
             BoundaryLengthArray.init(SizeOf(extended),iNumberOfRuns);
             PenaltyArray := Array_t.Create;
             PenaltyArray.init(SizeOf(extended),iNumberOfRuns);
             rScore := 0;
             rCost := 0;
             rBoundaryLength := 0;
             rPenalty := 0;
             rMaximum := 0;
             for iCount := 1 to iNumberOfRuns do
             begin
                  ScoreArray.setValue(iCount,@rScore);
                  CostArray.setValue(iCount,@rCost);
                  BoundaryLengthArray.setValue(iCount,@rBoundaryLength);
                  PenaltyArray.setValue(iCount,@rPenalty);
             end;

             // read data from the file
             for iCount := 1 to iNumberOfRuns do
             begin
                  readln(InFile,sLine);

                  rScore := StrToFloat(GetDelimitedAsciiElement(sLine,',',2));
                  rCost := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));
                  rBoundaryLength := StrToFloat(GetDelimitedAsciiElement(sLine,',',5));
                  rPenalty := StrToFloat(GetDelimitedAsciiElement(sLine,',',11));

                  ScoreArray.setValue(iCount,@rScore);
                  CostArray.setValue(iCount,@rCost);
                  BoundaryLengthArray.setValue(iCount,@rBoundaryLength);
                  PenaltyArray.setValue(iCount,@rPenalty);

                  if (rScore > rMaximum) then
                     rMaximum := rScore;
                  if (rCost > rMaximum) then
                     rMaximum := rCost;
                  if (rBoundaryLength > rMaximum) then
                     rMaximum := rBoundaryLength;
                  if (rPenalty > rMaximum) then
                     rMaximum := rPenalty;
             end;
             closefile(InFile);

             // plot the data to a bar graph
             PlotSummary(rMaximum,ScoreArray, CostArray, BoundaryLengthArray, PenaltyArray);

             ScoreArray.Destroy;
             CostArray.Destroy;
             BoundaryLengthArray.Destroy;
             PenaltyArray.Destroy;
        end;

     except
           MessageDlg('Exception in TBarGraphForm.BarGraphSummary',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TBarGraphForm.btnSaveClick(Sender: TObject);
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

procedure TBarGraphForm.FormResize(Sender: TObject);
begin
     if not fAutoClose then
     //if not fBarGraphStarting then
     begin
     try
          Image1.Align := alNone;
          Image1.Align := alClient;
          Image1.Picture.Graphic.Width := Image1.Width;
          Image1.Picture.Graphic.Height := Image1.Height;
          ResizeTheImage;
     except
     end;
     end;
end;

procedure TBarGraphForm.FormCreate(Sender: TObject);
begin
     fAutoClose := False;

     // Block users from typing a new value into the "Sort by" and "Y Axis Scale" combo boxes
     SendMessage(GetWindow(ComboBoxSortBy.Handle,GW_CHILD), EM_SETREADONLY, 1, 0);
     SendMessage(GetWindow(ComboBoxYAxisScale.Handle,GW_CHILD), EM_SETREADONLY, 1, 0);
end;

procedure TBarGraphForm.FormShow(Sender: TObject);
begin
     if fAutoClose then
        Timer1.Enabled := True;
end;

procedure TBarGraphForm.Timer1Timer(Sender: TObject);
begin
     ModalResult := mrOk;
end;

procedure TBarGraphForm.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin
     iPageNumber := UpDown1.Position;

     RefreshTheGraph;
end;

procedure TBarGraphForm.UpDown2Click(Sender: TObject; Button: TUDBtnType);
begin
     iObjectsPerPage := UpDown2.Position;

     RefreshTheGraph;
end;

procedure TBarGraphForm.CheckUseNameClick(Sender: TObject);
begin
     RefreshTheGraph;
end;

procedure TBarGraphForm.CheckFractionsClick(Sender: TObject);
begin
     RefreshTheGraph;
end;

procedure TBarGraphForm.UpDown3Click(Sender: TObject; Button: TUDBtnType);
begin
     iRunToDisplay := UpDown3.Position;

     RefreshTheGraph;
end;

end.
