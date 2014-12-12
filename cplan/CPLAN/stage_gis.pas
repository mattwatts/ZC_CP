unit stage_gis;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TAddStageToGISForm = class(TForm)
    Label1: TLabel;
    EditFieldName: TEdit;
    btnOk: TBitBtn;
    BitBtn2: TBitBtn;
    Memo1: TMemo;
    function DoesFieldExist(const sField : string) : boolean;
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AddStageToGISForm: TAddStageToGISForm;

function IsDBaseFieldNameValid(const sField : string) : boolean;

implementation

uses Control;

{$R *.DFM}

function IsLegalChar(const cChar : char) : boolean;
var
   iCount : char;
begin
     // Result is false if char is not legal.
     // Result is true if char is legal.
     Result := False;
     for iCount := 'A' to 'Z' do
         if (cChar = iCount) then
            Result := True;
     for iCount := '0' to '9' do
         if (cChar = iCount) then
            Result := True;
     if (cChar = '_') then
        Result := True;
end;

function ContainsIllegalCharacters(const sField : string) : boolean;
var
   iCount : integer;
begin
     // Result is true if string contains 1 or more illegal characters.
     // Result is false if string contains no illegal characters.

     Result := False;

     for iCount := 1 to Length(sField) do
     begin
          if not IsLegalChar(sField[iCount]) then
             Result := True;
     end;
end;

function IsDBaseFieldNameValid(const sField : string) : boolean;
var
   sTest : string;
begin
     // Determines if the name passed is valid to use as a dBase field name.

     // 1. field is 10 characters or less
     // 2. field starts with a..z
     // 3. field constains only a..z,0..9,_
     //    (and no other characters including space)

     Result := True;
     sTest := UpperCase(sField);

     if (Length(sTest) > 10)
     or (Length(sTest) = 0) then
        // 1. name fails because of length
        Result := False
     else
     begin
          if (sTest[1] < 'A')
          or (sTest[1] > 'Z') then
             // 2. name fails because of starting character
             Result := False
          else
          begin
               // 3. test if field contains illegal characters
               Result := not ContainsIllegalCharacters(sTest);
          end;
     end;
end;

function TAddStageToGISForm.DoesFieldExist(const sField : string) : boolean;
var
   sTest : string;
begin
     // Test if field sField exists in the shape table by opening the table
     // and attempting to access the field.
     with ControlForm.ShapeTable do
     begin
          TableName := ControlRes^.sShpTable;
          DatabaseName := ControlRes^.sDatabase;
          Open;

          Result := True;

          try
             sTest := FieldByName(sField).AsString;

          except
                // Field sField does not exist in the shape table.
                Result := False;
          end;

          Close;
     end;
end;

procedure TAddStageToGISForm.btnOkClick(Sender: TObject);
begin
     if (EditFieldName.Text = '') then
     begin
          // field name has not been entered
          ModalResult := mrNone;
          MessageDlg('Please enter a field name.',
                     mtInformation,
                     [mbOk],
                     0);
     end
     else
     begin
          if DoesFieldExist(EditFieldName.Text) then
          begin
               // field exists already
               ModalResult := mrNone;
               MessageDlg('The field name specified already exists, please enter a new field name.',
                          mtInformation,
                          [mbOk],
                          0);
          end
          else
          begin
               // field does not exist

               if IsDBaseFieldNameValid(EditFieldName.Text) then
               begin
                    // field name is valid

               end
               else
               begin
                    // field name is not valid
                    ModalResult := mrNone;
                    MessageDlg('The field name specified is not valid, please enter a valid field name.',
                               mtInformation,
                               [mbOk],
                               0);
               end;
          end;
     end;
end;

end.
