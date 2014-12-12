unit examine_u1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, ExtCtrls;

type


    trueFloattype = record
                rValue : extended;
                iIndex : integer;
                    end;
    ReportFeatIrr_T = record
      iSiteKey, iFeatKey : integer;
      rFeatIrr : extended;
                      end;
    ByteArray_T = array [1..10] of byte;
    BinaryArray_T = packed array [1..80] of boolean;


  TForm1 = class(TForm)
    StringGrid1: TStringGrid;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button3: TButton;
    RadioValue: TRadioGroup;
    Button4: TButton;
    SaveDialog1: TSaveDialog;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure DisplayInGrid(const sFile : string;
                            const iDataType : integer);
    procedure Button3Click(Sender: TObject);
    procedure CompareExtendedValues(const BA1, BA2 : ByteArray_T);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure SaveStringGrid2CSV(AGrid : TStringGrid;
                             const sFile : string);
var
   OutFile : Text;

   iCountRows,iCountCols : integer;

   fFilesOk : boolean;

begin
     fFilesOk := True;

     Assign(OutFile,sFile);

     try
        Rewrite(OutFile);

     except on EInOutError do
            begin
                 Screen.Cursor := crDefault;

                 MessageDlg('Could not create output CSV file ' + sFile,
                            mtError,[mbOk],0);

                  fFilesOk := False;
            end;
     end;

     if fFilesOk then
     begin
          {now create the datafile}

          //writeln(OutFile,FeatGridForm.Caption);

          for iCountRows := 0 to (AGrid.RowCount-1) do
          begin
               for iCountCols := 0 to (AGrid.ColCount-2) do
                   write(OutFile,AGrid.Cells[iCountCols,iCountRows] + ',');
               writeln(OutFile,AGrid.Cells[AGrid.ColCount-1,iCountRows]);
          end;

          close(OutFile);
     end;
end;



procedure AutoFitGrid(AGrid : TStringGrid;
                      Canvas : TCanvas;
                      const fFitEntireGrid : boolean);
// fFitEntireGrid = True   means fit entire grid
//                  False  means fit selected area
//
// Canvas is the Canvas of the form containing AGrid
var
   iRowCount,
   iColumnCount,
   iMaxColumnWidth,
   iCurrentColumnWidth : integer;
begin
     // auto fit the table with user parameters
     try
        if fFitEntireGrid then
        begin
             // auto fit entire table
             // for each column, determine the maximum width by scanning all cells in the column
             for iColumnCount := 0 to (AGrid.ColCount-1) do
             begin
                  iMaxColumnWidth := 0;
                  for iRowCount := 0 to (AGrid.RowCount-1) do
                  begin
                       iCurrentColumnWidth := Canvas.TextWidth(AGrid.Cells[iColumnCount,iRowCount]);
                       if (iCurrentColumnWidth > iMaxColumnWidth) then
                          iMaxColumnWidth := iCurrentColumnWidth;
                  end;
                  // set ColWidths for this column
                  AGrid.ColWidths[iColumnCount] := iMaxColumnWidth + 4;
             end;
        end
        else
        begin
             // auto fit selected rows and columns
             for iColumnCount := AGrid.Selection.Left to AGrid.Selection.Right do
             begin
                  iMaxColumnWidth := 0;
                  for iRowCount := AGrid.Selection.Top to AGrid.Selection.Bottom do
                  begin
                       iCurrentColumnWidth := Canvas.TextWidth(AGrid.Cells[iColumnCount,iRowCount]);
                       if (iCurrentColumnWidth > iMaxColumnWidth) then
                          iMaxColumnWidth := iCurrentColumnWidth;
                  end;
                  AGrid.ColWidths[iColumnCount] := iMaxColumnWidth + 4;
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception AutoFitGrid',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
     if OpenDialog1.Execute then
          Edit1.Text := OpenDialog1.Filename;
end;

function Bool2Str_0_1(const fBool : boolean) : string;
begin
     if fBool then
          Result := '1'
     else
          Result := '0';
end;


function BinaryArray2String(BA : BinaryArray_T) : string;
var
     iCount : integer;
begin
     Result := '';

     for iCount := 1 to 80 do
          Result := Result + Bool2Str_0_1(BA[iCount]);
end;

function ByteArray2String(BA : ByteArray_T) : string;
begin
     Result := IntToStr(BA[1]) + '\'+
               IntToStr(BA[2]) + '\'+
               IntToStr(BA[3]) + '\'+
               IntToStr(BA[4]) + '\'+
               IntToStr(BA[5]) + '\'+
               IntToStr(BA[6]) + '\'+
               IntToStr(BA[7]) + '\'+
               IntToStr(BA[8]) + '\'+
               IntToStr(BA[9]) + '\'+
               IntToStr(BA[10]);
end;

procedure TForm1.DisplayInGrid(const sFile : string;
                               const iDataType : integer);
var
     InFile0 : file of trueFloattype;
     InFile1 : file of ReportFeatIrr_T;
     aValue : trueFloattype;
     ReportFeatIrr : ReportFeatIrr_T;
     iCount, iX, iY : integer;
     ByteArray : ByteArray_T;
     BinaryArray : BinaryArray_T;
