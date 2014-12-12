unit reserve_class;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons;

type
  TSpecifyReserveClassesForm = class(TForm)
    Label1: TLabel;
    lblDatabasePath: TLabel;
    EditClass1: TEdit;
    EditClass2: TEdit;
    EditClass3: TEdit;
    EditClass4: TEdit;
    EditClass5: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BitBtnOkClick(Sender: TObject);
    procedure BitBtnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SpecifyReserveClassesForm: TSpecifyReserveClassesForm;

implementation

uses
    inifiles;

{$R *.DFM}

procedure TSpecifyReserveClassesForm.FormCreate(Sender: TObject);
var
   sDatabasePath : string;
   AIni : TIniFile;
begin
     // load settings from c-plan.ini file
     // database path is parameter passed in by c-plan
     //if (ParamCount = 1) then

     sDatabasePath := ParamStr(1);

     lblDatabasePath.Caption := sDatabasePath;

     if fileexists(sDatabasePath + '\cplan.ini') then
     begin
          AIni := TIniFile.Create(sDatabasePath + '\cplan.ini');

          EditClass1.Text := AIni.ReadString('Reserve Class','Class 1 Label',EditClass1.Text);
          EditClass2.Text := AIni.ReadString('Reserve Class','Class 2 Label','');
          EditClass3.Text := AIni.ReadString('Reserve Class','Class 3 Label','');
          EditClass4.Text := AIni.ReadString('Reserve Class','Class 4 Label','');
          EditClass5.Text := AIni.ReadString('Reserve Class','Class 5 Label','');

          AIni.Free;
     end
     else
         Timer1.Enabled := True;
end;

procedure TSpecifyReserveClassesForm.Timer1Timer(Sender: TObject);
begin
     Timer1.Enabled := False;
     Application.Terminate;
end;

procedure TSpecifyReserveClassesForm.BitBtnOkClick(Sender: TObject);
var
   sDatabasePath : string;
   AIni : TIniFile;
begin
     // load settings from c-plan.ini file
     // database path is parameter passed in by c-plan
     //if (ParamCount = 1) then

     sDatabasePath := ParamStr(1);

     if fileexists(sDatabasePath + '\cplan.ini') then
     begin
          AIni := TIniFile.Create(sDatabasePath + '\cplan.ini');

          AIni.EraseSection('Reserve Class');
          if (EditClass1.Text <> '') then
             AIni.WriteString('Reserve Class','Class 1 Label',EditClass1.Text);
          if (EditClass2.Text <> '') then
             AIni.WriteString('Reserve Class','Class 2 Label',EditClass2.Text);
          if (EditClass3.Text <> '') then
             AIni.WriteString('Reserve Class','Class 3 Label',EditClass3.Text);
          if (EditClass4.Text <> '') then
             AIni.WriteString('Reserve Class','Class 4 Label',EditClass4.Text);
          if (EditClass5.Text <> '') then
             AIni.WriteString('Reserve Class','Class 5 Label',EditClass5.Text);

          AIni.Free;
     end;

     Timer1.Enabled := True;
end;

procedure TSpecifyReserveClassesForm.BitBtnCancelClick(Sender: TObject);
begin
     Timer1.Enabled := True;
end;

end.
