unit Options;
{Author: Matthew Watts
 Date:
 Purpose: For managing C-Plan user Options}

{$IFDEF VER90}
{$DEFINE ARCVIEW_DDE}
{$ELSE}
{$UNDEF ARCVIEW_DDE}
{$ENDIF}

{$DEFINE FASTINIT}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Tabs, Buttons, Spin;

type
  TOptionsForm = class(TForm)
    BitBtn1: TBitBtn;
    TabSet1: TTabSet;
    Notebook1: TNotebook;
    Label1: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    OptPlotGroup: TRadioGroup;
    CheckPropose: TCheckBox;
    CheckUnDef: TCheckBox;
    CheckExc: TCheckBox;
    SiteFeatEdit: TLabel;
    SiteSummEdit: TLabel;
    DatabaseEdit: TLabel;
    Label4: TLabel;
    FSTable: TLabel;
    LinkGroup: TRadioGroup;
    ckShowExtraTools: TCheckBox;
    ckStayOnTop: TCheckBox;
    CheckInitDisp: TCheckBox;
    SubsetGroup: TRadioGroup;
    RadioDisplayValues: TRadioGroup;
    CheckReportTime: TCheckBox;
    SelectMapGroup: TRadioGroup;
    CheckZoom: TCheckBox;
    GroupBox1: TGroupBox;
    CheckWeightArea: TCheckBox;
    CheckWeightTarget: TCheckBox;
    CheckWeightVuln: TCheckBox;
    VariableToPass: TComboBox;
    Label5: TLabel;
    CheckRecalcContrib: TCheckBox;
    EditResWeight: TEdit;
    EditRadius: TEdit;
    EditExponent: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    CheckConnectSpattool: TCheckBox;
    Label9: TLabel;
    RadioCombType: TRadioGroup;
    EditOriginal: TEdit;
    SpinCombSize: TSpinEdit;
    EditCombSize: TEdit;
    Memo1: TMemo;
    CheckDisplayAbsSumirr: TCheckBox;
    CheckDisplayScheme: TRadioGroup;
    checkShowHint: TCheckBox;
    CheckLogCombsize: TCheckBox;
    CheckUpdateGISValues: TCheckBox;
    btnOverride: TButton;
    CheckLockCombsize: TCheckBox;
    btnReLink: TButton;
    CheckEnglishGIS: TCheckBox;
    btnUpdate: TButton;
    GroupBox2: TGroupBox;
    RadioScaleType: TRadioGroup;
    RadioVulnType: TRadioGroup;
    CheckExtraSumirrVars: TCheckBox;
    CheckUseValidationMode: TCheckBox;
    CheckValidateMinset: TCheckBox;
    RunIrrBeforeRpt: TCheckBox;
    CheckCompRpt: TCheckBox;
    CheckPartialValidateCombsize: TCheckBox;
    CheckValidateCombsize: TCheckBox;
    CheckValidateIrreplaceability: TCheckBox;
    CheckDbgLookup: TCheckBox;
    CheckDebugSPATTOOL: TCheckBox;
    btnRadius: TButton;
    btnExponent: TButton;
    CheckSuppressCSExclusionRecalc: TCheckBox;
    CheckDisplayCSTriggerPopup: TCheckBox;
    btnTest: TButton;
    CheckSuppressTXTDBFlog: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure TabClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure checkShowHintClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure OptPlotGroupClick(Sender: TObject);
    procedure CheckProposeClick(Sender: TObject);
    procedure CheckUnDefClick(Sender: TObject);
    procedure CheckExcClick(Sender: TObject);
    procedure ckIrrepClick(Sender: TObject);
    procedure ckAcceptClick(Sender: TObject);
    procedure ckCycleClick(Sender: TObject);
    procedure ckToggleClick(Sender: TObject);
    procedure ckOpenClick(Sender: TObject);
    procedure ckBrowseClick(Sender: TObject);
    procedure ckSaveClick(Sender: TObject);
    procedure ckSaveAsClick(Sender: TObject);
    procedure ckF2TargClick(Sender: TObject);
    procedure ckContribClick(Sender: TObject);
    procedure ckSelLogClick(Sender: TObject);
    procedure ckStageMemoClick(Sender: TObject);
    procedure ckPartDefClick(Sender: TObject);
    procedure ckRestTargClick(Sender: TObject);
    procedure ckRedCheckClick(Sender: TObject);
    procedure ckShowPopUClick(Sender: TObject);
    procedure ckExitClick(Sender: TObject);
    procedure ckViewClick(Sender: TObject);
    procedure LinkGroupClick(Sender: TObject);
    procedure ckShowExtraToolsClick(Sender: TObject);
    procedure ckStayOnTopClick(Sender: TObject);
    procedure CheckInitDispClick(Sender: TObject);
    procedure CheckUseValidationModeClick(Sender: TObject);
    procedure RunIrrBeforeRptClick(Sender: TObject);
    procedure CheckCompRptClick(Sender: TObject);
    procedure CheckValidateCombsizeClick(Sender: TObject);
    procedure UsingSubsetWAV(const fUsingWav : boolean);
    procedure RadioDisplayValuesClick(Sender: TObject);
    procedure CheckValidateIrreplaceabilityClick(Sender: TObject);
    procedure CheckReportTimeClick(Sender: TObject);
    procedure SelectMapGroupClick(Sender: TObject);
    procedure CheckZoomClick(Sender: TObject);
    procedure CheckWeightAreaClick(Sender: TObject);
    procedure CheckWeightTargetClick(Sender: TObject);
    procedure CheckWeightVulnClick(Sender: TObject);
    procedure RedisplayIt(const fAskUser : boolean);
    procedure SubsetGroupClick(Sender: TObject);
    procedure CheckDebugSPATTOOLClick(Sender: TObject);
    procedure VariableToPassClick(Sender: TObject);
    procedure CheckRecalcContribClick(Sender: TObject);
    procedure EditResWeightKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CheckConnectSpattoolMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CheckDbgLookupClick(Sender: TObject);
    procedure RadioCombTypeClick(Sender: TObject);
    procedure SpinCombSizeChange(Sender: TObject);
    procedure CheckDisplayAbsSumirrClick(Sender: TObject);
    procedure CheckDisplaySchemeClick(Sender: TObject);
    procedure CheckExtraSumirrVarsClick(Sender: TObject);
    procedure CheckLogCombsizeClick(Sender: TObject);
    procedure RadioScaleTypeClick(Sender: TObject);
    procedure RadioVulnTypeClick(Sender: TObject);
    procedure CheckUpdateGISValuesClick(Sender: TObject);
    procedure CheckPartialValidateCombsizeClick(Sender: TObject);
    procedure btnOverrideClick(Sender: TObject);
    procedure CheckLockCombsizeClick(Sender: TObject);
    procedure CheckValidateMinsetClick(Sender: TObject);
    procedure btnReLinkClick(Sender: TObject);
    procedure CheckEnglishGISClick(Sender: TObject);
    procedure EditRadiusChange(Sender: TObject);
    procedure EditExponentChange(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnRadiusClick(Sender: TObject);
    procedure btnExponentClick(Sender: TObject);
    procedure CheckSuppressCSExclusionRecalcClick(Sender: TObject);
    procedure CheckDisplayCSTriggerPopupClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure CheckSuppressTXTDBFlogClick(Sender: TObject);
  end;


  {$IFDEF ARCVIEW_DDE}
  procedure DDE_TryOpenArcView;
  procedure DDE_CloseArcView;
  {$ENDIF}
  {$IFDEF ARCVIEW_DDE}
  procedure LoadAVIni;
  {$ENDIF}
  procedure LoadZCIni;
  procedure DDE_TryOpenZonaeCogito;
  procedure DDE_CloseZonaeCogito;
  procedure GenerateIterationReports;
  procedure GenerateDebugReports(const sDir : string);


procedure GenerateStartReports;

var
  OptionsForm: TOptionsForm;
  fStartup, fStartForm, fStartingOptionsForm, fStartingCombsizeOptionsForm : boolean;

implementation

uses Control, Toolview, Dde_unit, Sf_irrep,
     Global, Toolmisc,
     {$IFDEF ARCVIEW_DDE}
     av1, Dialogs,
     {$ENDIF}
     IniFiles, FileCtrl,
     Reports, Comb_run,
     rules, pred_sf4,
     CombsizeRecord, override_combsize,
     validate, getuservalidatefile, msetexpt, spatio,
     marxan, ZCDDE_unit, open_ZC_GIS;

{$R *.DFM}

procedure SaveCustomCombSize;
var
   MyIni : TIniFile;
begin
     if ControlRes^.fOldIni then
        MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
     else
         MyIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);

     MyIni.WriteInteger('CombinationSize',
                        'Custom',
                        combsize.iCustomCombinationSize);
     MyIni.Free;
