unit new_project;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, Db, DBTables, ExtCtrls, ComCtrls;

type
  TNewProjectForm = class(TForm)
    OpenShape: TOpenDialog;
    PuTable: TTable;
    TopPanel: TPanel;
    LabelProjectName: TLabel;
    EditProjectName: TEdit;
    CheckMarxan: TCheckBox;
    LabelMarxan: TLabel;
    EditMarxan: TEdit;
    CheckCPlan: TCheckBox;
    CheckeFlows: TCheckBox;
    LabelCPlan: TLabel;
    EditCPlan: TEdit;
    LabeleFlows: TLabel;
    EditeFlows: TEdit;
    btnBrowseMarxan: TButton;
    btnBrowseCPlan: TButton;
    btnBrowseeFlows: TButton;
    OpenMarxan: TOpenDialog;
    OpenCPlan: TOpenDialog;
    OpeneFlows: TOpenDialog;
    GroupBox1: TGroupBox;
    ListBoxShapefiles: TListBox;
    Panel2: TPanel;
    btnBrowseShape: TButton;
    btnRemoveShape: TButton;
    BottomPanel: TPanel;
    LabelShape: TLabel;
    LabelPUKey: TLabel;
    ComboPUShape: TComboBox;
    ComboPUKey: TComboBox;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    UpDown1: TUpDown;
    procedure CheckMarxanClick(Sender: TObject);
    procedure CheckCPlanClick(Sender: TObject);
    procedure btnBrowseMarxanClick(Sender: TObject);
    procedure btnBrowseCPlanClick(Sender: TObject);
    procedure btnBrowseShapeClick(Sender: TObject);
    procedure btnRemoveShapeClick(Sender: TObject);
    procedure ComboPUShapeChange(Sender: TObject);
    procedure ScanPUFields;
    procedure CheckeFlowsClick(Sender: TObject);
    procedure AreWeUsingPuLayer;
    procedure btnBrowseeFlowsClick(Sender: TObject);
    procedure BottomPanelResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TopPanelResize(Sender: TObject);
    procedure MoveListBoxItem(Button: TUDBtnType);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure ListBoxShapefilesMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewProjectForm: TNewProjectForm;

implementation

uses
    Miscellaneous;
{$R *.DFM}

procedure TNewProjectForm.AreWeUsingPuLayer;
begin
     if (CheckMarxan.Checked or CheckCPlan.Checked or CheckeFlows.Checked) then
     begin
          LabelShape.Enabled := True;
          ComboPUShape.Enabled := True;
          LabelPUKey.Enabled := True;
          ComboPUKey.Enabled := True;
     end
     else
     begin
          LabelShape.Enabled := False;
          ComboPUShape.Enabled := False;
          LabelPUKey.Enabled := False;
          ComboPUKey.Enabled := False;
          ComboPUShape.Text := '';
          ComboPUKey.Text := '';
     end;
end;

procedure TNewProjectForm.CheckMarxanClick(Sender: TObject);
begin
     LabelMarxan.Enabled := CheckMarxan.Checked;
     EditMarxan.Enabled := CheckMarxan.Checked;
     btnBrowseMarxan.Enabled := CheckMarxan.Checked;

     if not CheckMarxan.Checked then
        EditMarxan.Text := '';

     AreWeUsingPuLayer;
end;

procedure TNewProjectForm.CheckCPlanClick(Sender: TObject);
begin
     LabelCPlan.Enabled := CheckCPlan.Checked;
     EditCPlan.Enabled := CheckCPlan.Checked;
     btnBrowseCPlan.Enabled := CheckCPlan.Checked;

     if not CheckCPlan.Checked then
        EditCPlan.Text := '';

     AreWeUsingPuLayer;
end;

procedure TNewProjectForm.CheckeFlowsClick(Sender: TObject);
begin
     LabeleFlows.Enabled := CheckeFlows.Checked;
     EditeFlows.Enabled := CheckeFlows.Checked;
     btnBrowseeFlows.Enabled := CheckeFlows.Checked;

     if not CheckeFlows.Checked then
        EditeFlows.Text := '';

     AreWeUsingPuLayer;
end;

procedure TNewProjectForm.btnBrowseMarxanClick(Sender: TObject);
begin
     if OpenMarxan.Execute then
        EditMarxan.Text := OpenMarxan.FileName;
end;

procedure TNewProjectForm.btnBrowseCPlanClick(Sender: TObject);
begin
     if OpenCPlan.Execute then
        EditCPlan.Text := OpenCPlan.FileName;
end;

procedure TNewProjectForm.btnBrowseShapeClick(Sender: TObject);
var
   fShpFile : boolean;
begin
     if OpenShape.Execute then
     begin
          ListBoxShapefiles.Items.Add(OpenShape.FileName);

          fShpFile := (LowerCase(ExtractFileExt(OpenShape.FileName)) = '.shp');

          if (fShpFile) then
          begin
               ComboPUShape.Items.Add(OpenShape.FileName);

               if (ComboPUShape.Enabled) then
                  if (ComboPUShape.Items.Count = 1) then
                  begin
                       ComboPUShape.Text := ComboPUShape.Items.Strings[0];
                       try
                          ScanPUFields;
                       except
                       end;
                  end;
          end;
     end;
