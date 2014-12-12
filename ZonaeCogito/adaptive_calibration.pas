unit adaptive_calibration;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ds;

type
  TAdaptiveCalibrationForm = class(TForm)
    btnStop: TButton;
    BitBtnCancel: TBitBtn;
    btnStart: TButton;
    Label1: TLabel;
    Label2: TLabel;    
    LabelMPM: TLabel;
    Steps: TLabel;
    LabelSteps: TLabel;
    EditMPM: TEdit;
    Label3: TLabel;
    LabelProgress: TLabel;
    CheckSeed: TCheckBox;
    CheckDifferentialFPF: TCheckBox;
    procedure btnStartClick(Sender: TObject);
    procedure InitialiseCalibration;
    procedure ReadSpecDatFPF;
    procedure WriteSpecDatFPF;
    procedure ReadMissingValuesMPM;
    procedure ExecuteNextStep;
    procedure FreeCalibration;
    procedure UpdateFPF;
    procedure btnStopClick(Sender: TObject);
    procedure BitBtnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FPF_Log_, FPF_, MPM_, StoreFPF_ : Array_t;
    iCalibration_Steps : integer;
    fCalibrationActive : boolean;
    sActiveCalibrationLogFPFFilename,
    sActiveCalibrationLogLogarithmFilename,
    sActiveCalibrationLogMPMFilename : string;
    rTargetMPM : extended;
  end;

var
  AdaptiveCalibrationForm: TAdaptiveCalibrationForm;

implementation

uses
    Marxan_interface, Miscellaneous, SCP_Main;

{$R *.DFM}

procedure TAdaptiveCalibrationForm.InitialiseCalibration;
var
   iCount : integer;
   rFPF_Log_, rFPF_, rValue : extended;
   OutFile : TextFile;
begin
     FPF_Log_ := Array_t.Create;
     FPF_Log_.init(SizeOf(extended),iNumberOfFeatures);
     FPF_ := Array_t.Create;
     FPF_.init(SizeOf(extended),iNumberOfFeatures);
     MPM_ := Array_t.Create;
     MPM_.init(SizeOf(extended),iNumberOfFeatures);
     StoreFPF_ := Array_t.Create;
     StoreFPF_.init(SizeOf(extended),iNumberOfFeatures);

     rValue := 0;
     rFPF_Log_ := -10;
     rFPF_ := exp(rFPF_Log_);
     for iCount := 1 to iNumberOfFeatures do
     begin
          FPF_Log_.setValue(iCount,@rFPF_Log_);
          FPF_.setValue(iCount,@rFPF_);
          MPM_.setValue(iCount,@rValue);
          StoreFPF_.setValue(iCount,@rValue);
     end;

     LabelMPM.Caption := '0';
     LabelProgress.Caption := '0 of ' + IntToStr(iNumberOfFeatures);
     LabelSteps.Caption := '0';

     sActiveCalibrationLogFPFFilename := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
                                         MarxanInterfaceForm.ReturnMarxanParameter('INPUTDIR') +
                                         '\adaptive_calibration_FPF_';
     sActiveCalibrationLogLogarithmFilename := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
                                               MarxanInterfaceForm.ReturnMarxanParameter('INPUTDIR') +
                                               '\adaptive_calibration_Logarithm_';
     sActiveCalibrationLogMPMFilename := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
                                         MarxanInterfaceForm.ReturnMarxanParameter('INPUTDIR') +
                                         '\adaptive_calibration_MPM_';
     iCount := 0;
     repeat
           Inc(iCount);
     until not fileexists(sActiveCalibrationLogFPFFilename + IntToStr(iCount) + '.csv');

     sActiveCalibrationLogFPFFilename := sActiveCalibrationLogFPFFilename + IntToStr(iCount) + '.csv';
     sActiveCalibrationLogLogarithmFilename := sActiveCalibrationLogLogarithmFilename + IntToStr(iCount) + '.csv';
     sActiveCalibrationLogMPMFilename := sActiveCalibrationLogMPMFilename + IntToStr(iCount) + '.csv';

     assignfile(OutFile,sActiveCalibrationLogFPFFilename);
     rewrite(OutFile);
     if CheckDifferentialFPF.Checked then
     begin
          write(OutFile,'FPF');
          for iCount := 1 to iNumberOfFeatures do
              write(OutFile,',' + MarxanInterfaceForm.ReturnFeatureName(iCount));
          writeln(OutFile);
     end
     else
     begin
          writeln(OutFile,'test,FPF,MPM');
     end;
     closefile(OutFile);
     //
     assignfile(OutFile,sActiveCalibrationLogLogarithmFilename);
     rewrite(OutFile);
     write(OutFile,'Logarithm');
     for iCount := 1 to iNumberOfFeatures do
         write(OutFile,',' + MarxanInterfaceForm.ReturnFeatureName(iCount));
     writeln(OutFile);
     closefile(OutFile);
     //
     assignfile(OutFile,sActiveCalibrationLogMPMFilename);
     rewrite(OutFile);
     write(OutFile,'MPM');
     for iCount := 1 to iNumberOfFeatures do
         write(OutFile,',' + MarxanInterfaceForm.ReturnFeatureName(iCount));
     writeln(OutFile);
     closefile(OutFile);

     rTargetMPM := StrToFloat(EditMPM.Text);

     // write FPF.
     WriteSpecDatFPF;

     fCalibrationActive := True;
     fActiveCalibrationRunning := True;
     fActiveCalibrationOpen := True;
     iCalibration_Steps := 0;
