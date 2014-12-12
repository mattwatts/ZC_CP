unit SelectMapQuery;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBTables, Db, StdCtrls, Buttons, ExtCtrls,
  GIS;

type
  TMapQueryForm = class(TForm)
    TopPanel: TPanel;
    ListBoxFields: TListBox;
    LabelFields: TLabel;
    ListBoxValues: TListBox;
    Label2: TLabel;
    Table1: TTable;
    Query1: TQuery;
    CheckLoadValues: TCheckBox;
    BottomPanel: TPanel;
    MemoQuery: TMemo;
    btnNewSelection: TButton;
    btnAddToSelection: TButton;
    BitBtn1: TBitBtn;
    btnAddField: TButton;
    Operator: TRadioGroup;
    btnNot: TButton;
    btnOr: TButton;
    btnAnd: TButton;
    EditValue: TEdit;
    btnUndo: TButton;
    procedure PrepareQueryForm(Active_GIS_Child : TGIS_Child);
    procedure ListBoxReadFields;
    function ExecuteQuery(const fAddSelection : boolean) : boolean;
    procedure UpdateValueList;
    procedure CheckLoadValuesClick(Sender: TObject);
    procedure ListBoxFieldsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListBoxFieldsKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnAddFieldClick(Sender: TObject);
    procedure btnAndClick(Sender: TObject);
    procedure btnOrClick(Sender: TObject);
    procedure btnNotClick(Sender: TObject);
    procedure ListBoxValuesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListBoxValuesKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnUndoClick(Sender: TObject);
    procedure btnNewSelectionClick(Sender: TObject);
    procedure btnAddToSelectionClick(Sender: TObject);
    function AddQuoteIfStringField : string;
  private
    { Private declarations }
  public
    { Public declarations }
    MapChild : TGIS_Child;
  end;

var
  MapQueryForm: TMapQueryForm;

implementation


{$R *.DFM}

procedure TMapQueryForm.ListBoxReadFields;
var
   iCount : integer;
