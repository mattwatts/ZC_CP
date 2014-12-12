unit GIS;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, OleCtrls, MapWinGIS_TLB, ExtCtrls, StdCtrls, CheckLst,
  Marxan_interface, ds, DBTables, Db, ComCtrls, Grids, Buttons;

type
  TGIS_Child = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Map1: TMap;
    OpenTheme: TOpenDialog;
    LabelOutputToMap: TLabel;
    ComboOutputToMap: TComboBox;
    PopupMenu1: TPopupMenu;
    AddShape1: TMenuItem;
    RemoveAllShapes1: TMenuItem;
    Image1: TImage;
    Table1: TTable;
    Query1: TQuery;
    CheckListBox1: TCheckListBox;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    DrawGrid1: TDrawGrid;
    StringGrid1: TStringGrid;
    Timer1: TTimer;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    ZoomToTimer: TTimer;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    btnPostDDESelection: TButton;
    RedrawTimer: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure UpdateMapeFlows(sField : string;
                              sf : MapWinGIS_TLB.Shapefile;
                              iUpdateLayer, iField : integer);
    procedure UpdateMap(iMinValue, iMaxValue : integer; sField : string;
                        const fSummedSolution : boolean;
                        const fEditConfig : boolean;
                        MChild : TMarxanInterfaceForm);
    function AddShape(sShapefile : string) : integer;
    function AddShapeColour(sShapefile : string; LayerColour : TColor; fLayerVisible : boolean) : integer;
    function AddGrid(sGridfile : string) : integer;
    function AddImage(sImagefile : string) : integer;
    procedure RemoveAllShapes;
    procedure RestoreAllShapes;
    procedure ComboOutputToMapChange(Sender: TObject);
    procedure Map1FileDropped(Sender: TObject; const Filename: WideString);
    procedure Map1_DMapEvents_MouseUp(Sender: TObject; Button,
      Shift: Smallint; x, y: Integer);
    procedure ReturnShapeFields(const iHandle : integer; StringList : TStrings);
    procedure ZoomTo(const iZoom : integer);
    procedure ChangeMode(const iMode : integer);
    procedure Map1SelectBoxFinal(Sender: TObject; Left, Right, Bottom,
      Top: Integer);
    procedure SelectRectangle(const iLeft, iRight, iBottom, iTop: Integer);
    procedure InitShapeSelection;
    procedure Map1ExtentsChanged(Sender: TObject);
    procedure RedrawSelection;
    procedure FormActivate(Sender: TObject);
    procedure SaveMapToBmpFile(const sFilename : string);
    procedure LookupSelectedPlanningUnits(MChild : TMarxanInterfaceForm);
    procedure DeselectSelectedPlanningUnits(MChild : TMarxanInterfaceForm);
    procedure MoveSelectedPlanningUnits(const iZone : integer;MChild : TMarxanInterfaceForm);
    procedure Force_ZCSELECT_Field(const fWriteIndexValues : boolean);
    function ReturnSelectedShapeCount : integer;
    function GridFile2ImageFile(sGridfile, sNewImagefile : string;
                        const fSaveImage : boolean) : integer;
    procedure Polygon2Grid(sf1 : MapWinGIS_TLB.Shapefile;
                           sShapeKeyField : string;
                           grid1 : MapWinGIS_TLB.Grid);
    function PolygonFile2GridFile(const sPolygonfile,
                                      sExistinggridfile,
                                      sNewgridfile : string;
                                      const iGridCellSize : integer) : integer;
    function PolygonFile2GridFile2ImageFile(const sPolygonfile,
                                                  sExistinggridfile,
                                                  sNewgridfile,
                                                  sNewImageFilename : string;
                                            const iGridCellSize : integer;
                                            const fSaveImage : boolean) : integer;
    procedure TabulatePolygon2Grid(sf1 : MapWinGIS_TLB.Shapefile;
                                    sShapeKeyField : string;
                                    grid1 : MapWinGIS_TLB.Grid);
    procedure IntersectImageFiles(const sImage1File, sImage2File, sOutputFile : string);
    procedure IntersectGridFiles(const sGrid1File, sGrid2File,
                                   sOutputPUVSPFile, sOutputSPFile,
                                   sOutputPUFile : string;
                             const fCreatePUFile : boolean);
    procedure IntersectGrids(const iGrid1Handle, iGrid2Handle : integer;
                             const sOutputPUVSPFile, sOutputSPFile,
                                   sOutputPUFile : string;
                             const fCreatePUFile : boolean);
    procedure LoadLegendIni;
    procedure SaveLegendIni;
    procedure FormResize(Sender: TObject);
    procedure Panel2CanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure CheckListBox1ClickCheck(Sender: TObject);
    procedure CheckListBox1DblClick(Sender: TObject);
    procedure CheckListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure CheckListBox1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckListBox1MeasureItem(Control: TWinControl;
      Index: Integer; var Height: Integer);
    function SafeReturnZoneName(const iZoneIndex : integer) : string;
    procedure ZoomToTimerTimer(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure UpdateDDETable;
    procedure UpdateDDEMap;
    procedure ForceCPlanFields;
    procedure BuildDistanceTable(const sOutputFileName : string;
                                 const sPULayer, sPUKey : string;
                                 const rRadius : extended);
    function ReturnDistanceBetweenPoints(const FromPoint, ToPoint : TPoint) : extended;
    procedure btnPostDDESelectionClick(Sender: TObject);
    function rtnZoneColour(const iPaintZone : integer) : TColor;
    procedure Map1MouseUp(Sender: TObject; Button, Shift: Smallint; x,
      y: Integer);
    procedure RedrawTimerTimer(Sender: TObject);
    procedure ExportShapesForSelection(const sOutputFileName : string;const fOnlySelectedShapes : boolean);
    procedure ExportShapesToKML(const sOutputFileName : string;const fOnlySelectedShapes, fBlackOutlines : boolean);
    procedure ExportShapesToKML_MARXANSINGLESOLUTION(const sOutputFileName, sDisplayField : string;
                                                     const fBlackOutlines : boolean;
                                                     const iOpacity : integer);
    procedure ExportShapesToKML_MARXANSUMMEDSOLUTION(const sOutputFileName, sDisplayField : string;
                                                     const fBlackOutlines : boolean;
                                                     const iMaxDisplayValue, iOpacity : integer);
    procedure StoreTransparency;
    procedure RestoreTransparency;
    procedure ExportAllShapesToKML(const sOutputFileName : string;const fReverseClockwise : boolean);
    procedure LabelShapeLayer(sLayer, sField : string;  AJustify : tkHJustification);
    procedure RestoreLabels;
    procedure RestoreLayerSize;
    procedure ExportShapes(const sShapeToExport, sOutputFileName : string);
  private
    { Private declarations }
  public
    { Public declarations }
    iPULayerHandle, iDDEPULayerHandle, iLastLayerHandle, iLastDisplayIndex : integer;
    iDefaultPointSize, iDefaultLineWidth, iDefaultPolygonLineWidth : integer;
    fShapeSelection, fDDEMapCategories : boolean;
    ShapeSelection, DDEMapCategories : Array_t;
    sPuFileName : string;
    SelectionColour, SummedSolutionColour : TColor;
  end;

procedure Polygon2Image(const sInputPolygonfile,sFieldToUse,sOutputGridfile,sOutputImagefile : string;
                        const iGridCellSize : integer);

var
  GIS_Child: TGIS_Child;

implementation

uses SCP_Main, CSV_Child, IniFiles, EditShapeLegend, Miscellaneous,
  EditConfigurations, map_legend, progress_form, eFlows, SetGISDisplayOptions,
  MessageForm;

{$R *.DFM}

procedure TGIS_Child.ExportShapes(const sShapeToExport, sOutputFileName : string);
var
   NewSF, InputSF : MapWinGIS_TLB.Shapefile;
   NewField : MapWinGIS_TLB.Field;
   NewShape : MapWinGIS_TLB.Shape;
   iShapeToExportHandle, iCount, iCount2 : integer;
   sPrjFilename : string;
begin
     try
        NewSF := CoShapefile.Create();
        NewSF.CreateNew(sOutputFileName, SHP_POLYGON);
        NewSF.StartEditingShapes(True,NewSF.GlobalCallback);

        iShapeToExportHandle := 0;
        for iCount := 0 to (GIS_Child.Map1.NumLayers-1) do
            if (GIS_Child.Map1.LayerName[iCount] = sShapeToExport) then
               iShapeToExportHandle := iCount;

        InputSF := IShapefile(GIS_Child.Map1.GetObject[iShapeToExportHandle]);

        // insert fields
        for iCount := 0 to (InputSF.NumFields-1) do
            NewSF.EditInsertField(InputSF.Field[iCount], iCount, NewSF.GlobalCallback);


        // loop through shapes, adding shapes to new shapefile
        for iCount := 0 to (InputSF.NumShapes-1) do
        begin
             // insert shape
             NewSF.EditInsertShape(InputSF.Shape[iCount], iCount);

             // insert fields
             for iCount2 := 0 to (InputSF.NumFields-1) do
                 NewSF.EditCellValue(iCount2, iCount, InputSF.CellValue[iCount2,iCount]);

             (*if ((iCount mod 50000) = 0) then
             begin
                  NewSF.StopEditingShapes(True,True,NewSF.GlobalCallback);
                  NewSF.StartEditingShapes(True,NewSF.GlobalCallback);
             end;*)
        end;

        NewSF.StopEditingShapes(True,True,NewSF.GlobalCallback);

        // copy the projection file if it exists
        sPrjFilename := ChangeFileExt(sShapeToExport,'.prj');
        if fileexists(sPrjFilename) then
           ACopyFile(sPrjFilename, ChangeFileExt(sOutputFileName,'.prj'));

     except
     end;
end;

procedure TGIS_Child.ExportShapesForSelection(const sOutputFileName : string;const fOnlySelectedShapes : boolean);
var
   NewSF, InputSF : MapWinGIS_TLB.Shapefile;
   NewField : MapWinGIS_TLB.Field;
   NewShape : MapWinGIS_TLB.Shape;
   iCount, iFieldIndex, iShapeIndex, iPUIDIndex : integer;
   fUseThisShape : boolean;
   sPrjFilename : string;
begin
     try
        if fShapeSelection then
        begin
             NewSF := CoShapefile.Create();
             NewSF.CreateNew(sOutputFileName, SHP_POLYGON);
             NewSF.StartEditingShapes(True,NewSF.GlobalCallback);

             // add PUID field to the shapefile
             // create field
             NewField := CoField.Create();
             NewField.Name := 'PUID';
             NewField.Type_ := MapWinGIS_TLB.INTEGER_FIELD;
             NewField.Width := 12;
             // insert field
             iFieldIndex := 0;
             NewSF.EditInsertField(NewField, iFieldIndex, NewSF.GlobalCallback);

             // find PUID field index in InputSF
             InputSF := IShapefile(GIS_Child.Map1.GetObject[iPULayerHandle]);
             iPUIDIndex := -1;
             for iCount := 0 to (InputSF.NumFields-1) do
             begin
                  if (SCPForm.fMarxanActivated) then
                     if (InputSF.Field[iCount].Name = MarxanInterfaceForm.ComboKeyField.Text) then
                        iPUIDIndex := iCount;
                  if (SCPForm.feFlowsActivated) then
                     if (InputSF.Field[iCount].Name = eFlowsForm.seFlowsKeyField) then
                        iPUIDIndex := iCount;
             end;

             // loop through shapes, adding selected shapes to new shapefile
             for iCount := 1 to InputSF.NumShapes do
             begin
                  if fOnlySelectedShapes then
                  begin
                       if fShapeSelection then
                          ShapeSelection.rtnValue(iCount,@fUseThisShape)
                       else
                           fUseThisShape := True;
                  end
                  else
                      fUseThisShape := True;

                  if fUseThisShape then
                  begin
                       // insert shape
                       iShapeIndex := iCount;
                       NewSF.EditInsertShape(InputSF.Shape[iCount-1], iShapeIndex);

                       // insert field
                       NewSF.EditCellValue(0, iShapeIndex, InputSF.CellValue[iPUIDIndex,iCount-1]);
                  end;
             end;

             NewSF.StopEditingShapes(True,True,NewSF.GlobalCallback);

             // copy the .prj file if it exists
             sPrjFilename := ChangeFileExt(sPuFileName,'.prj');
             if fileexists(sPrjFilename) then
                ACopyFile(sPrjFilename, ChangeFileExt(sOutputFileName,'.prj'));
        end;

     except
     end;
end;

procedure TGIS_Child.ExportShapesToKML_MARXANSUMMEDSOLUTION(const sOutputFileName, sDisplayField : string;
                                                            const fBlackOutlines : boolean;
                                                            const iMaxDisplayValue, iOpacity : integer);
var
   OutFile : TextFile;
   InputSF : MapWinGIS_TLB.Shapefile;
   InputShape : MapWinGIS_TLB.Shape;
   iNumPoints : integer;
   iCount, iCount2, iPUIDIndex, iDisplayIndex, iDisplayValue, iDisplayStyle : integer;
   fDisplayZero, fDisplayShape : boolean;
begin
     try
        // find PUID field index in InputSF
        InputSF := IShapefile(GIS_Child.Map1.GetObject[iPULayerHandle]);
        iPUIDIndex := -1;
        iDisplayIndex := -1;
        for iCount := 0 to (InputSF.NumFields-1) do
        begin
             if (InputSF.Field[iCount].Name = MarxanInterfaceForm.ComboKeyField.Text) then
                iPUIDIndex := iCount;
             if (InputSF.Get_Field(iCount).Name = sDisplayField) then
                iDisplayIndex := iCount;
        end;

        if (iPUIDIndex > -1) then
           if (iDisplayIndex > -1) then
           begin
                assignfile(OutFile,sOutputFileName);
                rewrite(OutFile);
                writeln(OutFile,'<?xml version="1.0" encoding="UTF-8"?>');
                writeln(OutFile,'<kml xmlns="http://www.opengis.net/kml/2.2">');
                writeln(OutFile,'  <Document>');
                writeln(OutFile,'    <name>Zonae Cogito ouput</name>');
                writeln(OutFile,'    <description>Marxan selection frequency created by Zonae Cogito');
                writeln(OutFile,'Coded by Matthew Watts');
                writeln(OutFile,'m.watts@uq.edu.au</description>');

                // create eleven graduated colour styles, 10 for desceasing selection frequencies, and one for selection frequency zero
                for iCount := 1 to 10 do
                begin
                     writeln(OutFile,'    <Style id="SSOLN' + IntToStr(iCount) + '">');
                     if fBlackOutlines then
                     begin
                          writeln(OutFile,'      <LineStyle>');
                          writeln(OutFile,'        <width>1</width>');
                          writeln(OutFile,'        <color>87000000</color>');
                          writeln(OutFile,'      </LineStyle>');
                          writeln(OutFile,'      <PolyStyle>');
                          //writeln(OutFile,'        <color>' + TColorToGoogleMapsHexRamp(SummedSolutionColour,iOpacity,iCount,0,10) + '</color>');
                          writeln(OutFile,'        <color>' + TColourToKML(SummedSolutionColour,OpacityRamp(iCount,0,10)) + '</color>');
                          writeln(OutFile,'      </PolyStyle>');
                     end
                     else
                     begin
                          writeln(OutFile,'      <PolyStyle>');
                          writeln(OutFile,'        <color>' + TColourToKML(SummedSolutionColour,OpacityRamp(iCount,0,10)) + '</color>');
                          writeln(OutFile,'        <outline>0</outline>');
                          writeln(OutFile,'      </PolyStyle>');
                     end;
                     writeln(OutFile,'    </Style>');
                end;

                fDisplayZero := False;
                if fBlackOutlines then
                begin
                     writeln(OutFile,'    <Style id="SSOLN0">');
                     writeln(OutFile,'      <LineStyle>');
                     writeln(OutFile,'        <width>1</width>');
                     writeln(OutFile,'        <color>87000000</color>');
                     writeln(OutFile,'      </LineStyle>');
                     writeln(OutFile,'      <PolyStyle>');
                     writeln(OutFile,'        <color>' + TColourToKML(clWhite,0) + '</color>');
                     writeln(OutFile,'      </PolyStyle>');
                     writeln(OutFile,'    </Style>');
                     fDisplayZero := True;
                end;

                // For Marxan summed solutions we have two styles;
                //  1) ramped colour for graduated selection frequency with optional black outline
                //       (there are 10 levels of graduation for this)
                //  2) black line for selection frequency zero (to be used only if black outline is switched on)

                // loop through shapes, adding selected shapes to new shapefile
                for iCount := 1 to InputSF.NumShapes do
                begin
                     // what is the display attribute for this shape? 1=available, 2=reserved
                     iDisplayValue := InputSF.CellValue[iDisplayIndex,iCount-1];

                     if (iDisplayValue = 0) then
                     begin
                          fDisplayShape := fBlackOutlines;
                          iDisplayStyle := 0;
                     end
                     else
                     begin
                          fDisplayShape := True;
                          iDisplayStyle := Round(iDisplayValue / iMaxDisplayValue * 10);
                     end;

                     if fDisplayShape then
                     begin
                          // display polygon
                          writeln(OutFile,'    <Placemark>');
                          writeln(OutFile,'      <name>' + IntToStr(InputSF.CellValue[iPUIDIndex,iCount-1]) + '</name>');
                          writeln(OutFile,'      <styleUrl>#SSOLN' + IntToStr(iDisplayStyle) + '</styleUrl>');
                          writeln(OutFile,'      <Polygon>');
                          writeln(OutFile,'        <extrude>1</extrude>');
                          writeln(OutFile,'        <altitudeMode>relativeToGround</altitudeMode>');
                          writeln(OutFile,'        <outerBoundaryIs>');
                          writeln(OutFile,'          <LinearRing>');
                          writeln(OutFile,'            <coordinates>');

                          iNumPoints := InputSF.Shape[iCount-1].numPoints;
                          InputShape := InputSF.Shape[iCount-1];
                          for iCount2 := iNumPoints downto 1 do
                          // The points for the polygon must be rendered in counter-clockwise order.
                          // If the colour appears grey, reverse the render order to make them counter-clockwise.
                          begin
                               write(OutFile,'              ');
                               write(OutFile,FloatToStr(InputShape.Point[iCount2-1].x) + ',');
                               write(OutFile,FloatToStr(InputShape.Point[iCount2-1].y) + ',');
                               writeln(OutFile,FloatToStr(InputShape.Point[iCount2-1].Z));
                          end;
                          writeln(OutFile,'            </coordinates>');
                          writeln(OutFile,'          </LinearRing>');
                          writeln(OutFile,'        </outerBoundaryIs>');
                          writeln(OutFile,'      </Polygon>');
                          writeln(OutFile,'    </Placemark>');
                     end;
                end;

                writeln(OutFile,'  </Document>');
                writeln(OutFile,'</kml>');
                closefile(OutFile);
           end;

     except
           MessageDlg('Exception in ExportShapesToKML',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TGIS_Child.ExportShapesToKML_MARXANSINGLESOLUTION(const sOutputFileName, sDisplayField : string;
                                                            const fBlackOutlines : boolean;
                                                            const iOpacity : integer);
var
   OutFile : TextFile;
   InputSF : MapWinGIS_TLB.Shapefile;
   InputShape : MapWinGIS_TLB.Shape;
   iNumPoints : integer;
   iCount, iCount2, iPUIDIndex, iDisplayIndex, iDisplayValue : integer;
   fDisplayAvailable, fDisplayShape : boolean;
   AvailableColour, ReservedColour : TColor;
begin
     try
        // find PUID field index in InputSF
        InputSF := IShapefile(GIS_Child.Map1.GetObject[iPULayerHandle]);
        iPUIDIndex := -1;
        iDisplayIndex := -1;
        for iCount := 0 to (InputSF.NumFields-1) do
        begin
             if (InputSF.Field[iCount].Name = MarxanInterfaceForm.ComboKeyField.Text) then
                iPUIDIndex := iCount;
             if (InputSF.Get_Field(iCount).Name = sDisplayField) then
                iDisplayIndex := iCount;
        end;

        if (iPUIDIndex > -1) then
           if (iDisplayIndex > -1) then
           begin
                MarxanInterfaceForm.SingleSolutionColours.rtnValue(1,@AvailableColour);
                MarxanInterfaceForm.SingleSolutionColours.rtnValue(2,@ReservedColour);

                assignfile(OutFile,sOutputFileName);
                rewrite(OutFile);
                writeln(OutFile,'<?xml version="1.0" encoding="UTF-8"?>');
                writeln(OutFile,'<kml xmlns="http://www.opengis.net/kml/2.2">');
                writeln(OutFile,'  <Document>');
                writeln(OutFile,'    <name>Zonae Cogito ouput</name>');
                writeln(OutFile,'    <description>Marxan best solution created by Zonae Cogito');
                writeln(OutFile,'Coded by Matthew Watts');
                writeln(OutFile,'m.watts@uq.edu.au</description>');

                writeln(OutFile,'    <Style id="ReservedStyle">');
                if fBlackOutlines then
                begin
                     writeln(OutFile,'      <LineStyle>');
                     writeln(OutFile,'        <width>1</width>');
                     writeln(OutFile,'        <color>87000000</color>');
                     writeln(OutFile,'      </LineStyle>');
                     writeln(OutFile,'      <PolyStyle>');
                     writeln(OutFile,'        <color>' + TColourToKML(ReservedColour,iOpacity) + '</color>');
                     writeln(OutFile,'      </PolyStyle>');
                end
                else
                begin
                     writeln(OutFile,'      <PolyStyle>');
                     writeln(OutFile,'        <color>' + TColourToKML(ReservedColour,iOpacity) + '</color>');
                     writeln(OutFile,'        <outline>0</outline>');
                     writeln(OutFile,'      </PolyStyle>');
                end;
                writeln(OutFile,'    </Style>');

                fDisplayAvailable := False;
                if (AvailableColour <> clWhite) then
                begin
                     writeln(OutFile,'    <Style id="AvailableStyle">');
                     writeln(OutFile,'      <LineStyle>');
                     if fBlackOutlines then
                     begin
                          writeln(OutFile,'        <width>1</width>');
                          writeln(OutFile,'        <color>87000000</color>');
                     end
                     else
                         writeln(OutFile,'        <width>0</width>');
                     writeln(OutFile,'      </LineStyle>');
                     writeln(OutFile,'      <PolyStyle>');
                     writeln(OutFile,'        <color>' + TColourToKML(AvailableColour,iOpacity) + '</color>');
                     writeln(OutFile,'      </PolyStyle>');
                     writeln(OutFile,'    </Style>');
                     fDisplayAvailable := True;
                end
                else
                    if fBlackOutlines then
                    begin
                         writeln(OutFile,'    <Style id="AvailableStyle">');
                         writeln(OutFile,'      <LineStyle>');
                         writeln(OutFile,'        <width>1</width>');
                         writeln(OutFile,'        <color>87000000</color>');
                         writeln(OutFile,'      </LineStyle>');
                         writeln(OutFile,'      <PolyStyle>');
                         writeln(OutFile,'        <color>' + TColourToKML(AvailableColour,0) + '</color>');
                         writeln(OutFile,'      </PolyStyle>');
                         writeln(OutFile,'    </Style>');
                         fDisplayAvailable := True;
                    end;

                // For Marxan solutions we have two styles;
                //  1) coloured polygon for selected areas with optional black outline
                //  2) black line for non-selected areas (to be used only if black outline is switched on)

                // loop through shapes, adding selected shapes to new shapefile
                for iCount := 1 to InputSF.NumShapes do
                begin
                     // what is the display attribute for this shape? 1=available, 2=reserved
                     iDisplayValue := InputSF.CellValue[iDisplayIndex,iCount-1];

                     if (iDisplayValue = 1) then
                        fDisplayShape := fDisplayAvailable
                     else
                         fDisplayShape := True;

                     if fDisplayShape then
                     begin
                          // display polygon
                          writeln(OutFile,'    <Placemark>');
                          writeln(OutFile,'      <name>' + IntToStr(InputSF.CellValue[iPUIDIndex,iCount-1]) + '</name>');
                          if (iDisplayValue = 1) then
                             writeln(OutFile,'      <styleUrl>#AvailableStyle</styleUrl>')
                          else
                              writeln(OutFile,'      <styleUrl>#ReservedStyle</styleUrl>');
                          writeln(OutFile,'      <Polygon>');
                          writeln(OutFile,'        <extrude>1</extrude>');
                          writeln(OutFile,'        <altitudeMode>relativeToGround</altitudeMode>');
                          writeln(OutFile,'        <outerBoundaryIs>');
                          writeln(OutFile,'          <LinearRing>');
                          writeln(OutFile,'            <coordinates>');

                          iNumPoints := InputSF.Shape[iCount-1].numPoints;
                          InputShape := InputSF.Shape[iCount-1];
                          for iCount2 := iNumPoints downto 1 do
                          // The points for the polygon must be rendered in counter-clockwise order.
                          // If the colour appears grey, reverse the render order to make them counter-clockwise.
                          begin
                               write(OutFile,'              ');
                               write(OutFile,FloatToStr(InputShape.Point[iCount2-1].x) + ',');
                               write(OutFile,FloatToStr(InputShape.Point[iCount2-1].y) + ',');
                               writeln(OutFile,FloatToStr(InputShape.Point[iCount2-1].Z));
                          end;
                          writeln(OutFile,'            </coordinates>');
                          writeln(OutFile,'          </LinearRing>');
                          writeln(OutFile,'        </outerBoundaryIs>');
                          writeln(OutFile,'      </Polygon>');
                          writeln(OutFile,'    </Placemark>');
                     end;
                end;

                writeln(OutFile,'  </Document>');
                writeln(OutFile,'</kml>');
                closefile(OutFile);
           end;

     except
           MessageDlg('Exception in ExportShapesToKML',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TGIS_Child.ExportAllShapesToKML(const sOutputFileName : string;const fReverseClockwise : boolean);
var
   OutFile : TextFile;
   InputSF : MapWinGIS_TLB.Shapefile;
   InputShape : MapWinGIS_TLB.Shape;
   iCount, iCount2, iPUIDIndex, iNumPoints : integer;
   fShapeSelected, fUseThisShape, fBlackOutlines : boolean;
begin
     try
        InputSF := IShapefile(GIS_Child.Map1.GetObject[0]);

        assignfile(OutFile,sOutputFileName);
        rewrite(OutFile);
        writeln(OutFile,'<?xml version="1.0" encoding="UTF-8"?>');
        writeln(OutFile,'<kml xmlns="http://www.opengis.net/kml/2.2">');
        writeln(OutFile,'  <Document>');
        writeln(OutFile,'    <Style id="transBluePoly">');
        writeln(OutFile,'      <LineStyle>');
        writeln(OutFile,'        <width>0</width>');
        writeln(OutFile,'      </LineStyle>');
        writeln(OutFile,'      <PolyStyle>');
        writeln(OutFile,'        <color>7dff0000</color>');
        writeln(OutFile,'      </PolyStyle>');
        writeln(OutFile,'    </Style>');

        // loop through shapes, adding selected shapes to new shapefile
        for iCount := 1 to InputSF.NumShapes do
        begin
             iNumPoints := InputSF.Shape[iCount-1].numPoints;
             InputShape := InputSF.Shape[iCount-1];

             writeln(OutFile,'    <Placemark>');
             writeln(OutFile,'      <name>' + IntToStr(InputSF.CellValue[iPUIDIndex,iCount-1]) + '</name>');
             writeln(OutFile,'      <styleUrl>#transBluePoly</styleUrl>');
             writeln(OutFile,'      <Polygon>');
             writeln(OutFile,'        <extrude>1</extrude>');
             writeln(OutFile,'        <altitudeMode>relativeToGround</altitudeMode>');
             writeln(OutFile,'        <outerBoundaryIs>');
             writeln(OutFile,'          <LinearRing>');
             writeln(OutFile,'            <coordinates>');
             if (fReverseClockwise) then
             begin
                  for iCount2 := iNumPoints downto 1 do
                  begin
                       write(OutFile,'              ');
                       write(OutFile,FloatToStr(InputShape.Point[iCount2-1].x) + ',');
                       write(OutFile,FloatToStr(InputShape.Point[iCount2-1].y) + ',');
                       writeln(OutFile,FloatToStr(InputShape.Point[iCount2-1].Z));
                  end;
             end
             else
             begin
                  for iCount2 := 1 to iNumPoints do
                  begin
                       write(OutFile,'              ');
                       write(OutFile,FloatToStr(InputShape.Point[iCount2-1].x) + ',');
                       write(OutFile,FloatToStr(InputShape.Point[iCount2-1].y) + ',');
                       writeln(OutFile,FloatToStr(InputShape.Point[iCount2-1].Z));
                  end;
             end;
             writeln(OutFile,'            </coordinates>');
             writeln(OutFile,'          </LinearRing>');
             writeln(OutFile,'        </outerBoundaryIs>');
             writeln(OutFile,'      </Polygon>');
             writeln(OutFile,'    </Placemark>');
        end;

        writeln(OutFile,'  </Document>');
        writeln(OutFile,'</kml>');
        closefile(OutFile);

     except
           MessageDlg('Exception in ExportShapesToKML',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TGIS_Child.ExportShapesToKML(const sOutputFileName : string;const fOnlySelectedShapes, fBlackOutlines : boolean);
var
   OutFile : TextFile;
   InputSF : MapWinGIS_TLB.Shapefile;
   InputShape : MapWinGIS_TLB.Shape;
   iNumPoints : integer;
   iCount, iCount2, iPUIDIndex : integer;
   fShapeSelected, fUseThisShape : boolean;
begin
     try
        // find PUID field index in InputSF
        InputSF := IShapefile(GIS_Child.Map1.GetObject[iPULayerHandle]);
        iPUIDIndex := -1;
        for iCount := 0 to (InputSF.NumFields-1) do
        begin
             if (SCPForm.fMarxanActivated) then
                if (InputSF.Field[iCount].Name = MarxanInterfaceForm.ComboKeyField.Text) then
                   iPUIDIndex := iCount;
             if (SCPForm.feFlowsActivated) then
                if (InputSF.Field[iCount].Name = eFlowsForm.seFlowsKeyField) then
                   iPUIDIndex := iCount;
        end;
        
        assignfile(OutFile,sOutputFileName);
        rewrite(OutFile);
        writeln(OutFile,'<?xml version="1.0" encoding="UTF-8"?>');
        writeln(OutFile,'<kml xmlns="http://www.opengis.net/kml/2.2">');
        writeln(OutFile,'  <Document>');
        writeln(OutFile,'    <Style id="transBluePoly">');
        writeln(OutFile,'      <LineStyle>');
        //writeln(OutFile,'        <width>1.5</width>');
        if fBlackOutlines then
        begin
             writeln(OutFile,'        <width>1</width>');
             writeln(OutFile,'        <color>87000000</color>');
        end
        else
            writeln(OutFile,'        <width>0</width>');
        writeln(OutFile,'      </LineStyle>');
        writeln(OutFile,'      <PolyStyle>');
        writeln(OutFile,'        <color>7dff0000</color>');
        writeln(OutFile,'      </PolyStyle>');
        writeln(OutFile,'    </Style>');

        //if fBlackOutlines then
        //begin
        //     writeln(OutFile,'    <Style id="thinBlackLine">');
        //     writeln(OutFile,'      <LineStyle>');
        //     writeln(OutFile,'        <color>87000000</color>');
        //     writeln(OutFile,'        <width>1.5</width>');
        //     writeln(OutFile,'      </LineStyle>');
        //     writeln(OutFile,'    </Style>');
        //end;

        // loop through shapes, adding selected shapes to new shapefile
        for iCount := 1 to InputSF.NumShapes do
        begin
             if fOnlySelectedShapes then
             begin
                  if fShapeSelection then
                     ShapeSelection.rtnValue(iCount,@fUseThisShape)
                  else
                      fUseThisShape := True;
             end
             else
                 fUseThisShape := True;

             if fUseThisShape then
             begin
                  writeln(OutFile,'    <Placemark>');
                  writeln(OutFile,'      <name>' + IntToStr(InputSF.CellValue[iPUIDIndex,iCount-1]) + '</name>');
                  writeln(OutFile,'      <styleUrl>#transBluePoly</styleUrl>');
                  writeln(OutFile,'      <Polygon>');
                  writeln(OutFile,'        <extrude>1</extrude>');
                  writeln(OutFile,'        <altitudeMode>relativeToGround</altitudeMode>');
                  writeln(OutFile,'        <outerBoundaryIs>');
                  writeln(OutFile,'          <LinearRing>');
                  //writeln(OutFile,'            <coordinates> -122.0857412771483,37.42227033155257,17');
                  writeln(OutFile,'            <coordinates>');

                  iNumPoints := InputSF.Shape[iCount-1].numPoints;
                  InputShape := InputSF.Shape[iCount-1];
                  for iCount2 := 1 to iNumPoints do
                  begin
                       write(OutFile,'              ');
                       write(OutFile,FloatToStr(InputShape.Point[iCount2-1].x) + ',');
                       write(OutFile,FloatToStr(InputShape.Point[iCount2-1].y) + ',');
                       writeln(OutFile,FloatToStr(InputShape.Point[iCount2-1].Z));
                  end;
                  //write(OutFile,'              ');
                  //write(OutFile,FloatToStr(InputSF.Shape[iCount-1].Point[0].x) + ',');
                  //write(OutFile,FloatToStr(InputSF.Shape[iCount-1].Point[0].y) + ',');
                  //writeln(OutFile,FloatToStr(InputSF.Shape[iCount-1].Point[0].Z));
                  //writeln(OutFile,'              -122.0858169768481,37.42231408832346,17');
                  writeln(OutFile,'            </coordinates>');
                  writeln(OutFile,'          </LinearRing>');
                  writeln(OutFile,'        </outerBoundaryIs>');
                  writeln(OutFile,'      </Polygon>');
                  writeln(OutFile,'    </Placemark>');

                  //if fBlackOutlines then
                  //begin
                  //writeln(OutFile,'    <Placemark>');
                  //writeln(OutFile,'      <name>Absolute</name>');
                  //writeln(OutFile,'      <styleUrl>#transPurpleLineGreenPoly</styleUrl>');
                  //writeln(OutFile,'      <LineString>');
                  //writeln(OutFile,'        <tessellate>1</tessellate>');
                  //writeln(OutFile,'        <altitudeMode>relativeToGround</altitudeMode>');
                  //writeln(OutFile,'            <coordinates>');
                  //for iCount2 := 1 to InputSF.Shape[iCount-1].numPoints do
                  //begin
                  //     write(OutFile,'              ');
                  //     write(OutFile,FloatToStr(InputSF.Shape[iCount-1].Point[iCount2-1].x) + ',');
                  //     write(OutFile,FloatToStr(InputSF.Shape[iCount-1].Point[iCount2-1].y) + ',');
                  //     writeln(OutFile,FloatToStr(InputSF.Shape[iCount-1].Point[iCount2-1].Z));
                  //end;
                  //write(OutFile,'              ');
                  //write(OutFile,FloatToStr(InputSF.Shape[iCount-1].Point[0].x) + ',');
                  //write(OutFile,FloatToStr(InputSF.Shape[iCount-1].Point[0].y) + ',');
                  //writeln(OutFile,FloatToStr(InputSF.Shape[iCount-1].Point[0].Z));
                  //writeln(OutFile,'            </coordinates>');
                  //writeln(OutFile,'      </LineString>');
                  //writeln(OutFile,'    </Placemark>');
                  //end;
             end;
        end;

        writeln(OutFile,'  </Document>');
        writeln(OutFile,'</kml>');
        closefile(OutFile);

     except
           MessageDlg('Exception in ExportShapesToKML',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

function TGIS_Child.ReturnDistanceBetweenPoints(const FromPoint, ToPoint : TPoint) : extended;
var
   rLat, rLon, rMilesX, rMilesY : double;
begin
     GIS_Child.Map1.PixelToProj(ToPoint.x, ToPoint.y, rLon, rLat);
     //PixelToProj(pixelX: Double; pixelY: Double; var projX: Double; var projY: Double);

     rMilesY := Abs(rLat - FromPoint.y) * 69.172;
     // The distance between lines of longitude changes as you go further north or south
     rMilesX := Abs(rLon - FromPoint.x) * 69.172 * Cos(rLat * Pi / 180);
     Result := Sqrt(Sqr(rMilesX) + Sqr(rMilesY));
end;


procedure TGIS_Child.BuildDistanceTable(const sOutputFileName : string;
                                        const sPULayer, sPUKey : string;
                                        const rRadius : extended);
var
   OutputFile : TextFile;
   iLayerIndex, iFieldIndex, iCount : integer;
   sf: MapWinGIS_TLB.Shapefile;
   FromPoint, ToPoint : TPoint;
   //util1 : MapWinGeoProc_TLB.Utils;
begin
     try
        if (GIS_Child.Map1.NumLayers > 0) then
        begin
             iLayerIndex := -1;
             for iCount := 0 to (GIS_Child.Map1.NumLayers-1) do
                 if (sPULayer = GIS_Child.Map1.LayerName[iCount]) then
                    iLayerIndex := iCount;

             if (iLayerIndex > -1) then
             begin
                  iFieldIndex := -1;
                  sf := IShapefile(GIS_Child.Map1.GetObject[GIS_Child.Map1.LayerHandle[iLayerIndex]]);
                  for iCount := 0 to (sf.Get_NumFields-1) do
                      if (sPUKey = sf.Get_Field(iCount).Name) then
                         iFieldIndex := iCount;

                  if (iFieldIndex > -1) then
                  begin
                       assignfile(OutputFile,sOutputFileName);
                       rewrite(OutputFile);
                       writeln(OutputFile,'header');
                       //util1 := CoUtils.Create();

                       // for each coreRecord in theCoreBitmap
                       for iCount := 1 to sf.NumShapes do
                       begin
                            // find centroid for the core record
                            //FromPoint := util1.Centroid(sf.Get_Shape(iCount));

                            //mwPoint = MapWinGeoProc.Utils.Centroid(mwShape)

                            // buffer this centroid to the desired radius
                            //bool MapWinGeoProc:BufferPoint(ref MapWinGIS.Point point, System.Double radius, int numQuadrants, ref MapWinGIS.Shape resultShp)

                            // select polygons that intersect with buffered centroid
                            //MapWinGeoProc:SelectWithPolygon(ref string inputSFPath, ref MapWinGIS.Shape polygon, ref string resultSFPath)

                            // traverse intersected polygons
                            begin
                                 // find centroid of intersected polygon

                                 // compute distance centroid to centroid
                                 //ReturnDistanceBetweenPoints

                                 // write output record
                            end;
                            (* theFTab.SelectByFTab( theFTab,
                                                  #FTAB_RELTYPE_ISWITHINDISTANCEOF,
                                                  d.AsNumber,
                                                  #VTAB_SELTYPE_NEW )


                            theCircle = Circle.Make( theCoreShape.ReturnCenter, d.AsNumber )
                            if ( theCircle = nil ) then
                                MsgBox.Info( "Cannot make Circle", "ERROR" )
                                return nil
                            end

                            'theFTab.SelectByShapes( {theCircle}, #VTAB_SELTYPE_NEW )


                            '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                            theBitmap = theFTab.GetSelection
                            if ( theBitMap = nil ) then
                                MsgBox.Info( "Got a NULL selection Bitmap...exiting...", "ERROR" )
                            end

                            for each rec in theBitMap
                                theTestShape = theFTab.ReturnValue( theFTab.FindField( "Shape" ), rec )
                                theTestIndex = theFTab.ReturnValue( theFTab.FindField( "RECNO" ), rec )
                                theDist = theCoreShape.Distance( theTestShape )

                                if ( theDist = 0 ) then
                                            theDist = C_EPSILON
                                        end
                                        if ( theTestIndex <> theCoreIndex ) then
                                            s = s + ","+theTestIndex.AsString+","+theDist.AsString
                                        end

                            end *)

                            writeln(OutputFile,IntToStr(iCount));
                       end;

                       closefile(OutputFile);
                  end;
             end;
        end;

     except
           MessageDlg('Exception in BuildDistanceTable',mtError,[mbOk],0);
           Application.Terminate;
     end;

     (*
     'CPlan.BuildDistanceTable

     'Purpose: Build spatial distance table for a shapefile
     'Author: Glenn Manion, adapted by Matthew Watts for use with C-Plan
     'Date: 9 Dec 2002

     'ask user if they want to run, may take overnight for large shapefile
     if (MsgBox.YesNo ("It may take several hours to run on a large shape file","Do you want to build a distance
     table?",TRUE)) then

     ' run add_record_no macro to add/update 0-based index field named RECNO
     av.run("CPlan.add_record_no",{})

     theView = av.GetActiveDoc

     C_EPSILON = 0.0001

     tList = theView.GetActiveThemes
     if ( tList.Count <> 1 ) then
         MsgBox.Info("Can only have ONE theme currently selected", "INFO" )
         return nil
     end

     theTheme = tList.Get(0)

     'select all features in the active document
     theTheme.GetFTab.GetSelection.SetAll
     theTheme.GetFTab.UpdateSelection

     theFTab = theTheme.GetFTab
     if ( theFTab = nil ) then
         MsgBox.Info( "Cannot get FTab....exiting...", "ERROR" )
         return nil
     end

     'setup the zone distances for the analysis
     d = MsgBox.Input( "Enter zone radius in metres ", "Zone Radius", 1000.AsString )
     'enter output name
     sOutputName = MsgBox.Input("Enter output name (no extension)","Output name","output")
    
     '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
     'set output data path to point to $HOME (normally c:\temp)
     sDataPath = System.GetEnvVar("HOME")

     'output file setup
     fname = sDataPath+"\\"+sOutputName+".txt"
     output = LineFile.Make( fname.AsFileName,
                             #FILE_PERM_WRITE )
     if ( output = nil ) then
         MsgBox.Info( "Cannot open"++fname, "ERROR" )
         return nil
     end

     'write header to the line file
     output.WriteElt(d.AsString )

     '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
     '''''''''''''''''''''''''''''SETTING UP THE SELECTION DATA'''''''''''''''''''
     'make sure that we have a selection
     theCoreBitmap = theFTab.GetSelection
     if ( theCoreBitmap = nil ) then
         MsgBox.Info( "Got a NULL core selection Bitmap...exiting...", "ERROR" )
     end
     if ( theCoreBitmap.Count < 1 ) then
         MsgBox.Info( "Must have at least ONE item selected", "INFO" )
         return nil
     end

     av.ShowMsg( "Extracting buffered polygons....." )
     i = 0
     total = theCoreBitmap.Count
     theCircle = nil

     ' get user to select which field has the area in metres squared
     ' future job: need to adapt existing npws script to generate area in metres squared
     aAreaField = MsgBox.ListAsString(theFTab.GetFields,
                                      "Select the Area field in hectares",
                                      "Available Fields")
     if (aAreaField = nil) then
        return nil
     end

     for each coreRecord in theCoreBitmap

         'progress = (i/total) * 100
         i = i+1
    
         theCoreShape = theFTab.ReturnValue( theFTab.FindField( "Shape" ), coreRecord )
         if ( theCoreShape = nil ) then
             MsgBox.Info( "Got a nil coreShape....exiting...", "ERROR" )
             return nil
         end

         theCoreIndex = theFTab.ReturnValue( theFTab.FindField( "RECNO" ), coreRecord )
         if ( theCoreIndex = nil ) then
             MsgBox.Info( "Got a nil coreIndex....exiting...", "ERROR" )
             return nil
         end
    
         theCoreAreaHectares = theFTab.ReturnValue( aAreaField, coreRecord )
         ' convert the area from hectares to metres squared
         theCoreArea = theCoreAreaHectares * 10000
         if ( theCoreArea = nil ) then
             MsgBox.Info( "The shape table must have AREA field in hectares....exiting...", "ERROR Missing AREA field" )
             return nil
         end
         theCoreRadius = (theCoreArea/3.141592654).Sqrt

         'if (theCoreArea < 1) then
         '   theCoreArea = 1
         'end
         'if (theCoreRadius < 1) then
         '   theCoreRadius = 1
         'end


         s = theCoreIndex.AsString
         s = s + "," + theCoreArea.AsString + "," + theCoreRadius.AsString


         'reset the selection to the core shape to original
         'theFTab.SelectByShapes({theCoreShape}, #VTAB_SELTYPE_NEW )
         theFTab.SelectByPoint(theCoreShape.ReturnCenter, 0, #VTAB_SELTYPE_NEW )

         '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
         theFTab.SelectByFTab( theFTab,
                               #FTAB_RELTYPE_ISWITHINDISTANCEOF,
                               d.AsNumber,
                               #VTAB_SELTYPE_NEW )


         theCircle = Circle.Make( theCoreShape.ReturnCenter, d.AsNumber )
         if ( theCircle = nil ) then
             MsgBox.Info( "Cannot make Circle", "ERROR" )
             return nil
         end

         'theFTab.SelectByShapes( {theCircle}, #VTAB_SELTYPE_NEW )


         '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
         theBitmap = theFTab.GetSelection
         if ( theBitMap = nil ) then
             MsgBox.Info( "Got a NULL selection Bitmap...exiting...", "ERROR" )
         end

         for each rec in theBitMap
             theTestShape = theFTab.ReturnValue( theFTab.FindField( "Shape" ), rec )
             theTestIndex = theFTab.ReturnValue( theFTab.FindField( "RECNO" ), rec )
             theDist = theCoreShape.Distance( theTestShape )

             if ( theDist = 0 ) then
                         theDist = C_EPSILON
                     end
                     if ( theTestIndex <> theCoreIndex ) then
                         s = s + ","+theTestIndex.AsString+","+theDist.AsString
                     end

         end
        output.WriteElt( s )

     end

     av.ClearStatus
     av.ShowMsg( "" )
     output.Close

     disp = av.GetActiveDoc.GetDisplay
     symb = Symbol.Make( #SYMBOL_PEN )
     symb.SetColor( Color.GetGreen )
     disp.DrawCircle( theCircle, symb )                         

     'call command line program to convert text to binary
     _CPLAN_PATH = av.Run("CPlan.FindCPlanPath",{})
     sInParam = sDataPath + "\" + sOutputName + ".txt"
     sOutParam = sDataPath + "\" + sOutputName
     'start utility now
     if (av.run("CPlan.FileExists",{_CPLAN_PATH + "\cluster1.exe"})) then
       sCommand = _CPLAN_PATH + "\cluster1.exe" ++ sInParam.Quote ++ sOutParam.Quote
       'MsgBox.Info(sCommand,"command is :")
       System.Execute(sCommand)
     else
       ' user needs to re-install C-Plan
       MsgBox.Info("C-Plan is not installed correctly.  You need to re-install the" + NL +
                   "C-Plan installation set.",
                   "Re-install C-Plan")

     end

     ' If cplan.ini exists on the same path as the shape file, automatically link the
     ' database to the newly created distance table with a call to SPATCFG.EXE
     ' First parameter is the cplan.ini path and filename.
     ' Second parameter is the dst file path and filename.
     sFirstParam = theFTab.GetSRCName.GetFilename.ReturnDir.GetFullName + "\\cplan.ini"
     if (av.run("CPlan.FileExists",{sFirstParam}) = True) then
       sSecondParam = sDataPath + "\" + sOutputName + ".dst"
       if (av.run("CPlan.FileExists",{_CPLAN_PATH + "\SPATCFG.EXE"})) then
         sCommand = _CPLAN_PATH + "\SPATCFG.EXE" ++ sFirstParam.Quote ++ sSecondParam.Quote
         System.Execute(sCommand)
       end
     end

     MsgBox.Info("Output distance table is " + sOutParam,"Distance table completed")
     end

     *)

end;

procedure TGIS_Child.ForceCPlanFields;
var
   iFieldsToAdd, iCount : integer;
   sTableName : string;

   function DoesFieldExist(sField : string) : boolean;
   var
      iCount : integer;
      fResult : boolean;
   begin
        fResult := False;

        for iCount := 0 to (Table1.FieldDefs.Count-1) do
            if (sField = Table1.FieldDefs.Items[iCount].Name) then
               fResult := True;

        Result := fResult;
   end;

   procedure AddFloatField(sField : string);
   begin
        if not DoesFieldExist(sField) then
        begin
             Inc(iFieldsToAdd);
             if (iFieldsToAdd > 1) then
                Query1.SQL.Add(', ADD ' + sField + ' NUMERIC(10,5)')
             else
                 Query1.SQL.Add('ADD ' + sField + ' NUMERIC(10,5)');
        end;
   end;

   procedure AddStr4Field(sField : string);
   begin
        if not DoesFieldExist(sField) then
        begin
             Inc(iFieldsToAdd);
             if (iFieldsToAdd > 1) then
                Query1.SQL.Add(', ADD ' + sField + ' CHAR(4)')
             else
                 Query1.SQL.Add('ADD ' + sField + ' CHAR(4)');
        end;
   end;

begin
     // if relevant fields do not exist in the shape file, create them with an sql query
     try
        Table1.DatabaseName := ExtractFilePath(SCPForm.sDDEPULayer);
        sTableName := ExtractFileName(SCPForm.sDDEPULayer);
        sTableName := Copy(sTableName,1,Length(sTableName) - Length(ExtractFileExt(sTableName))) + '.dbf';
        Table1.TableName := sTableName;
        Table1.Open;

        Query1.SQL.Clear;
        Query1.SQL.Add('ALTER TABLE "' + Table1.DatabaseName + '\' + sTableName + '"');

        iFieldsToAdd := 0;
        AddStr4Field('DISPLAY');
        //AddFloatField('IRREPL');
        //AddFloatField('SUMIRR');
        //AddFloatField('WAVIRR');
        //AddFloatField('PCCONTR');

        Table1.Close;

        if (iFieldsToAdd > 0) then
        begin
             Query1.Prepare;
             Query1.ExecSQL;
             Query1.Close;
        end;

     except
           Query1.SQL.SaveToFile(Table1.DatabaseName + '\error.sql');
           MessageDlg('Exception in ForceCPlanFields theme ' + SCPForm.sDDEPULayer + '.',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;


procedure TGIS_Child.UpdateDDETable;
var
   PUID_array, DISPLAY_array : Array_t;
   //VALUES_array : Array_t;
   iCount, iPUID, iPUIndex, iValue : integer;
   sDisplay : string[4];
   sTableName : string;
   //rValue : extended;
   myExtents: MapWinGIS_TLB.Extents;
begin
     try
        // sDDEPULayer sDDEPUKey sDDESourceTable sDDESourceKey

        // read data from source table to an array
        Table1.DatabaseName := ExtractFilePath(SCPForm.sDDESourceTable);
        Table1.TableName := ExtractFileName(SCPForm.sDDESourceTable);
        Table1.Open;
        PUID_array := Array_t.Create;
        PUID_array.init(SizeOf(integer),Table1.RecordCount);
        DISPLAY_array := Array_t.Create;
        DISPLAY_array.init(SizeOf(sDisplay),Table1.RecordCount);
        //VALUES_array := Array_t.Create;
        //VALUES_array.init(SizeOf(integer),Trunc(Table1.RecordCount * 4));
        for iCount := 1 to Table1.RecordCount do
        begin
             iPUID := Table1.FieldByName(SCPForm.sDDESourceKey).AsInteger;
             PUID_array.setValue(iCount,@iPUID);
             sDisplay := Table1.FieldByName('DISPLAY').AsString;
             DISPLAY_array.setValue(iCount,@sDisplay);

             //rValue := Table1.FieldByName('IRREPL').AsFloat;
             //VALUES_array.setValue(iCount,@rValue);
             //rValue := Table1.FieldByName('SUMIRR').AsFloat;
             //VALUES_array.setValue(iCount + Table1.RecordCount,@rValue);
             //rValue := Table1.FieldByName('WAVIRR').AsFloat;
             //VALUES_array.setValue(iCount + Trunc(Table1.RecordCount*2),@rValue);
             //rValue := Table1.FieldByName('PCCONTR').AsFloat;
             //VALUES_array.setValue(iCount + Trunc(Table1.RecordCount*3),@rValue);

             Table1.Next;
        end;
        Table1.Close;

        // remove layer from GIS display
        myExtents := IExtents(GIS_Child.Map1.Extents);
        RemoveAllShapes;

        // force fields in PU Layer table
        ForceCPlanFields;

        // write data to PU Layer table
        Table1.DatabaseName := ExtractFilePath(SCPForm.sDDEPULayer);
        sTableName := ExtractFileName(SCPForm.sDDEPULayer);
        sTableName := Copy(sTableName,1,Length(sTableName) - Length(ExtractFileExt(sTableName))) + '.dbf';
        Table1.TableName := sTableName;
        Table1.Open;
        for iCount := 1 to Table1.RecordCount do
        begin
             Table1.Edit;
             Table1.FieldByName('DISPLAY').AsString := '';

             iPUID := Table1.FieldByName(SCPForm.sDDEPUKey).AsInteger;

             iPUIndex := BinaryLookup_Integer(PUID_array,iPUID,1,PUID_array.lMaxSize);
             if (iPUIndex <> -1) then
             begin
                  PUID_array.rtnValue(iPUIndex,@iValue);
                  if (iPUID = iValue) then
                  begin
                       DISPLAY_array.rtnValue(iPUIndex,@sDisplay);
                       Table1.FieldByName('DISPLAY').AsString := sDisplay;
                  end;
             end;

             Table1.Next;
        end;


        // add layer to GIS display
        GIS_Child.RestoreAllShapes;
        GIS_Child.Map1.Extents := myExtents;

        PUID_array.Destroy;
        DISPLAY_array.Destroy;
        //VALUES_array.Destroy;

     finally
            Table1.Close;
     end;
end;

function DDEDisplay2Colour(const sValue : string) : TColor;
begin
     // RGB color intensities for blue, green, and red, respectively.
     // The value represents full-intensity,
     // pure blue  $00FF0000
     // pure green $0000FF00
     // pure red   $000000FF
     // black      $00000000
     // white      $00FFFFFF

     // 'Res' RGB 0 0 255       Pure blue
     // 'Exc' RGB 120 120 120   Grey
     // 'R1' RGB 0 95 99        Greeny Blue
     // 'SQL' RGB 255 0 255     Pink
     // 'Res' RGB 0 0 255
     // 'Res' RGB 0 0 255
     // 001-005 green spectrum
     Result := Rgb(0,0,0);

     if (sValue = 'Ava') then Result := Rgb(0,0,255); // pure blue
     if (sValue = 'Def') then Result := Rgb(0,0,255);
     if (sValue = 'Exc') then Result := Rgb(120,120,120);
     if (sValue = 'Flg') then Result := Rgb(255,0,255);
     if (sValue = 'Ign') then Result := Rgb(120,120,120);
     if (sValue = 'SQL') then Result := Rgb(255,0,255);
     if (sValue = 'Res') then Result := Rgb(0,0,255);
     if (sValue = 'Man') then Result := Rgb(0,95,99);
     if (sValue = 'Neg') then Result := Rgb(0,95,99);
     if (sValue = 'PDe') then Result := Rgb(0,95,99);
     if (sValue = 'R1') then Result := Rgb(0,95,99);
     if (sValue = 'R2') then Result := Rgb(0,95,99);
     if (sValue = 'R3') then Result := Rgb(0,95,99);
     if (sValue = 'R4') then Result := Rgb(0,95,99);
     if (sValue = 'R5') then Result := Rgb(0,95,99);
     if (sValue = 'Max') then Result := Rgb(0,60,0);
     if (sValue = 'Ir1') then Result := Rgb(0,60,0);
     if (sValue = '001') then Result := Rgb(0,100,0);
     if (sValue = '002') then Result := Rgb(0,140,0);
     if (sValue = '003') then Result := Rgb(0,180,0);
     if (sValue = '004') then Result := Rgb(0,220,0);
     if (sValue = '005') then Result := Rgb(0,255,0);
     if (sValue = '0Co') then Result := Rgb(255,255,255);
end;

function DDEDisplay2Index(const sValue : string) : integer;
begin
     Result := 0;

     if (sValue = 'Ava') then Result := 1;
     if (sValue = 'Def') then Result := 2;
     if (sValue = 'Exc') then Result := 3;
     if (sValue = 'Flg') then Result := 4;
     if (sValue = 'Ign') then Result := 5;
     if (sValue = 'SQL') then Result := 6;
     if (sValue = 'Res') then Result := 7;
     if (sValue = 'Man') then Result := 8;
     if (sValue = 'Neg') then Result := 9;
     if (sValue = 'PDe') then Result := 10;
     if (sValue = 'R1') then Result := 11;
     if (sValue = 'R2') then Result := 12;
     if (sValue = 'R3') then Result := 13;
     if (sValue = 'R4') then Result := 14;
     if (sValue = 'R5') then Result := 15;
     if (sValue = 'Max') then Result := 16;
     if (sValue = 'Ir1') then Result := 17;
     if (sValue = '001') then Result := 18;
     if (sValue = '002') then Result := 19;
     if (sValue = '003') then Result := 20;
     if (sValue = '004') then Result := 21;
     if (sValue = '005') then Result := 22;
     if (sValue = '0Co') then Result := 23;
end;

function DDEIndex2Display(const iValue : integer) : string;
begin
     case iValue of
          1 : Result := 'Ava';
          2 : Result := 'Def';
          3 : Result := 'Exc';
          4 : Result := 'Flg';
          5 : Result := 'Ign';
          6 : Result := 'SQL';
          7 : Result := 'Res';
          8 : Result := 'Man';
          9 : Result := 'Neg';
          10 : Result := 'PDe';
          11 : Result := 'R1';
          12 : Result := 'R2';
          13 : Result := 'R3';
          14 : Result := 'R4';
          15 : Result := 'R5';
          16 : Result := 'Max';
          17 : Result := 'Ir1';
          18 : Result := '001';
          19 : Result := '002';
          20 : Result := '003';
          21 : Result := '004';
          22 : Result := '005';
          23 : Result := '0Co';
     else
         Result := '';
     end;
end;

procedure TGIS_Child.UpdateDDEMap;
var
   iCount, iField, iUpdateLayer, iDisplayCategory : integer;
   sf: MapWinGIS_TLB.Shapefile;
   AColour : TColor;
   sValue : string;
   fCategory : boolean;

   function ValueToDisplayColour(const sValue : string) : TColor;
   begin
        Result := DDEDisplay2Colour(sValue);
        iDisplayCategory := DDEDisplay2Index(sValue);

        if (iDisplayCategory > 0) then
           DDEMapCategories.setValue(iDisplayCategory,@fCategory);
   end;
begin
     // refresh GIS display on DDE request

     iUpdateLayer := -1;
     for iCount := 0 to (Map1.NumLayers-1) do
         if (Map1.LayerName[iCount] = SCPForm.sDDEPULayer) then
            iUpdateLayer := iCount;

     if (iUpdateLayer > -1) then
     begin
          // get handle for shapefile in the view
          sf := IShapefile(Map1.GetObject[Map1.LayerHandle[iUpdateLayer]]);

          // find index for field
          iField := -1;
          for iCount := 0 to (sf.Get_NumFields-1) do
          begin
               if (sf.Get_Field(iCount).Name = 'DISPLAY') then
                  iField := iCount;
          end;

          if fDDEMapCategories then
             DDEMapCategories.Destroy;
          fDDEMapCategories := True;
          DDEMapCategories := Array_t.create;
          DDEMapCategories.init(SizeOf(boolean),23);
          fCategory := False;
          for iCount := 1 to 23 do
              DDEMapCategories.setValue(iCount,@fCategory);
          fCategory := True;

          if (iField > -1) then
          begin
               for iCount := 1 to sf.NumShapes do
               begin
                    sValue := sf.Get_CellValue(iField,iCount);

                    AColour := ValueToDisplayColour(sValue);

                    Map1.ShapeFillColor[iUpdateLayer,iCount-1] := AColour;

                    if SCPForm.ShapeOutlines1.Checked then
                       Map1.ShapeLayerLineColor[iUpdateLayer] := clBlack
                    else
                        Map1.ShapeLineColor[iUpdateLayer,iCount-1] := AColour;
               end;

               CheckListBox1.ItemIndex := 0;
               Timer1.Interval := 1;
               Timer1.Enabled := True;
          end;
     end;
end;

procedure TGIS_Child.LoadLegendIni;
var
   AIni : TIniFile;
begin
     AIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'ZC_legend.ini');

     AIni.ReadString('','','');

     AIni.Free;
end;

procedure TGIS_Child.SaveLegendIni;
var
   AIni : TIniFile;
begin
     AIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'ZC_legend.ini');

     AIni.WriteString('','','');

     AIni.Free;
end;

procedure WriteGridHeaderAscii(sOutFile : string; gh1 : MapWinGIS_TLB.GridHeader);
var
   OutFile : TextFile;
   sTmp : string;
begin
     assignfile(OutFile,sOutFile);
     rewrite(OutFile);
     writeln(OutFile,'NumberCols ' + IntToStr(gh1.NumberCols));
     writeln(OutFile,'NumberRows ' + IntToStr(gh1.NumberRows));
     writeln(OutFile,'dX ' + FloatToStr(gh1.dX));
     writeln(OutFile,'dY ' + FloatToStr(gh1.dY));
     writeln(OutFile,'XllCenter ' + FloatToStr(gh1.XllCenter));
     writeln(OutFile,'YllCenter ' + FloatToStr(gh1.YllCenter));
     sTmp := gh1.Projection;
     writeln(OutFile,'Projection ' + sTmp);
     sTmp := gh1.Notes;
     writeln(OutFile,'Notes ' + sTmp);
     sTmp := gh1.Key;
     writeln(OutFile,'Key ' + sTmp);
     writeln(OutFile,'NodataValue ' + IntToStr(gh1.NodataValue));

     closefile(OutFile);
end;

function TGIS_Child.GridFile2ImageFile(sGridfile, sNewImagefile : string;
                               const fSaveImage : boolean) : integer;
var
   grid1 : MapWinGIS_TLB.Grid;
   scheme1 : MapWinGIS_TLB.GridColorScheme;
   image1 : MapWinGIS_TLB.Image;
   util1 : MapWinGIS_TLB.Utils;
begin
     grid1 := CoGrid.Create();
     grid1.Open(sGridfile,
                LongDataType,
                False,
                Binary,
                nil);

     scheme1 := CoGridColorScheme.Create();

     scheme1.NoDataColor := clBlack;
     scheme1.UsePredefined(grid1.Minimum,
                           grid1.Maximum,
                           SummerMountains);

     util1 := CoUtils.Create();

     image1 := util1.GridToImage(grid1,scheme1,nil);
     if fSaveImage then
        image1.Save(sNewImagefile,true,BITMAP_FILE,nil);

     Result := Map1.AddLayer(image1, true);
     Map1.LayerName[Map1.NumLayers] := 'grid';
end;

procedure Polygon2Image(const sInputPolygonfile,sFieldToUse,sOutputGridfile,sOutputImagefile : string;
                        const iGridCellSize : integer);
var
   sf : MapWinGIS_TLB.Shapefile;
   gh1 : MapWinGIS_TLB.GridHeader;
   grid1 : MapWinGIS_TLB.Grid;
   scheme1 : MapWinGIS_TLB.GridColorScheme;
   image1 : MapWinGIS_TLB.Image;
   util1 : MapWinGIS_TLB.Utils;
   sSaveName : string;
   iRow, iCol, iShape, iField, iFieldToUse, iShapeKey : integer;
   rX, rY : double;
begin
     sf := CoShapefile.Create();
     sf.Open(sInputPolygonfile, nil);

     // we create a new grid header based on shape file extent and specified grid cell size
     gh1 := CoGridHeader.Create();
     gh1.NumberCols := Round(sf.Extents.xMax - sf.Extents.xMin) div iGridCellSize;
     gh1.NumberRows := Round(sf.Extents.yMax - sf.Extents.yMin) div iGridCellSize;
     gh1.dX := iGridCellSize;
     gh1.dY := iGridCellSize;
     gh1.XllCenter := sf.Extents.xMin;
     gh1.YllCenter := sf.Extents.yMin;
     gh1.Projection := '';
     gh1.Notes := '';
     gh1.Key := '';
     gh1.NodataValue := 255;

     // create new grid
     grid1 := CoGrid.Create();
     grid1.CreateNew(sOutputGridfile,gh1,
                     LongDataType,0,False,
                     Esri,nil);

     scheme1 := CoGridColorScheme.Create();

     scheme1.NoDataColor := clBlack;
     scheme1.UsePredefined(grid1.Minimum,
                           grid1.Maximum,
                           SummerMountains);

     util1 := CoUtils.Create();

     // find index of integer field we are converting
     iFieldToUse := 0;
     for iField := 0 to (sf.NumFields-1) do
     begin
          if (sf.Field[iField].Name = sFieldToUse) then
             iFieldToUse := iField;
     end;

     sf.BeginPointInShapefile;

     for iRow := 1 to grid1.Header.NumberRows do
         for iCol := 1 to grid1.Header.NumberCols do
         begin
              grid1.CellToProj(iCol,iRow,rX,rY);
              iShape := sf.PointInShapefile(rX,rY);

              if (iShape > -1) then
                 // set grid value as equal to PUID
                 grid1.Value[iCol,iRow] := sf.CellValue[iFieldToUse,iShape]
              else
                  // set grid value as equal to NODATA
                  grid1.Value[iCol,iRow] := grid1.Header.NodataValue;
         end;

     sf.EndPointInShapefile;

     if (sOutputGridfile <> '') then
        grid1.Save(sOutputGridfile,Esri,nil);

     image1 := util1.GridToImage(grid1,scheme1,nil);
     image1.Save(sOutputImagefile,true,BITMAP_FILE,nil);
end;

procedure TGIS_Child.Polygon2Grid(sf1 : MapWinGIS_TLB.Shapefile;
                                  sShapeKeyField : string;
                                  grid1 : MapWinGIS_TLB.Grid);
var
   iRow, iCol, iShape, iField, iKeyField, iShapeKey : integer;
   rX, rY : double;
   sTmp : string;
   OutFile : TextFile;
begin
     assignfile(OutFile,'D:\Marxan101\mapwindow\convert_poly_to_grid.txt');
     rewrite(OutFile);

     writeln(OutFile,'shape xMin ' + FloatToStr(sf1.Extents.xMin));
     writeln(OutFile,'shape xMax ' + FloatToStr(sf1.Extents.xMax));
     writeln(OutFile,'shape yMin ' + FloatToStr(sf1.Extents.yMin));
     writeln(OutFile,'shape yMax ' + FloatToStr(sf1.Extents.yMax));
     writeln(OutFile);

     writeln(OutFile,'col,row,x,y,shape');

     // find index of key field
     iKeyField := -1;
     for iField := 0 to (sf1.NumFields-1) do
     begin
          sTmp := sf1.Field[iField].Name;
          if (sTmp = sShapeKeyField) then
             iKeyField := iField;
     end;

     sf1.BeginPointInShapefile;

     for iRow := 1 to grid1.Header.NumberRows do
         for iCol := 1 to grid1.Header.NumberCols do
         begin
              grid1.CellToProj(iCol,iRow,rX,rY);
              iShape := sf1.PointInShapefile(rX,rY);

              if (iShape > -1) then
              begin
                   // set grid value as equal to PUID
                   iShapeKey := sf1.CellValue[iKeyField,iShape];
                   grid1.Value[iCol,iRow] := iShapeKey;
              end
              else
                  // set grid value as equal to NODATA
                  grid1.Value[iCol,iRow] := grid1.Header.NodataValue;

              //writeln(OutFile,IntToStr(iCol) + ',' + IntToStr(iRow) + ',' +
              //                FloatToStr(rX) + ',' + FloatToStr(rY) + ',' +
              //                IntToStr(iShape) + ',' + FloatToStr(iSPKey));
         end;

     sf1.EndPointInShapefile;

     closefile(OutFile);

//stepping through each row and column
//
//   Grid.CellToProj (find coords of the center of that cell)
//   Shapefile.PointInShapefile find which (if any) polygon that cell falls within
//   Shapefile.CellValue(FieldIndex,ShapeIndex) get polygon attribute
//   put attribute in grid cell (or NoData if the PointInShapefile returned nothing)
//
//ensure grid data is of the same data type at polygon field
end;

function TGIS_Child.PolygonFile2GridFile(const sPolygonfile,
                                               sExistinggridfile,
                                               sNewgridfile : string;
                                         const iGridCellSize : integer) : integer;
         // calls function Polygon2Grid
         // reads grid header from nominated grid file
         // creates new grid file
         // returns handle to created grid
var
   sf : MapWinGIS_TLB.Shapefile;
   gh1 : MapWinGIS_TLB.GridHeader;
   grid1, grid2 : MapWinGIS_TLB.Grid;
   scheme1 : MapWinGIS_TLB.GridColorScheme;
   sSaveName : string;
begin
     sf := CoShapefile.Create();
     sf.Open(sPolygonfile, nil);

     if (sExistinggridfile = '') then
     begin // we create a new grid header based on shape file extent and specified grid cell size
          gh1 := CoGridHeader.Create();
          gh1.NumberCols := Round(sf.Extents.xMax - sf.Extents.xMin) div iGridCellSize;
          gh1.NumberRows := Round(sf.Extents.yMax - sf.Extents.yMin) div iGridCellSize;
          gh1.dX := iGridCellSize;
          gh1.dY := iGridCellSize;
          gh1.XllCenter := sf.Extents.xMin;
          gh1.YllCenter := sf.Extents.yMin;
          gh1.Projection := '';
          gh1.Notes := '';
          gh1.Key := '';
          gh1.NodataValue := 255;

          sSaveName := Copy(sPolygonfile,1,Length(sPolygonfile) - Length(ExtractFileExt(sPolygonfile)));
          WriteGridHeaderAscii(sSaveName + '_1header.txt',gh1);

          // create new grid
          grid2 := CoGrid.Create();
          grid2.CreateNew(sNewgridfile,gh1,
                          LongDataType,0,False,
                          Esri,nil);
          WriteGridHeaderAscii(sSaveName + '_2header.txt',grid2.Header);
     end
     else
     begin // we take the grid header from the grid file specified
          grid1 := CoGrid.Create();
          grid1.Open(sExistinggridfile,
                     LongDataType,
                     False,
                     Binary,
                     nil);

          sSaveName := Copy(sNewgridfile,1,Length(sNewgridfile) - Length(ExtractFileExt(sNewgridfile)));
          WriteGridHeaderAscii(sSaveName + '_1header.txt',grid1.Header);

          // create new grid
          grid2 := CoGrid.Create();
          grid2.CreateNew(sNewgridfile,grid1.Header,
                          LongDataType,0,False,
                          Esri,nil);
          WriteGridHeaderAscii(sSaveName + '_2header.txt',grid2.Header);
     end;

     scheme1 := CoGridColorScheme.Create();

     scheme1.NoDataColor := clBlack;
     scheme1.UsePredefined(grid2.Minimum,
                           grid2.Maximum,
                           SummerMountains);

     Polygon2Grid(sf,'PUID',grid2);

     grid2.Save(sSaveName,Esri,nil);

     Result := Map1.AddLayer(grid2, true);
     Map1.LayerName[Map1.NumLayers] := 'grid';
end;

function TGIS_Child.PolygonFile2GridFile2ImageFile(const sPolygonfile,
                                                         sExistinggridfile,
                                                         sNewgridfile,
                                                         sNewImageFilename : string;
                                                   const iGridCellSize : integer;
                                                   const fSaveImage : boolean) : integer;
         // calls function Polygon2Grid
         // reads grid header from nominated grid file
         // creates new grid and image files
         // returns handle to created image
var
   sf : MapWinGIS_TLB.Shapefile;
   gh1 : MapWinGIS_TLB.GridHeader;
   grid1, grid2 : MapWinGIS_TLB.Grid;
   scheme1 : MapWinGIS_TLB.GridColorScheme;
   image1 : MapWinGIS_TLB.Image;
   util1 : MapWinGIS_TLB.Utils;
   sSaveName : string;
begin
     //utils1 := CoUtils.Create();
     sf := CoShapefile.Create();
     sf.Open(sPolygonfile, nil);

     if (sExistinggridfile = '') then
     begin // we create a new grid header based on shape file extent and specified grid cell size
          gh1 := CoGridHeader.Create();
          gh1.NumberCols := Round(sf.Extents.xMax - sf.Extents.xMin) div iGridCellSize;
          gh1.NumberRows := Round(sf.Extents.yMax - sf.Extents.yMin) div iGridCellSize;
          gh1.dX := iGridCellSize;
          gh1.dY := iGridCellSize;
          gh1.XllCenter := sf.Extents.xMin;
          gh1.YllCenter := sf.Extents.yMin;
          gh1.Projection := '';
          gh1.Notes := '';
          gh1.Key := '';
          gh1.NodataValue := 255;

          sSaveName := Copy(sPolygonfile,1,Length(sPolygonfile) - Length(ExtractFileExt(sPolygonfile)));
          WriteGridHeaderAscii(sSaveName + '_1header.txt',gh1);

          // create new grid
          grid2 := CoGrid.Create();
          grid2.CreateNew(sNewgridfile,gh1,
                          LongDataType,0,False,
                          Esri,nil);
          WriteGridHeaderAscii(sSaveName + '_2header.txt',grid2.Header);
     end
     else
     begin // we take the grid header from the grid file specified
          grid1 := CoGrid.Create();
          grid1.Open(sExistinggridfile,
                     LongDataType,
                     False,
                     Binary,
                     nil);


          sSaveName := Copy(sNewgridfile,1,Length(sNewgridfile) - Length(ExtractFileExt(sNewgridfile)));
          WriteGridHeaderAscii(sSaveName + '_1header.txt',grid1.Header);

          // create new grid
          grid2 := CoGrid.Create();
          grid2.CreateNew(sNewgridfile,grid1.Header,
                          LongDataType,0,False,
                          Esri,nil);
          WriteGridHeaderAscii(sSaveName + '_2header.txt',grid2.Header);
     end;

     scheme1 := CoGridColorScheme.Create();

     scheme1.NoDataColor := clBlack;
     scheme1.UsePredefined(grid2.Minimum,
                           grid2.Maximum,
                           SummerMountains);

     util1 := CoUtils.Create();

     Polygon2Grid(sf,'PUID',grid2);

     grid2.Save(sSaveName,Esri,nil);

     image1 := util1.GridToImage(grid2,scheme1,nil);
     if fSaveImage then
        image1.Save(sNewImageFilename,true,BITMAP_FILE,nil);

     Result := Map1.AddLayer(image1, true);
     Map1.LayerName[Map1.NumLayers] := 'grid';
end;

procedure TGIS_Child.TabulatePolygon2Grid(sf1 : MapWinGIS_TLB.Shapefile;
                                          sShapeKeyField : string;
                                          grid1 : MapWinGIS_TLB.Grid);
var
   iRow, iCol, iShape, iField, iKeyField, iSPKey, iPU, iSP, iPUCount, iSPCount, iSPIndex : integer;
   rX, rY : double;
   sTmp : string;
   OutFile, SPFile, PUvSPFile : TextFile;
   PU_,SP_,PUvSP_ : Variant;
   //extent1 : MapWinGis_TLB.Extent;
begin
     // using PointInShapeFile leaves horizontal lines 1 grid cell high between the rows of planning units
     // instead investigate using SelectShapes to avoid this error.  use + or - (grid cell size / 2) as the
     // bounds for SelectShapes.
     // choose the first shape in the list of shapes selected
     // This might not be an error at all. on closer investigation it requires further investigation.

     // MapTimes_Gis.PixelToProj X - 5, Y - 5, pt1.X, pt1.Y
     // MapTimes_Gis.PixelToProj X + 5, Y + 5, pt2.X, pt2.Y
     // ext.SetBounds(pt1.X, pt1.Y, 0, pt2.X, pt2.Y, 0)
     // If sf.SelectShapes(ext, 0.0, MapWinGIS.SelectMode.INTERSECTION, shapes) = True Then

     assignfile(OutFile,'D:\Marxan101\mapwindow\tabulate_poly_to_grid.txt');
     rewrite(OutFile);

     writeln(OutFile,'shape xMin ' + FloatToStr(sf1.Extents.xMin));
     writeln(OutFile,'shape xMax ' + FloatToStr(sf1.Extents.xMax));
     writeln(OutFile,'shape yMin ' + FloatToStr(sf1.Extents.yMin));
     writeln(OutFile,'shape yMax ' + FloatToStr(sf1.Extents.yMax));
     writeln(OutFile);

     writeln(OutFile,'col,row,x,y,shape');

     iPU := sf1.NumShapes;
     iSP := grid1.Maximum + 1;

     PU_ := VarArrayCreate([0,iPU-1],varInteger);
     SP_ := VarArrayCreate([0,iSP-1],varInteger);
     PUvSP_ := VarArrayCreate([0,iPU-1,0,iSP-1],varInteger);

     VarArrayLock(PU_);
     VarArrayLock(SP_);
     VarArrayLock(PUvSP_);

     for iPUCount := 0 to (iPU-1) do
     begin
          PU_[iPUCount] := 0;

          for iSPCount := 0 to (iSP-1) do
              PUvSP_[iPUCount,iSPCount] := 0;
     end;

     for iSPCount := 0 to (iSP-1) do
         SP_[iSPCount] := 0;

     // find index of key field
     iKeyField := -1;
     for iField := 0 to (sf1.NumFields-1) do
     begin
          sTmp := sf1.Field[iField].Name;
          if (sTmp = sShapeKeyField) then
             iKeyField := iField;
     end;

     sf1.BeginPointInShapefile;

     for iRow := 1 to grid1.Header.NumberRows do
         for iCol := 1 to grid1.Header.NumberCols do
         begin
              grid1.CellToProj(iCol,iRow,rX,rY);
              iSPKey := grid1.Value[iCol,iRow];

              if (iSPKey <= iSP) then
              begin
                   iShape := sf1.PointInShapefile(rX,rY);

                   if (iShape > -1) then
                   begin
                        PU_[iShape] := PU_[iShape] + 1;
                        SP_[iSPKey] := SP_[iSPKey] + 1;
                        PUvSP_[iShape,iSPKey] := PUvSP_[iShape,iSPKey] + 1;
                   end;

                   //writeln(OutFile,IntToStr(iCol) + ',' + IntToStr(iRow) + ',' +
                   //                FloatToStr(rX) + ',' + FloatToStr(rY) + ',' +
                   //                IntToStr(iShape) + ',' + FloatToStr(iSPKey));
              end;
         end;

     sf1.EndPointInShapefile;

     closefile(OutFile);

     assignfile(SPFile,'D:\Marxan101\mapwindow\sp.csv');
     rewrite(SPFile);
     writeln(SPFile,'id,name,target,spf');

     assignfile(PUvSPFile,'D:\Marxan101\mapwindow\puvsp.csv');
     rewrite(PUvSPFile);
     write(PUvSPFile,'id');

     iSPIndex := 0;
     for iSPCount := 0 to (iSP-1) do
         if (SP_[iSPCount] > 0) then
         begin
              Inc(iSPIndex);
              writeln(SPFile,IntToStr(iSPIndex) + ',' + IntToStr(iSPCount) + ',1,1');
              write(PUvSPFile,',' + IntToStr(iSPCount));
         end;

     writeln(PUvSPFile);

     for iPUCount := 0 to (iPU-1) do
         if (PU_[iPUCount] > 0) then
         begin
              write(PUvSPFile,IntToStr(sf1.CellValue[iKeyField,iPUCount]));

              for iSPCount := 0 to (iSP-1) do
                  if (SP_[iSPCount] > 0) then
                     write(PUvSPFile,',' + IntToStr(PUvSP_[iPUCount,iSPCount] * grid1.Header.dX * grid1.Header.dY));

              writeln(PUvSPFile);
         end;

     closefile(SPFile);
     closefile(PUvSPFile);

     VarArrayUnlock(PU_);
     VarArrayUnlock(SP_);
     VarArrayUnlock(PUvSP_);

     VarClear(PU_);
     VarClear(SP_);
     VarClear(PUvSP_);

//stepping through each row and column
//
//   Grid.CellToProj (find coords of the center of that cell)
//   Shapefile.PointInShapefile find which (if any) polygon that cell falls within
//   Shapefile.CellValue(FieldIndex,ShapeIndex) get polygon attribute
//   put attribute in grid cell (or NoData if the PointInShapefile returned nothing)
//
//ensure grid data is of the same data type at polygon field
end;

procedure TGIS_Child.IntersectImageFiles(const sImage1File, sImage2File, sOutputFile : string);
var
   image1, image2 : MapWinGIS_TLB.Image;
   iRow, iCol, iPUValue, iSPValue : integer;
   OutFile : TextFile;
begin
     // intersect our planning unit image and our vegetation image to produce a tabulate areas report
     image1 := CoImage.Create;
     image2 := CoImage.Create;

     image1.Open(sImage1File,BITMAP_FILE,true,nil);
     image2.Open(sImage2File,BITMAP_FILE,true,nil);

     assignfile(OutFile,sOutputFile);
     rewrite(OutFile);
     writeln(OutFile,'pu,sp');

     for iCol := 0 to (image1.Width - 1) do
         for iRow := 0 to (image1.Height -1) do
         begin
              iPUValue := image1.Value[iRow,iCol];
              iSPValue := image2.Value[iRow,iCol];

              if (iPUValue <> 0) and (iSPValue <> 0) then
              begin
                   writeln(OutFile,IntToStr(iPUValue) + ',' + IntToStr(iSPValue));
              end;
         end;

     closefile(OutFile);
end;

procedure TGIS_Child.IntersectGrids(const iGrid1Handle, iGrid2Handle : integer;
                                    const sOutputPUVSPFile, sOutputSPFile,
                                          sOutputPUFile : string;
                                    const fCreatePUFile : boolean);
var
   grid1, grid2 : MapWinGIS_TLB.Grid;
   iRow, iCol, iPUValue, iSPValue, iPU, iSP, iPUCount, iSPCount, iSPIndex : integer;
   PUFile, SPFile, PUvSPFile : TextFile;
   PU_,SP_,PUvSP_ : Variant;
begin
     // intersect 2 images to produce a tabulate areas report
     grid1 := IGrid(Map1.GetObject[iGrid1Handle]);
     grid2 := IGrid(Map1.GetObject[iGrid2Handle]);

     iPU := grid1.Maximum + 1;
     iSP := grid2.Maximum + 1;

     PU_ := VarArrayCreate([0,iPU-1],varInteger);
     SP_ := VarArrayCreate([0,iSP-1],varInteger);
     PUvSP_ := VarArrayCreate([0,iPU-1,0,iSP-1],varInteger);

     VarArrayLock(PU_);
     VarArrayLock(SP_);
     VarArrayLock(PUvSP_);

     for iPUCount := 0 to (iPU-1) do
     begin
          PU_[iPUCount] := 0;

          for iSPCount := 0 to (iSP-1) do
              PUvSP_[iPUCount,iSPCount] := 0;
     end;

     for iSPCount := 0 to (iSP-1) do
         SP_[iSPCount] := 0;

     for iCol := 0 to (grid1.Header.NumberCols - 1) do
         for iRow := 0 to (grid1.Header.NumberRows -1) do
         begin
              iPUValue := grid1.Value[iRow,iCol];
              iSPValue := grid2.Value[iRow,iCol];

              if (iSPValue <> grid2.Header.NodataValue) then
              begin
                   PU_[iPUValue] := PU_[iPUValue] + 1;
                   SP_[iSPValue] := SP_[iSPValue] + 1;
                   PUvSP_[iPUValue,iSPValue] := PUvSP_[iPUValue,iSPValue] + 1;
              end;
         end;

     assignfile(SPFile,sOutputSPFile);
     rewrite(SPFile);
     writeln(SPFile,'id,name,target,spf');

     assignfile(PUvSPFile,sOutputPUVSPFile);
     rewrite(PUvSPFile);
     write(PUvSPFile,'id');

     if fCreatePuFile then
     begin
          assignfile(PUFile,sOutputPUFile);
          rewrite(PUFile);
          write(PUFile,'id');

          for iPUCount := 0 to (iPU-1) do
              writeln(PUFile,IntToStr(iPUCount));

          closefile(PUFile);
     end;

     iSPIndex := 0;
     for iSPCount := 0 to (iSP-1) do
         if (SP_[iSPCount] > 0) then
         begin
              Inc(iSPIndex);
              writeln(SPFile,IntToStr(iSPIndex) + ',' + IntToStr(iSPCount) + ',1,1');
              write(PUvSPFile,',' + IntToStr(iSPCount));
         end;

     writeln(PUvSPFile);

     for iPUCount := 0 to (iPU-1) do
         if (PU_[iPUCount] > 0) then
         begin
              write(PUvSPFile,IntToStr(iPUCount));

              for iSPCount := 0 to (iSP-1) do
                  if (SP_[iSPCount] > 0) then
                     write(PUvSPFile,',' + IntToStr(PUvSP_[iPUCount,iSPCount] * grid2.Header.dX * grid2.Header.dY));

              writeln(PUvSPFile);
         end;

     closefile(SPFile);
     closefile(PUvSPFile);

     VarArrayUnlock(PU_);
     VarArrayUnlock(SP_);
     VarArrayUnlock(PUvSP_);

     VarClear(PU_);
     VarClear(SP_);
     VarClear(PUvSP_);
end;

procedure TGIS_Child.IntersectGridFiles(const sGrid1File, sGrid2File,
                                          sOutputPUVSPFile, sOutputSPFile,
                                          sOutputPUFile : string;
                                    const fCreatePUFile : boolean);
var
   grid1, grid2 : MapWinGIS_TLB.Grid;
   iRow, iCol, iPUValue, iSPValue, iPU, iSP, iPUCount, iSPCount, iSPIndex : integer;
   PUFile, SPFile, PUvSPFile : TextFile;
   PU_,SP_,PUvSP_ : Variant;
begin
     // intersect 2 images to produce a tabulate areas report
     grid1 := CoGrid.Create;
     grid2 := CoGrid.Create;

     grid1.Open(sGrid1File,LongDataType,true,Esri,nil);
     grid2.Open(sGrid2File,LongDataType,true,Esri,nil);

     iPU := grid1.Maximum + 1;
     iSP := grid2.Maximum + 1;

     PU_ := VarArrayCreate([0,iPU-1],varInteger);
     SP_ := VarArrayCreate([0,iSP-1],varInteger);
     PUvSP_ := VarArrayCreate([0,iPU-1,0,iSP-1],varInteger);

     VarArrayLock(PU_);
     VarArrayLock(SP_);
     VarArrayLock(PUvSP_);

     for iPUCount := 0 to (iPU-1) do
     begin
          PU_[iPUCount] := 0;

          for iSPCount := 0 to (iSP-1) do
              PUvSP_[iPUCount,iSPCount] := 0;
     end;

     for iSPCount := 0 to (iSP-1) do
         SP_[iSPCount] := 0;

     for iCol := 0 to (grid1.Header.NumberCols - 1) do
         for iRow := 0 to (grid1.Header.NumberRows -1) do
         begin
              iPUValue := grid1.Value[iRow,iCol];
              iSPValue := grid2.Value[iRow,iCol];

              if (iSPValue <> grid2.Header.NodataValue) then
              begin
                   PU_[iPUValue] := PU_[iPUValue] + 1;
                   SP_[iSPValue] := SP_[iSPValue] + 1;
                   PUvSP_[iPUValue,iSPValue] := PUvSP_[iPUValue,iSPValue] + 1;
              end;
         end;

     assignfile(SPFile,sOutputSPFile);
     rewrite(SPFile);
     writeln(SPFile,'id,name,target,spf');

     assignfile(PUvSPFile,sOutputPUVSPFile);
     rewrite(PUvSPFile);
     write(PUvSPFile,'id');

     if fCreatePuFile then
     begin
          assignfile(PUFile,sOutputPUFile);
          rewrite(PUFile);
          write(PUFile,'id');

          for iPUCount := 0 to (iPU-1) do
              writeln(PUFile,IntToStr(iPUCount));

          closefile(PUFile);
     end;

     iSPIndex := 0;
     for iSPCount := 0 to (iSP-1) do
         if (SP_[iSPCount] > 0) then
         begin
              Inc(iSPIndex);
              writeln(SPFile,IntToStr(iSPIndex) + ',' + IntToStr(iSPCount) + ',1,1');
              write(PUvSPFile,',' + IntToStr(iSPCount));
         end;

     writeln(PUvSPFile);

     for iPUCount := 0 to (iPU-1) do
         if (PU_[iPUCount] > 0) then
         begin
              write(PUvSPFile,IntToStr(iPUCount));

              for iSPCount := 0 to (iSP-1) do
                  if (SP_[iSPCount] > 0) then
                     write(PUvSPFile,',' + IntToStr(PUvSP_[iPUCount,iSPCount] * grid2.Header.dX * grid2.Header.dY));

              writeln(PUvSPFile);
         end;

     closefile(SPFile);
     closefile(PUvSPFile);

     VarArrayUnlock(PU_);
     VarArrayUnlock(SP_);
     VarArrayUnlock(PUvSP_);

     VarClear(PU_);
     VarClear(SP_);
     VarClear(PUvSP_);
end;

function TGIS_Child.ReturnSelectedShapeCount : integer;
var
   iCount : integer;
   fSelection : boolean;
begin
     Result := 0;

     if fShapeSelection then
        for iCount := 1 to ShapeSelection.lMaxSize do
        begin
             ShapeSelection.rtnValue(iCount,@fSelection);
             if fSelection then
                Inc(Result);
        end;
end;

procedure CaptureScreenShot(DestBitmap : TBitmap;
                            iTop,iLeft,iHeight,iWidth : integer) ;
var
   DC : HDC;
begin
     DC := GetDC (GetDesktopWindow) ;
     try
        DestBitmap.Width := iWidth;//GetDeviceCaps (DC, HORZRES) ;
        DestBitmap.Height := iHeight;//GetDeviceCaps (DC, VERTRES) ;
        BitBlt(DestBitmap.Canvas.Handle,
               0,
               0,
               DestBitmap.Width,
               DestBitmap.Height,
               DC,
               iLeft,//0,
               iTop,//0,
               SRCCOPY) ;
     finally
            ReleaseDC (GetDesktopWindow, DC) ;
     end;
end;

procedure TGIS_Child.SaveMapToBmpFile(const sFilename : string);
var
   iTop,iLeft : integer;
begin
     try
        iTop := SCPForm.Top + (SCPForm.Height - SCPForm.ClientHeight) +
                GIS_Child.Top + (GIS_Child.Height - GIS_Child.ClientHeight) +
                Map1.Top-7;

        iLeft := SCPForm.Left + (SCPForm.Width - SCPForm.ClientWidth) +
                 GIS_Child.Left + (GIS_Child.Width - GIS_Child.ClientWidth) +
                 Map1.Left-7;

        CaptureScreenShot(Image1.Picture.Bitmap,
                          iTop,
                          iLeft,
                          Map1.Height,
                          Map1.Width);

        Image1.Picture.SaveToFile(sFilename);

     except
           MessageDlg('Exception in SaveMapToBmpFile',mtError,[mbOk],0);
           Application.Terminate;
     end;
     {Image1.Picture.Bitmap.Height := Height;
     Image1.Picture.Bitmap.Width := Width;
     for iHeight := 0 to (Height - 1) do
         for iWidth := 0 to (Width - 1) do
             Image1.Picture.Bitmap.Canvas.Pixels[iWidth,iHeight] := Canvas.Pixels[iWidth,iHeight];}

    (*     Private Sub SnapShot()
        Dim image As New MapWinGIS.Image()
        Dim extents As MapWinGIS.Extents
        'Set extents to be the extents of the map
        extents = CType(Map1.Extents, MapWinGIS.Extents)
        'Take a picture of what is being displayed in map1 and store it in image
        image = Map1.SnapShot(extents)
    End Sub    *)
end;

procedure TGIS_Child.ReturnShapeFields(const iHandle : integer; StringList : TStrings);
var
   iCount : integer;
   sf: MapWinGIS_TLB.Shapefile;
begin
     sf := IShapefile(Map1.GetObject[iHandle]);

     StringList.Clear;

     for iCount := 0 to (sf.Get_NumFields-1) do
         StringList.Add(sf.Get_Field(iCount).Name);
end;

procedure TGIS_Child.StoreTransparency;
var
   rTransparency : extended;
   iCount : integer;
begin
     try
        if fTransparencyStored then
           TransparencyArray.Destroy;

        TransparencyArray := Array_t.Create;
        TransparencyArray.init(SizeOf(extended),Map1.NumLayers);
        for iCount := 0 to (Map1.NumLayers-1) do
        begin
             rTransparency := Map1.ShapeLayerFillTransparency[iCount];
             TransparencyArray.setValue(iCount+1,@rTransparency);
        end;

        fTransparencyStored := True;

     except
           MessageDlg('Exception in StoreTransparency',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TGIS_Child.RestoreTransparency;
var
   rTransparency : extended;
   iCount : integer;
begin
     try
        if fTransparencyStored then
        begin
             for iCount := 0 to (Map1.NumLayers-1) do
             begin
                  if (LowerCase(ExtractFileExt(Map1.LayerName[iCount])) = '.shp') then
                  begin
                       TransparencyArray.rtnValue(iCount+1,@rTransparency);
                       Map1.ShapeLayerFillTransparency[iCount] := rTransparency;
                  end;
             end;
        end;

     except
           MessageDlg('Exception in RestoreTransparency',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TGIS_Child.RestoreLabels;
var
   ALDO : LabelDisplayOption_T;
   iCount, iFontSize : integer;
begin
     try
        if fLabelDisplayOption then
        begin
             for iCount := 0 to (Map1.NumLayers-1) do
             begin
                  if (LowerCase(ExtractFileExt(Map1.LayerName[iCount])) = '.shp') then
                  begin
                       LabelDisplayOption.rtnValue(iCount+1,@ALDO);

                       LabelShapeLayer(Map1.LayerName[iCount],ALDO.sField,ALDO.AJustify);

                       if fLayerFontSizeOption then
                       begin
                            LayerFontSizeOption.rtnValue(iCount+1,@iFontSize);

                            Map1.LayerFont(iCount,'Arial',iFontSize);
                       end;
                  end;
             end;
        end;

     except
           MessageDlg('Exception in RestoreLabels',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TGIS_Child.RestoreLayerSize;
var
   rSize : single;
   iCount : integer;
begin
     try
        if fLayerSizeOption then
        begin
             for iCount := 0 to (Map1.NumLayers-1) do
             begin
                  if (LowerCase(ExtractFileExt(Map1.LayerName[iCount])) = '.shp') then
                  begin
                       LayerSizeOption.rtnValue(iCount+1,@rSize);

                       case IShapefile(Map1.GetObject[iCount]).ShapefileType of
                            SHP_POINT, SHP_POINTZ, SHP_POINTM :
                                 GIS_Child.Map1.ShapeLayerPointSize[iCount] := rSize;
                            SHP_POLYLINE, SHP_POLYLINEZ, SHP_POLYLINEM, SHP_POLYGON, SHP_POLYGONZ, SHP_POLYGONM :
                                 GIS_Child.Map1.ShapeLayerLineWidth[iCount] := rSize;
                       end;
                  end;
             end;
        end;

     except
           MessageDlg('Exception in RestoreLayerSize',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TGIS_Child.RemoveAllShapes;
var
   iCount : integer;
begin
     // save the .zcp project file
     StringGrid1.RowCount := Map1.NumLayers;
     StringGrid1.ColCount := 2;
     for iCount := 1 to Map1.NumLayers do
     begin
          StringGrid1.Cells[0,iCount-1] := Map1.LayerName[iCount-1];
          //StringGrid1.Cells[1,iCount-1] := IntToStr(ColourToIndex(Map1.ShapeLayerFillColor[iCount-1]));
          StringGrid1.Cells[1,iCount-1] := TColourToHex(Map1.ShapeLayerFillColor[iCount-1]);
     end;

     StoreTransparency;

     Map1.RemoveAllLayers;
end;

procedure TGIS_Child.RestoreAllShapes;
var
   sf: MapWinGIS_TLB.Shapefile;
   image1 : MapWinGIS_TLB.Image;
   iCount, iLayerHandle : integer;
   sLayerFileName, sFileExt : string;
begin
     // restore the .zcp project file

     for iCount := 1 to StringGrid1.RowCount do
     begin
          sLayerFileName := StringGrid1.Cells[0,iCount-1];
          sFileExt := LowerCase(ExtractFileExt(sLayerFileName));

          if (sFileExt = '.shp') then
          begin
               sf := CoShapefile.Create();
               sf.Open(sLayerFileName, nil);
               iLayerHandle := Map1.AddLayer(sf, true);
               Map1.LayerName[iLayerHandle] := sLayerFileName;
               Map1.ShapeLayerFillColor[iLayerHandle] := HexToTColour(StringGrid1.Cells[1,iCount-1]);
               if not SCPForm.ShapeOutlines1.Checked then
                  Map1.ShapeLayerLineColor[iLayerHandle] := Map1.ShapeLayerFillColor[iLayerHandle]
               else
                   Map1.ShapeLayerLineColor[iLayerHandle] := clBlack;

               case sf.ShapefileType of
                    SHP_POINT, SHP_POINTZ, SHP_POINTM : Map1.ShapeLayerPointColor[iLayerHandle] := Map1.ShapeLayerFillColor[iLayerHandle];
               end;
          end;

          if (sFileExt = '.bmp') then
          begin
               image1 := CoImage.Create();
               image1.Open(sLayerFileName,
                           USE_FILE_EXTENSION,
                           False,
                           nil);

               iLayerHandle := Map1.AddLayer(image1, true);
               Map1.LayerName[iLayerHandle] := sLayerFileName;
          end;

          Map1.LayerVisible[iCount-1] := CheckListBox1.Checked[iCount-1];
     end;

     RestoreTransparency;
     RestoreLabels;
     RestoreLayerSize;

     Map1.SendMouseUp := True;
     Map1.SendSelectBoxFinal := True;
end;

procedure TGIS_Child.UpdateMapeFlows(sField : string;
                                     sf : MapWinGIS_TLB.Shapefile;
                                     iUpdateLayer, iField : integer);
var
   iCount, iDisplayValue, iNullDisplayValue : integer;
   cs : MapWinGIS_TLB.ShapefileColorScheme;
   bk : MapWinGIS_TLB.ShapefileColorBreak;
   fDisplayNull : boolean;
   vDisplayValue : variant;
begin
     try
        // init colour scheme object
        cs := CoShapefileColorScheme.Create();
        cs.LayerHandle := iUpdateLayer;
        cs.FieldIndex := iField;

        bk := CoShapefileColorBreak.Create();
        bk.Caption := 'off';
        bk.StartColor := clWhite;
        bk.EndColor := clWhite;
        bk.StartValue := 0;
        bk.EndValue := 0;
        cs.Add(bk);

        bk := CoShapefileColorBreak.Create();
        bk.Caption := 'off';
        bk.StartColor := clBlue;
        bk.EndColor := clBlue;
        bk.StartValue := 1;
        bk.EndValue := 1;
        cs.Add(bk);

        Map1.ApplyLegendColors(cs);
        iNullDisplayValue := 0;
        
        if SCPForm.ShapeOutlines1.Checked then
           Map1.ShapeLayerLineColor[iUpdateLayer] := clBlack;
        for iCount := 1 to sf.NumShapes do
        begin
             if SCPForm.ShapeOutlines1.Checked then
                Map1.ShapeDrawLine[iUpdateLayer,iCount-1] := True;

             vDisplayValue := sf.CellValue[iField,iCount-1];
             fDisplayNull := False;
             if (vDisplayValue <> NULL) then
             begin
                  iDisplayValue := vDisplayValue;
                  if (iDisplayValue <= iNullDisplayValue) then
                     fDisplayNull := True;
             end
             else
                 fDisplayNull := True;

             if fDisplayNull then
             begin
                  Map1.ShapeFillTransparency[iUpdateLayer,iCount-1] := 0;
                  if not SCPForm.ShapeOutlines1.Checked then
                     Map1.ShapeDrawLine[iUpdateLayer,iCount-1] := False;
             end
             else
             begin
                  Map1.ShapeFillTransparency[iUpdateLayer,iCount-1] := Map1.ShapeLayerFillTransparency[iUpdateLayer];
                  if not SCPForm.ShapeOutlines1.Checked then
                  begin
                       Map1.ShapeLineColor[iUpdateLayer,iCount-1] := Map1.ShapeFillColor[iUpdateLayer,iCount-1];
                       Map1.ShapeDrawLine[iUpdateLayer,iCount-1] := True;
                  end;
             end;
        end;

     except
           MessageDlg('Exception in UpdateMapeFlows',mtError,[mbOk],0);
     end;
end;

procedure TGIS_Child.UpdateMap(iMinValue, iMaxValue : integer; sField : string;
                               const fSummedSolution : boolean;
                               const fEditConfig : boolean;
                               MChild : TMarxanInterfaceForm);
var
   iCount, iField, iUpdateLayer, iDisplayValue, iNullDisplayValue : integer;
   sf: MapWinGIS_TLB.Shapefile;
   cs : MapWinGIS_TLB.ShapefileColorScheme;
   bk : MapWinGIS_TLB.ShapefileColorBreak;
   AColour : TColor;
   fFieldNameContainsSSOLN, fDisplayNull : boolean;
   vDisplayValue : variant;
   SyncFile : TextFile;
begin
     // find correct layer
     iUpdateLayer := -1;
     for iCount := 0 to (Map1.NumLayers-1) do
         if (Map1.LayerName[iCount] = sPuFileName) then
            iUpdateLayer := iCount;

     if (iUpdateLayer > -1) then
     begin
          // get handle for shapefile in the view
          sf := IShapefile(Map1.GetObject[Map1.LayerHandle[iUpdateLayer]]);

          // find index for field
          iField := -1;
          for iCount := 0 to (sf.Get_NumFields-1) do
          begin
               if (sf.Get_Field(iCount).Name = sField) then
                  iField := iCount;
          end;

          if SCPForm.feFlowsActivated then
          begin
               if (iField > -1) then
                  UpdateMapeFlows(sField,sf,iUpdateLayer,iField);
          end
          else
          begin
               if (iField = -1) then
               begin
                    // attempt to fetch Marxan results and display them
                    assignfile(SyncFile,ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) + 'sync');
                    rewrite(SyncFile);
                    writeln(SyncFile,' ');
                    closefile(SyncFile);

                    ProgressForm := TProgressForm.Create(Application);
                    with ProgressForm do
                    begin
                         LabelCalibration.Visible := False;
                         ProgressBarCalibration.Visible := False;
                         BitBtnCancel.Top := BitBtnCancel.Top - 48;
                         ProgressForm.Height := ProgressForm.Height - 48;

                         ProgressForm.Show;
                         LabelMarxan.Caption := 'Marxan';
                         ProgressBarMarxan.Max := iSolutionCount;
                    end;

                    MarxanInterfaceForm.TimerMarxan.Enabled := True;

                    // if Marxan results don't exist, display a blank map
               end
               else
               begin
                    if fEditConfig then
                    begin
                         // init colour scheme object
                         cs := CoShapefileColorScheme.Create();
                         cs.LayerHandle := iUpdateLayer;
                         cs.FieldIndex := iField;

                         for iCount := 1 to iNumberOfZones do
                         begin
                              // init break object for colour scheme
                              bk := CoShapefileColorBreak.Create();
                              bk.Caption := 'zone ' + MChild.ReturnZoneName(iCount);
                              MChild.SingleSolutionColours.rtnValue(iCount,@AColour);
                              bk.StartColor := AColour;
                              bk.EndColor := AColour;
                              if (iCount = 1) then
                                 bk.StartValue := 0
                              else
                                  bk.StartValue := iCount - 1.51;
                              bk.EndValue := iCount + 0.51;

                              cs.Add(bk);
                         end;

                         if (iNumberOfZones <= 2) then
                         begin
                              // add a legend for excluded
                              bk := CoShapefileColorBreak.Create();
                              bk.Caption := 'excluded';
                              AColour := clGray;
                              bk.StartColor := AColour;
                              bk.EndColor := AColour;
                              bk.StartValue := 3;
                              bk.EndValue := 3;

                              cs.Add(bk);
                         end;
                    end
                    else
                    if fSummedSolution then
                    begin
                         // init break object for colour scheme
                         bk := CoShapefileColorBreak.Create();
                         bk.Caption := 'Marxan';
                         bk.StartColor := clWhite;
                         bk.EndColor := SummedSolutionColour;
                         bk.StartValue := iMinValue;
                         bk.EndValue := iMaxValue;

                         // init colour scheme object
                         cs := CoShapefileColorScheme.Create();
                         cs.LayerHandle := iUpdateLayer;
                         cs.FieldIndex := iField;
                         cs.Add(bk);
                    end
                    else
                    begin
                         // init colour scheme object
                         cs := CoShapefileColorScheme.Create();
                         cs.LayerHandle := iUpdateLayer;
                         cs.FieldIndex := iField;

                         for iCount := 1 to iNumberOfZones do
                         begin
                              // init break object for colour scheme
                              bk := CoShapefileColorBreak.Create();
                              bk.Caption := 'zone ' + MChild.ReturnZoneName(iCount);
                              MChild.SingleSolutionColours.rtnValue(iCount,@AColour);
                              bk.StartColor := AColour;
                              bk.EndColor := AColour;
                              bk.StartValue := iCount - 0.45;
                              bk.EndValue := iCount + 0.45;

                              cs.Add(bk);
                         end;
                    end;

                    Map1.ApplyLegendColors(cs);

                    fFieldNameContainsSSOLN := False;
                    iNullDisplayValue := 0;
                    if (Pos('SSOLN',sField) > 0) then
                    begin
                         fFieldNameContainsSSOLN := True;
                         iNullDisplayValue := 0;
                    end;

                    if not SCPForm.ShapeOutlines1.Checked then
                    begin
                         for iCount := 1 to sf.NumShapes do
                         begin
                              // if this shape has a NULL value, don't fill it's polygon
                              //   - set it's polygon fill to transparent
                              //   - set it's shape line width to zero
                              //       ShapeLineWidth[LayerHandle: Integer; Shape: Integer]: Single

                              vDisplayValue := sf.CellValue[iField,iCount-1];
                              fDisplayNull := False;
                              if (vDisplayValue <> NULL) then
                              begin
                                   iDisplayValue := vDisplayValue;
                                   if (iDisplayValue <= iNullDisplayValue) then
                                      fDisplayNull := True;
                              end
                              else
                                  fDisplayNull := True;

                              if fDisplayNull then
                              begin
                                   Map1.ShapeFillTransparency[iUpdateLayer,iCount-1] := 0;
                                   Map1.ShapeDrawLine[iUpdateLayer,iCount-1] := False;
                              end
                              else
                              begin
                                   Map1.ShapeLineColor[iUpdateLayer,iCount-1] := Map1.ShapeFillColor[iUpdateLayer,iCount-1];
                                   Map1.ShapeFillTransparency[iUpdateLayer,iCount-1] := Map1.ShapeLayerFillTransparency[iUpdateLayer];
                                   Map1.ShapeDrawLine[iUpdateLayer,iCount-1] := True;
                              end;
                         end;
                    end
                    else
                    begin
                         Map1.ShapeLayerLineColor[iUpdateLayer] := clBlack;
                         for iCount := 1 to sf.NumShapes do
                         begin
                              Map1.ShapeDrawLine[iUpdateLayer,iCount-1] := True;
                              // if this shape has a NULL value, don't fill it's polygon (ie. set it's polygon fill to transparent)
                              vDisplayValue := sf.CellValue[iField,iCount-1];
                              fDisplayNull := False;
                              if (vDisplayValue <> NULL) then
                              begin
                                   iDisplayValue := vDisplayValue;
                                   if (iDisplayValue <= iNullDisplayValue) then
                                      fDisplayNull := True;
                              end
                              else
                                  fDisplayNull := True;

                              if fDisplayNull then
                                 Map1.ShapeFillTransparency[iUpdateLayer,iCount-1] := 0
                              else
                                  Map1.ShapeFillTransparency[iUpdateLayer,iCount-1] := Map1.ShapeLayerFillTransparency[iUpdateLayer];
                         end;
                    end;
               end;
          end;
     end;
end;

procedure TGIS_Child.LabelShapeLayer(sLayer, sField : string;  AJustify : tkHJustification);
var
   iCount, iField, iUpdateLayer : integer;
   sf: MapWinGIS_TLB.Shapefile;
   cs : MapWinGIS_TLB.ShapefileColorScheme;
   bk : MapWinGIS_TLB.ShapefileColorBreak;
   APoint : MapWinGIS_TLB.Point;
   AColour : TColor;
   fFieldNameContainsSSOLN, fDisplayNull, fPuLayer, fDisplayLabel : boolean;
   vDisplayValue : variant;
   sDisplayValue : string;
   rX,rY : double;
begin
     // find correct layer
     iUpdateLayer := -1;
     for iCount := 0 to (Map1.NumLayers-1) do
         if (Map1.LayerName[iCount] = sLayer) then
            iUpdateLayer := iCount;

     if (iUpdateLayer > -1) then
     begin
          fPuLayer := (iUpdateLayer = iPULayerHandle);

          // get handle for shapefile in the view
          sf := IShapefile(Map1.GetObject[Map1.LayerHandle[iUpdateLayer]]);

          // find index for field
          iField := -1;
          for iCount := 0 to (sf.Get_NumFields-1) do
          begin
               if (sf.Get_Field(iCount).Name = sField) then
                  iField := iCount;
          end;

          if (iField > -1) then
          begin
               Map1.ClearLabels(iUpdateLayer);
               for iCount := 1 to sf.NumShapes do
               begin
                    fDisplayLabel := True;

                    if (fPuLayer) then
                       // detect if we are displaying this PU
                       fDisplayLabel := (Map1.ShapeFillTransparency[iUpdateLayer,iCount-1] <> 0);

                    if (fDisplayLabel) then
                    begin
                         // if this shape has a NULL value, don't label it's polygon
                         vDisplayValue := sf.CellValue[iField,iCount-1];
                         if (vDisplayValue <> NULL) then
                         begin
                              sDisplayValue := vDisplayValue;

                              // which point to display the label ?
                              APoint := sf.Shape[iCount-1].Point[0];
                              rX := APoint.x;
                              rY := APoint.y;

                              Map1.AddLabel(iUpdateLayer,sDisplayValue,clBlack,rX,rY,AJustify);
                         end;
                    end;
               end;
          end;
     end;
end;

procedure TGIS_Child.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     if fShapeSelection then
     begin
          ShapeSelection.Destroy;
          fShapeSelection := False;
     end;

     if fDDEMapCategories then
     begin
          DDEMapCategories.Destroy;
          fDDEMapCategories := False;
     end;

     if fLabelDisplayOption then
        LabelDisplayOption.Destroy;

     Action := caFree;

     SCPForm.GIS4.Enabled := False;
     SCPForm.GIS4.Visible := False;
end;

function TGIS_Child.AddImage(sImagefile : string) : integer;
var
   image1 : MapWinGIS_TLB.Image;
   fLayerExists : boolean;
   iCount, iAddLayer : integer;
begin
     // test if the imagefile is already in the list of layers before adding
     fLayerExists := False;
     if (Map1.NumLayers > 0) then
        for iCount := 0 to (Map1.NumLayers-1) do
            if (Map1.LayerName[iCount] = sImagefile) then
            begin
                 fLayerExists := True;
                 Result := Map1.LayerHandle[iCount];
            end;

     if not fLayerExists then
     begin
          image1 := CoImage.Create();
          image1.Open(sImagefile,
                      USE_FILE_EXTENSION,
                      False,
                      nil);

          iAddLayer := Map1.AddLayer(image1, true);
          Map1.LayerName[iAddLayer] := sImagefile;

          Result := iAddLayer;

          iLastLayerHandle := iAddLayer;

          CheckListBox1.Items.Add(ExtractFileName(sImagefile));
          CheckListBox1.Checked[CheckListBox1.Items.Count-1] := True;
     end;
end;

function TGIS_Child.AddGrid(sGridfile : string) : integer;
var
   grid1 : MapWinGIS_TLB.Grid;
   scheme1 : MapWinGIS_TLB.GridColorScheme;
   image1 : MapWinGIS_TLB.Image;
   util1 : MapWinGIS_TLB.Utils;
   fLayerExists : boolean;
   iCount, iAddLayer : integer;
   sImageFile : string;
begin
     // test if the gridfile is already in the list of layers before adding
     fLayerExists := False;
     if (Map1.NumLayers > 0) then
        for iCount := 0 to (Map1.NumLayers-1) do
            if (Map1.LayerName[iCount] = sGridfile) then
            begin
                 fLayerExists := True;
                 Result := Map1.LayerHandle[iCount];
            end;

     if not fLayerExists then
     begin
          grid1 := CoGrid.Create();
          grid1.Open(sGridfile,
                     LongDataType,
                     False,
                     Binary,
                     nil);

          scheme1 := CoGridColorScheme.Create();

          scheme1.NoDataColor := clBlack;
          scheme1.UsePredefined(grid1.Minimum,
                                grid1.Maximum,
                                SummerMountains);

          util1 := CoUtils.Create();

          MsgForm := TMsgForm.Create(Application);
          MsgForm.Caption := 'Please wait';
          MsgForm.MsgLabel.Caption := 'converting GRID to BMP...';
          MsgForm.Show;
          Application.ProcessMessages;

          image1 := util1.GridToImage(grid1,scheme1,nil);

          sImageFile := ChangeFileExt(sGridfile,'.bmp');
          image1.Save(sImageFile,true,BITMAP_FILE,nil);

          MsgForm.Free;

          iAddLayer := Map1.AddLayer(image1, true);
          Map1.LayerName[iAddLayer] := sImageFile;

          Result := iAddLayer;

          iLastLayerHandle := iAddLayer;

          CheckListBox1.Items.Add(ExtractFileName(sImageFile));
          CheckListBox1.Checked[CheckListBox1.Items.Count-1] := True;
     end;
end;

function TGIS_Child.AddShape(sShapefile : string) : integer;
var
   sf: MapWinGIS_TLB.Shapefile;
   iCount, iAddLayer : integer;
   fLayerExists : boolean;
begin
     sf := CoShapefile.Create();
     sf.Open(sShapefile, nil);

     // test if the shapefile is already in the list of layers before adding
     fLayerExists := False;
     if (Map1.NumLayers > 0) then
        for iCount := 0 to (Map1.NumLayers-1) do
            if (Map1.LayerName[iCount] = sShapefile) then
            begin
                 fLayerExists := True;
                 Result := Map1.LayerHandle[iCount];
            end;

     if not fLayerExists then
     begin
          iAddLayer := Map1.AddLayer(sf, true);
          if SCPForm.fMarxanActivated then
          begin
               iPULayerHandle := iAddLayer;
               Map1.ShapeLayerFillColor[iAddLayer] := clWhite;

               sPuFileName := sShapefile;
          end
          else
          begin
               Map1.ShapeLayerFillColor[iAddLayer] := clBlue;

               iLastLayerHandle := iAddLayer;

               if (SCPForm.feFlowsActivated) then
               begin
                    iPULayerHandle := iAddLayer;
                    eFlowsForm.ComboOutputToMapChange(self);
               end;
          end;

          Result := iAddLayer;
          Map1.LayerName[iAddLayer] := sShapefile;
          if not SCPForm.ShapeOutlines1.Checked then
             Map1.ShapeLayerLineColor[iAddLayer] := Map1.ShapeLayerFillColor[iAddLayer]
          else
              Map1.ShapeLayerLineColor[iAddLayer] := clBlack;

          CheckListBox1.Items.Add(ExtractFileName(sShapefile));
          CheckListBox1.Checked[CheckListBox1.Items.Count-1] := True;
          case IShapefile(Map1.GetObject[iAddLayer]).ShapefileType of
               SHP_POINT, SHP_POINTZ, SHP_POINTM : Map1.ShapeLayerPointSize[iAddLayer] := iDefaultPointSize;
               SHP_POLYLINE, SHP_POLYLINEZ, SHP_POLYLINEM, SHP_POLYGON, SHP_POLYGONZ, SHP_POLYGONM : Map1.ShapeLayerLineWidth[iAddLayer] := iDefaultLineWidth;
          end;

          Map1.SendMouseUp := True;
          Map1.SendSelectBoxFinal := True;
     end;
end;

function TGIS_Child.AddShapeColour(sShapefile : string; LayerColour : TColor; fLayerVisible : boolean) : integer;
var
   sf: MapWinGIS_TLB.Shapefile;
   iLayerHandle, iCount : integer;
   fLayerExists : boolean;
   LocalColour : TColor;
begin
     sf := CoShapefile.Create();
     sf.Open(sShapefile, nil);

     // test if the shapefile is already in the list of layers before adding
     fLayerExists := False;
     if (Map1.NumLayers > 0) then
        for iCount := 0 to (Map1.NumLayers-1) do
            if (Map1.LayerName[iCount] = sShapefile) then
            begin
                 fLayerExists := True;
                 Result := Map1.LayerHandle[iCount];
            end;

     if not fLayerExists then
     begin
          iLayerHandle := Map1.AddLayer(sf, true);
          Map1.LayerName[iLayerHandle] := sShapefile;
          if (LayerColour = clBlack) then
             LocalColour := clBlue
          else
              LocalColour := LayerColour;
              
          Map1.ShapeLayerFillColor[iLayerHandle] := LocalColour;
          
          if not SCPForm.ShapeOutlines1.Checked then
             Map1.ShapeLayerLineColor[iLayerHandle] := Map1.ShapeLayerFillColor[iLayerHandle]
          else
              Map1.ShapeLayerLineColor[iLayerHandle] := clBlack;

          Map1.SendMouseUp := True;
          Map1.SendSelectBoxFinal := True;

          CheckListBox1.Items.Add(ExtractFileName(sShapefile));
          CheckListBox1.Checked[CheckListBox1.Items.Count-1] := fLayerVisible;
          Map1.LayerVisible[CheckListBox1.Items.Count-1] := fLayerVisible;

          case IShapefile(Map1.GetObject[iLayerHandle]).ShapefileType of
               SHP_POINT, SHP_POINTZ, SHP_POINTM : Map1.ShapeLayerPointSize[iLayerHandle] := iDefaultPointSize;
               SHP_POLYLINE, SHP_POLYLINEZ, SHP_POLYLINEM, SHP_POLYGON, SHP_POLYGONZ, SHP_POLYGONM : Map1.ShapeLayerLineWidth[iLayerHandle] := iDefaultLineWidth;
          end;

          Result := iLayerHandle;

          iLastLayerHandle := iLayerHandle;
     end;
end;

procedure TGIS_Child.FormCreate(Sender: TObject);
begin
     iPULayerHandle := -1;
     iDDEPULayerHandle := -1;
     iLastLayerHandle := -1;
     iLastDisplayIndex := -1;
     fShapeSelection := False;
     fDDEMapCategories := False;

     iDefaultPointSize := 3;
     iDefaultLineWidth := 1;
     iDefaultPolygonLineWidth := 1;

     if SCPForm.TestSelectDDEcmd1.Visible then
        btnPostDDESelection.Visible := True;
                            
     SelectionColour := HexToTColour('FFFF00');;
     SummedSolutionColour := HexToTColour('0000FF');;

     Map1.CursorMode := cmPan;

     // Block users from typing a new value into the "Output to Map" combo box
     SendMessage(GetWindow(ComboOutputToMap.Handle,GW_CHILD), EM_SETREADONLY, 1, 0);
end;

procedure TGIS_Child.ComboOutputToMapChange(Sender: TObject);
var
   sPreviousOutput : string;
   fCurrentContainsZone, fPreviousContainsZone : boolean;
begin
     try
        try
           if (SCPForm.fMarxanActivated) then
           begin
                sPreviousOutput := MarxanInterfaceForm.ComboOutputToMap.Text;
                MarxanInterfaceForm.ComboOutputToMap.Text := ComboOutputToMap.Text;
                MarxanInterfaceForm.ComboOutputToMapChange(Sender);
                fCurrentContainsZone := Pos('Zone',ComboOutputToMap.Text) > 0;
                fPreviousContainsZone := Pos('Zone',sPreviousOutput) > 0;
           end;
           if (SCPForm.feFlowsActivated) then
           begin
                sPreviousOutput := eFlowsForm.ComboOutputToMap.Text;
                eFlowsForm.ComboOutputToMap.Text := ComboOutputToMap.Text;
                eFlowsForm.ComboOutputToMapChange(Sender);
           end;

        except
              try
                 CheckListBox1.ItemIndex := 0;
                 Timer1.Interval := 1;
                 Timer1.Enabled := True;
              except
              end;
        end;

        if (SCPForm.fMarxanActivated) then
           if (fCurrentContainsZone <> fPreviousContainsZone) then
           begin
                CheckListBox1.ItemIndex := 0;
                Timer1.Interval := 1;
                Timer1.Enabled := True;
           end;

     except
     end;
end;

procedure TGIS_Child.Map1FileDropped(Sender: TObject;
  const Filename: WideString);
var
   sExt : string;
begin
     // add the file to the map
     sExt := LowerCase(ExtractFileExt(Filename));

     // if extension is shape, add the shape
     if (sExt = '.shp') then
     begin
          AddShapeColour(Filename,IndexToColour(Map1.NumLayers),True);
          ZoomTo(1);
     end
     else
     // if extension is grid, add the grid
     if (sExt = '.adf') then
        AddGrid(Filename)
     else
         AddImage(Filename);
end;

procedure TGIS_Child.InitShapeSelection;
var
   iNumberOfShapes, iCount : integer;
   fShape : boolean;
   sf : MapWinGIS_TLB.Shapefile;
   iHandle : integer;
begin
     iHandle := -1;
     if (iPULayerHandle > -1) then
        iHandle := iPULayerHandle;
     if (iDDEPULayerHandle > -1) then
        iHandle := iDDEPULayerHandle;

     if (iHandle > -1) then
     begin
          sf := IShapefile(Map1.GetObject[iHandle]);
          iNumberOfShapes := sf.NumShapes;

          if fShapeSelection then
             ShapeSelection.Destroy;

          fShapeSelection := True;
          ShapeSelection := Array_t.Create;
          ShapeSelection.init(SizeOf(boolean),iNumberOfShapes);

          fShape := False;
          for iCount := 1 to iNumberOfShapes do
              ShapeSelection.setValue(iCount,@fShape);
     end;
end;

procedure TGIS_Child.RedrawSelection;
var
   iCount : integer;
   fShape : boolean;
   iHandle : integer;
begin
     if fShapeSelection then
        if (ShapeSelection <> nil) then
        begin
             // draw the shapes to unselected colours
             if (SCPForm.sDDEPULayer <> '') then
                UpdateDDEMap;
             if (sPuFileName <> '') then
             begin
                  if (SCPForm.fMarxanActivated) then
                     MarxanInterfaceForm.RefreshGISDisplay;
                  if (SCPForm.feFlowsActivated) then
                     eFlowsForm.RefreshGISDisplay;
             end;

             iHandle := -1;
             if (iPULayerHandle > -1) then
                iHandle := iPULayerHandle;
             if (iDDEPULayerHandle > -1) then
                iHandle := iDDEPULayerHandle;

             if (iHandle > -1) then
                for iCount := 1 to ShapeSelection.lMaxSize do
                begin
                     ShapeSelection.rtnValue(iCount,@fShape);
                     if fShape then
                     begin
                          Map1.ShapeFillColor[iHandle,iCount-1] := SelectionColour;
                          if not SCPForm.ShapeOutlines1.Checked then
                             Map1.ShapeLineColor[iHandle,iCount-1] := SelectionColour
                          else
                              Map1.ShapeLayerLineColor[iHandle] := clBlack;

                          Map1.ShapeFillTransparency[iHandle,iCount-1] := 1;
                     end;
                end;
        end;
end;

procedure TGIS_Child.SelectRectangle(const iLeft, iRight, iBottom, iTop: Integer);
var
   rTolerance : double;
   Vresult : OleVariant;
   Vselection : Variant;
   sf : MapWinGIS_TLB.Shapefile;
   extent : MapWinGIS_TLB.Extents;
   rLeft, rRight, rBottom, rTop : double;
   iCount : integer;
   fResult, fShapeSelection, fShapeSelectionFalse, fCurrentShapeSelection : boolean;
   iHandle : integer;
begin
     try
        iHandle := -1;
        if (iPULayerHandle > -1) then
           iHandle := iPULayerHandle;
        if (iDDEPULayerHandle > -1) then
           iHandle := iDDEPULayerHandle;

        if (iHandle > -1) then
        begin
             sf := IShapefile(Map1.GetObject[iHandle]);
             rTolerance := 0;
             extent := CoExtents.Create();

             Map1.PixelToProj(iLeft,iBottom,rLeft,rBottom);
             Map1.PixelToProj(iRight,iTop,rRight,rTop);

             extent.SetBounds(rLeft,rBottom,0,rRight,rTop,0);

             if SCPForm.Intersection1.Checked then
                fResult := sf.SelectShapes(extent,rTolerance,INTERSECTION,Vresult)
             else
                 fResult := sf.SelectShapes(extent,rTolerance,INCLUSION,Vresult);

             if fResult then
             begin
                  if not ShiftKeyDown then
                     InitShapeSelection;

                  Vselection := Vresult;

                  fShapeSelection := True;
                  fShapeSelectionFalse := False;
                  // For each of the selected shapes in the shapefile, color them differently than their original fill color
                  for iCount := VarArrayLowBound(Vselection,1) to VarArrayHighBound(Vselection,1) do
                  begin
                       ShapeSelection.rtnValue(Vselection[iCount]+1,@fCurrentShapeSelection);
                       if fCurrentShapeSelection then
                          ShapeSelection.setValue(Vselection[iCount]+1,@fShapeSelectionFalse)
                       else
                           ShapeSelection.setValue(Vselection[iCount]+1,@fShapeSelection);
                  end;

                  RedrawSelection;
             end
             else
                 if not ShiftKeyDown then
                 begin
                      InitShapeSelection;
                      RedrawSelection;
                 end;
        end;

     except
     end;
end;

procedure TGIS_Child.Map1_DMapEvents_MouseUp(Sender: TObject; Button,
  Shift: Smallint; x, y: Integer);
begin
     // select the planning unit under the mouse cursor

     // if shift is pressed, we add to current selection
     // if shift not pressed, we clear current selection first
     if (Map1.CursorMode = cmSelection) then
        SelectRectangle(x,x+1,y,y+1);
end;

procedure TGIS_Child.ZoomTo(const iZoom : integer);
var
   iHandle : integer;
begin
     case iZoom of
          0 : Map1.ZoomToMaxExtents;
          1 : begin
                   iHandle := Map1.LayerHandle[0];
                   Map1.ZoomToLayer(iHandle);
              end;
          2 : Map1.ZoomToPrev;
     end;
end;

procedure TGIS_Child.ChangeMode(const iMode : integer);
begin
     case iMode of
          0 : Map1.CursorMode := cmZoomIn;
          1 : Map1.CursorMode := cmZoomOut;
          2 : Map1.CursorMode := cmPan;
          3 : Map1.CursorMode := cmSelection;
     end;
end;

procedure TGIS_Child.Map1SelectBoxFinal(Sender: TObject; Left, Right,
  Bottom, Top: Integer);
begin
     // select the planning units contained in the selection box
     if (Map1.CursorMode = cmSelection) then
        SelectRectangle(Left,Right,Bottom,Top);
end;

procedure TGIS_Child.Map1ExtentsChanged(Sender: TObject);
begin
     // redraw the selection
     //RedrawSelection;
end;

procedure TGIS_Child.FormActivate(Sender: TObject);
begin
     SCPForm.SwitchChildFocus;
end;

procedure TGIS_Child.Force_ZCSELECT_Field(const fWriteIndexValues : boolean);
var
   fFieldExists, fSelection : boolean;
   iCount, iUpdate : integer;
   myExtents: MapWinGIS_TLB.Extents;
begin
     try
        Table1.DatabaseName := ExtractFilePath(sPuFileName);
        Table1.TableName := Copy(ExtractFileName(sPuFileName),1,Length(ExtractFileName(sPuFileName)) - Length(ExtractFileExt(ExtractFileName(sPuFileName)))) + '.dbf';

        Table1.Open;
        fFieldExists := False;
        // read the fields from the table
        for iCount := 0 to (Table1.FieldCount - 1) do
             if (Table1.FieldDefs.Items[iCount].Name = 'ZCSELECT') then
                fFieldExists := True;

        Table1.Close;

        myExtents := IExtents(GIS_Child.Map1.Extents);
        RemoveAllShapes;

        if not fFieldExists then
        begin
             Query1.SQL.Clear;
             Query1.SQL.Add('ALTER TABLE "' + Table1.DatabaseName + '\' + Table1.TableName + '"');
             Query1.SQL.Add('ADD ZCSELECT NUMERIC(10,0)');

             try
                Query1.Prepare;
                Query1.ExecSQL;
             except
                   MessageDlg('Exception in Force_ZCSELECT_Field ExecSQL',mtInformation,[mbOk],0);
                   Application.Terminate;
             end;

             Query1.Close;
        end;

        Table1.Open;
        for iCount := 1 to Table1.RecordCount do
        begin
             iUpdate := 0;
             if fWriteIndexValues then
                iUpdate := iCount // we are writing a one based index to the field
             else
                 if fShapeSelection then
                 begin
                      ShapeSelection.rtnValue(iCount,@fSelection);
                      if fSelection then
                         iUpdate := 1; // we are writing a selection flag to the field
                 end;

             Table1.Edit;
             Table1.FieldByName('ZCSELECT').AsInteger := iUpdate;
             Table1.Next;
        end;
        Table1.Close;

        RestoreAllShapes;
        GIS_Child.Map1.Extents := myExtents;
        if (SCPForm.fMarxanActivated) then
           MarxanInterfaceForm.RefreshGISDisplay;
        if (SCPForm.feFlowsActivated) then
           eFlowsForm.RefreshGISDisplay;
        GIS_Child.RedrawSelection;

     except
           MessageDlg('Exception in Force_ZCSELECT_Field',mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TGIS_Child.LookupSelectedPlanningUnits(MChild : TMarxanInterfaceForm);
var
   Child : TCSVChild;
begin
     // do a database lookup of currently selected sites

     // force the ZCSELECT field and populate it with the selection flag
     Force_ZCSELECT_Field(False);

     // lookup those rows with 1
     Child := TCSVChild.Create(Application);
     Child.Caption := 'selected planning units';
     Child.Show;
     Child.LoadMarxanSelectedPu(MChild,Self);
end;

procedure TGIS_Child.DeselectSelectedPlanningUnits(MChild : TMarxanInterfaceForm);
begin
     // cancel any STATUS,PULOCK&PUZONE settings for the selected planning units
     // make changes to the designated Marxan child
     if fShapeSelection then
        MChild.UpdateSelectedPuLock(0,ShapeSelection);
end;

procedure TGIS_Child.MoveSelectedPlanningUnits(const iZone : integer;MChild : TMarxanInterfaceForm);
begin
     // cancel any STATUS,PULOCK&PUZONE settings for the selected planning units

     // make a PULOCK entry for each of the selected planning units in the designated zone
     // make changes to the designated Marxan child
     if fShapeSelection then
        MChild.UpdateSelectedPuLock(iZone,ShapeSelection);
end;

procedure TGIS_Child.FormResize(Sender: TObject);
begin
     if SCPForm.ZoomtoExtentonResize1.Checked then
        ZoomTo(1);
end;

procedure TGIS_Child.Panel2CanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
     Resize := True;
end;

procedure TGIS_Child.CheckListBox1ClickCheck(Sender: TObject);
var
   iCount : integer;
   DrawRect : TRect;
begin
     for iCount := 0 to (CheckListBox1.Items.Count-1) do
     begin
          Map1.LayerVisible[iCount] := CheckListBox1.Checked[iCount];
     end;
end;

procedure TGIS_Child.CheckListBox1DblClick(Sender: TObject);
var
   iCount, iLayer, iMarxanColourOption : integer;
   fPULayer : boolean;
begin
     // edit the colour for the shapefile that has been double clicked on
     iLayer := -1;
     for iCount := 0 to (CheckListBox1.Items.Count-1) do
         if CheckListBox1.Selected[iCount] then
            iLayer := iCount;

     if (iLayer > -1) then
     begin
          // is this layer the PULayer?
          fPULayer := False;
          if (SCPForm.fMarxanActivated) then
             if (CompareStr(MarxanInterfaceForm.ComboPUShapefile.Text,Map1.LayerName[iLayer]) = 0) then
                fPULayer := True;

          if (SCPForm.fMarxanActivated and fPULayer) then
          begin
               iMarxanColourOption := 1;

               if (Pos('Zone',ComboOutputToMap.Text) = 0) then
                  iMarxanColourOption := 2;

               SCPForm.EditMarxanMapColours(iMarxanColourOption);
          end
          else
          begin
               MapLegendForm := TMapLegendForm.Create(Application);
               MapLegendForm.Caption := ExtractFileName(Map1.LayerName[iLayer]);
               //MapLegendForm.ColorGrid1.ForegroundIndex := ColourToIndex(Map1.ShapeLayerFillColor[iLayer]);
               //MapLegendForm.ColorGrid2.ForegroundIndex := ColourToIndex(Map1.ShapeLayerFillColor[iLayer]);
               MapLegendForm.iMapLayer := iLayer;
               MapLegendForm.sMapLayer := Map1.LayerName[iLayer];
               MapLegendForm.Active_GIS_Child := Self;
               MapLegendForm.ShowModal;
               MapLegendForm.Free;
               (*EditShapeLegendForm := TEditShapeLegendForm.Create(Application);
               EditShapeLegendForm.Caption := ExtractFileName(Map1.LayerName[iLayer]);

               EditShapeLegendForm.ColorGrid1.ForegroundIndex := ColourToIndex(Map1.ShapeLayerFillColor[iLayer]);
               EditShapeLegendForm.iMapLayer := iLayer;
               EditShapeLegendForm.sMapLayer := Map1.LayerName[iLayer];
               EditShapeLegendForm.Active_GIS_Child := Self;

               EditShapeLegendForm.ShowModal;
               EditShapeLegendForm.Free;*)
          end;

          CheckListBox1.ItemIndex := -1;
     end;
end;

function TGIS_Child.SafeReturnZoneName(const iZoneIndex : integer) : string;
begin
     try
        Result := MarxanInterfaceForm.ReturnZoneName(iZoneIndex);

     except
           Result := IntToStr(iZoneIndex);
     end;
end;

function TGIS_Child.rtnZoneColour(const iPaintZone : integer) : TColor;
var
   DrawColour : TColor;
begin
     if (iNumberOfZones <= 2) then
     begin
          if (iPaintZone = 0) then
             MarxanInterfaceForm.SingleSolutionColours.rtnValue(1,@DrawColour)
          else
              MarxanInterfaceForm.SingleSolutionColours.rtnValue(2,@DrawColour);
     end
     else
     begin
          MarxanInterfaceForm.SingleSolutionColours.rtnValue(iPaintZone,@DrawColour);
     end;

     Result := DrawColour;
end;

procedure TGIS_Child.CheckListBox1DrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
   DrawRect : TRect;
   DrawColour : TColor;
   iMarxanDisplayClasses, iCount, iDisplayIndex : integer;
   fDisplay, fEditConfigurationsFormHasFocus : boolean;
   sDisplay : string;

   procedure DrawDDECategory(const sLabel : string;const AColor : TColor);
   begin
        Inc(iDisplayIndex);

        with CheckListBox1.Canvas do
        begin
             Brush.Color := clWhite;
             TextOut(Rect.Left + 2 + CheckListBox1.ItemHeight,
                     Rect.Top + Round(iDisplayIndex * CheckListBox1.ItemHeight),
                     sLabel);

             DrawRect := Rect;
             DrawRect.Left := Rect.Right - CheckListBox1.ItemHeight;
             DrawRect.Top := Rect.Top + (iDisplayIndex * CheckListBox1.ItemHeight);
             DrawRect.Bottom := DrawRect.Top + CheckListBox1.ItemHeight;
             Brush.Color := AColor;
             FillRect(DrawRect);
        end;
   end;

begin
     // draw a square of the correct colour on the right hand side of the list box item
     with CheckListBox1.Canvas do
     begin
          Brush.Style := bsSolid;
          Brush.Color := clWhite;
          FillRect(Rect);

          fEditConfigurationsFormHasFocus := False;
          if SCPForm.fEditConfigurationsForm then
             if (SCPForm.MDIChildren[0].Caption = EditConfigurationsForm.Caption) then
                fEditConfigurationsFormHasFocus := True;

          if fEditConfigurationsFormHasFocus then
          begin // display edit configuration zones
               if (iNumberOfZones <= 2) then
               begin
                    // add a legend for available pu's
                    Brush.Color := clWhite;
                    TextOut(Rect.Left + 2 + CheckListBox1.ItemHeight, Rect.Top + (1 * CheckListBox1.ItemHeight),'Available');
                    DrawRect := Rect;
                    DrawRect.Left := Rect.Right - CheckListBox1.ItemHeight;
                    DrawRect.Top := Rect.Top + (1 * CheckListBox1.ItemHeight);
                    DrawRect.Bottom := DrawRect.Top + CheckListBox1.ItemHeight;
                    MarxanInterfaceForm.SingleSolutionColours.rtnValue(1,@DrawColour);
                    Brush.Color := DrawColour;
                    FillRect(DrawRect);
                    // add a legend for reserved pu's
                    Brush.Color := clWhite;
                    TextOut(Rect.Left + 2 + CheckListBox1.ItemHeight, Rect.Top + (2 * CheckListBox1.ItemHeight),'Reserved');
                    DrawRect := Rect;
                    DrawRect.Left := Rect.Right - CheckListBox1.ItemHeight;
                    DrawRect.Top := Rect.Top + (2 * CheckListBox1.ItemHeight);
                    DrawRect.Bottom := DrawRect.Top + CheckListBox1.ItemHeight;
                    MarxanInterfaceForm.SingleSolutionColours.rtnValue(2,@DrawColour);
                    Brush.Color := DrawColour;
                    FillRect(DrawRect);
                    // add a clGray legend for excluded pu's
                    Brush.Color := clWhite;
                    TextOut(Rect.Left + 2 + CheckListBox1.ItemHeight, Rect.Top + (3 * CheckListBox1.ItemHeight), 'Excluded');
                    DrawRect := Rect;
                    DrawRect.Left := Rect.Right - CheckListBox1.ItemHeight;
                    DrawRect.Top := Rect.Top + (3 * CheckListBox1.ItemHeight);
                    DrawRect.Bottom := DrawRect.Top + CheckListBox1.ItemHeight;
                    Brush.Color := clGray;
                    FillRect(DrawRect);
               end
               else
               begin
                   iMarxanDisplayClasses := iNumberOfZones;

                   for iCount := 1 to iMarxanDisplayClasses do
                   begin
                        Brush.Color := clWhite;
                        TextOut(Rect.Left + 2 + CheckListBox1.ItemHeight, Rect.Top + (iCount * CheckListBox1.ItemHeight),SafeReturnZoneName(iCount));

                        DrawRect := Rect;
                        DrawRect.Left := Rect.Right - CheckListBox1.ItemHeight;
                        DrawRect.Top := Rect.Top + (iCount * CheckListBox1.ItemHeight);
                        DrawRect.Bottom := DrawRect.Top + CheckListBox1.ItemHeight;
                        MarxanInterfaceForm.SingleSolutionColours.rtnValue(iCount,@DrawColour);
                        Brush.Color := DrawColour;
                        FillRect(DrawRect);
                   end;
               end;

          end
          else
          if SCPForm.fMarxanActivated and (Index = iPULayerHandle) then
          begin
               if (Pos('Zone',ComboOutputToMap.Text) = 0) then
               begin // display multiple zones
                    if (iNumberOfZones < 2) then
                       iMarxanDisplayClasses := 2
                    else
                        iMarxanDisplayClasses := iNumberOfZones;

                    for iCount := 1 to iMarxanDisplayClasses do
                    begin
                         Brush.Color := clWhite;
                         TextOut(Rect.Left + 2 + CheckListBox1.ItemHeight, Rect.Top + (iCount * CheckListBox1.ItemHeight),SafeReturnZoneName(iCount));

                         DrawRect := Rect;
                         DrawRect.Left := Rect.Right - CheckListBox1.ItemHeight;
                         DrawRect.Top := Rect.Top + (iCount * CheckListBox1.ItemHeight);
                         DrawRect.Bottom := DrawRect.Top + CheckListBox1.ItemHeight;
                         MarxanInterfaceForm.SingleSolutionColours.rtnValue(iCount,@DrawColour);
                         Brush.Color := DrawColour;
                         FillRect(DrawRect);
                    end;

                    if SCPForm.fEditConfigurationsForm then
                       if (SCPForm.MDIChildren[0].Caption = EditConfigurationsForm.Caption) then
                       begin
                            // add a clGray legend for excluded pu's
                            Brush.Color := clWhite;
                            TextOut(Rect.Left + 2 + CheckListBox1.ItemHeight,
                                    Rect.Top + (3 * CheckListBox1.ItemHeight),
                                    'Excluded');

                            DrawRect := Rect;
                            DrawRect.Left := Rect.Right - CheckListBox1.ItemHeight;
                            DrawRect.Top := Rect.Top + (3 * CheckListBox1.ItemHeight);
                            DrawRect.Bottom := DrawRect.Top + CheckListBox1.ItemHeight;
                            Brush.Color := clGray;
                            FillRect(DrawRect);
                       end;
               end
               else
               begin // display Selection Frequency

                    Brush.Color := clWhite;
                    TextOut(Rect.Left + 2 + CheckListBox1.ItemHeight, Rect.Top + CheckListBox1.ItemHeight,'frequency 0');

                    Brush.Color := clWhite;
                    TextOut(Rect.Left + 2 + CheckListBox1.ItemHeight, Rect.Top + (2 * CheckListBox1.ItemHeight),'frequency ' + IntToStr(ReturnSolutionCount(MarxanInterfaceForm.EditMarxanDatabasePath.Text)));
                    DrawRect := Rect;
                    DrawRect.Left := Rect.Right - CheckListBox1.ItemHeight;
                    DrawRect.Top := Rect.Top + (2 * CheckListBox1.ItemHeight);
                    DrawRect.Bottom := DrawRect.Top + CheckListBox1.ItemHeight;
                    Brush.Color := SummedSolutionColour;
                    FillRect(DrawRect);
               end;
          end
          else
          begin   
               if (SCPForm.sDDEPULayer <> '') and (iDDEPULayerHandle = Index) then
               begin
                    if (iLastDisplayIndex > 0) then
                    begin
                         // draw a white box to delete last legend
                         Brush.Color := clWhite;
                         DrawRect := Rect;
                         DrawRect.Bottom := Rect.Bottom + (iLastDisplayIndex * CheckListBox1.ItemHeight);
                         FillRect(DrawRect);
                    end;

                    // display dde planning unit layer categories
                    iDisplayIndex := 0;
                    if fDDEMapCategories then
                       for iCount := 1 to 23 do
                       begin
                            DDEMapCategories.rtnValue(iCount,@fDisplay);
                            if fDisplay then
                            begin
                                 sDisplay := DDEIndex2Display(iCount);
                                 DrawDDECategory(sDisplay,DDEDisplay2Colour(sDisplay));
                            end;
                       end;

                    iLastDisplayIndex := iDisplayIndex;
               end
               else
               begin
                    // display contextual layer as a single category
                    DrawRect := Rect;
                    DrawRect.Left := Rect.Right - (Rect.Bottom - Rect.Top);
                    Brush.Color := Map1.ShapeLayerFillColor[Index];
                    FillRect(DrawRect);
               end;
          end;

          Brush.Color := clWhite;
          TextOut(Rect.Left + 2, Rect.Top, CheckListBox1.Items[Index]);
     end;
end;

procedure TGIS_Child.CheckListBox1Click(Sender: TObject);
begin
     Timer1.Enabled := True;
end;

procedure TGIS_Child.Timer1Timer(Sender: TObject);
begin
     Timer1.Enabled := False;
     Timer1.Interval := 250;
     CheckListBox1.ItemIndex := -1;
end;

procedure TGIS_Child.CheckListBox1MeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
var
   iHeight : integer;
begin
     iHeight := CheckListBox1.ItemHeight;
     if SCPForm.fMarxanActivated then
        if (iPULayerHandle = Index) then
        begin
             if (iNumberOfZones <= 2) then
                iHeight := CheckListBox1.ItemHeight * (iNumberOfZones + 2)
             else
                 iHeight := CheckListBox1.ItemHeight * (iNumberOfZones + 1);
        end;

     Height := iHeight;
end;

procedure TGIS_Child.ZoomToTimerTimer(Sender: TObject);
begin
     ZoomToTimer.Enabled := False;
     ZoomTo(1);
end;

procedure TGIS_Child.SpeedButton4Click(Sender: TObject);
begin
     SCPForm.Extent1Click(Sender);
end;

procedure TGIS_Child.SpeedButton3Click(Sender: TObject);
begin
     SCPForm.Layer1Click(Sender);
end;

procedure TGIS_Child.SpeedButton6Click(Sender: TObject);
begin
     SCPForm.Previous1Click(Sender);
end;

procedure TGIS_Child.SpeedButton1Click(Sender: TObject);
begin
     SCPForm.ZoomIn1Click(Sender);
end;

procedure TGIS_Child.SpeedButton2Click(Sender: TObject);
begin
     SCPForm.ZoomOut1Click(Sender);
end;

procedure TGIS_Child.SpeedButton7Click(Sender: TObject);
begin
     SCPForm.Pan2Click(Sender);
end;

procedure TGIS_Child.SpeedButton8Click(Sender: TObject);
begin
     SCPForm.Select1Click(Sender);
end;

procedure TGIS_Child.btnPostDDESelectionClick(Sender: TObject);
begin
     SCPForm.TestSelectDDEcmd1Click(Sender);
end;

procedure TGIS_Child.Map1MouseUp(Sender: TObject; Button, Shift: Smallint;
  x, y: Integer);
begin
     // select the planning unit under the mouse cursor

     // if shift is pressed, we add to current selection
     // if shift not pressed, we clear current selection first
     if (Map1.CursorMode = cmSelection) then
        SelectRectangle(x,x+1,y,y+1);
end;

procedure TGIS_Child.RedrawTimerTimer(Sender: TObject);
begin
     RedrawTimer.Enabled := False;
     MarxanInterfaceForm.RefreshGISDisplay;
     GIS_Child.RedrawSelection;
     CheckListBox1.ItemIndex := 0;
     Timer1.Interval := 1;
     Timer1.Enabled := True;
end;

end.
