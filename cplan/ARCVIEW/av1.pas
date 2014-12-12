unit av1;
{Author: Matthew Watts
 Date: 5th May 97
 Purpose: Dynamic Data Exchange from C-Plan to ArcView
          Client and Server conversations}

{$DEFINE CPLAN}
{$I \software\cplan\cplan\STD_DEF.PAS}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DdeMan, StdCtrls, ExtCtrls
  {$IFDEF CPLAN}
  ,
  {$IFDEF bit16}
  Arrayt16;
  {$ELSE}
  ds;
  {$ENDIF}

  {$ELSE}
  ;
  {$ENDIF}

type
  TAVDDEForm = class(TForm)
    DdeCmdClient: TDdeClientConv;
    DdeCmdClientItem: TDdeClientItem;
    DdeServerItem1: TDdeServerItem;
    SelectDDE: TDdeServerConv;
    Panel1: TPanel;
    LeftPanel: TPanel;
    RightPanel: TPanel;                                                  
    Button1: TButton;
    btnRequest: TButton;
    Edit2: TComboBox;
    Edit1: TComboBox;
    Label4: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    ListBox1: TListBox;
    MinsetSelectDDE: TDdeServerConv;
    DdeServerItem2: TDdeServerItem;
    CommandConv: TDdeServerConv;
    DdeServerItem3: TDdeServerItem;
    procedure btnRequestClick(Sender: TObject);
    procedure btnTopicsClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure DdeServerItem1PokeData(Sender: TObject);
    procedure SelectDDEOpen(Sender: TObject);
    procedure SelectDDEExecuteMacro(Sender: TObject; Msg: TStrings);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DdeCmdClientClose(Sender: TObject);
    procedure MinsetSelectDDEExecuteMacro(Sender: TObject; Msg: TStrings);
    procedure CommandConvExecuteMacro(Sender: TObject; Msg: TStrings);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ArcViewExecCmd(const sCmd : string);
{posts a DDE execute command to ArcView}

{procedure BuildAttributeArr;}

function FindAdjacentSites(const sSourceSites, sDestinationSites, sSyncFile : string) : boolean;

function FindProximitySites(const sSourceSites, sDestinationSites, sSyncFile : string;
                            const iDistance : integer) : boolean;

function DDESendCmd(const ThisDDEConv : TDDEClientConv; const sCommand : string) : boolean;



var
  AVDDEForm: TAVDDEForm;
  {AttributeArr : Array_t;}

implementation

{$IFDEF CPLAN}
uses
    Dde_unit, Control, Opt1, Global, fldadd, Options, TrimIni;
{$ENDIF}

{$R *.DFM}



function FindAdjacentSites(const sSourceSites, sDestinationSites, sSyncFile : string) : boolean;
var
   sCmd : string;
begin
     if (ControlRes^.GISLink = ArcView) then
     try
        {pass SitesToConsider to ArcView
         resultant list will be returned from ArcView}
        sCmd := 'av.run("Minset.RunAdjacency",{"' + ControlRes^.sAVView +
                       '","' + ControlRes^.sAVTheme +
                       '","' + ControlRes^.sShpKeyField +
                       '","' + sSourceSites +
                       '","' + sDestinationSites +
                       '","' + sSyncFile + '"})';

        ArcViewExecCmd(sCmd);

     except
           MessageDlg('Exception in FindAdjacentSites',mtError,[mbOk],0);
     end;
end;

function FindProximitySites(const sSourceSites, sDestinationSites, sSyncFile : string;
                            const iDistance : integer) : boolean;
var
   sCmd : string;
begin
     if (ControlRes^.GISLink = ArcView) then
     try
        {pass SitesToConsider to ArcView
         resultant list will be returned from ArcView}
        sCmd := 'av.run("Minset.RunProximity",{"' + ControlRes^.sAVView +             {view}
                                            '","' + ControlRes^.sAVTheme +            {theme}
                                            '","' + ControlRes^.sShpKeyField + '"' +  {key field}
                                            ',' + IntToStr(iDistance) +               {distance}
                                            '","' + sSourceSites +
                                            '","' + sDestinationSites +
                                            '","' + sSyncFile + '"})';

        ArcViewExecCmd(sCmd);

     except
           MessageDlg('Exception in FindProximitySites',mtError,[mbOk],0);
     end;
