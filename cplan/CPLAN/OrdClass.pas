unit OrdClass;

interface

uses
    Global;

function LoadOrdinalClass(const sFieldToLoad : string;
                          var ClassDetail : ClassDetail_T) : boolean;

implementation

uses
    Control, Dialogs, Contribu;

function LoadOrdinalClass(const sFieldToLoad : string;
                          var ClassDetail : ClassDetail_T) : boolean;
var
   fStop : boolean;
   rValue : extended;
   iValue, iFeatCode, iFeatIndex, iCount : integer;
   pFeat : featureoccurrencepointer;
begin
     {if the field exists (and is an integer) in the FSTable, result is true, else it is false
      if field exists then Load its (integer) value to pFeat^.iOrdinalClass}
     fStop := False;
     Result := True;

     {initialise ClassDetail}
     for iCount := 1 to 10 do
         ClassDetail[iCount] := False;

     {attempt to open feature summary table}
     try
        ControlForm.CutOffTable.Open;
     except
           fStop := True;
           MessageDlg('Cannot open Feature Summary Table',mtInformation,[mbOk],0);
     end;

     {check for existance of sFieldToLoad, and that it is the right type (integer) in the table}
     try
        rValue := ControlForm.CutOffTable.FieldByName(sFieldToLoad).AsFloat;
     except
           fStop := True;
           ControlForm.CutOffTable.Close;

           MessageDlg(sFieldToLoad + ' in not an integer field or does not exist in the table',
                      mtInformation,[mbOk],0);
     end;

     if not fStop then
     try
        new(pFeat);

        {traverse the Feature Summary Table and load sFieldToLoad to pFeat^.iOrdinalClass}
        repeat
              rValue := ControlForm.CutOffTable.FieldByName(sFieldToLoad).AsFloat;
              iValue := round(rValue);
              if (iValue > 10) then
                 iValue := 10;
              if (iValue < 0) then
                 iValue := 0;

              iFeatCode := ControlForm.CutOffTable.FieldByName(ControlRes^.sFeatureKeyField).AsInteger;

              iFeatIndex := iFeatCode;
              if (iFeatIndex > 0) then
              begin
                   FeatArr.rtnValue(iFeatIndex,pFeat);
                   if (pFeat^.code = iFeatCode) then
                   begin
                        pFeat^.iOrdinalClass := iValue;
                        FeatArr.setValue(iFeatIndex,pFeat);

                        if (iValue > 0) then
                           ClassDetail[iValue] := True;
                   end;
              end;

              fStop := ControlForm.CutOffTable.EOF;
              ControlForm.CutOffTable.Next;

        until fStop;

        ControlForm.CutOffTable.Close;

     except
           MessageDlg('Error loading ' + sFieldToLoad + ' from the Feature Summary Table',mtError,[mbOk],0);
     end
     else
         Result := False;
end;

end.
