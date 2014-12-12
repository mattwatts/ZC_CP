    Array_t = class(ContigMemory)
    public
          lDataTypeSize : longint;
          lMaxSize : longint;
          Resizing : boolean;
          fastResize : boolean;
          ptrDataStart : pointer;

    private
           FofData : file;
           szData : string;
           CurrentBase : longint;
///           BaseRefs : ^Array_MAX_;
           fPaged : boolean;

           RangeList : RangedList; //LinkedList of RangeNode
           RangeNode : RangedNode; //RangedNode
           fBaseLine : boolean; // to see if we need to reset the linked list of ranges
           fNoPaging : boolean;
           Page_Size : longint;
           {Counters}
           (*
           cntFree,
           cntInit,
           cntResize,
           cntSetValue,
           cntRtnValue,
           cntRtnPtr,
           cntSort : longint;
           *)


    public
          constructor create;
          constructor create2(SizeOfDataType, InitialNum : longint);
          destructor Destroy; override;
          procedure free;
          procedure inhdestroy;

          procedure init(SizeOfDataType, InitialNum : longint);
          procedure clr;

          procedure resize(lNewSize : longint);
          procedure setresize(state : boolean);

          procedure setValue(const lElementNum : longint; ptrData : pointer);
          procedure rtnValue(const lElementNum : longint; ptrData : pointer);
          function rtnPtr(const lElementNum : longint) : pointer;

          procedure quicksortwrt(var DataPosition : integer; var sorttype : sortCast; iLo,iHi : longint);
          procedure BubbleSortwrt(DataPosition : integer; sorttype : sortCast);
          procedure SelectionSortwrt(DataPosition : integer; sorttype : sortcast);
          function sortwrt(DataPosition : integer; sorttype : sortCast) : array_t;

          procedure setto(ptrData : pointer);

          procedure setfilename(sz : string);

          procedure testing; override;
{          procedure WEBTEST(testlength : integer);}
          procedure sort(DataPosition : integer; sorttype : sortCast);

          procedure writetotextfile(szFile : string);
          procedure typedwriteln(datatype : string; const szFile : string);

          procedure dontpage;
          procedure dopage;

          function recite(sz : string) : tStringStream;

    protected

    private
           procedure baseline;
           procedure Array_tToMemStream(var MemStr : tMemoryStream);
           procedure MemStreamToArray_t(var MemStr : tMemoryStream);
           function LocateMem(lRef : longint) : pointer;
           procedure SaveData;
           procedure LoadData;
           procedure LocatePage(ref : longint);
           function fileof(page:integer) : string;
           procedure fileofp(page:integer; var res : string);
           procedure pagein(lRef : longint);
           procedure promote(lRef : longint);
    {DEBUG}
           function wrapCreate : integer;
           function wrapCreate2 : integer;
           function wrapDestroy : integer;
           function WrapFree : integer;
           function WrapInit : integer;
           function WrapResize : integer;
           function WrapSetValue : integer;
           function WrapRtnValue : integer;
           function WrapRtnPtr : integer;
           function WrapSortwrt : integer;
    end;

