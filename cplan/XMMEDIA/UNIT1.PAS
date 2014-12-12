unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OleCtnrs, ExtCtrls, MPlayer;

type
  TForm1 = class(TForm)
    MediaPlayer1: TMediaPlayer;
    Timer1: TTimer;
    OleContainer1: TOleContainer;
    ImageList1: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

end.
