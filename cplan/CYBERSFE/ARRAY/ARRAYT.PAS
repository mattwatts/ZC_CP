unit Arrayt;

interface

uses
    Forms,
    Wintypes, winprocs,dialogs,sysutils,
    {ulistnd}
    winmask
    , linklist{, sitelist, featlist} {added by Matt 20/6/96}
    ;

const
     SegmentSize_C = 65536;
type
    FourBytes_T=record
              wLowTwoBytes:word;
              wHighTwoBytes:word;
            end;

    Array_T = class
    public
        iDataTypeSize : integer;
        lMaxSize : longint;
        ptrDataStart : pointer;

        fit : boolean;
        lOddDataUnitsPerSegment : longint;

        HndlData : tHandle;

        constructor init(SizeOfDataType : integer; InitialSize : longint);
        destructor Destroy; override;
        procedure resize(lNewSize : longint);
        procedure setValue(lElementNum : longint; ptrData : pointer);
        procedure rtnValue(lElementNum : longint; ptrData : pointer);
        function rtnPtr(lElementNum : longint) : pointer;
        procedure FreeMemory(pStartOfBlock:pointer);
        procedure PtrDispose;
private
 procedure AllocateMem
             (var pStartOfBlock:pointer;lNoOfElements,lSizeOfElement:longint;
              var lDataUnitsPerSegment:longint);
 procedure ReAllocateMem
             (var pStartOfBlock:pointer;lNoOfElements,lSizeOfElement:longint;
              var lDataUnitsPerSegment:longint);

    end;

procedure randomlongArray(var RndArray : array_t);
function SortLongArray(const unsortedArray_C : array_t) : array_t;
function findlongmatch(SortArray : array_t; RecordtoMatch : longint) : integer;





