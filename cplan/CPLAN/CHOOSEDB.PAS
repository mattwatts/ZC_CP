unit Choosedb;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TChooseDBForm = class(TForm)
    DBBox: TListBox;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    procedure DBBoxDblClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ChooseDBForm: TChooseDBForm;

implementation

uses Control, start;

{$R *.DFM}

procedure TChooseDBForm.DBBoxDblClick(Sender: TObject);
var
   iCount : integer;
begin
     for iCount := 1 to DBBox.Items.Count do
         if DBBox.Selected[iCount-1] then
            iDBToLoad := iCount;

     ModalResult := mrOK;
end;

procedure TChooseDBForm.BitBtn1Click(Sender: TObject);
begin
     iDBToLoad := -1;
     {StartForm.Free;
     Application.Terminate;}
     ModalResult := mrOK;
end;

end.
