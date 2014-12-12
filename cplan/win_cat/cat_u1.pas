unit cat_u1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TJoinForm = class(TForm)
    btnJoinFiles: TButton;
    Label1: TLabel;
    JoinMemo: TMemo;
    lblProgress: TLabel;
    EditOutput: TEdit;
    Label2: TLabel;
    procedure btnJoinFilesClick(Sender: TObject);
    procedure ParseInFile(sFile : string);
    procedure CatFiles;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  JoinForm: TJoinForm;
  OutFile : TextFile;

implementation

{$R *.DFM}

procedure TJoinForm.ParseInFile(sFile : string);
var
   InFile : File of byte;
   fStop : boolean;
   bByte : byte;
   iValue : integer;
   sValue : string;
begin
     // read the contents of infile and write it to outfile

     assignfile(InFile,sFile);
     reset(InFile);

     fStop := False;
     repeat
           fStop := Eof(InFile);

           if not fStop then
           try
              read(InFile,bByte);
              iValue := bByte;
              sValue := IntToStr(iValue);
              writeln(OutFile,sValue);
           except
                 fStop := True;
           end;

     until fStop;

     closefile(InFile);
end;

procedure TJoinForm.CatFiles;
var
   iCount : integer;
begin
     if (JoinMemo.Lines.Count > 0) then
     begin
          Screen.Cursor := crHourglass;

          assignfile(OutFile,EditOutput.Text);
          rewrite(OutFile);

          for iCount := 0 to (JoinMemo.Lines.Count - 1) do
          begin
               lblProgress.Caption := 'reading file ' +
                                      IntToStr(iCount+1) +
                                      ' of ' +
                                      IntToStr(JoinMemo.Lines.Count);
               lblProgress.Update;

               ParseInFile(JoinMemo.Lines.Strings[iCount]);
          end;

          lblProgress.Caption := 'finished';
          lblProgress.Update;

          closefile(OutFile);

          Screen.Cursor := crDefault;
     end;
end;

procedure TJoinForm.btnJoinFilesClick(Sender: TObject);
begin
     CatFiles;
end;

end.
