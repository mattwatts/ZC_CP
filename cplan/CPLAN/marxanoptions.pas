unit marxanoptions;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, ExtCtrls, Tabs;

type
  TMarxanOptionsForm = class(TForm)
    TabSet1: TTabSet;
    Notebook1: TNotebook;
    LinkGroup: TRadioGroup;
    CheckInitDisp: TCheckBox;
    SelectMapGroup: TRadioGroup;
    CheckZoom: TCheckBox;
    btnReLink: TButton;
    CheckEnglishGIS: TCheckBox;
    OptPlotGroup: TRadioGroup;
    CheckPropose: TCheckBox;
    CheckUnDef: TCheckBox;
    CheckExc: TCheckBox;
    ckStayOnTop: TCheckBox;
    SubsetGroup: TRadioGroup;
    RadioDisplayValues: TRadioGroup;
    GroupBox1: TGroupBox;
    CheckWeightArea: TCheckBox;
    CheckWeightTarget: TCheckBox;
    CheckWeightVuln: TCheckBox;
    CheckDisplayAbsSumirr: TCheckBox;
    CheckDisplayScheme: TRadioGroup;
    CheckUpdateGISValues: TCheckBox;
    btnUpdate: TButton;
    Label1: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    SiteFeatEdit: TLabel;
    SiteSummEdit: TLabel;
    DatabaseEdit: TLabel;
    Label4: TLabel;
    FSTable: TLabel;
    ckShowExtraTools: TCheckBox;
    CheckReportTime: TCheckBox;
    checkShowHint: TCheckBox;
    GroupBox2: TGroupBox;
    RadioScaleType: TRadioGroup;
    RadioVulnType: TRadioGroup;
    CheckExtraSumirrVars: TCheckBox;
    CheckSuppressCSExclusionRecalc: TCheckBox;
    CheckUseValidationMode: TCheckBox;
    CheckValidateMinset: TCheckBox;
    RunIrrBeforeRpt: TCheckBox;
    CheckCompRpt: TCheckBox;
    CheckPartialValidateCombsize: TCheckBox;
    CheckValidateCombsize: TCheckBox;
    CheckValidateIrreplaceability: TCheckBox;
    CheckDbgLookup: TCheckBox;
    CheckDebugSPATTOOL: TCheckBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    VariableToPass: TComboBox;
    CheckRecalcContrib: TCheckBox;
    EditResWeight: TEdit;
    EditRadius: TEdit;
    EditExponent: TEdit;
    CheckConnectSpattool: TCheckBox;
    btnRadius: TButton;
    btnExponent: TButton;
    Label9: TLabel;
    RadioCombType: TRadioGroup;
    EditOriginal: TEdit;
    SpinCombSize: TSpinEdit;
    EditCombSize: TEdit;
    Memo1: TMemo;
    CheckLogCombsize: TCheckBox;
    btnOverride: TButton;
    CheckLockCombsize: TCheckBox;
    procedure TabSet1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MarxanOptionsForm: TMarxanOptionsForm;

implementation

{$R *.DFM}



procedure TMarxanOptionsForm.TabSet1Click(Sender: TObject);
begin
     Notebook1.PageIndex := TabSet1.TabIndex;

     Caption := TabSet1.Tabs[TabSet1.TabIndex];
end;

end.
