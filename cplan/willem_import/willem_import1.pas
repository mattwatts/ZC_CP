unit willem_import1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls;

type
  TForm1 = class(TForm)
    EditInMatrix: TEdit;
    Label1: TLabel;
    btnLocate: TButton;
    BitBtnConvert: TBitBtn;
    BitBtnExit: TBitBtn;
    OpenDialog1: TOpenDialog;
    ComboSite: TComboBox;
    Label2: TLabel;
    ComboFeature: TComboBox;
    ComboValue: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    FeatureList: TListBox;
    BitBtnFastConvert: TBitBtn;
    procedure btnLocateClick(Sender: TObject);
    procedure BitBtnExitClick(Sender: TObject);
    procedure BitBtnConvertClick(Sender: TObject);
    procedure ReadFieldNames(const sFilename : string);
    procedure ReadMatrix(const sFilename : string;
                         const iSiteField, iFeatureField, iValueField : integer);
    procedure FastReadMatrix(const sFilename : string;
                             const iSiteField, iFeatureField, iValueField : integer);
    procedure BitBtnFastConvertClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

    KeyFile_T = record
                  iSiteKey : integer;
                  iRichness : word;
                end;
    SingleValueFile_T = record
                    iFeatKey : word;
                    rAmount : single;
                  end;


var
  Form1: TForm1;

implementation

{$R *.DFM}

function CountCommas(const sLine : string) : integer;
var
   iCount : integer;
begin
     Result := 0;
     for iCount := 1 to Length(sLine) do
         if (sLine[iCount] = ',') then
            Inc(Result);
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

procedure ConvertHeaderlessCSV2Mtx(const sCSVFileName : string);
var
   iSite, iFeature, iElements, iElement : integer;
   InFile, SummaryFile : TextFile;
   sLine : string;
   Key : KeyFile_T;
   Value : SingleValueFile_T;
   ValueFile, KeyFile : file;
   sElement : string;
   rElement : single;

   procedure ParseLine;
   var
      iCount, iPos : integer;

      procedure ProcessElement;
      begin
           try
              rElement := StrToFloat(sElement);
           except
                 rElement := 0;
           end;
           if (rElement > 0) then
           begin
                Inc(Key.iRichness);
                Value.iFeatKey := iFeature;
                Value.rAmount := rElement;
                BlockWrite(ValueFile,Value,SizeOf(Value));
           end;
      end;

   begin
        iFeature := 0;
        iElement := 0;
        repeat
              Inc(iElement);
              Inc(iFeature);
              iPos := Pos(',',sLine);
              if (iPos = 0) then // comma does not exist
              begin
                   sElement := sLine;
                   sLine := '';
              end
              else
              if (iPos = 1) then // comma is first element
              begin
                   sElement := '';
                   sLine := Copy(sLine,2,Length(sLine)-1);
              end
              else
              begin
                   sElement := Copy(sLine,1,iPos-1);
                   sLine := Copy(sLine,iPos+1,Length(sLine)-iPos);
              end;
              ProcessElement;
        until (iElement >= iElements);
   end;

begin
     try
        Screen.Cursor := crHourglass;

        // count column totals and site and feature count on the way through
        assignfile(InFile,sCSVFileName);
        reset(InFile);

        assignfile(ValueFile,ExtractFilePath(sCSVFileName) + '\matrix.mtx');
        rewrite(ValueFile,1);
        assignfile(KeyFile,ExtractFilePath(sCSVFileName) + '\matrix.key');
        rewrite(KeyFile,1);

        iSite := 0;
        repeat
              Inc(iSite);
              readln(InFile,sLine);
              if (iSite = 1) then
                 iElements := CountCommas(sLine) + 1;

              Key.iSiteKey := iSite;
              Key.iRichness := 0;

              ParseLine;

              BlockWrite(KeyFile,Key,SizeOf(Key));

              Form1.Caption := IntToStr(iSite);

        until Eof(InFile);

        closefile(InFile);
        closefile(ValueFile);
        closefile(KeyFile);

        assignfile(SummaryFile,ExtractFilePath(sCSVFileName) + '\summary.txt');
        rewrite(SummaryFile);
        writeln(SummaryFile,'sites:' + IntToStr(iSite) + '   elements:' + IntToStr(iElements));
        closefile(SummaryFile);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ConvertHeaderlessCSV2Mtx',mtInformation,[mbOk],0);
     end;
end;

