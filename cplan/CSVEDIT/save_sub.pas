unit save_sub;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls;

type
  TSaveSubsetForm = class(TForm)
    AvailCols: TListBox;
    AvailRows: TListBox;
    UnusedCols: TListBox;
    UnusedRows: TListBox;
    btnChooseCols: TSpeedButton;
    btnUnchooseCols: TSpeedButton;
    btnChooseRows: TSpeedButton;
    btnUnchooseRows: TSpeedButton;
    lblAvCol: TLabel;
    lblAvRow: TLabel;
    lblUnAvCol: TLabel;
    lblUnAvRow: TLabel;
    btnLoadColumns: TButton;
    btnLoadRows: TButton;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    procedure FormResize(Sender: TObject);
    procedure LoadChildInfo(const sChild : string);
    procedure ProduceOutputFile(const sChild : string);
    procedure LabelBoxes;
    procedure btnChooseColsClick(Sender: TObject);
    procedure btnUnchooseColsClick(Sender: TObject);
    procedure btnChooseRowsClick(Sender: TObject);
    procedure btnUnchooseRowsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SaveSubsetForm: TSaveSubsetForm;

implementation

uses
    Childwin, MAIN, impexp;

{$R *.DFM}

procedure TSaveSubsetForm.LabelBoxes;
begin
     // label with item count in each box
     try
        if (AvailCols.Items.Count = 1) then
           lblAvCol.Caption := 'Available Column (1)'
        else
            lblAvCol.Caption := 'Available Columns (' + IntToStr(AvailCols.Items.Count) + ')';
        if (UnusedCols.Items.Count = 1) then
           lblUnAvCol.Caption := 'Column not to include (1)'
        else
            lblUnAvCol.Caption := 'Columns not to include (' + IntToStr(UnusedCols.Items.Count) + ')';

        if (AvailRows.Items.Count = 1) then
           lblAvRow.Caption := 'Available Row (1)'
        else
            lblAvRow.Caption := 'Available Rows (' + IntToStr(AvailRows.Items.Count) + ')';
        if (UnusedCols.Items.Count = 1) then
           lblUnAvRow.Caption := 'Row not to include (1)'
        else
            lblUnAvRow.Caption := 'Rows not to include (' + IntToStr(UnusedRows.Items.Count) + ')';

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSaveSubsetForm.LabelBoxes',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSaveSubsetForm.LoadChildInfo(const sChild : string);
var
   AChild : TMDIChild;
   iCount : integer;
begin
     // Load the Available columns and rows of the child to the form
     // so the user can select which ones not to include
     try
        Screen.Cursor := crHourglass;

        AChild := SCPForm.rtnChild(sChild);
        {list the rows}
        // do not add the key(header) row
        for iCount := 1 to (AChild.AGrid.RowCount-1) do
            AvailRows.Items.Add(AChild.AGrid.Cells[AChild.KeyFieldGroup.ItemIndex,iCount]);
        {list the columns}
        // do not add the key column
        for iCount := 0 to (AChild.AGrid.ColCount-1) do
            if (iCount <> AChild.KeyFieldGroup.ItemIndex) then
               AvailCols.Items.Add(AChild.AGrid.Cells[iCount,0]);

        LabelBoxes;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSaveSubsetForm.LoadChildInfo',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSaveSubsetForm.ProduceOutputFile(const sChild : string);
begin
     // Save an output CSV file with the appropriate rows and columns included
     try
        Screen.Cursor := crHourglass;

        // Determine boolean array of rows to include

        // Determine boolean array of columns to include

        // iterate rows and columns we are including and write the data to a CSV file

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSaveSubsetForm.ProduceOutputFile',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSaveSubsetForm.FormResize(Sender: TObject);
begin
     ClientWidth := btnCancel.Left + btnCancel.Width + btnLoadColumns.Left;
     ClientHeight := btnCancel.Top + btnCancel.Height + btnLoadColumns.Top;
end;

procedure TSaveSubsetForm.btnChooseColsClick(Sender: TObject);
begin
     MoveSelect(AvailCols,UnusedCols);
     LabelBoxes;
end;

procedure TSaveSubsetForm.btnUnchooseColsClick(Sender: TObject);
begin
     MoveSelect(UnusedCols,AvailCols);
     LabelBoxes;
end;

procedure TSaveSubsetForm.btnChooseRowsClick(Sender: TObject);
begin
     MoveSelect(AvailRows,UnusedRows);
     LabelBoxes;
end;

procedure TSaveSubsetForm.btnUnchooseRowsClick(Sender: TObject);
begin
     MoveSelect(UnusedRows,AvailRows);
     LabelBoxes;
end;

end.
