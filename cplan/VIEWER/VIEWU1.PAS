unit viewu1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Image1: TImage;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    LoadImage1: TMenuItem;
    LoadScript1: TMenuItem;
    Iterate1: TMenuItem;
    Begin1: TMenuItem;
    RepeatFromEnd1: TMenuItem;
    SetTimeDelay1: TMenuItem;
    OpenImage: TOpenDialog;
    ListBox1: TListBox;
    Timer1: TTimer;
    Skip1: TMenuItem;
    Pause1: TMenuItem;
    Continue1: TMenuItem;
    Rewind1: TMenuItem;
    Forward1: TMenuItem;
    AddtoScript1: TMenuItem;
    SaveScript1: TMenuItem;
    SaveDialog1: TSaveDialog;
    procedure Exit1Click(Sender: TObject);
    procedure RepeatFromEnd1Click(Sender: TObject);
    procedure LoadImage1Click(Sender: TObject);
    procedure LoadScript1Click(Sender: TObject);
    procedure Begin1Click(Sender: TObject);
    procedure SetTimeDelay1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Pause1Click(Sender: TObject);
    procedure Skip1Click(Sender: TObject);
    procedure Continue1Click(Sender: TObject);
    procedure Rewind1Click(Sender: TObject);
    procedure Forward1Click(Sender: TObject);
    procedure AddtoScript1Click(Sender: TObject);
    procedure SaveScript1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  iTimeDelay, iImage : integer;

implementation

uses ViewU2;

{$R *.DFM}

procedure TForm1.Exit1Click(Sender: TObject);
begin
     Application.Terminate;
end;

procedure TForm1.RepeatFromEnd1Click(Sender: TObject);
begin
     RepeatFromEnd1.Checked := not RepeatFromEnd1.Checked;
end;

procedure TForm1.LoadImage1Click(Sender: TObject);
begin
     if OpenImage.Execute then
     begin
          Listbox1.Visible := False;
          Image1.Picture.LoadFromFile(OpenImage.Filename);
     end;
end;

procedure TForm1.LoadScript1Click(Sender: TObject);
begin
     if OpenImage.Execute then
     begin
          Listbox1.Visible := True;   
          Listbox1.Items.LoadFromFile(OpenImage.Filename);
     end;
end;

procedure TForm1.Begin1Click(Sender: TObject);
begin
     if (Listbox1.Items.Count > 0) then
     begin
          Listbox1.Visible := False;
          Timer1.Interval := iTimeDelay;
          iImage := 1;
          Image1.Picture.LoadFromFile(Listbox1.Items.Strings[0]);
          Timer1.Enabled := True;
     end;
end;

procedure TForm1.SetTimeDelay1Click(Sender: TObject);
begin
     Form2 := TForm2.Create(Application);
     Form2.SpinEdit1.Value := iTimeDelay;

     if (Form2.ShowModal = mrOk) then
        iTimeDelay := Form2.SpinEdit1.Value;

     Form2.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     iTimeDelay := 1000;
     Caption := 'Viewer Form  x: ' + IntToStr(Image1.Width) +
                ' y: ' + IntToStr(Image1.Height);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
     if (Listbox1.Items.Count > 0) then
     begin
          Timer1.Interval := iTimeDelay;

          if (iImage < Listbox1.Items.Count) then
          begin
               Image1.Picture.LoadFromFile(Listbox1.Items.Strings[iImage]);
               Caption := 'Viewer Form  x: ' +
                          IntToStr(Image1.Width) +
                          ' y: ' +
                          IntToStr(Image1.Height) +
                          ' ' + IntToStr(iImage) + ' ' +
                          Listbox1.Items.Strings[iImage];

               Inc(iImage);
          end
          else
          begin
               if RepeatFromEnd1.Checked then
               begin
                    iImage := 0;
                    Image1.Picture.LoadFromFile(Listbox1.Items.Strings[iImage]);
                    Caption := 'Viewer Form  x: ' +
                               IntToStr(Image1.Width) +
                               ' y: ' +
                               IntToStr(Image1.Height) +
                               ' ' + IntToStr(iImage) + ' ' +
                               Listbox1.Items.Strings[iImage];
                    Inc(iImage);
               end
               else
                   Timer1.Enabled := False;
          end;
     end
     else
         Timer1.Enabled := False;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
     Caption := 'Viewer Form  x: ' + IntToStr(Image1.Width) +
                ' y: ' + IntToStr(Image1.Height);
end;

procedure TForm1.Pause1Click(Sender: TObject);
begin
     Timer1.Enabled := False;
end;

procedure TForm1.Skip1Click(Sender: TObject);
begin
     Timer1.Enabled := False;
     Timer1Timer(self);
     Timer1.Enabled := True;
end;

procedure TForm1.Continue1Click(Sender: TObject);
begin
     Timer1Timer(self);
     Timer1.Enabled := True;
end;

procedure TForm1.Rewind1Click(Sender: TObject);
begin
     if (iImage > 1) then
        Dec(iImage,2)
     else
         iImage := Listbox1.Items.Count - 1;

     Timer1Timer(self);
end;

procedure TForm1.Forward1Click(Sender: TObject);
begin
     Timer1Timer(self);
end;

procedure TForm1.AddtoScript1Click(Sender: TObject);
var
   iCount : integer;
begin
     if OpenImage.Execute then
        if (OpenImage.Files.Count > 0) then
           for iCount := 0 to (OpenImage.Files.Count-1) do
           begin
                {add path/name of files to listbox1}
                listbox1.items.add(OpenImage.Files.Strings[iCount]);
           end;
end;

procedure TForm1.SaveScript1Click(Sender: TObject);
begin
     if SaveDialog1.Execute then
        listbox1.items.savetofile(SaveDialog1.Filename);
end;

end.
