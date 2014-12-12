unit Resttarg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls,
  {$IFDEF VER90}
  Dll_u1, Menus;
  {$ELSE}
  Cpng_imp;
  {$ENDIF}

type
  TRestTargForm = class(TForm)
    Panel1: TPanel;
    TargBox: TListBox;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    TargID: TListBox;
    FeatBox: TListBox;
    OpenAsc: TOpenDialog;
    SaveAsc: TSaveDialog;
    btnReset: TButton;
    CheckResetCombsize: TCheckBox;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    LoadFeatureList1: TMenuItem;
    SaveFeatureList1: TMenuItem;
    Action1: TMenuItem;
    UseAll1: TMenuItem;
    RestoreOriginalSettings1: TMenuItem;
    UseHighlightedFeatures1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LoadFeatureList1Click(Sender: TObject);
    procedure SaveFeatureList1Click(Sender: TObject);
    procedure Usethislist1Click(Sender: TObject);
    procedure UseAll1Click(Sender: TObject);
    procedure RestoreOriginalSettings1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RestTargForm: TRestTargForm;
  {fCheckResetCombSize : boolean;}

implementation

uses
    Em_newu1, Control, Contribu, Sf_irrep, Global, Reinit,
    OrdClass;

{$R *.DFM}


procedure TRestTargForm.FormCreate(Sender: TObject);
var
   iFeatIdx, iFCode : integer;
   pFeat : featureoccurrencepointer;
   fFail, fStop : boolean;
begin
     ClientWidth := (2 * CheckResetCombsize.Left) + CheckResetCombsize.Width;

     try
        Screen.Cursor := crHourglass;

        fFail := False;
        ControlForm.CutOffTable.Open;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Cannot find feature cut-offs table',mtError,[mbOK],0);
           fFail := True;
     end;

     TargBox.Items.Clear;
     TargID.Items.Clear;

     new(pFeat);

     fStop := False;

     if not fFail then
        repeat
              iFCode := ControlForm.CutOffTable.FieldByName(ControlRes^.sFeatureKeyField).AsInteger;
              iFeatIdx := iFCode;

              if (iFeatIdx <> -1) then
              begin
                   FeatArr.rtnValue(iFeatIdx,pFeat);
                   if (iFCode = pFeat^.code) then
                   begin
                        TargBox.Items.Add(pFeat^.sID);
                        TargID.Items.Add(IntToStr(iFeatIdx));

                        {if this feature is not restricted, highlight it}
                        if not pFeat^.fRestrict then
                        begin
                             TargBox.Selected[TargBox.Items.Count-1] := True;
                        end;
                   end;
              end;

              ControlForm.CutOffTable.Next;

              if ControlForm.CutOffTable.EOF then
                 fStop := TRUE;

        until fStop;

     dispose(pFeat);

     ControlForm.CutOffTable.Close;

     Screen.Cursor := crDefault;
end;

procedure TRestTargForm.btnOKClick(Sender: TObject);
var
   iCount, iFeatIdx : integer;
   AFeat : featureoccurrence;
   fRetainClass : boolean;
   sRetainClass : string;
begin
     Screen.Cursor := crHourglass;

     fContrDataDone := False;

     fRetainClass := ControlRes^.fFeatureClassesApplied;
     sRetainClass := ControlRes^.sFeatureClassField;

     {first, set all features to be not restricted}
     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,@AFeat);
          AFeat.fRestrict := False;
          FeatArr.setValue(iCount,@AFeat);
     end;

     if (TargBox.SelCount > 0) then
     begin
          {restrict all feature targets except the ones highlighted}
          for iCount := 0 to (TargBox.Items.Count-1) do
              if not TargBox.Selected[iCount] then
              begin
                   iFeatIdx := StrToInt(TargID.Items.Strings[iCount]);

                   FeatArr.rtnValue(iFeatIdx,@AFeat);
                   AFeat.fRestrict := True;
                   FeatArr.setValue(iFeatIdx,@AFeat);
              end;

          Screen.Cursor := crHourglass;
          ReInitializeInitialValues(TargetChange);
          if fRetainClass then
          begin
               LoadOrdinalClass(sRetainClass,ControlRes^.ClassDetail);
               ControlRes^.fFeatureClassesApplied := True;
               ControlRes^.sFeatureClassField := sRetainClass;
          end;
          ExecuteIrreplaceability(-1,False,False,True,True,'');

          Screen.Cursor := crDefault;
     end
     else
     begin
          Screen.Cursor := crDefault;
          Screen.Cursor := crHourglass;
          RePrepIrrepData;
          ReInitializeInitialValues(TargetChange);
          if fRetainClass then
          begin
               LoadOrdinalClass(sRetainClass,ControLRes^.ClassDetail);
               ControlRes^.fFeatureClassesApplied := True;
               ControlRes^.sFeatureClassField := sRetainClass;
          end;
          ExecuteIrreplaceability(-1,False,False,True,True,'');

          Screen.Cursor := crDefault;
     end;

     ModalResult := mrOK;
