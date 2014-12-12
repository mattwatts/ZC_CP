unit marxan;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ds, ExtCtrls;

type
    MarxanSiteResult_T = record
                               fInBestSolution : boolean;
                               InSolution : Array_t; {array 1..Solutions of boolean}
                               iSummedSolution : integer;
                         end;
    FeatureResult_T = record
                            rTarget,
                            rAmountHeld,
                            rOccurrenceTarget,
                            rOccurrencesHeld,
                            rSeperationTarget,
                            rSeperationAchieved : extended;
                            fTargetMet : boolean;
                      end;
    MarxanFeatureResult_T = record
                                  BestSolution : FeatureResult_T;
                                  Solution : Array_t; {array 1..Solutions of FeatureResult_T}
                            end;

  TMarxanPrototypeForm = class(TForm)
    btnCreateMarxanDatabase: TButton;
    btnRunMarxanDatabase: TButton;
    GroupBoxMarxanDatabaseOptions: TGroupBox;
    EditMarxanDatabasePath: TEdit;
    btnBrowseDatabase: TButton;
    btnRetrieveResult: TButton;
    btnOptions: TButton;
    BitBtnClose: TBitBtn;
    OpenMarxan: TOpenDialog;
    btnOptimisation: TButton;
    btnCost: TButton;
    btnDisplayCostResult: TButton;
    RadioGroup1: TRadioGroup;
    GroupBox1: TGroupBox;
    CheckSolutionsSiteTable: TCheckBox;
    EditSolutions: TEdit;
    Label2: TLabel;
    btnViewSiteResults: TButton;
    btnSelectSolution: TButton;
    btnMapResult: TButton;
    btnViewSummary: TButton;
    btnViewFeatureResults: TButton;
    Label3: TLabel;
    EditStartSolution: TEdit;
    CheckLockReserve: TCheckBox;
    Label1: TLabel;
    ComboBoxCOST: TComboBox;
    SyncTimer: TTimer;
    CheckOptimisedMarxan: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnRunMarxanDatabaseClick(Sender: TObject);
    procedure ExecuteMarxan(const sDatabasePath : string);
    procedure btnCreateMarxanDatabaseClick(Sender: TObject);
    procedure btnMarxanOptionsClick(Sender: TObject);
    procedure btnBrowseDatabaseClick(Sender: TObject);
    procedure btnRetrieveResultClick(Sender: TObject);
    procedure btnOptimisationClick(Sender: TObject);
    procedure btnCostClick(Sender: TObject);
    procedure btnViewSiteResultsClick(Sender: TObject);
    procedure btnViewFeatureResultsClick(Sender: TObject);
    procedure btnViewSummaryClick(Sender: TObject);
    procedure btnMapResultClick(Sender: TObject);
    procedure btnSelectSolutionClick(Sender: TObject);
    procedure CheckSolutionsSiteTableClick(Sender: TObject);
    procedure EditSolutionsChange(Sender: TObject);
    procedure EditStartSolutionChange(Sender: TObject);
    procedure ComboBoxCOSTChange(Sender: TObject);
    procedure InitComboBoxCOST;
    procedure SyncTimerTimer(Sender: TObject);
    procedure CheckOptimisedMarxanClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure CreateMarxanDatabase(const sDatabasePath, sInputName, sOutputName : string);
procedure UpdateMarxanDatabase(const sDatabasePath, sInputName, sOutputName : string);
procedure DisposeMarxanResult;
function RunAnAppAnyPath(const sApp, sParam, sCurrentDirectory : string) : boolean;
procedure CreateMarxanDatabaseClick;
procedure DeleteOldMarxanOutput(const sDatabasePath, sOutputDirName, sOutputFileName : string);

var
  MarxanPrototypeForm: TMarxanPrototypeForm;
  fMarxanResultCreated : boolean;
  iMarxanScenarios : integer;
  MarxanSites,
  MarxanFeatures : Array_t;
  fCreatingMarxanPrototypeForm : boolean;

implementation

uses
    global, control, workdir, marxanoptions, marxan_files, FileCtrl,
    override_combsize, opt1, sf_irrep, displaysites,
    inifiles, displayfeatures, marxan_summary, Options,
    db;

{$R *.DFM}

function PadInt(const iInt,iDigits : integer) : string;
begin
     Result := IntToStr(iInt);

     if (Length(Result) < iDigits) then
        repeat
              Result := '0' + Result;

        until (Length(Result) >= iDigits);
end;

function RunAppWithCreateProcess(const sApp, sCurrentDirectory : string) : boolean;
var
   hProcess : HWND;
   uExitCode : UINT;
   //lpProcessInformation : LPPROCESS_INFORMATION;
   //lpStartupInfo : LPSTARTUPINFO;
   //lpCurrentDirectory : LPCTSTR;
   //lpEnvironment : LPVOID;
   //dwCreationFlags : DWORD;
   //lpProcessAttributes, lpThreadAttributes : LPSECURITY_ATTRIBUTES;
begin
     // run the application sApp with its current directory set to sCurrentDirectory
     SetCurrentDirectory(PChar(sCurrentDirectory));
     (*
     CreateProcess(sApp,
                   '', // command line is blank, that is, no parameters are being passed
                   lpProcessAttributes,
                   lpThreadAttributes,
                   TRUE, // calling process inherits handle privilidges
                   dwCreationFlage,
                   lpCurrentDirectory,
                   lpStartupInfo,
                   lpProcessInformation);
     *)
     //hProcess := lpProcessInformation.hProcess;
     //PROCESS_INFORMATION
     // wait for the process to be idle awaiting input
     WaitForInputIdle(hProcess,INFINITE);
     GetExitCodeProcess(hProcess,uExitCode);

     // terminate the process
     //TerminateProcess(hProcess,uExitCode);
     ExitProcess(uExitCode);
end;

function WrapCreateProcess(const sApp, sCurrentDirectory : string) : HWND;
//var
   //lpProcessInformation : PROCESS_INFORMATION;//LPPROCESS_INFORMATION;
   //lpStartupInfo : LPSTARTUPINFO;
   //lpCurrentDirectory : LPCTSTR;
   //lpEnvironment : LPVOID;
   //dwCreationFlags : DWORD;
   //lpProcessAttributes, lpThreadAttributes : LPSECURITY_ATTRIBUTES;
begin
     // run the application sApp with its current directory set to sCurrentDirectory
     SetCurrentDirectory(PChar(sCurrentDirectory));
     (*
     CreateProcess(sApp,
                   '', // command line is blank, that is, no parameters are being passed
                   lpProcessAttributes,
                   lpThreadAttributes,
                   TRUE, // calling process inherits handle privilidges
                   dwCreationFlage,
                   lpCurrentDirectory,
                   lpStartupInfo,
                   lpProcessInformation);
     *)
     //Result := lpProcessInformation.hProcess;
end;


function RunAnAppAnyPath(const sApp, sParam, sCurrentDirectory : string) : boolean;
var
   sRunFile, sPath, sExeFile : string;
   PCmd : PChar;
