unit Featrepd;

{$I STD_DEF.PAS}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Grids,
  {$IFDEF bit16}
  Arrayt16;
  {$ELSE}
  ds;
  {$ENDIF}

type
  TFeatRepdForm = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    FeatRepdGrid: TStringGrid;
    Button1: TButton;
    btnFind: TButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FeatRepdGridDblClick(Sender: TObject);
    procedure FeatRepdGridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure btnFindClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FeatRepdForm: TFeatRepdForm;


procedure Grid2Clipboard(const AGrid : TStringGrid);


implementation

uses
    Em_newu1, Control, Contribu, Clipbrd, Contsite,
    S1find, Global, Toolmisc;

{$R *.DFM}

procedure TFeatRepdForm.BitBtn1Click(Sender: TObject);
begin
     ModalResult := mrOK;
end;

procedure TFeatRepdForm.FormCreate(Sender: TObject);
var
   iCount : integer;
   {AFeatLocal : featureoccurrencesubset_T;}
   AFeat : featureoccurrence;
   rThisPC : real;

   wOldCursor : integer;
   fUnSorted : boolean;

   sTmp1, sTmp2, sTmp3 : string; {sort strings}

begin
     {shows a list of features to target}

     {load features and percentages to FeatRepdGrid}
     wOldCursor := Screen.Cursor;
     Screen.Cursor := crHourglass;

     try
     with FeatRepdGrid do
     begin
          RowCount := 1;
          ColCount := 3;
          DefaultColWidth := (ClientWidth -
                              ((ColCount+1) * GridLineWidth))
                             div ColCount;
          if DefaultColWidth < MIN_GRID_WIDTH then
             DefaultColWidth := MIN_GRID_WIDTH;

          Cells[0,0] := 'Name';
          Cells[1,0] := 'Code';
          Cells[2,0] := 'Percent';
          for iCount := 1 to iFeatureCount{LocalFeatures.lMaxSize} do
          begin
               {LocalFeatures.rtnValue(iCount,@AFeatLocal);}
               FeatArr.rtnValue(iCount,@AFeat);

               if (AFeat.rTrimmedTarget = 0) then
               begin
                    {this feature is not able to be contributed to,
                     it has no occurrence in available sites}
               end
               else
               begin
                    RowCount := RowCount + 1;

                    {AFeatLocal.reservedarea is man and sel sites
                     AFeat.reservedarea is existing reserved sites}

                    if (AFeat.rTrimmedTarget > 0) then
                       rThisPC := ((AFeat.rDeferredArea + AFeat.reservedarea) /
                                   AFeat.rTrimmedTarget) * 100
                    else
                        rThisPC := 0;

                    Cells[0,RowCount-1] := AFeat.sID;
                    Cells[1,RowCount-1] := IntToStr(AFeat.code);
                    Str(rThisPC:8:1,sTmp1);
                    Cells[2,RowCount-1] := sTmp1;
               end;
          end;

          {now sort the rows by the percent column}
          fUnSorted := True;
          while fUnSorted do
          begin
               fUnSorted := False;

               for iCount := 1 to (RowCount-2) do
                   if ( StrToFloat( Cells[2,iCount] )
                        < StrToFloat( Cells[2,iCount+1] ) ) then
                   begin
                        {swap them}
                        sTmp1 := Cells[2,iCount];
                        sTmp2 := Cells[1,iCount];
                        sTmp3 := Cells[0,iCount];

                        Cells[2,iCount] := Cells[2,iCount+1];
                        Cells[1,iCount] := Cells[1,iCount+1];
                        Cells[0,iCount] := Cells[0,iCount+1];

                        Cells[2,iCount+1] := sTmp1;
                        Cells[1,iCount+1] := sTmp2;
                        Cells[0,iCount+1] := sTmp3;

                        fUnSorted := True;
                   end;
          end;
     end;
     finally
            Screen.Cursor := wOldCursor;
     end;
end;

