unit override_combsize;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons,
  ds;

type
  TOverrideCombsizeForm = class(TForm)
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    Label1: TLabel;
    Memo1: TMemo;
    EditInputFile: TEdit;
    OpenDialog1: TOpenDialog;
    CheckDumpOutfile: TCheckBox;
    CheckDumpValidate: TCheckBox;
    procedure OverrideCombinationSize(const sInputFile : string;
                                      const fCreateOutfile,
                                            fCreateValidate : boolean);
    procedure ReadInputValues(const sInputFile : string;
                              var fFeatTargetRead, fFeatNumAvSitesRead : boolean;
                              const fDebug : boolean);
    procedure BitBtnOkClick(Sender: TObject);
    procedure EditInputFileClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    InputTarget, InputNumSites : Array_t;
    fFeatTargetRead, fFeatNumAvSitesRead,
    fCreateCombsizeOutputFile : boolean;
    CombsizeOutputFile : TextFile;
    iMinimumNumberSpecified : integer;
  end;

var
  OverrideCombsizeForm: TOverrideCombsizeForm;

procedure DumpAverageSiteValues(const sFilename : string);
function GetDelimitedAsciiElement(const sLine, sDelimiter : string;
                                  const iColumn : integer) : string;

implementation

uses
    FileCtrl,
    control, options, global, sf_irrep, validate,
    pred_sf4;

{$R *.DFM}

procedure DumpAverageSiteValues(const sFilename : string);
var
   OutputFile : TextFile;
   rAverageSite, rAverageInitialSite : extended;
   iCount : integer;
begin
     assignfile(OutputFile,sFilename);
     rewrite(OutputFile);
     writeln(OutputFile,'FeatKey,AverageSite,AverageInitialSite');

     for iCount := 1 to iFeatureCount do
     begin
          AverageSite.rtnValue(iCount,@rAverageSite);
          AverageInitialSite.rtnValue(iCount,@rAverageInitialSite);
          writeln(OutputFile,IntToStr(iCount) + ',' +
                             FloatToStr(rAverageSite) + ',' +
                             FloatToStr(rAverageInitialSite));
     end;

     closefile(OutputFile);
end;

function override_comb_predict_sf3 (const FArr : Array_T;
                                    var ReprArr : Array_T;
                                    const {iNumFeat,} iSpaceToTest : integer;
                                    const fDebug, fPartialDebug : boolean;
                                    const CombinationSizeCondition : CombinationSizeCondition_T) : extended;
label
   skip1,skip2;
var
   mean_site,sd,z,area_site,area2_site,sumarea,sumarea2,mean_target,
   combadj : extended;

   AFeat : featureoccurrence;
   ARepr : Repr;

   eAverageSite : extended;
   fPointFeatures : boolean;
   iCount : integer;
   rTarget,
   rTmp : extended;
   DbgFile : text;
   iNumberAvailable,
   iFeatNumAvSites : integer;
