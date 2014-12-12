unit sf_32;

interface

{$DEFINE _standard_}
{$DEFINE _standard_target_}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Spin;

type
  TSF32Form = class(TForm)
    OutBox: TListBox;
    Panel1: TPanel;
    Button1: TButton;
    RadioPred: TRadioGroup;
    InEdit: TEdit;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    Label2: TLabel;
    Label3: TLabel;
    SpinSites: TSpinEdit;
    SpinFeatures: TSpinEdit;
    RadioGroup1: TRadioGroup;
    SpinEdit3: TSpinEdit;
    Button2: TButton;
    Button3: TButton;
    SaveDialog1: TSaveDialog;
    Edit1: TEdit;
    Label4: TLabel;
    CheckBox1: TCheckBox;
    Button4: TButton;
    Listbox1: TListBox;
    CheckWriteTargets: TCheckBox;
    CheckDebugCombsize: TCheckBox;
    CheckWriteMatrix: TCheckBox;
    KillTimer: TTimer;
    procedure RadioGroup1Click(Sender: TObject);
    procedure InEditMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Edit1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RunDebugProcess;
    procedure KillTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SF32Form: TSF32Form;

implementation

{$R *.DFM}
//const
   //sites = 10000;
   //features = 210;
var
   {area : array[0..sites,1..features] of extended;
   sum,sum2 : array[1..features] of extended;
   target : array[1..features] of extended;
   repr_include,repr_exclude,repr_incexc,irr_feature : array[1..features] of extended;
   pred_irr : array[1..sites] of extended;}

   area, // : array[0..sites,1..features] of extended;
   sum,sum2, // : array[1..features] of extended;
   target, // : array[1..features] of extended;
   repr_include,repr_exclude,repr_incexc,irr_feature, // : array[1..features] of extended;
   pred_irr, pred_sum_irr : variant; // : array[1..sites] of extended;
   fArraysCreated : boolean;
   combsize,site,feature : longint;
   pcomb,qcomb,mult,wt_include,wt_exclude,total_repr_include,
   total_repr_exclude,total_repr_incexc : extended;
   {outfile : text;}
   {dispclass : array[1..10] of longint;}
   i,j, iSiteCount, iFeatureCount : integer;
{----------------------------------------------------------------------------}
function zprob (x: extended) : extended;
var
   z,t,q,m : extended;
   negative : boolean;
begin
   if x < 0 then
   begin
      negative:=true;
      x:=0-x;
   end
   else
      negative:=false;
   if x > 50 then
      x:=50;
   z:=0.3989*exp((0-sqr(x))/2);
   t:=1/(1+0.23164*x);
   m:=t;
   q:=0.31938*m;
   m:=m*t;
   q:=q-0.35656*m;
   m:=m*t;
   q:=q+1.78148*m;
   m:=m*t;
   q:=q-1.82126*m;
   m:=m*t;
   q:=q+1.33027*m;
   if negative then
      zprob:=1-q*z
   else
      zprob:=q*z;
end;
{----------------------------------------------------------------------------}
procedure read_site_data;
var
{$ifdef _standard_}
   infile : text;
   extendedarea : extended;
{$else}
   infile : file of word;
   wordarea : word;
{$endif}
   site,feature : longint;
begin
     assign (infile,SF32Form.InEdit.Text);
     reset (infile);
     for site:=1 to iSiteCount do
     begin
          for feature:=1 to iFeatureCount do
          begin
               {$ifdef _standard_}
               read (infile,extendedarea);
               {$else}
               blockread(infile,wordarea,1);
               //         wordarea := wordarea*4;
               {$endif}
               {$ifdef _standard_}
               //area[site,feature]:=trunc(extendedarea*4);
               area[site,feature] := extendedarea;
               {$else}
               area[site,feature]:= wordarea;
               {$endif}
          end;
          {$ifdef _standard_}
          readln (infile);
          {$endif}
     end;
     close (infile);
end;
{----------------------------------------------------------------------------}
procedure build_sum_tables;
var
   feature,site : longint;
