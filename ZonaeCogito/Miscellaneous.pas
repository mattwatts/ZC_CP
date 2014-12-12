unit Miscellaneous;

interface

uses
    ds,
    Grids,Graphics,Windows, DdeMan, dbtables, MapWinGIS_TLB;

type
    str255 = string[255];
    KeyFile_T = record
                  iSiteKey : integer;
                  iRichness : word;
                end;

    SingleValueFile_T = record
                    iFeatKey : word;
                    rAmount : single;
                  end;

    LabelDisplayOption_T = record
                  fDisplayLabel : boolean;
                  sField : str255;
                  AJustify : tkHJustification;
                           end;

  TOSInfo = class(TObject)
  public
    class function IsWOW64: Boolean;
  end;

function ShiftKeyDown : Boolean;
function DDESendCmd(const ThisDDEConv : TDDEClientConv; const sCommand : string) : boolean;
function Return_R_InstallPath : string;
function FileContainsCommas(const sFilename : string) : boolean;
procedure ConvertFileDelimiter_TabToComma(const sFilename : string);
function GenerateSubFilename(const sFilename, sSubname : string) : string;
function ReturnFieldIndex(const sFieldName, sLine : string) : integer;
function BinaryLookup_Integer(IntArr : Array_t; iMatch, iTop, iBottom : integer) : integer;
function BinaryLookupGrid_Integer(LookupGrid : TStringGrid; iMatch, iColumn, iTop, iBottom : integer) : integer;
function ReserveOrder_BinaryLookup_Integer(IntArr : Array_t; iMatch, iTop, iBottom : integer) : integer;
function IndexToColour(const iIndex : integer) : TColor;
//function ColourToIndex(const AColor : TColor) : integer;
procedure ProgramRunWaitCmdLine(const ApplicationLine,CommandLine,DefaultDirectory: string;Wait: boolean; fHideWindow : boolean);
procedure ProgramRunWait(const CommandLine,DefaultDirectory: string;Wait: boolean; fHideWindow : boolean);
procedure AutoFitGrid(AGrid : TStringGrid; Canvas : TCanvas; const fFitEntireGrid : boolean);
function TrimTrailingSlashes(const sLine : string) : string;
function TrimLeadSpaces(const sLine : string) : string;
function CountDelimitersInRow(const sRow, sDelimiter : string) : integer;
function GetDelimitedAsciiElement(const sLine, sDelimiter : string;const iColumn : integer) : string;
function GetDelimitedAsciiElement_smart(const sRow, sDelimiter : string;const iColumn : integer) : string;
procedure SaveStringGrid2CSV(AGrid : TStringGrid; const sFile : string);
procedure FasterLoadCSV2StringGrid(AGrid : TStringGrid; const sFile : string);
//procedure FastLoadCSV2StringGrid(AGrid : TStringGrid; const sFile : string);
function ACopyFile(const sSourceFile, sDestFile : string) : boolean;
procedure CopyIfExists(sFileName,sInputDir,sOutputDir : string);
function PadInt(const iInt,iDigits : integer) : string;
function probZUT(const z : extended) : extended;
function TrimEnclosingQuotes(const sLine : string) : string;
procedure ForceDBFIntegerField(ATable : TTable; AQuery : TQuery; const sDBFFileName, sFieldName : string);
procedure SortGrid(var AGrid : TStringGrid;
                   const iRowStartIndex, iColIndex : integer;
                   const wSortType, wSortDirection : word);
function RegionSafeStrToFloat(const sCell : string) : extended;
function TColourToKML(const Color : TColor; const iOpacity : integer) : string;
function TColourToKMLRamp(const Color : TColor; const iOpacity : integer;const rValue, rMin, rMax : extended) : string;
function OpacityRamp(const rValue, rMin, rMax : extended) : integer;
function TColourToHex(const Color : TColor) : string;
function HexToTColour(const sColor : string) : TColor;
function SmartOpenColour(const sColour : string) : TColor;
function Detect64BitOS : boolean;
procedure StoreLabelDisplayOption(const iLayer : integer;
                                  const fDL : boolean;
                                  const sF : str255;
                                  const AJ : tkHJustification);
function JustificationToString(const AJustify : tkHJustification) : string;
function StringToJustification(const sJustify : string) : tkHJustification;
procedure StoreLayerSizeOption(const iLayer : integer;
                               const rSize : single);
procedure StoreLayerFontSizeOption(const iLayer, iFontSize : integer);

const
     sVersionString = 'version 1.82';
     sCopyrightString = 'Copyright 2008-2012 University of Queensland';
     SORT_TYPE_STRING = 0;
     SORT_TYPE_REAL = 1;

     fDisplayeFlowsGUI_Default = False;

     sEE1 = 'latemhtaedfosdrol';
     sEE2 = 'yddadaysohw';
     sEE3 = 'reficul';
     sEE4 = 'temohpab';

var
   hMarxanProcess : THandle;
   LabelDisplayOption, LayerSizeOption, LayerFontSizeOption : Array_t;
   fLabelDisplayOption, fLayerSizeOption, fLayerFontSizeOption, fDisplayeFlowsGUI : boolean;

     
implementation

uses
    SysUtils, Forms, Dialogs, Math, registry, GIS;

// http://local.wasp.uwa.edu.au/~pbourke/texture_colour/colourramp/
// C Source for the "standard" hot-to-cold colour ramp.
//COLOUR GetColour(double v,double vmin,double vmax)
//{
//   COLOUR c = {1.0,1.0,1.0}; // white
//   double dv;
//
//   if (v < vmin)
//      v = vmin;
//   if (v > vmax)
//      v = vmax;
//   dv = vmax - vmin;
//
//   if (v < (vmin + 0.25 * dv)) {
//      c.r = 0;
//      c.g = 4 * (v - vmin) / dv;
//   } else if (v < (vmin + 0.5 * dv)) {
//      c.r = 0;
//      c.b = 1 + 4 * (vmin + 0.25 * dv - v) / dv;
//   } else if (v < (vmin + 0.75 * dv)) {
//      c.r = 4 * (v - vmin - 0.5 * dv) / dv;
//      c.b = 0;
//   } else {
//      c.g = 1 + 4 * (vmin + 0.75 * dv - v) / dv;
//      c.b = 0;
//   }
//
//   return(c);
//}

