unit open_ZC_GIS;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Db, DBTables;

type
  TOpen_ZC_GIS_Form = class(TForm)
    Label1: TLabel;
    Edit_ZCP_Project: TEdit;
    Label2: TLabel;
    EditPUShapefile: TEdit;
    Label3: TLabel;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    btnBrowseProject: TButton;
    btnBrowsePUShapefile: TButton;
    ComboKeyField: TComboBox;
    OpenZCPProject: TOpenDialog;
    OpenPUShape: TOpenDialog;
    PUTable: TTable;
    procedure btnBrowseProjectClick(Sender: TObject);
    procedure btnBrowsePUShapefileClick(Sender: TObject);
    procedure ScanPUFields;
    procedure BitBtnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Open_ZC_GIS_Form: TOpen_ZC_GIS_Form;

implementation

uses
    Global, Control;

{$R *.DFM}

procedure TOpen_ZC_GIS_Form.btnBrowseProjectClick(Sender: TObject);
begin
     OpenZCPProject.InitialDir := ControlRes^.sDatabase;
     if OpenZCPProject.Execute then
        Edit_ZCP_Project.Text := OpenZCPProject.Filename;
end;

procedure TOpen_ZC_GIS_Form.btnBrowsePUShapefileClick(Sender: TObject);
begin
     OpenPUShape.InitialDir := ControlRes^.sDatabase;
     if OpenPUShape.Execute then
     begin
          EditPUShapefile.Text := OpenPUShape.Filename;
          ScanPUFields;
     end;
end;


procedure TOpen_ZC_GIS_Form.ScanPUFields;
var
   sTableName : string;
   iCount : integer;
begin
     if (EditPUShapefile.Text <> '') then
        if fileexists(EditPUShapefile.Text) then
        begin
             PUTable.DatabaseName := ExtractFilePath(EditPUShapefile.Text);
             sTableName := ExtractFileName(EditPUShapefile.Text);
             sTableName := Copy(sTableName,1,Length(sTableName)-4);
             PUTable.TableName := sTableName + '.dbf';

             PUTable.Open;

             ComboKeyField.Items.Clear;
             ComboKeyField.Text := '';
             for iCount := 0 to (PUTable.FieldCount - 1) do
                 ComboKeyField.Items.Add(PUTable.FieldDefs.Items[iCount].Name);
             ComboKeyField.Text := ComboKeyField.Items.Strings[0];
             
             PUTable.Close;
        end;
end;

procedure TOpen_ZC_GIS_Form.BitBtnOkClick(Sender: TObject);
var
   fAcceptLink : boolean;
begin
     fAcceptLink := False;

     if (EditPUShapefile.Text <> '') then
        if fileexists(EditPUShapefile.Text) then
           // accept user parameters and open link with Zonea Cogito
           fAcceptLink := True;

     if fAcceptLink then
        ModalResult := mrOk
     else
         ModalResult := mrCancel;
end;

end.
