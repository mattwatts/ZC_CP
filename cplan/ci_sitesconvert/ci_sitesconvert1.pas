unit ci_sitesconvert1;

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
    BitBtnConvert: TBitBtn;
    procedure BitBtnExitClick(Sender: TObject);
    procedure BitBtnConvertClick(Sender: TObject);
    procedure btnLocateClick(Sender: TObject);
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

procedure ConvertCISiteKeyFile(const sCSVFileName : string);
var
   iSite, iFeature, iElements, iElement : integer;
   InFile, OutFile : TextFile;
   sLine : string;
   sElement : string;
   rElement : single;

   procedure ParseLine;
   var
      iCount, iPos : integer;
   begin
        iFeature := 0;
        iElement := 0;
        iElements := CountCommas(sLine) + 1;
        repeat
              Inc(iElement);
              iPos := Pos(',',sLine);
              if (iPos = 0) then // comma does not exist
              begin
                   sElement := sLine;
                   sLine := '';
              end
              else
              if (iPos = 1) then // comma is first element
              begin
                   sElement := '';
                   sLine := Copy(sLine,2,Length(sLine)-1);
              end
              else
              begin
                   sElement := Copy(sLine,1,iPos-1);
                   sLine := Copy(sLine,iPos+1,Length(sLine)-iPos);
              end;

              if (sElement <> '') and (sElement <> ' ') then
                 writeln(OutFile,sElement);
        until (iElement >= iElements);
   end;

begin
     try
        Screen.Cursor := crHourglass;

        assignfile(InFile,sCSVFileName);
        reset(InFile);

        assignfile(OutFile,ExtractFilePath(sCSVFileName) + '\SiteKey.csv');
        rewrite(OutFile);
        writeln(OutFile,'SITEKEY');

        iSite := 0;
        repeat
              Inc(iSite);
              readln(InFile,sLine);

              ParseLine;

              ConvertCISitesForm.Caption := IntToStr(iSite);

        until Eof(InFile);

        closefile(InFile);
        closefile(OutFile);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ConvertCISiteKeyFile',mtInformation,[mbOk],0);
     end;
end;
procedure TConvertCISitesForm.BitBtnConvertClick(Sender: TObject);
begin
     if fileexists(EditInSites.Text) then
     begin
          ConvertCISiteKeyFile(EditInSites.Text);

          MessageDlg('File converted ok',mtInformation,[mbOk],0);

          Application.Terminate;
     end;
end;

procedure TConvertCISitesForm.btnLocateClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
        EditInSites.Text := OpenDialog1.Filename;
end;

end.