procedure StoreLayerFontSizeOption(const iLayer, iFontSize : integer);
var
   iCount, iDefaultSize : integer;
begin
     if not fLayerFontSizeOption then
     begin
          LayerFontSizeOption := Array_T.Create;
          LayerFontSizeOption.init(SizeOf(integer),100);

          iDefaultSize := 8;

          for iCount := 1 to 100 do
              LayerFontSizeOption.setValue(iCount,@iDefaultSize);
     end;

     fLayerFontSizeOption := True;

     LayerFontSizeOption.setValue(iLayer,@iFontSize);
end;

procedure StoreLayerSizeOption(const iLayer : integer;
                               const rSize : single);
var
   iCount : integer;
   rDefaultSize : single;
begin
     if not fLayerSizeOption then
     begin
          LayerSizeOption := Array_T.Create;
          LayerSizeOption.init(SizeOf(single),100);

          rDefaultSize := 1;

          for iCount := 1 to 100 do
              LayerSizeOption.setValue(iCount,@rDefaultSize);
     end;

     fLayerSizeOption := True;

     LayerSizeOption.setValue(iLayer,@rSize);
end;

procedure StoreLabelDisplayOption(const iLayer : integer;
                                  const fDL : boolean;
                                  const sF : str255;
                                  const AJ : tkHJustification);
var
   iCount : integer;
   ALDO : LabelDisplayOption_T;
begin
     if not fLabelDisplayOption then
     begin
          LabelDisplayOption := Array_T.Create;
          LabelDisplayOption.init(SizeOf(LabelDisplayOption_T),100);

          ALDO.fDisplayLabel := False;
          ALDO.sField := '';
          ALDO.AJustify := hjNone;

          for iCount := 1 to 100 do
              LabelDisplayOption.setValue(iCount,@ALDO);
     end;

     // make the array bigger if it is not big enough
     fLabelDisplayOption := True;

     ALDO.fDisplayLabel := fDL;
     ALDO.sField := sF;
     ALDO.AJustify := AJ;
     LabelDisplayOption.setValue(iLayer,@ALDO);
end;

function JustificationToString(const AJustify : tkHJustification) : string;
begin
     case AJustify of
          hjLeft : Result := 'Left';
          hjCenter : Result := 'Center';
          hjRight : Result := 'Right';
          hjNone : Result := 'None';
     end;
end;

function StringToJustification(const sJustify : string) : tkHJustification;
begin
     if (sJustify = '') then
        Result := hjNone
     else
         case sJustify[1] of
              'L' : Result := hjLeft;
              'C' : Result := hjCenter;
              'R' : Result := hjRight;
         else
             Result := hjNone;
         end;
end;

class function TOSInfo.IsWOW64: Boolean;
type
    TIsWow64Process = function(Handle: THandle; var Res: BOOL): BOOL; stdcall;
var
   IsWow64Result: BOOL;
   IsWow64Process: TIsWow64Process;
begin
     IsWow64Process := GetProcAddress(GetModuleHandle('kernel32'), 'IsWow64Process');

     if Assigned(IsWow64Process) then
     begin
          if not IsWow64Process(GetCurrentProcess, IsWow64Result) then
             raise Exception.Create('Bad process handle');
          Result := IsWow64Result;
     end
     else
         Result := False;
end;

function Detect64BitOS : boolean;
begin
     Result := TOSInfo.IsWOW64;

     (*if Result = True then
        ShowMessage('Running on 64-bit OS')
     else
         ShowMessage('NOT running on 64-bit OS');*)
end;

function OpacityRamp(const rValue, rMin, rMax : extended) : integer;
var
   rRampValue : extended;
begin
     rRampValue := rValue;
     if (rValue < rMin) then
        rRampValue := rMin;
     if (rValue > rMax) then
        rRampValue := rMax;

     Result := Round(((rRampValue - rMin) / (rMax - rMin)) * 255);
end;

function TRampBetweenColoursToKML(const Color : TColor; const iOpacity : integer;const rValue, rMin, rMax : extended) : string;
begin
     //
end;

function TColourToKMLRamp(const Color : TColor; const iOpacity : integer;const rValue, rMin, rMax : extended) : string;
var
   rRampValue, rDelta, rRed, rGreen, rBlue : extended;
begin
     rRampValue := rValue;
     if (rValue < rMin) then
        rRampValue := rMin;
     if (rValue > rMax) then
        rRampValue := rMax;
     rDelta := rMax - rMin;

     (*rRed := 0;
     rGreen := 0;
     rBlue := 0;

     if (rValue < (rMin + 0.25 * rDelta)) then
     begin
          rRed := 0;
          rGreen := 4 * (rValue - rMin) / rDelta;
     end
     else
         if (rValue < (rMin + 0.5 * rDelta)) then
         begin
              rRed := 0;
              rBlue := 1 + 4 * (rMin + 0.25 * rDelta - rValue) / rDelta;
         end
         else
             if (rValue < (rMin + 0.75 * rDelta)) then
             begin
                  rRed := 4 * (rValue - rMin - 0.5 * rDelta) / rDelta;
                  rBlue := 0;
             end
             else
             begin
                  rGreen := 1 + 4 * (rMin + 0.75 * rDelta - rValue) / rDelta;
                  rBlue := 0;
             end;*)

     rRed := 1 - ((rRampValue - rMin) / (rMax - rMin));
     rGreen := rRed;
     rBlue := rRed;

     // iOpacity must be between 0 (transparent) and 255 (opaque)
     Result := IntToHex(iOpacity,2) +
               IntToHex(Round(GetBValue(Color)*rBlue), 2) +
               IntToHex(Round(GetGValue(Color)*rGreen), 2) +
               IntToHex(Round(GetRValue(Color)*rRed), 2);
