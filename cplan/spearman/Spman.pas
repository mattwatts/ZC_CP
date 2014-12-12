unit Spman;
{calculates the Spearman rank correlation coefficient
 for sets of data in two columns and measures their
 significance against values from 10,000 randomisations
 of the data; significance gives probability of finding
 random results further from zero (two-tailed test)}

{NOTE: procedure Ranks assumes two decimal places and max value 100}
{NOTE: maximum size of data array currently 20000}

interface

type

  datarecord=record
               real1:extended;
               rank1:extended;
               tied1:boolean;
               real2:extended;
               rank2:extended;
               tied2:boolean;
             end;

  randomrecord=record
                 value:extended;
                 taken:boolean;
               end;
  dataarray_t = array[1..50000] of datarecord; //Variant; //
  randomarray_t = array[1..50000] of randomrecord; //Variant; //

var
  iTies, iRanks,
  iCurrentTest,
  tests : integer;
  lines:longint;
  inputfilename:string;
  dataarray : dataarray_t;
  randomarray : randomarray_t;
  Spearman:extended;
  ActualCoefficient:extended;
  Probability:extended;
  OutputFile : TextFile;
  fArraysCreated : boolean;

Procedure Ranks;
Procedure Ties;
Function Rs:extended;
Procedure RandomAllocation;
Function TestStat:extended;

procedure Main_spman;


Implementation

uses
    SysUtils, sp_u1, FileCtrl,
    sp_optimise_maths;

Procedure NameInputFile;
{prompts for the name of the input text file}

begin
     tests := StrToInt(Form1.EditTests.Text);
     inputfilename := Form1.EditFile.Text;
  //writeln('Name of input text file (with path): ');
  //readln(inputfilename);
end; {procedure NameInputFile}


procedure DumpInputData;
var
   iCount : integer;
   TestFile : TextFile;
begin
     assignfile(TestFile,'c:\test.txt');
     rewrite(TestFile);
     writeln(TestFile,'real1,real2');

     for iCount := 1 to lines do
     begin
          writeln(TestFile,FloatToStr(dataarray[iCount].real1) +
                           ',' +
                           FloatToStr(dataarray[iCount].real2));
     end;

     closefile(TestFile);
end;

Procedure MakeArray;
{reads a text file to construct the array for analysis}

var
infile:text;
realnumber:extended;
iLines : integer;

begin
     assign(infile,inputfilename);
     reset(infile);
     lines:=0;
     // count lines
     while not eof(infile) do
     begin
          lines:=lines+1;
          readln(infile);
     end;
     closefile(infile);
     iLines := lines;
     lines := 0;
     {if not fArraysCreated then
     begin
          dataarray := VarArrayCreate([1,iLines],varDouble);
          randomarray := VarArrayCreate([1,iLines],varDouble);
          fArraysCreated := True;

          varBoolean
     end;}
     assign(infile,inputfilename);
     reset(infile);
     while not eof(infile) do
     begin
          lines:=lines+1;
          read(infile,realnumber);
          dataarray[lines].real1:=realnumber;
          readln(infile,realnumber);
          dataarray[lines].real2:=realnumber;
     end;

     DumpInputData;

     Ranks;
     Ties;
     Spearman:=Rs;
     ActualCoefficient:=Spearman; {for reference by TestStat}
     Probability:=TestStat;
end; {Procedure MakeArray}

Procedure OldRanks;
var
  value:integer;
  rank:integer;
  x:integer;
  fDebug : boolean;
  DebugFile : TextFile;

