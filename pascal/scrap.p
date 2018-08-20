{********************************************                                   
; File: Scrap.p                                                                 
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT SCRAP;                                                                     
INTERFACE                                                                       
USES TYPES;                                                                     
CONST                                                                           
                                                                                
(* *** Toolset Errors ***                                                       
badScrapType = $1610; {error - No scrap of this type. }                         
   *** Toolset Errors *** *)                                                    
                                                                                
textScrap = $0000; {scrapType -  }                                              
picScrap = $0001; {scrapType -  }                                               
PROCEDURE ScrapBootInit   ; Tool $16,$01;                                       
PROCEDURE ScrapStartUp   ; Tool $16,$02;                                        
PROCEDURE ScrapShutDown   ; Tool $16,$03;                                       
FUNCTION ScrapVersion  : Integer ; Tool $16,$04;                                
PROCEDURE ScrapReset   ; Tool $16,$05;                                          
FUNCTION ScrapStatus  : Boolean ; Tool $16,$06;                                 
PROCEDURE GetScrap ( destHandle:Handle; scrapType:Integer)  ; Tool $16,$0D;     
FUNCTION GetScrapCount  : Integer ; Tool $16,$12;                               
FUNCTION GetScrapHandle ( scrapType:Integer) : handle ; Tool $16,$0E;           
FUNCTION GetScrapPath  : Ptr ; Tool $16,$10;                                    
FUNCTION GetScrapSize ( scrapType:Integer) : Longint ; Tool $16,$0F;            
FUNCTION GetScrapState  : Integer ; Tool $16,$13;                               
PROCEDURE LoadScrap   ; Tool $16,$0A;                                           
PROCEDURE PutScrap ( numBytes:Longint; scrapType:Integer; srcPtr:Ptr)  ; Tool   
$16,$0C;                                                                        
PROCEDURE SetScrapPath ( path:Str255)  ; Tool $16,$11;                          
PROCEDURE UnloadScrap   ; Tool $16,$09;                                         
PROCEDURE ZeroScrap   ; Tool $16,$0B;                                           
IMPLEMENTATION                                                                  
END.                                                                            
