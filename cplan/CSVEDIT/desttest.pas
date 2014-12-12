unit desttest;

// Author : Matthew Watts
// Date : Tue 16th March 1999
// Purpose : Test the debug output for the C-Plan Minset Destruction
//           functionality.  These are validation routines.

{
   This is what we have to analyse with this unit:

     - check that amount destroyed in each cell at each iteration
       is using the correct destruction rate
     - check that the amount destroyed for each feature at each
       iteration is correct
     - check that feature targets and available area are reduced
       by the appropriate amount according to the amound destroyed
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  ds;

type
  TDestructTestForm = class(TForm)
    BitBtn1: TBitBtn;
    btnExecute: TButton;
    EditWorkingDirectory: TEdit;
    Label1: TLabel;
    btnBrowse: TButton;
    RadioValidateType: TRadioGroup;
    Label2: TLabel;
    Label3: TLabel;
    EditSites: TEdit;
    EditFeatures: TEdit;
    OpenDialog1: TOpenDialog;
    Label4: TLabel;
    EditMinimumArea: TEdit;
    ErrorTolerance: TEdit;
    Label5: TLabel;
    procedure btnExecuteClick(Sender: TObject);
    procedure ReadSiteFeatureCount(const sWorkingDirectory : string);
    procedure ExecuteValidation(const sWorkingDirectory : string;
                                const iValidationType : integer);
    procedure ReadDestructRate(const sFilename : string);
    procedure ReadDestructStatus(const sFilename : string);
    procedure ChangeWorkingDirectory;
    procedure btnBrowseClick(Sender: TObject);
    procedure EditWorkingDirectoryChange(Sender: TObject);
    procedure ReadDestructionFile(const sFilename : string);
    procedure ReadTargetFile(const sFilename : string);
    procedure InitDestructAmount;
    procedure MakeLookupArrays;
    procedure ReadRowValues(const sRow : string);
    procedure RecordError(const sError : string);
    function IsWithinErrorTolerance(const rA, rB : extended) : boolean;
  private
    { Private declarations }
    RowValues,
    FeatureKey, SiteKey,
    FeatureLookup, SiteLookup,
    DestructRate, DestructStatus,
    DestructAmount : Array_t;
    iErrorCount,
    iSiteCount, iFeatureCount : integer;
    fRowValuesCreated : boolean;
    rMinimumArea, rErrorTolerance : extended;
    sErrorFile : string;
  public
    { Public declarations }
  end;

var
  DestructTestForm: TDestructTestForm;

implementation

uses
    global,
    browsed,
    xdata;

{$R *.DFM}

procedure TDestructTestForm.RecordError(const sError : string);
var
   ErrorFile : TextFile;
begin
     Inc(iErrorCount);

     if FileExists(sErrorFile) then
     begin
          assignfile(ErrorFile,sErrorFile);
          reset(ErrorFile);
     end
     else
     begin
          assignfile(ErrorFile,sErrorFile);
          rewrite(ErrorFile);
     end;
     writeln(ErrorFile,sError);
     closefile(ErrorFile);
end;

procedure TDestructTestForm.ReadRowValues(const sRow : string);
var
   fEnd : boolean;
   iPosition,
   iCount, iRowValuesCount, iColumn : integer;
   sTmp : string;
   sCell : str255;
begin
     try
        if not fRowValuesCreated then
        begin
             RowValues := Array_t.Create;
             RowValues.init(SizeOf(str255),ARR_STEP_SIZE);
        end;
        fRowValuesCreated := True;
        iRowValuesCount := 0;
        iColumn := 0;
        sTmp := sRow;
        fEnd := False;

        if (sTmp <> '') then
        repeat
              if (sTmp[1] = '"') then
              begin
                   // this cell delimited by "
                   iPosition := Pos('"',sTmp);
                   Inc(iPosition);
              end
              else
                  // this cell delimited by ,
                  iPosition := Pos(',',sTmp);

              if (iPosition < Length(sTmp))
              and (iPosition > 0) then
              begin
                   if (iPosition = 1) then
                   begin
                        //if (Length(sTmp) > 1) then
                        //   sTmp := Copy(sTmp,2,Length(sTmp))
                        //else
                        //    sTmp := '';
                        sCell := '';

                   end
                   else
                   begin
                        sCell := Copy(sTmp,1,iPosition-1);
                        //if (sTmp
                   end;
              end
              else
                  sCell := sTmp;

              // REMOVE trailing comma if it exists
              if (Length(sCell) > 0) then
                 if (sCell[Length(sCell)] = ',') then
                    sCell := Copy(sCell,1,Length(sCell)-1);

              Inc(iColumn);
              if (iColumn > RowValues.lMaxSize) then
                 RowValues.resize(RowValues.lMaxSize + ARR_STEP_SIZE);
              RowValues.setValue(iColumn,@sCell);

              //end;

              // set sTmp to be the rest of the line - this cell
              if ((iPosition+1) <= Length(sTmp))
              and (iPosition > 0) then
                  sTmp := Copy(sTmp,iPosition+1,Length(sTmp)-iPosition)
              else
                  sTmp := '';

        until (sTmp = '');

        // adjust the size of the array we have just created
        if (iColumn = 0) then
        begin
             RowValues.resize(1);
             RowValues.lMaxSize := 0;
        end
        else
        begin
             if (iColumn <> RowValues.lMaxSize) then
                RowValues.resize(iColumn);
        end;

        // dump the array we have just created to an ascii file with the name of this row
        // DebugDumpRow;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReadRowValues',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


procedure TDestructTestForm.ChangeWorkingDirectory;
begin
     try
        if FileExists(EditWorkingDirectory.Text +
                      '\0\rule2\LoadSiteDestructStatus.csv') then
           ReadSiteFeatureCount(EditWorkingDirectory.Text);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ChangeWorkingDirectory',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TDestructTestForm.ReadSiteFeatureCount(const sWorkingDirectory : string);
var
   SiteFile, FeatureFile : TextFile;
   fEnd : boolean;
begin
     try
        Screen.Cursor := crHourglass;

        iSiteCount := 0;
        iFeatureCount := 0;

        // read the number of sites from the site file
        assignfile(SiteFile,sWorkingDirectory + '\0\rule2\LoadSiteDestructStatus.csv');
        reset(SiteFile);
        readln(SiteFile);
        fEnd := False;
        repeat
              fEnd := Eof(SiteFile);
              readln(SiteFile);
              inc(iSiteCount);
        until fEnd;
        closefile(SiteFile);

        // read the number of sites from the site file
        assignfile(FeatureFile,sWorkingDirectory + '\0\rule2\InitDestroy.csv');
        reset(FeatureFile);
        readln(FeatureFile);
        fEnd := False;
        repeat
              fEnd := Eof(FeatureFile);
              readln(FeatureFile);
              inc(iFeatureCount);
        until fEnd;
        closefile(FeatureFile);

        EditSites.Text := IntToStr(iSiteCount);
        EditFeatures.Text := IntToStr(iFeatureCount);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReadSiteFeatureCount',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TDestructTestForm.ReadDestructRate(const sFilename : string);
var
   InFile : TextFile;
   sLine : string;
   fEnd : boolean;
   iFeatureKey, iPos, iIndex : integer;
   rDestructRate : extended;
begin
     try
        DestructRate := Array_t.Create;
        DestructRate.init(SizeOf(extended),iFeatureCount);

        FeatureKey := Array_t.Create;
        FeatureKey.init(SizeOf(integer),iFeatureCount);

        assignfile(InFile,sFilename);
        reset(InFile);
        readln(InFile);

        fEnd := False;
        iIndex := 0;

        repeat
              fEnd := Eof(InFile);
              readln(InFile,sLine);
              Inc(iIndex);

              // extract destruct rate and feature key from sLine
              // and store it
              iPos := Pos(',',sLine);
              iFeatureKey := StrToInt(Copy(sLine,
                                           1,
                                           iPos-1));
              rDestructRate := StrToFloat(Copy(sLine,
                                               iPos+1,
                                               Length(sLine)-iPos));
              FeatureKey.setValue(iIndex,@iFeatureKey);
              DestructRate.setValue(iIndex,@rDestructRate);

        until fEnd;

        closefile(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReadDestructRate',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TDestructTestForm.ReadDestructStatus(const sFilename : string);
var
   InFile : TextFile;
   sLine, sAllowDestruct : string;
   fEnd, fDestructStatus : boolean;
   iSiteKey, iPos, iIndex : integer;
begin
     try
        DestructStatus := Array_t.Create;
        DestructStatus.init(SizeOf(boolean),iSiteCount);

        assignfile(InFile,sFilename);
        reset(InFile);
        readln(InFile);

        fEnd := False;
        iIndex := 0;

        repeat
              fEnd := Eof(InFile);
              readln(InFile,sLine);
              Inc(iIndex);

              // extract destruct status and site key from sLine
              // and store it
              iPos := Pos(',',sLine);
              iSiteKey := StrToInt(Copy(sLine,
                                        1,
                                        iPos-1));
              sAllowDestruct := Copy(sLine,
                                     iPos+1,
                                     Length(sLine)-iPos);
              if (sAllowDestruct = 'TRUE') then
                 fDestructStatus := True
              else
                  fDestructStatus := False;
              SiteKey.setValue(iIndex,@iSiteKey);
              DestructStatus.setValue(iIndex,@fDestructStatus);

        until fEnd;

        closefile(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReadDestructStatus',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function TDestructTestForm.IsWithinErrorTolerance(const rA, rB : extended) : boolean;
begin
     if (rA <= (rB + rErrorTolerance))
     and (rA >= (rB - rErrorTolerance)) then
         Result := True
     else
         Result := False;
end;

procedure TDestructTestForm.ReadDestructionFile(const sFilename : string);
var
   InFile : TextFile;
   fEnd : boolean;
   iSiteIndex, iFeatureIndex,
   iSiteKey, iFeatureKey, iIndex : integer;
   rOrigArea, rOrigDestruct, rDestructRate, rTestDestructRate,
   rNewArea, rNewDestruct, rDestructAmount,
   rIncDestructAmount : extended;
   sLine, sError : string;
   sCell : str255;

   procedure GetRowValues;
   begin
        RowValues.rtnValue(1,@sCell);
        iSiteKey := StrToInt(sCell);
        RowValues.rtnValue(2,@sCell);
        iFeatureKey := StrToInt(sCell);
        RowValues.rtnValue(3,@sCell);
        rOrigArea := StrToFloat(sCell);
        RowValues.rtnValue(4,@sCell);
        rOrigDestruct := StrToFloat(sCell);
        RowValues.rtnValue(5,@sCell);
        rTestDestructRate := StrToFloat(sCell);
        RowValues.rtnValue(6,@sCell);
        rNewArea := StrToFloat(sCell);
        RowValues.rtnValue(7,@sCell);
        rNewDestruct := StrToFloat(sCell);
   end;

   procedure ReportError(const iError : integer);
   begin
        case iError of
             1 : sError := 'destruct rate'; // error in destruct rate
             2 : sError := 'reduce area'; // error in reduce area
             3 : sError := 'increase destructed'; // error in increase destructed
             4 : sError := 'increase destructed (stored)'; // error in increase destructed (stored)
        end;

        RecordError(sFilename +
                    ' Row ' + IntToStr(iIndex) +
                    ' Error in ' + sError +
                    ' SiteKey ' + IntToStr(iSiteKey) +
                    ' FeatKey ' + IntToStr(iFeatureKey) +
                    ' OrigArea ' + FloatToStr(rOrigArea) +
                    ' OrigDestruct ' + FloatToStr(rOrigDestruct) +
                    ' DestructRate ' + FloatToStr(rTestDestructRate) +
                    ' NewArea ' + FloatToStr(rNewArea) +
                    ' NewDestruct ' + FloatToStr(rNewDestruct));
   end;

begin
     try
        assignfile(InFile,sFilename);
        reset(InFile);
        readln(InFile);

        fEnd := False;
        iIndex := 0;

        repeat
              fEnd := Eof(InFile);
              readln(InFile,sLine);
              Inc(iIndex);

              ReadRowValues(sLine);

              // now process the row values
              try
                 GetRowValues;

              except
                    Screen.Cursor := crDefault;
                    MessageDlg('Exception converting Destruct File ' +
                               sFilename +
                               ' row ' +
                               IntToStr(iIndex),
                               mtError,[mbOk],0);
                    Application.Terminate;
                    Exit;
              end;

              iFeatureIndex := FindIntegerMatch(FeatureLookup,iFeatureKey);
              DestructRate.rtnValue(iFeatureIndex,@rDestructRate);

              // calculate destruct amount for this cell
              rDestructAmount := rOrigArea * rDestructRate / 100;
              if ((rOrigArea - rDestructAmount) <= (rMinimumArea+rErrorTolerance)) then
                 rDestructAmount := rOrigArea;

              if IsWithinErrorTolerance(rDestructRate,rTestDestructRate) then
                 // there is an error if there is a mismatch here
                 ReportError(1);

              if IsWithinErrorTolerance((rOrigArea - rDestructAmount),rNewArea) then
                 // there is an error if there is a mismatch here
                 ReportError(2);

              if IsWithinErrorTolerance((rOrigDestruct + rDestructAmount),rNewDestruct) then
                 // there is an error if there is a mismatch here
                 ReportError(3);

              // increment the destruct amount
              DestructAmount.rtnValue(iFeatureIndex,@rIncDestructAmount);
              rIncDestructAmount := rIncDestructAmount + rDestructAmount;
              DestructAmount.rtnValue(iFeatureIndex,@rIncDestructAmount);

              if IsWithinErrorTolerance(rIncDestructAmount,rNewDestruct) then
                 // there is an error if there is a mismatch here
                 ReportError(4);

        until fEnd;

        closefile(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReadDestructionFile',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TDestructTestForm.ReadTargetFile(const sFilename : string);
var
   InFile : TextFile;
   fEnd : boolean;
   iIndex : integer;
   sLine : string;
begin
     try
        assignfile(InFile,sFilename);
        reset(InFile);
        readln(InFile);
        readln(InFile);

        fEnd := False;
        iIndex := 0;

        repeat
              fEnd := Eof(InFile);
              readln(InFile,sLine);
              Inc(iIndex);

              ReadRowValues(sLine);

              // now process the row values

        until fEnd;

        closefile(InFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReadTargetFile',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TDestructTestForm.InitDestructAmount;
var
   rDestructAmount : extended;
   iCount : integer;
begin
     try
        DestructAmount := Array_t.Create;
        DestructAmount.init(SizeOf(extended),iFeatureCount);
        rDestructAmount := 0;
        for iCount := 1 to iFeatureCount do
            DestructAmount.setValue(iCount,@rDestructAmount);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in InitDestructAmount',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TDestructTestForm.MakeLookupArrays;
begin
     try
        FeatureLookup := SortIntegerArray(FeatureKey);
        SiteLookup := SortIntegerArray(SiteKey);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in MakeLookupArrays',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TDestructTestForm.ExecuteValidation(const sWorkingDirectory : string;
                                              const iValidationType : integer);
var
   sDestructionFile : string;
   iIteration : integer;
begin
     // Execute the validation
     try
        // check that amount destroyed at each cell matches appropriate
        // destruction rate

        // for each iteration
        //   sum amount destroyed for each feature
        //   calculate feature targets and available area based on this
        //     to determine that C-Plan is adjusting them appropriately

        // The directory structure of the validation output looks
        // like this and contains the following files which
        // concern our validation :
        //
        //   working directory\0\rule2\DestroyAvailableFeatures.csv
        //   working directory\0\rule2\InitDestroy.csv
        //   working directory\0\rule2\LoadSiteDestructStatus.csv
        //
        //   working directory\1\rule2\DestroyAvailableFeatures.csv
        //   working directory\1\features1.csv
        //
        //   working directory\2\rule2\DestroyAvailableFeatures.csv
        //   working directory\2\features2.csv
        //
        //   ...
        //
        //   working directory\N-1\rule2\DestroyAvailableFeatures.csv
        //   working directory\N-1\featuresN-1.csv
        //
        //   working directory\N\featuresN.csv
        //
        // where we have N iterations.
        //
        // DestroyAvailableFeatures.csv is generated for iterations
        // 0 to N-1 (iteration 0 has starting values)
        // and contains fields :
        //    SiteKey                     key of site
        //    FeatureKey                  key of feature
        //    orig featurearea            area before destruction
        //    orig DestructArea           total destructed before destruction
        //    DestructRate                rate of destruction
        //    new DestructArea            total destructed after destruction
        //    new featurearea             area after destruction
        //
        // InitDestroy.csv is generated for iteration 0 (starting values)
        // and contains fields :
        //    FeatureKey                  key of feature
        //    DestructRate                rate of destruction
        //
        // LoadSiteDestructStatus.csv is generated for iteration 0
        // (starting values) and contains fields :
        //    SiteKey                     key of site
        //    AllowDestruct               boolean, allow destruction
        //
        // featuresX.csv is generated for each iteration (X = 1 to N)
        // and contains fields :
        // NOTE : first row of this file must be skipped
        //    Feature Name
        //    Feature Key                 key of feature
        //    Initial Reserved
        //    Initial Av.
        //    Extant
        //    Total in Database           total area
        //    Original Target
        //    Initial Achievable Target
        //    Original Target (%)
        //    Initial Available Target    initial target in available area
        //    Proposed Reserved           current amount selected
        //    Excluded
        //    Available                   current available amount
        //    Available Target            current target in available area
        //    % Original Target Met
        //    % Initial Achievable Target Met
        //    % Original Target (%) Met
        //    % Initial Available Target Met
        //    Feature In Use
        //    Mandatory Reserve
        //    Negotiated Reserve
        //    Partial Reserve
        //    Vulnerability
        //
        Screen.Cursor := crHourglass;

        iErrorCount := 0;
        sErrorFile := EditWorkingDirectory.Text +
                      '\ErrorLog.txt';

        fRowValuesCreated := False;
        InitDestructAmount;
        ReadDestructStatus(EditWorkingDirectory.Text +
                           '\0\rule2\LoadSiteDestructStatus.csv');
        ReadDestructRate(EditWorkingDirectory.Text +
                         '\0\rule2\InitDestroy.csv');
        MakeLookupArrays;

        try
           rMinimumArea := StrToFloat(EditMinimumArea.Text);
        except
              rMinimumArea := 0.2;
        end;

        iIteration := 0;
        sDestructionFile := EditWorkingDirectory.Text +
                            '\0\rule2\DestroyAvailableFeatures.csv';

        while FileExists(sDestructionFile) do
        begin
             ReadDestructionFile(sDestructionFile);

             Inc(iIteration);

             ReadTargetFile(EditWorkingDirectory.Text +
                            '\' +
                            IntToStr(iIteration) +
                            '\features' +
                            IntToStr(iIteration) +
                            '.csv');

             sDestructionFile := EditWorkingDirectory.Text +
                                 '\' +
                                 IntToStr(iIteration) +
                                 '\rule2\DestroyAvailableFeatures.csv';
        end;

        DestructStatus.Destroy;
        DestructRate.Destroy;
        FeatureKey.Destroy;
        SiteKey.Destroy;
        FeatureLookup.Destroy;
        SiteLookup.Destroy;
        RowValues.Destroy;

        Screen.Cursor := crDefault;

        if (iErrorCount > 0) then
           MessageDlg(IntToStr(iErrorCount) +
                      ' errors were encountered and reported to ' +
                      sErrorFile,
                      mtInformation,[mbOk],0);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ExecuteValidation',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TDestructTestForm.btnExecuteClick(Sender: TObject);
begin
     // Execute the validation
     if FileExists(EditWorkingDirectory.Text +
                      '\0\rule2\LoadSiteDestructStatus.csv') then
     begin
          try
             rErrorTolerance := StrToFloat(ErrorTolerance.Text);
          except
                rErrorTolerance := 0.01;
          end;
          ExecuteValidation(EditWorkingDirectory.Text,
                            RadioValidateType.ItemIndex);
     end
     else
         MessageDlg('The specified working directory does not contain' + Chr(10) + Chr(13) +
                    'destruction validation output',mtInformation,[mbOk],0);
end;

procedure TDestructTestForm.btnBrowseClick(Sender: TObject);
begin
     try
        BrowseDirForm := TBrowseDirForm.Create(Application);
        BrowseDirForm.DirectoryListBox1.Directory := EditWorkingDirectory.Text;
        BrowseDirForm.SpeedButton1.Visible := False;
        if (BrowseDirForm.ShowModal = mrOk) then
           EditWorkingDirectory.Text := BrowseDirForm.DirectoryListBox1.Directory;
        BrowseDirForm.Free;

     except
           MessageDlg('Exception in Browse working directory',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TDestructTestForm.EditWorkingDirectoryChange(Sender: TObject);
begin
     ChangeWorkingDirectory;
end;

end.
