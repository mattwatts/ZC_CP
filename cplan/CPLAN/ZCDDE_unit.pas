unit ZCDDE_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DdeMan, StdCtrls, ExtCtrls;

type
  TZCDDEForm = class(TForm)
    Panel1: TPanel;
    Label4: TLabel;
    Button1: TButton;
    btnRequest: TButton;
    Edit2: TComboBox;
    Edit1: TComboBox;
    LeftPanel: TPanel;
    Label1: TLabel;
    Memo1: TMemo;
    RightPanel: TPanel;
    Label2: TLabel;
    ListBox1: TListBox;
    DdeCmdClient: TDdeClientConv;
    DdeCmdClientItem: TDdeClientItem;
    DdeServerItem1: TDdeServerItem;
    SelectDDE: TDdeServerConv;
    MinsetSelectDDE: TDdeServerConv;
    DdeServerItem2: TDdeServerItem;
    CommandConv: TDdeServerConv;
    DdeServerItem3: TDdeServerItem;
    procedure btnRequestClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure DdeServerItem1PokeData(Sender: TObject);
    procedure SelectDDEExecuteMacro(Sender: TObject; Msg: TStrings);
    procedure FormResize(Sender: TObject);
    procedure MinsetSelectDDEExecuteMacro(Sender: TObject; Msg: TStrings);
    procedure CommandConvExecuteMacro(Sender: TObject; Msg: TStrings);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ZonaeCogitoExecCmd(const sCmd : string);

var
  ZCDDEForm: TZCDDEForm;

implementation

uses
    av1, Control, Dde_unit, ds, global, TrimIni;

{$R *.DFM}

procedure ZonaeCogitoExecCmd(const sCmd : string);
begin
     DDESendCmd(ZCDDEForm.DdeCmdClient,sCmd);
end;

procedure TZCDDEForm.btnRequestClick(Sender: TObject);
var
   PResult : PChar;

begin
     PResult := DdeCmdClient.RequestData(Edit1.Text);

     Memo1.Lines.Clear;
     Memo1.Lines.Add(StrPas(PResult));

     StrDispose(PResult);
end;

procedure TZCDDEForm.Button1Click(Sender: TObject);
begin
     DDESendCmd(DdeCmdClient,Edit2.Text);
end;

procedure TZCDDEForm.DdeServerItem1PokeData(Sender: TObject);
begin
     MessageDlg('Client has poked data',mtInformation,[mbOk],0);
end;

procedure TZCDDEForm.SelectDDEExecuteMacro(Sender: TObject; Msg: TStrings);
var
   iCount, iThisCode : integer;
   rThisCode : extended;
   sMsg : string;
begin
     {we have received a Selection of 1 or more
      site Geocodes from ArcView via DDE}

     sMsg := Msg.Strings[0];

     if (sMsg = 'start select') then
     begin
          {start of multiple dde select}
          ControlRes^.fMultiDDESelect := True;
          MultiSites := Array_T.Create;
          MultiSites.init(SizeOf(integer),ARR_STEP_SIZE);
          iMultiSiteCount := 0;
     end
     else
         if (sMsg = 'end select') then
         begin
              {end of multiple select}
              ControlRes^.fMultiDDESelect := False;

              {now use the sites which have been selected}
              if (iMultiSiteCount > 0) then
              begin
                   if (iMultiSiteCount <> MultiSites.lMaxSize) then
                      MultiSites.resize(iMultiSiteCount);
                   UseGISKeys(MultiSites);
              end;

              MultiSites.Destroy;
         end
         else
         begin
              //rThisCode := StrToFloat(sMsg);
              iThisCode := Trunc(StrToFloat(sMsg));

              if ControlRes^.fMultiDDESelect then
              begin
                   {this is a single site from an ArcView dde selection}

                   Inc(iMultiSiteCount);
                   if (iMultiSiteCount > MultiSites.lMaxSize) then
                      MultiSites.resize(MultiSites.lMaxSize + ARR_STEP_SIZE);
                   MultiSites.setValue(iMultiSiteCount,@iThisCode);
              end
              else
                  UseGISKey(iThisCode,False);
         end;
