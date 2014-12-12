unit cplanbuilder1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    EditInputCSV: TEdit;
    btnBrowse: TButton;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    OpenDialog1: TOpenDialog;
    CheckMarxan: TCheckBox;
    procedure btnBrowseClick(Sender: TObject);
    procedure BitBtnCancelClick(Sender: TObject);
    procedure BitBtnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

    // these types are for the sparse matrix implementation
    KeyFile_T = record
                  iSiteKey : integer;
                  iRichness : word;
                end;
    SingleValueFile_T = record
                    iFeatKey : word;
                    rAmount : single;
                  end;


var
  Form1: TForm1;

implementation

{$R *.DFM}

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

procedure BuildCPlan(const sFileName : string;const fMarxanStyleMatrix : boolean);
var
   InFile, OutSite, OutFeat : TextFile;
   sLine : string;
   iPreviousSiteKey,iSiteKey,iFeatKey : integer;
   rAmount : extended;
   KeyFileElement : KeyFile_T;
   ValueFileElement : SingleValueFile_T;
   KeyFile, ValueFile : file;
   fFirstSiteKeyChange : boolean;
begin
     try
        iSiteKey := 0;
        iPreviousSiteKey := 0;

        fFirstSiteKeyChange := True;

        KeyFileElement.iSiteKey := iSiteKey;
        KeyFileElement.iRichness := 0;

        assignfile(KeyFile,ExtractFilePath(sFileName) + 'matrix.key');
        rewrite(KeyFile,1);
        assignfile(ValueFile,ExtractFilePath(sFileName) + 'matrix.mtx');
        rewrite(ValueFile,1);

        assignfile(InFile,sFileName);
        reset(InFile);

        readln(InFile);
        repeat
              readln(InFile,sLine);

              if fMarxanStyleMatrix then
              begin
                   iSiteKey := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
                   iFeatKey := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
              end
              else
              begin
                   iSiteKey := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
                   iFeatKey := StrToInt(GetDelimitedAsciiElement(sLine,',',2));     
              end;
              rAmount := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));

              ValueFileElement.iFeatKey := iFeatKey;
              ValueFileElement.rAmount := rAmount;
              // write element to ValueFile
              BlockWrite(ValueFile,ValueFileElement,SizeOf(SingleValueFile_T));


              if (iSiteKey <> iPreviousSiteKey) then
              begin
                   // site key has changed
                   if fFirstSiteKeyChange then
                   begin
                        iPreviousSiteKey := iSiteKey;
                        fFirstSiteKeyChange := False;
                   end
                   else
                   begin
                        // write element to KeyFile
                        BlockWrite(KeyFile,KeyFileElement,SizeOf(KeyFile_T));

                        iPreviousSiteKey := iSiteKey;
                        KeyFileElement.iRichness := 0;
                   end;
              end;

              KeyFileElement.iSiteKey := iSiteKey;
              Inc(KeyFileElement.iRichness);

        until Eof(InFile);

        // write the last element to KeyFile
        BlockWrite(KeyFile,KeyFileElement,SizeOf(KeyFile_T));

        closefile(KeyFile);
        closefile(ValueFile);

        closefile(InFile);

     except
           MessageDlg('Exception in BuildCPlan',mtError,[mbOk],0);
     end;
end;

procedure TForm1.btnBrowseClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
        EditInputCSV.Text := OpenDialog1.FileName;
end;

procedure TForm1.BitBtnCancelClick(Sender: TObject);
begin
     Application.Terminate;
end;

procedure TForm1.BitBtnOkClick(Sender: TObject);
begin
     BuildCPlan(EditInputCSV.Text,CheckMarxan.Checked);
end;

end.
