
function samesqr(a,b : square_t) : boolean;
begin
     Result := FALSE;

     if a.x1 <> b.x1 then exit;
     if a.x2 <> b.x2 then exit;
     if a.y1 <> b.y1 then exit;
     if a.y2 <> b.y2 then exit;

     Result := TRUE;
end;

function direct2d(Actual,Base : square_t) : TwoDTransformation;
var
   minMidX : longint;
   minMidY : longint;

begin
     Result := Reverse;

     minMidX := (Base.x2 - Base.x1 + 1) div 2;
     minMidX := minMidX + Base.x1-1;
     minMidY := (Base.y2 - Base.y1 + 1) div 2;
     minMidY := minMidY + Base.y1-1;

     if not(samesqr(Actual,Base)) then
     begin
          if Actual.x1 >= Base.x1 then
          begin
               if Actual.y1 >= Base.y1 then
               begin
                    if Actual.x2 <= Base.x2 then
                    begin
                         if Actual.y2 <= Base.y2 then
                         begin
                              if Actual.x2 <= minMidX then
                              begin
                                   if Actual.y2 <= minMidY then
                                   begin
                                        result := TopLeft;
                                   end
                                   else
                                   begin
                                        result := BottomLeft;
                                   end;
                              end
                              else
                              begin
                                   if Actual.y2 <= minMidY then
                                   begin
                                        result := TopRight;
                                   end
                                   else
                                   begin
                                        result := BottomRight;
                                   end;
                              end;
                         end;
                    end;
               end;
          end;
     end
     else
         Result := Nothing;

end;


function TwoDimData.SameAs(comp : Square_t) : boolean;
begin
     result := TRUE;
     if data.x1 <> comp.x1 then result := FALSE;
     if data.x2 <> comp.x2 then result := FALSE;
     if data.y1 <> comp.y1 then result := FALSE;
     if data.y2 <> comp.y2 then result := FALSE;
end;

function TwoDimData.Same(szWhere : string; LimX,LimY : longint) : boolean;
type
    byteArray = array[1..1000] of byte;
    wordArray = array[1..1000] of word;
var
   l : longint;
   x : longint;
   bytebuffer : ^byteArray;
   wordbuffer : ^wordArray;
   ToRead : integer;
   ActualRead : integer;
   OriginalX : longint;


begin
     case datasize of
          1 : begin
                   new(bytebuffer);
              end;
          2 : begin
                   new(wordbuffer);
              end;
          else begin
                    messagedlg('Unknown data size',mterror,[mbok],0);
                    halt;
               end;
     end;

     Result := TRUE;

     if LimX < 1000 then
       if (data.x2 - data.x1 + 1) < 1000 then
           ToRead := data.x2 - data.x1 + 1
       else
           messagedlg('Too large a space to compare',mtinformation,[mbok],0)
     else
     begin
          messagedlg('Need to buffer the SAME test',mtinformation,[mbok],0);
          halt;
     end;

     if uppercase(szWhere) = 'DISK' then
     begin
          OriginalX := data.y1;
          repeat
                seek(datafile,asLinear(LimX));
//                l := asLinear(limX);
                case datasize of
                     1 : begin
                              blockread(dataFile,bytebuffer^,ToRead,ActualRead);
                              if OriginalX = data.y1 then
                              begin
                                   Originalbyte := bytebuffer^[1];
                              end;
                              for x := 1 to ActualRead do
                              begin
                                   if OriginalByte <> byteBuffer^[x] then
                                   begin
                                        Result := FALSE;
                                        Data.y1 := data.y2;
                                        break;
                                   end;
                              end;
                         end;
                     2 : begin
                              blockread(dataFile,wordbuffer^,ToRead,ActualRead);
                              if OriginalX = data.y1 then
                              begin
                                   Originalword := wordbuffer^[1];
                              end;
                              for x := 1 to ActualRead do
                              begin
                                   if OriginalWord <> wordBuffer^[x] then
                                   begin
                                        Result := FALSE;
                                        Data.y1 := data.y2;
                                        break;
                                   end;
                              end;
                         end;
                end;
                data.y1 := data.y1+1;
          until data.y1 > data.y2;
          data.y1 := OriginalX;
     end
     else
     begin
          messagedlg('I Dont know where the data is!',mtError,[mbok],0);
          halt;
     end;

     case datasize of
          1 : begin
                   dispose(bytebuffer);
              end;
          2 : begin
                   dispose(wordbuffer);
              end;
     end;
end;

