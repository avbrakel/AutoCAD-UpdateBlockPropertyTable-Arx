# AutoCAD-UpdateBlockPropertyTable-Arx
Automating the update of a dynamic blocks “Property table” of the block in an existing drawing is not possible from LISP. As dxf groups 1010 and 1071 can’t be saved.
 
To overcome this flaw, i did create an ARX that can be loaded in AutoCAD that expose an interface (UpdateBlockPropertyTable <block name> <list with table values>) for lisp.
I build a utility which works in ac2017, ac2020, ac2022.
 
