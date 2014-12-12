program Delimited_file_parser;

uses
  Forms,
  delim_parse in 'delim_parse.pas' {ParseDelimitedFileForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TParseDelimitedFileForm, ParseDelimitedFileForm);
  Application.Run;
end.
