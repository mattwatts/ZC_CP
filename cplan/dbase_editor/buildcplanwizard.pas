unit buildcplanwizard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Gauges, StdCtrls, Buttons, Spin, ExtCtrls, Grids,
  Childwin,
  ds;

type
  TBuildCPlanWizardForm = class(TForm)
    Notebook1: TNotebook;
    btnNext: TButton;
    BitBtn1: TBitBtn;
    btnBrowse: TButton;
    Label43: TLabel;
    Button31: TButton;
    BitBtn18: TBitBtn;
    ComboNameField: TComboBox;
    Button32: TButton;
    Button33: TButton;
    Label36: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Button29: TButton;
    Button30: TButton;
    BitBtn17: TBitBtn;
    PCContrCutOff: TSpinEdit;
    Button2: TButton;
    BitBtn2: TBitBtn;
    Button11: TButton;
    ComboAreaField: TComboBox;
    Button34: TButton;
    Button13: TButton;
    Button14: TButton;
    BitBtn10: TBitBtn;
    ComboTenureField: TComboBox;
    Button35: TButton;
    Label6: TLabel;
    SelHighlightTbl: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    UnSelHighlightTbl: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Label9: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Button4: TButton;
    BitBtn4: TBitBtn;
    OrigTenure: TListBox;
    AvailTenure: TListBox;
    ResTenure: TListBox;
    IgnTenure: TListBox;
    Button15: TButton;
    ComboTargetField: TComboBox;
    Button21: TButton;
    Button22: TButton;
    BitBtn13: TBitBtn;
    Button36: TButton;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Button20: TButton;
    Button25: TButton;
    BitBtn15: TBitBtn;
    EditOutputPath: TEdit;
    EditDatabaseName: TEdit;
    Button26: TButton;
    Label20: TLabel;
    Label21: TLabel;
    BitBtn11: TBitBtn;
    Button1: TButton;
    BitBtn12: TBitBtn;
    btnSaveSpec: TButton;
    btnLoadSpec: TButton;
    Gauge1: TGauge;
    LabelProgress: TLabel;
    AvailableTablesGrid: TStringGrid;
    ComboAvailableKey: TComboBox;
    Label7: TLabel;
    LabelAvailableTable: TLabel;
    NameTablesGrid: TStringGrid;
    LabelNameTable: TLabel;
    AreaTablesGrid: TStringGrid;
    TenureTablesGrid: TStringGrid;
    TargetTablesGrid: TStringGrid;
    LabelAreaTable: TLabel;
    LabelTenureTable: TLabel;
    LabelTargetTable: TLabel;
    ComboNameKey: TComboBox;
    ComboAreaKey: TComboBox;
    ComboTenureKey: TComboBox;
    ComboTargetKey: TComboBox;
    btnCancelTable: TButton;
    Button3: TButton;
    Button5: TButton;
    Button6: TButton;
    Panel1: TPanel;
    Label1: TLabel;
    Panel2: TPanel;
    Label25: TLabel;
    Label40: TLabel;
    Panel3: TPanel;
    Label3: TLabel;
    Label2: TLabel;
    Label8: TLabel;
    Panel4: TPanel;
    Label5: TLabel;
    Label10: TLabel;
    Label16: TLabel;
    Panel5: TPanel;
    Label23: TLabel;
    Label11: TLabel;
    Label17: TLabel;
    ComboBox1: TComboBox;
    MatrixGrid: TStringGrid;
    btnAddTableToMatrix: TSpeedButton;
    btnRemoveTable: TSpeedButton;
    Panel6: TPanel;
    Label4: TLabel;
    LabelFeatureNameTable: TLabel;
    ComboFeatureNameKey: TComboBox;
    Label18: TLabel;
    Label19: TLabel;
    ComboFeatureNameField: TComboBox;
    FeatureNameTablesGrid: TStringGrid;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    BitBtn3: TBitBtn;
    procedure FormCreate(Sender: TObject);
    function ListTableFields(const Child : TMDIChild) : string;
    procedure ListAvailableTables;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure Button25Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button26Click(Sender: TObject);
    procedure AvailableTablesGridClick(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
    procedure ImportCPlanMatrix;
    function ConvertMatrixTable(ASourceChild : TMDIChild;
                                const sSourceKey, sOutputPath, sMatrixName : string) : boolean;
    function CreateSiteTable : boolean;
    function CreateFeatureTable : boolean;
    procedure CreateIniFile;
    procedure ListRemainingTables;
    procedure ListTables(const sDestTbl : string;
                         AGrid : TStringGrid);
    procedure PrepareComboNameField;
    procedure Button32Click(Sender: TObject);
    procedure Button31Click(Sender: TObject);
    procedure Button29Click(Sender: TObject);
    procedure Button30Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SelHighlightTblClick(Sender: TObject);
    procedure UnSelHighlightTblClick(Sender: TObject);
    procedure TableGridClick(AGrid : TStringGrid;
                             ALabel : TLabel;
                             ACombo : TComboBox;
                             AKeyCombo : TComboBox);
    procedure NameTablesGridClick(Sender: TObject);
    procedure AreaTablesGridClick(Sender: TObject);
    procedure TenureTablesGridClick(Sender: TObject);
    procedure TargetTablesGridClick(Sender: TObject);
    procedure btnCancelTableClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure ImportCPlanFields;
    procedure PopulateI_STATUSField;
    procedure tall_form;
    procedure short_form;
    procedure ComboAvailableKeyChange(Sender: TObject);
    procedure ComboNameKeyChange(Sender: TObject);
    procedure ComboAreaKeyChange(Sender: TObject);
    procedure ComboTenureKeyChange(Sender: TObject);
    procedure ComboTargetKeyChange(Sender: TObject);
    procedure btnAddTableToMatrixClick(Sender: TObject);
    procedure btnRemoveTableClick(Sender: TObject);
    function ConvertMatrices : boolean;
    procedure MakeMasterFeatureList;
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure ComboFeatureNameKeyChange(Sender: TObject);
    procedure FeatureNameTablesGridClick(Sender: TObject);
    procedure GenerateCPlanWizardParamFile;
    procedure WizardParamCall;
    procedure AddTableToMatrix;
    procedure ParamCall_AddMatrixTables;
  private
    { Private declarations }
  public
    { Public declarations }
    sMatrixTable : string;
    //MatrixChild : TMDIChild;
    MasterFeatureList : Array_t;
  end;

var
  BuildCPlanWizardForm: TBuildCPlanWizardForm;

implementation

uses
    Converter, Main, browsed,
    inifiles, importintotablewizard;

{$R *.DFM}

procedure TBuildCPlanWizardForm.WizardParamCall;
begin
     // The wizard has been called by an Avenue script.
     // Load all tables as matrix inputs into the table editor.
     ParamCall_AddMatrixTables;
end;

procedure TBuildCPlanWizardForm.tall_form;
begin
     Height := BitBtn1.Top + BitBtn1.Height + 20 + Panel1.Height;
     Width := BitBtn1.Left + BitBtn1.Width + 20;
end;

procedure TBuildCPlanWizardForm.short_form;
begin
     Height := BitBtn18.Top + BitBtn18.Height + 20 + Panel1.Height;
     Width := BitBtn18.Left + BitBtn18.Width + 20;
end;

function TBuildCPlanWizardForm.ListTableFields(const Child : TMDIChild) : string;
var
   iCount : integer;
begin
     // list the fields from the table
     ComboAvailableKey.Items.Clear;
     ComboAvailableKey.Text := Child.Query1.FieldDefs.Items[0].Name;
     Result := ComboAvailableKey.Text;
     for iCount := 0 to (Child.Query1.FieldDefs.Count - 1) do
         ComboAvailableKey.Items.Add(Child.Query1.FieldDefs.Items[iCount].Name);
end;

procedure TBuildCPlanWizardForm.ListAvailableTables;
var
   iCount : integer;
begin
     if (MainForm.MDIChildCount > 0) then
     try
        // we must list all the tables users can choose from
        AvailableTablesGrid.ColCount := 3;
        AvailableTablesGrid.RowCount := MainForm.MDIChildCount + 1;

        AvailableTablesGrid.Cells[0,0] := 'Table Name';
        AvailableTablesGrid.Cells[1,0] := 'Key Field';
        AvailableTablesGrid.Cells[2,0] := 'Path';

        for iCount := 0 to (MainForm.MDIChildCount-1) do
        begin
             AvailableTablesGrid.Cells[0,iCount+1] := ExtractFileName( TMDIChild(MainForm.MDIChildren[iCount]).sFilename );
             AvailableTablesGrid.Cells[1,iCount+1] := '';
             AvailableTablesGrid.Cells[2,iCount+1] := TrimTrailingSlashes(ExtractFilePath( TMDIChild(MainForm.MDIChildren[iCount]).sFilename ));
        end;

        LabelAvailableTable.Caption := 'Table   ' + AvailableTablesGrid.Cells[0,1];

        AutoFitGrid(AvailableTablesGrid,Canvas,True);

        // list the fields from the first table in the list of loaded tables
        AvailableTablesGrid.Cells[1,1] := ListTableFields(TMDIChild(MainForm.MDIChildren[0]));

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ListAvailableTables',mtError,[mbOk],0);
     end;
end;

procedure TBuildCPlanWizardForm.ParamCall_AddMatrixTables;
var
   iCount : integer;
   ASelection : TGridRect;
begin
     try
        ASelection.Left := 1;
        ASelection.Right := 1;
        for iCount := 1 to (AvailableTablesGrid.RowCount-1) do
        begin
             ASelection.Top := iCount;
             ASelection.Bottom := iCount;
             // select this row, trigger select event for grid
             AvailableTablesGrid.Selection := ASelection;
             TableGridClick(AvailableTablesGrid,LabelAvailableTable,ComboBox1,ComboAvailableKey);

             // add this row to list of matrix tables
             AddTableToMatrix;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ParamCall_AddMatrixTables',mtError,[mbOk],0);
     end;
end;

procedure TBuildCPlanWizardForm.FormCreate(Sender: TObject);
begin
     // we must list all the tables users can choose from
     tall_form;
     Notebook1.PageIndex := 0;
     ListAvailableTables;

     MatrixGrid.ColCount := 3;
     MatrixGrid.RowCount := 2;
     MatrixGrid.FixedRows := 1;
     MatrixGrid.Cells[0,0] := 'Table Name';
     MatrixGrid.Cells[1,0] := 'Key Field';
     MatrixGrid.Cells[2,0] := 'Path';
     AutoFitGrid(MatrixGrid,Canvas,True);
end;

procedure TBuildCPlanWizardForm.btnBrowseClick(Sender: TObject);
begin
     // browse another table
     MainForm.FileOpenItemClick(Sender);
     // reset table list
     ListAvailableTables;
end;

procedure TBuildCPlanWizardForm.ListRemainingTables;
begin
     ListTables(sMatrixTable,NameTablesGrid);
     ListTables(sMatrixTable,AreaTablesGrid);
     ListTables(sMatrixTable,TenureTablesGrid);
     ListTables(sMatrixTable,FeatureNameTablesGrid);
     ListTables(sMatrixTable,TargetTablesGrid);

     { these need to be populated with fields when the user
       clicks one of the tables in the wizard
     ComboNameField
     ComboAreaField
     ComboTenureField
     ComboTargetField
     }
     LabelNameTable.Caption := 'no table selected';
     LabelAreaTable.Caption := 'no table selected';
     LabelTenureTable.Caption := 'no table selected';
     LabelTargetTable.Caption := 'no table selected';
     LabelFeatureNameTable.Caption := 'no table selected';
end;

procedure TBuildCPlanWizardForm.ListTables(const sDestTbl : string;
                                           AGrid : TStringGrid);
var
   iCount, iRow : integer;
begin
     // list all tables in the SourceTablesGrid except for sDestTbl
     if (MainForm.MDIChildCount > 0) then
     try
        // we must list all the tables users can choose from
        AGrid.ColCount := 3;
        AGrid.RowCount := MainForm.MDIChildCount;

        if (AGrid.RowCount > 1) then
           AGrid.FixedRows := 1;

        AGrid.Cells[0,0] := 'Table Name';
        AGrid.Cells[1,0] := 'Key Field';
        AGrid.Cells[2,0] := 'Path';
        iRow := 0;
        for iCount := 0 to (MainForm.MDIChildCount-1) do
            if (sDestTbl <> TMDIChild(MainForm.MDIChildren[iCount]).sFilename) then
            begin
                 Inc(iRow);
                 AGrid.Cells[0,iRow] := ExtractFileName( TMDIChild(MainForm.MDIChildren[iCount]).sFilename );
                 AGrid.Cells[1,iRow] := '';
                 AGrid.Cells[2,iRow] := TrimTrailingSlashes(ExtractFilePath( TMDIChild(MainForm.MDIChildren[iCount]).sFilename ));
            end;

        AutoFitGrid(AGrid,Canvas,True);

        //ClickSourceChild := TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(SourceTablesGrid.Cells[2,1] + '\' + SourceTablesGrid.Cells[0,1])]);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ListRemainingTables',mtError,[mbOk],0);
     end;
end;

procedure TBuildCPlanWizardForm.PrepareComboNameField;
var
   iCount : integer;
begin
     // list the fields for sDestinationTable in PrepareComboField
  {   ComboNameField.Items.Clear;
     ComboNameField.Text := ClickSourceChild.Query1.FieldDefs.Items[0].Name;
     for iCount := 0 to (ClickSourceChild.Query1.FieldDefs.Count - 1) do
     begin
          ComboNameField.Items.Add(ClickSourceChild.Query1.FieldDefs.Items[iCount].Name);
     end;
     LabelNameTable.Caption := 'Table   ' + SourceTablesGrid.Cells[0,SourceTablesGrid.Selection.Top];   }
end;

procedure TBuildCPlanWizardForm.btnNextClick(Sender: TObject);
begin
     short_form;
     sMatrixTable := AvailableTablesGrid.Cells[2,AvailableTablesGrid.Selection.Top] + '\' + AvailableTablesGrid.Cells[0,AvailableTablesGrid.Selection.Top];
     //MatrixChild := TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(sMatrixTable)]);

     ListRemainingTables;
     //EditOutputPath
     //EditDatabaseName
     EditOutputPath.Text := TrimTrailingSlashes(ExtractFilePath(sMatrixTable));
     EditDatabaseName.Text := 'CPlan';

     Notebook1.PageIndex := 1;
end;

procedure TBuildCPlanWizardForm.Button20Click(Sender: TObject);
begin
     Notebook1.PageIndex := 7;
end;

procedure TBuildCPlanWizardForm.Button25Click(Sender: TObject);
begin
     Notebook1.PageIndex := 9;
end;

procedure TBuildCPlanWizardForm.Button1Click(Sender: TObject);
begin
     Notebook1.PageIndex := 8;
end;

procedure TBuildCPlanWizardForm.Button26Click(Sender: TObject);
begin
     try
        BrowseDirForm := TBrowseDirForm.Create(Application);
        BrowseDirForm.DirectoryListBox1.Directory := EditOutputPath.Text;
        BrowseDirForm.Caption := 'Browse Output Path';
        if (BrowseDirForm.ShowModal = mrOk) then
           EditOutputPath.Text := BrowseDirForm.DirectoryListBox1.Directory;
        BrowseDirForm.Free;

     except
           MessageDlg('Exception in Browse Output Path',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TBuildCPlanWizardForm.AvailableTablesGridClick(Sender: TObject);
begin
     TableGridClick(AvailableTablesGrid,LabelAvailableTable,ComboBox1,ComboAvailableKey);
end;

procedure TBuildCPlanWizardForm.TableGridClick(AGrid : TStringGrid;
                                               ALabel : TLabel;
                                               ACombo : TComboBox;
                                               AKeyCombo : TComboBox);
var
   iCount : integer;
   ClickChild : TMDIChild;
begin
     // display the fields from the table that has been selected
     ClickChild := TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(AGrid.Cells[2,AGrid.Selection.Top] + '\' + AGrid.Cells[0,AGrid.Selection.Top])]);

     ALabel.Caption := 'Table   ' + AGrid.Cells[0,AGrid.Selection.Top];

     ACombo.Items.Clear;
     ACombo.Text := ClickChild.Query1.FieldDefs.Items[0].Name;
     AKeyCombo.Items.Clear;
     AKeyCombo.Text := ClickChild.Query1.FieldDefs.Items[0].Name;
     WipePreviousKey(AGrid);
     AGrid.Cells[1,AGrid.Selection.Top] := AKeyCombo.Text;
     for iCount := 0 to (ClickChild.Query1.FieldDefs.Count - 1) do
     begin
          ACombo.Items.Add(ClickChild.Query1.FieldDefs.Items[iCount].Name);
          AKeyCombo.Items.Add(ClickChild.Query1.FieldDefs.Items[iCount].Name);
     end;
end;

function rtnUniqueFileName(const sPath, sExt : string) : string;
var
   iCount : integer;
begin
     // return a unique pathX.ext filename
     iCount := 0;

     repeat
           Result := sPath + IntToStr(iCount) + '.' + sExt;

           Inc(iCount);

     until not FileExists(Result);
end;

procedure TBuildCPlanWizardForm.GenerateCPlanWizardParamFile;
var
   OutFile : TextFile;
begin
     assignfile(OutFile,rtnUniqueFileName(MainForm.sWorkingDirectory + '\wiz','cdw'));
     rewrite(OutFile);
     writeln(OutFile,'[Build C-Plan Database Wizard]');
     // write parameters to outfile
     
     closefile(OutFile);
end;

procedure TBuildCPlanWizardForm.BitBtn12Click(Sender: TObject);
begin
     LabelProgress.Caption := 'Importing C-Plan Matrix Data';
     Notebook1.PageIndex := 9;

     GenerateCPlanWizardParamFile;

     ImportCPlanMatrix;

     ImportCPlanFields;
end;

procedure TBuildCPlanWizardForm.PopulateI_STATUSField;
var
   sTENURE, sI_STATUS : string;
begin
     with ConvertModule.Table1 do
     try
        // EditOutputPath.Text + '\' + EditDatabaseName.Text + '_sites.dbf'
        // parse the file, read TENURE field and update I_STATUS field
        DatabaseName := TrimTrailingSlashes(EditOutputPath.Text);
        TableName := EditDatabaseName.Text + '_sites.dbf';
        Open;

        repeat
              sTENURE := FieldByName('TENURE').AsString;
              sI_STATUS := 'Initial Available';
              // see if this value is in the reserved class
              if (ResTenure.Items.IndexOf(sTENURE) > -1) then
                 sI_STATUS := 'Initial Reserve';
              // see if this value is in the ignored class
              if (IgnTenure.Items.IndexOf(sTENURE) > -1) then
                 sI_STATUS := 'Initial Excluded';

              Edit;
              FieldByName('I_STATUS').AsString := sI_STATUS;
              Post;
              Next;

        until Eof;

        Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in PopulateI_STATUSField',mtError,[mbOk],0);
     end;
end;
procedure TBuildCPlanWizardForm.ImportCPlanFields;
var
   sTable : string;
begin
     try
        // create the import into table wizard which we will use to import the C-Plan fields
        // into the site and feature tables
        ImportIntoTableForm := TImportIntoTableForm.Create(Application);
        // import site name
        if (LabelNameTable.Caption <> 'no table selected') then
        begin
             sTable := NameTablesGrid.Cells[2,NameTablesGrid.Selection.Top] + '\' +
                       NameTablesGrid.Cells[0,NameTablesGrid.Selection.Top];
             ImportIntoTableForm.ImportSingleFieldIntoTable(EditOutputPath.Text + '\' + EditDatabaseName.Text + '_sites.dbf',
                                                            'SITEKEY',
                                                            'NAME',
                                                            sTable,
                                                            ComboNameKey.Text,
                                                            ComboNameField.Text);
        end;
        // import site area
        if (LabelAreaTable.Caption <> 'no table selected') then
        begin
             sTable := AreaTablesGrid.Cells[2,AreaTablesGrid.Selection.Top] + '\' +
                       AreaTablesGrid.Cells[0,AreaTablesGrid.Selection.Top];
             ImportIntoTableForm.ImportSingleFieldIntoTable(EditOutputPath.Text + '\' + EditDatabaseName.Text + '_sites.dbf',
                                                            'SITEKEY',
                                                            'AREA',
                                                            sTable,
                                                            ComboAreaKey.Text,
                                                            ComboAreaField.Text);
        end;
        // import site tenure
        if (LabelTenureTable.Caption <> 'no table selected') then
        begin
             sTable := TenureTablesGrid.Cells[2,TenureTablesGrid.Selection.Top] + '\' +
                       TenureTablesGrid.Cells[0,TenureTablesGrid.Selection.Top];
             ImportIntoTableForm.ImportSingleFieldIntoTable(EditOutputPath.Text + '\' + EditDatabaseName.Text + '_sites.dbf',
                                                            'SITEKEY',
                                                            'TENURE',
                                                            sTable,
                                                            ComboTenureKey.Text,
                                                            ComboTenureField.Text);
             // parse the site tenure and populate the I_STATUS field
             PopulateI_STATUSField;
        end;
        // import feature target
        if (LabelTargetTable.Caption <> 'no table selected') then
        begin
             sTable := TargetTablesGrid.Cells[2,TargetTablesGrid.Selection.Top] + '\' +
                       TargetTablesGrid.Cells[0,TargetTablesGrid.Selection.Top];
             ImportIntoTableForm.ImportSingleFieldIntoTable(EditOutputPath.Text + '\' + EditDatabaseName.Text + '_features.dbf',
                                                            'FEATNAME',
                                                            'ITARGET',
                                                            sTable,
                                                            ComboTargetKey.Text,
                                                            ComboTargetField.Text);
        end;
        // import feature name
        if (LabelFeatureNameTable.Caption <> 'no table selected') then
        begin
             sTable := FeatureNameTablesGrid.Cells[2,FeatureNameTablesGrid.Selection.Top] + '\' +
                       FeatureNameTablesGrid.Cells[0,FeatureNameTablesGrid.Selection.Top];
             ImportIntoTableForm.ImportSingleFieldIntoTable(EditOutputPath.Text + '\' + EditDatabaseName.Text + '_features.dbf',
                                                            'FEATNAME',
                                                            'FEATNAME',
                                                            sTable,
                                                            ComboFeatureNameKey.Text,
                                                            ComboFeatureNameField.Text);
        end;

        ImportIntoTableForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ImportCPlanFields',mtError,[mbOk],0);
     end;
end;

procedure TBuildCPlanWizardForm.MakeMasterFeatureList;
var
   iCount, iFeatureCount, iFeature : integer;
   InChild : TMDIChild;
   sFEATNAME : str255;
begin
     try
        // traverse the 1 or more mtx input tables, reading feature name and keys from there

        // read field names from the first table
        InChild := TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(MatrixGrid.Cells[2,1] + '\' + MatrixGrid.Cells[0,1])]);
        MasterFeatureList := Array_t.Create;
        MasterFeatureList.init(SizeOf(str255),InChild.Query1.FieldCount-1);
        iFeature := 0;
        for iCount := 0 to (InChild.Query1.FieldDefs.Count-1) do
            if (InChild.Query1.FieldDefs.Items[iCount].Name <> MatrixGrid.Cells[1,1]) then
            begin
                 Inc(iFeature);
                 sFEATNAME := InChild.Query1.FieldDefs.Items[iCount].Name;
                 MasterFeatureList.setValue(iFeature,@sFEATNAME);
            end;

        if (MatrixGrid.RowCount > 2) then
        begin
             // read field names from 2nd and subsequent tables
             for iCount := 2 to (MatrixGrid.RowCount-1) do
             begin
                  InChild := TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(MatrixGrid.Cells[2,iCount] + '\' + MatrixGrid.Cells[0,iCount])]);
                  MasterFeatureList.resize(MasterFeatureList.lMaxSize + InChild.Query1.FieldCount - 1);
                  for iFeatureCount := 0 to (InChild.Query1.FieldDefs.Count-1) do
                      if (InChild.Query1.FieldDefs.Items[iFeatureCount].Name <> MatrixGrid.Cells[1,iCount]) then
                      begin
                           Inc(iFeature);
                           sFEATNAME := InChild.Query1.FieldDefs.Items[iFeatureCount].Name;
                           MasterFeatureList.setValue(iFeature,@sFEATNAME);
                      end;
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in MakeMasterFeatureList',mtError,[mbOk],0);
     end;
end;

function TBuildCPlanWizardForm.ConvertMatrices : boolean;
var
   iCount : integer;
begin
     try
        // for more than 1 input table, MatrixGrid contains the list of tables

        // convert the specified dbf table into a mtx & corresponding key file
        //     sMatrixTable : string;
        //     MatrixChild : TMDIChild;
        // ComboAvailableKey.Text is the name of the key field in this table
        // EditOutputPath.Text is output path
        // EditDatabaseName.Text is database name
        if (MatrixGrid.RowCount > 2) then
        begin
             // we have more than 1 table to add to the matrix
             for iCount := 1 to (MatrixGrid.RowCount-1) do
             begin
                  // call ConvertMatrixTable as many times as necessary
                  Result := ConvertMatrixTable(TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(MatrixGrid.Cells[2,iCount] + '\' + MatrixGrid.Cells[0,iCount])]),
                                               MatrixGrid.Cells[1,iCount],
                                               EditOutputPath.Text,
                                               IntToStr(iCount));
                  // parameters are (ASourceChild : TMDIChild;
                  //                 const sSourceKey,
                  //                       sOutputPath,
                  //                       sMatrixName : string)
                  // if fConvert is False, the conversion failed due to a type conflict
             end;

             // call ConvertModule.JoinMtxFiles(const sInKey1, sInMtx1, sInKey2, sInMtx2, sOutKey, sOutMtx : string)
             //   to successively stitch together these files if there is more than one
             ConvertModule.JoinMtxFiles(EditOutputPath.Text + '\1.key',EditOutputPath.Text + '\1.mtx',
                                        EditOutputPath.Text + '\2.key',EditOutputPath.Text + '\2.mtx',
                                        EditOutputPath.Text + '\tmp1.key',EditOutputPath.Text + '\tmp1.mtx');
             DeleteFile(EditOutputPath.Text + '\1.mtx');
             DeleteFile(EditOutputPath.Text + '\1.key');
             DeleteFile(EditOutputPath.Text + '\2.mtx');
             DeleteFile(EditOutputPath.Text + '\2.key');
             if (MatrixGrid.RowCount > 3) then
             begin
                  // there are 3 or more input tables
                  for iCount := 1 to (MatrixGrid.RowCount-3) do
                  begin
                       // join tmp i and iCount + 2 to tmp i+1
                       ConvertModule.JoinMtxFiles(EditOutputPath.Text + '\tmp' + IntToStr(iCount) + '.key',EditOutputPath.Text + '\tmp' + IntToStr(iCount) + '.mtx',
                                                  EditOutputPath.Text + '\' + IntToStr(iCount+2) + '.key',EditOutputPath.Text + '\' + IntToStr(iCount+2) + '.mtx',
                                                  EditOutputPath.Text + '\tmp' + IntToStr(iCount+1) + '.key',EditOutputPath.Text + '\tmp' + IntToStr(iCount+1) + '.mtx');
                       DeleteFile(EditOutputPath.Text + '\tmp' + IntToStr(iCount) + '.mtx');
                       DeleteFile(EditOutputPath.Text + '\tmp' + IntToStr(iCount) + '.key');
                       DeleteFile(EditOutputPath.Text + '\' + IntToStr(iCount+2) + '.mtx');
                       DeleteFile(EditOutputPath.Text + '\' + IntToStr(iCount+2) + '.key');
                  end;
                  renamefile(EditOutputPath.Text + '\tmp' + IntToStr(MatrixGrid.RowCount-2) + '.mtx',
                             EditOutputPath.Text + '\' + EditDatabaseName.Text + '_matrix.mtx');
                  renamefile(EditOutputPath.Text + '\tmp' + IntToStr(MatrixGrid.RowCount-2) + '.key',
                             EditOutputPath.Text + '\' + EditDatabaseName.Text + '_matrix.key');
             end
             else
             begin
                  renamefile(EditOutputPath.Text + '\tmp1.mtx',
                             EditOutputPath.Text + '\' + EditDatabaseName.Text + '_matrix.mtx');
                  renamefile(EditOutputPath.Text + '\tmp1.key',
                             EditOutputPath.Text + '\' + EditDatabaseName.Text + '_matrix.key');
             end;
        end
        else
        begin
             // there is only 1 table to add to the matrix
             Result := ConvertMatrixTable(TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(MatrixGrid.Cells[2,1] + '\' + MatrixGrid.Cells[0,1])]),
                                          MatrixGrid.Cells[1,1],
                                          EditOutputPath.Text,
                                          EditDatabaseName.Text + '_matrix');
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ConvertMatrices',mtError,[mbOk],0);
           Result := False;
     end;
end;

procedure TBuildCPlanWizardForm.ImportCPlanMatrix;
var
   fConvert : boolean;
begin
     try
        // convert the specified dbf table into a mtx & corresponding key file
        fConvert := ConvertMatrices;
        // create site table
        CreateSiteTable;

        MakeMasterFeatureList;
        // create feature table
        CreateFeatureTable;
        // create ini file
        CreateIniFile;

        MasterFeatureList.Destroy;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ImportCPlanMatrix',mtError,[mbOk],0);
     end;
end;

function TBuildCPlanWizardForm.CreateSiteTable : boolean;
var
   KeyFile : file;
   Key : KeyFile_T;
begin
     try
        // create site table
        // EditOutputPath.Text is output path
        // EditDatabaseName.Text is database name
        Result := True;
        with ConvertModule.Query1.Sql do
        begin
             Clear;
             Add('CREATE TABLE "' + EditOutputPath.Text + '\' + EditDatabaseName.Text + '_sites.dbf"');
             Add('(');
             Add('NAME CHAR(120),');        // 32
             Add('SITEKEY NUMERIC(12,0),');
             Add('STATUS CHAR(2),');
             Add('I_STATUS CHAR(17),');
             Add('TENURE CHAR(32),');
             Add('AREA NUMERIC(10,5),');
             Add('IRREPL NUMERIC(10,5),');
             Add('I_IRREPL NUMERIC(10,5),');
             Add('SUMIRR NUMERIC(10,5),');
             Add('I_SUMIRR NUMERIC(10,5),');
             Add('WAVIRR NUMERIC(10,5),');
             Add('I_WAVIRR NUMERIC(10,5),');
             Add('PCCONTR NUMERIC(10,5),');
             Add('I_PCCONTR NUMERIC(10,5),');
             Add('DISPLAY CHAR(3))');
        end;

        try
           ConvertModule.Query1.Prepare;
           ConvertModule.Query1.ExecSQL;
        except
              MessageDlg('Exception in CreateSiteTable executing SQL query',mtError,[mbOk],0);
              Result := False;
              Exit;
        end;

        // now populate the table
        // write the NAME, SITEKEY, AREA for each row in the matrix
        assignfile(KeyFile,EditOutputPath.Text + '\' + EditDatabaseName.Text + '_matrix.key');
        reset(KeyFile,1);
        //MatrixChild.DBGrid1.Visible := False;
        //MatrixChild.Query1.First;

        ConvertModule.Table1.DatabaseName := EditOutputPath.Text;
        ConvertModule.Table1.TableName := EditDatabaseName.Text + '_sites' + '.dbf';
        ConvertModule.Table1.Open;

        repeat
              BlockRead(KeyFile,Key,SizeOf(Key));

              ConvertModule.Table1.Append;

              ConvertModule.Table1.FieldByName('NAME').AsString := IntToStr(Key.iSiteKey);//MatrixChild.Query1.FieldByName(ComboAvailableKey.Text).AsString;
              ConvertModule.Table1.FieldByName('SITEKEY').AsString := IntToStr(Key.iSiteKey);//MatrixChild.Query1.FieldByName(ComboAvailableKey.Text).AsString;
              ConvertModule.Table1.FieldByName('AREA').AsFloat := 0;

              ConvertModule.Table1.Post;
              //MatrixChild.Query1.Next;

        until Eof(KeyFile);//MatrixChild.Query1.EOF;

        ConvertModule.Table1.Close;

        CloseFile(KeyFile);
        //MatrixChild.Query1.First;
        //MatrixChild.DBGrid1.Visible := True;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CreateSiteTable',mtError,[mbOk],0);
     end;
end;

function TBuildCPlanWizardForm.CreateFeatureTable : boolean;
var
   iCount : integer;
   sFEATNAME : str255;
begin
     try
        // create feature table
        // EditOutputPath.Text is output path
        // EditDatabaseName.Text is database name
        Result := True;
        with ConvertModule.Query1.Sql do
        begin
             Clear;
             Add('CREATE TABLE "' + EditOutputPath.Text + '\' + EditDatabaseName.Text + '_features.dbf"');
             Add('(');
             Add('FEATKEY NUMERIC(6,0),');
             Add('FEATNAME CHAR(254),');
             Add('ITARGET NUMERIC(12,2)');
             Add(')');
        end;

        try
           ConvertModule.Query1.Prepare;
           ConvertModule.Query1.ExecSQL;
        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in CreateFeatureTable executing SQL query',mtError,[mbOk],0);
              Result := False;
              Exit;
        end;

        // now populate the table
        // write FEATKEY, FEATNAME, ITARGET

        ConvertModule.Table1.DatabaseName := EditOutputPath.Text;
        ConvertModule.Table1.TableName := EditDatabaseName.Text + '_features' + '.dbf';
        ConvertModule.Table1.Open;

        for iCount := 1 to MasterFeatureList.lMaxSize do
        begin
             MasterFeatureList.rtnValue(iCount,@sFEATNAME);

             ConvertModule.Table1.Append;

             ConvertModule.Table1.FieldByName('FEATKEY').AsInteger := iCount;
             ConvertModule.Table1.FieldByName('FEATNAME').AsString := sFEATNAME;
             ConvertModule.Table1.FieldByName('ITARGET').AsFloat := 0;

             ConvertModule.Table1.Post;
        end;

        ConvertModule.Table1.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CreateFeatureTable',mtError,[mbOk],0);
     end;
end;

procedure TBuildCPlanWizardForm.CreateIniFile;
var
   AIniFile : TIniFile;
   sSection : string;
begin
     try
        // create ini file
        // EditOutputPath.Text is output path
        // EditDatabaseName.Text is database name
        AIniFile := TIniFile.Create(EditOutputPath.Text + '\cplan.ini');

        AIniFile.WriteString('Database1','Name',EditDatabaseName.Text);
        AIniFile.WriteInteger('Database1','PCCONTRCutOff',PCContrCutOff.Value);
        AIniFile.WriteInteger('Database1','MatrixSize',MasterFeatureList.lMaxSize);
        AIniFile.WriteString('Database1','FeatureSummaryTable',EditDatabaseName.Text + '_features.dbf');

        AIniFile.WriteString('Options','SparseMatrix',EditDatabaseName.Text + '_matrix.mtx');
        AIniFile.WriteString('Options','SparseKey',EditDatabaseName.Text + '_matrix.key');


        // add a default 'Resource' section
        AIniFile.WriteString('Resource',';AREA','');

        AIniFile.WriteString('Display Fields','NAME','');
        AIniFile.WriteString('Display Fields','STATUS','');
        AIniFile.WriteString('Display Fields','SITEKEY','');
        AIniFile.WriteString('Display Fields','PCUSED','');
        AIniFile.WriteString('Display Fields','IRREPL','');
        AIniFile.WriteString('Display Fields','TENURE','');

        AIniFile.WriteString('Options','SiteSummaryTable',EditDatabaseName.Text + '_sites.dbf');
        AIniFile.WriteString('Options','Key','SITEKEY');
        AIniFile.WriteString('Options','LinkToGIS','ArcView');

        AIniFile.WriteString('Sumirr Weightings','Area','0');
        AIniFile.WriteString('Sumirr Weightings','Target','0');
        AIniFile.WriteString('Sumirr Weightings','Vulnerability','0');
        AIniFile.WriteString('Sumirr Weightings','Minimum Weight','0.2');
        AIniFile.WriteString('Sumirr Weightings','CalculateAllVariations','1');

        AIniFile.WriteString('Sumirr Vulnerability Weightings','1','1');
        AIniFile.WriteString('Sumirr Vulnerability Weightings','2','0.8');
        AIniFile.WriteString('Sumirr Vulnerability Weightings','3','0.6');
        AIniFile.WriteString('Sumirr Vulnerability Weightings','4','0.4');
        AIniFile.WriteString('Sumirr Vulnerability Weightings','5','0.2');

        {add CRA Feature Report specifications to INI file}
        sSection := 'Feature Report % Targets Met';
        AIniFile.WriteString(sSection,'NAME','Feature Name');
        AIniFile.WriteString(sSection,'KEY','Feature Key');
        AIniFile.WriteString(sSection,'INUSE','Feature In Use');
        AIniFile.WriteString(sSection,'ITARGET','Original Tgt.');
        AIniFile.WriteString(sSection,'TRIMMEDITARG','Initial Achievable Tgt.');
        AIniFile.WriteString(sSection,'ORIGEFFTARG','Initial Available Tgt.');
        AIniFile.WriteString(sSection,'%ITARGMET','% Original Tgt. Met');
        AIniFile.WriteString(sSection,'%TRIMITMET','% Initial Achievable Tgt. Met');
        AIniFile.WriteString(sSection,'%OETMET','% Initial Available Tgt. Met');
        AIniFile.WriteString(sSection,'CURREFFTARG','Current Available Tgt.');
        AIniFile.WriteString(sSection,'PROPOSEDRES','Reserved in C-Plan');
        AIniFile.WriteString(sSection,'EXCLUDED','Excluded in C-Plan');
        AIniFile.WriteString(sSection,'CURRAVAIL','Available in C-Plan');

        AIniFile.WriteString('Feature Reports','% Targets Met','% Targets Met');

        {add Site Report Specifications to INI file}
        sSection := 'Site Report Subset Irr';
        AIniFile.WriteString(sSection,'NAME','Site Name');
        AIniFile.WriteString(sSection,'KEY','Site Key');
        AIniFile.WriteString(sSection,'STATUS','Status');
        AIniFile.WriteString(sSection,'IRR1','Site Irr Subset 1');
        AIniFile.WriteString(sSection,'SUM1','Summed Irr Subset 1');
        AIniFile.WriteString(sSection,'IRR2','Site Irr Subset 2');
        AIniFile.WriteString(sSection,'SUM2','Summed Irr Subset 2');
        AIniFile.WriteString(sSection,'IRR3','Site Irr Subset 3');
        AIniFile.WriteString(sSection,'SUM3','Summed Irr Subset 3');
        AIniFile.WriteString(sSection,'IRR4','Site Irr Subset 4');
        AIniFile.WriteString(sSection,'SUM4','Summed Irr Subset 4');
        AIniFile.WriteString(sSection,'IRR5','Site Irr Subset 5');
        AIniFile.WriteString(sSection,'SUM5','Summed Irr Subset 5');
        AIniFile.WriteString(sSection,'IRR6','Site Irr Subset 6');
        AIniFile.WriteString(sSection,'SUM6','Summed Irr Subset 6');
        AIniFile.WriteString(sSection,'IRR7','Site Irr Subset 7');
        AIniFile.WriteString(sSection,'SUM7','Summed Irr Subset 7');
        AIniFile.WriteString(sSection,'IRR8','Site Irr Subset 8');
        AIniFile.WriteString(sSection,'SUM8','Summed Irr Subset 8');
        AIniFile.WriteString(sSection,'IRR9','Site Irr Subset 9');
        AIniFile.WriteString(sSection,'SUM9','Summed Irr Subset 9');
        AIniFile.WriteString(sSection,'IRR10','Site Irr Subset 10');
        AIniFile.WriteString(sSection,'SUM10','Summed Irr Subset 10');

        AIniFile.WriteString('Site Reports','Subset Irr','Subset Irr');

        if (LabelTenureTable.Caption <> 'no table selected') then
        begin
             // write the users selected tenure classes to the ini file
             //AIniFile.WriteString
        end;

        AIniFile.Free;

        // EditOutputPath.Text is output path
        // EditDatabaseName.Text is database name
        AIniFile := TIniFile.Create('cplandb.ini');

        AIniFile.WriteString('Databases',EditDatabaseName.Text,EditOutputPath.Text);

        AIniFile.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CreateIniFile',mtError,[mbOk],0);
     end;
end;

function TBuildCPlanWizardForm.ConvertMatrixTable(ASourceChild : TMDIChild;
                                                  const sSourceKey, sOutputPath, sMatrixName : string) : boolean;
var
   OutputValue,OutputKey : file;
   Key : KeyFile_T;
   Value : SingleValueFile_T;
   iCount, iFeatureKey : integer;
begin
     try
        // for more than 1 input table, MatrixGrid contains the list of tables

        // convert the specified dbf table into a mtx & corresponding key file
        //     sMatrixTable : string;
        //     MatrixChild : TMDIChild;
        // ComboAvailableKey.Text is the name of the key field in this table
        // EditOutputPath.Text is output path
        // EditDatabaseName.Text is database name

        // assumptions : key field must be an integer
        //               all other fields must be numbers
        // Maybe manage this by only listing as available tables in the wizard tables that contain
        // only number fields.
        // NOTE : user can restrict other fields from the table by not choosing them
        //        when opening the file in the database tool
        Result := True;
        assignfile(OutputValue,sOutputPath + '\' + sMatrixName + '.mtx');
        rewrite(OutputValue,1);
        assignfile(OutputKey,sOutputPath + '\' + sMatrixName + '.key');
        rewrite(OutputKey,1);
        // process each row of the table
        ASourceChild.DBGrid1.Visible := False;
        ASourceChild.Query1.First;

        repeat
              // count the number of non zero fields for this row (not including key field)
              // write each non zero entry as a row to the ZZZ file
              // write the site key and richness to the YYY file
              try
                 Key.iSiteKey := ASourceChild.Query1.FieldByName(sSourceKey).AsInteger;
              except
                    Screen.Cursor := crDefault;
                    MessageDlg('Exception in ConvertMatrixTable, key field is not integer',mtError,[mbOk],0);
                    Result := False;
                    Exit;
              end;
              Key.iRichness := 0;
              iFeatureKey := 0;
              for iCount := 0 to (ASourceChild.Query1.FieldDefs.Count-1) do
              // for each field in the Matrix table
                  if (ASourceChild.Query1.FieldDefs.Items[iCount].Name <> sSourceKey) then
                  // if the field is not the tables key field
                  begin
                       Inc(iFeatureKey);
                       // iFeatureKey is a 1-based index of features

                       // read this cell and see if it is zero, no value means the same as zero
                       if not ASourceChild.Query1.FieldByName(ASourceChild.Query1.FieldDefs.Items[iCount].Name).IsNull then
                       begin
                            try
                               Value.rAmount := ASourceChild.Query1.FieldByName(ASourceChild.Query1.FieldDefs.Items[iCount].Name).AsFloat;
                            except
                                  Screen.Cursor := crDefault;
                                  MessageDlg('Exception in ConvertMatrixTable, ' +
                                             ASourceChild.Query1.FieldDefs.Items[iCount].Name +
                                             ' field is not integer',
                                             mtError,[mbOk],0);
                                  Result := False;
                                  Exit;
                            end;

                            if (Value.rAmount > 0) then
                            begin
                                 Inc(Key.iRichness);
                                 Value.iFeatKey := iFeatureKey;
                                 // write a row to the value file
                                 BlockWrite(OutputValue,Value,SizeOf(Value));
                            end;
                       end;
                  end;

              // write a row to the key file
              BlockWrite(OutputKey,Key,SizeOf(Key));
              ASourceChild.Query1.Next;

        until ASourceChild.Query1.EOF;

        ASourceChild.Query1.First;
        ASourceChild.DBGrid1.Visible := True;

        closefile(OutputValue);
        closefile(OutputKey);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ConvertMatrixTable',mtError,[mbOk],0);
     end;
end;

procedure TBuildCPlanWizardForm.Button32Click(Sender: TObject);
begin
     tall_form;
     Notebook1.PageIndex := 0;
end;

procedure TBuildCPlanWizardForm.Button31Click(Sender: TObject);
begin
     Notebook1.PageIndex := 2;
end;

procedure TBuildCPlanWizardForm.Button29Click(Sender: TObject);
begin
     Notebook1.PageIndex := 1;
end;

procedure TBuildCPlanWizardForm.Button30Click(Sender: TObject);
begin
     Notebook1.PageIndex := 3;
end;

procedure TBuildCPlanWizardForm.Button11Click(Sender: TObject);
begin
     Notebook1.PageIndex := 2;
end;

procedure TBuildCPlanWizardForm.Button2Click(Sender: TObject);
begin
     Notebook1.PageIndex := 4;
end;

procedure TBuildCPlanWizardForm.Button13Click(Sender: TObject);
begin
     Notebook1.PageIndex := 3;
end;

procedure TBuildCPlanWizardForm.Button14Click(Sender: TObject);

   procedure LoadTenureClasses;
   var
      iChildId : integer;
      TenureChild : TMDIChild;
      sTenureField, sTenureTable, sTenureValue : string;
      iTenureField, iTenureTable, iCount : integer;
   begin
        {we need to prepare the page by loading tenure classes
         to the OrigTenure box}
        if ((AvailTenure.Items.Count = 0)
            and (ResTenure.Items.Count = 0)
            and (IgnTenure.Items.Count = 0)) then {check we have not already specified tenure classes}
        begin
             OrigTenure.Items.Clear;
             AvailTenure.Items.Clear;
             ResTenure.Items.Clear;
             IgnTenure.Items.Clear;

             sTenureField := ComboTenureField.Text;

             sTenureTable := TenureTablesGrid.Cells[2,TenureTablesGrid.Selection.Top] + '\' +
                             TenureTablesGrid.Cells[0,TenureTablesGrid.Selection.Top];
             iTenureTable := MainForm.ReturnChildIndex(sTenureTable);
             TenureChild := TMDIChild(MainForm.MDIChildren[iTenureTable]);

             {write all unique tenure entries to the OrigTenure box}
             // parse the tenure field of the query, writing all unique values to OrigTenure
             TenureChild.DBGrid1.Visible := False;
             TenureChild.Query1.First;
             repeat
                   sTenureValue := TenureChild.Query1.FieldByName(sTenureField).AsString;
                   if (OrigTenure.Items.IndexOf(sTenureValue) < 0) then
                      OrigTenure.Items.Add(sTenureValue);

                   TenureChild.Query1.Next;
             until TenureChild.Query1.Eof;
             TenureChild.Query1.First;
             TenureChild.DBGrid1.Visible := True;
        end;
   end;

begin
     if (LabelTenureTable.Caption = 'no table selected') then
        Notebook1.PageIndex := 6
     else
     begin
          // there is a table selected
          // we must load its fields into the tenure classes select page
          LoadTenureClasses;
          Notebook1.PageIndex := 5;
     end;
end;

procedure TBuildCPlanWizardForm.Button15Click(Sender: TObject);
begin
     Notebook1.PageIndex := 4;
end;

procedure TBuildCPlanWizardForm.Button4Click(Sender: TObject);
begin
     Notebook1.PageIndex := 6;
end;

procedure TBuildCPlanWizardForm.Button21Click(Sender: TObject);
begin
     Notebook1.PageIndex := 6;
end;

procedure TBuildCPlanWizardForm.Button22Click(Sender: TObject);
begin
     Notebook1.PageIndex := 8;
end;

procedure MoveSelect(Source,Dest : TListbox);
var
   iCount : integer;
begin
     {move selected items from Source to Dest}
     try
        Screen.Cursor := crHourglass;
        {copy the items from 1st to last}
        if (Source.Items.Count > 0) then
        begin
             for iCount := 0 to (Source.Items.Count - 1) do
                 if Source.Selected[iCount] then
                    Dest.Items.Add(Source.Items.Strings[iCount]);

             {delete the source items from last to 1st}
             iCount := Source.Items.Count - 1;
             repeat
                   if Source.Selected[iCount] then
                      Source.Items.Delete(iCount);

                   Dec(iCount);

             until (iCount < 0);
        end;

        if (BuildCPlanWizardForm.OrigTenure.Items.Count = 0) then
           // enable next button if tenure classes are selected
           BuildCPlanWizardForm.Button4.Enabled := True
        else
            BuildCPlanWizardForm.Button4.Enabled := False;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception moving selected items',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TBuildCPlanWizardForm.SpeedButton2Click(Sender: TObject);
begin
     {move selected items from OrigTenure to AvailTenure}
     MoveSelect(OrigTenure,AvailTenure);
end;

procedure TBuildCPlanWizardForm.SpeedButton4Click(Sender: TObject);
begin
     MoveSelect(AvailTenure,OrigTenure);
end;

procedure TBuildCPlanWizardForm.SpeedButton1Click(Sender: TObject);
begin
     MoveSelect(OrigTenure,ResTenure);
end;

procedure TBuildCPlanWizardForm.SpeedButton3Click(Sender: TObject);
begin
     MoveSelect(ResTenure,OrigTenure);
end;

procedure TBuildCPlanWizardForm.SelHighlightTblClick(Sender: TObject);
begin
     MoveSelect(OrigTenure,IgnTenure);
end;

procedure TBuildCPlanWizardForm.UnSelHighlightTblClick(Sender: TObject);
begin
     MoveSelect(IgnTenure,OrigTenure);
end;

procedure TBuildCPlanWizardForm.NameTablesGridClick(Sender: TObject);
begin
     TableGridClick(NameTablesGrid,LabelNameTable,ComboNameField,ComboNameKey);
end;

procedure TBuildCPlanWizardForm.AreaTablesGridClick(Sender: TObject);
begin
     TableGridClick(AreaTablesGrid,LabelAreaTable,ComboAreaField,ComboAreaKey);
end;

procedure TBuildCPlanWizardForm.TenureTablesGridClick(Sender: TObject);
begin
     TableGridClick(TenureTablesGrid,LabelTenureTable,ComboTenureField,ComboTenureKey);
end;

procedure TBuildCPlanWizardForm.TargetTablesGridClick(Sender: TObject);
begin
     TableGridClick(TargetTablesGrid,LabelTargetTable,ComboTargetField,ComboTargetKey);
end;

procedure TBuildCPlanWizardForm.btnCancelTableClick(Sender: TObject);
begin
     LabelNameTable.Caption := 'no table selected';
     ComboNameField.Items.Clear;
     ComboNameField.Text := '';
     ComboNameKey.Items.Clear;
     ComboNameKey.Text := '';
end;

procedure TBuildCPlanWizardForm.Button3Click(Sender: TObject);
begin
     LabelAreaTable.Caption := 'no table selected';
     ComboAreaField.Items.Clear;
     ComboAreaField.Text := '';
     ComboAreaKey.Items.Clear;
     ComboAreaKey.Text := '';
end;

procedure TBuildCPlanWizardForm.Button5Click(Sender: TObject);
begin
     LabelTenureTable.Caption := 'no table selected';
     ComboTenureField.Items.Clear;
     ComboTenureField.Text := '';
     ComboTenureKey.Items.Clear;
     ComboTenureKey.Text := '';
end;

procedure TBuildCPlanWizardForm.Button6Click(Sender: TObject);
begin
     LabelTargetTable.Caption := 'no table selected';
     ComboTargetField.Items.Clear;
     ComboTargetField.Text := '';
     ComboTargetKey.Items.Clear;
     ComboTargetKey.Text := '';
end;

procedure TBuildCPlanWizardForm.ComboAvailableKeyChange(Sender: TObject);
begin
     WipePreviousKey(AvailableTablesGrid);
     AvailableTablesGrid.Cells[1,AvailableTablesGrid.Selection.Top] := ComboAvailableKey.Text;
     AutoFitGrid(AvailableTablesGrid,Canvas,True);
end;

procedure TBuildCPlanWizardForm.ComboNameKeyChange(Sender: TObject);
begin
     WipePreviousKey(NameTablesGrid);
     NameTablesGrid.Cells[1,NameTablesGrid.Selection.Top] := ComboNameKey.Text;
     AutoFitGrid(NameTablesGrid,Canvas,True);
end;

procedure TBuildCPlanWizardForm.ComboAreaKeyChange(Sender: TObject);
begin
     WipePreviousKey(AreaTablesGrid);
     AreaTablesGrid.Cells[1,AreaTablesGrid.Selection.Top] := ComboAreaKey.Text;
     AutoFitGrid(AreaTablesGrid,Canvas,True);
end;

procedure TBuildCPlanWizardForm.ComboTenureKeyChange(Sender: TObject);
begin
     WipePreviousKey(TenureTablesGrid);
     TenureTablesGrid.Cells[1,TenureTablesGrid.Selection.Top] := ComboTenureKey.Text;
     AutoFitGrid(TenureTablesGrid,Canvas,True);
end;

procedure TBuildCPlanWizardForm.ComboTargetKeyChange(Sender: TObject);
begin
     WipePreviousKey(TargetTablesGrid);
     TargetTablesGrid.Cells[1,TargetTablesGrid.Selection.Top] := ComboTargetKey.Text;
     AutoFitGrid(TargetTablesGrid,Canvas,True);
end;

procedure TBuildCPlanWizardForm.AddTableToMatrix;

   procedure AddARow(const sTbl,sKey,sPath : string);
   begin
        //
        if (MatrixGrid.RowCount = 2) then
        begin
             if (MatrixGrid.Cells[0,1] <> '') then
                MatrixGrid.RowCount := MatrixGrid.RowCount + 1;
        end
        else
            MatrixGrid.RowCount := MatrixGrid.RowCount + 1;
        MatrixGrid.Cells[0,MatrixGrid.RowCount-1] := sTbl;
        MatrixGrid.Cells[1,MatrixGrid.RowCount-1] := sKey;
        MatrixGrid.Cells[2,MatrixGrid.RowCount-1] := sPath;
   end;

begin
     // add fields
     //   table name       'Table Name'
     //   table key field  'Key Field'
     //   table path       'Path'
     AddARow(AvailableTablesGrid.Cells[0,AvailableTablesGrid.Selection.Top],
             AvailableTablesGrid.Cells[1,AvailableTablesGrid.Selection.Top],
             AvailableTablesGrid.Cells[2,AvailableTablesGrid.Selection.Top]);
     btnNext.Enabled := True;
     AutoFitGrid(MatrixGrid,Canvas,True);
end;

procedure TBuildCPlanWizardForm.btnAddTableToMatrixClick(Sender: TObject);
begin
     AddTableToMatrix;
end;

procedure TBuildCPlanWizardForm.btnRemoveTableClick(Sender: TObject);
var
   iTop, iBottom, iCount : integer;

   procedure DeleteARow(iRow : integer);
   var  // iRow is the zero based of the row to be removed
      iRowCount : integer;
   begin
        // blank the row
        MatrixGrid.Cells[0,iRow] := '';
        MatrixGrid.Cells[1,iRow] := '';
        MatrixGrid.Cells[2,iRow] := '';
        // copy rows up if necessary
        if (MatrixGrid.RowCount > (iRow + 1)) then
           for iRowCount := (iRow + 1) to (MatrixGrid.RowCount-1) do
           begin
                MatrixGrid.Cells[0,iRowCount-1] := MatrixGrid.Cells[0,iRowCount];
                MatrixGrid.Cells[1,iRowCount-1] := MatrixGrid.Cells[1,iRowCount];
                MatrixGrid.Cells[2,iRowCount-1] := MatrixGrid.Cells[2,iRowCount];
           end;
        // delete a row from the grid if necessary
        if (MatrixGrid.RowCount > 2) then
           MatrixGrid.RowCount := MatrixGrid.RowCount - 1;
   end;

begin
     // remove selected tables from the MatrixGrid
     iTop := MatrixGrid.Selection.Top;
     iBottom := MatrixGrid.Selection.Bottom;

     for iCount := iBottom to iTop do
         DeleteARow(iCount);

     // detect if there are any tables left in the grid
     if (MatrixGrid.RowCount = 2) then
        if (MatrixGrid.Cells[0,1] = '') then
           btnNext.Enabled := False;

     AutoFitGrid(MatrixGrid,Canvas,True);
end;


procedure TBuildCPlanWizardForm.Button9Click(Sender: TObject);
begin
     if (LabelTenureTable.Caption = 'no table selected') then
        Notebook1.PageIndex := 4
     else
     begin
          Notebook1.PageIndex := 5;
     end;
end;

procedure TBuildCPlanWizardForm.Button10Click(Sender: TObject);
begin
     Notebook1.PageIndex := 7;
end;

procedure TBuildCPlanWizardForm.Button7Click(Sender: TObject);
begin
     LabelFeatureNameTable.Caption := 'no table selected';
     ComboFeatureNameField.Items.Clear;
     ComboFeatureNameField.Text := '';
     ComboFeatureNameKey.Items.Clear;
     ComboFeatureNameKey.Text := '';
end;

procedure TBuildCPlanWizardForm.ComboFeatureNameKeyChange(Sender: TObject);
begin
     WipePreviousKey(FeatureNameTablesGrid);
     FeatureNameTablesGrid.Cells[1,FeatureNameTablesGrid.Selection.Top] := ComboFeatureNameKey.Text;
     AutoFitGrid(FeatureNameTablesGrid,Canvas,True);
end;

procedure TBuildCPlanWizardForm.FeatureNameTablesGridClick(
  Sender: TObject);
begin
     TableGridClick(FeatureNameTablesGrid,LabelFeatureNameTable,ComboFeatureNameField,ComboFeatureNameKey);
end;

end.

