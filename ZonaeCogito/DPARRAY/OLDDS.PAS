unit Ds;

interface
uses
    Nodes,dimensions,classes;

const
     cStart = 'START';
     cEnd   = 'END';
type

    SortCast = (scInt,scLong,scReal,scString);
    Array_MAX_ = array[1.._MAX_] of longint;

    RangedList = class;
    RangedNode = class;

    Array_t = class(DataStructurePtr_O)
    public
          lDataTypeSize : longint;
          lMaxSize : longint;
          Resizing : boolean;
          fastResize : boolean;
          ptrDataStart : pointer;

    private
           FofData : file;
           szData : string;
           CurrentBase : longint;
           BaseRefs : ^Array_MAX_;
           fPaged : boolean;
           fModified : boolean;

           RangeList : RangedList; //LinkedList of RangeNode
           RangeNode : RangedNode; //RangedNode
           fBaseLine : boolean; // to see if we need to reset the linked list of ranges

           fNoPaging : boolean;
           Page_Size : longint;
           {Counters}
           (*
           cntFree,
           cntInit,
           cntResize,
           cntSetValue,
           cntRtnValue,
           cntRtnPtr,
           cntSort : longint;
           *)

    public
          constructor create;
          constructor create2(SizeOfDataType, InitialNum : longint);
          destructor Destroy; override;
          procedure free;
          procedure inhdestroy;

          procedure init(SizeOfDataType, InitialNum : longint);
          procedure clr;

          procedure resize(lNewSize : longint);
          procedure setresize(state : boolean);

          procedure setValue(const lElementNum : longint; ptrData : pointer);
          procedure rtnValue(const lElementNum : longint; ptrData : pointer);
          function rtnPtr(const lElementNum : longint) : pointer;

          procedure quicksortwrt(var DataPosition : integer; var sorttype : sortCast; iLo,iHi : longint);
          procedure BubbleSortwrt(DataPosition : integer; sorttype : sortCast);
          procedure SelectionSortwrt(DataPosition : integer; sorttype : sortcast);
          function sortwrt(DataPosition : integer; sorttype : sortCast) : array_t;

          procedure setto(ptrData : pointer);

          procedure setfilename(sz : string);

          procedure testing; override;
{          procedure WEBTEST(testlength : integer);}
          procedure sort(DataPosition : integer; sorttype : sortCast);

          procedure writetotextfile(szFile : string);
          procedure typedwriteln(datatype : string; const szFile : string);

          procedure dontpage;
          procedure dopage;

          function recite(sz : string) : tStringStream;

    protected

    private
           procedure baseline;
           procedure Array_tToMemStream(var MemStr : tMemoryStream);
           procedure MemStreamToArray_t(var MemStr : tMemoryStream);
           function LocateMem(lRef : longint) : pointer;
           procedure SaveData;
           procedure LoadData;
           procedure LocatePage(ref : longint);
           function fileof(page:integer) : string;

    {DEBUG}
           function wrapCreate : integer;
           function wrapCreate2 : integer;
           function wrapDestroy : integer;
           function WrapFree : integer;
           function WrapInit : integer;
           function WrapResize : integer;
           function WrapSetValue : integer;
           function WrapRtnValue : integer;
           function WrapRtnPtr : integer;
           function WrapSortwrt : integer;
    end;

    DataStructure = class
    public
          StartNode : Node;     {The Initial Node of a datastructure}
          TailNode : Node;      {The final node in a linear DS, or last node
                                 created in other types of DS}
          ActiveNode : Node;    {The currently active node pointing to a
                                 location within the DS}

          constructor create;
          constructor createlinked(links : longint);  {Initialises the links
                                                       array to the app. size}
          destructor destroy;
          procedure free;

          procedure move(NodeNumbers : olevariant); virtual;
          procedure modify(data : variant);   {Modifies the standard Data of
                                               the active Node}
          procedure modifydata(const ptrToStructure : pointer);
          function rtnData : pointer;
          function rtnObject : tObject;

          function atstart : boolean; {TRUE: iff ActiveNode = StartNode}
          function atend : boolean;   {TRUE: iff ActiveNode = TailNode}
          function size : longint;   {Returns the value in elements}
    private
           elements : longint;   {The number of element in the datastructure}
 {          NodeRefs : array_t;}  {A colection of the nodes - I'm not sure how
                                 useful this will be at the moment - or how the
                                 DS should manifest}
    end;

    Trees = class(DataStructure)
    public
          constructor createTree(linkages : longint); dynamic;
          destructor destroy;

          procedure setfortraversal;
          procedure nextposition;
          function endoftraversal : boolean;
    private
           defaultLinks : longint;
    end;

    SpecialTree = class(Trees)
    public
          constructor createTree(linkages : longint); override; abstract;
    end;

    Lists = class(DataStructure)
    public
          constructor create;
          destructor destroy;
          procedure free;

    private

    end;

    LinkedList = class(Lists)
    public
          constructor create;
          constructor createsized(size : longint);
          constructor createtyped(szType : string);
          destructor destroy;
          procedure free;

          procedure insertbefore;
          procedure insertafter;
          procedure delete;
//          procedure move(NodeNumbers : olevariant);    virtual;

          procedure draw;

          procedure modifydata(const ptrToStructure : tObject);
          function rtnData : pointer;
          function rtnObject : tObject;

          function toStringStream : tStringStream;
    private
           typeCast : string;
           trueImageRef : longint;
    end;

    Webs = class(DataStructure)
    public

          constructor create;
          destructor destroy;
          procedure free;

          procedure RecurseWithProcedure(Proc : pointer);

    end;

    dData = record
          recLevel : longint;
          NodeRef : longint;
    end;

    Fractal = class(Webs)
    public
          maxlinkages : longint;

