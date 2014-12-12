unit CombsizeRecord;

interface

procedure InitCombsizeRecord;
procedure AppendCombsizeRecord(const iItn, iComb, iAv, iTrigger : integer);

implementation

uses
    Global, Control,
    SysUtils;

procedure InitCombsizeRecord;
var
   CombsizeFile : TextFile;
begin
     assignfile(CombsizeFile,ControlRes^.sWorkingDirectory + '\record_of_combsize.csv');
     rewrite(CombsizeFile);
     writeln(CombsizeFile,'Iteration,combsize,available sites,trigger');
     closefile(CombsizeFile);
end;

procedure AppendCombsizeRecord(const iItn, iComb, iAv, iTrigger : integer);
var
   CombsizeFile : TextFile;
begin
     assignfile(CombsizeFile,ControlRes^.sWorkingDirectory + '\record_of_combsize.csv');
     append(CombsizeFile);
     writeln(CombsizeFile,IntToStr(iItn) + ',' + IntToStr(iComb) + ',' + IntToStr(iAv) + ',' + IntToStr(iTrigger));
     closefile(CombsizeFile);
end;

end.
