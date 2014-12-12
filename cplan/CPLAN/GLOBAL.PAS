unit Global;
{Author: Matthew Watts
 Date:
 Purpose: Global constants and types for C-Plan}

interface

uses
    ds, version;

const
     DATABASE_KEY_FIELD : string = 'SITEKEY'; {used when constructing new databases}

     SHAPE_VALUE_FIELD : string = 'CPLANVALUE';

     {
      VERSIONS OF CPlan

      3.11 changed contact phone number on register form
           fixed up name of C-Plan installation error in 3.1

      beta 1.6 pre Eden CRA version
      beta 1.61
      beta 1.7 Eden CRA version

      beta 1.8 Date : updated 26 Nov 1997
               Description : post Eden CRA version
               Bug Fixes : Unregister bug in CPlan and installation set

      beta 2.0 UNE/LNE CRA Version

      beta 2.1 Post UNE/LNE CRA

      beta 2.11  6 Dec 1998 Version
      }

     {C-Plan registration files}
     CPLAN_REGDIR = 'cp.rgt';
     {$IFDEF VER80}
     CPLAN_REGFILE = 'cp16.rgt';
     {$ELSE}
     CPLAN_REGFILE = 'cp32.rgt';
     {$ENDIF}
     CPLAN_REGSEED = 19473 {registration seed modified on Wed 26 Nov 1997 when registration method updated}
                     {27234};

     //CSV_TYPESCAN_LINES = 1000;

     {DBMS Field Names}
     {GEOCODE_DBLABEL : string = 'KEY';}
     STATUS_DBLABEL : string = 'STATUS';
     NAME_DBLABEL : string = 'NAME';
     AREA_DBLABEL : string = 'AREA';
     {TENURE_DBLABEL : string = 'TENURE';}

     SUMMED_IRREPL_DBLABEL : string = 'SUMIRR';
     WAVIRR_DBLABEL : string = 'WAVIRR';

     BUILD_CLASS_DBLABEL : string = 'BUILDORD';

     NEW_BUILD_CLASS_DBLABEL : string = 'BUILTGIS';
     NEW_PREV_DISP_DBLABEL : string = 'PREVDISP';
     NEW_DISP_DBLABEL : string = 'DISPLAY';
     NEW_IRREPL_DBLABEL : string = 'IRREPL';
     NEW_INITIRR_DBLABEL : string = 'I_IRREPL';
     {new labels added 6/11/96 by Matt}
     NEW_PERCENT_AREA_DBLABEL : string = 'PCCONTR';



     PERCENT_AREA_USED_DBLABEL :               string = 'PCUSED';
     PREVIOUS_DISPLAY_CLASS_DBLABEL :          string = 'INITORD';
     INITIAL_IRREPLACEABILITY_DBLABEL :        string = 'INITEMR';
     IRREPLACEABILITY_DISPLAY_CLASS_DBLABEL :  string = 'SUBSORD';
     IRREPLACEABILITY_DBLABEL :                string = 'SUBSEMR';

     {---}
     {PERCENT_AREA_USED_DBLABEL :               string = 'CONTRIB';
     PREVIOUS_DISPLAY_CLASS_DBLABEL :          string = 'PREVDISPLA';
     INITIAL_IRREPLACEABILITY_DBLABEL :        string = 'INITIRREPL';
     IRREPLACEABILITY_DISPLAY_CLASS_DBLABEL :  string = 'IRREPLDISP';
     IRREPLACEABILITY_DBLABEL :                string = 'IRREPLACEA';}

     {$IFDEF SPARSE_MATRIX}
     {$ELSE}
     {$ENDIF}

     DB_INI_FILENAME : string = 'cplandb.ini';

     AUTOSAVE_FILE : string = 'autosave.log';

     {dde_unit.pas}
     TOP_LAYER : string = 'TopLayer';
     TOP_UPDATE_ID : string = 'top';
     BASE_LAYER : string = 'BaseLayer';
     BASE_UPDATE_ID : string = 'base';
     SERVICE_NAME : string = 'WinERMS';

     {.ems text file labels}
     // Note : this declaration is spelt incorrectly
     EMS_SEPERATOR : string = '***-----------seperator-----------***';
     {allow user to load old EMS file with incorrect spelling}

     EMS_SEPARATOR : string = '***-----------separator-----------***';
     EMS_PERCENT : string = 'Target Percent: ';


     BASEINDEX = 200;
     {base index for mutually exclusive integer flags}

     {editstr.pas}
     EDIT_REASON = BASEINDEX + 1;
     GET_CHOICE =  BASEINDEX + 2;
     VIEW_EDIT_STAGE_MEMO = BASEINDEX + 3;

     {sf_irrep.pas}
     EMR_CAT_COUNT = 5;

     {contribu.pas}
     BY_SITE =                 BASEINDEX + 11;
     BY_FEATURE =              BASEINDEX + 12; {flags for graph state}

     GRAPH_EDGE_SPACE = 35; {in pixels}
     DASH_STEP_SIZE =   5;

     {lookup.pas}
     CHOSEN_SITES =            BASEINDEX + 15;
     WERMS_CLICK =             BASEINDEX + 16;
     WERMS_REDRAW =            BASEINDEX + 17;
     NO_ACTION =               BASEINDEX + 18;

     {19 to 22 above, next is 23}

     {for editstr.pas, fn BrwoseSelectionMemo}
     BROWSE_EMS_MEMO =    BASEINDEX + 23;
     RESULT_CANCEL =      BASEINDEX + 24;
     RESULT_OPEN =        BASEINDEX + 25;
     RESULT_BROWSE =      BASEINDEX + 26;

     {sql_unit.pas}
     SQL_R1 = 1;
     SQL_R2 = 2;
     SQL_R3 = 3;
     SQL_R4 = 4;
     SQL_R5 = 5;
     SQL_UNR1 = 6;
     SQL_UNR2 = 7;
     SQL_UNR3 = 8;
     SQL_UNR4 = 9;
     SQL_UNR5 = 10;
     SQL_CUSTOM = 11;
     SQL_PROXIMITY = 12;
     SQL_EXC = 13;
     SQL_UNEXC = 14;
     SQL_LOOKUP =15;
     SQL_MAP = 16;
     SQL_MINSET = 17;

     {control.pas}
     IRREP_SUCCESS = 0;
     IRREP_ERROR = -1;
     IRREP_INIT_NEEDED = 1;

     DEFAULT_PERCENT = 15;
     DEFAULT_CUTOFF = 0;

     PATH_MAX = 144;
     MEMO_STRING : string = '(Memo)';
     ARR_STEP_SIZE = 1000;
     ERROR_STRING : string = 'ERROR';
     NULL_SITE_GEOCODE  = -1;
     DBASE_FP_CUTOFF = 0.00001;
     BUFF_ARR_SIZE = 2000;
     LARGE_BUFF_ARR_SIZE = 500;

     {choices.pas}
     CHOICE_MESSAGE = 'X';
     CHOICE_CODE_DEFERR = 'Y';
     CHOICE_CODE_DESELECT = 'Z';
     CHOICE_BUTTON_STEP_SIZE = 5;

     FIND_SITE =     BASEINDEX + 27;
     FIND_MEMO =     BASEINDEX + 28;

     GRID_MAX_COLUMNS = 30;

     LOG_DEFERR =    BASEINDEX + 29;
     LOG_DESELECT =  BASEINDEX + 30;

     LINE_MAX = 200000; {maximum length of LongLine_T input text line}

     LEN_SITE_NAME = 32; {length of site name for output .TRN files}

     DB_BUILD_FILENAME : string = 'build';


     MIN_GRID_WIDTH = 80;

     READ_AVAIL = BASEINDEX + 31;
     READ_PARTIAL = BASEINDEX + 32;
     {flags for PartEdForm activate}
     SORT_TYPE_REAL = BASEINDEX + 33;

     SQL_PAR = BASEINDEX + 34;
     SQL_FLG = BASEINDEX + 35;
     SQL_UNPAR = BASEINDEX + 36;
     SQL_UNFLG = BASEINDEX + 37;

     SORT_TYPE_STRING = BASEINDEX + 38;
     RPT_DESCRIBE = BASEINDEX + 39;

     BROWSE_EMS = BASEINDEX + 40;

     SQL_ADD_MAP = BASEINDEX + 41;
     SQL_UNDEFER = BASEINDEX + 42;

     LOAD_GEOCODE = BASEINDEX + 43;
     LOAD_NAME = BASEINDEX + 44;

     {mk_irr.pas}
     IRR_NUM_CATS = 12;
     IRR_HEADER_SIZE = 128;
     IRR_ID_LENGTH = 3;

     SQL_UNDEF_NOPAR = BASEINDEX + 45;

     RPT_VARI_COMB = BASEINDEX + 46;
     RPT_MATRIX = BASEINDEX + 47;


     {RPT_ALL_MAIN does this group of reports}
     RPT_SITE_COUNT = BASEINDEX + 48;
     RPT_IRREPL = BASEINDEX + 49;
     RPT_TARGETS = BASEINDEX + 50;
     RPT_PART_DEF = BASEINDEX + 51;
     RPT_MISS_FEAT = BASEINDEX + 52;
     RPT_ALL_MAIN = BASEINDEX + 53;

     {new report flags for system testing reports}
     RPT_MATRIX_PAR = BASEINDEX + 54;
     RPT_MATRIX_IRR = BASEINDEX + 55;
     RPT_MATRIX_PTT = BASEINDEX + 56;
     RPT_MATRIX_EXT = BASEINDEX + 57;
     RPT_MATRIX_EXT_PAR = BASEINDEX + 58;
     RPT_MATRIX_EXT_IRR = BASEINDEX + 59;
     RPT_MATRIX_EXT_PTT = BASEINDEX + 60;
     RPT_MATRIX_ALL = BASEINDEX + 61;
     RPT_MATRIX_EXT_ALL = BASEINDEX + 62;

     DEFAULT_SITE_SUMMARY : string = 'S_V2.DBF'{'c:\winerms\s_def.dbf'};
     DEFAULT_FEAT_SUMMARY : string = 'FS_V2.DBF'{'c:\winerms\fs_def.dbf'};

     DB_IMPORT_NODATA : string = '0';

     S_MATRIX_SIZE : string = 'MatrixSize';
     S_TIMBER_RES : string = 'Timber Resource';
     S_RESOURCE : string = 'Resource';
     CMB_SECTION : string = 'Combination Size';
     CMB_COUNTLBL : string = 'SiteCount';
     CMB_CMBLBL : string = 'CombSize';

     TOOL_DIVIDE_SPACE = 5;

     S_NO_DESCRIPT : string = 'No Description Specified';
     SEL_BUTTON_HEIGHT = 20;

     CHOICE_BUTTON_NUM_STEPS = 10;

     SHORT_STRING_LENGTH = 8;

     BIN_IO_PROGRESS_STEP = 100;

     PERSIST_CONTROL_FILE : string = 'CONTROL.POS';
     PERSIST_DBMS_FILE : string = 'DBMS.POS';
     PERSIST_FEAT_FILE : string = 'FEAT.POS';
     PERSIST_TOOL_FILE : string = 'TOOL.POS';
     PERSIST_F2TARG_FILE : string = 'F2TARG.POS';

     BIT16_BIN_FILE_VERSION = 8{6 4}; {used to be 2}
     BIT32_BIN_FILE_VERSION = 14{changed from 13 to 14 6Dec1998 for version beta2.11 new feature spaces}
                                {changed from 12 to 13 17Aug1998 when rVulnerability added to featureoccurrence}
                                {changed from 11 to 12 30June1998 when rExtantArea added to featureoccurrence}
                                {changed from 10 to 11 26 May 1998 when datatypes changed in site/featureoccurrence}
                                {changed from 9 to 10  18thFeb1998 optimised for 50/150/500 features}
                                {7 5}; {used to be 3}

     OLD_INI_FILE_NAME : string = 'EMRTOOL.INI';
     INI_FILE_NAME : string = 'CPLAN.INI';

     DISPLAY_SITE_COUNT = 30;
     {default maximum number of sites displayed in the contribution form}


     TEST_ACCEPT_THIS = 101;
     TEST_ACCEPT_ALL  = 102;
     TEST_REMOVE_THIS = 103;
     TEST_REMOVE_ALL  = 104;
     TEST_REMOVE_REST = 105;
     {return flags for TestToUnDeferSites, DEFRQRY.PAS}

     DARRAYT_PAGEFILE : string = 'page';

     {$IFDEF VER90}
     MAT_SPACE_COUNT = 8;
     {$ELSE}
     MAT_SPACE_COUNT = 8;
     {$ENDIF}

     IRREP_FLAG = 0;
     SUMIRR_FLAG = 1;
     WAVIRR_FLAG = 2;
     PCCONTR_FLAG = 3;

     {flags for minset selection and deselection from Control menu}
     MINSET_R1 = 100;
     MINSET_R2 = 101;
     MINSET_R3 = 102;
     MINSET_R4 = 103;
     MINSET_R5 = 104;
     MINSET_UNR1 = 105;
     MINSET_UNR2 = 106;
     MINSET_UNR3 = 107;
     MINSET_UNR4 = 108;
     MINSET_UNR5 = 109;
     MINSET_UNPAR = 110;
     MINSET_UNR1R2R3R4R5 = 111;
     MINSET_UNR1R2R3R4R5PD = 112;
     MINSET_MAP = 113;
     MINSET_ADD_TO_MAP = 114;
     MINSET_LOOKUP = 115;

