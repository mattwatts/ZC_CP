unit Datastru;

interface

uses Os_lims,dsdebug,sysutils;

type
         ContMemData_t = record
              lDataUnitsPerSegment : longint;
              fit : boolean;
         end;

         DataStructurePtr_O = class
         {Gives the data structure abity to posses a 'piece' of contiguous memory}
              instanceRef : longint;
              ContigData : ContMemData_t;

              constructor create;
              procedure free;
              destructor destroy; override;

              procedure AllocContMemPtr(var ptrData:pointer;
                                            lNumElements,lElSize : longint;
                                        var ContigData : ContMemData_t);
              procedure ReAllocContMemPtr(var ptrData:pointer;
                                              lNumElements,lElSize:longint;
                                              var ContigData : ContMemData_t);
              procedure DisposeContMemPtr(var ptrData : pointer);
              procedure FreeContMemPtr(var ptrData : pointer);
              function LocateContMemPtr(ptrData : pointer; lElementNum,lElSize : longint;
                                         ContigData : ContMemData_t) : pointer;

              procedure testing; virtual;


              function WrapAlloc : integer;
              function WrapReAlloc : integer;
              function WrapDispose : integer;
              function WrapFree : integer;
              function WrapLocate : integer;

              procedure  randomtests(testlength : longint);
              procedure  testAlloc(testlength : longint);
              procedure  testReAlloc(testlength : longint);
              procedure  testLocate(testlength : longint);

         end;


implementation

uses dialogs;

const
     maxels = 100000;
var
   oDSDebug : DataStructurePtr_O;
   db_ContMem : ContMemData_t;
   debugptr_ : pointer;
   Testptr : pointer;
   DSInstance : longint;
   mem : array[0..10] of longint;
   TestContigData : ContMemData_t;
   counter : longint;
   unitNumber : longint;
   unitsize : integer;
   flog : boolean;
   log : text;
   szlastWeb : string;

constructor DataStructurePtr_O.create;
begin
     inherited create;
     instanceRef := DSInstance;
     inc(DSInstance);
end;

destructor DataStructurePtr_O.destroy;
begin
     instanceRef := -1;
     inherited destroy;
end;

procedure DataStructurePtr_O.free;
begin
     instanceRef := 0;
     inherited free;
end;


function DataStructurePtr_O.WrapAlloc : integer;
begin
     unitNumber := round(maxels*random)+1;
     unitSize := random(10)+1;
     AllocContMemPtr(Testptr,unitNumber,unitSize,TestContigData);
     inc(counter);
     result := random(5) + 1;
     szlastWeb := 'alloc';
end;

function DataStructurePtr_O.WrapReAlloc : integer;
begin
     unitNumber := round(maxels*random)+1;
     unitSize := random(10)+1;
     ReAllocContMemPtr(Testptr,unitnumber,unitsize,TestContigData);
     inc(counter);

     result := random(5) + 1;
     szlastWeb := 'realloc';
end;

function DataStructurePtr_O.WrapDispose : integer;
begin
     DisposeContMemPtr(Testptr);
     inc(counter);
     result := 1;
     szlastWeb := 'dispose';
end;

function DataStructurePtr_O.WrapFree : integer;
begin
     if testptr <> nil then
        FreeContMemPtr(Testptr)
     else
        FreeContMemPtr(Testptr);

     inc(counter);
     result := 1;
     szlastWeb := 'free';
end;

function DataStructurePtr_O.WrapLocate : integer;
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

procedure  DataStructurePtr_O.randomtests(testlength : longint);
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
     {writeln(log,inttostr(counter) + '  ' + inttostr(nexttest) + '  ' + inttostr(memavail))};
end;
     until (counter >= testlength) and (szLastWeb <>'free');

{     WrapFree;}
     WrapDispose;
end;

procedure DataStructurePtr_O.testAlloc(testlength : longint);
var
   rtnTest : longint;

begin
     counter := 0;

     repeat
           rtnTest := WrapAlloc;
     until counter >= testlength;
     WrapFree;
end;

procedure DataStructurePtr_O.testReAlloc(testlength : longint);
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

procedure DataStructurePtr_O.testLocate(testlength : longint);
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
   test : DataStructurePtr_O;
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
{          test := DataStructurePtr_O.create;  }

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
procedure DataStructurePtr_O.testing;

begin
     flog := false;
{     CandD;}
     initdebug;
end;

procedure DataStructurePtr_O.AllocContMemPtr(var ptrData:pointer;
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
      if ptrData = nil then
           ptrData := allocmem(lNumElements*lElSize)
      else
      begin
           freemem(ptrData);
           ptrData := allocmem(lNumElements*lElSize)
      end;
{$endif}
except on exception do
    messagedlg('Error in AllocContMemPtr - DataStructurePtr_O',mterror,[mbok],0);
end;
end;

procedure DataStructurePtr_O.ReAllocContMemPtr(var ptrData:pointer;
                                              lNumElements,lElSize:longint;
                                              var ContigData : ContMemData_t);
var
   ptrTmp : pointer;

begin
try
{$ifdef ver80}
     Reallocatemem(ptrData,lNumElements,lElSize,ContigData.lDataUnitsPerSegment);
{$else}
     ReAllocmem(ptrData,lNumElements*lElSize);
{$endif}
except on exception do
    messagedlg('Error in ReAllocContMemPtr - DataStructurePtr_O',mterror,[mbok],0);
end;
end;

procedure DataStructurePtr_O.DisposeContMemPtr(var ptrData : pointer);
begin
try
{$ifdef ver80}
     DiscardMemory(ptrData);
{$else}
      dispose(ptrData);
{      ptrData := nil;}
{$endif}
except on exception do
    messagedlg('Error in DisposeContMemPtr - DataStructurePtr_O',mterror,[mbok],0);
end;
end;

procedure DataStructurePtr_O.FreeContMemPtr(var ptrData : pointer);
begin
try
{$ifdef ver80}
     FreeMemory(ptrData);
{$else}
       freemem(ptrData);
       ptrData := nil;
 {$endif}
except on exception do
    messagedlg('Error in FreeContMemPtr - DataStructurePtr_O',mterror,[mbok],0);
end;
end;

function DataStructurePtr_O.LocateContMemPtr(ptrData : pointer; lElementNum,lElSize : longint;
                                             ContigData : ContMemData_t) : pointer;
begin
try
{$ifdef ver80}
     Result := rtnContPtr(ptrData,lElementNum,lElSize,ContigData.lDataUnitsPerSegment,ContigData.fit);
{$else}
      Result := ptr(integer(ptrData)+(lElementNum-1)*lElSize);
{$endif}
except on exception do
    messagedlg('Error in LocateContMemPtr - DataStructurePtr_O',mterror,[mbok],0);
end;
end;

initialization
begin
     DSInstance := 1;
     debugptr_ := nil;
     new(testptr);
     oDSDebug := DataStructurePtr_O.create;

{     oDSDebug.testing;}

     oDSDebug.free;
end;
end.
