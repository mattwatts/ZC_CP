unit Arrayt;
{$define _develop_}     
{$undef _bit16_}
interface

uses
    DataStru,sysutils, filectrl, forms, WinProcs {hmemcpy - can be replaced with move},dialogs,classes;

const
     StdSize_C = 100000; {A std. size constant}
     BIGSIZE = 500000;
     SegmentSize_C = 65536;
     _MAX_ = 1000; {Maximum size for ref array}
     _PAGE_SIZE_ : longint = BIGSIZE*4;


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
           ContigData : ContMemData_t;
           FofData : file;
           szData : string;
           CurrentBase : longint;
           BaseRefs : ^Array_MAX_;
           fPaged : boolean;
           fModified : boolean;

    public
          constructor create;
          destructor Destroy; override;
          procedure free;
          procedure inhdestroy;

          procedure init(SizeOfDataType, InitialNum : longint);
          procedure clr;

          procedure resize(lNewSize : longint);
          procedure setresize(state : boolean);

          procedure setValue(lElementNum : longint; ptrData : pointer);
          procedure rtnValue(lElementNum : longint; ptrData : pointer);
          function rtnPtr(lElementNum : longint) : pointer;

          procedure quicksortwrt(DataPosition : integer; sorttype : sortCast; iLo,iHi : longint);
          procedure SelectionSortwrt(DataPosition : integer; sorttype : sortcast);
          function sortwrt(DataPosition : integer; sorttype : sortCast) : array_t;

          procedure setto(ptrData : pointer);

          procedure setfilename(sz : string);

          procedure testing; override;

    private
           procedure Array_tToMemStream(var MemStr : tMemoryStream);
           procedure MemStreamToArray_t(var MemStr : tMemoryStream);
           function LocateMem(lRef : longint) : pointer;
           procedure SaveData;
           procedure LoadData;
           procedure LocatePage(ref : longint);
           function fileof(page:integer) : string;
    end;

    function copyofarr(arr : array_t) : array_t;

var
   _testarr_ : array_t;


procedure setpagingarray(dir : string);

implementation
uses
    arraydb;
var
f : file;
l : longint;
   sz : string;
   lOldSize : longint;
   ArrayRef : longint;
   files : tfilelistbox;
   x : longint;

   basedir : string;
   baselocation : string;

procedure setpagingarray(dir : string);
begin
     basedir := dir;

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
   towrite,written : word;
   pos : longint;
   memstrm : tMemoryStream;

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

          memstrm := tMemoryStream.create;
          array_tToMemStream(memstrm);
          memstrm.savetofile(sz);
          memstrm.free;
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

   memstrm : tMemoryStream;

begin
     sz := fileof(currentbase);

{     assignfile(FofData,sz);
     reset(FofData,lDataTypeSize);
     ReallocContMemPtr(ptrDataStart,filesize(fOfData),lDataTypeSize,ContigData);
     closefile(fofdata);
}
     memstrm := tMemoryStream.create;
     memstrm.loadfromfile(sz);
     MemStreamToArray_t(memstrm);
     memstrm.free;
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

constructor Array_t.create;
begin
     inherited create;

     ptrDataStart := nil;
     lDataTypeSize := 0;
     lMaxSize := 0;
     Resizing := FALSE;

     ContigData.lDataUnitsPerSegment := 0;
     ContigData.fit := FALSE;

     CurrentBase := 1;
     fPaged := FALSE;
     fModified := TRUE;
     szData := baselocation;
     BaseRefs := nil;

     if instanceref = 2 then
     begin
     end;
end;

procedure Array_t.free;

var
   tmp : pchar;
   x : integer;
   
begin
     if self <> nil then
     begin
          if ptrDataStart <> nil then
          begin
               FreeContMemPtr(ptrDataStart);
               ptrDataStart := nil;
               DisposeContMemPtr(ptrDataStart);
          end;

          if fpaged then
          begin
               for x := 1 to _MAX_ do
               begin
                    sz := fileof(x);
{$ifdef _bit16_}
                    if fileexists(sz) then
                       deletefile(sz)
                    else
                        break;
{$else}
                    tmp := stralloc(length(sz)+1);
                    strpCopy(tmp,sz);
                    if not(deletefile(tmp)) then break;
{$endif}
               end;
              freemem(BaseRefs,_MAX_*sizeof(longint));
          end;

          inherited free;
     end;
end;

procedure Array_t.inhdestroy;
begin
     inherited destroy;
