unit importintotablewizard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Gauges, StdCtrls, Grids, Buttons, ExtCtrls,
  childwin, ds;

type

    KeyType_T = (Key_string, // key field is string 254
                 Key_float); // key field is float
    str254_T = string[254];

  TImportIntoTableForm = class(TForm)
    Notebook1: TNotebook;
    btnNext: TButton;
    BitBtn1: TBitBtn;
    btnBrowse: TButton;
    btnAddFieldToList: TSpeedButton;
    SelAllTbl: TSpeedButton;
    Label33: TLabel;
    btnAddEntireTable: TSpeedButton;
    Button27: TButton;
    Button28: TButton;
    BitBtn16: TBitBtn;
    ComboField: TComboBox;
    LinkGrid: TStringGrid;
    Button36: TButton;
    Label20: TLabel;
    Label21: TLabel;
    BitBtn11: TBitBtn;
    Button1: TButton;
    btnOk: TBitBtn;
    Gauge1: TGauge;
    LabelProgress: TLabel;
    AvailableTablesGrid: TStringGrid;
    SourceTablesGrid: TStringGrid;
    ComboDestinationKey: TComboBox;
    LabelAvailableTable: TLabel;
    ComboSourceKey: TComboBox;
    LabelSourceTable: TLabel;
    Panel1: TPanel;
    Label8: TLabel;
    Label1: TLabel;
    Panel2: TPanel;
    Label32: TLabel;
    Label7: TLabel;
    Label2: TLabel;
    EditNewName: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure ListAvailableTables;
    procedure ListSourceTables(const sDestinationTable : string);
    procedure btnBrowseClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure Button27Click(Sender: TObject);
    procedure PrepareLinkGrid;
    procedure PrepareComboField;
    procedure btnAddFieldToListClick(Sender: TObject);
    procedure AddRow;
    procedure DeleteRow(const iRow : integer);
    procedure DeleteSelectedRows;
    procedure SelAllTblClick(Sender: TObject);
    procedure Button28Click(Sender: TObject);
    procedure btnAddEntireTableClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure ImportIntoTable;
    function ListTableFields(const Child : TMDIChild) : string;
    procedure AvailableTablesGridClick(Sender: TObject);
    procedure SourceTablesGridClick(Sender: TObject);
    procedure Button36Click(Sender: TObject);
    procedure MakeDestinationLookupArray(const sDestinationTbl,
                                               sDestinationKey : string);
    procedure MakeFieldsToImport(const fInputIsLinkGrid : boolean;
                                 const sTbl,
                                       sKeyField,
                                       sFieldToImport,
                                       sFieldDestName : string);
    procedure FreeFieldsToImport;
    procedure ParseFieldsToImport;
    procedure DumpFieldsToImport(const sFilename, sDelimiter : string);
    procedure AddExtraDestinationFields(const sDestTbl : string);
    procedure ParseDestinationTable(const sDestTbl, sDestKey : string);
    procedure ImportSingleFieldIntoTable(const sDestinationTbl,
                                               sDestinationKey,
                                               sDestinationField,
                                               sSourceTbl,
                                               sSourceKey,
                                               sSourceField : string);
    procedure ComboFieldClick(Sender: TObject);
    procedure EditNewNameChange(Sender: TObject);
    procedure tall_form;
    procedure short_form;
    procedure ComboDestinationKeyChange(Sender: TObject);
    procedure ComboSourceKeyChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    sDestinationTable : string;
    DestinationChild, ClickSourceChild : TMDIChild;
    FieldsToImport,
    DestinationLookupArray,
    DestinationSortedKey : Array_t;
    DestinationKeyType : KeyType_T;
  end;

var
  ImportIntoTableForm: TImportIntoTableForm;

procedure WipePreviousKey(AGrid : TStringGrid);

implementation

uses
    converter, Main, listsort, reallist, fieldproperties;

// this unit needs to use {opt1, sitelist, featlist} but they are linked to too many other things.
// bring special versions of them across to listsort unit
// they are needed for list sorting algorithms, etc

{$R *.DFM}

procedure TImportIntoTableForm.tall_form;
begin
     Height := BitBtn16.Top + BitBtn16.Height + 20 + Panel2.Height;
     Width := BitBtn16.Left + BitBtn16.Width + 20;
end;

procedure TImportIntoTableForm.short_form;
begin
     Height := BitBtn1.Top + BitBtn1.Height + 20 + Panel1.Height;
     Width := BitBtn1.Left + BitBtn1.Width + 20;
end;

procedure TImportIntoTableForm.ListSourceTables(const sDestinationTable : string);
var
   iCount, iRow : integer;
begin
     // list all tables in the SourceTablesGrid except for sDestinationTable
     if (MainForm.MDIChildCount > 0) then
     try
        // we must list all the tables users can choose from
        SourceTablesGrid.ColCount := 3;
        SourceTablesGrid.RowCount := MainForm.MDIChildCount;

        if (SourceTablesGrid.RowCount > 1) then
           SourceTablesGrid.FixedRows := 1;

        SourceTablesGrid.Cells[0,0] := 'Table Name';
        SourceTablesGrid.Cells[1,0] := 'Key Field';
        SourceTablesGrid.Cells[2,0] := 'Path';
        iRow := 0;
        for iCount := 0 to (MainForm.MDIChildCount-1) do
            if (sDestinationTable <> TMDIChild(MainForm.MDIChildren[iCount]).sFilename) then
            begin
                 Inc(iRow);
                 SourceTablesGrid.Cells[0,iRow] := ExtractFileName( TMDIChild(MainForm.MDIChildren[iCount]).sFilename );
                 SourceTablesGrid.Cells[1,iRow] := '';
                 SourceTablesGrid.Cells[2,iRow] := TrimTrailingSlashes(ExtractFilePath( TMDIChild(MainForm.MDIChildren[iCount]).sFilename ));
            end;

        AutoFitGrid(SourceTablesGrid,Canvas,True);

        ClickSourceChild := TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(SourceTablesGrid.Cells[2,1] + '\' + SourceTablesGrid.Cells[0,1])]);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ListSourceTables',mtError,[mbOk],0);
     end;
