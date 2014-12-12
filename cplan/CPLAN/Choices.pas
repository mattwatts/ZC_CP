unit Choices;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Clipbrd, Menus, Global,
  Dll_u1, ds;


type
  TChoiceForm = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    btnCopy: TButton;
    btnFont: TButton;
    ChoiceFont: TFontDialog;
    ReasonMemo: TMemo;
    SitesBox: TListBox;
    btnPrev: TButton;
    btnNext: TButton;
    Label1: TLabel;
    Label2: TLabel;
    txtCurrChoice: TLabel;
    txtNumChoices: TLabel;
    btnPrevFew: TButton;
    btnNextFew: TButton;
    btnRemove: TButton;
    btnPaste: TButton;
    txtSiteCount: TLabel;
    MainMenu1: TMainMenu;
    Sites1: TMenuItem;
    Copy1: TMenuItem;
    Remove1: TMenuItem;
    Combine1: TMenuItem;
    Split1: TMenuItem;
    N1: TMenuItem;
    Copy2: TMenuItem;
    Cut1: TMenuItem;
    Paste2: TMenuItem;
    ChoiceLog: TListBox;
    FindString: TFindDialog;
    Search1: TMenuItem;
    Search2: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    btnTestSSS: TButton;
    SelectAll1: TMenuItem;
    btnPrevMany: TButton;
    btnNextMany: TButton;
    btnDelChoice: TButton;
    Label3: TLabel;
    ComboStage: TComboBox;
    function AddCode(const cChoiceCode : char;
                     const sGeocode : string) : boolean;
    {function RemoveCode(const sGeocode : string) : boolean;}
    function AddReason(const sReason : string) : boolean;
    function UpdateReason(const iChoiceNum : integer) : boolean;
    procedure btnFontClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPrevFewClick(Sender: TObject);
    procedure btnNextFewClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ReasonMemoClick(Sender: TObject);
    procedure SitesBoxClick(Sender: TObject);
    procedure SitesBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure btnRemoveClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure btnPasteClick(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Search1Click(Sender: TObject);
    procedure Search2Click(Sender: TObject);
    procedure FindStringFind(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure btnNextManyClick(Sender: TObject);
    procedure btnPrevManyClick(Sender: TObject);
    procedure btnDelChoiceClick(Sender: TObject);
    procedure ComboStageChange(Sender: TObject);
    procedure ReloadStageList;

    {RewindLog added 9 June 1998 by Matt
     return the list of geocodes after specified line in the log, then delete elements after that point}
    function RewindLog(const iRemainingLogLength : integer) : Array_t;

    // added 21 Oct 1998 to save selections in named stages to a series of ascii files
    procedure SaveStageSelections;
    function rtnChoiceName(const iChoice : integer) : string;
    procedure SaveChoiceSites(const iChoice : integer;
                              const sChoice : string);
    function CountExistingSelections : integer;
  private

    { Private declarations }
  public
    { Public declarations }
  end;


var
  ChoiceForm: TChoiceForm;
  iNumChoices,iCurrChoice,iPrevChoice : integer;

  iFindMemoChar,
  iFindSiteLine, iFindMemoLine,
  {current lines in ChoiceLog for Site/Memo searches}
  iFindSiteChoice, iFindMemoChoice : integer;
  {current choice in ChoiceLog for Site/Memo searches}

  sFindSiteText, sFindMemoText : string;

  wFindFlag : word;

  StageList : Array_T; {added Fri Nov 7th 1997}
  fStageListCreated : boolean;



procedure StartChoices;
procedure EndChoices;
procedure ClearChoices;

function SubStrSearch(const sSubString, sToSearch : string) : integer;
{finds the position of SubString in ToSearch else returns 0 (not found)}
function rtnLogStatus (const sLineToTest : string) : status_t;

procedure MakeView;
procedure TrimChoices(const iChoice : integer);

function FindChoice(const iToFind : integer) : integer;


implementation

uses Em_newu1, Contribu, Control, Editstr,
     Chc_data, In_order, resize, Sf_irrep,
     highligh, opt1;

{$R *.DFM}

function TChoiceForm.RewindLog(const iRemainingLogLength : integer) : Array_t;
var
   iCount, iItemsInArray, iEndLoop : integer;
   SearchArr : Array_t;

   procedure AddAKey(AArr : Array_t;
                     const iCode : integer);
   begin
        Inc(iItemsInArray);
        AArr.setValue(iItemsInArray,@iCode);
   end;

begin
     try
        {return the list of keys after specified line in the log, then delete elements after that point}

        Result := Array_t.Create;
        iItemsInArray := 0;

        if (ChoiceLog.Items.Count > 0)
        and (ChoiceLog.Items.Count > iRemainingLogLength) then
        begin
             Result.init(SizeOf(integer),(ChoiceLog.Items.Count - iRemainingLogLength));

             {iterate lines to the end of the log, adding keys to the result}
             for iCount := 0 to (ChoiceLog.Items.Count - iRemainingLogLength - 1) do
                 if (ChoiceLog.Items.Strings[iCount + iRemainingLogLength][1] <> CHOICE_MESSAGE) then
                    AddAKey(Result,StrToInt(Copy(ChoiceLog.Items.Strings[iCount + iRemainingLogLength],
                                            2,
                                            Length(ChoiceLog.Items.Strings[iCount + iRemainingLogLength]) - 1)));

             {remove keys from the selection log and de-select these sites from the
              negotiated class before passing them back}


             if (iItemsInArray > 0) then
             with ControlForm do
             begin
                  if (iItemsInArray <> Result.lMaxSize) then
                  begin
                       Result.resize(iItemsInArray);
                  end;

                  {highlight the negotiated site keys contained in Result}
                  SearchArr := SortFeatArray(Result);
                  Arr2SiteStatus(Result,
                                 SearchArr,
                                 R1,
                                 R1Key);
                  SearchArr.Destroy;

                  {de-select these sites to the available listbox}
                  MoveGroup(R1,R1Key,
                            Available,AvailableKey,
                            False,True);

                  {remove site keys from the selection log}
                  iEndLoop := ChoiceLog.Items.Count - iRemainingLogLength - 1;
                  for iCount := 0 to iEndLoop do
                      ChoiceLog.Items.Delete(ChoiceLog.Items.Count - 1);

             end
             else
             begin
                  Result.resize(1);
                  Result.lMaxSize := 0;
             end;
        end
        else
        begin
             {the specified line is on or before the end of the log,
              return empty array}
             Result.init(SizeOf(integer),1);
             Result.lMaxSize := 0;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TChoiceForm.RewindLog',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function rtnLogStatus (const sLineToTest : string) : status_t;
begin
     if (Pos(', Negotiated,',sLineToTest)>0)
     or (Pos(', '+ControlRes^.sR1Label+',',sLineToTest)>0) then
        Result := _R1
     else
         if (Pos(', Mandatory,',sLineToTest)>0)
         or (Pos(', ' + ControlRes^.sR2Label + ',',sLineToTest)>0) then
            Result := _R2
         else
             if (Pos(', ' + ControlRes^.sR3Label + ',',sLineToTest)>0) then
                Result := _R3
             else
                 if (Pos(', ' + ControlRes^.sR4Label + ',',sLineToTest)>0) then
                    Result := _R4
                 else
                     if (Pos(', ' + ControlRes^.sR5Label + ',',sLineToTest)>0) then
                        Result := _R5
                     else
                         if (Pos(', Partial ',sLineToTest)>0) then
                            Result := Pd
                         else
                             if (Pos(', Flagged,',sLineToTest)>0) then
                                Result := Fl
                             else
                                 if (Pos(', Excluded,',sLineToTest)>0) then
                                    Result := Ex
                                 else
                                     Result := Av;
end;

procedure StartChoices;
begin
     ChoiceForm := TChoiceForm.Create(Application);
     ClearChoices;
end;

procedure EndChoices;
begin
     try
        ChoiceForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('exception in EndChoices',mtError,[mbOk],0);
     end;
end;

procedure ClearChoices;
begin
     iCurrChoice := 0;
     iNumChoices := 0;

     ChoiceForm.ChoiceLog.Items.Clear;

     iPrevChoice := -1;

     iFindSiteLine := 0;
     iFindMemoLine := 0;
     iFindSiteChoice := 1;
     iFindMemoChoice := 1;
     sFindSiteText := '';
     sFindMemoText := '';
end;

function FindChoice(const iToFind : integer) : integer;
var
   iCount, iNumChoice : integer;
begin
     iNumChoice := 1; {the log starts at choice 1}
     iCount := 0;

     while (iNumChoice < iToFind)
     and (iCount < ChoiceForm.ChoiceLog.Items.Count) do
     begin
          {find a code line}
          while (iCount < ChoiceForm.ChoiceLog.Items.Count)
          and (ChoiceForm.ChoiceLog.Items.Strings[iCount][1] <> CHOICE_CODE_DEFERR)
          and (ChoiceForm.ChoiceLog.Items.Strings[iCount][1] <> CHOICE_CODE_DESELECT) do
                Inc(iCount);

          Inc(iNumChoice);

          {find a message line}
          while (iCount < ChoiceForm.ChoiceLog.Items.Count)
          and (ChoiceForm.ChoiceLog.Items.Strings[iCount][1] <> CHOICE_MESSAGE) do
                Inc(iCount);
     end;

     if (iCount >= ChoiceForm.ChoiceLog.Items.Count) then
        iCount := ChoiceForm.ChoiceLog.Items.Count - 1;

     Result := iCount;
end;

function CountChoice(const ThisBox : TListBox) : integer;
var
   iCount, iNumChoice, iBoxSize : integer;
   fFinished : boolean;
begin
     iNumChoice := 0;
     iCount := 0;
     iBoxSize := ThisBox.Items.Count;

     if (iBoxSize > 0) then
     while (iCount < iBoxSize) do
     begin
          {find a code line}
          fFinished := False;
          while not fFinished do
                if (iCount < iBoxSize) then
                begin
                     if (ThisBox.Items.Strings[iCount][1] <> CHOICE_CODE_DEFERR)
                     and (ThisBox.Items.Strings[iCount][1] <> CHOICE_CODE_DESELECT) then
                        Inc(iCount)
                     else
                         fFinished := True;
                end
                else
                    fFinished := True;

          Inc(iNumChoice);

          {find a message line}
          fFinished := False;
          while not fFinished do
                if (iCount < iBoxSize) then
                begin
                     if (ThisBox.Items.Strings[iCount][1] <> CHOICE_MESSAGE) then
                        Inc(iCount)
                     else
                         fFinished := True;
                end
                else
                    fFinished := True;
     end;

     Result := iNumChoice;
end;

procedure TrimChoices(const iChoice : integer);
var
   iStartLine, iCount : integer;
   sLine : string;
   fFinished : boolean;
begin
     iStartLine := 0;

     {go to choice iChoice+1 in ChoiceForm.ChoiceLog}
     if (iChoice > 0) then
        for iCount := 1 to iChoice do

            begin
                 {find a code line}
                 fFinished := False;
                 while not fFinished do
                       if (iStartLine < ChoiceForm.ChoiceLog.Items.Count) then
                       begin
                            if (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DEFERR)
                            and (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DESELECT) then
                                Inc(iStartLine)
                            else
                                fFinished := True;
                       end
                       else
                           fFinished := True;
                 {find a message line}
                 fFinished := False;
                 while not fFinished do
                       if (iStartLine < ChoiceForm.ChoiceLog.Items.Count) then
                       begin
                            if (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1]
                                <> CHOICE_MESSAGE) then
                               Inc(iStartLine)
                            else
                                fFinished := True;
                       end
                       else
                           fFinished := True;
            end;



     {delete line iStartLine to end of log}
     for iCount := ChoiceForm.ChoiceLog.Items.Count downto iStartLine do
         ChoiceForm.ChoiceLog.Items.Delete(iCount);
end;

function TChoiceForm.rtnChoiceName(const iChoice : integer) : string;
var
   iStartLine, iCount : integer;
   sLine : string;
   fFinished, fStageId : boolean;
begin
     try
        iStartLine := 0;

        Result := '';

        {go to choice iChoice in ChoiceForm.ChoiceLog}
        if (iChoice > 1) then
           for iCount := 1 to (iChoice-1) do
               begin
                    {find a code line}
                    fFinished := False;
                    while not fFinished do
                          if (iStartLine < ChoiceForm.ChoiceLog.Items.Count) then
                          begin
                               if (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DEFERR)
                               and (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DESELECT) then
                                   Inc(iStartLine)
                               else
                                   fFinished := True;
                          end
                          else
                              fFinished := True;
                    {find a message line}
                    fFinished := False;
                    while not fFinished do
                          if (iStartLine < ChoiceForm.ChoiceLog.Items.Count) then
                          begin
                               if (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1]
                                   <> CHOICE_MESSAGE) then
                                  Inc(iStartLine)
                               else
                                   fFinished := True;
                          end
                          else
                              fFinished := True;
               end;

        {add its message lines to ChoiceForm.ReasonMemo}
        iCount := iStartLine;

        fFinished := False;
        while not fFinished do
              if (iCount < ChoiceForm.ChoiceLog.Items.Count) then
              begin
                   if (ChoiceForm.ChoiceLog.Items.Strings[iCount][1]
                       = CHOICE_MESSAGE) then
                   begin
                        sLine := Copy(ChoiceForm.ChoiceLog.Items.Strings[iCount],2,
                                     Length(ChoiceForm.ChoiceLog.Items.Strings[iCount])-1);

                        if (Length(sLine)>=7) then
                           if (Copy(sLine,1,6) = 'stage ') then
                           begin
                                Result := Copy(sLine,7,Length(sLine)-6);
                           end;

                        Inc(iCount);
                   end
                   else
                       fFinished := True;
              end
              else
                  fFinished := True;

        if (Result = '')
        or (Result = 'no stage specified') then
           Result := 'no_stage';

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TChoiceForm.rtnChoiceName',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TChoiceForm.SaveChoiceSites(const iChoice : integer;
                                      const sChoice : string);
