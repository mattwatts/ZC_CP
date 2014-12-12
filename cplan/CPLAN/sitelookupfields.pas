unit sitelookupfields;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls;

type
  TSelectSiteFieldsForm = class(TForm)
    Panel1: TPanel;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    AllBox: TListBox;
    Panel2: TPanel;
    SelectAll: TSpeedButton;
    SelectOne: TSpeedButton;
    deselectone: TSpeedButton;
    deselectall: TSpeedButton;
    SelectBox: TListBox;
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
  SelectSiteFieldsForm: TSelectSiteFieldsForm;

implementation

uses
    Control, global, inifiles, sql_unit;

{$R *.DFM}

procedure TSelectSiteFieldsForm.TestRemoveField(const sField : string);
var
   iIndex : integer;
begin
     // if the user selected field exists in AllBox, remove it
     iIndex := AllBox.Items.IndexOf(sField);
     if (iIndex > -1) then
        AllBox.Items.Delete(iIndex);
end;

procedure TSelectSiteFieldsForm.LoadUserSettings;
var
   iCount : integer;
   AIni : TIniFile;
begin
     // read the user settings
     AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
     AIni.ReadSection('Site Info Fields',SelectBox.Items);
     AIni.Free;
     // remove user selected fields from the master list to clean up the display
     if (SelectBox.Items.Count > 0) then
        for iCount := 0 to (SelectBox.Items.Count - 1) do
            TestRemoveField(SelectBox.Items.Strings[iCount]);
end;

procedure TSelectSiteFieldsForm.SaveUserSettings;
var
   iCount : integer;
   AIni : TIniFile;
begin
     AIni := TIniFile.Create(ControlRes^.sDatabase + '\' + INI_FILE_NAME);
     AIni.EraseSection('Site Info Fields');
     if (SelectBox.Items.Count > 0) then
        for iCount := 0 to (SelectBox.Items.Count - 1) do
            AIni.WriteString('Site Info Fields',SelectBox.Items.Strings[iCount],'');
     AIni.Free;
end;

procedure TSelectSiteFieldsForm.MoveSelected(List: TCustomListBox; Items: TStrings);
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

procedure TSelectSiteFieldsForm.MoveAll;
var
  I: Integer;
begin
     for I := 0 to AllBox.Items.Count - 1 do
         SelectBox.Items.AddObject(AllBox.Items[I], AllBox.Items.Objects[I]);
     AllBox.Items.Clear;
end;

procedure TSelectSiteFieldsForm.UnSelectAll;
begin
     InitialiseFields;
end;

function _rtnSiteValue(const pSite : sitepointer;
                       const sField : string) : string;
begin
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


function ReturnFieldValue(const iFeature : integer;
                          const sFieldName : string) : string;
var
   pSite : sitepointer;
begin
     // iFeature is a 1-based feature index into the feature array and feature table
     // sFieldName is the field requested, which can be a) feature lookup field
     //                                              or b) feature table field
     //                                              or c) feature report field
     // open the feature table before a call to this function
     // close the feature table after a call to this function
     // (allows fast database operation to retrieve required fields)
     new(pSite);
     FeatArr.rtnValue(iFeature,pSite);
     Result := _rtnSiteValue(pSite,sFieldName);
     dispose(pSite);
     //if (Result = '') then
     //begin
          // fetch the field value from the feature table
     //end;
end;

procedure TSelectSiteFieldsForm.InitialiseFields;
var
   iCount : integer;
   sName : string;
begin
     // populate AllBox with all available fields
     AllBox.Items.Clear;

     // add the default fields
     AllBox.Items.Add('SITEKEY');
     AllBox.Items.Add('SITENAME');
     AllBox.Items.Add('STATUS');
     AllBox.Items.Add('I_STATUS');
     AllBox.Items.Add('AREA');
     AllBox.Items.Add('PCCONTR');
     AllBox.Items.Add('SUMIRR');
     AllBox.Items.Add('WAVIRR');
     AllBox.Items.Add('IRREPL');
     AllBox.Items.Add('DISPLAY');

     // clear SelectBox
     SelectBox.Items.Clear;
end;

procedure TSelectSiteFieldsForm.FormCreate(Sender: TObject);
begin
     // Populate AllBox with all available fields
     InitialiseFields;

     // Populate SelectBox with all selected fields,
     // removing each of these in turn from AllBox
     // Read these from the cplan.ini file
     LoadUserSettings;
end;

procedure TSelectSiteFieldsForm.SelectOneClick(Sender: TObject);
begin
     MoveSelected(AllBox,SelectBox.Items);
end;

procedure TSelectSiteFieldsForm.deselectoneClick(Sender: TObject);
begin
     MoveSelected(SelectBox,AllBox.Items);
end;

procedure TSelectSiteFieldsForm.SelectAllClick(Sender: TObject);
begin
     MoveAll;
end;

procedure TSelectSiteFieldsForm.deselectallClick(Sender: TObject);
begin
     UnSelectAll;
end;

procedure TSelectSiteFieldsForm.btnOkClick(Sender: TObject);
begin
     SaveUserSettings;
end;

end.
