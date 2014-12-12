unit Resize;

interface

procedure FitComponents2Form;

procedure CheckSelEmpty; {sees if selected/mandatory site lists empty, de/activates controls}
procedure CheckManEmpty;
procedure CheckExcEmpty;
procedure CheckParEmpty;
procedure CheckFlgEmpty;

procedure EnableMandatory;
procedure DisableMandatory;
procedure EnableExcluded;
procedure DisableExcluded;
procedure EnablePartial;
procedure DisablePartial;
procedure EnableFlagged;
procedure DisableFlagged;

procedure ManChoiceOn;
procedure ManChoiceOff;
procedure ExcChoiceOn;
procedure ExcChoiceOff;
procedure ParChoiceOn;
procedure ParChoiceOff;
procedure FlgChoiceOn;
procedure FlgChoiceOff;

procedure ApplyHide;

implementation

uses
    Control, Global, StdCtrls, ExtCtrls;


(************************************************************)

procedure CustPosBox(ABox : TListBox; APanel : TPanel;
                     Grp, UnGrp, UnAll : TButton;
                     var iNextTop : integer);
begin
     APanel.Visible := True;
     APanel.Top := iNextTop;
     APanel.Width := ControlForm.Available.Width;
     APanel.Left := ControlForm.R1.Left;

     ABox.Visible := True;
     ABox.Top := APanel.Top + APanel.Height;
     ABox.Width := ControlForm.Available.Width;
     ABox.Left := ControlForm.R1.Left;
     ABox.Height := ControlForm.R1.Height;

     {check height of selection buttons}
     Grp.Height := SEL_BUTTON_HEIGHT;
     UnGrp.Height := SEL_BUTTON_HEIGHT;
     UnAll.Height := SEL_BUTTON_HEIGHT;
     if ((Grp.Height * 3) > ABox.Height) then
     begin
          Grp.Height := ABox.Height div 3;
          UnGrp.Height := Grp.Height;
          UnAll.Height := Grp.Height;
     end;

     {position the selection buttons}
     Grp.Top := ABox.Top - ControlForm.MidPanel.Top;
     Grp.Left := (ControlForm.MidPanel.Width - Grp.Width) div 2;
     UnGrp.Top := Grp.Top + Grp.Height;
     UnGrp.Left := (ControlForm.MidPanel.Width - UnGrp.Width) div 2;
     UnAll.Top := UnGrp.Top + UnGrp.Height;
     UnAll.Left := (ControlForm.MidPanel.Width - UnAll.Width) div 2;

     iNextTop := ABox.Top + ABox.Height;
end;

procedure FitComponents2Form;
{sizes components on the ControlForm}
var
   iNumSelBoxes, iToolWidth, iNextTop : integer;
