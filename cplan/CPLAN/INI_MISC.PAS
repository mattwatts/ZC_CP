unit Ini_misc;
{$I STD_DEF.PAS}

interface

uses
    Global, Control;


function LoadDisplaySiteCount : integer;
procedure SaveDisplaySiteCount(const iDSC : integer);

implementation

uses
    IniFiles;

function LoadDisplaySiteCount : integer;
var
   AnIni : TIniFile;
begin
     if ControlRes^.fOldIni then
        AnIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
     else
         AnIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);

     Result := AnIni.ReadInteger('Contribution Form','Display Site Count',DISPLAY_SITE_COUNT);
     AnIni.Free;
end;

procedure SaveDisplaySiteCount(const iDSC : integer);
var
   AnIni : TIniFile;
begin
     if ControlRes^.fOldIni then
        AnIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
     else
         AnIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);

     AnIni.WriteInteger('Contribution Form','Display Site Count',iDSC);
     AnIni.Free;
end;


end.
