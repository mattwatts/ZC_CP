unit ci_mtx2_1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls;

type
  TMtx2CsvForm = class(TForm)
    OpenDialog1: TOpenDialog;
    btnLocate: TButton;
    EditInMtx: TEdit;
    Label1: TLabel;
    BitBtnConvert: TBitBtn;
    BitBtnExit: TBitBtn;
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
    SingleValueFile_T = record
                    iFeatKey : word;
                    rAmount : single;
                  end;

var
  Mtx2CsvForm: TMtx2CsvForm;

implementation

{$R *.DFM}


procedure TMtx2CsvForm.btnLocateClick(Sender: TObject);
begin
     If OpenDialog1.Execute then
        EditInMtx.Text := OpenDialog1.Filename;
end;

procedure TMtx2CsvForm.BitBtnExitClick(Sender: TObject);
begin
     Application.Terminate;
end;

procedure ConvertMtx(const sMtxFile : string);
var
   Key : KeyFile_T;
   Value : SingleValueFile_T;
   ValueFile, KeyFile : file;
   iLength, iCount, iMaxFeatKey : integer;
   OutSiteKey, OutValue, MaxFeatKey : TextFile;
begin
     iLength := Length(sMtxFile);
     assignfile(ValueFile,sMtxFile);
     reset(ValueFile,1);
     assignfile(KeyFile,Copy(sMtxFile,1,iLength-3) + 'key');
     reset(KeyFile,1);

     assignfile(OutSiteKey,ExtractFilePath(sMtxFile) + '\SiteKey.csv');
     rewrite(OutSiteKey);
     writeln(OutSiteKey,'SITEKEY,RICHNESS');

     assignfile(MaxFeatKey,ExtractFilePath(sMtxFile) + '\MaxFeatKey.csv');
     rewrite(MaxFeatKey);
     writeln(MaxFeatKey,'FEATKEY');

     assignfile(OutValue,ExtractFilePath(sMtxFile) + '\Value.csv');
     rewrite(OutValue);
     writeln(OutValue,'SITEKEY,FEATUREKEY,VALUE');

     iMaxFeatKey := 0;

     repeat
           BlockRead(KeyFile,Key,SizeOf(Key));
           writeln(OutSiteKey,IntToStr(Key.iSiteKey) + ',' + IntToStr(Key.iRichness));

           if (Key.iRichness > 0) then
              for iCount := 1 to Key.iRichness do
              begin
                   // process Key.iRichness elements
                   BlockRead(ValueFile,Value,SizeOf(Value));
                   writeln(OutValue,IntToStr(Key.iSiteKey) + ',' + IntToStr(Value.iFeatKey) + ',' + FloatToStr(Value.rAmount));

                   if (Value.iFeatKey > iMaxFeatKey) then
                      iMaxFeatKey := Value.iFeatKey;
              end;
     until Eof(KeyFile);

     writeln(MaxFeatKey,IntToStr(iMaxFeatKey));

     closefile(ValueFile);
     closefile(KeyFile);
     closefile(OutSiteKey);
     closefile(MaxFeatKey);
     closefile(OutValue);
end;

procedure TMtx2CsvForm.BitBtnConvertClick(Sender: TObject);
begin
     ConvertMtx(EditInMtx.Text);

     MessageDlg('conversion finished',mtInformation,[mbOk],0);
     Application.Terminate;
end;

end.
