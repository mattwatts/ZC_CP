unit ReportConfigurations;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Db, DBTables;

type
  TReportConfigurationsForm = class(TForm)
    ListBoxNames: TListBox;
    Label1: TLabel;
    BitBtnOk: TBitBtn;
    BitBtn2: TBitBtn;
    GroupBox1: TGroupBox;
    CheckTargetAchievement: TCheckBox;
    CheckSummary: TCheckBox;
    CheckPUDetail: TCheckBox;
    Label3: TLabel;
    ListBoxFields: TListBox;
    ThemeTable: TTable;
    CheckPUShape: TCheckBox;
    CheckBarGraph: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure LoadPlanningUnitConfigurations;
    procedure BitBtnOkClick(Sender: TObject);
    function WriteConfigurationsFile : string;
    procedure ExportShapesForConfigurations(sConfigurationTable : string);
    procedure CheckTargetAchievementClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ReportConfigurationsForm: TReportConfigurationsForm;

implementation

uses GIS, inifiles, Marxan_interface, SCP_Main, MZ_system_test,
  EditConfigurations, ComputeMarxanObjectives, MapWinGIS_TLB,
  Miscellaneous, BarGraph;

{$R *.DFM}

procedure TReportConfigurationsForm.ExportShapesForConfigurations(sConfigurationTable : string);
var
   InFile : TextFile;
   sHeaderRow, sLine, sConfiguration, sPrjFilename : string;
   iConfigurationCount, iCount, iElement, iPUIDIndex, iFieldIndex, iShapeIndex : integer;
   iLayerHandle, iShapeCount, iPUID : integer;
   NewSF, InputSF : MapWinGIS_TLB.Shapefile;
   NewField : MapWinGIS_TLB.Field;
   NewShape : MapWinGIS_TLB.Shape;
begin
     try
        assignfile(InFile,sConfigurationTable);
        reset(InFile);

        readln(InFile,sHeaderRow);
        iConfigurationCount := CountDelimitersInRow(sHeaderRow,',');
        closefile(InFile);

        // find PUID field index in InputSF
        iLayerHandle := GIS_Child.iPULayerHandle;
        if (iLayerHandle = -1) then
           iLayerHandle := GIS_Child.iLastLayerHandle;
        InputSF := IShapefile(GIS_Child.Map1.GetObject[iLayerHandle]);
        iPUIDIndex := -1;
        for iCount := 0 to (InputSF.NumFields-1) do
            if (InputSF.Field[iCount].Name = MarxanInterfaceForm.ComboKeyField.Text) then
               iPUIDIndex := iCount;

        for iCount := 1 to iConfigurationCount do
        begin
             reset(InFile);
             readln(InFile,sHeaderRow);
             sConfiguration := GetDelimitedAsciiElement(sHeaderRow,',',iCount + 1);

             // create blank shape file
             NewSF := CoShapefile.Create();
             NewSF.CreateNew(ExtractFilePath(sConfigurationTable) + sConfiguration + '.shp', SHP_POLYGON);

             // add fields to shape file
             NewField := CoField.Create();
             NewField.Name := 'PUID';
             NewField.Type_ := MapWinGIS_TLB.INTEGER_FIELD;
             NewField.Width := 12;
             // insert field
             iFieldIndex := 0;
             NewSF.EditInsertField(NewField, iFieldIndex, NewSF.GlobalCallback);
             // create Probability field
             NewField := CoField.Create();
             NewField.Name := 'VALUE';
             NewField.Type_ := MapWinGIS_TLB.INTEGER_FIELD;
             NewField.Width := 12;
             // insert field
             iFieldIndex := 0;
             NewSF.EditInsertField(NewField, iFieldIndex, NewSF.GlobalCallback);

             // loop through shapes, adding appropriate shapes to the new shapefile
             for iShapeCount := 1 to InputSF.NumShapes do
             begin
                   readln(InFile,sLine);
                   iElement := StrToInt(GetDelimitedAsciiElement(sLine,',',iCount+1));

                   if (iElement > 0) then
                   begin
                        iPUID := StrToInt(GetDelimitedAsciiElement(sLine,',',1));

                        // insert shape
                        iShapeIndex := iShapeCount;
                        NewSF.StartEditingShapes(True,NewSF.GlobalCallback);
                        NewSF.EditInsertShape(InputSF.Shape[iShapeCount-1], iShapeIndex);
                        NewSF.StopEditingShapes(True,True,NewSF.GlobalCallback);

                        // insert field values
                        NewSF.StartEditingTable(NewSF.GlobalCallback);
                        NewSF.EditCellValue(1, iShapeIndex, iPUID);
                        NewSF.EditCellValue(0, iShapeIndex, iElement);
                        NewSF.StopEditingTable(True,NewSF.GlobalCallback);
                   end;
             end;

             closefile(InFile);

             // copy the .prj file if it exists
             sPrjFilename := ChangeFileExt(GIS_Child.sPuFileName,'.prj');
             if fileexists(sPrjFilename) then
                ACopyFile(sPrjFilename, ExtractFilePath(sConfigurationTable) + sConfiguration + '.prj');
        end;

     except
     end;
