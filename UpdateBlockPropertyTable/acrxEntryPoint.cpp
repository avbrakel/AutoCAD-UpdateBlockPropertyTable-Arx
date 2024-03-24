// (C) Copyright 2002-2012 by Autodesk, Inc. 
//
// Permission to use, copy, modify, and distribute this software in
// object code form for any purpose and without fee is hereby granted, 
// provided that the above copyright notice appears in all copies and 
// that both that copyright notice and the limited warranty and
// restricted rights notice below appear in all supporting 
// documentation.
//
// AUTODESK PROVIDES THIS PROGRAM "AS IS" AND WITH ALL FAULTS. 
// AUTODESK SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF
// MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.  AUTODESK, INC. 
// DOES NOT WARRANT THAT THE OPERATION OF THE PROGRAM WILL BE
// UNINTERRUPTED OR ERROR FREE.
//
// Use, duplication, or disclosure by the U.S. Government is subject to 
// restrictions set forth in FAR 52.227-19 (Commercial Computer
// Software - Restricted Rights) and DFAR 252.227-7013(c)(1)(ii)
// (Rights in Technical Data and Computer Software), as applicable.
//

//-----------------------------------------------------------------------------
//----- acrxEntryPoint.cpp
//-----------------------------------------------------------------------------
#include "StdAfx.h"
#include "resource.h"
#include "PrintDxf.h"
#include <stdlib.h>
#include "rxobject.h"
#include "rxregsvc.h"
#include "rxdlinkr.h"
#include "rxditer.h"
#include "aced.h"
#include "adslib.h"
#include "dbents.h"
#include "dbregion.h"
#include "dbdict.h"
#include "dbsymtb.h"
#include "tchar.h"
#include "dbxrecrd.h"
#include "dbeval.h"
#include "acutmem.h"
#include "dbapserv.h"
#include "acestext.h"
#include "dbdynblk.h"
#include "dbobjptr.h"
#include "DocData.h"
//-----------------------------------------------------------------------------
#define szRDS _RXST("JEG")

//-----------------------------------------------------------------------------
//----- ObjectARX EntryPoint
class CUpdateBlockPropertyTableApp : public AcRxArxApp {

public:
	CUpdateBlockPropertyTableApp () : AcRxArxApp () {}

	virtual AcRx::AppRetCode On_kInitAppMsg (void *pkt) {
		// TODO: Load dependencies here

		// You *must* call On_kInitAppMsg here
		AcRx::AppRetCode retCode =AcRxArxApp::On_kInitAppMsg (pkt) ;
		
		// TODO: Add your initialization code here

		return (retCode) ;
	}

	virtual AcRx::AppRetCode On_kUnloadAppMsg (void *pkt) {
		// TODO: Add your code here

		// You *must* call On_kUnloadAppMsg here
		AcRx::AppRetCode retCode =AcRxArxApp::On_kUnloadAppMsg (pkt) ;

		// TODO: Unload dependencies here

		return (retCode) ;
	}

	virtual void RegisterServerComponents () {
	}
	
	// The ACED_ARXCOMMAND_ENTRY_AUTO macro can be applied to any static member 
	// function of the CUpdateBlockPropertyTableApp class.
	// The function should take no arguments and return nothing.
	//
	// NOTE: ACED_ARXCOMMAND_ENTRY_AUTO has overloads where you can provide resourceid and
	// have arguments to define context and command mechanism.
	
	// ACED_ARXCOMMAND_ENTRY_AUTO(classname, group, globCmd, locCmd, cmdFlags, UIContext)
	// ACED_ARXCOMMAND_ENTRYBYID_AUTO(classname, group, globCmd, locCmdId, cmdFlags, UIContext)
	// only differs that it creates a localized name using a string in the resource file
	//   locCmdId - resource ID for localized command

