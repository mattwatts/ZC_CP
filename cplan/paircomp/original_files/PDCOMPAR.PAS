Program PdCompar;
{calculates the actual F-ratio for an anova for paired comparisons,
 then compares this with the distribution of F-ratios from
 100,000 randomisations of the data}

uses Crt;

const
  rows=4;
  tests=100000;

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

var
  inputfilename:string[40];
  lines:integer;
  dataarray:array[1..rows] of datarecord;
  randomarray:array[1..rows*2] of randomrecord;
  GMean:real;
  CMean1:real;
  CMean2:real;
  F_actual:real;
  F_random:real;
  Fcounter:longint;

Procedure NameInputFile;
{prompts for the name of the input text file}

begin
  writeln('Name of input text file (with path): ');
  readln(inputfilename);
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
clrscr;
writeln;
writeln('Actual F-ratio is: ',F_actualstring);
writeln;
writeln('Probability is: ',probabilitystring);
end; {Procedure Output}


begin
NameInputFile;
MakeArray;
Make1DArray;
ActualResult;
RandomAllocation;
TestStats;
Output;
end.