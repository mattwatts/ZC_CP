#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <io.h>
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <time.h>
#include <string.h>

#define PI 3.141592654

struct bNode {
	int   nIndex;
	float fDist;
};

struct binLookup {
	int nIndex;
	int nOffset;
	int nItems;
	int nArea;      // in Hectares
	int nRadius;	// in Meters
};

struct binHeader {
	int   nItems;
	float fZoneDist;
};

int nGlobalTreeIndex;
struct bNode *GlobalTreeBasePtr;

#define BUFF_SIZE 0xFFFFF
#define MAXI_TREE 0xFFFFF
FILE *gDebug;
#undef DEBUG_ARGUMENTS

char *fHaveData( char *p, int *pArea, int *pRadius );
int nGetFieldCount( char *p );
void vNewTree( struct bNode *pTree, struct bNode *pItem );
void vInsertByIndex( struct bNode *pTree, struct bNode *pItem );
void vInsertByDist( struct bNode *pTree, struct bNode *pItem );
int nMakeIndexTree( char *p, struct bNode *tree );
int nMakeDistTree( char *p, struct bNode *tree );
int compareDist( const void *arg1, const void *arg2 );
int compareIndex( const void *arg1, const void *arg2 );

#define DEBUG_CLUSTER
void main( int argc, char *argv[] )
	{
	if ( argc != 3 )
		{
		printf( "\n\n\tUSAGE: cluster1 <input_data.txt> <output_name(no_extension)>\n\n" );
		exit( 0 );
		}

	FILE *fIn = fopen( argv[1], "r+t" );
	if ( NULL == fIn )
		{
		printf( "Cannot open InFile" );
		exit( 1 );
		}

	char *p = (char*)malloc(BUFF_SIZE);
	if ( NULL == p ) 
		{
		printf("Cannot allocate line buffer");
		fclose( fIn );
		exit( 1 );
		}
	// read the header line
	if ( fgets( p, BUFF_SIZE, fIn ) == NULL ) // read record
		{
		printf( "Cannot read header" );
		fclose( fIn );
		exit( 1 );
		}

	char *pIndex = strtok( p, "\n" );
	float fOuterZone = (float)atof( pIndex );
	if ( fOuterZone <= 0.0 )
		{
		printf( "Got an OUTER ZONE <= 0.0" );
		fclose( fIn );
		exit( 1 );
		}

	char *pCopy = (char*)malloc(BUFF_SIZE);
	if ( NULL == pCopy ) 
		{
		printf("Cannot allocate line Copy buffer");
		fclose( fIn );
		exit( 1 );
		}

	char *pDoubles = (char*)malloc(BUFF_SIZE);
	if ( NULL == pDoubles ) 
		{
		printf("Cannot allocate line doubles buffer");
		free( pCopy );
		fclose( fIn );
		exit( 1 );
		}

	struct bNode *treeBuff = (struct bNode *)malloc( MAXI_TREE * sizeof(struct bNode) );
	if ( NULL == treeBuff )
		{
		printf("Cannot allocate tree node buffer");
		fclose( fIn );
		free( pCopy );
		free( pDoubles );
		free( p );
		exit( 1 );
		}
	GlobalTreeBasePtr = treeBuff;


	char lpOutIndex[256];
	strcpy( lpOutIndex, argv[2] );
	strcat( lpOutIndex, ".idx" );
	char lpOutDist[256];
	strcpy( lpOutDist, argv[2] );
	strcat( lpOutDist, ".dst" );
	char lpOutBinTab[256];
	strcpy( lpOutBinTab, argv[2] );
	strcat( lpOutBinTab, ".blu" );
	char lpOutTable[256];
	strcpy( lpOutTable, argv[2] );
	strcat( lpOutTable, ".sta" );
	char lpErrors[256];
	strcpy( lpErrors, argv[2] );
	strcat( lpErrors, ".err" );

	int hOutIndex = _open( lpOutIndex, _O_RDWR | _O_BINARY | _O_CREAT, _S_IREAD | _S_IWRITE );
	if ( -1 == hOutIndex )
		{
		printf( "Cannot open %s", lpOutIndex );
		fclose( fIn );
		free( treeBuff );
		free( pDoubles );
		free( pCopy );
		free( p );
		exit( 1 );
		}

	int hOutDist = _open( lpOutDist, _O_RDWR | _O_BINARY | _O_CREAT, _S_IREAD | _S_IWRITE );
	if ( -1 == hOutDist )
		{
		printf( "Cannot open %s", lpOutDist );
		_close( hOutIndex );
		fclose( fIn );
		free( treeBuff );
		free( pDoubles );
		free( pCopy );
		free( p );
		exit( 1 );
		}

	int hOutBinTab = _open( lpOutBinTab, _O_RDWR | _O_BINARY | _O_CREAT, _S_IREAD | _S_IWRITE );
	if ( -1 == hOutBinTab )
		{
		printf( "Cannot open %s", lpOutBinTab );
		_close( hOutDist );
		_close( hOutIndex );
		fclose( fIn );
		free( pDoubles );
		free( treeBuff );
		free( pCopy );
		free( p );
		exit( 1 );
		}


	FILE *fOutTable = fopen( lpOutTable, "w+t" );
	if ( NULL == fOutTable )
		{
		printf( "Cannot open %s", lpOutTable );
		_close( hOutBinTab );
		_close( hOutIndex );
		_close( hOutDist );
		free( pDoubles );
		free( treeBuff );
		free( pCopy );
		free( p );
		fclose( fIn );
		exit( 1 );
		}

	FILE *fErrors = fopen( lpErrors, "w+t" );
	if ( NULL == fErrors )
		{
		printf( "Cannot open %s", lpOutTable );
		fclose( fOutTable );
		_close( hOutBinTab );
		_close( hOutIndex );
		_close( hOutDist );
		free( pDoubles );
		free( treeBuff );
		free( pCopy );
		free( p );
		fclose( fIn );
		exit( 1 );
		}


	// write zone distance
	fprintf( fOutTable, "%s%4.4f\n", "ZoneDistance=", fOuterZone );
	// write header line
	fprintf( fOutTable, "%s", "Index,Offset,NumItems,RoundedArea(Ha),Radius(Meters)\n" );

	// write header to Binary table file
	int totalItems = 0;
	struct binHeader bh;
	bh.nItems = totalItems;
	bh.fZoneDist = fOuterZone;
	_lseek( hOutBinTab, 0L, SEEK_SET );
	_write( hOutBinTab, &bh, sizeof( bh ) );
	
	// now positioned for data
	time_t tStart = time( NULL );
	int nDataCount = 0;
	int nNoDataCount = 0;
	//printf( "\n\n\t\t" );
	printf( "\n\n" );
	int nErr = 0;
	while( 1 )
		{
		if ( fgets( p, BUFF_SIZE, fIn ) == NULL ) // read record
			{
			break; // EOF
			}
		strcpy( pDoubles, p );

		++totalItems;
		//printf( "Processing item: %d\r\t\t", totalItems );
	
		// determine if the line has ANY distance data
		int pArea;
		int pRadius;
		char *t = fHaveData( p, &pArea, &pRadius );
		if ( t )
			{
			++nDataCount;
			//++t; // increment to next char after comma

			////////////// INDEX FIELD /////////////////////////////////////
			//copy into spare block for processing
			strcpy( pCopy, t );

			// get the current offset for this tree record
			int nOffset = _lseek( hOutIndex, 0, SEEK_CUR );

			// create binary tree sorted by 'index' field
			int numItems = nMakeIndexTree( pCopy, treeBuff );

			qsort( (void *)treeBuff, numItems, sizeof( struct bNode ), compareIndex );
			// now sort by index via quicksort
			// sanity check looking for DOUBLE indexes
			for ( int qqq=1; qqq<numItems; qqq++ )
				{					
				int n0 = treeBuff[qqq-1].nIndex;
				int n1 = treeBuff[qqq].nIndex;
				printf( "%d:%d\n", n0,n1 );
				if ( n0 == n1 )
					{
					++nErr;
					//fprintf( fErrors, "%d  %d\n", n0,n1 );
					fprintf( fErrors, "%s\n", pDoubles );
					}
				}
			printf("\n");
			
			// write the tree (index) record to the binary file
			_write( hOutIndex, treeBuff, numItems * sizeof( struct bNode ) );

			////////////// DIST FIELD /////////////////////////////////////
			//copy into spare block for processing
			strcpy( pCopy, t );

			// create binary tree sorted by 'dist' field
			numItems = nMakeDistTree( pCopy, treeBuff );
			// now sort by distance via quicksort
			qsort( (void *)treeBuff, numItems, sizeof( struct bNode ), compareDist );

			// write the tree (dist) record to the binary file
			_write( hOutDist, treeBuff, numItems * sizeof( struct bNode ) );

			// update the data lookup table file
			char *pIndex = strtok( p, "," );
			fprintf( fOutTable, 
				     "%s,%d,%d,%d,%d\n", 
					 pIndex, nOffset, numItems, pArea, pRadius );

			// update the binary lookup file
			struct binLookup bl;
			bl.nIndex = atoi( pIndex );
			bl.nOffset = nOffset;
			bl.nItems = numItems;
			bl.nArea = pArea; 
			bl.nRadius = pRadius;  
			_write( hOutBinTab, &bl, sizeof( bl ) );

			}
		else
			{
			++nNoDataCount;
			fprintf( fOutTable, 
				     "%s,%d,%d,%d,%d\n", 
					 strtok( p, "\n" ), -1, 0, pArea, pRadius 
					 );
			// update the binary lookup file
			struct binLookup bl;
			char *pIndex = strtok( p, "\n" );
			bl.nIndex = atoi( pIndex );
			bl.nOffset = -1;
			bl.nItems = 0;
			bl.nArea = pArea;
			bl.nRadius = pRadius;  
			_write( hOutBinTab, &bl, sizeof( bl ) );
			}
		}

	// update the numrecords field at start of binary lookup file
	bh.nItems = totalItems;
	bh.fZoneDist = fOuterZone;
	_lseek( hOutBinTab, 0L, SEEK_SET );
	_write( hOutBinTab, &bh, sizeof( bh ) );

	time_t tEnd = time( NULL );
	printf( "\n\nSTATISTICS.....\n" );
	printf( "\t%d records have SOME data & %d records have NO data in %d secs\n",
			nDataCount, nNoDataCount, tEnd-tStart );

	if ( nErr > 0 )
		{
		printf( "\n\n%d records with double indexes were detected - check the file %s\n", nErr, lpErrors );
		}

	// cleanup...
	if ( pDoubles )
		free( pDoubles );
	if ( treeBuff )
		free( treeBuff );
	if ( pCopy )
		free( pCopy );
	if ( p ) 
		free( p );
	fclose( fIn );
	fclose( fOutTable );
	fclose( fErrors );
	_close( hOutBinTab );
	_close( hOutIndex );
	_close( hOutDist );
	}