end;

procedure TNewProjectForm.btnRemoveShapeClick(Sender: TObject);
begin
     if (ListBoxShapefiles.Items.Count > 0) then
        if (ListBoxShapefiles.ItemIndex > -1) then
        begin
             ListBoxShapefiles.Items.Delete(ListBoxShapefiles.ItemIndex);
             ComboPUShape.Items.Delete(ListBoxShapefiles.ItemIndex);

             if (ComboPUShape.Enabled) then
                if (ComboPUShape.Items.Count > 0) then
                   ComboPUShape.Text := ComboPUShape.Items.Strings[0];
        end;
end;

procedure TNewProjectForm.ScanPUFields;
var
   sTableName : string;
   iCount : integer;
begin
     if (ComboPUShape.Text <> '') then
        if fileexists(ComboPUShape.Text) then
        begin
             PUTable.DatabaseName := ExtractFilePath(ComboPUShape.Text);
             sTableName := ExtractFileName(ComboPUShape.Text);
             sTableName := Copy(sTableName,1,Length(sTableName)-4);
             PUTable.TableName := sTableName + '.dbf';

             if fileexists(ExtractFilePath(ComboPUShape.Text) + sTableName + '.dbf') then
             begin
                  PUTable.Open;

                  ComboPUKey.Items.Clear;
                  ComboPUKey.Text := '';
                  for iCount := 0 to (PUTable.FieldCount - 1) do
                      ComboPUKey.Items.Add(PUTable.FieldDefs.Items[iCount].Name);
                  ComboPUKey.Text := ComboPUKey.Items.Strings[0];

                  PUTable.Close;
             end;
        end;
end;

procedure TNewProjectForm.ComboPUShapeChange(Sender: TObject);
begin
     if (ComboPUShape.Text <> '') then
        ScanPUFields;
end;

procedure TNewProjectForm.btnBrowseeFlowsClick(Sender: TObject);
begin
     if OpeneFlows.Execute then
        EditeFlows.Text := OpeneFlows.FileName;
end;

procedure TNewProjectForm.BottomPanelResize(Sender: TObject);
begin
     ComboPUShape.Width := BottomPanel.Width - ComboPUShape.Left - LabelShape.Left;
     ComboPUKey.Width := ComboPUShape.Width;
     btnCancel.Left := BottomPanel.Width - btnOk.Width - btnOk.Left;
end;

procedure TNewProjectForm.FormCreate(Sender: TObject);
begin
     CheckeFlows.Visible := fDisplayeFlowsGUI;
     EditeFlows.Visible := fDisplayeFlowsGUI;
     LabeleFlows.Visible := fDisplayeFlowsGUI;
     btnBrowseeFlows.Visible := fDisplayeFlowsGUI;

     if (fDisplayeFlowsGUI) then
        TopPanel.Height := EditeFlows.Top + (EditeFlows.Height * 2)
     else
         TopPanel.Height := EditCPlan.Top + (EditCPlan.Height * 2);
end;

procedure TNewProjectForm.TopPanelResize(Sender: TObject);
begin
     EditProjectName.Width := TopPanel.Width - EditProjectName.Left - LabelProjectName.Left;
     btnBrowseMarxan.Left := TopPanel.Width - CheckMarxan.Left - btnBrowseMarxan.Width;
     btnBrowseCPlan.Left := btnBrowseMarxan.Left;
     btnBrowseeFlows.Left := btnBrowseMarxan.Left;
     EditMarxan.Width := TopPanel.Width - EditMarxan.Left - (2 * CheckMarxan.Left) - btnBrowseMarxan.Width;
     EditCPlan.Width := EditMarxan.Width;
     EditeFlows.Width := EditMarxan.Width;
end;

procedure TNewProjectForm.MoveListBoxItem(Button: TUDBtnType);
var
   iItemIndex : integer;
begin
     iItemIndex := ListBoxShapefiles.ItemIndex;
     // btNext refers to the Up or Right arrow, and btPrev refers to the Down or Left arrow.
     if (Button = btNext) then
        // move the selected shape up in the list
        if (iItemIndex > 0) then
        begin
             ListBoxShapefiles.Items.Exchange(iItemIndex,iItemIndex-1);
             ListBoxShapefiles.ItemIndex := iItemIndex-1;
        end;
     if (Button = btPrev) then
        // move the selected shape down in the list
        if (iItemIndex < (ListBoxShapefiles.Items.Count-1)) then
        begin
             ListBoxShapefiles.Items.Exchange(iItemIndex,iItemIndex+1);
             ListBoxShapefiles.ItemIndex := iItemIndex+1;
        end;
end;

procedure TNewProjectForm.UpDown1Click(Sender: TObject;
  Button: TUDBtnType);
begin
     MoveListBoxItem(Button);
end;

procedure TNewProjectForm.ListBoxShapefilesMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     if (ListBoxShapefiles.Items.Count > 0) then
        if (ListBoxShapefiles.ItemIndex > -1) then
           if (LowerCase(ExtractFileExt(ListBoxShapefiles.Items.Strings[ListBoxShapefiles.ItemIndex])) = '.shp') then
              ComboPUShape.Text := ListBoxShapefiles.Items.Strings[ListBoxShapefiles.ItemIndex];
end;

end.
