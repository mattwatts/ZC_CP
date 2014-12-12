unit Toolview;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, StdCtrls;

type
  TToolForm = class(TForm)
    sbIrrep: TSpeedButton;
    sbAccept: TSpeedButton;
    sbToggle: TSpeedButton;
    sbCycle: TSpeedButton;
    a: TButton;
    i: TButton;
    t: TButton;
    c: TButton;
    sbReturn: TSpeedButton;
    r: TButton;
    sbRestTarg: TSpeedButton;
    sbPartDef: TSpeedButton;
    sbStageMemo: TSpeedButton;
    sbSelLog: TSpeedButton;
    sbContrib: TSpeedButton;
    sbRedCheck: TSpeedButton;
    sbSaveAs: TSpeedButton;
    sbSave: TSpeedButton;
    sbBrowse: TSpeedButton;
    sbF2Targ: TSpeedButton;
    sbOpen: TSpeedButton;
    sbToolOpt: TSpeedButton;
    sbShowExit: TSpeedButton;
    e: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure PrepToolForm;
    procedure UpdateCaption;
    procedure aClick(Sender: TObject);
    procedure iClick(Sender: TObject);
    procedure cClick(Sender: TObject);
    procedure rClick(Sender: TObject);
    procedure sbOpenClick(Sender: TObject);
    procedure sbBrowseClick(Sender: TObject);
    procedure sbSaveClick(Sender: TObject);
    procedure sbSaveAsClick(Sender: TObject);
    procedure sbF2TargClick(Sender: TObject);
    procedure sbContribClick(Sender: TObject);
    procedure sbSelLogClick(Sender: TObject);
    procedure sbStageMemoClick(Sender: TObject);
    procedure sbPartDefClick(Sender: TObject);
    procedure sbRestTargClick(Sender: TObject);
    procedure sbToolOptClick(Sender: TObject);
    procedure sbShowExitClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ToolForm: TToolForm;

implementation

uses
    Control, IniFiles, Editstr, Options,
    Global;

{$R *.DFM}

procedure TToolForm.UpdateCaption;
begin
     Caption := ControlForm.Caption;
end;

procedure TToolForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     ControlRes^.fToolView := False;
     ControlForm.Visible := True;
end;

procedure TToolForm.PrepToolForm;
var
   iToolWidth : integer;

   procedure IsButton(fFlag : boolean;
                      ASpeedButton : TSpeedButton);
   begin
        if fFlag then
        begin
             ASpeedButton.Visible := True;
             ASpeedButton.Left := iToolWidth;
             Inc(iToolWidth,ASpeedButton.Width);
        end
        else
            ASpeedButton.Visible := False;
   end;

   procedure PutSpace;
   begin
        Inc(iToolWidth,5);
   end;


begin
     ClientHeight := sbIrrep.Height;
     Caption := ControlForm.Caption;

     ShowHint := ControlRes^.fShowPopUp;

     iToolWidth := 0;

     IsButton(ControlRes^.fShowOpen,sbOpen);
     IsButton(ControlRes^.fShowBrowse,sbBrowse);
     IsButton(ControlRes^.fShowSave,sbSave);
     IsButton(ControlRes^.fShowSaveAs,sbSaveAs);

     if ControlRes^.fShowOpen
     or ControlRes^.fShowBrowse
     or ControlRes^.fShowSave
     or ControlRes^.fShowSaveAs then
        PutSpace;

     IsButton(ControlRes^.fShowIrrep,sbIrrep);
     IsButton(ControlRes^.fShowAccept,sbAccept);
     IsButton(ControlRes^.fShowToggle,sbToggle);
     IsButton(ControlRes^.fShowCycle,sbCycle);

     if ControlRes^.fShowIrrep
     or ControlRes^.fShowAccept
     or ControlRes^.fShowToggle
     or ControlRes^.fShowCycle then
        PutSpace;

     IsButton(ControlRes^.fShowContrib,sbContrib);
     IsButton(ControlRes^.fShowF2Targ,sbF2Targ);
     IsButton(ControlRes^.fShowPartDef,sbPartDef);
     IsButton(ControlRes^.fShowRestTarg,sbRestTarg);

     if ControlRes^.fShowContrib
     or ControlRes^.fShowF2Targ
     or ControlRes^.fShowPartDef
     or ControlRes^.fShowRestTarg then
        PutSpace;

     {IsButton(ControlRes^.fShowStageMemo,sbStageMemo);
     IsButton(ControlRes^.fShowRedCheck,sbRedCheck);}

     IsButton(ControlRes^.fShowSelLog,sbSelLog);
     IsButton(TRUE,sbToolOpt);
     IsButton(TRUE,sbReturn);
     IsButton(ControlRes^.fShowExit,sbShowExit);

     ClientWidth := iToolWidth;

     sbCycle.Hint := 'Cycle ' + ControlForm.ClickGroup.Items[
                                  ControlForm.ClickGroup.ItemIndex];