end;

procedure TAdaptiveCalibrationForm.ReadSpecDatFPF;
var
   sInFile, sTemp : string;
   InFile : TextFile;
   iFieldCount, iCount, iFPF_Field : integer;
   sLine : string;
   rFPF : extended;
begin
     sInFile := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
                MarxanInterfaceForm.ReturnMarxanParameter('INPUTDIR') + '\' +
                MarxanInterfaceForm.ReturnMarxanParameter('SPECNAME');
     assignfile(InFile,sInFile);
     reset(InFile);
     readln(InFile,sLine);

     iFPF_Field := -1;
     iFieldCount := CountDelimitersInRow(sLine,',') + 1;
     for iCount := 1 to iFieldCount do
     begin
          sTemp := UpperCase(GetDelimitedAsciiElement(sLine,',',iCount));
          if (sTemp = 'FPF') or (sTemp = 'SPF') then
             iFPF_Field := iCount;
     end;

     iCount := 0;
     while not Eof(InFile) do
     begin
          Inc(iCount);
          readln(InFile,sLine);

          rFPF := StrToFloat(GetDelimitedAsciiElement(sLine,',',iFPF_Field));
          FPF_.setValue(iCount,@rFPF);
     end;

     closefile(InFile);
end;

procedure TAdaptiveCalibrationForm.WriteSpecDatFPF;
var
   sInFile, sOutFile, sTemp : string;
   InFile, OutFile : TextFile;
   iFieldCount, iCount, iFPF_Field, iRowCounter : integer;
   sLine : string;
   rFPF : extended;
begin
     sInFile := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
                MarxanInterfaceForm.ReturnMarxanParameter('INPUTDIR') + '\' +
                MarxanInterfaceForm.ReturnMarxanParameter('SPECNAME') + '~2';
     sOutFile := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
                 MarxanInterfaceForm.ReturnMarxanParameter('INPUTDIR') + '\' +
                 MarxanInterfaceForm.ReturnMarxanParameter('SPECNAME');
     ACopyFile(sOutFile,sInFile);
     
     assignfile(InFile,sInFile);
     reset(InFile);
     readln(InFile,sLine);

     assignfile(OutFile,sOutFile);
     rewrite(OutFile);
     writeln(OutFile,sLine);

     iFPF_Field := -1;
     iFieldCount := CountDelimitersInRow(sLine,',') + 1;
     for iCount := 1 to iFieldCount do
     begin
          sTemp := UpperCase(GetDelimitedAsciiElement(sLine,',',iCount));
          if (sTemp = 'FPF') or (sTemp = 'SPF') then
             iFPF_Field := iCount;
     end;

     iRowCounter := 0;
     repeat
           Inc(iRowCounter);
           FPF_.rtnValue(iRowCounter,@rFPF);
           readln(InFile,sLine);

           for iCount := 1 to iFieldCount do
           begin
                if (iCount = iFPF_Field) then
                   write(OutFile,FloatToStr(rFPF))
                else
                    write(OutFile,GetDelimitedAsciiElement(sLine,',',iCount));

                if (iCount <> iFieldCount) then
                   write(OutFile,',');
           end;

           writeln(OutFile);

     until Eof(InFile);

     closefile(InFile);
     closefile(OutFile);
