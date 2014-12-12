unit ReportOnConfiguration;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Db, DBTables, Grids, ExtCtrls;

type
  TSummariseZonesForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    EditValuesFile: TEdit;
    Button3: TButton;
    Label6: TLabel;
    EditNameFile: TEdit;
    Button4: TButton;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    EditShapefile: TEdit;
    ComboShapePUID: TComboBox;
    Button1: TButton;
    ComboReportField: TComboBox;
    OpenDBF: TOpenDialog;
    InputTable: TTable;
    Button5: TButton;
    EditOutput: TEdit;
    Label7: TLabel;
    SaveDialog1: TSaveDialog;
    OpenValues: TOpenDialog;
    OpenName: TOpenDialog;
    ListFieldValues: TListBox;
    GridFieldValues: TStringGrid;
    GridFeatName: TStringGrid;
    RadioOutputType: TRadioGroup;
    CheckZones: TCheckBox;
    CheckPUID: TCheckBox;
    CheckFeat: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure LoadFieldNames;
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure ExecuteSummariseZones;
    procedure WriteZoneTable;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SummariseZonesForm: TSummariseZonesForm;

implementation

uses
    Miscellaneous, ds, GIS, SCP_Main, MapWinGIS_TLB;

{$R *.DFM}

procedure TSummariseZonesForm.LoadFieldNames;
var
   iCount : integer;
begin
     if fileexists(EditShapefile.Text) then
     try
        Screen.Cursor := crHourglass;

        ComboShapePUID.Items.Clear;
        ComboShapePUID.Text := '';
        ComboReportField.Items.Clear;
        ComboReportField.Text := '';

        InputTable.DatabaseName := TrimTrailingSlashes(ExtractFilePath(EditShapefile.Text));
        InputTable.TableName := ExtractFileName(EditShapefile.Text);
        InputTable.Open;
        // read the fields from the table
        for iCount := 0 to (InputTable.FieldCount - 1) do
        begin
             ComboShapePUID.Items.Add(InputTable.FieldDefs.Items[iCount].Name);
             ComboReportField.Items.Add(InputTable.FieldDefs.Items[iCount].Name);
        end;
        InputTable.Close;

        ComboShapePUID.Text := ComboShapePUID.Items.Strings[0];
        ComboReportField.Text := ComboReportField.Items.Strings[0];

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in LoadFieldNames',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;


procedure TSummariseZonesForm.Button1Click(Sender: TObject);
begin
     if OpenDBF.Execute then
     begin
          EditShapefile.Text := OpenDBF.Filename;
          LoadFieldNames;
     end;
end;

procedure TSummariseZonesForm.Button5Click(Sender: TObject);
begin
     if SaveDialog1.Execute then
        EditOutput.Text := SaveDialog1.Filename;
end;

procedure TSummariseZonesForm.Button3Click(Sender: TObject);
begin
     if OpenValues.Execute then
        EditValuesFile.Text := OpenValues.Filename;
end;

procedure TSummariseZonesForm.Button4Click(Sender: TObject);
begin
     if OpenName.Execute then
        EditNameFile.Text := OpenName.Filename;
end;

function CustomFloatToStr(const rNumber : extended) : string;
begin
     result := FloatToStrF(rNumber,ffFixed,15,2);
end;

procedure TSummariseZonesForm.WriteZoneTable;
var
   ZoneFile : TextFile;
   iCount : integer;
begin
     assignfile(ZoneFile,Copy(EditOutput.Text,1,Length(EditOutput.Text)-4) + '_zones.csv');
     rewrite(ZoneFile);
     writeln(ZoneFile,'ZoneIndex,ZoneName');

     for iCount := 0 to (ListFieldValues.Items.Count - 1) do
         writeln(ZoneFile,IntToStr(iCount+1) + ',' + ListFieldValues.Items.Strings[iCount]);

     closefile(ZoneFile);
end;

