unit Opt1;

{$I \SOFTWARE\cplan\cplan\STD_DEF.PAS}

{$define rngCheck}

{$UNDEF UNIQUE_TEST}

interface

uses
    
    Wintypes, winprocs,dialogs,sysutils,
    sitelist,featlist, ds;


{Optimisation for interactive}

function SortFeatArray(const unsortedArray_C : array_t) : array_t;
function findFeatMatch(SortArray : array_t; RecordtoMatch : longint) : integer;

function SortIntegerArray(const unsortedArray_C : array_t) : array_t;
function findIntegerMatch(SortArray : array_t; RecordtoMatch : longint) : integer;

function SortStrArray(const unsortedArray_C : array_t) : array_t;
function findStrMatch(SortArray : array_t; RecordtoMatch : string) : integer;

procedure TestUniqueIntArray(SortArray : array_t;
                             const sDataStructure : string);
procedure TestUniqueStrArray(SortArray : array_t;
                             const sDataStructure : string);

implementation

uses
    Forms,Toolmisc,Controls, Control;

function SortIntegerArray(const unsortedArray_C : array_t) : array_t;
begin
     Result := SortFeatArray(unsortedArray_C);
end;

function findIntegerMatch(SortArray : array_t; RecordtoMatch : longint) : integer;
begin
     Result := findFeatMatch(SortArray, RecordtoMatch);
end;

procedure TestUniqueIntArray(SortArray : array_t;
                             const sDataStructure : string);
type

      datatype = trueFeattype;

var
   value : datatype;
   iCount, iPreviousKey : integer;
   fFail : boolean;
   {$IFDEF UNIQUE_TEST}
   DebugFile : Text;
   {$ENDIF}
begin
     if (SortArray.lMaxSize > 0) then
     try
        {$IFDEF UNIQUE_TEST}
        try
           assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\unique_test.csv');
           rewrite(DebugFile);
        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in TestUniqueIntArray rewriting debug file',mtError,[mbOk],0);
        end;
        {$ENDIF}

        fFail := False;
        SortArray.rtnValue(1,@value);
        iPreviousKey := value.iCode;
        {$IFDEF UNIQUE_TEST}
        try
           writeln(DebugFile,'index,value');
           writeln(DebugFile,'1,' + IntToStr(iPreviousKey));
        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in TestUniqueIntArray writing to debug file',mtError,[mbOk],0);
        end;
        {$ENDIF}
        if (SortArray.lMaxSize > 1) then
           for iCount := 2 to SortArray.lMaxSize do
           begin
                SortArray.rtnValue(iCount,@value);

                {set fFail to false if current key is the same as the previous key}
                if (value.iCode = iPreviousKey) then
                   fFail := True;

                iPreviousKey := value.iCode;

                {$IFDEF UNIQUE_TEST}
                try
                   writeln(DebugFile,IntToStr(iCount) + ',' + IntToStr(iPreviousKey));
                except
                      Screen.Cursor := crDefault;
                      MessageDlg('Exception in TestUniqueIntArray writing to debug file',mtError,[mbOk],0);
                end;
                {$ENDIF}
           end;

        {$IFDEF UNIQUE_TEST}
        try
           closefile(DebugFile);
        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in TestUniqueIntArray closing debug file',mtError,[mbOk],0);
        end;
        {$ENDIF}


        if fFail then
        begin
             {one or more key identifier(s) is replicated}
             Screen.Cursor := crDefault;
             MessageDlg('NOTE: In ' + sDataStructure + ' the key values are not unique.' + Chr(10) + Chr(13) +
                        'This will cause the wrong data to be used for the rows with' + Chr(10) + Chr(13) +
                        'replicated keys. You can continue to use this data, however it' + Chr(10) + Chr(13) +
                        'is suggested you rebuild this data structure with unique key' + Chr(10) + Chr(13) +
                        'values for all the rows.',
                        mtWarning,[mbOk],0);
             {Application.Terminate;
             Exit;}
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TestUniqueIntArray',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TestUniqueStrArray(SortArray : array_t;
                             const sDataStructure : string);
type

      datatype = trueSitetype;

var
   value : datatype;
   iCount : integer;
   sPreviousKey : string;
   fFail : boolean;
