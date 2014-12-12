unit mask_pu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls;

type
  TMaskPuForm = class(TForm)
    Label1: TLabel;
    ComboPUTable: TComboBox;
    Label2: TLabel;
    EditMarxanMatrix: TEdit;
    ButtonBrowse: TButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure ButtonBrowseClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MaskPuForm: TMaskPuForm;

implementation

uses MAIN, Childwin, CombineRegions;

{$R *.DFM}

procedure TMaskPuForm.FormCreate(Sender: TObject);
var
   iCount : integer;
   aChild : TMDIChild;
begin
     try
        ComboPUTable.items.clear;

        if (SCPForm.MDIChildCount > 0) then
        begin
             for iCount := 0 to (SCPForm.MDIChildCount - 1) do
             begin
                  aChild := TMDIChild(SCPForm.MDIChildren[iCount]);

                  if (aChild.CheckLoadFileData.Checked) then
                  begin
                       ComboPUTable.items.add(aChild.Caption);
                  end;
             end;
        end;

        ComboPUTable.Text := ComboPUTable.Items.Strings[0];

     except
           MessageDlg('Exception in MaskPUForm FormCreate',mtError,[mbOk],0);
     end;
end;

procedure TMaskPuForm.ButtonBrowseClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
        EditMarxanMatrix.Text := OpenDialog1.Filename;
end;

procedure LoadMarxanMatrixMaskPU(const sFilename, sMask : string);
var
   InputFile : TextFile;
   iMaxFeature,iMinSite,iMaxSite, iValue, iCount, iPUID, iSPID, iSPindex, iPUindex : integer;
   sLine : string;
   i_I, i_J, iStartingFeatureIndex : integer;
   RowChild, SaveChild, DestinationChild : TMDIChild;
   sValue, sInputString : string;
   rValue : extended;
   fHeaderRow, fConvertM2ToHa : boolean;

   function BinarySearchRow(iSearchKey : integer) : integer;
   // assumes row id is integer and is sorted as integer
   var
      high, j, low : integer;
   begin
        low := 1;
        high := RowChild.aGrid.RowCount-1;

        while high-low > 1 do
        begin
             j := (high+low) div 2;
             if iSearchKey <= StrToInt(RowChild.aGrid.Cells[0,j]) then
                high := j
             else
                 low := j
        end;

        if StrToInt(RowChild.aGrid.Cells[0,high]) = iSearchKey then
           Result := high {*** found(r[high]) ***}
        else
        begin
              if StrToInt(RowChild.aGrid.Cells[0,low]) = iSearchKey then
                 Result := low {*** found(r[low]) ***}
              else
                  Result := -1; {*** notfound(key) ***}
        end;
   end;

begin
     // get a handle on table with PU Mask
     RowChild := TMDIChild(SCPForm.rtnChild(sMask));

     // parse matrix filename and find max and min sitekey, max featkey
     assignfile(InputFile,sFilename);
     reset(InputFile);
     readln(InputFile);

     iMaxFeature := 0;
     iMinSite := 1000000;
     iMaxSite := 0;

     repeat
           readln(InputFile,sLine);

           // species,pu,amount
           iValue := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
           if (iValue > iMaxFeature) then
              iMaxFeature := iValue;

           iValue := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
           if (BinarySearchRow(iValue) > -1) then
           begin
                if (iValue > iMaxSite) then
                   iMaxSite := iValue;
                if (iValue < iMinSite) then
                   iMinSite := iValue;
           end;

     until Eof(InputFile);
     closefile(InputFile);

     // create destination child
     SCPForm.CreateMDIChild('load marxan',False,False);
     DestinationChild := SCPForm.rtnChild('load marxan');
     with DestinationChild.aGrid do
     begin
          RowCount := iMaxSite - iMinSite + 2;
          ColCount := iMaxFeature + 1;
          Cells[0,0] := 'marxan';
          for iCount := 1 to RowCount do
              Cells[0,iCount] := IntToStr(iMinSite + iCount - 1);
          for iCount := 1 to ColCount do
              Cells[iCount,0] := IntToStr(iCount);
     end;

     // parse matrix file, writing each row as an element in the destination child
     reset(InputFile);
     readln(InputFile);
     repeat
           readln(InputFile,sLine);

           // species,pu,amount
           iPUID := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
           if (BinarySearchRow(iPUID) > -1) then
           begin
                iSPID := StrToInt(GetDelimitedAsciiElement(sLine,',',1));

                iSPindex := iSPID;
                iPUindex := 1 + iPUID - iMinSite;

                DestinationChild.aGrid.Cells[iSPindex,iPUindex] := GetDelimitedAsciiElement(sLine,',',3);
           end;

     until Eof(InputFile);
     closefile(InputFile);
end;

procedure TMaskPuForm.BitBtn1Click(Sender: TObject);
begin
     LoadMarxanMatrixMaskPU(EditMarxanMatrix.Text,ComboPUTable.Text);
end;

end.
