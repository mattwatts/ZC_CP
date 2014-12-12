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

          function withinany(ref : variant) : boolean;

          procedure LoadFromTextFile(szFileName : string; FileFormat : variant);
          function toStringStream : tStringStream;
    private
           typeCast : string;
           trueImageRef : longint;
    end;

    RangedList = class(linkedList)
    public
          lListPages : longint;

           ActiveNode : RangedNode;
           StartNode : RangedNode;
           TailNode : RangedNode;

           constructor create(pages : longint; var DataBlock : pointer);
           destructor destroy;
           procedure remove;
           procedure free;
           
           procedure draw;
           procedure moveNode(NodeNumbers : olevariant);
           procedure insertbefore;
           procedure insertafter;
           procedure delete;
           function atstart : boolean;
           function atend : boolean;

           function withinany(ref : variant; limit : longint) : boolean;
           procedure Movewithin(Ref : variant);
    private
           contigDataBlock : pointer;

    end;