begin
     SetCurrentDirectory(PChar(sCurrentDirectory));

     sExeFile := sApp;

     if (sParam = '') then
        sRunFile := sExeFile
     else
         sRunFile := sExeFile + ' ' + sParam;

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

procedure TMarxanPrototypeForm.InitComboBoxCOST;
var
   iCount : integer;
begin
     ComboBoxCOST.Text := ControlRes^.sMarxanCostField;
     // load all number fields from site table into drop down list box
     ComboBoxCOST.Items.Clear;

     with ControlForm.OutTable do
     begin
          Open;

          for iCount := 1 to FieldCount do
              if (FieldDefs.Items[iCount-1].DataType = ftSmallint)
              or (FieldDefs.Items[iCount-1].DataType = ftInteger)
              or (FieldDefs.Items[iCount-1].DataType = ftWord)
              or (FieldDefs.Items[iCount-1].DataType = ftFloat) then
                 ComboBoxCOST.Items.Add(FieldDefs.Items[iCount-1].Name);

          Close;
     end;
end;

procedure TMarxanPrototypeForm.FormCreate(Sender: TObject);
begin
     fCreatingMarxanPrototypeForm := True;

     EditMarxanDatabasePath.Text := ControlRes^.sMarxanDatabasePath;
     CheckLockReserve.Checked := ControlRes^.fLockReserve;

     CheckSolutionsSiteTable.Checked := ControlRes^.fRetrieveMarxanDetailToSiteTable;
     EditSolutions.Text := IntToStr(ControlRes^.iRetrieveMarxanDetailNumber);
     EditStartSolution.Text := IntToStr(ControlRes^.iRetrieveMarxanDetailStart);

     CheckOptimisedMarxan.Checked := ControlRes^.fOptimisedMarxan;

     InitComboBoxCOST;

     fCreatingMarxanPrototypeForm := False;
end;

procedure TMarxanPrototypeForm.ExecuteMarxan(const sDatabasePath : string);
var
   sTestExecutableName : string;
