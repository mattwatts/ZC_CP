unit BoundaryFileMaker;

interface

type
    Segment_T = record
                      rX1, rX2, rY1, rY2, rLength : extended;
                      iPUID : integer;
                end;
    Segment2_T = record
                       iPUID1, iPUID2 : integer;
                       rLength : extended;
                 end;


procedure MakeBoundaryLengthFile(const sInputShapeFileName, sPUIDFieldName, sOutputFileName : string;
                                 const fIncludeExternalEdges : boolean);

implementation

uses
    Forms, Controls, Dialogs, SysUtils, MapWinGIS_TLB, ds, GIS, Miscellaneous;

function CountSegments(InputSF : MapWinGIS_TLB.Shapefile) : integer;
var
   iCount, iNumberOfSegments : integer;
begin
     try
        // traverse the shapefile, counting segments
        iNumberOfSegments := 0;
        for iCount := 0 to (InputSF.NumShapes-1) do
        begin
             if (InputSF.Shape[iCount].numPoints > 1) then
                Inc(iNumberOfSegments,InputSF.Shape[iCount].numPoints-1);
        end;

        Result := iNumberOfSegments;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in CountSegments',mtError,[mbOk],0);
     end;
end;

procedure DecomposePolygonToSegments(InputSF : MapWinGIS_TLB.Shapefile;
                                     SegmentArray : Array_t;
                                     const iPUIDIndex : integer;
                                     var iMaximumPUID : integer);
var
   iCount, iCount2, iSegmentCount : integer;
   ASegment : Segment_T;
   rXLengthSqr, rYLengthSqr, rAX, rBX, rAY, rBY : extended;
begin
     try
        // traverse the shapefile, storing segments in an array
        iSegmentCount := 0;
        iMaximumPUID := 0;
        for iCount := 0 to (InputSF.NumShapes-1) do
        begin
             if (InputSF.Shape[iCount].numPoints > 1) then
                for iCount2 := 0 to (InputSF.Shape[iCount].numPoints-2) do
                begin
                     rAX := InputSF.Shape[iCount].Point[iCount2].x;
                     rAY := InputSF.Shape[iCount].Point[iCount2].y;
                     rBX := InputSF.Shape[iCount].Point[iCount2+1].x;
                     rBY := InputSF.Shape[iCount].Point[iCount2+1].y;
                     ASegment.iPUID := InputSF.CellValue[iPUIDIndex,iCount];

                     if (ASegment.iPUID > iMaximumPUID) then
                        iMaximumPUID := ASegment.iPUID;

                     rXLengthSqr := (rAX - rBX) * (rAX - rBX);
                     rYLengthSqr := (rAY - rBY) * (rAY - rBY);
                     if ((rXLengthSqr + rYLengthSqr) > 0) then
                        ASegment.rLength := sqrt(rXLengthSqr + rYLengthSqr)
                     else
                         ASegment.rLength := 0;

                     if (rAX > rBX) then
                     begin
                          ASegment.rX1 := rBX;
                          ASegment.rX2 := rAX;
                     end
                     else
                     begin
                          ASegment.rX1 := rAX;
                          ASegment.rX2 := rBX;
                     end;
                     if (rAY > rBY) then
                     begin
                          ASegment.rY1 := rBY;
                          ASegment.rY2 := rAY;
                     end
                     else
                     begin
                          ASegment.rY1 := rAY;
                          ASegment.rY2 := rBY;
                     end;

                     Inc(iSegmentCount);
                     SegmentArray.setValue(iSegmentCount,@ASegment);
                end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in DecomposePolygonToSegments',mtError,[mbOk],0);
     end;
end;

function AreSegmentCoordinatesIdentical(Segment1, Segment2 : Segment_T) : boolean;
var
   fResult : boolean;
begin
     // rX1, rX2, rY1, rY2
     fResult := True;

     if (Segment1.rX1 <> Segment2.rX1) then
        fResult := False;
     if (Segment1.rX2 <> Segment2.rX2) then
        fResult := False;
     if (Segment1.rY1 <> Segment2.rY1) then
        fResult := False;
     if (Segment1.rY2 <> Segment2.rY2) then
        fResult := False;

     Result := fResult;