	// Modal Command with localized name
	// ACED_ARXCOMMAND_ENTRY_AUTO(CUpdateBlockPropertyTableApp, JEGMyGroup, MyCommand, MyCommandLocal, ACRX_CMD_MODAL)
	static void JEGMyGroupMyCommand () {
		// Put your command code here

	}

	// Modal Command with pickfirst selection
	// ACED_ARXCOMMAND_ENTRY_AUTO(CUpdateBlockPropertyTableApp, JEGMyGroup, MyPickFirst, MyPickFirstLocal, ACRX_CMD_MODAL | ACRX_CMD_USEPICKSET)
	static void JEGMyGroupMyPickFirst () {
		ads_name result ;
		int iRet =acedSSGet (ACRX_T("_I"), NULL, NULL, NULL, result) ;
		if ( iRet == RTNORM )
		{
			// There are selected entities
			// Put your command using pickfirst set code here
		}
		else
		{
			// There are no selected entities
			// Put your command code here
		}
	}

	// Application Session Command with localized name
	// ACED_ARXCOMMAND_ENTRY_AUTO(CUpdateBlockPropertyTableApp, JEGMyGroup, MySessionCmd, MySessionCmdLocal, ACRX_CMD_MODAL | ACRX_CMD_SESSION)
	static void JEGMyGroupMySessionCmd () {
		// Put your command code here
	}

	// The ACED_ADSFUNCTION_ENTRY_AUTO / ACED_ADSCOMMAND_ENTRY_AUTO macros can be applied to any static member 
	// function of the CUpdateBlockPropertyTableApp class.
	// The function may or may not take arguments and have to return RTNORM, RTERROR, RTCAN, RTFAIL, RTREJ to AutoCAD, but use
	// acedRetNil, acedRetT, acedRetVoid, acedRetInt, acedRetReal, acedRetStr, acedRetPoint, acedRetName, acedRetList, acedRetVal to return
	// a value to the Lisp interpreter.
	//
	// NOTE: ACED_ADSFUNCTION_ENTRY_AUTO / ACED_ADSCOMMAND_ENTRY_AUTO has overloads where you can provide resourceid.
	
	//- ACED_ADSFUNCTION_ENTRY_AUTO(classname, name, regFunc) - this example
	//- ACED_ADSSYMBOL_ENTRYBYID_AUTO(classname, name, nameId, regFunc) - only differs that it creates a localized name using a string in the resource file
	//- ACED_ADSCOMMAND_ENTRY_AUTO(classname, name, regFunc) - a Lisp command (prefix C:)
	//- ACED_ADSCOMMAND_ENTRYBYID_AUTO(classname, name, nameId, regFunc) - only differs that it creates a localized name using a string in the resource file

