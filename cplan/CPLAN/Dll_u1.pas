unit Dll_u1;

interface

uses
    StdCtrls, Global, Forms, DBTables,
    ds;

    
procedure Debug2FileA(const sLine : string); export;

procedure ParseInsertSpace(const fOldIni:boolean;
                           const sDatabase:string;
                           App : TApplication); export;
procedure ParseRemoveSpaces(const fOldIni:boolean;
                            const sDatabase:string;
                            App : TApplication);

function ACopyFile(const sSourceFile, sDestFile : string) : boolean; export;

function Status2Str (const AStatus : Status_T) : string; export;
function Status2StrLong (const AStatus : Status_T) : string;

{new code added June 6th '97 from SF_IRREP}
function OrdStr(const iEmrCat : integer) : string; export;
procedure _MapWAVIRR2EMR(const ASiteArr : Array_T;
                         const iS_Count : integer;
                            var iIr1Count, i001Count, i002Count,
                                i003Count, i004Count, i005Count,
                                i0CoCount : integer); export;
procedure _MapSUMIRR2EMR(const ASiteArr : Array_T;
                         const iS_Count : integer;
                            var iIr1Count, i001Count, i002Count,
                                i003Count, i004Count, i005Count,
                                i0CoCount : integer); export;
procedure _MapField2Display(const ASSTable : TTable;
                            const ASiteArr : Array_t;
                            const sFieldToScan : string;
                            const fBoundedTo1 : boolean;
                            const iS_Count : integer;
                            var iIr1Count, i001Count, i002Count,
                                i003Count, i004Count, i005Count,
                                i0CoCount : integer); export;
//procedure _ClearOldSQL(const ASiteArr : Array_t;
//                       const iS_Count : integer); export;
procedure _HighlightSite(iGeo : integer;
                         Const Available, R1, R2, R3, R4, R5, Partial, Excluded, Flagged,
                         AvailableGeocode, R1Key, R2Key, R3Key, R4Key, R5Key,
                         PartialGeocode, ExcludedGeocode, FlaggedGeocode : TListbox); export;
function _CountSQL(Const Available, R1, R2, R3, R4, R5,
                         Partial, Excluded, Flagged,
                         AvailableGeocode, R1Key, R2Key, R3Key, R4Key, R5Key,
                         PartialGeocode, ExcludedGeocode, FlaggedGeocode : TListBox;
                   Const ASiteArr : Array_t;
                   Const iS_Count : integer;
                   const fKeepHighlight : boolean) : integer; export;
{CONTROL.PAS}
function CustDateStr : string; export;
function Cust2DateStr : string; export;
procedure UnHighlight(const ThisBox : TListBox;
                      const fKeepHighlight : boolean); export;
procedure Highlight(const ThisBox : TListBox); export;

implementation

uses
    Dll_u2, SysUtils, Dialogs, Controls, Control,
    FMXUtils;

procedure Highlight(const ThisBox : TListBox);
var
   iCount : integer;
   wTmp : integer;
   fAlreadyVisible : boolean;
begin
     wTmp := Screen.Cursor;

     try
        Screen.Cursor := crHourglass;

        fAlreadyVisible := ThisBox.Visible;

        if fAlreadyVisible then
           ThisBox.Visible := False;

        for iCount := 0 to (ThisBox.Items.Count-1) do
            ThisBox.Selected[iCount] := True;

        if fAlreadyVisible then
           ThisBox.Visible := True;

     finally
            Screen.Cursor := wTmp;
     end;
end;

procedure UnHighlight(const ThisBox : TListBox;
                      const fKeepHighlight : boolean);
var
   iCount : integer;
   wTmp : integer;
   fAlreadyVisible : boolean;
begin
     wTmp := Screen.Cursor;

     try
        Screen.Cursor := crHourglass;

        if not fKeepHighlight
        and (ThisBox.SelCount > 0) then
        begin
             fAlreadyVisible := ThisBox.Visible;

             if fAlreadyVisible then
                ThisBox.Visible := False;

             for iCount := 0 to (ThisBox.Items.Count-1) do
                 ThisBox.Selected[iCount] := False;

             if fAlreadyVisible then
                ThisBox.Visible := True;
        end;

     finally
            Screen.Cursor := wTmp;
     end;
end;

function Cust2DateStr : string;
begin
     Result := FormatDateTime('dddd" "mmmm d yyyy ' +
                              '"  " hh:mm AM/PM', Now);
end;

function CustDateStr : string;
begin
     Result := FormatDateTime('"Date is "dddd," "mmmm d, yyyy ' +
                              '"at" hh:mm AM/PM', Now);
end;

function _CountSQL(Const Available, R1, R2, R3, R4, R5,
                         Partial, Excluded, Flagged,
                         AvailableGeocode, R1Key, R2Key, R3Key, R4Key, R5Key,
                         PartialGeocode, ExcludedGeocode, FlaggedGeocode : TListBox;
                   Const ASiteArr : Array_t;
                   Const iS_Count : integer;
                   const fKeepHighlight : boolean) : integer;
var
   iCount : integer;
   TmpSite : site;

begin
     Result := 0;

     UnHighlight(Available,fKeepHighlight);
     UnHighlight(R1,fKeepHighlight);
     UnHighlight(R2,fKeepHighlight);
     UnHighlight(R3,fKeepHighlight);
     UnHighlight(R4,fKeepHighlight);
     UnHighlight(R5,fKeepHighlight);
     UnHighlight(Excluded,fKeepHighlight);
     UnHighlight(Partial,fKeepHighlight);
     UnHighlight(Flagged,fKeepHighlight);

     for iCount := 1 to iS_Count do
     begin
          ASiteArr.rtnValue(iCount,@TmpSite);

          if (TmpSite.sDisplay = 'SQL') then
          begin
               {highlight this site in the box it occurs in}
               _HighlightSite(TmpSite.iKey,
                              Available, R1, R2, R3, R4, R5,
                              Partial, Excluded, Flagged,
                              AvailableGeocode, R1Key, R2Key, R3Key, R4Key, R5Key,
                              PartialGeocode, ExcludedGeocode, FlaggedGeocode);

               Inc(Result);
          end;
     end;
end;

procedure _HighlightSite(iGeo : integer;
                         Const Available, R1, R2, R3, R4, R5, Partial, Excluded, Flagged,
                         AvailableGeocode, R1Key, R2Key, R3Key, R4Key, R5Key,
                         PartialGeocode, ExcludedGeocode, FlaggedGeocode : TListbox);
var
   fFound : boolean;
   iCount : integer;
   sGeo : string;
begin
     sGeo := IntToStr(iGeo);
     fFound := False;

     if (R1.Items.Count > 0) then
     for iCount := 0 to (R1Key.Items.Count-1) do
         if (R1Key.Items.Strings[iCount] = sGeo) then
         begin
              R1.Selected[iCount] := True;
              fFound := True;
         end;
     if not fFound
     and (R2.Items.Count > 0) then
     for iCount := 0 to (R2Key.Items.Count-1) do
         if (R2Key.Items.Strings[iCount] = sGeo) then
         begin
              R2.Selected[iCount] := True;
              fFound := True;
         end;
     if not fFound
     and (R3.Items.Count > 0) then
     for iCount := 0 to (R3Key.Items.Count-1) do
         if (R3Key.Items.Strings[iCount] = sGeo) then
         begin
              R3.Selected[iCount] := True;
              fFound := True;
         end;
     if not fFound
     and (R4.Items.Count > 0) then
     for iCount := 0 to (R4Key.Items.Count-1) do
         if (R4Key.Items.Strings[iCount] = sGeo) then
         begin
              R4.Selected[iCount] := True;
              fFound := True;
         end;
     if not fFound
     and (R5.Items.Count > 0) then
     for iCount := 0 to (R5Key.Items.Count-1) do
         if (R5Key.Items.Strings[iCount] = sGeo) then
         begin
              R5.Selected[iCount] := True;
              fFound := True;
         end;
     if not fFound
     and (Excluded.Items.Count > 0) then
     for iCount := 0 to (ExcludedGeocode.Items.Count-1) do
         if (ExcludedGeocode.Items.Strings[iCount] = sGeo) then
         begin
              Excluded.Selected[iCount] := True;
              fFound := True;
         end;

     if not fFound
     and (Available.Items.Count > 0) then
     for iCount := 0 to (AvailableGeocode.Items.Count-1) do
         if (AvailableGeocode.Items.Strings[iCount] = sGeo) then
         begin
              Available.Selected[iCount] := True;
              fFound := True;
         end;

     if not fFound
     and (Partial.Items.Count > 0) then
     for iCount := 0 to (PartialGeocode.Items.Count-1) do
         if (PartialGeocode.Items.Strings[iCount] = sGeo) then
         begin
              Partial.Selected[iCount] := True;
              fFound := True;
         end;

     if not fFound
     and (Flagged.Items.Count > 0) then
     for iCount := 0 to (FlaggedGeocode.Items.Count-1) do
         if (FlaggedGeocode.Items.Strings[iCount] = sGeo) then
         begin
              Flagged.Selected[iCount] := True;
              fFound := True;
         end;
end;

procedure _MapField2Display(const ASSTable : TTable;
                            const ASiteArr : Array_t;
                            const sFieldToScan : string;
                            const fBoundedTo1 : boolean;
                            const iS_Count : integer;
                            var iIr1Count, i001Count, i002Count,
                                i003Count, i004Count, i005Count,
                                i0CoCount : integer);
var
   iCount, iCount2 : integer;
   sSingle, sToTest,
   sHigh,sStep,sCutOff : extended;
   fEnd : boolean;
   sDisplay : string;
   TmpSite : site;
begin
     iIr1Count := 0;
     i001Count := 0;
     i002Count := 0;
     i003Count := 0;
     i004Count := 0;
     i005Count := 0;
     i0CoCount := 0;

     sHigh := 0;
     if not fBoundedTo1 then
     begin
          {first parse to find maximum value}

          ASSTable.Open;
          fEnd := False;
          sHigh := 0;

          repeat
                if ASSTable.EOF then
                   fEnd := True;

                if (ASSTable.FieldByName(sFieldToScan).AsFloat > sHigh) then
                   sHigh := ASSTable.FieldByName(sFieldToScan).AsFloat;

                ASSTable.Next;

          until fEnd;

          ASSTable.Close;
     end
     else
         sHigh := 1;

     sStep := sHigh / EMR_CAT_COUNT;

     ASSTable.Open;

     for iCount := 1 to iS_Count do
     {second parse to apply stepwise cutoffs}
     begin
          sToTest := ASSTable.FieldByName(sFieldToScan).AsFloat;

          ASiteArr.rtnValue(iCount,@TmpSite);
          sSingle := TmpSite.rIrreplaceability;
          if (sSingle < 0) then
             sSingle := 0;

          if (TmpSite.status = Pd) then
             sDisplay := 'PDe'
          else
          if (TmpSite.status = Fl) then
             sDisplay := 'Flg'
          else
          if (TmpSite.status = Ex) then
          begin
               sDisplay := 'Exc';
               sSingle := 0;
          end
          else
          if (TmpSite.status = Ig) then
          begin
               sDisplay := 'Ign';
               sSingle := 0;
          end
          else
          if (TmpSite.status = _R1)
          or (TmpSite.status = _R2)
          or (TmpSite.status = _R3)
          or (TmpSite.status = _R4)
          or (TmpSite.status = _R5) then
          begin
               sDisplay := 'Def';
               sSingle := 0;
          end
          else
          if (TmpSite.status = Re) then
          begin
               sDisplay := 'Res';
               sSingle := 0;
          end
          else
          if (sToTest = 0) then
          begin
               sDisplay := '0Co';
               Inc(i0CoCount);
          end
          else
              if (sToTest = sHigh) then
              begin
                   sDisplay := 'Ir1';
                   Inc(iIr1Count);
              end
              else
              begin
                   for iCount2 := (EMR_CAT_COUNT-1) downto 1 do
                   begin
                        sCutOff := sHigh - (iCount2 * sStep);

                        if (sToTest > sCutOff) then
                        begin
                             sDisplay := OrdStr(iCount2);
                        end;
                   end;

                   if (sDisplay = '001') then
                      Inc(i001Count)
                   else
                       if (sDisplay = '002') then
                          Inc(i002Count)
                       else
                           if (sDisplay = '003') then
                              Inc(i003Count)
                           else
                               if (sDisplay = '004') then
                                  Inc(i004Count)
                               else
                                   if (sDisplay = '005') then
                                      Inc(i005Count);
              end;

          TmpSite.sDisplay := sDisplay;
          TmpSite.rIrreplaceability := sSingle;
          ASiteArr.setValue(iCount,@TmpSite);


          ASSTable.Next;
     end;

     ASSTable.Close;
end;

procedure _MapSUMIRR2EMR(const ASiteArr : Array_T;
                         const iS_Count : integer;
                            var iIr1Count, i001Count, i002Count,
                                i003Count, i004Count, i005Count,
                                i0CoCount : integer);
var
   iCount, iCount2 : integer;
   TmpSite : site;
   sSingle : extended;

   sHigh,sStep,sCutOff : extended;

begin
     iIr1Count := 0;
     i001Count := 0;
     i002Count := 0;
     i003Count := 0;
     i004Count := 0;
     i005Count := 0;
     i0CoCount := 0;

     sHigh := 0;
     for iCount := 1 to iS_Count do
     {first parst to find maximum value}
     begin
          ASiteArr.rtnValue(iCount,@TmpSite);

          if (TmpSite.rSummedIrr > sHigh) then
             sHigh := TmpSite.rSummedIrr;
     end;

     sStep := sHigh / EMR_CAT_COUNT;

     for iCount := 1 to iS_Count do
     {second parse to apply stepwise cutoffs}
     begin
          ASiteArr.rtnValue(iCount,@TmpSite);

          TmpSite.sDisplay := '005'; {lowest irreplacability cat by default}
          TmpSite.rIrreplaceability := sSingle;

          if (TmpSite.status = Pd) then
          begin
               TmpSite.sDisplay := 'PDe';
               {TmpSite.rIrreplaceability := 1;}
          end
          else
          if (TmpSite.status = Fl) then
          begin
               TmpSite.sDisplay := 'Flg';
               {TmpSite.rIrreplaceability := 0;}
          end
          else
          if (TmpSite.status = Ex) then
          begin
               TmpSite.sDisplay := 'Exc';
               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.status = Ig) then
          begin
               TmpSite.sDisplay := 'Ign';
               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.status = _R1) then
          begin
               if (ControlRes^.GISLink = ArcView) then
                  TmpSite.sDisplay := 'R1'
               else
                   TmpSite.sDisplay := 'Def';

               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.status = _R2) then
          begin
               if (ControlRes^.GISLink = ArcView) then
                  TmpSite.sDisplay := 'R2'
               else
                   TmpSite.sDisplay := 'Def';

               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.status = _R3) then
          begin
               if (ControlRes^.GISLink = ArcView) then
                  TmpSite.sDisplay := 'R3'
               else
                   TmpSite.sDisplay := 'Def';

               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.status = _R4) then
          begin
               if (ControlRes^.GISLink = ArcView) then
                  TmpSite.sDisplay := 'R4'
               else
                   TmpSite.sDisplay := 'Def';

               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.status = _R5) then
          begin
               if (ControlRes^.GISLink = ArcView) then
                  TmpSite.sDisplay := 'R5'
               else
                   TmpSite.sDisplay := 'Def';

               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.status = Re) then
          begin
               TmpSite.sDisplay := 'Res';
               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.richness = 0)
          or (TmpSite.rSummedIrr = 0) then
          begin
               if (not TmpSite.fSiteHasUse) then
               begin
                    TmpSite.sDisplay := '0Co';
                    Inc(i0CoCount);
               end;
          end
          else
          if (TmpSite.rSummedIrr = sHigh) then
          begin
               TmpSite.sDisplay := 'Ir1';
               Inc(iIr1Count);
          end
          else
          for iCount2 := (EMR_CAT_COUNT-1) downto 1 do
          begin
               sCutOff := sHigh - (iCount2 * sStep);

               if (TmpSite.rSummedIrr > sCutOff) then
               begin
                    TmpSite.sDisplay := OrdStr(iCount2);
               end;
          end;

          if (TmpSite.sDisplay = '001') then
             Inc(i001Count)
          else
              if (TmpSite.sDisplay = '002') then
                 Inc(i002Count)
              else
                  if (TmpSite.sDisplay = '003') then
                     Inc(i003Count)
                  else
                      if (TmpSite.sDisplay = '004') then
                         Inc(i004Count)
                      else
                          if (TmpSite.sDisplay = '005') then
                             Inc(i005Count);

          if (TmpSite.rIrreplaceability < DBASE_FP_CUTOFF) then
             TmpSite.rIrreplaceability := 0;
          {adjust the data so a low value will not trigger
           a floating point translation error in the BDE}

          ASiteArr.setValue(iCount,@TmpSite);
     end;
