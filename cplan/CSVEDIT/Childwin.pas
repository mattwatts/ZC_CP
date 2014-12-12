unit Childwin;

interface

uses
    Windows, Classes, Graphics, Forms, Controls, Grids, ExtCtrls, StdCtrls,
    Db, DBTables, Spin,
    ds, ComCtrls, OleCtnrs, MPlayer,
    global, Menus;

type
  TMDIChild = class(TForm)
    Panel1: TPanel;
    aGrid: TStringGrid;
    InTable: TTable;
    lblDimensions: TLabel;
    KeyFieldGroup: TRadioGroup;
    CheckLoadFileData: TCheckBox;
    SpinRow: TSpinEdit;
    SpinCol: TSpinEdit;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    KeyCombo: TComboBox;
    Label2: TLabel;
    CheckLockFirstColumn: TCheckBox;
    CheckLockFirstRow: TCheckBox;
    StatusBar: TStatusBar;
    Timer1: TTimer;
    PopupMenu1: TPopupMenu;
    Insert1: TMenuItem;
    Append1: TMenuItem;
    Delete1: TMenuItem;
    Rows1: TMenuItem;
    Columns1: TMenuItem;
    Selection1: TMenuItem;
    Rows2: TMenuItem;
    Columns2: TMenuItem;
    Rows3: TMenuItem;
    Columns3: TMenuItem;
    Edit1: TMenuItem;
    EditValues1: TMenuItem;
    Copy_1: TMenuItem;
    Paste_1: TMenuItem;
    PasteTranspose1: TMenuItem;
    Cut1: TMenuItem;
    procedure LoadFile;
    procedure LoadDBFTable2Grid(TheGrid : TStringGrid;
                                const sFilename : string);
    procedure LinkFile;
    procedure LoadDBFTableDimensions(const sFilename : string;
                                     var iRows, iColumns : integer;
                                     TargetGrid : TStringGrid);
    procedure SpinEdit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function rtnColumnIndex(const sColumnName : string) : integer;
    procedure rtnDBFDataTypes;
    procedure CheckLockFirstColumnClick(Sender: TObject);
    procedure KeyComboChange(Sender: TObject);
    procedure aGridColumnMoved(Sender: TObject; FromIndex,
      ToIndex: Integer);
    procedure CheckLockFirstRowClick(Sender: TObject);
    procedure UpdateKeyObjects(const iColumnToUpdate : integer);
    procedure aGridGetEditMask(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure aGridGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure aGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure aGridRowMoved(Sender: TObject; FromIndex, ToIndex: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    function rtnRichnessOfColumns(var RichnessOfColumns : Array_t) : boolean;
    procedure FormActivate(Sender: TObject);
    procedure EditValues1Click(Sender: TObject);
    procedure Copy_1Click(Sender: TObject);
    procedure Paste_1Click(Sender: TObject);
    procedure PasteTranspose1Click(Sender: TObject);
    procedure Rows1Click(Sender: TObject);
    procedure Columns1Click(Sender: TObject);
    procedure Selection1Click(Sender: TObject);
    procedure Rows2Click(Sender: TObject);
    procedure Columns2Click(Sender: TObject);
    procedure Rows3Click(Sender: TObject);
    procedure Columns3Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DataFieldTypes : Array_t;
    fDataHasChanged : boolean;
  end;

function rtnDataType (DataType : TFieldType;
                      iPrecision : integer) : FDType_T;
 

implementation

{$R *.DFM}

uses
    {ImpTools,}
    SysUtils, Dialogs,
    itools, MAIN, adddata, csv_link_percent_edit;


function rtnDataType (DataType : TFieldType;
                      iPrecision : integer) : FDType_T;
begin
     case DataType of
          ftSmallint,ftInteger,ftWord,ftBoolean : Result := DBaseInt;
          ftFloat :
                    //if (iPrecision = 0) then
                    //   Result := DBaseInt
                    //else
                        Result := DBaseFloat;
     else
         Result := DBaseStr;
     end;
end;

function TMDIChild.rtnRichnessOfColumns(var RichnessOfColumns : Array_t) : boolean;
var
   iRichness, iRCount, iCCount : integer;
   rValue : extended;
begin
     // return the number of non zero values in each column as an array
     // with as many elements as there are columns
     try
        if CheckLoadFileData.Checked then
        begin
             Result := True;

             RichnessOfColumns := Array_t.Create;
             RichnessOfColumns.init(SizeOf(integer),SpinCol.Value);
             // init richness of columns to zero
             iRichness := 0;
             for iCCount := 1 to AGrid.ColCount do
                 RichnessOfColumns.setValue(iCCount,@iRichness);
             // traverse cells finding richness of each column as we go
             for iCCount := 0 to (AGrid.ColCount - 1) do
                 for iRCount := 0 to (AGrid.RowCount - 1) do
                 begin
                      try
                         rValue := StrToFloat(AGrid.Cells[iCCount,iRCount]);
                         if (rValue > 0) then
                         begin
                              // increment the richness of this column
                              RichnessOfColumns.rtnValue(iCCount+1,@iRichness);
                              Inc(iRichness);
                              RichnessOfColumns.setValue(iCCount+1,@iRichness);
                         end;

                      except
                      end;
                 end;
        end
        else
            Result := False;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TMDIChild.rtnRichnessOfColumns',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TMDIChild.UpdateKeyObjects(const iColumnToUpdate : integer
                                     {0 referenced, value of -1 indicates update all columns});
var
   iKeyField, iCount, iPos : integer;
begin
     {update KeyCombo and KeyFieldGroup (.Items) with new column name(s)}
     if (iColumnToUpdate = -1) then
     begin
          iKeyField := KeyFieldGroup.ItemIndex;

          {update all columns, column names and positions may have changed}
          KeyCombo.Items.Clear;
          KeyFieldGroup.Items.Clear;

          for iCount := 0 to (aGrid.ColCount - 1) do
          begin
               KeyCombo.Items.Add(aGrid.Cells[iCount,0]);
               KeyFieldGroup.Items.Add(aGrid.Cells[iCount,0]);
          end;

          iPos := KeyCombo.Items.IndexOf(KeyCombo.Text);
          if (iPos >= 0) then
             KeyFieldGroup.ItemIndex := iPos
          else
              KeyFieldGroup.ItemIndex := iKeyField;
     end
     else
     begin
          {update column iColumnToUpdate, column positions have not changed, just this name}
          iKeyField := KeyFieldGroup.ItemIndex;

          KeyCombo.Items.Delete(iColumnToUpdate);
          KeyFieldGroup.Items.Delete(iColumnToUpdate);

          KeyCombo.Items.Insert(iColumnToUpdate,aGrid.Cells[iColumnToUpdate,0]);
          KeyFieldGroup.Items.Insert(iColumnToUpdate,aGrid.Cells[iColumnToUpdate,0]);

          if (iKeyField = iColumnToUpdate) then
             KeyCombo.Text := aGrid.Cells[iColumnToUpdate,0];

          KeyFieldGroup.ItemIndex := iKeyField;
     end;
end;

procedure TMDIChild.rtnDBFDataTypes;
var
   {sName : string;}  {used for reading field name}
   iCount : integer;
   AFDType : FDType_T;
   AType : FieldDataType_T;
begin
     {store the data field types for the dbf table in .DataFieldTypes
      use .InTable to read the data
      NOTE : .InTable must be open to call this procedure}
     try
        DataFieldTypes := Array_T.Create;
        DataFieldTypes.init(SizeOf(FieldDataType_T),InTable.FieldDefs.Count);
        for iCount := 1 to DataFieldTypes.lMaxSize do
        begin
             AFDType := rtnDataType(InTable.FieldDefs.Items[iCount-1].DataType,
                                    InTable.FieldDefs.Items[iCount-1].Precision);

             {sName := InTable.FieldDefs.Items[iCount-1].Name;}  {used for reading field name}

             AType.DBDataType := AFDType;

             {if the field is a string, this is the length of the string}
             AType.iSize := InTable.FieldDefs.Items[iCount-1].Size;

             DataFieldTypes.setValue(iCount,@AType);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in rtnDBFDataTypes',mtError,[mbOk],0);
     end;
end;

function TMDIChild.rtnColumnIndex(const sColumnName : string) : integer;
var
   iCount : integer;
begin
     {return the index (zero referenced) of the cell in row zero which
      is equal to sColumnName,
      returns -1 if not found}

     Result := -1;
     for iCount := 0 to (aGrid.ColCount - 1) do
         if (aGrid.Cells[iCount,0] = sColumnName) then
            Result := iCount;
end;

procedure TMDIChild.LoadDBFTableDimensions(const sFilename : string;
                                           var iRows, iColumns : integer;
                                           TargetGrid : TStringGrid);
var
   iCount : integer;
begin
     {}
     try
        Screen.Cursor := crHourglass;

        InTable.DatabaseName := ExtractFilePath(sFilename);
        InTable.TableName := ExtractFileName(sFilename);

        InTable.Open;

        rtnDBFDataTypes;

        iRows := InTable.RecordCount + 1;
        {add the field names in as the first row of grid}
        iColumns := InTable.FieldDefs.Count;
        TargetGrid.ColCount := iColumns;
        TargetGrid.RowCount := 1;
        for iCount := 0 to (iColumns-1) do
            TargetGrid.Cells[{col,row}iCount,0] := InTable.FieldDefs.Items[iCount].Name;

        InTable.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadDBFTableDimensions ' + sFilename,
                      mtError,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
end;

procedure TMDIChild.LoadDBFTable2Grid(TheGrid : TStringGrid;
                                      const sFilename : string);
var
   fEnd : boolean;
   iRow, iRows, iColumns, iCount : integer;
begin
     {use InTable to load the grid}
     try
        Screen.Cursor := crHourglass;

        InTable.DatabaseName := ExtractFilePath(sFilename);
        InTable.TableName := ExtractFileName(sFilename);

        InTable.Open;

        rtnDBFDataTypes;

        {add the field names in as the first row of grid}
        iColumns := InTable.FieldDefs.Count;
        TheGrid.ColCount := iColumns;
        for iCount := 0 to (iColumns-1) do
            TheGrid.Cells[iCount,0] := InTable.FieldDefs.Items[iCount].Name;

        {add each row in the DBF file to the grid}
        iRow := 1;
        iRows := InTable.RecordCount + 1;
        TheGrid.RowCount := iRows;
        repeat
              fEnd := InTable.EOF;

              if not fEnd then
                 for iCount := 0 to (iColumns-1) do
                     try
                        //TheGrid.Cells[{col,row}iCount,iRow] :=
                        //   InTable.FieldByName(InTable.FieldDefs.Items[iCount].Name).AsString;
                        TheGrid.Cells[iCount,iRow] := InTable.Fields[iCount].AsString;
                     except
                           TheGrid.Cells[iCount,iRow] := '';
                     end;

              InTable.Next;
              Inc(iRow);

        until fEnd;



        InTable.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Load DBF Table ' + sFilename,
                      mtError,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
end;

procedure TMDIChild.LinkFile;
var
   iRows, iColumns : integer;
   rFractionOfFileToScan : extended;
begin
     {load link to a CSV or DBF file}

     try
        CheckLoadFileData.Checked := False;

        {aGrid.Visible := False;}

        if (LowerCase(ExtractFileExt(Caption)) = '.dbf')
        or (LowerCase(ExtractFileExt(Caption)) = '.db') then
           LoadDBFTableDimensions(Caption,iRows,iColumns,aGrid)
        else
        begin
             rFractionOfFileToScan := 0.01; // 0.01 is 1% of the file

             CSVLinkEdit := TCSVLinkEdit.Create(Application);
             CSVLinkEdit.lblFile.Caption := Caption;

             if (CSVLinkEdit.ShowModal = mrOk) then
             begin
                  if (CSVLinkEdit.RadioProportion.ItemIndex = 0) then
                     rFractionOfFileToScan := CSVLinkEdit.SpinPercent.Value / 100
                  else
                      rFractionOfFileToScan := 2; // a value >= 1, ie. all

                  LoadCSVDimensions2Grid(Caption,iRows,iColumns,aGrid,
                                         DataFieldTypes,
                                         True,
                                         rFractionOfFileToScan // fraction of file to scan for type
                                         );
             end;

             CSVLinkEdit.Free;
        end;

        //aGrid.Align := alNone;
        //aGrid.Height := aGrid.DefaultRowHeight * 2;
        ClientHeight := Panel1.Height + (aGrid.DefaultRowHeight * 2) + StatusBar.Height;
        //aGrid.Align := alClient;

        SpinRow.Value := iRows;
        SpinCol.Value := iColumns;

        lblDimensions.Caption := 'Rows: ' + IntToStr(iRows) +
                                 ' Columns: ' + IntToStr(iColumns);

        CheckLockFirstColumn.Visible := False;
        CheckLockFirstRow.Visible := False;

        StatusBar.SimpleText := 'Table is linked, data is not loaded into the grid';
        StatusBar.Refresh;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TMDIChild.LinkFile',mtError,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
end;

procedure TMDIChild.LoadFile;
var
   fLoaded : boolean;
begin
     {load contents of a CSV or DBF file into the grid}

     try
        CheckLoadFileData.Checked := True;
        fLoaded := True;

        if (LowerCase(ExtractFileExt(Caption)) = '.mtx') then
        begin
             LoadMTX2StringGrid(AGrid,Caption,fLoaded,DataFieldTypes);
        end
        else
        begin
             if (LowerCase(ExtractFileExt(Caption)) = '.mat') then
             begin
                  {we may be loading C-Plan matrix file or No-Header matrix file}
                  if (MainForm.OpenDialog.FilterIndex = 6) then
                     LoadMATNoHeader2StringGrid(AGrid,Caption,
                                                DataFieldTypes)  {load No-Header matrix}
                  else
                      LoadMAT2StringGrid(AGrid,Caption,fLoaded,
                                         DataFieldTypes);        {load C-Plan matrix}
             end
             else
             begin
                  if (LowerCase(ExtractFileExt(Caption)) = '.dbf')
                  or (LowerCase(ExtractFileExt(Caption)) = '.db') then
                     LoadDBFTable2Grid(AGrid,Caption)
                  else
                      LoadCSV2StringGrid(AGrid,Caption,TRUE,
                                         DataFieldTypes,
                                         True);
             end;
        end;

        SpinRow.Value := AGrid.RowCount;
        SpinCol.Value := AGrid.ColCount;

        lblDimensions.Caption := 'Rows: ' + IntToStr(AGrid.RowCount) +
                                 ' Columns: ' + IntToStr(AGrid.ColCount);

        if (AGrid.RowCount > 1) then
           AGrid.FixedRows := 1;

        {enable column moving for the loaded table}
        AGrid.Options := AGrid.Options + [goColMoving];

        if not fLoaded then
           {the matrix file was not loaded to grid,
            wrong version number}
           ;

        StatusBar.SimpleText := 'Table is loaded into the grid';
        StatusBar.Refresh;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TMDIChild.LoadFile',mtError,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
end;

procedure TMDIChild.SpinEdit1Change(Sender: TObject);
begin
     aGrid.DefaultColWidth := SpinEdit1.Value;
end;

procedure TMDIChild.FormCreate(Sender: TObject);
begin
     SpinEdit1.Value := aGrid.DefaultColWidth;
     Timer1.Enabled := True;
end;

procedure TMDIChild.CheckLockFirstColumnClick(Sender: TObject);
begin
     if CheckLockFirstColumn.Checked then
     begin
          if (aGrid.ColCount > 1) then
             aGrid.FixedCols := 1;
     end
     else
         aGrid.FixedCols := 0;
end;

procedure TMDIChild.KeyComboChange(Sender: TObject);
var
   iPos : integer;
begin
     iPos := KeyCombo.Items.IndexOf(KeyCombo.Text);
     if (iPos >= 0) then
        KeyFieldGroup.ItemIndex := iPos;
end;

procedure TMDIChild.aGridColumnMoved(Sender: TObject; FromIndex,
  ToIndex: Integer);
var
   ToType, FromType : FieldDataType_T;
begin
     {swap datatypes at FromIndex+1 and ToIndex+1}
     DataFieldTypes.rtnValue(FromIndex+1,@FromType);
     DataFieldTypes.rtnValue(ToIndex+1,@ToType);
     DataFieldTypes.setValue(FromIndex+1,@ToType);
     DataFieldTypes.setValue(ToIndex+1,@FromType);

     {we have moved a column, update key field objects}
     UpdateKeyObjects(-1);
     fDataHasChanged := True;
end;

procedure TMDIChild.CheckLockFirstRowClick(Sender: TObject);
begin
     if CheckLockFirstRow.Checked then
     begin
          if (aGrid.RowCount > 1) then
             aGrid.FixedRows := 1
          else
              CheckLockFirstRow.Checked := False;
     end
     else
         aGrid.FixedRows := 0;
end;

procedure TMDIChild.aGridGetEditMask(Sender: TObject; ACol, ARow: Integer;
  var Value: String);
begin
     if (ARow = 0) then
        UpdateKeyObjects(ACol);
     fDataHasChanged := True;
end;


procedure TMDIChild.aGridGetEditText(Sender: TObject; ACol, ARow: Integer;
  var Value: String);
begin
     if (ARow = 0) then
        UpdateKeyObjects(ACol);
     fDataHasChanged := True;
end;

procedure TMDIChild.aGridSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: String);
begin
     if (ARow = 0) then
        UpdateKeyObjects(ACol);
     fDataHasChanged := True;