end;

procedure FindDuplicateSegments(SegmentArray,Segment2Array : Array_t;
                                var iSegment2ArraySize : integer;
                                const iMaximumLengthPUID : integer);
var
   iCount : integer;
   Segment1, Segment2 : Segment_T;
   sSegment2Value : str255;
   iPUID1, iPUID2 : integer;
   sPUID1, sPUID2, sfinID1, sfinID2 : string;
begin
     //
     iCount := 1;
     iSegment2ArraySize := 0;

     while (iCount <= SegmentArray.lMaxSize) do
     begin
          SegmentArray.rtnValue(iCount,@Segment1);
          iPUID1 := Segment1.iPUID;
          sPUID1 := PadInt(iPUID1,iMaximumLengthPUID);

          if (iCount = SegmentArray.lMaxSize) then
          begin
               sSegment2Value := sPUID1 + '_' + sPUID1 + ' ' + FloatToStr(Segment1.rLength);
               Inc(iSegment2ArraySize);
               Segment2Array.setValue(iSegment2ArraySize,@sSegment2Value);
               iCount := iCount + 1;
          end
          else
          begin
               SegmentArray.rtnValue(iCount+1,@Segment2);
               iPUID2 := Segment2.iPUID;
               sPUID2 := PadInt(iPUID2,iMaximumLengthPUID);

               if (iPUID1 < iPUID2) then
               begin
                    sfinID1 := sPUID1;
                    sfinID2 := sPUID2;
               end;
               if (iPUID1 > iPUID2) then
               begin
                    sfinID1 := sPUID2;
                    sfinID2 := sPUID1;
               end;
               if (AreSegmentCoordinatesIdentical(Segment1,Segment2) = True) then
               begin
                    sSegment2Value := sfinID1 + '_' + sfinID2 + ' ' + FloatToStr(Segment1.rLength);
                    Inc(iSegment2ArraySize);
                    Segment2Array.setValue(iSegment2ArraySize,@sSegment2Value);
                    iCount := iCount + 2;
               end
               else
               begin
                    sSegment2Value :=  sPUID1 + '_' + sPUID1 + ' ' + FloatToStr(Segment1.rLength);
                    Inc(iSegment2ArraySize);
                    Segment2Array.setValue(iSegment2ArraySize,@sSegment2Value);
                    iCount := iCount + 1;
               end;
          end;
     end;
end;

procedure JoinSegmentsToBoundaryFile(Segment2Array : Array_t;
                                     const sOutputFileName : string;
                                     const iMaximumLengthPUID : integer;
                                     const fIncludeExternalEdges : boolean);
var
   OutFile : TextFile;
   iCount, iPUID1, iPUID2, iNextPUID1, iNextPUID2, iTrimCharacters : integer;
   rSegmentLength, rNextSegmentLength : extended;
   sSegment2Value : str255;
   fContinue : boolean;