end;

function TImportIntoTableForm.ListTableFields(const Child : TMDIChild) : string;
var
   iCount : integer;
begin
     // list the fields from the table
     ComboDestinationKey.Items.Clear;
     ComboDestinationKey.Text := Child.Query1.FieldDefs.Items[0].Name;
     Result := ComboDestinationKey.Text;
     for iCount := 0 to (Child.Query1.FieldDefs.Count - 1) do
         ComboDestinationKey.Items.Add(Child.Query1.FieldDefs.Items[iCount].Name);
end;

procedure TImportIntoTableForm.ListAvailableTables;
var
   iCount : integer;
begin
     if (MainForm.MDIChildCount > 0) then
     try
        // we must list all the tables users can choose from
        AvailableTablesGrid.ColCount := 3;
        AvailableTablesGrid.RowCount := MainForm.MDIChildCount + 1;

        AvailableTablesGrid.Cells[0,0] := 'Table Name';
        AvailableTablesGrid.Cells[1,0] := 'Key Field';
        AvailableTablesGrid.Cells[2,0] := 'Path';

        for iCount := 0 to (MainForm.MDIChildCount-1) do
        begin
             AvailableTablesGrid.Cells[0,iCount+1] := ExtractFileName( TMDIChild(MainForm.MDIChildren[iCount]).sFilename );
             AvailableTablesGrid.Cells[1,iCount+1] := '';
             AvailableTablesGrid.Cells[2,iCount+1] := TrimTrailingSlashes(ExtractFilePath( TMDIChild(MainForm.MDIChildren[iCount]).sFilename ));
        end;

        LabelAvailableTable.Caption := 'Table   ' + AvailableTablesGrid.Cells[0,1];

        AutoFitGrid(AvailableTablesGrid,Canvas,True);

        // list the fields from the first table in the control
        AvailableTablesGrid.Cells[1,1] := ListTableFields(TMDIChild(MainForm.MDIChildren[0]));

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ListAvailableTables',mtError,[mbOk],0);
     end;
end;

procedure TImportIntoTableForm.FormCreate(Sender: TObject);
begin
     // we must list all the tables users can choose from
     Notebook1.PageIndex := 0;
     ListAvailableTables;

     {AvailableTablesGrid.Selection.Top := 1;
     AvailableTablesGrid.Selection.Left := 1;
     AvailableTablesGrid.Selection.Bottom := 1;
     AvailableTablesGrid.Selection.Right := 2;}
     //AvailableTablesGrid.SelectCell(1,1);

     short_form;
     //Height := 289;
     // Height := 421;

     // SmallFonts Height 289 or 421 (single or double grid)
     //
end;

procedure TImportIntoTableForm.btnBrowseClick(Sender: TObject);
begin
     // browse another table
     MainForm.FileOpenItemClick(Sender);
     // reset table list
     ListAvailableTables;
end;

procedure TImportIntoTableForm.PrepareLinkGrid;
begin
     with LinkGrid do
     try
        ColCount := 5;
        RowCount := 2;
        Cells[0,0] := 'Field';
        Cells[1,0] := 'New Field Name';
        Cells[2,0] := 'Table Name';
        Cells[3,0] := 'Key Field';
        Cells[4,0] := 'Path';
        Cells[0,1] := '';
        Cells[1,1] := '';
        Cells[2,1] := '';
        Cells[3,1] := '';
        Cells[4,1] := '';

        AutoFitGrid(LinkGrid,Canvas,True);

     except
     end;
end;

procedure TImportIntoTableForm.PrepareComboField;
var
   iCount : integer;
begin
     // list the fields for sDestinationTable in PrepareComboField
     ComboField.Items.Clear;
     ComboSourceKey.Items.Clear;
     ComboField.Text := ClickSourceChild.Query1.FieldDefs.Items[0].Name;
     EditNewName.Text := ComboField.Text;
     ComboSourceKey.Text := ComboField.Text;
     for iCount := 0 to (ClickSourceChild.Query1.FieldDefs.Count - 1) do
     begin
          ComboField.Items.Add(ClickSourceChild.Query1.FieldDefs.Items[iCount].Name);
          ComboSourceKey.Items.Add(ClickSourceChild.Query1.FieldDefs.Items[iCount].Name);
     end;
     LabelSourceTable.Caption := 'Table   ' + SourceTablesGrid.Cells[0,SourceTablesGrid.Selection.Top];
     SourceTablesGrid.Cells[1,1] := ComboField.Text;
end;

