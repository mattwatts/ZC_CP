unit ds;
{$undef _develop_}
{$undef view}

{$undef memhold}
{$undef ptrrtntest}

{$undef tracer}
interface

uses
    DataStru,sysutils, filectrl, forms, WinProcs {hmemcpy - can be replaced with move},dialogs,classes;

const
     _MAX_ = 1000; {Maximum size for ref array}
     StdSize_C = 100000; {A std. size constant}

type
    SortCast = (scInt,scLong,scReal,scString);
    Array_MAX_ = array[1.._MAX_] of longint;

    Array_t = class(DataStructurePtr_O)
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
           BaseRefs : ^Array_MAX_;
           fPaged : boolean;
           fModified : boolean;

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


    protected


    private
           procedure Array_tToMemStream(var MemStr : tMemoryStream);
           procedure MemStreamToArray_t(var MemStr : tMemoryStream);
           function LocateMem(lRef : longint) : pointer;
           procedure SaveData;
           procedure LoadData;
           procedure LocatePage(ref : longint);
           function fileof(page:integer) : string;

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

    function copyofarr(arr : array_t) : array_t;
    procedure WEBTEST(testlength : longint);

    procedure LoadArrayWithText(var ar : array_t; LineMask : array of string; filename : string);
var
   _testarr_ : array_t;
   basedir : string;
   baselocation : string;


procedure setpagingarray(dir : string);

implementation
uses
    arraydb,os_lims{$ifdef tracer},datamat{$endif};

const
     MAXTESTRESIZE = 100000;
     BIGSIZE = 1048576{1000000 = 0.95  ,  1 meg = 1048576};
     SegmentSize_C = 65536;
     _PAGE_SIZE_ : longint = BIGSIZE*500;     {ie. paging size is =1.9M}

var
f : file;
l : longint;
p : pointer;
   sz : string;
   lOldSize : longint;
   ArrayRef : longint;
   files : tfilelistbox;
   x : longint;


   szlastWeb : string;

   ARRDBCounter : longint;
   debugbuffer : array[1..1000] of byte;

   start,finish : longint;
   startin,finishin : longint;

     Value : pointer;
     ptrtestValue : pointer;
     ptrLo, ptrHi, ptrcopy : pointer;

procedure LoadArrayWithText(var ar : array_t; LineMask : array of string; filename : string);
var
   x,y : longint;
   size : integer;
   f : text;
   ptrCollect : pointer;
   ptrPos : pointer;
   bIn : byte;
   wIn : word;
   iIn : Integer;
   lIn : longint;
   lnCount : longint;

begin
     size := 0;
     for x := 0 to High(LineMask) do
     begin
          if LineMask[x] = 'byte' then inc(size,sizeof(byte))
          else
              if LineMask[x] = 'word' then inc(size,sizeof(word))
              else
                  if LineMask[x] = 'integer' then inc(size,sizeof(integer))
                  else
                      if LineMask[x] = 'longint' then inc(size,sizeof(longint));

     end;

     if size <> ar.lDataTypeSize then
     begin
          messagedlg('trying to load from text file with incorrectly sized array',mterror,[mbok],0);
          halt;
     end;

     new(ptrCollect);
     getmem(ptrCollect,size);
     new(ptrPos);
     ptrPos := ptrCollect;

     assignfile(f,filename);
     reset(f);
     lnCount := 0;

     while not(eof(f)) do
     begin
          inc(lnCount);
          for x := 0 to High(LineMask) do
          begin
               if LineMask[x] = 'byte' then
               begin
                    read(f,bIn);
                    move(bIn,ptrPos^,sizeof(byte));
{$ifdef ver80}
                    ptrPos := ptr(seg(ptrpos^),word(ofs(ptrpos^) + sizeof(byte)));
{$else}
                    ptrPos := pointer(integer(integer(ptrpos^) + sizeof(byte)));
{$endif}
               end
               else
                   if LineMask[x] = 'word' then
                   begin
                        read(f,wIn);
                        move(wIn,ptrPos^,sizeof(word));
{$ifdef ver80}
                        ptrPos := ptr(seg(ptrpos^),word(ofs(ptrpos^) + sizeof(word)));
{$else}
                        ptrPos := pointer(integer(integer(ptrpos^) + sizeof(word)));
{$endif}
                    end
                   else
                       if LineMask[x] = 'integer' then
                       begin
                            read(f,iIn);
                            move(iIn,ptrPos^,sizeof(integer));
{$ifdef ver80}
                            ptrPos := ptr(seg(ptrpos^),word(ofs(ptrpos^) + sizeof(integer)));
{$else}
                            ptrPos := pointer(integer(integer(ptrpos^) + sizeof(integer)));
{$endif}
                       end
                       else
                           if LineMask[x] = 'longint' then
                           begin
                                read(f,lIn);
                                move(lIn,ptrPos^,sizeof(longint));
{$ifdef ver80}
                                ptrPos := ptr(seg(ptrpos^),word(ofs(ptrpos^) + sizeof(longint)));
{$else}
                                ptrPos := pointer(integer(ptrpos) + sizeof(longint));
{$endif}
                           end;

          end;

          ar.setValue(lnCount,ptrCollect);
          ptrPos := ptrCollect;
          readln(f);
     end;

     closefile(f);


{     dispose(ptrPos);
     freemem(ptrCollect,size);
     dispose(ptrCollect);}
end;

procedure setpagingarray(dir : string);
begin
     basedir := dir;

end;

procedure Array_t.typedwriteln(datatype : string; const szFile : string);
var
   x : longint;
   outFile : text;
   wword : word;
   llong : longint;
begin
     assignfile(outFile,szFile);
     append(outFile);
     if uppercase(datatype) = 'WORD' then
     begin
          for x := 1 to lMaxSize do
          begin
               rtnValue(x,@wword);
               write(outFile,inttostr(wword)+'   ');
          end;
     end
     else
         if uppercase(datatype) = 'LONG' then
         begin
              for x := 1 to lMaxSize do
              begin
                   rtnValue(x,@llong);
                   write(outFile,inttostr(llong)+'   ');
              end;
         end;

     writeln(outFile);
