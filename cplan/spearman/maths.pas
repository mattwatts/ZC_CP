unit maths;

interface

implementation

uses
    spman, dialogs, classes;

procedure ConvertSPDataToVariantArray(var Value1, Value2 : Variant;
                                      const DA : dataarray_t;
                                      const iNumberOfRecords : integer);
var
   iCount : integer;
   rValue : double;
begin
     try
        // create the two arrays we are writing data to
        Value1 := VarArrayCreate([1,iNumberOfRecords],varDouble);
        Value2 := VarArrayCreate([1,iNumberOfRecords],varDouble);

        // read iNumberOfRecords records of data from da and write it to Value1 and Value2
        for iCount := 1 to iNumberOfRecords do
        begin
             rValue := DA[iCount].real1;
             Value1[iCount] := rValue;
             rValue := DA[iCount].real2;
             Value2[iCount] := rValue;
        end;

     except
           MessageDlg('Exception in ConvertSPDataToVariantArray',mtError,[mbOk],0);
     end;
end;

procedure SP_ReduceDuplicatesFromList(var list, countlist : TList);
var
   iCount, iValue, iFrequency : integer;
begin
     try
        // traverse the list, removing duplicated values from it
        // create count list, setting frequency of all values to 1
        countlist := TList.Create;
        countlist.capacity := list.count;
        iValue := 1;
        for iCount := 1 to list.count do
            countlist.Add(@iValue);

        // traverse the list comparing values
        // if we find adjacent values that are identical,
        //   set the first value to nil
        //   increase frequency of second value by 1
        for iCount := 1 to (list.count-1) do
            if (double(list.Items[iCount-1]^) = double(list.Items[iCount]^))
            and (list.Items[iCount-1] <> nil) then
            begin
                 list.Items[iCount-1] := nil;
                 countlist.Items[iCount-1] := nil;
                 iFrequency := integer(countlist.Items[iCount]^);
                 Inc(iFrequency);
                 countlist.Delete(iCount);
                 countlist.Insert(iCount,@iFrequency);
            end;

        // remove the duplicated elements from the lists
        list.Pack;
        countlist.Pack;

     except
           MessageDlg('Exception in SP_ReduceDuplicatesFromList',mtError,[mbOk],0);
     end;
end;

// called by list.Sort below
function CompareFloatValues(Item1, Item2: Pointer): Integer;
begin
     // returns < 0 if Item1 is less than Item2,
     //         0 if they are equal and
     //         > 0 if Item1 is greater than Item2.
     try
        if (double(Item1^) < double(Item2^)) then
           Result := -1
        else
            if (double(Item1^) = double(Item2^)) then
               Result := 0
            else
                Result := 1;
     except
           MessageDlg('Exception in CompareFloatValues',mtError,[mbOk],0);
     end;
end;

procedure SP_SortReduceFloatArray(const inputFA : Variant;
                                  var outputFA,frequency : Variant;
                                  const iInputSize : integer;
                                  var iOutputSize : integer);
var
   list, countlist : TList;
   iCount, iFrequency : integer;
   dValue : double;
begin
     try
        // create a list and add the inputFA items to it
        list := TList.Create;
        list.capacity := iInputSize;
        list.Clear;
        for iCount := 1 to iInputSize do
        begin
             dValue := inputFA[iCount];
             list.Add(@dValue);
        end;

        // sort the list
        list.Sort(CompareFloatValues);

        // reduce duplicates from the sorted list
        SP_ReduceDuplicatesFromList(list,countlist);

        // write the sorted reduced list to outputFA
        iOutputSize := list.Count;
        outputFA := VarArrayCreate([1,iOutputSize],varDouble);
        frequency := VarArrayCreate([1,iOutputSize],varInteger);
        for iCount := 1 to iOutputSize do
        begin
             iFrequency := integer(countlist.Items[iCount-1]^);
             frequency[iCount] := iFrequency;

             dValue := double(list.Items[iCount-1]^);
             outputFA[iCount] := dValue;
        end;

        // dispose of temporary lists that have been created
        list.Free;
        countlist.Free;

     except
           MessageDlg('Exception in SP_SortReduceFloatArray',mtError,[mbOk],0);
     end;
end;

function FindValueByDividingInterval(const dValue : double;
                                     const ValueArray : Variant;
                                     const iArraySize : integer) : integer;