begin
  fDebug := Form1.CheckRanks.Checked;
  if fDebug then
  begin
       {forcedirectories(sDebugDirectory + '\' +
                        IntToStr(iCurrentTest));}
       assignfile(DebugFile,sDebugDirectory +
                       {IntToStr(iCurrentTest) +}
                       '\ranks' + IntToStr(iCurrentTest) + '.csv');
       rewrite(DebugFile);
       writeln(DebugFile,'line,which real,real value,rank value,rank');
  end;

  value:=10001;
  rank:=0;
  repeat
    begin
    value:=value-1;
    for x:=1 to lines do
      if (Round(100*dataarray[x].real1)=value) then
        begin
        rank:=rank+1;
        dataarray[x].rank1:=rank;

        if fDebug then
           writeln(DebugFile,IntToStr(x) + ',' +
                             '1,' +
                             FloatToStr(dataarray[x].real1) + ',' +
                             IntToStr(value) + ',' +
                             IntToStr(rank));
        end;
    end;
  until rank>=lines;

  value:=10001;
  rank:=0;
  repeat
    begin
    value:=value-1;
    for x:=1 to lines do
      if (Round(100*dataarray[x].real2)=value) then
        begin
        rank:=rank+1;
        dataarray[x].rank2:=rank;

        if fDebug then
           writeln(DebugFile,IntToStr(x) + ',' +
                             '2,' +
                             FloatToStr(dataarray[x].real2) + ',' +
                             IntToStr(value) + ',' +
                             IntToStr(rank));
        end;
    end;
  until rank>=lines;

  if fDebug then
     CloseFile(DebugFile);
end; {procedure OldRanks}

procedure NewRanks;
var
  value:integer;
  rank_1, rank_2:integer;
  x:integer;
  fDebug : boolean;
  DebugFile : TextFile;

begin
     fDebug := Form1.CheckRanks.Checked;
     if fDebug then
     begin
          {forcedirectories(sDebugDirectory + '\' +
                           IntToStr(iCurrentTest));}
          assignfile(DebugFile,sDebugDirectory +
                          {IntToStr(iCurrentTest) +}
                          '\ranks' + IntToStr(iCurrentTest) + '.csv');
          rewrite(DebugFile);
          writeln(DebugFile,'line,which real,real value,rank value,rank');
     end;

     value:=10001;
     rank_1:=0;
     rank_2:=0;
     repeat
           value:=value-1;
           for x:=1 to lines do
           begin
                if (rank_1 < lines)
                and (Round(100*dataarray[x].real1)=value) then
                begin
                     rank_1:=rank_1+1;
                     dataarray[x].rank1:=rank_1;

                     if fDebug then
                        writeln(DebugFile,IntToStr(x) + ',' +
                                          '1,' +
                                          FloatToStr(dataarray[x].real1) + ',' +
                                          IntToStr(value) + ',' +
                                          IntToStr(rank_1));
                end;

                if (rank_2 < lines)
                and (Round(100*dataarray[x].real2)=value) then
                begin
                     rank_2:=rank_2+1;
                     dataarray[x].rank2:=rank_2;

                     if fDebug then
                        writeln(DebugFile,IntToStr(x) + ',' +
                                          '2,' +
                                          FloatToStr(dataarray[x].real2) + ',' +
                                          IntToStr(value) + ',' +
                                          IntToStr(rank_2));
                end;
           end;

     until (rank_1 >= lines)
     and (rank_2 >= lines);

     if fDebug then
        CloseFile(DebugFile);
end; {procedure NewRanks}

Procedure Ranks;
begin
     // {ranks the real values}
     if Form1.CheckOptRanks.Checked then
        NewRanks
     else
         OldRanks;

     Inc(iRanks);
end;

procedure NewTies;
var
  a:integer;
  b:integer;
  c:integer;
  d:integer;
  x:integer;
  ties_1, ties_2:integer;
  rank:extended;
  fDebug : boolean;
  DebugFile : TextFile;

