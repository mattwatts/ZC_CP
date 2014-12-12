unit fieldproperties;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, Buttons, ExtCtrls, ds;

type
  TFieldPropertiesForm = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    StringGrid1: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure DisplayFieldProperties(const TypeInfo, FieldSize : Array_t);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FieldPropertiesForm: TFieldPropertiesForm;

implementation

uses
    converter;

{$R *.DFM}

function FieldTypeToStr(const FT : FDType_T) : string;
begin
     case FT of
          DBaseFloat : Result := 'Float';
          DBaseInt : Result := 'Integer';
          DBaseStr : Result := 'String';
     end;
end;

procedure TFieldPropertiesForm.DisplayFieldProperties(const TypeInfo, FieldSize : Array_t);
var
   iCount, iFieldSize : integer;
   FieldData : FieldDataType_T;
begin
     try
        StringGrid1.RowCount := TypeInfo.lMaxSize + 1;

        for iCount := 1 to TypeInfo.lMaxSize do
        begin
             TypeInfo.rtnValue(iCount,@FieldData);
             FieldSize.rtnValue(iCount,@iFieldSize);
             StringGrid1.Cells[0,iCount] := FieldData.sName;
             StringGrid1.Cells[1,iCount] := FieldTypeToStr(FieldData.DBDataType);
             //if (FieldData.DBDataType <> DBaseFloat) then
             //   StringGrid1.Cells[2,iCount] := IntToStr(FieldData.iSize);
             StringGrid1.Cells[2,iCount] := IntToStr(iFieldSize);
        end;

        AutoFitGrid(StringGrid1,Canvas,True);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TFieldPropertiesForm.DisplayFieldProperties',mtError,[mbOk],0);
     end;
end;

procedure TFieldPropertiesForm.FormCreate(Sender: TObject);
begin
     StringGrid1.Cells[0,0] := 'Name';
     StringGrid1.Cells[1,0] := 'Type';
     StringGrid1.Cells[2,0] := 'Size';
     //StringGrid1.Cells[3,0] := 'TableScanSize';
end;

end.
