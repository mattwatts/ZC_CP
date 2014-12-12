unit marxan_summary;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TMarxanSummaryForm = class(TForm)
    ResultBox: TListBox;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MarxanSummaryForm: TMarxanSummaryForm;

implementation

uses
    Control, Global;

{$R *.DFM}

procedure TMarxanSummaryForm.BitBtn1Click(Sender: TObject);
begin
     ModalResult := mrOk;
end;

procedure TMarxanSummaryForm.FormCreate(Sender: TObject);
begin
     // load output_log.dat
     ResultBox.Items.Clear;
     ResultBox.Items.LoadFromFile(ControlRes^.sDatabase + '\marxan\output\output_log.dat');
end;

end.