begin
     try
        if fDebug then
        begin
             {create debug file}
             assign(DbgFile,ControlRes^.sWorkingDirectory + '\comb' + IntToStr(combsize.iActiveCombinationSize) + '_sf3.csv');
             rewrite(DbgFile);
             {write feature code as first column
              write variable names as names of other columns}

             write(DbgFile,'Feature Code,Original Effective Target,area_site,area2_site,sumarea,sumarea2,');
             writeln(DbgFile,'mean_site,irr_feature,repr_include,repr_exclude');
        end;

        for iCount := 1 to iFeatureCount do
        begin
             // call init_irr_variables here if we are overriding NumAvSites
             iNumberAvailable := ControlForm.Available.Items.Count + ControlForm.Flagged.Items.Count;
             iAvailableSiteCount := iNumberAvailable;
             if OverrideCombsizeForm.fFeatNumAvSitesRead then
             begin
                  OverrideCombsizeForm.InputNumSites.rtnValue(iCount,@iFeatNumAvSites);
                  iNumberAvailable := iFeatNumAvSites;
                  iAvailableSiteCount := iNumberAvailable;
                  init_irr_variables(combsize.iActiveCombinationSize,iFeatNumAvSites);
             end;
             case CombinationSizeCondition of
                  Startup,
                  ExclusionChange,
                  TargetChange,
                  UserLoadLog,
                  OverrideChange : AverageInitialSite.rtnValue(iCount,@eAverageSite);
             else
                 AverageSite.rtnValue(iCount,@eAverageSite);
             end;

             try
                area_site:= eAverageSite;

                FArr.rtnValue(iCount,@AFeat);

                case CombinationSizeCondition of
                     OverrideChange,
                     Startup,
                     ExclusionChange,
                     TargetChange,
                     UserLoadLog :
                     begin
                          // we may have to take exclusions into account
                          if (AFeat.rInitialAvailable - AFeat.rExcluded) < AFeat.rInitialAvailableTarget then
                             rTarget := AFeat.rInitialAvailable - AFeat.rExcluded
                          else
                              rTarget := AFeat.rInitialAvailableTarget;

                          if OverrideCombsizeForm.fFeatNumAvSitesRead then
                          begin
                               OverrideCombsizeForm.InputTarget.rtnValue(iCount,@rTarget);
                          end;
                     end;
                else
                    rTarget := AFeat.targetarea;
                    // This case applies to MinsetLoadLog & TriggerTargetCannotBeMet & TriggerZeroAvSumirr
                end;

                if ControlRes^.fPointFeaturesSpecified then
                   PointFeatures.rtnValue(iCount,@fPointFeatures)
                else
                    fPointFeatures := False;
                    
                if fPointFeatures then
                   rTarget := 0;
                  // This is a point feature so we must ignore it for the purposes of combination size.
                  // This is equivalent to temporarily setting the target to zero.

                area2_site:=sqr(area_site);

             except
                   area_site := 0;
                   area2_site := 0;
             end;

             ReprArr.rtnValue(iCount,@ARepr);

             if (rTarget <= 0) then
             begin
                  ARepr.repr_exclude := 1;
                  ARepr.repr_include := 1;
                  sumarea := 0;
                  sumarea2 := 0;
                  mean_site := 0;

                  goto skip2;
             end;

             sumarea:=(AFeat.rSumArea-area_site)*mult;
             sumarea2:=(AFeat.rAreaSqr-area2_site)*mult;
             mean_site:=sumarea/iNumberAvailable;
             if (combsize.iActiveCombinationSize-1) > (iNumberAvailable-1)/2.0 then
                combadj:=sqrt((iNumberAvailable-1)-(combsize.iActiveCombinationSize-1))/(combsize.iActiveCombinationSize-1)
             else
                combadj:=sqrt(combsize.iActiveCombinationSize-1)/(combsize.iActiveCombinationSize-1);
             try
                rTmp := (sumarea2-(sqr(sumarea) / iNumberAvailable)) / iNumberAvailable;

                if (rTmp >= 0) then
                   rTmp := sqrt(rTmp)
                else
                    rTmp := 0;
                sd := rTmp * combadj;

             except on EInvalidOp do
                    sd := 0;
             end;
             mean_target:=rTarget/(combsize.iActiveCombinationSize-1);

             if sd < 0.00000000001 then
             begin
                if mean_site < mean_target then
                   ARepr.repr_exclude:=0
                else
                   ARepr.repr_exclude:=1;
             end
             else
             begin
                z:=(mean_target-mean_site)/sd;
                ARepr.repr_exclude:=zprob(z);
             end;
     skip1:
             if area_site >= rTarget then
             begin
                ARepr.repr_include:=1;
                goto skip2;
             end;
             mean_target:=(rTarget-area_site)/(combsize.iActiveCombinationSize-1);
             if sd < 0.00000000001 then
             begin
                if mean_site < mean_target then
                begin
                     ARepr.repr_include:=0;
                end
                else
                   ARepr.repr_include:=1;
             end
             else
             begin
                z:=(mean_target-mean_site)/sd;
                if z>35 then
                begin
                     ARepr.repr_include:=0;
                end
                else
                    ARepr.repr_include:=zprob(z);
             end;
     skip2:
             if (ARepr.repr_include = 0) and (area_site > 0) then
                ARepr.irr_feature:=1
             else
                ARepr.irr_feature:=(ARepr.repr_include-ARepr.repr_exclude) /
                                   ARepr.repr_include;

             ReprArr.setValue(iCount,@ARepr);
             {post representation data for this feature}

             if fDebug then
             begin
                  write(DbgFile,IntToStr(AFeat.code) + ',' + FloatToStr(rTarget) + ',' +
                        FloatToStr(area_site) + ',' + FloatToStr(area2_site) + ',' + FloatToStr(sumarea) + ',' +
                        FloatToStr(sumarea2) + ',');
                  writeln(DbgFile,FloatToStr(mean_site) + ',' + FloatToStr(ARepr.irr_feature) + ',' + FloatToStr(ARepr.repr_include) + ',' +
                          FloatToStr(ARepr.repr_exclude));

             end;
       end;

       if fDebug then
          CloseFile(DbgFile);

       total_repr_include[11]:=1;
       total_repr_exclude[11]:=1;

       for iCount := 1 to iFeatureCount do
       begin
            ReprArr.rtnValue(iCount,@ARepr);

            total_repr_include[11]:=total_repr_include[11] * ARepr.repr_include;
            total_repr_exclude[11]:=total_repr_exclude[11] * ARepr.repr_exclude;
       end;

       if total_repr_include[11] = 0 then
          override_comb_predict_sf3:=1
       else
          override_comb_predict_sf3:=(total_repr_include[11]-total_repr_exclude[11]) /
                                        total_repr_include[11];

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception overriding combination size',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;

