unit chooseoc;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TOrdClassForm = class(TForm)
    FieldList: TListBox;
    btnUseClass: TBitBtn;
    btnUsePreviousClass: TBitBtn;
    Label1: TLabel;
    btnUseNoClass: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FieldListClick(Sender: TObject);
    procedure btnUseClassClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OrdClassForm: TOrdClassForm;

implementation

uses Control;

{$R *.DFM}

procedure TOrdClassForm.FormCreate(Sender: TObject);
var
   fStop : boolean;
   iCount : integer;
   sField : string;
begin
     {load fields from the Feature Summary Table to FieldList}
     {attempt to open feature summary table}
     FieldList.Items.Clear;
     fStop := False;

     try
        ControlForm.CutOffTable.Open;
     except
           fStop := True;
           MessageDlg('Cannot open Feature Summary Table',mtInformation,[mbOk],0);
     end;

     try
        if not fStop then
        begin
             for iCount := 0 to (ControlForm.CutOffTable.FieldDefs.Count-1) do
             begin
                  sField := ControlForm.CutOffTable.FieldDefs.Items[iCount].Name;

                  if (sField <> ControlRes^.sFeatureKeyField)
                  and (sField <> 'FEATNAME')
                  and (sField <> 'ITARGET')
                  and (sField <> 'EXTANT')
                  and (sField <> 'VULN')
                  and (sField <> 'SRADIUS')
                  and (sField <> 'CONPATCH') then
                      FieldList.Items.Add(sField);
             end;

             if (FieldList.Items.Count > 0) then
                FieldList.ItemIndex := 0;

             ControlForm.CutOffTable.Close;
        end;

     except
           MessageDlg('Exception in loading Feature Summary Table field names',mtError,[mbOk],0);
     end;
end;

procedure TOrdClassForm.FieldListClick(Sender: TObject);
begin
     btnUseClass.Enabled := True;
end;

procedure TOrdClassForm.btnUseClassClick(Sender: TObject);
begin
     // ControlForm.S1.Visible := True;
end;

end.
