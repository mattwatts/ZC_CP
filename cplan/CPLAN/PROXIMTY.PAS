unit Proximty;

interface

uses
    Em_newu1, SysUtils;

const
     ORD_PROX_STEPS = 16; {number of ordinal categories for proximity,
                           this will be mapped onto ordinal EMR categories}


type
    Proximity_T = record
                  Easting, Northing : longint;
    end;

    ProximityData_T = array [1..totalsites] of Proximity_T;
    ProximityOrd_T = array [1..totalsites] of integer;
    ProxReals_T = array [1..totalsites] of real;


procedure UseProximity(const iNumCodes : integer;
                       const Codes : GeocodeList_T;
                       const ProximityData : ProximityData_T;
                       var OrdinalProximity : ProximityOrd_T);
function CalcDist(const lAEast, lANorth, lBEast, lBNorth : longint) : real;

procedure ProxManSel;
{this makes a map of relative proximity for Mandatory and Selected sites}

implementation

uses Control, Dialogs;

procedure ProxManSel;
{this makes a map of relative proximity for Mandatory and Selected sites}
var
   iCount, iMyCodeCount : integer;
   MyCodes : GeocodeList_T;
   MyProximityOrd : ProximityOrd_T;
   MyProxData : ProximityData_T;
begin
     iMyCodeCount := ControlForm.SelectedGeocode.Items.Count + ControlForm.MandatoryGeocode.Items.Count;
     {copy Mandatory and Selected geocodes to MyCodes}
     for iCount := 1 to ControlForm.SelectedGeocode.Items.Count do
     begin
          MyProxData[iCount].Easting := -1; {set invalid value for proximity data}

          MyCodes[iCount]^ := ControlForm.SelectedGeocode.Items.Strings[iCount-1];
     end;

     for iCount := 1 to ControlForm.MandatoryGeocode.Items.Count do
     begin
          MyProxData[iCount].Easting := -1; {set invalid value for proximity data}

          MyCodes[iCount + ControlForm.SelectedGeocode.Items.Count]^ :=
                         ControlForm.MandatoryGeocode.Items.Strings[iCount-1];
     end;
     {load MyProxData from database}
     ControlForm.OutTable.Open;
     with ControlForm.OutTable do
     repeat
           for iCount := 1 to iMyCodeCount do
               if (MyCodes[iCount]^ = FieldByName('KEY').AsString) then
               begin
                    MyProxData[iCount].Easting := FieldByName('EASTING').AsInteger;
                    MyProxData[iCount].Northing := FieldByName('NORTHING').AsInteger;
               end;

           Next;

     until EOF;
     ControlForm.OutTable.Close;
     {check that proximity data is valid for all sites loaded}
     for iCount := 1 to iMyCodeCount do
         if (MyProxData[iCount].Easting < 0) then
            MessageDlg('Database lookup for code ' + MyCodes[iCount]^ + ' failed',
                       mtError,[mbOK],0);
     {now go and make a proximity map for these sites}
     UseProximity(iMyCodeCount,MyCodes,MyProxData,MyProximityOrd);
end;

procedure MapProx2EMR(const iNumCodes : integer;
                      const Codes : GeocodeList_T;
                      const OrdinalProximity : ProximityOrd_T);
var
   iCount, iCount2 : integer;
   TmpSite : site;
   pSite : sitepointer;
begin
     for iCount := 1 to SiteArr.lMaxSize do
     begin
          SiteArr.rtnValue(iCount,pSite);
          TmpSite.subsord := '0';
          {initialise the subsequent EMR category to 0 so that only
           values specified will be displayed}

          for iCount2 := 1 to iNumCodes do
              if (Codes[iCount2]^ = TmpSite.geocode) then
                 TmpSite.subsord := IntToStr(OrdinalProximity[iCount2]);
          {for each site in the Codes list, copy the ordinal proximity of
           this to the sitearrays subsequent ordinal EMR variable}

          SiteArr.setValue(iCount,pSite);
     end;

     {write the mapped ordinal values to the database file}
     ControlForm.SubsequentEMR2DB;
     {tell WinERMS that its variables have been updated}
     ControlForm.InformWinERMS;
