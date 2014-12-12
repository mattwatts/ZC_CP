unit minset;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, ExtCtrls, Buttons, Gauges, Db, DBTables,
  Global, ds;

type
  TMinsetForm = class(TForm)
    Panel1: TPanel;
    LoopGroup: TRadioGroup;
    SpinIter: TSpinEdit;
    btnGoDoIt: TBitBtn;
    BitBtn2: TBitBtn;
    RadioField: TRadioGroup;
    Gauge1: TGauge;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    SpinSelect: TSpinEdit;
    RadioSelect: TRadioGroup;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    CheckSQLCondition: TCheckBox;
    SQLMemo: TMemo;
    CheckResourceLimit: TCheckBox;
    ComboResource: TComboBox;
    SpinResource: TSpinEdit;
    Label1: TLabel;
    Label3: TLabel;
    MinsetQuery: TQuery;
    DataSource1: TDataSource;
    lblIterCount: TLabel;
    ResourceGauge: TGauge;
    lblResGCapt: TLabel;
    procedure SpinIterChange(Sender: TObject);
    procedure LoopGroupClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SQLMemoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function AreSQLFieldsStatic : boolean;
    procedure AddMinsetSQL;
    procedure CheckSQLConditionClick(Sender: TObject);
    procedure SpinResourceChange(Sender: TObject);
    procedure ComboResourceChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  {type declarations for sorting site value arrays}
  SortElement_T = record
                    rValue : extended;
                    iSiteIndex : integer;
                  end;

var
  MinsetForm: TMinsetForm;


procedure ArrFindBestSite(const iFlag, iSQLArrCount : integer; var iBestCount : integer;
                          const SQLArray : Array_t; var BestArray : Array_t);
procedure FindBestNSites(const iFlag, iSitesToSelect, iSQLArrCount : integer; var iBestCount : integer;
                         const SQLArray : Array_t; var BestArray : Array_t);
{function IsResourceLimitExceeded(const iBestCount,iResArrCount : integer;
                                 const BestArray,ResArray : Array_t;
                                 var rDeferred : extended;
                                 const rTotalResource, rPartDeferred : extended;
                                 const iPercentWeCanDeferr : integer) : boolean;}
//procedure ExecuteMinset;

function AreFeaturesSatisfied(var iFeaturesSatisfied : integer;
                              const fTestClasses : boolean;
                              const ClassesToTest : ClassDetail_T) : boolean;
//procedure RunFastIrrep(const iIC : integer);


implementation



uses
    Control, Sf_irrep,
    Highligh, Em_newu1, Pred_sf4, Sql_unit,
    Choosere, Contribu, Pred_sf3, Toolmisc,
    msetexpt, opt1, destruct;

{$R *.DFM}

procedure TMinsetForm.AddMinsetSQL;
begin
     {}
     SQLMemo.Lines := SQLForm.ResultMemo.Lines;
end;

procedure TMinsetForm.SpinIterChange(Sender: TObject);
var
   iIdx : integer;
begin
     iIdx := LoopGroup.ItemIndex;

     LoopGroup.Items.Delete(2);
     LoopGroup.Items.Add(IntToStr(SpinIter.Value) + ' Iterations');

     LoopGroup.ItemIndex := iIdx;
end;

procedure TMinsetForm.LoopGroupClick(Sender: TObject);
begin
     if (LoopGroup.ItemIndex = 0) then
     begin
          {label1.Enabled := False;}
          SpinIter.Enabled := False;
     end
     else
     begin
          {label1.Enabled := True;}
          SpinIter.Enabled := True;
     end;
end;

procedure ArrFindBestSite(const iFlag, iSQLArrCount : integer; var iBestCount : integer;
                          const SQLArray : Array_t; var BestArray : Array_t);
var
   iCount, iKey, iSiteIndex, iKeyChosen : integer;
   rMax, rValue : extended;
   pSite : sitepointer;
   dIrrep : extended;
   sMsg : string;
