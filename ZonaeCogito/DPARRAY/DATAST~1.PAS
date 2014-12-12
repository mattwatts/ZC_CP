constructor DataStructure.create;
begin
     inherited create;
end;

destructor DataStructure.destroy;
begin
     inherited destroy;
end;

procedure DataStructure.Free;
begin
     inherited free;
end;


constructor DataStructure.createlinked(links : longint);
begin
     create;
end;

procedure DataStructure.modify(data : variant);
var
   t : longint;
begin
     ActiveNode.data := data;
end;

procedure DataStructure.modifyData(const ptrToStructure : pointer);
begin
     ActiveNode.data := longint(ptrToStructure);
end;

procedure DataStructure.moveNode(NodeNumbers : olevariant);
{Move the active pointer in the given direction by the given # of nodes}
var
   x : integer;
   tmpNode : Node;
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
                    tmpNode := ActiveNode.rtnNodeN(NodeNumbers);
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
                         tmpNode := ActiveNode.rtnAncestorNode;
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

function DataStructure.rtnData : pointer;
begin
     result := pointer(longint(ActiveNode.data));
end;

function DataStructure.rtnObject : tObject;
begin
     result := tObject(rtnData);
end;


function DataStructure.atstart : boolean;
begin
     if StartNode = ActiveNode then
        Result := TRUE
     else
         Result := FALSE;
end;

function DataStructure.atend : boolean;
begin
     if TailNode = ActiveNode then
        Result := TRUE
     else
         Result := FALSE;
end;

function DataStructure.size : longint;
begin
     result := elements;
end;


