procedure FractalEye.refresh;
begin

end;


procedure FractalEye.activate;
{
attach to the fractal at the app location and project the eye throughout the
node via it's projection technique (the standard 4 node projection).

from the start node,

repeat
      if the next image is not singular and the current image when derefed
      is not of zero variance
      begin
        for x := 1 to # of Nodes to project
        project each node
      end
      else
      begin
           add to the list of leaves
           project onto the screen
      end
until no more node to project
}
var
   x,y : longint;
   newField : square_t;
   NodeList : linkedList;
   templist : linkedList;
   fin : boolean;
   fractNode : fractalNode;
   EyeList : linkedList;

begin
     NodeList := LinkedList.create;
     EyeList := linkedList.create;

     moveNode(cStart);
     StartSpace.moveNode(cStart);

     NodeList.modifydata(StartSpace.ActiveNode);
     EyeList.modifyData(ActiveNode);

           Repeat
                 fractNode := fractalnode(NodeList.rtnData);
                 ActiveNode := FractalNode(EyeList.rtnData);
                 if (fractNode.Variance <> 0) then
                 begin
                      for x := ord(bottomleft) to ord(topright) do
                      begin
                           newField := ActiveNode.Field.TransformData(TwoDTransformation(x));
                           ActivateNode(x,newfield);   {Creates the new node in the fractaleye}
                           moveNode(x);
                           StartSpace.enclose(ActiveNode.Field);
                           modifydata(StartSpace.ActiveNode);      {Hooks the data as a pointer to the True fractal space}

                           NodeList.moveNode(cEnd);
                           NodeList.insertAfter;
                           NodeList.modifyData(StartSpace.ActiveNode);

//Insert at tail of eyelist
                           EyeList.moveNode(cEnd);
                           EyeList.insertafter;
                           EyeList.modifydata(ActiveNode);

                           moveNode(-1);
                      end;
                 end
                 else
                 begin
                      ActiveNode.displayspace;
                      //draw this space
                 end;
//Remove The first Node of the eyeList since it has been fully used
                 EyeList.moveNode(cStart);
                 if not(EyeList.atEnd) then EyeList.delete else EyeList.ActiveNode.data := Null;

                 NodeList.moveNode(cStart);
                 if not(NodeList.atEnd) then NodeList.delete else NodeList.ActiveNode.data := Null;
//                 if NodeList.atend then fin := true else NodeList.moveNode(1);

                 NodeList.moveNode(cStart);
                 EyeList.moveNode(cStart);
           Until NodeList.ActiveNode.data = Null;
     NodeList.destroy;
     EyeList.destroy;
end;

procedure FractalEye.modifyData(const ptrToStructure : pointer);
begin
     ActiveNode.data := longint(ptrToStructure);
end;

function FractalEye.rtnData : pointer;
begin
     result := pointer(longint(ActiveNode.data));
end;

function FractalEye.rtnObject : tObject;
begin
     result := tObject(rtnData);
end;

procedure FractalEye.attachto(var Fract : Fractal);
{  This procedure should attach to the appropriate location ie nodal position
of the Fract
}
begin
     Fract.moveNode(cstart);
     Fract.enclose(ActiveNode.field);
     modifydata(Fract.ActiveNode);
     StartSpace.ActiveNode := fractalNode(rtnData);
     StartSpace.StartNode := StartSpace.ActiveNode;
end;

constructor FractalEye.create(Init : square_T);
begin
     inherited create;
     StartSpace := fractal.create;
     ActiveNode.field.setValues(init);
end;

destructor FractalEye.destroy;
begin
     inherited destroy;
end;

procedure FractalEye.ActivateNode(N : longint; sq : square_t);
var
   BlankNode : fractalNode;

begin
     ActiveNode.SetNodeN(N,FractalNode.create(TwoDimensions));
     BlankNode := FractalNode(ActiveNode.rtnNodeN(N));
     BlankNode.Ancestor.ptrToNode := ActiveNode;
     BlankNode.field.data := sq;
     inc(elements);
end;

