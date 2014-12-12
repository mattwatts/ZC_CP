unit sp_optimise_maths;

interface

procedure SP_TieValues;

implementation

uses
    spman, dialogs, classes, sysutils, sp_u1;

procedure DebugOutVariantArray(const Arr : Variant;
                               const iArrSize : integer;
                               const sFilename : string);
var
   iCount : integer;
   DebugFile : TextFile;
begin
     assignfile(DebugFile,sDebugDirectory + '\' + IntToStr(iTies) + '_' + sFilename);
     rewrite(DebugFile);
     writeln(DebugFile,'index,value');
     for iCount := 1 to iArrSize do
         writeln(DebugFile,IntToStr(iCount) + ',' + FloatToStr(Arr[iCount]));
     closefile(DebugFile);
end;



procedure SP_DebugReduced(const _sorted1,_sorted2,_frequency1,_frequency2 : Variant;
                          const isorted1Size,isorted2Size : integer);
var
   iCount : integer;
   rValue : double;
   DebugFile : TextFile;
begin
     if Form1.CheckTies.Checked then
     try
        assignfile(DebugFile,sDebugDirectory + '\debug_reduced1_' + IntToStr(iTies) + '.csv');
        rewrite(DebugFile);
        writeln(DebugFile,'row,sorted1,frequency1');
        for iCount := 1 to isorted1Size do
            writeln(DebugFile,IntToStr(iCount) + ',' +
                              FloatToStr(_sorted1[iCount]) + ',' +
                              IntToStr(_frequency1[iCount]));
        closefile(DebugFile);

        assignfile(DebugFile,sDebugDirectory + '\debug_reduced2_' + IntToStr(iTies) + '.csv');
        rewrite(DebugFile);
        writeln(DebugFile,'row,sorted2,frequency2');
        for iCount := 1 to isorted2Size do
            writeln(DebugFile,IntToStr(iCount) + ',' +
                              FloatToStr(_sorted2[iCount]) + ',' +
                              IntToStr(_frequency2[iCount]));
        closefile(DebugFile);

     except
           MessageDlg('Exception in SP_DebugReduced',mtError,[mbOk],0);
     end;
end;

{procedure SP_DebugVariantArray(const Value1, Value2 : Variant;
                               const iNumberOfRecords : integer);
var
   iCount : integer;
   rValue : double;
   DebugFile : TextFile;
begin
     try
        assignfile(DebugFile,sDebugDirectory + '\debug_variant_array.csv');
        rewrite(DebugFile);
        writeln(DebugFile,'row,Value1,Value2');

        for iCount := 1 to iNumberOfRecords do
            writeln(DebugFile,IntToStr(iCount) + ',' +
                              FloatToStr(Value1[iCount]) + ',' +
                              FloatToStr(Value2[iCount]));

        closefile(DebugFile);
     except
           MessageDlg('Exception in SP_DebugVariantArray',mtError,[mbOk],0);
     end;
end;}

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

procedure RemoveDuplicatesFromSortedArray(const InputArr : Variant;
                                       const iInputSize : integer;
                                       var OutputArr, OutputCountArr : Variant;
                                       var iOutputSize : integer;
                                       const fDebug : boolean);
var
   iCount, iValue, iFrequencyA, iFrequency, iDuplicates, iIndex : integer;
   InputCountArr : Variant;
begin
     try
        // traverse the array, removing duplicated values from it
        // create arrays, setting frequency of all values to 1
        InputCountArr := VarArrayCreate([1,iInputSize],varInteger);
        for iCount := 1 to iInputSize do
        begin
             InputCountArr[iCount] := 1;
        end;

        // traverse the list comparing values
        // if we find adjacent values that are identical,
        //   set the first value to nil
        //   add frequency of first value to the second values
        iDuplicates := 0;
        for iCount := 1 to (iInputSize-1) do
            if (InputArr[iCount] = InputArr[iCount+1]) then
            begin
                 iFrequency := InputCountArr[iCount+1];
                 iFrequencyA := InputCountArr[iCount];
                 iFrequency := iFrequency + iFrequencyA;
                 InputCountArr[iCount+1] := iFrequency;

                 Inc(iDuplicates);

                 InputCountArr[iCount] := -1;
            end;

        if fDebug then
        begin
             // display the value array and the frequency array
             DebugOutVariantArray(InputArr,iInputSize,'after_count_freq_values.csv');
             DebugOutVariantArray(InputCountArr,iInputSize,'after_count_freq_frequency.csv');
        end;

        // iDuplicates duplicates have been set to -1 in the array
        OutputArr := VarArrayCreate([1,iInputSize-iDuplicates],varDouble);
        OutputCountArr := VarArrayCreate([1,iInputSize-iDuplicates],varInteger);
        iIndex := 0;
        for iCount := 1 to iInputSize do
            if (InputCountArr[iCount] > -1) then
            begin
                 Inc(iIndex);
                 OutputArr[iIndex] := InputArr[iCount];
                 OutputCountArr[iIndex] := InputCountArr[iCount];
            end;

        iOutputSize := iIndex;
        //InputCountArr.Free;

     except
           MessageDlg('Exception in RemoveDuplicatesFromSortedArray',mtError,[mbOk],0);
     end;
end;

procedure QuickSortFloatArr(var Arr : Variant;
                            const iLower, iUpper : integer);
var
   iPivotPoint : integer;

   procedure Partition(var Arr : Variant;
                       iLower, iUpper : integer;
                       var iPivotPoint : integer);
   var
      rPivot, rValue : extended;
   begin
        //Arr.rtnValue(iLower,@rPivot);
        rPivot := Arr[iLower];
        while (iLower < iUpper) do
        begin
             {begin right to left scan}

             //Arr.rtnValue(iUpper,@rValue);
             rValue := Arr[iUpper];

             while (rPivot > rValue)
             and (iLower < iUpper) do
             begin
                  Dec(iUpper);
                  //Arr.rtnValue(iUpper,@rValue);
                  rValue := Arr[iUpper];
             end;

             if (iUpper <> iLower) then
             begin
                  {move entry indexed by Hi to left side of partition}
                  //Arr.rtnValue(iUpper,@rValue);
                  rValue := Arr[iUpper];
                  //Arr.setValue(iLower,@rValue);
                  Arr[iLower] := rValue;
                  Inc(iLower);
             end;

             {begin left to right scan}

             //Arr.rtnValue(iLower,@rValue);
             rValue := Arr[iLower];

             while (rPivot < rValue)
             and (iLower < iUpper) do
             begin
                  Inc(iLower);
                  //Arr.rtnValue(iLower,@rValue);
                  rValue := Arr[iLower]
             end;

             if (iUpper <> iLower) then
             begin
                  //Arr.rtnValue(iLower,@rValue);
                  rValue := Arr[iLower];
                  //Arr.setValue(iUpper,@rValue);
                  Arr[iUpper] := rValue;
                  Dec(iUpper);
             end;
        end;

        {iLower and iUpper met somewhere between their initial setting}
        //Arr.setValue(iUpper,@rPivot);
        Arr[iUpper] := rPivot;
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

procedure SP_SortReduceFloatArray(var inputFA : Variant;
                                  var outputFA,frequency : Variant;
                                  const iInputSize : integer;
                                  var iOutputSize : integer;
                                  const fDebug : boolean);
var
   list, countlist : TList;
   iCount, iFrequency : integer;
   dValue : double;
   COPYinputFA : Variant;
begin
     try
        // output array before sort
        if fDebug then
           DebugOutVariantArray(inputFA,iInputSize,'before_sort.csv');

        // copy inputFA before sorting it
        COPYinputFA := VarArrayCreate([1,iInputSize],varDouble);
        for iCount := 1 to iInputSize do
            COPYinputFA[iCount] := inputFA[iCount];
        // sort copy of inputFA
        QuickSortFloatArr(COPYinputFA,1,iInputSize);

        // output array after sort
        if fDebug then
           DebugOutVariantArray(COPYinputFA,iInputSize,'after_sort.csv');

        // reduce duplicates from the sorted list
        RemoveDuplicatesFromSortedArray(COPYinputFA,iInputSize,outputFA,frequency,iOutputSize,fDebug);

        if fDebug then
        begin
             DebugOutVariantArray(outputFA,iOutputSize,'duplicates_removes_values.csv');
             DebugOutVariantArray(frequency,iOutputSize,'duplicates_removes_frequency.csv');
        end;

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
     try
        // result is the index (zero based, actually 1 based) of dValue in ValueArray

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

              if (dCompare = dValue) then
                 // do nothing, we have found a match
              else
              begin
                   if (dCompare > dValue) then
                   begin
                        // search higher
                        iLow := iPivot + 1;
                        iPivot := iLow + ((iHigh - iLow) div 2);
                   end
                   else
                       if (dCompare < dValue) then
                       begin
                            // search lower
                            iHigh := iPivot - 1;
                            iPivot := (iHigh - iLow) div 2;
                            if (iPivot = 0) then
                               // do not allow this to happen
                               iPivot := 1;
                       end;
              end;

        until (ValueArray[iPivot] = dValue);

        Result := iPivot;

     except
           MessageDlg('Exception in FindValueByDividingInterval',mtError,[mbOk],0);
     end;
end;

procedure SP_TieValues;
var
   _Real1, _Real2,
   _sorted1, _sorted2,
   _frequency1, _frequency2,
   _Rank1Sum, _Rank2Sum : Variant;
   rRank : extended;
   iSize, isorted1Size, isorted2Size, iCount, iIndex, iFrequency : integer;

begin
     try
        // read the dataarray real1 & real2 values and sort/reduce them
        ConvertSPDataToVariantArray(_Real1,_Real2,dataarray,lines);
        //SP_DebugVariantArray(_Real1,_Real2,lines);
        iSize := lines;
        SP_SortReduceFloatArray(_Real1,_sorted1,_frequency1,iSize,isorted1Size,Form1.CheckTies.Checked);
        SP_SortReduceFloatArray(_Real2,_sorted2,_frequency2,iSize,isorted2Size,Form1.CheckTies.Checked);
        if Form1.CheckTies.Checked then
           SP_DebugReduced(_sorted1,_sorted2,_frequency1,_frequency2,isorted1Size,isorted2Size);
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
             // iIndex is row index of real 1
             iIndex := FindValueByDividingInterval(_Real1[iCount],_sorted1,isorted1Size);
             iFrequency := _frequency1[iIndex];
             dataarray[iCount].tied1 := (iFrequency > 1);
             if dataarray[iCount].tied1
             // and value is same as value for iIndex
             // ie. dataarray[iCount].real1 == _Real1[iCount]
             // note, convert dataarray to a double before comparing
             {and (dataarray[iCount].real1 = _Real1[iCount])} then
                 _Rank1Sum[iIndex] := _Rank1Sum[iIndex] + dataarray[iCount].rank1;
             // process real 2
             // iIndex is row index of real 2
             iIndex := FindValueByDividingInterval(_Real2[iCount],_sorted2,isorted2Size);
             iFrequency := _frequency2[iIndex];
             dataarray[iCount].tied2 := (iFrequency > 1);
             if dataarray[iCount].tied2
             {and (dataarray[iCount].real2 = _Real2[iCount])} then
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
             iFrequency := _frequency1[iIndex];
             rRank := _Rank1Sum[iIndex];
             {if (iFrequency > 2) then
                dataarray[iCount].rank1 := rRank / 2
             else}
             dataarray[iCount].rank1 := rRank / iFrequency;
             // process real 2
             iIndex := FindValueByDividingInterval(_Real2[iCount],_sorted2,isorted2Size);
             iFrequency := _frequency2[iIndex];
             rRank := _Rank2Sum[iIndex];
             {if (iFrequency > 2) then
                dataarray[iCount].rank2 := rRank / 2
             else}
             dataarray[iCount].rank2 := rRank / iFrequency;
        end;

     except
           MessageDlg('Exception in SP_TieValues',mtError,[mbOk],0);
     end;
end;

end.
