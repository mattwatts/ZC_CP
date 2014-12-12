procedure mergecsv;
var
   filename : string[20];
   infile : array[1..10] of text;
   outfile : text;
   c : array[1..20000] of char;
   files,i,j,count,row : integer;
   ch : char;
begin
   write ('number of files : ');
   readln (files);
   for i:=1 to files do
   begin
      write ('file ',i,' : ');
      readln (filename);
      assign (infile[i],filename);
      reset (infile[i]);
   end;
   write ('output file : ');
   readln (filename);
   assign (outfile,filename);
   rewrite (outfile);
   row:=0;
   while not eof(infile[1]) do
   begin
      row:=row+1;
      writeln (row);
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
end;