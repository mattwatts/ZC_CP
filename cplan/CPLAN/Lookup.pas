unit Lookup;

{$I STD_DEF.PAS}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, Grids, Clipbrd,
  Global,
  {$IFDEF bit16}
  Arrayt16, Cpng_imp;
  {$ELSE}
  ds, Arr2lbox;
  {$ENDIF}


type
  TLookupForm = class(TForm)
    TopPanel: TPanel;
    btnOK: TBitBtn;
    LookupGrid: TStringGrid;
    btnCopy: TButton;
    LookupFont: TFontDialog;
    btnFields: TButton;
    VisibleCodes: TListBox;
    btnAccept: TButton;
    c: TButton;
    t: TButton;
    LocalClick: TRadioGroup;
    btnAutoFit: TButton;
    btnSave: TButton;
    SaveCSV: TSaveDialog;
    procedure btnCopyClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnAcceptClick(Sender: TObject);
    procedure LocalClickClick(Sender: TObject);
    procedure cClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure InheritCycleToggle;
    procedure DBMSFieldChange;
    procedure ChangeCycleToggle;
    procedure FormShow(Sender: TObject);
    procedure btnAutoFitClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure GenerateLookupDebugReports;
    procedure LookupGridSelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    procedure btnFieldsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LookupForm: TLookupForm;

  iLGGridCols, iLGCharSize, iLGNumCharsWide,
  iLGGridFieldLen,
  iXPos, iYPos : integer;

  fFirstLookup : boolean;

procedure LookupOn;
procedure LookupOff;
{called by Control to start and end unit with ControlForm}

procedure StartLookupArr(const Arr : Array_t);
function IsCodeVisible(const sGeocode : string) : boolean;

procedure CopyGridSelectionToClipboard(const AGrid : TStringGrid);

implementation

uses
    Control, Em_newu1, Contribu, Featrepd, Dde_unit,
    Sf_irrep, Sct_grid, Toolmisc, Featgrid,
    Auto_fit;

{$R *.DFM}


procedure TLookupForm.GenerateLookupDebugReports;
var
   sStub : string;
begin
     if ControlRes^.fDebugLookup then
     try
        sStub := ControlRes^.sWorkingDirectory +
                 '\' +
                 IntToStr(ControlRes^.iLookupDebugReports) +
                 '_';

        // write the contents of VisibleCodes to a file
        VisibleCodes.Items.SaveToFile(sStub + 'KEYS.CSV');

        // write the contents of LookupGrid to a file
        SaveStringGrid2CSV(LookupGrid,sStub + 'GRID.CSV');

        // increment the lookup debug counter
        Inc(ControlRes^.iLookupDebugReports);

     except

     end;
end;

procedure TLookupForm.InheritCycleToggle;
begin
     LocalClick.Font := ControlForm.ClickGroup.Font;

     LocalClick.Left := btnFields.Left + btnFields.Width + btnAccept.Left;

     LocalClick.Height := ControlForm.ClickGroup.Height;
     LocalClick.Width := ControlForm.ClickGroup.Width;
     LocalClick.Caption := ControlForm.ClickGroup.Caption;

     LocalClick.Top := ControlForm.ClickGroup.Top;
end;

procedure StartLookupArr(const Arr : Array_t);
var
   iCount, iField, iOldCursor, iAddCount, iPreviousRowCount,
   iGeocode, iInsert : integer;
   sGeocode, sDB, sSLbl : MyShortString;
   fStop : boolean;
