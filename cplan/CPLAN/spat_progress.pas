unit spat_progress;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TSpatialProgressForm = class(TForm)
    Label1: TLabel;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SpatialProgressForm: TSpatialProgressForm;

implementation

{$R *.DFM}

procedure TSpatialProgressForm.BitBtn1Click(Sender: TObject);
begin
     Free;
end;

end.