begin
     fDebug := Form1.CheckTies.Checked;
     if fDebug then
     begin
          {forcedirectories('c:\sp_test\' +
                           IntToStr(iCurrentTest));}
          assignfile(DebugFile,sDebugDirectory +
                          {IntToStr(iCurrentTest) +}
                          '\ties' + IntToStr(iCurrentTest) + '.csv');
          rewrite(DebugFile);
          writeln(DebugFile,'a,b,which real,ties,real value');
     end;

     for a:=1 to (lines-1) do
     begin
          for x:=1 to lines do
          begin
               dataarray[x].tied1:=false;
               dataarray[x].tied2:=false;
          end;

          ties_1:=1;
          ties_2:=1;
          for b:=a+1 to lines do
          begin
               if dataarray[a].real1=dataarray[b].real1 then
               begin
                    ties_1:=ties_1+1;
                    dataarray[a].tied1:=true;
                    dataarray[b].tied1:=true;

                    if fDebug then
                       writeln(DebugFile,IntToStr(a) + ',' +
                                         IntToStr(b) + ',' +
                                         '1,' +
                                         IntToStr(ties_1) + ',' +
                                         FloatToStr(dataarray[a].real1));
               end;

               if dataarray[a].real2=dataarray[b].real2 then
               begin
                    ties_2:=ties_2+1;
                    dataarray[a].tied2:=true;
                    dataarray[b].tied2:=true;

                    if fDebug then
                       writeln(DebugFile,IntToStr(a) + ',' +
                                         IntToStr(b) + ',' +
                                         '1,' +
                                         IntToStr(ties_2) + ',' +
                                         FloatToStr(dataarray[a].real2));
               end;
          end;

          if ties_1>1 then
          begin
               rank:=0;
               for c:=1 to lines do
                   if dataarray[c].tied1=true then
                      rank:=rank+dataarray[c].rank1;
               for d:=1 to lines do
                   if dataarray[d].tied1=true then
                      dataarray[d].rank1:=rank/ties_1;
          end;

          if ties_2>1 then
          begin
               rank:=0;
               for c:=1 to lines do
                   if dataarray[c].tied2=true then
                      rank:=rank+dataarray[c].rank2;
               for d:=1 to lines do
                   if dataarray[d].tied2=true then
                      dataarray[d].rank2:=rank/ties_2;
          end;
     end;

     if fDebug then
        CloseFile(DebugFile);

end; {procedure NewTies}

Procedure OldTies;
{averages the ranks of tied values}

var
  a:integer;
  b:integer;
  c:integer;
  d:integer;
  x:integer;
  ties:integer;
  rank:extended;
  fDebug : boolean;
  DebugFile : TextFile;

begin
  fDebug := Form1.CheckTies.Checked;
  if fDebug then
  begin
       {forcedirectories('c:\sp_test\' +
                        IntToStr(iCurrentTest));}
       assignfile(DebugFile,sDebugDirectory +
                       {IntToStr(iCurrentTest) +}
                       '\ties' + IntToStr(iCurrentTest) + '.csv');
       rewrite(DebugFile);
       writeln(DebugFile,'a,b,which real,ties,real value');
  end;

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

        if fDebug then
           writeln(DebugFile,IntToStr(a) + ',' +
                             IntToStr(b) + ',' +
                             '1,' +
                             IntToStr(ties) + ',' +
                             FloatToStr(dataarray[a].real1));
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
     but values are unchanged because e.g. 2nd and 3rd ties already
     made equal by first pass}

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

        if fDebug then
           writeln(DebugFile,IntToStr(a) + ',' +
                             IntToStr(b) + ',' +
                             '1,' +
                             IntToStr(ties) + ',' +
                             FloatToStr(dataarray[a].real2));
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

  if fDebug then
     CloseFile(DebugFile);

end; {procedure OldTies}

procedure TieDebugOutput(const sWhen : string);
var
   DebugFile : TextFile;
   iCount : integer;

   function BoolAsString(const fBool : boolean) : string;
   begin
        if fBool then
           Result := 'True'
        else
            Result := 'False';
   end;

begin
     // create debug output to examine tie output
     if Form1.CheckOptTies.Checked then
        assignfile(DebugFile,sDebugDirectory + '\tie_output_optimise_' + sWhen + IntToStr(iTies) + '.csv')
     else
         assignfile(DebugFile,sDebugDirectory + '\tie_output_' + sWhen + IntToStr(iTies) + '.csv');

     rewrite(DebugFile);
     writeln(DebugFile,'real1,real2,tied1,tied2,rank1,rank2');

     for iCount := 1 to lines do
     begin
          writeln(DebugFile,FloatToStr(dataarray[iCount].real1) + ',' +
                            FloatToStr(dataarray[iCount].real2) + ',' +
                            BoolAsString(dataarray[iCount].tied1) + ',' +
                            BoolAsString(dataarray[iCount].tied2) + ',' +
                            FloatToStr(dataarray[iCount].rank1) + ',' +
                            FloatToStr(dataarray[iCount].rank2));
     end;

     closefile(DebugFile);
end;

procedure Ties;
begin
     if Form1.CheckTies.Checked then
        TieDebugOutput('before');

     // averages the ranks of tied values
     if Form1.CheckOptTies.Checked then
        NewTies //SP_TieValues // NewTies
     else
         OldTies;

     // create debug output to examine tie output
     Inc(iTies);

     if Form1.CheckTies.Checked then
        TieDebugOutput('after');
