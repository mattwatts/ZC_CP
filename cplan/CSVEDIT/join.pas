unit join;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, Buttons, StdCtrls, ExtCtrls, Spin, Db, DBTables, Gauges;

const
     JTSIZE = 1000;
     MAXTMPFILES = 4000;

type

  str255 = string[255];

  TJoinForm = class(TForm)
    Notebook1: TNotebook;
    MasterIdBox: TListBox;
    Label1: TLabel;
    Button2: TButton;
    BitBtn1: TBitBtn;
    AvailTblBox: TListBox;
    LinkTblBox: TListBox;
    SelHighlightTbl: TSpeedButton;
    SelAllTbl: TSpeedButton;
    UnSelHighlightTbl: TSpeedButton;
    UnSelAllTbl: TSpeedButton;
    Label2: TLabel;
    Label3: TLabel;
    Button3: TButton;
    Button4: TButton;
    BitBtn2: TBitBtn;
    Label4: TLabel;
    Label5: TLabel;
    BitBtn3: TBitBtn;
    Button5: TButton;
    Button6: TButton;
    Label6: TLabel;
    ConvGrid: TStringGrid;
    BitBtn4: TBitBtn;
    Label7: TLabel;
    Label8: TLabel;
    btnPrevious: TButton;
    BitBtn5: TBitBtn;
    Label9: TLabel;
    Label10: TLabel;
    EditMult: TEdit;
    ComboFrom: TComboBox;
    ComboTo: TComboBox;
    Label11: TLabel;
    Label12: TLabel;
    Button1: TButton;
    btnNext: TButton;
    BitBtn6: TBitBtn;
    Label13: TLabel;
    CheckWriteToFile: TCheckBox;
    EditFile: TEdit;
    btnBrowse: TButton;
    SaveTable: TSaveDialog;
    ChildTable: TTable;
    LabelProgress: TLabel;
    Label14: TLabel;
    Button7: TButton;
    Button8: TButton;
    BitBtn7: TBitBtn;
    RadioButtonNo: TRadioButton;
    RadioButtonYes: TRadioButton;
    Label17: TLabel;
    ColumnMasterBox: TListBox;
    ColumnMasterCombo: TComboBox;
    Label18: TLabel;
    LabelProgressTable: TLabel;
    Gauge1: TGauge;
    btnBrowseTable: TButton;
    Button36: TButton;
    Button9: TButton;
    btnNoConversion: TButton;
    procedure EditConvertTable;
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SelHighlightTblClick(Sender: TObject);
    procedure UnSelHighlightTblClick(Sender: TObject);
    procedure SelAllTblClick(Sender: TObject);
    procedure UnSelAllTblClick(Sender: TObject);
    procedure MasterIdBoxClick(Sender: TObject);
    function CheckTblSelected : boolean;
    procedure BitBtn4Click(Sender: TObject);
    procedure ExecuteJoin;
    procedure EditMultChange(Sender: TObject);
    procedure btnPreviousClick(Sender: TObject);
    procedure ConvGridSelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    function rtnConversionChange : extended;
    procedure ComboFromChange(Sender: TObject);
    procedure ComboToChange(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure CheckWriteToFileClick(Sender: TObject);
    procedure RadioButtonNoClick(Sender: TObject);
    procedure RadioButtonYesClick(Sender: TObject);
    procedure ColumnMasterComboChange(Sender: TObject);
    procedure ColumnMasterBoxClick(Sender: TObject);
    procedure ExecuteColumnJoin(const fDebugColumnRow :  boolean);
    procedure btnBrowseTableClick(Sender: TObject);
    procedure AvailTblBoxClick(Sender: TObject);
    procedure LinkTblBoxClick(Sender: TObject);
    procedure SaveWizardSpecification(const sSpecFile : string);
    procedure btnNoConversionClick(Sender: TObject);
  private
    { Private declarations }
    function BrowseTable : boolean;
  public
    { Public declarations }
    ColumnFiles : array[1..5000] of Textfile;
  end;


function rtnConversionFactor(const iConvert : integer) : extended;


var
  JoinForm: TJoinForm;

implementation

uses MAIN, ds, Childwin, xdata,
     sitelist, tparse,
     global, userkey, loadtype, import,
     impexp;

{$R *.DFM}

function SaveMasterRowsTable(const AFile : TextFile) : boolean;
var
   sChild : string;
begin
     with JoinForm do
     begin
          sChild := MasterIdBox.Items.Strings[MasterIdBox.ItemIndex];
          writeln(AFile,'[MasterRows]');
          writeln(AFile,'Table=' + sChild);
          writeln(AFile,'Key=' + SCPForm.rtnChildKey(sChild));
          writeln(AFile,'Type=' + SCPForm.rtnChildType(sChild));
     end;
end;

function SaveMasterColumnsTable(const AFile : TextFile) : boolean;
var
   sChild : string;
begin
     with JoinForm do
     begin
          if RadioButtonYes.Checked then
          begin
               sChild := ColumnMasterBox.Items.Strings[ColumnMasterBox.ItemIndex];
               writeln(AFile,'[MasterColumns]');
               writeln(AFile,'Table=' + sChild);
               writeln(AFile,'Key=' + SCPForm.rtnChildKey(sChild));
               writeln(AFile,'Type=' + SCPForm.rtnChildType(sChild));
               writeln(AFile,'MasterColumn=' + ColumnMasterCombo.Text);
          end
          else
          begin
               writeln(AFile,'[MasterColumns]');
               writeln(AFile,'Table=');
               writeln(AFile,'Key=');
               writeln(AFile,'Type=');
               writeln(AFile,'MasterColumn=');
          end;
     end;
end;

function SaveInputCriteria(const AFile : TextFile) : boolean;
var
   sChild : string;
   iCount : integer;
begin
     with JoinForm do
     begin
          writeln(AFile,'[Input]');
          for iCount := 1 to (ConvGrid.RowCount-1) do
          begin
               sChild := ConvGrid.Cells[0,iCount];
               writeln(AFile,'Table=' + sChild);
               writeln(AFile,'Key=' + SCPForm.rtnChildKey(sChild));
               writeln(AFile,'Type=' + SCPForm.rtnChildType(sChild));
               writeln(AFile,'ConvertFactor=' + ConvGrid.Cells[1,iCount]);
          end;
     end;
end;


procedure TJoinForm.SaveWizardSpecification(const sSpecFile : string);
var
   OutFile : TextFile;
begin
     try
        {}
        assignfile(OutFile,sSpecFile);
        rewrite(OutFile);

        // write wizard spec header
        writeln(OutFile,'[C-Plan Join Tables Wizard Specification File]');
        writeln(OutFile,'Date=' + FormatDateTime('dddd," "mmmm d, yyyy',Now));
        writeln(OutFile,'Time=' + FormatDateTime('hh:mm AM/PM', Now));
        if CheckWriteToFile.Checked then
           writeln(OutFile,'WriteDirectlyToFile=True')
        else
            writeln(OutFile,'WriteDirectlyToFile=False');
        writeln(OutFile,'OutputFile=' + EditFile.Text);
        writeln(OutFile,'CPlanVersion=');
        writeln(OutFile,'');

        // write MasterRows settings
        SaveMasterRowsTable(OutFile);
        writeln(OutFile,'');

        // write MasterColumns settings
        SaveMasterColumnsTable(OutFile);
        writeln(OutFile,'');

        // write input criteria for the fields we are importing
        SaveInputCriteria(OutFile);

        closefile(OutFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TJoinForm.SaveWizardSpecification',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;



function TJoinForm.BrowseTable : boolean;
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
             MasterIdBox.Items.Add(sStr);
             ColumnMasterBox.Items.Add(sStr);
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

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TJoinForm.BrowseTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function Bool2String(const fValue : boolean) : string;
begin
     if (fValue = True) then
        Result := 'True'
     else
         Result := 'False';
end;

procedure TJoinForm.ExecuteColumnJoin(const fDebugColumnRow :  boolean);
type
    ArrayOfTempFiles = array [1..MAXTMPFILES] of TextFile;
    TempFilePointer = ^ArrayOfTempFiles;
    ArrayOfColumnUsed = array [1..MAXTMPFILES] of boolean;
    ColumnUserPointer = ^ArrayOfColumnUsed;
var
   {variables needing to be initialised}
   iNullValue, iRowCount, iColumnCount, iJoinTableCount : integer;
   MRChild, MCChild, BlankChild : TMDIChild;
   MRParser, MCParser : TTableParser;
   JTChildren : array [1..JTSIZE] of TMDIChild;
   JTParsers : array [1..JTSIZE] of TTableParser;
   JTSearchArrays : array [1..JTSIZE] of Array_T;
   ColumnUsed : ColumnUserPointer;
   sTempDir, sOutputPath : string;
   //TempFiles : array [1..MAXTMPFILES] of TextFile;
   TempFiles : TempFilePointer;
   {loop control variables}
   iR, iJ, iC, iCnt : integer;
   {temporary variables}
   iRowIndex, iColIndex : integer;
   sConvert, sRowKey, sColName, sCellValue : string;
   DebugColumnRowFile : TextFile;
   fCellValueWritten : boolean;

   {begin sub- procedures and functions of procedure TJoinForm.ExecuteColumnJoin}
   procedure InitMasterRows;
   var
      iTableId : integer;
   begin
        iTableId := SCPForm.rtnTableId(MasterIdBox.Items.Strings[MasterIdBox.ItemIndex]);
        MRChild := TMDIChild(SCPForm.MDIChildren[iTableId]);
        if not MRChild.CheckLoadFileData.Checked then
        begin
             MRParser := TTableParser.Create(Application);
             MRParser.initfile(MRChild.Caption);
        end;

        if not CheckWriteToFile.Checked then
        begin
             BlankChild.aGrid.ColCount := MRChild.SpinCol.Value;
             BlankChild.aGrid.RowCount := MRChild.SpinRow.Value;
        end;

        iRowCount := MRChild.SpinRow.Value - 1;
   end;
   function InitMasterColumns : boolean;
   var
      iCount, iTableId : integer;
      sT : string;
   begin
        try
           Result := True;

           iTableId := SCPForm.rtnTableId(ColumnMasterBox.Items.Strings[ColumnMasterBox.ItemIndex]);
           MCChild := TMDIChild(SCPForm.MDIChildren[iTableId]);
           if not MCChild.CheckLoadFileData.Checked then
           begin
                MCParser := TTableParser.Create(Application);
                MCParser.initfile(MCChild.Caption);
           end;

           if CheckWriteToFile.Checked then
           begin
                {initialise temporary output files}
                sTempDir := ExtractFilePath(MasterIdBox.Items.Strings[MasterIdBox.ItemIndex]);
                {we need to create 1 output file for each column in the master column list}

                if ((MCChild.SpinCol.Value-1) <= MAXTMPFILES) then
                   for iCount := 1 to MCChild.SpinRow.Value do
                   begin
                        try
                           sT := sTempDir + '~~' + IntToStr(iCount-1);
                           assignfile(TempFiles^[iCount],sT);
                           rewrite(TempFiles^[iCount]);
                        except
                              Screen.Cursor := crDefault;
                              MessageDlg('C-Plan can only join up to ' + IntToStr(MAXTMPFILES) +
                                         ' columns into a table',
                                         mtError,[mbOk],0);
                        end;
                   end
                else
                begin
                     Screen.Cursor := crDefault;
                     MessageDlg('C-Plan can only join up to ' + IntToStr(MAXTMPFILES) +
                                ' columns into a table',mtError,[mbOk],0);
                     Result := False;
                end;
           end;

           iColumnCount := MCChild.SpinRow.Value - 1;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception InitMasterColumns in ExecuteColumnJoin',mtError,[mbOk],0);
        end;
   end;
   function rtnIdArray(aChild : TMDIChild;
                       aParser : TTableParser) : Array_T;
   var
      sCell : str255;
      iCount : integer;
   begin
        Result := Array_T.Create;

        {default type for identifiers is str255, this will work for strings and numbers}
        Result.init(SizeOf(str255),(aChild.SpinRow.Value-1));
        if aChild.CheckLoadFileData.Checked then
        begin
             {read array from the grid}
             for iCount := 1 to (aChild.SpinRow.Value-1) do
             begin
                  sCell := aChild.aGrid.Cells[aChild.KeyFieldGroup.ItemIndex,iCount];
                  Result.setValue(iCount,@sCell);
             end;
        end
        else
        begin
             {read array from the table parser}
             for iCount := 1 to (aChild.SpinRow.Value-1) do
             begin
                  aParser.seekfile(iCount);
                  sCell := aParser.rtnRowValue(aChild.KeyFieldGroup.ItemIndex);
                  Result.setValue(iCount,@sCell);
             end;
        end;
   end;
   function InitJoinTables : boolean;
   var
      sBlankTable : string;
      iBlankId, iTableId, iCount : integer;
      IdArr : Array_T;
   begin
        {returns : FALSE if number of tables to join is > JTSIZE
                   TRUE if number of tables to join is <= JTSIZE}
        if (LinkTblBox.Items.Count > JTSIZE) then
        begin
             Result := False;

             Screen.Cursor := crDefault;
             MessageDlg('C-Plan can only link a maximum of ' + IntToStr(JTSIZE) +
                        ' tables at a time',
                        mtInformation,[mbOk],0);
        end
        else
        begin
             Result := True;

             {initialise objects for this set of join tables}
             for iCount := 1 to LinkTblBox.Items.Count do
             begin
                  iTableId := SCPForm.rtnTableId(LinkTblBox.Items.Strings[iCount-1]);
                  JTChildren[iCount] := TMDIChild(SCPForm.MDIChildren[iTableId]);
                  if not JTChildren[iCount].CheckLoadFileData.Checked then
                  begin
                       JTParsers[iCount] := TTableParser.Create(Application);
                       JTParsers[iCount].initfile(JTChildren[iCount].Caption);
                  end;
                  {build search array for this JT child}
                  IdArr := rtnIdArray(JTChildren[iCount],JTParsers[iCount]);
                  JTSearchArrays[iCount] := SortStrArray(IdArr);
                  IdArr.destroy;
             end;
             iJoinTableCount := LinkTblBox.Items.Count;

             {initialise the output file/output grid}
             for iCount := 1 to JTSIZE do
                 ColumnUsed^[iCount] := False;

             if not CheckWriteToFile.Checked then
             begin
                  {create new child form with grid}
                  sBlankTable := 'Table ' + IntToStr(MDIChildCount + 1);
                  SCPForm.CreateMDIChild(sBlankTable,True,False);
                  iBlankID := SCPForm.rtnTableId(sBlankTable);
                  BlankChild := TMDIChild(SCPForm.MDIChildren[iBlankID]);
             end;
        end;
   end;

   procedure FreeMasterRows;
   begin
        if not MRChild.CheckLoadFileData.Checked then
        begin
             MRParser.donefile;
             MRParser.free;
        end;
   end;
   procedure FreeMasterColumns;
   var
      iCount : integer;
   begin
        if not MCChild.CheckLoadFileData.Checked then
        begin
             MCParser.donefile;
             MCParser.free;
        end;

        {delete temp files}
        if CheckWriteToFile.Checked then
           for iCount := 0 to (MCChild.SpinRow.Value-1) do
           try
              deletefile(sTempDir + '~~' + IntToStr(iCount));
           except
           end;
   end;
   procedure FreeJoinTables;
   var
      iCount : integer;
   begin
        for iCount := 1 to LinkTblBox.Items.Count do
        begin
             if not JTChildren[iCount].CheckLoadFileData.Checked then
             begin
                  JTParsers[iCount].donefile;
                  JTParsers[iCount].free;
             end;
             JTSearchArrays[iCount].destroy;
        end;

        {tidy up BlankChild.aGrid}
   end;

   function rtnMRKey(const iMasterRowIndex : integer) : string;
   begin
        {return key identifier from row iMasterRowIndex in the Master Row table}
        if MRChild.CheckLoadFileData.Checked then
           Result := MRChild.aGrid.Cells[MRChild.KeyFieldGroup.ItemIndex,iMasterRowIndex]
        else
        begin
             MRParser.seekfile(iMasterRowIndex);
             Result := MRParser.rtnRowValue(MRChild.KeyFieldGroup.ItemIndex);
        end;
   end;
   function rtnColumnName(const iColumnIndex : integer) : string;
   var
      iColumnContainingMasterColumnList : integer;
   begin
        {return the name of column iColumnIndex in the Master Column table}
        iColumnContainingMasterColumnList := MCChild.rtnColumnIndex(ColumnMasterCombo.Text);
        if MCChild.CheckLoadFileData.Checked then
           Result := MCChild.aGrid.Cells[iColumnContainingMasterColumnList,iColumnIndex]

        else
        begin
             MCParser.seekfile(iColumnIndex);
             Result := MCParser.rtnRowValue(iColumnContainingMasterColumnList);
        end;
   end;
   function ReadJTCellValue(JTChild : TMDIChild;
                            JTParser : TTableParser;
                            JTSearchArr : Array_T;
                            const iCol {0 referenced}, iRow {1 referenced} : integer) : string;
   begin
        {return the contents of cell iCol,iRow in the Join table JTChild}
        if JTChild.CheckLoadFileData.Checked then
           // iCol and iRow both should be zero referenced in the following statement
           // NOTE : this may be a conflict with how they are declared above (ie. iRow 1 referenced)
           Result := JTChild.aGrid.Cells[iCol,iRow]
        else
        begin
             JTParser.seekfile(iRow);
             Result := JTParser.rtnRowValue(iCol);
        end;
   end;
   procedure WriteCellValue(const iCol {0 referenced}, iRow {0 referenced} : integer;
                            const sValue : string);
   begin
        {write sValue to cell iCol,iRow in the output table}
        {if column file iCol not used}
          {write sValue to column file iCol}
          {set column file iCol to used}
        //if not ColumnUsed^[iCol + 1] then
        if true then
        begin
             if CheckWriteToFile.Checked then
             begin
                  {write to file}
                  writeln(TempFiles^[iCol + 1],sValue);
             end
             else
             begin
                  {write to grid}
                  BlankChild.aGrid.Cells[iCol,iRow] := sValue;
             end;
             ColumnUsed^[iCol + 1] := True;
        end;
   end;
   procedure FlushNullCells(const iR : integer);
   var
      iCount : integer;
   begin
        {write null value to any columns that have not been written to}
        for iCount := 0 to (MCChild.SpinRow.Value-1) do
            if not ColumnUsed^[iCount+1] then
               if CheckWriteToFile.Checked then
                  {write null value to this temp file}
                  writeln(TempFiles^[iCount+1],IntToStr(iNullValue))
               else
                   {write null value to this grid cell}
                   BlankChild.aGrid.Cells[iCount,iR] := IntToStr(iNullValue);

        for iCount := 1 to JTSIZE{MCChild.SpinRow.Value} do
            ColumnUsed^[iCount] := False;
   end;
   procedure JoinColumnFiles;
   var
      DestinationFile : TextFile;
      iCount, iCount2 : integer;
      sTmp : string;
   begin
        {join the temporary column files created by the row parsing process into a single output file}

        assignfile(DestinationFile,EditFile.Text);
        rewrite(DestinationFile);

        labelProgress.Caption := 'joining temporary column files';

        for iCount := 1 to MCChild.SpinRow.Value do
        begin
             closefile(TempFiles^[iCount]);
             reset(TempFiles^[iCount]);
        end;

        {for each row in the MRChild}
        for iCount := 1 to (iRowCount + 1) do
        begin
             Gauge1.Progress := Round(iCount / MRChild.SpinRow.Value * 100);
             Refresh;

             {for each column}
             for iCount2 := 1 to (iColumnCount+1) do
             begin
                  readln(TempFiles^[iCount2],sTmp);
                  write(DestinationFile,sTmp);
                  if (iCount2 <> (iColumnCount+1)) then
                     write(DestinationFile,',')
                  else
                      writeln(DestinationFile);
             end;
        end;

        for iCount := 1 to MCChild.SpinRow.Value do
            closefile(TempFiles^[iCount]);

        closefile(DestinationFile);
   end;
   procedure WriteColumnIdentifiers;
   var
      iCount : integer;
      sC : string;
   begin
        {write column identifiers to grid of Temp files}
        if CheckWriteToFile.Checked then
           {write to temp files}
           writeln(TempFiles^[1],'Key')
        else
        begin
             BlankChild.aGrid.Cells[0,0] := 'Key';

             BlankChild.aGrid.RowCount := iRowCount + 1;
             BlankChild.aGrid.ColCount := iColumnCount + 1;
             BlankChild.aGrid.FixedRows := 1;
             BlankChild.lblDimensions.Caption := 'Rows: ' + IntToStr(BlankChild.AGrid.RowCount) +
                                                 ' Columns: ' + IntToStr(BlankChild.AGrid.ColCount);
             BlankChild.CheckLoadFileData.Checked := True;

        end;

        for iCount := 1 to MCChild.SpinRow.Value-1 do
        begin
             sC := rtnColumnName(iCount);

             if CheckWriteToFile.Checked then
                {write to temp files}
                writeln(TempFiles^[iCount+1],sC)
             else
                 {write to grid}
                 BlankChild.aGrid.Cells[iCount,0] := sC;
        end;
   end;
   procedure WriteRowKey(const sRK : string;
                         const iRR : integer);
   begin
        if CheckWriteToFile.Checked then
           writeln(TempFiles^[1],sRK)
        else
            BlankChild.aGrid.Cells[0,iRR] := sRK;

        ColumnUsed^[1] := True;
   end;
   {end sub- procedures and functions of procedure TJoinForm.ExecuteColumnJoin}

begin
     if fDebugColumnRow then
     begin
          assignfile(DebugColumnRowFile,'c:\debug_column_row.csv');
          rewrite(DebugColumnRowFile);
          writeln(DebugColumnRowFile,'row,col,row,col,table,value,row,col,written,used');
     end;

     {execute table join using a master column list.
      master column list contains the list and order of fields to create in the output file}

     {
     author: Matthew Watts
     date: Thu 14 May 1998

     procedure: TJoinForm.ExecuteColumnJoin

     inputs:
            master list of rows
            master list of columns
            n tables to be joined
            null value (integer)

     outputs:
             table with rows and columns from master list, populated with data from the n tables
             (any cells in the table that do not have corresponding data will be set to a
              null integer value, depending on its type)

     method:

            for each row r in the master list of rows
                for each table j of n tables to join
                    if r is a row in j
                       for each column c in master list of columns
                           if c is a column in j
                              write value to destination cell
                flush unused columns with null value

            if writing resultant table directly to file
               join temp column files to create final output file
               delete temp column files
     }
     try
        Screen.Cursor := crHourglass;
        iNullValue := 0; {this is the default null value, add option for user to specify this}

        new(ColumnUsed);
        new(TempFiles);

        try
           // We must save the specification for this wizard, use the specified output path
           // if we are writing directly to a file, or else use the path containing the
           // loaded table we are writing to.
           if CheckWriteToFile.Checked then
              sOutputPath := ExtractFilePath(EditFile.Text)
           else
               sOutputPath := 'c:';

           JoinForm.SaveWizardSpecification(rtnUniqueFileName(sOutputPath,'jws'));

        except
              Screen.Cursor := crDefault;
              if (mrNo = MessageDlg('There was an exception saving the specification file' + Chr(10) + Chr(13) +
                                    'for this table join.' + Chr(10) + Chr(13) +
                                    'Do you want to continue anyway?',
                                    mtConfirmation,
                                    [mbYes,mbNo],
                                    0)) then
              begin
                   Application.Terminate;
                   Exit;
              end
              else
                  Screen.Cursor := crHourglass;
        end;


        if InitJoinTables then
        begin
             if InitMasterColumns then
             begin
                  InitMasterRows;

                  {write the list of column identifiers to the table}
                  WriteColumnIdentifiers;

                  labelProgress.Caption := 'joining tables';
                  btnPrevious.Visible := False;
                  BitBtn4.Visible := False;
                  BitBtn5.Visible := False;
                  Gauge1.Visible := True;

                  for iR := 1 to iRowCount do
                  begin
                       Gauge1.Progress := Round(iR / iRowCount * 100);
                       Refresh;
                       sRowKey := rtnMRKey(iR);

                       {write row key to destination table}
                       WriteRowKey(sRowKey,iR);

                       for iJ := 1 to iJoinTableCount do
                       begin
                            iRowIndex := FindStrMatch(JTSearchArrays[iJ],sRowKey);
                            {iRowIndex is one referenced}
                            if (iRowIndex > 0) then
                            begin
                                 for iC := 1 to iColumnCount do
                                 begin
                                      fCellValueWritten := False;
                                      sColName := rtnColumnName(iC);
                                      iColIndex := JTChildren[iJ].rtnColumnIndex(sColName);
                                      {iColIndex is zero referenced}
                                      if (iColIndex > -1) then
                                      begin
                                           {}
                                           try
                                              sCellValue := ReadJTCellValue(JTChildren[iJ],
                                                                            JTParsers[iJ],
                                                                            JTSearchArrays[iJ],
                                                                            iColIndex,
                                                                            iRowIndex);
                                           except
                                                 Screen.Cursor := crDefault;
                                                 MessageDlg('Exception in ReadJTCellValue at ' +
                                                            ' master col ' + IntToStr(iC) +
                                                            ' master row ' + IntToStr(iR) +
                                                            ' join table ' + IntToStr(iJ) +
                                                            ' cell col ' + IntToStr(iColIndex) +
                                                            ' cell row ' + IntToStr(iRowIndex),
                                                            mtError,[mbOk],0);
                                           end;

                                           {convert the cell value if a conversion factor has been set for this table}
                                           if (ConvGrid.Cells[1,iJ] <> '') then
                                           try
                                              sConvert := FloatToStr(StrToFloat(sCellValue) *
                                                                     StrToFloat(ConvGrid.Cells[1,iJ]));
                                              sCellValue := sConvert;
                                           except
                                                 ConvGrid.Cells[1,iJ] := '';
                                           end;

                                           try
                                              WriteCellValue(iC,
                                                             iR,
                                                             sCellValue);
                                              fCellValueWritten := True;
                                           except
                                                 Screen.Cursor := crDefault;
                                                 MessageDlg('Exception in WriteCellValue at ' +
                                                            ' master col ' + IntToStr(iC) +
                                                            ' master row ' + IntToStr(iR) +
                                                            ' join table ' + IntToStr(iJ) +
                                                            ' cell col ' + IntToStr(iColIndex) +
                                                            ' cell row ' + IntToStr(iRowIndex) +
                                                            ' cell value ' + sCellValue,
                                                            mtError,[mbOk],0);
                                           end;

                                           if fDebugColumnRow
                                           and (iC > 198)
                                           and (iC < 202)
                                           and (sCellValue <> '0') then
                                              // writeln(DebugColumnRowFile,'iR(row),iC(column),iRowIndex(row),iColIndex(col),iJ(table),sCellValue(value)');
                                              // 'iR row iC column iRowIndex row iColIndex col iJ table sCellValue value'
                                              writeln(DebugColumnRowFile,IntToStr(iR) +
                                                                 ',' + IntToStr(iC) +
                                                                 ',' + IntToStr(iRowIndex) +
                                                                 ',' + IntToStr(iColIndex) +
                                                                 ',' + IntToStr(iJ) +
                                                                 ',' + sCellValue +
                                                                 ',' + sRowKey +
                                                                 ',' + sColName +
                                                                 ',' + Bool2String(fCellValueWritten) +
                                                                 ',' + Bool2String(ColumnUsed^[iC + 1]));
                                      end;
                                 end;
                            end;
                       end;

                       try
                          FlushNullCells(iR);
                       except
                             Screen.Cursor := crDefault;
                             MessageDlg('Exception in FlushNullCells',mtError,[mbOk],0);
                       end;
                  end;

                  if CheckWriteToFile.Checked then
                     try
                        JoinColumnFiles;
                     except
                           Screen.Cursor := crDefault;
                           MessageDlg('Exception in JoinColumnFiles',mtError,[mbOk],0);
                     end;

                  try
                     FreeMasterRows;
                     FreeMasterColumns;
                     FreeJoinTables;
                  except
                        Screen.Cursor := crDefault;
                        MessageDlg('Exception in Free data structures',mtError,[mbOk],0);
                  end;
             end
             else
             begin
                  FreeMasterColumns;
                  FreeJoinTables;
             end;

             {}
             {map key field selection components}

             if not CheckWriteToFile.Checked then
                with BlankChild do
                try
                     KeyFieldGroup.Items.Clear;
                     KeyCombo.Items.Clear;
                     for iCnt := 0 to (aGrid.ColCount - 1) do
                     begin
                          KeyFieldGroup.Items.Add(aGrid.Cells[iCnt,0]);
                          KeyCombo.Items.Add(aGrid.Cells[iCnt,0]);
                     end;
                     KeyFieldGroup.ItemIndex := 0;
                     KeyCombo.Text := KeyCombo.Items.Strings[0];
                except;
                       Screen.Cursor := crDefault;
                       MessageDlg('Exception setting child key properties',mtError,[mbOk],0);
                end;

        end;

        dispose(ColumnUsed);
        dispose(TempFiles);

        Screen.Cursor := crDefault;

        if fDebugColumnRow then
           closefile(DebugColumnRowFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TJoinForm.ExecuteColumnJoin',mtError,[mbOk],0);
     end;
end;


procedure TJoinForm.ExecuteJoin;
var
   sCell,
   sMasterTable, sTable, sKey : string;
   iCount, iBlankID, iTableID, iTable, iMasterID, iID,
   iColumnsToIterate, iExistingCols, iMatchedRow,
   iColumnsToCopy, iIterate, iStartingCol : integer;
   sId : string[255];
   MasterIdArray, IdArray, TableSearchArr : Array_t;

   MCChild, MasterChild, BlankChild, Child : TMDIChild;
   fStringField, fFoundRow : boolean;

   sOutTmpFile, sTmp : string;
   iGridCount, iSeekCount, iRewindCount : integer;
   OutGridFile, OutTmpFile, ChildFile : TextFile;

   fDBFFile : boolean;
   iFileRow, iBufferRow : integer;
   sBufferRow, sId1, sId2, sTmpCell,
   sOutputPath : string;

   MCParser : TTableParser;

   procedure InitChildFile;
   begin
        try
           if fDBFFile then
           begin
                ChildTable.DatabaseName := ExtractFilePath(Child.Caption);
                ChildTable.TableName := ExtractFileName(Child.Caption);
                ChildTable.Open;
           end
           else
           begin
                iFileRow := 1; {seek is on line 1}
                iBufferRow := 0; {buffer is contents of line 0 (the column identifier row)}
                AssignFile(ChildFile,Child.Caption);
                reset(ChildFile);
                readln(ChildFile,sBufferRow);
           end;

        except
              MessageDlg('Exception in InitChildFile ' + Child.Caption,
                         mtError,[mbOk],0);
        end;
   end;

   procedure SeekChildFile(const iSeekRow : integer);
   begin
        try
           if fDBFFile then
           begin
                if (iSeekRow <> ChildTable.RecNo) then
                   ChildTable.MoveBy(iSeekRow - ChildTable.RecNo);
           end
           else
           begin
                if (iBufferRow = iSeekRow) then
                   {we already have the correct line in the buffer, do nothing}
                else
                begin
                     {we need to seek to the correct line and read it into the buffer}

                     Inc(iSeekCount);

                     if (iSeekRow < iFileRow) then
                     begin
                          Inc(iRewindCount);

                          {we have to rewind the file}
                          CloseFile(ChildFile);
                          reset(ChildFile);
                          iBufferRow := 0;
                          iFileRow := 1;
                          ReadLn(ChildFile,sBufferRow);
                          {now seek until we get to iSeekRow}
                     end;

                     {we have to move forward until we get to iSeekRow}
                     if (iSeekRow > 0) then
                     repeat
                           ReadLn(ChildFile,sBufferRow);
                           Inc(iFileRow);
                           Inc(iBufferRow);

                     until (iBufferRow >= iSeekRow);
                end;
           end;

        except
              MessageDlg('Exception in SeekChildFile ' + Child.Caption,
                         mtError,[mbOk],0);
        end;
   end;

   function ReturnChildFile(const iColumn : integer;
                            const fTrimInvertedCommas : boolean) : string;
   var
      fInQuotes : boolean;
      iCount, iAtColumn : integer;
      sResult : string;
   begin
        {returns column iColumn from the current line}
        try
           if fDBFFile then
           begin
                Result := ChildTable.Fields[iColumn-1].AsString;
                {fields is zero referenced}
           end
           else
           begin
                {iterate to column iColumn}
                if (sBufferRow = '') then
                   MessageDlg('ReturnChildFile error buffer row is empty',mtError,[mbOk],0)
                else
                begin
                     iCount := 1;
                     iAtColumn := 1;
                     fInQuotes := False;
                     if (iColumn > 1) then
                     repeat
                           if (sBufferRow[iCount] = '"') then
                              fInQuotes := not fInQuotes
                           else
                           begin
                                if not fInQuotes
                                and (sBufferRow[iCount] = ',') then
                                    Inc(iAtColumn);
                           end;

                           if (iAtColumn < iColumn) then
                              Inc(iCount);

                     until (iAtColumn >= iColumn);

                     {iterate from iCount to end of column
                      (may be contained by "")
                      (will end with , or EOLN)}
                     if (sBufferRow[iCount] = '"') then
                     begin
                          {cell is enclosed in double quotes}
                          sResult := sBufferRow[iCount];

                          repeat
                                Inc(iCount);
                                sResult := sResult + sBufferRow[iCount];

                          until (sBufferRow[iCount] = '"');

                          if (sResult[Length(sResult)] <> '"') then
                             sResult := sResult + '"';
                     end
                     else
                     begin
                          {cell is not enclosed in double quotes}
                          sResult := sBufferRow[iCount];

                          repeat
                                Inc(iCount);

                                if (iCount <= Length(sBufferRow)) then
                                begin
                                     if (sBufferRow[iCount] <> ',') then
                                        sResult := sResult + sBufferRow[iCount]
                                     else
                                         iCount := Length(sBufferRow);
                                end;

                          until (iCount >= Length(sBufferRow));
                     end;

                     if (sResult[1] = ',') then
                        sResult := Copy(sResult,2,Length(sResult)-1);
                     if fTrimInvertedCommas then
                        if (sResult[1] = '"') then
                           sResult := Copy(sResult,2,Length(sResult)-2);

                     Result := sResult;
                end;
           end;

        except
              MessageDlg('Exception in ReturnChildFile ' + Child.Caption,
                         mtError,[mbOk],0);
        end;
   end;

   procedure CloseChildFile;
   begin
        if not Child.CheckLoadFileData.Checked then
        try
           if fDBFFile then
           begin
                ChildTable.Close;
           end
           else
           begin
                CloseFile(ChildFile);
           end;

        except
              MessageDlg('Exception in CloseChildFile ' + Child.Caption,
                         mtError,[mbOk],0);
        end;
   end;

   procedure CreateOutputFile;
   begin
        {create and open a new file for writing}
        AssignFile(OutGridFile,EditFile.Text);
        rewrite(OutGridFile);

        iGridCount := 0;
        repeat
              sOutTmpFile := ExtractFilePath(EditFile.Text) + '~tmp' + IntToStr(iGridCount) + '.csv';
              Inc(iGridCount);

        until not FileExists(sOutTmpFile);

        AssignFile(OutTmpFile,sOutTmpFile);
        rewrite(OutTmpFile);

   end; {of CreateOutputFile}

   procedure InitialiseOutputTable;
   begin
        if (iTable = 0) then
        begin
             {writing row identifiers from master table}
             iTableID := iMasterID;
             Child := MasterChild;

             if not CheckWriteToFile.Checked then
             begin
                  {set default row count and col count}
                  BlankChild.aGrid.RowCount := Child.SpinRow.Value;
                  BlankChild.aGrid.ColCount := 1;

                  BlankChild.SpinRow.Value :=  BlankChild.aGrid.RowCount;
                  BlankChild.SpinCol.Value :=  BlankChild.aGrid.ColCount;

                  BlankChild.KeyFieldGroup.ItemIndex := Child.KeyFieldGroup.ItemIndex;
             end;
        end
        else
        begin
             {writing grid data from one of the Linked Tables}
             iTableID := SCPForm.rtnTableId(LinkTblBox.Items.Strings[iTable-1]);
             Child := TMDIChild(SCPForm.MDIChildren[iTableID]);

             {increase the col count to store data from the linked table}
             if not CheckWriteToFile.Checked then
             begin
                  BlankChild.aGrid.ColCount := (Child.SpinCol.Value - 1) +
                                             BlankChild.aGrid.ColCount;

                  BlankChild.SpinCol.Value :=  BlankChild.aGrid.ColCount;
             end;
        end;

   end; {of InitialiseOutputTable}


   procedure ReadTableIdentifiers;
   var
      iCount : integer;
   begin

        {initialise table array}
        if fStringField then
        begin
             IdArray.init(SizeOf(sId),Child.SpinRow.Value-1);
             if (iTable = 1) then
                {this is the master table}
                MasterIdArray.init(SizeOf(sId),Child.SpinRow.Value-1);
        end
        else
        begin
             IdArray.init(SizeOf(integer),Child.SpinRow.Value-1);
             if (iTable = 1) then
                MasterIdArray.init(SizeOf(integer),Child.SpinRow.Value-1)
        end;

        for iCount := 1 to (Child.SpinRow.Value - 1) do
        begin
             if fStringField then
             begin
                  if not Child.CheckLoadFileData.Checked then
                  begin
                       SeekChildFile(iCount);
                       sId := ReturnChildFile(Child.KeyFieldGroup.ItemIndex+1,True);
                  end
                  else
                      sId := Child.aGrid.Cells[{col,row}
                                      Child.KeyFieldGroup.ItemIndex,
                                      iCount];

                  IdArray.setValue(iCount,@sId);
                  if (iTable = 1) then
                     MasterIdArray.setValue(iCount,@sId);
             end
             else
             begin
                  if not Child.CheckLoadFileData.Checked then
                  begin
                       SeekChildFile(iCount);
                       iId := StrToInt(ReturnChildFile(Child.KeyFieldGroup.ItemIndex+1,True));
                  end
                  else
                      iID := StrToInt(Child.aGrid.Cells[{col,row}
                                      Child.KeyFieldGroup.ItemIndex,
                                      iCount]);

                  IdArray.setValue(iCount,@iId);
                  if (iTable = 1) then
                     MasterIdArray.setValue(iCount,@iId);
             end;
        end;

   end; {of ReadTableIdentifiers}

   procedure MapMasterFields(const iCount : integer);
   begin
        {we are mapping master fields from Child(=MasterChild)
         to BlankChild}
        {read the two data elements}
        if not Child.CheckLoadFileData.Checked then
        begin
             if (iCount = 0)
             and fDBFFile then
             begin
                  {we are reading DBF Field names
                   (because we are on row zero of the DBF file)}
                  sId1 := ChildTable.Fields[0].AsString;
             end
             else
             begin
                  SeekChildFile(iCount);
                  sId1 := ReturnChildFile(1,not CheckWriteToFile.Checked);
             end;
        end
        else
        begin
             sId1 := Child.aGrid.Cells[0,iCount];
        end;

        {write the two data elements}
        if not CheckWriteToFile.Checked then
        begin
             BlankChild.aGrid.Cells[0,iCount] := sId1;
        end
        else
        begin
             WriteLn(OutTmpFile,sId1);
        end;
   end;

   procedure ReInitialiseOutputTable(const iCount : integer);
   begin
        if CheckWriteToFile.Checked
        and (iCount = 0) then
        begin
             if (iTable > 2) then
             begin
                  {the table being joined is the second or subsequent table}

                  CloseFile(OutGridFile);
                  CloseFile(OutTmpFile);

                  DeleteFile(sOutTmpFile);

                  RenameFile(EditFile.Text,sOutTmpFile);

                  AssignFile(OutGridFile,EditFile.Text);
                  AssignFile(OutTmpFile,sOutTmpFile);

                  rewrite(OutGridFile);
                  reset(OutTmpFile);
             end
             else
             begin
                  {the table being joined is the 1st non master table}

                  CloseFile(OutTmpFile);
                  reset(OutTmpFile);
             end;
        end;
   end;

   procedure MapNonMasterFields(const iCount : integer);
   var
      sTest : string;
      iC, iColumnsToIterate, iIterate : integer;
      tS : truesitetype;
      fF : truefeattype;

      function localstrcomp(const s1, s2 : str255) : boolean;
      var
         iL1, iL2, iCnt : integer;
      begin
           iL1 := Length(s1);
           iL2 := Length(s2);
           if (iL1 = iL2) then
           begin
                Result := True;
                if (iL1 > 0) then
                   for iCnt := 1 to iL1 do
                       if (s1[iCnt] <> s2[iCnt]) then
                          Result := False;
           end
           else
               Result := False;
           {}
      end;

   begin
        {if this is the first non-master table to be joined,
            OutTmpFile contains row identifiers
            OutGridFile is empty
         else
             OutGridFile contains row identifiers and one or more joined tables columns
             OutTmpFile contains old data
             (we must rename OutGridFile to OutTmpFile, and begin rewriting the newly
              created OutGridFile)}

        ReInitialiseOutputTable(iCount);

        if (iCount = 0) then
        begin
             {write column headers}

             if CheckWriteToFile.Checked then
             begin
                  {reset(OutTmpFile);}
                  readln(OutTmpFile,sTmp);
                  write(OutGridFile,sTmp + ',');

                  if (not Child.CheckLoadFileData.Checked)
                  and (not fDBFFile) then
                      SeekChildFile(0);

                  for iColumnsToIterate := 0 to (Child.SpinCol.Value-1) do
                      if (iColumnsToIterate <> Child.KeyFieldGroup.ItemIndex) then
                      begin
                           if (not Child.CheckLoadFileData.Checked) then
                           begin
                                if fDBFFile then
                                   sTmpCell := ChildTable.Fields[iColumnsToIterate].AsString
                                else
                                begin
                                     sTmpCell := ReturnChildFile(iColumnsToIterate+1,False);
                                end;
                           end
                           else
                               sTmpCell := Child.aGrid.Cells[iColumnsToIterate,0];

                           if (iColumnsToIterate <> (Child.SpinCol.Value-1)) then
                              sTmpCell := sTmpCell + ',';

                           Write(OutGridFile,sTmpCell);
                      end;

                  Writeln(OutGridFile);
             end
             else
             begin
                  {we are writing column headers from Child to new columns in BlankChild}

                  if (not Child.CheckLoadFileData.Checked) then
                  begin
                       if (not fDBFFile) then
                          SeekChildFile(0);
                  end;

                  iExistingCols := BlankChild.SpinCol.Value - Child.SpinCol.Value;

                  iC := 0;
                  for iColumnsToIterate := 0 to (Child.SpinCol.Value-1) do
                      if (iColumnsToIterate <> Child.KeyFieldGroup.ItemIndex) then
                      begin

                           if Child.CheckLoadFileData.Checked then
                              sTmpCell := Child.aGrid.Cells[iColumnsToIterate,0]
                           else
                               sTmpCell := ReturnChildFile(iColumnsToIterate+1,True);
                           Inc(iC);
                           BlankChild.aGrid.Cells[iExistingCols + iC,0] := sTmpCell;
                      end;
             end;
        end
        else
        begin
             {we are mapping data from Child to BlankChild}
             {extract key from MasterChild and see if this row is in Child}

             if fStringField then
             begin
                  MasterIdArray.rtnValue(iCount,{iCount is zero referenced, array is not}
                                         @sID);
                  iMatchedRow := findStrMatch(TableSearchArr,sID);
                  {TableSearchArr.rtnValue(iMatchedRow,@tS);
                  if localstrcomp(tS.szGeoCode,sID) then
                     iMatchedRow := -1;}
             end
             else
             begin
                  MasterIDArray.rtnValue(iCount,@iID);
                  iMatchedRow := findIntegerMatch(TableSearchArr,iID);
             end;

             {we must test if iMatchedRow contains the search key}
             if (iMatchedRow > 0) then
                fFoundRow := True
             else
                 fFoundRow := False;

             iColumnsToCopy := Child.SpinCol.Value - 1;
             if not CheckWriteToFile.Checked then
                iStartingCol := BlankChild.SpinCol.Value - iColumnsToCopy {- 1};

             try
                if CheckWriteToFile.Checked then
                begin
                     {write row identifier which has previously been written to the OutTmpFile}
                     readln(OutTmpFile,sTmp);
                     write(OutGridFile,sTmp + ',');
                end;

                if not Child.CheckLoadFileData.Checked then
                   SeekChildFile(iMatchedRow);

                iIterate := 0;
                
                for iC := 0 to (Child.SpinCol.Value - 1) do
                    if (iC <> Child.KeyFieldGroup.ItemIndex) then
                    begin
                         if fFoundRow then
                         begin
                              if Child.CheckLoadFileData.Checked then
                                 sCell := Child.aGrid.Cells[iC,
                                                            iMatchedRow]
                              else
                                  sCell := ReturnChildFile(iC + 1,True);

                              {attempt to apply Multiplier if there is one for this table}
                              if (ConvGrid.Cells[1,iTable-1] <> '') then
                                 {}
                                 try
                                    sTest := FloatToStr(StrToFloat(ConvGrid.Cells[1,iTable-1]) *
                                                        StrToFloat(sCell));
                                    sCell := sTest;

                                 except
                                       ConvGrid.Cells[1,iTable-1] := '';
                                 end;
                         end
                         else
                             sCell := '0';

                         if CheckWriteToFile.Checked then
                         begin
                              write(OutGridFile,sCell);

                              if (iIterate = (iColumnsToCopy - 1)) then
                                 writeln(OutGridFile)
                              else
                                  write(OutGridFile,',');
                         end
                         else
                             BlankChild.aGrid.Cells[iStartingCol + iIterate,iCount] := sCell;

                         Inc(iIterate);
                    end;

             except
                   Screen.Cursor := crDefault;
                   MessageDlg('Exception in ExecuteJoin, Iterate',mtError,[mbOk],0);
             end;

        end;

   end; {of MapNonMasterFields}

   procedure LoopTables;
   var
      iCount : integer;
   begin
        {loop through all the tables, writing data to the blank table (or file)}
        repeat
              try
                 InitialiseOutputTable;

                 Inc(iTable);

                 {turn list of identifiers from table into array of integer/string}
                 IdArray := Array_t.Create;
                 {table may be linked, if so, open file to read}
                 if not Child.CheckLoadFileData.Checked then
                 begin
                      if (LowerCase(
                           Copy(Child.Caption,Length(Child.Caption)-2,3))
                            = 'dbf') then
                         fDBFFile := True
                      else
                          fDBFFile := False;

                      InitChildFile;
                 end;
                 {handle string also - test whether column is int or str}

                 labelProgressTable.Caption := 'Table ' + IntToStr(iTable) +
                                               ' of ' + IntToStr(LinkTblBox.Items.Count + 1);

                 {labelProgress.Caption := 'Testing Table Identifiers (Int or String) ' + Child.Caption;
                 Refresh;
                 TestTableIdentifiers;}
                 fStringField := True; {make sort type string in all cases, saves time in parsing file}

                 labelProgress.Caption := 'Reading Table Identifiers ' + Child.Caption;
                 Refresh;

                 ReadTableIdentifiers;

                 labelProgress.Caption := 'Sorting Table Identifiers ' + Child.Caption;
                 Refresh;

                 {sort the IDArray}
                 {if fStringField then}

                 TableSearchArr := sortStrArray(IdArray);

                 {else
                     TableSearchArr := sortIntegerArray(IdArray);}

                 {now add this tables contents to the grid}
                 {loop through rows in MasterChild
                       look up the key field value in TableSearchArr
                       if key matches
                          copy data from source cells to destination cells
                          (applying multiplier if necessary)
                       else
                           write zero to destination cells
                 }

                 if (iTable = 1) then
                    labelProgress.Caption := 'Map Master Fields ' + Child.Caption
                 else
                     labelProgress.Caption := 'Map Non Master Fields ' + Child.Caption;

                 Refresh;

                 for iCount := 0 to (MasterChild.SpinRow.Value-1) do
                 begin
                      if (iTable = 1) then
                         MapMasterFields(iCount)
                      else
                          MapNonMasterFields(iCount);
                 end;

                 if CheckWriteToFile.Checked then
                    CloseChildFile;

                 {dispose IdArray, TableSearchArr}
                 IDArray.Destroy;
                 TableSearchArr.Destroy;

                 labelProgress.Caption := '';
                 labelProgressTable.Caption := '';
                 Refresh;

              except
                    Screen.Cursor := crDefault;
                    MessageDlg('Exception in Processing Table ' + Child.Caption,
                               mtError,[mbOk],0);
                    Application.Terminate;
              end;

        until (iTable > LinkTblBox.Items.Count);

   end; {of LoopTables}


begin  {of TJoinForm.ExecuteJoin}

     {execute the join with the user specified parameters}
     try
        Screen.Cursor := crHourglass;
        {build binary search arrays for key fields in each table we are using
         (including the master table)
        }

        try
           // We must save the specification for this wizard, use the specified output path
           // if we are writing directly to a file, or else use the path containing the
           // loaded table we are writing to.
           if CheckWriteToFile.Checked then
              sOutputPath := ExtractFilePath(EditFile.Text)
           else
               sOutputPath := 'c:';

           JoinForm.SaveWizardSpecification(rtnUniqueFileName(sOutputPath,'jws'));

        except
              Screen.Cursor := crDefault;
              if (mrNo = MessageDlg('There was an exception saving the specification file' + Chr(10) + Chr(13) +
                                    'for this table join.' + Chr(10) + Chr(13) +
                                    'Do you want to continue anyway?',
                                    mtConfirmation,
                                    [mbYes,mbNo],
                                    0)) then
              begin
                   Application.Terminate;
                   Exit;
              end
              else
                  Screen.Cursor := crHourglass;
        end;

        iSeekCount := 0;
        iRewindCount := 0;

        {master list table}
        {find master table name}
        sMasterTable := '';
        if (MasterIdBox.Items.Count > 0) then
           for iCount := 0 to (MasterIdBox.Items.Count - 1) do
               if MasterIdBox.Selected[iCount] then
                  sMasterTable := MasterIdBox.Items.Strings[iCount];

        MasterIdArray := Array_t.create;

        with SCPForm do
        begin
             if CheckWriteToFile.Checked then
                CreateOutputFile {we are writing to a file instead of writing to a grid}
             else
             begin
                  {create a new, empty Grid Child form to write results to}
                  sTable := 'Table ' + IntToStr(MDIChildCount + 1);
                  CreateMDIChild(sTable,True,False);
                  iBlankID := rtnTableId(sTable);
                  BlankChild := TMDIChild(MDIChildren[iBlankID]);
             end;


             iMasterID := rtnTableId(sMasterTable);
             MasterChild := TMDIChild(MDIChildren[iMasterID]);

             iTable := 0;


             LoopTables;
             {loop through all the tables, writing data to the blank table (or file)}
        end;

        MasterIDArray.Destroy;

        if CheckWriteToFile.Checked then
        begin
             {close file that we were writing to}
             CloseFile(OutGridFile);
             {close temporary file}
             CloseFile(OutTmpFile);
             {delete temporary file}
             DeleteFile(sOutTmpFile);
        end
        else
        begin
             if (BlankChild.aGrid.RowCount > 1) then
                BlankChild.aGrid.FixedRows := 1;

             BlankChild.lblDimensions.Caption := 'Rows: ' + IntToStr(BlankChild.aGrid.RowCount) +
                                                 ' Columns: ' + IntToStr(BlankChild.aGrid.ColCount);

             BlankChild.CheckLoadFileData.Checked := True;

             {set key field components and default key field/etc}
             with BlankChild do
             begin
                  KeyFieldGroup.Items.Clear;
                  KeyCombo.Items.Clear;
                  for iCount := 0 to (BlankChild.aGrid.ColCount - 1) do
                  begin
                       KeyFieldGroup.Items.Add(BlankChild.aGrid.Cells[iCount,0]);
                       KeyCombo.Items.Add(BlankChild.aGrid.Cells[iCount,0]);
                  end;
                  iCount := KeyFieldGroup.Items.IndexOf(KeyCombo.Text);
                  if (iCount >= 0) then
                     KeyFieldGroup.ItemIndex := iCount
                  else
                  begin
                       KeyFieldGroup.ItemIndex := 0;
                       KeyCombo.Text := KeyFieldGroup.Items.Strings[0];
                  end;
             end;
             BlankChild.fDataHasChanged := True;
        end;


     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ExecuteJoin',mtError,[mbOk],0);
     end;
     Screen.Cursor := crDefault;
     {}

end; {end TJoinForm.ExecuteJoin}

procedure TJoinForm.EditConvertTable;
begin
     {}
end;

function TJoinForm.CheckTblSelected : boolean;
begin
     {checks if there is at least 1 table selected}
     if (LinkTblBox.Items.Count > 0) then
        Result := True
     else
         Result := False;

     Button4.Enabled := Result;
end;

procedure TJoinForm.Button5Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex + 1;
end;

procedure TJoinForm.Button6Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex - 1;
end;

procedure TJoinForm.Button4Click(Sender: TObject);
var
   iCount : integer;
begin
     Notebook1.PageIndex := Notebook1.PageIndex + 1;

     {list Linked Tables in ConvGrid}
     ConvGrid.RowCount := LinkTblBox.Items.Count + 1;
     ConvGrid.Cells[0,0] := 'Linked Tables';
     ConvGrid.Cells[1,0] := 'Multiply By';
     for iCount := 0 to (LinkTblBox.Items.Count - 1) do
         ConvGrid.Cells[0,iCount+1] := LinkTblBox.Items.Strings[iCount];
end;

procedure TJoinForm.Button3Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex - 1;
end;

procedure TJoinForm.Button2Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex + 1;
end;

procedure TJoinForm.FormCreate(Sender: TObject);
var
   iCount : integer;
begin
     Notebook1.PageIndex := 0;

     ClientWidth := BitBtn1.Left + BitBtn1.Width + 14;
     ClientHeight := BitBtn1.Top + BitBtn1.Height + 8;

     {prepare first page of notebook}
     with SCPForm do
     if (MDIChildCount > 0) then
        for iCount := 0 to (MDIChildCount-1) do
            //if (TMDIChild(MDIChildren[iCount]).CheckLoadFileData.Checked) then
            begin
                 // only list tables that are loaded
                 MasterIdBox.Items.Add(MDIChildren[iCount].Caption);
                 AvailTblBox.Items.Add(MDIChildren[iCount].Caption);
                 ColumnMasterBox.Items.Add(MDIChildren[iCount].Caption);
            end;
end;

procedure TJoinForm.SelHighlightTblClick(Sender: TObject);
var
   iCount, iMax : integer;
begin

     if (AvailTblBox.Items.Count > 0) then
     begin
          {select any highlighted tables}
          iMax := (AvailTblBox.Items.Count - 1);
          for iCount := iMax downto 0 do
              if AvailTblBox.Selected[iCount] then
              begin
                   LinkTblBox.Items.Add(AvailTblBox.Items.Strings[iCount]);
                   {delete highlighted table}
                   AvailTblBox.Items.Delete(iCount);
              end;
     end;

     CheckTblSelected;
end;

procedure TJoinForm.UnSelHighlightTblClick(Sender: TObject);
var
   iCount, iMax : integer;
begin

     if (LinkTblBox.Items.Count > 0) then
     begin
          {deselect any highlighted tables}
          iMax := (LinkTblBox.Items.Count - 1);
          for iCount := iMax downto 0 do
              if LinkTblBox.Selected[iCount] then
              begin
                   AvailTblBox.Items.Add(LinkTblBox.Items.Strings[iCount]);
                   {delete highlighted table}
                   LinkTblBox.Items.Delete(iCount);
              end;
     end;

     CheckTblSelected;
end;

procedure TJoinForm.SelAllTblClick(Sender: TObject);
var
   iCount : integer;
begin

     if (AvailTblBox.Items.Count > 0) then
     begin
          {select all tables}
          for iCount := 0 to (AvailTblBox.Items.Count - 1) do
              LinkTblBox.Items.Add(AvailTblBox.Items.Strings[iCount]);

          {delete all tables}
          for iCount := 0 to (AvailTblBox.Items.Count - 1) do
              AvailTblBox.Items.Delete(0);
      end;

     CheckTblSelected;
end;

procedure TJoinForm.UnSelAllTblClick(Sender: TObject);
var
   iCount : integer;
begin

     if (LinkTblBox.Items.Count > 0) then
     begin
          {un-select all selected tables}
          for iCount := 0 to (LinkTblBox.Items.Count - 1) do
              AvailTblBox.Items.Add(LinkTblBox.Items.Strings[iCount]);

          {delete all tables}
          for iCount := 0 to (LinkTblBox.Items.Count - 1) do
              LinkTblBox.Items.Delete(0);
      end;

     CheckTblSelected;
end;

procedure TJoinForm.MasterIdBoxClick(Sender: TObject);
var
   iCount : integer;
begin
     if (MasterIDBox.Items.Count > 0) then
        for iCount := 0 to (MasterIdBox.Items.Count-1) do
            if MasterIdBox.Selected[iCount] then
            begin
                 Button2.Enabled := True;
                 {enable next button when table selected}
                 MasterIdBox.Hint := MasterIdBox.Items.Strings[iCount];
            end;
end;

procedure TJoinForm.BitBtn4Click(Sender: TObject);
begin
     {Execute a join with the specified parameters}
     if RadioButtonNo.Checked then
        ExecuteJoin;
     if RadioButtonYes.Checked then
        ExecuteColumnJoin(False);
end;

procedure TJoinForm.EditMultChange(Sender: TObject);
var
   rValue : real;
begin
     if (EditMult.Text <> '')
     and (EditMult.Text <> '.')
     and (EditMult.Text <> '-') then
        {test edit box contains a number}
        try
           rValue := StrToFloat(EditMult.Text);

           {write this value to highlighted table}
           ConvGrid.Cells[1,ConvGrid.Selection.Top] := EditMult.Text;

        except
              MessageDlg('Value must be a number',mtInformation,[mbOk],0);
              EditMult.Text := '';
        end;
end;

procedure TJoinForm.btnPreviousClick(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex - 1;
end;

procedure TJoinForm.ConvGridSelectCell(Sender: TObject; Col, Row: Integer;
  var CanSelect: Boolean);
begin
     EditMult.Text := ConvGrid.Cells[Col,Row];

     if (EditMult.Text = '') then
     begin
          rtnConversionChange;
          ConvGrid.Cells[Col,Row] := EditMult.Text;
     end;
     ActiveControl := EditMult;

     ConvGrid.Hint := ConvGrid.Cells[Col,Row];
end;

function TJoinForm.rtnConversionChange : extended;
var
   rConvFrom, rConvTo : extended;
   iIndexOf : integer;
begin
     try
     Result := -1;

     iIndexOf := ComboFrom.Items.IndexOf(ComboFrom.Text);

     if (iIndexOf >= 0) then
        {item is from drop down list}
        rConvFrom := rtnConversionFactor(iIndexOf)
     else
     begin
          {remove the text, user has entered some other string}
          ComboFrom.Text := '';
          rConvFrom := -1;
     end;

     iIndexOf := ComboTo.Items.IndexOf(ComboTo.Text);

     if (iIndexOf >= 0) then
        {item is from drop down list}
        rConvTo := rtnConversionFactor(iIndexOf)
     else
     begin
          {remove the text, user has entered some other string}
          ComboTo.Text := '';
          rConvTo := -1;
     end;

     if (rConvFrom > 0)
     and (rConvTo > 0) then
     begin
          Result := rConvFrom / rConvTo;
          EditMult.Text := FloatToStr(Result);
     end;

     except
           MessageDlg('Exception in rtnConversionChange',mtError,[mbOk],0);
     end;
end;

function rtnConversionFactor(const iConvert : integer) : extended;
begin
     case iConvert of
          1 : {square metres}     Result := 1;
          2 : {square kilometres} Result := 1000000;
          3 : {hectares}          Result := 10000;
          4 : {square feet}       Result := 10.8;
          5 : {square miles}      Result := 2591000;
          6 : {acres}             Result := 4049;
     else
         Result := -1;
     end;
end;

procedure TJoinForm.ComboFromChange(Sender: TObject);
begin
     rtnConversionChange;
end;

procedure TJoinForm.ComboToChange(Sender: TObject);
begin
     rtnConversionChange;
end;





procedure TJoinForm.btnNextClick(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex + 1;
end;

function rtnTableName : string;
var
   iCount : integer;
   sTable : string;
begin
     iCount := 0;

     repeat
           Inc(iCount);

           sTable := {ControlRes^.sDatabase +}
                     'table' +
                     IntToStr(iCount) +
                     '.csv';

     until not FileExists(sTable);

     Result := sTable;
end;

procedure TJoinForm.btnBrowseClick(Sender: TObject);
begin
     if (EditFile.Text = '') then
     begin
          {SaveTable.InitialDir := ControlRes^.sDatabase;}
          SaveTable.FileName := rtnTableName;
     end
     else
     begin
          SaveTable.InitialDir := ExtractFilePath(EditFile.Text);
          
     end;

     if SaveTable.Execute then
     begin
          EditFile.Text := SaveTable.FileName;
     end;
end;

procedure TJoinForm.CheckWriteToFileClick(Sender: TObject);
begin
     if (EditFile.Text = '')
     and CheckWriteToFile.Checked then
     begin
          {SaveTable.InitialDir := ControlRes^.sDatabase;}
          SaveTable.FileName := rtnTableName;

          if SaveTable.Execute then
          begin
               EditFile.Text := SaveTable.FileName;
          end;
     end;

     if (EditFile.Text = '')
     and CheckWriteToFile.Checked then
         CheckWriteToFile.Checked := False;
end;

procedure TJoinForm.RadioButtonNoClick(Sender: TObject);
begin

     RadioButtonYes.Checked := not RadioButtonNo.Checked;
     if RadioButtonNo.Checked then
        {enable next button}
        Button8.Enabled := True
     else
     begin
          {enable next button if a field has been chosen}
          if (ColumnMasterCombo.Text = '') then
             Button8.Enabled := False
          else
              Button8.Enabled := True;

     end;

end;

procedure TJoinForm.RadioButtonYesClick(Sender: TObject);
begin
     RadioButtonNo.Checked := not RadioButtonYes.Checked;

     if (ColumnMasterCombo.Text = '') then
        Button8.Enabled := False
     else
         Button8.Enabled := True;
end;


procedure TJoinForm.ColumnMasterComboChange(Sender: TObject);
begin
     if RadioButtonNo.Enabled then
        Button8.Enabled := True
     else
     begin
          if (ColumnMasterCombo.Text = '') then
             Button8.Enabled := False
          else
              Button8.Enabled := True;
     end;
end;

procedure TJoinForm.ColumnMasterBoxClick(Sender: TObject);
var
   iChildId, iCount : integer;
   Child : TMDIChild;
begin
     {load fields from the selected table into the Select AREA Field drop down
      list
      note: fields are first row of grid containing selected table}

     ColumnMasterCombo.Items.Clear;
     ColumnMasterCombo.Text := '';

     iChildId := SCPForm.rtnTableId(ColumnMasterBox.Items.Strings[ColumnMasterBox.ItemIndex]);
     Child := TMDIChild(SCPForm.MDIChildren[iChildId]);
     for iCount := 0 to (Child.aGrid.ColCount - 1) do
         ColumnMasterCombo.Items.Add(Child.aGrid.Cells[iCount,0]);

     if RadioButtonYes.Enabled then
        Button8.Enabled := False;

     ColumnMasterBox.Hint := ColumnMasterBox.Items.Strings[ColumnMasterBox.ItemIndex];
end;



procedure TJoinForm.btnBrowseTableClick(Sender: TObject);
begin
     BrowseTable;
end;



procedure TJoinForm.AvailTblBoxClick(Sender: TObject);
begin
     AvailTblBox.Hint := AvailTblBox.Items.Strings[AvailTblBox.ItemIndex];
end;

procedure TJoinForm.LinkTblBoxClick(Sender: TObject);
begin
     LinkTblBox.Hint := LinkTblBox.Items.Strings[LinkTblBox.ItemIndex];
end;

procedure TJoinForm.btnNoConversionClick(Sender: TObject);
begin
     ComboFrom.Text := 'no units';
     ComboTo.Text := 'no units';
     EditMult.Text := '';
     ConvGrid.Cells[1,ConvGrid.Selection.Top] := '';
end;

end.
