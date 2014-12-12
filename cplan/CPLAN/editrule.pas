unit editrule;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Spin;

type
  TEditRuleForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    OperatorGroup: TRadioGroup;
    VariableBox: TListBox;
    ValueBox: TComboBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CheckLoadValues: TCheckBox;
    CheckSortValues: TCheckBox;
    Label3: TLabel;
    SpinDistance: TSpinEdit;
    LabelAboutRule: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure VariableBoxClick(Sender: TObject);
    procedure OperatorGroupClick(Sender: TObject);
    procedure CheckLoadValuesClick(Sender: TObject);
    procedure CheckSortValuesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EditRuleForm: TEditRuleForm;

implementation

uses rules;

{$R *.DFM}

procedure TEditRuleForm.FormCreate(Sender: TObject);
begin
     VariableBox.Items := RulesForm.VariableBox.Items;

     fClicking := True;
     CheckLoadValues.Checked := RulesForm.checkLoadValues.Checked;
     CheckSortValues.Checked := RulesForm.CheckSortValues.Checked;
end;

procedure TEditRuleForm.VariableBoxClick(Sender: TObject);
begin
     fClicking := True;

     RulesForm.OperatorGroup.ItemIndex := OperatorGroup.ItemIndex;
     RulesForm.ValueBox.Text := ValueBox.Text;
     RulesForm.ValueBox.Items := ValueBox.Items;
     RulesForm.ValueBox.Enabled := ValueBox.Enabled;
     RulesForm.Label2.Enabled := Label2.Enabled;
     RulesForm.CheckLoadValues.Checked := CheckLoadValues.Checked;
     RulesForm.CheckSortValues.Checked := CheckSortValues.Checked;

     fClicking := False;

     RulesForm.VariableBox.ItemIndex := VariableBox.ItemIndex;
     RulesForm.VariableBoxClick(self);

     Label2.Enabled := RulesForm.Label2.Enabled;
     Label2.Caption := RulesForm.Label2.Caption;
     
     ValueBox.Items := RulesForm.ValueBox.Items;
     ValueBox.Text := RulesForm.ValueBox.Text;

     OperatorGroup.Visible := RulesForm.OperatorGroup.Visible;
     CheckLoadValues.Visible := RulesForm.OperatorGroup.Visible;
     CheckSortValues.Visible := RulesForm.OperatorGroup.Visible;
     ValueBox.Visible := RulesForm.OperatorGroup.Visible;
     Label2.Visible := RulesForm.OperatorGroup.Visible;

     Label3.Visible := RulesForm.SpinDistance.Visible;
     SpinDistance.Visible := RulesForm.SpinDistance.Visible;
end;

procedure TEditRuleForm.OperatorGroupClick(Sender: TObject);
begin
     VariableBoxClick(self);
end;

procedure TEditRuleForm.CheckLoadValuesClick(Sender: TObject);
begin
     VariableBoxClick(self);
end;

procedure TEditRuleForm.CheckSortValuesClick(Sender: TObject);
begin
     VariableBoxClick(self);
end;

end.
