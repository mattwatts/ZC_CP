unit workdir;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls;

type
  TWorkingDirForm = class(TForm)
    Label1: TLabel;
    EditPath: TEdit;
    Button1: TButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WorkingDirForm: TWorkingDirForm;

implementation

uses browsed,
     filectrl;

{$R *.DFM}

procedure TWorkingDirForm.Button1Click(Sender: TObject);
begin
     try
        ForceDirectories(EditPath.Text);
        BrowseDirForm := TBrowseDirForm.Create(Application);
        BrowseDirForm.DirectoryListBox1.Directory := EditPath.Text;
        if (BrowseDirForm.ShowModal = mrOk) then
           EditPath.Text := BrowseDirForm.DirectoryListBox1.Directory;
        BrowseDirForm.Free;
        
     except
           MessageDlg('Exception in Browse working directory',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TWorkingDirForm.FormCreate(Sender: TObject);
begin
     ClientWidth := Button1.Left + Button1.Width + Label1.Left;
     ClientHeight := BitBtn1.Top + BitBtn1.Height + EditPath.Top;
end;

end.
