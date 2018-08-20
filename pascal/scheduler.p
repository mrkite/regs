{********************************************                                   
; File: Scheduler.p                                                             
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT SCHEDULER;                                                                 
INTERFACE                                                                       
USES TYPES;                                                                     
PROCEDURE SchBootInit   ; Tool $07,$01;                                         
PROCEDURE SchStartUp   ; Tool $07,$02;                                          
PROCEDURE SchShutDown   ; Tool $07,$03;                                         
FUNCTION SchVersion  : Integer ; Tool $07,$04;                                  
PROCEDURE SchReset   ; Tool $07,$05;                                            
FUNCTION SchStatus  : Boolean ; Tool $07,$06;                                   
FUNCTION SchAddTask ( taskPtr:VoidProcPtr) : Boolean ; Tool $07,$09;            
PROCEDURE SchFlush   ; Tool $07,$0A;                                            
IMPLEMENTATION                                                                  
END.                                                                            
