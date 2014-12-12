unit Build_Child;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Grids, ExtCtrls;

type
  TBuildChild = class(TForm)
    BottomPanel: TPanel;
    TopPanel: TPanel;
    MidPanel: TPanel;
    ProfileGrid: TStringGrid;
    BitBtnBuild: TBitBtn;
    BitBtnCancel: TBitBtn;
    btnNew: TButton;
    btnLoad: TButton;
    btnSave: TButton;
    btnEdit: TButton;
    btnDelete: TButton;
    btnUp: TButton;
    btnAdd: TButton;
    btnDown: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure ResizeTheForm;
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BitBtnCancelClick(Sender: TObject);
    procedure LoadProfile(const sFilename : string);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure AddDataField(const sFilename,sFieldName,sDataType : string);
    procedure EditDataField(const sFilename,sFieldName,sDataType : string);
    procedure FormCreate(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure InitProfileGrid;
    procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    function IsProfileAboveMinimumRequired : boolean;
    procedure BitBtnBuildClick(Sender: TObject);
    procedure ExecuteBuild;
    procedure FormActivate(Sender: TObject);
    function ReturnPuLayerRow : integer;
    function ReturnOutputDirectoryName(const sPuLayerFileName : string) : string;    
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BuildChild: TBuildChild;
  iDataFieldsAdded : integer;

implementation

uses
    Edit_Profile_Element, Miscellaneous, SCP_Main, FileCtrl, GIS;

{$R *.DFM}

procedure TBuildChild.LoadProfile(const sFilename : string);
begin
     if fileexists(sFilename) then
     begin
          FasterLoadCSV2StringGrid(ProfileGrid,sFilename);
          iDataFieldsAdded := ProfileGrid.RowCount - 1;
          Caption := sFilename;

          AutoFitGrid(ProfileGrid,Canvas,True);  
     end;
end;

procedure TBuildChild.ResizeTheForm;
begin
     // move controls on top panel
     btnLoad.Left := (TopPanel.ClientWidth - btnLoad.Width) div 2;
     btnSave.Left := TopPanel.ClientWidth - (btnNew.Left * 2) - btnSave.Width;

     // move controls on middle panel
     ProfileGrid.Width := MidPanel.ClientWidth - (3 * ProfileGrid.Left) - btnAdd.Width;
     ProfileGrid.Height := MidPanel.ClientHeight - (2 * ProfileGrid.Top);
     btnAdd.Left := (2 * ProfileGrid.Left) + ProfileGrid.Width;
     btnEdit.Left := btnAdd.Left;
     btnDelete.Left := btnAdd.Left;
     btnUp.Left := btnAdd.Left;
     btnDown.Left := btnAdd.Left;

     // move controls on bottom panel
     BitBtnCancel.Left := BottomPanel.ClientWidth - (BitBtnBuild.Left * 2) - BitBtnCancel.Width;
end;

procedure TBuildChild.FormResize(Sender: TObject);
begin
     ResizeTheForm;
end;

procedure TBuildChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     Action := caFree;
end;

procedure TBuildChild.BitBtnCancelClick(Sender: TObject);
begin
     Close;
end;

procedure TBuildChild.btnAddClick(Sender: TObject);
begin
     ProfileElementForm := TProfileElementForm.Create(Application);
     ProfileElementForm.ShowModal;
     ProfileElementForm.Free;
end;

procedure TBuildChild.btnEditClick(Sender: TObject);
begin
     ProfileElementForm := TProfileElementForm.Create(Application);
     ProfileElementForm.PrepareEdit(ProfileGrid.Cells[0,ProfileGrid.Selection.Top],
                                    ProfileGrid.Cells[0,ProfileGrid.Selection.Top],
                                    ProfileGrid.Cells[0,ProfileGrid.Selection.Top]);
     ProfileElementForm.ShowModal;
     ProfileElementForm.Free;
end;

procedure TBuildChild.AddDataField(const sFilename,sFieldName,sDataType : string);
begin
     Inc(iDataFieldsAdded);

     if (ProfileGrid.RowCount < (iDataFieldsAdded + 1)) then
        ProfileGrid.RowCount := ProfileGrid.RowCount + 1;

     ProfileGrid.Cells[0,iDataFieldsAdded] := sFilename;
     ProfileGrid.Cells[1,iDataFieldsAdded] := sFieldName;
     ProfileGrid.Cells[2,iDataFieldsAdded] := sDataType;

     AutoFitGrid(ProfileGrid,Canvas,True);
end;

procedure TBuildChild.EditDataField(const sFilename,sFieldName,sDataType : string);
begin
     if (iDataFieldsAdded = 0) then
        Inc(iDataFieldsAdded);

     if (ProfileGrid.RowCount < (iDataFieldsAdded + 1)) then
        ProfileGrid.RowCount := ProfileGrid.RowCount + 1;

     ProfileGrid.Cells[0,ProfileGrid.Selection.Top] := sFilename;
     ProfileGrid.Cells[1,ProfileGrid.Selection.Top] := sFieldName;
     ProfileGrid.Cells[2,ProfileGrid.Selection.Top] := sDataType;

     AutoFitGrid(ProfileGrid,Canvas,True);
end;

procedure TBuildChild.FormCreate(Sender: TObject);
begin
     InitProfileGrid;
end;

procedure TBuildChild.InitProfileGrid;
begin
     iDataFieldsAdded := 0;
     ProfileGrid.RowCount := 2;
     ProfileGrid.ColCount := 3;
     ProfileGrid.Cells[0,0] := 'layer';
     ProfileGrid.Cells[1,0] := 'field';
     ProfileGrid.Cells[2,0] := 'type';
     ProfileGrid.Cells[0,1] := '';
     ProfileGrid.Cells[1,1] := '';
     ProfileGrid.Cells[2,1] := '';
end;

procedure TBuildChild.btnNewClick(Sender: TObject);
begin
     InitProfileGrid;
end;

procedure TBuildChild.btnLoadClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
        LoadProfile(OpenDialog1.Filename);
end;

procedure TBuildChild.btnSaveClick(Sender: TObject);
begin
     if SaveDialog1.Execute then
        SaveStringGrid2CSV(ProfileGrid,SaveDialog1.Filename);
end;

procedure TBuildChild.btnDeleteClick(Sender: TObject);
var
   iCount : integer;
begin
     if (iDataFieldsAdded > 0) then
     begin
          Dec(iDataFieldsAdded);

          ProfileGrid.Cells[0,ProfileGrid.Selection.Top] := '';
          ProfileGrid.Cells[1,ProfileGrid.Selection.Top] := '';
          ProfileGrid.Cells[2,ProfileGrid.Selection.Top] := '';

          // move up contents under it in the grid (if any)
          if (ProfileGrid.Selection.Top < (ProfileGrid.RowCount - 1)) then
             for iCount := ProfileGrid.Selection.Top to (ProfileGrid.RowCount - 2) do
             begin
                  ProfileGrid.Cells[0,iCount] := ProfileGrid.Cells[0,iCount+1];
                  ProfileGrid.Cells[1,iCount] := ProfileGrid.Cells[1,iCount+1];
                  ProfileGrid.Cells[2,iCount] := ProfileGrid.Cells[2,iCount+1];
             end;

          // remove row from grid if necessary
          if (ProfileGrid.RowCount > 2) then
             ProfileGrid.RowCount := ProfileGrid.RowCount - 1;
     end;
end;

procedure TBuildChild.btnUpClick(Sender: TObject);
var
   sTmp : string;
begin
     if (iDataFieldsAdded > 1) then
        if (ProfileGrid.Selection.Top > 1) then
        begin
             sTmp := ProfileGrid.Cells[0,ProfileGrid.Selection.Top-1];
             ProfileGrid.Cells[0,ProfileGrid.Selection.Top-1] := ProfileGrid.Cells[0,ProfileGrid.Selection.Top];
             ProfileGrid.Cells[0,ProfileGrid.Selection.Top] := sTmp;

             sTmp := ProfileGrid.Cells[1,ProfileGrid.Selection.Top-1];
             ProfileGrid.Cells[1,ProfileGrid.Selection.Top-1] := ProfileGrid.Cells[1,ProfileGrid.Selection.Top];
             ProfileGrid.Cells[1,ProfileGrid.Selection.Top] := sTmp;

             sTmp := ProfileGrid.Cells[2,ProfileGrid.Selection.Top-1];
             ProfileGrid.Cells[2,ProfileGrid.Selection.Top-1] := ProfileGrid.Cells[2,ProfileGrid.Selection.Top];
             ProfileGrid.Cells[2,ProfileGrid.Selection.Top] := sTmp;

             //iTop := ProfileGrid.Selection.Top;
             //iBottom := ProfileGrid.Selection.Bottom;
             //ProfileGrid.Selection.Top := iTop - 1;
             //ProfileGrid.Selection.Bottom; := iBottom - 1;
        end;
end;

procedure TBuildChild.btnDownClick(Sender: TObject);
var
   sTmp : string;
begin
     if (iDataFieldsAdded > 1) then
        if (ProfileGrid.Selection.Top < (ProfileGrid.RowCount-1)) then
        begin
             sTmp := ProfileGrid.Cells[0,ProfileGrid.Selection.Top+1];
             ProfileGrid.Cells[0,ProfileGrid.Selection.Top+1] := ProfileGrid.Cells[0,ProfileGrid.Selection.Top];
             ProfileGrid.Cells[0,ProfileGrid.Selection.Top] := sTmp;

             sTmp := ProfileGrid.Cells[1,ProfileGrid.Selection.Top+1];
             ProfileGrid.Cells[1,ProfileGrid.Selection.Top+1] := ProfileGrid.Cells[1,ProfileGrid.Selection.Top];
             ProfileGrid.Cells[1,ProfileGrid.Selection.Top] := sTmp;

             sTmp := ProfileGrid.Cells[2,ProfileGrid.Selection.Top+1];
             ProfileGrid.Cells[2,ProfileGrid.Selection.Top+1] := ProfileGrid.Cells[2,ProfileGrid.Selection.Top];
             ProfileGrid.Cells[2,ProfileGrid.Selection.Top] := sTmp;

             //iTop := ProfileGrid.Selection.Top;
             //iBottom := ProfileGrid.Selection.Bottom;
             //ProfileGrid.Selection.Top := iTop + 1;
             //ProfileGrid.Selection.Bottom; := iBottom + 1;
        end;
end;

function TBuildChild.IsProfileAboveMinimumRequired : boolean;
var
   iCount, iPulayers, iFeatures : integer;
begin
     iPulayers := 0;
     iFeatures := 0;

     for iCount := 1 to (ProfileGrid.RowCount - 1) do
     begin
          if (ProfileGrid.Cells[2,iCount] = 'Planning unit layer') then
             Inc(iPulayers);
          if (ProfileGrid.Cells[2,iCount] = 'Feature') then
             Inc(iFeatures);
     end;

     Result := (iPulayers = 1) and (iFeatures > 0);
end;

procedure TBuildChild.BitBtnBuildClick(Sender: TObject);
begin
     if IsProfileAboveMinimumRequired then
     begin
          ExecuteBuild;
          ModalResult := mrOk;
     end
     else
         MessageDlg('Invalid Build Profile.  Specify only one Planning Unit layer, and at least on Feature layer to continue.',
                    mtInformation,[mbOk],0);
end;

function TBuildChild.ReturnPuLayerRow : integer;
var
   iCount : integer;
begin
     Result := -1;
     for iCount := 1 to (ProfileGrid.RowCount - 1) do
         if (ProfileGrid.Cells[2,iCount] = 'Planning unit layer') then
            Result := iCount;
end;

function TBuildChild.ReturnOutputDirectoryName(const sPuLayerFileName : string) : string;
var
   iCount : integer;
   sDirectory : string;
begin
     sDirectory := ExtractFilePath(sPuLayerFileName);

     iCount := 1;
     Result := sDirectory + 'build' + IntToStr(iCount);

     while fileexists(Result) do
     begin
          Inc(iCount);
          Result := sDirectory + 'build' + IntToStr(iCount);
     end;
end;

procedure TBuildChild.ExecuteBuild;
var
   iPuLayerRow, iCount, iPuGridHandle, iFeatureLayerHandle : integer;
   sOutputDirectoryName, sTempOutputDirectoryName,
   sPuGridFileName, sFeatureGridName, sTmp : string;
begin
     // create a folder for database to live
     iPuLayerRow := ReturnPuLayerRow;
     if (iPuLayerRow > -1) then
     begin
          sOutputDirectoryName := ReturnOutputDirectoryName(ProfileGrid.Cells[0,iPuLayerRow]);
          ForceDirectories(sOutputDirectoryName);
          sTempOutputDirectoryName := sOutputDirectoryName + '\temp';
          ForceDirectories(sTempOutputDirectoryName);

          // save build profile to the database
          SaveStringGrid2CSV(ProfileGrid,sOutputDirectoryName + '\Marxan_build_profile.mbp');

          // seek pulayer and add it to the map document
          GIS_Child := TGIS_Child.Create(Application);
          GIS_Child.Show;
          if (LowerCase(ExtractFileExt(ProfileGrid.Cells[0,iPuLayerRow])) = '.shp') then
          begin
               sTmp := 'D:\Marxan101\data\species\tasinvis\w001001.adf';

               // convert planning unit polygons to a grid
               sPuGridFileName := sTempOutputDirectoryName + '\pulayer.adf';
               iPuGridHandle := GIS_Child.PolygonFile2GridFile(ProfileGrid.Cells[0,iPuLayerRow],
                                                               sTmp,
                                                               sPuGridFileName,
                                                               1000);
          end
          else
          begin
               iPuGridHandle := GIS_Child.AddGrid(ProfileGrid.Cells[0,iPuLayerRow]);
          end;

          GIS_Child.Caption := 'GIS';

          // traverse all layers in the profile
          for iCount := 1 to (ProfileGrid.RowCount - 1) do
              if (iCount <> iPuLayerRow) then
              begin
                   // if layer is not pulayer, intersect it with the pulayer, writing result to a series of sparse matrix files
                   if (LowerCase(ExtractFileExt(ProfileGrid.Cells[0,iCount])) = '.shp') then
                   begin
                        sFeatureGridName := sTempOutputDirectoryName + '\feature_' + IntToStr(iCount) + '.adf';

                        iFeatureLayerHandle := GIS_Child.PolygonFile2GridFile(ProfileGrid.Cells[0,iCount],
                                                                        '',
                                                                        sFeatureGridName,
                                                                        1000);
                        // convert feature polygons to a grid
                   end
                   else
                   begin
                        iFeatureLayerHandle := GIS_Child.AddGrid(ProfileGrid.Cells[0,iCount]);
                   end;

                   GIS_Child.IntersectGrids(iPuGridHandle,iFeatureLayerHandle,
                                            sTempOutputDirectoryName + '\PUVSPR_' + IntToStr(iCount) + '.csv',
                                            sTempOutputDirectoryName + '\SP_' + IntToStr(iCount) + '.csv',
                                            sTempOutputDirectoryName + '\PU_' + IntToStr(iCount) + '.csv',
                                            True);

                   GIS_Child.Map1.RemoveLayer(iFeatureLayerHandle);
              end;

          GIS_Child.Map1.RemoveLayer(iPuGridHandle);
          GIS_Child.Close;

          // join all sparse matrix files into a marxan dataset

          // create ZCP file for this dataset and load it into the tool
     end;
end;

procedure TBuildChild.FormActivate(Sender: TObject);
begin
     SCPForm.SwitchChildFocus;
end;

end.