begin
     with ControlForm do
     begin
          ToolPanel.Width := ControlForm.ClientWidth;

          {now fit the Tool components onto the ToolPanel}

          {UseFeatCutOffs.Caption := 'Use Imported Targets';}
          Label4.Caption := 'Target %';

          {if UseFeatCutOffs.Checked then}

          iToolWidth := btnIrrep.Width +
                        ClickGroup.Width +
                        UseFeatCutOffs.Width +
                        (4 * TOOL_DIVIDE_SPACE);
          {{else
              iToolWidth := btnIrrep.Width +
                        ToggleGroup.Width +
                        ClickGroup.Width +
                        TargetPercent.Width +
                        UseFeatCutOffs.Width +
                        (5 * TOOL_DIVIDE_SPACE);}

          btnIrrep.Left := TOOL_DIVIDE_SPACE;
          btnIrrep.Top := TOOL_DIVIDE_SPACE;
          btnAccept.Left := TOOL_DIVIDE_SPACE;
          btnAccept.Top := btnIrrep.Height + TOOL_DIVIDE_SPACE + 1;

          if (iToolWidth < ToolPanel.Width) then
          begin
               {there is enough room for all Tool components on the ToolPanel}
               ClickGroup.Visible := True;

               ClickGroup.Left := btnIrrep.Left + btnIrrep.Width + TOOL_DIVIDE_SPACE;
               ClickGroup.Top := TOOL_DIVIDE_SPACE-2;

               if not UseFeatCutOffs.Checked then
               begin
                    Label4.Visible := True;
                    TargetPercent.Visible := True;

                    Label4.Left := ClickGroup.Left + ClickGroup.Width + TOOL_DIVIDE_SPACE;
                    Label4.Top := TOOL_DIVIDE_SPACE;

                    TargetPercent.Left := Label4.Left;
                    TargetPercent.Top := Label4.Top + Label4.Height + TOOL_DIVIDE_SPACE;

                    UseFeatCutOffs.Left := TargetPercent.Left{TargetPercent.Left + TargetPercent.Width + TOOL_DIVIDE_SPACE};
                    UseFeatCutOffs.Top := TargetPercent.Top + TargetPercent.Height + TOOL_DIVIDE_SPACE;
               end
               else
               begin
                    Label4.Visible := False;
                    TargetPercent.Visible := False;

                    UseFeatCutOffs.Left := ClickGroup.Left + ClickGroup.Width + TOOL_DIVIDE_SPACE;
                    UseFeatCutOffs.Top := Label4.Height + (2 * TOOL_DIVIDE_SPACE);
               end;
          end
          else
          begin
               {there is NOT enough room for all Tool components on the ToolPanel}
               ClickGroup.Visible := False;

               if not UseFeatCutOffs.Checked then
               begin
                    Label4.Visible := True;
                    TargetPercent.Visible := True;

                    Label4.Left := btnIrrep.Left + btnIrrep.Width + TOOL_DIVIDE_SPACE;
                    Label4.Top := TOOL_DIVIDE_SPACE;

                    TargetPercent.Left := Label4.Left;
                    TargetPercent.Top := Label4.Top + Label4.Height + TOOL_DIVIDE_SPACE;

                    UseFeatCutOffs.Left := TargetPercent.Left {+ TargetPercent.Width + TOOL_DIVIDE_SPACE};
                    UseFeatCutOffs.Top := TargetPercent.Top + TargetPercent.Height + TOOL_DIVIDE_SPACE;
               end
               else
               begin
                    Label4.Visible := False;
                    TargetPercent.Visible := False;

                    UseFeatCutOffs.Left := btnIrrep.Left + btnIrrep.Width + TOOL_DIVIDE_SPACE;
                    UseFeatCutOffs.Top := Label4.Height + (2 * TOOL_DIVIDE_SPACE);
               end;
          end;

          {calculate how many selection boxes are visible}
          iNumSelBoxes := 1;

          if not HideMandatory1.Checked then
             Inc(iNumSelBoxes);
          if not HidePartial1.Checked then
             Inc(iNumSelBoxes);
          if not HideFlagged1.Checked then
             Inc(iNumSelBoxes);
          if not HideExcluded1.Checked then
             Inc(iNumSelBoxes);

          StatusPanel.Left := 0;
          StatusPanel.Top := ControlForm.ClientHeight - StatusPanel.Height;
          StatusPanel.Width := ToolPanel.Width;
          {position StatusPanel}

          MidPanel.Width := UnSelectAll.Width + 2;
          {ie. make MidPanel just wider than its widest possible control}
          MidPanel.Top := ToolPanel.Top + ToolPanel.Height + 1;
          MidPanel.Left := (ToolPanel.Width div 2) - (MidPanel.Width div 2);
          MidPanel.Height := StatusPanel.Top - MidPanel.Top;
          {position MidPanel}

          LeftPanel.Top := MidPanel.Top;
          LeftPanel.Height := MidPanel.Height;
          LeftPanel.Width := TOOL_DIVIDE_SPACE;
          {position LeftPanel}

          RightPanel.Top := LeftPanel.Top;
          RightPanel.Height := LeftPanel.Height;
          RightPanel.Width := LeftPanel.Width;
          RightPanel.Left := ToolPanel.Width - RightPanel.Width;
          {position RightPanel}

          Available.Top := MidPanel.Top;
          Available.Height := MidPanel.Height;
          Available.Left := LeftPanel.Width;
          Available.Width := MidPanel.Left - 1 - LeftPanel.Width;
          {position Available list box}

          {position Negotiated (referred to as Selected in code) list box}
          R1.Top := Available.Top;
          R1.Left := MidPanel.Left + MidPanel.Width;
          R1.Width := Available.Width;
          R1.Height := (MidPanel.Height - (iNumSelBoxes-1) * SplitPanelMan.Height)
                             div iNumSelBoxes;
          SelectedLabel.Left := MandatoryLabel.Left + R1.Left;
          iNextTop := R1.Top + R1.Height;
          {check height of Selected box buttons}
          SelectGroup.Height := SEL_BUTTON_HEIGHT;
          UnSelectGroup.Height := SEL_BUTTON_HEIGHT;
          UnSelectAll.Height := SEL_BUTTON_HEIGHT;
          if ((SelectGroup.Height * 3) > R1.Height) then
          begin
               SelectGroup.Height := R1.Height div 3;
               UnSelectGroup.Height := SelectGroup.Height;
               UnSelectAll.Height := SelectGroup.Height;
          end;
          {position the Selected box buttons}
          SelectGroup.Top := R1.Top - ControlForm.MidPanel.Top;
          SelectGroup.Left := (ControlForm.MidPanel.Width - SelectGroup.Width) div 2;
          UnSelectGroup.Top := SelectGroup.Top + SelectGroup.Height;
          UnSelectGroup.Left := (ControlForm.MidPanel.Width - UnSelectGroup.Width) div 2;
          UnSelectAll.Top := UnSelectGroup.Top + UnSelectGroup.Height;
          UnSelectAll.Left := (ControlForm.MidPanel.Width - UnSelectAll.Width) div 2;

          {position Split panel(s) and List box(es) if necessary}
          {position for Mandatory sites}
          if HideMandatory1.Checked then
          begin
               {make Mandatory invisible}
               R2.Visible := False;
               SplitPanelMan.Visible := False;
          end
          else
          begin
               {make Mandatory visible}
               CustPosBox(R2,SplitPanelMan,ManGroup,
                          UnManGroup,UnManAll,iNextTop);
          end;
          {position for Partial sites}
          if HidePartial1.Checked then
          begin
               {make Partial invisible}
               Partial.Visible := False;
               SplitPanelPar.Visible := False;

               ParGroup.Visible := False;
               UnParGroup.Visible := False;
               UnParAll.Visible := False;
          end
          else
          begin
               {make Partial visible}
               CustPosBox(Partial,SplitPanelPar,ParGroup,
                          UnParGroup,UnParAll,iNextTop);
          end;
          {position for Flagged sites}
          if HideFlagged1.Checked then
          begin
               {make Flagged invisible}
               Flagged.Visible := False;
               SplitPanelFlg.Visible := False;

               FlgGroup.Visible := False;
               UnFlgGroup.Visible := False;
               UnFlgAll.Visible := False;
          end
          else
          begin
               {make Flagged visible}
               CustPosBox(Flagged,SplitPanelFlg,FlgGroup,
                          UnFlgGroup,UnFlgAll,iNextTop);
          end;
          {position for Excluded sites}
          if HideExcluded1.Checked then
          begin
               {make Excluded invisible}
               Excluded.Visible := False;
               SplitPanelExc.Visible := False;
          end
          else
          begin
               {make Excluded visible}
               CustPosBox(Excluded,SplitPanelExc,ExcGroup,
                          UnExcGroup,UnExcAll,iNextTop);
          end;

          ProgressGauge.Width := Trunc((StatusPanel.Width div 2) - (TOOL_DIVIDE_SPACE * 1.5));
          ProgressGauge.Left := (StatusPanel.Width div 2);
          ProgressGauge.Update;
          {size ProgressGauge}
     end;
end;

(************************************************************)

procedure CheckSelEmpty;
begin
  with ControlForm do
  begin
     if (R1.Items.Count > 0) then
     begin
          {enable un-select Selected sites}
          UnSelectGroup.Visible := True;
          UnSelectAll.Visible := True;
          UnSelectGroup.Enabled := True;
          UnSelectAll.Enabled := True;
          Negotiated2.Enabled := True;
     end
     else
     begin
          {disable un-select Selected sites}
          UnSelectGroup.Visible := False;
          UnSelectAll.Visible := False;
          UnSelectGroup.Enabled := False;
          UnSelectAll.Enabled := False;
          Negotiated2.Enabled := False;
     end;
  end;
end;

procedure CheckExcEmpty;
begin
     with ControlForm do
     begin
          if (Excluded.Items.Count > 0)
          and not HideExcluded1.Checked then
          begin
               {enable un-select Excluded sites}
               {ExcGroup.Visible := True;
               ExcGroup.Enabled := True;}
               UnExcGroup.Visible := True;
               UnExcGroup.Enabled := True;
               UnExcAll.Visible := True;
               UnExcAll.Enabled := True;
               Excluded3.Enabled := True;
          end
          else
          begin
               {disable un-select Excluded sites}
               {ExcGroup.Visible := False;
               ExcGroup.Enabled := False;}
               UnExcGroup.Visible := False;
               UnExcGroup.Enabled := False;
               UnExcAll.Visible := False;
               UnExcAll.Enabled := False;
               Excluded3.Enabled := False;
          end;
     end;
end;

procedure CheckManEmpty;
begin
  with ControlForm do
  begin
     if (R2.Items.Count > 0)
     and not HideMandatory1.Checked then
     begin
          {enable un-select Mandatory sites}
          UnManGroup.Visible := True;
          UnManAll.Visible := True;
          UnManGroup.Enabled := True;
          UnManAll.Enabled := True;
          Mandatory3.Enabled := True;
     end
     else
     begin
          {disable un-select Mandatory sites}
          UnManGroup.Visible := False;
          UnManAll.Visible := False;
          UnManGroup.Enabled := False;
          UnManAll.Enabled := False;
          Mandatory3.Enabled := False;
     end;
  end;
end;

procedure CheckParEmpty;
begin
  with ControlForm do
  begin
     if (Partial.Items.Count > 0)
     and not HidePartial1.Checked then
     begin
          {enable un-select Partial sites}
          UnParGroup.Visible := True;
          UnParAll.Visible := True;
          Partial3.Enabled := True;
     end
     else
     begin
          {disable un-select Partial sites}
          UnParGroup.Visible := False;
          UnParAll.Visible := False;
          Partial3.Enabled := False;
     end;
  end;
end;

procedure CheckFlgEmpty;
begin
  with ControlForm do
  begin
     if (Flagged.Items.Count > 0)
     and not HideFlagged1.Checked then
     begin
          {enable un-select Flagged sites}
          UnFlgGroup.Visible := True;
          UnFlgAll.Visible := True;
          Flagged3.Enabled := True;
     end
     else
     begin
          {disable un-select Flagged sites}
          UnFlgGroup.Visible := False;
          UnFlgAll.Visible := False;
          Flagged3.Enabled := False;
     end;
  end;
end;

procedure ManChoiceOff;
{var
   iListPos : integer;}
begin
     with ControlForm do
     begin
          ManGroup.Visible := False;
          UnManGroup.Visible := False;
          UnManAll.Visible := False;

          Mandatory3.Enabled := False;
          {Both1.Enabled := False;}
     end;
end;

procedure ExcChoiceOff;
{var
   iListPos : integer;}
begin
     with ControlForm do
     begin
          ExcGroup.Visible := False;
          UnExcGroup.Visible := False;
          UnExcAll.Visible := False;
          {Excluded group buttons}

          Excluded3.Enabled := False;
          {Excluded menu items}
     end;
end;

procedure DisableMandatory;
begin
     {this method dis-appears the Mandatory list box and the SplitPanel}

     with ControlForm do
     begin
          ManChoiceOff;

          MandatoryLabel.Visible := False;
          SplitPanelMan.Visible := False;
          R2.Visible := False;


          (*if ExcGroup.Visible then
          begin
               Selected.Height := (MidPanel.Height - SplitPanelExc.Height) div 2;
               Excluded.Height := Selected.Height;
          end
          else
              Selected.Height := MidPanel.Height;

          Selected.Update;
          MidPanel.Update;*)

          FitComponents2Form;
     end;
end;

procedure DisableExcluded;
begin
     with ControlForm do
     begin
          ExcChoiceOff;

          ExcludedLabel.Visible := False;
          SplitPanelExc.Visible := False;
          Excluded.Visible := False;

          FitComponents2Form;
     end;
end;

procedure ManChoiceOn;
begin
     with ControlForm do
     begin
          ManGroup.Visible := True;
          UnManGroup.Visible := True;
          UnManAll.Enabled := True;
          UnManAll.Visible := True;
          {Mandatory group buttons}

          {menu items}
     end;
end;

procedure ExcChoiceOn;
begin
     with ControlForm do
     begin
          ExcGroup.Visible := True;
          UnExcGroup.Visible := True;
          UnExcAll.Visible := True;
          {Excluded group buttons}

          Excluded3.Enabled := True;
          {menu items}
     end;
end;

procedure ParChoiceOn;
begin
     with ControlForm do
     begin
          ParGroup.Visible := True;
          UnParGroup.Visible := True;
          UnParAll.Visible := True;
          {Partial group buttons}

          Partial3.Enabled := True;
          {menu items visible}
     end;
end;

procedure ParChoiceOff;
begin
     with ControlForm do
     begin
          ParGroup.Visible := False;
          UnParGroup.Visible := False;
          UnParAll.Visible := False;
          {Partial group buttons}

          Partial3.Enabled := False;
          {menu item}
     end;
end;

procedure FlgChoiceOn;
begin
     with ControlForm do
     begin
          FlgGroup.Visible := True;
          UnFlgGroup.Visible := True;
          UnFlgAll.Visible := True;
          {Flagged group buttons}

          Flagged3.Enabled := True;
          {menu items visible}
     end;
end;

procedure FlgChoiceOff;
begin
     with ControlForm do
     begin
          FlgGroup.Visible := False;
          UnFlgGroup.Visible := False;
          UnFlgAll.Visible := False;
          {Flagged group buttons}

          Flagged3.Enabled := False;
          {menu items visible}
     end;
end;

procedure EnablePartial;
begin
     with ControlForm do
     begin
          ParLabel.Visible := True;
          SplitPanelPar.Visible := True;
          Partial.Visible := True;

          ParChoiceOn;

          CheckParEmpty;

          FitComponents2Form;
     end;
end;

procedure DisablePartial;
begin
     with ControlForm do
     begin
          ParLabel.Visible := False;
          SplitPanelPar.Visible := False;
          Partial.Visible := False;

          ParChoiceOff;

          CheckParEmpty;

          FitComponents2Form;
     end;
end;

procedure EnableFlagged;
begin
     with ControlForm do
     begin
          FlgLabel.Visible := True;
          SplitPanelFlg.Visible := True;
          Flagged.Visible := True;

          FlgChoiceOn;

          CheckFlgEmpty;

          FitComponents2Form;
     end;
end;

procedure DisableFlagged;
begin
     with ControlForm do
     begin
          FlgLabel.Visible := False;
          SplitPanelFlg.Visible := False;
          Flagged.Visible := False;

          FlgChoiceOff;

          CheckFlgEmpty;

          FitComponents2Form;
     end;
end;

procedure EnableMandatory;
begin
     with ControlForm do
     begin
          MandatoryLabel.Visible := True;
          SplitPanelMan.Visible := True;
          R2.Visible := True;

          ManChoiceOn;

          CheckManEmpty;

          FitComponents2Form;
     end;
end;

procedure EnableExcluded;
begin
     with ControlForm do
     begin
          ExcludedLabel.Visible := True;
          SplitPanelExc.Visible := True;
          Excluded.Visible := True;

          ExcChoiceOn;

          CheckExcEmpty;

          FitComponents2Form;
     end;
end;

procedure ApplyHide;
begin
     with ControlForm do
     begin
          CheckSelEmpty;

          if HideMandatory1.Checked then
          begin
               DisableMandatory;
               ManGroup.Visible := False;
          end
          else
              EnableMandatory;

          CheckManEmpty;

          if HidePartial1.Checked then
             DisablePartial
          else
              EnablePartial;

          CheckParEmpty;

          if HideFlagged1.Checked then
             DisableFlagged
          else
              EnableFlagged;

          CheckFlgEmpty;

          if HideExcluded1.Checked then
          begin
               DisableExcluded;
               ExcGroup.Visible := False;
          end
          else
              EnableExcluded;

          CheckExcEmpty;

          if (R1.Items.Count > 0)
          or (R2.Items.Count > 0) then
          begin
               DeferredNeMaPd1.Enabled := True;
               Deferred1.Enabled := True;
          end
          else
          begin
               DeferredNeMaPd1.Enabled := False;
               Deferred1.Enabled := False;
          end;

          FitComponents2Form;
     end;
end;

end.
