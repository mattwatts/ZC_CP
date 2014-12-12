unit strip;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

procedure StripAsciiFromBinaryFile(const sInputFile, sOutputFile : string);


implementation

{$R *.DFM}

procedure StripAsciiFromBinaryFile(const sInputFile, sOutputFile : string);
begin
     //
end;

end.
