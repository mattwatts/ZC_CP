unit tbled_child;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls,
  ChildWin, ds, DdeMan,grids;

type
    str32 = string[32];

    IND_line_T = record
         sName : str32;
         iIndex : integer;
    end;

  TTblEdForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileCloseItem: TMenuItem;
    Window1: TMenuItem;
    Help1: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    WindowCascadeItem: TMenuItem;
    WindowTileItem: TMenuItem;
    WindowArrangeItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    OpenDialog: TOpenDialog;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    WindowMinimizeItem: TMenuItem;
    SpeedPanel: TPanel;
    OpenBtn: TSpeedButton;
    SaveBtn: TSpeedButton;
    CutBtn: TSpeedButton;
    CopyBtn: TSpeedButton;
    PasteBtn: TSpeedButton;
    ExitBtn: TSpeedButton;
    StatusBar: TStatusBar;
    Table1: TMenuItem;
    JoinTables1: TMenuItem;
    SaveDialog: TSaveDialog;
    GenerateRandom1: TMenuItem;
    ImportMatrix1: TMenuItem;
    DeleteRows1: TMenuItem;
    DeleteColumns1: TMenuItem;
    RandomDelete1: TMenuItem;
    Rows1: TMenuItem;
    Columns1: TMenuItem;
    Link1: TMenuItem;
    SpeedButton1: TSpeedButton;
    Fields1: TMenuItem;
    LoadERMSFieldNames1: TMenuItem;
    OpenIND: TOpenDialog;
    Tools1: TMenuItem;
    LoadFeatureToTargetReports1: TMenuItem;
    OpenFeaturesToTarget: TOpenDialog;
    N3: TMenuItem;
    OpenProject1: TMenuItem;
    SaveProject1: TMenuItem;
    OpenProject: TOpenDialog;
    SaveProject: TSaveDialog;
    ProjectBox: TListBox;
    ImportResourceWizard1: TMenuItem;
    LinkDialog: TOpenDialog;
    EditValues1: TMenuItem;
    CmdConv: TDdeServerConv;
    CmdItem: TDdeServerItem;
    N2: TMenuItem;
    FieldProperties1: TMenuItem;
    N5: TMenuItem;
    CompareContentsofTwoTables1: TMenuItem;
    SaveSubsetofRowsColumns1: TMenuItem;
    AutoFit1: TMenuItem;
    Transpose1: TMenuItem;
    CPlanReports1: TMenuItem;
    ConvertandLink1: TMenuItem;
    ConvertandOpen1: TMenuItem;
    LinkReport: TOpenDialog;
    OpenReport: TOpenDialog;
    Debug1: TMenuItem;
    MinsetTestA1: TMenuItem;
    MinsetTestB1: TMenuItem;
    RemoveLeadingCharacter1: TMenuItem;
    N6: TMenuItem;
    PasteSpecial1: TMenuItem;
    PasteMemo: TMemo;
    SQL1: TMenuItem;
    Find1: TMenuItem;
    SumFields1: TMenuItem;
    TestDestruction1: TMenuItem;
    AddCells1: TMenuItem;
    AnalyseHotspots1: TMenuItem;
    Wizards1: TMenuItem;
    ProcessHotspots1: TMenuItem;
    HotspotsSensitivityGraphs1: TMenuItem;
    RandomizeMatrix1: TMenuItem;
    ProcessRetention1: TMenuItem;
    WyongFeatureSummarise1: TMenuItem;
    CombineSimulationRegions1: TMenuItem;
    SaveExcelChunks1: TMenuItem;
    CombineDEHVeglayers1: TMenuItem;
    SplitTabareaReport1: TMenuItem;
    SumColumns1: TMenuItem;
    SumRows1: TMenuItem;
    SummariseHighestColumn1: TMenuItem;
    CoverttoPresenceAbsence1: TMenuItem;
    SaveToMarxanMatrix1: TMenuItem;
    OpenFromMarxanMatrix1: TMenuItem;
    OpenFromMarxanMatrixMaskPU1: TMenuItem;
    DeconstructPUZONE1: TMenuItem;
    SystemTest1: TMenuItem;
    Marxanwithzoning1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FileNewItemClick(Sender: TObject);
    procedure WindowCascadeItemClick(Sender: TObject);
    procedure UpdateMenuItems(Sender: TObject);
    procedure WindowTileItemClick(Sender: TObject);
    procedure WindowArrangeItemClick(Sender: TObject);
    procedure FileCloseItemClick(Sender: TObject);
    procedure FileOpenItemClick(Sender: TObject);
    procedure FileExitItemClick(Sender: TObject);
    procedure FileSaveItemClick(Sender: TObject);
    procedure FileSaveAsItemClick(Sender: TObject);
    procedure CutItemClick(Sender: TObject);
    procedure CopyItemClick(Sender: TObject);
    procedure PasteItemClick(Sender: TObject);
    procedure WindowMinimizeItemClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpAboutItemClick(Sender: TObject);
    procedure JoinTables1Click(Sender: TObject);
    function rtnTableId(const sCaption : string) : integer;
    function CreateMDIChild(const Name: string;
                            const fLoadFileData, fUser : boolean) : boolean;
    function IsNamedTable(const sFilename : string) : boolean;
    procedure SaveTable(const iChildID : integer);
    procedure GenerateRandom1Click(Sender: TObject);
    procedure GenerateRandomTable(const iPercentToPopulate, iRow, iColumn : integer;
                                  const rMax, rMin : extended;
                                  const fWriteToFile : boolean;
                                  const sFilename : string);
    procedure ImportMatrix1Click(Sender: TObject);
    procedure DeleteRows1Click(Sender: TObject);
    procedure DeleteColumns1Click(Sender: TObject);
    procedure Rows1Click(Sender: TObject);
    procedure Columns1Click(Sender: TObject);
    procedure Link1Click(Sender: TObject);
    procedure LoadERMSFieldNames1Click(Sender: TObject);
    procedure JoinTables(const fAutomaticallyLink : boolean);
    procedure LoadFeatureToTargetReports1Click(Sender: TObject);
    procedure OpenProject1Click(Sender: TObject);
    procedure SaveProject1Click(Sender: TObject);
    procedure ImportResourceWizard1Click(Sender: TObject);
    function rtnChild(const sCaption : string) : TMDIChild;
    procedure FormActivate(Sender: TObject);
    procedure EditValues1Click(Sender: TObject);
    function LinkQuery : Array_t;
    function LoadQuery : Array_t;
    procedure CmdConvExecuteMacro(Sender: TObject; Msg: TStrings);
    procedure FieldProperties1Click(Sender: TObject);
    procedure CompareContentsofTwoTables1Click(Sender: TObject);
    function rtnChildType(const sCaption : string) : string;
    function rtnChildKey(const sCaption : string) : string;
    procedure SaveSubsetofRowsColumns1Click(Sender: TObject);
    procedure AutoFit1Click(Sender: TObject);
    procedure Transpose1Click(Sender: TObject);
    procedure ConvertandLink1Click(Sender: TObject);
    procedure ConvertandOpen1Click(Sender: TObject);
    procedure MinsetTestA1Click(Sender: TObject);
    procedure MinsetTestB1Click(Sender: TObject);
    procedure RefreshMenu;
    procedure RemoveLeadingCharacter1Click(Sender: TObject);
    procedure PasteSpecial1Click(Sender: TObject);
    procedure SQL1Click(Sender: TObject);
    procedure CopyBtnClick(Sender: TObject);
    procedure PasteBtnClick(Sender: TObject);
    procedure Find1Click(Sender: TObject);
    procedure SumFields1Click(Sender: TObject);
    procedure TestDestruction1Click(Sender: TObject);
    procedure AddCells1Click(Sender: TObject);
    procedure UpdateMenus;
    procedure AnalyseHotspots1Click(Sender: TObject);
    procedure ProcessHotspots1Click(Sender: TObject);
    procedure HotspotsSensitivityGraphs1Click(Sender: TObject);
    procedure RandomizeMatrix1Click(Sender: TObject);
    procedure ProcessRetention1Click(Sender: TObject);
    procedure WyongFeatureSummarise1Click(Sender: TObject);
    procedure CombineSimulationRegions1Click(Sender: TObject);
    procedure CombineDEHVeglayers1Click(Sender: TObject);
    procedure SplitTabareaReport1Click(Sender: TObject);
    procedure SumColumns1Click(Sender: TObject);
    procedure SumRows1Click(Sender: TObject);
    procedure SummariseHighestColumn1Click(Sender: TObject);
    procedure CoverttoPresenceAbsence1Click(Sender: TObject);
    procedure SaveToMarxanMatrix1Click(Sender: TObject);
    procedure OpenFromMarxanMatrix1Click(Sender: TObject);
    procedure OpenFromMarxanMatrixMaskPU1Click(Sender: TObject);
    procedure DeconstructPUZONE1Click(Sender: TObject);
    procedure Marxanwithzoning1Click(Sender: TObject);
  private
    { Private declarations }
    procedure ShowHint(Sender: TObject);
    procedure ImportMatrix;
    procedure DeleteRows(Child : TMDIChild; const iStartRow,iEndRow : integer);
    procedure DeleteColumns(Child : TMDIChild; const iStartCol,iEndCol : integer);
    procedure ExecuteCmd(const sCmd : string);
    procedure SetKey(const sCmd : string);
    procedure ImportDataFields(const sCmd : string);
  public
    { Public declarations }
  end;

procedure ConvertCPlanReport(const sInputCSVTable, sOutputCSVTable : string);
procedure CopyGridSelectionToClipboard(const AGrid : TStringGrid;
                                       const iCopyType : integer);
procedure PasteClipboardToSelection(const AGrid : TStringGrid;
                                    const fTranspose : boolean);


var
  TblEdForm: TTblEdForm;
  fFirstActivate : boolean;

implementation

{$R *.DFM}

uses About,
     join, import,
     {ImpTools,} genrand, impexp, randdel,
     itools,
     reg, inifiles, global, savedbf,
     edittype, comptbl, save_sub, autofit, remove,
     Clipbrd, paste_sp, copy_sel, sql_tool, sortdata, operate, desttest,
  adddata, hotspots_accumulation, new_tbl, destanal,
  extract_sensitivity_graphs, rndmtx, process_retention, wyong_feat,
  CombineRegions, combineDEHveg, mask_pu, MZ_system_test;

procedure TTblEdForm.RefreshMenu;
var
   AChild : TMDIChild;

   procedure LoadedChild;
   begin
        // a loaded child is in focus
        FileSaveItem.Enabled := True;
        FileSaveAsItem.Enabled := True;

        Edit1.Enabled := True;

        ImportResourceWizard1.Enabled := True;
        JoinTables1.Enabled := True;
        ImportMatrix1.Enabled := True;
        CompareContentsOfTwoTables1.Enabled := True;
        AutoFit1.Enabled := True;
        GenerateRandom1.Enabled := True;
        RandomDelete1.Enabled := True;
        Transpose1.Enabled := True;
        FieldProperties1.Enabled := True;
        Find1.Enabled := True;
        AddCells1.Enabled := True;
        SumFields1.Enabled := True;

        Window1.Enabled := True;

        {if goEditing is in set Grid Options, check item}
        if (goEditing in AChild.aGrid.Options) then
           EditValues1.Checked := True
        else
            EditValues1.Checked := False;
   end;

   procedure LinkedChild;
   begin
        // a linked child is in focus
        FileSaveItem.Enabled := False;
        FileSaveAsItem.Enabled := False;

        Edit1.Enabled := False;

        ImportResourceWizard1.Enabled := True;
        JoinTables1.Enabled := True;
        ImportMatrix1.Enabled := True;
        CompareContentsOfTwoTables1.Enabled := False;
        AutoFit1.Enabled := False;
        GenerateRandom1.Enabled := True;
        RandomDelete1.Enabled := False;
        //Transpose1.Enabled := False;
        FieldProperties1.Enabled := True;
        Find1.Enabled := False;
        AddCells1.Enabled := False;
        SumFields1.Enabled := False;

        Window1.Enabled := True;

        EditValues1.Checked := False;
   end;

   procedure NoChildren;
   begin
        // no child is in focus
        FileSaveItem.Enabled := False;
        FileSaveAsItem.Enabled := False;

        Edit1.Enabled := False;

        ImportResourceWizard1.Enabled := False;
        JoinTables1.Enabled := False;
        ImportMatrix1.Enabled := False;
        CompareContentsOfTwoTables1.Enabled := False;
        AutoFit1.Enabled := False;
        GenerateRandom1.Enabled := True;
        RandomDelete1.Enabled := False;
        //Transpose1.Enabled := False;
        FieldProperties1.Enabled := False;
        Find1.Enabled := False;
        AddCells1.Enabled := False;
        SumFields1.Enabled := False;

        Window1.Enabled := False;

        EditValues1.Checked := False;
   end;