var
   iStartLine, iCount : integer;
   sChoiceFile, sLine : string;
   fFinished : boolean;
   ChoiceFile : TextFile;
begin
     try
        sChoiceFile := ControlRes^.sWorkingDirectory + '\' + sChoice + '.txt';
        if FileExists(sChoiceFile) then
        begin
             assignfile(ChoiceFile,sChoiceFile);
             append(ChoiceFile);
        end
        else
        begin
             assignfile(ChoiceFile,sChoiceFile);
             rewrite(ChoiceFile);
        end;

        iStartLine := 0;
        {find a code line}
        fFinished := False;
        while not fFinished do
              if (iStartLine < ChoiceForm.ChoiceLog.Items.Count) then
              begin
                   if (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DEFERR)
                   and (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DESELECT) then
                       Inc(iStartLine)
                   else
                       fFinished := True;
              end
              else
                  fFinished := True;

        {go to sites for choice iChoice in ChoiceForm.ChoiceLog}
        if (iChoice > 1) then
           for iCount := 1 to (iChoice-1) do
               begin
                    {find a message line}
                    fFinished := False;
                    while not fFinished do
                          if (iStartLine < ChoiceForm.ChoiceLog.Items.Count) then
                          begin
                               if (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1]
                                   <> CHOICE_MESSAGE) then
                                  Inc(iStartLine)
                               else
                                   fFinished := True;
                          end
                          else
                              fFinished := True;
                    {find a code line}
                    fFinished := False;
                    while not fFinished do
                          if (iStartLine < ChoiceForm.ChoiceLog.Items.Count) then
                          begin
                               if (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DEFERR)
                               and (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DESELECT) then
                                  Inc(iStartLine)
                               else
                                   fFinished := True;
                          end
                          else
                              fFinished := True;
               end;

        {add its geocode lines to ChoiceForm.SitesBox}
        iCount := iStartLine;

        fFinished := False;
        while not fFinished do
              if (iCount < ChoiceForm.ChoiceLog.Items.Count) then
              begin
                   if (ChoiceForm.ChoiceLog.Items.Strings[iCount][1] = CHOICE_CODE_DEFERR)
                   or (ChoiceForm.ChoiceLog.Items.Strings[iCount][1] = CHOICE_CODE_DESELECT) then
                   begin
                        sLine := Copy(ChoiceForm.ChoiceLog.Items.Strings[iCount],2,
                                     Length(ChoiceForm.ChoiceLog.Items.Strings[iCount])-1);

                        // sLine is the site key of the current site, write it to the output file
                        writeln(ChoiceFile,sLine);

                        Inc(iCount);
                   end
                   else
                       fFinished := True;
              end
              else
                  fFinished := True;

        CloseFile(ChoiceFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TChoiceForm.SaveChoiceSites',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


procedure ShowChoice(const iChoice : integer);
var
   iStartLine, iCount : integer;
   sLine : string;
   fFinished, fStageId : boolean;
begin
     iStartLine := 0;

     {go to choice iChoice in ChoiceForm.ChoiceLog}
     if (iChoice > 1) then
        for iCount := 1 to (iChoice-1) do
            begin
                 {find a code line}
                 fFinished := False;
                 while not fFinished do
                       if (iStartLine < ChoiceForm.ChoiceLog.Items.Count) then
                       begin
                            if (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DEFERR)
                            and (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DESELECT) then
                                Inc(iStartLine)
                            else
                                fFinished := True;
                       end
                       else
                           fFinished := True;
                 {find a message line}
                 fFinished := False;
                 while not fFinished do
                       if (iStartLine < ChoiceForm.ChoiceLog.Items.Count) then
                       begin
                            if (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1]
                                <> CHOICE_MESSAGE) then
                               Inc(iStartLine)
                            else
                                fFinished := True;
                       end
                       else
                           fFinished := True;
            end;

     {add its message lines to ChoiceForm.ReasonMemo}
     iCount := iStartLine;
     ChoiceForm.ReasonMemo.Clear;
     ChoiceForm.ReasonMemo.Update;

     fFinished := False;
     while not fFinished do
           if (iCount < ChoiceForm.ChoiceLog.Items.Count) then
           begin
                if (ChoiceForm.ChoiceLog.Items.Strings[iCount][1]
                    = CHOICE_MESSAGE) then
                begin
                     sLine := Copy(ChoiceForm.ChoiceLog.Items.Strings[iCount],2,
                                  Length(ChoiceForm.ChoiceLog.Items.Strings[iCount])-1);

                     fStageId := False;
                     if (Length(sLine)>6) then
                        if (Copy(sLine,1,6) = 'stage ') then
                        begin
                             fStageId := True;

                             ChoiceForm.ComboStage.Text := Copy(sLine,7,Length(sLine)-6);
                        end;

                     if not fStageId then
                        ChoiceForm.ReasonMemo.Lines.Add(sLine);

                     Inc(iCount);
                end
                else
                    fFinished := True;
           end
           else
               fFinished := True;

     ChoiceForm.ReasonMemo.Modified := False;