end;

procedure TToolForm.FormCreate(Sender: TObject);
begin
     {if ControlRes^.fPersistTool then
       LoadFormState(ToolForm,ControlRes^.sDatabase + '\' + PERSIST_TOOL_FILE);}

     PrepToolForm;
end;

procedure TToolForm.aClick(Sender: TObject);
begin
     ControlForm.btnAcceptClick(self);
end;

procedure TToolForm.iClick(Sender: TObject);
begin
     ControlForm.IrrepSimon1Click(self);
end;

procedure TToolForm.cClick(Sender: TObject);
begin
     ControlForm.btnCycleClick(self);
     UpdateCaption;
     {sbCycle.Hint := 'Cycle ' + ControlForm.ClickGroup.Items[
                                  ControlForm.ClickGroup.ItemIndex];}
end;

procedure TToolForm.rClick(Sender: TObject);
begin
     {ModalResult := mrOk;
     ControlForm.Visible := True;
     ControlRes^.fToolView := False;
     Free;}

     Close;
end;

procedure TToolForm.sbOpenClick(Sender: TObject);
begin
     ControlForm.Open1Click(self);
end;

procedure TToolForm.sbBrowseClick(Sender: TObject);
begin
     ControlForm.Browse1Click(self);
end;

procedure TToolForm.sbSaveClick(Sender: TObject);
begin
     ControlForm.SaveNoParam(self);
end;

procedure TToolForm.sbSaveAsClick(Sender: TObject);
begin
     ControlForm.SaveAsNoClick(self);
end;

procedure TToolForm.sbF2TargClick(Sender: TObject);
begin
     ControlForm.FeaturesToTarget1Click(self);
end;

procedure TToolForm.sbContribClick(Sender: TObject);
begin
     ControlForm.Contribution1Click(self);
end;

procedure TToolForm.sbSelLogClick(Sender: TObject);
begin
     ControlForm.Reasoning1Click(self);
end;

procedure TToolForm.sbStageMemoClick(Sender: TObject);
begin
     EditViewStageMemo;
end;

procedure TToolForm.sbPartDefClick(Sender: TObject);
begin
     ControlForm.PartialDeferral1Click(self);
end;

procedure TToolForm.sbRestTargClick(Sender: TObject);
begin
     ControlForm.RestrictTargets1Click(self);
end;

procedure TToolForm.sbToolOptClick(Sender: TObject);
begin
     {try
        OptionsForm := TOptionsForm.Create(Application);

        //OptionsForm.TabSet1.TabIndex := 3;
        OptionsForm.ShowModal;

     finally
            OptionsForm.Free;
     end;}

     PrepToolForm;
end;

procedure TToolForm.sbShowExitClick(Sender: TObject);
begin
     ControlForm.Exit1Click(Self);
end;

procedure TToolForm.FormDestroy(Sender: TObject);
begin
  {SaveFormState(ToolForm,ControlRes^.sDatabase + '\' + PERSIST_TOOL_FILE);}
end;

end.
