program ci_sitesconvert;

uses
  Forms,
  ci_sitesconvert1 in 'ci_sitesconvert1.pas' {ConvertCISitesForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TConvertCISitesForm, ConvertCISitesForm);
  Application.Run;
end.
