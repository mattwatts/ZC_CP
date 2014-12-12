unit validation_parameters;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TValidationParamForm = class(TForm)
    CheckValidateStartingCondition: TCheckBox;
    CheckAnneal: TCheckBox;
    EditValidateSimAn: TEdit;
    CheckBox3: TCheckBox;
    EditItImp: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ValidationParamForm: TValidationParamForm;

implementation

uses Marxan_interface, SCP_Main;

{$R *.DFM}

procedure TValidationParamForm.BitBtn1Click(Sender: TObject);
var
   iMarxanChildIndex : integer;
begin
     // execute validation run

     // set marxan parameters to create validation output
     iMarxanChildIndex := SCPForm.ReturnMarxanChildIndex;
     if (iMarxanChildIndex > -1) then
        with TMarxanInterfaceForm(MDIChildren[iMarxanChildIndex]) do
        begin
             DeleteInputParameter('SAVEANNEALINGTRACE');
             DeleteInputParameter('ANNEALINGTRACEROWS');
             DeleteInputParameter('SAVEITIMPTRACE');
             DeleteInputParameter('ITIMPTRACEROWS');

             if CheckAnneal.Checked then
             begin
                  UpdateInputParameter('SAVEANNEALINGTRACE','3');
                  UpdateInputParameter('ANNEALINGTRACEROWS',EditValidateSimAn.Text);
                  fValidateAnnealing := True;

             end;

             if CheckAnneal.Checked then
             begin
                  UpdateInputParameter('SAVEITIMPTRACE','3');
                  UpdateInputParameter('ITIMPTRACEROWS',EditItImp.Text);
                  fValidateIterativeImprovement := True;
             end;

             // run marxan
             ButtonUpdateClick(Self);

             // run validation analysis

        end;
end;

end.
