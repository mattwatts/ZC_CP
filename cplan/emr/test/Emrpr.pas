unit EMRPR;

{STANDALONE VERSION OF emrprdll.pas

 This is a modified version of EMRPA5; the main data structures
 derived from site data are arrays of pointers to records;
 written to be called by Windows E-RMS ...

 For this version, EMR is measured as the frequency of the
 rarest UNDER-represented feature, with representation measured
 against a nominated percentage target}

interface


const

  totalsites=400; {maximum number of sites in the data set}

  lines=401; {lines in the array used to change output text file}

  max=500; {maximum number of features in any site}

  totalfeatures=500; {maximum number of feature codes in region}

type

  site=record
         geocode:string[8];
         area:real;
         feature:array[1..max] of integer;
         richness:integer;
         featurearea:array[1..max] of real;
         status:string[2];
         initmaxrf:real;
         initdone:boolean;
         initord:string[3];
         subsmaxrf:real;
         subsdone:boolean;
         subsord:string[3];
       end;

  sitepointer=^site;

  featureoccurrence=record
                 code:integer;
                 count:integer;
                 rf:real;      {from first calculation}
                 initrf:real;  {copy for initialization}
                 subsrf:real;  {copy for each run with selections}
                 totalarea:real;
                 targetarea:real;
                 reservedarea:real;
                 repd:boolean;
               end;
var

  {FOR COMMUNICATION WITH WERMS}
  databasepath:string[200];
  datafile:string[100]; {dos name plus backslash}
  outputfile:string[100]; {dos name plus backslash}
  uPercentage:word; {% area of features to be represented}
  uNumMandatory:word; {number of mandatory sites to be passed}
  uNumSelections:word; {number of selected sites to be passed}

  {INTERNAL}
  sitearray:array[1..totalsites] of sitepointer;
  numfeatures:integer;
  numsites:integer;
  featurearray:array[1..totalfeatures] of featureoccurrence;
  maxrf:real;


procedure EMRPR_main;

implementation

uses
    dialogs, forms, SysUtils;

PROCEDURE StartLogBegin;
{writes to a log file in c:\werms}

var
  logfile:text;

begin
  assign(logfile,'emrdll.log');
  rewrite(logfile);
  writeln(logfile,'Beginning Function IrrepStart');
  close(logfile);
end; {Procedure StartLogBegin}


PROCEDURE GetPath;
begin
     databasepath:='c:\data\emr_test\westdiv\source';
end; {procedure GetPath}

PROCEDURE IONames;
{Sets up names and paths for input and output files}

begin
 datafile:=databasepath+'\westdiv.txt'; {input}
 outputfile:=databasepath+'\table.txt'; {output}
end;

PROCEDURE MakeArray;
{Takes the text file and converts data into an array of
site records called 'sitearray'}

const
 space=' ';

var
 b:integer;
 n:integer;
 p:integer;
 s:integer;
 z:integer;
 ch:integer;
 index:integer;
 sitenumber:integer;
 alphanumeric:char;
 sitegeocode:array[1..8] of char;
 characters:integer;
 wholenumber:integer;
 realnumber:real;
 sitearea:real;
 infile:text;
 character:char;
 x:integer;
 y:integer;

begin
 for n:=1 to totalsites do
   sitearray[n]:=nil;

    {initialises all pointers to nil to avoid wrong
     addresses for records or possible
     assignments which overwrite other memory space}

  assign(infile,datafile);
  reset(infile);
  numsites:=0;

  {assign the nominated file name to the text file variable;
   initialise numsites which will keep track of the number
   of sites in the data set}

  while not eof(infile) do
    begin
    numsites:=numsites+1;
    new(sitearray[numsites]);

    for b:=1 to max do
      sitearray[numsites]^.feature[b]:=0;

      {initialises the feature codes in all
       possible array spaces within each site
       to blanks to avoid using junk in memory in
       place of real codes in later procedures; this
       is necessary because most sites have less than
       max features so there will be extra memory
       spaces in their feature arrays which do not
       have real codes allocated to them}

    s:=0;
    repeat
      s:=s+1;
      read(infile,alphanumeric);
      sitegeocode[s]:=alphanumeric;
    until s=8;
    sitearray[numsites]^.geocode:=sitegeocode;
    index:=pos(space,sitearray[numsites]^.geocode);
    delete(sitearray[numsites]^.geocode,index,8-index+1);

      {allocate the site number from the count of sites in
       the data set; read the first line of the site record
       and copy the sitename to the array; last lines get rid
       of trailing spaces}

    readln(infile,sitearea);
    sitearray[numsites]^.area:=sitearea;

      {read the site area and go to the beginning of the
       second line}

    x:=0;
    while not eoln(infile) do
      begin
      x:=x+1;
      read(infile,wholenumber);
      sitearray[numsites]^.feature[x]:=wholenumber;
      end;
    sitearray[numsites]^.richness:=x;
    readln(infile);

    y:=0;
    while not eoln(infile) do
      begin
      y:=y+1;
      read(infile,realnumber);
      sitearray[numsites]^.featurearea[y]:=realnumber;
      end;
    readln(infile);

    end;

