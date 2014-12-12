unit genrand;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Spin;

type
  TGenRandForm = class(TForm)
    SpinValue: TSpinEdit;
    BitBtn1: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SpinRow: TSpinEdit;
    SpinCol: TSpinEdit;
    BitBtn2: TBitBtn;
    WriteToFile: TCheckBox;
    EditFile: TEdit;
    Label4: TLabel;
    Button1: TButton;
    SaveMatrix: TSaveDialog;
    Label5: TLabel;
    Label6: TLabel;
    EditMin: TEdit;
    EditMax: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure WriteToFileClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GenRandForm: TGenRandForm;

implementation

{$R *.DFM}

procedure TGenRandForm.Button1Click(Sender: TObject);
begin
     if SaveMatrix.Execute then
        EditFile.Text := SaveMatrix.Filename;
end;

procedure TGenRandForm.WriteToFileClick(Sender: TObject);
begin
     if WriteToFile.Checked then
     begin
          if (EditFile.Text = '') then
             Button1Click(self);

          if (EditFile.Text = '') then
             WriteToFile.Checked := False;
     end;
end;

end.
