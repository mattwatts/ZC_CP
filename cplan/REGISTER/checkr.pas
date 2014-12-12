unit checkr;

interface

uses
  {Windows,} Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, DB, DBTables;

type
  TDispenseForm = class(TForm)
    GroupBox1: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label8: TLabel;
    EditId: TEdit;
    EditUser: TEdit;
    EditInstCode: TEdit;
    CommentMemo: TMemo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    EditOrg: TEdit;
    UserTable: TTable;
    Label3: TLabel;
    Label6: TLabel;
    ComboProg: TComboBox;
    ComboVer: TComboBox;
    CreationQuery: TQuery;
    Label7: TLabel;
    EditEmail: TEdit;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure RegisterUser;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DispenseForm: TDispenseForm;

implementation

uses
    Reg, Global, displayrego;

{$R *.DFM}


procedure TDispenseForm.RegisterUser;
var
   sPath, sRegCode : string;
begin
     {add to the database and inform user of Registration Code}
     sRegCode := GenerateReg(EditInstCode.Text);

     DisplayRegoForm := TDisplayRegoForm.Create(Application);
     DisplayRegoForm.SetRegoCode(sRegCode);
     DisplayRegoForm.ShowModal;
     DisplayRegoForm.Free;
     //MessageDlg('Registration Code is ' + sRegCode,mtInformation,[mbOk],0);

     sPath := ExtractFilePath(Application.ExeName);
     if not FileExists(sPath + 'users.dbf') then
     begin
          // create a new table to store the user registry
          CreationQuery.SQL.Clear;
          CreationQuery.SQL.Add('create table "' + sPath + 'users.dbf"');
          CreationQuery.SQL.Add('(');
          CreationQuery.SQL.Add('USERID CHAR(200),');
          //CreationQuery.SQL.Add('USER_ CHAR(200),');
          //CreationQuery.SQL.Add('ORG CHAR(200),');
          CreationQuery.SQL.Add('DATE_ CHAR(200),');
          CreationQuery.SQL.Add('INSTCODE CHAR(200),');
          CreationQuery.SQL.Add('COMMENT CHAR(200),');
          CreationQuery.SQL.Add('PROGRAM CHAR(200),');
          CreationQuery.SQL.Add('VERSION CHAR(200)');
          CreationQuery.SQL.Add(')');
          CreationQuery.Prepare;
          CreationQuery.ExecSQL;
     end;
     UserTable.DatabaseName := sPath;
     UserTable.TableName := 'users.dbf';
     UserTable.Open;
     UserTable.Append;

     UserTable.FieldByName('USERID').AsString := EditId.Text;
     //UserTable.FieldByName('USER_').AsString := EditUser.Text;
     //UserTable.FieldByName('ORG').AsString := EditOrg.Text;
     UserTable.FieldByName('DATE_').AsString :=
                                     FormatDateTime('ddd mmm dd yyyy, hh:mm AM/PM',Now);
     UserTable.FieldByName('INSTCODE').AsString := EditInstCode.Text;
     UserTable.FieldByName('COMMENT').AsString := CommentMemo.Text;

     UserTable.FieldByName('PROGRAM').AsString := ComboProg.Text;
     UserTable.FieldByName('VERSION').AsString := ComboVer.Text;
     //UserTable.FieldByName('EMAIL').AsString := EditEmail.Text;

     UserTable.Post;
     UserTable.Close;

     {EditId.Text := '';
     EditUser.Text := '';
     EditOrg.Text := '';
     EditInstCode.Text := '';
     CommentMemo.Text := '';}
end;

procedure TDispenseForm.BitBtn1Click(Sender: TObject);
begin
     if {(EditId.Text <> '')
     and (EditUser.Text <> '')
     and (EditOrg.Text <> '')
     and} (EditInstCode.Text <> '')
     {and (ComboProg.Text <> '')} then
     begin
          {user has entered all required info}
          {generate user Registration Code and store record in database}
          RegisterUser;
     end
     else
     begin
          MessageDlg('You must enter User, Organisation, InstCode and Program to Register',
                     mtInformation,[mbOk],0);
     end;
end;

procedure TDispenseForm.BitBtn2Click(Sender: TObject);
begin
     Application.Terminate;
end;

procedure TDispenseForm.FormCreate(Sender: TObject);
begin
     {$IFDEF VER80}
     ComboProg.Text := 'C-Plan 16 bit';
     {$ELSE}
     ComboProg.Text := 'C-Plan 32 bit';
     {$ENDIF}

     //ComboVer.Text := CPLAN_VERSION;
     //ComboVer.Items.Add(CPLAN_VERSION);
end;

end.
