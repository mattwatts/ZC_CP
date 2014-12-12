unit pctarg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Spin;

type
  TPCTargForm = class(TForm)
    Label1: TLabel;
    SpinPC: TSpinEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    EditPC: TEdit;
    SpinButton1: TSpinButton;
    Button1: TButton;
    Label2: TLabel;
    EditMultiply: TEdit;
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpinButton1DownClick(Sender: TObject);
    procedure SpinButton1UpClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PCTargForm: TPCTargForm;

implementation

uses Control;

{$R *.DFM}

procedure TPCTargForm.BitBtn2Click(Sender: TObject);
begin
     ModalResult := mrCancel;
end;

procedure TPCTargForm.BitBtn1Click(Sender: TObject);
//var
//   rMultiply : extended;
begin
     //iPercentage := SpinPC.Value;
     //try
     //   rMultiply := RegionSafeStrToFloat(EditMultiply.Text);
     //except
     //      rMultiply := 1;
     //end;

     try
        rPercentage := RegionSafeStrToFloat(EditPC.Text) {* rMultiply};
        ControlForm.TargetPercent.Text := FloatToStr(rPercentage {/ rMultiply});
        ModalResult := mrOk;
     except
           EditPC.Text := FloatToStr(rPercentage {/ rMultiply});
     end;
end;

procedure TPCTargForm.FormCreate(Sender: TObject);
begin
     try
        // SpinP
        EditPC.Text := ControlForm.TargetPercent.Text;
     except
           // SpinPC.Value := rPercentage;
     end;
end;

procedure TPCTargForm.SpinButton1DownClick(Sender: TObject);
var
   rValue : extended;
begin
     // down click, decriment PC target
     try
        rValue := RegionSafeStrToFloat(EditPC.Text);
        rValue := rValue - 5;

     except
           rValue := rPercentage - 5;
     end;
     if (rValue < 0) then
        rValue := 0;
     EditPC.Text := FloatToStr(rValue);
end;

procedure TPCTargForm.SpinButton1UpClick(Sender: TObject);
var
   rValue : extended;
begin
     // up click, increment PC target
     try
        rValue := RegionSafeStrToFloat(EditPC.Text);
        rValue := rValue + 5;

     except
           rValue := rPercentage + 5;
     end;
     if (rValue > 100) then
        rValue := 100;
     EditPC.Text := FloatToStr(rValue);
end;

procedure TPCTargForm.Button1Click(Sender: TObject);
begin
     Visible := False;
     ControlForm.UseFeatCutOffs.Checked := True;
end;

end.