end;

procedure Array_t.writetotextfile(szFile : string);
var
   logfile : text;
   llong : longint;
   x : longint;
begin
     assignfile(logfile,szFile);
     rewrite(logfile);
     for x := 1 to lMaxSize do
     begin
          rtnValue(x,@llong);
          writeln(logfile,llong);
     end;
     closefile(logfile);
end;

function Array_t.fileof(page:integer) : string;
begin
     Result := baselocation + inttostr(instanceRef) + '.' + inttostr(page);
end;
procedure Array_t.setfilename(sz : string);
begin
     szData := sz;
end;

procedure Array_t.Array_tToMemStream(var MemStr : tMemoryStream);
var
   x : longint;
   l,ll : longint;
   p : pointer;
   start,finish : longint;

begin
     start := baserefs^[currentbase] + 1;
     finish := baserefs^[currentbase+1];
     if finish = -1 then finish := lOldSize;
     if finish < start then finish := lMaxSize;

     for x := start to finish do
     begin
try
          rtnValue(x,@l);
          MemStr.write(l,lDataTypeSize);
{          MemStr.seek(-ldataTypeSize,1);
          MemStr.read(ll,lDataTypeSize);
          if l <> l then
          begin
          l := -1;
          end;
}
except
begin
     l := -1;
end;
end;
     end;
end;

procedure Array_t.MemStreamToArray_t(var MemStr : tMemoryStream);
var
   p : pointer;
   count : longint;
   l : longint;
   ll : longint;
begin
     count := BaseRefs^[CurrentBase];
{     MemStr.seek(0,0);}
     getmem(p,lDataTypeSize);
     l := MemStr.read(ll,lDataTypeSize);
     if l = lDataTypeSize then
     repeat
          inc(count);
{          ll := longint(p^);}
          setValue(count,@ll);
          l := MemStr.read(ll,lDataTypeSize);
     until l <> lDataTypeSize;
     freemem(p,lDataTypeSize);
     {lMaxSize := count;}
end;


procedure Array_t.SaveData;
var
   sz : string;
   amount : longint;
   x : longint;
   p : pointer;
   ArraySaveFile : file;
   towrite,written : word;
   pos : longint;
   memstr : tMemoryStream;
   start,finish,currentpos : longint;
   fhandle : integer;

begin
{assignfile(f,'d:\temp\arrp22.1');
reset(f,4);
blockread(f,l,1);
closefile(f);}
     if fModified then
     begin
          if BaseRefs^[CurrentBase+1] = -1 then
             amount := lOldSize
          else
             amount := BaseRefs^[CurrentBase+1];

          amount := amount - BaseRefs^[CurrentBase];
          sz := fileof(CurrentBase);

          start := baserefs^[currentbase] + 1;
          finish := baserefs^[currentbase+1];
          if finish = -1 then finish := lOldSize;
          if finish < start then finish := lMaxSize;
          currentpos := start;

          assignfile(ArraySaveFile,sz);
          rewrite(ArraySaveFile,lDataTypeSize);
          while currentpos <= finish do
          begin
               p := rtnptr(currentpos);
               if ((currentpos + ContigData.lDataUnitsPerSegment) <= finish) then
               begin
                    blockwrite(ArraySaveFile,p^,ContigData.lDataUnitsPerSegment);
                    currentpos := currentpos + ContigData.lDataUnitsPerSegment;
               end
               else
               begin
                    blockwrite(ArraySaveFile,p^,finish - CurrentPos + 1);
                    break;
               end;
          end;
          closefile(ArraySaveFile);
{          for x := start to finish do
          memstr := tMemoryStream.create;
          array_tToMemStream(memstr);
          memstr.savetofile(sz);
          memstr.free;}

{          memstrm.loadfromfile(sz);}

          fModified := FALSE;
     end;
end;

procedure Array_t.LoadData;
var
   sz : string;
   x : longint;
   pos : longint;
   p : pointer;
   toread : word;
   amount : longint;
   start,finish,currentpos : longint;
   ArraySaveFile : file;

   memstrm : tMemoryStream;

begin
     sz := fileof(currentbase);

     start := baserefs^[currentbase] + 1;
     finish := baserefs^[currentbase+1];
     if finish = -1 then finish := lOldSize;
     if finish < start then finish := lMaxSize;
     currentpos := start;

     assignfile(ArraySaveFile,sz);
     reset(ArraySaveFile,lDataTypeSize);
     while currentpos <= finish do
     begin
          p := rtnptr(currentpos);
          if ((currentpos + ContigData.lDataUnitsPerSegment) <= finish) then
          begin
               blockread(ArraySaveFile,p^,ContigData.lDataUnitsPerSegment);
               currentpos := currentpos + ContigData.lDataUnitsPerSegment;
          end
          else
          begin
               blockread(ArraySaveFile,p^,finish - CurrentPos + 1);
               break;
          end;
     end;
     closefile(ArraySaveFile);

{     assignfile(FofData,sz);
     reset(FofData,lDataTypeSize);
     ReallocContMemPtr(ptrDataStart,filesize(fOfData),lDataTypeSize,ContigData);
     closefile(fofdata);
}
{     memstrm := tMemoryStream.create;
     memstrm.loadfromfile(sz);
     MemStreamToArray_t(memstrm);
     memstrm.free;}
{     assignfile(FofData,sz);
     reset(FofData,lDataTypeSize);

          pos := 1;
          amount := filesize(fofdata);
          for x := 1 to (amount div ContigData.lDataUnitspersegment) do
          begin
               p := rtnptr(pos);
               blockread(fofdata,p,ContigData.lDataUnitsPerSegment);
               inc(pos,ContigData.lDataUnitsPerSegment);
          end;
          p := rtnptr(pos);
          blockread(fofdata,p,word(amount-pos+1));
}

{     blockread(FofData,ptrDataStart,(filesize(FofData) div lDataTypeSize));}

{     for x := 1 to filesize(fofdata) do
     begin
          p := rtnptr(BaseRefs[CurrentBase]+x);
          blockread(fofData,p,1);
     end;
}
     fModified := FALSE;
