unit extract_sensitivity_graphs;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  Childwin;

type
  TExtractSensitivityGraphsForm = class(TForm)
    BitBtnCancel: TBitBtn;
    BitBtnOk: TBitBtn;
    ComboTable: TComboBox;
    Label1: TLabel;
    RadioProcedure: TRadioGroup;
    Label2: TLabel;
    EditFeatureCount: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure LoopCreateGraph1(const sTable, sBaseDir : string);
    procedure CreateGraph1(const sTable, sBaseDir : string;
                           const iFeature : integer;
                           AChild : TMDIChild);
    procedure CreateGraph2(const sTable, sBaseDir : string);
    procedure CreateGraph3(const sTable, sBaseDir : string);
    procedure CreateGraph4(const sTable, sBaseDir : string);
    procedure CreateGraph5(const sTable, sBaseDir : string);
    procedure CreateGraph6(const sTable, sBaseDir : string);
    procedure CreateGraph7(const sTable, sBaseDir : string);
    procedure BitBtnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ExtractSensitivityGraphsForm: TExtractSensitivityGraphsForm;

implementation

uses grids, MAIN, hotspots_accumulation;

{$R *.DFM}

function LocateRow(const sBobID, sSensitivityID : string;
                   TheChild : TMDIChild) : integer;
begin
     Result := 0;
     // returns a zero based index of which row in the table contains the specified run
     //sBobID		1 based column 2
     //sSensitivityID	1 based column 4
     repeat
           Inc(Result);

     until (Result >= TheChild.aGrid.RowCount)
     or ((sBobId = TheChild.aGrid.Cells[1,Result]) and (sSensitivityID = TheChild.aGrid.Cells[3,Result]));
end;

function StringValueGreaterThan(const sStr1, sStr2 : string) : boolean;
begin
     Result := StrToFloat(sStr1) > StrToFloat(sStr2);
end;

function IsGraphValid(AGrid : TStringGrid;
                      var iPercentValid : integer) : boolean;
var
   iValid : integer;
begin
     Result := True;
     iValid := 8;

     if not StringValueGreaterThan(AGrid.Cells[2,1],AGrid.Cells[2,3]) then
     begin
          Dec(iValid);
	  Result := False;
     end;
     if not StringValueGreaterThan(AGrid.Cells[2,2],AGrid.Cells[2,3]) then
     begin
          Dec(iValid);
	  Result := False;
     end;
     if not StringValueGreaterThan(AGrid.Cells[2,1],AGrid.Cells[2,4]) then
     begin
          Dec(iValid);
	  Result := False;
     end;
     if not StringValueGreaterThan(AGrid.Cells[2,2],AGrid.Cells[2,4]) then
     begin
          Dec(iValid);
	  Result := False;
     end;
     if not StringValueGreaterThan(AGrid.Cells[2,3],AGrid.Cells[2,5]) then
     begin
          Dec(iValid);
	  Result := False;
     end;
     if not StringValueGreaterThan(AGrid.Cells[2,3],AGrid.Cells[2,6]) then
     begin
          Dec(iValid);
	  Result := False;
     end;
     if not StringValueGreaterThan(AGrid.Cells[2,4],AGrid.Cells[2,5]) then
     begin
          Dec(iValid);
	  Result := False;
     end;
     if not StringValueGreaterThan(AGrid.Cells[2,4],AGrid.Cells[2,6]) then
     begin
          Dec(iValid);
	  Result := False;
     end;

     iPercentValid := round(iValid / 8 * 100);
end;

procedure TExtractSensitivityGraphsForm.LoopCreateGraph1(const sTable, sBaseDir : string);
var
   AChild, BChild : TMDIChild;
   iCount, iValid, iPercentValid, iTPV : integer;
