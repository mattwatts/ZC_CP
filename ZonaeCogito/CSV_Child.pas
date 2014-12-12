unit CSV_Child;

interface

uses
    Marxan_interface, GIS,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ExtCtrls, Db, DBTables, ComCtrls, Grids, StdCtrls, Spin;

type
  TCSVChild = class(TForm)
    aGrid: TStringGrid;
    Panel1: TPanel;
    lblDimensions: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure InitBlankChild;
    procedure LoadFile;
    procedure NewChild;
    procedure FormActivate(Sender: TObject);
    procedure LoadMarxanSelectedPu(MChild : TMarxanInterfaceForm;GChild : TGIS_Child);
    procedure SaveNonZeroRowsAndColumns(const sFilename : string);
    procedure FormCreate(Sender: TObject);
    procedure aGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
    iTableIndex : integer;
  end;

var
  CSVChild: TCSVChild;
  feFlowsSummary : boolean;

implementation

uses
    Miscellaneous, SCP_Main, ds, eFlows;

{$R *.DFM}



procedure TCSVChild.SaveNonZeroRowsAndColumns(const sFilename : string);
var
   iRow, iColumn : integer;
   RowArea, ColumnArea : Array_t;
   rRowArea, rColumnArea, rAmount : extended;
   OutFile, RowFile, ColumnFile : TextFile;
   sRowFile, sColumnFile : string;
begin
     // init arrays
     RowArea := Array_t.Create;
     RowArea.init(SizeOf(extended),aGrid.RowCount-1);
     ColumnArea := Array_t.Create;
     ColumnArea.init(SizeOf(extended),aGrid.ColCount-1);
     rRowArea := 0;
     for iRow := 1 to RowArea.lMaxSize do
         RowArea.setValue(iRow,@rRowArea);
     rColumnArea := 0;
     for iColumn := 1 to ColumnArea.lMaxSize do
         ColumnArea.setValue(iColumn,@rColumnArea);
     // identify total area for rows and columns
     for iRow := 1 to (aGrid.RowCount-1) do
         for iColumn := 1 to (aGrid.ColCount-1) do
         begin
              if (aGrid.Cells[iColumn,iRow] <> '') then
                 try
                    rAmount := StrToFloat(aGrid.Cells[iColumn,iRow]);
                    if (rAmount > 0) then
                    begin
                         RowArea.rtnValue(iRow,@rRowArea);
                         ColumnArea.rtnValue(iColumn,@rColumnArea);

                         rRowArea := rRowArea + rAmount;
                         rColumnArea := rColumnArea + rAmount;

                         RowArea.setValue(iRow,@rRowArea);
                         ColumnArea.setValue(iColumn,@rColumnArea);
                    end;
                 except
                 end;
         end;

     // write the output files
     if fileexists(sFilename) then
        DeleteFile(sFilename);
     assignfile(OutFile,sFilename);
     rewrite(OutFile);

     sRowFile := GenerateSubFilename(sFilename,'row');
     if fileexists(sRowFile) then
        DeleteFile(sRowFile);
     assignfile(RowFile,sRowFile);
     rewrite(RowFile);

     sColumnFile := GenerateSubFilename(sFilename,'column');
     if fileexists(sColumnFile) then
        DeleteFile(sColumnFile);
     assignfile(ColumnFile,sColumnFile);
     rewrite(ColumnFile);

     // write header row of output matrix file
     write(OutFile,aGrid.Cells[0,0]);
     for iColumn := 1 to ColumnArea.lMaxSize do
     begin
          ColumnArea.rtnValue(iColumn,@rColumnArea);
          if (rColumnArea > 0) then
             write(OutFile,',' + aGrid.Cells[iColumn,0]);
     end;
     writeln(OutFile);
     // write data fields of output matrix file
     for iRow := 1 to RowArea.lMaxSize do
     begin
          RowArea.rtnValue(iRow,@rRowArea);
          if (rRowArea > 0) then
          begin
               write(OutFile,aGrid.Cells[0,iRow]);
               for iColumn := 1 to ColumnArea.lMaxSize do
               begin
                    ColumnArea.rtnValue(iColumn,@rColumnArea);
                    if (rColumnArea > 0) then
                    begin
                         write(OutFile,',' + aGrid.Cells[iColumn,iRow]);
                    end;
               end;
               writeln(OutFile);
          end;
     end;

     writeln(RowFile,'id,amount');
     for iRow := 1 to RowArea.lMaxSize do
     begin
          RowArea.rtnValue(iRow,@rRowArea);
          writeln(RowFile,aGrid.Cells[0,iRow] + ',' + FloatToStr(rRowArea));
     end;
     writeln(ColumnFile,'id,amount');
     for iColumn := 1 to ColumnArea.lMaxSize do
     begin
          ColumnArea.rtnValue(iColumn,@rColumnArea);
          writeln(ColumnFile,aGrid.Cells[iColumn,0] + ',' + FloatToStr(rColumnArea));
     end;

     closefile(OutFile);
     closefile(RowFile);
     closefile(ColumnFile);

     RowArea.Destroy;
     ColumnArea.Destroy;
end;

procedure TCSVChild.LoadMarxanSelectedPu(MChild : TMarxanInterfaceForm;GChild : TGIS_Child);
var
   iCount, iCount2, iPuFieldCount, iRow : integer;
   InFile : TextFile;
   sLine, sFilename, sTemp : string;
   fSelection, fFound : boolean;