procedure TImportIntoTableForm.btnNextClick(Sender: TObject);
begin
     sDestinationTable := AvailableTablesGrid.Cells[2,AvailableTablesGrid.Selection.Top] + '\' +
                          AvailableTablesGrid.Cells[0,AvailableTablesGrid.Selection.Top];
     DestinationChild := TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(sDestinationTable)]);

     ListSourceTables(sDestinationTable);
     PrepareLinkGrid;
     PrepareComboField;
     // Height := 289;
     //Height := 421;
     tall_form;
     Notebook1.PageIndex := 1;
end;

procedure TImportIntoTableForm.Button27Click(Sender: TObject);
begin
     short_form;
     //Height := 289;
     // Height := 421;
     Notebook1.PageIndex := 0;
     // we must refresh list of tables in case user clicked 'Browse Another Table'
     //AvailableTablesGrid
     ListAvailableTables;
end;

procedure TImportIntoTableForm.AddRow;
begin
     if LinkGrid.RowCount = 2 then
     begin
          if LinkGrid.Cells[0,1] = '' then
             // do nothing because the table is already empty
          else
              // add a row
              LinkGrid.RowCount := LinkGrid.RowCount + 1;
     end
     else
     begin
          // add a row
          LinkGrid.RowCount := LinkGrid.RowCount + 1;
     end;
end;

procedure TImportIntoTableForm.DeleteRow(const iRow : integer);
var
   iStartRow, iEndRow, iCount : integer;
begin
     // iRow is a zero based index
     if (iRow < (LinkGrid.RowCount-1)) then
     begin
          // row is not last row
          // map contents of the grid upwards
          for iCount := iRow+1 to LinkGrid.RowCount-1 do
          begin
               LinkGrid.Cells[0,iCount-1] := LinkGrid.Cells[0,iCount];
               LinkGrid.Cells[1,iCount-1] := LinkGrid.Cells[1,iCount];
               LinkGrid.Cells[2,iCount-1] := LinkGrid.Cells[2,iCount];
               LinkGrid.Cells[3,iCount-1] := LinkGrid.Cells[3,iCount];
               LinkGrid.Cells[4,iCount-1] := LinkGrid.Cells[4,iCount];
          end;
     end
     else
         // row is last row
         ;

     if (LinkGrid.RowCount = 2) then
     begin
          // blank out the 2nd row
          LinkGrid.Cells[0,1] := '';
          LinkGrid.Cells[1,1] := '';
          LinkGrid.Cells[2,1] := '';
          LinkGrid.Cells[3,1] := '';
          LinkGrid.Cells[4,1] := '';

          // disable next button, there are no fields selected
          Button28.Enabled := False;
     end
     else
         LinkGrid.RowCount := LinkGrid.RowCount - 1;
end;

procedure TImportIntoTableForm.DeleteSelectedRows;
var
   iStartRow, iEndRow, iCount : integer;
begin
     //
     iStartRow := LinkGrid.Selection.Top;
     iEndRow := LinkGrid.Selection.Bottom;

     for iCount := iStartRow to iEndRow do
         DeleteRow(iStartRow);
end;

procedure TImportIntoTableForm.btnAddFieldToListClick(Sender: TObject);
var
   fContinue : boolean;
begin
     // check if the new name specified is a valid dbase field name before continuing
     // if the text is not blank
     fContinue := True;
     // if the text is not the same as ComboField.Text
     // ie. if the user has changed the text
     if (EditNewName.Text <> ComboField.Text) then
     begin
          // if the text is not a valid dbase name
          // or if the text is a local sql reserve word
          if not IsDBaseFieldNameValid(UpperCase(EditNewName.Text))
          or IsLocalSQLReserveWord(UpperCase(EditNewName.Text))
          or (EditNewName.Text = '') then
          begin
               // field name entered by user is invalid
               // display a message to the user
               MessageDlg('"' + EditNewName.Text + '" is not a valid dBase field name',mtInformation,[mbOk],0);
               // change field name back to default
               //EditNewName.Text := ComboField.Text
               fContinue := False;
          end;
     end;

     if fContinue then
     begin
          // add a row to the fields to import table
          AddRow;
          // put this fields details in the last row of the grid
          LinkGrid.Cells[0,LinkGrid.RowCount-1] := ComboField.Text;
          LinkGrid.Cells[1,LinkGrid.RowCount-1] := EditNewName.Text;
          LinkGrid.Cells[2,LinkGrid.RowCount-1] := SourceTablesGrid.Cells[0,SourceTablesGrid.Selection.Top];
          LinkGrid.Cells[3,LinkGrid.RowCount-1] := ComboSourceKey.Text;//SourceTablesGrid.Cells[1,SourceTablesGrid.Selection.Top];
          LinkGrid.Cells[4,LinkGrid.RowCount-1] := SourceTablesGrid.Cells[2,SourceTablesGrid.Selection.Top];

          AutoFitGrid(LinkGrid,Canvas,True);

          Button28.Enabled := True;
     end;
end;

procedure TImportIntoTableForm.SelAllTblClick(Sender: TObject);
begin
     DeleteSelectedRows;
     AutoFitGrid(LinkGrid,Canvas,True);
end;

procedure TImportIntoTableForm.Button28Click(Sender: TObject);
begin
     short_form;
     //Height := 289;
     // Height := 421;
     Notebook1.PageIndex := 2;
end;

procedure TImportIntoTableForm.btnAddEntireTableClick(Sender: TObject);
var
   iCount : integer;
