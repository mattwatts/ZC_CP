unit User_Select_Fields;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, Db, DBTables, ExtCtrls;

type
  TUserSelectFieldsForm = class(TForm)
    LeftPanel: TPanel;
    RightPanel: TPanel;
    MidPanel: TPanel;
    TopPanel: TPanel;
    lblTableName: TLabel;
    Label3: TLabel;
    InputTable: TTable;
    btnSelectAllFields: TButton;
    BitBtn1: TBitBtn;
    InputFields: TListBox;
    Label1: TLabel;
    AddSelected: TButton;
    AddAll: TButton;
    RemoveSelected: TButton;
    RemoveAll: TButton;
    Label2: TLabel;
    OutputFields: TListBox;
    btnDown: TSpeedButton;
    btnUp: TSpeedButton;
    BitBtn2: TBitBtn;
    InputType: TListBox;
    OutputType: TListBox;
    procedure ResizeTheForm;
    procedure FormResize(Sender: TObject);
    procedure InitForm(const sFilename : string);
    procedure AddSelectedClick(Sender: TObject);
    procedure RemoveSelectedClick(Sender: TObject);
    procedure AddAllClick(Sender: TObject);
    procedure RemoveAllClick(Sender: TObject);
    procedure btnSelectAllFieldsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    fAllOriginalFieldsUsed : boolean;
  end;

var
  UserSelectFieldsForm: TUserSelectFieldsForm;

implementation

uses
    Miscellaneous;

{$R *.DFM}

procedure TUserSelectFieldsForm.ResizeTheForm;
begin
     // resize left and right panels
     LeftPanel.Width := (Width - 37 - (LeftPanel.BevelWidth * 6)) div 2;
     RightPanel.Width := LeftPanel.Width;
     // resize/move components on left panel
     InputFields.Height := LeftPanel.Height - InputFields.Top - 74;
     InputFields.Width := LeftPanel.Width - 12;
     BitBtn1.Left := (LeftPanel.Width - BitBtn1.Width) div 2;
     BitBtn1.Top := LeftPanel.Height - BitBtn1.Height - 12;
     btnSelectAllFields.Left := (LeftPanel.Width - btnSelectAllFields.Width) div 2;
     btnSelectAllFields.Top := BitBtn1.Top - btnSelectAllFields.Height - 6;
     // resize/move components on middle panel
     RemoveAll.Top := MidPanel.Height - AddSelected.Top - RemoveAll.Height;
     RemoveSelected.Top := RemoveAll.Top - RemoveSelected.Height - 6;
     // resize/move components on right panel
     OutputFields.Height := InputFields.Height;
     OutputFields.Width := InputFields.Width;
     BitBtn2.Left := BitBtn1.Left;
     BitBtn2.Top := BitBtn1.Top;
     btnDown.Left := BitBtn2.Left;
     btnDown.Top := BitBtn2.Top - BitBtn2.Height - 6;
     btnUp.Left := BitBtn2.Left + BitBtn2.Width - btnUp.Width;
     btnUp.Top := btnDown.Top;
end;

procedure TUserSelectFieldsForm.FormResize(Sender: TObject);
begin
     ResizeTheForm;
end;

procedure TUserSelectFieldsForm.InitForm(const sFilename : string);
var
   iCount : integer;
begin
     //
     try
        Screen.Cursor := crHourglass;

        lblTableName.Caption := sFilename;

        InputFields.Items.Clear;
        OutputFields.Items.Clear;
        InputType.Items.Clear;
        OutputType.Items.Clear;

        InputTable.DatabaseName := TrimTrailingSlashes(ExtractFilePath(sFilename));
        InputTable.TableName := ExtractFileName(sFilename);
        InputTable.Open;
        // read the fields from the table
        for iCount := 0 to (InputTable.FieldCount - 1) do
        begin
             InputFields.Items.Add(InputTable.FieldDefs.Items[iCount].Name);
             if (InputTable.FieldDefs.Items[iCount].DataType <> ftString) then
                InputType.Items.Add('Float')
             else
                 InputType.Items.Add('String');
        end;
        InputTable.Close;

        fAllOriginalFieldsUsed := False;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
     end;
end;

procedure TUserSelectFieldsForm.AddSelectedClick(Sender: TObject);
var
   iItems, iCount : integer;
begin
     // add selected fields
     iItems := InputFields.Items.Count;

     if (iItems > 0) then
     begin
        for iCount := 0 to (iItems - 1) do
            if InputFields.Selected[iCount] then
            begin
                 OutputFields.Items.Add(InputFields.Items.Strings[iCount]);
                 OutputType.Items.Add(InputFields.Items.Strings[iCount]);
                 //InputFields.Items.Delete(iCount);
            end;

        for iCount := (iItems - 1) downto 0 do
            if InputFields.Selected[iCount] then
            begin
                 //OutputFields.Items.Add(InputFields.Items.Strings[iCount]);
                 InputFields.Items.Delete(iCount);
                 InputType.Items.Delete(iCount);
            end;
     end;
end;

procedure TUserSelectFieldsForm.RemoveSelectedClick(Sender: TObject);
var
   iItems, iCount : integer;
begin
     // add selected fields
     iItems := OutputFields.Items.Count;

     if (iItems > 0) then
     begin
        for iCount := 0 to (iItems - 1) do
            if OutputFields.Selected[iCount] then
            begin
                 InputFields.Items.Add(OutputFields.Items.Strings[iCount]);
                 InputType.Items.Add(OutputFields.Items.Strings[iCount]);
                 //OutputFields.Items.Delete(iCount);
            end;

        for iCount := (iItems - 1) downto 0 do
            if OutputFields.Selected[iCount] then
            begin
                 //InputFields.Items.Add(OutputFields.Items.Strings[iCount]);
                 OutputFields.Items.Delete(iCount);
                 OutputType.Items.Delete(iCount);
            end;
     end;
end;

procedure TUserSelectFieldsForm.AddAllClick(Sender: TObject);
var
   iItems, iCount : integer;
begin
     // add selected fields
     iItems := InputFields.Items.Count;

     if (iItems > 0) then
     begin
        for iCount := 0 to (iItems - 1) do
        begin
             OutputFields.Items.Add(InputFields.Items.Strings[iCount]);
             OutputType.Items.Add(InputFields.Items.Strings[iCount]);
             //InputFields.Items.Delete(iCount);
        end;

        InputFields.Items.Clear;
        InputType.Items.Clear;
     end;
end;

procedure TUserSelectFieldsForm.RemoveAllClick(Sender: TObject);
var
   iItems, iCount : integer;
begin
     // add selected fields
     iItems := OutputFields.Items.Count;

     if (iItems > 0) then
     begin
        for iCount := 0 to (iItems - 1) do
        begin
             InputFields.Items.Add(OutputFields.Items.Strings[iCount]);
             InputType.Items.Add(OutputFields.Items.Strings[iCount]);
             //OutputFields.Items.Delete(iCount);
        end;

        OutputFields.Items.Clear;
        OutputType.Items.Clear;
     end;
end;

procedure TUserSelectFieldsForm.btnSelectAllFieldsClick(Sender: TObject);
begin
     fAllOriginalFieldsUsed := True;
     AddAllClick(Sender);
     ModalResult := mrOk;
end;

end.