end;

procedure TMDIChild.aGridRowMoved(Sender: TObject; FromIndex,
  ToIndex: Integer);
begin
     if (FromIndex = 0)
     or (ToIndex = 0) then
     begin
          {key fields need to be reread}
          UpdateKeyObjects(-1);
          KeyCombo.Text := KeyFieldGroup.Items.Strings[KeyFieldGroup.ItemIndex];
     end;
     fDataHasChanged := True;
end;

procedure TMDIChild.Timer1Timer(Sender: TObject);
begin
     if not (goEditing in aGrid.Options) then
     begin
          if CheckLoadFileData.Checked then
             StatusBar.SimpleText := 'Table is in select mode'
          else
              {table is linked};
     end;

     Timer1.Enabled := False;
end;



procedure TMDIChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     try
        DataFieldTypes.Destroy;
     except
     end;
     try
        Action := caFree;
     except
     end;
end;

procedure TMDIChild.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
   wDlgResult : word;
begin
     if fDataHasChanged then
     begin
          wDlgResult := MessageDlg('Table ' + Caption +
                                   ' has changed.  Do you want to save the contents before closing?',
                                   mtConfirmation,
                                   [mbYes,mbNo,mbCancel],0);

          case wDlgResult of
               mrYes :
               begin
                    MainForm.FileSaveAsItemClick(Self);
                    if fDataHasChanged then
                       CanClose := False;
               end;
               //mrNo : CanClose := True;
               mrCancel : CanClose := False;
          end;
     end;
     //else CanClose := True;
