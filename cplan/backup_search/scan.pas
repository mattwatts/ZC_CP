unit scan;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TScanForm = class(TForm)
    ScanResult: TListBox;
    SaveScanResult: TSaveDialog;
    TempList: TListBox;
    Panel1: TPanel;
    lblCount: TLabel;
    Label1: TLabel;
    Panel2: TPanel;
    btnSave: TButton;
    BitBtn2: TBitBtn;
    procedure ExecuteScan;
    procedure btnSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  str255 = string[255];

var
  ScanForm: TScanForm;

implementation

uses search_main,
     ds;

{$R *.DFM}

function FileIsNotConverted(const sFilename : string) : boolean;
var
   iLengthConverted, iLengthFilename : integer;
begin
     // returns False if sFilename has '_converted.txt' appended
     //    else True
     Result := True;
     iLengthConverted := Length('_converted.txt');
     iLengthFilename := Length(sFilename);
     if (iLengthFilename > iLengthConverted) then
        if (Copy(sFilename,
                 iLengthFilename - iLengthConverted + 1,
                 iLengthConverted) = '_converted.txt') then
           Result := False;
end;

function IsNull(const iInt : integer) : boolean;
begin
     Result := False;

     if (iInt = 0)
     {or (iInt = 8482816)
     or (iInt = 8483584)
     or (iInt = 8483840)
     or (iInt = 8488960)} then
        Result := True;
end;

function Is_CR(const iInt : integer) : boolean;
begin
     Result := False;

     if (iInt = 13)
     {or (iInt = 8482829)
     or (iInt = 8483597)
     or (iInt = 8483853)
     or (iInt = 8488973)} then
        Result := True;
end;
function Is_LF(const iInt : integer) : boolean;
begin
     Result := False;

     if (iInt = 10)
     {or (iInt = 8482826)
     or (iInt = 8483594)
     or (iInt = 8483850)
     or (iInt = 8488970)} then
        Result := True;
end;

procedure Debug_LoadTextFile2ListBox(const sTextFile : string;
                                     const fDebug : boolean;
                                     const i_Null, i_CR, i_LF : integer);
//
// Called when file to convert is not using a recognised coding for
//
var
   InFile : File;
   OutFile : TextFile;
   fEof : boolean;
   sLine : string;
   cChar : char;
   iValue, iLinesAdded, iLine,
   iRow_14, iRow_15, iRow_16 : integer;
   // rows iRow_14, iRow_15, iRow_16 are NULL, CR, LF
begin
     //
     ScanForm.TempList.Items.Clear;

     iRow_14 := 0;
     iRow_15 := 0;
     iRow_16 := 0;

     if FileIsNotConverted(sTextFile) then
     begin
          if fDebug then
          begin
               assignfile(OutFile,sTextFile + '_debug.txt');
               rewrite(OutFile);
          end;

          if FileExists(sTextFile) then
          begin
               assignfile(InFile,sTextFile);
               reset(InFile,1);

               sLine := '';
               fEof := False;
               iLinesAdded := 0;
               iLine := 1;
               repeat
                     //fEof := EOF(InFile);

                     blockread(InFile,iValue,1);

                     if fDebug then
                        if (iLine = 14)
                        or (iLine = 15)
                        or (iLine = 16) then
                           // write rows 14,15 and 16 to the file
                           writeln(OutFile,IntToStr(iValue));

                     // i_Null, i_CR, i_LF

                     if (i_Null <> iValue)
                     and (i_LF <> iValue) then
                     // null character
                     // line feed character (always preceded by a carriage return character)
                     begin
                          if (i_CR = iValue) then
                          begin
                               // 13 is a carriage return character, add the current line to the listbox
                               ScanForm.TempList.Items.Add(sLine);
                               // initialise the current line
                               sLine := '';
                               Inc(iLinesAdded);
                          end
                          else
                              // character is not 0, 10 or 13 so append it to the current line
                              sLine := sLine + Chr(iValue);
                     end;

                     {
                     readln(InFile,sLine);
                     AListBox.Items.Add(sLine);
                     }

                     Inc(iLine);

               until EOF(InFile);

               closefile(InFile);

               if fDebug then
                  closefile(OutFile);

               if FileIsNotConverted(sTextFile) then
                  ScanForm.TempList.Items.SaveToFile(sTextFile + '_converted.txt');

               {if (iLinesAdded = 0)
               and (not fDebug) then
                   LoadTextFile2ListBox(sTextFile,True);}
          end;
     end
     else
         ScanForm.TempList.Items.LoadFromFile(sTextFile);
end;


procedure LoadTextFile2ListBox(const sTextFile : string;
                               const fDebug : boolean);
var
   InFile : File;
   OutFile : TextFile;
   fEof : boolean;
   sLine : string;
   cChar : char;
   iValue, iLinesAdded, iLine,
   iRow_14, iRow_15, iRow_16 : integer;
   // rows iRow_14, iRow_15, iRow_16 are NULL, CR, LF