begin
     // this method refreshes the main form menu to make appropriate controls
     // available for
     //               1) loaded child
     //               2) linked child
     //               3) no children

     try
        if (ActiveMDIChild <> nil) then
        begin
             AChild := TMDIChild(ActiveMDIChild);

             if AChild.CheckLoadFileData.Checked then
                LoadedChild
             else
                 LinkedChild;
        end
        else
            NoChildren;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RefreshMenu',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function TTblEdForm.rtnChildType(const sCaption : string) : string;
var
   AChild : TMDIChild;
begin
     {if the child specified is Linked, return "Link" else return "Load"}
     AChild := rtnChild(sCaption);
     if AChild.CheckLoadFileData.Checked then
        Result := 'Load'
     else
         Result := 'Link';
end;

function TTblEdForm.rtnChildKey(const sCaption : string) : string;
var
   AChild : TMDIChild;
begin
     {return a Childs key field}
     AChild := rtnChild(sCaption);
     Result := AChild.KeyCombo.Text;
end;


function TTblEdForm.LinkQuery : Array_t;
var
   iResult, iCount : integer;
   fFail : boolean;
   sStr : str255;
begin
     try
        Result := Array_T.Create;
        Result.init(SizeOf(sStr),ARR_STEP_SIZE);
        fFail := True;
        LinkDialog.Title := 'Locate files to link';
        iResult := 0;

        if LinkDialog.Execute then
           if (LinkDialog.Files.Count > 0) then
           begin
                fFail := False;

                for iCount := 0 to (LinkDialog.Files.Count - 1) do
                begin
                     sStr := LinkDialog.Files.Strings[iCount];
                     if CreateMDIChild(sStr,False,False) then
                     begin
                          Inc(iResult);
                          if (iResult > Result.lMaxSize) then
                             Result.resize(Result.lMaxSize + ARR_STEP_SIZE);
                          Result.setValue(iResult,@sStr);
                     end;
                end;
           end;
        {}
        if fFail then
        begin
             {return nil result}
             Result.resize(1);
             Result.lMaxSize := 0;
        end
        else
        begin
             if (iResult <> Result.lMaxSize) then
                Result.resize(iResult);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TTblEdForm.LinkQuery',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function TTblEdForm.LoadQuery : Array_t;
var
   iResult, iCount : integer;
   fFail : boolean;
   sStr : str255;
begin
     try
        {}
        fFail := True;
        Result := Array_T.Create;
        Result.init(SizeOf(sStr),ARR_STEP_SIZE);
        OpenDialog.Title := 'Locate files to open';
        iResult := 0;

        if OpenDialog.Execute then
           if (OpenDialog.Files.Count > 0) then
           begin
                fFail := False;

                for iCount := 0 to (OpenDialog.Files.Count - 1) do
                begin
                     sStr := OpenDialog.Files.Strings[iCount];
                     if CreateMDIChild(sStr,True,False) then
                     begin
                          Inc(iResult);
                          if (iResult > Result.lMaxSize) then
                             Result.resize(Result.lMaxSize + ARR_STEP_SIZE);
                          Result.setValue(iResult,@sStr);
                     end;
                end;
           end;

        if fFail then
        begin
             {return nil result}
             Result.resize(1);
             Result.lMaxSize := 0;
        end
        else
        begin
             if (iResult <> Result.lMaxSize) then
                Result.resize(iResult);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TTblEdForm.LoadQuery',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TTblEdForm.DeleteRows(Child : TMDIChild; const iStartRow,iEndRow : integer);
var
   iColCount, iRowCount, iRowsToDelete : integer;
   sRow : string;
begin
     iRowsToDelete := iEndRow - iStartRow + 1;

     if (iRowsToDelete = 1) then
        sRow := 'a row'
     else
         sRow := IntToStr(iRowsToDelete) + ' rows';

     if (MessageDlg('This will delete ' + sRow + ' from the table' + Chr(10) + Chr(13) +
                    'Do you want to continue',mtConfirmation,[mbYes,mbNo],0)
         = mrYes) then
     begin

          {delete the rows which the selection contains}

          {copy cell contents upwards}
          for iColCount := 0 to (Child.aGrid.ColCount - 1) do
              for iRowCount := iStartRow to (Child.aGrid.RowCount - 1 - iRowsToDelete) do
                  Child.aGrid.Cells[iColCount,iRowCount] := Child.aGrid.Cells[iColCount,iRowCount+iRowsToDelete];

          {delete empty row(s) from bottom of grid}
          Child.aGrid.RowCount := Child.aGrid.RowCount - iRowsToDelete;

          Child.lblDimensions.Caption := 'Rows: ' + IntToStr(Child.AGrid.RowCount) +
                                         ' Columns: ' + IntToStr(Child.AGrid.ColCount);
     end;
end;

procedure TTblEdForm.DeleteColumns(Child : TMDIChild; const iStartCol,iEndCol : integer);
var
   iColCount, iRowCount, iColsToDelete, iElementsToMove : integer;
   sCol : string;
   AField : FieldDataType_T;
begin
     {delete the columns which the selection contains}
     iColsToDelete := iEndCol - iStartCol + 1;

     if (iColsToDelete = 1) then
        sCol := 'a column'
     else
         sCol := IntToStr(iColsToDelete) + ' columns';

     if (MessageDlg('This will delete ' + sCol + ' from the table' + Chr(10) + Chr(13) +
                    'Do you want to continue',mtConfirmation,[mbYes,mbNo],0)
         = mrYes) then
     begin
          {copy cell contents left}
          for iRowCount := 0 to (Child.aGrid.RowCount-1) do
              for iColCount := iStartCol to (Child.aGrid.ColCount - 1 - iColsToDelete) do
                  Child.aGrid.Cells[iColCount,iRowCount] := Child.aGrid.Cells[iColCount+iColsToDelete,iRowCount];

          {delete empty column(s) from right of grid}
          Child.aGrid.ColCount := Child.aGrid.ColCount - iColsToDelete;

          {adjust type definition to remove the definition for the fields that have been removed}
          // shuffle elements
          iElementsToMove := Child.DataFieldTypes.lMaxSize - iEndCol - 1;
          if (iElementsToMove > 0) then
             // if we need to shuffle elements
             for iColCount := iStartCol to (iStartCol + iElementsToMove - 1) do
             begin
                  Child.DataFieldTypes.rtnValue(iColCount + 1 + iColsToDelete,@AField);
                  Child.DataFieldTypes.setValue(iColCount + 1,@AField);
             end;
          // resize array
          Child.DataFieldTypes.resize(Child.DataFieldTypes.lMaxSize - iColsToDelete);


          Child.lblDimensions.Caption := 'Rows: ' + IntToStr(Child.AGrid.RowCount) +
                                         ' Columns: ' + IntToStr(Child.AGrid.ColCount);
     end;
end;

procedure TTblEdForm.SaveTable(const iChildID : integer);
var
   sTable : string;
   Child : TMDIChild;
   SaveDBFModule : TSaveDBFModule;
begin
     {write the data in SaveChild.aGrid to a CSV file
      note: need to check within cells for commas (done by SaveStringGrid2CSV)}

     try
        Screen.Cursor := crHourglass;

        {if file extension is dbf, change it to csv}
        Child := TMDIChild(MDIChildren[iChildID]);
        sTable := Child.Caption;
        if (LowerCase(ExtractFileExt(sTable)) = '.dbf')
        or (LowerCase(ExtractFileExt(sTable)) = '.db') then
        begin
             // saving a DBF or DB file
             SaveDBFModule := TSaveDBFModule.Create(Application);

             if FileExists(Child.Caption) then
             begin
                  if (mrYes = MessageDlg('File ' + Child.Caption + ' exists, overwrite?',
                                         mtConfirmation,[mbYes,mbNo],0)) then
                  begin
                       SaveDBFModule.WriteGridToFile(Child.Caption,
                                                     Child.aGrid,
                                                     Child.DataFieldTypes);
                       Child.fDataHasChanged := False;
                  end;
             end
             else
             begin
                  SaveDBFModule.WriteGridToFile(Child.Caption,
                                                Child.aGrid,
                                                Child.DataFieldTypes);
                  Child.fDataHasChanged := False;
             end;

             SaveDBFModule.Free;
        end
        else
        begin
             if (LowerCase(ExtractFileExt(sTable)) = '.mat') then
             begin
                  // saving a MAT file
                  if FileExists(Child.Caption) then
                  begin
                       if (mrYes = MessageDlg('File ' + Child.Caption + ' exists, overwrite?',
                                         mtConfirmation,[mbYes,mbNo],0)) then
                       begin
                            SaveStringGrid2MAT(Child.aGrid,sTable,
                                               Child.aGrid.ColCount - 1, {richness, num. of features}
                                               Child.KeyFieldGroup.ItemIndex);  {Key Column}
                            Child.fDataHasChanged := False;
                       end;
                  end
                  else
                  begin
                       SaveStringGrid2MAT(Child.aGrid,sTable,
                                          Child.aGrid.ColCount - 1, {richness, num. of features}
                                          Child.KeyFieldGroup.ItemIndex);  {Key Column}
                       Child.fDataHasChanged := False;
                  end;
             end
             else
             begin
                  // saving a CSV file
                  if FileExists(Child.Caption) then
                  begin
                       if (mrYes = MessageDlg('File ' + Child.Caption + ' exists, overwrite?',
                                         mtConfirmation,[mbYes,mbNo],0)) then
                       begin
                            SaveStringGrid2CSV(Child.aGrid,sTable);
                            Child.fDataHasChanged := False;
                       end;
                  end
                  else
                  begin
                       SaveStringGrid2CSV(Child.aGrid,sTable);
                       Child.fDataHasChanged := False;
                  end;
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exceptin in Save Table',mtError,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
end;

function TTblEdForm.rtnTableId(const sCaption : string) : integer;
var
   iCount : integer;
begin
     {}
     Result := -1;

     if (MDIChildCount > 0) then
        for iCount := 0 to (MDIChildCount-1) do
            if (MDIChildren[iCount].Caption = sCaption) then
               Result := iCount;
end;

function TTblEdForm.rtnChild(const sCaption : string) : TMDIChild;
var
   iChildId : integer;
begin
     iChildId := rtnTableId(sCaption);
     if (iChildId > -1) then
        Result := TMDIChild(MDIChildren[iChildId])
     else
         Result := nil;
end;

procedure TTblEdForm.JoinTables(const fAutomaticallyLink : boolean);
begin
     try
        {execute the Join Tables Expert form}
        JoinForm := TJoinForm.Create(Application);
        JoinForm.ShowModal;

        if fAutomaticallyLink
        and JoinForm.CheckWriteToFile.Checked then
            CreateMDIChild(JoinForm.EditFile.Text,False,False);

        JoinForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in JoinTables',mtError,[mbOk],0);
     end;
end;

procedure TTblEdForm.ImportMatrix;
begin
     try
        {execute the Join Tables Expert form}
        ImportMatrixForm := TImportMatrixForm.Create(Application);
        ImportMatrixForm.ShowModal;
        ImportMatrixForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ImportMatrix',mtError,[mbOk],0);
     end;
end;

function RunCPlanApp(const sApp : string) : boolean;
var
   sRunFile, sPath : string;
   PCmd : PChar;
   AIniFile : TIniFile;
begin
     AIniFile := TIniFile.Create(DB_INI_FILENAME);

     sPath := AIniFile.ReadString('Paths','32bit','');
     sRunFile := sPath + '\' + sApp + '.exe';

     AIniFile.Free;

     if FileExists(sRunFile) then
     begin
          GetMem(PCmd,Length(sRunFile)+1);
          StrPCopy(PCmd,sRunFile);

          WinEXEC(PCmd,SW_SHOW);

          FreeMem(PCmd,Length(sRunFile)+1);

          Result := True;
     end
     else
         Result := False;
