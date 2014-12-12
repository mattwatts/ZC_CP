unit jaz1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TForm1 = class(TForm)
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure PaintImage;
    procedure Image1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
     // paint the image a random color
     randomize;
     Image1.Height := Height;
     Image1.Width := Width;
     //Image1.Align := alClient;
     PaintImage;
end;

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


procedure TForm1.PaintImage;
var
   MyRect : TRect;
begin
     {Image1.Height := Height;
     Image1.Width := Width;
     MyRect := Rect(0,0,(Image1.Width-1)
                    ,(Image1.Height-1));

     Image1.Canvas.Brush.Color := rtnRandomColour;
     Image1.Canvas.FillRect(MyRect);}
     Form1.Color := rtnRandomColour;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
     PaintImage;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     PaintImage;
end;

end.
