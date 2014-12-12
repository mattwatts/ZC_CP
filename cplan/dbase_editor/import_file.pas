unit import_file;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TImportFileForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    EditImportFile: TEdit;
    EditNewTable: TEdit;
    btnBrowse: TButton;
    CheckUseDefaultNames: TCheckBox;
    ImportDialog: TOpenDialog;
    Label3: TLabel;
    btnSetWorkingDirectory: TButton;
    lblWorkDir: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure btnSetWorkingDirectoryClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckUseDefaultNamesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ImportFileForm: TImportFileForm;

implementation

uses Main, converter;

{$R *.DFM}



procedure TImportFileForm.BitBtn1Click(Sender: TObject);
begin
     if fileexists(EditImportFile.Text) then
        MainForm.CreateMDIChild(EditImportFile.Text,
                                MainForm.sWorkingDirectory + '\' + EditNewTable.Text,
                                False);
end;

procedure TImportFileForm.btnBrowseClick(Sender: TObject);
begin
     if ImportDialog.Execute then
     begin
          EditImportFile.Text := ImportDialog.Filename;
          EditNewTable.Text := ExtractFileName(MainForm.rtnUniqueDbfName(TrimTrailingSlashes(ExtractFilePath(ImportDialog.Filename)),
                                                                         ExtractFileName(ImportDialog.Filename)));
     end;
end;

procedure TImportFileForm.btnSetWorkingDirectoryClick(Sender: TObject);
begin
     MainForm.SetWorkingDirectory1Click(Sender);
     lblWorkDir.Caption := MainForm.sWorkingDirectory;
end;

procedure TImportFileForm.FormCreate(Sender: TObject);
begin
     lblWorkDir.Caption := MainForm.sWorkingDirectory;
end;

procedure TImportFileForm.CheckUseDefaultNamesClick(Sender: TObject);
begin
     MainForm.fUseDefaultImportNames := CheckUseDefaultNames.Checked;
end;

end.
