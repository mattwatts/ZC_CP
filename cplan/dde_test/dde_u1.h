//---------------------------------------------------------------------------
#ifndef dde_u1H
#define dde_u1H
//---------------------------------------------------------------------------
#include <vcl\Classes.hpp>
#include <vcl\Controls.hpp>
#include <vcl\StdCtrls.hpp>
#include <vcl\Forms.hpp>
#include <vcl\DdeMan.hpp>
//---------------------------------------------------------------------------
class TSpatialForm : public TForm
{
__published:	// IDE-managed Components
        TDdeClientConv *SpatCPlanClient;
        TDdeClientItem *DdeClientItem1;
        TDdeServerConv *SpatCPlanServer;
        TDdeServerItem *DdeServerItem1;
        TButton *Button1;
        TLabel *Label1;
        TLabel *Label2;
        TLabel *Label3;
        TLabel *lblA;
        TLabel *lblB;
        TButton *Button2;
        void __fastcall Button1Click(TObject *Sender);
        void __fastcall SpatCPlanClientOpen(TObject *Sender);
        void __fastcall SpatCPlanClientClose(TObject *Sender);
        void __fastcall SpatCPlanServerExecuteMacro(TObject *Sender,
        TStrings *Msg);
        void __fastcall Button2Click(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TSpatialForm(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern TSpatialForm *SpatialForm;
//---------------------------------------------------------------------------
#endif
