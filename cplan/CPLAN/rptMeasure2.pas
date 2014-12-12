unit rptMeasure2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TReportMeasure2Form = class(TForm)
    EditFileName: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    btnBrowse: TButton;
    Label1: TLabel;
    SaveDialog1: TSaveDialog;
    ListBox1: TListBox;
    procedure BitBtn1Click(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ReportMeasure2Form: TReportMeasure2Form;

implementation

uses
    Reports, Global, Control;

{$R *.DFM}

procedure PopulateListBox;
begin
     ReportMeasure2SummaryToListBox(ReportMeasure2Form.Listbox1);
end;

procedure TReportMeasure2Form.BitBtn1Click(Sender: TObject);
begin
     ReportMeasure2Summary(EditFileName.Text);
end;

procedure TReportMeasure2Form.btnBrowseClick(Sender: TObject);
begin
     SaveDialog1.InitialDir := ControlRes^.sWorkingDirectory;
     if SaveDialog1.Execute then
        EditFilename.Text := SaveDialog1.Filename;
end;

procedure TReportMeasure2Form.FormActivate(Sender: TObject);
begin
     PopulateListBox;
end;

end.
