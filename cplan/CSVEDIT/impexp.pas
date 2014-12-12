unit impexp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Buttons, StdCtrls, Db, DBTables, Spin, Gauges, ComCtrls,
  Childwin, tparse;

type
  TImportMatrixForm = class(TForm)
    Notebook1: TNotebook;
    Label1: TLabel;
    btnNext: TButton;
    BitBtn1: TBitBtn;
    Label2: TLabel;
    MtxTblBox: TListBox;
    AreaBox: TListBox;
    Label3: TLabel;
    Label4: TLabel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    TenureBox: TListBox;
    Label5: TLabel;
    Label6: TLabel;
    OrigTenure: TListBox;
    AvailTenure: TListBox;
    ResTenure: TListBox;
    IgnTenure: TListBox;
    Label7: TLabel;
    Button10: TButton;
    Label8: TLabel;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    BitBtn10: TBitBtn;
    EditMult: TEdit;
    ComboFrom: TComboBox;
    ComboTo: TComboBox;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    SelHighlightTbl: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    UnSelHighlightTbl: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Label9: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Button15: TButton;
    Label17: TLabel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Label18: TLabel;
    Label19: TLabel;
    BitBtn11: TBitBtn;
    Button1: TButton;
    Label20: TLabel;
    Label21: TLabel;
    BitBtn12: TBitBtn;
    TableQuery: TQuery;
    Button20: TButton;
    Label22: TLabel;
    Label23: TLabel;
    TargetBox: TListBox;
    Label24: TLabel;
    ComboBox3: TComboBox;
    Button21: TButton;
    Button22: TButton;
    BitBtn13: TBitBtn;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    ComboBox4: TComboBox;
    Label28: TLabel;
    ComboBox5: TComboBox;
    Button23: TButton;
    Button24: TButton;
    BitBtn14: TBitBtn;
    combomult: TEdit;
    Button25: TButton;
    BitBtn15: TBitBtn;
    Label29: TLabel;
    Label30: TLabel;
    Edit2: TEdit;
    Label31: TLabel;
    Edit1: TEdit;
    Button26: TButton;
    SaveData: TSaveDialog;
    PopulateTable: TTable;
    Label32: TLabel;
    Label33: TLabel;
    Edit3: TEdit;
    Label34: TLabel;
    ComboBox6: TComboBox;
    Label35: TLabel;
    ComboBox7: TComboBox;
    Button27: TButton;
    Button28: TButton;
    BitBtn16: TBitBtn;
    Label36: TLabel;
    Label37: TLabel;
    Button29: TButton;
    Button30: TButton;
    BitBtn17: TBitBtn;
    Label38: TLabel;
    Label39: TLabel;
    SpinEdit1: TSpinEdit;
    Label40: TLabel;
    Label41: TLabel;
    Button31: TButton;
    BitBtn18: TBitBtn;
    NameTableBox: TListBox;
    Label43: TLabel;
    ComboBox8: TComboBox;
    Button32: TButton;
    Gauge1: TGauge;
    LabelProgress: TLabel;
    btnBrowse: TButton;
    Button33: TButton;
    Button34: TButton;
    Button35: TButton;
    Button36: TButton;
    Label45: TLabel;
    Label46: TLabel;
    Label47: TLabel;
    ExtantBox: TListBox;
    Label16: TLabel;
    ExtantCombo: TComboBox;
    Label42: TLabel;
    Label44: TLabel;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    BitBtn5: TBitBtn;
    Label48: TLabel;
    Label49: TLabel;
    EditExtantConv: TEdit;
    Label50: TLabel;
    ExtantFromConv: TComboBox;
    Label51: TLabel;
    ExtantToConv: TComboBox;
    Button8: TButton;
    Button9: TButton;
    BitBtn6: TBitBtn;
    Label52: TLabel;
    Label53: TLabel;
    VulnerabilityBox: TListBox;
    Label54: TLabel;
    ComboVuln: TComboBox;
    Button16: TButton;
    Button17: TButton;
    Button18: TButton;
    BitBtn7: TBitBtn;
    btnSaveSpec: TButton;
    btnLoadSpec: TButton;
    procedure btnNextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MtxTblBoxClick(Sender: TObject);
    procedure EditMultChange(Sender: TObject);
    procedure ComboFromChange(Sender: TObject);
    procedure ComboToChange(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn10Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    function IsTenureSelected : boolean;
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SelHighlightTblClick(Sender: TObject);
    procedure UnSelHighlightTblClick(Sender: TObject);
    procedure AreaBoxClick(Sender: TObject);
    procedure TenureBoxClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
    procedure ExecuteImportSequence;
    procedure ParseLoadTenure(const sFilename, sTenureField : string;
                              TenureBox : TListBox);
    procedure Button15Click(Sender: TObject);
    procedure CreateEmptyTables(const sDatabasePath, sDatabaseName : string;
                                const fAddIRR_SUM_WAVfields : boolean);
    procedure TargetBoxClick(Sender: TObject);
    procedure combomultChange(Sender: TObject);
    procedure Button26Click(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure Button24Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure ComboBox4Change(Sender: TObject);
    procedure InitPathName;
    procedure PopulateSST;
    function PopulateFST : integer;
    procedure WriteINISettings(const iMatrixSize : integer);
    procedure WriteGlobalINISettings(const sOutPath,{output database path}
                                           sDBName {database name} : string);
    procedure ComboBox6Change(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure NameTableBoxClick(Sender: TObject);
    procedure ProgressStart(const sLabel : string);
    procedure ProgressUpdate(const iUpdate : integer);
    procedure ProgressStop;
    procedure btnBrowseClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure EditExtantConvChange(Sender: TObject);
    procedure ExtantFromConvChange(Sender: TObject);
    procedure ExtantBoxClick(Sender: TObject);
    procedure OrigTenureClick(Sender: TObject);
    procedure AvailTenureClick(Sender: TObject);
    procedure ResTenureClick(Sender: TObject);
    procedure IgnTenureClick(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure VulnerabilityBoxClick(Sender: TObject);
    procedure btnSaveSpecClick(Sender: TObject);
    procedure btnLoadSpecClick(Sender: TObject);
    procedure LoadWizardSpecification(const sSpecFile : string);
    procedure SaveWizardSpecification(const sSpecFile : string);
  private
    { Private declarations }
    function BrowseTable : boolean;
  public
    { Public declarations }
  end;

procedure CheckDisposeParser(aChild : TMDIChild;
                             aParser : TTableParser);


function rtnConversionChange(FromBox, ToBox : TComboBox;
                             Mult : TEdit) : extended;

procedure MoveSelect(Source,Dest : TListbox);
function rtnUniqueFileName(const sPath, sExt : string) : string;


var
  ImportMatrixForm: TImportMatrixForm;
  iAreaField : integer;
  ProgressLastUpdate, Tenth_Of_a_Sec : TDateTime;

implementation

uses
    MAIN, Join,
    FileCtrl, IniFiles,
    global, ds, xdata, userkey, loadtype,
    browsed;

{$R *.DFM}

{
This is the structure of a Wizard Specification file which details the complete set
of specifications that the Wizard requires in order to build a C-Plan database.

BEGIN C-Plan Database Wizard Specification File
DATE
TIME

MatrixTable=
Key=
Type=Link/Load
ConvertFactor=
From=
To=

NameTable=
Key=
Type=
Name=

PCCONTRCutOff=

AreaTable=
Key=
Type=
Area=
ConvertFactor=
From=
To=

TenureTable=
Key=
Type=
Tenure=
InitialAvailable=3
a
b
c
InitialReserved=2
d
e
InitialExcluded=4
f
g
h
i

TargetTable=
Key=
Type=
Target=
ConvertFactor=
From=
To=

ExtantTable=
Key=
Type=
Extant=
ConvertFactor=
From=
To=

VulnerabilityTable=
Key=
Type=
Vulnerability=

OutputPath=

DatabaseName=

END
}


function rtnUniqueFileName(const sPath, sExt : string) : string;
var
   iCount : integer;
begin
     // return a unique path\autosaveX.ext filename
     iCount := 0;

     repeat
           Result := sPath + '\autosave' + IntToStr(iCount) + '.' + sExt;

           Inc(iCount);

     until not FileExists(Result);
end;

function SaveMatrixTable(const AFile : TextFile) : boolean;
var
   sChild : string;
begin
     with ImportMatrixForm do
     begin
          sChild := MtxTblBox.Items.Strings[MtxTblBox.ItemIndex];
          writeln(AFile,'[Matrix]');
          writeln(AFile,'Table=' + sChild);
          writeln(AFile,'Key=' + SCPForm.rtnChildKey(sChild));
          writeln(AFile,'Type=' + SCPForm.rtnChildType(sChild));
          writeln(AFile,'ConvertFactor=' + Edit3.Text);
          writeln(AFile,'From=' + ComboBox6.Text);
          writeln(AFile,'To=' + ComboBox7.Text);
     end;
end;

function SaveNameTable(const AFile : TextFile) : boolean;
var
   sChild : string;
begin
     with ImportMatrixForm do
     begin
          writeln(AFile,'[Name]');
          if (ComboBox8.Text = '') then
          begin
               writeln(AFile,'Table=');
               writeln(AFile,'Key=');
               writeln(AFile,'Type=');
               writeln(AFile,'Name=');
          end
          else
          begin
               sChild := NameTableBox.Items.Strings[NameTableBox.ItemIndex];
               writeln(AFile,'Table=' + sChild);
               writeln(AFile,'Key=' + SCPForm.rtnChildKey(sChild));
               writeln(AFile,'Type=' + SCPForm.rtnChildType(sChild));
               writeln(AFile,'Name=' + ComboBox8.Text);
          end;
     end;
end;

function SaveAreaTable(const AFile : TextFile) : boolean;
var
   sChild : string;
begin
     with ImportMatrixForm do
     begin
          writeln(AFile,'[Area]');
          if (ComboBox1.Text = '') then
          begin
               writeln(AFile,'Table=');
               writeln(AFile,'Key=');
               writeln(AFile,'Type=');
               writeln(AFile,'Area=');
               writeln(AFile,'ConvertFactor=');
               writeln(AFile,'From=');
               writeln(AFile,'To=');
          end
          else
          begin
               sChild := AreaBox.Items.Strings[AreaBox.ItemIndex];
               writeln(AFile,'Table=' + sChild);
               writeln(AFile,'Key=' + SCPForm.rtnChildKey(sChild));
               writeln(AFile,'Type=' + SCPForm.rtnChildType(sChild));
               writeln(AFile,'Area=' + ComboBox1.Text);
               writeln(AFile,'ConvertFactor=' + EditMult.Text);
               writeln(AFile,'From=' + ComboFrom.Text);
               writeln(AFile,'To=' + ComboTo.Text);
          end;
     end;
end;

function SaveTenureTable(const AFile : TextFile) : boolean;
var
   sChild : string;
   iCount : integer;
begin
     with ImportMatrixForm do
     begin
          writeln(AFile,'[Tenure]');
          if (ComboBox2.Text = '')
          or (OrigTenure.Items.Count <> 0) then
          begin
               writeln(AFile,'Table=');
               writeln(AFile,'Key=');
               writeln(AFile,'Type=');
               writeln(AFile,'Tenure=');
               writeln(AFile,'InitialAvailable=');
               writeln(AFile,'InitialReserved=');
               writeln(AFile,'InitialExcluded=');
          end
          else
          begin
               sChild := TenureBox.Items.Strings[TenureBox.ItemIndex];
               writeln(AFile,'Table=' + sChild);
               writeln(AFile,'Key=' + SCPForm.rtnChildKey(sChild));
               writeln(AFile,'Type=' + SCPForm.rtnChildType(sChild));
               writeln(AFile,'Tenure=' + ComboBox2.Text);
               writeln(AFile,'InitialAvailable=' + IntToStr(AvailTenure.Items.Count));
               if (AvailTenure.Items.Count > 0) then
                  for iCount := 0 to (AvailTenure.Items.Count-1) do
                      writeln(AFile,AvailTenure.Items.Strings[iCount]);
               writeln(AFile,'InitialReserved=' + IntToStr(ResTenure.Items.Count));
               if (ResTenure.Items.Count > 0) then
                  for iCount := 0 to (ResTenure.Items.Count-1) do
                      writeln(AFile,ResTenure.Items.Strings[iCount]);
               writeln(AFile,'InitialExcluded=' + IntToStr(IgnTenure.Items.Count));
               if (IgnTenure.Items.Count > 0) then
                  for iCount := 0 to (IgnTenure.Items.Count-1) do
                      writeln(AFile,IgnTenure.Items.Strings[iCount]);
          end;
     end;
end;

function SaveTargetTable(const AFile : TextFile) : boolean;
var
   sChild : string;
begin
     with ImportMatrixForm do
     begin
          writeln(AFile,'[Target]');
          if (ComboBox3.Text = '') then
          begin
               writeln(AFile,'Table=');
               writeln(AFile,'Key=');
               writeln(AFile,'Type=');
               writeln(AFile,'Target=');
               writeln(AFile,'ConvertFactor=');
               writeln(AFile,'From=');
               writeln(AFile,'To=');
          end
          else
          begin
               sChild := TargetBox.Items.Strings[TargetBox.ItemIndex];
               writeln(AFile,'Table=' + sChild);
               writeln(AFile,'Key=' + SCPForm.rtnChildKey(sChild));
               writeln(AFile,'Type=' + SCPForm.rtnChildType(sChild));
               writeln(AFile,'Target=' + ComboBox3.Text);
               writeln(AFile,'ConvertFactor=' + combomult.Text);
               writeln(AFile,'From=' + ComboBox4.Text);
               writeln(AFile,'To=' + ComboBox5.Text);
          end;
     end;
end;

function SaveExtantTable(const AFile : TextFile) : boolean;
var
   sChild : string;
begin
     with ImportMatrixForm do
     begin
          writeln(AFile,'[Extant]');
          if (ExtantCombo.Text = '') then
          begin
               writeln(AFile,'Table=');
               writeln(AFile,'Key=');
               writeln(AFile,'Type=');
               writeln(AFile,'Extant=');
               writeln(AFile,'ConvertFactor=');
               writeln(AFile,'From=');
               writeln(AFile,'To=');
          end
          else
          begin
               sChild := ExtantBox.Items.Strings[ExtantBox.ItemIndex];
               writeln(AFile,'Table=' + sChild);
               writeln(AFile,'Key=' + SCPForm.rtnChildKey(sChild));
               writeln(AFile,'Type=' + SCPForm.rtnChildType(sChild));
               writeln(AFile,'Extant=' + ExtantCombo.Text);
               writeln(AFile,'ConvertFactor=' + EditExtantConv.Text);
               writeln(AFile,'From=' + ExtantFromConv.Text);
               writeln(AFile,'To=' + ExtantToConv.Text);
          end;
     end;
end;

function SaveVulnerabilityTable(const AFile : TextFile) : boolean;
var
   sChild : string;
begin
     with ImportMatrixForm do
     begin
          writeln(AFile,'[Vulnerability]');
          if (ComboVuln.Text = '') then
          begin
               writeln(AFile,'Table=');
               writeln(AFile,'Key=');
               writeln(AFile,'Type=');
               writeln(AFile,'Vulnerability=');
          end
          else
          begin
               sChild := VulnerabilityBox.Items.Strings[VulnerabilityBox.ItemIndex];
               writeln(AFile,'Table=' + sChild);
               writeln(AFile,'Key=' + SCPForm.rtnChildKey(sChild));
               writeln(AFile,'Type=' + SCPForm.rtnChildType(sChild));
               writeln(AFile,'Vulnerability=' + ComboVuln.Text);
          end;
     end;
end;


//////////////////////////////////////////////////////////////


procedure TImportMatrixForm.LoadWizardSpecification(const sSpecFile : string);
var
   InFile : TextFile;
begin
     try
        {}
        assignfile(InFile,sSpecFile);
        reset(InFile);

        // read each of the settings from the file in turn
        //LoadMatrixTable(InFile);

        //LoadNameTable(InFile);

        closefile(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TImportMatrixForm.LoadWizardSpecification',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;



procedure TImportMatrixForm.SaveWizardSpecification(const sSpecFile : string);
var
   OutFile : TextFile;
begin
     try
        {}
        assignfile(OutFile,sSpecFile);
        rewrite(OutFile);

        // write wizard spec header
        writeln(OutFile,'[C-Plan Database Wizard Specification File]');
        writeln(OutFile,'Date=' + FormatDateTime('dddd," "mmmm d, yyyy',Now));
        writeln(OutFile,'Time=' + FormatDateTime('hh:mm AM/PM', Now));
        writeln(OutFile,'OutputPath=' + Edit2.Text);
        writeln(OutFile,'DatabaseName=' + Edit1.Text);
        writeln(OutFile,'CPlanVersion=');
        writeln(OutFile,'');

        // write matrix settings
        SaveMatrixTable(OutFile);
        writeln(OutFile,'PCCONTRCutOff=' + IntToStr(SpinEdit1.Value));
        writeln(OutFile,'');

        // write name settings
        SaveNameTable(OutFile);
        writeln(OutFile,'');

        // write area settings
        SaveAreaTable(OutFile);
        writeln(OutFile,'');

        // write tenure settings
        SaveTenureTable(OutFile);
        writeln(OutFile,'');

        // write target settings
        SaveTargetTable(OutFile);
        writeln(OutFile,'');

        // write extant settings
        SaveExtantTable(OutFile);
        writeln(OutFile,'');

        // write vulnerability settings
        SaveVulnerabilityTable(OutFile);
        //writeln(OutFile,'');

        closefile(OutFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TImportMatrixForm.SaveWizardSpecification',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function TImportMatrixForm.BrowseTable : boolean;
var
   wResult : word;
   TablesAdded : Array_t;
   sStr : str255;

   procedure AddTables;
   var
      iCount : integer;
      AChild : TMDIChild;
   begin
        Result := True;

        for iCount := 1 to TablesAdded.lMaxSize do
        begin
             TablesAdded.rtnValue(iCount,@sStr);
             MtxTblBox.Items.Add(sStr);
             NameTableBox.Items.Add(sStr);
             AreaBox.Items.Add(sStr);
             TenureBox.Items.Add(sStr);
             TargetBox.Items.Add(sStr);
             ExtantBox.Items.Add(sStr);
             VulnerabilityBox.Items.Add(sStr);
             {get user to select key field for this table}
             AChild := SCPForm.rtnChild(sStr);
             SelectKeyForm := TSelectKeyForm.Create(Application);
             SelectKeyForm.initChild(sStr);
             SelectKeyForm.ShowModal;
             SelectKeyForm.Free;
        end;
   end;
begin
     {}
     try
        Result := False;

        LoadTypeForm := TLoadTypeForm.Create(Application);
        if (LoadTypeForm.ShowModal = mrOk) then
        begin
             if LoadTypeForm.RadioButtonLink.Checked then
             begin
                  {search and link a file}
                  TablesAdded := SCPForm.LinkQuery;
                  if (TablesAdded.lMaxSize > 0) then
                     {add these tables to our table selection list(s)}
                     AddTables;
                  TablesAdded.Destroy;
             end
             else
             begin
                  {search and load a file}
                  TablesAdded := SCPForm.LoadQuery;
                  if (TablesAdded.lMaxSize > 0) then
                     {add these tables to our table selection list(s)}
                     AddTables;
                  TablesAdded.Destroy;
             end;
        end;

        LoadTypeForm.Free;


        (*wResult := MessageDlg('Do you want to link the table instead of loading it to the grid',
                              mtConfirmation,
                              [mbYes,mbNo,mbCancel],
                              0);

        case wResult of
             mrYes :
             begin
                  {search and link a file}
                  TablesAdded := SCPForm.LinkQuery;
                  if (TablesAdded.lMaxSize > 0) then
                     {add these tables to our table selection list(s)}
                     AddTables;
                  TablesAdded.Destroy;
             end;
             mrNo :
             begin
                  {search and load a file}
                  TablesAdded := SCPForm.LoadQuery;
                  if (TablesAdded.lMaxSize > 0) then
                     {add these tables to our table selection list(s)}
                     AddTables;
                  TablesAdded.Destroy;
             end;
        end;*)

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TImportMatrixForm.BrowseTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TImportMatrixForm.ProgressStart(const sLabel : string);
begin
     {}
     Notebook1.PageIndex := Notebook1.Pages.Count - 1;

     LabelProgress.Caption := sLabel;

     {ProgressBar1.Visible := True;}
     Gauge1.Visible := True;

     ProgressLastUpdate := Time;
     Tenth_Of_a_Sec := StrToTime('0:0:1')/10;

     Refresh; {refresh the form}
end;

procedure TImportMatrixForm.ProgressUpdate(const iUpdate : integer);
var
   iBreak : integer;
begin
     {}
     if (Time > (ProgressLastUpdate+Tenth_Of_a_Sec))
     and (iUpdate > Gauge1.Progress) then
     begin
          if (iUpdate >= 73) then
          begin
               iBreak := iUpdate;
               //iUpdate := iBreak;
          end;
          ProgressLastUpdate := Time;
          {ProgressBar1.Position := iUpdate;}
          Gauge1.Progress := iUpdate;

          Refresh;
     end;
end;

procedure TImportMatrixForm.ProgressStop;
begin
     {}
     LabelProgress.Caption := '';

     {ProgressBar1.Visible := False;}
     Gauge1.Visible := False;

     Refresh;
end;



procedure TImportMatrixForm.CreateEmptyTables(const sDatabasePath, sDatabaseName : string;
                                              const fAddIRR_SUM_WAVfields : boolean);
var
   iCount : integer;
begin
     {create the site summary table}
     with TableQuery.Sql do
     begin
          Clear;
          Add('CREATE TABLE "' + sDatabasePath + '\sites_' + sDatabaseName + '.dbf"');
          Add('(');
          Add('NAME CHAR(120),');        // 32
          Add(DATABASE_KEY_FIELD + ' NUMERIC(12,0),');
          Add('STATUS CHAR(2),');
          Add('I_STATUS CHAR(17),');
          Add('TENURE CHAR(32),');
          Add('AREA NUMERIC(10,5),');
          Add('IRREPL NUMERIC(10,5),');
          Add('I_IRREPL NUMERIC(10,5),');
          Add('SUMIRR NUMERIC(10,5),');
          Add('I_SUMIRR NUMERIC(10,5),');
          Add('WAVIRR NUMERIC(10,5),');
          Add('I_WAVIRR NUMERIC(10,5),');
          Add('PCCONTR NUMERIC(10,5),');
          Add('I_PCCONTR NUMERIC(10,5),');
          Add('DISPLAY CHAR(3))');
          {Add('PREVDISP CHAR(3)');}
          {if fAddIRR_SUM_WAVfields then
          begin
               Add(',');
               for iCount := 1 to 10 do
                   Add('IRR' + IntToStr(iCount) + ' NUMERIC(10,5),');
               for iCount := 1 to 10 do
                   Add('SUM' + IntToStr(iCount) + ' NUMERIC(10,5),');
               for iCount := 1 to 5 do
                   Add('WAV' + IntToStr(iCount) + ' NUMERIC(10,5),');
          end;}
          {TableQuery.Sql.Add(')');}
     end;

     try
        TableQuery.Prepare;
        TableQuery.ExecSQL;
     except
           MessageDlg('Exception executing SQL query to create site dBase table',mtInformation,[mbOk],0);
           Application.Terminate;
           Exit;
     end;

     {create the feature summary table}
     with TableQuery.Sql do
     begin
          Clear;
          Add('CREATE TABLE "' + sDatabasePath + '\features_' + sDatabaseName + '.dbf"');
          Add('(');
          Add('FEATKEY NUMERIC(6,0),');
          Add('FEATNAME CHAR(254),');
          Add('ITARGET NUMERIC(12,2)');
          if (ExtantCombo.Text <> '') then {EXTANT has been specified by the user}
             Add(',EXTANT NUMERIC(12,2)');
          if (ComboVuln.Text <> '') then {VULNERABILITY has been specified by the user}
             Add(',VULN NUMERIC(12,2)');
          Add(')');
     end;

     try
        TableQuery.Prepare;
        TableQuery.ExecSQL;
     except
           TableQuery.SQL.SaveToFile('c:\fst.sql');
           Screen.Cursor := crDefault;
           MessageDlg('Exception executing SQL query to create feature dBase table',mtInformation,[mbOk],0);
           Application.Terminate;
           Exit;
     end;

end;

procedure GetChild(aBox : TListBox;
                   var aChild : TMDIChild;
                   var aParser : TTableParser);
var
   iChildId : integer;
begin
     iChildId := SCPForm.rtnTableId(aBox.Items.Strings[aBox.ItemIndex]);

     aChild := TMDIChild(SCPForm.MDIChildren[iChildId]);
     if not aChild.CheckLoadFileData.Checked then
     begin
          {data is to be read from a file using a TTableParser
           initialise aParser so we can read from it}
          aParser := TTableParser.Create(Application);
          aParser.initfile(aChild.Caption);
     end;
end;

procedure GetBinarySearchArr(aChild : TMDIChild;
                             aParser : TTableParser;
                             var SearchArr : Array_T;
                             var fKeyIsInteger : boolean;
                             const sDataStructure : string);
var
   KeyArr : Array_t;
   iKey, iKeyArrCount, iCount : integer;
   sKey : str255;

   AType : FieldDataType_T;

   procedure AddToKeyArr(const iK : integer);
   begin
        Inc(iKeyArrCount);
        if (iKeyArrCount > KeyArr.lMaxSize) then
           KeyArr.Resize(KeyArr.lMaxSize + ARR_STEP_SIZE);
        KeyArr.setValue(iKeyArrCount,@iK);
   end;

   procedure AddToKeyStrArr(const sK : str255);
   begin
        Inc(iKeyArrCount);
        if (iKeyArrCount > KeyArr.lMaxSize) then
           KeyArr.Resize(KeyArr.lMaxSize + ARR_STEP_SIZE);
        KeyArr.setValue(iKeyArrCount,@sK);
   end;

begin
     try
        {assumes GetChild has already been called with aChild and aParser

         creates : binary search array for looking up rows within the file
                   by specifying a row key}

        {determine whether Key field is integer, else string is used}
        aChild.DataFieldTypes.rtnValue(aChild.KeyFieldGroup.ItemIndex + 1,@AType);

        iKeyArrCount := 0;
        KeyArr := Array_t.create;

        if (AType.DBDataType = DBaseInt) then
        begin
             fKeyIsInteger := True;
             KeyArr.init(SizeOf(integer),ARR_STEP_SIZE);
        end
        else
        begin
             fKeyIsInteger := False;
             KeyArr.init(SizeOf(sKey),ARR_STEP_SIZE);
        end;


        try
           if aChild.CheckLoadFileData.Checked then
           begin
                {data is loaded into aChild.aGrid}
                for iCount := 1 to (aChild.aGrid.RowCount - 1) do
                begin
                     if fKeyIsInteger then
                     begin
                          iKey := StrToInt(aChild.aGrid.Cells[aChild.KeyFieldGroup.ItemIndex,iCount]);
                          AddToKeyArr(iKey); {load all the row keys into KeyArr}
                     end
                     else
                     begin
                          sKey := aChild.aGrid.Cells[aChild.KeyFieldGroup.ItemIndex,iCount];
                          AddToKeyStrArr(sKey); {load all the row keys into KeyArr}
                     end;
                end;
           end
           else
           begin
                {data must be read from file using aParser}

                // switch off optimise column access to speed up reading key field only
		aParser.fOptimiseColumnAccess := False;

                iCount := 1;
                aParser.seekfile(iCount);
                repeat
                      if fKeyIsInteger then
                      begin
                           iKey := StrToInt(aParser.rtnRowValue(aChild.KeyFieldGroup.ItemIndex));
                           AddToKeyArr(iKey); {load all the row keys into KeyArr}
                      end
                      else
                      begin
                           sKey := aParser.rtnRowValue(aChild.KeyFieldGroup.ItemIndex);
                           AddToKeyStrArr(sKey); {load all the row keys into KeyArr}
                      end;
                      Inc(iCount);

                until (not aParser.seekfile(iCount));

		// switch on optimise column access to speed up reading many fields
		aParser.fOptimiseColumnAccess := True;
           end;

        except
              on EConvertError do
              begin
                   Screen.Cursor := crDefault;
                   MessageDlg('Exception in GetBinarySearchArr, key in table ' + aChild.Caption +
                              ' is not an integer',mtError,[mbOk],0);
                   Application.Terminate;
                   Exit;
                   iKeyArrCount := -1;
              end;
        end;

        if (iKeyArrCount > 0) then
        begin
             if (iKeyArrCount <> KeyArr.lMaxSize) then
                KeyArr.resize(iKeyArrCount);

             if fKeyIsInteger then
             begin
                  SearchArr := SortIntegerArray(KeyArr); {convert KeyArr to SearchArr}
                  TestUniqueIntArray(SearchArr,sDataStructure);
             end
             else
             begin
                  SearchArr := SortStrArray(KeyArr); {convert KeyArr to SearchArr};
                  TestUniqueStrArray(SearchArr,sDataStructure);
             end;
        end
        else
        if (iKeyArrCount <> -1) then
        begin
             {error - there are no keys}
             Screen.Cursor := crDefault;

             MessageDlg('Exception in GetBinarySearchArr, no keys in table ' + aChild.Caption,
                        mtError,[mbOk],0);
             Application.Terminate;
             Exit;
        end;

        KeyArr.Destroy;

     except
           MessageDlg('Exception in GetBinarySearchArr',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure CheckDisposeParser(aChild : TMDIChild;
                             aParser : TTableParser);
begin
     if not aChild.CheckLoadFileData.Checked then
     begin
          {we must dispose of the aParser which has been used to table data}
          aParser.donefile;
          aParser.Free;
     end;
end;

procedure TestColumnsAreUnique(aChild : TMDIChild);
var
   ColumnIds, ColumnSearchArr : Array_T;
   sId : str255;
   iIdCount, iCount : integer;
begin
     {}
     if (aChild.aGrid.ColCount > 1) then
     try
        ColumnIds := Array_T.Create;
        ColumnIds.init(sizeof(sId),ARR_STEP_SIZE);
        iIdCount := 0;

        for iCount := 0 to (aChild.aGrid.ColCount - 1) do
            if (iCount <> aChild.KeyFieldGroup.ItemIndex) then
            begin
                 sId := aChild.aGrid.Cells[iCount,0];
                 inc(iIdCount);
                 if (iIdCount > ColumnIds.lMaxSize) then
                    ColumnIds.resize(ColumnIds.lMaxSize + ARR_STEP_SIZE);
                 ColumnIds.setValue(iIdCount,@sId);
            end;

        if (iIdCount <> ColumnIds.lMaxSize) then
           ColumnIds.resize(iIdCount);

        ColumnSearchArr := SortStrArray(ColumnIds);

        {test if ColumnSearchArr has replicated keys}
        TestUniqueColumnArray(ColumnSearchArr,
                              aChild.Caption);

        ColumnIds.Destroy;
        ColumnSearchArr.Destroy;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TestColumnsAreUnique ' + aChild.Caption,
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TImportMatrixForm.PopulateSST;
var
   sSSTableName : string;
   fFail : boolean;
   MatrixChild, NameChild, AreaChild, TenureChild : TMDIChild;
   MatrixParser, NameParser, AreaParser, TenureParser : TTableParser;
   MatrixSearchArr, AreaSearchArr, NameSearchArr, TenureSearchArr : Array_T;
   iAreaColumn, iNameColumn, iTenureColumn, iInitCount,
   iBuffPos, iBytesWritten, iFeatureMatrixRow, iSeekRow,
   iFeatureIndex, iRichness : integer;
   sMatrixKey, sTenureValue : string;
   rMtxConvert, rAreaConvert, rValue : real;
   fMatrixKeyIsInteger,
   fNameKeyIsInteger,
   fAreaKeyIsInteger,
   fTenureKeyIsInteger : boolean;

   {variables for output MTX & KEY files}
   OutputMatrix,OutputKey : file;
   Key : KeyFile_T;
   Value : SingleValueFile_T;
   fDontWrite : boolean;

   {test if we have reached the end of the feature matrix table}
   function FeatureMatrixTableEnd : boolean;
   begin
        Result := False;

        if MatrixChild.CheckLoadFileData.Checked then
        begin
             {the matrix data is already loaded in a grid}
             if (iFeatureMatrixRow >= MatrixChild.AGrid.RowCount) then
                Result := True;
        end
        else
            Result := not MatrixParser.seekfile(iFeatureMatrixRow);
   end;

   function rtnTenureString(const sOriginalValue : string) : string;
   var
      iCount : integer;
   begin
        Result := 'Available';
        {determine which list (Available, Reserved, Ignored) sOriginalValue is contained in}
        if (AvailTenure.Items.Count > 0) then
           for iCount := 0 to (AvailTenure.Items.Count - 1) do
               if (AvailTenure.Items.Strings[iCount] = sOriginalValue) then
                  Result := 'Initial Available';

        if (ResTenure.Items.Count > 0) then
           for iCount := 0 to (ResTenure.Items.Count - 1) do
               if (ResTenure.Items.Strings[iCount] = sOriginalValue) then
                  Result := 'Initial Reserve';

        if (IgnTenure.Items.Count > 0) then
           for iCount := 0 to (IgnTenure.Items.Count - 1) do
               if (IgnTenure.Items.Strings[iCount] = sOriginalValue) then
                  Result := 'Initial Excluded';
        {return string name 'Available','Reserved' or 'Ignored' of the tenure}
   end;


begin
     {populate site summary table with NAME, KEY, AREA, TENURE
      and populate matrix file with feature matrix data}

     sSSTableName := Edit2.Text + '\sites_' + Edit1.Text + '.dbf';

     PopulateTable.DatabaseName := Edit2.Text;
     PopulateTable.TableName := 'sites_' + Edit1.Text + '.dbf';

     try
        ProgressStart('Populate Site Table and Site by Feature Matrix');

        {open PopulateTable}
        fFail := False;
        try PopulateTable.Open;
        except {cannot open PopulateTable}
              fFail := True;
        end;

        if not fFail then
        begin
             {PopulateTable is ready to receive data}

             {get the Feature Matrix child}
             GetChild(MtxTblBox,MatrixChild,MatrixParser);
             {binary search array is created for testing uniqueness in the matrix key field only}
             GetBinarySearchArr(MatrixChild,MatrixParser,MatrixSearchArr,fMatrixKeyIsInteger,MatrixChild.Caption);
             MatrixSearchArr.Destroy;
             {test that the list of features in the table is unique}
             TestColumnsAreUnique(MatrixChild);

             {initialise output MAT table so we can write to it}
             iBuffPos := 0;
             assignfile(OutputMatrix,Edit2.Text + '\matrix_' + Edit1.Text + '.mtx');
             assignfile(OutputKey,Edit2.Text + '\matrix_' + Edit1.Text + '.key');
             rewrite(OutputMatrix,1);
             rewrite(OutputKey,1);

             {if importing NAME init NAME objects}
             if (ComboBox8.Text <> '') then
             begin
                  GetChild(NameTableBox,NameChild,NameParser) {user has chosen a Name field};
                  GetBinarySearchArr(NameChild,NameParser,NameSearchArr,fNameKeyIsInteger,NameChild.Caption);
                  iNameColumn := NameChild.rtnColumnIndex(ComboBox8.Text);
             end;

             {if importing AREA initialise AREA table so we can read from it}
             if (ComboBox1.Text <> '') then
             begin
                  GetChild(AreaBox,AreaChild,AreaParser) {user has chosen an AREA field};
                  GetBinarySearchArr(AreaChild,AreaParser,AreaSearchArr,fAreaKeyIsInteger,AreaChild.Caption);
                  iAreaColumn := AreaChild.rtnColumnIndex(ComboBox1.Text);
                  if (EditMult.Text = '') then
                     rAreaConvert := 0
                  else
                      rAreaConvert := StrToFloat(EditMult.Text);
             end;

             {if importing TENURE initialise TENURE table so we can read from it}
             if (ComboBox2.Text <> '') then
             begin
                  GetChild(TenureBox,TenureChild,TenureParser);
                  GetBinarySearchArr(TenureChild,TenureParser,TenureSearchArr,fTenureKeyIsInteger,TenureChild.Caption);
                  iTenureColumn := TenureChild.rtnColumnIndex(ComboBox2.Text);
             end;

             {initialise row counter}
             iFeatureMatrixRow := 1;
             if (Edit3.Text = '') then
                rMtxConvert := 0
             else
                 rMtxConvert := StrToFloat(Edit3.Text);

             {seek to first row of matrix file if necessary}
             if not MatrixChild.CheckLoadFileData.Checked then
                MatrixParser.seekfile(iFeatureMatrixRow);

             {now iterate through each row in the matrix table}
             repeat
                   {create a new row at the end (or beginning if there are no records yet) of the Site Summary Table}
                   PopulateTable.Append;

                   {write key field from Feature Matrix table to SITEKEY}
                   if MatrixChild.CheckLoadFileData.Checked then
                      sMatrixKey := MatrixChild.aGrid.Cells[MatrixChild.KeyFieldGroup.ItemIndex,
                                                            iFeatureMatrixRow]
                   else
                       sMatrixKey := MatrixParser.rtnRowValue(MatrixChild.KeyFieldGroup.ItemIndex);
                   PopulateTable.FieldByName(DATABASE_KEY_FIELD).AsString := sMatrixKey;

                   Key.iSiteKey := StrToInt(sMatrixKey);
                   iFeatureIndex := 0;
                   iRichness := 0;

                   for iInitCount := 0 to (MatrixChild.aGrid.ColCount - 1) do
                   begin
                        {write Feature Matrix values for sMatrixKey to MAT file}
                        fDontWrite := False;

                        {these lines need to be modified for handling 'drifting' key
                         fields, ie. not only column 0 or 1}
                        if (iInitCount = MatrixChild.KeyFieldGroup.ItemIndex) then
                           fDontWrite := True;

                        if (not fDontWrite) then
                        begin
                             Inc(iFeatureIndex);

                             if MatrixChild.CheckLoadFileData.Checked then
                             begin
                                  if (MatrixChild.aGrid.Cells[iInitCount,iFeatureMatrixRow] = '') then
                                     rValue := 0
                                  else
                                      rValue := StrToFloat(MatrixChild.aGrid.Cells[iInitCount,iFeatureMatrixRow]);
                             end
                             else
                                 rValue := StrToFloat(MatrixParser.rtnRowValue(iInitCount));

                             {convert matrix value if necessary}
                             if (rValue > 0) then
                             begin
                                  Inc(iRichness);
                                  if (rMtxConvert <> 0) then
                                     rValue := rValue * rMtxConvert;

                                  Value.iFeatKey := iFeatureIndex;
                                  Value.rAmount := rValue;
                                  BlockWrite(OutputMatrix,Value,SizeOf(Value));
                             end;

                        end;
                   end;
                   Key.iRichness := iRichness;
                   BlockWrite(OutputKey,Key,SizeOf(Key));

                   {if importing NAME}
                   if (ComboBox8.Text <> '') then
                   begin
                        {seek in NAME table to row with key = GEOCODE}
                        if fNameKeyIsInteger then
                           iSeekRow := findIntegerMatch(NameSearchArr,StrToInt(sMatrixKey))
                        else
                            iSeekRow := findStrMatch(NameSearchArr,sMatrixKey);

                        if NameChild.CheckLoadFileData.Checked then
                        begin
                             try
                                PopulateTable.FieldByName('NAME').AsString := NameChild.aGrid.Cells[iNameColumn,iSeekRow]
                             except
                                   Screen.Cursor := crDefault;
                                   MessageDlg('Exception reading cell [ column ' + IntToStr(iAreaColumn) +
                                              ' row ' + IntToStr(iSeekRow) + ' ] of key ' + sMatrixKey +
                                              ' of table ' + TenureChild.Caption,
                                              mtError,[mbOk],0);
                                   Application.Terminate;
                                   Exit;
                             end;
                        end
                        else
                        begin
                             NameParser.seekfile(iSeekRow);
                             PopulateTable.FieldByName('NAME').AsString := NameParser.rtnRowValue(iNameColumn);
                        end;
                        {write NAME value from NAME table to NAME}
                   end
                   else
                       PopulateTable.FieldByName('NAME').AsString := sMatrixKey;

                   {if importing AREA}
                   if (ComboBox1.Text <> '') then
                   begin
                        {seek in AREA table to row with key = GEOCODE}
                        if fAreaKeyIsInteger then
                           iSeekRow := findIntegerMatch(AreaSearchArr,StrToInt(sMatrixKey))
                        else
                            iSeekRow := findStrMatch(AreaSearchArr,sMatrixKey);

                        if AreaChild.CheckLoadFileData.Checked then
                        begin
                             try
                                rValue := StrToFloat(AreaChild.aGrid.Cells[iAreaColumn,iSeekRow]);
                             except
                                   Screen.Cursor := crDefault;
                                   MessageDlg('Exception converting cell [ column ' + IntToStr(iAreaColumn) +
                                              ' row ' + IntToStr(iSeekRow) + ' ] of key ' + sMatrixKey +
                                              ' of table ' + TenureChild.Caption,
                                              mtError,[mbOk],0);
                                   Application.Terminate;
                                   Exit;
                             end;
                        end
                        else
                        begin
                             AreaParser.seekfile(iSeekRow);
                             rValue := StrToFloat(AreaParser.rtnRowValue(iAreaColumn));
                        end;
                        {check if we have to convert AREA}
                        if (rAreaConvert <> 0) then
                           rValue := rValue * rAreaConvert;
                        {write AREA value from AREA table to AREA}
                        PopulateTable.FieldByName('AREA').AsFloat := rValue;
                   end;

                   {if importing TENURE TenureBox.ItemIndex contains selection unit TENURE field
                                       ComboBox2.Text is field name of TENURE field}
                   if (ComboBox2.Text <> '') then
                   begin
                        {seek in TENURE table to row with key = GEOCODE}
                        if fTenureKeyIsInteger then
                           iSeekRow := findIntegerMatch(TenureSearchArr,StrToInt(sMatrixKey))
                        else
                            iSeekRow := findStrMatch(TenureSearchArr,sMatrixKey);

                        if TenureChild.CheckLoadFileData.Checked then
                        begin
                             try
                                sTenureValue := TenureChild.aGrid.Cells[iTenureColumn,iSeekRow];
                             except
                                   Screen.Cursor := crDefault;
                                   MessageDlg('Exception reading cell [ column ' + IntToStr(iTenureColumn) +
                                              ' row ' + IntToStr(iSeekRow) + ' ] of key ' + sMatrixKey +
                                              ' of table ' + TenureChild.Caption,
                                              mtError,[mbOk],0);
                                   Application.Terminate;
                                   Exit;
                             end;
                        end
                        else
                        begin
                             TenureParser.seekfile(iSeekRow);
                             sTenureValue := TenureParser.rtnRowValue(iTenureColumn);
                        end;
                        {determine which list (Available, Reserved, Ignored) TENURE value is contained in}
                        {write value 'Available','Reserved' or 'Ignored' to I_STATUS and tenure to TENURE}
                        PopulateTable.FieldByName('TENURE').AsString := sTenureValue;
                        PopulateTable.FieldByName('I_STATUS').AsString := rtnTenureString(sTenureValue);
                   end
                   else
                       {write 'Available' to I_STATUS}
                       PopulateTable.FieldByName('I_STATUS').AsString := 'Initial Available';

                   ProgressUpdate(Round(
                                        (iFeatureMatrixRow/(MatrixChild.SpinRow.Value-1))*100
                                       )
                                  );

                   Inc(iFeatureMatrixRow);

             until FeatureMatrixTableEnd;

             CheckDisposeParser(MatrixChild,MatrixParser); {check if MatrixParser was used}

             if (ComboBox8.Text <> '') then {check if Name objects used}
             begin
                  CheckDisposeParser(NameChild,NameParser);
                  NameSearchArr.Destroy;
             end;

             if (ComboBox1.Text <> '') then  {check if AreaParser was used}
             begin
                  CheckDisposeParser(AreaChild,AreaParser);
                  AreaSearchArr.Destroy;
             end;

             if (ComboBox2.Text <> '') then {check in TenureParser was used}
             begin
                  CheckDisposeParser(TenureChild,TenureParser);
                  TenureSearchArr.Destroy;
             end;

             closefile(OutputMatrix);
             closefile(OutputKey);

             PopulateTable.Post;
             PopulateTable.Close; {close the PopulateTable (Site Summary Table)}

             ProgressStop;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception populating site dBase table and site X feature matrix.' +
                      chr(10) + chr(13) +
                      'There may be a problem with the input table(s).',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function TImportMatrixForm.PopulateFST : integer;
var
   sFeatureToFind, sCellValue, sFSTableName : string;
   VulnChild, ExtantChild, MatrixChild, TargetChild : TMDIChild;
   VulnParser, ExtantParser, TargetParser : TTableParser;
   VulnSearchArr, ExtantSearchArr, TargetSearchArr : Array_T;
   iRowContainingFeature,
   iFe, iChildId, iFeature, iVulnColumn, iExtantColumn, iTargetColumn, iTotalFeatures : integer;
   rValue, rTargetConvert, rExtantConvert : real;
   fVulnKeyIsInteger, fExtantKeyIsInteger, fTargetKeyIsInteger, fStop : boolean;

   function EndOfFeaturesReached : boolean;
   begin
        if (iFeature > iTotalFeatures) then
           Result := True
        else
            Result := False;
   end;

begin
     try
        ProgressStart('Populate Feature Table');

        {populate feature summary table with NAME, CODE, ITARGET, EXTANT}
        sFSTableName := Edit2.Text + '\features_' + Edit1.Text + '.dbf';
        PopulateTable.DatabaseName := Edit2.Text;
        PopulateTable.TableName := 'features_' + Edit1.Text + '.dbf';
        PopulateTable.Open;
        {matrix table contains feature NAME's
         target table contains feature TARGET
         (set target to 0 if TARGET table/field not specified)}

        {initialise matrix child}
        iChildId := SCPForm.rtnTableId(MtxTblBox.Items.Strings[MtxTblBox.ItemIndex]);
        MatrixChild := TMDIChild(SCPForm.MDIChildren[iChildId]);

        iFeature := 0;

        if (ComboBox3.Text <> '') then
        begin
             {TARGET field selected, initialise Target objects}
             GetChild(TargetBox,TargetChild,TargetParser);
             GetBinarySearchArr(TargetChild,TargetParser,TargetSearchArr,fTargetKeyIsInteger,TargetChild.Caption);
             iTargetColumn := TargetChild.rtnColumnIndex(ComboBox3.Text);
             if (combomult.Text = '') then
                rTargetConvert := 1
             else
                 rTargetConvert := StrToFloat(combomult.Text);

             {if not TargetChild.CheckLoadFileData.Checked then
                TargetParser.seekfile(iFeature + 1);}
        end;

        if (ExtantCombo.Text <> '') then
        begin
             GetChild(ExtantBox,ExtantChild,ExtantParser);
             GetBinarySearchArr(ExtantChild,ExtantParser,ExtantSearchArr,fExtantKeyIsInteger,ExtantChild.Caption);
             iExtantColumn := ExtantChild.rtnColumnIndex(ExtantCombo.Text);
             if (EditExtantConv.Text = '') then
                rExtantConvert := 1
             else
                 rExtantConvert := StrToFloat(EditExtantConv.Text);
        end;

        if (ComboVuln.Text <> '') then
        begin
             GetChild(VulnerabilityBox,VulnChild,VulnParser);
             GetBinarySearchArr(VulnChild,VulnParser,VulnSearchArr,fVulnKeyIsInteger,VulnChild.Caption);
             iVulnColumn := VulnChild.rtnColumnIndex(ComboVuln.Text);
        end;

        iTotalFeatures := MatrixChild.SpinCol.Value - 1;

        iFe := 0;
        repeat
              Inc(iFeature);
              if (iFeature <> (MatrixChild.KeyFieldGroup.ItemIndex + 1)) then
              begin
                   Inc(iFe);
                   PopulateTable.Append;
                   PopulateTable.FieldByName('FEATKEY').AsInteger := iFe;
                   sFeatureToFind := MatrixChild.aGrid.Cells[iFeature-1,0];
                   PopulateTable.FieldByName('FEATNAME').AsString := sFeatureToFind;

                   fStop := False;

                   if (ComboBox3.Text = '') then
                      rValue := 0
                   else
                   begin
                        {we are reading a value from the Target file, we must get the key for this feature
                         and use it to look up the row from the Target file containing this key}

                        if fTargetKeyIsInteger then
                           iRowContainingFeature := FindIntegerMatch(TargetSearchArr,StrToInt(sFeatureToFind))
                        else
                            iRowContainingFeature := FindStrMatch(TargetSearchArr,sFeatureToFind);

                        if (iRowContainingFeature > TargetChild.SpinRow.Value) then
                           fStop := True;

                        if not fStop then
                        begin
                             if (iRowContainingFeature > 0)
                             {and (iRowContainingFeature < TargetChild.SpinRow.Value)} then
                             begin
                                  if TargetChild.CheckLoadFileData.Checked then
                                     try
                                        sCellValue := TargetChild.aGrid.Cells[iTargetColumn,iRowContainingFeature{-1}];
                                        rValue := StrToFloat(sCellValue);
                                     except
                                           Screen.Cursor := crDefault;
                                           MessageDlg('Exception converting target cell >' + sCellValue + '< to floating point number, ' +
                                                      'column ' + IntToStr(iTargetColumn) +
                                                      ' row ' + IntToStr(iRowContainingFeature{-1}),
                                                      mtError,[mbOk],0);
                                           Application.Terminate;
                                           Exit;
                                     end
                                  else
                                  begin
                                       {seek to row iRowContainingFeature}
                                       TargetParser.seekfile(iRowContainingFeature{-1});
                                       try
                                          sCellValue := TargetParser.rtnRowValue(iTargetColumn);
                                          rValue := StrToFloat(sCellValue);
                                       except
                                             Screen.Cursor := crDefault;
                                             MessageDlg('Exception converting target cell >' + sCellValue + '< to floating point number, ' +
                                                        'column ' + IntToStr(iTargetColumn) +
                                                        ' row ' + IntToStr(iRowContainingFeature{-1}),
                                                        mtError,[mbOk],0);
                                             Application.Terminate;
                                             Exit;
                                       end;
                                  end;
                             end
                             else
                                 rValue := 0;
                        end;
                   end;

                   if not fStop then
                   begin
                        rValue := rValue * rTargetConvert;
                        PopulateTable.FieldByName('ITARGET').AsFloat := rValue;
                   end;

                   if (ExtantCombo.Text <> '') then
                   begin
                        if fExtantKeyIsInteger then
                           iRowContainingFeature := FindIntegerMatch(ExtantSearchArr,StrToInt(sFeatureToFind))
                        else
                            iRowContainingFeature := FindStrMatch(ExtantSearchArr,sFeatureToFind);

                        if (iRowContainingFeature > 0)
                        and (iRowContainingFeature <= ExtantChild.SpinRow.Value) then
                        begin
                             if ExtantChild.CheckLoadFileData.Checked then
                                rValue := StrToFloat(ExtantChild.aGrid.Cells[iExtantColumn,iRowContainingFeature])
                             else
                             begin
                                  ExtantParser.seekfile(iRowContainingFeature);
                                  rValue := StrToFloat(ExtantParser.rtnRowValue(iExtantColumn));
                             end;

                             PopulateTable.FieldByName('EXTANT').AsFloat := rValue;
                        end;
                   end;

                   if (ComboVuln.Text <> '') then
                   begin
                        if fVulnKeyIsInteger then
                           iRowContainingFeature := FindIntegerMatch(VulnSearchArr,StrToInt(sFeatureToFind))
                        else
                            iRowContainingFeature := FindStrMatch(VulnSearchArr,sFeatureToFind);

                        if (iRowContainingFeature > 0)
                        and (iRowContainingFeature <= VulnChild.SpinRow.Value) then
                        begin
                             if VulnChild.CheckLoadFileData.Checked then
                                rValue := StrToFloat(VulnChild.aGrid.Cells[iVulnColumn,iRowContainingFeature])
                             else
                             begin
                                  VulnParser.seekfile(iRowContainingFeature);
                                  rValue := StrToFloat(VulnParser.rtnRowValue(iVulnColumn));
                             end;

                             PopulateTable.FieldByName('VULN').AsFloat := rValue;
                        end;
                   end;

                   ProgressUpdate(Round(
                                        100*(iFeature/iTotalFeatures)
                                       ));
              end;

        until EndOfFeaturesReached;

        if (ComboBox3.Text <> '') then
        begin
             {dispose of Target objects}
             CheckDisposeParser(TargetChild,TargetParser);
             TargetSearchArr.Destroy;
        end;

        if (ExtantCombo.Text <> '') then
        begin
             CheckDisposeParser(ExtantChild,ExtantParser);
             ExtantSearchArr.Destroy;
        end;

        if (ComboVuln.Text <> '') then
        begin
             CheckDisposeParser(VulnChild,VulnParser);
             VulnSearchArr.Destroy;
        end;

        PopulateTable.Post;
        PopulateTable.Close;

        Result := iFeature;

        ProgressStop;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception populating feature dBase table.' +
                      chr(10) + chr(13) +
                      'There may be a problem with the input table(s).',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TImportMatrixForm.WriteINISettings(const iMatrixSize : integer);
var
   AIniFile : TIniFile;
   sSection : string;
begin
     {}
     try
        AIniFile := TIniFile.Create(Edit2.Text + '\cplan.ini');

        AIniFile.WriteString('Database1','Name',Edit1.Text);
        AIniFile.WriteInteger('Database1','PCCONTRCutOff',SpinEdit1.Value);
        AIniFile.WriteInteger('Database1','MatrixSize',iMatrixSize-1);
        AIniFile.WriteString('Database1','FeatureSummaryTable','features_' + Edit1.Text + '.dbf');

        AIniFile.WriteString('Options','SparseMatrix','matrix_' + Edit1.Text + '.mtx');
        AIniFile.WriteString('Options','SparseKey','matrix_' + Edit1.Text + '.key');


        // add a default 'Resource' section
        AIniFile.WriteString('Resource',';AREA','');

        AIniFile.WriteString('Display Fields','NAME','');
        AIniFile.WriteString('Display Fields','STATUS','');
        AIniFile.WriteString('Display Fields',DATABASE_KEY_FIELD,'');
        AIniFile.WriteString('Display Fields','PCUSED','');
        AIniFile.WriteString('Display Fields','IRREPL','');
        AIniFile.WriteString('Display Fields','TENURE','');

        AIniFile.WriteString('Options','SiteSummaryTable','sites_' + Edit1.Text + '.dbf');
        AIniFile.WriteString('Options','Key',DATABASE_KEY_FIELD);
        AIniFile.WriteString('Options','LinkToGIS','ArcView');

        AIniFile.WriteString('Sumirr Weightings','Area','0');
        AIniFile.WriteString('Sumirr Weightings','Target','0');
        AIniFile.WriteString('Sumirr Weightings','Vulnerability','0');
        AIniFile.WriteString('Sumirr Weightings','Minimum Weight','0.2');
        AIniFile.WriteString('Sumirr Weightings','CalculateAllVariations','1');

        AIniFile.WriteString('Sumirr Vulnerability Weightings','1','1');
        AIniFile.WriteString('Sumirr Vulnerability Weightings','2','0.8');
        AIniFile.WriteString('Sumirr Vulnerability Weightings','3','0.6');
        AIniFile.WriteString('Sumirr Vulnerability Weightings','4','0.4');
        AIniFile.WriteString('Sumirr Vulnerability Weightings','5','0.2');

        {add CRA Feature Report specifications to INI file}
        sSection := 'Feature Report % Targets Met';
        AIniFile.WriteString(sSection,'NAME','Feature Name');
        AIniFile.WriteString(sSection,'KEY','Feature Key');
        AIniFile.WriteString(sSection,'INUSE','Feature In Use');
        AIniFile.WriteString(sSection,'ITARGET','Original Tgt.');
        AIniFile.WriteString(sSection,'TRIMMEDITARG','Initial Achievable Tgt.');
        AIniFile.WriteString(sSection,'ORIGEFFTARG','Initial Available Tgt.');
        AIniFile.WriteString(sSection,'%ITARGMET','% Original Tgt. Met');
        AIniFile.WriteString(sSection,'%TRIMITMET','% Initial Achievable Tgt. Met');
        AIniFile.WriteString(sSection,'%OETMET','% Initial Available Tgt. Met');
        AIniFile.WriteString(sSection,'CURREFFTARG','Current Available Tgt.');
        AIniFile.WriteString(sSection,'PROPOSEDRES','Reserved in C-Plan');
        AIniFile.WriteString(sSection,'EXCLUDED','Excluded in C-Plan');
        AIniFile.WriteString(sSection,'CURRAVAIL','Available in C-Plan');

        AIniFile.WriteString('Feature Reports','% Targets Met','% Targets Met');

        {add Site Report Specifications to INI file}
        sSection := 'Site Report Subset Irr';
        AIniFile.WriteString(sSection,'NAME','Site Name');
        AIniFile.WriteString(sSection,'KEY','Site Key');
        AIniFile.WriteString(sSection,'STATUS','Status');
        AIniFile.WriteString(sSection,'IRR1','Site Irr Subset 1');
        AIniFile.WriteString(sSection,'SUM1','Summed Irr Subset 1');
        AIniFile.WriteString(sSection,'IRR2','Site Irr Subset 2');
        AIniFile.WriteString(sSection,'SUM2','Summed Irr Subset 2');
        AIniFile.WriteString(sSection,'IRR3','Site Irr Subset 3');
        AIniFile.WriteString(sSection,'SUM3','Summed Irr Subset 3');
        AIniFile.WriteString(sSection,'IRR4','Site Irr Subset 4');
        AIniFile.WriteString(sSection,'SUM4','Summed Irr Subset 4');
        AIniFile.WriteString(sSection,'IRR5','Site Irr Subset 5');
        AIniFile.WriteString(sSection,'SUM5','Summed Irr Subset 5');
        AIniFile.WriteString(sSection,'IRR6','Site Irr Subset 6');
        AIniFile.WriteString(sSection,'SUM6','Summed Irr Subset 6');
        AIniFile.WriteString(sSection,'IRR7','Site Irr Subset 7');
        AIniFile.WriteString(sSection,'SUM7','Summed Irr Subset 7');
        AIniFile.WriteString(sSection,'IRR8','Site Irr Subset 8');
        AIniFile.WriteString(sSection,'SUM8','Summed Irr Subset 8');
        AIniFile.WriteString(sSection,'IRR9','Site Irr Subset 9');
        AIniFile.WriteString(sSection,'SUM9','Summed Irr Subset 9');
        AIniFile.WriteString(sSection,'IRR10','Site Irr Subset 10');
        AIniFile.WriteString(sSection,'SUM10','Summed Irr Subset 10');

        AIniFile.WriteString('Site Reports','Subset Irr','Subset Irr');

        AIniFile.Free;

        {
        [Sumirr Weightings]
        Area=0
        Target=0
        Vulnerability=0
        Minimum Weight=0.2
        CalculateAllVariations=1

        [Vulnerability]
        1=1
        2=0.8
        3=0.6
        4=0.4
        5=0.2

        [Site Reports]
        SUBSET_IRR=SUBSET_IRR

        [Feature Reports]
        % Targets Met=% Targets Met

        [Site Report SUBSET_IRR]
        NAME=Site Name
        KEY=Site Key
        STATUS=Status
        IRR1=SITE_IRR_SS1
        SUM1=SUMIRR_SS1
        IRR2=SITE_IRR_SS2
        SUM2=SUMIRR_SS2
        IRR3=SITE_IRR_SS3
        SUM3=SUMIRR_SS3
        IRR4=SITE_IRR_SS4
        SUM4=SUMIRR_SS4
        IRR5=SITE_IRR_SS5
        SUM5=SUMIRR_SS5
        IRR6=SITE_IRR_SS6
        SUM6=SUMIRR_SS6
        IRR7=SITE_IRR_SS7
        SUM7=SUMIRR_SS7
        IRR8=SITE_IRR_SS8
        SUM8=SUMIRR_SS8
        IRR9=SITE_IRR_SS9
        SUM9=SUMIRR_SS9
        IRR10=SITE_IRR_SS10
        SUM10=SUMIRR_SS10

        [Feature Report % Targets Met]
        KEY=Feature Key
        NAME=Feature Name
        INUSE=Feature In Use
        ITARGET=Original Tgt.
        TRIMMEDITARG=Initial Achievable Tgt.
        ORIGEFFTARG=Initial Available Tgt.
        %ITARGMET=% Original Tgt. Met
        %TRIMITMET=% Initial Achievable Tgt. Met
        %OETMET=% Initial Available Tgt. Met
        CURREFFTARG=Current Available Tgt.
        PROPOSEDRES=Reserved in C-Plan
        EXCLUDED=Excluded in C-Plan
        CURRAVAIL=Available in C-Plan
        }

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in WriteINISettings.' +
                      chr(10) + chr(13) +
                      'There may be a problem with the input table(s).',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TImportMatrixForm.WriteGlobalINISettings(const sOutPath,{output database path}
                                                         sDBName {database name} : string);
var
   AIniFile : TIniFile;
begin
     {}
     try
        AIniFile := TIniFile.Create('cplandb.ini');

        AIniFile.WriteString('Databases',sDBName,sOutPath);

        AIniFile.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in WriteGlobalINISettings.' +
                      chr(10) + chr(13) +
                      'There may be a problem with the input table(s).',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TImportMatrixForm.ExecuteImportSequence;
var
   iFeatures : integer;
begin
     {import the data with the specified parameters}

     {
     1. MtxTblBox.Items.Strings(MtxTblBox.ItemIndex) is feature matrix table

     2. AreaBox.ItemIndex contains selection unit AREA field
     ComboBox1.Text is field name of AREA field in the AreaBox table
     2a. EditMult.Text is conversion factor for AREA field
       (blank means no conversion)

     2b. TenureBox.ItemIndex contains selection unit TENURE field
     ComboBox2.Text is field name of TENURE field

     2c. if (OrigTenure.Items.Count = 0) then
            AvailTenure classes of Available Tenure
            ResTenure   Reserved
            IgnTenure   Ignored
         else
             tenure not specified on 2c

     choose output path and database name
     }

     {
     TASK : create :
                   site summary table     DBF
                     populate with NAME, GEOCODE, AREA and TENURE if specified
                   feature summary table  DBF
                     populate with TARGET, EXTANT, VULN
                   site by feature matrix MAT
     }

     try
        {create output database path if it does not exist}
        ForceDirectories(Edit2.Text);

        //SaveWizardSpecification(Edit2.Text + '\autosave.cws');
        SaveWizardSpecification(rtnUniqueFileName(Edit2.Text,'cws'));

        {create empty site summary table and feature summary table}
        CreateEmptyTables(Edit2.Text, {output database path}
                          Edit1.Text, {database name}
                          FALSE       {add IRR1..10,SUM1..10 and WAV1..5}
                          );

        {populate site summary table with KEY, AREA, TENURE
         also populate MAT file with feature matrix data}
        PopulateSST;

        {populate feature summary table with NAME, CODE, ITARGET}
        iFeatures := PopulateFST;

        {create INI file with appropriate settings on the output database path}
        WriteINISettings(iFeatures);

        {add a setting for this database to the global cplandb.ini ?!}
        WriteGlobalINISettings(Edit2.Text, {output database path}
                               Edit1.Text  {database name}
                               );

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ExecuteImportSequence.' +
                      chr(10) + chr(13) +
                      'There may be a problem with the input table(s).',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


procedure MoveSelect(Source,Dest : TListbox);
var
   iCount : integer;
begin
     {move selected items from Source to Dest}
     try
        Screen.Cursor := crHourglass;
        {copy the items from 1st to last}
        if (Source.Items.Count > 0) then
        begin
             for iCount := 0 to (Source.Items.Count - 1) do
                 if Source.Selected[iCount] then
                    Dest.Items.Add(Source.Items.Strings[iCount]);

             {delete the source items from last to 1st}
             iCount := Source.Items.Count - 1;
             repeat
                   if Source.Selected[iCount] then
                      Source.Items.Delete(iCount);

                   Dec(iCount);

             until (iCount < 0);
        end;
        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception moving selected items',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function TImportMatrixForm.IsTenureSelected : boolean;
begin
     {determines if Original Tenure box is empty, ie. all orig tenure classes have
      been selected to one of Available, Reserved or Ignored}
     if (OrigTenure.Items.Count = 0) then
     begin
          Result := True;
     end
     else
         Result := False;
end;

procedure TImportMatrixForm.btnNextClick(Sender: TObject);
begin
      Notebook1.PageIndex := Notebook1.PageIndex + 1;
end;

procedure TImportMatrixForm.InitPathName;
var
   sTmp : string;
begin
     {}
     sTmp := ExtractFilePath(MtxTblBox.Items.Strings[MtxTblBox.ItemIndex]);
     if (Length(sTmp) > 1) then
     begin
          if (Copy(sTmp,Length(sTmp),1) = '\') then
             sTmp := Copy(sTmp,1,Length(sTmp) - 1);
     end;
     Edit2.Text := sTmp;
     Edit1.Text := 'data';
end;

procedure TImportMatrixForm.FormCreate(Sender: TObject);
var
   iCount : integer;
begin
     Notebook1.PageIndex := 0;

     ClientWidth := BitBtn1.Left + BitBtn1.Width + 14;
     ClientHeight := BitBtn1.Top + BitBtn1.Height + 8;

     {prepare first page of notebook}
     {add available tables to listbox so user can choose which table contains
      the matrix data}
     with SCPForm do
     if (MDIChildCount > 0) then
        for iCount := 0 to (MDIChildCount-1) do
            //if (TMDIChild(MDIChildren[iCount]).CheckLoadFileData.Checked) then
            begin
                 // only list tables that are loaded
                 MtxTblBox.Items.Add(MDIChildren[iCount].Caption);
                 AreaBox.Items.Add(MDIChildren[iCount].Caption);
                 ExtantBox.Items.Add(MDIChildren[iCount].Caption);
                 TenureBox.Items.Add(MDIChildren[iCount].Caption);
                 TargetBox.Items.Add(MDIChildren[iCount].Caption);
                 NameTableBox.Items.Add(MDIChildren[iCount].Caption);
                 VulnerabilityBox.Items.Add(MDIChildren[iCount].Caption);
            end;
end;


procedure TImportMatrixForm.MtxTblBoxClick(Sender: TObject);
var
   iCount, iChildIndex : integer;
   Child : TMDIChild;
begin
     if (MtxTblBox.Items.Count > 0) then
        for iCount := 0 to (MtxTblBox.Items.Count-1) do
            if MtxTblBox.Selected[iCount] then
            begin
                 btnNext.Enabled := True;
                 {enable next button when user selects a table}

                 InitPathName; {ititialise output path and database name}

                 {set SpinEdit1.MaxValue to equal the number of features in
                  the selected matrix, allows user to select PCCONTRCutOff
                  to be <= this value}
                 iChildIndex := SCPForm.rtnTableId(MtxTblBox.Items.Strings[iCount]);
                 Child := TMDIChild(SCPForm.MDIChildren[iChildIndex]);
                 SpinEdit1.MaxValue := Child.SpinRow.Value - 1;

                 MtxTblBox.Hint := MtxTblBox.Items.Strings[iCount];
            end;
end;


procedure TImportMatrixForm.EditMultChange(Sender: TObject);
var
   rValue : real;
begin
     if (EditMult.Text <> '')
     and (EditMult.Text <> '.')
     and (EditMult.Text <> '-') then
        {test edit box contains a number}
        try
           rValue := StrToFloat(EditMult.Text);

        except
              MessageDlg('Value must be a number',mtInformation,[mbOk],0);
              EditMult.Text := '';
        end;
end;

function rtnConversionChange(FromBox, ToBox : TComboBox;
                             Mult : TEdit) : extended;
var
   rConvFrom, rConvTo : extended;
   iIndexOf : integer;
begin
     try
        Result := -1;

        iIndexOf := FromBox.Items.IndexOf(FromBox.Text);

        if (iIndexOf >= 0) then
           {item is from drop down list}
           rConvFrom := rtnConversionFactor(iIndexOf)
        else
        begin
             {remove the text, user has entered some other string}
             FromBox.Text := '';
             rConvFrom := -1;
        end;

        iIndexOf := ToBox.Items.IndexOf(ToBox.Text);

        if (iIndexOf >= 0) then
           {item is from drop down list}
           rConvTo := rtnConversionFactor(iIndexOf)
        else
        begin
             {remove the text, user has entered some other string}
             ToBox.Text := '';
             rConvTo := -1;
        end;

        if (rConvFrom > 0)
        and (rConvTo > 0) then
        begin
             Result := rConvFrom / rConvTo;
             Mult.Text := FloatToStr(Result);
        end;

     except
           MessageDlg('Exception in rtnConversionChange',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


procedure TImportMatrixForm.ComboFromChange(Sender: TObject);
begin
     rtnConversionChange(ComboFrom,ComboTo,EditMult);
end;

procedure TImportMatrixForm.ComboToChange(Sender: TObject);
begin
     rtnConversionChange(ComboFrom,ComboTo,EditMult);
end;

procedure TImportMatrixForm.Button12Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex - 1;
end;

procedure TImportMatrixForm.Button11Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex - 1;
end;

procedure TImportMatrixForm.Button3Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex + 1;
end;

procedure TImportMatrixForm.BitBtn3Click(Sender: TObject);
begin
     ModalResult := mrCancel;
end;

procedure TImportMatrixForm.BitBtn1Click(Sender: TObject);
begin
     ModalResult := mrCancel;
end;

procedure TImportMatrixForm.BitBtn2Click(Sender: TObject);
begin
     ModalResult := mrCancel;
end;

procedure TImportMatrixForm.BitBtn10Click(Sender: TObject);
begin
     ModalResult := mrCancel;
end;

procedure TImportMatrixForm.ParseLoadTenure(const sFilename, sTenureField : string;
                                            TenureBox : TListBox);
var
   Parser : TTableParser;
   iTenureField, iRow : integer;
   sCell : string;
begin
     {parse sFilename, load all distinct values of field sTenureField to TenureBox}

     try
        Parser := TTableParser.Create(Application);

        if Parser.initfile(sFilename) then
           {initialise table sFilename within Parser}
        begin
             {table is ready to read the tenure field}
             iTenureField := Parser.rtnColumnId(sTenureField);

             Parser.fOptimiseColumnAccess := False;

             iRow := 1;
             Parser.seekfile(iRow);
             if (iTenureField >= 0) then
                repeat
                      sCell := Parser.rtnRowValue(iTenureField);

                      if (TenureBox.Items.IndexOf(sCell)=-1) then
                         TenureBox.Items.Add(sCell);

                      Inc(iRow);

                until (not Parser.seekfile(iRow));

             Parser.donefile;
        end;

        {dispose table sFilename within Parser}
        Parser.Free;

     except
           Screen.Cursor := crDefault;

           MessageDlg('Exception in TImportExpertForm.ParseLoadTenure file ' + sFilename,
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;



procedure TImportMatrixForm.Button14Click(Sender: TObject);

   procedure LoadTenureClasses;
   var
      iChildId : integer;
      TenureChild : TMDIChild;
      sTenureField, sTenureTable : string;
      iTenureField, iTenureTable, iCount : integer;
   begin
        {we need to prepare the page by loading tenure classes
         to the OrigTenure box}
        if ((AvailTenure.Items.Count = 0)
            and (ResTenure.Items.Count = 0)
            and (IgnTenure.Items.Count = 0)) then {check we have not already specified tenure classes}
        begin
             OrigTenure.Items.Clear;
             AvailTenure.Items.Clear;
             ResTenure.Items.Clear;
             IgnTenure.Items.Clear;

             sTenureField := ComboBox2.Text;

             {we will have to parse the dbf or csv file if we are just linked to the file,
              else we will have parse the grid in the appropriate child}
             sTenureTable := TenureBox.Items.Strings[TenureBox.ItemIndex];
             iTenureTable := SCPForm.rtnTableId(sTenureTable);
             TenureChild := TMDIChild(SCPForm.MDIChildren[iTenureTable]);
             if TenureChild.CheckLoadFileData.Checked then
             begin
                  {data is loaded and we can parse the grid}

                  {locate column with field name sTenureField}
                  for iCount := 0 to (TenureChild.aGrid.ColCount - 1) do
                      if (TenureChild.aGrid.Cells[iCount,0] = sTenureField) then
                         iTenureField := iCount;

                  {write all unique tenure entries to the OrigTenure box}
                  for iCount := 1 to (TenureChild.aGrid.RowCount - 1) do
                      if (OrigTenure.Items.IndexOf(TenureChild.aGrid.Cells[iTenureField,iCount]) < 0) then
                         OrigTenure.Items.Add(TenureChild.aGrid.Cells[iTenureField,iCount]);
             end
             else
             begin
                  {Screen.Cursor := crHourglass;}

                  {data is not loaded so we must parse the file}
                  ParseLoadTenure(TenureChild.Caption,ComboBox2.Text,OrigTenure);

                  {Screen.Cursor := crDefault;}
             end;
        end;
   end;

begin
     if (ComboBox2.Text <> '') then
     begin
          {jump to 2c assign classes of tenure}
          Notebook1.PageIndex := Notebook1.PageIndex + 1;

          {we also need to prepare the page by loading tenure classes
           to the OrigTenure box}
          LoadTenureClasses;
     end
     else
         {jump to 3  choose extra sst field table(s), no tenure table/field specified}
         Notebook1.PageIndex := 8;
end;

procedure TImportMatrixForm.Button13Click(Sender: TObject);
begin
     if (ComboBox1.Text = '') then
        {area field not specified
         jump back to 2  choose AREA table, because user has not selected AREA table}
        Notebook1.PageIndex := Notebook1.PageIndex - 2
     else
         {area field specified
          jump back to 2a convert unit of area, because user has selected AREA table}
         Notebook1.PageIndex := Notebook1.PageIndex - 1;
end;

procedure TImportMatrixForm.SpeedButton2Click(Sender: TObject);
begin
     {move selected items from OrigTenure to AvailTenure}
     MoveSelect(OrigTenure,AvailTenure);
end;

procedure TImportMatrixForm.SpeedButton4Click(Sender: TObject);
begin
     MoveSelect(AvailTenure,OrigTenure);
end;

procedure TImportMatrixForm.SpeedButton1Click(Sender: TObject);
begin
     MoveSelect(OrigTenure,ResTenure);
end;

procedure TImportMatrixForm.SpeedButton3Click(Sender: TObject);
begin
     MoveSelect(ResTenure,OrigTenure);
end;

procedure TImportMatrixForm.SelHighlightTblClick(Sender: TObject);
begin
     MoveSelect(OrigTenure,IgnTenure);
end;

procedure TImportMatrixForm.UnSelHighlightTblClick(Sender: TObject);
begin
     MoveSelect(IgnTenure,OrigTenure);
end;

procedure TImportMatrixForm.AreaBoxClick(Sender: TObject);
var
   iChildId, iCount : integer;
   Child : TMDIChild;
begin
     {load fields from the selected table into the Select AREA Field drop down
      list
      note: fields are first row of grid containing selected table}

     ComboBox1.Items.Clear;
     ComboBox1.Text := '';

     iChildId := SCPForm.rtnTableId(AreaBox.Items.Strings[AreaBox.ItemIndex]);
     Child := TMDIChild(SCPForm.MDIChildren[iChildId]);
     for iCount := 0 to (Child.aGrid.ColCount - 1) do
         ComboBox1.Items.Add(Child.aGrid.Cells[iCount,0]);

     AreaBox.Hint := AreaBox.Items.Strings[AreaBox.ItemIndex];
end;

procedure TImportMatrixForm.TenureBoxClick(Sender: TObject);
var
   iChildId, iCount : integer;
   Child : TMDIChild;
begin
     {load fields from the selected table into the Select AREA Field drop down
      list
      note: fields are first row of grid containing selected table}

     ComboBox2.Items.Clear;
     ComboBox2.Text := '';

     iChildId := SCPForm.rtnTableId(TenureBox.Items.Strings[TenureBox.ItemIndex]);
     Child := TMDIChild(SCPForm.MDIChildren[iChildId]);
     for iCount := 0 to (Child.aGrid.ColCount - 1) do
         ComboBox2.Items.Add(Child.aGrid.Cells[iCount,0]);

     TenureBox.Hint := TenureBox.Items.Strings[TenureBox.ItemIndex];
end;

procedure TImportMatrixForm.Button2Click(Sender: TObject);
begin
     if (AreaBox.ItemIndex >= 0) then
        {jump to 2a convert unit of area}
        Notebook1.PageIndex := Notebook1.PageIndex + 1
     else
         {jump to 2b choose TENURE table (skip 2a because user is not importing area)}
         Notebook1.PageIndex := Notebook1.PageIndex + 2;
end;

procedure TImportMatrixForm.Button10Click(Sender: TObject);
var
   iCount : integer;
begin
     {launch join tables expert, pass in parameter to automatically link table
      (if writing directly to an output file)
      and after it has been run, refresh the
      available tables box (MtxTblBox from the list of tables)}

     SCPForm.JoinTables(True);

     MtxTblBox.Items.Clear;
     AreaBox.Items.Clear;
     ExtantBox.Items.Clear;
     TenureBox.Items.Clear;
     TargetBox.Items.Clear;
     NameTableBox.Items.Clear;
     with SCPForm do
     if (MDIChildCount > 0) then
        for iCount := 0 to (MDIChildCount-1) do
        begin
             MtxTblBox.Items.Add(MDIChildren[iCount].Caption);
             AreaBox.Items.Add(MDIChildren[iCount].Caption);
             ExtantBox.Items.Add(MDIChildren[iCount].Caption);
             TenureBox.Items.Add(MDIChildren[iCount].Caption);
             TargetBox.Items.Add(MDIChildren[iCount].Caption);
             NameTableBox.Items.Add(MDIChildren[iCount].Caption);
        end;
     btnNext.Enabled := False;
end;

procedure TImportMatrixForm.Button4Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex + 1;
end;

procedure TImportMatrixForm.Button1Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex - 1;
end;

procedure TImportMatrixForm.BitBtn12Click(Sender: TObject);
begin
     try
        {build the C-Plan database with the specified input parameters}
        Screen.Cursor := crHourglass;

        if (Edit2.Text <> '') then
           ExecuteImportSequence;

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Execute Import Sequence',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TImportMatrixForm.Button15Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex - 1;
end;

procedure TImportMatrixForm.TargetBoxClick(Sender: TObject);
var
   iChildId, iCount : integer;
   Child : TMDIChild;
begin
     {load fields from the selected table into the Select TARGET Field drop down list
      note: fields are first row of grid containing selected table}

     ComboBox3.Items.Clear;
     ComboBox3.Text := '';

     iChildId := SCPForm.rtnTableId(TargetBox.Items.Strings[TargetBox.ItemIndex]);
     Child := TMDIChild(SCPForm.MDIChildren[iChildId]);
     for iCount := 0 to (Child.aGrid.ColCount - 1) do
         ComboBox3.Items.Add(Child.aGrid.Cells[iCount,0]);

     TargetBox.Hint := TargetBox.Items.Strings[TargetBox.ItemIndex];
end;

procedure TImportMatrixForm.combomultChange(Sender: TObject);
var
   rValue : real;
begin
     if (combomult.Text <> '')
     and (combomult.Text <> '.')
     and (combomult.Text <> '-') then
        {test edit box contains a number}
        try
           rValue := StrToFloat(combomult.Text);

        except
              MessageDlg('Value must be a number',mtInformation,[mbOk],0);
              combomult.Text := '';
        end;
end;

procedure TImportMatrixForm.Button26Click(Sender: TObject);
begin
     {SaveData.InitialDir := ExtractFilePath(Edit2.Text);}

     try
        BrowseDirForm := TBrowseDirForm.Create(Application);
        BrowseDirForm.DirectoryListBox1.Directory := Edit2.Text;
        BrowseDirForm.Caption := 'Browse Output Path';
        if (BrowseDirForm.ShowModal = mrOk) then
           Edit2.Text := BrowseDirForm.DirectoryListBox1.Directory;
        BrowseDirForm.Free;

     except
           MessageDlg('Exception in Browse Output Path',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;

end;

procedure TImportMatrixForm.Button21Click(Sender: TObject);
begin
     if (ComboBox2.Text = '') then
        {no tenure field specified
         jump back to choose Tenure table, because user has not selected Tenure table}
        Notebook1.PageIndex := Notebook1.PageIndex - 2
     else
         {tenure field specified
          jump back to assign classes of Tenure, because user has selected Tenure table}
         Notebook1.PageIndex := Notebook1.PageIndex - 1;

end;

procedure TImportMatrixForm.Button22Click(Sender: TObject);
begin
     if (ComboBox3.Text = '') then
        {no TARGET table has been specified}
        Notebook1.PageIndex := Notebook1.PageIndex + 2
     else
         {TARGET table has been specified}
         Notebook1.PageIndex := Notebook1.PageIndex + 1;
end;

procedure TImportMatrixForm.Button24Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex + 1;
end;

procedure TImportMatrixForm.Button20Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex - 1;

     (*if (ComboBox3.Text = '') then
        {EXTANT table has not been chosen}
        Notebook1.PageIndex := Notebook1.PageIndex - 2
     else
         {EXTANT table has been chosen}
         Notebook1.PageIndex := Notebook1.PageIndex - 1;*)
end;

procedure TImportMatrixForm.ComboBox4Change(Sender: TObject);
begin
     rtnConversionChange(ComboBox4,ComboBox5,combomult);
end;

procedure TImportMatrixForm.ComboBox6Change(Sender: TObject);
begin
     rtnConversionChange(ComboBox6,ComboBox7,Edit3);
end;

procedure TImportMatrixForm.Edit3Change(Sender: TObject);
var
   rValue : real;
begin
     if (Edit3.Text <> '')
     and (Edit3.Text <> '.')
     and (Edit3.Text <> '-') then
        {test edit box contains a number}
        try
           rValue := StrToFloat(Edit3.Text);

        except
              MessageDlg('Value must be a number',mtInformation,[mbOk],0);
              Edit3.Text := '';
        end;
end;

procedure TImportMatrixForm.NameTableBoxClick(Sender: TObject);
var
   iChildId, iCount : integer;
   Child : TMDIChild;
begin
     {load fields from the selected table into the Select AREA Field drop down list
      note: fields are first row of grid containing selected table}

     ComboBox8.Items.Clear;
     ComboBox8.Text := '';

     iChildId := SCPForm.rtnTableId(NameTableBox.Items.Strings[NameTableBox.ItemIndex]);
     Child := TMDIChild(SCPForm.MDIChildren[iChildId]);
     for iCount := 0 to (Child.aGrid.ColCount - 1) do
         ComboBox8.Items.Add(Child.aGrid.Cells[iCount,0]);

     NameTableBox.Hint := NameTableBox.Items.Strings[NameTableBox.ItemIndex];
end;

procedure TImportMatrixForm.btnBrowseClick(Sender: TObject);
begin
     BrowseTable;
end;




procedure TImportMatrixForm.Button6Click(Sender: TObject);
begin
     if (combobox3.Text = '') then
        {no target field specified, step - 2}
        Notebook1.PageIndex := Notebook1.PageIndex - 2
     else
         {target field specified, step - 1}
         Notebook1.PageIndex := Notebook1.PageIndex - 1;
end;

procedure TImportMatrixForm.Button7Click(Sender: TObject);
begin
     if (ExtantCombo.Text = '') then
        Notebook1.PageIndex := Notebook1.PageIndex + 2
     else
         Notebook1.PageIndex := Notebook1.PageIndex + 1;
end;


procedure TImportMatrixForm.EditExtantConvChange(Sender: TObject);
var
   rValue : real;
begin
     if (EditExtantConv.Text <> '')
     and (EditExtantConv.Text <> '.')
     and (EditExtantConv.Text <> '-') then
        {test edit box contains a number}
        try
           rValue := StrToFloat(EditExtantConv.Text);

        except
              MessageDlg('Value must be a number',mtInformation,[mbOk],0);
              combomult.Text := '';
        end;
end;

procedure TImportMatrixForm.ExtantFromConvChange(Sender: TObject);
begin
     rtnConversionChange(ExtantFromConv,ExtantToConv,EditExtantConv);
end;

procedure TImportMatrixForm.ExtantBoxClick(Sender: TObject);
var
   iChildId, iCount : integer;
   Child : TMDIChild;
begin
     {load fields from the selected table into the Select TARGET Field drop down list
      note: fields are first row of grid containing selected table}

     ExtantCombo.Items.Clear;
     ExtantCombo.Text := '';

     iChildId := SCPForm.rtnTableId(ExtantBox.Items.Strings[ExtantBox.ItemIndex]);
     Child := TMDIChild(SCPForm.MDIChildren[iChildId]);
     for iCount := 0 to (Child.aGrid.ColCount - 1) do
         ExtantCombo.Items.Add(Child.aGrid.Cells[iCount,0]);

     ExtantBox.Hint := ExtantBox.Items.Strings[ExtantBox.ItemIndex];
end;

procedure TImportMatrixForm.OrigTenureClick(Sender: TObject);
begin
     OrigTenure.Hint := OrigTenure.Items.Strings[OrigTenure.ItemIndex];
end;

procedure TImportMatrixForm.AvailTenureClick(Sender: TObject);
begin
     AvailTenure.Hint := AvailTenure.Items.Strings[AvailTenure.ItemIndex];
end;

procedure TImportMatrixForm.ResTenureClick(Sender: TObject);
begin
     ResTenure.Hint := ResTenure.Items.Strings[ResTenure.ItemIndex];
end;

procedure TImportMatrixForm.IgnTenureClick(Sender: TObject);
begin
     IgnTenure.Hint := IgnTenure.Items.Strings[IgnTenure.ItemIndex];
end;


procedure TImportMatrixForm.Button17Click(Sender: TObject);
begin
     if (ExtantCombo.Text = '') then
        {no extant field specified, step - 2}
        Notebook1.PageIndex := Notebook1.PageIndex - 2
     else
         {extant field specified, step - 1}
         Notebook1.PageIndex := Notebook1.PageIndex - 1;
end;

procedure TImportMatrixForm.Button18Click(Sender: TObject);
begin
     Notebook1.PageIndex := Notebook1.PageIndex + 1;
end;

procedure TImportMatrixForm.VulnerabilityBoxClick(Sender: TObject);
var
   iChildId, iCount : integer;
   Child : TMDIChild;
begin
     {load fields from the selected table into the Select VulnerabilityBox Field drop down list
      note: fields are first row of grid containing selected table}

     ComboVuln.Items.Clear;
     ComboVuln.Text := '';

     iChildId := SCPForm.rtnTableId(VulnerabilityBox.Items.Strings[VulnerabilityBox.ItemIndex]);
     Child := TMDIChild(SCPForm.MDIChildren[iChildId]);
     for iCount := 0 to (Child.aGrid.ColCount - 1) do
         ComboVuln.Items.Add(Child.aGrid.Cells[iCount,0]);

     VulnerabilityBox.Hint := VulnerabilityBox.Items.Strings[VulnerabilityBox.ItemIndex];
end;

procedure TImportMatrixForm.btnSaveSpecClick(Sender: TObject);
begin
     //SaveWizardSpecification();
end;

procedure TImportMatrixForm.btnLoadSpecClick(Sender: TObject);
begin
     //LoadWizardSpecification();
end;

end.
