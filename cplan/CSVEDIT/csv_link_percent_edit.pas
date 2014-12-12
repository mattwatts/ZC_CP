unit csv_link_percent_edit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, ExtCtrls, Buttons;

type
  TCSVLinkEdit = class(TForm)
    RadioProportion: TRadioGroup;
    SpinPercent: TSpinEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    lblFile: TLabel;
    procedure SpinPercentChange(Sender: TObject);
    procedure RadioProportionClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CSVLinkEdit: TCSVLinkEdit;

implementation

{$R *.DFM}

procedure TCSVLinkEdit.SpinPercentChange(Sender: TObject);
var
   iItemIndex : integer;
begin
     //
     iItemIndex := RadioProportion.ItemIndex;
     RadioProportion.Items.Delete(0);
     RadioProportion.Items.Insert(0,IntToStr(SpinPercent.Value) + ' Percent');
     RadioProportion.ItemIndex := iItemIndex;
end;

procedure TCSVLinkEdit.RadioProportionClick(Sender: TObject);
begin
     if (RadioProportion.ItemIndex = 0) then
        SpinPercent.Enabled := True
     else
         SpinPercent.Enabled := False;
end;

end.