begin
     //
     assignfile(OutFile,sOutputFileName);
     rewrite(OutFile);
     writeln(OutFile,'id1,id2,boundary');

     iCount := 1;
     iTrimCharacters := (iMaximumLengthPUID * 2) + 2;

     while (iCount <= Segment2Array.lMaxSize) do
     begin
          Segment2Array.rtnValue(iCount,@sSegment2Value);
          // 00301_00029 6.37
          // 1234567890123456
          // iMaximumLengthPUID 5
          iPUID1 := StrToInt(Copy(sSegment2Value,1,iMaximumLengthPUID));
          iPUID2 := StrToInt(Copy(sSegment2Value,iMaximumLengthPUID+2,iMaximumLengthPUID));
          rSegmentLength := StrToFloat(Copy(sSegment2Value,iTrimCharacters+1,Length(sSegment2Value)-iTrimCharacters));

          Inc(iCount);

          if (iCount <= Segment2Array.lMaxSize) then
          begin
               Segment2Array.rtnValue(iCount,@sSegment2Value);
               iNextPUID1 := StrToInt(Copy(sSegment2Value,1,iMaximumLengthPUID));
               iNextPUID2 := StrToInt(Copy(sSegment2Value,iMaximumLengthPUID+2,iMaximumLengthPUID));
               rNextSegmentLength := StrToFloat(Copy(sSegment2Value,iTrimCharacters+1,Length(sSegment2Value)-iTrimCharacters));
               fContinue := (iPUID1 = iNextPUID1) and (iPUID2 = iNextPUID2);

               while (fContinue) do
               begin
                    rSegmentLength := rSegmentLength + rNextSegmentLength;
                    Inc(iCount);
                    if (iCount < Segment2Array.lMaxSize) then
                    begin
                         Segment2Array.rtnValue(iCount,@sSegment2Value);
                         iNextPUID1 := StrToInt(Copy(sSegment2Value,1,iMaximumLengthPUID));
                         iNextPUID2 := StrToInt(Copy(sSegment2Value,iMaximumLengthPUID+2,iMaximumLengthPUID));
                         rNextSegmentLength := StrToFloat(Copy(sSegment2Value,iTrimCharacters+1,Length(sSegment2Value)-iTrimCharacters));
                         fContinue := (iPUID1 = iNextPUID1) and (iPUID2 = iNextPUID2);
                    end
                    else
                        fContinue := False;
               end;

               if (iPUID1 <> iPUID2) then
                  writeln(OutFile,IntToStr(iPUID1) + ',' + IntToStr(iPUID2) + ',' + FloatToStr(rSegmentLength))
               else
                   if fIncludeExternalEdges then
                      writeln(OutFile,IntToStr(iPUID1) + ',' + IntToStr(iPUID2) + ',' + FloatToStr(rSegmentLength));

          end
          else
          begin
               if (iPUID1 <> iPUID2) then
                  writeln(OutFile,IntToStr(iPUID1) + ',' + IntToStr(iPUID2) + ',' + FloatToStr(rSegmentLength))
               else
                   if fIncludeExternalEdges then
                      writeln(OutFile,IntToStr(iPUID1) + ',' + IntToStr(iPUID2) + ',' + FloatToStr(rSegmentLength));
          end;
     end;

     closefile(OutFile);
end;

procedure SaveArray_segments(SegmentArray : Array_t;
                             const sOutputFileName : string);
var
   OutFile : TextFile;
   iCount : integer;
   ASegment : Segment_T;
begin
     assignfile(OutFile,sOutputFileName);
     rewrite(OutFile);
     writeln(OutFile,'index,iPUID,rLength,rX1,rX2,rY1,rY2');

     for iCount := 1 to SegmentArray.lMaxSize do
     begin
          SegmentArray.rtnValue(iCount,@ASegment);
          writeln(OutFile,IntToStr(iCount) + ',' +
                          IntToStr(ASegment.iPUID) + ',' +
                          FloatToStr(ASegment.rLength) + ',' +
                          FloatToStr(ASegment.rX1) + ',' +
                          FloatToStr(ASegment.rX2) + ',' +
                          FloatToStr(ASegment.rY1) + ',' +
                          FloatToStr(ASegment.rY2));
     end;

     closefile(OutFile);
end;

procedure SaveArray_segments_BSformat(SegmentArray : Array_t;
                                      const sOutputFileName : string);
var
   OutFile : TextFile;
   iCount : integer;
   ASegment : Segment_T;
begin
     assignfile(OutFile,sOutputFileName);
     rewrite(OutFile);
     writeln(OutFile,'x1_y1_x2_y2 length PUID');

     for iCount := 1 to SegmentArray.lMaxSize do
     begin
          SegmentArray.rtnValue(iCount,@ASegment);
          writeln(OutFile,FloatToStr(ASegment.rX1) + '_' +
                          FloatToStr(ASegment.rY1) + '_' +
                          FloatToStr(ASegment.rX2) + '_' +
                          FloatToStr(ASegment.rY2) + ' ' +
                          FloatToStr(ASegment.rLength) + ' ' +
                          IntToStr(ASegment.iPUID));
     end;

     closefile(OutFile);
end;

procedure LoadArray_segments_BSformat(SegmentArray : Array_t;
                                      const sInputFileName : string);
var
   InFile : TextFile;
   iCount, iPos : integer;
   ASegment : Segment_T;
   sLine, sTemp : string;
