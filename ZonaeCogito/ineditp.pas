unit ineditp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,math, ComCtrls,FileCtrl, ExtCtrls;

type
  TInEditForm = class(TForm)
    btnLoad: TButton;
    btnSave: TButton;
    btnExit: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    Edit3: TEdit;
    GroupBox5: TGroupBox;
    Label14: TLabel;
    Edit11: TEdit;
    h: TTabSheet;
    Label13: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    ComboBox2: TComboBox;
    Edit16: TEdit;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    Edit18: TEdit;
    Edit19: TEdit;
    btnBrowseOutput: TButton;
    Label17: TLabel;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    GroupBox3: TGroupBox;
    ComboBox3: TComboBox;
    ComboBox1: TComboBox;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    Label6: TLabel;
    CheckBox3: TCheckBox;
    Edit13: TEdit;
    Edit14: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    Edit1: TEdit;
    GroupBox6: TGroupBox;
    Label5: TLabel;
    Edit5: TEdit;
    Label9: TLabel;
    Edit2: TEdit;
    CheckBox1: TCheckBox;
    Label10: TLabel;
    Label11: TLabel;
    Edit4: TEdit;
    Edit6: TEdit;
    Label15: TLabel;
    Label16: TLabel;
    CheckBox2: TCheckBox;
    Edit7: TEdit;
    GroupBox7: TGroupBox;
    Edit9: TEdit;
    Label18: TLabel;
    Edit10: TEdit;
    CheckBox9: TCheckBox;
    Label20: TLabel;
    Edit8: TEdit;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    RadioGroup1: TRadioGroup;
    TabSheet6: TTabSheet;
    btnBrowseInput: TButton;
    Edit17: TEdit;
    Label12: TLabel;
    GroupBox4: TGroupBox;
    Label21: TLabel;
    Label25: TLabel;
    Label28: TLabel;
    GroupBox8: TGroupBox;
    Label26: TLabel;
    Edit12: TEdit;
    Edit15: TEdit;
    Edit20: TEdit;
    Edit21: TEdit;
    Edit22: TEdit;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    TabSheet7: TTabSheet;
    GroupBox9: TGroupBox;
    Label19: TLabel;
    Label27: TLabel;
    Label29: TLabel;
    Edit23: TEdit;
    Edit24: TEdit;
    Edit25: TEdit;
    GroupBox10: TGroupBox;
    Edit26: TEdit;
    Edit27: TEdit;
    CheckBox16: TCheckBox;
    CheckEnableMarZone: TCheckBox;
    Label31: TLabel;
    Label32: TLabel;
    CheckBox15: TCheckBox;
    Edit28: TEdit;
    Edit29: TEdit;
    Label30: TLabel;
    CheckBox17: TCheckBox;
    CheckBox18: TCheckBox;
    procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure Edit6Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit7Change(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure ComboBox4Change(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure btnBrowseInputClick(Sender: TObject);
    procedure btnBrowseOutputClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox9Click(Sender: TObject);
    procedure CheckBox12Click(Sender: TObject);
    procedure CheckBox13Click(Sender: TObject);
    procedure CheckBox14Click(Sender: TObject);
    procedure CheckBox17Click(Sender: TObject);
    procedure CheckBox18Click(Sender: TObject);
  private
    { Private declarations }
  public
    puno,spno:integer;
    version:real;
    blm,prop: double;
    { Annealing Variables }
    iterations,Titns:integer;
    Tinit,Tcool:double;
    {various }
    iseed,repeats,outmode,verbose:integer;
    misslevel :double;
    outbest:double;
    runopts:integer;
    heurotype:integer;
    costthresh,tpf1,tpf2:double;
    saverun,savebest,savesummary,savesen,savespecies:integer;
    savesumsoln,savelog:integer;
    savename:string[30];
    indir,outdir : string[200];
    ineditdir :string[200];
    specname:string[30];
    puname:string[30];
    puvsprname:string[30];
    boundaryname:string[30];
    blockdefname:string[30];
    tempstr:string;
    { Public declarations }
    procedure LoadFile(sDirectory : string);
    function compstr(str1,str2:string):boolean;
    procedure ReadVar(var infile:text; variable:pointer);
    procedure FindVar(var varaddress;
     var filename:string;  searchstr:string; vartype:integer;
     warn:boolean);
    procedure LoadFile2(sDirectory : string);
    function CheckChoice: boolean;
    procedure SaveFile;
    procedure SaveFile2;
    procedure NumbersChanged;
  end;

var
  InEditForm: TInEditForm;

implementation

uses
    inedit_browse;

{$R *.DFM}

function RegionSafeStrToFloat(const sCell : string) : extended;
var
   iPos : integer;
begin
     // safely reads a float with a . as DecimalSeperator when the DecimalSeperator
     // is other that .
     try
        Result := StrToFloat(sCell);

     except
           // StrToFloat has failed, so substitute DecimalSeperator for . in sCell and try again
           iPos := Pos('.',sCell);
           if (iPos > 1) then
              Result := StrToFloat(Copy(sCell,1,iPos-1) + DecimalSeparator + Copy(sCell,iPos+1,Length(sCell)-iPos));
     end;
end;

function RegionSafeFloatToStr(const rValue : extended) : string;
var
   iPos : integer;
begin
     // makes a float with . as DecimalSeperator safe to send to ArcView which
     // is not region specific ???? maybe overseas versions will be
     if (DecimalSeparator = '.') then
        Result := FloatToStr(rValue)
     else
     begin
          Result := FloatToStr(rValue);
          iPos := Pos(DecimalSeparator,Result);
          if (iPos > 1) then
             Result := Copy(Result,1,iPos-1) + '.' + Copy(Result,iPos+1,Length(Result)-iPos);
     end;
end;

function TInEditForm.Checkchoice: boolean;
var mistakes:integer;
begin
   mistakes := 0;
 if (RegionSafeStrToFloat(Edit3.text) < 0) then begin
     ShowMessage('Boundary modifier must be greater than or equal to 0');
     inc(mistakes);
   end;
   if (StrToInt(Edit5.text) < 0) then begin
     ShowMessage('Number of Iterations must be an integer 0 or greater');
     inc(mistakes);
   end;
  if (StrToInt(Edit11.text) < 0) then begin
     ShowMessage('repeat runs should be at least 0');
     inc(mistakes);
   end;

   if (mistakes >0) then begin
     Checkchoice := False;
     ShowMessage(IntToStr(mistakes) + ' errors must be corrected before saving.');
     end
   else
     Checkchoice := True;
end; {Procedure Checkchoice}

procedure TInEditForm.LoadFile(sDirectory : string);
var
   inf: TextFile;
   filename:string;
begin
     ineditdir := sDirectory;
     filename := 'input.dat';
     assignfile(inf,filename);
     reset(inf);
          readln(inf,version);
          readln(inf,blm);
          readln(inf,prop);
          readln(inf,iterations);
          readln(inf,Tinit);
          readln(inf,Tcool);
          readln(inf,Titns);
          readln(inf,iseed);
          readln(inf,outbest);
          readln(inf,repeats);
          readln(inf,costthresh); {Cost Threshold}
          readln(inf,tpf1); {CTF A}
          readln(inf,tpf2); {CTF B}
          readln(inf,saverun);
          readln(inf,savebest);
          readln(inf,savesummary);
          readln(inf,savesen);
          readln(inf,savespecies);
          readln(inf,savesumsoln);
          readln(inf,savename);
          readln(inf,indir);
          readln(inf,outdir);
          readln(inf,runopts);
          readln(inf,misslevel);
          readln(inf,heurotype);
          readln(inf,verbose);
     closefile(inf);
     Edit3.text := RegionSafeFloatToStr(blm);  {Boundary Length }
     Edit8.text := RegionSafeFloatToStr(prop);
     Edit10.text := RegionSafeFloatToStr(outbest);
     Edit9.text := IntToStr(iseed);
     if (iseed < 0) then
       Edit9.enabled := false
     else
       checkbox9.checked := true;
     { Annealing Controls }
     Edit5.text := IntToStr(iterations);
     Edit4.text := RegionSafeFloatToStr(Tinit);
     Edit6.text := RegionSafeFloatToStr(Tcool);
     Edit2.text := IntToStr(Titns);
     Edit11.text := IntToStr(repeats);
     Edit13.text := RegionSafeFloatToStr(costthresh);
     Edit14.text := RegionSafeFloatToStr(tpf1);
     Edit1.text := RegionSafeFloatToStr(tpf2);
     if (costthresh > 0) then begin
        Checkbox3.checked := true;
        edit13.enabled := true;
        edit14.enabled := true;
        edit1.enabled := true;
     end else begin
        Checkbox3.checked := false;
        edit13.enabled := false;
        edit14.enabled := false;
        edit1.enabled := false;
     end;
     combobox2.itemindex := verbose;
     combobox3.itemindex := runopts;
     if (runopts  in [1,4]) then   {run options and Heuristic Options }
       combobox1.enabled := False
     else
       combobox1.enabled := True;
     combobox1.itemindex := heurotype;

     if (Tinit < 0) then begin
         Checkbox1.checked := true;
         CheckBox1Click(self);
     end;

     Edit17.text := indir;
     Edit18.text := outdir;
     Edit19.text := RegionSafeFloatToStr(misslevel);

     {Output Saving}
     if (SaveRun > 0) then
        CheckBox4.checked := true
     else
        CheckBox4.checked := false;
     if (SaveBest > 0) then
        CheckBox5.checked := true
     else
        CheckBox5.checked := false;
     if (SaveSummary > 0) then
        CheckBox6.checked := true
     else
        CheckBox6.checked := false;
     if (SaveSen > 0) then
        CheckBox7.checked := true
     else
        CheckBox7.checked := false;
     if (SaveSpecies > 0) then
        CheckBox8.checked := true
     else
        CheckBox8.checked := false;
     if (savesumsoln >0) then
       CheckBox11.checked := true
     else
       CheckBox11.checked := false;

     if (savelog > 0) then
        CheckBox18.checked := true
     else
         CheckBox18.checked := false;

     if (savesen = 2) or (savespecies = 2) or
        (savesummary = 2) or (savesumsoln = 2) or (savebest = 2) or (saverun = 2) then
       Checkbox10.checked := true;
     if (savesen = 3) or (savespecies = 3) or
        (savesummary = 3) or (savesumsoln = 3) or (savebest = 3) or (saverun = 3) then
     begin
          Checkbox10.checked := true;
          Checkbox17.checked := true;
     end;

     Edit16.text := savename;

end;  { Load File }

function TInEditForm.compstr(str1,str2:string):boolean;
var
   i,compare:integer;
   test:boolean;
begin
    if length(str1) > length(str2) then
      compare := length(str2)
    else
        compare := length(str1);
    if (length(str1) = 0) or (length(str2) = 0) then
    begin
         compstr := false;
    end else begin
        test := true;
        i:= 1;
        repeat begin
        if str1[i] <> str2[i] then begin
           test := false;
           end;
        i := i + 1;
        end;
        until (not test) or (i>compare);
        compstr := test;
    end; {else}
    if test then
      Delete(str1,0,compare);
end;         {function Compstr}

procedure TInEditForm.ReadVar(var infile:text; variable:pointer);
{ reads a variable into value dependent on vartype }

begin

end; { Scan Variable }

procedure TInEditForm.FindVar(var varaddress;var filename:string;
          searchstr:string; vartype:integer; warn:boolean);
{ This procedure searches through infile to find a given variable label }
{ Variable Warn is true if a warning is to issued when variable no in file}
{ Vartype 1:integer;
          2:real;
          3:double;
          4:string}
var
  foundstr:string;
  infile:Textfile;
  foundit: boolean;
begin
     assignfile(infile,'input.dat');
     reset(infile);
      foundit := false;
      repeat
        readln(infile,foundstr);
        if compstr(foundstr,searchstr) then begin
        Delete(foundstr,1,length (searchstr));
            foundit := true;
        case vartype of
             1: integer(varaddress) := StrToInt(foundstr);
             2: real(varaddress) := RegionSafeStrToFloat(foundstr);
             3: double(varaddress) := RegionSafeStrToFloat(foundstr);
             4:tempstr :=string(trim(foundstr));  {Need to strip out spaces }
        end;
        end;

      until (eof(infile) or foundit);
      if (not foundit) and warn then
         ShowMessage('Could not find '+searchstr);
      closefile(infile);
end;  {Find Variable }

procedure TInEditForm.LoadFile2(sDirectory : string);
var
   filename:string;
   realpoint: ^real;
begin
     if (pos('input.dat',sDirectory)>0) then
     begin
          ineditdir := ExtractFilePath(sDirectory);
          SetCurrentDir(ineditdir);
          filename := ExtractFileName(sDirectory);
     end
     else
     begin
          ineditdir := sDirectory;
          filename := 'input.dat';
     end;
     
  FindVar(version,filename,'VERSION',3,false);
  FindVar(blm,filename,'BLM',3,true);
  FindVar(prop,filename,'PROP',3,true);
  FindVar(iterations,filename,'NUMITNS',1,true);
  FindVar(Tinit,filename,'STARTTEMP',3,true);
  FindVar(Tcool,filename,'COOLFAC',3,true);
  FindVar(Titns,filename,'NUMTEMP',1,true);
  FindVar(iseed,filename,'RANDSEED',1,false);
  FindVar(outbest,filename,'BESTSCORE',3,false);
  FindVar(repeats,filename,'NUMREPS',1,true);
  FindVar(costthresh,filename,'COSTTHRESH',3,true);
  FindVar(tpf1,filename,'THRESHPEN1',3,false);
  FindVar(tpf2,filename,'THRESHPEN2',3,false);
  FindVar(saverun,filename,'SAVERUN',1,true);
  FindVar(savebest,filename,'SAVEBEST',1,true);
  FindVar(savesummary,filename,'SAVESUMMARY',1,true);
  FindVar(savesen,filename,'SAVESCEN',1,true);
  FindVar(savespecies,filename,'SAVETARGMET',1,true);
  FindVar(savesumsoln,filename,'SAVESUMSOLN',1,true);
  FindVar(savesumsoln,filename,'SAVESUMSOLN',1,true);
  FindVar(savelog,filename,'SAVELOG',1,true);
  savename := tempstr;
  FindVar(indir,filename,'INPUTDIR',4,true);
  indir := tempstr;
  FindVar(outdir,filename,'OUTPUTDIR',4,true);
  outdir := tempstr;
  Findvar(specname,filename,'SPECNAME',4,true);
  specname := tempstr;
  FindVar(puname,filename,'PUNAME',4,true);
  puname := tempstr;
  FindVar(puvsprname,filename,'PUVSPRNAME',4,true);
  puvsprname := tempstr;
  tempstr := '';
  FindVar(boundaryname,filename,'BOUNDNAME',4,false);
  boundaryname := tempstr;
  tempstr := '';
  FindVar(blockdefname,filename,'BLOCKDEFNAME',4,false);
  blockdefname := tempstr;
  FindVar(runopts,filename,'RUNMODE',1,true);
  FindVar(misslevel,filename,'MISSLEVEL',3,true);
  FindVar(heurotype,filename,'HEURTYPE',1,true);
  FindVar(verbose,filename,'VERBOSITY',1,true);
  Edit3.text := RegionSafeFloatToStr(blm);  {Boundary Length }
  Edit8.text := RegionSafeFloatToStr(prop);
  Edit10.text := RegionSafeFloatToStr(outbest);
  if (outbest >= 0) then
    Checkbox14.checked := true;
  Edit10.enabled := Checkbox14.checked;
  
  Edit9.text := IntToStr(iseed);
  if (iseed < 0) then
    Edit9.enabled := false
  else
    checkbox9.checked := true;
  { Annealing Controls }
  Edit5.text := IntToStr(iterations);
  Edit4.text := RegionSafeFloatToStr(Tinit);
  Edit6.text := RegionSafeFloatToStr(Tcool);
  Edit2.text := IntToStr(Titns);
  Edit11.text := IntToStr(repeats);
  Edit13.text := RegionSafeFloatToStr(costthresh);
  Edit14.text := RegionSafeFloatToStr(tpf1);
  Edit1.text := RegionSafeFloatToStr(tpf2);
  if (costthresh > 0) then begin
     Checkbox3.checked := true;
     edit13.enabled := true;
     edit14.enabled := true;
     edit1.enabled := true;
  end else begin
     Checkbox3.checked := false;
     edit13.enabled := false;
     edit14.enabled := false;
     edit1.enabled := false;
  end;
  combobox2.itemindex := verbose;
  combobox3.itemindex := runopts;
  if (runopts  in [1,4]) then   {run options and Heuristic Options }
    combobox1.enabled := False
  else
    combobox1.enabled := True;
  combobox1.itemindex := heurotype;

  if (Tinit < 0) then begin
      Checkbox1.checked := true;
      CheckBox1Click(self);
  end;

  Edit17.text := indir;
  Edit18.text := outdir;
  Edit19.text := RegionSafeFloatToStr(misslevel);

  {Output Saving}
  if (SaveRun > 0) then
     CheckBox4.checked := true
  else
     CheckBox4.checked := false;
  if (SaveBest > 0) then
     CheckBox5.checked := true
  else
     CheckBox5.checked := false;
  if (SaveSummary > 0) then
     CheckBox6.checked := true
  else
     CheckBox6.checked := false;
  if (SaveSen > 0) then
     CheckBox7.checked := true
  else
     CheckBox7.checked := false;
  if (SaveSpecies > 0) then
     CheckBox8.checked := true
  else
     CheckBox8.checked := false;
  if (savesumsoln >0) then
    CheckBox11.checked := true
  else
    CheckBox11.checked := false;
  if (savesen = 2) or (savespecies = 2) or (savesumsoln = 2) or (savebest = 2) or (saverun = 2) then
    Checkbox10.checked := true;
  if (savesen = 3) or (savespecies = 3) or
     (savesummary = 3) or (savesumsoln = 3) or (savebest = 3) or (saverun = 3) then
  begin
       Checkbox10.checked := true;
       Checkbox17.checked := true;
  end;
  Edit16.text := savename;

  {New filename loading into editboxes}
  Edit12.text := specname;
  Edit15.text := puname;
  Edit20.text := puvsprname;
  Edit21.text := blockdefname;
  if length(blockdefname) < 1 then
      edit21.enabled := false
 else
      edit21.enabled := true;
 checkbox12.checked := edit21.enabled;
  Edit22.text := boundaryname;
  if length(boundaryname) < 1 then
     edit22.enabled := false
 else
     edit22.enabled := true;
 checkbox13.checked := edit22.enabled;

end;  { Load File style 2 }

procedure TInEditForm.SaveFile;
var
   inf: TextFile;
   filename:string;
   outformat:integer;
begin
if (CheckChoice) then begin
  blm := RegionSafeStrToFloat(Edit3.text);  {Boundary Length }
  prop := RegionSafeStrToFloat(Edit8.text);    {Hard wired for simplicity}
  misslevel := RegionSafeStrToFloat(Edit19.text);
  { Working out Output Options}
  if (Checkbox10.checked) then
    outformat := 2
  else
    outformat := 1;

  if CheckBox17.checked then
     outformat := 3;
     // allows output CSV file format (value of 3)
  if (Checkbox4.checked) then
     SaveRun := outformat
  else
     SaveRun := 0;
  if (Checkbox5.checked) then
     SaveBest := outformat
  else
      SaveBest := 0;
  if (Checkbox6.checked) then
     SaveSummary := outformat
  else
      SaveSummary := 0;
  if (Checkbox7.checked) then
     SaveSen := outformat
  else
      SaveSen := 0;
  if (Checkbox8.checked) then
     SaveSpecies := outformat
  else
      SaveSpecies := 0;
  if (Checkbox11.checked) then
    savesumsoln := outformat
  else
    savesumsoln := 0;

  SaveName := Edit16.text;

  { Annealing Controls }
  iterations := StrToInt(Edit5.text);
  Tinit := RegionSafeStrToFloat(Edit4.text);
  Tcool := RegionSafeStrToFloat(Edit6.text);
  Titns := StrToInt(Edit2.text);
  iseed := StrToInt(Edit9.text);
  outbest := RegionSafeStrToFloat(Edit10.text);
  repeats := StrToInt(Edit11.text);
  verbose := combobox2.itemindex;
  runopts := combobox3.itemindex;
  heurotype := combobox1.itemindex;
  indir := Edit17.text;
  if (length(indir) < 1) then
    indir := '0';
  outdir := Edit18.text;
  if (length(outdir)<1) then
     outdir := '0';

  filename := 'input.dat';
  SetCurrentDir(ineditdir);
  assignfile(inf,filename);
  rewrite(inf);
       writeln(inf,'3.1');
       writeln(inf,blm);
       writeln(inf,prop);
       writeln(inf,iterations);
       writeln(inf,Tinit);
       writeln(inf,Tcool);
       writeln(inf,Titns);
       writeln(inf,iseed);
       writeln(inf,outbest);
       writeln(inf,repeats);
       writeln(inf,RegionSafeStrToFloat(Edit13.text)); {Cost Threshold}
       writeln(inf,RegionSafeStrToFloat(Edit14.text)); {CTF A}
       writeln(inf,RegionSafeStrToFloat(Edit1.text)); {CTF B}
       writeln(inf,saverun);
       writeln(inf,savebest);
       writeln(inf,savesummary);
       writeln(inf,savesen);
       writeln(inf,savespecies);
       writeln(inf,savesumsoln);
       writeln(inf,savename);
       writeln(inf,indir);
       writeln(inf,outdir);
       writeln(inf,runopts);
       writeln(inf,misslevel);
       writeln(inf,heurotype);
       writeln(inf,verbose);
  closefile(inf);
  end;
end;


procedure TInEditForm.SaveFile2;
var
   inf: TextFile;
   filename:string;
   outformat:integer;
begin
if (CheckChoice) then begin
  blm := RegionSafeStrToFloat(Edit3.text);  {Boundary Length }
  prop := RegionSafeStrToFloat(Edit8.text);    {Hard wired for simplicity}
  misslevel := RegionSafeStrToFloat(Edit19.text);
  { Working out Output Options}
  if (Checkbox10.checked) then
    outformat := 2
  else
    outformat := 1;
  if (Checkbox4.checked) then
     SaveRun := outformat
  else
     SaveRun := 0;
  if (Checkbox5.checked) then
     SaveBest := outformat
  else
      SaveBest := 0;
  if (Checkbox6.checked) then
     SaveSummary := outformat
  else
      SaveSummary := 0;
  if (Checkbox7.checked) then
     SaveSen := outformat
  else
      SaveSen := 0;
  if (Checkbox8.checked) then
     SaveSpecies := outformat
  else
      SaveSpecies := 0;
  if (Checkbox11.checked) then
    savesumsoln := outformat
  else
    savesumsoln := 0;

  if CheckBox18.Checked then
     savelog := outformat
  else
      savelog := 0;

  SaveName := Edit16.text;

  { Annealing Controls }
  iterations := StrToInt(Edit5.text);
  Tinit := RegionSafeStrToFloat(Edit4.text);
  Tcool := RegionSafeStrToFloat(Edit6.text);
  Titns := StrToInt(Edit2.text);
  iseed := StrToInt(Edit9.text);
  outbest := RegionSafeStrToFloat(Edit10.text);
  repeats := StrToInt(Edit11.text);
  verbose := combobox2.itemindex;
  runopts := combobox3.itemindex;
  heurotype := combobox1.itemindex;
  indir := Edit17.text;
  if (length(indir) < 1) then
    indir := '0';
  outdir := Edit18.text;
  if (length(outdir)<1) then
     outdir := '0';
  specname := Edit12.text;
  if (length(specname) < 1) then
     specname := 'spec.dat';
  puname := Edit15.text;
  if (length(puname) < 1) then
     puname := 'PU.dat';
  puvsprname := Edit20.text;
  if (length(puvsprname) < 1) then
     puvsprname := 'puvspr2.dat';
  boundaryname := Edit22.text;
  if (length(boundaryname) < 1) then
     boundaryname := 'boundary.dat';
  blockdefname := Edit21.text;
  if (length(blockdefname) < 1) then
    blockdefname := 'gspec.dat';

  filename := 'input.dat';
  SetCurrentDir(ineditdir);
  assignfile(inf,filename);
  rewrite(inf);
       writeln(inf,'Input file for Annealing program.');
       writeln(inf);
       writeln(inf,'This file generated by Zonae Cogito.');
       writeln(inf,'written by Matthew Watts');
       writeln(inf,'m.watts@uq.edu.au');
       writeln(inf);
       writeln(inf,'General Parameters');
       writeln(inf,'VERSION 0.1');
       writeln(inf,'BLM ', blm);
       writeln(inf,'PROP ',prop);
       writeln(inf,'RANDSEED ',iseed);
       writeln(inf,'BESTSCORE ',outbest);
       writeln(inf,'NUMREPS ',repeats);
       writeln(inf);writeln(inf,'Annealing Parameters');
       writeln(inf,'NUMITNS ',iterations);
       writeln(inf,'STARTTEMP ',Tinit);
       writeln(inf,'COOLFAC ',Tcool);
       writeln(inf,'NUMTEMP ',Titns);
       writeln(inf);writeln(inf,'Cost Threshold');
       writeln(inf,'COSTTHRESH ',RegionSafeStrToFloat(Edit13.text)); {Cost Threshold}
       writeln(inf,'THRESHPEN1 ',RegionSafeStrToFloat(Edit14.text)); {CTF A}
       writeln(inf,'THRESHPEN2 ',RegionSafeStrToFloat(Edit1.text)); {CTF B}
       writeln(inf);writeln(inf,'Input Files');
       writeln(inf,'INPUTDIR ',indir);
       writeln(inf,'SPECNAME ',specname);
       writeln(inf,'PUNAME ',puname);
       writeln(inf,'PUVSPRNAME ',puvsprname);
       if checkbox13.checked then
              writeln(inf,'BOUNDNAME ',boundaryname);
       if checkbox12.checked then
              writeln(inf,'BLOCKDEFNAME ',blockdefname);
       writeln(inf);writeln(inf,'Save Files');
       writeln(inf,'SCENNAME ',savename);
       writeln(inf,'SAVERUN ',saverun);
       writeln(inf,'SAVEBEST ',savebest);
       writeln(inf,'SAVESUMMARY ',savesummary);
       writeln(inf,'SAVESCEN ',savesen);
       writeln(inf,'SAVETARGMET ',savespecies);
       writeln(inf,'SAVESUMSOLN ',savesumsoln);
       writeln(inf,'SAVELOG ',savelog);
       writeln(inf,'OUTPUTDIR ',outdir);
       writeln(inf);writeln(inf,'Program control.');
       writeln(inf,'RUNMODE ',runopts);
       writeln(inf,'MISSLEVEL ',misslevel);
       writeln(inf,'HEURTYPE ',heurotype);
       writeln(inf,'VERBOSITY ',verbose);
  closefile(inf);
  end;
end;   {SaveFile 2}


procedure TInEditForm.btnLoadClick(Sender: TObject);
var
   sDirectory : string;
begin
     if (ParamCount = 0) then
        sDirectory := GetCurrentDir
     else
         sDirectory := ExtractFilePath(ParamStr(1));

     if (Radiogroup1.itemindex = 0) then
        LoadFile(sDirectory)
     else
         LoadFile2(sDirectory);

     btnSave.enabled := false;
end;

procedure TInEditForm.btnSaveClick(Sender: TObject);
begin
     if (Radiogroup1.itemindex = 0) then
       SaveFile
     else
       SaveFile2;
  btnSave.enabled := false;
end;

procedure TInEditForm.NumbersChanged;
begin
     btnSave.enabled := true;
end;

procedure TInEditForm.Edit6Change(Sender: TObject);
begin
  if (RegionSafeStrToFloat(edit6.text) >=0) and (RegionSafeStrToFloat(edit4.text) > 0) then
  label16.caption := RegionSafeFloatToStr(RegionSafeStrToFloat(edit4.text) *
                  power(RegionSafeStrToFloat(edit6.text),Strtoint(edit2.text)));
  NumbersChanged;
end;

procedure TInEditForm.Edit1Change(Sender: TObject);
begin
  NumbersChanged;
end;

procedure TInEditForm.btnExitClick(Sender: TObject);
begin
  if (btnSave.enabled) then
    begin
      if (Messagedlg('Exit without saving changes?',mtConfirmation,
         [mbYes,mbNo],0) = mrYes)then
           close;
    end
    else
        close;
end;

procedure TInEditForm.ComboBox4Change(Sender: TObject);
begin
  NumbersChanged;
end;

procedure TInEditForm.CheckBox3Click(Sender: TObject);
begin
  Edit13.enabled := CheckBox3.checked;
  if (not CheckBox3.checked) then
     Edit13.text := '0';
  Edit14.enabled := CheckBox3.checked;
  Edit1.enabled := CheckBox3.checked;
  
end;

procedure TInEditForm.ComboBox3Change(Sender: TObject);
begin
      numberschanged;
      if (combobox3.itemindex in [1,4]) then
        combobox1.enabled := False
      else
        combobox1.enabled := True;
      {if (combobox3.itemindex <1) then begin
        Edit5.enabled := true;
        label5.enabled := true;
      end else begin
        Edit5.enabled := false;
        label5.enabled := true;
      end;               }
end;

procedure TInEditForm.btnBrowseInputClick(Sender: TObject);
begin
  if (DirectoryExists(Edit17.text)) then  begin
    InEditBrowseForm.DirectoryListBox1.Directory := Edit17.text;
  end;
  InEditBrowseForm.mode := 1;
  InEditBrowseForm.showmodal;
end;

procedure TInEditForm.btnBrowseOutputClick(Sender: TObject);
begin
  if (DirectoryExists(Edit18.text)) then
    InEditBrowseForm.DirectoryListBox1.Directory := Edit18.text;
  InEditBrowseForm.mode := 2;
  InEditBrowseForm.showmodal;
end;

procedure TInEditForm.CheckBox1Click(Sender: TObject);
begin
  edit4.enabled := Not(checkbox1.checked);
  edit6.enabled := Not(checkbox1.checked);
  edit7.enabled := Not(checkbox1.checked);
  Checkbox2.enabled := Not(checkbox1.checked);
  if (Checkbox1.checked) then begin
      label16.caption := 'adaptive annealing';
      edit4.text := '-1';
  end else begin
      label16.caption := 'compute final an set things up ';
      edit4.text := '1';
      Checkbox2click(self);
  end;
end;

procedure TInEditForm.CheckBox2Click(Sender: TObject);
begin
  Edit7.enabled := checkbox2.checked;
  edit6.enabled := not(checkbox2.checked);
  if (checkbox2.checked) then
     edit7.text := label16.caption;
end;

procedure TInEditForm.Edit7Change(Sender: TObject);
begin
  if (length(edit7.text)> 0) then
    if (RegionSafeStrToFloat(edit7.text) > 0) then
      Edit6.text := RegionSafeFloatToStr(power(RegionSafeStrToFloat(edit7.text)/
              RegionSafeStrToFloat(edit4.text)
              ,1/RegionSafeStrToFloat(edit2.text)));
end;

procedure TInEditForm.Edit2Change(Sender: TObject);
begin
   if (CheckBox2.Checked) then
      Edit7Change(self)
   else
      Edit6Change(self);
end;

procedure TInEditForm.CheckBox9Click(Sender: TObject);
begin
  Edit9.enabled := checkbox9.checked;
  if (not(checkbox9.checked)) then
    Edit9.text := '-1';
end;

procedure TInEditForm.CheckBox12Click(Sender: TObject);
begin
  Edit21.enabled := checkbox12.checked;
  NumbersChanged;
end;

procedure TInEditForm.CheckBox13Click(Sender: TObject);
begin
  Edit22.enabled := checkbox13.checked;
  NumbersChanged;
end;

procedure TInEditForm.CheckBox14Click(Sender: TObject);
begin
   Edit10.enabled := CheckBox14.checked;
   Numberschanged;
   if not (checkbox14.checked) then
      Edit10.text := '-1';
end;







procedure TInEditForm.CheckBox17Click(Sender: TObject);
begin
     NumbersChanged;
     if CheckBox17.Checked then
        CheckBox10.Checked := True;
end;

procedure TInEditForm.CheckBox18Click(Sender: TObject);
begin
     NumbersChanged;
end;

end.
