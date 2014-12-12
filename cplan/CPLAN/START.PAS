unit Start;

{$I STD_DEF.PAS}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls;

type
  TStartForm = class(TForm)
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  StartForm: TStartForm;
  sDatabase, sTopic : string;

  fNoUser, fRptIrr, fFlatTarg, fKillOnRun : boolean;
  sRptIrr, sUsePred : string;

  fUseParams : boolean; {says whether to load command line parameters}


procedure run_me;

implementation

uses
    Em_newu1, Control, Rununit, Global,
    Toolmisc, rules;

{$R *.DFM}

function SomeFlags : boolean;
var
   iCount : integer;
begin
     {this function determines whether flags are
      specified on the command line}

     Result := False;

     if (ParamCount > 0) then
        for iCount := 1 to ParamCount do
            if (Length(ParamStr(iCount)) > 1) then
            begin
                 if (ParamStr(iCount)[1] = '-') then
                    Result := True;
            end;
end;

procedure ScanParams;
var
   iCount : integer;
   cSearch : char;
begin
     {called to scan and note flags on the command line}
     fLinkToArcView := False;

     fExecuteIrreplaceabilityAndDie := False;
     fExecuteMinsetAndDie := False;
     sExecuteMinsetFileName := '';


     if (ParamCount > 0) then
        for iCount := 1 to ParamCount do
        begin
             cSearch := ParamStr(iCount)[1];
             if (cSearch = '-')
             and (Length(ParamStr(iCount)) > 1) then
             begin
                  if (ParamStr(iCount) = '-irr') then
                     fExecuteIrreplaceabilityAndDie := True;


                  if (Copy(ParamStr(iCount),1,2) = '-m') then
                  begin
                       fExecuteMinsetAndDie := True;
                       sExecuteMinsetFileName := Copy(ParamStr(iCount),3,Length(ParamStr(iCount))-2);
                  end;

                  case ParamStr(iCount)[2] of
                       'A','a' : begin
                                      {CPlan is being called by ArcView}
                                      fLinkToArcView := True;
                                 end;
                       'r','R' : begin
                                      {auto report}
                                      if (Length(ParamStr(iCount)) > 3) then
                                      begin
                                           {character after -r indicates report type}
                                           case ParamStr(iCount)[3] of
                                                'i','I' : begin
                                                               {irreplaceability report}
                                                               fRptIrr := True;
                                                               sRptIrr := Copy(ParamStr(iCount),4,Length(ParamStr(iCount))-3);
                                                               fUseParams := True;
                                                          end;
                                           end;
                                      end;
                                 end;
                       't','T' : begin
                                      {use flat targets}
                                      fFlatTarg := True;
                                      fUseParams := True;
                                 end;
                       'p','P' : begin
                                      {specify predictor to use}
                                      if (Length(ParamStr(iCount)) > 2) then
                                      begin
                                           sUsePred := Copy(ParamStr(iCount),3,Length(ParamStr(iCount))-2);
                                           fUseParams := True;
                                      end;
                                 end;
                       'N','n' : begin
                                      if (ParamStr(iCount) = '-nouser')
                                      or (ParamStr(iCount) = '-NOUSER') then
                                      begin
                                           fNoUser := True;
                                           {no user output or messages}
                                           fUseParams := True;
                                      end;
                                 end;
                  end;
             end;
        end;
end;

procedure run_me;
begin
     Randomize;

     fNoUser := False;
     fRptIrr := False;
     fFlatTarg := False;
     sRptIrr := '';
     sUsePred := '';

     fUseParams := False;

     if SomeFlags then
     begin
          {we have some command line flags specified}
          sDatabase := ParamStr(1);

          ScanParams;

          fKillOnRun := True;

          ExecuteCPlanApplication(Application.Handle,sDatabase,sTopic);
     end
     else
     if (ParamCount = 2) then
     begin
          {there are two command line parameters,
           the command line parameters specify which
           Database and Topic to load the tool with}
          sDatabase := ParamStr(1);
          sTopic := ParamStr(2);

          ExecuteCPlanApplication(Application.Handle,sDatabase,sTopic);
     end
     else
     if (ParamCount > 2)
     or (ParamCount = 1) then
     begin
          sDatabase := ParamStr(1);
          sTopic := 'no topic';

          ExecuteCPlanApplication(Application.Handle,sDatabase,sTopic);
     end
     else
     begin
          Screen.Cursor := crDefault;
          MessageDlg('You must specify (at least) the database path as a calling parameter',
                     mtInformation,[mbOk],0);
          Application.Terminate;
     end;

     //if fExecuteIrreplaceabilityAndDie then
     //   ExecuteIrreplaceability(-1,False,False,True,True,'');

     if fExecuteMinsetAndDie then
     begin
          // bring up minset form
         try
            iMinsetFlag := MINSET_R1;
            RulesForm := TRulesForm.Create(Application);
            RulesForm.Show;
            // load minset
            RulesForm.LoadMinsetSpecification(ControlRes^.sDatabase + '\' + sExecuteMinsetFileName);

            // execute minset (don't show ending message)
            try
               Screen.Cursor := crHourglass;
               RulesForm.Visible := False;
               ControlForm.Visible := False;

               RulesForm.ExecuteSequence(False);

               Screen.Cursor := crDefault;
               RulesForm.Visible := True;
               ControlForm.Visible := True;

            except
                  Screen.Cursor := crDefault;
                  RulesForm.Visible := True;
                  ControlForm.Visible := True;
            end;
         finally
                RulesForm.Free;
         end;

     end;

     if fExecuteIrreplaceabilityAndDie or fExecuteMinsetAndDie then
        Application.Terminate;
end;

procedure TStartForm.FormActivate(Sender: TObject);
begin
     run_me;
end;

initialization


end.