begin
   for feature:=1 to iFeatureCount do
   begin
      sum[feature]:=0;
      sum2[feature]:=0;
      for site:=1 to iSiteCount do
      begin
         sum[feature]:=sum[feature]+area[site,feature];
         sum2[feature]:=sum2[feature]+sqr(1.0*area[site,feature]);
      end;
      AREA[0,FEATURE]:={ROUND}(SUM[FEATURE]*1.0/iSiteCount);
     { WRITELN (FEATURE,' ',SUM[FEATURE],' ',SUM[FEATURE]*1.0/SITES:10:4,' ',AREA[0,FEATURE]);
      READLN;}
   end;
end;
{----------------------------------------------------------------------------}
procedure set_targets;
var
   feature : longint;
begin
   for feature:=1 to iFeatureCount do
   begin
      target[feature]:=sum[feature]*0.60;
   end;
end;
{----------------------------------------------------------------------------}

procedure write_matrix;
var
   iSite, iFeature : integer;
   MatrixFile : TextFile;
begin
     //
     assign(MatrixFile,'Matrix.csv');
     rewrite(MatrixFile);

     write(MatrixFile,'Sites,');
     // write feature identifiers to the first row
     for iFeature := 1 to iFeatureCount do
         if (iFeature <> iFeatureCount) then
            write(MatrixFile,IntToStr(iFeature) + ',')
         else
             writeln(MatrixFile,IntToStr(iFeature));

     for iSite := 1 to iSiteCount do
     begin
          // write site identifier to 1st column of 2nd and additional rows
          write(MatrixFile,IntToStr(iSite) + ',');

          for iFeature := 1 to iFeatureCount do
              if (iFeature <> iFeatureCount) then
                 write(MatrixFile,FloatToStr(area[iSite,iFeature]) + ',')
              else

                  writeln(MatrixFile,FloatToStr(area[iSite,iFeature]));
     end;

     closefile(MatrixFile);
end;

procedure write_targets;
var
   feature : longint;
   targfile : text;
begin
     assign(targfile,'targ.csv');
     rewrite(targfile);

     writeln(targfile,'Findex,target,total');

     for feature := 1 to iFeatureCount do
     begin
          writeln(targfile,IntToStr(feature) + ',' + FloatToStr(target[feature]) + ',' + FloatToStr(sum[feature]));
     end;

     closefile(targfile);
end;

procedure set_targets_file(const sFile : string);
var
   feature : longint;
   targfile : text;
   rValue : extended;

begin
     assign(targfile,sFile);
     reset(targfile);

     for feature:=1 to iFeatureCount do
     begin
          readln(targfile,rValue);

{$ifdef _standard_target_}
          //rValue := rValue * 4;

          if (rValue < 0) then
             rValue := 0;

          if (rValue > sum[feature]) then
          begin
               {
               MessageDlg('!!! value ' +
                          floattostr(rValue) +
                          ' sum ' +
                          floattostr(sum[feature]) +
                          ' feature ' +
                          inttostr(feature),
                          mtError,[mbOk],0);
               }

               rValue := sum[feature];
          end;
{$else}
          rValue := rValue * sum[feature] /100;
{$endif}
          target[feature] := rValue;
     end;

     close(targfile);
end;
{----------------------------------------------------------------------------}
function predict_repr_comb (combsize: longint) : extended;
var
   feature : longint;
   mean_site,mean_target,sd,z,sumarea,sumarea2,repr_comb,combadj : extended;
begin
   repr_comb:=1;
   for feature:=1 to iFeatureCount do
   begin
      mean_target:=target[feature]/combsize;
      sumarea:=sum[feature];
      sumarea2:=sum2[feature];
      mean_site:=sumarea/iSiteCount;
      if combsize > iSiteCount/2 then
         combadj:=sqrt(iSiteCount-combsize)/combsize
      else
         combadj:=sqrt(combsize)/combsize;
      sd:=(sqrt((sumarea2-sqr(sumarea)/iSiteCount)/(iSiteCount)))*combadj;
      if sd < 0.00000000001 then
         z:=-50
      else
         z:=(mean_target-mean_site)/sd;
      repr_comb:=repr_comb*zprob(z);
   end;
   predict_repr_comb:=repr_comb;