end;


function TColourToKML(const Color : TColor; const iOpacity : integer) : string;
begin
     // iOpacity must be between 0 (transparent) and 255 (opaque)
     Result := IntToHex(iOpacity,2) +
               IntToHex(GetBValue(Color), 2) +
               IntToHex(GetGValue(Color), 2) +
               IntToHex(GetRValue(Color), 2);
end;

function SmartOpenColour(const sColour : string) : TColor;
begin
     try
        if (Length(sColour) < 3) then
           Result := IndexToColour(StrToInt(sColour))
        else
            Result := HexToTColour(sColour);
     except
           MessageDlg('Exception in SmartOpenColour >' + sColour + '<',mtError,[mbOk],0);
           Application.Terminate;
     end;

end;

function TColourToHex(const Color : TColor) : string;
begin
     Result := IntToHex( GetRValue( Color ), 2 ) + // red
               IntToHex( GetGValue( Color ), 2 ) + // green
               IntToHex( GetBValue( Color ), 2 );  // blue
end;

function HexToTColour(const sColor : string) : TColor;
begin
     Result := RGB(StrToInt( '$'+Copy( sColor, 1, 2 ) ), // red
                   StrToInt( '$'+Copy( sColor, 3, 2 ) ), // green
                   StrToInt( '$'+Copy( sColor, 5, 2 ) ));// blue
end;

function RegionSafeStrToFloat(const sCell : string) : extended;
var
   iPos : integer;
begin
     // safely reads a float with a . as DecimalSeperator when the DecimalSeperator
     // is other that .
     try
        Result := StrToFloat(sCell);

     except
           // StrToFloat has failed, so substitute DecimalSeperator for . in sCell and try again
           iPos := Pos('.',sCell);
           if (iPos > 1) then
              Result := StrToFloat(Copy(sCell,1,iPos-1) + DecimalSeparator + Copy(sCell,iPos+1,Length(sCell)-iPos));
     end;
end;

function CustCompare(const sOne, sTwo : string;
                     const wSortType, wSortDirection : word) : boolean;
var
   rOne, rTwo : extended;
begin
     case wSortType of
          SORT_TYPE_REAL:
          begin
               try
                  Result := False;
                  if (sOne = '') then
                     rOne := -9999 // make blank string equivalent to -9999
                  else
                      rOne := RegionSafeStrToFloat(sOne);

                  if (sTwo = '') then
                     rTwo := -9999 // make blank string equivalent to zero
                  else
                      rTwo := RegionSafeStrToFloat(sTwo);

                  case wSortDirection of
                       0 : {Descending order}
                           if (rOne < rTwo) then
                              Result := True;
                       1 : {Ascending order}
                           if (rOne > rTwo) then
                              Result := True;
                  end;

               except on exception do;
               end;
          end;
          SORT_TYPE_STRING:
          begin
               Result := False;

               case wSortDirection of
                    0 : {Descending order}
                        if (sOne < sTwo) then
                           Result := True;
                    1 : {Ascending order}
                        if (sOne > sTwo) then
                           Result := True;
               end;
          end;
     end;
end;

procedure SortGrid(var AGrid : TStringGrid;
                   const iRowStartIndex, iColIndex : integer;
                   const wSortType, wSortDirection : word);
var
   iCount, iDBGCount : integer;
   fSwap : boolean;
   sLow,sHigh : string;
begin
     iDBGCount := 0;

     if (iRowStartIndex < (AGrid.RowCount-2))
     and (iColIndex < AGrid.ColCount) then
     begin
          AGrid.RowCount := AGrid.RowCount + 1;

          fSwap := True;
          while fSwap do
          begin
               fSwap := False;

               for iCount := iRowStartIndex to (AGrid.RowCount-3) do
                   begin
                        sLow := AGrid.Cells[iColIndex,iCount];
                        sHigh := AGrid.Cells[iColIndex,iCount + 1];

                        if CustCompare(sLow,sHigh,
                                       wSortType,
                                       wSortDirection {0 is descending, 1 is ascending}
                                       ) then
                        with AGrid do
                        begin
                             Rows[RowCount-1] := Rows[iCount];
                             Rows[iCount] := Rows[iCount+1];
                             Rows[iCount+1] := Rows[RowCount-1];

                             fSwap := True;
                        end;
                   end;

               Inc(iDbgCount);
          end;

          AGrid.RowCount := AGrid.RowCount - 1;
     end;
end;

procedure ForceDBFIntegerField(ATable : TTable; AQuery : TQuery; const sDBFFileName, sFieldName : string);
var
   iFieldsToAdd, iCount : integer;
   sTableName : string;
   fResult : boolean;
