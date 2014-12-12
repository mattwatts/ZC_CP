unit batch;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Grids;

type
  TBatchForm = class(TForm)
    BatchGrid: TStringGrid;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    btnAddRun: TButton;
    btnEditRun: TButton;
    btnExecute: TButton;
    lblRuns: TLabel;
    btnDelete: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnAddRunClick(Sender: TObject);
    procedure btnEditRunClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BatchForm: TBatchForm;

implementation

uses run_spec, sp_u1, spman;

{$R *.DFM}

procedure AutoFitGrid(AGrid : TStringGrid;
                      Canvas : TCanvas;
                      const fFitEntireGrid : boolean);
// fFitEntireGrid = True   means fit entire grid
//                  False  means fit selected area
//
// Canvas is the Canvas of the form containing AGrid
var
   iRowCount,
   iColumnCount,
   iMaxColumnWidth,
   iCurrentColumnWidth : integer;
begin
     // auto fit the table with user parameters
     try
        if fFitEntireGrid then
        begin
             // auto fit entire table
             // for each column, determine the maximum width by scanning all cells in the column
             for iColumnCount := 0 to (AGrid.ColCount-1) do
             begin
                  iMaxColumnWidth := 0;
                  for iRowCount := 0 to (AGrid.RowCount-1) do
                  begin
                       iCurrentColumnWidth := Canvas.TextWidth(AGrid.Cells[iColumnCount,iRowCount]);
                       if (iCurrentColumnWidth > iMaxColumnWidth) then
                          iMaxColumnWidth := iCurrentColumnWidth;
                  end;
                  // set ColWidths for this column
                  AGrid.ColWidths[iColumnCount] := iMaxColumnWidth + 4;
             end;
        end
        else
        begin
             // auto fit selected rows and columns
             for iColumnCount := AGrid.Selection.Left to AGrid.Selection.Right do
             begin
                  iMaxColumnWidth := 0;
                  for iRowCount := AGrid.Selection.Top to AGrid.Selection.Bottom do
                  begin
                       iCurrentColumnWidth := Canvas.TextWidth(AGrid.Cells[iColumnCount,iRowCount]);
                       if (iCurrentColumnWidth > iMaxColumnWidth) then
                          iMaxColumnWidth := iCurrentColumnWidth;
                  end;
                  AGrid.ColWidths[iColumnCount] := iMaxColumnWidth + 4;
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception AutoFitGrid',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


procedure TBatchForm.FormCreate(Sender: TObject);
begin
     BatchGrid.Cells[0,0] := 'input file';
     BatchGrid.Cells[1,0] := 'tests';

     AutoFitGrid(BatchGrid,Canvas,True);
end;

procedure TBatchForm.btnAddRunClick(Sender: TObject);
begin
     RunSpecForm := TRunSpecForm.Create(Application);

     if (RunSpecForm.ShowModal = mrOk)
     and FileExists(RunSpecForm.EditFile.Text) then
     begin
          BatchGrid.RowCount := BatchGrid.RowCount + 1;
          BatchGrid.Cells[0,BatchGrid.RowCount-1] := RunSpecForm.EditFile.Text;
          BatchGrid.Cells[1,BatchGrid.RowCount-1] := RunSpecForm.EditTests.Text;
          BatchGrid.FixedRows := 1;
          AutoFitGrid(BatchGrid,Canvas,True);

          if (BatchGrid.RowCount = 2) then
             lblRuns.Caption := '1 run in batch'
          else
              lblRuns.Caption := IntToStr(BatchGrid.RowCount-1) + ' runs in batch';
     end;

     RunSpecForm.Free;
end;

procedure TBatchForm.btnEditRunClick(Sender: TObject);
begin
     if (BatchGrid.Selection.Top > 0) then
     begin
          RunSpecForm := TRunSpecForm.Create(Application);

          // set form properties
          RunSpecForm.EditFile.Text := BatchGrid.Cells[0,BatchGrid.Selection.Top];
          RunSpecForm.EditTests.Text := BatchGrid.Cells[1,BatchGrid.Selection.Top];

          if (RunSpecForm.ShowModal = mrOk)
          and FileExists(RunSpecForm.EditFile.Text) then
          begin
               BatchGrid.Cells[0,BatchGrid.Selection.Top] := RunSpecForm.EditFile.Text;
               BatchGrid.Cells[1,BatchGrid.Selection.Top] := RunSpecForm.EditTests.Text;
               AutoFitGrid(BatchGrid,Canvas,True);

               if (BatchGrid.RowCount = 2) then
                  lblRuns.Caption := '1 run in batch'
               else
                   lblRuns.Caption := IntToStr(BatchGrid.RowCount-1) + ' runs in batch';
          end;

          RunSpecForm.Free;
     end;
end;

procedure TBatchForm.btnDeleteClick(Sender: TObject);
var
   iCount : integer;
begin
     if (BatchGrid.Selection.Top > 0) then
        if (mrYes = MessageDlg('Delete run from the list',
                               mtConfirmation,[mbYes,mbNo],0)) then
        begin
             // shuffle elements up in the grid if this is not the last row
             if (BatchGrid.Selection.Top <= (BatchGrid.RowCount - 2)) then
                for iCount := (BatchGrid.RowCount - 2) downto BatchGrid.Selection.Top do
                begin
                     BatchGrid.Cells[0,iCount+1] := BatchGrid.Cells[0,iCount];
                     BatchGrid.Cells[1,iCount+1] := BatchGrid.Cells[1,iCount];
                end;

             // remove the last row from the grid
             if (BatchGrid.RowCount < 2) then
                BatchGrid.FixedRows := 0;
             BatchGrid.RowCount := BatchGrid.RowCount - 1;
             
             AutoFitGrid(BatchGrid,Canvas,True);

             if (BatchGrid.RowCount = 2) then
                lblRuns.Caption := '1 run in batch'
             else
                 lblRuns.Caption := IntToStr(BatchGrid.RowCount-1) + ' runs in batch';
        end;
end;

procedure TBatchForm.btnExecuteClick(Sender: TObject);
var
   iCount : integer;
begin
     try
        Screen.Cursor := crHourglass;

        if (BatchGrid.RowCount > 1) then
        begin
             BatchForm.Visible := False;

             for iCount := 1 to (BatchGrid.RowCount - 1) do
             begin
                  // set parameters
                  Form1.EditFile.Text := BatchGrid.Cells[0,iCount];
                  Form1.EditOutput.Text := BatchGrid.Cells[0,iCount] + '_output.txt';
                  Form1.EditTests.Text := BatchGrid.Cells[1,iCount];
                  Form1.Caption := 'Spearman run ' +
                                   IntToStr(iCount) +
                                   ' of ' +
                                   IntToStr(BatchGrid.RowCount - 1);
                  Form1.Update;
                  // execute run
                  Main_spman;
             end;

             BatchForm.Visible := True;
             Form1.Caption := 'Spearman';
        end;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception encountered',mtError,[mbOk],0);
           BatchForm.Visible := True;
     end;

     ModalResult := mrOk;
end;

end.