end;
{----------------------------------------------------------------------------}
procedure init_irr_variables (combsize: longint);
begin
   pcomb:=1/combsize;
   qcomb:=1-pcomb;
   pcomb:=pcomb*iSiteCount;
   mult:=iSiteCount/(iSiteCount-1);
   wt_include:=combsize/iSiteCount;
   wt_exclude:=1-wt_include;
end;
{----------------------------------------------------------------------------}

{----------------------------------------------------------------------------}
function sf3_predict_irreplaceability (site: longint;
                                       const fDebug : boolean;
                                       const sDebugFile : string) : extended;
label
   skip1,skip2;
var
   feature : longint;
   mean_site,sd,z,area_site,area2_site,sumarea,sumarea2,mean_target,zmin,
   combadj : extended;

   dbgfile : text;
begin

   if fDebug then
   begin
        assignfile(dbgfile,sDebugFile);
        rewrite(dbgfile);
        writeln(dbgfile,'fcode,target,area_site,area2_site,sumarea,sumarea2,mean_site,irr_feature,repr_include,repr_exclude');
   end;

   for feature:=1 to iFeatureCount do
   begin
         area_site:=area[site,feature];
         area2_site:=sqr(area_site);
         sumarea:=(sum[feature]-area_site)*mult;
         sumarea2:=(sum2[feature]-area2_site)*mult;
         mean_site:=sumarea/iSiteCount;
         if (combsize-1) > (iSiteCount-1)/2.0 then
            combadj:=sqrt((iSiteCount-1)-(combsize-1))/(combsize-1)
         else
            combadj:=sqrt(combsize-1)/(combsize-1);

         try
            sd := sumarea2 - (sqr(sumarea)/iSiteCount);
            {sd := sd / iSiteCount;}
            sd := sd / iSiteCount;
            sd := sqrt(sd);
            sd := sd * combadj;

         except
               sd := 0;
         end;

         {don't know the purpose of this block of code
          switch it off for select combsize because
          it is setting repr_exclude to zero when it should be non zero(?)}

         if (site > 0) then
            if (sum[feature]-area_site) < target[feature] then
            begin
               repr_exclude[feature]:=0;
               goto skip1;
            end;

         mean_target:=target[feature]/(combsize-1);
         if sd < 0.00000000001 then
         begin
            if mean_site < mean_target then
               repr_exclude[feature]:=0
            else
               repr_exclude[feature]:=1;
         end
         else
         begin
            z:=(mean_target-mean_site)/sd;
            repr_exclude[feature]:=zprob(z);
         end;
 skip1:
         if area_site >= target[feature] then
         begin
            repr_include[feature]:=1;
            goto skip2;
         end;
         mean_target:=(target[feature]-area_site)/(combsize-1);
         if sd < 0.00000000001 then
         begin
            if mean_site < mean_target then
            begin
                 repr_include[feature]:=1;
                 repr_exclude[feature]:=1;
            end
            else
               repr_include[feature]:=1;
         end
         else
         begin
            z:=(mean_target-mean_site)/sd;
            if (z>35) then
            begin
                 repr_include[feature]:=1;
                 repr_exclude[feature]:=1;
            end
            else
                repr_include[feature]:=zprob(z);
         end;
 skip2:
         if (repr_include[feature] = 0) and (area[site,feature] > 0) then
            repr_include[feature]:=1;
         if repr_include[feature] = 0 then
            irr_feature[feature]:=0
         else
            irr_feature[feature]:=(repr_include[feature]-repr_exclude[feature])/repr_include[feature];

         {if (feature = 2) then
            SF32Form.Listbox1.Items.Add('f' + IntToStr(feature) + ' ' + FloatToStr(irr_feature[feature]) +
                                        ' area_site ' + FloatToStr(area_site)); }
         {writeln(outfile,' f sd ',sd,' m_s ',mean_site,' irr ',irr_feature[feature],' zp ',repr_include[feature]);}

         if fDebug then
            writeln(dbgfile,
                    IntToStr(feature) + ',' +
                    FloatToStr(target[feature]) + ',' +
                    FloatToStr(area_site) + ',' +
                    FloatToStr(area2_site) + ',' +
                    FloatToStr(sumarea) + ',' +
                    FloatToStr(sumarea2) + ',' +
                    FloatToStr(mean_site) + ',' +
                    FloatToStr(irr_feature[feature]) + ',' +
                    FloatToStr(repr_include[feature]) + ',' +
                    FloatToStr(repr_exclude[feature])
                    );
   end;

   if fDebug then
      closefile(dbgfile);

   total_repr_include:=1;
   total_repr_exclude:=1;
   for feature:=1 to iFeatureCount do
   begin
      total_repr_include:=total_repr_include*repr_include[feature];
      total_repr_exclude:=total_repr_exclude*repr_exclude[feature];
   end;
   if total_repr_include = 0 then
      sf3_predict_irreplaceability:=0
   else
      sf3_predict_irreplaceability:=(total_repr_include-total_repr_exclude)/total_repr_include;
