unit Dde_unit;
{Author: Matthew Watts
 Date:
 Purpose: this is the unit for dynamic data exchange communication with WinERMS}

{$I STD_DEF.PAS}

interface

uses
    Em_newu1, Global,
    ds, Options, Dll_u1, ddeman;



function DDEOpenMapLink : boolean;
function DDEOpenSystemLink : boolean;
function DDECloseLinks : boolean;
function DDERefresh(const iWERMSLayer : integer) : boolean;
function DDEUpdate : boolean;
function DDEShowLookup(const fFlag : boolean) : boolean;
function DDESendNotify(const fFlag : boolean) : boolean;
function DDELookup(const sItem : string;
                   const iWERMSVariable : integer): boolean;
function DDEGetLayerInfo(const sWERMSLayer : string;
                         var sWERMSVariable : string;
                         var iWERMSVariable : integer) : boolean;
procedure DDEGetSystemInfo;
procedure UseGISKey(const iThisGeocode : integer;
                        const fMinimizeControl : boolean);
procedure DdeSelectionDataChange;
procedure DdeToggleLookup;
{specific DDE functions}

function DDEOpenLink(var ThisDDEConv : TDDEClientConv; const sServName, sTopicName : string)
                    : boolean;
function DDEGetInfo(const ThisDDEConv : TDDEClientConv; const sItemName : string) : PChar;
function DDESendCmd(const ThisDDEConv : TDDEClientConv; const sCommand : string): boolean;
{generic DDE functions}

function TrimActiveTopic(const sDdeData : string) : string;
function TrimGeocode(const sLine : string) : integer;

procedure ParseDDEData(const pData : PChar);
function LengthPChar(const pLine : PChar) : integer;

function ShowFeatureForm(const iGeo : integer) : boolean;
{lookup feature irreplacabilties for site/sites}

function DDECreate(const iWERMSLayer : integer): boolean;

procedure UseGISKeys(SitesSelected : Array_T);

var
   iClickSite, iMultiSiteCount : integer {site};
   MultiSites : Array_t;

implementation

uses Control, Dialogs, SysUtils {,Testdde}, Lookup, Contribu, Forms,
     Controls, Sf_irrep, Featgrid, Toolmisc,
     Opt1, Toolview, Highligh;

function DDEOpenLink(var ThisDDEConv : TDDEClientConv;
                     const sServName, sTopicName : string) : boolean;
begin
     {attempt to open a link with ThisDDEConv to a named sServName and sTopicName}

     ThisDDEConv.SetLink(sServName,sTopicName);

     if ThisDDEConv.OpenLink then
     begin
          Result := True;
     end
     else
     begin
          Screen.Cursor := crDefault;
          MessageDlg('Unable to link to ' + sServName + ' ' + sTopicName, mtInformation, [mbOK], 0);
          Screen.Cursor := crHourglass;
          Result := False;
     end;
end;

function DDEGetInfo(const ThisDDEConv : TDDEClientConv;
                    const sItemName : string) : PChar;
begin
     {request data on sItemName from ThisDDEConv}
     Result := ThisDDEConv.RequestData(sItemName);
end;


function DDEOpenSystemLink : boolean;
begin
     with ControlForm do
     begin
          Result := DDEOpenLink(SystemConv,SERVICE_NAME,'System');

          {SystemItem.DdeItem := 'Selection';}

          {SystemConv.PokeData(SystemItem.DDEItem,'Selection');
          SystemItem.DdeItem := 'Selection';}
     end;
end;

procedure DdeToggleLookup;
begin
     {this is triggered after the ControlForm is created and displayed as
      a hack to switch off DDEShowLookup, because calling it from
      DDEOpenMapLink leaves the internal WinERMS DBMS Lookup on}
     DDEShowLookup(True);
     DDEShowLookup(False);
end;

function DDEOpenMapLink : boolean;
begin
     Result := DDEOpenLink(ControlForm.MapConv,SERVICE_NAME,ControlRes^.sTopic);
     {sTopic is a variable from the ControlForm which
      holds the current map topic}

     if Result then
     begin
          DDESendNotify(True);
          {tell WinERMS to send a XTYP_ADVDATA message when user clicks on a site
           (for the site selection DDE hot-link)}
          DDEShowLookup(False);
          {tell WinERMS to stop doing an internal DBMS lookup when user clicks
           on a site. by default we will switch this off because the Conservation
           Tool has its own DBMS Lookup Grid and we are using the WinERMS Click
           for our own site selection and DBMS Lookup, the user can switch
           it back on if necessary}
     end;