end;

destructor Array_t.Destroy;
begin
     if ptrDataStart <> nil then
     begin
          FreeContMemPtr(ptrDataStart);
          ptrDataStart := nil;
          DisposeContMemPtr(ptrDataStart);
     end;
     inherited destroy;
end;

procedure Array_t.init(SizeOfDataType, InitialNum : longint);

var
   x,y,z : longint;

begin
     lDataTypeSize := SizeOfDataType;
     lMaxSize := InitialNum;

     if ((lMaxSize*lDataTypeSize) < _PAGE_SIZE_) then
        fpaged := false
     else
        fpaged := true;

     if sizeof(integer) = 2 then
     begin
          if ((SEGMENTSIZE_C mod SizeOfDataType) = 0) then
             ContigData.Fit := TRUE
          else
              ContigData.Fit := FALSE;

          if ptrDataStart <> nil then
            FreeContMemPtr(ptrDataStart);
          AllocContMemPtr(ptrDataStart,InitialNum,SizeOfDataType,ContigData);
     end
     else
     begin
          getmem(ptrDataStart,lMaxSize*lDataTypeSize);
     end;

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

procedure Array_T.setValue(lElementNum : longint; ptrData : pointer);

var
   pNewPtr : pointer;
   iPosition : integer;
   tmpA : array_t;
   tmpB : array_t;
   x : longint;
   lPtr : longint;

begin
      if (lElementNum < 1) or (lElementNum > lMaxSize) then
      begin
          if not(resizing) then
          begin
               MessageDlg('Error rtnValue trying to access beyond scope, index ' + IntToStr(lElementNum)
                     + ' - Halting',
                     mtError,[mbOK],0);
               halt;
          end
          else
          begin
               resize(lMaxSize+BIGSIZE)
          end;
     end;
try
      new(pNewptr);
      pNewPtr := LocateMem(lElementNum);
      move(ptrData^,pNewPtr^,lDataTypeSize);
      fModified := TRUE;
except on exception do 
begin
{$ifdef _bit16_}
     x := globalsize(selectorof(ptrdatastart));
{$endif}
     halt;
end;
end;
end;

procedure Array_T.rtnValue(lElementNum : longint; ptrData : pointer);

var
   pNewPtr : pointer;
   iPosition : integer;

begin
     if (lElementNum < 1) or (lElementNum > lMaxSize) then
     begin
          MessageDlg('Error rtnValue trying to access beyond scope, index ' + IntToStr(lElementNum)
                     + ' - Halting',
                     mtError,[mbOK],0);
              halt;
     end;
      new(pNewptr);
      pNewPtr := LocateMem(lElementNum);
      move(pNewPtr^,ptrData^,lDataTypeSize);
end;

function Array_t.rtnPtr(lElementNum : longint) : pointer;
begin
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
     inittest;
end;

procedure Array_T.resize(lNewSize : longint);
var
   oldcb : longint;
   f : file;
   sz : string;
   fsize : longint;
begin
     lOldSize := lMaxSize;
     lMaxSize := lNewSize;
     if lNewSize <= 0 then
     begin
     exit; lNewSize := 1;
     end;


     if ((lNewSize * lDataTypeSize) < _PAGE_SIZE_) then
        fpaged := false
     else
     begin
          fpaged := true;
          if BaseRefs = nil then
          begin
               getmem(BaseRefs,_MAX_*sizeof(longint));
               BaseRefs^[1] := 0;
               BaseRefs^[2] := -1;
          end;
     end;
     if not(fPaged) then
     begin
          ReallocContMemPtr(ptrDataStart,lNewSize,lDataTypeSize,ContigData);
     end
     else
     begin
          savedata;
          if BaseRefs^[currentBase+1] = -1 then
          begin
               BaseRefs^[CurrentBase+1] := lOldSize;
               BaseRefs^[CurrentBase+2] := -1;
          end;
          oldcb := currentbase;
          locatepage(lNewSize);
          if oldcb <> currentbase then
          begin
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

procedure Array_t.quicksortwrt(DataPosition : integer; sorttype : sortCast; iLo,iHi : longint);
var
     Lo,Hi,Mid,T : longint;
     rMid,rblank : real;
     rLo,rHi : real;
     intLo,intHi : integer;
     lLo,lHi : longint;
     szLo,szHi : string;
     Value : pointer;
     testValue : pointer;
     ptrLo, ptrHi, ptrcopy : pointer;