procedure TSummariseZonesForm.ExecuteSummariseZones;
var
   sFieldValue, sPUID, sLine, sPUName, sDBFName : string;
   iCount, iUniqueValueCount, iReportFeatureCount, iCount1, iCount2, iArrayIndex,
   iPUID, iFeatID, iPUIndex, iFeatIndex, iZoneIndex : integer;
   ValueArray, FeatureTotalArray : Array_t;
   rValue, rValueArray, rTotalArray, rPercentageValue : extended;
   InFile, OutFile : TextFile;
   fRestorePULayer : boolean;
   myExtents: MapWinGIS_TLB.Extents;
begin
     try
        // if the dbf table is our planning unit layer, close it from GIS window and restore it when finished
        fRestorePULayer := False;
        if SCPForm.fMarxanActivated then
        begin
             sPUName := Copy(GIS_Child.sPuFileName,1,Length(GIS_Child.sPuFileName)-4);
             sDBFName := Copy(EditShapefile.Text,1,Length(EditShapefile.Text)-4);
             if (sPUName = sDBFName) then
             begin
                  // remove layer from GIS display
                  myExtents := IExtents(GIS_Child.Map1.Extents);
                  GIS_Child.RemoveAllShapes;
                  fRestorePULayer := True;
             end;
        end;

        // parse dbf table, loading all "PUID" and "Field To Summarise" values into an array
        // count how many unique "Field To Summarise" values there are
        InputTable.DatabaseName := TrimTrailingSlashes(ExtractFilePath(EditShapefile.Text));
        InputTable.TableName := ExtractFileName(EditShapefile.Text);
        InputTable.Open;
        ListFieldValues.Items.Clear;
        GridFieldValues.ColCount := 2;
        GridFieldValues.RowCount := InputTable.RecordCount + 1;
        GridFieldValues.Cells[0,0] := 'PUID';
        GridFieldValues.Cells[1,0] := 'ZoneName';
        for iCount := 1 to InputTable.RecordCount do
        begin
             sPUID := InputTable.FieldByName(ComboShapePUID.Text).AsString;
             sFieldValue := InputTable.FieldByName(ComboReportField.Text).AsString;

             if (sFieldValue <> '') then
                if (ListFieldValues.Items.IndexOf(sFieldValue) = -1) then
                   ListFieldValues.Items.Add(sFieldValue);

             GridFieldValues.Cells[0,iCount] := sPUID;
             GridFieldValues.Cells[1,iCount] := sFieldValue;

             InputTable.Next;
        end;
        InputTable.Close;

        if CheckZones.Checked then
           WriteZoneTable;

        // sort arrays by PUID to make binary lookup array for PUID/"Field To Summarise"
        SortGrid(GridFieldValues,1,0,SORT_TYPE_REAL,1);
        if CheckPUID.Checked then
           SaveStringGrid2CSV(GridFieldValues,Copy(EditOutput.Text,1,Length(EditOutput.Text)-4) + '_planning_units.csv');

        // load the feature name file to an array
        FasterLoadCSV2StringGrid(GridFeatName,EditNameFile.Text);
        SortGrid(GridFeatName,1,0,SORT_TYPE_REAL,1);
        if CheckFeat.Checked then
           SaveStringGrid2CSV(GridFeatName,Copy(EditOutput.Text,1,Length(EditOutput.Text)-4) + '_features.csv');

        // create 2d extended array of unique values X number of features to summarise with
        iUniqueValueCount := ListFieldValues.Items.Count;
        iReportFeatureCount := GridFeatName.RowCount - 1;
        ValueArray := Array_t.Create;
        ValueArray.init(SizeOf(extended),Round(iUniqueValueCount * iReportFeatureCount));
        FeatureTotalArray := Array_t.Create;
        FeatureTotalArray.init(SizeOf(extended),iReportFeatureCount);
        rValueArray := 0;
        rTotalArray := 0;
        for iCount2 := 1 to iReportFeatureCount do
            FeatureTotalArray.setValue(iCount2,@rTotalArray);

        for iCount1 := 1 to ValueArray.lMaxSize do
            ValueArray.setValue(iCount1,@rValueArray);

        // parse feature file, remembering how much of each feature exists in each unique value for "Field To Summarise"
        assignfile(InFile,EditValuesFile.Text);
        reset(InFile);
        readln(InFile,sLine);
        repeat
              readln(InFile,sLine);
              // species,pu,amount

              iFeatID := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
              iPUID := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
              rValue := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));

              // find feature and zone indices in their respective arrays
              iFeatIndex := BinaryLookupGrid_Integer(GridFeatName, iFeatID, 0, 1, GridFeatName.RowCount-1);
              iPUIndex := BinaryLookupGrid_Integer(GridFieldValues, iPUID, 0, 1, GridFieldValues.RowCount-1);

              if (GridFieldValues.Cells[1,iPUIndex] <> '') then
              begin
                   // find 1-based zone index for this PU's zone
                   iZoneIndex := ListFieldValues.Items.IndexOf(GridFieldValues.Cells[1,iPUIndex]) + 1;

                   // increment the amount for this feature in this zone
                   iArrayIndex := Round(iFeatIndex + ((iZoneIndex - 1) * iReportFeatureCount));
                   ValueArray.rtnValue(iArrayIndex,@rValueArray);
                   rValueArray := rValueArray + rValue;
                   ValueArray.setValue(iArrayIndex,@rValueArray);
              end;

              // increment the total amount for this feature
              FeatureTotalArray.rtnValue(iFeatIndex,@rTotalArray);
              rTotalArray := rTotalArray + rValue;
              FeatureTotalArray.setValue(iFeatIndex,@rTotalArray);

        until Eof(InFile);                                                     

        // write summary to output file
        assignfile(OutFile,EditOutput.Text);
        rewrite(OutFile);
        // write zone names to header row
        write(OutFile,'Feature Name,Feature Class');
        for iCount1 := 1 to iUniqueValueCount do
            write(OutFile,',' + ListFieldValues.Items.Strings[iCount1-1]);
        // write total if output type is absolute
        if (RadioOutputType.ItemIndex = 0) then
           write(OutFile,',total');
        writeln(OutFile);
        // write one line for each feature
        for iCount2 := 1 to iReportFeatureCount do
        begin
             write(OutFile,GridFeatName.Cells[1,iCount2] + ',' + GridFeatName.Cells[2,iCount2]);

             FeatureTotalArray.rtnValue(iCount2,@rTotalArray);

             for iCount1 := 1 to iUniqueValueCount do
             begin
                  iArrayIndex := Round(iCount2 + ((iCount1 - 1) * iReportFeatureCount));
                  ValueArray.rtnValue(iArrayIndex,@rValueArray);

                  if (RadioOutputType.ItemIndex = 0) then
                     write(OutFile,',' + FloatToStr(rValueArray))
                  else
                  begin
                       if (rTotalArray > 0) then
                          write(OutFile,',' + CustomFloatToStr(rValueArray/rTotalArray*100))
                       else
                           write(OutFile,',0');
                  end;
             end;                                     

             if (RadioOutputType.ItemIndex = 0) then
                write(OutFile,',' + FloatToStr(rTotalArray));

             writeln(OutFile);
        end;

        closefile(OutFile);
        ValueArray.Destroy;
        // restore planning unit layer to GIS window if applicable
        if fRestorePULayer then
        begin
             // add layer to GIS display
             GIS_Child.RestoreAllShapes;
             GIS_Child.Map1.Extents := myExtents;
             GIS_Child.RedrawTimer.Enabled := True;
        end;

     except
           MessageDlg('Exception in ExecuteSummariseZones',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TSummariseZonesForm.BitBtn1Click(Sender: TObject);
begin
     ExecuteSummariseZones;
end;

end.
