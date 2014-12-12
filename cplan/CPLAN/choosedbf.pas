unit choosedbf;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
    SubsetField_first_T = record
            fIrr,
            fSum,
            fSum_A,
            fSum_T,
            fSum_V,
            fSum_AT,
            fSum_AV,
            fSum_TV,
            fSum_ATV : boolean;
                       end;
    SubsetField_second_T = record
            fWav,
            fPC : boolean;
                      end;
    SubsetField_T = record
            _first : array [1..10] of SubsetField_first_T;
            _second : array [1..5] of SubsetField_second_T;
                    end;

type
  TChooseFieldsForm = class(TForm)
    Label1: TLabel;
    ComboSubset: TComboBox;
    GroupChoice: TGroupBox;
    CheckIrr: TCheckBox;
    CheckSum: TCheckBox;
    CheckWav: TCheckBox;
    CheckPC: TCheckBox;
    CheckSum_T: TCheckBox;
    CheckSum_V: TCheckBox;
    CheckSum_AT: TCheckBox;
    CheckSum_AV: TCheckBox;
    CheckSum_A: TCheckBox;
    CheckSum_TV: TCheckBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CheckSum_ATV: TCheckBox;
    ListSubsets: TListBox;
    btnDeSelectAll: TButton;
    procedure ChooseUserFields;
    procedure DisplayChoices(const iChoice : integer);
    procedure RefreshChoices;
    procedure ComboSubsetChange(Sender: TObject);
    procedure CheckIrrClick(Sender: TObject);
    procedure CheckSumClick(Sender: TObject);
    procedure CheckWavClick(Sender: TObject);
    procedure CheckPCClick(Sender: TObject);
    procedure CheckSum_AClick(Sender: TObject);
    procedure CheckSum_TClick(Sender: TObject);
    procedure CheckSum_VClick(Sender: TObject);
    procedure CheckSum_ATClick(Sender: TObject);
    procedure CheckSum_AVClick(Sender: TObject);
    procedure CheckSum_TVClick(Sender: TObject);
    procedure CheckSum_ATVClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListSubsetsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure InitSubsetsInUse;
    procedure btnDeSelectAllClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ChooseFieldsForm: TChooseFieldsForm;
  NewUserSubsetChoices, UserSubsetChoices : SubsetField_T;
  fCheckClickAction : boolean;
  iUserSubset : integer;

procedure ResetUserSubsetChoices;
procedure EditUserSubsetChoices;

implementation

{$R *.DFM}

uses
    Control;

procedure ResetUserSubsetChoices;
var
   iCount : integer;
begin
     // choose everything by default
     for iCount := 1 to 10 do
         with UserSubsetChoices._first[iCount] do
         begin
              fIrr := False;
              fSum := False;
              fSum_A := False;
              fSum_T := False;
              fSum_V := False;
              fSum_AT := False;
              fSum_AV := False;
              fSum_TV := False;
              fSum_ATV := False;
         end;
     for iCount := 1 to 5 do
         with UserSubsetChoices._second[iCount] do
         begin
              fWav := False;
              fPC := False;
         end;
     fCheckClickAction := True;
     iUserSubset := 1;
end;

procedure EditUserSubsetChoices;
begin
     try
        NewUserSubsetChoices := UserSubsetChoices;

        ChooseFieldsForm := TChooseFieldsForm.Create(Application);
        if (ChooseFieldsForm.ShowModal = mrOk) then
           UserSubsetChoices := NewUserSubsetChoices;

        ChooseFieldsForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Edit Subset Choices',mtError,[mbOk],0);
     end;
end;

procedure TChooseFieldsForm.RefreshChoices;
begin
     //
end;

