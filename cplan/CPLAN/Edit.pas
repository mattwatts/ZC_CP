unit Edit;

{$I STD_DEF.PAS}

(*{$DEFINE DUBUGEDIT}*)
{$UNDEF DEBUGEDIT}


interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  StdCtrls, Forms, DBCtrls, DB, DBTables, Mask, ExtCtrls, Buttons,
  {$IFDEF bit16}
  Arrayt16;
  {$ELSE}
  ds;
  {$ENDIF}

type
  TEditForm = class(TForm)
    ScrollBox: TScrollBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    DBNavigator: TDBNavigator;
    Panel1: TPanel;
    Panel2: TPanel;
    Table1: TTable;
    BitBtn1: TBitBtn;
    EditTarget: TEdit;
    lblName: TLabel;
    lblID: TLabel;
    DataSource1: TDataSource;
    BitBtn2: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure DBNavigatorClick(Sender: TObject; Button: TNavigateBtn);
    procedure BitBtn1Click(Sender: TObject);
    procedure DataSource1UpdateData(Sender: TObject);
    procedure EditTargetChange(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  EditForm: TEditForm;
  fEditTargets : boolean;
  OldTargetArr : Array_t;

implementation

uses Control, Dialogs;

{$R *.DFM}

procedure TEditForm.FormCreate(Sender: TObject);
var
   rValue : real;
   iElement : integer;
begin
     {TrimPathFile(ImportForm.txtFeatTable.Text,sDBPath,sDBFile);}
     Table1.DatabaseName := ControlRes^.sDatabase;
     Table1.TableName := ControlRes^.sFeatCutOffsTable;

     Caption := 'Edit ' + ControlRes^.sFeatureTargetField + ' target field in ' + ControlRes^.sFeatCutOffsTable;

     try
        Table1.Open;

        lblID.Caption := Table1.FieldByName(ControlRes^.sFeatureKeyField).AsString;
        lblName.Caption := Table1.FieldByName('FEATNAME').AsString;
        EditTarget.Text := Table1.FieldByName(ControlRes^.sFeatureTargetField).AsString;
        Label3.Caption := ControlRes^.sFeatureTargetField;

     except
           Label2.Caption := 'CODE';
           Label3.Caption := 'CUTOFF';

           lblID.Caption := Table1.FieldByName(ControlRes^.sFeatureKeyField).AsString;
           lblName.Caption := Table1.FieldByName(Label2.Caption).AsString;
           EditTarget.Text := Table1.FieldByName(Label3.Caption).AsString;

           {Screen.Cursor := crDefault;
           MessageDlg('Exception in TEditForm.FormCreate',mtError,[mbOk],0);}
     end;

     {store the old target values in an array in case user clicks cancel}
     OldTargetArr := Array_t.Create;
     OldTargetArr.init(SizeOf(real),Table1.RecordCount);

     iElement := 1;
     repeat
           rValue := Table1.FieldByName(Label3.Caption).AsFloat;
           OldTargetArr.setValue(iElement,@rValue);

           Inc(iElement);
           Table1.Next;

     until (iElement > Table1.RecordCount);

     Table1.Close;
     Table1.Open;
end;

procedure TEditForm.DBNavigatorClick(Sender: TObject;
  Button: TNavigateBtn);
begin
     lblID.Caption := Table1.FieldByName(ControlRes^.sFeatureKeyField).AsString;
     lblName.Caption := Table1.FieldByName(Label2.Caption).AsString;
     EditTarget.Text := Table1.FieldByName(Label3.Caption).AsString;
end;

procedure TEditForm.BitBtn1Click(Sender: TObject);
begin
     EditTargetChange(self);
end;

procedure TEditForm.DataSource1UpdateData(Sender: TObject);
begin
    MessageDlg('DataSource1UpdateData',mtInformation,[mbOk],0);
end;

procedure TEditForm.EditTargetChange(Sender: TObject);
var
   rValue : extended;
begin
     rValue := -1;
     try
        rValue := RegionSafeStrToFloat(EditTarget.Text);

        if (rValue >= 0) then
        begin
             Table1.Edit;
             Table1.FieldByName(Label3.Caption).AsFloat := rValue;
             Table1.Post;
        end;

     except
     end;
end;

procedure TEditForm.BitBtn2Click(Sender: TObject);
var
   iElement : integer;
   rValue : real;
begin
     {write values back to the file, indicate targets have not changed}
     Table1.Close;
     Table1.Open;

     iElement := 1;

     repeat
           OldTargetArr.rtnValue(iElement,@rValue);
           Table1.Edit;
           Table1.FieldByName(label3.caption).AsFloat := rValue;
           Table1.Next;

           Inc(iElement);

     until (iElement > Table1.RecordCount);
end;

procedure TEditForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     OldTargetArr.Destroy;
end;

end.
