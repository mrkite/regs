{********************************************                                   
; File: IntMath.p                                                               
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT INTMATH;                                                                   
INTERFACE                                                                       
USES TYPES;                                                                     
CONST                                                                           
                                                                                
(* *** Toolset Errors ***                                                       
imBadInptParam = $0B01; {error - bad input parameter }                          
imIllegalChar = $0B02; {error - Illegal character in string }                   
imOverflow = $0B03; {error - integer or long integer overflow }                 
imStrOverflow = $0B04; {error - string overflow }                               
   *** Toolset Errors *** *)                                                    
                                                                                
minLongint = $80000000; {Limit - minimum negative signed long integer }         
minFrac = $80000000; {Limit - pinned value for negative Frac overflow }         
minFixed = $80000000; {Limit - pinned value for negative Fixed overflow }       
minInt = $8000; {Limit - Minimum negative signed integer }                      
maxInt = $7FFF; {Limit - Maximum positive signed integer }                      
maxUInt = $FFFF; {Limit - Maximum positive unsigned integer }                   
maxLongint = $7FFFFFFF; {Limit - maximum positive signed Longint }              
maxFrac = $7FFFFFFF; {Limit - pinned value for positive Frac overflow }         
maxFixed = $7FFFFFFF; {Limit - pinned value for positive Fixed overflow }       
maxULong = $FFFFFFFF; {Limit - maximum unsigned Long }                          
unsignedFlag = $0000; {SignedFlag -  }                                          
signedFlag = $0001; {SignedFlag -  }                                            
                                                                                
TYPE                                                                            
IntDivRecPtr = ^IntDivRec;                                                      
IntDivRec = RECORD                                                              
    quotient : Integer; { quotient from SDivide }                               
    remainder : Integer; { remainder from SDivide }                             
END;                                                                            
LongDivRecPtr = ^LongDivRec;                                                    
LongDivRec = RECORD                                                             
    quotient : Longint; { Quotient from LongDiv }                               
    remainder : Longint; { remainder from LongDiv }                             
END;                                                                            
DivRecPtr = ^DivRec; (* for backward compatability *)                           
DivRec = LongDivRec;                                                            
LongMulRecPtr = ^LongMulRec;                                                    
LongMulRec = RECORD                                                             
    lsResult : Longint; { low 2 words of product }                              
    msResult : Longint; { High 2 words of product }                             
END;                                                                            
WordDivRecPtr = ^WordDivRec;                                                    
WordDivRec = RECORD                                                             
    quotient : Integer; { Quotient from UDivide }                               
    remainder : Integer; { remainder from UDivide }                             
END;                                                                            
PROCEDURE IMBootInit   ; Tool $0B,$01;                                          
PROCEDURE IMStartUp   ; Tool $0B,$02;                                           
PROCEDURE IMShutDown   ; Tool $0B,$03;                                          
FUNCTION IMVersion  : Integer ; Tool $0B,$04;                                   
PROCEDURE IMReset   ; Tool $0B,$05;                                             
FUNCTION IMStatus  : Boolean ; Tool $0B,$06;                                    
FUNCTION Dec2Int ( strPtr:Ptr; strLength:Integer; signedFlag:Boolean) : Integer 
; Tool $0B,$28;                                                                 
FUNCTION Dec2Long ( strPtr:Ptr; strLength:Integer; signedFlag:Boolean) :        
Longint ; Tool $0B,$29;                                                         
FUNCTION Fix2Frac ( fixedValue:Fixed) : Frac ; Tool $0B,$1C;                    
FUNCTION Fix2Long ( fixedValue:Fixed) : Longint ; Tool $0B,$1B;                 
PROCEDURE Fix2X ( fixedValue:Fixed;VAR extendPtr:Extended)  ; Tool $0B,$1E;     
FUNCTION FixATan2 ( input1:Longint; input2:Longint) : Fixed ; Tool $0B,$17;     
FUNCTION FixDiv ( dividend:Longint; divisor:Longint) : Fixed ; Tool $0B,$11;    
FUNCTION FixMul ( multiplicand:Fixed; multiplier:Fixed) : Fixed ; Tool $0B,$0F; 
FUNCTION FixRatio ( numerator:Integer; denominator:Integer) : Fixed ; Tool      
$0B,$0E;                                                                        
FUNCTION FixRound ( fixedValue:Fixed) : Integer ; Tool $0B,$13;                 
FUNCTION Frac2Fix ( fracValue:Frac) : Fixed ; Tool $0B,$1D;                     
PROCEDURE Frac2X ( fracValue:Frac;VAR extendPtr:Extended)  ; Tool $0B,$1F;      
FUNCTION FracCos ( angle:Fixed) : Frac ; Tool $0B,$15;                          
FUNCTION FracDiv ( dividend:Longint; divisor:Longint) : Frac ; Tool $0B,$12;    
FUNCTION FracMul ( multiplicand:Frac; multiplier:Frac) : Frac ; Tool $0B,$10;   
FUNCTION FracSin ( angle:Fixed) : Frac ; Tool $0B,$16;                          
FUNCTION FracSqrt ( fracValue:Frac) : Frac ; Tool $0B,$14;                      
FUNCTION Hex2Int ( strPtr:Ptr; strLength:Integer) : Integer ; Tool $0B,$24;     
FUNCTION Hex2Long ( strPtr:Ptr; strLength:Integer) : Longint ; Tool $0B,$25;    
FUNCTION HexIt ( intValue:Integer) : Longint ; Tool $0B,$2A;                    
FUNCTION HiWord ( longValue:Longint) : Integer ; Tool $0B,$18;                  
PROCEDURE Int2Dec ( wordValue:Integer; strPtr:Ptr; strLength:Integer;           
signedFlag:Boolean)  ; Tool $0B,$26;                                            
PROCEDURE Int2Hex ( intValue:Integer; strPtr:Ptr; strLength:Integer)  ; Tool    
$0B,$22;                                                                        
PROCEDURE Long2Dec ( longValue:Longint; strPtr:Ptr; strLength:Integer;          
signedFlag:Boolean)  ; Tool $0B,$27;                                            
FUNCTION Long2Fix ( longValue:Longint) : Fixed ; Tool $0B,$1A;                  
PROCEDURE Long2Hex ( longValue:Longint; strPtr:Ptr; strLength:Integer)  ; Tool  
$0B,$23;                                                                        
FUNCTION LongDivide ( dividend:Longint; divisor:Longint) : LongDivRec ;         
EXTERNAL ;                                                                      
FUNCTION LongMul ( multiplicand:Longint; multiplier:Longint) : LongMulRec ;     
EXTERNAL ;                                                                      
FUNCTION LoWord ( longValue:Longint) : Integer ; Tool $0B,$19;                  
FUNCTION Multiply ( multiplicand:Integer; multiplier:Integer) : Longint ; Tool  
$0B,$09;                                                                        
FUNCTION SDivide ( dividend:Integer; divisor:Integer) : IntDivRec ; Tool        
$0B,$0A;                                                                        
FUNCTION UDivide ( dividend:Integer; divisor:Integer) : WordDivRec ; Tool       
$0B,$0B;                                                                        
FUNCTION X2Fix ( extendPtr:ExtendedPtr) : Longint ; Tool $0B,$20;               
FUNCTION X2Frac ( extendPtr:ExtendedPtr) : Longint ; Tool $0B,$21;              
IMPLEMENTATION                                                                  
END.                                                                            
