program viewer;

uses
  Forms,
  viewu1 in 'viewu1.pas' {Form1},
  ViewU2 in 'ViewU2.pas' {Form2};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
