constructor ContigMemory.create;
begin
     inherited create;
     instanceRef := DSInstance;
     inc(DSInstance);
end;

destructor ContigMemory.destroy;
begin
     instanceRef := -1;
     inherited destroy;
end;

procedure ContigMemory.free;
begin
     instanceRef := 0;
     inherited free;
end;


function ContigMemory.WrapAlloc : integer;
begin
     unitNumber := round(maxels*random)+1;
     unitSize := random(10)+1;
     AllocContMemPtr(Testptr,unitNumber,unitSize,TestContigData);
     inc(counter);
     result := random(5) + 1;
     szlastWeb := 'alloc';
end;

function ContigMemory.WrapReAlloc : integer;
begin
     unitNumber := round(maxels*random)+1;
     unitSize := random(10)+1;
     ReAllocContMemPtr(Testptr,unitnumber,unitsize,TestContigData);
     inc(counter);

     result := random(5) + 1;
     szlastWeb := 'realloc';
end;

function ContigMemory.WrapDispose : integer;
begin
     DisposeContMemPtr(Testptr);
     inc(counter);
     result := 1;
     szlastWeb := 'dispose';
end;

function ContigMemory.WrapFree : integer;
begin
     if testptr <> nil then
        FreeContMemPtr(Testptr)
     else
        FreeContMemPtr(Testptr);

     inc(counter);
     result := 1;
     szlastWeb := 'free';
end;

function ContigMemory.WrapLocate : integer;
var
   tmpptr : pointer;
   pos : longint;
begin
     pos := round(random*unitnumber);
     if pos = 0 then pos := unitnumber;
     tmpptr := LocateContMemPtr(Testptr,pos,unitsize,TestContigData);
     inc(counter);
     result := random(5) + 1;
     szlastWeb := 'locate';
end;

procedure  ContigMemory.randomtests(testlength : longint);
var
   nexttest : integer;

begin
     counter := 0;

     WrapAlloc;

     nexttest := random(5) + 1;

     repeat
           case nexttest of

                1: nexttest := WrapAlloc;
                2: nexttest := WrapreAlloc;
                3: nexttest := Wraplocate;
                4: nexttest := WrapFree;
                5: nexttest := WrapLocate;
                else
                begin
                end;
           end;
if flog then
begin
     writeln(log,inttostr(counter) + '  ' + inttostr(nexttest) + '  ' + inttostr(memavail));
end;
     until (counter >= testlength) and (szLastWeb <>'free');

{     WrapFree;}
     WrapDispose;
end;

procedure ContigMemory.testAlloc(testlength : longint);
var
   rtnTest : longint;

begin
     counter := 0;

     repeat
           rtnTest := WrapAlloc;
     until counter >= testlength;
     WrapFree;
end;

procedure ContigMemory.testReAlloc(testlength : longint);
var
   rtnTest : longint;

begin
     counter := 0;

     WrapAlloc;
     repeat
           rtnTest := WrapReAlloc;
     until counter >= testlength;
     WrapFree;
end;

procedure ContigMemory.testLocate(testlength : longint);
var
   rtnTest : longint;

begin
     counter := 0;

     WrapAlloc;
     repeat
           rtnTest := WrapLocate;
     until counter >= testlength;
     WrapFree;
end;

(*procedure CandD;
{Test procedure to  ensure operation of create and destroy functions.
 that they don't have memory leaks and that they can be called in any order
 without causing system failure}
var
   test : ContigMemory;
   x : longint;

begin
randomize;
     mem[1] := memavail;
if flog then
begin
     assign(log,'d:\DataStrc.log');
     rewrite(log);
end;
     for x := 1 to 10 do
     begin
          mem[3] := memavail;
if flog then
begin
     writeln(log,mem[3]);
end;
{          test := ContigMemory.create;  }

{          RandomTests(10000);}
          TestAlloc(100);
          TestReAlloc(1000);
          TestLocate(1000);

{          test.free;}
          mem[4] := memavail;
if flog then
begin
     writeln(log,mem[4]);
end;

          if mem[3] <> mem[4] then
          begin
               mem[0] := mem[4] - mem[3];
          end;
     end;
if flog then
closefile(log);
     mem[2] := memavail;

     x:= 1;
end;
*)
procedure ContigMemory.testing;

