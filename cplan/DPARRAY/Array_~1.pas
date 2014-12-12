{$I \software\cplan\dparray\Ranged~1.pas}
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

function Array_t.recite(sz : string) : tStringStream;
begin
     if sz = cPAGELIST then RangeList.draw
end;

procedure Array_t.typedwriteln(datatype : string; const szFile : string);
var
   x : longint;
   outFile : text;
   wword : word;
   llong : longint;
   sz : string;
begin
     assignfile(outFile,szFile);
     append(outFile);
     toUpper(datatype,sz);
     if sz = 'WORD' then
     begin
          for x := 1 to lMaxSize do
          begin
               rtnValue(x,@wword);
               write(outFile,inttostr(wword)+'   ');
          end;
     end
     else
         if sz = 'LONG' then
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

procedure Array_t.fileofp(page:integer; var res : string);
begin
     Res := baselocation + inttostr(instanceRef) + '.' + inttostr(page);
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
{
     start := baserefs^[currentbase] + 1;
     finish := baserefs^[currentbase+1];
     if finish = -1 then finish := lOldSize;
     if finish < start then finish := lMaxSize;

     for x := start to finish do
     begin
try
          rtnValue(x,@l);
          MemStr.write(l,lDataTypeSize);
except
begin
     l := -1;
end;
end;
     end;
}
end;

procedure Array_t.MemStreamToArray_t(var MemStr : tMemoryStream);
var
   p : pointer;
   count : longint;
   l : longint;
   ll : longint;
begin
{     count := BaseRefs^[CurrentBase];
     getmem(p,lDataTypeSize);
     l := MemStr.read(ll,lDataTypeSize);
     if l = lDataTypeSize then
     repeat
          inc(count);
          setValue(count,@ll);
          l := MemStr.read(ll,lDataTypeSize);
     until l <> lDataTypeSize;
     freemem(p,lDataTypeSize);
}
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
(*
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
*)
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
(*     sz := fileof(currentbase);

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
*)     
end;

procedure Array_t.LocatePage(ref : longint);
var
   cb : integer;
   fin : boolean;

begin
{     cb := 1;

     while BaseRefs^[cb] <> -1 do
     begin
          if ((BaseRefs^[cb] < ref) and (BaseRefs^[cb+1] >= ref)) then break;
          inc(cb);
     end;
     if BaseRefs^[cb] = -1 then
     begin
          dec(cb);
     end;
     currentbase := cb;
}
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
     szData := baselocation;
///     baserefs := nil;

     fNopaging := FALSE;
     Page_size := _PAGE_SIZE_;

     RangeList := nil;
     RangeNode := nil;
     fbaseline := TRUE;

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
          if rangelist <> nil then RangeList.free;
          if rangenode <> nil then RangeNode.free;
          if lMaxSize <> 0 then
          begin
               FreeContMemPtr(ptrDataStart);
{$ifdef ver80}
               ptrDataStart := nil;
               DisposeContMemPtr(ptrDataStart);
{$else}
{               dispose(ptrDataStart);}
{$endif}
          end;

(*
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
*)
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
   aMem : array[1..10] of longint;

begin
     if lMaxSize <> 0 then
     begin
          FreeContMemPtr(ptrDataStart);
{$ifdef ver80}
          ptrDataStart := nil;
          DisposeContMemPtr(ptrDataStart);
{$endif}
     end;

     if RangeList <> nil then RangeList.destroy;
     if RangeNode <> nil then RangeNode.destroy;
(*
     if BaseRefs <> nil then
     begin
          for x := 1 to _MAX_ do
          begin
               sz := fileof(x);
//                 fileofp(x,sz);
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
          dispose(BaseRefs);
          BaseRefs := nil;
     end;
*)

  inherited destroy;
end;

procedure Array_t.dontpage;
begin
     fNoPaging := TRUE;
end;

