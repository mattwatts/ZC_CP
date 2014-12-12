unit combineDEHveg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TCombineDEHVegForm = class(TForm)
    Button1: TButton;
    LabelProgress: TLabel;
    Button2: TButton;
    Label1: TLabel;
    EditColumnChild: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    EditRowChild: TEdit;
    EditInputDirectory: TEdit;
    EditOutputDirectory: TEdit;
    EditOutputTableName: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    EditListOfInputFiles: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    CheckMatchIntputFileName: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CombineDEHVegForm: TCombineDEHVegForm;

implementation

uses MAIN, Childwin;

{$R *.DFM}

procedure Combine_DEH_Vegetation;
var
   RowChild, ColumnChild, InputChild, ListOfInputFilesChild : TMDIChild;
   sRowChild, sColumnChild, sInputChild,
   sInputDirectory, sOutputDirectory,
   sRowID, sListOfInputFiles, sDestinationColumnId : string;
   iCount, iFeatureCount, iDestinationRow, iDestinationColumn, iColumnCount : integer;
   rCellValue : extended;

   {function search( key : typekey; var r : dataarray ) : integer;
   var
      high, j, low : integer;
   begin
        low := 0;
        high := n;
        while high-low > 1 do
        begin
             j := (high+low) div 2;
             if key <= r[j].k then
                high := j
             else
                 low := j
        end;

        if r[high].k = key then
           search := high //*** found(r[high]) ***
        else search := -1; //*** notfound(key) ***
   end;}

   function BinarySearchRow : integer;
   // assumes row id is integer and is sorted as integer
   var
      high, j, low, key : integer;
   begin
        key := StrToInt(sRowID);

        low := 1;
        high := RowChild.aGrid.RowCount-1;

        while high-low > 1 do
        begin
             j := (high+low) div 2;
             if key <= StrToInt(RowChild.aGrid.Cells[0,j]) then
                high := j
             else
                 low := j
        end;

        if StrToInt(RowChild.aGrid.Cells[0,high]) = key then
           Result := high {*** found(r[high]) ***}
        else
        begin
              if StrToInt(RowChild.aGrid.Cells[0,low]) = key then
                 Result := low {*** found(r[low]) ***}
              else
                  Result := -1; {*** notfound(key) ***}
        end;
   end;


   function BinarySearchColumn : integer;
   // assumes column is id string and is sorted as string
   var
      high, j, low : integer;
      key : string;
   begin
        key := sDestinationColumnId;

        low := 1;
        high := RowChild.aGrid.ColCount-1;

        while high-low > 1 do
        begin
             j := (high+low) div 2;
             if key <= RowChild.aGrid.Cells[j,0] then
             //if key >= RowChild.aGrid.Cells[j,0] then
                high := j
             else
                 low := j
        end;

        if RowChild.aGrid.Cells[high,0] = key then
           Result := high {*** found(r[high]) ***}
        else
        begin
              if RowChild.aGrid.Cells[low,0] = key then
                 Result := low {*** found(r[low]) ***}
              else
                  Result := -1; {*** notfound(key) ***}
        end;
   end;