begin
     sTestExecutableName := 'exec.bat';

     // copy marxan executable to marxan database
     CopyFile(PChar('c:\marxan\marxan.exe'),PChar(ControlRes^.sMarxanDatabasePath + '\marxan.exe'),True);
     if fileexists('c:\marxan\' + sTestExecutableName) then
        CopyFile(PChar('c:\marxan\' + sTestExecutableName),PChar(ControlRes^.sMarxanDatabasePath + '\'+ sTestExecutableName),True);

     // call the executable
     if fileexists(ControlRes^.sMarxanDatabasePath + '\'+ sTestExecutableName) then
        RunAnAppAnyPath(ControlRes^.sMarxanDatabasePath + '\'+ sTestExecutableName,'',ControlRes^.sMarxanDatabasePath)
     else
         RunAnAppAnyPath(ControlRes^.sMarxanDatabasePath + '\marxan.exe','',ControlRes^.sMarxanDatabasePath);
     //RunAnAppAnyPath(ControlRes^.sMarxanDatabasePath + '\x.bat');
end;


procedure TMarxanPrototypeForm.btnRunMarxanDatabaseClick(Sender: TObject);
var
   sTestExecutableName : string;
begin
     sTestExecutableName := 'mcombine.exe';
     if ControlRes^.fMarxanDatabaseExists then
     begin
          // delete sync file if it exists
          DeleteFile(ControlRes^.sMarxanDatabasePath + '\CPlanSync');
          // get rid of any old Marxan results before doing a new Marxan run
          ControlForm.CleanDatabaseMarxanRuns;
          // delete the old files in the Marxan output directory to avoid confusing output
          DeleteOldMarxanOutput(ControlRes^.sMarxanDatabasePath,'output','output');

          UpdateMarxanDatabase(ControlRes^.sMarxanDatabasePath,'input','output');
          ExecuteMarxan(ControlRes^.sMarxanDatabasePath);

          if fileexists(ControlRes^.sMarxanDatabasePath + '\' + sTestExecutableName) then
             SyncTimer.Enabled := True;
     end;
end;


procedure CreateMarxanDatabaseClick;
begin
     // get user to select which directory to put marxan databse in
     try
        WorkingDirForm := TWorkingDirForm.Create(Application);

        ForceDirectories(ControlRes^.sDatabase + '\marxan');
        WorkingDirForm.EditPath.Text := ControlRes^.sDatabase + '\marxan';
        WorkingDirForm.Caption := 'Specify New Marxan Database Path';
        if (mrOk = WorkingDirForm.ShowModal) then
        begin
             ControlRes^.sMarxanDatabasePath := WorkingDirForm.EditPath.Text;
             ControlRes^.sMarxanOutputPath := ControlRes^.sMarxanDatabasePath;

             fIniChange := True;
        end;

        CreateMarxanDatabase(ControlRes^.sMarxanDatabasePath,'input','output');

        ControlRes^.fMarxanDatabaseExists := True;

     finally
            WorkingDirForm.Free;
     end;
end;

procedure TMarxanPrototypeForm.btnCreateMarxanDatabaseClick(
  Sender: TObject);
begin
     CreateMarxanDatabaseClick;
     EditMarxanDatabasePath.Text := ControlRes^.sMarxanDatabasePath;
end;

procedure TMarxanPrototypeForm.btnMarxanOptionsClick(Sender: TObject);
begin
     // copy inedit.exe to directory containing input.dat
     CopyFile(PChar('c:\marxan\inedit.exe'),PChar(ControlRes^.sMarxanDatabasePath + '\inedit.exe'),True);

     // execute inedit.exe to set options
     RunAnAppAnyPath(ControlRes^.sMarxanDatabasePath + '\inedit.exe','',ControlRes^.sMarxanDatabasePath);
end;

procedure CreateAnnealingInputFile(const sFile,sInputName,sOutputName : string);
var
   input_File : TextFile;
begin
     try
        assignfile(input_File,sFile);
        rewrite(input_File);

        // write parameters to the input_File
        writeln(input_File,'Input file for Marxan program, written by Ian Ball and Hugh Possingham.');
        writeln(input_File,'iball@maths.adelaide.edu.au');
        writeln(input_File,'hpossing@maths.adelaide.edu.au');
        writeln(input_File,'');
        writeln(input_File,'This file generated by cplan.exe');
        writeln(input_File,'emailto: cplan@ozemail.com.au');
        writeln(input_File,'');
        writeln(input_File,'General Parameters');
        writeln(input_File,'VERSION 0.1');
        writeln(input_File,'BLM  0.00000000000000E+0000');
        writeln(input_File,'PROP  5.00000000000000E-0001');
        writeln(input_File,'RANDSEED -1');
        writeln(input_File,'BESTSCORE  1.00000000000000E+0001');
        writeln(input_File,'NUMREPS 3');
        writeln(input_File,'');
        writeln(input_File,'Annealing Parameters');
        writeln(input_File,'NUMITNS 1000000');
        writeln(input_File,'STARTTEMP -1.00000000000000E+0000');
        writeln(input_File,'COOLFAC  6.00000000000000E+0000');
        writeln(input_File,'NUMTEMP 10000');
        writeln(input_File,'');
        writeln(input_File,'Cost Threshold');
        writeln(input_File,'COSTTHRESH  4.00000000000000E+0002');
        writeln(input_File,'THRESHPEN1  1.40000000000000E+0001');
        writeln(input_File,'THRESHPEN2  1.00000000000000E+0000');
        writeln(input_File,'');
        writeln(input_File,'Input Files');
        writeln(input_File,'INPUTDIR ' + sInputName);
        writeln(input_File,'SPECNAME spec.dat');
        writeln(input_File,'PUNAME pu.dat');
        writeln(input_File,'PUVSPRNAME puvspr2.dat');
        writeln(input_File,'BOUNDNAME ');
        writeln(input_File,'BLOCKDEFNAME ');
        writeln(input_File,'');
        writeln(input_File,'Save Files');
        writeln(input_File,'SCENNAME output');
        writeln(input_File,'SAVERUN 1');
        writeln(input_File,'SAVEBEST 1');
        writeln(input_File,'SAVESUMMARY 1');
        writeln(input_File,'SAVESCEN 1');
        writeln(input_File,'SAVETARGMET 1');
        writeln(input_File,'SAVESUMSOLN 1');
        writeln(input_File,'SAVELOG 1');
        writeln(input_File,'SAVESNAPSTEPS 0');
        writeln(input_File,'SAVESNAPCHANGES 0');
        writeln(input_File,'SAVESNAPFREQUENCY 23');
        writeln(input_File,'OUTPUTDIR ' + sOutputName);
        writeln(input_File,'');
        writeln(input_File,'Program control.');
        writeln(input_File,'RUNMODE 1');
        writeln(input_File,'MISSLEVEL  0.10000000000000E+0001');
        writeln(input_File,'ITIMPTYPE 0');
        writeln(input_File,'HEURTYPE -1');
        writeln(input_File,'CLUMPTYPE 0');
        writeln(input_File,'VERBOSITY 2');

        closefile(input_File);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CreateAnnealingInputFile',mtError,[mbOk],0);
     end;
end;

procedure CreateCostInputFile(const sFile,sInputName,sOutputName : string);
var
   input_File : TextFile;
begin
     try
        assignfile(input_File,sFile);
        rewrite(input_File);

        // write parameters to the input_File
        writeln(input_File,'Input file for Marxan program, written by Ian Ball and Hugh Possingham.');
        writeln(input_File,'iball@maths.adelaide.edu.au');
        writeln(input_File,'hpossing@maths.adelaide.edu.au');
        writeln(input_File,'');
        writeln(input_File,'This file generated by cplan.exe');
        writeln(input_File,'emailto: cplan@ozemail.com.au');
        writeln(input_File,'');
        writeln(input_File,'General Parameters');
        writeln(input_File,'VERSION 0.1');
        writeln(input_File,'BLM  0.00000000000000E+0000');
        writeln(input_File,'PROP  0.50000000000000E+0000');
        writeln(input_File,'RANDSEED -1');
        writeln(input_File,'BESTSCORE  1.00000000000000E+0001');
        writeln(input_File,'NUMREPS 1');
        writeln(input_File,'');
        writeln(input_File,'Annealing Parameters');
        writeln(input_File,'NUMITNS 1000000');
        writeln(input_File,'STARTTEMP -1.00000000000000E+0000');
        writeln(input_File,'COOLFAC  6.00000000000000E+0000');
        writeln(input_File,'NUMTEMP 10000');
        writeln(input_File,'');
        writeln(input_File,'Cost Threshold');
        writeln(input_File,'COSTTHRESH  0.00000000000000E+0000');
        writeln(input_File,'THRESHPEN1  1.40000000000000E+0001');
        writeln(input_File,'THRESHPEN2  1.00000000000000E+0000');
        writeln(input_File,'');
        writeln(input_File,'Input Files');
        writeln(input_File,'INPUTDIR ' + sInputName);
        writeln(input_File,'SPECNAME spec.dat');
        writeln(input_File,'PUNAME pu.dat');
        writeln(input_File,'PUVSPRNAME puvspr2.dat');
        writeln(input_File,'BOUNDNAME ');
        writeln(input_File,'BLOCKDEFNAME ');
        writeln(input_File,'');
        writeln(input_File,'Save Files');
        writeln(input_File,'SCENNAME output');
        writeln(input_File,'SAVERUN 1');
        writeln(input_File,'SAVEBEST 1');
        writeln(input_File,'SAVESUMMARY 1');
        writeln(input_File,'SAVESCEN 1');
        writeln(input_File,'SAVETARGMET 1');
        writeln(input_File,'SAVESUMSOLN 1');
        writeln(input_File,'SAVELOG 1');
        writeln(input_File,'SAVESNAPSTEPS 0');
        writeln(input_File,'SAVESNAPCHANGES 0');
        writeln(input_File,'SAVESNAPFREQUENCY 23');
        writeln(input_File,'OUTPUTDIR ' + sOutputName);
        writeln(input_File,'');
        writeln(input_File,'Program control.');
        writeln(input_File,'RUNMODE 4');
        writeln(input_File,'MISSLEVEL  0.10000000000000E+0001');
        writeln(input_File,'ITIMPTYPE 0');
        writeln(input_File,'HEURTYPE -1');
        writeln(input_File,'CLUMPTYPE 0');
        writeln(input_File,'VERBOSITY 2');

        closefile(input_File);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CreateCostInputFile',mtError,[mbOk],0);
     end;
end;

procedure CreateInputFile(const sFile,sInputName,sOutputName : string);
var
   input_File : TextFile;
begin
     try
        assignfile(input_File,sFile);
        rewrite(input_File);

        // write parameters to the input_File
        writeln(input_File,'Input file for Marxan program, written by Ian Ball and Hugh Possingham.');
        writeln(input_File,'iball@maths.adelaide.edu.au');
        writeln(input_File,'hpossing@maths.adelaide.edu.au');
        writeln(input_File,'');
        writeln(input_File,'This file generated by cplan.exe');
        writeln(input_File,'emailto: cplan@ozemail.com.au');
        writeln(input_File,'');
        writeln(input_File,'General Parameters');
        writeln(input_File,'VERSION 0.1');
        writeln(input_File,'BLM 0');
        writeln(input_File,'PROP 0.5');
        writeln(input_File,'RANDSEED -1');
        writeln(input_File,'BESTSCORE  1.00000000000000E+0001');
        writeln(input_File,'NUMREPS 1');
        writeln(input_File,'');
        writeln(input_File,'Annealing Parameters');
        writeln(input_File,'NUMITNS 1000000');
        writeln(input_File,'STARTTEMP -1.00000000000000E+0000');
        writeln(input_File,'COOLFAC  6.00000000000000E+0000');
        writeln(input_File,'NUMTEMP 10000');
        writeln(input_File,'');
        writeln(input_File,'Cost Threshold');
        writeln(input_File,'COSTTHRESH  0');
        writeln(input_File,'THRESHPEN1  1.40000000000000E+0001');
        writeln(input_File,'THRESHPEN2  1.00000000000000E+0000');
        writeln(input_File,'');
        writeln(input_File,'Input Files');
        writeln(input_File,'INPUTDIR ' + sInputName);
        writeln(input_File,'SPECNAME spec.dat');
        writeln(input_File,'PUNAME pu.dat');
        writeln(input_File,'PUVSPRNAME puvspr2.dat');
        writeln(input_File,'BOUNDNAME ');
        writeln(input_File,'BLOCKDEFNAME ');
        writeln(input_File,'');
        writeln(input_File,'Save Files');                              
        writeln(input_File,'SCENNAME output');
        writeln(input_File,'SAVERUN 3');
        writeln(input_File,'SAVEBEST 3');
        writeln(input_File,'SAVESUMMARY 3');
        writeln(input_File,'SAVESCEN 1');
        writeln(input_File,'SAVETARGMET 3');
        writeln(input_File,'SAVESUMSOLN 3');
        writeln(input_File,'SAVELOG 1');
        writeln(input_File,'OUTPUTDIR ' + sOutputName);
        writeln(input_File,'');
        writeln(input_File,'Program control.');
        writeln(input_File,'RUNMODE 4');
        writeln(input_File,'MISSLEVEL 1');
        writeln(input_File,'ITIMPTYPE 0');
        writeln(input_File,'HEURTYPE -1');
        writeln(input_File,'CLUMPTYPE 0');
        writeln(input_File,'VERBOSITY 2');

        closefile(input_File);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CreateInputFile',mtError,[mbOk],0);
     end;
end;

procedure CreateSpecFile(const sFile : string);
var
   spec_File : TextFile;
   iCount : integer;
   fInclude_spf, fInclude_target2, fInclude_sepdistance, fInclude_sepnum, fInclude_targetocc : boolean;
   sLine : string;
   pFeat : featureoccurrencepointer;
begin
     try
        new(pFeat);
        assignfile(spec_File,sFile);
        rewrite(spec_File);

        // open feature tables and detect fields
        ControlForm.CutOffTable.Open;
        fInclude_spf := TableContainsField(ControlForm.CutOffTable,'SPF');
        fInclude_target2 := TableContainsField(ControlForm.CutOffTable,'TARGET2');
        fInclude_sepdistance := TableContainsField(ControlForm.CutOffTable,'SEPDIST');
        fInclude_sepnum := TableContainsField(ControlForm.CutOffTable,'SEPNUM');
        fInclude_targetocc := TableContainsField(ControlForm.CutOffTable,'TARGETOCC');
        sLine := '"id","type","target"';
        if fInclude_spf then
           sLine := sLine + ',"spf"';
        if fInclude_target2 then
           sLine := sLine + ',"target2"';
        if fInclude_sepdistance then
           sLine := sLine + ',"sepdistance"';
        if fInclude_sepnum then
           sLine := sLine + ',"sepnum"';
        sLine := sLine + ',"name"';
        if fInclude_targetocc then
           sLine := sLine + ',"targetocc"';
        writeln(spec_File,sLine);

        for iCount := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iCount,pFeat);

             // fInclude_spf,fInclude_target2,fInclude_sepdistance,fInclude_sepnum,fInclude_targetocc
             //"id","type","target","spf","target2","sepdistance","sepnum","name","targetocc"
             sLine := IntToStr(pFeat^.code) + ',0';
             if pFeat^.fRestrict then
                sLine := sLine + ',0'
             else
                 try
                    sLine := sLine + ',' + RegionSafeFloatToStr(Round(pFeat^.rInitialTrimmedTarget*100)/100);
                 except
                       sLine := sLine + ',' + RegionSafeFloatToStr(Round(pFeat^.rInitialTrimmedTarget));
                 end;
             if fInclude_spf then
                sLine := sLine + ',' + ControlForm.CutOffTable.FieldByName('SPF').AsString;
             if fInclude_target2 then
                sLine := sLine + ',' + ControlForm.CutOffTable.FieldByName('TARGET2').AsString;
             if fInclude_sepdistance then
                sLine := sLine + ',' + ControlForm.CutOffTable.FieldByName('SEPDIST').AsString;
             if fInclude_sepnum then
                sLine := sLine + ',' + ControlForm.CutOffTable.FieldByName('SEPNUM').AsString;
             sLine := sLine + ',' + IntToStr(pFeat^.code);
             if fInclude_targetocc then
                sLine := sLine + ',' + ControlForm.CutOffTable.FieldByName('TARGETOCC').AsString;

             writeln(spec_File,sLine);

             ControlForm.CutOffTable.Next;
        end;

        ControlForm.CutOffTable.Close;
        closefile(spec_File);
        dispose(pFeat);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CreateSpecFile',mtError,[mbOk],0);
     end;
end;

procedure CreatePuFiles(const sPuFile, sPuvspr2File : string);
var
   iCount, iFeatures : integer;
   pu_File, puvspr2_File : TextFile;
   pSite : sitepointer;
   fInclude_xloc_yloc, fTableContainsCost : boolean;
   sLine, sCost : string;
   Value : ValueFile_T;
begin
     try
        assignfile(pu_File,sPuFile);
        rewrite(pu_File);
        assignfile(puvspr2_File,sPuvspr2File);
        rewrite(puvspr2_File);
        writeln(puvspr2_File,'"species","pu","amount"');
        new(pSite);

        // open site table and detect fields
        ControlForm.OutTable.Open;
        fTableContainsCost := TableContainsField(ControlForm.OutTable,ControlRes^.sMarxanCostField);
        fInclude_xloc_yloc := TableContainsField(ControlForm.OutTable,'XLOC')
                              and TableContainsField(ControlForm.OutTable,'YLOC');
        sLine := '"id","cost","status"';
        if fInclude_xloc_yloc then
           sLine := sLine + ',"xloc","yloc"';
        writeln(pu_File,sLine); //"id","cost","status","xloc","yloc"

        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);

             // write row to pu.dat
             sLine := IntToStr(pSite^.iKey);
             if fTableContainsCost then
                sCost := ',' + ControlForm.OutTable.FieldByName(ControlRes^.sMarxanCostField).AsString
             else
                 sCost := ',' + ControlForm.OutTable.FieldByName('area').AsString;

             if (sCost = ',') then
                sCost := ',1';
             sLine := sLine + sCost;
             
             // status corresponds to simulated annealing inputs
             // proposed reserves are not locked in
             case pSite^.status of
                  Av,Fl : sLine := sLine + ',0';
                  _R1,_R2,_R3,_R4,_R5,Pd : if MarxanPrototypeForm.CheckLockReserve.Checked then
                                              sLine := sLine + ',2'
                                           else
                                               sLine := sLine + ',1';
                  Re : sLine := sLine + ',2';
                  Ex,Ig : sLine := sLine + ',3';
             end;
             if fInclude_xloc_yloc then
                sLine := sLine + ',' + ControlForm.OutTable.FieldByName('xloc').AsString
                         + ',' + ControlForm.OutTable.FieldByName('yloc').AsString;
             writeln(pu_File,sLine);

             // write 0 or more rows to puvspr2 for this sites features
             if (pSite^.richness > 0) then
                for iFeatures := 1 to pSite^.richness do
                begin
                     FeatureAmount.rtnValue(pSite^.iOffSet + iFeatures,@Value);
                     writeln(puvspr2_File,IntToStr(Value.iFeatKey) + ',' + IntToStr(pSite^.iKey) + ',' + FloatToStr(Value.rAmount));
                     //writeln(puvspr2_File,IntToStr(Value.iFeatKey) + ',' + IntToStr(pSite^.iKey) + ',' + FloatToStr(Round(Value.rAmount*100)/100));
                     //writeln(puvspr2_File,IntToStr(Value.iFeatKey) + ',' + IntToStr(iCount) + ',' + FloatToStr(Round(Value.rAmount*100)/100));
                end;

             ControlForm.OutTable.Next;
        end;

        ControlForm.OutTable.Close;
        closefile(pu_File);
        closefile(puvspr2_File);
        dispose(pSite);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CreatePuFiles',mtError,[mbOk],0);
     end;
end;

procedure UpdatePuFile(const sPuFile : string);
var
   iCount, iFeatures : integer;
   pu_File, puvspr2_File : TextFile;
   pSite : sitepointer;
   fInclude_xloc_yloc, fTableContainsCost : boolean;
   sLine : string;
   Value : ValueFile_T;
begin
     try
        assignfile(pu_File,sPuFile);
        rewrite(pu_File);
        new(pSite);

        // open site table and detect fields
        ControlForm.OutTable.Open;
        fTableContainsCost := TableContainsField(ControlForm.OutTable,ControlRes^.sMarxanCostField);
        fInclude_xloc_yloc := TableContainsField(ControlForm.OutTable,'XLOC')
                              and TableContainsField(ControlForm.OutTable,'YLOC');
        sLine := '"id","cost","status"';
        if fInclude_xloc_yloc then
           sLine := sLine + ',"xloc","yloc"';
        writeln(pu_File,sLine); //"id","cost","status","xloc","yloc"

        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);

             // write row to pu.dat
             sLine := IntToStr(pSite^.iKey);
             if fTableContainsCost then
                sLine := sLine + ',' + ControlForm.OutTable.FieldByName(ControlRes^.sMarxanCostField).AsString
             else
                 sLine := sLine + ',' + ControlForm.OutTable.FieldByName('area').AsString;
             // status corresponds to simulated annealing inputs
             // proposed reserves are not locked in
             case pSite^.status of
                  Av,Fl : sLine := sLine + ',0';
                  _R2,_R3,_R4,_R5,Pd : sLine := sLine + ',1';
                  Re, _R1 : sLine := sLine + ',2';
                  Ex,Ig : sLine := sLine + ',3';
             end;
             if fInclude_xloc_yloc then
                sLine := sLine + ',' + ControlForm.OutTable.FieldByName('xloc').AsString
                         + ',' + ControlForm.OutTable.FieldByName('yloc').AsString;
             writeln(pu_File,sLine);

             ControlForm.OutTable.Next;
        end;

        ControlForm.OutTable.Close;
        closefile(pu_File);
        dispose(pSite);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in UpdatePuFile',mtError,[mbOk],0);
     end;
end;

procedure CreateMarxanDatabase(const sDatabasePath, sInputName, sOutputName : string);
begin
     Screen.Cursor := crHourglass;
     try
        // create output files
        ForceDirectories(sDatabasePath + '\' + sInputName);
        ForceDirectories(sDatabasePath + '\' + sOutputName);
        CreateInputFile(sDatabasePath + '\input.dat',sInputName,sOutputName);
        CreateSpecFile(sDatabasePath + '\' + sInputName + '\spec.dat');
        CreatePuFiles(sDatabasePath + '\' + sInputName + '\pu.dat',sDatabasePath + '\' + sInputName + '\puvspr2.dat');

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CreateMarxanDatabase',mtError,[mbOk],0);
     end;
     Screen.Cursor := crDefault;
end;

procedure UpdateMarxanDatabase(const sDatabasePath, sInputName, sOutputName : string);
begin
     Screen.Cursor := crHourglass;
     try
        // create output files
        ForceDirectories(sDatabasePath + '\' + sInputName);
        ForceDirectories(sDatabasePath + '\' + sOutputName);
        //CreateInputFile(sDatabasePath + '\input.dat',sInputName,sOutputName);
        CreateSpecFile(sDatabasePath + '\' + sInputName + '\spec.dat');
        UpdatePuFile(sDatabasePath + '\' + sInputName + '\pu.dat');

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CreateMarxanDatabase',mtError,[mbOk],0);
     end;
     Screen.Cursor := crDefault;
end;

procedure DeleteOldMarxanOutput(const sDatabasePath, sOutputDirName, sOutputFileName : string);
var
   sFilename : string;
   fTerminate : boolean;
   iRun : integer;
begin
     try
        //
        iRun := 0;
        fTerminate := False;

        repeat  
              sFilename := sDatabasePath + '\' + sOutputDirName + '\' + sOutputFileName + '_r' + PadInt(iRun + 1,5) + '.dat';
              if fileexists(sFilename) then
                 DeleteFile(sFilename)
              else
                  fTerminate := True;

              sFilename := sDatabasePath + '\' + sOutputDirName + '\' + sOutputFileName + '_mv' + PadInt(iRun + 1,5) + '.dat';
              if fileexists(sFilename) then
                 DeleteFile(sFilename)
              else
                  fTerminate := True;

              Inc(iRun);

        until fTerminate; //not fileexists(sFilename);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DeleteOldMarxanOutput',mtError,[mbOk],0);
     end;
end;

function CountScenarios(const sDatabasePath, sOutputDirName, sOutputFileName : string) : integer;
var
   sFilename : string;
begin
     try
        //
        Result := 0;

        repeat
              Inc(Result);
              sFilename := sDatabasePath + '\' + sOutputDirName + '\' + sOutputFileName + '_r' + PadInt(Result + 1,5) + '.dat';

        until not fileexists(sFilename);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CountScenarios',mtError,[mbOk],0);
     end;
end;

procedure WriteSiteValuesToDatabase;
begin

end;

procedure DumpSiteResult;
var
   MarxanSiteResult : MarxanSiteResult_t;
   iCount, iScenario, iSiteKey, iSiteInSolution, iSiteIndex : integer;
   fInSolution, fSiteInSolution : boolean;
   Infile_ssoln, Infile_best, Infile_r : TextFile;
   sLine : string;
   pSite : sitepointer;

   OutFile : TextFile;
begin
     try
        // dump the contents of the site result to the working directory for checking
        new(pSite);
        assignfile(OutFile,ControlRes^.sWorkingDirectory + '\dump_site_result.csv');
        rewrite(OutFile);
        write(OutFile,'SiteKey,MBEST,MSUMMED');
        for iScenario := 1 to iMarxanScenarios do
            write(OutFile,',MSOLN' + IntToStr(iScenario+ControlRes^.iRetrieveMarxanDetailStart-1));
        writeln(OutFile);

        for iCount := 1 to iSiteCount do
        begin
             MarxanSites.rtnValue(iCount,@MarxanSiteResult);
             SiteArr.rtnValue(iCount,pSite);
             write(OutFile,IntToStr(pSite^.iKey) + ',' +
                           IntToStr(Bool2Int(MarxanSiteResult.fInBestSolution)) + ',' +
                           IntToStr(MarxanSiteResult.iSummedSolution));
             for iScenario := 1 to iMarxanScenarios do
             begin
                  MarxanSiteResult.InSolution.rtnValue(iScenario,@fInSolution);
                  write(OutFile,',' + IntToStr(Bool2Int(fInSolution)));
             end;
             writeln(OutFile);
        end;

        dispose(pSite);
        closefile(OutFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DumpSiteResult',mtError,[mbOk],0);
     end;
end;

procedure ReadSiteResult(const sDatabasePath, sOutputDirName, sOutputFileName : string);
var
   MarxanSiteResult : MarxanSiteResult_t;
   iCount, iScenario, iSiteKey, iSiteInSolution, iSiteIndex : integer;
   fInSolution, fSiteInSolution : boolean;
   Infile_ssoln, Infile_best, Infile_r : TextFile;
   sLine : string;
   pSite : sitepointer;
begin
     try
        // create site array with space for appropriate number of scenarios
        MarxanSites := Array_t.Create;
        MarxanSites.init(SizeOf(MarxanSiteResult_t),iSiteCount);
        MarxanSiteResult.fInBestSolution := False;
        MarxanSiteResult.iSummedSolution := 0;
        fInSolution := False;
        for iCount := 1 to iSiteCount do
        begin
             MarxanSiteResult.InSolution := Array_t.Create;
             MarxanSiteResult.InSolution.init(SizeOf(boolean),iMarxanScenarios);
             for iScenario := 1 to iMarxanScenarios do
                 MarxanSiteResult.InSolution.setValue(iScenario,@fInSolution);
             MarxanSites.setValue(iCount,@MarxanSiteResult);
        end;

        // prepare the input files
        try
        assignfile(Infile_ssoln,sDatabasePath + '\' + sOutputDirName + '\' + sOutputFileName + '_ssoln.dat');
        reset(Infile_ssoln);
        except
        end;
        try
        assignfile(Infile_best,sDatabasePath + '\' + sOutputDirName + '\' + sOutputFileName + '_best.dat');
        reset(Infile_best);
        except
        end;
        try
        if fileexists(sDatabasePath + '\' + sOutputDirName + '\' + sOutputFileName + '_r0000' + IntToStr(ControlRes^.iRetrieveMarxanDetailStart) + '.dat') then
           assignfile(Infile_r,sDatabasePath + '\' + sOutputDirName + '\' + sOutputFileName + '_r0000' + IntToStr(ControlRes^.iRetrieveMarxanDetailStart) + '.dat')
        else
            assignfile(Infile_r,sDatabasePath + '\' + sOutputDirName + '\' + sOutputFileName + '_r0000' + IntToStr(ControlRes^.iRetrieveMarxanDetailStart) + '.txt');
        reset(Infile_r);
        except
        end;

        new(pSite);

        // traverse ssoln
        try
           while not Eof(Infile_ssoln) do
           begin
                readln(Infile_ssoln,sLine);
                // extract site key (1st element) and 0/1 site-in-solution (2nd element)
                iSiteKey := StrToInt(GetDelimitedAsciiElement(sLine,' ',1));
                iSiteInSolution := StrToInt(GetDelimitedAsciiElement(sLine,' ',2));
                if (iSiteInSolution > 0) then
                begin
                     iSiteIndex := findIntegerMatch(OrdSiteArr,iSiteKey);
                     MarxanSites.rtnValue(iSiteIndex,@MarxanSiteResult);
                     MarxanSiteResult.iSummedSolution := iSiteInSolution;
                     MarxanSites.setValue(iSiteIndex,@MarxanSiteResult);
                end;
           end;
        except
        end;

        // traverse best
        try
           while not Eof(Infile_best) do
           begin
                readln(Infile_best,sLine);
                // extract site key (1st element)
                iSiteKey := StrToInt(sLine);
                iSiteIndex := findIntegerMatch(OrdSiteArr,iSiteKey);
                MarxanSites.rtnValue(iSiteIndex,@MarxanSiteResult);
                MarxanSiteResult.fInBestSolution := True;
                MarxanSites.setValue(iSiteIndex,@MarxanSiteResult);
           end;
        except
        end;

        // traverse r
        try
           while not Eof(Infile_r) do
           begin
                readln(Infile_r,sLine);
                // extract site key (1st element)
                if (Pos(',',sLine)>0) then
                   iSiteKey := StrToInt(GetDelimitedAsciiElement(sLine,' ',1))
                else
                    iSiteKey := StrToInt(sLine);
                iSiteIndex := findIntegerMatch(OrdSiteArr,iSiteKey);
                // mark this site as in solution 1
                MarxanSites.rtnValue(iSiteIndex,@MarxanSiteResult);
                fInSolution := True;
                MarxanSiteResult.InSolution.setValue(1,@fInSolution);
                MarxanSites.setValue(iSiteIndex,@MarxanSiteResult);
           end;
        except
        end;

        // close the input files
        try
        closefile(Infile_ssoln);
        except
        end;
        try
        closefile(Infile_best);
        except
        end;
        try
        closefile(Infile_r);
        except
        end;

        // traverse the other r files
        if (iMarxanScenarios > 1) then
           //for iCount := (ControlRes^.iRetrieveMarxanDetailStart+1) to (ControlRes^.iRetrieveMarxanDetailStart+iMarxanScenarios-1) do
           for iCount := 2 to iMarxanScenarios do
           begin
                assignfile(Infile_r,sDatabasePath + '\' + sOutputDirName + '\' + sOutputFileName + '_r' + PadInt(iCount+ControlRes^.iRetrieveMarxanDetailStart-1,5) +'.dat');
                reset(Infile_r);

                // traverse r
                try
                   while not Eof(Infile_r) do
                   begin
                        readln(Infile_r,sLine);
                        // extract site key (1st element)
                        if (Pos(',',sLine)>0) then
                           iSiteKey := StrToInt(GetDelimitedAsciiElement(sLine,' ',1))
                        else
                            iSiteKey := StrToInt(sLine);
                        iSiteIndex := findIntegerMatch(OrdSiteArr,iSiteKey);
                        // mark this site as in solution iCount
                        MarxanSites.rtnValue(iSiteIndex,@MarxanSiteResult);
                        fInSolution := True;
                        MarxanSiteResult.InSolution.setValue(iCount,@fInSolution);
                        MarxanSites.setValue(iSiteIndex,@MarxanSiteResult);
                   end;
                except
                end;

                try
                closefile(Infile_r);
                except
                end;
           end;

        dispose(pSite);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReadSiteResult',mtError,[mbOk],0);
     end;
end;

procedure ReadFeatureResult(const sDatabasePath, sOutputDirName, sOutputFileName : string);
var
   MarxanFeatureResult : MarxanFeatureResult_t;
   FeatureResult : FeatureResult_t;
   iCount, iScenario, iFeature : integer;
   Infile_mvbest, Infile_mv : TextFile;
   sLine : string;
begin
     try
        // create feature array with space for appropriate number of scenarios
        MarxanFeatures := Array_t.Create;
        MarxanFeatures.init(SizeOf(MarxanFeatureResult_t),iFeatureCount);
        FeatureResult.rTarget := 0;
        FeatureResult.rAmountHeld := 0;
        FeatureResult.rOccurrenceTarget := 0;
        FeatureResult.rOccurrencesHeld := 0;
        FeatureResult.rSeperationTarget := 0;
        FeatureResult.rSeperationAchieved := 0;
        FeatureResult.fTargetMet := False;
        MarxanFeatureResult.BestSolution := FeatureResult;
        for iCount := 1 to iFeatureCount do
        begin
             MarxanFeatureResult.Solution := Array_t.Create;
             MarxanFeatureResult.Solution.init(SizeOf(FeatureResult_t),iMarxanScenarios);
             for iScenario := 1 to iMarxanScenarios do
                 MarxanFeatureResult.Solution.setValue(iScenario,@FeatureResult);
             MarxanFeatures.setValue(iCount,@MarxanFeatureResult);
        end;

        // prepare the input files
        assignfile(Infile_mvbest,sDatabasePath + '\' + sOutputDirName + '\' + sOutputFileName + '_mvbest.dat');
        reset(Infile_mvbest);
        readln(Infile_mvbest);
        assignfile(Infile_mv,sDatabasePath + '\' + sOutputDirName + '\' + sOutputFileName + '_mv00001.dat');
        reset(Infile_mv);
        readln(Infile_mv);

        // traverse mvbest
        try
           iFeature := 0;
           while not Eof(Infile_mvbest) do
           begin
                Inc(iFeature);
                MarxanFeatures.rtnValue(iFeature,@MarxanFeatureResult);
                // Chr(9) is tab
                readln(Infile_mvbest,sLine);
                FeatureResult.rTarget := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),3));
                FeatureResult.rAmountHeld := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),4));
                FeatureResult.rOccurrenceTarget := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),5));
                FeatureResult.rOccurrencesHeld := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),6));
                FeatureResult.rSeperationTarget := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),7));
                FeatureResult.rSeperationAchieved := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),8));
                FeatureResult.fTargetMet := (GetDelimitedAsciiElement(sLine,Chr(9),9) = 'yes');
                MarxanFeatureResult.BestSolution := FeatureResult;
                MarxanFeatures.setValue(iFeature,@MarxanFeatureResult);
           end;
        except
        end;

        // traverse mv
        try
           iFeature := 0;
           while not Eof(Infile_mv) do
           begin
                Inc(iFeature);
                MarxanFeatures.rtnValue(iFeature,@MarxanFeatureResult);
                // Chr(9) is tab
                readln(Infile_mv,sLine);
                FeatureResult.rTarget := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),3));
                FeatureResult.rAmountHeld := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),4));
                FeatureResult.rOccurrenceTarget := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),5));
                FeatureResult.rOccurrencesHeld := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),6));
                FeatureResult.rSeperationTarget := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),7));
                FeatureResult.rSeperationAchieved := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),8));
                FeatureResult.fTargetMet := (GetDelimitedAsciiElement(sLine,Chr(9),9) = 'yes');
                MarxanFeatureResult.Solution.setValue(1,@FeatureResult);
                MarxanFeatures.setValue(iFeature,@MarxanFeatureResult);
           end;
        except
        end;

        // close the input files
        closefile(Infile_mvbest);
        closefile(Infile_mv);

        // traverse the other mv files
        if (iMarxanScenarios > 1) then
           for iCount := 2 to iMarxanScenarios do
           begin
                assignfile(Infile_mv,sDatabasePath + '\' + sOutputDirName + '\' + sOutputFileName + '_mv' + PadInt(iCount,5) + '.dat');
                reset(Infile_mv);
                readln(Infile_mv);

                // traverse mv
                try
                   iFeature := 0;
                   while not Eof(Infile_mv) do
                   begin
                        Inc(iFeature);
                        MarxanFeatures.rtnValue(iFeature,@MarxanFeatureResult);
                        // Chr(9) is tab
                        readln(Infile_mv,sLine);
                        FeatureResult.rTarget := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),3));
                        FeatureResult.rAmountHeld := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),4));
                        FeatureResult.rOccurrenceTarget := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),5));
                        FeatureResult.rOccurrencesHeld := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),6));
                        FeatureResult.rSeperationTarget := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),7));
                        FeatureResult.rSeperationAchieved := StrToFloat(GetDelimitedAsciiElement(sLine,Chr(9),8));
                        FeatureResult.fTargetMet := (GetDelimitedAsciiElement(sLine,Chr(9),9) = 'yes');
                        MarxanFeatureResult.Solution.setValue(iCount,@FeatureResult);
                        MarxanFeatures.setValue(iFeature,@MarxanFeatureResult);
                   end;
                except
                end;

                closefile(Infile_mv);
           end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReadFeatureResult',mtError,[mbOk],0);
     end;
