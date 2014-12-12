unit Testdde;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, DdeMan;

type
  TDDETestForm = class(TForm)
    DDEActivate: TCheckBox;
    ClientItem: TDdeClientItem;
    ClientConv: TDdeClientConv;
    InfoBox: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    txtService: TEdit;
    txtTopic: TEdit;
    btnConnect: TButton;
    procedure FormActivate(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DDETestForm: TDDETestForm;
  sService,sTopicX : string;

implementation

uses Dde_unit;

{$R *.DFM}

procedure TDDETestForm.FormActivate(Sender: TObject);
begin
     txtService.text := 'WinERMS';
     txtTopic.text := 'c:\winerms\initord.wmp';
end;

procedure TDDETestForm.btnConnectClick(Sender: TObject);
begin
     InfoBox.Clear;

     sService := txtService.text;
     sTopicX := txtTopic.text;

     if DDEOpenLink then
        InfoBox.Items.Add('connection established')
     else
         InfoBox.Items.Add('no connection');
end;

end.
