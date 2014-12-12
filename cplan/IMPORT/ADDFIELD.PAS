unit Addfield;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, DB, DBTables, Spin;

type
  TBtnBottomDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Label1: TLabel;
    EditName: TEdit;
    TypeGroup: TRadioGroup;
    SpinSize: TSpinEdit;
    SpinDec: TSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    AQuery: TQuery;
    procedure CancelBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure ExecuteSQL;
    procedure FormCreate(Sender: TObject);
    procedure TypeGroupClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BtnBottomDlg: TBtnBottomDlg;

  fInsertResult : boolean;
  sLocalDB, sLocalTable, sLocalField : string;

function AlterTable(const sDB, sTableName, sNewField : string) : boolean;

implementation

uses
    SysUtils, Dialogs;

{$R *.DFM}

function AlterTable(const sDB, sTableName, sNewField : string) : boolean;
begin
     {this function runs the Add Field Form with appropriate init}

     sLocalDB := {ExtractFilePath}(sDB);
     sLocalTable := sTableName{ExtractFileName(sDB)};
     sLocalField := sNewField;
     fInsertResult := False;

     BtnBottomDlg := TBtnBottomDlg.Create(Application);

     BtnBottomDlg.ShowModal;
     BtnBottomDlg.Free;

     Result := fInsertResult;
end;

procedure TBtnBottomDlg.ExecuteSQL;
var
   sStatement : string;
begin
     sStatement := 'ALTER TABLE ' + Copy(sLocalTable,1,Length(sLocalTable)-4) + ' ADD ' +
                   EditName.Text + ' ' + 'SMALLINT'                        
                   {TypeGroup.Items.Strings[TypeGroup.ItemIndex]};

     (*
     if (TypeGroup.ItemIndex = 2) then
     {type is character and needs 1 parameter}
        sStatement := sStatement + '(' + IntToStr(SpinSize.Value) + ')'
     else
         sStatement := sStatement + '(' + IntToStr(SpinSize.Value) + ',' +
                       IntToStr(SpinDec.Value) + ')';
     *)

     MessageDlg(sStatement,mtInformation,[mbOk],0);


     AQuery.DatabaseName := sLocalDB;
     AQuery.SQL.Add(sStatement);
     AQuery.ExecSQL;

     fInsertResult := True;
end;


procedure TBtnBottomDlg.CancelBtnClick(Sender: TObject);
begin
     ModalResult := mrOk;
end;

procedure TBtnBottomDlg.OKBtnClick(Sender: TObject);
begin
     ExecuteSQL;
     ModalResult := mrOk;
end;

procedure TBtnBottomDlg.FormCreate(Sender: TObject);
begin
     Caption := 'Add Field to Table ' + sLocalTable;
     EditName.Text := sLocalField;
end;

procedure TBtnBottomDlg.TypeGroupClick(Sender: TObject);
begin
     if (TypeGroup.ItemIndex = 2) then
     begin
          Label3.Enabled := False;
          SpinDec.Enabled := False;
          SpinDec.Visible := False;
     end
     else
     begin
          Label3.Enabled := True;
          SpinDec.Enabled := True;
          SpinDec.Visible := True;
     end;
end;

end.
