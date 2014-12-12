unit progress_form;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Buttons;

type
  TProgressForm = class(TForm)
    BitBtnCancel: TBitBtn;
    ProgressBarMarxan: TProgressBar;
    ProgressBarCalibration: TProgressBar;
    LabelMarxan: TLabel;
    LabelCalibration: TLabel;
    procedure UpdateMarxanRun(iUpdateRun : integer);
    procedure BitBtnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ProgressForm: TProgressForm;

implementation

{$R *.DFM}

procedure TProgressForm.UpdateMarxanRun(iUpdateRun : integer);
begin
     //
     ProgressBarMarxan.Visible := True;
     ProgressBarMarxan.Position := iUpdateRun;
end;

procedure TProgressForm.BitBtnCancelClick(Sender: TObject);
begin
     BitBtnCancel.Enabled := False;
end;

end.