end;

procedure TAdaptiveCalibrationForm.ReadMissingValuesMPM;
var
   sInFile, sTemp : string;
   InFile : TextFile;
   iFieldCount, iCount, iMPM_Field, iFileCount : integer;
   sLine : string;
   rMPM, rTestMPM : extended;
begin
     rMPM := 1;
     for iCount := 1 to iNumberOfFeatures do
         MPM_.setValue(iCount,@rMPM);

     for iFileCount := 1 to iSolutionCount do
     begin
          sInFile := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
                     MarxanInterfaceForm.ReturnMarxanParameter('OUTPUTDIR') +
                     '\' +
                     MarxanInterfaceForm.ReturnMarxanParameter('SCENNAME') +
                     '_mv' + PadInt(iFileCount,5) +
                     MarxanInterfaceForm.ReturnMarxanOutputFileExt('SAVETARGMET');

          assignfile(InFile,sInFile);
          reset(InFile);
          readln(InFile,sLine);

          iMPM_Field := -1;
          iFieldCount := CountDelimitersInRow(sLine,',') + 1;
          for iCount := 1 to iFieldCount do
          begin
               sTemp := UpperCase(GetDelimitedAsciiElement(sLine,',',iCount));
               if (Pos('MPM',sTemp) > 0) then
                  iMPM_Field := iCount;
          end;

          iCount := 0;
          while not Eof(InFile) do
          begin
               Inc(iCount);
               readln(InFile,sLine);

               rTestMPM := StrToFloat(GetDelimitedAsciiElement(sLine,',',iMPM_Field));
               MPM_.rtnValue(iCount,@rMPM);
               if (rTestMPM < rMPM) then
                  MPM_.setValue(iCount,@rTestMPM);
          end;

          closefile(InFile);
     end;
end;

procedure TAdaptiveCalibrationForm.UpdateFPF;
var
   iCount : integer;
   rMPM, rLog, rFPF : extended;
   fTargetMPMMet : boolean;
begin
     if CheckDifferentialFPF.Checked then
     begin
          for iCount := 1 to iNumberOfFeatures do
          begin
               MPM_.rtnValue(iCount,@rMPM);

               if (rMPM < rTargetMPM) then
               begin
                    FPF_Log_.rtnValue(iCount,@rLog);
                    rLog := rLog + 1;
                    FPF_Log_.setValue(iCount,@rLog);

                    FPF_.rtnValue(iCount,@rFPF);
                    rFPF := rFPF + exp(rLog);
                    FPF_.setValue(iCount,@rFPF);
               end;
          end;
     end
     else
     begin
          fTargetMPMMet := True;

          for iCount := 1 to iNumberOfFeatures do
          begin
               MPM_.rtnValue(iCount,@rMPM);

               if (rMPM < rTargetMPM) then
                  fTargetMPMMet := False;
          end;

          if fTargetMPMMet then
          begin
               for iCount := 1 to iNumberOfFeatures do
               begin
                    // rewind a step
                    FPF_Log_.rtnValue(iCount,@rLog);
                    FPF_.rtnValue(iCount,@rFPF);

                    rFPF := rFPF - exp(rLog);
                    rLog := -10;

                    FPF_Log_.setValue(iCount,@rLog);
                    FPF_.setValue(iCount,@rFPF);
               end;
          end
          else
              for iCount := 1 to iNumberOfFeatures do
              begin
                   FPF_Log_.rtnValue(iCount,@rLog);
                   rLog := rLog + 1;
                   FPF_Log_.setValue(iCount,@rLog);

                   FPF_.rtnValue(iCount,@rFPF);
                   rFPF := rFPF + exp(rLog);
                   FPF_.setValue(iCount,@rFPF);
              end;
     end;
