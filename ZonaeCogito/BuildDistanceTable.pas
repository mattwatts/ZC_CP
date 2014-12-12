unit BuildDistanceTable;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TBuildDistanceTableForm = class(TForm)
    Label1: TLabel;
    ComboPULayer: TComboBox;
    Label2: TLabel;
    ComboKeyField: TComboBox;
    Label3: TLabel;
    EditRadius: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label4: TLabel;
    EditOutputFilename: TEdit;
    btnBrowse: TButton;
    SaveDistanceFile: TSaveDialog;
    procedure btnBrowseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboPULayerChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BuildDistanceTableForm: TBuildDistanceTableForm;

implementation

uses GIS, MapWinGIS_TLB;

{$R *.DFM}

procedure TBuildDistanceTableForm.btnBrowseClick(Sender: TObject);
begin
     if (SaveDistanceFile.Execute) then
        EditOutputFilename.Text := SaveDistanceFile.FileName;
end;

procedure TBuildDistanceTableForm.FormCreate(Sender: TObject);
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
              ComboPULayer.Items.Add(GIS_Child.Map1.LayerName[iCount]);
          ComboPuLayer.Text := ComboPULayer.Items.Strings[0];

          // load list of fields from this map layer
          sf := IShapefile(GIS_Child.Map1.GetObject[GIS_Child.Map1.LayerHandle[0]]);
          ComboKeyField.Items.Clear;
          ComboKeyField.Text := '';
          for iCount := 0 to (sf.Get_NumFields-1) do
              ComboKeyField.Items.Add(sf.Get_Field(iCount).Name);
          ComboKeyField.Text := ComboKeyField.Items.Strings[0];
     end;
end;

procedure TBuildDistanceTableForm.ComboPULayerChange(Sender: TObject);
var
   sf: MapWinGIS_TLB.Shapefile;
   iLayerHandle, iCount : integer;
begin
     iLayerHandle := ComboPULayer.Items.IndexOf(ComboPULayer.Text);

     // load list of fields from this map layer
     sf := IShapefile(GIS_Child.Map1.GetObject[GIS_Child.Map1.LayerHandle[iLayerHandle]]);
     ComboKeyField.Items.Clear;
     ComboKeyField.Text := '';
     for iCount := 0 to (sf.Get_NumFields-1) do
         ComboKeyField.Items.Add(sf.Get_Field(iCount).Name);
     ComboKeyField.Text := ComboKeyField.Items.Strings[0];
end;

end.
