unit Binfile;

{$I STD_DEF.PAS}

interface

function BinFormatOk(const sExeFile, sBinFile : string;
                     var lASize : longint) : boolean;

function rtnBinName(const sFile : string) : string;
function rtnFileDateTime(const sFile : string) : TDateTime;

implementation

uses
    Global, SysUtils, Dialogs,
    ds;

function BinFormatOk(const sExeFile, sBinFile : string;
                     var lASize : longint) : boolean;
var
   BinFile : file;
   ABuffer : BinFileHeader_T;
   wValidVersion : word;
begin
     Result := False;
     lASize := 0;

     if FileExists(sBinFile) then
     begin
          try
             assignfile(BinFile,sBinFile);
             reset(BinFile,1);
             BlockRead(BinFile,ABuffer,SizeOf(ABuffer));
             closefile(BinFile);

             {$IFDEF bit16}
             wValidVersion := BIT16_BIN_FILE_VERSION;
             {$ELSE}
             wValidVersion := BIT32_BIN_FILE_VERSION;
             {$ENDIF}

             if (ABuffer.wVersionNum = wValidVersion)
             {$IFDEF CPLAN_USERS}
             and (ABuffer.ExeDateTime = rtnFileDateTime(sExeFile))
             {$ENDIF} then
             begin
                  Result := True;
                  {the only recognised bin file version is 2.
                   bin files of version 1 are automatically
                   ignored and rewritten as bin file version 2}
                  lASize := ABuffer.lArrSize;
             end;

          except on exception do
          end;
     end;
end;

function rtnBinName(const sFile : string) : string;
var
   lLen : longint;
begin
     lLen := Length(sFile);

     if (lLen > 4)
     and (sFile[lLen-3] = '.') then
         Result := Copy(sFile,1,lLen-3) + 'BIN'
     else
         Result := 'ERROR';
end;

function rtnFileDateTime(const sFile : string) : TDateTime;
var
   iExeFileHandle : integer;
begin
     iExeFileHandle := FileOpen(sFile,fmShareDenyNone);
     Result := 0;

     if (iExeFileHandle > 0) then
     begin
          Result := FileDateToDateTime(FileGetDate(iExeFileHandle));
          FileClose(iExeFileHandle);
     end
     else
         MessageDlg('cannot open EXE file',mtError,[mbOk],0);
end;

end.