end;

procedure Array_t.LocatePage(ref : longint);
var
   cb : integer;
   fin : boolean;

begin
     cb := 1;

     while BaseRefs^[cb] <> -1 do
     begin
          if ((BaseRefs^[cb] < ref) and (BaseRefs^[cb+1] >= ref)) then break;
          inc(cb);
     end;
     if BaseRefs^[cb] = -1 then
     begin
          dec(cb);
     end;
{     if (BaseRefs^[cb] < ref) then
     begin
          fin := FALSE;
          repeat
                inc(cb);
                if (BaseRefs^[cb] = -1) then
                begin
                     if BaseRefs^[cb-1] <= ref then
                        dec(cb);
                     fin := TRUE;
                end
                else
                begin
                     if (BaseRefs^[cb] >= ref) then
                     begin
                          dec(cb);
                          fin := TRUE;
                     end;
                end;
          until fin;
     end;
}
     currentbase := cb;
end;

constructor Array_t.create2(SizeOfDataType, InitialNum : longint);
begin
     create;

     init(SizeOfDataType, InitialNum);
end;

constructor Array_t.create;
var
   test : boolean;
begin
{     if self <> nil then destroy;}
     inherited create;
     new(ptrDataStart);

     lDataTypeSize := 0;
     lMaxSize := 0;
     Resizing := FALSE;

     ContigData.lDataUnitsPerSegment := 0;
     ContigData.fit := FALSE;

     CurrentBase := 1;
     fPaged := FALSE;
     fModified := TRUE;
     szData := baselocation;
     new(baserefs);

     (*
     cntFree := 0;
     cntInit := 0;
     cntResize := 0;
     cntSetValue := 0;
     cntRtnValue := 0;
     cntRtnPtr := 0;
     cntSort := 0;
     *)
end;

procedure Array_t.free;

var
   tmp : pchar;
   x : integer;

begin
{inc(cntFree);}
     if self <> nil then
     begin
          if lMaxSize <> 0 then
          begin
{$ifdef ver80}
               FreeContMemPtr(ptrDataStart);
               ptrDataStart := nil;
               DisposeContMemPtr(ptrDataStart);
{$else}
               dispose(ptrDataStart);
{$endif}
          end;

          if BaseRefs <> nil then
          begin
               for x := 1 to _MAX_ do
               begin
                    sz := fileof(x);
{$ifdef ver80}
                    if fileexists(sz) then
                       deletefile(sz)
                    else
                        break;
{$else}
                    tmp := stralloc(length(sz)+1);
                    strpCopy(tmp,sz);
               if not(deletefile(tmp)) then
               begin
                    strdispose(tmp);
                    break;
               end
               else
                   strdispose(tmp);
{$endif}
               end;
{              freemem(BaseRefs,_MAX_*sizeof(longint));}
              dispose(BaseRefs);
              BaseRefs := Nil;
          end;
     lMaxSize := 0;
     end;
end;

procedure Array_t.inhdestroy;
begin
     inherited destroy;
end;

destructor Array_t.Destroy;
var
   tmp : pChar;
   x : longint;
   m :longint;

begin
     if lMaxSize <> 0 then
     begin
          FreeContMemPtr(ptrDataStart);
{$ifdef ver80}
          ptrDataStart := nil;
          DisposeContMemPtr(ptrDataStart);
{$endif}
     end;

     if BaseRefs <> nil then
     begin
          for x := 1 to _MAX_ do
          begin
               sz := fileof(x);
{$ifdef ver80}
               if fileexists(sz) then
                   deletefile(sz)
               else
                   break;
{$else}
               tmp := stralloc(length(sz)+1);
               strpCopy(tmp,sz);
               if not(deletefile(tmp)) then
               begin
                    strdispose(tmp);
                    break;
               end
               else
                   strdispose(tmp);
{$endif}
          end;
     end;


     dispose(BaseRefs);
  inherited destroy;
end;

procedure Array_t.init(SizeOfDataType, InitialNum : longint);

var
   x,y,z : longint;
   test : boolean;

begin
{inc(cntInit);}
     if (lMaxSize <> 0) then
     self.free;

     lDataTypeSize := SizeOfDataType;
     lMaxSize := InitialNum;

     ContigData.lDataUnitsPerSegment := SegmentSize_C div SizeOfDataType;
     
     if ((lMaxSize*lDataTypeSize) <= _PAGE_SIZE_) then
        fpaged := false
     else
     begin
{$ifdef ver80}
          if ((SEGMENTSIZE_C mod SizeOfDataType) = 0) then
             ContigData.Fit := TRUE
          else
              ContigData.Fit := FALSE;
          AllocContMemPtr(ptrDataStart,1,SizeOfDataType,ContigData);
{$else}
          getmem(ptrDataStart,1*lDataTypeSize);
{$endif}
          lMaxSize := 0;
          for x := 2 to (InitialNum div (_PAGE_SIZE_ div SizeofDataType)) do
          begin
               fModified := true;
               resize(lMaxSize+(_PAGE_SIZE_ div SizeofDataType));
          end;
          fModified := true;
          resize(InitialNum);

          exit;
     end;

{$ifdef ver80}
          if ((SEGMENTSIZE_C mod SizeOfDataType) = 0) then
             ContigData.Fit := TRUE
          else
              ContigData.Fit := FALSE;

{          if ptrDataStart <> nil then
            FreeContMemPtr(ptrDataStart); }
          AllocContMemPtr(ptrDataStart,InitialNum,SizeOfDataType,ContigData);
{$else}
{          if lMaxSize <> 0 then FreeContMemPtr(ptrDataStart);}
{          if ptrDataStart <> nil then
            FreeMem(ptrDataStart);    }
          getmem(ptrDataStart,lMaxSize*lDataTypeSize);
{$endif}
     resizing := FALSE;
     fModified := TRUE;
end;

procedure Array_t.clr;
begin
     if ptrDataStart <> nil then
     begin
          FreeContMemPtr(ptrDataStart);
     end;

     ptrDataStart := nil;
     fModified := TRUE;
