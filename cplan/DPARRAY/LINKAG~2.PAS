    Linkage = class
    public
          ptrToNode : Node;     {The node pointed to by the linkage}
          ref : integer;         {A reference - not being used at the moment}

          constructor create;   dynamic;
          destructor destroy;
          procedure free;

          function rtnNode : Node;
    end;

