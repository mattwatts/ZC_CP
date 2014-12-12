unit RedundancyCheck;
// Author : Matthew Watts
// Date : 1 Feb 2000
// Purpose : Implement new redundancy check method as specified by Bob Pressey
//           for use as an option in minimum set algorithms.

interface

uses
    ds, Dll_u1;

var
   iRedundantSites : integer;
   RedCheckExcludeSites : Array_t;

procedure MinimumSetRedundancyCheck(const fDebug, fRedundancyCheckOrder, fExcludeSites : boolean);
procedure MapRedundancyCheck;
procedure InitRedCheckExcludeSites;

implementation

uses
    global, control, opt1, highligh,
    dialogs, sysutils, forms, controls,
    toolmisc;


procedure InitRedCheckExcludeSites;
var
   iCount : integer;
   pSite : sitepointer;
   fExclude : boolean;
begin
     try
        if not ControlRes^.fRedCheckExcludeSitesCreated then
        begin
             RedCheckExcludeSites := Array_T.Create;
             RedCheckExcludeSites.init(SizeOf(boolean),iSiteCount);
        end;

        new(pSite);
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);
             if (pSite^.status = _R1)
             or (pSite^.status = _R2)
             or (pSite^.status = _R3)
             or (pSite^.status = _R4)
             or (pSite^.status = _R5)
             or (pSite^.status = Pd) then
                fExclude := True    // don't do a redundancy check on this site
             else
                 fExclude := False; // redundancy check this site if necessary
             RedCheckExcludeSites.setValue(iCount,@fExclude);
        end;
        dispose(pSite);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in InitRedCheckExcludeSites',mtError,[mbOk],0);
     end;
end;

function IsSiteRedundant(const iSiteKey : integer;
                         const fDebug : boolean) : boolean;
// returns TRUE if site is redundant
//         FALSE if site is not redundant
var
   iIndex, iCount : integer;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   Value : ValueFile_T;
   DebugFile : TextFile;
begin
     try
        // determine if this site is redundant
        // ie. for each feature in the site
        //       subtract amount in site from reserved amount for the feature
        //       is the feature now satisfied ?

        // True (redundant) is the default
        Result := True;

        new(pSite);
        new(pFeat);
        iIndex := FindIntegerMatch(OrdSiteArr,iSiteKey);
        SiteArr.rtnValue(iIndex,pSite);

        if (pSite^.richness > 0) then
           for iCount := 1 to pSite^.richness do
           begin
                // examine a feature at the site
                FeatureAmount.rtnValue(pSite^.iOffset + iCount,@Value);
                FeatArr.rtnValue(Value.iFeatKey,pFeat);
                // if (the target with this site deselected is above zero)
                // then (we need this site ,ie. it is not redundant)
                if ((pFeat^.targetarea + Value.rAmount) > 0) then
                   // this site is needed for this feature
                   Result := False;

                if fDebug then
                begin
                     // append information to the debug file
                     assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\MinimumSetRedundancyCheck_debug.csv');
                     append(DebugFile);
                     writeln(DebugFile,IntToStr(pSite^.iKey) + ',' +
                                       IntToStr(Value.iFeatKey) + ',' +
                                       FloatToStr(pFeat^.targetarea) + ',' +
                                       FloatToStr(Value.rAmount) + ',' +
                                       FloatToStr(pFeat^.targetarea + Value.rAmount) + ',' +
                                       Bool2String(Result));
                     closefile(DebugFile);
                end;
           end;

        dispose(pSite);
        dispose(pFeat);

        // see if irr is 0

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Minimum Set redundancy check at site ' + IntToStr(iSiteKey),
                      mtError,[mbOk],0);
     end;
end;

procedure DeSelectThisSite(const iSiteKey : integer);
var
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
   HighlightArr : Array_t;
begin
     with ControlForm do
     try
        // Deselect this site from either Negotiated or Mandatory using
        // the C-Plan interface selection routines.

        UnHighlight(R1,False);
        UnHighlight(R2,False);
        UnHighlight(R3,False);
        UnHighlight(R4,False);
        UnHighlight(R5,False);

        HighlightArr := Array_t.Create;
        HighlightArr.init(SizeOf(integer),1);
        HighlightArr.setValue(1,@iSiteKey);
        Arr2Highlight(HighlightArr,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);
        HighlightArr.Destroy;

        Inc(iRedundantSites);

        if (R1.SelCount > 0) then
           MoveGroup(R1,R1Key,
                     Available,AvailableKey,False,True);
        if (R2.SelCount > 0) then
           MoveGroup(R2,R2Key,
                     Available,AvailableKey,False,True);
        if (R3.SelCount > 0) then
           MoveGroup(R3,R3Key,
                     Available,AvailableKey,False,True);
        if (R4.SelCount > 0) then
           MoveGroup(R4,R4Key,
                     Available,AvailableKey,False,True);
        if (R5.SelCount > 0) then
           MoveGroup(R5,R5Key,
                     Available,AvailableKey,False,True);

     except

     end;