begin
try
       Lo := iLo;
       Hi := iHi;
       Value := rtnPtr((Lo+Hi) div 2);
{$ifdef _bit16_}
       testvalue := ptr(seg(value^),ofs(value^)+dataPosition);
{$else}
       testvalue := pointer(integer(value^)+dataPosition);
{$endif}
       repeat
             ptrLo := rtnPtr(Lo);
{$ifdef _bit16_}
             ptrLo := ptr(seg(ptrLo^),word(ofs(ptrLo^)+dataPosition));
{$else}
             ptrLo := pointer(integer(ptrLo^)+dataPosition);
{$endif}
             ptrHi := rtnPtr(Hi);
{$ifdef _bit16_}
             ptrHi := ptr(seg(ptrHi^),word(ofs(ptrHi^)+dataPosition));
{$else}
             ptrHi := pointer(integer(ptrHi^) + dataPosition);
{$endif}
             case sorttype of
               scInt :    begin
                               while integer(PtrLo^) < integer(testvalue^) do
                               begin
                                    Inc(Lo);
                                    ptrLo := rtnPtr(Lo);
{$ifdef _bit16_}
                                    ptrLo := ptr(seg(ptrLo^),word(ofs(ptrLo^)+dataPosition));
{$else}
                                    ptrLo := pointer(integer(ptrLo^)+dataPosition);
{$endif}
                               end;
                          end;
               scLong :   begin
                               while longint(PtrLo^) < longint(testvalue^) do
                               begin
                                    Inc(Lo);
                                    ptrLo := rtnPtr(Lo);
{$ifdef _bit16_}
                                    ptrLo := ptr(seg(ptrLo^),word(ofs(ptrLo^)+dataPosition));
{$else}
                                    ptrLo := pointer(integer(ptrLo^)+dataPosition);
{$endif}
                               end;

                          end;
               scReal :   begin
                               while real(PtrLo^) < real(testvalue^) do
                               begin
                                    Inc(Lo);
                                    ptrLo := rtnPtr(Lo);
{$ifdef _bit16_}
                                    ptrLo := ptr(seg(ptrLo^),word(ofs(ptrLo^)+dataPosition));
{$else}
                                    ptrLo := pointer(integer(ptrLo^)+dataPosition);
{$endif}
                               end;
                          end;
               scString : begin
                               while string(PtrLo^) < string(testvalue^) do
                               begin
                                    Inc(Lo);
                                    ptrLo := rtnPtr(Lo);
{$ifdef _bit16_}
                                    ptrLo := ptr(seg(ptrLo^),word(ofs(ptrLo^)+dataPosition));
{$else}
                                    ptrLo := pointer(integer(ptrLo^)+dataPosition);
{$endif}
                               end;
                          end;
               else       begin
                               halt;
                          end;
             end;
             case sorttype of
               scInt :    begin
                               while integer(PtrHi^) > integer(testvalue^) do
                               begin
                                    Dec(Hi);
                                    ptrHI := rtnPtr(Hi);
{$ifdef _bit16_}
                                    ptrHi := ptr(seg(ptrHi^),word(ofs(ptrHi^)+dataPosition));
{$else}
                                    ptrHi := pointer(integer(ptrHi^)+dataPosition);
{$endif}
                               end;
                          end;
               scLong :   begin
                               while longint(Ptrhi^) > longint(testvalue^) do
                               begin
                                    Dec(Hi);
                                    ptrHI := rtnPtr(Hi);
{$ifdef _bit16_}
                                    ptrHi := ptr(seg(ptrHi^),word(ofs(ptrHi^)+dataPosition));
{$else}
                                    ptrHi := pointer(integer(ptrHi^)+dataPosition);
{$endif}
                               end;
                          end;
               scReal :   begin
                               while real(Ptrhi^) > real(testvalue^) do
                               begin
                                    Dec(Hi);
                                    ptrHI := rtnPtr(Hi);
{$ifdef _bit16_}
                                    ptrHi := ptr(seg(ptrHi^),word(ofs(ptrHi^)+dataPosition));
{$else}
                                    ptrHi := pointer(integer(ptrHi^)+dataPosition);
{$endif}
                               end;
                          end;
               scString : begin
                               while string(Ptrhi^) > string(testvalue^) do
                               begin
                                    Dec(Hi);
                                    ptrHI := rtnPtr(Hi);
{$ifdef _bit16_}
                                    ptrHi := ptr(seg(ptrHi^),word(ofs(ptrHi^)+dataPosition));
{$else}
                                    ptrHi := pointer(integer(ptrHi^)+dataPosition);
{$endif}
                               end;
                          end;
               else       begin
                               halt;
                          end;
             end;
             if Lo <= Hi then
             begin
             case sorttype of
               scInt :    begin
                               getmem(ptrcopy,lDatatypeSize);
                               ptrLo := rtnPtr(Lo);
{$ifdef _bit16_}
                               hmemcpy(ptrcopy,ptrlo,lDataTypeSize);
{$else}
                               move(ptrLo^,ptrCopy^,lDataTypeSize);
{$endif}
                               ptrHi := rtnPtr(Hi);
                               setValue(Lo,PtrHi);
                               setValue(Hi,Ptrcopy);
                               freemem(ptrcopy,ldatatypesize);
                          end;
               scLong :   begin
                               getmem(ptrcopy,lDatatypeSize);
                               ptrLo := rtnPtr(Lo);
{$ifdef _bit16_}
                               hmemcpy(ptrcopy,ptrlo,lDataTypeSize);
{$else}
                               move(ptrLo^,ptrCopy^,lDataTypeSize);
{$endif}
                               ptrHi := rtnPtr(Hi);
                               setValue(Lo,PtrHi);
                               setValue(Hi,Ptrcopy);
                               freemem(ptrcopy,ldatatypesize);
                          end;
               scReal :   begin
                               getmem(ptrcopy,lDatatypeSize);
                               ptrLo := rtnPtr(Lo);
{$ifdef _bit16_}
                               hmemcpy(ptrcopy,ptrlo,lDataTypeSize);
{$else}
                               move(ptrLo^,ptrcopy^,lDataTypeSize);
{$endif}
                               ptrHi := rtnPtr(Hi);
                               setValue(Lo,PtrHi);
                               setValue(Hi,Ptrcopy);
                               freemem(ptrcopy,ldatatypesize);
                          end;
               scString : begin
                               getmem(ptrcopy,lDatatypeSize);
                               ptrLo := rtnPtr(Lo);
{$ifdef _bit16_}
                               hmemcpy(ptrcopy,ptrlo,lDataTypeSize);
{$else}
                               move(ptrLo^,ptrcopy^,lDataTypeSize);
{$endif}
                               ptrHi := rtnPtr(Hi);
                               setValue(Lo,PtrHi);
                               setValue(Hi,Ptrcopy);
                               freemem(ptrcopy,ldatatypesize);
                          end;
               else       begin
                               halt;
                          end;
             end;
                  inc(Lo);
                  dec(Hi);
             end;

       until Lo > Hi;
       if Hi > iLo then QuickSortwrt(DataPosition,sorttype,iLo,Hi);
       if Lo < iHi then QuickSortwrt(DataPosition,sorttype,Lo,iHi);
