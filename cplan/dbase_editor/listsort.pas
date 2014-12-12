unit listsort;

interface

uses
    ds;

  type
      trueSiteType = record
               szGeoCode : string[255];
               iIndex : integer;
      end;

      trueFeatType = record
               iCode : integer;
               iIndex : integer;
      end;



      SiteDataType = trueSitetype;

    pSiteNode_T = ^SiteNode_T;
    SiteNode_T = record
               Data : SiteDataType;
               pNext : pSiteNode_T;
                    {HERE ADD ANY OTHER
                     FIELDS TO THE LIST
                     NODE}
             end;

    pSiteList_T = ^ListSite_O;
    ListSite_O = class
                  pHead,
                  pCurrent : pSiteNode_T;

                  constructor init;
                  Function  AddNode(Data : SiteDataType) : boolean;
                  Function  DeleteNode : boolean;
                  Function  AmmendData(Data : SiteDataType) : boolean;
                  Function  ReadData   : SiteDataType;
                  Function  IsStart    : boolean;
                  Function  IsEnd      : boolean;
                  Procedure GoStart;
                  Procedure GoEnd;
                  Function  GoPrev     : boolean;
                  Function  GoNext     : boolean;
                  Function  Length     : longint;
                  Function  Position   : longint;
                  function  FindPrevNode(pNode : pSiteNode_T) : pSiteNode_T;
                  destructor clear;

                  procedure NewHead(Data : SiteDataType);
                end;

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
procedure TestUniqueFloatArray(SortArray : array_t;
                               const sDataStructure : string);


implementation

uses
    Wintypes, winprocs,dialogs,sysutils,
    Forms, Controls, reallist;


  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  {sets up a dummy node to start the list}
  constructor listsite_o.init;
  begin
    pHead := nil;
    pCurrent := nil;
  end;{constructor init}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Function listsite_o.AddNode(Data : SiteDataType) : boolean;
  var
    pTemp : pSiteNode_T;
  begin
    AddNode := True;
    pTemp := new(pSiteNode_T);
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
  end;{Function listsite_o.AddNode}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Function listsite_o.DeleteNode : boolean;
  {Removes the node pointed by pCurrent}
  var
    pPrev : pSiteNode_T;
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
  end;{Function listsite_o.DeleteNode}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Function listsite_o.AmmendData(Data : SiteDataType) : boolean;
  begin
    AmmendData := True;
    if pCurrent <> nil then
      pCurrent^.Data := Data
    else
      AmmendData := False;
  end;{Function listsite_o.AmmendData}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Function listsite_o.ReadData : SiteDataType;
  begin
    if pCurrent <> nil then
      ReadData := pCurrent^.Data
  end;{Function listsite_o.AmmendData}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Function listsite_o.IsStart : boolean;
  begin
    if pCurrent = pHead then
      IsStart := True
    else
      IsStart := False
  end;{Function listsite_o.IsStart}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function listsite_o.IsEnd : boolean;
  {The current node is at the end unless the list is not empty and the
   node following is not the last}
  begin
    IsEnd := True;
    if (pHead <> nil) and (pCurrent^.pNext <> nil) then
        IsEnd := False
  end;{function listsite_o.IsEnd}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Procedure listsite_o.GoStart;
  begin
    pCurrent := pHead;
  end;{Procedure listsite_o.GoStart}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  Procedure listsite_o.GoEnd;
  begin
    if pCurrent <> nil then
      while pCurrent^.pNext <> nil do
        pCurrent := pCurrent^.pNext;
  end;{Procedure listsite_o.GoEnd}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function listsite_o.GoPrev : boolean;
  var
    pTemp : pSiteNode_T;
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
  end;{function listsite_o.GoPrev}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function listsite_o.GoNext : boolean;
  begin
    if (pCurrent <> nil) and (pCurrent^.pNext <> nil) then
    begin
      pCurrent := pCurrent^.pNext;
      GoNext := True;
    end
    else
      GoNext := False
  end;{function listsite_o.GoNext}


  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function listsite_o.Length : longint;
  var
    pTemp : pSiteNode_T;
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
  end;{function listsite_o.Length}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  function listsite_o.Position;
  var
    pTemp : pSiteNode_T;
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
  end;{function listsite_o.Position}

  {xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}
  destructor listsite_o.clear;
  var
    pTemp : pSiteNode_T;
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
  function listsite_o.FindPrevNode(pNode : pSiteNode_T) : pSiteNode_T;
  {Returns pointer to the node that comes before the node pointed by the
   pointer given in the argument, returns nil if not found}
  var
    pTemp : pSiteNode_T;
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