begin
     //
     ScanForm.TempList.Items.Clear;

     iRow_14 := 0;
     iRow_15 := 0;
     iRow_16 := 0;

     if FileIsNotConverted(sTextFile) then
     begin
          if fDebug then
          begin
               assignfile(OutFile,sTextFile + '_debug.txt');
               rewrite(OutFile);
          end;

          if FileExists(sTextFile) then
          begin
               assignfile(InFile,sTextFile);
               reset(InFile,1);

               sLine := '';
               fEof := False;
               iLinesAdded := 0;
               iLine := 1;
               repeat
                     //fEof := EOF(InFile);

                     blockread(InFile,iValue,1);

                     if (iLine = 14) then
                        iRow_14 := iValue;
                     if (iLine = 15) then
                        iRow_15 := iValue;
                     if (iLine = 16) then
                        iRow_16 := iValue;

                     if fDebug then
                        if (iLine = 14)
                        or (iLine = 15)
                        or (iLine = 16) then
                           // write rows 14,15 and 16 to the file
                           writeln(OutFile,IntToStr(iValue));

                     if (not IsNull(iValue))
                     and (not Is_LF(iValue)) then
                     // 0 is a null character
                     // 10 is a line feed character (always preceded by 13, a carriage return character)
                     begin
                          if Is_CR(iValue) then
                          begin
                               // 13 is a carriage return character, add the current line to the listbox
                               ScanForm.TempList.Items.Add(sLine);
                               // initialise the current line
                               sLine := '';
                               Inc(iLinesAdded);
                          end
                          else
                              // character is not 0, 10 or 13 so append it to the current line
                              sLine := sLine + Chr(iValue);
                     end;

                     {
                     readln(InFile,sLine);
                     AListBox.Items.Add(sLine);
                     }

                     Inc(iLine);

               until EOF(InFile);

               closefile(InFile);

               if fDebug then
                  closefile(OutFile);

               if FileIsNotConverted(sTextFile) then
                  ScanForm.TempList.Items.SaveToFile(sTextFile + '_converted.txt');

               if (iLinesAdded = 0)
               and (not fDebug) then
                   Debug_LoadTextFile2ListBox(sTextFile,
                                              True,
                                              iRow_14,  // NULL
                                              iRow_15,  // CR
                                              iRow_16   // LF
                                              );
          end;
     end
     else
         ScanForm.TempList.Items.LoadFromFile(sTextFile);
end;

