{********************************************                                   
; File: GSOS.p                                                                  
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT GSOS;                                                                      
INTERFACE                                                                       
USES TYPES;                                                                     
CONST                                                                           
                                                                                
readEnable = $0001; {access - read enable bit: CreateRec, OpenRec access and    
requestAccess fields }                                                          
writeEnable = $0002; {access - write enable bit: CreateRec, OpenRec access and  
requestAccess fields }                                                          
fileInvisible = $0004; {access - Invisible bit }                                
backupNeeded = $0020; {access - backup needed bit: CreateRec, OpenRec access    
field. (Must be 0 in requestAccess field ) }                                    
renameEnable = $0040; {access - rename enable bit: CreateRec, OpenRec access    
and requestAccess fields }                                                      
destroyEnable = $0080; {access - destroy enable  bit: CreateRec, OpenRec access 
and requestAccess fields }                                                      
startPlus = $0000; {base - > setMark = displacement }                           
eofMinus = $0001; {base - > setMark = eof - displacement }                      
markPlus = $0002; {base - > setMark = mark + displacement }                     
markMinus = $0003; {base - > setMark = mark - displacement }                    
cacheOff = $0000; {cachePriority - do not cache blocks invloved in this read }  
cacheOn = $0001; {cachePriority -  cache blocks invloved in this read if        
possible }                                                                      
                                                                                
(* *** Toolset Errors ***                                                       
badSystemCall = $0001; {error - bad system call number }                        
invalidPcount = $0004; {error - invalid parameter count }                       
gsosActive = $07; {error - GS/OS already active }                               
devNotFound = $10; {error - device not found }                                  
invalidDevNum = $11; {error - invalid device number }                           
drvrBadReq = $20; {error - bad request or command }                             
drvrBadCode = $0021; {error - bad control or status code }                      
drvrBadParm = $0022; {error - bad call parameter }                              
drvrNotOpen = $0023; {error - character device not open }                       
drvrPriorOpen = $0024; {error - character device already open }                 
irqTableFull = $0025; {error - interrupt table full }                           
drvrNoResrc = $0026; {error - resources not available }                         
drvrIOError = $0027; {error - I/O error }                                       
drvrNoDevice = $0028; {error - device not connected }                           
drvrBusy = $0029; {error - call aborted, driver is busy }                       
drvrWrtProt = $002B; {error - device is write protected }                       
drvrBadCount = $002C; {error - invalid byte count }                             
drvrBadBlock = $002D; {error - invalid block address }                          
drvrDiskSwitch = $002E; {error - disk has been switched }                       
drvrOffLine = $002F; {error - device off line/ no media present }               
badPathSyntax = $0040; {error - invalid pathname syntax }                       
invalidRefNum = $0043; {error - invalid reference number }                      
pathNotFound = $44; {error - subdirectory does not exist }                      
volNotFound = $0045; {error - volume not found }                                
fileNotFound = $0046; {error - file not found }                                 
dupPathname = $0047; {error - create or rename with existing name }             
volumeFull = $0048; {error - volume full error }                                
volDirFull = $0049; {error - volume directory full }                            
badFileFormat = $004A; {error - version error (incompatible file format) }      
badStoreType = $004B; {error - unsupported (or incorrect) storage type }        
eofEncountered = $004C; {error - end-of-file encountered }                      
outOfRange = $004D; {error - position out of range }                            
invalidAccess = $004E; {error - access not allowed }                            
buffTooSmall = $004F; {error - buffer too small }                               
fileBusy = $0050; {error - file is already open }                               
dirError = $0051; {error - directory error }                                    
unknownVol = $0052; {error - unknown volume type }                              
paramRangeErr = $0053; {error - parameter out of range }                        
outOfMem = $0054; {error - out of memory }                                      
dupVolume = $0057; {error - duplicate volume name }                             
notBlockDev = $0058; {error - not a block device }                              
invalidLevel = $0059; {error - specifield level outside legal range }           
damagedBitMap = $005A; {error - block number too large }                        
badPathNames = $005B; {error - invalid pathnames for ChangePath }               
notSystemFile = $005C; {error - not an executable file }                        
osUnsupported = $005D; {error - Operating System not supported }                
stackOverflow = $005F; {error - too many applications on stack }                
dataUnavail = $0060; {error - Data unavailable }                                
endOfDir = $0061; {error - end of directory has been reached }                  
invalidClass = $0062; {error - invalid FST call class }                         
resForkNotFound = $0063; {error - file does not contain required resource }     
invalidFSTID = $0064; {error - error - FST ID is invalid }                      
   *** Toolset Errors *** *)                                                    
                                                                                
(* *** File System IDs ***                                                      
proDOSFSID = $0001; {fileSysID - ProDOS/SOS  }                                  
dos33FSID = $0002; {fileSysID - DOS 3.3 }                                       
dos32FSID = $0003; {fileSysID - DOS 3.2 }                                       
dos31FSID = $0003; {fileSysID - DOS 3.1 }                                       
appleIIPascalFSID = $0004; {fileSysID - Apple II Pascal }                       
mfsFSID = $0005; {fileSysID - Macintosh (flat file system) }                    
hfsFSID = $0006; {fileSysID - Macintosh (hierarchical file system) }            
lisaFSID = $0007; {fileSysID - Lisa file system }                               
appleCPMFSID = $0008; {fileSysID - Apple CP/M }                                 
charFSTFSID = $0009; {fileSysID - Character FST }                               
msDOSFSID = $000A; {fileSysID - MS/DOS }                                        
highSierraFSID = $000B; {fileSysID - High Sierra }                              
iso9660FSID = $000C; {fileSysID - ISO 9660 }                                    
appleShareFSID = $000D; {fileSysID - ISO 9660 }                                 
   *** File System IDs *** *)                                                   
                                                                                
characterFST = $4000; {FSTInfo.attributes - character FST }                     
ucFST = $8000; {FSTInfo.attributes - SCM should upper case pathnames before     
passing them to the FST }                                                       
onStack = $8000; {QuitRec.flags - place state information about quitting        
program on the quit return stack }                                              
restartable = $4000; {QuitRec.flags - the quitting program is capable of being  
restarted from its dormant memory }                                             
seedling = $0001; {storageType - standard file with seedling structure }        
standardFile = $0001; {storageType - standard file type (no resource fork) }    
sapling = $0002; {storageType - standard file with sapling structure }          
tree = $0003; {storageType - standard file with tree structure }                
pascalRegion = $0004; {storageType - UCSD Pascal region on a partitioned disk } 
extendedFile = $0005; {storageType - extended file type (with resource fork) }  
directoryFile = $000D; {storageType - volume directory or subdirectory file }   
minorRelNumMask = $00FF; {version - minor release number }                      
majorRelNumMask = $7F00; {version - major release number }                      
finalRelNumMask = $8000; {version - final release number }                      
isFileExtended = $8000; {GetDirEntryGS -  }                                     
                                                                                
TYPE                                                                            
GSString255Hndl = ^GSString255Ptr;                                              
GSString255Ptr = ^GSString255;                                                  
GSString255 = RECORD                                                            
    length : Integer; { Number of Chars in text field  }                        
    text : PACKED ARRAY[1..255] OF CHAR;                                        
END;                                                                            
GSString255HndlPtr = ^GSString255Hndl;                                          
                                                                                
GSString32Hndl = ^GSString32Ptr;                                                
GSString32Ptr = ^GSString32;                                                    
GSString32 = RECORD                                                             
    length : Integer; { Number of characters in text field }                    
    text : PACKED ARRAY[1..32] OF CHAR;                                         
END;                                                                            
ResultBuf255Hndl = ^ResultBuf255Ptr;                                            
ResultBuf255Ptr = ^ResultBuf255;                                                
ResultBuf255 = RECORD                                                           
    bufSize : Integer;                                                          
    bufString : GSString255;                                                    
END;                                                                            
ResultBuf255HndlPtr = ^ResultBuf255Hndl;                                        
                                                                                
ResultBuf32Hndl = ^ResultBuf32Ptr;                                              
ResultBuf32Ptr = ^ResultBuf32;                                                  
ResultBuf32 = RECORD                                                            
    bufSize : Integer;                                                          
    bufString : GSString32;                                                     
END;                                                                            
ChangePathRecPtrGS = ^ChangePathRecGS;                                          
ChangePathRecGS = RECORD                                                        
    pCount : Integer;                                                           
    pathname : GSString255Ptr;                                                  
    newPathname : GSString255Ptr;                                               
END;                                                                            
CreateRecPtrGS = ^CreateRecGS;                                                  
CreateRecGS = RECORD                                                            
    pCount : Integer;                                                           
    pathname : GSString255Ptr;                                                  
    access : Integer;                                                           
    fileType : Integer;                                                         
    auxType : Longint;                                                          
    storageType : Integer;                                                      
    eof : Longint;                                                              
    resourceEOF : Longint;                                                      
END;                                                                            
DAccessRecPtrGS = ^DAccessRecGS;                                                
DAccessRecGS = RECORD                                                           
    pCount : Integer;                                                           
    devNum : Integer;                                                           
    code : Integer;                                                             
    list : Ptr;                                                                 
    requestCount : Longint;                                                     
    transferCount : Longint;                                                    
END;                                                                            
DevNumRecPtrGS = ^DevNumRecGS;                                                  
DevNumRecGS = RECORD                                                            
    pCount : Integer;                                                           
    devName : GSString255Ptr;                                                   
    devNum : Integer;                                                           
END;                                                                            
DInfoRecPtrGS = ^DInfoRecGS;                                                    
DInfoRecGS = RECORD                                                             
    pCount : Integer; { minimum = 2 }                                           
    devNum : Integer;                                                           
    devName : GSString32Ptr;                                                    
    characteristics : Integer;                                                  
    totalBlocks : Longint;                                                      
    slotNum : Integer;                                                          
    unitNum : Integer;                                                          
    version : Integer;                                                          
    deviceID : Integer;                                                         
    headLink : Integer;                                                         
    forwardLink : Integer;                                                      
    extendedDIBptr : Longint;                                                   
END;                                                                            
DIORecPtrGS = ^DIORecGS;                                                        
DIORecGS = RECORD                                                               
    pCount : Integer;                                                           
    devNum : Integer;                                                           
    buffer : Ptr;                                                               
    requestCount : Longint;                                                     
    startingBlock : Longint;                                                    
    blockSize : Integer;                                                        
    transferCount : Longint;                                                    
END;                                                                            
DirEntryRecPtrGS = ^DirEntryRecGS;                                              
DirEntryRecGS = RECORD                                                          
    pCount : Integer;                                                           
    refNum : Integer;                                                           
    flags : Integer;                                                            
    base : Integer;                                                             
    displacement : Integer;                                                     
    name : Ptr;                                                                 
    entryNum : Integer;                                                         
    fileType : Integer;                                                         
    eof : Longint;                                                              
    blockCount : Longint;                                                       
    createDateTime : TimeRec;                                                   
    modDateTime : TimeRec;                                                      
    access : Integer;                                                           
    auxType : Longint;                                                          
    fileSysID : Integer;                                                        
    optionList : ResultBuf255Ptr;                                               
    resourceEOF : Longint;                                                      
    resourceBlocks : Longint;                                                   
END;                                                                            
ExpandPathRecPtrGS = ^ExpandPathRecGS;                                          
ExpandPathRecGS = RECORD                                                        
    pCount : Integer;                                                           
    inputPath : GSString255Ptr;                                                 
    outputPath : ResultBuf255Ptr;                                               
    flags : Integer;                                                            
END;                                                                            
FileInfoRecPtrGS = ^FileInfoRecGS;                                              
FileInfoRecGS = RECORD                                                          
    pCount : Integer;                                                           
    pathname : GSString255Ptr;                                                  
    access : Integer;                                                           
    fileType : Integer;                                                         
    auxType : Longint;                                                          
    storageType : Integer; { must be 0 for SetFileInfo }                        
    createDateTime : TimeRec;                                                   
    modDateTime : TimeRec;                                                      
    optionList : Longint;                                                       
    eof : Longint;                                                              
    blocksUsed : Longint; { must be 0 for SetFileInfo }                         
    resourceEOF : Longint; { must be 0 for SetFileInfo }                        
    resourceBlocks : Longint; { must be 0 for SetFileInfo }                     
END;                                                                            
FormatRecPtrGS = ^FormatRecGS;                                                  
FormatRecGS = RECORD                                                            
    pCount : Integer;                                                           
    devName : GSString32Ptr; { device name pointer }                            
    volName : GSString32Ptr; { volume name pointer }                            
    fileSysID : Integer; { file system ID }                                     
    reqFileSysID : Integer; { in;  }                                            
END;                                                                            
FSTInfoRecPtrGS = ^FSTInfoRecGS;                                                
FSTInfoRecGS = RECORD                                                           
    pCount : Integer;                                                           
    fstNum : Integer;                                                           
    fileSysID : Integer;                                                        
    fstName : ResultBuf255Ptr;                                                  
    version : Integer;                                                          
    attributes : Integer;                                                       
    blockSize : Integer;                                                        
    maxVolSize : Longint;                                                       
    maxFileSize : Longint;                                                      
END;                                                                            
InterruptRecPtrGS = ^InterruptRecGS;                                            
InterruptRecGS = RECORD                                                         
    pCount : Integer;                                                           
    intNum : Integer;                                                           
    vrn : Integer; { used only by BindInt }                                     
    intCode : Longint; { used only by BindInt }                                 
END;                                                                            
IORecPtrGS = ^IORecGS;                                                          
IORecGS = RECORD                                                                
    pCount : Integer;                                                           
    refNum : Integer;                                                           
    dataBuffer : Ptr;                                                           
    requestCount : Longint;                                                     
    transferCount : Longint;                                                    
    cachePriority : Integer;                                                    
END;                                                                            
LevelRecPtrGS = ^LevelRecGS;                                                    
LevelRecGS = RECORD                                                             
    pCount : Integer;                                                           
    level : Integer;                                                            
END;                                                                            
NameRecPtrGS = ^NameRecGS;                                                      
NameRecGS = RECORD                                                              
    pCount : Integer;                                                           
    pathname : GSString255Ptr; { full pathname or a filename depending on call  
}                                                                               
END;                                                                            
GetNameRecPtrGS = ^GetNameRecGS;                                                
GetNameRecGS = RECORD                                                           
    pCount : Integer;                                                           
    dataBuffer : ResultBuf255Ptr; { full pathname or a filename depending on    
call }                                                                          
END;                                                                            
NewlineRecPtrGS = ^NewlineRecGS;                                                
NewlineRecGS = RECORD                                                           
    pCount : Integer;                                                           
    refNum : Integer;                                                           
    enableMask : Integer;                                                       
    numChars : Integer;                                                         
    newlineTable : Ptr;                                                         
END;                                                                            
OpenRecPtrGS = ^OpenRecGS;                                                      
OpenRecGS = RECORD                                                              
    pCount : Integer;                                                           
    refNum : Integer;                                                           
    pathname : GSString255Ptr;                                                  
    requestAccess : Integer;                                                    
    resourceNumber : Integer; { For extended files: dataFork/resourceFork }     
    access : Integer; { Value of file's access attribute }                      
    fileType : Integer; { Value of file's fileType attribute }                  
    auxType : Longint;                                                          
    storageType : Integer;                                                      
    createDateTime : TimeRec;                                                   
    modDateTime : TimeRec;                                                      
    optionList : IntPtr;                                                        
    eof : Longint;                                                              
    blocksUsed : Longint;                                                       
    resourceEOF : Longint;                                                      
    resourceBlocks : Longint;                                                   
END;                                                                            
OSShutdownRecPtrGS = ^OSShutdownRecGS;                                          
OSShutdownRecGS = RECORD                                                        
    pCount : Integer; { in }                                                    
    shutdownFlag : Integer; { in }                                              
END;                                                                            
PositionRecPtrGS = ^PositionRecGS;                                              
PositionRecGS = RECORD                                                          
    pCount : Integer;                                                           
    refNum : Integer;                                                           
    position : Longint;                                                         
END;                                                                            
EOFRecPtrGS = ^EOFRecGS;                                                        
EOFRecGS = RECORD                                                               
    pCount : Integer;                                                           
    refNum : Integer;                                                           
    eof : Longint;                                                              
END;                                                                            
PrefixRecPtrGS = ^PrefixRecGS;                                                  
PrefixRecGS = RECORD                                                            
    pCount : Integer;                                                           
    prefixNum : Integer;                                                        
    CASE INTEGER OF                                                             
         0: (getPrefix : ResultBuf255Ptr;);                                     
         1: (setPrefix : GSString255Ptr;);                                      
END;                                                                            
QuitRecPtrGS = ^QuitRecGS;                                                      
QuitRecGS = RECORD                                                              
    pCount : Integer;                                                           
    pathname : GSString255Ptr; { pathname of next app to run }                  
    flags : Integer;                                                            
END;                                                                            
RefnumRecPtrGS = ^RefNumRecGS;                                                  
RefNumRecGS = RECORD                                                            
    pCount : Integer;                                                           
    refNum : Integer;                                                           
END;                                                                            
SessionStatusRecPtrGS = ^SessionStatusRecGS;                                    
SessionStatusRecGS = RECORD                                                     
    pCount : Integer; { in: min = 1 }                                           
    status : Integer; { out: }                                                  
END;                                                                            
SetPositionRecPtrGS = ^SetPositionRecGS;                                        
SetPositionRecGS = RECORD                                                       
    pCount : Integer;                                                           
    refNum : Integer;                                                           
    base : Integer;                                                             
    displacement : Longint;                                                     
END;                                                                            
SysPrefsRecPtrGS = ^SysPrefsRecGS;                                              
SysPrefsRecGS = RECORD                                                          
    pCount : Integer;                                                           
    preferences : Integer;                                                      
END;                                                                            
VersionRecPtrGS = ^VersionRecGS;                                                
VersionRecGS = RECORD                                                           
    pCount : Integer;                                                           
    version : Integer;                                                          
END;                                                                            
VolumeRecPtrGS = ^VolumeRecGS;                                                  
VolumeRecGS = RECORD                                                            
    pCount : Integer;                                                           
    devName : GSString32Ptr;                                                    
    volName : ResultBuf255Ptr;                                                  
    totalBlocks : Longint;                                                      
    freeBlocks : Longint;                                                       
    fileSysID : Integer;                                                        
    blockSize : Integer;                                                        
END;                                                                            
PROCEDURE BeginSessionGS (VAR pblockPtr: SessionStatusRecGS); GSOS $201D ;      
                                                                                
PROCEDURE BindIntGS (VAR pblockPtr: InterruptRecGS); GSOS $2031 ;               
                                                                                
PROCEDURE ChangePathGS (VAR pblockPtr: ChangePathRecGS); GSOS $2004 ;           
                                                                                
PROCEDURE ClearBackupBitGS (VAR pblockPtr: NameRecGS); GSOS $200B ;             
                                                                                
PROCEDURE CloseGS (VAR pblockPtr: RefNumRecGS); GSOS $2014 ;                    
                                                                                
PROCEDURE CreateGS (VAR pblockPtr: CreateRecGS); GSOS $2001 ;                   
                                                                                
PROCEDURE DControlGS (VAR pblockPtr: DAccessRecGS); GSOS $202E ;                
                                                                                
PROCEDURE DestroyGS (VAR pblockPtr: NameRecGS); GSOS $2002 ;                    
                                                                                
PROCEDURE DInfoGS (VAR pblockPtr: DInfoRecGS); GSOS $202C ;                     
                                                                                
PROCEDURE DReadGS (VAR pblockPtr: DIORecGS); GSOS $202F ;                       
                                                                                
PROCEDURE DStatusGS (VAR pblockPtr: DAccessRecGS); GSOS $202D ;                 
                                                                                
PROCEDURE DWriteGS (VAR pblockPtr: DIORecGS); GSOS $2030 ;                      
                                                                                
PROCEDURE EndSessionGS (VAR pblockPtr: SessionStatusRecGS); GSOS $201E ;        
                                                                                
PROCEDURE EraseDiskGS (VAR pblockPtr: FormatRecGS); GSOS $2025 ;                
                                                                                
PROCEDURE ExpandPathGS (VAR pblockPtr: ExpandPathRecGS); GSOS $200E ;           
                                                                                
PROCEDURE FlushGS (VAR pblockPtr: RefNumRecGS); GSOS $2015 ;                    
                                                                                
PROCEDURE FormatGS (VAR pblockPtr: FormatRecGS); GSOS $2024 ;                   
                                                                                
PROCEDURE GetBootVolGS (VAR pblockPtr: NameRecGS); GSOS $2028 ;                 
                                                                                
PROCEDURE GetDevNumberGS (VAR pblockPtr: DevNumRecGS); GSOS $2020 ;             
                                                                                
PROCEDURE GetDirEntryGS (VAR pblockPtr: DirEntryRecGS); GSOS $201C ;            
                                                                                
PROCEDURE GetEOFGS (VAR pblockPtr: EOFRecGS); GSOS $2019 ;                      
                                                                                
PROCEDURE GetFileInfoGS (VAR pblockPtr: FileInfoRecGS); GSOS $2006 ;            
                                                                                
PROCEDURE GetFSTInfoGS (VAR pblockPtr: FSTInfoRecGS); GSOS $202B ;              
                                                                                
PROCEDURE GetLevelGS (VAR pblockPtr: LevelRecGS); GSOS $201B ;                  
                                                                                
PROCEDURE GetMarkGS (VAR pblockPtr: PositionRecGS); GSOS $2017 ;                
                                                                                
PROCEDURE GetNameGS (VAR pblockPtr: GetNameRecGS); GSOS $2027 ;                 
                                                                                
PROCEDURE GetPrefixGS (VAR pblockPtr: PrefixRecGS); GSOS $200A ;                
                                                                                
PROCEDURE GetVersionGS (VAR pblockPtr: VersionRecGS); GSOS $202A ;              
                                                                                
PROCEDURE GetSysPrefsGS (VAR pblockPtr: SysPrefsRecGS); GSOS $200F ;            
                                                                                
PROCEDURE NewlineGS (VAR pblockPtr: NewlineRecGS); GSOS $2011 ;                 
                                                                                
PROCEDURE NullGS (VAR pblockPtr: IntPtr); GSOS $200D ;                          
                                                                                
PROCEDURE OpenGS (VAR pblockPtr: OpenRecGS); GSOS $2010 ;                       
                                                                                
PROCEDURE QuitGS (VAR pblockPtr: QuitRecGS); GSOS $2029 ;                       
                                                                                
PROCEDURE ReadGS (VAR pblockPtr: IORecGS); GSOS $2012 ;                         
                                                                                
PROCEDURE ResetCacheGS (VAR pblockPtr: IntPtr); GSOS $2026 ;                    
                                                                                
PROCEDURE SessionStatusGS (VAR pblockPtr: SessionStatusRecGS); GSOS $201F ;     
                                                                                
PROCEDURE SetEOFGS (VAR pblockPtr: SetPositionRecGS); GSOS $2018 ;              
                                                                                
PROCEDURE SetFileInfoGS (VAR pblockPtr: FileInfoRecGS); GSOS $2005 ;            
                                                                                
PROCEDURE SetLevelGS (VAR pblockPtr: LevelRecGS); GSOS $201A ;                  
                                                                                
PROCEDURE SetMarkGS (VAR pblockPtr: SetPositionRecGS); GSOS $2016 ;             
                                                                                
PROCEDURE SetPrefixGS (VAR pblockPtr: PrefixRecGS); GSOS $2009 ;                
                                                                                
PROCEDURE SetSysPrefsGS (VAR pblockPtr: SysPrefsRecGS); GSOS $200C ;            
                                                                                
PROCEDURE UnbindIntGS (VAR pblockPtr: InterruptRecGS); GSOS $2032 ;             
                                                                                
PROCEDURE VolumeGS (VAR pblockPtr: VolumeRecGS); GSOS $2008 ;                   
                                                                                
PROCEDURE WriteGS (VAR pblockPtr: IORecGS); GSOS $2013 ;                        
                                                                                
PROCEDURE OSShutdownGS (VAR pblockPtr: OSShutdownRecGS); GSOS $2003 ;           
                                                                                
PROCEDURE FSTSpecific (VAR pBlockPtr: Ptr); GSOS $2033 ;                        
                                                                                
IMPLEMENTATION                                                                  
END.                                                                            
