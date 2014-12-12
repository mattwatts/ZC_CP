unit Test_imp;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Grids, DB, DBTables, Menus;

type
  TDBManForm = class(TForm)
    TRNFile: TStringGrid;
    Button1: TButton;
    Button2: TButton;
    txtMatrix: TEdit;
    txtTrn: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    browseCSV: TButton;
    browseTRN: TButton;
    BrowseDB: TOpenDialog;
    CSVFile: TStringGrid;
    txtDBName: TEdit;
    txtOutPath: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    SSTable: TTable;
    FSTable: TTable;
    AQuery: TQuery;
    txtTitle: TEdit;
    slkdf: TLabel;
    btnExit: TButton;
    MainMenu1: TMainMenu;
    Database1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    Import1: TMenuItem;
    Fields1: TMenuItem;
    lblProcess: TLabel;
    lblCount: TLabel;
    Button3: TButton;
    LargeMatrixBuild1: TMenuItem;
    txtMutEx: TEdit;
    Label5: TLabel;
    Button4: TButton;
    lblProgress: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure browseCSVClick(Sender: TObject);
    procedure browseTRNClick(Sender: TObject);
    procedure btnNewDBClick(Sender: TObject);
    procedure btnAddMatrixClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure Fields1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DBManForm: TDBManForm;

  fKill : boolean;

implementation

uses
    Imptools, Global, FieldImp,
    Dbms_man, Showimp, Mk_irr, reg;

{$R *.DFM}

procedure TDBManForm.Button1Click(Sender: TObject);
begin
     LoadCSV2StringGrid(CSVFile,'a:\combined.csv',TRUE);
end;

procedure TDBManForm.Button2Click(Sender: TObject);
begin
     LoadTRN2StringGrid(TRNFile,'d:\car\urben\v001\v001.trn');
end;