end;

procedure TRestTargForm.btnCancelClick(Sender: TObject);
begin
     ModalResult := mrOK;
end;

function IsEmptySpace(sLine:string):boolean;
var
   iCount : integer;
begin
     Result := True;

     if (Length(sLine) > 0) then
        for iCount := 1 to Length(sLine) do
            if (sLine[iCount] <> ' ') then
               Result := False;
end;

procedure TrimEmptySpace(ABox:TListBox);
var
   iCount : integer;
begin

     if (ABox.Items.Count > 0) then
     begin
          iCount := ABox.Items.Count - 1;

          repeat
                if IsEmptySpace(ABox.Items.Strings[iCount]) then
                   ABox.Items.Delete(iCount);

                Dec(iCount);

          until iCount < 0;

     end;
end;

procedure TRestTargForm.btnResetClick(Sender: TObject);
begin
     if (TargBox.SelCount = 0) then
        {MessageDlg('There are no highlighted features to Reset',
                   mtInformation,[mbOk],0)}
     else
         UnHighlight(TargBox,fKeepHighlight);

     btnOKClick(self);
end;

procedure TRestTargForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
     {fCheckResetCombSize := CheckResetCombsize.Checked;}
end;

procedure TRestTargForm.LoadFeatureList1Click(Sender: TObject);
var
   iCount, iCountTest, iNotFound : integer;
   fFound : boolean;
   sMsg : string;
begin
     OpenAsc.InitialDir := ControlRes^.sWorkingDirectory;
     OpenAsc.Filename := '*.TGT';

     if OpenAsc.Execute
     and FileExists(OpenAsc.Filename) then
     begin
          FeatBox.Items.Clear;
          FeatBox.Items.LoadFromFile(OpenAsc.Filename);
          UnHighlight(TargBox,fKeepHighlight);
          TrimEmptySpace(TargBox);
          iNotFound := 0;

          if (FeatBox.Items.Count > 0) then
             for iCount := 0 to (FeatBox.Items.Count-1) do
             begin
                  fFound := False;

                  for iCountTest := 0 to (TargBox.Items.Count-1) do
                      if (FeatBox.Items.Strings[iCount] = TargBox.Items.Strings[iCountTest]) then
                      begin
                           TargBox.Selected[iCountTest] := True;
                           fFound := True;
                      end;

                  if not fFound then
                     Inc(iNotFound);
             end;

          FeatBox.Items.Clear;

          if (iNotFound = 0) then
             sMsg := 'All Features from Input file found'
          else
              if (iNotFound = 1) then
                 sMsg := '1 Feature from Input file not found'
              else
                  sMsg := IntToStr(iNotFound) + ' Features from Input file not found';

          MessageDlg(sMsg,mtInformation,[mbOk],0);
     end;
end;

procedure TRestTargForm.SaveFeatureList1Click(Sender: TObject);
var
   iCount : integer;
   fStop : boolean;
begin
     SaveAsc.InitialDir := ControlRes^.sWorkingDirectory;
     SaveAsc.Filename := '*.TGT';

     if SaveAsc.Execute then
     begin
          FeatBox.Items.Clear;
          if (TargBox.SelCount > 0) then
             for iCount := 0 to (TargBox.Items.Count-1) do
                 if TargBox.Selected[iCount] then
                    FeatBox.Items.Add(TargBox.Items.Strings[iCount]);

          FeatBox.Items.SaveToFile(SaveAsc.Filename);
     end;
end;

procedure TRestTargForm.Usethislist1Click(Sender: TObject);
begin
     btnOKClick(self);
end;

procedure TRestTargForm.UseAll1Click(Sender: TObject);
begin
     btnResetClick(self);
end;

procedure TRestTargForm.RestoreOriginalSettings1Click(Sender: TObject);
begin
     ModalResult := mrOK;
end;

procedure TRestTargForm.FormActivate(Sender: TObject);
begin
     RestTargForm.CheckResetCombsize.Visible := ControlRes^.fShowExtraTools;
     if ControlRes^.fShowExtraTools then
        Panel1.Height := CheckResetCombsize.Top + CheckResetCombsize.Height + btnOk.Top
     else
         Panel1.Height := btnOk.Height + (2 * btnOk.Top);
end;

end.
