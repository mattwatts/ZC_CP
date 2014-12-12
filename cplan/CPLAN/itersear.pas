unit itersear;
{Purpose: Iterative Search Routines for iteratively selecting sites
          until conservation goals are reached.

 Author: Matthew Watts
 Date: Wed June 11 1997}


interface

uses
{$IFDEF VER90}
  ds, Highligh, Dll_u1;
{$ELSE}
  Arrayt16, Cpng_imp;
{$ENDIF}

procedure IterateTillSatisfied(const sFirstFld, sSecondFld : string);

implementation

uses
    Control, Dialogs, SysUtils, Global,
    Sf_irrep;

function findBestSite(const sFirstFld, sSecondFld : string) : boolean;
var
   fEnd : boolean;
   iGeocode : integer;
   rFirstValue, rSecondValue,
   rThisFirst, rThisSecond : extended;
   ASiteArr : Array_t;
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
begin
     {this function finds and highlights the site with the highest
      value for sFirstFld, using sSecondFld as a tie-breaker.
      Result is false if sFirstFld has no values > 0
      ie. for Calculated Irr fields, this means all feature are
      satisfied}

     Result := False;

     with ControlForm do
     begin
          OutTable.Open;

          fEnd := False;
          rFirstValue := 0;
          rSecondValue := 0;
          repeat
                if OutTable.EOF then
                   fEnd := True;

                if (OutTable.FieldByName(STATUS_DBLABEL).AsString = 'Av') then
                begin
                     {process only available sites}

                     rThisFirst := OutTable.FieldByName(sFirstFld).AsFloat;

                     if (rThisFirst >= rFirstValue)
                     and (rThisFirst > 0) then
                     begin
                          rThisSecond := OutTable.FieldByName(sSecondFld).AsFloat;
                          if (rThisSecond >= rSecondValue) then
                          begin
                               {if (rThisSecond = rSecondValue) then
                                  MessageDlg('findBestSite tie break is identical value ' +
                                             FloatToStr(rSecondValue),
                                             mtWarning,[mbOk],0);}

                               Result := True;

                               iGeocode := OutTable.FieldByName(ControlRes^.sKeyField).AsInteger;

                          end;
                     end;
                end;

                OutTable.Next;

          until fEnd;

          OutTable.Close;
     end;

     if Result then
     begin
          ASiteArr := Array_t.Create;
          ASiteArr.init(SizeOf(integer),1);
          ASiteArr.setValue(1,@iGeocode);

          Arr2Highlight(ASiteArr,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);

          ASiteArr.Destroy;
     end;
end;

procedure IterateTillSatisfied(const sFirstFld, sSecondFld : string);
var
   fChooseResult : boolean;
begin
     with ControlForm do
     repeat
           UnHighlight(Available,fKeepHighlight);

           if not fContrDataDone then
              ExecuteIrreplaceability(-1,False,False,True,True,'');

           fChooseResult := findBestSite(sFirstFld,sSecondFld);

           MoveGroup(Available,AvailableKey,R1,R1Key,
                     FALSE {no user},True);

     until not fChooseResult;
end;

end.
