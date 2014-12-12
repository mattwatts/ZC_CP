unit SORTS;

{$I STD_DEF.PAS}

interface

uses
  {$IFDEF bit16}
  Arrayt16;
  {$ELSE}
  ds;
  {$ENDIF}

procedure SelectionSortIntArr(var Arr : Array_t);
procedure SelectionSortFloatArr(var Arr : Array_t);

procedure QuickSortIntArr(var Arr : Array_t;
                          const iLower, iUpper : integer);
procedure QuickSortFloatArr(var Arr : Array_t;
                            const iLower, iUpper : integer);
procedure QuickSortCustomFloatArr(var Arr : Array_t;
                                  const iLower, iUpper : integer);

implementation

uses reallist;

procedure SelectionSortIntArr(var Arr : Array_t);
{var
   lPass, lCount, lMinPos : longint;
   iValue, iTest, iMin : integer;}
begin
     {sorts lo to hi}

     QuickSortIntArr(Arr,1,Arr.lMaxSize);
     (*
     if (Arr.lMaxSize > 1) then
        for lPass := 1 to (Arr.lMaxSize-1) do
        begin
             lMinPos := lPass;
             for lCount := (lPass+1) to Arr.lMaxSize do
             begin
                  Arr.rtnValue(lCount,@iTest);
                  Arr.rtnValue(lMinPos,@iMin);
                  if (iTest < iMin) then
                     lMinPos := lCount;
             end;

             if (lPass <> lMinPos) then
             begin
                  Arr.rtnValue(lMinPos,@iMin);
                  Arr.rtnValue(lPass,@iValue);
                  Arr.setValue(lPass,@iMin);
                  Arr.setValue(lMinPos,@iValue);
             end;
        end;*)
end;

procedure SelectionSortFloatArr(var Arr : Array_t);
{var
   lPass, lCount, lMaxPos : longint;
   rValue, rTest, rMax : extended;}
begin
     {sorts hi to lo}

     QuickSortFloatArr(Arr,1,Arr.lMaxSize);

     (*
     if (Arr.lMaxSize > 1) then
        for lPass := 1 to (Arr.lMaxSize-1) do
        begin
             lMaxPos := lPass;
             for lCount := (lPass+1) to Arr.lMaxSize do
             begin
                  Arr.rtnValue(lCount,@rTest);
                  Arr.rtnValue(lMaxPos,@rMax);
                  if (rTest > rMax) then
                     lMaxPos := lCount;
             end;

             if (lPass <> lMaxPos) then
             begin
                  {exchange the elements unless they have the same index number}
                  Arr.rtnValue(lMaxPos,@rMax);
                  Arr.rtnValue(lPass,@rValue);
                  Arr.setValue(lPass,@rMax);
                  Arr.setValue(lMaxPos,@rValue);
             end;
        end;*)
end;

procedure QuickSortIntArr(var Arr : Array_t;
                          const iLower, iUpper : integer);
var
   iPivotPoint : integer;

   procedure Partition(var Arr : Array_t;
                       iLower, iUpper : integer;
                       var iPivotPoint : integer);
   var
      iPivot, iValue : integer;
   begin
        Arr.rtnValue(iLower,@iPivot);
        while (iLower < iUpper) do
        begin
             {begin right to left scan}

             Arr.rtnValue(iUpper,@iValue);

             while (iPivot < iValue)
             and (iLower < iUpper) do
             begin
                  Dec(iUpper);
                  Arr.rtnValue(iUpper,@iValue);
             end;

             if (iUpper <> iLower) then
             begin
                  {move entry indexed by Hi to left side of partition}
                  Arr.rtnValue(iUpper,@iValue);
                  Arr.setValue(iLower,@iValue);
                  Inc(iLower);
             end;

             {begin left to right scan}

             Arr.rtnValue(iLower,@iValue);

             while (iPivot > iValue)
             and (iLower < iUpper) do
             begin
                  Inc(iLower);
                  Arr.rtnValue(iLower,@iValue);
             end;

             if (iUpper <> iLower) then
             begin
                  Arr.rtnValue(iLower,@iValue);
                  Arr.setValue(iUpper,@iValue);
                  Dec(iUpper);
             end;
        end;

        {iLower and iUpper met somewhere between their initial setting}
        Arr.setValue(iUpper,@iPivot);
        iPivotPoint := iUpper;

   end; {of sub-procedure Partition}