begin
     try
        // load data from pu.dat to the grid
        assignfile(InFile,MChild.Return_MZ_Filename('pu',fFound));
        reset(InFile);
        readln(InFile,sLine);

        iPuFieldCount := CountDelimitersInRow(sLine,',') + 1;
        AGrid.ColCount := iPuFieldCount;
        AGrid.RowCount := GChild.ReturnSelectedShapeCount + 1;
        AGrid.Options := AGrid.Options + [goColMoving];
        AGrid.FixedRows := 1;
        iRow := 1;

        for iCount := 1 to iPuFieldCount do
            AGrid.Cells[iCount-1,0] := TrimEnclosingQuotes(GetDelimitedAsciiElement(sLine,',',iCount));

        for iCount := 1 to GChild.ShapeSelection.lMaxSize do
        begin
             readln(InFile,sLine);
             GChild.ShapeSelection.rtnValue(iCount,@fSelection);
             if fSelection then
             begin
                  for iCount2 := 1 to iPuFieldCount do
                      AGrid.Cells[iCount2-1,iRow] := GetDelimitedAsciiElement(sLine,',',iCount2);
                  Inc(iRow);
             end;
        end;

        closefile(InFile);

        // load data from Selection Frequency file to the grid, if the file exists
        sTemp := MChild.ReturnMarxanParameter('SAVESUMSOLN');
        if (sTemp = '3') then
        begin
             sFilename := ExtractFilePath(MChild.EditMarxanDatabasePath.Text) +
                          MChild.ReturnMarxanParameter('OUTPUTDIR') +
                          '\' +
                          MChild.ReturnMarxanParameter('SCENNAME') +
                          '_ssoln.csv';

             if fileexists(sFilename) then
             begin
                  AGrid.ColCount := AGrid.ColCount + 1;
                  AGrid.Cells[AGrid.ColCount-1,0] := 'ssoln';
                  assignfile(InFile,sFilename);
                  reset(InFile);
                  readln(InFile);

                  iRow := AGrid.RowCount - 1;

                  for iCount := GChild.ShapeSelection.lMaxSize downto 1 do
                  begin
                       readln(InFile,sLine);
                       GChild.ShapeSelection.rtnValue(iCount,@fSelection);
                       if fSelection then
                       begin
                            AGrid.Cells[iCount-1,iRow] := GetDelimitedAsciiElement(sLine,',',2);
                            Dec(iRow);
                       end;
                  end;

                  closefile(InFile);
             end;
        end;

        lblDimensions.Caption := 'rows ' + IntToStr(AGrid.RowCount) +
                                 ' fields ' + IntToStr(AGrid.ColCount) +
                                 ' data elements ' + IntToStr(AGrid.RowCount * AGrid.ColCount);

     except
           MessageDlg('Exception in TCSVChild.LoadMarxanSelectedPu',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TCSVChild.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
     Action := caFree;
end;

procedure TCSVChild.NewChild;
begin
     if fileexists(Caption) then
        LoadFile
     else
         InitBlankChild;
end;

procedure TCSVChild.InitBlankChild;
begin
     AGrid.RowCount := 3;
     AGrid.ColCount := 3;
     AGrid.Options := AGrid.Options + [goColMoving];
     AGrid.FixedRows := 1;
     lblDimensions.Caption := 'rows ' + IntToStr(AGrid.RowCount) +
                              ' fields ' + IntToStr(AGrid.ColCount) +
                              ' data elements ' + IntToStr(AGrid.RowCount * AGrid.ColCount);
end;

procedure TCSVChild.LoadFile;
var
   fLoaded : boolean;
begin
     //  load contents of a CSV file into the grid}
     try
        fLoaded := True;

        if not FileContainsCommas(Caption) then
           ConvertFileDelimiter_TabToComma(Caption);

        FasterLoadCSV2StringGrid(AGrid,Caption);

        lblDimensions.Caption := 'rows ' + IntToStr(AGrid.RowCount) +
                              ' fields ' + IntToStr(AGrid.ColCount) +
                              ' data elements ' + IntToStr(AGrid.RowCount * AGrid.ColCount);

        if (AGrid.RowCount > 1) then
           AGrid.FixedRows := 1;

        {enable column moving for the loaded table}
        AGrid.Options := AGrid.Options + [goColMoving];

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TCSVChild.LoadFile',mtError,[mbOk],0);
           Application.Terminate;
     end;

     Screen.Cursor := crDefault;
end;


procedure TCSVChild.FormActivate(Sender: TObject);
begin
     SCPForm.SwitchChildFocus;
end;

procedure TCSVChild.FormCreate(Sender: TObject);
begin
     feFlowsSummary := False;
end;

procedure TCSVChild.aGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  S: string;
begin
     if feFlowsSummary then
     begin
          if (ARow > 0) then
          try
             if eFlowsRowColour[iTableIndex,ARow] then
             begin
                   S := aGrid.Cells[ACol, ARow];

                   aGrid.Canvas.Brush.Color := TColor($D9D9C0);
                   aGrid.Canvas.FillRect(Rect);

                   aGrid.Canvas.Font.Color := clBlack;
                   aGrid.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, S);
             end;
          except
          end;
     end;
end;

end.
