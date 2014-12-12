unit Os_lims;
interface

uses wintypes,dialogs,winprocs,sysutils;

{$ifdef ver80}
const
     SegmentSize_C = 65536;

type
    FourBytes_T=record
              wLowTwoBytes:word;
              wHighTwoBytes:word;
            end;

function rtnContPtr(pStartOfBlock : pointer; lElementNum, iDataTypeSize, lOddDataUnitsPerSegment : longint;
                    fit : boolean) : pointer;
 procedure DiscardMemory(var pStartOfBlock:pointer);
 procedure FreeMemory(var pStartOfBlock:pointer);
 procedure ReAllocateMem
             (var pStartOfBlock:pointer;lNoOfElements,lSizeOfElement:longint;
              var lDataUnitsPerSegment:longint);
 procedure AllocateMem(var pStartOfBlock:pointer;lNoOfElements,lSizeOfElement:longint;
              var lDataUnitsPerSegment:longint);

{$endif}
{$ifdef VER90}
function memavail : longint;
{$endif}

implementation
{$ifdef ver90}
function memavail : longint;
var
   heap : tHeapstatus;
begin
     heap := getheapstatus;
     result := longint(heap.totalallocated);
end;
{$endif}

{$ifdef ver80}
function rtnContPtr(pStartOfBlock : pointer; lElementNum, iDataTypeSize, lOddDataUnitsPerSegment : longint;
                    fit : boolean) : pointer;
var
   iPosition : integer;
{$ifdef ver80}
   tempHandle : tHandle;
   HndlData : thandle;

procedure rtnMemEven;
 var
   lOffset:longint;
   pNewPointer:pointer;
 begin
   lOffset := (lElementNum - 1) * iDataTypeSize;
   {Ptr is a function specifying the segment and offset parts of pointer}
   Result := Ptr(
                    FourBytes_T(pStartOfBlock).wHighTwoBytes +
                    FourBytes_T(lOffset).wHighTwoBytes * SelectorInc,
                    {Segment part incremented by multiples of SelectorInc
                     which is separation between sectors}
                    FourBytes_T(pStartOfBlock).wLowTwoBytes +
                    FourBytes_T(lOffset).wLowTwoBytes);
   {Treat memory pointed to as if it is a longint, assign value to it}
 end;

procedure rtnMemOdd;
 var
   lOffset,
   lSegments,
   lExtraElements,
   lActualElementNo : longint;
   pNewPointer:pointer;
   wLowWord, wHighWord : word;
 begin
   lActualElementNo := lElementNum - 1;
   if lActualElementNo >= lOddDataUnitsPerSegment then
   {The fancy arithmetic only needed if we have to go past first segment}
   begin
     lSegments := lActualElementNo div lOddDataUnitsPerSegment;
     lExtraElements := lActualElementNo mod lOddDataUnitsPerSegment;
     lOffSet := (lSegments * SegmentSize_C) + lExtraElements * iDataTypeSize;
   end
   else
     {less one since pointer points to first location}
        lOffset := lActualElementNo * iDataTypeSize;

   {Ptr is a function specifying the segment and offset parts of pointer}

  Result := Ptr(
                    FourBytes_T(pStartOfBlock).wHighTwoBytes +
                    FourBytes_T(lOffset).wHighTwoBytes * SelectorInc,
                    {Segment part incremented by multiples of SelectorInc
                     which is separation between sectors}
                    FourBytes_T(pStartOfBlock).wLowTwoBytes +
                    FourBytes_T(lOffset).wLowTwoBytes);



 end;
{$endif}
 begin
{$ifdef ver80}
      hndlData := selectorof(pStartOfBlock);
{$endif}

 {$ifdef ver80}
      if fit then
         rtnMemEven
      else
          rtnMemOdd;

{$else}
      iPosition := integer(ptrDataStart);
      inc(iPosition,(lElementNum-1)*iDataTypeSize);
      Result := ptr(iPosition);
{$endif}
 end;

 procedure DiscardMemory(var pStartOfBlock:pointer);
 {Frees up the memory block pointed to by pStartOfBlock.  The handle
  is found for the block and then is used to unlock then free the block}
{The following two references to HndlData shoe hndldata to be invalid!}
var
   HndlData : thandle;
   t : byte;
 begin
