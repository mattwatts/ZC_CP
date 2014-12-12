unit Change_status;

interface

uses
  GIS, Marxan_interface,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TChangeStatusForm = class(TForm)
    RadioAction: TRadioGroup;
    BitBtnOk: TBitBtn;
    BitBtn2: TBitBtn;
    procedure PrepareForm;
    procedure BitBtnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    GChild : TGIS_Child;
    MChild : TMarxanInterfaceForm;
  end;

var
  ChangeStatusForm: TChangeStatusForm;

implementation

{$R *.DFM}

procedure TChangeStatusForm.PrepareForm;
var
   iCount : integer;
begin
     // iNumberOfZones
     RadioAction.Items.Clear;
     RadioAction.Items.Add('Database lookup');
     RadioAction.Items.Add('Mark as "Not selected"');

     for iCount := 1 to iNumberOfZones do
         RadioAction.Items.Add('Move to "' + MChild.ReturnZoneName(iCount) + '"');
end;

procedure TChangeStatusForm.BitBtnOkClick(Sender: TObject);
begin
     case RadioAction.ItemIndex of
          0 : GChild.LookupSelectedPlanningUnits(MChild);
          1 : GChild.DeselectSelectedPlanningUnits(MChild);
     else
         GChild.MoveSelectedPlanningUnits(RadioAction.ItemIndex-1,MChild);
     end;
end;

end.