end;

procedure Array_T.setValue(const lElementNum : longint; ptrData : pointer);

var
   pNewPtr : pointer;
   iPosition : integer;
   tmpA : array_t;
   tmpB : array_t;
   x : longint;
   lPtr : longint;

begin
{inc(cntSetValue);}
      if (lElementNum < 1) or (lElementNum > lMaxSize) then
      begin
          if not(resizing) then
          begin
               MessageDlg('Error setValue trying to access beyond scope, index ' + IntToStr(lElementNum)
                     + ' - Halting',
                     mtError,[mbOK],0);
               halt;
          end
          else
          begin
               if lMaxSize < _Page_Size_ then
                resize(_PAGE_SIZE_)
               else
               begin
                    if ((lMaxSize mod _Page_Size_) = 0) then
                    begin
                         resize(lMaxSize + _page_size_)
                    end
                    else
                    begin
                         resize(((lMaxSize div _page_size_)+1)*_page_size_);
                    end;
               end;
          end;
     end;
try
      fModified := TRUE;
{$ifdef ver80}
      new(pNewptr);
{$else}
      new(pNewptr);
{       getmem(pNewPtr,lDataTypeSize);}
{$endif}
      pNewPtr := LocateMem(lElementNum);
{$ifdef ver80}
      move(ptrData^,pNewPtr^,lDataTypeSize);
{$else}
      move(ptrData^,pNewPtr^,lDataTypeSize);
{$endif}
{$ifdef ver80}
      dispose(pNewptr);
{$else}
       pNewPtr := NIL;
       dispose(pNewPtr);
{$endif}
except on exception do
begin
{$ifdef ver80}
     x := globalsize(selectorof(ptrdatastart));
{$endif}
     halt;
end;
end;
end;

procedure Array_T.rtnValue(const lElementNum : longint; ptrData : pointer);

var
   pNewPtr : pointer;
   iPosition : integer;

begin
{inc(cntRtnValue);}
     if (lElementNum < 1) or (lElementNum > lMaxSize) then
     begin
          MessageDlg('Error rtnValue trying to access beyond scope, index ' + IntToStr(lElementNum)
                     + ' - Halting',
                     mtError,[mbOK],0);
              halt;
     end;

{$ifdef ver80}
        new(pNewptr);
{$else}
        new(pNewptr);
{      getmem(pNewptr,lDataTypeSize);}
{$endif}

      pNewPtr := LocateMem(lElementNum);
{$ifdef ver80}
      move(pNewPtr^,ptrData^,lDataTypeSize);
{$else}
      move(pNewPtr^,ptrData^,lDataTypeSize);
{$endif}

{$ifdef ver80}
      pNewptr := nil;
        dispose(pNewptr);
{$else}
      pNewptr := nil;
        dispose(pNewptr);
{       pNewptr := nil;
      freemem(pNewptr);}
{$endif}

end;

function Array_t.rtnPtr(const lElementNum : longint) : pointer;
begin
{inc(cntRtnPtr);}
     if (lElementNum < 1) or (lElementNum > lMaxSize) then
     begin
          MessageDlg('Error rtnPtr trying to access beyond scope, index ' + IntToStr(lElementNum)
                     + ' - Halting',
                     mtError,[mbOK],0);
              halt;
     end;
     Result := LocateMem(lElementNum);
     fModified := TRUE;
end;

procedure Array_t.testing;
begin
     initArraytest;
end;

procedure Array_T.resize(lNewSize : longint);
var
   oldcb : longint;
   f : file;
   sz : string;
   fsize : longint;
begin
{inc(cntResize);}
     lOldSize := lMaxSize;
     lMaxSize := lNewSize;
     if lNewSize <= 0 then
     begin
     exit; lNewSize := 1;
     end;


     if ((lNewSize * lDataTypeSize) <= _PAGE_SIZE_) then
        fpaged := false
     else
     begin
          fpaged := true;
     end;

     if BaseRefs = nil then
     begin
          getmem(BaseRefs,_MAX_*sizeof(longint));
          BaseRefs^[1] := 0;
          BaseRefs^[2] := -1;
          fModified := FALSE;
          if fpaged then savedata;
     end;

     if not(fPaged) then
     begin
          ReallocContMemPtr(ptrDataStart,lNewSize,lDataTypeSize,ContigData);
     end
     else
     begin
          if BaseRefs^[currentBase+1] = -1 then
          begin
               BaseRefs^[CurrentBase+1] := lOldSize;
               BaseRefs^[CurrentBase+2] := -1;
               savedata;
          end;
          oldcb := currentbase;
          locatepage(lNewSize);
          if oldcb <> currentbase then
          begin
               savedata;
               FreeContMemPtr(ptrDataStart);
               if fileexists(fileof(currentbase)) then
               begin
                    assignfile(f,fileof(currentbase));
                    reset(f,lDataTypeSize);
                    fsize := filesize(f);
                    closefile(f);
                    AllocContMemPtr(ptrDataStart,fsize,lDataTypeSize,ContigData);
                    LoadData;
               end
               else
                   AllocContMemPtr(ptrDataStart,1,lDataTypeSize,ContigData);
          end;

          ReallocContMemPtr(ptrDataStart,lMaxSize-BaseRefs^[CurrentBase],lDataTypeSize,ContigData);
          BaseRefs^[CurrentBase+1] := -1;
     end;
end;

procedure Array_t.setresize(state : boolean);
begin
     resizing := state;
     fastResize := false;
end;
procedure Array_t.sort(DataPosition : integer; sorttype : sortCast);
begin
{inc(cntSort);}
     try
        quicksortwrt(DataPosition,sorttype,1,lMaxSize);
     except on exception do
     begin
          SelectionSortwrt(DataPosition,sorttype);
     end;
     end
end;

procedure Array_t.quicksortwrt(var DataPosition : integer; var sorttype : sortCast; iLo,iHi : longint);
var
     Lo,Hi : longint;
     ptrTestValue : pointer;
     Value : pointer;
     ptrLo : pointer;
     ptrHi : pointer;
     lTest,lValue,longlo,longhi : longint;

