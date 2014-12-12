unit Featgrid;

{$I \SOFTWARE\cplan\cplan\STD_DEF.PAS}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, Global, StdCtrls, Buttons, ExtCtrls, Menus,
  Dll_u1, lbox;

type
  TFeatGridForm = class(TForm)
    FeatGrid: TStringGrid;
    FeatGridBox: TListBox;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    LocalClick: TRadioGroup;
    a: TButton;
    t: TButton;
    c: TButton;
    btnAccept: TButton;
    btnCopy: TButton;
    MainMenu1: TMainMenu;
    Report1: TMenuItem;
    Grid1: TMenuItem;
    SaveCSV: TSaveDialog;
    TmpBox: TListBox;
    SiteKeys: TListBox;
    btnAutoFit: TButton;
    SitesToDisplay: TListBox;
    SitesToDisplayKey: TListBox;
    btnSaveGrid: TButton;
    btnSummariseSites: TButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure FeatGridSelectCell(Sender: TObject; Col, Row: Longint;
      var CanSelect: Boolean);
    procedure LocalClickClick(Sender: TObject);
    procedure aClick(Sender: TObject);
    procedure cClick(Sender: TObject);
    procedure FeatGridBoxDblClick(Sender: TObject);
    procedure btnAcceptClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure Grid1Click(Sender: TObject);
    procedure Special1Click(Sender: TObject);
    procedure InvertSpecial1Click(Sender: TObject);
    procedure InvertAllFeatures1Click(Sender: TObject);
    procedure InheritCycleToggle;
    procedure DisplayGroupClick(Sender: TObject);
    procedure btnAutoFitClick(Sender: TObject);
    procedure DisplaySiteValues(iSiteKey : integer);
    procedure Beukers_ReportToFile(const sFilename : string;
                                   const iReportType : integer);
    procedure IrrepGrid1Click(Sender: TObject);
    procedure AreaGrid1Click(Sender: TObject);
    procedure PCAvTargGrid1Click(Sender: TObject);
    procedure InitialiseForm;
    procedure SitesToDisplayClick(Sender: TObject);
    procedure btnSaveGridClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSummariseSitesClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FeatGridForm: TFeatGridForm;
  fEnableSelection,
  fSingleSite : boolean;

procedure SaveStringGrid2CSV(AGrid : TStringGrid;
                             const sFile : string);


implementation

uses
    Dde_unit, Em_newu1, Sf_irrep, Contribu,
    Control, F1find,
    Pred_sf4, Toolmisc,
    Pred_sf3, ds,
    auto_fit, Lookup, opt1, summarise_sites,
    dbmisc;

{$R *.DFM}

procedure TFeatGridForm.Beukers_ReportToFile(const sFilename : string;
                                             const iReportType : integer);
var
   ReportFile : TextFile;
   iCount, iFeature, iSiteKey, iSiteIndex, iFeatureIndex : integer;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   Value : ValueFile_T;
   sValue : string;
   ClickValues : Array_t;
   rIrrep : extended;

   function FindFeatureAtSite : integer;
   var
      iIterate : integer;
   begin
        result := 0;
        if (pSite^.richness > 0) then
           for iIterate := 1 to pSite^.richness do
           begin
                FeatureAmount.rtnValue(pSite^.iOffset + iIterate,@Value);
                if (iFeature = Value.iFeatKey) then
                   result := iIterate;
           end;
   end;