procedure TScanForm.ExecuteScan;
var
   iSearchStrings, iPos, iSearchFiles, iSearchLine, iDirectoryLine, iMatchCount, iFileMatchCount : integer;
   sSearchFile, sSearchString : string;
   sFixedLengthSearchString : str255;
   SearchStrings : Array_t;
   fStop : boolean;

   procedure PrepareSearchStrings;
   begin
        ScanResult.Items.Add('Search Strings :');

        sSearchString := SearchForm.SearchEdit.Text;
        iSearchStrings := 0;
        SearchStrings := Array_t.Create;
        SearchStrings.init(SizeOf(str255),5);
        fStop := False;
        repeat
              // fetch the next search string (if there is another one)
              // \ is the delimiter
              iPos := Pos('\',sSearchString);
              if (iPos > 0) then
              begin
                   sFixedLengthSearchString := Copy(sSearchString,1,iPos - 1);
                   sSearchString := Copy(sSearchString,iPos + 1,Length(sSearchString) - iPos);
              end
              else
              begin
                   sFixedLengthSearchString := sSearchString;
                   fStop := True;
              end;

              Inc(iSearchStrings);
              if (iSearchStrings > SearchStrings.lMaxSize) then
                 SearchStrings.resize(SearchStrings.lMaxSize + 5);
              SearchStrings.setValue(iSearchStrings,@sFixedLengthSearchString);

              ScanResult.Items.Add(sFixedLengthSearchString);

        until fStop;

        if (iSearchStrings <> SearchStrings.lMaxSize) then
           SearchStrings.resize(iSearchStrings);
   end;

begin
     // SearchForm.FileList  files to scan
     // SearchForm.SearchEdit.Text      search string
     // TempList             temporary file buffer
     try
        if not FileExists(SearchForm.FileList.Items.Strings[0]) then
        begin
             // search file(s) don't exist
             {MessageDlg('Search aborted because search file does not exist ' +
                        SearchForm.FileList.Items.Strings[0],
                        mtInformation,[mbOk],0);}

             ScanResult.Items.Add('Search aborted because search file does not exist.');
             ScanResult.Items.Add('File : ' + SearchForm.FileList.Items.Strings[0]);
        end
        else
        begin
             // determine if we have multiple search strings and split them up
             PrepareSearchStrings;
             // sSearchString := SearchForm.SearchEdit.Text;
             iMatchCount := 0;

             // ScanResult.Items.Add('Search String : ' + sSearchString);
             ScanResult.Items.Add('Search Directory : ' +
                                  ExtractFileDir(SearchForm.FileList.Items.Strings[0]));
             ScanResult.Items.Add('');

             if (SearchStrings.lMaxSize = 1) then
             begin
                  // If there is only one search string, cache it so we don't
                  // have to return it for each file.
                  SearchStrings.rtnValue(1,@sFixedLengthSearchString);
                  sSearchString := sFixedLengthSearchString;
             end;

             if SearchForm.CheckDisable.Checked then
             begin
                  SearchStrings.resize(1);
                  sSearchString := SearchForm.SearchEdit.Text;
             end;

             if (SearchForm.FileList.Items.Count > 0) then
                for iSearchFiles := 0 to (SearchForm.FileList.Items.Count - 1) do
                begin
                     SearchForm.lblUpdate.Caption := 'Processing ' +
                                                     IntToStr(iSearchFiles+1) +
                                                     ' of ' +
                                                     IntToStr(SearchForm.FileList.Items.Count);
                     SearchForm.Update;

                     iFileMatchCount := 0;
                     sSearchFile := SearchForm.FileList.Items.Strings[iSearchFiles];

                     LoadTextFile2ListBox(sSearchFile,
                                          False);

                     // loop through each of the Search Strings
                     for iPos := 1 to SearchStrings.lMaxSize do
                     begin
                          if (SearchStrings.lMaxSize > 1) then
                          begin
                               SearchStrings.rtnValue(iPos,@sFixedLengthSearchString);
                               sSearchString := sFixedLengthSearchString;
                          end;

                          // scan each line of the file currently loaded
                          for iSearchLine := 0 to (TempList.Items.Count - 1) do
                              if (Pos(LowerCase(sSearchString),
                                      LowerCase(TempList.Items.Strings[iSearchLine])) > 0) then
                              begin
                                   Inc(iMatchCount);
                                   Inc(iFileMatchCount);

                                   // we have found a match for our search
                                   //ScanResult.Items.Add('File : ' + ExtractFileName(SearchForm.FileList.Items.Strings[iSearchFiles]));
                                   //ScanResult.Items.Add('Directory : ' + SearchForm.FileList.Items.Strings[iSearchFiles]);

                                   if (Length(TempList.Items.Strings[iSearchLine]) > 10) then
                                      if (Copy(TempList.Items.Strings[iSearchLine],1,10) <> 'Directory ')
                                      and (iSearchLine > 0) then
                                      begin
                                           // rewind until we find the directory containing this search string
                                           iDirectoryLine := iSearchLine;
                                           repeat
                                                 Dec(iDirectoryLine);

                                           until (iDirectoryLine = 0)
                                           or (Copy(TempList.Items.Strings[iDirectoryLine],1,10) = 'Directory ');

                                           ScanResult.Items.Add('Directory : ' + TempList.Items.Strings[iDirectoryLine]);
                                      end;
                                   ScanResult.Items.Add('Line ' +
                                                        IntToStr(iSearchLine+1) +
                                                        ' : ' +
                                                        TempList.Items.Strings[iSearchLine]);
                                   ScanResult.Items.Add('------------------------------------');
                              end;
                     end;

                     if (iFileMatchCount > 0) then
                     begin
                          ScanResult.Items.Add('');
                          ScanResult.Items.Add(IntToStr(iFileMatchCount) + ' search matches found in file :');
                          ScanResult.Items.Add(ExtractFileName(SearchForm.FileList.Items.Strings[iSearchFiles]));
                          if (SearchStrings.lMaxSize > 1) then
                          begin
                               ScanResult.Items.Add('With search string :');
                               ScanResult.Items.Add(sSearchString);
                          end;
                          ScanResult.Items.Add('------------------------------------------------------------------------');
                          ScanResult.Items.Add('');
                     end;

                     SearchForm.lblSearchMatches.Caption := IntToStr(iMatchCount) + ' search matches found.';
                end;

             if (iMatchCount > 0) then
                ScanResult.Items.Add('');
             ScanResult.Items.Add(IntToStr(iMatchCount) + ' search matches found in all files.');
             lblCount.Caption := IntToStr(iMatchCount) + ' search matches found in all files.';

             SearchStrings.Destroy;
             SearchForm.lblUpdate.Caption := '';
             SearchForm.Update;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Execute Search, file(s) may be read only',mtError,[mbOk],0);
     end;
end;

procedure TScanForm.btnSaveClick(Sender: TObject);
begin
     if SaveScanResult.Execute then
        ScanResult.Items.SaveToFile(SaveScanResult.Filename);
end;

end.
