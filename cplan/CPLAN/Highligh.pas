unit Highligh;

{$I \SOFTWARE\cplan\cplan\STD_DEF.PAS}

interface

uses
  Control, Em_newu1, Global, StdCtrls,
  {$IFDEF bit16}
  Arrayt16;
  {$ELSE}
  ds;
  {$ENDIF}


procedure LoadHighlight(const sFile : string;
                        const wType : word;
                        const fUser : boolean);
{Loads GEOCODES/NAMES (depending on the value of wType)
 from a text file, one line for each site.
 Highlights these sites in whatever box they appear in,
 and Shows a summary form of class/mismatch count}
procedure SaveHighlight(const sFile : string;
                        const wType : word;
                        const fPromptToOverwrite : boolean);
{Saves highlighted site GEOCODES/NAMES (depending on the value of wType)
 to a text file, one line for each site.}

procedure Arr2Highlight(Arr : Array_t;
                        var iUr,iR1,iR2,iR3,iR4,iR5,iEx,iRe,iIg,iPd,iFl : integer);
procedure NameArr2Highlight(Arr : Array_t;
                            var iUr,iR1,iR2,iR3,iR4,iR5,iEx,iRe,iIg,iPd,iFl : integer);

function Highlight2Arr(var Arr : Array_t) : boolean;
{creates an Array_t of MyShortString which is list of all
 highlighted sites, Result is false and Arr is
 freed up if no items highlighted}
function HighlightBox2Arr(ABox,AGeoBox : TListBox;
                          var Arr : Array_t) : boolean;
function Box2Arr(ABox,AGeoBox : TListBox;
                 var Arr : Array_t) : boolean;

function Arr2SiteStatus(Arr, SearchArr : Array_t;
                        SiteName, SiteKey : TListbox) : integer;

implementation

uses
    SysUtils, Dialogs, Forms, Controls,
    Dbmisc, Opt1, Dll_u1,
    mthread;


function IsWhiteSpace(const sLine : string) : boolean;
var
   iCount : integer;
begin
     Result := True;

     if (Length(sLine) > 0) then
        for iCount := 1 to Length(sLine) do
            if (sLine[iCount] <> ' ') then
               Result := False;
end;

procedure LoadHighlight(const sFile : string;
                        const wType : word;
                        const fUser : boolean);
var
   sToSearch, sMsg : string;
   fSiteFound : boolean;
   iCount, iUr,iR1,iR2,iR3,iR4,iR5,iEx,iRe,iIg,iPd,iFl,iMiss,
   iCursor, iSite : integer;

   InFile : Text;
   sLine : string;
   IdArray : Array_t;
   iId, iIdArrayCount : integer;
   sId : str255;