end;

procedure DumpProximity(const iNumCodes : integer;
                        const Codes : GeocodeList_T;
                        const OrdinalProximity : ProximityOrd_T);
var
   iCount : integer;
begin
          for iCount := 1 to iNumCodes do
         Debug2File(1,'code ' + Codes[iCount]^
             + ' prox ' + IntToStr(OrdinalProximity[iCount]));
end;

function CalcDist(const lAEast, lANorth, lBEast, lBNorth : longint) : real;
var
   fTmp, fTmp1, fTmp2 : real;
begin
     fTmp1 := (lAEast - lBEast);
     {Debug2File(1,'fTmp1 is ' + FloatToStr(fTmp1));}
     fTmp1 := fTmp1 * fTmp1;
     {Debug2File(1,'fTmp1 is ' + FloatToStr(fTmp1));}
     fTmp2 := (lANorth - lBNorth);
     {Debug2File(1,'fTmp2 is ' + FloatToStr(fTmp2));}
     fTmp2 := fTmp2 * fTmp2;
     {Debug2File(1,'fTmp2 is ' + FloatToStr(fTmp2));}

     fTmp := fTmp1 + fTmp2;
     {Debug2File(1,'fTmp is ' + FloatToStr(fTmp));}
     fTmp := Sqrt(fTmp);
     {Debug2File(1,'fTmp now ' + FloatToStr(fTmp));}

     Result := fTmp;
end;


function MakeOrdinalProximity(const iNumCodes : integer;
                 const ProxReals : ProxReals_T) : ProximityOrd_T;
var
   fHigh, fLow, fStep, fCutOff : real;
   OrdinalProximity : ProximityOrd_T;
   iCount, iCount2 : integer;
begin
     fHigh := 0;
     for iCount := 1 to iNumCodes do
         if (ProxReals[iCount] > fHigh) then
            fHigh := ProxReals[iCount];

     fLow := fHigh;
     for iCount := 1 to iNumCodes do
         if (ProxReals[iCount] < fLow) then
            fLow := ProxReals[iCount];

     Debug2File(1,'fHigh is ' + FloatToStr(fHigh)
                + ' fLow is ' + FloatToStr(fLow));

     fStep := (fHigh - fLow) / ORD_PROX_STEPS;

     Debug2File(1,'fStep is ' + FloatToStr(fStep));

     for iCount := ORD_PROX_STEPS downto 1 do
     begin
          fCutOff := fLow + (iCount * fStep) + 1;
          Debug2File(1,'cutoff ' + IntToStr(iCount) + ' ' + FloatToStr(fCutOff));

          for iCount2 := iNumCodes downto 1 do
              if (ProxReals[iCount2] < fCutOff) then
                 OrdinalProximity[iCount2] := iCount;
     end;

     Result := OrdinalProximity;
end;


procedure UseProximity(const iNumCodes : integer; const Codes : GeocodeList_T;
                       const ProximityData : ProximityData_T;
                       var OrdinalProximity : ProximityOrd_T);
var
   iCount, iCount2 : integer;
   rTotal : real;
   ProxReals : ProxReals_T;
begin
     {this uses the ProximityData extracted by SQL_Unit, ProxManSel and other functions}
     for iCount := 1 to iNumCodes do
     begin
          rTotal := 0;

          for iCount2 := 1 to iNumCodes do {compare site to all other sites}
          begin
               if (iCount <> iCount2) then
                  rTotal := rTotal + (CalcDist(
                         ProximityData[iCount].Easting,
                         ProximityData[iCount].Northing,
                         ProximityData[iCount2].Easting,
                         ProximityData[iCount2].Northing) / iNumCodes);

               {Debug2File(1,'fTotal is ' + FloatToStr(fTotal));
               Debug2File(1,'iCount is ' + IntToStr(iCount) +
                          ' iCount2 is ' + IntToStr(iCount2));}
          end;
          ProxReals[iCount] := rTotal;
     end;
     OrdinalProximity := MakeOrdinalProximity(iNumCodes,ProxReals);
     MapProx2EMR(iNumCodes,Codes,OrdinalProximity);
end;

end.