end;

procedure TAdaptiveCalibrationForm.ExecuteNextStep;
var
   OutFile : TextFile;
   iCount, iFeaturesDone : integer;
   rFPF, rLog, rMPM, rMinimumMPM : extended;
begin
     Inc(iCalibration_Steps);

     // extract MPM.
     ReadMissingValuesMPM;

     // write to log files
     assignfile(OutFile,sActiveCalibrationLogMPMFilename);
     append(OutFile);
     write(OutFile,IntToStr(iCalibration_Steps));
     rMinimumMPM := 1;
     iFeaturesDone := 0;
     for iCount := 1 to iNumberOfFeatures do
     begin
          MPM_.rtnValue(iCount,@rMPM);
          write(OutFile,',' + FloatToStr(rMPM));

          if (rMPM < rTargetMPM) then
          begin
               if (rMPM < rMinimumMPM) then
                  rMinimumMPM := rMPM;
          end
          else
              Inc(iFeaturesDone);
     end;
     writeln(OutFile);
     closefile(OutFile);
     //
     if CheckDifferentialFPF.Checked then
     begin
          assignfile(OutFile,sActiveCalibrationLogFPFFilename);
          append(OutFile);
          write(OutFile,IntToStr(iCalibration_Steps));
          for iCount := 1 to iNumberOfFeatures do
          begin
               FPF_.rtnValue(iCount,@rFPF);
               write(OutFile,',' + FloatToStr(rFPF));
          end;
          writeln(OutFile);
          closefile(OutFile);
     end
     else
     begin
          assignfile(OutFile,sActiveCalibrationLogFPFFilename);
          append(OutFile);
          FPF_.rtnValue(1,@rFPF);
          writeln(OutFile,IntToStr(iCalibration_Steps) + ',' +
                          FloatToStr(rFPF) + ',' +
                          FloatToStr(rMinimumMPM));
          closefile(OutFile);
     end;
     //
     assignfile(OutFile,sActiveCalibrationLogLogarithmFilename);
     append(OutFile);
     write(OutFile,IntToStr(iCalibration_Steps));
     for iCount := 1 to iNumberOfFeatures do
     begin
          FPF_Log_.rtnValue(iCount,@rLog);
          write(OutFile,',' + FloatToStr(rLog));
     end;
     writeln(OutFile);
     closefile(OutFile);

     // update FPF.
     UpdateFPF;

     // write FPF.
     WriteSpecDatFPF;

     LabelMPM.Caption := FloatToStr(rMinimumMPM);
     LabelProgress.Caption := IntToStr(iFeaturesDone) + ' of ' + IntToStr(iNumberOfFeatures);
     LabelSteps.Caption := IntToStr(iCalibration_Steps);
end;

procedure TAdaptiveCalibrationForm.FreeCalibration;
begin
     fCalibrationActive := False;
     fActiveCalibrationRunning := False;

     FPF_Log_.Destroy;
     FPF_.Destroy;
     MPM_.Destroy;
     StoreFPF_.Destroy;
end;

procedure TAdaptiveCalibrationForm.btnStartClick(Sender: TObject);
begin
     InitialiseCalibration;

     MarxanInterfaceForm.ButtonUpdateClick(Sender);
     btnStart.Enabled := False;
     btnStop.Enabled := True;
     BitBtnCancel.Enabled := False;
end;

procedure TAdaptiveCalibrationForm.btnStopClick(Sender: TObject);
begin
     btnStop.Enabled := False;
     FreeCalibration;

     SCPForm.CreateCSVChild(sActiveCalibrationLogFPFFilename,0);
     SCPForm.AutoFitCSVChild(True);
end;

procedure TAdaptiveCalibrationForm.BitBtnCancelClick(Sender: TObject);
begin
     Free;
end;

end.