end;
{----------------------------------------------------------------------------}
function sf3_select_combsize : longint;
var
  { combsize : longint;  }
   pred_comb : Variant; //array[1..sites] of extended;
   min_repr,max_repr,mid_repr,BEST : extended;
   i : integer;
begin
     pred_comb := VarArrayCreate([1,iSiteCount],varDouble);

   for combsize:=2 to iSiteCount-1 do
   BEGIN
      INIT_IRR_VARIABLES (COMBSIZE);
      pred_comb[combsize]:=sf3_PREDICT_IRREPLACEABILITY(0,
                                                        sf32Form.CheckDebugCombsize.Checked,   {debug mode flag}
                                                        'comb' + IntToStr(combsize) + '.csv'); {debug filename (if applicable)}
      SF32Form.OutBox.Items.Add(IntToStr(COMBSIZE) + ' ' + FloatToStr(PRED_COMB[COMBSIZE]));
   END;
   BEST:=1000;
   FOR I:=2 TO iSiteCount-1 DO
   BEGIN
      IF ABS(PRED_COMB[I]-0.5) <= BEST THEN
      BEGIN
         COMBSIZE:=I;
         BEST:=ABS(PRED_COMB[I]-0.5);
      END;
   END;
   sf3_select_combsize:=combsize;
end;

{----------------------------------------------------------------------------}
function sf4_predict_irreplaceability (site: longint) : double;
label
   skip1,skip2,skip3;
var
   feature, iCount : longint;
   mean_site,sd,z,area_site,area2_site,sumarea,sumarea2,mean_target,zmin,
   combadj : extended;