begin
     assignfile(InFile,sInputFileName);
     reset(InFile);
     readln(InFile,sLine);

     for iCount := 1 to SegmentArray.lMaxSize do
     begin
          readln(InFile,sLine);
          // x1_y1_x2_y2 length PUID
          // 12345678901234567890123

          iPos := Pos('_',sLine);
          ASegment.rX1 := StrToFloat(Copy(sLine,1,iPos-1));
          sTemp := Copy(sLine,iPos+1,Length(sLine)-iPos);
          iPos := Pos('_',sTemp);
          ASegment.rY1 := StrToFloat(Copy(sTemp,1,iPos-1));
          sTemp := Copy(sTemp,iPos+1,Length(sTemp)-iPos);
          iPos := Pos('_',sTemp);
          ASegment.rX2 := StrToFloat(Copy(sTemp,1,iPos-1));
          sTemp := Copy(sTemp,iPos+1,Length(sTemp)-iPos);
          iPos := Pos(' ',sTemp);
          ASegment.rY2 := StrToFloat(Copy(sTemp,1,iPos-1));
          sTemp := Copy(sTemp,iPos+1,Length(sTemp)-iPos);
          iPos := Pos(' ',sTemp);
          ASegment.rLength := StrToFloat(Copy(sTemp,1,iPos-1));
          sTemp := Copy(sTemp,iPos+1,Length(sTemp)-iPos);
          ASegment.iPUID := StrToInt(sTemp);

          SegmentArray.setValue(iCount,@ASegment);
     end;

     closefile(InFile);
end;

procedure SaveArray_str255(Array_str255 : Array_t;
                           const sOutputFileName : string);
var
   OutFile : TextFile;
   iCount : integer;
   AValue : str255;
begin
     assignfile(OutFile,sOutputFileName);
     rewrite(OutFile);
     writeln(OutFile,'puid1_puid2 length');

     for iCount := 1 to Array_str255.lMaxSize do
     begin
          Array_str255.rtnValue(iCount,@AValue);
          //writeln(OutFile,IntToStr(iCount) + ',"' + AValue + '"');
          writeln(OutFile,AValue);
     end;

     closefile(OutFile);
end;

procedure LoadArray_str255(Array_str255 : Array_t;
                           const sInputFileName : string);
var
   InFile : TextFile;
   iCount : integer;
   AValue : str255;
begin
     assignfile(InFile,sInputFileName);
     reset(InFile);
     readln(InFile,AValue);

     for iCount := 1 to Array_str255.lMaxSize do
     begin
          readln(InFile,AValue);
          Array_str255.setValue(iCount,@AValue);
     end;

     closefile(InFile);
end;

procedure RemoveTemporaryFile(const sFilename : string);
begin
     if fileexists(sFilename) then       
        deletefile(sFilename);
end;

procedure MakeBoundaryLengthFile(const sInputShapeFileName, sPUIDFieldName, sOutputFileName : string;
                                 const fIncludeExternalEdges : boolean);
var
   OutFile : TextFile;
   InputSF : MapWinGIS_TLB.Shapefile;
   iPUIDIndex, iCount, iNumberOfSegments, iGISLayerHandle, iMaximumPUID, iMaximumLengthPUID,
   iSegment2ArraySize : integer;
   sMaximumPUID, sWorkingDirectory : string;
   PUIDLookupArray, SegmentArray, Segment2Array : Array_t;
