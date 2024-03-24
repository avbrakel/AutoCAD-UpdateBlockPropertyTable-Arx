//
//////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2016 Autodesk, Inc.  All rights reserved.
//
//  Use of this software is subject to the terms of the Autodesk license 
//  agreement provided at the time of installation or download, or which 
//  otherwise accompanies this software in either electronic or hard copy form.   
//
//////////////////////////////////////////////////////////////////////////////
//
// Description:
//
// Test App for ARx Usage of Protocol Extension in
// conjunction with the AcDb library.
// 
// Defines the AsdkEntTemperature "property" extension
// protocol class for AcDbEntity, a default implementation,
// and specific implementations for Circles and Regions.

#if defined(_DEBUG) && !defined(AC_FULL_DEBUG)
#error _DEBUG should not be defined except in internal Adesk debug builds
#endif

#include "stdafx.h"
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
//#include "dbobjptr.h"
//#include "DocData.h"


int printdxf(struct resbuf *eb)
{
	/*if (eb == NULL) {
		acutPrintf(_T("(0 . NULL)"));
	}
	else 
	{ 
		acutPrintf(_T("(%d . =)"), eb->restype); 
	}*/

	int rt;
	if (eb == NULL)
		return RTNONE;
	if ((eb->restype >= 0) && (eb->restype <= 9) ||	//STRING	//   0..9
		(eb->restype == 100) ||									// 100
		(eb->restype == 102) ||									// 102
		(eb->restype >= 300) && (eb->restype <= 309) ||			// 300.. 309
		(eb->restype >= 1000) && (eb->restype <= 1009)||		//1000..1009
		(eb->restype == 5005))									//5005
		rt = RTSTR;
	else if ((eb->restype >= 10) && (eb->restype <= 19)||
		(eb->restype == 1010))
		rt = RT3DPOINT;
	else if ((eb->restype >= 38) && (eb->restype <= 59)||
		(eb->restype >= 140) && (eb->restype <= 149)||
		(eb->restype == 5001))//RTREAL							//5001
		rt = RTREAL;
	else if ((eb->restype >= 60) && (eb->restype <= 79) ||
		(eb->restype >= 170) && (eb->restype <= 179)||
		(eb->restype >= 280) && (eb->restype <= 289)||			// 280..289
		(eb->restype >= 1060) && (eb->restype <= 1070)||
		(eb->restype == 5003))//RTSHORT
		rt = RTSHORT;
	else if ((eb->restype >= 90) && (eb->restype <= 99)||
		(eb->restype == 1071))
		rt = RTLONG;//32 - bit integer value
	else if ((eb->restype >= 210) && (eb->restype <= 239))
		rt = RT3DPOINT;
	else if ((eb->restype >= 290) && (eb->restype <= 299))		// 290..299
		rt = RTSHORT;//BOOLEAN
	else if ((eb->restype >= 330) && (eb->restype <= 369))
		rt = RTENAME;
	else if (eb->restype < 0)
		// Entity name (or other sentinel)
		rt = eb->restype;
	else if (eb->restype == RTLB)
		rt = eb->restype;
	else if (eb->restype == RTLE)
		rt = eb->restype;
	else
		rt = RTNONE;
	switch (rt) {
	case RTLONG:
		acutPrintf(_T("(%d . %d)\n"), eb->restype,eb->resval.rlong);
		break;
	case RTSHORT:
		acutPrintf(_T("(%d . %d)\n"), eb->restype,
			eb->resval.rint);
		break;
	case RTREAL:
		acutPrintf(_T("(%d . %0.3f)\n"), eb->restype,			eb->resval.rreal);
		break;
	case RTSTR:
		acutPrintf(_T("(%d . \"%s\")\n"), eb->restype,
			eb->resval.rstring);
		break;
	case RT3DPOINT:
		acutPrintf(_T("(%d . %0.3f %0.3f %0.3f)\n"),
			eb->restype,
			eb->resval.rpoint[X], eb->resval.rpoint[Y],
			eb->resval.rpoint[Z]);
		break;
	case RTLB:
		acutPrintf(_T("(%d . list begin)"),eb->restype);
		break;
	case  RTLE:
		acutPrintf(_T("(%d . list end)"), eb->restype);
		break;
	case RTNONE:
		acutPrintf(_T("(%d . Unknown type)\n"), eb->restype);
		break;
	case -1:
	case -2:
	case RTENAME:
		// First block entity
		acutPrintf(_T("(%d . <Entity name: %8lx>)\n"),
			eb->restype, eb->resval.rlname[0]);
	}
	return eb->restype;
}

int printdxfList(struct resbuf *eb)
{ 
	if (eb != NULL)
	{
		struct resbuf *entdata;
		for (entdata = eb; entdata->rbnext != NULL; entdata = entdata->rbnext)
		{

			//	/*if (entdata->restype == 92)
			//	{
			//		startdata92 = TRUE;
			//		acutPrintf(_T("\n\t92"));
			//	}*/
			//	if ((entdata->restype == 300) && startdata92)
			//	{
			//		acutPrintf(_T("\n\t300 old value"));
			//		printdxf(entdata);
			//		acutUpdString(rb->rbnext->rbnext->rbnext->resval.rstring, entdata->resval.rstring);
			//		startdata92 = FALSE;
			//		//startdata302 = FALSE;
			//		//startdata340 = FALSE;
			//	}
			printdxf(entdata);
		}
		return entdata->restype;
	}
	return -1;
}


