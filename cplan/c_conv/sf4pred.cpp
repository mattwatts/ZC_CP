// Author : Matthew Watts
// Date : 20 July 1998
// Purpose : C++ implementation of 'Irreplaceability Predictor Version 4' written
//           originally in Borland Pascal by Simon Ferrier


//---------------------------------------------------------------------------
#include <vcl\vcl.h>
#pragma hdrstop

#include "sf4pred.h"
//---------------------------------------------------------------------------

/*

*/

// Global declaration for SiteArray and FeatureArray
site_instance *SiteArray;
feature_instance *FeatureArray;

void __fastcall InitIrreplaceability(int iSites,
                                     int iFeatures,
                                     AnsiString sMatrixFile,
                                     AnsiString sFeatureFile)
{
	// instantiate memory as required
    //site_instance SiteArray[iSites];
    //feature_instance FeatureArray[iFeatures];

    // read site data from sMatrixFile

    // read feature targets from sFeatureFile

}

void __fastcall SelectCombinationSize(int iCombinationSize)
{
	// select combination size and return it

}

void __fastcall CalculateIrreplaceability()
{
    // calculate irreplaceability

}

void __fastcall TestIrreplaceability()
{
	// test call to irreplaceability functions on test dataset to demonstrate
    // how to use this set of functions

    InitIrreplaceability(10,  // Number of sites
                         10,  // Number of features
                         "",  // Matrix file
                         ""); // Feature file

    int	iCombinationSize;
    SelectCombinationSize(iCombinationSize);
}