begin
     try
        iUr := 0;
        iR1 := 0;
        iR2 := 0;
        iR3 := 0;
        iR4 := 0;
        iR5 := 0;
        iEx := 0;
        iRe := 0;
        iIg := 0;
        iPd := 0;
        iFl := 0;
        iMiss := 0;

        assignfile(InFile,sFile);
        reset(InFile);

        IdArray := Array_t.Create;
        case wType of
             LOAD_NAME : IdArray.init(SizeOf(sId),ARR_STEP_SIZE);
             LOAD_GEOCODE : IdArray.init(SizeOf(iId),ARR_STEP_SIZE);
        end;
        iIdArrayCount := 0;

        repeat
              readln(InFile,sLine);

              if not IsWhiteSpace(sLine) then
              begin
                   Inc(iIdArrayCount);
                   if (iIdArrayCount > IdArray.lMaxSize) then
                      IdArray.resize(IdArray.lMaxSize + ARR_STEP_SIZE);

                   case wType of
                        LOAD_NAME :
                        begin
                             sId := sLine;
                             IdArray.setValue(iIdArrayCount,@sId);
                        end;
                        LOAD_GEOCODE :
                        begin
                             iId := StrToInt(sLine);
                             IdArray.setValue(iIdArrayCount,@iId);
                        end;
                   end;
              end;


        until Eof(InFile);

        closefile(InFile);

        {highlight any sites in IdArray}
        if (iIdArrayCount > 0) then
        begin
             if (iIdArrayCount <> IdArray.lMaxSize) then
                IdArray.resize(iIdArrayCount);

             case wType of
                  LOAD_NAME : NameArr2Highlight(IdArray,iUr,iR1,iR2,iR3,iR4,iR5,iEx,iRe,iIg,iPd,iFl);
                  LOAD_GEOCODE : Arr2Highlight(IdArray,iUr,iR1,iR2,iR3,iR4,iR5,iEx,iRe,iIg,iPd,iFl);
             end;

             {report count in each class}
             if fUser then
                MessageDlg('File ' + sFile + ' site count in each class' + Chr(10) + Chr(13) + Chr(10) + Chr(13) +
                           '  Un-reserved ' + IntToStr(iUr) + Chr(10) + Chr(13) +
                           '  '+ControlRes^.sR1Label+' ' + IntToStr(iR1) + Chr(10) + Chr(13) +
                           '  '+ControlRes^.sR2Label+' ' + IntToStr(iR2) + Chr(10) + Chr(13) +
                           '  '+ControlRes^.sR3Label+' ' + IntToStr(iR3) + Chr(10) + Chr(13) +
                           '  '+ControlRes^.sR4Label+' ' + IntToStr(iR4) + Chr(10) + Chr(13) +
                           '  '+ControlRes^.sR5Label+' ' + IntToStr(iR5) + Chr(10) + Chr(13) +
                           '  Partially Selected ' + IntToStr(iPd) + Chr(10) + Chr(13) +
                           '  Initial Reserve ' + IntToStr(iRe) + Chr(10) + Chr(13) +
                           '  Initial Excluded ' + IntToStr(iIg) + Chr(10) + Chr(13) +
                           '  Excluded ' + IntToStr(iEx) + Chr(10) + Chr(13) +
                           '  Flagged ' + IntToStr(iFl) + Chr(10) + Chr(13) + Chr(10) + Chr(13) +
                           '  No Match ' + IntToStr(iIdArrayCount - iUr - iR1 - iR2 - iR3 - iR4 - iR5 - iPd - iRe - iIg - iEx - iFl),
                           mtInformation,[mbOk],0);
        end
        else
        begin
             {report no sites found}
             MessageDlg('No sites found in file ' + sFile,
                        mtInformation,[mbOk],0);
        end;

        IdArray.Destroy;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadHighlight',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure SaveHighlight(const sFile : string;
                        const wType : word;
                        const fPromptToOverwrite : boolean);
var
   SArr : Array_t;
   fStop : boolean;
   iCount, iSiteGeocode, iSiteIndex : integer;
   pSite : sitepointer;
begin
     if Highlight2Arr(SArr) then
     begin
          {create the output file}
          fStop := False;
          if FileExists(sFile)
          and fPromptToOverwrite then
          begin
               if (mrYes <> MessageDlg('Overwrite file ' + sFile,mtConfirmation,[mbYes,mbNo],0)) then
                  fStop := True;
          end;

          if not fStop then
          with ControlForm.ReportBox do
          begin
               {write the list of sites into a file}
               if (wType = LOAD_NAME) then
                  new(pSite);

               Items.Clear;
               for iCount := 1 to SArr.lMaxSize do
               begin
                    SArr.rtnValue(iCount,@iSiteGeocode);
                    case wType of
                         LOAD_GEOCODE : Items.Add(IntToStr(iSiteGeocode));
                         LOAD_NAME :
                         begin
                              {need to locate the site name}
                              iSiteIndex := findIntegerMatch(OrdSiteArr,iSiteGeocode);
                              SiteArr.rtnValue(iSiteIndex,pSite);

                              Items.Add(pSite^.sName);
                         end;
                    end;
               end;
               Items.SaveToFile(sFile);
               Items.Clear;
               SArr.Destroy;

               if (wType = LOAD_NAME) then
                  dispose(pSite);
          end;
     end;


end;

function Arr2SiteStatus(Arr, SearchArr : Array_t;
                        SiteName, SiteKey : TListbox) : integer;
var
   iIndex, iCount, iCount2, iListBoxValue, iToSearch : integer;
   sToSearch : MyShortString;
begin
     try
        Result := 0;
        if (Arr.lMaxSize > 0) then
        begin
             {deselect any highlighted elements in SiteName listbox}
             UnHighlight(SiteName,fKeepHighlight);

             if (SiteName.Items.Count > 0) then
                for iCount := 1 to SiteName.Items.Count do
                begin
                     iListBoxValue := StrToInt(SiteKey.Items.Strings[iCount-1]);

                     iIndex := findFeatMatch(SearchArr,iListBoxValue);

                     if (iIndex > 0) then
                        if (iIndex <= Arr.lMaxSize) then
                        begin
                             Arr.rtnValue(iIndex,@iToSearch);

                             if (iListBoxValue = iToSearch) then
                             begin
                                  SiteName.Selected[iCount-1]:= True; {highlight this element in the SiteName box}
                                  Inc(Result);
                             end;
                        end;
                end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Arr2Available',mtError,[mbOk],0);
     end;
