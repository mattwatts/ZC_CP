unit Exclarea;

{$I STD_DEF.PAS}

interface

uses
    Em_newu1, Global,
    ds;


type
    {$IFDEF SPARSE_MATRIX_2}
    {$ELSE}
    ExcSite_T = record
        iSiteGeocode : integer;
        featurearea : FeatureArea_T;
    end;
    {$ENDIF}

    ExcludedSiteArea_T = class
    public
          constructor init;
          procedure done;
          {$IFDEF SPARSE_MATRIX_2}
          procedure AddExcludedSite(ExcludedSite : Array_t);
          function RemoveExcludedSite(const iSiteKey : integer;
                                      ExcludedSite : Array_t) : boolean;
          {$ELSE}
          procedure AddExcludedSite(const AExcSite : ExcSite_T);
          function RemoveExcludedSite(const iSiteKey : integer;
                                      var AExcSite : ExcSite_T) : boolean;
          {$ENDIF}
    end;

implementation

var
   ExcludedSitesArr : Array_t;
   lInternalSiteCount : longint;

constructor ExcludedSiteArea_T.init;
begin
     ExcludedSitesArr := Array_t.create;
     {$IFDEF SPARSE_MATRIX_2}
     {$ELSE}
     ExcludedSitesArr.init(SizeOf(ExcSite_T),ARR_STEP_SIZE);
     {$ENDIF}

     lInternalSiteCount := 0;
end;

procedure ExcludedSiteArea_T.done;
begin
     ExcludedSitesArr.Destroy;
end;

{$IFDEF SPARSE_MATRIX_2}
procedure ExcludedSiteArea_T.AddExcludedSite(ExcludedSite : Array_t);
{$ELSE}
procedure ExcludedSiteArea_T.AddExcludedSite(const AExcSite : ExcSite_T);
{$ENDIF}
begin
     {$IFDEF SPARSE_MATRIX_2}
     {$ELSE}
     Inc(lInternalSiteCount);
     if (lInternalSiteCount > ExcludedSitesArr.lMaxSize) then
        ExcludedSitesArr.resize(ExcludedSitesArr.lMaxSize + ARR_STEP_SIZE);
     ExcludedSitesArr.setValue(lInternalSiteCount,@AExcSite);
     {$ENDIF}
end;


{$IFDEF SPARSE_MATRIX_2}
function ExcludedSiteArea_T.RemoveExcludedSite(const iSiteKey : integer;
                                               ExcludedSite : Array_t) : boolean;
{$ELSE}
function ExcludedSiteArea_T.RemoveExcludedSite(const iSiteKey : integer;
                                               var AExcSite : ExcSite_T) : boolean;
{$ENDIF}
var
   lCount, lSiteIndex : longint;
   {$IFDEF SPARSE_MATRIX_2}
   {$ELSE}
   pExcSite : ^ExcSite_T;
   {$ENDIF}
begin
     {try to find iSiteGeocode in ExcludedSitesArr}
     Result := False;

     {$IFDEF SPARSE_MATRIX_2}
     {$ELSE}
     if (lInternalSiteCount > 0) then
     begin
          lCount := 0;
          
          new(pExcSite);
          repeat
                Inc(lCount);
                ExcludedSitesArr.rtnValue(lCount,pExcSite);

                if (pExcSite^.iSiteGeocode = iSiteKey) then
                begin
                     Result := True;
                     ExcludedSitesArr.rtnValue(lCount,@AExcSite);
                     lSiteIndex := lCount;
                end;

          until Result
          or (lCount >= lInternalSiteCount);

          if Result then
          begin
               {remove element lSiteIndex from ExcludedSitesArr}
               if (lSiteIndex < lInternalSiteCount) then
                  for lCount := lSiteIndex to (lInternalSiteCount-1) do
                  begin
                       ExcludedSitesArr.rtnValue(lCount+1,pExcSite);
                       ExcludedSitesArr.setValue(lCount,pExcSite);
                  end;

               if ((lInternalSiteCount + ARR_STEP_SIZE) < ExcludedSitesArr.lMaxSize) then
                  ExcludedSitesArr.resize(ExcludedSitesArr.lMaxSize - ARR_STEP_SIZE);

               Dec(lInternalSiteCount);
          end;
          dispose(pExcSite);
     end;
     {$ENDIF}
end;

end.