end;

function DDECloseLinks;
begin
     Result := False;

     if (ControlRes^.GISLink = ArcView) then
     begin
          try
             DDE_CloseArcView;
             Result := True;

          except
                Screen.Cursor := crDefault;
                MessageDlg('exception in DDE_CloseArcView',mtError,[mbOk],0);
          end;
     end;
end;

function DDESendSystemCmd(const sCommand : string): boolean;
begin
     Result := DDESendCmd(ControlForm.SystemConv,sCommand);
end;

function DDESendCmd(const ThisDDEConv : TDDEClientConv; const sCommand : string): boolean;
var
   MacroCmd : array [0..80] of char;
begin
     {send a command macro to the server}

     StrPCopy(MacroCmd,sCommand);
     {pascal string to null terminated string}

     if (ThisDDEConv.ExecuteMacro(MacroCmd,False) = False) then
     begin
          Result := False;
     end
     else
     begin
          Result := True;
     end;
end;

function DDECreate(const iWERMSLayer : integer): boolean;
begin {refresh all categories within a named WinERMS variable}

     if (fDDEConnected = False) then
     begin
          Result := False;
     end
     else
         Result := DDESendCmd(ControlForm.MapConv,
                              '[create( ' + IntToStr(iWERMSLayer) + ' )]');
end;

function DDERefresh(const iWERMSLayer : integer): boolean;
begin {refresh all categories within a named WinERMS variable}

     if (fDDEConnected = False) then
     begin
          Result := False;
     end
     else
         Result := DDESendCmd(ControlForm.MapConv,'[refresh( ' + IntToStr(iWERMSLayer) + ' )]');
end;

function DDEUpdate : boolean;
begin {update WinERMS display from new categories which have been written to disk}

     Result := True;

     if (fDDEConnected = False) then
     begin
          Result := False;
     end
     else
         if DDESendCmd(ControlForm.MapConv,'[update( base )]') then
            Result := DDESendCmd(ControlForm.MapConv,'[update( top )]');
end;

function DDELookup(const sItem : string;
                   const iWERMSVariable : integer): boolean;
begin {do a named internal WinERMS DB lookup}

     if (fDDEConnected = False) then
     begin
          Result := False;
     end
     else
         Result := DDESendCmd(ControlForm.MapConv,
                              '[lookup( ' + IntToStr(iWERMSVariable)
                              + ', "' + sItem + '" )]');
end;

function DDESendNotify(const fFlag : boolean) : boolean;
begin {switch on/off fDDENotify in WinERMS}

     if fDDEConnected then
        Result := DDESendCmd(ControlForm.MapConv,'[assign ( fNotifyDDE, '
                      + Bool2String(fFlag) + ' )]')
     else
     begin
          Result := False;
     end;
end;

function DDEShowLookup(const fFlag : boolean) : boolean;
begin {switch on/off fShowLookup in WinERMS}

     if (fDDEConnected = False) then
     begin
          Result := False;
     end
     else
         Result := DDESendCmd(ControlForm.MapConv,
                              '[assign( fShowLookup, ' + Bool2String(fFlag) + ' )]');
end;

function DDEGetLayerInfo(const sWERMSLayer : string;
                         var sWERMSVariable : string;
                         var iWERMSVariable : integer) : boolean;
{pERMSData is in the format:
 INT,STRING[TAB]...}
{get data on a named WinERMS map layer}
var
   pERMSData : PChar;
   sData, sTmp : string;
   iCount : integer;
