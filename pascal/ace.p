{********************************************                                   
; File: ACE.p                                                                   
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT ACE;                                                                       
INTERFACE                                                                       
USES TYPES;                                                                     
                                                                                
(* *** Toolset Errors ***                                                       
CONST                                                                           
aceNoError = $0; {Error -  }                                                    
aceIsActive = $1D01; {Error -  }                                                
aceBadDP = $1D02; {Error -  }                                                   
aceNotActive = $1D03; {Error -   }                                              
aceNoSuchParam = $1D04; {Error -  }                                             
aceBadMethod = $1D05; {Error -  }                                               
aceBadSrc = $1D06; {Error -  }                                                  
aceBadDest = $1D07; {Error -  }                                                 
aceDataOverlap = $1D08; {Error -  }                                             
aceNotImplemented = $1DFF; {Error -  }                                          
   *** Toolset Errors *** *)                                                    
                                                                                
PROCEDURE ACEBootInit   ; Tool $1D,$01;                                         
PROCEDURE ACEStartUp ( dPageAddr:Integer)  ; Tool $1D,$02;                      
PROCEDURE ACEShutDown   ; Tool $1D,$03;                                         
FUNCTION ACEVersion  : Integer ; Tool $1D,$04;                                  
PROCEDURE ACEReset   ; Tool $1D,$05;                                            
FUNCTION ACEStatus  : Boolean ; Tool $1D,$06;                                   
FUNCTION ACEInfo ( infoItemCode:Integer) : Longint ; Tool $1D,$07;              
PROCEDURE ACECompBegin   ; Tool $1D,$0B;                                        
PROCEDURE ACECompress ( src:Handle; srcOffset:Longint; dest:Handle;             
destOffset:Longint; nBlks:Integer; method:Integer)  ; Tool $1D,$09;             
PROCEDURE ACEExpand ( src:Handle; srcOffset:Longint; dest:Handle;               
destOffset:Longint; nBlks:Integer; method:Integer)  ; Tool $1D,$0A;             
PROCEDURE ACEExpBegin   ; Tool $1D,$0C;                                         
IMPLEMENTATION                                                                  
END.                                                                            
