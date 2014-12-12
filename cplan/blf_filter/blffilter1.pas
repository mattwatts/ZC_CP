unit blffilter1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls;

type
  TConvertCISitesForm = class(TForm)
    EditInSites: TEdit;
    Label1: TLabel;
    btnLocate: TButton;
    OpenDialog1: TOpenDialog;
    BitBtnExit: TBitBtn;
    BitBtnSplit: TBitBtn;
    BitBtnSummate: TBitBtn;
    procedure BitBtnExitClick(Sender: TObject);
    procedure BitBtnSplitClick(Sender: TObject);
    procedure btnLocateClick(Sender: TObject);
    procedure BitBtnSummateClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConvertCISitesForm: TConvertCISitesForm;

implementation

{$R *.DFM}


procedure TConvertCISitesForm.BitBtnExitClick(Sender: TObject);
begin
     Application.Terminate;
end;

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

procedure ConvertBLFFile(const sBLFFileName : string);
var
   iSite, iFeature, iElements, iElement : integer;
   InFile, OutFile1, OutFile2 : TextFile;
   sLine : string;
   sElement : string;
   rElement : single;
   sSiteKey : string;
   rRowTotal : extended;

   procedure ParseLine;
   var
      iCount, iPos : integer;
      sId1, sId2, sBoundary : string;
   begin
        sId1 := GetDelimitedAsciiElement(sLine,',',1);
        sId2 := GetDelimitedAsciiElement(sLine,',',2);
        sBoundary := GetDelimitedAsciiElement(sLine,',',3);

        if (sId1 = sId2) then
           writeln(OutFile2,sId1 + ',' + sId2 + ',' + sBoundary)
        else
            writeln(OutFile1,sId1 + ',' + sId2 + ',' + sBoundary);
   end;

begin
     // create 2 output files
     // in file 1, put rows that do not have equivalent id's
     // in file 2, put rows that have equivalent id's
     // as a post processing step, summate all cells in file 2 that are equivalent

     try
        Screen.Cursor := crHourglass;

        assignfile(InFile,sBLFFileName);
        reset(InFile);
        readln(InFile); // skip header row

        assignfile(OutFile1,ExtractFilePath(sBLFFileName) + '\non_equivalent.csv');
        rewrite(OutFile1);
        writeln(OutFile1,'id1,id2,boundary');

        assignfile(OutFile2,ExtractFilePath(sBLFFileName) + '\equivalent.csv');
        rewrite(OutFile2);
        writeln(OutFile2,'id1,id2,boundary');

        iSite := 0;
        repeat
              Inc(iSite);
              readln(InFile,sLine);

              ParseLine;

              ConvertCISitesForm.Caption := IntToStr(iSite);

        until Eof(InFile);

        closefile(InFile);
        closefile(OutFile1);
        closefile(OutFile2);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ConvertCSVFile',mtInformation,[mbOk],0);
     end;
end;

procedure SummateEquivalentFile(const sEquivalentFileName : string);
var
   iSite, iFeature, iElements, iElement : integer;
   InFile, OutFile : TextFile;
   sLine : string;
   sElement : string;
   rElement : single;
   sSiteKey : string;
   rRowTotal : extended;
   sLastId1, sLastId2 : string;
   rBoundary : extended;

   procedure ParseLine;
   var
      iCount, iPos : integer;
      sId1, sId2, sBoundary : string;
   begin
        sId1 := GetDelimitedAsciiElement(sLine,',',1);
        sId2 := GetDelimitedAsciiElement(sLine,',',2);
        sBoundary := GetDelimitedAsciiElement(sLine,',',3);


        if (sId1 <> sLastId1)
        or (sId2 <> sLastId2) then
        begin
             // 2 cases;
             //    end of equivalent section
             // OR
             //    single non-equivalent row
             // these can be made equivalent by accumulating boundary, which may be 0 or >0

             // flush the previous section or non section
             if (rBoundary > 0) then
                writeln(OutFile,sLastId1 + ',' + sLastId2 + ',' + FloatToStr(rBoundary));

             rBoundary := StrToFloat(sBoundary);
        end
        else
        begin
             rBoundary := rBoundary + StrToFloat(sBoundary);
        end;

        sLastId1 := sId1;
        sLastId2 := sId2;
   end;

begin
     // create 2 output files
     // in file 1, put rows that do not have equivalent id's
     // in file 2, put rows that have equivalent id's
     // as a post processing step, summate all cells in file 2 that are equivalent

     try
        Screen.Cursor := crHourglass;

        assignfile(InFile,sEquivalentFileName);
        reset(InFile);
        readln(InFile); // skip header row

        assignfile(OutFile,ExtractFilePath(sEquivalentFileName) + '\summate_equivalent.csv');
        rewrite(OutFile);
        writeln(OutFile,'id1,id2,boundary');

        sLastId1 := '';
        sLastId2 := '';
        rBoundary := 0;

        iSite := 0;
        repeat
              Inc(iSite);
              readln(InFile,sLine);

              ParseLine;

              ConvertCISitesForm.Caption := IntToStr(iSite);

        until Eof(InFile);

        // write last row
        writeln(OutFile,sLastId1 + ',' + sLastId2 + ',' + FloatToStr(rBoundary));

        closefile(InFile);
        closefile(OutFile);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in SummateEquivalentFile',mtInformation,[mbOk],0);
     end;
end;

procedure TConvertCISitesForm.BitBtnSplitClick(Sender: TObject);
begin
     if fileexists(EditInSites.Text) then
     begin
          ConvertBLFFile(EditInSites.Text);
          //SummateEquivalentFile(ExtractFilePath(EditInSites.Text) + '\equivalent.csv');

          MessageDlg('File converted ok',mtInformation,[mbOk],0);

          Application.Terminate;
     end;
end;

procedure TConvertCISitesForm.btnLocateClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
        EditInSites.Text := OpenDialog1.Filename;
end;

procedure TConvertCISitesForm.BitBtnSummateClick(Sender: TObject);
begin
     if fileexists(EditInSites.Text) then
     begin
          SummateEquivalentFile(EditInSites.Text);

          MessageDlg('File converted ok',mtInformation,[mbOk],0);

          Application.Terminate;
     end;
end;

end.
