unit destanal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TDestructAnalyseForm = class(TForm)
    RadioProcedure: TRadioGroup;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    ComboTable: TComboBox;
    Label1: TLabel;
    MSTBox: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure BitBtnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DestructAnalyseForm: TDestructAnalyseForm;

implementation

uses MAIN, Childwin, hotspots_accumulation;

{$R *.DFM}

procedure TDestructAnalyseForm.FormCreate(Sender: TObject);
var
   iCount : integer;
begin
     with SCPForm do
          if (MDIChildCount > 0) then
          begin
               for iCount := 0 to (MDIChildCount-1) do
               begin
                    ComboTable.Items.Add(MDIChildren[iCount].Caption);
               end;
               ComboTable.Text := ComboTable.Items.Strings[0];
          end;
end;

procedure GetDestructFileValues(const sScenario : string;
                                var rVal1, rVal2, rVal3 : extended);
var
   AChild : TMDIChild;
begin
     // open the table sScenario\AreaDestroyed.csv
     AChild := LoadChildHandle(sScenario + '\AreaDestroyed_.csv');

     // extract the 3 values from relevant cells
     // row 2 (1 based)
     // columns 2, 51, 101 (1 based)
     rVal1 := StrToFloat(AChild.aGrid.Cells[1,1]);
     rVal2 := StrToFloat(AChild.aGrid.Cells[50,1]);
     rVal3 := StrToFloat(AChild.aGrid.Cells[100,1]);

     // close the table
     AChild.Free;
end;

function GetMstName(const sPath : string) : string;
var
   iCount : integer;
begin
     iCount := 11;
     Result := '';
     repeat
           Dec(iCount);
           if fileexists(sPath + '\minset' + IntToStr(iCount) + '.mst') then
              Result := sPath + '\minset' + IntToStr(iCount) + '.mst';

     until (iCount = 0) or (Result <> '');
end;

procedure LowerCaseListBox(ABox : TListBox);
var
   iCount : integer;
   sLine : string;
begin
     // change each line in the list box to lower case
     if (ABox.Items.Count > 0) then
        for iCount := (ABox.Items.Count-1) downto 0 do
        begin
             sLine := LowerCase(ABox.Items.Strings[iCount]);
             ABox.Items.Strings[iCount] := sLine;
        end;
end;

function Boolean2String(const fBool : boolean) : string;
begin
     if fBool then
        Result := 'True'
     else
         Result := 'False';
end;