end;

procedure MinimumSetRedundancyCheck(const fDebug, fRedundancyCheckOrder, fExcludeSites : boolean);
// method : parse the list of sites that have been selected (negotiated and mandatory sites),
//          deselecting each redundant sites in turn as we come to it (and adjusting targets)
//          then continuing through the list of sites.
//
// fRedundancyCheckOrder = FALSE means downto
//                         TRUE        to
var
   ListOfSelectedSites : Array_t;
   iListOfSelectedSites, iCount, iKey, iSiteIndex : integer;
   fRedundant, fExclude : boolean;
   DebugFile : TextFile;

   procedure AddKeyToList(const iSiteKey : integer);
   begin
        Inc(iListOfSelectedSites);
        if (ListOfSelectedSites.lMaxSize < iListOfSelectedSites) then
           ListOfSelectedSites.resize(ListOfSelectedSites.lMaxSize + ARR_STEP_SIZE);
        ListOfSelectedSites.setValue(iListOfSelectedSites,@iSiteKey);
   end;

begin
     try
        if fDebug then
           if (not FileExists(ControlRes^.sWorkingDirectory + '\MinimumSetRedundancyCheck_debug.csv')) then
           begin
                // create the debug file for the redundancy check if it doesn't exist
                assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\MinimumSetRedundancyCheck_debug.csv');
                rewrite(DebugFile);
                writeln(DebugFile,'SiteKey,FeatKey,targetarea,amount,targetarea+amount,is redundant');
                closefile(DebugFile);
           end;

        iListOfSelectedSites := 0;
        // make a list of selected sites (negotiated and mandatory)
        if (ControlForm.R1.Items.Count > 0)
        or (ControlForm.R2.Items.Count > 0)
        or (ControlForm.R3.Items.Count > 0)
        or (ControlForm.R4.Items.Count > 0)
        or (ControlForm.R5.Items.Count > 0) then
        begin
             ListOfSelectedSites := Array_t.Create;
             ListOfSelectedSites.init(SizeOf(integer),ARR_STEP_SIZE);

             if (ControlForm.R1.Items.Count > 0) then
                for iCount := 0 to (ControlForm.R1.Items.Count-1) do
                    AddKeyToList(StrToInt(ControlForm.R1Key.Items.Strings[iCount]));

             if (ControlForm.R2.Items.Count > 0) then
                for iCount := 0 to (ControlForm.R2.Items.Count-1) do
                    AddKeyToList(StrToInt(ControlForm.R2Key.Items.Strings[iCount]));

             if (ControlForm.R3.Items.Count > 0) then
                for iCount := 0 to (ControlForm.R3.Items.Count-1) do
                    AddKeyToList(StrToInt(ControlForm.R3Key.Items.Strings[iCount]));

             if (ControlForm.R4.Items.Count > 0) then
                for iCount := 0 to (ControlForm.R4.Items.Count-1) do
                    AddKeyToList(StrToInt(ControlForm.R4Key.Items.Strings[iCount]));

             if (ControlForm.R5.Items.Count > 0) then
                for iCount := 0 to (ControlForm.R5.Items.Count-1) do
                    AddKeyToList(StrToInt(ControlForm.R5Key.Items.Strings[iCount]));

             // parse the list of selected sites
             if fRedundancyCheckOrder then
                for iCount := 1 to iListOfSelectedSites do
                begin
                     // test if site is redundant and needs to be deselected
                     ListOfSelectedSites.rtnValue(iCount,@iKey);
                     if fExcludeSites then
                     begin
                          // we need to test if this site is excluded
                          iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
                          RedCheckExcludeSites.rtnValue(iSiteIndex,@fExclude);
                     end
                     else
                         fExclude := False;
                     if not fExclude then
                        if IsSiteRedundant(iKey,fDebug) then
                           // site is redundant, so deselect it
                           DeSelectThisSite(iKey);
                end
             else
                 for iCount := iListOfSelectedSites downto 1 do
                 begin
                      // test if site is redundant and needs to be deselected
                      ListOfSelectedSites.rtnValue(iCount,@iKey);
                      if fExcludeSites then
                      begin
                           // we need to test if this site is excluded
                           iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
                           RedCheckExcludeSites.rtnValue(iSiteIndex,@fExclude);
                      end
                      else
                          fExclude := False;
                      if not fExclude then
                         if IsSiteRedundant(iKey,fDebug) then
                            // site is redundant, so deselect it
                            DeSelectThisSite(iKey);
                 end;

             ListOfSelectedSites.Destroy;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Minimum Set redundancy check',
                      mtError,[mbOk],0);
     end;
