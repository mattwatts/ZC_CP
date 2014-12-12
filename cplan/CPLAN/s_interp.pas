unit s_interp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Menus
  {$IFDEF VER80}
  {$ELSE}
  , Dll_u1, Randtest, reports, highligh
  {$ENDIF};

type
  TSIForm = class(TForm)
    ScriptMemo: TMemo;
    Panel1: TPanel;
    btnReport: TButton;
    btnIrrep: TButton;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Load1: TMenuItem;
    Save1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    Script1: TMenuItem;
    Execute1: TMenuItem;
    CheckSyntax1: TMenuItem;
    OpenScript: TOpenDialog;
    SaveScript: TSaveDialog;
    LoadBox: TListBox;
    btnITarget: TButton;
    btnPCTarget: TButton;
    btnDeSelect: TButton;
    btnSelect: TButton;
    btnRandomSelect: TButton;
    btnRandomF2Targ: TButton;
    Commands1: TMenuItem;
    Report1: TMenuItem;
    Irrep1: TMenuItem;
    Memory1: TMenuItem;
    ITarget1: TMenuItem;
    PCTarget1: TMenuItem;
    Basic1: TMenuItem;
    Selection1: TMenuItem;
    Select1: TMenuItem;
    DeSelect1: TMenuItem;
    RandomSelect1: TMenuItem;
    SystemTest1: TMenuItem;
    RandomFeaturesToTarget1: TMenuItem;
    btnExecute: TButton;
    btnCheckSyntax: TButton;
    Contribution1: TMenuItem;
    SelectionLog1: TMenuItem;
    Resource1: TMenuItem;
    FileMenu1: TMenuItem;
    ShowMenu1: TMenuItem;
    ReportMenu1: TMenuItem;
    HighlightMenu1: TMenuItem;
    ShowTimer: TTimer;
    Minset1: TMenuItem;
    procedure Exit1Click(Sender: TObject);
    procedure Load1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure btnIrrepClick(Sender: TObject);
    procedure btnITargetClick(Sender: TObject);
    procedure btnPCTargetClick(Sender: TObject);
    procedure btnMemoryClick(Sender: TObject);
    procedure CheckSyntax1Click(Sender: TObject);
    function CheckSyntax : boolean;
    procedure Execute1Click(Sender: TObject);
    procedure ExecScript;
    procedure btnSelectClick(Sender: TObject);
    procedure btnDeSelectClick(Sender: TObject);
    procedure btnRandomSelectClick(Sender: TObject);
    procedure btnRandomF2TargClick(Sender: TObject);
    procedure Report1Click(Sender: TObject);
    procedure Irrep1Click(Sender: TObject);
    procedure Memory1Click(Sender: TObject);
    procedure ITarget1Click(Sender: TObject);
    procedure PCTarget1Click(Sender: TObject);
    procedure Select1Click(Sender: TObject);
    procedure DeSelect1Click(Sender: TObject);
    procedure RandomSelect1Click(Sender: TObject);
    procedure RandomFeaturesToTarget1Click(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
    procedure btnCheckSyntaxClick(Sender: TObject);
    procedure Contribution1Click(Sender: TObject);
    procedure SelectionLog1Click(Sender: TObject);
    procedure Resource1Click(Sender: TObject);
    procedure Minset1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SIForm: TSIForm;


function ExecuteMacroCmd(const sCmd : string) : boolean;
function IsValidCmd(const sCmd : string) : boolean;



implementation

uses
    Global, Control, Sf_irrep, Choosere,
    In_Order, resize, calcfld, Choices,
    Contribu, minset,
    ds, convert, defrqry, msetexpt;

{$R *.DFM}

function IsWhiteSpace(const sCmd : string) : boolean;
var
   iCount : integer;
   fComment, fAllSpace : boolean;
begin
     {if all characters are spaces or the first non-space character is the
      comment identifier}
     Result := True;
     fComment := False;
     fAllSpace := True;
     if (Length(sCmd) > 0) then
        for iCount := 1 to Length(sCmd) do
            if (not fComment)
            and fAllSpace then
            begin
                 if (sCmd[iCount] = ' ') then
                 else
                     if (sCmd[iCount] = '''') then
                        fComment := True
                     else
                         fAllSpace := False;
                         {this line has some other first character}
            end;

     if (not fComment)
     and (not fAllSpace) then
         Result := False;
         {line is not white space or a comment
          starting with '}
end;

{procedures that call each command}

procedure RunCmdRedundancyCheck;
var
   aDeferrals : Array_t;
begin
     try
        if not fContrDataDone then
           ExecuteIrreplaceability(-1,False,False,True,True,'');

        Deferrals2Array(aDeferrals);

        if (aDeferrals.lMaxSize > 0) then
           RedundancyCheck(aDeferrals,1);

        aDeferrals.Destroy;

     except
           Screen.Cursor := crDefault;

           MessageDlg('Exception in RunCmdRedundancyCheck',
                      mtError,[mbOk],0);
     end;
end;

procedure RunCmdMinset(const sStopCond, sSelectPerIter, sSelectTo, sSelectBest, sCmd : string);
var
   sLocalCmd, sLocalBest, sResLimit, sSQLCondition : string;
   iStopCond, iSelectPerIter, iStartChar, iSpacePos : integer;

   function ExtractSQLFileName(var sResLimit : string) : string;
   var
      iStringPos : integer;
   begin
        {extracts filename with .SQL extension if it exists,
         else set result to ''}
        result := '';

        if (Pos('.sql',LowerCase(sResLimit)) > 0) then
        begin
             {count down from the end of the string to the first space OR
              the first character in the string.
              make result the string after the space (or '') and make
              sResLimit the string before the space (or '')}
             iStringPos := Length(sResLimit);

             repeat
                   Dec(iStringPos);

             until (iStringPos = 1)
             or (sResLimit[iStringPos] = ' ');

             if (iStringPos > 1) then
             begin
                  Result := Copy(sResLimit,iStringPos+1,Length(sResLimit)-iStringPos);
                  sResLimit := Copy(sResLimit,1,iStringPos-1);
             end;
        end;
   end;

begin
     {apply the sCmd conditions and run the Minset command}
     try
        MinsetForm := TMinsetForm.Create(Application);

        {adjust components on form to reflect sCmd conditions}
        {set stopping condition}
        try
           iStopCond := StrToInt(sStopCond);
        except
              iStopCond := 10;
        end;
        if (iStopCond = 0) then
           MinsetForm.LoopGroup.ItemIndex := 0
        else
        begin
             MinsetForm.LoopGroup.ItemIndex := 2;
             MinsetForm.SpinIter.Value := iStopCond;
        end;
        {set selections per iteration}
        try
           iSelectPerIter := StrToInt(sSelectPerIter);
        except
              iSelectPerIter := 1;
        end;
        MinsetForm.SpinSelect.Value := iSelectPerIter;
        {set select to}
        if (UpperCase(sSelectTo) = 'M') then
           MinsetForm.RadioSelect.ItemIndex := 1
        else
            MinsetForm.RadioSelect.ItemIndex := 0;
        {set select best}
        sLocalBest := UpperCase(sSelectBest);
        sLocalCmd := UpperCase(Copy(sCmd,7,Length(sCmd)-6));
        if (sLocalBest = 'I') then
        begin
             MinsetForm.RadioField.ItemIndex := 0;

             iStartChar := Pos('I',sLocalCmd);
        end
        else
        if (sLocalBest = 'S') then
        begin
             MinsetForm.RadioField.ItemIndex := 1;

             iStartChar := Pos('S',sLocalCmd);
        end
        else
        if (sLocalBest = 'W') then
        begin
             MinsetForm.RadioField.ItemIndex := 2;

             iStartChar := Pos('W',sLocalCmd);
        end
        else
        begin
             MinsetForm.RadioField.ItemIndex := 3;

             iStartChar := Pos('P',sLocalCmd);
        end;
        {set resource limit}
        if (iStartChar < Length(sLocalCmd)) then
        begin
             sResLimit := Copy(sLocalCmd,
                               iStartChar+1,
                               Length(sLocalCmd)-iStartChar);
             sSQLCondition := ExtractSQLFileName(sResLimit);
        end
        else
        begin
             sResLimit := '';
             sSQLCondition := '';
        end;
        if (sResLimit <> '') then
        begin
             iSpacePos := Pos(' ',sResLimit);
             MinsetExpertForm.ComboResource.Text := Copy(sResLimit,1,iSpacePos-1);
             MinsetExpertForm.SpinResource.Value := StrToInt(Copy(sResLimit,iSpacePos+1,Length(sResLimit)-iSpacePos));
             MinsetExpertForm.CheckResourceLimit.Checked := True;
        end;
        {set SQL condition}
        if (sSQLCondition <> '') then
        begin
             if FileExists(sSQLCondition) then
             begin
                  MinsetForm.SQLMemo.Lines.LoadFromFile(sSQLCondition);
                  MinsetForm.CheckSQLCondition.Checked := True;
             end;

             if FileExists(ControlRes^.sDatabase + '\' + sSQLCondition) then
             begin
                  MinsetForm.SQLMemo.Lines.LoadFromFile(sSQLCondition);
                  MinsetForm.CheckSQLCondition.Checked := True;
             end;
        end;

        MinsetForm.Show;
        //ExecuteMinset;

     finally
            MinsetForm.Free;
     end;

end;

procedure RunCmdResource;
var
   iCount : integer;
   sField : string;
begin
     {bring up the resource form}
     try
        ChooseResForm := TChooseResForm.Create(Application);

        if (ChooseResForm.CResBox.Items.Count > 0) then
        begin
             ChooseResForm.Show;

             {show info on each resource it contains}
             for iCount := 0 to ChooseResForm.CResBox.Items.Count-1 do
             begin
                  sField := ChooseResForm.CResBox.Items.Strings[iCount];

                  ProcessTimberResource(sField,TRUE);
             end;

        end;
     {dispose of recource form}
     finally
            ChooseResForm.Free;
     end;
end;

procedure RunCmdSelectionLog(const iSelectionsToKeep : integer);
begin
     {bring up the selection log form}
     if (ChoiceForm.ChoiceLog.Items.Count > 0) then
     begin
          iCurrChoice := 1;
          iPrevChoice := -1;

          ChoiceForm.Show;


          {move to selection iSelectionsToKeep}
          if (iSelectionsToKeep <= 0) then
             {choose a random selection to go to}
              iCurrChoice := Random(iNumChoices + 1)
          else
          begin
               {go to selection iSelectionsToKeep}
               if (iSelectionsToKeep > iNumChoices) then
                  iCurrChoice := iNumChoices
               else
                   iCurrChoice := iSelectionsToKeep;
          end;
          MakeView;

          {press 'remove following selections'}
          TrimChoices(iCurrChoice);
          UpdateLog2ListBoxes;
          ExecuteIrreplaceability(-1,False,False,True,True,'');
          ApplyHide;
          FitComponents2Form;
          LabelCountUpdate;
          Autosave;
          Makeview;

          {dispose of selection log form}
          ChoiceForm.Visible := False;
     end;
end;

procedure RunCmdContribution;
var
   iSG, iPD, iVG, iHG, iSI : integer;

  procedure RedrawContrib;
  begin
       with ContributionForm do
       begin
            Panel1.Width := ClientWidth;
            GraphImage.Width := ClientWidth;
            GraphImage.Height := ClientHeight - Panel1.Height;

            {This is where we must repaint the screen}

            labelSiteName.Caption := '';
            labelValue.Caption := '';
            {reset labels which track mouse movement over canvas}

            case iGraphState of
                 BY_FEATURE : DrawFeatureBars(iSiteIndex);
                 BY_SITE : DrawSiteBars;
            end;
       end;
  end;

begin
     {this command has no effect if there are no deferred sites}
     Screen.Cursor := crHourglass;
     {bring up the contribution form}
     if ((ControlForm.Mandatory.Items.Count +
          ControlForm.Negotiated.Items.Count +
          ControlForm.Partial.Items.Count) > 0) then
     begin
          if not fContrDataDone then
             ExecuteIrreplaceability(-1,False,False,True,True,'');

          try
             ContributionForm := TContributionForm.Create(Application);
             with ContributionForm do
             begin
                  Show;


                  {switch between all possible variant screen modes}
                  for iSG := 1 to selectGradient.Items.Count do
                      for iPD := 1 to selectPlotData.Items.Count do
                          for iVG := 0 to 1 do
                              for iHG := 0 to 1 do
                                  for iSI := 1 to GraphContribution.Features.lMaxSize do
                                  begin
                                       selectGradient.ItemIndex := iSG;
                                       selectPlotData.ItemIndex := iPD;
                                       checkVertGrid.Checked := boolean(iVG);
                                       checkHorzGrid.Checked := boolean(iHG);
                                       iSiteIndex := iSI;

                                       {click on each deferred site in
                                        turn with every variant above,
                                        then click again to get back to the sites}

                                       {show feature graph for site iSiteIndex}
                                       iGraphState := BY_FEATURE;
                                       RedrawContrib;

                                       {show site graph with these settings}
                                       iGraphState := BY_SITE;
                                       RedrawContrib;
                                  end;


                  {bring up features 2 target form}
                  {do some things on features 2 target ?}
                  {dispose features 2 target form}

                  {call other code here to launch features 2 target form}
             end;
          finally
                 {dispose contribution form}
                 ContributionForm.Free;
                 Screen.Cursor := crDefault;
          end;
     end;
end;

procedure RunCmdSelect(const sType, sCount : string);
var
   iSelCount : integer;
   fLoadHighlight : boolean;

   procedure _Select(ABox,AGeoBox : TListBox);
   var
      iCount : integer;
   begin
        UnHighlight(ControlForm.Available,FALSE);

        if fLoadHighlight then
        begin
             if FileExists(sCount) then
                LoadHighlight(sCount,LOAD_GEOCODE,True)
        end
        else
        begin
             if (iSelCount = 0)
             or (iSelCount > ControlForm.Available.Items.Count) then
                iSelCount := ControlForm.Available.Items.Count;

             if (iSelCount > 0) then
                for iCount := 0 to (iSelCount-1) do
                    ControlForm.Available.Selected[iCount] := True;
        end;

        ControlForm.MoveGroup(ControlForm.Available,
                              ControlForm.AvailableKey,
                              ABox,AGeoBox,
                              FALSE {no user to click dialog buttons});
   end;

begin
     try
        fLoadHighlight := False;
        iSelCount := StrToInt(sCount);

     except
           iSelCount := 0;
           if (sCount <> '') then
              fLoadHighlight := True;
     end;

     if (UpperCase(sType) = 'NE') then
        _Select(ControlForm.Negotiated,ControlForm.NegotiatedKey)
     else
     if (UpperCase(sType) = 'MA') then
        _Select(ControlForm.Mandatory,ControlForm.MandatoryKey)
     else
     if (UpperCase(sType) = 'EX') then
        _Select(ControlForm.Excluded,ControlForm.ExcludedKey)
     else
     if (UpperCase(sType) = 'PD') then
        _Select(ControlForm.Partial,ControlForm.PartialKey)
     else
     if (UpperCase(sType) = 'FL') then
        _Select(ControlForm.Flagged,ControlForm.FlaggedKey);
end;

procedure RunCmdDeSelect(const sType, sCount : string);
var
   iSelCount : integer;
   fLoadHighlight : boolean;

   procedure _DeSelect(ABox,AGeoBox : TListBox);
   var
      iCount : integer;
   begin
        UnHighlight(ABox,FALSE);

        if fLoadHighlight then
        begin
             if FileExists(sCount) then
                LoadHighlight(sCount,LOAD_GEOCODE,True);
        end
        else
        begin
             if (iSelCount = 0)
             or (iSelCount > ABox.Items.Count) then
                iSelCount := ABox.Items.Count;

             if (iSelCount > 0) then
                for iCount := 0 to (iSelCount-1) do
                    ABox.Selected[iCount] := True;
        end;

        ControlForm.MoveGroup(ABox,AGeoBox,ControlForm.Available,
                  ControlForm.AvailableKey,
                  FALSE {no user to click dialog buttons});
   end;

begin
     try
        fLoadHighlight := False;
        iSelCount := StrToInt(sCount);

     except
           iSelCount := 0;
           if (sCount <> '') then
              fLoadHighlight := True;
     end;

     if (UpperCase(sType) = 'NE') then
        _DeSelect(ControlForm.Negotiated,ControlForm.NegotiatedKey)
     else
     if (UpperCase(sType) = 'MA') then
        _DeSelect(ControlForm.Mandatory,ControlForm.MandatoryKey)
     else
     if (UpperCase(sType) = 'EX') then
        _DeSelect(ControlForm.Excluded,ControlForm.ExcludedKey)
     else
     if (UpperCase(sType) = 'PD') then
        _DeSelect(ControlForm.Partial,ControlForm.PartialKey)
     else
     if (UpperCase(sType) = 'FL') then
        _DeSelect(ControlForm.Flagged,ControlForm.FlaggedKey);
end;

procedure RunCmdRandomSelect;
begin
     RandomSelect(ControlForm.Available.Items.Count +
                  ControlForm.Negotiated.Items.Count +
                  ControlForm.Mandatory.Items.Count +
                  ControlForm.Partial.Items.Count +
                  ControlForm.Flagged.Items.Count +
                  ControlForm.Excluded.Items.Count);
end;

procedure RunCmdRandomF2T;
begin
     RandomFeatures2Target;
end;

procedure RunCmdReport(const sType, sOutFile : string);
begin
     if (UpperCase(sType) = 'IRREP') then
     begin
          ReportSites(sOutFile, {filename to report to}
                       'REPORT IRREP ' + sOutFile {description for this report},
                       FALSE {do not prompt to overwrite if file exists},
                       ControlForm.OutTable {site summary table to use},
                       iSiteCount {total number of sites},
                       SiteArr,
                       ControlRes,
                       '');
     end
     else
     if (UpperCase(sType) = 'TARGET') then
     begin
          ReportFeatures(sOutFile, {filename to report to}
                        'REPORT TARGET ' + sOutFile {description for this report},
                        FALSE {do not prompt to overwrite if file exists},
                        ControlForm.UseFeatCutOffs.Checked,
                        FeatArr, iFeatureCount, rPercentage,
                        '');
     end
     else
     if (UpperCase(sType) = 'PARTIAL') then
     begin
          ReportPartial(sOutFile,
                        'REPORT PARTIAL ' + sOutFile,
                        FALSE,
                        ControlForm.ReportBox,
                        ControlForm.PartialKey,
                        SiteArr, FeatArr, OrdSiteArr, OrdFeatArr);
     end;
end;

procedure RunCmdPCTarget(const sPC : string);
begin
     ControlForm.TargetPercent.Text := sPC;

     if ControlForm.UseFeatCutOffs.Checked then
        ControlForm.UseFeatCutOffs.Checked := False;
end;

procedure RunCmdITarget;
begin
     if not ControlForm.UseFeatCutOffs.Checked then
        ControlForm.UseFeatCutOffs.Checked := True;
end;
procedure RunCmdIrrep;
begin
     ExecuteIrreplaceability(-1,False,False,True,True,'');
end;
procedure RunCmdMemory;
begin
     {? record memory allocation in log file, c:\mem.log implement}
end;

function ExtractLineParam(const sCmd : string;
                          const iParam : integer) : string;
var
   iStartPos, iEndPos, iPos, iCount : integer;

   procedure PassNextSpace;
   var
      fStop : boolean;
   begin
        if (iPos < Length(sCmd)) then
        begin
             if (sCmd[iPos] = ' ') then
                Inc(iPos);

             fStop := False;
             if (iPos < Length(sCmd)) then
             repeat
                   if (sCmd[iPos] <> ' ') then
                      Inc(iPos)
                   else
                       fStop := True;

                   if (iPos > Length(sCmd)) then
                      fStop := True;

             until fStop;
        end;
   end;

begin
     {extract paramater iParam from sCmp,
      0 is first parameter on sCmd}

     iPos := 1;

     if (iParam > 0) then
        for iCount := 1 to iParam do
            PassNextSpace;

     iStartPos := iPos;

     PassNextSpace;

     iEndPos := iPos;

     if (sCmd[iEndPos] = ' ') then
        Dec(iEndPos);

     if (sCmd[iStartPos] = ' ') then
        Inc(iStartPos);

     Result := Copy(sCmd,iStartPos,iEndPos-iStartPos+1);
end;

function ExecuteMacroCmd(const sCmd : string) : boolean;
var
   sZeroParam, sFirstParam, sSecondParam : string;
   iValue : integer;

   function IsCmd(const sCommand, sMiniCommand : string) : boolean;
   begin
        if (UpperCase(sZeroParam) = sCommand)
        or (UpperCase(sZeroParam) = sMiniCommand) then
           Result := True
        else
            Result := False;
   end;


begin
     if IsWhiteSpace(sCmd) then
        Result := True
     else
     begin
          Result := False;
          {make command invalid until proven otherwise}

          sZeroParam := ExtractLineParam(sCmd,0);

          if IsCmd('REPORT','RPT') then
          begin
               {report command has 3 parameters}
               sFirstParam := ExtractLineParam(sCmd,1);
               sSecondParam := ExtractLineParam(sCmd,2);

               if ((sFirstParam = 'IRREP') or (sFirstParam = 'TARGET')
                   or (sFirstParam = 'PARTIAL'))
               and (sSecondParam <> '') then
               begin
                    Result := True;
                    {this is a valid REPORT command line}
                    RunCmdReport(sFirstParam,sSecondParam);
               end;
          end
          else
          if IsCmd('PCTARGET','PCT') then
          begin
               sFirstParam := ExtractLineParam(sCmd,1);

               try
                  if (StrToInt(sFirstParam) > 0) then
                  begin
                       Result := True;
                       {this is a valid PCTARGET value}
                       RunCmdPCTarget(sFirstParam);
                  end;
               except
               end;
          end
          else
          if IsCmd('ITARGET','IT') then
          begin
               Result := True;
               RunCmdITarget;
          end
          else
          if IsCmd('IRREP','IRR') then
          begin
               Result := True;
               RunCmdIrrep;
          end
          else
          if IsCmd('MEMORY','MEM') then
          begin
               Result := True;
               RunCmdMemory;
          end
          else
          if IsCmd('SELECT','SEL') then
          begin
               Result := True;
               RunCmdSelect(ExtractLineParam(sCmd,1),
                            ExtractLineParam(sCmd,2));
          end
          else
          if IsCmd('DESELECT','DESEL') then
          begin
               Result := True;
               RunCmdDeSelect(ExtractLineParam(sCmd,1),
                              ExtractLineParam(sCmd,2));
          end
          else
          if IsCmd('RANDOMSELECT','RNDSEL') then
          begin
               Result := True;
               RunCmdRandomSelect;
          end
          else
          if IsCmd('RANDOMFEATURES2TARGET','RNDF2T') then
          begin
               Result := True;
               RunCmdRandomF2T;
          end
          else
          if IsCmd('CONTRIBUTION','CONTR') then
          begin
               Result := True;
               RunCmdContribution;
          end
          else
          if IsCmd('SELECTIONLOG','SELLOG') then
          begin
               Result := True;

               sFirstParam := ExtractLineParam(sCmd,1);
               if (UpperCase(sFirstParam) = 'RND') then
                  iValue := 0
               else
               try
                  iValue := StrToInt(sFirstParam);
               except
                     iValue := 0;
               end;
               RunCmdSelectionLog(iValue);
          end
          else
          If IsCmd('RESOURCE','RES') then
          begin
               Result := True;
               RunCmdResource;
          end
          else
          if IsCmd('MINSET','MINSET') then
          begin
               Result := True;
               RunCmdMinset(ExtractLineParam(sCmd,1), {stopping condition}
                            ExtractLineParam(sCmd,2), {selections per iteration}
                            ExtractLineParam(sCmd,3), {select to}
                            ExtractLineParam(sCmd,4), {select best}
                            sCmd); {Resource Limit and SQL Condition if applicable}
          end;

          {
          These are the possible macro commands

          REPORT IRREP|TARGET filename
          IRREP
          ITARGET
          PCTARGET n
          MEMORY

          SELECT ToStatus(R1,R2,Pd,Fl,Ex) Count(or All Available)
          DESELECT FromStatus(R1,R2,Pd,Fl,Ex) Count(or All)
          RANDOMSELECT
          RANDOMFEATURES2TARGET
          CONTRIBUTION
          SELECTIONLOG
          RESOURCE

          These are the shortened versions

          RPT
          IRR
          IT
          PCT
          MEM

          SEL
          DESEL
          RNDSEL
          RNDF2T
          CONTR
          SELLOG
          RES
          }

     end;
end;

function IsValidCmd(const sCmd : string) : boolean;
var
   sZeroParam, sFirstParam, sSecondParam : string;


   function IsCmd(const sCommand, sMiniCommand : string) : boolean;
   begin
        if (UpperCase(sZeroParam) = sCommand)
        or (UpperCase(sZeroParam) = sMiniCommand) then
           Result := True
        else
            Result := False;
   end;


begin
     if IsWhiteSpace(sCmd) then
        Result := True
     else
     begin
          Result := False;
          {make command invalid until proven otherwise}

          sZeroParam := ExtractLineParam(sCmd,0);

          if IsCmd('REPORT','RPT') then
          begin
               {report command has 3 parameters}
               sFirstParam := ExtractLineParam(sCmd,1);
               sSecondParam := ExtractLineParam(sCmd,2);

               if ((sFirstParam = 'IRREP') or (sFirstParam = 'TARGET')
                   or (sFirstParam = 'PARTIAL'))
               and (sSecondParam <> '') then
                   Result := True;
                   {this is a valid REPORT command line}
          end
          else
          if IsCmd('PCTARGET','PCT') then
          begin
               sFirstParam := ExtractLineParam(sCmd,1);

               try
                  if (StrToInt(sFirstParam) > 0) then
                     Result := True;
                     {this is a valid PCTARGET value}
               except
               end;
          end
          else
          if IsCmd('ITARGET','IT') then
             Result := True
          else
          if IsCmd('IRREP','IRR') then
             Result := True
          else
          if IsCmd('MEMORY','MEM') then
             Result := True
          else
          if IsCmd('RANDOMSELECT','RNDSEL') then
             Result := True
          else
          if IsCmd('RANDOMFEATURES2TARGET','RNDF2T') then
             Result := True
          else
          if IsCmd('SELECT','SEL') then
          begin
               if (Length(ExtractLineParam(sCmd,1)) = 2) then
                  Result := True;
          end
          else
          if IsCmd('DESELECT','DESEL') then
          begin
               if (Length(ExtractLineParam(sCmd,1)) = 2) then
                  Result := True;
          end
          else
          if IsCmd('CONTRIBUTION','CONTR') then
             Result := True
          else
          if IsCmd('SELECTIONLOG','SELLOG') then
             Result := True
          else
          If IsCmd('RESOURCE','RES') then
             Result := True
          else
          if IsCmd('MINSET','MINSET') then
             Result := True;

          {
          These are the possible macro commands

          REPORT IRREP|TARGET filename
          IRREP
          ITARGET
          PCTARGET n
          MEMORY

          SELECT ToStatus(R1,R2,Pd,Fl,Ex) Count(or All Available)
          DESELECT FromStatus(R1,R2,Pd,Fl,Ex) Count(or All)
          RANDOMSELECT
          RANDOMFEATURES2TARGET
          CONTRIBUTION
          SELECTIONLOG
          RESOURCE

          These are the shortened versions

          RPT
          IRR
          IT
          PCT
          MEM

          SEL
          DESEL
          RNDSEL
          RNDF2T
          CONTR
          SELLOG
          RES
          }

     end;
end;

procedure TSIForm.Exit1Click(Sender: TObject);
begin
     ModalResult := mrOk;
end;

procedure TSIForm.Load1Click(Sender: TObject);
begin
     {load a script}

     if OpenScript.Execute
     and FileExists(OpenScript.FileName) then
     begin
          LoadBox.Items.Clear;
          LoadBox.Items.LoadFromFile(OpenScript.FileName);
          ScriptMemo.Lines := LoadBox.Items;
          LoadBox.Items.Clear;
     end;
end;

procedure TSIForm.FormCreate(Sender: TObject);
begin
     OpenScript.InitialDir := ControlRes^.sWorkingDirectory;
     SaveScript.InitialDir := ControlRes^.sWorkingDirectory;
end;

procedure TSIForm.Save1Click(Sender: TObject);
begin
     if SaveScript.Execute then
     begin
          if not FileExists(SaveScript.FileName) then
          begin
               LoadBox.Items.Clear;
               LoadBox.Items := ScriptMemo.Lines;
               LoadBox.Items.SaveToFile(SaveScript.FileName);
               LoadBox.Items.Clear;
          end
          else
          begin
               {file exists}
               MessageDlg('Cannot create ' + SaveScript.FileName +
                          ' (file exists)',mtInformation,[mbOk],0);
          end;
     end;

end;

procedure TSIForm.btnReportClick(Sender: TObject);
begin
     ScriptMemo.Lines.Add('REPORT ');

     MessageDlg('Enter 2 parameters;' + Chr(13) + Chr(10) +
                '  type (IRREP, TARGET or PARTIAL)' + Chr(13) + Chr(10) +
                '  filename',mtInformation,[mbOk],0);

     ScriptMemo.SetFocus;
end;

procedure TSIForm.btnIrrepClick(Sender: TObject);
begin
     ScriptMemo.Lines.Add('IRREP');

     ScriptMemo.SetFocus;
end;

procedure TSIForm.btnITargetClick(Sender: TObject);
begin
     ScriptMemo.Lines.Add('ITARGET');

     ScriptMemo.SetFocus;
end;

procedure TSIForm.btnPCTargetClick(Sender: TObject);
begin
     ScriptMemo.Lines.Add('PCTARGET ');

     MessageDlg('Enter 1 parameter;' + Chr(13) + Chr(10) +
                '  % value (0 to 100)',mtInformation,[mbOk],0);

     ScriptMemo.SetFocus;
end;

procedure TSIForm.btnMemoryClick(Sender: TObject);
begin
     ScriptMemo.Lines.Add('MEMORY');

     ScriptMemo.SetFocus;
end;

procedure TSIForm.CheckSyntax1Click(Sender: TObject);
begin
     if CheckSyntax then
        MessageDlg('Syntax is correct',mtInformation,[mbOk],0);
end;

function TSIForm.CheckSyntax : boolean;
var
   iCount : integer;
   fStop, fValid : boolean;
begin
     if (ScriptMemo.Lines.Count > 0) then
     begin
          Screen.Cursor := crHourglass;

          iCount := 0;
          fStop := False;
          fValid := True;

          repeat
                if IsValidCmd(ScriptMemo.Lines.Strings[iCount]) then
                   Inc(iCount)
                else
                begin
                     {this line is not a valid command}
                     fStop := True;
                     fValid := False;
                     Screen.Cursor := crDefault;
                     MessageDlg('Syntax error on line ' + IntToStr(iCount+1),
                                mtInformation,[mbOk],0);

                     {add code to highlight this line in the memo}
                end;

                if (iCount > (ScriptMemo.Lines.Count-1)) then
                   fStop := True;

          until fStop;

          Screen.Cursor := crDefault;
          {if fValid then
             MessageDlg('Syntax is correct',mtInformation,[mbOk],0);}
     end;

     Result := fValid;
end;

procedure TSIForm.Execute1Click(Sender: TObject);
begin
     if CheckSyntax then
        ExecScript;
end;

procedure TSIForm.ExecScript;
var
   iCount : integer;
   fStop, fValid : boolean;
begin
     if (ScriptMemo.Lines.Count > 0) then
     begin
          Screen.Cursor := crHourglass;

          Randomize;

          iCount := 0;
          fStop := False;
          fValid := True;

          repeat
                if ExecuteMacroCmd(ScriptMemo.Lines.Strings[iCount]) then
                   Inc(iCount)
                else
                begin
                     {this line is not a valid command}
                     fStop := True;
                     fValid := False;
                     Screen.Cursor := crDefault;
                     MessageDlg('Syntax error on line ' + IntToStr(iCount+1),
                                mtInformation,[mbOk],0);

                     {add code to highlight this line in the memo}
                end;

                if (iCount > (ScriptMemo.Lines.Count-1)) then
                   fStop := True;

          until fStop;

          Screen.Cursor := crDefault;
          {if fValid then
             MessageDlg('Syntax is correct',mtInformation,[mbOk],0);}
     end;
end;

procedure TSIForm.btnSelectClick(Sender: TObject);
begin
     ScriptMemo.Lines.Add('SELECT ');

     MessageDlg('Enter 2 parameters;' + Chr(13) + Chr(10) +
                '  ToStatus (NR,MR,PR,Fl,Ex)' + Chr(13) + Chr(10) +
                '  count (or All)',mtInformation,[mbOk],0);

     ScriptMemo.SetFocus;
end;

procedure TSIForm.btnDeSelectClick(Sender: TObject);
begin
     ScriptMemo.Lines.Add('DESELECT ');

     MessageDlg('Enter 2 parameters;' + Chr(13) + Chr(10) +
                '  FromStatus (NR,MR,PR,Fl,Ex)' + Chr(13) + Chr(10) +
                '  count (or All)',mtInformation,[mbOk],0);

     ScriptMemo.SetFocus;
end;

procedure TSIForm.btnRandomSelectClick(Sender: TObject);
begin
     ScriptMemo.Lines.Add('RANDOMSELECT');

     ScriptMemo.SetFocus;
end;

procedure TSIForm.btnRandomF2TargClick(Sender: TObject);
begin
     ScriptMemo.Lines.Add('RANDOMFEATURES2TARGET');

     ScriptMemo.SetFocus;
end;

procedure TSIForm.Report1Click(Sender: TObject);
begin
     btnReportClick(self);
end;

procedure TSIForm.Irrep1Click(Sender: TObject);
begin
     btnIrrepClick(self);
end;

procedure TSIForm.Memory1Click(Sender: TObject);
begin
     btnMemoryClick(self);
end;

procedure TSIForm.ITarget1Click(Sender: TObject);
begin
     btnITargetClick(self);
end;

procedure TSIForm.PCTarget1Click(Sender: TObject);
begin
     btnPCTargetClick(self);
end;

procedure TSIForm.Select1Click(Sender: TObject);
begin
     btnSelectClick(self);
end;

procedure TSIForm.DeSelect1Click(Sender: TObject);
begin
     btnDeSelectClick(self);
end;

procedure TSIForm.RandomSelect1Click(Sender: TObject);
begin
     btnRandomSelectClick(self);
end;

procedure TSIForm.RandomFeaturesToTarget1Click(Sender: TObject);
begin
     btnRandomF2TargClick(self);
end;

procedure TSIForm.btnExecuteClick(Sender: TObject);
begin
     Execute1Click(self);
end;

procedure TSIForm.btnCheckSyntaxClick(Sender: TObject);
begin
     CheckSyntax1Click(self);
end;

procedure TSIForm.Contribution1Click(Sender: TObject);
begin
     ScriptMemo.Lines.Add('CONTRIBUTION');

     ScriptMemo.SetFocus;
end;

procedure TSIForm.SelectionLog1Click(Sender: TObject);
begin
     ScriptMemo.Lines.Add('SELECTIONLOG ');

     MessageDlg('Enter 1 parameter;' + Chr(13) + Chr(10) +
                '  selection to trim after (or RND)',mtInformation,[mbOk],0);

     ScriptMemo.SetFocus;
end;

procedure TSIForm.Resource1Click(Sender: TObject);
begin
     ScriptMemo.Lines.Add('RESOURCE');

     ScriptMemo.SetFocus;
end;

procedure TSIForm.Minset1Click(Sender: TObject);
begin
     ScriptMemo.Lines.Add('MINSET ');

     MessageDlg('Enter 6 parameters;' + Chr(13) + Chr(10) +
                '  Stopping Condition (0=until all satisfied, x=x iterations' + Chr(13) + Chr(10) +
                '  Selections Per Iteration (x iterations)' + Chr(13) + Chr(10) +
                '  Select To (N or M)' + Chr(13) + Chr(10) +
                '  Select Best (I,S,W or P)' + Chr(13) + Chr(10) +
                '  Resouce Limit(Field %ToAllowDeferred or leave blank)' + Chr(13) + Chr(10) +
                '  SQL Condition(file.sql or leave blank',
                mtInformation,[mbOk],0);

     ScriptMemo.SetFocus;
end;

end.