procedure TChooseFieldsForm.DisplayChoices(const iChoice : integer);
begin
     // display choices for subset iChoice
     if (iChoice > 0) then
     begin
          fCheckClickAction := False;

          GroupChoice.Caption := 'Subset ' + IntToStr(iChoice);

          if (iChoice <= 5) then
          begin
               CheckWav.Enabled := True;
               CheckPC.Enabled := True;
               CheckWav.Checked := NewUserSubsetChoices._second[iChoice].fWav;
               CheckPC.Checked := NewUserSubsetChoices._second[iChoice].fPC;
          end
          else
          begin
               CheckWav.Checked := False;
               CheckWav.Enabled := False;
               CheckPC.Checked := False;
               CheckPC.Enabled := False;
          end;

          with NewUserSubsetChoices._first[iChoice] do
          begin
               CheckIrr.Checked := fIrr;
               CheckSum.Checked := fSum;
               CheckSum_A.Checked := fSum_A;
               CheckSum_T.Checked := fSum_T;
               CheckSum_V.Checked := fSum_V;
               CheckSum_AT.Checked := fSum_AT;
               CheckSum_AV.Checked := fSum_AV;
               CheckSum_TV.Checked := fSum_TV;
               CheckSum_ATV.Checked := fSum_ATV;
          end;

          fCheckClickAction := True;
     end;
end;

procedure TChooseFieldsForm.ChooseUserFields;
begin
     //
end;

procedure TChooseFieldsForm.ComboSubsetChange(Sender: TObject);
begin
     //
     //DisplayChoices(iUserSubset);
end;

procedure TChooseFieldsForm.CheckIrrClick(Sender: TObject);
var
   iCount : integer;
begin
     if fCheckClickAction then
        if (ListSubsets.Items.Count > 0) then
           for iCount := 0 to (ListSubsets.Items.Count-1) do
               if ListSubsets.Selected[iCount] then
                  //NewUserSubsetChoices._first[iCount+1].fIrr := CheckIrr.Checked;
                  NewUserSubsetChoices._first[StrToInt(ListSubsets.Items.Strings[iCount])].fIrr := CheckIrr.Checked;
end;

procedure TChooseFieldsForm.CheckSumClick(Sender: TObject);
var
   iCount : integer;
begin
     if fCheckClickAction then
        if (ListSubsets.Items.Count > 0) then
           for iCount := 0 to (ListSubsets.Items.Count-1) do
               if ListSubsets.Selected[iCount] then
                  NewUserSubsetChoices._first[StrToInt(ListSubsets.Items.Strings[iCount])].fSum := CheckSum.Checked;
end;

procedure TChooseFieldsForm.CheckWavClick(Sender: TObject);
var
   iCount : integer;
begin
     if fCheckClickAction then
        if (ListSubsets.Items.Count > 0) then
           for iCount := 0 to (ListSubsets.Items.Count-1) do
               if ListSubsets.Selected[iCount] then
                  NewUserSubsetChoices._second[StrToInt(ListSubsets.Items.Strings[iCount])].fWav := CheckWav.Checked;
end;

procedure TChooseFieldsForm.CheckPCClick(Sender: TObject);
var
   iCount : integer;
begin
     if fCheckClickAction then
        if (ListSubsets.Items.Count > 0) then
           for iCount := 0 to (ListSubsets.Items.Count-1) do
               if ListSubsets.Selected[iCount] then
                  NewUserSubsetChoices._second[StrToInt(ListSubsets.Items.Strings[iCount])].fPC := CheckPC.Checked;
end;

procedure TChooseFieldsForm.CheckSum_AClick(Sender: TObject);
var
   iCount : integer;
begin
     if fCheckClickAction then
        if (ListSubsets.Items.Count > 0) then
           for iCount := 0 to (ListSubsets.Items.Count-1) do
               if ListSubsets.Selected[iCount] then
                  NewUserSubsetChoices._first[StrToInt(ListSubsets.Items.Strings[iCount])].fSum_A := CheckSum_A.Checked;
end;

procedure TChooseFieldsForm.CheckSum_TClick(Sender: TObject);
var
   iCount : integer;
begin
     if fCheckClickAction then
        if (ListSubsets.Items.Count > 0) then
           for iCount := 0 to (ListSubsets.Items.Count-1) do
               if ListSubsets.Selected[iCount] then
                  NewUserSubsetChoices._first[StrToInt(ListSubsets.Items.Strings[iCount])].fSum_T := CheckSum_T.Checked;
end;

procedure TChooseFieldsForm.CheckSum_VClick(Sender: TObject);
var
   iCount : integer;
