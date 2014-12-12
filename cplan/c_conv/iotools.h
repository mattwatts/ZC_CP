//---------------------------------------------------------------------------
#ifndef iotoolsH
#define iotoolsH
//---------------------------------------------------------------------------
#include <vcl\Classes.hpp>
#include <vcl\Controls.hpp>
#include <vcl\StdCtrls.hpp>
#include <vcl\Forms.hpp>
#include <vcl\DBTables.hpp>
#include <vcl\DB.hpp>
//---------------------------------------------------------------------------
class TDataModule1 : public TDataModule
{
__published:	// IDE-managed Components
	TTable *Table1;
    void __fastcall CSVFileToMatV8File(AnsiString sCSVFile,
                                       AnsiString sV8File);
	void __fastcall DataModule1Create(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TDataModule1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern TDataModule1 *DataModule1;
//---------------------------------------------------------------------------
#endif
