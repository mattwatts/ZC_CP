unit rndmtx;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Grids,
  childwin;

const
     MTX_BUFF_ARR_SIZE = 4096;


type
  TRndMtxForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    Label3: TLabel;
    procedure RandomizeChild(ActiveChild : TMDIChild);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  MtxBuff_T = array [1..MTX_BUFF_ARR_SIZE] of extended;

var
  RndMtxForm: TRndMtxForm;

implementation

uses
    ds;

{$R *.DFM}

procedure InitDataRow(var DR : MtxBuff_T);
var
   iC : integer;
begin
     for iC := 1 to MTX_BUFF_ARR_SIZE do
         DR[iC] := 0;
end;

procedure RandomizeDataArray(DA, NewDA : Array_T;
                             const iFeatures : integer);
var
   iCount, iFeat, iSite, iNewFeat, iNewSite : integer;
   DataRow, NewDataRow, TestDataRow : MtxBuff_T;
   rCellValue : extended;
begin
     try
        // NewDA is already initialised to zeroes
        // randomly move all cells in the matrix to a new position
        for iSite := 1 to DA.lMaxSize do
        begin
             InitDataRow(DataRow);
             InitDataRow(NewDataRow);

             DA.rtnValue(iSite,@DataRow);

             for iFeat := 1 to iFeatures do
                 if (DataRow[iFeat] <> 0) then
                 begin
                      // find random blank position
                      repeat
                            iNewFeat := random(iFeatures)+1;
                            iNewSite := random(DA.lMaxSize)+1;

                            NewDA.rtnValue(iNewSite,@NewDataRow);

                      until (iSite <> iNewSite) and (iFeat <> iNewFeat) and (NewDataRow[iNewFeat] = 0);

                      // store cell value at new position
                      NewDataRow[iNewFeat] := DataRow[iFeat];
                      NewDA.setValue(iNewSite,@NewDataRow);
                 end;
        end;

     except
           MessageDlg('Exception in RandomizeDataArray',mtError,[mbOk],0);
     end;
end;

procedure TRndMtxForm.RandomizeChild(ActiveChild : TMDIChild);
var
   DataArray, NewDataArray : Array_t;
   DataRow : MtxBuff_T;
   iCount, iColCount, iDataCount, iDataArraySize : integer;
begin
     // Status_T = (Av,R1,R2,R3,R4,R5,Pd,Fl,Ex,Ig,Re);
     // Tenure_T = (Ava,Res,Ign);

     if (ActiveChild.aGrid.ColCount > MTX_BUFF_ARR_SIZE) then
        MessageDlg('Too many columns.  Maximum is ' + IntToStr(MTX_BUFF_ARR_SIZE),mtInformation,[mbOk],0)
     else
     with ActiveChild.aGrid do
     try
        // read the data from reserved rows of the grid into an array
        DataArray := Array_t.Create;
        DataArray.init(SizeOf(MtxBuff_T),RowCount-1);
        iDataArraySize := 0;
        NewDataArray := Array_t.Create;
        NewDataArray.init(SizeOf(MtxBuff_T),RowCount-1);
        for iCount := 1 to (RowCount-1) do
            if (Cells[1,iCount] <> 'Reserve') then
            begin
                 Inc(iDataArraySize);
                 InitDataRow(DataRow);
                 NewDataArray.setValue(iDataArraySize,@DataRow);
                 for iColCount := 2 to (ColCount-1) do
                 begin
                      if (Cells[iColCount,iCount] = '') then
                         DataRow[iColCount-1] := 0
                      else
                          DataRow[iColCount-1] := StrToFloat(Cells[iColCount,iCount]);
                 end;
                 DataArray.setValue(iDataArraySize,@DataRow);
            end;
        if (iDataArraySize > 0)
        and (DataArray.lMaxSize <> iDataArraySize) then
        begin
             DataArray.resize(iDataArraySize);
             NewDataArray.resize(iDataArraySize);
        end;

        // randomize the data in the array
        RandomizeDataArray(DataArray,NewDataArray,ColCount-2);
        // write the array back to the reserved rows of the grid
        iDataCount := 0;
        for iCount := 1 to (RowCount-1) do
            if (Cells[1,iCount] <> 'Reserve') then
            begin
                 Inc(iDataCount);
                 InitDataRow(DataRow);
                 NewDataArray.rtnValue(iDataCount,@DataRow);
                 for iColCount := 2 to (ColCount-1) do
                     Cells[iColCount,iCount] := FloatToStr(DataRow[iColCount-1]);
            end;
        // finished with DataArray
        DataArray.Destroy;
        NewDataArray.Destroy;

        // mark the grid as modified so user will be prompted to save the file
        ActiveChild.fDataHasChanged := True;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception performing randomization',mtError,[mbOk],0);
     end;
end;

end.
