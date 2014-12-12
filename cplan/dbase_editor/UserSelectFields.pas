unit UserSelectFields;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, Db, DBTables;

type
  TUserSelectFieldsForm = class(TForm)
    InputFields: TListBox;
    OutputFields: TListBox;
    AddSelected: TButton;
    AddAll: TButton;
    RemoveSelected: TButton;
    RemoveAll: TButton;
    btnDown: TSpeedButton;
    btnUp: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label3: TLabel;
    lblTableName: TLabel;
    InputTable: TTable;
    InputType: TListBox;
    OutputType: TListBox;
    btnSelectAllFields: TButton;
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
    converter;

{$R *.DFM}

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
