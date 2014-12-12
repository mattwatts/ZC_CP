unit DebugO;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FileCtrl, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    RadioGroup1: TRadioGroup;
    DirectoryListBox1: TDirectoryListBox;
    FilterComboBox1: TFilterComboBox;
    DriveComboBox1: TDriveComboBox;
    FileListBox1: TFileListBox;
    GroupBox2: TGroupBox;
    ListBox1: TListBox;
    GroupBox3: TGroupBox;
    ListBox2: TListBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    ListBox3: TListBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    procedure DriveComboBox1Change(Sender: TObject);
    procedure FileListBox1Change(Sender: TObject);
    procedure FileListBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

const
     szObject = 'class';
     szEndObject = 'end';

     szEndObjectSearch = 'implementation';

var
   lastindex : integer;
   szlastfilename : string;
   firstActive : boolean;
{$R *.DFM}

procedure TForm1.DriveComboBox1Change(Sender: TObject);
begin
     DirectoryListBox1.Drive := DriveComboBox1.Drive;
end;

procedure findstructures(szFileName : string);
var
   activeFile : text;
   InString : string;

begin
     if szfilename <> '' then
     begin
          assignfile(activeFile,szFileName);
          reset(ActiveFile);

          while not(eof(ActiveFile)) do
          begin
               readln(ActiveFile,InString);
               if (pos(szObject,InString) <> 0) then
               begin
                    form1.listbox1.items.add(extractfilename(szFileName) + ':' + InString);
                    form1.listbox1.update;
               end;

               if (pos(szEndObjectSearch,InString) <> 0) then
               begin
                    break;
               end;
          end;

          closefile(ActiveFile);
     end;
end;

procedure removestructures(szFileName : string);
begin
     messagedlg('remove not operating', mtinformation,[mbok],0);
end;

procedure TForm1.FileListBox1Change(Sender: TObject);
begin
{     if selected then parse for structures, adding to list box
     else remove file related structures from listbox}
     if FileListBox1.itemIndex <> -1 then
     begin
          if FileListBox1.selected[FileListBox1.itemindex] then
          begin
               findstructures(FileListBox1.Filename);
               if lastindex <> - 1 then
               begin
                    if not(FileListBox1.selected[lastindex]) then
                    begin
                         removestructures(szlastfilename);
                    end;
               end;
               lastindex := FileListBox1.itemindex;
               szlastfilename := FileListBox1.filename;
          end;
     end;
end;

procedure TForm1.FileListBox1Click(Sender: TObject);
begin
     if firstActive then
     begin
          if FileListBox1.selected[FileListBox1.itemindex] then
          begin
               findstructures(FileListBox1.Filename);
               if lastindex <> - 1 then
               begin
                    if not(FileListBox1.selected[lastindex]) then
                    begin
                         removestructures(szlastfilename);
                    end;
               end;
               lastindex := FileListBox1.itemindex;
               szlastfilename := FileListBox1.filename;
          end;
          firstActive := FALSE;
     end;
end;

initialization
begin
     firstActive := TRUE;
     lastindex := -1;
end;

end.
