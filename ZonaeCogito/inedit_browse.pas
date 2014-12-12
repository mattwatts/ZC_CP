unit inedit_browse;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl;

type
  TInEditBrowseForm = class(TForm)
    DirectoryListBox1: TDirectoryListBox;
    Edit1: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    procedure DirectoryListBox1Change(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    mode:integer;
  end;

var
  InEditBrowseForm: TInEditBrowseForm;

implementation

uses
    ineditp;

{$R *.DFM}

procedure TInEditBrowseForm.DirectoryListBox1Change(Sender: TObject);
begin
     Edit1.text := DirectoryListBox1.directory;
end;

procedure TInEditBrowseForm.btnOkClick(Sender: TObject);
begin
     case mode of
          1: InEditForm.edit17.text := DirectoryListBox1.Directory;
          2: InEditForm.edit18.text := DirectoryListBox1.Directory;
     end;

     close;
end;

procedure TInEditBrowseForm.btnCancelClick(Sender: TObject);
begin
     Close;
end;

end.
