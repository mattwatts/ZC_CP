unit FirstSiteReport;

interface

uses
    ds;

procedure InitFirstSiteReport;
procedure AppendFirstSiteReport(TiedSites : Array_t);

var
     iFirstSiteReport_LastUpdate : integer;

implementation

uses
    Global, Control, validate,
    SysUtils;


procedure InitFirstSiteReport;
var
   ReportFile : Text;
begin
     assignfile(ReportFile,ControlRes^.sWorkingDirectory + '\SelectFirstSites.csv');
     rewrite(ReportFile);
     writeln(ReportFile,'iteration,sitekey,value');
     closefile(ReportFile);

     assignfile(ReportFile,ControlRes^.sWorkingDirectory + '\SelectFirstHistogram.csv');
     rewrite(ReportFile);
     writeln(ReportFile,'iteration,ties');
     closefile(ReportFile);

     iFirstSiteReport_LastUpdate := -1;
end;

procedure AppendFirstSiteReport(TiedSites : Array_t);
var
   ReportFile : Text;
   iCount, iSiteKey : integer;

   procedure AddExtraRows(const iStart, iEnd  : integer);
   var
     iCount : integer;
   begin
        for iCount := iStart to iEnd do
          writeln(ReportFile,IntToStr(iCount) + ',0');
   end;

begin
     assignfile(ReportFile,ControlRes^.sWorkingDirectory + '\SelectFirstSites.csv');
     append(ReportFile);
     for iCount := 1 to TiedSites.lMaxSize do
     begin
          TiedSites.rtnValue(iCount,@iSiteKey);
          writeln(ReportFile,IntToStr(iMinsetIterationCount) + ',' +
                             IntToStr(iSiteKey) + ',' +
                             IntToStr(-1));
     end;
     closefile(ReportFile);

     assignfile(ReportFile,ControlRes^.sWorkingDirectory + '\SelectFirstHistogram.csv');
     append(ReportFile);
     // determine if we need to add extra rows and add them here if necessary
     // case 1 : iFirstSiteReport_LastUpdate = -1 means no rows added yet
     if (iFirstSiteReport_LastUpdate = -1)
     and (iMinsetIterationCount > 1) then
         AddExtraRows(1,iMinsetIterationCount-1)
     else
     begin
          // case 2 : iMinsetIterationCount > (iFirstSiteReport_LastUpdate + 1)
          if (iMinsetIterationCount > (iFirstSiteReport_LastUpdate + 1)) then
             AddExtraRows(iFirstSiteReport_LastUpdate + 1,iMinsetIterationCount-1);
     end;
     writeln(ReportFile,IntToStr(iMinsetIterationCount) + ',' +
                        IntToStr(TiedSites.lMaxSize));
     closefile(ReportFile);

     iFirstSiteReport_LastUpdate := iMinsetIterationCount;
end;


end.