end;

procedure MapRedundancyCheck;
// method : parse the list of sites that have been selected (negotiated and mandatory and partial sites),
//          and map the redundant sites
var
   ListOfSelectedSites, SitesToMap : Array_t;
   iListOfSelectedSites, iSitesToMap, iCount, iKey : integer;
   fRedundant : boolean;
   DebugFile : TextFile;

   procedure AddKeyToList(const iSiteKey : integer);
   begin
        Inc(iListOfSelectedSites);
        if (ListOfSelectedSites.lMaxSize < iListOfSelectedSites) then
           ListOfSelectedSites.resize(ListOfSelectedSites.lMaxSize + ARR_STEP_SIZE);
        ListOfSelectedSites.setValue(iListOfSelectedSites,@iSiteKey);
   end;

begin
     try
        Screen.Cursor := crHourglass;

        iListOfSelectedSites := 0;
        // make a list of selected sites (negotiated and mandatory)
        if (ControlForm.R1.Items.Count > 0)
        or (ControlForm.R2.Items.Count > 0)
        or (ControlForm.R3.Items.Count > 0)
        or (ControlForm.R4.Items.Count > 0)
        or (ControlForm.R5.Items.Count > 0) then
        begin
             ListOfSelectedSites := Array_t.Create;
             ListOfSelectedSites.init(SizeOf(integer),ARR_STEP_SIZE);

             SitesToMap := Array_t.Create;
             SitesToMap.init(SizeOf(integer),ARR_STEP_SIZE);
             iSitesToMap := 0;

             if (ControlForm.R1.Items.Count > 0) then
                for iCount := 0 to (ControlForm.R1.Items.Count-1) do
                    AddKeyToList(StrToInt(ControlForm.R1Key.Items.Strings[iCount]));

             if (ControlForm.R2.Items.Count > 0) then
                for iCount := 0 to (ControlForm.R2.Items.Count-1) do
                    AddKeyToList(StrToInt(ControlForm.R2Key.Items.Strings[iCount]));

             if (ControlForm.R3.Items.Count > 0) then
                for iCount := 0 to (ControlForm.R3.Items.Count-1) do
                    AddKeyToList(StrToInt(ControlForm.R3Key.Items.Strings[iCount]));

             if (ControlForm.R4.Items.Count > 0) then
                for iCount := 0 to (ControlForm.R4.Items.Count-1) do
                    AddKeyToList(StrToInt(ControlForm.R4Key.Items.Strings[iCount]));

             if (ControlForm.R5.Items.Count > 0) then
                for iCount := 0 to (ControlForm.R5.Items.Count-1) do
                    AddKeyToList(StrToInt(ControlForm.R5Key.Items.Strings[iCount]));

             if (ControlForm.Partial.Items.Count > 0) then
                for iCount := 0 to (ControlForm.Partial.Items.Count-1) do
                    AddKeyToList(StrToInt(ControlForm.PartialKey.Items.Strings[iCount]));

             // parse the list of selected sites
             for iCount := iListOfSelectedSites downto 1 do
             begin
                  // test if site is redundant and needs to be deselected
                  ListOfSelectedSites.rtnValue(iCount,@iKey);
                  if IsSiteRedundant(iKey,False) then
                  begin
                       // site is redundant, so add it to list
                       Inc(iSitesToMap);
                       if (iSitesToMap > SitesToMap.lMaxSize) then
                          SitesToMap.resize(SitesToMap.lMaxSize + ARR_STEP_SIZE);
                       SitesToMap.setValue(iSitesToMap,@iKey);
                  end;
             end;

             ListOfSelectedSites.Destroy;
             // map the sites
             if (iSitesToMap > 0) then
             begin
                  if (iSitesToMap <> SitesToMap.lMaxSize) then
                     SitesToMap.resize(iSitesToMap);
                  MapSites(SitesToMap,False);
                  Screen.Cursor := crDefault;
                  if (iSitesToMap = 1) then
                     MessageDlg('There is 1 redundant site',mtInformation,[mbOk],0)
                  else
                      MessageDlg('There are ' + IntToStr(iSitesToMap) + ' redundant sites',mtInformation,[mbOk],0);
             end
             else
             begin
                  Screen.Cursor := crDefault;
                  MessageDlg('There are no redundant sites',mtInformation,[mbOk],0);;
             end;
             SitesToMap.Destroy;
        end;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Map redundancy check',
                      mtError,[mbOk],0);
     end;
end;

end.
