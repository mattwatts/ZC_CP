unit DSCanvas;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

procedure drawCircle(x,y,radius : longint);
procedure drawArc(x1,y1,x2,y2 : longint);
procedure writetext(x,y : longint; sz : string);
implementation

{$R *.DFM}

procedure TForm2.Button1Click(Sender: TObject);
begin
     form2.canvas.ellipse(0,0,75,75);
end;

procedure drawCircle(x,y,radius : longint);
begin
     form2.Canvas.ellipse(x-radius,y-radius,x+radius,y+radius);
end;

procedure drawArc(x1,y1,x2,y2 : longint);
begin
          form2.Canvas.arc(x1,y1,x2,y2,x1,y1,x2,y2);
end;

procedure writetext(x,y : longint; sz : string);
begin
     form2.canvas.textout(x,y,sz);
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
     form2.Canvas.arc(50,25,50,75,50,25,50,75);
end;

end.