end;


(*
procedure BuildAttributeArr;
var
   iAttribute, iCount : integer;
   UnsortedArr : Array_t;

{builds AttributeArr which is a sorted array that can be used
 for a fast lookup of site indexes in an ArcView Shp File}

begin
     with ControlForm do
     begin
          ShapeTable.TableName := ControlRes^.sShpTable;
          ShapeTable.DatabaseName := ControlRes^.sDatabase;

          ShapeTable.Open;

          UnSortedArr := Array_t.Create;
          UnsortedArr.init(SizeOf(integer),ShapeTable.RecordCount);

          for iCount := 1 to ShapeTable.RecordCount do
          begin
               iAttribute := ShapeTable.FieldByName('ATTRIBUTE').AsInteger;

               UnSortedArr.setValue(iCount,@iAttribute);

               ShapeTable.Next;
          end;

          ShapeTable.Close;

          AttributeArr := SortFeatArray(UnSortedArr);

          UnSortedArr.Destroy;
     end;
end;
*)

procedure TAVDDEForm.btnRequestClick(Sender: TObject);
var
   PResult : PChar;

begin
     PResult := DdeCmdClient.RequestData(Edit1.Text);

     Memo1.Lines.Clear;
     Memo1.Lines.Add(StrPas(PResult));

     StrDispose(PResult);
end;

procedure TAVDDEForm.btnTopicsClick(Sender: TObject);
var
   PResult : PChar;

begin
     PResult := DdeCmdClient.RequestData('Topics');

     Memo1.Lines.Clear;
     Memo1.Lines.Add(StrPas(PResult));

     StrDispose(PResult);
end;

function DDESendCmd(const ThisDDEConv : TDDEClientConv; const sCommand : string) : boolean;
var
   MacroCmd : array [0..2500] of char;
begin
     {send a macro command to the server}
     Result := False;

     if (Length(sCommand) < 2500) then
     begin
          StrPCopy(MacroCmd,sCommand);
          {pascal string to null terminated string}

          if ThisDDEConv.ExecuteMacro(MacroCmd,True) then
             Result := True;
     end
     else
     begin
          MessageDlg('Message longer than 2499 characters in DDESendCmd',mtError,[mbOk],0);
     end;
end;

procedure ArcViewExecCmd(const sCmd : string);
begin
     DDESendCmd(AVDDEForm.DdeCmdClient,sCmd);
end;

procedure TAVDDEForm.Button1Click(Sender: TObject);
begin
     DDESendCmd(DdeCmdClient,Edit2.Text);
end;

procedure TAVDDEForm.DdeServerItem1PokeData(Sender: TObject);
begin
     MessageDlg('Client has poked data',mtInformation,[mbOk],0);
end;

procedure TAVDDEForm.SelectDDEOpen(Sender: TObject);
begin
     MessageDlg('SelectDDE is open',mtInformation,[mbOk],0);
end;

procedure TAVDDEForm.SelectDDEExecuteMacro(Sender: TObject; Msg: TStrings);
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
         (*if (sMsg = 'end do nothing') then
         begin
              {end of multiple select}
              ControlRes^.fMultiDDESelect := False;

              {now use the sites which have been selected}
              if (iMultiSiteCount > 0) then
              begin
                   if (iMultiSiteCount <> MultiSites.lMaxSize) then
                      MultiSites.resize(iMultiSiteCount);
                   //UseGISKeys(MultiSites);
              end;

              MultiSites.Destroy;
         end
         else*)
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

procedure TAVDDEForm.FormResize(Sender: TObject);
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

procedure TAVDDEForm.FormCreate(Sender: TObject);
begin
     {DdeClientConv1.DdeService := 'ArcView';
     DdeClientConv1.DdeTopic := 'System';}
end;

procedure TAVDDEForm.DdeCmdClientClose(Sender: TObject);
begin
     {Cmd conversation has closed}
end;

procedure TAVDDEForm.MinsetSelectDDEExecuteMacro(Sender: TObject;
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

procedure TAVDDEForm.CommandConvExecuteMacro(Sender: TObject; Msg: TStrings);
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
