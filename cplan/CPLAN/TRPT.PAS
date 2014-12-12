unit trpt;

interface

procedure InitTimeReport(const sDirectoryForDebugFile : string);
procedure FreeTimeReport;
procedure ReportTime(const sTaskDescription : string);

implementation

uses
    SysUtils, FileCtrl;

var
   TimeReportFile : text;
   LastTime : TDateTime;
   Hour, Min, Sec, MSec: Word;

function Time2Str(aTime : TDateTime) : string;
begin
     DecodeTime(Now, Hour, Min, Sec, MSec);
     Result := IntToStr(Hour) + ':' +
               IntToStr(Min) + ':' +
               IntToStr(Sec) + ':' +
               IntToStr(MSec);
end;


procedure InitTimeReport(const sDirectoryForDebugFile : string);
begin
     ForceDirectories(sDirectoryForDebugFile);

     assignfile(TimeReportFile,(sDirectoryForDebugFile + '\exectime.log'));
     rewrite(TimeReportFile);
     writeln(TimeReportFile,'time format Hour:Min:Sec:MSec');
     writeln(TimeReportFile,(Time2Str(Time) + '  begin log'));
     LastTime := Time;
end;

procedure FreeTimeReport;
begin
     writeln(TimeReportFile,(Time2Str(Time) + '  end log'));
     closefile(TimeReportFile);
end;

procedure ReportTime(const sTaskDescription : string);
begin
     writeln(TimeReportFile,(Time2Str(Time) + ' elapsed ' + Time2Str(Time-LastTime) + '  ' + sTaskDescription));
     LastTime := Time;
end;


end.
