unit mtx_arith;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TMtxArithForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    ComboMtx1: TComboBox;
    ComboMtx2: TComboBox;
    RadioGroup1: TRadioGroup;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure OperateOnMatrices;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MtxArithForm: TMtxArithForm;

implementation

uses
    Main, Childwin;

{$R *.DFM}

procedure TMtxArithForm.FormCreate(Sender: TObject);
var
   iCount : integer;

begin
     // Populate ComboMtx1 and ComboMtx2 with
     // available loaded tables.

     if (SCPForm.MDIChildCount > 0) then
        for iCount := 0 to (SCPForm.MDIChildCount - 1) do
        begin
             ComboMtx1.Items.Add(SCPForm.MDIChildren[iCount].Caption);
             ComboMtx2.Items.Add(SCPForm.MDIChildren[iCount].Caption);
        end;
end;

procedure TMtxArithForm.OperateOnMatrices;
var
   Mtx1, Mtx2, NewMtx : TMDIChild;
   iCount, iRow, iColumn : integer;
   sChild, sCell : string;
begin
     try
        //
        Screen.Cursor := crHourglass;

        // create a new blank matrix
        sChild := 'operation output ' + IntToStr(SCPForm.MDIChildCount + 1);
        SCPForm.CreateMDIChild(sChild,false,False);
        NewMtx := SCPForm.rtnChild(sChild);
        NewMtx.aGrid.ColCount := Mtx1.aGrid.ColCount;
        NewMtx.aGrid.RowCount := Mtx1.aGrid.RowCount;
        NewMtx.SpinCol.Value := NewMtx.aGrid.ColCount;
        NewMtx.SpinRow.Value := NewMtx.aGrid.RowCount;
        NewMtx.lblDimensions.Caption := 'Rows: ' + IntToStr(NewMtx.AGrid.RowCount) +
                                        ' Columns: ' + IntToStr(NewMtx.AGrid.ColCount);
        NewMtx.fDataHasChanged := True;
        NewMtx.KeyFieldGroup.Items.Clear;
        NewMtx.KeyCombo.Items.Clear;
        for iCount := 0 to (NewMtx.aGrid.ColCount - 1) do
        begin
             NewMtx.KeyFieldGroup.Items.Add(NewMtx.aGrid.Cells[iCount,0]);
             NewMtx.KeyCombo.Items.Add(NewMtx.aGrid.Cells[iCount,0]);
        end;
        NewMtx.KeyFieldGroup.ItemIndex := 0;
        NewMtx.KeyCombo.Text := NewMtx.KeyCombo.Items.Strings[0];

        Mtx1 := SCPForm.rtnChild(ComboMtx1.Text);
        Mtx2 := SCPForm.rtnChild(ComboMtx2.Text);

        // copy row and column identifiers to new matrix
        for iRow := 1 to (Mtx1.aGrid.RowCount - 1) do
            NewMtx.aGrid.Cells[0,iRow] := Mtx1.aGrid.Cells[0,iRow];
        for iColumn := 1 to (Mtx1.aGrid.ColCount - 1) do
            NewMtx.aGrid.Cells[iColumn,0] := Mtx1.aGrid.Cells[iColumn,0];

        // traverse rows and columns, calculating and writing to new matrix
        for iRow := 1 to (Mtx1.aGrid.RowCount - 1) do
            for iColumn := 1 to (Mtx1.aGrid.ColCount - 1) do
            begin
                 case RadioGroup1.ItemIndex of
                      0 : sCell := FloatToStr(StrToFloat(Mtx1.aGrid.Cells[iColumn,iRow]) +
                                              StrToFloat(Mtx2.aGrid.Cells[iColumn,iRow])); // add
                      1 : sCell := FloatToStr(StrToFloat(Mtx1.aGrid.Cells[iColumn,iRow]) -
                                              StrToFloat(Mtx2.aGrid.Cells[iColumn,iRow])); // subtract
                 end;

                 NewMtx.aGrid.Cells[iColumn,iRow] := sCell;
            end;
        //sCell
        //if ComboMtx1
        //ComboMtx2


        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in OperateOnMatrices',mtError,[mbOk],0);
     end;
end;

procedure TMtxArithForm.BitBtn1Click(Sender: TObject);
begin
     OperateOnMatrices;
end;

end.
