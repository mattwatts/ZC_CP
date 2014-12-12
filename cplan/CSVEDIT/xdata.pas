unit xdata;


{$I \SOFTWARE\cplan\STD_DEF.PAS}

{$define rngCheck}

{$UNDEF TEST_UNIQUE_KEY}
{$UNDEF TEST_UNIQUE_STRING}

interface

uses
    Forms,
    Wintypes, winprocs,dialogs,sysutils,
    sitelist,featlist,
  {$IFDEF bit16}
  Arrayt16;
  {$ELSE}
  ds;
  {$ENDIF}


{Optimisation for interactive}
(*
function SortSiteArray(const unsortedArray_C : array_t) : array_t;
function findSiteMatch(SortArray : array_t; RecordtoMatch : string) : integer;
*)
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
procedure TestUniqueColumnArray(SortArray : array_t;
                                const sDataStructure : string);


implementation

uses
    Controls;

procedure TestUniqueIntArray(SortArray : array_t;
                             const sDataStructure : string);
type

      datatype = trueFeattype;

var
   value : datatype;
   iCount, iPreviousKey : integer;
   fFail : boolean;
   {$IFDEF TEST_UNIQUE_KEY}
   DbgFile : Text;
   {$ENDIF}
begin
     if (SortArray.lMaxSize > 0) then
     try
        fFail := False;
        SortArray.rtnValue(1,@value);
        iPreviousKey := value.iCode;
        {$IFDEF TEST_UNIQUE_KEY}
        assignfile(DbgFile,'d:\keytest_integer.txt');
        rewrite(DbgFile);
        writeln(DbgFile,'datastructure is ' + sDataStructure);
        writeln(DbgFile,'1,' + IntToStr(iPreviousKey));
        {$ENDIF}
        if (SortArray.lMaxSize > 1) then
           for iCount := 2 to SortArray.lMaxSize do
           begin
                SortArray.rtnValue(iCount,@value);

                {set fFail to false if current key is the same as the previous key}
                if (value.iCode = iPreviousKey) then
                   fFail := True;

                iPreviousKey := value.iCode;
                {$IFDEF TEST_UNIQUE_KEY}
                writeln(DbgFile,IntToStr(iCount) + ',' + IntToStr(iPreviousKey));
                {$ENDIF}
           end;

        {$IFDEF TEST_UNIQUE_KEY}
        if fFail then
           writeln(DbgFile,'Fail is True')
        else
            writeln(DbgFile,'Fail is False');
        closefile(DbgFile);
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
   {$IFDEF TEST_UNIQUE_STRING}
   DbgFile : Text;
   {$ENDIF}