begin
     new(pSite);
     rMax := 0;

     if (iSQLArrCount = 0) then
        {we must choose Available sites from the site array}
        begin
             for iCount := 1 to iSiteCount do
             begin
                  SiteArr.rtnValue(iCount,pSite);
                  if (pSite^.status = Av)
                  or (pSite^.status = Fl) then
                  begin
                       case iFlag of
                            IRREP_FLAG : rValue := pSite^.rIrreplaceability;
                            SUMIRR_FLAG : rValue := pSite^.rSummedIrr;
                            WAVIRR_FLAG : rValue := pSite^.rWAVIRR;
                            PCCONTR_FLAG : rValue := pSite^.rPCUSED;
                       end;

                       if (rValue > rMax) then
                       begin
                            rMax := rValue;
                            iKeyChosen := pSite^.iKey;
                       end;
                  end;
             end;

             if (rMax = 0) then
                sMsg := 'No sites with non zero value remain';
        end
        else
        {we must choose from a subset of Available sites in the SQLArray
         which is the result of the SQL Query}
        begin
             for iCount := 1 to iSQLArrCount do
             begin
                  SQLArray.rtnValue(iCount,@iKey);

                  iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
                  SiteArr.rtnValue(iSiteIndex,pSite);

                  if (pSite^.status = Av)
                  or (pSite^.status = Fl) then
                  begin
                       case iFlag of
                            IRREP_FLAG : rValue := pSite^.rIrreplaceability;
                            SUMIRR_FLAG : rValue := pSite^.rSummedIrr;
                            WAVIRR_FLAG : rValue := pSite^.rWAVIRR;
                            PCCONTR_FLAG : rValue := pSite^.rPCUSED;
                       end;

                       if (rValue > rMax) then
                       begin
                            rMax := rValue;
                            iKeyChosen := pSite^.iKey;
                       end;
                  end;
             end;

             if (rMax = 0) then
                sMsg := 'No sites remain which satisfy SQL criteria';
        end;

        {iKey is the site with the maximum value}

     if (rMax > 0) then
     begin
          try
             BestArray := Array_t.Create;
             BestArray.init(SizeOf(integer),1);
          except
                Screen.Cursor := crDefault;
                MessageDlg('Exception in BestArray.init',mtError,[mbOk],0);
                Application.Terminate;
                Exit;
          end;
          BestArray.setValue(1,@iKeyChosen);
          iBestCount := 1;
     end
     else
     begin
          iBestCount := 0;
          MessageDlg(sMsg,mtInformation,[mbOk],0);
     end;

     dispose(pSite);
end;

procedure FindBestNSites(const iFlag, iSitesToSelect, iSQLArrCount : integer; var iBestCount : integer;
                         const SQLArray : Array_t; var BestArray : Array_t);
var
   iCount, iNCount, iKey, iKeyChosen : integer;
   rMax, rValue : extended;
   pSite : sitepointer;
   dIrrep : extended;
   sMsg : string;

   procedure AddASite(const iGeo : integer);
   begin
        Inc(iBestCount);

        if (iBestCount > BestArray.lMaxSize) then
           BestArray.resize(BestArray.lMaxSize + ARR_STEP_SIZE);

        BestArray.setValue(iBestCount,@iGeo);
   end;

   function IsSiteAlreadyChosen(const iGeo : integer) : boolean;
   var
      iCount, iCompareKey : integer;
   begin
        Result := False;
        if (iBestCount > 0) then
           for iCount := 1 to iBestCount do
           begin
                {test for a match}
                BestArray.rtnValue(iCount,@iCompareKey);
                if (iGeo = iCompareKey) then
                   Result := True;
           end;
   end;

