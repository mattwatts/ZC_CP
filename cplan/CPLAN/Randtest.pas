unit Randtest;

interface


procedure RunRandomTest(const lIterations : longint);
procedure RandomFeatures2Target;
procedure RandomSelect(const lOrigAvail : longint);



implementation

uses
    Control, Sf_irrep, Editcoun, SysUtils,
    Forms, Controls, Dialogs, F1Find,
  {$IFDEF VER80}
  Cpng_imp;
  {$ELSE}
  Dll_u1;
  {$ENDIF}

procedure RandomSelect(const lOrigAvail : longint);
var
   lSiteCount, lSite, lCount, lRandResult : longint;
   fSelect : boolean;
begin
     with ControlForm do
     begin
          if (Available.Items.Count > (lOrigAvail DIV 2)) then
          begin
               UnHighlight(Available,fKeepHighlight);

               {randomly highlight some Ur sites}
               lSiteCount := Random(Available.Items.Count) + 1;

               if (lSiteCount > 0) then
                  for lCount := 1 to lSiteCount do
                  begin
                       lSite := Random(Available.Items.Count);
                       Available.Selected[lSite] := True;
                  end;
          end;

          if (Available.SelCount > 0) then
          begin
               {select Ur sites as R1}
               lRandResult := Random(8);

               case lRandResult of
                    0 : MoveGroup(Available,AvailableKey,
                                  R1,R1Key,FALSE,True);
                    1 : MoveGroup(Available,AvailableKey,
                                  R2,R2Key,FALSE,True);
                    2 : MoveGroup(Available,AvailableKey,
                                  R3,R3Key,FALSE,True);
                    3 : MoveGroup(Available,AvailableKey,
                                  R4,R4Key,FALSE,True);
                    4 : MoveGroup(Available,AvailableKey,
                                  R5,R5Key,FALSE,True);
                    5 : MoveGroup(Available,AvailableKey,
                                  Partial,PartialKey,FALSE,True);
                    6 : MoveGroup(Available,AvailableKey,
                                  Flagged,FlaggedKey,FALSE,True);
                    7 : MoveGroup(Available,AvailableKey,
                                  Excluded,ExcludedKey,FALSE,True);
               end;
          end
          else
          begin
               UnHighlight(R1,fKeepHighlight);
               UnHighlight(R2,fKeepHighlight);
               UnHighlight(R3,fKeepHighlight);
               UnHighlight(R4,fKeepHighlight);
               UnHighlight(R5,fKeepHighlight);
               UnHighlight(Partial,fKeepHighlight);
               UnHighlight(Flagged,fKeepHighlight);
               UnHighlight(Excluded,fKeepHighlight);

               {randomly deselect some sites to Ur}
               fSelect := False;
               repeat
                     lRandResult := Random(8);

                     case lRandResult of
                          0 : if (R1.Items.Count > 0) then
                              begin
                                   lSiteCount := Random(R1.Items.Count) + 1;

                                   if (lSiteCount > 0) then
                                      for lCount := 1 to lSiteCount do
                                      begin
                                           fSelect := True;
                                           lSite := Random(R1.Items.Count);
                                           R1.Selected[lSite] := True;
                                      end;
                              end;

                          1 : if (R2.Items.Count > 0) then
                              begin
                                   lSiteCount := Random(R2.Items.Count) + 1;

                                   if (lSiteCount > 0) then
                                      for lCount := 1 to lSiteCount do
                                      begin
                                           fSelect := True;
                                           lSite := Random(R2.Items.Count);
                                           R2.Selected[lSite] := True;
                                      end;
                              end;

                          2 : if (R3.Items.Count > 0) then
                              begin
                                   lSiteCount := Random(R3.Items.Count) + 1;

                                   if (lSiteCount > 0) then
                                      for lCount := 1 to lSiteCount do
                                      begin
                                           fSelect := True;
                                           lSite := Random(R3.Items.Count);
                                           R3.Selected[lSite] := True;
                                      end;
                              end;

                          3 : if (R4.Items.Count > 0) then
                              begin
                                   lSiteCount := Random(R4.Items.Count) + 1;

                                   if (lSiteCount > 0) then
                                      for lCount := 1 to lSiteCount do
                                      begin
                                           fSelect := True;
                                           lSite := Random(R4.Items.Count);
                                           R4.Selected[lSite] := True;
                                      end;
                              end;

                          4 : if (R5.Items.Count > 0) then
                              begin
                                   lSiteCount := Random(R5.Items.Count) + 1;

                                   if (lSiteCount > 0) then
                                      for lCount := 1 to lSiteCount do
                                      begin
                                           fSelect := True;
                                           lSite := Random(R5.Items.Count);
                                           R5.Selected[lSite] := True;
                                      end;
                              end;

                          5 : if (Partial.Items.Count > 0) then
                              begin
                                   lSiteCount := Random(Partial.Items.Count) + 1;

                                   if (lSiteCount > 0) then
                                      for lCount := 1 to lSiteCount do
                                      begin
                                           fSelect := True;
                                           lSite := Random(Partial.Items.Count);
                                           Partial.Selected[lSite] := True;
                                      end;
                              end;

                          6 : if (Flagged.Items.Count > 0) then
                              begin
                                   lSiteCount := Random(Flagged.Items.Count) + 1;

                                   if (lSiteCount > 0) then
                                      for lCount := 1 to lSiteCount do
                                      begin
                                           fSelect := True;
                                           lSite := Random(Flagged.Items.Count);
                                           Flagged.Selected[lSite] := True;
                                      end;
                              end;

                          7 : if (Excluded.Items.Count > 0) then
                              begin
                                   lSiteCount := Random(Excluded.Items.Count) + 1;

                                   if (lSiteCount > 0) then
                                      for lCount := 1 to lSiteCount do
                                      begin
                                           fSelect := True;
                                           lSite := Random(Excluded.Items.Count);
                                           Excluded.Selected[lSite] := True;
                                      end;
                              end;
                     end;

               until fSelect;


               if (R1.SelCount > 0) then
                  MoveGroup(R1,R1Key,
                            Available,AvailableKey,FALSE,True)
               else
               if (R2.SelCount > 0) then
                  MoveGroup(R2,R2Key,
                            Available,AvailableKey,FALSE,True)
               else
               if (R3.SelCount > 0) then
                  MoveGroup(R3,R3Key,
                            Available,AvailableKey,FALSE,True)
               else
               if (R4.SelCount > 0) then
                  MoveGroup(R4,R4Key,
                            Available,AvailableKey,FALSE,True)
               else
               if (R5.SelCount > 0) then
                  MoveGroup(R5,R5Key,
                            Available,AvailableKey,FALSE,True)
               else
               if (Partial.SelCount > 0) then
                  MoveGroup(Partial,PartialKey,
                            Available,AvailableKey,FALSE,True)
               else
               if (Flagged.SelCount > 0) then
                  MoveGroup(Flagged,FlaggedKey,
                            Available,AvailableKey,FALSE,True)
               else
               if (Excluded.SelCount > 0) then
                  MoveGroup(Excluded,ExcludedKey,
                            Available,AvailableKey,FALSE,True);
          end;

          Refresh;
     end;
