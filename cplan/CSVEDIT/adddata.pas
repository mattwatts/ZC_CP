unit adddata;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, ExtCtrls, Buttons,
  ChildWin;

type
  TAddDataForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    RadioAddWhat: TRadioGroup;
    lblCount: TLabel;
    SpinCount: TSpinEdit;
    procedure RadioAddWhatClick(Sender: TObject);
    procedure ApplyUserOptions;
    procedure AddRows(const fInsert : boolean;
                      const iNumberOfRows : integer);
    procedure AddColumns(const fInsert : boolean;
                         const iNumberOfColumns : integer);
    function FindUniqueFieldNames(const iNumberOfColumns : integer) : string;
  private
    { Private declarations }
  public
    { Public declarations }
    AddChild : TMDIChild;
  end;

var
  AddDataForm: TAddDataForm;

implementation

uses
    global;

{$R *.DFM}

procedure TAddDataForm.AddRows(const fInsert : boolean;
                               const iNumberOfRows : integer);
var
   iCount, iSelectionTop, iPreviousGridLength, iCol : integer;
begin
     try
        iPreviousGridLength := AddChild.aGrid.RowCount;
        iSelectionTop := AddChild.aGrid.Selection.Top;

        AddChild.aGrid.RowCount := AddChild.aGrid.RowCount + iNumberOfRows;

        if fInsert then
        begin
             // move rows down to create a gap in the grid
             for iCount := (iPreviousGridLength-1) downto iSelectionTop do
                 for iCol := 0 to (AddChild.aGrid.ColCount - 1) do
                     AddChild.aGrid.Cells[iCol,iCount + iNumberOfRows] := AddChild.aGrid.Cells[iCol,iCount];

             // blank the contents of the 'new' cells
             for iCount := iSelectionTop to (iSelectionTop + iNumberOfRows - 1) do
                 for iCol := 0 to (AddChild.aGrid.ColCount - 1) do
                     AddChild.aGrid.Cells[iCol,iCount] := '';
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Add Rows',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function TAddDataForm.FindUniqueFieldNames(const iNumberOfColumns : integer) : string;
begin
     try
        Result := 'a';

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Find Unique Field Names',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TAddDataForm.AddColumns(const fInsert : boolean;
                                  const iNumberOfColumns : integer);
var
   iCount, iSelectionLeft, iPreviousGridWidth, iRow : integer;
   AField : FieldDataType_T;
   sFieldName : string;
begin
     try
        // We must give a unique name to each new columns created so
        // as to avoid an exception if the file is saved as dbf.
        // Note : The user can then rename these fields if they choose.

        sFieldName := FindUniqueFieldNames(iNumberOfColumns);

        iPreviousGridWidth := AddChild.aGrid.ColCount;
        iSelectionLeft := AddChild.aGrid.Selection.Left;

        AddChild.aGrid.ColCount := AddChild.aGrid.ColCount + iNumberOfColumns;
        AddChild.DataFieldTypes.resize(AddChild.DataFieldTypes.lMaxSize + iNumberOfColumns);

        if fInsert then
        begin
             // move field specifications right to create a gap

             // move columns right to create a gap in the grid
             for iCount := (iPreviousGridWidth-1) downto iSelectionLeft do
             begin
                  AddChild.DataFieldTypes.rtnValue(iCount + 1,@AField);
                  AddChild.DataFieldTypes.setValue(iCount + 1 + iNumberOfColumns,@AField);

                  for iRow := 0 to (AddChild.aGrid.RowCount - 1) do
                      AddChild.aGrid.Cells[iCount + iNumberOfColumns,iRow] := AddChild.aGrid.Cells[iCount,iRow];
             end;

             AField.DBDataType := DBaseStr;
             AField.iSize := 254;
             AField.iDigit2 := 0;

             for iCount := (iSelectionLeft+1) to (iSelectionLeft+iNumberOfColumns) do
             begin
                  AddChild.DataFieldTypes.setValue(iCount,@AField);

                  // blank the contents of the 'new' cells
                  for iRow := 0 to (AddChild.aGrid.RowCount - 1) do
                      AddChild.aGrid.Cells[iCount-1,iRow] := '';

                  AddChild.aGrid.Cells[iCount-1,0] := sFieldName + IntToStr(iCount-iSelectionLeft);
             end;
        end
        else
        begin
             AField.DBDataType := DBaseStr;
             AField.iSize := 254;
             AField.iDigit2 := 0;

             for iCount := (iPreviousGridWidth+1) to (AddChild.aGrid.ColCount) do
             begin
                  AddChild.DataFieldTypes.setValue(iCount,@AField);
                  AddChild.aGrid.Cells[iCount-1,0] := sFieldName + IntToStr(iCount-iPreviousGridWidth);
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Add Columns',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TAddDataForm.ApplyUserOptions;
begin
     try
        Screen.Cursor := crHourglass;

        // make the additions specified by the user to the table
        case RadioAddWhat.ItemIndex of
             0 : AddRows(True,
                         SpinCount.Value); // insert rows
             1 : AddRows(False,
                         SpinCount.Value); // append rows
             2 : AddColumns(True,
                            SpinCount.Value); // insert columns
             3 : AddColumns(False,
                            SpinCount.Value); // append columns
        end;

        AddChild.UpdateKeyObjects(-1);
        AddChild.lblDimensions.Caption := 'Rows: ' +
                                          IntToStr(AddChild.AGrid.RowCount) +
                                          ' Columns: ' +
                                          IntToStr(AddChild.AGrid.ColCount);
        AddChild.fDataHasChanged := True;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Apply User Options',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TAddDataForm.RadioAddWhatClick(Sender: TObject);
begin
     case RadioAddWhat.ItemIndex of
          0 : lblCount.Caption := 'Rows to Add';
          1 : lblCount.Caption := 'Rows to Add';
          2 : lblCount.Caption := 'Columns to Add';
          3 : lblCount.Caption := 'Columns to Add';
     end;
end;

end.