end;

function NameArr2SiteStatus(Arr, SearchArr : Array_t;
                            SiteName, SiteKey : TListbox) : integer;
var
   iIndex, iCount : integer;
   sToSearch : str255;
   sListBoxValue : string;
begin
     try
        Result := 0;
        if (Arr.lMaxSize > 0) then
        begin
             UnHighlight(SiteName,fKeepHighlight);

             if (SiteName.Items.Count > 0) then
                for iCount := 1 to SiteName.Items.Count do
                begin
                     sListBoxValue := SiteName.Items.Strings[iCount-1];

                     iIndex := findStrMatch(SearchArr,sListBoxValue);

                     if (iIndex > 0) then
                     begin
                          Arr.rtnValue(iIndex,@sToSearch);

                          if (sListBoxValue = sToSearch) then
                          begin
                               SiteName.Selected[iCount-1]:= True; {highlight this element in the SiteName box}
                               Inc(Result);
                          end;
                     end;
                end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in NameArr2Available',mtError,[mbOk],0);
     end;
end;

procedure Arr2Highlight(Arr : Array_t;
                        var iUr,iR1,iR2,iR3,iR4,iR5,iEx,iRe,iIg,iPd,iFl : integer);
var
   fR2Visible, fR3Visible, fR4Visible, fR5Visible, fExcVisible, fFlgVisible, fParVisible : boolean;
   SearchArr : Array_t;
begin
     try
        with ControlForm do
            if (Arr.lMaxSize > 0) then
            begin
                 if ControlRes^.fReportMinsetMemSize then
                    AddMemoryReportRow('Arr2Highlight begin');

                 {store visible state of listboxes we can switch off}
                 fR2Visible := R2.Visible;
                 fR3Visible := R3.Visible;
                 fR4Visible := R4.Visible;
                 fR5Visible := R5.Visible;
                 fExcVisible := Excluded.Visible;
                 fFlgVisible := Flagged.Visible;
                 fParVisible := Partial.Visible;

                 {make listboxes invisible}
                 Available.Visible := False;
                 R1.Visible := False;
                 R2.Visible := False;
                 R3.Visible := False;
                 R4.Visible := False;
                 R5.Visible := False;
                 Excluded.Visible := False;
                 Partial.Visible := False;
                 Flagged.Visible := False;

                 if ControlRes^.fReportMinsetMemSize then
                    AddMemoryReportRow('Arr2Highlight before SortFeatArray');

                 SearchArr := SortFeatArray(Arr);

                 if ControlRes^.fReportMinsetMemSize then
                    AddMemoryReportRow('Arr2Highlight after SortFeatArray and before Arr2SiteStatus');

                 {use Arr2SiteStatus on each of the site status groups to highlight elements from Arr}
                 iUr := Arr2SiteStatus(Arr,SearchArr,Available,AvailableKey);
                 iR1 := Arr2SiteStatus(Arr,SearchArr,R1,R1Key);
                 iR2 := Arr2SiteStatus(Arr,SearchArr,R2,R2Key);
                 iR3 := Arr2SiteStatus(Arr,SearchArr,R3,R3Key);
                 iR4 := Arr2SiteStatus(Arr,SearchArr,R4,R4Key);
                 iR5 := Arr2SiteStatus(Arr,SearchArr,R5,R5Key);
                 iEx := Arr2SiteStatus(Arr,SearchArr,Excluded,ExcludedKey);
                 iPd := Arr2SiteStatus(Arr,SearchArr,Partial,PartialKey);
                 iFl := Arr2SiteStatus(Arr,SearchArr,Flagged,FlaggedKey);
                 iRe := Arr2SiteStatus(Arr,SearchArr,Reserved,ReservedKey);
                 iIg := Arr2SiteStatus(Arr,SearchArr,Ignored,IgnoredKey);

                 if ControlRes^.fReportMinsetMemSize then
                    AddMemoryReportRow('Arr2Highlight after Arr2SiteStatus');

                 SearchArr.Destroy;

                 if ControlRes^.fReportMinsetMemSize then
                    AddMemoryReportRow('Arr2Highlight after .Destroy');

                 {restore visible state of listboxes}
                 Available.Visible := True;
                 R1.Visible := True;
                 R2.Visible := fR2Visible;
                 R3.Visible := fR3Visible;
                 R4.Visible := fR4Visible;
                 R5.Visible := fR5Visible;
                 Excluded.Visible := fExcVisible;
                 Partial.Visible := fParVisible;
                 Flagged.Visible := fFlgVisible;

                 if ControlRes^.fReportMinsetMemSize then
                    AddMemoryReportRow('Arr2Highlight end');
            end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Arr2Highlight',mtError,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
