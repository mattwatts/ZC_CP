unit sortdata;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  Childwin;

type
  TSortDataForm = class(TForm)
    RadioSortDirection: TRadioGroup;
    ComboSortField: TComboBox;
    Label1: TLabel;
    btnSort: TBitBtn;
    BitBtn2: TBitBtn;
    procedure btnSortClick(Sender: TObject);
    procedure SortData(const fDebug : boolean;
                       const iDirection : integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SortDataForm: TSortDataForm;
  SortChild : TMDIChild;

implementation

uses
    reallist, xdata,
    global, ds, sitelist,
    grids;

{$R *.DFM}


function CustCompare(const sOne, sTwo : string;
                     const wSortType, wSortDirection : word) : boolean;
begin
     case wSortType of
          SORT_TYPE_REAL:
          begin
               try
                  Result := False;

                  case wSortDirection of
                       0 : {Descending order}
                           if (StrToFloat(sOne) < StrToFloat(sTwo)) then
                              Result := True;
                       1 : {Ascending order}
                           if (StrToFloat(sOne) > StrToFloat(sTwo)) then
                              Result := True;
                  end;

               except on exception do;
               end;
          end;
          SORT_TYPE_STRING:
          begin
               Result := False;

               case wSortDirection of
                    0 : {Descending order}
                        if (sOne < sTwo) then
                           Result := True;
                    1 : {Ascending order}
                        if (sOne > sTwo) then
                           Result := True;
               end;
          end;
     end;
end;


procedure SortGrid(var AGrid : TStringGrid;
                   const iRowStartIndex, iColIndex : integer;
                   const wSortType, wSortDirection : word);
var
   iCount, iDBGCount : integer;
   fSwap : boolean;
   sLow,sHigh : string;
begin
     iDBGCount := 0;

     if (iRowStartIndex < (AGrid.RowCount-2))
     and (iColIndex < AGrid.ColCount) then
     begin
          AGrid.RowCount := AGrid.RowCount + 1;

          fSwap := True;
          while fSwap do
          begin
               fSwap := False;

               for iCount := iRowStartIndex to (AGrid.RowCount-3) do
                   begin
                        sLow := AGrid.Cells[iColIndex,iCount];
                        sHigh := AGrid.Cells[iColIndex,iCount + 1];

                        if CustCompare(sLow,sHigh,
                                       wSortType,
                                       wSortDirection {0 is descending, 1 is ascending}
                                       ) then
                        with AGrid do
                        begin
                             Rows[RowCount-1] := Rows[iCount];
                             Rows[iCount] := Rows[iCount+1];
                             Rows[iCount+1] := Rows[RowCount-1];

                             fSwap := True;
                        end;
                   end;

               Inc(iDbgCount);
          end;

          AGrid.RowCount := AGrid.RowCount - 1;
     end;
end;


procedure TSortDataForm.SortData(const fDebug : boolean;
                                 const iDirection : integer);
var
   AType : FieldDataType_T;
   rValue : extended;
   sCell, sValue : string;
   iCount, iKeyColumn, iIndex : integer;
   FloatValue : trueFloatType;
   SiteValue : trueSitetype;
   DebugFile : TextFile;
   fCorrectRow, fTestCorrectRow : boolean;

begin
     // iDirection = 0 means sort descending
     //              1 means sort ascending
     try
        Screen.Cursor := crHourglass;
        // find the data type of the field to sort by
        iKeyColumn := SortChild.KeyFieldGroup.Items.IndexOf(ComboSortField.Text);
        SortChild.DataFieldTypes.rtnValue(iKeyColumn+1,@AType);
        case AType.DBDataType of
             DBaseFloat, DBaseInt :
             begin
                  SortGrid(SortChild.aGrid,
                           1, // row to start sorting from
                           iKeyColumn, // key field index
                           SORT_TYPE_REAL, // data type of key field
                           iDirection); // soft direction
             end;
             DBaseStr :
             begin
                  SortGrid(SortChild.aGrid,
                           1, // row to start sorting from
                           iKeyColumn, // key field index
                           SORT_TYPE_STRING, // data type of key field
                           iDirection); // soft direction
             end;
        end;
        SortChild.fDataHasChanged := True;
        Screen.Cursor := crDefault;
        
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in SortData',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSortDataForm.btnSortClick(Sender: TObject);
begin
     SortData(true,RadioSortDirection.ItemIndex);
     SortData(False,RadioSortDirection.ItemIndex);
     SortData(False,RadioSortDirection.ItemIndex);
     SortData(False,RadioSortDirection.ItemIndex);
     SortData(False,RadioSortDirection.ItemIndex);
end;

end.
