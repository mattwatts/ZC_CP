//---------------------------------------------------------------------------
#include <vcl\vcl.h>
#pragma hdrstop

#include "dde_u1.h"
//---------------------------------------------------------------------------
#pragma resource "*.dfm"
TSpatialForm *SpatialForm;
//---------------------------------------------------------------------------
__fastcall TSpatialForm::TSpatialForm(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TSpatialForm::Button1Click(TObject *Sender)
{
  //SpatCPlanClient->DdeService = "tool32";
  //SpatCPlanClient->DdeTopic = "CPlanSpatServer";

  if (SpatCPlanClient->SetLink("tool32","CPlanSpatServer"))
  //if (SpatCPlanClient->OpenLink())
  {
    Label1->Caption = "link set";
    if (SpatCPlanClient->OpenLink())
    {
      Label3->Caption = "link opened";
      
    }
    else
    {
      Label3->Caption = "link not opened";
    }
  }
  else
  {
    Label1->Caption = "link not set";
  }
}
//---------------------------------------------------------------------------
void __fastcall TSpatialForm::SpatCPlanClientOpen(TObject *Sender)
{
  Label2->Caption = "C-Plan has opened";        
}
//---------------------------------------------------------------------------
void __fastcall TSpatialForm::SpatCPlanClientClose(TObject *Sender)
{
  Label2->Caption = "C-Plan has closed";        
}
//---------------------------------------------------------------------------
void __fastcall TSpatialForm::SpatCPlanServerExecuteMacro(TObject *Sender,
        TStrings *Msg)
{
  AnsiString sMsg;

  sMsg = Msg->Strings[0];

  lblA->Caption = sMsg;

  Update();
}
//---------------------------------------------------------------------------
void __fastcall TSpatialForm::Button2Click(TObject *Sender)
{
  if (SpatCPlanClient->ExecuteMacro("Hello There",FALSE))
  {
    // Hello executed successfully

  }
  if (SpatCPlanClient->ExecuteMacro("contribresult",FALSE))
  {
    //
    lblB->Caption = lblB->Caption + "H";
  }
}
//---------------------------------------------------------------------------