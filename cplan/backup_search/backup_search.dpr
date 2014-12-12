program backup_search;

uses
  Forms,
  search in 'search.pas' {SelectFilesForm},
  search_main in 'search_main.pas' {SearchForm},
  scan in 'scan.pas' {ScanForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TSearchForm, SearchForm);
  Application.CreateForm(TScanForm, ScanForm);
  Application.Run;
end.
