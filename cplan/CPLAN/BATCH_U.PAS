unit Batch_u;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls;

type
  TBatchForm = class(TForm)
    BatchBox: TListBox;
    Panel1: TPanel;
    btnLoad: TButton;
    btnExecute: TButton;
    OpenBatch: TOpenDialog;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BatchForm: TBatchForm;
  iCurrBatLine : integer;
  PCurrExe : PChar;

implementation

uses
    ToolHelp;

{$R *.DFM}


procedure RunTheBatch;
begin
     GetMem(PCurrExe,256);

     BatchForm.Timer1.Enabled := True;

     iCurrBatLine := 0;
end;

procedure EndTheBatch;
begin
     FreeMem(PCurrExe,256);

     BatchForm.Timer1.Enabled := False;

     iCurrBatLine := -1;
end;

procedure TBatchForm.FormCreate(Sender: TObject);
begin
     iCurrBatLine := -1;

     if (ParamCount = 1) then
     begin
          BatchBox.Items.LoadFromFile(ParamStr(1));
          RunTheBatch;
     end
     else
         MessageDlg('Load a batch file then Execute',
                    mtInformation,[mbOk],0);
end;

procedure TBatchForm.btnLoadClick(Sender: TObject);
begin
     with OpenBatch do
     begin
          InitialDir := 'C:\';
          FileName := 'BATCH.TXT';

          if Execute then
          begin
               BatchBox.Items.LoadFromFile(FileName);
          end;
     end;
end;

procedure TBatchForm.btnExecuteClick(Sender: TObject);
begin
     RunTheBatch;
end;

function MyFindModule(PExe : PChar) : boolean;
var
   me : TModuleEntry;
   x : THandle;
begin
     Result := True;

     x := ModuleFindName(@me,PExe);

     if (pointer(x) = nil) then
        Result := False;
end;

procedure TrimExeName(var sExe : string;
                      PCmd : PChar);
var
   sCmd : string;
   iSlashPos, iSpacePos : integer;
begin
     sCmd := StrPas(PCmd);

     iSpacePos := 1;

     while (sCmd[iSpacePos] <> ' ')
     and (iSpacePos < Length(sCmd)) do
         Inc(iSpacePos);

     if (iSpacePos < Length(sCmd)) then
        iSlashPos := iSpacePos
     else
         iSlashPos := Length(sCmd);

     while (sCmd[iSlashPos] <> '\')
     and (iSlashPos > 1) do
         Dec(iSlashPos);

     if (iSlashPos > 0)
     and (iSlashPos < Length(sCmd)) then
         sExe := Copy(sCmd,iSlashPos+1,iSpacePos-iSlashPos-1)
     else
         sExe := sCmd;

     {MessageDlg('trim exe name sCmd ' + sCmd + ' sExe ' + sExe,
                mtInformation,[mbOk],0);}
end;

procedure TBatchForm.Timer1Timer(Sender: TObject);
var
   PCmdLine : PChar;
   sExe : string;
   wResult : word;
begin
     GetMem(PCmdLine,256);

     if (iCurrBatLine >= BatchBox.Items.Count) then
        EndTheBatch
     else
     begin
          if (BatchBox.Items.Count > 0) then
          begin
               if (iCurrBatLine = 0) then
               begin
                    StrPCopy(PCmdLine,BatchBox.Items.Strings[iCurrBatLine]);
                    wResult := WinExec(PCmdLine,SW_SHOWMAXIMIZED);
                    Inc(iCurrBatLine);

                    TrimExeName(sExe,PCmdLine);
                    StrPCopy(PCurrExe,sExe);
               end
               else
               if not MyFindModule(PCurrExe) then
               begin
                    StrPCopy(PCmdLine,BatchBox.Items.Strings[iCurrBatLine]);
                    wResult := WinExec(PCmdLine,SW_SHOWMAXIMIZED);
                    Inc(iCurrBatLine);

                    TrimExeName(sExe,PCmdLine);
                    StrPCopy(PCurrExe,sExe);
               end;
          end;
     end;

     FreeMem(PCmdLine,256);
end;

end.
