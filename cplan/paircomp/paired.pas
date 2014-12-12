unit paired;
{calculates the actual F-ratio for an anova for paired comparisons,
 then compares this with the distribution of F-ratios from
 100,000 randomisations of the data}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids;

const
  rows=10000;
  //tests=100000;

type
  datarecord=record
             col1:real;
             col2:real;
             rowmean:real;
             end;

  randomrecord=record
               value:real;
               taken:boolean;
               end;
type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    EditFileName: TEdit;
    btnBrowse: TButton;
    btnExecute: TButton;
    btnCancel: TButton;
    btnAdd: TButton;
    Label2: TLabel;
    EditTests: TEdit;
    StringGrid1: TStringGrid;
    OpenDialog1: TOpenDialog;
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
var
  inputfilename{,outputfilename}:string{[40]};
  iFilenamesInBatch, tests,
  lines:integer;
  dataarray:array[1..rows] of datarecord;
  randomarray:array[1..rows*2] of randomrecord;
  GMean:real;
  CMean1:real;
  CMean2:real;
  F_actual:real;
  F_random:real;
  Fcounter:longint;
  outputfile : TextFile;

implementation

{$R *.DFM}


Procedure NameInputFile;
{prompts for the name of the input text file}
begin
     //writeln('Name of input text file (with path): ');
     //readln(inputfilename);
end; {procedure NameInputFile}

Procedure MakeArray;
{reads a text file to construct an array with two columns of variable
 length; columns are the treatments, rows are the individuals}

var
infile:text;
realnumber:real;

begin
assign(infile,inputfilename);
reset(infile);
lines:=0;
while not eof(infile) do
  begin
  lines:=lines+1;
  read(infile,realnumber);
  dataarray[lines].col1:=realnumber;
  readln(infile,realnumber);
  dataarray[lines].col2:=realnumber;
  end;
end; {Procedure MakeArray}

Procedure Make1DArray;
{extracts the values from the actual anova table for random
 selection in Procedure RandomResults}

var
  a:integer;
  r:integer;

begin
  r:=0;
  for a:=1 to lines do
    begin
    r:=r+1;
    randomarray[r].value:=dataarray[a].col1;
    r:=r+1;
    randomarray[r].value:=dataarray[a].col2;
    end;
end; {Procedure Make1DArray}

Procedure GrandMean;
{calculates the grand mean for the data}

var
  a:integer;
  GSum:real;
  number:integer;

begin
GSum:=0;
number:=lines*2;
for a:=1 to lines do
  GSum:=GSum+dataarray[a].col1+dataarray[a].col2;
GMean:=GSum/number;
end; {Procedure GrandMean}

Procedure ColumnMeans;
{calculates the column means for the treatments
 and writes the values to global variables}

var
  a:integer;
  CSum1:real;
  CSum2:real;

begin
  CSum1:=0;
  CSum2:=0;
  for a:=1 to lines do
    begin
    CSum1:=CSum1+dataarray[a].col1;
    CSum2:=CSum2+dataarray[a].col2;
    end;
  CMean1:=CSum1/lines;
  CMean2:=CSum2/lines;
end; {Procedure ColumnMeans}

Procedure RowMeans;
{calculates row means and writes them to the data array}

var
  a:integer;

begin
  for a:=1 to lines do
    dataarray[a].rowmean:=(dataarray[a].col1+dataarray[a].col2)/2;
end; {Procedure RowMeans}

Function MStr:real;
{returns the mean square for the treatments (columns)}

var
  SStr:real;

begin
  SStr:=lines*(sqr(CMean1-GMean)+sqr(CMean2-GMean));
  MStr:=SStr; {degrees of freedom = 1 for case of two treatments}
end; {Function MStr}

Function MSre:real;
{returns the mean square for the residual}

var
  a:integer;
  b:integer;
  RSum:real;

begin
  RSum:=0;
  for a:=1 to lines do
    begin
    RSum:=RSum+sqr(dataarray[a].col1-CMean1-dataarray[a].rowmean+GMean);
    RSum:=RSum+sqr(dataarray[a].col2-CMean2-dataarray[a].rowmean+GMean);
    end;
  MSre:=RSum/(lines-1);
end; {Function MSre}

Procedure ActualResult;
{calculates the actual F-ratio for the data}

begin
  GrandMean;
  ColumnMeans;
  RowMeans;
  F_actual:=MStr/MSre;