end; {function override_comb_predict_sf3}


function override_select_combination_size (const SDArr, FArr : Array_T;
                                           var ReprArr : Array_T;
                                           const iNumFeat{, iNumAvail} : integer;
                                           const fShowProgress, fDebug, fPartialDebug : boolean;
                                           const CombinationSizeCondition : CombinationSizeCondition_T) : longint;
var
   lCombsize, lCount, lCombCount : longint;
   pred_comb : Array_T;
   min_repr,max_repr : extended;
   dComb, dBest : extended;
   fAutoLoad : boolean;
   rIrrTarget : extended;
   iRangeToTest,
   iOldCursor : integer;
   DbgFile, PartialDebugFile : Text;
begin
     try
        if ControlRes^.fDumpAverageSite then
           DumpAverageSiteValues(ControlRes^.sWorkingDirectory + '\override_AverageSite.csv');
        {$IFDEF DBG_SHOW_ALLOC}
        MessageDlg('TestMem before pred_comb MaxAvail ' +
                   IntToStr(MaxAvail) + ' MemAvail ' +
                   IntToStr(MemAvail),mtInformation,[mbOK],0);
        {$ENDIF}

        if OverrideCombsizeForm.fCreateCombsizeOutputFile then
           writeln(OverrideCombsizeForm.CombsizeOutputFile,'combsize,dComb');

        if fDebug then
        begin
             assign(DbgFile,ControlRes^.sWorkingDirectory + '\select_combsize_sf3.csv');
             rewrite(DbgFile);
             writeln(DbgFile,'combsize,dComb');
        end;

        if fPartialDebug then
        begin
             assignfile(PartialDebugFile,ControlRes^.sWorkingDirectory +
                                         '\select_combsize_' +
                                         IntToStr(iMinsetIterationCount) +
                                         '.csv');
             rewrite(PartialDebugFile);
             writeln(PartialDebugFile,'combsize,dComb');
        end;

        if fShowProgress then
        begin
             ControlForm.ProgressOn;
             ControlForm.ProcLabelOn('Select Combination Size');
        end;

        {$IFDEF DBG_SHOW_ALLOC}
        MessageDlg('TestMem after pred_comb MaxAvail ' +
                   IntToStr(MaxAvail) + ' MemAvail ' +
                   IntToStr(MemAvail),mtInformation,[mbOK],0);
        {$ENDIF}

        lCombsize := 0;
        min_repr:=1;
        max_repr:=0;

        ControlRes^.LastCombinationSizeCondition := CombinationSizeCondition;

        case CombinationSizeCondition of
             OverrideChange,
             Startup,
             ExclusionChange,
             TargetChange,
             UserLoadLog : iRangeToTest := ControlForm.Available.Items.Count +
                                           ControlForm.Flagged.Items.Count +
                                           ControlForm.R1.Items.Count +
                                           ControlForm.R2.Items.Count +
                                           ControlForm.R3.Items.Count +
                                           ControlForm.R4.Items.Count +
                                           ControlForm.R5.Items.Count +
                                           ControlForm.Partial.Items.Count {+
                                           ControlForm.Excluded.Items.Count};
        else
            iRangeToTest := ControlForm.Available.Items.Count +
                            ControlForm.Flagged.Items.Count;
            ControlRes^.fCustomCombSize := False;
             // The else statement applies to MinsetLoadLog & TriggerTargetCannotBeMet & TriggerZeroAvSumirr
        end;

        //
        if (CombinationSizeCondition = OverrideChange) then
           if (iRangeToTest > OverrideCombsizeForm.iMinimumNumberSpecified) then
              iRangeToTest := OverrideCombsizeForm.iMinimumNumberSpecified;

        ControlRes^.iCombinationSizeRange := iRangeToTest;

        pred_comb := Array_t.Create;
        pred_comb.init(SizeOf(extended),iRangeToTest-2);

        for lCombCount:=2 to (iRangeToTest-1) do
        begin
             combsize.iActiveCombinationSize := lCombCount;
             if fShowProgress then
                ControlForm.ProgressUpdate(round(combsize.iActiveCombinationSize/(iRangeToTest-1)*100));

             init_irr_variables(combsize.iActiveCombinationSize,iRangeToTest);

             dComb := override_comb_predict_sf3(FeatArr,LocalRepr,
                                                iRangeToTest,
                                                ControlRes^.fValidateCombsize,
                                                ControlRes^.fPartialValidateCombsize,
                                                CombinationSizeCondition);

             pred_comb.setValue(combsize.iActiveCombinationSize-1,@dComb);

             if fDebug then
             begin
                  writeln(DbgFile,IntToStr(lCombCount) + ',' + FloatToStr(dComb));
             end;

             if fPartialDebug then
                writeln(PartialDebugFile,IntToStr(lCombCount) + ',' + FloatToStr(dComb));

             if OverrideCombsizeForm.fCreateCombsizeOutputFile then
                writeln(OverrideCombsizeForm.CombsizeOutputFile,IntToStr(lCombCount) + ',' + FloatToStr(dComb));
        end;

        dBest := 1000;
        for lCount := 2 to (iRangeToTest-1) do
        begin
             pred_comb.rtnValue(lCount-1,@dComb);

             if abs(dComb - 0.5) <= dBest then
             begin
                  lCombsize := lCount;
                  dBest := abs(dComb - 0.5);
             end;
        end;

        {$IFDEF DEBUG_COMB}
        RptPredComb(pred_comb);
        {$ENDIF}

        if (lCombsize <= 2) then
           lCombsize := 2;

        if fShowProgress then
        begin
             ControlForm.ProgressOff;
             ControlForm.ProcLabelOff;
        end;

        if fDebug then
           CloseFile(DbgFile);

        if fPartialDebug then
           closefile(PartialDebugFile);

        override_select_combination_size := lCombsize;
        case CombinationSizeCondition of
             OverrideChange,
             Startup,
             ExclusionChange,
             TargetChange,
             UserLoadLog : combsize.iSelectedCombinationSize := lCombsize;
        else
            combsize.iCurrentSelectedCombinationSize := lCombsize;
            combsize.iCurrentSitesUsed := iRangeToTest;
             // The else statement applies to MinsetLoadLog & TriggerTargetCannotBeMet & TriggerZeroAvSumirr
        end;
        combsize.iActiveCombinationSize := lCombsize;

        //if not fAutoLoad then
           pred_comb.Destroy;

        AppendCombsizeLog('override_select_combination_size');

        iAvailableSiteCount := ControlForm.Available.Items.Count + ControlForm.Flagged.Items.Count;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in override select combination size',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;