// iDataType
//   0 means use trueFloattype
//   1 means use ReportFeatIrr_T
begin
     // blank the grid first
     StringGrid1.RowCount := 2;
     for iX := 0 to 3 do
          for iY := 0 to 1 do
               StringGrid1.Cells[iX,iY] := '';
     // populate the grid from the file

     if (iDataType = 0) then
     begin
          StringGrid1.Cells[0,0] := 'index';
          StringGrid1.Cells[1,0] := 'value';
          StringGrid1.Cells[2,0] := 'x 10000';
          StringGrid1.Cells[3,0] := 'byte';
          StringGrid1.Cells[4,0] := '';

          assignfile(InFile0,sFile);
          reset(InFile0);
          iCount := 0;
          repeat
                      read(InFile0,aValue);

                      Inc(iCount);
                      if (iCount > StringGrid1.RowCount) then
                           StringGrid1.RowCount := iCount;

                      ByteArray := ByteArray_T(aValue.rValue);
                      //BinaryArray := BinaryArray_T(aValue.rValue);

                      StringGrid1.Cells[0,iCount] := IntToStr(iCount);
                      StringGrid1.Cells[1,iCount] := FloatToStr(aValue.rValue);
                      StringGrid1.Cells[2,iCount] := FloatToStr(aValue.rValue * 10000);
                      StringGrid1.Cells[3,iCount] := ByteArray2String(ByteArray);
                      //StringGrid1.Cells[4,iCount] := BinaryArray2String(BinaryArray);

          until Eof(InFile0);

          closefile(InFile0);
     end
     else
     begin
          StringGrid1.Cells[0,0] := 'sitekey';
          StringGrid1.Cells[1,0] := 'featkey';
          StringGrid1.Cells[2,0] := 'value';
          StringGrid1.Cells[3,0] := 'byte';
          StringGrid1.Cells[4,0] := '';

          assignfile(InFile1,sFile);
          reset(InFile1);
          iCount := 0;
          repeat
                read(InFile1,ReportFeatIrr);

                Inc(iCount);
                if (iCount > StringGrid1.RowCount) then
                   StringGrid1.RowCount := iCount;

                      ByteArray := ByteArray_T(ReportFeatIrr.rFeatIrr);
                      //BinaryArray := BinaryArray_T(aValue.rValue);

                      StringGrid1.Cells[0,iCount] := IntToStr(ReportFeatIrr.iSiteKey);
                      StringGrid1.Cells[1,iCount] := IntToStr(ReportFeatIrr.iFeatKey);
                      StringGrid1.Cells[2,iCount] := FloatToStr(ReportFeatIrr.rFeatIrr);
                      StringGrid1.Cells[3,iCount] := ByteArray2String(ByteArray);
                      //StringGrid1.Cells[4,iCount] := BinaryArray2String(BinaryArray);

          until Eof(InFile1);

          closefile(InFile1);
     end;

     AutoFitGrid(StringGrid1,
                 Canvas,
                 True);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
     DisplayInGrid(Edit1.Text,RadioValue.ItemIndex);
end;

function Bool2Str(const fBool : boolean) : string;
begin
     if fBool then
          Result := 'True'
     else
          Result := 'False';
end;

function IsWithinTolerance(const rA, rB, rTolerance : extended) : boolean;
begin
     if (rA < (rB + rTolerance))
     and (rA > (rB - rTolerance)) then
     begin
          Result := True;
          if (rA = 0)
          and (rB <> 0) then
              Result := False;
          if (rB = 0)
          and (rA <> 0) then
              Result := False;
     end
     else
         Result := False;
end;

procedure TForm1.CompareExtendedValues(const BA1, BA2 : ByteArray_T);
var
     rValue1, rValue2 : extended;
     iX, iY : integer;
