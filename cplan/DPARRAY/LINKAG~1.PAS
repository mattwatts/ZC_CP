constructor Linkage.create;
begin
     inherited create;
     ptrToNode := Nil;
     ref := LinkageRef;
     inc(linkageRef);
end;

destructor Linkage.destroy;
begin
     if self <> nil then
     begin
          if ptrToNode <> nil then
          begin
               ptrToNode.Ancestor := nil;
               ptrToNode.destroy;
          end;
          inherited destroy;
     end;
end;

procedure Linkage.Free;
begin
     if ptrToNode <> NIL then
     begin
          ptrToNode.free;
          ptrToNode := NIL;
     inherited free;
     end;

end;

function Linkage.rtnNode : Node;
begin
     Result := ptrToNode;
end;


