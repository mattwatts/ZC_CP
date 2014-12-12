unit Linkages;

interface

type
    Linkage = class

    ptrToNode : Node;
    ref : integer;

    constructor create;
    destructor destroy;
    procedure free;

    end;

implementation
constructor Linkage.create;
begin
     inherited create;
     ref := 1;
end;

destructor Linkage.destroy;
begin

     inherited destroy;
end;

procedure Linkage.Free;
begin

end;


end.
