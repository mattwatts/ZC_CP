unit trimini;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TTrimIniForm = class(TForm)
    IniBox: TListBox;
    procedure DeleteExistingArcViewSection(const sIniFileName : string);
    procedure DeleteRedundantBlankLines(const sIniFileName : string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TrimIniForm: TTrimIniForm;

implementation

{$R *.DFM}

procedure TTrimIniForm.DeleteRedundantBlankLines(const sIniFileName : string);
var
   fPreviousLineWasBlank, fEndOfFile : boolean;
   iCount, iPositionInFile : integer;
begin
     // Delete redundant blank lines from the cplan ini file, that is
     // blank lines which follow another blank line

     with IniBox.Items do
     try
        Clear;
        LoadFromFile(sIniFileName);

        if (Count > 0) then
        begin
             fPreviousLineWasBlank := False;
             fEndOfFile := False;
             iCount := 0;
             repeat
                   if (Strings[iCount] = '') then
                   begin
                        // line is blank
                        if fPreviousLineWasBlank then
                           // delete this line from the list box
                           IniBox.Items.Delete(iCount)
                        else
                            // advance to the next line because the previous one wasn't blank
                            Inc(iCount);

                        fPreviousLineWasBlank := True;
                   end
                   else
                   begin
                        fPreviousLineWasBlank := False;
                        Inc(iCount);
                   end;
                   if (iCount >= Count) then
                      fEndOfFile := True;

             until fEndOfFile;
        end;

        // insert 1 blank line between sections

        SaveToFile(sIniFileName);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TTrimIniForm.DeleteRedundantBlankLines',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;


procedure TTrimIniForm.DeleteExistingArcViewSection(const sIniFileName : string);
var
   fStop, fInArcViewSection : boolean;
   iPositionInFile : integer;
begin
     with IniBox.Items do
     try
        Clear;
        LoadFromFile(sIniFileName);

        if (Count > 0) then
        begin
             iPositionInFile := 0;
             fStop := False;
             fInArcViewSection := False;
             {process contents of file}
             repeat
                   if fInArcViewSection then
                   begin
                        if (Length(Strings[iPositionInFile])>0) then
                           if (Copy(Strings[iPositionInFile],1,1) = '[') then
                              fInArcViewSection := False;
                   end
                   else
                   begin
                        if (Length(Strings[iPositionInFile]) = 9) then
                           if (Strings[iPositionInFile] = '[ArcView]') then
                              fInArcViewSection := True;
                   end;

                   if fInArcViewSection then
                      Delete(iPositionInFile)
                   else
                       Inc(iPositionInFile);

                   if (iPositionInFile >= Count) then
                      fStop := True;

             until fStop;

             SaveToFile(sIniFileName);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TTrimIniForm.DeleteExistingArcViewSection',
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

end.