begin
     for feature:=1 to iFeatureCount do
     begin
           area_site:=area[site,feature];
           area2_site:=sqr(area_site);
           sumarea:=(sum[feature]-area_site)*mult;
           sumarea2:=(sum2[feature]-area2_site)*mult;
           mean_site:=sumarea/iSiteCount;
           if (combsize-1) > (iSiteCount-1)/2.0 then
              combadj:=sqrt((iSiteCount-1)-(combsize-1))/(combsize-1)
           else
              combadj:=sqrt(combsize-1)/(combsize-1);
           sd:=(sqrt((sumarea2-(sqr(sumarea)/iSiteCount))/(iSiteCount)))*combadj;

           {test removing this block of code because it works for sf3...
            Matt 23Mar98

            remove for predict combsize
            keep in for run irreplaceability}
           if (site > 0) then
              if (sum[feature]-area_site) < target[feature] then
              begin
                 repr_incexc[feature]:=0;
                 goto skip1;
              end;

           mean_target:=target[feature]/(combsize-1);
           if sd < 0.00000000001 then
           begin
              if mean_site < mean_target then
                 repr_incexc[feature]:=0
              else
                 repr_incexc[feature]:=1;
           end
           else
           begin
              z:=(mean_target-mean_site)/sd;
              repr_incexc[feature]:=zprob(z);
           end;
   skip1:
           if area_site >= target[feature] then
           begin
              repr_include[feature]:=1;
              goto skip2;
           end;
           mean_target:=(target[feature]-area_site)/(combsize-1);
           if sd < 0.00000000001 then
           begin
              if mean_site < mean_target then
                 repr_include[feature]:=0
              else
                 repr_include[feature]:=1;
           end
           else
           begin
              z:=(mean_target-mean_site)/sd;
              repr_include[feature]:=zprob(z);
           end;
   skip2:
           if (combsize) > (iSiteCount-1)/2.0 then
              combadj:=sqrt((iSiteCount-1)-(combsize))/(combsize)
           else
              combadj:=sqrt(combsize)/(combsize);
           sd:=(sqrt((sumarea2-sqr(sumarea)/iSiteCount)/(iSiteCount)))*combadj;
           if (sum[feature]-area_site) < target[feature] then
           begin
              repr_exclude[feature]:=0;
              goto skip3;
           end;
           mean_target:=target[feature]/(combsize);
           if sd < 0.00000000001 then
           begin
              if mean_site < mean_target then
                 repr_exclude[feature]:=0
              else
                 repr_exclude[feature]:=1;
           end
           else
           begin
              z:=(mean_target-mean_site)/sd;
              repr_exclude[feature]:=zprob(z);
           end;
  skip3:
           if (repr_include[feature] = 0) and (area[site,feature] > 0) then
              repr_include[feature]:=1;
           if (repr_include[feature] + repr_exclude[feature]) = 0 then
              irr_feature[feature]:=0
           else
              irr_feature[feature]:=((repr_include[feature]-repr_incexc[feature])*wt_include)
                 /(repr_include[feature]*wt_include+repr_exclude[feature]*wt_exclude);

           if (feature = 2) then
              SF32Form.Listbox1.Items.Add('f' + IntToStr(feature) + ' ' + FloatToStr(irr_feature[feature]) +
                                          ' area_site ' + FloatToStr(area_site));

           // accumulate sumirr for this site
           pred_sum_irr[site] := pred_sum_irr[site] + irr_feature[feature];
     end;
     total_repr_include:=1;
     total_repr_exclude:=1;
     total_repr_incexc:=1;
     for feature:=1 to iFeatureCount do
     begin
        total_repr_include:=total_repr_include*repr_include[feature];
        total_repr_exclude:=total_repr_exclude*repr_exclude[feature];
        total_repr_incexc:=total_repr_incexc*repr_incexc[feature];
     end;
     if (total_repr_include+total_repr_exclude) = 0 then
        sf4_predict_irreplaceability:=0
     else
        sf4_predict_irreplaceability:=((total_repr_include-total_repr_incexc)*wt_include)
                 /(total_repr_include*wt_include+total_repr_exclude*wt_exclude);
end;
{----------------------------------------------------------------------------}
function sf4_select_combsize : longint;
var
  { combsize : longint;  }
   pred_comb : Variant; //array[1..sites] of extended;
   min_repr,max_repr,mid_repr,BEST : extended;
   i : integer;
begin
     pred_comb := VarArrayCreate([1,iSiteCount],varDouble);

   for combsize:=2 to iSiteCount-1 do
   BEGIN
      INIT_IRR_VARIABLES (COMBSIZE);
      pred_comb[combsize]:=sf4_PREDICT_IRREPLACEABILITY(0);
      SF32Form.OutBox.Items.Add(IntToStr(COMBSIZE) + ' ' + FloatToStr(PRED_COMB[COMBSIZE]));
   END;
   BEST:=1000;
   FOR I:=2 TO iSiteCount-1 DO
   BEGIN
      IF ABS(PRED_COMB[I]-0.5) < BEST THEN
      BEGIN
         COMBSIZE:=I;
         BEST:=ABS(PRED_COMB[I]-0.5);
      END;
   END;
   sf4_select_combsize:=combsize;
end;