end;

procedure _MapWAVIRR2EMR(const ASiteArr : Array_T;
                         const iS_Count : integer;
                            var iIr1Count, i001Count, i002Count,
                                i003Count, i004Count, i005Count,
                                i0CoCount : integer);
var
   iCount, iCount2 : integer;
   TmpSite : site;
   sSingle : extended;

   sHigh,sStep,sCutOff : extended;

begin
     iIr1Count := 0;
     i001Count := 0;
     i002Count := 0;
     i003Count := 0;
     i004Count := 0;
     i005Count := 0;
     i0CoCount := 0;

     sHigh := 0;
     for iCount := 1 to iS_Count do
     {first parst to find maximum value}
     begin
          ASiteArr.rtnValue(iCount,@TmpSite);

          if (TmpSite.rWAVIRR > sHigh) then
             sHigh := TmpSite.rWAVIRR;
     end;

     sStep := sHigh / EMR_CAT_COUNT;

     for iCount := 1 to iS_Count do
     begin
          ASiteArr.rtnValue(iCount,@TmpSite);

          TmpSite.sDisplay := '005'; {lowest irreplacability cat by default}
          TmpSite.rIrreplaceability := sSingle;

          if (TmpSite.status = Pd) then
          begin
               TmpSite.sDisplay := 'PDe';
          end
          else
          if (TmpSite.status = Fl) then
          begin
               TmpSite.sDisplay := 'Flg';
          end
          else
          if (TmpSite.status = Ex) then
          begin
               TmpSite.sDisplay := 'Exc';
               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.status = Ig) then
          begin
               TmpSite.sDisplay := 'Ign';
               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.status = _R1) then
          begin
               if (ControlRes^.GISLink = ArcView) then
                  TmpSite.sDisplay := 'R1'
               else
                   TmpSite.sDisplay := 'Def';

               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.status = _R2) then
          begin
               if (ControlRes^.GISLink = ArcView) then
                  TmpSite.sDisplay := 'R2'
               else
                   TmpSite.sDisplay := 'Def';

               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.status = _R3) then
          begin
               if (ControlRes^.GISLink = ArcView) then
                  TmpSite.sDisplay := 'R3'
               else
                   TmpSite.sDisplay := 'Def';

               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.status = _R4) then
          begin
               if (ControlRes^.GISLink = ArcView) then
                  TmpSite.sDisplay := 'R4'
               else
                   TmpSite.sDisplay := 'Def';

               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.status = _R5) then
          begin
               if (ControlRes^.GISLink = ArcView) then
                  TmpSite.sDisplay := 'R5'
               else
                   TmpSite.sDisplay := 'Def';

               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.status = Re) then
          begin
               TmpSite.sDisplay := 'Res';
               TmpSite.rIrreplaceability := 0;
          end
          else
          if (TmpSite.richness = 0)
          or (TmpSite.rWAVIRR = 0) then
          begin
               if (not TmpSite.fSiteHasUse) then
               begin
                    TmpSite.sDisplay := '0Co';
                    Inc(i0CoCount);
               end;
          end
          else
          if (TmpSite.rWAVIRR = 1) then
          begin
               TmpSite.sDisplay := 'Ir1';
               Inc(iIr1Count);
          end
          else
          for iCount2 := (EMR_CAT_COUNT-1) downto 1 do
          begin
               sCutOff := sHigh - (iCount2 * sStep);

               if (TmpSite.rWAVIRR > sCutOff) then
               begin
                    TmpSite.sDisplay := OrdStr(iCount2);
                    TmpSite.rIrreplaceability := sSingle;
               end;
          end;

          if (TmpSite.sDisplay = '001') then
             Inc(i001Count)
          else
              if (TmpSite.sDisplay = '002') then
                 Inc(i002Count)
              else
                  if (TmpSite.sDisplay = '003') then
                     Inc(i003Count)
                  else
                      if (TmpSite.sDisplay = '004') then
                         Inc(i004Count)
                      else
                          if (TmpSite.sDisplay = '005') then
                             Inc(i005Count);

          if (TmpSite.rIrreplaceability < DBASE_FP_CUTOFF) then
             TmpSite.rIrreplaceability := 0;
          {adjust the data so a low value will not trigger
           a floating point translation error in the BDE}

          ASiteArr.setValue(iCount,@TmpSite);
     end;