implementation

 procedure Array_t.ReAllocateMem
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
 begin
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
   HndlData := GlobalReAlloc(HndlData,lTotalMemNeeded,GMEM_MOVEABLE+GMEM_ZEROINIT);
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
 end;{procedure reAllocateMem}

  procedure Array_t.AllocateMem
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
 begin
   {CHECK IF THE SIZE OF THE MEMORY OBJECT IS EVEN TOO BIG FOR A SEGMENT}
   if lSizeOfElement > SegmentSize_C then
   begin
     MessageDlg('AllocateMem:  This procedure cannot allocate memory ' +
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
 end;{procedure ReAllocateMem}


 procedure Array_t.FreeMemory(pStartOfBlock:pointer);
 {Frees up the memory block pointed to by pStartOfBlock.  The handle
  is found for the block and then is used to unlock then free the block}
 begin
   {Firstly unlock the block if successful returns 0}
   while (bool(GlobalUnlock(HndlData)) <> bool(0)) do begin end;
{   if GlobalUnlock(hHandle) then
     messageDlg('Memory management:  `FreeMem'''+
                ' did not fully unlock the memory block with starting '+
                'address $'+inttohex(longint(pStartOfBlock),8)+'.',
                mtWarning,[mbOk],0)
   else
     {Next free the block if successful returns 0}
     if bool(GlobalFree(HndlData)) <> bool(0) then
       messageDlg('Memory management:  `FreeMem'''+
                  ' could not free the memory block with starting '+
                  'address $'+inttohex(longint(pStartOfBlock),8)+'.',
                  mtWarning,[mbOk],0);
 end;{procedure FreeMem}

constructor Array_T.init(SizeOfDataType : integer; InitialSize : longint);

begin
     iDataTypeSize := SizeOfDataType;
     lMaxSize := InitialSize;

     if sizeof(integer) = 2 then
     begin
          if ((SEGMENTSIZE_C mod SizeOfDataType) = 0) then
             Fit := TRUE
          else
              Fit := FALSE;

          new(ptrDataStart);
          AllocateMem(ptrDataStart,InitialSize,SizeOfDataType,lOddDataUnitsPerSegment);
     end
     else
     begin
          getmem(ptrDataStart,lMaxSize*iDataTypeSize);
     end;

end;

destructor Array_T.Destroy;

begin
     if sizeof(integer) = 2 then
     begin
          FreeMemory(ptrDataStart);
          dispose(ptrDataStart);
     end
     else
     begin
          freemem(ptrDataStart);
     end;

     inherited destroy;
end;

procedure Array_T.PtrDispose;
begin
{$ifdef bit16}
     hndlData := selectorof(ptrDataStart);
     hndlData := globalrealloc(hndlData,0,GMEM_MODIFY+GMEM_MOVEABLE);
     ptrDataStart := globallock(hndlData);
{$endif}
end;

procedure Array_T.resize(lNewSize : longint);
begin
     if lNewSize > 0 then
        lMaxSize := lNewSize
     else
     begin
          resize(1);
          lMaxSize := 0;
          exit;
     end;

     if sizeof(integer) = 2 then
     begin
          ReAllocateMem(ptrDataStart,lNewSize,iDataTypeSize,lOddDataUnitsPerSegment);
     end
     else
     begin
          reallocmem(ptrDataStart,lMaxSize*iDataTypeSize);
     end;
end;

procedure Array_T.setValue(lElementNum : longint; ptrData : pointer);

var
   pNewPtr : pointer;
   iPosition : integer;

{$ifdef bit16}
procedure setmemeven;
 {Treats the memory block as an array and places the value into the memory
  at the appropriate position}
 var
    lOffset:longint;
    pNewPointer:pointer;
 begin
      lOffset := (lElementNum - 1) * iDataTypeSize;

   {Ptr is a function specifying the segment and offset parts of pointer}
      new(pNewPointer);
      pNewPointer := Ptr(
                    FourBytes_T(ptrDataStart).wHighTwoBytes +
                    FourBytes_T(lOffset).wHighTwoBytes * SelectorInc,
                    {Segment part incremented by multiples of SelectorInc
                     which is separation between sectors}
                    FourBytes_T(ptrDataStart).wLowTwoBytes +
                    FourBytes_T(lOffset).wLowTwoBytes);

      hmemcpy(pNewPointer,ptrData,iDataTypeSize);
end;

procedure setmemodd;
 var
   lOffset,
   lSegments,
   lExtraElements,
   lActualElementNo : longint;
   pNewPointer:pointer;
   lfirst,lsecond : word;
begin
   lActualElementNo := lElementNum - 1;
   if lActualElementNo > lOddDataUnitsPerSegment then
   {The fancy arithmetic only needed if we have to go past first segment}
   begin
     lSegments := lActualElementNo div lOddDataUnitsPerSegment;
     lExtraElements := lActualElementNo mod lOddDataUnitsPerSegment;
     lOffSet := lSegments * SegmentSize_C + lExtraElements * iDataTypeSize;
   end
   else
     {less one since pointer points to first location}
     lOffset := lActualElementNo * iDataTypeSize;

   {Ptr is a function specifying the segment and offset parts of pointer}
   try
   lfirst := FourBytes_T(lOffset).wHighTwoBytes;
   lfirst := lfirst * SelectorInc;
   inc(lFirst,FourBytes_T(ptrDataStart).wHighTwoBytes);
   lsecond := FourBytes_T(lOffset).wLowTwoBytes;
   inc(lsecond,FourBytes_T(ptrDataStart).wLowTwoBytes);

   new(pNewPointer);
  pNewPointer := Ptr(word(lfirst),word(lsecond));
   {Treat memory pointed to as if it is a longint, assign value to it}
   hmemcpy(pNewPointer,ptrData,iDataTypeSize);
   except on exception do
   begin
        messagedlg('error in set odd',mterror,[mbok],0);
   end;
   end;
end;
{$endif}
begin
{$ifdef rngCheck}
      if (lElementNum < 1) or (lElementNum > lMaxSize) then
      begin
          MessageDlg('Error rtnPtr trying to access beyond scope, index ' + IntToStr(lElementNum)
                     + ' - Halting',
                     mtError,[mbOK],0);
          halt;
     end;
{$endif}
{$ifdef bit16}
     if Fit then
        setMemEven
     else
        setmemodd;
{$else}
      new(pNewptr);
      iPosition := integer(ptrDataStart);
      inc(iPosition,(lElementNum-1)*iDataTypeSize);
      pNewPtr := ptr(iPosition);
      move(ptrData^,pNewPtr^,iDataTypeSize);
{$endif}
end;

procedure Array_T.rtnValue(lElementNum : longint; ptrData : pointer);

var
   pNewPtr : pointer;
   iPosition : integer;
{$ifdef bit16}
procedure rtnMemEven;
 var
   lOffset:longint;
   pNewPointer:pointer;
 begin
   lOffset := (lElementNum - 1) * iDataTypeSize;
   {Ptr is a function specifying the segment and offset parts of pointer}
   new(pNewPointer);
   pNewPointer := Ptr(
                    FourBytes_T(ptrDataStart).wHighTwoBytes +
                    FourBytes_T(lOffset).wHighTwoBytes * SelectorInc,
                    {Segment part incremented by multiples of SelectorInc
                     which is separation between sectors}
                    FourBytes_T(ptrDataStart).wLowTwoBytes +
                    FourBytes_T(lOffset).wLowTwoBytes);
   {Treat memory pointed to as if it is a longint, assign value to it}
   hmemcpy(ptrData,pNewPointer,iDataTypeSize);
 end;

procedure rtnMemOdd;
 var
   lOffset,
   lSegments,
   lExtraElements,
   lActualElementNo : longint;
   pNewPointer:pointer;
   wLowWord, wHighWord : word;
   lfirst,lsecond : word;
 begin
   lActualElementNo := lElementNum - 1;
   if lActualElementNo > lOddDataUnitsPerSegment then
   {The fancy arithmetic only needed if we have to go past first segment}
   begin
     lSegments := lActualElementNo div lOddDataUnitsPerSegment;
     lExtraElements := lActualElementNo mod lOddDataUnitsPerSegment;
     lOffSet := lSegments * SegmentSize_C + lExtraElements * iDataTypeSize;
   end
   else
     {less one since pointer points to first location}
     lOffset := lActualElementNo * iDataTypeSize;

   {Ptr is a function specifying the segment and offset parts of pointer}

try
   lfirst := FourBytes_T(lOffset).wHighTwoBytes;
   lfirst := lfirst * SelectorInc;
   inc(lFirst,FourBytes_T(ptrDataStart).wHighTwoBytes);
   lsecond := FourBytes_T(lOffset).wLowTwoBytes;
   inc(lsecond,FourBytes_T(ptrDataStart).wLowTwoBytes);
except on exception do
begin
;
end;
end;
   new(pNewPointer);
  pNewPointer := Ptr(word(lfirst),word(lsecond));


  hmemcpy(ptrData,pNewPointer,iDataTypeSize);

 end;
{$endif}
 begin
{$ifdef rngCheck}
      if (lElementNum < 1) or (lElementNum > lMaxSize) then
      begin
          MessageDlg('Error rtnValue trying to access beyond scope, index ' + IntToStr(lElementNum)
                     + ' - Halting',
                     mtError,[mbOK],0);
          halt;
     end;
{$endif}
{$ifdef bit16}
      if fit then
         rtnMemEven
      else
          rtnMemOdd;
{$else}
      new(pNewptr);
      iPosition := integer(ptrDataStart);
      inc(iPosition,(lElementNum-1)*iDataTypeSize);
      pNewPtr := ptr(iPosition);
      move(pNewPtr^,ptrData^,iDataTypeSize);
{$endif}
 end;

function Array_T.rtnPtr(lElementNum : longint) : pointer;
var
   iPosition : integer;
{$ifdef bit16}
   tempHandle : tHandle;

procedure rtnMemEven;
 var
   lOffset:longint;
   pNewPointer:pointer;
 begin
   lOffset := (lElementNum - 1) * iDataTypeSize;
   {Ptr is a function specifying the segment and offset parts of pointer}
   Result := Ptr(
                    FourBytes_T(ptrDataStart).wHighTwoBytes +
                    FourBytes_T(lOffset).wHighTwoBytes * SelectorInc,
                    {Segment part incremented by multiples of SelectorInc
                     which is separation between sectors}
                    FourBytes_T(ptrDataStart).wLowTwoBytes +
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
   if lActualElementNo > lOddDataUnitsPerSegment then
   {The fancy arithmetic only needed if we have to go past first segment}
   begin
     lSegments := lActualElementNo div lOddDataUnitsPerSegment;
     lExtraElements := lActualElementNo mod lOddDataUnitsPerSegment;
     lOffSet := lSegments * SegmentSize_C + lExtraElements * iDataTypeSize;
   end
   else
     {less one since pointer points to first location}
     lOffset := lActualElementNo * iDataTypeSize;

   {Ptr is a function specifying the segment and offset parts of pointer}

  Result := Ptr(
                    FourBytes_T(ptrDataStart).wHighTwoBytes +
                    FourBytes_T(lOffset).wHighTwoBytes * SelectorInc,
                    {Segment part incremented by multiples of SelectorInc
                     which is separation between sectors}
                    FourBytes_T(ptrDataStart).wLowTwoBytes +
                    FourBytes_T(lOffset).wLowTwoBytes);



 end;
{$endif}
 begin
      if (lElementNum < 1) or (lElementNum > lMaxSize) then
         MessageDlg('access beyond scope, index ' + IntToStr(lElementNum),
                    mtError,[mbOK],0);

{$ifdef bit16}
      hndlData := selectorof(ptrDataStart);
      hndlData := globalrealloc(hndlData,0,GMEM_MODIFY+GMEM_FIXED);
      ptrDataStart := globallock(hndlData);
{$endif}
{      hndlData := globalrealloc(hndlData,0,GMEM_MODIFY+GMEM_FIXED);
      ptrDataStart := globallock(hndlData);
}
      new(Result);
{$ifdef bit16}
      tempHandle := selectorof(Result);
      tempHandle := globalalloc(GPTR,iDataTypeSize);
      result := globallock(tempHandle);
{$endif}
 {     tempHandle := globalalloc(GPTR,iDataTypeSize);
      result := globallock(tempHandle);
 }
 {$ifdef bit16}
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


function SortLongArray(const unsortedArray_C : array_t) : array_t;
type

      datatype = longint;

var
   SortedList : LongList_O;
   value : longint;
   test : longint;
   flag : boolean;
   x : longint;

begin
     flag := FALSE;

     Result := Array_T.create;
     Result := Result.init(sizeof(datatype),unsortedarray_c.lMaxSize);
     SortedList := LongList_O.create;
     SortedList.init;

(*
{$ifdef bit16}
     new(Result);
     new(SortedList);
{$else}
     getmem(pointer(Result),sizeof(array_t));
     getmem(pointer(SortedList),sizeof(array_t));
{$endif}
 *)

     {Build the sorted list}

     unSortedArray_c.rtnValue(1,@value);
     SortedList.addNode(value);
     for x := 2 to unSortedArray_c.lMaxSize do
     begin
          flag := FALSE;
          unSortedArray_c.rtnValue(x,@Value);
          SortedList.GoStart;
          test := SortedList.readdata;
          if test <= value then
          begin
               SortedList.NewHead(Value);
          end
          else
          begin
          repeat
                SortedList.GoNext;
                test := SortedList.readdata;
                if test <= Value then
                begin
                     SortedList.GoPrev;
                     SortedList.addNode(Value);
                     flag := TRUE;
                end;
                if SortedList.pCurrent.pNext = Nil then
                begin
                     {insert at tail}
                     SortedList.addNode(value);
                     flag := TRUE
                end;
          until flag;
          end;
     end;

     {Pass the sorted list into the array}
     SortedList.GoStart;
     for x := 1 to unsortedarray_c.lMaxSize do
     begin
          value := sortedlist.readdata;
          Result.setValue(x,@value);
          SortedList.GoNext;
     end;
end;

function findLongMatch(SortArray : array_t; RecordtoMatch : longint) : integer;
type
    Direction = (Up,Down);

      datatype = longint;

var
   ActiveDirection : Direction;
   lSizeOfMove : longint;
   lPos : longint;

   Value : datatype;

   function findsize : longint;
   begin
        result := 2;
        repeat
              result := result * 2;
        until result >= SortArray.lMaxSize;
   end;

begin
     Result := 0;
     sortArray.rtnValue(1,@value);
     if RecordToMatch = Value then
        Result := 1
     else
     begin
          lSizeofMove := findsize div 2;
          ActiveDirection := Up;
          lPos := 1;
          repeat
                if ActiveDirection = Up then
                   inc(lPos,lSizeOfMove)
                else
                    dec(lPos,lSizeOfMove);
                if lPos <= sortArray.lMaxSize then
                begin
                     sortArray.rtnValue(lPos,@value);
                     if RecordtoMatch = value then
                        result := lpos
                     else
                     begin
                          if RecordToMatch > Value then
                          begin
                               ActiveDirection := Down;
                          end
                          else
                          begin
                               ActiveDirection := Up;
                          end;
                          lSizeOfMove := lSizeOfMove div 2;
                     end;
                end
                else
                begin
                     ActiveDirection := Down;
                     lSizeOfMove := lSizeOfMove Div 2;
                end;
          if lSizeOfMove = 0 then
          begin
               Result := -1;
               lPos := Result;
          end;
          until  Result = lPos;

     end;
     Result := Value;
end;

 procedure randomlongArray(var RndArray : array_t);
 var
    x : longint;
    value : longint;
 begin
{      Randomize;}
      for x := 1 to RndArray.lMaxSize do
      begin
           value := random(6555)+x;
           RndArray.setValue(x,@value);
      end;
 end;

{******************************************************************************}

end.