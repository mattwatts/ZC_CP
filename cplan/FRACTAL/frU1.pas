unit frU1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ExtDlgs, Menus, StdCtrls;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    OpenPictureDialog1: TOpenPictureDialog;
    SavePictureDialog1: TSavePictureDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Image1: TImage;
    Image2: TImage;
    Panel3: TPanel;
    File1: TMenuItem;
    SaveImage11: TMenuItem;
    Save1: TMenuItem;
    LoadLeftImage1: TMenuItem;
    LoadRightImage1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    Process1: TMenuItem;
    FractalIterate1: TMenuItem;
    Start1: TMenuItem;
    End1: TMenuItem;
    Timer1: TTimer;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    RandomizeLeftImage1: TMenuItem;
    Button3: TButton;
    MandlebrotSeries1: TMenuItem;
    N1001: TMenuItem;
    N5001: TMenuItem;
    N10001: TMenuItem;
    WhereItsAt1: TMenuItem;
    Graph1: TMenuItem;
    PatternA1: TMenuItem;
    procedure Exit1Click(Sender: TObject);
    procedure SaveImage11Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure LoadLeftImage1Click(Sender: TObject);
    procedure LoadRightImage1Click(Sender: TObject);
    procedure FractalIterate;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure PatternACanvas(Canvas : TCanvas;
                             const iHeight, iWidth : integer);
    procedure RandomizeCanvas(Canvas : TCanvas;
                              const iHeight, iWidth : integer);
    procedure RandomizeLeftImage1Click(Sender: TObject);
    procedure MandlebrotSeries(Canvas : TCanvas;
                               const iHeight, iWidth, iSeriesLength : integer);
    procedure N1001Click(Sender: TObject);
    procedure N5001Click(Sender: TObject);
    procedure N10001Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure WhereItsAt1Click(Sender: TObject);
    procedure TripOut(Canvas : TCanvas;
                      const iHeight, iWidth : integer);
    procedure DisplayGraph(Canvas : TCanvas;
                           const iHeight, iWidth,
                                 iXLo, iXRange, iYLo, iYRange : integer);
    procedure Graph1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PatternA1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  ComplexNumber_T = record
      iR, iI : integer;
                    end;

var
  Form1: TForm1;
  iIteration : integer;
  sWorkingDirectory : string;

implementation

uses
    inifiles, FileCtrl;
    
{$R *.DFM}

function ComplexNumberMultiply(const C1, C2 : ComplexNumber_T) : ComplexNumber_T;
begin
     // Zr=(Zr*Zr)-(Zi*Zi)+Cr;
     // where C1~Z and C2~C
     result.iR := (C1.iR*C1.iR) - (C1.iI*C1.iI) + C2.iR;
     // Zi=(2*Zr*Zi)+Ci;
     result.iI := (2 * C1.iR * C1.iI) + C2.iI;
end;

function ReadIniPath : string;
var
   FractIni : TIniFile;
begin
     Result := 'c:\fract';

     try
        FractIni := TIniFile.Create('fract.ini');
        Result := FractIni.ReadString('Fract','WorkingDirectory','c:\fract');
        FractIni.Free;
     except
     end;
end;

procedure TForm1.FractalIterate;
begin
     {
      }
     try
        sWorkingDirectory := ReadIniPath;
        ForceDirectories(sWorkingDirectory);
        Timer1.Enabled := True;

     except
           MessageDlg('Exception in FractalIterate',mtError,[mbOk],0);
     end;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
     Application.Terminate;
end;

procedure TForm1.SaveImage11Click(Sender: TObject);
begin
     SavePictureDialog1.Title := 'Save Left Image';
     if SavePictureDialog1.Execute then
        Image1.Picture.SaveToFile(SavePictureDialog1.Filename);
end;

procedure TForm1.Save1Click(Sender: TObject);
begin
     SavePictureDialog1.Title := 'Save Right Image';
     if SavePictureDialog1.Execute then
        Image2.Picture.SaveToFile(SavePictureDialog1.Filename);
