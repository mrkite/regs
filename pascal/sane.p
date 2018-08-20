UNIT SANE;                                                                      
                                                                                
{ Apple IIGS SANE Interfaces                                                    
                                                                                
  See the Apple Numerics Manual for complete documentation                      
                                                                                
                                                                                
  Copyright (c) 1986-1988 by TML Systems, Inc. All Rights Reserved.             
}                                                                               
                                                                                
                                                                                
{ The SANE environment word (Integer) is defined as follows:                    
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
}                                                                               
                                                                                
INTERFACE                                                                       
                                                                                
CONST   DecStrLen   = 255;                                                      
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
TYPE                                                                            
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
{ Standard housekeeping routines }                                              
                                                                                
PROCEDURE SANEStartUp                                                           
                                                                                
PROCEDURE SANEShutDown;                                                         
FUNCTION  SANEVersion: Integer;                                                 
PROCEDURE SANEReset;                                                            
FUNCTION  SANEStatus: Integer;                                                  
                                                                                
{ Conversions between numeric binary types }                                    
                                                                                
FUNCTION  Num2Integer                                                           
                                                                                
FUNCTION  Num2Longint                                                           
                                                                                
FUNCTION  Num2Real                                                              
                                                                                
FUNCTION  Num2Double                                                            
                                                                                
FUNCTION  Num2Extended                                                          
                                                                                
FUNCTION  Num2Comp                                                              
                                                                                
                                                                                
{ Conversions between binary and decimal }                                      
                                                                                
PROCEDURE Num2Dec                                                               
                                                                                
                                                                                
                                                                                
FUNCTION  Dec2Num                                                               
                                                                                
                                                                                
{ Conversions between decimal formats }                                         
                                                                                
PROCEDURE Str2Dec                                                               
                                                                                
                                                                                
                                                                                
                                                                                
PROCEDURE CStr2Dec                                                              
                                                                                
                                                                                
                                                                                
PROCEDURE Dec2Str                                                               
                                                                                
                                                                                
                                                                                
                                                                                
{ Arithmetic, auxiliary and elementary functions }                              
                                                                                
FUNCTION  Remainder                                                             
                                                                                
                                                                                
FUNCTION  Rint                                                                  
                                                                                
FUNCTION  Scalb                                                                 
                                                                                
                                                                                
FUNCTION  Logb                                                                  
                                                                                
FUNCTION  Log2                                                                  
                                                                                
FUNCTION  Ln1                                                                   
                                                                                
FUNCTION  Exp2                                                                  
                                                                                
FUNCTION  Exp1                                                                  
                                                                                
FUNCTION  Tan                                                                   
                                                                                
                                                                                
FUNCTION  CopySign                                                              
                                                                                
FUNCTION  NextExtended                                                          
                                                                                
FUNCTION  XpwrI                                                                 
                                                                                
                                                                                
FUNCTION  XpwrY                                                                 
                                                                                
FUNCTION  Compound                                                              
                                                                                
FUNCTION  Annuity                                                               
                                                                                
FUNCTION  RandomX                                                               
                                                                                
                                                                                
{ Inquirty routines }                                                           
                                                                                
FUNCTION  ClassReal                                                             
                                                                                
FUNCTION  ClassDouble                                                           
                                                                                
FUNCTION  ClassComp                                                             
                                                                                
FUNCTION  ClassExtended                                                         
                                                                                
FUNCTION  SignNum                                                               
                                                                                
                                                                                
{ NaN function }                                                                
                                                                                
FUNCTION  NAN                                                                   
                                                                                
                                                                                
{ Environment control routines }                                                
                                                                                
FUNCTION  GetHaltVector: Integer;                                               
PROCEDURE SetHaltVector                                                         
                                                                                
                                                                                
{ Environment access routines }                                                 
PROCEDURE SetEnvironment                                                        
                                                                                
PROCEDURE GetEnvironment                                                        
                                                                                
PROCEDURE ProcEntry                                                             
                                                                                
PROCEDURE ProcExit                                                              
                                                                                
                                                                                
{ Comparison routine }                                                          
                                                                                
FUNCTION  Relation                                                              
                                                                                
                                                                                
IMPLEMENTATION                                                                  
                                                                                
END.                                                                            