procedure Array_t.dopage;
begin
     fNoPaging := FALSE;
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

     if ((lMaxSize*lDataTypeSize) <= PAGE_SIZE) or fNoPaging then
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
          ContigData.lDataUnitsPerSegment := SegmentSize_C div SizeOfDataType;
          getmem(ptrDataStart,1*lDataTypeSize);
{$endif}

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
end;

procedure Array_t.clr;
begin
     if ptrDataStart <> nil then
     begin
          FreeContMemPtr(ptrDataStart);
     end;

     ptrDataStart := nil;
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
               if lMaxSize < Page_Size then
                resize(PAGE_SIZE)
               else
               begin
                    if ((lMaxSize mod Page_Size) = 0) then
                    begin
                         resize(lMaxSize + page_size)
                    end
                    else
                    begin
                         resize(((lMaxSize div page_size)+1)*page_size);
                    end;
               end;
          end;
     end;
try
     if rangeList <> nil then RangeList.ActiveNode.fModified := true;
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
     messagedlg('Error in trying to set value - Known possible cause:'+
                 ' Existance of array paging files before the code was started',
                 mterror,[mbok],0);
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
     if rangeList <> nil then RangeList.ActiveNode.fModified := true;
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
   aMem : array[1..10] of longint;
   toset : boolean;

begin
{inc(cntResize);}
     toset := false;
     lOldSize := lMaxSize;
     lMaxSize := lNewSize;
     if lNewSize <= 0 then
     begin
     exit; lNewSize := 1;
     end;

     if ((lNewSize * lDataTypeSize) <= PAGE_SIZE) or fNopaging then
        fpaged := false
     else
     begin
          fpaged := true;
     end;

     if not(fPaged) then
     begin
          ReallocContMemPtr(ptrDataStart,lNewSize,lDataTypeSize,ContigData);
     end
     else
     begin
          ReallocContMemPtr(ptrDataStart,PAGE_SIZE div lDataTypeSize,lDataTypeSize,ContigData);

          BaseLine;
     end;

end;

procedure Array_t.baseline;  // sets the linked list of ranges from BaseRefs^[CurrentBase]
var
   stpt,endpt : longint;

   fterm : boolean;
   count : longint;

begin
     if RangeList = nil then RangeList := RangedList.create(
                  (PAGE_SIZE div (Contigdata.lDataUnitsPerSegment*lDataTypeSize)),ptrDataStart)
     else RangeList.free;
     if RangeNode = nil then RangeNode := RangedNode.create;

    endpt := 0;
    count := 0;
    fterm := false;
     repeat
           inc(count);
           if not(fterm) then
           begin
                stpt := endpt + 1;
                endpt := stpt-1 + ContigData.lDataUnitsPerSegment;
           end
           else
           begin
                stpt := -2;
                endpt := -2;
           end;
           if endpt > lmaxsize then
           begin
                endpt := lmaxsize;
                fterm := true;
           end;
           RangeList.ActiveNode.setdata(stpt,endpt);
           if count <= RangeList.lListPages then
           begin
              RangeList.ActiveNode.ptrdata := pointer(longint(ptrDataStart) + (stpt-1)*lDataTypeSize);
              RangeList.ActiveNode.data := stpt;
           end;
           RangeList.insertafter;
     until (endpt = lMaxSize);
     RangeList.delete;
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
     Result := Nil;
     try
        quicksortwrt(DataPosition,sorttype,1,lMaxSize);
     except on exception do
     begin
          SelectionSortwrt(DataPosition,sorttype);
     end;
     end;
end;

procedure Array_T.pagein(lRef : longint);
var
   dataref : longint;
   f : file of byte;
   pt : pointer;

