unit SetGISDisplayOptions;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls, ds, Miscellaneous, MapWinGIS_TLB;

type
  TGISOptionsForm = class(TForm)
    ScrollBar1: TScrollBar;
    Label4: TLabel;
    ComboShapefile: TComboBox;
    Transparency: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    BitBtn1: TBitBtn;
    btnApply: TButton;
    TrackBarSize: TTrackBar;
    LabelTrackBarSize: TLabel;
    CheckLabel: TCheckBox;
    ComboLabelField: TComboBox;
    LabelField: TLabel;
    LabelJustify: TLabel;
    ComboLabelJustification: TComboBox;
    LabelFontSize: TLabel;
    TrackBarFontSize: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure ComboShapefileChange(Sender: TObject);
    procedure CheckLabelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  GISOptionsForm: TGISOptionsForm;

implementation

uses GIS;

{$R *.DFM}

procedure TGISOptionsForm.FormCreate(Sender: TObject);
var
   iCount, iLayerHandle, iFontSize : integer;
   ALDO : LabelDisplayOption_T;
begin
     ComboShapefile.Items.Clear;
     for iCount := 0 to (GIS_Child.Map1.NumLayers-1) do
     begin
          if (pos('.shp',LowerCase(GIS_Child.Map1.LayerName[iCount])) > 0) then
             ComboShapefile.Items.Add(GIS_Child.Map1.LayerName[iCount]);
     end;

     if (ComboShapefile.Items.Count > 0) then
     begin
          ComboShapefile.Text := ComboShapefile.Items.Strings[0];

          iLayerHandle := -1;
          for iCount := 0 to (GIS_Child.Map1.NumLayers-1) do
              if (CompareStr(ComboShapefile.Text,GIS_Child.Map1.LayerName[iCount]) = 0) then
                 iLayerHandle := iCount;

          if (iLayerHandle <> -1) then
          begin
               ScrollBar1.Position := Round(GIS_Child.Map1.ShapeLayerFillTransparency[iLayerHandle] * 100);

               case IShapefile(GIS_Child.Map1.GetObject[iLayerHandle]).ShapefileType of
                    SHP_POINT, SHP_POINTZ, SHP_POINTM :
                        if (TrackBarSize.Position <> GIS_Child.Map1.ShapeLayerPointSize[iLayerHandle]) then
                        begin
                             TrackBarSize.Position := Round(GIS_Child.Map1.ShapeLayerPointSize[iLayerHandle]);
                             LabelTrackBarSize.Enabled := True;
                             TrackBarSize.Enabled := True;
                        end;
                    SHP_POLYLINE, SHP_POLYLINEZ, SHP_POLYLINEM, SHP_POLYGON, SHP_POLYGONZ, SHP_POLYGONM :
                        if (TrackBarSize.Position <> GIS_Child.Map1.ShapeLayerLineWidth[iLayerHandle]) then
                        begin
                             TrackBarSize.Position := Round(GIS_Child.Map1.ShapeLayerLineWidth[iLayerHandle]);
                             LabelTrackBarSize.Enabled := True;
                             TrackBarSize.Enabled := True;
                        end;
               else
                    LabelTrackBarSize.Enabled := False;
                    TrackBarSize.Enabled := False;
               end;

               GIS_Child.ReturnShapeFields(iLayerHandle,ComboLabelField.Items);
               ComboLabelField.ItemIndex := 0;
               ComboLabelJustification.ItemIndex := 0;

               if fLabelDisplayOption then
               begin
                    LabelDisplayOption.rtnValue(iLayerHandle+1,@ALDO);
                    CheckLabel.Checked := ALDO.fDisplayLabel;
                    if CheckLabel.Checked then
                    begin
                         ComboLabelField.ItemIndex := ComboLabelField.Items.IndexOf(ALDO.sField);
                         case ALDO.AJustify of
                              hjLeft : ComboLabelJustification.ItemIndex := 0;
                              hjCenter : ComboLabelJustification.ItemIndex := 1;
                              hjRight : ComboLabelJustification.ItemIndex := 2;
                              hjNone : ComboLabelJustification.ItemIndex := 3;
                         end;

                         if fLayerFontSizeOption then
                         begin
                              LayerFontSizeOption.rtnValue(iLayerHandle+1,@iFontSize);
                              TrackBarFontSize.Position := iFontSize;
                         end;
                    end;
               end
               else
                   CheckLabel.Checked := False;

               CheckLabelClick(Sender);
          end;
     end;

end;

procedure TGISOptionsForm.btnApplyClick(Sender: TObject);
var
   iCount, iLayerHandle : integer;
   fRedisplayGIS : boolean;
   AJustify : tkHJustification;