close(infile);
end; {Procedure MakeArray}

PROCEDURE FeatureList;
{Produces a list of features for the region}

var
  a:integer;
  n:integer;
  i:integer;
  j:integer;
  featurenumber:integer;
  newfeature:featureoccurrence;
  featurefound:boolean;
begin
  numfeatures:=0;
  for i:=1 to sitearray[1]^.richness do
    begin
    numfeatures:=numfeatures+1;
    featurearray[numfeatures].code:=sitearray[1]^.feature[i];
    end;

  {scan through the list of feature codes in the first
   site; for each feature, increment numfeatures and write the
   code to the appropriate place in the array of records
   created to store all codes and associated information}

  for n:=2 to numsites do
    for j:=1 to sitearray[n]^.richness do
      begin
      featurefound:=false;
      featurenumber:=1;
      repeat
        if sitearray[n]^.feature[j]=featurearray[featurenumber].code then
          featurefound:=true
        else
          featurenumber:=featurenumber+1;
      until (featurefound=true) or (featurenumber=numfeatures+1);

        {for each of the other site records in the array,
         scan through the list of feature codes; compare each code
         with the list of codes already produced in featurearray;
         if there is a match, change the boolean variable to 'true'
         and start again for the next code in the site being
         considered; if there is no match, increment
         the variable featurenumber and compare the same code
         with the next one on the existing list until the
         end of the list}

      if (featurefound=false) and (featurenumber=numfeatures+1) then
        begin
        numfeatures:=numfeatures+1;
        featurearray[numfeatures].code:=sitearray[n]^.feature[j];
        end;
      end;

        {if the end of the code list is reached and a match
         has not been found, increment the variable numfeatures,
         go to the end of code list and add the new one}

  for a:=1 to numfeatures do
    featurearray[a].repd:=false;

    {initialise all fields for reserved status to false}

end;{procedure FeatureList}

PROCEDURE FrequencyCalc;
{Calculates the frequency of occurrence of
 each feature in the selected region}

var
  k:integer;
  l:integer;
  m:integer;
  featurefound:boolean;
  frequency:integer;
begin
  for k:=1 to numfeatures do
    begin
    frequency:=0;
    for l:=1 to numsites do
      begin
      m:=1;
      featurefound:=false;
      repeat
        if sitearray[l]^.feature[m]=featurearray[k].code then
          featurefound:=true
        else
          m:=m+1;
      until (featurefound=true) or (m=sitearray[l]^.richness+1);
      if featurefound=true then
        begin
        frequency:=frequency+1;
        featurearray[k].count:=frequency;
        end;
      end;
    end;

    {for each code on the list in turn, check to see if
     it matches any of the codes in each site record
     in the array; if a match is found, increment the
     variable frequency and write this to the record for
     the respective code in the array of site records}

end;{procedure FrequencyCalc}

PROCEDURE Divide;
{Calculates the rarity fraction of each feature based on
 it frequency in the region}

var
  x:integer;
begin
  for x:=1 to numfeatures do
    featurearray[x].rf:=100/featurearray[x].count;

  {calculate rarity indices for each code by
   dividing 100 by the number of occurrences in
   the data set}

end;{procedure Divide}

PROCEDURE TotalArea;
{Calculates the total area of each feature in the region}

var
  a:integer;
  b:integer;
  c:integer;

begin
  for a:=1 to numfeatures do
    featurearray[a].totalarea:=0;

    {initialises all array spaces for the total area
     of each feature to zero}

  for a:=1 to numfeatures do
    for b:=1 to numsites do
      begin
      c:=0;
      repeat
        c:=c+1;
        if featurearray[a].code=sitearray[b]^.feature[c] then
          featurearray[a].totalarea:=
          featurearray[a].totalarea+sitearray[b]^.featurearea[c];
        until c=sitearray[b]^.richness;
      end;

    {look for all occurrences of each feature in the
     array of sites and accumulate the area of each}

end; {procedure TotalArea}

PROCEDURE StartLogEnd;
{writes to a log file in c:\werms}

var
  logfile:text;

begin
  assign(logfile,'emrdll.log');
  append(logfile);
  writeln(logfile,'Finishing Function IrrepStart');
  close(logfile);
end; {Procedure StartLogEnd}

PROCEDURE InitialStatus;
{Makes initial status codes zero-zero, makes all
 initdone values false (for procedure InitialSiteMax)
 and transfers rf values to initrf values (for
 procedure InitialSiteMax)}

var
  x:integer;

begin
  for x:=1 to numsites do
    sitearray[x]^.status:='00';
  for x:=1 to numsites do
    sitearray[x]^.initdone:=false;
  for x:=1 to numfeatures do
    featurearray[x].initrf:=featurearray[x].rf;
end; {procedure InitialStatus}