begin
     try
        // for Max Beukers 28 Mar 2000
        //
        // Produce a site by feature matrix in comma delimited ascii format
        // Use site keys as row ids and feature names as column ids
        // SiteKeys contains the list of site keys
        // Use sites that have been posted to the multiple features form
        // Use features that are not currently restricted (turned off)
        new(pSite);
        new(pFeat);
        assignfile(ReportFile,sFilename);
        rewrite(ReportFile);

        write(ReportFile,'SiteKey');
        for iCount := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iCount,pFeat);
             if not pFeat^.fRestrict then
                write(ReportFile,',' + pFeat^.sID);
        end;
        writeln(ReportFile);

        for iCount := 0 to (SiteKeys.Items.Count-1) do
        begin
             iSiteKey := StrToInt(SiteKeys.Items.Strings[iCount]);
             iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
             SiteArr.rtnValue(iSiteIndex,pSite);

             if (iReportType = 0) then
                ClickValues := click_predict_sf4(iSiteIndex);

             write(ReportFile,IntToStr(iSiteKey));

             for iFeature := 1 to iFeatureCount do
             begin
                  FeatArr.rtnValue(iFeature,pFeat);
                  if not pFeat^.fRestrict then
                  begin
                       // find index of this feature at this site, 0 means not at this site
                       iFeatureIndex := FindFeatureAtSite;
                       if (iFeatureIndex = 0) then
                          // write zero value to file
                          sValue := '0'
                       else
                       begin
                            // write the sites feature value to file
                            FeatureAmount.rtnValue(pSite^.iOffset + iFeatureIndex,@Value);
                            case iReportType of
                                 0 : begin
                                          ClickValues.rtnValue(iFeatureIndex,@rIrrep);
                                          sValue := FloatToStr(rIrrep); // IRR
                                     end;
                                 1 : sValue := FloatToStr(Value.rAmount); // AREA
                                 2 : if (pFeat^.targetarea > 0) then
                                        sValue := FloatToStr(Value.rAmount / pFeat^.targetarea * 100)
                                     else
                                         sValue := '0'; // PCAVTARG
                            end;
                       end;

                       write(ReportFile,',' + sValue);
                  end;
             end;

             if (iReportType = 0) then
                ClickValues.Destroy;

             writeln(ReportFile);
        end;

        dispose(pSite);
        dispose(pFeat);
        closefile(ReportFile);

     except
     end;
end;

procedure TFeatGridForm.InheritCycleToggle;
begin
     LocalClick.Font := ControlForm.ClickGroup.Font;

     LocalClick.Height := ControlForm.ClickGroup.Height;
     LocalClick.Width := ControlForm.ClickGroup.Width;
     LocalClick.Caption := ControlForm.ClickGroup.Caption;

     //LocalClick.Left := btnAutoFit.Left + btnAutoFit.Width + btnAccept.Left;

     //LocalClick.Top := ControlForm.ClickGroup.Top;
end;

procedure SaveStringGrid2CSV(AGrid : TStringGrid;
                             const sFile : string);
var
   OutFile : Text;

   iCountRows,iCountCols : integer;

   fFilesOk : boolean;

begin
     fFilesOk := True;

     Assign(OutFile,sFile);

     try
        Rewrite(OutFile);

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not create output CSV file ' + sFile,
                            mtError,[mbOk],0);

                  fFilesOk := False;
            end;
     end;

     if fFilesOk then
     begin
          {now create the datafile}

          //writeln(OutFile,FeatGridForm.Caption);

          for iCountRows := 0 to (AGrid.RowCount-1) do
          begin
               for iCountCols := 0 to (AGrid.ColCount-2) do
                   write(OutFile,AGrid.Cells[iCountCols,iCountRows] + ',');
               writeln(OutFile,AGrid.Cells[AGrid.ColCount-1,iCountRows]);
          end;

          close(OutFile);
     end;
end;

function SlashToComma(sLine : string) : string;
var
   iCount : integer;
   fFound : boolean;
begin
     Result := sLine;
     fFound := False;

     if (Length(sLine)>0) then
     begin
        for iCount := 1 to Length(sLine) do
            if (sLine[iCount] = '\') then
            begin
               Result[iCount] := ',';
               fFound := True;
            end
     end;

     if not fFound then
        Result := ',,';
end;

procedure SaveSpecialStringGrid2CSV(AGrid : TStringGrid;
                             const sFile : string);
var
   OutFile : Text;

   iCountRows,iCountCols : integer;

   fFilesOk : boolean;

begin
     fFilesOk := True;

     Assign(OutFile,sFile);

     try
        Rewrite(OutFile);

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not create output CSV file ' + sFile,
                            mtError,[mbOk],0);

                  fFilesOk := False;
            end;
     end;

     if fFilesOk then
     begin
          {now create the datafile}
          for iCountRows := 0 to (AGrid.RowCount-1) do
          begin
               for iCountCols := 0 to (AGrid.ColCount-2) do
               begin
                    if (iCountCols > 0) then
                    begin
                         if (iCountRows > 1) then
                         begin
                              {extract Irrepl, Area and % to Target from cell
                               and write into adjacent matrix elements}
                              if (AGrid.Cells[iCountCols,iCountRows] = '') then
                                 write(OutFile,',,,')
                              else
                                  write(OutFile,SlashToComma(AGrid.Cells[iCountCols,iCountRows]) + ',');
                         end
                         else
                             write(OutFile,AGrid.Cells[iCountCols,iCountRows] + ',,,');
                    end
                    else
                        write(OutFile,AGrid.Cells[iCountCols,iCountRows] + ',');
               end;

               if (iCountRows > 1) then
               begin
                    {extract Irrepl, Area and % to Target from cell
                     and write into adjacent matrix elements}

                    writeln(OutFile,SlashToComma(AGrid.Cells[AGrid.ColCount-1,iCountRows]));
               end
               else
                   writeln(OutFile,AGrid.Cells[AGrid.ColCount-1,iCountRows] + ',,');
          end;

          close(OutFile);
     end;