end;

procedure TForm1.LoadLeftImage1Click(Sender: TObject);
begin
     OpenPictureDialog1.Title := 'Load Left Image';
     if OpenPictureDialog1.Execute then
        Image1.Picture.LoadFromFile(OpenPictureDialog1.Filename);
end;

procedure TForm1.LoadRightImage1Click(Sender: TObject);
begin
     OpenPictureDialog1.Title := 'Load Left Image';
     if OpenPictureDialog1.Execute then
        Image2.Picture.LoadFromFile(OpenPictureDialog1.Filename);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
     sWorkingDirectory := 'd:\temp\';//ReadIniPath;
     ForceDirectories(sWorkingDirectory);
     iIteration := 1;
     Timer1.Enabled := True;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
     Timer1.Enabled := False;
     label1.Caption := '';
end;

procedure TForm1.PatternACanvas(Canvas : TCanvas;
                                 const iHeight, iWidth : integer);
var
   RandColor : TColor;
   iX, iY, iNumber : integer;
begin
     Randomize;

     for iX := 0 to (iWidth - 1) do
         for iY := 0 to (iHeight - 1) do
         begin
              // value between 1 and 17
              //iNumber := (Round((iX * iX) + (iY * iY)) Mod 17) + 1;
              //iNumber :=  (Round(sin(iX) + sin(iY)) Mod 17) + 1;
              iNumber :=  ((iX + iY) Mod 17) + 1;

              case iNumber of
                1 : RandColor := clAqua;
                2 : RandColor := clBlack;
                3 : RandColor := clBlue;
                4 : RandColor := clDkGray;
                5 : RandColor := clFuchsia;
                6 : RandColor := clGray;
                7 : RandColor := clGreen;
                8 : RandColor := clLime;
                9 : RandColor := clLtGray;
                10 : RandColor := clMaroon;
                11 : RandColor := clNavy;
                12 : RandColor := clOlive;
                13 : RandColor := clPurple;
                14 : RandColor := clRed;
                15 : RandColor := clSilver;
                16 : RandColor := clTeal;
                17 : RandColor := clYellow;
              end;

              Canvas.Pixels[iX,iY] := RandColor;
         end;
end;


procedure TForm1.RandomizeCanvas(Canvas : TCanvas;
                                 const iHeight, iWidth : integer);
var
   RandColor : TColor;
   iX, iY, iRandom : integer;
begin
     Randomize;

     for iX := 0 to (iWidth - 1) do
         for iY := 0 to (iHeight - 1) do
         begin
              iRandom := Random(16) + 1;

              case iRandom of
                1 : RandColor := clAqua;
                2 : RandColor := clBlack;
                3 : RandColor := clBlue;
                4 : RandColor := clDkGray;
                5 : RandColor := clFuchsia;
                6 : RandColor := clGray;
                7 : RandColor := clGreen;
                8 : RandColor := clLime;
                9 : RandColor := clLtGray;
                10 : RandColor := clMaroon;
                11 : RandColor := clNavy;
                12 : RandColor := clOlive;
                13 : RandColor := clPurple;
                14 : RandColor := clRed;
                15 : RandColor := clSilver;
                16 : RandColor := clTeal;
                17 : RandColor := clYellow;
              end;

              Canvas.Pixels[iX,iY] := RandColor;
         end;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
var
   MyRect : TRect;
   iX, iY,
   iNewX, iNewY, iMagnitude, iDepth : integer;
   TempColor : TColor;
   ConstantPoint, OriginalPoint, NewPoint : ComplexNumber_T;