PROCEDURE WriteOutputFile;
{Writes the header line, list of site keys, and commas
 for later output from InitialEMRText and SubsequentEMRText;
 advantage of writing format for file with EMR code is
 that the order of site keys is the same as in the input
 file; site keys don't have to be checked for ID before
 information written from sitearray}

var
  a:integer;
  outfile:text;

begin
  assign(outfile,outputfile);
  rewrite(outfile);
  writeln(outfile,'NAME,GEOCODE,STATUS,INITEMR,INITORD,SUBSEMR,SUBSORD');
  for a:=1 to numsites-1 do
    writeln(outfile,'name,',sitearray[a]^.geocode,',,,,');
  write(outfile,'name,',sitearray[numsites]^.geocode,',,,,');
  close(outfile);
end; {Procedure WriteOutputFile}

PROCEDURE PassPCMandatory;
{Dummy procedure to set up GetPercentage to read the target
 percentage area for features and GetMandatory to read an
 array of null-terminated strings that represents
 the list of mandatory sites from WERMS}

var
   index:word;
   MArray:array[1..4] of string[3];

begin
     uPercentage:=5;
     uNumMandatory:=4;
     MArray[1]:='44';
     MArray[2]:='45';
     MArray[3]:='214';
     MArray[4]:='215'; {list of mandatory sites to be passed}
end; {procedure PassMandatory}

PROCEDURE GetPercentage;
{Reads the overall target percentage for representation
 of features from WERMS; calculates target area for each
 feature}
var
   a:integer;
begin
     for a:=1 to numfeatures do
       featurearray[a].targetarea:=
       featurearray[a].totalarea*uPercentage/100;
end; {procedure GetPercentage}

PROCEDURE GetMandatory;
{Reads an array of null-terminated strings representing a
 list of mandatory sites from WERMS and converts them to
 Pascal strings for calculation of EMR}

var
  a:integer;
  m:integer;
  MArray:array[1..100] of string[12];
  index:word;

begin
     for m:=1 to uNumMandatory do
         for a:=1 to numsites do
             if sitearray[a]^.geocode=MArray[m] then
             begin
                  sitearray[a]^.status:='R2';
                  sitearray[a]^.initmaxrf:=100;
                  sitearray[a]^.initdone:=true;
             end;

     {for each of the mandatory sites in MArray, find the matching
      name in sitearray, change status to R2, change initmaxrf to 100,
      and change initdone to true so that the site will not be
      processed by Procedure InitSiteMax}

end; {procedure GetMandatory}

PROCEDURE InitialSiteMax;
{finds the rarest code, with rarity based on
 frequency in the whole data set, in each
 site and allocates this maximum rarity
 value to the site}
var
  a:integer;
  x:integer;
  y:integer;
  z:integer;
  index:integer;
  featurerf:array[1..max] of real;
