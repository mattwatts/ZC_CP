function LinkedList.toStringStream : tStringStream;
var
   sz : string;
   i : longint;
begin
     move(cStart);

     while not(atend) do
     begin
          sz := (ActiveNode as RangedNode).asString;
          i := length(sz);
          result.write(i,sizeof(i));
          result.writestring(sz);
     end;

     sz:= ActiveNode.asString;
end;


procedure LinkedList.insertbefore;
{Inserts a blank node, increasing 'elements', before the active node - move the
active node to this blank node}
begin
     if ActiveNode.Ancestor.ptrToNode <> nil then
     begin  {Inserting within a list segment}
          {Use the ancestor reference to source the node from which a new node
           can be created}
           ActiveNode.Ancestor.ptrToNode.setNodeN(1,Node.createLinked(ActiveNode.Links.lMaxSize));
           ActiveNode.Ancestor.ptrToNode.rtnNodeN(1).Ancestor.PtrToNode := ActiveNode.Ancestor.ptrToNode;
           ActiveNode.Ancestor.ptrToNode := ActiveNode.Ancestor.ptrToNode.rtnNodeN(1);
           ActiveNode.Ancestor.ptrToNode.setNodeN(1,ActiveNode);
           inc(elements);
           move(-1);
          {Create this new node with an appropriate ancestor}
          {Modify the ancestor linkage to them newly created node}
          {increase the element counter}
          {Move the active node to the correct location}
     end
     else
     begin  {We are trying to insert before the begining of the list}
{          ActiveNode.Ancestor := linkage.create;}
          ActiveNode.Ancestor.ptrToNode := Node.createLinked(ActiveNode.links.lMaxSize);
          {Re-link the ancestor linkage to a new node}
          {Set the startnode to this newly created node}
          StartNode := ActiveNode.Ancestor.ptrToNode;
{          StartNode.Ancestor.ptrToNode := NIL;}
          StartNode.setNodeN(1,ActiveNode);
          Move(-1);
          inc(elements);
          {Increase the counter}
          {Move the active node to this new node}
     end;
end;

procedure LinkedList.insertafter;
{Inserts a blank node, increasing 'elements', after the active node - move the
active node to this blank node}
var
   tmpLinkage : linkage;
   dat,dat2 : variant;

begin
{     links.rtn}
     ActiveNode.links.rtnValue(1,@tmpLinkage);
     if tmpLinkage.ptrToNode <> Nil then
     begin
          move(1);
          insertBefore;
     end
     else
     begin
          insertbefore;
//          TailNode := ActiveNode;
          move(1);
          dat := ActiveNode.data;
          move(-1);
          modify(dat);
          move(1);
          ActiveNode.data := dat2;
     end;
end;

procedure LinkedList.delete;
{Deletes the active node - moving it 'backwards' - modifing 'elements'}
begin
     if not(atStart) then
     begin
          if not(atEnd) then
          begin
               ActiveNode.Ancestor.ptrToNode.setNodeN(1,ActiveNode.rtnNodeN(1));

               ActiveNode.rtnNodeN(1).Ancestor.ptrToNode := ActiveNode.Ancestor.ptrToNode;

               move(1);
               dec(elements);
          end
          else
          begin
               TailNode := ActiveNode.Ancestor.ptrToNode;
               ActiveNode.destroy;
               ActiveNode := TailNode;
               ActiveNode.setNodeN(1,NIL);
               dec(elements);
          end;
     end
     else
     begin
          {Move StartNode to next node... - if possible otherwise just free the node}

          if elements > 1 then
          begin
               StartNode := ActiveNode.rtnNodeN(1);
               StartNode.Ancestor.ptrToNode := NIL;

               ActiveNode.destroy;

               ActiveNode := StartNode;
               dec(elements);
          end
          else
          begin
               ActiveNode.data := varempty;
               if elements > 1 then dec(elements);
          end;
     end;
end;


