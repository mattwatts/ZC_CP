unit import_target_field;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, Db, DBTables;

type
  TImportTargetFieldForm = class(TForm)
    Label1: TLabel;
    EditInputFile: TEdit;
    ButtonBrowse: TButton;
    OpenDialog1: TOpenDialog;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ComboTargetField: TComboBox;
    ComboKeyField: TComboBox;
    EditNewTargetName: TEdit;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    Table1: TTable;
    Query1: TQuery;
    procedure ButtonBrowseClick(Sender: TObject);
    procedure LoadFieldNames;
    procedure ComboTargetFieldChange(Sender: TObject);
    procedure BitBtnOkClick(Sender: TObject);
    procedure ImportTargetField;
    procedure ReloadTarget;
    procedure MakeTargetFieldExist;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ImportTargetFieldForm: TImportTargetFieldForm;

implementation

uses
    control, global, reinit, sf_irrep, ds;

{$R *.DFM}

function CountDelimitersInRow(const sRow, sDelimiter : string) : integer;
var
   iCount : integer;
begin
     Result := 0;
     if (Length(sRow) > 0) then
        for iCount := 1 to Length(sRow) do
            if (sRow[iCount] = sDelimiter) then
               Inc(Result);
end;

function GetDelimitedAsciiElement(const sLine, sDelimiter : string;
                                  const iColumn : integer) : string;
// returns the element at 1-based-index column iColumn
// returns blank string if the column does not exist in sLine
// NOTE : the function needs to return a blank string in the case where 2
//        delimiters occur as adjacent characters in the input line.
//        ie. the case of blank cells in the input file
var
   sTrimLine : string;
   iPos, iTrim, iCount : integer;
begin
     Result := '';

     sTrimLine := sLine;
     iTrim := iColumn-1;
     if (iTrim > 0) then
        for iCount := 1 to iTrim do // trim the required number of columns from the start of the string
        begin
             iPos := Pos(sDelimiter,sTrimLine);
             if (iPos > 0) then
                sTrimLine := Copy(sTrimLine,iPos+1,Length(sTrimLine)-iPos)
             else
                 // there are not enough delimiters in the line,
                 // assume blank cells have been truncated from file
                 sTrimLine := '';
        end;
     iPos := Pos(sDelimiter,sTrimLine);
     if (iPos = 1) then
     begin
          // there is a delimiter at the start of the line we must trim first
          {sTrimLine := Copy(sTrimLine,2,Length(sTrimLine)-1);
          iPos := Pos(sDelimiter,sTrimLine);
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;}
          // WRONG !  What we must actually do is return the blank string
          //          ie. this is a blank cell in the input file
          Result := '';
     end
     else
     begin
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;
     end;
end;


procedure TImportTargetFieldForm.LoadFieldNames;
var
   iCount, iNumberOfFields : integer;
   InFile : TextFile;
   sLine, sFieldName : string;
begin
     //
     if (LowerCase(ExtractFileExt(EditInputFile.Text)) = '.dbf') then
     begin
          // load dbf table field names
          Table1.DatabaseName := ExtractFilePath(EditInputFile.Text);
          Table1.TableName := ExtractFileName(EditInputFile.Text);
          Table1.Open;
          // load the feature targets from the feature table
          for iCount := 1 to Table1.FieldCount do
          begin
               ComboKeyField.Items.Add(Table1.FieldDefs.Items[iCount-1].Name);
               ComboTargetField.Items.Add(Table1.FieldDefs.Items[iCount-1].Name);
          end;
          Table1.Close;
          ComboKeyField.Text := ComboKeyField.Items.Strings[0];
          ComboTargetField.Text := ComboTargetField.Items.Strings[0];
          EditNewTargetName.Text := ComboTargetField.Text;
     end
     else
     begin
          // load csv table field names
          assignfile(InFile,EditInputFile.Text);
          reset(InFile);
          readln(InFile,sLine);
          closefile(InFile);

          iNumberOfFields := CountDelimitersInRow(sLine,',') + 1;
          for iCount := 1 to iNumberOfFields do
          begin
               sFieldName := GetDelimitedAsciiElement(sLine,',',iCount);

               ComboKeyField.Items.Add(sFieldName);
               ComboTargetField.Items.Add(sFieldName);
          end;

          ComboKeyField.Text := ComboKeyField.Items.Strings[0];
          ComboTargetField.Text := ComboTargetField.Items.Strings[0];
          EditNewTargetName.Text := ComboTargetField.Text;
     end;
end;

procedure TImportTargetFieldForm.ButtonBrowseClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
     begin
          // load the field names from the table and populate the combo boxes with them
          EditInputFile.Text := OpenDialog1.Filename;
          LoadFieldNames;

          Label2.Enabled := True;
          Label3.Enabled := True;
          Label4.Enabled := True;
          ComboKeyField.Enabled := True;
          ComboTargetField.Enabled := True;
          EditNewTargetName.Enabled := True;

     end;
end;

procedure TImportTargetFieldForm.ComboTargetFieldChange(Sender: TObject);
begin
     EditNewTargetName.Text := ComboTargetField.Text;
end;

procedure TImportTargetFieldForm.MakeTargetFieldExist;
var
   iCount : integer;
   fFieldExistsInTable : boolean;
