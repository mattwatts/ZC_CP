unit ci_import1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls;

type
  TForm1 = class(TForm)
    EditInMatrix: TEdit;
    Label1: TLabel;
    btnLocate: TButton;
    BitBtnConvert: TBitBtn;
    BitBtnExit: TBitBtn;
    OpenDialog1: TOpenDialog;
    EditColumns: TEdit;
    Label5: TLabel;
    EditFiles: TEdit;
    Label2: TLabel;
    procedure btnLocateClick(Sender: TObject);
    procedure BitBtnExitClick(Sender: TObject);
    procedure BitBtnConvertClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

    KeyFile_T = record
                  iSiteKey : integer;
                  iRichness : word;
                end;

    //IntKeyFile_T = record
    //              iSiteKey : integer;
    //              iRichness : integer;
    //            end;

    SingleValueFile_T = record
                    iFeatKey : word;
                    rAmount : single;
                  end;

    //IntValueFile_T = record
    //                iFeatKey : integer;
    //                rAmount : extended;
    //              end;

    ExtendedLine_T = array [1..200000] of extended;
    ExtendedLineArrayPointer = ^ExtendedLine_T;



var
  Form1: TForm1;

implementation

{$R *.DFM}

function CountCommas(const sLine : string) : integer;
var
   iCount : integer;
begin
     Result := 0;
     for iCount := 1 to Length(sLine) do
         if (sLine[iCount] = ',') then
            Inc(Result);
end;

function GetDelimitedAsciiElement(var sLine : string;
                                  const sDelimiter : string;
                                  const iColumn : integer) : string;
// returns the element at 1-based-index column iColumn
// returns blank string if the column does not exist in sLine
var
   sTrimLine : string;
   iPos, iTrim, iCount : integer;
begin
     Result := '';

     sTrimLine := sLine;
     iTrim := iColumn-1;
     if (iTrim > 0) then
        for iCount := 1 to iTrim do // trim the required number of columns from the start of the string
        begin
             iPos := Pos(sDelimiter,sTrimLine);
             sTrimLine := Copy(sTrimLine,iPos+1,Length(sTrimLine)-iPos);
        end;
     iPos := Pos(sDelimiter,sTrimLine);
     if (iPos = 1) then
     begin
          // there is a delimiter at the start of the line we must trim first
          sTrimLine := Copy(sTrimLine,2,Length(sTrimLine)-1);
          sLine := sTrimLine;
          iPos := Pos(sDelimiter,sTrimLine);
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;
     end
     else
     begin
          sLine := sTrimLine;
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;
     end;
end;

procedure ConvertNHeaderlessCSV2Mtx(const sCSVFileName1 : string);
var
   iSite, iFeature, iElements, iElement, iNumberOfColumns,
   iFileCount, iFiles, iRowsInFile : integer;
   InFile, SummaryFile, AsciiMatrixFile : TextFile;
   sLine : string;
   //Key : KeyFile_T;
   //Value : SingleValueFile_T;
   //ValueFile, KeyFile : file;
   sElement : string;
   rElement : single;
   sFileBase, sCSVFileName : string;
   ExtendedLineArray : ExtendedLineArrayPointer;

   procedure WriteErrorInfo;
   var
      ErrorFile : TextFile;
   begin
        assignfile(ErrorFile,ExtractFilePath(sCSVFileName1) + '\error.txt');
        rewrite(ErrorFile);
        writeln(ErrorFile,IntToStr(iSite));
        writeln(ErrorFile,sLine);
        writeln(ErrorFile,sCSVFileName);
        closefile(ErrorFile);
   end;

   procedure FastParseLineBlankCheck;
   var
      iCount, iArrayElement : integer;
      sArrayElement : string;
      rArrayElement : extended;
   begin
        // convert the long ascii line to an array of extended
        sArrayElement := '';
        iArrayElement := 0;
        for iCount := 1 to 200000 do
            ExtendedLineArray^[iCount] := 0;
        for iCount := 1 to Length(sLine) do
        begin
             if (iArrayElement < 200000) then
             begin
                  if (sLine[iCount] = ',') then
                  begin
                       // end element

                       Inc(iArrayElement);
                       if (iArrayElement = (iNumberOfColumns+1)) then
                       begin
                            MessageDlg('iArrayElement exceeds ' + IntToStr(iNumberOfColumns) + ' site ' +
                                       IntToStr(iSite) +
                                       ' elements ' +
                                       IntToStr(CountCommas(sLine)) +
                                       ' filename ' +
                                       sCSVFileName
                                       ,mtInformation,[mbOk],0);
                            WriteErrorInfo;
                       end;
                       if (sArrayElement <> '') then
                       try
                          ExtendedLineArray^[iArrayElement] := StrToFloat(sArrayElement);
                       except
                             ExtendedLineArray^[iArrayElement] := 0;
                       end;
                       sArrayElement := '';
                  end
                  else
                      // continue to accumulate element
                      sArrayElement := sArrayElement + sLine[iCount];
             end;
        end;
        // finish last element
        if (iArrayElement < iNumberOfColumns) then
        begin
             Inc(iArrayElement);
             if (sArrayElement <> '') then
             try
                ExtendedLineArray^[iArrayElement] := StrToFloat(sArrayElement);
             except
                   ExtendedLineArray^[iArrayElement] := 0;
             end;
        end;
        sArrayElement := '';
        // now parse the converted array
        // array element ONEBASE index is site key
        // iSite is ONEBASE index of feature key
        for iCount := 1 to iArrayElement do
        begin
             if (ExtendedLineArray^[iCount] > 0) then
                writeln(AsciiMatrixFile,IntToStr(iCount) + ',' + IntToStr(iSite) + ',' + FloatToStr(ExtendedLineArray^[iCount]));//SiteKey,FeatKey,Amount
        end;
   end;
