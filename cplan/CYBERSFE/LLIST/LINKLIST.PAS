unit Linklist;

{Sets up a linked list}
interface
uses winprocs;

  type

      dataType = integer;

    StubClass = class

    end;

    Node_O = class
               pNext : Node_O;
               pData : pointer;

               constructor init(iDataSize : integer);
               destructor Destroy;  override;
             end;

    List_O = class
                  pHead,
                  pCurrent : Node_O;

                  constructor init(iDataSize : integer);
                  Function  AddNode(ptrData : pointer; iDataSize : integer) : boolean; dynamic;
                  Function  DeleteNode : boolean;
                  Function  AmmendData(ptrData : pointer; iDataSize : integer) : boolean;  dynamic;
                  Function  ReadData   : pointer;  dynamic;
                  Function  IsStart    : boolean;
                  Function  IsEnd      : boolean;
                  Procedure GoStart;
                  Procedure GoEnd;
                  Function  GoPrev     : boolean;
                  Function  GoNext     : boolean;
                  Function  Length     : longint;
                  Function  Position   : longint;
                  function  FindPrevNode(pNode : Node_O) : Node_O;
                  destructor destroy; override;

                  procedure NewHead(ptrData : pointer; iDataSize : integer);  dynamic;
                end;

    ConstSizedDataList_O = class (List_O)
                  iDataSize : integer;
    end;

    LongList_O = class(ConstSizedDataList_O)

                  constructor init;
                  destructor destroy; override;
                  Function  AddNode(Data : Longint) : boolean;
                  Function  AmmendData(Data : Longint) : boolean;
                  Function  ReadData   : Longint;
                  procedure NewHead(Data : Longint);
    end;

    IntList_O = class(ConstSizedDataList_O)

                  constructor init; 
                  destructor Destroy; override;
                  Function  AddNode(Data : integer) : boolean;
                  Function  AmmendData(Data : integer) : boolean;
                  Function  ReadData   : integer;
                  procedure NewHead(Data : integer);
    end;

    SingleList_O = class(ConstSizedDataList_O)

                  constructor init;
                  destructor Destroy; override;
                  Function  AddNode(Data : Single) : boolean;
                  Function  AmmendData(Data : Single) : boolean;
                  Function  ReadData   : Single;
                  procedure NewHead(Data : Single);
    end;

    RealList_O = class(ConstSizedDataList_O)

                  constructor init;
                  destructor Destroy; override;
                  Function  AddNode(Data : real) : boolean;
                  Function  AmmendData(Data : real) : boolean;
                  Function  ReadData   : real;
                  procedure NewHead(Data : real);
    end;

    WordList_O = class(ConstSizedDataList_O)

                  constructor init;
                  destructor Destroy; override;
                  Function  AddNode(Data : word) : boolean;
                  Function  AmmendData(Data : word) : boolean;
                  Function  ReadData   : word;
                  procedure NewHead(Data : word);
    end;

    ByteList_O = class(ConstSizedDataList_O)

                  constructor init;
                  destructor Destroy; override;
                  Function  AddNode(Data : byte) : boolean;
                  Function  AmmendData(Data : byte) : boolean;
                  Function  ReadData   : byte;
                  procedure NewHead(Data : byte);
    end;

    BooleanList_O = class(ConstSizedDataList_O)

                  constructor init;
                  destructor Destroy; override;
                  Function  AddNode(Data : boolean) : boolean;
                  Function  AmmendData(Data : boolean) : boolean;
                  Function  ReadData   : boolean;
                  procedure NewHead(Data : boolean);
    end;


