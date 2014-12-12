unit wyong_feat;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TWyongFeatureForm = class(TForm)
    ComboTables: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label4: TLabel;
    Label5: TLabel;
    procedure ListAvailableTables;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure SummariseTable;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WyongFeatureForm: TWyongFeatureForm;

implementation

uses MAIN, Childwin;

{$R *.DFM}

procedure TWyongFeatureForm.ListAvailableTables;
var
   iCount : integer;
   aChild : TMDIChild;
begin
     {list available loaded tables in ComboTables}
     try
        ComboTables.items.clear;

        if (SCPForm.MDIChildCount > 0) then
        begin
             for iCount := 0 to (SCPForm.MDIChildCount - 1) do
             begin
                  aChild := TMDIChild(SCPForm.MDIChildren[iCount]);

                  if (aChild.CheckLoadFileData.Checked) then
                     ComboTables.items.add(aChild.Caption);
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ListAvailableTables',mtError,[mbOk],0);
     end;
end;

procedure TWyongFeatureForm.FormCreate(Sender: TObject);
begin
     ListAvailableTables;
end;

procedure TWyongFeatureForm.BitBtn1Click(Sender: TObject);
begin
     SummariseTable;
end;

procedure TWyongFeatureForm.SummariseTable;
var
   InputChild, OutputChild : TMDIChild;
   iCount, iColumn : integer;
   sInputID, sOutputID : string;
begin
     // sample file is d:\wyong_test\combined_group1.csv
     // locate the input child
     InputChild := SCPForm.rtnChild(ComboTables.Text);

     // create a new table
     SCPForm.CreateMDIChild('wyong_summary',False,False);
     OutputChild := SCPForm.rtnChild('wyong_summary');
     OutputChild.aGrid.ColCount := InputChild.aGrid.ColCount;
     OutputChild.aGrid.RowCount := 2;
     OutputChild.SpinCol.Value := OutputChild.aGrid.ColCount;
     OutputChild.SpinRow.Value := OutputChild.aGrid.RowCount;
     for iCount := 0 to (InputChild.aGrid.ColCount-1) do
     begin
          OutputChild.aGrid.Cells[iCount,0] := InputChild.aGrid.Cells[iCount,0];
          OutputChild.aGrid.Cells[iCount,1] := InputChild.aGrid.Cells[iCount,1];
     end;
     sOutputID := '';
     // parse each row of the table, remembering what output row and name we are up to
     // for each row in input file, see if its ID is same as previous row ID
     //   yes : add values to existing output row
     //   no : add values to new output row that is initialised to zero
     for iCount := 2 to (InputChild.aGrid.RowCount-1) do
     begin
          sInputID := InputChild.aGrid.Cells[1,iCount];
          if (sOutputID <> sInputID) then
          begin
               // we are adding a new output row
               sOutputID := sInputID;
               OutputChild.aGrid.RowCount := OutputChild.aGrid.RowCount + 1;
               // initialise the new cells
               for iColumn := 5 to (InputChild.aGrid.ColCount-1) do
                   OutputChild.aGrid.Cells[iColumn,OutputChild.aGrid.RowCount-1] := '0';
          end;
          // increment the values on the current output row
          for iColumn := 5 to (InputChild.aGrid.ColCount-1) do
              OutputChild.aGrid.Cells[iColumn,OutputChild.aGrid.RowCount-1] := FloatToStr(StrToFloat(OutputChild.aGrid.Cells[iColumn,OutputChild.aGrid.RowCount-1]) +
                                                                                          StrToFloat(InputChild.aGrid.Cells[iColumn,iCount]));
          // also copy columns B and D
          OutputChild.aGrid.Cells[1,OutputChild.aGrid.RowCount-1] := InputChild.aGrid.Cells[1,iCount];
          OutputChild.aGrid.Cells[3,OutputChild.aGrid.RowCount-1] := InputChild.aGrid.Cells[3,iCount];
     end;
     OutputChild.lblDimensions.Caption := 'Rows: ' + IntToStr(OutputChild.AGrid.RowCount) +
                                          ' Columns: ' + IntToStr(OutputChild.AGrid.ColCount);
     OutputChild.SpinCol.Value := OutputChild.aGrid.ColCount;
     OutputChild.SpinRow.Value := OutputChild.aGrid.RowCount;
end;

end.