end;

procedure SaveCust2Grid2CSV(AGrid : TStringGrid;
                            const sFile : string);
var
   OutFile : Text;

   iCountRows,iCountCols : integer;

   fFilesOk : boolean;

begin
     {$IFNDEF SPARSE_MATRIX_2}
     fFilesOk := True;

     Assign(OutFile,sFile);

     try
        Rewrite(OutFile);

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not create output CSV file ' + sFile,
                            mtError,[mbOk],0);

                  fFilesOk := False;
            end;
     end;

     if fFilesOk then
     begin
          {now create the datafile}

          write(OutFile,'Feature Name/Site Key,');

          {write site Geocodes as first row of output}
          for iCountRows := 2 to (AGrid.RowCount-1) do
              write(OutFile,IntToStr(FindSiteGeocode(AGrid.Cells[0,iCountRows])) + ',,,');

          writeln(OutFile);

          write(OutFile,'Site Name:,');

          {write site Names as second row of output}
          for iCountRows := 2 to (AGrid.RowCount-1) do
              write(OutFile,AGrid.Cells[0,iCountRows] + ',,,');

          writeln(OutFile);

          {now iterate rest of columns of AGrid progressively writing
           the columns as rows to the output file}
          for iCountCols := 1 to (AGrid.ColCount-1) do
          begin
               {iterate each column of the grid}

               {write the feature name as 1st element of output line}
               write(OutFile,AGrid.Cells[iCountCols,1] + ',');

               for iCountRows := 2 to (AGrid.RowCount-2) do
               begin
                    if (AGrid.Cells[iCountCols,iCountRows] = '') then
                       write(OutFile,',,,')
                    else
                        write(OutFile,SlashToComma(AGrid.Cells[iCountCols,iCountRows]) + ',');
               end;

               if (AGrid.Cells[iCountCols,AGrid.RowCount-1] = '') then
                  writeln(OutFile,',,')
               else
                   writeln(OutFile,SlashToComma(AGrid.Cells[iCountCols,AGrid.RowCount-1]));
          end;

          close(OutFile);
     end;
     {$ENDIF}
end;

procedure SaveCust3Grid2CSV(AGrid : TStringGrid;
                            const sFile : string);
var
   OutFile : Text;

   iGeocode, iSiteIndex, iCountRows, iCountCols, iFeatCount : integer;
   pSite : sitepointer;

   pFeat : featureoccurrencepointer;

   fFeatFound, fFilesOk : boolean;

