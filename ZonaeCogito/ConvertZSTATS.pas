unit ConvertZSTATS;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBTables, Db, Buttons, StdCtrls, ExtCtrls;

type
  TConvertZSTATSForm = class(TForm)
    Label1: TLabel;
    EditInputPath: TEdit;
    btnBrowse: TButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Table1: TTable;
    Query1: TQuery;
    RadioConvertField: TRadioGroup;
    procedure ConvertZSTATSTables;
    procedure BitBtn1Click(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConvertZSTATSForm: TConvertZSTATSForm;

implementation

uses
    BrowseForFolderU, FileCtrl, SCP_Main, DBF_Child;

{$R *.DFM}

procedure TConvertZSTATSForm.ConvertZSTATSTables;
var
   FindResult : integer;
   SearchRec : TSearchRec;
   sOutputPath, sFieldname : string;
   ADBFChild : TDBFChild;
   iChildIndex : integer;
begin
     try
        // create output folder that is subdirectory of input folder
        sOutputPath := EditInputPath.Text + '\ZSTATS_convert';
        ForceDirectories(sOutputPath);

        sFieldname := RadioConvertField.Items.Strings[RadioConvertField.ItemIndex];

        // for each dbf table in the input folder
        FindResult := FindFirst(EditInputPath.Text + '\*.dbf', faAnyFile, SearchRec);
        while FindResult = 0 do
        begin
             if (Pos('.dbf',LowerCase(SearchRec.Name)) > 0) then
             begin
                  // load only the "VALUE" and "SUM" fields
                  SCPForm.MaskLoadZSTATSDBF(EditInputPath.Text + '\' + SearchRec.Name,sFieldname);
                  // save to DBF folder in output path
                  iChildIndex := SCPForm.ReturnNamedChildIndex(2,EditInputPath.Text + '\' + SearchRec.Name);
                  ADBFChild := TDBFChild(SCPForm.MDIChildren[iChildIndex]);
                  ADBFChild.DBGrid1.Visible := False;
                  try
                     ADBFChild.SaveZSTATSDBFChild2DBF(sOutputPath + '\' + SearchRec.Name,sFieldname);
                  except
                  end;
                  // close the file
                  ADBFChild.Free;
             end;

             FindResult := FindNext(SearchRec);
        end;
        FindClose(SearchRec);      

     except
     end;
end;

procedure TConvertZSTATSForm.BitBtn1Click(Sender: TObject);
begin
     ConvertZSTATSTables;
end;

procedure TConvertZSTATSForm.btnBrowseClick(Sender: TObject);
begin
     EditInputPath.Text := BrowseForFolder('Locate input folder','',False);
end;

end.
