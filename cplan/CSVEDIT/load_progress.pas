unit load_progress;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;

type
  TLoadProgressForm = class(TForm)
    ProgressBar1: TProgressBar;
    lblProgress: TLabel;
    procedure DisplayLabel(const sLabel : string);
    procedure UpdateGauge(const iValue : integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LoadProgressForm: TLoadProgressForm;

procedure InitProgressForm(const sCaption, sLabel : string);

implementation

{$R *.DFM}

procedure InitProgressForm(const sCaption, sLabel : string);
begin
     LoadProgressForm := TLoadProgressForm.Create(Application);

     LoadProgressForm.Caption := sCaption;
     LoadProgressForm.lblProgress.Caption := sLabel;

     LoadProgressForm.Show;
     LoadProgressForm.Update;
end;

procedure TLoadProgressForm.DisplayLabel(const sLabel : string);
begin
     lblProgress.Caption := sLabel;
     Update;
end;

procedure TLoadProgressForm.UpdateGauge(const iValue : integer);
begin
     if (iValue <= ProgressBar1.Max) then
          ProgressBar1.Position := iValue
     else
          ProgressBar1.Position := ProgressBar1.Max;
     Update;
end;

end.