{
          ActiveNode : FractalNode;
          StartNode : FractalNode;
          TailNode : FractalNode;
}
          constructor create;
          destructor destroy;
          procedure free;

          procedure move(NodeNumbers : olevariant);
          procedure RecurseWithProcedure(Proc : pointer);
          procedure DrawState;

          procedure BuildFromData; virtual; abstract;
          procedure Save; virtual; abstract;
          procedure Load; virtual; abstract;

          procedure ActivateNode(N : longint; sq : square_t);
          function LastLeaf : FractalNode;

//          procedure move(NodeNumbers : olevariant);

          function deref(sq : square_t) : longint;

    private
           DrawingData :dData;

           LeafsLinked : LinkedList;
    end;

    TwoDFractal = class(Fractal)
    public

          constructor create;
          destructor destroy;
          procedure free;

          procedure Build(level : longint);
          procedure BuildFromData(const szFileName, szFileFormat : string;
                                  dimx,dimy : longint);
          procedure RecurseWithProcedure(Proc : pointer);
          procedure Save;
          procedure Load;
          procedure drawstate;

          procedure movedir(whichway : TwoDTransformation);
          procedure enclose(field : TwoDimData);
          procedure enclosefrom(field : TwoDimData);
    protected
          function bounded(x,y : longint) : longint;
    private
           procedure ParseAndCreate(lScope : longint);
    end;


    FractalEye = class(TwoDFractal)
    public
          constructor create(Init : square_t);
          destructor destroy;

          procedure activate;
          procedure attachto(var Fract : TwoDFractal);

          procedure refresh;

          procedure modifydata(const ptrToStructure : pointer);
          function rtnData : pointer;
          function rtnObject : tObject;

    private
          procedure ActivateNode(N : longint; sq : square_t);
    end;

    RangedList = class(linkedList)
           ActiveNode : RangedNode;
           StartNode : RangedNode;
           TailNode : RangedNode;

           constructor create;

           procedure draw;
           procedure move(NodeNumbers : olevariant);
           procedure insertbefore;
           procedure delete;
    end;

    RangedNode = class(Node)
        StartData : variant;
        EndData : variant;

        constructor create;
        destructor destroy;
        procedure free;

        function within(Value : variant) : boolean;
        procedure setdata(startpoint,endpoint : variant);
        procedure image(ref : imagesqr);  override;

        function rtnAncestorNode : RangedNode;
        function rtnNodeN(N : longint) : RangedNode;
        procedure SetNodeN(N : longint; const tmpNode : Rangednode);

        function asString : string; override;
    end;

implementation

uses
    sysutils,dialogs,forms,dscanvas,os_lims,stdFctns,arrayt;

var
   memarr : array[1..10] of longint;
   FileLimitX,FileLimitY : longint;
   LevelOffsets : array[1..10] of longint; // max drawing ability of 10 levels

   LevelRef,BranchRef,OldBranchRef : longint;

{$I d:\cybrsafe\development\ll.pas}
{$I d:\cybrsafe\development\fract2d.pas}
{$I d:\cybrsafe\development\fracteye.pas}
{$I d:\cybrsafe\development\fract.pas}


procedure TwoDFractal.DrawState;
begin
     inherited;
end;

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


procedure TwoDFractal.RecurseWithProcedure(Proc : pointer);
begin
     inherited;

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
                       Move(x);
                       Recurse;
                       Move(-1);
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
     move(cStart);

     recurse;

 end;

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


constructor Lists.create;
begin
     inherited create;
     elements := 1;
end;

constructor DataStructure.createlinked(links : longint);
begin
     create;
end;

destructor Lists.destroy;
begin
     if self <> nil then
     inherited destroy;
end;

procedure Lists.Free;
begin
     if self <> nil then inherited free;

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


procedure Fractal.move(NodeNumbers : olevariant);
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

procedure RangedList.move(NodeNumbers : olevariant);
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

procedure DataStructure.move(NodeNumbers : olevariant);
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

(*
procedure DataStructure.move(NodeNumbers : olevariant);
{Move the active pointer in the given direction by the given # of nodes}
var
   x : integer;
   tmpNode : Node;
   sz : string;

begin
     if vartype(NodeNumbers) and varTypeMask = varstring then
     begin
          sz := uppercase(NodeNumbers);
          if sz = 'START' then
          begin
               ActiveNode := StartNode;
          end
          else
          begin
               if sz = 'END' then
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
          if vartype(NodeNumbers) and varTypeMask = varinteger then
          begin
               if NodeNumbers > 0 then
               begin
                    for x := 1 to NodeNumbers do
                    begin
                         tmpNode := ActiveNode.rtnNodeN(1);
                         if tmpNode <> nil then
                            ActiveNode := tmpNode
                         else
                             break;
                    end;
               end
               else
               begin
                    for x := 1 to round(abs(NodeNumbers)) do
                    begin
                         tmpNode := ActiveNode.Ancestor.ptrToNode;
                         if tmpNode <> nil then
                            ActiveNode := tmpNode
                         else
                             break;
                    end;
               end;
          end
          else
          begin
               messagedlg('I dont know how to handle',mterror,[mbok],0);
               halt;
          end;
     end;
end;
*)
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



end.
