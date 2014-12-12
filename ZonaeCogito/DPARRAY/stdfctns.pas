unit StdFctns;

interface
uses sysutils;

function _2dToLinear(x,maxx,y: longint) : longint;
{Returns the linear equivalent of a 2Dimension point - the first position is 1}
function LinearToX(lPos,maxx : longint) : longint;
{Returns the X Value of the 2Dimensionsion point of the linear position}
function LinearToY(lPos,maxx : longint) : longint;
{Returns the Y Value of the 2Dimensionsion point of the linear position}

procedure stubproc;

function uniqueName(Location : tFileName) : tFileName;

function compareMemUsed(First,Second : longint; mess : string) : boolean;

procedure toUpper(const Mixed : string; var Upper : string);

procedure overwritefile(var f: file; lSize : longint);

function UniqueFileName(szDir : string) : string;

implementation
uses dialogs,os_lims;

var
   fNameRefNum : longint;
   uniquenum : longint;

function UniqueFileName(szDir : string) : string;
begin
     inc(uniquenum);
     if szdir[length(szdir)] <> '\' then
     begin
          result := szDir + '\' + inttostr(uniquenum) + '.niq';
     end
     else
     begin
          result := szDir + inttostr(uniquenum) + '.niq';
     end;
end;

procedure overwritefile(var f: file; lSize : longint);
const
     testfile = 'c:\array.cpy';
var
   tmpFile : file;
   p : pointer;
   l : longint;

begin
     if fileExists(string(tFileRec(f).name)) then
     begin
          //need to rename the existing file
          renamefile(string(tFileRec(f).name),testfile);
          //rewrite the new file
          rewrite(f,lSize);
          //copy the old info back to the new file
          getmem(p,SegmentSize_C);
          assignfile(tmpFile,testfile);
          reset(tmpFile,lSize);
          while not(eof(tmpFile)) do
          begin
               blockread(tmpFile,p^,SegmentSize_C div lSize,l);
               blockwrite(f,p^,l);
          end;
          seek(f,0);
          closefile(tmpFile);
          freemem(p);
          // delete the old copy
          deleteFile(testfile);
     end
     else
     begin
          //rewrite the new file
          rewrite(f,lSize);
     end;
end;

procedure toUpper(const Mixed : string; var Upper : string);
var
   x : longint;
   ch : char;
begin
     Upper := Mixed;
     for x := 1 to length(Mixed) do
     begin
          ch := Mixed[x];
          if ord(ch) > 96 then ch := chr(ord(ch)-32);
          Upper[x] := ch;
     end;
end;

function compareMemUsed(First,Second : longint; mess : string) : boolean;
begin
     if first <> second then
     begin
          Result := FALSE;
          if (messagedlg(mess + 'Difference in memory sizes - OK - Continue - Cancel to Halt',
                      mterror,[mbok,mbCancel],0) = 2) then halt;
     end
     else
     begin
          Result := TRUE;
     end;
end;

function uniqueName(Location : tFileName) : tFileName;
begin
     inc(fNameRefNum);

     {Insert this number after the '.'}

     result := changefileext(location,'.'+inttostr(fNameRefNum));

end;

procedure stubproc;
var
   res : word;
begin
     res := messagedlg('Stub Procedure Encountered - OK to continue CANCEL to halt',
                      mtWarning,[mbok,mbcancel],0);
     halt;
end;


function _2dToLinear(x,maxx,y: longint) : longint;
begin
     result := (y-1)*maxx+x;
end;

function LinearToX(lPos,maxx : longint) : longint;
begin
     result := lPos mod maxx;
     if result = 0 then result := maxx;
end;

function LinearToY(lPos,maxx : longint) : longint;
begin
     result := lPos div maxx;
     if ((lPos mod maxx) <> 0) then inc(result);
end;

initialization
begin
     fNameRefNum := 0;
     uniquenum := 0;
end;

end.