end;

procedure NameArr2Highlight(Arr : Array_t;
                            var iUr,iR1,iR2,iR3,iR4,iR5,iEx,iRe,iIg,iPd,iFl : integer);
var
   fR2Visible, fR3Visible, fR4Visible, fR5Visible, fExcVisible, fFlgVisible, fParVisible : boolean;
   SearchArr : Array_t;
begin
     try
        with ControlForm do
            if (Arr.lMaxSize > 0) then
            begin
                 {store visible state of listboxes we can switch off}
                 fR2Visible := R2.Visible;
                 fR3Visible := R3.Visible;
                 fR4Visible := R4.Visible;
                 fR5Visible := R5.Visible;
                 fExcVisible := Excluded.Visible;
                 fFlgVisible := Flagged.Visible;
                 fParVisible := Partial.Visible;

                 {make listboxes invisible}
                 Available.Visible := False;
                 R1.Visible := False;
                 R2.Visible := False;
                 R3.Visible := False;
                 R4.Visible := False;
                 R5.Visible := False;
                 Excluded.Visible := False;
                 Partial.Visible := False;
                 Flagged.Visible := False;

                 SearchArr := SortStrArray(Arr);

                 {use Arr2SiteStatus on each of the site status groups to highlight elements from Arr}
                 iUr := NameArr2SiteStatus(Arr,SearchArr,Available,AvailableKey);
                 iR1 := NameArr2SiteStatus(Arr,SearchArr,R1,R1Key);
                 iR2 := NameArr2SiteStatus(Arr,SearchArr,R2,R2Key);
                 iR3 := NameArr2SiteStatus(Arr,SearchArr,R3,R3Key);
                 iR4 := NameArr2SiteStatus(Arr,SearchArr,R4,R4Key);
                 iR5 := NameArr2SiteStatus(Arr,SearchArr,R5,R5Key);
                 iEx := NameArr2SiteStatus(Arr,SearchArr,Excluded,ExcludedKey);
                 iPd := NameArr2SiteStatus(Arr,SearchArr,Partial,PartialKey);
                 iFl := NameArr2SiteStatus(Arr,SearchArr,Flagged,FlaggedKey);
                 iRe := NameArr2SiteStatus(Arr,SearchArr,Reserved,ReservedKey);
                 iIg := NameArr2SiteStatus(Arr,SearchArr,Ignored,IgnoredKey);

                 SearchArr.Destroy;

                 {restore visible state of listboxes}
                 Available.Visible := True;
                 R1.Visible := True;
                 R2.Visible := fR2Visible;
                 R3.Visible := fR3Visible;
                 R4.Visible := fR4Visible;
                 R5.Visible := fR5Visible;
                 Excluded.Visible := fExcVisible;
                 Partial.Visible := fParVisible;
                 Flagged.Visible := fFlgVisible;
            end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in NameArr2Highlight',mtError,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
end;

function HighlightBox2Arr(ABox,AGeoBox : TListBox;
                          var Arr : Array_t) : boolean;
var
   iNumItems, iCount : integer;

   procedure AddToArr(const sLongGeocode : string);
   var
      iGeocode : integer;
   begin
        iGeocode := StrToInt(sLongGeocode);

        Inc(iNumItems);
        if (iNumItems > Arr.lMaxSize) then
           Arr.resize(Arr.lMaxSize + ARR_STEP_SIZE);
        Arr.setValue(iNumItems,@iGeocode);
   end;

begin
     Arr := Array_t.Create;
     Arr.init(SizeOf(integer),ARR_STEP_SIZE);
     iNumItems := 0;

     if (ABox.SelCount > 0) then
        for iCount := 0 to (ABox.Items.Count-1) do
            if ABox.Selected[iCount] then
               AddToArr(AGeoBox.Items.Strings[iCount]);

     if (iNumItems = 0) then
     begin
          Result := False;
          Arr.Destroy;
     end
     else
     begin
          Result := True;

          if (iNumItems <> Arr.lMaxSize) then
             Arr.resize(iNumItems);
     end;