try
{$ifdef _log_}
inc(countfr);
writeln(logfile,'Free : ',countfr);
flush(logfile);
{$endif}
t := 0;
      HndlData := selectorof(pStartOfBlock);
{      while (bool(GlobalUnlock(HndlData)) <> bool(0)) do begin inc(t); end;}
      GlobalUnlock(HndlData);
      HndlData := globalrealloc(HndlData,0,GMEM_MODIFY+GMEM_DISCARDABLE);
      globalfree(hndlData);
      globaldiscard(hndlData);
     pStartOfBlock := nil;
except on exception do
    messagedlg('Error in DiscardMem - OS_Lims',mterror,[mbok],0);
end;
 end;{procedure FreeMem}

 procedure FreeMemory(var pStartOfBlock:pointer);
 {Frees up the memory block pointed to by pStartOfBlock.  The handle
  is found for the block and then is used to unlock then free the block}
{The following two references to HndlData shoe hndldata to be invalid!}
var
   HndlData : thandle;
   t : byte;
 begin
try
 t := 0;
      HndlData := selectorof(pStartOfBlock);
{      while (bool(GlobalUnlock(HndlData)) <> bool(0)) do begin inc(t) end;}
      GlobalUnlock(HndlData);
      HndlData := globalrealloc(HndlData,0,GMEM_MODIFY+GMEM_DISCARDABLE);
      globalfree(hndlData);
{      if bool(GlobalFree(HndlData)) <> bool(0) then
         messageDlg('Memory management:  `FreeMem'''+
                    ' could not free the memory block with starting '+
                    'address $'+inttohex(longint(pStartOfBlock),8)+'.',
                    mtWarning,[mbOk],0);
}
     pStartOfBlock := nil;
except on exception do
    messagedlg('Error in FreeMemory - OS_Lims',mterror,[mbok],0);
end;
 end;{procedure FreeMem}

 procedure ReAllocateMem
             (var pStartOfBlock:pointer;lNoOfElements,lSizeOfElement:longint;
              var lDataUnitsPerSegment:longint);
 {The Generic Allocation procedure:  Allocates a global block of memory
  for the specified number of elements of a data type with length
  `lSizeOfElement', a pointer to the start of the block is the var
  This procedure is used when the data type could be one that may not
  fit an even number of times in a segment.}
 var
   lTotalMemNeeded,
   lSegmentsNeeded,
   lExtraMemNeeded : longint;
   HndlData : thandle;

   tmpptr : pointer;

 begin
try
   {CHECK IF THE SIZE OF THE MEMORY OBJECT IS EVEN TOO BIG FOR A SEGMENT}
   if lSizeOfElement > SegmentSize_C then
   begin
     MessageDlg('reAllocateMem:  This procedure cannot reallocate memory ' +
                'for a data type larger than a segment.',
                mtWarning,[mbOK],0);
     halt;
   end;

   {CALCULATE HOW MUCH MEMORY NEEDED}
   if (SegmentSize_C mod lSizeOfElement) = 0 then
   {if multiples of the data type fit evenly in a segment use normal proc}
     lTotalMemNeeded := lSizeOfElement*lNoOfElements
   else
   begin
     lDataUnitsPerSegment := SegmentSize_C div lSizeOfElement;
     lSegmentsNeeded := lNoOfElements div lDataUnitsPerSegment;
     lExtraMemNeeded :=
                  (lNoOfElements - lSegmentsNeeded * lDataUnitsPerSegment) *
                   lSizeOfElement;
     lTotalMemNeeded := lSegmentsNeeded * SegmentSize_C + lExtraMemNeeded;
   end;

   {ALLOCATES GLOBAL MEMORY BLOCK}

   HndlData := selectorof(pStartOfBlock);
   HndlData := GlobalReAlloc(HndlData,lTotalMemNeeded,GMEM_MOVEABLE+GMEM_ZEROINIT);

   if (globalsize(HndlData) < lTotalMemNeeded) then
   begin
       messagedlg('Didnt allocate the correct amount of memory',mterror,[mbok],0);
   end;

   if HndlData = 0 then  {0 when unable to allocate memory}
     {If unable to allocate enough memory reshuffle memory spaces}
     if GlobalCompact(lTotalMemNeeded) >= lTotalMemNeeded then
     begin
       {The compacting freed the memory so now use it}
       HndlData := GlobalReAlloc(HndlData,lTotalMemNeeded,GMEM_MOVEABLE+GMEM_ZEROINIT);
       if HndlData = 0 then  {0 when unable to allocate memory}
       begin
         {Check again just in case}
         MessageDlg('Global compacting sucessfully freed '+
                    inttostr(lTotalMemNeeded)+
                    ' bytes but an attempt to reallocate this memory failed.',
                    mtInformation,[mbOk],0);
         halt; {abort since cannot continue}
       end {if hMemHandle = 0}
       else
         MessageDlg('Unable to reallocate memory of '+
                    inttostr(lTotalMemNeeded)+
                    ' Bytes even after a Global Compacting',
                    mtInformation,[mbOk],0);
     end;{if GlobalCompact(lTotalMemNeeded) < lTotalMemNeeded}

   {Now point to the memory block}
   pStartOfBlock := GlobalLock(HndlData);
except on exception do
    messagedlg('Error in ReallocMem - OS_Lims',mterror,[mbok],0);
end;
 end;{procedure reAllocateMem}

  procedure AllocateMem
             (var pStartOfBlock:pointer;lNoOfElements,lSizeOfElement:longint;
              var lDataUnitsPerSegment:longint);
 {The Generic Allocation procedure:  Allocates a global block of memory
  for the specified number of elements of a data type with length
  `lSizeOfElement', a pointer to the start of the block is the var
  This procedure is used when the data type could be one that may not
  fit an even number of times in a segment.}
 var
   lTotalMemNeeded,
   lSegmentsNeeded,
   lExtraMemNeeded : longint;
   HndlData : thandle;
 begin
   {CHECK IF THE SIZE OF THE MEMORY OBJECT IS EVEN TOO BIG FOR A SEGMENT}