begin
     // if nec. save the data from the final page in the list - active node should be on this node
     dataref := RangeList.ActiveNode.data;
     if RangeList.ActiveNode.fModified then
     begin
          //open the file
          assignfile(f,RangeList.ActiveNode.szFileName);
          rewrite(f);
          if ((lMaxSize - dataref) >= Contigdata.lDataunitspersegment) then
          begin
               pt := locateContMemPtr(ptrDataStart,dataref,lDataTypeSize,ContigData);
               blockwrite(f,pt^,(Contigdata.lDataunitspersegment)*lDataTypeSize);
          end
          else
          begin
               pt := locateContMemPtr(ptrDataStart,dataref,lDataTypeSize,ContigData);
               blockwrite(f,pt^,(lMaxSize - dataref)*lDataTypeSize);
          end;

          //save the data located at ptrData

          closefile(f);
          RangeList.ActiveNode.fModified := false;
     end;
     // Go to start
     RangeList.moveNode(cStart);
     // insert before
     RangeList.insertbefore;
     // find the correct page for nec data
    RangeList.Movewithin(lRef);
     // copy this data appropriately to the new blank startnode
     RangeList.StartNode.startdata := RangeList.ActiveNode.startdata;
     RangeList.StartNode.enddata := RangeList.ActiveNode.enddata;
     RangeList.StartNode.data := dataref;
     RangeList.StartNode.szfileName := RangeList.ActiveNode.szfilename;
         // load the contig data block from the app file
          assignfile(f,RangeList.ActiveNode.szFileName);
          if fileexists(RangeList.ActiveNode.szfilename) then
          begin
               reset(f);
               pt := locateContMemPtr(ptrDataStart,dataref,lDataTypeSize,ContigData);
               blockread(f,pt^,filesize(f));
               closefile(f);
          end;
     // delete the active node - ie the one that has just been located/copied from
     RangeList.remove;
     RangeList.moveNode(cStart);
end;

procedure Array_T.promote(lRef : longint);
var
   aMem : array[1..10] of longint;

begin
     if RangeList.atStart then exit;
     // Go to start
     RangeList.moveNode(cStart);

     // insert before
     RangeList.insertbefore;
     // find the correct page for nec data
     RangeList.Movewithin(lRef);

     // copy this data appropriately to the new blank startnode
     RangeList.StartNode.startdata := RangeList.ActiveNode.startdata;
     RangeList.StartNode.enddata := RangeList.ActiveNode.enddata;
     RangeList.StartNode.data := RangeList.ActiveNode.data;
     RangeList.StartNode.szfileName := RangeList.ActiveNode.szfilename;

     // delete the active node - ie the one that has just been located/copied from
     RangeList.remove;
     RangeList.moveNode(cStart);
end;

function Array_T.LocateMem(lRef : longint) : pointer;
var
   oldcb : longint;
   tmpcb : longint;
   f : file;
   sz : string;
   ftest : boolean;
   AppRef : longint;
   offset : longint;
   tosave : pointer;
   savedptr : pointer;
   l,l2 : longint;

begin
     prev := 0;
     if not(fpaged) then
        result := LocateContMemPtr(ptrDataStart,lRef,lDataTypeSize,ContigData)
     else
     begin
      RangeList.moveNode(cStart);
       begin
          ftest :=  RangeList.withinany(lRef,RangeList.lListPages);
          if not(ftest) then
          begin
               pagein(lRef);
               AppRef := lRef-RangeList.ActiveNode.startdata+longint(RangeList.ActiveNode.data);
               result := LocateContMemPtr(ptrDataStart,AppRef,lDataTypeSize,ContigData);
          end
          else
          begin
               promote(lRef);
               AppRef := lRef-RangeList.ActiveNode.startdata+longint(RangeList.ActiveNode.data);
               result := LocateContMemPtr(ptrDataStart,AppRef,lDataTypeSize,ContigData);
          end;

          exit;
       end;
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
     Result := 0;
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
result := 0;
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
result := 0;
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
result := 0;
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
result := 0;
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
result := 0;
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
result := 0;
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
result := 0;
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
result := 0;
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
result := 0;
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


