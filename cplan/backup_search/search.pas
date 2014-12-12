unit search;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, Outline, DirOutln, StdCtrls, Buttons, FileCtrl;

type
  TSelectFilesForm = class(TForm)
    DriveComboBox1: TDriveComboBox;
    DirectoryListBox1: TDirectoryListBox;
    FileListBox1: TFileListBox;
    FilterComboBox1: TFilterComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label4: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SelectFilesForm: TSelectFilesForm;

implementation

{$R *.DFM}


{
 NULL = 0 = 8482816

 CR = 13 = 8482829


 LF = 10 = 8482826


(Rows 14,15,16)

8483584
8483597
8483594

8483840
8483853
8483850

8488960
8488973
8488970

}

end.