try
   if lSizeOfElement > SegmentSize_C then
   begin
     MessageDlg('AllocateMem:  This procedure cannot allocate memory ' +
                'for a data type larger than a segment.',
                mtWarning,[mbOK],0);
     halt;
   end;

   {CALCULATE HOW MUCH MEMORY NEEDED}
   lDataUnitsPerSegment := SegmentSize_C div lSizeOfElement;
   if (SegmentSize_C mod lSizeOfElement) = 0 then
   {if multiples of the data type fit evenly in a segment use normal proc}
     lTotalMemNeeded := lSizeOfElement*lNoOfElements
   else
   begin
     lSegmentsNeeded := lNoOfElements div lDataUnitsPerSegment;
     lExtraMemNeeded :=
                  (lNoOfElements - lSegmentsNeeded * lDataUnitsPerSegment) *
                   lSizeOfElement;
     lTotalMemNeeded := lSegmentsNeeded * SegmentSize_C + lExtraMemNeeded;
   end;

   {ALLOCATES GLOBAL MEMORY BLOCK}
   HndlData := selectorof(pStartOfBlock);
   HndlData := GlobalAlloc(GHND,lTotalMemNeeded);
   if HndlData = 0 then  {0 when unable to allocate memory}
     {If unable to allocate enough memory reshuffle memory spaces}
     if GlobalCompact(lTotalMemNeeded) >= lTotalMemNeeded then
     begin
       {The compacting freed the memory so now use it}
       HndlData := GlobalAlloc(GHND,lTotalMemNeeded);
       if HndlData = 0 then  {0 when unable to allocate memory}
       begin
         {Check again just in case}
         MessageDlg('Global compacting sucessfully freed '+
                    inttostr(lTotalMemNeeded)+
                    ' bytes but an attempt to allocate this memory failed.',
                    mtInformation,[mbOk],0);
         halt; {abort since cannot continue}
       end {if hMemHandle = 0}
       else
         MessageDlg('Unable to allocate memory of '+
                    inttostr(lTotalMemNeeded)+
                    ' Bytes even after a Global Compacting',
                    mtInformation,[mbOk],0);
     end;{if GlobalCompact(lTotalMemNeeded) < lTotalMemNeeded}

   {Now point to the memory block}
   pStartOfBlock := GlobalLock(HndlData);

except on exception do
    messagedlg('Error in AllocateMem - OS_Lims',mterror,[mbok],0);
end;
 end;{procedure AllocateMem}
{$endif}
end.


