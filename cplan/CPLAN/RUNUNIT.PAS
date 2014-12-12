unit Rununit;

{$I STD_DEF.PAS}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Control, StdCtrls, Menus,
  Global;

type
  TRunForm = class(TForm)
    txtDatabase: TEdit;
    Label1: TLabel;
    txtTopic: TEdit;
    Label2: TLabel;
    btnStartTool: TButton;
    btnBatch: TButton;
    BatchBox: TListBox;
    ComboBox1: TComboBox;
    procedure FormActivate(Sender: TObject);
    procedure btnStartToolClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnBatchClick(Sender: TObject);
    (*procedure EndControlForm; {called by control unit to end session}*)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RunForm: TRunForm;



implementation

uses Em_newu1, Start, Toolmisc;

{$R *.DFM}

procedure TRunForm.FormActivate(Sender: TObject);
begin
     txtDatabase.Text := 'c:\car\urben\v003';
     txtTopic.Text := 'c:\winerms\newsubs.wmp';

     fUseParams := False;
end;

procedure TRunForm.btnStartToolClick(Sender: TObject);
begin
     RunForm.Visible := False;
     {ModalResult := mrOK;}
     {this frees the RunForm}

     ExecuteCPlanApplication(Application.Handle,{txtDatabase}ComboBox1.Text,txtTopic.Text);
     {this is the function call WinERMS uses to load the conservation tool
      from its main menu}
end;

(*
procedure TRunForm.EndControlForm;
begin
     ControlForm.Free;
     Debug2File(1,'ControlForm freed');

     RunForm.Visible := True;

     {ModalResult := mrOK;}
end;
*)

procedure TRunForm.FormCreate(Sender: TObject);
var
   sFile : string;
begin
     ClientWidth := btnStartTool.Left + btnStartTool.Width + 20;
     ClientHeight := btnStartTool.Top + btnStartTool.Height + 20;

     sFile := 'C:\WINERMS\DATABASE.TXT';

     if FileExists(sFile) then
        ComboBox1.Items.LoadFromFile(sFile);
end;

function SomeFlagsBox(ABox : TListBox) : boolean;
var
   iCount, iCountChar : integer;
begin
     {this function determines whether flags are
      specified in ABox (which is where the batch file is loaded)}

     Result := False;

     if (ABox.Items.Count > 0) then
        for iCount := 1 to ABox.Items.Count do
            if (Length(ABox.Items.Strings[iCount-1]) > 1) then
            begin
                 for iCountChar := 1 to Length(ABox.Items.Strings[iCount-1]) do
                     if (ABox.Items.Strings[iCount-1][iCountChar] = '-') then
                        Result := True;
            end;
end;

function ScanParamsLine(const sLine : string) : string;
var
   iCount, iCmdEnd : integer;
   cSearch : char;
   sCmd : string;
   fCmd : boolean;{is there a cmd}
begin
     {called to scan and note flags on a command line}


     iCount := 1;
     Result := '';

     while (iCount < Length(sLine))
     and (sLine[iCount] <> ' ')
     and (sLine[iCount] <> '-') do
         Inc(iCount);

     if (iCount > 1) then
        Result := Copy(sLine,1,iCount-1);
     {return the database path which is the first parameter
      and has no flag}




     iCount := 1;

     while (iCount < Length(sLine)) do
     begin
          cSearch := sLine[iCount];
          fCmd := False;

          if (cSearch = '-') then
          {search for a flag command}
          begin
               {find the end of this command}
               iCmdEnd := iCount + 1;

               while (iCmdEnd <= Length(sLine))
               and (sLine[iCmdEnd] <> '-')
               and (sLine[iCmdEnd] <> ' ') do
                   Inc(iCmdEnd);

               if (iCmdEnd > iCount+1) then
               begin
                    {extract cmd characters}
                    sCmd := Copy(sLine,iCount+1,iCmdEnd-iCount-1);
                    fCmd := True;
                    iCount := iCmdEnd;
               end;
          end;

          if fCmd then
             case sCmd[1] of
                  'r','R' : begin
                                 {auto report if there is at least 3
                                  chars in the cmd, eg. -rIfile}
                                 if (Length(sCmd) > 2) then
                                 begin
                                      {character after -r indicates report type}
                                      case sCmd[2] of
                                           'i','I' : begin
                                                          {irreplaceability report}
                                                          fRptIrr := True;
                                                          sRptIrr := Copy(sCmd,3,Length(sCmd)-2);
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
                                 if (Length(sCmd) > 1) then
                                 begin
                                      sUsePred := Copy(sCmd,3,Length(sCmd)-2);
                                      fUseParams := True;
                                 end;
                            end;
                  'N','n' : begin
                                 if (LowerCase(sCmd) = 'nouser') then
                                 begin
                                      fNoUser := True;
                                      {no user output or messages}
                                      fUseParams := True;
                                 end;
                            end;
             end;


          Inc(iCount);
     end;
end;

procedure TRunForm.btnBatchClick(Sender: TObject);
var
   sFile, sDB : string;
   iCount : integer;
   fAlreadyRun : boolean;
begin
     sFile := 'C:\CAR\BAT001.TXT';

     if InputQuery('Run Batch File','Specify Path and Filename',sFile) then
     if FileExists(sFile) then
     begin
          {load and execute each line of the batch file as a set of parameters}
          BatchBox.Items.Clear;
          BatchBox.Items.LoadFromFile(sFile);

          fAlreadyRun := False;

          if SomeFlagsBox(BatchBox) then
          begin
               for iCount := 1 to BatchBox.Items.Count do
               begin
                    {reset the flags here}
                    fNoUser := False;
                    fRptIrr := False;
                    fFlatTarg := False;
                    sRptIrr := '';
                    sUsePred := '';
                    fUseParams := False;

                    fKillOnRun := False;


                    sDB := ScanParamsLine(BatchBox.Items.Strings[iCount-1]);

                    if fAlreadyRun then
                       ReInitMem(true);

                    if (sDB <> '') then
                    begin
                         ExecuteCPlanApplication(Application.Handle,sDB,'no topic');
                         fAlreadyRun := True;

                         sDB := '';
                    end;
               end;

               Application.terminate;
          end
          else
              MessageDlg('No commands found in batch file',mtInformation,[mbOk],0);
     end
     else
         MessageDlg('No batch file found',mtInformation,[mbOk],0);
end;

end.