function rtnSensitivityID(const sPath : string) : string;
var
   sLowerCasePath : string;

   function ReadTargetParameter : string;
   begin
        Result := 'T1';
        if (Pos('half_tgt',sLowerCasePath) > 0) then
           Result := 'T1/2';
        if (Pos('orig_tgt',sLowerCasePath) > 0) then
           Result := 'T1';
        if (Pos('dbl_tgt',sLowerCasePath) > 0) then
           Result := 'T2';
   end;
   function ReadReserveParameter : string;
   begin
        Result := 'R1';
        if (Pos('half_res',sLowerCasePath) > 0) then
           Result := 'R1/2';
        if (Pos('orig_res',sLowerCasePath) > 0) then
           Result := 'R1';
        if (Pos('dbl_res',sLowerCasePath) > 0) then
           Result := 'R2';
   end;
   function ReadDestructRateParameter : string;
   begin
        Result := 'D1';
        if (Pos('\half_dest\',sLowerCasePath) > 0) then
           Result := 'D1/2';
        if (Pos('\orig_dest\',sLowerCasePath) > 0) then
           Result := 'D1';
        if (Pos('\dbl_dest\',sLowerCasePath) > 0) then
           Result := 'D2';
   end;
begin
     sLowerCasePath := lowercase(sPath);
     Result := ReadDestructRateParameter + ' ' + ReadTargetParameter + ' ' + ReadReserveParameter;
end;

function ComparePathToMSTFile(const sPath : string;
                              var sResult : string) : boolean;
var
   sMstFile, sMstTarg, sPathTarg, sMstRes, sPathRes, sMstDest, sPathDest, sMstComp, sPathComp,
   sMstVuln, sPathVuln, sMstVar, sPathVar, sMstDestRate, sPathDestRate, sOtherMstParam, sLowerCasePath
    : string ; // deduce this filename from sPath, it will be minset0.mst, minset1.mst, etc
   rVal1, rVal2, rVal3 : extended;
// returns true if path parameters match mst parameters
// returns false if a mismatch in parameters
//   (also generates detail file for any false results)
   procedure ReadTargetParameter;
   begin
        // read target parameter
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('targetfield=half_tgt') > 0) then
           // mst says half target
           sMstTarg := 'half';
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('targetfield=itarget') > 0) then
           // mst says original target
           sMstTarg := 'orig';
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('targetfield=dbl_tgt') > 0) then
           // mst says double target
           sMstTarg := 'dbl';
        if (Pos('half_tgt',sLowerCasePath) > 0) then
           // path says half target
           sPathTarg := 'half';
        if (Pos('orig_tgt',sLowerCasePath) > 0) then
           // path says orig target
           sPathTarg := 'orig';
        if (Pos('dbl_tgt',sLowerCasePath) > 0) then
           // path says dbl target
           sPathTarg := 'dbl';
   end;
   procedure ReadReserveParameter;
   begin
        // read reserve parameter
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('selectionsperdestruction=9') > 0) then
           // mst says half reserve
           sMstRes := 'half';
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('selectionsperdestruction=19') > 0) then
           // mst says orig reserve
           sMstRes := 'orig';
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('selectionsperdestruction=38') > 0) then
           // mst says dbl reserve
           sMstRes := 'dbl';
        if (Pos('half_res',sLowerCasePath) > 0) then
           // path says half res
           sPathRes := 'half';
        if (Pos('orig_res',sLowerCasePath) > 0) then
           // path says orig res
           sPathRes := 'orig';
        if (Pos('dbl_res',sLowerCasePath) > 0) then
           // path says dbl res
           sPathRes := 'dbl';
   end;
   procedure ReadDestructParameter;
   begin
        // read destruct parameter
        //\d1\ ~ EnableDestruction=Yes
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('enabledestruction=yes') > 0) then
           // mst says destruct on
           sMstDest := 'on';
        if (Pos('\d1\',sLowerCasePath) > 0) then
           // path says destruct on
           sPathDest := 'on';
   end;
   procedure ReadComplementarityParameter;
   begin
        // read complementarity parameter
        //\c0\ ~ Complementarity=No  \c1\ ~ Complementarity=Yes
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('complementarity=yes') > 0) then
           // mst says complementarity on
           sMstComp := 'on';
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('complementarity=no') > 0) then
           // mst says complementarity off
           sMstComp := 'off';
        if (Pos('\c1\',sLowerCasePath) > 0) then
           // path says complementarity on
           sPathComp := 'on';
        if (Pos('\c0\',sLowerCasePath) > 0) then
           // path says complementarity off
           sPathComp := 'off';
   end;
   procedure ReadVulnerabilityParameter;
   begin
        // read vulnerability parameter
        //\1v0\ ~ Vulnerability=No
        //\2vm\ Vulnerability=Normalise with Maximum
        //\3vw\ Normalise with Weighted Average
        //\4vr\ Restrict to Maximum 50%
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('vulnerability=no') > 0) then
           // mst says vulnerability no
           sMstVuln := 'no';
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('vulnerability=normalise with maximum') > 0) then
           // mst says vulnerability max
           sMstVuln := 'max';
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('vulnerability=normalise with weighted average') > 0) then
           // mst says vulnerability wav
           sMstVuln := 'wav';
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('vulnerability=restrict to maximum 50%') > 0) then
           // mst says vulnerability restrict
           sMstVuln := 'restrict';
        if (Pos('\1v0\',sLowerCasePath) > 0) then
           // path says vulnerability no
           sPathVuln := 'no';
        if (Pos('\2vm\',sLowerCasePath) > 0) then
           // path says vulnerability max
           sPathVuln := 'max';
        if (Pos('\3vw\',sLowerCasePath) > 0) then
           // path says vulnerability wav
           sPathVuln := 'wav';
        if (Pos('\4vr\',sLowerCasePath) > 0) then
           // path says vulnerability restrict
           sPathVuln := 'restrict';
   end;
   procedure ReadVariableParameter;
   begin
        // read variable parameter
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('1. richness') > 0) then
           sMstVar := 'ri';
        if (Pos('\1ri',sLowerCasePath) > 0) then
           sPathVar := 'ri';
        // 1. richness
        // \1ri
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('1. feature rarity') > 0) then
           sMstVar := 'mr';
        if (Pos('\2fr',sLowerCasePath) > 0) then
           sPathVar := 'mr';
        // 1. feature rarity
        // \2mr
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('1. summed rarity') > 0) then
           sMstVar := 'sr';
        if (Pos('\3sr',sLowerCasePath) > 0) then
           sPathVar := 'sr';
        // 1. summed rarity
        // \3sr
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('1. weighted %target') > 0) then
           sMstVar := 'wt';
        if (Pos('\4wt',sLowerCasePath) > 0) then
           sPathVar := 'wt';
        //
        // \4wt
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('1. select irrepl highest') > 0) then
           sMstVar := 'ir';
        if (Pos('\5ir',sLowerCasePath) > 0) then
           sPathVar := 'ir';
        // 1. Select IRREPL Highest
        // \5ir
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('1. select sumirr highest') > 0) then
           sMstVar := 'si';
        if (Pos('\6si',sLowerCasePath) > 0) then
           sPathVar := 'si';
        // 1. Select SUMIRR Highest
        // \6si
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('1. select one highest') > 0) then
           sMstVar := 'vuln';
        if (Pos('\7one',sLowerCasePath) > 0) then
           sPathVar := 'vuln';
        // 1. Select ONE Highest
        // \7one
   end;
   procedure ReadDestructRateParameter;
   begin
        // read destruct rate parameter
        GetDestructFileValues(sPath,rVal1,rVal2,rVal3);
        if (Pos('\half_dest\',sLowerCasePath) > 0) then
           sPathDestRate := 'half';
        if (Pos('\orig_dest\',sLowerCasePath) > 0) then
           sPathDestRate := 'orig';
        if (Pos('\dbl_dest\',sLowerCasePath) > 0) then
           sPathDestRate := 'dbl';
        // feature 1
        if (rVal1 > 2.5) and (rVal1 < 3.5) then
           sMstDestRate := 'half';
        if (rVal1 > 3.5) and (rVal1 < 4.5) then
           sMstDestRate := 'orig';
        if (rVal1 > 6) and (rVal1 < 7) then
           sMstDestRate := 'dbl';
        // feature 50
        if (rVal2 > 3.5) and (rVal2 < 4.5) then
           sMstDestRate := 'half';
        if (rVal2 > 5.5) and (rVal2 < 6.5) then
           sMstDestRate := 'orig';
        if (rVal2 > 10) and (rVal2 < 11) then
           sMstDestRate := 'dbl';
        // feature 100
        if (rVal3 > 1) and (rVal3 < 2) then
           sMstDestRate := 'half';
        if (rVal3 > 2.5) and (rVal3 < 3.5) then
           sMstDestRate := 'orig';
        if (rVal3 > 5) and (rVal3 < 6) then
           sMstDestRate := 'dbl';
   end;
   procedure ReadStaticParameters;
   begin
        // check mst parameters that are the same for every minset run
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('startingcondition=use selected sites') = -1) then
        begin
             Result := False;
             sOtherMstParam := sOtherMstParam + 'StartingCondition=use selected sites_';
        end;
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('stoppingcondition=all features satisfied') = -1) then
        begin
             Result := False;
             sOtherMstParam := sOtherMstParam + 'StoppingCondition=All Features Satisfied_';
        end;
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('selectionsperiteration=1') = -1) then
        begin
             Result := False;
             sOtherMstParam := sOtherMstParam + 'SelectionsPerIteration=1_';
        end;
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('resourcelimit=none') = -1) then
        begin
             Result := False;
             sOtherMstParam := sOtherMstParam + 'ResourceLimit=None_';
        end;
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('redundancycheck=no') = -1) then
        begin
             Result := False;
             sOtherMstParam := sOtherMstParam + 'RedundancyCheck=No_';
        end;
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('redundancycheckorder=no') = -1) then
        begin
             Result := False;
             sOtherMstParam := sOtherMstParam + 'RedundancyCheckOrder=No_';
        end;
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('redundancycheckexclude=no') = -1) then
        begin
             Result := False;
             sOtherMstParam := sOtherMstParam + 'RedundancyCheckExclude=No_';
        end;
        if (DestructAnalyseForm.MSTBox.Items.IndexOf('redundancycheckend=no') = -1) then
        begin
             Result := False;
             sOtherMstParam := sOtherMstParam + 'RedundancyCheckEnd=No_';
        end;
   end;
