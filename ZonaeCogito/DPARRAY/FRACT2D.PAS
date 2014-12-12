procedure Fractal.movedir(whichway : TwoDTransformation);
function derref : longint;
begin
     result := -1;
end;
begin
     moveNode(derref);
end;

procedure Fractal.enclose(field : TwoDimData);
{this procedure moves the active node to an all inclusive surround of the
 passed field}
var
   dir,dir2 : twodtransformation;
   fin : boolean;
begin
     fin := false;
     if not(ActiveNode.field.sameas(field.data)) then
     repeat
//           dir := ActiveNode.field.whichway(field.data);
           dir := direct2d(field.data,ActiveNode.field.data);
           if ((dir < reverse) and (dir > topLeft)) then
           dir := reverse;
{           if dir <> dir2 then
           begin
                fin := TRUE;

           end;
}
           moveNode(dir)
     until ActiveNode.field.sameas(field.data);
end;

procedure Fractal.enclosefrom(field : TwoDimData);
{this procedure moves the active node from a defined position to an all
inclusive surround of the passed field}
begin

end;

procedure Fractal.Build(level : longint);
const
     lScope = 1024;
var
   x,y : longint;
   newField : square_t;
   NodeList,NewNodes : linkedList;
   fin : boolean;

begin
     (ActiveNode as FractalNode).Field.definedata(1,1,lScope); {Sets the initial node to 1,1,->fractalsize}

     NodeList := LinkedList.create;
     NewNodes := LinkedList.create;

     NodeList.modifydata(ActiveNode);
    Repeat
           NewNodes.modify(longint(Nil));
           fin := false;
           Repeat
                 ActiveNode := NodeList.rtnData;
                 for x := 0 to 3 do
                 begin
                      newField := (ActiveNode as FractalNode).Field.TransformData(TwoDTransformation(x));
                      ActivateNode(x+1,newfield);   {Creates the new node in the fractal}
                      newNodes.modifyData(ActiveNode.rtnNodeN(x+1));
                      newNodes.insertAfter;
                 end;
                 if NodeList.atend then fin := true else NodeList.moveNode(1);
           Until fin;
           if NewNodes.elements > 1 then NewNodes.delete else fin := FALSE;

           if not(fin) then
           begin
{                switch leaves and NodeList}
           end;

           while not(NodeList.atStart) do
           begin
                NodeList.delete;
           end;
           NodeList.ActiveNode.data := longint(Nil);

           NewNodes.moveNode(cStart);
           NodeList.modifyData(NewNodes.rtnData);

           while not(NewNodes.atEnd) do
           begin
                NewNodes.moveNode(1);
                NodeList.insertAfter;
                NodeList.modifyData(NewNodes.rtnData);
           end;

           while not(newNodes.atStart) do
           begin
                newNodes.delete;
           end;

           NodeList.moveNode(cStart);

           dec(level);
     Until ((NodeList.ActiveNode.data = longint(Nil)) or (level <= 1));


     NodeList.destroy;
     NewNodes.destroy;
(*
     ActiveNode.Field.definedata(1,1,1024); {Sets the initial node to 1,1,->fractalsize}

     for y := 2 to level do
     begin
          for x := 0 to 3 do
          begin
               newField := ActiveNode.Field.TransformData(TwoDTransformation(x));
               ActivateNode(x+1,newfield);   {Creates the new node in the fractal}
          end;
     end;
*)
end;

function Fractal.bounded(x,y : longint) : longint;
begin
     if x > y then result := x else result := y;
end;

