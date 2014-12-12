unit JoinDBFTables_puvspr;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Db, DBTables;

type
  TJoinDBFTablesForm = class(TForm)
    Label1: TLabel;
    EditInputPath: TEdit;
    RadioGroupFeatureIndexType: TRadioGroup;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    btnBrowse: TButton;
    Table1: TTable;
    CheckSPORDER: TCheckBox;
    CheckPUDAT: TCheckBox;
    CheckSPECDAT: TCheckBox;
    CheckConvertM2: TCheckBox;
    CheckSummary: TCheckBox;
    CheckCPlan: TCheckBox;
    Query1: TQuery;
    CheckCK1: TCheckBox;
    CheckCreateMarZone: TCheckBox;
    Label2: TLabel;
    EditZoneCount: TEdit;
    CheckSkipFirstDBFColumn: TCheckBox;
    procedure btnBrowseClick(Sender: TObject);
    procedure ExecuteTableJoin;
    procedure ProcessOutputFiles;
    procedure BitBtn1Click(Sender: TObject);
    procedure ParsePUDAT;
    procedure ParseSPECDAT;
    procedure CreateINPUTDAT;
    procedure CheckPUDATClick(Sender: TObject);
    procedure CheckSPECDATClick(Sender: TObject);
    procedure MaskCPlanCheckbox;
    procedure GenerateCPlanFiles;
    procedure MTXConvertPUVSPRDAT;
    procedure CheckCreateMarZoneClick(Sender: TObject);
    procedure GenerateMarZoneFiles;
  private
    { Private declarations }
  public
    { Public declarations }
    sOutputFile, sPUFile, sSPECFile : string;
  end;

var
  JoinDBFTablesForm: TJoinDBFTablesForm;

implementation

uses
    BrowseForFolderU, SCP_Main, DBF_Child, Miscellaneous, FileCtrl,
    ConvertCPlan;

{$R *.DFM}

function ExtractFID(const sValue : string) : integer;
var
   sFID : string;
begin
     // VALUE_
     // 123456
     sFID := Copy(sValue,7,Length(sValue) - 6);
     // V_
     // 12
     //sFID := Copy(sValue,3,Length(sValue) - 1);
     Result := StrToInt(sFID);
end;

procedure TJoinDBFTablesForm.ExecuteTableJoin;
var
   FindResult, iCurrentTable, iPUID, iFID, iRowCount, iFieldCount, iFileRecords, iPURecords, iFeatureIndex : integer;
   SearchRec : TSearchRec;
   sTableName, sSummaryFile, sFeatureIndexFile : string;
   OutputFile, SummaryFile, PUFile, SPECFile, FeatureIndexFile : TextFile;
   rValue : extended;
   fSkipFirstColumn : boolean;
   iStartIndex : integer;
