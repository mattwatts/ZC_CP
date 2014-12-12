unit Dbms_man;
{DBMS Setup Management Routines for emrtool.ini}

interface

uses
    Global;

procedure AddMatrixIni(const sIni,sName,sMatrix,sCutOffs : string;
                       const iCutOff, iMatSize : integer);
procedure NewIni(const sIni, sSSTable : string);

implementation

uses
    IniFiles, SysUtils{, Test_imp}, Control;

procedure AddMatrixIni(const sIni,sName,sMatrix,sCutOffs : string;
                       const iCutOff, iMatSize : integer);
var
   AnIni : TIniFile;
   iCount : integer;
   sThisDB, sDBSection : string;
   fFail : boolean;
begin
     {add a new Database(matrix) to an existing emrtool.ini
      file with zero or more existing Databases(matrices)
      ie. finds the next space after Database1, Database2,
          Database3, ..., DatabaseN.
      Creates DatabaseN+1}

     AnIni := TIniFile.Create(sIni);

     iCount := 1;
     fFail := False;
     repeat
           sThisDB := AnIni.ReadString('Database' + IntToStr(iCount),
                                       'Name',ERROR_STRING);

           if (sThisDB = ERROR_STRING) then
              fFail := True
           else
               Inc(iCount);

     until fFail;

     sDBSection := 'Database' + IntToStr(iCount);

     AnIni.WriteString(sDBSection,'Name',sName);
     AnIni.WriteInteger(sDBSection,'PCCONTRCutOff',iCutOff);
     AnIni.WriteString(sDBSection,'MatrixFile',sMatrix);
     AnIni.WriteInteger(sDBSection,S_MATRIX_SIZE,iMatSize);
     AnIni.WriteString(sDBSection,'FeatureSummaryTable',sCutOffs);

     {AnIni.WriteString(sDBSection,'MatrixFormat','V2');}
     {this is for saving a version 2 matrix file}

     AnIni.Free;
end;

procedure NewIni(const sIni, sSSTable : string);
var
   AnIni : TIniFile;
   iCount : integer;
   sSection : string;
begin
     {creates a new emrtool.ini file with default
      Options, IrrTarget and Display sections}

     {added IrrCreate section
      Date: 12 April '96
      Author: Matt Watts}

     AnIni := TIniFile.Create(sIni);

     {write the Options section}
     sSection := 'Options';
     AnIni.WriteString(sSection,'SiteSummaryTable',sSSTable);
     AnIni.WriteBool(sSection,'UpdateBaseLayer',True);
     AnIni.WriteBool(sSection,'UpdateTopLayer',False);
     AnIni.WriteBool(sSection,'MinimiseOnDone',True);
     AnIni.WriteBool(sSection,'DDEOn',True);
     AnIni.WriteInteger(sSection,'DefaultTargetPercent',DEFAULT_PERCENT);
     AnIni.WriteBool(sSection,'ShowHints',True);
     AnIni.WriteString(sSection,'LookupLayer','Base');
     AnIni.WriteBool(sSection,'UseFlatTargets',True);

     {write the IrrTarget section}
     AnIni.WriteString('IrrTarget','Value','0.25');

     {write the Display Fields section}
     sSection := 'Display Fields';
     AnIni.WriteString(sSection,NAME_DBLABEL,'');
     AnIni.WriteString(sSection,STATUS_DBLABEL,'');
     AnIni.WriteString(sSection,'SKEY','');
     AnIni.WriteString(sSection,PERCENT_AREA_USED_DBLABEL,'');
     AnIni.WriteString(sSection,IRREPLACEABILITY_DISPLAY_CLASS_DBLABEL,'');
     AnIni.WriteString(sSection,ControlRes^.sI_STATUSField,'');

     {write the IrrCreate section}
     sSection := 'IrrCreate';
     AnIni.WriteString(sSection,'CreateField',ControlRes^.sI_STATUSField);
     AnIni.WriteString(sSection,'InitField',NEW_PREV_DISP_DBLABEL);
     AnIni.WriteString(sSection,'SubsField',NEW_DISP_DBLABEL);

     AnIni.Free;
end;

end.