	// Lisp Function is similar to ARX Command but it creates a lisp 
	// callable function. Many return types are supported not just string
	// or integer.
	// ACED_ADSFUNCTION_ENTRY_AUTO(CUpdateBlockPropertyTableApp, MyLispFunction, false)
	static int ads_UpdateBlockPropertyTable()
	{
		struct resbuf * eb1;
		resbuf * rbArgs;
		rbArgs = acedGetArgs();
		if (rbArgs != NULL)
		{
			if (rbArgs->restype == RTSTR)
			{
#ifdef DEBUG
				acutPrintf(_T("(Blockname= \"%s\")\n"), rbArgs->resval.rstring);
#endif
				AcDbBlockTable *xBlockTable = NULL;
				AcDbDatabase *database = acdbHostApplicationServices()->workingDatabase();
				AcDbBlockTable *blockTable = NULL;
				AcDbBlockTableRecord *blockTableRecord = NULL;
				Acad::ErrorStatus es;
				es = database->getBlockTable(blockTable, AcDb::kForRead);
				if (es != Acad::eOk)
				{
					acutPrintf(L"\n; error: getting block table %s", acadErrorStatusText(es));
					acutRelRb(rbArgs);
					acedRetNil();
					return (RTNORM);
				}

				//Get the block table record for the external reference
				es = blockTable->getAt(rbArgs->resval.rstring, blockTableRecord, AcDb::kForRead);
				if (es != Acad::eOk)
				{
					//acutPrintf(L"\nError could not get BLOCK %s %s", rb->resval.rstring, acadErrorStatusText(es));
					acutPrintf(L"\n; error: No BLOCK %s defined in drawing", rbArgs->resval.rstring);
					blockTable->close();
					acutRelRb(rbArgs);
					acedRetNil();
					return (RTNORM);
				}
				//
				AcDbObjectId dictid, xrecid;
				dictid = blockTableRecord->extensionDictionary();
				//dictid = pBlkDef->extensionDictionary();
				if (dictid == AcDbObjectId::kNull)

				{
					acutPrintf(_T("\n; error: Id is NULL."));
					blockTableRecord->close();
					blockTable->close();
					acutRelRb(rbArgs);
					acedRetNil();
					return (RTNORM);
				}
#ifdef DEBUG
//				acutPrintf(_T("\nId is NOT NULL"));
#endif
				AcDbDictionary * pDict;
				acdbOpenObject(pDict, dictid, AcDb::kForRead);
#ifdef DEBUG
				acutPrintf(_T("\nDict Id=%x"), dictid);
#endif
				blockTable->close();
				blockTableRecord->close();
				AcDbEvalGraph * pXrec = NULL;
				//Get Dynamic block dictionary
				es = pDict->getAt(ACDB_ENHANCED_BLOCK, (AcDbObject * &)pXrec, AcDb::kForRead);
				if (es != Acad::eOk)
				{
					acutPrintf(_T("\n; error: Block %s isn't a dynamic block"), rbArgs->resval.rstring);
					pDict->close();
					acutRelRb(rbArgs);
					acedRetNil();
					return (RTNORM);
				}
#ifdef DEBUG
				else
				{
					acutPrintf(_T("\nGet Dynamic block dictionary: ACDB_ENHANCED_BLOCK Ok"));
				}
#endif
				pDict->close();
				//find eval graph
				AcDbObjectId tmpId = NULL;
				AcDbObjectId idEnh = NULL;
				tmpId = pXrec->objectId();
#ifdef DEBUG
				acutPrintf(_T("\nAcDbEvalGraph Id=%x"), tmpId);//ok
#endif
				AcDbEvalNodeIdArray NodeID;
				es = pXrec->getAllNodes(NodeID);
				int j = NodeID.length();
#ifdef DEBUG
				acutPrintf(_T("\nrNodelenght %i"), j);
#endif
				AcDbEvalNodeIdArray idArr;
				AcDbObject * pObj = NULL;
				ads_name name;
				bool blHasBlockPropertyTable = false;
				for (int i = 0; i < NodeID.length(); i++)
				{
					AcDbEvalNodeId idNode = NodeID.at(i);
					pXrec->getNode(idNode, AcDb::kForRead, &pObj);
					if (pObj != NULL && !pObj->isErased())
					{
						{
#ifdef DEBUG
							ACHAR str[32]; pObj->id().handle().getIntoAsciiBuffer(str);
							acutPrintf(_T("\n\tClass=%s DxfName=%s Handle=%sH"), pObj->id().objectClass()->name(), pObj->id().objectClass()->dxfName(), str, pObj->id().objectClass());
#endif
							if (_tcscmp(pObj->id().objectClass()->dxfName(), _T("BLOCKPROPERTIESTABLE")) != 0)
							{
#ifdef DEBUG
//								acutPrintf(_T("\n\tNOT FoundTC"));
#endif
							}
							else
							{
#ifdef DEBUG
//								acutPrintf(_T("\n\tFound BLOCKPROPERTIESTABLE"));
#endif
								blHasBlockPropertyTable = true;
								es = acdbGetAdsName(name, pObj->id());
							}
							pObj->close();
						}
					}
				}
				if (!blHasBlockPropertyTable)
				{
					acutPrintf(_T("\n; error: Block has no BlockPropertyTable"));
					acutRelRb(rbArgs);
					acedRetNil();
					return (RTNORM);
				}
#ifdef DEBUG
				acutPrintf(_T("\n\t=>ARG"));//----------------------------------------	
				acutPrintf(_T("\n("));
				printdxfList(rbArgs);
				acutPrintf(_T("\n)"));
#endif
				struct resbuf * rlongRowElements;
				if (rbArgs->rbnext->restype == RTLB)
				{
#ifdef DEBUG
//					acutPrintf(_T("(listRTLB=level 1)\n"));
#endif
					if (rbArgs->rbnext->rbnext->restype == RTLB)
					{
#ifdef DEBUG
//						acutPrintf(_T("(listRTLB=level 2)\n"));
#endif
						int32_t intRowLength = 0;
						int32_t intTableLength = 0;
						if ((rbArgs->rbnext->rbnext->rbnext->restype == RTSTR) || (rbArgs->rbnext->rbnext->rbnext->restype == RTSHORT)|| (rbArgs->rbnext->rbnext->rbnext->restype == RTREAL))
						{
#ifdef DEBUG
							acutPrintf(_T("(value1= \"%s\")\n"), rbArgs->rbnext->rbnext->rbnext->resval.rstring);
#endif
							struct resbuf * eb;
							resbuf * entdata;
							eb1 = acdbEntGet(name);
#ifdef DEBUG
							acutPrintf(_T("\n\t=>ORIGINAL DATA ---------------------------------------------"));//----------------------------------------	
							acutPrintf(_T("\n("));
							printdxfList(eb1);
							acutPrintf(_T(")"));
#endif
							for (entdata = eb1; entdata->restype != 340; entdata = entdata->rbnext)
							{
								if (entdata->restype == 91)
								{
									intRowLength = entdata->resval.rlong;
#ifdef DEBUG
//									acutPrintf(_T("\nStart field definitions -------------------\n\tAmount of vars = %d"), entdata->resval.rlong);
#endif
								}
#ifdef DEBUG
//								printdxf(entdata);
#endif
							}
#ifdef DEBUG
//							acutPrintf(_T("\n\tNEXT =>ROW"));//----------------------------------------
#endif
							eb= entdata;
							bool startdata92 = FALSE;
							for (entdata = eb; !startdata92; entdata = entdata->rbnext)
							{
								if (entdata->restype == 92)
								{
									startdata92 = TRUE;
									intTableLength = entdata->resval.rlong;
									rlongRowElements = entdata;
#ifdef DEBUG
//									acutPrintf(_T("\n\tAmount of rows = %d\nStart DATA ================================"), entdata->resval.rlong);
#endif
								}
#ifdef DEBUG
//								printdxf(entdata);
#endif
							}
#ifdef DEBUG
//							acutPrintf(_T("\n\tNEXT1 =>DATA"));//----------------------------------------
//							printdxf(entdata);
#endif
							resbuf * entType = entdata;
#ifdef DEBUG
//							acutPrintf(_T("\n\tNEXT2 =>DATA"));//----------------------------------------	
#endif
							struct resbuf * listTbl;
							struct resbuf * entdataPost;
							listTbl = rbArgs->rbnext->rbnext;
#ifdef DEBUG
//							acutPrintf(_T("\n\tNEXT2 =>LIST"));//----------------------------------------
//							printdxfList(listTbl);
							acutPrintf(_T("\nSTART UPDATE LOOP"));//----------------------------------------	
#endif
							int i = -1;
							while ((entdata->restype == 90) && (listTbl!=NULL) &&(listTbl->restype== RTLB))
							{
								entdata = entdata->rbnext;
#ifdef DEBUG
								printdxf(entdata);
#endif
								i++;
								listTbl = listTbl->rbnext;
#ifdef DEBUG
//								printdxf(listTbl);
//								acutPrintf(_T("\n\tROW =>DATA=%d"),i);//----------------------------------------
#endif
								int32_t intRowIndex;
								for (intRowIndex = 1; intRowIndex <= intRowLength; intRowIndex++)
								{
#ifdef DEBUG
									acutPrintf(_T("\n"));
									printdxf(entdata);
									printdxf(entdata->rbnext);
									acutPrintf(_T("\n\tlist:"));
									printdxf(listTbl);
#endif
									if ((entdata->restype = 170) && (entdata->resval.rlong == 1) &&
										(entdata->rbnext->restype = 300))
									{//(170 1)(300 "str")
#ifdef DEBUG						
//										acutPrintf(_T("\n\tstring old value: \"%s\""), entdata->rbnext->resval.rstring);//type 300;
#endif
										if (listTbl->restype == RTSTR)
										{
#ifdef DEBUG
//											acutPrintf(_T(" new value:\"%s\""), listTbl->resval.rstring);
#endif
											acutUpdString(listTbl->resval.rstring, entdata->rbnext->resval.rstring);
										}
										else
										{
											acutPrintf(_T("\n; error: list type not a string"));
											printdxf(listTbl);
											acutRelRb(rbArgs);
											acutRelRb(eb1);
											acedRetNil();
											return (RTNORM);
										}

									}
									else if ((entdata->restype = 170) && (entdata->resval.rlong == 40) &&
										(entdata->rbnext->restype = 140))
									{//(170 40)(140 0.1)
#ifdef DEBUG                           
//										acutPrintf(_T("\n\treal old value %d"), entdata->rbnext->resval.rreal);//type 140; 
#endif
										if (listTbl->restype == RTSHORT)// RTSHORT = 5003
										{
#ifdef DEBUG
//											acutPrintf(_T(" new value int %d"), listTbl->resval.rint);
#endif
											entdata->rbnext->resval.rreal = (ads_real)listTbl->resval.rint;
										}
										else if (listTbl->restype == RTLONG)//RTLONG =   5010  Long integer
										{
#ifdef DEBUG
											acutPrintf(_T(" new value int %d"), listTbl->resval.rint);
#endif
											entdata->rbnext->resval.rreal = (ads_real)listTbl->resval.rlong;
										}
										else if (listTbl->restype == RTREAL)//5001 /*Real number
										{
#ifdef DEBUG
//											acutPrintf(_T(" new value rl %d"), listTbl->resval.rreal);
#endif
											entdata->rbnext->resval.rreal = listTbl->resval.rreal;
										}
										else
										{
											acutPrintf(_T("\n; error: list type not a real/shotInt/Longint"));
											printdxf(listTbl);
											acutRelRb(eb1);
											acutRelRb(rbArgs);
											acedRetNil();
											return (RTNORM);
										}
									}
									else if ((entdata->restype = 170) && (entdata->resval.rint == -9999))
									{//(170 . -9999) existing empty value
#ifdef DEBUG
//										acutPrintf(_T("\n\tno rooom to store %s convering 170 group an add 300 group"), listTbl->resval.rstring);
#endif
										entdata->resval.rint = 1;
										resbuf * temp = entdata->rbnext;//object after (170 -9999)
										if ((entdata->rbnext = acutBuildList(300, listTbl->resval.rstring, 0)) == NULL)
										{
											acutPrintf(_T("\n; error: Memory Error"));
											acutRelRb(eb1);
											acutRelRb(rbArgs);
											acedRetNil();
											return -1;
										}
										entdata->rbnext->rbnext = temp;
									}
									else
									{
										acutPrintf(_T("\n; error: unknow type: (%d "), entdata->restype);
										acutPrintf(_T( "%d)"), entdata->resval.rint);
										acutPrintf(_T("(%d ?)"), entdata->rbnext->restype);
										acutRelRb(eb1);
										acutRelRb(rbArgs);
										acedRetNil();
										return (RTNORM);
									}
									listTbl = listTbl->rbnext;
									entdataPost = entdata->rbnext;
									entdata = entdata->rbnext->rbnext;
#ifdef DEBUG
//									printdxf(entdata);
#endif
								}
#ifdef DEBUG
//								acutPrintf(_T("\nEND ROW:%d"), intRowIndex);
//								printdxf(entdata);
#endif
								listTbl = listTbl->rbnext;
#ifdef DEBUG
//								printdxf(listTbl);
#endif
							}
							//extend list if to short
							if ((listTbl != NULL) && (listTbl->restype == RTLB))
							{
#ifdef DEBUG
								acutPrintf(_T("\nSTARTLOOP EXTEND DATA"));//----------------------------------------	
#endif
								while ((listTbl != NULL) && (listTbl->restype == RTLB))
								{
									//entdata = object 93
									resbuf * temp = entdata->rbnext;//object after 93
									if ((entdata->rbnext = acutBuildList(entdata->restype, entdata->resval.rint, 0)) == NULL)
									{
										acutPrintf(_T("\n; error: Memory Error"));
										acutRelRb(eb1);
										acutRelRb(rbArgs);
										acedRetNil();
										return -1;
									}
									//entdata = object 90
									//temp = object after 93
									entdata->rbnext->rbnext = temp;
									entdata->restype = 90;
									entdata->resval.rint = i;
									temp = entdata->rbnext;//temp = object 93
									resbuf * entDataExt = entType->rbnext;
#ifdef DEBUG
									printdxf(entDataExt);
#endif
									i++;
									listTbl = listTbl->rbnext;
#ifdef DEBUG
									printdxf(listTbl);
									acutPrintf(_T("\n\tROW =>DATA=%d"), i);//----------------------------------------
#endif
									int32_t intRowIndex;
									for (intRowIndex = 1; intRowIndex <= intRowLength; intRowIndex++)
									{
#ifdef DEBUG
										acutPrintf(_T("\n"));
										printdxf(entDataExt);
										printdxf(entDataExt->rbnext);

										acutPrintf(_T("\n\tlist:"));
										printdxf(listTbl);
#endif
										if ((entDataExt->restype = 170) && (entDataExt->resval.rlong == 1) &&
											(entDataExt->rbnext->restype = 300))
										{
#ifdef DEBUG
											acutPrintf(_T("\n\tstring old value: NON"));//type 300;
#endif
											if (listTbl->restype == RTSTR)
											{
#ifdef DEBUG
												acutPrintf(_T(" new value:%s"), listTbl->resval.rstring);
#endif
												if ((entdata->rbnext = acutBuildList(170, 1, 300, listTbl->resval.rstring, 0)) == NULL)
												{
													acutPrintf(_T("\n; error: Memory Error"));
													acutRelRb(eb1);
													acutRelRb(rbArgs);
													acedRetNil();
													return -1;
												}
												entdata->rbnext->rbnext->rbnext = temp;
											}
											else
											{
												acutPrintf(_T("\n; error: list type not a string"));
												printdxf(listTbl);
												acutRelRb(eb1);
												acutRelRb(rbArgs);
												acedRetNil();
												return (RTNORM);
											}

										}
										else if ((entDataExt->restype = 170) && (entDataExt->resval.rlong == 40) &&
											(entDataExt->rbnext->restype = 140))
										{
#ifdef DEBUG
											acutPrintf(_T("\n\treal old value NON"));//type 140
#endif
											if (listTbl->restype == RTSHORT)
											{
#ifdef DEBUG
												acutPrintf(_T(" new value int %d"), listTbl->resval.rint);
#endif
												if ((entdata->rbnext = acutBuildList(170, 40, 140, (ads_real)listTbl->resval.rint, 0)) == NULL)
												{
													acutPrintf(_T("\n; error: Memory Error"));
													acutRelRb(eb1);
													acutRelRb(rbArgs);
													acedRetNil();
													return -1;
												}
												entdata->rbnext->rbnext->rbnext = temp;						
											}
											else if (listTbl->restype == RTLONG)
											{
#ifdef DEBUG
												acutPrintf(_T(" new value long int %d"), (ads_real)listTbl->resval.rlong);
#endif
												if ((entdata->rbnext = acutBuildList(170, 40, 140, (ads_real)listTbl->resval.rlong, 0)) == NULL)
												{
													acutPrintf(_T("\n; error: Memory Error"));
													acutRelRb(eb1);
													acutRelRb(rbArgs);
													acedRetNil();
													return -1;
												}
												entdata->rbnext->rbnext->rbnext = temp;
											}
											else if (listTbl->restype == RTREAL)
											{
#ifdef DEBUG
												acutPrintf(_T(" new value rl %d"), listTbl->resval.rreal);
#endif
												if ((entdata->rbnext = acutBuildList(170, 40, 140, listTbl->resval.rreal, 0)) == NULL)
												{
													acutPrintf(_T("\n; error: Memory Error"));
													acutRelRb(eb1);
													acutRelRb(rbArgs);
													acedRetNil();
													return -1;
												}
												entdata->rbnext->rbnext->rbnext = temp;
											}
											else
											{
												acutPrintf(_T("\n; error: list type not a real/shotInt/LongInt"));
												printdxf(listTbl);
												acutRelRb(eb1);
												acutRelRb(rbArgs);
												acedRetNil();
												return (RTNORM);
											}
										}
										else
										{
											acutPrintf(_T("\n; error: unknow type"));
											acutRelRb(eb1);
											acutRelRb(rbArgs);
											acedRetNil();
											return (RTNORM);
										}
										listTbl = listTbl->rbnext;
										entdata = entdata->rbnext->rbnext;
										entDataExt = entDataExt->rbnext->rbnext;
#ifdef DEBUG
										printdxf(entdata);
#endif
										
									}
#ifdef DEBUG
									acutPrintf(_T("\nEND ROW:"));
#endif
									entdata = entdata->rbnext;
									listTbl = listTbl->rbnext;
								}

							}
							//shorten list if to long
							if (i+1 < rlongRowElements->resval.rlong)
							{
#ifdef DEBUG
								acutPrintf(_T("\nLIST TO LONG:"));
								printdxf(entdata);
								printdxf(entdataPost);
#endif
								resbuf * tempNew = entdataPost;//last element of new list			
								resbuf * tempOld = entdataPost;//last element of old list
								resbuf * tempOldstart = tempOld->rbnext;//first element of old list
								while (entdata->restype != 93)
								{
									tempOld = entdata;
									entdata = entdata->rbnext;
								}
#ifdef DEBUG
								acutPrintf(_T("\nTAIL:"));
								printdxf(entdata);	
#endif							
								tempNew->rbnext = entdata;
#ifdef DEBUG
								acutPrintf(_T("\nRelease old LIST Items:"));
								printdxfList(tempOldstart);
								acutPrintf(_T("\nRelease old LIST Items2:"));
								printdxfList(tempOld);//to be set 0;
#endif
								tempOld->rbnext = NULL;
#ifdef DEBUG
								acutPrintf(_T("\nRelease LIST Items2:"));
								printdxfList(tempOldstart);//to be set 0;
#endif
								acutRelRb(tempOldstart);
							}
							pObj->close();
							rlongRowElements->resval.rlong = i + 1;//set length of table
#ifdef DEBUG
							acutPrintf(_T("\n290: boolean must match tickbox"));
							printdxf(entdata->rbnext);
#endif

							//check properties must match tickbox, to avoid problems with existing items
							if ((entdata->rbnext->resval.rint == 1)||(entdata->rbnext->restype != 290))
							{
								printdxf(entdata->rbnext);
								acutPrintf(_T("\n; error: Block properties must match a row tickbox is switched on"));
								acutRelRb(eb1);
								acutRelRb(rbArgs);
								acedRetNil();
								return (RTNORM);
							}
#ifdef DEBUG
							printdxfList(entdata->rbnext->rbnext);
#endif

							//check extra parameters input
							if (listTbl->rbnext != NULL)
							{
								acutPrintf(_T("\n; error: too many arguments"));
#ifdef DEBUG
								acutPrintf(_T("\nExtra parameters:"));
								printdxfList(listTbl);
#endif
								acutRelRb(eb1);
								acutRelRb(rbArgs);
								acedRetNil();
								return (RTNORM);
							}
#ifdef DEBUG
							acutPrintf(_T("\n\t=>RESULT before EntMod IS:---------------------------------------------------"));
							acutPrintf(_T("\n("));
							printdxfList(eb1);
							acutPrintf(_T(")"));
#endif

							int es = acdbEntMod(eb1);
#ifdef DEBUG
//							acutPrintf(_T("\n\tRESULT after EntMod IS:"));
//							acutPrintf(_T("\n("));
//							printdxfList(eb1);
//							acutPrintf(_T("\n)"));
#endif
							
							if (RTNORM == es)
							{
								acdbEntUpd(name);
								//acDocManager->sendStringToExecute(acDocManager->curDocument(), _T("\x1B\x1B\x1B-BEDIT "));
								//acDocManager->sendStringToExecute(acDocManager->curDocument(), rbArgs->resval.rstring);
								//acDocManager->sendStringToExecute(acDocManager->curDocument(), _T("\nBCLOSE "));

							}
							else
							{
								acutRelRb(eb1);
								acutRelRb(rbArgs);
								acedRetNil();
								return (RTNORM);
							}
							//acutRelRb(entdata);
						}
						else
						{
							acutPrintf(_T("\n; error: incorrecy list level 1= \"%d\")"), rbArgs->rbnext->rbnext->rbnext->restype);
							acutRelRb(rbArgs);
							acedRetNil();
							return (RTNORM);
						}
					}
					else
					{
						acutPrintf(_T("\n; error: incorrecy list type level 0= \"%d\")"), rbArgs->rbnext->rbnext->restype);
						acutRelRb(rbArgs);
						acedRetNil();
						return (RTNORM);
					}
				}
				else
				{
					acutPrintf(_T("\n; error: List has no records = \"%d\")"), rbArgs->rbnext->restype);
					acutRelRb(rbArgs);
					acedRetNil();
					return (RTNORM);
				}
			}
			else
			{
				acutPrintf(_T("\n; error: Argument 2 isn't a list = \"%d\")"), rbArgs->restype);
				acutRelRb(rbArgs);
				acedRetNil();
				return (RTNORM);
			}
		}
	    acedRetList(eb1);
		acutRelRb(rbArgs);
		acutRelRb(eb1);
		return (RTNORM);
	}
} ;

//-----------------------------------------------------------------------------
IMPLEMENT_ARX_ENTRYPOINT(CUpdateBlockPropertyTableApp)

ACED_ARXCOMMAND_ENTRY_AUTO(CUpdateBlockPropertyTableApp, JEGMyGroup, MyCommand, MyCommandLocal, ACRX_CMD_MODAL, NULL)
ACED_ARXCOMMAND_ENTRY_AUTO(CUpdateBlockPropertyTableApp, JEGMyGroup, MyPickFirst, MyPickFirstLocal, ACRX_CMD_MODAL | ACRX_CMD_USEPICKSET, NULL)
ACED_ARXCOMMAND_ENTRY_AUTO(CUpdateBlockPropertyTableApp, JEGMyGroup, MySessionCmd, MySessionCmdLocal, ACRX_CMD_MODAL | ACRX_CMD_SESSION, NULL)
//ACED_ADSSYMBOL_ENTRY_AUTO(CUpdateBlockPropertyTableApp, MyLispFunction, false)
ACED_ADSSYMBOL_ENTRY_AUTO(CUpdateBlockPropertyTableApp, UpdateBlockPropertyTable, false)