begin
     AChild := LoadChildHandle(sTable);

     // call graph 1 for min and 10th percentile
     CreateGraph1(sTable,sBaseDir,0,AChild);

     BChild := LoadChildHandle(sBaseDir + '\graph1.csv');
     if IsGraphValid(BChild.aGrid,iPercentValid) then
        MessageDlg('Graph 1 valid',mtInformation,[mbOk],0)
     else
         MessageDlg('Graph 1 invalid',mtInformation,[mbOk],0);
     BChild.Free;


     // call graph 1 for each feature individually
     iValid := 0;
     iTPV := 0;
     for iCount := 1 to 107 do
     begin
          CreateGraph1(sTable,sBaseDir,iCount,AChild);

          BChild := LoadChildHandle(sBaseDir + '\' + 'feature' + IntToStr(iCount) + '_graph1.csv');
          if IsGraphValid(BChild.aGrid,iPercentValid) then
          begin
               Inc(iValid);
               CopyFile(pchar(sBaseDir + '\' + 'feature' + IntToStr(iCount) + '_graph1.csv'),
                        pchar(sBaseDir + '\' + 'valid_feature' + IntToStr(iCount) + '_graph1.csv'),
                        False);
          end;
          Inc(iTPV,iPercentValid);
          BChild.Free;
     end;

     MessageDlg(IntToStr(iValid) + ' out of 107 valid, ' + IntToStr(Round(iTPV/107)) + ' percent of total checks valid',mtInformation,[mbOk],0);

     AChild.Free;
end;

procedure TExtractSensitivityGraphsForm.CreateGraph1(const sTable, sBaseDir : string;
                                                     const iFeature : integer;
                                                     AChild : TMDIChild);
var
   OutFile : TextFile;
   iMinCol, iTenthCol : integer;
begin
     // make a csv file called graph1.csv
     if (iFeature = 0) then
     begin
          iMinCol := 113;                   // 0 based index
          iTenthCol := 114;                 // 0 based index
          assignfile(OutFile,sBaseDir + '\graph1.csv');
     end
     else
     begin
          iMinCol := iFeature + 5;          // 0 based index
          iTenthCol := iFeature + 5;        // 0 based index
          assignfile(OutFile,sBaseDir + '\' + 'feature' + IntToStr(iFeature) + '_graph1.csv');
     end;

     rewrite(OutFile);
     if (iFeature = 0) then
        writeln(OutFile,'Graph1 variable,sensitivity,MIN retention,Graph1 variable,sensitivity,MIN retention,Graph1 variable,sensitivity,MIN retention')
     else
         writeln(OutFile,'Feature' + IntToStr(iFeature) +
                         '_Graph1 variable,sensitivity,MIN retention,Graph1 variable,sensitivity,MIN retention,Graph1 variable,sensitivity,MIN retention');

     write(OutFile,'VmIr,D1/2 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1/2 T1/2 R1',AChild)] + ',');
     write(OutFile,'VmIr,D1 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'VmIr,D2 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D2 T1/2 R1',AChild)]);
     write(OutFile,'CVmSi,D1/2 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1/2 T1/2 R1',AChild)] + ',');
     write(OutFile,'CVmSi,D1 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'CVmSi,D2 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D2 T1/2 R1',AChild)]);
     write(OutFile,'VmFr,D1/2 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1/2 T1/2 R1',AChild)] + ',');
     write(OutFile,'VmFr,D1 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'VmFr,D2 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D2 T1/2 R1',AChild)]);
     write(OutFile,'Vm,D1/2 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1/2 T1/2 R1',AChild)] + ',');
     write(OutFile,'Vm,D1 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'Vm,D2 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D2 T1/2 R1',AChild)]);
     write(OutFile,'CRi,D1/2 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1/2 T1/2 R1',AChild)] + ',');
     write(OutFile,'CRi,D1 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'CRi,D2 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D2 T1/2 R1',AChild)]);
     write(OutFile,'Ri,D1/2 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1/2 T1/2 R1',AChild)] + ',');
     write(OutFile,'Ri,D1 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'Ri,D2 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D2 T1/2 R1',AChild)]);

     writeln(OutFile);

     if (iFeature = 0) then
        writeln(OutFile,'Graph1 variable,sensitivity,10th Percentile retention,Graph1 variable,sensitivity,10th Percentile retention,Graph1 variable,sensitivity,10th Percentile retention')
     else
         writeln(OutFile,'Feature' + IntToStr(iFeature) +
                         '_Graph1 variable,sensitivity,10th Percentile retention,Graph1 variable,sensitivity,10th Percentile retention,Graph1 variable,sensitivity,10th Percentile retention');

     write(OutFile,'VmIr,D1/2 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1/2 T1/2 R1',AChild)] + ',');
     write(OutFile,'VmIr,D1 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'VmIr,D2 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D2 T1/2 R1',AChild)]);
     write(OutFile,'VmSi,D1/2 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1/2 T1/2 R1',AChild)] + ',');
     write(OutFile,'VmSi,D1 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'VmSi,D2 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D2 T1/2 R1',AChild)]);
     write(OutFile,'Ir,D1/2 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1/2 T1/2 R1',AChild)] + ',');
     write(OutFile,'Ir,D1 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'Ir,D2 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D2 T1/2 R1',AChild)]);
     write(OutFile,'CVmRi,D1/2 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1/2 T1/2 R1',AChild)] + ',');
     write(OutFile,'CVmRi,D1 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'CVmRi,D2 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D2 T1/2 R1',AChild)]);
     write(OutFile,'CRi,D1/2 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1/2 T1/2 R1',AChild)] + ',');
     write(OutFile,'CRi,D1 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'CRi,D2 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D2 T1/2 R1',AChild)]);
     write(OutFile,'Ri,D1/2 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1/2 T1/2 R1',AChild)] + ',');
     write(OutFile,'Ri,D1 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'Ri,D2 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D2 T1/2 R1',AChild)]);

     closefile(OutFile);
end;

procedure TExtractSensitivityGraphsForm.CreateGraph2(const sTable, sBaseDir : string);
var
   AChild : TMDIChild;
   OutFile : TextFile;
   iMinCol, iTenthCol : integer;
begin
     // make a csv file called graph2.csv
     AChild := LoadChildHandle(sTable);
     iMinCol := 113;                   // one based index
     iTenthCol := 114;                 // one based index

     assignfile(OutFile,sBaseDir + '\graph2.csv');
     rewrite(OutFile);
     writeln(OutFile,'Graph2 variable,sensitivity,MIN retention,Graph2 variable,sensitivity,MIN retention,Graph2 variable,sensitivity,MIN retention');

     write(OutFile,'VmIr,D1/2 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1/2 T1 R1',AChild)] + ',');
     write(OutFile,'VmIr,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'VmIr,D2 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D2 T1 R1',AChild)]);
     write(OutFile,'CVmSi,D1/2 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1/2 T1 R1',AChild)] + ',');
     write(OutFile,'CVmSi,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'CVmSi,D2 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D2 T1 R1',AChild)]);
     write(OutFile,'VmFr,D1/2 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1/2 T1 R1',AChild)] + ',');
     write(OutFile,'VmFr,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'VmFr,D2 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D2 T1 R1',AChild)]);
     write(OutFile,'Vm,D1/2 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1/2 T1 R1',AChild)] + ',');
     write(OutFile,'Vm,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'Vm,D2 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D2 T1 R1',AChild)]);
     write(OutFile,'CRi,D1/2 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1/2 T1 R1',AChild)] + ',');
     write(OutFile,'CRi,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'CRi,D2 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D2 T1 R1',AChild)]);
     write(OutFile,'Ri,D1/2 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1/2 T1 R1',AChild)] + ',');
     write(OutFile,'Ri,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'Ri,D2 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D2 T1 R1',AChild)]);

     writeln(OutFile);
     writeln(OutFile,'Graph2 variable,sensitivity,10th Percentile retention,Graph2 variable,sensitivity,10th Percentile retention,Graph2 variable,sensitivity,10th Percentile retention');

     write(OutFile,'VmIr,D1/2 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1/2 T1 R1',AChild)] + ',');
     write(OutFile,'VmIr,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'VmIr,D2 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D2 T1 R1',AChild)]);
     write(OutFile,'VmSi,D1/2 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1/2 T1 R1',AChild)] + ',');
     write(OutFile,'VmSi,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'VmSi,D2 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D2 T1 R1',AChild)]);
     write(OutFile,'Ir,D1/2 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1/2 T1 R1',AChild)] + ',');
     write(OutFile,'Ir,D1 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'Ir,D2 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D2 T1 R1',AChild)]);
     write(OutFile,'CVmRi,D1/2 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1/2 T1 R1',AChild)] + ',');
     write(OutFile,'CVmRi,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'CVmRi,D2 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D2 T1 R1',AChild)]);
     write(OutFile,'CRi,D1/2 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1/2 T1 R1',AChild)] + ',');
     write(OutFile,'CRi,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'CRi,D2 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D2 T1 R1',AChild)]);
     write(OutFile,'Ri,D1/2 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1/2 T1 R1',AChild)] + ',');
     write(OutFile,'Ri,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'Ri,D2 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D2 T1 R1',AChild)]);

     closefile(OutFile);

     AChild.Free;
end;

procedure TExtractSensitivityGraphsForm.CreateGraph3(const sTable, sBaseDir : string);
var
   AChild : TMDIChild;
   OutFile : TextFile;
   iMinCol, iTenthCol : integer;
begin
     // make a csv file called graph3.csv
     AChild := LoadChildHandle(sTable);
     iMinCol := 113;                   // one based index
     iTenthCol := 114;                 // one based index

     assignfile(OutFile,sBaseDir + '\graph3.csv');
     rewrite(OutFile);
     writeln(OutFile,'Graph3 variable,sensitivity,MIN retention,Graph3 variable,sensitivity,MIN retention,Graph3 variable,sensitivity,MIN retention');

     write(OutFile,'VmIr,D1/2 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1/2 T2 R1',AChild)] + ',');
     write(OutFile,'VmIr,D1 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'VmIr,D2 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D2 T2 R1',AChild)]);
     write(OutFile,'CVmSi,D1/2 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1/2 T2 R1',AChild)] + ',');
     write(OutFile,'CVmSi,D1 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'CVmSi,D2 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D2 T2 R1',AChild)]);
     write(OutFile,'VmFr,D1/2 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1/2 T2 R1',AChild)] + ',');
     write(OutFile,'VmFr,D1 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'VmFr,D2 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D2 T2 R1',AChild)]);
     write(OutFile,'Vm,D1/2 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1/2 T2 R1',AChild)] + ',');
     write(OutFile,'Vm,D1 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'Vm,D2 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D2 T2 R1',AChild)]);
     write(OutFile,'CRi,D1/2 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1/2 T2 R1',AChild)] + ',');
     write(OutFile,'CRi,D1 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'CRi,D2 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D2 T2 R1',AChild)]);
     write(OutFile,'Ri,D1/2 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1/2 T2 R1',AChild)] + ',');
     write(OutFile,'Ri,D1 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'Ri,D2 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D2 T2 R1',AChild)]);

     writeln(OutFile);
     writeln(OutFile,'Graph3 variable,sensitivity,10th Percentile retention,Graph3 variable,sensitivity,10th Percentile retention,Graph3 variable,sensitivity,10th Percentile retention');

     write(OutFile,'VmIr,D1/2 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1/2 T2 R1',AChild)] + ',');
     write(OutFile,'VmIr,D1 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'VmIr,D2 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D2 T2 R1',AChild)]);
     write(OutFile,'VmSi,D1/2 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1/2 T2 R1',AChild)] + ',');
     write(OutFile,'VmSi,D1 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'VmSi,D2 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D2 T2 R1',AChild)]);
     write(OutFile,'Ir,D1/2 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1/2 T2 R1',AChild)] + ',');
     write(OutFile,'Ir,D1 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'Ir,D2 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D2 T2 R1',AChild)]);
     write(OutFile,'CVmRi,D1/2 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1/2 T2 R1',AChild)] + ',');
     write(OutFile,'CVmRi,D1 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'CVmRi,D2 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D2 T2 R1',AChild)]);
     write(OutFile,'CRi,D1/2 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1/2 T2 R1',AChild)] + ',');
     write(OutFile,'CRi,D1 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'CRi,D2 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D2 T2 R1',AChild)]);
     write(OutFile,'Ri,D1/2 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1/2 T2 R1',AChild)] + ',');
     write(OutFile,'Ri,D1 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'Ri,D2 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D2 T2 R1',AChild)]);

     closefile(OutFile);

     AChild.Free;
end;

procedure TExtractSensitivityGraphsForm.CreateGraph4(const sTable, sBaseDir : string);
var
   AChild : TMDIChild;
   OutFile : TextFile;
   iMinCol, iTenthCol : integer;
begin
     // make a csv file called graph4.csv
     AChild := LoadChildHandle(sTable);
     iMinCol := 113;                   // one based index
     iTenthCol := 114;                 // one based index

     assignfile(OutFile,sBaseDir + '\graph4.csv');
     rewrite(OutFile);
     writeln(OutFile,'Graph4 variable,sensitivity,MIN retention,Graph4 variable,sensitivity,MIN retention,Graph4 variable,sensitivity,MIN retention');

     write(OutFile,'VmIr,D1 T1/2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1 T1/2 R1/2',AChild)] + ',');
     write(OutFile,'VmIr,D1 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'VmIr,D1 T1/2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1 T1/2 R2',AChild)]);
     write(OutFile,'CVmSi,D1 T1/2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1 T1/2 R1/2',AChild)] + ',');
     write(OutFile,'CVmSi,D1 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'CVmSi,D1 T1/2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1 T1/2 R2',AChild)]);
     write(OutFile,'VmFr,D1 T1/2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1 T1/2 R1/2',AChild)] + ',');
     write(OutFile,'VmFr,D1 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'VmFr,D1 T1/2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1 T1/2 R2',AChild)]);
     write(OutFile,'Vm,D1 T1/2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1 T1/2 R1/2',AChild)] + ',');
     write(OutFile,'Vm,D1 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'Vm,D1 T1/2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1 T1/2 R2',AChild)]);
     write(OutFile,'CRi,D1 T1/2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1 T1/2 R1/2',AChild)] + ',');
     write(OutFile,'CRi,D1 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'CRi,D1 T1/2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1 T1/2 R2',AChild)]);
     write(OutFile,'Ri,D1 T1/2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1 T1/2 R1/2',AChild)] + ',');
     write(OutFile,'Ri,D1 T1/2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'Ri,D1 T1/2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1 T1/2 R2',AChild)]);

     writeln(OutFile);
     writeln(OutFile,'Graph4 variable,sensitivity,10th Percentile retention,Graph4 variable,sensitivity,10th Percentile retention,Graph4 variable,sensitivity,10th Percentile retention');

     write(OutFile,'VmIr,D1 T1/2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1 T1/2 R1/2',AChild)] + ',');
     write(OutFile,'VmIr,D1 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'VmIr,D1 T1/2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1 T1/2 R2',AChild)]);
     write(OutFile,'VmSi,D1 T1/2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1 T1/2 R1/2',AChild)] + ',');
     write(OutFile,'VmSi,D1 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'VmSi,D1 T1/2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1 T1/2 R2',AChild)]);
     write(OutFile,'Ir,D1 T1/2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1 T1/2 R1/2',AChild)] + ',');
     write(OutFile,'Ir,D1 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'Ir,D1 T1/2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1 T1/2 R2',AChild)]);
     write(OutFile,'CVmRi,D1 T1/2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1 T1/2 R1/2',AChild)] + ',');
     write(OutFile,'CVmRi,D1 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'CVmRi,D1 T1/2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1 T1/2 R2',AChild)]);
     write(OutFile,'CRi,D1 T1/2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1 T1/2 R1/2',AChild)] + ',');
     write(OutFile,'CRi,D1 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'CRi,D1 T1/2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1 T1/2 R2',AChild)]);
     write(OutFile,'Ri,D1 T1/2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1 T1/2 R1/2',AChild)] + ',');
     write(OutFile,'Ri,D1 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1 T1/2 R1',AChild)] + ',');
     writeln(OutFile,'Ri,D1 T1/2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1 T1/2 R2',AChild)]);

     closefile(OutFile);

     AChild.Free;
