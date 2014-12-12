unit eFlows_progress;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TeFlowsProgressForm = class(TForm)
    Timer1: TTimer;
    LabelProgress: TLabel;
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  eFlowsProgressForm: TeFlowsProgressForm;

implementation

uses eFlows;

{$R *.DFM}

procedure TeFlowsProgressForm.Timer1Timer(Sender: TObject);
var
   sInFile, sLine1, sLine2 : string;
   iRun, iIteration : integer;
   InFile : TextFile;
begin
     try
        sInFile := ExtractFilePath(eFlowsForm.EditeFlowSpreadsheetPathName.Text) + '\timing.sync';

        if fileexists(sInFile) then
        begin
             assignfile(InFile,sInFile);
             reset(InFile);
             readln(InFile,sLine1);
             readln(InFile,sLine2);
             closefile(InFile);

             iRun := StrToInt(Copy(sLine1,2,Length(sLine1)-2));
             iIteration := StrToInt(Copy(sLine2,2,Length(sLine1)-2));

             LabelProgress.Caption := IntToStr(iRun) + ' ' + IntToStr(iIteration);
             LabelProgress.Repaint;
        end;
        
     except
     end;
end;

end.
