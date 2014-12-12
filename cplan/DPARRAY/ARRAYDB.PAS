unit Arraydb;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, FileCtrl;

type
  TArrayDebug = class(TForm)
    Button1: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button8: TButton;
    Button12: TButton;
    GroupBox5: TGroupBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit9: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    OpenDialog1: TOpenDialog;
    CheckBox3: TCheckBox;
    Label7: TLabel;
    ListBox1: TListBox;
    Button7: TButton;
    Edit8: TEdit;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ArrayDebug: TArrayDebug;

procedure initArraytest;

implementation
uses
    os_lims,stdfctns,ds;

{$R *.DFM}

var
   resizingtest : boolean;
   sparearr : array_t;
   
procedure initArraytest;
begin
    Application.CreateForm(TArrayDebug, ArrayDebug);
    ArrayDebug.showmodal;
    ArrayDebug.destroy;
end;

procedure TArrayDebug.Button2Click(Sender: TObject);
var
   beg,fin : longint;
   testarr : array_t;
   x : longint;
begin
     beg := memavail;
     for x := 1 to strtoint(edit9.text) do
     begin
          testarr := array_t.create;
          testarr.destroy;
     end;
     fin := memavail;

     edit1.text := inttostr(beg);
     edit2.text := inttostr(fin);
     edit3.text := inttostr(beg-fin);
     edit1.update;
     edit2.update;
     edit3.update;

end;

procedure TArrayDebug.Button1Click(Sender: TObject);
begin
     close
end;

procedure TArrayDebug.Button3Click(Sender: TObject);
var
   testarr : array_t;
   beg,fin : longint;
   st,fn : longint;
   x : longint;

begin
st := memavail;
     testarr := array_t.create;
     fn := strtoint(edit9.text);

     for x := 1 to fn do
     begin
     beg := memavail;
          testarr.init(strtoint(edit4.text),strtoint(edit5.text));
          testarr.free;
          if x mod 100 = 0 then
          begin
               edit7.text := inttostr(x);
               edit7.update;
          end;
     fin := memavail;

     if beg <> fin then
     begin
     edit1.text := inttostr(beg);
     edit2.text := inttostr(fin);
     edit3.text := inttostr(beg-fin);
     edit1.update;
     edit2.update;
     edit3.update;

     end;
     end;

     testarr.destroy;
fn := memavail;
     edit3.text := inttostr(st-fn);
     edit3.update;


end;

procedure TArrayDebug.Button4Click(Sender: TObject);
var
   testarr : array_t;
   beg,fin : longint;
   st,fn : longint;
   x : longint;

begin
st := memavail;
     testarr := array_t.create;
     fn := strtoint(edit9.text);

     for x := 1 to fn do
     begin
     beg := memavail;
          testarr.init(strtoint(edit4.text),strtoint(edit5.text));
          testarr.resize(strtoint(edit6.text));
          testarr.clr;
          if x mod 100 = 0 then
          begin
               edit7.text := inttostr(x);
               edit7.update;
          end;
     fin := memavail;

     if beg <> fin then
     begin
     edit1.text := inttostr(beg);
     edit2.text := inttostr(fin);
     edit3.text := inttostr(beg-fin);
     edit1.update;
     edit2.update;
     edit3.update;

     end;
     end;

     testarr.destroy;
fn := memavail;
     edit3.text := inttostr(st-fn);
     edit3.update;


end;

procedure TArrayDebug.Button5Click(Sender: TObject);
var
   testarr : array_t;
   x,l,y : longint;

begin
     testarr := array_t.create;
     testarr.init(sizeof(longint),20000);

     for x := 1 to 20000 do
     begin
          l := 20001 - x;
          testarr.setvalue(x,@l);
     end;
     for x := 1 to 20000 do
     begin
          testarr.rtnvalue(20001-x,@l);
          if l <> x then
          edit6.text := 'Error ' + inttostr(x);
          edit6.update;
     end;
end;

procedure TArrayDebug.Button6Click(Sender: TObject);
var
   testarr : array_t;
   x,l,y : longint;
   last : longint;

begin
     testarr := array_t.create;
     testarr.init(sizeof(longint),strtoint(edit5.text));

     randseed := 0;

     for x := 1 to strtoint(edit5.text) do
     begin
          l := random(10000)+1;
          testarr.setvalue(x,@l);
     end;

     testarr.sort(0,scLong);

     last := -1;
     for x := 1 to strtoint(edit5.text) do
     begin
          testarr.rtnvalue(x,@l);
          if l < last then
          begin
               edit6.text := 'Error ' + inttostr(x);
               edit6.update;
          end;
          last := l;
     end;

     testarr.destroy;