end;

procedure ShowSites(const iChoice : integer);
var
   iStartLine, iCount : integer;
   sLine : string;
   fFinished : boolean;
begin
     iStartLine := 0;
     {find a code line}
     fFinished := False;
     while not fFinished do
           if (iStartLine < ChoiceForm.ChoiceLog.Items.Count) then
           begin
                if (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DEFERR)
                and (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DESELECT) then
                    Inc(iStartLine)
                else
                    fFinished := True;
           end
           else
               fFinished := True;

     {go to sites for choice iChoice in ChoiceForm.ChoiceLog}
     if (iChoice > 1) then
        for iCount := 1 to (iChoice-1) do
            begin
                 {find a message line}
                 fFinished := False;
                 while not fFinished do
                       if (iStartLine < ChoiceForm.ChoiceLog.Items.Count) then
                       begin
                            if (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1]
                                <> CHOICE_MESSAGE) then
                               Inc(iStartLine)
                            else
                                fFinished := True;
                       end
                       else
                           fFinished := True;
                 {find a code line}
                 fFinished := False;
                 while not fFinished do
                       if (iStartLine < ChoiceForm.ChoiceLog.Items.Count) then
                       begin
                            if (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DEFERR)
                            and (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DESELECT) then
                               Inc(iStartLine)
                            else
                                fFinished := True;
                       end
                       else
                           fFinished := True;
            end;

     {add its geocode lines to ChoiceForm.SitesBox}
     iCount := iStartLine;
     ChoiceForm.SitesBox.Clear;
     ChoiceForm.SitesBox.Update;

     fFinished := False;
     while not fFinished do
           if (iCount < ChoiceForm.ChoiceLog.Items.Count) then
           begin
                if (ChoiceForm.ChoiceLog.Items.Strings[iCount][1] = CHOICE_CODE_DEFERR)
                or (ChoiceForm.ChoiceLog.Items.Strings[iCount][1] = CHOICE_CODE_DESELECT) then
                begin
                     sLine := Copy(ChoiceForm.ChoiceLog.Items.Strings[iCount],2,
                                  Length(ChoiceForm.ChoiceLog.Items.Strings[iCount])-1);

                     sLine := FindSiteName(StrToInt(sLine));
                     {this fetches the site name only if it is selected/mandatory/excluded}

                     ChoiceForm.SitesBox.Items.Add(sLine);
                     Inc(iCount);
                end
                else
                    fFinished := True;
           end
           else
               fFinished := True;
end;

procedure TChoiceForm.SaveStageSelections;
var
   sStage, sStageListFile : string;
   StageListFile : TextFile;
   iCount : integer;
