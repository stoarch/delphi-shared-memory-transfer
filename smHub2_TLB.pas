unit smHub2_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 8/26/2017 2:41:37 PM from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\work.delphi\Test.Transfer\smHubApp.tlb (1)
// LIBID: {381FB692-9141-4D72-90BC-1934D7D870CF}
// LCID: 0
// Helpfile: 
// HelpString: smHub2 Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  smHub2MajorVersion = 1;
  smHub2MinorVersion = 0;

  LIBID_smHub2: TGUID = '{381FB692-9141-4D72-90BC-1934D7D870CF}';

  IID_ISharedMemoryHub2: TGUID = '{69AF3CA2-2E6E-4A35-BCF7-239F04DFC3CB}';
  CLASS_SharedMemoryHub2: TGUID = '{E456485A-B2BB-4166-8A4E-44A60AFFBE2D}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ISharedMemoryHub2 = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  SharedMemoryHub2 = ISharedMemoryHub2;


// *********************************************************************//
// Interface: ISharedMemoryHub2
// Flags:     (256) OleAutomation
// GUID:      {69AF3CA2-2E6E-4A35-BCF7-239F04DFC3CB}
// *********************************************************************//
  ISharedMemoryHub2 = interface(IUnknown)
    ['{69AF3CA2-2E6E-4A35-BCF7-239F04DFC3CB}']
    function GetSharedMemoryName(out value: WideString): HResult; stdcall;
  end;

// *********************************************************************//
// The Class CoSharedMemoryHub2 provides a Create and CreateRemote method to          
// create instances of the default interface ISharedMemoryHub2 exposed by              
// the CoClass SharedMemoryHub2. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSharedMemoryHub2 = class
    class function Create: ISharedMemoryHub2;
    class function CreateRemote(const MachineName: string): ISharedMemoryHub2;
  end;

implementation

uses ComObj;

class function CoSharedMemoryHub2.Create: ISharedMemoryHub2;
begin
  Result := CreateComObject(CLASS_SharedMemoryHub2) as ISharedMemoryHub2;
end;

class function CoSharedMemoryHub2.CreateRemote(const MachineName: string): ISharedMemoryHub2;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SharedMemoryHub2) as ISharedMemoryHub2;
end;

end.