begin
   Result := True;

   if (fDDEConnected = False) then
   begin
        Result := False;
        sWERMSVariable := 'nothing';
        iWERMSVariable := 0;
   end
   else
   begin
     pERMSData := ControlForm.MapConv.RequestData(sWERMSLayer);

     if (pERMSData <> nil) then
     begin
          sData := StrPas(pERMSData);
          if (sData[1] = '<') and (sData[2] = 'd') then
          begin
               {layer disabled}
               Result := False;
               sWERMSVariable := 'disabled';
               iWERMSVariable := 0;
          end
          else
          begin
               {layer ok}
               iCount := 1;
               sTmp := '';
               while (sData[iCount] <> ',') do {go to first ,}
               begin
                    sTmp := sTmp + sData[iCount];
                    Inc(iCount);
               end;
               Inc(iCount); {advance past ,}

               iWERMSVariable := StrToInt(sTmp);
               sTmp := '';
               while (ord(sData[iCount]) <> 9) do {go to first tab}
               begin
                    sTmp := sTmp + sData[iCount];
                    Inc(iCount);
               end;

               sWERMSVariable := sTmp;
               Result := True;
          end;
     end;
   end;
end;

function LengthPChar(const pLine : PChar) : integer;
var
   pTmp : PChar;
   iCount : integer;
