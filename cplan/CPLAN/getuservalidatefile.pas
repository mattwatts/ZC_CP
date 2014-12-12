unit getuservalidatefile;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TFormGetUserValidateFile = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    EditInputFile: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    procedure EditInputFileClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormGetUserValidateFile: TFormGetUserValidateFile;

function UserSelectValidateFile : string;
function ValidateThisIteration(const iIteration : integer) : boolean;
procedure SaveItnValidateFile;

implementation

uses
    Control, validate, ds;

{$R *.DFM}

function ValidateThisIteration(const iIteration : integer) : boolean;
var
   fValidateIteration : boolean;
begin
     if fValidateIterationsCreated then
     begin
          Result := False;
          if (iIteration > 0)
          and (iIteration <= ValidateIterations.lMaxSize) then
          begin
               ValidateIterations.rtnValue(iIteration,@fValidateIteration);
               Result := fValidateIteration;
          end;
     end
     else
         Result := True;
end;

procedure SaveItnValidateFile;
var
   OutputFile : TextFile;
   iCount : integer;
   fValidateIteration : boolean;
begin
     if fValidateIterationsCreated then
     begin
          // make a copy of this file in the working directory
          assignfile(OutputFile,ControlRes^.sWorkingDirectory + '\IterationsToValidate.csv');
          rewrite(OutputFile);
          writeln(OutputFile,'IterationsToValidate');
          for iCount := 1 to ValidateIterations.lMaxSize do
          begin
               ValidateIterations.rtnValue(iCount,@fValidateIteration);
               if fValidateIteration then
                  writeln(OutputFile,IntToStr(iCount));
          end;
          closefile(OutputFile);
     end;
end;


procedure LoadItnValidateFile(const sFilename : string);
var
   InputFile, OutputFile : TextFile;
   iMaxValue, iValue, iCount : integer;
   sLine : string;
   fValidateIteration : boolean;
begin
     // find the maximum iteration number in the file
     assignfile(InputFile,sFilename);
     reset(InputFile);
     readln(InputFile);
     iMaxValue := 0;
     repeat
           readln(InputFile,sLine);
           iValue := strtoint(sLine);
           if (iValue > iMaxValue) then
              iMaxValue := iValue;
     until Eof(InputFile);
     closefile(InputFile);
     // create the array and init it
     if fValidateIterationsCreated then
        ValidateIterations.Destroy;
     ValidateIterations := Array_t.Create;
     ValidateIterations.init(SizeOf(boolean),iMaxValue);
     fValidateIteration := False;
     for iCount := 1 to iMaxValue do
         ValidateIterations.setValue(iCount,@fValidateIteration);
     // read the file again and load the data from it to the array
     assignfile(InputFile,sFilename);
     reset(InputFile);
     readln(InputFile);
     fValidateIteration := True;
     repeat
           readln(InputFile,sLine);
           iValue := strtoint(sLine);
           ValidateIterations.setValue(iValue,@fValidateIteration);
     until Eof(InputFile);
     closefile(InputFile);
     // make a copy of this file in the working directory
     sValidateIterationsFile := ControlRes^.sWorkingDirectory + '\IterationsToValidate.csv';
     assignfile(OutputFile,sValidateIterationsFile);
     rewrite(OutputFile);
     writeln(OutputFile,'IterationsToValidate');
     for iCount := 1 to ValidateIterations.lMaxSize do
     begin
          ValidateIterations.rtnValue(iCount,@fValidateIteration);
          if fValidateIteration then
             writeln(OutputFile,IntToStr(iCount));
     end;
     closefile(OutputFile);

     fValidateIterationsCreated := True;
end;

function UserSelectValidateFile : string;
begin
     try
     Result := '';

     FormGetUserValidateFile := TFormGetUserValidateFile.Create(Application);
     if (FormGetUserValidateFile.ShowModal = mrOk) then
        if (FormGetUserValidateFile.EditInputFile.Text <> 'click here to browse the input file') then
        begin
             // attempt to load the file
             if fileexists(FormGetUserValidateFile.EditInputFile.Text) then
             begin
                  LoadItnValidateFile(FormGetUserValidateFile.EditInputFile.Text);
                  Result := FormGetUserValidateFile.EditInputFile.Text;
             end;
        end;
     except
     end;
end;

procedure TFormGetUserValidateFile.EditInputFileClick(Sender: TObject);
begin
     if (EditInputFile.Text = 'click here to browse the input file') then
        OpenDialog1.InitialDir := ControlRes^.sWorkingDirectory;

     if OpenDialog1.Execute then
        EditInputFile.Text := OpenDialog1.Filename;
end;

end.
