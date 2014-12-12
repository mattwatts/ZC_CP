{ Form Template - Source and Destination Choices Lists }
unit Choosefi;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls;

type
  TDualListDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    SrcList: TListBox;
    DstList: TListBox;
    SrcLabel: TLabel;
    DstLabel: TLabel;
    IncludeBtn: TSpeedButton;
    IncAllBtn: TSpeedButton;
    ExcludeBtn: TSpeedButton;
    ExAllBtn: TSpeedButton;
    Label1: TLabel;
    procedure IncludeBtnClick(Sender: TObject);
    procedure ExcludeBtnClick(Sender: TObject);
    procedure IncAllBtnClick(Sender: TObject);
    procedure ExcAllBtnClick(Sender: TObject);
    procedure MoveSelected(List: TCustomListBox; Items: TStrings);
    procedure SetItem(List: TListBox; Index: Integer);
    function GetFirstSelection(List: TCustomListBox): Integer;
    procedure SetButtons;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DualListDlg: TDualListDlg;

function ChooseFields(var {Avail,} Display : TListBox;
                      const sCaption,sSource,sDest : string) : boolean;

implementation

uses Em_newu1, SysUtils, Control, Global;

{$R *.DFM}

procedure ReloadDBMSDisplayFields;
var
   iCount,iCount2 : integer;
   sToMatch : string;
   fMatch : boolean;
begin
     with DualListDlg do
     try
        SrcList.Items.Clear;
        DstList.Items.Clear;

        ControlForm.OutTable.Open;

        ControlRes^.fUseNewDBLABELS := False;

        for iCount2 := 0 to (ControlForm.OutTable.FieldDefs.Count-1) do
            if (NEW_IRREPL_DBLABEL = ControlForm.OutTable.FieldDefs.Items[iCount2].Name) then
               ControlRes^.fUseNewDBLABELS := True;

        iCount := 0;
        while (iCount < ControlForm.LookupDisplayList.Items.Count) do
        begin
             sToMatch := ControlForm.LookupDisplayList.Items.Strings[iCount];
             fMatch := False;
             for iCount2 := 0 to (ControlForm.OutTable.FieldDefs.Count-1) do
                 if (sToMatch = ControlForm.OutTable.FieldDefs.Items[iCount2].Name) then
                    fMatch := True;

             Inc(iCount);

             if fMatch then
                DstList.Items.Add(sToMatch);
        end;
        {match all fields in LookupDisplayList to the DB file,
         deleting any that don't match}

         
        for iCount := 0 to (ControlForm.OutTable.FieldDefs.Count-1) do
        begin
             sToMatch := ControlForm.OutTable.FieldDefs.Items[iCount].Name;
             fMatch := False;
             for iCount2 := 0 to (ControlForm.LookupDisplayList.Items.Count-1) do
                 if (sToMatch = ControlForm.LookupDisplayList.Items.Strings[iCount2]) then
                    fMatch := True;

             if not fMatch then
                SrcList.Items.Add(sToMatch);
        end;
        {iterate all the DB fields, adding any not displayed to the
         available list}

     finally
            ControlForm.OutTable.Close;
     end;
end;



function ChooseFields(var {Avail,} Display : TListBox;
                      const sCaption,sSource,sDest : string) : boolean;
begin
     DualListDlg := TDualListDlg.Create(Application);

     Result := True;

     with DualListDlg do
     try
        Caption := sCaption;
        SrcLabel.Caption := sSource;
        DstLabel.Caption := sDest;

        ReloadDBMSDisplayFields;

        if (ShowModal = mrOK) then
           Display.Items := DstList.Items;

     finally
            Free;
     end;

end; {of function ChooseFields}


procedure TDualListDlg.IncludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(SrcList);
  MoveSelected(SrcList, DstList.Items);
  SetItem(SrcList, Index);
end;

procedure TDualListDlg.ExcludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(DstList);
  MoveSelected(DstList, SrcList.Items);
  SetItem(DstList, Index);
end;

procedure TDualListDlg.IncAllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to SrcList.Items.Count - 1 do
    DstList.Items.AddObject(SrcList.Items[I],
      SrcList.Items.Objects[I]);
  SrcList.Items.Clear;
  SetItem(SrcList, 0);
end;

procedure TDualListDlg.ExcAllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to DstList.Items.Count - 1 do
    SrcList.Items.AddObject(DstList.Items[I], DstList.Items.Objects[I]);
  DstList.Items.Clear;
  SetItem(DstList, 0);
end;

procedure TDualListDlg.MoveSelected(List: TCustomListBox; Items: TStrings);
var
  I: Integer;
begin
  for I := List.Items.Count - 1 downto 0 do
    if List.Selected[I] then
    begin
      Items.AddObject(List.Items[I], List.Items.Objects[I]);
      List.Items.Delete(I);
    end;
end;

procedure TDualListDlg.SetButtons;
var
  SrcEmpty, DstEmpty: Boolean;
begin
  SrcEmpty := SrcList.Items.Count = 0;
  DstEmpty := DstList.Items.Count = 0;
  IncludeBtn.Enabled := not SrcEmpty;
  IncAllBtn.Enabled := not SrcEmpty;
  ExcludeBtn.Enabled := not DstEmpty;
  ExAllBtn.Enabled := not DstEmpty;
end;

function TDualListDlg.GetFirstSelection(List: TCustomListBox): Integer;
begin
  for Result := 0 to List.Items.Count - 1 do
    if List.Selected[Result] then Exit;
  Result := LB_ERR;
end;

procedure TDualListDlg.SetItem(List: TListBox; Index: Integer);
var
  MaxIndex: Integer;
begin
  with List do
  begin
    SetFocus;
    MaxIndex := List.Items.Count - 1;
    if Index = LB_ERR then Index := 0
    else if Index > MaxIndex then Index := MaxIndex;
    Selected[Index] := True;
  end;
  SetButtons;
end;

end.