char *fHaveData( char *p, int *pArea, int *pRadius )
	{
	
	char *q = p;
	for ( int i=0; i<=2; i++ )
		{
		q = strstr(q, "," );
		if ( q )
			++q;
		}
	// get a copy of the pointer to return 
	// either NULL or the rest of the string
	char *pRetval;
	if ( q )
		pRetval = q; 
	else
		pRetval = NULL;

	// extract index field
	char *index = strtok( p, "," );
	// extract Area Field and convert to hectares
	char *area = strtok( NULL, "," );
	*pArea = int( floor( atof( area ) / 10000 ) );
	
	// extract Radius Field
	char *radius;
	if ( pRetval ) // got some neighbour data
		radius = strtok( NULL, "," );
	else	// got NO neighbour data
		radius = strtok( NULL, "\n" );
	*pRadius = int( floor( sqrt( ( atof( area ) / PI ) ) ) );

	return( pRetval );
	}


int nGetFieldCount( char *p )
	{
	int n=0;
	char *q = p;
	while( ( q = strstr(q, "," ) ) != NULL )
		{
		++n; //another delimiter counted
		++q; //advance to next character
		}

	if ( n % 2 ) 
		{
		printf( "got an uneven index||distance pair here\n" );
		return( 0 );
		}
	return( n/2 ); // return number of fields (  = delimiters/2 )
	}


