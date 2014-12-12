unit EasyEditTargets;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ExtCtrls, StdCtrls, Buttons, Db, DBTables;

type
  TEasyEditTargetsForm = class(TForm)
    Panel1: TPanel;
    StringGrid1: TStringGrid;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    Table1: TTable;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EasyEditTargetsForm: TEasyEditTargetsForm;

implementation

uses
    global, control, auto_fit;

{$R *.DFM}

procedure TEasyEditTargetsForm.FormCreate(Sender: TObject);
var
   iCount : integer;
   pFeat : featureoccurrencepointer;
begin
     // populate the grid with feature names, ids and targets
     with StringGrid1 do
     try
        RowCount := iFeatureCount + 1;
        Cells[0,0] := 'Feature Name'; // [col,row]
        Cells[1,0] := 'Feature Id';
        Cells[2,0] := 'Target';

        new(pFeat);
        Table1.DatabaseName := ControlRes^.sDatabase;
        Table1.TableName := ControlRes^.sFeatCutOffsTable;
        Table1.Open;
        // load the feature targets from the feature table
        for iCount := 1 to iFeatureCount do
        begin
             FeatArr.rtnValue(iCount,pFeat);

             Cells[0,iCount] := pFeat^.sID;
             Cells[1,iCount] := IntToStr(pFeat^.code);
             Cells[2,iCount] := Table1.FieldByName(ControlRes^.sFeatureTargetField).AsString;
             Table1.Next;
        end;
        Table1.Close;
        dispose(pFeat);

        AutoFitGrid(StringGrid1,Canvas,True);

        // switch on grid editing
        if goEditing in StringGrid1.Options then
           StringGrid1.Options := [goFixedVertLine,goFixedHorzLine,goVertLine,
                                   goHorzLine,goRangeSelect,goColSizing,goRowSizing,
                                   goColMoving,goRowMoving]
        else
            StringGrid1.Options := [goFixedVertLine,goFixedHorzLine,goVertLine,
                                    goHorzLine,goRangeSelect,goColSizing,goRowSizing,
                                    goColMoving,goRowMoving,goEditing];

     except
     end;
end;

end.