constructor LinkedList.create;
begin
     inherited create;

     ActiveNode := Node.createLinked(1);

     StartNode := ActiveNode;
     TailNode := StartNode;

     typeCast := '';

end;

constructor LinkedList.createsized(size : longint);
{Creates a single linked list consisting of a single node
(pointed to by both Active and Start) that has a data element of 'size' bytes}
begin
     create;

     ActiveNode := GenericNode.create(1,size);
     StartNode := ActiveNode;
     TailNode := ActiveNode
end;

constructor LinkedList.createtyped(szType : string);
var
   typeoption : integer;
   firstNode : boolean;

begin
     create;
     typeCast := sztype;
{     if self.ActiveNode = NIL then firstNode := TRUE else firstNode := FALSE;

     create;

     if (uppercase(szType) = 'LONGINT') then typeoption := 1
     else
         if (uppercase(szType) = 'REAL') then typeoption := 2
         else
              if (uppercase(szType) = 'OBJECT') then typeoption := 3
              else
                  typeoption := -1;


     case typeoption of
     1 : begin
              ActiveNode := LongintNode.create(1);
         end;

     2 : begin
              ActiveNode := RealNode.create(1);
         end;
     3 : begin
              ActiveNode := ObjectNode.create(1);
         end;
     else
         begin
              halt;
         end;
     end;

     if firstNode then
     begin
          ActiveNode.Ancestor.free;
          ActiveNode.Ancestor := NIL;
     end;

     StartNode := ActiveNode;
     TailNode := ActiveNode;

}
end;

destructor LinkedList.destroy;
begin
try
     if self <> nil then
     begin
          elements := 0;
          if ActiveNode <> nil then
          begin
               ActiveNode := TailNode;
               while not(atStart) do
               begin
                    TailNode := ActiveNode.Ancestor.ptrToNode;
                    ActiveNode.destroy;
                    ActiveNode := TailNode;
               end;

               ActiveNode.destroy;

               ActiveNode := Nil;
               StartNode := Nil;
               TailNode := Nil;
               inherited destroy;
          end
          else
              inherited destroy;
     end;
except on exception do
begin
     messagedlg('Error in LinkedList.Destroy',mtError,[mbOK],0);
end;
end;
end;

procedure LinkedList.Free;
begin
{          if ActiveNode <> nil then
          begin
               ActiveNode := TailNode;
               while not(atStart) do
               begin
                    TailNode := ActiveNode.Ancestor.ptrToNode;
                    ActiveNode.free;
                    ActiveNode := TailNode;
               end;

               ActiveNode.free;

               ActiveNode := StartNode;
               inherited free;
          end
          else
              inherited free;
}
     ActiveNode := TailNode;
     while not(ActiveNode = StartNode) do
     begin
          TailNode := ActiveNode.Ancestor.ptrToNode;
          ActiveNode.destroy;
     end;

     startNode.data := null;
     inherited free;

end;

procedure LinkedList.Draw;
{ Active := start
trueimageref = 0
repeat
      Active.drawImage
      Active.drawLinkages
      Active.next
until active.atend

if start <> finish
 Active.drawimage

}
begin
     if form2 = nil then form2 := tform2.create(Application);
     ActiveNode := StartNode;
     trueImageRef := 0;

     while not(atend)do
     begin
           ActiveNode.drawImage(TrueImageRef);
           move(1);
     end;

     ActiveNode.DrawImage(TrueImageRef);
     form2.update;

     ActiveNode := StartNode;

     while not(atend)do
     begin
           ActiveNode.drawLinkages;
           move(1);
     end;

     ActiveNode.drawLinkages;
end;

procedure LinkedList.modifyData(const ptrToStructure : tObject);
begin
     ActiveNode.data := longint(ptrToStructure);
end;

function LinkedList.rtnData : pointer;
begin
     result := pointer(longint(ActiveNode.data));
end;

function LinkedList.rtnObject : tObject;
begin
     result := tObject(rtnData);
end;