procedure TFeatRepdForm.FormResize(Sender: TObject);
begin
     with FeatRepdGrid do
     begin
          DefaultColWidth := (ClientWidth -
                              ((ColCount+1) * GridLineWidth))
                             div ColCount;
          if DefaultColWidth < MIN_GRID_WIDTH then
             DefaultColWidth := MIN_GRID_WIDTH;
     end;
end;

procedure TFeatRepdForm.Button1Click(Sender: TObject);
begin
     Grid2Clipboard(FeatRepdGrid);
end;

procedure Grid2Clipboard(const AGrid : TStringGrid);
var
   pStart : pointer;
   pMoving : PChar;
   iCount, iCount2, iDataSize : integer;

   SRect : TGridRect;
begin
     {copy any highlighted fields as text to the clipboard}

     try

     iDataSize := 0;

     SRect := AGrid.Selection;

     {find the size of data block to create}
     for iCount := SRect.Left to SRect.Right do
         for iCount2 := SRect.Top to SRect.Bottom do
            Inc(iDataSize,Length(AGrid.Cells[iCount2,iCount])+2);
     GetMem(pMoving,iDataSize);
     pStart := @pMoving;
     {create null terminated string list}
     for iCount := SRect.Top to SRect.Bottom do
     begin
          for iCount2 := SRect.Left to SRect.Right do
          begin
               StrPCopy(pMoving,AGrid.Cells[iCount2,iCount] + '  ');
               pMoving := pMoving + Length(AGrid.Cells[iCount2,iCount]) + 2;
          end;
          pMoving := pMoving - 2;
          StrPCopy(pMoving,Chr(13) + Chr(10));
          pMoving := pMoving + 2;
     end;
     pMoving := pMoving - 2;
     pMoving := #0;

     Clipboard.SetTextBuf(pStart);
     {FreeMem(pStart,iDataSize);
     GlobalUnlock(hData);
     GlobalFree(hData);}

     except
           MessageDlg('Exception in Grid2Clipboard',mtError,[mbOK],0);
     end;
end;

procedure TFeatRepdForm.FeatRepdGridDblClick(Sender: TObject);
var
   iRowClicked, iFeatCode : integer;
   wOldCursor : integer;
begin
     {lookup sites with this feature and order them from highest
      contrib to this feat to lowest contrib}

     try
     wOldCursor := Screen.Cursor;
     Screen.Cursor := crHourglass;

     {find which row is highlighted}
     iRowClicked := FeatRepdGrid.Selection.Top;

     if (iRowClicked > 0) then
     begin
          iFeatCode := StrToInt(FeatRepdGrid.Cells[1,iRowClicked]);
          FindContributingSites(iFeatCode);
     end;
     except on exception do
               MessageDlg('Exception in FeatRepdGridDblClick',mtError,[mbOK],0);
     end;

     Screen.Cursor := wOldCursor;
end;

procedure TFeatRepdForm.FeatRepdGridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
     if (FeatRepdGrid.Selection.Top <
         FeatRepdGrid.Selection.Bottom) then
        btnFind.Enabled := True
     else
         btnFind.Enabled := False;
end;

procedure TFeatRepdForm.btnFindClick(Sender: TObject);
var
   iCount, iNumFeat, iLow, iHigh, iFCode : integer;
begin
     {build a feature list of highlighted features}
     {pass this list to SiteFeatGrid to search and display}

     iLow := FeatRepdGrid.Selection.Top;
     if (iLow > 0) then
     begin
          iHigh := FeatRepdGrid.Selection.Bottom;
          iNumFeat := iHigh - iLow + 1;

          FGridList := Array_t.Create;
          FGridList.init(SizeOf(iFCode),iNumFeat);

          for iCount := iLow to iHigh do
          begin
               iFCode := StrToInt(FeatRepdGrid.Cells[1,iCount]);
               FGridList.setValue(iCount-iLow+1,@iFCode);
          end;

          Visible := False;

          AvailableSitesForm := TAvailableSitesForm.Create(Application);
          AvailableSitesForm.ShowModal;
          AvailableSitesForm.Free;
          Visible := True;

          FGridList.Destroy;
     end;
end;

end.

