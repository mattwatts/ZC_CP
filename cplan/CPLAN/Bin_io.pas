unit Bin_io;

{for saving and loading the SiteArr and FeatArr
 Author : Matthew Watts
 Date : 30/7/96}

{$I STD_DEF.PAS}

interface


uses
    Em_newu1, Global,
  {$IFDEF bit16}
  Arrayt16;
  {$ELSE}
  ds;
  {$ENDIF}

type
    SiteFile_T = record
        ASite : site;
        AGeo : integer;
    end;

    FeatFile_T = record
        AFeat : featureoccurrence;
        AFCode : integer;
        dSData : extended;
    end;


function SArr2File(const sExeFile, sFile : string;
                   var SArr, SCodes{, SOrd} : Array_t) : boolean;
function FArr2File(const sExeFile, sFile : string;
                   var FArr, FCodes{, FOrd}, SData : Array_t) : boolean;
function File2SArr(const sFile : string;
                   var SArr, SCodes{, SOrd} : Array_t) : boolean;
function File2FArr(const sFile : string;
                   var FArr, FCodes{, FOrd}, SData : Array_t) : boolean;

procedure SaveAutoLoadData(const sExeFile : string);


implementation

uses
    SysUtils, Sitelist, Featlist,
    IniFiles, Control, Sf_irrep,
    Toolmisc, Dialogs, Binfile;

procedure SaveAutoLoadData(const sExeFile : string);
var
   sSiteFile, sFeatFile : string;
