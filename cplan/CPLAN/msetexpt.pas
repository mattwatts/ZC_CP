unit msetexpt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, ExtCtrls, ComCtrls, Tabnotbk, Buttons;

type
  TMinsetExpertForm = class(TForm)
    TabbedNotebook1: TTabbedNotebook;
    LoopGroup: TRadioGroup;
    SitesBetweenRules: TRadioGroup;
    GroupBox1: TGroupBox;
    SpinSelect: TSpinEdit;
    Memo1: TMemo;
    CombineVuln: TRadioGroup;
    GroupBox2: TGroupBox;
    x: TLabel;
    Label4: TLabel;
    CheckResourceLimit: TCheckBox;
    ComboResource: TComboBox;
    SpinResource: TSpinEdit;
    CheckDebugSites: TCheckBox;
    BitBtn1: TBitBtn;
    SpinVuln: TSpinEdit;
    SpinIter: TSpinEdit;
    Memo2: TMemo;
    CheckEnableDestruction: TCheckBox;
    btnSetWorkingDirectory: TButton;
    CheckExtraDetail: TCheckBox;
    DestructMemo: TMemo;
    SpinSelectionsPerDestruction: TSpinEdit;
    CheckDebugFeatures: TCheckBox;
    CheckEnableComplementarity: TCheckBox;
    Memo3: TMemo;
    TabbedNotebook2: TTabbedNotebook;
    RadioGroup1: TRadioGroup;
    SpinEdit1: TSpinEdit;
    RadioGroup2: TRadioGroup;
    GroupBox3: TGroupBox;
    SpinEdit2: TSpinEdit;
    Memo4: TMemo;
    GroupBox4: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    SpinEdit3: TSpinEdit;
    CheckBox2: TCheckBox;
    Memo5: TMemo;
    Button1: TButton;
    CheckBox4: TCheckBox;
    RedundancySetting: TRadioGroup;
    RedundancyTiming: TSpinEdit;
    CheckProposedReserve: TCheckBox;
    CheckHotspotsFeatures: TCheckBox;
    GroupBox5: TGroupBox;
    Label5: TLabel;
    TgtField2: TComboBox;
    GroupBox6: TGroupBox;
    Label6: TLabel;
    TgtField: TComboBox;
    RadioStartingCondition: TRadioGroup;
    EditLogFile: TEdit;
    Button2: TButton;
    OpenLog: TOpenDialog;
    RadioGroup3: TRadioGroup;
    Edit1: TEdit;
    Button3: TButton;
    RedCheckEnd: TCheckBox;
    RedCheckOrder: TCheckBox;
    RedCheckExclude: TCheckBox;
    CheckReportSelectFirstSites: TCheckBox;
    Memo6: TMemo;
    Memo7: TMemo;
    CheckNull: TCheckBox;
    EditAreaPerDestruction: TEdit;
    RadioPerDestruction: TRadioGroup;
    LabelDESTRATE: TLabel;
    ComboDESTRATE: TComboBox;
    Label1: TLabel;
    EditVulnWeight: TEdit;
    CheckReAllocate: TCheckBox;
    Label7: TLabel;
    ComboRegionField: TComboBox;
    Label8: TLabel;
    EditRegionResRateTable: TEdit;
    BtnBrowseRegResRateTable: TButton;
    RadioReAllocLogic: TRadioGroup;
    Label9: TLabel;
    EditReAllocUnitSize: TEdit;
    Label10: TLabel;
    EditYearsToSimulate: TEdit;
    OpenResRateTable: TOpenDialog;
    procedure SpinVulnChange(Sender: TObject);
    procedure SpinIterChange(Sender: TObject);
    procedure LoopGroupClick(Sender: TObject);
    procedure CombineVulnClick(Sender: TObject);
    procedure ComboResourceChange(Sender: TObject);
    procedure SpinResourceChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSetWorkingDirectoryClick(Sender: TObject);
    procedure CheckEnableDestructionClick(Sender: TObject);
    procedure TabbedNotebook1Change(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure CheckBox4Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure SpinEdit3Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure RadioGroup2Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure RedundancyTimingChange(Sender: TObject);
    procedure TgtField2Change(Sender: TObject);
    procedure RadioStartingConditionClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure RadioGroup3Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CheckNullClick(Sender: TObject);
    procedure ComboDESTRATEChange(Sender: TObject);
    procedure BtnBrowseRegResRateTableClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MinsetExpertForm: TMinsetExpertForm;

implementation

uses sub_feat, Control, destruct;

{$R *.DFM}

procedure TMinsetExpertForm.SpinVulnChange(Sender: TObject);
begin
     CombineVuln.Items.Delete(3);
     CombineVuln.Items.Add('Restrict to Maximum ' + IntToStr(SpinVuln.Value) + '%');
     CombineVuln.ItemIndex := 3;
end;

procedure TMinsetExpertForm.SpinIterChange(Sender: TObject);
var
   iIdx : integer;
begin
     iIdx := LoopGroup.ItemIndex;

     LoopGroup.Items.Delete(2);
     LoopGroup.Items.Add(IntToStr(SpinIter.Value) + ' Iterations');

     LoopGroup.ItemIndex := iIdx;
end;

procedure TMinsetExpertForm.LoopGroupClick(Sender: TObject);
begin
     if (LoopGroup.ItemIndex = 2) then
        SpinIter.Enabled := True
     else
         SpinIter.Enabled := False;

     if (LoopGroup.ItemIndex = 1) then
     begin
          // allow user to select one or more feature subsets
          StopSubsetForm := TStopSubsetForm.Create(Application);
          if (StopSubsetForm.ShowModal <> mrOk) then
             LoopGroup.ItemIndex := 0;
          StopSubsetForm.Free;
     end;
end;

procedure TMinsetExpertForm.CombineVulnClick(Sender: TObject);
begin
     if (CombineVuln.ItemIndex = 3) then
        SpinVuln.Enabled := True
     else
         SpinVuln.Enabled := False;
end;

procedure TMinsetExpertForm.ComboResourceChange(Sender: TObject);
begin
     CheckResourceLimit.Checked := True;
end;

procedure TMinsetExpertForm.SpinResourceChange(Sender: TObject);
begin
     CheckResourceLimit.Checked := True;
end;

procedure TMinsetExpertForm.FormCreate(Sender: TObject);
var
   Sheet : TTabSheet;
begin
     TabbedNotebook1.PageIndex := 0;

     // enable destruction option if DESTRATE exists in the Feature Summary Table
     CheckEnableDestruction.Enabled := ControlRes^.fDESTRATELoaded;
     if (not CheckEnableDestruction.Enabled) then
        DestructMemo.Lines.Add('DESTRATE must be specified in the feature summary table to activate this option.');

     CheckExtraDetail.Visible := ControlRes^.fShowExtraTools;

     if not ControlRes^.fShowExtraTools then
     begin
          TabbedNotebook1.Visible := False;
          TabbedNotebook2.Visible := True;

          TabbedNotebook2.PageIndex := 0;
     end;

     // load available target fields so the user can select which one they want
     if ControlForm.UseFeatCutOffs.Checked then
     begin
          ControlForm.LoadTargetFields(TgtField.Items);
          TgtField.Text := ControlRes^.sFeatureTargetField;
          ControlForm.LoadTargetFields(TgtField2.Items);
          TgtField2.Text := ControlRes^.sFeatureTargetField;
     end
     else
     begin
          TgtField.Enabled := False;
          TgtField.Text := 'ITARGET';
          TgtField2.Enabled := False;
          TgtField2.Text := 'ITARGET';
     end;

     // load available site fields so user can select region field
     ControlForm.LoadSiteFields(ComboRegionField.Items);

     ControlForm.LoadTargetFields(ComboDESTRATE.Items);
     ComboDESTRATE.Text := ControlRes^.sDESTRATEField;
end;

procedure TMinsetExpertForm.btnSetWorkingDirectoryClick(Sender: TObject);
begin
     ControlForm.SetWorkingDirectory1Click(Sender);
end;

procedure TMinsetExpertForm.CheckEnableDestructionClick(Sender: TObject);
begin
     SpinSelectionsPerDestruction.Enabled := CheckEnableDestruction.Checked;
end;

procedure TMinsetExpertForm.TabbedNotebook1Change(Sender: TObject;
  NewTab: Integer; var AllowChange: Boolean);
begin
     // selected page has changed
     (*if ControlRes^.fShowExtraTools then
        AllowChange := True
     else
     begin
          if (NewTab = 4)
          or (NewTab = 5)
          or (NewTab = 6) then
             AllowChange := False
          else
              AllowChange := True;
     end;*)
end;


procedure TMinsetExpertForm.CheckBox4Click(Sender: TObject);
begin
     CheckDebugFeatures.Checked := CheckBox4.Checked;
end;

procedure TMinsetExpertForm.CheckBox2Click(Sender: TObject);
begin
     CheckDebugSites.Checked := CheckBox2.Checked;
end;

procedure TMinsetExpertForm.CheckBox1Click(Sender: TObject);
begin
     CheckResourceLimit.Checked := CheckBox1.Checked;
end;

procedure TMinsetExpertForm.SpinEdit3Change(Sender: TObject);
begin
     SpinResource.Text := SpinEdit3.Text;
     SpinResourceChange(Sender);
end;

procedure TMinsetExpertForm.ComboBox1Change(Sender: TObject);
begin
     ComboResource.Text := ComboBox1.Text;
     ComboResourceChange(Sender);
end;

procedure TMinsetExpertForm.SpinEdit2Change(Sender: TObject);
begin
     SpinSelect.Text := SpinEdit2.Text;
end;

procedure TMinsetExpertForm.RadioGroup2Click(Sender: TObject);
begin
     SitesBetweenRules.ItemIndex := RadioGroup2.ItemIndex;
end;

procedure TMinsetExpertForm.SpinEdit1Change(Sender: TObject);
begin
     SpinIter.Value := SpinEdit1.Value;
     SpinIterChange(Sender);
end;

procedure TMinsetExpertForm.RadioGroup1Click(Sender: TObject);
begin
     LoopGroup.ItemIndex := RadioGroup1.ItemIndex;
     LoopGroupClick(Sender);
end;


procedure TMinsetExpertForm.RedundancyTimingChange(Sender: TObject);
var
   iIdx : integer;
begin
     iIdx := RedundancySetting.ItemIndex;

     RedundancySetting.Items.Delete(2);
     RedundancySetting.Items.Add('After each ' +
                                 IntToStr(RedundancyTiming.Value) +
                                 ' Iterations');

     RedundancySetting.ItemIndex := iIdx;
end;


procedure TMinsetExpertForm.TgtField2Change(Sender: TObject);
begin
     TgtField.Text := TgtField2.Text;
end;


procedure TMinsetExpertForm.RadioStartingConditionClick(Sender: TObject);
begin
     if (RadioStartingCondition.ItemIndex = 1) then
     begin
          if FileExists(EditLogFile.Text) then
          begin
               // it is ok to select this item as a log file is specified
          end
          else
          begin
               // the user must select a valid log file to proceed
               OpenLog.InitialDir := ControlRes^.sWorkingDirectory;
               if OpenLog.Execute then
                  EditLogFile.Text := OpenLog.Filename
               else
                   RadioStartingCondition.ItemIndex := 0;
          end;
     end;
end;

procedure TMinsetExpertForm.Button2Click(Sender: TObject);
begin
     OpenLog.InitialDir := ControlRes^.sWorkingDirectory;
     if OpenLog.Execute then
     begin
          EditLogFile.Text := OpenLog.Filename;
          RadioStartingCondition.ItemIndex := 1;
     end;
end;


procedure TMinsetExpertForm.RadioGroup3Click(Sender: TObject);
begin
     if (RadioGroup3.ItemIndex = 1) then
     begin
          if FileExists(EditLogFile.Text) then
          begin
               // it is ok to select this item as a log file is specified
          end
          else
          begin
               // the user must select a valid log file to proceed
               OpenLog.InitialDir := ControlRes^.sWorkingDirectory;
               if OpenLog.Execute then
               begin
                    EditLogFile.Text := OpenLog.Filename;
                    Edit1.Text := OpenLog.Filename;
                    RadioStartingCondition.ItemIndex := 1;
               end
               else
               begin
                    RadioStartingCondition.ItemIndex := 0;
                    RadioGroup3.ItemIndex := 0;
               end;
          end;
     end
     else
         RadioStartingCondition.ItemIndex := RadioGroup3.ItemIndex;
end;

procedure TMinsetExpertForm.Button3Click(Sender: TObject);
begin
     OpenLog.InitialDir := ControlRes^.sWorkingDirectory;
     if OpenLog.Execute then
     begin
          EditLogFile.Text := OpenLog.Filename;
          Edit1.Text := OpenLog.Filename;
          RadioStartingCondition.ItemIndex := 1;
          RadioGroup3.ItemIndex := 1;
     end;

end;




procedure TMinsetExpertForm.CheckNullClick(Sender: TObject);
begin
     ControlRes^.fNullHotspotsSimulation := CheckNull.Checked;
end;

procedure TMinsetExpertForm.ComboDESTRATEChange(Sender: TObject);
begin
     ControlRes^.sDESTRATEField := ComboDESTRATE.Text;

     if ControlRes^.fDestructObjectsCreated then
     begin
          FreeDestroy(FALSE);
          InitDestroy(FALSE);
     end;
end;

procedure TMinsetExpertForm.BtnBrowseRegResRateTableClick(Sender: TObject);
begin
     if (EditRegionResRateTable.Text = '') then
        OpenResRateTable.InitialDir := ControlRes^.sWorkingDirectory;

     if OpenResRateTable.Execute then
        EditRegionResRateTable.Text := OpenResRateTable.Filename;
end;

end.