except on exception do
   begin
Lo := Lo -1;{          selectionsortwrt(DataPosition,sorttype);}
raise;
   end
end;
end;

 procedure Array_t.SelectionSortwrt(DataPosition : integer; sorttype : sortCast);
var
  I, J, T: longint;
  rblank1,rblank2,rblank3 : longint;

begin
  for I := 1 to lMaxSize - 1 do
    for J := lMaxSize downto I + 1 do
    begin
         rtnValue(i,@rblank1);
         rtnvalue(j,@rblank2);
      if rblank1 > rblank2 then
      begin
        setvalue(i,@rblank2);
        setvalue(j,@rblank1);
      end;
    end;
end;

function array_t.sortwrt(DataPosition : integer; sorttype : sortCast) : array_t;
begin
     result := array_t.create;
     Result := copyofarr(self);

try
     Result.quicksortwrt(DataPosition,sorttype,1,lMaxSize);
except on exception do
   begin
Result.SelectionSortwrt(DataPosition,sorttype);
   end;
end;
end;

function Array_T.LocateMem(lRef : longint) : pointer;
var
   oldcb : longint;
   tmpcb : longint;
   f : file;

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
               assignfile(f,fileof(currentbase));
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

initialization
begin
     _testarr_ := array_t.create;

{     for x := 1 to files
     sz := baselocation+'22.1';
     if not deletefile(sz) then
     begin
     loldsize := -1;
     end;
}
{$ifdef _develop_}
     basedir := 'd:\temp';
{$else}
     basedir := 'c:';
{$endif}
     baselocation := basedir+'\arrp';

end;
end.