implementation

  constructor Node_O.init(iDataSize : integer);
  begin
       getmem(pData,iDataSize);
       pNext := NIL;
  end;

  destructor Node_O.destroy;
  begin
       pNext := NIL;
{       freemem(pointer(pNext));}
       pData := NIL;
       dispose(pData);
       inherited destroy;
  end;

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  {sets up a dummy node to start the list}
  constructor List_O.init(iDataSize : integer);
  begin
       pHead := Node_O.create;
       pCurrent := Node_O.create;
       pHead.init(iDataSize);
       pCurrent := nil;

  end;{constructor init}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Function List_O.AddNode(ptrData : pointer; iDataSize : integer) : boolean;
  var
    pTemp : Node_O;

  begin
    result := True;
    pTemp := Node_O.create;
    pTemp.init(iDataSize);
    if pTemp <> nil then
      {allocation sucessful}
      if pCurrent = nil then
      {The Current pointer is pointing to the end meaning the list is empty}
      begin
        pHead := pTemp;
        move(ptrData^,pTemp.pData^,iDataSize);
{
        hmemcpy(pTest,ptrData,iDataSize);
}
        pTemp.pNext := nil;
        pCurrent := pTemp;
      end
      else
      {Start here if the list already has elements,
       add new node after current leaving pCurrent where it is}
      begin
        pTemp.pNext := pCurrent.pNext;
        pCurrent.pNext := pTemp;
        move(ptrData^,pTemp.pData^,iDataSize);
{        hmemcpy(pTemp.pData,ptrData,iDataSize);}
        pCurrent := pTemp;
      end{ELSEif pCurrent = nil}
    else
      {allocation unsucessful}
      Result := False;

  end;{Function List_O.AddNode}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Function List_O.DeleteNode : boolean;
  {Removes the node pointed by pCurrent}
  var
    pPrev : Node_O;
  begin
    if pCurrent <> nil then {is list empty}
    begin
      {Find the node before pCurrent}
      pPrev := FindPrevNode(pCurrent);

      {is pCurrent pointing to first node}
      if pPrev = nil then
      begin {pCurrent is first node}
        pHead := pCurrent.pNext;
        pCurrent.Destroy;
        pCurrent := pHead; {advance current pointer to new first node}
      end{if pPrev = nil}
      else
      begin {pCurrent is not first node}
        pPrev.pNext := pCurrent.pNext; {weave pointers around delete node}
        pCurrent.Destroy;
        pCurrent := pPrev; {current pointer is now the prev node}
      end;{ELSEif pPrev = nil}
      Result := True;
    end{if pCurrent <> nil}
    else
      Result := False;

  end;{Function List_O.DeleteNode}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Function List_O.AmmendData(ptrData : pointer; iDataSize : integer) : boolean;
  begin
       Result := TRUE;
       if pCurrent <> nil then
          move(ptrData^,pCurrent.pData^,iDataSize)
{          hmemcpy(pCurrent.pData,ptrData,iDataSize)}
       else
           Result := FALSE;
  end;{Function List_O.AmmendData}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Function List_O.ReadData : pointer;
  begin
    if pCurrent <> nil then
      Result := pCurrent.pData
  end;{Function List_O.AmmendData}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Function List_O.IsStart : boolean;
  begin
    if pCurrent = pHead then
      Result := True
    else
      Result := False
  end;{Function List_O.IsStart}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function List_O.IsEnd : boolean;
  {The current node is at the end unless the list is not empty and the
   node following is not the last}
  begin
    Result := True;
    if (pHead <> nil) and (pCurrent.pNext <> nil) then
        Result := False
  end;{function List_O.IsEnd}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Procedure List_O.GoStart;
  begin
    pCurrent := pHead;
  end;{Procedure List_O.GoStart}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Procedure List_O.GoEnd;
  begin
    if pCurrent <> nil then
      while pCurrent.pNext <> nil do
        pCurrent := pCurrent.pNext;
  end;{Procedure List_O.GoEnd}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function List_O.GoPrev : boolean;
  var
    pTemp : Node_O;
  begin
    if (pCurrent <> nil) and (pCurrent <> pHead) then
    begin
      pTemp := pHead;
      while (pTemp.pNext <> pCurrent) and (pTemp <> nil) do
        pTemp := pTemp.pNext;

      pCurrent := pTemp;
      Result := True;
    end{if (pCurrent <> nil) and (pCurrent <> pHead)}
    else
      Result := False;

  end;{function List_O.GoPrev}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function List_O.GoNext : boolean;
  begin
    if (pCurrent <> nil) and (pCurrent.pNext <> nil) then
    begin
      pCurrent := pCurrent.pNext;
      Result := True;
    end
    else
      Result := False
  end;{function List_O.GoNext}


  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function List_O.Length : longint;
  var
    pTemp : Node_O;
  begin
    Result := 0;
    if pHead <> nil then
    begin
      pTemp := pHead;
      while pTemp <> nil do
      begin
        inc(Result);
        pTemp := pTemp.pNext;
      end;
    end;{if pHead <> nil}

  end;{function List_O.Length}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function List_O.Position;
  var
    pTemp : Node_O;
  begin
    Result := 0;
    if pCurrent <> nil then
    begin
      pTemp := pHead;
      Result := 1;
      while (pTemp <> nil) and (pTemp <> pCurrent) do
      begin
        inc(Result);
        pTemp := pTemp.pNext;
      end;{while (pTemp <> nil) and (pTemp <> pCurrent)}
    end;{if pCurrent <> nil}

  end;{function List_O.Position}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  destructor List_O.Destroy;
  var
    pTemp : Node_O;
  begin
    while pHead <> nil do
    {Repeat disposal while there is still a node pointed to}
    begin
      pTemp := pHead;
      pHead := pHead.pNext;
      {move to pNext node along and delete the first one}
      pTemp.Destroy;
    end;
{    pHead.Destroy;
    pCurrent.Destroy;
}
    inherited Destroy;

  end; {of destructor}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function List_O.FindPrevNode(pNode : Node_O) : Node_O;
  {Returns pointer to the node that comes before the node pointed by the
   pointer given in the argument, returns nil if not found}
  var
    pTemp : Node_O;
  begin
    Result := nil;
    if (pNode <> nil) and (pHead <> nil) and (pNode <> pHead) then
    begin
      pTemp := pHead;
      while (pTemp.pNext <> nil) and (Result = nil) do
        if pTemp.pNext = pNode then
          Result := pTemp
        else
          pTemp := pTemp.pNext;
    end;{if (pNode <> nil) and (pHead <> nil) and (pNode <> pHead)}

  end;{function AdjSite_O.FindPrevNode}

