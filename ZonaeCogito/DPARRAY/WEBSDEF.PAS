    Webs = class(DataStructure)
    public

          constructor create;
          destructor destroy;
          procedure free;

          procedure RecurseWithProcedure(Proc : pointer);

          procedure modifyData(const ptrToStructure : tObject);
          function rtnData : pointer;
    end;

    Fractal = class(Webs)
    public
          ActiveNode : FractalNode;
          StartNode : FractalNode;
//          TailNode : FractalNode;

          maxlinkages : longint;

          constructor create;
          destructor destroy;
          procedure free;

          procedure moveNode(NodeNumbers : olevariant);
          procedure RecurseWithProcedure(Proc : pointer);
          procedure DrawState;

          procedure ActivateNode(N : longint; sq : square_t);
          function LastLeaf : FractalNode;

          procedure Build(level : longint);
          procedure BuildFromData(const szFileName, szFileFormat : string;
                                  dimx,dimy : longint);
          procedure Save;
          procedure Load;

          procedure movedir(whichway : TwoDTransformation);
          procedure enclose(field : TwoDimData);
          procedure enclosefrom(field : TwoDimData);

          function deref(sq : square_t) : longint;

    protected
          function bounded(x,y : longint) : longint;

    private
           DrawingData :dData;
           LeafsLinked : LinkedList;

           procedure ParseAndCreate(lScope : longint);
    end;

    FractalEye = class(Fractal)
    public
          StartSpace : fractal;

          constructor create(Init : square_t);
          destructor destroy;

          procedure activate;
          procedure attachto(var Fract : Fractal);

          procedure refresh;

          procedure modifydata(const ptrToStructure : pointer);
          function rtnData : pointer;
          function rtnObject : tObject;

    private
          procedure ActivateNode(N : longint; sq : square_t);
    end;

