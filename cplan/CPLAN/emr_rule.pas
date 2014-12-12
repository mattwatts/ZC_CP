unit emr_rule;
// This unit calculates Effective Maximum Rarity (EMR) as defined
// by Bob Pressey.
// Author : Matt
// Date : 1st March 1999

// This is now calculated by GetRarity in arithrle.pas

interface

uses
    ds;

procedure CalculateEMR(SitesEMR : Array_T);

implementation

uses
    Control, Global;

procedure CalculateEMR(SitesEMR : Array_T);
begin
     try

     except {
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Calculate EMR',mtError,[mbOk],0);
           Application.Terminate;
           Exit; }
     end;
end;

end.
