constructor RangedList.create(pages : longint; var DataBlock : pointer);
begin
     inherited create;

     StartNode := nil;
     TailNode := nil;
     ActiveNode := nil;

     ActiveNode := RangedNode.create;
     StartNode := ActiveNode;
     TailNode := ActiveNode;

     lListPages := pages;
     ContigDataBlock := DataBlock;

end;

destructor RangedList.destroy;
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
                    TailNode := RangedNode(ActiveNode.Ancestor.ptrToNode);
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

procedure RangedList.free;
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
                    TailNode := RangedNode(ActiveNode.Ancestor.ptrToNode);
                    ActiveNode.free;
                    ActiveNode := TailNode;
               end;

               ActiveNode.free;
          end;
     end;
except on exception do
begin
     messagedlg('Error in LinkedList.Destroy',mtError,[mbOK],0);
end;
end;
end;

procedure RangedList.Draw;
begin
     if form2 = nil then form2 := tform2.create(Application);
     form2.show;
     ActiveNode := StartNode;
     trueImageRef := 0;

     while not(atend)do
     begin
           ActiveNode.drawImage(TrueImageRef);
           moveNode(1);
     end;

     ActiveNode.DrawImage(TrueImageRef);
     form2.update;

     ActiveNode := StartNode;

     while not(atend)do
     begin
           ActiveNode.drawLinkages;
           moveNode(1);
     end;

     ActiveNode.drawLinkages;
end;

function RangedList.atstart : boolean;
begin
     if StartNode = ActiveNode then
        Result := TRUE
     else
         Result := FALSE;
end;

function RangedList.atend : boolean;
begin
     if TailNode = ActiveNode then
        Result := TRUE
     else
         Result := FALSE;
end;

procedure RangedList.delete;
{Deletes the active node - moving it 'backwards' - modifing 'elements'}
var
   tmpnode : RangedNode;

begin
     if not(atStart) then
     begin
          if not(atEnd) then
          begin
               ActiveNode.Ancestor.ptrToNode.setNodeN(1,ActiveNode.rtnNodeN(1));
               ActiveNode.rtnNodeN(1).Ancestor.ptrToNode := ActiveNode.Ancestor.ptrToNode;
               ActiveNode.Ancestor.ptrToNode := nil;
               ActiveNode.setNodeN(1,Nil);
               ActiveNode.destroy;
               dec(elements);
          end
          else
          begin
               moveNode(-1);
               TailNode := ActiveNode;
               moveNode(1);
//               TailNode := rangednode(ActiveNode.Ancestor.ptrToNode);
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

procedure RangedList.remove;
{Deletes the active node - moving it 'backwards' - modifing 'elements'}
var
   tmpnode : RangedNode;

begin
     if not(atStart) then
     begin
          if not(atEnd) then
          begin
               ActiveNode.Ancestor.ptrToNode.setNodeN(1,ActiveNode.rtnNodeN(1));
               ActiveNode.rtnNodeN(1).Ancestor.ptrToNode := ActiveNode.Ancestor.ptrToNode;
               ActiveNode.Ancestor.ptrToNode := nil;
               ActiveNode.setNodeN(1,Nil);
               ActiveNode.remove;
               dec(elements);
          end
          else
          begin
               moveNode(-1);
               TailNode := ActiveNode;
               moveNode(1);
//               TailNode := rangednode(ActiveNode.Ancestor.ptrToNode);
               ActiveNode.remove;
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

               ActiveNode.remove;

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

function RangedList.withinany(ref : variant; limit : longint) : boolean;
var
   count : longint;
begin
     Result := FALSE;
     moveNode(cstart);
     if ActiveNode.within(Ref) then begin Result := TRUE; exit; end;
     count := 1;
     while not(Atend) do
     begin
          if count = limit then break;
          moveNode(1);
          inc(count);
           if ActiveNode.within(ref) then
           begin
                Result := True;
                break;
           end;
     end;

end;

procedure RangedList.insertbefore;
{Inserts a blank node, increasing 'elements', before the active node - move the
active node to this blank node}
var
   tmpNode : rangedNode;
begin
     if ActiveNode.Ancestor.ptrToNode <> nil then
     begin  {Inserting within a list segment}
          {Use the ancestor reference to source the node from which a new node
           can be created}
           ActiveNode.Ancestor.ptrToNode.setNodeN(1,RangedNode.create);
           ActiveNode.Ancestor.ptrToNode.rtnNodeN(1).Ancestor.PtrToNode := ActiveNode.Ancestor.ptrToNode;
           ActiveNode.Ancestor.ptrToNode := ActiveNode.Ancestor.ptrToNode.rtnNodeN(1);
           ActiveNode.Ancestor.ptrToNode.setNodeN(1,ActiveNode);
           inc(elements);
           moveNode(-1);
          {Create this new node with an appropriate ancestor}
          {Modify the ancestor linkage to them newly created node}
          {increase the element counter}
          {Move the active node to the correct location}
     end
     else
     begin  {We are trying to insert before the begining of the list}
{          ActiveNode.Ancestor := linkage.create;}
          RangedNode(ActiveNode.Ancestor.ptrToNode) := RangedNode.create;
          {Re-link the ancestor linkage to a new node}
          {Set the startnode to this newly created node}
          StartNode := RangedNode(ActiveNode.Ancestor.ptrToNode);
{          StartNode.Ancestor.ptrToNode := NIL;}
          tmpNode := ActiveNode;
          MoveNode(-1);
          ActiveNode.setNodeN(1,TmpNode);
          inc(elements);
          {Increase the counter}
          {Move the active node to this new node}
     end;
end;

