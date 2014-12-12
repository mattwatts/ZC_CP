unit userkey;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TSelectKeyForm = class(TForm)
    ListBox1: TListBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
    procedure initchild(const sChild : string);
    procedure ListBox1DblClick(Sender: TObject);
  private
    { Private declarations }
    sTable : string;
  public
    { Public declarations }
  end;

var
  SelectKeyForm: TSelectKeyForm;

implementation

uses MAIN, Childwin;

{$R *.DFM}

procedure TSelectKeyForm.initchild(const sChild : string);
var
   AChild : TMDIChild;
   iCount : integer;
begin
     try
        //sTable := sChild;
        //AChild := MainForm.rtnChild(sTable);
        //listbox1.items.clear;
        //for iCount := 0 to (AChild.aGrid.ColCount - 1) do
        //    listbox1.items.add(AChild.aGrid.Cells[iCount,0]);
        //listbox1.itemindex := listbox1.items.indexof(AChild.KeyCombo.Text);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSelectKeyForm.initchild',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSelectKeyForm.BitBtn1Click(Sender: TObject);
var
   AChild : TMDIChild;
begin
     {make this the key field in sTable}
     //AChild := MainForm.rtnChild(sTable);
     AChild.KeyCombo.Text := ListBox1.Items.Strings[ListBox1.ItemIndex];
     AChild.KeyFieldGroup.ItemIndex := ListBox1.ItemIndex;
end;

procedure TSelectKeyForm.ListBox1DblClick(Sender: TObject);
begin
     BitBtn1Click(self);
     ModalResult := mrOk;
end;

end.
