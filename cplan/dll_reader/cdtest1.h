// 
// cdtest1.h
//

//
//
// define a struct for the pascal client to access
//
//
struct ttt0 {
		int v1;				// should be a 4 byte integer in Pascal
		int v2;				// -----------------//-----------------
		int v3;				// -----------------//-----------------
		double d1;			// should be an 8 byte double in Pascal
		float  f1;			// should be a 4 byte real in Pascal
		float  f2;			// -----------------//-----------------
		int v4;				// should be a 4 byte integer in Pascal
};// sizeof


//////////////////////////////////////////////////////////////////////////////////////////////
// Matt, I have set the internal values for this struct to the following values
//
// v1 = 1
// v2 = 2
// v3 = 3
// d1 = 100.123456789
// f1 = 10.123123
// f2 = 20.987987
// v4 = 4;
//
// also, note that the function getDLLBlock returns a pointer to this internal block
// therefore the memory allocated by this function is 'owned' by it so to speak, thus
// use the function freeDllBlock0 to return this 32 byte block of memory to the global pool.
// 
// Try this party trick.......
//
//				Call getDLLBlock a number of times but save the pointers that you get. 
//
//				Now alter some of the values in the structs/records 
//                                           that you get back via the saved pointers.
//				
//              Then call the function displayInternals( with each of the saved pointers ).
//
//				Check that the display function shows that the modified values have been set.
//
//				Now call freeDLLBlock to release the memory
//
///////////////////////////////////////////////////////////////////////////////////////////////



extern "C" {

__declspec(dllexport) int makeContact( char * );

__declspec(dllexport) void * getDllBlock0();

__declspec(dllexport) int freeDllBlock0( struct ttt0 * );

__declspec(dllexport) int displayInternals( struct ttt0 * );


}


