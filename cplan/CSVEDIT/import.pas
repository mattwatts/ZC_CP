unit import;

{$UNDEF REPORT_TIME}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Gauges, Buttons, Spin, StdCtrls, ExtCtrls, Grids, ds;

const
     MAXINPUTTABLES = 1000;
     MAXINPUTCOLUMNS = 1000;

type
  TImportDataFieldForm = class(TForm)
    Notebook1: TNotebook;
    Label1: TLabel;
    Label2: TLabel;
    btnNext: TButton;
    BitBtn1: TBitBtn;
    UpdateTblBox: TListBox;
    Label32: TLabel;
    Button27: TButton;
    Button28: TButton;
    BitBtn16: TBitBtn;
    Label40: TLabel;
    Label41: TLabel;
    Button31: TButton;
    BitBtn18: TBitBtn;
    NameTableBox: TListBox;
    Button32: TButton;
    Label20: TLabel;
    Label21: TLabel;
    BitBtn11: TBitBtn;
    Button1: TButton;
    btnOk: TBitBtn;
    Gauge1: TGauge;
    LabelProgress: TLabel;
    Label7: TLabel;
    AvailTblBox: TListBox;
    SpeedButton5: TSpeedButton;
    SelAllTbl: TSpeedButton;
    Label42: TLabel;
    ComboField: TComboBox;
    LinkGrid: TStringGrid;
    Label33: TLabel;
    Label34: TLabel;
    ConvertGrid: TStringGrid;
    Label10: TLabel;
    EditMult: TEdit;
    Label11: TLabel;
    ComboFrom: TComboBox;
    Label12: TLabel;
    ComboTo: TComboBox;
    EditName: TEdit;
    Label3: TLabel;
    btnBrowse: TButton;
    Button36: TButton;
    btnAddEntireTable: TSpeedButton;
    btnNoConvert: TButton;
    procedure UpdateTblBoxClick(Sender: TObject);
    procedure Button27Click(Sender: TObject);
    procedure Button28Click(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure Button32Click(Sender: TObject);
    procedure Button31Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AvailTblBoxClick(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SelAllTblClick(Sender: TObject);
    procedure EditMultChange(Sender: TObject);
    procedure ComboToChange(Sender: TObject);
    procedure ComboFromChange(Sender: TObject);
    procedure ConvertGridSelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    procedure EditNameChange(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure ExecImportDataField;
    procedure LinkGridSelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    procedure SaveWizardSpecification(const sSpecFile : string);
    procedure btnAddEntireTableClick(Sender: TObject);
    procedure btnNoConvertClick(Sender: TObject);
  private
    { Private declarations }
    procedure ListInputTables(var InputTables : Array_t);
    function BrowseTable : boolean;
  public
    { Public declarations }
  end;

var
  ImportDataFieldForm: TImportDataFieldForm;
  fSelectingCell : boolean;

implementation

uses
    MAIN, Childwin, impexp, tparse,
    global, xdata, fldadd, trpt, userkey, loadtype,
    FileCtrl;

{$R *.DFM}

function SaveDestinationTable(const AFile : TextFile) : boolean;
var
   sChild : string;
begin
     with ImportDataFieldForm do
     begin
          sChild := UpdateTblBox.Items.Strings[UpdateTblBox.ItemIndex];
          writeln(AFile,'[Destination]');
          writeln(AFile,'Table=' + sChild);
          writeln(AFile,'Key=' + SCPForm.rtnChildKey(sChild));
          writeln(AFile,'Type=' + SCPForm.rtnChildType(sChild));
     end;
end;

function SaveInputCriteria(const AFile : TextFile) : boolean;
var
   sChild : string;
   iCount : integer;
begin
     with ImportDataFieldForm do
     begin
          writeln(AFile,'[Input]');
          for iCount := 1 to (ConvertGrid.RowCount-1) do
          begin
               sChild := LinkGrid.Cells[0,iCount];
               writeln(AFile,'Table=' + sChild);
               writeln(AFile,'Key=' + SCPForm.rtnChildKey(sChild));
               writeln(AFile,'Type=' + SCPForm.rtnChildType(sChild));
               writeln(AFile,'Field=' + LinkGrid.Cells[1,iCount]);
               writeln(AFile,'NewFieldName=' + ConvertGrid.Cells[1,iCount]);
               writeln(AFile,'ConvertFactor=' + ConvertGrid.Cells[2,iCount]);
          end;
     end;
end;


procedure TImportDataFieldForm.SaveWizardSpecification(const sSpecFile : string);
var
   OutFile : TextFile;
begin
     try
        {}
        assignfile(OutFile,sSpecFile);
        rewrite(OutFile);

        // write wizard spec header
        writeln(OutFile,'[C-Plan Import Data Field Wizard Specification File]');
        writeln(OutFile,'Date=' + FormatDateTime('dddd," "mmmm d, yyyy',Now));
        writeln(OutFile,'Time=' + FormatDateTime('hh:mm AM/PM', Now));
        writeln(OutFile,'CPlanVersion=');
        writeln(OutFile,'');

        // write Destination settings
        SaveDestinationTable(OutFile);
        writeln(OutFile,'');

        // write input criteria for the fields we are importing
        SaveInputCriteria(OutFile);

        closefile(OutFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TImportDataFieldForm.SaveWizardSpecification',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;



function TImportDataFieldForm.BrowseTable : boolean;
var
   wResult : word;
   TablesAdded : Array_t;
   sStr : str255;

   procedure AddTables;
   var
      iCount : integer;
      AChild : TMDIChild;
   begin
        Result := True;

        for iCount := 1 to TablesAdded.lMaxSize do
        begin
             TablesAdded.rtnValue(iCount,@sStr);
             UpdateTblBox.Items.Add(sStr);
             AvailTblBox.Items.Add(sStr);
             {get user to select key field for this table}
             AChild := SCPForm.rtnChild(sStr);
             SelectKeyForm := TSelectKeyForm.Create(Application);
             SelectKeyForm.initChild(sStr);
             SelectKeyForm.ShowModal;
             SelectKeyForm.Free;
        end;
   end;
begin
     {}
     try
        Result := False;

        LoadTypeForm := TLoadTypeForm.Create(Application);
        if (LoadTypeForm.ShowModal = mrOk) then
        begin
             if LoadTypeForm.RadioButtonLink.Checked then
             begin
                  {search and link a file}
                  TablesAdded := SCPForm.LinkQuery;
                  if (TablesAdded.lMaxSize > 0) then
                     {add these tables to our table selection list(s)}
                     AddTables;
                  TablesAdded.Destroy;
             end
             else
             begin
                  {search and load a file}
                  TablesAdded := SCPForm.LoadQuery;
                  if (TablesAdded.lMaxSize > 0) then
                     {add these tables to our table selection list(s)}
                     AddTables;
                  TablesAdded.Destroy;
             end;
        end;

        LoadTypeForm.Free;

        (*wResult := MessageDlg('Do you want to link the table instead of loading it to the grid',
                              mtConfirmation,
                              [mbYes,mbNo,mbCancel],
                              0);

        case wResult of
             mrYes :
             begin
                  {search and link a file}
                  TablesAdded := SCPForm.LinkQuery;
                  if (TablesAdded.lMaxSize > 0) then
                     {add these tables to our table selection list(s)}
                     AddTables;
                  TablesAdded.Destroy;
             end;
             mrNo :
             begin
                  {search and load a file}
                  TablesAdded := SCPForm.LoadQuery;
                  if (TablesAdded.lMaxSize > 0) then
                     {add these tables to our table selection list(s)}
                     AddTables;
                  TablesAdded.Destroy;
             end;
        end;*)

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TImportDataFieldForm.BrowseTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TImportDataFieldForm.UpdateTblBoxClick(Sender: TObject);
begin
     btnNext.Enabled := True;
     UpdateTblBox.Hint := UpdateTblBox.Items.Strings[UpdateTblBox.ItemIndex];
end;

procedure TImportDataFieldForm.Button27Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex - 1;
end;

procedure TImportDataFieldForm.Button28Click(Sender: TObject);
var
   iCount : integer;
begin
     {prepare grid on 'enter names and conversion factors of fields' page}
     ConvertGrid.RowCount := LinkGrid.RowCount;
     for iCount := 1 to (LinkGrid.RowCount - 1) do
     begin
          ConvertGrid.Cells[0,iCount] := LinkGrid.Cells[1,iCount];
          ConvertGrid.Cells[1,iCount] := LinkGrid.Cells[1,iCount];
     end;

     Notebook1.PageIndex := Notebook1.PageIndex + 1;
end;

procedure TImportDataFieldForm.btnNextClick(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex + 1;
end;

procedure TImportDataFieldForm.Button32Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex - 1;
end;

procedure TImportDataFieldForm.Button31Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex + 1;
end;

procedure TImportDataFieldForm.Button1Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex - 1;
end;

procedure TImportDataFieldForm.FormCreate(Sender: TObject);
var
   iCount : integer;
   AChild : TMDIChild;
begin
     fSelectingCell := False;

     Notebook1.PageIndex := 0;

     ClientWidth := BitBtn1.Left + BitBtn1.Width + 14;
     ClientHeight := BitBtn1.Top + BitBtn1.Height + 8;

     UpdateTblBox.Items.Clear;
     AvailTblBox.Items.Clear;

     {prepare first page of notebook}
     {add available tables to listbox so user can choose which table contains
      the matrix data}
     with SCPForm do
          if (MDIChildCount > 0) then
             for iCount := 0 to (MDIChildCount-1) do
             begin
                  AvailTblBox.Items.Add(MDIChildren[iCount].Caption);
                  UpdateTblBox.Items.Add(MDIChildren[iCount].Caption);
             end;
                 (*if (TMDIChild(MDIChildren[iCount]).CheckLoadFileData.Checked) then
                 begin
                      // only allow loaded children as input
                      AvailTblBox.Items.Add(MDIChildren[iCount].Caption);
                 end
                 else
                 begin
                      // table to add data to must be linked DBF
                      if (LowerCase(ExtractFileExt(MDIChildren[iCount].Caption)) = '.dbf') then
                         UpdateTblBox.Items.Add(MDIChildren[iCount].Caption);
                 end;*)

     LinkGrid.Cells[0,0] := 'Table';
     LinkGrid.Cells[1,0] := 'Field';
     ConvertGrid.Cells[0,0] := 'Field';
     ConvertGrid.Cells[1,0] := 'New Name';
     ConvertGrid.Cells[2,0] := 'Conversion Factor';
end;

procedure TImportDataFieldForm.AvailTblBoxClick(Sender: TObject);
var
   iChildId, iCount : integer;
   Child : TMDIChild;
begin
     {load fields from the selected table into the Select AREA Field drop down
      list
      note: fields are first row of grid containing selected table}

     ComboField.Items.Clear;
     ComboField.Text := '';

     iChildId := SCPForm.rtnTableId(AvailTblBox.Items.Strings[AvailTblBox.ItemIndex]);
     Child := TMDIChild(SCPForm.MDIChildren[iChildId]);
     for iCount := 0 to (Child.aGrid.ColCount - 1) do
         ComboField.Items.Add(Child.aGrid.Cells[iCount,0]);

     AvailTblBox.Hint := AvailTblBox.Items.Strings[AvailTblBox.ItemIndex];
end;

procedure TImportDataFieldForm.SpeedButton5Click(Sender: TObject);
begin
     if (ComboField.Text <> '') then
     begin
          {add row to grid if first row is not blank}
          if (LinkGrid.Cells[0,1] <> '') then
             LinkGrid.RowCount := LinkGrid.RowCount + 1;

          {add this table and field to the Grid}
          LinkGrid.Cells[0,LinkGrid.RowCount - 1] := AvailTblBox.Items.Strings[AvailTblBox.ItemIndex];
          LinkGrid.Cells[1,LinkGrid.RowCount - 1] := ComboField.Text;

          Button28.Enabled := True; {enable next button}
     end;
end;

procedure TImportDataFieldForm.SelAllTblClick(Sender: TObject);
var
   iTop, iBottom, iCount : integer;
begin
     {remove selected element from list (if there is one)}
     iTop := LinkGrid.Selection.Top;
     iBottom := LinkGrid.Selection.Bottom;
     if (LinkGrid.RowCount = 2) then
     begin
          {there is only 1 additional row in the grid}
          LinkGrid.Cells[0,1] := '';
          LinkGrid.Cells[1,1] := '';
          Button28.Enabled := False; {disable next button}
     end
     else
     begin
          {copy rows from last row up 1 row}
          if (iTop < LinkGrid.RowCount) then
             for iCount := iTop to (LinkGrid.RowCount - 1) do
             begin
                  LinkGrid.Cells[0,iCount] := LinkGrid.Cells[0,iCount + 1];
                  LinkGrid.Cells[1,iCount] := LinkGrid.Cells[1,iCount + 1];
             end;

          {remove last additional row in the grid}
          LinkGrid.RowCount := LinkGrid.RowCount - 1;
     end;

     {disable next button if there are now no fields in the grid}
end;


procedure TImportDataFieldForm.EditMultChange(Sender: TObject);
var
   rValue : real;
begin
     if not fSelectingCell then
        if (EditMult.Text <> '')
        and (EditMult.Text <> '.')
        and (EditMult.Text <> '-') then
           {test edit box contains a number}
           try
              rValue := StrToFloat(EditMult.Text);

              {write this value to highlighted table}
              ConvertGrid.Cells[2,ConvertGrid.Selection.Top] := EditMult.Text;

           except
                 MessageDlg('Value must be a number',mtInformation,[mbOk],0);
                 EditMult.Text := '';
           end;
end;

procedure TImportDataFieldForm.ComboToChange(Sender: TObject);
begin
     rtnConversionChange(ComboFrom,ComboTo,EditMult);
end;

procedure TImportDataFieldForm.ComboFromChange(Sender: TObject);
begin
     rtnConversionChange(ComboFrom,ComboTo,EditMult);
end;

procedure TImportDataFieldForm.ConvertGridSelectCell(Sender: TObject; Col,
  Row: Integer; var CanSelect: Boolean);
begin
     fSelectingCell := True;

     {make sure we have only one row and column currently selected so
      we can be sure we are writing to the correct cell when we
      update cell values}
     if (ConvertGrid.Selection.Top = ConvertGrid.Selection.Bottom)
     and (ConvertGrid.Selection.Left = ConvertGrid.Selection.Right) then
     begin
          {enable either 'Conversion Factor' or 'New Name' selection components,
           depending upon which column has been clicked on}
          if (Col = 1) then
          begin
               {edit New Name}
               Label10.Caption := 'New Name:';

               EditName.Text := ConvertGrid.Cells[Col,Row];
               EditName.Visible := True;

               EditMult.Visible := False;
               Label11.Visible := False;
               ComboFrom.Visible := False;
               Label12.Visible := False;
               ComboTo.Visible := False;
               btnNoConvert.Visible := False;
          end
          else
          begin
               {edit Conversion Factor}
               Label10.Caption := 'Conversion Factor:';

               EditMult.Text := ConvertGrid.Cells[Col,Row];
               EditMult.Visible := True;
               Label11.Visible := True;
               ComboFrom.Visible := True;
               Label12.Visible := True;
               ComboTo.Visible := True;
               btnNoConvert.Visible := True;

               EditName.Visible := False;
          end;

          ConvertGrid.Hint := ConvertGrid.Cells[Col,Row];
     end;

     fSelectingCell := False;
end;

procedure TImportDataFieldForm.EditNameChange(Sender: TObject);
begin
     {make sure we have only one row and column currently selected so
      we can be sure we are writing to the correct cell when we
      update cell values}
     if not fSelectingCell then
        if (ConvertGrid.Selection.Top = ConvertGrid.Selection.Bottom)
        and (ConvertGrid.Selection.Left = ConvertGrid.Selection.Right) then
            ConvertGrid.Cells[1,
                              ConvertGrid.Selection.Top] := EditName.Text;
end;

procedure TImportDataFieldForm.ListInputTables(var InputTables : Array_t);
var
   iCount, iListSize : integer;
   sTable, sValue : string[255];

   procedure AddElement;
   var
      iLoop : integer;
      fAlreadyHaveIt : boolean;
   begin
        {see if we already have this table in the list}
        fAlreadyHaveIt := False;
        for iLoop := 1 to iListSize do
        begin
             InputTables.rtnValue(iLoop,@sValue);
             if (sValue = sTable) then
                fAlreadyHaveIt := True;
        end;
        if not fAlreadyHaveIt then
        begin
             Inc(iListSize);
             InputTables.setValue(iListSize,@sTable);
        end;
   end;

begin
     try
        {build array of unique table names from the input field list}

        iListSize := 1;
        InputTables := Array_t.Create;
        InputTables.init(SizeOf(sTable),LinkGrid.RowCount - 1);
        sTable := LinkGrid.Cells[0,1];
        InputTables.setValue(1,@sTable);

        if (LinkGrid.RowCount > 2) then
           for iCount := 2 to (LinkGrid.RowCount - 1) do
           begin
                sTable := LinkGrid.Cells[0,iCount];
                AddElement;
           end;

        if (iListSize < InputTables.lMaxSize) then
           InputTables.resize(iListSize);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in List Input Tables',mtError,[mbOk],0);
           application.terminate;
           exit;
     end;
end;

function rtnKeyArray(aChild : TMDIChild;
                     aParser : TTableParser;
                     const fKeyIsInteger : boolean) : Array_T;
var
   sCell : string[255];
   iCell, iCount : integer;
begin
     try

        Result := Array_T.Create;

        {default type for identifiers is str255, this will work for strings and numbers}
        if fKeyIsInteger then
           Result.init(SizeOf(integer),(aChild.SpinRow.Value-1))
        else
            Result.init(SizeOf(sCell),(aChild.SpinRow.Value-1));
        if aChild.CheckLoadFileData.Checked then
        begin
             {read array from the grid}
             for iCount := 1 to (aChild.SpinRow.Value-1) do
             begin
                  sCell := aChild.aGrid.Cells[aChild.KeyFieldGroup.ItemIndex,iCount];
                  if fKeyIsInteger then
                  begin
                       iCell := StrToInt(sCell);
                       Result.setValue(iCount,@iCell);
                  end
                  else
                      Result.setValue(iCount,@sCell);
             end;
        end
        else
        begin
             {read array from the table parser}

			 // switch off tparse column optimise to speed up reading key field only
			 aParser.fOptimiseColumnAccess := False;

             for iCount := 1 to (aChild.SpinRow.Value-1) do
             begin
                  aParser.seekfile(iCount);
                  sCell := aParser.rtnRowValue(aChild.KeyFieldGroup.ItemIndex);

                  if fKeyIsInteger then
                  begin
                       iCell := StrToInt(sCell);
                       Result.setValue(iCount,@iCell);
                  end
                  else
                      Result.setValue(iCount,@sCell);
             end;

			 //	switch on tparse column optimise to speed up reading multiple fields
			 aParser.fOptimiseColumnAccess := True;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in rtnKeyArray',mtError,[mbOk],0);
     end;
end;


procedure TImportDataFieldForm.btnOkClick(Sender: TObject);
begin
     ExecImportDataField;
end;

function AddColumnsToGrid(aChild : TMDIChild {aGrid : TStringGrid};
                          columnGrid : TStringGrid;
                          tableGrid : TStringGrid;
                          var ColumnArray : Array_t) : boolean;
{we need to determine which of the fields already exist in the grid, and
 which we need to add.  column indexes of fields to add will be the result
 (ie. function will append new columns to the end of the grid, and
      existing columns will have their index within the grid)}
var
   iIndex, iColumn, iCount : integer;
   ChildContainingField : TMDIChild;
   FieldDataType : FieldDataType_T;
begin
     {}
     try
        ColumnArray := Array_t.Create;
        ColumnArray.init(SizeOf(integer),columnGrid.RowCount-1);

        for iCount := 1 to (columnGrid.RowCount-1) do
        begin
             iColumn := aChild.rtnColumnIndex(columnGrid.Cells[1,iCount]);

             if (iColumn = -1) then
             begin
                  {column does not exist in grid}
                  aChild.aGrid.ColCount := aChild.aGrid.ColCount + 1;
                  aChild.aGrid.Cells[aChild.aGrid.ColCount-1,0] := columnGrid.Cells[1,iCount]; {set name of new column}

                  iColumn := aChild.aGrid.ColCount-1;
                  ColumnArray.setValue(iCount,@iColumn);

                  {add type information to the destination child for this column}
                  {find table containing this field, look up column in it and find type}
                  ChildContainingField := SCPForm.rtnChild(tableGrid.Cells[0,iCount]);
                  iIndex := ChildContainingField.KeyFieldGroup.Items.IndexOf(columnGrid.Cells[0,iCount]) + 1;
                  ChildContainingField.DataFieldTypes.rtnValue(iIndex,@FieldDataType);
                  {write type information to child}
                  aChild.DataFieldTypes.resize(aChild.DataFieldTypes.lMaxSize + 1);
                  aChild.DataFieldTypes.setValue(aChild.DataFieldTypes.lMaxSize,@FieldDataType);
             end
             else
             begin
                  {column does exist in grid}
                  ColumnArray.setValue(iCount,@iColumn);
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in AddColumnsToGrid',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


procedure TImportDataFieldForm.ExecImportDataField;
var
   iCount,
   iRow, iInputRow, iTable, iField : integer;
   DestinationChild : TMDIChild;
   DestinationParser : TTableParser;
   InputTables, InputKeys, ColumnArray : Array_t;

   InputChildren : array [1..MAXINPUTTABLES] of TMDIChild;
   InputParsers : array [1..MAXINPUTTABLES] of TTableParser;
   InputSearchArrays : array [1..MAXINPUTTABLES] of Array_t;
   sInputTable : string[255];

   ColumnInInputChild : array [1..MAXINPUTCOLUMNS] of integer;

   sTable, sKeyToFind : string;
   iDestinationKeyColumn, iInputRows, iOriginalColumnCount : integer;

   fUseIntegerKey : boolean;
   FieldDataType : FieldDataType_T;

   sOutputPath : string;

   function rtnKeyFromRow(const iRowToReturn : integer) : string;
   begin
        {
         range of values to call : 1..rowsintable-1
         values returned : key value for a row in the table
              (except the header row which is row 0)}

        if DestinationChild.CheckLoadFileData.Checked then
        begin
             {return value from grid cell in the child}
             Result := DestinationChild.aGrid.Cells[iDestinationKeyColumn,iRowToReturn];
        end
        else
        begin
             {seek to row iRowToReturn and return value}
             if (DestinationParser.rtnTableType = CSV) then
                DestinationParser.seekfile(iRowToReturn);
             Result := DestinationParser.rtnRowValue(iDestinationKeyColumn);
        end;
   end;

   procedure SetColumnInInputChild;
   var
      iCount : integer;
      AChild : TMDIChild;
   begin
        {determine source column for each of the tables to import}
        for iCount := 1 to (LinkGrid.RowCount - 1) do
        begin
             AChild := SCPForm.rtnChild(LinkGrid.Cells[0,iCount]);

             ColumnInInputChild[iCount] := AChild.KeyCombo.Items.IndexOf(LinkGrid.Cells[1,iCount]);
        end;
   end;

   procedure WriteCellValue(const iRowInLinkGrid : integer;
                            InputChild : TMDIChild;
                            InputParser : TTableParser;
                            iRowInInputChild,
                            iRowInDestinationChild,
                            iColumnInInputChild : integer;
                            CArray : Array_t);
   var
      {iColumnInInputChild : integer;}
      sValueToWrite, sTmp : string;
      iColToWrite : integer;
   begin
        try
           if InputChild.CheckLoadFileData.Checked then
              {get value from the grid}
              sValueToWrite := InputChild.aGrid.Cells[iColumnInInputChild,iRowInInputChild]
           else
           begin
                {get value from the parser}
                InputParser.seekfile(iRowInInputChild);
                sValueToWrite := InputParser.rtnRowValue(iColumnInInputChild);
           end;

           {apply conversion factor for this cell}
           if (ConvertGrid.Cells[2,iRowInLinkGrid] <> '') then
           try
              sTmp := FloatToStr(StrToFloat(ConvertGrid.Cells[2,iRowInLinkGrid]) * StrToFloat(sValueToWrite));
              sValueToWrite := sTmp;

           except
                 ConvertGrid.Cells[2,iRowInLinkGrid] := '';
           end;

           {write the value to the DestinationChild}
           if DestinationChild.CheckLoadFileData.Checked then
           begin
                {ColumnArray contains index of columns to write to for each field}
                CArray.rtnValue(iRowInLinkGrid,@iColToWrite);
                {write value to the grid}
                DestinationChild.aGrid.Cells[iColToWrite{iRowInLinkGrid + iOriginalColumnCount - 1},
                                             iRowInDestinationChild] := sValueToWrite;
           end
           else
           begin
                {write value to the parser}
                {parser is already on the correct line from a previous call to rtnKeyFromRow}
                DestinationParser.SetCellValue(sValueToWrite,
                                               ConvertGrid.Cells[1,iRowInLinkGrid],
                                               iRowInLinkGrid,
                                               iRowInDestinationChild);
           end;

           {add fields to destination table if necessary which will be in 1 of 3 forms
           1) dbf file
           2) csv file
           3) grid}

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in WriteCellValue',
                         mtError,[mbOk],0);
              Application.Terminate;
              exit;
        end;
   end;

   procedure AddFieldsToDBFTable;
   var
      FieldAdder : TFieldAdder;
      FieldsToAdd : Array_T;
      FieldType : AddFieldType_T; {C or N}
      FieldSpec : FieldSpec_T;
                  {.sName
                   .FieldType : AddFieldType_T;
                   .iDigit1,
                   .iDigit2 : integer;}
      iFieldsAdded, iIndex, iCount : integer;
      ChildContainingField : TMDIChild;

   begin
        try
           FieldAdder := TFieldAdder.Create(Application);
           FieldsToAdd := Array_T.Create;
           FieldsToAdd.init(SizeOf(FieldSpec),LinkGrid.RowCount - 1);
           iFieldsAdded := 0;
           for iCount := 1 to (LinkGrid.RowCount - 1) do
           begin
                FieldSpec.sName := ConvertGrid.Cells[1,iCount];
                //FieldSpec.sPreviousName := ConvertGrid.Cells[0,iCount];

                {check if this field is already present in table}
                if (-1 = DestinationChild.KeyFieldGroup.Items.IndexOf(FieldSpec.sName)) then
                begin
                     {FieldSpec.sName is not an existing field of the table, we must add it}

                     Inc(iFieldsAdded);

                     {find table containing this field, look up column in it and find type}
                     ChildContainingField := SCPForm.rtnChild(LinkGrid.Cells[0,iCount]);
                     iIndex := ChildContainingField.KeyFieldGroup.Items.IndexOf(LinkGrid.Cells[1,iCount]) + 1;
                     ChildContainingField.DataFieldTypes.rtnValue(iIndex,@FieldDataType);
                     case FieldDataType.DBDataType of
                          DBaseInt : begin
                                          FieldSpec.FieldType := N;
                                          FieldSpec.iDigit1 := 10;
                                          FieldSpec.iDigit2 := 0;
                                     end;
                          DBaseFloat : begin
                                          FieldSpec.FieldType := N;
                                          FieldSpec.iDigit1 := 10;
                                          FieldSpec.iDigit2 := 5;
                                       end;
                          DBaseStr : begin
                                          FieldSpec.FieldType := C;
                                          if (FieldDataType.iSize = 0) then
                                             FieldSpec.iDigit1 := 254
                                          else
                                              FieldSpec.iDigit1 := FieldDataType.iSize;
                                          FieldSpec.iDigit2 := 0;
                                     end;
                     end;
                     {set FieldType, iDigit1 and iDigit2 for FieldSpec}

                     FieldsToAdd.setValue(iFieldsAdded,@FieldSpec);
                end;

           end;
           if (iFieldsAdded > 0) then
           begin
                if (iFieldsAdded <> FieldsToAdd.lMaxSize) then
                   FieldsToAdd.resize(iFieldsAdded);

                FieldAdder.AddFieldsToTable(FieldsToAdd,
                                            ExtractFileName(DestinationChild.Caption),
                                            ExtractFilePath(DestinationChild.Caption));
           end;
           FieldsToAdd.Destroy;
           FieldAdder.Free;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in AddFieldsToDBFTable',mtError,[mbOk],0);
        end;
   end;

   function IsChildsKeyInteger(aChild : TMDIChild) : boolean;
   begin
        Result := False;
        aChild.DataFieldTypes.rtnValue((aChild.KeyFieldGroup.ItemIndex + 1),@FieldDataType);
        if (FieldDataType.DBDataType = DBaseInt)
        or (FieldDataType.DBDataType = DBaseFloat) {inserted because type selector is returning float for all numbers in CSV file}
          then
              Result := True;
   end;

begin
     try
        Screen.Cursor := crHourglass;

        {import data field(s) into the table}
        {$IFDEF REPORT_TIME}
        InitTimeReport('d:\iap\test\fldimp');
        {$ENDIF}

        // create specification report for this import before beginning the import
        try
        sOutputPath := ExtractFilePath(UpdateTblBox.Items.Strings[UpdateTblBox.ItemIndex]);
        ForceDirectories(sOutputPath);
        SaveWizardSpecification(rtnUniqueFileName(sOutputPath,'fws'));
        except
              Screen.Cursor := crDefault;
              if (mrNo = MessageDlg('There was an exception saving the specification file' + Chr(10) + Chr(13) +
                                    '(' + sOutputPath + '\autosave.fws)' + Chr(10) + Chr(13) +
                                    'for this data field import.' + Chr(10) + Chr(13) +
                                    'Do you want to continue anyway?',
                                    mtConfirmation,
                                    [mbYes,mbNo],
                                    0)) then
              begin
                   // user has indicated they don't want to continue
                   Application.Terminate;
                   Exit;
              end
              else
                  Screen.Cursor := crHourglass;
        end;

        {init destination table objects}
        DestinationChild := SCPForm.rtnChild(UpdateTblBox.Items.Strings[UpdateTblBox.ItemIndex]);
        iDestinationKeyColumn := DestinationChild.KeyCombo.Items.IndexOf(DestinationChild.KeyCombo.Text);
        iOriginalColumnCount := DestinationChild.aGrid.ColCount;

        fUseIntegerKey := IsChildsKeyInteger(DestinationChild);

        if DestinationChild.CheckLoadFileData.Checked then
        begin
             {we need to determine which of the fields already exist in the grid, and
              which we need to add.  column indexes of fields to add will be the result
              (ie. function will append new columns to the end of the grid, and
                   existing columns will have their index within the grid)}
             AddColumnsToGrid(DestinationChild,
                              ConvertGrid,
                              LinkGrid,
                              ColumnArray);

             {add rows to the grid to contain new data elements}
             {DestinationChild.aGrid.ColCount := DestinationChild.aGrid.ColCount + LinkGrid.RowCount - 1;
             for iCount := 0 to (LinkGrid.RowCount - 2) do
                 DestinationChild.aGrid.Cells[iOriginalColumnCount + iCount,0] := ConvertGrid.Cells[1,iCount + 1];}

             {we need to add types for the fields that are being added to a loaded grid}
        end
        else
        begin
             DestinationParser := TTableParser.Create(Application);
             DestinationParser.initfile(DestinationChild.Caption);

             {if the table is dbf, we need to execute an sql query to add fields to it}
             if (DestinationParser.rtnTableType = DBF) then
             begin
                  DestinationParser.donefile;

                  AddFieldsToDBFTable;

                  DestinationParser.initfile(DestinationChild.Caption);

                  DestinationParser.DBFTable.Edit; {enter edit mode for first record of the database}
             end;

             DestinationParser.initTmpFiles(ExtractFilePath(DestinationChild.Caption),LinkGrid.RowCount - 1);

             if (DestinationParser.rtnTableType = CSV) then
                {write the name of the columns being added to the temporary csv files that have been created}
                for iCount := 0 to (LinkGrid.RowCount - 2) do
                    DestinationParser.setCellValue(ConvertGrid.Cells[1,iCount + 1], {value to write to temp file}
                                                   '',                              {unused}
                                                   iCount + 1,                      {index of temp file to write to}
                                                   0);                              {unused}
        end;
        {}

        {build a list of input tables from the list of fields to import
         note: there can be one or more fields from each input table in the list of fields}
        ListInputTables(InputTables);
        if (InputTables.lMaxSize > MAXINPUTTABLES) then
        begin
             Screen.Cursor := crDefault;
             MessageDlg('You can only input fields from ' + IntToStr(MAXINPUTTABLES) +
                        ' tables at a time with C-Plan',
                        mtError,[mbOk],0);
             application.terminate;
             exit;
        end;

        if (LinkGrid.RowCount >= MAXINPUTCOLUMNS) then
        begin
             Screen.Cursor := crDefault;
             MessageDlg('You can only input ' + IntToStr(MAXINPUTCOLUMNS) +
                        ' fields at a time with C-Plan',
                        mtError,[mbOk],0);
             application.terminate;
             exit;
        end;

        {init input table(s) object(s)}
        for iTable := 1 to InputTables.lMaxSize do
        begin
             InputTables.rtnValue(iTable,@sInputTable);
             InputChildren[iTable] := SCPForm.rtnChild(sInputTable);
             if fUseIntegerKey then
                fUseIntegerKey := IsChildsKeyInteger(InputChildren[iTable]);
        end;

        for iTable := 1 to InputTables.lMaxSize do
        begin
             if not InputChildren[iTable].CheckLoadFileData.Checked then
             begin
                  InputParsers[iTable] := TTableParser.Create(Application);
                  InputParsers[iTable].initfile(sInputTable);
             end;
             InputKeys := rtnKeyArray(InputChildren[iTable], InputParsers[iTable], fUseIntegerKey);
             if fUseIntegerKey then
                InputSearchArrays[iTable] := SortIntegerArray(InputKeys)
             else
                 InputSearchArrays[iTable] := SortStrArray(InputKeys);
             InputKeys.Destroy;
        end;

        {determine source column index for each column to be imported}
        SetColumnInInputChild;

        {$IFDEF REPORT_TIME}
        ReportTime('before main loop');
        {$ENDIF}

        {traverse each row of table to update
           traverse input tables
             if intable contains row
               traverse each field of fields to add
                 if intable contains field
                   convert cell value if necessary
                   write value to destination table}
        for iRow := 1 to (DestinationChild.SpinRow.Value - 1) do
            for iTable := 1 to InputTables.lMaxSize do
            begin
                 {see if iTable contains iRow}
                 InputTables.rtnValue(iTable,@sInputTable);

                 {get the key field for this row of the Destination table}
                 sKeyToFind := rtnKeyFromRow(iRow);

                 {$IFDEF REPORT_TIME}
                 ReportTime(IntToStr(iRow) + ' key found');
                 {$ENDIF}

                 if fUseIntegerKey then
                    iInputRow := FindIntegerMatch(InputSearchArrays[iTable],StrToInt(sKeyToFind))
                 else
                     iInputRow := FindStrMatch(InputSearchArrays[iTable],sKeyToFind);

                 {$IFDEF REPORT_TIME}
                 ReportTime('Match found');
                 {$ENDIF}

                 if (iInputRow > -1) then
                 begin
                      {traverse the fields to add chosen by the user,
                       and add the ones occuring in this table}
                      for iInputRows := 1 to (LinkGrid.RowCount - 1) do
                          if (LinkGrid.Cells[0,iInputRows] = sInputTable) then
                          begin
                               {write value for this field to the Destination table}
                               WriteCellValue(iInputRows,            {row index from LinkGrid of field to add}
                                              InputChildren[iTable],
                                              InputParsers[iTable],
                                              iInputRow,             {row in Input child containing data}
                                              iRow,                  {row in Destination child}
                                              ColumnInInputChild[iInputRows],
                                              ColumnArray
                                              );
                          end
                          else
                              {};
                 end
                 else
                 begin
                      {input row does not occur in this table,

                       NOTE : Code needs to be added to deal with writing to a CSV file where input file
                              has missing rows (compared to destination rows)

                       we must output null values to the CSV file, blank cells in the DBF do not matter}

                      {write null values to columns contained in the current table}
                      
                      if not DestinationChild.CheckLoadFileData.Checked then
                         for iCount := 1 to (LinkGrid.RowCount - 1) do
                             if (DestinationChild.Caption = LinkGrid.Cells[0,iCount]) then
                                DestinationParser.FlushCSVColumn(iCount);
                 end;

                 {$IFDEF REPORT_TIME}
                 ReportTime('value written');
                 {$ENDIF}

                 if (not DestinationChild.CheckLoadFileData.Checked) then
                    if (DestinationParser.rtnTableType = DBF) then
                    begin
                         DestinationParser.DBFTable.Next;
                         DestinationParser.DBFTable.Edit;
                    end;

                 {$IFDEF REPORT_TIME}
                 ReportTime('dbf advanced');
                 {$ENDIF}
            end;

        {$IFDEF REPORT_TIME}
        ReportTime('after main loop');
        {$ENDIF}



        if DestinationChild.CheckLoadFileData.Checked then
        begin
             {update dimensions components to reflect state of the grid}
             DestinationChild.lblDimensions.Caption := 'Rows: ' + IntToStr(DestinationChild.aGrid.RowCount) +
                                                       ' Columns: ' + IntToStr(DestinationChild.aGrid.ColCount);
             DestinationChild.SpinCol.Value := DestinationChild.aGrid.ColCount;
             DestinationChild.SpinRow.Value := DestinationChild.aGrid.RowCount;
             DestinationChild.fDataHasChanged := True;

             {destroy array of column information}
             ColumnArray.Destroy;
        end
        else
        begin
             {free destination table objects}

             if (DestinationParser.rtnTableType = DBF) then
                DestinationParser.DBFTable.Post;

             DestinationParser.doneTMPfiles;

             DestinationParser.donefile;
             DestinationParser.free;

             {re-link table now fields have been added}
             sTable := DestinationChild.Caption;
             DestinationChild.Free;
             SCPForm.CreateMDIChild(sTable,False,False);
        end;

        {free input table(s) object(s)}
        for iTable := 1 to InputTables.lMaxSize do
        begin
             if not InputChildren[iTable].CheckLoadFileData.Checked then
             begin
                  InputParsers[iTable].donefile;
                  InputParsers[iTable].free;
             end;
             InputSearchArrays[iTable].destroy;
        end;
        InputTables.Destroy;

        {$IFDEF REPORT_TIME}
        FreeTimeReport;
        {$ENDIF}

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Import Data Field Wizard',mtError,[mbOk],0);
           application.terminate;
           exit;
     end;

     Screen.Cursor := crDefault;
end;



procedure TImportDataFieldForm.btnBrowseClick(Sender: TObject);
begin
     BrowseTable;
end;

procedure TImportDataFieldForm.LinkGridSelectCell(Sender: TObject; Col,
  Row: Integer; var CanSelect: Boolean);
begin
     LinkGrid.Hint := LinkGrid.Cells[Col,Row];
end;


procedure TImportDataFieldForm.btnAddEntireTableClick(Sender: TObject);
var
   iChildId, iCount : integer;
   Child : TMDIChild;

     // add all fields from this table except the key field

begin
     // traverse the fields in the current table
     iChildId := SCPForm.rtnTableId(AvailTblBox.Items.Strings[AvailTblBox.ItemIndex]);
     Child := TMDIChild(SCPForm.MDIChildren[iChildId]);
     for iCount := 0 to (Child.aGrid.ColCount - 1) do
         if (Child.KeyFieldGroup.ItemIndex <> iCount) then
         // add the field to the LinkGrid if it is not the key field
         begin
              if (LinkGrid.Cells[0,1] <> '') then
                 LinkGrid.RowCount := LinkGrid.RowCount + 1;

              LinkGrid.Cells[0,LinkGrid.RowCount - 1] := AvailTblBox.Items.Strings[AvailTblBox.ItemIndex];
              LinkGrid.Cells[1,LinkGrid.RowCount - 1] := Child.aGrid.Cells[iCount,0];

              Button28.Enabled := True;
         end;
end;

procedure TImportDataFieldForm.btnNoConvertClick(Sender: TObject);
begin
     ComboFrom.Text := 'no units';
     ComboTo.Text := 'no units';
     EditMult.Text := '';
     ConvertGrid.Cells[2,ConvertGrid.Selection.Top] := '';
end;

end.