begin
     sSiteFile := Copy(ControlRes^.sSiteFeatureTable,1,
                       Length(ControlRes^.sSiteFeatureTable)-3) + 'BIN';

     sFeatFile := Copy(ControlRes^.sFeatCutOffsTable,1,
                       Length(ControlRes^.sFeatCutOffsTable)-3) + 'BIN';

     if SArr2File(sExeFile,ControlRes^.sDatabase + '\' + sSiteFile,
                  SiteArr,SiteCodes)
     and FArr2File(sExeFile,ControlRes^.sDatabase + '\' + sFeatFile,
                   FeatArr,FeatCodes,AverageSite) then
     begin
     end
     else
     begin
          MessageDlg('error saving BIN files',mtError,[mbOk],0);
     end;

     with ControlForm do
     begin
          Available.Items.SaveToFile(ControlRes^.sDatabase + '\' + 'av.bin');
          AvailableKey.Items.SaveToFile(ControlRes^.sDatabase + '\' + 'avg.bin');
          Reserved.Items.SaveToFile(ControlRes^.sDatabase + '\' + 're.bin');
          ReservedKey.Items.SaveToFile(ControlRes^.sDatabase + '\' + 'reg.bin');
          Ignored.Items.SaveToFile(ControlRes^.sDatabase + '\' + 'ig.bin');
          IgnoredKey.Items.SaveToFile(ControlRes^.sDatabase + '\' + 'igg.bin');
     end;
end;

function SArr2File(const sExeFile, sFile : string;
                   var SArr, SCodes : Array_t) : boolean;
var
   OutFile : file;

   pBuff : ^SiteFile_T;

   pSite : sitepointer;
   iSiteIndex,
   iCount, iInitCount : integer;
   AHeader : BinFileHeader_T;
begin
     Result := True;

     ControlForm.ProgressOn;
     ControlForm.ProcLabelOn('Save Sites');

     try
        if (SArr.lMaxSize > 0) then
        begin
             new(pBuff);

             new(pSite);
             assign(OutFile,sFile);
             rewrite(OutFile,1);

             {$IFDEF bit16}
             AHeader.wVersionNum := BIT16_BIN_FILE_VERSION;
             {$ELSE}
             AHeader.wVersionNum := BIT32_BIN_FILE_VERSION;
             {$ENDIF}

             AHeader.ExeDateTime := rtnFileDateTime(sExeFile);

             AHeader.lArrSize := SArr.lMaxSize;
             for iInitCount := 1 to 8 do
                 AHeader.EmptySpace[iInitCount] := 0;
                 {initialise empty space in header}
             BlockWrite(OutFile,AHeader,SizeOf(AHeader));

             for iCount := 1 to SArr.lMaxSize do
             begin
                  if ((iCount mod BIN_IO_PROGRESS_STEP)=0) then
                     ControlForm.ProgressUpdate(Round(iCount/SArr.lMaxSize*100));

                  SArr.rtnValue(iCount,pSite);
                  SCodes.rtnValue(iCount,@iSiteIndex);

                  pBuff^.ASite := pSite^;
                  pBuff^.AGeo := iSiteIndex;

                  BlockWrite(OutFile,pBuff^,SizeOf(SiteFile_T));
             end;

             dispose(pSite);
             close(OutFile);

             dispose(pBuff);
        end;

     except on exception do
            Result := False;
     end;

     ControlForm.ProgressOff;
     ControlForm.ProcLabelOff;
end;

function FArr2File(const sExeFile, sFile : string;
                   var FArr, FCodes{, FOrd}, SData : Array_t) : boolean;
var
   OutFile : file {of FeatFile_T};

   pBuff : ^FeatFile_T;

   iCount, iInitCount : integer;
   AHeader : BinFileHeader_T;
begin
     Result := True;

     ControlForm.ProgressOn;
     ControlForm.ProcLabelOn('Save Features');

     try
        if (FArr.lMaxSize > 0) then
        begin
             new(pBuff);

             assign(OutFile,sFile);
             rewrite(OutFile,1);

             {$IFDEF bit16}
             AHeader.wVersionNum := BIT16_BIN_FILE_VERSION;
             {$ELSE}
             AHeader.wVersionNum := BIT32_BIN_FILE_VERSION;
             {$ENDIF}

             AHeader.ExeDateTime := rtnFileDateTime(sExeFile);

             AHeader.lArrSize := FArr.lMaxSize;
             for iInitCount := 1 to 8 do
                 AHeader.EmptySpace[iInitCount] := 0;
                 {initialise empty space in header}
             BlockWrite(OutFile,AHeader,SizeOf(AHeader));

             for iCount := 1 to FArr.lMaxSize do
             begin
                  if ((iCount mod BIN_IO_PROGRESS_STEP)=0) then
                     ControlForm.ProgressUpdate(Round(iCount/FArr.lMaxSize*100));

                  FArr.rtnValue(iCount,@(pBuff^.AFeat));
                  FCodes.rtnValue(iCount,@(pBuff^.AFCode));
                  SData.rtnValue(iCount,@(pBuff^.dSData));

                  BlockWrite(OutFile,pBuff^,SizeOf(FeatFile_T));
             end;

             close(OutFile);

             dispose(pBuff);
        end;

     except on exception do
            Result := False;
     end;

     ControlForm.ProgressOff;
     ControlForm.ProcLabelOff;
end;

function File2SArr(const sFile : string;
                   var SArr, SCodes{, SOrd} : Array_t) : boolean;
var
   InFile : file {of SiteFile_T};

   pBuff : ^SiteFile_T;

   iCount : integer;
   AHeader : BinFileHeader_T;

   wValidVersion : word;
begin
     Result := False;

     ControlForm.ProgressOn;
     ControlForm.ProcLabelOn('Reload Sites');

     if FileExists(sFile) then
     begin
          Result := True;

          new(pBuff);

          assign(InFile,sFile);
          reset(InFile,1);

          BlockRead(InFile,AHeader,SizeOf(AHeader));
          {check the .bin file version number in the header is 2
           ie. this function handles version 2 bin files only}

          {$IFDEF bit16}
          wValidVersion := BIT16_BIN_FILE_VERSION;
          {$ELSE}
          wValidVersion := BIT32_BIN_FILE_VERSION;
          {$ENDIF}

          if (AHeader.wVersionNum <> wValidVersion)
          or (AHeader.lArrSize <> SArr.lMaxSize) then
             Result := False
          else
              for iCount := 1 to SArr.lMaxSize do
              begin
                   if ((iCount mod BIN_IO_PROGRESS_STEP)=0) then
                      ControlForm.ProgressUpdate(Round(iCount/SArr.lMaxSize*100));

                   BlockRead(InFile,pBuff^,SizeOf(SiteFile_T));

                   SArr.setValue(iCount,@(pBuff^.ASite));
                   SCodes.setValue(iCount,@(pBuff^.AGeo));
              end;

          close(InFile);

          dispose(pBuff);
     end;

     ControlForm.ProgressOff;
     ControlForm.ProcLabelOff;
end;

function File2FArr(const sFile : string;
                   var FArr, FCodes{, FOrd}, SData : Array_t) : boolean;
var
   InFile : file {of FeatFile_T};

   pBuff : ^FeatFile_T;

   iCount : integer;
   AHeader : BinFileHeader_T;

   wValidVersion : word;

begin
     Result := False;

     ControlForm.ProgressOn;
     ControlForm.ProcLabelOn('Reload Features');

     if FileExists(sFile) then
     begin
          Result := True;

          new(pBuff);

          assign(InFile,sFile);
          reset(InFile,1);

          BlockRead(InFile,AHeader,SizeOf(AHeader));

          {$IFDEF bit16}
          wValidVersion := BIT16_BIN_FILE_VERSION;
          {$ELSE}
          wValidVersion := BIT32_BIN_FILE_VERSION;
          {$ENDIF}

          if (AHeader.wVersionNum <> wValidVersion)
          or (AHeader.lArrSize <> FArr.lMaxSize) then
             Result := False
          else
              for iCount := 1 to FArr.lMaxSize do
              begin
                   if ((iCount mod BIN_IO_PROGRESS_STEP)=0) then
                      ControlForm.ProgressUpdate(Round(iCount/FArr.lMaxSize*100));

                   BlockRead(InFile,pBuff^,SizeOf(FeatFile_T));

                   FArr.setValue(iCount,@(pBuff^.AFeat));
                   FCodes.setValue(iCount,@(pBuff^.AFCode));
                   SData.setValue(iCount,@(pBuff^.dSData));
              end;

          close(InFile);

          dispose(pBuff);
     end;

     ControlForm.ProgressOff;
     ControlForm.ProcLabelOff;
end;


end.
