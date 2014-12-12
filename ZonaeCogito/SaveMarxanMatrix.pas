unit SaveMarxanMatrix;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls;

type
  TSaveMarxanMatrixForm = class(TForm)
    Label1: TLabel;
    EditOutFile: TEdit;
    btnBrowse: TButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    SaveDialog1: TSaveDialog;
    CheckHeader: TCheckBox;
    Label2: TLabel;
    EditStartingFeatureIndex: TEdit;
    CheckConvertM2: TCheckBox;
    RadioSaveType: TRadioGroup;
    CheckAppend: TCheckBox;
    procedure BitBtn1Click(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure CheckAppendClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SaveMarxanMatrixForm: TSaveMarxanMatrixForm;

implementation

uses SCP_Main, CSV_Child, ds;

{$R *.DFM}

procedure SaveMarxanMatrix_(const sFilename : string;
                            const sStartingFeatureIndex : string;
                            const fHeaderRow, fConvertM2ToHa, fAppendOutput : boolean;
                            const iSaveType : integer);
var
   OutFile : TextFile;
   i_I, i_J, iStartingFeatureIndex : integer;
   SaveChild : TCSVChild;
   sValue, sInputString : string;
   rValue : extended;
   fAppend : boolean;
   iSpeciesFrequency : integer;
   SpeciesFrequency : Array_t;
begin
     SaveChild := TCSVChild(SCPForm.ActiveMDIChild);

     fAppend := False;
     if fAppendOutput
     and fileexists(sFilename) then
         fAppend := True;

     assignfile(OutFile,sFilename);
     if fAppend then
        append(OutFile)
     else
         rewrite(OutFile);

     try
        iStartingFeatureIndex := StrToInt(sStartingFeatureIndex);
     except
           iStartingFeatureIndex := 0;
     end;

     if fHeaderRow then
        writeln(OutFile,'species,pu,amount');

     SpeciesFrequency := Array_t.Create;
     SpeciesFrequency.init(SizeOf(integer),SaveChild.aGrid.ColCount-1);
     iSpeciesFrequency := 0;
     for i_J := 1 to SpeciesFrequency.lMaxSize do
        SpeciesFrequency.setValue(i_J,@iSpeciesFrequency);

     if (iSaveType = 0) then
     begin // Planning Units order
          for i_I := 1 to (SaveChild.aGrid.RowCount-1) do
              for i_J := 1 to (SaveChild.aGrid.ColCount-1) do
              begin
                   sValue := SaveChild.aGrid.Cells[i_J,i_I];

                   if (sValue <> '') then
                   begin
                        rValue := StrToFloat(sValue);

                        if (rValue > 0) then
                        begin
                             SpeciesFrequency.rtnValue(i_J,@iSpeciesFrequency);
                             Inc(iSpeciesFrequency);
                             SpeciesFrequency.setValue(i_J,@iSpeciesFrequency);

                             if fConvertM2ToHa then
                                rValue := rValue / 10000;

                             writeln(OutFile,IntToStr(i_J + iStartingFeatureIndex) + ',' + SaveChild.aGrid.Cells[0,i_I] + ',' + FloatToStr(rValue));
                        end;
                   end;
              end;
     end
     else
     begin // Features order
          for i_J := 1 to (SaveChild.aGrid.ColCount-1) do
              for i_I := 1 to (SaveChild.aGrid.RowCount-1) do
              begin
                   sValue := SaveChild.aGrid.Cells[i_J,i_I];

                   if (sValue <> '') then
                   begin
                        rValue := StrToFloat(sValue);

                        if (rValue > 0) then
                        begin
                             SpeciesFrequency.rtnValue(i_J,@iSpeciesFrequency);
                             Inc(iSpeciesFrequency);
                             SpeciesFrequency.setValue(i_J,@iSpeciesFrequency);

                             if fConvertM2ToHa then
                                rValue := rValue / 10000;

                             writeln(OutFile,IntToStr(i_J + iStartingFeatureIndex) + ',' + SaveChild.aGrid.Cells[0,i_I] + ',' + FloatToStr(rValue));
                        end;
                   end;
              end;
     end;

     closefile(OutFile);

     assignfile(OutFile,ExtractFilePath(sFilename) + 'speciesid_' + ExtractFileName(sFilename));
     if fAppendOutput
     and fileexists(ExtractFilePath(sFilename) + 'speciesid_' + ExtractFileName(sFilename)) then
         append(OutFile)
     else
     begin
          rewrite(OutFile);
          if fHeaderRow then
             writeln(OutFile,'featureid,featurename,frequency');
     end;
     for i_J := 1 to (SaveChild.aGrid.ColCount-1) do
     begin
          SpeciesFrequency.rtnValue(i_J,@iSpeciesFrequency);
          writeln(OutFile,IntToStr(i_J + iStartingFeatureIndex) + ',' + SaveChild.aGrid.Cells[i_J,0] + ',' + IntToStr(iSpeciesFrequency));
     end;
     closefile(OutFile);

     SpeciesFrequency.Destroy;

     MessageDlg('Last feature index used was ' + IntToStr(SaveChild.aGrid.ColCount-1+iStartingFeatureIndex) +
                '. Use ' + IntToStr(SaveChild.aGrid.ColCount-1+iStartingFeatureIndex) + ' as number to add to starting index for next marxan matrix.',mtConfirmation,[mbOk],0)
end;

procedure TSaveMarxanMatrixForm.BitBtn1Click(Sender: TObject);
begin
     SaveMarxanMatrix_(EditOutFile.Text,
                       EditStartingFeatureIndex.Text,
                       CheckHeader.Checked,
                       CheckConvertM2.Checked,
                       CheckAppend.Checked,
                       RadioSaveType.ItemIndex);
end;

procedure TSaveMarxanMatrixForm.btnBrowseClick(Sender: TObject);
begin
     if (SaveDialog1.Execute) then
        EditOutFile.Text := SaveDialog1.Filename;
end;

procedure TSaveMarxanMatrixForm.CheckAppendClick(Sender: TObject);
begin
     CheckHeader.Enabled := not CheckAppend.Checked;
end;

end.