begin
     new(pSite);

     try
        BestArray := Array_t.Create;
        BestArray.init(SizeOf(integer),ARR_STEP_SIZE);
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in BestArray.init',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
     iBestCount := 0;

     for iNCount := 1 to iSitesToSelect do
     begin
          if (iSQLArrCount = 0) then
          begin
               rMax := 0;

               {we must choose Available sites from the site array}
               for iCount := 1 to iSiteCount do
               begin
                    SiteArr.rtnValue(iCount,pSite);

                    {if geocode is not on list of selected sites}
                    if (not IsSiteAlreadyChosen(pSite^.iKey)) then
                       if (pSite^.status = Av)
                       or (pSite^.status = Fl) then
                       begin
                            case iFlag of
                                 IRREP_FLAG : rValue := pSite^.rIrreplaceability;
                                 SUMIRR_FLAG : rValue := pSite^.rSummedIrr;
                                 WAVIRR_FLAG : rValue := pSite^.rWAVIRR;
                                 PCCONTR_FLAG : rValue := pSite^.rPCUSED;
                            end;

                            if (rValue > rMax) then
                            begin
                                 rMax := rValue;
                                 iKeyChosen := pSite^.iKey;
                            end;
                       end;
               end;

               if (rMax > 0) then
                  {add this geocode to the list}
                  AddASite(iKeyChosen)
               else
                   sMsg := 'No sites with non zero value remain';
          end
          else
          begin
               rMax := 0;

               {we must choose from a subset of Available sites in the SQLArray
                which is the result of the SQL Query}
               for iCount := 1 to iSQLArrCount do
               begin
                    SQLArray.rtnValue(iCount,@iKey);

                    iSiteIndex := FindFeatMatch(OrdSiteArr,iKey);
                    SiteArr.rtnValue(iSiteIndex,pSite);

                    {if geocode is not on list of selected sites}
                    if (not IsSiteAlreadyChosen(pSite^.iKey)) then
                       if (pSite^.status = Av)
                       or (pSite^.status = Fl) then
                       begin
                            case iFlag of
                                 IRREP_FLAG : rValue := pSite^.rIrreplaceability;
                                 SUMIRR_FLAG : rValue := pSite^.rSummedIrr;
                                 WAVIRR_FLAG : rValue := pSite^.rWAVIRR;
                                 PCCONTR_FLAG : rValue := pSite^.rPCUSED;
                            end;

                            if (rValue > rMax) then
                            begin
                                 rMax := rValue;
                                 iKeyChosen := pSite^.iKey;

                            end;
                       end;
               end;

               if (rMax > 0) then
                  AddASite(iKeyChosen)
               else
                   sMsg := 'No sites remain which satisfy SQL criteria';
               {add this geocode to the list}
          end;
     end;

     {}

     if (iBestCount > 0) then
     begin
          {resize the AResultSites array to compact it}
          if (iBestCount <> BestArray.lMaxSize) then
             BestArray.resize(iBestCount);
     end
     else
     begin
          BestArray.Destroy;
          {dispose of the empty site array}

          MessageDlg(sMsg,mtInformation,[mbOk],0);
     end;

     dispose(pSite);
end;

function AreFeaturesSatisfied(var iFeaturesSatisfied : integer;
                              const fTestClasses : boolean;
                              const ClassesToTest : ClassDetail_T) : boolean;
var
   iCount, iNum : integer;
   pFeat : featureoccurrencepointer;
   SatisfiedInEachClass : ClassDetail_T;
   rTargetArea, rDestructArea : extended;
begin
     Result := True;
     new(pFeat);
     iFeaturesSatisfied := 0;

     if fTestClasses then
     begin
          for iCount := 1 to iFeatureCount do
          begin
               FeatArr.rtnValue(iCount,pFeat);
               if (pFeat^.iOrdinalClass > 0) then
                  if (pFeat^.targetarea > 0)
                  and ClassesToTest[pFeat^.iOrdinalClass] then
                      Result := False;

               if (pFeat^.targetarea <= 0) then
                  Inc(iFeaturesSatisfied);
          end;
     end
     else
     begin
          for iCount := 1 to iFeatureCount do
          begin
               FeatArr.rtnValue(iCount,pFeat);

               rTargetArea := pFeat^.targetarea;

               if (iDestructionYear > -1) then
               begin
                    DestructArea.rtnValue(iCount,@rDestructArea);
                    if (rTargetArea > pFeat^.rCurrentSumArea) then
                       rTargetArea := pFeat^.rCurrentSumArea
               end;

               if (rTargetArea < 0.001) then
                  Inc(iFeaturesSatisfied)
               else
                   Result := False;
          end;
     end;

     dispose(pFeat);
end;

function TMinsetForm.AreSQLFieldsStatic : boolean;
var
   fNonStaticFieldFound : boolean;

  procedure TestThisField(const sField : string);
  var
     iCount : integer;
  begin
       {if this field is contained in the
        MinsetForm.SQLMemo, return False, else True}
       if (SQLMemo.Lines.Count > 0) then
          for iCount := 0 to (SQLMemo.Lines.Count-1) do
              if (Pos(UpperCase(sField),
                     UpperCase(SQLMemo.Lines.Strings[iCount])) > 0) then
                 fNonStaticFieldFound := True;
  end;