begin
     if (ComboShapefile.Items.Count > 0) then
     begin
          iLayerHandle := -1;
          for iCount := 0 to (GIS_Child.Map1.NumLayers-1) do
              if (CompareStr(ComboShapefile.Text,GIS_Child.Map1.LayerName[iCount]) = 0) then
                 iLayerHandle := iCount;

          if (iLayerHandle <> -1) then
          begin
               // apply transparency option
               fRedisplayGIS := False;
               if (GIS_Child.Map1.ShapeLayerFillTransparency[iLayerHandle] <> (ScrollBar1.Position / 100)) then
               begin
                    GIS_Child.Map1.ShapeLayerFillTransparency[iLayerHandle] := ScrollBar1.Position / 100;
                    fRedisplayGIS := True;
               end;

               // apply size option
               case IShapefile(GIS_Child.Map1.GetObject[iLayerHandle]).ShapefileType of
                    SHP_POINT, SHP_POINTZ, SHP_POINTM :
                        if (TrackBarSize.Position <> GIS_Child.Map1.ShapeLayerPointSize[iLayerHandle]) then
                        begin
                             GIS_Child.Map1.ShapeLayerPointSize[iLayerHandle] := TrackBarSize.Position;
                             fRedisplayGIS := True;
                        end;
                    SHP_POLYLINE, SHP_POLYLINEZ, SHP_POLYLINEM, SHP_POLYGON, SHP_POLYGONZ, SHP_POLYGONM :
                        if (TrackBarSize.Position <> GIS_Child.Map1.ShapeLayerLineWidth[iLayerHandle]) then
                        begin
                             GIS_Child.Map1.ShapeLayerLineWidth[iLayerHandle] := TrackBarSize.Position;
                             StoreLayerSizeOption(iLayerHandle+1,GIS_Child.Map1.ShapeLayerLineWidth[iLayerHandle]);
                             fRedisplayGIS := True;
                        end;
               end;

               if (fRedisplayGIS) then
                  GIS_Child.Timer1.Enabled := True;

               if CheckLabel.Checked then
               begin
                    case ComboLabelJustification.ItemIndex of
                         0 : AJustify := hjLeft;
                         1 : AJustify := hjCenter;
                         2 : AJustify := hjRight;
                         3 : AJustify := hjNone;
                    end;

                    StoreLabelDisplayOption(iLayerHandle+1,CheckLabel.Checked,ComboLabelField.Text,AJustify);
                    StoreLayerFontSizeOption(iLayerHandle+1,TrackBarFontSize.Position);

                    GIS_Child.LabelShapeLayer(ComboShapefile.Text,ComboLabelField.Text,AJustify);
                    GIS_Child.Map1.LayerFont(iLayerHandle,'Arial',TrackBarFontSize.Position);
               end
               else
               begin
                    StoreLabelDisplayOption(iLayerHandle+1,CheckLabel.Checked,'',hjNone);
                    GIS_Child.Map1.ClearLabels(iLayerHandle);
               end;
          end;
     end;
end;

procedure TGISOptionsForm.BitBtn1Click(Sender: TObject);
begin
     btnApplyClick(Sender);
end;

procedure TGISOptionsForm.ComboShapefileChange(Sender: TObject);
var
   iCount, iLayerHandle, iFontSize : integer;
   ALDO : LabelDisplayOption_T;
begin
     iLayerHandle := -1;
     for iCount := 0 to (GIS_Child.Map1.NumLayers-1) do
         if (CompareStr(ComboShapefile.Text,GIS_Child.Map1.LayerName[iCount]) = 0) then
            iLayerHandle := iCount;

     if (iLayerHandle <> -1) then
     begin
          ScrollBar1.Position := Round(GIS_Child.Map1.ShapeLayerFillTransparency[iLayerHandle] * 100);

          case IShapefile(GIS_Child.Map1.GetObject[iLayerHandle]).ShapefileType of
               SHP_POINT, SHP_POINTZ, SHP_POINTM :
                   if (TrackBarSize.Position <> GIS_Child.Map1.ShapeLayerPointSize[iLayerHandle]) then
                   begin
                        TrackBarSize.Position := Round(GIS_Child.Map1.ShapeLayerPointSize[iLayerHandle]);
                        LabelTrackBarSize.Enabled := True;
                        TrackBarSize.Enabled := True;
                   end;
               SHP_POLYLINE, SHP_POLYLINEZ, SHP_POLYLINEM, SHP_POLYGON, SHP_POLYGONZ, SHP_POLYGONM :
                   if (TrackBarSize.Position <> GIS_Child.Map1.ShapeLayerLineWidth[iLayerHandle]) then
                   begin
                        TrackBarSize.Position := Round(GIS_Child.Map1.ShapeLayerLineWidth[iLayerHandle]);
                        LabelTrackBarSize.Enabled := True;
                        TrackBarSize.Enabled := True;
                   end;
          else
               LabelTrackBarSize.Enabled := False;
               TrackBarSize.Enabled := False;
          end;

          GIS_Child.ReturnShapeFields(iLayerHandle,ComboLabelField.Items);
          ComboLabelField.ItemIndex := 0;

          if fLabelDisplayOption then
          begin
               LabelDisplayOption.rtnValue(iLayerHandle+1,@ALDO);
               CheckLabel.Checked := ALDO.fDisplayLabel;
               if CheckLabel.Checked then
               begin
                    ComboLabelField.ItemIndex := ComboLabelField.Items.IndexOf(ALDO.sField);
                    case ALDO.AJustify of
                         hjLeft : ComboLabelJustification.ItemIndex := 0;
                         hjCenter : ComboLabelJustification.ItemIndex := 1;
                         hjRight : ComboLabelJustification.ItemIndex := 2;
                         hjNone : ComboLabelJustification.ItemIndex := 3;
                    end;

                    if fLayerFontSizeOption then
                    begin
                         LayerFontSizeOption.rtnValue(iLayerHandle+1,@iFontSize);
                         TrackBarFontSize.Position := iFontSize;
                    end;
               end;
          end
          else
              CheckLabel.Checked := False;

          CheckLabelClick(Sender);
     end;
end;

procedure TGISOptionsForm.CheckLabelClick(Sender: TObject);
begin
     LabelField.Enabled := CheckLabel.Checked;
     ComboLabelField.Enabled := CheckLabel.Checked;
     LabelJustify.Enabled := CheckLabel.Checked;
     ComboLabelJustification.Enabled := CheckLabel.Checked;
     LabelFontSize.Enabled := CheckLabel.Checked;
     TrackBarFontSize.Enabled := CheckLabel.Checked;
end;

end.