begin
try
       Lo := iLo;
       Hi := iHi;


       new(Value);
       new(ptrtestValue);
       new(ptrLo);
       new(ptrHi);

       Value := rtnPtr(Hi{(Lo+Hi) div 2});
{$ifdef ver80}
       ptrtestValue := ptr(seg(value^),word(ofs(value^))+dataPosition);
{$else}
       ptrtestValue := pointer(integer(value)+dataPosition);
{$endif}
       repeat
             ptrLo := rtnPtr(Lo);
             ptrHi := rtnPtr(Hi);
{$ifdef ver80}
             ptrLo := ptr(seg(ptrLo^),word(ofs(ptrLo^)+dataPosition));
             ptrHi := ptr(seg(ptrHi^),word(ofs(ptrHi^)+dataPosition));
{$else}
             ptrLo := pointer(integer(ptrLo)+dataPosition);
             ptrHi := pointer(integer(ptrHi)+dataPosition);
{$endif}

             case sorttype of
               scInt :    begin
                               while integer(PtrLo^) < integer(ptrtestValue^) do
                               begin
                                    Inc(Lo);
                                    ptrLo := rtnPtr(Lo);
{$ifdef ver80}
                                    ptrLo := ptr(seg(ptrLo^),word(ofs(ptrLo^)+dataPosition));
{$else}
                                    ptrLo := pointer(integer(pointer(ptrLo))+dataPosition);
{$endif}

                               end;
                          end;
               scLong :   begin
                               while longint(PtrLo^) < longint(ptrtestValue^) do
                               begin
                                    Inc(Lo);
                                    ptrLo := rtnPtr(Lo);
{$ifdef ver80}
                                    ptrLo := ptr(seg(ptrLo^),word(ofs(ptrLo^)+dataPosition));
{$else}
                                    ptrLo := pointer(integer(pointer(ptrLo))+dataPosition);
{$endif}
                               end;

                          end;
               scReal :   begin
                               while real(PtrLo^) < real(ptrtestValue^) do
                               begin
                                    Inc(Lo);
                                    ptrLo := rtnPtr(Lo);
{$ifdef ver80}
                                    ptrLo := ptr(seg(ptrLo^),word(ofs(ptrLo^)+dataPosition));
{$else}
                                    ptrLo := pointer(integer(pointer(ptrLo))+dataPosition);
{$endif}
                               end;
                          end;
               scString : begin
                               while string(PtrLo^) < string(ptrtestValue^) do
                               begin
                                    Inc(Lo);
                                    ptrLo := rtnPtr(Lo);
{$ifdef ver80}
                                    ptrLo := ptr(seg(ptrLo^),word(ofs(ptrLo^)+dataPosition));
{$else}
                                    ptrLo := pointer(integer(pointer(ptrLo))+dataPosition);
{$endif}
                               end;
                          end;
               else       begin
                               halt;
                          end;
             end;
             case sorttype of
               scInt :    begin
                               while integer(PtrHi^) > integer(ptrtestValue^) do
                               begin
                                    Dec(Hi);
                                    ptrHI := rtnPtr(Hi);
{$ifdef ver80}
                                    ptrHi := ptr(seg(ptrHi^),word(ofs(ptrHi^)+dataPosition));
{$else}
                                    ptrHi := pointer(integer(pointer(ptrHi))+dataPosition);
{$endif}
                               end;
                          end;
               scLong :   begin
                               while longint(Ptrhi^) > longint(ptrtestValue^) do
                               begin
                                    Dec(Hi);
                                    ptrHI := rtnPtr(Hi);
{$ifdef ver80}
                                   ptrHi := ptr(seg(ptrHi^),word(ofs(ptrHi^)+dataPosition));
{$else}
                                    ptrHi := pointer(integer(pointer(ptrHi))+dataPosition);
{$endif}
                               end;
                          end;
               scReal :   begin
                               while real(Ptrhi^) > real(ptrtestValue^) do
                               begin
                                    Dec(Hi);
                                    ptrHI := rtnPtr(Hi);
{$ifdef ver80}
                                    ptrHi := ptr(seg(ptrHi^),word(ofs(ptrHi^)+dataPosition));
{$else}
                                    ptrHi := pointer(integer(pointer(ptrHi))+dataPosition);
{$endif}
                               end;
                          end;
               scString : begin
                               while string(Ptrhi^) > string(ptrtestValue^) do
                               begin
                                    Dec(Hi);
                                    ptrHI := rtnPtr(Hi);
{$ifdef ver80}
                                    ptrHi := ptr(seg(ptrHi^),word(ofs(ptrHi^)+dataPosition));
{$else}
                                    ptrHi := pointer(integer(pointer(ptrHi))+dataPosition);
{$endif}
                               end;
                          end;
               else       begin
                               halt;
                          end;
             end;
             if Lo < Hi then
             begin
                  getmem(ptrcopy,lDatatypeSize);
                  ptrLo := rtnPtr(Lo);

                  move(ptrLo^,ptrCopy^,lDataTypeSize);

                  ptrHi := rtnPtr(Hi);
                  setValue(Lo,PtrHi);
                  setValue(Hi,Ptrcopy);
                  freemem(ptrcopy,ldatatypesize);
                  inc(Lo);
                  dec(Hi);
             end
             else
             if Lo = Hi then
             begin
                  inc(Lo);
                  dec(Hi);
             end;

       until Lo > Hi;
       try
          if Hi > iLo then QuickSortwrt(DataPosition,sorttype,iLo,Hi);
          if Lo < iHi then QuickSortwrt(DataPosition,sorttype,Lo,iHi);
       except on exception do
       begin
            raise;
       end;
       end;

{$ifdef ver80}

{       dispose(Value);
       dispose(ptrtestValue);
       dispose(ptrLo);
       dispose(ptrHi);
}
{$endif}