end;

procedure TExtractSensitivityGraphsForm.CreateGraph5(const sTable, sBaseDir : string);
var
   AChild : TMDIChild;
   OutFile : TextFile;
   iMinCol, iTenthCol : integer;
begin
     // make a csv file called graph5.csv
     AChild := LoadChildHandle(sTable);
     iMinCol := 113;                   // one based index
     iTenthCol := 114;                 // one based index

     assignfile(OutFile,sBaseDir + '\graph5.csv');
     rewrite(OutFile);
     writeln(OutFile,'Graph5 variable,sensitivity,MIN retention,Graph5 variable,sensitivity,MIN retention,Graph5 variable,sensitivity,MIN retention');

     write(OutFile,'VmIr,D1 T1 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1 T1 R1/2',AChild)] + ',');
     write(OutFile,'VmIr,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'VmIr,D1 T1 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1 T1 R2',AChild)]);
     write(OutFile,'CVmSi,D1 T1 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1 T1 R1/2',AChild)] + ',');
     write(OutFile,'CVmSi,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'CVmSi,D1 T1 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1 T1 R2',AChild)]);
     write(OutFile,'VmFr,D1 T1 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1 T1 R1/2',AChild)] + ',');
     write(OutFile,'VmFr,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'VmFr,D1 T1 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1 T1 R2',AChild)]);
     write(OutFile,'Vm,D1 T1 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1 T1 R1/2',AChild)] + ',');
     write(OutFile,'Vm,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'Vm,D1 T1 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1 T1 R2',AChild)]);
     write(OutFile,'CRi,D1 T1 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1 T1 R1/2',AChild)] + ',');
     write(OutFile,'CRi,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'CRi,D1 T1 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1 T1 R2',AChild)]);
     write(OutFile,'Ri,D1 T1 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1 T1 R1/2',AChild)] + ',');
     write(OutFile,'Ri,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'Ri,D1 T1 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1 T1 R2',AChild)]);

     writeln(OutFile);
     writeln(OutFile,'Graph5 variable,sensitivity,10th Percentile retention,Graph5 variable,sensitivity,10th Percentile retention,Graph5 variable,sensitivity,10th Percentile retention');

     write(OutFile,'VmIr,D1 T1 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1 T1 R1/2',AChild)] + ',');
     write(OutFile,'VmIr,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'VmIr,D1 T1 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1 T1 R2',AChild)]);
     write(OutFile,'VmSi,D1 T1 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1 T1 R1/2',AChild)] + ',');
     write(OutFile,'VmSi,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'VmSi,D1 T1 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1 T1 R2',AChild)]);
     write(OutFile,'Ir,D1 T1 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1 T1 R1/2',AChild)] + ',');
     write(OutFile,'Ir,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'Ir,D1 T1 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1 T1 R2',AChild)]);
     write(OutFile,'CVmRi,D1 T1 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1 T1 R1/2',AChild)] + ',');
     write(OutFile,'CVmRi,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'CVmRi,D1 T1 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1 T1 R2',AChild)]);
     write(OutFile,'CRi,D1 T1 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1 T1 R1/2',AChild)] + ',');
     write(OutFile,'CRi,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'CRi,D1 T1 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1 T1 R2',AChild)]);
     write(OutFile,'Ri,D1 T1 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1 T1 R1/2',AChild)] + ',');
     write(OutFile,'Ri,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'Ri,D1 T1 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1 T1 R2',AChild)]);

     closefile(OutFile);

     AChild.Free;
end;

procedure TExtractSensitivityGraphsForm.CreateGraph6(const sTable, sBaseDir : string);
var
   AChild : TMDIChild;
   OutFile : TextFile;
   iMinCol, iTenthCol : integer;
begin
     // make a csv file called graph6.csv
     AChild := LoadChildHandle(sTable);
     iMinCol := 113;                   // one based index
     iTenthCol := 114;                 // one based index

     assignfile(OutFile,sBaseDir + '\graph6.csv');
     rewrite(OutFile);
     writeln(OutFile,'Graph6 variable,sensitivity,MIN retention,Graph6 variable,sensitivity,MIN retention,Graph6 variable,sensitivity,MIN retention');

     write(OutFile,'VmIr,D1 T2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1 T2 R1/2',AChild)] + ',');
     write(OutFile,'VmIr,D1 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'VmIr,D1 T2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1 T2 R2',AChild)]);
     write(OutFile,'CVmSi,D1 T2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1 T2 R1/2',AChild)] + ',');
     write(OutFile,'CVmSi,D1 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'CVmSi,D1 T2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1 T2 R2',AChild)]);
     write(OutFile,'VmFr,D1 T2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1 T2 R1/2',AChild)] + ',');
     write(OutFile,'VmFr,D1 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'VmFr,D1 T2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1 T2 R2',AChild)]);
     write(OutFile,'Vm,D1 T2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1 T2 R1/2',AChild)] + ',');
     write(OutFile,'Vm,D1 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'Vm,D1 T2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1 T2 R2',AChild)]);
     write(OutFile,'CRi,D1 T2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1 T2 R1/2',AChild)] + ',');
     write(OutFile,'CRi,D1 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'CRi,D1 T2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1 T2 R2',AChild)]);
     write(OutFile,'Ri,D1 T2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1 T2 R1/2',AChild)] + ',');
     write(OutFile,'Ri,D1 T2 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'Ri,D1 T2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1 T2 R2',AChild)]);

     writeln(OutFile);
     writeln(OutFile,'Graph6 variable,sensitivity,10th Percentile retention,Graph6 variable,sensitivity,10th Percentile retention,Graph6 variable,sensitivity,10th Percentile retention');

     write(OutFile,'VmIr,D1 T2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1 T2 R1/2',AChild)] + ',');
     write(OutFile,'VmIr,D1 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'VmIr,D1 T2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1 T2 R2',AChild)]);
     write(OutFile,'VmSi,D1 T2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1 T2 R1/2',AChild)] + ',');
     write(OutFile,'VmSi,D1 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'VmSi,D1 T2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1 T2 R2',AChild)]);
     write(OutFile,'Ir,D1 T2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1 T2 R1/2',AChild)] + ',');
     write(OutFile,'Ir,D1 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'Ir,D1 T2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1 T2 R2',AChild)]);
     write(OutFile,'CVmRi,D1 T2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1 T2 R1/2',AChild)] + ',');
     write(OutFile,'CVmRi,D1 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'CVmRi,D1 T2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1 T2 R2',AChild)]);
     write(OutFile,'CRi,D1 T2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1 T2 R1/2',AChild)] + ',');
     write(OutFile,'CRi,D1 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'CRi,D1 T2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1 T2 R2',AChild)]);
     write(OutFile,'Ri,D1 T2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1 T2 R1/2',AChild)] + ',');
     write(OutFile,'Ri,D1 T2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1 T2 R1',AChild)] + ',');
     writeln(OutFile,'Ri,D1 T2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1 T2 R2',AChild)]);

     closefile(OutFile);

     AChild.Free;
