//---------------------------------------------------------------------------
#include <vcl\vcl.h>
#pragma hdrstop

#include "iotools.h"
//---------------------------------------------------------------------------
#pragma resource "*.dfm"
TDataModule1 *DataModule1;
//---------------------------------------------------------------------------
__fastcall TDataModule1::TDataModule1(TComponent* Owner)
	: TDataModule(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TDataModule1::CSVFileToMatV8File(AnsiString sCSVFile,
                                                 AnsiString sV8File)
{
   // convert csv file to matrix version 8 file

}


//---------------------------------------------------------------------------
void __fastcall TDataModule1::DataModule1Create(TObject *Sender)
{
	// do nothing
}
//---------------------------------------------------------------------------
