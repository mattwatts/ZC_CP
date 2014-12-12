unit validate;

interface

uses
    ds;

procedure ValidateDeferrSiteRpt(const fDeferral : boolean;
                                const sName : string;
                                const fComplementarity : boolean);
procedure ValidateZeroSiteRpt;

var
   iMinsetIterationCount : integer;
   ValidateIterations : Array_t;
   fValidateIterationsCreated : boolean;
   sValidateIterationsFile : string;

implementation


uses
    Reports, Control, SysUtils, FileCtrl,
    Sf_irrep, Comb_run, Forms, Dialogs,
    Dll_u1, options;

procedure ValidateDeferrSiteRpt(const fDeferral : boolean;
                                const sName : string;
                                const fComplementarity : boolean);
var
   sOutDir : string;
   fGenerateSiteAndFeatureReports : boolean;
begin
     try
        if not ControlRes^.fMinsetIsRunning then
        begin
             if ControlRes^.fRunIrrBefRpt then
                ExecuteIrreplaceability(-1,False,False,False,fComplementarity,'');

             if not fContrDoneOnce then
                ExecuteIrreplaceability(-1,False,False,False,fComplementarity,'');

             GenerateIterationReports;
        end;

     except
           MessageDlg('Exception in ValidateDeferrSiteRpt',mtError,[mbOk],0);
     end;
end;

procedure ValidateZeroSiteRpt;
var
   sOutDir : string;
   fGenerateSiteAndFeatureReports : boolean;
begin
     try
        // Only generate Site and Feature reports if we are not already
        // producing them with the comprehensive debug mode.
        if ControlRes^.fValidateMode
        and ControlRes^.fGenerateCompRpt then
            fGenerateSiteAndFeatureReports := False
        else
            fGenerateSiteAndFeatureReports := True;

        if ControlRes^.fGenerateCompRpt then
        begin
             if (ControlRes^.iValidateCount = 0) then
             begin
                  sOutDir := ControlRes^.sWorkingDirectory + '\0';
                  ForceDirectories(sOutDir);

                  if fGenerateSiteAndFeatureReports then
                  begin
                       ReportFeatures(sOutDir + '\sample' + '_features.csv',
                                      'Validate Initial',
                                      FALSE,
                                      ControlForm.UseFeatCutOffs.Checked,
                                      FeatArr,
                                      iFeatureCount,
                                      rPercentage,
                                      '');

                       ReportSites(sOutDir + '\sample' + '_sites.csv',
                               'Validate Initial',
                               FALSE,
                               ControlForm.OutTable,
                               iSiteCount, SiteArr, ControlRes,
                               '' {}
                               );
                  end;
                  {
                  SparseMatrixRpt(sOutDir + '\sample_matrix.csv',
                                  sOutDir + '\sample_key.csv',
                                  FALSE,False,
                                  True,True,True,True);
                  }
             end;
        end;

     except
           MessageDlg('Exception in ValidateZeroSiteRpt',mtError,[mbOk],0);
     end;
end;


end.