begin
     if (SortArray.lMaxSize > 0) then
     try
        fFail := False;
        SortArray.rtnValue(1,@value);
        sPreviousKey := value.szGeoCode;
        {$IFDEF TEST_UNIQUE_STRING}
        assignfile(DbgFile,'d:\keytest_string.txt');
        //if FileExists('d:\keytest.txt') then
        //   reset(DbgFile)
        //else
            rewrite(DbgFile);
        writeln(DbgFile,'datastructure is ' + sDataStructure);
        writeln(DbgFile,'1,' + sPreviousKey);
        {$ENDIF}
        if (SortArray.lMaxSize > 1) then
           for iCount := 2 to SortArray.lMaxSize do
           begin
                SortArray.rtnValue(iCount,@value);

                {set fFail to false if current key is the same as the previous key}
                if (value.szGeoCode = sPreviousKey) then
                   fFail := True;

                sPreviousKey := value.szGeoCode;
                {$IFDEF TEST_UNIQUE_STRING}
                writeln(DbgFile,IntToStr(iCount) + ',' + sPreviousKey);
                {$ENDIF}
           end;

        {$IFDEF TEST_UNIQUE_STRING}
        if fFail then
           writeln(DbgFile,'Fail is True')
        else
            writeln(DbgFile,'Fail is False');
        closefile(DbgFile);
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
           MessageDlg('Exception in TestUniqueStrArray',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TestUniqueColumnArray(SortArray : array_t;
                                const sDataStructure : string);
type

      datatype = trueSitetype;

var
   value : datatype;
   iCount : integer;
   sPreviousKey : string;
   fFail : boolean;
   {$IFDEF TEST_UNIQUE_KEY}
   DbgFile : Text;
   {$ENDIF}
begin
     if (SortArray.lMaxSize > 0) then
     try
        fFail := False;
        SortArray.rtnValue(1,@value);
        sPreviousKey := value.szGeoCode;
        {$IFDEF TEST_UNIQUE_KEY}
        assignfile(DbgFile,'d:\keytest.txt');
        if FileExists('d:\keytest.txt') then
           reset(DbgFile)
        else
            rewrite(DbgFile);
        writeln(DbgFile,'datastructure is ' + sDataStructure);
        writeln(DbgFile,'1,' + sPreviousKey);
        {$ENDIF}
        if (SortArray.lMaxSize > 1) then
           for iCount := 2 to SortArray.lMaxSize do
           begin
                SortArray.rtnValue(iCount,@value);

                {set fFail to false if current key is the same as the previous key}
                if (value.szGeoCode = sPreviousKey) then
                   fFail := True;

                sPreviousKey := value.szGeoCode;
                {$IFDEF TEST_UNIQUE_KEY}
                writeln(DbgFile,IntToStr(iCount) + ',' + sPreviousKey);
                {$ENDIF}
           end;

        {$IFDEF TEST_UNIQUE_KEY}
        if fFail then
           writeln(DbgFile,'Fail is True')
        else
            writeln(DbgFile,'Fail is False');
        closefile(DbgFile);
        {$ENDIF}

        if fFail then
        begin
             {one or more key identifier(s) is replicated}
             Screen.Cursor := crDefault;
             MessageDlg('NOTE: In ' + sDataStructure + ' the matrix column identifiers are not unique.' + Chr(10) + Chr(13) +
                        'This will cause the wrong data to be used for the columns with' + Chr(10) + Chr(13) +
                        'replicated keys. You can continue to use this data, however it' + Chr(10) + Chr(13) +
                        'is suggested you rebuild this data structure with unique column' + Chr(10) + Chr(13) +
                        'identifiers.',
                        mtWarning,[mbOk],0);
             {Application.Terminate;
             Exit;}
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TestUniqueColumnArray',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


function SortIntegerArray(const unsortedArray_C : array_t) : array_t;
begin
     Result := SortFeatArray(unsortedArray_C);
end;

function findFeatMatch(SortArray : array_t; RecordtoMatch : longint) : integer;
begin
     Result := findIntegerMatch(SortArray, RecordtoMatch);
end;
(*
function SortSiteArray(const unsortedArray_C : array_t) : Array_t;
type

      datatype = trueSitetype;

var
   value : datatype;
   x : longint;
   szStr : string[8];

begin
     Result := array_T.create;

     Result.init(sizeof(datatype),unsortedarray_c.lMaxSize);

     unSortedArray_c.rtnValue(1,@szStr);
     value.szGeoCode := szStr;
     value.iIndex := 1;
     Result.setValue(1,@value);
     for x := 2 to unSortedArray_c.lMaxSize do
     begin
          unSortedArray_c.rtnValue(x,@szStr);
          value.szGeoCode := szStr;
          value.iIndex := x;

          Result.setValue(x,@value)
     end;

     Result.quicksortwrt(0,scString,1,Result.lMaxSize);
end;
*)

(*
procedure SortFeatArray(const unsortedArray_C : array_t;
                        var OArr : Array_t);
type

      datatype = trueFeattype;

var
   value : datatype;
   x : longint;

   iInt : integer;

begin
     OArr := Array_T.create;
     OArr.init(sizeof(datatype),unsortedarray_c.lMaxSize);

     unSortedArray_c.rtnValue(1,@iInt);
     value.iCode := iInt;
     value.iIndex := 1;
     OArr.setValue(1,@value);

     for x := 2 to unSortedArray_c.lMaxSize do
     begin
          unSortedArray_c.rtnValue(x,@iInt);
          value.iCode := iInt;
          value.iIndex := integer(x);

          OArr.setValue(x,@value);
     end;

     OArr.quicksortwrt(0,scInt,1,OArr.lMaxSize);
end;
*)


{******************************************************************************}

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
end;


function findIntegerMatch(SortArray : array_t; RecordtoMatch : longint) : integer;
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
     if (Value.iCode = RecordToMatch) then
        Result := Value.iIndex
     else
         Result := -1;
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


// ----------------------------------------------------

end.