begin
     pTmp := pLine;
     iCount := 1;

     while (pTmp[1] <> #0) do
     begin
          pTmp := pTmp + 1;
          Inc(iCount);
     end;

     Result := iCount;
end;

procedure ParseDDEData(const pData : PChar);
{pData points to a tab delimited null terminated string
 containing 6 fields}
var
   sNorth, sEast, sKey, sData : string;
   iItemCategory, iCategory, iItem, iPrevPosInData, iPosInData : integer;
begin
     sData := StrPas(pData);
     iPosInData := 1;
     while (sData[iPosInData] <> Chr(9){TAB}) do
           Inc(iPosInData);

     sNorth := Copy(sData,1,iPosInData-1);
     iPrevPosInData := iPosInData;
     Inc(iPosInData);

     while (sData[iPosInData] <> Chr(9)) do
           Inc(iPosInData);

     sEast := Copy(sData,iPrevPosInData+1,(iPosInData-iPrevPosInData));
     iPrevPosInData := iPosInData;
     Inc(iPosInData);

     while (sData[iPosInData] <> Chr(9)) do
           Inc(iPosInData);

     sKey := Copy(sData,iPrevPosInData+1,(iPosInData-iPrevPosInData));
     iPrevPosInData := iPosInData;
     Inc(iPosInData);

     while (sData[iPosInData] <> Chr(9)) do
           Inc(iPosInData);

     iItemCategory := StrToInt(Copy(sData,iPrevPosInData+1,
                        (iPosInData-iPrevPosInData)));
     iPrevPosInData := iPosInData;
     Inc(iPosInData);

     while (sData[iPosInData] <> Chr(9)) do
           Inc(iPosInData);

     iCategory := StrToInt(Copy(sData,iPrevPosInData+1,
                    (iPosInData-iPrevPosInData)));
     iItem := StrToInt(Copy(sData,iPosInData+1,Length(sData)-iPosInData));
end;

function TrimActiveTopic(const sDdeData : string) : string;
var
   iPosInString : integer;
begin
     {determine WinERMS active topic from 'Topics' string}

     iPosInString := 1;

     while (iPosInString <= Length(sDdeData)) and (sDdeData[iPosInString] <> Chr(9)) do
           Inc(iPosInString);

     Result := Copy(sDdeData,1,iPosInString-1);
end;

procedure DDEGetSystemInfo;
var
   pSysData : PChar;
   sServerActiveTopic : string;
   wOldCursor : integer;
begin
     {get data from servers System conversation on what the current active topic is}

     pSysData := ControlForm.SystemConv.RequestData('Topics');

     try
        sServerActiveTopic := TrimActiveTopic(StrPas(pSysData));
     except on Exception do Exit;
     end;
     if (AnsiLowerCase(sServerActiveTopic) <> AnsiLowerCase(ControlRes^.sTopic)) then
     begin
          ControlRes^.sTopic := AnsiLowerCase(sServerActiveTopic);

          wOldCursor := Screen.Cursor;
          Screen.Cursor := crDefault;
          MessageDlg(SERVICE_NAME + ' Active Topic is '
                     + ControlRes^.sTopic,mtInformation,[mbOK],0);
          Screen.Cursor := wOldCursor;
     end;

     {pSysData := ControlForm.SystemConv.RequestData('SysItems');
     ShowDDEData(pSysData);
     pSysData := ControlForm.SystemConv.RequestData('TopicItemList');
     ShowDDEData(pSysData);
     pSysData := ControlForm.SystemConv.RequestData('Help');
     ShowDDEData(pSysData);}
end;

function DisplayFeatureForm(const iGeo : integer) : boolean;
var
   iSiteIndex : integer;
   pSite : sitepointer;
   sType : string;
   LookupSites : Array_t;
begin
     if not ControlRes^.fFeatureFormUp then
     begin
          Screen.Cursor := crDefault;
          if not fContrDataDone then
             {if (mrYes = MessageDlg('Contribution Data Not Current.  Recalculate and Show Features?',
                 mtConfirmation,[mbYes,mbNo],0)) then}
             begin
                  Screen.Cursor := crHourglass;
                  ExecuteIrreplaceability(-1,False,False,True,True,'');
             end;

          if fContrDataDone then
          begin
               Screen.Cursor := crHourglass;

               if (iGeo = NULL_SITE_GEOCODE) then
               begin
                    {ControlRes^.fFeatureFormUp := True;}

                    {we are dealing with multiple sites highlighted in the
                     Available list box}
                    fSingleSite := False;

                    iClickSite := NULL_SITE_GEOCODE;

                    if (not ControlRes^.fFeatureFormUp) then
                    begin
                         ControlRes^.fFeatureFormUp := True;
                         //FeatGridForm := TFeatGridForm.Create(Application);
                         Screen.Cursor := crDefault;
                         if FeatGridForm.Visible then
                            FeatGridForm.Visible := False;
                         FeatGridForm.Show;
                         //if (FeatGridForm.FeatGrid.ColCount > 1) then
                         //   FeatGridForm.ShowModal;
                         //FeatGridForm.Free;
                    end
                    else
                    begin
                         Screen.Cursor := crDefault;
                         MessageDlg('Features form is already open.  Close the form first.',mtInformation,[mbOk],0);
                    end;

                    {ControlRes^.fFeatureFormUp := False;}
               end
               else
               begin
                    {we are dealing with a single site identified by iGeo}
                    fSingleSite := True;
                    new(pSite);

                    iSiteIndex := FindFeatMatch(OrdSiteArr,iGeo);
                    iClickSite := iGeo;
                    SiteArr.rtnValue(iSiteIndex,pSite);
                    Screen.Cursor := crDefault;
                    {find info for this site}
                    if (pSite^.richness > 0) then
                    begin
                         // look up this site to the site grid
                         if Highlight2Arr(LookupSites) then
                            StartLookupArr(LookupSites);

                         ControlRes^.fFeatureFormUp := True;
                         FeatGridForm.btnAccept.Visible := True;
                         if FeatGridForm.Visible then
                            FeatGridForm.Visible := False;
                         FeatGridForm.Show;
                         FeatGridForm.btnAccept.Visible := False;
                         {call feature irreplacability for this site}
                    end
                    else
                    begin
                         {this site has no features}

                         MessageDlg('Site has no Features',
                                    mtInformation,[mbOK],0);
                    end;

                    dispose(pSite);
               end;

               Result := True;

               Screen.Cursor := crDefault;
          end;

          ControlRes^.fFeatureFormUp := False;
     end
     else
     begin
          Screen.Cursor := crDefault;
          MessageDlg('Features form is already open.  Close the form first.',mtInformation,[mbOk],0);
     end;
end;

function ShowFeatureForm(const iGeo : integer) : boolean;
var
   iSiteIndex : integer;
   pSite : sitepointer;
   sType : string;
   LookupSites : Array_t;
begin
     if not ControlRes^.fFeatureFormUp then
     begin
          DisplayFeatureForm(iGeo);
     end
     else
     begin
          Screen.Cursor := crDefault;
          MessageDlg('Features form is already open.  Close the form first.',mtInformation,[mbOk],0);
     end;
end;

function DeSelectSite(const iGeo : integer) : boolean;
var
   fSiteFound : boolean;
   sCat : string;
   iCount : integer;

   ASite : site;
   iSiteIndex : integer;

begin
     fSiteFound := False;

     ControlRes^.fDeSelectSite := True;

     with ControlForm do
     begin
          iSiteIndex := FindFeatMatch(OrdSiteArr,iGeo);
          SiteArr.rtnValue(iSiteIndex,@ASite);

          if (ASite.status = Ig) then
          begin
               {ASite has TENURE Ignored}

               fSiteFound := True;

               MessageDlg('Cannot De-Select Site ' + IntToStr(iGeo) +
                          ', it is Ignored',
                          mtInformation,[mbOK],0);
          end
          else
          if (ASite.status = Re) then
          begin
               {ASite has TENURE Reserved}

               fSiteFound := True;

               MessageDlg('Cannot De-Select Site ' + IntToStr(iGeo) +
                          ', it is an Pre-Existing Reserve',
                          mtInformation,[mbOK],0);
          end
          else
          begin
               {ASite has TENURE Available}

               UnHighlight(R1,fKeepHighlight);
               UnHighlight(R2,fKeepHighlight);
               UnHighlight(R3,fKeepHighlight);
               UnHighlight(R4,fKeepHighlight);
               UnHighlight(R5,fKeepHighlight);
               UnHighlight(Excluded,fKeepHighlight);
               UnHighlight(Partial,fKeepHighlight);
               UnHighlight(Flagged,fKeepHighlight);

               for iCount := 1 to R1.Items.Count do
                   if (R1Key.Items.Strings[iCount-1] = IntToStr(iGeo)) then
                   begin
                        R1.Selected[iCount-1]:= True;
                        fSiteFound := True;
                        sCat := ControlRes^.sR1Label;
                   end;
               if not fSiteFound
               and (R2.Items.Count > 0) then
               for iCount := 1 to R2.Items.Count do
                   if (R2Key.Items.Strings[iCount-1] = IntToStr(iGeo)) then
                   begin
                        R2.Selected[iCount-1]:= True;
                        fSiteFound := True;
                        sCat := ControlRes^.sR2Label;
                   end;
               if not fSiteFound
               and (R3.Items.Count > 0) then
               for iCount := 1 to R3.Items.Count do
                   if (R3Key.Items.Strings[iCount-1] = IntToStr(iGeo)) then
                   begin
                        R3.Selected[iCount-1]:= True;
                        fSiteFound := True;
                        sCat := ControlRes^.sR3Label;
                   end;
               if not fSiteFound
               and (R4.Items.Count > 0) then
               for iCount := 1 to R4.Items.Count do
                   if (R4Key.Items.Strings[iCount-1] = IntToStr(iGeo)) then
                   begin
                        R4.Selected[iCount-1]:= True;
                        fSiteFound := True;
                        sCat := ControlRes^.sR4Label;
                   end;
               if not fSiteFound
               and (R5.Items.Count > 0) then
               for iCount := 1 to R5.Items.Count do
                   if (R5Key.Items.Strings[iCount-1] = IntToStr(iGeo)) then
                   begin
                        R5.Selected[iCount-1]:= True;
                        fSiteFound := True;
                        sCat := ControlRes^.sR5Label;
                   end;
               if not fSiteFound
               and (Excluded.Items.Count > 0) then
               for iCount := 1 to Excluded.Items.Count do
                   if (ExcludedKey.Items.Strings[iCount-1] = IntToStr(iGeo)) then
                   begin
                        Excluded.Selected[iCount-1]:= True;
                        fSiteFound := True;
                        sCat := 'Excluded';
                   end;
               if not fSiteFound
               and (Partial.Items.Count > 0) then
               for iCount := 1 to Partial.Items.Count do
                   if (PartialKey.Items.Strings[iCount-1] = IntToStr(iGeo)) then
                   begin
                        Partial.Selected[iCount-1]:= True;
                        fSiteFound := True;
                        sCat := 'Partial';
                   end;
               if not fSiteFound
               and (Flagged.Items.Count > 0) then
               for iCount := 1 to Flagged.Items.Count do
                   if (FlaggedKey.Items.Strings[iCount-1] = IntToStr(iGeo)) then
                   begin
                        Flagged.Selected[iCount-1]:= True;
                        fSiteFound := True;
                        sCat := 'Flagged';
                   end;

               if fSiteFound then
               begin
                    {check site tenure, if Existing Reserve, skip this step}

                    if (mrYes = MessageDlg('Site ' + IntToStr(iGeo) + ' is ' +
                                       sCat + '.  De-Select it?',mtConfirmation,
                                       [mbYes,mbNo],0)) then
                    begin
                         if (R1.SelCount > 0) then
                            MoveGroup(R1,R1Key,Available,AvailableKey,TRUE,True)
                         else
                         if (R2.SelCount > 0) then
                            MoveGroup(R2,R2Key,Available,AvailableKey,TRUE,True)
                         else
                         if (R3.SelCount > 0) then
                            MoveGroup(R3,R3Key,Available,AvailableKey,TRUE,True)
                         else
                         if (R4.SelCount > 0) then
                            MoveGroup(R4,R4Key,Available,AvailableKey,TRUE,True)
                         else
                         if (R5.SelCount > 0) then
                            MoveGroup(R5,R5Key,Available,AvailableKey,TRUE,True)
                         else
                         if (Excluded.SelCount > 0) then
                            MoveGroup(Excluded,ExcludedKey,Available,AvailableKey,TRUE,True)
                         else
                         if (Partial.SelCount > 0) then
                            MoveGroup(Partial,PartialKey,Available,AvailableKey,TRUE,True)
                         else
                         if (Flagged.SelCount > 0) then
                            MoveGroup(Flagged,FlaggedKey,Available,AvailableKey,TRUE,True);

                         Available.Selected[Available.Items.Count-1] := True;
                    end
                    else
                    begin
                         UnHighlight(R1,fKeepHighlight);
                         UnHighlight(R2,fKeepHighlight);
                         UnHighlight(R3,fKeepHighlight);
                         UnHighlight(R4,fKeepHighlight);
                         UnHighlight(R5,fKeepHighlight);
                         UnHighlight(Excluded,fKeepHighlight);
                         UnHighlight(Partial,fKeepHighlight);
                         UnHighlight(Flagged,fKeepHighlight);
                    end;
               end
               else
               begin
                    {site not found!}
                    MessageDlg('DeSelectSite, site not found ' + IntToStr(iGeo),
                               mtError,[mbOK],0);
               end;
          end;
     end;

     Result := fSiteFound;
     ControlRes^.fDeSelectSite := False;
end;

function FindStatusHighlight(const iThisGeocode : integer) : Status_T;
var
   iCount : integer;
   fSiteFound : boolean;
begin
     fSiteFound := False;

     Result := Ig;

     with ControlForm do
     begin
          if (Available.Items.Count > 0) then
             for iCount := 1 to Available.Items.Count do
                 if (AvailableKey.Items.Strings[iCount-1] = IntToStr(iThisGeocode)) then
                 begin
                      if Available.Selected[iCount-1] then
                         Available.Selected[iCount-1] := False
                      else
                          Available.Selected[iCount-1] := True;

                      fSiteFound := True;
                      Result := Av;
                 end;

          if not fSiteFound
          and (R1.Items.Count > 0) then
          for iCount := 1 to R1.Items.Count do
              if (R1Key.Items.Strings[iCount-1] = IntToStr(iThisGeocode)) then
              begin
                   if R1.Selected[iCount-1] then
                      R1.Selected[iCount-1] := False
                   else
                       R1.Selected[iCount-1]:= True;
                   fSiteFound := True;
                   Result := _R1;
              end;
          if not fSiteFound
          and (R2.Items.Count > 0) then
          for iCount := 1 to R2.Items.Count do
              if (R2Key.Items.Strings[iCount-1] = IntToStr(iThisGeocode)) then
              begin
                   if R2.Selected[iCount-1] then
                      R2.Selected[iCount-1] := False
                   else
                       R2.Selected[iCount-1]:= True;
                   fSiteFound := True;
                   Result := _R2;
              end;
          if not fSiteFound
          and (R3.Items.Count > 0) then
          for iCount := 1 to R3.Items.Count do
              if (R3Key.Items.Strings[iCount-1] = IntToStr(iThisGeocode)) then
              begin
                   if R3.Selected[iCount-1] then
                      R3.Selected[iCount-1] := False
                   else
                       R3.Selected[iCount-1]:= True;
                   fSiteFound := True;
                   Result := _R3;
              end;
          if not fSiteFound
          and (R4.Items.Count > 0) then
          for iCount := 1 to R4.Items.Count do
              if (R4Key.Items.Strings[iCount-1] = IntToStr(iThisGeocode)) then
              begin
                   if R4.Selected[iCount-1] then
                      R4.Selected[iCount-1] := False
                   else
                       R4.Selected[iCount-1]:= True;
                   fSiteFound := True;
                   Result := _R4;
              end;
          if not fSiteFound
          and (R5.Items.Count > 0) then
          for iCount := 1 to R5.Items.Count do
              if (R5Key.Items.Strings[iCount-1] = IntToStr(iThisGeocode)) then
              begin
                   if R5.Selected[iCount-1] then
                      R5.Selected[iCount-1] := False
                   else
                       R5.Selected[iCount-1]:= True;
                   fSiteFound := True;
                   Result := _R5;
              end;
          if not fSiteFound
          and (Excluded.Items.Count > 0) then
          for iCount := 1 to Excluded.Items.Count do
              if (ExcludedKey.Items.Strings[iCount-1] = IntToStr(iThisGeocode)) then
              begin
                   if Excluded.Selected[iCount-1] then
                      Excluded.Selected[iCount-1] := False
                   else
                       Excluded.Selected[iCount-1]:= True;
                   fSiteFound := True;
                   Result := Ex;
              end;
          if not fSiteFound
          and (Partial.Items.Count > 0) then
          for iCount := 1 to Partial.Items.Count do
              if (PartialKey.Items.Strings[iCount-1] = IntToStr(iThisGeocode)) then
              begin
                   if Partial.Selected[iCount-1] then
                      Partial.Selected[iCount-1] := False
                   else
                       Partial.Selected[iCount-1]:= True;
                   fSiteFound := True;
                   Result := Pd;
              end;
          if not fSiteFound
          and (Flagged.Items.Count > 0) then
          for iCount := 1 to Flagged.Items.Count do
              if (FlaggedKey.Items.Strings[iCount-1] = IntToStr(iThisGeocode)) then
              begin
                   if Flagged.Selected[iCount-1] then
                      Flagged.Selected[iCount-1] := False
                   else
                       Flagged.Selected[iCount-1]:= True;
                   fSiteFound := True;
                   Result := Fl;
              end;
          if not fSiteFound
          and (Reserved.Items.Count > 0) then
          for iCount := 1 to Reserved.Items.Count do
              if (ReservedKey.Items.Strings[iCount-1] = IntToStr(iThisGeocode)) then
              begin
                   if Reserved.Selected[iCount-1] then
                      Reserved.Selected[iCount-1] := False
                   else
                       Reserved.Selected[iCount-1]:= True;
                   fSiteFound := True;
                   Result := Re;
              end;
          if not fSiteFound
          and (Ignored.Items.Count > 0) then
          for iCount := 1 to Ignored.Items.Count do
              if (IgnoredKey.Items.Strings[iCount-1] = IntToStr(iThisGeocode)) then
              begin
                   if Ignored.Selected[iCount-1] then
                      Ignored.Selected[iCount-1] := False
                   else
                       Ignored.Selected[iCount-1]:= True;
                   fSiteFound := True;
                   Result := Ig;
              end;
     end;
end;

procedure UseGISKeys(SitesSelected : Array_T);
var
   i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : integer;
begin
     {perform appropriate function on these sites}
     Arr2Highlight(SitesSelected,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);

     {if (SitesSelected.lMaxSize > 0)
     and (ControlForm.ToggleGroup.ItemIndex = 0) then}

     ControlForm.btnAcceptClick(ControlForm);
end;

procedure UseGISKey(const iThisGeocode : integer;
                        const fMinimizeControl : boolean);
var
   fSiteFound : boolean;
   iCount : integer;
   SourceStatus, DestStatus : Status_T;
   var iUr,iR1, iR2, iR3, iR4, iR5,iEx,iRe,iIg,iPd,iFl : integer;
   HighlightArr, LArr : Array_t;
begin
     {use the Geocode passed from the DDE hot link, with
      the action depending on the state of
      ControlForm.ClickGroup.ItemIndex (hot key alt-c) and
      ControlForm.ToggleGroup.ItemIndex (hot key alt-t) and
      ControlForm.btnAcceptClick (hot key alt-a) to accept multiple sites}

     iWinermsKeyClick := iThisGeocode;
     fSiteFound := False;

     with ControlForm do
     begin
          ControlRes^.sLastChoiceType := 'GIS Click';

          {we are doing a multiple DDE Selection, we may need to choose
           from Selected, Mandatory, Excluded,
           Reserved, Ignored, Partial, Flagged as well
           and Available}

          HighlightArr := Array_t.Create;
          HighlightArr.init(SizeOf(integer),1);
          HighlightArr.setValue(1,@iThisGeocode);
          Arr2Highlight(HighlightArr,
                        iUr,iR1, iR2, iR3, iR4, iR5,iEx,iRe,iIg,iPd,iFl);
          if ((iUr+iR1+iR2+iR3+iR4+iR5+iEx+iRe+iIg+iPd+iFl) > 0) then
             fSiteFound := True;
          HighlightArr.Destroy;
     end;

     {bring the ControlForm to focus so users can use the DDE hot keys
      without needing to switch back to the Conservation Tool}
     if fMinimizeControl
     and fMinimiseOnDone then
         if (not ControlRes^.fToolView) then
             begin
                  ControlForm.WindowState := wsMinimized;
                  ControlForm.BringToFront;
             end
             else
                 ToolForm.BringToFront;
end;

function TrimGeocode(const sLine : string) : integer;
var
   sTmp, sTmp2 : string;
   iCount : integer;
begin
     iCount := 1;

     while (iCount < Length(sLine))
     and (sLine[iCount] <> Chr(9)) do
         Inc(iCount); {advance past easting}

     Inc(iCount); {advance past tab}

     while (iCount < Length(sLine))
     and (sLine[iCount] <> Chr(9)) do
         Inc(iCount); {advance past northing}

     Inc(iCount); {advance past tab}

     sTmp := '';

     while (iCount < Length(sLine))
     and (sLine[iCount] <> Chr(9)) do
     begin
          sTmp := sTmp + sLine[iCount];
          Inc(iCount);
     end;
     Inc(iCount);

     sTmp2 := '';

     while (iCount < Length(sLine))
     and (sLine[iCount] <> Chr(9)) do
     begin
          sTmp2 := sTmp2 + sLine[iCount];
          Inc(iCount);
     end;
     {Check WinERMS layer clicked on
      matches iEMRLayer or iStatusLayer}
     if (ControlRes^.iEMRLayer = StrToInt(sTmp2))
     or (ControlRes^.iStatusLayer = StrToInt(sTmp2)) then
        Result := StrToInt(sTmp)
     else
     begin
          MessageDlg('WinERMS Map Layer clicked on (' + sTmp2 +
                     ') does not match original Base (' + IntToStr(ControlRes^.iEMRLayer) +
                     ') or Top (' + IntToStr(ControlRes^.iStatusLayer) + ') layers',
                     mtWarning,[mbOK],0);
          Result := -1; {WinERMS layer clicked on doesn't match iEMRLayer or iStatusLayer}
     end;
end;


procedure DdeSelectionDataChange;
var
   iThisCode : integer;
begin
     if (ControlForm.SystemItem.Text = 'start select') then
     begin
          {start of multiple dde select}
          ControlRes^.fMultiDDESelect := True;
          MultiSites := Array_T.Create;
          MultiSites.init(SizeOf(integer),ARR_STEP_SIZE);
          iMultiSiteCount := 0;
     end
     else
         if (ControlForm.SystemItem.Text = 'end select') then
         begin
              {end of multiple select}
              ControlRes^.fMultiDDESelect := False;

              {now use the sites which have been selected}
              if (iMultiSiteCount > 0) then
                 UseGISKeys(MultiSites);

              MultiSites.Destroy;
         end
         else
         begin
              if ControlRes^.fMultiDDESelect then
              begin
                   {this is a single site from an ArcView dde selection}
                   iThisCode := StrToInt(ControlForm.SystemItem.Text);
                   Inc(iMultiSiteCount);
                   if (iMultiSiteCount > MultiSites.lMaxSize) then
                      MultiSites.resize(MultiSites.lMaxSize + ARR_STEP_SIZE);
                   MultiSites.setValue(iMultiSiteCount,@iThisCode);
              end
              else
              begin
                   {this is a single dde selection from WinERMS}

                   iThisCode := TrimGeocode(ControlForm.SystemItem.Text);
                   {TrimGeocode tests whether the layer
                    clicked on matches our irreplacability later}
                   if (iThisCode >= 0) then
                      UseGISKey(iThisCode,FALSE);
                      {the geocode is -1 if the (i)WinERMSLayer clicked on
                       doesn't match our iEMRLayer or iStatusLayer}
              end;
         end;
end;

end.
