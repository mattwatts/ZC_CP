unit datamod1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TDataModule1 = class(TDataModule)
    procedure DataModule1Create(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule1: TDataModule1;

implementation

uses
    Start;

{$R *.DFM}

procedure TDataModule1.DataModule1Create(Sender: TObject);
begin
     run_me;
end;

end.