begin
     if (SortArray.lMaxSize > 0) then
     try
        fFail := False;
        SortArray.rtnValue(1,@value);
        sPreviousKey := value.szGeoCode;
        if (SortArray.lMaxSize > 1) then
           for iCount := 2 to SortArray.lMaxSize do
           begin
                SortArray.rtnValue(iCount,@value);

                {set fFail to false if current key is the same as the previous key}
                if (value.szGeoCode = sPreviousKey) then
                   fFail := True;

                sPreviousKey := value.szGeoCode;
           end;

        if fFail then
        begin
             {one or more key identifier(s) is replicated}
             Screen.Cursor := crDefault;
             MessageDlg('NOTE: In ' + sDataStructure + ' the key values are not unique.' + Chr(10) + Chr(13) +
                        'This will cause the wrong data to be used for the rows with' + Chr(10) + Chr(13) +
                        'replicated keys. You can continue to use this data, however it' + Chr(10) + Chr(13) +
                        'is suggested you rebuild this data structure with unique key' + Chr(10) + Chr(13) +
                        'values for all the rows.',
                        mtWarning,[mbOk],0);
             {Application.Terminate;
             Exit;}
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TestUniqueStrArray',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function SortFeatArray(const unsortedArray_C : array_t) : array_t;
type

      datatype = trueFeattype;

var
   SortedList : ListFeat_O;
   value : datatype;
   test : datatype;
   flag : boolean;
   x : longint;

   iInt : integer;

begin
     flag := FALSE;

     Result := Array_T.create;
     SortedList := ListFeat_O.create;

     Result.init(sizeof(datatype),unsortedarray_c.lMaxSize);
     SortedList.init;

     {Build the sorted list}

     unSortedArray_c.rtnValue(1,@iInt);
     value.iCode := iInt;
     value.iIndex := 1;
     SortedList.addNode(value);
     for x := 2 to unSortedArray_c.lMaxSize do
     begin
          flag := FALSE;
          unSortedArray_c.rtnValue(x,@iInt);
          value.iCode := iInt;
          value.iIndex := x;
          SortedList.GoStart;
          test := SortedList.readdata;
          if test.iCode <= value.iCode then
          begin
               SortedList.NewHead(Value);
          end
          else
          begin
          repeat
                SortedList.GoNext;
                test := SortedList.readdata;
                if test.iCode <= Value.iCode then
                begin
                     SortedList.GoPrev;
                     SortedList.addNode(Value);
                     flag := TRUE;
                end;
                if SortedList.pCurrent^.pNext = Nil then
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

     SortedList.clear;
end;


function findFeatMatch(SortArray : array_t; RecordtoMatch : longint) : integer;
type
    Direction = (Up,Down);

      datatype = truefeattype;

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
     if RecordToMatch = Value.iCode then
        Result := 1
     else
     begin
          if RecordToMatch > Value.iCode then
          begin
               Result := -1;
               exit;
          end;

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
                     if RecordtoMatch = value.iCode then
                        result := lpos
                     else
                     begin
                          if RecordToMatch > Value.iCode then
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
     Result := Value.iIndex;
end;



function SortStrArray(const unsortedArray_C : array_t) : array_t;
type

      datatype = trueSitetype;

var
   SortedList : ListSite_O;
   value : datatype;
   test : datatype;
   x : longint;
   szStr : string[255];

   flag : boolean;
begin
     Result := array_T.create;
     SortedList := ListSite_O.create;
     Result.init(sizeof(datatype),unsortedarray_c.lMaxSize);
     SortedList.init;

     {Build the sorted list}

     unSortedArray_c.rtnValue(1,@szStr);
     value.szGeoCode := szStr;
     value.iIndex := 1;
     SortedList.addNode(value);
     for x := 2 to unSortedArray_c.lMaxSize do
     begin
          flag := FALSE;
          unSortedArray_c.rtnValue(x,@szStr);
          value.szGeoCode := szStr;
          value.iIndex := x;
          SortedList.GoStart;
          test := SortedList.readdata;
          if test.szGeoCode <= value.szGeoCode then
          begin
               SortedList.NewHead(Value);
          end
          else
          begin
          repeat
                SortedList.GoNext;
                test := SortedList.readdata;
                if test.szGeoCode <= Value.szGeoCode then
                begin
                     SortedList.GoPrev;
                     SortedList.addNode(Value);
                     flag := TRUE;
                end;
                if SortedList.pCurrent^.pNext = Nil then
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

     SortedList.clear;
end;




function findStrMatch(SortArray : array_t; RecordtoMatch : string) : integer;
type
    Direction = (Up,Down);

    datatype = truesitetype;

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
     if RecordToMatch = Value.szGeoCode then
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
                     if RecordtoMatch = value.szGeoCode then
                        result := lpos
                     else
                     begin
                          if RecordToMatch > Value.szGeoCode then
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
     if (Value.szGeoCode = RecordToMatch) then
        Result := Value.iIndex
     else
         Result := -1;
end;



end.
