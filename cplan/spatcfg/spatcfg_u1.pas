unit spatcfg_u1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TSPATCFGForm = class(TForm)
    btnLink: TButton;
    Label1: TLabel;
    EditCPlanDatabase: TEdit;
    btnLocateCPlanDB: TButton;
    Label2: TLabel;
    EditDistanceTable: TEdit;
    Locate: TButton;
    BitBtn1: TBitBtn;
    btnMoveSpat: TButton;
    OpenCPlan: TOpenDialog;
    OpenDistance: TOpenDialog;
    ErrorBox: TListBox;
    CPLANINIBox: TListBox;
    AutoTimer: TTimer;
    btnMoveCPlan: TButton;
    SaveCPlan: TSaveDialog;
    SaveSpat: TSaveDialog;
    procedure btnLinkClick(Sender: TObject);
    procedure btnLocateCPlanDBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LocateClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure AutoTimerTimer(Sender: TObject);
    procedure btnMoveCPlanClick(Sender: TObject);
    procedure btnMoveSpatClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SPATCFGForm: TSPATCFGForm;
  fCPLocate, fSpatLocate : boolean;

implementation

uses
    inifiles, FMXUtils;

{$R *.DFM}

procedure UpdateCPLANINI(const sIni,sDst : string);
var
   AIni : TIniFile;
begin
     AIni := TIniFile.Create(sIni);

     AIni.ReadSectionValues('Spatial Tool',SPATCFGForm.CPLANINIBox.Items);
     AIni.EraseSection('Spatial Tool');
     AIni.WriteString('Spatial Tool','SpatialDatabase',ExtractFilePath(sDst));
     AIni.WriteString('Spatial Tool','ConnectSpatialTool','1');

     AIni.Free;
end;

procedure WriteUNITDATAINI(const sDst : string);
var
   sUnitdata : string;
   UnitdataFile : TextFile;
   iLength : integer;
   sFile : string;
begin
     sUnitdata := ExtractFilePath(sDst) + 'unitdata.ini';
     assignfile(UnitdataFile,sUnitdata);
     rewrite(UnitdataFile);

     iLength := Length(sDst);
     sFile := Copy(sDst,1,iLength-3) + 'blu';
     writeln(UnitdataFile,'planning_unit_lookup_index			 ' + sFile);
     writeln(UnitdataFile,'planning_unit_distance_keyed_data	 ' + sDst);
     sFile := Copy(sDst,1,iLength-3) + 'idx';
     writeln(UnitdataFile,'planning_unit_index_keyed_data		 ' + sFile);
     sFile := Copy(sDst,1,iLength-3) + 'log';
     writeln(UnitdataFile,'log				 ' + sFile);

     //planning_unit_lookup_index			 d:\data\n1\n1test.blu
     //planning_unit_distance_keyed_data	 d:\data\n1\n1test.dst
     //planning_unit_index_keyed_data		 d:\data\n1\n1test.idx
     //log				 d:\data\n1\n1test.log

     close(UnitdataFile);
end;

procedure TSPATCFGForm.btnLinkClick(Sender: TObject);
var
   iLength : integer;
   sFile : string;
begin
     try
        if fCPLocate
        and fSpatLocate then
        begin
             // display contents of .err file if any contents
             iLength := Length(EditDistanceTable.Text);
             sFile := Copy(EditDistanceTable.Text,1,iLength-3) + 'err';
             if FileExists(sFile) then
                ErrorBox.Items.LoadFromFile(sFile);

             if (ErrorBox.Items.Count = 0) then
             begin
                  // initialise unitdata.ini file on spatial database path
                   WriteUNITDATAINI(EditDistanceTable.Text);

                  // update cplan.ini file on C-Plan database path
                  // add (or replace if already there) path information to this section
                  // and any other parameters needed
                  UpdateCPLANINI(EditCPlanDatabase.Text,EditDistanceTable.Text);

                  MessageDlg('Settings updated.',mtInformation,[mbOk],0);
                  Application.Terminate
             end
             else
             begin
                  ErrorBox.Items.Insert(0,'');
                  ErrorBox.Items.Insert(0,'There are errors in the distance file');
                  ErrorBox.Visible := True;
             end;
        end
        else
            MessageDlg('Locate C-Plan Database and Spatial Distance Table first',mtInformation,[mbOk],0);

     except
           MessageDlg('Exception when performing link',mtInformation,[mbOk],0);
     end;
end;

procedure TSPATCFGForm.btnLocateCPlanDBClick(Sender: TObject);
begin
     ErrorBox.Visible := False;
     if OpenCPlan.Execute then
     begin
          EditCPlanDatabase.Text := OpenCPlan.Filename;
          fCPLocate := True;
     end;
end;

procedure TSPATCFGForm.FormCreate(Sender: TObject);
begin
     fCPLocate := False;
     fSpatLocate := False;

     if (ParamCount = 2) then
     begin
          // command line parameters passed in for automatic operation
          AutoTimer.Enabled := True;
     end;
end;

procedure TSPATCFGForm.LocateClick(Sender: TObject);
begin
     ErrorBox.Visible := False;
     if OpenDistance.Execute then
     begin
          EditDistanceTable.Text := OpenDistance.Filename;
          fSpatLocate := True;
     end;
end;

procedure TSPATCFGForm.BitBtn1Click(Sender: TObject);
begin
     Application.Terminate;