end;

procedure TExtractSensitivityGraphsForm.CreateGraph7(const sTable, sBaseDir : string);
var
   AChild : TMDIChild;
   OutFile : TextFile;
   iMinCol, iTenthCol : integer;
begin
     // make a csv file called graph7.csv
     AChild := LoadChildHandle(sTable);
     iMinCol := 113;                   // one based index
     iTenthCol := 114;                 // one based index

     assignfile(OutFile,sBaseDir + '\graph7.csv');
     rewrite(OutFile);
     writeln(OutFile,'Graph7 variable,sensitivity,MIN retention,Graph7 variable,sensitivity,MIN retention,Graph7 variable,sensitivity,MIN retention');

     write(OutFile,'VmIr,D2 T2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D2 T2 R1/2',AChild)] + ',');
     write(OutFile,'VmIr,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'VmIr,D1/2 T1/2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmIr','D1/2 T1/2 R2',AChild)]);
     write(OutFile,'CVmSi,D2 T2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D2 T2 R1/2',AChild)] + ',');
     write(OutFile,'CVmSi,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'CVmSi,D1/2 T1/2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CVmSi','D1/2 T1/2 R2',AChild)]);
     write(OutFile,'VmFr,D2 T2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D2 T2 R1/2',AChild)] + ',');
     write(OutFile,'VmFr,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'VmFr,D1/2 T1/2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('VmFr','D1/2 T1/2 R2',AChild)]);
     write(OutFile,'Vm,D2 T2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D2 T2 R1/2',AChild)] + ',');
     write(OutFile,'Vm,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'Vm,D1/2 T1/2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Vm','D1/2 T1/2 R2',AChild)]);
     write(OutFile,'CRi,D2 T2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D2 T2 R1/2',AChild)] + ',');
     write(OutFile,'CRi,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'CRi,D1/2 T1/2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('CRi','D1/2 T1/2 R2',AChild)]);
     write(OutFile,'Ri,D2 T2 R1/2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D2 T2 R1/2',AChild)] + ',');
     write(OutFile,'Ri,D1 T1 R1,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'Ri,D1/2 T1/2 R2,' + AChild.aGrid.Cells[iMinCol,LocateRow('Ri','D1/2 T1/2 R2',AChild)]);

     writeln(OutFile);
     writeln(OutFile,'Graph7 variable,sensitivity,10th Percentile retention,Graph7 variable,sensitivity,10th Percentile retention,Graph7 variable,sensitivity,10th Percentile retention');

     write(OutFile,'VmIr,D2 T2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D2 T2 R1/2',AChild)] + ',');
     write(OutFile,'VmIr,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'VmIr,D1/2 T1/2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmIr','D1/2 T1/2 R2',AChild)]);
     write(OutFile,'VmSi,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D2 T2 R1/2',AChild)] + ',');
     write(OutFile,'VmSi,D1 T1/2 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'VmSi,D1/2 T1/2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('VmSi','D1/2 T1/2 R2',AChild)]);
     write(OutFile,'Ir,D2 T2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D2 T2 R1/2',AChild)] + ',');
     write(OutFile,'Ir,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'Ir,D1/2 T1/2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ir','D1/2 T1/2 R2',AChild)]);
     write(OutFile,'CVmRi,D2 T2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D2 T2 R1/2',AChild)] + ',');
     write(OutFile,'CVmRi,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'CVmRi,D1/2 T1/2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CVmRi','D1/2 T1/2 R2',AChild)]);
     write(OutFile,'CRi,D2 T2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D2 T2 R1/2',AChild)] + ',');
     write(OutFile,'CRi,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'CRi,D1/2 T1/2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('CRi','D1/2 T1/2 R2',AChild)]);
     write(OutFile,'Ri,D2 T2 R1/2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D2 T2 R1/2',AChild)] + ',');
     write(OutFile,'Ri,D1 T1 R1,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1 T1 R1',AChild)] + ',');
     writeln(OutFile,'Ri,D1/2 T1/2 R2,' + AChild.aGrid.Cells[iTenthCol,LocateRow('Ri','D1/2 T1/2 R2',AChild)]);

     closefile(OutFile);

     AChild.Free;
