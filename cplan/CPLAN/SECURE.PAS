unit secure;

interface

function GetMachineId : integer;
{return a unique identifier for this computer}
procedure SetMachineRegCode (const iRegCode : integer);
{create the .REG file for C-Plan to work}
function CheckMachineRegCode : boolean;
{check the .REG file is valid for this computer}

implementation

function GetMachineId : integer;
begin
     {return a unique identifier for this computer}

     {find hard disk volume id}
end;

procedure SetMachineRegCode (const iRegCode : integer);
begin
     {create the .REG file for C-Plan to work}
end;

function CheckMachineRegCode : boolean;
begin
     {check the .REG file is valid for this computer}
     Result := False;
end;

end.
