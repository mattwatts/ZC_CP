unit CombineRegions;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TCombineRegionsForm = class(TForm)
    Label1: TLabel;
    ComboMasterFeatures: TComboBox;
    Label2: TLabel;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure BitBtnOkClick(Sender: TObject);
    procedure CombineRegions;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function GetDelimitedAsciiElement(const sLine, sDelimiter : string;
                                  const iColumn : integer) : string;

var
  CombineRegionsForm: TCombineRegionsForm;

implementation

uses MAIN, Childwin;

{$R *.DFM}

procedure TCombineRegionsForm.FormCreate(Sender: TObject);
var
   iCount : integer;
begin
     with SCPForm do
          if (MDIChildCount > 0) then
             for iCount := 0 to (MDIChildCount-1) do
                 ComboMasterFeatures.Items.Add(MDIChildren[iCount].Caption);
end;

function GetDelimitedAsciiElement(const sLine, sDelimiter : string;
                                  const iColumn : integer) : string;
// returns the element at 1-based-index column iColumn
// returns blank string if the column does not exist in sLine
var
   sTrimLine : string;
   iPos, iTrim, iCount : integer;
begin
     Result := '';

     sTrimLine := sLine;
     iTrim := iColumn-1;
     if (iTrim > 0) then
        for iCount := 1 to iTrim do // trim the required number of columns from the start of the string
        begin
             iPos := Pos(sDelimiter,sTrimLine);
             sTrimLine := Copy(sTrimLine,iPos+1,Length(sTrimLine)-iPos);
        end;
     iPos := Pos(sDelimiter,sTrimLine);
     if (iPos = 1) then
     begin
          // there is a delimiter at the start of the line we must trim first
          sTrimLine := Copy(sTrimLine,2,Length(sTrimLine)-1);
          iPos := Pos(sDelimiter,sTrimLine);
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;
     end
     else
     begin
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;
     end;
end;

function CountDelimitersInRow(const sRow, sDelimiter : string) : integer;
var
   iCount : integer;
begin
     Result := 0;
     if (Length(sRow) > 0) then
        for iCount := 1 to Length(sRow) do
            if (sRow[iCount] = sDelimiter) then
               Inc(Result);
end;


function TrimScenarioName(const sScenarioName : string) : string;
var
   iDelimiters : integer;
begin
     // use only the file name from the path and file name for scenario name, eg. filename.csv out of D:\mwatts\28Oct2005\databases2\naderwar\scenario1\filename.csv
     iDelimiters := CountDelimitersInRow(sScenarioName,'\');
     // there are N delimiters, which means N+1 elements
     // we need element N+1
     Result := GetDelimitedAsciiElement(sScenarioName,'\',iDelimiters + 1);
end;

procedure TCombineRegionsForm.CombineRegions;
var
   MasterChild, NewChild, ImportChild : TMDIChild;
   iCount, iChildCount, iColumnCount, iOutputColumn, iInputRow, iOutputColumnInc : integer;
begin
     // get a handle on the master feature report
     MasterChild := TMDIChild(SCPForm.rtnChild(ComboMasterFeatures.Text));
     // Make a new table and populate it with the list of feature names and
     // feature targets from the master feature report.
     SCPForm.CreateMDIChild('combine_regions',False,False);
     NewChild := SCPForm.rtnChild('combine_regions');
     NewChild.aGrid.ColCount := 2;
     NewChild.aGrid.RowCount := MasterChild.aGrid.RowCount + 1;
     NewChild.SpinCol.Value := NewChild.aGrid.ColCount;
     NewChild.SpinRow.Value := NewChild.aGrid.RowCount;
     NewChild.lblDimensions.Caption := 'Rows : ' + IntToStr(NewChild.aGrid.RowCount) + ' Columns : ' + IntToStr(NewChild.aGrid.ColCount);
     NewChild.aGrid.Cells[0,0] := 'scenario ->';
     NewChild.aGrid.Cells[0,1] := 'feature name';
     NewChild.aGrid.Cells[1,1] := 'feature target';
     // write feature name to first column and feature target to second column
     for iCount := 1 to (MasterChild.aGrid.RowCount - 1) do
     begin
          NewChild.aGrid.Cells[0,iCount+1] := MasterChild.aGrid.Cells[0,iCount];
          NewChild.aGrid.Cells[1,iCount+1] := MasterChild.aGrid.Cells[7,iCount];
     end;
     iOutputColumn := 2;
     // For each remaining table, import all its relevant data into our new table.
     for iChildCount := 0 to (ComboMasterFeatures.Items.Count - 1) do
         if (ComboMasterFeatures.Text <> ComboMasterFeatures.Items.Strings[iChildCount]) then
         begin
              ImportChild := TMDIChild(SCPForm.rtnChild(ComboMasterFeatures.Items.Strings[iChildCount]));
              // bring across scenario name
              NewChild.aGrid.Cells[iOutputColumn,0] := TrimScenarioName(ImportChild.Caption);
              // bring across column names
              iOutputColumnInc := iOutputColumn;
              for iColumnCount := 1 to (ImportChild.aGrid.ColCount - 1) do
              begin
                   NewChild.aGrid.Cells[iOutputColumnInc,1] := ImportChild.aGrid.Cells[iColumnCount,1];
                   Inc(iOutputColumnInc);
              end;
              // we need to bring across columns (1-based) 2 to the last column, adding N-1 columns to the output table
              NewChild.aGrid.ColCount := NewChild.aGrid.ColCount + (ImportChild.aGrid.ColCount-1);
              NewChild.SpinCol.Value := NewChild.aGrid.ColCount;
              NewChild.lblDimensions.Caption := 'Rows : ' + IntToStr(NewChild.aGrid.RowCount) + ' Columns : ' + IntToStr(NewChild.aGrid.ColCount);
              // We need to match up the rows.  Some rows from NewChild do not
              // occur in ImportChild, so these need to be skipped.
              iInputRow := 2;
              for iCount := 2 to (NewChild.aGrid.RowCount - 1) do
              begin
                   // skip this row if the feature names do not match up
                   if (NewChild.aGrid.Cells[0,iCount] = ImportChild.aGrid.Cells[0,iInputRow]) then
                   begin
                        // for each row, refresh the output column
                        iOutputColumnInc := iOutputColumn;
                        for iColumnCount := 1 to (ImportChild.aGrid.ColCount - 1) do
                        begin
                             NewChild.aGrid.Cells[iOutputColumnInc,iCount] := ImportChild.aGrid.Cells[iColumnCount,iInputRow];
                             Inc(iOutputColumnInc);
                        end;
                        // move to the next input row of ImportChild
                        Inc(iInputRow);
                   end;
              end;
              // update the output column ready for the next table now that we have finished traversing the rows
              iOutputColumn := iOutputColumnInc;
         end;

     // Save the new table to disk.
     NewChild.Caption := ExtractFilePath(MasterChild.Caption) + '\combine_regions.csv';
     if fileexists(NewChild.Caption) then
        deletefile(NewChild.Caption);
     SCPForm.SaveTable(SCPForm.rtnTableID(NewChild.Caption));
end;

procedure TCombineRegionsForm.BitBtnOkClick(Sender: TObject);
begin
     CombineRegions;
end;

end.
