PROGRAM EMRPA;

{STANDALONE VERSION OF emrpadll.pas

 This is a modified version of EMRPA5; the main data structures
 derived from site data are arrays of pointers to records;
 written as prototype for interface with Windows E-RMS}

uses WinCrt,WinAPI,Strings;

const

  totalsites=400; {maximum number of sites in the data set}
  lines=401; {lines in the array used to change output text file}

  max=30; {maximum number of features in any site}

  totalfeatures=100; {maximum number of feature codes in region}

  pad=4;

type

  site=record
         name:string[12];
         no:integer;
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
                 repd:boolean;
               end;
var

  {FOR COMMUNICATION WITH WERMS}
  hDatabasePath:word; {handle for database path; asciiz from WERMS}
  databasepath:string[80];
  datafile:string[100]; {dos name plus backslash}
  outputfile:string[100]; {dos name plus backslash}
  uNumMandatory:word; {number of mandatory sites to be passed}
  hMArray:word;{handle for mandatory array; asciiz from WERMS}
  uNumSelections:word; {number of selected sites to be passed}
  hSArray:word; {handle for selected array; asciiz from WERMS}

  {INTERNAL}
  sitearray:array[1..totalsites] of sitepointer;
  numfeatures:integer;
  numsites:integer;
  featurearray:array[1..totalfeatures] of featureoccurrence;
  maxrf:real;

 PROCEDURE PassPath;
 {Dummy procedure to set up GetPath to read a
  null-terminated string from WERMS as part of the
  interactive system; passes the path of the directory
  (as a null-terminated string) where all files will be
  created}

 var
   path:string[17];
   lPath:word;
   pPath:PChar;

 begin
   path:='c:\programs\emrpa';
   lPath:=19;
   hDatabasePath:=GlobalAlloc(gmem_moveable,lPath); {global}
   pPath:=GlobalLock(hDatabasePath);
   StrPCopy(pPath,path);
   repeat
     pPath:=pPath+1;
   until pPath^=#0;
   pPath:=pPath+1;
   pPath^:=#0;
   {add a second null to the end of the null string}
   GlobalUnlock(hDatabasePath);
 end; {procedure PassPath}

 PROCEDURE GetPath;
 {Reads the data base path passed by WERMS as a null-
  terminated string and converts it to a length byte string}

 var
   pPath:PChar;

 begin
   pPath:=GlobalLock(hDatabasePath);
   databasepath:=StrPas(pPath);
   {length of Pascal string = length of string passed}
   GlobalUnlock(hDatabasePath);
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
   sitename:array[1..12] of char;
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

      sitearray[numsites]^.no:=numsites;
      s:=0;
      repeat
        s:=s+1;
        read(infile,alphanumeric);
        sitename[s]:=alphanumeric;
      until s=12;
      sitearray[numsites]^.name:=sitename;
      index:=pos(space,sitearray[numsites]^.name);
      delete(sitearray[numsites]^.name,index,12-index+1);

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
    writeln(outfile,'RECORD_ID,STATUS,INITEMR,INITORD,SUBSEMR,SUBSORD');
    for a:=1 to numsites-1 do
      writeln(outfile,sitearray[a]^.name,',,,,,');
    write(outfile,sitearray[numsites]^.name,',,,,,');
    close(outfile);
  end; {Procedure WriteOutputFile}

  PROCEDURE PassMandatory;
  {Dummy procedure to set up GetMandatory to read
   an array of null-terminated strings that represents
   the list of mandatory sites from WERMS}

  var
    lMArray:word;
    pMArray:PChar;
    index:word;
    MArray:array[1..4] of string[3];

  begin
    uNumMandatory:=4;
    MArray[1]:='033';
    MArray[2]:='034';
    MArray[3]:='035';
    MArray[4]:='036'; {list of mandatory sites to be passed}
    lMArray:=17;
    {length of string array - sum of all Pascal strings + 1
     for each string + 1 for extra terminating null}
    hMArray:=GlobalAlloc(gmem_moveable,lMArray);
    pMArray:=GlobalLock(hMArray);
    index:=0;
    repeat
      index:=index+1;
      StrPCopy(pMArray,MArray[index]);
      repeat
        pMArray:=pMArray+1;
      until pMArray^=#0;
      pMArray:=pMArray+1;
    until index=uNumMandatory;
    pMArray^:=#0;

    {after copying the Pascal string the pointer is at the
     beginning of the null terminated string; increment the pointer
     until the terminating null, then advance it to point to the next
     vacant space; after doing this for each string, add a second
     terminating null to the end of the array}

    GlobalUnlock(hMArray);
  end; {procedure PassMandatory}

  PROCEDURE GetMandatory;
  {Reads an array of null-terminated strings representing a
   list of mandatory sites from WERMS and converts them to
   Pascal strings for calculation of EMR}

  var
    a:integer;
    m:integer;
    MArray:array[1..100] of string[12];
    index:word;
    pMArray:PChar;

  begin
   pMArray:=GlobalLock(hMArray);
   index:=1;
   repeat
     MArray[index]:=StrPas(pMArray); {no trailing spaces}
     repeat
       pMArray:=pMArray+1;
     until pMArray^=#0;
   pMArray:=pMArray+1;
   index:=index+1;
   until pMArray^=#0;

   {convert null strings one at a time to Pascal strings; final
    double terminating null indicates end of array}

   GlobalUnlock(hMArray);

   for m:=1 to uNumMandatory do
     for a:=1 to numsites do
       if sitearray[a]^.name=MArray[m] then
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
        featurearray[a].initrf:=100/numsites;

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
            for d:=1 to numfeatures do
              if (sitearray[b]^.feature[c]=featurearray[d].code)
              and (featurearray[d].repd=false) then
                begin
                featurearray[d].repd:=true;
                features:=features+1;
                end;
          end;
      until b=numsites;

        {for each of the possible values of initmaxrf, run through
         the list of sites in the array; if the initmaxrf of any
         site matches the one being sought, change the boolean
         variable 'sitefound' to true; for each of the site records
         with the respective initmaxrf value, look at each feature
         code in turn and check it against the complete list of codes
         in featurearray; when a match is found, tag the feature as
         represented to indicate that it is no longer to be included
         in assessments of rarity fractions or initmaxrf; increment
         the variable 'features' to indicate how many features
         are represented in the sites listed so far; continue
         this process until all features are represented}

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
   1. RECORD_ID (SITE KEY): string;
   2. STATUS (CODE FOR MANDATORY, UNIQUE, SELECTED): string[2];
   3. INITEMR (INITIAL EMR VALUE): real;
   4. INITORD (ORDINAL FOR INITIAL EMR VALUE): string[3];
   5. SUBSEMR (SUBSEQUENT EMR VALUE): real;
   6. SUBSORD (ORDINAL FOR SUBSEQUENT EMR VALUE): string[3]}

  type
    memoryline=string[100];
    linepointer=^memoryline;

  var
    a:integer;
    n:integer;
    s:integer;
    x:integer;
    teststring:string[12];
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
      teststring:='            '; {twelve blanks}
      x:=0;
      repeat
        x:=x+1;
        teststring[x]:=linearray[n]^[x];
      until linearray[n]^[x]=',';
      delete(teststring,x,12-x+1);
      {get rid of the comma from the string and any trailing blanks}
      a:=0;
      repeat
        a:=a+1;
      until teststring=sitearray[a]^.name;
      {find the record in sitearray that corresponds to the file line}

      {RECORD_ID:}
      linearray[n]^:=teststring+',';

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
    pSArray:PChar;
    index:word;
    SArray:array[1..4] of string[3];

  begin
    uNumSelections:=4;
    SArray[1]:='016';
    SArray[2]:='017';
    SArray[3]:='018';
    SArray[4]:='019'; {list of selected sites to be passed}
    lSArray:=17;
    {length of string array - sum of all Pascal strings + 1
     for each string + 1 for extra terminating null}
    hSArray:=GlobalAlloc(gmem_moveable,lSArray);
    pSArray:=GlobalLock(hSArray);
    index:=0;
    repeat
      index:=index+1;
      StrPCopy(pSArray,SArray[index]);
      repeat
        pSArray:=pSArray+1;
      until pSArray^=#0;
      pSArray:=pSArray+1;
    until index=uNumSelections;
    pSArray^:=#0;

    {after copying the Pascal string the pointer is at the
     beginning of the null terminated string; increment the pointer
     until the terminating null, then advance it to point to the next
     vacant space; after doing this for each string, add a second
     terminating null to the end of the array}

    GlobalUnlock(hSArray);
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
    pSArray:PChar;

  begin
   pSArray:=GlobalLock(hSArray);
   index:=1;
   repeat
     SArray[index]:=StrPas(pSArray);  {no trailing spaces}
     repeat
       pSArray:=pSArray+1;
     until pSArray^=#0;
   pSArray:=pSArray+1;
   index:=index+1;
   until pSArray^=#0;

   {convert null strings one at a time to Pascal strings; final
    double terminating null indicates end of array}

   GlobalUnlock(hSArray);

   for m:=1 to uNumSelections do
     for a:=1 to numsites do
       if sitearray[a]^.name=SArray[m] then
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
            for d:=1 to numfeatures do
              if (sitearray[b]^.feature[c]=featurearray[d].code)
              and (featurearray[d].repd=false) then
                begin
                featurearray[d].repd:=true;
                features:=features+1;
                end;
          end;
      until b=numsites;

        {for each of the possible values of subsmaxrf, run through
         the list of sites in the array; if the subsmaxrf of any
         site matches the one being sought, change the boolean
         variable 'sitefound' to true; for each of the site records
         with the respective subsmaxrf value, look at each feature
         code in turn and check it against the complete list of codes
         in featurearray; when a match is found, tag the feature as
         represented to indicate that it is no longer to be included
         in assessments of rarity fractions or subsmaxrf; increment
         the variable 'features' to indicate how many features
         are represented in the sites listed so far; continue
         this process until all features are represented}

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
   1. RECORD_ID (SITE KEY): string;
   2. STATUS (CODE FOR MANDATORY, UNIQUE, SELECTED): string[2];
   3. INITEMR (INITIAL EMR VALUE): real;
   4. INITORD (ORDINAL FOR INITIAL EMR VALUE): string[3];
   5. SUBSEMR (SUBSEQUENT EMR VALUE): real;
   6. SUBSORD (ORDINAL FOR SUBSEQUENT EMR VALUE): string[3]}

  type
    memoryline=string[100];
    linepointer=^memoryline;

  var
    a:integer;
    n:integer;
    s:integer;
    x:integer;
    comma:integer;
    teststring:string[12];
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
      teststring:='            '; {twelve blanks}
      x:=0;
      repeat
        x:=x+1;
        teststring[x]:=linearray[n]^[x];
      until linearray[n]^[x]=',';
      delete(teststring,x,12-x+1);
      {get rid of the comma from the string and any trailing blanks}
      a:=0;
      repeat
        a:=a+1;
      until teststring=sitearray[a]^.name;
      {find the record in sitearray that corresponds to the file line}
      {x currently at the first comma - after the site key}

      if sitearray[a]^.status='Se' then
      linearray[n]^[x+1]:=sitearray[a]^.status[1];
      linearray[n]^[x+2]:=sitearray[a]^.status[2];

      {update status code if the site has been selected}
      {x still at the first comma - after the site key}

      comma:=1;
      repeat
        repeat
          x:=x+1
        until linearray[n]^[x]=',';
      comma:=comma+1;
      until comma=4;
      {find the position in the array of the fourth comma in the
       string for the site}

      delete(linearray[n]^,x+1,10);
      {trim off the last 10 characters of the string after the
       fourth comma; these are subsemr (6), a comma, and subsord (3)}

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

begin
  PassPath;
  GetPath;
  IONames;
  MakeArray;
  FeatureList;
  FrequencyCalc;
  Divide;
  InitialStatus;
  WriteOutputFile;

  PassMandatory;
  GetMandatory;
  InitialSiteMax;
  InitialEMR;
  InitOrdinalEMR;
  TransferValues;
  InitialEMRText;

  PassSelections;
  SubsequentStatus;
  GetSelections;
  SubsequentSitemax;
  SubsequentEMR;
  SubsOrdinalEMR;
  SubsequentEMRText;
end.
