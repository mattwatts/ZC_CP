unit Colors;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Buttons;

type
  TColorForm = class(TForm)
    BarColor: TColorDialog;
    LowFeature: TShape;
    MidFeature: TShape;
    HighFeature: TShape;
    SelectedSites: TShape;
    MandatorySites: TShape;
    BitBtn1: TBitBtn;
    procedure LowFeatureMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MidFeatureMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HighFeatureMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SelectedSitesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MandatorySitesMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ColorForm: TColorForm;

implementation

{$R *.DFM}

procedure TColorForm.LowFeatureMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     BarColor.Color := LowFeature.Brush.Color;
     if BarColor.Execute then
        LowFeature.Brush.Color := BarColor.Color;
end;

procedure TColorForm.MidFeatureMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     BarColor.Color := MidFeature.Brush.Color;
     if BarColor.Execute then
        MidFeature.Brush.Color := BarColor.Color;
end;

procedure TColorForm.HighFeatureMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     BarColor.Color := HighFeature.Brush.Color;
     if BarColor.Execute then
        HighFeature.Brush.Color := BarColor.Color;
end;

procedure TColorForm.SelectedSitesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     BarColor.Color := SelectedSites.Brush.Color;
     if BarColor.Execute then
        SelectedSites.Brush.Color := BarColor.Color;
end;

procedure TColorForm.MandatorySitesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     BarColor.Color := MandatorySites.Brush.Color;
     if BarColor.Execute then
        MandatorySites.Brush.Color := BarColor.Color;
end;

end.
