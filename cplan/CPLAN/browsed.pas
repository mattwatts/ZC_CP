unit browsed;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, FileCtrl, StdCtrls;

type
  TBrowseDirForm = class(TForm)
    Label1: TLabel;
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    SpeedButton1: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BrowseDirForm: TBrowseDirForm;

implementation

uses {Editstr,} edits;

{$R *.DFM}

procedure TBrowseDirForm.FormCreate(Sender: TObject);
begin
     ClientWidth := SpeedButton1.Left +
                    SpeedButton1.Width +
                    DriveComboBox1.Left;
     ClientHeight := BitBtn1.Top +
                     BitBtn1.Height +
                     DriveComboBox1.Top;
end;

procedure TBrowseDirForm.SpeedButton1Click(Sender: TObject);
var
   sDir : string;
begin
     EnterStrForm := TEnterStrForm.Create(Application);
     if (EnterStrForm.ShowModal = mrOk) then
     begin  {user has clicked ok on the directory form}
          sDir := DirectoryListBox1.Directory + '\' + EnterStrForm.Edit1.Text;
          ForceDirectories(sDir);
          DirectoryListBox1.Directory := sDir;
     end;
     EnterStrForm.Free;
end;

end.
