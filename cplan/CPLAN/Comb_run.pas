unit Comb_run;

{$I STD_DEF.PAS}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Spin, StdCtrls,
  {$IFDEF bit16}
  Arrayt16, Buttons, Cpng_imp;
  {$ELSE}
  ds, Dll_u1, reports;
  {$ENDIF}

type
  TCombRunForm = class(TForm)
    Label1: TLabel;
    edFilename: TEdit;
    BtnBrowse: TButton;
    spLow: TSpinEdit;
    spHigh: TSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    BtnRunReport: TButton;
    BtnFinish: TButton;
    Label5: TLabel;
    SaveRpt: TSaveDialog;
    lblStatus: TLabel;
    DescrMemo: TMemo;
    Label6: TLabel;
    CheckSparseMatrix: TCheckBox;
    SpinStep: TSpinEdit;
    lblStep: TLabel;
    procedure BtnFinishClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure spLowChange(Sender: TObject);
    procedure spHighChange(Sender: TObject);
    procedure BtnRunReportClick(Sender: TObject);
    function RunVariCombRpt(sFilename:string;iLow,iHigh,iStep:integer) : boolean;
    procedure BtnBrowseClick(Sender: TObject);
    procedure RptIrrepCombStart(sFilename:string;iCurrComb:integer);
    procedure RptIrrepCombAdd(sFilename:string;iCurrComb:integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function GenUniqueTmpFile(sDestPath:string):string;
function ForceFileExt(const sFile, sExt : string) : string;

procedure RunMatrixRpt(const sFilename{,sDescription}:string;
                       const iFlag : integer;
                       const fPromptToOverwrite : boolean);
procedure ExtantMatrixRpt(const sFilename{,sDescription}:string;
                          const iFlag : integer;
                          const fPromptToOverwrite : boolean);
procedure ReportExcDefLog(const sOutFile : string);

procedure RecurseRemoveCommas(var sLine : string);

procedure SparseMatrixRpt(const sFilename, sKeyFile : string;
                          const fPromptToOverwrite, fTwoFileMethod,
                                fOne, fTwo, fThree, fFour : boolean);

var
  CombRunForm: TCombRunForm;
  iReportFlag : integer;

implementation

uses
    Global, Control, Sf_irrep, Em_newu1,
    {Reports,} Toolmisc, pred_sf4, contribu,
    pred_sf3, In_order,
    opt1, partl_ed;

{$R *.DFM}

procedure ReportExcDefLog(const sOutFile : string);
var
   RptFile : text;
   iLogSize, iCount, iSiteIndex : integer;
   LogEntry : LogEntry_T;
   pSite : sitepointer;
begin
     assign(RptFile,sOutFile);
     rewrite(RptFile);
     writeln(RptFile,'Name,Key');

     {add any excluded sites as first elements in the log file}
     if (ControlForm.Excluded.Items.Count > 0) then
     begin
          writeln(RptFile,',Ex');

          for iCount := 0 to (ControlForm.Excluded.Items.Count-1) do
          begin
               writeln(RptFile,ControlForm.Excluded.Items.Strings[iCount] + ',' +
                               ControlForm.ExcludedKey.Items.Strings[iCount]);
          end;
     end;

     {add any R1, R2 or Pd sites as the next elements in the log file}
     BuildLogList(iLogSize,False);
     if (iLogSize > 0) then
     begin
          writeln(RptFile,',Def');

          new(pSite);

          for iCount := 1 to iLogSize do
          begin
               LogList.rtnValue(iCount,@LogEntry);

               iSiteIndex := FindFeatMatch(OrdSiteArr,LogEntry.iKey);
               SiteArr.rtnValue(iSiteIndex,pSite);

               if (pSite^.status = _R1)
               or (pSite^.status = _R2)
               or (pSite^.status = _R3)
               or (pSite^.status = _R4)
               or (pSite^.status = _R5)
               or (pSite^.status = Pd) then
                  writeln(RptFile,pSite^.sName + ',' + IntToStr(LogEntry.iKey));
          end;

          dispose(pSite);
     end;

     LogList.Destroy;

     CloseFile(RptFile);
end;

procedure ExtantMatrixRpt(const sFilename : string;
                          const iFlag : integer;
                          const fPromptToOverwrite : boolean);
var
   iCount, iFCount, iFeaturePos, iContribIndex, iFeatIndex, iTestFeat,
   iFeatCode, iInitCount, iRecordCount, iCommaCount, iFileCount,
   iColumnCount : integer;
   sDescr, sTest : string;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   fStop, fOldNames, fOk, fAddComma : boolean;
   OutFiles : array [1..50] of text;
   iOutFiles, iNumCommas, iOutFile, iColumnsInEachOutputFile : integer;
   rValue : extended;
   ClickValues : Array_t;
   sFile, sPath : string;
   Value : ValueFile_T;

   function FindThisFeature(const iFeatureIndex : integer) : integer;
   var
      iLocalCount : integer;
   begin
        Result := 0;

        FeatArr.rtnValue(iFeatureIndex,pFeat);

        if (pSite^.richness > 0) then
           for iLocalCount := 1 to pSite^.richness do
           begin
                FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                if (Value.iFeatKey = pFeat^.code) then
                   Result := iLocalCount;
           end;
   end;

   function RtnValueAtSite(iFeatCode:integer) : extended;
   var
      iLocalCount : integer;
      fReserved : boolean;
   begin
        try
           case iFlag of
                0 : {report sites by features matrix}
                begin
                     Result := 0;
                     if (pSite^.richness > 0) then
                        for iLocalCount := 1 to pSite^.richness do
                        begin
                             FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                             if (Value.iFeatKey = iFeatCode) then
                                Result := Value.rAmount;
                        end;
                end;
                1 : {report binary partial matrix}
                begin
                     Result := 0;
                     if (pSite^.richness > 0)
                     and (pSite^.status = Pd) then
                         for iLocalCount := 1 to pSite^.richness do
                         begin
                              FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                              SparsePartial.rtnValue(pSite^.iOffset + iLocalCount,@fReserved);
                              if (Value.iFeatKey = iFeatCode)
                              and fReserved then
                                  Result := 1;
                         end;
                end;
                2 : {report feature irrep matrix}
                begin
                     {available - irreplaceability value
                      other - 0}

                     Result := 0;

                     if (pSite^.richness > 0) then
                        for iLocalCount := 1 to pSite^.richness do
                        begin
                             FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                             if (Value.iFeatKey = iFeatCode) then
                             begin
                                  ClickValues.rtnValue(iLocalCount,@rValue);
                                  Result := rValue;
                             end;
                        end;
                end;
                3 : {report % to target}
                begin
                     {available - possible % to current effective target
                      deferred - stored value (% to targ at time of deferral)}
                     Result := 0;

                     if (pSite^.richness > 0) then
                     begin
                          if (pSite^.status = _R1)
                          or (pSite^.status = _R2)
                          or (pSite^.status = _R3)
                          or (pSite^.status = _R4)
                          or (pSite^.status = _R5) then
                          begin
                               for iLocalCount := 1 to pSite^.richness do
                               begin
                                    rValue := 0;

                                    FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                                    if (Value.iFeatKey = iFeatCode) then
                                       Result := rValue;
                               end;
                          end
                          else
                              if (pSite^.status = Pd) then
                              begin
                                   for iLocalCount := 1 to pSite^.richness do
                                   begin
                                        FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                                        if (Value.iFeatKey = iFeatCode) then
                                        begin
                                             SparsePartial.rtnValue(pSite^.iOffset + iLocalCount,@fReserved);
                                             if fReserved then
                                             begin
                                                  {calculate the value}
                                                  iFeatIndex := Value.iFeatKey;
                                                  FeatArr.rtnValue(iFeatIndex,pFeat);

                                                  if (pFeat^.targetarea > 0) then
                                                     Result := Value.rAmount /
                                                               pFeat^.targetarea * 100
                                                  else
                                                      Result := 0;
                                             end;
                                        end;
                                   end;
                              end
                              else
                              begin
                                   for iLocalCount := 1 to pSite^.richness do
                                   begin
                                        FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                                        if (Value.iFeatKey = iFeatCode) then
                                        begin
                                             {calculate the value}
                                             iFeatIndex := Value.iFeatKey;
                                             FeatArr.rtnValue(iFeatIndex,pFeat);

                                             if (pFeat^.targetarea > 0) then
                                                Result := Value.rAmount /
                                                          pFeat^.targetarea * 100
                                             else
                                                 Result := 0;
                                        end;
                                   end;
                              end;
                     end;
                end;
           end;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in ExtantMatrixReport/RtnValueAtSite',mtError,[mbOk],0);
        end;
   end;

begin
     {parse the sites and write feature data out to a CSV file}

     try
        iColumnsInEachOutputFile := 250;

        fStop := False;

        if fPromptToOverwrite then
           if FileExists(sFilename) then
              if (mrNo = MessageDlg('File ' + sFilename + ' exists.  Overwrite?',mtConfirmation,[mbYes,mbNo],0)) then
                 fStop := True;


        if not fStop then
        begin
             AssignFile(OutFiles[1],sFilename);
             Rewrite(OutFiles[1]);

             iOutFiles := iFeatureCount div iColumnsInEachOutputFile;
             if ((iFeatureCount mod iColumnsInEachOutputFile) > 0) then
                Inc(iOutFiles);

             sFile := ExtractFileName(sFilename);
             sPath := ExtractFilePath(sFilename);
             if (iOutFiles > 1) then
                for iFileCount := 2 to iOutFiles do
                begin
                     AssignFile(OutFiles[iFileCount],sPath + '\' + IntToStr(iFileCount-1) + sFile);
                     rewrite(OutFiles[iFileCount]);
                end;
        end;

     except
            begin
                 fStop := True;
            end;
     end;

     if not fStop then
     try
     begin
          new(pFeat);
          new(pSite);

          Write(OutFiles[1],'KEY,NAME,');

          fOldNames := True;
          iColumnCount := 0;

          ControlForm.CutOffTable.Open;
          iRecordCount := ControlForm.CutOffTable.RecordCount;

          {possible error of extra , after last element}

          ControlForm.CutOffTable.Close;
          iCommaCount := 2;

          for iFCount := 1 to iRecordCount do
          begin
               iFeatIndex := iFCount;

               if (iFeatIndex > 0) then
               begin
                    FeatArr.rtnValue(iFeatIndex,pFeat);
                    if (pFeat^.code = iFCount) then
                    begin
                         // Need to determine which file to write this element to
                         // and whether we need to add a comma delimiter after writing
                         // the element (which we do for each column in a CSV file
                         // except for the last column).
                         iOutFile := 1;
                         fAddComma := False;
                         if (iCommaCount <= iColumnsInEachOutputFile) then
                         begin
                              {the output file will be file 1}
                              if (iCommaCount < iColumnsInEachOutputFile)
                              and (iCommaCount <> (iFeatureCount+1)) then
                                  fAddComma := True;
                         end
                         else
                         begin
                              {the output file will be file 2 .. file n}
                              Inc(iOutFile);
                              iNumCommas := iCommaCount - iColumnsInEachOutputFile;
                              if (iNumCommas > iColumnsInEachOutputFile) then
                                 repeat
                                       Inc(iOutFile);
                                       Dec(iNumCommas,iColumnsInEachOutputFile);

                                 until (iNumCommas <= iColumnsInEachOutputFile);

                              if (iNumCommas < iColumnsInEachOutputFile)
                              and (iCommaCount <> (iFeatureCount+1)) then
                                  fAddComma := True;
                         end;

                         if fAddComma then
                            write(OutFiles[iOutFile],pFeat^.sID + ',')
                         else
                             write(OutFiles[iOutFile],pFeat^.sID);

                         Inc(iCommaCount);
                    end;
               end;
          end;

          for iFileCount := 1 to iOutFiles do
              writeln(OutFiles[iFileCount]);

          for iCount := 1 to iSiteCount do
          begin
               SiteArr.rtnValue(iCount,pSite);

               if (iFlag = 2) then
               begin
                    {we need to predict irreplaceability for this site}
                    ClickValues := click_predict_sf4(iCount);
               end;

               Write(OutFiles[1],IntToStr(pSite^.iKey) + ',' +
                             pSite^.sName + ','
                             );
               iCommaCount := 2;

               for iFCount := 1 to iRecordCount do
               begin
                    iFeatIndex := iFCount;

                    if (iFeatIndex > 0) then
                    begin
                         FeatArr.rtnValue(iFeatIndex,pFeat);

                         if (pFeat^.code = iFCount) then
                         begin

                              iOutFile := 1;
                              fAddComma := False;
                              if (iCommaCount <= iColumnsInEachOutputFile) then
                              begin
                                   {the output file will be file 1}
                                   if (iCommaCount < iColumnsInEachOutputFile)
                                   and (iCommaCount <> (iFeatureCount+1)) then
                                       fAddComma := True;
                              end
                              else
                              begin
                                   {the output file will be file 2 .. file n}
                                   Inc(iOutFile);
                                   iNumCommas := iCommaCount - iColumnsInEachOutputFile;
                                   if (iNumCommas > iColumnsInEachOutputFile) then
                                      repeat
                                            Inc(iOutFile);
                                            Dec(iNumCommas,iColumnsInEachOutputFile);

                                      until (iNumCommas <= iColumnsInEachOutputFile);

                                   if (iNumCommas < iColumnsInEachOutputFile)
                                   and (iCommaCount <> (iFeatureCount+1)) then
                                       fAddComma := True;
                              end;

                              if fAddComma then
                                 write(OutFiles[iOutFile],FloatToStr(RtnValueAtSite(pFeat^.code)) + ',')
                              else
                                  write(OutFiles[iOutFile],FloatToStr(RtnValueAtSite(pFeat^.code)));

                              Inc(iCommaCount);
                         end;
                    end;
               end;

               for iFileCount := 1 to iOutFiles do
                   writeln(OutFiles[iFileCount]);

               if (iFlag = 2) then
                  ClickValues.Destroy;
          end;

          dispose(pFeat);
          dispose(pSite);
          for iFileCount := 1 to iOutFiles do
              CloseFile(OutFiles[iFileCount]);
     end;
     except
           Screen.Cursor := crDefault;
           MessageDlg('exception in ExtantMatrixRpt',mtError,[mbOk],0);

           dispose(pFeat);
           dispose(pSite);
           for iFileCount := 1 to iOutFiles do
               CloseFile(OutFiles[iFileCount]);
     end;

end;

procedure SparseMatrixRpt(const sFilename, sKeyFile : string;
                          const fPromptToOverwrite, fTwoFileMethod,
                                fOne, fTwo, fThree, fFour : boolean);
var
   iCount, iFCount, iFeaturePos, iContribIndex, iFeatIndex, iTestFeat,
   iFeatCode, iInitCount, iFileCount,
   iColumnCount, iNumCommas : integer;
   sDescr, sTest, sFile, sPath, sLine : string;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   fPartialFlag, fReserved,
   fStop, fOldNames, fOk : boolean;
   OutFile, KeyFile : text;
   {$IFDEF SPARSE_MATRIX_2}
   ClickValues : Array_t;
   {$ELSE}
   AFeatCust : FeatureCust_T;
   ClickRepr : ClickRepr_T;
   {$ENDIF}
   rValueOne,rValueTwo,rValueThree,rValueFour : extended;
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}
   fValidate : boolean;
   //ReportFeatIrr : ReportFeatIrr_T;
   //FeatIrrFile : file of ReportFeatIrr_T;

   function FindThisFeature(const iFeatureIndex : integer) : integer;
   var
      iLocalCount : integer;
   begin
        Result := 0;

        FeatArr.rtnValue(iFeatureIndex,pFeat);

        if (pSite^.richness > 0) then
           for iLocalCount := 1 to pSite^.richness do
           begin
                {$IFDEF SPARSE_MATRIX}
                FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                if (Value.iFeatKey = pFeat^.code) then
                   Result := iLocalCount;
                {$ELSE}
                if (pSite^.feature[iLocalCount] = pFeat^.code) then
                   Result := iLocalCount;
                {$ENDIF}
           end;
   end;

   function RtnValueAtSite(iFeatureKey : integer;
                           var rOne,rTwo,rThree,rFour : extended) : boolean;
   var
      iLocalCount : integer;
   begin
        try
           Result := False;
           rOne := 0;
           rTwo := 0;
           rThree := 0;
           rFour := 0;

           if (pSite^.richness > 0) then
           begin
                if fOne then
                   // feature amount
                   for iLocalCount := 1 to pSite^.richness do
                   begin
                        FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                        if (Value.iFeatKey = iFeatureKey) then
                        begin
                             rOne := Value.rAmount;
                             Result := True;
                        end;
                   end;

                if fTwo
                and (pSite^.status = Pd) then
                    // partial status
                    for iLocalCount := 1 to pSite^.richness do
                    begin
                         FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                         if (Value.iFeatKey = iFeatureKey) then
                         begin
                              Result := True;
                              SparsePartial.rtnValue(pSite^.iOffset + iLocalCount,@fPartialFlag);
                              if fPartialFlag then
                                 rTwo := 1;
                         end;
                    end;

                if fThree then
                   {available - irreplaceability value
                    other - 0}
                   for iLocalCount := 1 to pSite^.richness do
                       begin
                            FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                            if (Value.iFeatKey = iFeatureKey) then
                            begin
                                 ClickValues.rtnValue(iLocalCount,@rThree);
                                 Result := True;
                            end;
                       end;

                if fFour then
                begin
                     {available - possible % to current effective target
                      deferred - stored value (% to targ at time of deferral)}
                     for iLocalCount := 1 to pSite^.richness do
                     begin
                          FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                          if (Value.iFeatKey = iFeatureKey) then
                          case pSite^.status of
                               Re, Ex :
                               begin
                                    rFour := 0;
                               end;
                               _R1, _R2, _R3, _R4, _R5 :
                               begin
                                    // calculate value for this site
                                    iFeatIndex := FindFeature(Value.iFeatKey);
                                    FeatArr.rtnValue(iFeatIndex,pFeat);
                                    if ((pFeat^.targetarea + Value.rAmount) > 0) then
                                       rFour := Value.rAmount /
                                                (pFeat^.targetarea + Value.rAmount) * 100
                                       else
                                           rFour := 0;
                                    Result := True;
                               end;
                               Pd :
                               begin
                                    SparsePartial.rtnValue(pSite^.iOffset + iLocalCount,@fReserved);
                                    {calculate the value}
                                    iFeatIndex := FindFeature(Value.iFeatKey);
                                    FeatArr.rtnValue(iFeatIndex,pFeat);

                                    if fReserved then
                                    begin
                                         if ((pFeat^.targetarea + Value.rAmount) > 0) then
                                            rFour := Value.rAmount /
                                                     (pFeat^.targetarea + Value.rAmount) * 100
                                         else
                                             rFour := 0;
                                    end
                                    else
                                    begin
                                         if (pFeat^.targetarea > 0) then
                                            rFour := Value.rAmount /
                                                     pFeat^.targetarea * 100
                                         else
                                             rFour := 0;
                                    end;

                                    Result := True;
                               end;
                          else
                              // site is available or flagged
                              // so we need to calculate the value
                              iFeatIndex := Value.iFeatKey;
                              FeatArr.rtnValue(iFeatIndex,pFeat);

                              if (pFeat^.targetarea > 0) then
                                 rFour := Value.rAmount /
                                           pFeat^.targetarea * 100
                              else
                                  rFour := 0;
                          end;
                     end;
                end;
           end;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in ExtantMatrixReport/RtnValueAtSite',mtError,[mbOk],0);
        end;
   end;

begin
     {parse the sites and write feature data out to a CSV file}

     if (fOne or fTwo or fThree or fFour) then
     try
        fStop := False;

        if fPromptToOverwrite then
           if FileExists(sFilename) then
              if (mrNo = MessageDlg('File ' + sFilename + ' exists.  Overwrite?',mtConfirmation,[mbYes,mbNo],0)) then
                 fStop := True;

        if not fStop then
        begin
             AssignFile(OutFile,sFilename);
             Rewrite(OutFile);
             //AssignFile(FeatIrrFile,sFilename + '.bin');
             //Rewrite(FeatIrrFile);

             if fTwoFileMethod then
             begin
                  AssignFile(KeyFile,sKeyFile);
                  Rewrite(KeyFile);
             end;
        end;

     except
           fStop := True;
     end
     else
         fStop := True;

     if not fStop then
     try
        new(pFeat);
        new(pSite);

        if fTwoFileMethod then
           sLine := 'FeatureKey,'
        else
            sLine := 'SiteIndex,FeatureKey,';

        if fOne then
        begin
             if (fTwo or fThree or fFour) then
                sLine := sLine + 'FeatureAmount,'
             else
                 sLine := sLine + 'FeatureAmount';
        end;
        if fTwo then
        begin
             if (fThree or fFour) then
                sLine := sLine + 'PartialStatus,'
             else
                 sLine := sLine + 'PartialStatus';
        end;
        if fThree then
        begin
             if fFour then
                sLine := sLine + 'FeatureIrreplaceability,'
             else
                 sLine := sLine + 'FeatureIrreplaceability';
        end;
        if fFour then
           sLine := sLine + 'Feature%ToTarget';

        writeln(OutFile,sLine);

        if fTwoFileMethod then
           writeln(KeyFile,'SiteIndex,SiteRichness');

        fOldNames := True;
        iColumnCount := 0;

        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);
             ValidateSite.rtnValue(iCount,@fValidate);
             if fValidate then
             begin
                 if fTwoFileMethod then
                    writeln(KeyFile,IntToStr(iCount) + ',' + IntToStr(pSite^.richness));

                 {$IFNDEF SPARSE_MATRIX_2}
                 if fFour
                 and ((pSite^.status = R1)
                      or (pSite^.status = R2)
                      or (pSite^.status = R3)
                      or (pSite^.status = R4)
                      or (pSite^.status = R5)
                      or (pSite^.status = Pd)) then
                 begin
                      {we need to look up contrib data for this deferred site}
                      fOk := False;
                      if fContrDataDone then
                      begin
                           iContribIndex := findcontribsite(pSite^.iKey);

                           if (GraphContribution.Features.lMaxSize >= iContribIndex) then
                           begin
                                GraphContribution.Features.rtnValue(iContribIndex,@AFeatCust);
                                fOk := True;
                           end;
                      end;

                      {initialise AFeatCust.rValue[] because it has not been calculated, set to 0}
                      if not fOk then
                         for iInitCount := 1 to max do
                             AFeatCust.rValue[iInitCount] := 0;
                 end;
                 {$ENDIF}

                 if fThree then
                 begin
                      ClickValues := click_predict_sf4(iCount);
                 end;

                 for iFeatIndex := 1 to iFeatureCount do
                 begin
                      FeatArr.rtnValue(iFeatIndex,pFeat);

                      if RtnValueAtSite(pFeat^.code,rValueOne,rValueTwo,rValueThree,rValueFour) then
                      begin
                           // feature exists at this site
                           // site key, feature key, ...

                           if fTwoFileMethod then
                              sLine := IntToStr(pFeat^.code) + ','
                           else
                               sLine := IntToStr(iCount) + ',' + IntToStr(pFeat^.code) + ',';
                           if fOne then
                           begin
                                if (fTwo or fThree or fFour) then
                                   sLine := sLine + FloatToStr(rValueOne) + ','
                                else
                                    sLine := sLine + FloatToStr(rValueOne);
                           end;
                           if fTwo then
                           begin
                                if (fThree or fFour) then
                                   sLine := sLine + FloatToStr(rValueTwo) + ','
                                else
                                    sLine := sLine + FloatToStr(rValueTwo);
                           end;
                           if fThree then
                           begin
                                if fFour then
                                   sLine := sLine + FloatToStr(rValueThree) + ','
                                else
                                    sLine := sLine + FloatToStr(rValueThree);
                           end;
                           if fFour then
                              sLine := sLine + FloatToStr(rValueFour);

                           writeln(OutFile,sLine);

                           //ReportFeatIrr.iSiteKey := pSite^.iKey;
                           //ReportFeatIrr.iFeatKey := pFeat^.code;
                           //ReportFeatIrr.rFeatIrr := rValueThree;
                           //write(FeatIrrFile,ReportFeatIrr);
                      end;
                 end;
                 {$IFDEF SPARSE_MATRIX_2}
                 if fThree then
                    ClickValues.Destroy;
                 {$ENDIF}
             end;
        end;

        dispose(pFeat);
        dispose(pSite);
        CloseFile(OutFile);
        //closefile(FeatIrrFile);
        if fTwoFileMethod then
           CloseFile(KeyFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('exception in SparseMatrixRpt',mtError,[mbOk],0);

           dispose(pFeat);
           dispose(pSite);
           CloseFile(OutFile);
           //closefile(FeatIrrFile);
           if fTwoFileMethod then
              CloseFile(KeyFile);
     end;
end;

procedure RunMatrixRpt(const sFilename{,sDescription}:string;
                       const iFlag : integer;
                       const fPromptToOverwrite : boolean);
var
   iCount, iFCount, iFeaturePos, iContribIndex, iFeatIndex : integer;
   sDescr, sTest : string;
   pSite : sitepointer;
   pFeat : featureoccurrencepointer;
   fReserved, fStop, fOldNames : boolean;
   OutFile : text;
   {$IFDEF SPARSE_MATRIX_2}
   ClickValues : Array_t;
   rValue : extended;
   {$ELSE}
   AFeatCust : FeatureCust_T;
   ClickRepr : ClickRepr_T;
   {$ENDIF}
   {$IFDEF SPARSE_MATRIX}
   Value : ValueFile_T;
   {$ENDIF}

   function FindThisFeature(const iFeatureIndex : integer) : integer;
   var
      iLocalCount : integer;
   begin
        Result := 0;

        FeatArr.rtnValue(iFeatureIndex,pFeat);

        if (pSite^.richness > 0) then
           for iLocalCount := 1 to pSite^.richness do
           begin
                {$IFDEF SPARSE_MATRIX}
                FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                if (Value.iFeatKey = pFeat^.code) then
                {$ELSE}
                if (pSite^.feature[iLocalCount] = pFeat^.code) then
                {$ENDIF}
                   Result := iLocalCount;
           end;
   end;

   function RtnValueAtSite(iFeatCode:integer) : extended;
   var
      iLocalCount : integer;
   begin
        case iFlag of
             0 : {report sites by features matrix}
             begin
                  Result := 0;
                  if (pSite^.richness > 0) then
                     for iLocalCount := 1 to pSite^.richness do
                     begin
                          {$IFDEF SPARSE_MATRIX}
                          FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                          if (Value.iFeatKey = iFeatCode) then
                             Result := Value.rAmount;
                          {$ELSE}
                          if (pSite^.feature[iLocalCount] = iFeatCode) then
                             Result := pSite^.featurearea[iLocalCount];
                          {$ENDIF}
                     end;
             end;
             1 : {report binary partial matrix}
             begin
                  Result := 0;
                  if (pSite^.richness > 0)
                  and (pSite^.status = Pd) then
                       for iLocalCount := 1 to pSite^.richness do
                       begin
                            FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                            SparsePartial.rtnValue(pSite^.iOffset + iLocalCount,@fReserved);
                            if (Value.iFeatKey = iFeatCode)
                            and fReserved then
                                Result := 1;
                       end;
             end;
             2 : {report feature irrep matrix}
             begin
                  {available - irreplaceability value
                   other - 0}

                  Result := 0;

                  if (pSite^.richness > 0)
                  and ((pSite^.status = Av)
                       or (pSite^.status = Fl)) then
                       for iLocalCount := 1 to pSite^.richness do
                       begin
                            {$IFDEF SPARSE_MATRIX}
                            FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                            if (Value.iFeatKey = iFeatCode) then
                            {$ELSE}
                            if (pSite^.feature[iLocalCount] = iFeatCode) then
                            {$ENDIF}
                            {$IFDEF SPARSE_MATRIX_2}
                            begin
                                 ClickValues.rtnValue(iLocalCount,@rValue);
                                 Result := rValue;
                            end;
                            {$ELSE}
                               Result := ClickRepr[iLocalCount];
                            {$ENDIF}
                       end;
             end;
             3 : {report % to target}
             begin
                  {available - possible % to current effective target
                   deferred - stored value (% to targ at time of deferral)}
                  Result := 0;

                  if (pSite^.richness > 0) then
                  begin
                       if (pSite^.status = _R1)
                       or (pSite^.status = _R2)
                       or (pSite^.status = _R3)
                       or (pSite^.status = _R4)
                       or (pSite^.status = _R5) then
                       begin
                            for iLocalCount := 1 to pSite^.richness do
                            begin
                                 {$IFDEF SPARSE_MATRIX_2}
                                 Result := 0;
                                 {$ELSE}
                                 FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                                 if (Value.iFeatKey = iFeatCode) then
                                    Result := AFeatCust.rValue[iLocalCount];
                                 {$ENDIF}
                            end;
                       end
                       else
                           if (pSite^.status = Pd) then
                           begin
                                for iLocalCount := 1 to pSite^.richness do
                                begin
                                     FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                                     if (Value.iFeatKey = iFeatCode) then
                                     begin
                                          //SparsePartial.rtnValue(pSite^.iOffset + lCount,@fReserved);
                                          {calculate the value}
                                          iFeatIndex := FindFeature(Value.iFeatKey);
                                          FeatArr.rtnValue(iFeatIndex,pFeat);

                                          if (pFeat^.targetarea > 0) then
                                             Result := Value.rAmount /
                                                       pFeat^.targetarea * 100
                                          else
                                              Result := 0;
                                     end;
                                end;
                           end
                           else
                           begin
                                for iLocalCount := 1 to pSite^.richness do
                                begin
                                     {$IFDEF SPARSE_MATRIX}
                                     FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                                     if (Value.iFeatKey = iFeatCode) then
                                     {$ELSE}
                                     if (pSite^.feature[iLocalCount] = iFeatCode) then
                                     {$ENDIF}
                                     begin
                                          {calculate the value}
                                          {$IFDEF SPARSE_MATRIX}
                                          FeatureAmount.rtnValue(pSite^.iOffset + iLocalCount,@Value);
                                          iFeatIndex := Value.iFeatKey;
                                          {$ELSE}
                                          iFeatIndex := FindFeature(pSite^.feature[iLocalCount]);
                                          {$ENDIF}
                                          FeatArr.rtnValue(iFeatIndex,pFeat);

                                          if (pFeat^.targetarea > 0) then
                                             {$IFDEF SPARSE_MATRIX}
                                             Result := Value.rAmount /
                                             {$ELSE}
                                             Result := pSite^.featurearea[iLocalCount] /
                                             {$ENDIF}
                                                       pFeat^.targetarea * 100
                                          else
                                              Result := 0;
                                     end;
                                end;
                           end;
                  end;
             end;
        end;
   end;

begin
     {parse the sites and write feature data out to a CSV file}

     try
        fStop := False;

        if fPromptToOverwrite then
           if FileExists(sFilename) then
              if (mrNo = MessageDlg('File ' + sFilename + ' exists.  Overwrite?',mtConfirmation,[mbYes,mbNo],0)) then
                 fStop := True;


        if not fStop then
        begin
             AssignFile(OutFile,sFilename);
             Rewrite(OutFile);
        end;

     except {on exception do}
            begin
                 fStop := True;
            end;
     end;

     if not fStop then
     begin
          new(pFeat);
          new(pSite);

          {write date string and description as first row of the CSV file}
          {if (sDescription = '') then
             sDescr := 'No Description Specified'
          else
              sDescr := sDescription;

          WriteLn(OutFile,Cust2DateStr + ' - ' + sDescr);}

          {write feature names as the second row of the CSV file}
          Write(OutFile,'Site Key,Site Name/Feature Names,');

          fOldNames := True;

          ControlForm.CutOffTable.Open;
          repeat
                if fOldNames then
                   try
                      sTest := ControlForm.CutOffTable.FieldByName('FEATNAME').AsString;

                   except
                         fOldNames := False;
                   end;

                if not fOldNames then
                   sTest := ControlForm.CutOffTable.FieldByName('CODE').AsString;

                write(OutFile,sTest);

                ControlForm.CutOffTable.Next;

                if not ControlForm.CutOffTable.EOF then
                   write(OutFile,',');

          until ControlForm.CutOffTable.EOF;
          ControlForm.CutOffTable.Close;
          writeln(OutFile);

          for iCount := 1 to iSiteCount do
          begin
               CombRunForm.lblStatus.Caption := 'Site ' + IntToStr(iCount) +
                           ' of ' + IntToStr(iSiteCount);
               CombRunForm.lblStatus.Refresh;

               SiteArr.rtnValue(iCount,pSite);

               if (iFlag = 2)
               and ((pSite^.status = Av)
                    or (pSite^.status = Fl)) then
               begin
                    {we need to predict irreplaceability for this site}
                    ClickValues := click_predict_sf4(iCount);
               end;

               Write(OutFile,IntToStr(pSite^.iKey) + ',' +
                             pSite^.sName + ','
                             );

               ControlForm.CutOffTable.Open;
               repeat
                     write(OutFile,
                           FloatToStr(
                           RtnValueAtSite(ControlForm.CutOffTable.FieldByName(ControlRes^.sFeatureKeyField).AsInteger)
                           ));

                     ControlForm.CutOffTable.Next;

                     if not ControlForm.CutOffTable.EOF then
                        write(OutFile,',');

               until ControlForm.CutOffTable.EOF;
               ControlForm.CutOffTable.Close;
               writeln(OutFile);

               if (iFlag = 2)
               and ((pSite^.status = Av)
                    or (pSite^.status = Fl)) then
                   ClickValues.Destroy;
          end;

          dispose(pFeat);
          dispose(pSite);
          CloseFile(OutFile);
     end;
end;

function ForceFileExt(const sFile, sExt : string) : string;
var
   iFirstPos,iLastPos : integer;
   sTmp : string;
begin
     sTmp := ExtractFileName(sFile);

     if (Pos(sExt,sFile) = 0) then
     begin
          {first remove the .XXX if there is one}
          if (Length(sTmp) > 4) then
             if (sTmp[Length(sTmp)-3] = '.') then
                sTmp := Copy(sTmp,1,Length(sTmp)-4);

          {test to see if there is _X at the end of this string}
          if (Length(sTmp) > 2) then
             if (sTmp[Length(sTmp)-1] = '_')
             and (LowerCase(sTmp[Length(sTmp)]) = LowerCase(Copy(sExt,2,1))) then
                sTmp := Copy(sTmp,1,Length(sTmp)-2);

          if (ExtractFilePath(sFile) = '') then
             sTmp := ControlRes^.sWorkingDirectory + '\' + sTmp
          else
              sTmp := ExtractFilePath(sFile) + sTmp;

          Result := sTmp + sExt;
     end
     else
         Result := sFile;
end;

function ForceMultiFilename(const sFile : string) : string;
var
   sP,sF : string;
   iPos : integer;
begin
     sP := ExtractFilePath(sFile);
     sF := ExtractFileName(sFile);

     iPos := Pos('.',sF);
     if (iPos > 1) then
        sF := Copy(sF,1,iPos-1);

     Result := sP + sF;
end;

procedure TCombRunForm.RptIrrepCombStart(sFilename:string;iCurrComb:integer);
var
   OutFile : TextFile;
   fFail : boolean;
   iCount : integer;
   pSite : sitepointer;
   sMemoText : string;
begin
     fFail := False;

     try
        assignfile(OutFile,sFilename);
        Rewrite(OutFile);

     except on exception do
            begin
                 fFail := True;
            end;
     end;

     if not fFail then
     try
        begin
             try
                if (DescrMemo.Text = '') then
                   sMemoText := 'No Description Specified'
                else
                    sMemoText := DescrMemo.Text;

                WriteLn(OutFile,Cust2DateStr + ' - ' + sMemoText);

                WriteLn(OutFile,'KEY by IRREPLACEABILITY for combsize=,' + IntToStr(iCurrComb));

                new(pSite);

                for iCount := 1 to iSiteCount do
                begin
                     SiteArr.rtnValue(iCount,pSite);

                     WriteLn(OutFile,IntToStr(pSite^.iKey) + ',' + FloatToStr(pSite^.rIrreplaceability));
                end;

             finally
                    CloseFile(OutFile);
                    dispose(pSite);
             end;
        end;

     except
           Screen.Cursor := crDefault;

           RptErrorStop('Exception in TCombRunForm.RptIrrepCombStart');
     end;
end;

function GenUniqueTmpFile(sDestPath:string):string;
var
   iCount : integer;
begin
     iCount := 0;

     repeat
           Inc(iCount);

           Result := sDestPath + IntToStr(iCount) + '.TMP';

     until not FileExists(Result);
end;

procedure TCombRunForm.RptIrrepCombAdd(sFilename:string;iCurrComb:integer);
var
   ThisLine : array [1..LINE_MAX] of Char;
   InFile, OutFile : TextFile;
   fFail : boolean;
   iLineLength, iWriteCount, iCount : integer;
   pSite : sitepointer;
   sTmp, sTmpFilename : string;
   PTmpFile, PFile : PChar;
   cAChar : char;
begin
     try

        fFail := False;

        try
           sTmpFilename := GenUniqueTmpFile(ExtractFilePath(sFilename));

           assignfile(OutFile,sTmpFilename);
           Rewrite(OutFile);

        except on exception do
               begin
                    fFail := True;
               end;
        end;

        if not fFail then
        begin
             try
                try
                   assignfile(InFile,sFilename);
                   Reset(InFile);

                except on exception do
                       begin
                            fFail := True;
                       end;
                end;

                new(pSite);

                if not fFail then
                begin
                     while not Eoln(InFile) do
                     begin
                          Read(InFile,cAChar);
                          write(OutFile,cAChar);
                     end;
                     Readln(InFile);
                     Writeln(OutFile);
                     {copy the header row of the report without modifying}

                     iLineLength := 0;

                     while not Eoln(InFile) do
                     begin
                          Inc(iLineLength);
                          Read(InFile,ThisLine[iLineLength]);
                     end;
                     Readln(InFile);

                     if (iLineLength > 0) then
                        for iWriteCount := 1 to iLineLength do
                            Write(OutFile,ThisLine[iWriteCount]);

                     sTmp := ',' + IntToStr(iCurrComb);
                     for iWriteCount := 1 to Length(sTmp) do
                         Write(OutFile,sTmp[iWriteCount]);

                     WriteLn(OutFile);
                     {write the column headers (current combsize) as the next line}

                     for iCount := 1 to iSiteCount do
                     begin
                          iLineLength := 0;

                          while not Eoln(InFile) do
                          begin
                               Inc(iLineLength);
                               Read(InFile,ThisLine[iLineLength]);
                          end;
                          Readln(InFile);

                          SiteArr.rtnValue(iCount,pSite);

                          if (iLineLength > 0) then
                             for iWriteCount := 1 to iLineLength do
                                 Write(OutFile,ThisLine[iWriteCount]);

                          sTmp := ',' + FloatToStr(pSite^.rIrreplaceability);

                          for iWriteCount := 1 to Length(sTmp) do
                              Write(OutFile,sTmp[iWriteCount]);

                          Writeln(OutFile);
                          {add each sites current irr to the rest of the file rows}
                     end;

                     closefile(InFile);
                end;

             finally
                    CloseFile(OutFile);
                    dispose(pSite);


                    if DeleteFile(PChar(sFilename)) then
                    begin
                         if not RenameFile(sTmpFilename,sFilename) then
                            MessageDlg('TCombRunForm.RptIrrepCombAdd cannot Rename tmp file',mtError,[mbOk],0);
                    end
                    else
                        MessageDlg('TCombRunForm.RptIrrepCombAdd cannot Delete old file',mtError,[mbOk],0);


                    (*
                    {GetMem(PFile,SizeOf(sFilename)+1);
                    GetMem(PTmpFile,SizeOf(sTmpFilename)+1);}
                    PFile := StrAlloc(SizeOf(sFilename)+4);
                    PTmpFile := StrAlloc(SizeOf(sTmpFilename)+4);

                    StrPCopy(PFile,sFilename);
                    StrPCopy(PTmpFile,sTmpFilename);

                    if DeleteFile(PFile) then
                    begin
                         if not RenameFile(PTmpFile,PFile) then
                            MessageDlg('TCombRunForm.RptIrrepCombAdd cannot Rename tmp file',mtError,[mbOk],0);
                    end
                    else
                        MessageDlg('TCombRunForm.RptIrrepCombAdd cannot Delete old file',mtError,[mbOk],0);

                    FreeMem(PFile{,SizeOf(sFilename)+1});
                    FreeMem(PTmpFile{,SizeOf(sTmpFilename)+1});
                    StrDispose(PFile);
                    StrDispose(PTmpFile);
                    *)

             end;
        end;

     except
           Screen.Cursor := crDefault;

           RptErrorStop('Exception in TCombRunForm.RptIrrepCombAdd  ' +
                        'file: ' + sFilename + ' current combsize: ' + IntToStr(iCurrComb));
     end;
end;

procedure ReportCombGraph(const iFile, iReport, iCombsize : integer);
var
   sRptFile : string;
   RptFile : TextFile;
   pSite : sitepointer;
   iCount : integer;
begin
     try
        new(pSite);

        sRptFile := ControlRes^.sWorkingDirectory + '\comb_detail_' + IntToStr(iFile) + '.csv';
        assignfile(RptFile,sRptFile);

        try
           append(RptFile);

        except
              rewrite(RptFile);
              writeln(RptFile,'combsize,irreplaceability');
        end;

        for iCount := 1 to iSiteCount do
        begin
             SiteArr.rtnValue(iCount,pSite);
             writeln(RptFile,IntToStr(iCombsize) + ',' + FloatToStr(pSite^.rIrreplaceability));
        end;

        closefile(RptFile);
        dispose(pSite);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReportCombGraph',mtError,[mbOk],0);
     end;
end;

function TCombRunForm.RunVariCombRpt(sFilename:string;iLow,iHigh,iStep:integer) : boolean;
var
   iCount, iReportCount, iFileCount : integer;
   fStart :  boolean;
begin
     {do something}

     try
        Screen.Cursor := crHourglass;

        iReportCount := 0;
        iFileCount := 1;
        fStart := True;

        if (iLow <= iHigh)
        and (iLow > 0) then
            for iCount := iLow to iHigh do
            begin
                 if ((iCount mod iStep) = 0) then
                 begin
                      lblStatus.Caption := 'Runs To Go: ' +
                                           IntToStr((iHigh-iCount+1) div iStep);
                      Refresh;

                      RunIrrepVariComb(iCount);

                      if fStart then
                      begin
                           RptIrrepCombStart(sFilename,iCount);
                           fStart := False;
                      end
                      else
                          RptIrrepCombAdd(sFilename,iCount);

                      {if (iCount = iLow) then
                         RptIrrepCombStart(sFilename,iCount)
                      else
                          RptIrrepCombAdd(sFilename,iCount);}

                      Inc(iReportCount);

                      if (iReportCount >= 50) then
                      begin
                           Inc(iFileCount);
                           iReportCount := 0;
                      end;

                      ReportCombGraph(iFileCount,iReportCount,iCount);
                 end;
            end;

     finally
            Screen.Cursor := crDefault;
            lblStatus.Caption := '';
     end;

     MessageDlg('RunVariCombRpt finished',mtInformation,[mbOk],0);
end;

procedure TCombRunForm.BtnFinishClick(Sender: TObject);
begin
     ModalResult := mrOk;
end;

procedure TCombRunForm.FormResize(Sender: TObject);
begin
     ClientHeight := BtnFinish.Top + BtnFinish.Height + TOOL_DIVIDE_SPACE;
     ClientWidth := BtnFinish.Left + BtnFinish.Width + TOOL_DIVIDE_SPACE;
end;

procedure TCombRunForm.FormCreate(Sender: TObject);
begin
     BtnRunReport.Top := DescrMemo.Top + DescrMemo.Height + TOOL_DIVIDE_SPACE;
     BtnFinish.Top := BtnRunReport.Top + BtnRunReport.Height + TOOL_DIVIDE_SPACE;

     case iReportFlag of
          RPT_VARI_COMB :
          begin
               BtnRunReport.Top := 136;
               BtnFinish.Top := 176;

               DescrMemo.Visible := False;
               Label6.Visible := False;

               spLow.Visible := True;
               spHigh.Visible := True;
               Label2.Visible := True;
               Label3.Visible := True;

               spLow.MaxValue := ControlForm.Available.Items.Count-1;
               spLow.MinValue := 2;
               spLow.Value := 2;

               spHigh.MaxValue := ControlForm.Available.Items.Count-1;
               spHigh.MinValue := 2;
               spHigh.Value := spHigh.MaxValue;

               edFilename.Text := ControlRes^.sWorkingDirectory + '\SAMPLE_combsize.CSV';

               lblStep.Visible := True;
               SpinStep.Visible := True;
          end;
          RPT_MATRIX, RPT_MATRIX_PAR, RPT_MATRIX_IRR, RPT_MATRIX_PTT, RPT_MATRIX_ALL,
          RPT_MATRIX_EXT, RPT_MATRIX_EXT_PAR, RPT_MATRIX_EXT_IRR, RPT_MATRIX_EXT_PTT, RPT_MATRIX_EXT_ALL :
          begin
               {BtnRunReport.Top := 230;
               BtnFinish.Top := 270;}
               DescrMemo.Visible := False;
               Label6.Visible := False;

               label5.caption := '( _matrix.CSV is added automatically )';
               case iReportFlag of
                    RPT_MATRIX_PAR : caption := 'Partial Status Matrix Report (All Features)';
                    RPT_MATRIX_IRR : caption := 'Feature Irrep. Matrix Report (All Features)';
                    RPT_MATRIX_PTT : caption := '% to Targ. Matrix Report (All Features)';
                    RPT_MATRIX_ALL : caption := 'Report All Matrix Files (All Features)';

                    RPT_MATRIX_EXT : caption := 'Matrix File Report (Extant Features)';
                    RPT_MATRIX_EXT_PAR : caption := 'Partial Status Matrix Report (Extant Features)';
                    RPT_MATRIX_EXT_IRR : caption := 'Feature Irrep. Matrix Report (Extant Features)';
                    RPT_MATRIX_EXT_PTT : caption := '% to Targ. Matrix Report (Extant Features)';
                    RPT_MATRIX_EXT_ALL : caption := 'Report All Matrix Files (Extant Features)';
               else
                   caption := 'Matrix File Report (All Features)';
               end;

               edFilename.Text := ControlRes^.sWorkingDirectory + '\SAMPLE_matrix.CSV';

               CheckSparseMatrix.Visible := True;
          end;
          RPT_SITE_COUNT :
          begin
               label5.caption := '( _count.CSV is added automatically )';
               caption := 'Site Count Report';
               edFilename.Text := ControlRes^.sWorkingDirectory + '\SAMPLE_count.CSV';
          end;
          RPT_IRREPL :
          begin
               label5.caption := '( _sites.CSV is added automatically )';
               caption := 'Site Report';
               edFilename.Text := ControlRes^.sWorkingDirectory + '\SAMPLE_sites.CSV';
          end;
          RPT_TARGETS :
          begin
               label5.caption := '( _features.CSV is added automatically )';
               caption := 'Feature Report';
               edFilename.Text := ControlRes^.sWorkingDirectory + '\SAMPLE_features.CSV';
          end;
          RPT_PART_DEF :
          begin
               label5.caption := '( _partial.TXT is added automatically )';
               caption := 'Partially Reserved Report';
               edFilename.Text := ControlRes^.sWorkingDirectory + '\SAMPLE_partial.TXT';
          end;
          RPT_MISS_FEAT :
          begin
               label5.caption := '( _missing.TXT is added automatically )';
               caption := 'Missing Features Report';
               edFilename.Text := ControlRes^.sWorkingDirectory + '\SAMPLE_missing.TXT';
          end;
          RPT_ALL_MAIN :
          begin
               label5.caption := '( File extensions are added automatically )';
               caption := 'All Main Reports';
               edFilename.Text := ControlRes^.sWorkingDirectory + '\SAMPLE';
          end;
     end;
     edFilename.SelectAll;
end;

procedure TCombRunForm.spLowChange(Sender: TObject);
begin
     try
        if (spLow.Value > spHigh.Value) then
           spLow.Value := spHigh.Value;
     except on EConvertError do;
     end;
end;

procedure TCombRunForm.spHighChange(Sender: TObject);
begin
     try
        if (spLow.Value > spHigh.Value) then
           spHigh.Value := spLow.Value;
     except on EConvertError do;
     end;
end;

procedure RecurseRemoveCommas(var sLine : string);
begin
     while Pos(',', sLine) > 0 do
           sLine[Pos(',', sLine)] := ' ';
end;


procedure TCombRunForm.BtnRunReportClick(Sender: TObject);
var
   fStop : boolean;
   sFile, sDescr, sPathFile, sExt, sRunFile : string;
   iFileHandle, iRtnValue : integer;
   PCmd : PChar;

   procedure DoThatAll(const cAChar : string);
   begin
        if (edFilename.Text = 'SAMPLE') then
           edFilename.Text := ControlRes^.sWorkingDirectory + '\SAMPLE_' + cAChar + '.CSV'
        else
            edFilename.Text := ForceFileExt(edFilename.Text,'_' + cAChar + '.CSV');
   end;

   function DoThat(const cAChar : string) : boolean;
   begin
        if (edFilename.Text = 'SAMPLE') then
           edFilename.Text := ControlRes^.sWorkingDirectory + '\SAMPLE_' + cAChar + '.CSV'
        else
            edFilename.Text := ForceFileExt(edFilename.Text,'_' + cAChar + '.CSV');

        Result := False;

        if FileExists(edFilename.Text) then
        begin
             iFileHandle := FileOpen(edFilename.Text,fmOpenWrite);
             if (iFileHandle > 0) then
             begin
                  FileClose(iFileHandle);

                  if (mrNo = MessageDlg('File ' + edFilename.Text +
                                         ' exists.  Overwrite?',mtConfirmation,
                                         [mbYes,mbNo],0)) then

                     Result := True;
             end
             else
             begin
                  MessageDlg('File ' + edFilename.Text + ' is in use',mtInformation,[mbOk],0);
                  Result := True;
             end;
        end;
   end;

   function DoThatTXT(const cAChar : string) : boolean;
   begin
        if (edFilename.Text = 'SAMPLE') then
           edFilename.Text := ControlRes^.sWorkingDirectory + '\SAMPLE_' + cAChar + '.TXT'
        else
            edFilename.Text := ForceFileExt(edFilename.Text,'_' + cAChar + '.TXT');

        Result := False;

        if FileExists(edFilename.Text) then
        begin
             iFileHandle := FileOpen(edFilename.Text,fmOpenWrite);
             if (iFileHandle > 0) then
             begin
                  FileClose(iFileHandle);

                  if (mrNo = MessageDlg('File ' + edFilename.Text +
                                         ' exists.  Overwrite?',mtConfirmation,
                                         [mbYes,mbNo],0)) then

                     Result := True;
             end
             else
             begin
                  MessageDlg('File ' + edFilename.Text + ' is in use',mtInformation,[mbOk],0);
                  Result := True;
             end;
        end;
   end;

begin
     fStop := False;
     sDescr := DescrMemo.Text;

     RecurseRemoveCommas(sDescr);

     if (sDescr = '') then
        sDescr := 'No Description Specified';

     case iReportFlag of
          RPT_VARI_COMB :
          begin
               spLowChange(self);
               spHighChange(self);
               if (edFilename.Text = 'SAMPLE') then
                  edFilename.Text := ControlRes^.sWorkingDirectory + '\SAMPLE_combsize.CSV'
               else
                   edFilename.Text := ForceFileExt(edFilename.Text,'_combsize.CSV');

               if (spLow.Value = spLow.MinValue)
               and (spHigh.Value = spHigh.MaxValue)
               and ((spHigh.Value-spLow.Value)>10) then
               begin
                    if (mrNo = MessageDlg('Use default Low and High combsize?' +
                                           Chr(13) + Chr(10) + '(This will involve ' +
                                           IntToStr((spHigh.Value-spLow.Value+1) div SpinStep.Value) +
                                           ' runs)',
                                           mtConfirmation,[mbYes,mbNo],0)) then
                       fStop := True;
               end;

               if not fStop
               and FileExists(edFilename.Text) then
               begin
                    iFileHandle := FileOpen(edFilename.Text,fmOpenWrite);
                    if (iFileHandle > 0) then
                    begin
                         FileClose(iFileHandle);
                         if (mrNo = MessageDlg('File ' + edFilename.Text +
                                           ' exists.  Overwrite?',mtConfirmation,
                                           [mbYes,mbNo],0)) then
                         fStop := True;
                    end
                    else
                    begin
                         MessageDlg('File ' + edFilename.Text + ' is in use',mtInformation,[mbOk],0);
                         fStop := True;
                    end;
               end;

               if not fStop then
               begin
                    lblStep.Visible := False;
                    RunVariCombRpt(edFilename.Text,spLow.Value,spHigh.Value,
                                   SpinStep.Value);
               end;
          end;
          RPT_MATRIX, RPT_MATRIX_PAR, RPT_MATRIX_IRR, RPT_MATRIX_PTT, RPT_MATRIX_ALL,
          RPT_MATRIX_EXT, RPT_MATRIX_EXT_PAR, RPT_MATRIX_EXT_IRR, RPT_MATRIX_EXT_PTT, RPT_MATRIX_EXT_ALL:
          begin
               Screen.Cursor := crHourglass;

               DoThatAll('matrix');

               if CheckSparseMatrix.Checked then
               begin
                    case iReportFlag of
                         RPT_MATRIX : SparseMatrixRpt(edFilename.Text,
                                                      edFilename.Text + '.key',True,False,
                                                      True,False,False,False);
                         RPT_MATRIX_PAR : SparseMatrixRpt(edFilename.Text,
                                                      edFilename.Text + '.key',True,False,
                                                          False,True,False,False);
                         RPT_MATRIX_IRR : SparseMatrixRpt(edFilename.Text,
                                                      edFilename.Text + '.key',True,False,
                                                          False,False,True,False);
                         RPT_MATRIX_PTT : SparseMatrixRpt(edFilename.Text,
                                                      edFilename.Text + '.key',True,False,
                                                          False,False,False,True);

                         RPT_MATRIX_ALL : SparseMatrixRpt(edFilename.Text,
                                                      edFilename.Text + '.key',True,False,
                                                          True,True,True,True);

                         RPT_MATRIX_EXT : SparseMatrixRpt(edFilename.Text,
                                                      edFilename.Text + '.key',True,False,
                                                          True,False,False,False);
                         RPT_MATRIX_EXT_PAR : SparseMatrixRpt(edFilename.Text,
                                                      edFilename.Text + '.key',True,False,
                                                              False,True,False,False);
                         RPT_MATRIX_EXT_IRR : SparseMatrixRpt(edFilename.Text,
                                                      edFilename.Text + '.key',True,False,
                                                              False,False,True,False);
                         RPT_MATRIX_EXT_PTT : SparseMatrixRpt(edFilename.Text,
                                                      edFilename.Text + '.key',True,False,
                                                              False,False,False,True);

                         RPT_MATRIX_EXT_ALL :
                         begin
                              SparseMatrixRpt(edFilename.Text,
                                              edFilename.Text + '.key',True,False,
                                              True,True,True,True);
                         end;
                    end;
               end
               else
               begin
                    case iReportFlag of
                         RPT_MATRIX : RunMatrixRpt(edFilename.Text,0,True);
                         RPT_MATRIX_PAR : RunMatrixRpt(edFilename.Text,1,True);
                         RPT_MATRIX_IRR : RunMatrixRpt(edFilename.Text,2,True);
                         RPT_MATRIX_PTT : RunMatrixRpt(edFilename.Text,3,True);

                         RPT_MATRIX_ALL :
                         begin
                              if (LowerCase(Copy(edFilename.Text,Length(edFilename.Text)-3,4)) = '.csv') then
                              begin
                                   // string contains extension
                                   sPathFile := Copy(edFilename.Text,1,Length(edFilename.Text)-4);
                                   sExt := '.csv';
                              end
                              else
                              begin
                                   // string does not contain extension
                                   sPathFile := Copy(edFilename.Text,1,Length(edFilename.Text));
                                   sExt := '.csv';
                              end;

                              {sPathFile := Copy(edFilename.Text,1,Length(edFilename.Text)-6);
                              sExt := Copy(edFilename.Text,Length(edFilename.Text)-5,6);}

                              RunMatrixRpt(sPathFile + '1' + sExt,0,True);
                              RunMatrixRpt(sPathFile + '2' + sExt,1,True);
                              RunMatrixRpt(sPathFile + '3' + sExt,2,True);
                              RunMatrixRpt(sPathFile + '4' + sExt,3,True);
                         end;

                         RPT_MATRIX_EXT : ExtantMatrixRpt(edFilename.Text,0,True);
                         RPT_MATRIX_EXT_PAR : ExtantMatrixRpt(edFilename.Text,1,True);
                         RPT_MATRIX_EXT_IRR : ExtantMatrixRpt(edFilename.Text,2,True);
                         RPT_MATRIX_EXT_PTT : ExtantMatrixRpt(edFilename.Text,3,True);

                         RPT_MATRIX_EXT_ALL :
                         begin
                              if (LowerCase(Copy(edFilename.Text,Length(edFilename.Text)-3,4)) = '.csv') then
                              begin
                                   // string contains extension
                                   sPathFile := Copy(edFilename.Text,1,Length(edFilename.Text)-4);
                                   sExt := '.csv';
                              end
                              else
                              begin
                                   // string does not contain extension
                                   sPathFile := Copy(edFilename.Text,1,Length(edFilename.Text));
                                   sExt := '.csv';
                              end;

                              {sPathFile := Copy(edFilename.Text,1,Length(edFilename.Text)-6);
                              sExt := Copy(edFilename.Text,Length(edFilename.Text)-5,6);}

                              ExtantMatrixRpt(sPathFile + '1' + sExt,0,True);
                              ExtantMatrixRpt(sPathFile + '2' + sExt,1,True);
                              ExtantMatrixRpt(sPathFile + '3' + sExt,2,True);
                              ExtantMatrixRpt(sPathFile + '4' + sExt,3,True);
                         end;
                    end;
               end;

               Screen.Cursor := crDefault;
          end;
          RPT_SITE_COUNT :
          begin
               fStop := DoThat('count');

               Screen.Cursor := crHourglass;
               if not fStop then
                  ReportTotals(edFilename.Text,sDescr,FALSE,
                               ControlForm.ReportBox, SiteArr, iSiteCount,
                               iIr1Count,i001Count,i002Count,i003Count,
                               i004Count,i005Count,i0CoCount,
                               ControlForm.Available.Items.Count,
                               ControlForm.Flagged.Items.Count,
                               ControlForm.Reserved.Items.Count,
                               ControlForm.Ignored.Items.Count,
                               ControlForm.R1.Items.Count,
                               ControlForm.R2.Items.Count,
                               ControlForm.R3.Items.Count,
                               ControlForm.R4.Items.Count,
                               ControlForm.R5.Items.Count,
                               ControlForm.Partial.Items.Count,
                               ControlForm.Excluded.Items.Count);

               Screen.Cursor := crDefault;
          end;

          RPT_IRREPL :
          begin
               fStop := DoThat('sites');

               Screen.Cursor := crHourglass;
               if not fStop then
                  ReportSites(edFilename.Text,sDescr,FALSE,
                              ControlForm.OutTable, iSiteCount, SiteArr, ControlRes,'');
               Screen.Cursor := crDefault;
          end;
          RPT_TARGETS :
          begin
               fStop := DoThat('features');

               Screen.Cursor := crHourglass;
               if not fStop then
                  ReportFeatures(edFilename.Text,sDescr,FALSE,
                                ControlForm.UseFeatCutOffs.Checked, FeatArr, iFeatureCount,
                                rPercentage,
                                '');

               Screen.Cursor := crDefault;
          end;
          RPT_PART_DEF :
          begin
               fStop := DoThatTXT('partial');

               Screen.Cursor := crHourglass;
               if not fStop then
                  ReportPartial(edFilename.Text,sDescr,FALSE,
                                ControlForm.ReportBox, ControlForm.PartialKey,
                                SiteArr, FeatArr, OrdSiteArr, OrdFeatArr);
               Screen.Cursor := crDefault;
          end;
          RPT_MISS_FEAT :
          begin
               fStop := DoThatTXT('missing');

               Screen.Cursor := crHourglass;
               if not fStop then
                  ReportMissingFeatures(edFilename.Text,sDescr,FALSE,
                                        ControlForm.ReportBox, ControlForm.CutOffTable, ControlRes,
                                        OrdFeatArr,FeatArr);
               Screen.Cursor := crDefault;
          end;
          RPT_ALL_MAIN :
          begin
               Screen.Cursor := crHourglass;

               try
                  sFile := ForceMultiFilename(edFilename.Text);

                  ReportTotals(sFile + '_count.CSV',sDescr,TRUE,
                               ControlForm.ReportBox, SiteArr, iSiteCount,
                               iIr1Count,i001Count,i002Count,i003Count,
                               i004Count,i005Count,i0CoCount,
                               ControlForm.Available.Items.Count,
                               ControlForm.Flagged.Items.Count,
                               ControlForm.Reserved.Items.Count,
                               ControlForm.Ignored.Items.Count,
                               ControlForm.R1.Items.Count,
                               ControlForm.R2.Items.Count,
                               ControlForm.R3.Items.Count,
                               ControlForm.R4.Items.Count,
                               ControlForm.R5.Items.Count,
                               ControlForm.Partial.Items.Count,
                               ControlForm.Excluded.Items.Count);
                  ReportSites(sFile + '_sites.CSV',sDescr,TRUE,
                               ControlForm.OutTable, iSiteCount, SiteArr, ControlRes,'');
                  ReportFeatures(sFile + '_features.CSV',sDescr,TRUE,
                                ControlForm.UseFeatCutOffs.Checked, FeatArr, iFeatureCount,
                                rPercentage,
                                '');
                  if (ControlForm.Partial.Items.Count > 0) then
                     ReportPartial(sFile + '_partial.TXT',sDescr,TRUE,
                                ControlForm.ReportBox, ControlForm.PartialKey,
                                SiteArr, FeatArr, OrdSiteArr, OrdFeatArr);
                  {ReportMissingFeatures(sFile + '_M.TXT',sDescr,TRUE,
                                         ControlForm.ReportBox, ControlForm.CutOffTable,
                                         ControlRes, OrdFeatArr,FeatArr);}
                  // create an EMS file to go with these reports
                  SaveSelections(sFile + '.log',FALSE);

               finally
                      Screen.Cursor := crDefault;
               end;
          end;
     end;

     if not fStop then
     begin
          lblStatus.Caption := 'Finished';
          lblStatus.Refresh;

          (*
          if CheckSendToExcel.Checked
          and (iReportFlag <> RPT_ALL_MAIN) then
          begin
               {launch excel and pass it this file}
               sRunFile := 'Excel.exe';{ "' + edFilename.Text + '"';}

               GetMem(PCmd,Length(sRunFile)+1);
               StrPCopy(PCmd,sRunFile);

               iRtnValue := WinEXEC(PCmd,SW_SHOW);

               FreeMem(PCmd,Length(sRunFile)+1);
          end;
          *)
     end;
end;

procedure TCombRunForm.BtnBrowseClick(Sender: TObject);
begin
     if (edFilename.Text = 'SAMPLE') then
        SaveRpt.InitialDir := ControlRes^.sWorkingDirectory
     else
         SaveRpt.InitialDir := ExtractFilePath(edFilename.Text);
     SaveRpt.FileName := ExtractFileName(edFilename.Text);
     //SaveRpt.FileName := edFilename.Text;

     if SaveRpt.Execute then
     begin
          case iReportFlag of
               RPT_VARI_COMB : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_combsize.CSV');
               RPT_MATRIX : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_matrix.CSV');
               RPT_MATRIX_PAR : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_matrix.CSV');
               RPT_MATRIX_IRR : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_matrix.CSV');
               RPT_MATRIX_PTT : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_matrix.CSV');
               RPT_SITE_COUNT : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_count.CSV');
               RPT_IRREPL : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_sites.CSV');
               RPT_TARGETS : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_features.CSV');
               RPT_PART_DEF : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_partial.TXT');
               RPT_MISS_FEAT : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_missing.TXT');
               RPT_ALL_MAIN : edFilename.Text := ForceMultiFilename(SaveRpt.FileName);

               RPT_MATRIX_ALL : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_matrix.CSV');
               RPT_MATRIX_EXT : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_matrix.CSV');
               RPT_MATRIX_EXT_PAR : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_matrix.CSV');
               RPT_MATRIX_EXT_IRR : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_matrix.CSV');
               RPT_MATRIX_EXT_PTT : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_matrix.CSV');
               RPT_MATRIX_EXT_ALL : edFilename.Text := ForceFileExt(SaveRpt.FileName,'_matrix.CSV');
          end;
          edFilename.SelectAll;
     end;
end;


{here are the reporting functions}

end.