begin
     try
        Screen.Cursor := crHourglass;

        // count column totals and site and feature count on the way through

        try
           iNumberOfColumns := StrToInt(Form1.EditColumns.Text);
        except
              iNumberOfColumns := 1;
        end;

        assignfile(AsciiMatrixFile,ExtractFilePath(sCSVFileName1) + '\AsciiMatrix.csv');
        rewrite(AsciiMatrixFile);
        writeln(AsciiMatrixFile,'SiteKey,FeatKey,Amount');

        //assignfile(ValueFile,ExtractFilePath(sCSVFileName1) + '\matrix.mtx');
        //rewrite(ValueFile,1);
        //assignfile(KeyFile,ExtractFilePath(sCSVFileName1) + '\matrix.key');
        //rewrite(KeyFile,1);
        iSite := 0;

        assignfile(SummaryFile,ExtractFilePath(sCSVFileName1) + '\summary.txt');
        rewrite(SummaryFile);

        sFileBase := Copy(sCSVFileName1,1,Length(sCSVFileName1)-5);

        new(ExtendedLineArray);

        try
           iFiles := StrToInt(Form1.EditFiles.Text);
        except
              iFiles := 1;
        end;

        for iFileCount := 1 to iFiles do
        begin
             iRowsInFile := 0;

             sCSVFileName := sFileBase + IntToStr(iFileCount) + '.csv';
             assignfile(InFile,sCSVFileName);
             reset(InFile);
             repeat
                   Inc(iSite);
                   Inc(iRowsInFile);
                   readln(InFile,sLine);
                   if (iSite = 1) then
                      iElements := CountCommas(sLine) + 1;

                   FastParseLineBlankCheck;

                   Form1.Caption := sCSVFileName + ' ' + IntToStr(iSite);

             until Eof(InFile);
             closefile(InFile);

             writeln(SummaryFile,IntToStr(iRowsInFile) + ' rows in file ' + IntToStr(iFileCount));
        end;

        dispose(ExtendedLineArray);

        //closefile(ValueFile);
        //closefile(KeyFile);

        closefile(AsciiMatrixFile);

        writeln(SummaryFile,'rows:' + IntToStr(iSite) + '   columns:' + IntToStr(iElements));
        closefile(SummaryFile);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ConvertNHeaderlessCSV2Mtx',mtInformation,[mbOk],0);
     end;
end;


procedure TForm1.btnLocateClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
        EditInMatrix.Text := OpenDialog1.Filename;
end;

procedure TForm1.BitBtnExitClick(Sender: TObject);
begin
     Application.Terminate;
end;

procedure TForm1.BitBtnConvertClick(Sender: TObject);
var
   sFileBase : string;
   iCount : integer;
begin
     // count column totals and site and feature count on the way through
     // run with 10input files, the first being specified as ;
     // E:\ftp\65.205.36.42\C_Synthesis\Irreplaceability\Amphibians\Amph_Matrix\AmphMatr1.csv
     // file will be of the form XA.csv
     // where X is the pathname minus the end bit
     // A is 1 or 2 digit integer from 1 to 10
     // .csv is itself
     sFileBase := Copy(EditInMatrix.Text,1,Length(EditInMatrix.Text)-5);

     ConvertNHeaderlessCSV2Mtx(EditInMatrix.Text);

     MessageDlg('File converted ok',mtInformation,[mbOk],0);

     Application.Terminate;
end;

end.
