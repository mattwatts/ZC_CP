unit Sql_unit;

{$I STD_DEF.PAS}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, DB, DBTables, Menus,
  Em_newu1, Global, Spin, ds, Arr2lbox;

type
  TSQLForm = class(TForm)
    FieldBox: TListBox;
    Label2: TLabel;
    Values: TComboBox;
    Operator: TRadioGroup;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    btnOR: TButton;
    btnAND: TButton;
    btnUndo: TButton;
    lblValues: TLabel;
    SQLQuery: TQuery;
    btnSave: TButton;
    btnLoad: TButton;
    SQLSave: TSaveDialog;
    SQLOpen: TOpenDialog;
    checkLoadValues: TCheckBox;
    QueryTable: TTable;
    Button1: TButton;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Load1: TMenuItem;
    Save1: TMenuItem;
    Exit1: TMenuItem;
    SQL1: TMenuItem;
    Accept1: TMenuItem;
    Execute1: TMenuItem;
    N1: TMenuItem;
    OR1: TMenuItem;
    AND1: TMenuItem;
    UNDO1: TMenuItem;
    N2: TMenuItem;
    checkSortValues: TCheckBox;
    btnNot: TButton;
    btnAccept: TButton;
    btnExecute: TButton;
    N3: TMenuItem;
    NOT1: TMenuItem;
    SortBox: TListBox;
    Button2: TButton;
    Button3: TButton;
    ResultMemo: TMemo;
    TestBox: TListBox;
    Label1: TLabel;
    lblStatProfile: TLabel;
    CheckAnalyseValues: TCheckBox;
    SpinValue: TSpinEdit;
    CheckExcludeZeroValues: TCheckBox;
    procedure FieldBoxClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure btnORClick(Sender: TObject);
    procedure btnANDClick(Sender: TObject);
    procedure btnUndoClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Accept1Click(Sender: TObject);
    procedure Execute1Click(Sender: TObject);
    procedure btnNotClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure LoadValues(const sField : string);
    procedure SortIntFields;
    procedure SortFloatFields;
    procedure SortStringFields;
    procedure checkLoadValuesClick(Sender: TObject);
    procedure ValuesChange(Sender: TObject);
    procedure ResultMemoKeyPress(Sender: TObject; var Key: Char);
    procedure checkSortValuesClick(Sender: TObject);
    procedure ResultMemoKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PrepareForm;
    procedure OperatorClick(Sender: TObject);
    procedure SpinValueChange(Sender: TObject);
    procedure CheckExcludeZeroValuesClick(Sender: TObject);
    function ContainsHighest : boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;



procedure GrabSQLExpression; {forward declaration}
procedure SeeQuery;

procedure RunSQL(const iFlag : integer);
procedure UseResults;
procedure BuildCustom(const iNumCodes : integer; const Codes : Array_T{GeocodeList_T});
//procedure MapSQL(const iNumCodes : integer; const SomeCodes : Array_T;
//                 const fDestroyArray : boolean);

function RtnLoadStatusString : string;
procedure UpdateQuery;
procedure LookupSQL(const iNumCodes : integer; var SomeCodes : Array_T);
function Status2Str (const AStatus : Status_T) : string;

var
  SQLForm: TSQLForm;
  sSQLFileName, sSQLDatabase, sSearchDB : string;
  iLocalFlag, iNumCodes, iOldNumCodes : integer;
  Codes : Array_T;
  CurrentFieldType : TFieldType;

implementation

uses Control, Lookup, Contribu,
     Sf_irrep, Partl_ed, Toolmisc, SORTS,
     minset, comp2coo, av1, rules;

{$R *.DFM}

procedure LookupSQL(const iNumCodes : integer; var SomeCodes : Array_T);
begin
     if (iNumCodes > 0) then
     begin
          StartLookupArr(SomeCodes);
     end;
end;

procedure UnDeferSQL(iNumCodes : integer;
                     Codes : Array_T);
var
   Codes2, Codes3, Codes4, Codes5, Codes6 : Array_T;
   iCode, iCount : integer;
begin
     {makes Negotiated and Mandatory sites Available}

     with ControlForm do
     begin
          Codes2 := Array_t.Create;
          Codes2.init(SizeOf(iCode),iNumCodes);
          Codes3 := Array_t.Create;
          Codes3.init(SizeOf(iCode),iNumCodes);
          Codes4 := Array_t.Create;
          Codes4.init(SizeOf(iCode),iNumCodes);
          Codes5 := Array_t.Create;
          Codes5.init(SizeOf(iCode),iNumCodes);
          Codes6 := Array_t.Create;
          Codes6.init(SizeOf(iCode),iNumCodes);

          for iCount := 1 to iNumCodes do
          begin
               Codes.rtnValue(iCount,@iCode);
               Codes2.setValue(iCount,@iCode);
               Codes3.setValue(iCount,@iCode);
               Codes4.setValue(iCount,@iCode);
               Codes5.setValue(iCount,@iCode);
               Codes6.setValue(iCount,@iCode);
          end;

          MoveSome(R1,R1Key,Available,AvailableKey,iNumCodes,Codes);
          MoveSome(R2,R2Key,Available,AvailableKey,iNumCodes,Codes2);
          MoveSome(R3,R3Key,Available,AvailableKey,iNumCodes,Codes3);
          MoveSome(R4,R4Key,Available,AvailableKey,iNumCodes,Codes4);
          MoveSome(R5,R5Key,Available,AvailableKey,iNumCodes,Codes5);
          MoveSome(Partial,PartialKey,Available,AvailableKey,iNumCodes,Codes6);
     end;
end;

procedure UnDeferSQLNoPartial(iNumCodes : integer;
                     Codes : Array_T);
var
   Codes2, Codes3, Codes4, Codes5 : Array_T;
   iCode, iCount : integer;