{----------------------------------------------------------------------------}
procedure RunPredictor;
begin
     iSiteCount := SF32Form.SpinSites.Value;
     iFeatureCount := SF32Form.SpinFeatures.Value;

     // create the variant arrays that will store the data
     if not fArraysCreated then
     begin
          area := VarArrayCreate([0,iSiteCount,1,iFeatureCount],varDouble); // : array[0..sites,1..features] of extended;
          sum := VarArrayCreate([1,iFeatureCount],varDouble);
          sum2 := VarArrayCreate([1,iFeatureCount],varDouble);
          target := VarArrayCreate([1,iFeatureCount],varDouble);
          repr_include  := VarArrayCreate([1,iFeatureCount],varDouble);
          repr_exclude := VarArrayCreate([1,iFeatureCount],varDouble);
          repr_incexc := VarArrayCreate([1,iFeatureCount],varDouble);
          irr_feature := VarArrayCreate([1,iFeatureCount],varDouble); // : array[1..features] of extended;
          pred_irr  := VarArrayCreate([1,iSiteCount],varDouble);
          pred_sum_irr := VarArrayCreate([1,iSiteCount],varDouble); // : array[1..sites] of extended;

          fArraysCreated := True;
     end;

     {if (iSiteCount > Sites) then
     begin
          MessageDlg('Too many sites, max is ' + IntToStr(Sites),
                     mtInformation,[mbOk],0);
          exit;
          Application.Terminate;
     end;
     if (iFeatureCount > Features) then
     begin
          MessageDlg('Too many features, max is ' + IntToStr(Features),
                     mtInformation,[mbOk],0);
          exit;
          Application.Terminate;
     end;}

     read_site_data;
     build_sum_tables;

     if sf32form.Checkbox1.Checked then
        set_targets_file(sf32form.Edit1.Text)
     else
         set_targets;

     if sf32form.CheckWriteTargets.Checked then
        write_targets;

     if sf32form.CheckWriteMatrix.Checked then
        write_matrix;

     SF32Form.OutBox.Items.Clear;
     SF32Form.Listbox1.Items.Clear;

     if (SF32Form.RadioGroup1.ItemIndex = 0) then
        case SF32Form.RadioPred.ItemIndex of
             0 : combsize := sf3_select_combsize;
             1 : combsize := sf4_select_combsize;
        end
     else
         combsize := SF32Form.SpinEdit3.Value;

     SF32Form.OutBox.Items.Add('');
     SF32Form.OutBox.Items.Add('combsize = ' +
                               IntToStr(combsize));
     SF32Form.OutBox.Items.Add('');

     init_irr_variables(combsize);

     for site:=1 to iSiteCount do
     begin
          // init pred_sum_irr
          pred_sum_irr[site] := 0;

          case SF32Form.RadioPred.ItemIndex of
               0 : pred_irr[site]:=sf3_predict_irreplaceability(site,False,'');
               1 : pred_irr[site]:=sf4_predict_irreplaceability(site);
          end;

          SF32Form.OutBox.Items.Add(IntToStr(site) + ' ' +
                                    FloatToStr(pred_irr[site]));
     end;
end;
procedure TSF32Form.RadioGroup1Click(Sender: TObject);
begin
     if (RadioGroup1.ItemIndex) = 0 then
        SpinEdit3.Enabled := False
     else
         SpinEdit3.Enabled := True;
end;

procedure TSF32Form.InEditMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     OpenDialog1.Title := 'locate matrix file';

     if OpenDialog1.Execute then
        InEdit.Text := OpenDialog1.Filename;
end;

procedure TSF32Form.Button1Click(Sender: TObject);
begin
     if SaveDialog1.Execute then
        OutBox.Items.SaveToFile(SaveDialog1.Filename);
end;

