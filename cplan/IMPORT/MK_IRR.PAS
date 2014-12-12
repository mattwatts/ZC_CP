unit Mk_irr;

interface

uses Global;

function WriteIrrFile(const sFile : string) : boolean;

function CreateIrrFile(const sPath : string) : boolean;
{this procedure is a user-friendly wrapper around
 function WriteIrrFile}

implementation

uses SysUtils, IniFiles;

function CreateIrrFile(const sPath : string) : boolean;
var
   sFileName : string;
   iPos : integer;
   {AnIni : TIniFile;}
   sGIS : string;

begin
     {we must trim the last sub-directory from sPath
      and use it to contruct a WinERMS .IRR filename}

     Result := False; {we are not connecting to WinERMS}

     iPos := Length(sPath);

     sGIS := 'None';
     {set default GIS to link to, which is None.
      Add handlers here to recognise other GIS'}

     while (iPos > 1)
     and (sPath[iPos] <> '\') do
         Dec(iPos);

     sFileName := Copy(sPath,iPos+1,Length(sPath)-iPos);

     if (Length(sFileName) = 4)
     and ((sFileName[1] = 'v')
          or (sFileName[1] = 'V')) then
     begin
          WriteIrrFile(sPath + '\' + sFileName + '.IRR');
          sGIS := 'WinERMS';

          Result := True;
     end;

     {AnIni := TIniFile.Create(sPath + '\' + INI_FILE_NAME);
     AnIni.WriteString('Options','LinkToGIS',sGIS);}
end;


function WriteIrrFile(const sFile : string) : boolean;
var
   OutFile : file;
   IrrMember : IrrCatMember_T;
   IrrHeader : IrrCatHeader_T;
   iCount : integer;
   cAChar : char;
   bByte : byte;

   iHandle, iBytesWritten : integer;

   lOffset : longint;


   procedure UpdMember(const sLbl : string;
                       const iIdx : integer);
   begin
        IrrMember.Item[1] := sLbl[1];
        IrrMember.Item[2] := sLbl[2];
        IrrMember.Item[3] := sLbl[3];
        IrrMember.cCat := Chr(iIdx);

        Inc(lOffset,iBytesWritten);
        FileSeek(iHandle,lOffset,0);

        iBytesWritten := FileWrite(iHandle,
                                   IrrMember,
                                   SizeOf(IrrMember));
   end;


begin
     Result := True;

     lOffset := 0;

     for iCount := 1 to IRR_HEADER_SIZE do
         IrrHeader[iCount] := '0';

     iHandle := FileCreate(sFile);

     iBytesWritten := FileWrite(iHandle,
                                IrrHeader,
                                SizeOf(IrrHeader));

     UpdMember('SQL',1);
     UpdMember('Res',2);
     UpdMember('Def',3);
     UpdMember('PDe',4);
     UpdMember('Flg',5);
     UpdMember('Ir1',6);
     UpdMember('001',7);
     UpdMember('002',8);
     UpdMember('003',9);
     UpdMember('004',10);
     UpdMember('005',11);
     UpdMember('0Co',12);
     UpdMember('Exc',13);
     UpdMember('Ign',14);

     FileClose(iHandle);
end;

end.
