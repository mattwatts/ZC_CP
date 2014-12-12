program Edit_dBase;

uses
  Forms,
  db_edit in 'db_edit.pas' {Edit_dBaseForm},
  Unit1 in 'Unit1.pas' {DataModule1: TDataModule},
  Unit2 in 'Unit2.pas' {Form2};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.Run;
end.
