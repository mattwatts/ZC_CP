unit ExtractAquaMapsSpecies;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Db, DBTables, ds;

type
  TExtractAquaMapSpeciesForm = class(TForm)
    Label1: TLabel;
    ComboDBFSpeciesRecords: TComboBox;
    Label2: TLabel;
    ComboSHPPolygonLocations: TComboBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ComboSpec1: TComboBox;
    ComboSpec2: TComboBox;
    ComboProb: TComboBox;
    ComboCCode: TComboBox;
    InputTable: TTable;
    Label7: TLabel;
    ComboSHPCCode: TComboBox;
    CheckFilterProbability: TCheckBox;
    EditFilterPr: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure ReadDBFFieldNames;
    procedure ReadSHPFieldNames;
    procedure ComboDBFSpeciesRecordsChange(Sender: TObject);
    procedure ExecuteExtraction;
    function ExportShapesForSpecies(const sOutputFileName : string; ValArray, PrArray : Array_T; iArraySize : integer) : integer;
    procedure ComboSHPPolygonLocationsChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ExtractAquaMapSpeciesForm: TExtractAquaMapSpeciesForm;

implementation

uses SCP_Main, GIS, DBF_Child, MapWinGIS_TLB, Marxan_interface, Miscellaneous;

{$R *.DFM}

function TExtractAquaMapSpeciesForm.ExportShapesForSpecies(const sOutputFileName : string; ValArray, PrArray : Array_T; iArraySize : integer) : integer;
var
   NewSF, InputSF : MapWinGIS_TLB.Shapefile;
   NewField : MapWinGIS_TLB.Field;
   NewShape : MapWinGIS_TLB.Shape;
   iCount, iArrayCount, iFieldIndex, iShapeIndex, iCSCIndex, iLayerHandle, iArrayIndex, iFilterRecordCount : integer;
   fShapeSelected : boolean;
   sArrayValue, sCSCValue : string[200];
   rProb : extended;
   rPr : double;
   sPrjFilename : string;
begin
     try
        NewSF := CoShapefile.Create();
        NewSF.CreateNew(sOutputFileName, SHP_POLYGON);
        iFilterRecordCount := 0;

        // create C Squares Code field
        NewField := CoField.Create();
        NewField.Name := 'C_SQ_CODE';
        NewField.Type_ := MapWinGIS_TLB.STRING_FIELD;
        NewField.Width := 12;
        // insert field
        iFieldIndex := 0;
        NewSF.EditInsertField(NewField, iFieldIndex, NewSF.GlobalCallback);
        // create Probability field
        NewField := CoField.Create();
        NewField.Name := 'PROB';
        NewField.Type_ := MapWinGIS_TLB.DOUBLE_FIELD;
        NewField.Width := 12;
        // insert field
        iFieldIndex := 0;
        NewSF.EditInsertField(NewField, iFieldIndex, NewSF.GlobalCallback);

        // find C Squares Code field index in InputSF
        iLayerHandle := GIS_Child.iPULayerHandle;
        if (iLayerHandle = -1) then
           iLayerHandle := GIS_Child.iLastLayerHandle;
        InputSF := IShapefile(GIS_Child.Map1.GetObject[iLayerHandle]);
        iCSCIndex := -1;
        for iCount := 0 to (InputSF.NumFields-1) do
            if (InputSF.Field[iCount].Name = ComboSHPCCode.Text) then
               iCSCIndex := iCount;

        // loop through shapes, adding selected shapes to new shapefile
        for iCount := 1 to InputSF.NumShapes do
        begin
             sCSCValue := InputSF.CellValue[iCSCIndex,iCount-1];
             fShapeSelected := False;
             iArrayIndex := -1;
             for iArrayCount := 1 to iArraySize do
             begin
                  ValArray.rtnValue(iArrayCount,@sArrayValue);

                  if (sArrayValue = sCSCValue) then
                  begin
                       fShapeSelected := True;
                       iArrayIndex := iArrayCount;
                  end;
             end;

             if fShapeSelected then
             begin
                  // insert shape
                  iShapeIndex := iCount;
                  NewSF.StartEditingShapes(True,NewSF.GlobalCallback);
                  NewSF.EditInsertShape(InputSF.Shape[iCount-1], iShapeIndex);
                  NewSF.StopEditingShapes(True,True,NewSF.GlobalCallback);

                  ValArray.rtnValue(iArrayIndex,@sArrayValue);
                  PrArray.rtnValue(iArrayIndex,@rProb);
                  rPr := rProb;
                  // insert field values
                  NewSF.StartEditingTable(NewSF.GlobalCallback);
                  NewSF.EditCellValue(1, iShapeIndex, sArrayValue);
                  NewSF.EditCellValue(0, iShapeIndex, rPr);
                  NewSF.StopEditingTable(True,NewSF.GlobalCallback);

                  Inc(iFilterRecordCount);
             end;
        end;

        // copy the .prj file if it exists
        if fileexists(sOutputFileName) then
        begin
             sPrjFilename := ChangeFileExt(InputSF.Filename,'.prj');
             if fileexists(sPrjFilename) then
                ACopyFile(sPrjFilename, ChangeFileExt(sOutputFileName,'.prj'));
        end;

        Result := iFilterRecordCount;

     except
     end;