begin
     try
        fSkipFirstColumn := CheckSkipFirstDBFColumn.Checked;
        if fSkipFirstColumn then
           iStartIndex := 1
        else
            iStartIndex := 0;
        // create blank output & summary files
        sOutputFile := EditInputPath.Text + '\join.csv';
        assignfile(OutputFile,sOutputFile);
        rewrite(OutputFile);
        writeln(OutputFile,'species,pu,amount');
        if CheckSummary.Checked then
        begin
             sSummaryFile := EditInputPath.Text + '\join_summary.csv';
             assignfile(SummaryFile,sSummaryFile);
             rewrite(SummaryFile);
             writeln(SummaryFile,'FILEINDEX,FILENAME,RECORDS');
        end;
        // create planning unit file
        if CheckPUDAT.Checked then
        begin
             sPUFile := EditInputPath.Text + '\planning_units.csv';
             assignfile(PUFile,sPUFile);
             rewrite(PUFile);
             writeln(PUFile,'id');
        end;
        // create feature file
        if CheckSPECDAT.Checked then
        begin
             sSPECFile := EditInputPath.Text + '\features.csv';
             assignfile(SPECFile,sSPECFile);
             rewrite(SPECFile);
             writeln(SPECFile,'id');
        end;
        // create feature index assignment file
        if (RadioGroupFeatureIndexType.ItemIndex = 0) then
        begin
             sFeatureIndexFile := EditInputPath.Text + '\feature_index_assignment.csv';
             assignfile(FeatureIndexFile,sFeatureIndexFile);
             rewrite(FeatureIndexFile);
             writeln(FeatureIndexFile,'ASSIGNID,FIELDNAME,FILENAME');
        end;

        // for each dbf table in the input folder
        FindResult := FindFirst(EditInputPath.Text + '\*.dbf', faAnyFile, SearchRec);
        iCurrentTable := 0;
        iFeatureIndex := 0;
        while FindResult = 0 do
        begin
             if (Pos('.dbf',LowerCase(SearchRec.Name)) > 0) then
             begin
                  iCurrentTable := iCurrentTable + 1;
                  // load table
                  sTableName := EditInputPath.Text + '\' + SearchRec.Name;
                  iFileRecords := 0;
                  Table1.DatabaseName := EditInputPath.Text;
                  Table1.TableName := SearchRec.Name;
                  Table1.Open;
                  begin
                       //   traverse all the cells of the table, writing non-zero entries to output file
                       for iRowCount := 1 to Table1.RecordCount do
                       begin
                            iPUID := Table1.Fields.Fields[0+iStartIndex].Value;
                            iPURecords := 0;

                            for iFieldCount := (2 + iStartIndex) to Table1.Fields.Count do
                            begin
                                 rValue := Table1.Fields.Fields[iFieldCount-1].Value;
                                 if (rValue > 0) then
                                 begin
                                      if (RadioGroupFeatureIndexType.ItemIndex = 0) then
                                         // assign unique index
                                         iFID := iFeatureIndex + iFieldCount - 1
                                      else
                                          // use column names from files
                                          iFID := ExtractFID(Table1.Fields.Fields[iFieldCount-1].FieldName);

                                      if CheckConvertM2.Checked then
                                         rValue := rValue / 10000;

                                      writeln(OutputFile,IntToStr(iFID) + ',' + IntToStr(iPUID) + ',' + FloatToStr(rValue));
                                      Inc(iFileRecords);
                                      Inc(iPURecords);

                                      if CheckSPECDAT.Checked then
                                         writeln(SPECFile,IntToStr(iFID));
                                 end;
                            end;

                            if CheckPUDAT.Checked then
                               if (iPURecords > 0) then
                                  writeln(PUFile,IntToStr(iPUID));

                            if (iRowCount < Table1.RecordCount) then
                               Table1.Next;
                       end;
                       // write index assignment information
                       if (RadioGroupFeatureIndexType.ItemIndex = 0) then
                       begin
                            for iFieldCount := (2 + iStartIndex) to Table1.Fields.Count do
                                writeln(FeatureIndexFile,IntToStr(iFeatureIndex + iFieldCount - 1) + ',' +
                                                         Table1.Fields.Fields[iFieldCount-1].FieldName + ',' +
                                                         SearchRec.Name);
                            Inc(iFeatureIndex,Table1.Fields.Count-1);
                       end;
                       //   write information row to summary file
                       if CheckSummary.Checked then
                          writeln(SummaryFile,IntToStr(iCurrentTable) + ',' + SearchRec.Name + ',' + IntToStr(iFileRecords));
                  end;
                  Table1.Close
             end;

             FindResult := FindNext(SearchRec);
        end;
        FindClose(SearchRec);

        // close output files
        closefile(OutputFile);
        if CheckSummary.Checked then
           closefile(SummaryFile);
        closefile(PUFile);
        closefile(SPECFile);
        if (RadioGroupFeatureIndexType.ItemIndex = 0) then
           closefile(FeatureIndexFile);

     except
     end;
end;

procedure TJoinDBFTablesForm.ParsePUDAT;
var
   InFile, OutFile : TextFile;
   sLine : string;
begin
     try
        assignfile(InFile,EditInputPath.Text + '\marxan\input\pu_.dat');
        assignfile(OutFile,EditInputPath.Text + '\marxan\input\pu.dat');
        reset(InFile);
        rewrite(OutFile);
        readln(InFile,sLine);
        writeln(OutFile,sLine + ',cost,status');
        repeat
               readln(InFile,sLine);
               writeln(OutFile,sLine + ',1,0');
        until Eof(InFile);
        closefile(InFile);
        closefile(OutFile);
        deletefile(EditInputPath.Text + '\marxan\input\pu_.dat');
     except
     end;
end;

procedure TJoinDBFTablesForm.ParseSPECDAT;
var
   InFile, OutFile : TextFile;
   sLine : string;
