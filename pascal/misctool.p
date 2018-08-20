{********************************************                                   
; File: MiscTool.p                                                              
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT MISCTOOL;                                                                  
INTERFACE                                                                       
USES TYPES;                                                                     
                                                                                
(* *** Toolset Errors ***                                                       
CONST                                                                           
badInputErr = $0301; {error - bad input parameter }                             
noDevParamErr = $0302; {error - no device for input parameter }                 
taskInstlErr = $0303; {error - task already installed error }                   
noSigTaskErr = $0304; {error - no signature in task header }                    
queueDmgdErr = $0305; {error - queue has been damaged error }                   
taskNtFdErr = $0306; {error - task was not found error }                        
firmTaskErr = $0307; {error - firmware task was unsuccessful }                  
hbQueueBadErr = $0308; {error - heartbeat queue damaged }                       
unCnctdDevErr = $0309; {error - attempted to dispatch to unconnected device }   
idTagNtAvlErr = $030B; {error - ID tag not available }                          
pdosUnClmdIntErr = $0001; {System Fail - ProDOS unclaimed interrupt error }     
divByZeroErr = $0004; {System Fail - divide by zero error }                     
pdosVCBErr = $000A; {System Fail - ProDOS VCB unusable }                        
pdosFCBErr = $000B; {System Fail - ProDOS FCB unusable }                        
pdosBlk0Err = $000C; {System Fail - ProDOS block zero allocated illegally }     
pdosIntShdwErr = $000D; {System Fail - ProDOS interrupt w/ shadowing off }      
segLoader1Err = $0015; {System Fail - segment loader error }                    
sPackage0Err = $0017; {System Fail - can't load a package }                     
package1Err = $0018; {System Fail - can't load a package }                      
package2Err = $0019; {System Fail - can't load a package }                      
package3Err = $001A; {System Fail - can't load a package }                      
package4Err = $001B; {System Fail - can't load a package }                      
package5Err = $001C; {System Fail - can't load a package }                      
package6Err = $001D; {System Fail - can't load a package }                      
package7Err = $001E; {System Fail - can't load a package }                      
package8Err = $0020; {System Fail - can't load a package }                      
package9Err = $0021; {System Fail - can't load a package }                      
package10Err = $0022; {System Fail - can't load a package }                     
package11Err = $0023; {System Fail - can't load a package }                     
package12Err = $0024; {System Fail - can't load a package }                     
outOfMemErr = $0025; {System Fail - out of memory error }                       
segLoader2Err = $0026; {System Fail - segment loader error }                    
fMapTrshdErr = $0027; {System Fail - file map trashed }                         
stkOvrFlwErr = $0028; {System Fail - stack overflow error }                     
psInstDiskErr = $0030; {System Fail - Please Insert Disk (file manager alert) } 
memMgr1Err = $0032; {System Fail - memory manager error }                       
memMgr2Err = $0033; {System Fail - memory manager error }                       
memMgr3Err = $0034; {System Fail - memory manager error }                       
memMgr4Err = $0035; {System Fail - memory manager error }                       
memMgr5Err = $0036; {System Fail - memory manager error }                       
memMgr6Err = $0037; {System Fail - memory manager error }                       
memMgr7Err = $0038; {System Fail - memory manager error }                       
memMgr8Err = $0039; {System Fail - memory manager error }                       
memMgr9Err = $003A; {System Fail - memory manager error }                       
memMgr10Err = $003B; {System Fail - memory manager error }                      
memMgr11Err = $003C; {System Fail - memory manager error }                      
memMgr12Err = $003D; {System Fail - memory manager error }                      
memMgr13Err = $003E; {System Fail - memory manager error }                      
memMgr14Err = $003F; {System Fail - memory manager error }                      
memMgr15Err = $0040; {System Fail - memory manager error }                      
memMgr16Err = $0041; {System Fail - memory manager error }                      
memMgr17Err = $0042; {System Fail - memory manager error }                      
memMgr18Err = $0043; {System Fail - memory manager error }                      
memMgr19Err = $0044; {System Fail - memory manager error }                      
memMgr20Err = $0045; {System Fail - memory manager error }                      
memMgr21Err = $0046; {System Fail - memory manager error }                      
memMgr22Err = $0047; {System Fail - memory manager error }                      
memMgr23Err = $0048; {System Fail - memory manager error }                      
memMgr24Err = $0049; {System Fail - memory manager error }                      
memMgr25Err = $004A; {System Fail - memory manager error }                      
memMgr26Err = $004B; {System Fail - memory manager error }                      
memMgr27Err = $004C; {System Fail - memory manager error }                      
memMgr28Err = $004D; {System Fail - memory manager error }                      
memMgr29Err = $004E; {System Fail - memory manager error }                      
memMgr30Err = $004F; {System Fail - memory manager error }                      
memMgr31Err = $0050; {System Fail - memory manager error }                      
memMgr32Err = $0051; {System Fail - memory manager error }                      
memMgr33Err = $0052; {System Fail - memory manager error }                      
memMgr34Err = $0053; {System Fail - memory manager error }                      
stupVolMntErr = $0100; {System Fail - can't mount system startup volume }       
   *** Toolset Errors *** *)                                                    
                                                                                
(* *** Reference Numbers ***                                                    
p1PrntModem = $0000; {Battery Ram Parameter Ref Number -  }                     
p1LineLnth = $0001; {Battery Ram Parameter Ref Number -  }                      
p1DelLine = $0002; {Battery Ram Parameter Ref Number -  }                       
p1AddLine = $0003; {Battery Ram Parameter Ref Number -  }                       
p1Echo = $0004; {Battery Ram Parameter Ref Number -  }                          
p1Buffer = $0005; {Battery Ram Parameter Ref Number -  }                        
p1Baud = $0006; {Battery Ram Parameter Ref Number -  }                          
p1DtStpBits = $0007; {Battery Ram Parameter Ref Number -  }                     
p1Parity = $0008; {Battery Ram Parameter Ref Number -  }                        
p1DCDHndShk = $0009; {Battery Ram Parameter Ref Number -  }                     
p1DSRHndShk = $000A; {Battery Ram Parameter Ref Number -  }                     
p1XnfHndShk = $000B; {Battery Ram Parameter Ref Number -  }                     
p2PrntModem = $000C; {Battery Ram Parameter Ref Number -  }                     
p2LineLnth = $000D; {Battery Ram Parameter Ref Number -  }                      
p2DelLine = $000E; {Battery Ram Parameter Ref Number -  }                       
p2AddLine = $000F; {Battery Ram Parameter Ref Number -  }                       
p2Echo = $0010; {Battery Ram Parameter Ref Number -  }                          
p2Buffer = $0011; {Battery Ram Parameter Ref Number -  }                        
p2Baud = $0012; {Battery Ram Parameter Ref Number -  }                          
p2DtStpBits = $0013; {Battery Ram Parameter Ref Number -  }                     
p2Parity = $0014; {Battery Ram Parameter Ref Number -  }                        
p2DCDHndShk = $0015; {Battery Ram Parameter Ref Number -  }                     
p2DSRHndShk = $0016; {Battery Ram Parameter Ref Number -  }                     
p2XnfHndShk = $0017; {Battery Ram Parameter Ref Number -  }                     
dspColMono = $0018; {Battery Ram Parameter Ref Number -  }                      
dsp40or80 = $0019; {Battery Ram Parameter Ref Number -  }                       
dspTxtColor = $001A; {Battery Ram Parameter Ref Number -  }                     
dspBckColor = $001B; {Battery Ram Parameter Ref Number -  }                     
dspBrdColor = $001C; {Battery Ram Parameter Ref Number -  }                     
hrtz50or60 = $001D; {Battery Ram Parameter Ref Number -  }                      
userVolume = $001E; {Battery Ram Parameter Ref Number -  }                      
bellVolume = $001F; {Battery Ram Parameter Ref Number -  }                      
sysSpeed = $0020; {Battery Ram Parameter Ref Number -  }                        
slt1intExt = $0021; {Battery Ram Parameter Ref Number -  }                      
slt2intExt = $0022; {Battery Ram Parameter Ref Number -  }                      
slt3intExt = $0023; {Battery Ram Parameter Ref Number -  }                      
slt4intExt = $0024; {Battery Ram Parameter Ref Number -  }                      
slt5intExt = $0025; {Battery Ram Parameter Ref Number -  }                      
slt6intExt = $0026; {Battery Ram Parameter Ref Number -  }                      
slt7intExt = $0027; {Battery Ram Parameter Ref Number -  }                      
startupSlt = $0028; {Battery Ram Parameter Ref Number -  }                      
txtDspLang = $0029; {Battery Ram Parameter Ref Number -  }                      
kybdLang = $002A; {Battery Ram Parameter Ref Number -  }                        
kyBdBuffer = $002B; {Battery Ram Parameter Ref Number -  }                      
kyBdRepSpd = $002C; {Battery Ram Parameter Ref Number -  }                      
kyBdRepDel = $002D; {Battery Ram Parameter Ref Number -  }                      
dblClkTime = $002E; {Battery Ram Parameter Ref Number -  }                      
flashRate = $002F; {Battery Ram Parameter Ref Number -  }                       
shftCpsLCas = $0030; {Battery Ram Parameter Ref Number -  }                     
fstSpDelKey = $0031; {Battery Ram Parameter Ref Number -  }                     
dualSpeed = $0032; {Battery Ram Parameter Ref Number -  }                       
hiMouseRes = $0033; {Battery Ram Parameter Ref Number -  }                      
dateFormat = $0034; {Battery Ram Parameter Ref Number -  }                      
clockFormat = $0035; {Battery Ram Parameter Ref Number -  }                     
rdMinRam = $0036; {Battery Ram Parameter Ref Number -  }                        
rdMaxRam = $0037; {Battery Ram Parameter Ref Number -  }                        
langCount = $0038; {Battery Ram Parameter Ref Number -  }                       
lang1 = $0039; {Battery Ram Parameter Ref Number -  }                           
lang2 = $003A; {Battery Ram Parameter Ref Number -  }                           
lang3 = $003B; {Battery Ram Parameter Ref Number -  }                           
lang4 = $003C; {Battery Ram Parameter Ref Number -  }                           
lang5 = $003D; {Battery Ram Parameter Ref Number -  }                           
lang6 = $003E; {Battery Ram Parameter Ref Number -  }                           
lang7 = $003F; {Battery Ram Parameter Ref Number -  }                           
lang8 = $0040; {Battery Ram Parameter Ref Number -  }                           
layoutCount = $0041; {Battery Ram Parameter Ref Number -  }                     
layout1 = $0042; {Battery Ram Parameter Ref Number -  }                         
layout2 = $0043; {Battery Ram Parameter Ref Number -  }                         
layout3 = $0044; {Battery Ram Parameter Ref Number -  }                         
layout4 = $0045; {Battery Ram Parameter Ref Number -  }                         
layout5 = $0046; {Battery Ram Parameter Ref Number -  }                         
layout6 = $0047; {Battery Ram Parameter Ref Number -  }                         
layout7 = $0048; {Battery Ram Parameter Ref Number -  }                         
layout8 = $0049; {Battery Ram Parameter Ref Number -  }                         
layout9 = $004A; {Battery Ram Parameter Ref Number -  }                         
layout10 = $004B; {Battery Ram Parameter Ref Number -  }                        
layout11 = $004C; {Battery Ram Parameter Ref Number -  }                        
layout12 = $004D; {Battery Ram Parameter Ref Number -  }                        
layout13 = $004E; {Battery Ram Parameter Ref Number -  }                        
layout14 = $004F; {Battery Ram Parameter Ref Number -  }                        
layout15 = $0050; {Battery Ram Parameter Ref Number -  }                        
layout16 = $0051; {Battery Ram Parameter Ref Number -  }                        
aTalkNodeNo = $0080; {Battery Ram Parameter Ref Number -  }                     
                                                                                
irqIntFlag = $0000; {GetAddr Param Ref No -  }                                  
irqDataReg = $0001; {GetAddr Param Ref No -  }                                  
irqSerial1 = $0002; {GetAddr Param Ref No -  }                                  
irqSerial2 = $0003; {GetAddr Param Ref No -  }                                  
irqAplTlkHi = $0004; {GetAddr Param Ref No -  }                                 
tickCnt = $0005; {GetAddr Param Ref No -  }                                     
irqVolume = $0006; {GetAddr Param Ref No -  }                                   
irqActive = $0007; {GetAddr Param Ref No -  }                                   
irqSndData = $0008; {GetAddr Param Ref No -  }                                  
brkVar = $0009; {GetAddr Param Ref No -  }                                      
evMgrData = $000A; {GetAddr Param Ref No -  }                                   
mouseSlot = $000B; {GetAddr Param Ref No -  }                                   
mouseClamps = $000C; {GetAddr Param Ref No -  }                                 
absClamps = $000D; {GetAddr Param Ref No -  }                                   
sccIntFlag = $000E; {GetAddr Param Ref No -  }                                  
                                                                                
extVGCInt = $01; {Hardware Interrupt Status - Returned by GetIRQEnable }        
scanLineInt = $02; {Hardware Interrupt Status - Returned by GetIRQEnable }      
adbDataInt = $04; {Hardware Interrupt Status - Returned by GetIRQEnable }       
ADTBDataInt = $04; {Hardware Interrupt Status - maintained for compatiblity     
with old interfaces }                                                           
oneSecInt = $10; {Hardware Interrupt Status - Returned by GetIRQEnable }        
quartSecInt = $20; {Hardware Interrupt Status - Returned by GetIRQEnable }      
vbInt = $40; {Hardware Interrupt Status - Returned by GetIRQEnable }            
kbdInt = $80; {Hardware Interrupt Status - Returned by GetIRQEnable }           
                                                                                
kybdEnable = $0000; {Interrupt Ref Number - Parameter to IntSource }            
kybdDisable = $0001; {Interrupt Ref Number - Parameter to IntSource }           
vblEnable = $0002; {Interrupt Ref Number - Parameter to IntSource }             
vblDisable = $0003; {Interrupt Ref Number - Parameter to IntSource }            
qSecEnable = $0004; {Interrupt Ref Number - Parameter to IntSource }            
qSecDisable = $0005; {Interrupt Ref Number - Parameter to IntSource }           
oSecEnable = $0006; {Interrupt Ref Number - Parameter to IntSource }            
oSecDisable = $0007; {Interrupt Ref Number - Parameter to IntSource }           
adbEnable = $000A; {Interrupt Ref Number - Parameter to IntSource }             
adbDisable = $000B; {Interrupt Ref Number - Parameter to IntSource }            
scLnEnable = $000C; {Interrupt Ref Number - Parameter to IntSource }            
scLnDisable = $000D; {Interrupt Ref Number - Parameter to IntSource }           
exVCGEnable = $000E; {Interrupt Ref Number - Parameter to IntSource }           
exVCGDisable = $000F; {Interrupt Ref Number - Parameter to IntSource }          
                                                                                
mouseOff = $0000; {Mouse Mode Value -  }                                        
transparent = $0001; {Mouse Mode Value -  }                                     
transParnt = $0001; {Mouse Mode Value - (old name) }                            
moveIntrpt = $0003; {Mouse Mode Value -  }                                      
bttnIntrpt = $0005; {Mouse Mode Value -  }                                      
bttnOrMove = $0007; {Mouse Mode Value -  }                                      
mouseOffVI = $0008; {Mouse Mode Value -  }                                      
transParntVI = $0009; {Mouse Mode Value - (old name) }                          
transparentVI = $0009; {Mouse Mode Value -  }                                   
moveIntrptVI = $000B; {Mouse Mode Value -  }                                    
bttnIntrptVI = $000D; {Mouse Mode Value -  }                                    
bttnOrMoveVI = $000F; {Mouse Mode Value -  }                                    
                                                                                
toolLoc1 = $0000; {Vector Ref Number -  }                                       
toolLoc2 = $0001; {Vector Ref Number -  }                                       
usrTLoc1 = $0002; {Vector Ref Number -  }                                       
usrTLoc2 = $0003; {Vector Ref Number -  }                                       
intrptMgr = $0004; {Vector Ref Number -  }                                      
copMgr = $0005; {Vector Ref Number -  }                                         
abortMgr = $0006; {Vector Ref Number -  }                                       
U_sysFailMgr = $0007; {Vector Ref Number -  }                                   
aTalkIntHnd = $0008; {Vector Ref Number -  }                                    
sccIntHnd = $0009; {Vector Ref Number -  }                                      
scLnIntHnd = $000A; {Vector Ref Number -  }                                     
sndIntHnd = $000B; {Vector Ref Number -  }                                      
vblIntHnd = $000C; {Vector Ref Number -  }                                      
mouseIntHnd = $000D; {Vector Ref Number -  }                                    
qSecIntHnd = $000E; {Vector Ref Number -  }                                     
kybdIntHnd = $000F; {Vector Ref Number -  }                                     
adbRBIHnd = $0010; {Vector Ref Number -  }                                      
adbSRQHnd = $0011; {Vector Ref Number -  }                                      
deskAccHnd = $0012; {Vector Ref Number -  }                                     
flshBufHnd = $0013; {Vector Ref Number -  }                                     
kybdMicHnd = $0014; {Vector Ref Number -  }                                     
oneSecHnd = $0015; {Vector Ref Number -  }                                      
extVCGHnd = $0016; {Vector Ref Number -  }                                      
otherIntHnd = $0017; {Vector Ref Number -  }                                    
crsrUpdtHnd = $0018; {Vector Ref Number -  }                                    
incBsyFlag = $0019; {Vector Ref Number -  }                                     
decBsyFlag = $001A; {Vector Ref Number -  }                                     
bellVector = $001B; {Vector Ref Number -  }                                     
breakVector = $001C; {Vector Ref Number -  }                                    
traceVector = $001D; {Vector Ref Number -  }                                    
stepVector = $001E; {Vector Ref Number -  }                                     
ctlYVector = $0028; {Vector Ref Number -  }                                     
proDOSVctr = $002A; {Vector Ref Number -  }                                     
osVector = $002B; {Vector Ref Number -  }                                       
msgPtrVctr = $002C; {Vector Ref Number -  }                                     
   *** Reference Numbers *** *)                                                 
                                                                                
                                                                                
TYPE                                                                            
ClampRecHndl = ^ClampRecPtr;                                                    
ClampRecPtr = ^ClampRec;                                                        
ClampRec = RECORD                                                               
    yMaxClamp : Integer;                                                        
    yMinClamp : Integer;                                                        
    xMaxClamp : Integer;                                                        
    xMinClamp : Integer;                                                        
END;                                                                            
FWRecHndl = ^FWRecPtr;                                                          
FWRecPtr = ^FWRec;                                                              
FWRec = RECORD                                                                  
    yRegExit : Integer;                                                         
    xRegExit : Integer;                                                         
    aRegExit : Integer;                                                         
    status : Integer;                                                           
END;                                                                            
MouseRecHndl = ^MouseRecPtr;                                                    
MouseRecPtr = ^MouseRec;                                                        
MouseRec = PACKED RECORD                                                        
    mouseMode : Byte;                                                           
    mouseStatus : Byte;                                                         
    yPos : Integer;                                                             
    xPos : Integer;                                                             
END;                                                                            
InterruptStateRecHndl = ^InterruptStateRecPtr;                                  
InterruptStateRecPtr = ^InterruptStateRec;                                      
InterruptStateRec = PACKED RECORD                                               
    irq_A : Integer;                                                            
    irq_X : Integer;                                                            
    irq_Y : Integer;                                                            
    irq_S : Integer;                                                            
    irq_D : Integer;                                                            
    irq_P : Byte;                                                               
    irq_DB : Byte;                                                              
    irq_e : Byte;                                                               
    irq_K : Byte;                                                               
    irq_PC : Integer;                                                           
    irq_state : Byte;                                                           
    irq_shadow : Integer;                                                       
    irq_mslot : Byte;                                                           
END;                                                                            
PROCEDURE MTBootInit   ; Tool $03,$01;                                          
PROCEDURE MTStartUp   ; Tool $03,$02;                                           
PROCEDURE MTShutDown   ; Tool $03,$03;                                          
FUNCTION MTVersion  : Integer ; Tool $03,$04;                                   
PROCEDURE MTReset   ; Tool $03,$05;                                             
FUNCTION MTStatus  : Boolean ; Tool $03,$06;                                    
PROCEDURE ClampMouse ( xMinClamp:Integer; xMaxClamp:Integer; yMinClamp:Integer; 
yMaxClamp:Integer)  ; Tool $03,$1C;                                             
PROCEDURE ClearMouse   ; Tool $03,$1B;                                          
PROCEDURE ClrHeartBeat   ; Tool $03,$14;                                        
PROCEDURE DeleteID ( idTag:Integer)  ; Tool $03,$21;                            
PROCEDURE DelHeartBeat ( taskPtr:Ptr)  ; Tool $03,$13;                          
FUNCTION FWEntry ( aRegValue:Integer; xRegValue:Integer; yRegValue:Integer;     
eModeEntryPt:Integer) : FWRec ; EXTERNAL ;                                      
FUNCTION GetAbsClamp  : ClampRec ; EXTERNAL ;                                   
FUNCTION GetAddr ( refNum:Integer) : Ptr ; Tool $03,$16;                        
FUNCTION GetIRQEnable  : Integer ; Tool $03,$29;                                
FUNCTION GetMouseClamp  : ClampRec ; EXTERNAL ;                                 
FUNCTION GetNewID ( idTag:Integer) : Integer ; Tool $03,$20;                    
FUNCTION GetTick  : Longint ; Tool $03,$25;                                     
FUNCTION GetVector ( vectorRefNum:Integer) : Ptr ; Tool $03,$11;                
PROCEDURE HomeMouse   ; Tool $03,$1A;                                           
PROCEDURE InitMouse ( mouseSlot:Integer)  ; Tool $03,$18;                       
PROCEDURE IntSource ( srcRefNum:Integer)  ; Tool $03,$23;                       
FUNCTION Munger ( destPtr:Ptr; destLenPtr:IntPtr; targPtr:Ptr; targLen:Integer; 
replPtr:Ptr; replLen:Integer; padPtr:Ptr) : Integer ; Tool $03,$28;             
FUNCTION PackBytes (VAR srcBuffer:Ptr;VAR srcSize:Integer; dstBuffer:Ptr;       
dstSize:Integer) : Integer ; Tool $03,$26;                                      
PROCEDURE PosMouse ( xPos:Integer; yPos:Integer)  ; Tool $03,$1E;               
PROCEDURE ReadAsciiTime ( bufferPtr:Ptr)  ; Tool $03,$0F;                       
FUNCTION ReadBParam ( paramRefNum:Integer) : Integer ; Tool $03,$0C;            
PROCEDURE ReadBRam ( bufferPtr:Ptr)  ; Tool $03,$0A;                            
FUNCTION ReadMouse  : MouseRec ; EXTERNAL ;                                     
FUNCTION ReadTimeHex  : TimeRec ; EXTERNAL ;                                    
FUNCTION ServeMouse  : Integer ; Tool $03,$1F;                                  
PROCEDURE SetAbsClamp ( xMinClamp:Integer; xMaxClamp:Integer;                   
yMinClamp:Integer; yMaxClamp:Integer)  ; EXTERNAL ;                             
PROCEDURE SetHeartBeat ( taskPtr:Ptr)  ; Tool $03,$12;                          
PROCEDURE SetMouse ( mouseMode:Integer)  ; Tool $03,$19;                        
PROCEDURE SetVector ( vectorRefNum:Integer; vectorPtr:Ptr)  ; Tool $03,$10;     
PROCEDURE StatusID ( idTag:Integer)  ; Tool $03,$22;                            
PROCEDURE SysBeep   ; Tool $03,$2C;                                             
PROCEDURE SysFailMgr ( errorCode:Integer; str:Str255)  ; Tool $03,$15;          
FUNCTION UnPackBytes ( srcBuffer:Ptr; srcSize:Integer;VAR dstBuffer:Ptr;VAR     
dstSize:Integer) : Integer ; Tool $03,$27;                                      
PROCEDURE WriteBParam ( theData:Integer; paramRefNum:Integer)  ; Tool $03,$0B;  
PROCEDURE WriteBRam ( bufferPtr:Ptr)  ; Tool $03,$09;                           
PROCEDURE WriteTimeHex ( month:Byte; day:Byte; curYear:Byte; hour:Byte;         
minute:Byte; second:Byte)  ; EXTERNAL ;                                         
PROCEDURE AddToQueue ( newEntryPtr:Ptr; headerPtr:Ptr)  ; Tool $03,$2E;         
PROCEDURE DeleteFromQueue ( entryPtr:Ptr; headerPtr:Ptr)  ; Tool $03,$2F;       
PROCEDURE SetInterruptState ( iStateRec:InterruptStateRec;                      
bytesDesired:Integer)  ; Tool $03,$30;                                          
PROCEDURE GetInterruptState (VAR iStateRec:InterruptStateRec;                   
bytesDesired:Integer)  ; Tool $03,$31;                                          
FUNCTION GetIntStateRecSize  : Integer ; Tool $03,$32;                          
FUNCTION ReadMouse2  : MouseRec ; EXTERNAL ;                                    
FUNCTION GetCodeResConverter  : ProcPtr ; Tool $03,$34;                         
FUNCTION GetRomResource  : Ptr ; Tool $03,$35;                                  
IMPLEMENTATION                                                                  
END.                                                                            
