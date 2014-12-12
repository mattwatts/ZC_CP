unit NewConfiguration;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TNewConfigurationForm = class(TForm)
    Label1: TLabel;
    EditConfigurationName: TEdit;
    Label2: TLabel;
    ComboSeedConfiguration: TComboBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure LoadSeedConfigurations;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewConfigurationForm: TNewConfigurationForm;

implementation

uses GIS, inifiles, Marxan_interface, EditConfigurations;

{$R *.DFM}

procedure TNewConfigurationForm.LoadSeedConfigurations;
var
   AIni : TIniFile;
   iCount : integer;
begin
     AIni := TIniFile.Create(ExtractFilePath(GIS_Child.sPuFileName) + 'configurations.ini');

     AIni.ReadSectionValues('Configurations',ComboSeedConfiguration.Items);

     AIni.Free;

     for iCount := iNumberOfRuns downto 1 do
         ComboSeedConfiguration.Items.Insert(0,'Marxan Solution ' + IntToStr(iCount));

     ComboSeedConfiguration.Items.Insert(0,'Marxan Best Solution');
     ComboSeedConfiguration.Items.Insert(0,'Marxan initial configuration');
     ComboSeedConfiguration.Items.Insert(0,'Blank configuration');

     ComboSeedConfiguration.Text := ComboSeedConfiguration.Items.Strings[0];
end;

procedure TNewConfigurationForm.FormCreate(Sender: TObject);
begin
     LoadSeedConfigurations;
end;

procedure TNewConfigurationForm.BitBtn1Click(Sender: TObject);
var
   fNameInUse : boolean;
begin
     if (EditConfigurationName.Text <> '') then
     begin
          fNameInUse := False;
          if (EditConfigurationsForm <> nil) then
             if (EditConfigurationsForm.ListBoxPUConfiguration.Items.Count > 0) then
                if (EditConfigurationsForm.ListBoxPUConfiguration.Items.IndexOf(EditConfigurationName.Text) > -1) then
                   fNameInUse := True;

          if fNameInUse then
             MessageDlg('Configuration name already in use, please enter a different name',mtInformation,[mbOk],0)
          else
              ModalResult := mrOk;
     end;
end;

end.
