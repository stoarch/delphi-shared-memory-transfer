unit smHub_TLB;

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
// File generated on 8/25/2017 1:07:00 PM from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\work.delphi\Test.Transfer\smHub.tlb (1)
// LIBID: {99B3C9FC-823C-41BB-8EE6-C96AC7793EA7}
// LCID: 0
// Helpfile: 
// HelpString: smHub Library
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
  smHubMajorVersion = 1;
  smHubMinorVersion = 0;

  LIBID_smHub: TGUID = '{99B3C9FC-823C-41BB-8EE6-C96AC7793EA7}';

  IID_IISharedMemoryHub: TGUID = '{3A679666-0E28-4DCD-A955-887427BAF07F}';
  CLASS_ISharedMemoryHub: TGUID = '{D80B9910-1514-4824-8C00-C3261395D345}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IISharedMemoryHub = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  ISharedMemoryHub = IISharedMemoryHub;


// *********************************************************************//
// Interface: IISharedMemoryHub
// Flags:     (256) OleAutomation
// GUID:      {3A679666-0E28-4DCD-A955-887427BAF07F}
// *********************************************************************//
  IISharedMemoryHub = interface(IUnknown)
    ['{3A679666-0E28-4DCD-A955-887427BAF07F}']
    function GetSharedMemoryName(out value: WideString): HResult; stdcall;
  end;

// *********************************************************************//
// The Class CoISharedMemoryHub provides a Create and CreateRemote method to          
// create instances of the default interface IISharedMemoryHub exposed by              
// the CoClass ISharedMemoryHub. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoISharedMemoryHub = class
    class function Create: IISharedMemoryHub;
    class function CreateRemote(const MachineName: string): IISharedMemoryHub;
  end;

implementation

uses ComObj;

class function CoISharedMemoryHub.Create: IISharedMemoryHub;
begin
  Result := CreateComObject(CLASS_ISharedMemoryHub) as IISharedMemoryHub;
end;

class function CoISharedMemoryHub.CreateRemote(const MachineName: string): IISharedMemoryHub;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ISharedMemoryHub) as IISharedMemoryHub;
end;

end.