end;


procedure TTblEdForm.FormCreate(Sender: TObject);
var
   iCount : integer;
   GIni : TIniFile;
begin
     if IsValidRegFile then
     begin
          Application.OnHint := ShowHint;
          Screen.OnActiveFormChange := UpdateMenuItems;
          fFirstActivate := True;

          // check if we need to add the Debug menu

          GIni := TIniFile.Create('cplandb.ini');
          Debug1.Visible := GIni.ReadBool('Debug','Debug',False);
          SQL1.Visible := Debug1.Visible;
          Find1.Visible := Debug1.Visible;
          GIni.Free;
     end
     else
     begin
          if not RunCPlanApp('register') then
          begin

          end;

          Application.Terminate;
          exit;
     end;
end;

procedure TTblEdForm.ShowHint(Sender: TObject);
begin
  StatusBar.SimpleText := Application.Hint;
end;

function TTblEdForm.CreateMDIChild(const Name: string;
                                  const fLoadFileData, fUser : boolean) : boolean;
var
   iCount : integer;
   Child: TMDIChild;
   fCreate : boolean;

  function InitialiseNewTable : boolean;
  var
     iCount : integer;
     AField : FieldDataType_T;
  begin
       // create a blank table with a valid set of components,
       // ready to add data to
       if fUser then
       begin
            NewTableForm := TNewTableForm.Create(Application);
            if (NewTableForm.ShowModal = mrOk) then
            begin
                 Child.aGrid.RowCount := NewTableForm.SpinRows.Value;
                 Child.aGrid.ColCount := NewTableForm.SpinCols.Value;
            end
            else
                Result := False;
            NewTableForm.Free;
       end
       else
       begin
            Child.aGrid.RowCount := 3;
            Child.aGrid.ColCount := 3;
       end;

       with Child do
       begin
            Result := True;
            aGrid.FixedRows := 1;
            aGrid.FixedCols := 1;
            CheckLockFirstRow.Checked := True;
            CheckLockFirstColumn.Checked := True;
            aGrid.Cells[0,0] := 'new';
            for iCount := 1 to (aGrid.ColCount - 1) do
                // label columns
                aGrid.Cells[iCount,0] := IntToStr(iCount);
            for iCount := 1 to (aGrid.RowCount - 1) do
                // label rows
                aGrid.Cells[0,iCount] := IntToStr(iCount);

            fDataHasChanged := True;
            CheckLoadFileData.Checked := True;
            lblDimensions.Caption := 'Rows : ' +
                                     IntToStr(aGrid.RowCount) +
                                     ' Columns: ' +
                                     IntToStr(aGrid.ColCount);

            // write default column properties for these columns
            AField.DBDataType := DBaseStr;
            AField.iSize := 254;
            AField.iDigit2 := 0;
            DataFieldTypes := Array_t.Create;
            DataFieldTypes.init(SizeOf(AField),aGrid.ColCount);
            for iCount := 1 to aGrid.ColCount do
                DataFieldTypes.setValue(iCount,@AField);
       end;

  end; {of InitialiseNewTable}

begin
     try
        Screen.Cursor := crHourglass;

        if (rtnTableId(Name) = -1) then
        begin
             Result := True;
             {create a new MDI child window }
             Child := TMDIChild.Create(Application);
             Child.Caption := Name;

             if FileExists(Name) then
             begin
                  if fLoadFileData then
                     Child.LoadFile
                  else
                      Child.LinkFile;

                  Child.fDataHasChanged := False;
                  fCreate := True;
             end
             else
             begin
                  fCreate := InitialiseNewTable;
             end;

             if fCreate then
             begin
                  Child.KeyFieldGroup.Items.Clear;
                  for iCount := 0 to (Child.aGrid.ColCount-1) do
                      Child.KeyFieldGroup.Items.Add(Child.aGrid.Cells[iCount,0]);
                  Child.KeyCombo.Items := Child.KeyFieldGroup.Items;
                  Child.KeyCombo.Text := Child.KeyFieldGroup.Items.Strings[0];
                  Child.KeyFieldGroup.ItemIndex := 0;
                  {set default key field to be first field in the grid}
             end
             else
                 Child.Free;
             UpdateMenus;
        end
        else
            Result := False;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Create Child Table',mtError,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
end;

function TTblEdForm.IsNamedTable(const sFilename : string) : boolean;
begin
     {determine if table has been loaded from/saved to a file}

     Result := False;

     if (Length(sFilename) > 6) then
        if (Copy(sFilename,1,6) = 'Table ') then
           Result := True;
end;

procedure TTblEdForm.GenerateRandomTable(const iPercentToPopulate, iRow, iColumn : integer;
                                        const rMax, rMin : extended;
                                        const fWriteToFile : boolean;
                                        const sFilename : string);
var
   iIterRow, iIterCol, iTableID, iCount : integer;
   sTable, sDataToAdd : string;
   Child : TMDIChild;
   OutFile : TextFile;
   rRandom, rDiff : extended;
begin
     try
        Screen.Cursor := crHourglass;

        if fWriteToFile then
        begin
             assignfile(OutFile,sFilename);
             rewrite(OutFile);
             write(OutFile,'Key,');
        end
        else
        begin
             sTable := 'Table ' + IntToStr(MDIChildCount + 1);
             CreateMDIChild(sTable,True,False);
             iTableId := rtnTableId(sTable);

             Child := TMDIChild(MDIChildren[iTableId]);
             Child.aGrid.RowCount := iRow;
             Child.aGrid.ColCount := iColumn;
             Child.SpinRow.Value := iRow;
             Child.SpinCol.Value := iColumn;
             Child.aGrid.Cells[0,0] := 'Key';
        end;

        {write column names}
        for iIterCol := 1 to (iColumn - 1) do
            if fWriteToFile then
            begin
                 if (iIterCol = (iColumn-1)) then
                    Writeln(OutFile,IntToStr(iIterCol))
                 else
                     write(OutFile,IntToStr(iIterCol) + ',');
            end
            else
                Child.aGrid.Cells[iIterCol,0] := IntToStr(iIterCol);

        rDiff := rMax - rMin;

        {write row names}
        for iIterRow := 1 to (iRow-1) do
        begin
             if fWriteToFile then
                write(OutFile,IntToStr(iIterRow) + ',')
             else
                 Child.aGrid.Cells[0,iIterRow] := IntToStr(iIterRow);

             {now populate it with data}
             for iIterCol := 1 to (iColumn - 1) do
             begin
                  if ((Random(99)+1) <= iPercentToPopulate) then
                  begin
                       {populate this cell with a random value}
                       rRandom := Random;
                       sDataToAdd := FloatToStr(rMin + (rRandom * rDiff));
                  end
                  else
                      sDataToAdd := '0';

                  if fWriteToFile then
                  begin
                       if (iIterCol = (iColumn - 1)) then
                          writeln(OutFile,sDataToAdd)
                       else
                           write(OutFile,sDataToAdd + ',');
                  end
                  else
                      Child.aGrid.Cells[iIterCol,iIterRow] := sDataToAdd;

             end;
        end;

        if fWriteToFile then
        begin
             CloseFile(OutFile);
        end
        else
        with Child do
        begin
             if (aGrid.RowCount > 1) then
                aGrid.FixedRows := 1;
             CheckLoadFileData.Checked := True;
             lblDimensions.Caption := 'Rows: ' + IntToStr(aGrid.RowCount) +
                                      ' Columns: ' + IntToStr(aGrid.ColCount);
             {key field objects}
             KeyFieldGroup.Items.Clear;
             KeyCombo.Items.Clear;
             for iCount := 0 to (aGrid.ColCount - 1) do
             begin
                  KeyFieldGroup.Items.Add(aGrid.Cells[iCount,0]);
                  KeyCombo.Items.Add(aGrid.Cells[iCount,0]);
             end;
             KeyFieldGroup.ItemIndex := 0;
             KeyCombo.Text := KeyCombo.Items.Strings[0];
             fDataHasChanged := True;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GenerateRandomTable',mtError,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
end;

procedure TTblEdForm.FileNewItemClick(Sender: TObject);
begin
     // create a new table for a user to enter data into

     CreateMDIChild('New Table ' + IntToStr(MDIChildCount + 1),True,True);
end;

procedure TTblEdForm.FileOpenItemClick(Sender: TObject);
var
   iCount : integer;
begin
     OpenDialog.Title := 'Locate files to open';

     if OpenDialog.Execute then
        if (OpenDialog.Files.Count > 0) then
           for iCount := 0 to (OpenDialog.Files.Count - 1) do
               CreateMDIChild(OpenDialog.Files.Strings[iCount],True,False);
end;

procedure TTblEdForm.FileCloseItemClick(Sender: TObject);
begin
  if ActiveMDIChild <> nil then
    ActiveMDIChild.Close;
end;

procedure TTblEdForm.FileSaveItemClick(Sender: TObject);
var
   Child : TMDIChild;
begin
     { save current file (ActiveMDIChild points to the window) }

     Child := TMDIChild(ActiveMDIChild);
     if Child.CheckLoadFileData.Checked then
     begin
          if IsNamedTable(ActiveMDIChild.Caption) then
             SaveTable(rtnTableID(ActiveMDIChild.Caption))
          else
              if SaveDialog.Execute then
              begin
                   ActiveMDIChild.Caption := SaveDialog.Filename;
                   SaveTable(rtnTableID(ActiveMDIChild.Caption));
              end;
     end;
end;

procedure TTblEdForm.FileSaveAsItemClick(Sender: TObject);
var
   Child : TMDIChild;
begin
     { save current file under new name }

     Child := TMDIChild(ActiveMDIChild);
     if Child.CheckLoadFileData.Checked then
     begin
          if IsNamedTable(ActiveMDIChild.Caption) then
          begin
               SaveDialog.InitialDir := ExtractFileDir(ActiveMDIChild.Caption);
               SaveDialog.Filename := ExtractFileName(ActiveMDIChild.Caption);
          end;

          if SaveDialog.Execute then
          begin
               ActiveMDIChild.Caption := SaveDialog.Filename;
               SaveTable(rtnTableID(ActiveMDIChild.Caption));
          end;
     end;
end;

procedure TTblEdForm.FileExitItemClick(Sender: TObject);
begin
  Close;
end;

procedure TTblEdForm.CutItemClick(Sender: TObject);
var
   Child : TMDIChild;
   iCol, iRow : integer;
begin
     {cut selection to clipboard}
     if (ActiveMDIChild <> nil) then
     try
        Child := TMDIChild(ActiveMDIChild);
        if (Child.checkLoadFileData.Checked) then
        begin
             // copy the selection to the clipboard
             CopyGridSelectionToClipboard(Child.aGrid,0);

             // delete contents of the selected area from the grid
             for iCol := Child.aGrid.Selection.Left to Child.aGrid.Selection.Right do
                 for iRow := Child.aGrid.Selection.Top to Child.aGrid.Selection.Bottom do
                     Child.aGrid.Cells[iCol,iRow] := '';
             Child.fDataHasChanged := True;
        end;


     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception cutting selection',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TTblEdForm.CopyItemClick(Sender: TObject);
var
   Child : TMDIChild;
begin
     {copy selection to clipboard}
     if (ActiveMDIChild <> nil) then
     try
        CopySelectionForm := TCopySelectionForm.Create(Application);
        if (CopySelectionForm.ShowModal = mrOk) then
        begin
             Child := TMDIChild(ActiveMDIChild);
             CopyGridSelectionToClipboard(Child.aGrid,
                                          CopySelectionForm.SelectWhat.ItemIndex);
        end;
        CopySelectionForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception copying selection',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TTblEdForm.PasteItemClick(Sender: TObject);
var
   Child : TMDIChild;
begin
     {paste selection from clipboard}
     if (ActiveMDIChild <> nil) then
     try
        Child := TMDIChild(ActiveMDIChild);
        if (Child.checkLoadFileData.Checked) then
        begin
             PasteClipboardToSelection(Child.aGrid,FALSE);
             Child.fDataHasChanged := True;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception cutting selection',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TTblEdForm.WindowCascadeItemClick(Sender: TObject);
begin
  Cascade;
end;

procedure TTblEdForm.WindowTileItemClick(Sender: TObject);
begin
  Tile;