end;


function OrdStr(const iEmrCat : integer) : string;
begin
     Result := IntToStr(iEmrCat);

     if (iEmrCat = EMR_CAT_COUNT) then
        Result := '999'
     else
         if (iEmrCat < 10) then
            Result := '00' + Result
         else
             if (iEmrCat < 100) then
                Result := '0' + Result;
end;

procedure Debug2FileA(const sLine : string);
var
   DbgFile : Text;
begin
     assign(DbgFile,'c:\dbg.txt');
     append(DbgFile);

     writeln(DbgFile,sLine);

     close(DbgFile);
end;

procedure ParseInsertSpace(const fOldIni:boolean;
                           const sDatabase:string;
                           App : TApplication);
var
   iCount : integer;
begin
     try
        Form1 := TForm1.Create(App);

        Form1.Listbox1.Items.Clear;

        if fOldIni then
           Form1.Listbox1.Items.LoadFromFile(sDatabase + '\' + OLD_INI_FILE_NAME)
        else
            Form1.Listbox1.Items.LoadFromFile(sDatabase + '\' + INI_FILE_NAME);

        if (Form1.Listbox1.Items.Count > 1) then
        begin
             iCount := 1;

             repeat
                   if (Length(Form1.Listbox1.Items.Strings[iCount]) > 0) then
                      if (Form1.Listbox1.Items.Strings[iCount-1] <> '')
                      and (Form1.Listbox1.Items.Strings[iCount][1] = '[') then
                          Form1.Listbox1.Items.Insert(iCount,'');

                   {if (Form1.Listbox1.Items.Strings[iCount-1] = '')
                   and (Form1.Listbox1.Items.Strings[iCount] = '') then
                       Form1.Listbox1.Items.Delete(iCount);}

                   Inc(iCount);

             until iCount >= Form1.Listbox1.Items.Count;
        end;

        if fOldIni then
           Form1.Listbox1.Items.SaveToFile(sDatabase + '\' + OLD_INI_FILE_NAME)
        else
            Form1.Listbox1.Items.SaveToFile(sDatabase + '\' + INI_FILE_NAME);

        Form1.Listbox1.Items.Clear;

        Form1.Free;

        {$IFDEF VER90}
        {ParseRemoveSpaces(fOldIni,sDatabase,App);}
        {$ENDIF}

     except
           MessageDlg('exception in ParseInsertSpace',mtError,[mbOk],0);
     end;
end;

procedure ParseRemoveSpaces(const fOldIni:boolean;
                            const sDatabase:string;
                            App : TApplication);
var
   iCount : integer;
begin
     try
        Form1 := TForm1.Create(App);

        Form1.Listbox1.Items.Clear;

        if fOldIni then
           Form1.Listbox1.Items.LoadFromFile(sDatabase + '\' + OLD_INI_FILE_NAME)
        else
            Form1.Listbox1.Items.LoadFromFile(sDatabase + '\' + INI_FILE_NAME);

        if (Form1.Listbox1.Items.Count > 1) then
        begin
             iCount := 1;

             repeat
                   {if (Length(Form1.Listbox1.Items.Strings[iCount]) > 0) then
                      if (Form1.Listbox1.Items.Strings[iCount-1] <> '')
                      and (Form1.Listbox1.Items.Strings[iCount][1] = '[') then
                          Form1.Listbox1.Items.Insert(iCount,'');}

                   repeat

                         if (Form1.Listbox1.Items.Strings[iCount-1] = '')
                         and (Form1.Listbox1.Items.Strings[iCount] = '') then
                             Form1.Listbox1.Items.Delete(iCount);

                   until (Form1.Listbox1.Items.Strings[iCount-1] <>
                          Form1.Listbox1.Items.Strings[iCount]);

                   Inc(iCount);

             until iCount >= Form1.Listbox1.Items.Count;
        end;

        if fOldIni then
           Form1.Listbox1.Items.SaveToFile(sDatabase + '\' + OLD_INI_FILE_NAME)
        else
            Form1.Listbox1.Items.SaveToFile(sDatabase + '\' + INI_FILE_NAME);

        Form1.Listbox1.Items.Clear;

     except
           MessageDlg('exception in ParseRemoveSpaces',mtError,[mbOk],0);
     end;

     Form1.Free;
end;

function ACopyFile(const sSourceFile, sDestFile : string) : boolean;
{var
   iHInFile, iHOutFile, iFilePos,
   iSeekInPos, iSeekOutPos,
   iBytesRead, iBytesWritten : integer;
   wWord : word;}
begin
     // FMXUtils CopyFile(FromFile, ToFile)
     try
        Result := False;
        CopyFile(sSourceFile,sDestFile);
        Result := True;
     except
     end;

     {Result := True;
     iHInFile := FileOpen(sSourceFile,fmShareDenyNone);
     iBytesWritten := 0;

     if (iHInFile > 0) then
     begin
          iHOutFile := FileCreate(sDestFile);

          if (iHOutFile > 0) then
          begin
               iFilePos := 0;

               repeat
                     iSeekInPos := FileSeek(iHInFile,iFilePos,0);

                     iBytesRead := FileRead(iHInFile,wWord,1);

                     if (iBytesRead = 1) then
                     begin
                          iSeekOutPos := FileSeek(iHOutFile,iFilePos,0);
                          Inc(iFilePos);
                          iBytesWritten := FileWrite(iHOutFile,wWord,1);
                     end;

               until (iBytesWritten < 1)
               or (iBytesRead < 1);

               FileClose(iHOutFile);
          end
          else
              Result := False;

          FileClose(iHInFile);

          if (iBytesWritten < 1) then
             Result := False;
     end
     else
     begin

          MessageDlg('Cannot find ' + sSourceFile + '  Please contact software support',
                     mtError,[mbOk],0);

          Result := False;
     end;}
end;

function Status2Str (const AStatus : Status_T) : string;
begin
     case AStatus of
          Av : Result := 'Av';
          _R1 : Result := 'R1';
          _R2 : Result := 'R2';
          _R3 : Result := 'R3';
          _R4 : Result := 'R4';
          _R5 : Result := 'R5';
          Pd : Result := 'PR';
          Fl : Result := 'Fl';
          Ex : Result := 'Ex';
          Ig : Result := 'IE';
          Re : Result := 'IR';
     else
         Result := '??';
     end;
end;

function Status2StrLong (const AStatus : Status_T) : string;
begin
     case AStatus of
          Av : Result := 'Available';
          _R1 : Result := ControlRes^.sR1Label;
          _R2 : Result := ControlRes^.sR2Label;
          _R3 : Result := ControlRes^.sR3Label;
          _R4 : Result := ControlRes^.sR4Label;
          _R5 : Result := ControlRes^.sR5Label;
          Pd : Result := 'Partially Selected';
          Fl : Result := 'Flagged';
          Ex : Result := 'Excluded';
          Ig : Result := 'Ignored';
          Re : Result := 'Reserved';
     else
         Result := '??';
     end;
end;

end.