begin
     try
        Screen.Cursor := crHourglass;

        iNumChoices := CountChoice(ChoiceLog);

        if (iNumChoices > 0) then
        begin
             sStageListFile := ControlRes^.sWorkingDirectory + '\stages.txt';
             assignfile(StageListFile,sStageListFile);
             rewrite(StageListFile);

             for iCount := 1 to iNumChoices do
             begin
                  sStage := rtnChoiceName(iCount);
                  if (sStage = 'no_stage') then
                  begin
                       // do not generate reports for sites in the
                       // 'no stage specified' stage
                  end
                  else
                  begin
                       SaveChoiceSites(iCount,sStage);
                       writeln(StageListFile,ControLRes^.sWorkingDirectory + '\' + sStage + '.txt');
                  end;
             end;

             closefile(StageListFile);
        end;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TChoiceForm.SaveStageSelections',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;



procedure MakeView;
begin
     Screen.Cursor := crHourglass;

     with ChoiceForm do
     begin
          iNumChoices := CountChoice(ChoiceLog);

          SitesBox.Width := ClientWidth div 5;
          SitesBox.Height := ClientHeight - Panel1.Height;
          ReasonMemo.Width := ClientWidth - SitesBox.Width;
          ReasonMemo.Height := SitesBox.Height;
          {resize string boxes}

          if (iNumChoices > 0) then
          begin
               if (iCurrChoice > iNumChoices) then
                  iCurrChoice := iNumChoices
               else if (iCurrChoice < 1) then
                       iCurrChoice := 1;

               txtNumChoices.Caption := IntToStr(iNumChoices);
               txtCurrChoice.Caption := IntToStr(iCurrChoice);

               if (iCurrChoice > 1) then
               begin
                    btnPrev.Enabled := True;
                    btnPrevFew.Enabled := True;
                    btnPrevMany.Enabled := True;
               end
               else
               begin
                    btnPrev.Enabled := False;
                    btnPrevFew.Enabled := False;
                    btnPrevMany.Enabled := False;
               end;

               if (iCurrChoice < iNumChoices) then
               begin
                    btnNext.Enabled := True;
                    btnNextFew.Enabled := True;
                    btnNextMany.Enabled := True;
               end
               else
               begin
                    btnNext.Enabled := False;
                    btnNextFew.Enabled := False;
                    btnNextMany.Enabled := False;
               end;

               if (iCurrChoice <> iPrevChoice) then
               begin
                    {if the view is not current, update it}
                    {UserChoices.ReturnReason(iCurrChoice,ChoiceForm.ReasonMemo);
                    UserChoices.ReturnCodes(iCurrChoice,ChoiceForm.SitesBox);}
                    ShowChoice(iCurrChoice);
                    ShowSites(iCurrChoice);

                    if (ChoiceForm.SitesBox.Items.Count = 1) then
                       ChoiceForm.txtSiteCount.Caption := '(' + IntToStr(ChoiceForm.SitesBox.Items.Count) +
                                                       ' Site)'
                    else
                        ChoiceForm.txtSiteCount.Caption := '(' + IntToStr(ChoiceForm.SitesBox.Items.Count) +
                                                       ' Sites)';

                    iPrevChoice := iCurrChoice;
               end;
          end
          else
          begin
               {there are no choices to see}

               btnPrev.Enabled := False;
               btnPrevFew.Enabled := False;
               btnPrevMany.Enabled := False;
               btnNext.Enabled := False;
               btnNextFew.Enabled := False;
               btnNextMany.Enabled := False;

               txtNumChoices.Caption := '0';
               txtCurrChoice.Caption := '0';

               SitesBox.Clear;
               ReasonMemo.Clear;
          end;
     end;

     Screen.Cursor := crDefault;
end;


function TChoiceForm.AddCode(const cChoiceCode : char;
                             const sGeocode : string) : boolean;
begin
     Result := True;

     ChoiceLog.Items.Add(cChoiceCode + sGeocode);
end;

function TChoiceForm.AddReason(const sReason : string) : boolean;
begin
     Result := True;

     ChoiceLog.Items.Add(CHOICE_MESSAGE + sReason);
end;

function TChoiceForm.UpdateReason(const iChoiceNum : integer) : boolean;
var
   iStartLine, iCount : integer;
begin
     Result := True;

     {if ReasonMemo.Modified then}
     begin
          {update reasoning from ReasonMemo to ChoiceLog because of user changes}

          {find correct entry point in ChoiceLog}
          iStartLine := 0;
          if (iChoiceNum > 1) then
             for iCount := 1 to (iChoiceNum-1) do
                 begin
                      {find a code line}
                      while (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DEFERR)
                      and (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_CODE_DESELECT)
                      and (iStartLine < ChoiceForm.ChoiceLog.Items.Count) do
                            Inc(iStartLine);
                      {find a message line}
                      while (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] <> CHOICE_MESSAGE)
                      and (iStartLine < ChoiceForm.ChoiceLog.Items.Count) do
                            Inc(iStartLine);
                 end;

          {delete old reason line(s)}
          while (iStartLine <= ChoiceLog.Items.Count)
          and (ChoiceForm.ChoiceLog.Items.Strings[iStartLine][1] = CHOICE_MESSAGE) do
              ChoiceForm.ChoiceLog.Items.Delete(iStartLine);

          {add new reason line(s)}
          if (ReasonMemo.Lines.Count > 0) then
             for iCount := (ReasonMemo.Lines.Count-1) downto 0 do
                 ChoiceForm.ChoiceLog.Items.Insert(iStartLine,CHOICE_MESSAGE + ReasonMemo.Lines.Strings[iCount])
          else
              ChoiceForm.ChoiceLog.Items.Insert(iStartLine,CHOICE_MESSAGE + 'no reason specified');
          {add the stage name associated with this selection and precede
           it with 'stage '}
          if (ComboStage.Text = '') then
             ChoiceForm.ChoiceLog.Items.Insert(iStartLine,CHOICE_MESSAGE + 'stage no stage specified')
          else
              ChoiceForm.ChoiceLog.Items.Insert(iStartLine,CHOICE_MESSAGE + 'stage ' + ComboStage.Text);
     end;
end;

procedure TChoiceForm.btnFontClick(Sender: TObject);
begin
     ChoiceFont.Font := ReasonMemo.Font;
     if ChoiceFont.Execute then
     begin
          ReasonMemo.Font := ChoiceFont.Font;
          SitesBox.Font := ReasonMemo.Font;

          {trigger screen repaint}
          ReasonMemo.Update;
          SitesBox.Update;
     end;

end;

procedure TChoiceForm.btnCopyClick(Sender: TObject);
var
   pStart, pMoving : PChar;
   hData : THandle;
   iCount, iDataSize : integer;
begin
     if (SitesBox.SelCount > 0) then
     begin
          iDataSize := 0;

          {find the size of data block to create}
          for iCount := 0 to (SitesBox.Items.Count-1) do
              if SitesBox.Selected[iCount] then
                 Inc(iDataSize,Length(SitesBox.Items.Strings[iCount])+2);
          Dec(iDataSize,2);

          hData := GlobalAlloc(GHND,iDataSize);
          pMoving := GlobalLock(hData);
          pStart := pMoving;

          {create null terminated string list}
          for iCount := 0 to (SitesBox.Items.Count-1) do
              if SitesBox.Selected[iCount] then
              begin
                   StrPCopy(pMoving,SitesBox.Items.Strings[iCount] + Chr(13) + Chr(10));
                   pMoving := pMoving + Length(SitesBox.Items.Strings[iCount]) + 2;
              end;
          pMoving := pMoving - 2;
          pMoving := #0;

          Clipboard.SetTextBuf(pStart);
          GlobalUnlock(hData);
     end
     else
     if (ReasonMemo.SelText <> '') then
     begin
          ReasonMemo.CopyToClipboard;

          {GetMem(pStart,256);
          StrPCopy(pStart,ReasonMemo.SelText);
          Clipboard.SetTextBuf(pStart);
          FreeMem(pStart,256);}
     end;
        {this may limit the copy to 256 characters**********}
end;