end;

procedure TReportConfigurationsForm.LoadPlanningUnitConfigurations;
var
   AIni : TIniFile;
   iCount : integer;
begin
     AIni := TIniFile.Create(ExtractFilePath(GIS_Child.sPuFileName) + 'configurations.ini');

     AIni.ReadSection('Configurations',ListBoxFields.Items);

     ListBoxNames.Items.Clear;
     if (ListBoxFields.Items.Count > 0) then
        for iCount := 1 to ListBoxFields.Items.Count do
            ListBoxNames.Items.Add(AIni.ReadString('Configurations',ListBoxFields.Items.Strings[iCount-1],''));

     AIni.Free;

     if (ListBoxNames.Items.Count = 0) then
        MessageDlg('There are no planning unit configurations defined.',mtInformation,[mbOk],0)
     else
         if (EditConfigurationsForm <> nil) then
            ListBoxNames.Selected[EditConfigurationsForm.ListBoxPUConfiguration.ItemIndex] := True;
end;

procedure TReportConfigurationsForm.FormCreate(Sender: TObject);
begin
     LoadPlanningUnitConfigurations;
end;

function TReportConfigurationsForm.WriteConfigurationsFile : string;
var
   sFilename, sTableName, sFieldName : string;
   OutFile : TextFile;
   iCount, iFieldCount, iFieldValue : integer;
