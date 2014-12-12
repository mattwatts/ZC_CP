unit Fieldimp;

{$I IMP_DEF.DEF}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DB, DBTables, StdCtrls, ExtCtrls, Grids,
  Global;

type
  TImpOptionsForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    txtSite: TEdit;
    txtCSV: TEdit;
    btnBrowseDBase: TButton;
    btnBrowseCSV: TButton;
    KeyField: TComboBox;
    ImpFields: TListBox;
    Label3: TLabel;
    Label4: TLabel;
    btnStart: TButton;
    btnExit: TButton;
    UpdateTable: TTable;
    CSVFile: TStringGrid;
    OpenCSV: TOpenDialog;
    OpenDB: TOpenDialog;
    checkZeroSites: TCheckBox;
    Label5: TLabel;
    dBaseKey: TComboBox;
    lblProgress: TLabel;
    procedure btnExitClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnBrowseCSVClick(Sender: TObject);
    procedure KeyFieldChange(Sender: TObject);
    procedure btnBrowseDBaseClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ImpOptionsForm: TImpOptionsForm;
  {iAvailFldCount : integer;
  CSVAvailFld : CSVFld_T;}

implementation

uses
    Imptools, ShowImp, AddField,
  {$IFDEF bit16}
  Arrayt16;
  {$ELSE}
  ds;
  {$ENDIF}

{$R *.DFM}

procedure TImpOptionsForm.btnExitClick(Sender: TObject);
begin
     ModalResult := mrOK;
end;

function CustFindRow(const sLine : string;
                     const iCol : integer) : integer;
var
   iCount : integer;
begin
     Result := -1;

     for iCount := 1 to (ImpOptionsForm.CSVFile.RowCount-1) do
         if (ImpOptionsForm.CSVFile.Cells[iCol,iCount] = sLine) then
            Result := iCount;
end;

function CustFindCol(const sLine : string) : integer;
var
   iCount : integer;
begin
     Result := -1;

     for iCount := 1 to (ImpOptionsForm.CSVFile.ColCount-1) do
         if (ImpOptionsForm.CSVFile.Cells[iCount,0] = sLine) then
            Result := iCount;
end;

procedure TImpOptionsForm.btnStartClick(Sender: TObject);
var
   fStop, fNoMatch, fAdd, fStopUpdate : boolean;
   iProgressCount,
   iCount, iFldCount, iRowIndex, iKeyCol,
   iNoMatch, iFields : integer;
   CSVFld : Array_T;
   CSVItem : CSVFldItem_T;
   sDBKeyField, sDBValue, sDBStub, sDBPut : string;
