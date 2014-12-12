Program Spman;
{calculates the Spearman rank correlation coefficient
 (the formulation of Siegel and Castellan that deals with
 tied values) for sets of data in two columns and measures
 their significance against values from 100,000 randomisations
 of the data; significance gives probability of finding
 random results further from zero (two-tailed test)}

{NOTE: procedure Ranks assumes two decimal places and max value 1000}
{NOTE: maximum size of data array currently 1500}


uses Crt;

const
  tests=100000;

type

  datarecord=record
               real1:real;
               rank1:real;
               tied1:boolean;
               real2:real;
               rank2:real;
               tied2:boolean;
             end;

  randomrecord=record
                 value:real;
                 taken:boolean;
               end;

var
  lines:word;
  inputfilename:string[100];
  dataarray:array[1..1500] of datarecord;
  randomarray:array[1..1500] of randomrecord;
  sigmaX2:real;
  sigmaY2:real;
  ActualRs:real;
  Probability:real;

Procedure NameInputFile;
{prompts for the name of the input text file}

begin
  writeln('Name of input text file (with path): ');
  readln(inputfilename);
end; {procedure NameInputFile}

Procedure MakeArray;
{reads a text file to construct the array for analysis}

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
  dataarray[lines].real1:=realnumber;
  readln(infile,realnumber);
  dataarray[lines].real2:=realnumber;
  end;
close(infile);
end; {Procedure MakeArray}

Procedure Ranks;
{ranks the real values}

var
  value:longint;
  rank:integer;
  x:word;

begin
  value:=100001;
  rank:=0;
  repeat
    begin
    value:=value-1;
    for x:=1 to lines do
      if dataarray[x].real1=value/1000 then
        begin
        rank:=rank+1;
        dataarray[x].rank1:=rank;
        end;
    end;
  until rank=lines;

  value:=100001;
  rank:=0;
  repeat
    begin
    value:=value-1;
    for x:=1 to lines do
      if dataarray[x].real2=value/1000 then
        begin
        rank:=rank+1;
        dataarray[x].rank2:=rank;
        end;
    end;
  until rank=lines;
end; {procedure Ranks}

Procedure Ties;
{averages the ranks of tied values}

var
  a:integer;
  b:integer;
  c:integer;
  d:integer;
  x:integer;
  ties:integer;
  rank:real;

begin
  for a:=1 to (lines-1) do
    begin
    for x:=1 to lines do
      dataarray[x].tied1:=false;
    ties:=1;
    for b:=a+1 to lines do
      if dataarray[a].real1=dataarray[b].real1 then
        begin
        ties:=ties+1;
        dataarray[a].tied1:=true;
        dataarray[b].tied1:=true;
        end;
    if ties>1 then
      begin
      rank:=0;
      for c:=1 to lines do
        if dataarray[c].tied1=true then
          rank:=rank+dataarray[c].rank1;
      for d:=1 to lines do
        if dataarray[d].tied1=true then
          dataarray[d].rank1:=rank/ties;
      end;
    end;

    {note that this duplicates tie calculations for more than two ties;
     but values are unchanged because e.g. 2nd, 3rd and subsequent ties
     already given equal ranks by first pass}

  for a:=1 to (lines-1) do
    begin
    for x:=1 to lines do
      dataarray[x].tied2:=false;
    ties:=1;
    for b:=a+1 to lines do
      if dataarray[a].real2=dataarray[b].real2 then
        begin
        ties:=ties+1;
        dataarray[a].tied2:=true;
        dataarray[b].tied2:=true;
        end;
    if ties>1 then
      begin
      rank:=0;
      for c:=1 to lines do
        if dataarray[c].tied2=true then
          rank:=rank+dataarray[c].rank2;
      for d:=1 to lines do
        if dataarray[d].tied2=true then
          dataarray[d].rank2:=rank/ties;
      end;
    end;
end; {procedure Ties}

Procedure Spearman;
{calculates the Spearman rank correlation coefficient}

var
  a:integer;
  sumX:real;
  sumY:real;
  sigmaD2:real;
  averageX:real;
  averageY:real;

begin
  sumX:=0;
  sumY:=0;
  sigmaX2:=0;
  sigmaY2:=0;
  sigmaD2:=0;
  for a:=1 to lines do
    begin
    sumX:=sumX+dataarray[a].rank1;
    sumY:=sumY+dataarray[a].rank2;
    sigmaD2:=sigmaD2+sqr(dataarray[a].rank1-dataarray[a].rank2);
    end;
  averageX:=sumX/lines;
  averageY:=sumY/lines;
  for a:=1 to lines do
    begin
    sigmaX2:=sigmaX2+sqr(dataarray[a].rank1-averageX);
    sigmaY2:=sigmaY2+sqr(dataarray[a].rank2-averageY);
    end;
  ActualRs:=(sigmaX2+sigmaY2-sigmaD2)/(2*sqrt(sigmaX2*sigmaY2));
end; {Procedure Spearman}

Procedure MakeRandomArray;
{creates a copy of the second series of ranks for random allocation}

var
  a:integer;

begin
  for a:=1 to lines do
    randomarray[a].value:=dataarray[a].rank2;
end; {procedure MakeRandomArray}

Procedure RandomAllocation;forward;

Procedure TestStatistics;
{generates random pairings of observations and calculates
 the Spearman correlation coefficient for each; returns
 the proportion of coefficients from randomised data equal to
 or greater than the actual coefficient}

var
  a:longint;
  b:integer;
  SigmaD2:real;
  RandomRs:real;
  SCounter:longint;

begin
  SCounter:=0;
  randomize;
  clrscr;
  for a:=1 to tests do
    begin
    RandomAllocation;
    SigmaD2:=0;
    for b:=1 to lines do
      SigmaD2:=SigmaD2+sqr(dataarray[b].rank1-dataarray[b].rank2);
    RandomRs:=(sigmaX2+sigmaY2-sigmaD2)/(2*sqrt(sigmaX2*sigmaY2));
    if abs(RandomRs)>=abs(ActualRs) then
      SCounter:=SCounter+1;
    gotoxy(19,3);
    write('Randomisations = ',a:6);
    end;
  Probability:=SCounter/tests;
end;{Procedure TestStatistics}

Procedure RandomAllocation;
{randomises the second series of ranks in the data array;
 NOTE: call to randomise is in the procedure (TestStats) that calls
 this one}

var
  a:integer;
  check:integer;

begin
  for a:=1 to lines do
    randomarray[a].taken:=false;
  for a:=1 to lines do
    begin
    repeat
      check:=random(lines)+1;
    until randomarray[check].taken=false;
    dataarray[a].rank2:=randomarray[check].value;
    randomarray[check].taken:=true;
    end;
end;{procedure RandomAllocation}

Procedure Output;
{reports correlation coefficients and significance levels to the screen}

var
  Spearmanstring:string[6];
  Pstring:string[6];

begin

str(ActualRs:6:3,Spearmanstring);
str(Probability:6:4,Pstring);

clrscr;
writeln('Input file: ',inputfilename);
writeln;
writeln('Coefficient is: ',Spearmanstring);
writeln('Significance is P=',Pstring);
writeln;

end;{procedure Output}

begin
NameInputFile;
MakeArray;
Ranks;
Ties;
Spearman;
MakeRandomArray;
TestStatistics;
Output;
end.