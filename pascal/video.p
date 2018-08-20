{********************************************                                   
; File: Video.p                                                                 
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT VIDEO;                                                                     
INTERFACE                                                                       
USES TYPES;                                                                     
CONST                                                                           
                                                                                
vdVideoOverlay = $01; { -  }                                                    
vdFrameGrabber = $02; { -  }                                                    
vdInVStandards = $03; { -  }                                                    
vdOutVStandards = $04; { -  }                                                   
vdKeyDissLevels = $05; { -  }                                                   
vdNKeyDissLevels = $06; { -  }                                                  
vdAdjSideEffect = $07; { -  }                                                   
vdKeyColorBits = $08; { -  }                                                    
vdInHueAdj = $09; { -  }                                                        
vdInSatAdj = $0A; { -  }                                                        
vdInContrastAdj = $0B; { -  }                                                   
vdInBrightAdj = $0C; { -  }                                                     
vdOutSetup = $0D; { -  }                                                        
vdOutChromaFilter = $0E; { -  }                                                 
vdOutExtBlank = $0F; { -  }                                                     
vdKeyEnhDiss = $10; { -  }                                                      
vdLineInterrupt = $11; { -  }                                                   
vdGGBus = $12; { -  }                                                           
vdDualOut = $13; { -  }                                                         
vdTextMonoOver = $14; { -  }                                                    
vdGenlock = $32; { -  }                                                         
vdVideoDetect = $33; { -  }                                                     
vdGenlocked = $34; { -  }                                                       
vdAdjInc = $50; { -  }                                                          
vdAdjDec = $51; { -  }                                                          
vdAdjSave = $52; { -  }                                                         
vdAvail = $01; { -  }                                                           
vdNotAvail = $00; { -  }                                                        
vdYes = $01; { -  }                                                             
vdNo = $00; { -  }                                                              
vdOn = $01; { -  }                                                              
vdOff = $00; { -  }                                                             
vdKColorEnable = $64; { -  }                                                    
vdVerticalBlank = $82; { -  }                                                   
vdMainPageLin = $C8; { -  }                                                     
vdRAMPageSel = $C9; { -  }                                                      
vdVBLInterrupt = $CA; { -  }                                                    
vdInterlaceMode = $CB; { -  }                                                   
vdClearVBLInt = $CC; { -  }                                                     
vdClearLineInt = $CD; { -  }                                                    
vdDisplayField = $CE; { -  }                                                    
vdVBLIntRequest = $CF; { -  }                                                   
vdLineIntRequest = $D0; { -  }                                                  
vdNone = $00; { -  }                                                            
vdNTSC = $01; { -  }                                                            
vdPAL = $02; { -  }                                                             
vdSECAM = $04; { -  }                                                           
vdSNTSC = $08; { -  }                                                           
vdSPAL = $10; { -  }                                                            
vdSSECAM = $20; { -  }                                                          
vdRGB60 = $40; { -  }                                                           
vdRGB50 = $80; { -  }                                                           
vdAux = $00; { -  }                                                             
vdMain = $10; { -  }                                                            
vdInterlace = $30; { -  }                                                       
vdField1 = $01; { -  }                                                          
vdField0 = $00; { -  }                                                          
vdEnable = $01; { -  }                                                          
vdDisable = $00; { -  }                                                         
vdExternal = $00; { -  }                                                        
vdGraphics = $01; { -  }                                                        
vdVBlank = $01; { -  }                                                          
vdActiveVideo = $00; { -  }                                                     
vdNoVideoDevice = $2110; {Error - no video device was found }                   
vdAlreadyStarted = $2111; {Error - Video tool set already started }             
vdInvalidSelector = $2112; {Error - an invalid selector was specified }         
vdInvalidParam = $2113; {Error - an invalid parameter was specified }           
vdUnImplemented = $21FF; {Error - an unimplemented tool set routine was called  
}                                                                               
PROCEDURE VDBootInit   ; Tool $21,$01;                                          
PROCEDURE VDStartUp   ; Tool $21,$02;                                           
PROCEDURE VDShutdown   ; Tool $21,$03;                                          
FUNCTION VDVersion  : Integer ; Tool $21,$04;                                   
PROCEDURE VDReset   ; Tool $21,$05;                                             
FUNCTION VDStatus  : Boolean ; Tool $21,$06;                                    
FUNCTION VDGetFeatures ( videoSelector:Integer) : Integer ; Tool $21,$1B;       
PROCEDURE VDInControl ( videoSelector:Integer; inputCtlValue:Integer)  ; Tool   
$21,$1C;                                                                        
FUNCTION VDInStatus ( videoSelector:Integer) : Integer ; Tool $21,$09;          
PROCEDURE VDInSetStd ( inputStandard:Integer)  ; Tool $21,$0A;                  
FUNCTION VDInGetStd  : Integer ; Tool $21,$0B;                                  
PROCEDURE VDInConvAdj ( videoSelector:Integer; adjustFunction:Integer)  ; Tool  
$21,$0C;                                                                        
PROCEDURE VDKeyControl ( videoSelector:Integer; keyerCtlValue:Integer)  ; Tool  
$21,$0D;                                                                        
FUNCTION VDKeyStatus ( videoSelector:Integer) : Integer ; Tool $21,$0E;         
PROCEDURE VDKeySetKCol ( redValue:Integer; greenValue:Integer;                  
blueValue:Integer)  ; Tool $21,$0F;                                             
FUNCTION VDKeyGetRCol  : Integer ; Tool $21,$10;                                
FUNCTION VDKeyGetGCol  : Integer ; Tool $21,$11;                                
FUNCTION VDKeyGetBCol  : Integer ; Tool $21,$12;                                
PROCEDURE VDKeySetKDiss ( kDissolve:Integer)  ; Tool $21,$13;                   
FUNCTION VDKeyGetKDiss  : Integer ; Tool $21,$14;                               
PROCEDURE VDKeySetNKDiss ( nonKeyDissolve:Integer)  ; Tool $21,$15;             
FUNCTION VDKeyGetNKDiss  : Integer ; Tool $21,$16;                              
PROCEDURE VDOutSetStd ( outStandard:Integer)  ; Tool $21,$17;                   
FUNCTION VDOutGetStd  : Integer ; Tool $21,$18;                                 
PROCEDURE VDOutControl ( videoSelector:Integer; outCtlValue:Integer)  ; Tool    
$21,$19;                                                                        
FUNCTION VDOutStatus ( videoSelector:Integer) : Integer ; Tool $21,$1A;         
PROCEDURE VDGGControl ( videoSelector:Integer; gGCtlValue:Integer)  ; Tool      
$21,$1D;                                                                        
FUNCTION VDGGStatus ( videoSelector:Integer) : Integer ; Tool $21,$1E;          
IMPLEMENTATION                                                                  
END.                                                                            