end;

procedure TTblEdForm.WindowArrangeItemClick(Sender: TObject);
begin
  ArrangeIcons;
end;

procedure TTblEdForm.WindowMinimizeItemClick(Sender: TObject);
var
  I: Integer;
begin
  { Must be done backwards through the MDIChildren array }
  for I := MDIChildCount - 1 downto 0 do
    MDIChildren[I].WindowState := wsMinimized;
end;

procedure TTblEdForm.UpdateMenuItems(Sender: TObject);
begin
     UpdateMenus;
end;

procedure TTblEdForm.UpdateMenus;
var
   fEnabled : boolean;
begin
     fEnabled := MDIChildCount > 0;

     SaveProject1.Enabled := fEnabled;

     FileCloseItem.Enabled := fEnabled;
     FileSaveItem.Enabled := fEnabled;
     FileSaveAsItem.Enabled := fEnabled;
     CutItem.Enabled := fEnabled;
     CopyItem.Enabled := fEnabled;
     PasteItem.Enabled := fEnabled;
     CopyBtn.Enabled := fEnabled;
     PasteBtn.Enabled := fEnabled;
     SaveBtn.Enabled := fEnabled;
     CutBtn.Enabled := fEnabled;
     CopyBtn.Enabled := fEnabled;
     PasteBtn.Enabled := fEnabled;
     WindowCascadeItem.Enabled := fEnabled;
     WindowTileItem.Enabled := fEnabled;
     WindowArrangeItem.Enabled := fEnabled;
     WindowMinimizeItem.Enabled := fEnabled;

     RefreshMenu;
end;

procedure TTblEdForm.FormDestroy(Sender: TObject);
begin
  Screen.OnActiveFormChange := nil;
end;

procedure TTblEdForm.HelpAboutItemClick(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TTblEdForm.JoinTables1Click(Sender: TObject);
begin
     //if (MDIChildCount > 1) then
        try
           JoinTables(False);

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in Join Tables',mtError,[mbOk],0);
        end
     //else
     //    MessageDlg('You must link or open at least two tables to activate this function',
     //               mtInformation,[mbOk],0);
end;

procedure TTblEdForm.GenerateRandom1Click(Sender: TObject);
var
   rMin, rMax : extended;
begin
     GenRandForm := TGenRandForm.Create(Application);
     if (mrOk = GenRandForm.ShowModal) then
     begin
          Randomize;

          try
             rMin := StrToFloat(GenRandForm.EditMin.Text);
             rMax := StrToFloat(GenRandForm.EditMax.Text);

          except
                rMin := 0;
                rMax := 1000;
          end;

          GenerateRandomTable(GenRandForm.SpinValue.Value,
                              GenRandForm.SpinRow.Value+1,
                              GenRandForm.SpinCol.Value+1,
                              rMin,
                              rMax,
                              GenRandForm.WriteToFile.Checked,
                              GenRandForm.EditFile.Text);
     end;

     GenRandForm.Free;
end;

procedure TTblEdForm.ImportMatrix1Click(Sender: TObject);
begin
     //if (MDIChildCount > 0) then
        try
           ImportMatrix;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in Import Matrix',mtError,[mbOk],0);
        end;
     //else
     //    MessageDlg('You must link or open at least one table to activate this function',
     //               mtInformation,[mbOk],0);
end;

procedure TTblEdForm.DeleteRows1Click(Sender: TObject);
var
   Child : TMDIChild;
   iCount, iPos : integer;
begin
     {delete the rows which the selection contains}
     if (ActiveMDIChild <> nil) then
     begin
          Child := TMDIChild(ActiveMDIChild);
          if Child.CheckLoadFileData.Checked then
             if (Child.aGrid.RowCount > 2) then
             begin
                  DeleteRows(Child,
                             Child.aGrid.Selection.Top,
                             Child.aGrid.Selection.Bottom);

                  with Child do
                  begin
                       {remap key field selection components because we may have just deleted column(s)}
                       KeyFieldGroup.Items.Clear;
                       KeyCombo.Items.Clear;
                       for iCount := 0 to (aGrid.ColCount - 1) do
                       begin
                            KeyFieldGroup.Items.Add(aGrid.Cells[iCount,0]);
                            KeyCombo.Items.Add(aGrid.Cells[iCount,0]);
                       end;
                       iPos := KeyFieldGroup.Items.IndexOf(KeyCombo.Text);
                       if (iPos >= 0) then
                          KeyFieldGroup.ItemIndex := iPos
                       else
                       begin
                            KeyFieldGroup.ItemIndex := 0;
                            KeyCombo.Text := KeyCombo.Items.Strings[0];
                       end;

                       SpinRow.Value := aGrid.RowCount;
                       fDataHasChanged := True;
                  end;
             end;
     end;
end;

procedure TTblEdForm.DeleteColumns1Click(Sender: TObject);
var
   Child : TMDIChild;
   iCount, iPos : integer;
begin
     {delete the columns which the selection contains}
     if (ActiveMDIChild <> nil) then
     begin
          Child := TMDIChild(ActiveMDIChild);
          if Child.CheckLoadFileData.Checked then
             if (Child.aGrid.ColCount > (1)) then
             begin
                  DeleteColumns(Child,
                                Child.aGrid.Selection.Left,
                                Child.aGrid.Selection.Right);
                  with Child do
                  begin
                       {remap key field selection components because we may have just deleted column(s)}
                       KeyFieldGroup.Items.Clear;
                       KeyCombo.Items.Clear;
                       for iCount := 0 to (aGrid.ColCount - 1) do
                       begin
                            KeyFieldGroup.Items.Add(aGrid.Cells[iCount,0]);
                            KeyCombo.Items.Add(aGrid.Cells[iCount,0]);
                       end;
                       iPos := KeyFieldGroup.Items.IndexOf(KeyCombo.Text);
                       if (iPos >= 0) then
                          KeyFieldGroup.ItemIndex := iPos
                       else
                       begin
                            KeyFieldGroup.ItemIndex := 0;
                            KeyCombo.Text := KeyCombo.Items.Strings[0];
                       end;

                       SpinCol.Value := aGrid.ColCount;
                       fDataHasChanged := True;
                  end;
             end;
     end;
end;

procedure TTblEdForm.Rows1Click(Sender: TObject);
var
   iRowsDeleted, iRowSelected, iRowsToSelectFrom, iCol,
   iCount, iRow, iSpace, iColCount : integer;
   Child : TMDIChild;
   fSpaceFound : boolean;
begin
     if (ActiveMDIChild <> nil) then
     try
        Randomize;

        Child := TMDIChild(ActiveMDIChild);

        if Child.CheckLoadFileData.Checked then
             if (Child.aGrid.RowCount > 2) then
             begin
                  HowManyForm := THowManyForm.Create(Application);

                  with HowManyForm do
                  begin
                       Caption := 'Delete Random Rows';
                       lblQuestion.Caption := 'How many rows do you want to delete?';

                       SpinHowMany.MaxValue := Child.aGrid.RowCount - 2;
                       SpinHowMany.MinValue := 1;
                       SpinHowMany.Value := SpinHowMany.MaxValue div 2;

                       if (ShowModal = mrOk) then
                          if (SpinHowMany.Value > 0) then
                          begin
                               {randomly select some rows}
                               iRowsDeleted := 0;
                               iRowsToSelectFrom := Child.aGrid.RowCount - 1;
                               iCol := 0;
                               repeat
                                     iRowSelected := Random(iRowsToSelectFrom) + 1;

                                     if (Child.aGrid.Cells[iCol,iRowSelected] <> '') then
                                     begin
                                          Child.aGrid.Cells[iCol,iRowSelected] := '';
                                          Inc(iRowsDeleted);
                                     end;

                               until (iRowsDeleted >= SpinHowMany.Value);

                               {copy rows upwards to cover selected rows}
                               iRow := 1;
                               fSpaceFound := False;
                               repeat
                                     if (Child.aGrid.Cells[iCol,iRow] = '') then
                                     begin
                                          if not fSpaceFound then
                                          begin
                                               fSpaceFound := True;
                                               iSpace := iRow;
                                          end;

                                          Inc(iRow);
                                     end
                                     else
                                         if fSpaceFound then
                                         begin
                                              {this non space must be moved up to the space,
                                               then we must look at the row below the row we change}
                                              for iColCount := 0 to (Child.aGrid.ColCount - 1) do
                                                  Child.aGrid.Cells[iColCount,iRow] := Child.aGrid.Cells[iColCount,iSpace];
                                              iRow := iSpace + 1;
                                         end;

                               until (iRow > (iRowsToSelectFrom - iRowsDeleted));

                               {delete empty rows from the bottom}
                               Child.aGrid.RowCount := Child.aGrid.RowCount - iRowsDeleted;

                               {refresh matrix dimensions label}
                               Child.lblDimensions.Caption := 'Rows: ' + IntToStr(Child.AGrid.RowCount) +
                                                              ' Columns: ' + IntToStr(Child.AGrid.ColCount);
                               Child.fDataHasChanged := True;
                          end;



                       Free;
                  end;
             end;

     except
           MessageDlg('Exception in Delete Random Rows Click',mtError,[mbOk],0);
     end;
end;

procedure TTblEdForm.Columns1Click(Sender: TObject);
var
   iColumnsDeleted, iColumnSelected, iColumnsToSelectFrom, iRow,
   iCount, iColumn, iSpace, iRowCount : integer;
   Child : TMDIChild;
   fSpaceFound : boolean;
begin
     if (ActiveMDIChild <> nil) then
     try
        Randomize;

        Child := TMDIChild(ActiveMDIChild);

        if Child.CheckLoadFileData.Checked then
           if (Child.aGrid.ColCount > 2) then
           begin
                HowManyForm := THowManyForm.Create(Application);

                with HowManyForm do
                begin
                     Caption := 'Delete Random Rows';
                     lblQuestion.Caption := 'How many rows do you want to delete?';

                     SpinHowMany.MaxValue := Child.aGrid.ColCount - 2;
                     SpinHowMany.MinValue := 1;
                     SpinHowMany.Value := SpinHowMany.MaxValue div 2;

                     if (ShowModal = mrOk) then
                        if (SpinHowMany.Value > 0) then
                        begin
                             {randomly select some Columns}
                             iColumnsDeleted := 0;
                             iColumnsToSelectFrom := Child.aGrid.ColCount - 1;
                             iColumn := 1;
                             repeat
                                   iColumnSelected := Random(iColumnsToSelectFrom) + 1;

                                   if (Child.aGrid.Cells[iColumnSelected,1] <> '') then
                                   begin
                                        Child.aGrid.Cells[iColumnSelected,1] := '';
                                        Inc(iColumnsDeleted);
                                   end;

                             until (iColumnsDeleted >= SpinHowMany.Value);

                             {copy columns left to cover selected columns}
                             iColumnSelected := 1;
                             fSpaceFound := False;
                             repeat
                                   if (Child.aGrid.Cells[iColumnSelected,1] = '') then
                                   begin
                                        if not fSpaceFound then
                                        begin
                                             fSpaceFound := True;
                                             iSpace := iRow;
                                        end;

                                        Inc(iColumnSelected);
                                   end
                                   else
                                       if fSpaceFound then
                                       begin
                                            {this non space must be moved left to the space,
                                             then we must look at the column right of the column we change}
                                            for iRowCount := 0 to (Child.aGrid.ColCount - 1) do
                                                Child.aGrid.Cells[iSpace,iRowCount] := Child.aGrid.Cells[iColumnSelected,iRowCount];
                                            iColumnSelected := iSpace + 1;
                                       end;

                             until (iColumnSelected > (iColumnsToSelectFrom - iColumnsDeleted));

                             {delete empty Columns from the right}
                             Child.aGrid.ColCount := Child.aGrid.ColCount - iColumnsDeleted;

                             {refresh matrix dimensions label}
                             Child.lblDimensions.Caption := 'Rows: ' + IntToStr(Child.AGrid.RowCount) +
                                                            ' Columns: ' + IntToStr(Child.AGrid.ColCount);
                             Child.fDataHasChanged := True;
                        end;



                     Free;
                end;
           end;

     except
           MessageDlg('Exception in Delete Random Rows Click',mtError,[mbOk],0);
     end;
end;

procedure TTblEdForm.Link1Click(Sender: TObject);
var
   iCount : integer;
begin
     LinkDialog.Title := 'Locate files to link';

     if LinkDialog.Execute then
        if (LinkDialog.Files.Count > 0) then
           for iCount := 0 to (LinkDialog.Files.Count - 1) do
               CreateMDIChild(LinkDialog.Files.Strings[iCount],False,False);
end;

procedure TrimTrailSpaces(var sLine : str32);
var
   iPos : integer;
begin
     iPos := Length(sLine);

     if (Length(sLine) > 1) then
        while (sLine[iPos] = ' ')
        and (iPos > 1) do
            Dec(iPos);

     if (iPos < Length(sLine)) then
        sLine := Copy(sLine,1,iPos);
end;

procedure TTblEdForm.LoadERMSFieldNames1Click(Sender: TObject);
var
   Child : TMDIChild;
   IndFile : TextFile;
   FieldNameArr : Array_T;
   iFields : integer;
   {sStr : str32;}
   sLine : string;
   IND_line : IND_line_T;

   procedure LoadFieldNames;
   begin
        AssignFile(IndFile,OpenIND.Filename);

        reset(IndFile);
        readln(IndFile);

        FieldNameArr := Array_T.Create;
        FieldNameArr.init(SizeOf(IND_line),20);

        iFields := 0;
        repeat
              ReadLn(IndFile,sLine);

              if (Length(sLine) > 32) then
              begin
                   IND_line.sName := Copy(sLine,1,31);
                   TrimTrailSpaces(IND_line.sName);
                   IND_line.iIndex := StrToInt(Copy(sLine,32,Length(sLine)-31));
              end;

              Inc(iFields);
              if (iFields > FieldNameArr.lMaxSize) then
                 FieldNameArr.resize(FieldNameArr.lMaxSize + 20);
              FieldNameArr.setValue(iFields,@IND_line);

        until EOF(IndFile);

        CloseFile(IndFile);
   end;

   procedure PasteToSelectedColumns;
   var
      iColumn, iCount, iFieldCount : integer;
      sTmp : string;
   begin
        try
           for iCount := Child.aGrid.Selection.Left to Child.aGrid.Selection.Right do
           begin
                iColumn := -1;

                if (Length(Child.aGrid.Cells[iCount,0]) > Length('Value-')) then
                begin
                     sLine := Copy(Child.aGrid.Cells[iCount,0],1,6);
                     if (sLine = 'Value-') then
                     begin
                          sTmp :=Copy(Child.aGrid.Cells[iCount,0],
                                      7,
                                      Length(Child.aGrid.Cells[iCount,0])-6);

                          iColumn := StrToInt(sTmp);
                     end;
                end;

                if (iColumn > 0) then
                   for iFieldCount := 1 to FieldNameArr.lMaxSize do
                   begin
                        FieldNameArr.rtnValue(iFieldCount,@IND_line);

                        if (IND_line.iIndex = iColumn) then
                           Child.aGrid.Cells[iCount,0] := IND_line.sName;
                   end;
           end;

        except
              MessageDlg('Exception in Paste To Selected Columns',mtError,[mbOk],0);
        end;

        FieldNameArr.Destroy;
   end;

begin
     if (ActiveMDIChild <> nil) then
     begin
          {locate IND file, map feature names from it to the
           currently selected column names}
          Child := TMDIChild(ActiveMDIChild);

          OpenIND.Title := 'Locate ERMS IND file to load column names';
          if FileExists(Child.Caption) then
             OpenIND.InitialDir := ExtractFilePath(Child.Caption);

          if OpenIND.Execute then
          try
             LoadFieldNames;

             if (iFields > 0) then
                PasteToSelectedColumns;

          except
                MessageDlg('Exception in Load ERMS Field Names',mtError,[mbOk],0);
          end;
     end
     else
         MessageDlg('You must open a table to operate this function',mtInformation,[mbOk],0);

end;

procedure TTblEdForm.LoadFeatureToTargetReports1Click(Sender: TObject);
var
   Child : TMDIChild;
   iColumn, iTableId, iCount : integer;
   sTable : string;
begin
     if OpenFeaturesToTarget.Execute then
        {}
        if (OpenFeaturesToTarget.Files.Count > 0) then
        begin
             sTable := 'link feature to target reports';

             CreateMDIChild(sTable,
                            True,False);
             iTableId := rtnTableId(sTable);
             Child := TMDIChild(MDIChildren[iTableId]);

             for iCount := 0 to (OpenFeaturesToTarget.Files.Count - 1) do
             {load each of the tables into the grid}
             begin
                  (*
                  Child.aGrid.RowCount := iRow;
                  Child.aGrid.ColCount := iColumn;

                  {write column names}
                  for iIterCol := 2 to (Child.aGrid.ColCount-1) do
                      Child.aGrid.Cells[iIterCol,0] := IntToStr(iIterCol-1);
                  *)
             end;
        end;
end;

procedure TTblEdForm.OpenProject1Click(Sender: TObject);
var
   iCount, iTableId : integer;
   sItem1, sItem2,
   sAdd : string;
   Child : TMDIChild;
begin
     try
     if OpenProject.Execute then
     begin
          ProjectBox.Items.LoadFromFile(OpenProject.Filename);
          if (ProjectBox.Items.Count > 0) then
             for iCount := 0 to ((ProjectBox.Items.Count div 2) - 1) do
             begin
                  sItem1 := ProjectBox.Items.Strings[iCount*2];
                  sItem2 := ProjectBox.Items.Strings[(iCount*2)+1];
                  {test if we have this file open, if not, open/link it}
                  iTableId := rtnTableId(sItem2);
                  if (iTableId = -1) then
                  begin
                       {table is not open}
                       if (Copy(sItem1,1,4) = 'load') then
                          CreateMDIChild(sItem2,True,False)
                       else
                           CreateMDIChild(sItem2,False,False);

                       iTableId := rtnTableId(sItem2);
                       Child := TMDIChild(MDIChildren[iTableId]);
                       Child.KeyFieldGroup.ItemIndex := StrToInt(Copy(sItem1,8,1));
                  end;
             end;
     end;
     except
           MessageDlg('Exception in Open Project',mtError,[mbOk],0);
     end;
end;

procedure TTblEdForm.SaveProject1Click(Sender: TObject);
var
   iCount : integer;
   sAdd : string;
   Child : TMDIChild;
begin
     try
     if SaveProject.Execute then
     begin
          ProjectBox.Items.Clear;

          if (MDIChildCount > 0) then
             for iCount := 0 to (MDIChildCount-1) do
                 if FileExists(MDIChildren[iCount].Caption) then
                 begin
                      Child := TMDIChild(MDIChildren[iCount]);
                      if Child.CheckLoadFileData.Checked then
                         sAdd := 'load '
                      else
                          sAdd := 'link ';

                      ProjectBox.Items.Add(sAdd);
                      ProjectBox.Items.Add(Child.Caption);
                 end;

          if (ProjectBox.Items.Count > 0) then
             ProjectBox.Items.SaveToFile(SaveProject.Filename);
     end;
     except
           MessageDlg('Exception in Save Project',mtError,[mbOk],0);
     end;
end;

procedure TTblEdForm.ImportResourceWizard1Click(Sender: TObject);
begin
     //if (MDIChildCount > 1) then
        try
           ImportDataFieldForm := TImportDataFieldForm.Create(Application);
           ImportDataFieldForm.ShowModal;
           ImportDataFieldForm.Free;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in Import Data Field Wizard',
                         mtError,[mbOk],0);
        end
     //else
     //    MessageDlg('You must link or open at least two tables to activate this function',
     //               mtInformation,[mbOk],0);
