unit EditConfigurations;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, Db, DBTables, ds;

type
  TEditConfigurationsForm = class(TForm)
    Panel1: TPanel;
    ThemeTable: TTable;
    PUConfiguration: TEdit;
    btnAdd: TButton;
    Button1: TButton;
    btnSendToMarxan: TButton;
    Button5: TButton;
    ListBoxConfigFieldNames: TListBox;
    ListBoxPUConfiguration: TListBox;
    Splitter1: TSplitter;
    Panel2: TPanel;
    RadioGroupAction: TRadioGroup;
    ListBox1: TListBox;
    PanelSave: TPanel;
    PanelUndo: TPanel;
    StatusGrid: TStringGrid;
    Timer1: TTimer;
    procedure btnAddClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LoadPlanningUnitConfigurations;
    procedure LoadSaveToZones;
    procedure Button1Click(Sender: TObject);
    function ReturnMaxConfigNumber : integer;
    procedure PopluateSeedConfiguration(const sConfigFieldName : string; const iSeedConfiguration : integer);
    procedure SaveNewConfigurationSettings;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBoxPUConfigurationMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SaveToScenario;
    procedure ListBoxPUConfigurationKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnSendToMarxanClick(Sender: TObject);
    procedure StoreStatusVector;
    procedure StorePuLockVector;
    procedure FormActivate(Sender: TObject);
    procedure PanelSaveClick(Sender: TObject);
    procedure RedrawConfigMapLegend;
    procedure PanelUndoClick(Sender: TObject);
    procedure RestoreUndo;
    procedure Timer1Timer(Sender: TObject);
    //procedure CreateParams(var Params: TCreateParams); override;
  private
    { Private declarations }
  public
    { Public declarations }
    iConfigNumber : integer;
    sConfigField, sConfigName : string;
    fUndoArray : boolean;
    UndoArray : Array_t;
  end;

var
  EditConfigurationsForm: TEditConfigurationsForm;

implementation

uses NewConfiguration, SCP_Main, GIS, inifiles, Marxan_interface,
  ReportConfigurations, Miscellaneous, MapWinGIS_TLB;

{$R *.DFM}

(*procedure TEditConfigurationsForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style:=(Style or WS_POPUP) and (not WS_DLGFRAME);
end;*)


procedure TEditConfigurationsForm.StoreStatusVector;
var
   fFound : boolean;
   sFilename, sInLine, sTableName, sFieldValue, sTest : string;
   InFile, OutFile : TextFile;
   iStatusField, iIdField, iFieldCount, iCount, iCountRow, iPUID, iStatus, iMatchingIndex : integer;
