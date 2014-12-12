unit Calcdef;

interface

uses
    Global, Em_newu1, Toolmisc;

procedure CalcDeferrSite(const pSite : sitepointer);
procedure CalcPartDeferrSite(const pSite : sitepointer);
procedure CalcExcludeSite(const pSite : sitepointer);

procedure CalcUnDeferrSite(const pSite : sitepointer);
procedure CalcUnPartDeferrSite(const pSite : sitepointer);
procedure CalcUnExcludeSite(const pSite : sitepointer);

{these procedures dynamically adjust targets as sites are selected}

implementation

uses
    Contribu {for FindFeature},
    Control {for FeatArr},
    Exclarea,
    Dialogs, partl_ed;

procedure CalcDeferrSite(const pSite : sitepointer);
var
   lCount, lFeatureIndex : longint;
   pFeat : featureoccurrencepointer;
   Value : ValueFile_T;
begin
     try
        if (pSite^.richness > 0) then
        try
           new(pFeat);

           for lCount := 1 to pSite^.richness do
           begin
                FeatureAmount.rtnValue(pSite^.iOffset + lCount,@Value);
                lFeatureIndex := Value.iFeatKey;

                FeatArr.rtnValue(lFeatureIndex,pFeat);

                pFeat^.targetarea := pFeat^.targetarea - Value.rAmount;
                pFeat^.rDeferredArea := pFeat^.rDeferredArea + Value.rAmount;
                pFeat^.rCurrentSumArea := pFeat^.rCurrentSumArea - Value.rAmount;
                pFeat^.rCurrentAreaSqr := pFeat^.rCurrentAreaSqr - Sqr(Value.rAmount);
                if (pSite^.status = _R1) then
                   pFeat^.rR1 := pFeat^.rR1 + Value.rAmount
                else
                    if (pSite^.status = _R2) then
                       pFeat^.rR2 := pFeat^.rR2 + Value.rAmount
                    else
                        if (pSite^.status = _R3) then
                           pFeat^.rR3 := pFeat^.rR3 + Value.rAmount
                        else
                            if (pSite^.status = _R4) then
                               pFeat^.rR4 := pFeat^.rR4 + Value.rAmount
                            else
                                if (pSite^.status = _R5) then
                                   pFeat^.rR5 := pFeat^.rR5 + Value.rAmount;

                {decriment the Feature current effective target}
                {increment the Feature deferred area}
                {decriment rCurrentSumArea}
                {decriment rCurrentAreaSqr}
                FeatArr.setValue(lFeatureIndex,pFeat);
           end;

           dispose(pFeat);

        finally

        end;

     except
           RptErrorStop('Exception in CalcDeferrSite Site: ' + pSite^.sName);
     end;
end;

procedure CalcUnDeferrSite(const pSite : sitepointer);
var
   lCount, lFeatureIndex : longint;
   pFeat : featureoccurrencepointer;
   Value : ValueFile_T;
begin
     try
        if (pSite^.richness > 0) then
        try
           new(pFeat);

           for lCount := 1 to pSite^.richness do
           begin
                FeatureAmount.rtnValue(pSite^.iOffset + lCount,@Value);
                lFeatureIndex := Value.iFeatKey;

                FeatArr.rtnValue(lFeatureIndex,pFeat);

                pFeat^.targetarea := pFeat^.targetarea + Value.rAmount;
                pFeat^.rDeferredArea := pFeat^.rDeferredArea - Value.rAmount;
                pFeat^.rCurrentSumArea := pFeat^.rCurrentSumArea + Value.rAmount;
                pFeat^.rCurrentAreaSqr := pFeat^.rCurrentAreaSqr + Sqr(Value.rAmount);
                if (pSite^.status = _R1) then
                   pFeat^.rR1 := pFeat^.rR1 - Value.rAmount
                else
                    if (pSite^.status = _R2) then
                       pFeat^.rR2 := pFeat^.rR2 - Value.rAmount
                    else
                        if (pSite^.status = _R3) then
                           pFeat^.rR3 := pFeat^.rR3 - Value.rAmount
                        else
                            if (pSite^.status = _R4) then
                               pFeat^.rR4 := pFeat^.rR4 - Value.rAmount
                            else
                                if (pSite^.status = _R5) then
                                   pFeat^.rR5 := pFeat^.rR5 - Value.rAmount;
                {increment the Feature current effective target}
                {decriment the Feature deferred area}
                {incriment rCurrentSumArea}
                {incriment rCurrentAreaSqr}

                FeatArr.setValue(lFeatureIndex,pFeat);
           end;

           dispose(pFeat);

        finally
               
        end;

     except
           RptErrorStop('Exception in CalcUnDeferrSite Site: ' + pSite^.sName);
     end;