function GetDelimitedAsciiColumn(const sLine, sElement, sDelimiter : string) : integer;
// returns the 1-based-index of the column in sLine containing sElement
// returns 0 if sElement does not exist within sLine
var
   iPos, iDelimiters, iCount : integer;
begin
     iPos := Pos(lowercase(sElement),lowercase(sLine));
     if (iPos > 0) then
     begin
          // count how many delimiters are between 1 and iPos
          iDelimiters := 0;
          if (iPos > 1) then
             for iCount := 1 to (iPos - 1) do
                 if (sLine[iCount] = sDelimiter) then
                    Inc(iDelimiters);
          Result := iDelimiters + 1;
     end
     else
         Result := 0;
end;

function GetDelimitedAsciiElement(const sLine, sDelimiter : string;
                                  const iColumn : integer) : string;
// returns the element at 1-based-index column iColumn
// returns blank string if the column does not exist in sLine
var
   sTrimLine : string;
   iPos, iTrim, iCount : integer;
begin
     Result := '';

     sTrimLine := sLine;
     iTrim := iColumn-1;
     if (iTrim > 0) then
        for iCount := 1 to iTrim do // trim the required number of columns from the start of the string
        begin
             iPos := Pos(sDelimiter,sTrimLine);
             sTrimLine := Copy(sTrimLine,iPos+1,Length(sTrimLine)-iPos);
        end;
     iPos := Pos(sDelimiter,sTrimLine);
     if (iPos = 1) then
     begin
          // there is a delimiter at the start of the line we must trim first
          sTrimLine := Copy(sTrimLine,2,Length(sTrimLine)-1);
          iPos := Pos(sDelimiter,sTrimLine);
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;
     end
     else
     begin
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;
     end;