begin
     // if relevant field does not exist in the shape file, create it with an sql query
     try
        ATable.DatabaseName := ExtractFilePath(sDBFFileName);
        ATable.TableName := ExtractFileName(sDBFFileName);;
        ATable.Open;

        AQuery.SQL.Clear;
        AQuery.SQL.Add('ALTER TABLE "' + sDBFFileName + '"');

        iFieldsToAdd := 0;
        fResult := False;

        for iCount := 0 to (ATable.FieldDefs.Count-1) do
            if (sFieldName = ATable.FieldDefs.Items[iCount].Name) then
               fResult := True;

        if not fResult then
        begin
             Inc(iFieldsToAdd);

             AQuery.SQL.Add('ADD ' + sFieldName + ' NUMERIC(10,0)');
        end;

        ATable.Close;

        if (iFieldsToAdd > 0) then
        begin
             AQuery.Prepare;
             AQuery.ExecSQL;
             AQuery.Close;
        end;

     except
           AQuery.SQL.SaveToFile(ATable.DatabaseName + '\error.sql');
           MessageDlg('Exception in ForceDBFIntegerField ' + sDBFFileName + ' ' + sFieldName,mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

function ShiftKeyDown : Boolean;
var
   State : TKeyboardState;
begin
   GetKeyboardState(State) ;
   Result := ((State[vk_Shift] and 128) <> 0) ;
end;

function DDESendCmd(const ThisDDEConv : TDDEClientConv; const sCommand : string) : boolean;
var
   MacroCmd : array [0..250] of char;
begin
     {send a macro command to the server}
     Result := False;

     if (Length(sCommand) < 250) then
     begin
          StrPCopy(MacroCmd,sCommand);
          {pascal string to null terminated string}

          if ThisDDEConv.ExecuteMacro(MacroCmd,False) then
             Result := True;
     end
     else
     begin
          MessageDlg('Message longer than 249 characters in DDESendCmd',mtError,[mbOk],0);
     end;
end;

function Return_R_InstallPath : string;
var
   Reg: TRegistry;
   sValue : string;
begin
     sValue := '';

     Reg := TRegistry.Create(KEY_READ);
     try
        Reg.RootKey := HKEY_LOCAL_MACHINE;
        if Reg.OpenKey('\Software\R-core\R', False) then
           sValue := Reg.ReadString('InstallPath');

     finally
            Reg.CloseKey;
            Reg.Free;
     end;
     
     if (sValue = '') then
     begin
          Reg := TRegistry.Create(KEY_READ);
          try
             sValue := '';
             Reg.RootKey := HKEY_CURRENT_USER;
             if Reg.OpenKey('\Software\R-core\R', False) then
                sValue := Reg.ReadString('InstallPath');

          finally
                 Reg.CloseKey;
                 Reg.Free;
          end;
     end;

     Result := sValue;
end;

function FileContainsCommas(const sFilename : string) : boolean;
var
   InFile : TextFile;
   sLine : string;
begin
     assignfile(InFile,sFilename);
     reset(InFile);
     readln(InFile,sLine);
     closefile(InFile);

     Result := (CountDelimitersInRow(sLine,',') > 0);
end;

function CovertLineDelimitersTabToComma(const sLine : string) : string;
var
   iCount : integer;
begin
     Result := '';
     for iCount := 1 to Length(sLine) do
     begin
          if (Ord(sLine[iCount]) < 32) then
             Result := Result + ','
          else
              Result := Result + sLine[iCount];
     end;
end;

procedure ConvertFileDelimiter_TabToComma(const sFilename : string);
var
   InFile, OutFile : TextFile;
   sLine : string;
begin
     ACopyFile(sFilename,sFilename + '~');
     DeleteFile(sFilename);

     assignfile(InFile,sFilename + '~');
     reset(InFile);

     assignfile(OutFile,sFilename);
     rewrite(OutFile);

     repeat
           readln(InFile,sLine);
           writeln(OutFile,CovertLineDelimitersTabToComma(sLine));

     until Eof(InFile);

     closefile(InFile);
     closefile(OutFile);
end;

function GenerateSubFilename(const sFilename, sSubname : string) : string;
var
   sExt, sPath, sFile : string;
begin
     sExt := ExtractFileExt(sFilename);
     sPath := ExtractFilePath(sFilename);
     sFile := ExtractFileName(sFilename);
     sFile := Copy(sFile,1,Length(sFile) - Length(sExt));

     Result := sPath + sFile + '_' + sSubname + sExt;
end;

function ReturnFieldIndex(const sFieldName, sLine : string) : integer;
var
   iCount, iFieldCount : integer;
begin
     Result := -1;
     iFieldCount := CountDelimitersInRow(sLine,',') + 1;
     for iCount := 1 to iFieldCount do
         if (LowerCase(sFieldName) = LowerCase(TrimEnclosingQuotes(GetDelimitedAsciiElement(sLine,',',iCount)))) then
            Result := iCount;
end;

function BinaryLookup_Integer(IntArr : Array_t; iMatch, iTop, iBottom : integer) : integer;
//int puno,int name, struct binsearch PULookup[]
var
   iCentre, iCount, iCentreValue : integer;
   fLoop : boolean;
begin
     // use a binary search to find the index of planning unit iMatch
     // IntArr is in numeric order

     iCentre := iTop + floor((iBottom - iTop) / 2);

     IntArr.rtnValue(iCentre,@iCentreValue);
     fLoop := True;

     while ((iTop <= iBottom) and (iCentreValue <> iMatch) and fLoop) do
     begin
          if (iMatch < iCentreValue) then
          begin
               iBottom := iCentre - 1;
               if (iBottom < iTop) then
               begin
                    iBottom := iTop;
                    fLoop := False;
               end;
               iCount := iBottom - iTop + 1;
               iCentre := iTop + floor(iCount / 2);
          end
          else
          begin
               iTop := iCentre + 1;
               if (iTop > iBottom) then
               begin
                    iTop := iBottom;
                    fLoop := False;
               end;
               iCount := iBottom - iTop + 1;
               iCentre := iTop + floor(iCount / 2);
          end;

          IntArr.rtnValue(iCentre,@iCentreValue);
     end;

     if (iCentreValue = iMatch) then
        Result := iCentre
     else
         Result := -1;
end;

function BinaryLookupGrid_Integer(LookupGrid : TStringGrid; iMatch, iColumn, iTop, iBottom : integer) : integer;
//int puno,int name, struct binsearch PULookup[]
var
   iCentre, iCount, iCentreValue : integer;
   fLoop : boolean;
begin
     // use a binary search to find the index of planning unit iMatch
     // LookupGrid column iColumn is in numeric order

     iCentre := iTop + floor((iBottom - iTop) / 2);

     //IntArr.rtnValue(iCentre,@iCentreValue);
     iCentreValue := StrToInt(LookupGrid.Cells[iColumn,iCentre]);
     fLoop := True;

     while ((iTop <= iBottom) and (iCentreValue <> iMatch) and fLoop) do
     begin
          if (iMatch < iCentreValue) then
          begin
               iBottom := iCentre - 1;
               if (iBottom < iTop) then
               begin
                    iBottom := iTop;
                    fLoop := False;
               end;
               iCount := iBottom - iTop + 1;
               iCentre := iTop + floor(iCount / 2);
          end
          else
          begin
               iTop := iCentre + 1;
               if (iTop > iBottom) then
               begin
                    iTop := iBottom;
                    fLoop := False;
               end;
               iCount := iBottom - iTop + 1;
               iCentre := iTop + floor(iCount / 2);
          end;

          //IntArr.rtnValue(iCentre,@iCentreValue);
          iCentreValue := StrToInt(LookupGrid.Cells[iColumn,iCentre]);
     end;

     if (iCentreValue = iMatch) then
        Result := iCentre
     else
         Result := -1;
end;

function ReserveOrder_BinaryLookup_Integer(IntArr : Array_t; iMatch, iTop, iBottom : integer) : integer;
//int puno,int name, struct binsearch PULookup[]
var
   iCentre, iCount, iCentreValue : integer;
   fLoop : boolean;
begin
     // use a binary search to find the index of planning unit iMatch
     // IntArr is in reverse numeric order

     iCentre := iTop + floor((iBottom - iTop) / 2);

     IntArr.rtnValue(iCentre,@iCentreValue);
     fLoop := True;

     while ((iTop <= iBottom) and (iCentreValue <> iMatch) and fLoop) do
     begin
          if (iMatch > iCentreValue) then
          begin
               iBottom := iCentre - 1;
               if (iBottom < iTop) then
               begin
                    iBottom := iTop;
                    fLoop := False;
               end;
               iCount := iBottom - iTop + 1;
               iCentre := iTop + floor(iCount / 2);
          end
          else
          begin
               iTop := iCentre + 1;
               if (iTop > iBottom) then
               begin
                    iTop := iBottom;
                    fLoop := False;
               end;
               iCount := iBottom - iTop + 1;
               iCentre := iTop + floor(iCount / 2);
          end;

          IntArr.rtnValue(iCentre,@iCentreValue);
     end;

     if (iCentreValue = iMatch) then
        Result := iCentre
     else
         Result := -1;
end;

function TrimEnclosingQuotes(const sLine : string) : string;
begin
     if (sLine[1] = '"') and (sLine[Length(sLine)] = '"') then
        Result := Copy(sLine,2,Length(sLine)-2);
end;

function IndexToColour(const iIndex : integer) : TColor;
var
   iSmallIndex : integer;
begin
     if (iIndex > 13) then
        iSmallIndex := iIndex mod 14
     else
         iSmallIndex := iIndex;

     case iSmallIndex of
          0 : Result := clBlue;
          1 : Result := clMaroon;
          2 : Result := clGreen;
          3 : Result := clOlive;
          4 : Result := clNavy;
          5 : Result := clPurple;
          6 : Result := clTeal;
          7 : Result := clGray;
          8 : Result := clSilver;
          9 : Result := clRed;
          10 : Result := clLime;
          11 : Result := clYellow;
          12 : Result := clFuchsia;
          13 : Result := clAqua;
     else
         Result := clBlue;
     end;
end;

(*function ColourToIndex(const AColor : TColor) : integer;
begin
     case AColor of
          clBlack : Result := 0;
          clMaroon : Result := 1;
          clGreen : Result := 2;
          clOlive : Result := 3;
          clNavy : Result := 4;
          clPurple : Result := 5;
          clTeal : Result := 6;
          clGray : Result := 7;
          clSilver : Result := 8;
          clRed : Result := 9;
          clLime : Result := 10;
          clYellow : Result := 11;
          clBlue : Result := 12;
          clFuchsia : Result := 13;
          clAqua : Result := 14;
          clWhite : Result := 15;
     else
         Result := 0;
     end;
end;*)

procedure ProgramRunWaitCmdLine(const ApplicationLine,CommandLine,DefaultDirectory: string;Wait: boolean; fHideWindow : boolean);
var
   StartUpInfo: TStartUpInfo;
   ProcInfo: Process_Information;
   Dir, Msg: PChar;
   ErrNo: integer;
   E: Exception;
begin
     FillChar(StartUpInfo, SizeOf(StartUpInfo), 0);
     StartUpInfo.cb := SizeOf(StartUpInfo);
     if fHideWindow then
     begin
          StartUpInfo.dwFlags := STARTF_USESHOWWINDOW;
          StartUpInfo.wShowWindow := SW_HIDE;//SW_MINIMIZE;
     end;
     if DefaultDirectory <> '' then
        Dir := PChar(DefaultDirectory)
     else
         Dir := nil;
     if CreateProcess(PChar(ApplicationLine),PChar(CommandLine),nil,nil,False,0,nil,Dir,StartUpInfo,ProcInfo) then
     begin
          try
             hMarxanProcess := ProcInfo.hProcess;
             if Wait then
                WaitForSingleObject(ProcInfo.hProcess,INFINITE);

          finally
                 CloseHandle(ProcInfo.hThread);
                 CloseHandle(ProcInfo.hProcess);
          end;
     end
     else
     begin
          ErrNo := GetLastError;
          Msg := AllocMem(4096);
          try
             FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM,nil,ErrNo,0,Msg,4096,nil);
             E := Exception.Create('Create Process Error #' + IntToStr(ErrNo) + ': ' + string(Msg));
          finally
                 FreeMem(Msg);
          end;
          raise E;
     end;