procedure List_O.NewHead(ptrData : pointer; iDataSize : integer);
var
   pTemp : Node_O;
begin
     pTemp := Node_O.create;
     {pTemp := }pTemp.init(iDataSize);
     if pCurrent = nil then
     begin
          pHead := pTemp;
          move(ptrData^,pTemp.pData,iDataSize);
{          hmemcpy(pTemp.pData,ptrData,iDataSize);}
          pTemp.pNext := NIL;
          pCurrent := pTemp;
     end
     else
     begin
          pTemp.pNext := pHead;
          move(ptrData^,pTemp.pData,iDataSize);
{          hmemcpy(pTemp.pData,ptrData,iDataSize);         }
          pCurrent := pTemp;
          pHead := pTemp;
     end;

end;
(* LINKED LIST OF LONGINTS  *)
constructor LongList_O.init;
begin
     inherited init(sizeof(longint));
     iDataSize := sizeof(longint);
end;

destructor LongList_o.Destroy;
begin
     inherited Destroy;
end;

Function LongList_O.AddNode(Data : Longint) : boolean;
begin
     Result := inherited Addnode(@Data,iDataSize);
end;{Function List_O.AddNode}

Function LongList_O.AmmendData(Data : Longint) : boolean;
begin
     Result := inherited AmmendData(@Data,iDataSize);
end;{Function List_O.AmmendData}

Function LongList_O.ReadData : Longint;
var
   blankptr : pointer;
begin
     new(blankptr);
     if pCurrent <> nil then
        blankptr := inherited ReadData;
     Result := longint(blankptr^);
end;{Function List_O.AmmendData}

procedure LongList_O.NewHead(Data : Longint);
begin
     inherited NewHead(@Data,iDataSize);
end;

(* LINKED LIST OF INTEGERS  *)
constructor IntList_O.init;
begin
     inherited init(sizeof(Integer));
     iDataSize := sizeof(Integer);
end;

destructor IntList_o.Destroy;
begin
     inherited Destroy;
end;

Function IntList_O.AddNode(Data : Integer) : boolean;
begin
     Result := inherited Addnode(@Data,iDataSize);
end;{Function List_O.AddNode}

Function IntList_O.AmmendData(Data : Integer) : boolean;
begin
     Result := inherited AmmendData(@Data,iDataSize);
end;{Function List_O.AmmendData}

Function IntList_O.ReadData : Integer;
var
   blankptr : pointer;
begin
     new(blankptr);
     if pCurrent <> nil then
        blankptr := inherited ReadData;
     Result := Integer(blankptr^);
end;{Function List_O.AmmendData}

procedure IntList_O.NewHead(Data : Integer);
begin
     inherited NewHead(@Data,iDataSize);
end;

(* LINKED LIST OF SingleS  *)
constructor SingleList_O.init;
begin
     inherited init(sizeof(Single));
     iDataSize := sizeof(Single);
end;

destructor SingleList_o.Destroy;
begin
     inherited Destroy;
end;

Function SingleList_O.AddNode(Data : Single) : boolean;
begin
     Result := inherited Addnode(@Data,iDataSize);
end;{Function List_O.AddNode}