procedure TChoiceForm.FormShow(Sender: TObject);
begin
     MakeView;
end;

procedure TChoiceForm.ReloadStageList;
var
   iCount : integer;
   StageEntry : StageEntry_T;
begin
     {we need to call BuildStageList to get a list of stages for user to
      select from}
     if fStageListCreated then
        StageList.Destroy;
     BuildStageList(StageList);
     ComboStage.Items.Clear;
     if (StageList.lMaxSize > 0) then
        for iCount := 1 to StageList.lMaxSize do
        begin
             StageList.rtnValue(iCount,@StageEntry);
             ComboStage.Items.Add(StageEntry.sStageName);
        end;
end;

procedure TChoiceForm.btnPrevClick(Sender: TObject);
begin
     {UserChoices.}UpdateReason(iCurrChoice{,ReasonMemo});
     Dec(iCurrChoice);
     MakeView;
     ReloadStageList;
end;

procedure TChoiceForm.btnNextClick(Sender: TObject);
begin
     {UserChoices.}UpdateReason(iCurrChoice{,ReasonMemo});
     Inc(iCurrChoice);
     MakeView;
     ReloadStageList;
end;

procedure TChoiceForm.btnPrevFewClick(Sender: TObject);
begin
     {UserChoices.}UpdateReason(iCurrChoice{,ReasonMemo});

     if (iCurrChoice-CHOICE_BUTTON_STEP_SIZE) < 1 then
        iCurrChoice := 1
     else
         Dec(iCurrChoice,CHOICE_BUTTON_STEP_SIZE);

     MakeView;
     ReloadStageList;
end;

procedure TChoiceForm.btnNextFewClick(Sender: TObject);
begin
     UpdateReason(iCurrChoice);

     if (iCurrChoice+CHOICE_BUTTON_STEP_SIZE) > iNumChoices then
        iCurrChoice := iNumChoices
     else
         Inc(iCurrChoice,CHOICE_BUTTON_STEP_SIZE);

     MakeView;
     ReloadStageList;
end;

procedure TChoiceForm.FormResize(Sender: TObject);
begin
     MakeView;

     {rewrite labels to size}
     Label1.Caption := 'Selection';
     Label2.Caption := 'of';
end;

procedure TChoiceForm.ReasonMemoClick(Sender: TObject);
begin
     {un-select any selections in SitesBox}
     UnHighlight(SitesBox,fKeepHighlight);

     {remove/split sites disabled}
     btnRemove.Enabled := False;
     Remove1.Enabled := False;
     Split1.Enabled := False;

     {paste reason enabled}
     btnPaste.Enabled := True;
     Paste2.Enabled := True;
end;

procedure TChoiceForm.SitesBoxClick(Sender: TObject);
begin
     {un-select any selections in ReasonMemo}
     UnHighlightMemo(ReasonMemo);

     {paste reason disabled}
     btnPaste.Enabled := False;
     Paste2.Enabled := False;
     Update;
end;

procedure TChoiceForm.SitesBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
     if SitesBox.SelCount > 0 then
     begin
          {remove/split sites enabled}
          btnRemove.Enabled := True;
          Remove1.Enabled := True;
          Split1.Enabled := True;
     end
     else
     begin
          {remove/split sites disabled}
          btnRemove.Enabled := False;
          Remove1.Enabled := False;
          Split1.Enabled := False;
     end;
end;

procedure TChoiceForm.btnRemoveClick(Sender: TObject);
var
   iCount, iCount2 : integer;
   fCodeFound, fStop : boolean;
begin
     if SitesBox.SelCount > 0 then
     with ControlForm do
     begin
          UnHighlight(R1,fKeepHighlight);
          UnHighlight(R2,fKeepHighlight);
          UnHighlight(R3,fKeepHighlight);
          UnHighlight(R4,fKeepHighlight);
          UnHighlight(R5,fKeepHighlight);
          UnHighlight(Excluded,fKeepHighlight);
          UnHighlight(Flagged,fKeepHighlight);
          UnHighlight(Partial,fKeepHighlight);

          for iCount := 0 to (SitesBox.Items.Count-1) do
              if SitesBox.Selected[iCount] then
              {find this site in the man/sel/exc lists and select it}

              begin
                   fStop := False;
                   if (iCurrChoice = iNumChoices) then
                      {fStop := True
                   else}
                       fStop := FindFollowingDeSelect(StrToInt(SitesBox.Items.Strings[iCount]),
                                              FindChoice(iCurrChoice+1),
                                              ChoiceLog.Items.Count-1);

                   if not fStop then
                   begin
                        fCodeFound := False;

                        if R1.Items.Count > 0 then
                           for iCount2 := 0 to (R1.Items.Count-1) do
                               if (R1.Items.Strings[iCount2] = SitesBox.Items.Strings[iCount]) then
                               begin
                                    R1.Selected[iCount2] := True;
                                    fCodeFound := True;
                               end;
                        if not fCodeFound then if R2.Items.Count > 0 then
                           for iCount2 := 0 to (R2.Items.Count-1) do
                               if (R2.Items.Strings[iCount2] = SitesBox.Items.Strings[iCount]) then
                               begin
                                    R2.Selected[iCount2] := True;
                                    fCodeFound := True;
                               end;
                        if not fCodeFound then if R3.Items.Count > 0 then
                           for iCount2 := 0 to (R3.Items.Count-1) do
                               if (R3.Items.Strings[iCount2] = SitesBox.Items.Strings[iCount]) then
                               begin
                                    R3.Selected[iCount2] := True;
                                    fCodeFound := True;
                               end;
                        if not fCodeFound then if R4.Items.Count > 0 then
                           for iCount2 := 0 to (R4.Items.Count-1) do
                               if (R4.Items.Strings[iCount2] = SitesBox.Items.Strings[iCount]) then
                               begin
                                    R4.Selected[iCount2] := True;
                                    fCodeFound := True;
                               end;
                        if not fCodeFound then if R5.Items.Count > 0 then
                           for iCount2 := 0 to (R5.Items.Count-1) do
                               if (R5.Items.Strings[iCount2] = SitesBox.Items.Strings[iCount]) then
                               begin
                                    R5.Selected[iCount2] := True;
                                    fCodeFound := True;
                               end;
                        if not fCodeFound then if Excluded.Items.Count > 0 then
                           for iCount2 := 0 to (Excluded.Items.Count-1) do
                               if (Excluded.Items.Strings[iCount2] = SitesBox.Items.Strings[iCount]) then
                               begin
                                    Excluded.Selected[iCount2] := True;
                                    fCodeFound := True;
                               end;
                        if not fCodeFound then if Partial.Items.Count > 0 then
                           for iCount2 := 0 to (Partial.Items.Count-1) do
                               if (Partial.Items.Strings[iCount2] = SitesBox.Items.Strings[iCount]) then
                               begin
                                    Partial.Selected[iCount2] := True;
                                    fCodeFound := True;
                               end;
                        if not fCodeFound then if Flagged.Items.Count > 0 then
                           for iCount2 := 0 to (Flagged.Items.Count-1) do
                               if (Flagged.Items.Strings[iCount2] = SitesBox.Items.Strings[iCount]) then
                               begin
                                    Flagged.Selected[iCount2] := True;
                                    fCodeFound := True;
                               end;

                        if not fCodeFound then
                           MessageDlg('Site ' + FindSiteName(StrToInt(SitesBox.Items.Strings[iCount])) +
                                      ' is not selected', mtInformation,[mbOK],0);
                   end;
              end;

          {now unselect all the selected sites which have been flagged}
          if R1.SelCount > 0 then
             MoveGroup(R1,R1Key,Available,AvailableKey,TRUE,True);
          if R2.SelCount > 0 then
             MoveGroup(R2,R2Key,Available,AvailableKey,TRUE,True);
          if R3.SelCount > 0 then
             MoveGroup(R3,R3Key,Available,AvailableKey,TRUE,True);
          if R4.SelCount > 0 then
             MoveGroup(R4,R4Key,Available,AvailableKey,TRUE,True);
          if R5.SelCount > 0 then
             MoveGroup(R5,R5Key,Available,AvailableKey,TRUE,True);
          if Excluded.SelCount > 0 then
             MoveGroup(Excluded,ExcludedKey,Available,AvailableKey,TRUE,True);
          if Partial.SelCount > 0 then
             MoveGroup(Partial,PartialKey,Available,AvailableKey,TRUE,True);
          if Flagged.SelCount > 0 then
             MoveGroup(Flagged,FlaggedKey,Available,AvailableKey,TRUE,True);

          {make the view current}
          iPrevChoice := -1;
          MakeView;
     end;

     {disable remove/split sites}
     btnRemove.Enabled := False;
     Remove1.Enabled := False;
     Split1.Enabled := False;