begin
     fFilesOk := True;

     Assign(OutFile,sFile);

     try
        Rewrite(OutFile);

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not create output CSV file ' + sFile,
                            mtError,[mbOk],0);

                 fFilesOk := False;
            end;
     end;

     if fFilesOk then
     begin
          {now create the datafile}

          write(OutFile,'Feature Name/Site Key (displays Feature Irr\Amount\%ToTarget),');

          new(pSite);
          FeatGridForm.TmpBox.Items.Clear;
          {write site Geocodes as first row of output}
          for iCountRows := 2 to (AGrid.RowCount-1) do
          begin
               iGeocode := FindSiteGeocode(AGrid.Cells[0,iCountRows]);
               iSiteIndex := FindFeatMatch(OrdSiteArr,iGeocode);
               SiteArr.rtnValue(iSiteIndex,pSite);

               write(OutFile,IntToStr(iGeocode) + ',,,');

               FeatGridForm.TmpBox.Items.Add(FloatToStr(pSite^.rIrreplaceability));
          end;
          dispose(pSite);

          writeln(OutFile);

          write(OutFile,'Site Name:,');

          {write site Names as second row of output}
          for iCountRows := 2 to (AGrid.RowCount-1) do
              write(OutFile,AGrid.Cells[0,iCountRows] + ',,,');

          writeln(OutFile);

          write(OutFile,'Site Irreplaceability:,');
          for iCountRows := 0 to (FeatGridForm.TmpBox.Items.Count-1) do
              write(OutFile,FeatGridForm.TmpBox.Items.Strings[iCountRows] + ',,,');
          writeln(OutFile);
          FeatGridForm.TmpBox.Items.Clear;

          new(pFeat);

          for iFeatCount := 1 to iFeatureCount do
          begin
               FeatArr.rtnValue(iFeatCount,pFeat);
               fFeatFound := False;

               for iCountCols := 1 to (AGrid.ColCount-1) do
                   if (pFeat^.code = StrToInt(AGrid.Cells[iCountCols,0])) then
                   begin
                        fFeatFound := True;
                        {iterate each column of the grid}

                        {write the feature name as 1st element of output line}
                        write(OutFile,AGrid.Cells[iCountCols,1] + ',');

                        for iCountRows := 2 to (AGrid.RowCount-2) do
                        begin
                             if (AGrid.Cells[iCountCols,iCountRows] = '') then
                                write(OutFile,',,,')
                             else
                                 write(OutFile,SlashToComma(AGrid.Cells[iCountCols,iCountRows]) + ',');
                        end;

                        if (AGrid.Cells[iCountCols,AGrid.RowCount-1] = '') then
                           writeln(OutFile,',,')
                        else
                            writeln(OutFile,SlashToComma(AGrid.Cells[iCountCols,AGrid.RowCount-1]));
                   end;

               if not fFeatFound then
               begin
                    write(OutFile,pFeat^.sID + ',');
                    for iCountRows := 2 to (AGrid.RowCount-2) do
                        write(OutFile,',,,');
                    writeln(OutFile,',,');
               end;
          end;

          dispose(pFeat);
          close(OutFile);
     end;
end;

procedure TFeatGridForm.DisplaySiteValues(iSiteKey : integer);
var
   iSiteIndex, iFeatIndex, iCount : integer;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   fAvail, fPreReserve, fUnSorted : boolean;
   ClickValues : Array_t;
   rValue, rPercentInSite : extended;
   Value : ValueFile_T;
   sRepr, sPercentInSite, sTmp1, sTmp2, sTmp3, sTmp4, sValue : string;