procedure RangedList.Movewithin(Ref : variant);
begin
     moveNode(cStart);
     moveNode(1);
     while not(atend) do
     begin
          if ((Ref >= ActiveNode.startdata) and (ref <= ActiveNode.enddata)) then
          begin
               exit;
          end;
          moveNode(1);
     end;

     if ((Ref >= ActiveNode.startdata) and (ref <= ActiveNode.enddata)) then
     begin

     end
     else
     begin
          //not found within list
          messagedlg('error trying to locate element '+inttostr(longint(ref)),mterror,[mbok],0);
     end;
end;

procedure RangedList.insertAfter;
{Inserts a blank node, increasing 'elements', after the active node - move the
active node to this blank node}
var
   tmpLinkage : linkage;
   dat,dat2 : variant;
   oldNode : RangedNode;

begin
{     links.rtn}
     ActiveNode.links.rtnValue(1,@tmpLinkage);
     if tmpLinkage.ptrToNode <> Nil then
     begin
          moveNode(1);
          insertBefore;
     end
     else
     begin
          ActiveNode.setNodeN(1,RangedNode.create);
          oldNode := ActiveNode;
          moveNode(1);
          RangedNode(ActiveNode.Ancestor.ptrToNode) := oldNode;
          TailNode := ActiveNode;
          inc(elements);
{          insertbefore;
          moveNode(1);               }
//          move(pointer(ActiveNode)^,pointer(ActiveNode.Ancestor.ptrToNode)^,ActiveNode.instanceSize)

     end;
//     draw;
end;

constructor RangedNode.create;
begin
//     inherited create;
{     Links := array_t.create;
     Ancestor := Linkage.create;

     Radius := BaseRadius;
     NodeRefNum := NodeMarker;
     inc(NodeMarker);
}
     inherited createlinked(1);

     StartData := Null;
     EndData := Null;
                                
     ptrData := nil;
     fModified := true;
     szFileName := uniquefilename(baselocation);
end;

procedure drawimage(var Ref : longint);
begin

end;

function RangedNode.asString : string;
begin
try
     Result := ' ' + string(StartData) + '  ' + string(EndData) + ' ';
except on exception do result := 'Error converting data to string';
end;
end;

destructor RangedNode.destroy;
begin
     StartData := Null;
     EndData := Null;

     ptrData := Nil;
     if fileexists(szFileName) then deletefile(szFileName);
     inherited;
end;

destructor RangedNode.remove;
begin
     StartData := Null;
     EndData := Null;

     ptrData := Nil;
     inherited destroy;
end;

procedure RangedNode.free;
begin
     StartData := Null;
     EndData := Null;

     ptrData := Nil;
     if fileexists(szFileName) then deletefile(szFileName);
     inherited;
end;

function RangedNode.rtnAncestorNode : RangedNode;
begin
     Result := RangedNode(Ancestor.rtnNode);
end;

function RangedNode.rtnNodeN(N : longint) : RangedNode;
var
   ActiveLink : Linkage;
begin
     Links.rtnValue(N,@ActiveLink);
     Result :=rangedNode( ActiveLink.ptrToNode);
end;

procedure RangedNode.SetNodeN(N : longint; const tmpNode : Rangednode);
var
   ActiveLink : Linkage;
begin
     if self = nil then exit;
     Links.rtnValue(N,@ActiveLink);
     RangedNode(ActiveLink.ptrToNode) := tmpNode;
end;

procedure RangedNode.image(ref : imagesqr);
{Draws ellipse and writes data}
begin
     DrawCircle(ref.x1,ref.y1,radius);
     writeText(ref.x1-radius div 4,ref.y1-radius div 3,asstring);
end;

{
procedure RangedNode.free;
begin
     StartData := Null;
     EndData := Null;
end;
}
function RangedNode.within(Value : variant) : boolean;
begin
     if (Value <= EndData) and (Value >= StartData) then
         result := TRUE
     else
         result := FALSE;
end;

procedure RangedNode.setdata(startpoint,endpoint : variant);
begin
     StartData := StartPoint;
     EndData := EndPoint;
end;
procedure RangedList.moveNode(NodeNumbers : olevariant);
{Move the active pointer in the given direction by the given # of nodes}
var
   x : integer;
   tmpNode : RangedNode;
   sztmp : string;
   res : integer;

begin
     res := vartype(NodeNumbers);
     if (res = 8) then    //ie a string
     begin
          if string(NodeNumbers) = cStart then
          begin
               ActiveNode := StartNode;
          end
          else
          begin
               if string(NodeNumbers) = cEnd then
               begin
                    ActiveNode := TailNode;
               end
               else
               begin
                    messagedlg('Incorrect string for moving',mterror,[mbok],0);
                    halt;
               end;
          end;

     end
     else
     begin
          if res = varinteger then
          begin
               if NodeNumbers > 0 then
               begin
                    tmpNode := RangedNode(ActiveNode.rtnNodeN(NodeNumbers));
                    if tmpNode <> nil then
                       ActiveNode := tmpNode
                    else
                    begin
                         messagedlg('Incorrect Index for movement',mterror,[mbok],0);
                         halt;
                    end;
               end
               else
               begin
                    if NodeNumbers < 0 then
                    for x := 1 to round(abs(NodeNumbers)) do
                    begin
                         tmpNode := RangedNode(ActiveNode.rtnAncestorNode);
                         if tmpNode <> nil then
                            ActiveNode := tmpNode
                         else
                             break;
                    end
                    else
                    begin
                         ActiveNode := StartNode;
                    end;
               end;
          end
          else
          begin
               if NodeNumbers = 0.0 then
               begin
                    ActiveNode := TailNode;
               end
               else
               begin
                    messagedlg('I dont know how to handle',mterror,[mbok],0);
                    halt;
               end;
          end;
     end;
end;