end;

procedure ProgramRunWait(const CommandLine,DefaultDirectory: string;Wait: boolean; fHideWindow : boolean);
var
   StartUpInfo: TStartUpInfo;
   ProcInfo: Process_Information;
   Dir, Msg: PChar;
   ErrNo: integer;
   E: Exception;
begin
     FillChar(StartUpInfo, SizeOf(StartUpInfo), 0);
     StartUpInfo.cb := SizeOf(StartUpInfo);
     if fHideWindow then
     begin
          StartUpInfo.dwFlags := STARTF_USESHOWWINDOW;
          StartUpInfo.wShowWindow := SW_HIDE;//SW_MINIMIZE;
     end;
     if DefaultDirectory <> '' then
        Dir := PChar(DefaultDirectory)
     else
         Dir := nil;
     if CreateProcess(nil,PChar(CommandLine),nil,nil,False,0,nil,Dir,StartUpInfo,ProcInfo) then
     begin
          try
             hMarxanProcess := ProcInfo.hProcess;
             if Wait then
                WaitForSingleObject(ProcInfo.hProcess,INFINITE);

          finally
                 CloseHandle(ProcInfo.hThread);
                 CloseHandle(ProcInfo.hProcess);
          end;
     end
     else
     begin
          ErrNo := GetLastError;
          Msg := AllocMem(4096);
          try
             FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM,nil,ErrNo,0,Msg,4096,nil);
             E := Exception.Create('Create Process Error #' + IntToStr(ErrNo) + ': ' + string(Msg));
          finally
                 FreeMem(Msg);
          end;
          raise E;
     end;