end;

procedure RandomFeatures2Target;
var
   lRandResult, lCount, lCount2,
   lChooseCount, lFeature : longint;
begin
     try
        FeaturesToTargetForm := TFeaturesToTargetForm.Create(Application);

        with FeaturesToTargetForm do
        begin
             Show;

             lRandResult := Random(5);

             if (lRandResult > 0) then
                for lCount := 1 to lRandResult do
                begin
                     if (F1FindBox.SelCount > 0) then
                        for lCount2 := 0 to (F1FindBox.Items.Count-1) do
                            F1FindBox.Selected[lCount2] := False;

                     lChooseCount := Random(F1FindBox.Items.Count);
                     if (lChooseCount > 0) then
                     repeat
                           lFeature := Random(F1FindBox.Items.Count-1) + 1;
                           F1FindBox.Selected[lFeature] := True;

                     until (F1FindBox.SelCount >= lChooseCount);

                     if (Random(2) = 0) then
                        FindAvailableSitesClick
                     else
                         ShowDeferredClick;
                end;

             ModalResult := mrOk;
        end;
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RandomFeatures2Target',mtError,[mbOk],0);
     end;

     FeaturesToTargetForm.Free;
end;

procedure RunRandomTest(const lIterations : longint);
var
   fStop : boolean;
   lRunCount, lSiteCount, lSite, lCount,
   lOrigAvail, lSelectCount : longint;
begin
     try
        //Randomize;

        ControlRes^.fRandomTest := True;
        fStop := False;
        lRunCount := 0;
        lOrigAvail := ControlForm.Available.Items.Count +
                      ControlForm.R1.Items.Count +
                      ControlForm.R2.Items.Count +
                      ControlForm.R3.Items.Count +
                      ControlForm.R4.Items.Count +
                      ControlForm.R5.Items.Count +
                      ControlForm.Partial.Items.Count +
                      ControlForm.Flagged.Items.Count +
                      ControlForm.Excluded.Items.Count;

        repeat
              Inc(lRunCount);

              Screen.Cursor := crHourglass;

              {EditCountForm.lblProgress.Caption := 'Run ' + IntToStr(lRunCount) +
                                                   ' of ' + IntToStr(lIterations);
              EditCountForm.Refresh;}

              lSelectCount := Random(5);
              {select a random number of sites}

              if (lSelectCount > 0) then
                 for lCount := 1 to lSelectCount do
                     RandomSelect(lOrigAvail);

              ExecuteIrreplaceability(-1,False,False,True,True,'');
              {run Irreplaceability}

              ControlForm.Refresh;

              RandomFeatures2Target;
              {randomize features2target}

        until (lRunCount >= lIterations);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RunRandomTest',mtError,[mbOk],0);
     end;

     ControlRes^.fRandomTest := False;
end;

end.
