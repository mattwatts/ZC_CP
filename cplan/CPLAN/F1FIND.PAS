unit F1find;

{$I STD_DEF.PAS}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, Grids, Spin;

type
  TFeaturesToTargetForm = class(TForm)
    Panel1: TPanel;
    F1FindBox: TListBox;
    btnFindSites: TButton;
    BitBtn1: TBitBtn;
    F1Grid: TStringGrid;
    btnCopy: TButton;
    btnShow: TButton;
    Label1: TLabel;
    lblPercent: TLabel;
    btnSave: TButton;
    SaveCSV: TSaveDialog;
    GroupBox1: TGroupBox;
    CheckMaskLess: TCheckBox;
    SpinLess: TSpinEdit;
    Label2: TLabel;
    GroupBox2: TGroupBox;
    CheckMaskGreater: TCheckBox;
    SpinGreater: TSpinEdit;
    Label3: TLabel;
    SortGroup: TRadioGroup;
    DisplayList: TListBox;
    FindFeature: TFindDialog;
    btnFind: TButton;
    SortField: TRadioGroup;
    procedure btnFindSitesClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure btnShowClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure SpinGreaterChange(Sender: TObject);
    procedure CheckMaskGreaterClick(Sender: TObject);
    procedure SpinLessChange(Sender: TObject);
    procedure CheckMaskLessClick(Sender: TObject);
    procedure SortGroupClick(Sender: TObject);
    procedure btnFindClick(Sender: TObject);
    procedure FindFeatureFind(Sender: TObject);
    procedure SearchForFeature(const fDown,fMatchCase,fWholeWord : boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FeaturesToTargetForm: TFeaturesToTargetForm;

  iF1GridCols, iF1CharSize, iF1NumCharsWide,
  iF1GridFieldLen, iPercentWidth : integer;

  iPreviousStartingPoint : integer;

procedure FindAvailableSitesClick;
procedure ShowDeferredClick;

implementation

uses
    Control, Em_newu1, Sct_grid, Contribu,
    S1find, Partl_ed, Global, Clipbrd,
    Defrqry, S2Show, Toolmisc, Randtest,
    Sf_irrep, Imptools,
  {$IFDEF bit16}
  Arrayt16, Cpng_imp;
  {$ELSE}
  ds, lbox;
  {$ENDIF}

{$R *.DFM}

procedure TFeaturesToTargetForm.SearchForFeature(const fDown,fMatchCase,fWholeWord : boolean);
var
   iMatchFound, iStartingPoint, iCount : integer;
   fRemember, fAlreadySelected,
   fFound : boolean;
   //InitialSelections : Array_t;

   function DoesThisMatch(const sStringToMatch : string) : boolean;
   var
      sAdjustedMatch,           // what we are searching for
      sAdjustedString : string; // what we are searching in
   begin
        Result := False;

        if fMatchCase then
        begin
             sAdjustedString := sStringToMatch;
             sAdjustedMatch := FindFeature.FindText;
        end
        else
        begin
             sAdjustedString := LowerCase(sStringToMatch);
             sAdjustedMatch := LowerCase(FindFeature.FindText);
        end;

        if fWholeWord then
        begin
             if (sAdjustedMatch = sAdjustedString) then
             begin
                  Result := True;
                  iMatchFound := iCount;
             end;
        end
        else
        begin
             if (Pos(sAdjustedMatch,sAdjustedString) > 0) then
             begin
                  Result := True;
                  iMatchFound := iCount;
             end;
        end;
   end;

begin
     // search for a feature using the user settings
     try
        // start searching from the selected feature
        // if more than 1 feature is selected, use the 1st selected feature
        if (iPreviousStartingPoint > 0) then
           iStartingPoint := iPreviousStartingPoint
        else
        begin
             iStartingPoint := -1;
             for iCount := (F1FindBox.Items.Count-1) downto 0 do
                 if F1FindBox.Selected[iCount] then
                    iStartingPoint := iCount;
             if (iStartingPoint = -1) then
             begin
                  if fDown then
                     iStartingPoint := 0
                  else
                      iStartingPoint := F1FindBox.Items.Count-1;
             end;
        end;

        fFound := False;

        // advance in direction indicated until either 1) end of list is reached
        //                                          or 2) search criteria has been found
        iCount := iStartingPoint;
        if fDown then
        begin
             // search downwards
             repeat
                   fFound := DoesThisMatch(F1FindBox.Items.Strings[iCount]);
                   Inc(iCount);

             until (iCount >= F1FindBox.Items.Count)
             or fFound;
        end
        else
        begin
             // search upwards
             repeat
                   fFound := DoesThisMatch(F1FindBox.Items.Strings[iCount]);
                   Dec(iCount);

             until (iCount < 0)
             or fFound;
        end;

        // select the feature that has been found OR tell user end of list has been reached
        if fFound then
        begin
             // advance listbox to past item we are selecting by
             // selecting then de-selecting the next element in list
             if (iMatchFound < (F1FindBox.Items.Count-1)) then
             begin // if item we are selecting is not the last item in list
                  fRemember := F1FindBox.Selected[iMatchFound+1];
                  F1FindBox.Selected[iMatchFound+1] := True;
                  F1FindBox.Selected[iMatchFound+1] := fRemember;
             end;
             // remember if this feature is already selected before we select it
             fAlreadySelected := F1FindBox.Selected[iMatchFound];
             // select the feature we have just found
             F1FindBox.Selected[iMatchFound] := True;
             if not fAlreadySelected then // if this feature was not already part of the selection
             begin
                  if (mrNo = MessageDlg('Add this feature to the selection?',mtConfirmation,[mbYes,mbNo],0)) then
                     F1FindBox.Selected[iMatchFound] := False;
                  if fDown then
                     iPreviousStartingPoint := iMatchFound + 1
                  else
                      iPreviousStartingPoint := iMatchFound - 1;
             end;
        end
        else
        begin
             MessageDlg('Searched to end of list and match not found',mtInformation,[mbOk],0);
             if fDown then
                iPreviousStartingPoint := 0
             else
                 iPreviousStartingPoint := F1FindBox.Items.Count - 1;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TF1FindForm.SearchForFeature',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TFeaturesToTargetForm.FormResize(Sender: TObject);
var
   sALine : string;
   iCount, iLessValue, iGreaterValue : integer;
   rValue : extended;
   fMask : boolean;
begin
     try
        F1FindBox.Items.Clear;

        try
           iF1NumCharsWide := ClientWidth div iF1CharSize;
           {iF1GridFieldLen := (iF1NumCharsWide div iF1GridCols) - 1;}
           iF1GridFieldLen := iF1NumCharsWide - (iPercentWidth + 3);

           lblPercent.Left := Panel1.Width - lblPercent.Width - 4 {iF1CharSize * (iF1GridFieldLen + 2)};
        except;
        end;
        Screen.Cursor := crHourglass;

        {empty the display list}
        DisplayList.Items.Clear;
        iLessValue := SpinLess.Value;
        iGreaterValue := SpinGreater.Value;

        if (F1Grid.RowCount > 1) then
           for iCount := 1 to (F1Grid.RowCount-1) do
           begin
                rValue := RegionSafeStrToFloat(F1Grid.Cells[1,iCount]);
                fMask := False;
                if CheckMaskLess.Checked then
                   {check this value is > SpinLess.Value}
                   if (rValue > iLessValue) then
                      fMask := True;

                if CheckMaskGreater.Checked then
                   {check this value is < SpinGreater.Value}
                   if (rValue < iGreaterValue) then
                      fMask := True;

                if (not fMask) then
                begin
                     {display this feature if its % to C.E.T is within our range of values}

                     {add the geocode of this site to the display list}
                     DisplayList.Items.Add(F1Grid.Cells[2,iCount]);

                     sALine := BuildField(F1Grid.Cells[0,iCount],iF1GridFieldLen) + ' ' +
                               F1Grid.Cells[1,iCount];

                     F1FindBox.Items.Add(sALine);
                end;
           end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('exception in TF1FindForm.FormResize',
                      mtError,[mbOK],0);
     end;

     Screen.Cursor := crDefault;
end;

procedure TFeaturesToTargetForm.btnFindSitesClick(Sender: TObject);
begin
     FindAvailableSitesClick;

     if not fContrDataDone then
     begin
          if (mrYes = MessageDlg('Recalculate and redisplay selections',
                                 mtConfirmation,[mbYes,mbNo],0)) then
          begin
               ExecuteIrreplaceability(-1,False,False,True,True,'');
               FormCreate(self);
               FormResize(self);
          end;
     end;
end;

procedure FindAvailableSitesClick;
var
   iFeatCode,iCount,iCurrFeat,iNumSelected : integer;
begin
     with FeaturesToTargetForm do
     try
        Screen.Cursor := crHourglass;

        iNumSelected := F1FindBox.SelCount;

        if (iNumSelected > 0) then
        begin
             FGridList := Array_t.Create;
             FGridList.init(SizeOf(iFeatCode),iNumSelected);
             iCurrFeat := 0;
             for iCount := 0 to (F1FindBox.Items.Count-1) do
                 if F1FindBox.Selected[iCount] then
                 begin
                      Inc(iCurrFeat);
                      iFeatCode := StrToInt(DisplayList.Items.Strings[iCount]);
                      FGridList.setValue(iCurrFeat,@iFeatCode);
                 end;

             Visible := False;

             AvailableSitesForm := TAvailableSitesForm.Create(Application);
             AvailableSitesForm.ShowModal;
             AvailableSitesForm.Free;

             FGridList.Destroy;

             Visible := True;
        end
        else
        begin
             Screen.Cursor := crDefault;
             MessageDlg('Highlight 1 or more features to activate this function',
                        mtInformation,[mbOk],0);
        end;



     except
           Screen.Cursor := crDefault;
           MessageDlg('exception in btnFindSitesClick',
                      mtError,[mbOK],0);
     end;

     Screen.Cursor := crDefault;
end;

procedure TFeaturesToTargetForm.BitBtn1Click(Sender: TObject);
begin
     ModalResult := mrOK;
end;

procedure TFeaturesToTargetForm.FormCreate(Sender: TObject);
var
   sPercent{, sPercentTrimmed} : string;
   rThisPC, rExclusionAdjustedTarget : extended;
   iCount : integer;
   AFeat : featureoccurrence;
begin
     {if ControlRes^.fPersistF2Targ then
       LoadFormState(F1FindForm,ControlRes^.sDatabase + '\' + PERSIST_F2TARG_FILE);}

     try
        Width := SortField.Left + SortField.Width + 20;

        iPreviousStartingPoint := -1;

        Caption := 'Features To Target';

        BitBtn1.Font := ControlForm.Font;
        btnShow.Font := ControlForm.Font;
        btnCopy.Font := ControlForm.Font;
        btnFindSites.Font := ControlForm.Font;
        btnSave.Font := ControlForm.Font;
        btnFind.Font := ControlForm.Font;

        Screen.Cursor := crHourglass;
        iF1GridCols := 2;
        iF1CharSize := Canvas.TextWidth(' ');

        {find width of Percent column}
        iPercentWidth := Length(lblPercent.Caption);

        iF1NumCharsWide := ClientWidth div iF1CharSize;
        {iF1GridFieldLen := (iF1NumCharsWide div iF1GridCols) - 1;}

        F1Grid.RowCount := 1;
        F1Grid.ColCount := iF1GridCols + 1;

        F1Grid.Cells[0,0] := 'Name';
        F1Grid.Cells[1,0] := 'Percent of Initial Achievable Target Satisfied';
        {F1Grid.Cells[2,0] := 'Percent to Trimmed Target';}
        F1Grid.Cells[2,0] := 'Code';

        for iCount := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iCount,@AFeat);

             if (AFeat.rTrimmedTarget = 0) then
             begin
                  {}
             end
             else
             begin
                  F1Grid.RowCount := F1Grid.RowCount + 1;

                  rExclusionAdjustedTarget := AFeat.targetarea + AFeat.rDeferredArea + AFeat.reservedarea;
                  //if (AFeat.rTrimmedTarget > (AFeat.rDeferredArea + AFeat.reservedarea + AFeat.rSumArea)) then
                  //   rExclusionAdjustedTarget := AFeat.rDeferredArea + AFeat.reservedarea;

                  rThisPC := ((AFeat.rDeferredArea + AFeat.reservedarea) /
                              rExclusionAdjustedTarget) * 100;

                  //Str(rThisPC:6:2,sPercent);
                  sPercent := FloatToStr(rThisPC);

                  F1Grid.Cells[0,F1Grid.RowCount-1] := AFeat.sID;
                  F1Grid.Cells[1,F1Grid.RowCount-1] := sPercent;
                  {F1Grid.Cells[2,F1Grid.RowCount-1] :=}
                  F1Grid.Cells[2,F1Grid.RowCount-1] := IntToStr(AFeat.code);

                  if (Length(sPercent) > iPercentWidth) then
                     iPercentWidth := Length(sPercent);
             end;
        end;

        iF1GridFieldLen := iF1NumCharsWide - (iPercentWidth + 3);

        SortGrid(F1Grid,1,1,SORT_TYPE_REAL,SortGroup.ItemIndex);

     except
           Screen.Cursor := crDefault;
           MessageDlg('exception in TF1FindForm.FormCreate',
                      mtError,[mbOK],0);
     end;

     Screen.Cursor := crDefault;
end;


procedure TFeaturesToTargetForm.btnCopyClick(Sender: TObject);
begin
     CopyLBox2Clip(F1FindBox);
end;

procedure TFeaturesToTargetForm.btnShowClick(Sender: TObject);
begin
     ShowDeferredClick;

     if not fContrDataDone then
     begin
          if (mrYes = MessageDlg('Recalculate and redisplay selections',
                                 mtConfirmation,[mbYes,mbNo],0)) then
          begin
               ExecuteIrreplaceability(-1,False,False,True,True,'');
               FormCreate(self);
               FormResize(self);
          end;
     end;
end;

procedure ShowDeferredClick;
var
   OurFeatures : Array_T;
   iFeatCode,iCount,iCurrFeat,iNumSelected : integer;
begin
     with FeaturesToTargetForm do
     try
        Screen.Cursor := crHourglass;

        iNumSelected := F1FindBox.SelCount;

        if (iNumSelected > 0) then
        begin
             OurFeatures := Array_t.Create;
             OurFeatures.init(SizeOf(iFeatCode),iNumSelected);
             iCurrFeat := 0;
             for iCount := 0 to (F1FindBox.Items.Count-1) do
                 if F1FindBox.Selected[iCount] then
                 begin
                      Inc(iCurrFeat);
                      {iFeatCode := StrToInt(ExtractCodeRight(F1FindBox.Items.Strings[iCount],
                                           iF1GridFieldLen));}
                      iFeatCode := StrToInt(DisplayList.Items.Strings[iCount]);
                      OurFeatures.setValue(iCurrFeat,@iFeatCode);
                 end;

             Visible := False;

             {now call WhyImpFeat with OurFeatures}
             ShowWhyImpFeat(OurFeatures);

             Visible := True;
        end
        else
        begin
             Screen.Cursor := crDefault;
             MessageDlg('Highlight 1 or more features to activate this function',
                        mtInformation,[mbOk],0);
        end;


     except
           Screen.Cursor := crDefault;
           MessageDlg('exception in btnShowClick',
                      mtError,[mbOK],0);
     end;

     Screen.Cursor := crDefault;
end;

procedure TFeaturesToTargetForm.btnSaveClick(Sender: TObject);
begin
     if (SaveCSV.FileName = '') then
     begin
          SaveCSV.InitialDir := ControlRes^.sWorkingDirectory;
          SaveCSV.FileName := 'sample.csv';
     end;

     if SaveCSV.Execute then
     begin
          if FileExists(SaveCSV.Filename) then
          begin
               if (mrYes = MessageDlg('File ' + SaveCSV.Filename + ' exists.  Overwrite?',
                                      mtConfirmation,[mbYes,mbNo],0)) then
                  {save F1Grid to SaveCSV.Filename}
                  SaveStringGrid2CSV(F1Grid,SaveCSV.Filename);
          end
          else
              SaveStringGrid2CSV(F1Grid,SaveCSV.Filename);
     end;
end;

procedure TFeaturesToTargetForm.SpinGreaterChange(Sender: TObject);
var
   iValue : integer;
   fNoValue : boolean;
begin
     try
        fNoValue := False;
        iValue := SpinGreater.Value;

     except on EConvertError do
               fNoValue := True;
     end;

     if (not fNoValue) then
     begin
          CheckMaskGreater.Checked := True;
          FormResize(self);
     end;
end;

procedure TFeaturesToTargetForm.CheckMaskGreaterClick(Sender: TObject);
begin
     FormResize(self);
end;

procedure TFeaturesToTargetForm.SpinLessChange(Sender: TObject);
var
   iValue : integer;
begin
     try
        iValue := SpinLess.Value;
        CheckMaskLess.Checked := True;
        FormResize(self);
     except
     end;
end;

procedure TFeaturesToTargetForm.CheckMaskLessClick(Sender: TObject);
begin
     FormResize(self);
end;

procedure TFeaturesToTargetForm.SortGroupClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        case SortField.ItemIndex of
             0 : SortGrid(F1Grid,1,0,SORT_TYPE_STRING,SortGroup.ItemIndex);
             1 : SortGrid(F1Grid,1,1,SORT_TYPE_REAL,SortGroup.ItemIndex);
        end;
        FormResize(self);
        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
     end;
end;

procedure TFeaturesToTargetForm.btnFindClick(Sender: TObject);
begin
     FindFeature.Execute;
end;

procedure TFeaturesToTargetForm.FindFeatureFind(Sender: TObject);
var
   fDown, fMatchCase, fWholeWord : boolean;
begin
     try
        Screen.Cursor := crHourglass;

        // do the search specified by the user
        // get user settings for direction, case sensitivity and whole word sensitivity
        if (FindFeature.Options*[frDown])=[frDown] then
           fDown := True
        else
            fDown := False;
        if (FindFeature.Options*[frMatchCase])=[frMatchCase] then
           fMatchCase := True
        else
            fMatchCase := False;
        if (FindFeature.Options*[frWholeWord])=[frWholeWord] then
           fWholeWord := True
        else
            fWholeWord := False;
        // search for features using these settings
        SearchForFeature(fDown,fMatchCase,fWholeWord);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TF1FindForm.FindFeatureFind',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

end.
