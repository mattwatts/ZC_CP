unit fldadd;

{$undef TESTNEWTABLE}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables,
  ds {added for Array_T}
  ;

type
  TFieldAdder = class(TDataModule)
    TableQuery: TQuery;
    procedure AddFieldsToTable(ListOfFields : Array_T;
                               const sTableName, sDatabasePath : string);
    procedure NewTable(ListOfFields : Array_T;
                       const sTableName, sDatabasePath : string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FieldAdder: TFieldAdder;

implementation

uses
    FileCtrl, Global;


{$R *.DFM}
procedure TFieldAdder.AddFieldsToTable(ListOfFields : Array_T;
                                       const sTableName, sDatabasePath : string);
var
   iCount : integer;

   FieldType : AddFieldType_T;

   FieldSpec : FieldSpec_T;
                   {FieldType : AddFieldType_T;
                   iDigit1,
                   iDigit2 : integer;}
   sFieldType, sToAdd : string;

begin
     {alter the database table}
     ForceDirectories(sDatabasePath);

     for iCount := 1 to ListOfFields.lMaxSize do
     begin
          TableQuery.Sql.Clear;
          TableQuery.Sql.Add('ALTER TABLE "' + sDatabasePath + '\' + sTableName + '" ADD');
          {TableQuery.Sql.Add('(');}

          ListOfFields.rtnValue(iCount,@FieldSpec);
          case FieldSpec.FieldType of
               C : sFieldType := 'CHAR';
               N : sFieldType := 'NUMERIC';
          end;

          sToAdd := FieldSpec.sName + ' ' + sFieldType + '(' +
                    IntToStr(FieldSpec.iDigit1);

          if (FieldSpec.FieldType = N) then
             sToAdd := sToAdd  + ',' +
                       IntToStr(FieldSpec.iDigit2);

          sToAdd := sToAdd + ')';
          {if (iCount <> ListOfFields.lMaxSize) then
             sToAdd := sToAdd + ',';}
          TableQuery.Sql.Add(sToAdd);
          {TableQuery.Sql.Add(')');}

          TableQuery.Sql.SaveToFile('c:\sql_test.sql');

          try
             TableQuery.Prepare;
             TableQuery.ExecSQL;
          except
                Screen.Cursor := crDefault;
                MessageDlg('Exception in AddFieldsToTable',mtError,[mbOk],0);
                Application.Terminate;
                Exit;
          end;

     end;
end;

procedure TFieldAdder.NewTable(ListOfFields : Array_T;
                               const sTableName, sDatabasePath : string);
var
   iCount : integer;

   FieldType : AddFieldType_T;

   FieldSpec : FieldSpec_T;
                   {FieldType : AddFieldType_T;
                   iDigit1,
                   iDigit2 : integer;}
   sFieldType, sToAdd : string;

begin
     try
        {alter the database table}
        ForceDirectories(sDatabasePath);

        TableQuery.Sql.Clear;

        sToAdd := 'CREATE TABLE "' + sDatabasePath + sTableName + '"';

        TableQuery.Sql.Add(sToAdd);
        sToAdd := '(';

        TableQuery.Sql.Add(sToAdd);

        for iCount := 1 to ListOfFields.lMaxSize do
        begin
             ListOfFields.rtnValue(iCount,@FieldSpec);
             case FieldSpec.FieldType of
                  C : sFieldType := 'CHAR';
                  N : sFieldType := 'NUMERIC';
             end;

             sToAdd := FieldSpec.sName + ' ' + sFieldType + '(' +
                       IntToStr(FieldSpec.iDigit1);

             if (FieldSpec.FieldType = N) then
                sToAdd := sToAdd  + ',' +
                          IntToStr(FieldSpec.iDigit2);

             sToAdd := sToAdd + ')';

             if (iCount <> ListOfFields.lMaxSize) then
                sToAdd := sToAdd + ',';

             TableQuery.Sql.Add(sToAdd);
        end;

        sToAdd := ')';
        TableQuery.Sql.Add(sToAdd);

        try
           TableQuery.Prepare;
           TableQuery.ExecSQL;
        except
              TableQuery.SQL.SaveToFile(sDatabasePath + '\SQLTEXT.TXT');

              Screen.Cursor := crDefault;
              MessageDlg('Exception in TFieldAdder.NewTable during prepare/exec SQL query',mtError,[mbOk],0);
              Application.Terminate;
              Exit;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TFieldAdder.NewTable',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

end.