end;

procedure TExtractSensitivityGraphsForm.FormCreate(Sender: TObject);
var
   iCount : integer;
begin
     with SCPForm do
          if (MDIChildCount > 0) then
          begin
               for iCount := 0 to (MDIChildCount-1) do
               begin
                    ComboTable.Items.Add(MDIChildren[iCount].Caption);
               end;
               ComboTable.Text := ComboTable.Items.Strings[0];
          end;
end;

procedure TExtractSensitivityGraphsForm.BitBtnOkClick(Sender: TObject);
var
   sBaseDir : string;
begin
     try
        Screen.Cursor := crHourglass;
        // the path containing the input table is where output files are created
        sBaseDir := ExtractFilePath(ComboTable.Text);

        case RadioProcedure.ItemIndex of
             0 : LoopCreateGraph1(ComboTable.Text,sBaseDir);
             1 : CreateGraph2(ComboTable.Text,sBaseDir);
             2 : CreateGraph3(ComboTable.Text,sBaseDir);
             3 : CreateGraph4(ComboTable.Text,sBaseDir);
             4 : CreateGraph5(ComboTable.Text,sBaseDir);
             5 : CreateGraph6(ComboTable.Text,sBaseDir);
             6 : CreateGraph7(ComboTable.Text,sBaseDir);
        end;

        Screen.Cursor := crDefault;
     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in Extract Sensitivity Graphs',
                      mtError,[mbOk],0);
     end;
end;

end.