begin
     {makes Negotiated and Mandatory sites Available}

     with ControlForm do
     begin
          Codes2 := Array_t.Create;
          Codes2.init(SizeOf(iCode),iNumCodes);
          Codes3 := Array_t.Create;
          Codes3.init(SizeOf(iCode),iNumCodes);
          Codes4 := Array_t.Create;
          Codes4.init(SizeOf(iCode),iNumCodes);
          Codes5 := Array_t.Create;
          Codes5.init(SizeOf(iCode),iNumCodes);

          for iCount := 1 to iNumCodes do
          begin
               Codes.rtnValue(iCount,@iCode);
               Codes2.setValue(iCount,@iCode);
               Codes3.setValue(iCount,@iCode);
               Codes4.setValue(iCount,@iCode);
               Codes5.setValue(iCount,@iCode);
          end;

          MoveSome(R1,R1Key,Available,AvailableKey,iNumCodes,Codes);
          MoveSome(R2,R2Key,Available,AvailableKey,iNumCodes,Codes2);
          MoveSome(R3,R3Key,Available,AvailableKey,iNumCodes,Codes3);
          MoveSome(R4,R4Key,Available,AvailableKey,iNumCodes,Codes4);
          MoveSome(R5,R5Key,Available,AvailableKey,iNumCodes,Codes5);
     end;
end;

procedure UseResults;
begin
     with ControlForm do
        case iLocalFlag of
             SQL_R1   : MoveSome(Available,AvailableKey,R1,R1Key,iNumCodes,Codes);
             SQL_UNR1 : MoveSome(R1,R1Key,Available,AvailableKey,iNumCodes,Codes);
             SQL_R2   : MoveSome(Available,AvailableKey,R2,R2Key,iNumCodes,Codes);
             SQL_UNR2 : MoveSome(R2,R2Key,Available,AvailableKey,iNumCodes,Codes);
             SQL_R3   : MoveSome(Available,AvailableKey,R3,R3Key,iNumCodes,Codes);
             SQL_UNR3 : MoveSome(R3,R3Key,Available,AvailableKey,iNumCodes,Codes);
             SQL_R4   : MoveSome(Available,AvailableKey,R4,R4Key,iNumCodes,Codes);
             SQL_UNR4 : MoveSome(R4,R4Key,Available,AvailableKey,iNumCodes,Codes);
             SQL_R5   : MoveSome(Available,AvailableKey,R5,R5Key,iNumCodes,Codes);
             SQL_UNR5 : MoveSome(R5,R5Key,Available,AvailableKey,iNumCodes,Codes);

             SQL_UNDEFER : UnDeferSQL(iNumCodes,Codes);
             SQL_UNDEF_NOPAR : UnDeferSQLNoPartial(iNumCodes,Codes);

             SQL_EXC : MoveSome(Available,AvailableKey,Excluded,ExcludedKey,iNumCodes,Codes);
             SQL_UNEXC : MoveSome(Excluded,ExcludedKey,Available,AvailableKey,iNumCodes,Codes);

             SQL_LOOKUP : LookupSQL(iNumCodes,Codes);
             SQL_MAP :
                     if (iNumCodes > 0) then
                     begin
                          if (iNumCodes <> Codes.lMaxSize) then
                             Codes.resize(iNumCodes);
                          MapSites(Codes,FALSE);
                          Codes.Destroy;
                     end;
             SQL_ADD_MAP :
                     if (iNumCodes > 0) then
                     begin
                          if (iNumCodes <> Codes.lMaxSize) then
                             Codes.resize(iNumCodes);
                          MapSites(Codes,TRUE);
                          Codes.Destroy;
                     end;
             SQL_PAR : MoveSome(Available,AvailableKey,Partial,PartialKey,iNumCodes,Codes);
             SQL_UNPAR : MoveSome(Partial,PartialKey,Available,AvailableKey,iNumCodes,Codes);
             SQL_FLG : MoveSome(Available,AvailableKey,Flagged,FlaggedKey,iNumCodes,Codes);
             SQL_UNFLG : MoveSome(Flagged,FlaggedKey,Available,AvailableKey,iNumCodes,Codes);
             SQL_MINSET : if (iNumCodes > 0) then
                             MinsetForm.AddMinsetSQL;
        end;

     SQLForm.ModalResult := mrOK;
end;

procedure BuildCustom(const iNumCodes : integer; const Codes : Array_T);
begin
     {this builds a custom map layer containing sites
      identified by the geocode array Codes}
end;

procedure RunSQL(const iFlag : integer);
begin
     try
        iLocalFlag := iFlag;

        ControlRes^.sLastChoiceType := 'SQL Query';

        {ask user if irrep has not been run}
        Screen.Cursor := crDefault;
        if not fContrDataDone then
           ExecuteIrreplaceability(-1,False,False,True,True,'');

        SQLForm := TSQLForm.Create(Application);
        SQLForm.PrepareForm;
        SQLForm.ShowModal;
        SQLForm.Free;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in RunSQL',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure SetCaption;
begin
  with SQLForm do
     case iLocalFlag of
          SQL_R1 : Caption := 'Search - Select Sites As '+ControlRes^.sR1Label;
          SQL_UNR1 : Caption := 'Search - DeSelect '+ControlRes^.sR1Label+' Sites';
          SQL_R2 : Caption := 'Search - Select Sites As '+ControlRes^.sR2Label;
          SQL_UNR2 : Caption := 'Search - DeSelect '+ControlRes^.sR2Label+' Sites';
          SQL_R3 : Caption := 'Search - Select Sites As '+ControlRes^.sR3Label;
          SQL_UNR3 : Caption := 'Search - DeSelect '+ControlRes^.sR3Label+' Sites';
          SQL_R4 : Caption := 'Search - Select Sites As '+ControlRes^.sR4Label;
          SQL_UNR4 : Caption := 'Search - DeSelect '+ControlRes^.sR4Label+' Sites';
          SQL_R5 : Caption := 'Search - Select Sites As '+ControlRes^.sR5Label;
          SQL_UNR5 : Caption := 'Search - DeSelect '+ControlRes^.sR5Label+' Sites';
          SQL_UNDEFER : Caption := 'Search - DeSelect '+ControlRes^.sR1Label+', '+ControlRes^.sR2Label+', '+ControlRes^.sR3Label+', '+ControlRes^.sR4Label+', '+ControlRes^.sR5Label+' and Partial Sites';
          SQL_UNDEF_NOPAR : Caption := 'Search - DeSelect '+ControlRes^.sR1Label+', '+ControlRes^.sR2Label+', '+ControlRes^.sR3Label+', '+ControlRes^.sR4Label+' and '+ControlRes^.sR5Label+' Sites';

          SQL_CUSTOM : Caption := 'Search - Build Custom Map Layer';
          SQL_PROXIMITY : Caption := 'Search - Choose Proximity Area';

          SQL_EXC : Caption := 'Search - Select Sites As Excluded';
          SQL_UNEXC : Caption := 'Search - DeSelect Excluded Sites';

          SQL_PAR : Caption := 'Search - Select Sites As Partially Deferred';
          SQL_FLG : Caption := 'Search - Select Sites As Flagged';
          SQL_UNPAR : Caption := 'Search - DeSelect Partially Deferred Sites';
          SQL_UNFLG : Caption := 'Search - DeSelect Flagged Sites';

          SQL_MAP : Caption := 'Search - Map Query Sites';
          SQL_ADD_MAP : Caption := 'Search - Add Query Sites To Map';

          SQL_LOOKUP : Caption := 'Search - Lookup Sites';

          SQL_MINSET :
          begin
               Caption := 'Specify Minset SQL Query';
               btnExecute.Caption := 'Use Query';
               Execute1.Caption := 'Use Query';
          end;
     end;