begin
     try

     CombineDEHVegForm.LabelProgress.Visible := True;

     // load table containing our row identifiers
     sRowChild := CombineDEHVegForm.EditRowChild.Text;
     SCPForm.CreateMDIChild(sRowChild,True,False);
     RowChild := TMDIChild(SCPForm.rtnChild(sRowChild));

     // load table containing our column identifiers
     sColumnChild := CombineDEHVegForm.EditColumnChild.Text;
     SCPForm.CreateMDIChild(sColumnChild,True,False);
     ColumnChild := TMDIChild(SCPForm.rtnChild(sColumnChild));

     sListOfInputFiles := CombineDEHVegForm.EditListOfInputFiles.Text;
     SCPForm.CreateMDIChild(sListOfInputFiles,True,False);
     ListOfInputFilesChild := TMDIChild(SCPForm.rtnChild(sListOfInputFiles));

     // Set the input directory containing all the tables to be joined
     // and the output directory where the new table is to be saved.
     sInputDirectory := CombineDEHVegForm.EditInputDirectory.Text;
     sOutputDirectory := CombineDEHVegForm.EditOutputDirectory.Text;

     // add 1 column to the RowChild for each row in ColumnChild
     RowChild.aGrid.ColCount :=  RowChild.aGrid.ColCount + ColumnChild.aGrid.RowCount;
     RowChild.SpinCol.Value := RowChild.aGrid.ColCount;
     RowChild.SpinRow.Value := RowChild.aGrid.RowCount;
     RowChild.lblDimensions.Caption := 'Rows : ' + IntToStr(RowChild.aGrid.RowCount) + ' Columns : ' + IntToStr(RowChild.aGrid.ColCount);
     // label the new columns
     for iCount := 1 to ColumnChild.aGrid.RowCount do
         RowChild.aGrid.Cells[iCount,0] := ColumnChild.aGrid.Cells[0,iCount-1];

     // Load each of the tables from ColumnChild in turn,
     // adding their cell values to the relevant column of RowChild.
     // Divide the cell value by 10,000 to convert from m2 to hectares.
     for iCount := 1 to ListOfInputFilesChild.aGrid.RowCount do
     begin
          CombineDEHVegForm.LabelProgress.Caption := IntToStr(iCount) + ' of ' + IntToStr(ListOfInputFilesChild.aGrid.RowCount) +
                                                     ' table ' +  ListOfInputFilesChild.aGrid.Cells[0,iCount-1];
          CombineDEHVegForm.LabelProgress.Update;

          sInputChild := sInputDirectory + ListOfInputFilesChild.aGrid.Cells[0,iCount-1];
          SCPForm.CreateMDIChild(sInputChild,True,False);
          InputChild := TMDIChild(SCPForm.rtnChild(sInputChild));

          // traverse through the cell values in the input child
          for iFeatureCount := 1 to (InputChild.aGrid.RowCount - 1) do
          begin
               sRowID := InputChild.aGrid.Cells[0,iFeatureCount];

               // seek to the correct output row in RowChild
               //iDestinationRow := 1;
               //while sRowID <> RowChild.aGrid.Cells[0,iDestinationRow] do
               //      Inc(iDestinationRow);
               iDestinationRow := BinarySearchRow;

               for iColumnCount := 2 to InputChild.aGrid.ColCount do
               begin
                    //sDestinationColumnId := InputChild.aGrid.Cells[iColumnCount-1,0];
                    sDestinationColumnId := Copy(ListOfInputFilesChild.aGrid.Cells[0,iCount-1],1,Length(ListOfInputFilesChild.aGrid.Cells[0,iCount-1])-4) +
                                            '_' +
                                            Copy(InputChild.aGrid.Cells[iColumnCount-1,0],7,1);

                    rCellValue := StrToFloat(InputChild.aGrid.Cells[iColumnCount-1,iFeatureCount]);
                    rCellValue := rCellValue / 10000;

                    if (rCellValue > 0) then
                    begin
                         iDestinationColumn := 1;

                         if CombineDEHVegForm.CheckMatchIntputFileName.Checked then
                         begin
                              // seek to the correct row in list of input files
                              while ListOfInputFilesChild.aGrid.Cells[0,iCount-1] <> RowChild.aGrid.Cells[iDestinationColumn,0] do
                                    Inc(iDestinationColumn);
                         end
                         else
                         begin
                              // seek to the correct output column in RowChild
                              while ((sDestinationColumnId <> RowChild.aGrid.Cells[iDestinationColumn,0]) and (iDestinationColumn < RowChild.aGrid.ColCount)) do
                                    Inc(iDestinationColumn);
                              if (sDestinationColumnId <> RowChild.aGrid.Cells[iDestinationColumn,0]) then
                                 iDestinationColumn := -1;
                              //iDestinationColumn := BinarySearchColumn;
                         end;

                         if (iDestinationColumn <> -1) then
                            RowChild.aGrid.Cells[iDestinationColumn,iDestinationRow] := FloatToStr(rCellValue);
                    end;
               end;
          end;

          InputChild.Free;
     end;

     // save RowChild to a new file
     RowChild.Caption := sOutputDirectory + CombineDEHVegForm.EditOutputTableName.Text;
     if fileexists(RowChild.Caption) then
        deletefile(RowChild.Caption);
     SCPForm.SaveTable(SCPForm.rtnTableID(RowChild.Caption));

     MessageDlg('Finished',mtInformation,[mbOk],0);

     except
           MessageDlg('Exception Combine_DEH_Vegetation ' + ' table ' + ListOfInputFilesChild.aGrid.Cells[0,iCount-1] + ' feature ' + IntToStr(iFeatureCount) + ' row ' + sRowID + ' ' + IntToStr(iDestinationRow),mtError,[mbOk],0);
     end;