begin
     // if the new target field does not exist, then add it with an sql query
     Table1.DatabaseName := ControlRes^.sDatabase;
     Table1.TableName := ControlRes^.sFeatCutOffsTable;
     Table1.Open;
     fFieldExistsInTable := False;
     for iCount := 1 to Table1.FieldCount do
         if (Table1.FieldDefs.Items[iCount-1].Name = EditNewTargetName.Text) then
            fFieldExistsInTable := True;
     Table1.Close;

     if not fFieldExistsInTable then
        with Query1 do
        begin
             // add the field with an sql query
             SQL.Clear;
             SQL.Add('ALTER TABLE "' +
                     ControlRes^.sDatabase +
                     '\' +
                     ControlRes^.sFeatCutOffsTable +
                     '"');
             SQL.Add('ADD ' + EditNewTargetName.Text + ' NUMERIC(10,5)');
             try
                Prepare;
                ExecSQL;
             except
                   Screen.Cursor := crDefault;
                   SQL.SaveToFile('c:\add_fld.sql');
                   MessageDlg('Exception adding field to the feature table',mtInformation,[mbOk],0);
             end;

        end;
end;

procedure TImportTargetFieldForm.ImportTargetField;
var
   iCount, iNumberOfFields, iFeatureKey, iFeatureKeyField, iFeatureTargetField : integer;
   InFile : TextFile;
   sLine, sFieldName : string;
   NewFeatureTarget : Array_t;
   rNewFeatureTarget : extended;
begin
     // read the targets from a file into an array of feature targets, then write the array of feature targets to
     // the feature dbf table
     NewFeatureTarget := Array_t.Create;
     NewFeatureTarget.init(SizeOf(extended),iFeatureCount);
     rNewFeatureTarget := 0;
     for iCount := 1 to iFeatureCount do
         NewFeatureTarget.setValue(iCount,@rNewFeatureTarget);

     if (LowerCase(ExtractFileExt(EditInputFile.Text)) = '.dbf') then
     begin
          // load dbf table feature targets
          Table1.DatabaseName := ExtractFilePath(EditInputFile.Text);
          Table1.TableName := ExtractFileName(EditInputFile.Text);
          Table1.Open;
          // load the feature targets from the feature table
          for iCount := 1 to Table1.FieldCount do
          begin
               iFeatureKey := Table1.FieldByName(ComboKeyField.Text).AsInteger;
               rNewFeatureTarget := Table1.FieldByName(ComboTargetField.Text).AsFloat;
               NewFeatureTarget.setValue(iFeatureKey,@rNewFeatureTarget);

               Table1.Next;
          end;
          Table1.Close;
     end
     else
     begin
          // load csv table feature targets
          assignfile(InFile,EditInputFile.Text);
          reset(InFile);
          readln(InFile,sLine);

          iNumberOfFields := CountDelimitersInRow(sLine,',') + 1;
          // find field index for feature key field and feature target field
          for iCount := 1 to iNumberOfFields do
          begin
               sFieldName := GetDelimitedAsciiElement(sLine,',',iCount);

               if (sFieldName = ComboKeyField.Text) then
                  iFeatureKeyField := iCount;
               if (sFieldName = ComboTargetField.Text) then
                  iFeatureTargetField := iCount;
          end;
          // traverse table loading feature target to the array
          repeat
                readln(InFile,sLine);

                iFeatureKey := StrToInt(GetDelimitedAsciiElement(sLine,',',iFeatureKeyField));
                rNewFeatureTarget := StrToFloat(GetDelimitedAsciiElement(sLine,',',iFeatureTargetField));
                NewFeatureTarget.setValue(iFeatureKey,@rNewFeatureTarget);

          until Eof(InFile);

          closefile(InFile);
     end;

     // write the new feature target to the feature table under the correct field name,
     // adding the new field to the table first if it doesn't exist already.
     MakeTargetFieldExist;
     Table1.DatabaseName := ControlRes^.sDatabase;
     Table1.TableName := ControlRes^.sFeatCutOffsTable;
     Table1.Open;
     for iCount := 1 to iFeatureCount do
     begin
          NewFeatureTarget.rtnValue(iCount,@rNewFeatureTarget);
          Table1.FieldByName(EditNewTargetName.Text).AsFloat := rNewFeatureTarget;
          Table1.Next;
     end;
     Table1.Close;
     NewFeatureTarget.Destroy;
end;

procedure TImportTargetFieldForm.ReloadTarget;
begin
     if (ControlRes^.sFeatureTargetField <> EditNewTargetName.Text) then
        fIniChange := True;

     ControlRes^.sFeatureTargetField := EditNewTargetName.Text;

     ControlForm.LoadFeatureTable;

     if ControlForm.UseFeatCutOffs.Checked then
     begin
          {we are using imported targets, so we must run irrep}
          ReInitializeInitialValues(TargetChange);

          ExecuteIrreplaceability(-1,False,False,True,True,'');
     end
     else
         ControlForm.UseFeatCutOffs.Checked := True;
end;

procedure TImportTargetFieldForm.BitBtnOkClick(Sender: TObject);
begin
     ImportTargetField;

     ReloadTarget;
end;

end.