begin
  for a:=1 to numfeatures do
    if featurearray[a].repd=true then
      // make this equal to zero to be compatible with the C-Plan
      // 'rarity' arithmetic minset rule
      featurearray[a].initrf := 0;
      //featurearray[a].initrf:=100/numsites;

  {give minimum rarity values to any features that
   have been represented in applications of Procedure
   InitialEMR}

  for y:=1 to numsites do

    {calculate initmaxrf values for sites that have
     not been nominated as mandatory (and which had
     initmaxrf values assigned in Procedure Mandatorysites}

    if sitearray[y]^.initdone=false then
    {if the site has not been made mandatory or already processed
     by Procedure InitialEMR, do all the following}
      begin
      for index:=1 to max do
        featurerf[index]:=0.0;
      maxrf:=0;
      for z:=1 to sitearray[y]^.richness do
        begin
          for a:=1 to numfeatures do
            begin
            if sitearray[y]^.feature[z]=featurearray[a].code then
              begin
              index:=z;
              featurerf[index]:=featurearray[a].initrf;
              end;
            end;
        end;

   {take each site and run through the storage spaces for
    each of its feature codes; assign the rarity fraction
    for that feature to a space in the rf temporary array
    corresponding to the order of the code in the site}

      if sitearray[y]^.richness=1 then
        maxrf:=featurerf[1]
      else
        begin
        index:=1;
        maxrf:=featurerf[index];
        repeat
          index:=index+1;
          if featurerf[index]>maxrf then
            maxrf:=featurerf[index];
        until index=sitearray[y]^.richness;
        end;
      sitearray[y]^.initmaxrf:=maxrf;
      end;

    {when the temporary array of rarity fractions has
     been constructed for each site, find the highest
     value, call this maxrf and write it to the
     appropriate storage space in sitearray}

end;{procedure InitialSiteMax}

PROCEDURE InitialEMR;
{In successive applications, finds the site(s) with
highest initmaxrf and excludes those sites and the
features within them from further consideration}
var
  a:integer;
  b:integer;
  c:integer;
  d:integer;
  features:integer;
begin
  for d:=1 to numfeatures do
    featurearray[d].reservedarea:=0;
    {initialise reserved areas for all features}

  features:=0;
  a:=0;
  repeat
    a:=a+1;
    b:=0;
    repeat
      b:=b+1;
      if sitearray[b]^.initmaxrf=100/a then
        begin
        sitearray[b]^.initdone:=true;
        {no further processing by Procedure InitialSitemax}
        if (sitearray[b]^.initmaxrf=100) and
           (sitearray[b]^.status<>'R2') then
           sitearray[b]^.status:='Un';
           {site has initmaxrf of 100 because of unique features only}
        for c:=1 to sitearray[b]^.richness do
          begin
          d:=0;
          repeat
            d:=d+1;
          until sitearray[b]^.feature[c]=featurearray[d].code;
          featurearray[d].reservedarea:=
            featurearray[d].reservedarea+sitearray[b]^.featurearea[c];
          end;
        end;
    until b=numsites;

      {for each of the possible values of initmaxrf, run through
       the list of sites in the array; for each of the sites with
       the respective maxrf value, look at each feature code in
       turn and check it against the complete list of codes
       in featurearray; when a match is found, increase the
       reserved area of the feature by the area that occurs in
       the site}

    for d:=1 to numfeatures do
      if (featurearray[d].reservedarea>=featurearray[d].targetarea)
         and (featurearray[d].repd=false) then
         begin
         featurearray[d].repd:=true;
         features:=features+1;
         end;

      {after sites with each value of maxrf have been processed,
       check to see how many more features are represented}

    InitialSitemax;
  until features=numfeatures;
end;{procedure InitialEMR}

PROCEDURE InitOrdinalEMR;
{Converts initial EMR (real) values to ordinal values which relate
 to WERMS legend codes}

var
  a:integer;
  n:integer;

begin
  for a:=1 to numsites do
    begin
    if sitearray[a]^.initmaxrf=100/1 then
      sitearray[a]^.initord:='001';
    if sitearray[a]^.initmaxrf=100/2 then
      sitearray[a]^.initord:='002';
    if sitearray[a]^.initmaxrf=100/3 then
      sitearray[a]^.initord:='003';
    if sitearray[a]^.initmaxrf=100/4 then
      sitearray[a]^.initord:='004';
    if sitearray[a]^.initmaxrf=100/5 then
      sitearray[a]^.initord:='005';
    if sitearray[a]^.initmaxrf=100/6 then
      sitearray[a]^.initord:='006';
    if sitearray[a]^.initmaxrf=100/7 then
      sitearray[a]^.initord:='007';
    if sitearray[a]^.initmaxrf=100/8 then
      sitearray[a]^.initord:='008';
    if sitearray[a]^.initmaxrf=100/9 then
      sitearray[a]^.initord:='009';
    if sitearray[a]^.initmaxrf=100/10 then
      sitearray[a]^.initord:='010';

    for n:=11 to 15 do
      if sitearray[a]^.initmaxrf=100/n then
        sitearray[a]^.initord:='011';
    for n:=16 to 20 do
      if sitearray[a]^.initmaxrf=100/n then
        sitearray[a]^.initord:='012';
    for n:=21 to 30 do
      if sitearray[a]^.initmaxrf=100/n then
        sitearray[a]^.initord:='013';
    for n:=31 to 50 do
      if sitearray[a]^.initmaxrf=100/n then
        sitearray[a]^.initord:='014';
    for n:=51 to 100 do
      if sitearray[a]^.initmaxrf=100/n then
        sitearray[a]^.initord:='015';
    for n:=101 to numsites-1 do
      if sitearray[a]^.initmaxrf=100/n then
        sitearray[a]^.initord:='016';

    if sitearray[a]^.initmaxrf=100/numsites then
      sitearray[a]^.initord:='999';
    end;
  end; {procedure InitOrdinalEMR}

PROCEDURE TransferValues;
{Copies values from initmaxrf and initord to subsmaxrf and
 subsord so that WERMS can read initial emr values from subsord
 field (from which it will read during selection process)
 unless otherwise instructed}

var
  a:integer;

begin
  for a:=1 to numsites do
    begin
    sitearray[a]^.subsmaxrf:=sitearray[a]^.initmaxrf;
    sitearray[a]^.subsord:=sitearray[a]^.initord;
    end;
end; {procedure TransferValues}

PROCEDURE InitialEMRText;
{Writes the results of InitialEMR and InitOrdinalEMR to a comma
 delimited text file which can be read by WERMS}

{Structure of output file:
 1. NAME (ACTUAL NAME FROM MAP): string;
 2. GEOCODE (CODE FOR IDENTITY OF CENTROID): string;
 3. STATUS (CODE FOR MANDATORY, UNIQUE, SELECTED): string[2];
 4. INITEMR (INITIAL EMR VALUE): real;
 5. INITORD (ORDINAL FOR INITIAL EMR VALUE): string[3];
 6. SUBSEMR (SUBSEQUENT EMR VALUE): real;
 7. SUBSORD (ORDINAL FOR SUBSEQUENT EMR VALUE): string[3]}

type
  memoryline=string[100];
  linepointer=^memoryline;

var
  a:integer;
  n:integer;
  s:integer;
  t:integer;
  x:integer;
  match:boolean;
  teststring:string[8];
  line:string[100];
  initemrfile:text;
  linearray:array[1..lines] of linepointer;
  initemrstring:string[6];
  subsemrstring:string[6];

begin
  assign(initemrfile,outputfile);
  reset(initemrfile);
  n:=0;
  for n:=1 to numsites+1 do
    begin
    readln(initemrfile,line);
    new(linearray[n]);
    linearray[n]^:=line;
    end;
  for n:=2 to numsites+1 do {first line is the header}
    begin
    teststring:='        '; {eight blanks}
    x:=0;
    repeat
      x:=x+1;
    until linearray[n]^[x]=',';
    {find the first comma (following site name)}
    t:=0;
    repeat
      x:=x+1;
      t:=t+1;
      teststring[t]:=linearray[n]^[x];
    until linearray[n]^[x]=',';
    {find the second comma (following site geocode)}

    delete(teststring,t,8-t+1);
    {get rid of the comma from the string}

    a:=0;
    match:=false;
    repeat
      a:=a+1;
      if teststring=sitearray[a]^.geocode then
        match:=true;
    until (teststring=sitearray[a]^.geocode) or (a=numsites);
    if (a=numsites) and (not match) then
      begin
      messagedlg
      ('GEOCODE USED BY EXTERNAL PROGRAM HAS NO MATCH IN DBMS FILE.' +
       'PROBLEM IN EXTERNAL PROGRAM',mtError,[mbOk],0);
      Halt;
      end;

    {find the record in sitearray that corresponds to the file line;
     write an error message if there is no match}

    {NAME AND GEOCODE}
    linearray[n]^:=copy(linearray[n]^,1,x);
    {truncate after the second comma (following geocode)}

    {STATUS CODE:}
    linearray[n]^:=linearray[n]^+sitearray[a]^.status+',';

    {INITEMR:}
    str(sitearray[a]^.initmaxrf:6:2,initemrstring);
    linearray[n]^:=linearray[n]^+initemrstring+',';

    {INITORD:}
    linearray[n]^:=linearray[n]^+sitearray[a]^.initord+',';

    {SUBSEMR:}
    str(sitearray[a]^.subsmaxrf:6:2,subsemrstring);
    linearray[n]^:=linearray[n]^+subsemrstring+',';

    {SUBSORD:}
    linearray[n]^:=linearray[n]^+sitearray[a]^.subsord;
    end;

rewrite(initemrfile);
for n:=1 to numsites do
  writeln(initemrfile,linearray[n]^);
write(initemrfile,linearray[numsites+1]^);
close(initemrfile);
for n:=1 to numsites+1 do
  dispose(linearray[n]);
end; {procedure InitialEMRText}

PROCEDURE PassSelections;
{Dummy procedure to set up GetSelections to read
 an array of null-terminated strings that represents
 the list of selected sites from WERMS}

var
   lSArray:word;
   index:word;
   SArray:array[1..4] of string[3];
begin
     uNumSelections:=4;
     SArray[1]:='120';
     SArray[2]:='121';
     SArray[3]:='320';
     SArray[4]:='321'; {list of selected sites to be passed}
     lSArray:=17;
     {length of string array - sum of all Pascal strings + 1
      for each string + 1 for extra terminating null}

     {after copying the Pascal string the pointer is at the
      beginning of the null terminated string; increment the pointer
      until the terminating null, then advance it to point to the next
      vacant space; after doing this for each string, add a second
      terminating null to the end of the array}

end; {procedure PassSelections}

PROCEDURE SubsequentStatus;
{for each call of selection function from WERMS,
 re-initializes field to indicate which sites have been
 dealt with by procedure SubsequentEMR (for processing by
 procedure SubsequentSiteMax); also initializes repd field
 in featurearray so that SubsequentSiteMax and SubsequentEMR
 can operate}

var
  x:integer;
  y:integer;

begin
  for x:=1 to numsites do
    if sitearray[x]^.status='R2' then
      sitearray[x]^.subsdone:=true
    else sitearray[x]^.subsdone:=false;
  for y:=1 to numfeatures do
    begin
    featurearray[y].repd:=false;
    featurearray[y].subsrf:=featurearray[y].rf;
    end;
    {re-initialize repd values for all features and
     refresh subsrf values for each application of
     IrrepRun from WERMS}
end; {procedure SubsequentStatus}

PROCEDURE GetSelections;
{Reads an array of null-terminated strings representing a
 list of selected sites from WERMS and converts them to
 Pascal strings for calculation of EMR}
var
  a:integer;
  m:integer;
  SArray:array[1..100] of string[12];
  index:word;
begin
 for m:=1 to uNumSelections do
   for a:=1 to numsites do
     if sitearray[a]^.geocode=SArray[m] then
       begin
       sitearray[a]^.status:='Se';
       sitearray[a]^.subsmaxrf:=100;
       sitearray[a]^.subsdone:=true;
       {subsmaxrf values for mandatory sites already set to 100
        by procedure TransferValues; these values will remain
        unchanged by later procedures because subsdone values
        for mandatory sites set to true in procedure SubsequentStatus}
       end;

  {for each of the selected sites in SArray, find the matching
   name in sitearray, change status to Se, change subsmaxrf to 100,
   and change subsdone to true so that the site will not be
   processed by Procedure SubsequentSiteMax}

end; {procedure GetSelections}

PROCEDURE SubsequentSiteMax;
{finds the rarest code, with rarity based on
 frequency in the whole data set, in each
 site and allocates this maximum rarity
 value to the site}
var
  a:integer;
  x:integer;
  y:integer;
  z:integer;
  index:integer;
  featurerf:array[1..max] of real;
begin
  for a:=1 to numfeatures do
    if featurearray[a].repd=true then
      featurearray[a].subsrf:=100/numsites;

  {give minimum rarity values to any features that
   have been represented in applications of Procedure
   SubsequentEMR}

  for y:=1 to numsites do

    {calculate subsmaxrf values for sites that have
     not been nominated as mandatory or selected (and which
     had initmaxrf or subsmaxrf values assigned in Procedures
     GetMandatory or GetSelections}

    if sitearray[y]^.subsdone=false then
    {if the site has not been made mandatory, selected or
     already processed by Procedure SubsequentEMR,
     do all the following}
      begin
      for index:=1 to max do
        featurerf[index]:=0.0;
      maxrf:=0;
      for z:=1 to sitearray[y]^.richness do
        begin
          for a:=1 to numfeatures do
            begin
            if sitearray[y]^.feature[z]=featurearray[a].code then
              begin
              index:=z;
              featurerf[index]:=featurearray[a].subsrf;
              end;
            end;
        end;

   {take each site and run through the storage spaces for
    each of its feature codes; assign the rarity fraction
    for that feature to a space in the rf temporary array
    corresponding to the order of the code in the site}

      if sitearray[y]^.richness=1 then
        maxrf:=featurerf[1]
      else
        begin
        index:=1;
        maxrf:=featurerf[index];
        repeat
          index:=index+1;
          if featurerf[index]>maxrf then
            maxrf:=featurerf[index];
        until index=sitearray[y]^.richness;
        end;
      sitearray[y]^.subsmaxrf:=maxrf;
      end;

    {when the temporary array of rarity fractions has
     been constructed for each site, find the highest
     value, call this maxrf and write it to the
     appropriate storage space in sitearray}

end;{procedure SubsequentSiteMax}

PROCEDURE SubsequentEMR;
{In successive applications, finds the site(s) with
highest subsmaxrf and excludes those sites and the
features within them from further consideration}
var
  a:integer;
  b:integer;
  c:integer;
  d:integer;
  features:integer;
begin
  for d:=1 to numfeatures do
    featurearray[d].reservedarea:=0;
    {initialise reserved areas for all features}

  features:=0;
  a:=0;
  repeat
    a:=a+1;
    b:=0;
    repeat
      b:=b+1;
      if sitearray[b]^.subsmaxrf=100/a then
        begin
        sitearray[b]^.subsdone:=true;
        {no further processing by Procedure SubsequentSitemax}
        for c:=1 to sitearray[b]^.richness do
          begin
          d:=0;
          repeat
            d:=d+1;
          until sitearray[b]^.feature[c]=featurearray[d].code;
          featurearray[d].reservedarea:=
            featurearray[d].reservedarea+sitearray[b]^.featurearea[c];
          end;
        end;
    until b=numsites;

      {for each of the possible values of initmaxrf, run through
       the list of sites in the array; for each of the sites with
       the respective maxrf value, look at each feature code in
       turn and check it against the complete list of codes
       in featurearray; when a match is found, increase the
       reserved area of the feature by the area that occurs in
       the site}

    for d:=1 to numfeatures do
      if (featurearray[d].reservedarea>=featurearray[d].targetarea)
         and (featurearray[d].repd=false) then
         begin
         featurearray[d].repd:=true;
         features:=features+1;
         end;

      {after sites with each value of maxrf have been processed,
       check to see how many more features are represented}

    SubsequentSiteMax;
  until features=numfeatures;
end;{procedure SubsequentEMR}

PROCEDURE SubsOrdinalEMR;
{Converts subsequent EMR (real) values to ordinal values which relate
 to WERMS legend codes}

var
  a:integer;
  n:integer;

begin
  for a:=1 to numsites do
    begin
    if sitearray[a]^.subsmaxrf=100/1 then
      sitearray[a]^.subsord:='001';
    if sitearray[a]^.subsmaxrf=100/2 then
      sitearray[a]^.subsord:='002';
    if sitearray[a]^.subsmaxrf=100/3 then
      sitearray[a]^.subsord:='003';
    if sitearray[a]^.subsmaxrf=100/4 then
      sitearray[a]^.subsord:='004';
    if sitearray[a]^.subsmaxrf=100/5 then
      sitearray[a]^.subsord:='005';
    if sitearray[a]^.subsmaxrf=100/6 then
      sitearray[a]^.subsord:='006';
    if sitearray[a]^.subsmaxrf=100/7 then
      sitearray[a]^.subsord:='007';
    if sitearray[a]^.subsmaxrf=100/8 then
      sitearray[a]^.subsord:='008';
    if sitearray[a]^.subsmaxrf=100/9 then
      sitearray[a]^.subsord:='009';
    if sitearray[a]^.subsmaxrf=100/10 then
      sitearray[a]^.subsord:='010';

    for n:=11 to 15 do
      if sitearray[a]^.subsmaxrf=100/n then
        sitearray[a]^.subsord:='011';
    for n:=16 to 20 do
      if sitearray[a]^.subsmaxrf=100/n then
        sitearray[a]^.subsord:='012';
    for n:=21 to 30 do
      if sitearray[a]^.subsmaxrf=100/n then
        sitearray[a]^.subsord:='013';
    for n:=31 to 50 do
      if sitearray[a]^.subsmaxrf=100/n then
        sitearray[a]^.subsord:='014';
    for n:=51 to 100 do
      if sitearray[a]^.subsmaxrf=100/n then
        sitearray[a]^.subsord:='015';
    for n:=101 to numsites-1 do
      if sitearray[a]^.subsmaxrf=100/n then
        sitearray[a]^.subsord:='016';

    if sitearray[a]^.subsmaxrf=100/numsites then
      sitearray[a]^.subsord:='999';
    end;
  end; {procedure SubsOrdinalEMR}

PROCEDURE SubsequentEMRText;
{Writes the results of SubsequentEMR and SubsOrdinalEMR to a comma
 delimited text file which can be read by WERMS}

{Structure of output file:
 1. NAME (ACTUAL NAME FROM MAP): string;
 2. GEOCODE (CODE FOR IDENTITY OF CENTROID): string;
 3. STATUS (CODE FOR MANDATORY, UNIQUE, SELECTED): string[2];
 4. INITEMR (INITIAL EMR VALUE): real;
 5. INITORD (ORDINAL FOR INITIAL EMR VALUE): string[3];
 6. SUBSEMR (SUBSEQUENT EMR VALUE): real;
 7. SUBSORD (ORDINAL FOR SUBSEQUENT EMR VALUE): string[3]}

type
  memoryline=string[100];
  linepointer=^memoryline;

var
  a:integer;
  n:integer;
  s:integer;
  t:integer;
  x:integer;
  comma:integer;
  match:boolean;
  teststring:string[8];
  line:string[100];
  initemrfile:text;
  linearray:array[1..lines] of linepointer;
  initemrstring:string[6];
  subsemrstring:string[6];

begin
  assign(initemrfile,outputfile);
  reset(initemrfile);
  n:=0;
  for n:=1 to numsites+1 do
    begin
    readln(initemrfile,line);
    new(linearray[n]);
    linearray[n]^:=line;
    end;
  for n:=2 to numsites+1 do {first line is the header}
    begin
    teststring:='        '; {eight blanks}
    x:=0;
    repeat
      x:=x+1;
    until linearray[n]^[x]=',';
    {find the first comma (following site name)}
    t:=0;
    repeat
      x:=x+1;
      t:=t+1;
      teststring[t]:=linearray[n]^[x];
    until linearray[n]^[x]=',';
    {find the second comma (following site geocode)}

    delete(teststring,t,8-t+1);
    {get rid of the comma from the string}

    a:=0;
    match:=false;
    repeat
      a:=a+1;
      if teststring=sitearray[a]^.geocode then
        match:=true;
    until (teststring=sitearray[a]^.geocode) or (a=numsites);
    if (a=numsites) and (not match) then
      begin
      messagedlg
      ('GEOCODE USED BY EXTERNAL PROGRAM HAS NO MATCH IN DBMS FILE' +
       'PROBLEM IN EXTERNAL PROGRAM',mtError,[mbOk],0);
      Halt;
      end;

    {find the record in sitearray that corresponds to the file line;
     write an error message if there is no match}

    if sitearray[a]^.status='Se' then
      begin
      linearray[n]^[x+1]:=sitearray[a]^.status[1];
      linearray[n]^[x+2]:=sitearray[a]^.status[2];
      end;

    {update status code if the site has been selected}
    {x at the second comma - after the site geocode}

    comma:=2;
    repeat
      repeat
        x:=x+1
      until linearray[n]^[x]=',';
    comma:=comma+1;
    until comma=5;
    {find the position in the array of the fifth comma in the
     string for the site}

    linearray[n]^:=copy(linearray[n]^,1,x);
    {trim off the characters following the fifth comma in the
     string for the site}

    {SUBSEMR:}
    str(sitearray[a]^.subsmaxrf:6:2,subsemrstring);
    linearray[n]^:=linearray[n]^+subsemrstring+',';

    {SUBSORD:}
    linearray[n]^:=linearray[n]^+sitearray[a]^.subsord;
    end;

rewrite(initemrfile);
for n:=1 to numsites do
  writeln(initemrfile,linearray[n]^);
write(initemrfile,linearray[numsites+1]^);
close(initemrfile);
for n:=1 to numsites+1 do
  dispose(linearray[n]);
end; {procedure SubsequentEMRText}

PROCEDURE FreeMemory;
{called by WERMS just prior to exit from
 Irreplaceability module; disposes of any memory
 committed by the EMR dll}

var
  a:integer;

begin
  for a:=1 to numsites do
    dispose(sitearray[a]);
end;

procedure SaveSiteList(const sOutputSiteFile : string);
var
   iFeatureCount, iSiteCount, iCount, iFeatureToWrite : integer;
   sFeatureToWrite : string;
   OutputSiteFile : TextFile;
begin
     assignfile(OutputSiteFile,sOutputSiteFile);
     rewrite(OutputSiteFile);
     writeln(OutputSiteFile,'SiteIndex,SiteKey');

     for iSiteCount := 1 to numsites do
     begin
          writeln(OutputSiteFile,IntToStr(iSiteCount) + ',' + sitearray[iSiteCount]^.geocode);
     end;
     closefile(OutputSiteFile);
end;

procedure SaveFeatureList(const sOutputFeatureFile : string);
var
   iFeatureCount, iSiteCount, iCount, iFeatureToWrite : integer;
   sFeatureToWrite : string;
   OutputFeatureFile : TextFile;
begin
     assignfile(OutputFeatureFile,sOutputFeatureFile);
     rewrite(OutputFeatureFile);
     writeln(OutputFeatureFile,'FeatureIndex,FeatureKey');
     for iFeatureCount := 1 to numfeatures do
         writeln(OutputFeatureFile,IntToStr(iFeatureCount) + ',' + IntToStr(featurearray[iFeatureCount].code));

     closefile(OutputFeatureFile);
end;

procedure SaveMatrixToCSVFile(const sOutputMatrixFile : string);
var
   iFeatureCount, iSiteCount, iCount, iFeatureToWrite : integer;
   sFeatureToWrite : string;
   OutputMatrixFile : TextFile;
begin
     assignfile(OutputMatrixFile,sOutputMatrixFile);
     rewrite(OutputMatrixFile);
     write(OutputMatrixFile,'Sites,');
     for iFeatureCount := 1 to numfeatures do
         if (iFeatureCount = numfeatures) then
            writeln(OutputMatrixFile,IntToStr(featurearray[iFeatureCount].code))
         else
             write(OutputMatrixFile,IntToStr(featurearray[iFeatureCount].code) + ',');

     for iSiteCount := 1 to numsites do
     begin
          write(OutputMatrixFile,sitearray[iSiteCount]^.geocode + ',');
          for iFeatureCount := 1 to numfeatures do
          begin
               iFeatureToWrite := 0;

               if (sitearray[iSiteCount]^.richness > 0) then
                  for iCount := 1 to sitearray[iSiteCount]^.richness do
                      if (sitearray[iSiteCount]^.feature[iCount] = featurearray[iFeatureCount].code) then
                         iFeatureToWrite := iCount;

               if (iFeatureToWrite = 0) then
                  sFeatureToWrite := '0'
               else
                   sFeatureToWrite := FloatToStr(sitearray[iSiteCount]^.featurearea[iFeatureToWrite]);

               if (iFeatureCount = numfeatures) then
                  writeln(OutputMatrixFile,sFeatureToWrite)
               else
                   write(OutputMatrixFile,sFeatureToWrite + ',');
          end;
     end;
     closefile(OutputMatrixFile);
end;

procedure EMRPR_main;
begin
     StartLogBegin; {***}
     GetPath;
     IONames;
     MakeArray;
     FeatureList;

     //SaveSiteList('c:\sitelist.csv');
     //SaveFeatureList('c:\featlist.csv');
     //SaveMatrixToCSVFile('c:\matrix.csv');

     FrequencyCalc;
     Divide;
     TotalArea;
     StartLogEnd; {***}
     InitialStatus;
     WriteOutputFile;

     //PassPCMandatory;
     GetPercentage;
     //GetMandatory;
     InitialSiteMax;
     InitialEMR;
     InitOrdinalEMR;
     TransferValues;
     InitialEMRText;

     //PassSelections;
     SubsequentStatus;
     //GetSelections;
     SubsequentSitemax;
     SubsequentEMR;
     SubsOrdinalEMR;
     SubsequentEMRText;

     FreeMemory;
end;

end.