begin
     try
        //iCount := 0;
        //repeat
        //      Inc(iCount);
        //      sFilename := ExtractFilePath(GIS_Child.sPuFileName) + 'configurations' + IntToStr(iCount) + '.csv';
        //until not fileexists(sFilename);
        sFilename := ExtractFilePath(GIS_Child.sPuFileName) + 'configurations.csv';

        assignfile(OutFile,sFilename);
        rewrite(OutFile);
        write(OutFile,'Planning Unit Detail');
        for iCount := 0 to (ListBoxNames.Items.Count-1) do
            if ListBoxNames.Selected[iCount] then
               write(OutFile,',' + ListBoxNames.Items.Strings[iCount]);
        writeln(OutFile);

        ThemeTable.DatabaseName := ExtractFilePath(MarxanInterfaceForm.ComboPUShapefile.Text);
        sTableName := ExtractFileName(MarxanInterfaceForm.ComboPUShapefile.Text);
        sTableName := Copy(sTableName,1,Length(sTableName) - Length(ExtractFileExt(sTableName))) + '.dbf';
        ThemeTable.TableName := sTableName;
        ThemeTable.Open;

        for iCount := 1 to ThemeTable.RecordCount do
        begin
             write(OutFile,ThemeTable.FieldByName(MarxanInterfaceForm.ComboKeyField.Text).AsString);

             for iFieldCount := 0 to (ListBoxNames.Items.Count-1) do
                 if ListBoxNames.Selected[iFieldCount] then
                 begin
                      sFieldName := ListBoxFields.Items.Strings[iFieldCount];
                      iFieldValue := ThemeTable.FieldByName(sFieldName).AsInteger;
                      if (iFieldValue = 2) then
                         iFieldValue := 1;
                      //if (iFieldValue = 3) then
                      //   iFieldValue := 0;
                      write(OutFile,',' + IntToStr(iFieldValue));
                 end;

             writeln(OutFile);

             ThemeTable.Next;
        end;

        ThemeTable.Close;
        closefile(OutFile);
        Result := sFilename;

     except
           Result := '';
           MessageDlg('Exception in WriteConfigurationsFile',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TReportConfigurationsForm.BitBtnOkClick(Sender: TObject);
var
   sConfigurationsFile, sConfigurationsNewFileName, sTemp : string;
   iCount : integer;
   fContinue, fExecute : boolean;
begin
     try
        fContinue := True;

        if (ListBoxNames.SelCount < 1) then
        begin
             fContinue := False;
             MessageDlg('You must select at least one configuration to report on.',mtWarning,[mbOk],0);
             ModalResult := mrNone;
        end;

        if fContinue then
        begin
             if (not CheckTargetAchievement.Checked)
             and (not CheckSummary.Checked)
             and (not CheckPUDetail.Checked)
             and (not CheckPUShape.Checked) then
             begin
                  fContinue := False;
                  MessageDlg('You must select at least one report to create.',mtWarning,[mbOk],0);
                  ModalResult := mrNone;
             end;
        end;

        if fContinue then
        begin      
             // write the configurations to a csv file
             sConfigurationsFile := WriteConfigurationsFile;

             if (sConfigurationsFile <> '') then
             begin
                  // load the configuration csv file
                  SCPForm.CSVFileOpen(sConfigurationsFile);

                  fCMOSortOrder := True;
                  fCMOProduceDetail := False;
                  fCMOTargetAchievement := CheckTargetAchievement.Checked;
                  fCMOCheckSummary := CheckSummary.Checked;
                  sCMOInputDat := MarxanInterfaceForm.EditMarxanDatabasePath.Text;

                  fExecute := False;
                  if CheckTargetAchievement.Checked then
                     fExecute := True;
                  if CheckSummary.Checked then
                     fExecute := True;

                  if fExecute then
                  begin
                       if (iNumberOfZones <= 2) then
                       begin
                            // detect marcon and marprob datasets
                            sTemp := MarxanInterfaceForm.ReturnMarxanParameter('PROBABILITYWEIGHTING');
                            //if (MarxanInterfaceForm.ReturnMarxanIntParameter('PROBABILITYWEIGHTING') = -999) then
                            if (sTemp = '') then
                               ExecuteMarxanTest(sConfigurationsFile,1,0)
                            else
                                ExecuteMarConTest(sConfigurationsFile,1,0);

                            //ExecuteMarProb1DTest(sConfigurationsFile);
                            //ExecuteMarProb2DTest(sConfigurationsFile);
                       end
                       else
                           ExecuteMarZoneTest(sConfigurationsFile,1,0);
                  end;

                  if CheckPUShape.Checked then
                     // create a shapefile for each configuration we are reporting on
                     ExportShapesForConfigurations(sConfigurationsFile);

                  // close the configuration csv file
                  SCPForm.ReturnNamedChild(sConfigurationsFile).Close;
                  if CheckPUDetail.Checked then
                  begin
                       // rename the configurations file before loading it
                       // from configurations.csv to configurations_pu_detail.csv
                       sConfigurationsNewFileName := Copy(sConfigurationsFile,1,Length(sConfigurationsFile)-4) + '_pu_detail.csv';
                       renamefile(sConfigurationsFile,sConfigurationsNewFileName);
                       SCPForm.CSVFileOpen(sConfigurationsNewFileName);
                  end;

                  if CheckTargetAchievement.Checked then
                  begin
     fBarGraphStarting := True;
                       BarGraphForm := TBarGraphForm.Create(Application);
                       BarGraphForm.InitGraph(2);
                       BarGraphForm.ShowModal;
                       BarGraphForm.Free;
                  end;
             end;
        end;

     except
           MessageDlg('Exception when reporting configurations',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TReportConfigurationsForm.CheckTargetAchievementClick(
  Sender: TObject);
begin
     CheckBarGraph.Enabled := CheckTargetAchievement.Checked;
     if not CheckTargetAchievement.Checked then
        CheckBarGraph.Checked := False;
end;

end.