end;

function CountDelimitersInRow(const sRow, sDelimiter : string) : integer;
var
   iCount : integer;
begin
     Result := 0;
     if (Length(sRow) > 0) then
        for iCount := 1 to Length(sRow) do
            if (sRow[iCount] = sDelimiter) then
               Inc(Result);
end;

function GetDelimitedAsciiElement_smart(const sRow, sDelimiter : string;const iColumn : integer) : string;
// returns the element at 1-based-index column iColumn
var
   iStart, iEnd, iFieldCount, iLength, iCount : integer;
   fInField : boolean;
begin
     Result := '';
     fInField := False;

     // find the start and end of field iColumn
     iFieldCount := 0;
     iStart := 0;
     iEnd := 0;
     iLength := Length(sRow);
     if (iLength > 0) then
        for iCount := 1 to iLength do
        begin
             if (sRow[iCount] = '"') then
                fInField := not fInField;

             if (sRow[iCount] = sDelimiter) then
                if not fInField then
                begin
                     Inc(iFieldCount);
                     if (iFieldCount = iColumn) then
                        iStart := iCount + 1;
                     if (iFieldCount = (iColumn+1)) then
                        iEnd := iCount - 1;
                end;
        end;

     if (iEnd = 0) then
        iEnd := iLength;

     if (iStart < iEnd) then
        Copy(sRow,iStart,iEnd-iStart+1)
     else
         Result := '';
end;

function GetDelimitedAsciiElement(const sLine, sDelimiter : string;const iColumn : integer) : string;
// returns the element at 1-based-index column iColumn
var
   sTrimLine : string;
   iPos, iTrim, iCount : integer;
begin
     Result := '';

     sTrimLine := sLine;
     iTrim := iColumn-1;
     if (iTrim > 0) then
        for iCount := 1 to iTrim do // trim the required number of columns from the start of the string
        begin
             iPos := Pos(sDelimiter,sTrimLine);
             if (iPos > 0) then
                sTrimLine := Copy(sTrimLine,iPos+1,Length(sTrimLine)-iPos)
             else
                 sTrimLine := '';
        end;
     iPos := Pos(sDelimiter,sTrimLine);
     if (iPos = 1) then
     begin
          Result := '';
     end
     else
     begin
          if (iPos > 0) then
             Result := Copy(sTrimLine,1,iPos-1)
          else
              Result := sTrimLine;
     end;
end;

procedure AutoFitGrid(AGrid : TStringGrid; Canvas : TCanvas; const fFitEntireGrid : boolean);
// fFitEntireGrid = True   means fit entire grid
//                  False  means fit selected area
//
// Canvas is the Canvas of the form containing AGrid
var
   iRowCount,
   iColumnCount,
   iMaxColumnWidth,
   iCurrentColumnWidth : integer;