var
   dCompare : double;
   iHigh, iLow, iPivot : integer;
begin
     // result is the index (zero based) of dValue in ValueArray

     // sorted from low to high ?
     // start with the middle element
     // if element = value
     //    match
     // else
     //     if element < value
     //        search higher
     //     else
     //         search lower
     iPivot := iArraySize div 2;
     iLow := 1;
     iHigh := iArraySize;
     repeat
           dCompare := ValueArray[iPivot];

           if (dCompare < dValue) then
           begin
                // search higher
                iLow := iPivot + 1;
                iPivot := iLow + ((iHigh - iLow) div 2);
           end
           else
               if (dCompare > dValue) then
               begin
                    // search lower
                    iHigh := iPivot - 1;
                    iPivot := (iHigh - iLow) div 2;
               end;

     until (ValueArray[iPivot] = dValue);

     Result := iPivot;
end;

procedure SP_TieValues;
var
   _Real1, _Real2,
   _sorted1, _sorted2,
   _frequency1, _frequency2,
   _Rank1Sum, _Rank2Sum : Variant;
   iSize, isorted1Size, isorted2Size, iCount, iIndex, iFrequency : integer;

begin
     try
        // read the dataarray real1 & real2 values and sort/reduce them
        ConvertSPDataToVariantArray(_Real1,_Real2,dataarray,lines);
        iSize := lines;
        SP_SortReduceFloatArray(_Real1,_sorted1,_frequency1,iSize,isorted1Size);
        SP_SortReduceFloatArray(_Real2,_sorted2,_frequency2,iSize,isorted2Size);
        // initialise 1..tie variables to sum rank for real 1 & real2
        _Rank1Sum := VarArrayCreate([1,isorted1Size],varDouble);
        _Rank2Sum := VarArrayCreate([1,isorted2Size],varDouble);
        for iCount := 1 to iSorted1Size do
            _Rank1Sum[iCount] := 0;
        for iCount := 1 to iSorted2Size do
            _Rank2Sum[iCount] := 0;

        // use the sorted value and frequency arrays to do a spearman 'Ties' operation
        // ie. traverse dataarray :
        //       set .tied1 & .tied2
        //       adjust rank
        for iCount := 1 to lines do
        begin
             // process real 1
             iIndex := FindValueByDividingInterval(_Real1[iCount],_sorted1,isorted1Size);
             iFrequency := _frequency1.Items[iIndex];
             dataarray[iCount].tied1 := (iFrequency > 1);
             _Rank1Sum[iIndex] := _Rank1Sum[iIndex] + dataarray[iCount].rank1;
             // process real 2
             iIndex := FindValueByDividingInterval(_Real2[iCount],_sorted2,isorted2Size);
             iFrequency := _frequency2.Items[iIndex];
             dataarray[iCount].tied2 := (iFrequency > 1);
             _Rank2Sum[iIndex] := _Rank2Sum[iIndex] + dataarray[iCount].rank2;

             // sum the rank of all ties for each seperate tie value
             // ie. Rank1Sum & Rank2Sum are array 1..sortedsize of double
             //     (1 double sum value for each iIndex)
             // make the rank of these ties = the summed rank / the tie frequency
        end;

        // reparse the lines and rank them according to the summed rank and tie frequency
        for iCount := 1 to lines do
        begin
             // process real 1
             iIndex := FindValueByDividingInterval(_Real1[iCount],_sorted1,isorted1Size);
             iFrequency := _frequency1.Items[iIndex];
             dataarray[iCount].rank1 := _Rank1Sum[iIndex] / iFrequency;
             // process real 2
             iIndex := FindValueByDividingInterval(_Real2[iCount],_sorted2,isorted2Size);
             iFrequency := _frequency2.Items[iIndex];
             dataarray[iCount].rank2 := _Rank2Sum[iIndex] / iFrequency;
        end;
        // dispose of temporary arrays that have been created
        _Real1.Free;
        _Real2.Free;
        _sorted1.Free;
        _sorted2.Free;
        _frequency1.Free;
        _frequency2.Free;
        _Rank1Sum.Free;
        _Rank2Sum.Free;

     except
           MessageDlg('Exception in SP_SortArrays',mtError,[mbOk],0);
     end;
end;

end.
