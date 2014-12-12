         ContMemData_t = record
              lDataUnitsPerSegment : longint;
              fit : boolean;
         end;

         ContigMemory = class
         {Gives the data structure abity to posses a 'piece' of contiguous memory}
              instanceRef : longint;
              ContigData : ContMemData_t;

              constructor create;
              procedure free;
              destructor destroy; override;

              procedure AllocContMemPtr(var ptrData:pointer;
                                            lNumElements,lElSize : longint;
                                        var ContigData : ContMemData_t);
              procedure ReAllocContMemPtr(var ptrData:pointer;
                                              lNumElements,lElSize:longint;
                                              var ContigData : ContMemData_t);
              procedure DisposeContMemPtr(var ptrData : pointer);
              procedure FreeContMemPtr(var ptrData : pointer);
              function LocateContMemPtr(ptrData : pointer; lElementNum,lElSize : longint;
                                         ContigData : ContMemData_t) : pointer;

              procedure testing; virtual;


              function WrapAlloc : integer;
              function WrapReAlloc : integer;
              function WrapDispose : integer;
              function WrapFree : integer;
              function WrapLocate : integer;

              procedure  randomtests(testlength : longint);
              procedure  testAlloc(testlength : longint);
              procedure  testReAlloc(testlength : longint);
              procedure  testLocate(testlength : longint);

         end;


