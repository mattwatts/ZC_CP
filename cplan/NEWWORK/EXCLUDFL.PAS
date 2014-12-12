unit Excludfl;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Menus, Grids;

type
  TFailExSites = class(TForm)
    Panel1: TPanel;
    btnAccept: TButton;
    btnRemove: TButton;
    CheckBox1: TCheckBox;
    PopupAccept: TPopupMenu;
    PopupRemove: TPopupMenu;
    ThisSite1: TMenuItem;
    RemainingSites1: TMenuItem;
    ThisSite2: TMenuItem;
    AllSites1: TMenuItem;
    RemainingSites2: TMenuItem;
    btnOk: TButton;
    lblInfo: TLabel;
    btnCancel: TButton;
    AGrid: TStringGrid;
    procedure btnAcceptClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure ThisSite1Click(Sender: TObject);
    procedure RemainingSites1Click(Sender: TObject);
    procedure ThisSite2Click(Sender: TObject);
    procedure RemainingSites2Click(Sender: TObject);
    procedure AllSites1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FailExSites: TFailExSites;
  iFailExSitesResult : integer;

implementation

uses
    Global, Control;

{$R *.DFM}

procedure TFailExSites.btnAcceptClick(Sender: TObject);
begin
     PopupAccept.Popup(Left + btnAccept.Left + btnAccept.Width,
                       Top + btnAccept.Height);

     {modalresult := idOK;}
end;

procedure TFailExSites.btnRemoveClick(Sender: TObject);
begin
     PopupRemove.Popup(Left + btnRemove.Left + btnRemove.Width,
                       Top + btnRemove.Height);

     {listbox1.items.clear;
     modalResult := idCancel;}
end;

procedure TFailExSites.btnOkClick(Sender: TObject);
begin
     ModalResult := mrOk;
end;

procedure TFailExSites.ThisSite1Click(Sender: TObject);
begin
     iFailExSitesResult := TEST_ACCEPT_THIS;
     ModalResult := mrOk;
end;

procedure TFailExSites.RemainingSites1Click(Sender: TObject);
begin
     iFailExSitesResult := TEST_ACCEPT_ALL;
     ModalResult := mrOk;
end;

procedure TFailExSites.ThisSite2Click(Sender: TObject);
begin
     iFailExSitesResult := TEST_REMOVE_THIS;
     ModalResult := mrOk;
end;

procedure TFailExSites.RemainingSites2Click(Sender: TObject);
begin
     iFailExSitesResult := TEST_REMOVE_REST;
     ModalResult := mrOk;
end;

procedure TFailExSites.AllSites1Click(Sender: TObject);
begin
     iFailExSitesResult := TEST_REMOVE_ALL;
     ModalResult := mrOk;
end;

procedure TFailExSites.CheckBox1Click(Sender: TObject);
begin
     iFailExSitesResult := TEST_ACCEPT_ALL;
     ModalResult := mrOk;
     fWatchExc := False;
     CheckBox1.Visible := False;
end;

procedure TFailExSites.btnCancelClick(Sender: TObject);
begin
     ModalResult := mrCancel;
end;

procedure TFailExSites.FormResize(Sender: TObject);
begin
     {resize the grids to fit into the screen}
     try
        AGrid.DefaultColWidth := (ClientWidth div AGrid.ColCount) - 2 +
                                 Trunc((ClientWidth mod AGrid.ColCount)/AGrid.ColCount);

     except
           AGrid.DefaultColWidth := 1;
     end;
end;

end.
