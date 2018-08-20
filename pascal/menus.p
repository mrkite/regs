{********************************************                                   
; File: Menus.p                                                                 
;                                                                               
;                                                                               
; Copyright Apple Computer, Inc. 1986-89                                        
; All Rights Reserved                                                           
;                                                                               
********************************************}                                   
                                                                                
UNIT MENUS;                                                                     
INTERFACE                                                                       
USES TYPES,QUICKDRAW,EVENTS,CONTROLS,WINDOWS;                                   
CONST                                                                           
                                                                                
mDrawMsg = $0000; {MenuDefProcCodes -  }                                        
mChooseMsg = $0001; {MenuDefProcCodes -  }                                      
mSizeMsg = $0002; {MenuDefProcCodes -  }                                        
mDrawTitle = $0003; {MenuDefProcCodes -  }                                      
mDrawMItem = $0004; {MenuDefProcCodes -  }                                      
mGetMItemID = $0005; {MenuDefProcCodes -  }                                     
mInvis = $0004; {MenuFlag -  }                                                  
mCustom = $0010; {MenuFlag -  }                                                 
mXor = $0020; {MenuFlag -  }                                                    
mSelected = $0040; {MenuFlag -  }                                               
mDisabled = $0080; {MenuFlag -  }                                               
customMenu = $0010; {MenuFlagMasks -  }                                         
xorMItemHilite = $0020; {MenuFlagMasks -  }                                     
xorTitleHilite = $0020; {MenuFlagMasks -  }                                     
underMItem = $0040; {MenuFlagMasks -  }                                         
disableItem = $0080; {MenuFlagMasks -  }                                        
disableMenu = $0080; {MenuFlagMasks -  }                                        
enableItem = $FF7F; {MenuFlagMasks -  }                                         
enableMenu = $FF7F; {MenuFlagMasks -  }                                         
noUnderMItem = $FFBF; {MenuFlagMasks -  }                                       
colorMItemHilite = $FFDF; {MenuFlagMasks -  }                                   
colorTitleHilite = $FFDF; {MenuFlagMasks -  }                                   
colorReplace = $FFDF; {MenuFlagMasks -  }                                       
standardMenu = $FFEF; {MenuFlagMasks -  }                                       
                                                                                
