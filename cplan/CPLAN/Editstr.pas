unit Editstr;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Global;


type
  TEditStrForm = class(TForm)
    ReasonMemo: TMemo;
    Panel1: TPanel;
    btnOK: TBitBtn;
    btnPaste: TButton;
    btnCancel: TBitBtn;
    btnBrowse: TButton;
    Button1: TButton;
    ComboStage: TComboBox;
    Label1: TLabel;
    procedure btnPasteClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HideStageSelect;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function EditReason(const sType : string;
                    const SourceStatus, DestStatus : status_t;
                    const fShowStageSelect : boolean) : boolean;

function GetCombineChoice(const iNumChoices, iCurrChoice : integer) : integer;

procedure EditViewStageMemo;

function BrowseSelectionMemo(const sFile : string) : word;

function RptDescribe(const sRptType : string) : string;
function SaveEditStageMemo(sFileName : string) : boolean;
procedure AutoSelectReason(const sType : string);



var
  EditStrForm: TEditStrForm;
  sSiteStatus, sRptStr : string;
  wLocalFlag, wResult : word;
  iLocalMax, iLocalCurr, iLocalChoice : integer;
  fMoveOk : boolean;

implementation

{$R *.DFM}

uses Choices, Control, Dll_u1, In_Order,
     validate;

procedure TEditStrForm.HideStageSelect;
begin
     {}

     ComboStage.Visible := False;
     Label1.Visible := False;
     Panel1.Height := 41; {73}
end;

function BrowseSelectionMemo(const sFile : string) : word;
begin
     wLocalFlag := BROWSE_EMS;

     EditStrForm := TEditStrForm.Create(Application);

     with EditStrForm do
     begin
          try
             HideStageSelect;
             btnBrowse.Visible := True;
             btnPaste.Visible := False;
             ReasonMemo.ReadOnly := True;

             BrowseSelection(sFile);
             ReasonMemo.Lines := ControlForm.BrowseEMSReason.Items;

             Caption := 'Stage Memo for ' + sFile;
             Screen.Cursor := crDefault;

             wResult := RESULT_CANCEL;

             EditStrForm.ShowModal;

          finally
                 EditStrForm.Free;
          end;
     end;

     Result := wResult;
end;

function RptDescribe(const sRptType : string) : string;
begin
     wLocalFlag := RPT_DESCRIBE;

     EditStrForm := TEditStrForm.Create(Application);

     with EditStrForm do
     begin
          try
             Caption := 'Enter Description for ' + sRptType + ' Report';

             Screen.Cursor := crDefault;

             ReasonMemo.Lines.Clear {:= ControlForm.EMSReason.Items};

             EditStrForm.ShowModal;

          finally
                 EditStrForm.Free;
          end;

          Result := sRptStr;
     end;
end;

procedure EditViewStageMemo;
begin
     wLocalFlag := VIEW_EDIT_STAGE_MEMO;

     EditStrForm := TEditStrForm.Create(Application);

     with EditStrForm do
     begin
          try
             Caption := 'Edit Stage Memo';
             Panel1.Height := 41;

             Screen.Cursor := crDefault;

             {AddEMSDate;} {adds date if EMSReason is empty}

             {Copy contents of EMSReason to ReasonMemo}
             ReasonMemo.Lines := ControlForm.EMSReason.Items;

             EditStrForm.ShowModal;

          finally
                 EditStrForm.Free;
          end;
     end;
end;

function SaveEditStageMemo(sFileName : string) : boolean;
begin
     wLocalFlag := VIEW_EDIT_STAGE_MEMO;
     Result := True;

     EditStrForm := TEditStrForm.Create(Application);

     with EditStrForm do
     begin
          try
             Caption := 'Edit Stage Memo for ' + sFileName;
             btnCancel.Visible := False;
             panel1.Height := 41;
             Refresh;

             Screen.Cursor := crDefault;

             {AddEMSDate;} {adds date if EMSReason is empty}

             {Copy contents of EMSReason to ReasonMemo}
             ReasonMemo.Lines := ControlForm.EMSReason.Items;

             EditStrForm.ShowModal;

          finally
                 EditStrForm.Free;
          end;
     end;
end;


function GetCombineChoice(const iNumChoices, iCurrChoice : integer) : integer;
var
   wOldCursor : integer;
begin
     wLocalFlag := GET_CHOICE;
     iLocalMax := iNumChoices;
     iLocalCurr := iCurrChoice;

     EditStrForm := TEditStrForm.Create(Application);

     with EditStrForm do
     begin
          try
             wOldCursor := Screen.Cursor;
             Caption := 'Enter choice to combine with choice ' + IntToStr(iCurrChoice);

             Screen.Cursor := crDefault;

             EditStrForm.ShowModal;

          finally
                 EditStrForm.Free;
                 Screen.Cursor := wOldCursor;
          end;
     end;

     Result := iLocalChoice;
end;

procedure AutoSelectReason(const sType : string);
var
   sTime : string;
begin
     {if (ControlRes^.sLastChoiceType = 'SQL Query') then
        ChoiceForm.AddReason(ControlRes^.sSQLQuery);}

     sTime := FormatDateTime('ddd, mmm d, yyyy, hh:mm AM/PM',
                             Now);

     sSiteStatus := sType;

     if (ControlRes^.sLastChoiceType = 'None') then
        ControlRes^.sLastChoiceType := 'Automatic Selection';

     ChoiceForm.AddReason('stage minset iteration ' + IntToStr(iMinsetIterationCount));
     ChoiceForm.AddReason(ControlRes^.sLastChoiceType +
                          ', ' +
                          sSiteStatus +
                          ',' + sTime);