begin
     try
     if (ImpFields.SelCount > 0) then
     begin
          {CSV file is loaded}
          Screen.Cursor := crHourglass;

          iFldCount := 0;
          iKeyCol := -1;
          iNoMatch := 0;

          fStop := False;

          CSVFld := Array_t.Create;
          CSVFld.init(SizeOf(CSVItem),ARR_STEP_SIZE);

          {open dbase file}
          try
             with UpdateTable do
             begin
                  TableName := ExtractFileName(txtSite.Text);
                  sDBStub := ExtractFilePath(txtSite.Text);
                  if (Length(sDBStub) > 1) then
                     sDBStub := Copy(sDBStub,1,Length(sDBStub)-1);
                  DatabaseName := sDBStub;
                  Open;

                  {build a list of fields for import}

                  for iCount := 0 to (CSVFile.ColCount-1) do
                      if (KeyField.Text = CSVFile.Cells[iCount,0]) then
                         iKeyCol := iCount;

                  sDBKeyField := dBaseKey.Text; {MapKey.Items.Strings[MapKey.ItemIndex]}

                  if (ImpFields.SelCount > 0)
                  and (sDBKeyField <> '') then
                  begin
                       for iCount := 0 to (ImpFields.Items.Count-1) do
                           if ImpFields.Selected[iCount] then
                           begin
                                {compare current ImpField to fields in
                                 existing DB file and call AlterTable
                                 if AlterTable returns true then
                                 add the item}

                                fAdd := True;

                                {for iFields := 1 to FieldDefs.Count do
                                    if (FieldDefs.Items[iFields-1].Name <> ImpFields.Items.Strings[iCount]) then
                                       fAdd := False;
                                if not fAdd then
                                begin
                                     Close;
                                     Screen.Cursor := crDefault;
                                     fAdd := AlterTable(DatabaseName,TableName,ImpFields.Items.Strings[iCount]);
                                     Screen.Cursor := crHourglass;
                                     Open;
                                end;}

                                if fAdd then
                                begin
                                     Inc(iFldCount);
                                     if (iFldCount > CSVFld.lMaxSize) then
                                        CSVFld.resize(CSVFld.lMaxSize + ARR_STEP_SIZE);

                                     CSVItem.sItem := ImpFields.Items.Strings[iCount];
                                     CSVItem.iItem := CustFindCol(ImpFields.Items.Strings[iCount]);

                                     CSVFld.setValue(iFldCount,@CSVItem);

                                     if (sDBKeyField = CSVItem.sItem) then
                                        fStop := True;
                                        {prevents writing over key field
                                         if user selects this as one of the
                                         import fields}
                                end;
                           end;
                  end;
             end;

          except on EDBEngineError do
                 begin
                      Screen.Cursor := crDefault;

                      MessageDlg('Database file not found - ' + UpdateTable.DatabaseName
                                + '\' + UpdateTable.TableName, mtError, [mbOK], 0);

                      Screen.Cursor := crHourglass;

                      fStop := true;
                 end;
          end;

          {traverse dBase file
           match MapKey.Items.Strings(MapKey.ItemIndex)
           to    KeyField in CSVGrid}
          {now import the data into the DBF file}
          if not fStop
          and (iFldCount > 0) then
          begin
               StartFieldSummary(txtCSV.Text,txtSite.Text,KeyField.Text,sDBKeyField);
               {bring up the output form with Field Import Details}

               iProgressCount := 0;

               repeat
                     Inc(iProgressCount);

                     lblProgress.Caption := 'Processing Site ' + IntToStr(iProgressCount) +
                                      ' of ' + IntToStr(UpdateTable.RecordCount);
                     lblProgress.Refresh;


                     sDBValue := UpdateTable.FieldByName(sDBKeyField).AsString;
                     iRowIndex := CustFindRow(sDBValue,iKeyCol);

                     UpdateTable.Edit;

                     fNoMatch := True;

                     for iCount := 1 to iFldCount do
                     begin
                          CSVFld.rtnValue(iCount,@CSVItem);

                          if (iRowIndex = -1) then
                          begin
                               sDBPut := DB_IMPORT_NODATA;
                          end
                          else
                          begin
                               fNoMatch := False;
                               sDBPut := CSVFile.Cells[CSVItem.iItem,iRowIndex];
                          end;

                          fStopUpdate := False;
                          if (sDBPut = DB_IMPORT_NODATA)
                          and (not checkZeroSites.Checked) then
                              fStopUpdate := True;

                          if not fStopUpdate then
                             UpdateTable.FieldByName(CSVItem.sItem).AsString := sDBPut;
                     end;

                     if fNoMatch then
                     begin
                          ShowImpForm.AddLineField('"' + sDBValue + '" not found');
                          Inc(iNoMatch);
                     end;

                     UpdateTable.Post;
                     UpdateTable.Next;

               until UpdateTable.EOF;

               lblProgress.Caption := '';
               lblProgress.Refresh;
          end;

          if (iFldCount > 0) then
          begin
               if (iNoMatch > 0) then
               begin
                    ShowImpForm.AddLineField('Total of ' + IntToStr(iNoMatch) +
                                             ' elements not found in input file');
                    ShowImpForm.AddLineField('Value set to ' + DB_IMPORT_NODATA +
                                             ' by default');
               end
               else
                   ShowImpForm.AddLineField('All elements found in input file');

               Screen.Cursor := crDefault;
               EndFieldSummary;
               {display the form to the user and then get rid of it}
          end
          else
          begin
               Screen.Cursor := crDefault;
               MessageDlg('No fields to import',mtInformation,[mbOk],0);
               Screen.Cursor := crHourglass;
          end;

          CSVFld.Destroy;

          if not fStop then
             UpdateTable.Close;
     end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Import Field(s)',mtError,[mbOk],0);
     end;
end;

procedure TImpOptionsForm.btnBrowseCSVClick(Sender: TObject);
var
   iCount : integer;
begin
     OpenCSV.FileName := ExtractFileName(txtCSV.Text);
     OpenCSV.InitialDir := ExtractFilePath(txtCSV.Text);

     if OpenCSV.Execute then
     begin
          Screen.Cursor := crHourglass;

          txtCSV.Text := LowerCase(OpenCSV.FileName);
          txtCSV.SelectAll;
          LoadCSV2StringGrid(CSVFile,OpenCSV.FileName,TRUE);

          {iAvailFldCount := CSVFile.ColCount;}
          KeyField.Items.Clear;
          KeyField.Text := '';
          ImpFields.Items.Clear;

          if (CSVFile.ColCount > 0) then
          for iCount := 0 to (CSVFile.ColCount-1) do
          begin
               {CSVAvailFld[iCount+1].sItem := CSVFile.Cells[iCount,0];
               CSVAvailFld[iCount+1].iItem := iCount;}
               KeyField.Items.Add(CSVFile.Cells[iCount,0]);
          end;

          Screen.Cursor := crDefault;
     end;
end;

procedure TImpOptionsForm.KeyFieldChange(Sender: TObject);
var
   iCount : integer;
begin
     ImpFields.Items.Clear;

     for iCount := 0 to (KeyField.Items.Count-1) do
         if (KeyField.Items.Strings[iCount] <> KeyField.Text) then
            ImpFields.Items.Add(KeyField.Items.Strings[iCount]);
end;

procedure TImpOptionsForm.btnBrowseDBaseClick(Sender: TObject);
var
   iCount : integer;
begin
     OpenDB.FileName := ExtractFileName(txtSite.Text);
     OpenDB.InitialDir := ExtractFilePath(txtSite.Text);

     if OpenDB.Execute then
     begin
          txtSite.Text := LowerCase(OpenDB.FileName);
          txtSite.SelectAll;

          {load the field names into the dBaseKey List Box}
          UpdateTable.DatabaseName := ExtractFilePath(txtSite.Text);
          UpdateTable.TableName := ExtractFileName(txtSite.Text);

          try
             UpdateTable.Open;
             dBaseKey.Items.Clear;
             dBaseKey.Text := '';

             for iCount := 0 to (UpdateTable.FieldDefs.Count-1) do
                 dBaseKey.Items.Add(UpdateTable.FieldDefs.Items[iCount].Name);

             UpdateTable.Close;

          except on exception do;
          end;
     end;
end;

procedure TImpOptionsForm.FormResize(Sender: TObject);
begin
     ClientHeight := ImpFields.Top + ImpFields.Height + 10;
     ClientWidth := ImpFields.Left + ImpFields.Width + 10;
     {Position := poScreenCenter;}
end;

procedure TImpOptionsForm.FormCreate(Sender: TObject);
begin
     FormResize(self);
end;

end.