end;

procedure DisposeMarxanResult;
var
   iCount : integer;
   MarxanSiteResult : MarxanSiteResult_t;
   MarxanFeatureResult : MarxanFeatureResult_t;
begin
     try
        // destroy marxan result data structures
        for iCount := 1 to MarxanSites.lMaxSize do
        begin
             MarxanSites.rtnValue(iCount,@MarxanSiteResult);
             MarxanSiteResult.InSolution.Destroy;
        end;
        for iCount := 1 to MarxanFeatures.lMaxSize do
        begin
             MarxanFeatures.rtnValue(iCount,@MarxanFeatureResult);
             MarxanFeatureResult.Solution.Destroy;
        end;

        MarxanSites.Destroy;
        MarxanFeatures.Destroy;

        fMarxanResultCreated := False;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DisposeMarxanResult',mtError,[mbOk],0);
     end;
end;

procedure ReadMarxanResult(const sDatabasePath, sOutputDirName, sOutputFileName : string);
begin
     Screen.Cursor := crHourglass;
     try
        if fMarxanResultCreated then
           DisposeMarxanResult;

        iMarxanScenarios := CountScenarios(sDatabasePath, sOutputDirName, sOutputFileName);

        if (iMarxanScenarios > ControlRes^.iRetrieveMarxanDetailNumber) then
           iMarxanScenarios := ControlRes^.iRetrieveMarxanDetailNumber;

        try
        ReadSiteResult(sDatabasePath, sOutputDirName, sOutputFileName);
        except
        end;
        DumpSiteResult;
        try
        ReadFeatureResult(sDatabasePath, sOutputDirName, sOutputFileName);
        except
        end;

        fMarxanResultCreated := True;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReadMarxanResult',mtError,[mbOk],0);
     end;
     Screen.Cursor := crDefault;
