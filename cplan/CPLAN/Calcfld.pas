unit Calcfld;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Gauges;

type
  TCalcFieldForm = class(TForm)
    btnStart: TButton;
    btnExit: TButton;
    barProgress: TGauge;
    RptBox: TListBox;
    btnSaveResource: TButton;
    SaveResourceReport: TSaveDialog;
    procedure btnStartClick(Sender: TObject);
    procedure CalcField;
    procedure btnExitClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSaveResourceClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CalcFieldForm: TCalcFieldForm;
  sFieldName : string;

procedure FindSustainableYield;
procedure ProcessTimberResource(const sResource : string;
                                const fNoUser : boolean);

implementation

uses
    Em_newu1, Control, IniFiles, Global,
    Sf_irrep;

{$R *.DFM}

procedure ProcessTimberResource(const sResource : string;
                                const fNoUser : boolean);
begin
     try
        Screen.Cursor := crHourglass;

        if not fContrDataDone then
           ExecuteIrreplaceability(-1,False,False,True,True,'');

        sFieldName := sResource;
        CalcFieldForm := TCalcFieldForm.Create(Application);

        CalcFieldForm.Caption := 'Process Resource ' + sResource;

        Screen.Cursor := crDefault;

        if fNoUser then
           CalcFieldForm.Show
        else
            CalcFieldForm.ShowModal;

     finally
            CalcFieldForm.Free;
     end;
end;

procedure FindSustainableYield;
begin
     try
        sFieldName := 'SYIELD';
        CalcFieldForm := TCalcFieldForm.Create(Application);

        CalcFieldForm.Caption := 'Find Sustainable Yield';

        CalcFieldForm.ShowModal;

     finally
            CalcFieldForm.Free;
     end;
end;

procedure TCalcFieldForm.CalcField;
var
   ASite : site;
   lCount : longint;
   rValue, rTotal, rTotalExc, rPartial, rR1, rR2, rR3, rR4, rR5, rTableValue : extended;
   sDB, sTenure, sTmp, sTest : string;
   iGeocode, iToTarget, iTotalExc, iPartialPC, iR1, iR2, iR3, iR4, iR5 : integer;
