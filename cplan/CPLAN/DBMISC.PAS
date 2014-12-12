unit Dbmisc;


interface


procedure TrimTrailSpaces(var sLine : string);
procedure TrimLeadSpaces(var sLine : string);


implementation


procedure TrimTrailSpaces(var sLine : string);
var
   iPos : integer;
begin
     iPos := Length(sLine);

     if (Length(sLine) > 1) then
        while (sLine[iPos] = ' ')
        and (iPos > 1) do
            Dec(iPos);

     if (iPos < Length(sLine)) then
        sLine := Copy(sLine,1,iPos);
end;

procedure TrimLeadSpaces(var sLine : string);
var
   iPos : integer;
begin
     iPos := 1;

     if (Length(sLine) > 1) then
        while (sLine[iPos] = ' ') do
              Inc(iPos);

     if (iPos < Length(sLine)) then
        sLine := Copy(sLine,iPos,Length(sLine)-iPos+1);
end;


end.