end;

procedure TSQLForm.PrepareForm;
var
   iCount, iNumFields : integer;
   sTmp, sFlag, sStatLine : string;
begin
     try
        SetCaption;

        QueryTable.DatabaseName := ControlForm.OutTable.DatabaseName;
        QueryTable.TableName := ControlForm.OutTable.TableName;

        QueryTable.Open;

        iNumFields := QueryTable.FieldDefs.Count;

        FieldBox.MultiSelect := False;
        sSQLFileName := 'sample.sql';
        sSQLDatabase := ControlRes^.sWorkingDirectory;

        SQLQuery.DatabaseName := ControlRes^.sDatabase;
        SQLQuery.Close;
        SQLQuery.SQL.Clear;

        case iLocalFlag of  {sets appropriate selection unit for data needed from query}
             SQL_PROXIMITY : sTmp := ControlRes^.sKeyField + ', EASTING, NORTHING';
             {need geocode and easting and northing}

        else {need only geocode}
             sTmp := ControlRes^.sKeyField;
        end;

        SQLQuery.SQL.Add('Select ' + sTmp + ' from "'
                         + Copy(QueryTable.TableName,1,Length(QueryTable.TableName)-4) {trim .dbf}
                         + '" where ');

        sStatLine := RtnLoadStatusString;

        if (sStatLine <> '') then
        begin
             SQLQuery.SQL.Add(sStatLine);
             SQLQuery.SQL.Add(' AND ');
        end;

        for iCount := 1 to iNumFields do
        begin
             sTmp := QueryTable.FieldDefs.Items[iCount-1].Name;

             FieldBox.Items.Add(sTmp);
        end;

        QueryTable.Close;
        SeeQuery;

        if (iLocalFlag = SQL_MINSET) then
           if (MinsetForm.SQLMemo.Lines.Count <> 1) then
              if (MinsetForm.SQLMemo.Lines.Strings[0] <> 'No Query Specified') then
                 ResultMemo.Lines := MinsetForm.SQLMemo.Lines;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TSQLForm.PrepareForm',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TSQLForm.SortIntFields;
var
   OrigArr : Array_t;
begin
     SortBox.Items := Values.Items;

     if ListBox2IntArr(SortBox,OrigArr) then
     begin
          SelectionSortIntArr(OrigArr);

          IntArr2ListBox(SortBox,OrigArr);
          OrigArr.destroy;

          Values.Items := SortBox.Items;
          Values.Text := Values.Items[0];
     end;

     SortBox.Items.Clear;
end;

procedure TSQLForm.SortFloatFields;
var
   OrigArr : Array_t;
begin
     SortBox.Items := Values.Items;

     if ListBox2FloatArr(SortBox,OrigArr) then
     begin
          SelectionSortFloatArr(OrigArr);

          FloatArr2ListBox(SortBox,OrigArr);
          OrigArr.destroy;

          Values.Items := SortBox.Items;
          Values.Text := Values.Items[0];
     end;

     SortBox.Items.Clear;
end;

procedure TSQLForm.SortStringFields;
begin
     {do something}
     Values.Sorted := True;
     Values.Sorted := False;
end;


function RtnLoadStatusString : string;
begin
     case iLocalFlag of
          SQL_UNR1 : Result := ' (status = ' + Chr(39) + 'R1' + Chr(39) + ')';
          SQL_UNR2 : Result := ' (status = ' + Chr(39) + 'R2' + Chr(39) + ')';
          SQL_UNR3 : Result := ' (status = ' + Chr(39) + 'R3' + Chr(39) + ')';
          SQL_UNR4 : Result := ' (status = ' + Chr(39) + 'R4' + Chr(39) + ')';
          SQL_UNR5 : Result := ' (status = ' + Chr(39) + 'R5' + Chr(39) + ')';
          SQL_UNEXC : Result := ' (status = ' + Chr(39) + 'Ex' + Chr(39) + ')';
          SQL_UNPAR : Result := ' (status = ' + Chr(39) + 'PR' + Chr(39) + ')';
          SQL_UNFLG : Result := ' (status = ' + Chr(39) + 'Fl' + Chr(39) + ')';
          SQL_UNDEFER : Result := '((status = ' + Chr(39) + 'MR' + Chr(39) +
                                 ') OR (status = ' + Chr(39) + 'NR' + Chr(39) +
                                 ') OR (status = ' + Chr(39) + 'PR' + Chr(39) + '))';
          SQL_UNDEF_NOPAR : Result := '((status = ' + Chr(39) + 'MR' + Chr(39) +
                                     ') OR (status = ' + Chr(39) + 'NR' + Chr(39) + '))';
          SQL_LOOKUP, SQL_MAP, SQL_ADD_MAP : Result := '';
          SQL_MINSET : Result := '((status = ' + Chr(39) + 'Av' + Chr(39) +
                                 ') OR (status = ' + Chr(39) + 'Fl' + Chr(39) + '))';
     else
         Result := ' (status = ' + Chr(39) + 'Av' + Chr(39) + ')';
     end;
end;

function SiteLoadStatusOk(const sStatusLine : string) : boolean;
begin
     Result := False;
     if (0 = CompareText(sStatusLine,RtnLoadStatusString)) then
        Result := True;
end;

function SiteStatusOk(const sStatus : string) : boolean;
var
   sFlag : string;
