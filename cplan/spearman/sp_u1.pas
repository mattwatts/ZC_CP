unit sp_u1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    EditFile: TEdit;
    Label2: TLabel;
    EditTests: TEdit;
    Button1: TButton;
    OpenSPFile: TOpenDialog;
    btnExecute: TButton;
    BitBtn1: TBitBtn;
    Label3: TLabel;
    EditOutput: TEdit;
    OutBox: TListBox;
    lblIteration: TLabel;
    CheckTies: TCheckBox;
    CheckRanks: TCheckBox;
    CheckOptRanks: TCheckBox;
    CheckOptTies: TCheckBox;
    btnBatchRuns: TButton;
    EditDebugOut: TEdit;
    Label4: TLabel;
    procedure btnExecuteClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure btnBatchRunsClick(Sender: TObject);
    procedure CheckRanksClick(Sender: TObject);
    procedure ClickDebug(const fVisible : boolean);
    procedure CheckTiesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  sDebugDirectory : string;

implementation

uses
    Spman, batch, FileCtrl;

{$R *.DFM}

procedure TForm1.btnExecuteClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;

        if CheckOptTies.Checked then
           sDebugDirectory := EditDebugOut.Text + '\optimise_ties'
        else
            sDebugDirectory := EditDebugOut.Text + '\old_ties';
        ForceDirectories(sDebugDirectory);

        Main_spman;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception encountered',mtError,[mbOk],0);
     end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
     OpenSPFile.InitialDir := ExtractFilePath(EditFile.Text);
     OpenSPFile.Filename := ExtractFileName(EditFile.Text);

     if OpenSPFile.Execute then
     begin
          EditFile.Text := OpenSPFile.Filename;
          EditOutput.Text := EditFile.Text +
                             '_output.txt';
     end;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
     Application.Terminate;
     Exit;
end;

procedure TForm1.btnBatchRunsClick(Sender: TObject);
begin
     sDebugDirectory := EditDebugOut.Text;
     ForceDirectories(sDebugDirectory);

     BatchForm := TBatchForm.Create(Application);
     BatchForm.ShowModal;
     BatchForm.Free;
end;

procedure TForm1.CheckRanksClick(Sender: TObject);
begin
     ClickDebug(CheckRanks.Checked or CheckTies.Checked);
end;

procedure TForm1.ClickDebug(const fVisible : boolean);
begin
     EditDebugOut.Visible := fVisible;
     Label4.Visible := fVisible;
end;

procedure TForm1.CheckTiesClick(Sender: TObject);
begin
     ClickDebug(CheckRanks.Checked or CheckTies.Checked);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     fArraysCreated := False;
end;

end.
