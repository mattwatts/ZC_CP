unit UpdateAverageSite;

interface

procedure RefreshAverageSite;

implementation

uses
    Global, Control, Sf_irrep, ds,
    Forms, Dialogs, Controls;

procedure RefreshAverageSite;
var
   pFeat : featureoccurrencepointer;
   pSite : sitepointer;
   iCount, iCount2 : integer;
   eAverageSite : extended;
   Value : ValueFile_T;
begin
     try
        new(pFeat);
        new(pSite);

        if not fAverageSiteCreated then
        begin
             AverageSite := Array_t.Create;
             AverageSite.init(SizeOf(extended),iFeatureCount);
             AverageInitialSite := Array_t.Create;
             AverageInitialSite.init(SizeOf(extended),iFeatureCount);
             fAverageSiteCreated := True;
        end;
        eAverageSite := 0;
        for iCount := 1 to iFeatureCount do
        begin
             //FeatArr.rtnValue(iCount,pFeat);

             //pFeat^.rCurrentSumArea := 0;
             //pFeat^.rCurrentAreaSqr := 0;

             //FeatArr.setValue(iCount,pFeat);

             AverageSite.setValue(iCount,@eAverageSite);
        end;

        {traverse sites and features for each site and find current sum area & average site}
        {for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);

             if ((pSite^.status = Av) or (pSite^.status = Fl))
             and (pSite^.richness > 0) then
                for iCount2 := 1 to pSite^.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffset + iCount2,@Value);
                     FeatArr.rtnValue(Value.iFeatKey,pFeat);

                     pFeat^.rCurrentSumArea := pFeat^.rCurrentSumArea + Value.rAmount;

                     pFeat^.rCurrentAreaSqr := pFeat^.rCurrentAreaSqr + sqr(Value.rAmount);
                     //eAverageSite := (pFeat^.rCurrentSumArea - pFeat^.rExcluded)*1.0/(ControlForm.Available.Items.Count+
                     //                                                           ControlForm.Flagged.Items.Count);
                     //AverageSite.setValue(Value.iFeatKey,@eAverageSite);
                     FeatArr.setValue(Value.iFeatKey,pFeat);
                end;
        end;}

        if ((ControlForm.Available.Items.Count+ControlForm.Flagged.Items.Count) > 0) then
           for iCount := 1 to iFeatureCount do
           begin
                FeatArr.rtnValue(iCount,pFeat);

                eAverageSite := (pFeat^.rCurrentSumArea - pFeat^.rExcluded)*1.0/(ControlForm.Available.Items.Count+
                                                                                 ControlForm.Flagged.Items.Count);
                AverageSite.setValue(iCount,@eAverageSite);
           end;

        dispose(pFeat);
        dispose(pSite);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RefreshAverageSite',mtError,[mbOk],0);
     end;
end;

end.
