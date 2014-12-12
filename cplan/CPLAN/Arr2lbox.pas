unit ARR2LBOX;
{Various methods for converting listboxes to and from
 James Sheltons Array_t.

 Note: This unit is linked to TOOL16.EXE via a DLL, CPLANENG.DLL which
       must be recompiled seperately when changes are made.

 Author: Matthew Watts
 Date Modified: Wed June 11 1997}

{$I STD_DEF.PAS}

interface

uses
  StdCtrls, Classes,
  {$IFDEF bit16}
  Arrayt16;
  {$ELSE}
  ds;
  {$ENDIF}

function ListBox2IntArr(SourceBox : TListBox; var IntArr : Array_T) : boolean; export;
function ListBox2FloatArr(SourceBox : TListBox; var FloatArr : Array_T) : boolean; export;
function IntArr2ListBox(SourceBox : TListBox; IntArr : Array_T) : boolean; export;
function FloatArr2ListBox(SourceBox : TListBox; FloatArr : Array_T) : boolean; export;


function SortIntArray(const unsortedArray_C : array_t) : array_t; export;
function SortFloatArray(const unsortedArray_C : array_t) : array_t; export;


implementation

uses
    Global, SysUtils, Linklist;


function ListBox2IntArr(SourceBox : TListBox; var IntArr : Array_T) : boolean;
type
    LocalSortType = integer;

var
   iNumItems, iCount : integer;
   rValue : LocalSortType;

   procedure AddToArr;
   begin
        Inc(iNumItems);
        if (iNumItems > IntArr.lMaxSize) then
           IntArr.resize(IntArr.lMaxSize + ARR_STEP_SIZE);
        IntArr.setValue(iNumItems,@rValue);
   end;

begin
     IntArr := Array_t.Create;
     IntArr.init(SizeOf(LocalSortType),ARR_STEP_SIZE);
     iNumItems := 0;
     Result := False;

     for iCount := 0 to (SourceBox.Items.Count-1) do
     begin
          try
             rValue := StrToInt(SourceBox.Items[iCount]);
          except on exception do
                 begin
                      rValue := 0;
                 end;
          end;

         AddToArr;
     end;

     if (iNumItems = 0) then
     begin
          IntArr.Destroy;
     end
     else
     begin
          Result := True;

          if (iNumItems <> IntArr.lMaxSize) then
             IntArr.resize(iNumItems);
     end;
end;

function RegionSafeStrToFloat(const sCell : string) : extended;
var
   iPos : integer;
begin
     // safely reads a float with a . as DecimalSeperator when the DecimalSeperator
     // is other that .
     try
        Result := StrToFloat(sCell);

     except
           // StrToFloat has failed, so substitute DecimalSeperator for . in sCell and try again
           iPos := Pos('.',sCell);
           if (iPos > 1) then
              Result := StrToFloat(Copy(sCell,1,iPos-1) + DecimalSeparator + Copy(sCell,iPos+1,Length(sCell)-iPos));
     end;
end;

function ListBox2FloatArr(SourceBox : TListBox; var FloatArr : Array_T) : boolean;
type
    LocalSortType = extended;

var
   iNumItems, iCount : integer;
   rValue : LocalSortType;

   procedure AddToArr;
   begin
        Inc(iNumItems);
        if (iNumItems > FloatArr.lMaxSize) then
           FloatArr.resize(FloatArr.lMaxSize + ARR_STEP_SIZE);
        FloatArr.setValue(iNumItems,@rValue);
   end;

begin
     FloatArr := Array_t.Create;
     FloatArr.init(SizeOf(LocalSortType),ARR_STEP_SIZE);
     iNumItems := 0;
     Result := False;

     for iCount := 0 to (SourceBox.Items.Count-1) do
     begin
          try
             rValue := RegionSafeStrToFloat(SourceBox.Items.Strings[iCount]);
          except on exception do
                 begin
                      rValue := 0;
                 end;
          end;

         AddToArr;
     end;

     if (iNumItems = 0) then
     begin
          FloatArr.Destroy;
     end
     else
     begin
          Result := True;

          if (iNumItems <> FloatArr.lMaxSize) then
             FloatArr.resize(iNumItems);
     end;
end;

function IntArr2ListBox(SourceBox : TListBox; IntArr : Array_T) : boolean;
var
   lCount : longint;
   iValue, iLast : integer;
begin
     Result := False;
     iLast := -1111;

     if (IntArr.lMaxSize > 0) then
     begin
          Result := True;
          SourceBox.Clear;

          for lCount := 1 to IntArr.lMaxSize do
          begin
               IntArr.rtnValue(lCount,@iValue);

               if (iValue <> iLast) then
                  SourceBox.Items.Add(IntToStr(iValue));

               iLast := iValue;
          end;
     end;
end;

function FloatArr2ListBox(SourceBox : TListBox; FloatArr : Array_T) : boolean;
var
   lCount : longint;
   rValue, rLast : extended;
   sValue : string;
begin
     Result := False;
     rLast := -11.11;

     if (FloatArr.lMaxSize > 0) then
     begin
          Result := True;
          SourceBox.Clear;

          for lCount := 1 to FloatArr.lMaxSize do
          begin
               FloatArr.rtnValue(lCount,@rValue);

               sValue := FloatToStr(rValue);

               if (Pos('E',sValue) > 0) then
               begin
                    sValue := FloatToStrF(rValue,ffFixed,10,8);
               end;

               //if (Pos('E',sValue)>4) then
               //   sValue := Copy(sValue,1,3) + Copy(sValue,Pos('E',sValue),Length(sValue)-Pos('E',sValue)+1);

               if (rValue <> rLast) then
                  SourceBox.Items.Add(sValue);

               rLast := rValue;
          end;
     end;
end;


{---------------------------------------------------------------------------}


function SortIntArray(const unsortedArray_C : array_t) : array_t;
type
      datatype = integer;

var
   SortedList : IntList_O;
   value : datatype;
   test : datatype;
   flag : boolean;
   x : longint;

   iInt : integer;

begin
     Result := Array_T.create;
     SortedList := IntList_O.create;

     Result.init(sizeof(datatype),unsortedarray_c.lMaxSize);
     SortedList.init;

     {Build the sorted list}

     unSortedArray_c.rtnValue(1,@iInt);
     value := iInt;
     SortedList.addNode(value);
     for x := 2 to unSortedArray_c.lMaxSize do
     begin
          flag := FALSE;
          unSortedArray_c.rtnValue(x,@iInt);
          value := iInt;
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

function SortFloatArray(const unsortedArray_C : array_t) : array_t;
type
      datatype = extended;

var
   SortedList : RealList_O;
   value : datatype;
   test : datatype;
   flag : boolean;
   x : longint;

   iInt : integer;

begin
     Result := Array_T.create;
     SortedList := RealList_O.create;

     Result.init(sizeof(datatype),unsortedarray_c.lMaxSize);
     SortedList.init;

     {Build the sorted list}

     unSortedArray_c.rtnValue(1,@iInt);
     value := iInt;
     SortedList.addNode(value);
     for x := 2 to unSortedArray_c.lMaxSize do
     begin
          flag := FALSE;
          unSortedArray_c.rtnValue(x,@iInt);
          value := iInt;
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

     SortedList.Destroy;
end;

end.
