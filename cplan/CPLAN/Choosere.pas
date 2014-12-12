unit Choosere;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TChooseResForm = class(TForm)
    CResBox: TListBox;
    Panel1: TPanel;
    Button1: TButton;
    procedure CResBoxDblClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ChooseResForm: TChooseResForm;

implementation

uses
    Calcfld, IniFiles, Control, Global;

{$R *.DFM}

procedure TChooseResForm.CResBoxDblClick(Sender: TObject);
var
   sField : string;
   iCount : integer;
begin
     for iCount := 0 to CResBox.Items.Count-1 do
         if CResBox.Selected[iCount] then
            sField := CResBox.Items.Strings[iCount];

     ProcessTimberResource(sField,FALSE);

     {ModalResult := mrOK;}
end;

procedure TChooseResForm.BitBtn1Click(Sender: TObject);
begin
     ModalResult := mrOK;
end;

procedure TChooseResForm.FormCreate(Sender: TObject);
var
   AIni : TIniFile;
begin
     if ControlRes^.fOldIni then
	AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME)
     else
	 AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);

     AIni.ReadSection(S_TIMBER_RES,CResBox.Items);
     if (CResBox.Items.Count = 0) then
        AIni.ReadSection(S_RESOURCE,CResBox.Items);

     AIni.Free;
end;

procedure TChooseResForm.Button1Click(Sender: TObject);
begin
     modalresult := mrok;
end;

end.
