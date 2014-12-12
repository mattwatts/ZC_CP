unit mvu1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, MPlayer, Buttons;

type
  TForm1 = class(TForm)
    MediaPlayer1: TMediaPlayer;
    procedure RadioGroup1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin
     MediaPlayer1.Enabled := False;
     
     MediaPlayer1.Filename := 'd:\video\lucy\' +
                              IntToStr(RadioGroup1.ItemIndex + 1) +
                              'convert.avi';

     MediaPlayer1.Enabled := True;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
     Application.Terminate;
end;

end.
