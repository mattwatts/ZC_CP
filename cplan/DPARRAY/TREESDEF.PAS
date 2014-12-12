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