end;

procedure TMarxanPrototypeForm.btnBrowseDatabaseClick(Sender: TObject);
begin
     OpenMarxan.InitialDir := ControlRes^.sWorkingDirectory;

     if OpenMarxan.Execute then
     begin
          EditMarxanDatabasePath.Text := ExtractFilePath(OpenMarxan.Filename);

          ControlRes^.sMarxanDatabasePath := EditMarxanDatabasePath.Text;
          ControlRes^.sMarxanOutputPath := EditMarxanDatabasePath.Text;
          fIniChange := True;
          ControlRes^.fMarxanDatabaseExists := True;
     end;
end;

procedure TMarxanPrototypeForm.btnRetrieveResultClick(Sender: TObject);
begin
     if ControlRes^.fMarxanDatabaseExists then
        ReadMarxanResult(ControlRes^.sMarxanDatabasePath,'output','output');

     ExecuteIrreplaceability(-1,False,False,True,True,'');

     // display the marxan result

end;



procedure TMarxanPrototypeForm.btnOptimisationClick(Sender: TObject);
begin
     CreateAnnealingInputFile(ControlRes^.sMarxanDatabasePath + '\input.dat','input','output');
     btnRunMarxanDatabaseClick(Sender);
end;

procedure TMarxanPrototypeForm.btnCostClick(Sender: TObject);
begin
     CreateCostInputFile(ControlRes^.sMarxanDatabasePath + '\input.dat','input','output');
     btnRunMarxanDatabaseClick(Sender);
