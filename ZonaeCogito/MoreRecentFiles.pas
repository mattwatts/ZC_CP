unit MoreRecentFiles;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TRecentMoreForm = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RecentMoreForm: TRecentMoreForm;

implementation

uses SCP_Main, IniFiles;

{$R *.DFM}

procedure TRecentMoreForm.FormCreate(Sender: TObject);
var
   AIni : TIniFile;
   iCount, iDuplicateIndex : integer;
begin
     //
     try
        AIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'UserSettings.ini');
        AIni.ReadSection('FileOpen',ListBox1.Items);
        AIni.Free;

     except
     end;
end;

procedure TRecentMoreForm.ListBox1DblClick(Sender: TObject);
begin
     SCPForm.GiveWindowFocus(ListBox1.Items.Strings[ListBox1.ItemIndex]);
     ModalResult := mrOk;
end;

procedure TRecentMoreForm.BitBtn1Click(Sender: TObject);
begin
     SCPForm.GiveWindowFocus(ListBox1.Items.Strings[ListBox1.ItemIndex]);
end;

end.
