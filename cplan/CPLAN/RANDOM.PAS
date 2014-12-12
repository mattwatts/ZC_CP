unit Random;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Spin;

const
     RANDOM_SEL = 100;
     RANDOM_MAN = 101;
     RANDOM_BOTH = 102;

type
  TRandomGen = class(TForm)
    GroupBox1: TGroupBox;
    Mandatory: TGroupBox;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RandomGen: TRandomGen;


procedure RandomSelection(const iControlFlag : integer);
{activates Form}


implementation

{$R *.DFM}

procedure RandomSelection(const iControlFlag : integer);
begin



     case iControlFlag of
          RANDOM_SEL : ;
          RANDOM_MAN : ;
          RANDOM_BOTH : ;
     else
         MessageDlg('Unknown ControlFlag for RandomSelection',mtError,[mbOK],0);
     end;

     try
        RandomGen := TRandomGen.Create(Application);

        RandomGen.ShowModal;

     finally
            RandomGen.Free;
     end;
end;

end.
