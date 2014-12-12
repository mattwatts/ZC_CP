{
 Creation Date : Wed 8th Oct 1997

 Purpose : for converting Eden CRA compartment selection (EMS) files for
           use with sub-compartment layer

 Author : Matthew Watts

 Modifications :

               uses unit c2c C2CForm
 }


unit comp2coo;

interface

procedure ConvertComp2CooEMS(const sOrigEMS, sDestEMS : string);

implementation

uses
    Control, Stdctrls, Forms, Dialogs,
    Controls, c2c, Global;



procedure ConvertComp2CooEMS(const sOrigEMS, sDestEMS : string);
var
   OrigEMSFile, DestEMSFile : Text;
   sOrigLine, sDestLine, sTmp : string;
   iCount : integer;

   procedure GetBox;
   begin
        C2CForm.C2Box.Clear;
        repeat
              readln(OrigEMSFile,sTmp);
              C2CForm.C2Box.Items.Add(sTmp);
        until EOF(OrigEMSFile) or IsSeperator(sTmp);
   end;

   procedure PutBox;
   var
      iCount : integer;
   begin
        for iCount := 0 to (C2CForm.C2Box.Items.Count-1) do
            writeln(DestEMSFile,C2CForm.C2Box.Items.Strings[iCount]);
   end;

   procedure Exec_SQL(const sField, sCompField, sTable, sValue, sAttach : string;
                      const fStringQuery : boolean);
   var
      fEnd : boolean;
      sLine, sValueToFind, sTest : string;
   begin
        try

        with C2CForm.EMSQuery do
        begin
             DatabaseName := ControlRes^.sDatabase;

             Close;
             SQL.Clear;
             sTest := 'Select ' + sCompField + ' from ' +
                     {Copy(}sTable{,1,Length(sTable)-4)} + ' where';
             SQL.Add(sTest);

             if fStringQuery then
                sTest := sField + ' = ''' + sValue + ''''
             else
                 sTest := sField + ' = ' + sValue;
             SQL.Add(sTest);

             C2CForm.QueryMemo.Lines := SQL;
             C2CForm.Show{Modal};

             Open;
             sValueToFind := FieldByName( FieldDefs.Items[0].Name ).AsString;
             Close;

             SQL.Clear;

             if fStringQuery then
                sTest := 'SELECT ' + sField + ' FROM ' +
                         Copy(sTable,1,Length(sTable)-4) +
                         ' WHERE ' + sCompField + ' = ''' + sValueToFind + ''''
             else
                 sTest := 'SELECT ' + sField + ' FROM ' +
                          Copy(sTable,1,Length(sTable)-4) +
                          ' WHERE ' + sCompField + ' = ' + sValueToFind;

             SQL.Add(sTest);
             Open;
             fEnd := False;
             while (not fEnd) do
             begin
                  sLine := FieldByName( FieldDefs.Items[0].Name ).AsString;

                  C2CForm.DestBox.Items.Add(sAttach + sLine);

                  Next;

                  if EOF then
                     fEnd := True;
             end;

             Close;
        end;

        except
              Screen.Cursor := crDefault;
              MessageDlg('Exception in Exec_SQL',mtError,[mbOk],0);
        end;
   end;

   procedure PutBoxQuery(const sField, sCompField : string;
                         const fStringQuery : boolean);
   var
      iCount : integer;
      sValue : string;
   begin
        C2CForm.DestBox.Items.Clear;

        for iCount := 0 to (C2CForm.C2Box.Items.Count-1) do
            if IsSeperator(C2CForm.C2Box.Items.Strings[iCount]) then
               C2CForm.DestBox.Items.Add(C2CForm.C2Box.Items.Strings[iCount])
            else
            begin
                 {execute SQL query }

                 sValue := C2CForm.C2Box.Items.Strings[iCount];

                 Exec_SQL(sField,
                          sCompField,
                          ControlRes^.sSiteSummaryTable,
                          sValue,
                          '',
                          fStringQuery);
            end;

        {write site geocodes of this compartment to the file}
        for iCount := 0 to (C2CForm.DestBox.Items.Count-1) do
            writeln(DestEMSFile,C2CForm.DestBox.Items.Strings[iCount]);
   end;

   procedure PutBoxQueryAttach(const sField, sCompField : string);
   var
      iCount : integer;
      sValue, sAttach : string;
   begin
        C2CForm.DestBox.Items.Clear;

        for iCount := 0 to (C2CForm.C2Box.Items.Count-1) do
            if IsSeperator(C2CForm.C2Box.Items.Strings[iCount]) then
               C2CForm.DestBox.Items.Add(C2CForm.C2Box.Items.Strings[iCount])
            else
            begin
                 {execute SQL query }
                 sValue := Copy(C2CForm.C2Box.Items.Strings[iCount],
                                2,
                                Length(C2CForm.C2Box.Items.Strings[iCount])-1);

                 sAttach := Copy(C2CForm.C2Box.Items.Strings[iCount],
                                 1,
                                 1);

                 if (sAttach = CHOICE_MESSAGE) then
                    C2CForm.DestBox.Items.Add(C2CForm.C2Box.Items.Strings[iCount])
                 else
                     Exec_SQL(sField,
                          sCompField,
                          ControlRes^.sSiteSummaryTable,
                          sValue,
                          sAttach,
                          False);
            end;

        {write site geocodes of this compartment to the file}
        for iCount := 0 to (C2CForm.DestBox.Items.Count-1) do
            writeln(DestEMSFile,C2CForm.DestBox.Items.Strings[iCount]);
   end;


begin
     try

        {convert large scale EMS selection file for use with smaller scale
         selection units (eg. compartments to subcompartments)}

        C2CForm := TC2CForm.Create(Application);

        {initialise files}
        assign(OrigEMSFile,sOrigEMS);
        reset(OrigEMSFile);

        assign(DestEMSFile,sDestEMS);
        rewrite(DestEMSFile);


        readln(OrigEMSFile,sOrigLine);
        writeln(DestEMSFile,sOrigLine);
        {target percent}

        readln(OrigEMSFile,sOrigLine);
        writeln(DestEMSFile,sOrigLine);
        {date stamp}

        GetBox;
        PutBox;
        {EMS reason}

        for iCount := 1 to 8 do
        begin
             {convert site names for each of the 8 site classes;
              Available, Negotiated, Mandatory, Excluded,
              Reserved, Ignored, Partial, Flagged}
             GetBox;
             PutBoxQuery('NAME',ControlRes^.sCompNameField,TRUE);
        end;

        for iCount := 1 to 8 do
        begin
             {convert site geocodes for each of the 8 site classes}
             GetBox;
             PutBoxQuery(ControlRes^.sKeyField,ControlRes^.sCompGeoField,FALSE);
        end;

        GetBox;
        PutBoxQueryAttach(ControlRes^.sKeyField,ControlRes^.sCompGeoField);
        {traverse choice log and convert all geocodes to corresponding list of
         geocodes}
        {choice log}

        WriteLn(DestEMSFile,'***-----------separator-----------*** PartialFlags End');
        {ignore the partial flags, users must add these manually using a partial deferral report}

        {ems file structure is:

         target percent
         date stamp
         EMSReason
         -seperator-
         Available
         -seperator-
         Negotiated
         -seperator-
         Mandatory
         -seperator-
         Excluded
         -seperator-
         Reserved
         -seperator-
         Ignored
         -seperator-
         Partial
         -seperator-
         Flagged
         -seperator-
         AvailableGeocode
         -seperator-
         NegotiatedGeocode
         -seperator-
         MandatoryGeocode
         -seperator-
         ExcludedGeocode
         -seperator-
         ReservedGeocode
         -seperator-
         IgnoredGeocode
         -seperator-
         PartialGeocode
         -seperator-
         FlaggedGeocode
         -seperator-
         ChoiceLog
         -seperator-
         Partial Flags (if any)
         }

         {close files}
         CloseFile(OrigEMSFile);
         CloseFile(DestEMSFile);

         C2CForm.Free;

      except
            Screen.Cursor := crDefault;
            MessageDlg('Exception in ConvertComp2CooEMS',mtError,[mbOk],0);
      end;
end;

end.
