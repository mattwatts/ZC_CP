unit ConvertLayer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TConvertLayerForm = class(TForm)
    Label4: TLabel;
    ComboLayer: TComboBox;
    Label1: TLabel;
    EditOutput: TEdit;
    btnBrowse: TButton;
    SaveDialog1: TSaveDialog;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    procedure PrepareTheForm(const sInputMask, sCT, sOM : string);
    procedure FormResize(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    function GenerateOutputFilename : string;
    procedure BitBtnOkClick(Sender: TObject);
    procedure PerformConversion;
  private
    { Private declarations }
  public
    { Public declarations }
    sConvertType, sOutputMask : string;
  end;

var
  ConvertLayerForm: TConvertLayerForm;

implementation

uses GIS;

{$R *.DFM}

function ReturnConvertFilename(const sPath : string) : string;
var
   iCount : integer;
begin
     iCount := 1;

     while fileexists(sPath + 'convert' + IntToStr(iCount) + '.shp') do
           Inc(iCount);

     Result := sPath + 'convert' + IntToStr(iCount) + '.shp';
end;

procedure TConvertLayerForm.PerformConversion;
begin
     if (sConvertType = 'SHPtoSHP') then
     begin
          GIS_Child.ExportShapes(ComboLayer.Text,EditOutput.Text);
     end;

     if (sConvertType = 'SHPtoBMP') then
     begin
          Polygon2Image(ComboLayer.Text,'PUID','',EditOutput.Text,100);   
     end;
end;

function TConvertLayerForm.GenerateOutputFilename : string;
begin
     if (sOutputMask = '.shp') then
     begin
          Result := ReturnConvertFilename(ExtractFilePath(ComboLayer.Text));
     end
     else
         if (sOutputMask = '.bmp') then
         begin
              Result := ChangeFileExt(ComboLayer.Text,sOutputMask);
         end
         else
             Result := '';
end;

procedure TConvertLayerForm.PrepareTheForm(const sInputMask, sCT, sOM : string);
var
   iCount : integer;
   sExtension : string;
begin
     sConvertType := sCT;
     sOutputMask := sOM;

     ComboLayer.Items.Clear;
     for iCount := 0 to (GIS_Child.Map1.NumLayers-1) do
     begin
          sExtension := LowerCase(ExtractFileExt(GIS_Child.Map1.LayerName[iCount]));

          if (sExtension = sInputMask) then
             ComboLayer.Items.Add(GIS_Child.Map1.LayerName[iCount]);
     end;

     if (ComboLayer.Items.Count = 0) then
        MessageDlg('No layers of type ' + sInputMask + ' present for conversion',mtInformation,[mbOk],0)
     else
     begin
          ComboLayer.Text := ComboLayer.Items.Strings[0];
          EditOutput.Text := GenerateOutputFilename;
     end;
end;

procedure TConvertLayerForm.FormResize(Sender: TObject);
begin
     ComboLayer.Width := ClientWidth - Label4.Left - ComboLayer.Left;
     EditOutput.Width := ComboLayer.Width - btnBrowse.Width - Label4.Left;
     btnBrowse.Left := EditOutput.Width + EditOutput.Left + Label4.Left;
     BitBtnCancel.Left := ClientWidth - BitBtnOk.Left - BitBtnCancel.Width;
end;

procedure TConvertLayerForm.btnBrowseClick(Sender: TObject);
begin
     SaveDialog1.InitialDir := ExtractFileExt(EditOutput.Text);
     SaveDialog1.DefaultExt := Copy(sOutputMask,2,3);
     if SaveDialog1.Execute then
        EditOutput.Text := SaveDialog1.Filename;
end;

procedure TConvertLayerForm.BitBtnOkClick(Sender: TObject);
begin
     PerformConversion;
end;

end.
