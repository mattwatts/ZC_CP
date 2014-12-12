unit joinwizard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Gauges, StdCtrls, Spin, ExtCtrls, Grids, Buttons,
  Childwin;

type
  TJoinWizardForm = class(TForm)
    Notebook1: TNotebook;
    Label7: TLabel;
    LabelAvailableTable: TLabel;
    btnAddTableToMatrix: TSpeedButton;
    btnRemoveTable: TSpeedButton;
    btnNext: TButton;
    BitBtn1: TBitBtn;
    btnBrowse: TButton;
    AvailableTablesGrid: TStringGrid;
    ComboAvailableKey: TComboBox;
    Panel1: TPanel;
    Label1: TLabel;
    ComboBox1: TComboBox;
    MatrixGrid: TStringGrid;
    Label43: TLabel;
    LabelNameTable: TLabel;
    Label25: TLabel;
    Button31: TButton;
    BitBtn18: TBitBtn;
    ComboNameField: TComboBox;
    Button32: TButton;
    Button33: TButton;
    NameTablesGrid: TStringGrid;
    ComboNameKey: TComboBox;
    btnCancelTable: TButton;
    Panel2: TPanel;
    Label40: TLabel;
    LabelAreaTable: TLabel;
    Label2: TLabel;
    Label8: TLabel;
    Button2: TButton;
    BitBtn2: TBitBtn;
    Button11: TButton;
    ComboAreaField: TComboBox;
    Button34: TButton;
    AreaTablesGrid: TStringGrid;
    ComboAreaKey: TComboBox;
    Button3: TButton;
    Panel3: TPanel;
    Label3: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Button20: TButton;
    Button25: TButton;
    BitBtn15: TBitBtn;
    EditOutputPath: TEdit;
    EditTableName: TEdit;
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
    procedure tall_form;
    procedure short_form;
    procedure TableGridClick(AGrid : TStringGrid;
                             ALabel : TLabel;
                             ACombo : TComboBox;
                             AKeyCombo : TComboBox);
    function ListTableFields(const Child : TMDIChild) : string;
    procedure ListAvailableTables;
    procedure FormCreate(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure Button32Click(Sender: TObject);
    procedure Button31Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure Button25Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure AvailableTablesGridClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  JoinWizardForm: TJoinWizardForm;

implementation

uses Main, converter, importintotablewizard;

{$R *.DFM}

procedure TJoinWizardForm.tall_form;
begin
     Height := BitBtn1.Top + BitBtn1.Height + 20 + Panel1.Height;
     Width := BitBtn1.Left + BitBtn1.Width + 20;
end;

procedure TJoinWizardForm.short_form;
begin
     Height := BitBtn18.Top + BitBtn18.Height + 20 + Panel1.Height;
     Width := BitBtn18.Left + BitBtn18.Width + 20;
end;

procedure TJoinWizardForm.TableGridClick(AGrid : TStringGrid;
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

function TJoinWizardForm.ListTableFields(const Child : TMDIChild) : string;
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

procedure TJoinWizardForm.ListAvailableTables;
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

procedure TJoinWizardForm.FormCreate(Sender: TObject);
begin
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

procedure TJoinWizardForm.btnNextClick(Sender: TObject);
begin
     short_form;
     Notebook1.PageIndex := 1;
end;

procedure TJoinWizardForm.Button32Click(Sender: TObject);
begin
     tall_form;
     Notebook1.PageIndex := 0;
end;

procedure TJoinWizardForm.Button31Click(Sender: TObject);
begin
     Notebook1.PageIndex := 2;
end;

procedure TJoinWizardForm.Button11Click(Sender: TObject);
begin
     Notebook1.PageIndex := 1;
end;

procedure TJoinWizardForm.Button2Click(Sender: TObject);
begin
     Notebook1.PageIndex := 3;
end;

procedure TJoinWizardForm.Button20Click(Sender: TObject);
begin
     Notebook1.PageIndex := 2;
end;

procedure TJoinWizardForm.Button25Click(Sender: TObject);
begin
     Notebook1.PageIndex := 4;
end;

procedure TJoinWizardForm.Button1Click(Sender: TObject);
begin
     Notebook1.PageIndex := 3;
end;

procedure TJoinWizardForm.AvailableTablesGridClick(Sender: TObject);
begin
     TableGridClick(AvailableTablesGrid,LabelAvailableTable,ComboBox1,ComboAvailableKey);
end;

end.