end;

procedure TTblEdForm.FormActivate(Sender: TObject);
var
   iCount : integer;
begin
     if fFirstActivate then
     begin
          {load any files that have been passed to us as parameters}
          if (ParamCount > 0) then
             for iCount := 1 to ParamCount do
                 if FileExists(ParamStr(iCount)) then
                    CreateMDIChild(ParamStr(iCount), {filename of table to load}
                                   TRUE,False);            {load table contents into the grid}
     end;
     fFirstActivate := False;

     //RefreshMenu;
     UpdateMenus;
end;

procedure TTblEdForm.EditValues1Click(Sender: TObject);
var
   Child : TMDIChild;
begin
     {toggle the goEditing option of the grid if data is loaded into the grid}
     if (ActiveMDIChild <> nil) then
     begin
          Child := TMDIChild(ActiveMDIChild);
          if Child.CheckLoadFileData.Checked then
          begin
               {if goEditing is in set Child.aGrid.Options, then remove it, else add it}
               if goEditing in Child.aGrid.Options then
               begin
                    Child.aGrid.Options := [goFixedVertLine,goFixedHorzLine,goVertLine,
                                            goHorzLine,goRangeSelect,goColSizing,goRowSizing,
                                            goColMoving,goRowMoving];
                    EditValues1.Checked := False;
                    Child.StatusBar.SimpleText := 'Table is in select mode';
               end
               else
               begin
                    Child.aGrid.Options := [goFixedVertLine,goFixedHorzLine,goVertLine,
                                            goHorzLine,goRangeSelect,goColSizing,goRowSizing,
                                            goColMoving,goRowMoving,goEditing];
                    EditValues1.Checked := True;
                    Child.StatusBar.SimpleText := 'Table is in edit mode';
               end;
          end;
     end;
end;

procedure TTblEdForm.SetKey(const sCmd : string);
var
   sLine, sTable, sKey : string;
   iSpacePos : integer;
   AChild : TMDIChild;
begin
     {}
     sLine := Copy(sCmd,5,Length(sCmd)-4);
     iSpacePos := Pos(' ',sLine);
     sKey := Copy(sLine,1,iSpacePos-1);
     sTable := Copy(sLine,iSpacePos+1,Length(sLine)-iSpacePos-1);
     AChild := TblEdForm.rtnChild(sTable);
     AChild.KeyCombo.Text := sKey;
     AChild.KeyFieldGroup.ItemIndex := AChild.KeyFieldGroup.Items.IndexOf(sKey);
end;

procedure TTblEdForm.ImportDataFields(const sCmd : string);
var
   sLine, sFld, sSrcTbl, sDestTbl : string;
   iSeekPos : integer;
begin
     try
        {sCmd is of structure:
              'import fld "src tbl" "dest tbl"'
        }
        sLine := Copy(sCmd,8,Length(sCmd)-7);
        iSeekPos := Pos(sLine,' ');
        sFld := Copy(sCmd,1,iSeekPos-1);
        sLine := Copy(sLine,iSeekPos+2,Length(sLine)-iSeekPos-1);
        iSeekPos := Pos(sLine,'"');
        sSrcTbl := Copy(sLine,1,iSeekPos-1);
        sDestTbl := Copy(sLine,iSeekPos+3,Length(sLine)-Length(sSrcTbl)-4);

        MessageDlg('TTblEdForm.ImportDataFields ' +
                   sFld + ' ' + sSrcTbl + ' ' + sDestTbl,
                   mtInformation,[mbOk],0);

        {set up components on Import Data Fields wizard and run it}
        ImportDataFieldForm := TImportDataFieldForm.Create(Application);

        with ImportDataFieldForm do
        begin
             {table to receive data}
             UpdateTblBox.ItemIndex := UpdateTblBox.Items.IndexOf(sDestTbl);

             {table to provide data}
             LinkGrid.RowCount := 2;
             LinkGrid.Cells[0,1] := sSrcTbl;
             LinkGrid.Cells[1,1] := sFld;

             {name of field to be added, same because we are not changing the name}
             ConvertGrid.Cells[0,1] := sFld;
             ConvertGrid.Cells[1,1] := sFld;

             ExecImportDataField;
             Free;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TTblEdForm.ImportDataFields',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TTblEdForm.ExecuteCmd(const sCmd : string);
var
   sLowerCaseCmd : string;
