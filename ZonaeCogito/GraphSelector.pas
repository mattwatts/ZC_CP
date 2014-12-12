unit GraphSelector;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TGraphSelectorForm = class(TForm)
    Label1: TLabel;
    ComboInputFile: TComboBox;
    RadioGraphType: TRadioGroup;
    BitBtnOk: TBitBtn;
    BitBtn2: TBitBtn;
    btnBrowse: TButton;
    OpenDialog1: TOpenDialog;
    procedure ReturnCSVChildren;
    procedure PrepareForm;
    procedure StartLineGraph;
    procedure StartBarGraph(const iGraphType : integer);
    procedure btnBrowseClick(Sender: TObject);
    procedure BitBtnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GraphSelectorForm: TGraphSelectorForm;

implementation

uses SCP_Main, graph, CSV_Child, BarGraph;

{$R *.DFM}

procedure TGraphSelectorForm.ReturnCSVChildren;
var
   iCount : integer;
begin
     ComboInputFile.Text := '';
     ComboInputFile.Items.Clear;

     for iCount := 0 to (SCPForm.MDIChildCount - 1) do
         if (SCPForm.MDIChildren[iCount].Tag = 4) then
            ComboInputFile.Items.Add(SCPForm.MDIChildren[iCount].Caption);

     if (ComboInputFile.Items.Count > 0) then
        ComboInputFile.Text := ComboInputFile.Items.Strings[0];
end;


procedure TGraphSelectorForm.PrepareForm;
var
   iCSVChildIndex, iCount : integer;
   AChild : TCSVChild;
begin
     try
        ReturnCSVChildren;

     except
           MessageDlg('Exception in TGraphSelectorForm.PrepareForm',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TGraphSelectorForm.StartLineGraph;
var
   iCount : integer;
   AChild : TCSVChild;
begin
     try
        AChild := TCSVChild(SCPForm.ReturnNamedChild(ComboInputFile.Text));

        if (AChild = nil) then
        begin
             SCPForm.CSVFileOpen(ComboInputFile.Text);
             AChild := TCSVChild(SCPForm.ReturnNamedChild(ComboInputFile.Text));
        end;

        if (AChild <> nil) then
        begin
             GraphForm := TGraphForm.Create(Application);
             with GraphForm do
             begin
                  sCsvChildName := AChild.Caption;
                  sXField := AChild.aGrid.Cells[0,0];
                  sYField := AChild.aGrid.Cells[1,0];

                  // add field names to X & Y field controls
                  ComboXAxis.Items.Clear;
                  ComboXAxis.Text := sXField;
                  ComboYAxis.Items.Clear;
                  ComboYAxis.Text := sYField;
                  for iCount := 0 to (AChild.aGrid.ColCount - 1) do
                  begin
                       ComboXAxis.Items.Add(AChild.aGrid.Cells[iCount,0]);
                       ComboYAxis.Items.Add(AChild.aGrid.Cells[iCount,0]);
                  end;

                  GraphCSVChild := AChild;
             end;

             GraphForm.Caption := 'Graph ' + AChild.Caption;
             GraphForm.ShowModal;
             GraphForm.Free;
        end;

     except
           MessageDlg('Exception in TGraphSelectorForm.StartLineGraph',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TGraphSelectorForm.StartBarGraph(const iGraphType : integer);
begin
     try
     fBarGraphStarting := True;
        BarGraphForm := TBarGraphForm.Create(Application);
        BarGraphForm.InitGraph(iGraphType);
        BarGraphForm.ShowModal;
        BarGraphForm.Free;

     except
           MessageDlg('Exception in TGraphSelectorForm.StartBarGraph',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TGraphSelectorForm.btnBrowseClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
     begin
          if (ComboInputFile.Items.IndexOf(OpenDialog1.Filename) = -1) then
          begin
               ComboInputFile.Items.Add(OpenDialog1.Filename);
          end;
          ComboInputFile.Text := OpenDialog1.Filename;
     end;
end;

procedure TGraphSelectorForm.BitBtnOkClick(Sender: TObject);
begin
     try
        if (RadioGraphType.ItemIndex = 0) then
           StartLineGraph
        else
            StartBarGraph(RadioGraphType.ItemIndex);

     except
           MessageDlg('Exception in TGraphSelectorForm.BitBtnOkClick',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TGraphSelectorForm.FormCreate(Sender: TObject);
begin
     PrepareForm;
end;

end.
