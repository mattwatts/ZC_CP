unit emrpr_U1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TEMRTestForm = class(TForm)
    btnExecute: TButton;
    procedure btnExecuteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EMRTestForm: TEMRTestForm;

implementation

uses
    EMRPR;

{$R *.DFM}

procedure TEMRTestForm.btnExecuteClick(Sender: TObject);
begin
     try
        Screen.Cursor := crHourglass;

        EMRPR_main;

        Screen.Cursor := crDefault;
        
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception calculating EMR',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

end.