end;

procedure Compute_Total_Areas;
var
   RowChild, ColumnChild, InputChild : TMDIChild;
   sRowChild, sColumnChild, sInputChild,
   sInputDirectory, sOutputDirectory,
   sRowID : string;
   iCount, iFeatureCount, iDestinationRow : integer;
   rCellValue, rSpeciesTotal : extended;
   OutFile : TextFile;
begin
     try

     CombineDEHVegForm.LabelProgress.Visible := True;

     // load table containing our column identifiers
     // 'D:\DEH\tabreports_sorted.txt'
     sColumnChild := CombineDEHVegForm.EditColumnChild.Text;
     SCPForm.CreateMDIChild(sColumnChild,True,False);
     ColumnChild := TMDIChild(SCPForm.rtnChild(sColumnChild));

     // Set the input directory containing all the tables to be joined
     // and the output directory where the new table is to be saved.
     sInputDirectory := CombineDEHVegForm.EditInputDirectory.Text;
     sOutputDirectory := CombineDEHVegForm.EditOutputDirectory.Text;

     assignfile(OutFile,sOutputDirectory + CombineDEHVegForm.EditOutputTableName.Text);
     rewrite(OutFile);
     writeln(OutFile,'species,total area');

     // Load each of the tables from ColumnChild in turn,
     // adding their cell values to the relevant total.
     // Divide the cell value by 10,000 to convert from m2 to hectares.
     for iCount := 1 to ColumnChild.aGrid.RowCount do
     begin
          CombineDEHVegForm.LabelProgress.Caption := IntToStr(iCount) + ' of ' + IntToStr(ColumnChild.aGrid.RowCount) +
                                                     ' table ' +  ColumnChild.aGrid.Cells[0,iCount-1];
          CombineDEHVegForm.LabelProgress.Update;

          sInputChild := sInputDirectory + ColumnChild.aGrid.Cells[0,iCount-1];
          SCPForm.CreateMDIChild(sInputChild,True,False);
          InputChild := TMDIChild(SCPForm.rtnChild(sInputChild));

          rSpeciesTotal := 0;
          // traverse through the cell values in the input child
          for iFeatureCount := 1 to (InputChild.aGrid.RowCount - 1) do
          begin
               rCellValue := StrToFloat(InputChild.aGrid.Cells[1,iFeatureCount]);
               rCellValue := rCellValue / 10000;

               rSpeciesTotal := rSpeciesTotal + rCellValue;
          end;

          writeln(OutFile,sInputChild + ',' + FloatToStr(rSpeciesTotal));

          InputChild.Free;
     end;

     CloseFile(OutFile);

     except
           MessageDlg('Exception Compute_Total_Areas feature' + IntToStr(iFeatureCount) + ' row ' + IntToStr(iDestinationRow),mtError,[mbOk],0);
     end;
end;

procedure TCombineDEHVegForm.Button1Click(Sender: TObject);
begin
     Combine_DEH_Vegetation;
end;

procedure TCombineDEHVegForm.Button2Click(Sender: TObject);
begin
     Compute_Total_Areas;
end;

end.