end;



procedure TMarxanPrototypeForm.btnViewSiteResultsClick(Sender: TObject);
var
   iCount : integer;
   AIni : TIniFile;
begin
     // set site fields
     AIni := TIniFile.Create(ControlRes^.sDatabase + '\cplan.ini');
     AIni.EraseSection('Site Info Fields');
     AIni.WriteString('Site Info Fields','SITEKEY','');
     AIni.WriteString('Site Info Fields','SITENAME','');
     AIni.WriteString('Site Info Fields','STATUS','');
     AIni.WriteString('Site Info Fields','MARXANINBESTSOLUTION','');
     AIni.WriteString('Site Info Fields','MARXANSUMMEDSOLUTION','');
     if (iMarxanScenarios > 0) then
        for iCount := 1 to iMarxanScenarios do
            AIni.WriteString('Site Info Fields','MARXANINSOLUTION' + IntToStr(iCount),'');
     AIni.Free;
     // display the site result in the site info form
     Visible := False;

     DisplaySitesForm := TDisplaySitesForm.Create(Application);
     DisplaySitesForm.ShowModal;
     try
        DisplaySitesForm.Free;
     except
     end;

     Visible := True;
end;

procedure TMarxanPrototypeForm.btnViewFeatureResultsClick(Sender: TObject);
var
   iCount : integer;
   AIni : TIniFile;
