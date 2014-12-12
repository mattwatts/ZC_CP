unit spatio;

{$UNDEF DBG_SIO}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBTables, Db,ds, DdeMan, ExtCtrls;

type
  TSpatIOModule = class(TDataModule)
    DBFTable: TTable;
    SQLQuery: TQuery;
    DdeServerItem1: TDdeServerItem;
    CPlanServer: TDdeServerConv;
    DdeClientItem1: TDdeClientItem;
    CPlanClient: TDdeClientConv;
    CheckTimer: TTimer;
    AreYouThereTimer: TTimer;
    // CreateEmptyTable creates a test file
    procedure CreateEmptyTable(const sPath, sTable : string);
    // WriteTable and ReadTable are test primitives which read and write only test data
    procedure WriteTable(const sPath, sTable : string;
                         FieldOne, FieldTwo : Array_t);
    procedure ReadTable(const sPath, sTable : string;
                        var FieldOne, FieldTwo : Array_t);
    // CreateContribTable creates a table that WriteContribTable can write to
    procedure CreateContribTable(const sPath, sTable : string;
                                const iVectorsToPass : integer);
    // WriteContribTable and ReadContribTable are for reading and writing data for a SPATTOOL config run
    procedure WriteContribTable(const sPath, sTable : string;
                                const iVariableToUse : integer);
    procedure ReadContribResult(var SpatialResult : Array_t);
    procedure DeleteTable(const sPath, sTable : string);
    // Functions to send SPATTOOL requests and receive results
    procedure SendConfigRequest;
    procedure SendContribRequest;
    procedure ReceiveConfigResult;
    procedure ReceiveContribResult;
    function ConnectToSPATTOOL : boolean;
    procedure CPlanServerExecuteMacro(Sender: TObject; Msg: TStrings);
    procedure UseContribResult;
    procedure CheckTimerTimer(Sender: TObject);
    procedure PrepareConfigInput(const sOutputPath : string);
    procedure UpdatePrepareSpreadTable(const sTable : string;
                                       const fWriteTextFile : boolean);
    procedure UpdateSiteStatus(const sTable : string);
    procedure ReadConfigTable(var ConfigResult : Array_t;
                              var rAllFeaturesValue : extended);
    procedure UseConfigResult(var ConfigResult : Array_t;
                              const sFilenameToReportTo : string;
                              const rAllFeaturesValue : extended);
    // procedures for Prepare Spread and Spread jobs
    procedure CreatePrepareSpreadTable;
    procedure WritePrepareSpreadTable(const sFilename : string);
    procedure ReadPrepareSpreadTable;
    procedure SendPrepareSpreadRequest;
    procedure ReceivePrepareSpreadResult;
    procedure CreateSpreadTable;
    procedure WriteSpreadTable(const sFilename : string);
    procedure ReadSpreadTable(var SpreadResult : Array_t);
    procedure SendSpreadRequest;
    procedure ReceiveSpreadResult;
    procedure UseSpreadResult(var SpreadResult : Array_t;
                              const sFilenameToReportTo : string);
    procedure SendSpatialParameters;
    procedure SpatIOModuleCreate(Sender: TObject);
    procedure SpatIOModuleDestroy(Sender: TObject);
    procedure AreYouThereTimerTimer(Sender: TObject);
    procedure SendExponentRequest;
    procedure SendRadiusRequest;
    procedure SendTerminateRequest;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

{write an array of integers to an ascii file}
procedure IntArr2File(const sPath, sFile : string;
                      IntArr : Array_t);
{read an array of integers from an ascii file}
procedure File2IntArr(const sPath, sFile : string;
                      var IntArr : Array_t);

function RunAnApp(const sApp, sCmdLine : string) : boolean;
procedure DisposeOldTempFiles(const sPath : string);


var
  SpatIOModule: TSpatIOModule;
  SpatResult : Array_t;
  iSpattoolRequest,
  iSpattoolProcess,
  iReceiveDataExtended, iLooper : integer;
  fReceiveDataExtended : boolean;
  sJob : string;
  //ReceiveDataExtended : Array_t;

procedure TestSpatIOModule;

function rtnUniqueFileName(const sPath, sExt : string) : string;

procedure CreateSyncFile(const sSyncName : string);

implementation

uses
    Global, IniFiles, Control, av1, em_newu1, toolmisc, sf_irrep,
    override_combsize, spat_progress, spatDLLmanager, displaygrid,
    auto_fit;

{$R *.DFM}

