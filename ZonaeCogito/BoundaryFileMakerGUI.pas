unit BoundaryFileMakerGUI;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls;

type
  TBoundaryFileMakerForm = class(TForm)
    Label1: TLabel;
    ComboPulayer: TComboBox;
    Label2: TLabel;
    ComboPUIDField: TComboBox;
    CheckIncludeEdges: TCheckBox;
    Label3: TLabel;
    EditOutputFileName: TEdit;
    btnBrowse: TButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    SaveBoundaryLengthFile: TSaveDialog;
    procedure btnBrowseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboPulayerChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BoundaryFileMakerForm: TBoundaryFileMakerForm;

implementation

uses GIS, MapWinGIS_TLB;

{$R *.DFM}

procedure TBoundaryFileMakerForm.btnBrowseClick(Sender: TObject);
begin
     if (SaveBoundaryLengthFile.Execute) then
        EditOutputFileName.Text := SaveBoundaryLengthFile.FileName;
end;

procedure TBoundaryFileMakerForm.FormCreate(Sender: TObject);
var
   sf: MapWinGIS_TLB.Shapefile;
   iCount : integer;
begin
     // load list of map layers
     ComboPULayer.Items.Clear;
     ComboPULayer.Text := '';

     if (GIS_Child.Map1.NumLayers > 0) then
     begin
          for iCount := 0 to (GIS_Child.Map1.NumLayers-1) do
              if (LowerCase(ExtractFileExt(GIS_Child.Map1.LayerName[iCount])) = '.shp') then
                 ComboPULayer.Items.Add(GIS_Child.Map1.LayerName[iCount]);

          if (ComboPULayer.Items.Count > 0) then
          begin
               ComboPuLayer.Text := ComboPULayer.Items.Strings[0];
               EditOutputFileName.Text := ExtractFilePath(ComboPulayer.Text) + 'bound.dat';

               // load list of fields from this map layer
               sf := IShapefile(GIS_Child.Map1.GetObject[GIS_Child.Map1.LayerHandle[0]]);
               ComboPUIDField.Items.Clear;
               ComboPUIDField.Text := '';
               for iCount := 0 to (sf.Get_NumFields-1) do
                   ComboPUIDField.Items.Add(sf.Get_Field(iCount).Name);
               ComboPUIDField.Text := ComboPUIDField.Items.Strings[0];
          end;
     end;
end;

procedure TBoundaryFileMakerForm.ComboPulayerChange(Sender: TObject);
var
   sf: MapWinGIS_TLB.Shapefile;
   iLayerHandle, iCount : integer;
begin
     EditOutputFileName.Text := ExtractFilePath(ComboPulayer.Text) + 'bound.dat';
     iLayerHandle := ComboPULayer.Items.IndexOf(ComboPULayer.Text);

     // load list of fields from this map layer
     sf := IShapefile(GIS_Child.Map1.GetObject[GIS_Child.Map1.LayerHandle[iLayerHandle]]);
     ComboPUIDField.Items.Clear;
     ComboPUIDField.Text := '';
     for iCount := 0 to (sf.Get_NumFields-1) do
         ComboPUIDField.Items.Add(sf.Get_Field(iCount).Name);
     ComboPUIDField.Text := ComboPUIDField.Items.Strings[0];
end;

end.