begin
     try
        new(pSite);
        new(pFeat);

        iSiteIndex := FindFeatMatch(OrdSiteArr,iSiteKey);
        SiteArr.rtnValue(iSiteIndex,pSite);

        fPreReserve := False;
        if (pSite^.status = Re) then
        begin
             fPreReserve := True;
             fAvail := False;
        end
        else
        begin
             if (pSite^.status = _R1)
             or (pSite^.status = _R2)
             or (pSite^.status = _R3)
             or (pSite^.status = _R4)
             or (pSite^.status = _R5)
             or (pSite^.status = Pd) then
             begin
                  fAvail := False;
             end
             else
                 fAvail := True;
        end;

        FeatGrid.ColCount := 4;
        FeatGrid.RowCount := pSite^.richness+1;
        FeatGrid.FixedRows := 1;
        FeatGrid.FixedCols := 1;
        FeatGrid.Cells[0,0] := 'Feature';
        FeatGrid.Cells[1,0] := 'Irrepl.';
        FeatGrid.Cells[2,0] := 'Amount';
        FeatGrid.Cells[3,0] := '% of Avail. Target';

        Caption := 'Site ' + pSite^.sName +
                   ' - status ' + Status2Str(pSite^.status);

        LocalClick.Items := ControlForm.ClickGroup.Items;
        LocalClick.ItemIndex := ControlForm.ClickGroup.ItemIndex;

        ClickValues := click_predict_sf4(iSiteIndex);

        for iCount := 1 to pSite^.richness do
        begin
             {find necessary % to target for this feature}
             FeatureAmount.rtnValue(pSite^.iOffset + iCount,@Value);
             iFeatIndex := Value.iFeatKey;
             FeatArr.rtnValue(iFeatIndex,pFeat);

             FeatGrid.Cells[0,iCount] := pFeat^.sID;
             Str(Value.rAmount:6:2,sValue);

             ClickValues.rtnValue(iCount,@rValue);
             Str(rValue:6:3,sRepr);

             if fAvail then
             begin
                  if (pFeat^.targetarea > 0) then
                     rPercentInSite := Value.rAmount /
                                       pFeat^.targetarea * 100
                  else
                      rPercentInSite := 0;

                  Str(rPercentInSite:6:2,sPercentInSite);
             end
             else
             begin
                  if fPreReserve then
                     sPercentInSite := '0' // site is a pre-existing reserve, set to zero
                  else
                  begin
                       // we need to calculate the % to target if this site was un-reserved
                       if ((pFeat^.targetarea + Value.rAmount) > 0) then
                       begin
                            rPercentInSite := Value.rAmount /
                                              (pFeat^.targetarea + Value.rAmount) * 100;
                            Str(rPercentInSite:6:2,sPercentInSite);
                       end
                       else
                           sPercentInSite := '0';
                  end;
             end;
             TrimLeadSpaces(sPercentInSite);
             if (sPercentInSite = '0.00') then
                sPercentInSite := '0';

             FeatGrid.Cells[1,iCount] := sRepr;
             FeatGrid.Cells[2,iCount] := sValue;
             FeatGrid.Cells[3,iCount] := sPercentInSite;
        end;

        ClickValues.Destroy;

        {now sort the rows by the irr_feature column}
        fUnSorted := True;
        with FeatGrid do
        while fUnSorted do
        begin
             fUnSorted := False;

             if (Cells[1,1] <> '-') then
                for iCount := 1 to (RowCount-2) do
                    if (RegionSafeStrToFloat(Cells[1,iCount]) <
                        RegionSafeStrToFloat(Cells[1,iCount+1])) then
                    begin
                         {swap them}
                         sTmp1 := Cells[0,iCount];
                         sTmp2 := Cells[1,iCount];
                         sTmp3 := Cells[2,iCount];
                         sTmp4 := Cells[3,iCount];

                         Cells[0,iCount] := Cells[0,iCount+1];
                         Cells[1,iCount] := Cells[1,iCount+1];
                         Cells[2,iCount] := Cells[2,iCount+1];
                         Cells[3,iCount] := Cells[3,iCount+1];

                         Cells[0,iCount+1] := sTmp1;
                         Cells[1,iCount+1] := sTmp2;
                         Cells[2,iCount+1] := sTmp3;
                         Cells[3,iCount+1] := sTmp4;

                         fUnSorted := True;
                    end;
        end;

        dispose(pSite);
        dispose(pFeat);

     except
     end;
end;

procedure TFeatGridForm.InitialiseForm;
var
   iFeatIndex, iCount, iCount2, iSiteIndex, iCol, iAlreadyInList : integer;
   pFeat : featureoccurrencepointer;
   ClickValues : Array_t;
   rValue : extended;
   rPercentInSite : extended;
   sRepr, sPercentInSite, sTmp1, sTmp2, sTmp3, sTmp4, sValue : string;
   fUnSorted, fAvail : boolean;
   iFCustIdx : integer;
   pSite : sitepointer;
   Value : ValueFile_T;

   procedure ListControlSites(ASiteName,ASiteKey:TListBox);
   var
      iCount : integer;
   begin
        if (ASiteName.SelCount > 0) then
           for iCount := 0 to (ASiteName.Items.Count-1) do
               if ASiteName.Selected[iCount] then
               begin
                    SitesToDisplay.Items.Add(ASiteName.Items.Strings[iCount]);
                    SitesToDisplayKey.Items.Add(ASiteKey.Items.Strings[iCount]);
               end;
   end;