begin
     try
        {possible commands are:

                  link
                  load
                  set key
                  import data field(s)
                  exit table_ed
                  areyouthere}

        sLowerCaseCmd := LowerCase(sCmd);

        if (Length(sCmd) >= 4) then
        begin
             case sLowerCaseCmd[1] of
                  'a' : {are you there};
                  'l' : if (sLowerCaseCmd[2] = 'i') then
                           {link}  CreateMDIChild(Copy(sLowerCaseCmd,6,Length(sLowerCaseCmd)-5),False,False)
                        else
                            {load} CreateMDIChild(Copy(sLowerCaseCmd,6,Length(sLowerCaseCmd)-5),True,False);
                  's' : {set key}
                        SetKey(sLowerCaseCmd);
                  'i' : {import data field(s)}
                        ImportDataFields(sLowerCaseCmd);
                  'e' : {exit}
                  begin
                       Application.Terminate;
                       Exit;
                  end;
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TTblEdForm.ExecuteCmd',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TTblEdForm.CmdConvExecuteMacro(Sender: TObject; Msg: TStrings);
var
   iCount : integer;
begin
     try
        if (Msg.Count > 0) then
           for iCount := 0 to (Msg.Count - 1) do
               ExecuteCmd(Msg[iCount]);
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TTblEdForm.CmdConvExecuteMacro',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TTblEdForm.FieldProperties1Click(Sender: TObject);
var
   Child : TMDIChild;
begin
     if (ActiveMDIChild <> nil) then
     try
        Child := TMDIChild(ActiveMDIChild);

        {if Child.CheckLoadFileData.Checked then}
        {this is used to determine if data is loaded into grid or not}

        EditTypeForm := TEditTypeForm.Create(Application);

        EditTypeForm.initchild(Child);

        if (EditTypeForm.ShowModal = mrOk) then
           {user has clicked ok}
           EditTypeForm.UpdateTypes(Child)
        else
            {user has clicked cancel};


        EditTypeForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Edit Field Properties',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TTblEdForm.CompareContentsofTwoTables1Click(Sender: TObject);
begin
     try
        CompareTablesForm := TCompareTablesForm.Create(Application);

        {list available loaded tables on the CompareContentsForm}
        CompareTablesForm.ListAvailableTables;

        if (CompareTablesForm.ListBox1.Items.Count > 1) then
           CompareTablesForm.ShowModal
        else
            MessageDlg('You must have at least two tables loaded to activate this function',
                       mtInformation,[mbOk],0);

        CompareTablesForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Compare Tables',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TTblEdForm.SaveSubsetofRowsColumns1Click(Sender: TObject);
var
   Child : TMDIChild;
begin
     {delete the rows which the selection contains}
     if (ActiveMDIChild <> nil) then
     begin
          Child := TMDIChild(ActiveMDIChild);
          if Child.CheckLoadFileData.Checked then
          begin
               // This function can be performed on the currently selected table
               SaveSubsetForm := TSaveSubsetForm.Create(Application);
               SaveSubsetForm.LoadChildInfo(Child.Caption);
               SaveSubsetForm.ShowModal;
               SaveSubsetForm.Free;
          end;
     end;
end;

procedure TTblEdForm.AutoFit1Click(Sender: TObject);
var
   Child : TMDIChild;
begin
     if (ActiveMDIChild <> nil) then
     begin
          Child := TMDIChild(ActiveMDIChild);
          if Child.CheckLoadFileData.Checked then
          begin
               AutoFitForm := TAutoFitForm.Create(Application);
               AutoFitForm.sTable := Child.Caption;
               AutoFitForm.ShowModal;
               AutoFitForm.Free;
          end;
     end;
end;

procedure TTblEdForm.Transpose1Click(Sender: TObject);
var
   NewChild, Child : TMDIChild;
   sTable : string;
   iTableId, iColumnCount, iRowCount : integer;
begin
     try
        if (ActiveMDIChild <> nil) then
        begin
             Child := TMDIChild(ActiveMDIChild);
             if Child.CheckLoadFileData.Checked then
             begin
                  Screen.Cursor := crHourglass;
                  // Transpose Child

                  // create a new child
                  sTable := 'Table ' + IntToStr(MDIChildCount + 1);
                  CreateMDIChild(sTable,True,False);
                  Screen.Cursor := crHourglass;
                  iTableId := rtnTableId(sTable);
                  NewChild := TMDIChild(MDIChildren[iTableId]);
                  // set the dimensions of the new child
                  NewChild.aGrid.RowCount := Child.aGrid.ColCount;
                  NewChild.aGrid.ColCount := Child.aGrid.RowCount;
                  NewChild.lblDimensions.Caption := 'Rows : ' + IntToStr(NewChild.aGrid.RowCount) + ' Columns: ' + IntToStr(NewChild.aGrid.ColCount);
                  if (NewChild.aGrid.RowCount > 1) then
                     NewChild.aGrid.FixedRows := 1
                  else
                      NewChild.CheckLockFirstRow.Checked := False;

                  // populate the new child with cell values from the old child
                  for iColumnCount := 0 to (Child.aGrid.ColCount-1) do
                      for iRowCount := 0 to (Child.aGrid.RowCount-1) do
                          NewChild.aGrid.Cells[iRowCount,iColumnCount] := Child.aGrid.Cells[iColumnCount,iRowCount];

                  // set the key field for the new child
                  NewChild.KeyFieldGroup.Items.Clear;
                  NewChild.KeyCombo.Items.Clear;
                  for iColumnCount := 0 to (NewChild.aGrid.ColCount-1) do
                  begin
                       NewChild.KeyFieldGroup.Items.Add(NewChild.aGrid.Cells[iColumnCount,0]);
                       NewChild.KeyCombo.Items.Add(NewChild.aGrid.Cells[iColumnCount,0]);
                  end;
                  NewChild.KeyFieldGroup.ItemIndex := 0;
                  NewChild.KeyCombo.Text := NewChild.KeyCombo.Items.Strings[0];

                  NewChild.CheckLoadFileData.Checked := True;

                  Screen.Cursor := crDefault;
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TTblEdForm.Transpose',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function GetConvertFilename(const sOriginal : string) : string;
var
   iLength : integer;
begin
     // add _convert to the filename that has been passed
     iLength := Length(sOriginal);
     if (Pos('.',sOriginal) = (iLength-3)) then
        Result := Copy(sOriginal,1,iLength-4) +
                  '_convert' +
                  Copy(sOriginal,iLength-3,4)
     else
         Result := sOriginal + '_convert';
end;


procedure ConvertCPlanReport(const sInputCSVTable, sOutputCSVTable : string);
var
   InputTable, OutputTable : TextFile;
   sLine : string;
begin
     // Creates a new copy of the input CSV table, except without the first row.
     // Puts the copy in a new file which is the same except for _convert being
     // appended to the filename before the .extension
     try
        assignfile(InputTable,sInputCSVTable);
        assignfile(OutputTable,sOutputCSVTable);
        reset(InputTable);
        rewrite(OutputTable);

        // read and discard the header row from the C-Plan CSV report table
        readln(InputTable);

        repeat
              // read and write each other line from the table
              readln(InputTable,sLine);
              writeln(OutputTable,sLine);

        until EOF(InputTable);

        closefile(InputTable);
        closefile(OutputTable);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ConvertCPlanReport "' + sInputCSVTable + '"',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TTblEdForm.ConvertandLink1Click(Sender: TObject);
var
   iCount : integer;
   sNewFile : string;
begin
     LinkReport.Title := 'Locate C-Plan reports to convert and link';

     if LinkReport.Execute then
        if (LinkReport.Files.Count > 0) then
           for iCount := 0 to (LinkReport.Files.Count - 1) do
           begin
                sNewFile := GetConvertFilename(LinkReport.Files.Strings[iCount]);
                ConvertCPlanReport(LinkReport.Files.Strings[iCount],sNewFile);
                CreateMDIChild(sNewFile,False,False);
           end;
end;

procedure TTblEdForm.ConvertandOpen1Click(Sender: TObject);
var
   iCount : integer;
   sNewFile : string;
begin
     OpenReport.Title := 'Locate C-Plan reports to convert and load';

     if OpenReport.Execute then
        if (OpenReport.Files.Count > 0) then
           for iCount := 0 to (OpenReport.Files.Count - 1) do
           begin
                sNewFile := GetConvertFilename(OpenReport.Files.Strings[iCount]);
                ConvertCPlanReport(OpenReport.Files.Strings[iCount],sNewFile);
                CreateMDIChild(sNewFile,True,False);
           end;
end;

procedure TTblEdForm.MinsetTestA1Click(Sender: TObject);
begin
     //
end;

procedure TTblEdForm.MinsetTestB1Click(Sender: TObject);
begin
     //
end;

procedure TTblEdForm.RemoveLeadingCharacter1Click(Sender: TObject);
begin
     if (ActiveMDIChild <> nil) then
     begin
          RemoveChild := TMDIChild(ActiveMDIChild);
          RemoveCharForm := TRemoveCharForm.Create(Application);
          RemoveCharForm.ShowModal;
          RemoveCharForm.Free;
     end;
end;

procedure ReadCellsFromLine(const sLine : string;
                            var Cells : Array_t);
var
   fEnd : boolean;
   iPosition,
   iCount, iRowValuesCount, iColumn : integer;
   sTmp : string;
   sCell : str255;
begin
     try
        Cells := Array_t.Create;
        Cells.init(SizeOf(str255),ARR_STEP_SIZE);

        iRowValuesCount := 0;
        iColumn := 0;
        sTmp := sLine;
        fEnd := False;

        if (sTmp <> '') then
        repeat
              if (sTmp[1] = '"') then
              begin
                   // this cell delimited by "
                   iPosition := Pos('"',sTmp);
                   Inc(iPosition);
              end
              else
                  // this cell delimited by ,
                  iPosition := Pos(',',sTmp);

              if (iPosition < Length(sTmp))
              and (iPosition > 0) then
              begin
                   if (iPosition = 1) then
                   begin
                        //if (Length(sTmp) > 1) then
                        //   sTmp := Copy(sTmp,2,Length(sTmp))
                        //else
                        //    sTmp := '';
                        sCell := '';

                   end
                   else
                   begin
                        sCell := Copy(sTmp,1,iPosition-1);
                        //if (sTmp
                   end;
              end
              else
                  sCell := sTmp;

              // store this cell
              Inc(iColumn);
              if (iColumn > Cells.lMaxSize) then
                 Cells.resize(Cells.lMaxSize + ARR_STEP_SIZE);
              Cells.setValue(iColumn,@sCell);

              // set sTmp to be the rest of the line - this cell
              if ((iPosition+1) <= Length(sTmp))
              and (iPosition > 0) then
                  sTmp := Copy(sTmp,iPosition+1,Length(sTmp)-iPosition)
              else
                  sTmp := '';

        until (sTmp = '');

        // adjust the size of the array we have just created
        if (iColumn = 0) then
        begin
             Cells.resize(1);
             Cells.lMaxSize := 0;
        end
        else
        begin
             if (iColumn <> Cells.lMaxSize) then
                Cells.resize(iColumn);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReadCellsFromLine',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure PasteClipboardToSelection(const AGrid : TStringGrid;
                                    const fTranspose : boolean);
var
   iColumns, iRows, iCount, iColumnSpace, iRowSpace : integer;
   sLine : string;
   sCell : str255;
   Cells : Array_t;

   procedure TransposePasteCells;
   var
      iTop, iLeft, iColCount, iRowCount : integer;
   begin
        iTop := AGrid.Selection.Top;
        iLeft := AGrid.Selection.Left;

        for iRowCount := 0 to (iRows-1) do
        begin
             sLine := TblEdForm.PasteMemo.Lines.Strings[iRowCount];
             // read the columns in this row
             ReadCellsFromLine(sLine,
                               Cells);
             // write the columns (transposed) to the table
             for iColCount := 0 to (iColumns-1) do
             begin
                  Cells.rtnValue(iColCount+1,@sCell);
                  AGrid.Cells[iLeft + iRowCount,iTop + iColCount] := sCell;
             end;

             Cells.Destroy;
        end;
   end;

   procedure PasteCells;
   var
      iTop, iLeft, iColCount, iRowCount : integer;
   begin
        iTop := AGrid.Selection.Top;
        iLeft := AGrid.Selection.Left;

        for iRowCount := 0 to (iRows-1) do
        begin
             sLine := TblEdForm.PasteMemo.Lines.Strings[iRowCount];
             // read the columns in this row
             ReadCellsFromLine(sLine,
                               Cells);
             // write the columns to the table
             for iColCount := 0 to (iColumns-1) do
             begin
                  if (iColCount < Cells.lMaxSize) then
                     Cells.rtnValue(iColCount+1,@sCell)
                  else
                      sCell := '';

                  AGrid.Cells[iLeft + iColCount,iTop + iRowCount] := sCell;
             end;

             Cells.Destroy;
        end;
   end;