begin
     // auto fit the table with user parameters
     try
        if fFitEntireGrid then
        begin
             // auto fit entire table
             // for each column, determine the maximum width by scanning all cells in the column
             for iColumnCount := 0 to (AGrid.ColCount-1) do
             begin
                  iMaxColumnWidth := 0;
                  for iRowCount := 0 to (AGrid.RowCount-1) do
                  begin
                       iCurrentColumnWidth := Canvas.TextWidth(AGrid.Cells[iColumnCount,iRowCount]);
                       if (iCurrentColumnWidth > iMaxColumnWidth) then
                          iMaxColumnWidth := iCurrentColumnWidth;
                  end;
                  // set ColWidths for this column
                  AGrid.ColWidths[iColumnCount] := iMaxColumnWidth + 4;
             end;
        end
        else
        begin
             // auto fit selected rows and columns
             for iColumnCount := AGrid.Selection.Left to AGrid.Selection.Right do
             begin
                  iMaxColumnWidth := 0;
                  for iRowCount := AGrid.Selection.Top to AGrid.Selection.Bottom do
                  begin
                       iCurrentColumnWidth := Canvas.TextWidth(AGrid.Cells[iColumnCount,iRowCount]);
                       if (iCurrentColumnWidth > iMaxColumnWidth) then
                          iMaxColumnWidth := iCurrentColumnWidth;
                  end;
                  AGrid.ColWidths[iColumnCount] := iMaxColumnWidth + 4;
             end;
        end;

     except
           //Screen.Cursor := crDefault;
           MessageDlg('Exception AutoFitGrid',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

function TrimLeadSpaces(const sLine : string) : string;
var
   sTmp : string;
begin
     sTmp := sLine;

     while (sTmp[1] = ' ') do
     begin
          if (Length(sTmp) > 1) then
             sTmp := Copy(sTmp,2,Length(sTmp)-1);
     end;

     Result := sTmp;
end;

function TrimTrailingSlashes(const sLine : string) : string;
var
   sResult : string;
begin
     sResult := sLine;
     repeat
           if (sResult[Length(sResult)] = '\') then
              sResult := Copy(sResult,1,Length(sResult)-1);

     until (sResult[Length(sResult)] <> '\');

     Result := sResult;
end;

function TestCellContainsComma(sLine : string) : string;
begin
     {}
     if (Pos(',',sLine) > 0) then
        Result := '"' + sLine + '"'
     else
         Result := sLine;
end;

procedure SaveStringGrid2CSV(AGrid : TStringGrid; const sFile : string);
var
   OutFile : Text;

   iCountRows,iCountCols : integer;

   fFilesOk : boolean;

begin
     fFilesOk := True;

     Assign(OutFile,sFile);

     try
        Rewrite(OutFile);

     except on EInOutError do
            begin
                 //Screen.Cursor := crDefault;

                 MessageDlg('Could not create output CSV file ' + sFile,
                            mtError,[mbOk],0);

                  fFilesOk := False;
            end;
     end;

     if fFilesOk then
     begin
          {now create the datafile}
          for iCountRows := 0 to (AGrid.RowCount-1) do
          begin
               for iCountCols := 0 to (AGrid.ColCount-2) do
                   write(OutFile,TestCellContainsComma(AGrid.Cells[iCountCols,iCountRows]) + ',');
               writeln(OutFile,TestCellContainsComma(AGrid.Cells[AGrid.ColCount-1,iCountRows]));
          end;

          close(OutFile);
     end;
end;

function NextCharPos(const cSearchChar : char;
                     const sString : string;
                     const iStartPos, iStringLength : integer) : integer;
var
   iPos : integer;
   fEnd : boolean;
begin
     iPos := iStartPos;
     fEnd := False;
     while (not fEnd) do
     begin
          if (iPos <= iStringLength) then
          begin
               if (sString[iPos] = cSearchChar) then
               begin
                    fEnd := True;
                    Result := iPos;
               end
               else
               begin
                    Inc(iPos);
               end;
          end
          else
          begin
               fEnd := True;
               Result := -1; // character not found
          end;
     end;
end;

procedure FasterLoadCSV2StringGrid(AGrid : TStringGrid; const sFile : string);
var
     InFile : TextFile;
     sLine : string;
     iRows, iColumns, iRow, iStartPos, iCommaPos, iLength : integer;

     procedure PopulateRow(const iR : integer);
     var
          iCount : integer;
     begin
          iStartPos := 1;
          for iCount := 1 to iColumns do
          begin
               iCommaPos := NextCharPos(',',sLine,iStartPos,iLength);

               if (iCommaPos = iStartPos) then
                  AGrid.Cells[iCount-1,iR] := ''
               else
               if (iCommaPos > 0) then
                  AGrid.Cells[iCount-1,iR] := Copy(sLine,iStartPos,iCommaPos-iStartPos)
               else
                   AGrid.Cells[iCount-1,iR] := Copy(sLine,iStartPos,iLength-iStartPos+1);

               iStartPos := iCommaPos + 1;
          end;
     end;

begin
     try
        // parse file and find dimensions
        assignfile(InFile,sFile);
        reset(InFile);
        readln(InFile,sLine);
        iColumns := CountDelimitersInRow(sLine,',') + 1;
        iRows := 1;
        repeat
               readln(InFile,sLine);
               Inc(iRows);

        until Eof(InFile);
        closefile(InFile);
        // resize the grid
        AGrid.RowCount := iRows;
        AGrid.ColCount := iColumns;
        // parse file and load into grid
        assignfile(InFile,sFile);
        reset(InFile);
        readln(InFile,sLine);
        iLength := Length(sLine);
        PopulateRow(0);
        iRow := 1;
        repeat
               readln(InFile,sLine);
               iLength := Length(sLine);
               PopulateRow(iRow);
               Inc(iRow);

        until Eof(InFile);
        closefile(InFile);

     except
           MessageDlg('Exception in faster load CSV file',mtError,[mbOk],0);
           Application.Terminate;
     end;
end;

(*
procedure FastLoadCSV2StringGrid(AGrid : TStringGrid; const sFile : string);
var
     InFile : TextFile;
     sHeader, sLine, sScratch : string;
     iRows, iColumns, iRow, iPos : integer;

     procedure PopulateRow(const iR : integer;
                           const sL : string);
     var
          iCount : integer;
     begin
          sScratch := sL;
          for iCount := 1 to iColumns do
          begin
               iPos := Pos(',',sScratch);
               if (iPos > 0) then
               begin
                    AGrid.Cells[iCount-1,iR] := Copy(sScratch,1,iPos-1);
                    sScratch := Copy(sScratch,iPos+1,Length(sScratch)-iPos);
               end
               else
               begin
                    AGrid.Cells[iCount-1,iR] := sScratch;
                    sScratch := '';
               end;
          end;
     end;

begin
     try
        // parse file and find dimensions
        assignfile(InFile,sFile);
        reset(InFile);
        readln(InFile,sHeader);
        iColumns := CountCommasInLine(sHeader) + 1;
        iRows := 1;
        repeat
               readln(InFile,sLine);
               Inc(iRows);

        until Eof(InFile);
        closefile(InFile);
        // resize the grid
        AGrid.RowCount := iRows;
        AGrid.ColCount := iColumns;
        // parse file and load into grid
        assignfile(InFile,sFile);
        reset(InFile);
        readln(InFile,sHeader);
        PopulateRow(0,sHeader);
        iRow := 1;
        repeat
               readln(InFile,sLine);
               PopulateRow(iRow,sLine);
               Inc(iRow);

        until Eof(InFile);
        closefile(InFile);

     except
           //Screen.Cursor := crDefault;
           MessageDlg('Exception in fast load CSV file',mtError,[mbOk],0);
     end;
end;
*)

function AFastCopyFile(const sSourceFile, sDestFile : string) : boolean;
var
   iHInFile, iHOutFile, iFilePos,
   iBytesRead, iBytesWritten : integer;
   WordArray : array[1..32768] of word;
begin
     Result := True;
     iHInFile := FileOpen(sSourceFile,fmShareDenyNone);
     iBytesWritten := 0;

     if (iHInFile > 0) then
     begin
          iHOutFile := FileCreate(sDestFile);

          if (iHOutFile > 0) then
          begin
               iFilePos := 0;

               repeat
                     FileSeek(iHInFile,iFilePos,0);

                     iBytesRead := FileRead(iHInFile,WordArray,32768);

                     if (iBytesRead > 0) then
                     begin
                          FileSeek(iHOutFile,iFilePos,0);
                          Inc(iFilePos,iBytesRead);
                          iBytesWritten := FileWrite(iHOutFile,WordArray,iBytesRead);
                     end;

               until (iBytesWritten < 1)
               or (iBytesRead < 1);

               FileClose(iHOutFile);
          end
          else
              Result := False;

          FileClose(iHInFile);

          if (iBytesWritten < 1) then
             Result := False;
     end
     else
     begin

          MessageDlg('Cannot find ' + sSourceFile + '  Please contact software support',
                     mtError,[mbOk],0);

          Result := False;
     end;
end;

function ACopyFile(const sSourceFile, sDestFile : string) : boolean;
var
   iHInFile, iHOutFile, iFilePos,
   iBytesRead, iBytesWritten : integer;
   wWord : word;
begin
     Result := AFastCopyFile(sSourceFile,sDestFile);

     (*
     Result := True;
     iHInFile := FileOpen(sSourceFile,fmShareDenyNone);
     iBytesWritten := 0;

     if (iHInFile > 0) then
     begin
          iHOutFile := FileCreate(sDestFile);

          if (iHOutFile > 0) then
          begin
               iFilePos := 0;

               repeat
                     FileSeek(iHInFile,iFilePos,0);

                     iBytesRead := FileRead(iHInFile,wWord,1);

                     if (iBytesRead = 1) then
                     begin
                          FileSeek(iHOutFile,iFilePos,0);
                          Inc(iFilePos);
                          iBytesWritten := FileWrite(iHOutFile,wWord,1);
                     end;

               until (iBytesWritten < 1)
               or (iBytesRead < 1);

               FileClose(iHOutFile);
          end
          else
              Result := False;

          FileClose(iHInFile);

          if (iBytesWritten < 1) then
             Result := False;
     end
     else
     begin

          MessageDlg('Cannot find ' + sSourceFile + '  Please contact software support',
                     mtError,[mbOk],0);

          Result := False;
     end;
     *)
end;

procedure CopyIfExists(sFileName,sInputDir,sOutputDir : string);
var
   sIn, sOut : string;
begin
     if (sFileName <> '') then
     begin
          sIn := sInputDir + '\' + sFileName;

          if fileexists(sIn) then
          begin
               sOut := sOutputDir + '\' + sFileName;

               if fileexists(sOut) then
                  DeleteFile(sOut);

               ACopyFile(sIn,sOut);
          end;
     end;
end;

function PadInt(const iInt,iDigits : integer) : string;
begin
     Result := IntToStr(iInt);

     if (Length(Result) < iDigits) then
        repeat
              Result := '0' + Result;

        until (Length(Result) >= iDigits);
end;

function probZUT(const z : extended) : extended;
// Probability that a standard normal random variable has value >= z
// (i.e. the area under the standard normal curve for Z in [z,+inf]

// Originally adapted by Gary Perlman from a polynomial approximation in:
// Ibbetson D, Algorithm 209
// Collected Algorithms of the CACM 1963 p. 616
// Adapted (returns upper tail instead of lower tail)

// This function is not copyrighted
var
   Z_MAX, y, x, w, rResult : extended;
begin
     Z_MAX := 5;

     if (z = 0) then
        x := 0
     else
     begin
          y := 0.5 * abs (z);
          if (y >= (Z_MAX * 0.5)) then
             x := 1
          else
              if (y < 1) then
              begin
                   w := y*y;
                   x := ((((((((0.000124818987 * w
                         -0.001075204047) * w +0.005198775019) * w
                         -0.019198292004) * w +0.059054035642) * w
                         -0.151968751364) * w +0.319152932694) * w
                         -0.531923007300) * w +0.797884560593) * y * 2.0;
              end
              else
              begin
                   y := y - 2;
                   x := (((((((((((((-0.000045255659 * y
                         +0.000152529290) * y -0.000019538132) * y
                         -0.000676904986) * y +0.001390604284) * y
                         -0.000794620820) * y -0.002034254874) * y
                         +0.006549791214) * y -0.010557625006) * y
                         +0.011630447319) * y -0.009279453341) * y
                         +0.005353579108) * y -0.002141268741) * y
                         +0.000535310849) * y +0.999936657524;
              end;
     end;

     if (z < 0) then
        rResult := ((x + 1) * 0.5)
     else
         rResult := ((1 - x) * 0.5);

     Result := rResult;
end;

end.
