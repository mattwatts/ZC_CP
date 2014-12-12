function fractal.deref(sq : square_t) : longint;
var
   dir : TwoDTransformation;
begin
     ActiveNode := StartNode;

     dir := direct2d(sq,ActiveNode.field.data);

     if ActiveNode.Variance <> 0 then
     while dir <> nothing do
     begin
          moveNode(dir);
          if ActiveNode.Variance <> 0 then
          dir := direct2d(sq,ActiveNode.field.data)
          else
          break;
     end;

     Result := ActiveNode.SingleValue;
end;

procedure Fractal.ActivateNode(N : longint; sq : square_t);
var
   BlankNode : fractalNode;

begin
     ActiveNode.SetNodeN(N,FractalNode.create(TwoDimensions));
     BlankNode := FractalNode(ActiveNode.rtnNodeN(N));
     BlankNode.Ancestor.ptrToNode := ActiveNode;
     BlankNode.field.data := sq;
     inc(elements);
end;


function Fractal.lastLeaf : FractalNode;
var
   tempNode : fractalNode;
   x : longint;
begin
     tempNode := (ActiveNode as FractalNode);
     Result := (ActiveNode as FractalNode);
     repeat
           for x := 1 to tempNode.Links.lMaxSize do
           begin
                tempNode := fractalNode(Result.rtnNodeN(x));
                if tempNode <> nil then
                begin
                     Result := tempNode;
                     break;
                end;
           end;
     until tempNode = NIL;
end;

constructor Fractal.create;
var
   x : longint;
begin
     inherited create;

     ActiveNode := FractalNode.create(TwoDimensions);
     elements := 1;

     StartNode := ActiveNode;
     TailNode := StartNode;

     maxLinkages := 4;

     for x := 1 to 10 do
     leveloffsets[x] := -1;
end;

destructor Fractal.destroy;
begin
     if self <> nil then
     begin
          if ActiveNode <> nil then
          begin
               {Traverse the fractal destroying all nodes until the active node
                is finally at the start node}
               while not(atStart) do
               begin

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
end;

procedure Fractal.Free;
begin
     inherited free;
end;