// create binary tree insertion sorted by 'index' field
int nMakeIndexTree( char *p, struct bNode *pTree )
	{
	struct bNode node;
	char *q = p;
	int numInserts = 0;

	// get the first index,data pair
	char *indexToken = strtok( q, "," );
	char *valueToken = strtok( NULL, "," );

	// setup the new node and insert into new tree
	node.nIndex  = atoi( indexToken );
	node.fDist = (float)atof( valueToken );
	vNewTree( pTree, &node );
	++numInserts;

	// now insert all successive nodes into the tree
	while ( 1 )
		{
		indexToken = strtok( NULL, "," );
	    valueToken = strtok( NULL, "," );

		if ( NULL == indexToken )
			break;

		if ( NULL == valueToken )
			{
			printf( "!!!!!!!!!!!!!!! got something funny going on here !!!!!!!!!!\n" );
			break;
			}
				
		// setup the new node and insert into new tree
		node.nIndex  = atoi( indexToken );
		node.fDist = (float)atof( valueToken );
		vInsertByIndex( pTree, &node );
		++numInserts;
		}

	return( numInserts );
	}


// create binary tree insertion sorted by 'dist' field
int nMakeDistTree( char *p, struct bNode *pTree )
	{
	struct bNode node;
	char *q = p;
	int numInserts = 0;

	// get the first index,data pair
	char *indexToken = strtok( q, "," );
	char *valueToken = strtok( NULL, "," );

	// setup the new node and insert into new tree
	node.nIndex  = atoi( indexToken );
	node.fDist = (float)atof( valueToken );
	vNewTree( pTree, &node );
	++numInserts;

	// now insert all successive nodes into the tree
	while ( 1 )
		{
		indexToken = strtok( NULL, "," );
	    valueToken = strtok( NULL, "," );

		if ( NULL == indexToken )
			break;

		if ( NULL == valueToken )
			{
			printf( "!!!!!!!!!!!!!!! got something funny going on here !!!!!!!!!!\n" );
			break;
			}
				
		// setup the new node and insert into new tree
		node.nIndex  = atoi( indexToken );
		node.fDist = (float)atof( valueToken );
		vInsertByDist( pTree, &node );
		++numInserts;
		}
	return( numInserts );
	}