begin
     new(pSite);
     new(pFeat);

     InheritCycleToggle;

     SiteKeys.Items.Clear;
     FeatGridBox.Items.Clear;

     SitesToDisplay.Width := 121;

     // list all the selected site names in SitesToDisplay
     // list all the selected site keys in SitesToDisplayKey
     SitesToDisplay.Items.Clear;
     SitesToDisplayKey.Items.Clear;
     iAlreadyInList := SitesToDisplay.Items.Count;
     ListControlSites(ControlForm.Available,ControlForm.AvailableKey);
     ListControlSites(ControlForm.Flagged,ControlForm.FlaggedKey);
     ListControlSites(ControlForm.R1,ControlForm.R1Key);
     ListControlSites(ControlForm.R2,ControlForm.R2Key);
     ListControlSites(ControlForm.R3,ControlForm.R3Key);
     ListControlSites(ControlForm.R4,ControlForm.R4Key);
     ListControlSites(ControlForm.R5,ControlForm.R5Key);
     ListControlSites(ControlForm.Partial,ControlForm.PartialKey);
     ListControlSites(ControlForm.Excluded,ControlForm.ExcludedKey);
     ListControlSites(ControlForm.Reserved,ControlForm.ReservedKey);
     ListControlSites(ControlForm.Ignored,ControlForm.IgnoredKey);

     Grid1.Visible := False;

     // de-select all selected items
     for iCount := 0 to (SitesToDisplay.Items.Count-1) do
         SitesToDisplay.Selected[iCount] := False;
     // display info about the first site added
     DisplaySiteValues(StrToInt(SitesToDisplayKey.Items.Strings[iAlreadyInList]));
     // select the first site added
     SitesToDisplay.Selected[iAlreadyInList] := True;

     dispose(pSite);
     dispose(pFeat);

     fEnableSelection := not LookupForm.Visible;

     if not fEnableSelection then
     begin
          // if this form is being launched from the lookup form,
          // disable the Accept button and selection controls
          // and the double click action of the form
          btnAccept.Visible := False;
          LocalClick.Visible := False;
          btnAutoFit.Left := btnAccept.Left;
     end;
end;

procedure TFeatGridForm.BitBtn1Click(Sender: TObject);
begin
     Visible := False;
     // empty the list of sites
     SitesToDisplay.Items.Clear;
     SitesToDisplayKey.Items.Clear;

end;

procedure TFeatGridForm.FeatGridSelectCell(Sender: TObject; Col,
  Row: Longint; var CanSelect: Boolean);
begin
     FeatGrid.ShowHint := True;
     FeatGrid.Hint := FeatGrid.Cells[Col,Row];
end;

procedure TFeatGridForm.LocalClickClick(Sender: TObject);
begin
     ControlForm.ClickGroup.ItemIndex := LocalClick.ItemIndex;
end;

procedure TFeatGridForm.aClick(Sender: TObject);
begin
     ControlForm.btnAcceptClick(self);
end;

procedure TFeatGridForm.cClick(Sender: TObject);
begin
     if (LocalClick.ItemIndex = LocalClick.Items.Count-1) then
        LocalClick.ItemIndex := 0
     else
         LocalClick.ItemIndex := LocalClick.ItemIndex + 1;
end;

procedure TFeatGridForm.FeatGridBoxDblClick(Sender: TObject);
var
   iCount : integer;
begin
     if fEnableSelection then
     try
        if (FeatGridBox.Items.Count > 3)
        and (FeatGridBox.SelCount >= 1) then
            for iCount := 3 to (FeatGridBox.Items.Count-1) do
                if FeatGridBox.Selected[iCount] then
                   UseGISKey(StrToInt(
                       FeatGrid.Cells[0,iCount]),
                                     TRUE);

     except
           Screen.Cursor := crDefault;
           MessageDlg('exception in BoxDblClick',
                      mtError,[mbOK],0);
     end;
end;

procedure TFeatGridForm.btnAcceptClick(Sender: TObject);
var
   iCount, iUserSites, iUserSite : integer;
   UserSites : Array_t;