end;

procedure TArrayDebug.Button12Click(Sender: TObject);
type
    filetype = word;
var
   testin : file;
   count : longint;
   bytein : filetype;
   bytearr : filetype;
   pos : longint;

begin
     _testarr_ := array_t.create;

     resizingtest := checkbox3.checked;
{LOAD DATA FROM FILE}
     if opendialog1.execute then
     begin
          assignfile(testin,opendialog1.filename);
          reset(testin,sizeof(filetype));

          if resizingtest then
          begin
               _testarr_.init(sizeof(filetype),1);
               _testarr_.resizing := true;
          end
          else
          begin
               _testarr_.init(sizeof(filetype),filesize(testin));
          end;

          count := 0;

          while not(eof(testin)) do
          begin
               blockread(testin,bytein,1);
               inc(count);
               _testarr_.setValue(count,@bytein);
          end;
     end
     else
         exit;
     if _testarr_.lMaxSize <> filesize(testin) then
     begin
          _testarr_.lMaxSize := filesize(testin);
     end;
     closefile(testin);

     if checkbox1.checked then
     begin
          assignfile(testin,opendialog1.filename);
          reset(testin,sizeof(filetype));
          count := 0;
          while not(eof(testin)) do
          begin
               blockread(testin,bytein,1);
               inc(count);
               _testarr_.rtnValue(count,@bytearr);

               if bytein <> bytearr then
               begin
                    count := 0;
                    halt;
               end;
          end;
          closefile(testin);
     end;

     if checkbox2.checked then
     begin
          assignfile(testin,opendialog1.filename);
          reset(testin,sizeof(filetype));
          count := filesize(testin);
          while not(eof(testin)) do
          begin
               pos := random(count);
               seek(testin,pos);
               blockread(testin,bytein,1);
               inc(pos);
               _testarr_.rtnValue(pos,@bytearr);

               if bytein <> bytearr then
               begin
                    count := 0;
                    halt;
               end;

               if (pos = (_testarr_.lMaxSize-1)) then
               begin
                    dec(count);
                    _testarr_.resize(count);
               end;
          end;
          closefile(testin);
     end;
     _testarr_.destroy;
end;

procedure TArrayDebug.Button8Click(Sender: TObject);
var
   start,finish : longint;
   x,y : longint;
begin
     y := strtoint(edit9.text);
     for x := 1 to y do
     begin
           edit9.text := inttostr(x);
           edit9.update;
           webtest(strtoint(edit7.text));
     end;
end;

procedure TArrayDebug.Button7Click(Sender: TObject);
var
   x,y,l : longint;
   mem : array[1..10] of longint;
   range,range2 : integer;
   memst : tStringStream;

begin
     range := strtoint(edit5.text);
     range2 := strtoint(edit8.text);

mem[1] := memavail;
     sparearr := array_t.create;
     sparearr.init(sizeof(longint),range);

mem[7] := memavail;
     for x := 1 to range2 do
     begin
//          if x < 16457 then
//          sparearr.setValue(x,@x)
//          else
          sparearr.setValue(x,@x);

{          if ((x mod 1000) = 0) then
          begin
               edit3.text := inttostr(x);
               edit3.update;
          end;

{          if x > 1 then
          begin
          sparearr.rtnValue(x-1,@L);
          if (x-1) <> l then
          halt;
          end;
}
     end;

     for x := 1 to range2 do
     begin
{          if ((x mod 1000) = 0) then
          begin
               edit3.text := inttostr(x);
               edit3.update;
          end;
}
          sparearr.rtnValue(x,@L);

          if x <> l then
          halt;
     end;

mem[7] := memavail;

     for x := 1 to range2 do
     begin
          y := round(random * (range2-1)) + 1;
{          if ((x mod 1000) = 0) then
          begin
               edit3.text := inttostr(x) + '  ' + inttostr(y);
               edit3.update;
          end;
}
          sparearr.rtnValue(y,@L);

          if y <> l then
          halt;
     end;

     sparearr.destroy;
mem[2] := memavail;
comparememused(mem[1],mem[2],inttostr(mem[1]) + ' ' + inttostr(mem[2]) + '  ' +
               inttostr(mem[2] - mem[1]) + ' whoops ');
     messagebeep(0);
end;

end.
