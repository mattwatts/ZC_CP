{$I fract2d.pas}
{$I fracteye.pas}
{$I fract.pas}


procedure Fractal.DrawState;
var
  Data : dData;
   blank : longint;
   canvasxmax : longint;
   ref1,ref2 : imagesqr;

function deCrypt : imagesqr;
var
   max : longint;
   cmax : longint;
   x : longint;

begin
     // setradius is called if needed - ie if there are too many possible nodes
       // to fit in a single line
     //the number of possible nodes is Links.lMAxSize ^ recLevel => x Position
     // RecLevel => Y Position

     max := 4;
     cmax := 4;

     case Data.RecLevel of

     1 : max := 1;
     2 : max := 4;
     3 : max := 9;
     4 : max := 30;
     5 : max := 80;
     end;

{     if max > 8 then
        Result.x1 := (CanvasXMax div ((max div 2)+1)) *(LevelOffsets[Data.RecLevel]+1)
     else }
        Result.x1 := (CanvasXMax div (max + 1 )) *(LevelOffsets[Data.RecLevel]+1);
     Result.y1 := (Data.RecLevel)*4*ActiveNode.radius;
end;

begin
     //using the drawingdata position and draw a node;
     canvasxmax := form2.clientwidth;

     ActiveNode.setRadius(10);
     blank := fractalnode(ActiveNode).SingleValue;
     ActiveNode.data := blank;
     inc(LevelOffsets[LevelRef]);
     Data.RecLevel := LevelRef;
     Data.NodeRef := BranchRef;
     ref1 := decrypt;
     ActiveNode.image(ref1);
     if LevelRef <> 1 then
     begin
          inc(LevelOffsets[LevelRef-1]);
          Data.RecLevel := Levelref-1;
          ref2 := decrypt;
          ActiveNode.imageLinks(ref1,ref2);
          ActiveNode.imageLable(ref1,ref2,OldBranchRef);
          dec(LevelOffsets[LevelRef-1]);

     end;
end;

procedure Webs.modifyData(const ptrToStructure : tObject);
begin
     ActiveNode.data := longint(ptrToStructure);
end;

function Webs.rtnData : pointer;
begin
     result := pointer(longint(ActiveNode.data));
end;


procedure Fractal.moveNode(NodeNumbers : olevariant);
{Move the active pointer in the given direction by the given # of nodes}
var
   x : integer;
   tmpNode : FractalNode;
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
//                    ActiveNode := TailNode;
                    messagedlg('Incorrect string for moving',mterror,[mbok],0);
                    halt;
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
               if NodeNumbers = ord(Reverse) then NodeNumbers := -1;

               if NodeNumbers > 0 then
               begin
                    tmpNode := FractalNode(ActiveNode.rtnNodeN(NodeNumbers));
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
                         tmpNode := FractalNode(ActiveNode.rtnAncestorNode);
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
//                    ActiveNode := TailNode;
                    messagedlg('I dont know how to handle',mterror,[mbok],0);
                    halt;
               end
               else
               begin
                    messagedlg('I dont know how to handle',mterror,[mbok],0);
                    halt;
               end;
          end;
     end;
end;

constructor Webs.create;
begin
     inherited create;

end;

destructor Webs.destroy;
begin

     inherited destroy;
end;

procedure Webs.Free;
begin

end;


procedure Fractal.RecurseWithProcedure(Proc : pointer);
begin
     inherited;
end;

procedure Webs.RecurseWithProcedure(Proc : pointer);
type
    proced = procedure;

var
   RecLevel : longint;
   ActiveBranch : longint;
   ProcedureToPerform : proced;
      a,c,d,e,f,g,h : longint;
   canvasxmax : longint;
   max : longint;
   x : longint;

   procedure recurse;
   var
      x,b : longint;
      tmpNode : Node;
      oldBranch : longint;
   begin
        inc(RecLevel);
        if ActiveNode.Links <> nil then
        begin
             for x := 1 to ActiveNode.Links.lMaxSize do
             begin
                  tmpNode := ActiveNode.rtnNodeN(x);
                  if tmpNode <> nil then
                  begin
                       ActiveBranch := x;
                       MoveNode(x);
                       Recurse;
                       MoveNode(-1);
                  end;
             end;
        end;
        LevelRef := RecLevel;
        BranchRef := ActiveBranch;
        //execute code
        oldBranchRef := activenode.pathref;
        ProcedureToPerform;
        dec(RecLevel);
   end;

begin
     RecLevel := 0;
     ActiveBranch := 0;
     ProcedureToPerform := (Proc);
     moveNode(cStart);

     recurse;

 end;


