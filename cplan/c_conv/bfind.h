//---------------------------------------------------------------------------
#ifndef bfindH
#define bfindH
//---------------------------------------------------------------------------

struct SearchInteger_T
{
	int iOriginalPosition;
    int iValue;
};

struct SearchString_T
{
	int iOriginalPosition;
    SmallString<255> sValue;
};

void __fastcall SortIntegerArray(int iArraySize,
                                 int *OrigArray[],
                                 SearchInteger_T   *SearchArray[]);

void __fastcall SortStringArray(int iArraySize,
                                SmallString<255> *OrigArray[],
                                SearchString_T   *SearchArray[]);

void __fastcall FindIntegerMatch(int iValueToMatch,
                                 int iArraySize,
                                 SearchInteger_T *SearchArray[]);

void __fastcall FindStringMatch(SmallString<255> sValueToMatch,
                                int iArraySize,
                                SearchInteger_T *SearchArray[]);

#endif