begin
     try
        assignfile(InFile,EditInputPath.Text + '\marxan\input\spec_.dat');
        assignfile(OutFile,EditInputPath.Text + '\marxan\input\spec.dat');
        reset(InFile);
        rewrite(OutFile);
        readln(InFile,sLine);
        writeln(OutFile,sLine + ',prop,spf');
        repeat
               readln(InFile,sLine);
               writeln(OutFile,sLine + ',0.1,1');
        until Eof(InFile);
        closefile(InFile);
        closefile(OutFile);
        deletefile(EditInputPath.Text + '\marxan\input\spec_.dat');
     except
     end;
end;

procedure TJoinDBFTablesForm.CreateINPUTDAT;
var
   OutFile : TextFile;
begin
     try
        assignfile(OutFile,EditInputPath.Text + '\marxan\input.dat');
        rewrite(OutFile);
        writeln(OutFile,'Input parameter file for Marxan.');
        writeln(OutFile,'');
        writeln(OutFile,'This file generated by Zonae Cogito.');
        writeln(OutFile,'written by Matt Watts');
        writeln(OutFile,'m.watts@uq.edu.au');
        writeln(OutFile,'');
        writeln(OutFile,'General Parameters');
        writeln(OutFile,'BLM 1');
        writeln(OutFile,'PROP 0.5');
        writeln(OutFile,'RANDSEED -1');
        writeln(OutFile,'NUMREPS 10');
        writeln(OutFile,'');
        writeln(OutFile,'Annealing Parameters');
        writeln(OutFile,'NUMITNS 1000000');
        writeln(OutFile,'STARTTEMP -1');
        writeln(OutFile,'NUMTEMP 10000');
        writeln(OutFile,'');
        writeln(OutFile,'Input Files');
        writeln(OutFile,'INPUTDIR input');
        writeln(OutFile,'PUNAME pu.dat');
        writeln(OutFile,'SPECNAME spec.dat');
        writeln(OutFile,'PUVSPRNAME puvspr.dat');
        if CheckSPORDER.Checked then
           writeln(OutFile,'MATRIXSPORDERNAME sporder.dat');
        if CheckCreateMarZone.Checked then
        begin
             writeln(OutFile,'ZONESNAME zones.dat');
             writeln(OutFile,'COSTSNAME costs.dat');
             writeln(OutFile,'ZONECOSTNAME zonecost.dat');
             writeln(OutFile,'ZONEBOUNDCOSTNAME zoneboundcost.dat');
             writeln(OutFile,'ZONETARGETNAME zonetarget.dat');
             writeln(OutFile,'ZONECONTRIBNAME zonecontrib.dat');
        end;
        writeln(OutFile,'');
        writeln(OutFile,'Save Files');
        writeln(OutFile,'SCENNAME output');
        writeln(OutFile,'SAVERUN 3');
        writeln(OutFile,'SAVEBEST 3');
        writeln(OutFile,'SAVESUMMARY 3');
        writeln(OutFile,'SAVETARGMET 3');
        writeln(OutFile,'SAVESUMSOLN 3');
        writeln(OutFile,'SAVEPENALTY 3');
        writeln(OutFile,'SAVESCEN 1');
        writeln(OutFile,'SAVELOG 1');
        writeln(OutFile,'OUTPUTDIR output');
        writeln(OutFile,'');                                                
        writeln(OutFile,'Program control');
        writeln(OutFile,'RUNMODE 1');
        writeln(OutFile,'MISSLEVEL 1');
        writeln(OutFile,'ITIMPTYPE 0');
        writeln(OutFile,'HEURTYPE -1');
        writeln(OutFile,'CLUMPTYPE 0');
        writeln(OutFile,'VERBOSITY 3');
        closefile(OutFile);
     except
     end;
end;

procedure TJoinDBFTablesForm.ProcessOutputFiles;
var
   FindResult, iCurrentTable, iPUID, iFID, iRowCount, iFieldCount, iFileRecords, iPURecords, iFeatureIndex : integer;
   SearchRec : TSearchRec;
   sTableName, sSummaryFile, sFeatureIndexFile : string;
   OutputFile, SummaryFile, PUFile, SPECFile, FeatureIndexFile : TextFile;
   rValue : extended;
