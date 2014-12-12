unit delim_parse;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Spin, StdCtrls, ExtCtrls, Buttons;

type
  TParseDelimitedFileForm = class(TForm)
    EditIn: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    EditOut: TEdit;
    btnBrowse: TButton;
    OpenDialog1: TOpenDialog;
    Label3: TLabel;
    EditDelimiter: TEdit;
    EditName: TEdit;
    Label5: TLabel;
    EditValue: TEdit;
    RadioType: TRadioGroup;
    SpinIndex: TSpinEdit;
    BitBtnParse: TBitBtn;
    BitBtn2: TBitBtn;
    procedure BitBtnParseClick(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ParseDelimitedFileForm: TParseDelimitedFileForm;

implementation

{$R *.DFM}

function GetDelimitedAsciiColumn(const sLine, sElement, sDelimiter : string) : integer;
// returns the 1-based-index of the column in sLine containing sElement
// returns 0 if sElement does not exist within sLine
var
   iPos, iDelimiters, iCount : integer;
begin
     iPos := Pos(lowercase(sElement),lowercase(sLine));
     if (iPos > 0) then
     begin
          // count how many delimiters are between 1 and iPos
          iDelimiters := 0;
          if (iPos > 1) then
             for iCount := 1 to (iPos - 1) do
                 if (sLine[iCount] = sDelimiter) then
                    Inc(iDelimiters);
          Result := iDelimiters + 1;
     end
     else
         Result := 0;
end;

function GetDelimitedAsciiElement(const sLine, sDelimiter : string;
                                  const iColumn : integer) : string;
// returns the element at 1-based-index column iColumn
// returns 0 if the column does not exist in sLine
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
     if (iPos > 0) then
        Result := Copy(sTrimLine,1,iPos-1)
     else
         Result := sTrimLine;
end;

procedure SimpleSQLTypeParseDelimitedFile(const sInputFile, sOutputFile, sDelimiter, sFieldName, sFieldValue : string;
                                          const iFieldType, iFieldIndex : integer);
var
   InputFile, OutputFile : TextFile;
   sHeader, sLine, sElementValue : string;
   iFieldIndexInFile : integer;

   // iFieldType
   //   0 use field name
   //   1 use field index
begin
     try
        assignfile(InputFile,sInputFile);
        reset(InputFile);
        assignfile(OutputFile,sOutputFile);
        rewrite(OutputFile);

        // write the header row to the new file
        readln(InputFile,sHeader);
        writeln(OutputFile,sHeader);

        // find the 1 based index of the field we are comparing
        if (iFieldType = 0) then
           iFieldIndexInFile := GetDelimitedAsciiColumn(sHeader,sFieldName,sDelimiter)
        else
            iFieldIndexInFile := iFieldIndex;
        // parse data rows of the input file and write those that
        // satisfy the simple SQL type query
        repeat
              readln(InputFile,sLine);

              sElementValue := GetDelimitedAsciiElement(sLine,
                                                        sDelimiter,
                                                        iFieldIndexInFile);
              if (LowerCase(sFieldValue) =
                  LowerCase(sElementValue)) then
                 writeln(OutputFile,sLine);

        until Eof(InputFile);

        closefile(InputFile);
        closefile(OutputFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in SimpleSQLTypeParseDelimitedFile',mtError,[mbOk],0);
     end;
end;

procedure TParseDelimitedFileForm.BitBtnParseClick(Sender: TObject);
begin
     Screen.Cursor := crHourglass;

     SimpleSQLTypeParseDelimitedFile(EditIn.Text,
                                     EditOut.Text,
                                     EditDelimiter.Text,
                                     EditName.Text,
                                     EditValue.Text,
                                     RadioType.ItemIndex,
                                     SpinIndex.Value);

     Screen.Cursor := crDefault;

     MessageDlg('Finished processing file',mtInformation,[mbOk],0);
end;

procedure TParseDelimitedFileForm.BitBtn2Click(Sender: TObject);
begin
     Application.Terminate;
end;

function NameOutputFile(const sFile : string) : string;
begin
     Result := sFile + '_output.txt';
end;

procedure TParseDelimitedFileForm.btnBrowseClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
     begin
          EditIn.Text := OpenDialog1.FileName;
          EditOut.Text := NameOutputFile(OpenDialog1.FileName);
     end;
end;

end.
