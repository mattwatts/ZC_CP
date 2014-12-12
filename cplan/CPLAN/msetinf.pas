unit msetinf;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TMinsetUserForm = class(TForm)
    btnStepMinset: TButton;
    MinsetTimer: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblIteration: TLabel;
    lblRule: TLabel;
    lblSitesSelected: TLabel;
    Label7: TLabel;
    lblTotalSitesSelected: TLabel;
    lblMinset: TLabel;
    lblMinset2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lblRemSel: TLabel;
    lblRed: TLabel;
    btnPause: TButton;
    procedure btnStepMinsetClick(Sender: TObject);
    procedure MinsetTimerTimer(Sender: TObject);
    procedure UpdateMinsetLabel;
    procedure UpdateRedundancyLabel;
    procedure btnPauseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MinsetUserForm: TMinsetUserForm;
  iActiveMinset : integer;

implementation

uses
    mthread, rules, Control,
    RedundancyCheck;

{$R *.DFM}

procedure TMinsetUserForm.UpdateMinsetLabel;
begin
     //
     lblMinset2.Visible := True;
     lblMinset.Visible := True;
     lblMinset.Caption := IntToStr(iActiveMinset) + ' of ' + IntToStr(iNumberOfMinsets);
end;

procedure TMinsetUserForm.btnStepMinsetClick(Sender: TObject);
begin
     fStopExecutingMinset := True;
     Caption := 'Minset is stopping';
     Update;
end;

procedure TMinsetUserForm.MinsetTimerTimer(Sender: TObject);
begin
     //Application.ProcessMessages;
end;

procedure TMinsetUserForm.UpdateRedundancyLabel;
begin // update redundancy check labels

      Label4.Visible := True;
      Label5.Visible := True;
      lblRemSel.Visible := True;
      lblRed.Visible := True;
      lblRemSel.Caption := IntToStr(ControlForm.R1.Items.Count +
                                    ControlForm.R2.Items.Count +
                                    ControlForm.R3.Items.Count +
                                    ControlForm.R4.Items.Count +
                                    ControlForm.R5.Items.Count);
      lblRed.Caption := IntToStr(iRedundantSites);
end;


procedure TMinsetUserForm.btnPauseClick(Sender: TObject);
begin
     //fPauseMinset := True;
     Caption := 'Minset is pausing';
     Update;
end;

end.
