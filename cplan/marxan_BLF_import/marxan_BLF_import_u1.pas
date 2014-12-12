unit marxan_BLF_import_u1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    EditBLF: TEdit;
    BrowseBLF: TButton;
    Label2: TLabel;
    EditCPlanSiteTable: TEdit;
    BrowseSite: TButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    procedure BrowseBLFClick(Sender: TObject);
    procedure BrowseSiteClick(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure ConvertBLF;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.BrowseBLFClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
        EditBLF.Text := OpenDialog1.Filename;
end;

procedure TForm1.BrowseSiteClick(Sender: TObject);
begin
     if OpenDialog2.Execute then
        EditCPlanSiteTable.Text := OpenDialog2.Filename;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
     Application.Terminate;
end;

function GetDelimitedAsciiElement(const sLine : string;
                                  const sDelimiter : string;
                                  const iColumn : integer) : string;
// returns the element at 1-based-index column iColumn
// returns blank string if the column does not exist in sLine
var
   sTrimLine : string;
   iPos, iTrim, iCount : integer;
begin
     Result := '';

     sTrimLine := sLine;
     iTrim := iColumn-1;
     if (iTrim > 0) then
        for iCount := 1 to iTrim do // trim the required number of columns from the start of the string
        begin
             iPos := Pos(sDelimiter,sTrimLine);
             sTrimLine := Copy(sTrimLine,iPos+1,Length(sTrimLine)-iPos);
        end;
     iPos := Pos(sDelimiter,sTrimLine);
     if (iPos = 1) then
     begin
          // there is a delimiter at the start of the line we must trim first
          sTrimLine := Copy(sTrimLine,2,Length(sTrimLine)-1);
          //sLine := sTrimLine;
          iPos := Pos(sDelimiter,sTrimLine);
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;
     end
     else
     begin
          //sLine := sTrimLine;
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;
     end;
end;

procedure TForm1.ConvertBLF;
var
   OutFile, BLF, CPlanSites : TextFile;
   iCPlanSites, iSiteName, iSiteKey, iID1, iID2, iSubstituteID1, iSubstituteID2 : integer;
   rBoundary : extended;
   SiteNames : Array[1..100000] of integer;
   SiteKeys : Array[1..100000] of integer;
   sLine : string;

   function substitute_ID(const iOriginalID : integer) : integer;
   var
      iCount : integer;
   begin
        Result := -1;
        for iCount := 1 to iCPlanSites do
            if (SiteNames[iCount] = iOriginalID) then
               Result := SiteKeys[iCount];
   end;
   
begin
     // read the site keys and site names from the site table
     assignfile(CPlanSites,EditCPlanSiteTable.Text);
     reset(CPlanSites);
     readln(CPlanSites);
     iCPlanSites := 0;
     repeat
           readln(CPlanSites,sLine);

           iSiteName := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
           iSiteKey := StrToInt(GetDelimitedAsciiElement(sLine,',',2));

           Inc(iCPlanSites);
           SiteNames[iCPlanSites] := iSiteName;
           SiteKeys[iCPlanSites] := iSiteKey;

     until Eof(CPlanSites);
     closefile(CPlanSites);

     // parse the blf file
     assignfile(BLF,EditBLF.Text);
     reset(BLF);
     readln(BLF,sLine);
     assignfile(OutFile,ExtractFilePath(EditBLF.Text) + 'outBLF.csv');
     rewrite(OutFile);
     writeln(OutFile,'id1,id2,boundary');
     repeat
           readln(BLF,sLine);

           iId1 := StrToInt(GetDelimitedAsciiElement(sLine,',',1));
           iId2 := StrToInt(GetDelimitedAsciiElement(sLine,',',2));
           rBoundary := StrToFloat(GetDelimitedAsciiElement(sLine,',',3));
           //   match id to site name
           //   substitute corresponding site key for id
           iSubstituteID1 := substitute_ID(iID1);
           iSubstituteID2 := substitute_ID(iID2);

           writeln(OutFile,IntToStr(iSubstituteID1) + ',' + IntToStr(iSubstituteID2) + ',' + FloatToStr(rBoundary));

     until Eof(BLF);
     closefile(BLF);
     closefile(OutFile);
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
     ConvertBLF;
     Application.Terminate;
end;

end.
