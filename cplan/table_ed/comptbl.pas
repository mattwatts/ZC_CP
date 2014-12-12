unit comptbl;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, Gauges;

type
  TCompareTablesForm = class(TForm)
    ListBox1: TListBox;
    ListBox2: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    Gauge1: TGauge;
    btnCancel: TBitBtn;
    btnBeginComparison: TButton;
    Label3: TLabel;
    btnSaveLog: TButton;
    btnOk: TBitBtn;
    SaveLog: TSaveDialog;
    CheckBlank: TCheckBox;
    procedure ListAvailableTables;
    procedure ExecuteComparison;
    procedure btnBeginComparisonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSaveLogClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CompareTablesForm: TCompareTablesForm;

implementation

uses
    Main, Childwin;

{$R *.DFM}

procedure TCompareTablesForm.ListAvailableTables;
var
   iCount : integer;
   aChild : TMDIChild;
begin
     {list available loaded tables in listbox1 and listbox2}
     try
        listbox1.items.clear;
        listbox2.items.clear;

        if (SCPForm.MDIChildCount > 0) then
        begin
             for iCount := 0 to (SCPForm.MDIChildCount - 1) do
             begin
                  aChild := TMDIChild(SCPForm.MDIChildren[iCount]);

                  if (aChild.CheckLoadFileData.Checked) then
                  begin
                       listbox1.items.add(aChild.Caption);
                       listbox2.items.add(aChild.Caption);
                  end;
             end;
        end;

        {now highlight elements in listbox1 and listbox2}
        if (listbox1.items.count > 1) then
        begin
             {aChild := TMDIChild(ActiveMDIChild);
             if aChild.CheckLoadFileData.Checked then
             begin
                  listbox1.itemindex := listbox1.items.indexof(aChild.Caption);
                  if (listbox1.itemindex = listbox1.items.count) then
                     listbox2.itemindex := listbox1.itemindex - 1
                  else
                      listbox2.itemindex := listbox1.itemindex + 1;
             end
             else
             begin}
                  listbox1.itemindex := 0;
                  listbox2.itemindex := 1;
             {end;}
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TCompareTablesForm.ListAvailableTables',mtError,[mbOk],0);
     end;
end;

procedure TCompareTablesForm.btnBeginComparisonClick(Sender: TObject);
begin
     if (listbox1.itemindex <> listbox2.itemindex) then
     begin
          ExecuteComparison;
     end
     else
     begin
          MessageDlg('Comparison has to be performed on two different tables',mtInformation,[mbOk],0);
     end;
end;

procedure TCompareTablesForm.FormCreate(Sender: TObject);
begin
     ClientHeight := btnBeginComparison.Top + btnBeginComparison.Height + listbox1.left;
     ClientWidth := listbox2.left + listbox2.width + listbox1.left;
end;

function AreValuesDifferent(const rErrorTol : extended;
                            const sVal1, sVal2 : string) : boolean;
var
   rVal1, rVal2 : extended;
begin
     // FALSE if rVal1 is in [(rVal2 - rErrorTol),(rVal2 + rErrorTol)]
     // else
     // TRUE

     if (sVal1 = sVal2) then
        Result := FALSE
     else
     begin
          Result := TRUE;

          try
             rVal1 := StrToFloat(sVal1);
             rVal2 := StrToFloat(sVal2);

             if (rVal1 >= (rVal2 - (rErrorTol * rVal2)))
             and (rVal1 <= (rVal2 + (rErrorTol * rVal2))) then
                 Result := FALSE;

          except
          end;
     end;
end;

procedure TCompareTablesForm.ExecuteComparison;
var
   iDifferences, iMaxColumns, iMaxRows, iColCount, iRowCount : integer;
   Child1, Child2 : TMDIChild;
   fOk : boolean;
   rErrorTolerance : extended;
