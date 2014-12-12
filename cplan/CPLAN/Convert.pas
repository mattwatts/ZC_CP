unit Convert;

{$I STD_DEF.PAS}

interface

uses
    Global,
  {$IFDEF bit16}
  Arrayt16;
  {$ELSE}
  ds;
  {$ENDIF}

procedure Deferrals2Array (var aDef : Array_t);

implementation

uses
    Control, Em_newu1, SysUtils;

procedure Deferrals2Array (var aDef : Array_t);
var
   iDefCount, iCount : integer;

   procedure AddASite(const sGeo_ : string);
   var
      iGeo : integer;
   begin
        Inc(iDefCount);

        iGeo := StrToInt(sGeo_);

        if (iDefCount > aDef.lMaxSize) then
           aDef.resize(aDef.lMaxSize + ARR_STEP_SIZE);

        aDef.setValue(iDefCount,@iGeo);
   end;

begin
     aDef := Array_t.create;
     aDef.init(SizeOf(integer),ARR_STEP_SIZE);
     iDefCount := 0;

     with ControlForm do
     begin
          if (R1.Items.Count > 0) then
             for iCount := 0 to (R1.Items.Count-1) do
                 AddASite(R1Key.Items.Strings[iCount]);
          if (R2.Items.Count > 0) then
             for iCount := 0 to (R2.Items.Count-1) do
                 AddASite(R2Key.Items.Strings[iCount]);
          if (R3.Items.Count > 0) then
             for iCount := 0 to (R3.Items.Count-1) do
                 AddASite(R3Key.Items.Strings[iCount]);
          if (R4.Items.Count > 0) then
             for iCount := 0 to (R4.Items.Count-1) do
                 AddASite(R4Key.Items.Strings[iCount]);
          if (R5.Items.Count > 0) then
             for iCount := 0 to (R5.Items.Count-1) do
                 AddASite(R5Key.Items.Strings[iCount]);
          if (Partial.Items.Count > 0) then
             for iCount := 0 to (Partial.Items.Count-1) do
                 AddASite(PartialKey.Items.Strings[iCount]);
     end;

     if (iDefCount > 0) then
        aDef.resize(iDefCount)
     else
     begin
          aDef.resize(1);
          aDef.lMaxSize := 0;
     end;
end;

end.