end;

procedure TSPATCFGForm.AutoTimerTimer(Sender: TObject);
var
   sCPlanDB, sDstTable, sFile : string;
   iLength : integer;
begin
     try
        // Execute using the provided command line parameters.
        // Die gracefully if successful, or else display distance table errors.

        AutoTimer.Enabled := False;

        sCPlanDB := ParamStr(1);
        sDstTable := ParamStr(2);

        if fileexists(sCPlanDB)
        and fileexists(sDstTable) then
        begin
             // display contents of .err file if any contents
             iLength := Length(sDstTable);
             sFile := Copy(sDstTable,1,iLength-3) + 'err';
             if FileExists(sFile) then
                ErrorBox.Items.LoadFromFile(sFile);

             if (ErrorBox.Items.Count = 0) then
             begin
                  // initialise unitdata.ini file on spatial database path
                   WriteUNITDATAINI(sDstTable);

                  // update cplan.ini file on C-Plan database path
                  // add (or replace if already there) path information to this section
                  // and any other parameters needed
                  UpdateCPLANINI(sCPlanDB,sDstTable);

                  Application.Terminate;
             end
             else
             begin
                  ErrorBox.Items.Insert(0,'');
                  ErrorBox.Items.Insert(0,'There are errors in the distance file : (detail below)');
                  ErrorBox.Items.Insert(0,'Warning : cannot complete required operation.');
                  ErrorBox.Visible := True;
             end;
        end
        else
        begin
             MessageDlg('Specified files not found : >'  + sCPlanDB + '< >' + sDstTable + '<',mtInformation,[mbOk],0);
             Application.Terminate;
        end;

     except
           MessageDlg('Exception when performing link',mtInformation,[mbOk],0);
     end;
end;

procedure TSPATCFGForm.btnMoveCPlanClick(Sender: TObject);
var
   AIni : TIniFile;
   sTmp : string;
begin
     if fileexists(EditCPlanDatabase.Text) then
     begin
          if SaveCPlan.Execute then
          begin
               // move cplan.ini
               MoveFile(EditCPlanDatabase.Text,SaveCPlan.Filename);
               // move referenced files (sst, fst, mtx, key)
               AIni := TIniFile.Create(SaveCPlan.Filename);
               sTmp := AIni.ReadString('Options','SparseMatrix','');
               MoveFile(ExtractFileDir(EditCPlanDatabase.Text) + sTmp,
                        ExtractFileDir(SaveCPlan.Filename) + sTmp);
               sTmp := AIni.ReadString('Options','SparseKey','');
               MoveFile(ExtractFileDir(EditCPlanDatabase.Text) + sTmp,
                        ExtractFileDir(SaveCPlan.Filename) + sTmp);
               sTmp := AIni.ReadString('Options','SiteSummaryTable','');
               MoveFile(ExtractFileDir(EditCPlanDatabase.Text) + sTmp,
                        ExtractFileDir(SaveCPlan.Filename) + sTmp);
               sTmp := AIni.ReadString('Database1','FeatureSummaryTable','');
               MoveFile(ExtractFileDir(EditCPlanDatabase.Text) + sTmp,
                        ExtractFileDir(SaveCPlan.Filename) + sTmp);
               AIni.Free;

               EditCPlanDatabase.Text := SaveCPlan.Filename;
          end;
     end;
end;

procedure TSPATCFGForm.btnMoveSpatClick(Sender: TObject);
var
   sTmpSrc, sTmpDest : string;
   DestIni : TextFile;
begin
     if fileexists(EditDistanceTable.Text) then
     begin
          SaveSpat.FileName := ExtractFileName(EditDistanceTable.Text);
          if SaveSpat.Execute then
          begin
               assignfile(DestIni,ExtractFileDir(SaveSpat.Filename) + '\unitdata.ini');
               rewrite(DestIni);
               MoveFile(EditDistanceTable.Text,SaveSpat.Filename);
               writeln(DestIni,'planning_unit_distance_keyed_data	 ' + SaveSpat.Filename);
               sTmpSrc := Copy(EditDistanceTable.Text,1,Length(EditDistanceTable.Text)-3);
               sTmpDest := Copy(SaveSpat.Filename,1,Length(SaveSpat.Filename)-3);
               MoveFile(sTmpSrc + 'blu',
                        sTmpDest + 'blu');
               writeln(DestIni,'planning_unit_lookup_index			 ' + sTmpDest + 'blu');
               MoveFile(sTmpSrc + 'idx',
                        sTmpDest + 'idx');
               writeln(DestIni,'planning_unit_index_keyed_data		 ' + sTmpDest + 'idx');
               if fileexists(sTmpSrc + 'err') then
                  MoveFile(sTmpSrc + 'err',
                           sTmpDest + 'err');
               if fileexists(sTmpSrc + 'sta') then
                  MoveFile(sTmpSrc + 'sta',
                           sTmpDest + 'sta');
               if fileexists(sTmpSrc + 'txt') then
                  MoveFile(sTmpSrc + 'txt',
                           sTmpDest + 'txt');
               writeln(DestIni);
               writeln(DestIni,'log				 ' + sTmpDest + 'log');
               closefile(DestIni);
               deletefile(ExtractFileDir(EditDistanceTable.Text) + '\unitdata.ini');

               EditDistanceTable.Text := SaveSpat.Filename;
          end;
     end;
end;

end.
