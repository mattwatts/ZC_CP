unit fieldimp;

{
Author : Matthew Watts
Date : Wed 15th April 1998
Purpose : Data Field Import routines.
          allow users to select inputs for ImportFieldsToTable and execute the
          actual import of data fields in an efficient way, note: ImportFieldsToTable
          is a generic procedure that can be called externally to this unit with the
          appropriate parameters, assuming the tables specified are linked/loaded
          to the table editor.
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ds;

type
  TFieldImportForm = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;


procedure ImportFieldsToTable(const sDestinationTable, sDestinationKey : string;
                              SourceTables, SourceKeys, SourceFields : Array_t);

var
  FieldImportForm: TFieldImportForm;

implementation

uses MAIN, Childwin, tparse, global, xdata, impexp;

{$R *.DFM}


{this is called by ImportFieldsToTable}
procedure GetTableChild(sTable : string;
                        var aChild : TMDIChild;
                        var aParser : TTableParser);
var
   iChildId : integer;
begin
     iChildId := SCPForm.rtnTableId(sTable);

     aChild := TMDIChild(SCPForm.MDIChildren[iChildId]);
     if not aChild.CheckLoadFileData.Checked then
     begin
          {data is to be read from a file using a TTableParser
           initialise aParser so we can read from it}
          aParser := TTableParser.Create(Application);
          aParser.initfile(aChild.Caption);
     end;
end;

{this is called by ImportFieldsToTable}
procedure GetTableSearchArr(aChild : TMDIChild;
                            const sKeyField : string;
                            aParser : TTableParser;
                            var SearchArr : Array_T);
var
   KeyArr : Array_t;
   iKey, iKeyArrCount, iKeyColumn, iCount : integer;

   procedure AddToKeyArr(const iK : integer);
   begin
        Inc(iKeyArrCount);
        if (iKeyArrCount > KeyArr.lMaxSize) then
           KeyArr.Resize(KeyArr.lMaxSize + ARR_STEP_SIZE);
        KeyArr.setValue(iKeyArrCount,@iK);
   end;

begin
     try
        {assumes GetChild has already been called with aChild and aParser

         creates : binary search array for looking up rows within the file
                   by specifying a row key}
        iKeyArrCount := 0;
        KeyArr := Array_t.create;
        KeyArr.init(SizeOf(integer),ARR_STEP_SIZE);

        try
           iKeyColumn := aChild.rtnColumnIndex(sKeyField);

           if aChild.CheckLoadFileData.Checked then
           begin
                {data is loaded into aChild.aGrid}
                for iCount := 1 to (aChild.aGrid.RowCount - 1) do
                begin
                     iKey := StrToInt(aChild.aGrid.Cells[iKeyColumn,iCount]);
                     AddToKeyArr(iKey); {load all the row keys into KeyArr}
                end;
           end
           else
           begin
                {data must be read from file using aParser}

                iCount := 1;
                aParser.seekfile(iCount);
                repeat
                      iKey := StrToInt(aParser.rtnRowValue(iKeyColumn));
                      AddToKeyArr(iKey); {load all the row keys into KeyArr}
                      Inc(iCount);

                until (not aParser.seekfile(iCount));
           end;

        except
              on EConvertError do
              begin
                   Screen.Cursor := crDefault;
                   MessageDlg('Exception in GetBinarySearchArr, key in table ' + aChild.Caption +
                              ' is not an integer',mtError,[mbOk],0);
                   iKeyArrCount := -1;
              end;
        end;

        if (iKeyArrCount > 0) then
           SearchArr := SortIntegerArray(KeyArr) {convert KeyArr to SearchArr}
        else
        if (iKeyArrCount <> -1) then
        begin
             {error - there are no keys}
             Screen.Cursor := crDefault;

             MessageDlg('Exception in GetBinarySearchArr, no keys in table ' + aChild.Caption,
                        mtError,[mbOk],0);
        end;

        KeyArr.Destroy;

     except
           MessageDlg('Exception in GetBinarySearchArr',mtError,[mbOk],0);
     end;
end;

function AddFieldsToTable(const sTable : string;
                          SourceFields : Array_t) : boolean;
begin
     Result := True;
     {test if SourceFields exist in sDestinationTable, asking user if they want to
      continue if there is a type conflict}
          {add fields to sDestinationTable if necessary
           (if file is linked
               execute SQL query to add necessary fields
            else

               )}
end;

procedure ImportFieldsToTable(const sDestinationTable, sDestinationKey : string;
                              SourceTables, SourceKeys, SourceFields : Array_t);
var
   DestinationChild : TMDIChild;
   DestinationParser : TTableParser;
   iCount, iCount2, iColumn : integer;
   sTable, sKey : string[255];

   SourceChildren : array [1..100] of TMDIChild;
   SourceParsers : array [1..100] of TTableParser;
   SourceSearchArrays : array [1..100] of Array_T;

   SourceColumns : Array_T;
   ASourceField : SourceField_T;

begin
     {
      sDestinationTable       destination table
      sDestinationKey         key field in destination table
      SourceTables            source table(s) containing data fields to import
      SourceKeys              key field(s) in source table(s)
      SourceFields            list of fields to import (this is a record of type SourceField_T)
                              which has the fields:
                                    table containing field (which must be one of the SourceTables)
                                    field name in source table
                                    field name in destination table (doesn't have to exist in destination table)
                                    field data type (can be Int/Float/String)
                                    field conversion factor (only applicable for Int/Float)
     }

     {
      method used to import the data:

       - initialse various objects to read/write tables

       - test if SourceFields exist in sDestinationTable
         if they exist and there is a type conflict, ask user to 1) continue and change datatype in destination table
                                                              or 2) exit
         if they don't exist, add them to sDestinationTable

       - traverse rows of sDestinationTable from start to finish, importing data elements for each row

       - dispose of various objects used to read/write tables
     }

     if (SourceTables.lMaxSize <= 100) then
     try
        {add fields to sDestinationTable if necessary}
        if AddFieldsToTable(sDestinationTable,SourceFields) then
        begin
             {initialise objects}
             GetTableChild(sDestinationTable,
                           DestinationChild,
                           DestinationParser);
             for iCount := 1 to SourceTables.lMaxSize do
             begin
                  SourceTables.rtnValue(iCount,@sTable);
                  SourceKeys.rtnValue(iCount,@sKey);
                  GetTableChild(sTable,
                                SourceChildren[iCount],
                                SourceParsers[iCount]);
                  GetTableSearchArr(SourceChildren[iCount],
                                    sKey,
                                    SourceParsers[iCount],
                                    SourceSearchArrays[iCount]);
             end;
             {determine which columns each of the SourceFields are contained in}
             SourceColumns := Array_T.Create;
             SourceColumns.init(SizeOf(integer),ARR_STEP_SIZE);
             for iCount := 1 to SourceFields.lMaxSize do
             begin
                  SourceFields.rtnValue(iCount,@ASourceField);
                  for iCount2 := 1 to SourceTables.lMaxSize do
                  begin
                       SourceTables.rtnValue(iCount2,@sTable);
                       if (ASourceField.sTableContainingField = sTable) then
                       begin
                            iColumn := SourceChildren[iCount2].rtnColumnIndex(ASourceField.sSourceFieldName);
                            SourceColumns.setValue(iCount,@iColumn);
                       end;
                  end;
             end;




             {dispose objects}
             CheckDisposeParser(DestinationChild,DestinationParser);
             for iCount := 1 to SourceTables.lMaxSize do
             begin
                  CheckDisposeParser(SourceChildren[iCount],SourceParsers[iCount]);
                  SourceSearchArrays[iCount].Destroy;
             end;
             SourceColumns.Destroy;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in ImportFieldsToTable ' +  sDestinationTable,
                      mtError,[mbOk],0);
     end
     else
     begin
          {there are more than 100 source tables, can only perform function with
           100 or fewer source tables}
          Screen.Cursor := crDefault;
          MessageDlg('There are ' + IntToStr(SourceTables.lMaxSize) + ' source tables.' + Chr(10) + Chr(13) +
                     'The operation can only be performed with 100 or fewer source tables.',
                     mtInformation,[mbOk],0);
     end;
end;

end.
