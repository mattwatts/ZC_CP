unit Ds;

interface
uses
    classes;

const
     cStart = 'START';
     cEnd   = 'END';
     _MAX_ = 1000; {Maximum size for ref array}
     StdSize_C = 100000; {A std. size constant}
     cPAGELIST = 'PAGELIST';

type
    TwoDTransformation = (Nothing,BottomLeft,BottomRight,TopLeft,TopRight,Reverse);

    Square_t = record
          x1,y1,x2,y2 : longint;
    end;

    SortCast = (scInt,scLong,scReal,scString);
    Array_MAX_ = array[1.._MAX_] of longint;

    imagesqr = record
          x1,y1 : longint;
    end;

    DimensionData = record
          Links : longint;
    end;

    dData = record
          recLevel : longint;
          NodeRef : longint;
    end;

//Predefinition of all classes shown in thier object hierarchy

            DimData = class;

            TwoDimData = class;

            ThreeDimData = class;

    Linkage = class;



                                Node = class;

    TypedNode = class;     SpecialNode = class;      GenericNode = class;

    LongintNode = class;
    RealNode = class;
    ObjectNode = class;
    FractalNode = class;
    RangedNode = class;


                  ContigMemory = class;

                  Array_t = class;



                                DataStructure = class;

    Lists = class;          Webs = class;            Trees = class;

    LinkedList = class;     Fractal = class;         SpecialTree = class;


    RangedList = class;     //TwoDFractal = class;
                            FractalEye = class;


{$I Dimens~2.pas}
{$I Linkag~2.pas}
{$I NodeDef.pas}
{$I Contig~2.pas}
{$I Array_~2.pas}
{$I DataSt~2.pas}
{$I ListDef.pas}
{$I WebsDef.pas}
{$I TreesDef.pas}


//dimensions
    function direct2d(Actual,Base : square_t) : TwoDTransformation;
//contig and array
    function copyofarr(arr : array_t) : array_t;
    procedure WEBTEST(testlength : longint);

    procedure LoadArrayWithText(var ar : array_t; LineMask : array of string; filename : string);
    procedure setpagingarray(dir : string);
//

procedure arrayt_initialization;


var
     _testarr_ : array_t;
   basedir : string;
   baselocation : string;

implementation
uses
    filectrl,sysutils,dialogs,forms,dscanvas,graphics,os_lims,dsdebug,arraydb,
    stdfctns{, start, Control};

const
   baseradius = 25;
   maxels = 100000;
     MAXTESTRESIZE = 100000;
     BIGSIZE = 1000000;
     _PAGE_SIZE_ : longint = 1024*1024*1024 ;{ie. 1024mb} //Has a minimum of 64K

var
   memarr : array[1..10] of longint;
   FileLimitX,FileLimitY : longint;
   LevelOffsets : array[1..10] of longint; // max drawing ability of 10 levels

   LevelRef,BranchRef,OldBranchRef : longint;
   twoDimensions : DimensionData;

   dataFile : file;
   dataSize : integer;
   OriginalByte : byte;
   OriginalWord : word;
   NodeMarker : longint;  {A means of assigning a discret value to each node}
   LinkageRef : longint; {The linkage ref counter}

//Contig and array_t
   oDSDebug : ContigMemory;
   db_ContMem : ContMemData_t;
   debugptr_ : pointer;
   Testptr : pointer;
   DSInstance : longint;
   mem : array[0..10] of longint;
   TestContigData : ContMemData_t;
   counter : longint;
   unitNumber : longint;
   unitsize : integer;
   flog : boolean;
   log : text;
   szlastWeb : string;
f : file;
l : longint;
p : pointer;
   sz : string;
   lOldSize : longint;
   ArrayRef : longint;
   x : longint;

   ARRDBCounter : longint;
   debugbuffer : array[1..1000] of byte;

   istart,finish : longint;
   startin,finishin : longint;

     Value : pointer;
     ptrtestValue : pointer;
     ptrLo, ptrHi, ptrcopy : pointer;

     //Array_t
     prev : longint;


{$I Dimens~1.pas}
{$I Linkag~1.pas}
{$I NodeCode.pas}
{$I Contig~1.pas}
{$I Array_~1.pas}
{$I DataSt~1.pas}
{$I ListCode.pas}
{$I WebsCode.pas}
{$I TreesC~1.pas}

(*initialization
begin
     //basedir := 'c:\Arraytemp';
     basedir := sDatabase;
     baselocation := basedir;
     ForceDirectories(basedir);
     if fileexists(baselocation+'\*.*') then
     begin
          while deletefile(baselocation+'\*.*')do ;
     end;
     twodimensions.links := 4;
end;*)

procedure arrayt_initialization;
begin
     //basedir := 'c:\Arraytemp';
     //basedir := sDatabase;
     basedir := 'c:\';
     baselocation := basedir;
     ForceDirectories(basedir);
     if fileexists(baselocation+'\*.*') then
     begin
          while deletefile(baselocation+'\*.*')do ;
     end;
     twodimensions.links := 4;
end;

end.
