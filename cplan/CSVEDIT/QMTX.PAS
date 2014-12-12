unit qmtx;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, Spin, ExtCtrls, Buttons;

type
  TQMtxForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    DataTypeGroup: TRadioGroup;
    GroupBox1: TGroupBox;
    SpinSites: TSpinEdit;
    SpinFeatures: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    StringGrid1: TStringGrid;
    Label3: TLabel;
    OrientationGroup: TRadioGroup;
    procedure OrientationGroupClick(Sender: TObject);
    procedure initmtxfile(const sFile : string);
    procedure DataTypeGroupClick(Sender: TObject);
    procedure SpinSitesChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
   iNumberOfDataElements,  iSizeOfFile : integer;
  end;

var
  QMtxForm: TQMtxForm;

implementation

{$R *.DFM}

procedure TQMtxForm.OrientationGroupClick(Sender: TObject);
begin
     with StringGrid1 do
          case OrientationGroup.ItemIndex of
               0 : begin
                        Cells[{col,row}1,0] := 'Feature 1';
                        Cells[{col,row}2,0] := 'Feature 2';
                        Cells[{col,row}3,0] := 'Feature 3';

                        Cells[{col,row}0,1] := 'Site 1';
                        Cells[{col,row}0,2] := 'Site 2';
                        Cells[{col,row}0,3] := 'Site 3';
                   end;
               1 : begin
                        Cells[0,1{col,row}] := 'Feature 1';
                        Cells[0,2{col,row}] := 'Feature 2';
                        Cells[0,3{col,row}] := 'Feature 3';

                        Cells[{col,row}1,0] := 'Site 1';
                        Cells[{col,row}2,0] := 'Site 2';
                        Cells[{col,row}3,0] := 'Site 3';
                   end;
          end; {of case statement}
end;

procedure TQMtxForm.initmtxfile(const sFile : string);
var
   f: file;
begin
     try
        {sFile must exist before calling this function}

        {determine file size so we can set default values for number of
         data elements in file --> site/feature}

        AssignFile(f, sFile);
        Reset(f,1);
        iSizeOfFile := FileSize(f);
        CloseFile(f);

        OrientationGroupClick(self);
        DataTypeGroupClick(self);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TQMtxForm.initmtxfile ' + sFile,
                      mtError,[mbOk],0);
     end;
end;

procedure TQMtxForm.DataTypeGroupClick(Sender: TObject);
var
   iSizeOfDataType : integer;
begin
     {set default number of sites and features
      iSizeOfFile is size of file}
     try
        case DataTypeGroup.ItemIndex of
             0 : iSizeOfDataType := SizeOf(byte);
             1 : iSizeOfDataType := SizeOf(word);
        end;

        iNumberOfDataElements := iSizeOfFile div iSizeOfDataType;

        SpinSites.MinValue := 1;
        SpinFeatures.MinValue := 1;
        SpinSites.MaxValue := iNumberOfDataElements;
        SpinFeatures.MaxValue := iNumberOfDataElements;

        {setting value will automatically call onchange for this component
         which will set value for SpinFeatures}
        SpinSites.Value := Round(sqrt(iNumberOfDataElements));

     except
           {}
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TQMtxForm.DataTypeGroupClick',mtError,[mbOk],0);
     end;
end;

procedure TQMtxForm.SpinSitesChange(Sender: TObject);
begin
     try
        SpinFeatures.Value := iNumberOfDataElements div SpinSites.Value;

     except
           {text box value is '', so we don't need to do anything}
     end;
end;

end.