begin
     Result := False;

     sFlag := '';

     case iLocalFlag of
          SQL_UNR1 : sFlag := 'R1';
          SQL_UNR2 : sFlag := 'R2';
          SQL_UNR3 : sFlag := 'R3';
          SQL_UNR4 : sFlag := 'R4';
          SQL_UNR5 : sFlag := 'R5';
          SQL_UNEXC : sFlag := 'Ex';
          SQL_UNPAR : sFlag := 'PR';
          SQL_UNFLG : sFlag := 'Fl';
     else
         sFlag := '';
     end;

     if (sStatus = sFlag) then
        Result := True
     else
     if (sFlag = '') then {flag has not been found yet}
     begin
          case iLocalFlag of
               SQL_UNDEFER : if (sStatus = 'MR')
                             or (sStatus = 'NR')
                             or (sStatus = 'PR') then
                                Result := True;
               SQL_UNDEF_NOPAR : if (sStatus = 'MR')
                                 or (sStatus = 'NR') then
                                    Result := True;
               SQL_LOOKUP, SQL_MAP, SQL_ADD_MAP : Result := True;
               SQL_MINSET : if (sStatus = 'Av')
                            or (sStatus = 'Fl') then
                               Result := True;
          else
              if (sStatus = 'Av')
              or (sStatus = 'Fl') then
                 Result := True;
          end;
     end;
end;

procedure TSQLForm.LoadValues(const sField : string);
{this procedure loads and sorts the appropriate field,
 loading min and max only for ints & reals if sort not
 specified}
var
   sTmp : string;
   fUniqueSTR, fLoadAll, fEnd : boolean;
   rTmp, rMin, rMax : extended;
   iTmp, iMin, iMax : integer;
begin
     Screen.Cursor := crHourglass;
     Values.Clear;
     fLoadAll := checkSortValues.Checked;
     iMin := 0; iMax := 0; rMin := 0; rMax := 0;
     fEnd := False;

     fUniqueSTR := False;
     if (sField = 'NAME')
     or (sField = ControlRes^.sKeyField) then
        fUniqueSTR := True;

     Values.Sorted := False;

     try
        QueryTable.Open;
        while not fEnd do
        begin
             if SiteStatusOk(QueryTable.FieldByName(STATUS_DBLABEL).AsString) then
             case CurrentFieldType of
                  ftSmallInt, ftInteger :
                  begin
                       iTmp := QueryTable.FieldByName(sField).AsInteger;
                       if fLoadAll then
                          Values.Items.Add(IntToStr(iTmp))
                       else
                       begin
                            {type is Integer and we are loading Max/Min values}

                            if (iTmp < iMin) then
                               iMin := iTmp
                            else
                                if (iTmp > iMax) then
                                   iMax := iTmp;
                       end;
                  end;
                  ftFloat :
                  begin
                       rTmp := QueryTable.FieldByName(sField).AsFloat;
                       sTmp := QueryTable.FieldByName(sField).AsString;

                       if fLoadAll then
                       begin
                            //Values.Items.Add(sTmp)
                            // if sTmp contains 'E' then use FloatToStrF
                            if (Pos('E',sTmp) > 0) then
                            begin
                                 sTmp := FloatToStrF(rTmp,ffFixed,10,8);
                                 Values.Items.Add(sTmp);
                            end
                            else
                                Values.Items.Add(FloatToStr(rTmp))


                       end
                       else
                       begin
                            {type is Real and we are loading Max/Min values}

                            if (rTmp < rMin) then
                               rMin := rTmp
                            else
                                if (rTmp > rMax) then
                                   rMax := rTmp;
                       end;
                  end;
                  ftString :
                  begin
                       sTmp := QueryTable.FieldByName(sField).AsString;

                       if fUniqueSTR then
                          Values.Items.Add(sTmp)
                       else
                           if (Values.Items.IndexOf(sTmp) = -1) then
                              Values.Items.Add(sTmp);
                  end;
             end;

             if QueryTable.EOF then
                fEnd := True;

             QueryTable.Next;
        end;

        {now if Real or Int we need to display min/max
                            OR sort and display all}

        case CurrentFieldType of
             ftSmallint, ftInteger :
                                begin
                                     if fLoadAll then
                                        SortIntFields
                                     else
                                     begin
                                          {add min and max to display}
                                          lblValues.Caption := 'Max and Min';
                                          {Values.Items.Add('Max:');}
                                          Values.Items.Add(IntToStr(iMax));
                                          {Values.Items.Add('Min:');}
                                          Values.Items.Add(IntToStr(iMin));
                                          Values.Text := IntToStr(iMax);
                                     end;
                                end;
             ftFloat :
                  begin
                       if fLoadAll then
                          SortFloatFields
                       else
                       begin
                            {add min and max to display}
                            lblValues.Caption := 'Max and Min';
                            {Values.Items.Add('Max:');}
                            Values.Items.Add(FloatToStr(rMax));
                            {Values.Items.Add('Min:');}
                            Values.Items.Add(FloatToStr(rMin));
                            Values.Text := FloatToStr(rMax);
                       end;
                  end;
             ftString : Values.Text := Values.Items.Strings[0];
        else
            MessageDlg('Unknown Sort Type',mtError,[mbOk],0);
        end;

     if fLoadAll
     and (CurrentFieldType = ftString) then
         Values.Sorted := True;

     finally
            QueryTable.Close;
            Screen.Cursor := crDefault;
     end;
end;

procedure TSQLForm.FieldBoxClick(Sender: TObject);
var
   iCount, iBoxLen : integer;
begin
     if (Operator.ItemIndex < 6) then
     begin
          {choose a field for the SQL query}
          lblValues.Caption := 'Values';

          iBoxLen := FieldBox.Items.Count;

          if checkLoadValues.Checked then
             for iCount := 1 to iBoxLen do
                 if FieldBox.Selected[iCount-1] then
                 begin
                      try
                         CurrentFieldType := QueryTable.FieldDefs.Items[iCount-1].DataType;
                      except
                            CurrentFieldType := QueryTable.FieldDefs.Items[rtnFieldIndex(FieldBox.Items.Strings[iCount-1],QueryTable)].DataType;
                      end;
                      //CurrentFieldType := QueryTable.FieldDefs.Items[iCount-1].DataType;
                      //CurrentFieldType := QueryTable.FieldDefs.Items[rtnFieldIndex(FieldBox.Items.Strings[iCount-1],QueryTable)].DataType;
                      LoadValues(FieldBox.Items[iCount-1]);
                 end;
     end;
end;

procedure TSQLForm.BitBtn1Click(Sender: TObject);
begin
     {OK button pressed, finished, exit program}
     {maybe prompt for save SQL query}
     ModalResult := mrOK;
end;

function GetOperator : string;
begin
     Result := SQLForm.Operator.Items.Strings[SQLForm.Operator.ItemIndex];
end;

