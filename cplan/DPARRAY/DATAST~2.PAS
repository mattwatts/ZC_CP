    DataStructure = class
    public
          StartNode : Node;     {The Initial Node of a datastructure}
          TailNode : Node;      {The final node in a linear DS, or last node
                                 created in other types of DS}
          ActiveNode : Node;    {The currently active node pointing to a
                                 location within the DS}

          elements : longint;   {The number of element in the datastructure}

          constructor create;
          constructor createlinked(links : longint);  {Initialises the links
                                                       array to the app. size}
          destructor destroy;
          procedure free;

          procedure moveNode(NodeNumbers : olevariant); virtual;
          procedure modify(data : variant);   {Modifies the standard Data of
                                               the active Node}
          procedure modifydata(const ptrToStructure : pointer);
          function rtnData : pointer;
          function rtnObject : tObject;

          function atstart : boolean; {TRUE: iff ActiveNode = StartNode}
          function atend : boolean;   {TRUE: iff ActiveNode = TailNode}
          function size : longint;   {Returns the value in elements}
    private
 {          NodeRefs : array_t;}  {A colection of the nodes - I'm not sure how
                                 useful this will be at the moment - or how the
                                 DS should manifest}
    end;