end;

function EditReason(const sType : string;
                    const SourceStatus, DestStatus : status_t;
                    const fShowStageSelect : boolean) : boolean;
var
   iCount : integer;
   wOldCursor : integer;
   sTime : string;
   StageEntry : StageEntry_T;
begin
     {we need to call BuildStageList to get a list of stages for user to
      select from}
     if fStageListCreated then
        StageList.Destroy;
     BuildStageList(StageList);

     sSiteStatus := sType;
     wLocalFlag := EDIT_REASON;
     fMoveOk := True;

     EditStrForm := TEditStrForm.Create(Application);

     with EditStrForm do
     begin
          try
             if not fShowStageSelect then
                HideStageSelect;

             if (StageList.lMaxSize > 0) then
                for iCount := 1 to StageList.lMaxSize do
                begin
                     StageList.rtnValue(iCount,@StageEntry);
                     ComboStage.Items.Add(StageEntry.sStageName);
                end;

             wOldCursor := Screen.Cursor;
             // count how many selections we already have
             Caption := 'Enter reason for selection ' + IntToStr(ChoiceForm.CountExistingSelections+1) + ' (' + Status2StrLong(SourceStatus) +
                        ' to ' + Status2StrLong(DestStatus) + ')';

             Screen.Cursor := crDefault;

             if (ControlRes^.sLastChoiceType = 'SQL Query') then
                ReasonMemo.Lines.Add(ControlRes^.sSQLQuery);

             EditStrForm.ShowModal;

             if (fMoveOk) then
             {the user has not hit Cancel
              fMoveOk set to false by Cancel button click}
             begin
                  sTime := FormatDateTime('ddd, mmm d, yyyy, hh:mm AM/PM',
                                          Now);

                  if (ComboStage.Text = '') then
                     ComboStage.Text := 'no stage specified';

                  ChoiceForm.AddReason('stage ' + ComboStage.Text);

                  ChoiceForm.AddReason(ControlRes^.sLastChoiceType +
                                       ', ' +
                                       sSiteStatus +
                                       ',' + sTime {+ ',' + 'stage ' +
                                       ComboStage.Text} {add here as well so we have a record of
                                                        which stage this selection was
                                                        originally assigned to (in case user
                                                        changes this selection to another stage)}
                                       );

                  if (ReasonMemo.Lines.Count > 0) then
                     for iCount := 0 to (ReasonMemo.Lines.Count-1) do
                           ChoiceForm.AddReason(
                                ReasonMemo.Lines.Strings[iCount])
                  else
                      ChoiceForm.AddReason('no reason specified');
             end;

          finally
                 EditStrForm.Free;
                 Screen.Cursor := wOldCursor;
          end;
     end;

     Result := fMoveOk;
end;

procedure TEditStrForm.btnPasteClick(Sender: TObject);
begin
     ReasonMemo.PasteFromClipboard;
end;

procedure TEditStrForm.btnOKClick(Sender: TObject);
var
   iThisChoice : integer;
begin
     {OK button has been hit}
     case wLocalFlag of
          GET_CHOICE : begin
                            try
                               iThisChoice := StrToInt(ReasonMemo.Text);
                            except on EConvertError do
                                   iThisChoice := 0;
                            end;

                            if (iThisChoice <> iLocalCurr)
                            and (iThisChoice > 0)
                            and (iThisChoice <= iLocalMax) then
                                iLocalChoice := iThisChoice
                            else
                            begin
                                 ModalResult := mrNone;
                                 MessageDlg('Invalid choice, must be in range 1 to '
                                            + IntToStr(iLocalMax)
                                            + ' and not ' + IntToStr(iLocalCurr),
                                            mtInformation,[mbOK],0);
                                 ReasonMemo.Text := '';
                            end;
                       end;
          EDIT_REASON : ;
          BROWSE_EMS : wResult := RESULT_OPEN;
          VIEW_EDIT_STAGE_MEMO :
                   begin
                        if ReasonMemo.Modified then
                           ControlForm.EMSReason.Items := ReasonMemo.Lines;

                        {AddEMSDate;} {adds date if EMSReason is empty}
                   end;
          RPT_DESCRIBE :
                   begin
                        sRptStr := ReasonMemo.Text;
                        if (sRptStr = '') then
                           sRptStr := S_NO_DESCRIPT;
                   end;
     else
         MessageDlg('Unknown flag in Edit String Unit',mtError,[mbOK],0);
     end;
end;

procedure TEditStrForm.btnCancelClick(Sender: TObject);
begin
     {cancel button has been hit}
     case wLocalFlag of
          GET_CHOICE : iLocalChoice := 0;
                        {cancels the combine choice that called this}
          EDIT_REASON : fMoveOk := False;
                       {cancels the MoveGroup instance that called this}
          RPT_DESCRIBE : sRptStr := '';

          BROWSE_EMS : wResult := RESULT_CANCEL;
     else
     end;
end;

procedure TEditStrForm.btnBrowseClick(Sender: TObject);
begin
     wResult := RESULT_BROWSE;
     ModalResult := mrOK;
end;

procedure TEditStrForm.Button1Click(Sender: TObject);
begin
     ReasonMemo.CopyToClipboard;
end;

procedure TEditStrForm.FormCreate(Sender: TObject);
begin
     ClientWidth := btnCancel.Width + btnCancel.Left + btnOK.Left;
end;

end.