function TSQLForm.ContainsHighest : boolean;
var
   iCount : integer;
begin
     //
     Result := False;
     for iCount := 0 to (ResultMemo.Lines.Count - 1) do
         if (Pos('Highest',ResultMemo.Lines.Strings[iCount]) > 0) then
            Result := True;
end;

procedure TSQLForm.btnORClick(Sender: TObject);
begin
     SQLQuery.SQL.Add(' OR ');

     SeeQuery;
end;

procedure GrabSQLExpression;
{Builds SQL expression with field, operator, and value selected
 by user, and adds the expression to the SQL query list}
var
   iCount, iBoxLen : integer;
   sQuote, sTmp : string;
begin
     case CurrentFieldType of
          ftString : sQuote := chr(39); {single quote}
     else
         sQuote := '';
     end;

     with SQLForm do
     begin
        iBoxLen := FieldBox.Items.Count;

        for iCount := 1 to iBoxLen do
            if FieldBox.Selected[iCount-1] then
            begin
                 if (Operator.ItemIndex < 6) then
                    sTmp := '(' +
                            FieldBox.Items.Strings[iCount-1] +
                            GetOperator + sQuote +
                            Values.Text + sQuote +
                            ')'
                 else
                     sTmp := '(' +
                             FieldBox.Items.Strings[iCount-1] +
                             ' ' +
                             GetOperator +
                             ')';

                 SQLQuery.SQL.Add( sTmp );
            end;
     end;

     SeeQuery;
end;

procedure TSQLForm.btnANDClick(Sender: TObject);
begin
     SQLQuery.SQL.Add(' AND ');

     SeeQuery;
end;

procedure TSQLForm.btnUndoClick(Sender: TObject);
begin
     if SQLQuery.SQL.Count > 1 then
        SQLQuery.SQL.Delete(SQLQuery.SQL.Count-1);

     SeeQuery;
end;

