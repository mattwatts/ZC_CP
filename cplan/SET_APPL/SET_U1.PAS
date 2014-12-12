unit set_u1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
    Str255 = String[255];
    Set_T = array[1..20000] of Str255;

  TSetForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ListBox1: TListBox;
    Label1: TLabel;
    Button4: TButton;
    Label2: TLabel;
    Label3: TLabel;
    OpenDialog1: TOpenDialog;
    Button5: TButton;
    Button6: TButton;
    GroupBox1: TGroupBox;
    Button7: TButton;
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure LoadSetFromFile(var ASet : Set_T;
                              var iSetCount : integer;
                              const sFile : string;
                              const fReset : boolean);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SetForm: TSetForm;
  LocalSet, SetA, SetB : Set_T;
  iACount, iBCount : integer;

  _500files : array[1..5000] of Textfile;
  {_1000files : array[1..1000] of Text;}

implementation

uses
    FileCtrl;

{$R *.DFM}

procedure TSetForm.LoadSetFromFile(var ASet : Set_T;
                                   var iSetCount : integer;
                                   const sFile : string;
                                   const fReset : boolean);
var
   InFile : textfile;
   sValue, sLine : string;
begin
     {sFile is an ascii file of identifiers}
     assignfile(InFile,sFile);
     reset(InFile);

     if fReset then
        iSetCount := 0;

     repeat
           try
              readln(InFile,sLine);
              sValue := sLine;
              Inc(iSetCount);
              ASet[iSetCount] := sValue;
           except

           end;

     until EOF(InFile);

     closefile(InFile);
end;

procedure TSetForm.Button4Click(Sender: TObject);
begin
     listbox1.items.savetofile('c:\result.txt');
end;

procedure TSetForm.Button1Click(Sender: TObject);
begin
     if OpenDialog1.Execute then
     begin
        LoadSetFromFile(SetA,iACount,OpenDialog1.Filename,TRUE);
        Label2.Caption := IntToStr(iACount);
     end;
end;

procedure TSetForm.Button2Click(Sender: TObject);
begin
     if OpenDialog1.Execute then
     begin
        LoadSetFromFile(SetB,iBCount,OpenDialog1.Filename,True);
        Label3.Caption := IntToStr(iBCount);
     end;
end;

procedure TSetForm.Button3Click(Sender: TObject);
var
   iA, iB : integer;
   fFound : boolean;
begin
     {traverse SetA

               element A
               traverse SetB
                        elementB

                        if elementA not one of elementB
                           add to result list}

     listbox1.items.clear;

     for iA := 1 to iACount do
     begin
          fFound := False;
          for iB := 1 to iBCount do
              if (SetA[iA] = SetB[iB]) then
                 fFound := True;

          if not fFound then
             listbox1.items.add(SetA[iA]);
     end;
end;

procedure TSetForm.Button5Click(Sender: TObject);
begin
     if OpenDialog1.Execute then
     begin
        LoadSetFromFile(SetA,iACount,OpenDialog1.Filename,FALSE);
        Label2.Caption := IntToStr(iACount);
     end;
end;

procedure TSetForm.Button6Click(Sender: TObject);
var

   iLocalSet, iCount, iCount2 : integer;
   fExists : boolean;
begin
     {make LocalSet the list of SetA with no duplicates,
      then copy the result to listbox}

     iLocalSet := 0;

     for iCount := 1 to iACount do
     begin
          {attempt to add all elements from SetA to LocalSet
           (if they don't yet exist in LocalSet)}

          fExists := False;
          if (iLocalSet > 0) then
             for iCount2 := 1 to iLocalSet do
             begin
                  {test if element exists in LocalSet}
                  if (SetA[iCount] = LocalSet[iCount2]) then
                     fExists := True;
             end;

          if not fExists then
          begin
               {add element to LocalSet}
               Inc(iLocalSet);
               LocalSet[iLocalSet] := SetA[iCount];
          end;
     end;

     listbox1.items.clear;

     if (iLocalSet > 0) then
     begin
          {write local set to the result list}
          for iCount := 1 to iLocalSet do
              listbox1.items.add(LocalSet[iCount]);

          listbox1.sorted := True;
          listbox1.sorted := False;
     end;
end;

procedure TSetForm.Button7Click(Sender: TObject);
var
   iCount, iFiles : integer;
   sDir : string;
begin
     {init 3000 files}
     iFiles := 5000;

     sDir := 'd:\~test';

     ForceDirectories(sDir);
     for iCount := 1 to iFiles do
     begin
          AssignFile(_500files[iCount],sDir + '\' + IntToStr(iCount) + '.txt');
          rewrite(_500files[iCount]);
          writeln(_500files[iCount],IntToStr(iCount));
     end;

     for iCount := 1 to iFiles do
         writeln(_500files[iCount],'xyzt');

     for iCount := 1 to iFiles do
         closefile(_500files[iCount]);
end;


end.