end;

procedure CalcPartDeferrSite(const pSite : sitepointer);
var
   lCount, lFeatureIndex : longint;
   pFeat : featureoccurrencepointer;
   Value : ValueFile_T;
   fReserved : boolean;
begin
     try
        if (pSite^.richness > 0) then
        try
           new(pFeat);

           for lCount := 1 to pSite^.richness do
           begin
                SparsePartial.rtnValue(pSite^.iOffset + lCount,@fReserved);
                if fReserved then
                begin
                     FeatureAmount.rtnValue(pSite^.iOffset + lCount,@Value);
                     lFeatureIndex := Value.iFeatKey;

                     FeatArr.rtnValue(lFeatureIndex,pFeat);

                     pFeat^.targetarea := pFeat^.targetarea - Value.rAmount;
                     pFeat^.rDeferredArea := pFeat^.rDeferredArea + Value.rAmount;
                     pFeat^.rCurrentSumArea := pFeat^.rCurrentSumArea - Value.rAmount;
                     pFeat^.rCurrentAreaSqr := pFeat^.rCurrentAreaSqr - Sqr(Value.rAmount);
                     pFeat^.rPartial := pFeat^.rPartial + Value.rAmount;
                     {decriment the Feature current effective target}
                     {increment the Feature deferred area}
                     {decrement rCurrentSumArea}
                     {decriment rCurrentAreaSqr}

                     FeatArr.setValue(lFeatureIndex,pFeat);
                end;
           end;

        finally
               dispose(pFeat);
        end;

     except
           RptErrorStop('Exception in CalcPartDeferrSite Site: ' + pSite^.sName);
     end;
end;

procedure CalcUnPartDeferrSite(const pSite : sitepointer);
var
   lCount, lFeatureIndex : longint;
   pFeat : featureoccurrencepointer;
   Value : ValueFile_T;
   fReserved : boolean;
begin
     try
        if (pSite^.richness > 0) then
        try
           new(pFeat);

           for lCount := 1 to pSite^.richness do
           begin
                SparsePartial.rtnValue(pSite^.iOffset + lCount,@fReserved);
                if fReserved then
                begin
                     FeatureAmount.rtnValue(pSite^.iOffset + lCount,@Value);
                     lFeatureIndex := Value.iFeatKey;

                     FeatArr.rtnValue(lFeatureIndex,pFeat);

                     pFeat^.targetarea := pFeat^.targetarea + Value.rAmount;
                     pFeat^.rDeferredArea := pFeat^.rDeferredArea - Value.rAmount;
                     pFeat^.rCurrentSumArea := pFeat^.rCurrentSumArea + Value.rAmount;
                     pFeat^.rCurrentAreaSqr := pFeat^.rCurrentAreaSqr + Sqr(Value.rAmount);
                     pFeat^.rPartial := pFeat^.rPartial - Value.rAmount;
                     {increment the Feature current effective target}
                     {decriment the Feature deferred area}
                     {incriment rCurrentSumArea}
                     {incriment rCurrentAreaSqr}

                     FeatArr.setValue(lFeatureIndex,pFeat);
                end;
           end;

        finally
               dispose(pFeat);
        end;

     except
           RptErrorStop('Exception in CalcUnPartDeferrSite Site: ' + pSite^.sName);
     end;
end;

procedure CalcExcludeSite(const pSite : sitepointer);
var
   lCount, lFeatureIndex : longint;
   pFeat : featureoccurrencepointer;
   {$IFNDEF SPARSE_MATRIX_2}
   TmpExcSite : ExcSite_T;
   {$ENDIF}
   rUnReach, rToTrim : extended;
   fHello : boolean;
   Value : ValueFile_T;