end;

procedure TChoiceForm.BitBtn1Click(Sender: TObject);
begin
     ModalResult := mrOK;

     {user has hit OK and is exiting}
     UpdateReason(iCurrChoice);

     try FindString.CloseDialog; except end;
     {free search dialog box if active}

     ReasonMemo.Text := '';
     SitesBox.Clear;
     {gets rid of previous display values on exit}
end;

procedure TChoiceForm.btnPasteClick(Sender: TObject);
begin
     ReasonMemo.PasteFromClipboard;
end;

procedure TChoiceForm.Cut1Click(Sender: TObject);
begin
     ReasonMemo.CutToClipboard;
end;

procedure TChoiceForm.FormActivate(Sender: TObject);
begin
     MakeView;
end;

procedure TChoiceForm.Search1Click(Sender: TObject);
begin
     if (iNumChoices > 0) then
     begin
          {search for a site}
          wFindFlag := FIND_SITE;

          FindString.FindText := sFindSiteText;
          FindString.Execute;
     end;
end;

procedure TChoiceForm.Search2Click(Sender: TObject);
begin
     if (iNumChoices > 0) then
     begin
          {search for a reason}
          wFindFlag := FIND_MEMO;

          FindString.FindText := sFindMemoText;
          FindString.Execute;
     end;
end;

function SubStrSearch(const sSubString, sToSearch : string) : integer;
{finds the position of SubString in ToSearch else returns 0 (not found)}
var
   sThisImage : string;
   iNumImages, iCount : integer;
begin
     Result := 0;

     if (Length(sSubString) <= Length(sToSearch)) then
     begin
          iNumImages := Length(sToSearch) - Length(sSubString) + 1;

          for iCount := iNumImages downto 1 do
          begin
               sThisImage := Copy(sToSearch,iCount,Length(sSubString));

               if (sThisImage = sSubString) then
               begin
                    Result := iCount;

                    if (wFindFlag = FIND_MEMO) then
                    begin
                         iFindMemoChar := iCount-1;

                    end;
               end;
          end;
     end;
end;

procedure SearchForSite(const fDown,fMatchCase,fWholeWord : boolean);
var
   fFound, fHere, fOldLineUsed : boolean;
   iCurrSearchChoice, iThisLine, iSitesBoxCounter, iNumPasses : integer;
   sThisGeocode, sThisSiteName : string;
   wOldCursor : integer;