procedure Convert4HeaderlessCSV2Mtx(const sCSVFileName1,sCSVFileName2,sCSVFileName3,sCSVFileName4 : string);
var
   iSite, iFeature, iElements, iElement : integer;
   InFile, SummaryFile : TextFile;
   sLine : string;
   Key : KeyFile_T;
   Value : SingleValueFile_T;
   ValueFile, KeyFile : file;
   sElement : string;
   rElement : single;

   procedure ParseLine;
   var
      iCount, iPos : integer;

      procedure ProcessElement;
      begin
           try
              rElement := StrToFloat(sElement);
           except
                 rElement := 0;
           end;
           if (rElement > 0) then
           begin
                Inc(Key.iRichness);
                Value.iFeatKey := iFeature;
                Value.rAmount := rElement;
                BlockWrite(ValueFile,Value,SizeOf(Value));
           end;
      end;

   begin
        iFeature := 0;
        iElement := 0;
        repeat
              Inc(iElement);
              Inc(iFeature);
              iPos := Pos(',',sLine);
              if (iPos = 0) then // comma does not exist
              begin
                   sElement := sLine;
                   sLine := '';
              end
              else
              if (iPos = 1) then // comma is first element
              begin
                   sElement := '';
                   sLine := Copy(sLine,2,Length(sLine)-1);
              end
              else
              begin
                   sElement := Copy(sLine,1,iPos-1);
                   sLine := Copy(sLine,iPos+1,Length(sLine)-iPos);
              end;
              ProcessElement;
        until (iElement >= iElements);
   end;

begin
     try
        Screen.Cursor := crHourglass;

        // count column totals and site and feature count on the way through

        assignfile(ValueFile,ExtractFilePath(sCSVFileName1) + '\matrix.mtx');
        rewrite(ValueFile,1);
        assignfile(KeyFile,ExtractFilePath(sCSVFileName1) + '\matrix.key');
        rewrite(KeyFile,1);
        iSite := 0;

        assignfile(InFile,sCSVFileName1);
        reset(InFile);
        repeat
              Inc(iSite);
              readln(InFile,sLine);
              if (iSite = 1) then
                 iElements := CountCommas(sLine) + 1;

              Key.iSiteKey := iSite;
              Key.iRichness := 0;

              ParseLine;

              BlockWrite(KeyFile,Key,SizeOf(Key));

              Form1.Caption := IntToStr(iSite);

        until Eof(InFile);
        closefile(InFile);

        assignfile(InFile,sCSVFileName2);
        reset(InFile);
        repeat
              Inc(iSite);
              readln(InFile,sLine);

              Key.iSiteKey := iSite;
              Key.iRichness := 0;

              ParseLine;

              BlockWrite(KeyFile,Key,SizeOf(Key));

              Form1.Caption := IntToStr(iSite);

        until Eof(InFile);
        closefile(InFile);

        assignfile(InFile,sCSVFileName3);
        reset(InFile);
        repeat
              Inc(iSite);
              readln(InFile,sLine);

              Key.iSiteKey := iSite;
              Key.iRichness := 0;

              ParseLine;

              BlockWrite(KeyFile,Key,SizeOf(Key));

              Form1.Caption := IntToStr(iSite);

        until Eof(InFile);
        closefile(InFile);

        assignfile(InFile,sCSVFileName4);
        reset(InFile);
        repeat
              Inc(iSite);
              readln(InFile,sLine);

              Key.iSiteKey := iSite;
              Key.iRichness := 0;

              ParseLine;

              BlockWrite(KeyFile,Key,SizeOf(Key));

              Form1.Caption := IntToStr(iSite);

        until Eof(InFile);
        closefile(InFile);

        closefile(ValueFile);
        closefile(KeyFile);

        assignfile(SummaryFile,ExtractFilePath(sCSVFileName1) + '\summary.txt');
        rewrite(SummaryFile);
        writeln(SummaryFile,'sites:' + IntToStr(iSite) + '   elements:' + IntToStr(iElements));
        closefile(SummaryFile);

        Screen.Cursor := crDefault;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Convert4HeaderlessCSV2Mtx',mtInformation,[mbOk],0);
     end;
end;

procedure TForm1.ReadFieldNames(const sFilename : string);
var
   InFile : TextFile;
   sLine, sElement : string;
   iElements, iCount : integer;
