unit ConvertCPlan;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, dbtables, Db;

type
  TConvertCPlanForm = class(TForm)
    Label1: TLabel;
    EditInputFile: TEdit;
    btnBrowse: TButton;
    OpenDialog1: TOpenDialog;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    RadioGroupInputFormat: TRadioGroup;
    Table1: TTable;
    Query1: TQuery;
    procedure BitBtn1Click(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure CreateCPLANINI(const sOutputFile : string);
procedure DBFConvertPUDAT(const sInputPUDAT, sOutputSITESDBF : string;
                          AQuery : TQuery; ATable : TTable);
procedure DBFConvertSPECDAT(const sInputSPECDAT, sOutputFEATURESDBF : string;
                            AQuery : TQuery; ATable : TTable);

var
  ConvertCPlanForm: TConvertCPlanForm;

implementation

uses
    Miscellaneous, FileCtrl, ds, Math;

{$R *.DFM}

procedure CreateCPLANINI(const sOutputFile : string);
var
   OutFile : TextFile;
begin
     try
        assignfile(OutFile,sOutputFile);
        rewrite(OutFile);

        writeln(OutFile,'[Database1]');
        writeln(OutFile,'Name=IAPN1');
        writeln(OutFile,'PCCONTRCutOff=0');
        writeln(OutFile,'FeatureSummaryTable=cplanfeatures.dbf');
        writeln(OutFile);
        writeln(OutFile,'[Sumirr Weightings]');
        writeln(OutFile,'Area=1');
        writeln(OutFile,'Target=1');
        writeln(OutFile,'Vulnerability=1');
        writeln(OutFile,'Minimum Weight=0.2');
        writeln(OutFile,'CalculateAllVariations=1');
        writeln(OutFile);
        writeln(OutFile,'[Reserve Class]');
        writeln(OutFile,'Class 1 Label=Negotiated');
        writeln(OutFile,'Class 2 Label=Mandatory');
        writeln(OutFile);
        writeln(OutFile,'[Options]');
        writeln(OutFile,'Key=SITEKEY');
        writeln(OutFile,'PlotField=SUMIRR');
        writeln(OutFile,'DefaultTargetPercent=10');
        writeln(OutFile,'SparseKey=cplanmatrix.key');
        writeln(OutFile,'SparseMatrix=cplanmatrix.mtx');
        writeln(OutFile,'SiteSummaryTable=cplansites.dbf');
        writeln(OutFile,'UseImportedTargets=0');
        writeln(OutFile);

        closefile(OutFile);

     except
     end;
end;

procedure DBFConvertPUDAT(const sInputPUDAT, sOutputSITESDBF : string;
                          AQuery : TQuery; ATable : TTable);
var
   InFile : TextFile;
   sLine : string;
   iId : integer;
begin
     try
        with AQuery do
        begin
             SQL.Clear;
             SQL.Add('create table "' + sOutputSITESDBF + '"');
             SQL.Add('(');
             SQL.Add('NAME CHAR(30),');
             SQL.Add('SITEKEY NUMERIC(10,0),');
             SQL.Add('STATUS CHAR(2),');
             SQL.Add('I_STATUS CHAR(9),');
             SQL.Add('AREA NUMERIC(10,5),');
             SQL.Add('IRREPL NUMERIC(10,5),');
             SQL.Add('I_IRREPL NUMERIC(10,5),');
             SQL.Add('SUMIRR NUMERIC(10,5),');
             SQL.Add('I_SUMIRR NUMERIC(10,5),');
             SQL.Add('WAVIRR NUMERIC(10,5),');
             SQL.Add('I_WAVIRR NUMERIC(10,5),');
             SQL.Add('PCCONTR NUMERIC(10,5),');
             SQL.Add('I_PCCONTR NUMERIC(10,5),');
             SQL.Add('DISPLAY CHAR(3)');
             SQL.Add(')');
             Prepare;
             ExecSQL;
        end;

        assignfile(InFile,sInputPUDAT);
        reset(InFile);
        readln(InFile);
        ATable.DatabaseName := ExtractFilePath(sOutputSITESDBF);
        ATable.TableName := ExtractFileName(sOutputSITESDBF);
        ATable.Open;

        repeat
               readln(InFile,sLine);
               // id,cost,status
               iId := StrToInt(GetDelimitedAsciiElement(sLine,',',1));

               ATable.AppendRecord([IntToStr(iId),
                                    iId,
                                    '',
                                    '',
                                    1.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                    '']);

        until Eof(InFile);

        ATable.Close;
        closefile(InFile);

     except
           MessageDlg('Exception in DBFConvertPUDAT',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure DBFConvertPUDAT_linear(const sInputPUDAT, sOutputSITESDBF : string;
                                 AQuery : TQuery; ATable : TTable);
var
   InFile : TextFile;
   sLine : string;
   iId, iCount : integer;
begin
     try
        with AQuery do
        begin
             SQL.Clear;
             SQL.Add('create table "' + sOutputSITESDBF + '"');
             SQL.Add('(');
             SQL.Add('NAME CHAR(30),');
             SQL.Add('SITEKEY NUMERIC(10,0),');
             SQL.Add('STATUS CHAR(2),');
             SQL.Add('I_STATUS CHAR(9),');
             SQL.Add('AREA NUMERIC(10,5),');
             SQL.Add('IRREPL NUMERIC(10,5),');
             SQL.Add('I_IRREPL NUMERIC(10,5),');
             SQL.Add('SUMIRR NUMERIC(10,5),');
             SQL.Add('I_SUMIRR NUMERIC(10,5),');
             SQL.Add('WAVIRR NUMERIC(10,5),');
             SQL.Add('I_WAVIRR NUMERIC(10,5),');
             SQL.Add('PCCONTR NUMERIC(10,5),');
             SQL.Add('I_PCCONTR NUMERIC(10,5),');
             SQL.Add('DISPLAY CHAR(3)');
             SQL.Add(')');
             Prepare;
             ExecSQL;
        end;

        assignfile(InFile,sInputPUDAT);
        reset(InFile);
        readln(InFile);
        ATable.DatabaseName := ExtractFilePath(sOutputSITESDBF);
        ATable.TableName := ExtractFileName(sOutputSITESDBF);
        ATable.Open;

        iCount := 0;
        repeat
               readln(InFile,sLine);
               // id,cost,status
               iId := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
               Inc(iCount);
               ATable.AppendRecord([IntToStr(iId),
                                    iCount,
                                    '',
                                    '',
                                    1.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                    '']);

        until Eof(InFile);

        ATable.Close;
        closefile(InFile);

     except
           MessageDlg('Exception in DBFConvertPUDAT',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure DBFConvertSPECDAT(const sInputSPECDAT, sOutputFEATURESDBF : string;
                            AQuery : TQuery; ATable : TTable);
var
   InFile : TextFile;
   sLine : string;
   iId : integer;
begin
     try
        with AQuery do
        begin
             SQL.Clear;
             SQL.Add('create table "' + sOutputFEATURESDBF + '"');
             SQL.Add('(');
             SQL.Add('FEATNAME CHAR(30),');
             SQL.Add('FEATKEY NUMERIC(10,0),');
             SQL.Add('ITARGET NUMERIC(10,5),');
             SQL.Add('VULN NUMERIC(10,5)');
             SQL.Add(')');
             Prepare;
             ExecSQL;
        end;

        assignfile(InFile,sInputSPECDAT);
        reset(InFile);
        readln(InFile);
        ATable.DatabaseName := ExtractFilePath(sOutputFEATURESDBF);
        ATable.TableName := ExtractFileName(sOutputFEATURESDBF);
        ATable.Open;

        repeat
               readln(InFile,sLine);
               // id,prop,spf
               iId := StrToInt(GetDelimitedAsciiElement(sLine,',',1));

               ATable.AppendRecord([IntToStr(iId),
                                    iId,
                                    1,
                                    0]);

        until Eof(InFile);

        ATable.Close;
        closefile(InFile);

     except
           MessageDlg('Exception in DBFConvertSPECDAT',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure DBFConvertSPECDAT_linear(const sInputSPECDAT, sOutputFEATURESDBF : string;
                                   AQuery : TQuery; ATable : TTable);
var
   InFile : TextFile;
   sLine : string;
   iId, iCount : integer;
begin
     try
        with AQuery do
        begin
             SQL.Clear;
             SQL.Add('create table "' + sOutputFEATURESDBF + '"');
             SQL.Add('(');
             SQL.Add('FEATNAME CHAR(30),');
             SQL.Add('FEATKEY NUMERIC(10,0),');
             SQL.Add('ITARGET NUMERIC(10,5),');
             SQL.Add('VULN NUMERIC(10,5)');
             SQL.Add(')');
             Prepare;
             ExecSQL;
        end;

        assignfile(InFile,sInputSPECDAT);
        reset(InFile);
        readln(InFile);
        ATable.DatabaseName := ExtractFilePath(sOutputFEATURESDBF);
        ATable.TableName := ExtractFileName(sOutputFEATURESDBF);
        ATable.Open;
        iCount := 0;
        repeat
               readln(InFile,sLine);
               // id,prop,spf
               iId := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
               Inc(iCount);
               ATable.AppendRecord([IntToStr(iId),
                                    iCount,
                                    1,
                                    0]);

        until Eof(InFile);

        ATable.Close;
        closefile(InFile);

     except
           MessageDlg('Exception in DBFConvertSPECDAT',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

function BinaryLookup_Integer_safe(IntArr : Array_t; iMatch, iInputTop, iInputBottom : integer) : integer;
//int puno,int name, struct binsearch PULookup[]
var
   iCentre, iCount, iCentreValue, iTop, iBottom : integer;
   fLoop : boolean;
begin
     // use a binary search to find the index of planning unit iMatch
     // IntArr is in numeric order

     iTop := iInputTop;
     iBottom := iInputBottom;

     iCentre := iTop + floor((iBottom - iTop) / 2);

     IntArr.rtnValue(iCentre,@iCentreValue);
     fLoop := True;

     while ((iTop <= iBottom) and (iCentreValue <> iMatch) and fLoop) do
     begin
          if (iMatch < iCentreValue) then
          begin
               iBottom := iCentre - 1;
               if (iBottom < iTop) then
               begin
                    iBottom := iTop;
                    fLoop := False;
               end;
               iCount := iBottom - iTop + 1;
               iCentre := iTop + floor(iCount / 2);
          end
          else
          begin
               iTop := iCentre + 1;
               if (iTop > iBottom) then
               begin
                    iTop := iBottom;
                    fLoop := False;
               end;
               iCount := iBottom - iTop + 1;
               iCentre := iTop + floor(iCount / 2);
          end;

          IntArr.rtnValue(iCentre,@iCentreValue);
     end;

     if (iCentreValue = iMatch) then
        Result := iCentre
     else
     begin
          Result := -1;
          // do the slow search
          for iCount := iInputTop to iInputBottom do
          begin
               IntArr.rtnValue(iCount,@iCentreValue);
               if (iCentreValue = iMatch) then
                  Result := iCentre;
          end;
     end;
end;

procedure ConvertMatrixToCPlan(const sInputFileName : string; const iInputFormat : integer;
                               AQuery : TQuery; ATable : TTable);
var
   InputFile, PUFile, SPECFile : TextFile;
   sLine, sOutputDir, sTempMatrixName : string;
   iPU, iLastPU, iFeatureName, iPUCount, iSPCount, iPUKey : integer;
   rAmount : extended;
   OutputMatrix, OutputKey : file;
   Key : KeyFile_T;
   Value : SingleValueFile_T;
   PUArray, SPECArray : Array_t;
begin
     try
        // iInputFormat
        //   0 feature,planning unit,amount
        //   1 planning unit,feature,amount

        sOutputDir := ExtractFilePath(sInputFileName) + 'cplan';
        ForceDirectories(sOutputDir);

        (*sTempMatrixName := sOutputDir + '\temp_matrix_1.csv';

        // we need to sort the input file before processing
        if (iInputFormat = 0) then
        begin
             // convert_mtx.exe 3 sIputFileName sTempMatrixName
             ProgramRunWait('"' + ExtractFilePath(Application.ExeName) + 'convert_mtx.exe"' +
                            ' 2' +
                            ' "' + sInputFileName + '"' +
                            ' "' + sTempMatrixName + '"',
                            '',
                            True,
                            False);
        end
        else
        begin
             // convert_mtx.exe 2 sIputFileName sTempMatrixName
             ProgramRunWait('"' + ExtractFilePath(Application.ExeName) + 'convert_mtx.exe"' +
                            ' 3' +
                            ' "' + sInputFileName + '"' +
                            ' "' + sTempMatrixName + '"',
                            '',
                            True,
                            False);
        end;*)

        assignfile(InputFile,sInputFileName);
        reset(InputFile);
        readln(InputFile);

        // create output MTX and KEY files
        assignfile(OutputMatrix,sOutputDir + '\cplanmatrix.mtx');
        rewrite(OutputMatrix,1);
        assignfile(OutputKey,sOutputDir + '\cplanmatrix.key');
        rewrite(OutputKey,1);
        iLastPU := -1;
        Key.iRichness := 0;

        assignfile(PUFile, sOutputDir + '\putemp1.csv');
        rewrite(PuFile);
        writeln(PuFile,'id');
        assignfile(SPECFile, sOutputDir + '\spectemp1.csv');
        rewrite(SPECFile);
        writeln(SPECFile,'id');

        // first parse to find all PU's and SPEC's
        repeat
              readln(InputFile,sLine);

              if (iInputFormat = 0) then
              begin
                   iFeatureName := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
                   iPU := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
              end
              else
              begin
                   iPU := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
                   iFeatureName := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
              end;

              writeln(PuFile,IntToStr(iPU));
              writeln(SPECFile,IntTOStr(iFeatureName));

        until Eof(InputFile);

        closefile(PuFile);
        closefile(SPECFile);

        // sort and remove duplicates for PUFile and SPECFile
        ProgramRunWait('"' + ExtractFilePath(Application.ExeName) + 'ascii_table_integer_sorter.exe" "' +
                       sOutputDir + '\putemp1.csv' + '" "' + sOutputDir + '\putemp2.csv"',
                       '',
                       True,
                       False);
        ProgramRunWait('"' + ExtractFilePath(Application.ExeName) + 'ascii_table_integer_sorter.exe" "' +
                       sOutputDir + '\spectemp1.csv' + '" "' + sOutputDir + '\spectemp2.csv"',
                       '',
                       True,
                       False);

        // count the PU's
        iPUCount := 0;
        assignfile(PUFile, sOutputDir + '\putemp2.csv');
        reset(PUFile);
        readln(PUFile);
        repeat
              readln(PUFile);
              Inc(iPUCount);
        until Eof(PUFile);
        // load PU's to array for binary lookup
        PUArray := Array_t.Create;
        PUArray.init(SizeOf(integer),iPUCount);
        reset(PUFile);
        readln(PUFile);
        iPUCount := 0;
        repeat
              readln(PUFile,sLine);
              iPU := StrToInt(sLine);
              Inc(iPUCount);
              PUArray.setValue(iPUCount,@iPU);
        until Eof(PUFile);
        closefile(PUFile);
        // count the SP's
        iSPCount := 0;
        assignfile(SPECFile, sOutputDir + '\spectemp2.csv');
        reset(SPECFile);
        readln(SPECFile);
        repeat
              readln(SPECFile);
              Inc(iSPCount);
        until Eof(SPECFile);
        // load SP's to array for binary lookup
        SPECArray := Array_t.Create;
        SPECArray.init(SizeOf(integer),iSPCount);
        reset(SPECFile);
        readln(SPECFile);
        iSPCount := 0;
        repeat
              readln(SPECFile,sLine);
              iFeatureName := StrToInt(sLine);
              Inc(iSPCount);
              SPECArray.setValue(iSPCount,@iFeatureName);
        until Eof(SPECFile);
        closefile(SPECFile);

        // second parse to write converted matrix file
        reset(InputFile);
        readln(InputFile);
        repeat
              readln(InputFile,sLine);

              if (iInputFormat = 0) then
              begin
                   iFeatureName := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
                   iPU := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
              end
              else
              begin
                   iPU := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
                   iFeatureName := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
              end;

              // lookup the feature key using this feature name
              Value.iFeatKey := BinaryLookup_Integer_safe(SPECArray,iFeatureName,1,iSPCount);
              // lookup the pu key using this pu name
              iPUKey := BinaryLookup_Integer_safe(PUArray,iPU,1,iPUCount);

              Value.rAmount := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));
              BlockWrite(OutputMatrix,Value,SizeOf(Value));

              // detect PU change
              if (iLastPU = -1) then
                 iLastPU := iPUKey;
              if (iPUKey <> iLastPU) then
              begin
                   BlockWrite(OutputKey,Key,SizeOf(Key));
                   Key.iRichness := 0;
                   iLastPU := iPUKey;
              end;

              Key.iSiteKey := iPUKey;
              Inc(Key.iRichness);

        until Eof(InputFile);
        BlockWrite(OutputKey,Key,SizeOf(Key));

        closefile(InputFile);
        closefile(OutputKey);
        closefile(OutputMatrix);

        DBFConvertPUDAT_linear(sOutputDir + '\putemp2.csv',
                               sOutputDir + '\cplansites.dbf',
                               AQuery, ATable);
        DBFConvertSPECDAT_linear(sOutputDir + '\spectemp2.csv',
                                 sOutputDir + '\cplanfeatures.dbf',
                                 AQuery, ATable);
        CreateCPLANINI(sOutputDir + '\cplan.ini');

        deletefile(sTempMatrixName);

        if fileexists(sOutputDir + '\cplansites.dbf') then
        begin
             deletefile(sOutputDir + '\putemp1.csv');
             deletefile(sOutputDir + '\putemp2.csv');
             deletefile(sOutputDir + '\putemp2.csv_log.txt');
        end;

        if fileexists(sOutputDir + '\cplanfeatures.dbf') then
        begin
             deletefile(sOutputDir + '\spectemp1.csv');
             deletefile(sOutputDir + '\spectemp2.csv');
             deletefile(sOutputDir + '\spectemp2.csv_log.txt');
        end;

        PUArray.Destroy;
        SPECArray.Destroy;

     except
           MessageDlg('Exception in ConvertMatrixToCPlan',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TConvertCPlanForm.BitBtn1Click(Sender: TObject);
begin
     ConvertMatrixToCPlan(EditInputFile.Text,RadioGroupInputFormat.ItemIndex,Query1,Table1);
end;

procedure TConvertCPlanForm.btnBrowseClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
        EditInputFile.Text := OpenDialog1.Filename;
end;

end.
