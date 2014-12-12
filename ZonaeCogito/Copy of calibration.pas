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
    procedure BitBtn1Click(Sender: TObject);
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

uses Marxan_interface, FileCtrl, Miscellaneous;

{$R *.DFM}

procedure StoreInputDatFiles;
var
   sBaseDirectory : string;
begin
     sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);

     ForceDirectories(sBaseDirectory + 'backup');

     CopyIfExists('input.dat',sBaseDirectory,sBaseDirectory + 'backup');
     CopyIfExists('zoneboundcost.dat',sBaseDirectory + 'input',sBaseDirectory + 'backup');
     CopyIfExists('spec.dat',sBaseDirectory + 'input',sBaseDirectory + 'backup');
     CopyIfExists('zonetarget.dat',sBaseDirectory + 'input',sBaseDirectory + 'backup');
     CopyIfExists('zonecost.dat',sBaseDirectory + 'input',sBaseDirectory + 'backup');
end;

procedure RetrieveInputDatFiles;
var
   sBaseDirectory : string;
begin
     sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);

     CopyIfExists('input.dat',sBaseDirectory + 'backup',sBaseDirectory );
     CopyIfExists('zoneboundcost.dat',sBaseDirectory + 'backup',sBaseDirectory + 'input');
     CopyIfExists('spec.dat',sBaseDirectory + 'backup',sBaseDirectory + 'input');
     CopyIfExists('zonetarget.dat',sBaseDirectory + 'backup',sBaseDirectory + 'input');
     CopyIfExists('zonecost.dat',sBaseDirectory + 'backup',sBaseDirectory + 'input');
     DeleteFile(sBaseDirectory + 'backup\input.dat');
     DeleteFile(sBaseDirectory + 'backup\zoneboundcost.dat');
     DeleteFile(sBaseDirectory + 'backup\spec.dat');
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

           if (Pos('BLM',UpperCase(sInputLine)) > 0) then
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

           if (Pos('PROBABILITYWEIGHTING',UpperCase(sInputLine)) > 0) then
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
   sBaseDirectory, sInputLine : string;
   InputFile, OutputFile : TextFile;
begin
     sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);

     CopyIfExists('zoneboundcost.dat',sBaseDirectory + 'backup',sBaseDirectory + 'input');

     assignfile(InputFile,sBaseDirectory + 'input\zoneboundcost.dat');
     reset(InputFile);
     assignfile(OutputFile,sBaseDirectory + 'input\zoneboundcost.dat~');
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

     deletefile(sBaseDirectory + 'input\zoneboundcost.dat');
     Acopyfile(sBaseDirectory + 'input\zoneboundcost.dat~',sBaseDirectory + 'input\zoneboundcost.dat');
end;

procedure UpdateTargetFile(rValue : extended);
var
   sBaseDirectory, sInputLine : string;
   InputFile, OutputFile : TextFile;
begin
     sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);

     CopyIfExists('spec.dat',sBaseDirectory + 'backup',sBaseDirectory + 'input');

     assignfile(InputFile,sBaseDirectory + 'input\spec.dat');
     reset(InputFile);
     assignfile(OutputFile,sBaseDirectory + 'input\spec.dat~');
     rewrite(OutputFile);

     readln(InputFile,sInputLine);
     writeln(OutputFile,sInputLine);

     repeat
           readln(InputFile,sInputLine);

           writeln(OutputFile,GetDelimitedAsciiElement(sInputLine,',',1) + ',' +
                              FloatToStr(StrToFloat(GetDelimitedAsciiElement(sInputLine,',',2)) * rValue) + ',' +
                              FloatToStr(StrToFloat(GetDelimitedAsciiElement(sInputLine,',',3)) * rValue) + ',' +
                              GetDelimitedAsciiElement(sInputLine,',',4) + ',' +
                              GetDelimitedAsciiElement(sInputLine,',',5));

     until Eof(InputFile);

     closefile(InputFile);
     closefile(OutputFile);

     deletefile(sBaseDirectory + 'input\spec.dat');
     Acopyfile(sBaseDirectory + 'input\spec.dat~',sBaseDirectory + 'input\spec.dat');
end;

procedure UpdateZoneTargetFile(rValue : extended);
var
   sBaseDirectory, sInputLine : string;
   InputFile, OutputFile : TextFile;
begin
     sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);

     CopyIfExists('zonetarget.dat',sBaseDirectory + 'backup',sBaseDirectory + 'input');

     assignfile(InputFile,sBaseDirectory + 'input\zonetarget.dat');
     reset(InputFile);
     assignfile(OutputFile,sBaseDirectory + 'input\zonetarget.dat~');
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

     deletefile(sBaseDirectory + 'input\zonetarget.dat');
     Acopyfile(sBaseDirectory + 'input\zonetarget.dat~',sBaseDirectory + 'input\zonetarget.dat');