begin
     try
        assignfile(InFile,sFilename);
        reset(InFile);
        readln(InFile,sLine);
        closefile(InFile);
        iElements := CountCommas(sLine) + 1;
        for iCount := 1 to iElements do
        begin
             sElement := GetDelimitedAsciiElement(sLine,',',iCount);
             ComboSite.Items.Add(sElement);
             ComboFeature.Items.Add(sElement);
             ComboValue.Items.Add(sElement);
        end;
        if (iElements = 4) then
        begin
             ComboSite.Text := ComboSite.Items.Strings[1];
             ComboFeature.Text := ComboFeature.Items.Strings[2];
             ComboValue.Text := ComboValue.Items.Strings[3];
        end
        else
        begin
             ComboSite.Text := ComboSite.Items.Strings[0];
             ComboFeature.Text := ComboFeature.Items.Strings[0];
             ComboValue.Text := ComboValue.Items.Strings[0];
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReadFieldNames',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TForm1.ReadMatrix(const sFilename : string;
                            const iSiteField, iFeatureField, iValueField : integer);
var
   InFile, SiteFile, FeatureFile, SummaryFile : TextFile;
   sLine, sElement, sSite, sPreviousSite, sFeature : string;
   iElements, iCount, iSiteIndex, iFeatureIndex : integer;
   rValue : extended;
   Key : KeyFile_T;
   Value : SingleValueFile_T;
   ValueFile, KeyFile : file;
   fEnd, fInitRichness : boolean;
begin
     try
        // assume file is sorted by site field
        // zero values will be skipped

        assignfile(InFile,sFilename);
        reset(InFile);
        readln(InFile,sLine);
        sPreviousSite := '';

        assignfile(SiteFile,ExtractFilePath(sFilename) + 'sites.csv');
        rewrite(SiteFile);
        writeln(SiteFile,'SITEKEY,NAME,I_STATUS,AREA');

        assignfile(ValueFile,ExtractFilePath(sFilename) + 'matrix.mtx');
        rewrite(ValueFile,1);
        assignfile(KeyFile,ExtractFilePath(sFilename) + 'matrix.key');
        rewrite(KeyFile,1);

        FeatureList.Items.Clear;
        iSiteIndex := 0;
        Key.iRichness := 0;
        fEnd := False;
        repeat
              readln(InFile,sLine);
              fEnd := Eof(InFile);

              sSite := GetDelimitedAsciiElement(sLine,',',iSiteField);
              sFeature := GetDelimitedAsciiElement(sLine,',',iFeatureField);
              rValue := StrToFloat(GetDelimitedAsciiElement(sLine,',',iValueField));

              if (rValue <> 0) then
              begin
                   fInitRichness := False;
                   // write the site id to the site file
                   if (sSite <> sPreviousSite) then
                   begin
                        Inc(iSiteIndex);
                        writeln(SiteFile,IntToStr(iSiteIndex) + ',' + sSite);

                        // set Key values
                        // write the previous site key and richness to the key file, if it is not blank
                        if (sPreviousSite <> '') then
                        begin
                             Key.iSiteKey := iSiteIndex - 1;
                             BlockWrite(KeyFile,Key,SizeOf(Key));
                             //fInitRichness := True;
                             Key.iRichness := 0;
                        end;

                        sPreviousSite := sSite;

                        //
                   end;
                   // add the feature id to the list and look up the corresponding feature index
                   // write the feature index and feature value to the matrix file
                   if (FeatureList.Items.Count = 0) then
                   begin
                        FeatureList.Items.Add(sFeature);
                        iFeatureIndex := 1;
                   end
                   else
                   begin
                        iFeatureIndex := FeatureList.Items.IndexOf(sFeature) + 1;
                        if (iFeatureIndex = 0) then
                        begin
                             FeatureList.Items.Add(sFeature);
                             iFeatureIndex := FeatureList.Items.Count;
                        end;
                   end;
                   if (rValue <> 0) then
                   begin
                        Inc(Key.iRichness);
                        // set Value values
                        Value.iFeatKey := iFeatureIndex;
                        Value.rAmount := rValue;
                        BlockWrite(ValueFile,Value,SizeOf(Value));
                   end;
                   //if fInitRichness then
                   //   Key.iRichness := 0;
              end;
              if fEnd then
              begin
                   fInitRichness := False;
                   // write the site id to the site file
                   Inc(iSiteIndex);
                   if (sSite <> sPreviousSite) then
                   begin
                        writeln(SiteFile,IntToStr(iSiteIndex) + ',' + sSite);
                   end;
                   if fEnd then
                   begin
                        Key.iSiteKey := iSiteIndex - 1;
                        BlockWrite(KeyFile,Key,SizeOf(Key));
                        Key.iRichness := 0;

                        sPreviousSite := sSite;
                   end;
                   // add the feature id to the list and look up the corresponding feature index
                   // write the feature index and feature value to the matrix file
                   if (FeatureList.Items.Count = 0) then
                   begin
                        FeatureList.Items.Add(sFeature);
                        iFeatureIndex := 1;
                   end
                   else
                   begin
                        iFeatureIndex := FeatureList.Items.IndexOf(sFeature) + 1;
                        if (iFeatureIndex = 0) then
                        begin
                             FeatureList.Items.Add(sFeature);
                             iFeatureIndex := FeatureList.Items.Count;
                        end;
                   end;
                   if (rValue <> 0) then
                   begin
                        Inc(Key.iRichness);
                        // set Value values
                        Value.iFeatKey := iFeatureIndex;
                        Value.rAmount := rValue;
                        BlockWrite(ValueFile,Value,SizeOf(Value));
                   end;
              end;

        until fEnd;

        closefile(InFile);
        closefile(SiteFile);
        closefile(ValueFile);
        closefile(KeyFile);
        assignfile(FeatureFile,ExtractFilePath(sFilename) + 'features.csv');
        rewrite(FeatureFile);
        writeln(FeatureFile,'FEATKEY,FEATNAME,ITARGET');
        // write feature id's to the feauture file
        for iCount := 1 to FeatureList.Items.Count do
            writeln(FeatureFile,IntToStr(iCount) + ',' + FeatureList.Items.Strings[iCount-1]);
        closefile(FeatureFile);

        assignfile(SummaryFile,ExtractFilePath(sFilename) + 'summary.txt');
        rewrite(SummaryFile);
        writeln(SummaryFile,'File=' + sFilename);
        writeln(SummaryFile,'SiteId=' + ComboSite.Text);
        writeln(SummaryFile,'FeatureId=' + ComboFeature.Text);
        writeln(SummaryFile,'FeatureValue=' + ComboValue.Text);
        writeln(SummaryFile,'Sites=' + IntToStr(iSiteIndex-1));
        writeln(SummaryFile,'Features=' + IntToStr(FeatureList.Items.Count));
        closefile(SummaryFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ReadMatrix',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TForm1.FastReadMatrix(const sFilename : string;
                                const iSiteField, iFeatureField, iValueField : integer);
