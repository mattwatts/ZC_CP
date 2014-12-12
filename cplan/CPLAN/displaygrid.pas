unit displaygrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids;

type
  TDisplayGridForm = class(TForm)
    StringGrid1: TStringGrid;
    procedure InitWithFile(const sFilename : string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DisplayGridForm: TDisplayGridForm;

implementation

uses
    imptools;

{$R *.DFM}


procedure TDisplayGridForm.InitWithFile(const sFilename : string);
begin
     Caption := sFilename;
     LoadCSV2StringGrid(StringGrid1,sFilename,False);
end;

end.
