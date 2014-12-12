unit Cpng_imp;
{this is the C-Plan import unit to import CPLANENG.DLL code to TOOL16.EXE

 Author: Matthew Watts
 Date: 6th June 1997}

{$I STD_DEF.PAS}

interface

uses
    Forms, Global, StdCtrls, //Arrayt16,
    DBTables, Grids, ds;

procedure ParseInsertSpace(const fOldIni : boolean;
                           const sDatabase : string;
                           App : TApplication);

function ACopyFile(const sSourceFile, sDestFile : string) : boolean;

function Status2Str (const AStatus : Status_T) : string;

{from ARR2LBOX.PAS}
function ListBox2IntArr(SourceBox : TListBox; var IntArr : Array_T) : boolean;
function ListBox2FloatArr(SourceBox : TListBox; var FloatArr : Array_T) : boolean;
function IntArr2ListBox(SourceBox : TListBox; IntArr : Array_T) : boolean;
function FloatArr2ListBox(SourceBox : TListBox; FloatArr : Array_T) : boolean;
function SortIntArray(const unsortedArray_C : array_t) : array_t;
function SortFloatArray(const unsortedArray_C : array_t) : array_t;

{added June 6 '97}
procedure _MapField2Display(const ASSTable : TTable;
                            const pred_irr, ASiteArr : Array_t;
                            const sFieldToScan : string;
                            const fBoundedTo1 : boolean;
                            const iS_Count : integer;
                            var iIr1Count, i001Count, i002Count,
                                i003Count, i004Count, i005Count,
                                i0CoCount : integer);
procedure _MapSUMIRR2EMR(const pred_irr, ASiteArr : Array_T;
                         const iS_Count : integer;
                         var iIr1Count, i001Count, i002Count,
                                i003Count, i004Count, i005Count,
                                i0CoCount : integer);
procedure _MapWAVIRR2EMR(const pred_irr, ASiteArr : Array_T;
                         const iS_Count : integer;
                         var iIr1Count, i001Count, i002Count,
                                i003Count, i004Count, i005Count,
                                i0CoCount : integer);
procedure _MapPredIrr2EMR(const pred_irr, ASiteArr : Array_T;
                          const iS_Count : integer;
                          var iIr1Count, i001Count, i002Count,
                                i003Count, i004Count, i005Count,
                                i0CoCount : integer);
function OrdStr(const iEmrCat : integer) : string;
procedure _ClearOldSQL(const ASiteArr : Array_t;
                       const iS_Count : integer);
procedure _HighlightSite(iGeo : integer;
                         Const Available, Negotiated, Mandatory, Partial, Excluded, Flagged,
                         AvailableGeocode, NegotiatedGeocode, MandatoryGeocode,
                         PartialGeocode, ExcludedGeocode, FlaggedGeocode : TListbox);
function _CountSQL(Const Available, Negotiated, Mandatory,
                         Partial, Excluded, Flagged,
                         AvailableGeocode, NegotiatedGeocode, MandatoryGeocode,
                         PartialGeocode, ExcludedGeocode, FlaggedGeocode : TListBox;
                   Const ASiteArr : Array_t;
                   Const iS_Count : integer;
                   const fKeepHighlight : boolean) : integer;
{CONTROL.PAS}
function CustDateStr : string;
function Cust2DateStr : string;
procedure UnHighlight(var ThisBox : TListBox;
                      const fKeepHighlight : boolean);
procedure Highlight(var ThisBox : TListBox);


{reporting functions
 added 11/8/97}
procedure ReportTargets(const sFile, sDescr : string; const fTestFileExists : boolean;
                        const fUseITarget : boolean; const FArr : Array_t;
                        const  iFCount, iPC : integer);
procedure ReportTotals(const sFile, sDescr : string; const fTestFileExists : boolean;
                       const RptBox : TListbox; const SArr : Array_t;
                       const iSCount, iIr1Count,i001Count,i002Count,i003Count,
                       i004Count,i005Count,i0CoCount,
                       iAv, iFl, iRe, iIg, iNe, iMa, iPd, iEx : integer);
procedure ReportMissingFeatures(const sFile,sDescr : string; const fTestFileExists : boolean;
                                const RptBox : TListbox; const CTable : TTable;
                                const CRes : ControlResPointer_T;
                                const OFArr : Array_t);
procedure ReportPartial(const sFile, sDescr : string; const fTestFileExists : boolean;
                        const RptBox, PGeocode : TListbox; const SArr : Array_t;
                        const  FArr : Array_t;
                        const OSArr, OFArr : Array_t);
procedure ReportIrrepl(const sFile, sDescr : string; const fTestFileExists : boolean;
                       const OTable : TTable; const iSCount : integer; const SArr : Array_t;
                       const CRes : ControlResPointer_T);

{stored in lbox.pas}
procedure CopyLBox2Clip(AListBox : TListBox);
procedure CopySGrid2Clip(AGrid : TStringGrid);


implementation

procedure ParseInsertSpace(const fOldIni : boolean;
                           const sDatabase : string;
                           App : TApplication); external 'CPLANENG';

function ACopyFile(const sSourceFile, sDestFile : string) : boolean; external 'CPLANENG';

function Status2Str (const AStatus : Status_T) : string; external 'CPLANENG';

{from ARR2LBOX.PAS}
function ListBox2IntArr(SourceBox : TListBox; var IntArr : Array_T) : boolean; external 'CPLANENG';
function ListBox2FloatArr(SourceBox : TListBox; var FloatArr : Array_T) : boolean; external 'CPLANENG';
function IntArr2ListBox(SourceBox : TListBox; IntArr : Array_T) : boolean; external 'CPLANENG';
function FloatArr2ListBox(SourceBox : TListBox; FloatArr : Array_T) : boolean; external 'CPLANENG';
function SortIntArray(const unsortedArray_C : array_t) : array_t; external 'CPLANENG';
function SortFloatArray(const unsortedArray_C : array_t) : array_t; external 'CPLANENG';

{added June 6 '97 from SF_IRREP.PAS}
procedure _MapField2Display(const ASSTable : TTable;
                            const pred_irr, ASiteArr : Array_t;
                            const sFieldToScan : string;
                            const fBoundedTo1 : boolean;
                            const iS_Count : integer;
                          var iIr1Count, i001Count, i002Count,
                                i003Count, i004Count, i005Count,
                                i0CoCount : integer); external 'CPLANENG';
procedure _MapSUMIRR2EMR(const pred_irr, ASiteArr : Array_T;
                         const iS_Count : integer;
                          var iIr1Count, i001Count, i002Count,
                                i003Count, i004Count, i005Count,
                                i0CoCount : integer); external 'CPLANENG';
procedure _MapWAVIRR2EMR(const pred_irr, ASiteArr : Array_T;
                         const iS_Count : integer;
                          var iIr1Count, i001Count, i002Count,
                                i003Count, i004Count, i005Count,
                                i0CoCount : integer); external 'CPLANENG';
procedure _MapPredIrr2EMR(const pred_irr, ASiteArr : Array_T;
                          const iS_Count : integer;
                          var iIr1Count, i001Count, i002Count,
                                i003Count, i004Count, i005Count,
                                i0CoCount : integer); external 'CPLANENG';
function OrdStr(const iEmrCat : integer) : string; external 'CPLANENG';
procedure _ClearOldSQL(const ASiteArr : Array_t;
                       const iS_Count : integer); external 'CPLANENG';
procedure _HighlightSite(iGeo : integer;
                         Const Available, Negotiated, Mandatory, Partial, Excluded, Flagged,
                         AvailableGeocode, NegotiatedGeocode, MandatoryGeocode,
                         PartialGeocode, ExcludedGeocode, FlaggedGeocode : TListbox); external 'CPLANENG';
function _CountSQL(Const Available, Negotiated, Mandatory,
                         Partial, Excluded, Flagged,
                         AvailableGeocode, NegotiatedGeocode, MandatoryGeocode,
                         PartialGeocode, ExcludedGeocode, FlaggedGeocode : TListBox;
                   Const ASiteArr : Array_t;
                   Const iS_Count : integer;
                   const fKeepHighlight : boolean) : integer; external 'CPLANENG';
{CONTROL.PAS}
function CustDateStr : string; external 'CPLANENG';
function Cust2DateStr : string; external 'CPLANENG';
procedure UnHighlight(var ThisBox : TListBox;
                      const fKeepHighlight : boolean); external 'CPLANENG';
procedure Highlight(var ThisBox : TListBox); external 'CPLANENG';

{reporting functions
 added 11/8/97}
{stored in reports.pas}
procedure ReportTargets(const sFile, sDescr : string; const fTestFileExists : boolean;
                        const fUseITarget : boolean; const FArr : Array_t;
                        const iFCount, iPC : integer);
                        external 'CPLANENG';
procedure ReportTotals(const sFile, sDescr : string; const fTestFileExists : boolean;
                       const RptBox : TListbox; const SArr : Array_t;
                       const iSCount, iIr1Count,i001Count,i002Count,i003Count,
                       i004Count,i005Count,i0CoCount,
                       iAv, iFl, iRe, iIg, iNe, iMa, iPd, iEx : integer);
                       external 'CPLANENG';
procedure ReportMissingFeatures(const sFile,sDescr : string; const fTestFileExists : boolean;
                                const RptBox : TListbox; const CTable : TTable;
                                const CRes : ControlResPointer_T;
                                const OFArr : Array_t); external 'CPLANENG';
procedure ReportPartial(const sFile, sDescr : string; const fTestFileExists : boolean;
                        const RptBox, PGeocode : TListbox; const  SArr : Array_t;
                        const  FArr : Array_t;
                        const OSArr, OFArr : Array_t); external 'CPLANENG';
procedure ReportIrrepl(const sFile, sDescr : string; const fTestFileExists : boolean;
                       const OTable : TTable; const iSCount : integer; const SArr : Array_t;
                       const CRes : ControlResPointer_T); external 'CPLANENG';

{stored in lbox.pas}
procedure CopyLBox2Clip(AListBox : TListBox); external 'CPLANENG';
procedure CopySGrid2Clip(AGrid : TStringGrid); external 'CPLANENG';


end.