begin {of procedure QuickSortIntArr}

     Partition(Arr,iLower,iUpper,iPivotPoint);

     {recursive calls partition left and right segments}
     if (iLower < iPivotPoint) then
        QuickSortIntArr(Arr,iLower,iPivotPoint-1);

     if (iUpper > iPivotPoint) then
        QuickSortIntArr(Arr,iPivotPoint+1,iUpper);

end; {of procedure QuickSortIntArr}

procedure QuickSortFloatArr(var Arr : Array_t;
                            const iLower, iUpper : integer);
var
   iPivotPoint : integer;

   procedure Partition(var Arr : Array_t;
                       iLower, iUpper : integer;
                       var iPivotPoint : integer);
   var
      rPivot, rValue : extended;
   begin
        Arr.rtnValue(iLower,@rPivot);
        while (iLower < iUpper) do
        begin
             {begin right to left scan}

             Arr.rtnValue(iUpper,@rValue);

             while (rPivot > rValue)
             and (iLower < iUpper) do
             begin
                  Dec(iUpper);
                  Arr.rtnValue(iUpper,@rValue);
             end;

             if (iUpper <> iLower) then
             begin
                  {move entry indexed by Hi to left side of partition}
                  Arr.rtnValue(iUpper,@rValue);
                  Arr.setValue(iLower,@rValue);
                  Inc(iLower);
             end;

             {begin left to right scan}

             Arr.rtnValue(iLower,@rValue);

             while (rPivot < rValue)
             and (iLower < iUpper) do
             begin
                  Inc(iLower);
                  Arr.rtnValue(iLower,@rValue);
             end;

             if (iUpper <> iLower) then
             begin
                  Arr.rtnValue(iLower,@rValue);
                  Arr.setValue(iUpper,@rValue);
                  Dec(iUpper);
             end;
        end;

        {iLower and iUpper met somewhere between their initial setting}
        Arr.setValue(iUpper,@rPivot);
        iPivotPoint := iUpper;

   end; {of sub-procedure Partition}

begin {of procedure QuickSortFloatArr}

     Partition(Arr,iLower,iUpper,iPivotPoint);

     {recursive calls partition left and right segments}
     if (iLower < iPivotPoint) then
        QuickSortFloatArr(Arr,iLower,iPivotPoint-1);

     if (iUpper > iPivotPoint) then
        QuickSortFloatArr(Arr,iPivotPoint+1,iUpper);

end; {of procedure QuickSortFloatArr}

procedure QuickSortCustomFloatArr(var Arr : Array_t;
                                  const iLower, iUpper : integer);
var
   iPivotPoint : integer;

   procedure Partition(var Arr : Array_t;
                       iLower, iUpper : integer;
                       var iPivotPoint : integer);
   var
      Pivot, Value : trueFloattype; // rValue iIndex
      //rPivot, rValue : extended;
   begin
        Arr.rtnValue(iLower,@Pivot);
        while (iLower < iUpper) do
        begin
             {begin right to left scan}

             Arr.rtnValue(iUpper,@Value);

             while (Pivot.rValue > Value.rValue)
             and (iLower < iUpper) do
             begin
                  Dec(iUpper);
                  Arr.rtnValue(iUpper,@Value);
             end;

             if (iUpper <> iLower) then
             begin
                  {move entry indexed by Hi to left side of partition}
                  Arr.rtnValue(iUpper,@Value);
                  Arr.setValue(iLower,@Value);
                  Inc(iLower);
             end;

             {begin left to right scan}

             Arr.rtnValue(iLower,@Value);

             while (Pivot.rValue < Value.rValue)
             and (iLower < iUpper) do
             begin
                  Inc(iLower);
                  Arr.rtnValue(iLower,@Value);
             end;

             if (iUpper <> iLower) then
             begin
                  Arr.rtnValue(iLower,@Value);
                  Arr.setValue(iUpper,@Value);
                  Dec(iUpper);
             end;
        end;

        {iLower and iUpper met somewhere between their initial setting}
        Arr.setValue(iUpper,@Pivot);
        iPivotPoint := iUpper;

   end; {of sub-procedure Partition}

begin {of procedure QuickSortCustomFloatArr}

     Partition(Arr,iLower,iUpper,iPivotPoint);

     {recursive calls partition left and right segments}
     if (iLower < iPivotPoint) then
        QuickSortFloatArr(Arr,iLower,iPivotPoint-1);

     if (iUpper > iPivotPoint) then
        QuickSortFloatArr(Arr,iPivotPoint+1,iUpper);

end; {of procedure QuickSortCustomFloatArr}


end.