end; {Procedure ActualResult}

Procedure RandomAllocation;
{randomly allocates the original data values to positions in the
 data matrix used to calculate anova parameters
 - note call to randomize in following procedure that calls this one}

var
a:integer;
check:integer;

begin
for a:=1 to lines*2 do
  randomarray[a].taken:=false;
for a:=1 to lines do
  begin
  repeat
    check:=random(lines*2)+1;
  until randomarray[check].taken=false;
  dataarray[a].col1:=randomarray[check].value;
  randomarray[check].taken:=true;
  repeat
    check:=random(lines*2)+1;
  until randomarray[check].taken=false;
  dataarray[a].col2:=randomarray[check].value;
  randomarray[check].taken:=true;
  end;
end; {Procedure RandomAllocation}

Procedure TestStats;
{generates random arrrangements of the data,
 calculates a treatment F-ratio for each one, and counts
 the number of randomly generated F-ratios greater than or
 equal to the actual ratio}

var
a:longint;

begin
Fcounter:=0;
randomize;
for a:=1 to tests do
  begin
  RandomAllocation;
  ColumnMeans;
  RowMeans;
  F_random:=MStr/MSre;
  if F_random>=F_actual then
    Fcounter:=Fcounter+1;
  end;
end; {Procedure TestStats}

Procedure Output;
{writes the results to screen}

var
F_actualstring:string[9];
probabilitystring:string[6];
probability:real;

begin
str(F_actual:9:4,F_actualstring);
probability:=Fcounter/tests;
str(probability:6:4,probabilitystring);
//clrscr;
writeln(outputfile);
writeln(outputfile,'Actual F-ratio is: ',F_actualstring);
writeln(outputfile);
writeln(outputfile,'Probability is: ',probabilitystring);

//writeln('Press ENTER to terminate program');
{pause until user presses enter}
//readln;
end; {Procedure Output}

procedure paired_comparisons_main;
begin
     //NameInputFile;

     //writeln(outputfile,'MakeArray');
     MakeArray;

     //writeln(outputfile,'Make1DArray');
     Make1DArray;

     //writeln(outputfile,'ActualResult');
     ActualResult;

     //writeln(outputfile,'RandomAllocation');
     RandomAllocation;
     TestStats;
     Output;
end;

procedure TForm1.btnCancelClick(Sender: TObject);
begin
     Application.Terminate;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     StringGrid1.Cells[0,0] := 'Input Filename';
     StringGrid1.Cells[1,0] := 'Tests';
     iFilenamesInBatch := 0;
end;

procedure TForm1.btnBrowseClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
        EditFileName.Text := OpenDialog1.Filename;
end;

procedure TForm1.btnAddClick(Sender: TObject);
begin
     if (EditFileName.Text <> '') then
     begin
          Inc(iFilenamesInBatch);
          if (StringGrid1.RowCount <= iFilenamesInBatch) then
             StringGrid1.RowCount := iFilenamesInBatch + 1;

          StringGrid1.Cells[0,iFilenamesInBatch] := EditFileName.Text;
          StringGrid1.Cells[1,iFilenamesInBatch] := EditTests.Text;
     end;
end;

procedure ExecutePairedComparison(const sInFile,sOutFile : string;
                                  const iTests : integer);
begin
     try
        Screen.Cursor := crHourglass;

        tests := iTests;
        inputfilename := sInFile;
        assignfile(outputfile,sOutFile);
        rewrite(outputfile);

        paired_comparisons_main;

        closefile(outputfile);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ExecutePairedComparison on file ' + sInFile,mtError,[mbOk],0);
     end;
end;

procedure TForm1.btnExecuteClick(Sender: TObject);
var
   iCount : integer;
begin
     if (iFilenamesInBatch > 0) then
     begin
          // execute
          for iCount := 1 to iFilenamesInBatch do
              ExecutePairedComparison(StringGrid1.Cells[0,iCount],
                                      ExtractFilePath(StringGrid1.Cells[0,iCount]) + 'output' + ExtractFileName(StringGrid1.Cells[0,iCount]),
                                      StrToInt(StringGrid1.Cells[1,iCount]));
     end
     else
     begin
          // there are no items in the list, try adding current filename/tests
          // and then execute
          MessageDlg('add a file to the list before executing',mtInformation,[mbOk],0);
     end;
end;

end.
