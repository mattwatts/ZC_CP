//----------------------------------------------------------------------------
// Global.hpp - bcbdcc32 generated hdr (DO NOT EDIT) rev: 0
// From: Global.pas
//----------------------------------------------------------------------------
#ifndef GlobalHPP
#define GlobalHPP
//----------------------------------------------------------------------------
#include <System.hpp>
namespace Global
{
//-- type declarations -------------------------------------------------------
typedef SmallString<8>  MyShortString;

typedef System::AnsiString StrArr[30];

struct LogEntry_T
{
	int iGeocode;
	Word wType;
} ;

typedef char LongLine_T[10240];

typedef Extended *realpointer;

typedef float *singlepointer;

struct Repr
{
	Extended repr_incexc;
	Extended repr_include;
	Extended repr_exclude;
	Extended irr_feature;
} ;

typedef Repr *ReprPointer;

typedef char IrrCatHeader_T[128];

typedef char IrrItem_T[3];

#pragma pack(push, 1)
struct IrrCatMember_T
{
	char Item[3];
	char cCat;
} ;
#pragma pack(pop)

struct CSVFldItem_T
{
	System::SmallString<255>  sItem;
	int iItem;
} ;

typedef Extended ClickRepr_T[500];

typedef System::??? Buff_T[200];

typedef System::??? LargeBuff_T[500];

enum GisLink_T { None, WinERMS, ArcView };

typedef bool ClassDetail_T[10];

struct ControlRes_T
{
	bool ClassDetail[10];
	System::AnsiString sDeferredAVLFile;
	System::AnsiString sAVView;
	System::AnsiString sAVTheme;
	System::AnsiString sAVAVLFile;
	System::AnsiString sInitAVLFile;
	System::AnsiString sWorkingDirectory;
	GisLink_T GisLink;
	System::AnsiString sShpKeyField;
	System::AnsiString sFeatureClassField;
	System::AnsiString sCompGeoField;
	System::AnsiString sCompNameField;
	System::AnsiString sShpTable;
	System::AnsiString sPrevCaption;
	System::AnsiString sSQLQuery;
	System::AnsiString sLastChoiceType;
	System::AnsiString sTopic;
	System::AnsiString sService;
	System::AnsiString sDatabase;
	System::AnsiString sIniPath;
	System::AnsiString sAppPath;
	System::AnsiString sSiteFeatureTable;
	System::AnsiString sSiteSummaryTable;
	System::AnsiString sFeatCutOffsTable;
	System::AnsiString sSubSites;
	System::AnsiString sSubFeatures;
	System::AnsiString sSubMatrix;
	System::AnsiString sOldCaption;
	System::AnsiString sEMRLayer;
	System::AnsiString sStatusLayer;
	int iEMRLayer;
	int iStatusLayer;
	int iDisplayValuesFor;
	int iValidateCount;
	int iControlTop;
	int iControlLeft;
	int iControlHeight;
	int iControlWidth;
	int iLookupTop;
	int iLookupLeft;
	int iLookupHeight;
	int iLookupWidth;
	bool fSizeControl;
	bool fSizeLookup;
	bool fValidateIrreplaceability;
	bool fShowExtraTools;
	bool fToolView;
	bool fShowIrrep;
	bool fShowAccept;
	bool fShowCycle;
	bool fShowToggle;
	bool fShowF2Targ;
	bool fShowContrib;
	bool fShowSelLog;
	bool fShowStageMemo;
	bool fShowPartDef;
	bool fShowOpen;
	bool fShowSave;
	bool fShowSaveAs;
	bool fShowRestTarg;
	bool fShowRedCheck;
	bool fShowBrowse;
	bool fShowPopUp;
	bool fShowExit;
	bool fMultiDDESelect;
	bool fFeatureClassesApplied;
	bool fGenerateCompRpt;
	bool fRunIrrBefRpt;
	bool fStatusOk;
	bool fOldIni;
	bool fInitialiseGIS;
	bool fLinkToWinERMS;
	bool fFeatureFormUp;
	bool fPersistControl;
	bool fPersistDBMS;
	bool fPersistFeat;
	bool fPersistTool;
	bool fPersistF2Targ;
	bool fUseNewDBLABELS;
	bool fEscapePressed;
	bool fDeSelectSite;
	bool fStayOnTop;
	bool fRandomTest;
	bool fStarting;
	bool fValidateMode;
	bool fValidateCombsize;
} ;

typedef ControlRes_T *ControlResPointer_T;

enum Status_T { Av, Ne, Ma, Pd, Fl, Ex, Ig, Re };

typedef Word BinSpace_T[8];

struct BinFileHeader_T
{
	Word wVersionNum;
	long lArrSize;
	System::TDateTime ExeDateTime;
	Word EmptySpace[8];
} ;

typedef Word MatSpace_T[8];

struct MatFileHeader_T
{
	Word wVersionNum;
	long lFeatureCount;
	Word EmptySpace[8];
} ;

typedef short feature_T[500];

typedef Extended featurearea_T[500];

typedef bool FeatureFlag_T[500];

typedef Extended FeatureValue_T[500];

typedef Word FeatureCode_T[500];

struct SiteCust_T
{
	int iCode;
	Extended rPercentUsed;
	Extended rValue2;
} ;

typedef SiteCust_T *SiteCustPointer;

struct FeatureCust_T
{
	int iCount;
	Word wCode[500];
	Extended rValue[500];
} ;

typedef FeatureCust_T *FeatureCustPointer;

typedef Extended TenExtendedArr_T[10];

typedef Extended FiveExtendedArr_T[5];

typedef Extended ElevenExtendedArr_T[11];

struct site
{
	bool fSiteHasUse;
	System::SmallString<255>  sName;
	int geocode;
	Extended area;
	short feature[500];
	short richness;
	Extended featurearea[500];
	bool PFlag[500];
	Status_T status;
	Extended rSubsetIrr[10];
	Extended rSubsetSum[10];
	Extended rSubsetWav[5];
	Extended rSubsetPCUsed[5];
	Extended rPCUSED;
	Extended rSummedIrr;
	Extended rWAVIRR;
	Extended subsmaxrf;
	System::SmallString<3>  subsord;
} ;

typedef site *sitepointer;

struct featureoccurrence
{
	int iOrdinalClass;
	int code;
	System::SmallString<255>  sID;
	Extended rNegotiated;
	Extended rMandatory;
	Extended rPartial;
	Extended rCurrentEffTarg;
	Extended rCutOff;
	Extended rSumArea;
	Extended rAreaSqr;
	Extended rCurrentSumArea;
	Extended rCurrentAreaSqr;
	Extended rExcTotal;
	Extended rTrimmedTarget;
	Extended rOriginalAvailable;
	Extended rOriginalEffectiveTarget;
	Extended rDeferredArea;
	Extended totalarea;
	Extended targetarea;
	Extended reservedarea;
	bool fRestrict;
	bool repd;
} ;

typedef featureoccurrence *featureoccurrencepointer;

struct FeatureOccurrenceSubset_T
{
	Extended targetarea;
	Extended reservedarea;
	bool repd;
} ;

typedef FeatureOccurrenceSubset_T *FeatureSubsetPointer;

struct ResourceElement_T
{
	int iGeocode;
	Extended rResource;
} ;

struct StageEntry_T
{
	System::SmallString<255>  sStageName;
	int iSelectionsInStage;
} ;

//-- var, const, procedure ---------------------------------------------------
extern System::AnsiString CPLAN_VERSION;
#define CPLAN_REGDIR "cp.rgt"
#define CPLAN_REGFILE "cp32.rgt"
#define CPLAN_REGSEED (Word)(19473)
extern System::AnsiString GEOCODE_DBLABEL;
extern System::AnsiString STATUS_DBLABEL;
extern System::AnsiString NAME_DBLABEL;
extern System::AnsiString AREA_DBLABEL;
extern System::AnsiString TENURE_DBLABEL;
extern System::AnsiString SUMMED_IRREPL_DBLABEL;
extern System::AnsiString WAVIRR_DBLABEL;
extern System::AnsiString BUILD_CLASS_DBLABEL;
extern System::AnsiString NEW_BUILD_CLASS_DBLABEL;
extern System::AnsiString NEW_PREV_DISP_DBLABEL;
extern System::AnsiString NEW_DISP_DBLABEL;
extern System::AnsiString NEW_IRREPL_DBLABEL;
extern System::AnsiString NEW_INITIRR_DBLABEL;
extern System::AnsiString NEW_PERCENT_AREA_DBLABEL;
extern System::AnsiString PERCENT_AREA_USED_DBLABEL;
extern System::AnsiString PREVIOUS_DISPLAY_CLASS_DBLABEL;
extern System::AnsiString INITIAL_IRREPLACEABILITY_DBLABEL;
extern System::AnsiString IRREPLACEABILITY_DISPLAY_CLASS_DBLABEL;
extern System::AnsiString IRREPLACEABILITY_DBLABEL;
#define max (Word)(500)
extern System::AnsiString DB_INI_FILENAME;
extern System::AnsiString DBG_FILE;
extern System::AnsiString FIND_DBG_FILE;
extern System::AnsiString CHOICE_DBG_FILE;
extern System::AnsiString AUTOSAVE_FILE;
extern System::AnsiString TOP_LAYER;
extern System::AnsiString TOP_UPDATE_ID;
extern System::AnsiString BASE_LAYER;
extern System::AnsiString BASE_UPDATE_ID;
extern System::AnsiString SERVICE_NAME;
extern System::AnsiString EMS_SEPERATOR;
extern System::AnsiString EMS_SEPARATOR;
extern System::AnsiString EMS_PERCENT;
#define BASEINDEX (Byte)(200)
#define EDIT_REASON (Byte)(201)
#define GET_CHOICE (Byte)(202)
#define VIEW_EDIT_STAGE_MEMO (Byte)(203)
#define SQL_SEL (Byte)(204)
#define SQL_UNSEL (Byte)(205)
#define SQL_MAN (Byte)(206)
#define SQL_UNMAN (Byte)(207)
#define SQL_CUSTOM (Byte)(219)
#define SQL_PROXIMITY (Byte)(220)
#define SQL_EXC (Byte)(221)
#define SQL_UNEXC (Byte)(222)
#define SQL_LOOKUP (Byte)(208)
#define SQL_MAP (Byte)(209)
#define SQL_MINSET (Shortint)(-1)
#define EMR_CAT_COUNT (Byte)(5)
#define BY_SITE (Byte)(211)
#define BY_FEATURE (Byte)(212)
#define GRAPH_EDGE_SPACE (Byte)(35)
#define DASH_STEP_SIZE (Byte)(5)
#define CHOSEN_SITES (Byte)(215)
#define WERMS_CLICK (Byte)(216)
#define WERMS_REDRAW (Byte)(217)
#define NO_ACTION (Byte)(218)
#define BROWSE_EMS_MEMO (Byte)(223)
#define RESULT_CANCEL (Byte)(224)
#define RESULT_OPEN (Byte)(225)
#define RESULT_BROWSE (Byte)(226)
#define IRREP_SUCCESS (Byte)(0)
#define IRREP_ERROR (Shortint)(-1)
#define IRREP_INIT_NEEDED (Byte)(1)
#define DEFAULT_PERCENT (Byte)(15)
#define DEFAULT_CUTOFF (Byte)(0)
#define PATH_MAX (Byte)(144)
extern System::AnsiString MEMO_STRING;
#define ARR_STEP_SIZE (Byte)(50)
extern System::AnsiString ERROR_STRING;
#define NULL_SITE_GEOCODE (Shortint)(-1)
#define DBASE_FP_CUTOFF  3.91993E-306
#define BUFF_ARR_SIZE (Byte)(200)
#define LARGE_BUFF_ARR_SIZE (Word)(500)
#define CHOICE_MESSAGE (char)(88)
#define CHOICE_CODE_DEFERR (char)(89)
#define CHOICE_CODE_DESELECT (char)(90)
#define CHOICE_BUTTON_STEP_SIZE (Byte)(5)
#define FIND_SITE (Byte)(227)
#define FIND_MEMO (Byte)(228)
#define GRID_MAX_COLUMNS (Byte)(30)
#define LOG_DEFERR (Byte)(229)
#define LOG_DESELECT (Byte)(230)
#define LINE_MAX (Word)(10240)
#define LEN_SITE_NAME (Byte)(32)
extern System::AnsiString DB_BUILD_FILENAME;
#define MIN_GRID_WIDTH (Byte)(80)
#define READ_AVAIL (Byte)(231)
#define READ_PARTIAL (Byte)(232)
#define SORT_TYPE_REAL (Byte)(233)
#define SQL_PAR (Byte)(234)
#define SQL_FLG (Byte)(235)
#define SQL_UNPAR (Byte)(236)
#define SQL_UNFLG (Byte)(237)
#define SORT_TYPE_STRING (Byte)(238)
#define RPT_DESCRIBE (Byte)(239)
#define BROWSE_EMS (Byte)(240)
#define SQL_ADD_MAP (Byte)(241)
#define SQL_UNDEFER (Byte)(242)
#define LOAD_GEOCODE (Byte)(243)
#define LOAD_NAME (Byte)(244)
#define IRR_NUM_CATS (Byte)(12)
#define IRR_HEADER_SIZE (Byte)(128)
#define IRR_ID_LENGTH (Byte)(3)
#define SQL_UNDEF_NOPAR (Byte)(245)
#define RPT_VARI_COMB (Byte)(246)
#define RPT_MATRIX (Byte)(247)
#define RPT_SITE_COUNT (Byte)(248)
#define RPT_IRREPL (Byte)(249)
#define RPT_TARGETS (Byte)(250)
#define RPT_PART_DEF (Byte)(251)
#define RPT_MISS_FEAT (Byte)(252)
#define RPT_ALL_MAIN (Byte)(253)
#define RPT_MATRIX_PAR (Byte)(254)
#define RPT_MATRIX_IRR (Byte)(255)
#define RPT_MATRIX_PTT (Word)(256)
#define RPT_MATRIX_EXT (Word)(257)
#define RPT_MATRIX_EXT_PAR (Word)(258)
#define RPT_MATRIX_EXT_IRR (Word)(259)
#define RPT_MATRIX_EXT_PTT (Word)(260)
#define RPT_MATRIX_ALL (Word)(261)
#define RPT_MATRIX_EXT_ALL (Word)(262)
extern System::AnsiString DEFAULT_SITE_SUMMARY;
extern System::AnsiString DEFAULT_FEAT_SUMMARY;
extern System::AnsiString DB_IMPORT_NODATA;
extern System::AnsiString S_MATRIX_SIZE;
extern System::AnsiString S_TIMBER_RES;
extern System::AnsiString S_RESOURCE;
extern System::AnsiString CMB_SECTION;
extern System::AnsiString CMB_COUNTLBL;
extern System::AnsiString CMB_CMBLBL;
#define TOOL_DIVIDE_SPACE (Byte)(5)
extern System::AnsiString S_NO_DESCRIPT;
#define SEL_BUTTON_HEIGHT (Byte)(20)
#define CHOICE_BUTTON_NUM_STEPS (Byte)(10)
#define SHORT_STRING_LENGTH (Byte)(8)
#define BIN_IO_PROGRESS_STEP (Byte)(100)
extern System::AnsiString PERSIST_CONTROL_FILE;
extern System::AnsiString PERSIST_DBMS_FILE;
extern System::AnsiString PERSIST_FEAT_FILE;
extern System::AnsiString PERSIST_TOOL_FILE;
extern System::AnsiString PERSIST_F2TARG_FILE;
#define BIT16_BIN_FILE_VERSION (Byte)(8)
#define BIT32_BIN_FILE_VERSION (Byte)(10)
extern System::AnsiString OLD_INI_FILE_NAME;
extern System::AnsiString INI_FILE_NAME;
#define DISPLAY_SITE_COUNT (Byte)(30)
#define TEST_ACCEPT_THIS (Byte)(101)
#define TEST_ACCEPT_ALL (Byte)(102)
#define TEST_REMOVE_THIS (Byte)(103)
#define TEST_REMOVE_ALL (Byte)(104)
#define TEST_REMOVE_REST (Byte)(105)
extern System::AnsiString DARRAYT_PAGEFILE;
#define MAT_SPACE_COUNT (Byte)(8)
#define IRREP_FLAG (Byte)(0)
#define SUMIRR_FLAG (Byte)(1)
#define WAVIRR_FLAG (Byte)(2)
#define PCCONTR_FLAG (Byte)(3)
#define MINSET_NEG (Byte)(100)
#define MINSET_MAN (Byte)(101)
#define MINSET_UNNEG (Byte)(102)
#define MINSET_UNMAN (Byte)(103)
#define MINSET_UNPAR (Byte)(104)
#define MINSET_UNNEMA (Byte)(105)
#define MINSET_UNNEMAPD (Byte)(106)
#define MINSET_MAP (Byte)(107)
#define MINSET_ADD_TO_MAP (Byte)(108)
//-- template instantiations -------------------------------------------------
template class SmallString<3> ;
template class SmallString<255> ;
template class SmallString<8> ;

}	/* namespace Global */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Global;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// Global