TYPE                                                                            
MenuBarRecHndl = ^MenuBarRecPtr;                                                
MenuBarRecPtr = ^MenuBarRec;                                                    
MenuBarRec = CtlRec ;                                                           
MenuRecHndl = ^MenuRecPtr;                                                      
MenuRecPtr = ^MenuRec;                                                          
MenuRec = PACKED RECORD                                                         
    menuID : Integer; { Menu's ID number }                                      
    menuWidth : Integer; { Width of menu }                                      
    menuHeight : Integer; { Height of menu }                                    
    menuProc : WordProcPtr; { Menu's definition procedure }                     
    menuFlag : Integer; { Bit flags }                                           
    firstItem : Byte;                                                           
    numOfItems : Byte;                                                          
    titleWidth : Integer; { Width of menu's title }                             
    titleName : Ptr;                                                            
END;                                                                            
PROCEDURE MenuBootInit   ; Tool $0F,$01;                                        
PROCEDURE MenuStartUp ( userID:Integer; dPageAddr:Integer)  ; Tool $0F,$02;     
PROCEDURE MenuShutDown   ; Tool $0F,$03;                                        
FUNCTION MenuVersion  : Integer ; Tool $0F,$04;                                 
PROCEDURE MenuReset   ; Tool $0F,$05;                                           
FUNCTION MenuStatus  : Boolean ; Tool $0F,$06;                                  
PROCEDURE CalcMenuSize ( newWidth:Integer; newHeight:Integer; menuNum:Integer)  
; Tool $0F,$1C;                                                                 
PROCEDURE CheckMItem ( checkedFlag:Boolean; itemNum:Integer)  ; Tool $0F,$32;   
FUNCTION CountMItems ( menuNum:Integer) : Integer ; Tool $0F,$14;               
PROCEDURE DeleteMenu ( menuNum:Integer)  ; Tool $0F,$0E;                        
PROCEDURE DeleteMItem ( itemNum:Integer)  ; Tool $0F,$10;                       
PROCEDURE DisableMItem ( itemNum:Integer)  ; Tool $0F,$31;                      
PROCEDURE DisposeMenu ( menuHandle:MenuRecHndl)  ; Tool $0F,$2E;                
PROCEDURE DrawMenuBar   ; Tool $0F,$2A;                                         
PROCEDURE EnableMItem ( itemNum:Integer)  ; Tool $0F,$30;                       
FUNCTION FixMenuBar  : Integer ; Tool $0F,$13;                                  
PROCEDURE FlashMenuBar   ; Tool $0F,$0C;                                        
FUNCTION GetBarColors  : Longint ; Tool $0F,$18;                                
FUNCTION GetMenuBar  : MenuBarRecHndl ; Tool $0F,$0A;                           
FUNCTION GetMenuFlag ( menuNum:Integer) : Integer ; Tool $0F,$20;               
FUNCTION GetMenuMgrPort  : GrafPortPtr ; Tool $0F,$1B;                          
FUNCTION GetMenuTitle ( menuNum:Integer) : Ptr ; Tool $0F,$22;                  
FUNCTION GetMHandle ( menuNum:Integer) : MenuRecHndl ; Tool $0F,$16;            
FUNCTION GetMItem ( itemNum:Integer) : StringPtr ; Tool $0F,$25;                
FUNCTION GetMItemFlag ( itemNum:Integer) : Integer ; Tool $0F,$27;              
FUNCTION GetMItemMark ( itemNum:Integer) : Integer ; Tool $0F,$34;              
FUNCTION GetMItemStyle ( itemNum:Integer) : TextStyle ; Tool $0F,$36;           
FUNCTION GetMTitleStart  : Integer ; Tool $0F,$1A;                              
FUNCTION GetMTitleWidth ( menuNum:Integer) : Integer ; Tool $0F,$1E;            
FUNCTION GetSysBar  : MenuBarRecHndl ; Tool $0F,$11;                            
PROCEDURE HiliteMenu ( hiliteFlag:Boolean; menuNum:Integer)  ; Tool $0F,$2C;    
PROCEDURE InitPalette   ; Tool $0F,$2F;                                         
PROCEDURE InsertMenu ( addMenuHandle:MenuRecHndl; insertAfter:Integer)  ; Tool  
$0F,$0D;                                                                        
PROCEDURE InsertMItem ( addItemPtr:Ptr; insertAfter:Integer; menuNum:Integer)   
; Tool $0F,$0F;                                                                 
FUNCTION MenuGlobal ( menuGlobalMask:Integer) : Integer ; Tool $0F,$23;         
PROCEDURE MenuKey ( taskRecPtr:WmTaskRec; barHandle:MenuBarRecHndl)  ; Tool     
$0F,$09;                                                                        
PROCEDURE MenuNewRes   ; Tool $0F,$29;                                          
PROCEDURE MenuRefresh ( redrawRoutinePtr:VoidProcPtr)  ; Tool $0F,$0B;          
PROCEDURE MenuSelect ( taskRecPtr:WmTaskRec; barHandle:MenuBarRecHndl)  ; Tool  
$0F,$2B;                                                                        
FUNCTION NewMenu ( menuStringPtr:Ptr) : MenuRecHndl ; Tool $0F,$2D;             
FUNCTION NewMenuBar ( theWindowPtr:WindowPtr) : MenuBarRecHndl ; Tool $0F,$15;  
PROCEDURE SetBarColors ( newBarColor:Integer; newInvertColor:Integer;           
newOutColor:Integer)  ; Tool $0F,$17;                                           
PROCEDURE SetMenuBar ( barHandle:MenuBarRecHndl)  ; Tool $0F,$39;               
PROCEDURE SetMenuFlag ( newValue:Integer; menuNum:Integer)  ; Tool $0F,$1F;     
PROCEDURE SetMenuID ( newMenuNum:Integer; curMenuNum:Integer)  ; Tool $0F,$37;  
PROCEDURE SetMenuTitle ( newStr:Str255; menuNum:Integer)  ; Tool $0F,$21;       
PROCEDURE SetMItem ( newItemLine:Str255; itemNum:Integer)  ; Tool $0F,$24;      
PROCEDURE SetMItemBlink ( count:Integer)  ; Tool $0F,$28;                       
PROCEDURE SetMItemFlag ( newValue:Integer; itemNum:Integer)  ; Tool $0F,$26;    
PROCEDURE SetMItemID ( newItemNum:Integer; curItemNum:Integer)  ; Tool $0F,$38; 
PROCEDURE SetMItemMark ( mark:Integer; itemNum:Integer)  ; Tool $0F,$33;        
PROCEDURE SetMItemName ( str:Str255; itemNum:Integer)  ; Tool $0F,$3A;          
PROCEDURE SetMItemStyle ( theTextStyle:TextStyle; itemNum:Integer)  ; Tool      
$0F,$35;                                                                        
PROCEDURE SetMTitleStart ( xStart:Integer)  ; Tool $0F,$19;                     
PROCEDURE SetMTitleWidth ( newWidth:Integer; menuNum:Integer)  ; Tool $0F,$1D;  
PROCEDURE SetSysBar ( barHandle:MenuBarRecHndl)  ; Tool $0F,$12;                
FUNCTION PopUpMenuSelect ( selection:Integer; currentLeft:Integer;              
currentTop:Integer; flag:Integer; menuHandle:MenuRecHndl) : Integer ; Tool      
$0F,$3C;                                                                        
FUNCTION GetPopUpDefProc  : Ptr ; Tool $0F,$3B;                                 
PROCEDURE DrawPopUp ( selection:Integer; flag:Integer; right:Integer;           
bottom:Integer; left:Integer; top:Integer; menuHandle:MenuRecHndl)  ; Tool      
$0F,$3D;                                                                        
FUNCTION NewMenuBar2 ( refDesc:RefDescriptor; menuBarTemplateRef:Ref;           
windowPortPtr:GrafPortPtr) : MenuBarRecHndl ; Tool $0F,$43;                     
FUNCTION NewMenu2 ( refDesc:RefDescriptor; menuTemplateRef:Ref) : MenuRecHndl ; 
Tool $0F,$3E;                                                                   
PROCEDURE InsertMItem2 ( refDesc:RefDescriptor; menuTemplateRef:Ref;            
insertAfter:Integer; menuNum:Integer)  ; Tool $0F,$3F;                          
PROCEDURE SetMenuTitle2 ( refDesc:RefDescriptor; titleRef:Ref; menuNum:Integer) 
; Tool $0F,$40;                                                                 
PROCEDURE SetMItem2 ( refDesc:RefDescriptor; menuItemTempRef:Ref;               
menuItemID:Integer)  ; Tool $0F,$41;                                            
PROCEDURE SetMItemName2 ( refDesc:RefDescriptor; titleRef:Ref;                  
menuItemID:Integer)  ; Tool $0F,$42;                                            
PROCEDURE HideMenuBar   ; Tool $0F,$45;                                         
PROCEDURE ShowMenuBar   ; Tool $0F,$46;                                         
IMPLEMENTATION                                                                  
END.                                                                            
