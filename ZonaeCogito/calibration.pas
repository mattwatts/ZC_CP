unit calibration;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TCalibrationForm = class(TForm)
    RadioInput: TRadioGroup;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    GroupBox1: TGroupBox;
    EditNumber: TEdit;
    Label1: TLabel;
    GroupBox2: TGroupBox;
    EditMin: TEdit;
    EditMax: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    CheckExponent: TCheckBox;
    MemoExponent: TMemo;
    procedure BitBtn1Click(Sender: TObject);
    procedure CheckExponentClick(Sender: TObject);
    procedure UpdateMemoExponent;
    procedure EditNumberChange(Sender: TObject);
    procedure EditMinChange(Sender: TObject);
    procedure EditMaxChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure CollectNextCalibrationResult;
procedure DisplayAllCalibrationResults;
procedure StartNextCalibrationJob;
procedure RetrieveInputDatFiles;

var
  CalibrationForm: TCalibrationForm;

implementation

uses Marxan_interface, FileCtrl, Miscellaneous, SCP_Main, GIS;

{$R *.DFM}

procedure StoreInputDatFiles;
var
   sBaseDirectory : string;
   fFound : boolean;
begin
     sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);

     ForceDirectories(sBaseDirectory + 'backup');

     CopyIfExists('input.dat',sBaseDirectory,sBaseDirectory + 'backup');
     CopyIfExists('zoneboundcost.dat',sBaseDirectory + 'input',sBaseDirectory + 'backup');

     CopyIfExists(MarxanInterfaceForm.ReturnMarxanParameter('SPECNAME'),sBaseDirectory + 'input',sBaseDirectory + 'backup');

     CopyIfExists('zonetarget.dat',sBaseDirectory + 'input',sBaseDirectory + 'backup');
     CopyIfExists('zonecost.dat',sBaseDirectory + 'input',sBaseDirectory + 'backup');
end;

procedure RetrieveInputDatFiles;
var
   sBaseDirectory, sInputDir : string;
   fFound : boolean;
