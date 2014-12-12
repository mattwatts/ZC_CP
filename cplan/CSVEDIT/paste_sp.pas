unit paste_sp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons,
  Childwin;

type
  TPasteSpecialForm = class(TForm)
    btnPaste: TBitBtn;
    BitBtn2: TBitBtn;
    CheckTranspose: TCheckBox;
    procedure btnPasteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PasteSpecialForm: TPasteSpecialForm;
  PasteSpecialChild : TMDIChild;
  
implementation

uses
    main;

{$R *.DFM}

procedure TPasteSpecialForm.btnPasteClick(Sender: TObject);
begin
     // paste clipboard to grid

     PasteClipboardToSelection(PasteSpecialChild.aGrid,
                               CheckTranspose.Checked);
     PasteSpecialChild.fDataHasChanged := True;
end;

end.