end;


Function Rs:extended;
{calculates the Spearman rank correlation coefficient}

var
  a:integer;
  SS:extended;
  denominator,eLines:extended;
  //Spearman:extended;

begin
  SS:=0;
  for a:=1 to lines do
    SS:=SS+sqr(dataarray[a].rank1-dataarray[a].rank2);
  eLines := lines;
  denominator:=eLines*(sqr(eLines)-1);
  Rs:=1-(6*SS/denominator);
end; {Function Rs}

Procedure RandomAllocation;
{randomises the second series of observations in the data array;
 NOTE: call to randomise is in the procedure (TestStats) that calls
 this one}

var
  a:integer;
  check:integer;

begin
     for a:=1 to lines do
     begin
          randomarray[a].value:=dataarray[a].real2;
          randomarray[a].taken:=false;
     end;

     for a:=1 to lines do
     begin
          repeat
                check:=random(lines)+1;
          until randomarray[check].taken=false;

          dataarray[a].real2:=randomarray[check].value;
          randomarray[check].taken:=true;
     end;
end;{procedure RandomAllocation}

Function TestStat:extended;
{generates random pairings of observations and calculates
 the Spearman correlation coefficient for each; returns
 the proportion of coefficients from randomised data equal to
 or greater than the actual coefficient}

var
  a, iCount:longint;
  SCounter:longint;
  RCoeff:extended;
  OutFile : TextFile;
begin
     if Form1.CheckTies.Checked then
     begin
          // output ORIGINAL array
          assignfile(OutFile,sDebugDirectory + '\randomallocation0.csv');
          rewrite(OutFile);
          writeln(OutFile,'index,real1,real2');
          for iCount :=1 to lines do
          begin
               writeln(OutFile,IntToStr(iCount) + ',' +
                               FloatToStr(dataarray[iCount].real1) + ',' +
                               FloatToStr(dataarray[iCount].real2));
          end;
          closefile(OutFile);
     end;

     SCounter:=0;
     randomize;
     for a:=1 to tests do
     begin
          iCurrentTest := a;

          RandomAllocation;

          if Form1.CheckTies.Checked then
          begin
               // output randomly allocated array
               assignfile(OutFile,sDebugDirectory + '\randomallocation' + IntToStr(a) + '.csv');
               rewrite(OutFile);
               writeln(OutFile,'index,real1,real2');
               for iCount :=1 to lines do
               begin
                    writeln(OutFile,IntToStr(iCount) + ',' +
                                    FloatToStr(dataarray[iCount].real1) + ',' +
                                    FloatToStr(dataarray[iCount].real2));
               end;
               closefile(OutFile);
          end;

          Ranks;
          Ties;
          RCoeff:=abs(Rs);
          if RCoeff>=abs(ActualCoefficient) then
            SCounter:=SCounter+1;

          // update iteration counter
          if ((a mod 100) = 0) then
          begin
               Form1.lblIteration.Caption := 'Randomisations = ' +
                                             IntToStr(a);
               Form1.Update;
          end;
     end;
     TestStat:=SCounter/tests;
end;{Function TestStats}

procedure Write_Info(const sLine : string);
begin
     writeln(OutputFile,sLine);
     Form1.OutBox.Items.Add(sLine);
     Form1.Update;
end;

Procedure Output;
{reports correlation coefficients and significance levels to the screen}

var
   Spearmanstring, Pstring : string;
begin
     //str(Spearman:6:3,Spearmanstring);
     //str(Probability:6:4,Pstring);

     //clrscr;
     Write_Info('Input file: ' + inputfilename);
     Write_Info('');
     Write_Info('Number of tests ' + Form1.EditTests.Text);
     Write_Info('Coefficient is: ' + FloatToStr(Spearman){Spearmanstring});
     Write_Info('Significance is P=' + FloatToStr(Probability){Pstring});
     Write_Info('');

end;{procedure Output}

procedure Main_spman;
begin
     iTies := 0;
     iRanks := 0;

     iCurrentTest := 0;

     Form1.lblIteration.Caption := 'Starting';
     Form1.Update;

     assignfile(OutputFile,Form1.EditOutput.Text);
     rewrite(OutputFile);

     NameInputFile;
     MakeArray;

     Output;

     closefile(OutputFile);
end;

end.