begin
     try
        sWorkingDirectory := ExtractFilePath(sOutputFileName);

        if (GIS_Child.Map1.NumLayers > 0) then
        for iCount := 0 to (GIS_Child.Map1.NumLayers-1) do
            if (GIS_Child.Map1.LayerName[iCount] = sInputShapeFileName) then
               iGISLayerHandle := iCount;

        if (iGISLayerHandle > -1) then
        begin
             InputSF := IShapefile(GIS_Child.Map1.GetObject[iGISLayerHandle]);

             iPUIDIndex := -1;
             for iCount := 0 to (InputSF.NumFields-1) do
                 if (InputSF.Field[iCount].Name = sPUIDFieldName) then
                    iPUIDIndex := iCount;

             if (iPUIDIndex > -1) then
             begin
                  Screen.Cursor := crHourglass;

                  iNumberOfSegments := CountSegments(InputSF);
                  // create data structures
                  SegmentArray := Array_t.Create;
                  SegmentArray.init(SizeOf(Segment_T),iNumberOfSegments);
                  Segment2Array := Array_t.Create;
                  Segment2Array.init(SizeOf(str255),iNumberOfSegments);

                  // decompose polygons to segments
                  DecomposePolygonToSegments(InputSF,SegmentArray,iPUIDIndex,iMaximumPUID);

                  //SaveArray_segments(SegmentArray,sWorkingDirectory + 'segments_unsorted.csv');
                  SaveArray_segments_BSformat(SegmentArray,sWorkingDirectory + 'segments_unsorted.txt');

                  // sort segment list
                  ProgramRunWait('"' + ExtractFilePath(Application.ExeName) + 'ascii_table_sorter.exe" ' +
                                 '"' + sWorkingDirectory + 'segments_unsorted.txt' + '" ' +
                                 '"' + sWorkingDirectory + 'segments_sorted.txt' + '" ' +
                                 '1',
                                 '',
                                 True,
                                 False);

                  // load sorted segment list from file
                  LoadArray_segments_BSformat(SegmentArray,sWorkingDirectory + 'segments_sorted.txt');
                  //SaveArray_segments(SegmentArray,sWorkingDirectory + 'segments_sorted.csv');

                  sMaximumPUID := IntToStr(iMaximumPUID);
                  iMaximumLengthPUID := Length(sMaximumPUID);

                  // find duplicate segments
                  FindDuplicateSegments(SegmentArray,Segment2Array,iSegment2ArraySize,iMaximumLengthPUID);

                  // sort Segment2Array
                  if (iSegment2ArraySize < Segment2Array.lMaxSize) then
                     Segment2Array.resize(iSegment2ArraySize);
                  SaveArray_str255(Segment2Array,sWorkingDirectory + 'segments2_unsorted.txt');

                  ProgramRunWait('"' + ExtractFilePath(Application.ExeName) + 'ascii_table_sorter.exe" ' +
                                 '"' + sWorkingDirectory + 'segments2_unsorted.txt' + '" ' +
                                 '"' + sWorkingDirectory + 'segments2_sorted.txt' + '" ' +
                                 '1',
                                 '',
                                 True,
                                 False);

                  // load sorted segment list from file
                  LoadArray_str255(Segment2Array,sWorkingDirectory + 'segments2_sorted.txt');

                  // calculate segment lengths
                  JoinSegmentsToBoundaryFile(Segment2Array,sOutputFileName,iMaximumLengthPUID,fIncludeExternalEdges);

                  // dispose data structures
                  SegmentArray.Destroy;
                  Segment2Array.Destroy;

                  RemoveTemporaryFile(sWorkingDirectory + 'segments_unsorted.txt');
                  RemoveTemporaryFile(sWorkingDirectory + 'segments_sorted.txt');
                  //RemoveTemporaryFile(sWorkingDirectory + 'segments_unsorted.csv');
                  //RemoveTemporaryFile(sWorkingDirectory + 'segments_sorted.csv');
                  RemoveTemporaryFile(sWorkingDirectory + 'segments_sorted.txt_log.txt');
                  RemoveTemporaryFile(sWorkingDirectory + 'segments2_unsorted.txt');
                  RemoveTemporaryFile(sWorkingDirectory + 'segments2_sorted.txt');
                  RemoveTemporaryFile(sWorkingDirectory + 'segments2_sorted.txt_log.txt');

                  Screen.Cursor := crDefault;
             end
             else
             begin
                  MessageDlg('Cannot find field ' + sPUIDFieldName + ' in ' + sInputShapeFileName + '. Halting.',mtError,[mbOk],0);
             end;
        end
        else
        begin
             MessageDlg('Cannot find shapefile ' + sInputShapeFileName + '. Halting.',mtError,[mbOk],0);
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in MakeBoundaryLengthFile',mtError,[mbOk],0);
     end;
end;


end.
