// 
// cdtest1.cpp
//


#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include "cdtest1.h"


int 
makeContact( char *s )
	{
	char buff[256];
	sprintf( buff, "The string is ->%s<-", s );
	MessageBox( NULL, s, "Testing the DLL parameters", MB_OK );

	//MessageBox( NULL, s, "sizeof struct ttt0", MB_OK );
	//sizeof

	return( 1 );
	}


void *
getDllBlock0()
	{
	
	struct ttt0 *myStruct = (struct ttt0 *) malloc( sizeof( struct ttt0 ) );

	// initialise it with some values
	myStruct->v1 = 1;
	myStruct->v2 = 2;
	myStruct->v3 = 3;
	myStruct->d1 = 100.123456789;
	myStruct->f1 = (float)10.123123;
	myStruct->f2 = (float)20.987987;
	myStruct->v4 = 4;


	return( (void *) myStruct );
	}


int 
freeDllBlock0( struct ttt0 *p ) 
	{
	if ( p )
		free( p );

	return( 1 );
	}


int 
displayInternals( struct ttt0 *p )
	{
	char buff[64];

	sprintf( buff, /*"%s",*/ "v1->%d<-", p->v1 );
	//sprintf( buff, "%s", "v1 %d ", p->v1 );
	MessageBox( NULL, buff, "struct/record Internals 1 of 7", MB_OK );

	sprintf( buff, /*"%s",*/ "v2->%d<-", p->v2 );
	MessageBox( NULL, buff, "struct/record Internals 2 of 7", MB_OK );

	sprintf( buff, /*"%s",*/ "v3->%d<-", p->v3 );
	MessageBox( NULL, buff, "struct/record Internals 3 of 7", MB_OK );

	sprintf( buff, /*"%s",*/ "d1->%lf<-", p->d1 );
	MessageBox( NULL, buff, "struct/record Internals 4 of 7", MB_OK );

	sprintf( buff, /*"%s",*/ "f1->%f<-", p->f1 );
	MessageBox( NULL, buff, "struct/record Internals 5 of 7", MB_OK );

	sprintf( buff, /*"%s",*/ "f2->%f<-", p->f2 );
	MessageBox( NULL, buff, "struct/record Internals 6 of 7", MB_OK );

	sprintf( buff, /*"%s",*/ "v4->%d<-", p->v4 );
	MessageBox( NULL, buff, "struct/record Internals 7 of 7", MB_OK );

	return( 1 );
	}

