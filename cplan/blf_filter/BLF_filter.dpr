program BLF_filter;

uses
  Forms,
   blffilter1 in 'blffilter1.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TConvertCISitesForm, ConvertCISitesForm);
  Application.Run;
end.
