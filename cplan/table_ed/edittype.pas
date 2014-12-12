unit edittype;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, ExtCtrls, Grids, Buttons,
  Childwin;

type
  TEditTypeForm = class(TForm)
    FieldGrid: TStringGrid;
    EditPanel: TPanel;
    DataTypeGroup: TRadioGroup;
    Label1: TLabel;
    Label2: TLabel;
    SpinFirst: TSpinEdit;
    SpinSecond: TSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    EditName: TEdit;
    Label5: TLabel;
    procedure FieldGridSelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure initchild(Child : TMDIChild);
    procedure UpdateTypes(Child : TMDIChild);
    procedure FieldGridRowMoved(Sender: TObject; FromIndex,
      ToIndex: Integer);
    procedure EditNameChange(Sender: TObject);
    procedure DataTypeGroupClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    fChange : boolean;
  end;

var
  EditTypeForm: TEditTypeForm;

implementation

uses
    Global;

{$R *.DFM}

procedure TEditTypeForm.initchild(Child : TMDIChild);
var
   iCount : integer;
   AType : FieldDataType_T;
begin
     try
        Caption := 'Field Properties for ' + Child.Caption;

        {init grid}
        FieldGrid.Cells[0,0] := 'Name';
        FieldGrid.Cells[1,0] := 'Type';
        FieldGrid.Cells[2,0] := 'Digits';
        FieldGrid.Cells[3,0] := 'Float';
        {display the childs fields in the grid}
        FieldGrid.RowCount := Child.DataFieldTypes.lMaxSize + 1;
        for iCount := 1 to Child.DataFieldTypes.lMaxSize do
        begin
             {return this type and write its attributes to the appropriate row}
             Child.DataFieldTypes.rtnValue(iCount,@AType);

             {field name}
             FieldGrid.Cells[0,iCount] := Child.aGrid.Cells[iCount-1,0];
             {field type & field float}
             FieldGrid.Cells[3,iCount] := '';
             case AType.DBDataType of
                  DBaseInt : FieldGrid.Cells[1,iCount] := 'Integer';
                  DBaseFloat :
                  begin
                       FieldGrid.Cells[1,iCount] := 'Float';
                       FieldGrid.Cells[3,iCount] := IntToStr(AType.iDigit2);
                  end;
                  DBaseStr : FieldGrid.Cells[1,iCount] := 'String';
             end;
             {field digits}
             FieldGrid.Cells[2,iCount] := IntToStr(AType.iSize);
        end;

        {edit details for first field in the list of fields}
        Label5.Caption := 'Field 1 of ' +
                          IntToStr(FieldGrid.RowCount-1) + ' Fields';
        EditPanel.Enabled := True;
        EditName.Text := FieldGrid.Cells[0,1];
        Label3.Caption := 'Edit Field  ' + EditName.Text;
        case FieldGrid.Cells[1,1][1] of
             'F' :
             begin
                  DataTypeGroup.ItemIndex := 0;
                  SpinFirst.Value := StrToInt(FieldGrid.Cells[2,1]);
                  Label1.Caption := 'Digits';
                  SpinSecond.Visible := True;
                  Label2.Visible := True;
                  SpinSecond.Value := StrToInt(FieldGrid.Cells[3,1]);
                  Label2.Caption := 'Float';
             end;
             'I' :
             begin
                  DataTypeGroup.ItemIndex := 1;
                  SpinFirst.Value := StrToInt(FieldGrid.Cells[2,1]);
                  Label1.Caption := 'Digits';
                  SpinSecond.Visible := False;
                  Label2.Visible := False;
             end;
             'S' :
             begin
                  DataTypeGroup.ItemIndex := 2;
                  SpinFirst.Value := StrToInt(FieldGrid.Cells[2,1]);
                  Label1.Caption := 'Characters';
                  SpinSecond.Visible := False;
                  Label2.Visible := False;
             end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TEditTypeForm.initchild ' + Child.Caption,
                      mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

procedure TEditTypeForm.UpdateTypes(Child : TMDIChild);
begin
     {}
