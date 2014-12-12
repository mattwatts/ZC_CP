//--------------------=-----------------------------------------------------
#include <vcl\vcl.h>
#pragma hdrstop

#include "bfind.h"

/*

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


*/

void __fastcall SortIntegerArray(int iArraySize,
                                 int *OrigArray[],
                                 SearchInteger_T   *SearchArray[])
//IntegerList_O SortedList;
//int	iValue;
//bool fFlag;
{
	// create a binary lookup array for the list of integer identifiers
    // contained in OrigArray
}

void __fastcall SortStringArray(int iArraySize,
                                SmallString<255> *OrigArray[],
                                SearchString_T   *SearchArray[])
{
	// create a binary lookup array for the list of string identifiers
    // contained in OrigArray
}

void __fastcall FindIntegerMatch(int iValueToMatch,
                                 int iArraySize,
                                 SearchInteger_T *SearchArray[])
{
	// find index of element iValueToMatch using binary lookup
    // array SearchArray
}

void __fastcall FindStringMatch(SmallString<255> sValueToMatch,
                                int iArraySize,
                                SearchInteger_T *SearchArray[])
{
	// find index of element sValueToMatch using binary lookup
    // array SearchArray
}


//---------------------------------------------------------------------------
