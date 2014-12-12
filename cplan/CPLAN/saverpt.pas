unit saverpt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, Buttons;

type
  TSaveRptForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OutputFile: TMaskEdit;
    Label1: TLabel;
    Label2: TLabel;
    Metadata: TMemo;
    SaveReport: TSaveDialog;
    procedure PrepFeatures(const sRpt : string);
    procedure PrepSites(const sRpt : string);
    procedure FormResize(Sender: TObject);
    procedure OutputFileMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SetOutputFile;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SaveRptForm: TSaveRptForm;

implementation

uses
    Spatio, global, control;

{$R *.DFM}

procedure TSaveRptForm.SetOutputFile;
begin
     //
     SaveReport.InitialDir := ExtractFilePath(OutputFile.Text);
     SaveReport.Filename := ExtractFileName(OutputFile.Text);
     if SaveReport.Execute then
        OutputFile.Text := SaveReport.Filename;
end;

procedure TSaveRptForm.PrepFeatures(const sRpt : string);
begin
     //
     Caption := 'Enter Feature report output file and description';
     OutputFile.Text := rtnUniqueFileName(ControlRes^.sWorkingDirectory +'\features_' + sRpt,'csv');
end;

procedure TSaveRptForm.PrepSites(const sRpt : string);
begin
     //
     Caption := 'Enter Site report output file and description';
     OutputFile.Text := rtnUniqueFileName(ControlRes^.sWorkingDirectory +'\sites_' + sRpt,'csv')
end;

procedure TSaveRptForm.FormResize(Sender: TObject);
begin
     ClientWidth := BitBtn2.Left + BitBtn2.Width + BitBtn1.Left;
     ClientHeight := BitBtn2.Top + BitBtn2.Height + Label1.Top;
end;

procedure TSaveRptForm.OutputFileMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     SetOutputFile;
end;

procedure TSaveRptForm.FormCreate(Sender: TObject);
begin
     FormResize(self);
end;

end.
