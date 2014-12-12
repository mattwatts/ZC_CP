unit MZ_system_test;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls;

type
  TMarxanSystemTestForm = class(TForm)
    Label1: TLabel;
    EditInputDat: TEdit;
    btnBrowse: TButton;
    Label2: TLabel;
    ComboTestConfigurations: TComboBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OpenDialog1: TOpenDialog;
    InputDatListBox: TListBox;
    RadioSoftwareTestType: TRadioGroup;
    CheckTranspose: TCheckBox;
    CheckSortOrder: TCheckBox;
    CheckProduceDetail: TCheckBox;
    GroupBox1: TGroupBox;
    CheckTargetAchievement: TCheckBox;
    CheckSummary: TCheckBox;
    CheckPUDetail: TCheckBox;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure ExecuteValidation;
    procedure ComboTestConfigurationsChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MarxanSystemTestForm: TMarxanSystemTestForm;

implementation

uses SCP_Main, ComputeMarxanObjectives, CSV_Child, Marxan_interface;

{$R *.DFM}
     
procedure TMarxanSystemTestForm.BitBtn1Click(Sender: TObject);
begin
     ExecuteValidation;
end;

procedure TMarxanSystemTestForm.ExecuteValidation;
var
   sTestConfigurations : string;
   AChild : TCSVChild;
   rBLM : extended;
begin
     fCMOSortOrder := CheckSortOrder.Checked;
     fCMOProduceDetail := CheckProduceDetail.Checked;
     fCMOTargetAchievement := CheckTargetAchievement.Checked;
     fCMOCheckSummary := CheckSummary.Checked;
     fCMOProducePUDetail := CheckPUDetail.Checked;
     sCMOInputDat := EditInputDat.Text;

     if CheckTranspose.Checked then
     begin
          AChild := TCSVChild(SCPForm.ReturnNamedChild(ComboTestConfigurations.Text));
          sTestConfigurations := SCPForm.TransposeCSVChild(AChild,True);
     end
     else
         sTestConfigurations := ComboTestConfigurations.Text;

     rBLM := 1;

     case RadioSoftwareTestType.ItemIndex of
          0 : ExecuteMarZoneTest(sTestConfigurations,rBLM,1);
          1 : ExecuteMarxanTest(sTestConfigurations,rBLM,1);
          2 : ExecuteMarProb1DTest(sTestConfigurations,rBLM,1);
          3 : ExecuteMarProb2DTest(sTestConfigurations,rBLM,1);
          4 : ExecuteMarConTest(sTestConfigurations,rBLM,1);
     end;
end;

procedure TMarxanSystemTestForm.FormCreate(Sender: TObject);
var
   iCount : integer;
   sInputDatFile : string;
begin
     ComboTestConfigurations.Items.Clear;

     if (SCPForm.MDIChildCount > 0) then
        for iCount := 0 to (SCPForm.MDIChildCount-1) do
            ComboTestConfigurations.Items.Add(SCPForm.MDIChildren[iCount].Caption);

     ComboTestConfigurations.Text := ComboTestConfigurations.Items.Strings[0];
     CheckTranspose.Checked := (Pos('anneal_zones',ComboTestConfigurations.Text) > 0);

     // if file exists ..\input.dat, then set parameter to reflect this
     sInputDatFile := ExtractFilePath(ComboTestConfigurations.Text);
     sInputDatFile := ExtractFilePath(Copy(sInputDatFile,1,Length(sInputDatFile)-1));
     sInputDatFile := sInputDatFile + 'input.dat';
     if fileexists(sInputDatFile) then
        EditInputDat.Text := sInputDatFile
     else
         EditInputDat.Text := '';
end;

procedure TMarxanSystemTestForm.btnBrowseClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
        EditInputDat.Text := OpenDialog1.Filename;
end;

procedure TMarxanSystemTestForm.ComboTestConfigurationsChange(
  Sender: TObject);
var
   sInputDatFile : string;
begin
     // if file exists ..\input.dat, then set parameter to reflect this
     sInputDatFile := ExtractFilePath(ComboTestConfigurations.Text);
     sInputDatFile := ExtractFilePath(Copy(sInputDatFile,1,Length(sInputDatFile)-1));
     sInputDatFile := sInputDatFile + 'input.dat';
     if fileexists(sInputDatFile) then
        EditInputDat.Text := sInputDatFile
     else
         EditInputDat.Text := '';

end;

end.
