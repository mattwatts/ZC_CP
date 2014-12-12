unit Showimp;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TShowImpForm = class(TForm)
    Panel1: TPanel;
    ViewBox: TListBox;
    BitBtn1: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
    procedure PrepFormIni(const sIni : string);
    procedure AddLineField(const sLine : string);
    procedure PrepFormField(const sInFile,sUpdateFile,
                            sInKey,sUpdateKey : string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ShowImpForm: TShowImpForm;

procedure ShowImpSummaryForm(const sIni : string);

procedure StartFieldSummary(const sInFile,sUpdateFile,
                            sInKey,sUpdateKey : string);
procedure EndFieldSummary;

implementation

{$R *.DFM}

uses
    IniFiles;

procedure StartFieldSummary(const sInFile,sUpdateFile,
                            sInKey,sUpdateKey : string);
begin
     {try}

        ShowImpForm := TShowImpForm.Create(application);
        ShowImpForm.PrepFormField(sInFile,sUpdateFile,
                                  sInKey,sUpdateKey);
        {ShowImpForm.Show;}

     {finally
            ShowImpForm.Free;
     end;}
end;

procedure EndFieldSummary;
begin
     try
        ShowImpForm.ShowModal;

     finally
            ShowImpForm.Free;
     end;
end;

procedure ShowImpSummaryForm(const sIni : string);
begin
     try
        ShowImpForm := TShowImpForm.Create(application);
        ShowImpForm.PrepFormIni(sIni);
        ShowImpForm.ShowModal;

     finally
            ShowImpForm.Free;
     end;
end;

procedure TShowImpForm.BitBtn1Click(Sender: TObject);
begin
     ModalResult := mrOk;
end;

procedure TShowImpForm.AddLineField(const sLine : string);
begin
     ViewBox.Items.Add(sLine);
end;

procedure TShowImpForm.PrepFormIni(const sIni : string);
var
   AnIni : TIniFile;
   iDBCount, iCount : integer;
   sFile, sDBName, sX : string;
begin
     {do something}
     Caption := 'Database Info';

     if FileExists(sIni) then
     begin
          AnIni := TIniFile.Create(sIni);

          with ViewBox.Items do
          begin
               Clear;
               Add('Path : ' + sIni);
               Add('  SiteSummaryTable : ' +
                   AnIni.ReadString('Options','SiteSummaryTable','NOT FOUND'));

               iDBCount := 0;
               iCount := 1;

               repeat
                     sDBName := 'Database' + IntToStr(iCount);
                     sFile := AnIni.ReadString(sDBName,
                                               'Name','NOT FOUND');

                     if (sFile <> 'NOT FOUND') then
                     begin
                          Inc(iCount);
                          Inc(iDBCount);

                          Add('');
                          Add(sDBName);
                          Add('  Name : ' + AnIni.ReadString(sDBName,'Name','NOT FOUND'));

                          sX := AnIni.ReadString(sDBName,'MatrixFile','NOT FOUND');
                          if (sX = 'NOT FOUND') then
                             sX := AnIni.ReadString(sDBName,'SiteFeatureTable','NOT FOUND');

                          Add('  Matrix : ' + sX);

                          sX := AnIni.ReadString(sDBName,'FeatureSummaryTable','NOT FOUND');
                          if (sX = 'NOT FOUND') then
                             sX := AnIni.ReadString(sDBName,'FeatureCutOffsTable','NOT FOUND');

                          Add('  Feature Summary Table : ' + sX);
                          Add('  Features : ' + AnIni.ReadString(sDBName,'MatrixSize','NOT FOUND'));

                          sX := AnIni.ReadString(sDBName,'PCCONTRCutOff','NOT FOUND');
                          if (sX = 'NOT FOUND') then
                             sX := AnIni.ReadString(sDBName,'PCUSEDCutOff','NOT FOUND');

                          Add('  PCCONTRCutOff : ' + sX);
                     end;

               until (sFile = 'NOT FOUND');

               Insert(2,'  Databases : ' + IntToStr(iDBCount));
          end;

          AnIni.Free;
     end
     else
     begin
          ViewBox.Items.Clear;
          ViewBox.Items.Add('Path : ' + sIni);
          ViewBox.Items.Add('');
          ViewBox.Items.Add('  not found');
     end;
end;

procedure TShowImpForm.PrepFormField(const sInFile,sUpdateFile,
                                           sInKey,sUpdateKey : string);
begin
     Caption := 'Import Log';

     with ViewBox.Items do
     begin
          Clear;
          Add('In File : ' + sInFile);
          Add('In Key Field : ' + sInKey);
          Add('Update File : ' + sUpdateFile);
          Add('Update Key Field : ' + sUpdateKey);
          Add('');
     end;
end;

end.