begin
     try
        ListBoxFields.Items.Clear;

        Table1.DatabaseName := ExtractFilePath(MapChild.sPuFileName);
        Table1.TableName := Copy(ExtractFileName(MapChild.sPuFileName),1,Length(ExtractFileName(MapChild.sPuFileName)) - Length(ExtractFileExt(ExtractFileName(MapChild.sPuFileName)))) + '.dbf';

        Table1.Open;
        // read the fields from the table
        for iCount := 0 to (Table1.FieldCount - 1) do
             ListBoxFields.Items.Add(Table1.FieldDefs.Items[iCount].Name);
        ListBoxFields.ItemIndex := 0;

        Table1.Close;

     except
           MessageDlg('Exception in Force_ZCSELECT_Field',mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMapQueryForm.UpdateValueList;
var
   sFieldName, sValue : string;
begin
     try
        ListBoxValues.Items.Clear;
        EditValue.Text := '';

        if CheckLoadValues.Checked then
        begin
             Table1.Open;

             ListBoxValues.Sorted := True;

             sFieldName := ListBoxFields.Items.Strings[ListBoxFields.ItemIndex];

             ListBoxValues.Items.Add(Table1.FieldByName(sFieldName).AsString);
             while not Table1.Eof do
             begin
                  Table1.Next;
                  sValue := Table1.FieldByName(sFieldName).AsString;
                  if (sValue <> '') then
                     if (ListBoxValues.Items.IndexOf(sValue) = -1) then
                        ListBoxValues.Items.Add(sValue);
             end;

             if (ListBoxValues.Items.Count > 0) then
             begin
                  EditValue.Text := ListBoxValues.Items.Strings[0];
                  ListBoxValues.ItemIndex := 0;
             end;

             Table1.Close;
        end;

     except
           MessageDlg('Exception in UpdateValueList',mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

procedure TMapQueryForm.PrepareQueryForm(Active_GIS_Child : TGIS_Child);
begin
     try
        MapChild := Active_GIS_Child;

        MapChild.Force_ZCSELECT_Field(True);
        ListBoxReadFields;
        UpdateValueList;

        MemoQuery.Lines.Clear;
        //MemoQuery.Lines.Add('Select ZCSELECT from "' + MapChild.sShapeFileName + '" where');

     except
           MessageDlg('Exception in PrepareQueryForm',mtInformation,[mbOk],0);
           Application.Terminate;
     end;
end;

function TMapQueryForm.ExecuteQuery(const fAddSelection : boolean) : boolean;
var
   iCount, iShapeIndex : integer;
   fEnd, fSelection, fResult : boolean;
begin
     try
        fResult := True;
        Query1.SQL.Clear;
        Query1.SQL.Add('Select ZCSELECT from "' + Table1.DatabaseName + Table1.TableName + '" where');
        for iCount := 1 to MemoQuery.Lines.Count do
            Query1.SQL.Add(MemoQuery.Lines.Strings[iCount-1]);
        //Query1.SQL.SaveToFile(ExtractFilePath(MapChild.sPuFileName) + '\select_query.txt');

        Query1.Open;

        try
           if not MapChild.fShapeSelection then
                  MapChild.InitShapeSelection
           else
               if not fAddSelection then
                      MapChild.InitShapeSelection;

           fSelection := True;
           fEnd := False;
           while (not fEnd) do
           begin
                iShapeIndex := Query1.FieldByName('ZCSELECT').AsInteger;

                if (iShapeIndex = 0) then
                begin
                     fEnd := True;
                     MessageDlg('No shapes returned by query',mtInformation,[mbOk],0);
                end
                else
                begin
                     MapChild.ShapeSelection.setValue(iShapeIndex,@fSelection);

                     Query1.Next;

                     if Query1.EOF then
                        fEnd := True;
                end;
           end;

        except
              fResult := False;
              MessageDlg('No shapes returned by query',mtInformation,[mbOk],0);
        end;

        Query1.Close;

        MapChild.RedrawSelection;

     except
           fResult := False;
           MessageDlg('Invalid query entered',mtInformation,[mbOk],0);
     end;

     Result := fResult;
end;

procedure TMapQueryForm.CheckLoadValuesClick(Sender: TObject);
begin
     UpdateValueList;
end;

procedure TMapQueryForm.ListBoxFieldsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     UpdateValueList;
end;

procedure TMapQueryForm.ListBoxFieldsKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     UpdateValueList;
end;

function TMapQueryForm.AddQuoteIfStringField : string;
begin
     //
     //Query1.Fields.Fields[ListBoxFields.ItemIndex].DataType

     //if (Query1.FieldDefs.Items[ListBoxFields.ItemIndex].DataType = ftString) then
     Table1.Open;

     //Table1.FieldDefs.Items[ListBoxFields.ItemIndex].Name
     if (Table1.FieldDefs.Items[ListBoxFields.ItemIndex].DataType = ftString) then
        Result := '"' + EditValue.Text + '"'
     else
         Result := EditValue.Text;

     Table1.Close;
end;

procedure TMapQueryForm.btnAddFieldClick(Sender: TObject);
begin
     MemoQuery.Lines.Add('(' + ListBoxFields.Items.Strings[ListBoxFields.ItemIndex] + ' ' +
                         Operator.Items.Strings[Operator.ItemIndex] + ' ' +
                         AddQuoteIfStringField + ')');
end;

procedure TMapQueryForm.btnAndClick(Sender: TObject);
begin
     MemoQuery.Lines.Add('and');
end;

procedure TMapQueryForm.btnOrClick(Sender: TObject);
begin
     MemoQuery.Lines.Add('or');
end;

procedure TMapQueryForm.btnNotClick(Sender: TObject);
begin
     MemoQuery.Lines.Add('not');
end;

procedure TMapQueryForm.ListBoxValuesMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     try
        if (ListBoxValues.Items.Count > 0) then
           EditValue.Text := ListBoxValues.Items.Strings[ListBoxValues.ItemIndex];

     except
           EditValue.Text := '';
     end;
end;

procedure TMapQueryForm.ListBoxValuesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     try
        if (ListBoxValues.Items.Count > 0) then
           EditValue.Text := ListBoxValues.Items.Strings[ListBoxValues.ItemIndex];
           
     except
           EditValue.Text := '';
     end;
end;

procedure TMapQueryForm.btnUndoClick(Sender: TObject);
begin
     if MemoQuery.Lines.Count > 1 then
        MemoQuery.Lines.Delete(MemoQuery.Lines.Count-1);
end;

procedure TMapQueryForm.btnNewSelectionClick(Sender: TObject);
begin
     if ExecuteQuery(False) then
        ModalResult := mrOk;
end;

procedure TMapQueryForm.btnAddToSelectionClick(Sender: TObject);
begin
     if ExecuteQuery(True) then
        ModalResult := mrOk;
end;

end.
