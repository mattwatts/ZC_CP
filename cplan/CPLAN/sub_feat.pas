unit sub_feat;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TStopSubsetForm = class(TForm)
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    btnOk: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
    procedure CheckBox6Click(Sender: TObject);
    procedure CheckBox7Click(Sender: TObject);
    procedure CheckBox8Click(Sender: TObject);
    procedure CheckBox9Click(Sender: TObject);
    procedure CheckBox10Click(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  StopSubsetForm: TStopSubsetForm;

implementation

uses
    rules;

{$R *.DFM}

function CheckTheBoxes : boolean;
begin
     Result := False;

     with StopSubsetForm do
     begin
          if CheckBox1.Checked then
             Result := True;
          if CheckBox2.Checked then
             Result := True;
          if CheckBox3.Checked then
             Result := True;
          if CheckBox4.Checked then
             Result := True;
          if CheckBox5.Checked then
             Result := True;
          if CheckBox6.Checked then
             Result := True;
          if CheckBox7.Checked then
             Result := True;
          if CheckBox8.Checked then
             Result := True;
          if CheckBox9.Checked then
             Result := True;
          if CheckBox10.Checked then
             Result := True;
     end;
end;

procedure TStopSubsetForm.FormCreate(Sender: TObject);
begin
     CheckBox1.Checked := ClassesToTest[1];
     CheckBox2.Checked := ClassesToTest[2];
     CheckBox3.Checked := ClassesToTest[3];
     CheckBox4.Checked := ClassesToTest[4];
     CheckBox5.Checked := ClassesToTest[5];
     CheckBox6.Checked := ClassesToTest[6];
     CheckBox7.Checked := ClassesToTest[7];
     CheckBox8.Checked := ClassesToTest[8];
     CheckBox9.Checked := ClassesToTest[9];
     CheckBox10.Checked := ClassesToTest[10];
end;

procedure TStopSubsetForm.CheckBox1Click(Sender: TObject);
begin
     btnOk.Enabled := CheckTheBoxes;
end;

procedure TStopSubsetForm.CheckBox2Click(Sender: TObject);
begin
     btnOk.Enabled := CheckTheBoxes;
end;

procedure TStopSubsetForm.CheckBox3Click(Sender: TObject);
begin
     btnOk.Enabled := CheckTheBoxes;
end;

procedure TStopSubsetForm.CheckBox4Click(Sender: TObject);
begin
     btnOk.Enabled := CheckTheBoxes;
end;

procedure TStopSubsetForm.CheckBox5Click(Sender: TObject);
begin
     btnOk.Enabled := CheckTheBoxes;
end;

procedure TStopSubsetForm.CheckBox6Click(Sender: TObject);
begin
     btnOk.Enabled := CheckTheBoxes;
end;

procedure TStopSubsetForm.CheckBox7Click(Sender: TObject);
begin
     btnOk.Enabled := CheckTheBoxes;
end;

procedure TStopSubsetForm.CheckBox8Click(Sender: TObject);
begin
     btnOk.Enabled := CheckTheBoxes;
end;

procedure TStopSubsetForm.CheckBox9Click(Sender: TObject);
begin
     btnOk.Enabled := CheckTheBoxes;
end;

procedure TStopSubsetForm.CheckBox10Click(Sender: TObject);
begin
     btnOk.Enabled := CheckTheBoxes;
end;

procedure TStopSubsetForm.btnOkClick(Sender: TObject);
begin
     ClassesToTest[1] := CheckBox1.Checked;
     ClassesToTest[2] := CheckBox2.Checked;
     ClassesToTest[3] := CheckBox3.Checked;
     ClassesToTest[4] := CheckBox4.Checked;
     ClassesToTest[5] := CheckBox5.Checked;
     ClassesToTest[6] := CheckBox6.Checked;
     ClassesToTest[7] := CheckBox7.Checked;
     ClassesToTest[8] := CheckBox8.Checked;
     ClassesToTest[9] := CheckBox9.Checked;
     ClassesToTest[10] := CheckBox10.Checked;
end;

end.
