unit Editcoun;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Spin;

type
  TEditCountForm = class(TForm)
    SpinValue: TSpinEdit;
    btnOk: TButton;
    btnCancel: TButton;
    lblValue: TLabel;
    lblProgress: TLabel;
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EditCountForm: TEditCountForm;



function GetUserCount(const sCaption,sValue,sOk,sCancel : string;
                      const lMin, lMax : longint;
                      var lUser : longint) : boolean;

implementation

uses
    Randtest;


{$R *.DFM}

function GetUserCount(const sCaption,sValue,sOk,sCancel : string;
                      const lMin, lMax : longint;
                      var lUser : longint) : boolean;
begin
     Result := False;
     lUser := lMin;

     try
        EditCountForm := TEditCountForm.Create(Application);
        with EditCountForm do
        begin
             Caption := sCaption;
             lblValue.Caption := sValue;
             btnOk.Caption := sOk;
             btnCancel.Caption := sCancel;
             SpinValue.MinValue := lMin;
             SpinValue.MaxValue := lMax;
             SpinValue.Value := lMin;

             Screen.Cursor := crDefault;

             if (ShowModal = mrOk) then
             begin
                  Result := True;
                  lUser := SpinValue.Value;
             end;
        end;


     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in GetUserCount',mtError,[mbOk],0);
     end;

     EditCountForm.Free;
end;


procedure TEditCountForm.btnOkClick(Sender: TObject);
begin
     Screen.Cursor := crHourglass;

     RunRandomTest(SpinValue.Value);

     ModalResult := mrOk;
end;

procedure TEditCountForm.btnCancelClick(Sender: TObject);
begin
     ModalResult := mrCancel;
end;

end.