except on exception do
   begin
{messagedlg('stack overflow error',mterror,[mbok],0);
{halt;
Lo := Lo -1;{          selectionsortwrt(DataPosition,sorttype);}
raise;
   end;
end;
end;

 procedure Array_t.SelectionSortwrt(DataPosition : integer; sorttype : sortCast);
var
  I, J, T: longint;

  ptr1,ptr2 : pointer;
  ptr3, ptr4 : pointer;

begin
{     new(ptr1);
     new(ptr2);
     new(ptr3);
     new(ptr4);
     getmem(ptr1,lDataTypeSize);
     getmem(ptr2,lDataTypeSize);

     case sorttype of
     scInt : begin
                  for I := 1 to lMaxSize - 1 do
                  begin
                      for J := lMaxSize downto I + 1 do
                      begin
                           ptr1 := rtnptr(i);
                           ptr2 := rtnPtr(j);
                           ptr3 := ptr(seg(ptr1^),word(ofs(ptr1^)+dataposition));
                           ptr4 := ptr(seg(ptr2^),word(ofs(ptr2^)+dataposition));
                           if integer(ptr3^) > integer(ptr4^) then
                           begin
                                setvalue(i,ptr2);
                                setvalue(j,ptr1);
                           end;
                      end;
                  end;
             end;
     scLong : begin
                  for I := 1 to lMaxSize - 1 do
                  begin
                      for J := lMaxSize downto I + 1 do
                      begin
                           ptr1 := rtnptr(i);
                           ptr2 := rtnPtr(j);
                           ptr3 := ptr(seg(ptr1^),word(ofs(ptr1^)+dataposition));
                           ptr4 := ptr(seg(ptr2^),word(ofs(ptr2^)+dataposition));
                           if longint(ptr3^) > longint(ptr4^) then
                           begin
                                setvalue(i,ptr2);
                                setvalue(j,ptr1);
                           end;
                      end;
                  end;
             end;
     scReal : begin
                  for I := 1 to lMaxSize - 1 do
                  begin
                      for J := lMaxSize downto I + 1 do
                      begin
                           ptr1 := rtnptr(i);
                           ptr2 := rtnPtr(j);
                           ptr3 := ptr(seg(ptr1^),word(ofs(ptr1^)+dataposition));
                           ptr4 := ptr(seg(ptr2^),word(ofs(ptr2^)+dataposition));
                           if real(ptr3^) > real(ptr4^) then
                           begin
                                setvalue(i,ptr2);
                                setvalue(j,ptr1);
                           end;
                      end;
                  end;
              end;
     scString : begin
                  for I := 1 to lMaxSize - 1 do
                  begin
                      for J := lMaxSize downto I + 1 do
                      begin
                           ptr1 := rtnptr(i);
                           ptr2 := rtnPtr(j);
                           ptr3 := ptr(seg(ptr1^),word(ofs(ptr1^)+dataposition));
                           ptr4 := ptr(seg(ptr2^),word(ofs(ptr2^)+dataposition));
                           if string(ptr3^) > string(ptr4^) then
                           begin
                                setvalue(i,ptr2);
                                setvalue(j,ptr1);
                           end;
                      end;
                  end;
               end;
     end;

dispose(ptr1);
dispose(ptr2);
dispose(ptr3);
dispose(ptr4);
}
end;

 procedure Array_t.BubbleSortwrt(DataPosition : integer; sorttype : sortCast);
var
  I, J, T: longint;

  ptr1,ptr2 : pointer;
  ptr3, ptr4 : pointer;

begin
{
     new(ptr1);
     new(ptr2);
     new(ptr3);
     new(ptr4);
     getmem(ptr1,lDataTypeSize);
     getmem(ptr2,lDataTypeSize);

     case sorttype of
     scInt : begin
                  for I := lMaxSize downto  1 do
                  begin
                      for J := 1 to lMaxSize - 1 do
                      begin
                           ptr1 := rtnptr(j+1);
                           ptr2 := rtnPtr(j);
                           ptr3 := ptr(seg(ptr1^),word(ofs(ptr1^)+dataposition));
                           ptr4 := ptr(seg(ptr2^),word(ofs(ptr2^)+dataposition));
                           if integer(ptr4^) > integer(ptr3^) then
                           begin
                                setvalue(j+1,ptr2);
                                setvalue(j,ptr1);
                           end;
                      end;
                  end;
             end;
     scLong : begin
                  for I := lMaxSize downto  1 do
                  begin
                      for J := 1 to lMaxSize - 1 do
                      begin
                           ptr1 := rtnptr(j+1);
                           ptr2 := rtnPtr(j);
                           ptr3 := ptr(seg(ptr1^),word(ofs(ptr1^)+dataposition));
                           ptr4 := ptr(seg(ptr2^),word(ofs(ptr2^)+dataposition));
                           if longint(ptr4^) > longint(ptr3^) then
                           begin
                                setvalue(j+1,ptr2);
                                setvalue(j,ptr1);
                           end;
                      end;
                  end;
             end;
     scReal : begin
                  for I := lMaxSize downto  1 do
                  begin
                      for J := 1 to lMaxSize - 1 do
                      begin
                           ptr1 := rtnptr(j+1);
                           ptr2 := rtnPtr(j);
                           ptr3 := ptr(seg(ptr1^),word(ofs(ptr1^)+dataposition));
                           ptr4 := ptr(seg(ptr2^),word(ofs(ptr2^)+dataposition));
                           if real(ptr4^) > real(ptr3^) then
                           begin
                                setvalue(j+1,ptr2);
                                setvalue(j,ptr1);
                           end;
                      end;
                  end;
              end;
     scString : begin
                  for I := lMaxSize downto  1 do
                  begin
                      for J := 1 to lMaxSize - 1 do
                      begin
                           ptr1 := rtnptr(j+1);
                           ptr2 := rtnPtr(j);
                           ptr3 := ptr(seg(ptr1^),word(ofs(ptr1^)+dataposition));
                           ptr4 := ptr(seg(ptr2^),word(ofs(ptr2^)+dataposition));
                           if string(ptr4^) > string(ptr3^) then
                           begin
                                setvalue(j+1,ptr2);
                                setvalue(j,ptr1);
                           end;
                      end;
                  end;
               end;
     end;

dispose(ptr1);
dispose(ptr2);
dispose(ptr3);
dispose(ptr4);
}
end;

function array_t.sortwrt(DataPosition : integer; sorttype : sortCast) : array_t;
begin
     try
        quicksortwrt(DataPosition,sorttype,1,lMaxSize);
     except on exception do
     begin
          SelectionSortwrt(DataPosition,sorttype);
     end;
     end;
{     result := array_t.create;
     Result := copyofarr(self);

try
     Result.quicksortwrt(DataPosition,sorttype,1,lMaxSize);
except on exception do
   begin
Result.SelectionSortwrt(DataPosition,sorttype);
   end;
end;
}
end;

function Array_T.LocateMem(lRef : longint) : pointer;
var
   oldcb : longint;
   tmpcb : longint;
   f : file;
   sz : string;

begin
     if not(fpaged) then
        result := LocateContMemPtr(ptrDataStart,lRef,lDataTypeSize,ContigData)
     else
     begin
          oldcb := currentbase;
          locatepage(lRef);
          if oldcb <> currentbase then
          begin
               tmpcb := currentbase;
               currentbase := oldcb;
               savedata;
               currentbase := tmpcb;
               freecontmemptr(ptrDataStart);
               sz := fileof(currentbase);
               assignfile(f,sz);
               reset(f,lDataTypeSize);
               AllocContMemPtr(ptrDataStart,filesize(f),lDataTypeSize,ContigData);
               closefile(f);
               loaddata;
          end;
          result := LocateContMemPtr(ptrDataStart,lRef-BaseRefs^[CurrentBase],lDataTypeSize,ContigData)
     end;

end;


procedure array_t.setto(ptrData : pointer);
var
   x : longint;
begin
     for x := 1 to lMaxSize do
         setValue(x,ptrData);
end;

function copyofarr(arr : array_t) : array_t;
begin
     result := array_t.create;
     result := arr;
end;


procedure WEBTEST(testlength : longint);
var
   start,finish,mid : longint;
   nexttest : longint;

   testObject : tObject;

   a2 : array_t;
begin
     randomize;

start := memavail;
_testarr_ := array_t.create2(4,100);
_testarr_.init(10,1000);
_testArr_.destroy;
finish := memavail;

start := memavail;
     _testarr_ := array_t.create2(4,100);

     nexttest := random(10)+4;

nexttest := 8;

     ARRDBCounter := 0;

     repeat
           case nexttest of
           1 : begin
                    nexttest := random(7)+4;
               end;
           2 : begin
                    nexttest := random(7) + 4;
               end;
           3 : begin
                    nexttest := random(7) + 4;
               end;
           4 : begin
{                    nexttest := random(7)+4;}
                    nexttest := _testarr_.WrapFree;
               end;
           5 : begin
{                    nexttest := random(7)+4;}
                    nexttest := _testarr_.WrapInit;
               end;
           6 : begin
{                    nexttest := random(7)+4;}
                    nexttest := _testarr_.WrapResize;
               end;
           7 : begin
{                    nexttest := random(7)+4;}
                    nexttest := _testarr_.WrapSetValue;
               end;
           8 : begin
{                    nexttest := random(7)+4;}
                    nexttest := _testarr_.WrapRtnValue;
               end;
           9 : begin
{                    nexttest := random(7)+4;}
                    nexttest := _testarr_.WrapRtnPtr;
               end;
           10 : begin
{                    nexttest := random(7)+4;}
                     nexttest := _testarr_.WrapSortwrt;
                end;
           else
               nexttest := random(7)+4;
           end;
{           Arraydebug.edit7.text := inttostr(ARRDBCounter);
           Arraydebug.edit7.update;
}

     until ARRDBCounter >= testlength;
     _testarr_.destroy;
finish := memavail;

Arraydebug.edit3.text := inttostr(Finish-Start);
Arraydebug.edit3.update;

{$ifdef memhold}
     if start <> finish then
         messagedlg('Error in memory',mterror,[mbok],0);
{$endif}
end;

{DEBUG WRAPPERS}
function array_t.wrapCreate : integer;
begin
try
startin := memavail;
{$ifdef view}
     arrayDebug.listbox1.items.add('create');
     arrayDebug.listbox1.items.move(arrayDebug.listbox1.items.count-1,0);
     arrayDebug.listbox1.update;
{$endif}
     _testarr_ := array_t.create;

     inc(ARRDBcounter);
     result := 5;
     szlastWeb := 'create';
finishin := memavail;
except on exception do
begin
     messagedlg('Error in Create',mterror,[mbok],0);
end;
end;
end;

function array_t.wrapCreate2 : integer;
begin
try
startin := memavail;
{$ifdef view}
     arrayDebug.listbox1.items.add('create2  4  100');
     arrayDebug.listbox1.items.move(arrayDebug.listbox1.items.count-1,0);
     arrayDebug.listbox1.update;
{$endif}
     _testarr_ := array_t.create2(4,100);

     inc(ARRDBcounter);
     result := random(7)+4;
     szlastWeb := 'create2';
finishin := memavail;
except on exception do
begin
     messagedlg('Error in Create2',mterror,[mbok],0);
end;
end;
end;

function array_t.wrapDestroy : integer;
begin
try
startin := memavail;
{$ifdef view}
     arrayDebug.listbox1.items.add('destroy');
     arrayDebug.listbox1.items.move(arrayDebug.listbox1.items.count-1,0);
     arrayDebug.listbox1.update;
{$endif}
{     _testarr_.destroy;}

     inc(ARRDBcounter);
     result := 5;
     szlastWeb := 'destroy';
finishin := memavail;
except on exception do
begin
     messagedlg('Error in wrapDestroy',mterror,[mbok],0);
end;
end;
end;

function array_t.WrapFree : integer;
begin
try
startin := memavail;
{$ifdef view}
     arrayDebug.listbox1.items.add('free');
     arrayDebug.listbox1.items.move(arrayDebug.listbox1.items.count-1,0);
     arrayDebug.listbox1.update;
{$endif}
     _testarr_.free;

     inc(ARRDBcounter);
     result := 5;
     szlastWeb := 'free';
finishin := memavail;
except on exception do
begin
     messagedlg('Error in Free',mterror,[mbok],0);
end;
end;
end;

function array_t.WrapInit : integer;
var
   newsize,newels : longint;
begin
try
startin := memavail;
     newsize := round(random*4)+1;
     newels := round(random*1000)+1;
{$ifdef view}
     arrayDebug.listbox1.items.add('init  ' + inttostr(newsize) + '  ' + inttostr(newels));
     arrayDebug.listbox1.items.move(arrayDebug.listbox1.items.count-1,0);
     arrayDebug.listbox1.update;
{$endif}
     _testarr_.Init(newsize,newels);

     inc(ARRDBcounter);
     result := random(7)+4;
     szlastWeb := 'init';
finishin := memavail;
except on exception do
begin
     messagedlg('Error in Init',mterror,[mbok],0);
end;
end;
end;

function array_t.WrapResize : integer;
var
   newsize : longint;
begin
try
startin := memavail;
     newsize := round(random*MAXTESTRESIZE)+1;
     if newsize = _testarr_.lMaxSize then inc(newsize);
{$ifdef view}
     arrayDebug.listbox1.items.add('resize  ' + inttostr(newsize));
     arrayDebug.listbox1.items.move(arrayDebug.listbox1.items.count-1,0);
     arrayDebug.listbox1.update;
{$endif}
     _testarr_.resize(newsize);

     inc(ARRDBcounter);
     result := random(7)+4;
     szlastWeb := 'resize';
finishin := memavail;
except on exception do
begin
     messagedlg('Error in Resize',mterror,[mbok],0);
end;
end;
end;

function array_t.WrapSetValue : integer;
var
   pos : longint;
begin
try
startin := memavail;
     pos := _testarr_.lMaxSize;
     pos := round(pos*random);
     if pos = 0 then pos := _testarr_.lMaxSize;
{$ifdef view}
     arrayDebug.listbox1.items.add('setvalue  ' + inttostr(pos));
     arrayDebug.listbox1.items.move(arrayDebug.listbox1.items.count-1,0);
     arrayDebug.listbox1.update;
{$endif}
     _testarr_.SetValue(pos,@debugbuffer);

     inc(ARRDBcounter);
     result := random(7)+4;
     szlastWeb := 'setvalue';
finishin := memavail;
{$ifdef memhold}
     if startin <> finishin then
         messagedlg('Error in memory',mterror,[mbok],0);
{$endif}
except on exception do
begin
     messagedlg('Error in SetValue',mterror,[mbok],0);
end;
end;
end;

function array_t.WrapRtnValue : integer;
var
   pos : longint;
begin
try
startin := memavail;
     pos := _testarr_.lMaxSize;
     pos := round(pos*random);
     if pos = 0 then pos := _testarr_.lMaxSize;
{$ifdef view}
     arrayDebug.listbox1.items.add('rtnValue  ' + inttostr(pos));
     arrayDebug.listbox1.items.move(arrayDebug.listbox1.items.count-1,0);
     arrayDebug.listbox1.update;
{$endif}

     _testarr_.RtnValue(pos,@debugbuffer);

     inc(ARRDBcounter);
     result := random(7)+4;
     szlastWeb := 'rtnvalue';
finishin := memavail;
{$ifdef memhold}
     if startin <> finishin then
         messagedlg('Error in memory',mterror,[mbok],0);
{$endif}
except on exception do
begin
     messagedlg('Error in RtnValue',mterror,[mbok],0);
end;
end;
end;

function array_t.WrapRtnPtr : integer;
var
   pt : pointer;
   pos : longint;

{$ifdef ptrrtntest}
   function testptrRtn : pointer;
   begin
        new(Result);
   end;
{$endif}
begin
try

startin := memavail;
     pos := _testarr_.lMaxSize;
     pos := round(pos*random);
     if pos = 0 then pos := _testarr_.lMaxSize;
{$ifdef view}
     arrayDebug.listbox1.items.add('rtnptr  '+inttostr(pos));
     arrayDebug.listbox1.items.move(arrayDebug.listbox1.items.count-1,0);
     arrayDebug.listbox1.update;
{$endif}

{$ifdef ptrrtntest}
startin := memavail;
testptrrtn;
finishin := memavail;
{$endif}

     new(pt);
     pos := _testarr_.lMaxSize;
     pos := round(pos*random);
     if pos = 0 then pos := _testarr_.lMaxSize;
     pt := _testarr_.rtnPtr(pos);
     pt := NIL;
     dispose(pt);
     inc(ARRDBcounter);
     result := random(7)+4;
     szlastWeb := 'rtnptr';
finishin := memavail;
{$ifdef memhold}
     if startin <> finishin then
         messagedlg('Error in memory',mterror,[mbok],0);
{$endif}
except on exception do
begin
     messagedlg('Error in RtnPtr',mterror,[mbok],0);
end;
end;
end;

function array_t.WrapSortwrt : integer;
begin
try
startin := memavail;
{$ifdef view}
     arrayDebug.listbox1.items.add('sort');
     arrayDebug.listbox1.items.move(arrayDebug.listbox1.items.count-1,0);
     arrayDebug.listbox1.update;
{$endif}
     {POSSIBLE LEAK - SO IS NOT CURRENTLY IMPLIMENTED TESTED FULLY}
{     _testarr_.sort(0,scLong);}
     inc(ARRDBcounter);
     result := random(7)+4;
     szlastWeb := 'sort';
finishin := memavail;
{$ifdef memhold}
     if startin <> finishin then
         messagedlg('Error in memory',mterror,[mbok],0);
{$endif}
except on exception do
begin
     messagedlg('Error in Sort(index,sortcast)',mterror,[mbok],0);
end;
end;
end;


procedure testing;
begin

end;

initialization
begin
{$ifdef _develop_}
     basedir := 'd:\temp';
{$else}
     basedir := 'c:';
{$endif}
     baselocation := basedir+'\arrp';

{     initArraytest;}


end;
end.