Function SingleList_O.AmmendData(Data : Single) : boolean;
begin
     Result := inherited AmmendData(@Data,iDataSize);
end;{Function List_O.AmmendData}

Function SingleList_O.ReadData : Single;
var
   blankptr : pointer;
begin
     new(blankptr);
     if pCurrent <> nil then
        blankptr := inherited ReadData;
     Result := Single(blankptr^);
end;{Function List_O.AmmendData}

procedure SingleList_O.NewHead(Data : Single);
begin
     inherited NewHead(@Data,iDataSize);
end;

(* LINKED LIST OF RealS  *)
constructor RealList_O.init;
begin
     inherited init(sizeof(Real));
     iDataSize := sizeof(Real);
end;

destructor RealList_o.Destroy;
begin
     inherited Destroy;
end;

Function RealList_O.AddNode(Data : Real) : boolean;
begin
     Result := inherited Addnode(@Data,iDataSize);
end;{Function List_O.AddNode}

Function RealList_O.AmmendData(Data : Real) : boolean;
begin
     Result := inherited AmmendData(@Data,iDataSize);
end;{Function List_O.AmmendData}

Function RealList_O.ReadData : Real;
var
   blankptr : pointer;
begin
     new(blankptr);
     if pCurrent <> nil then
        blankptr := inherited ReadData;
     Result := Real(blankptr^);
end;{Function List_O.AmmendData}

procedure RealList_O.NewHead(Data : Real);
begin
     inherited NewHead(@Data,iDataSize);
end;

(* LINKED LIST OF WordS  *)
constructor WordList_O.init;
begin
     inherited init(sizeof(Word));
     iDataSize := sizeof(Word);
end;

destructor WordList_o.Destroy;
begin
     inherited Destroy;
end;

Function WordList_O.AddNode(Data : Word) : boolean;
begin
     Result := inherited Addnode(@Data,iDataSize);
end;{Function List_O.AddNode}

Function WordList_O.AmmendData(Data : Word) : boolean;
begin
     Result := inherited AmmendData(@Data,iDataSize);
end;{Function List_O.AmmendData}

Function WordList_O.ReadData : Word;
var
   blankptr : pointer;
begin
     new(blankptr);
     if pCurrent <> nil then
        blankptr := inherited ReadData;
     Result := Word(blankptr^);
end;{Function List_O.AmmendData}

procedure WordList_O.NewHead(Data : Word);
begin
     inherited NewHead(@Data,iDataSize);
end;

(* LINKED LIST OF ByteS  *)
constructor ByteList_O.init;
begin
     inherited init(sizeof(Byte));
     iDataSize := sizeof(Byte);
end;

destructor ByteList_o.Destroy;
begin
     inherited Destroy;
end;

Function ByteList_O.AddNode(Data : Byte) : boolean;
begin
     Result := inherited Addnode(@Data,iDataSize);
end;{Function List_O.AddNode}

Function ByteList_O.AmmendData(Data : Byte) : boolean;
begin
     Result := inherited AmmendData(@Data,iDataSize);
end;{Function List_O.AmmendData}

Function ByteList_O.ReadData : Byte;
var
   blankptr : pointer;
begin
     new(blankptr);
     if pCurrent <> nil then
        blankptr := inherited ReadData;
     Result := Byte(blankptr^);
end;{Function List_O.AmmendData}

procedure ByteList_O.NewHead(Data : Byte);
begin
     inherited NewHead(@Data,iDataSize);
end;

(* LINKED LIST OF BooleanS  *)
constructor BooleanList_O.init;
begin
     inherited init(sizeof(Boolean));
     iDataSize := sizeof(Boolean);
end;

destructor BooleanList_o.Destroy;
begin
     inherited Destroy;
end;

Function BooleanList_O.AddNode(Data : Boolean) : boolean;
begin
     Result := inherited Addnode(@Data,iDataSize);
end;{Function List_O.AddNode}

Function BooleanList_O.AmmendData(Data : Boolean) : boolean;
begin
     Result := inherited AmmendData(@Data,iDataSize);
end;{Function List_O.AmmendData}

Function BooleanList_O.ReadData : Boolean;
var
   blankptr : pointer;
begin
     new(blankptr);
     if pCurrent <> nil then
        blankptr := inherited ReadData;
     Result := Boolean(blankptr^);
end;{Function List_O.AmmendData}

procedure BooleanList_O.NewHead(Data : Boolean);
begin
     inherited NewHead(@Data,iDataSize);
end;

end. {unit Ulist}