begin
     try
        Screen.Cursor := crHourglass;
        // store the current configuration as status in pu.dat
        // initialise input/output files
        sFilename := MarxanInterfaceForm.Return_MZ_Filename('pu',fFound);
        ACopyFile(sFilename,sFilename + '~');
        assignfile(InFile,sFilename + '~');
        reset(InFile);
        assignfile(OutFile,sFilename);
        rewrite(OutFile);
        readln(InFile,sInLine);
        // find status field
        iFieldCount := CountDelimitersInRow(sInLine,',') + 1;
        // detect which field index is id and which is status
        iStatusField := -1;
        iIdField := -1;
        for iCount := 1 to iFieldCount do
        begin
             sTest := GetDelimitedAsciiElement(sInLine,',',iCount);
             if (sTest = 'status') then
                iStatusField := iCount;
             if (sTest = 'id') then
                iIdField := iCount;
        end;
        // write header row
        if (iStatusField = -1) then // append data field to row
        begin
             writeln(OutFile,sInLine + ',status');
             Inc(iFieldCount);
             iStatusField := iFieldCount;
        end
        else
            writeln(OutFile,sInLine);


        // traverse data records
        ThemeTable.DatabaseName := ExtractFilePath(MarxanInterfaceForm.ComboPUShapefile.Text);
        sTableName := ExtractFileName(MarxanInterfaceForm.ComboPUShapefile.Text);
        sTableName := Copy(sTableName,1,Length(sTableName) - Length(ExtractFileExt(sTableName))) + '.dbf';
        ThemeTable.TableName := sTableName;
        ThemeTable.Open;
        // create a data structure to store the pukey and status
        StatusGrid.ColCount := 2;
        StatusGrid.RowCount := ThemeTable.RecordCount;
        for iCountRow := 1 to ThemeTable.RecordCount do
        begin
             StatusGrid.Cells[0,iCountRow-1] := ThemeTable.FieldByName(MarxanInterfaceForm.ComboKeyField.Text).AsString;
             StatusGrid.Cells[1,iCountRow-1] := ThemeTable.FieldByName(sConfigField).AsString;
             ThemeTable.Next;
        end;
        ThemeTable.Close;

        // create binary lookup for status
        SortGrid(StatusGrid,0,0,SORT_TYPE_REAL,1);

        // store status in the pu.dat file
        repeat
              // read from input files
              readln(InFile,sInLine);

              // find matching planning unit in data structure
              iPUID := StrToInt(GetDelimitedAsciiElement(sInLine,',',iIdField));
              iMatchingIndex := BinaryLookupGrid_Integer(StatusGrid, iPUID, 0, 0, StatusGrid.RowCount-1);
              // get matching status
              iStatus := StrToInt(StatusGrid.Cells[1,iMatchingIndex]);

              // write to output file
              if (iStatusField = -1) then // append data field to row
                 writeln(OutFile,sInLine + ',' + sFieldValue)
              else
              begin // substitute data field within row
                   for iCount := 1 to iFieldCount do
                   begin
                        if (iCount > 1) then
                           write(OutFile,',');

                        if (iIdField = iCount) then
                           write(OutFile,IntToStr(iPUID))
                        else
                            if (iStatusField = iCount) then
                               write(OutFile,IntToStr(iStatus))
                            else
                                write(OutFile,GetDelimitedAsciiElement(sInLine,',',iCount));
                   end;
                   writeln(OutFile);
              end;

        until Eof(InFile);      

        closefile(InFile);
        closefile(OutFile);
        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in StoreStatusVector',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TEditConfigurationsForm.PopluateSeedConfiguration(const sConfigFieldName : string; const iSeedConfiguration : integer);
var
   fFound : boolean;
   sFilename, sLine, sTableName, sFieldValue : string;
   InFile : TextFile;
   iStatusField, iFieldCount, iCountRow : integer;
   myExtents: MapWinGIS_TLB.Extents;

   function FilterMarxanResult(const iResult : integer) : integer;
   begin
        if (iNumberOfZones <= 2) and (iResult = 1) then
           Result := 0
        else
            Result := iResult;
   end;

   function ReturnPURowValue : integer;
   var
      iSolution : integer;
   begin
        // iNumberOfRuns ReturnMaxConfigNumber
        case iSeedConfiguration of
             0 : Result := 0;
             1 : 
             begin // 1 Marxan initial configuration, (MXN read from pu.dat status, MZN read from pulock.dat)
                  if (iStatusField = -1) then
                     Result := 0
                  else
                  begin
                       readln(InFile,sLine);
                       Result := StrToInt(GetDelimitedAsciiElement(sLine,',',iStatusField));
                  end;
             end;
             2 : Result := FilterMarxanResult(ThemeTable.FieldByName('BESTSOLN').AsInteger);
             3 : Result := FilterMarxanResult(ThemeTable.FieldByName('SOLN1').AsInteger);
        else
            if (iSeedConfiguration >= 3) and (iSeedConfiguration <= (iNumberOfRuns+2)) then
            begin
                 Result := FilterMarxanResult(ThemeTable.FieldByName('SOLN' + IntToStr(iSeedConfiguration-2)).AsInteger);
            end;

            if (iSeedConfiguration >= (iNumberOfRuns+3)) then
            begin
                 Result := ThemeTable.FieldByName('CONFIG' + IntToStr(iSeedConfiguration-iNumberOfRuns-2)).AsInteger;
            end; 
        end;
   end;

   procedure InitStatusFile;
   var
      iCount : integer;
   begin //    1 Marxan initial configuration, (MXN read from pu.dat status, MZN read from pulock.dat)
        sFilename := MarxanInterfaceForm.Return_MZ_Filename('pu',fFound);
        assignfile(InFile,sFilename);
        reset(InFile);
        readln(InFile,sLine);
        // find status field
        iFieldCount := CountDelimitersInRow(sLine,',') + 1;
        iStatusField := -1;
        for iCount := 1 to iFieldCount do
            if (GetDelimitedAsciiElement(sLine,',',iCount) = 'status') then
               iStatusField := iCount;
   end;

   procedure FreeStatusFile;
   begin
        closefile(InFile);
   end;

