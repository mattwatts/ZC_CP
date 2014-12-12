unit pi_calc;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, Spin, ExtCtrls;

type
  TForm1 = class(TForm)
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    btnCalculate: TButton;
    BitBtn1: TBitBtn;
    Label2: TLabel;
    lblPoints: TLabel;
    Label4: TLabel;
    lblPi: TLabel;
    Label3: TLabel;
    lblFired: TLabel;
    Timer1: TTimer;
    btnPause: TButton;
    btnImport: TButton;
    OpenDialog1: TOpenDialog;
    Timer2: TTimer;
    procedure btnCalculateClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     iTotalPoints, iTotalInQuadrant : currency;
  end;

var
  Form1: TForm1;

implementation

uses
    inifiles;

{$R *.DFM}

procedure AppendPiOutput;
var
   OutputFile : TextFile;
   sOutputFile : string;
begin
     sOutputFile := 'c:\pi_output.csv';
     if fileexists(sOutputFile) then
     begin
          assignfile(OutputFile,sOutputFile);
          append(OutputFile);
     end
     else
     begin
          assignfile(OutputFile,sOutputFile);
          rewrite(OutputFile);
          writeln(OutputFile,'Date&Time,TotalPoints,TotalInQuadrant,pi');
     end;
     writeln(OutputFile,FormatDateTime('ddd mmm d yyyy  hh:mm AM/PM',Now) + ',' +
                        FloatToStr(Form1.iTotalPoints) + ',' +
                        FloatToStr(Form1.iTotalInQuadrant) + ',' +
                        Form1.lblPi.Caption);
     closefile(OutputFile);
end;

procedure WriteValuesToIni;
var
   AIni : TIniFile;
begin
     // store the values
     AIni := TIniFile.Create('c:\pi_calculation.txt');
     AIni.WriteString('pi','TotalPoints',FloatToStr(Form1.iTotalPoints));
     AIni.WriteString('pi','TotalInQuadrant',FloatToStr(Form1.iTotalInQuadrant));
     AIni.WriteString('pi','pi',Form1.lblPi.Caption);
     AIni.Free;

     try
        AIni := TIniFile.Create('d:\software\pi_calc\pi_calculation.txt');

        AIni.WriteString('pi','TotalPoints',FloatToStr(Form1.iTotalPoints));
        AIni.WriteString('pi','TotalInQuadrant',FloatToStr(Form1.iTotalInQuadrant));
        AIni.WriteString('pi','pi',Form1.lblPi.Caption);
        AIni.Free;
     except
     end;
end;

procedure ReadValuesFromIni;
var
   AIni : TIniFile;
begin
     AIni := TIniFile.Create('c:\pi_calculation.txt');
     Form1.iTotalPoints := StrToFloat(AIni.ReadString('pi','TotalPoints','0'));
     Form1.iTotalInQuadrant := StrToFloat(AIni.ReadString('pi','TotalInQuadrant','0'));
     Form1.lblPi.Caption := AIni.ReadString('pi','pi','0');
     AIni.Free;
end;

procedure ImportValuesFromIni(const sIni : string;
                              Sender: TObject);
var
   AIni : TIniFile;
   iValue : currency;
begin
     if not Form1.Timer1.Enabled then
     begin
          AIni := TIniFile.Create(sIni);
          iValue := StrToFloat(AIni.ReadString('pi','TotalPoints','0'));
          Form1.iTotalPoints := Form1.iTotalPoints + iValue;
          iValue := StrToFloat(AIni.ReadString('pi','TotalInQuadrant','0'));
          Form1.iTotalInQuadrant := Form1.iTotalInQuadrant + iValue;
          //Form1.lblPi.Caption := AIni.ReadString('pi','pi','0');
          AIni.Free;

          Form1.Timer1Timer(Sender);
     end;
end;

function CalculatePi(const iPoints : integer;
                      var iTotalPoints, iTotalInQuadrant : currency) : extended;
var
   iCount, iInQuadrant : integer;
   rX, rY :extended;
begin
     iInQuadrant := 0;

     for iCount := 1 to iPoints do
     begin
          rX := random;
          rY := random;
          if (((rX*rX) + (rY*rY)) <= 1) then
             Inc(iInQuadrant);
         // x + y <= 1 means in quadrant
     end;

     iTotalPoints := iTotalPoints + iPoints;
     iTotalInQuadrant := iTotalInQuadrant + iInQuadrant;

     // calculate pi based on ratio of points in and out of the circle
     Result := 4 * iTotalInQuadrant / iTotalPoints;
end;



procedure TForm1.btnCalculateClick(Sender: TObject);
begin
     if not Timer1.Enabled then
     begin
          iTotalPoints := 0;
          iTotalInQuadrant := 0;

          ReadValuesFromIni;
          lblFired.Caption := FloatToStr(iTotalPoints);
          lblPoints.Caption := FloatToStr(iTotalInQuadrant);

          Randomize;

          Timer1.Enabled := True;
     end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
     lblPi.Caption := FloatToStr(CalculatePi(SpinEdit1.Value,
                                             iTotalPoints, iTotalInQuadrant));

     lblFired.Caption := FloatToStr(iTotalPoints);
     lblPoints.Caption := FloatToStr(iTotalInQuadrant);
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
     Timer1.Enabled := False;

     WriteValuesToIni;

     AppendPiOutput;

     Application.Terminate;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     btnCalculateClick(Sender);
end;

procedure TForm1.btnPauseClick(Sender: TObject);
begin
     Timer1.Enabled := False;

     WriteValuesToIni;

     AppendPiOutput;
end;

procedure TForm1.btnImportClick(Sender: TObject);
begin
     if not Form1.Timer1.Enabled then
        if OpenDialog1.Execute then
           ImportValuesFromIni(OpenDialog1.Filename,Sender);
end;



procedure TForm1.Timer2Timer(Sender: TObject);
begin
     // autosave result
     // every 7200000 milliseconds
     // (which is 2 hours)
     AppendPiOutput;
end;

end.
