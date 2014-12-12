unit Tester;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls,DS;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Button6: TButton;
    Button7: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

  SLL : LinkedList;
  FDS : Fractal;
  Tree : trees;
  testeye : fractaleye;

implementation
uses
    OS_Lims,StdFctns,timer,DSCanvas;
{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
   l : longint;
   mem : array[1..10] of longint;
   testNode : Node;

begin
mem[1] := memavail;
testNode := Node.createlinked(1);
TestNode.destroy;

mem[2] := memavail;
CompareMemUsed(mem[1],mem[2],'SLL Test Button');
     SLL := LinkedList.create;
     SLL.modify(4);
     Sll.insertAfter;
     Sll.destroy;
mem[3] := memavail;
CompareMemUsed(mem[2],mem[3],'SLL Test Button');
     SLL := LinkedList.create;
     SLL.modify(4);
     Sll.insertBefore;
     SLL.modify(3);
     Sll.moveNode(cStart);
     Sll.insertAfter;
     SLL.modify(5);
     Sll.moveNode(-1);
     Sll.insertBefore;
     SLL.modify(6);
     Sll.insertAfter;
     Sll.Modify(7);
     Sll.draw;
     Sll.destroy;
mem[4] := memavail;
CompareMemUsed(mem[3],mem[4],'Sll Test Button');

end;

procedure test;
begin
     messagedlg('it works',mtinformation,[mbok],0);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
   testNode : FractalNode;
   l : longint;
   mem : array[1..10] of longint;
   testfile : file of word;
   szfilename : string;
   xRng,yRng : longint;

   screen : TwoDimData;
   startscreen : square_t;
   value : longint;
   wd : word;

   x,y : longint;

   ddata : dimensiondata;
   p : integer;
begin
     szfilename := edit1.text;
     xRng := strtoint(edit2.text);
     yRng := strtoint(edit3.text);

     screen := TwoDimData.create;

     StartScreen.x1 := 1;
     StartScreen.y1 := 1;
     StartScreen.x2 := 8;
     StartScreen.y2 := 8;



mem[1] := memavail;
ddata.links := 2;
TestNode := FractalNode.create(ddata);
TestNode.destroy;
mem[2] := memavail;



     testeye := fractaleye.create(startScreen);
mem[3] := memavail;

FDS := Fractal.create;

{FDS.Build(3);}
FDS.BuildFromData(szfilename,'WORD',xRng,yRng);



(*
mem[6] := memavail;
FDS.moveNode(cStart);
mem[7] := memavail;
form2.show;
FDS.RecurseWithProcedure(@Fractal.DrawState);
form2.update;exit;
     StartScreen.x1 := 1;
     StartScreen.y1 := 1;
     StartScreen.x2 := 1;
     StartScreen.y2 := 1;



assignfile(testfile,szfilename);
reset(testfile);
setstart('1');

for l := 1 to 1 do
for x := 1 to xRng do
begin
     StartScreen.x1 := x;
     for y := 1 to yRng do
     begin
          StartScreen.y1 := y;
          StartScreen.x2 := StartScreen.x1;
          StartScreen.y2 := StartScreen.y1;
          screen.setValues(startScreen);

          value := FDS.deref(startscreen);

          p := screen.asLinear(xRng);
          seek(testfile,p);
          blockread(testFile,wd,1);

          if value <> wd then
          begin
               messagedlg('error in deref '+inttostr(x)+' '+inttostr(y)+' Fractal: '+
                           inttostr(value)+'  File: '+inttostr(wd),mterror,[mbok],0);
          end;

     end;
end;

setfinish('1');
edit4.text := floattostr(elapsedtime / 1000);
mem[7] := memavail;



closefile(testfile);

*)
mem[5] := memavail;
CompareMemUsed(mem[3],mem[4],'Fractal Test Button' +
               inttostr(mem[4] - mem[3]) +'  ');
end;

procedure TForm1.Button3Click(Sender: TObject);
var
   start,finish : longint;
begin
start := memavail;
     Tree := trees.createtree(2);
     tree.destroy;
finish := memavail;
comparememused(start,finish,'tree test ');
end;




procedure TForm1.Button6Click(Sender: TObject);
begin
     if fds <> nil then button7click(sender);
     close;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
     if fds <> nil then FDS.destroy;
     if testeye <> nil then testeye.destroy;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
   tofind : TwoDimData;
begin
     toFind := twodimdata.create;
     toFind.data.x1 := strtoint(edit5.text);
     toFind.data.y1 := strtoint(edit6.text);
     toFind.data.x2 := strtoint(edit7.text);
     toFind.data.y2 := strtoint(edit8.text);
     FDS.enclose(tofind);

     edit4.text := inttostr(FDS.ActiveNode.SingleValue);
     edit4.update;
     tofind.destroy;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
     testeye.attachto(FDS);
     testeye.activate;
end;

initialization
begin
end;

end.