end;
procedure TEditTypeForm.FieldGridSelectCell(Sender: TObject; Col,
  Row: Integer; var CanSelect: Boolean);
begin
     {edit this feature in the edit panel}
     EditPanel.Enabled := True;

     Label5.Caption := 'Field ' + IntToStr(Row) +
                       ' of ' + IntToStr(FieldGrid.RowCount-1) +
                       ' Fields';

     EditName.Text := FieldGrid.Cells[0,Row];

     Label3.Caption := 'Edit Field  ' + EditName.Text;

     case FieldGrid.Cells[1,Row][1] of
          'F' :
          begin
               DataTypeGroup.ItemIndex := 0;
               SpinFirst.Value := StrToInt(FieldGrid.Cells[2,Row]);
               Label1.Caption := 'Digits';
               SpinSecond.Visible := True;
               Label2.Visible := True;
               SpinSecond.Value := StrToInt(FieldGrid.Cells[3,Row]);
               Label2.Caption := 'Float';
          end;
          'I' :
          begin
               DataTypeGroup.ItemIndex := 1;
               SpinFirst.Value := StrToInt(FieldGrid.Cells[2,Row]);
               Label1.Caption := 'Digits';
               SpinSecond.Visible := False;
               Label2.Visible := False;
          end;
          'S' :
          begin
               DataTypeGroup.ItemIndex := 2;
               SpinFirst.Value := StrToInt(FieldGrid.Cells[2,Row]);
               Label1.Caption := 'Characters';
               SpinSecond.Visible := False;
               Label2.Visible := False;
          end;
     end;
end;

procedure TEditTypeForm.FormResize(Sender: TObject);
var
   iDefaultColWidth : integer;
begin
     {adjust default column width in the grid}
     iDefaultColWidth := Round((FieldGrid.Width -
                                24{width of scrollbar})
                               /4);
     if (iDefaultColWidth > 15) then
        FieldGrid.DefaultColWidth := iDefaultColWidth
     else
         FieldGrid.DefaultColWidth := 15;
end;

procedure TEditTypeForm.FormCreate(Sender: TObject);
begin
     {adjust default col width}
     FormResize(self);
     fChange := False;
end;

procedure TEditTypeForm.FieldGridRowMoved(Sender: TObject; FromIndex,
  ToIndex: Integer);
begin
     Label5.Caption := 'Field ' + IntToStr(FieldGrid.Selection.Top) +
                       ' of ' + IntToStr(FieldGrid.RowCount-1) +
                       ' Fields';
     fChange := True;
end;

function IsWhiteSpace(const sString : string) : boolean;
var
   iCount : integer;
begin
     //Result := False;
     Result := True;

     if (sString = '') then
        //Result := True
     else
     begin
          //Result := True;
          for iCount := 1 to Length(sString) do
              if (sString[iCount] <> ' ') then
                 Result := False;
     end;
end;

procedure TEditTypeForm.EditNameChange(Sender: TObject);
begin
(*     if not IsWhiteSpace(EditName.Text) then
     begin
          {}
          Label3.Caption := 'Edit Field  ' + EditName.Text;
          FieldGrid.Cells[0,FieldGrid.Selection.Top] := EditName.Text;
          fChange := True;
     end;                    *)
end;

function rtnCorrectTypeIndex(const sType : string) : integer;
begin
     {result is 0 = Float
                1 = Integer
                2 = String}
     case sType[1] of
          'F' : Result := 0;
          'I' : Result := 1;
     else
         Result := 2;
     end;
end;

procedure TEditTypeForm.DataTypeGroupClick(Sender: TObject);
begin
     {check if DataTypeGroup.ItemIndex corresponds to the string in the
      currently selected row}
(*     if (rtnCorrectTypeIndex(FieldGrid.Cells[1,FieldGrid.Selection.Top]) <>
         DataTypeGroup.ItemIndex) then
     begin
          {FieldGrid.Cells}

          fChange := True;
     end;                      *)
end;

end.
