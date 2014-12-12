unit reg_u1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FileCtrl, StdCtrls, Grids, Outline, DirOutln;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

function rtnVolumeSerialNumber(const DriveChar : char) : integer;
var
   pAddressOfSN : LPDWORD;
   NotUsed, VolFlags : integer;
begin
     GetVolumeInformation(PChar(DriveChar + ':\'),
                          nil,
                          0,
                          pAddressOfSN, {address of serial number}
                          NotUsed,
                          VolFlags,
                          nil,
                          0);

     Result := pAddressOfSN;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     Listbox1.Items.Add('c ' + IntToStr(rtnVolumeSerialNumber('c')));
     Listbox1.Items.Add('d ' + IntToStr(rtnVolumeSerialNumber('d')));
end;

end.