end;

procedure TOverrideCombsizeForm.ReadInputValues(const sInputFile : string;
                                                var fFeatTargetRead, fFeatNumAvSitesRead : boolean;
                                                const fDebug : boolean);
var
   InputFile, OutputFile : TextFile;
   sHeaderRow, sLine, sFileName, sExtension : string;
   fStop : boolean;
   iKeyCol, iTargetCol, iNumAvCol, iFeatKey, iNumAv : integer;
   rTarget : extended;
begin
     //

     assignfile(InputFile,sInputFile);
     reset(InputFile);
     readln(InputFile,sHeaderRow);
     fFeatTargetRead := (Pos('feattarget',lowercase(sHeaderRow)) > 0);
     fFeatNumAvSitesRead := (Pos('featnumavsites',lowercase(sHeaderRow)) > 0);

     if fDebug then
     begin
          sFileName := ExtractFileName(sInputFile);
          sExtension := ExtractFileExt(sInputFile);
          assignfile(OutputFile,ExtractFilePath(sInputFile) + '\' +
                                Copy(sFileName,1,Length(sFileName) - Length(sExtension)) +
                                '_input' +
                                sExtension);
          rewrite(OutputFile);
          write(OutputFile,'FeatKey');
          if fFeatTargetRead then
             write(OutputFile,',FeatTarget');
          if fFeatNumAvSitesRead then
             write(OutputFile,',FeatNumAvSites');
          writeln(OutputFile);
     end;

     iKeyCol := GetDelimitedAsciiColumn(sHeaderRow,'FeatKey',',');
     iTargetCol := GetDelimitedAsciiColumn(sHeaderRow,'FeatTarget',',');
     iNumAvCol := GetDelimitedAsciiColumn(sHeaderRow,'FeatNumAvSites',',');

     iMinimumNumberSpecified := ControlForm.Available.Items.Count + ControlForm.Flagged.Items.Count;

     fStop := False;
     repeat
           readln(InputFile,sLine);

           // extract & store values for this line
           iFeatKey := StrToInt(GetDelimitedAsciiElement(sLine,',',iKeyCol));

           if fDebug then
              write(OutputFile,IntToStr(iFeatKey));

           if fFeatTargetRead then
           begin
                rTarget := RegionSafeStrToFloat(GetDelimitedAsciiElement(sLine,',',iTargetCol));
                InputTarget.setValue(iFeatKey,@rTarget);
                if fDebug then
                   write(OutputFile,',' + FloatToStr(rTarget));
           end;

           if fFeatNumAvSitesRead then
           begin
                iNumAv := StrToInt(GetDelimitedAsciiElement(sLine,',',iNumAvCol));
                InputNumSites.setValue(iFeatKey,@iNumAv);
                if fDebug then
                   write(OutputFile,',' + IntToStr(iNumAv));

                if (iNumAv < iMinimumNumberSpecified) then
                   iMinimumNumberSpecified := iNumAv;
           end;

           if fDebug then
              writeln(OutputFile);

           fStop := Eof(InputFile);

     until fStop;

     if fDebug then
        closefile(OutputFile);

     closefile(InputFile);
