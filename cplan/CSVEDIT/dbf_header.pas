// Author : Matthew Watts
// Date : 30 sept 1999
// Purpose : Query structure of dBase IV table using notes on file structure
//           from dBase Language Reference from Glen Manion NPWS


unit dbf_header;

// .dbf file is composed of :
//    header
//    data records
//    deletion flags
//    end-of-file marker

{
.dbf file, header

Byte     Contents              Meaning
0        1 byte                bits 0-2  version number
                               bit 3     presence of dBase IV memo file
                               bits 4-6  presence of SQL table
                               bit 7     presence of and memo file (dBase III plus OR dBase IV)
1-3      3 bytes               date of last update formatted YYMMDD
4-7      32-bit number         number of records in file
8-9      16-bit number         number of bytes in header
10-11    16-bit number         number of bytes in record
12-13    2 bytes               reserved; fill with 0
14       1 byte                flag indicating incomplete transaction
15       1 byte                encryption flag
16-27    12 bytes              reserved for dBase IV in multi-user environment
28       1 byte                production .mdx file flag, 01H = production .mdx file, 00H = no file
29-31    3 bytes               reserved; fill with 0
32-n     32 bytes each         field descriptor array
n+1      1 byte                ODH as the field terminator
}

{
.dbf file, field descriptor (an array of which is in the file header)

Byte     Contents              Meaning
0-10     11 bytes              Field name in ASCII (zero-filled)
11       1 byte                Field type in ASCII (C, D, F, L, M or N)
12-15    4 bytes               reserved
16       1 byte                Field length in binary
17       1 byte                Field decimal count in binary
18-19    2 bytes               reserved
20       1 byte                work area ID
21-30    10 bytes              reserved
31       1 byte                production .mdx field flag; 01H = field has tag in .mdx file, 00H = not
}

{
.dbf file, data records

Data records follow header and are predeced by 1 byte;
  a space (20H) if record not deleted,
  asterix (2AH) if record deleted.
Fields packed into records without field seperators or record terminators.
}

{
.dbf file, end of file marker

End of file marked by single byte, ASCII 26 (1AH).
}

interface

uses
    global;

procedure return_dBase_Header_Info(const sFilename : string;
                                   var dBase_Header : dBaseHeader_T);

implementation

uses
    forms, dialogs, controls;

procedure return_dBase_Header_Info(const sFilename : string;
                                   var dBase_Header : dBaseHeader_T);
var
   dBaseFile : file of byte;
   bByte : byte;
begin
     // bVersionNumber : byte;
     // iRecordCount is a field in the header, iFieldCount must be derived by reading field headers until field terminator
     //
     try
        dBase_Header.bVersionNumber := 0;
        dBase_Header.iRecordCount := 0;
        dBase_Header.iFieldCount := 0;

        assignfile(dBaseFile,sFilename);
        FileMode := 0;  { Set file access to read only }
        reset(dBaseFile);

        // read the header from the dBase file
        read(dBaseFile,bByte);
        read(dBaseFile,bByte);
        read(dBaseFile,bByte);
        read(dBaseFile,bByte);

        closefile(dBaseFile);

     except
           Screen.Cursor := crDefault;
           MessageDlg('Exception in return_dBase_Header_Info file ' + sFilename,
                      mtError,[mbOk],0);
     end;
end;

end.