begin
     try
        label1.Caption := 'Calculating Iteration ' + IntToStr(iIteration);
        {make Image2 a blank, white canvas}
        {MyRect := Rect(0,0,(Image1.Width-1)
                       ,(Image1.Height-1));
        Image2.Canvas.Brush.Color := clWhite;
        Image2.Canvas.FillRect(MyRect);
        Refresh;}

        //ConstantPoint.iR := iIteration div 2;
        //ConstantPoint.iI := iIteration div 3;
        ConstantPoint.iR := random(1000);
        ConstantPoint.iI := random(1000);

        {generate a fractal in Image2}
        for iX := 0 to (Image1.Width - 1) do
            for iY := 0 to (Image1.Height - 1) do
                //if (Image1.Canvas.Pixels[iX,iY] <> clWhite) then
                begin
                     {calculate a new colour for this dot}
                     OriginalPoint.iR := iX - (iX div 2);
                     OriginalPoint.iI := iY - (iY div 2);

                     iDepth := 0;
                     repeat
                           NewPoint := ComplexNumberMultiply(OriginalPoint,ConstantPoint);
                           iNewX := NewPoint.iR;
                           iNewY := NewPoint.iI;

                           Inc(iDepth);
                           iMagnitude := ((NewPoint.iR*NewPoint.iR)+(NewPoint.iI*NewPoint.iI))

                     until (iMagnitude > 4) or (iDepth > 100);

                     //if (iDepth > 4) then
                     if (iDepth > 100) then
                        TempColor := clBlack
                     else
                         // let magnitude determine the color
                         TempColor := iMagnitude;

                     //Image2.Canvas.Pixels[iX + (iX div 2),iY + (iY div 2)] := TempColor;
                     Image1.Canvas.Pixels[iX,iY] := TempColor;
                end;


        {copy the contents of Image2 to Image1}
        //Image1.Picture := Image2.Picture;

        // save the image to a file
        //Image2.Picture.SaveToFile(sWorkingDirectory + '\image' + IntToStr(iIteration) + '.bmp');

        Inc(iIteration);

     except
           MessageDlg('Exception in Timer Tick',
                      mtError,[mbOk],0);
     end;
end;

procedure TForm1.RandomizeLeftImage1Click(Sender: TObject);
begin
     Screen.Cursor := crHourglass;

     RandomizeCanvas(Image1.Canvas,
                     Image1.Height,
                     Image1.Width);

     Screen.Cursor := crDefault;
end;

procedure TForm1.MandlebrotSeries(Canvas : TCanvas;
                                  const iHeight, iWidth, iSeriesLength : integer);
var
   iX, iY, iCount : integer;
begin
     try
     Screen.Cursor := crHourglass;
     {}
     iX := 1;
     iY := 1;
     Canvas.Pixels[iX,iY] := clBlack;

     {generate the Mandlebrot series of a given length}
     for iCount := 1 to iSeriesLength do
     begin
          iX := 1;
          iY := 1;

          iX := (iY * iY) - (iX * iX);
          if (iX < 0) then
             repeat
                   iX := iX + iWidth;
             until (iX >= 0);
          if (iX >= iWidth) then
             iX := iX mod iWidth;

          iY := -2 * iY * iX;
          if (iY < 0) then
             repeat
                   iY := iY + iHeight;
             until (iY >= 0);
          if (iY >= iHeight) then
             iY := iY mod iHeight;

          Canvas.Pixels[iX,iY] := clBlack;
     end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in MandlebrotSeries',mtError,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
end;

procedure TForm1.TripOut(Canvas : TCanvas;
                         const iHeight, iWidth : integer);
var
   iX, iY, iX_, iY_, iCount, iSeriesLength, iSegment, iLength : integer;
   AColor : TColor;

   function rtnRandomColour : TColor;
   begin
        case random(18) of
             0 : Result := clAqua;
             1 : Result := clBlack;
             2 : Result := clBlue;
             3 : Result := clDkGray;
             4 : Result := clFuchsia;
             5 : Result := clGray;
             6 : Result := clGreen;
             7 : Result := clLime;
             8 : Result := clLtGray;
             9 : Result := clMaroon;
             10 : Result := clNavy;
             11 : Result := clOlive;
             12 : Result := clPurple;
             13 : Result := clRed;
             14 : Result := clSilver;
             15 : Result := clTeal;
             16 : Result := clWhite;
             17 : Result := clYellow;
        end;
   end;