end;

procedure UpdateCostFile(rValue : extended);
var
   sBaseDirectory, sInputLine : string;
   InputFile, OutputFile : TextFile;
begin
     sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);

     CopyIfExists('zonecost.dat',sBaseDirectory + 'backup',sBaseDirectory + 'input');

     assignfile(InputFile,sBaseDirectory + 'input\zonecost.dat');
     reset(InputFile);
     assignfile(OutputFile,sBaseDirectory + 'input\zonecost.dat~');
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

     deletefile(sBaseDirectory + 'input\zonecost.dat');
     Acopyfile(sBaseDirectory + 'input\zonecost.dat~',sBaseDirectory + 'input\zonecost.dat');
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
           UpdateTargetFile(rValue);
        if (iInput = 3) then
           // update target file
           UpdateZoneTargetFile(rValue);
        if (iInput = 4) then
           // update cost file
           UpdateCostFile(rValue);
        if (iInput = 5) then
           UpdateProbabilityWeightingParameter(rValue);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in UpdateValue',mtError,[mbOk],0);
     end;
end;

function ReturnCalibrationResultText : string;
var
   InFile : TextFile;
   sInFile, sLine : string;
   rTotalCost, rTotalScore, rBoundary, rTotalBoundary, rTotalPenalty, rTotalShortfall : extended;  //  , rTotalProbability
   iTotalPUs, iTotalMissing, iRowsProcessed, iPUs, iPUsR2, iPUsR3,iAdder : integer;
begin
     // read output_sum.txt file and calculate average cost (column 3)
     // comma delimited ascii
     // ExtractFilePath(EditMarxanDatabasePath.Text) + 'output\output_sum.txt'

     try
        sInFile := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) + 'output\output_sum.txt';
        if not fileexists(sInFile) then
           sInFile := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) + 'output\output_sum.csv';
        assignfile(InFile,sInFile);
        reset(InFile);
        readln(InFile,sLine);

        iAdder := CountDelimitersInRow(sLine,',') - 7;

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
              iTotalPUs := iTotalPUs + StrToInt(GetDelimitedAsciiElement(sLine,',',4));
              rTotalBoundary := rTotalBoundary + StrToFloat(GetDelimitedAsciiElement(sLine,',',5+iAdder));
              rTotalPenalty := rTotalPenalty + StrToFloat(GetDelimitedAsciiElement(sLine,',',6+iAdder));
              //rTotalProbability := rTotalProbability + StrToFloat(GetDelimitedAsciiElement(sLine,',',7));
              rTotalShortfall := rTotalShortfall + StrToFloat(GetDelimitedAsciiElement(sLine,',',7+iAdder));
              iTotalMissing := iTotalMissing + StrToInt(GetDelimitedAsciiElement(sLine,',',8+iAdder));

              Inc(iRowsProcessed);

        until Eof(InFile);

        Result := FloatToStr(rTotalScore / iRowsProcessed) + ',' +
                  FloatToStr(rTotalCost / iRowsProcessed) + ',' +
                  FloatToStr(iTotalPUs / iRowsProcessed) + ',' +
                  FloatToStr(rTotalBoundary / iRowsProcessed) + ',' +
                  FloatToStr(rTotalPenalty / iRowsProcessed) + ',' +
                  //FloatToStr(rTotalProbability / iRowsProcessed) + ',' +
                  FloatToStr(rTotalShortfall / iRowsProcessed) + ',' +
                  FloatToStr(iTotalMissing / iRowsProcessed);

        closefile(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in UpdateValue',mtError,[mbOk],0);
     end;
end;

procedure CollectNextCalibrationResult;
var
   CalibrationResultFile : TextFile;
   sOutputDirectoryName : string;
begin
     try
        sOutputDirectoryName := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) + 'output\';

        // write a graphic for this results map to a JPG file
        MarxanInterfaceForm.SaveArc3Map(sOutputDirectoryName + 'map' + IntToStr(iCurrentCalibrationNumber) + '.JPG');

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
     end;
end;

procedure DisplayAllCalibrationResults;
begin
     try
        MarxanInterfaceForm.Caption := 'Marxan';
        // display collected output file for all the runs in this calibration
        MarxanInterfaceForm.DisplayReport(ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text) + 'output\calibrate.csv');

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DisplayAllCalibrationResults',mtError,[mbOk],0);
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
     end;
end;

procedure TCalibrationForm.BitBtn1Click(Sender: TObject);
begin
     RunCalibration(RadioInput.ItemIndex,EditNumber.Text,EditMin.Text,EditMax.Text,
                    CalibrationForm.RadioInput.Items.Strings[CalibrationForm.RadioInput.ItemIndex]);
end;

end.
