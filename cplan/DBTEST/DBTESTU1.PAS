unit dbtestu1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Db, DBTables;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    Table1: TTable;
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    Query1: TQuery;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
   iCount : integer;
   sS : string;
begin
     Table1.Open;

     for iCount := 0 to (Table1.FieldDefs.Count - 1) do
     with Table1.FieldDefs.Items[iCount] do
     begin
          Listbox1.Items.Add('Name : ' + Name);

          case DataType of
               ftUnknown : sS := 'Unknown or undetermined';
               ftString	: sS := 'Character or string field';
               ftSmallint : sS := '16-bit integer field';
               ftInteger : sS := '32-bit integer field';
               ftWord : sS := '16-bit unsigned integer field';
               ftBoolean : sS := 'Boolean field';
               ftFloat : sS := 'Floating-point numeric field';
               ftCurrency : sS := 'Money field';
               ftBCD : sS := 'Binary-coded decimal field';
               ftDate : sS := 'Date field';
               ftTime : sS := 'Time field';
               ftDateTime : sS := 'Date and time field';
               ftBytes : sS := 'Fixed number of bytes (binary storage)';
               ftVarBytes : sS := 'Variable number of bytes (binary storage)';

               ftAutoInc : sS := 'Auto-incrementing 32-bit integer counter field';
               ftBlob : sS := 'Binary Large OBject field';
               ftMemo : sS := 'Text memo field';
               ftGraphic : sS := 'Bitmap field';
               ftFmtMemo : sS := 'Formatted text memo field';
               ftParadoxOle : sS := 'Paradox OLE field';
               ftDBaseOle : sS := 'dBASE OLE field';
               ftTypedBinary : sS := 'Typed binary field';
          end;

          Listbox1.Items.Add('DataType : ' + sS);
          Listbox1.Items.Add('Size : ' + IntToStr(Size));
          if Required then
             Listbox1.Items.Add('Required : True')
          else
              Listbox1.Items.Add('Required : False');

          if (iCount <> (Table1.FieldDefs.Count - 1)) then
             Listbox1.Items.Add('');
     end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
     Query1.SQL := Memo1.Lines;
     try
        Query1.Open;
        
     except
           {MessageDlg('exception in open',mtInformation,[mbOk],0);}
     end;
end;

end.