begin
     with ControlForm.OutTable do
     try
        RptBox.Items.Clear;

        Open;
        lCount := 1;

        rValue := 0;
        rTotal := 0;
        rTotalExc := 0;
        rPartial := 0;
        rR1 := 0;
        rR2 := 0;
        rR3 := 0;
        rR4 := 0;
        rR5 := 0;

        {we need to determine which field is the Tenure field, so we can parse it}
        {try I_STATUS, if this doesn't exist use TENURE}
        if not ControlRes^.fStatusTested then
        begin
             ControlRes^.fStatusTested := True;

             try
                sTest := FieldByName('I_STATUS').AsString;
                ControlRes^.sI_STATUSField := 'I_STATUS';
             except
                   ControlRes^.sI_STATUSField := 'TENURE';
             end;
        end;

        repeat
              SiteArr.rtnValue(lCount,@ASite);
              sDB := FieldByName(ControlRes^.sKeyField).AsString;
              sTenure := FieldByName(ControlRes^.sI_STATUSField).AsString;
              iGeocode := ASite.iKey;

              barProgress.Progress := Round((lCount / iSiteCount)*100);

              if (sTenure = 'Initial Available')
              or (sTenure = 'Available')
              or (sTenure = '') {tenure not set} then
              begin
                   rTableValue := FieldByName(sFieldName).AsFloat;

                   if (ASite.status <> _R1)
                   and (ASite.status <> _R2)
                   and (ASite.status <> _R3)
                   and (ASite.status <> _R4)
                   and (ASite.status <> _R5)
                   and (ASite.status <> Pd) then
                       rValue := rValue + rTableValue;
                       {rValue is the amount that is Av,Ex or Fl}

                   if (ASite.status = Pd) then
                      rPartial := rPartial + rTableValue;

                   if (ASite.status = _R1) then
                      rR1 := rR1 + rTableValue;

                   if (ASite.status = _R2) then
                      rR2 := rR2 + rTableValue;

                   if (ASite.status = _R3) then
                      rR3 := rR3 + rTableValue;

                   if (ASite.status = _R4) then
                      rR4 := rR4 + rTableValue;

                   if (ASite.status = _R5) then
                      rR5 := rR5 + rTableValue;

                   rTotal := rTotal + rTableValue;

                   if (ASite.status = Ex) then
                      rTotalExc := rTotalExc + rTableValue;

                   CalcFieldForm.Update;
              end;

              Next;
              Inc(lCount);

        until EOF
        or (lCount > iSiteCount);

     finally
            Close;
     end;

     if (rTotal > 0) then
     begin
          iToTarget := Round((rValue/rTotal)*100);
          iTotalExc := Round((rTotalExc/rTotal)*100);
          iPartialPC := Round((rPartial/rTotal)*100);
          iR1  := Round((rR1/rTotal)*100);
          iR2 := Round((rR2/rTotal)*100);
          iR3 := Round((rR3/rTotal)*100);
          iR4 := Round((rR4/rTotal)*100);
          iR5 := Round((rR5/rTotal)*100);
     end
     else
     begin
          iToTarget := 0;
          iTotalExc := 0;
          iPartialPC := 0;
          iR1 := 0;
          iR2 := 0;
          iR3 := 0;
          iR4 := 0;
          iR5 := 0;
     end;

     btnStart.Enabled := False;

     {populate the report box}
     RptBox.Items.Clear;
     RptBox.Items.Add('Resource ' + sFieldName + ' Report');
     RptBox.Items.Add('');
     Str(rTotal:10:1,sTmp);
     RptBox.Items.Add('Initial Available ' + sTmp);
     RptBox.Items.Add('');
     Str(rValue:10:1,sTmp);
     RptBox.Items.Add('% Remaining: ' + IntToStr(iToTarget) + '% (' + sTmp +')');
     Str(rR1:10:1,sTmp);
     RptBox.Items.Add('% '+ControlRes^.sR1Label+': ' + IntToStr(iR1) + '% (' + sTmp + ')');
     if (ControlRes^.sR2Label <> '') then
     begin
          Str(rR2:10:1,sTmp);
          RptBox.Items.Add('% '+ControlRes^.sR2Label+': ' + IntToStr(iR2) + '% (' + sTmp + ')');
     end;
     if (ControlRes^.sR3Label <> '') then
     begin
          Str(rR3:10:1,sTmp);
          RptBox.Items.Add('% '+ControlRes^.sR3Label+': ' + IntToStr(iR3) + '% (' + sTmp + ')');
     end;
     if (ControlRes^.sR4Label <> '') then
     begin
          Str(rR4:10:1,sTmp);
          RptBox.Items.Add('% '+ControlRes^.sR4Label+': ' + IntToStr(iR4) + '% (' + sTmp + ')');
     end;
     if (ControlRes^.sR5Label <> '') then
     begin
          Str(rR5:10:1,sTmp);
          RptBox.Items.Add('% '+ControlRes^.sR5Label+': ' + IntToStr(iR5) + '% (' + sTmp + ')');
     end;
     Str(rPartial:10:1,sTmp);
     RptBox.Items.Add('% Partially Selected: ' + IntToStr(iPartialPC) + '% (' + sTmp + ')');
     Str(rTotalExc:10:1,sTmp);
     RptBox.Items.Add('% Excluded: ' + IntToStr(iTotalExc) + '% (' + sTmp + ')');
     btnSaveResource.Enabled := True;

     CalcFieldForm.Update;
end;

procedure TCalcFieldForm.btnStartClick(Sender: TObject);
var
   wOldCursor : integer;
begin
     try
        wOldCursor := Screen.Cursor;
        Screen.Cursor := crHourglass;

        CalcField;

     finally
            Screen.Cursor := wOldCursor;
     end;
end;

procedure TCalcFieldForm.btnExitClick(Sender: TObject);
begin
     ModalResult := mrOK;
end;

procedure TCalcFieldForm.FormResize(Sender: TObject);
begin
     ClientWidth := (barProgress.Left*2) + barProgress.Width;
     ClientHeight := barProgress.Top + barProgress.Height +
                     barProgress.Left;
end;

procedure TCalcFieldForm.FormCreate(Sender: TObject);
begin
     FormResize(self);
end;

procedure TCalcFieldForm.btnSaveResourceClick(Sender: TObject);
begin
     SaveResourceReport.InitialDir := ControlRes^.sWorkingDirectory;
     if SaveResourceReport.Execute then
        RptBox.Items.SaveToFile(SaveResourceReport.Filename);
end;

end.

