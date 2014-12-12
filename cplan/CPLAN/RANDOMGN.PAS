unit Randomgn;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Spin,
  {$IFDEF VER90}
  Dll_u1;
  {$ELSE}
  Cpng_imp;
  {$ENDIF}

const
     RANDOM_SEL = 100;
     RANDOM_MAN = 101;
     RANDOM_BOTH = 102;

type
  TRandomGen = class(TForm)
    SelectedGroup: TGroupBox;
    MandatoryGroup: TGroupBox;
    SelSpin: TSpinEdit;
    ManSpin: TSpinEdit;
    Button1: TButton;
    GroupBox1: TGroupBox;
    ExcSpin: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure SelectedGroupDblClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure MandatoryGroupDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RandomGen: TRandomGen;
  wLocalFlag : word;


procedure RandomSelection(const wControlFlag : word);
{activates Form}


implementation

uses Control, Em_newu1;

{$R *.DFM}

procedure SelOff;
begin
     with RandomGen do
     begin
          {SelectedGroup.Enabled := False;}
          SelSpin.MaxValue := 0;
          SelSpin.MinValue := 0;
          SelSpin.Value := 0;
          SelSpin.Visible := False;
     end;
end;

procedure SelOn;
begin
     with RandomGen do
     begin
          {SelectedGroup.Enabled := True;}
          SelSpin.Enabled := True;
          SelSpin.Visible := True;
          SelSpin.MaxValue := ControlForm.AvailableGeocode.Items.Count;
          SelSpin.MinValue := 0;
          if (iRandomSel > SelSpin.MaxValue) or (iRandomSel < SelSpin.MinValue) then
          begin
               iRandomSel := SelSpin.MinValue;
               SelSpin.Value := SelSpin.MinValue;
          end
          else
              SelSpin.Value := iRandomSel;

          if (SelSpin.MaxValue = 0) then
             {SelOff};
     end;
end;

procedure ManOff;
begin
     with RandomGen do
     begin
          {MandatoryGroup.Enabled := False;}
          ManSpin.Enabled := False;
          ManSpin.MaxValue := 0;
          ManSpin.MinValue := 0;
          ManSpin.Value := 0;
          ManSpin.Visible := False;
     end;
end;

procedure ManOn;
begin
     with RandomGen do
     begin
          {MandatoryGroup.Enabled := True;}
          ManSpin.Enabled := True;
          ManSpin.Visible := True;

          ManSpin.MaxValue := ControlForm.AvailableGeocode.Items.Count;
          ManSpin.MinValue := 0;
          if (iRandomSel > ManSpin.MaxValue) or (iRandomSel < ManSpin.MinValue) then
          begin
               iRandomSel := ManSpin.MinValue;
               ManSpin.Value := ManSpin.MinValue;
          end
          else
              ManSpin.Value := iRandomSel;

          if (ManSpin.MaxValue = 0) then
             {ManOff};
     end;
end;



procedure RandomSelection(const wControlFlag : word);
begin
     try
        RandomGen := TRandomGen.Create(Application);

        wLocalFlag := wControlFlag;

        (*
        case wLocalFlag of
        {set initial states for the form}
             RANDOM_SEL : begin SelOn; ManOff; end;
             RANDOM_MAN : begin ManOn; SelOff; end;
             RANDOM_BOTH : begin SelOn; ManOn; end;
             (RANDOM_SEL + RANDOM_MAN) : begin SelOn; ManOn; end;
        else
            MessageDlg('Unknown ControlFlag for RandomSelection',
                       mtError,[mbOK],0);
        end;
        *)

        RandomGen.ShowModal;

     finally
            RandomGen.Free;
     end;
end;

procedure TRandomGen.Button1Click(Sender: TObject);
var
   iTmp : integer;
begin
     Randomize;

     if (SelSpin.Value > 0) then
     begin
          UnHighlight(ControlForm.Available);
          {unhighlight all items in the Available listbox}

          repeat
               {select some random sites in the Available listbox}
               iTmp := Random(ControlForm.AvailableGeocode.Items.Count);
               if (iTmp >= 0) and (iTmp < ControlForm.Available.Items.Count) then
                  ControlForm.Available.Selected[iTmp] := True
               else SelSpin.Value := 0;

          until (ControlForm.Available.SelCount >= SelSpin.Value);

          ControlForm.MoveGroup(ControlForm.Available,ControlForm.AvailableGeocode,
                                ControlForm.Negotiated,ControlForm.NegotiatedGeocode,TRUE);
     end;

     {Randomize;}

     if (ManSpin.Value > 0) then
     begin
          UnHighlight(ControlForm.Available);

          repeat
                iTmp := Random(ControlForm.AvailableGeocode.Items.Count);

                if (iTmp >= 0) and (iTmp < ControlForm.Available.Items.Count) then
                   ControlForm.Available.Selected[iTmp] := True
                else ManSpin.Value := 0;
          until (ControlForm.Available.SelCount >= ManSpin.Value);

          ControlForm.MoveGroup(ControlForm.Available,ControlForm.AvailableGeocode,
                                ControlForm.Mandatory,ControlForm.MandatoryGeocode,TRUE);
     end;
     if (ExcSpin.Value > 0) then
     begin
          UnHighlight(ControlForm.Available);
          repeat
                iTmp := Random(ControlForm.AvailableGeocode.Items.Count);

                if (iTmp >= 0) and (iTmp < ControlForm.Available.Items.Count) then
                   ControlForm.Available.Selected[iTmp] := True
                else ExcSpin.Value := 0;
          until (ControlForm.Available.SelCount >= ExcSpin.Value);

          ControlForm.MoveGroup(ControlForm.Available,ControlForm.AvailableGeocode,
                                ControlForm.Excluded,ControlForm.ExcludedGeocode,TRUE);
     end;

     ModalResult := mrOK;

end;

procedure TRandomGen.SelectedGroupDblClick(Sender: TObject);
begin
     {toggle activation of random Selected sites}
     if SelSpin.Visible then
        SelOn
     else
         SelOff
end;

procedure TRandomGen.FormActivate(Sender: TObject);
begin
     SelSpin.MaxValue := ControlForm.Available.Items.Count div 3;

     ManSpin.Enabled := True;
     ExcSpin.Enabled := True;
     ManSpin.MaxValue := SelSpin.MaxValue;
     ExcSpin.MaxValue := SelSpin.MaxValue;
end;

procedure TRandomGen.MandatoryGroupDblClick(Sender: TObject);
begin
     {toggle activation of random Mandatory sites}
     if ManSpin.Visible then
        ManOn
     else
         ManOff;
end;

end.