// attach first item at head of linear buffer
void vNewTree( struct bNode *pTree, struct bNode *pItem )
	{
	memcpy( pTree, pItem, sizeof( struct bNode ) );
	nGlobalTreeIndex = 1; // the zero'th slot is occupied by pItem now
	}


void vInsertByIndex( struct bNode *pTree, struct bNode *pItem )
	{
	// copy item data to new slot and increment for next slot
	memcpy( &GlobalTreeBasePtr[nGlobalTreeIndex++], pItem, sizeof( struct bNode ) );
	}


void vInsertByDist( struct bNode *pTree, struct bNode *pItem )
	{
	// copy item data to new slot and increment for next slot
	memcpy( &GlobalTreeBasePtr[nGlobalTreeIndex++], pItem, sizeof( struct bNode ) );
	}

int compareDist( const void *arg1, const void *arg2 )
{
	if ( ((bNode *)(arg1))->fDist < ((bNode *)(arg2))->fDist )
		return -1;

	else if ( ((bNode *)(arg1))->fDist > ((bNode *)(arg2))->fDist )
		return 1;

	else 
		return 0;
}

int compareIndex( const void *arg1, const void *arg2 )
{
	if ( ((bNode *)(arg1))->nIndex < ((bNode *)(arg2))->nIndex )
		return -1;

	else if ( ((bNode *)(arg1))->nIndex > ((bNode *)(arg2))->nIndex )
		return 1;

	else 
		return 0;
}