begin
     // sample path : D:\hotspots_output\Par01856\040601\dbl_dest\DBL_TGT\half_res\d1\c0\1v0\1ri
     //
     // corresponding mst file :
     { [Minset Specification]
       WorkingDirectory=D:\hotspots_output\040601\dbl_dest\DBL_TGT\half_res\d1\c0\1v0\1ri
       Date=Wednesday, June 27, 2001
       Time=05:32 AM
       TargetField=DBL_TGT
       StartingCondition=use selected sites
       StoppingCondition=All Features Satisfied
       SelectionsPerIteration=1
       ResourceLimit=None
       ReportSites=No
       ReportFeatures=No
       ReportProposedReserve=No
       ReportHotspotsFeatures=Yes
       IterationsToValidateFile=D:\hotspots_output\040601\dbl_dest\HALF_TGT\orig_res\d1\c0\1v0\1ri\IterationsToValidate.csv
       EnableDestruction=Yes
       SelectionsPerDestruction=9
       Complementarity=No
       Vulnerability=No
       RedundancyCheck=No
       RedundancyCheckOrder=No
       RedundancyCheckExclude=No
       RedundancyCheckEnd=No

       [Rule List]
       1. richness
       2. Select First Sites
       }
     // NOTE : in this example, there is an error in reserve parameter
     //
     // parameters are : destruct multiplier         - check values in \AreaDestroyed.csv  SEE detecting_destruct_rates_080102.txt
     //                  target                      - half_tgt ~ TargetField=HALF_TGT  orig_tgt ~ TargetField=ITARGET  dbl_tgt ~ TargetField=DBL_TGT
     //                  reserve                     - half_res ~ SelectionsPerDestruction=9  orig_res ~ SelectionsPerDestruction=19  dbl_res ~ SelectionsPerDestruction=38
     //                  destruct on or off          - \d1\ ~ EnableDestruction=Yes
     //                  complementarity on or off   - \c0\ ~ Complementarity=No  \c1\ ~ Complementarity=Yes
     //                  vulnerability (4 settings)  - \1v0\ ~ Vulnerability=No  \2vm\  \3vw\  \4vr\
     //                  variable (8 settings)       -
     //                      (only 7 implemented, process the single null run manually)
     // also need to check :  StartingCondition=use selected sites
     //                       StoppingCondition=All Features Satisfied
     //                       SelectionsPerIteration=1
     //                       ResourceLimit=None
     //                       RedundancyCheck=No
     //                       RedundancyCheckOrder=No
     //                       RedundancyCheckExclude=No
     //                       RedundancyCheckEnd=No
     //

     Result := True;
     sMstTarg := '';
     sPathTarg := 'orig';
     sMstRes := '';
     sPathRes := 'orig';
     sMstDest := '';
     sPathDest := '';
     sMstComp := '';
     sPathComp := '';
     sMstVuln := '';
     sPathVuln := '';
     sMstVar := '';
     sPathVar := '';
     sMstDestRate := '';
     sPathDestRate := 'orig';
     sOtherMstParam := '';

     sLowerCasePath := LowerCase(sPath);
     // load the .mst file into a listbox control
     sMstFile := GetMstName(sPath);
     DestructAnalyseForm.MSTBox.Items.Clear;
     DestructAnalyseForm.MSTBox.Items.LoadFromFile(sMstFile);
     // make all characters in the list box lowercase
     LowerCaseListBox(DestructAnalyseForm.MSTBox);
     // compare each of the parameters
     // if they don't match
     //   result false
     //   detail mismatch

     // derive the actual and intended parameters for the scenario
     ReadTargetParameter;
     ReadReserveParameter;
     ReadDestructParameter;
     ReadComplementarityParameter;
     ReadVulnerabilityParameter;
     ReadVariableParameter;
     ReadDestructRateParameter;
     ReadStaticParameters;

     // now check if parameters are correct
     if (sMstTarg <> sPathTarg)
     or (sMstRes <> sPathRes)
     or (sMstDest <> sPathDest)
     or (sMstComp <> sPathComp)
     or (sMstVuln <> sPathVuln)
     or (sMstVar <> sPathVar)
     or (sMstDestRate <> sPathDestRate) then
        Result := False;

     sResult := sPath + ',' +
                sMstFile + ',' +
                sMstTarg + ',' +
                sPathTarg + ',' +
                sMstRes + ',' +
                sPathRes + ',' +
                sMstDest + ',' +
                sPathDest + ',' +
                sMstComp + ',' +
                sPathComp + ',' +
                sMstVuln + ',' +
                sPathVuln + ',' +
                sMstVar + ',' +
                sPathVar + ',' +
                sMstDestRate + ',' +
                sPathDestRate + ',' +
                sOtherMstParam + ',' +
                Boolean2String(Result);
