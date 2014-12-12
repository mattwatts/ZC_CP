unit Dstest;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;


implementation
uses
    datastru, arrayt;
{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
     oDSDebug.testing;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
     close;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
     _testarr_.testing;
{      arraydebug.showmodal;
      arraydebug.close;           }
end;

end.