end;

procedure TOptionsForm.UsingSubsetWAV(const fUsingWav : boolean);
begin
     if fUsingWav then
     begin
          {remove '6' to '10'}
          if (SubsetGroup.Items.Count = 11) then
          begin
               SubsetGroup.Items.Delete(10);
               SubsetGroup.Items.Delete(9);
               SubsetGroup.Items.Delete(8);
               SubsetGroup.Items.Delete(7);
               SubsetGroup.Items.Delete(6);
          end;
          SubsetGroup.Height := 108;
     end
     else
     begin
          {add '6' to '10'}
          if (SubsetGroup.Items.Count = 6) then
          begin
               SubsetGroup.Items.Add('6');
               SubsetGroup.Items.Add('7');
               SubsetGroup.Items.Add('8');
               SubsetGroup.Items.Add('9');
               SubsetGroup.Items.Add('10');
          end;
          SubsetGroup.Height := 183;
     end;
end;

procedure TOptionsForm.FormCreate(Sender: TObject);
var
   iIdx, iCount, iDeferred : integer;
begin
     fStartForm := True;

     ControlRes^.fOptionCreate := True;

     fStartup := False;

     CheckValidateMinset.Checked := ControlRes^.fValidateMinset;

     TabSet1.Tabs := Notebook1.Pages;
     //TabSet1.Tabs.Delete(5);
     //TabSet1.Tabs.Delete(4);
     TabSet1.Tabs.Delete(6);
     TabSet1.Tabs.Delete(5);
     if not ControlRes^.fShowExtraTools then
        TabSet1.Tabs.Delete(4);

     Caption := TabSet1.Tabs[TabSet1.TabIndex] + ' Options';

     //checkMinimise.Font := CheckPropose.Font;
     checkShowHint.Font := CheckPropose.Font;
     ckStayOnTop.Font := CheckPropose.Font;

     RadioDisplayValues.ItemIndex := ControlRes^.iDisplayValuesFor;

     {$IFDEF VER80}
     iIdx := LinkGroup.Items.IndexOf('ArcView');
     if (iIdx > 0) then
        LinkGroup.Items.Delete(iIdx);
     {$ENDIF}

     SubsetGroup.Visible := ControlRes^.fFeatureClassesApplied;
     CheckReportTime.Checked := ControlRes^.fReportTime;

     SelectMapGroup.ItemIndex := ControlRes^.iSelectMapSites;
     CheckZoom.Checked := ControlRes^.fZoomOnSelect;
     if (SelectMapGroup.ItemIndex = 1) then
        CheckZoom.Enabled := False
     else
         CheckZoom.Enabled := True;

     // set values for the spatial options page
     CheckConnectSpattool.Checked := ControlRes^.fConnectedToSPATTOOL;

     //VariableToPass.Text := VariableToPass.Items.Strings[ControlRes^.iSpatialVariableToPass];
     VariableToPass.Text := ControlRes^.sSpatialVariableToPass;
     if ControlRes^.fFeatureClassesApplied then
     begin
          for iCount := 1 to 10 do
              if ControlRes^.ClassDetail[iCount] then
                 VariableToPass.Items.Add('sumirr ' + IntToStr(iCount));
     end;

     CheckRecalcContrib.Checked := ControlRes^.fRecalcContrib;
     EditResWeight.Text := FloatToStr(ControlRes^.rSpatContribReservedWeight);
     EditRadius.Text := IntToStr(ControlRes^.iSpatialContribRadius);
     EditExponent.Text := FloatToStr(ControlRes^.rSpatialContribExponent);

     SpinCombSize.Value := combsize.iCustomCombinationSize;

     ControlRes^.fOptionCreate := False;

     CheckDisplayAbsSumirr.Checked := ControlRes^.fDisplayAbsSumirr;
     CheckDisplayScheme.ItemIndex := ControlRes^.iDisplayScheme;
     
     CheckExtraSumirrVars.Checked := ControlRes^.fCalculateBobsExtraVariations;
     if ControlRes^.fShowExtraTools then
        CheckExtraSumirrVars.Enabled := True;

     RadioScaleType.ItemIndex := ControlRes^.iScalingType;

     RadioVulnType.ItemIndex := ControlRes^.iVulnWeightingType;
     if ControlRes^.fFloatVulnerabilityLoaded then
        RadioVulnType.Visible := True;

     CheckLogCombsize.Checked := ControlRes^.fLogCombsizeRecalc;

     CheckLockCombsize.Checked := ControlRes^.fLockUserDefinedCombinationSize;

     CheckEnglishGIS.Checked := ControlRes^.fGISRegionalSettingIsEnglish;

     CheckSuppressCSExclusionRecalc.Checked := ControlRes^.fSuppressCSExclusionRecalc;

     CheckDisplayCSTriggerPopup.Checked := ControlRes^.fDisplayCSTriggerPopup;

     iDeferred := ControlForm.R1.Items.Count + ControlForm.R2.Items.Count + ControlForm.R3.Items.Count + ControlForm.R4.Items.Count + ControlForm.R5.Items.Count;
     Memo1.Lines.Clear;
     Memo1.Lines.Add('The Combination Size is Reduced by the number of Provisionally');
     Memo1.Lines.Add('Selected Sites.  There are ' + IntToStr(iDeferred) + ' selected sites.');

     CheckSuppressTXTDBFlog.Checked := not ControlRes^.fGenerate_TXT_DBF_log;
     
     CheckDisplayScheme.Visible := not (ControlRes^.GISLink = ZonaeCogito);

     fStartForm := False;
end;

procedure TOptionsForm.TabClick(Sender: TObject);
begin
     Notebook1.PageIndex := TabSet1.TabIndex;

     Caption := TabSet1.Tabs[TabSet1.TabIndex] + ' Options';
end;

procedure TOptionsForm.FormActivate(Sender: TObject);
var
   iCount : integer;
