
    DimData = class
    public
          constructor create;
          destructor destroy;
          procedure free;
    end;

    TwoDimData = class(DimData)
    public
          data : Square_t;

          constructor create;
          destructor destroy;
          procedure free;

          procedure definedata(startrefx,startrefy : longint; mag : longint);
          function asLinear(xMax : longint) : longint;
          procedure setValues(const newValues : square_t);

          function SameAs(comp : Square_t) : boolean;
          function Same(szWhere : string; LimX,LimY : longint) : boolean;
          function TransformData(trans : TwoDTransformation) : Square_t;
          function whichway(desired : square_T) : TwoDTransformation;
    end;

    ThreeDimData = class(DimData)
    public
          x3,y3 : longint;

          constructor create;
          destructor destroy;
          procedure free;
    end;