begin
     try
        if Clipboard.HasFormat(CF_TEXT) then
        begin
             TblEdForm.PasteMemo.Clear;
             TblEdForm.PasteMemo.PasteFromClipboard;

             // read the number of columns and rows from the memo
             iRows := TblEdForm.PasteMemo.Lines.Count;
             iColumns := 0;
             for iCount := 0 to (iRows-1) do
             begin
                  sLine := TblEdForm.PasteMemo.Lines.Strings[iCount];
                  // see how many columns are in this row
                  ReadCellsFromLine(sLine,
                                    Cells);
                  if (Cells.lMaxSize > iColumns) then
                     iColumns := Cells.lMaxSize;
                  Cells.Destroy;
             end;

             // if the columns and rows can fit into the destination table,
             // write them there
             iColumnSpace := AGrid.ColCount - AGrid.Selection.Left;
             iRowSpace := AGrid.RowCount - AGrid.Selection.Top;

             if fTranspose then
             begin
                  // we are reversing columns and rows
                  if (iColumns <= iRowSpace)
                  and (iRows <= iColumnSpace) then
                     TransposePasteCells
                  else
                      MessageDlg('There is not enough room to paste the selection.',
                                 mtInformation,[mbOk],0);
             end
             else
             begin
                  // we are not reversing columns and rows
                  if (iRows <= iRowSpace)
                  and (iColumns <= iColumnSpace) then
                     PasteCells
                  else
                      MessageDlg('There is not enough room to paste the selection.',
                                 mtInformation,[mbOk],0);
             end;

             //TblEdForm.PasteMemo.Lines.SaveToFile('c:\pml.txt');
             TblEdForm.PasteMemo.Clear;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in PasteClipboardToSelection',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure CopyGridSelectionToClipboard(const AGrid : TStringGrid;
                                       const iCopyType : integer);
{iCopyType = 0  cells
             1  columns
             2  rows
             3  entire grid}
var
   pStart : PChar;
   iRowCount, iColumnCount, iCharCount, iDataSize, iCurrChar,
   iStartCol, iEndCol, iStartRow, iEndRow : integer;
begin
     {copy any highlighted fields as text to the clipboard}
     if (AGrid.RowCount > 1) then
     begin
          iDataSize := 0;

          {find the size of data block to create}
          case iCopyType of
               0 : begin // cells
                        iStartCol := AGrid.Selection.Left;
                        iEndCol := AGrid.Selection.Right;
                        iStartRow := AGrid.Selection.Top;
                        iEndRow := AGrid.Selection.Bottom;
                   end;
               1 : begin // columns
                        iStartCol := AGrid.Selection.Left;
                        iEndCol := AGrid.Selection.Right;
                        iStartRow := 0;
                        iEndRow := AGrid.RowCount - 1;
                   end;
               2 : begin // rows
                        iStartCol := 0;
                        iEndCol := AGrid.ColCount - 1;
                        iStartRow := AGrid.Selection.Top;
                        iEndRow := AGrid.Selection.Bottom;
                   end;
               3 : begin // entire grid
                        iStartCol := 0;
                        iEndCol := AGrid.ColCount - 1;
                        iStartRow := 0;
                        iEndRow := AGrid.RowCount - 1;
                   end;
          end;

          // add the size of each selected cell in the selected column(s) and row(s)
          for iRowCount := iStartRow to iEndRow do
          begin
               for iColumnCount := iStartCol to iEndCol do
                   Inc(iDataSize,Length(AGrid.Cells[iColumnCount,iRowCount])+1);
               Inc(iDataSize,1);
          end;

          Inc(iDataSize,1); {make 1 space for the null character}

          pStart := StrAlloc(iDataSize);

          iCurrChar := 0;
          {create null terminated string list}
          // add the cell values for the selected column(s) and row(s)
          for iRowCount := iStartRow to iEndRow do
              for iColumnCount := iStartCol to iEndCol do
              begin
                   for iCharCount := 1 to Length(AGrid.Cells[iColumnCount,iRowCount]) do
                   begin
                        pStart[iCurrChar] := AGrid.Cells[iColumnCount,iRowCount][iCharCount];
                        Inc(iCurrChar);
                   end;
                   // add a comma as a cell seperator between cells within a row
                   if (iColumnCount <> iEndCol) then
                   begin
                        pStart[iCurrChar] := ',';
                        Inc(iCurrChar);
                   end
                   else
                   // add an end of line marker to the last cell in the row
                   begin
                        pStart[iCurrChar] := Chr(13); {add CR}
                        Inc(iCurrChar);
                        pStart[iCurrChar] := Chr(10); {add LF}
                        Inc(iCurrChar);
                   end;
              end;

          pStart[iCurrChar] := #0; {add null character to terminate PChar}

          Clipboard.SetTextBuf(pStart);
     end;
end;

procedure TTblEdForm.PasteSpecial1Click(Sender: TObject);
begin
     if (ActiveMDIChild <> nil) then
     begin
          PasteSpecialChild := TMDIChild(ActiveMDIChild);
          PasteSpecialForm := TPasteSpecialForm.Create(Application);
          PasteSpecialForm.CheckTranspose.Checked := True;
          PasteSpecialForm.btnPasteClick(Sender);
          PasteSpecialForm.Free;
     end;
end;

procedure TTblEdForm.SQL1Click(Sender: TObject);
begin
     SQLToolForm := TSQLToolForm.Create(Application);
     SQLToolForm.ShowModal;
     SQLToolForm.Free;
end;

procedure TTblEdForm.CopyBtnClick(Sender: TObject);
begin
     CopyItemClick(Sender);
end;

procedure TTblEdForm.PasteBtnClick(Sender: TObject);
begin
     PasteItemClick(Sender);
end;

procedure TTblEdForm.Find1Click(Sender: TObject);
var
   iCount : integer;
begin
     if (ActiveMDIChild <> nil) then
     begin
          SortChild := TMDIChild(ActiveMDIChild);

          SortDataForm := TSortDataForm.Create(Application);
          SortDataForm.ComboSortField.Items.Clear;
          for iCount := 0 to (SortChild.KeyCombo.Items.Count-1) do
              SortDataForm.ComboSortField.Items.Add(SortChild.KeyCombo.Items.Strings[iCount]);
          SortDataForm.ComboSortField.ItemIndex := SortChild.KeyCombo.ItemIndex;    
          SortDataForm.ComboSortField.Text := SortChild.KeyCombo.Text;
          SortDataForm.Caption := 'Sort Table ' + SortChild.Caption;
          SortDataForm.ShowModal;
          SortDataForm.Free;
     end;
end;

procedure TTblEdForm.SumFields1Click(Sender: TObject);
begin
     if (ActiveMDIChild <> nil) then
     try
        OperationChild := TMDIChild(ActiveMDIChild);
        OperationForm := TOperationForm.Create(Application);
        OperationForm.ShowModal;
        OperationForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Sum Fields',mtError,[mbOk],0);
     end;
end;

procedure TTblEdForm.TestDestruction1Click(Sender: TObject);
begin
     DestructTestForm := TDestructTestForm.Create(Application);
     DestructTestForm.ShowModal;
     DestructTestForm.Free;
end;

procedure TTblEdForm.AddCells1Click(Sender: TObject);
begin
     if (ActiveMDIChild <> nil) then
     try
        AddDataForm := TAddDataForm.Create(Application);
        AddDataForm.AddChild := TMDIChild(ActiveMDIChild);

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

procedure TTblEdForm.AnalyseHotspots1Click(Sender: TObject);
begin
     HotspotsAnalysisForm := THotspotsAnalysisForm.Create(Application);
     HotspotsAnalysisForm.ShowModal;
     HotspotsAnalysisForm.Free;
end;

procedure TTblEdForm.ProcessHotspots1Click(Sender: TObject);
begin
     DestructAnalyseForm := TDestructAnalyseForm.Create(Application);
     DestructAnalyseForm.ShowModal;
     DestructAnalyseForm.Free;
end;

procedure TTblEdForm.HotspotsSensitivityGraphs1Click(Sender: TObject);
begin
     ExtractSensitivityGraphsForm := TExtractSensitivityGraphsForm.Create(Application);
     ExtractSensitivityGraphsForm.ShowModal;
     ExtractSensitivityGraphsForm.Free;
end;

procedure TTblEdForm.RandomizeMatrix1Click(Sender: TObject);
begin
     // perform mals random matrix op
     // randomly move the matrix cells around, regarding tenure
     // input file is table with SiteKey,Tenure (or Status?)
     // RandomizeMatrix using Mal's methodology for Cape dataset
     if (ActiveMDIChild <> nil) then
     try
        Randomize;
        RndMtxForm := TRndMtxForm.Create(Application);
        if (RndMtxForm.ShowModal = mrOk) then
           // randomize the table
           RndMtxForm.RandomizeChild(TMDIChild(ActiveMDIChild));
        RndMtxForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RandMtx',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TTblEdForm.ProcessRetention1Click(Sender: TObject);
begin
     ProcessRetentionForm := TProcessRetentionForm.Create(Application);
     ProcessRetentionForm.ShowModal;
     ProcessRetentionForm.Free;
end;

procedure TTblEdForm.WyongFeatureSummarise1Click(Sender: TObject);
begin
     WyongFeatureForm := TWyongFeatureForm.Create(Application);
     WyongFeatureForm.ShowModal;
     WyongFeatureForm.Free;
end;

procedure TTblEdForm.CombineSimulationRegions1Click(Sender: TObject);
begin
     CombineRegionsForm := TCombineRegionsForm.Create(Application);
     CombineRegionsForm.ShowModal;
     CombineRegionsForm.Free;
end;

procedure TTblEdForm.CombineDEHVeglayers1Click(Sender: TObject);
begin
     CombineDEHVegForm := TCombineDEHVegForm.Create(Application);
     CombineDEHVegForm.ShowModal;
     CombineDEHVegForm.Free;
end;

procedure TTblEdForm.SplitTabareaReport1Click(Sender: TObject);
var
   SplitChild : TMDIChild;
   iCount, iOutputFiles, iCountOutput : integer;
   OutputFile, SummaryFile : TextFile;
   sOutputName, sIdentifier : string;
   rCellValue : extended;
