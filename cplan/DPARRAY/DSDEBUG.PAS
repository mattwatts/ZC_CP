unit Dsdebug;
interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TDataStructDEBUG = class(TForm)
    Button1: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit8: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Edit9: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataStructDEBUG: TDataStructDEBUG;

procedure initDebug;

implementation
uses
    datastru,os_lims;
var
   oDSDebug : DataStructurePtr_O;
   db_ContMem : ContMemData_t;
   debugptr_ : pointer;
   Testptr : pointer;
   DSInstance : longint;

procedure initDebug;
begin
     Application.CreateForm(TDataStructDEBUG, DataStructDEBUG);
     DataStructDEBUG.showmodal;
     DataStructDEBUG.destroy;
end;
{$R *.DFM}

procedure TDataStructDEBUG.Button1Click(Sender: TObject);
begin
     close;
end;

procedure TDataStructDEBUG.FormCreate(Sender: TObject);
begin
{$ifdef ver80}
     edit8.text := inttostr(word(debugptr_^)) + ' ' + inttostr(word(ptr(seg(debugptr_),ofs(debugptr_)+2)^));
{$else}

{$endif}
end;

procedure TDataStructDEBUG.FormShow(Sender: TObject);
begin
{$ifdef ver80}
     edit8.text := inttostr(word(debugptr_^)) + ' ' + inttostr(word(ptr(seg(debugptr_),ofs(debugptr_)+2)^));
{$else}

{$endif}
end;

procedure TDataStructDEBUG.Button2Click(Sender: TObject);
var
   beg,fin : longint;
   lreturn : longint;
begin
     oDSDebug := DataStructurePtr_O.create;
     if debugptr_ <> nil then
     begin
          oDSDebug.FreeContMemPtr(debugptr_);
          debugptr_ := nil;
     end;

     beg := memavail;

     oDSDebug.AllocContMemPtr(debugptr_,strtoint(edit5.text),strtoint(edit4.text),db_contMem);

     fin := memavail;

     oDSDebug.destroy;

     edit1.text := inttostr(beg);
     edit1.update;
     edit2.text := inttostr(fin);
     edit2.update;
     edit3.text := inttostr(beg-fin);
     edit3.update;
end;

procedure TDataStructDEBUG.Button3Click(Sender: TObject);
var
   beg,fin : longint;
   lreturn : longint;
begin
     oDSDebug := DataStructurePtr_O.create;
     if debugptr_ = nil then
        oDSDebug.AllocContMemPtr(debugptr_,strtoint(edit5.text),strtoint(edit4.text),db_ContMem);

     beg := memavail;

     oDSDebug.ReAllocContMemPtr(debugptr_,strtoint(edit6.text),strtoint(edit4.text),db_ContMem);

     fin := memavail;

     oDSDebug.destroy;

     edit1.text := inttostr(beg);
     edit1.update;
     edit2.text := inttostr(fin);
     edit2.update;
     edit3.text := inttostr(beg-fin);
     edit3.update;
end;

procedure TDataStructDEBUG.Button4Click(Sender: TObject);
var
   beg,fin : longint;
   lreturn : longint;
begin
     beg := memavail;

     oDSDebug := DataStructurePtr_O.create;
     if debugptr_ <> nil then
     begin
          oDSDebug.FreeContMemPtr(debugptr_);
          debugptr_ := nil;
     end;
     oDSDebug.destroy;

     fin := memavail;

     edit1.text := inttostr(beg);
     edit1.update;
     edit2.text := inttostr(fin);
     edit2.update;
     edit3.text := inttostr(beg-fin);
     edit3.update;
end;

procedure TDataStructDEBUG.Button5Click(Sender: TObject);
var
   beg,fin : longint;
   lreturn : longint;
begin
     oDSDebug := DataStructurePtr_O.create;
     beg := memavail;

     oDSDebug.FreeContMemPtr(debugptr_);

     fin := memavail;

     oDSDebug.destroy;

     edit1.text := inttostr(beg);
     edit1.update;
     edit2.text := inttostr(fin);
     edit2.update;
     edit3.text := inttostr(beg-fin);
     edit3.update;
end;

procedure TDataStructDEBUG.Button7Click(Sender: TObject);
var
   beg,fin : longint;
   x : longint;
   lReturn : longint;
   mem : array[0..10] of longint;
   test : DataStructurePtr_O;
   inner,outer : longint;
begin
randomize;
     inner := strtointdef(edit7.text,1);
     outer := strtointdef(edit9.text,1);
     mem[1] := memavail;
     for x := 1 to outer do
     begin
          edit9.text := inttostr(x);
          edit9.update;

          test := DataStructurePtr_O.create;

          mem[3] := memavail;
          if checkbox1.checked then test.TestAlloc(inner);
          if checkbox2.checked then test.TestReAlloc(inner);
          if checkbox3.checked then test.TestLocate(inner);
          if checkbox4.checked then test.RandomTests(inner);

          mem[4] := memavail;
          test.destroy;

               mem[0] := mem[4] - mem[3];
          edit1.text := inttostr(mem[3]);
          edit2.text := inttostr(mem[4]);
          edit3.text := inttostr(mem[0]);
          edit1.update;
          edit2.update;
          edit3.update;

     end;
     mem[2] := memavail;

     x:= 1;

(*{$ifdef ver80}
     beg := memavail;
{$endif}

     lReturn := round(strtofloat(edit9.text));
     x := -1;
     while x <> lReturn do
     begin
          inc(x);
          oDSDebug := DataStructurePtr_O.create;

          oDSDebug.AllocContMemPtr(debugptr_,strtoint(edit5.text),strtoint(edit4.text),db_ContMem);
          oDSDebug.ReAllocContMemPtr(debugptr_,strtoint(edit6.text),strtoint(edit4.text),db_ContMem);
          oDSDebug.FreeContMemPtr(debugptr_);
          oDSDebug.DisposeContMemPtr(debugptr_);

          oDSDebug.destroy;
          if x mod 100 = 0 then
          begin
               edit7.text := inttostr(x);
               edit7.update;
          end;
     end;

{$ifdef ver80}
     fin := memavail;
{$endif}
     edit1.text := inttostr(beg);
     edit1.update;
     edit2.text := inttostr(fin);
     edit2.update;
     edit3.text := inttostr(beg-fin);
     edit3.update;
*)
end;

end.