begin
     sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);

     sInputDir := MarxanInterfaceForm.ReturnMarxanParameter('INPUTDIR');

     CopyIfExists('input.dat',sBaseDirectory + 'backup',sBaseDirectory );
     CopyIfExists(MarxanInterfaceForm.ReturnMarxanParameter('ZONEBOUNDCOSTNAME'),sBaseDirectory + 'backup',sBaseDirectory + sInputDir);
     CopyIfExists(MarxanInterfaceForm.ReturnMarxanParameter('SPECNAME'),sBaseDirectory + 'backup',sBaseDirectory + sInputDir);
     CopyIfExists('zonetarget.dat',sBaseDirectory + 'backup',sBaseDirectory + sInputDir);
     CopyIfExists('zonecost.dat',sBaseDirectory + 'backup',sBaseDirectory + sInputDir);
     DeleteFile(sBaseDirectory + 'backup\input.dat');
     DeleteFile(sBaseDirectory + 'backup\' + MarxanInterfaceForm.ReturnMarxanParameter('ZONEBOUNDCOSTNAME'));
     DeleteFile(sBaseDirectory + 'backup\' + MarxanInterfaceForm.ReturnMarxanParameter('SPECNAME'));
     DeleteFile(sBaseDirectory + 'backup\feat.dat');
     DeleteFile(sBaseDirectory + 'backup\zonetarget.dat');
     DeleteFile(sBaseDirectory + 'backup\zonecost.dat');
end;

procedure UpdateBLMParameter(rValue : extended);
// parse the input.dat file (writing it to another file) until finding a line that contains sParameterLoaded.  Substitute the new value.
var
   InputFile, OutputFile : TextFile;
   sInputLine : string;
begin
     assignfile(InputFile,MarxanInterfaceForm.EditMarxanDatabasePath.Text);
     reset(InputFile);
     assignfile(OutputFile,MarxanInterfaceForm.EditMarxanDatabasePath.Text + '~');
     rewrite(OutputFile);

     repeat
           readln(InputFile,sInputLine);

           if (Pos('BLM',UpperCase(sInputLine)) = 1) then
              writeln(OutputFile,'BLM ' + FloatToStr(rValue))
           else
               writeln(OutputFile,sInputLine);

     until Eof(InputFile);

     closefile(InputFile);
     closefile(OutputFile);

     deletefile(MarxanInterfaceForm.EditMarxanDatabasePath.Text);
     ACopyFile(MarxanInterfaceForm.EditMarxanDatabasePath.Text + '~',MarxanInterfaceForm.EditMarxanDatabasePath.Text);
     deletefile(MarxanInterfaceForm.EditMarxanDatabasePath.Text + '~');
end;

procedure UpdateProbabilityWeightingParameter(rValue : extended);
// parse the input.dat file (writing it to another file) until finding a line that contains sParameterLoaded.  Substitute the new value.
var
   InputFile, OutputFile : TextFile;
   sInputLine : string;
begin
     assignfile(InputFile,MarxanInterfaceForm.EditMarxanDatabasePath.Text);
     reset(InputFile);
     assignfile(OutputFile,MarxanInterfaceForm.EditMarxanDatabasePath.Text + '~');
     rewrite(OutputFile);

     repeat
           readln(InputFile,sInputLine);

           if (Pos('PROBABILITYWEIGHTING',UpperCase(sInputLine)) = 1) then
              writeln(OutputFile,'PROBABILITYWEIGHTING ' + FloatToStr(rValue))
           else
               writeln(OutputFile,sInputLine);

     until Eof(InputFile);

     closefile(InputFile);
     closefile(OutputFile);

     deletefile(MarxanInterfaceForm.EditMarxanDatabasePath.Text);
     ACopyFile(MarxanInterfaceForm.EditMarxanDatabasePath.Text + '~',MarxanInterfaceForm.EditMarxanDatabasePath.Text);
     deletefile(MarxanInterfaceForm.EditMarxanDatabasePath.Text + '~');
end;


procedure UpdateZoneBLMFile(rValue : extended);
var
   sBaseDirectory, sInputLine, sInputDir, sZoneBoundCostName : string;
   InputFile, OutputFile : TextFile;
begin
     sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);

     sInputDir := MarxanInterfaceForm.ReturnMarxanParameter('INPUTDIR');
     sZoneBoundCostName := MarxanInterfaceForm.ReturnMarxanParameter('ZONEBOUNDCOSTNAME');

     CopyIfExists('zoneboundcost.dat',sBaseDirectory + 'backup',sBaseDirectory + sInputDir);

     assignfile(InputFile,sBaseDirectory + sInputDir + '\' + sZoneBoundCostName);
     reset(InputFile);
     assignfile(OutputFile,sBaseDirectory + sInputDir + '\' + sZoneBoundCostName + '~');
     rewrite(OutputFile);

     readln(InputFile,sInputLine);
     writeln(OutputFile,sInputLine);

     repeat
           readln(InputFile,sInputLine);

           writeln(OutputFile,GetDelimitedAsciiElement(sInputLine,',',1) + ',' +
                              GetDelimitedAsciiElement(sInputLine,',',2) + ',' +
                              FloatToStr(StrToFloat(GetDelimitedAsciiElement(sInputLine,',',3)) * rValue));

     until Eof(InputFile);

     closefile(InputFile);
     closefile(OutputFile);

     deletefile(sBaseDirectory + sInputDir + '\' + sZoneBoundCostName);
     Acopyfile(sBaseDirectory + sInputDir + '\' + sZoneBoundCostName + '~',sBaseDirectory + sInputDir + '\' + sZoneBoundCostName);
end;

procedure UpdateSPFFile(rValue : extended);
var
   sBaseDirectory, sInputLine, sSpecName, sInputDir : string;
   InputFile, OutputFile : TextFile;
   iFields, iCount, iSPFField : integer;
begin
     sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);

     sInputDir := MarxanInterfaceForm.ReturnMarxanParameter('INPUTDIR');
     sSpecName := MarxanInterfaceForm.ReturnMarxanParameter('SPECNAME');
     if (sSpecName = '') then
        sSpecName := MarxanInterfaceForm.ReturnMarxanParameter('FEATNAME');

     CopyIfExists(sSpecName,sBaseDirectory + 'backup',sBaseDirectory + sInputDir);

     assignfile(InputFile,sBaseDirectory + sInputDir + '\' + sSpecName);
     reset(InputFile);
     assignfile(OutputFile,sBaseDirectory + sInputDir + '\' + sSpecName + '~');
     rewrite(OutputFile);

     readln(InputFile,sInputLine);

     iFields := CountDelimitersInRow(sInputLine,',') + 1;
     for iCount := 1 to iFields do
         if (GetDelimitedAsciiElement(sInputLine,',',iCount) = 'spf') then
            iSPFField := iCount;

     writeln(OutputFile,sInputLine);

     repeat
           readln(InputFile,sInputLine);

           for iCount := 1 to iFields do
           begin
                if (iCount = iSPFField) then
                   //write(OutputFile,FloatToStr(StrToFloat(GetDelimitedAsciiElement(sInputLine,',',iCount)) * rValue))
                   write(OutputFile,FloatToStr(rValue))
                else
                    write(OutputFile,GetDelimitedAsciiElement(sInputLine,',',iCount));

                if (iCount <> iFields) then
                   write(OutputFile,',');
           end;

           writeln(OutputFile);

     until Eof(InputFile);

     closefile(InputFile);
     closefile(OutputFile);

     deletefile(sBaseDirectory + sInputDir + '\' + sSpecName);
     Acopyfile(sBaseDirectory + sInputDir + '\' + sSpecName + '~',sBaseDirectory + sInputDir + '\' + sSpecName);
end;

procedure UpdateTargetFile(rValue : extended);
var
   sBaseDirectory, sInputLine, sSpecName, sInputDir : string;
   InputFile, OutputFile : TextFile;
   iFields, iCount, iTargetField : integer;
begin
     sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);

     sInputDir := MarxanInterfaceForm.ReturnMarxanParameter('INPUTDIR');
     sSpecName := MarxanInterfaceForm.ReturnMarxanParameter('SPECNAME');
     if (sSpecName = '') then
        sSpecName := MarxanInterfaceForm.ReturnMarxanParameter('FEATNAME');

     CopyIfExists(sSpecName,sBaseDirectory + 'backup',sBaseDirectory + sInputDir);

     assignfile(InputFile,sBaseDirectory + sInputDir + '\' + sSpecName);
     reset(InputFile);
     assignfile(OutputFile,sBaseDirectory + sInputDir + '\' + sSpecName + '~');
     rewrite(OutputFile);

     readln(InputFile,sInputLine);

     iFields := CountDelimitersInRow(sInputLine,',') + 1;
     iTargetField := 0;
     for iCount := 1 to iFields do
         if (GetDelimitedAsciiElement(sInputLine,',',iCount) = 'target') then
            iTargetField := iCount;
     if (iTargetField = 0) then
        for iCount := 1 to iFields do
            if (GetDelimitedAsciiElement(sInputLine,',',iCount) = 'prop') then
               iTargetField := iCount;

     writeln(OutputFile,sInputLine);

     repeat
           readln(InputFile,sInputLine);

           for iCount := 1 to iFields do
           begin
                if (iCount = iTargetField) then
                   write(OutputFile,FloatToStr(StrToFloat(GetDelimitedAsciiElement(sInputLine,',',iCount)) * rValue))
                else
                    write(OutputFile,GetDelimitedAsciiElement(sInputLine,',',iCount));

                if (iCount <> iFields) then
                   write(OutputFile,',');
           end;

           writeln(OutputFile);

     until Eof(InputFile);

     closefile(InputFile);
     closefile(OutputFile);

     deletefile(sBaseDirectory + sInputDir + '\' + sSpecName);
     Acopyfile(sBaseDirectory + sInputDir + '\' + sSpecName + '~',sBaseDirectory + sInputDir + '\' + sSpecName);
end;

procedure UpdateZoneTargetFile(rValue : extended);
var
   sBaseDirectory, sInputLine, sInputDir, sZoneTargetName : string;
   InputFile, OutputFile : TextFile;
begin
     sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);

     sZoneTargetName := MarxanInterfaceForm.ReturnMarxanParameter('ZONETARGETNAME');
     sInputDir := MarxanInterfaceForm.ReturnMarxanParameter('INPUTDIR');

     CopyIfExists('zonetarget.dat',sBaseDirectory + 'backup',sBaseDirectory + sInputDir);

     assignfile(InputFile,sBaseDirectory + sInputDir + '\' + sZoneTargetName);
     reset(InputFile);
     assignfile(OutputFile,sBaseDirectory + sInputDir + '\' + sZoneTargetName + '~');
     rewrite(OutputFile);

     readln(InputFile,sInputLine);
     writeln(OutputFile,sInputLine);

     repeat
           readln(InputFile,sInputLine);

           writeln(OutputFile,GetDelimitedAsciiElement(sInputLine,',',1) + ',' +
                              GetDelimitedAsciiElement(sInputLine,',',2) + ',' +
                              FloatToStr(StrToFloat(GetDelimitedAsciiElement(sInputLine,',',3)) * rValue) + ',' +
                              GetDelimitedAsciiElement(sInputLine,',',4));

     until Eof(InputFile);

     closefile(InputFile);
     closefile(OutputFile);

     deletefile(sBaseDirectory + sInputDir + '\' + sZoneTargetName);
     Acopyfile(sBaseDirectory + sInputDir + '\' + sZoneTargetName + '~',sBaseDirectory + sInputDir + '\' + sZoneTargetName);
end;

procedure UpdateCostFile(rValue : extended);
var
   sBaseDirectory, sInputLine, sInputDir, sZoneCostName : string;
   InputFile, OutputFile : TextFile;
begin
     sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);

     sInputDir := MarxanInterfaceForm.ReturnMarxanParameter('INPUTDIR');
     sZoneCostName := MarxanInterfaceForm.ReturnMarxanParameter('ZONECOSTNAME');

     CopyIfExists('zonecost.dat',sBaseDirectory + 'backup',sBaseDirectory + sInputDir);

     assignfile(InputFile,sBaseDirectory + sInputDir + '\' + sZoneCostName);
     reset(InputFile);
     assignfile(OutputFile,sBaseDirectory + sInputDir + '\' + sZoneCostName + '~');
     rewrite(OutputFile);

     readln(InputFile,sInputLine);
     writeln(OutputFile,sInputLine);

     repeat
           readln(InputFile,sInputLine);

           writeln(OutputFile,GetDelimitedAsciiElement(sInputLine,',',1) + ',' +
                              GetDelimitedAsciiElement(sInputLine,',',2) + ',' +
                              FloatToStr(StrToFloat(GetDelimitedAsciiElement(sInputLine,',',3)) * rValue));

     until Eof(InputFile);

     closefile(InputFile);
     closefile(OutputFile);

     deletefile(sBaseDirectory + sInputDir + '\' + sZoneCostName);
     Acopyfile(sBaseDirectory + sInputDir + '\' + sZoneCostName + '~',sBaseDirectory + sInputDir + '\' + sZoneCostName);
end;

procedure UpdateValue(iInput : integer; rValue : extended);
begin
     try
        //
        if (iInput = 0) then
           UpdateBLMParameter(rValue);
        if (iInput = 1) then
           // update Zone BLM file
           UpdateZoneBLMFile(rValue);
        if (iInput = 2) then
           // update target file
           UpdateSPFFile(rValue);
        if (iInput = 3) then
           // update target file
           UpdateTargetFile(rValue);
        if (iInput = 4) then
           // update target file
           UpdateZoneTargetFile(rValue);
        if (iInput = 5) then
           // update cost file
           UpdateCostFile(rValue);
        if (iInput = 6) then
           UpdateProbabilityWeightingParameter(rValue);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in UpdateValue',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

function ReturnCalibrationResultText : string;
var
   InFile : TextFile;
   sInFile, sLine : string;
   rTotalCost, rTotalScore, rTotalBoundary, rTotalPenalty, rTotalShortfall : extended;
   iTotalPUs, iTotalMissing, iRowsProcessed, iAdder : integer;
begin
     // read output_sum.txt file and calculate average cost (column 3)
     // comma delimited ascii
     try
        sInFile := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
                   MarxanInterfaceForm.ReturnMarxanParameter('OUTPUTDIR') +
                   '\' +
                   MarxanInterfaceForm.ReturnMarxanParameter('SCENNAME') +
                   '_sum.txt';
        if not fileexists(sInFile) then
           sInFile := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) +
                      MarxanInterfaceForm.ReturnMarxanParameter('OUTPUTDIR') +
                      '\' +
                      MarxanInterfaceForm.ReturnMarxanParameter('SCENNAME') +
                      '_sum.csv';
        assignfile(InFile,sInFile);
        reset(InFile);
        readln(InFile,sLine);

        //iAdder := CountDelimitersInRow(sLine,',') - 7;
        iAdder := CountDelimitersInRow(sLine,',') - 8;

        rTotalScore := 0;
        rTotalCost := 0;
        iTotalPUs := 0;
        rTotalBoundary := 0;
        rTotalPenalty := 0;
        //rTotalProbability := 0;
        rTotalShortfall := 0;
        iTotalMissing := 0;
        iRowsProcessed := 0;
        repeat
              readln(InFile,sLine);

              rTotalScore := rTotalScore + StrToFloat(GetDelimitedAsciiElement(sLine,',',2));
              rTotalCost := rTotalCost + StrToFloat(GetDelimitedAsciiElement(sLine,',',3));
              if fMarZone then
              begin
                   iTotalPUs := iTotalPUs + StrToInt(GetDelimitedAsciiElement(sLine,',',6));
                   rTotalBoundary := rTotalBoundary + StrToFloat(GetDelimitedAsciiElement(sLine,',',5+iAdder));
                   rTotalPenalty := rTotalPenalty + StrToFloat(GetDelimitedAsciiElement(sLine,',',6+iAdder));
                   rTotalShortfall := rTotalShortfall + StrToFloat(GetDelimitedAsciiElement(sLine,',',7+iAdder));
                   iTotalMissing := iTotalMissing + Round(StrToFloat(GetDelimitedAsciiElement(sLine,',',8+iAdder)));
              end
              else
              begin
                   iTotalPUs := iTotalPUs + StrToInt(GetDelimitedAsciiElement(sLine,',',4));
                   rTotalBoundary := rTotalBoundary + StrToFloat(GetDelimitedAsciiElement(sLine,',',5));
                   rTotalPenalty := rTotalPenalty + StrToFloat(GetDelimitedAsciiElement(sLine,',',11));
                   rTotalShortfall := rTotalShortfall + StrToFloat(GetDelimitedAsciiElement(sLine,',',12));
                   iTotalMissing := iTotalMissing + Round(StrToFloat(GetDelimitedAsciiElement(sLine,',',13)));
              end;

              Inc(iRowsProcessed);

        until Eof(InFile);

        Result := FloatToStr(rTotalScore / iRowsProcessed) + ',' +
                  FloatToStr(rTotalCost / iRowsProcessed) + ',' +
                  FloatToStr(iTotalPUs / iRowsProcessed) + ',' +
                  FloatToStr(rTotalBoundary / iRowsProcessed) + ',' +
                  FloatToStr(rTotalPenalty / iRowsProcessed) + ',' +
                  FloatToStr(rTotalShortfall / iRowsProcessed) + ',' +
                  FloatToStr(iTotalMissing / iRowsProcessed);

        closefile(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReturnCalibrationResultText',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure CollectNextCalibrationResult;
var
   CalibrationResultFile : TextFile;
   sOutputDirectoryName : string;
begin
     try
        sOutputDirectoryName := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) + 'output\';

        // write a graphic for this results map to a BMP file
        GIS_Child.SaveMapToBmpFile(sOutputDirectoryName + 'map' + IntToStr(iCurrentCalibrationNumber) + '.BMP');

        // write a row to the collected output file with this runs results
        if (iCurrentCalibrationNumber = 1) then
        begin
             assignfile(CalibrationResultFile,sOutputDirectoryName + 'calibrate.csv');
             rewrite(CalibrationResultFile);
             //writeln(CalibrationResultFile,'test,' + sCalibrationVariable + ',Score,Cost,Planning Units,Boundary Length,Penalty,Probability,Shortfall,Missing Values');
             writeln(CalibrationResultFile,'test,' + sCalibrationVariable + ',Score,Cost,Planning Units,Boundary Length,Penalty,Shortfall,Missing Values');
        end
        else
        begin
             assignfile(CalibrationResultFile,sOutputDirectoryName + 'calibrate.csv');
             append(CalibrationResultFile);
        end;
        writeln(CalibrationResultFile,IntToStr(iCurrentCalibrationNumber) + ',' + FloatToStr(rCalibrationCurrentValue) + ',' + ReturnCalibrationResultText);

        closefile(CalibrationResultFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CollectNextCalibrationResult',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure DisplayAllCalibrationResults;
begin
     try
        MarxanInterfaceForm.Caption := 'Marxan';
        // display collected output file for all the runs in this calibration
        SCPForm.DisplayMarxanCalibrationReport;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DisplayAllCalibrationResults',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure StartNextCalibrationJob;
var
   rDelta : extended;
begin
     try
        MarxanInterfaceForm.Caption := 'Marxan test ' + IntToStr(iCurrentCalibrationNumber) + ' of ' + IntToStr(iCalibrationNumber);

        rDelta := (rCalibrationMaximum - rCalibrationMinimum) / (iCalibrationNumber - 1);

        if fCalibrationCheckExponent then
           try
              rCalibrationCurrentValue := Exp(rCalibrationMinimum + (rDelta * (iCurrentCalibrationNumber - 1)))
           except
                 rCalibrationCurrentValue := 0;
           end
        else
            rCalibrationCurrentValue := rCalibrationMinimum + (rDelta * (iCurrentCalibrationNumber - 1));

        UpdateValue(iCalibrationInput,rCalibrationCurrentValue);
        MarxanInterfaceForm.UpdateMarxan;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in StartNextCalibrationJob',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure RunCalibration(iInput : integer; sNumber, sMin, sMax, sVariable : string);
begin
     try
        fCalibrationRunning := True;
        iCalibrationNumber := StrToInt(sNumber);
        iCurrentCalibrationNumber := 1;
        iCalibrationInput := iInput;
        rCalibrationMinimum := StrToFloat(sMin);
        rCalibrationMaximum := StrToFloat(sMax);
        sCalibrationVariable := sVariable;
        fCalibrationCheckExponent := CalibrationForm.CheckExponent.Checked;

        StoreInputDatFiles;

        StartNextCalibrationJob;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RunCalibration',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TCalibrationForm.BitBtn1Click(Sender: TObject);
begin
     RunCalibration(RadioInput.ItemIndex,EditNumber.Text,EditMin.Text,EditMax.Text,
                    CalibrationForm.RadioInput.Items.Strings[CalibrationForm.RadioInput.ItemIndex]);
end;

procedure TCalibrationForm.UpdateMemoExponent;
var
   iCalibration : integer;
   rValue, rCalibration, rDelta : extended;
begin
     try
        if CheckExponent.Checked then
        begin
             MemoExponent.Visible := True;

             MemoExponent.Lines.Clear;

             for iCalibration := 1 to StrToInt(EditNumber.Text) do
             begin

                  rDelta := (StrToFloat(EditMax.Text) - StrToFloat(EditMin.Text)) / (StrToInt(EditNumber.Text) - 1);

                  try
                     rValue := StrToFloat(EditMin.Text) + (rDelta * (iCalibration - 1));
                     rCalibration := Exp(rValue);
                     
                  except
                        rCalibration := 0;
                  end;

                  MemoExponent.Lines.Add('value ' + FloatToStr(rValue) + ' exponent ' + FloatToStr(rCalibration));
             end;
        end
        else
            MemoExponent.Visible := False;

     except
           MemoExponent.Lines.Clear;
           MemoExponent.Visible := False;
     end;
end;

procedure TCalibrationForm.CheckExponentClick(Sender: TObject);
begin
     UpdateMemoExponent;
end;

procedure TCalibrationForm.EditNumberChange(Sender: TObject);
begin
     UpdateMemoExponent;
end;

procedure TCalibrationForm.EditMinChange(Sender: TObject);
begin
     UpdateMemoExponent;
end;

procedure TCalibrationForm.EditMaxChange(Sender: TObject);
begin
     UpdateMemoExponent;
end;

end.