begin
     if fCheckClickAction then
        if (ListSubsets.Items.Count > 0) then
           for iCount := 0 to (ListSubsets.Items.Count-1) do
               if ListSubsets.Selected[iCount] then
                  NewUserSubsetChoices._first[StrToInt(ListSubsets.Items.Strings[iCount])].fSum_V := CheckSum_V.Checked;
end;

procedure TChooseFieldsForm.CheckSum_ATClick(Sender: TObject);
var
   iCount : integer;
begin
     if fCheckClickAction then
        if (ListSubsets.Items.Count > 0) then
           for iCount := 0 to (ListSubsets.Items.Count-1) do
               if ListSubsets.Selected[iCount] then
                  NewUserSubsetChoices._first[StrToInt(ListSubsets.Items.Strings[iCount])].fSum_AT := CheckSum_AT.Checked;
end;

procedure TChooseFieldsForm.CheckSum_AVClick(Sender: TObject);
var
   iCount : integer;
begin
     if fCheckClickAction then
        if (ListSubsets.Items.Count > 0) then
           for iCount := 0 to (ListSubsets.Items.Count-1) do
               if ListSubsets.Selected[iCount] then
                  NewUserSubsetChoices._first[StrToInt(ListSubsets.Items.Strings[iCount])].fSum_AV := CheckSum_AV.Checked;
end;

procedure TChooseFieldsForm.CheckSum_TVClick(Sender: TObject);
var
   iCount : integer;
begin
     if fCheckClickAction then
        if (ListSubsets.Items.Count > 0) then
           for iCount := 0 to (ListSubsets.Items.Count-1) do
               if ListSubsets.Selected[iCount] then
                  NewUserSubsetChoices._first[StrToInt(ListSubsets.Items.Strings[iCount])].fSum_TV := CheckSum_TV.Checked;
end;

procedure TChooseFieldsForm.CheckSum_ATVClick(Sender: TObject);
var
   iCount : integer;
begin
     if fCheckClickAction then
        if (ListSubsets.Items.Count > 0) then
           for iCount := 0 to (ListSubsets.Items.Count-1) do
               if ListSubsets.Selected[iCount] then
                  NewUserSubsetChoices._first[StrToInt(ListSubsets.Items.Strings[iCount])].fSum_ATV := CheckSum_ATV.Checked;
end;

procedure TChooseFieldsForm.InitSubsetsInUse;
var
   iCount : integer;
begin
     ListSubsets.Items.Clear;
     for iCount := 1 to 10 do
         if ControlRes^.ClassDetail[iCount] then
            ListSubsets.Items.Add(IntToStr(iCount));
     if (ListSubsets.Items.Count > 0) then
     begin
          ListSubsets.Selected[0] := True;
          iUserSubset := StrToInt(ListSubsets.Items.Strings[0]);
     end
     else
     begin
          MessageDlg('No subsets were specified in selected field.',mtError,[mbOk],0);
          //ModalResult := mrOk;
     end;
end;

procedure TChooseFieldsForm.FormCreate(Sender: TObject);
begin
     InitSubsetsInUse;
     DisplayChoices(iUserSubset);
end;

procedure TChooseFieldsForm.ListSubsetsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   iCount : integer;
begin
     // user has just clicked on the listbox.

     // if there is only 1 item selected, set this as the active subset
     if (ListSubsets.SelCount = 1) then
     begin
          // 1 item selected
          for iCount := 0 to (ListSubsets.Items.Count-1) do
              if ListSubsets.Selected[iCount] then
              begin
                   iUserSubset := StrToInt(ListSubsets.Items.Strings[iCount]);
                   DisplayChoices(iUserSubset);
              end;
     end
     else
     begin
          // more than 1 items selected
     end;
end;

procedure TChooseFieldsForm.btnDeSelectAllClick(Sender: TObject);
var
   iCount : integer;
begin
     if (ListSubsets.Items.Count > 0) then
     begin
          for iCount := 0 to (ListSubsets.Items.Count-1) do
              if ListSubsets.Selected[iCount] then
              begin

              end;
     end;
end;

end.