end;


procedure TExtractAquaMapSpeciesForm.ReadDBFFieldNames;
var
   iDBFChildIndex, iCount : integer;
   ADBFChild : TDBFChild;
begin
     //
     try
        iDBFChildIndex := SCPForm.ReturnNamedDBFTableChildIndex(ComboDBFSpeciesRecords.Text);

        if (iDBFChildIndex > -1) then
        begin
             ADBFChild := TDBFChild(SCPForm.MDIChildren[iDBFChildIndex]);

             ComboSpec1.Items.Clear;
             ComboSpec2.Items.Clear;
             ComboCCode.Items.Clear;
             ComboProb.Items.Clear;
             ComboSpec1.Text := '';
             ComboSpec2.Text := '';
             ComboCCode.Text := '';
             ComboProb.Text := '';

             // read the fields from the table
             for iCount := 0 to (ADBFChild.DBGrid1.FieldCount - 1) do
             begin
                  ComboSpec1.Items.Add(ADBFChild.DBGrid1.Fields[iCount].FieldName);
                  ComboSpec2.Items.Add(ADBFChild.DBGrid1.Fields[iCount].FieldName);
                  ComboCCode.Items.Add(ADBFChild.DBGrid1.Fields[iCount].FieldName);
                  ComboProb.Items.Add(ADBFChild.DBGrid1.Fields[iCount].FieldName);
             end;
        end;

     except

     end;
end;

procedure TExtractAquaMapSpeciesForm.ReadSHPFieldNames;
var
   iLayerHandle, iCount : integer;
   InputSF : MapWinGIS_TLB.Shapefile;
begin
     //
     try
        iLayerHandle := GIS_Child.iPULayerHandle;
        if (iLayerHandle = -1) then
           iLayerHandle := GIS_Child.iLastLayerHandle;
        InputSF := IShapefile(GIS_Child.Map1.GetObject[iLayerHandle]);

        if (iLayerHandle > -1) then
           if (InputSF.Filename = ComboSHPPolygonLocations.Text) then
           begin
                ComboSHPCCode.Items.Clear;
                ComboSHPCCode.Text := '';

                // read the fields from the table
                for iCount := 0 to (InputSF.NumFields - 1) do
                begin
                     ComboSHPCCode.Items.Add(InputSF.Field[iCount].Name);
                end;
           end;

     except

     end;
end;

procedure TExtractAquaMapSpeciesForm.FormCreate(Sender: TObject);
var
   iCount, iCountLayers : integer;
begin
     // load a list of open dbf tables into dbf drop down listbox
     // load a list of open shp files into shp drop down listbox

     ComboDBFSpeciesRecords.Items.Clear;
     ComboSHPPolygonLocations.Items.Clear;

     if (SCPForm.MDIChildCount > 0) then
         for iCount := 0 to (SCPForm.MDIChildCount - 1) do
         begin
              if (SCPForm.MDIChildren[iCount].Tag = 3) then
                 // DBF table
                 ComboDBFSpeciesRecords.Items.Add(SCPForm.MDIChildren[iCount].Caption);

              if (SCPForm.MDIChildren[iCount].Tag = 2) then
              begin
                   // GIS child
                   if (GIS_Child.Map1.NumLayers > 0) then
                      for iCountLayers := 0 to (GIS_Child.Map1.NumLayers-1) do
                          ComboSHPPolygonLocations.Items.Add(GIS_Child.Map1.LayerName[iCountLayers]);
              end;
         end;

     if (ComboDBFSpeciesRecords.Items.Count > 0) then
        ComboDBFSpeciesRecords.Text := ComboDBFSpeciesRecords.Items.Strings[0];

     if (ComboSHPPolygonLocations.Items.Count > 0) then
        ComboSHPPolygonLocations.Text := ComboSHPPolygonLocations.Items.Strings[0];

     ReadDBFFieldNames;
     ReadSHPFieldNames;
end;

function FilterQuotes(const sField : string) : string;
var
   sResult : string;
begin
     sResult := sField;

     if (Length(sField) > 3) then
        if (sField[1] = '"') then
           if (sField[Length(sField)] = '"') then
              sResult := Copy(sField,2,Length(sField)-2);

     Result := sResult;
end;

procedure TExtractAquaMapSpeciesForm.ExecuteExtraction;
var
   ValueArray, ProbArray : Array_t;
   sCCode, sLastCCode : string[200];
   rProb, rFilterProbability : extended;
   iDBFChildIndex, iCount, iArraySize, iSpeciesIndex, iFilterRecordCount : integer;
   ADBFChild : TDBFChild;
   sSpec1, sSpec2, sLastSpec1, sLastSpec2, sOutputPath, sSummaryFileName : string;
   SummaryFile : TextFile;
   fFilterProbability : boolean;
