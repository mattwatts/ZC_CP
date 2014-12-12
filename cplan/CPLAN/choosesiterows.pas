unit choosesiterows;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Spin, Buttons;

type
  TChooseSiteRowsForm = class(TForm)
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
  ChooseSiteRowsForm: TChooseSiteRowsForm;

implementation

uses
    global, control, sql_unit;

{$R *.DFM}

function rtnSiteValue(const pSite : sitepointer;
                      const sField : string) : string;
begin
     Result := '';

     if (UpperCase(sField) = 'SITEKEY') then
        Result := IntToStr(pSite^.iKey)
     else
     if (UpperCase(sField) = 'SITENAME') then
        Result := pSite^.sName
     else
     if (UpperCase(sField) = 'STATUS') then
        Result := Status2Str(pSite^.status)
     else
     if (UpperCase(sField) = 'I_STATUS') then
        case pSite^.status of
             Av,_R1,_R2,_R3,_R4,_R5,Pd,Fl,Ex : Result := 'Initial Available';
             Ig : Result := 'Initial Excluded';
             Re : Result := 'Initial Reserve';
        end
     else
     if (UpperCase(sField) = 'AREA') then
        Result := FloatToStr(pSite^.area)
     else
     if (UpperCase(sField) = 'PCCONTR') then
        Result := FloatToStr(pSite^.rPCUSED)
     else
     if (UpperCase(sField) = 'SUMIRR') then
        Result := FloatToStr(pSite^.rSummedIrr)
     else
     if (UpperCase(sField) = 'WAVIRR') then
        Result := FloatToStr(pSite^.rWAVIRR)
     else
     if (UpperCase(sField) = 'IRREPL') then
        Result := FloatToStr(pSite^.rIrreplaceability)
     else
     if (UpperCase(sField) = 'DISPLAY') then
        Result := pSite^.sDisplay;
end;

procedure TChooseSiteRowsForm.VariableBoxClick(Sender: TObject);
var
   iCount : integer;
   pSite : sitepointer;
   sValue : string;
begin
     Screen.Cursor := crHourglass;

     try
        // load values for this field into ValueBox for user to select from
        ValueBox.Items.Clear;
        ValueBox.Text := '';
        new(pSite);
        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);

             if (pSite^.status <> Re) then
             begin
                  sValue := rtnSiteValue(pSite,VariableBox.Items.Strings[VariableBox.ItemIndex]);
                  if (ValueBox.Items.IndexOf(sValue) = -1) then
                     ValueBox.Items.Add(sValue);
             end;
        end;
        dispose(pSite);
        if (ValueBox.Items.Count > 0) then
           ValueBox.Text := ValueBox.Items.Strings[0];
     except
     end;

     Screen.Cursor := crDefault;
end;

end.
