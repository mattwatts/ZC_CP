unit R_access;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TR_Form = class(TForm)
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  R_Form: TR_Form;

implementation

uses
    Miscellaneous;

{$R *.DFM}



procedure TR_Form.FormCreate(Sender: TObject);
var
   sInstallPath : string;
begin
     sInstallPath := Return_R_InstallPath;

     if (sInstallPath = '') then
        label1.Caption := 'R is not installed'
     else
         label1.Caption := 'R is installed on "' + sInstallPath + '"';
end;

end.
