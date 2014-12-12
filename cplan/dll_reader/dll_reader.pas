unit dll_reader;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

const
     PChar_param : PChar = 'test PChar string';
type
     struct_ttt0_T = {packed} record
               v1 : integer;  // integer is 4 bytes
               v2 : integer;
               v3 : integer;
               dummy1 : shortint;  // shortint is 1 byte
               dummy2 : shortint;
               dummy3 : shortint;
               dummy4 : shortint;
               d1 : double;   // double is 8 bytes
               f1 : single;   // single is 4 bytes
               f2 : single;
               v4 : integer;  // Size is (4*4 + 8*1 + 4*2) = 16 + 8 + 8 = 32
                              // PLUS 4 dummy bytes added before record 4 to get it to work
                              end;
     pointer_struct_ttt0_T = ^struct_ttt0_T;

     thirtytwobytes_T = array [1..32] of byte;
     pointer_thirtytwobytes_T = ^thirtytwobytes_T;


     pointer_char_T = ^char;
     char_array_200_T = array [1..200] of char;
type
  TTestReadMSDLLForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ListBox1: TListBox;
    Label6: TLabel;
    btnTestSpatanalDLL: TButton;
    btnCloseAPI: TButton;
    Button1: TButton;
    Label7: TLabel;
    Label8: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnTestSpatanalDLLClick(Sender: TObject);
    procedure btnCloseAPIClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TestReadMSDLLForm: TTestReadMSDLLForm;

implementation

{$R *.DFM}

// import functions from v.dll
(*
C Decleration for the functions in the dll

extern "C" {

__declspec(dllexport) int makeContact( char * );

__declspec(dllexport) void * getDllBlock0();

__declspec(dllexport) int freeDllBlock0( struct ttt0 * );

__declspec(dllexport) int displayInternals( struct ttt0 * );

}
*)
function makeContact(param : PChar{pointer_char_T}) : integer; cdecl; external 'c2dtest1.dll';

function getDllBlock0 : pointer{pointer_struct_ttt0_T}; cdecl; external 'c2dtest1.dll';

function freeDllBlock0(structure : pointer{pointer_struct_ttt0_T}) : integer; cdecl; external 'c2dtest1.dll';

function displayInternals(structure : pointer{pointer_struct_ttt0_T}) : integer; cdecl; external 'c2dtest1.dll';

//makeContactSpatanalDLL
function makeContactSpatanalDLL : integer; cdecl; external 'spatdll0.dll';

function TestDllResponse : integer; cdecl; external 'spatdll0.dll';
function openAPI({var} p_api,                 // Shared_API*  p_api, /* Critical Section (CS) pointer */
                  p_hSemaphore                // HANDLE*      p_hSemaphore, /* Sema  controls the CS */
                  : pointer;
                 {const} p_inidirFN,          // char*        p_inidirFN,  /* Initialisation directory */
                  p_logFN : PChar;            // char*        p_logFN,  /* (Opt)File to append log msgs */
                 {const} debug_mode : integer // int          debug_mode /* 1=debug mode, 0=normal */
                 ) : integer; cdecl; external 'spatanal.dll';
procedure closeAPI; cdecl; external 'spatanal.dll';
function getAPI_ErrMsg : PChar; cdecl; external 'spatanal.dll';
function getAPI_DstFName : PChar; cdecl; external 'spatanal.dll';
function getAPI_Config(i : integer) : double; cdecl; external 'spatanal.dll';
function getAPI_ConfigAttrConst(i : integer) : single; cdecl; external 'spatanal.dll';
function getAPI_SpreadAttrTarget(i : integer) : single; cdecl; external 'spatanal.dll';
function getAPI_ThreadID : integer; cdecl; external 'spatanal.dll';
function getAPI_NumUnits : integer; cdecl; external 'spatanal.dll';
function getAPI_NumAttributes : integer; cdecl; external 'spatanal.dll';
function getAPI_Mode : integer; cdecl; external 'spatanal.dll';
function getAPI_Exponent : single; cdecl; external 'spatanal.dll';
function getAPI_ZoneRadius : single; cdecl; external 'spatanal.dll';
function getAPI_PlanningUnitState(i : integer) : integer; cdecl; external 'spatanal.dll';
function getAPI_PlanningUnitAttribute(i_unit, i_ftr : integer) : single; cdecl; external 'spatanal.dll';


procedure initstruct(structure : pointer_struct_ttt0_T);
begin
     structure.v1 := 4;
     structure.v2 := 3;
     structure.v3 := 2;
     structure.d1 := 3.14159;
     structure.f1 := 6;
     structure.f2 := 9;
     structure.v4 := 1;