begin
     try
        // sort output file
        if CheckPUDAT.Checked or CheckSPECDAT.Checked then
        begin
             ForceDirectories(EditInputPath.Text + '\marxan\input');
             ForceDirectories(EditInputPath.Text + '\marxan\output');
             CreateINPUTDAT;
             if CheckCreateMarZone.Checked then
             begin
                  ACopyFile(ExtractFilePath(Application.ExeName) + '\MarZone.exe',EditInputPath.Text + '\marxan\MarZone.exe');
                  ACopyFile(ExtractFilePath(Application.ExeName) + '\MarZone_x64.exe',EditInputPath.Text + '\marxan\MarZone_x64.exe');
             end
             else
             begin
                  ACopyFile(ExtractFilePath(Application.ExeName) + '\Marxan.exe',EditInputPath.Text + '\marxan\Marxan.exe');
                  ACopyFile(ExtractFilePath(Application.ExeName) + '\Marxan_x64.exe',EditInputPath.Text + '\marxan\Marxan_x64.exe');
             end;
        end;
        ProgramRunWait('"' + ExtractFilePath(Application.ExeName) + 'convert_mtx.exe" 2 "' + sOutputFile + '" "' + EditInputPath.Text + '\marxan\input\puvspr.dat"',
                    '',
                    True,
                    False);
        if CheckSPORDER.Checked then
           ProgramRunWait('"' + ExtractFilePath(Application.ExeName) + 'convert_mtx.exe" 3 "' + sOutputFile + '" "' + EditInputPath.Text + '\marxan\input\sporder.dat"',
                       '',
                       True,
                       False);
        if not CheckCK1.Checked then
           if fileexists(EditInputPath.Text + '\marxan\input\puvspr.dat') then
              deletefile(sOutputFile);
        if CheckPUDAT.Checked then
        begin
             ProgramRunWait('"' + ExtractFilePath(Application.ExeName) + 'ascii_table_integer_sorter.exe" "' + sPUFile + '" "' + EditInputPath.Text + '\marxan\input\pu_.dat"',
                         '',
                         True,
                         False);
             if fileexists(EditInputPath.Text + '\marxan\input\pu_.dat') then       
             begin
                  deletefile(sPUFile);
                  deletefile(EditInputPath.Text + '\marxan\input\pu_.dat_log.txt');
                  ParsePUDAT;
             end;
        end;
        if CheckSPECDAT.Checked then
        begin
             ProgramRunWait('"' + ExtractFilePath(Application.ExeName) + 'ascii_table_integer_sorter.exe" "' + sSPECFile + '" "' + EditInputPath.Text + '\marxan\input\spec_.dat"',
                         '',
                         True,
                         False);
             if fileexists(EditInputPath.Text + '\marxan\input\spec_.dat') then
             begin
                  deletefile(sSPECFile);
                  deletefile(EditInputPath.Text + '\marxan\input\spec_.dat_log.txt');
                  ParseSPECDAT;
             end;
        end;

     except
     end;
end;

procedure TJoinDBFTablesForm.MTXConvertPUVSPRDAT;
var
   InFile : TextFile;
   sLine : string;
   iPU, iLastPU : integer;
   rAmount : extended;
   OutputMatrix, OutputKey : file;
   Key : KeyFile_T;
   Value : SingleValueFile_T;
begin
     try
        // open input file
        assignfile(InFile,EditInputPath.Text + '\marxan\input\puvspr.dat');
        reset(InFile);
        readln(InFile);
        // create output MTX and KEY files
        assignfile(OutputMatrix,EditInputPath.Text + '\cplan\cplanmatrix.mtx');
        rewrite(OutputMatrix,1);
        assignfile(OutputKey,EditInputPath.Text + '\cplan\cplanmatrix.key');
        rewrite(OutputKey,1);

        // traverse input file
        iLastPU := -1;
        Key.iRichness := 0;
        repeat
              readln(InFile,sLine);
              // species,pu,amount
              Value.iFeatKey := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
              Value.rAmount := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));
              BlockWrite(OutputMatrix,Value,SizeOf(Value));

              iPU := StrToInt(GetDelimitedAsciiElement(sLine,',',2));

              // detect PU change
              if (iLastPU = -1) then
                 iLastPU := iPU;
              if (iPU <> iLastPU) then
              begin
                   BlockWrite(OutputKey,Key,SizeOf(Key));
                   Key.iRichness := 0;
                   iLastPU := iPU;   
              end;

              Key.iSiteKey := iPU;
              Inc(Key.iRichness);

        until Eof(InFile);

        BlockWrite(OutputKey,Key,SizeOf(Key));

        closefile(InFile);
        closefile(OutputMatrix);
        closefile(OutputKey);

     except
     end;
