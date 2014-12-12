unit featlookupfields;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons;

type
  TSelectFieldsForm = class(TForm)
    Panel1: TPanel;
    AllBox: TListBox;
    Splitter1: TSplitter;
    SelectBox: TListBox;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    Panel2: TPanel;
    SelectAll: TSpeedButton;
    SelectOne: TSpeedButton;
    deselectone: TSpeedButton;
    deselectall: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure InitialiseFields;
    procedure MoveSelected(List: TCustomListBox; Items: TStrings);
    procedure MoveAll;
    procedure UnSelectAll;
    procedure TestRemoveField(const sField : string);
    procedure LoadUserSettings;
    procedure SaveUserSettings;
    procedure SelectOneClick(Sender: TObject);
    procedure deselectoneClick(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure deselectallClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  SelectFieldsForm: TSelectFieldsForm;

implementation

uses Control, global, inifiles;

{$R *.DFM}

procedure TSelectFieldsForm.TestRemoveField(const sField : string);
var
   iIndex : integer;
begin
     // if the user selected field exists in AllBox, remove it
     iIndex := AllBox.Items.IndexOf(sField);
     if (iIndex > -1) then
        AllBox.Items.Delete(iIndex);
end;

procedure TSelectFieldsForm.LoadUserSettings;
var
   iCount : integer;
   AIni : TIniFile;
begin
     // read the user settings
     AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
     AIni.ReadSection('Feature Info Fields',SelectBox.Items);
     AIni.Free;
     // remove user selected fields from the master list to clean up the display
     if (SelectBox.Items.Count > 0) then
        for iCount := 0 to (SelectBox.Items.Count - 1) do
            TestRemoveField(SelectBox.Items.Strings[iCount]);
end;

procedure TSelectFieldsForm.SaveUserSettings;
var
   iCount : integer;
   AIni : TIniFile;
begin
     AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
     AIni.EraseSection('Feature Info Fields');
     if (SelectBox.Items.Count > 0) then
        for iCount := 0 to (SelectBox.Items.Count - 1) do
            AIni.WriteString('Feature Info Fields',SelectBox.Items.Strings[iCount],'');
     AIni.Free;
end;

procedure TSelectFieldsForm.MoveSelected(List: TCustomListBox; Items: TStrings);
var
  I: Integer;
begin
     for I := 0 to List.Items.Count - 1 do
       if List.Selected[I] then
          Items.AddObject(List.Items[I], List.Items.Objects[I]);

     for I := List.Items.Count - 1 downto 0 do
       if List.Selected[I] then
          List.Items.Delete(I);
end;

procedure TSelectFieldsForm.MoveAll;
var
  I: Integer;
begin
     for I := 0 to AllBox.Items.Count - 1 do
         SelectBox.Items.AddObject(AllBox.Items[I], AllBox.Items.Objects[I]);
     AllBox.Items.Clear;
end;

procedure TSelectFieldsForm.UnSelectAll;
begin
     InitialiseFields;
end;

function _rtnFeatureValue(const pFeat : featureoccurrencepointer;
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
          if ((pFeat^.rInitialTrimmedTarget) > 0) then
             Result := FloatToStr(pFeat^.rTrimmedArea/(pFeat^.rInitialTrimmedTarget)*100)
          else
              Result := '0';
     end;
end;


function ReturnFieldValue(const iFeature : integer;
                          const sFieldName : string) : string;
var
   pFeat : featureoccurrencepointer;
begin
     // iFeature is a 1-based feature index into the feature array and feature table
     // sFieldName is the field requested, which can be a) feature lookup field
     //                                              or b) feature table field
     //                                              or c) feature report field
     // open the feature table before a call to this function
     // close the feature table after a call to this function
     // (allows fast database operation to retrieve required fields)
     new(pFeat);
     FeatArr.rtnValue(iFeature,pFeat);
     Result := _rtnFeatureValue(pFeat,sFieldName);
     dispose(pFeat);
     //if (Result = '') then
     //begin
          // fetch the field value from the feature table
     //end;
end;

procedure TSelectFieldsForm.InitialiseFields;
var
   iCount : integer;
   sName : string;
begin
     // populate AllBox with all available fields
     AllBox.Items.Clear;

     // add the default fields
     AllBox.Items.Add('FEATKEY');
     AllBox.Items.Add('FEATNAME');
     AllBox.Items.Add('IN USE');
     AllBox.Items.Add('SUBSET');
     AllBox.Items.Add('SRADIUS');
     AllBox.Items.Add('PATCHCON');
     AllBox.Items.Add('VULN');
     AllBox.Items.Add('EXTANT');
     AllBox.Items.Add(ControlRes^.sR1Label);
     AllBox.Items.Add(ControlRes^.sR2Label);
     AllBox.Items.Add(ControlRes^.sR3Label);
     AllBox.Items.Add(ControlRes^.sR4Label);
     AllBox.Items.Add(ControlRes^.sR5Label);
     AllBox.Items.Add('PARTIAL');
     AllBox.Items.Add('CURRENT TARGET');
     AllBox.Items.Add('% ORIGINAL EFFECTIVE TARGET');
     AllBox.Items.Add('ITARGET');
     AllBox.Items.Add('AVAILABLE');
     AllBox.Items.Add('EXCLUDED');
     AllBox.Items.Add('INITIAL TRIMMED TARGET');
     AllBox.Items.Add('TRIMMED TARGET');
     AllBox.Items.Add('INITIAL AVAILABLE');
     AllBox.Items.Add('INITIAL AVAILABLE TARGET');
     AllBox.Items.Add('DEFERRED');
     AllBox.Items.Add('TOTAL');
     AllBox.Items.Add('INITIAL RESERVED');
     AllBox.Items.Add('TOTAL RESERVED');
     AllBox.Items.Add('EXCLUDE TRIM');
     AllBox.Items.Add('EXCLUDE TRIM AMOUNT');
     AllBox.Items.Add('EXCLUDE TRIM %');

     // clear SelectBox
     SelectBox.Items.Clear;
end;

procedure TSelectFieldsForm.FormCreate(Sender: TObject);
begin
     // Populate AllBox with all available fields
     InitialiseFields;

     // Populate SelectBox with all selected fields,
     // removing each of these in turn from AllBox
     // Read these from the cplan.ini file
     LoadUserSettings;
end;

procedure TSelectFieldsForm.SelectOneClick(Sender: TObject);
begin
     MoveSelected(AllBox,SelectBox.Items);
end;

procedure TSelectFieldsForm.deselectoneClick(Sender: TObject);
begin
     MoveSelected(SelectBox,AllBox.Items);
end;

procedure TSelectFieldsForm.SelectAllClick(Sender: TObject);
begin
     MoveAll;
end;

procedure TSelectFieldsForm.deselectallClick(Sender: TObject);
begin
     UnSelectAll;
end;

procedure TSelectFieldsForm.btnOkClick(Sender: TObject);
begin
     SaveUserSettings;
end;

end.