procedure TrimPathFile(const sLine : string; var sPath, sFile : string);
begin
     sPath := ExtractFilePath(sLine);

     if (Length(sPath) > 1)
     and (sPath[Length(sPath)] = '\') then
         sPath := Copy(sPath,1,Length(sPath)-1);
     {trim \ from path if present}

     sFile := ExtractFileName(sLine);
end;

procedure TSQLForm.btnSaveClick(Sender: TObject);
begin
     SQLSave.InitialDir := sSQLDatabase;
     SQLSave.FileName := sSQLFileName;

     if SQLSave.Execute then
     begin
          TrimPathFile(SQLSave.FileName,sSQLDatabase,sSQLFileName);
          SQLQuery.SQL.SaveToFile(SQLSave.FileName);
     end;
end;

function SQLFileOk(sFilename:string):boolean;
var
   iCount : integer;
begin
     Result := True;

     SQLForm.TestBox.Items.LoadFromFile(sFilename);

     if (SQLForm.TestBox.Items.Count > 0) then
        for iCount := 0 to (SQLForm.TestBox.Items.Count-1) do
            if (Pos('status',SQLForm.TestBox.Items.Strings[iCount]) > 0) then
               if not SiteLoadStatusOk(SQLForm.TestBox.Items.Strings[iCount]) then
                  Result := False;

     SQLFOrm.TestBox.Items.Clear;
end;

procedure SQLReplaceFile(sFilename:string);
var
   iCount : integer;
begin
     SQLForm.TestBox.Items.LoadFromFile(sFilename);

     if (SQLForm.TestBox.Items.Count > 0) then
        for iCount := 0 to (SQLForm.TestBox.Items.Count-1) do
            if (Pos('status',SQLForm.TestBox.Items.Strings[iCount]) > 0) then
            begin
                 SQLForm.TestBox.Items.Strings[iCount] := RtnLoadStatusString;
            end;

     SQLForm.ResultMemo.Lines := SQLForm.TestBox.Items;
     SQLFOrm.TestBox.Items.Clear;
     UpdateQuery;
end;

procedure TSQLForm.btnLoadClick(Sender: TObject);
begin
     {GrabSQLExpression;}

     SQLOpen.InitialDir := sSQLDatabase;
     SQLOpen.Filename := sSQLFileName;

     if SQLOpen.Execute then
     begin
          TrimPathFile(SQLSave.FileName,sSQLDatabase,sSQLFileName);

          if SQLFileOk(SQLOpen.Filename) then
             SQLQuery.SQL.LoadFromFile(SQLOpen.Filename)
          else
          begin
               if (mrOk = MessageDlg('Invalid status line in ' + SQLOpen.Filename +
                                     '  Open and Replace status line?',mtInformation,[mbOk,mbCancel],0)) then
                  SQLReplaceFile(SQLOpen.Filename);
          end;
     end;

     SeeQuery;
end;

procedure TSQLForm.Button1Click(Sender: TObject);
begin
     SeeQuery;
end;

procedure SeeQuery;
begin
     with SQLForm do
     begin
          ResultMemo.Lines := SQLQuery.SQL;
          ResultMemo.Update;

          CheckExcludeZeroValues.Visible := ContainsHighest;
     end;
end;

procedure UpdateQuery;
begin
     with SQLForm do
     begin
          SQLQuery.SQL := ResultMemo.Lines;
     end;
end;

procedure TSQLForm.Accept1Click(Sender: TObject);
begin
     {accept current field and value choice}
     GrabSQLExpression;
end;

(*
QueryRequest_T = record
                   fHighest : boolean; {True means highest, False means lowest}
                   sVariable : str255;
                   rPercentage : extended;
                 end;
*)

function Is_Tenure_Ok(SiteStatus : Status_t) : boolean;
begin
     // Status_T = (Av,R1,R2,Pd,Fl,Ex,Ig,Re);
     case iLocalFlag of
          SQL_PAR,
          SQL_EXC,
          SQL_FLG,
          SQL_R1,
          SQL_R2,
          SQL_R3,
          SQL_R4,
          SQL_R5 : Result := (SiteStatus = Av);
          SQL_UNR1 : Result := (SiteStatus = _R1);
          SQL_UNR2 : Result := (SiteStatus = _R2);
          SQL_UNR3 : Result := (SiteStatus = _R3);
          SQL_UNR4 : Result := (SiteStatus = _R4);
          SQL_UNR5 : Result := (SiteStatus = _R5);
          SQL_UNDEFER : Result := ((SiteStatus = _R1) or (SiteStatus = _R2)
                                    or (SiteStatus = _R3) or (SiteStatus = _R4)
                                    or (SiteStatus = _R5) or (SiteStatus = Pd));
          SQL_UNDEF_NOPAR : Result := ((SiteStatus = _R1) or (SiteStatus = _R2)
                                       or (SiteStatus = _R3) or (SiteStatus = _R4)
                                       or (SiteStatus = _R5));
          SQL_UNEXC : Result := (SiteStatus = Ex);
          SQL_UNPAR : Result := (SiteStatus = Pd);
          SQL_UNFLG : Result := (SiteStatus = Fl);
     else
         Result := True;
     end;
end;

procedure ProcessQueryRequest(const QueryRequest : Array_t;
                              var QueryResult : Array_t;
                              const fDebug : boolean;
                              const fExcludeZeroValues : boolean);
var
   ARequest : QueryRequest_t;
   NonZeroCount,
   SiteVectors : Array_t;
   rValue : extended;
   iCount, iField, iStart, iEnd, iNumberOfSites, iNonZeroCount : integer;
   DebugFile : TextFile;
   fTenureOk : boolean;
   pSite : sitepointer;
begin
     // Input : list of fields to determine the highest/lowest
     // Output : substitute extended precision real which fits
     //          into the following example statements :
     //    (IRREP > 0.56)  or  (IRREP < 0.43)

     // Method for determining cut off point :
     //   1) load values from a file into a vector of extended precision real
     //   2) sort the values
     //   3) find the Nth value from each vector (where N is the % of total number of sites)
     try
        // create and initialise the temporary and result vector
        SiteVectors := Array_t.Create;
        SiteVectors.init(SizeOf(extended),iSiteCount * QueryRequest.lMaxSize);

        QueryResult := Array_t.Create;
        QueryResult.init(SizeOf(extended),QueryRequest.lMaxSize);

        NonZeroCount := Array_t.Create;
        NonZeroCount.init(SizeOf(integer),QueryRequest.lMaxSize);
        iNonZeroCount := 0;

        rValue := 0;

        for iCount := 1 to SiteVectors.lMaxSize do
            SiteVectors.setValue(iCount,@rValue);

        for iCount := 1 to QueryResult.lMaxSize do
        begin
             QueryResult.setValue(iCount,@rValue);
             NonZeroCount.setValue(iCount,@iNonZeroCount);
        end;

        // load the values from the database file
        ControlForm.OutTable.Open;
        new(pSite);
        for iCount := 1 to iSiteCount do
        begin
             // if the tenure for this site is not correct, set its value to zero
             SiteArr.rtnValue(iCount,pSite);
             fTenureOk := Is_Tenure_Ok(pSite^.status);

             for iField := 1 to QueryRequest.lMaxSize do
             begin
                  if fTenureOk then
                  begin
                       QueryRequest.rtnValue(iField,@ARequest);
                       rValue := ControlForm.OutTable.FieldByName(ARequest.sVariable).AsFloat;

                       if (rValue > 0) then
                       begin
                            NonZeroCount.rtnValue(iField,@iNonZeroCount);
                            Inc(iNonZeroCount);
                            NonZeroCount.setValue(iField,@iNonZeroCount);
                       end;
                  end
                  else
                      rValue := 0;

                  SiteVectors.setValue(iCount + ((iField - 1) * iSiteCount),@rValue);
             end;

             ControlForm.OutTable.Next;
        end;
        ControlForm.OutTable.Close;
        dispose(pSite);

        // sort the values we have loaded
        iStart := 1;
        iEnd := iSiteCount;
        for iField := 1 to QueryRequest.lMaxSize do
        begin
             case iLocalFlag of
                  SQL_PAR,
                  SQL_EXC,
                  SQL_FLG,
                  SQL_R1,
                  SQL_R2,
                  SQL_R3,
                  SQL_R4,
                  SQL_R5 : iNumberOfSites := ControlForm.Available.Items.Count;
                  SQL_UNR1 : iNumberOfSites := ControlForm.R1.Items.Count;
                  SQL_UNR2 : iNumberOfSites := ControlForm.R2.Items.Count;
                  SQL_UNR3 : iNumberOfSites := ControlForm.R3.Items.Count;
                  SQL_UNR4 : iNumberOfSites := ControlForm.R4.Items.Count;
                  SQL_UNR5 : iNumberOfSites := ControlForm.R5.Items.Count;
                  SQL_UNDEFER : iNumberOfSites := ControlForm.R1.Items.Count +
                                                  ControlForm.R2.Items.Count +
                                                  ControlForm.R3.Items.Count +
                                                  ControlForm.R4.Items.Count +
                                                  ControlForm.R5.Items.Count +
                                                  ControlForm.Partial.Items.Count;
                  SQL_UNDEF_NOPAR : iNumberOfSites := ControlForm.R1.Items.Count +
                                                      ControlForm.R2.Items.Count +
                                                      ControlForm.R3.Items.Count +
                                                      ControlForm.R4.Items.Count +
                                                      ControlForm.R5.Items.Count;
                  SQL_UNEXC : iNumberOfSites := ControlForm.Excluded.Items.Count;
                  SQL_UNPAR : iNumberOfSites := ControlForm.Partial.Items.Count;
                  SQL_UNFLG : iNumberOfSites := ControlForm.Flagged.Items.Count;
             else
                 iNumberOfSites := iSiteCount;
             end;

             QueryRequest.rtnValue(iField,@ARequest);
             QuickSortFloatArr(SiteVectors,iStart,iEnd);

             // determine how many sites the user wants to select
             if fExcludeZeroValues
             and ARequest.fHighest then
             begin
                  NonZeroCount.rtnValue(iField,@iNonZeroCount);
                  iNumberOfSites := Round(iNonZeroCount * ARequest.rPercentage / 100);
             end
             else
                 iNumberOfSites := Round(iNumberOfSites * ARequest.rPercentage / 100);

             if (iNumberOfSites <= 0) then
                iNumberOfSites := 1;
             if ARequest.fHighest then
                SiteVectors.rtnValue(iNumberOfSites + iStart - 1,@rValue)
             else
                 SiteVectors.rtnValue(SiteVectors.lMaxSize - iNumberOfSites + 1,@rValue);

             QueryResult.setValue(iField,@rValue);

             Inc(iStart,iSiteCount);
             Inc(iEnd,iSiteCount);
        end;

        if fDebug then
        begin
             assignfile(DebugFile,ControlRes^.sWorkingDirectory +
                                  '\' +
                                  IntToStr(QueryRequest.lMaxSize) +
                                  '_Sorted_Vectors.csv');
             rewrite(DebugFile);
             writeln(DebugFile,'index,value');
             for iCount := 1 to SiteVectors.lMaxSize do
             begin
                  SiteVectors.rtnValue(iCount,@rValue);
                  writeln(DebugFile,IntToStr(iCount) +
                                    ',' +
                                    FloatToStr(rValue));
             end;
             closefile(DebugFile);
        end;

        NonZeroCount.Destroy;
        SiteVectors.Destroy;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception processing query.  You may be trying to use string fields.' + Chr(10) + Chr(13) +
                      'Only fields containing numbers can be used with the Highest and Lowest operators.',
                      mtError,[mbOk],0);
           SiteVectors.Destroy;
     end;