end;

function Box2Arr(ABox,AGeoBox : TListBox;
                 var Arr : Array_t) : boolean;
var
   iNumItems, iCount : integer;

   procedure AddToArr(const sLongGeocode : string);
   var
      iGeocode : integer;
   begin
        iGeocode := StrToInt(sLongGeocode);

        Inc(iNumItems);
        if (iNumItems > Arr.lMaxSize) then
           Arr.resize(Arr.lMaxSize + ARR_STEP_SIZE);
        Arr.setValue(iNumItems,@iGeocode);
   end;

begin
     Arr := Array_t.Create;
     Arr.init(SizeOf(integer),ARR_STEP_SIZE);
     iNumItems := 0;

     //if (ABox.SelCount > 0) then
        for iCount := 0 to (ABox.Items.Count-1) do
            //if ABox.Selected[iCount] then
               AddToArr(AGeoBox.Items.Strings[iCount]);

     if (iNumItems = 0) then
     begin
          Result := False;
          Arr.Destroy;
     end
     else
     begin
          Result := True;

          if (iNumItems <> Arr.lMaxSize) then
             Arr.resize(iNumItems);
     end;
end;

function Highlight2Arr(var Arr : Array_t) : boolean;
var
   iNumItems, iCount : integer;

   procedure AddToArr(const sLongGeocode : string);
   var
      iGeocode : integer;
   begin
        iGeocode := StrToInt(sLongGeocode);

        Inc(iNumItems);
        if (iNumItems > Arr.lMaxSize) then
           Arr.resize(Arr.lMaxSize + ARR_STEP_SIZE);
        Arr.setValue(iNumItems,@iGeocode);
   end;

begin
     Arr := Array_t.Create;
     Arr.init(SizeOf(integer),ARR_STEP_SIZE);
     iNumItems := 0;

     with ControlForm do
     begin
          if (Available.SelCount > 0) then
             for iCount := 0 to (Available.Items.Count-1) do
                 if Available.Selected[iCount] then
                    AddToArr(AvailableKey.Items.Strings[iCount]);
          if (R1.SelCount > 0) then
             for iCount := 0 to (R1.Items.Count-1) do
                 if R1.Selected[iCount] then
                    AddToArr(R1Key.Items.Strings[iCount]);
          if (R2.SelCount > 0) then
             for iCount := 0 to (R2.Items.Count-1) do
                 if R2.Selected[iCount] then
                    AddToArr(R2Key.Items.Strings[iCount]);
          if (R3.SelCount > 0) then
             for iCount := 0 to (R3.Items.Count-1) do
                 if R3.Selected[iCount] then
                    AddToArr(R3Key.Items.Strings[iCount]);
          if (R4.SelCount > 0) then
             for iCount := 0 to (R4.Items.Count-1) do
                 if R4.Selected[iCount] then
                    AddToArr(R2Key.Items.Strings[iCount]);
          if (R5.SelCount > 0) then
             for iCount := 0 to (R5.Items.Count-1) do
                 if R5.Selected[iCount] then
                    AddToArr(R2Key.Items.Strings[iCount]);
          if (Partial.SelCount > 0) then
             for iCount := 0 to (Partial.Items.Count-1) do
                 if Partial.Selected[iCount] then
                    AddToArr(PartialKey.Items.Strings[iCount]);
          if (Flagged.SelCount > 0) then
             for iCount := 0 to (Flagged.Items.Count-1) do
                 if Flagged.Selected[iCount] then
                    AddToArr(FlaggedKey.Items.Strings[iCount]);
          if (Excluded.SelCount > 0) then
             for iCount := 0 to (Excluded.Items.Count-1) do
                 if Excluded.Selected[iCount] then
                    AddToArr(ExcludedKey.Items.Strings[iCount]);
          if (Reserved.SelCount > 0) then
             for iCount := 0 to (Reserved.Items.Count-1) do
                 if Reserved.Selected[iCount] then
                    AddToArr(ReservedKey.Items.Strings[iCount]);
          if (Ignored.SelCount > 0) then
             for iCount := 0 to (Ignored.Items.Count-1) do
                 if Ignored.Selected[iCount] then
                    AddToArr(IgnoredKey.Items.Strings[iCount]);
     end;

     if (iNumItems = 0) then
     begin
          Result := False;
          Arr.Destroy;
     end
     else
     begin
          Result := True;

          if (iNumItems <> Arr.lMaxSize) then
             Arr.resize(iNumItems);
     end;
end;

end.