procedure TwoDimData.definedata(startrefx,startrefy : longint; mag : longint);
var
   okmag : longint;

   function valid(var mag : longint) : boolean;
   begin
        okMag := 1;

        while okMag < mag do
        begin
             okMag := okMag *2;
        end;

        if Mag = okMag then
           Result := TRUE
        else
            Result := FALSE;
   end;

   procedure makevalid(var mag : longint);
   begin
        mag := okMag;
   end;

begin
     if not(valid(mag)) then makevalid(mag);

     Data.x1 := startrefx;
     Data.y1 := startrefy;
     Data.x2 := startrefx-1+mag;
     Data.y2 := startrefx-1+mag;
end;

function TwoDimData.whichway(desired : square_T) : TwoDTransformation;
{Trying to get data to desired}
var
   range : longint;
begin
     range := Data.x2-Data.x1;
     range := (range div 2);
     inc(range);

     Result := Reverse;

     //Looking for Right Half
     if (Desired.x1 >= (Data.x1 + Range)) and
        (Desired.x2 <= Data.x2)then
     begin
          //Looking for Top Half
          if (Desired.y2 < (Data.y1 + Range)) and
             (Desired.y1 >= Data.y1)then
          begin
               Result := TopRight;
          end
          else
          begin
          //Ensure we have the Bottom half
               if (Desired.y1 >= (Data.y1 + Range)) and
                  (Desired.y2 <= Data.y2)then
               begin
                    Result := BottomRight;
               end
               else
               begin
                    messagedlg('Some form of error we appear to be out of scope R- T/B',mterror,[mbok],0);
                    halt;
               end;

          end;
     end
     else
     begin
     //Ensure we have the Left half
          if (Desired.x2 < (Data.x1 + Range)) and
             (Desired.x1 >= Data.x1)then
          begin
          //Looking for Top Half
          if (Desired.y2 < (Data.y1 + Range)) and
             (Desired.y1 >= Data.y1)then
          begin
               Result := TopLeft;
          end
          else
          begin
          //Ensure we have the Bottom half
               if (Desired.y1 >= (Data.y1 + Range)) and
                  (Desired.y2 <= Data.y2)then
               begin
                    Result := BottomLeft;
               end
               else
               begin
                    messagedlg('Some form of error we appear to be out of scope L- T/B',mterror,[mbok],0);
                    halt;
               end;

          end;
          end
          else
          begin
//               messagedlg('Reversing',mterror,[mbok],0);
//               halt;
          end;

     end;
end;

function TwoDimData.TransformData(trans : TwoDTransformation) : Square_t;
{
  x1
y1|----------|
  | TL  | TR |
  |__________|
  |     |    |
  | BL  | BR |
  |----------|x2
           y2
}
var
   range : longint;
begin
     Result := Data;
     range := Data.x2-Data.x1;
     range := (range div 2);
     {if range <> 0 then}
     inc(range);
     case trans of
         BottomLeft : begin
                           Result.y1 := Data.y1+range;
                           Result.x2 := Data.x2-range;
                      end;
         BottomRight : begin
                            Result.x1 := Data.x1 + range;
                            Result.y1 := Data.y1 + range;
                       end;
         TopLeft : begin
                           Result.x2 := Data.x2-range;
                           Result.y2 := Data.y2-range;
                   end;
         TopRight : begin
                           Result.x1 := Data.x1 + range;
                           Result.y2 := Data.y2-range;
                    end;
         else
             begin
                  messagedlg('unrecognised transformation direction',mterror,[mbok],0);
                  Result := Data;
             end;
     end;
end;

procedure TwoDimData.setValues(const newValues : square_t);
begin
     data := newValues;
end;

function TwoDimData.asLinear(xMax : longint) : longint;
begin
     Result := (data.y1-1) * xMax + data.x1-1;
end;

constructor DimData.create;
begin
     inherited create;
end;

destructor DimData.destroy;
begin
     inherited destroy;
end;

procedure DimData.free;
begin
     inherited free;
end;

constructor TwoDimData.create;
begin
     inherited create;

     data.x1 := 0;
     data.y1 := 0;
     data.x2 := 0;
     data.y2 := 0;
end;

destructor TwoDimData.destroy;
begin
     data.x1 := 0;
     data.y1 := 0;
     data.x2 := 0;
     data.y2 := 0;

     inherited destroy;
end;

procedure TwoDimData.free;
begin
     data.x1 := 0;
     data.y1 := 0;
     data.x2 := 0;
     data.y2 := 0;

     inherited free;
end;

constructor ThreeDimData.create;
begin
     inherited create;

     x3 := 0;
     y3 := 0;
end;

destructor ThreeDimData.destroy;
begin
     x3 := 0;
     y3 := 0;

     inherited destroy;
end;

procedure ThreeDimData.free;
begin
     x3 := 0;
     y3 := 0;

     inherited free;
end;
