unit select_tgt_field;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TSelectTargetFieldForm = class(TForm)
    Label5: TLabel;
    TgtField: TComboBox;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    EditMultiply: TEdit;
    Label2: TLabel;
    procedure TgtFieldChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SelectTargetFieldForm: TSelectTargetFieldForm;

implementation

uses Control;

{$R *.DFM}



procedure TSelectTargetFieldForm.TgtFieldChange(Sender: TObject);
begin
     ControlRes^.sFeatureTargetField := TgtField.Text;
end;

procedure TSelectTargetFieldForm.FormCreate(Sender: TObject);
begin
     // load available target fields so the user can select which one they want
     ControlForm.LoadTargetFields(TgtField.Items);
     TgtField.Text := ControlRes^.sFeatureTargetField;
end;


procedure TSelectTargetFieldForm.btnOkClick(Sender: TObject);
begin
     try
        ControlRes^.rTargetMultiplyFactor := StrToFloat(EditMultiply.Text);
     except
           ControlRes^.rTargetMultiplyFactor := 1;
           EditMultiply.Text := '1';
     end;
end;

end.
