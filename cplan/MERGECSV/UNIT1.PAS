unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure mergecsv(const sInFile1, sInFile2, sOutFile : string);
var
   filename : string[20];
   infile : array[1..10] of text;
   outfile : text;
   c : array[1..20000] of char;
   files,i,j,count,row : integer;
   ch : char;
begin
     files := 2;
     assign(infile[1],sInFile1);
     assign(infile[2],sInFile2);
     reset(infile[1]);
     reset(infile[2]);

     assign(outfile,sOutFile);
     rewrite(outfile);

   {write ('number of files : ');
   readln (files);
   for i:=1 to files do
   begin
      write ('file ',i,' : ');
      readln (filename);
      assign (infile[i],filename);
      reset (infile[i]);
   end;}
   {write ('output file : ');
   readln (filename);
   assign (outfile,filename);
   rewrite (outfile);}
   row:=0;
   while not eof(infile[1]) do
   begin
      row:=row+1;
      {writeln (row);}
      count:=0;
      for i:=1 to files do
      begin
         repeat
            read (infile[i],ch);
            if ch <> chr(13) then
            begin
               count:=count+1;
               c[count]:=ch;
            end;
         until ch = chr(13);
         if i <> files then
         begin
            count:=count+1;
            c[count]:=',';
         end;
         read (infile[i],ch);
      end;
      for i:=1 to count do
         write (outfile,c[i]);
      writeln (outfile);
   end;
   for i:=1 to files do
      close (infile[i]);
   close (outfile);
end;


procedure TForm1.FormCreate(Sender: TObject);
var
   sInFile1, sInFile2, sOutFile : string;
begin
     sInFile1 := 'g:\data\eden\matrix711\coupe\ignored_removed\1.csv';
     sInFile2 := 'g:\data\eden\matrix711\coupe\ignored_removed\2.csv';
     sOutFile := 'g:\data\eden\matrix711\coupe\ignored_removed\mtx.csv';

     mergecsv(sInFile1,sInFile2,sOutFile);
end;

end.
