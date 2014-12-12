unit spatopt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Tabs, StdCtrls, Buttons, Spin;

type
  TSpatialOptionsForm = class(TForm)
    TabSet1: TTabSet;
    Notebook1: TNotebook;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Use1: TCheckBox;
    Use2: TCheckBox;
    Use3: TCheckBox;
    Use4: TCheckBox;
    Use5: TCheckBox;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Use6: TCheckBox;
    Use7: TCheckBox;
    Use8: TCheckBox;
    Use9: TCheckBox;
    Use10: TCheckBox;
    PatchCon1: TCheckBox;
    PatchCon2: TCheckBox;
    PatchCon3: TCheckBox;
    PatchCon4: TCheckBox;
    PatchCon5: TCheckBox;
    PatchCon6: TCheckBox;
    PatchCon7: TCheckBox;
    PatchCon8: TCheckBox;
    PatchCon9: TCheckBox;
    PatchCon10: TCheckBox;
    Label16: TLabel;
    Label17: TLabel;
    Button1: TButton;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Spread1: TCheckBox;
    Spread2: TCheckBox;
    Spread3: TCheckBox;
    Spread4: TCheckBox;
    Spread5: TCheckBox;
    Spread6: TCheckBox;
    Spread7: TCheckBox;
    Spread8: TCheckBox;
    Spread9: TCheckBox;
    Spread10: TCheckBox;
    Label30: TLabel;
    ComboBox1: TComboBox;
    SpatialIndexGroup: TRadioGroup;
    SumirrWeightingsGroup: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    GroupBox1: TGroupBox;
    SpinEdit1: TSpinEdit;
    Label31: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure TabSet1Click(Sender: TObject);
    procedure SpatialIndexGroupClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SpatialOptionsForm: TSpatialOptionsForm;

implementation

{$R *.DFM}

procedure TSpatialOptionsForm.FormCreate(Sender: TObject);
begin
     TabSet1.Tabs := Notebook1.Pages;
     Caption := TabSet1.Tabs[TabSet1.TabIndex] + ' Options';
end;

procedure TSpatialOptionsForm.TabSet1Click(Sender: TObject);
begin
     Notebook1.PageIndex := TabSet1.TabIndex;
     Caption := TabSet1.Tabs[TabSet1.TabIndex] + ' Options';
end;



procedure TSpatialOptionsForm.SpatialIndexGroupClick(Sender: TObject);
begin
     if (SpatialIndexGroup.ItemIndex = 1) then
        SumirrWeightingsGroup.Enabled := True
     else
         SumirrWeightingsGroup.Enabled := False;
end;


end.