begin
     fStartForm := True;

     CheckDbgLookup.Checked := ControlRes^.fDebugLookup;

     ControlRes^.fOptionCreate := True;

     CheckWeightArea.Checked := ControlRes^.fSumirrWeightArea;
     CheckWeightTarget.Checked := ControlRes^.fSumirrWeightTarget;
     CheckWeightVuln.Checked := ControlRes^.fSumirrWeightVuln;

     CheckValidateCombsize.Checked := ControlRes^.fValidateCombsize;
     CheckCompRpt.Checked := ControlRes^.fGenerateCompRpt;
     RunIrrBeforeRpt.Checked := ControlRes^.fRunIrrBefRpt;

     CheckUseValidationMode.Checked := ControlRes^.fValidateMode;

     CheckShowHint.Checked := fShowHints;
     ckStayOnTop.Checked := ControlRes^.fStayOnTop;

     // mtx or mat file
     // SiteFeatEdit.Caption := ControlRes^.sSiteFeatureTable;
     SiteFeatEdit.Caption := ControlRes^.sSparseMatrix;

     SiteSummEdit.Caption := ControlRes^.sSiteSummaryTable;
     DatabaseEdit.Caption := ControlRes^.sDatabase;
     FSTable.Caption := ControlRes^.sFeatCutOffsTable;

     CheckInitDisp.Checked := ControlRes^.fInitialiseGIS;

     // OptPlotGroup.Items := ControlForm.PlotGroup.Items;
     OptPlotGroup.Items.Clear;
     OptPlotGroup.Items.Add('Site Irreplaceability (IRREPL)');
     OptPlotGroup.Items.Add('Summed Irreplaceability (SUMIRR)');
     OptPlotGroup.Items.Add('Weighted Average Irreplaceability (WAVIRR)');
     OptPlotGroup.Items.Add('Percent Contribution (PCCONTR)');
     // add any necessary spatial contrib variables that we are calculating
     if ControlRes^.fSpatResultCreated then
     begin
          if (ControlRes^.iSpatialVectorsToPass > 0) then
          begin
               for iCount := 1 to 10 do
                   if ControlRes^.fDoConfigOnSubset[iCount] then
                      OptPlotGroup.Items.Add('Spatial Contribution ' + IntToStr(iCount));
          end;
          OptPlotGroup.Items.Add('Spatial Contribution');
     end;
     // add MSummedSoln if it has been generated
     if fMarxanResultCreated then
        OptPlotGroup.Items.Add('Marxan Summed Solution');

     OptPlotGroup.ItemIndex := ControlRes^.iGISPlotField;

     if (OptPlotGroup.ItemIndex = 1) then
     begin
          GroupBox1.Visible := True;
          CheckWeightArea.Visible := True;
          CheckWeightTarget.Visible := True;
          CheckWeightVuln.Visible := True;
          CheckDisplayAbsSumirr.Visible := True;
     end
     else
     begin
          GroupBox1.Visible := False;
          CheckWeightArea.Visible := False;
          CheckWeightTarget.Visible := False;
          CheckWeightVuln.Visible := False;
          CheckDisplayAbsSumirr.Visible := False;
     end;

     SubsetGroup.Items := ControlForm.SubsetGroup.Items;
     SubsetGroup.ItemIndex := ControlForm.SubsetGroup.ItemIndex;

     if (OptPlotGroup.ItemIndex = 2)
     or (OptPlotGroup.ItemIndex = 3) then
        {plotting Wavirr of PCUsed}
        UsingSubsetWAV(True)
     else
         UsingSubsetWAV(False);

     CheckPropose.Checked := fProposeSites;
     CheckUnDef.Checked := fWatchUnDef;
     CheckExc.Checked := fWatchExc;

     case ControlRes^.GISLink of
          ArcView : LinkGroup.ItemIndex := 1;
          ZonaeCogito : LinkGroup.ItemIndex := 2;
     else
         LinkGroup.ItemIndex := 0;
     end;

     CheckDebugSPATTOOL.Checked := ControlRes^.fDebugSPATTOOL;

     if (Notebook1.PageIndex = 0) then
        ckShowExtraTools.Checked := ControlRes^.fShowExtraTools;

     fStartup := True;

     ControlRes^.fOptionCreate := False;

     fStartForm := False;
end;

procedure TOptionsForm.checkShowHintClick(Sender: TObject);
begin
     fShowHints := CheckShowHint.Checked;

     fIniChange := True;

     if fShowHints then
        HintsOn
     else
         HintsOff;
end;

procedure TOptionsForm.BitBtn1Click(Sender: TObject);
begin

     if not ControlForm.Visible
     and not ControlRes^.fToolView then
     begin
          {ToolForm change from open to close}

          ToolForm.Close;
     end
     else
         if ControlForm.Visible
         and ControlRes^.fToolView then
         begin
              {ToolForm change from close to open}

              ControlForm.ToolView1Click(self);
         end;
end;

procedure TOptionsForm.OptPlotGroupClick(Sender: TObject);
begin
     Screen.Cursor := crHourglass;
     try
     if (ControlRes^.iGISPlotField <> OptPlotGroup.ItemIndex) then
     begin
          ControlRes^.iGISPlotField := OptPlotGroup.ItemIndex;
          if (OptPlotGroup.Items.Strings[OptPlotGroup.ItemIndex] = 'Marxan Summed Solution') then
             ControlRes^.iGISPlotField := 10;
          RedisplayIt(True);
     end;

     except
     end;
     Screen.Cursor := crDefault;
end;

procedure TOptionsForm.CheckProposeClick(Sender: TObject);
begin
     fProposeSites := CheckPropose.Checked;
end;

procedure TOptionsForm.CheckUnDefClick(Sender: TObject);
begin
     fWatchUnDef := CheckUnDef.Checked;
end;

procedure TOptionsForm.CheckExcClick(Sender: TObject);
begin
     fWatchExc := CheckExc.Checked;
end;

procedure TOptionsForm.ckIrrepClick(Sender: TObject);
begin
     //ControlRes^.fShowIrrep := ckIrrep.Checked;
end;

procedure TOptionsForm.ckAcceptClick(Sender: TObject);
begin
     //ControlRes^.fShowAccept := ckAccept.Checked;
end;

procedure TOptionsForm.ckCycleClick(Sender: TObject);
begin
     //ControlRes^.fShowCycle := ckCycle.Checked;
end;

procedure TOptionsForm.ckToggleClick(Sender: TObject);
begin
     //ControlRes^.fShowToggle := ckToggle.Checked;
end;

procedure TOptionsForm.ckOpenClick(Sender: TObject);
begin
     //ControlRes^.fShowOpen := ckOpen.Checked;
end;

procedure TOptionsForm.ckBrowseClick(Sender: TObject);
begin
     //ControlRes^.fShowBrowse := ckBrowse.Checked;
end;

procedure TOptionsForm.ckSaveClick(Sender: TObject);
begin
     //ControlRes^.fShowSave := ckSave.Checked;
end;

procedure TOptionsForm.ckSaveAsClick(Sender: TObject);
begin
     //ControlRes^.fShowSaveAs := ckSaveAs.Checked;
end;

procedure TOptionsForm.ckF2TargClick(Sender: TObject);
begin
     //ControlRes^.fShowF2Targ := ckF2Targ.Checked;
end;

procedure TOptionsForm.ckContribClick(Sender: TObject);
begin
     //ControlRes^.fShowContrib := ckContrib.Checked;
end;

procedure TOptionsForm.ckSelLogClick(Sender: TObject);
begin
     //ControlRes^.fShowSelLog := ckSelLog.Checked;
end;

procedure TOptionsForm.ckStageMemoClick(Sender: TObject);
begin
     //ControlRes^.fShowStageMemo := ckStageMemo.Checked;
end;

procedure TOptionsForm.ckPartDefClick(Sender: TObject);
begin
     //ControlRes^.fShowPartDef := ckPartDef.Checked;