// ---------------------------------------------------------------------------
procedure DisposeOldTempFiles(const sPath : string);
var
   iCount : integer;

   procedure TryDelete(const sCmd : string);
   begin
          if fileexists(sPath + '\' + sCmd + IntToStr(iCount)) then
             deletefile(sPath + '\' + sCmd + IntToStr(iCount));
   end;
   procedure TryDeleteNoInt(const sCmd : string);
   begin
          if fileexists(sPath + '\' + sCmd) then
             deletefile(sPath + '\' + sCmd);
   end;
   procedure TryDeleteExt(const sCmd, sExt : string);
   begin
          if fileexists(sPath + '\' + sCmd + IntToStr(iCount) + '.' + sExt) then
             deletefile(sPath + '\' + sCmd + IntToStr(iCount) + '.' + sExt);
   end;
begin
     TryDeleteNoInt('cmdterminate');
     for iCount := 0 to 1000 do
     begin
          TryDelete('cmdcontrib');
          TryDelete('cmdconfig');
          TryDelete('cmdprepspread');
          TryDelete('cmdspread');
          TryDelete('cmdradius');
          TryDelete('radius');
          TryDelete('cmdexponent');
          TryDelete('exponent');
          TryDelete('cmdareyouthere');
          TryDelete('synccontrib');
          TryDelete('syncconfig');
          TryDelete('syncprepspread');
          TryDelete('syncspread');
          TryDelete('syncareyouthere');
          TryDeleteExt('contrib_in','txt');
          TryDeleteExt('contrib_out','txt');
          TryDeleteExt('cfg_fin','txt');
          TryDeleteExt('cfg_sin','txt');
          TryDeleteExt('config_fout','txt');
          TryDeleteExt('pspr_sin','txt');
          TryDeleteExt('pspr_fin','txt');
          TryDeleteExt('cfg_sin','txt');
          TryDeleteExt('spr_in','txt');
     end;
end;
// ---------------------------------------------------------------------------
procedure CreateDummyConfigFile(const sFilenameToReportTo : string);
var
   ReportFile : Text;
   iCount, iItem : integer;
   AFeat : featureoccurrence;
   rValueC, rReservedArea : extended;
begin
     assignfile(ReportFile,sFilenameToReportTo);
     rewrite(ReportFile);
     iItem := 0;
     writeln(ReportFile,'Feature,Feature Key,Area reserved,Patch size/connectivity index,(Area reserved) X (index)');
     writeln(ReportFile,'All Features Combined,,,' +
                        FloatToStr(0) + ','
                        );
     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,@AFeat);
          if (AFeat.rPATCHCON <> 0) then
          begin
               Inc(iItem);
               //rValue := 0;
               // reserved area is current proposed reserved areas (rDeferredArea) +
               //                  initial reserved areas (reservedarea)
               rReservedArea := AFeat.rDeferredArea + AFeat.reservedarea;
               writeln(ReportFile,AFeat.sID + ',' +
                                  IntToStr(AFeat.code) + ',' +
                                  FloatToStr(rReservedArea) + ',' +
                                  FloatToStr(rValueC) + ',' +
                                  FloatToStr(rValueC * rReservedArea)
                                  );
          end;
     end;


     closefile(ReportFile);

     ControlForm.ProcLabel.Visible := False;
     ControlForm.ProcLabel.Caption := '';
     ControlForm.ProcLabel.Update;
end;
// ---------------------------------------------------------------------------
procedure CreateDummySpreadFile(const sFilenameToReportTo : string);
var
   ReportFile : Text;
   iCount, iItem : integer;
   AFeat : featureoccurrence;
   rValueS : extended;
begin
     assignfile(ReportFile,sFilenameToReportTo);
     rewrite(ReportFile);
     iItem := 0;
     writeln(ReportFile,'Feature,Feature Key,Spread index');
     for iCount := 1 to iFeatureCount do
     begin
          FeatArr.rtnValue(iCount,@AFeat);
          if (AFeat.rPATCHCON <> 0) then
          begin
               Inc(iItem);
               //rValue := 0;
               writeln(ReportFile,AFeat.sID + ',' +
                                  IntToStr(AFeat.code) + ',' +
                                  FloatToStr(rValueS)
                                  );
          end;
     end;

     closefile(ReportFile);

     ControlForm.ProcLabel.Visible := False;
     ControlForm.ProcLabel.Caption := '';
     ControlForm.ProcLabel.Update;
end;
// ---------------------------------------------------------------------------
function rtnUniqueFileName(const sPath, sExt : string) : string;
var
   iCount : integer;
begin
     // return a unique pathX.ext filename
     iCount := 0;

     repeat
           Result := sPath + IntToStr(iCount) + '.' + sExt;

           Inc(iCount);

     until not FileExists(Result);
end;

// ---------------------------------------------------------------------------

function Status2Double(const aStatus : Status_T) : double;
begin // mirrors function ConvertFloatStatusToState in dlluser.c
     case aStatus of
          Av,Fl : Result := 0;//'A';               // Available sites
          Ex,Ig : Result := 1;//'U';               // Un-Available sites
     else
         Result := 2;//'R';                        // Reserved sites 
     end;
end;

function Status2IntChar(const aStatus : Status_T) : integer;
begin // mirrors function ConvertFloatStatusToState in dlluser.c
     case aStatus of
          Av,Fl : Result := 0;//'A';               // Available sites
          Ex,Ig : Result := 1;//'U';               // Un-Available sites
     else
         Result := 2;//'R';                        // Reserved sites
     end;
end;

function Status2Char(const aStatus : Status_T) : char;
begin
     case aStatus of
          Av,Fl : Result := 'A';               // Available sites
          Ex,Ig : Result := 'U';               // Un-Available sites
     else
         Result := 'R';                        // Reserved sites
     end;
end;
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------

procedure TestSpatIOModule;
var
   TestModule : TSpatIOModule;
   sDirectory, sTable : string;
   Field1,Field2,Field3,Field4 : Array_t;
begin
     {test procedure to test call the spatial i/o module, TSpatIOModule}
     try
        TestModule := TSpatIOModule.Create(Application);

        sDirectory := 'e:\data\test_siomod';
        sTable := 'abc';

        TestModule.CreateEmptyTable(sDirectory,sTable);

        {load data to Field1 and Field2 from ascii files}
        File2IntArr(sDirectory,'book1',Field1);
        File2IntArr(sDirectory,'book2',Field2);

        {write contents of Field1 and Field2 to a dbase table}
        TestModule.WriteTable(sDirectory,sTable,Field1,Field2);

        {read contents of Field3 and Field4 from the dbase table}
        TestModule.ReadTable(sDirectory,sTable,Field3,Field4);

        {write contents of Field3 and Field4 to ascii files}
        IntArr2File(sDirectory,'out1_',Field3);
        IntArr2File(sDirectory,'out2_',Field4);

        {delete the test table we have created}
        //TestModule.DeleteTable(sDirectory,sTable);

        TestModule.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TestSpatIOModule',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------

procedure IntArr2File(const sPath, sFile : string;
                      IntArr : Array_t);
var
   iCount, iValue : integer;
   OutFile : Text;
begin
     {write contents of an integer array to an ascii file}
     try
        assignfile(OutFile,sPath + '\' + sFile + '.txt');
        rewrite(OutFile);
        for iCount := 1 to IntArr.lMaxSize do
        begin
             IntArr.rtnValue(iCount,@iValue);
             writeln(OutFile,IntToStr(iValue));
        end;
        closefile(OutFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.IntArr2File',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure File2IntArr(const sPath, sFile : string;
                      var IntArr : Array_t);
var
   iValue, iArrSize : integer;
   InFile : Text;
   sLine : string;
begin
     {read contents of an integer array from an ascii file}
     try
        assignfile(InFile,sPath + '\' + sFile + '.txt');
        reset(InFile);
        iArrSize := 0;
        IntArr := Array_t.Create;
        IntArr.init(SizeOf(integer),ARR_STEP_SIZE);

        repeat
              readln(InFile,sLine);
              iValue := StrToInt(sLine);

              inc(iArrSize);
              if (iArrSize > IntArr.lMaxSize) then
                 IntArr.resize(IntArr.lMaxSize + ARR_STEP_SIZE);
              IntArr.setValue(iArrSize,@iValue);

        until EOLN(InFile);

        if (iArrSize <> IntArr.lMaxSize) then
           IntArr.resize(iArrSize);

        closefile(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.IntArr2File',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------

procedure TSpatIOModule.SendSpatialParameters;
var
   OutFile : TextFile;
   rValue : extended;
   iValue : integer;
begin
     if ControlRes^.fConnectSPATTOOL then
     try
        // send a command of spatial parameters to the spatial tool
        // write a space delimited parameters.txt file for the Spatial Tool
        assignfile(OutFile,ControlRes^.sWorkingDirectory + '\parameters.txt');
        rewrite(OutFile);
        writeln(OutFile,'sites ' + IntToStr(iSiteCount));
        writeln(OutFile,'configfeatures ' + IntToStr(ControlRes^.iFeaturesWithPATCHCON));
        writeln(OutFile,'contribfeatures 1');
        writeln(OutFile,'spreadfeatures ' + IntToStr(ControlRes^.iFeaturesWithSRADIUS));
        // make sure radius is greater than 0
        iValue := ControlRes^.iSpatialContribRadius;
        if (iValue < 1) then
           iValue := 1;
        writeln(OutFile,'radius ' + IntToStr(iValue));
        // make sure exponent is in range of 0 to 1
        rValue := ControlRes^.rSpatialContribExponent;
        if (rValue < 0) then
           rValue := 0;
        if (rValue > 1) then
           rValue := 1;
        writeln(OutFile,'exponent ' + FloatToStr(rValue));
        closefile(OutFile);
        // write a sync file to tell Spatial Tool to read in the new parameters
        assignfile(OutFile,ControlRes^.sWorkingDirectory + '\param');
        rewrite(OutFile);
        writeln(OutFile,'param');
        closefile(OutFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.SendSpatialParameters',mtError,[mbOk],0);
     end;
end;

procedure WriteSFContribTable(const sFilename : string);
var
   OutFile : TextFile;
begin
     assignfile(OutFile,sFilename);
     rewrite(OutFile);

     writeln(OutFile,'A 1');
     writeln(OutFile,'A 5');
     writeln(OutFile,'A 4');
     writeln(OutFile,'A 2');
     writeln(OutFile,'A 1');
     writeln(OutFile,'A 2');
     writeln(OutFile,'A 2');
     writeln(OutFile,'A 3');
     writeln(OutFile,'A 4');
     writeln(OutFile,'A 5');
     writeln(OutFile,'A 3');
     writeln(OutFile,'A 5');
     writeln(OutFile,'');

     closefile(OutFile);
end;

procedure TSpatIOModule.SendContribRequest;
var
   RequestFile : TextFile;
begin
     {send a request and input data to the spatial tool
      instructing it to perform contrib operation}
     try

        SpatialProgressForm := TSpatialProgressForm.Create(Application);
        SpatialProgressForm.Show;
        sJob := '1';
        //DDESendCmd(SpatIOModule.CPlanClient,'contrib');
        Inc(iSpattoolRequest);
        // create contrib input file
        WriteContribTable(ControlRes^.sSpatialDistanceFile,'contrib_in' + IntToStr(iSpattoolRequest) + '.txt',
                          ControlRes^.iSpatialVariableToPass);
        //WriteSFContribTable(ControlRes^.sSpatialDistanceFile + '\contrib_in' + IntToStr(iSpattoolRequest) + '.txt');
        // send request to spattool
        assignfile(RequestFile,ControlRes^.sSpatialDistanceFile + '\cmdcontrib' + IntToStr(iSpattoolRequest));
        rewrite(RequestFile);
        writeln(RequestFile,'contrib');
        closefile(RequestFile);
        Screen.Cursor := crHourglass;

        {now start the timer which periodically checks to see if the result is ready yet}
        CheckTimer.Enabled := TRUE;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.SendContribRequest',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSpatIOModule.SendExponentRequest;
var
   RequestFile : TextFile;
begin
     {send a request to the spatial tool instructing it to change the radius}
     try
        sJob := '1';
        Inc(iSpattoolRequest);
        // send exponent to spattool
        assignfile(RequestFile,ControlRes^.sSpatialDistanceFile + '\exponent' + IntToStr(iSpattoolRequest));
        rewrite(RequestFile);
        writeln(RequestFile,FloatToStr(ControlRes^.rSpatialContribExponent));
        closefile(RequestFile);
        // send request to spattool
        assignfile(RequestFile,ControlRes^.sSpatialDistanceFile + '\cmdexponent' + IntToStr(iSpattoolRequest));
        rewrite(RequestFile);
        writeln(RequestFile,'exponent');
        closefile(RequestFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.SendExponentRequest',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSpatIOModule.SendRadiusRequest;
var
   RequestFile : TextFile;
begin
     {send a request and input data to the spatial tool
      instructing it to perform contrib operation}
     try
        sJob := '1';
        Inc(iSpattoolRequest);
        // send radius to spattool
        assignfile(RequestFile,ControlRes^.sSpatialDistanceFile + '\radius' + IntToStr(iSpattoolRequest));
        rewrite(RequestFile);
        writeln(RequestFile,IntToStr(ControlRes^.iSpatialContribRadius));
        closefile(RequestFile);
        // send request to spattool
        assignfile(RequestFile,ControlRes^.sSpatialDistanceFile + '\cmdradius' + IntToStr(iSpattoolRequest));
        rewrite(RequestFile);
        writeln(RequestFile,'radius');
        closefile(RequestFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.SendRadiusRequest',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSpatIOModule.SendTerminateRequest;
var
   RequestFile : TextFile;
begin
     {send a request and input data to the spatial tool
      instructing it to perform contrib operation}
     try
        sJob := '1';
        Inc(iSpattoolRequest);
        // send request to spattool
        assignfile(RequestFile,ControlRes^.sSpatialDistanceFile + '\cmdterminate' {+ IntToStr(iSpattoolRequest)});
        rewrite(RequestFile);
        writeln(RequestFile,'terminate');
        closefile(RequestFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.SendTerminateRequest',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure CreateSyncFile(const sSyncName : string);
var
   OutFile : TextFile;
begin
     assignfile(OutFile,ControlRes^.sDatabase + '\' + sSyncName);
     rewrite(OutFile);
     closefile(OutFile);
end;

procedure TSpatIOModule.SendConfigRequest;                                
var
   RequestFile : TextFile;
begin
     {assemble an input dataset and send a CONFIG request to the SPATTOOL}
     try

        SpatialProgressForm := TSpatialProgressForm.Create(Application);
        SpatialProgressForm.Show;
        sJob := '1';
        //DDESendCmd(SpatIOModule.CPlanClient,'contrib');
        Inc(iSpattoolRequest);
        // create contrib input file
        PrepareConfigInput(ControlRes^.sSpatialDistanceFile);
        // send request to spattool
        assignfile(RequestFile,ControlRes^.sSpatialDistanceFile + '\cmdconfig' + IntToStr(iSpattoolRequest));
        rewrite(RequestFile);
        writeln(RequestFile,'config');
        closefile(RequestFile);
        Screen.Cursor := crHourglass;

        {now start the timer which periodically checks to see if the result is ready yet}
        CheckTimer.Enabled := TRUE;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.SendConfigRequest',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSpatIOModule.UseContribResult;
begin
     try
        ControlForm.ProcLabel.Visible := False;
        ControlForm.ProcLabel.Caption := '';
        ControlForm.ProcLabel.Update;
        {$IFNDEF SPARSE_MATRIX_2}
        MapPCUSED2Array;
        {$ENDIF}
        if ControlRes^.fFeatureClassesApplied then
           MapMemoryVariable2Display(ControlRes^.iGISPlotField,
                                     ControlForm.SubsetGroup.ItemIndex,
                                     ControlRes^.iDisplayValuesFor, {option for display Available/Deferred}
                                     5, {divide middle values into 5 categories}
                                     SiteArr, iSiteCount,
                                     iIr1Count, i001Count, i002Count,
                                     i003Count, i004Count, i005Count,
                                     i0CoCount)
        else
            MapMemoryVariable2Display(ControlRes^.iGISPlotField,
                                      0,
                                      ControlRes^.iDisplayValuesFor, {option for display Available/Deferred}
                                      5, {divide middle values into 5 categories}
                                      SiteArr, iSiteCount,
                                      iIr1Count, i001Count, i002Count,
                                      i003Count, i004Count, i005Count,
                                      i0CoCount);

        ControlForm.UpdateDatabase(True);
        ControlForm.InformGIS;          

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.UseContribResult',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function ConcatData : string;
var
   iCount : integer;
   rValue : extended;
begin
     Result := '';
     (*for iCount := 1 to 10 do
     begin
          ReceiveDataExtended.rtnValue(iCount,@rValue);
          Result := Result + FloatToStr(rValue);
          if (iCount <> 10) then
             Result := Result + ', ';
     end;*)
end;

procedure TSpatIOModule.ReceiveContribResult;
begin
     {receive Contrib result/data from the SPATTOOL}
     try
        Screen.Cursor := crHourglass;

        // display the debug information in a message box
        //MessageDlg('values ' + ConcatData,mtInformation,[mbOk],0);

        if ControlRes^.fSpatResultCreated then
           SpatResult.Destroy;

        ControlRes^.fSpatResultCreated := TRUE;

        // read the contrib result from gmtest0.exe
        ReadContribResult(SpatResult);

        {now use the data we have just retrieved from the table}
        UseContribResult;

        try
           SpatialProgressForm.Free;
        except
        end;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.ReceiveContribResult',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSpatIOModule.ReceiveConfigResult;
var
   ConfigResult : Array_t;
   rAllFeaturesValue : extended;
   sConfigReportFile : string;
begin
     {read and use the CONFIG result that has been created by the SPATTOOL}
     try
        CheckTimer.Enabled := False;
        // read the CONFIG result
        ReadConfigTable(ConfigResult,
                        rAllFeaturesValue);

        // generate a filename to report the config result to
        sConfigReportFile := rtnUniqueFileName(ControlRes^.sWorkingDirectory + '\config_result',
                                               'csv');

        // create a dummy file to open
        //CreateDummyConfigFile(sConfigReportFile);
        // use the CONFIG result
        UseConfigResult(ConfigResult,
                        sConfigReportFile,
                        rAllFeaturesValue
                        );

        // launch the Table Editor with this file loaded into a grid
        //RunAnApp('table_ed',
        //         '"' + sConfigReportFile + '"');
        DisplayGridForm := TDisplayGridForm.Create(Application);
        DisplayGridForm.InitWithFile(sConfigReportFile);
        AutoFitGrid(DisplayGridForm.StringGrid1,DisplayGridForm.Canvas,True);
        DisplayGridForm.ShowModal;
        DisplayGridForm.Free;
        // destroy cfg_fout.dbf and cfg_sync.dbf
        //DeleteTable(ControlRes^.sDatabase,'cfg_fout');
        //DeleteTable(ControlRes^.sDatabase,'cfg_sync');
        CheckTimer.Enabled := False;
        try
        SpatialProgressForm.Free;
        except
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.ReceiveConfigResult',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


// ---------------------------------------------------------------------------

function RunAnAppAnyPath(const sApp : string) : boolean;
var
   sRunFile, sPath, sExeFile : string;
   PCmd : PChar;
begin
     sExeFile := sApp;
     sRunFile := sExeFile;

     if FileExists(sExeFile) then
     begin
          GetMem(PCmd,Length(sRunFile)+1);
          StrPCopy(PCmd,sRunFile);

          WinEXEC(PCmd,SW_SHOW);

          FreeMem(PCmd,Length(sRunFile)+1);

          Result := True;
     end
     else
         Result := False;
end;

function RunAnApp(const sApp, sCmdLine : string) : boolean;
var
   sRunFile, sPath, sExeFile : string;
   PCmd : PChar;
   AIniFile : TIniFile;
begin
     AIniFile := TIniFile.Create(DB_INI_FILENAME);

     sPath := AIniFile.ReadString('Paths','32bit','');
     sExeFile := sPath + '\' + sApp + '.exe';
     sRunFile := sExeFile + ' ' + sCmdLine;

     AIniFile.Free;

     if FileExists(sExeFile) then
     begin
          GetMem(PCmd,Length(sRunFile)+1);
          StrPCopy(PCmd,sRunFile);

          WinEXEC(PCmd,SW_SHOW);

          FreeMem(PCmd,Length(sRunFile)+1);

          Result := True;
     end
     else
         Result := False;
end;


function TSpatIOModule.ConnectToSPATTOOL : boolean;
var
   sCmdLine : string;
   rValue : extended;
   iCount : integer;
begin
     {attempt to connect to the SPATTOOL}
     try
        Result := False;

        {launch the SPATTOOL application}
        // We pass no parameter when starting the program
        sCmdLine := '';
        //if RunAnApp('spattool',sCmdLine) then
        //begin
             // get cplan CPlanClient to start a dde conversation with spattool SpatServer
             //CPlanClient.SetLink('spattool','SpatServer');
             //CPlanClient.OpenLink;

             // send the init command
             //DDESendCmd(SpatIOModule.CPlanClient,'init ' + ControlRes^.sSpatialDistanceFile);

             //RunAnApp('execit',ControlRes^.sSpatialDistanceFile);

             Result := True;

             (*ReceiveDataExtended := Array_t.Create;
             ReceiveDataExtended.init(SizeOf(extended),10);
             for iCount := 1 to 10 do
             begin
                  rValue := iCount + 10;
                  ReceiveDataExtended.setValue(iCount,@rValue);
             end;*)
        //end;

        RunAnAppAnyPath('C:\Program Files\CPlan32\gmtest0.exe');

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.ConnectToSPATTOOL',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------

procedure TSpatIOModule.WriteTable(const sPath, sTable : string;
                                   FieldOne, FieldTwo : Array_t);
var
   iCount, iValue : integer;
begin
     {write the contents of FieldOne and FieldTwo to a table
      that has already been created}
     try
        DBFTable.DatabaseName := sPath;
        DBFTable.TableName := sTable + '.dbf';
        DBFTable.Open;

        {write data to the table}
        for iCount := 1 to FieldOne.lMaxSize do
        begin
             DBFTable.Append;
             FieldOne.rtnValue(iCount,@iValue);
             DBFTable.FieldByName('FLDONE').AsInteger := iValue;
             FieldTwo.rtnValue(iCount,@iValue);
             DBFTable.FieldByName('FLDTWO').AsInteger := iValue;
        end;

        DBFTable.Post;
        DBFTable.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.WriteTable',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSpatIOModule.ReadTable(const sPath, sTable : string;
                                  var FieldOne, FieldTwo : Array_t);
var
   iCount, iValue : integer;
begin
     {Create the arrays FieldOne and FieldTwo and
      read the contents of a table that has already been populated}
     try
        DBFTable.DatabaseName := sPath;
        DBFTable.TableName := sTable + '.dbf';
        DBFTable.Open;

        {create the arrays to store the result}
        FieldOne := Array_t.Create;
        FieldOne.init(SizeOf(integer),DBFTable.RecordCount);
        FieldTwo := Array_t.Create;
        FieldTwo.init(SizeOf(integer),DBFTable.RecordCount);

        {read data from the table to the arrays}
        for iCount := 1 to DBFTable.RecordCount do
        begin
             iValue := DBFTable.FieldByName('FLDONE').AsInteger;
             FieldOne.setValue(iCount,@iValue);
             iValue := DBFTable.FieldByName('FLDTWO').AsInteger;
             FieldTwo.setValue(iCount,@iValue);

             DBFTable.Next; {advance table to next record in the dataset}
        end;

        DBFTable.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.ReadTable',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------

procedure TSpatIOModule.WriteContribTable(const sPath, sTable : string;
                                          const iVariableToUse : integer);
var
   iNumber,
   iCount, iVectorCount, iVectorWritingTo : integer;
   aSite : site;
   aWS : WeightedSumirr_T;
   VectorX, VectorXsqr : Array_t;
   VectorSTDDEV, VectorMEAN : Array_t;
   rSTDDEV, rMEAN,
   rX, rXsqr,
   rAllX, rAllXsqr,
   rAllSTDDEV, rAllMEAN,
   rVectorMaximumValue, rCurrentVectorValue,
   rTmp : extended;
   sAPISiteStatus : string;
   OutFile : TextFile;

   {variables to use for subsets:
     0 rSubsetIrr
     1 rSubsetWav
     2 rSubsetSum
     3 r_sub_a
     4 r_sub_t
     5 r_sub_v
     6 r_sub_at
     7 r_sub_av
     8 r_sub_tv
     9 r_sub_atv

    variables to use for non-subsets:
     0 subsmaxrf
     1 rWAVIRR
     2 rSummedIrr
     3 r_a
     4 r_t
     5 r_v
     6 r_at
     7 r_av
     8 r_tv
     9 r_atv
   }

   function rtnValueForRow : extended;
   var
      iCount : integer;
   begin
        case iVariableToUse of
             0 : Result := aSite.rIrreplaceability;
             1 : Result := aSite.rWAVIRR;
             2 : Result := aSite.rSummedIrr;
             3 : Result := aWS.r_a;
             4 : Result := aWS.r_t;
             5 : Result := aWS.r_v;
             6 : Result := aWS.r_at;
             7 : Result := aWS.r_av;
             8 : Result := aWS.r_tv;
             9 : Result := aWS.r_atv;
        end;
        if (iVariableToUse > 0) then
        begin
             Result := -1;
             // we are using one of the subset sumirr inputs
             for iCount := 1 to 10 do
                 if (ControlRes^.sSpatialVariableToPass = 'sumirr ' + IntToStr(iCount)) then
                    Result := aSite.rSubsetSum[iCount];
        end;
   end;

   function rtnSubsetValueForRow : extended;
   begin
        case iVariableToUse of
             0 : Result := aSite.rSubsetIrr[iVectorCount];
             1 : Result := aSite.rSubsetWav[iVectorCount];
             2 : Result := aSite.rSubsetSum[iVectorCount];
             3 : Result := aWS.r_sub_a[iVectorCount];
             4 : Result := aWS.r_sub_t[iVectorCount];
             5 : Result := aWS.r_sub_v[iVectorCount];
             6 : Result := aWS.r_sub_at[iVectorCount];
             7 : Result := aWS.r_sub_av[iVectorCount];
             8 : Result := aWS.r_sub_tv[iVectorCount];
             9 : Result := aWS.r_sub_atv[iVectorCount];
        end;
   end;

begin
     {write the contents of FieldOne and FieldTwo to a table
      that has already been created}
     try
        assignfile(OutFile,sPath + '\' + sTable);
        rewrite(OutFile);

        {we must parse through the sites and determine maximum value for each vector}
        VectorX := Array_t.Create;
        VectorXsqr := Array_t.Create;
        VectorSTDDEV := Array_t.Create;
        VectorMEAN := Array_t.Create;
        VectorX.init(SizeOf(extended),ControlRes^.iSpatialVectorsToPass);
        VectorXsqr.init(SizeOf(extended),ControlRes^.iSpatialVectorsToPass);
        VectorSTDDEV.init(SizeOf(extended),ControlRes^.iSpatialVectorsToPass);
        VectorMEAN.init(SizeOf(extended),ControlRes^.iSpatialVectorsToPass);
        rVectorMaximumValue := 0;
        rAllX := 0;
        rAllXsqr := 0;
        for iCount := 1 to ControlRes^.iSpatialVectorsToPass do
        begin
             VectorX.setValue(iCount,@rVectorMaximumValue);
             VectorXsqr.setValue(iCount,@rVectorMaximumValue);
        end;
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,@aSite);
             if (aSite.status = Av) then
             begin
                  iVectorWritingTo := 0;
                  if (iVariableToUse > 2) then
                     WeightedSumirr.rtnValue(iCount,@aWS);

                  // accumulate non-subset value
                  rCurrentVectorValue := rtnValueForRow;
                  rAllX := rAllX + rCurrentVectorValue;
                  rAllXsqr := rAllXsqr + (rCurrentVectorValue*rCurrentVectorValue);

                  // accumulate subset value
                  for iVectorCount := 1 to 10 do
                      if (ControlRes^.fDoConfigOnSubset[iVectorCount]) then
                      begin
                           Inc(iVectorWritingTo);
                           rCurrentVectorValue := rtnSubsetValueForRow;
                           VectorX.rtnValue(iVectorWritingTo,@rX);
                           VectorXsqr.rtnValue(iVectorWritingTo,@rXsqr);

                           rX := rX + rCurrentVectorValue;
                           rXsqr := rXsqr + (rCurrentVectorValue*rCurrentVectorValue);

                           VectorX.setValue(iVectorWritingTo,@rX);
                           VectorXsqr.setValue(iVectorWritingTo,@rXsqr);
                      end;
             end;
        end;

        // now calculate MEAN and STDDEV for each subset we are passing into the spatial
        iNumber := ControlForm.Available.Items.Count + ControlForm.Flagged.Items.Count;
        if (iNumber = 0) then
           iNumber := 2;  // assign minimum number of sites so as not to trigger divide by zero
        rTmp := ((iNumber*rAllXsqr)-(rAllX*rAllX))
                           /
                           (iNumber*(iNumber-1));
        rAllSTDDEV := sqrt(rTmp);
        rAllMEAN := rAllX / iNumber;
        for iCount := 1 to ControlRes^.iSpatialVectorsToPass do
        begin
             VectorX.rtnValue(iCount,@rX);
             VectorXsqr.rtnValue(iCount,@rXsqr);
             rMEAN := rX / iNumber;
             rSTDDEV := sqrt(((iNumber*rXsqr)-(rX*rX))
                             /
                             (iNumber*(iNumber-1)));
             VectorMEAN.setValue(iCount,@rMEAN);
             VectorSTDDEV.setValue(iCount,@rSTDDEV);
        end;

        {write data to the table}
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,@aSite);

             sAPISiteStatus := Status2Char(aSite.status);
             write(OutFile,sAPISiteStatus + ' ');
             iVectorWritingTo := 0;

             // return data for this site so we can write it to the table
             if (iVariableToUse > 2) then
                WeightedSumirr.rtnValue(iCount,@aWS);

             if (sAPISiteStatus = 'R') then
             begin
                  // write the weighted value for this vector with the weighting
                  for iVectorCount := 1 to 10 do
                      if (ControlRes^.fDoConfigOnSubset[iVectorCount]) then
                      begin
                           Inc(iVectorWritingTo);
                           VectorMEAN.rtnValue(iVectorWritingTo,@rMEAN);
                           VectorSTDDEV.rtnValue(iVectorWritingTo,@rSTDDEV);
                           write(OutFile,FloatToStr(rMEAN + (rSTDDEV * ControlRes^.rSpatContribReservedWeight)) + ' ');
                      end;

                  // write the non-subset weighted value for this vector
                  writeln(OutFile,FloatToStr(rAllMEAN + (rAllSTDDEV * ControlRes^.rSpatContribReservedWeight)));
             end
             else
             begin
                  // write the actual row value
                  for iVectorCount := 1 to 10 do
                      if (ControlRes^.fDoConfigOnSubset[iVectorCount]) then
                      begin
                           Inc(iVectorWritingTo);
                           write(OutFile,FloatToStr(rtnSubsetValueForRow) + ' ');
                      end;

                  // write the non-subset weighted value for this vector
                  writeln(OutFile,FloatToStr(rtnValueForRow));
             end;
        end;

        closefile(OutFile);

        VectorX.Destroy;
        VectorXsqr.Destroy;
        VectorMEAN.Destroy;
        VectorSTDDEV.Destroy;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.WriteContribTable',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSpatIOModule.ReadContribResult(var SpatialResult : Array_t);
var
   iRCount, iRowCount, iCCount, iColumnCount : integer;
   rValue : single;
   sLine, sValue : string;
   InFile : TextFile;
begin
     try
        iRowCount := iSiteCount;
        iColumnCount := 1;
        SpatialResult := Array_t.Create;
        SpatialResult.init(SizeOf(single),(iRowCount));

        assignfile(InFile,ControlRes^.sSpatialDistanceFile + '\contrib_out' + IntToStr(iSpattoolRequest) + '.txt');
        reset(InFile);

        {read data from the table to the arrays}
        for iRCount := 1 to iRowCount do
        begin
             readln(InFile,sLine);

             // only store the 1st contrib vector  NEED TO STORE THE OTHERS
             //for iCCount := 0 to (iColumnCount-1) do
             begin
                  // 1-based column 3 contains the 1st contrib value
                  //
                  sValue := GetDelimitedAsciiElement(sLine,' ',3);
                  try
                     rValue := StrToFloat(sValue);
                     if (rValue < 0) then
                        rValue := -1 * rValue;
                  except
                        rValue := 0;
                  end;
                  // read the parameter directly from the gmtest0.exe
                  //retrieveparam(iCCount+1);
                  SpatialResult.setValue({(iCCount*iColumnCount)+}iRCount,@rValue);
             end;
        end;

        closefile(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.ReadContribResult',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------

procedure TSpatIOModule.CreateEmptyTable(const sPath, sTable : string);
begin
     {create an empty dBase file using an SQL Query}
     try
        with SQLQuery.Sql do
        begin
             Clear;
             Add('CREATE TABLE "' + sPath + '\' + sTable + '.dbf"');
             Add('(');
             Add('FLDONE NUMERIC(5,0),'); {maximum of 2 digits}
             Add('FLDTWO NUMERIC(5,0)');  {maximum of 2 digits}
             Add(')');
        end;

        try
           SQLQuery.Prepare;
           SQLQuery.ExecSQL;
        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception executing SQL Query',mtError,[mbOk],0);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.CreateEmptyTable',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------

procedure TSpatIOModule.CreateContribTable(const sPath, sTable : string;
                                          const iVectorsToPass : integer);
var
   iCount : integer;
   sLine : string;
begin
     {create an empty dBase file using an SQL Query}
     try
        // remove the file we are creating if it already exists
        if FileExists(sPath + '\' + sTable + '.dbf') then
           DeleteFile(sPath + '\' + sTable + '.dbf');

        with SQLQuery.Sql do
        begin
             Clear;

             sLine := 'CREATE TABLE "' + sPath + '\' + sTable + '.dbf"';
             Add(sLine);
             sLine := '(';
             Add(sLine);
             sLine := 'S CHAR(1),';
             Add(sLine);
             for iCount := 1 to iVectorsToPass do
             begin
                  sLine := 'V' + IntToStr(iCount) + ' NUMERIC(10,5),';
                  Add(sLine);
             end;
             Add('V' + IntToStr(iVectorsToPass+1) + ' NUMERIC(10,5)');
             sLine := ')';
             Add(sLine);
        end;
        {$IFDEF DBG_SIO}
        SQLQuery.SQL.SaveToFile(ControlRes^.sDatabase + '\cctdbg.sql');
        {$ENDIF}

        try
           SQLQuery.Prepare;
           SQLQuery.ExecSQL;
        except
              SQLQuery.SQL.SaveToFile(ControlRes^.sDatabase + '\cctdbg.sql');
              Screen.Cursor := crDefault;
              MessageDlg('Exception executing SQL Query',mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.CreateContribTable',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------

procedure TSpatIOModule.DeleteTable(const sPath, sTable : string);
var
   sFile : string;
begin
     {delete a table if it exists}
     try
        sFile := sPath + '\' + sTable + '.dbf';
        if FileExists(sFile) then
           DeleteFile(sFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.DeleteTable',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSpatIOModule.CPlanServerExecuteMacro(Sender: TObject;
  Msg: TStrings);
var
   sMsg : string;
   rValue : extended;
   iCount : integer;
begin
     try  (*
        // We have received a DDE command from the SPATTOOL
        sMsg := Msg[0];
        //ControlForm.lblA.Caption := sMsg;
        //ControlForm.Update;
        Inc(iLooper);
        if (iLooper > 4) then
           iLooper := 1;
        if (iLooper = 2) then
        begin
             if (sMsg = 'bringtofront') then
             begin
                  ControlForm.BringToFront;
             end
             else
             begin
                  //if (sMsg = 'contrib done') then
                  if (sJob = '1') then
                  begin
                       //fReceiveDataExtended := True;
                       ReceiveContribResult;
                  end;
                  //if (sMsg = 'config done') then
                  if (sJob = '2') then
                  begin
                       ReceiveConfigResult;
                  end;
                  //if (sMsg = 'preparespread done') then
                  if (sJob = '3') then
                  begin
                       ReceivePrepareSpreadResult;
                  end;
                  //if (sMsg = 'spread done') then
                  if (sJob = '4') then
                  begin
                       ReceiveSpreadResult;
                  end;
             end;
        end;
              *)
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.CPlanSpatServerExecuteMacro',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSpatIOModule.CheckTimerTimer(Sender: TObject);
var
   sSyncFile : string;
begin
     try
        sSyncFile := ControlRes^.sSpatialDistanceFile + '\synccontrib' + IntToStr(iSpattoolRequest);
        if fileexists(sSyncFile) then
        begin
             CheckTimer.Enabled := False;
             ReceiveContribResult;

             CheckTimer.Enabled := False;
             iSpattoolProcess := 0;
             Screen.Cursor := crDefault;
        end;
        sSyncFile := ControlRes^.sSpatialDistanceFile + '\syncconfig' + IntToStr(iSpattoolRequest);
        if fileexists(sSyncFile) then
        begin
             CheckTimer.Enabled := False;
             ReceiveConfigResult;

             CheckTimer.Enabled := False;
             iSpattoolProcess := 0;
             Screen.Cursor := crDefault;
        end;
        sSyncFile := ControlRes^.sSpatialDistanceFile + '\syncprepspread' + IntToStr(iSpattoolRequest);
        if fileexists(sSyncFile) then
        begin
             CheckTimer.Enabled := False;
             ReceivePrepareSpreadResult;

             CheckTimer.Enabled := False;
             iSpattoolProcess := 0;
             Screen.Cursor := crDefault;
        end;
        sSyncFile := ControlRes^.sSpatialDistanceFile + '\syncspread' + IntToStr(iSpattoolRequest);
        if fileexists(sSyncFile) then
        begin
             CheckTimer.Enabled := False;
             ReceiveSpreadResult;

             CheckTimer.Enabled := False;
             iSpattoolProcess := 0;
             Screen.Cursor := crDefault;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.CheckTimerTimer',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------

function rtnSiteFeatureValue(const ASite : site;
                             const AFeat : featureoccurrence) : extended;
var
   iCount : integer;
   fFound : boolean;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
begin
     // if the feature with key AFeat.code occurs at site ASite, return the featurearea of that
     // occurrence, else return 0
     fFound := False;
     iCount := 1;
     Result := 0;
     if (ASite.richness > 0) then
        repeat
              {$IFDEF SPARSE_MATRIX}
              FeatureAmount.rtnValue(ASite.iOffset + iCount,@Value);
              if (Value.iFeatKey = AFeat.code) then
              begin
                   Result := Value.rAmount;
                   fFound := True;
              end;
              {$ELSE}
              if (ASite.feature[iCount] = AFeat.code) then
              begin
                   Result := ASite.featurearea[iCount];
                   fFound := True;
              end;
              {$ENDIF}

              Inc(iCount);

        until (iCount > ASite.richness)
        or fFound;
end;

// ---------------------------------------------------------------------------

procedure TSpatIOModule.PrepareConfigInput(const sOutputPath : string);
var
   iCount, iVectorCount, iVectorToWrite : integer;
   ASite : site;
   AFeat : featureoccurrence;
   OutFile : TextFile;
begin
     // create CONFIG input files cfg_sin.dbf and cfg_fin.dbf and populate them with data
     try
        // delete files if they already exist
        assignfile(OutFile,sOutputPath + '\cfg_sin' + IntToStr(iSpattoolRequest) + '.txt');
        rewrite(OutFile);
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,@ASite);
             write(OutFile,IntToStr(Status2IntChar(ASite.status)) + ' ');
             iVectorToWrite := 0;
             // write each vector value for this site
             (*for iVectorCount := 1 to iFeatureCount do
             begin
                  FeatArr.rtnValue(iVectorCount,@AFeat);
                  if (AFeat.rPATCHCON <> 0) then
                     // we are using this feature for contrib
                     begin
                          Inc(iVectorToWrite);
                          write(OutFile,FloatToStr(rtnSiteFeatureValue(ASite,AFeat)) + ' ');
                     end;
             end;*)
             writeln(OutFile,FloatToStr(ASite.area));
        end;
        closefile(OutFile);

        assignfile(OutFile,sOutputPath + '\cfg_fin' + IntToStr(iSpattoolRequest) + '.txt');
        rewrite(OutFile);
        (*for iCount := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iCount,@AFeat);
             if (AFeat.rPATCHCON <> 0) then
             begin
                  writeln(OutFile,FloatToStr(AFeat.rPATCHCON));
             end;
        end;*)
        writeln(OutFile,FloatToStr(ControlRes^.rSpatialConfigAreaWeighting));
        closefile(OutFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.PrepareConfigInput',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------

procedure TSpatIOModule.UpdatePrepareSpreadTable(const sTable : string;
                                                 const fWriteTextFile : boolean);
var
   iCount, iVectorCount, iVectorToWrite : integer;
   ASite : site;
   AFeat : featureoccurrence;
   BinaryTable : File of double;
   TextTable : TextFile;
   dValue : double;
begin
     try
        // rewrite table
        if fWriteTextFile then
        begin
             assignfile(TextTable,ControlRes^.sDatabase + '\' + sTable);
             rewrite(TextTable);
        end
        else
        begin
             assignfile(BinaryTable,ControlRes^.sDatabase + '\' + sTable);
             rewrite(BinaryTable);
        end;
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,@ASite);
             dValue := Status2Double(ASite.status);
             if fWriteTextFile then
             begin
                  write(TextTable,Status2Char(ASite.status){FloatToStr(dValue)} + ' ');
             end
             else
             begin
                  write(BinaryTable,dValue);
             end;
             iVectorToWrite := 0;
             for iVectorCount := 1 to iFeatureCount do
             begin
                  FeatArr.rtnValue(iVectorCount,@AFeat);
                  if (AFeat.rSRADIUS <> 0) then
                     begin
                          Inc(iVectorToWrite);
                          dValue := rtnSiteFeatureValue(ASite,AFeat);
                          if fWriteTextFile then
                          begin
                               write(TextTable,FloatToStr(dValue) + ' ');
                          end
                          else
                          begin
                               write(BinaryTable,dValue);
                          end;
                     end;
             end;
             if fWriteTextFile then
                writeln(TextTable);
        end;
        if fWriteTextFile then
        begin
             closefile(TextTable);
        end
        else
        begin
             closefile(BinaryTable);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.UpdatePrepareSpreadTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------

procedure TSpatIOModule.ReadConfigTable(var ConfigResult : Array_t;
                                        var rAllFeaturesValue : extended);
var
   iItems : integer;
   eValue : extended;
   rValue : single;
   InFile : TextFile;
   sLine : string;

   procedure ProcessRow;
   var
      iCount : integer;
   begin
        Inc(iItems);
        //eValue := DBFTable.FieldByName('F').AsFloat;
        // square the result before storing it because eValue is the square root of the Row result
        //rValue := eValue * eValue;
        // don't square the result
        //rValue := DBFTable.FieldByName('F').AsFloat;
        try
           eValue := StrToFloat(sLine);
        except
              eValue := 0;
              rValue := 0;
        end;
        try
           rValue := eValue;
        except
              rValue := 0;
        end;
        if (iItems <= ConfigResult.lMaxSize) then
        begin
             if (iItems > ConfigResult.lMaxSize) then
                ConfigResult.resize(iItems);
             ConfigResult.setValue(iItems,@rValue);
        end;
        //if (iItems = ConfigResult.lMaxSize) then
           rAllFeaturesValue := rValue;
   end;

begin
     // read the config result from the config result table
     try
        assignfile(InFile,ControlRes^.sSpatialDistanceFile + '\config_fout' + IntToStr(iSpattoolRequest) + '.txt');
        reset(InFile);
        ConfigResult := Array_t.Create;
        ConfigResult.init(SizeOf(single),iFeatureCount);
        iItems := 0;
        {process the first row}
        readln(InFile,sLine);
        ProcessRow;
        closefile(InFile);

        if (iItems > 0) then
           if (iItems <> ConfigResult.lMaxSize) then
              ConfigResult.resize(iItems);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.ReadConfigTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------


procedure TSpatIOModule.UseConfigResult(var ConfigResult : Array_t;
                                        const sFilenameToReportTo : string;
                                        const rAllFeaturesValue : extended);
var
   ReportFile : Text;
   iItem, iCount, iVectorsToProcess : integer;
   AFeat : featureoccurrence;
   rValue, rReservedArea : single;
begin
     //
     try
        assignfile(ReportFile,sFilenameToReportTo);
        rewrite(ReportFile);
        iItem := 0;
        writeln(ReportFile,'Feature,Feature Key,Area reserved,Patch size/connectivity index,(Area reserved) X (index)');
        writeln(ReportFile,'All Features Combined,,,' +
                           FloatToStr(rAllFeaturesValue) + ','
                           );
        (*for iCount := 1 to ConfigResult.lMaxSize do
        begin
             FeatArr.rtnValue(iCount,@AFeat);
             if (AFeat.rPATCHCON <> 0) then
             begin
                  Inc(iItem);
                  ConfigResult.rtnValue(iItem,@rValue);
                  // reserved area is current proposed reserved areas (rDeferredArea) +
                  //                  initial reserved areas (reservedarea)
                  rReservedArea := AFeat.rDeferredArea + AFeat.reservedarea;
                  writeln(ReportFile,AFeat.sID + ',' +
                                     IntToStr(AFeat.code) + ',' +
                                     FloatToStr(rReservedArea) + ',' +
                                     FloatToStr(rValue) + ',' +
                                     FloatToStr(rValue * rReservedArea)
                                     );
             end;
        end;*)

        //Inc(iItem);
        //ConfigResult.rtnValue(iItem,@rValue);
        //writeln(ReportFile,'All Features Combined,,,' +
        //                   FloatToStr(rValue) + ','
        //                   );

        closefile(ReportFile);
        // destroy the ConfigResult now that we have used it
        ConfigResult.Destroy;

        ControlForm.ProcLabel.Visible := False;
        ControlForm.ProcLabel.Caption := '';
        ControlForm.ProcLabel.Update;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.UseConfigResult',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------
procedure TSpatIOModule.WritePrepareSpreadTable(const sFilename : string);
var
   iCount, iVectorToWrite, iVectorCount : integer;
   ASite : site;
   AFeat : featureoccurrence;
   BinaryTable : File of double;
   TextTable : textfile;
   dValue : double;
   fWriteTextFile : boolean;
begin
     try
        fWriteTextFile := True;
        // create & populate pspr_sin.bin
        // 2 fields
        // S string
        // N vectors of type float
        if fWriteTextFile then
        begin
             assignfile(TextTable,sFilename + '\' + 'pspr_sin' + IntToStr(iSpattoolRequest) + '.txt');
             rewrite(TextTable);
        end
        else
        begin
             assignfile(BinaryTable,sFilename + '\' + 'pspr_sin.bin');
             rewrite(BinaryTable);
        end;
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,@ASite);
             dValue := Status2Double(ASite.status);
             if fWriteTextFile then
             begin
                  write(TextTable,Status2Char(ASite.status){FloatToStr(dValue)} + ' ');
             end
             else
             begin
                  write(BinaryTable,dValue);
             end;
             iVectorToWrite := 0;
             for iVectorCount := 1 to iFeatureCount do
             begin
                  FeatArr.rtnValue(iVectorCount,@AFeat);
                  if (AFeat.rSRADIUS <> 0) then
                     begin
                          Inc(iVectorToWrite);
                          dValue := rtnSiteFeatureValue(ASite,AFeat);
                          if fWriteTextFile then
                          begin
                               write(TextTable,FloatToStr(dValue) + ' ');
                          end
                          else
                          begin
                               write(BinaryTable,dValue);
                          end;
                     end;
             end;
             if fWriteTextFile then
                writeln(TextTable);
        end;
        if fWriteTextFile then
        begin
             closefile(TextTable);
        end
        else
        begin
             closefile(BinaryTable);
        end;
        // create & populate pspr_fin.bin
        // 2 fields
        // R float
        // T float
        if fWriteTextFile then
        begin
             assignfile(TextTable,sFilename + '\' + 'pspr_fin' + IntToStr(iSpattoolRequest) + '.txt');
             rewrite(TextTable);
        end
        else
        begin
             assignfile(BinaryTable,sFilename + '\' + 'pspr_fin.bin');
             rewrite(BinaryTable);
        end;
        for iCount := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iCount,@AFeat);
             if (AFeat.rSRADIUS <> 0) then
             begin
                  dValue := AFeat.rSRADIUS;
                  if fWriteTextFile then
                  begin
                       write(TextTable,FloatToStr(dValue) + ' ');
                  end
                  else
                  begin
                       write(BinaryTable,dValue);
                  end;
                  dValue := (AFeat.reservedarea +
                             AFeat.rDeferredArea +
                             AFeat.rSumArea)
                            /
                            AFeat.rTrimmedTarget;
                  if fWriteTextFile then
                  begin
                       writeln(TextTable,FloatToStr(dValue) + ' ');
                  end
                  else
                  begin
                       write(BinaryTable,dValue);
                  end;
                  //T = (init. res + prop. res + avail) / trimmed target
             end;
        end;
        if fWriteTextFile then
        begin
             closefile(TextTable);
        end
        else
        begin
             closefile(BinaryTable);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.WritePrepareSpreadTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------
procedure TSpatIOModule.ReadPrepareSpreadTable;
begin
     try

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.ReadPrepareSpreadTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------
procedure TSpatIOModule.SendPrepareSpreadRequest;
var
   RequestFile : TextFile;
begin
     {assemble an input dataset and send a PREPARE SPREAD request to the SPATTOOL}
     try
        //SpatialProgressForm := TSpatialProgressForm.Create(Application);
        //SpatialProgressForm.Show;
        Inc(iSpattoolRequest);
        // create prepare spread input file
        WritePrepareSpreadTable(ControlRes^.sSpatialDistanceFile);
        // send request to spattool
        assignfile(RequestFile,ControlRes^.sSpatialDistanceFile + '\cmdprepspread' + IntToStr(iSpattoolRequest));
        rewrite(RequestFile);
        writeln(RequestFile,'prepspread');
        closefile(RequestFile);
        Screen.Cursor := crDefault;

        (*
        // send areyouthere request
        Inc(iSpattoolRequest);
        // send request to spattool
        assignfile(RequestFile,ControlRes^.sSpatialDistanceFile + '\cmdareyouthere' + IntToStr(iSpattoolRequest));
        rewrite(RequestFile);
        writeln(RequestFile,'prepspread');
        closefile(RequestFile);
        Screen.Cursor := crHourglass;

        {now start the timer which periodically checks to see if the result is ready yet}
        AreYouThereTimer.Enabled := TRUE;
        *)

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.SendPrepareSpreadRequest',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;
// ---------------------------------------------------------------------------

procedure TSpatIOModule.UpdateSiteStatus(const sTable : string);
var
   iCount : integer;
   ASite : site;
begin
     // update the S (STATUS) field of the table
     try
        // update table
        DBFTable.DatabaseName := ControlRes^.sDatabase;
        DBFTable.TableName := sTable;
        DBFTable.Open;
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,@ASite);
             DBFTable.Edit;
             DBFTable.FieldByName('S').AsString := Status2Char(ASite.status);
             DBFTable.Next;
        end;
        //DBFTable.Post;
        DBFTable.Close;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.UpdateSiteStatus',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


// ---------------------------------------------------------------------------
procedure TSpatIOModule.ReceivePrepareSpreadResult;
begin
     try
        ControlRes^.fPrepareSpreadRun := True;
        // now run the SPREAD spatial command because it has been prepared
        SendSpreadRequest;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.ReceivePrepareSpreadResult',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------
procedure TSpatIOModule.WriteSpreadTable(const sFilename : string);
var
   iCount : integer;
   ASite : site;
   TextTable : TextFile;
   dValue : double;
begin
     try
        assignfile(TextTable,sFilename + '\' + 'spr_in' + IntToStr(iSpattoolRequest) + '.txt');
        rewrite(TextTable);
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,@ASite);
             dValue := Status2Double(ASite.status);
             writeln(TextTable,Status2Char(ASite.status));
        end;
        closefile(TextTable);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.WriteSpreadTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------
procedure TSpatIOModule.ReadSpreadTable(var SpreadResult : Array_t);
var
   iItems : integer;
   eValue : extended;
   rValue : single;
   InFile : TextFile;
   sLine : string;

   procedure ProcessRow;
   var
      iCount : integer;
   begin
        Inc(iItems);
        //eValue := DBFTable.FieldByName('F').AsFloat;
        // square the result before storing it because eValue is the square root of the Row result
        //rValue := eValue * eValue;
        // don't square the result
        //rValue := DBFTable.FieldByName('S').AsFloat;
        eValue := StrToFloat(sLine);
        try
           rValue := eValue;
        except
              rValue := 0;
        end;

        if (iItems <= SpreadResult.lMaxSize) then
           SpreadResult.setValue(iItems,@rValue);
   end;

begin
     // read the SpreadResult from the SpreadResult table
     try
        //DBFTable.DatabaseName := ControlRes^.sDatabase;
        //DBFTable.TableName := 'spr_out.dbf';
        //DBFTable.Open;
        assignfile(InFile,ControlRes^.sSpatialDistanceFile + '\spread_out' + IntToStr(iSpattoolRequest) + '.txt');
        reset(InFile);
        SpreadResult := Array_t.Create;
        SpreadResult.init(SizeOf(single),iFeatureCount);
        iItems := 0;
        {process the first row}
        readln(InFile,sLine);
        ProcessRow;
        repeat
              //DBFTable.Next;
              {process each other row}
              readln(InFile,sLine);
              ProcessRow;

        until Eof(InFile);//DBFTable.EOF;
        //DBFTable.Close;
        closefile(InFile);

        if (iItems > 0) then
           if (iItems <> SpreadResult.lMaxSize) then
              SpreadResult.resize(iItems);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.ReadSpreadTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------
procedure TSpatIOModule.SendSpreadRequest;
var
   RequestFile : TextFile;
begin
     {assemble an input dataset and send a SPREAD request to the SPATTOOL}
     try
        SpatialProgressForm := TSpatialProgressForm.Create(Application);
        SpatialProgressForm.Show;
        Inc(iSpattoolRequest);
        // create spread input file
        WriteSpreadTable(ControlRes^.sSpatialDistanceFile);
        // send request to spattool
        assignfile(RequestFile,ControlRes^.sSpatialDistanceFile + '\cmdspread' + IntToStr(iSpattoolRequest));
        rewrite(RequestFile);
        writeln(RequestFile,'spread');
        closefile(RequestFile);
        Screen.Cursor := crHourglass;

        {now start the timer which periodically checks to see if the result is ready yet}
        CheckTimer.Enabled := TRUE;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.SendSpreadRequest',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------
procedure TSpatIOModule.ReceiveSpreadResult;
var
   SpreadResult : Array_t;
   rAllFeaturesValue : extended;
   sSpreadReportFile : string;
begin
     {read and use the CONFIG result that has been created by the SPATTOOL}
     try
        ReadSpreadTable(SpreadResult);

        // generate a filename to report the config result to
        sSpreadReportFile := rtnUniqueFileName(ControlRes^.sWorkingDirectory + '\spread_result',
                                               'csv');

        // use the CONFIG result
        UseSpreadResult(SpreadResult,sSpreadReportFile);

        // launch the Table Editor with this file loaded into a grid
        //RunAnApp('table_ed',
        //         '"' + sSpreadReportFile + '"');
        DisplayGridForm := TDisplayGridForm.Create(Application);
        DisplayGridForm.InitWithFile(sSpreadReportFile);
        DisplayGridForm.ShowModal;
        DisplayGridForm.Free;

        try
        SpatialProgressForm.Free;
        except
        end;

     except
           (*Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.ReceiveSpreadResult',mtError,[mbOk],0);
           Application.Terminate;
           Exit;*)
     end;
end;

// ---------------------------------------------------------------------------
procedure TSpatIOModule.CreatePrepareSpreadTable;
var
   iCount : integer;
begin
     try
        // delete files if they already exist
        DeleteTable(ControlRes^.sDatabase,'pspr_sin');
        DeleteTable(ControlRes^.sDatabase,'pspr_fin');
        // create pspr_sin.dbf
        try
           with SQLQuery.Sql do
           begin
                Clear;
                Add('CREATE TABLE "' + ControlRes^.sDatabase + '\pspr_sin.dbf"');
                Add('(');
                Add('S CHAR(1),');
                for iCount := 1 to ControlRes^.iFeaturesWithSRADIUS do
                    if (iCount = ControlRes^.iFeaturesWithSRADIUS) then
                       Add('V' + IntToStr(iCount) + ' NUMERIC(10,5)')
                    else
                        Add('V' + IntToStr(iCount) + ' NUMERIC(10,5),');
                Add(')');
           end;
           SQLQuery.Prepare;
           SQLQuery.ExecSQL;
        except
              Screen.Cursor := crDefault;
              SQLQuery.SQL.SaveToFile('c:\pspr_sin.sql');
              MessageDlg('Exception executing SQL Query to create pspr_sin',mtError,[mbOk],0);
        end;
        // create pspr_fin.dbf
        try
           with SQLQuery.Sql do
           begin
                Clear;
                Add('CREATE TABLE "' + ControlRes^.sDatabase + '\pspr_fin.dbf"');
                Add('(');
                Add('R NUMERIC(10,5),');
                Add('T NUMERIC(10,5)');
                Add(')');
           end;
           SQLQuery.Prepare;
           SQLQuery.ExecSQL;
        except
              Screen.Cursor := crDefault;
              SQLQuery.SQL.SaveToFile('c:\pspr_fin.sql');
              MessageDlg('Exception executing SQL Query to create pspr_fin',mtError,[mbOk],0);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.CreatePrepareSpreadTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

// ---------------------------------------------------------------------------
procedure TSpatIOModule.CreateSpreadTable;
begin
     try
        // delete file if it already exists
        DeleteTable(ControlRes^.sDatabase,'spr_in');
        // create spr_in.dbf
        try
           with SQLQuery.Sql do
           begin
                Clear;
                Add('CREATE TABLE "' + ControlRes^.sDatabase + '\spr_in.dbf"');
                Add('(');
                Add('S CHAR(1)');
                Add(')');
           end;
           SQLQuery.Prepare;
           SQLQuery.ExecSQL;
        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception executing SQL Query to create spr_in',mtError,[mbOk],0);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.CreateSpreadTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;
// ---------------------------------------------------------------------------
procedure TSpatIOModule.UseSpreadResult(var SpreadResult : Array_t;
                                        const sFilenameToReportTo : string);
var
   ReportFile : Text;
   iItem, iCount, iVectorsToProcess : integer;
   AFeat : featureoccurrence;
   rValue : single;
begin
     // write the spread result to a spread report file
     try
        assignfile(ReportFile,sFilenameToReportTo);
        rewrite(ReportFile);
        iItem := 0;
        writeln(ReportFile,'Feature,Feature Key,Spread index');
        for iCount := 1 to SpreadResult.lMaxSize do
        begin
             FeatArr.rtnValue(iCount,@AFeat);
             if (AFeat.rSRADIUS <> 0) then
             begin
                  Inc(iItem);
                  SpreadResult.rtnValue(iItem,@rValue);
                  writeln(ReportFile,AFeat.sID + ',' +
                                     IntToStr(AFeat.code) + ',' +
                                     FloatToStr(rValue)
                                     );
             end;
        end;

        closefile(ReportFile);
        SpreadResult.Destroy;

        ControlForm.ProcLabel.Visible := False;
        ControlForm.ProcLabel.Caption := '';
        ControlForm.ProcLabel.Update;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.UseSpreadResult',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------

procedure TSpatIOModule.SpatIOModuleCreate(Sender: TObject);
begin
     DisposeOldTempFiles(ControlRes^.sSpatialDistanceFile);
end;

procedure TSpatIOModule.SpatIOModuleDestroy(Sender: TObject);
begin
     DisposeOldTempFiles(ControlRes^.sSpatialDistanceFile);
end;


procedure TSpatIOModule.AreYouThereTimerTimer(Sender: TObject);
// look for are you there response file
var
   sSyncFile : string;
begin
     try
        sSyncFile := ControlRes^.sSpatialDistanceFile + '\syncareyouthere' + IntToStr(iSpattoolRequest);
        if fileexists(sSyncFile) then
        begin
             AreYouThereTimer.Enabled := False;
             ReceivePrepareSpreadResult;

             AreYouThereTimer.Enabled := False;
             iSpattoolProcess := 0;
             Screen.Cursor := crDefault;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSpatIOModule.AreYouThereTimerTimer',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

end.

// ---------------------------------------------------------------------------