begin
     // TMarxanInterfaceForm.WriteMarxanResult
     try
        // force the database field if not present
        myExtents := IExtents(GIS_Child.Map1.Extents);
        GIS_Child.RemoveAllShapes;
        MarxanInterfaceForm.ForceAField(sConfigFieldName);
        if (iSeedConfiguration = 1) then
           InitStatusFile;

        // iSeedConfiguration
        //    0 Blank configuration
        //    1 Marxan initial configuration, (MXN read from pu.dat status, MZN read from pulock.dat)
        //    2 Marxan Best Solution
        //    3 Marxan Solution 1
        //    ... Marxan Solution N
        //    User CONFIG1
        //    ... User CONFIGX

        ThemeTable.DatabaseName := ExtractFilePath(MarxanInterfaceForm.ComboPUShapefile.Text);
        sTableName := ExtractFileName(MarxanInterfaceForm.ComboPUShapefile.Text);
        sTableName := Copy(sTableName,1,Length(sTableName) - Length(ExtractFileExt(sTableName))) + '.dbf';
        ThemeTable.TableName := sTableName;
        ThemeTable.Open;

        for iCountRow := 1 to ThemeTable.RecordCount do
        begin
             ThemeTable.Edit;
             ThemeTable.FieldByName(sConfigFieldName).AsInteger := ReturnPURowValue;

             ThemeTable.Next;
        end;

        // free objects used
        ThemeTable.Close;
        GIS_Child.RestoreAllShapes;
        GIS_Child.Map1.Extents := myExtents;
        if (iSeedConfiguration = 1) then
           FreeStatusFile;

     except
           MessageDlg('Exception in PopulateSeedConfiguration',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TEditConfigurationsForm.SaveNewConfigurationSettings;
var
   AIni : TIniFile;
begin
     AIni := TIniFile.Create(ExtractFilePath(GIS_Child.sPuFileName) + 'configurations.ini');

     AIni.WriteString('Configurations',sConfigField,sConfigName);

     AIni.Free;
end;

procedure TEditConfigurationsForm.btnAddClick(Sender: TObject);
begin
     NewConfigurationForm := TNewConfigurationForm.Create(Application);

     if (ListBoxPUConfiguration.Items.IndexOf(PUConfiguration.Text) = -1) then
        NewConfigurationForm.EditConfigurationName.Text := PUConfiguration.Text;

     if (mrOk = NewConfigurationForm.ShowModal) then
     begin
          // create new configuration
          iConfigNumber := ReturnMaxConfigNumber + 1;
          sConfigField := 'CONFIG' + IntToStr(iConfigNumber);
          sConfigName := NewConfigurationForm.EditConfigurationName.Text;

          // populate it with seed configuration
          PopluateSeedConfiguration(sConfigField,NewConfigurationForm.ComboSeedConfiguration.Items.IndexOf(NewConfigurationForm.ComboSeedConfiguration.Text));

          // store the configuration in our parameter file
          SaveNewConfigurationSettings;
          LoadPlanningUnitConfigurations;
          PUConfiguration.Text := sConfigName;

          ListBoxPUConfiguration.ItemIndex := ListBoxConfigFieldNames.Items.IndexOf(sConfigField);

          // load configuration into GIS display
          GIS_Child.UpdateMap(0, iNumberOfZones-1, sConfigField, False, True, MarxanInterfaceForm);
          GIS_Child.RedrawSelection;
          RedrawConfigMapLegend;
     end;
end;

procedure TEditConfigurationsForm.Button5Click(Sender: TObject);
begin
     Close;
     GIS_Child.RedrawTimer.Enabled := True;
     //MarxanInterfaceForm.RefreshGISDisplay;
     //GIS_Child.RedrawSelection;
     //RedrawConfigMapLegend;
end;

function TEditConfigurationsForm.ReturnMaxConfigNumber : integer;
var
   AIni : TIniFile;
   iCount : integer;
begin
     AIni := TIniFile.Create(ExtractFilePath(GIS_Child.sPuFileName) + 'configurations.ini');

     //AIni.ReadSection('Configurations',ListBoxPUConfiguration.Items);
     AIni.ReadSection('Configurations',ListBox1.Items);

     if (ListBox1.Items.Count > 0) then
     begin
          iCount := 0;
          repeat
                Inc(iCount);

          //until (ListBoxPUConfiguration.Items.IndexOf('CONFIG' + IntToStr(iCount)) = -1);
          until (ListBox1.Items.IndexOf('CONFIG' + IntToStr(iCount)) = -1);
     end
     else
         iCount := 2;

     //AIni.ReadSectionValues('Configurations',ListBoxPUConfiguration.Items);

     AIni.Free;

     Result := iCount - 1;
end;

procedure TEditConfigurationsForm.LoadPlanningUnitConfigurations;
var
   AIni : TIniFile;
   iCount : integer;
begin
     AIni := TIniFile.Create(ExtractFilePath(GIS_Child.sPuFileName) + 'configurations.ini');

     AIni.ReadSection('Configurations',ListBoxConfigFieldNames.Items);

     ListBoxPUConfiguration.Items.Clear;
     if (ListBoxConfigFieldNames.Items.Count > 0) then
        for iCount := 1 to ListBoxConfigFieldNames.Items.Count do
            ListBoxPUConfiguration.Items.Add(AIni.ReadString('Configurations',ListBoxConfigFieldNames.Items.Strings[iCount-1],''));

     AIni.Free;

     //ListBoxPUConfiguration.Refresh;

     if (ListBoxPUConfiguration.Items.Count = 0) then
     begin
        btnAddClick(Self);
        //MessageDlg('There are no planning unit configurations defined.',mtInformation,[mbOk],0);
        // if no configurations exist then
        //    EditConfigurationsForm.Button5Click(Sender);
     end;
end;

procedure TEditConfigurationsForm.LoadSaveToZones;
var
   iCount : integer;
begin
     RadioGroupAction.Items.Clear;
     RadioGroupAction.Items.Add('Not Selected');

     if (iNumberOfZones <= 2) then
     begin
          RadioGroupAction.Items.Add('Reserved');
          RadioGroupAction.Items.Add('Excluded');
     end
     else
     begin
          for iCount := 1 to iNumberOfZones do
              RadioGroupAction.Items.Add(MarxanInterfaceForm.ReturnZoneName(iCount));
     end;

     RadioGroupAction.ItemIndex := 0;
end;

procedure TEditConfigurationsForm.FormCreate(Sender: TObject);
begin
     LoadPlanningUnitConfigurations;

     LoadSaveToZones;

     if (ListBoxPUConfiguration.Items.Count > 0) then
     begin
          PUConfiguration.Text := ListBoxPUConfiguration.Items.Strings[0];
          ListBoxPUConfiguration.ItemIndex := 0;

          iConfigNumber := 1;
          sConfigField := ListBoxConfigFieldNames.Items.Strings[0];
          sConfigName := ListBoxPUConfiguration.Items.Strings[0];

          GIS_Child.UpdateMap(0, iNumberOfZones-1, ListBoxConfigFieldNames.Items.Strings[0], False, True, MarxanInterfaceForm);
          GIS_Child.RedrawSelection;
          RedrawConfigMapLegend;
     end;

     fUndoArray := False;
end;

procedure TEditConfigurationsForm.Button1Click(Sender: TObject);
begin
     ReportConfigurationsForm := TReportConfigurationsForm.Create(Application);
     ReportConfigurationsForm.ShowModal;
     ReportConfigurationsForm.Free;

     SCPForm.UpdateOpenFiles;
end;

procedure TEditConfigurationsForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
     SCPForm.EditConfigurations2.Enabled := False;
     SCPForm.EditConfigurations2.Visible := False;

     SCPForm.fEditConfigurationsForm := False;

     if fUndoArray then
        UndoArray.Destroy;


     Action := caFree;
end;

procedure TEditConfigurationsForm.ListBoxPUConfigurationMouseUp(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
     // user has selected another configuration
     if (ListBoxPUConfiguration.ItemIndex > -1) then
     begin
          PUConfiguration.Text := ListBoxPUConfiguration.Items.Strings[ListBoxPUConfiguration.ItemIndex];
          sConfigField := ListBoxConfigFieldNames.Items.Strings[ListBoxPUConfiguration.ItemIndex];
          GIS_Child.UpdateMap(0, iNumberOfZones-1, sConfigField, False, True, MarxanInterfaceForm);
          GIS_Child.RedrawSelection;
          RedrawConfigMapLegend;
     end;
end;

procedure TEditConfigurationsForm.RestoreUndo;
var
   fShape : boolean;
   iCount, iUndo : integer;
   sTableName : string;
   myExtents: MapWinGIS_TLB.Extents;
begin
     if fUndoArray then
        if GIS_Child.fShapeSelection then
        try
           myExtents := IExtents(GIS_Child.Map1.Extents);
           GIS_Child.RemoveAllShapes;
           ThemeTable.DatabaseName := ExtractFilePath(MarxanInterfaceForm.ComboPUShapefile.Text);
           sTableName := ExtractFileName(MarxanInterfaceForm.ComboPUShapefile.Text);
           sTableName := Copy(sTableName,1,Length(sTableName) - Length(ExtractFileExt(sTableName))) + '.dbf';
           ThemeTable.TableName := sTableName;
           ThemeTable.Open;

           for iCount := 1 to ThemeTable.RecordCount do
           begin
                // restore Undo value
                UndoArray.rtnValue(iCount,@iUndo);

                ThemeTable.Edit;
                ThemeTable.FieldByName(sConfigField).AsInteger := iUndo;
                ThemeTable.Next;
           end;

           ThemeTable.Close;
           GIS_Child.RestoreAllShapes;
           GIS_Child.Map1.Extents := myExtents;

           fUndoArray := False;
           UndoArray.Destroy;

        except
              MessageDlg('Exception in RestoreUndo',mtError,[mbOk],0);
              Application.Terminate;
        end;
end;

procedure TEditConfigurationsForm.SaveToScenario;
var
   fShape : boolean;
   iCount, iSaveValue, iUndo : integer;
   sTableName : string;
   myExtents: MapWinGIS_TLB.Extents;
begin
     if GIS_Child.fShapeSelection then
     try
        if (RadioGroupAction.ItemIndex = 0) then
           iSaveValue := 0
        else
            if (iNumberOfZones <= 2) then
               iSaveValue := RadioGroupAction.ItemIndex + 1 // Marxan status
            else
                iSaveValue := RadioGroupAction.ItemIndex; // MarZone status

        myExtents := IExtents(GIS_Child.Map1.Extents);
        GIS_Child.RemoveAllShapes;
        ThemeTable.DatabaseName := ExtractFilePath(MarxanInterfaceForm.ComboPUShapefile.Text);
        sTableName := ExtractFileName(MarxanInterfaceForm.ComboPUShapefile.Text);
        sTableName := Copy(sTableName,1,Length(sTableName) - Length(ExtractFileExt(sTableName))) + '.dbf';
        ThemeTable.TableName := sTableName;
        ThemeTable.Open;

        // create Undo array
        if fUndoArray then
           UndoArray.Destroy;
        fUndoArray := True;
        UndoArray := Array_t.Create;
        UndoArray.init(SizeOf(integer),ThemeTable.RecordCount);

        for iCount := 1 to ThemeTable.RecordCount do
        begin
             //   iPUID := ThemeTable.FieldByName(MarxanInterfaceForm.ComboKeyField.Text).AsInteger;

             // store Undo value
             iUndo := ThemeTable.FieldByName(sConfigField).AsInteger;
             UndoArray.setValue(iCount,@iUndo);

             GIS_Child.ShapeSelection.rtnValue(iCount,@fShape);
             if fShape then
             begin
                  ThemeTable.Edit;
                  ThemeTable.FieldByName(sConfigField).AsInteger := iSaveValue;
             end;

             ThemeTable.Next;
        end;

        ThemeTable.Close;
        GIS_Child.RestoreAllShapes;
        GIS_Child.Map1.Extents := myExtents;

     except
           MessageDlg('Exception in SaveToScenario',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TEditConfigurationsForm.ListBoxPUConfigurationKeyUp(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
     // user has selected another configuration
     if (ListBoxPUConfiguration.ItemIndex > -1) then
     begin
          PUConfiguration.Text := ListBoxPUConfiguration.Items.Strings[ListBoxPUConfiguration.ItemIndex];
          sConfigField := ListBoxConfigFieldNames.Items.Strings[ListBoxPUConfiguration.ItemIndex];
          GIS_Child.UpdateMap(0, iNumberOfZones-1, sConfigField, False, True, MarxanInterfaceForm);
          GIS_Child.RedrawSelection;
          RedrawConfigMapLegend;
     end;
end;

procedure TEditConfigurationsForm.StorePuLockVector;
var
   f_pulock_FileExists, fFound, fSelected : boolean;
   sPuDatName, sPuLockFileName, sTempFileName, sLine : string;
   PuDatFile, PuLockFile, TempFile : TextFile;
   iCount, iPUID, iZone, iPUIDField, iPUIDIndex : integer;
   //PUID_pudat : Array_t;
begin
     (*
     // read planning unit array from pu.dat
     PUID_pudat := Array_t.Create;
     PUID_pudat.init(SizeOf(integer),SelectedPus.lMaxSize);
     sPuDatName := Return_MZ_Filename('pu',fFound);
     if fFound and fileexists(sPuDatName) then
     begin
          assignfile(PuDatFile,sPuDatName);
          reset(PuDatFile);
          readln(PuDatFile,sLine);
          iPUIDField := ReturnFieldIndex('id', sLine);
          for iCount := 1 to SelectedPus.lMaxSize do
          begin
               readln(PuDatFile,sLine);
               iPUID := StrToInt(GetDelimitedAsciiElement(sLine,',',iPUIDField));
               PUID_pudat.setValue(iCount,@iPUID);
          end;
     end;

     sPuLockFileName := Return_MZ_Filename('pulock',fFound);
     f_pulock_FileExists := fileexists(sPuLockFileName);

     sTempFileName := ExtractFilePath(EditMarxanDatabasePath.Text) +
                      ReturnMarxanParameter('INPUTDIR') + '\temp1.dat';
     assignfile(TempFile,sTempFileName);
     rewrite(TempFile);
     writeln(TempFile,'puid,zoneid');

     // Unlock selected planning units.
     if fFound and f_pulock_FileExists then
     begin
          assignfile(PuLockFile,sPuLockFileName);
          reset(PuLockFile);
          readln(PuLockFile,sLine);

          while not Eof(PuLockFile) do
          begin
               readln(PuLockFile,sLine);
               iPUID := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
               iZone := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
               // find index of this planning unit in the global list of planning units
               iPUIDIndex := BinaryLookup_Integer(PUID_pudat,iPUID,1,PUID_pudat.lMaxSize);
               SelectedPus.rtnValue(iPUIDIndex,@fSelected);
               if not fSelected then
                  writeln(TempFile,IntToStr(iPUID) + ',' + IntToStr(iZone));
          end;

          closefile(PuLockFile);
     end;

     // Lock selected planning units to the designated zone.
     // If zone is zero, we are not locking the selected planning units.
     if (iLockZone > 0) then
        for iCount := 1 to SelectedPus.lMaxSize do
        begin
             SelectedPus.rtnValue(iCount,@fSelected);
             if fSelected then
             begin
                  PUID_pudat.rtnValue(iCount,@iPUID);
                  writeln(TempFile,IntToStr(iPUID) + ',' + IntToStr(iLockZone));
             end;
        end;

     closefile(TempFile);
     PUID_pudat.Destroy;
     *)
end;


procedure TEditConfigurationsForm.btnSendToMarxanClick(Sender: TObject);
begin
     // store the current configuration as status in input.dat (Marxan)
     StoreStatusVector;

     Close;
     MarxanInterfaceForm.ButtonUpdateClick(Sender);
     //                              OR as zone in pulock.dat (MarZone)
     //StorePuLockVector;

end;

procedure TEditConfigurationsForm.FormActivate(Sender: TObject);
begin
     SCPForm.SwitchChildFocus;
end;

procedure TEditConfigurationsForm.PanelSaveClick(Sender: TObject);
begin
     // update the value of the selected planning units in the selected configuration
     SaveToScenario;
     GIS_Child.UpdateMap(0, iNumberOfZones-1, sConfigField, False, True, MarxanInterfaceForm);
     // init selection
     GIS_Child.InitShapeSelection;
     RedrawConfigMapLegend;
end;

procedure TEditConfigurationsForm.RedrawConfigMapLegend;
begin
     GIS_Child.CheckListBox1.ItemIndex := 0;
     GIS_Child.Timer1.Interval := 1;
     GIS_Child.Timer1.Enabled := True;
end;

procedure TEditConfigurationsForm.PanelUndoClick(Sender: TObject);
begin
     RestoreUndo;
     GIS_Child.UpdateMap(0, iNumberOfZones-1, sConfigField, False, True, MarxanInterfaceForm);
     // init selection
     GIS_Child.InitShapeSelection;
     RedrawConfigMapLegend;
end;

procedure TEditConfigurationsForm.Timer1Timer(Sender: TObject);
begin
     Timer1.Enabled := False;
     EditConfigurationsForm.Button5Click(Sender);
end;

end.