procedure listsite_o.NewHead(Data : SiteDataType);
var
   pTemp : pSiteNode_t;
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

function SortIntegerArray(const unsortedArray_C : array_t) : array_t;
begin
     Result := SortFeatArray(unsortedArray_C);
end;

function findIntegerMatch(SortArray : array_t; RecordtoMatch : longint) : integer;
begin
     Result := findFeatMatch(SortArray, RecordtoMatch);
end;

procedure TestUniqueIntArray(SortArray : array_t;
                             const sDataStructure : string);
type

      datatype = trueFeattype;

var
   value : datatype;
   iCount, iPreviousKey : integer;
   fFail : boolean;
   {$IFDEF UNIQUE_TEST}
   DebugFile : Text;
   {$ENDIF}
begin
     if (SortArray.lMaxSize > 0) then
     try
        {$IFDEF UNIQUE_TEST}
        try
           assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\unique_test.csv');
           rewrite(DebugFile);
        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in TestUniqueIntArray rewriting debug file',mtError,[mbOk],0);
        end;
        {$ENDIF}

        fFail := False;
        SortArray.rtnValue(1,@value);
        iPreviousKey := value.iCode;
        {$IFDEF UNIQUE_TEST}
        try
           writeln(DebugFile,'index,value');
           writeln(DebugFile,'1,' + IntToStr(iPreviousKey));
        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in TestUniqueIntArray writing to debug file',mtError,[mbOk],0);
        end;
        {$ENDIF}
        if (SortArray.lMaxSize > 1) then
           for iCount := 2 to SortArray.lMaxSize do
           begin
                SortArray.rtnValue(iCount,@value);

                {set fFail to false if current key is the same as the previous key}
                if (value.iCode = iPreviousKey) then
                   fFail := True;

                iPreviousKey := value.iCode;

                {$IFDEF UNIQUE_TEST}
                try
                   writeln(DebugFile,IntToStr(iCount) + ',' + IntToStr(iPreviousKey));
                except
                      Screen.Cursor := crDefault;
                      MessageDlg('Exception in TestUniqueIntArray writing to debug file',mtError,[mbOk],0);
                end;
                {$ENDIF}
           end;

        {$IFDEF UNIQUE_TEST}
        try
           closefile(DebugFile);
        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in TestUniqueIntArray closing debug file',mtError,[mbOk],0);
        end;
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
begin
     if (SortArray.lMaxSize > 0) then
     try
        fFail := False;
        SortArray.rtnValue(1,@value);
        sPreviousKey := value.szGeoCode;
        if (SortArray.lMaxSize > 1) then
           for iCount := 2 to SortArray.lMaxSize do
           begin
                SortArray.rtnValue(iCount,@value);

                {set fFail to false if current key is the same as the previous key}
                if (value.szGeoCode = sPreviousKey) then
                   fFail := True;

                sPreviousKey := value.szGeoCode;
           end;

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
procedure TestUniqueFloatArray(SortArray : array_t;
                               const sDataStructure : string);
type

      datatype = trueFloattype;

var
   value : datatype;
   iCount : integer;
   rPreviousKey : extended;
   fFail : boolean;
begin
     if (SortArray.lMaxSize > 0) then
     try
        fFail := False;
        SortArray.rtnValue(1,@value);
        rPreviousKey := value.rValue;
        if (SortArray.lMaxSize > 1) then
           for iCount := 2 to SortArray.lMaxSize do
           begin
                SortArray.rtnValue(iCount,@value);

                {set fFail to false if current key is the same as the previous key}
                if (value.rValue = rPreviousKey) then
                   fFail := True;

                rPreviousKey := value.rValue;
           end;

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
           MessageDlg('Exception in TestUniqueFloatArray',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
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

     SortedList.clear;
end;


function findFeatMatch(SortArray : array_t; RecordtoMatch : longint) : integer;
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
     Result := Value.iIndex;
end;



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

     SortedList.clear;
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
        //Result := Value.iIndex
     else
         Result := -1;
end;



end.
