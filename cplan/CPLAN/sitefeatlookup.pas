unit sitefeatlookup;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, Grids;

type
  TSiteFeatLookupForm = class(TForm)
    TopPanel: TPanel;
    btnOK: TBitBtn;
    btnCopy: TButton;
    btnFields: TButton;
    VisibleCodes: TListBox;
    btnAccept: TButton;
    c: TButton;
    t: TButton;
    LocalClick: TRadioGroup;
    btnAutoFit: TButton;
    btnSave: TButton;
    StringGrid1: TStringGrid;
    Splitter1: TSplitter;
    StringGrid2: TStringGrid;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SiteFeatLookupForm: TSiteFeatLookupForm;

implementation

{$R *.DFM}


end.
