{********************************************                                   
; File: Print.p                                                                 
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT PRINT;                                                                     
INTERFACE                                                                       
USES TYPES,QUICKDRAW,EVENTS,CONTROLS,WINDOWS,LINEEDIT,DIALOGS;                  
CONST                                                                           
                                                                                
(* *** Toolset Errors ***                                                       
pntrConFailed = $1308; {error - connection to the printer failed }              
memFullErr = $FF80; {errors -  }                                                
ioAbort = $FFE5; {errors -  }                                                   
prAbort = $0080; {errors -  }                                                   
missingDriver = $1301; {errors - specified driver not in system/drivers }       
portNotOn = $1302; {errors - specified port not selected in ctl panel }         
noPrintRecord = $1303; {errors - no print record was given }                    
badLaserPrep = $1304; {errors - laser prep in laser writer incompatible }       
badLPFile = $1305; {errors - laser prep in system/drivers incompatible }        
papConnNotOpen = $1306; {errors - cannot connect to laser writer }              
papReadWriteErr = $1307; {errors - apple talk PAPRead or PAPWrite error }       
ptrConnFailed = $1308; {errors - cannot establish connection with imagewriter } 
badLoadParam = $1309; {errors - parameter for load/unload is invalid }          
callNotSupported = $130A; {errors - toolcall made is not supported by this      
version }                                                                       
startUpAlreadyMade = $1321; {errors - low level startup already made }          
invalidCtlVal = $1322; {errors - invalid control value had been spec'd }        
   *** Toolset Errors *** *)                                                    
                                                                                
kReset = $0001; {LLDControl - Printer control value - reset printer }           
kFormFeed = $0002; {LLDControl - Printer control value - form feed }            
kLineFeed = $0003; {LLDControl - Printer control value - line feed }            
bothDrivers = $0; {whichDriver - input to PMLoadDriver and PMUnloadDriver }     
printerDriver = $0001; {whichDriver - input to PMLoadDriver and PMUnloadDriver  
}                                                                               
portDriver = $0002; {whichDriver - input to PMLoadDriver and PMUnloadDriver }   
prPortrait = $0000; { -  }                                                      
prLandscape = $0001; { -  }                                                     
prImageWriter = $0001; { -  }                                                   
prImageWriterLQ = $0002; { -  }                                                 
prLaserWriter = $0003; { -  }                                                   
prEpson = $0004; { -  }                                                         
prBlackWhite = $0001; { -  }                                                    
prColor = $0002; { -  }                                                         
bDraftLoop = $0000; { -  }                                                      
bSpoolLoop = $0080; { -  }                                                      
                                                                                
TYPE                                                                            
PrPrinterSpecRec = RECORD                                                       
    prPrinterType : Integer;                                                    
    prCharacteristics : Integer;                                                
END;                                                                            
PrInfoRecHndl = ^PrInfoRecPtr;                                                  
PrInfoRecPtr = ^PrInfoRec;                                                      
PrInfoRec = RECORD                                                              
    iDev : Integer; { reserved for internal use }                               
    iVRes : Integer; { vertical resolution of printer }                         
    iHRes : Integer; { horizontal resolution of printer }                       
    rPage : Rect; { defining page rectangle }                                   
END;                                                                            
PrJobRecPtr = ^PrJobRec;                                                        
PrJobRec = PACKED RECORD                                                        
    iFstPage : Integer; { first page to print }                                 
    iLstPage : Integer; { last page to print }                                  
    iCopies : Integer; { number of copies }                                     
    bJDocLoop : Byte; { printing method }                                       
    fFromUser : Byte; { used internally }                                       
    pIdleProc : WordProcPtr; { background procedure }                           
    pFileName : Ptr; { spool file name }                                        
    iFileVol : Integer; { spool file volume reference number }                  
    bFileVers : Byte; { spool file version number }                             
    bJobX : Byte; { used internally }                                           
END;                                                                            
PrStyleRecHndl = ^PrStyleRecPtr;                                                
PrStyleRecPtr = ^PrStyleRec;                                                    
PrStyleRec = RECORD                                                             
    wDev : Integer; { output quality information }                              
    internA : ARRAY[1..3] OF Integer; { for internal use }                      
    feed : Integer; { paper feed type }                                         
    paperType : Integer; { paper type }                                         
    crWidth : Integer; { carriage Width for image writer or vertical sizing for 
lazer writer }                                                                  
    reduction : Integer; { % reduction, laser writer only }                     
    internB : Integer; { for internal use }                                     
END;                                                                            
PrRecHndl = ^PrRecPtr;                                                          
PrRecPtr = ^PrRec;                                                              
PrRec = RECORD                                                                  
    prVersion : Integer; { print manager version }                              
    prInfo : PrInfoRec; { printer infomation subrecord }                        
    rPaper : Rect; { Defining paper rectangle }                                 
    prStl : PrStyleRec; { style subrecord }                                     
    prInfoPT : PACKED ARRAY[1..14] OF Byte; { reserved for internal use }       
    prXInfo : PACKED ARRAY[1..24] OF Byte; { reserved for internal use }        
    prJob : PrJobRec; { job subrecord }                                         
    printX : PACKED ARRAY[1..38] OF Byte; { reserved for future use }           
    iReserved : Integer; { reserved for internal use }                          
END;                                                                            
PrStatusRecHndl = ^PrStatusRecPtr;                                              
PrStatusRecPtr = ^PrStatusRec;                                                  
PrStatusRec = RECORD                                                            
    iTotPages : Integer; { number of pages in spool file }                      
    iCurPage : Integer; { page being printed }                                  
    iTotCopies : Integer; { number of copies requested }                        
    iCurCopy : Integer; { copy being printed }                                  
    iTotBands : Integer; { reserved for internal use }                          
    iCurBand : Integer; { reserved for internal use }                           
    fPgDirty : Integer; { TRUE if started printing page }                       
    fImaging : Integer; { reserved for internal use }                           
    hPrint : PrRecHndl; { handle of print record }                              
    pPrPort : GrafPortPtr; { pointer to grafport being use for printing }       
    hPic : Longint; { reserved for internal use }                               
END;                                                                            
PROCEDURE PMBootInit   ; Tool $13,$01;                                          
PROCEDURE PMStartUp ( userID:Integer; dPageAddr:Integer)  ; Tool $13,$02;       
PROCEDURE PMShutDown   ; Tool $13,$03;                                          
FUNCTION PMVersion  : Integer ; Tool $13,$04;                                   
PROCEDURE PMReset   ; Tool $13,$05;                                             
FUNCTION PMStatus  : Boolean ; Tool $13,$06;                                    
PROCEDURE LLDBitMap ( bitMapPtr:Ptr; rectPtr:Rect; userID:Integer)  ; Tool      
$13,$1C;                                                                        
PROCEDURE LLDControl ( printerControlValue:Integer)  ; Tool $13,$1B;            
PROCEDURE LLDShutDown ( userID:Integer)  ; Tool $13,$1A;                        
PROCEDURE LLDStartUp ( dPageAddr:Integer; userID:Integer)  ; Tool $13,$19;      
PROCEDURE LLDText ( textPtr:Ptr; textLength:Integer; userID:Integer)  ; Tool    
$13,$1D;                                                                        
PROCEDURE PMLoadDriver ( whichDriver:Integer)  ; Tool $13,$35;                  
PROCEDURE PMUnloadDriver ( whichDriver:Integer)  ; Tool $13,$34;                
FUNCTION PrChoosePrinter  : Boolean ; Tool $13,$16;                             
FUNCTION PrChooser  : Boolean ; Tool $13,$16;                                   
PROCEDURE PrCloseDoc ( printGrafPortPtr:GrafPortPtr)  ; Tool $13,$0F;           
PROCEDURE PrClosePage ( printGrafPortPtr:GrafPortPtr)  ; Tool $13,$11;          
PROCEDURE PrDefault ( printRecordHandle:PrRecHndl)  ; Tool $13,$09;             
FUNCTION PrDriverVer  : Integer ; Tool $13,$23;                                 
FUNCTION PrError  : Integer ; Tool $13,$14;                                     
FUNCTION PrJobDialog ( printRecordHandle:PrRecHndl) : Boolean ; Tool $13,$0C;   
FUNCTION PrOpenDoc ( printRecordHandle:PrRecHndl; printGrafPortPtr:GrafPortPtr) 
: GrafPortPtr ; Tool $13,$0E;                                                   
PROCEDURE PrOpenPage ( printGrafPortPtr:GrafPortPtr; pageFramePtr:RectPtr)  ;   
Tool $13,$10;                                                                   
PROCEDURE PrPicFile ( printRecordHandle:PrRecHndl;                              
printGrafPortPtr:GrafPortPtr; statusRecPtr:PrStatusRecPtr)  ; Tool $13,$12;     
PROCEDURE PrPixelMap ( srcLocPtr:LocInfoPtr; srcRectPtr:Rect;                   
colorFlag:Integer)  ; Tool $13,$0D;                                             
FUNCTION PrPortVer  : Integer ; Tool $13,$24;                                   
PROCEDURE PrSetError ( errorNumber:Integer)  ; Tool $13,$15;                    
FUNCTION PrStlDialog ( printRecordHandle:PrRecHndl) : Boolean ; Tool $13,$0B;   
FUNCTION PrValidate ( printRecordHandle:PrRecHndl) : Boolean ; Tool $13,$0A;    
PROCEDURE PrSetDocName ( DocNamePtr:StringPtr)  ; Tool $13,$37;                 
FUNCTION PrGetDocName  : StringPtr ; Tool $13,$36;                              
FUNCTION PrGetPgOrientation ( prRecordHandle:PrRecHndl) : Integer ; Tool        
$13,$38;                                                                        
FUNCTION PrGetPrinterSpecs  : PrPrinterSpecRec ; Tool $13,$18;                  
PROCEDURE PrGetZoneName (VAR ZoneNamePtr:Str255)  ; Tool $13,$25;               
PROCEDURE PrGetPrinterDvrName (VAR DvrNamePtr:Str255)  ; Tool $13,$28;          
PROCEDURE PrGetPortDvrName (VAR DvrNamePtr:Str255)  ; Tool $13,$29;             
PROCEDURE PrGetUserName (VAR UserNamePtr:Str255)  ; Tool $13,$2A;               
PROCEDURE PrGetNetworkName (VAR NetworkNamePtr:Str255)  ; Tool $13,$2B;         
IMPLEMENTATION                                                                  
END.                                                                            