end;

function Status2Str (const AStatus : Status_T) : string;
begin
     case AStatus of
          Av : Result := 'Av';
          _R1 : Result := 'R1';
          _R2 : Result := 'R2';
          _R3 : Result := 'R3';
          _R4 : Result := 'R4';
          _R5 : Result := 'R5';
          Pd : Result := 'PR';
          Fl : Result := 'Fl';
          Ex : Result := 'Ex';
          Ig : Result := 'IE';
          Re : Result := 'IR';
     else
         Result := '??';
     end;
end;

procedure DebugSiteDump1;
var
   DebugFile : TextFile;
   iCount : integer;
   pSite : sitepointer;
   WS : WeightedSumirr_T;
begin
     assignfile(DebugFile,ControlRes^.sWorkingDirectory + '\dbgs1.csv');
     rewrite(DebugFile);

     writeln(DebugFile,'SiteKey,status,sum_tv1,sum_tv2,sum_tv3');

     new(pSite);
     for iCount := 1 to iSiteCount do
     begin
          SiteArr.rtnValue(iCount,pSite);
          WeightedSumirr.rtnValue(iCount,@WS);

          writeln(DebugFile,IntToStr(pSite^.iKey) + ',' +
                            Status2Str(pSite^.status) + ',' +
                            FloatToStr(WS.r_sub_tv[1]) + ',' +
                            FloatToStr(WS.r_sub_tv[2]) + ',' +
                            FloatToStr(WS.r_sub_tv[3]));
     end;
     dispose(pSite);

     closefile(DebugFile);
end;

procedure TSQLForm.Execute1Click(Sender: TObject);
var
   iRequests, iRequestCount,
   iCount, iNumFields, iCode, iPos : integer;
   wOldCursor : integer;
   wResult : word;
   fEnd : boolean;
   sCode, sLine, sVariable, sAmount : string;
   QueryRequest, QueryResult : Array_t;
   ARequest : QueryRequest_t;
   rValue : extended;

   procedure AddRequest;
   begin
        Inc(iRequests);
        if (iRequests > QueryRequest.lMaxSize) then
           QueryRequest.resize(QueryRequest.lMaxSize + 10);
        QueryRequest.setValue(iRequests,@ARequest);
   end;