begin
     for iCount := 0 to (ClickSourceChild.Query1.FieldDefs.Count - 1) do
         if (ClickSourceChild.Query1.FieldDefs.Items[iCount].Name <> ComboSourceKey.Text) then
         // do not add the key field, but add all the others in the table
         begin
              // add a row to the fields to import table
              AddRow;
              // put this fields details in the last row of the grid
              LinkGrid.Cells[0,LinkGrid.RowCount-1] := ClickSourceChild.Query1.FieldDefs.Items[iCount].Name;
              LinkGrid.Cells[1,LinkGrid.RowCount-1] := ClickSourceChild.Query1.FieldDefs.Items[iCount].Name;
              LinkGrid.Cells[2,LinkGrid.RowCount-1] := SourceTablesGrid.Cells[0,SourceTablesGrid.Selection.Top];
              LinkGrid.Cells[3,LinkGrid.RowCount-1] := ComboSourceKey.Text;
              LinkGrid.Cells[4,LinkGrid.RowCount-1] := SourceTablesGrid.Cells[2,SourceTablesGrid.Selection.Top];
         end;

     AutoFitGrid(LinkGrid,Canvas,True);

     Button28.Enabled := True;
end;

procedure TImportIntoTableForm.Button1Click(Sender: TObject);
begin
     tall_form;
     // Height := 289;
     //Height := 421;
     Notebook1.PageIndex := 1;
end;

procedure TImportIntoTableForm.btnOkClick(Sender: TObject);
begin
     LabelProgress.Caption := 'Importing Data';
     Notebook1.PageIndex := 3;

     ImportIntoTable;

     ModalResult := mrOk;
end;

procedure TImportIntoTableForm.MakeDestinationLookupArray(const sDestinationTbl,
                                                                sDestinationKey : string);
var
   sFieldValue : str254_T;
   //rFieldValue : extended;
   iCount : integer;
   //AChild : TMDIChild;
begin
     with ConvertModule.Table1 do
     try
        // write all the key values from the key field to a lookup array which
        // will be either STRING 254  (str254_T)
        //             or EXTENDED
        // ComboDestinationKey.Text is the key field

        // identify key field

        // identify type of key field
        //AChild := TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(sDestinationTbl)]);
        Close;
        DatabaseName := TrimTrailingSlashes(ExtractFilePath(sDestinationTbl));
        TableName := ExtractFileName(sDestinationTbl);
        Open;
           
        DestinationKeyType := Key_string;
        DestinationLookupArray := Array_t.Create;
        DestinationLookupArray.init(sizeof(str254_T),RecordCount{AChild.Query1.RecordCount});

        // load key field
        //AChild.DBGrid1.Visible := False;
        //AChild.Query1.First;
        iCount := 0;
        repeat
              Inc(iCount);

              sFieldValue := FieldByName(sDestinationKey).AsString; //AChild.Query1.FieldByName(sDestinationKey).AsString;
              DestinationLookupArray.setValue(iCount,@sFieldValue);

              //AChild.Query1.Next;
              Next;

        until Eof; //AChild.Query1.Eof;

        //AChild.Query1.First;
        //AChild.DBGrid1.Visible := True;
        Close;
        // sort key field
        DestinationSortedKey := SortStrArray(DestinationLookupArray);
        // check for duplicates
        TestUniqueStrArray(DestinationSortedKey,sDestinationTbl{AChild.sFilename});

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TImportIntoTableForm.MakeDestinationLookupArray',mtError,[mbOk],0);
     end;
end;

function rtnFieldIndex(sField : string;
                       TypeInfo : Array_t) : integer;
var
   FD : FieldDataType_T;
   iCount : integer;
begin
     // return 1-based index, 0 means not found
     Result := 0;
     for iCount := 1 to TypeInfo.lMaxSize do
     begin
          TypeInfo.rtnValue(iCount,@FD);
          if (sField = FD.sName) then
             Result := iCount;
     end;
end;

procedure TImportIntoTableForm.MakeFieldsToImport(const fInputIsLinkGrid : boolean;
                                                  const sTbl,
                                                        sKeyField,
                                                        sFieldToImport,
                                                        sFieldDestName : string);
var
   iCount, iFieldIndex, iSize, iInitCount, iValue : integer;
   rValue : extended;
   sValue : str254_T;
   FTI : FieldToImport_T;
   FD : FieldDataType_T;
   TypeInfo, FieldSize : Array_t;
   SourceChild : TMDIChild;