end;

procedure TOptionsForm.ckRestTargClick(Sender: TObject);
begin
     //ControlRes^.fShowRestTarg := ckRestTarg.Checked;
end;

procedure TOptionsForm.ckRedCheckClick(Sender: TObject);
begin
     //ControlRes^.fShowRedCheck := ckRedCheck.Checked;
end;

procedure TOptionsForm.ckShowPopUClick(Sender: TObject);
begin
     //ControlRes^.fShowPopUp := ckShowPopUp.Checked;
end;

procedure TOptionsForm.ckExitClick(Sender: TObject);
begin
     //ControlRes^.fShowExit := ckExit.Checked;
end;

procedure TOptionsForm.ckViewClick(Sender: TObject);
begin
     //ControlRes^.fToolView := ckView.Checked;
end;

{$IFDEF ARCVIEW_DDE}
procedure DDE_CloseArcView;
begin
     if (AVDDEForm <> nil) then
     begin
          if (ControlRes^.GISLink = ArcView) then
             AVDDEForm.DdeCmdClient.CloseLink;

          AVDDEForm.Free;

          ControlRes^.GISLink := None;
     end;
end;
{$ENDIF}
procedure DDE_CloseZonaeCogito;
begin
     if (ZCDDEForm <> nil) then
     begin
          if (ControlRes^.GISLink = ZonaeCogito) then
             ZCDDEForm.DdeCmdClient.CloseLink;

          ZCDDEForm.Free;

          ControlRes^.GISLink := None;
     end;
end;

{$IFDEF ARCVIEW_DDE}
procedure LoadAVIni;
var
   AnIni : TIniFile;
begin
     {load the local settings for the users database}
     if (ControlRes^.fOldIni) then
        AnIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
     else
         AnIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);

     ControlRes^.sAVView := AnIni.ReadString('ArcView','View','');
     ControlRes^.sAVTheme := AnIni.ReadString('ArcView','Theme','');
     ControlRes^.sShpTable := AnIni.ReadString('ArcView','ShapeTable','');

     ControlRes^.sShpKeyField := AnIni.ReadString('ArcView','Key','ATTRIBUTE');

     ControlRes^.sAVAVLFile := AnIni.ReadString('ArcView','AVLFile','');
     ControlRes^.sInitAVLFile := AnIni.ReadString('ArcView','InitAVLFile','');
     ControlRes^.sDeferredAVLFile := AnIni.ReadString('ArcView','DeferredAVLFile','');

     AnIni.Free;

     {if there was no AVLFile or InitAVLFile settings, we must load these
      from the global defaults}
     if (ControlRes^.sInitAVLFile = '') then
     begin
          AnIni := TIniFile.Create(DB_INI_FILENAME);

          ControlRes^.sAVAVLFile := AnIni.ReadString('ArcView','AVLFile','');
          ControlRes^.sInitAVLFile := AnIni.ReadString('ArcView','InitAVLFile','');
          ControlRes^.sDeferredAVLFile := AnIni.ReadString('ArcView','DeferredAVLFile','');

          AnIni.Free;
     end;

end;
{$ENDIF}

procedure LoadZCIni;
var
   AnIni : TIniFile;
begin
     if (ControlRes^.fOldIni) then
        AnIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
     else
         AnIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);

     ControlRes^.sZCProject := AnIni.ReadString('ZonaeCogito','Project','');
     if not fileexists(ControlRes^.sZCProject) then
        ControlRes^.sZCProject := '';

     ControlRes^.sShpTable := AnIni.ReadString('ZonaeCogito','ShapeTable','');  
     ControlRes^.sShpKeyField := AnIni.ReadString('ZonaeCogito','Key','ATTRIBUTE');

     if not fileexists(ControlRes^.sShpTable) then
     begin
          ControlRes^.sShpTable := '';
          ControlRes^.sShpKeyField := '';
     end;

     AnIni.Free;
end;

{$IFDEF ARCVIEW_DDE}
procedure DDE_TryOpenArcView;
begin
     AVDDEForm := TAVDDEForm.Create(Application);

     LoadAVIni;

     with AVDDEForm.DdeCmdClient do
     begin
          {ConnectMode := ddeManual;}
          DdeService := 'ArcView';
          DdeTopic := 'System';

          if OpenLink then
          begin
               ControlRes^.GISLink := ArcView;

               //ControlForm.InitDisplay2DB;
               //ControlForm.InformGIS;
          end
          else
          begin
               ControlRes^.GISLink := None;

               Screen.Cursor := crDefault;
               MessageDlg('Unable to link to ' +
                          DDeService + ' ' + DdeTopic,
                          mtInformation,[mbOk],0);

               DDE_CloseArcView;
          end;
     end;
end;
{$ENDIF}

procedure DDE_TryOpenZonaeCogito;
var
   fAcceptLink : boolean;
   sTableName, sPathName : string;