end;

procedure TJoinDBFTablesForm.GenerateCPlanFiles;
begin
     try
        if CheckPUDAT.Checked
        and CheckSPECDAT.Checked
        and CheckCPlan.Checked then
        begin
             ForceDirectories(EditInputPath.Text + '\cplan');
             DBFConvertPUDAT(EditInputPath.Text + '\marxan\input\pu.dat',
                             EditInputPath.Text + '\cplan\cplansites.dbf',
                             Query1, Table1);
             DBFConvertSPECDAT(EditInputPath.Text + '\marxan\input\spec.dat',
                               EditInputPath.Text + '\cplan\cplanfeatures.dbf',
                               Query1, Table1);
             MTXConvertPUVSPRDAT;
             CreateCPLANINI(EditInputPath.Text + '\cplan\cplan.ini');
        end;

     except
     end;
end;

procedure TJoinDBFTablesForm.btnBrowseClick(Sender: TObject);
begin
     EditInputPath.Text := BrowseForFolder('Locate input folder','',False);
end;

procedure TJoinDBFTablesForm.GenerateMarZoneFiles;
var
   OutFile : TextFile;
   iZoneCount, iCount : integer;
begin
     try
        if CheckCreateMarZone.Checked then
        begin
             iZoneCount := StrToInt(EditZoneCount.Text);

             // write zones.dat
             assignfile(OutFile,EditInputPath.Text + '\marxan\input\zones.dat');
             rewrite(OutFile);
             writeln(OutFile,'zoneid,zonename');
             for iCount := 1 to iZoneCount do
                 writeln(OutFile,IntToStr(iCount) + ',' + IntToStr(iCount));
             closefile(OutFile);

             // write costs.dat
             assignfile(OutFile,EditInputPath.Text + '\marxan\input\costs.dat');
             rewrite(OutFile);
             writeln(OutFile,'costid,costname');
             writeln(OutFile,'1,cost');
             closefile(OutFile);

             // write zonecost.dat
             assignfile(OutFile,EditInputPath.Text + '\marxan\input\zonecost.dat');
             rewrite(OutFile);
             writeln(OutFile,'zoneid,costid,multiplier');
             for iCount := 1 to iZoneCount do
                 writeln(OutFile,IntToStr(iCount) + ',1,1');
             closefile(OutFile);

             // write zoneboundcost.dat
             assignfile(OutFile,EditInputPath.Text + '\marxan\input\zoneboundcost.dat');
             rewrite(OutFile);
             writeln(OutFile,'zoneid1,zoneid2,cost');
             closefile(OutFile);

             // write zonetarget.dat
             assignfile(OutFile,EditInputPath.Text + '\marxan\input\zonetarget.dat');
             rewrite(OutFile);
             writeln(OutFile,'zoneid,speciesid,target');
             closefile(OutFile);

             // write zonecontrib.dat
             assignfile(OutFile,EditInputPath.Text + '\marxan\input\zonecontrib.dat');
             rewrite(OutFile);
             writeln(OutFile,'zoneid,speciesid,fraction');
             closefile(OutFile);
        end;

     except
     end;
end;

procedure TJoinDBFTablesForm.BitBtn1Click(Sender: TObject);
begin
     ExecuteTableJoin;
     ProcessOutputFiles;
     GenerateCPlanFiles;
     GenerateMarZoneFiles;
end;

procedure TJoinDBFTablesForm.MaskCPlanCheckbox;
begin
     if CheckPUDAT.Checked
     and CheckSPECDAT.Checked then
         CheckCPlan.Enabled := True
     else
     begin
          CheckCPlan.Enabled := False;
          CheckCPlan.Checked := False;
     end;
end;

procedure TJoinDBFTablesForm.CheckPUDATClick(Sender: TObject);
begin
     MaskCPlanCheckbox;
end;

procedure TJoinDBFTablesForm.CheckSPECDATClick(Sender: TObject);
begin
     MaskCPlanCheckbox;
end;

procedure TJoinDBFTablesForm.CheckCreateMarZoneClick(Sender: TObject);
begin
     EditZoneCount.Enabled := CheckCreateMarZone.Checked;
     Label2.Enabled := CheckCreateMarZone.Checked;
end;

end.