begin
     try
        {compare two tables and produce a report detailing any differences between them}
        Screen.Cursor := crHourglass;
        listbox1.visible := False;
        label2.visible := False;
        btnBeginComparison.Visible := False;
        btnCancel.Visible := False;
        btnOk.Visible := True;
        btnSaveLog.Visible := True;
        label1.caption := 'Comparison Log';
        iDifferences := 0;
        Child1 := SCPForm.rtnChild(listbox1.items.strings[listbox1.itemindex]);
        Child2 := SCPForm.rtnChild(listbox2.items.strings[listbox2.itemindex]);
        listbox2.Items.clear;
        listbox2.left := listbox1.left;
        listbox2.width := 497;
        Gauge1.Visible := True;

        // error tolerance is 0.1 % of the value for floating point numbers
        rErrorTolerance := 0.001;

        {now do the comparison, writing differences/comments to listbox2}
        listbox2.items.add('Comparing');
        listbox2.items.add('  ' + Child1.Caption + ' to');
        listbox2.items.add('  ' + Child2.Caption);
        listbox2.items.add('');
        {compare the column count and row count}
        if (Child1.aGrid.RowCount <> Child2.aGrid.RowCount) then
        begin
             Inc(iDifferences);
             listbox2.items.add('Difference : Mismatch in row count');
             listbox2.items.add('  ' + Child1.Caption + ' is ' + IntToStr(Child1.aGrid.RowCount));
             listbox2.items.add('  ' + Child2.Caption + ' is ' + IntToStr(Child2.aGrid.RowCount));
             if (Child1.aGrid.RowCount < Child2.aGrid.RowCount) then
                iMaxRows := Child1.aGrid.RowCount
             else
                 iMaxRows := Child2.aGrid.RowCount;
             listbox2.items.add('             Only the first ' + IntToStr(iMaxRows) + ' rows will be tested.');
             listbox2.items.add('');
        end
        else
            iMaxRows := Child1.aGrid.RowCount;
        if (Child1.aGrid.ColCount <> Child2.aGrid.ColCount) then
        begin
             Inc(iDifferences);
             listbox2.items.add('Difference : Mismatch in column count');
             listbox2.items.add('  ' + Child1.Caption + ' is ' + IntToStr(Child1.aGrid.ColCount));
             listbox2.items.add('  ' + Child2.Caption + ' is ' + IntToStr(Child2.aGrid.ColCount));
             if (Child1.aGrid.ColCount < Child2.aGrid.ColCount) then
                iMaxColumns := Child1.aGrid.ColCount
             else
                 iMaxColumns := Child2.aGrid.ColCount;
             listbox2.items.add('             Only the first ' + IntToStr(iMaxColumns) + ' columns will be tested.');
             listbox2.items.add('');
        end
        else
            iMaxColumns := Child1.aGrid.ColCount;
        {compare the column names}
        for iColCount := 0 to (iMaxColumns - 1) do
            if AreValuesDifferent(rErrorTolerance,Child1.aGrid.Cells[iColCount,0],Child2.aGrid.Cells[iColCount,0]) then
            begin
                 Inc(iDifferences);
                 listbox2.items.add('Difference : Mismatch in column ' + IntToStr(iColCount+1) + ' name');
                 listbox2.items.add('  ' + Child1.Caption + ' is >' + Child1.aGrid.Cells[iColCount,0] + '<');
                 listbox2.items.add('  ' + Child2.Caption + ' is >' + Child2.aGrid.Cells[iColCount,0] + '<');
                 listbox2.items.add('');
            end;
        {compare each value from both grids}
        for iColCount := 0 to (iMaxColumns - 1) do
        begin
             Gauge1.Progress := Round(iColCount/iMaxColumns*100);
             Refresh;
             for iRowCount := 0 to (iMaxRows - 1) do
                 if AreValuesDifferent(rErrorTolerance,Child1.aGrid.Cells[iColCount,iRowCount],Child2.aGrid.Cells[iColCount,iRowCount]) then
                 begin
                      fOk := True;
                      if CheckBlank.Checked then
                      begin
                           if ((Child1.aGrid.Cells[iColCount,iRowCount] = '') and (Child2.aGrid.Cells[iColCount,iRowCount] = '0'))
                           or ((Child1.aGrid.Cells[iColCount,iRowCount] = '0') and (Child2.aGrid.Cells[iColCount,iRowCount] = '')) then
                              fOk := False;
                      end;

                      if fOk then
                      begin
                           Inc(iDifferences);
                           listbox2.items.add('Difference : Mismatch in cell value at column ' + IntToStr(iColCount+1) +
                                              ' (' + Child1.aGrid.Cells[iColCount,0] + ')' +
                                              ' row ' + IntToStr(iRowCount+1));
                           listbox2.items.add('  ' + Child1.Caption + ' is >' + Child1.aGrid.Cells[iColCount,iRowCount] + '<');
                           listbox2.items.add('  ' + Child2.Caption + ' is >' + Child2.aGrid.Cells[iColCount,iRowCount] + '<');
                           listbox2.items.add('');
                      end;
                 end;
        end;

        //listbox2.items.add('');
        if (iDifferences = 0) then
           listbox2.items.add('No differences were found.')
        else
            listbox2.items.add(IntToStr(iDifferences) + ' differences were found.');

        Gauge1.Visible := False;
        Screen.Cursor := crDefault;
        //ModalResult := mrOk;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TCompareTablesForm.ExecuteComparison',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TCompareTablesForm.btnSaveLogClick(Sender: TObject);
begin
     SaveLog.InitialDir := listbox1.items.strings[listbox1.itemindex];
     if SaveLog.Execute then
        listbox2.items.savetofile(SaveLog.Filename);
end;

end.
