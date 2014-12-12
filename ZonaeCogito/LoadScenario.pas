unit LoadScenario;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TLoadScenarioForm = class(TForm)
    Panel1: TPanel;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    ScenarioListBox: TListBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LoadScenarioForm: TLoadScenarioForm;

implementation

uses Marxan_interface, Inifiles;

{$R *.DFM}

procedure TLoadScenarioForm.FormCreate(Sender: TObject);
var
   ScenarioIni : TIniFile;
   sBaseDirectory : string;
begin
     try
        // load scenarios to the listbox
        sBaseDirectory := ExtractFilePath(MarxanInterfaceForm.EditMarxanDatabasePath.Text);
        ScenarioIni := TIniFile.Create(sBaseDirectory + 'scenarios.ini');
        ScenarioListBox.Items.Clear;

        ScenarioIni.ReadSection('Scenario',ScenarioListBox.Items);

        if (ScenarioListBox.Items.Count > 0) then
        begin
             ScenarioListBox.MultiSelect := False;
             ScenarioListBox.ItemIndex := 0;
        end;

     except
           MessageDlg('Exception loading Scenario',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

end.