begin
     fFound := False;
     fHere := True;
     fOldLineUsed := False;
     iCurrSearchChoice := iCurrChoice;
     iNumPasses := 0;
     sFindSiteText := ChoiceForm.FindString.FindText;

     while not fFound
     and fHere do
     begin
          Inc(iNumPasses);

          if fDown then
          begin
               {search downwards for site in current choice}
               {compare each geocode/sitename in this choice
                with ChoiceForm.FindString.FindText}
               {if we find it, bring it to focus}

               if not fOldLineUsed
               and (iFindSiteLine >= FindChoice(iCurrSearchChoice))
               and (iFindSiteLine <= FindChoice(iCurrSearchChoice+1)) then
               begin
                    iThisLine := iFindSiteLine+1;
                    fOldLineUsed := True;
               end
               else
               begin
                    iThisLine := FindChoice(iCurrSearchChoice);
                    fOldLineUsed := False;
               end;

               while (iThisLine < ChoiceForm.ChoiceLog.Items.Count)
               and (ChoiceForm.ChoiceLog.Items.Strings[iThisLine][1] <> CHOICE_CODE_DEFERR)
               and (ChoiceForm.ChoiceLog.Items.Strings[iThisLine][1] <> CHOICE_CODE_DESELECT) do
                   Inc(iThisLine);
               {advance this choice past its message line/s to its code line/s}

               while not fFound
               and (iThisLine < ChoiceForm.ChoiceLog.Items.Count)
               and ((ChoiceForm.ChoiceLog.Items.Strings[iThisLine][1] = CHOICE_CODE_DEFERR)
                    or (ChoiceForm.ChoiceLog.Items.Strings[iThisLine][1] = CHOICE_CODE_DESELECT)) do
               begin
                    {this is where we apply fMatchCase,fWholeWord and do the comparison
                     between ChoiceForm.FindString.FindText and the current geocode/sitename}

                    sThisGeocode := Copy(ChoiceForm.ChoiceLog.Items.Strings[iThisLine],
                                         2,Length(ChoiceForm.ChoiceLog.Items.Strings[iThisLine])-1);
                    sThisSiteName := FindSiteName(StrToInt(sThisGeocode));

                    if fMatchCase then
                    begin
                         {match case}
                         if fWholeWord then
                            fFound := (CompareStr(sThisGeocode,ChoiceForm.FindString.FindText) = 0)
                                      or (CompareStr(sThisSiteName,ChoiceForm.FindString.FindText) = 0)
                         else
                         begin
                              fFound := (SubStrSearch(ChoiceForm.FindString.FindText,sThisGeocode) <> 0)
                                        or (SubStrSearch(ChoiceForm.FindString.FindText,sThisSiteName) <> 0);
                         end;
                    end
                    else
                    begin
                         {don't match case}
                         if fWholeWord then
                            fFound := (CompareText(sThisGeocode,ChoiceForm.FindString.FindText) = 0)
                                      or (CompareText(sThisSiteName,ChoiceForm.FindString.FindText) = 0)
                         else
                         begin
                              fFound := (SubStrSearch(LowerCase(ChoiceForm.FindString.FindText),
                                         LowerCase(sThisGeocode)) <> 0)
                                        or (SubStrSearch(LowerCase(ChoiceForm.FindString.FindText),
                                         LowerCase(sThisSiteName)) <> 0);
                         end;
                    end;

                    Inc(iThisLine);
               end;
          end
          else
          begin
               {search upwards for site in current choice}
               {compare each geocode/sitename in this choice
                with ChoiceForm.FindString.FindText}

               if not fOldLineUsed
               and (iFindSiteLine >= FindChoice(iCurrSearchChoice))
               and (iFindSiteLine <= FindChoice(iCurrSearchChoice+1)) then
               begin
                    iThisLine := iFindSiteLine-1;
                    fOldLineUsed := True;
               end
               else
               begin
                    iThisLine := FindChoice(iCurrSearchChoice+1);
                    fOldLineUsed := False;
               end;

               if (iThisLine > 0)
               and (ChoiceForm.ChoiceLog.Items.Strings[iThisLine][1] = CHOICE_MESSAGE) then
                   Dec(iThisLine);
                   {decrement iThisLine if we are on a message line,
                    ie. if current choice is not last choice}

               while not fFound
               and (iThisLine > 0)
               and (ChoiceForm.ChoiceLog.Items.Strings[iThisLine][1] <> CHOICE_MESSAGE) do
               begin
                    {this is where we apply fMatchCase,fWholeWord and do the comparison
                     between ChoiceForm.FindString.FindText and the current geocode/sitename}

                    sThisGeocode := Copy(ChoiceForm.ChoiceLog.Items.Strings[iThisLine],
                                         2,Length(ChoiceForm.ChoiceLog.Items.Strings[iThisLine])-1);
                    sThisSiteName := FindSiteName(StrToInt(sThisGeocode));

                    if fMatchCase then
                    begin
                         {match case}
                         if fWholeWord then
                            fFound := (CompareStr(sThisGeocode,ChoiceForm.FindString.FindText) = 0)
                                      or (CompareStr(sThisSiteName,ChoiceForm.FindString.FindText) = 0)
                         else
                             fFound := (SubStrSearch(ChoiceForm.FindString.FindText,sThisGeocode) <> 0)
                                       or (SubStrSearch(ChoiceForm.FindString.FindText,sThisSiteName) <> 0);
                    end
                    else
                    begin
                         {don't match case}
                         if fWholeWord then
                            fFound := (CompareText(sThisGeocode,ChoiceForm.FindString.FindText) = 0)
                                      or (CompareText(sThisSiteName,ChoiceForm.FindString.FindText) = 0)
                         else
                             fFound := (SubStrSearch(LowerCase(ChoiceForm.FindString.FindText),
                                        LowerCase(sThisGeocode)) <> 0)
                                       or (SubStrSearch(LowerCase(ChoiceForm.FindString.FindText),
                                        LowerCase(sThisSiteName)) <> 0);
                    end;

                    Dec(iThisLine);
               end;
          end;

          if not fFound then
          begin
               {adjust the search choice to keep searching,
                or terminate if all searched, 'wrap-around' logic}

               if (iNumPasses > (iNumChoices+1)) then
                  fHere := False
               else
               begin
                    if fDown then
                    begin
                         if (iCurrSearchChoice = iNumChoices) then
                            iCurrSearchChoice := 1
                         else
                             Inc(iCurrSearchChoice);
                    end
                    else
                    begin
                         if (iCurrSearchChoice = 1) then
                            iCurrSearchChoice := iNumChoices
                         else
                             Dec(iCurrSearchChoice);
                    end;

                    if (iNumChoices = 1) then
                       iCurrSearchChoice := 1;
                       {handles case iNumChoices = 1}
               end;
          end
          else
          begin
               {we have found the site name\geocode!!!}

               if fDown then
                  iFindSiteLine := iThisLine-1
               else
                   iFindSiteLine := iThisLine+1;
               iCurrChoice := iCurrSearchChoice;
               MakeView;

               UnHighlight(ChoiceForm.SitesBox,fKeepHighlight);

               {find sThisGeocode in SitesBox and highlight it}
               for iSitesBoxCounter := 0 to (ChoiceForm.SitesBox.Items.Count-1) do
                   if (ChoiceForm.SitesBox.Items.Strings[iSitesBoxCounter] = sThisSiteName) then
                   begin
                        ChoiceForm.SitesBox.Selected[iSitesBoxCounter] := True;
                   end;

               ChoiceForm.Update;
          end;
     end;

     if not fHere then
     begin
          {iFindSiteLine := 0;}

          wOldCursor := Screen.Cursor;
          Screen.Cursor := crDefault;
          MessageDlg('Site Key/Name not found in choices',mtInformation,[mbOK],0);
          Screen.Cursor := wOldCursor;
     end;
end;

procedure SearchForMemo(const fDown,fMatchCase,fWholeWord : boolean);
var
   fFound, fHere, fOldLineUsed : boolean;
   iCurrSearchChoice, iThisLine, iMemoCounter, iNumPasses : integer;
   sThisLine : string;
   wOldCursor : integer;
begin
     fFound := False;
     fHere := True;
     fOldLineUsed := False;
     iCurrSearchChoice := iCurrChoice;
     iNumPasses := 0;
     sFindMemoText := ChoiceForm.FindString.FindText;

     while not fFound
     and fHere do
     begin
          Inc(iNumPasses);

          if fDown then
          begin
               {search downwards for memo string in current choice}
               {compare each substring in this choice
                with ChoiceForm.FindString.FindText}
               {if we find it, bring it to focus}

               if not fOldLineUsed
               and (iFindMemoLine >= FindChoice(iCurrSearchChoice))
               and (iFindMemoLine <= FindChoice(iCurrSearchChoice+1)) then
               begin
                    iThisLine := iFindMemoLine+1;
                    fOldLineUsed := True;
               end
               else
               begin
                    iThisLine := FindChoice(iCurrSearchChoice);
                    fOldLineUsed := False;
               end;

               while not fFound
               and (iThisLine < ChoiceForm.ChoiceLog.Items.Count)
               and (ChoiceForm.ChoiceLog.Items.Strings[iThisLine][1] = CHOICE_MESSAGE) do
               begin
                    {this is where we apply fMatchCase,fWholeWord and do the comparison
                     between ChoiceForm.FindString.FindText and the lines subset}

                    sThisLine := Copy(ChoiceForm.ChoiceLog.Items.Strings[iThisLine],
                                      2,Length(ChoiceForm.ChoiceLog.Items.Strings[iThisLine])-1);

                    if fMatchCase then
                    begin
                         {match case}
                         if fWholeWord then
                            fFound := (CompareStr(sThisLine,ChoiceForm.FindString.FindText) = 0)
                         else
                             fFound := (SubStrSearch(ChoiceForm.FindString.FindText,sThisLine) <> 0);
                    end
                    else
                    begin
                         {don't match case}
                         if fWholeWord then
                            fFound := (CompareText(sThisLine,ChoiceForm.FindString.FindText) = 0)
                         else
                             fFound := (SubStrSearch(LowerCase(ChoiceForm.FindString.FindText),
                                         LowerCase(sThisLine)) <> 0);
                    end;

                    Inc(iThisLine);
               end;
          end
          else
          begin
               {search upwards for memo string in current choice}
               {compare each geocode/sitename in this choice
                with ChoiceForm.FindString.FindText}

               if not fOldLineUsed
               and (iFindSiteLine >= FindChoice(iCurrSearchChoice))
               and (iFindSiteLine <= FindChoice(iCurrSearchChoice+1)) then
               begin
                    iThisLine := iFindSiteLine-1;
                    fOldLineUsed := True;
               end
               else
               begin
                    iThisLine := FindChoice(iCurrSearchChoice+1);

                    if (ChoiceForm.ChoiceLog.Items.Strings[iThisLine][1] = CHOICE_MESSAGE) then
                       Dec(iThisLine);
                    while (iThisLine > 0)
                    and (ChoiceForm.ChoiceLog.Items.Strings[iThisLine][1] <> CHOICE_MESSAGE) do
                        Dec(iThisLine);

                    {start at the end of message lines for current search choice}

                    fOldLineUsed := False;
               end;

               while not fFound
               and (iThisLine > 0)
               and (ChoiceForm.ChoiceLog.Items.Strings[iThisLine][1] = CHOICE_MESSAGE) do
               begin
                    {this is where we apply fMatchCase,fWholeWord and do the comparison
                     between ChoiceForm.FindString.FindText and the current geocode/sitename}

                    sThisLine := Copy(ChoiceForm.ChoiceLog.Items.Strings[iThisLine],
                                      2,Length(ChoiceForm.ChoiceLog.Items.Strings[iThisLine])-1);

                    if fMatchCase then
                    begin
                         {match case}
                         if fWholeWord then
                            fFound := (CompareStr(sThisLine,ChoiceForm.FindString.FindText) = 0)
                         else
                             fFound := (SubStrSearch(ChoiceForm.FindString.FindText,sThisLine) <> 0);
                    end
                    else
                    begin
                         {don't match case}
                         if fWholeWord then
                            fFound := (CompareText(sThisLine,ChoiceForm.FindString.FindText) = 0)
                         else
                             fFound := (SubStrSearch(LowerCase(ChoiceForm.FindString.FindText),
                                        LowerCase(sThisLine)) <> 0);
                    end;

                    Dec(iThisLine);
               end;
          end;

          if not fFound then
          begin
               {adjust the search choice to keep searching,
                or terminate if all searched, 'wrap-around' logic}

               if (iNumPasses > (iNumChoices+1)) then
                  fHere := False
               else
               begin
                    if fDown then
                    begin
                         if (iCurrSearchChoice = iNumChoices) then
                            iCurrSearchChoice := 1
                         else
                             Inc(iCurrSearchChoice);
                    end
                    else
                    begin
                         if (iCurrSearchChoice = 1) then
                            iCurrSearchChoice := iNumChoices
                         else
                             Dec(iCurrSearchChoice);
                    end;

                    if (iNumChoices = 1) then
                       iCurrSearchChoice := 1;
                       {handles case iNumChoices = 1}
               end;
          end
          else
          begin
               {we have found the memo string!!!}
               if fDown then
                  iFindMemoLine := iThisLine-1
               else
                   iFindMemoLine := iThisLine+1;
               iCurrChoice := iCurrSearchChoice;
               MakeView;

               UnHighlightMemo(ChoiceForm.ReasonMemo);

               {find sThisLine in ReasonMemo and highlight part of it}
               for iMemoCounter := 0 to (ChoiceForm.ReasonMemo.Lines.Count-1) do
                   if (ChoiceForm.ReasonMemo.Lines.Strings[iMemoCounter] = sThisLine) then
                   begin
                        ChoiceForm.BringToFront;
                        ChoiceForm.ActiveControl := ChoiceForm.ReasonMemo;

                        ChoiceForm.ReasonMemo.SelStart := iFindMemoChar-2;
                        ChoiceForm.ReasonMemo.SelLength := Length(ChoiceForm.FindString.FindText);
                   end
                   else
                   begin
                        Inc(iFindMemoChar,
                            Length(ChoiceForm.ReasonMemo.Lines.Strings[iMemoCounter]) + 2);
                   end;

               ChoiceForm.Update;
          end;
     end;

     if not fHere then
     begin
          wOldCursor := Screen.Cursor;
          Screen.Cursor := crDefault;
          MessageDlg('Memo Line not found in choices',mtInformation,[mbOK],0);
          Screen.Cursor := wOldCursor;
     end;
end;

procedure TChoiceForm.FindStringFind(Sender: TObject);
var
   fDown, fMatchCase, fWholeWord : boolean;
   wOldCursor : integer;
begin
     try
        wOldCursor := Screen.Cursor;
        Screen.Cursor := crHourglass;

        UpdateReason(iCurrChoice);

        {check search direction, case match, whole word match}
        if (FindString.Options*[frDown])=[frDown] then fDown := True
        else fDown := False;

        if (FindString.Options*[frMatchCase])=[frMatchCase] then fMatchCase := True
        else fMatchCase := False;

        if (FindString.Options*[frWholeWord])=[frWholeWord] then fWholeWord := True
        else fWholeWord := False;

        case wFindFlag of
             FIND_SITE : SearchForSite(fDown,fMatchCase,fWholeWord);
             FIND_MEMO : SearchForMemo(fDown,fMatchCase,fWholeWord);
        end;

     finally
            Screen.Cursor := wOldCursor;
     end;
end;

procedure TChoiceForm.SelectAll1Click(Sender: TObject);
begin
     HighlightMemo(ReasonMemo);
     ActiveControl := ReasonMemo;
end;

procedure TChoiceForm.btnNextManyClick(Sender: TObject);
var
   iStepSize : integer;
begin
     UpdateReason(iCurrChoice);

     iStepSize := iNumChoices div CHOICE_BUTTON_NUM_STEPS;

     if (iCurrChoice+iStepSize) > iNumChoices then
        iCurrChoice := iNumChoices
     else
         Inc(iCurrChoice,iStepSize);

     MakeView;
     ReloadStageList;
end;

procedure TChoiceForm.btnPrevManyClick(Sender: TObject);
var
   iStepSize : integer;
begin
     UpdateReason(iCurrChoice);

     iStepSize := iNumChoices div CHOICE_BUTTON_NUM_STEPS;

     if (iCurrChoice-iStepSize) <= 1 then
        iCurrChoice := 1
     else
         Dec(iCurrChoice,iStepSize);

     MakeView;
     ReloadStageList;
end;

procedure TChoiceForm.btnDelChoiceClick(Sender: TObject);
var
   fCancel, fCancelPressed : boolean;
   wTmp : word;
begin
     if (iCurrChoice <> iNumChoices) then
     begin
          {give user option of saving to EMS file now}

          fCancel := False;

          if (fSelectionChange or fFlagSelectionChange)
          and ((ControlForm.R1.Items.Count > 0)
               or (ControlForm.R2.Items.Count > 0)
               or (ControlForm.R3.Items.Count > 0)
               or (ControlForm.R4.Items.Count > 0)
               or (ControlForm.R5.Items.Count > 0)
               or (ControlForm.Excluded.Items.Count > 0)
               or (ControlForm.Flagged.Items.Count > 0)
               or (ControlForm.Partial.Items.Count > 0)) then
          {if choices have changed and there are some items currently chosen}
          begin
               wTmp := MessageDlg
                  ('Save current site choices before Deleting Selections?',mtConfirmation,[mbYes,mbNo,mbCancel],0);

               case wTmp of
                    mrYes :
                    begin
                         ControlForm.Save1Click(Self,fCancel, fCancelPressed);
                         if fCancelPressed then
                            fCancel := True;
                    end;
                    mrCancel : fCancel := True;
               end;
          end;

          if not fCancel then
          begin
               {trim from iCurrChoice+1 to last choice}

               TrimChoices(iCurrChoice);
               UpdateLog2ListBoxes;

               ControlRes^.fStatusOk := False;
               {recalculate status and targetarea from site list boxes}

               ExecuteIrreplaceability(-1,False,False,True,True,'');
               ApplyHide;
               FitComponents2Form;
               LabelCountUpdate;
               Autosave;

               Makeview;

               fSelectionChange := True;
          end;
     end;
end;

procedure TChoiceForm.ComboStageChange(Sender: TObject);
begin
     UpdateReason(iCurrChoice);
end;

function TChoiceForm.CountExistingSelections : integer;
begin
     // count how many selections there are in the log
     Result := CountChoice(ChoiceLog);
end;

end.