procedure TDBManForm.browseCSVClick(Sender: TObject);
begin
     with BrowseDB do
     begin
          Title := 'Browse CSV Report Matrix';
          DefaultExt := 'CSV';
          InitialDir := ExtractFilePath(txtMatrix.Text);
          FileName := ExtractFileName(txtMatrix.Text);
          FilterIndex := 1;
          if Execute then
          begin
               txtMatrix.Text := {LowerCase}(FileName);

               {if (txtTrn.Text = 'c:\') then}

               txtTrn.Text := ExtractFilePath(FileName);

               txtMatrix.SelectAll;
               txtTrn.SelectAll;
          end;
     end;
end;

procedure TDBManForm.browseTRNClick(Sender: TObject);
begin
     with BrowseDB do
     begin
          Title := 'Browse TRN Site List';
          DefaultExt := '*';
          InitialDir := ExtractFilePath(txtTrn.Text);
          FileName := INI_FILE_NAME;
          FilterIndex := 2;
          if Execute then
          begin
               txtTrn.Text := {LowerCase}ExtractFilePath(FileName);
               txtTrn.SelectAll;
          end;
     end;
end;

(*
function CustTrim01(const sLine : string) : string;
var
   iCount : integer;
begin
     {we are generating a 1-5 char
      Database Name from the user title
      (for naming new DB files)}


     {trim to 5 chars or less}
     if (Length(sLine) > 5) then
        Result := Copy(sLine,1,5)
     else
         Result := sLine;


     {check not empty}
     if (Length(Result) = 0) then
        Result := 'empty'
     else
         for iCount := 1 to Length(Result) do
             if (Result[iCount] = ' ') then
                Result[iCount] := '_';
end;
*)

procedure TDBManForm.btnNewDBClick(Sender: TObject);
var
   sLabel, sOutPath : string;
   fRun, fEndBrowse : boolean;
begin
     fEndBrowse := False;

     repeat
           if (txtMatrix.Text = 'c:\')
           and (txtTrn.Text = 'c:\') then
           begin
                fRun := False;

                {browse some files}
                browseCSVclick(self);
                browseTRNclick(self);
           end
           else
               fRun := True;

           fEndBrowse := True;

     until fEndBrowse;

     if fRun then
     begin
          try
             Screen.Cursor := crHourglass;

             LoadCSV2StringGrid(CSVFile,txtMatrix.Text,TRUE);
             LoadCSV2StringGrid(TRNFile,txtTrn.Text,TRUE);
             {LoadTRN2StringGrid(TRNFile,txtTrn.Text);}

             sLabel := {CustTrim01}(txtTitle.Text);
             sOutPath := ExtractFilePath(txtTrn.Text);

             {sTmpCSV := 'c:\scratch' + '\' + DB_BUILD_FILENAME + '.csv';
             sTmpTRN := 'c:\scratch' + '\' + DB_BUILD_FILENAME + '.trn';
             SaveStringGrid2CSV(CSVFile,sTmpCSV);
             SaveStringGrid2TRN(TRNFile,sTmpTRN);}

             {if SortTrimInput(CSVFile,TRNFile) then}
             if CheckImportSize(CSVFile,TRNFile) then
             begin
                  {SaveStringGrid2CSV(CSVFile,sTmpCSV);
                  SaveStringGrid2TRN(TRNFile,sTmpTRN);}


                  {CSV2SiteSummary(TRNFile,SSTable,sLabel,sOutPath);}
                  CSV2SiteSummary(CSVFile,SSTable,sLabel,sOutPath);

                  {TRN2SiteSummary(TRNFile,SSTable,sLabel,sOutPath);}
                  CSV2Matrix(CSVFile,FSTable,sLabel,sOutPath,2);
             end;

          finally
                 Screen.Cursor := crDefault;
          end;

          DBManForm.lblProcess.Caption := 'Finished';
          DBManForm.lblCount.Caption := '';
          DBManForm.Update;

     end;
end;

procedure TDBManForm.btnAddMatrixClick(Sender: TObject);
var
   sLabel, sOutPath : string;
begin
     if (txtMatrix.Text = 'c:\')
     and (txtTrn.Text = 'c:\') then
     begin
          {browse some files}
     end
     else
     begin
          Screen.Cursor := crHourglass;

          LoadCSV2StringGrid(CSVFile,txtMatrix.Text,TRUE);
          LoadTRN2StringGrid(TRNFile,txtTrn.Text);
          sLabel := {CustTrim01}(txtTitle.Text);
          sOutPath := ExtractFilePath(txtTrn.Text);

          if SortTrimInput(CSVFile,TRNFile) then
          begin
               CSV2Matrix(CSVFile,FSTable,sLabel,sOutPath,1);
          end;

          Screen.Cursor := crDefault;

          DBManForm.lblProcess.Caption := 'Finished';
          DBManForm.lblCount.Caption := '';
          DBManForm.Update;
     end;
end;

procedure TDBManForm.btnExitClick(Sender: TObject);
begin
     modalresult := mrok;
     application.terminate;
end;

procedure TDBManForm.Fields1Click(Sender: TObject);
begin
     ImpOptionsForm := TImpOptionsForm.Create(Application);
     ImpOptionsForm.ShowModal;
     ImpOptionsForm.Free;
end;

procedure TDBManForm.Button3Click(Sender: TObject);
var
   sInFile, sOutPath, sLabel,
   sIni, sMatrixFile : string;
   iFCount, iPCUSED_C_O : integer;
   fLinkToWinERMS : boolean;
begin
     {Large/Small Matrix Build}

     try
        Screen.Cursor := crHourglass;

        try
           iPCUSED_C_O := StrToInt(txtMutEx.Text);

        except on exception do
               iPCUSED_C_O := 0;
        end;

        sInFile := txtMatrix.Text;
        sOutPath := ExtractFilePath(txtTrn.Text);
        sLabel := {UpperCase(CustTrim01(}txtTitle.Text{))};

        if (sOutPath[Length(sOutPath)] = '\')
        and (Length(sOutPath) > 1) then
            sOutPath := Copy(sOutPath,1,Length(sOutPath)-1);

        Parse2FileV2(sInFile,sLabel,sOutPath,
                   SSTable,FSTable,sMatrixFile,iFCount);

        if (iFCount > 0) then
        begin
             fLinkToWinERMS := CreateIrrFile(sOutPath);
             {this function is for WinERMS only and will not do
              anything if the directory structure is not an
              ERMS directory structure (eg. c:\car\urben\v001)}


             if fLinkToWinERMS then
                sIni := sOutPath + '\' + OLD_INI_FILE_NAME {must use EMRTYOOL.INI if WinERMS}
             else
                 sIni := sOutPath + '\' + INI_FILE_NAME;

             if not FileExists(sIni) then
                NewIni(sIni,SSTable.TableName);

             if (iPCUSED_C_O > iFCount) then
                iPCUSED_C_O := iFCount;

             AddMatrixIni(sIni,sLabel,ExtractFileName(sMatrixFile),
                          FSTable.TableName,iPCUSED_C_O,iFCount);


        end;

     except
           Screen.Cursor := crDefault;

           MessageDlg('Exception in Build Matrix, possible error in input file',mtError,[mbOk],0);
     end;

     Screen.Cursor := crDefault;

     ShowImpSummaryForm(sIni);
end;

procedure TDBManForm.FormResize(Sender: TObject);
begin
     ClientHeight := btnExit.Top + btnExit.Height + 10;
     ClientWidth := btnExit.Left + btnExit.Width + 10;
     {Position := poScreenCenter;}
end;

procedure TDBManForm.Exit1Click(Sender: TObject);
begin
     btnExitClick(self)
end;

procedure TDBManForm.FormCreate(Sender: TObject);
begin
     if IsValidRegFile then
        FormResize(self)
     else
     begin
          MessageDlg('Please register C-Plan',mtInformation,[mbOk],0);

          Application.terminate;
          exit;
     end;
end;

procedure TDBManForm.Button4Click(Sender: TObject);
begin
     messagedlg('>' + ExtractFilePath(Application.ExeName) + '<',mtInformation,[mbOk],0);
end;

procedure TDBManForm.FormShow(Sender: TObject);
begin
{$IFDEF VER80}
Caption := 'C-Plan Database Import 16 Bit';
{$ELSE}
Caption := 'C-Plan Database Import 32 Bit';
{$ENDIF}
end;

end.
