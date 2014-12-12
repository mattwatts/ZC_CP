unit BLF_process;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls;

type
  TBLFProcessForm = class(TForm)
    Label1: TLabel;
    EditBLFFile: TEdit;
    btnBrowse: TButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OpenDialog1: TOpenDialog;
    procedure btnBrowseClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BLFProcessForm: TBLFProcessForm;

implementation

uses
    ds, global;

{$R *.DFM}

procedure TBLFProcessForm.btnBrowseClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
        EditBLFFile.Text := OpenDialog1.Filename;
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

procedure ProcessBLFFile(const sBLFFileName : string);
var
   InFile, OutFile, DuplicateFile, AFile, BFile : TextFile;
   BLF, Duplicates : Array_t;
   fDuplicate : boolean;
   BLF_Element, BLF_SecondaryElement : BLF_T;
   iBLFElements, iCount, iPrimaryCount, iSecondaryCount : integer;
   sLine, sId1, sId2, sBoundary : string;

   procedure StoreBLFElement;
   begin
        if (iBLFElements > BLF.lMaxSize) then
           BLF.resize(BLF.lMaxSize + 10000);

        BLF_Element.iId1 := StrToInt(sId1);
        BLF_Element.iId2 := StrToInt(sId2);
        BLF_Element.rBoundary := StrToFloat(sBoundary);

        BLF.setValue(iBLFElements,@BLF_Element);
   end;

begin
     try
        assignfile(InFile,sBLFFileName);
        reset(InFile);
        readln(InFile);

        iBLFElements := 0;
        BLF := Array_T.Create;
        BLF.init(SizeOf(BLF_T),10000);
        // read the BLF file to an array
        repeat
              readln(InFile,sLine);
              Inc(iBLFElements);

              sId1 := GetDelimitedAsciiElement(sLine,',',1);
              sId2 := GetDelimitedAsciiElement(sLine,',',2);
              sBoundary := GetDelimitedAsciiElement(sLine,',',3);

              StoreBLFElement;

        until Eof(InFile);

        closefile(InFile);

        // adjust the size of the BLF array
        if (BLF.lMaxSize <> iBLFElements) then
           BLF.resize(iBLFElements);

        // write the BLF file to a debugging file
        assignfile(OutFile,ExtractFilePath(sBLFFileName) + '\BLF_debug.csv');
        rewrite(OutFile);
        writeln(OutFile,'id1,id2,boundary');
        for iCount := 1 to iBLFElements do
        begin
             BLF.rtnValue(iCount,@BLF_Element);
             writeln(OutFile,IntToStr(BLF_Element.iId1) + ',' + IntToStr(BLF_Element.iId2) + ',' + FloatToStr(BLF_Element.rBoundary));
        end;
        closefile(OutFile);

        // create blank duplicates file
        Duplicates := Array_T.Create;
        Duplicates.init(SizeOf(fDuplicate),iBLFElements);
        fDuplicate := False;
        for iCount := 1 to iBLFElements do
            Duplicates.setValue(iCount,@fDuplicate);

        // dump the duplicate identifiers to a file
        assignfile(DuplicateFile,ExtractFilePath(sBLFFileName) + '\BLF_duplicates.csv');
        rewrite(DuplicateFile);
        writeln(DuplicateFile,'onebaseindex,id1,id2,boundary,SECONDonebaseindex,SECONDid1,SECONDid2,SECONDboundary');
        fDuplicate := True;
        for iPrimaryCount := 1 to (iBLFElements-1) do
        begin
             BLF.rtnValue(iPrimaryCount,@BLF_Element);

             for iSecondaryCount := (iPrimaryCount+1) to iBLFElements do
             begin
                  BLF.rtnValue(iSecondaryCount,@BLF_SecondaryElement);

                  if (BLF_Element.iId1 <> BLF_Element.iId2) then
                  begin
                       if ((BLF_Element.iId1 = BLF_SecondaryElement.iId1) and (BLF_Element.iId2 = BLF_SecondaryElement.iId2))
                       or ((BLF_Element.iId1 = BLF_SecondaryElement.iId2) and (BLF_Element.iId2 = BLF_SecondaryElement.iId1)) then
                       begin
                            writeln(DuplicateFile,IntToStr(iPrimaryCount) + ',' + IntToStr(BLF_Element.iId1) + ',' + IntToStr(BLF_Element.iId2) + ',' + FloatToStr(BLF_Element.rBoundary) + ',' +
                                                  IntToStr(iSecondaryCount) + ',' + IntToStr(BLF_SecondaryElement.iId1) + ',' + IntToStr(BLF_SecondaryElement.iId2) + ',' + FloatToStr(BLF_SecondaryElement.rBoundary));

                            // mark primary and secondary elements as duplicates
                            Duplicates.setValue(iPrimaryCount,@fDuplicate);
                            Duplicates.setValue(iSecondaryCount,@fDuplicate);
                       end;
                  end;
             end;
        end;
        closefile(DuplicateFile);

        // parse elements again, writing duplicates to one file & non-duplicates to another file
        assignfile(AFile,ExtractFilePath(sBLFFileName) + '\BLFraw_duplicates.csv');
        rewrite(AFile);
        writeln(AFile,'id1,id2,boundary');
        assignfile(BFile,ExtractFilePath(sBLFFileName) + '\BLFraw_nonduplicates.csv');
        rewrite(BFile);
        writeln(BFile,'id1,id2,boundary');
        for iCount := 1 to iBLFElements do
        begin
             // is this row a duplicate ?
             Duplicates.rtnValue(iCount,@fDuplicate);
             BLF.rtnValue(iCount,@BLF_Element);
             if fDuplicate then
                writeln(AFile,IntToStr(BLF_Element.iId1) + ',' + IntToStr(BLF_Element.iId2) + ',' + FloatToStr(BLF_Element.rBoundary))
             else
                 writeln(BFile,IntToStr(BLF_Element.iId1) + ',' + IntToStr(BLF_Element.iId2) + ',' + FloatToStr(BLF_Element.rBoundary));
        end;
        closefile(AFile);
        closefile(BFile);
        
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ProcessBLFFile',mtInformation,[mbOk],0);
     end;
end;

procedure TBLFProcessForm.BitBtn1Click(Sender: TObject);
begin
     Screen.Cursor := crHourglass;
     try
        ProcessBLFFile(EditBLFFile.Text);
     except
     end;  
     Screen.Cursor := crDefault;
end;

end.