begin
     // create and initialise extra fields in this array (one for each field)
     // store each one using the correct type and size, store the name also
     try
        // we must store each field as integer, extended or str254_T in its own array
        // and also remember the size so we can create new fields appropriately
        // go through each of the features in LinkGrid,
        // LinkGrid.Cells[0,x] is 'Field'
        // LinkGrid.Cells[1,x] is 'New Field Name'
        // LinkGrid.Cells[1,x] is 'Table Name'
        // LinkGrid.Cells[2,x] is 'Key Field'
        // LinkGrid.Cells[3,x] is 'Path'
        // where x goes from 1 to LinkGrid.RowCount-1
        //
        // read their type etc. and add them to the array
        // create and initialise an array of values for each unit of fields to import

        // we must have the ability to read from inputs from passed parameters as well as LinkGrid
        if fInputIsLinkGrid then
        begin
             // read input parameters from the link grid

             FieldsToImport := Array_t.Create;
             FieldsToImport.init(SizeOf(FTI),LinkGrid.RowCount-1);
             for iCount := 1 to (LinkGrid.RowCount-1) do
             begin
                  FTI.sName := LinkGrid.Cells[0,iCount];
                  FTI.sNewName := LinkGrid.Cells[1,iCount];
                  FTI.sTable := LinkGrid.Cells[2,iCount];
                  FTI.sKeyField := LinkGrid.Cells[3,iCount];
                  FTI.sPath := LinkGrid.Cells[4,iCount];

                  ConvertModule.ScanDBaseFileFieldTypes(FTI.sPath + '\' + FTI.sTable,TypeInfo);
                  iFieldIndex := rtnFieldIndex(FTI.sName,TypeInfo);
                  SourceChild := TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(FTI.sPath + '\' + FTI.sTable)]);
                  SourceChild.CountFieldSize(FieldSize);
                  FieldSize.rtnValue(iFieldIndex,@iSize);
                  // set field size
                  FTI.iSize := iSize;
                  TypeInfo.rtnValue(iFieldIndex,@FD);
                  // set field datatype
                  FTI.DBDataType := FD.DBDataType;
                  TypeInfo.Destroy;
                  FieldSize.Destroy;

                  FTI.ArrayOfValues := Array_t.Create;
                  case FTI.DBDataType of
                       DBaseFloat : FTI.ArrayOfValues.init(SizeOf(extended),DestinationSortedKey.lMaxSize);
                       DBaseInt : FTI.ArrayOfValues.init(SizeOf(integer),DestinationSortedKey.lMaxSize);
                       DBaseStr : FTI.ArrayOfValues.init(FTI.iSize + 1,DestinationSortedKey.lMaxSize);
                  end;
                  rValue := 0;
                  iValue := 0;
                  sValue := '';
                  for iInitCount := 1 to DestinationSortedKey.lMaxSize do
                      case FTI.DBDataType of
                           DBaseFloat : FTI.ArrayOfValues.setValue(iInitCount,@rValue);
                           DBaseInt : FTI.ArrayOfValues.setValue(iInitCount,@iValue);
                           DBaseStr : FTI.ArrayOfValues.setValue(iInitCount,@sValue);
                      end;

                  FieldsToImport.setValue(iCount,@FTI);
             end;
        end
        else
        begin
             // read input parameters from the passed parameters
             FieldsToImport := Array_t.Create;
             FieldsToImport.init(SizeOf(FTI),1);
             FTI.sName := sFieldToImport;
             FTI.sNewName := sFieldDestName;
             FTI.sTable := ExtractFileName(sTbl);
             FTI.sKeyField := sKeyField;
             FTI.sPath := TrimTrailingSlashes(ExtractFilePath(sTbl));
             // read iSize and DBDataType from the child containing this table
             ConvertModule.ScanDBaseFileFieldTypes(FTI.sPath + '\' + FTI.sTable,TypeInfo);
             iFieldIndex := rtnFieldIndex(FTI.sName,TypeInfo);
             SourceChild := TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(FTI.sPath + '\' + FTI.sTable)]);
             SourceChild.CountFieldSize(FieldSize);
             FieldSize.rtnValue(iFieldIndex,@iSize);
             FTI.iSize := iSize;
             TypeInfo.rtnValue(iFieldIndex,@FD);
             FTI.DBDataType := FD.DBDataType;
             TypeInfo.Destroy;
             FieldSize.Destroy;

             FTI.ArrayOfValues := Array_t.Create;
             case FTI.DBDataType of
                  DBaseFloat : FTI.ArrayOfValues.init(SizeOf(extended),DestinationSortedKey.lMaxSize);
                  DBaseInt : FTI.ArrayOfValues.init(SizeOf(integer),DestinationSortedKey.lMaxSize);
                  DBaseStr : FTI.ArrayOfValues.init(FTI.iSize + 1,DestinationSortedKey.lMaxSize);
             end;
             rValue := 0;
             iValue := 0;
             sValue := '';
             for iInitCount := 1 to DestinationSortedKey.lMaxSize do
                 case FTI.DBDataType of
                      DBaseFloat : FTI.ArrayOfValues.setValue(iInitCount,@rValue);
                      DBaseInt : FTI.ArrayOfValues.setValue(iInitCount,@iValue);
                      DBaseStr : FTI.ArrayOfValues.setValue(iInitCount,@sValue);
                 end;
             FieldsToImport.setValue(1,@FTI);
             // creating FieldsToImport
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in MakeFieldsToImport',mtError,[mbOk],0);
     end;
end;

procedure TImportIntoTableForm.FreeFieldsToImport;
var
   iCount : integer;
   FTI : FieldToImport_T;
begin
     try
        // free each of the arrays stored in FieldsToImport
        for iCount := 1 to FieldsToImport.lMaxSize do
        begin
             FieldsToImport.rtnValue(iCount,@FTI);
             FTI.ArrayOfValues.Destroy;
        end;

        FieldsToImport.Destroy;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in FreeFieldsToImport',mtError,[mbOk],0);
     end;
end;


procedure TImportIntoTableForm.AddExtraDestinationFields(const sDestTbl : string);
var
   iCount, iFieldsToAdd, iFieldCount : integer;
   FTI : FieldToImport_T;
   fTableContainsField : boolean;
begin
     try
        // iterate through the fields to import, checking if each one isn't present in the
        // destination table, and adding it to the SQL query to add to the table
        // Finally, execute the SQL query if adding 1 or more fields
        ConvertModule.Query1.SQL.Clear;
        ConvertModule.Query1.SQL.Add('ALTER TABLE "' + sDestTbl + '"');
        iFieldsToAdd := 0;
        // use ConvertModule.Table1 to look at the fields of the table specified
        ConvertModule.Table1.DatabaseName := TrimTrailingSlashes(ExtractFilePath(sDestTbl));
        ConvertModule.Table1.TableName := ExtractFileName(sDestTbl);
        ConvertModule.Table1.Open;
        for iCount := 1 to FieldsToImport.lMaxSize do
        begin
             FieldsToImport.rtnValue(iCount,@FTI);
             if (FTI.iSize < 1) then
                FTI.iSize := 1;
             // is FTI.sName one of the fields in the destination table ?
             fTableContainsField := False;
             for iFieldCount := 1 to ConvertModule.Table1.FieldDefs.Count do
                 if (FTI.sNewName = ConvertModule.Table1.FieldDefs.Items[iFieldCount-1].Name) then
                    fTableContainsField := True;
             if not fTableContainsField then
             begin
                  Inc(iFieldsToAdd);
                  if (iFieldsToAdd > 1) then
                     ConvertModule.Query1.SQL.Add(',');
                  case FTI.DBDataType of
                       DBaseFloat : ConvertModule.Query1.SQL.Add('ADD ' + FTI.sNewName + ' NUMERIC(10,5)');
                       // try using FTI.iSize instead of 10 above, and see if this works correctly
                       DBaseInt :   ConvertModule.Query1.SQL.Add('ADD ' + FTI.sNewName + ' NUMERIC(' + IntToStr(FTI.iSize) + ',0)');
                       DBaseStr :   ConvertModule.Query1.SQL.Add('ADD ' + FTI.sNewName + ' CHAR(' + IntToStr(FTI.iSize) + ')');
                  end;
             end;
        end;
        ConvertModule.Table1.Close;
        if (iFieldsToAdd > 0) then
        begin
             ConvertModule.Query1.Prepare;
             ConvertModule.Query1.ExecSQL;
        end;

     except
           ConvertModule.Query1.SQL.SaveToFile('error_in_SQL.sql');
           Screen.Cursor := crDefault;
           MessageDlg('Exception in AddExtraDestinationFields',mtError,[mbOk],0);
     end;
end;



procedure TImportIntoTableForm.DumpFieldsToImport(const sFilename, sDelimiter : string);
var
   iCount, iRow, iDestinationRow, iValue, iFieldCount : integer;
   rValue : extended;
   FTI : FieldToImport_T;
   SourceChild : TMDIChild;
   sSourceKeyValue, sSourceValue, sDestinationKey : str254_T;
   OutFile : TextFile;
begin
     try
        assignfile(OutFile,sFilename);
        rewrite(OutFile);
        // write the field names as the first row of the file
        write(OutFile,'rowkey');
        for iCount := 1 to FieldsToImport.lMaxSize do
        begin
             FieldsToImport.rtnValue(iCount,@FTI);
             write(OutFile,sDelimiter + FTI.sName);
        end;
        writeln(OutFile);

        // go through each row of the sorted destination table
        // write the field value(s) for that row to the file
        for iCount := 1 to DestinationSortedKey.lMaxSize do
        begin
             DestinationSortedKey.rtnValue(iCount,@sDestinationKey);
             write(OutFile,sDestinationKey);

             for iFieldCount := 1 to FieldsToImport.lMaxSize do
             begin
                  FieldsToImport.rtnValue(iFieldCount,@FTI);
                  SourceChild := TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(FTI.sPath + '\' + FTI.sTable)]);

                  case FTI.DBDataType of
                       DBaseFloat : begin
                                         FTI.ArrayOfValues.rtnValue(iCount,@rValue);
                                         sSourceValue := FloatToStr(rValue);
                                    end;
                       DBaseInt : begin
                                       FTI.ArrayOfValues.rtnValue(iCount,@iValue);
                                       sSourceValue := IntToStr(iValue);
                                  end;
                       DBaseStr : FTI.ArrayOfValues.rtnValue(iCount,@sSourceValue);
                  end;
                  write(OutFile,sDelimiter + sSourceValue);
             end;
             writeln(OutFile);
        end;
        closefile(OutFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DumpFieldsToImport',mtError,[mbOk],0);
     end;
end;

procedure TImportIntoTableForm.ParseFieldsToImport;
var
   iCount, iRow, iDestinationRow, iValue : integer;
   rValue : extended;
   FTI : FieldToImport_T;
   SourceChild : TMDIChild;
   sSourceKeyValue, sSourceValue, sTestKey : str254_T;
begin
     try
        for iCount := 1 to FieldsToImport.lMaxSize do
        begin
             FieldsToImport.rtnValue(iCount,@FTI);
             SourceChild := TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(FTI.sPath + '\' + FTI.sTable)]);

             SourceChild.DBGrid1.Visible := False;
             SourceChild.Query1.First;
             iRow := 0;
             repeat
                   Inc(iRow);
                   sSourceKeyValue := SourceChild.Query1.FieldByName(FTI.sKeyField).AsString;
                   // if sSourceKeyValue matches a record in DestinationSortedKey
                   //   store sSourceValue as appropriate type (FTI.DBDataType)
                   //   in appropriate element of FTI.ArrayOfValues
                   iDestinationRow := findStrMatch(DestinationSortedKey,sSourceKeyValue);
                   if (iDestinationRow > -1) then
                   begin
                        DestinationSortedKey.rtnValue(iDestinationRow,@sTestKey);
                        if (sTestKey = sSourceKeyValue) then
                           case FTI.DBDataType of
                                DBaseFloat : begin
                                                  try
                                                     rValue := StrToFloat(SourceChild.Query1.FieldByName(FTI.sName).AsString);
                                                  except
                                                        rValue := 0;
                                                  end;
                                                  FTI.ArrayOfValues.setValue(iDestinationRow,@rValue);
                                             end;
                                DBaseInt : begin
                                                try
                                                   iValue := StrToInt(SourceChild.Query1.FieldByName(FTI.sName).AsString);
                                                except
                                                      iValue := 0;
                                                end;
                                                FTI.ArrayOfValues.setValue(iDestinationRow,@iValue);
                                           end;
                                DBaseStr : begin
                                                sSourceValue := SourceChild.Query1.FieldByName(FTI.sName).AsString;
                                                FTI.ArrayOfValues.setValue(iDestinationRow,@sSourceValue);
                                           end;
                           end;
                   end;
                   SourceChild.Query1.Next;

             until SourceChild.Query1.Eof;
             SourceChild.Query1.First;
             SourceChild.DBGrid1.Visible := True;

             // examine each line of the query
             //   if its key value matches an index in DestinationSortedKey
             //     pull out the data value for field FTI.sName from SourceChild.Query1
             //     store it in the array FTI.ArrayOfValues
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ParseFieldsToImport',mtError,[mbOk],0);
     end;
end;

procedure TImportIntoTableForm.ParseDestinationTable(const sDestTbl, sDestKey : string);
var
   iRowIndex, iValue, iCount : integer;
   rValue : extended;
   sKeyValue, sValue : str254_T;
   FTI : FieldToImport_T;
begin
     // parse the destination table
     // for each row
     //   look up index in DestinationSortedKey
     //   write field value(s) from FieldsToImport
     try
        ConvertModule.Table1.DatabaseName := TrimTrailingSlashes(ExtractFilePath(sDestTbl));
        ConvertModule.Table1.TableName := ExtractFileName(sDestTbl);

        ConvertModule.Table1.Open;

        repeat
              // read the value for the key field and look up this row in DestinationSortedKey
              sKeyValue := ConvertModule.Table1.FieldByName(sDestKey).AsString;
              iRowIndex := findStrMatch(DestinationSortedKey,sKeyValue);

              ConvertModule.Table1.Edit;
              for iCount := 1 to FieldsToImport.lMaxSize do
              begin
                   FieldsToImport.rtnValue(iCount,@FTI);

                   case FTI.DBDataType of
                        DBaseFloat : begin
                                          FTI.ArrayOfValues.rtnValue(iRowIndex,@rValue);
                                          sValue := FloatToStr(rValue);
                                     end;
                        DBaseInt   : begin
                                          FTI.ArrayOfValues.rtnValue(iRowIndex,@iValue);
                                          sValue := IntToStr(iValue);
                                     end;
                        DBaseStr   : FTI.ArrayOfValues.rtnValue(iRowIndex,@sValue);
                   end;

                   ConvertModule.Table1.FieldByName(FTI.sNewName).AsString := sValue;
              end;

              ConvertModule.Table1.Next

        until ConvertModule.Table1.Eof;

        ConvertModule.Table1.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ParseDestinationTable',mtError,[mbOk],0);
     end;
end;

procedure TImportIntoTableForm.ImportSingleFieldIntoTable(const sDestinationTbl,
                                                                sDestinationKey,
                                                                sDestinationField,
                                                                sSourceTbl,
                                                                sSourceKey,
                                                                sSourceField : string);
begin
     //
     try
        MakeDestinationLookupArray(sDestinationTbl,sDestinationKey);
        MakeFieldsToImport(False,sSourceTbl,sSourceKey,sSourceField,sDestinationField);
        ParseFieldsToImport;
        AddExtraDestinationFields(sDestinationTbl);
        ParseDestinationTable(sDestinationTbl,sDestinationKey);
        DestinationLookupArray.Destroy;
        DestinationSortedKey.Destroy;
        FreeFieldsToImport;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ImportSingleFieldIntoTable',mtError,[mbOk],0);
     end;
end;

procedure TImportIntoTableForm.ImportIntoTable;
begin
     //
     try
        // make a lookup array for the destination table
        MakeDestinationLookupArray(sDestinationTable,ComboDestinationKey.Text);

        // create and initialise extra fields in this array (one for each field)
        // store each one using the correct type and size, store the name also
        MakeFieldsToImport(True,'','','','');

        // parse each field of the source table(s) seperately, writing cell values to the arrays
        // the purpose of parsing each field seperately is to
        //   a) deal with the case where a table is specified more that once to prevent duplicate memory objects
        //   b) simplify the instructions so as to minimise complexity/room for error & maximise reliability
        ParseFieldsToImport;

        // do a debug dump of the contents of fields to import
        //DumpFieldsToImport('c:\dump_fields_to_import.csv',',');

        // HOW to resolve, case where user only loaded a subset of fields because
        // this same subset of fields needs to be used to refresh destination table below
        // drop existing fields from the destination table if their type needs to be changed
        // add extra fields to the destination table if necessary
        AddExtraDestinationFields(sDestinationTable);
        // parse the destination table, writing the contents of the extra fields
        // added to the lookup array
        ParseDestinationTable(sDestinationTable,ComboDestinationKey.Text);

        // dispose of lookup array and extra fields
        DestinationLookupArray.Destroy;
        DestinationSortedKey.Destroy;
        FreeFieldsToImport;

        // refresh the destination table which may have had fields added
        DestinationChild.Free;
        MainForm.CreateMDIChild(sDestinationTable,'',False);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ImportIntoTable',mtError,[mbOk],0);
     end;
end;

procedure TImportIntoTableForm.AvailableTablesGridClick(Sender: TObject);
var
   iCount : integer;
   //ClickDestinationChild : TMDIChild;
begin
     // display the fields from the table that has been selected
     ClickSourceChild := TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(AvailableTablesGrid.Cells[2,AvailableTablesGrid.Selection.Top] + '\' + AvailableTablesGrid.Cells[0,AvailableTablesGrid.Selection.Top])]);

     LabelAvailableTable.Caption := 'Table   ' + AvailableTablesGrid.Cells[0,AvailableTablesGrid.Selection.Top];

     ComboDestinationKey.Items.Clear;
     ComboDestinationKey.Text := ClickSourceChild.Query1.FieldDefs.Items[0].Name;
     WipePreviousKey(AvailableTablesGrid);
     AvailableTablesGrid.Cells[1,AvailableTablesGrid.Selection.Top] := ComboDestinationKey.Text;
     for iCount := 0 to (ClickSourceChild.Query1.FieldDefs.Count - 1) do
         ComboDestinationKey.Items.Add(ClickSourceChild.Query1.FieldDefs.Items[iCount].Name);

     btnNext.Enabled := True;
end;

procedure TImportIntoTableForm.SourceTablesGridClick(Sender: TObject);
var
   iCount : integer;
begin
     ClickSourceChild := TMDIChild(MainForm.MDIChildren[MainForm.ReturnChildIndex(SourceTablesGrid.Cells[2,SourceTablesGrid.Selection.Top] + '\' + SourceTablesGrid.Cells[0,SourceTablesGrid.Selection.Top])]);

     ComboField.Items.Clear;
     ComboSourceKey.Items.Clear;
     ComboField.Text := ClickSourceChild.Query1.FieldDefs.Items[0].Name;
     EditNewName.Text := ComboField.Text;
     ComboSourceKey.Text := ComboField.Text;
     WipePreviousKey(SourceTablesGrid);
     SourceTablesGrid.Cells[1,SourceTablesGrid.Selection.Top] := ComboSourceKey.Text;
     for iCount := 0 to (ClickSourceChild.Query1.FieldDefs.Count - 1) do
     begin
          ComboField.Items.Add(ClickSourceChild.Query1.FieldDefs.Items[iCount].Name);
          ComboSourceKey.Items.Add(ClickSourceChild.Query1.FieldDefs.Items[iCount].Name);
     end;
     LabelSourceTable.Caption := 'Table   ' + SourceTablesGrid.Cells[0,SourceTablesGrid.Selection.Top];
end;

procedure TImportIntoTableForm.Button36Click(Sender: TObject);
begin
     // browse another table
     MainForm.FileOpenItemClick(Sender);
     // reset table list
     //ListAvailableTables;
     //ListSourceTables(DestinationChild.sFilename);
     ListSourceTables(sDestinationTable);
     PrepareLinkGrid;
     PrepareComboField;

end;







procedure TImportIntoTableForm.ComboFieldClick(Sender: TObject);
begin
     EditNewName.Text := ComboField.Text;
end;

procedure TImportIntoTableForm.EditNewNameChange(Sender: TObject);
begin (*
     // if the text is not blank
     if (EditNewName.Text <> '') then
        // if the text is not the same as ComboField.Text
        // ie. if the user has changed the text
        if (EditNewName.Text <> ComboField.Text) then
        begin
             // if the text is not a valid dbase name
             // or if the text is a local sql reserve word
             if not IsDBaseFieldNameValid(EditNewName.Text)
             or IsLocalSQLReserveWord(EditNewName.Text) then
             begin
                  // field name entered by user is invalid
                  // display a message to the user
                  MessageDlg('"' + EditNewName.Text + '" is not a valid dBase field name',mtInformation,[mbOk],0);
                  // change field name back to default
                  EditNewName.Text := ComboField.Text
             end;
        end; *)
end;

procedure WipePreviousKey(AGrid : TStringGrid);
var
   iCount : integer;
begin
     if (AGrid.RowCount > 1) then
        for iCount := 1 to (AGrid.RowCount-1) do
            AGrid.Cells[1,iCount] := '';
end;

procedure TImportIntoTableForm.ComboDestinationKeyChange(Sender: TObject);
begin
     // wipe previous tables key field setting
     WipePreviousKey(AvailableTablesGrid);
     AvailableTablesGrid.Cells[1,AvailableTablesGrid.Selection.Top] := ComboDestinationKey.Text;
     AutoFitGrid(AvailableTablesGrid,Canvas,True);
end;

procedure TImportIntoTableForm.ComboSourceKeyChange(Sender: TObject);
begin
     WipePreviousKey(SourceTablesGrid);
     SourceTablesGrid.Cells[1,SourceTablesGrid.Selection.Top] := ComboSourceKey.Text;
     AutoFitGrid(SourceTablesGrid,Canvas,True);
end;

end.
