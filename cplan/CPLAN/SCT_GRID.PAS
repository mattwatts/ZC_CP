unit Sct_grid;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, ExtCtrls, StdCtrls, Buttons;

type
  TSelectGridForm = class(TForm)
    Panel1: TPanel;
    ABox: TListBox;
    btnChoose: TButton;
    btnOK: TBitBtn;
    procedure FormActivate(Sender: TObject);
    procedure btnChooseClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SelectGridForm: TSelectGridForm;
  iNumColumns, iFieldLen : integer;


function ExtractCode(const sText : string;
                     const iFieldLen, iKeyField : integer) : string;
function ExtractCodeRight(const sText : string;
                          const iFieldLen : integer) : string;
function BuildField(const sText : string;
                    const iWidthToFit : integer) : string;


implementation

uses Em_newu1;

{$R *.DFM}

function ExtractCode(const sText : string;
                     const iFieldLen, iKeyField : integer) : string;
var
   iEnd,iStart : integer;
begin
     try
        Result := Copy(sText,((iKeyField-1)*iFieldLen)+1,iFieldLen);

        iEnd := Length(Result);
        while (Result[iEnd] = ' ')
        and (iEnd > 1) do
            Dec(iEnd);
        {trim trailing spaces}

        iStart := 1;
        while (Result[iStart] = ' ')
        and (iStart < iEnd) do
            Inc(iStart);
        {trim leading spaces}

        if (iEnd >= iStart) then
           Result := Copy(Result,iStart,iEnd-iStart+1);

     except on exception do
            MessageDlg('exception in ExtractCode',mtError,[mbOK],0);
     end;
end;

function ExtractCodeRight(const sText : string;
                          const iFieldLen : integer) : string;
var
   iEnd,iStart : integer;
begin
     try
        Result := Copy(sText,iFieldLen+1,Length(sText)-iFieldLen);

        iEnd := Length(Result);
        while (Result[iEnd] = ' ')
        and (iEnd > 1) do
            Dec(iEnd);
        {trim trailing spaces}

        iStart := 1;
        while (Result[iStart] = ' ')
        and (iStart < iEnd) do
            Inc(iStart);
        {trim leading spaces}

        if (iEnd >= iStart) then
           Result := Copy(Result,iStart,iEnd-iStart+1);

     except on exception do
            MessageDlg('exception in ExtractCode',mtError,[mbOK],0);
     end;
end;

function BuildField(const sText : string;
                    const iWidthToFit : integer) : string;
var
   iCount : integer;
begin
     if (iWidthToFit > Length(sText)) then
     begin
          {field is shorter than space available}

          Result := sText;

          for iCount := Length(sText) + 1 to iWidthToFit do
              Result := Result + ' ';
              {append spaces to match length iWidthToFit}
     end
     else
     begin
          {field is wider than or equal to space available}

          Result := Copy(sText,1,iWidthToFit);
     end;
end;

procedure TSelectGridForm.FormActivate(Sender: TObject);
var
   iCount,
   iCharSize, iNumCharsWide : integer;

   sALine : string;
begin
     iNumColumns := 3;

     iCharSize := Canvas.TextWidth(' ');
     iNumCharsWide := ClientWidth div iCharSize;
     iFieldLen := (iNumCharsWide div iNumColumns) -1;

     if (iFieldLen > 0) then
     begin
          for iCount := 1 to 30 do
          begin
               sALine := BuildField(IntToStr(iCount) + 'first',iFieldLen) +
                         ' ' +
                         BuildField(IntToStr(iCount) + 'thisisareallylongstring...........',
                         iFieldLen) +
                         ' ' +
                         BuildField(IntToStr(iCount) + 'third',iFieldLen);

               ABox.Items.Add(sALine);
          end;
     end;
end;

procedure TSelectGridForm.btnChooseClick(Sender: TObject);
var
   iCount : integer;
   sText : string;
begin
     if (ABox.SelCount > 0) then
        for iCount := 0 to (ABox.Items.Count-1) do
            if ABox.Selected[iCount] then
            begin
                 sText := ABox.Items.Strings[iCount];
                 sText := ExtractCode(sText,iFieldLen,1);
            end;
end;

procedure TSelectGridForm.btnOKClick(Sender: TObject);
begin
     ModalResult := mrOK;
end;

end.
