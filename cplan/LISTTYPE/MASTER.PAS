unit Master;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs,arraydef, StdCtrls;

type
  TForm2 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
   t : array_t;
   infile : file;
implementation

{$R *.DFM}
procedure loadarray;
var
   x,y : integer;
   inarray : array[1..1000] of word;
   PASS : LONGINT;

begin
     assignfile(infile,'c:\data\bird1km.mat');
     reset(infile,2);
     for x := 1 to 10 do
     begin
          blockread(infile,inarray[1],1000);
          for y := 1 to 1000 do
          begin
               pass := (x-1);
               pass := pass*1000;
               inc(pass,y);
               t.setvalue(pass,@inarray[y])
          end;
     end;
end;

procedure TForm2.Button1Click(Sender: TObject);
var
   x,z : longint;
   a,y : word;
begin
     new(t);
     t.init(sizeof(word),100);
     for a := 1 to 100 do
     begin
          t.setvalue(a,@a);
     end;
     for x := 1 to 100 do
     begin
          t.rtnvalue(x,@y);
          writeln(y);
     end;
     t.resize(200);
     for a := 101 to 200 do
     begin
          t.setvalue(a,@a);
     end;
     for x := 1 to 200 do
     begin
          t.rtnvalue(x,@y);
          writeln(y);
     end;
     x := 7;
     y := 0;
     loadarray;
     for x := 1 to 1000 do
     begin
          z := random(10000);
          inc(z);
          t.rtnValue(z,@y);
          seek(infile,z-1);
          blockread(infile,a,1);
          if a <> y then
          begin
               messagedlg('array error',mterror,[mbok],0);
            {   halt;}
          end;
     end;
     t.resize(80);
     t.resize(500000);

z := 1;
t.setvalue(400000,@z);

  for x := 1 to 1000 do
     begin
          z := random(80);
          inc(z);
          t.rtnValue(z,@y);
          seek(infile,z-1);
          blockread(infile,a,1);
          if a <> y then
             messagedlg('array error z = '+inttostr(z),mterror,[mbok],0);
     end;
end;

end.
