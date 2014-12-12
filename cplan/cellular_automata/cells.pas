unit cells;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TCAForm = class(TForm)
    Panel1: TPanel;
    Image2: TImage;
    Image1: TImage;
    btnInitLeft: TButton;
    btnInitRight: TButton;
    btnRule54Left: TButton;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnInitLeftClick(Sender: TObject);
    procedure btnInitRightClick(Sender: TObject);
    procedure btnRule54LeftClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CAForm: TCAForm;

implementation

{$R *.DFM}

procedure TCAForm.FormResize(Sender: TObject);
begin
     Image1.Width := Width div 2;
     Image2.Width := Image1.Width;
end;


procedure TCAForm.FormCreate(Sender: TObject);
begin
     Randomize;
end;

function InitImage(TheImage : TImage) : boolean;
var
   iRow, iCol : integer;
begin
     //
     for iRow := 0 to (TheImage.Height-1) do
         for iCol := 0 to (TheImage.Width-1) do
             if (Random > 0.5) then
                TheImage.Canvas.Pixels[iCol,iRow] := clWhite
             else
                 TheImage.Canvas.Pixels[iCol,iRow] := clBlack;
     Result := True;
end;

procedure ProcessRule54(TheImage : TImage);
var
   iRow, iCol : integer;
   fUpdate : boolean;
begin
     //
     for iRow := 0 to (TheImage.Height-1) do
     begin
          for iCol := 1 to (TheImage.Width-2) do
          begin
               fUpdate := False;
              if (TheImage.Canvas.Pixels[iCol,iRow] = clWhite)
              and (TheImage.Canvas.Pixels[iCol-1,iRow] = clWhite)
              and (TheImage.Canvas.Pixels[iCol+1,iRow] = clWhite) then
              begin
                   TheImage.Canvas.Pixels[iCol,iRow] := clWhite;
                   fUpdate := True;
              end;

              if (TheImage.Canvas.Pixels[iCol,iRow] = clBlack)
              and ((TheImage.Canvas.Pixels[iCol-1,iRow] = clBlack)
                   or (TheImage.Canvas.Pixels[iCol+1,iRow] = clBlack)) then
              begin
                   TheImage.Canvas.Pixels[iCol,iRow] := clBlack;
                   fUpdate := True;
              end;

              if not fUpdate then
                 TheImage.Canvas.Pixels[iCol,iRow] := clBlack;
          end;
     end;
end;

procedure TCAForm.btnInitLeftClick(Sender: TObject);
begin
     InitImage(Image1);
end;

procedure TCAForm.btnInitRightClick(Sender: TObject);
begin
     InitImage(Image2);
end;

procedure TCAForm.btnRule54LeftClick(Sender: TObject);
begin
     ProcessRule54(Image1);
end;

end.