begin
     try
        if (pSite^.richness > 0) then
        try
           new(pFeat);

           {$IFNDEF SPARSE_MATRIX_2}
           TmpExcSite.iSiteGeocode := pSite^.iKey;
           {$ENDIF}

           for lCount := 1 to pSite^.richness do
           begin
                FeatureAmount.rtnValue(pSite^.iOffset + lCount,@Value);
                lFeatureIndex := Value.iFeatKey;

                rToTrim := 0;

                FeatArr.rtnValue(lFeatureIndex,pFeat);

                pFeat^.rCurrentSumArea := pFeat^.rCurrentSumArea - Value.rAmount;
                pFeat^.rCurrentAreaSqr := pFeat^.rCurrentAreaSqr - Sqr(Value.rAmount);
                pFeat^.rExcluded := pFeat^.rExcluded + Value.rAmount;
                {decrement rCurrentSumArea}
                {decriment rCurrentAreaSqr}
                {increment rExcTotal}
                if (pFeat^.rCurrentSumArea < pFeat^.targetarea)
                {and (pFeat^.rCurrentSumArea > 0)}
                and (pFeat^.targetarea > 0) then
                begin
                     {trim target area to available amount if exclusions
                      will make it unreachable}

                     rToTrim := pFeat^.targetarea - pFeat^.rCurrentSumArea;

                     pFeat^.targetarea := pFeat^.rCurrentSumArea;
                end;

                {$IFNDEF SPARSE_MATRIX_2}
                TmpExcSite.featurearea[lCount] := rToTrim;
                {$ENDIF}

                FeatArr.setValue(lFeatureIndex,pFeat);
           end;

        finally
               dispose(pFeat);
        end
        else
        begin
             {$IFNDEF SPARSE_MATRIX_2}
             for lCount := 1 to max do
                 TmpExcSite.featurearea[lCount] := 0;
             {$ENDIF}
        end;

        {$IFNDEF SPARSE_MATRIX_2}
        //ExcludedSiteArea.AddExcludedSite(TmpExcSite);
        {$ENDIF}

     except
           RptErrorStop('Exception in CalcExcludeSite Site: ' + pSite^.sName);
     end;
end;

procedure CalcUnExcludeSite(const pSite : sitepointer);
var
   {$IFNDEF SPARSE_MATRIX_2}
   TmpExcSite : ExcSite_T;
   {$ENDIF}
   pFeat : featureoccurrencepointer;
   lCount, lFeatureIndex : longint;
   Value : ValueFile_T;
begin
     try
        {$IFNDEF SPARSE_MATRIX_2}
        //if ExcludedSiteArea.RemoveExcludedSite(pSite^.iKey,TmpExcSite) then
        {$ENDIF}
           if (pSite^.richness > 0) then
           try
              new(pFeat);

              for lCount := 1 to pSite^.richness do
              begin
                   FeatureAmount.rtnValue(pSite^.iOffset + lCount,@Value);
                   lFeatureIndex := Value.iFeatKey;
                   FeatArr.rtnValue(lFeatureIndex,pFeat);
                   {$IFNDEF SPARSE_MATRIX_2}
                   pFeat^.targetarea := pFeat^.targetarea + TmpExcSite.featurearea[lCount];
                   {$ENDIF}

                   pFeat^.rCurrentSumArea := pFeat^.rCurrentSumArea + Value.rAmount;
                   pFeat^.rCurrentAreaSqr := pFeat^.rCurrentAreaSqr + Sqr(Value.rAmount);
                   pFeat^.rExcluded := pFeat^.rExcluded - Value.rAmount;
                   {increment rCurrentSumArea}
                   {incriment rCurrentAreaSqr}
                   {decriment rExcTotal}
                   FeatArr.setValue(lFeatureIndex,pFeat);
              end;

           finally
                  dispose(pFeat);
           end;

     except
           RptErrorStop('Exception in CalcUnExcludeSite Site: ' + pSite^.sName);
     end;
end;

end.