begin
     try
        UserSites := Array_t.Create;
        UserSites.init(SizeOf(integer),ARR_STEP_SIZE);
        iUserSites := 0;

        // Build a list of user selected sites
        for iCount := 0 to (SitesToDisplay.Items.Count-1) do
        begin
             if (SitesToDisplay.Selected[iCount]) then
             begin
                  Inc(iUserSites);
                  if (iUserSites > UserSites.lMaxSize) then
                     UserSites.resize(UserSites.lMaxSize + ARR_STEP_SIZE);
                  iUserSite := StrToInt(SitesToDisplayKey.Items.Strings[iCount]);
                  UserSites.setValue(iUserSites,@iUserSite);
             end;
        end;

        if (iUserSites > 0) then
        begin
             if (iUserSites <> UserSites.lMaxSize) then
                UserSites.resize(iUserSites);
             UseGISKeys(UserSites);
        end;
        UserSites.Destroy;
        
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in btnAcceptClick',mtError,[mbOk],0);
     end;
end;

procedure TFeatGridForm.btnCopyClick(Sender: TObject);
begin
     CopySGrid2Clip(FeatGrid);
end;

function ForceFileExtF(sFile : string) : string;
var
   iFirstPos,iLastPos : integer;
   sExt : string;
begin
     // trim the existing file extension
     sExt := ExtractFileExt(sFile);

     if (sExt <> '') then
        Result := Copy(sFile,1,Length(sFile) - Length(sExt))
     else
         Result := sFile;

     // trim the existing _F if it exists
     if (Length(Result) > 2) then
        if (Copy(Result,Length(Result) - 1,2) = '_F') then
           Result := Copy(Result,1,Length(Result) - 2);

     // build new filename
     Result := Result + '_F.CSV';
end;

procedure TFeatGridForm.Grid1Click(Sender: TObject);
var
   sFilename : string;
begin
     SaveCSV.InitialDir := ControlRes^.sWorkingDirectory;
     SaveCSV.Filename := 'SAMPLE_F.CSV';

     if SaveCSV.Execute then
     begin
          sFilename := ForceFileExtF(SaveCSV.Filename);

          if FileExists(sFilename) then
          begin
               if (mrYes = MessageDlg('File ' + sFilename + ' exists.  Overwrite?',
                   mtConfirmation,[mbOk,mbCancel],0)) then
                  SaveStringGrid2CSV(FeatGrid,sFilename);
          end
          else
              SaveStringGrid2CSV(FeatGrid,sFilename);
     end;
end;

procedure TFeatGridForm.Special1Click(Sender: TObject);
var
   sFilename : string;
begin
     SaveCSV.InitialDir := ControlRes^.sWorkingDirectory;
     SaveCSV.Filename := 'SAMPLE_F.CSV';

     if SaveCSV.Execute then
     begin
          sFilename := ForceFileExtF(SaveCSV.Filename);

          if FileExists(sFilename) then
          begin
               if (mrOk = MessageDlg('File ' + sFilename + ' exists.  Overwrite?',
                   mtConfirmation,[mbOk,mbCancel],0)) then
                  SaveSpecialStringGrid2CSV(FeatGrid,sFilename);
          end
          else
              SaveSpecialStringGrid2CSV(FeatGrid,sFilename);
     end;
end;

procedure TFeatGridForm.InvertSpecial1Click(Sender: TObject);
var
   sFilename : string;
begin
     SaveCSV.InitialDir := ControlRes^.sWorkingDirectory;
     SaveCSV.Filename := 'SAMPLE_F.CSV';

     if SaveCSV.Execute then
     begin
          sFilename := ForceFileExtF(SaveCSV.Filename);

          if FileExists(sFilename) then
          begin
               if (mrOk = MessageDlg('File ' + sFilename + ' exists.  Overwrite?',
                   mtConfirmation,[mbOk,mbCancel],0)) then
                  SaveCust2Grid2CSV(FeatGrid,sFilename);
          end
          else
              SaveCust2Grid2CSV(FeatGrid,sFilename);
     end;
end;

procedure TFeatGridForm.InvertAllFeatures1Click(Sender: TObject);
var
   sFilename : string;
begin
     SaveCSV.InitialDir := ControlRes^.sWorkingDirectory;
     SaveCSV.Filename := 'SAMPLE_F.CSV';

     if SaveCSV.Execute then
     begin
          sFilename := ForceFileExtF(SaveCSV.Filename);

          if FileExists(sFilename) then
          begin
               if (mrOk = MessageDlg('File ' + sFilename + ' exists.  Overwrite?',
                   mtConfirmation,[mbOk,mbCancel],0)) then
                  SaveCust3Grid2CSV(FeatGrid,sFilename);
          end
          else
              SaveCust3Grid2CSV(FeatGrid,sFilename);
     end;
