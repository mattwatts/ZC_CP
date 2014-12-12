unit Edit_Profile_Element;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl, Buttons, ExtCtrls;

type
  TProfileElementForm = class(TForm)
    BottomPanel: TPanel;
    RightPanel: TPanel;
    LeftPanel: TPanel;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    DriveComboBox1: TDriveComboBox;
    DirectoryListBox1: TDirectoryListBox;
    FilterComboBox1: TFilterComboBox;
    FileListBox1: TFileListBox;
    Label1: TLabel;
    ComboField: TComboBox;
    Label2: TLabel;
    ComboDataType: TComboBox;
    Label3: TLabel;
    Directory: TLabel;
    LabelFileType: TLabel;
    LabelFile: TLabel;
    procedure FilterComboBox1Change(Sender: TObject);
    procedure FileListBox1Change(Sender: TObject);
    procedure ReadShapeFields(const sFilename : string);
    procedure ReadGridFields(const sFilename : string);
    procedure FormCreate(Sender: TObject);
    procedure BitBtnOkClick(Sender: TObject);
    procedure BitBtnCancelClick(Sender: TObject);
    procedure ResizeTheForm;
    procedure FormResize(Sender: TObject);
    procedure DirectoryListBox1Change(Sender: TObject);
    procedure DriveComboBox1Change(Sender: TObject);
    procedure PrepareEdit(const sLayer, sField, sType : string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ProfileElementForm: TProfileElementForm;
  fCreatedGISWindow, fEditDataField : boolean;

implementation

uses GIS, Build_Child;

{$R *.DFM}

procedure TProfileElementForm.PrepareEdit(const sLayer, sField, sType : string);
var
   sExtension : string;
begin
     //
     DriveComboBox1.Drive := ExtractFileDrive(sLayer)[1];
     DirectoryListBox1.Directory := ExtractFilePath(sLayer);
     sExtension := LowerCase(ExtractFileExt(FileListBox1.Filename));

     if (sExtension = '.shp') then
        FilterComboBox1.ItemIndex := 0;
     if (sExtension = '.adf') then
        FilterComboBox1.ItemIndex := 1;
        
     FileListBox1.FileName := ExtractFileName(sLayer);

     ComboField.Text := sField;
     ComboDataType.Text := sType;

     fEditDataField := True;
end;

procedure TProfileElementForm.ResizeTheForm;
begin
     // resize controls on left panel
     DriveComboBox1.Width := LeftPanel.ClientWidth - DriveComboBox1.Left - DirectoryListBox1.Left;
     FilterComboBox1.Width := DriveComboBox1.Width;
     DirectoryListBox1.Width := LeftPanel.ClientWidth - (DirectoryListBox1.Left * 2);
     DirectoryListBox1.Height := (LeftPanel.ClientHeight - DirectoryListBox1.Top - (DriveComboBox1.Top * 3) - LabelFile.Height) div 2;
     LabelFile.Top := DirectoryListBox1.Top + DirectoryListBox1.Height + DriveComboBox1.Top;
     FileListBox1.Width := DirectoryListBox1.Width;
     FileListBox1.Top := LabelFile.Top + LabelFile.Height + DriveComboBox1.Top;
     FileListBox1.Height := DirectoryListBox1.Height;

     // move controls on bottom panel
     BitBtnCancel.Left := BottomPanel.ClientWidth - (BitBtnOk.Left * 2) - BitBtnCancel.Width;
end;


procedure TProfileElementForm.FilterComboBox1Change(Sender: TObject);
begin
     FileListBox1.Mask := FilterComboBox1.Mask;
     if fCreatedGISWindow then
     begin
          GIS_Child.Close;
          fCreatedGISWindow := False;
     end;
end;

procedure TProfileElementForm.ReadShapeFields(const sFilename : string);
var
   iShapeHandle : integer;
begin
     //
     GIS_Child := TGIS_Child.Create(Application);
     GIS_Child.Show;
     iShapeHandle := GIS_Child.AddShape(sFilename);
     GIS_Child.Caption := 'GIS';

     GIS_Child.ReturnShapeFields(iShapeHandle,ComboField.Items);

     fCreatedGISWindow := True;
end;

procedure TProfileElementForm.ReadGridFields(const sFilename : string);
begin
     //
     //GIS_Child := TGIS_Child.Create(Application);
     //GIS_Child.Show;
     //GIS_Child.AddGrid(sFilename);
     //GIS_Child.Caption := 'GIS';

     ComboField.Items.Clear;
     ComboField.Items.Add('VALUE');
     ComboField.Text := 'VALUE';

     //fCreatedGISWindow := True;
end;

procedure TProfileElementForm.FileListBox1Change(Sender: TObject);
var
   sExtension : string;
begin
     if fileexists(FileListBox1.FileName) then
     begin
          if fCreatedGISWindow then
          begin
               GIS_Child.Close;
               fCreatedGISWindow := False;
          end;

          sExtension := LowerCase(ExtractFileExt(FileListBox1.Filename));

          if (sExtension = '.shp') then
             ReadShapeFields(FileListBox1.Filename);

          if (sExtension = '.adf') then
             ReadGridFields(FileListBox1.Filename);
     end;
end;

procedure TProfileElementForm.FormCreate(Sender: TObject);
begin
     fCreatedGISWindow := False;
     fEditDataField := False;
end;

procedure TProfileElementForm.BitBtnOkClick(Sender: TObject);
begin
     if (FileListBox1.Filename = '') or (ComboField.Text = '') or (ComboDataType.Text = '') then
        MessageDlg('Specify File, Field and Data Type before accepting changes.',mtInformation,[mbOk],0)
     else
     begin
          if fCreatedGISWindow then
          begin
               GIS_Child.Close;
               fCreatedGISWindow := False;
          end;

          if fEditDataField then
             BuildChild.EditDataField(FileListBox1.Filename,ComboField.Text,ComboDataType.Text)
          else
              BuildChild.AddDataField(FileListBox1.Filename,ComboField.Text,ComboDataType.Text);

          ModalResult := mrOk;
     end;
end;

procedure TProfileElementForm.BitBtnCancelClick(Sender: TObject);
begin
     if fCreatedGISWindow then
        GIS_Child.Close;
end;

procedure TProfileElementForm.FormResize(Sender: TObject);
begin
     ResizeTheForm;
end;

procedure TProfileElementForm.DirectoryListBox1Change(Sender: TObject);
begin
     if fCreatedGISWindow then
     begin
          GIS_Child.Close;
          fCreatedGISWindow := False;
     end;
end;

procedure TProfileElementForm.DriveComboBox1Change(Sender: TObject);
begin
     if fCreatedGISWindow then
     begin
          GIS_Child.Close;
          fCreatedGISWindow := False;
     end;
end;

end.
