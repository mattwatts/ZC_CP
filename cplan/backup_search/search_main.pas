unit search_main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TSearchForm = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    btnLocate: TButton;
    FileList: TListBox;
    Label2: TLabel;
    SearchEdit: TEdit;
    Label3: TLabel;
    btnExecute: TButton;
    BitBtn1: TBitBtn;
    Label4: TLabel;
    Label5: TLabel;
    lblUpdate: TLabel;
    CheckDisable: TCheckBox;
    lblSearchMatches: TLabel;
    procedure btnLocateClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SearchForm: TSearchForm;

implementation

uses search, scan;

{$R *.DFM}

procedure TSearchForm.btnLocateClick(Sender: TObject);
begin
     SelectFilesForm := TSelectFilesForm.Create(Application);
     if (SelectFilesForm.ShowModal = mrOk) then
        FileList.Items := SelectFilesForm.FileListBox1.Items;

     SelectFilesForm.Free;
end;

procedure TSearchForm.BitBtn1Click(Sender: TObject);
begin
     Application.Terminate;
end;

procedure TSearchForm.btnExecuteClick(Sender: TObject);
begin
     try
        if (SearchEdit.Text <> '')
        or (FileList.Items.Count = 0) then
        begin
             Screen.Cursor := crHourglass;

             ScanForm := TScanForm.Create(Application);
             ScanForm.lblCount.Caption := '';
             ScanForm.ScanResult.Items.Clear;
             ScanForm.ExecuteScan;

             Screen.Cursor := crDefault;

             ScanForm.ShowModal;
             ScanForm.Free;
        end
        else
            MessageDlg('Complete Steps 1 and 2 first.',mtInformation,[mbOk],0);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Execute Search, file(s) may be read only.',mtError,[mbOk],0);
     end;
end;

end.