end;

procedure TMDIChild.FormActivate(Sender: TObject);
begin
     //MainForm.RefreshMenu;
end;

procedure TMDIChild.EditValues1Click(Sender: TObject);
begin
     //MainForm.EditValues1Click(Sender);
     //EditValues1.Checked := MainForm.EditValues1.Checked;
end;

procedure TMDIChild.Copy_1Click(Sender: TObject);
begin
     MainForm.CopyItemClick(Sender);
end;

procedure TMDIChild.Paste_1Click(Sender: TObject);
begin
     //SCPForm.PasteItemClick(Sender);
end;

procedure TMDIChild.PasteTranspose1Click(Sender: TObject);
begin
     //MainForm.PasteSpecial1Click(Sender);
end;

procedure TMDIChild.Rows1Click(Sender: TObject);
begin
    // MainForm.DeleteRows1Click(Sender);
end;

procedure TMDIChild.Columns1Click(Sender: TObject);
begin
     //MainForm.DeleteColumns1Click(Sender);
end;

procedure TMDIChild.Selection1Click(Sender: TObject);
begin
     // delete selection

     // equivelent to Copy | Cut which doesn't yet exist in tbl ed
end;

procedure TMDIChild.Rows2Click(Sender: TObject);
begin
     // Insert Rows
     if (MainForm.ActiveMDIChild <> nil) then
     try
        AddDataForm := TAddDataForm.Create(Application);
        AddDataForm.AddChild := TMDIChild(MainForm.ActiveMDIChild);

        if (AddDataForm.ShowModal = mrOk) then
           // Apply the user add cells options
           AddDataForm.ApplyUserOptions;
        AddDataForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Add Cells',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TMDIChild.Columns2Click(Sender: TObject);