end;

procedure TOverrideCombsizeForm.OverrideCombinationSize(const sInputFile : string;
                                                        const fCreateOutfile,
                                                              fCreateValidate : boolean);
var
   //InputFilef{, OutputFile} : TextFile;
   sFileName, sExtension, sOutputFileName, sValidatePath, sValidateName : string;
   iNumSites, iCount : integer;
   rTarget : extended;
begin
     try
        // ExtractFileName
        // ExtractFileExt
        // ExtractFilePath
        if fileexists(sInputFile) then
        begin
             InputTarget := Array_t.Create;
             InputTarget.init(SizeOf(extended),iFeatureCount);
             InputNumSites := Array_t.Create;
             InputNumSites.init(SizeOf(integer),iFeatureCount);
             rTarget := 0;
             iNumSites := 0;
             for iCount := 1 to iFeatureCount do
             begin
                  InputTarget.setValue(iCount,@rTarget);
                  InputNumSites.setValue(iCount,@iNumSites);
             end;

             sFileName := ExtractFileName(sInputFile);
             sExtension := ExtractFileExt(sInputFile);

             fCreateCombsizeOutputFile := fCreateOutfile;
             if fCreateOutfile then
             begin
                  sOutputFileName := ExtractFilePath(sInputFile) + '\' +
                                     Copy(sFileName,1,Length(sFileName) - Length(sExtension)) +
                                     '_output' +
                                     sExtension;
                  assignfile(CombsizeOutputFile,sOutputFileName);
                  rewrite(CombsizeOutputFile);
             end;

             // read values from input file
             ReadInputValues(sInputFile,
                             fFeatTargetRead,fFeatNumAvSitesRead,
                             True);

             // override combination size
             combsize.iSelectedCombinationSize:=override_select_combination_size(AverageSite,FeatArr,LocalRepr,
                                                                        iFeatureCount,
                                                                        True,
                                                                        ControlRes^.fValidateCombsize,
                                                                        ControlRes^.fPartialValidateCombsize,
                                                                        OverrideChange);
             //combsize.iCurrentSitesUsed := ControlForm.Available.Items.Count + ControlForm.Flagged.Items.Count;
             combsize.iActiveCombinationSize := combsize.iSelectedCombinationSize;
             WriteCombsizeDebug('OverrideCombinationSize');
             // call init irr variables for each feature
             init_irr_variables(combsize.iActiveCombinationSize,iAvailableSiteCount);

             if fCreateOutfile then
                closefile(CombsizeOutputFile);

             if fCreateValidate then
             begin
                  // sValidateFileName, sValidateName
                  // create validate output in subdir with the name of the input
                  // file minus its extension
                  sValidateName := Copy(sFileName,1,Length(sFileName) - Length(sExtension));
                  sValidatePath := ExtractFilePath(sInputFile) + '\' + sValidateName;
                  ForceDirectories(sValidatePath);

                  // call code to create validate files
                  GenerateDebugReports(sValidatePath);
             end;

             InputTarget.Destroy;
             InputNumSites.Destroy;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in override combination size',mtError,[mbOk],0);
     end;
end;

procedure TOverrideCombsizeForm.BitBtnOkClick(Sender: TObject);
begin
     OverrideCombinationSize(EditInputFile.Text,
                             CheckDumpOutfile.Checked,
                             CheckDumpValidate.Checked);
end;

procedure TOverrideCombsizeForm.EditInputFileClick(Sender: TObject);
begin
     if (EditInputFile.Text = 'click here to browse the input file') then
        OpenDialog1.InitialDir := ControlRes^.sWorkingDirectory;

     if OpenDialog1.Execute then
        EditInputFile.Text := OpenDialog1.Filename;
end;

end.