var
   InFile, SiteFile, FeatureFile, SummaryFile : TextFile;
   sLine, sElement, sSite, sPreviousSite, sFeature : string;
   iElements, iCount, iSiteIndex, iFeatureIndex, iMaxFeatureIndex : integer;
   rValue : extended;
   Key : KeyFile_T;
   Value : SingleValueFile_T;
   ValueFile, KeyFile : file;
   fEnd, fInitRichness : boolean;
begin
     try
        // assume file is sorted by site field
        // zero values will be skipped

        assignfile(InFile,sFilename);
        reset(InFile);
        readln(InFile,sLine);
        sPreviousSite := '';

        assignfile(SiteFile,ExtractFilePath(sFilename) + 'sites.csv');
        rewrite(SiteFile);
        writeln(SiteFile,'SITEKEY,NAME');

        assignfile(ValueFile,ExtractFilePath(sFilename) + 'matrix.mtx');
        rewrite(ValueFile,1);
        assignfile(KeyFile,ExtractFilePath(sFilename) + 'matrix.key');
        rewrite(KeyFile,1);

        iMaxFeatureIndex := 0;
        iSiteIndex := 0;
        Key.iRichness := 0;
        fEnd := False;
        repeat
              readln(InFile,sLine);
              fEnd := Eof(InFile);

              sSite := GetDelimitedAsciiElement(sLine,',',iSiteField);
              sFeature := GetDelimitedAsciiElement(sLine,',',iFeatureField);
              rValue := StrToFloat(GetDelimitedAsciiElement(sLine,',',iValueField));

              if (rValue <> 0) then
              begin
                   fInitRichness := False;
                   // write the site id to the site file
                   if (sSite <> sPreviousSite) then
                   begin
                        Inc(iSiteIndex);
                        writeln(SiteFile,IntToStr(iSiteIndex) + ',' + sSite);

                        // set Key values
                        // write the previous site key and richness to the key file, if it is not blank
                        if (sPreviousSite <> '') then
                        begin
                             Key.iSiteKey := iSiteIndex - 1;
                             BlockWrite(KeyFile,Key,SizeOf(Key));
                             //fInitRichness := True;
                             Key.iRichness := 0;
                        end;
                        sPreviousSite := sSite;
                   end;
                   // add the feature id to the list and look up the corresponding feature index
                   // write the feature index and feature value to the matrix file
                   iFeatureIndex := StrToInt(sFeature);
                   if (iFeatureIndex > iMaxFeatureIndex) then
                      iMaxFeatureIndex := iFeatureIndex;
                   if (rValue <> 0) then
                   begin
                        Inc(Key.iRichness);
                        // set Value values
                        Value.iFeatKey := iFeatureIndex;
                        Value.rAmount := rValue;
                        BlockWrite(ValueFile,Value,SizeOf(Value));
                   end;
                   //if fInitRichness then
                   //   Key.iRichness := 0;
              end;
              if fEnd then
              begin
                   fInitRichness := False;
                   // write the site id to the site file
                   Inc(iSiteIndex);
                   if (sSite <> sPreviousSite) then
                   begin
                        writeln(SiteFile,IntToStr(iSiteIndex) + ',' + sSite);
                   end;
                   if fEnd then
                   begin
                        Key.iSiteKey := iSiteIndex - 1;
                        BlockWrite(KeyFile,Key,SizeOf(Key));
                        Key.iRichness := 0;

                        sPreviousSite := sSite;
                   end;
                   // add the feature id to the list and look up the corresponding feature index
                   // write the feature index and feature value to the matrix file
                   iFeatureIndex := StrToInt(sFeature);
                   if (iFeatureIndex > iMaxFeatureIndex) then
                      iMaxFeatureIndex := iFeatureIndex;
                   if (rValue <> 0) then
                   begin
                        Inc(Key.iRichness);
                        // set Value values
                        Value.iFeatKey := iFeatureIndex;
                        Value.rAmount := rValue;
                        BlockWrite(ValueFile,Value,SizeOf(Value));
                   end;
              end;

        until fEnd;

        closefile(InFile);
        closefile(SiteFile);
        closefile(ValueFile);
        closefile(KeyFile);
        assignfile(FeatureFile,ExtractFilePath(sFilename) + 'features.csv');
        rewrite(FeatureFile);
        writeln(FeatureFile,'FEATKEY,FEATNAME');
        // write feature id's to the feauture file
        for iCount := 1 to iMaxFeatureIndex do
            writeln(FeatureFile,IntToStr(iCount) + ',' + IntToStr(iCount));
        closefile(FeatureFile);

        assignfile(SummaryFile,ExtractFilePath(sFilename) + 'summary.txt');
        rewrite(SummaryFile);
        writeln(SummaryFile,'File=' + sFilename);
        writeln(SummaryFile,'SiteId=' + ComboSite.Text);
        writeln(SummaryFile,'FeatureId=' + ComboFeature.Text);
        writeln(SummaryFile,'FeatureValue=' + ComboValue.Text);
        writeln(SummaryFile,'Sites=' + IntToStr(iSiteIndex-1));
        writeln(SummaryFile,'Features=' + IntToStr(iMaxFeatureIndex));
        closefile(SummaryFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in FastReadMatrix',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TForm1.btnLocateClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
     begin
          EditInMatrix.Text := OpenDialog1.Filename;

          Label2.Enabled := True;
          Label3.Enabled := True;
          Label4.Enabled := True;
          ComboSite.Enabled := True;
          ComboFeature.Enabled := True;
          ComboValue.Enabled := True;
          ComboSite.Items.Clear;
          ComboFeature.Items.Clear;
          ComboValue.Items.Clear;

          ReadFieldNames(EditInMatrix.Text);
     end;
end;

procedure TForm1.BitBtnExitClick(Sender: TObject);
begin
     Application.Terminate;
end;

procedure TForm1.BitBtnConvertClick(Sender: TObject);
begin
     //
     Screen.Cursor := crHourglass;
     if fileexists(EditInMatrix.Text) then
     begin
          ReadMatrix(EditInMatrix.Text,
                    ComboSite.Items.IndexOf(ComboSite.Text) + 1,
                    ComboFeature.Items.IndexOf(ComboFeature.Text) + 1,
                    ComboValue.Items.IndexOf(ComboValue.Text) + 1);
          MessageDlg('File converted ok',mtInformation,[mbOk],0);
          Application.Terminate;
     end;
     Screen.Cursor := crDefault;
end;


procedure TForm1.BitBtnFastConvertClick(Sender: TObject);
begin
     //
     Screen.Cursor := crHourglass;
     if fileexists(EditInMatrix.Text) then
     begin
          FastReadMatrix(EditInMatrix.Text,
                         ComboSite.Items.IndexOf(ComboSite.Text) + 1,
                         ComboFeature.Items.IndexOf(ComboFeature.Text) + 1,
                         ComboValue.Items.IndexOf(ComboValue.Text) + 1);  
          MessageDlg('File converted ok',mtInformation,[mbOk],0);
          Application.Terminate;
     end;
     Screen.Cursor := crDefault;
end;

end.
