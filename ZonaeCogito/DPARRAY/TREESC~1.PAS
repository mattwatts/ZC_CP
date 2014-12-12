constructor Trees.CreateTree(Linkages : longint);
begin
     inherited create;

     StartNode := Node.createlinked(linkages);
     ActiveNode := StartNode;
     TailNode := StartNode;
     defaultLinks := linkages;
end;

destructor Trees.Destroy;
begin
{     setfortraversal;

     while not(endoftraversal) do
     begin
          ActiveNode.destroy;
          nextposition;
     end;

     ActiveNode.destroy;
}
     inherited destroy;
end;

procedure Trees.setfortraversal;
var
   x : longint;
begin
     if ActiveNode.activelinks <> 0 then
     repeat
           for x := 1 to ActiveNode.links.lmaxsize do
           begin
                if ActiveNode.TestNodeN(x) then
                begin
                     ActiveNode := ActiveNode.rtnNodeN(x);
                     break;
                end;
           end;
     until ActiveNode.links = nil;
end;

procedure Trees.nextposition;
begin
     ActiveNode := StartNode;
     setfortraversal;
end;

function Trees.endoftraversal : boolean;
begin
     if ActiveNode = StartNode then result := TRUE else Result := FALSE;
end;