begin
     // set feature fields
     (*AIni := TIniFile.Create(ControlRes^.sDatabase + '\cplan.ini');
     AIni.EraseSection('Site Info Fields');
     AIni.WriteString('Site Info Fields','SITEKEY','');
     AIni.WriteString('Site Info Fields','SITENAME','');
     AIni.WriteString('Site Info Fields','STATUS','');
     AIni.WriteString('Site Info Fields','MARXANINBESTSOLUTION','');
     AIni.WriteString('Site Info Fields','MARXANSUMMEDSOLUTION','');
     if (iMarxanScenarios > 0) then
        for iCount := 1 to iMarxanScenarios do
            AIni.WriteString('Site Info Fields','MARXANINSOLUTION' + IntToStr(iCount),'');
     AIni.Free;*)
     // display feature result
     Visible := False;

     DisplayFeaturesForm := TDisplayFeaturesForm.Create(Application);
     DisplayFeaturesForm.ShowModal;
     try
        DisplayFeaturesForm.Free;
     except
     end;

     Visible := True;
end;

procedure TMarxanPrototypeForm.btnViewSummaryClick(Sender: TObject);
begin
     MarxanSummaryForm := TMarxanSummaryForm.Create(Application);
     MarxanSummaryForm.ShowModal;
     MarxanSummaryForm.Free;