end;

procedure TFeatGridForm.DisplayGroupClick(Sender: TObject);
begin
     FormShow(self);
end;

procedure TFeatGridForm.btnAutoFitClick(Sender: TObject);
begin
     AutoFitGrid(FeatGrid,
                 Canvas,
                 True {fit entire grid});
end;

procedure TFeatGridForm.IrrepGrid1Click(Sender: TObject);
begin
     SaveCSV.InitialDir := ControlRes^.sWorkingDirectory;

     if SaveCSV.Execute then
     begin
          if FileExists(SaveCSV.Filename) then
          begin
               if (mrYes = MessageDlg('File ' + SaveCSV.Filename + ' exists.  Overwrite?',
                   mtConfirmation,[mbOk,mbCancel],0)) then
                  FeatGridForm.Beukers_ReportToFile(SaveCSV.Filename,0);
          end
          else
              FeatGridForm.Beukers_ReportToFile(SaveCSV.Filename,0);
     end;        
end;

procedure TFeatGridForm.AreaGrid1Click(Sender: TObject);
begin
     SaveCSV.InitialDir := ControlRes^.sWorkingDirectory;

     if SaveCSV.Execute then
     begin
          if FileExists(SaveCSV.Filename) then
          begin
               if (mrYes = MessageDlg('File ' + SaveCSV.Filename + ' exists.  Overwrite?',
                   mtConfirmation,[mbOk,mbCancel],0)) then
                  FeatGridForm.Beukers_ReportToFile(SaveCSV.Filename,1);
          end
          else
              FeatGridForm.Beukers_ReportToFile(SaveCSV.Filename,1);
     end;
end;

procedure TFeatGridForm.PCAvTargGrid1Click(Sender: TObject);
begin
     SaveCSV.InitialDir := ControlRes^.sWorkingDirectory;

     if SaveCSV.Execute then
     begin
          if FileExists(SaveCSV.Filename) then
          begin
               if (mrYes = MessageDlg('File ' + SaveCSV.Filename + ' exists.  Overwrite?',
                   mtConfirmation,[mbOk,mbCancel],0)) then
                  FeatGridForm.Beukers_ReportToFile(SaveCSV.Filename,2);
          end
          else
              FeatGridForm.Beukers_ReportToFile(SaveCSV.Filename,2);
     end;
end;

procedure TFeatGridForm.SitesToDisplayClick(Sender: TObject);
var
   iCount : integer;
begin
     for iCount := 0 to (SitesToDisplay.Items.Count-1) do
         if SitesToDisplay.Selected[iCount] then
            DisplaySiteValues(StrToInt(SitesToDisplayKey.Items.Strings[iCount]));
end;

procedure TFeatGridForm.btnSaveGridClick(Sender: TObject);
begin
     SaveCSV.InitialDir := ControlRes^.sWorkingDirectory;
     if SaveCSV.Execute then
        SaveStringGrid2CSV(FeatGrid,SaveCSV.Filename);
end;

procedure TFeatGridForm.FormShow(Sender: TObject);
begin
     InitialiseForm;
     with FeatGrid do
     begin
          DefaultColWidth := (ClientWidth -
                              ((ColCount+1) * GridLineWidth))
                             div ColCount;

          if DefaultColWidth < MIN_GRID_WIDTH then
             DefaultColWidth := MIN_GRID_WIDTH;
     end;
end;

procedure TFeatGridForm.btnSummariseSitesClick(Sender: TObject);
begin
     // bring up a form that summarises the feature attributes for all selected sites
     SummariseSitesForm := TSummariseSitesForm.Create(Application);
     SummariseSitesForm.ShowModal;
     SummariseSitesForm.Free;
end;

procedure TFeatGridForm.FormHide(Sender: TObject);
begin
     Visible := False;
     // empty the list of sites
     SitesToDisplay.Items.Clear;
     SitesToDisplayKey.Items.Clear;

end;

end.