end;

function GetLastCycleNumber(const sScenario : string) : integer;
var
   AChild : TMDIChild;
begin
     try
        AChild := LoadChildHandle(sScenario + '\AreaDestroyed_.csv');
        Result := AChild.SpinRow.Value - 1;
        AChild.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetLastCycleNumber',mtError,[mbOk],0);
     end;
end;

procedure ExtractCycle(const sBaseDir, sScenario : string;
                       const iCycle : integer;
                       var sLine : string);
var
   RetentionChild : TMDIChild;
   iCount : integer;
   rExtant, rTarget, rDestroyed : extended;
begin
     try
        // load the file for this run
        // Retention.csv
        RetentionChild := LoadChildHandle(sScenario + '\Retention.csv');
        sLine := '';
        // extract cycle iCycle from this file
        for iCount := 1 to (RetentionChild.aGrid.ColCount - 1) do
        begin
             sLine := sLine + ',' + RetentionChild.aGrid.Cells[iCount,iCycle];
        end;
        RetentionChild.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ExtractCycle',mtError,[mbOk],0);
     end;
end;

procedure HotspotsParse(const iProcedure : integer;
                        const sTable, sBaseDir : string);
var
   AChild : TMDIChild;
   sPath : string;
   iTable, iEndpoint, iComplementarity, iVulnerability, iVariable, iParamErrors,
   iScenario, iCycleNumber, iCount : integer;
   Destruction, Complementarity, BobCO : array [1..2] of string[2];
   Vulnerability, BobVU : array [1..4] of string[3];
   Variable, BobVA : array [1..8] of string[4];
   sScenario, sLine, sRetention, sBobID, sMattID, sSensitivityID : string;
   OutFile : TextFile;