procedure Fractal.ParseAndCreate(lScope : longint);
(*
**************************ALGORITHM*********************************************
{    Repeat
           NewNodes := Nil

           Scan and Deal with NodeList wrt Similar Nodes

           Repeat
                 If content not the same then
                 begin
                      split and add to newNode list
                 end
                 else
                 begin
                      Set Appr Values
                 end
                 Delete Node from nodelist
           Until No Nodes left in NodeList

           NodeList := NewNodes
     Until No New Nodes
}
*)
var
   NodeList : LinkedList;
   NewNodes : LinkedList;
   BlankNode : FractalNode;
   x,l : longint;
   newField : square_t;
   fin : boolean;
   f : boolean;

   function Within(X,Y : longint) : boolean;
   begin
        Result := True;

        if (newField.x1 > X) then
        begin
             Result := FALSE;
             exit;
        end;
{        if (newField.x2 > X) then
        begin
             Result := FALSE;
             exit;
        end;  }
        if newField.y1 > Y then
        begin
             Result := FALSE;
             exit;
        end;
{        if newField.y2 > Y then
        begin
             Result := FALSE;
             exit;
        end;}
   end;

   function comparefields(where : string; field1,field2 :twoDimData) : boolean;
   begin

   end;

   procedure ScanForSimilarNodes;
   var
      thisNode : fractalNode;
      nextNode : fractalNode;
   begin
        {
         Trace through all the nodes in the NodeList comparing fields from disk
         - handle in the event of finding a match
        }
         while not(NodeList.atEnd) do
         begin
              thisNode := NodeList.rtnData;
              nextNode := pointer(longint(NodeList.ActiveNode.rtnNodeN(1).data));
              if compareFields('DISK',FractalNode(pointer(longint(NodeList.ActiveNode.data))).field,
                                        nextnode.field) then
              begin
                   {Adjust Structure}
              end
              else
              begin
                   {Don't do anything}
              end;
              NodeList.moveNode(1);
         end;

         NodeList.moveNode(cStart);
   end;

   function SameThroughout : boolean;
   var
      BlankNode : fractalNode;
   begin
{        BlankNode := NodeList.rtnData;}
        result := ActiveNode.Field.Same('Disk',FileLimitX,FileLimitY);

        if result then
        begin
{             messagedlg('found uniform node: '+inttostr(ActiveNode.field.data.x1)+' '+inttostr(ActiveNode.field.data.y1)+' '+
                         inttostr(ActiveNode.field.data.x2)+' '+inttostr(ActiveNode.field.data.y2),mtinformation,[mbok],0);
}        end;
   end;

begin
memarr[1] := memavail;
     ActiveNode.Field.definedata(1,1,lScope); {Sets the initial node to 1,1,->fractalsize}

     NodeList := LinkedList.create;
     NewNodes := LinkedList.create;

     NodeList.modifydata(ActiveNode);
    Repeat
           NewNodes.modify(null);
           fin := false;
           Repeat
                 ActiveNode := NodeList.rtnData;
                 If not(SameThroughout) then
                 begin
{
Provided the split is valid then set the app. node link
Add these new locations to the newNode list
}
{                      BlankNode := NodeList.rtnData;}
                      for x := ord(bottomLeft) to ord(TopRight) do
                      begin
                           newField := ActiveNode.Field.TransformData(TwoDTransformation(x));
                           if within(FileLimitX,FileLimitY) then
                           if (not(ActiveNode.field.sameas(newfield))) and
                              (newfield.x1 <> newfield.x2) then
                           begin
                                ActivateNode(x,newfield);   {Creates the new node in the fractal}
                                newNodes.modifyData(ActiveNode.rtnNodeN(x));
                                newNodes.insertAfter;
                                {valid field}
                           end
                           else
                           begin
                                ActivateNode(x,newfield);   {Creates the new node in the fractal}
                                moveNode(x);
                                if (newfield.x1 <> newfield.x2) then
                                begin
                                     ActiveNode.singleValue := OriginalWord;
                                     ActiveNode.data := OriginalWord;
                                end
                                else
                                begin
                                     f := ActiveNode.Field.Same('Disk',FileLimitX,FileLimitY);
                                     ActiveNode.singleValue := OriginalWord;
                                     ActiveNode.data := OriginalWord;
                                end;
                                ActiveNode.Variance := 0;
                                movenode(-1);
                           end;
                      end;
                 end
                 else
                 begin
                      ActiveNode.singleValue := OriginalWord;
                      ActiveNode.data := OriginalWord;
                      ActiveNode.Variance := 0;
{                      Set Appr Values}
                 end;
{                 Delete Node from nodelist}
{                 if not(NodeList.atEnd) then
                    NodeList.delete
                 else
                 begin
                     NodeList.delete;
                     NodeList.ActiveNode := Nil;
                 end;
           Until NodeList.ActiveNode = Nil;}
                 if NodeList.atend then fin := true else NodeList.moveNode(1);
           Until fin;
           if NewNodes.elements > 1 then NewNodes.delete else fin := FALSE;

           if not(fin) then
           begin
{                switch leaves and NodeList}
           end;

           while not(NodeList.atStart) do
           begin
                NodeList.delete;
           end;
           NodeList.ActiveNode.data := longint(Nil);

           NewNodes.moveNode(cStart);
//           if (NodeList.ActiveNode.data <> longint(nil)) then
              if NewNodes.elements > 1 then NodeList.modifyData(NewNodes.rtndata);
//           else
//               NodeList.ActiveNode.data := Null;

           while not(NewNodes.atEnd) do
           begin
                NewNodes.moveNode(1);
                NodeList.insertAfter;
                NodeList.modifyData(NewNodes.rtnData);
           end;

           while not(newNodes.atStart) do
           begin
                newNodes.delete;
           end;

           NodeList.moveNode(cStart);

     Until NodeList.ActiveNode.data = longint(Nil);


     NodeList.destroy;
     NewNodes.destroy;
memarr[2] := memavail;
{compareMemUsed(memarr[1],memarr[2],'Parse And Create '+
               inttostr(memarr[2] - memarr[1]) +'  ');}
end;

procedure Fractal.BuildFromData(const szFileName,szFileFormat : string;
                                    dimx,dimy : longint);
var
   sztmp : string;

begin
memarr[3] := memavail;

     if szFileFormat = 'BYTE' then
     begin
          dataSize := sizeof(byte);
     end
     else
     begin
          if szFileFormat = 'WORD' then
          begin
               dataSize := sizeof(word);
          end
          else
          begin
               messagedlg('Invalid dataformat',mterror,[mbok],0);
               halt;
          end;
     end;
memarr[4] := memavail;

     if fileexists(szFileName) then
     begin
          assignfile(dataFile,szFileName);
          reset(dataFile,datasize);

          FileLimitX := dimx;
          FileLimitY := dimy;

          ParseAndCreate(bounded(dimx,dimy));

          closefile(dataFile);
     end
     else
     begin
          messagedlg('Data File '+szFileName+' does not exist',mtinformation,[mbok],0);
     end;

memarr[5] := memavail;
end;

procedure Fractal.Save;
begin

end;

procedure Fractal.Load;
begin

end;