begin
     rValue1 := extended(BA1);
     rValue2 := extended(BA2);

     // blank the grid first
     StringGrid1.RowCount := 20;
     for iX := 0 to 3 do
          for iY := 0 to StringGrid1.RowCount-1 do
               StringGrid1.Cells[iX,iY] := '';
     // populate the grid from the file
     StringGrid1.Cells[0,0] := 'index';
     StringGrid1.Cells[1,0] := 'value';
     StringGrid1.Cells[2,0] := 'tolerance';
     StringGrid1.Cells[3,0] := 'equivalent';

     StringGrid1.Cells[0,1] := '1';
     StringGrid1.Cells[1,1] := 'value';
     StringGrid1.Cells[2,1] := '0.0000000001';
     StringGrid1.Cells[3,1] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.0000000001));

     StringGrid1.Cells[0,2] := '2';
     StringGrid1.Cells[1,2] := 'value';
     StringGrid1.Cells[2,2] := '0.000000001';
     StringGrid1.Cells[3,2] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.000000001));

     StringGrid1.Cells[0,3] := '3';
     StringGrid1.Cells[1,3] := 'value';
     StringGrid1.Cells[2,3] := '0.00000001';
     StringGrid1.Cells[3,3] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.00000001));

     StringGrid1.Cells[0,4] := '4';
     StringGrid1.Cells[1,4] := 'value';
     StringGrid1.Cells[2,4] := '0.0000001';
     StringGrid1.Cells[3,4] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.0000001));

     StringGrid1.Cells[0,5] := '5';
     StringGrid1.Cells[1,5] := 'value';
     StringGrid1.Cells[2,5] := '0.000001';
     StringGrid1.Cells[3,5] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.000001));

     StringGrid1.Cells[0,6] := '6';
     StringGrid1.Cells[1,6] := 'value';
     StringGrid1.Cells[2,6] := '0.00001';
     StringGrid1.Cells[3,6] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.00001));

     StringGrid1.Cells[0,7] := '7';
     StringGrid1.Cells[1,7] := 'value';
     StringGrid1.Cells[2,7] := '0.0001';
     StringGrid1.Cells[3,7] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.0001));

     StringGrid1.Cells[0,8] := '8';
     StringGrid1.Cells[1,8] := 'value';
     StringGrid1.Cells[2,8] := '0.001';
     StringGrid1.Cells[3,8] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.001));

     StringGrid1.Cells[0,9] := '9';
     StringGrid1.Cells[1,9] := 'value';
     StringGrid1.Cells[2,9] := '0.01';
     StringGrid1.Cells[3,9] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.01));

     StringGrid1.Cells[0,10] := '10';
     StringGrid1.Cells[1,10] := 'value';
     StringGrid1.Cells[2,10] := '0.1';
     StringGrid1.Cells[3,10] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.1));

     StringGrid1.Cells[0,11] := '11';
     StringGrid1.Cells[1,11] := 'value';
     StringGrid1.Cells[2,11] := '0';
     StringGrid1.Cells[3,11] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0));

     StringGrid1.Cells[0,12] := '12';
     StringGrid1.Cells[1,12] := 'value';
     StringGrid1.Cells[2,12] := '0.00000000001';
     StringGrid1.Cells[3,12] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.00000000001));

     StringGrid1.Cells[0,13] := '13';
     StringGrid1.Cells[1,13] := 'value';
     StringGrid1.Cells[2,13] := '0.000000000001';
     StringGrid1.Cells[3,13] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.000000000001));

     StringGrid1.Cells[0,14] := '14';
     StringGrid1.Cells[1,14] := '10 power -13';
     StringGrid1.Cells[2,14] := '0.0000000000001';
     StringGrid1.Cells[3,14] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.0000000000001));

     StringGrid1.Cells[0,15] := '15';
     StringGrid1.Cells[1,15] := '10 power -14';
     StringGrid1.Cells[2,15] := '0.00000000000001';
     StringGrid1.Cells[3,15] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.00000000000001));

     StringGrid1.Cells[0,16] := '16';
     StringGrid1.Cells[1,16] := '10 power -15';
     StringGrid1.Cells[2,16] := '0.000000000000001';
     StringGrid1.Cells[3,16] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.000000000000001));

     StringGrid1.Cells[0,17] := '17';
     StringGrid1.Cells[1,17] := '10 power -16';
     StringGrid1.Cells[2,17] := '0.0000000000000001';
     StringGrid1.Cells[3,17] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.0000000000000001));

     StringGrid1.Cells[0,18] := '18';
     StringGrid1.Cells[1,18] := '10 power -17';
     StringGrid1.Cells[2,18] := '0.00000000000000001';
     StringGrid1.Cells[3,18] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.00000000000000001));

     StringGrid1.Cells[0,19] := '19';
     StringGrid1.Cells[1,19] := '10 power -18';
     StringGrid1.Cells[2,19] := '0.000000000000000001';
     StringGrid1.Cells[3,19] := Bool2Str(IsWithinTolerance(rValue1,rValue2,0.000000000000000001));

     // extended is 10 bytes
     // & 19-20	significant digits

     {MessageDlg(FloatToStr(rValue1) + ' ' +
                FloatToStr(rValue2) +
                ' = ' + Bool2Str(rValue1 = rValue2) +
                ' tol ' + Bool2Str(IsWithinTolerance(rValue1,rValue2,0.0000000001)),
                mtInformation,[mbOk],0);}
end;




procedure TForm1.Button3Click(Sender: TObject);
var
     BA1, BA2 : ByteArray_T;
begin
     // 0\0\0\0\0\0\0\128\1\64
     BA1[1] := 0;
     BA1[2] := 0;
     BA1[3] := 0;
     BA1[4] := 0;
     BA1[5] := 0;
     BA1[6] := 0;
     BA1[7] := 0;
     BA1[8] := 128;
     BA1[9] := 1;
     BA1[10] := 64;


     // 0\8\0\0\0\0\0\128\1\64
     BA2[1] := 0;
     BA2[2] := 8;
     BA2[3] := 0;
     BA2[4] := 0;
     BA2[5] := 0;
     BA2[6] := 0;
     BA2[7] := 0;
     BA2[8] := 128;
     BA2[9] := 1;
     BA2[10] := 64;

     
     CompareExtendedValues(BA1,BA2);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
     if SaveDialog1.Execute then
        SaveStringGrid2CSV(StringGrid1,SaveDialog1.FileName);
end;

end.
