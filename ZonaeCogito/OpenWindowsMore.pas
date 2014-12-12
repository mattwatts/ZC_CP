unit OpenWindowsMore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TOpenMoreForm = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpenMoreForm: TOpenMoreForm;

implementation

uses SCP_Main;

{$R *.DFM}

procedure TOpenMoreForm.FormCreate(Sender: TObject);
var
   iCount : integer;
begin
     ListBox1.Items.Clear;

     if (MDIChildCount > 0) then
        for iCount := 0 to (MDIChildCount - 1) do
            ListBox1.Items.Add(MDIChildren[iCount].Caption);
end;

procedure TOpenMoreForm.ListBox1Click(Sender: TObject);
begin
     SCPForm.FileOpen(ListBox1.Items.Strings[ListBox1.ItemIndex]);
     ModalResult := mrOk;
end;

procedure TOpenMoreForm.BitBtn1Click(Sender: TObject);
begin
     SCPForm.FileOpen(ListBox1.Items.Strings[ListBox1.ItemIndex]);   
end;

end.