end;

procedure TZCDDEForm.FormResize(Sender: TObject);
begin
     if ((ClientWidth div 2) > 0) then
     begin
          LeftPanel.Width := ClientWidth div 2;

          if ((LeftPanel.Height - 27) > 0) then
          begin
               Memo1.Height := LeftPanel.Height - 27;
               Listbox1.Height := RightPanel.Height - 27;
          end
          else
          begin
               Memo1.Height := 0;
               Listbox1.Height := 0;
          end;
     end;
end;

procedure TZCDDEForm.MinsetSelectDDEExecuteMacro(Sender: TObject;
  Msg: TStrings);
var
   iCount, iThisCode : integer;
   sMsg : string;
   fProximity : boolean;

   function IsStart(const sLine : string) : boolean;
   begin
        if (sMsg = 'start adjacency') then
        begin
             Result := True;
        end
        else
            if (sMsg = 'start proximity') then
            begin
                 Result := True;
            end
            else
                Result := False;
   end;

   function IsEnd(const sLine : string) : boolean;
   begin
        if (sMsg = 'end adjacency') then
        begin
             Result := True;
             fProximity := False;
        end
        else
            if (sMsg = 'end proximity') then
            begin
                 Result := True;
                 fProximity := True;
            end
            else
                Result := False;
   end;

begin
     {we have received a Selection of 1 or more
      adjacent site Geocodes from ArcView via DDE}

     sMsg := Msg.Strings[0];

     if IsStart(sMsg) then
     begin
          {start of multiple dde select}
          MultiSites := Array_T.Create;
          MultiSites.init(SizeOf(integer),ARR_STEP_SIZE);
          iMultiSiteCount := 0;
     end
     else
         if IsEnd(sMsg) then
         begin
              {end of multiple select}

              {now use the sites which have been selected}
              if (iMultiSiteCount > 0) then
              begin
                   if (iMultiSiteCount <> MultiSites.lMaxSize) then
                      MultiSites.resize(iMultiSiteCount);



                   {This is where we do something with MultiSites}
                   if fProximity then
                      {proximity result}
                   else
                       {adjacency result};
                   {
                    restart adjacency minset because it has been halted waiting for a result
                    from ArcView (and this is the result)


                    }
              end;

              MultiSites.Destroy;
         end
         else
         begin
              {we are adding site geocodes to the array}

              iThisCode := StrToInt(sMsg);

              Inc(iMultiSiteCount);
              if (iMultiSiteCount > MultiSites.lMaxSize) then
                 MultiSites.resize(MultiSites.lMaxSize + ARR_STEP_SIZE);
              MultiSites.setValue(iMultiSiteCount,@iThisCode);
         end;
end;

procedure TZCDDEForm.CommandConvExecuteMacro(Sender: TObject;
  Msg: TStrings);
var
   sMsg, sIniFile : string;
   IniForm : TTrimIniForm;
begin
     {we have received a Ini file message from ArcView}

     sMsg := Msg[0];

     {sMsg can be :
                    InitShpTable  -  add TENURE and DISPLAY fields to a SHP file table,
                                     so it can be used interactively as display module with a C-Plan database}


     try
        if (sMsg = 'Remove ArcView Sections') then
        begin
             IniForm := TTrimIniForm.Create(Application);

             if ControlRes^.fOldIni then
                sIniFile := ControlRes^.sDatabase + '\' + OLD_INI_FILE_NAME
             else
                 sIniFile := ControlRes^.sDatabase + '\' + INI_FILE_NAME;

             IniForm.DeleteExistingArcViewSection(sIniFile);
             IniForm.Free;
        end
        else
        begin
             if (sMsg = 'UpdateDatabase') then
             begin
                  try
                  ControlForm.UpdateDatabase(True);
                  except
                  end;
             end
             else
                 if (sMsg = 'UpdateTenure') then
                 begin
                      try
                      ControlForm.UpdateTenure;
                      except
                      end;
                 end;
        end;

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in TAVDDEForm.IniConvExecuteMacro',mtError,[mbOk],0);
           Application.Terminate;
           Exit;
     end;
end;

end.