begin
     {Execute SQL Query}
     // Parse the query and convert all Highest % to > X
     // and all Lowest % to < X
     iRequests := 0;
     QueryRequest := Array_t.Create;
     QueryRequest.init(SizeOf(ARequest),10);
     for iCount := 0 to (ResultMemo.Lines.Count - 1) do
     begin
          sLine := ResultMemo.Lines.Strings[iCount];

          iPos := Pos(' Highest ',sLine);
          if (iPos > 0) then
          begin
               // (IRREPL Highest 10 %)
               sVariable := Copy(sLine,2,iPos - 2);
               sAmount := Copy(sLine,iPos + 9,Length(sLine) - iPos - 11);

               ARequest.fHighest := True;
               ARequest.sVariable := sVariable;
               ARequest.rPercentage := RegionSafeStrToFloat(sAmount);
               AddRequest;
          end;
          iPos := Pos(' Lowest ',sLine);
          if (iPos > 0) then
          begin
               // (IRREPL Lowest 10 %)
               sVariable := Copy(sLine,2,iPos - 2);
               sAmount := Copy(sLine,iPos + 8,Length(sLine) - iPos - 10);

               ARequest.fHighest := False;
               ARequest.sVariable := sVariable;
               ARequest.rPercentage := RegionSafeStrToFloat(sAmount);
               AddRequest;
          end;
     end;

     if (iRequests > 0) then
     begin
          if (QueryRequest.lMaxSize <> iRequests) then
             QueryRequest.resize(iRequests);

          //DebugSiteDump1;

          ProcessQueryRequest(QueryRequest,
                              QueryResult,
                              False,
                              CheckExcludeZeroValues.Checked);

          SQLQuery.SQL.Clear;

          // use the query result to modify the SQL query
          for iCount := 0 to (ResultMemo.Lines.Count - 1) do
          begin
               sLine := ResultMemo.Lines.Strings[iCount];

               iPos := Pos(' Highest ',sLine);
               if (iPos > 0) then
               begin
                    // (IRREPL Highest 10 %)
                    sVariable := Copy(sLine,2,iPos - 2);
                    sAmount := Copy(sLine,iPos + 9,Length(sLine) - iPos - 11);

                    for iRequestCount := 1 to QueryResult.lMaxSize do
                    begin
                         QueryRequest.rtnValue(iRequestCount,@ARequest);
                         if ARequest.fHighest then
                            if (ARequest.sVariable = sVariable)
                            and (FloatToStr(ARequest.rPercentage) = sAmount) then
                            begin
                                 QueryResult.rtnValue(iRequestCount,@rValue);
                                 // update this line in the query
                                 sLine := '(' + sVariable + ' >= ' + FloatToStrF(rValue,ffFixed,18,18) + ')';
                            end;
                    end;
               end;
               iPos := Pos(' Lowest ',sLine);
               if (iPos > 0) then
               begin
                    // (IRREPL Lowest 10 %)
                    sVariable := Copy(sLine,2,iPos - 2);
                    sAmount := Copy(sLine,iPos + 8,Length(sLine) - iPos - 10);

                    for iRequestCount := 1 to QueryResult.lMaxSize do
                    begin
                         QueryRequest.rtnValue(iRequestCount,@ARequest);
                         if (not ARequest.fHighest) then
                            if (ARequest.sVariable = sVariable)
                            and (FloatToStr(ARequest.rPercentage) = sAmount) then
                            begin
                                 QueryResult.rtnValue(iRequestCount,@rValue);
                                 // update this line in the query
                                 sLine := '(' + sVariable + ' <= ' + FloatToStrF(rValue,ffFixed,18,18) + ')';
                            end;
                    end;
               end;

               SQLQuery.SQL.Add(sLine);
          end;

          QueryResult.Destroy;
     end;

     QueryRequest.Destroy;

     ControlRes^.sSQLQuery := '';
     iCount := 1;

     while (iCount+1 <= SQLQuery.SQL.Count) do
     begin
          if ((Length(ControlRes^.sSQLQuery) +
               Length(SQLQuery.SQL.Strings[iCount]) + 1) < 256) then
          begin
               if (iCount > 0) then
                  ControlRes^.sSQLQuery := ControlRes^.sSQLQuery + ' ';

               ControlRes^.sSQLQuery := ControlRes^.sSQLQuery +
                                        SQLQuery.SQL.Strings[iCount];
          end;

          Inc(iCount);
     end;

     Codes := Array_t.Create;
     Codes.init(SizeOf(iCode),ARR_STEP_SIZE);

     Screen.Cursor := crHourglass;

     try
        SQLQuery.Open; {returns a result set for the query}

        {now dump result of Query to ResultBox}

        iNumFields := SQLQuery.FieldDefs.Count;

        iNumCodes := 0; {reset result list}

        fEnd := False;
        while (not fEnd) do
        begin
             Inc(iNumCodes);

             {extract geocode as result field}
             {sometimes triggers exception when doing .AsInteger conversion}
             sCode := SQLQuery.FieldByName( SQLQuery.FieldDefs.Items[0].Name ).AsString;

             if (sCode = '') then
             begin
                  {there are zero geocodes in the resulting list}
                  iNumCodes := 0;
                  fEnd := True;
             end
             else
             try
                iCode := StrToInt(sCode);
             except;
                   {integer conversion failed}
                   Screen.Cursor := crDefault;
                   MessageDlg('integer conversion failed on >' + sCode + '<',mtError,[mbOk],0);
             end;

             if not fEnd then
             begin
                  if (iNumCodes > Codes.lMaxSize) then
                     Codes.resize(Codes.lMaxSize + ARR_STEP_SIZE);
                  Codes.setValue(iNumCodes,@iCode);

                  SQLQuery.Next;

                  if SQLQuery.EOF then
                     fEnd := True;
             end;
        end;

        SQLQuery.Close;

        if (iRequests > 0) then
        begin
             // restore the SQL query
             SQLQuery.SQL.SaveToFile(ControlRes^.sWorkingDirectory + '\modified_statement.sql');
             SQLQuery.SQL := ResultMemo.Lines;
        end;

        if (iNumCodes > 0) then
        begin
             if (iNumCodes <> Codes.lMaxSize) then
                Codes.resize(iNumCodes);

             wOldCursor := Screen.Cursor;
             Screen.Cursor := crDefault;

             if (iNumCodes = 1) then
                wResult := MessageDlg('1 site matches the search query.  Use this site?',
                                      mtConfirmation,[mbYes,mbNo],0)
             else
                 wResult := MessageDlg(IntToStr(iNumCodes) +
                                       ' sites match the search query.  Use these sites?',
                                       mtConfirmation,[mbYes,mbNo],0);

             if (wResult = mrYes) then
             begin
                  Screen.Cursor := wOldCursor;
                  UseResults;
             end;
        end
        else
        begin
             wOldCursor := Screen.Cursor;
             Screen.Cursor := crDefault;
             MessageDlg('No keys match SQL query',mtInformation,[mbOK],0);
             Screen.Cursor := wOldCursor;
        end;

     except on exception do
            begin
                 Screen.Cursor := crDefault;
                 MessageDlg('Error executing SQL Query.  Check Query and try again.',mtInformation,[mbOk],0);
            end;
     end;

     Screen.Cursor := crDefault;
end;

procedure TSQLForm.btnNotClick(Sender: TObject);
begin
     SQLQuery.SQL.Add(' NOT ');

     SeeQuery;
end;

procedure TSQLForm.Button2Click(Sender: TObject);
begin
     SQLQuery.SQL.Add('(');

     SeeQuery;
end;

procedure TSQLForm.Button3Click(Sender: TObject);
begin
     SQLQuery.SQL.Add(')');

     SeeQuery;
end;

procedure TSQLForm.checkLoadValuesClick(Sender: TObject);
begin
     checkSortValues.Enabled := checkLoadValues.Checked;
     Values.Items.Clear;
     Values.Text := '';

     FieldBoxClick(self);
end;

procedure TSQLForm.ValuesChange(Sender: TObject);
begin
     if (Values.Text = 'Min:')
     or (Values.Text = 'Max:') then
        Values.Text := '';
end;

procedure TSQLForm.ResultMemoKeyPress(Sender: TObject; var Key: Char);
begin
     UpdateQuery;
end;

procedure TSQLForm.checkSortValuesClick(Sender: TObject);
begin
     {reparse a field for the SQL query}
     FieldBoxClick(self);
end;

procedure TSQLForm.ResultMemoKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     UpdateQuery;
end;

procedure TSQLForm.OperatorClick(Sender: TObject);
begin
     if (Operator.ItemIndex < 6) then
     begin
          // not using highest/lowest operator
          SpinValue.Visible := False;
          checkLoadValues.Visible := True;
          checkSortValues.Visible := True;

          FieldBoxClick(Sender);
     end
     else
     begin
          // using highest/lowest operator
          SpinValue.Visible := True;
          if (Operator.ItemIndex = 6) then
             lblValues.Caption := 'Highest'
          else
              lblValues.Caption := 'Lowest';

          checkLoadValues.Visible := False;
          checkSortValues.Visible := False;
     end;
end;

procedure TSQLForm.SpinValueChange(Sender: TObject);
var
   iItemIndex : integer;
begin
     // update the items %
     iItemIndex := Operator.ItemIndex;
     Operator.Items.Delete(7);
     Operator.Items.Delete(6);
     Operator.Items.Add('Highest ' + IntToStr(SpinValue.Value) + ' %');
     Operator.Items.Add('Lowest ' + IntToStr(SpinValue.Value) + ' %');
     Operator.ItemIndex := iItemIndex;
end;

procedure TSQLForm.CheckExcludeZeroValuesClick(Sender: TObject);
begin
     // CheckExcludeZeroValues.Checked := ContainsHighest;
end;

end.
