unit ChooseFeatureRows;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TChooseFeatureRowsForm = class(TForm)
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    checkSortValues: TCheckBox;
    checkLoadValues: TCheckBox;
    OperatorGroup: TRadioGroup;
    VariableBox: TListBox;
    Label1: TLabel;
    Label3: TLabel;
    ValueBox: TComboBox;
    procedure VariableBoxClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ChooseFeatureRowsForm: TChooseFeatureRowsForm;

implementation

uses
    global, control;

{$R *.DFM}

function rtnFeatureValue(const pFeat : featureoccurrencepointer;
                         const sField : string) : string;
begin
     Result := '';
     if (sField = 'FEATKEY') then
        Result := IntToStr(pFeat^.code)
     else
     if (sField = 'FEATNAME') then
        Result := pFeat^.sID
     else
     if (sField = 'IN USE') then
        Result := bool2string(not pFeat^.fRestrict)
     else
     if (sField = 'SUBSET') then
        Result := IntToStr(pFeat^.iOrdinalClass)
     else
     if (sField = 'SRADIUS') then
        Result := FloatToStr(pFeat^.rSRADIUS)
     else
     if (sField = 'PATCHCON') then
        Result := FloatToStr(pFeat^.rPATCHCON)
     else
     if (sField = 'VULN') then
        Result := FloatToStr(pFeat^.rVulnerability)
     else
     if (sField = 'EXTANT') then
        Result := FloatToStr(pFeat^.rExtantArea)
     else
     if (sField = 'NEGOTIATED')
     or (sField = ControlRes^.sR1Label) then
        Result := FloatToStr(pFeat^.rR1)
     else
     if (sField = 'MANDATORY')
     or (sField = ControlRes^.sR2Label) then
        Result := FloatToStr(pFeat^.rR2)
     else
     if (sField = ControlRes^.sR3Label) then
        Result := FloatToStr(pFeat^.rR3)
     else
     if (sField = ControlRes^.sR4Label) then
        Result := FloatToStr(pFeat^.rR4)
     else
     if (sField = ControlRes^.sR5Label) then
        Result := FloatToStr(pFeat^.rR5)
     else
     if (sField = 'PARTIAL') then
        Result := FloatToStr(pFeat^.rPartial)
     else
     if (sField = 'CURRENT TARGET') then
        Result := FloatToStr(pFeat^.targetarea)
     else
     if (sField = '% ORIGINAL EFFECTIVE TARGET') then
        Result := FloatToStr(pFeat^.rCurrentEffTarg)
     else
     if (sField = 'ITARGET') then
        Result := FloatToStr(pFeat^.rCutOff)
     else
     if (sField = 'AVAILABLE') then
        Result := FloatToStr(pFeat^.rSumArea)
     else
     if (sField = 'EXCLUDED') then
        Result := FloatToStr(pFeat^.rExcluded)
     else
     if (sField = 'INITIAL TRIMMED TARGET') then
        Result := FloatToStr(pFeat^.rInitialTrimmedTarget)
     else
     if (sField = 'TRIMMED TARGET') then
        Result := FloatToStr(pFeat^.rTrimmedTarget)
     else
     if (sField = 'INITIAL AVAILABLE') then
        Result := FloatToStr(pFeat^.rInitialAvailable)
     else
     if (sField = 'INITIAL AVAILABLE TARGET') then
        Result := FloatToStr(pFeat^.rInitialAvailableTarget)
     else
     if (sField = 'DEFERRED') then
        Result := FloatToStr(pFeat^.rDeferredArea)
     else
     if (sField = 'TOTAL') then
        Result := FloatToStr(pFeat^.totalarea)
     else
     if (sField = 'INITIAL RESERVED') then
        Result := FloatToStr(pFeat^.reservedarea)
     else
     if (sField = 'TOTAL RESERVED') then
        Result := FloatToStr(pFeat^.reservedarea + pFeat^.rDeferredArea)
     else
     if (sField = 'EXCLUDE TRIM') then
     begin
          if (pFeat^.rTrimmedArea > 0) then
             Result := 'YES'
          else
              Result := '';
     end
     else
     if (sField = 'EXCLUDE TRIM AMOUNT') then
        Result := FloatToStr(pFeat^.rTrimmedArea)
     else
     if (sField = 'EXCLUDE TRIM %') then
     begin
          if ((pFeat^.rInitialTrimmedTarget-pFeat^.reservedarea) > 0) then
             Result := FloatToStr(pFeat^.rTrimmedArea/(pFeat^.rInitialTrimmedTarget-pFeat^.reservedarea)*100)
          else
              Result := '0';
     end;
end;

procedure TChooseFeatureRowsForm.VariableBoxClick(Sender: TObject);
var
   iCount : integer;
   pFeat : featureoccurrencepointer;
   sValue : string;
begin
     Screen.Cursor := crHourglass;

     try
        // load values for this field into ValueBox for user to select from
        ValueBox.Items.Clear;
        ValueBox.Text := '';
        new(pFeat);
        for iCount := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iCount,pFeat);

             sValue := rtnFeatureValue(pFeat,VariableBox.Items.Strings[VariableBox.ItemIndex]);
             if (ValueBox.Items.IndexOf(sValue) = -1) then
                ValueBox.Items.Add(sValue);
        end;
        dispose(pFeat);
        if (ValueBox.Items.Count > 0) then
           ValueBox.Text := ValueBox.Items.Strings[0];
     except
     end;

     Screen.Cursor := crDefault;
end;

end.
