    Node = class
    public
          Links : array_t; {Of linkages}
          data : variant;  {The Data position - often data will be stored here}

          Ancestor : Linkage;{The linkage to the node that 'inspired' 'this' one}

          Radius : longint;

          constructor create;
          constructor createNull;
          constructor createLinked(lLinks : longint);
          constructor createsized(lLinks,size : longint);
          constructor createtyped(lLinks : longint; sztype : string);
          destructor destroy;
          destructor dest;
          procedure free;

          function RtnRefNum : longint;  {Returns the private NodeRefNum}
          function RtnValue : variant;
          procedure setValue(val : variant);
          function TestNodeN(N : longint) : boolean;

          function rtnAncestorNode : Node; virtual;
          function rtnNodeN(N : longint) : Node; virtual;
          procedure SetNodeN(N : longint; const tmpNode : node); virtual;

          function activelinks : longint;
          function pathref : longint;
          procedure followLinkN(N : integer);

          procedure drawimage(var Ref : longint);
          procedure drawlinkages;

          procedure setradius(rad : longint);


          procedure image(ref : imagesqr); dynamic;
          procedure imageLinks(ref1,ref2 : imagesqr);
          procedure imageLable(ref1,ref2 : imagesqr; Value : longint);

          function asString : string; dynamic; abstract;

    protected
    private
          NodeRefNum : longint; {A simple reference}
          ActiveImageRef : longint;

          function derivedimage(ref : longint) : imagesqr;  dynamic;
          function derivedlinkage(ref : longint) : imagesqr; dynamic;
          function DataAsString : string;
    end;

    SpecialNode = class(Node)

    end;

    GenericNode = class(Node)
    public
          Data : pointer;           {A generic node is a pointer to a }
          lDataSize : longint;      {sized memory field}

          constructor create(lLinks,lsize : longint);
          destructor destroy;
          procedure free;

    end;

    TypedNode = class(Node)         {A temporary blank object}
    public
          constructor create(lLinks : longint);
          destructor destroy;
          procedure free;

    end;

    LongintNode = class(TypedNode)
    public
          Data : longint;           {A true typed Node}

          constructor create(lLinks : longint);
          destructor destroy;
          procedure free;

    end;

    RealNode = class(TypedNode)
    public
          Data : real;              {A true typed Node}

          constructor create(lLinks : longint);
          destructor destroy;
          procedure free;

    end;

    ObjectNode = class(TypedNode)
    public
          Data : tObject;           {A true typed Node}

          constructor create(lLinks : longint);
          destructor destroy;
          procedure free;

    end;

    FractalNode = class(TypedNode)
    public
          Field : TwoDimData;

          SingleValue : longint;
          Variance : longint;

          constructor create(Dimension : DimensionData);
          destructor destroy;
          procedure free;

        function rtnAncestorNode : FractalNode;
        function rtnNodeN(N : longint) : FractalNode;
        procedure SetNodeN(N : longint; const tmpNode : FractalNode);
        procedure displayspace;

    private
          function derivedimage(ref : longint) : imagesqr; override;
          function derivedlinkage(ref : longint) : imagesqr; override;
    end;


    RangedNode = class(Node)

        StartData : variant;
        EndData : variant;


        ptrData : pointer;
        fModified : boolean;
        szFileName : string;

        constructor create;
        destructor destroy;
        destructor remove;
        procedure free;

        function within(Value : variant) : boolean;
        procedure setdata(startpoint,endpoint : variant);
        procedure image(ref : imagesqr);  override;

        function rtnAncestorNode : RangedNode;
        function rtnNodeN(N : longint) : RangedNode;
        procedure SetNodeN(N : longint; const tmpNode : Rangednode);

        function asString : string; override;
    end;