begin
     ZCDDEForm := TZCDDEForm.Create(Application);

     if (ControlRes^.sShpTable = '') then
        LoadZCIni;

     if (ControlRes^.sShpTable = '') then
     begin
          // there are no settings for Zonae Cogito
          // query the user for the settings for Zonae Cogito
          fAcceptLink := False;

          Open_ZC_GIS_Form := TOpen_ZC_GIS_Form.Create(Application);
          if (Open_ZC_GIS_Form.ShowModal = mrOk) then
          begin
               // accept parameters and start link
               fAcceptLink := True;
               
               ControlRes^.sZCProject := Open_ZC_GIS_Form.Edit_ZCP_Project.Text;
               ControlRes^.sShpKeyField := Open_ZC_GIS_Form.ComboKeyField.Text;

               ControlRes^.sShpTable := ExtractFilePath(Open_ZC_GIS_Form.EditPUShapefile.Text);
               sTableName := ExtractFileName(Open_ZC_GIS_Form.EditPUShapefile.Text);
               sTableName := Copy(sTableName,1,Length(sTableName)-4);
               ControlRes^.sShpTable := ControlRes^.sShpTable + sTableName + '.dbf';

               fIniChange := True;
          end;
          Open_ZC_GIS_Form.Free;
     end
     else
         fAcceptLink := True;

     with ZCDDEForm.DdeCmdClient do
     begin
          {ConnectMode := ddeManual;}
          DdeService := 'ZonaeCogito';
          DdeTopic := 'ZCServerConv';

          if OpenLink then
          begin
               ControlRes^.GISLink := ZonaeCogito;

               ZonaeCogitoExecCmd('name ' + ControlRes^.sDatabaseName);
               ZonaeCogitoExecCmd('project ' + ControlRes^.sZCProject);

               sTableName := ExtractFileName(ControlRes^.sShpTable);
               sTableName := Copy(sTableName,1,Length(sTableName)-4);
               sPathName := ExtractFilePath(ControlRes^.sShpTable);

               ZonaeCogitoExecCmd('sourcetable ' + ControlRes^.sDatabase + '\' + ControlRes^.sSiteSummaryTable);
               ZonaeCogitoExecCmd('sourcekey SITEKEY');
               ZonaeCogitoExecCmd('pulayer ' + sPathName + sTableName + '.shp');
               ZonaeCogitoExecCmd('pukey ' + ControlRes^.sShpKeyField);
               ZonaeCogitoExecCmd('redrawmap start');
          end
          else
          begin
               // attempt to launch Zonae Cogito
               // wait for it to initialise
               // attempt to open dde link a second time

               ControlRes^.GISLink := None;

               Screen.Cursor := crDefault;
               MessageDlg('Unable to link to ' +
                          DDeService + ' ' + DdeTopic,
                          mtInformation,[mbOk],0);

               DDE_CloseZonaeCogito;
          end;
     end;
end;


procedure TOptionsForm.LinkGroupClick(Sender: TObject);

   {$IFDEF ARCVIEW_DDE}
   procedure CloseArcView;
   begin
        DDE_CloseArcView;

        fIniChange := True;
   end;

   procedure TryOpenArcView;
   begin
        DDE_TryOpenArcView;

        if (ControlRes^.GisLink = ArcView) then
        begin
             fIniChange := True;
             // redisplay here
             ControlForm.IrrepSimon1Click(Sender);
        end
        else
            LinkGroup.ItemIndex := 0;
   end;
   {$ENDIF}
   procedure CloseZonaeCogito;
   begin
        DDE_CloseZonaeCogito;

        fIniChange := True;
   end;

   procedure TryOpenZonaeCogito;
   begin
        DDE_TryOpenZonaeCogito;

        if (ControlRes^.GisLink = ZonaeCogito) then
        begin
             fIniChange := True;
             // redisplay here
             ControlForm.IrrepSimon1Click(Sender);
        end
        else
            LinkGroup.ItemIndex := 0;
   end;

begin
     if fStartup then
     begin
          case LinkGroup.ItemIndex of
               0 :
               begin
                    {None}
                    case ControlRes^.GISLink of
                             {$IFDEF ARCVIEW_DDE}
                             ArcView : CloseArcView{close link with ArcView};
                             {$ENDIF}
                             ZonaeCogito : CloseZonaeCogito;
                    end;
                    ControlRes^.GISLink := None;

                    CheckDisplayScheme.Visible := True;
               end;
               {$IFDEF ARCVIEW_DDE}
               1 :
               begin
                    {ArcView}
                    if (ControlRes^.GISLink = ZonaeCogito) then
                    begin
                         CloseZonaeCogito;
                         ControlRes^.GISLink := None;
                    end;

                    {attempt to open link with ArcView}
                    TryOpenArcView;

                    CheckDisplayScheme.Visible := True;
               end;
               {$ENDIF}
               2 :
               begin
                    if (ControlRes^.GISLink = ArcView) then
                    begin
                         CloseArcView;
                         ControlRes^.GISLink := None;
                    end;

                    TryOpenZonaeCogito;

                    CheckDisplayScheme.Visible := not (ControlRes^.GISLink = ZonaeCogito);
               end;
          end;

          Screen.Cursor := crDefault;
     end;
end;

procedure TOptionsForm.ckShowExtraToolsClick(Sender: TObject);
var
   fOriginal : boolean;
   iTabIndex : integer;
begin
     if not fStartingOptionsForm then
     begin
          fOriginal := ControlRes^.fShowExtraTools;
          ControlRes^.fShowExtraTools := ckShowExtraTools.Checked;
          ControlForm.TryShowExtraTools;
          CheckExtraSumirrVars.Enabled := ControlRes^.fShowExtraTools;

          if not ControlRes^.fShowExtraTools
          and (fOriginal) then
              // user has switched off extra tools
              try
                 TabSet1.Tabs.Delete(4); // remove validate page
              except
              end
          else
              // user has switched on extra tools
              try
                 iTabIndex := Tabset1.TabIndex;
                 TabSet1.Tabs := Notebook1.Pages;
                 TabSet1.Tabs.Delete(6);
                 TabSet1.Tabs.Delete(5);
                 TabSet1.TabIndex := iTabIndex;
              except
              end;
     end;
end;

procedure TOptionsForm.ckStayOnTopClick(Sender: TObject);
begin
     ControlRes^.fStayOnTop := ckStayOnTop.Checked;

     if ControlRes^.fStayOnTop then
     begin
          ControlForm.FormStyle := fsStayOnTop;
          if ControlRes^.fToolView then
             ToolForm.FormStyle := fsStayOnTop;
     end
     else
     begin
          ControlForm.FormStyle := fsNormal;
          if ControlRes^.fToolView then
             ToolForm.FormStyle := fsNormal;
     end;

     fIniChange := True;
end;

procedure TOptionsForm.CheckInitDispClick(Sender: TObject);
begin
     ControlRes^.fInitialiseGIS := CheckInitDisp.Checked;

     fIniChange := True;
end;

procedure GenerateIterationReports;
var
   sReportDirectory : string;
   fValidateIteration, fSparseMatrixRpt : boolean;
begin
     try
        if ControlRes^.fValidateMode then
        begin
             Screen.Cursor := crHourglass;

             Inc(ControlRes^.iSelectIterationCount);

             // determine if we need to validate this iteration
                fValidateIteration := True;
                if fValidateIterationsCreated then
                begin
                     if (ControlRes^.iSelectIterationCount < 1) then
                        fValidateIteration := True
                     else
                     begin
                          if (ControlRes^.iSelectIterationCount <= ValidateIterations.lMaxSize) then
                             ValidateIterations.rtnValue(ControlRes^.iSelectIterationCount,@fValidateIteration)
                          else
                              fValidateIteration := False;
                     end;
                end;

             if fValidateIteration then
             begin
                  // produce validation reports for the current validation iteration
                  sReportDirectory := ControlRes^.sWorkingDirectory + '\' + IntToStr(ControlRes^.iSelectIterationCount);
                  // generate starting validate reports in working dir\0\.
                  ForceDirectories(sReportDirectory);
                  // generate feature report
                  ReportFeatures(sReportDirectory + '\features' + IntToStr(ControlRes^.iSelectIterationCount) + '.csv', // output file name
                                 'validation',         // report description
                                 False,                // do not test if file exists
                                 ControlForm.UseFeatCutOffs.Checked, // use imported target
                                 FeatArr,              // feature array
                                 iFeatureCount,        // number of features
                                 rPercentage,          // percentage target for features
                                 ''                    // use default feature report
                                 );
                  if ControlRes^.fGenerateCompRpt then
                  begin
                       // generate sparse matrix report
                       // if minset is running then
                       //    if no complementarity
                       //       do not produce this file
                       fSparseMatrixRpt := True;
                       if ControlRes^.fMinsetIsRunning then
                          if not MinsetExpertForm.CheckEnableComplementarity.Checked then
                             fSparseMatrixRpt := False;

                       if fSparseMatrixRpt then
                          SparseMatrixRpt(sReportDirectory + '\debugmatrix' + IntToStr(ControlRes^.iSelectIterationCount) + '.csv',    // first file
                                          '',                  // second file
                                          False,               // do not test if file exists
                                          False,               // do not use 2 file method, ie, use 1 file method
                                          False,True,True,True // use the last 3 of the 4 available data fields in this matrix
                                          );
                       // generate site report
                       ReportSites(sReportDirectory + '\sites' + IntToStr(ControlRes^.iSelectIterationCount) + '.csv', // output file name
                                   'validation',         // report description
                                   False,                // do not test if file exists
                                   ControlForm.OutTable, // site table
                                   iSiteCount,           // number of sites
                                   SiteArr,              // site array
                                   ControlRes,           // cplan options
                                   ''                    // use default site report
                                   );
                       // generate log for selections up to date
                       ReportExcDefLog(sReportDirectory + '\log' + IntToStr(ControlRes^.iSelectIterationCount) + '.csv');
                       // generate sumirr weightings debug file
                       DebugSumirrWeightings(ControlRes^.iSelectIterationCount);
                  end;
             end;

             Screen.Cursor := crDefault;
        end;

     except
           Screen.Cursor := crDefault;
     end;
end;

procedure GenerateDebugReports(const sDir : string);
begin
     try
        Screen.Cursor := crHourglass;

        // generate validate reports in sDir
        ForceDirectories(sDir);
        // generate feature report
        ReportFeatures(sDir + '\features.csv', // output file name
                       'exception debug',   // report description
                       False,                // do not test if file exists
                       ControlForm.UseFeatCutOffs.Checked, // use imported target
                       FeatArr,              // feature array
                       iFeatureCount,        // number of features
                       rPercentage,          // percentage target for features
                       ''                    // use default feature report
                       );
        // generate site report
        ReportSites(sDir + '\sites.csv', // output file name
                    'exception debug',   // report description
                    False,                // do not test if file exists
                    ControlForm.OutTable, // site table
                    iSiteCount,           // number of sites
                    SiteArr,              // site array
                    ControlRes,           // cplan options
                    ''                    // use default site report
                    );
        // generate sparse matrix report
        SparseMatrixRpt(sDir + '\debugmatrix.csv',    // first file
                        '',                  // second file
                        False,               // do not test if file exists
                        False,               // do not use 2 file method, ie, use 1 file method
                        True,True,True,True // use the last 3 of the 4 available data fields in this matrix
                        );
        // generate log for selections up to date
        ReportExcDefLog(sDir + '\log.csv');
        // generate sumirr weightings debug file
        DumpSumirrWeightings(sDir);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
     end;
end;

procedure GenerateStartReports;
begin
     try
        Screen.Cursor := crHourglass;

        ControlRes^.iSelectIterationCount := 0;

        // generate starting validate reports in working dir\0\.
        ForceDirectories(ControlRes^.sWorkingDirectory + '\0');
        // generate site report
        ReportSites(ControlRes^.sWorkingDirectory + '\0\sites0.csv', // output file name
                    'start validation',   // report description
                    False,                // do not test if file exists
                    ControlForm.OutTable, // site table
                    iSiteCount,           // number of sites
                    SiteArr,              // site array
                    ControlRes,           // cplan options
                    ''                    // use default site report
                    );
        // generate feature report
        ReportFeatures(ControlRes^.sWorkingDirectory + '\0\features0.csv', // output file name
                       'start validation',   // report description
                       False,                // do not test if file exists
                       ControlForm.UseFeatCutOffs.Checked, // use imported target
                       FeatArr,              // feature array
                       iFeatureCount,        // number of features
                       rPercentage,          // percentage target for features
                       ''                    // use default feature report
                       );
        // generate sparse matrix report
        SparseMatrixRpt(ControlRes^.sWorkingDirectory + '\0\debugmatrix0.csv',    // first file
                        '',                 // second file
                        False,              // do not test if file exists
                        False,              // do not use 2 file method, ie, use 1 file method
                        True,True,True,True // use all 4 data fields in this matrix
                        );
        // generate sumirr weightings report
        DebugSumirrWeightings(0);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
     end;
end;

procedure TOptionsForm.CheckUseValidationModeClick(Sender: TObject);
begin
     ControlRes^.fValidateMode := CheckUseValidationMode.Checked;

     if CheckUseValidationMode.Checked then
     begin
          RunIrrBeforeRpt.Enabled := True;
          CheckCompRpt.Enabled := True;
          CheckCompRpt.Checked := True;

          if not fStartForm then
          begin
               // we must now automatically generate the starting reports
               // 1) prompt work dir
               ControlForm.SetWorkingDirectory1Click(Sender);
               // 2) generate start reports
               GenerateStartReports;
               // 3) ask user for file specifying which iterations to validate for
               UserSelectValidateFile;
          end;
     end
     else
     begin
          RunIrrBeforeRpt.Enabled := False;
          CheckCompRpt.Enabled := False;
     end;
end;

procedure TOptionsForm.RunIrrBeforeRptClick(Sender: TObject);
begin
     ControlRes^.fRunIrrBefRpt := RunIrrBeforeRpt.Checked;
end;

procedure TOptionsForm.CheckCompRptClick(Sender: TObject);
begin
     ControlRes^.fGenerateCompRpt := CheckCompRpt.Checked;
end;

procedure TOptionsForm.CheckValidateCombsizeClick(Sender: TObject);
begin
     ControlRes^.fValidateCombsize := CheckValidateCombsize.Checked;
end;

procedure TOptionsForm.RadioDisplayValuesClick(Sender: TObject);
var
   wDlgResult : word;
begin
     if (ControlRes^.iDisplayValuesFor <> RadioDisplayValues.ItemIndex) then
     begin
          ControlRes^.iDisplayValuesFor := RadioDisplayValues.ItemIndex;

          fIniChange := True;

          if (ControlRes^.GisLink <> None) then
          begin
               if (ControlRes^.iDisplayValuesFor = 0) then
                  wDlgResult := MessageDlg('Redisplay map now',mtConfirmation,[mbYes,mbNo],0)
               else
                   wDlgResult := MessageDlg('                Redisplay map now ?' + Chr(10) + Chr(13) +
                                            '' + Chr(10) + Chr(13) +
                                            'Note: Irreplaceability values shown in this mode' + Chr(10) + Chr(13) +
                                            'are for single de-selection only.  Irreplaceability' + Chr(10) + Chr(13) +
                                            'will have to be recalculated for each de-selection' + Chr(10) + Chr(13) +
                                            'for the site indices to be current.',
                                            mtConfirmation,[mbYes,mbNo],0);

               if (mrYes = wDlgResult) then
               begin
                    {we are linked to a GIS and user has indicated they want to redisplay with the new
                     'Display Values For' setting}

                    if fContrDataDone then
                    begin
                         if ControlRes^.fFeatureClassesApplied then
                            MapMemoryVariable2Display(ControlRes^.iGISPlotField,SubsetGroup.ItemIndex,
                                                      ControlRes^.iDisplayValuesFor, {option for display Available/Deferred}
                                                      5, {divide middle values into 5 categories}
                                                      SiteArr, iSiteCount,
                                                      iIr1Count, i001Count, i002Count,
                                                      i003Count, i004Count, i005Count,
                                                      i0CoCount)
                         else
                             MapMemoryVariable2Display(ControlRes^.iGISPlotField,0,
                                                       ControlRes^.iDisplayValuesFor, {option for display Available/Deferred}
                                                       5, {divide middle values into 5 categories}
                                                       SiteArr, iSiteCount,
                                                       iIr1Count, i001Count, i002Count,
                                                       i003Count, i004Count, i005Count,
                                                       i0CoCount);

                         ControlForm.UpdateDatabase(True);
                         ControlForm.InformGIS;
                    end
                    else
                        ExecuteIrreplaceability(-1,False,False,True,True,'');
               end;
          end;
     end;
end;

procedure TOptionsForm.CheckValidateIrreplaceabilityClick(Sender: TObject);
begin
     ControlRes^.fValidateIrreplaceability := CheckValidateIrreplaceability.Checked;
end;

procedure TOptionsForm.CheckReportTimeClick(Sender: TObject);
begin
     //ControlRes^.fReportTime := CheckReportTime.Checked;
     ControlRes^.fReportTime := False;
end;

procedure TOptionsForm.SelectMapGroupClick(Sender: TObject);
begin
     ControlRes^.iSelectMapSites := SelectMapGroup.ItemIndex;

     if (SelectMapGroup.ItemIndex = 1) then
        CheckZoom.Enabled := False
     else
         CheckZoom.Enabled := True;

     fIniChange := True;
end;

procedure TOptionsForm.CheckZoomClick(Sender: TObject);
begin
     ControlRes^.fZoomOnSelect := CheckZoom.Checked;

     fIniChange := True;
end;

procedure TOptionsForm.RedisplayIt(const fAskUser : boolean);
var
   fReDisplay : boolean;
begin
     if (not ControlRes^.fOptionCreate) then
     try
        Screen.Cursor := crHourglass;

        if (OptPlotGroup.ItemIndex = 1) then
        begin
             GroupBox1.Visible := True;
             CheckWeightArea.Visible := True;
             CheckWeightTarget.Visible := True;
             CheckWeightVuln.Visible := True;
             CheckDisplayAbsSumirr.Visible := True;
        end
        else
        begin
             GroupBox1.Visible := False;
             CheckWeightArea.Visible := False;
             CheckWeightTarget.Visible := False;
             CheckWeightVuln.Visible := False;
             CheckDisplayAbsSumirr.Visible := False;
        end;

        //ControlRes^.iGISPlotField := OptPlotGroup.ItemIndex;
        ControlForm.SubsetGroup.ItemIndex := SubsetGroup.ItemIndex;

        //if (ControlRes^.GISLink = ArcView) then
        begin
             if fAskUser then
             begin
                  if (ControlRes^.GISLink = ArcView) then
                     fReDisplay := (mrYes = MessageDlg('Redisplay map now',mtConfirmation,[mbYes,mbNo],0))
                  else
                      fReDisplay := True;
             end
             else
                 fReDisplay := True;

             if fReDisplay then //(mrYes = MessageDlg('Redisplay map now',mtConfirmation,[mbYes,mbNo],0)) then
             begin
                  if fContrDataDone then
                  begin
                       if ControlRes^.fFeatureClassesApplied then
                           MapMemoryVariable2Display(ControlRes^.iGISPlotField,SubsetGroup.ItemIndex,
                                                     ControlRes^.iDisplayValuesFor, {option for display Available/Deferred}
                                                     5, {divide middle values into 5 categories}
                                                     SiteArr, iSiteCount,
                                                     iIr1Count, i001Count, i002Count,
                                                     i003Count, i004Count, i005Count,
                                                     i0CoCount)
                       else
                           MapMemoryVariable2Display(ControlRes^.iGISPlotField,0,
                                                     ControlRes^.iDisplayValuesFor, {option for display Available/Deferred}
                                                     5, {divide middle values into 5 categories}
                                                     SiteArr, iSiteCount,
                                                     iIr1Count, i001Count, i002Count,
                                                     i003Count, i004Count, i005Count,
                                                     i0CoCount);

                       //ControlForm.UpdateDatabase(True);
                       ControlForm.RefreshGIS;
                       if (ControlRes^.GISLink = ArcView) or (ControlRes^.GISLink = ZonaeCogito) then
                          ControlForm.InformGIS;
                  end
                  else
                      ExecuteIrreplaceability(-1,False,False,True,True,'');
             end;
        end;

        if (OptPlotGroup.ItemIndex = 2)
        or (OptPlotGroup.ItemIndex = 3) then
           {plotting Wavirr of PCUsed}
           UsingSubsetWAV(True)
        else
            UsingSubsetWAV(False);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RedisplayIt',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TOptionsForm.CheckWeightAreaClick(Sender: TObject);
begin
     ControlRes^.fSumirrWeightArea := CheckWeightArea.Checked;
     RedisplayIt(True);
     fIniChange := True;
end;

procedure TOptionsForm.CheckWeightTargetClick(Sender: TObject);
begin
     ControlRes^.fSumirrWeightTarget := CheckWeightTarget.Checked;
     RedisplayIt(True);
     fIniChange := True;
end;

procedure TOptionsForm.CheckWeightVulnClick(Sender: TObject);
begin
     ControlRes^.fSumirrWeightVuln := CheckWeightVuln.Checked;
     RedisplayIt(True);
     fIniChange := True;
end;

procedure TOptionsForm.SubsetGroupClick(Sender: TObject);
begin
     RedisplayIt(True);
end;

procedure TOptionsForm.CheckDebugSPATTOOLClick(Sender: TObject);
begin
     ControlRes^.fDebugSPATTOOL := CheckDebugSPATTOOL.Checked;
end;

procedure TOptionsForm.VariableToPassClick(Sender: TObject);
var
   iIndex : integer;
begin
     iIndex := VariableToPass.Items.IndexOf(VariableToPass.Text);
     if (iIndex >= 0) then
     begin
          ControlRes^.iSpatialVariableToPass := iIndex;
          ControlRes^.sSpatialVariableToPass := VariableToPass.Items.Strings[iIndex];
          fIniChange := True;
     end;
end;

procedure TOptionsForm.CheckRecalcContribClick(Sender: TObject);
begin
     ControlRes^.fRecalcContrib := CheckRecalcContrib.Checked;
     fIniChange := True;
end;

procedure TOptionsForm.EditResWeightKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
   rValue : extended;
begin
     try
        rValue := RegionSafeStrToFloat(EditResWeight.Text);
        ControlRes^.rSpatContribReservedWeight := rValue;
        fIniChange := True;
     except
     end;
end;

procedure TOptionsForm.CheckConnectSpattoolMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     ControlRes^.fConnectSPATTOOL := CheckConnectSpattool.Checked;
     fIniChange := True;
end;

procedure TOptionsForm.CheckDbgLookupClick(Sender: TObject);
begin
     ControlRes^.fDebugLookup := CheckDbgLookup.Checked;
end;

procedure TOptionsForm.RadioCombTypeClick(Sender: TObject);
var
   iCombinationSize : integer;
begin
     if not fStartForm then
     begin
          case RadioCombType.ItemIndex of
               0 : // original
                   begin
                        iCombinationSize := combsize.iSelectedCombinationSize -
                                            (ControlForm.R1.Items.Count +
                                             ControlForm.R2.Items.Count +
                                             ControlForm.R3.Items.Count +
                                             ControlForm.R4.Items.Count +
                                             ControlForm.R5.Items.Count);

                        ControlRes^.fCustomCombSize := False;
                        AppendCombsizeLog('user select original');

                        btnTest.Enabled := False;
                   end;
               1 : // custom
                   begin
                        if ControlRes^.fLockUserDefinedCombinationSize then
                           iCombinationSize := combsize.iCustomCombinationSize
                        else
                        begin
                             if ControlRes^.fSuppressCSExclusionRecalc then
                                iCombinationSize := combsize.iCustomCombinationSize -
                                                               ControlForm.R1.Items.Count -
                                                               ControlForm.R2.Items.Count -
                                                               ControlForm.R3.Items.Count -
                                                               ControlForm.R4.Items.Count -
                                                               ControlForm.R5.Items.Count -
                                                               ControlForm.Excluded.Items.Count -
                                                               ControlForm.Partial.Items.Count
                             else
                                 iCombinationSize := combsize.iCustomCombinationSize -
                                                               ControlForm.R1.Items.Count -
                                                               ControlForm.R2.Items.Count -
                                                               ControlForm.R3.Items.Count -
                                                               ControlForm.R4.Items.Count -
                                                               ControlForm.R5.Items.Count -
                                                               ControlForm.Partial.Items.Count;
                        end;
                        ControlRes^.fCustomCombSize := True;
                        AppendCombsizeLog('user select custom');

                        btnTest.Enabled := True;
                   end;
          end;
          if (iCombinationSize < 2) then
             EditCombSize.Text := 'less than 2'
          else
              EditCombSize.Text := IntToStr(iCombinationSize);
     end;
end;

procedure TOptionsForm.SpinCombSizeChange(Sender: TObject);
begin
     if not fStartForm then
     begin
          combsize.iCustomCombinationSize := SpinCombSize.Value;
          if (RadioCombType.ItemIndex = 1) then
             RadioCombTypeClick(Sender);

          SaveCustomCombSize;

          AppendCombsizeLog('user change custom');
     end;
end;

procedure TOptionsForm.CheckDisplayAbsSumirrClick(Sender: TObject);
begin
     if (ControlRes^.fDisplayAbsSumirr <> CheckDisplayAbsSumirr.Checked) then
     begin
          ControlRes^.fDisplayAbsSumirr := CheckDisplayAbsSumirr.Checked;
          RedisplayIt(True);
          fIniChange := True;
     end;
end;

procedure TOptionsForm.CheckDisplaySchemeClick(Sender: TObject);
begin
     if (ControlRes^.iDisplayScheme <> CheckDisplayScheme.ItemIndex) then
     begin
          ControlRes^.iDisplayScheme := CheckDisplayScheme.ItemIndex;
          RedisplayIt(True);
          fIniChange := True;
     end;
end;

procedure TOptionsForm.CheckExtraSumirrVarsClick(Sender: TObject);
begin
     ControlRes^.fCalculateBobsExtraVariations := CheckExtraSumirrVars.Checked;
     ControlRes^.fCalculateAllVariations := ControlRes^.fCalculateBobsExtraVariations;
     fIniChange := True;

     if CheckExtraSumirrVars.Enabled then
     begin
          if CheckExtraSumirrVars.Checked then
             InitMinsetSumirrWeightings
          else
              FreeMinsetSumirrWeightings;
     end;
end;

procedure TOptionsForm.CheckLogCombsizeClick(Sender: TObject);
begin
     fIniChange := True;
     ControlRes^.fLogCombsizeRecalc := CheckLogCombsize.Checked;
end;

procedure TOptionsForm.RadioScaleTypeClick(Sender: TObject);
begin
     if not fStartForm then
     begin
          ControlRes^.iScalingtype := RadioScaleType.ItemIndex;
          fIniChange := True;
     end;
end;

procedure TOptionsForm.RadioVulnTypeClick(Sender: TObject);
begin
     if not fStartForm then
     begin
          ControlRes^.iVulnWeightingType := RadioVulnType.ItemIndex;
          fIniChange := True;
     end;
end;

procedure TOptionsForm.CheckUpdateGISValuesClick(Sender: TObject);
begin
     ControlRes^.fUpdateGISValues := CheckUpdateGISValues.Checked;
     fIniChange := True;
     RedisplayIt(True);
end;

procedure TOptionsForm.CheckPartialValidateCombsizeClick(Sender: TObject);
begin
     ControlRes^.fPartialValidateCombsize := CheckPartialValidateCombsize.Checked;
     fIniChange := True;
     if ControlRes^.fPartialValidateCombsize then
        InitCombsizeRecord;
end;

procedure TOptionsForm.btnOverrideClick(Sender: TObject);
begin
     if (RadioCombType.ItemIndex = 0) then
     begin
          OverrideCombsizeForm := TOverrideCombsizeForm.Create(Application);
          OverrideCombsizeForm.ShowModal;
          OverrideCombsizeForm.Free;
          
          EditOriginal.Text := IntToStr(combsize.iSelectedCombinationSize);
          RadioCombTypeClick(Sender);
     end;
end;

procedure TOptionsForm.CheckLockCombsizeClick(Sender: TObject);
begin
     if not fStartForm then
     begin
          ControlRes^.fLockUserDefinedCombinationSize := CheckLockCombsize.Checked;
          RadioCombTypeClick(Sender);
     end;
end;

procedure TOptionsForm.CheckValidateMinsetClick(Sender: TObject);
begin
     if not fStartForm then
        ControlRes^.fValidateMinset := CheckValidateMinset.Checked;
end;

procedure TOptionsForm.btnReLinkClick(Sender: TObject);
var
   AIni : TIniFile;
begin
     if (LinkGroup.ItemIndex = 1) then
     begin
          // remove the [ArcView] section of the cplan.ini file
          AIni := TIniFile.Create(ControlRes^.sDatabase + '\cplan.ini');
          AIni.EraseSection('ArcView');
          AIni.Free;

          LinkGroup.ItemIndex := 0;
          LinkGroup.ItemIndex := 1;
     end;
     if (LinkGroup.ItemIndex = 2) then
     begin
          AIni := TIniFile.Create(ControlRes^.sDatabase + '\cplan.ini');
          AIni.EraseSection('ZonaeCogito');
          AIni.Free;

          LinkGroup.ItemIndex := 0;
          LinkGroup.ItemIndex := 2;
     end;
end;

procedure TOptionsForm.CheckEnglishGISClick(Sender: TObject);
begin
     if not fStartForm then
     begin
          ControlRes^.fGISRegionalSettingIsEnglish := CheckEnglishGIS.Checked;
          RedisplayIt(True);
          fIniChange := True;
     end;
end;

procedure TOptionsForm.EditRadiusChange(Sender: TObject);
var
   iValue : integer;
begin
     if not fStartForm then
     try
        iValue := StrToInt(EditRadius.Text);
        if (iValue > 0) then
        begin
             ControlRes^.iSpatialContribRadius := iValue;
             fIniChange := True;
        end;

     except
     end;
end;

procedure TOptionsForm.EditExponentChange(Sender: TObject);
var
   rValue : extended;
begin
     if not fStartForm then
     try
        rValue := RegionSafeStrToFloat(EditExponent.Text);
        if (rValue > 0) then
        begin
             ControlRes^.rSpatialContribExponent := rValue;
             fIniChange := True;
        end;
     except
     end;
end;

procedure TOptionsForm.btnUpdateClick(Sender: TObject);
begin
     RedisplayIt(False);
end;

procedure TOptionsForm.btnRadiusClick(Sender: TObject);
begin
     SpatIOModule.SendRadiusRequest;
end;

procedure TOptionsForm.btnExponentClick(Sender: TObject);
begin
     SpatIOModule.SendExponentRequest;
end;

procedure TOptionsForm.CheckSuppressCSExclusionRecalcClick(
  Sender: TObject);
begin
     if not fStartForm then
     begin
          ControlRes^.fSuppressCSExclusionRecalc := CheckSuppressCSExclusionRecalc.Checked;
          fIniChange := True;
     end;
end;

procedure TOptionsForm.CheckDisplayCSTriggerPopupClick(Sender: TObject);
begin
     if not fStartForm then
     begin
          ControlRes^.fDisplayCSTriggerPopup := CheckDisplayCSTriggerPopup.Checked;
          fIniChange := True;
     end;
end;

procedure TOptionsForm.btnTestClick(Sender: TObject);
begin
     ControlForm.IrrepSimon1Click(Sender);
     // update SpinCombSize
     fStartForm := True;
     SpinCombSize.Value := combsize.iCustomCombinationSize;
     fStartForm := False;
     RadioCombTypeClick(Sender);
end;

procedure TOptionsForm.CheckSuppressTXTDBFlogClick(Sender: TObject);
begin
     if not fStartForm then
     begin
          ControlRes^.fGenerate_TXT_DBF_log := not CheckSuppressTXTDBFlog.Checked;
          fIniChange := True;
     end;
end;

initialization

end.