begin
     flog := false;
{     CandD;}
     initdebug;
end;

procedure ContigMemory.AllocContMemPtr(var ptrData:pointer;
                                            lNumElements,lElSize : longint;
                                         var ContigData : ContMemData_t);
begin
try
{$ifdef ver80}
      if ptrData = nil then
          AllocateMem(ptrData,lNumElements,lElSize,ContigData.lDataUnitsPerSegment)
      else
      begin
           FreeContMemPtr(ptrData);
           AllocateMem(ptrData,lNumElements,lElSize,ContigData.lDataUnitsPerSegment);
      end;
{$else}
      ContigData.lDataUnitsPerSegment := SegmentSize_C div lElSize;
      if ptrData = nil then
           ptrData := allocmem(lNumElements*lElSize)
      else
      begin
           freemem(ptrData);
           ptrData := allocmem(lNumElements*lElSize)
      end;
{$endif}
except on exception do
    messagedlg('Error in AllocContMemPtr - ContigMemory',mterror,[mbok],0);
end;
end;

procedure ContigMemory.ReAllocContMemPtr(var ptrData:pointer;
                                              lNumElements,lElSize:longint;
                                              var ContigData : ContMemData_t);
var
   oldsize: longint;
   pt : pointer;

begin
try
{$ifdef ver80}
     if ptrData = nil then
          AllocateMem(ptrData,lNumElements,lElSize,ContigData.lDataUnitsPerSegment);
     Reallocatemem(ptrData,lNumElements,lElSize,ContigData.lDataUnitsPerSegment);
{$else}
     ContigData.lDataUnitsPerSegment := SegmentSize_C div lElSize;
     oldsize := sizeof(ptrData^);
     if oldSize < (lNumElements*lElSize) then
     begin
          ReAllocmem(ptrData,lNumElements*lElSize);
     end
     else
     begin
          ReAllocmem(ptrData,lNumElements*lElSize);
          pt := pointer(integer(ptrData^)+oldsize);
          fillchar(pt^,(lNumElements*lElSize)-oldsize,0);
     end;
{$endif}
except on exception do
    messagedlg('Error in ReAllocContMemPtr - ContigMemory',mterror,[mbok],0);
end;
end;

procedure ContigMemory.DisposeContMemPtr(var ptrData : pointer);
begin
try
{$ifdef ver80}
     DiscardMemory(ptrData);
{$else}
      ReAllocmem(ptrData,0);
{      ptrData := nil;}
{$endif}
except on exception do
    messagedlg('Error in DisposeContMemPtr - ContigMemory',mterror,[mbok],0);
end;
end;

procedure ContigMemory.FreeContMemPtr(var ptrData : pointer);
begin
try
{$ifdef ver80}
     FreeMemory(ptrData);
{$else}
       ReAllocmem(ptrData,0);
 {$endif}
except on exception do
    messagedlg('Error in FreeContMemPtr - ContigMemory',mterror,[mbok],0);
end;
end;

function ContigMemory.LocateContMemPtr(ptrData : pointer; lElementNum,lElSize : longint;
                                             ContigData : ContMemData_t) : pointer;
begin
   result := nil;
try
{$ifdef ver80}
     Result := rtnContPtr(ptrData,lElementNum,lElSize,ContigData.lDataUnitsPerSegment,ContigData.fit);
{$else}
      Result := pointer(integer(ptrData)+(lElementNum-1)*lElSize);
{$endif}
except on exception do
    messagedlg('Error in LocateContMemPtr - ContigMemory',mterror,[mbok],0);
end;
end;