begin
     try
        // get a handle on the dbf table
        iDBFChildIndex := SCPForm.ReturnNamedDBFTableChildIndex(ComboDBFSpeciesRecords.Text);
        if (iDBFChildIndex > -1) then
        begin
             ADBFChild := TDBFChild(SCPForm.MDIChildren[iDBFChildIndex]);
             sLastSpec1 := '';
             sLastSpec2 := '';
             sOutputPath := ExtractFilePath(ComboDBFSpeciesRecords.Text);
             sSummaryFileName := sOutputPath + 'species_summary.csv';
             assignfile(SummaryFile,sSummaryFileName);
             rewrite(SummaryFile);
             if (CheckFilterProbability.Checked) then
                writeln(SummaryFile,'SPNUMBER,SPNAME1,SPNAME2,SHAPERECORDCOUNT,FILTERRECORDCOUNT')
             else
                 writeln(SummaryFile,'SPNUMBER,SPNAME1,SPNAME2,RECORDCOUNT');

             ValueArray := Array_t.Create;
             ValueArray.init(SizeOf(sCCode),100);
             ProbArray := Array_t.Create;
             ProbArray.init(SizeOf(rProb),100);
             iArraySize := 0;
             iSpeciesIndex := 1;

             if (CheckFilterProbability.Checked) then
             begin
                  rFilterProbability := StrToFloat(EditFilterPr.Text);
             end;

             // traverse the dbf table
             ADBFChild.Query1.FindFirst;
             for iCount := 1 to ADBFChild.Query1.RecordCount do
             begin
                  // read this record
                  sSpec1 := FilterQuotes(ADBFChild.Query1.FieldByName(ComboSpec1.Text).AsString);
                  sSpec2 := FilterQuotes(ADBFChild.Query1.FieldByName(ComboSpec2.Text).AsString);
                  sCCode := FilterQuotes(ADBFChild.Query1.FieldByName(ComboCCode.Text).AsString);
                  rProb := ADBFChild.Query1.FieldByName(ComboProb.Text).AsFloat;

                  if (iCount = 1) then
                  begin
                       sLastSpec1 := sSpec1;
                       sLastSpec2 := sSpec2;
                  end;

                  if (CheckFilterProbability.Checked) then
                  begin
                       fFilterProbability := (rProb >= rFilterProbability);
                  end
                  else
                      fFilterProbability := True;

                  if fFilterProbability then
                  begin
                       if (sSpec1 <> sLastSpec1) or (sSpec2 <> sLastSpec2) then
                       begin
                            // C Code has changed

                            // call function to export shapes for a species
                            iFilterRecordCount := ExportShapesForSpecies(sOutputPath + 'species' + IntToStr(iSpeciesIndex) + '.shp',
                                                                         ValueArray,ProbArray,iArraySize);
                            // write a record for this species to the summary file
                            if (iFilterRecordCount > 0) then
                               writeln(SummaryFile,IntToStr(iSpeciesIndex) + ',' +
                                                   sLastSpec1 + ',' +
                                                   sLastSpec2 + ',' +
                                                   IntToStr(iArraySize) + ',' +
                                                   IntToStr(iFilterRecordCount));

                            iArraySize := 0;
                            sLastSpec1 := sSpec1;
                            sLastSpec2 := sSpec2;
                            Inc(iSpeciesIndex);
                       end;

                       // store this record in the array
                       Inc(iArraySize);
                       if (iArraySize > ValueArray.lMaxSize) then
                       begin
                            ValueArray.resize(ValueArray.lMaxSize + 100);
                            ProbArray.resize(ProbArray.lMaxSize + 100);
                       end;
                       ValueArray.setValue(iArraySize,@sCCode);
                       ProbArray.setValue(iArraySize,@rProb);
                  end;

                  if (iCount < ADBFChild.Query1.RecordCount) then
                     ADBFChild.Query1.FindNext;
             end;

             // call function to export shapes for the last species
             iFilterRecordCount := ExportShapesForSpecies(sOutputPath + 'species' + IntToStr(iSpeciesIndex) + '.shp',
                                                          ValueArray,ProbArray,iArraySize);
             // write a record for the last species to the summary file
             if (iFilterRecordCount > 0) then
                writeln(SummaryFile,IntToStr(iSpeciesIndex) + ',' +
                                    sSpec1 + ',' +
                                    sSpec2 + ',' +
                                    IntToStr(iArraySize) + ',' +
                                    IntToStr(iFilterRecordCount));

             ValueArray.Destroy;
             ProbArray.Destroy;
             closefile(SummaryFile);
        end;

     except
     end;
end;

procedure TExtractAquaMapSpeciesForm.BitBtn1Click(Sender: TObject);
begin
     // traverse the dbf table and
     ExecuteExtraction;
end;

procedure TExtractAquaMapSpeciesForm.ComboDBFSpeciesRecordsChange(
  Sender: TObject);
begin
     ReadDBFFieldNames;
end;

procedure TExtractAquaMapSpeciesForm.ComboSHPPolygonLocationsChange(
  Sender: TObject);
begin
     ReadSHPFieldNames;
end;

end.