procedure TSF32Form.Button2Click(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;
        RunPredictor;

     except
           Screen.Cursor := crDefault;
           MessageDlg('exception in RunPredictor',mtInformation,[mbOk],0);
     end;

     Screen.Cursor := crDefault;
end;

procedure TSF32Form.Button3Click(Sender: TObject);
begin
     Application.Terminate;
end;

procedure TSF32Form.Edit1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     OpenDialog1.Title := 'locate target file';
     if OpenDialog1.Execute then
        Edit1.Text := OpenDialog1.Filename;
end;

procedure TSF32Form.Button4Click(Sender: TObject);
begin
     if SaveDialog1.Execute then
        Listbox1.Items.SaveToFile(SaveDialog1.Filename);
end;

procedure StoreIrrepResults(const sFilename : string);
var
   Outfile : TextFile;
   iCount : integer;
begin
     assignfile(OutFile,sFilename);
     rewrite(OutFile);
     writeln(OutFile,'index,pred_irr,pred_sum_irr');
     for iCount := 1 to iSiteCount do
     begin
          writeln(OutFile,IntToStr(iCount) + ',' +
                          FloatToStr(pred_irr[iCount]) + ',' +
                          FloatToStr(pred_sum_irr[iCount]));
     end;         
     closefile(OutFile);

end;

procedure TSF32Form.RunDebugProcess;
var
   sPath : string;
   iCombsize, iSelectedCombsize, iSites, iFeatures : integer;
   OutputFile : TextFile;
begin
     try
        iCombsize := StrToInt(ParamStr(1));
        iSites := StrToInt(ParamStr(2));
        iFeatures := StrToInt(ParamStr(3));

        SpinSites.Value := iSites;
        SpinFeatures.Value := iFeatures;

        sPath := ExtractFilePath(Application.ExeName);
        // set matrix name
        InEdit.Text := sPath +
                       IntToStr(iSites) + 'x' +
                       IntToStr(iFeatures) + 'matrix.txt';
        // set target name
        Edit1.Text := sPath +
                      IntToStr(iSites) + 'x' +
                      IntToStr(iFeatures) + 'target.txt';
        // use target file
        CheckBox1.Checked := True;

        assignfile(OutputFile,sPath +
                              IntToStr(iSites) + 'x' +
                              IntToStr(iFeatures) + 'output.txt');
        rewrite(OutputFile);
        writeln(OutputFile,'process started at ' + TimeToStr(Time));
        writeln(OutputFile,'');
        writeln(OutputFile,'combsize passed = ' + IntToStr(iCombsize));
        writeln(OutputFile,'sites = ' + IntToStr(iSites));
        writeln(OutputFile,'features = ' + IntToStr(iFeatures));
        writeln(OutputFile,'');

        // calculate combination size that predictor would choose and run irrep at this combsize
        // use predictor 3 to calculate combination size (same as C-Plan does)
        RadioPred.ItemIndex := 0;
        RunPredictor;
        // store combination size that has been calculated
        iSelectedCombsize := combsize;
        writeln(OutputFile,'combsize selected = ' + IntToStr(iSelectedCombsize));

        // choose predictor 4 to calculate irreplaceability with
        RadioPred.ItemIndex := 1;
        // set user defined combination size at passed combsize
        RadioGroup1.ItemIndex := 1;
        SpinEdit3.Value := iCombsize;
        // run irrep at the combsize that has been passed
        RunPredictor;

        // store the results of iCombsize
        StoreIrrepResults(sPath +
                          IntToStr(iSites) + 'x' +
                          IntToStr(iFeatures) + '_passed_combsize.csv');

        // set user defined combination size at selected combsize
        RadioGroup1.ItemIndex := 1;
        SpinEdit3.Value := iSelectedCombsize;
        // run irrep at the combsize that has been passed
        RunPredictor;

        // store the results of iSelectedCombsize
        StoreIrrepResults(sPath +
                          IntToStr(iSites) + 'x' +
                          IntToStr(iFeatures) + '_selected_combsize.csv');

        writeln(OutputFile,'');
        writeln(OutputFile,'process finished at ' + TimeToStr(Time));
        closefile(OutputFile);
        // write sync file
        assignfile(OutputFile,sPath +
                              IntToStr(iSites) + 'x' +
                              IntToStr(iFeatures) + 'sync');
        rewrite(OutputFile);
        closefile(OutputFile);

     except
     end;
end;

procedure TSF32Form.FormCreate(Sender: TObject);
begin
     fArraysCreated := False;
     // read the parameters if there are any
     if (ParamCount > 0) then
        if (ParamCount = 3) then
        begin
             RunDebugProcess;

             // activate kill timer
             KillTimer.Enabled := True;
        end;
end;

procedure TSF32Form.KillTimerTimer(Sender: TObject);
begin
     KillTimer.Enabled := False;
     Application.Terminate;
end;

end.