end;

procedure TTestReadMSDLLForm.FormCreate(Sender: TObject);
var
   param : pointer_char_T;
   sTest : string[10];
   AString : string;//PChar;
   pstruct : pointer_struct_ttt0_T;
   char_array : char_array_200_T; // array [1..200] of char;
   p_char_array : pointer;         
begin
     sTest := 'test';
     param := @sTest;
     p_char_array := @char_array;
     char_array[1] := 'a';
     char_array[2] := 'b';
     char_array[3] := 'c';
     char_array[4] := char(0){'#0'};
     //AString := 'hello world';
     //param := @AString;
     //param := PChar(AString);
     makeContactSpatanalDLL;
     Label1.Caption := IntToStr(makeContact('hello matt'));
     //                                     p_char_array              this works
     //                                     {'hello world'}           this works
     //                                     {param}
     //                                     {PChar('hello world')}    this works
     //                                     {PChar_param}
     Label4.Caption := IntToStr(SizeOf(struct_ttt0_T));
     Label6.Caption := IntToStr(SizeOf(thirtytwobytes_T));
     pstruct := getDllBlock0;
     // display internals of pstruct
     listbox1.items.add('from getDllBlock0');
     listbox1.items.add('v1 ' + IntToStr(pstruct^.v1));
     listbox1.items.add('v2 ' + IntToStr(pstruct^.v2));
     listbox1.items.add('v3 ' + IntToStr(pstruct^.v3));
     listbox1.items.add('d1 ' + FloatToStr(pstruct^.d1));
     listbox1.items.add('f1 ' + FloatToStr(pstruct^.f1));
     listbox1.items.add('f2 ' + FloatToStr(pstruct^.f2));
     listbox1.items.add('v4 ' + IntToStr(pstruct^.v4));

     //displayInternals(pstruct);

     initstruct(pstruct);
     listbox1.items.add('');
     listbox1.items.add('from initstruct');
     listbox1.items.add('v1 ' + IntToStr(pstruct^.v1));
     listbox1.items.add('v2 ' + IntToStr(pstruct^.v2));
     listbox1.items.add('v3 ' + IntToStr(pstruct^.v3));
     listbox1.items.add('d1 ' + FloatToStr(pstruct^.d1));
     listbox1.items.add('f1 ' + FloatToStr(pstruct^.f1));
     listbox1.items.add('f2 ' + FloatToStr(pstruct^.f2));
     listbox1.items.add('v4 ' + IntToStr(pstruct^.v4));

     //displayInternals(pstruct);

     freeDllBlock0(pstruct);

     label8.caption := IntToStr(TestDllResponse);
end;

procedure TTestReadMSDLLForm.btnTestSpatanalDLLClick(Sender: TObject);
var
   iResult : integer;
   p1, p2, p3, p4 : pointer;
begin
     iResult := openAPI(p1,
                        p2,
                        'C:\gap_analysis\spatanal\csrc\win32\moduse',                    // path should not include trailing \
                        'C:\gap_analysis\spatanal\csrc\win32\moduse\delphi_test_1.log',  // filename should include path
                        1{USE DEBUG MODE});
     // Shared_API*  p_api, /* Critical Section (CS) pointer */
     // HANDLE*      p_hSemaphore, /* Sema  controls the CS */
     // char*        p_inidirFN,  /* Initialisation directory */
     // char*        p_logFN,  /* (Opt)File to append log msgs */


     {
     function getAPI_ErrMsg : PChar; external 'spatanal.dll'
     function getAPI_DstFName : PChar; external 'spatanal.dll'
     function getAPI_Config(i : integer) : double; external 'spatanal.dll'
     function getAPI_ConfigAttrConst(i : integer) : single; external 'spatanal.dll'
     function getAPI_SpreadAttrTarget(i : integer) : single; external 'spatanal.dll'
     function getAPI_ThreadID : integer; external 'spatanal.dll'
     function getAPI_NumUnits : integer; external 'spatanal.dll'
     function getAPI_NumAttributes : integer; external 'spatanal.dll'
     function getAPI_Mode : integer; external 'spatanal.dll'
     function getAPI_Exponent : single; external 'spatanal.dll'
     function getAPI_ZoneRadius : single; external 'spatanal.dll'
     function getAPI_PlanningUnitState(i : integer) : integer; external 'spatanal.dll'
     function getAPI_PlanningUnitAttribute(i_unit, i_ftr : integer) : single; external 'spatanal.dll'
     }

     //closeAPI;
end;

procedure TTestReadMSDLLForm.btnCloseAPIClick(Sender: TObject);
begin
     closeAPI;
end;

end.