end;

procedure TMarxanPrototypeForm.btnMapResultClick(Sender: TObject);
begin
     OptionsForm := TOptionsForm.Create(Application);

     OptionsForm.OptPlotGroup.ItemIndex := OptionsForm.OptPlotGroup.Items.IndexOf('Marxan Summed Solution');
     ControlRes^.iGISPlotField := 10;

     OptionsForm.RedisplayIt(True);

     OptionsForm.Free;
end;

procedure TMarxanPrototypeForm.btnSelectSolutionClick(Sender: TObject);
begin
     ControlForm.Negotiated1Click(Sender);
end;




procedure TMarxanPrototypeForm.CheckSolutionsSiteTableClick(
  Sender: TObject);
begin
     if not fCreatingMarxanPrototypeForm then
     begin
          ControlRes^.fRetrieveMarxanDetailToSiteTable := CheckSolutionsSiteTable.Checked;
          fIniChange := True;
     end;
end;

procedure TMarxanPrototypeForm.EditSolutionsChange(Sender: TObject);
begin
     if not fCreatingMarxanPrototypeForm then
     begin
          try
             ControlRes^.iRetrieveMarxanDetailNumber := StrToInt(EditSolutions.Text);
             fIniChange := True;
          except
          end;
     end;
end;

procedure TMarxanPrototypeForm.EditStartSolutionChange(Sender: TObject);
begin
     if not fCreatingMarxanPrototypeForm then
     begin
          try
             ControlRes^.iRetrieveMarxanDetailStart := StrToInt(EditStartSolution.Text);
             fIniChange := True;
          except
          end;
     end;
end;


procedure TMarxanPrototypeForm.ComboBoxCOSTChange(Sender: TObject);
begin
     if not fCreatingMarxanPrototypeForm then
     begin
          fIniChange := True;
          ControlRes^.sMarxanCostField := ComboBoxCost.Text;
     end;
end;

procedure TMarxanPrototypeForm.SyncTimerTimer(Sender: TObject);
begin
     if fileexists(ControlRes^.sMarxanDatabasePath + '\CPlanSync') then
     begin
          SyncTimer.Enabled := False;
          DeleteFile(ControlRes^.sMarxanDatabasePath + '\CPlanSync');

          // retrieve the marxan result
          btnRetrieveResultClick(Sender);
          // map the marxan result to the gis
          btnMapResultClick(Sender);
     end;
end;

procedure TMarxanPrototypeForm.CheckOptimisedMarxanClick(Sender: TObject);
begin
     if not fCreatingMarxanPrototypeForm then
        fIniChange := True;
end;

end.