// author : Matt
// date : 22 December 2001
// method : loop through each path in sTable
//            loop through each run in each path
//              do requested operation on the run and collate the results
//          present summarised results to user
begin
     try
        // each row is sTable contains :
        //    column 1 = path
        //    column 2 = endpoint
        // column 2 is only used when iProcedure = 2
        //
        // each path contains a set of hotspots output files
        //
        if (iProcedure = 0) then
        begin
             assignfile(OutFile,sBaseDir + '\parameter_summary.csv');
             rewrite(OutFile);
             writeln(OutFile,'scenario,BobID,MattID,SensitivityID,Path,MstFile,MstTarg,PathTarg,MstRes,PathRes,MstDest,PathDest,MstComp,PathComp,' +
                             'MstVuln,PathVuln,MstVar,PathVar,MstDestRate,PathDestRate,OtherMstParam,Correct');
        end;
        if (iProcedure = 1) then
        begin
             assignfile(OutFile,sBaseDir + '\extract_endpoints.csv');
             rewrite(OutFile);
             writeln(OutFile,'scenario,BobID,MattID,SensitivityID,Path,Endpoint');
        end;
        if (iProcedure = 2) then
        begin
             assignfile(OutFile,sBaseDir + '\extract_retention.csv');
             rewrite(OutFile);
             sLine := 'scenario,BobID,MattID,SensitivityID,Path,Endpoint';
             for iCount := 1 to 107 do
                 sLine := sLine + ',' + IntToStr(iCount);
             writeln(OutFile,sLine);
        end;
        iParamErrors := 0;
        iScenario := 0;

        AChild := SCPForm.rtnChild(sTable);

        if (AChild = nil) then
        begin
             MessageDlg('Specify a table containing path,endpoint and try again',
                        mtInformation,[mbOk],0);

             //ModalResult := mrNone;
        end
        else
        begin
             Destruction[1] := 'D0';
             Destruction[2] := 'D1';
             Complementarity[1] := 'C0';
             Complementarity[2] := 'C1';
             BobCO[1] := '';
             BobCO[2] := 'C';
             Vulnerability[1] := '1v0';
             Vulnerability[2] := '2vm';
             Vulnerability[3] := '3vw';
             Vulnerability[4] := '4vr';
             BobVU[1] := '';
             BobVU[2] := 'Vm';
             BobVU[3] := 'Vw';
             BobVU[4] := 'Vr';
             Variable[1] := '1ri';
             Variable[2] := '2fr';
             Variable[3] := '3sr';
             Variable[4] := '4wt';
             Variable[5] := '5ir';
             Variable[6] := '6si';
             Variable[7] := '7one';
             Variable[8] := 'null';
             BobVA[1] := 'Ri';
             BobVA[2] := 'Fr';
             BobVA[3] := 'Sr';
             BobVA[4] := 'Wt';
             BobVA[5] := 'Ir';
             BobVA[6] := 'Si';
             BobVA[7] := '';
             BobVA[8] := 'null';


             // loop through each path
             for iTable := 1 to (AChild.aGrid.RowCount-1) do
             begin
                  sPath := AChild.aGrid.Cells[0,iTable];
                  if (iProcedure = 2) then
                     iEndpoint := StrToInt(AChild.aGrid.Cells[1,iTable]);

                  // loop through each run in the current path
                  for iComplementarity := 1 to 2 do
                      for iVulnerability := 1 to 4 do
                          for iVariable := 1 to 8 do
                          begin
                               sScenario := sPath + '\' +
                                            Destruction[2] + '\' +
                                            Complementarity[iComplementarity] + '\' +
                                            Vulnerability[iVulnerability] + '\' +
                                            Variable[iVariable];

                               sBobID := BobCO[iComplementarity] + BobVU[iVulnerability] + BobVA[iVariable];
                               sMattID := Destruction[2] + '\' +
                                          Complementarity[iComplementarity] + '\' +
                                          Vulnerability[iVulnerability] + '\' +
                                          Variable[iVariable];
                               sSensitivityID := rtnSensitivityID(sPath);

                               if fileexists(sScenario + '\hotspots_feature1.csv') then
                               begin
                                    // add this run to the summary list
                                    Inc(iScenario);
                                    // do requested operation on the current run dependant on iProcedure
                                    //    0  test .mst parameters
                                    //    1  extract endpoints
                                    //    2  extract retention
                                    case iProcedure of
                                         0 : begin
                                                  if not ComparePathToMSTFile(sScenario,sLine) then
                                                     // there is an error in the parameters for this run
                                                     Inc(iParamErrors);
                                                  writeln(OutFile,IntToStr(iScenario) + ',' + sBobID + ',' + sMattId + ',' + sSensitivityId + ',' + sLine);
                                             end;
                                         1 : begin
                                                  iCycleNumber := GetLastCycleNumber(sScenario);
                                                  writeln(OutFile,IntToStr(iScenario) + ',' + sBobID + ',' + sMattId + ',' + sSensitivityId + ',' + sScenario + ',' + IntToStr(iCycleNumber));
                                             end;
                                         2 : begin
                                                  // extract the retention vector for this cycle
                                                  ExtractCycle(sBaseDir,sScenario,iEndpoint,sLine);
                                                  writeln(OutFile,IntToStr(iScenario) + ',' + sBobID + ',' + sMattId + ',' + sSensitivityId + ',' + sScenario + ',' + IntToStr(iEndpoint) + sLine);
                                             end;
                                    end;
                               end;
                          end;
             end;
        end;

        closefile(OutFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in HotspotsParse on table ' + sTable,
                      mtError,[mbOk],0);
     end;
end;

procedure TDestructAnalyseForm.BitBtnOkClick(Sender: TObject);
var
   sBaseDir : string;
begin
     try
        Screen.Cursor := crHourglass;
        // the path containing the input table is where output files are created
        sBaseDir := ExtractFilePath(ComboTable.Text);
        HotspotsParse(RadioProcedure.ItemIndex,ComboTable.Text,sBaseDir);
        Screen.Cursor := crDefault;
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Analyse Hotspots',
                      mtError,[mbOk],0);
     end;
end;

end.
