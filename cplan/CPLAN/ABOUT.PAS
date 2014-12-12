unit About;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    OKButton: TBitBtn;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    lblVer: TLabel;
    Label3: TLabel;
    Image1: TImage;
    Label1: TLabel;
    lblExeDate: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

uses
    Global, version, SysUtils, IniFiles;

{$R *.DFM}

function ReturnFileDate(const sDir : string) : string;
var
   SRec : TSearchRec;
   sTime : string;
   iResult : integer;
   iTime : integer;
begin
     iResult := FindFirst(sDir,faAnyFile,SRec);
     iTime := SRec.Time;
     Result := FormatDateTime('ddd, mmm d, yyyy, hh:mm AM/PM',
                              FileDateToDateTime(iTime));
     FindClose(SRec);
end;

procedure TAboutBox.FormCreate(Sender: TObject);
var
   sExeFile : string;
begin
     lblVer.Caption := CPLAN_VERSION;

     sExeFile := Application.ExeName;
     lblExeDate.Caption := ReturnFileDate(sExeFile);
end;






end.