begin
     try
     Screen.Cursor := crHourglass;
     {}
     iX := 1;
     iY := 1;
     //Canvas.Pixels[iX,iY] := clBlack;

     Randomize;

     iSeriesLength := (iWidth * iHeight) div 2;//1000;//(iWidth * iHeight) div 2;

     iLength := 10;

     {generate the Mandlebrot series of a given length}
     for iCount := 1 to iSeriesLength do
     begin
          // draw a square with length iLength
          iX := Random(iWidth);
          iY := Random(iHeight);
          if (iX + iLength) > iWidth then
          begin
               if (iY + iLength) > iHeight then
               begin
                    AColor := rtnRandomColour;
                    for iX_ := iX downto (iX - iLength) do
                        Canvas.Pixels[iX_,iY] := AColor;
                    for iX_ := iX downto (iX - iLength) do
                        Canvas.Pixels[iX_,iY - iLength] := AColor;
                    for iY_ := iY downto (iY - iLength) do
                        Canvas.Pixels[iX,iY_] := AColor;
                    for iY_ := iY downto (iY - iLength) do
                        Canvas.Pixels[iX - iLength,iY_] := AColor;
               end
               else
               begin
                    AColor := rtnRandomColour;
                    for iX_ := iX downto (iX - iLength) do
                        Canvas.Pixels[iX_,iY] := AColor;
                    for iX_ := iX downto (iX - iLength) do
                        Canvas.Pixels[iX_,iY - iLength] := AColor;
                    for iY_ := iY to (iY + iLength) do
                        Canvas.Pixels[iX,iY_] := AColor;
                    for iY_ := iY to (iY + iLength) do
                        Canvas.Pixels[iX - iLength,iY_] := AColor;
               end;
          end
          else
          begin
               if (iY + iLength) > iHeight then
               begin
                    AColor := rtnRandomColour;
                    for iX_ := iX downto (iX - iLength) do
                        for iY_ := iY downto (iY - iLength) do
                            Canvas.Pixels[iX_,iY_] := AColor;
                    for iX_ := iX downto (iX - iLength) do
                        Canvas.Pixels[iX_,iY] := AColor;
                    for iX_ := iX downto (iX - iLength) do
                        Canvas.Pixels[iX_,iY - iLength] := AColor;
                    for iY_ := iY downto (iY - iLength) do
                        Canvas.Pixels[iX,iY_] := AColor;
                    for iY_ := iY downto (iY - iLength) do
                        Canvas.Pixels[iX - iLength,iY_] := AColor;
               end
               else
               begin
                    AColor := rtnRandomColour;
                    for iX_ := iX downto (iX - iLength) do
                        for iY_ := (iY - iLength) to iY do
                            Canvas.Pixels[iX_,iY_] := AColor;
                    for iX_ := iX downto (iX - iLength) do
                        Canvas.Pixels[iX_,iY] := AColor;
                    for iX_ := iX downto (iX - iLength) do
                        Canvas.Pixels[iX_,iY - iLength] := AColor;
                    for iY_ := iY downto (iY - iLength) do
                        Canvas.Pixels[iX,iY_] := AColor;
                    for iY_ := iY downto (iY - iLength) do
                        Canvas.Pixels[iX - iLength,iY_] := AColor;
               end;
          end;
     end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in MandlebrotSeries',mtError,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
end;

procedure TForm1.N1001Click(Sender: TObject);
begin
     MandlebrotSeries(Image1.Canvas,
                      Image1.Height,
                      Image1.Width,
                      100);
end;

procedure TForm1.N5001Click(Sender: TObject);
begin
     MandlebrotSeries(Image1.Canvas,
                      Image1.Height,
                      Image1.Width,
                      500);