begin
     {}

     fNonStaticFieldFound := False;

     TestThisField(STATUS_DBLABEL);
     TestThisField(SUMMED_IRREPL_DBLABEL);
     TestThisField('I_SUMIRR');
     TestThisField(WAVIRR_DBLABEL);
     TestThisField('I_WAVIRR');

     if ControlRes^.fUseNewDBLabels then
     begin
          TestThisField(NEW_IRREPL_DBLABEL);
          TestThisField(NEW_INITIRR_DBLABEL);
          TestThisField(NEW_PERCENT_AREA_DBLABEL);
          TestThisField(NEW_DISP_DBLABEL);
          TestThisField(NEW_PREV_DISP_DBLABEL);
     end
     else
     begin
          TestThisField(IRREPLACEABILITY_DBLABEL);
          TestThisField(INITIAL_IRREPLACEABILITY_DBLABEL);
          TestThisField(PERCENT_AREA_USED_DBLABEL);
          TestThisField(IRREPLACEABILITY_DISPLAY_CLASS_DBLABEL);
          TestThisField(PREVIOUS_DISPLAY_CLASS_DBLABEL);
     end;

     Result := fNonStaticFieldFound;
end;

function IsResourceLimitExceeded(const iBestCount,iResArrCount : integer;
                                 const BestArray,ResArray : Array_t;
                                 var rDeferred : extended;
                                 const rTotalResource, rPartDeferred : extended;
                                 const iPercentWeCanDeferr : integer) : boolean;
var
   iKey, iCount, iResCount : integer;
   ResElement : ResourceElement_t;
   rProposedDeferred,
   rAmountWeCanDeferr : extended;
begin
     {determines whether rDeferred with the addition of the
      resource (stored in ResArray) contained by the sites
      in BestArray will exceed the limit which has been set}
     rProposedDeferred := 0;
     rAmountWeCanDeferr := rTotalResource * iPercentWeCanDeferr / 100;

     for iResCount := 1 to iResArrCount do
     begin
          ResArray.rtnValue(iResCount,@ResElement);

          for iCount := 1 to iBestCount do
          begin
               BestArray.rtnValue(iCount,@iKey);

               if (iKey = ResElement.iKey) then
                  rProposedDeferred := rProposedDeferred + ResElement.rResource;
          end;
     end;

     if ((rProposedDeferred + rDeferred) > rAmountWeCanDeferr) then
        Result := True
     else
     begin
          Result := False;
          rDeferred := rDeferred + rProposedDeferred;
     end;
end;

procedure TMinsetForm.FormCreate(Sender: TObject);
begin
     if (ControlForm.Available.Items.Count > 0) then
     begin
          SpinSelect.MinValue := 1;
          SpinSelect.MaxValue := ControlForm.Available.Items.Count;
          SpinSelect.Value := 1;

          {we need to load available resource fields to the
           SpinResource.Items if there are any}
          try
             ChooseResForm := TChooseResForm.Create(Application);

             if (ChooseResForm.CResBox.Items.Count > 0) then
             begin
                  MinsetExpertForm.ComboResource.Items := ChooseResForm.CResBox.Items;
                  MinsetExpertForm.ComboResource.Text := MinsetExpertForm.ComboResource.Items.Strings[0];
             end
             else
             begin
                  {there are no resource fields}
                  GroupBox2.Enabled := False;
                  checkResourceLimit.Enabled := False;
                  SpinResource.Enabled := False;
                  MinsetExpertForm.ComboResource.Enabled := False;
             end;

          finally
                 ChooseResForm.Free;
          end;
     end
     else
     begin
          SpinSelect.MinValue := 0;
          SpinSelect.MaxValue := 0;
          SpinSelect.Value := 0;
     end;
end;


procedure TMinsetForm.SQLMemoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     RunSQL(SQL_MINSET);
     if (SQLMemo.Lines.Count = 1)
     and (SQLMemo.Lines.Strings[0] = 'No Query Specified') then
         checkSQLCondition.Checked := False
     else
         checkSQLCondition.Checked := True;
         {automatically check the box if a user specifys an SQL Query}
end;

procedure TMinsetForm.CheckSQLConditionClick(Sender: TObject);
begin
     if (SQLMemo.Lines.Count = 1) then
        if (MinsetForm.SQLMemo.Lines.Strings[0] = 'No Query Specified') then
              if (CheckSQLCondition.Checked = True) then
              begin
                   RunSQL(SQL_MINSET);

                   if (SQLMemo.Lines.Count = 1)
                   and (MinsetForm.SQLMemo.Lines.Strings[0] = 'No Query Specified') then
                       CheckSQLCondition.Checked := False;
              end;
end;

procedure TMinsetForm.SpinResourceChange(Sender: TObject);
begin
     CheckResourceLimit.Checked := True;
end;

procedure TMinsetForm.ComboResourceChange(Sender: TObject);
begin
     CheckResourceLimit.Checked := True;
end;

end.
