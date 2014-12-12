unit About;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAboutForm = class(TForm)
    ProductName: TLabel;
    Version: TLabel;
    BitBtn1: TBitBtn;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

uses
    {Global,} SysUtils;

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
     //DateTimeToStr(FileDateToDateTime(iTime));
     FindClose(SRec);
end;

procedure TAboutForm.FormCreate(Sender: TObject);
begin
     Version.Caption := 'Version : 0.9';
end;
       
end.