begin
     // Insert Columns
     if (MainForm.ActiveMDIChild <> nil) then
     try
        AddDataForm := TAddDataForm.Create(Application);
        AddDataForm.AddChild := TMDIChild(MainForm.ActiveMDIChild);

        AddDataForm.RadioAddWhat.ItemIndex := 2;

        if (AddDataForm.ShowModal = mrOk) then
           // Apply the user add cells options
           AddDataForm.ApplyUserOptions;
        AddDataForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Add Cells',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TMDIChild.Rows3Click(Sender: TObject);
begin
     // Append Rows
     if (MainForm.ActiveMDIChild <> nil) then
     try
        AddDataForm := TAddDataForm.Create(Application);
        AddDataForm.AddChild := TMDIChild(MainForm.ActiveMDIChild);

        AddDataForm.RadioAddWhat.ItemIndex := 1;

        if (AddDataForm.ShowModal = mrOk) then
           // Apply the user add cells options
           AddDataForm.ApplyUserOptions;
        AddDataForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Add Cells',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TMDIChild.Columns3Click(Sender: TObject);
begin
     // Append Columns
     if (MainForm.ActiveMDIChild <> nil) then
     try
        AddDataForm := TAddDataForm.Create(Application);
        AddDataForm.AddChild := TMDIChild(MainForm.ActiveMDIChild);

        AddDataForm.RadioAddWhat.ItemIndex := 3;

        if (AddDataForm.ShowModal = mrOk) then
           // Apply the user add cells options
           AddDataForm.ApplyUserOptions;
        AddDataForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Add Cells',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TMDIChild.Cut1Click(Sender: TObject);
begin
     MainForm.CutItemClick(Sender);
end;

procedure TMDIChild.PopupMenu1Popup(Sender: TObject);
begin
     if CheckLoadFileData.Checked then

        //EditValues1.Checked := MainForm.EditValues1.Checked

     else
     begin
          Edit1.Enabled := False;
          Delete1.Enabled := False;
          Insert1.Enabled := False;
          Append1.Enabled := False;
     end;

end;

end.