begin
     if (ActiveMDIChild <> nil) then
     begin
          sIdentifier := 'landscapes';

          SplitChild := TMDIChild(ActiveMDIChild);
          iOutputFiles := SplitChild.aGrid.ColCount - 1;

          assignfile(SummaryFile,'d:\temp\' + sIdentifier + '_summary.csv');
          rewrite(SummaryFile);
          writeln(SummaryFile,'feature name,table name');

          for iCountOutput := 1 to iOutputFiles do
          begin
               sOutputName := SplitChild.aGrid.Cells[iCountOutput,0];

               writeln(SummaryFile,sOutputName + ',' + sIdentifier + IntToStr(iCountOutput));

               assignfile(OutputFile,'d:\temp\' + sIdentifier + IntToStr(iCountOutput) + '.csv');
               rewrite(OutputFile);
               writeln(OutputFile,'Key,' + sOutputName);
               for iCount := 1 to (SplitChild.aGrid.RowCount-1) do
               begin
                    try
                       rCellValue := StrToFloat(SplitChild.aGrid.Cells[iCountOutput,iCount]);
                    except
                          rCellValue := 0;
                    end;
                    
                    if (rCellValue > 0) then
                       writeln(OutputFile,SplitChild.aGrid.Cells[0,iCount] + ',' + SplitChild.aGrid.Cells[iCountOutput,iCount]);
               end;
               closefile(OutputFile);
          end;

          closefile(SummaryFile);
     end;
end;

procedure TTblEdForm.SumColumns1Click(Sender: TObject);
var
   SumChild : TMDIChild;
   iCount, iCountRow : integer;
   OutputFile : TextFile;
   sOutputName : string;
   rSum : extended;
begin
     if (ActiveMDIChild <> nil) then
     try
        Screen.Cursor := crHourglass;

        SumChild := TMDIChild(ActiveMDIChild);

        assignfile(OutputFile,'d:\temp\sum_columns.csv');
        rewrite(OutputFile);
        writeln(OutputFile,'ROWKEY,COLUMNSUM');

        for iCountRow := 1 to (SumChild.aGrid.RowCount-1) do
        begin
             rSum := 0;

             for iCount := 1 to (SumChild.aGrid.ColCount-1) do
             begin
                  try
                     rSum := rSum + StrToFloat(SumChild.aGrid.Cells[iCount,iCountRow]);
                  except
                  end;
             end;

             writeln(OutputFile,SumChild.aGrid.Cells[0,iCountRow] + ',' + FloatToStr(rSum));
        end;

        closefile(OutputFile);
     except
     end;

     Screen.Cursor := crDefault;
end;

procedure TTblEdForm.SumRows1Click(Sender: TObject);
var
   SumChild : TMDIChild;
   iCount, iCountRow : integer;
   OutputFile : TextFile;
   sOutputName : string;
   rSum : extended;
begin
     if (ActiveMDIChild <> nil) then
     try
        Screen.Cursor := crHourglass;

        SumChild := TMDIChild(ActiveMDIChild);

        assignfile(OutputFile,'d:\temp\sum_rows.csv');
        rewrite(OutputFile);
        writeln(OutputFile,'COLUMNKEY,ROWSUM');

        for iCount := 1 to (SumChild.aGrid.ColCount-1) do
        begin
             rSum := 0;

             for iCountRow := 1 to (SumChild.aGrid.RowCount-1) do
             begin
                  try
                     rSum := rSum + StrToFloat(SumChild.aGrid.Cells[iCount,iCountRow]);
                  except
                  end;
             end;

             writeln(OutputFile,SumChild.aGrid.Cells[iCount,0] + ',' + FloatToStr(rSum));
        end;

        closefile(OutputFile);
     except
     end;

     Screen.Cursor := crDefault;
end;

procedure TTblEdForm.SummariseHighestColumn1Click(Sender: TObject);
var
   SumChild : TMDIChild;
   iCount, iCountRow, iNonZeroColumn : integer;
   OutputFile : TextFile;
   sOutputName : string;
   rValue : extended;
begin
     // computes for each row, what is the right-most non-zero column

     if (ActiveMDIChild <> nil) then
     try
        Screen.Cursor := crHourglass;

        SumChild := TMDIChild(ActiveMDIChild);

        assignfile(OutputFile,'d:\temp\summarise_highest_column.csv');
        rewrite(OutputFile);
        writeln(OutputFile,'ROWKEY,COLUMNMAX');

        for iCountRow := 1 to (SumChild.aGrid.RowCount-1) do
        begin
             iNonZeroColumn := -1;

             for iCount := 1 to (SumChild.aGrid.ColCount-1) do
             begin
                  try
                     rValue := StrToFloat(SumChild.aGrid.Cells[iCount,iCountRow]);
                  except
                        rValue := 0;
                  end;

                  if (rValue > 0) then
                     iNonZeroColumn := iCount;
             end;

             if (iNonZeroColumn > 0) then
                writeln(OutputFile,SumChild.aGrid.Cells[0,iCountRow] + ',' + SumChild.aGrid.Cells[iNonZeroColumn,iCountRow])
             else
                 writeln(OutputFile,SumChild.aGrid.Cells[0,iCountRow] + ',0');
        end;

        closefile(OutputFile);
     except
     end;

     Screen.Cursor := crDefault;
end;

procedure TTblEdForm.CoverttoPresenceAbsence1Click(Sender: TObject);
var
   PresenceAbsenceChild : TMDIChild;
   iCount, iCountRow : integer;
   OutputFile : TextFile;
   sOutputName : string;
   rValue : extended;
begin
     if (ActiveMDIChild <> nil) then
     try
        Screen.Cursor := crHourglass;

        PresenceAbsenceChild := TMDIChild(ActiveMDIChild);

        assignfile(OutputFile,'d:\temp\presenceabsence.csv');
        rewrite(OutputFile);
        // write the header row of the converted file
        write(OutputFile,PresenceAbsenceChild.aGrid.Cells[0,0]);
        for iCount := 1 to (PresenceAbsenceChild.aGrid.ColCount-1) do
            write(OutputFile,',' + PresenceAbsenceChild.aGrid.Cells[iCount,0]);
        writeln(OutputFile);

        for iCountRow := 1 to (PresenceAbsenceChild.aGrid.RowCount-1) do
        begin
             write(OutputFile,PresenceAbsenceChild.aGrid.Cells[0,iCountRow]);
             for iCount := 1 to (PresenceAbsenceChild.aGrid.ColCount-1) do
             begin
                  try
                     rValue := StrToFloat(PresenceAbsenceChild.aGrid.Cells[iCount,iCountRow]);
                  except
                        rValue := 0;
                  end;
                  if (rValue > 0) then
                     rValue := 10000;
                  write(OutputFile,',' + FloatToStr(rValue));
             end;
             writeln(OutputFile);
        end;

        closefile(OutputFile);
     except
     end;

     Screen.Cursor := crDefault;
end;

procedure SaveMarxanMatrix(const sFilename : string);
var
   OutFile : TextFile;
   i_I, i_J, iStartingFeatureIndex : integer;
   SaveChild : TMDIChild;
   sValue, sInputString : string;
   rValue : extended;
   fHeaderRow, fConvertM2ToHa : boolean;
begin
     SaveChild := TMDIChild(TblEdForm.ActiveMDIChild);

     assignfile(OutFile,sFilename);
     rewrite(OutFile);

     sInputString := InputBox('Add to starting feature index', 'Input number to add to starting feature index for Marxan matrix', '0');

     iStartingFeatureIndex := StrToInt(sInputString);

     if (mrYes = MessageDlg('Include Header Row',mtConfirmation,[mbYes,mbNo],0)) then
        fHeaderRow := True
     else
         fHeaderRow := False;

     if (mrYes = MessageDlg('Convert M2 to Hectares ?',mtConfirmation,[mbYes,mbNo],0)) then
        fConvertM2ToHa := True
     else
         fConvertM2ToHa := False;

     if fHeaderRow then
        writeln(OutFile,'species,pu,amount');

     for i_I := 1 to (SaveChild.aGrid.RowCount-1) do
         for i_J := 1 to (SaveChild.aGrid.ColCount-1) do
         begin
              sValue := SaveChild.aGrid.Cells[i_J,i_I];

              if (sValue <> '') then
              begin
                   rValue := StrToFloat(sValue);

                   if (rValue > 0) then
                   begin
                        if fConvertM2ToHa then
                           rValue := rValue / 10000;

                        writeln(OutFile,IntToStr(i_J + iStartingFeatureIndex) + ',' + SaveChild.aGrid.Cells[0,i_I] + ',' + FloatToStr(rValue));
                   end;
              end;
         end;

     closefile(OutFile);

     assignfile(OutFile,ExtractFilePath(sFilename) + 'speciesid_' + ExtractFileName(sFilename));
     rewrite(OutFile);
     if fHeaderRow then
        writeln(OutFile,'featureid,featurename');
     for i_J := 1 to (SaveChild.aGrid.ColCount-1) do
         writeln(OutFile,IntToStr(i_J + iStartingFeatureIndex) + ',' + SaveChild.aGrid.Cells[i_J,0]);
     closefile(OutFile);

     MessageDlg('Last feature index used was ' + IntToStr(SaveChild.aGrid.ColCount-1+iStartingFeatureIndex) +
                '. Use ' + IntToStr(SaveChild.aGrid.ColCount-1+iStartingFeatureIndex) + ' as number to add to starting index for next marxan matrix.',mtConfirmation,[mbOk],0)
end;

procedure LoadMarxanMatrix(const sFilename : string);
var
   InputFile : TextFile;
   iMaxFeature,iMinSite,iMaxSite, iValue, iCount, iPUID, iSPID, iSPindex, iPUindex : integer;
   sLine : string;


   i_I, i_J, iStartingFeatureIndex : integer;
   SaveChild, DestinationChild : TMDIChild;
   sValue, sInputString : string;
   rValue : extended;
   fHeaderRow, fConvertM2ToHa : boolean;
begin
     // parse matrix filename and find max and min sitekey, max featkey
     assignfile(InputFile,sFilename);
     reset(InputFile);
     readln(InputFile);

     iMaxFeature := 0;
     iMinSite := 1000000;
     iMaxSite := 0;

     repeat
           readln(InputFile,sLine);

           // species,pu,amount
           iValue := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
           if (iValue > iMaxFeature) then
              iMaxFeature := iValue;

           iValue := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
           if (iValue > iMaxSite) then
              iMaxSite := iValue;
           if (iValue < iMinSite) then
              iMinSite := iValue;

     until Eof(InputFile);
     closefile(InputFile);

     // create destination child
     TblEdForm.CreateMDIChild('load marxan',False,False);
     DestinationChild := TblEdForm.rtnChild('load marxan');
     with DestinationChild.aGrid do
     begin
          RowCount := iMaxSite - iMinSite + 2;
          ColCount := iMaxFeature + 1;
          Cells[0,0] := 'marxan';
          for iCount := 1 to RowCount do
              Cells[0,iCount] := IntToStr(iMinSite + iCount - 1);
          for iCount := 1 to ColCount do
              Cells[iCount,0] := IntToStr(iCount);
     end;

     // parse matrix file, writing each row as an element in the destination child
     reset(InputFile);
     readln(InputFile);
     repeat
           readln(InputFile,sLine);

           // species,pu,amount
           iSPID := StrToInt(GetDelimitedAsciiElement(sLine,',',1));

           iPUID := StrToInt(GetDelimitedAsciiElement(sLine,',',2));

           iSPindex := iSPID;
           iPUindex := 1 + iPUID - iMinSite;

           DestinationChild.aGrid.Cells[iSPindex,iPUindex] := GetDelimitedAsciiElement(sLine,',',3);

     until Eof(InputFile);
     closefile(InputFile);
end;

procedure TTblEdForm.SaveToMarxanMatrix1Click(Sender: TObject);
begin
     if (SaveDialog.Execute) then
        SaveMarxanMatrix(SaveDialog.Filename);
end;

procedure TTblEdForm.OpenFromMarxanMatrix1Click(Sender: TObject);
begin
     if OpenDialog.Execute then
        LoadMarxanMatrix(OpenDialog.Filename);
end;

procedure TTblEdForm.OpenFromMarxanMatrixMaskPU1Click(Sender: TObject);
begin
     MaskPUForm := TMaskPUForm.Create(Application);
     MaskPUForm.ShowModal;
     MaskPUForm.Free;
end;

procedure TTblEdForm.DeconstructPUZONE1Click(Sender: TObject);
var
   PUZONEChild : TMDIChild;
   sCellValue, sOutputLine : string;
   iCount, iPUID, iThisPUID : integer;
   OutFile : TextFile;
begin
     if (ActiveMDIChild <> nil) then
     begin
          PUZONEChild := TMDIChild(ActiveMDIChild);

          assignfile(OutFile,'D:\kerrie\Jan2007\input\PULOCK_PUZONE_prep\puzone_process.csv');
          rewrite(OutFile);

          iPUID := -1;
          sOutputLine := '';

          for iCount := 1 to (PUZONEChild.aGrid.RowCount-1) do
          begin
               // recognise patterns
               iThisPUID := StrToInt(PUZONEChild.aGrid.Cells[0,iCount]);
               if (iThisPUID = iPUID) then
                  sOutputLine := sOutputLine + '_' + PUZONEChild.aGrid.Cells[1,iCount]
               else
               begin
                    writeln(OutFile,sOutputLine);
                    sOutputLine := IntToStr(iThisPUID) + ',' + PUZONEChild.aGrid.Cells[1,iCount];
                    iPUID := iThisPUID;
               end;

          end;



          writeln(OutFile,sOutputLine);

          closefile(OutFile);
     end;
end;

procedure TTblEdForm.Marxanwithzoning1Click(Sender: TObject);
begin
     if (TblEdForm.MDIChildCount > 0) then
     begin
          MarZoneSystemTestForm := TMarZoneSystemTestForm.Create(Application);
          MarZoneSystemTestForm.ShowModal;
          MarZoneSystemTestForm.Free;
     end
     else
         MessageDlg('You need to have a zoning configuration table loaded to access this function.',
                    mtInformation,[mbOk],0);
end;

end.