end;

procedure TForm1.N10001Click(Sender: TObject);
begin
     MandlebrotSeries(Image1.Canvas,
                      Image1.Height,
                      Image1.Width,
                      1000000);
end;

procedure TForm1.FormResize(Sender: TObject);
begin
{     Panel2.Height := Panel1.Height;
     Panel2.Width := Panel1.Width;

     Image2.Height := Image1.Height;
     Image2.Width := Image1.Width;}
end;

procedure TForm1.WhereItsAt1Click(Sender: TObject);
begin
     // Where Its At
     TripOut(Image1.Canvas,
             Image1.Height,
             Image1.Width);
end;

procedure TForm1.DisplayGraph(Canvas : TCanvas;
                              const iHeight, iWidth,
                                    iXLo, iXRange, iYLo, iYRange : integer);
var
   iX, iY, iX_, iY_, iCount, iSeriesLength, iSegment, iLength : integer;
   AColor : TColor;

   function rtnRandomColour : TColor;
   begin
        case random(18) of
             0 : Result := clAqua;
             1 : Result := clBlack;
             2 : Result := clBlue;
             3 : Result := clDkGray;
             4 : Result := clFuchsia;
             5 : Result := clGray;
             6 : Result := clGreen;
             7 : Result := clLime;
             8 : Result := clLtGray;
             9 : Result := clMaroon;
             10 : Result := clNavy;
             11 : Result := clOlive;
             12 : Result := clPurple;
             13 : Result := clRed;
             14 : Result := clSilver;
             15 : Result := clTeal;
             16 : Result := clWhite;
             17 : Result := clYellow;
        end;
   end;

begin
     try
        Screen.Cursor := crHourglass;
        {}
        iX := 1;
        iY := 1;
        //Canvas.Pixels[iX,iY] := clBlack;

        // iHeight, iWidth,
        // iXLo, iXRange, iYLo, iYRange

        for iCount := 0 to (iWidth-1) do
        begin
             Canvas.Pixels[iCount,0] := clBlack;
             Canvas.Pixels[iCount,iHeight-1] := clBlack;
             Canvas.Pixels[iCount,2] := clBlack;
             Canvas.Pixels[iCount,iHeight-3] := clBlack;
             Canvas.Pixels[iCount,4] := clBlack;
             Canvas.Pixels[iCount,iHeight-5] := clBlack;
             Canvas.Pixels[iCount,5] := clBlack;
             Canvas.Pixels[iCount,iHeight-7] := clBlack;
        end;

        for iCount := 0 to (iHeight-1) do
        begin
             Canvas.Pixels[0,iCount] := clBlack;
             Canvas.Pixels[iWidth-1,iCount] := clBlack;
             Canvas.Pixels[2,iCount] := clBlack;
             Canvas.Pixels[iWidth-3,iCount] := clBlack;
             Canvas.Pixels[4,iCount] := clBlack;
             Canvas.Pixels[iWidth-5,iCount] := clBlack;
             Canvas.Pixels[6,iCount] := clBlack;
             Canvas.Pixels[iWidth-7,iCount] := clBlack;
        end;


     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DisplayGraph',mtError,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
end;

procedure TForm1.Graph1Click(Sender: TObject);
begin
     DisplayGraph(Image1.Canvas,
                  Image1.Height,
                  Image1.Width,
                  -1,2,-1,2);
                  //iXLo, iXRange, iYLo, iYRange
end;

procedure TForm1.FormShow(Sender: TObject);
begin
     //RandomizeLeftImage1Click(Sender);
     //Button1Click(Sender);
end;

procedure TForm1.PatternA1Click(Sender: TObject);
begin   
     Screen.Cursor := crHourglass;

     PatternACanvas(Image1.Canvas,
                    Image1.Height,
                    Image1.Width);

     Screen.Cursor := crDefault;
end;

end.
