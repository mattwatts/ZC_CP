// Author : Matthew Watts
// Date : 20 July 1998
// Purpose : C++ implementation of 'Irreplaceability Predictor Version 4' written
//           originally in Borland Pascal by Simon Ferrier


//---------------------------------------------------------------------------
#ifndef sf4predH
#define sf4predH
//---------------------------------------------------------------------------


/*
	Declare structures and functions that are needed for
    Simon Ferriers irreplaceability predictor version 4.
*/


struct site_instance
{
	int iKey;         // Site Key identifier
    short iRichness;  // Site Richness (no. of features at site)
                      // short is good for 32768 features
    short *iFeatureCodes[];  // feature codes of features (if any)
    float *rFeatureValues[]; // feature values of features (if any)
};

struct feature_instance
{
	short iKey;		  // Feature Key identifier

    float rTarget;    // Feature Target Area
    float rTotal;     // Feature Total Area
};


void __fastcall InitIrreplaceability(int iSites,
                                     int iFeatures,
                                     AnsiString sMatrixFile,	// Site by Feature matrix file
                                     AnsiString sSiteFile,      // Site dBase file
                                     AnsiString sFeatureFile);  // Feature dBase file

void __fastcall SelectCombinationSize(int iCombinationSize);

void __fastcall CalculateIrreplaceability();

void __fastcall TestIrreplaceability();

#endif