begin
     try
        if (ControlForm.LookupDisplayList.Items.Count > 0) then
        begin
             LookupForm.Visible := True;
             LookupForm.BringToFront;

             try
                iOldCursor := Screen.Cursor;

                Screen.Cursor := crDefault;
                if not fContrDataDone then
                   if (mrYes = MessageDlg('Site status has changed.  Recalculate values?',
                       mtConfirmation,[mbYes,mbNo],0)) then
                   begin
                        Screen.Cursor := crHourglass;
                        ExecuteIrreplaceability(-1,False,False,True,True,'');
                   end;

             finally
                    Screen.Cursor := iOldCursor;
             end;

             try
                fStop := False;
                ControlForm.OutTable.Open;

             except on exception do
                    begin
                         Screen.Cursor := crDefault;
                         MessageDlg('StartLookupArr cannot open ' + ControlForm.OutTable.DatabaseName +
                         '\' + ControlForm.OutTable.TableName,mtInformation,[mbOk],0);

                         fStop := True;
                    end;
             end;

             if not fStop then
             begin
                  LookupForm.LookupGrid.ColCount := ControlForm.LookupDisplayList.Items.Count + 1;
                  LookupForm.LookupGrid.Cells[0,0] := 'Select';
                  
                  if (LookupForm.LookupGrid.RowCount = 1) then
                     for iCount := 0 to (ControlForm.LookupDisplayList.Items.Count-1) do
                     begin
                          if (ControlForm.LookupDisplayList.Items[iCount] = 'SUBSEMR') then
                             LookupForm.LookupGrid.Cells[iCount+1,0] := 'Irrepl.'
                          else
                          if (ControlForm.LookupDisplayList.Items[iCount] = 'PCUSED') then
                             LookupForm.LookupGrid.Cells[iCount+1,0] := '% Contrib.'
                          else
                              LookupForm.LookupGrid.Cells[iCount+1,0] := ControlForm.LookupDisplayList.Items[iCount];
                     end;
                  {if there are no sites in grid, write field names into first row of matrix}

                  if (Arr.lMaxSize > 0) then
                  begin
                       iAddCount := 0;
                       for iCount := 1 to Arr.lMaxSize do
                       begin
                            Arr.rtnValue(iCount,@iGeocode);
                            sGeocode := IntToStr(iGeocode);
                            if not IsCodeVisible(sGeocode) then
                               Inc(iAddCount);
                       end;

                       if (iAddCount > 0) then
                       begin
                            {shuffle elements down by iAddCount elements}
                            iPreviousRowCount := LookupForm.LookupGrid.RowCount;
                            LookupForm.LookupGrid.RowCount := LookupForm.LookupGrid.RowCount + iAddCount;
                            {if (iPreviousRowCount > 1) then
                               for iCount := (LookupForm.LookupGrid.RowCount-iAddCount-1) downto 1 do
                                   LookupForm.LookupGrid.Rows[iCount+iAddCount] := LookupForm.LookupGrid.Rows[iCount];
                            }
                            iInsert := 0;

                            while not ControlForm.OutTable.EOF do
                            begin
                                 sDB := ControlForm.OutTable.FieldByName(ControlRes^.sKeyField).AsString;

                                 for iCount := 1 to Arr.lMaxSize do
                                 begin
                                      Arr.rtnValue(iCount,@iGeocode);
                                      sGeocode := IntToStr(iGeocode);

                                      if (sGeocode = sDB) then
                                         if not IsCodeVisible(sGeocode) then
                                         begin
                                              {add this site to VisibleCodes and LookupGrid}
                                              LookupForm.VisibleCodes.Items.Add(sDB);
                                              Inc(iInsert);

                                              {display relevant fields for this site}
                                              for iField := 0 to (ControlForm.LookupDisplayList.Items.Count-1) do
                                                  LookupForm.LookupGrid.Cells[iField+1,iPreviousRowCount-1+iCount] :=
                                                    ControlForm.OutTable.FieldByName(
                                                      ControlForm.LookupDisplayList.Items[iField]).AsString;
                                         end;
                                 end;

                                 ControlForm.OutTable.Next;
                            end;

                            if (LookupForm.LookupGrid.RowCount > 1) then
                               LookupForm.LookupGrid.FixedRows := 1;
                       end;
                  end;

                  ControlForm.OutTable.Close;

                  if ((LookupForm.LookupGrid.RowCount-1) = 1) then
                     sSLbl := 'site'
                  else
                      sSLbl := 'sites';

                  LookupForm.Caption := 'Lookup (' +
                                        IntToStr(LookupForm.LookupGrid.RowCount-1) +
                                        ' ' + sSLbl + ')';
             end;
        end
        else
        begin
             Screen.Cursor := crDefault;
             MessageDlg('You must select 1 or more DBMS fields to activate lookup',
                        mtInformation,[mbOk],0);
        end;

        Arr.Destroy;

        // generate debug list for this set of sites if we are in debug mode
        LookupForm.GenerateLookupDebugReports;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception looking up sites',mtError,[mbOk],0);
     end;
end;

function IsCodeVisible(const sGeocode : string) : boolean;
{says if this site is already displayed in DBMS grid}
var
   iCount : integer;
begin
     Result := False;

     with LookupForm do
     begin
          if (LookupGrid.RowCount > 1)
          and (VisibleCodes.Items.Count > 0) then
              for iCount := 0 to (VisibleCodes.Items.Count-1) do
                  if (VisibleCodes.Items.Strings[iCount] = sGeocode) then
                     Result := True;
     end;
end;

procedure LookupOn;
begin
     {start the DBMS lookup form but leave it hidden}
     LookupForm := TLookupForm.Create(Application);
end;

procedure LookupOff;
begin
     {dispose of the DBMS lookup form}
     LookupForm.Free;
end;

procedure TLookupForm.btnCopyClick(Sender: TObject);
begin
     CopyGridSelectionToClipboard(LookupGrid);
end;

procedure CopyGridSelectionToClipboard(const AGrid : TStringGrid);
var
   pStart : PChar;
   iRowCount, iColumnCount, iCharCount, iDataSize, iCurrChar : integer;
begin
     {copy any highlighted fields as text to the clipboard}
     if (AGrid.RowCount > 1) then
     begin
          iDataSize := 0;

          {find the size of data block to create}
          // add the size of the Field Names for the selected column(s)
          for iColumnCount := AGrid.Selection.Left to AGrid.Selection.Right do
              Inc(iDataSize,Length(AGrid.Cells[iColumnCount,0])+1); // add room for comma or carriage return if last cell in row
          Inc(iDataSize,1); // add room for line feed

          // add the size of each selected cell in the selected column(s) and row(s)
          for iRowCount := AGrid.Selection.Top to AGrid.Selection.Bottom do
          begin
               for iColumnCount := AGrid.Selection.Left to AGrid.Selection.Right do
                   Inc(iDataSize,Length(AGrid.Cells[iColumnCount,iRowCount])+1);
               Inc(iDataSize,1);
          end;

          Inc(iDataSize,1); {make 1 space for the null character}

          pStart := StrAlloc(iDataSize);

          iCurrChar := 0;
          {create null terminated string list}
          // add the field names for the selected columns
          for iColumnCount := AGrid.Selection.Left to AGrid.Selection.Right do
          begin
               for iCharCount := 1 to Length(AGrid.Cells[iColumnCount,0]) do
               begin
                    pStart[iCurrChar] := AGrid.Cells[iColumnCount,0][iCharCount];
                    Inc(iCurrChar);
               end;
               // add a comma as a cell seperator between cells within a row
               if (iColumnCount <> AGrid.Selection.Right) then
               begin
                    pStart[iCurrChar] := ',';
                    Inc(iCurrChar);
               end
               else
               // add an end of line marker to the last cell in the row
               begin
                    pStart[iCurrChar] := Chr(13); {add CR}
                    Inc(iCurrChar);
                    pStart[iCurrChar] := Chr(10); {add LF}
                    Inc(iCurrChar);
               end;
          end;
          // add the cell values for the selected column(s) and row(s)
          for iRowCount := AGrid.Selection.Top to AGrid.Selection.Bottom do
              for iColumnCount := AGrid.Selection.Left to AGrid.Selection.Right do
              begin
                   for iCharCount := 1 to Length(AGrid.Cells[iColumnCount,iRowCount]) do
                   begin
                        pStart[iCurrChar] := AGrid.Cells[iColumnCount,iRowCount][iCharCount];
                        Inc(iCurrChar);
                   end;
                   // add a comma as a cell seperator between cells within a row
                   if (iColumnCount <> AGrid.Selection.Right) then
                   begin
                        pStart[iCurrChar] := ',';
                        Inc(iCurrChar);
                   end
                   else
                   // add an end of line marker to the last cell in the row
                   begin
                        pStart[iCurrChar] := Chr(13); {add CR}
                        Inc(iCurrChar);
                        pStart[iCurrChar] := Chr(10); {add LF}
                        Inc(iCurrChar);
                   end;
              end;

          pStart[iCurrChar] := #0; {add null character to terminate PChar}

          Clipboard.SetTextBuf(pStart);
     end;
end;

procedure TLookupForm.btnOKClick(Sender: TObject);
begin
     {user has clicked OK. clear all sites from the grid and hide it}

     Visible := False;
     LookupGrid.RowCount := 1;
     VisibleCodes.Items.Clear;
     iLastCodeGrabbed := -1;
end;

procedure TLookupForm.FormActivate(Sender: TObject);
var
   wOldCursor : integer;
begin
     LocalClick.Items := ControlForm.ClickGroup.Items;

     LocalClick.ItemIndex := ControlForm.ClickGroup.ItemIndex;

     InheritCycleToggle;
end;

procedure TLookupForm.btnAcceptClick(Sender: TObject);
var
   iUserSites, iUserSite, iCount : integer;
   fAcceptSite : boolean;
   UserSites : Array_t;
begin
     fAcceptSite := False;

     if (LocalClick.Items[LocalClick.ItemIndex] <> 'Lookup') then
     begin
          // Build an array of selected sites and pass to UseGISKeys
          UserSites := Array_t.Create;
          UserSites.init(SizeOf(integer),ARR_STEP_SIZE);
          iUserSites := 0;

          //for iCount := 1 to (LookupBox.Items.Count-1) do
          //    if LookupBox.Selected[iCount] then
          if (LookupGrid.RowCount > 1) then
             // for iCount := LookupGrid.Selection.Top to LookupGrid.Selection.Bottom do
             for iCount := 1 to (LookupGrid.RowCount-1) do  
                 if (LookupGrid.Cells[0,iCount] <> '') then
                 begin
                      if (LocalClick.Items[LocalClick.ItemIndex] <> 'Features') then
                         fAcceptSite := True;

                      inc(iUserSites);
                      if (iUserSites > UserSites.lMaxSize) then
                         UserSites.resize(UserSites.lMaxSize + ARR_STEP_SIZE);
                      iUserSite := StrToInt(VisibleCodes.Items.Strings[iCount-1]);
                      UserSites.setValue(iUserSites,@iUserSite);
                 end;

          // Pass the array to UseGISKeys
          if (iUserSites > 0) then
          begin
               if (iUserSites <> UserSites.lMaxSize) then
                  UserSites.resize(iUserSites);
               UseGISKeys(UserSites);
          end;
          UserSites.Destroy;
     end;

     if fAcceptSite then
     begin
          {recalculate and redisplay results}
          if (VisibleCodes.Items.Count > 0) then
          begin
               {VisibleCodes contains }

               Listbox2IntArr(VisibleCodes,UserSites);

               Visible := False;
               LookupGrid.RowCount := 1;
               VisibleCodes.Items.Clear;
               iLastCodeGrabbed := -1;

               StartLookupArr(UserSites);
          end;
     end;
end;

procedure TLookupForm.ChangeCycleToggle;
begin
     if Visible then
     begin
          LocalClick.ItemIndex := ControlForm.ClickGroup.ItemIndex;
     end;
end;

procedure TLookupForm.DBMSFieldChange;
var
   UserSites : Array_t;
begin
     {DBMS fields have been edited, redraw then Lookup}

     if Visible
     and (VisibleCodes.Items.Count > 0) then
     begin
          Listbox2IntArr(VisibleCodes,UserSites);

          Visible := False;
          LookupGrid.RowCount := 1;
          VisibleCodes.Items.Clear;
          iLastCodeGrabbed := -1;

          StartLookupArr(UserSites);

          {UserSites.Destroy;}
     end;
end;

procedure TLookupForm.LocalClickClick(Sender: TObject);
begin
     ControlForm.ClickGroup.ItemIndex := LocalClick.ItemIndex;
     ControlForm.ClickGroupClick(self);
end;

procedure TLookupForm.cClick(Sender: TObject);
begin
     if (LocalClick.ItemIndex = LocalClick.Items.Count-1) then
        LocalClick.ItemIndex := 0
     else
         LocalClick.ItemIndex := LocalClick.ItemIndex + 1;
     LocalClickClick(self);
end;

procedure TLookupForm.FormCreate(Sender: TObject);
begin
     fFirstLookup := True;
     btnOk.Font := ControlForm.Font;
     btnCopy.Font := ControlForm.Font;
     btnAccept.Font := ControlForm.Font;
     btnAutoFit.Font := ControlForm.Font;
     btnSave.Font := ControlForm.Font;
     btnFields.Font := ControlForm.Font;
end;

procedure TLookupForm.FormShow(Sender: TObject);
begin
     if ControlRes^.fSizeLookup then
     begin
          LookupForm.Top := ControlRes^.iLookupTop;
          LookupForm.Left := ControlRes^.iLookupLeft;
          LookupForm.Height := ControlRes^.iLookupHeight;
          LookupForm.Width := ControlRes^.iLookupWidth;

          ControlRes^.fSizeLookup := False;
     end;
end;

procedure TLookupForm.btnAutoFitClick(Sender: TObject);
begin
     AutoFitGrid(LookupGrid,
                 Canvas,
                 True {fit entire grid});
end;


procedure TLookupForm.btnSaveClick(Sender: TObject);
begin
     SaveCSV.InitialDir := ControlRes^.sWorkingDirectory;
     SaveCSV.FileName := 'sample.csv';
 
     if SaveCSV.Execute then
     begin
          if FileExists(SaveCSV.Filename) then
          begin
               if (mrYes = MessageDlg('File ' + SaveCSV.Filename + ' exists.  Overwrite?',
                                      mtConfirmation,[mbYes,mbNo],0)) then
                  {save F1Grid to SaveCSV.Filename}
                  SaveStringGrid2CSV(LookupGrid,SaveCSV.Filename);
          end
          else
              SaveStringGrid2CSV(LookupGrid,SaveCSV.Filename);
     end;
end;

procedure TLookupForm.LookupGridSelectCell(Sender: TObject; Col,
  Row: Integer; var CanSelect: Boolean);
begin
     if (Col = 0)
     and (Row > 0) then
         if (LookupGrid.Cells[Col,Row] = '') then
            LookupGrid.Cells[Col,Row] := 'Select'
         else
             LookupGrid.Cells[Col,Row] := '';
end;

procedure TLookupForm.btnFieldsClick(Sender: TObject);
begin
     ControlForm.DBMSFields1Click(Sender);
end;

end.
