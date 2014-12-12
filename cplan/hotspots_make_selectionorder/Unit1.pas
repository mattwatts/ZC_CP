unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ds;

type
      trueFeatType = record
               iCode : integer;
               iIndex : integer;
      end;
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

  TForm1 = class(TForm)
    ListBox1: TListBox;
    btnLoadList: TButton;
    btnConvert: TButton;
    OpenDialog1: TOpenDialog;
    procedure btnLoadListClick(Sender: TObject);
    procedure btnConvertClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  SiteKeyArray : array_t;
  fSiteKeyArrayCreated : boolean;
  iSiteKeyArraySize : integer;

implementation

{$R *.DFM}
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


procedure TForm1.btnLoadListClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
        ListBox1.Items.LoadFromFile(OpenDialog1.Filename);
end;

function GetOutFileName(const sFile : string) : string;
begin
     Result := ExtractFilePath(sFile) + 'SelectionOrder.csv';
end;

procedure LoadSiteKeyArray(const sFile : string);
var
   InFile : TextFile;
   iSiteKey, iPos : integer;
   sLine, sTmp : string;
begin
     //
     iSiteKeyArraySize := 0;
     if not fSiteKeyArrayCreated then
     begin
          SiteKeyArray := Array_t.Create;
          SiteKeyArray.init(SizeOf(integer),10000);
     end;

     assignfile(InFile,sFile);
     reset(InFile);

     readln(InFile);
     readln(InFile);

     repeat
           readln(InFile,sLine);
           if (sLine <> '') then
           begin
                // extract column 2 from this line
                iPos := Pos(',',sLine);
                sTmp := Copy(sLine,iPos + 1,Length(sLine)-iPos);
                iPos := Pos(',',sTmp);
                sTmp := Copy(sTmp,1,iPos - 1);
                iSiteKey := StrToInt(sTmp);
                Inc(iSiteKeyArraySize);
                if (iSiteKeyArraySize > SiteKeyArray.lMaxSize) then
                   SiteKeyArray.resize(SiteKeyArray.lMaxSize + 10000);
                SiteKeyArray.setValue(iSiteKeyArraySize,@iSiteKey);
           end;

     until EOF(InFile);

     closefile(InFile);
end;

procedure ConvertFile(const sFile : string);
var
   InFile, OutFile : TextFile;
   sOutFile, sLine : string;
   iSiteKey : integer;
   OrdinalSiteArr : Array_t;
begin
     assignfile(InFile,sFile);
     reset(InFile);

     repeat
           readln(InFile,sLine);

     until (sLine = '***-----------separator-----------*** AvailKey End');

     sOutFile := GetOutFileName(sFile);
     assignfile(OutFile,sOutFile);
     rewrite(OutFile);
     writeln(OutFile,'SiteIndex');

     LoadSiteKeyArray(ExtractFilePath(sFile) + '0\sites0.csv');
     OrdinalSiteArr := SortFeatArray(SiteKeyArray);

     repeat
           readln(InFile,sLine);
           if (sLine <> '***-----------separator-----------*** NegotKey End') then
           begin
                // do a lookup to convert the site key to a site index
                iSiteKey := StrToInt(sLine);
                writeln(OutFile,IntToStr(findFeatMatch(OrdinalSiteArr,iSiteKey)));
           end;

     until (sLine = '***-----------separator-----------*** NegotKey End');

     OrdinalSiteArr.Destroy;

     closefile(InFile);
     closefile(OutFile);
end;

procedure TForm1.btnConvertClick(Sender: TObject);
var
   iCount : integer;
begin
     try
        Screen.Cursor := crHourglass;

        fSiteKeyArrayCreated := False;

        for iCount := 0 to (ListBox1.Items.Count-1) do
            ConvertFile(ListBox1.Items.Strings[iCount]);

        if fSiteKeyArrayCreated then
           SiteKeyArray.Destroy;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception performing file conversion',mtError,[mbOk],0);
     end;
end;

end.
