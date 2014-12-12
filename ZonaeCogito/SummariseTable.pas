unit SummariseTable;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CSV_Child, Buttons, Grids;

type
  TSummariseTableForm = class(TForm)
    ComboField: TComboBox;
    Label1: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    StringGrid1: TStringGrid;
    procedure BitBtn1Click(Sender: TObject);
    procedure SummariseTheTable;
  private
    { Private declarations }
  public
    { Public declarations }
    SummariseChild : TCSVChild;
  end;

var
  SummariseTableForm: TSummariseTableForm;

implementation

uses SCP_Main, Miscellaneous;

{$R *.DFM}

procedure TSummariseTableForm.SummariseTheTable;
var
   iCount, iFieldIndex, iRecordIndex, iValueCount : integer;

   function FindSummaryIndex(const sValue : string) : integer;
   var
      fTagOnEnd : boolean;
      iCountIndex : integer;
   begin
        // find the index of row with value sValue.
        // if it doesn't exist, tag it onto the end of the grid.
        fTagOnEnd := True;
        if (StringGrid1.RowCount > 1) then
        begin
             for iCountIndex := 1 to (StringGrid1.RowCount - 1) do
                 if (StringGrid1.Cells[0,iCountIndex] = sValue) then
                 begin
                      fTagOnEnd := False;
                      Result := iCountIndex;
                 end;
        end;

        if fTagOnEnd then
        begin
             StringGrid1.RowCount := StringGrid1.RowCount + 1;
             StringGrid1.Cells[0,StringGrid1.RowCount-1] := sValue;
             StringGrid1.Cells[1,StringGrid1.RowCount-1] := '0';
             Result := StringGrid1.RowCount-1;
        end;
   end;
begin
     try
        StringGrid1.Cells[0,0] := ComboField.Text;
        StringGrid1.Cells[1,0] := 'count';

        // find summary field index
        iFieldIndex := 0;
        for iCount := 0 to (SummariseChild.aGrid.ColCount - 1) do
            if (SummariseChild.aGrid.Cells[iCount,0] = ComboField.Text) then
               iFieldIndex := iCount;

        // traverse records, creating summary
        if (SummariseChild.aGrid.RowCount > 1) then
           for iCount := 1 to (SummariseChild.aGrid.RowCount - 1) do
           begin
                // increment the counter for this value
                iRecordIndex := FindSummaryIndex(SummariseChild.aGrid.Cells[iFieldIndex,iCount]);
                iValueCount := StrToInt(StringGrid1.Cells[1,iRecordIndex]);
                Inc(iValueCount);
                StringGrid1.Cells[1,iRecordIndex] := IntToStr(iValueCount);
           end;

     except
     end;
end;

procedure TSummariseTableForm.BitBtn1Click(Sender: TObject);
var
   sSummaryFile : string;
begin
     SummariseTheTable;
     sSummaryFile := SummariseChild.Caption + ComboField.Text + '.csv';
     SaveStringGrid2CSV(StringGrid1,sSummaryFile);
     SCPForm.FileOpen(sSummaryFile);
end;

end.