type
    ////////////////////////////////////////////////////////////////////////////
    ///       //  ////  //     ///    //////////////////////////////////////////
    /////  //////  /  ////  //  //  ////////////////////////////////////////////
    /////  ///////  //////     ///    //////////////////////////////////////////
    /////  ///////  //////  //////  ////////////////////////////////////////////
    /////  ///////  //////  //////    //////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    BLF_T = record
          iId1, iId2 : integer;
          rBoundary : extended;
            end;

    ReportFeatIrr_T = record
       iSiteKey, iFeatKey : integer;
       rFeatIrr : extended;
                      end;

    // added 18 aug 2000 for combination size
    CombinationSize_T = record
       iSelectedCombinationSize,        // selected by conditions Startup, ExclusionChange, TargetChange, UserLoadLog
       iCurrentSelectedCombinationSize, // selected by MinsetLoadLog, TriggerTargetCannotBeMet, TriggerZeroAvSumirr
       iCurrentSitesUsed,               // sites used when above combination size selected, used for adjusting for reserves
       iCustomCombinationSize,          // set by user
       iActiveCombinationSize,          // combination size in use
       iActiveNoComplCombinationSize    // combination size in use with no complementarity
        : integer;
                        end;


    // added 17 aug 2000 for combination size
    CombinationSizeCondition_T = (Startup,                   // At Startup
                                  ExclusionChange,           // When sites are excluded or removed from excluded
                                  TargetChange,              // Change in targets
                                  UserLoadLog,               // user loads a log file
                                  OverrideChange,
                                  MinsetLoadLog,             // Loading a 'starting condition' log file in minset
                                  TriggerTargetCannotBeMet,  // Feature target cannot be met at current CS
                                  TriggerZeroAvSumirr,       // All Av sites have zero SUMIRR when all targets are not met
                                  TriggerExcludedSite);      // excluded sites trigger

    // added 20 mar 2000 for new sumirr weightings for the minset
    MinsetSumirrWeightings_T = record
        rWcr,       // i) W crown
        rWpt,       // ii) W proportional tgt (E.A. weighting)
        rWcrWit,    // iii) W crown AND W inverse tgt
        rWcrWvu,    // iv) W crown AND W vuln
        rWcrWitWvu, // v) W crown AND W inverse tgt AND W vuln
        rWsa,       // vi) W Toms standardised area
        rWsaWpa,    // vii) W Toms standardised area AND W proportional area
        rWsaWpt,    // Toms standardised area & proportional target  ** ADDED 1may00
        rWpaWpt     // proportional area and proportional target     ** ADDED 1may00
        : extended;
    end;

    str255 = string[255];

    QueryRequest_T = record
                   fHighest : boolean; {True means highest, False means lowest}
                   sVariable : str255;
                   rPercentage : extended;
                     end;

    // these types are for the sparse matrix implementation
    KeyFile_T = record
                  iSiteKey : integer;
                  iRichness : word;
                end;
    ValueFile_T = record
                    iFeatKey : word;
                    rAmount : extended;
                  end;
    SingleValueFile_T = record
                    iFeatKey : word;
                    rAmount : single;
                  end;

    MyShortString = string[SHORT_STRING_LENGTH];

    StrArr = array [1..GRID_MAX_COLUMNS] of string;

    LogEntry_T = record
         iKey : integer;
         wType : word;
    end;
    SelectionEntry_T = record
         iKey, iSelection : integer;
         wType : word;
    end;

    LongLine_T = array [1..LINE_MAX] of Char;

    realpointer = ^extended;
    singlepointer = ^single;

    Repr = record
         repr_incexc,
         repr_include,
         repr_exclude,
         irr_feature : extended;
           end;

    ReprPointer = ^Repr;

    IrrCatHeader_T = array [1..IRR_HEADER_SIZE] of char;

    IrrItem_T = array [1..IRR_ID_LENGTH] of char;

    IrrCatMember_T = record
         Item : IrrItem_T;
         cCat : char;
                     end;

    CSVFldItem_T = record
        sItem : string[255];
        iItem : integer;
                   end;

    {$IFDEF SPARSE_MATRIX_2}
    {$ELSE}
    ClickRepr_T = array [1..max] of extended;
    {$ENDIF}

    Buff_T = array [1..BUFF_ARR_SIZE] of real;
    LargeBuff_T = array [1..LARGE_BUFF_ARR_SIZE] of real;
    BuffV4_T = array [1..LARGE_BUFF_ARR_SIZE] of single;

    GisLink_T = (None, ArcView, ZonaeCogito);
    {possible GIS linkage states C-Plan}

    {stores which classes are in use}
    ClassDetail_T = array[1..10] of boolean;

    VulnerabilityWeightings_T = array [1..5] of single;

    ControlRes_T = record
        iSimulationYear,
        iRetrieveMarxanDetailNumber,
        iRetrieveMarxanDetailStart,
        iExecuteIrreplaceabilityCount,
        iCombinationSizeRange,
        iVulnWeightingType,
        iScalingType,
        iSelectIterationCount,
        iDisplayScheme,
        iSiteAREAFeature,
        iFeaturesWithPATCHCON, iFeaturesWithSRADIUS,
        iSpatialContribRadius,
        iGISPlotField,
        iSpatialVectorsToPass, iSpatialVariableToPass,
        iLookupDebugReports,
        iSelectMapSites, {added 1 July 1998 for storing user choices for}
        iEMRLayer, iStatusLayer, {Info about WinERMS Layers}
        iDisplayValuesFor, {indicates whether displaying irr values for:
                              Available Sites (0), default or
                              Deferred Sites (1)}
        iValidateCount,
        iControlTop, iControlLeft, iControlHeight, iControlWidth,
        iLookupTop, iLookupLeft, iLookupHeight, iLookupWidth {position and size of ControlForm and LookupForm}
        : integer;

        fDoConfigOnSubset : ClassDetail_T;

        fLoadSiteVuln,
        fLoadSiteCost,
        fOptimisedMarxan,
        fStartDestructReportsRun,
        fRetrieveMarxanDetailToSiteTable,
        fLockReserve,
        fGenerate_TXT_DBF_log,
        fDisplayCSTriggerPopup,
        fR2Visible, fR3Visible, fR4Visible, fR5Visible,
        fMarxanDatabaseExists,
        fNullHotspotsSimulation,
        fReportTargetFieldLoaded,
        fGISRegionalSettingIsEnglish,
        fPointFeaturesSpecified,
        fReportMinsetMemSize,
        fValidateMinset,
        fLockUserDefinedCombinationSize,
        fValidateIterationsFileSpecified,
        fDumpAverageSite,
        fPartialValidateCombsize,
        fUpdateGISValues,
        fRedCheckExcludeSitesCreated,
        fUseContinuousVuln,
        fLogCombsizeRecalc,
        fCalculateBobsExtraVariations, // added 20.3.00, calcluate bobs extra sumirr weightings
        fMinsetIsRunning,
        fCSSelectChange, fDisplayAbsSumirr,
        fInitialValuesCreated, fDebugLookup,
        fDESTRATELoaded, // tells if DESTRATE specified by user in FSTable
        fDestructObjectsCreated, fRecalcSpatialCONTRIB, fPrepareSpreadRun, fRecalcContrib,
        fDebugSPATTOOL, fSpatResultCreated, fConnectSPATTOOL, fConnectedToSPATTOOL,
        fCheckMatrixOrder, {check order of site identifiers in the matrix when loading}
        fSizeControl, fSizeLookup, {flags for ControlForm,LookupForm position and size}
        fReportTime, {produce a report of execution times}
        fValidateIrreplaceability, fShowExtraTools,
        fToolView, {indicates if ToolForm is visible (ie. ControlForm invisible)}
        fShowIrrep,fShowAccept,fShowCycle,fShowToggle,
        fShowF2Targ,fShowContrib,fShowSelLog,fShowStageMemo,
        fShowPartDef,fShowOpen,fShowSave,fShowSaveAs,
        fShowRestTarg,fShowRedCheck,fShowBrowse,
        fShowPopUp,fShowExit, {options on show buttons ToolForm}
        fMultiDDESelect, fFeatureClassesApplied, fGenerateCompRpt, fRunIrrBefRpt,
        fStatusOk, {says whether site status and feature targets are up to date}
        fOldIni, fInitialiseGIS,
        fLinkToWinERMS, fFeatureFormUp,
        fPersistControl, fPersistDBMS, fPersistFeat, fPersistTool, fPersistF2Targ,
        fUseNewDBLABELS, fEscapePressed,
        fDeSelectSite, fStayOnTop, fRandomTest, fStarting,
        fValidateMode, fValidateCombsize, fCustomCombSize,
        fOptionCreate, fSRADIUSLoaded, fPATCHCONLoaded,
        fFloatVulnerabilityLoaded, fVulnerabilityLoaded, fCalculateAllVariations,
        fSumirrWeightArea, fSumirrWeightTarget, fSumirrWeightVuln,
        fZoomOnSelect, {selecting and zooming in on mapped sites}
        fExtantLoaded, fKeyTested,
        fFeatureKeyTested, fStatusTested,
        fSuppressCSExclusionRecalc : boolean;

        VulnerabilityWeightings : VulnerabilityWeightings_T;
        LastCombinationSizeCondition : CombinationSizeCondition_T;

        rSpatialContribExponent,
        rSpatialConfigAreaWeighting,
        rSummedMinimumWeight, rSpatContribReservedWeight : single;
        rTargetMultiplyFactor,
        rDisplayMaximumValue : extended;

        ClassDetail : ClassDetail_T;
        GisLink : GisLink_T;

        sZCProject,
        sSiteVulnFieldName,
        sSiteCostFieldName,
        sDESTRATEField,
        sMarxanCostField,
        sMarxanDatabasePath,
        sMarxanOutputPath,
        sSpatialVariableToPass,
        sReportTargetField,
        sPointFeatureField,
        sFeatureTargetField,
        sFloatVulnerabilityField,
        sSpatialDistanceFile,
        sSparseMatrix, sSparseKey,
        sFeatureKeyField, sI_STATUSField,
        sKeyField,
        sDatabaseName,
        sDeferredAVLFile,
        sAVView, sAVTheme, sAVAVLFile, sInitAVLFile,
        sAVKeyField,
        sWorkingDirectory, {user specified default directory for file output,
                           defaults to sDatabase if not specified in INI [Options]}
        sShpKeyField, {key field in ArcView shape table}
        sFeatureClassField, {field in FSTable that feature sub-classes have been loaded from}
        sCompGeoField, sCompNameField,
        sShpTable,
        sPrevCaption,
        sSQLQuery, {if choice is SQL, this contains query used}
        sLastChoiceType, {last User choice type}
        sTopic, sService, sDatabase,
        sIniPath, sAppPath,
        sSiteFeatureTable, sSiteSummaryTable,
        sFeatCutOffsTable,
        {sSubSites,sSubFeatures,sSubMatrix, {files for subcompartment layer (if available)}
        sOldCaption,
        sEMRLayer, sStatusLayer,
        sR1Label, sR2Label, sR3Label, sR4Label, sR5Label : string;
    end;

    ControlResPointer_T = ^ControlRes_T;

    Status_T = (Av,_R1,_R2,_R3,_R4,_R5,Pd,Fl,Ex,Ig,Re);

    Tenure_T = (Ava,Res,Ign);

    {.bin and .mat file types}
    BinSpace_T = array[1..8] of word; {16 bytes}

    {BinFileHeader_T is 22 bytes altogether}
    BinFileHeader_T = record
                            wVersionNum : word; {2 bytes}
                            lArrSize : longint; {4 bytes}
                            ExeDateTime : TDateTime;

                            EmptySpace : BinSpace_T;
                      end;

    MatSpace_T = array[1..MAT_SPACE_COUNT] of word;

    {MatFileHeader_T is 22 bytes altogether}
    MatFileHeader_T = record
                            wVersionNum : word; {2 bytes}
                            lFeatureCount : longint; {4 bytes}

                            EmptySpace : MatSpace_T;
                      end;

{types previously declared in EM_NEWU1.PAS}
type
  {$IFDEF SPARSE_MATRIX_2}
  {$ELSE}
  feature_T = array[1..max] of word;
  featurearea_T = array[1..max] of single;
  FeatureFlag_T = array[1..max] of boolean;
  FeatureValue_T = array [1..max] of single;
  FeatureCode_T = array [1..max] of word;
  {$ENDIF}

  SiteCust_T = record
              {iCount : integer;}
              iCode : integer;
              rPercentUsed : single;
              {rValue : extended;}
              rValue2 : single;
  end;

  SiteCustPointer = ^SiteCust_T;

  {$IFDEF SPARSE_MATRIX_2}
  {$ELSE}
  FeatureCust_T = record
                 iCount : word;
                 wCode : FeatureCode_T;
                 rValue : FeatureValue_T;
  end;
  FeatureCustPointer = ^FeatureCust_T;
  {$ENDIF}

  {$IFDEF CPLAN_APP}
  GraphData_T = record
              Sites : Array_T{SitesCust_T};
              Features : Array_T{array [1..totalsites] of ^FeaturesCust_T};
              {iCount : integer;}
  end;
  {$ENDIF}

  TenExtendedArr_T = array[1..10] of single;
  FiveExtendedArr_T = array[1..5] of single;
  ElevenExtendedArr_T = array[1..11] of extended;

  site=record
         fSiteHasUse : boolean;
         fPartialProtection : boolean;
         sName : string[255];
         iKey:integer;
         area:extended;
         richness: smallint;
         status:  Status_T;
         rSubsetIrr, rSubsetSum : TenExtendedArr_T;
         rSubsetWav, rSubsetPCUsed : FiveExtendedArr_T;
         rPCUSED, rSummedIrr, rWAVIRR, rIrreplaceability, rSummedIrrVuln2 :extended;
         sDisplay:string[3];
         sSubclass:string[30];
         iOffset : integer;
       end;

  sitepointer=^site;

  WeightedSumirr_T = record
                       r_a, r_t, r_v, r_at, r_av, r_atv, r_tv : single; {7 combinations of Area, Tgt. & Vuln}
                       r_sub_a, r_sub_t, r_sub_v, r_sub_at,
                       r_sub_av, r_sub_atv, r_sub_tv : TenExtendedArr_T; {7 combinations of Area, Tgt. & Vuln for
                                                                          each of the 10 possible feature subsets}
                     end;

type
  featureoccurrence=record
                 rSRADIUS, rPATCHCON, rVulnerability, rFloatVulnerability : single;
                 iOrdinalClass,
                 code : word;
                 sID : string[255];
                 sSIZE : string[6];
                 rTrimmedArea,
                 rExtantArea,
                 rR1,rR2,rR3,rR4,rR5,rPartial, rCurrentEffTarg,
                 rCutOff,
                 rSumArea,      // available
                 rAreaSqr,
                 rCurrentSumArea, rCurrentAreaSqr,
                 rExcluded,
                 rTrimmedTarget, rInitialTrimmedTarget,
                 rInitialAvailable,
                 rInitialAvailableTarget,
                 rDeferredArea, // proposed reserved
                 totalarea,
                 targetarea,
                 reservedarea   // initial reserved
                 :extended;
                 fRestrict, {toggled to switch on/off feature targs}
                 repd:boolean;
               end;

  featureoccurrencepointer = ^featureoccurrence;

  FeatureOccurrenceSubset_T=record
  {this dataset is for processing contribution of Selected and Mandatory
   sites to the reservation target percentage}
                     targetarea : extended;
                     reservedarea : extended;
                     repd : boolean;
  end;

  FeatureSubsetPointer = ^FeatureOccurrenceSubset_T;

  {type declerations for the minset code}
  ResourceElement_T = record
            iKey : integer;
            rResource : extended;
                      end;

  StageEntry_T = record
        sStageName : string[255];
        iSelectionsInStage : integer;
                 end;

  {datatypes used by ImportFieldsToTable in unit fieldimp}
  FDType_T = (DBaseFloat,
              DBaseInt,
              DBaseStr);
  FieldDataType_T = record
                  DBDataType : FDType_T;
                  iSize : integer; {length of string if DBaseStr is string}
                  iDigit2 : integer; {added 28 july 1998}
                    end;
  AddField_T = record
        sName : string;
        DataType : FieldDataType_T;
               end;
  SourceField_T = record
        sTableContainingField,
        sSourceFieldName,
        sDestinationFieldName : string;
        FieldDataType : FieldDataType_T;
        rConversionFactor : extended;
                  end;

   AddFieldType_T = (C, N);


   FieldSpec_T = record
                   sName{, sPreviousName} : string[255];
                   FieldType : AddFieldType_T; {C (char) or N (numeric)}
                   iDigit1,
                   iDigit2 : integer;
                 end;

   InitialValues_T = record
                       rIrr, rSumIrr, rWavIrr : extended;
                     end;

   dBaseHeader_T = record
                     bVersionNumber : byte;
                     iRecordCount, iFieldCount : integer;
                   end;


   Hotspots_Area_Indices_T = record
                 rWeightedPercentTarget, rMaxRarity, rRichness, rSummedRarity,
                 rIrreplaceability,
                 rSumirr : extended;
   end;



implementation

end.
