unit Featlist;

{Sets up a linked list}

interface

uses sitelist;
  type

      dataType = trueFeattype;

    pNode_T = ^Node_T;
    Node_T = record
               Data : DataType;
               pNext : pNode_T;
                    {HERE ADD ANY OTHER
                     FIELDS TO THE LIST
                     NODE}
             end;

    pList_T = ^ListFeat_O;
    ListFeat_O = class
                  pHead,
                  pCurrent : pNode_T;

                  constructor init;
                  Function  AddNode(Data : datatype) : boolean;
                  Function  DeleteNode : boolean;
                  Function  AmmendData(Data : datatype) : boolean;
                  Function  ReadData   : datatype;
                  Function  IsStart    : boolean;
                  Function  IsEnd      : boolean;
                  Procedure GoStart;
                  Procedure GoEnd;
                  Function  GoPrev     : boolean;
                  Function  GoNext     : boolean;
                  Function  Length     : longint;
                  Function  Position   : longint;
                  function  FindPrevNode(pNode : pNode_T) : pNode_T;
                  destructor clear;

                  procedure NewHead(Data : datatype);
                end;

implementation

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  {sets up a dummy node to start the list}
  constructor listfeat_o.init;
  begin
    pHead := nil;
    pCurrent := nil;
  end;{constructor init}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Function listfeat_o.AddNode(Data : dataType) : boolean;
  var
    pTemp : pNode_T;
  begin
    AddNode := True;
    pTemp := new(pNode_T);
    if pTemp <> nil then
      {allocation sucessful}
      if pCurrent = nil then
      {The Current pointer is pointing to the end meaning the list is empty}
      begin
        pHead := pTemp;
        pTemp^.Data := Data;
        pTemp^.pNext := nil;
        pCurrent := pTemp;
      end
      else
      {Start here if the list already has elements,
       add new node after current leaving pCurrent where it is}
      begin
        pTemp^.pNext := pCurrent^.pNext;
        pCurrent^.pNext := pTemp;
        pTemp^.Data := Data;
        pCurrent := pTemp;
      end{ELSEif pCurrent = nil}
    else
      {allocation unsucessful}
      AddNode := False;
  end;{Function listfeat_o.AddNode}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Function listfeat_o.DeleteNode : boolean;
  {Removes the node pointed by pCurrent}
  var
    pPrev : pNode_T;
  begin
    if pCurrent <> nil then {is list empty}
    begin
      {Find the node before pCurrent}
      pPrev := FindPrevNode(pCurrent);

      {is pCurrent pointing to first node}
      if pPrev = nil then
      begin {pCurrent is first node}
        pHead := pCurrent^.pNext;
        Dispose(pCurrent);
        pCurrent := pHead; {advance current pointer to new first node}
      end{if pPrev = nil}
      else
      begin {pCurrent is not first node}
        pPrev^.pNext := pCurrent^.pNext; {weave pointers around delete node}
        Dispose(pCurrent);
        pCurrent := pPrev; {current pointer is now the prev node}
      end;{ELSEif pPrev = nil}
      DeleteNode := True;
    end{if pCurrent <> nil}
    else
      DeleteNode := False;
  end;{Function listfeat_o.DeleteNode}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Function listfeat_o.AmmendData(Data : DataType) : boolean;
  begin
    AmmendData := True;
    if pCurrent <> nil then
      pCurrent^.Data := Data
    else
      AmmendData := False;
  end;{Function listfeat_o.AmmendData}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Function listfeat_o.ReadData : DataType;
  begin
    if pCurrent <> nil then
      ReadData := pCurrent^.Data
  end;{Function listfeat_o.AmmendData}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Function listfeat_o.IsStart : boolean;
  begin
    if pCurrent = pHead then
      IsStart := True
    else
      IsStart := False
  end;{Function listfeat_o.IsStart}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function listfeat_o.IsEnd : boolean;
  {The current node is at the end unless the list is not empty and the
   node following is not the last}
  begin
    IsEnd := True;
    if (pHead <> nil) and (pCurrent^.pNext <> nil) then
        IsEnd := False
  end;{function listfeat_o.IsEnd}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Procedure listfeat_o.GoStart;
  begin
    pCurrent := pHead;
  end;{Procedure listfeat_o.GoStart}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Procedure listfeat_o.GoEnd;
  begin
    if pCurrent <> nil then
      while pCurrent^.pNext <> nil do
        pCurrent := pCurrent^.pNext;
  end;{Procedure listfeat_o.GoEnd}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function listfeat_o.GoPrev : boolean;
  var
    pTemp : pNode_T;
  begin
    if (pCurrent <> nil) and (pCurrent <> pHead) then
    begin
      pTemp := pHead;
      while (pTemp^.pNext <> pCurrent) and (pTemp <> nil) do
        pTemp := pTemp^.pNext;

      pCurrent := pTemp;
      GoPrev := True;
    end{if (pCurrent <> nil) and (pCurrent <> pHead)}
    else
      GoPrev := False
  end;{function listfeat_o.GoPrev}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function listfeat_o.GoNext : boolean;
  begin
    if (pCurrent <> nil) and (pCurrent^.pNext <> nil) then
    begin
      pCurrent := pCurrent^.pNext;
      GoNext := True;
    end
    else
      GoNext := False
  end;{function listfeat_o.GoNext}


  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function listfeat_o.Length : longint;
  var
    pTemp : pNode_T;
  begin
    Result := 0;
    if pHead <> nil then
    begin
      pTemp := pHead;
      while pTemp <> nil do
      begin
        inc(Result);
        pTemp := pTemp^.pNext;
      end;
    end;{if pHead <> nil}
  end;{function listfeat_o.Length}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function listfeat_o.Position;
  var
    pTemp : pNode_T;
  begin
    Result := 0;
    if pCurrent <> nil then
    begin
      pTemp := pHead;
      Result := 1;
      while (pTemp <> nil) and (pTemp <> pCurrent) do
      begin
        inc(Result);
        pTemp := pTemp^.pNext;
      end;{while (pTemp <> nil) and (pTemp <> pCurrent)}
    end;{if pCurrent <> nil}
  end;{function listfeat_o.Position}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  destructor listfeat_o.clear;
  var
    pTemp : pNode_T;
  begin
    while pHead <> nil do
    {Repeat disposal while there is still a node pointed to}
    begin
      pTemp := pHead;
      pHead := pHead^.pNext;
      {move to pNext node along and delete the first one}
      dispose(pTemp);
    end;
    pHead := nil;
    pCurrent := nil
  end; {of destructor}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function listfeat_o.FindPrevNode(pNode : pNode_T) : pNode_T;
  {Returns pointer to the node that comes before the node pointed by the
   pointer given in the argument, returns nil if not found}
  var
    pTemp : pNode_T;
  begin
    Result := nil;
    if (pNode <> nil) and (pHead <> nil) and (pNode <> pHead) then
    begin
      pTemp := pHead;
      while (pTemp^.pNext <> nil) and (Result = nil) do
        if pTemp^.pNext = pNode then
          Result := pTemp
        else
          pTemp := pTemp^.pNext;
    end;{if (pNode <> nil) and (pHead <> nil) and (pNode <> pHead)}
  end;{function AdjSite_O.FindPrevNode}

procedure listfeat_o.NewHead(Data : datatype);
var
   pTemp : pNode_t;
begin
     new(pTemp);
     if pCurrent = nil then
     begin
          pHead := pTemp;
          pTemp^.Data := Data;
          pTemp^.pNext := NIL;
          pCurrent := pTemp;
     end
     else
     begin
          pTemp^.pNext := pHead;
          pTemp^.Data := Data;
          pCurrent := pTemp;
          pHead := pTemp;
     end;
end;
end. {unit Ulist}


