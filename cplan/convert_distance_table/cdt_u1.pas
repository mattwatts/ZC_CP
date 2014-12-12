unit cdt_u1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    EditIn: TEdit;
    btnBrowseIn: TButton;
    Label2: TLabel;
    EditOut: TEdit;
    btnBrowseOut: TButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure btnBrowseInClick(Sender: TObject);
    procedure btnBrowseOutClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

function ExtractFileNameNoExt(const sFileName : string) : string;
var
   iPos : integer;
begin
     Result := ExtractFileName(sFileName);
     iPos := Pos('.',Result);
     if (iPos > 1) then
        // trim file extension from the result
        Result := Copy(Result,1,iPos-1);
end;

function GetDelimitedAsciiElement(const sLine, sDelimiter : string;
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
          iPos := Pos(sDelimiter,sTrimLine);
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;
     end
     else
     begin
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;
     end;
end;

function CountDelimitersInRow(const sRow, sDelimiter : string) : integer;
var
   iCount : integer;
begin
     Result := 0;
     if (Length(sRow) > 0) then
        for iCount := 1 to Length(sRow) do
            if (sRow[iCount] = sDelimiter) then
               Inc(Result);
end;

procedure TForm1.btnBrowseInClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
     begin
          EditIn.Text := OpenDialog1.FileName;
          EditOut.Text := ExtractFilePath(EditIn.Text) + ExtractFileNameNoExt(EditIn.Text) + '_convert.txt';
     end;
end;

procedure TForm1.btnBrowseOutClick(Sender: TObject);
begin
     if SaveDialog1.Execute then
        EditOut.Text := SaveDialog1.FileName;
end;

function ConvertLine(const sLine : string) : string;
var
   iFields, iCount : integer;
   sElement : string;
begin
     Result := sLine;

     iFields := CountDelimitersInRow(sLine,',') + 1;

     Result := '';

     for iCount := 1 to iFields do
     begin
          if (iCount > 1) then
             Result := Result + ',';

          sElement := GetDelimitedAsciiElement(sLine,',',iCount);
          if (Pos('e',sElement) > 0) then
          begin
               // we need to convert the floating point value expressed in
               // scientific notation to fixed point notation
               //FloatToText
               sElement := FloatToStrF(StrToFloat(sElement),ffFixed,18,0);
          end;
          Result := Result + sElement;
     end;
end;

procedure ConvertDistanceTable(const sIn, sOut : string);
var
   InFile, OutFile : TextFile;
   sLine : string;
begin
     try
        Screen.Cursor := crHourglass;

        assignfile(InFile,sIn);
        reset(InFile);

        assignfile(OutFile,sOut);
        rewrite(OutFile);

        while not Eof(InFile) do
        begin
             readln(InFile,sLine);
             sLine := ConvertLine(sLine);
             writeln(OutFile,sLine);
        end;

        closefile(InFile);
        closefile(OutFile);

        Screen.Cursor := crDefault;

        MessageDlg('The file converted ok.',mtInformation,[mbOk],0);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ConvertDistanceTable',mtError,[mbOk],0);
     end;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
     ConvertDistanceTable(EditIn.Text,EditOut.Text);
     Application.Terminate;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
     Application.Terminate;
end;

end.
