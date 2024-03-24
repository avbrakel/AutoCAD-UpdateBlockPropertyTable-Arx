; © 2008-2011, Andrey Lazebny, Moscow (Russian Federation)
; v1.5, 23.11.11
; v1.4, 11.02.10
; v1.3, 24.10.09
; © 2008-2011,	Translation by Nikolay Poleshchuk, Saint Petersburg (Russian Federation)
; 2015-10,	DBdJ: Made functions for every head function, made function tree and wrote a little manual.

;Updated and made functions by DBdJ 10-2015
; Function Tree		Other functions		Commandline name
;Sub	01 used	by	02, 03, 05, 07 to 13
;Head	02	--->	01			C:VSPadd	Function for adding a new Visibility Set parameter
;Head	03	--->	01, 04, 05		C:VSPSet	Function for setting selected Visibility Set as current
;Sub 	04 used by	03 and 13
;Sub 	05 uses		01
;Sub 	06 used by	07, 08
;Head	07 	--->	01, 06			C:VSPDelsel	Function for removing selected elements from the current Visibility Set
;Head	08 	--->	01, 06			C:VSPDelAll	Function for removing all the elements from the current Visibility Set
;Head	09 	--->	01			C:VSPAddsel	Function for adding selected elements to current Visibility Set
;Head	10 	--->	01			C:VSPclean	Function for complete cleaning current state from all the elements, dynamic properties and states
;Head	11 	--->	01, 12			C:VSPallProps	Function for setting visibility of all the dynamic properties and grips in all the states of all Visibility Sets
;Sub 	12 uses		01
;Head 	13 	--->	01, 04, 05		C:VSPSel2VS	Function for batch setting visibility of selected entities in several chosen states of the current visibility set
;Sub 	14 used by	03, 13


(prompt "\n
Visibility States commando's of Visibility Add version 1.6
Commandname   Explanation
- - - - - -   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
VSPadd        Add Visibility Parameter
VSPSet        Set a Visibility Parameter
VSPDelsel     Remove Selected elements from current Visibility Set
VSPDelAll     Remove All elements from current Visibility Set
VSPAddsel     Add Selected elements from current Visibility Set
VSPclean      Clean current Visibility Set: no elements, dynamic properties and states
VSPallProps   All Dynamic Properties on in all Visibility Sets
VSPSel2VS     Using a form to Set/Add (in)visibility for selected objects in several visibility States

It seems only VSPadd and VSPSet are working under AutoCAD 2016. VSPSel2VS gives an internal error.
")(princ)

(prompt "
Visibility States Manual of Visibility Add version 1.6, tested and working with AutoCAD 2016.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
00:           Visibility States Parameter is shortened by VSP, Visibility State by VS.
01:           save(as) the drawing often during the steps, especially when filling a table!
02:           Copy the desired block to a new drawing and save it to speed up the editing and save process.
03:           Edit the desired block with the Block Editor.
04:           If not present: add the VSP of the Dynamic Block Panel.
05:           Use the general VSP for the other dynamic block actions and correspondig entities, all turned on.
")(princ)
(prompt "
06:           Use Function VSPadd to add a VSP.
07:           Rename the VSP.
08:           Use Function VSPSet to set the VSP.
              Look at the text left of the Model-text at the right bottom, here you can see the current VSP.
09:           Select the added Lookups of other VSPs and let them show in the all VS.
              (Unless you don't want them to see in the current state?)
10:           Add objects.
11:           Make UNIQUE (! !) VS with short names for the just added objects, 
              like A00 to A20 for the first Lookup: Opt A (A00 is the begin state).
12:           Make a Lookup like Opt_A, filled with this values of the VS of the VSP on the right side (A00 to A20).
13:           On the left side of this Lookup the desired user values.
14:           Repeat steps 06 to 13 for every Lookup where you want to use the VSPadd command,
              replace Opt_A and A00 to A20 by Opt_B and B00 to B20 (etc).
")(princ)
(prompt "
15:           Copy a standard Lookup and change the name, click properties and add Lookups:
              (one for the VS-combo table and one for each Lookup base on the added VSP, except the standard).
16:           Place the Lookup table. When filling, use short names, because it has limited memory.
17:           Fill the VS-combo table like this:
              VSP_A, VSP_B, VSP_C on the left side with the right values. On the right side:
              range AAA, AAB, AAC, BAA, BAB. etc.
18:           Fill the other tables with the right VSP (double values!) with:
              A00, A00, A00, A01, A01 etc and on the left side the range AAA, AAB, AAC, BAA, BAB. etc.
19:           Close the table, ignore errors of double values.

20:           Save the block and return to Modelspace/Paperspace.
21:           The lisp is still buggy: when going back to another VSP and do actions with the VS,
              you need to cut and paste the objects of another VSP and renew the VS?
22:           When changing a value in a lookup table, you have to reclick the same value in the other lookups based on the extra VSPs.
23:           Purge and save the drawing often.
")(princ)


(vl-load-com)

;Load these functions only in the block editor space!

(if (= (getvar "BLOCKEDITOR") 0) (alert "The programs work only in the block editor space!"); (exit)))
(progn 
;============================================================================================================================================================

; *** 01 ***
;Utility function for getting ACAD_EVALUATION_GRAPH dictionary from the block editor space
;List of dotted pairs and DXF codes is being written to EVAL_GRAPH variable
; 11.02.10
(defun eval_graf_output (/ BLK_RECORD DICTIONARY point) ;Used by 02, 03, 05, 07 to 13
;Creating temporary "point" element
(vl-cmdf "_.point" "0,0,0")
(setq point_block (entlast))
(setq BLK_RECORD (cdr (assoc 330 (entget point_block))))
;Getting pointer to DICTIONARY dictionary
(setq DICTIONARY (assoc 360 (entget BLK_RECORD)))
;Getting pointer to ACAD_EVALUATION_GRAPH dictionary
(mapcar '(lambda (x) (if (and (= (car x) 360) (= (cdr (assoc 0 (entget (cdr x)))) "ACAD_EVALUATION_GRAPH"))
              (setq EVA-U-TION_GRAPH x))) 
(entget (cdr DICTIONARY)))
;Getting ACAD_EVALUATION_GRAPH dictionary
(setq EVAL_GRAPH (entget (cdr EVA-U-TION_GRAPH)))
;Removing temporary "point" element
(vla-Delete (vlax-ename->vla-object point_block))
(setq EVAL_GRAPH EVAL_GRAPH)
);end of eval_graf_output function

;===========================================================================================================================================================

; *** 02 ***	 ; Headfunction
;Function for adding a new Visibility Set parameter
; v1.5 23.11.11
(defun C:VSPadd (/ point_insert BLC-VIS-PAR name_visibility del-1 BLC-VIS-PAR-1 del5 del1010 del1071 subst301 st-360 neo-91 visibility-1 zam95 zapis zam96 zam97 eval-1 st-12 eval-12 p1-12-1 eval-2 final-1)
;Preliminary definition of place for Visibility Set parameter icon
(setq point_insert (getpoint "Select point for placing Visibility Set: "))
(eval_graf_output) ;Getting ACAD_EVALUATION_GRAPH 'Call (eval_graf_output)

;Searching for all Visibility Sets
(setq BLC-VIS-PAR-7 nil)
(mapcar '(lambda (x) 
  (if (and (= (car x) 360) 
               (= (cdr (assoc 0 (entget (cdr x)))) "BLOCKVISIBILITYPARAMETER"))
      (setq BLC-VIS-PAR-7 (cons (cdr x) BLC-VIS-PAR-7))
)) EVAL_GRAPH)
(setq BLC-VIS-PAR-7 (vl-remove nil BLC-VIS-PAR-7))
(setq BLC-VIS-PAR-8 (mapcar 'vlax-ename->vla-object BLC-VIS-PAR-7))
;Deleting all
(mapcar 'vla-Delete BLC-VIS-PAR-8)
;Save block to clean the ACAD_EVALUATION_GRAPH dictionary from grips of all the Visibility sets
(command "_.BSAVE")
;Creating a "fantom" visibility set
(progn 
    (setq name_visibility "Fantom")
    (command "_.BParameter" "_V" "_L" name_visibility point_insert "")
)
(command "_.BSAVE")
;Getting ACAD_EVALUATION_GRAPH dictionary
(eval_graf_output)
;Search and save pointer to our visibilty set that is yet not fantom
(setq BLC-VIS-PAR-9 nil)
(mapcar '(lambda (x) 
  (if (and (= (car x) 360) 
               (= (cdr (assoc 0 (entget (cdr x)))) "BLOCKVISIBILITYPARAMETER"))
      (setq BLC-VIS-PAR-9 (cons (cdr x) BLC-VIS-PAR-9))
)) EVAL_GRAPH)
(setq BLC-VIS-PAR-9 (vl-remove nil BLC-VIS-PAR-9))
;Undoing to kill all the visibility sets
(command "_.undo" 5 )
(command "_.BSAVE")

;Getting ACAD_EVALUATION_GRAPH dictionary
(eval_graf_output)
;Counting number of records with code 91. Though we are counting codes 360 we are getting number of 91th ones.
;Result is by 1 greater than in reality
(setq st-360 0)
(mapcar '(lambda (x) (if (= (car x) 360) (setq st-360 (1+ st-360))))  EVAL_GRAPH)
;Creating dotted pair 91 for a new "clumsy" Visibility Set
(setq neo-91 (cons 91 st-360))

;!! Changing variable
(setq visibility-1 (car BLC-VIS-PAR-9))
;Creating dotted pair 95 for a new "clumsy" Visibility Set
(setq zam95 (cons 95 (1+ (cdr (assoc 96 EVAL_GRAPH)))))
;Creating record with "fantom" visibility set
(setq zapis (append (list neo-91) '((93 . 32)) (list zam95) (list (cons 360 visibility-1)) '((92 . -1)) '((92 . -1)) '((92 . -1)) '((92 . -1))))
;Creating new dotted pairs 96 and 97 (taking into account "family growth")
(setq zam96 (cons 96 (1+ (cdr (assoc 96 EVAL_GRAPH)))))
(setq zam97 (cons 97 (1+ (cdr (assoc 97 EVAL_GRAPH)))))
;Replacing these pairs in ACAD_EVALUATION_GRAPH dictionary
(setq EVAL_GRAPH (subst zam96 (assoc 96 EVAL_GRAPH) EVAL_GRAPH))
(setq EVAL_GRAPH (subst zam97 (assoc 97 EVAL_GRAPH) EVAL_GRAPH))
;Getting the rest of ACAD_EVALUATION_GRAPH beginning from the last dotted pair 91,
; that is from the beginning of the last record with code 91
(setq eval-1 (member (cons 91 (1- st-360)) EVAL_GRAPH))
;Removing the last record with code 91 from the rest of ACAD_EVALUATION_GRAPH and at the same time saving the last record in eval-12 variable
(setq st-12 0)
(setq eval-12 nil)
(while (< st-12 8) (setq eval-12 (append eval-12 (list (car eval-1)))) (setq eval-1 (cdr eval-1)) (setq st-12 (1+ st-12)))
;Extracting pair 360 from the last record with code 91
(setq p1-12-1 (assoc 360 eval-12))
;Getting the beginning of ACAD_EVALUATION_GRAPH dictionary but without last record
(setq eval-2 (reverse (cdr (cdr (cdr (cdr (member p1-12-1 (reverse EVAL_GRAPH))))))))
;Returning the last record to the dictionary begin as well as record with "clumsy" Visibility Set and the rest of the dictionary
(setq final-1 (append eval-2 eval-12 zapis eval-1))
;Modifying dictionary
(entmod final-1)
;The key point. If do not save new Visibility set then it cannot be set but if save then all the dynamic parameters are being removed. So if we save and undo
;AutoCAD loses orientation and allows to set new visibility set.
(command "_.BSAVE")
(command "_.undo" 1 )

;Creating new name for the Visibility Set to be inserted
(setq name_visibility (strcat "Visibility:" (substr (vl-princ-to-string (cdr (assoc -1 EVAL_GRAPH))) 14 9)))
;Inserting new Visibility Set
(command "_.BParameter" "_V" "_L" name_visibility point_insert "")

;Finding "clumsy" Visibility Set

(eval_graf_output)
(setq BLC-VIS-PAR nil)
(mapcar '(lambda (x) 
  (if (and (= (car x) 360) 
           (null (entget (cdr x)))
          ;(= (cdr (assoc 301 (entget (cdr x)))) "Clumsy")
      )
      (setq BLC-VIS-PAR (cons x BLC-VIS-PAR)))) EVAL_GRAPH)
(setq BLC-VIS-PAR (car BLC-VIS-PAR))
;Counting number of records with code 91
;While counting codes 360 we are counting 91ths. The result is 1 greater than in reality
(setq res_spisok nil)
(mapcar '(lambda (x) (if (= (car x) 360) (setq res_spisok (append res_spisok (list x))))) EVAL_GRAPH)
(setq num_posl_block (1- (length res_spisok)))

;Finding position of "clumsy" Visibility Set in eval_graph list and getting dotted pair 91 in its record
(setq krivoy-91 (nth (- (vl-position BLC-VIS-PAR EVAL_GRAPH) 3) EVAL_GRAPH))
;Trasferring record with "clumsy" Visibility Set to the very end of the list
(while (< (cdr krivoy-91) num_posl_block)
;Moving record one step down
(setq num4_prop_block (cons 91 (1+ (cdr krivoy-91))))
(setq EVAL_GRAPH (subst '(1) num4_prop_block EVAL_GRAPH))
(setq EVAL_GRAPH (subst '(2) krivoy-91 EVAL_GRAPH))
(setq EVAL_GRAPH (subst num4_prop_block '(2) EVAL_GRAPH))
(setq EVAL_GRAPH (subst krivoy-91 '(1) EVAL_GRAPH))
;Modifying ACAD_EVALUATION_GRAPH dictionary
(entmod EVAL_GRAPH)
;Getting ACAD_EVALUATION_GRAPH dictionary again
(eval_graf_output)
;Calculating "clumsy" Visibility Set again
(mapcar '(lambda (x) 
  (if (and (= (car x) 360) 
           (= (cdr (assoc 0 (entget (cdr x)))) "BLOCKVISIBILITYPARAMETER")
           (= (cdr (assoc 301 (entget (cdr x)))) "Clumsy"))
      (setq BLC-VIS-PAR x))) EVAL_GRAPH)
;Finding position of "clumsy" Visibility Set in eval_graph list
(setq krivoy-91 (nth (- (vl-position BLC-VIS-PAR EVAL_GRAPH) 3) EVAL_GRAPH))
; And so on in the loop till record with "clumsy" Visibility Set comes to the very bottom
);end while

;Again getting ACAD_EVALUATION_GRAPH dictionary
(eval_graf_output)
;Getting the rest of it plus the last record
(setq ost_eval+8 (member krivoy-91 EVAL_GRAPH))
;Taking pair 360 with "clumsy" Visibility Set from the rest
(setq ost-360 (assoc 360 ost_eval+8))
;Cleaning the rest of ACAD_EVALUATION_GRAPH from the last record
(setq ost-eval (cddddr (cddddr ost_eval+8)))
;Getting ACAD_EVALUATION_GRAPH begin without last record with code 91 (i.e. with "clumsy" Visibility Set)
(setq nachalo (reverse (cddddr (member ost-360 (reverse EVAL_GRAPH)))))
;Joining begin with the end of ACAD_EVALUATION_GRAPH dictionary
(setq EVAL_GRAPH (append nachalo ost-eval))
;And modifying it
(entmod EVAL_GRAPH)
;Saving block
(vla-SendCommand (vla-get-ActiveDocument (vlax-get-acad-object)) "_.BSAVE ")
);end defun Visibility_add

;==============================================================================================================

; *** 03 ***  ; Headfunction
;Function for setting selected Visibility Set as current

(defun C:VSPSet (/ object-load listprop current-91 num4_prop_block BLC-VIS-PAR tecuchiy)
;Selecting required Visibility Set
(setq object-load (car (entsel "Select required Visibility Set: ")))
;Checking type of the selected object. If it is Visibility Set then we save its name,
;if no then we scold and exit
(if (= (vla-get-ObjectName (vlax-ename->vla-object object-load)) "AcDbBlockVisibilityParameterEntity") 
(setq listprop (vlax-get-property (vlax-ename->vla-object object-load) "VisibilityName")) 
(progn (alert "Selected object is not a Visibility parameter ") (exit)))
;Switching off grips of all the objects
(sssetfirst nil nil)
;Getting ACAD_EVALUATION_GRAPH dictionary
(eval_graf_output)
;Finding required Visibility Set
(mapcar '(lambda (x) 
  (if (and (= (car x) 360) 
           (= (cdr (assoc 0 (entget (cdr x)))) "BLOCKVISIBILITYPARAMETER")
           (= (cdr (assoc 301 (entget (cdr x)))) listprop))
      (setq BLC-VIS-PAR x))) EVAL_GRAPH)
;Finding Visibility Set position in eval_graph list
(setq current-91 (nth (- (vl-position BLC-VIS-PAR EVAL_GRAPH) 3) EVAL_GRAPH))

;Moving record with Visibility Set up to the top (see details in function visibility_add)
(while (> (cdr current-91) 0)
;Finding next pair
(setq num4_prop_block (cons 91 (1- (cdr current-91))))
(setq EVAL_GRAPH (subst '(1) num4_prop_block EVAL_GRAPH))
(setq EVAL_GRAPH (subst '(2) current-91 EVAL_GRAPH))
(setq EVAL_GRAPH (subst num4_prop_block '(2) EVAL_GRAPH))
(setq EVAL_GRAPH (subst current-91 '(1) EVAL_GRAPH))
(entmod EVAL_GRAPH)
(eval_graf_output)
(mapcar '(lambda (x) 
  (if (and (= (car x) 360) 
           (= (cdr (assoc 0 (entget (cdr x)))) "BLOCKVISIBILITYPARAMETER")
           (= (cdr (assoc 301 (entget (cdr x)))) listprop))
      (setq BLC-VIS-PAR x))) EVAL_GRAPH)
;Finding element's position in eval_graph list
(setq current-91 (nth (- (vl-position BLC-VIS-PAR EVAL_GRAPH) 3) EVAL_GRAPH))
);end while

;Saving block
(vla-SendCommand (vla-get-ActiveDocument (vlax-get-acad-object)) "_.BSAVE  ")
;Getting ACAD_EVALUATION_GRAPH dictionary again
(eval_graf_output)
;Finding current state in the current Visibility Set
(setq tecuchiy (cdr (assoc 303 (entget (cdr (assoc 360 EVAL_GRAPH))))))
;Setting current state
(vla-SendCommand (vla-get-ActiveDocument (vlax-get-acad-object)) "(command \"_.-BVSTATE\" \"_S\" tecuchiy) ")
;Saving block
(vla-SendCommand (vla-get-ActiveDocument (vlax-get-acad-object)) "_.BSAVE ")
;We do the complete regeneration of editor of blocks
(command "_-BVSTATE" "_N" "W5W" "_H")
(command "_.undo" "")
;We turn off visibility all elements, to not belongings current Visibility Set
(eddedd)
(kpblc-objects-hide 2)
(command "_.BVMODE" "0")
(command "_.BVMODE" "1")
Getting string with current Visibility Set name and returning it
(tecuch_visibility)
);end defun visibility-up

;==================================================================================================================================================

; *** 04 *** ;Used by 03 and 13
;Function for switching on grips of all the elements of the current Visibility Set

(defun eddedd (/ current_visibility current_visibility1 tecuch_elements nabor-add)
;Getting ACAD_EVALUATION_GRAPH dictionary
(eval_graf_output)
;Getting current Visibility Set
(setq current_visibility (tecuch_visibility))
;Retrieving its code 360
(mapcar '(lambda (x) 
  (if (and (= (car x) 360) 
           (= (cdr (assoc 0 (entget (cdr x)))) "BLOCKVISIBILITYPARAMETER")
           (= (cdr (assoc 301 (entget (cdr x)))) current_visibility))
  (setq current_visibility1 (entget (cdr x))))) EVAL_GRAPH)
;Creating list of elements for current Visibility Set
(setq tecuch_elements nil)
(mapcar '(lambda (x) 
(if (= (car x) 331) (setq tecuch_elements (append tecuch_elements (list (cdr x)))))
) current_visibility1)
;Creating sset with these elements
(setq nabor-add (ssadd))
(mapcar '(lambda (x) 
(setq nabor-add (ssadd x nabor-add))
) tecuch_elements)
;Switching grips on for the elements
(sssetfirst nil nabor-add)
);end eddedd

;===================================================================================================================================================

; *** 05 *** 'Used by 03, 04 and 13
;Function for retrieving name of the current Visibility Set. It is used as an independent function or as a utility function.
;It returns a string with Visibility Set name. The current_visibility variable stores name of the current
; Visibility Set

(defun tecuch_visibility (/ tecuch_spis res2_spisok)
;Getting ACAD_EVALUATION_GRAPH dictionary
(eval_graf_output)
;Getting list of all the Visibility Sets in the same order as in ACAD_EVALUATION_GRAPH
(setq tecuch_spis nil)
(mapcar '(lambda (x) 
  (if (and (= (car x) 360) 
           (= (cdr (assoc 0 (entget (cdr x)))) "BLOCKVISIBILITYPARAMETER"))
  (setq tecuch_spis (append tecuch_spis (list (cdr (assoc 301 (entget (cdr x))))))))) EVAL_GRAPH)
;Checking list for identical Visibility Set names
(setq res2_spisok nil)
(mapcar '(lambda (x) (if (member x res2_spisok)
 (progn
  (alert (strcat x
  "\nBlock should not contain identical property names! \nAdd a space at the end of property name!"))
  (exit))
 (setq res2_spisok (append res2_spisok (list x))))
) tecuch_spis)
;Selecting the first name in list, this Visibility Set is current
(setq current_visibility (car tecuch_spis))
;And finally writing current Visibility set name to status line,
; as VVA from DWG.RU forum advised me
(setvar "MODEMACRO" current_visibility)
);end tecuch_visibility

;=====================================================================================================================================================

; *** 06 ***	; Used by 07 and 08
;Utility function for auditing BLOCKVISIBILITYPARAMETER dictionary. The function receives dictionary
;without pointers to elements or properties. As a result dictionary list with modified pairs and without 1071 & 1010
;is stored into BLC-VISPAR variable

(defun blk-visib-param-auditor (visname / BLC-VISPAR-in st-vispar)
;Processing DXF decription of the dictionary only if is an element of BLOCKVISIBILITYPARAMETER parameter
(if (= (cdr (assoc 0 visname)) "BLOCKVISIBILITYPARAMETER") (progn
(setq BLC-VISPAR nil)
;Dictionary is scanned from the end up to dotted pair 91
(setq BLC-VISPAR-in (reverse visname))
(setq st-vispar 0)
(while
;While looping BLC-VISPAR-in list is reduced and BLC-VISPAR is extended, number is counted
; and value of the next pair is modified
(cond 
((= (caar BLC-VISPAR-in) 333) (setq BLC-VISPAR (append BLC-VISPAR (list (car BLC-VISPAR-in)))) (setq st-vispar (1+ st-vispar)) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 95) (setq BLC-VISPAR (append BLC-VISPAR (list (cons 95 st-vispar)))) (setq st-vispar 0) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 332) (setq BLC-VISPAR (append BLC-VISPAR (list (car BLC-VISPAR-in)))) (setq st-vispar (1+ st-vispar)) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 94) (setq BLC-VISPAR (append BLC-VISPAR (list (cons 94 st-vispar)))) (setq st-vispar 0) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 303) (setq BLC-VISPAR (append BLC-VISPAR (list (car BLC-VISPAR-in)))) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 92) (setq BLC-VISPAR (append BLC-VISPAR (list (car BLC-VISPAR-in)))) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 331) (setq BLC-VISPAR (append BLC-VISPAR (list (car BLC-VISPAR-in)))) (setq st-vispar (1+ st-vispar)) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 93) (setq BLC-VISPAR (append BLC-VISPAR (list (cons 93 st-vispar)))) (setq st-vispar 0) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 91) (setq BLC-VISPAR (append BLC-VISPAR BLC-VISPAR-in)) (setq BLC-VISPAR (reverse (vl-remove (assoc 1071 BLC-VISPAR) (vl-remove (assoc 1010 BLC-VISPAR) BLC-VISPAR)))) (setq BLC-VISPAR-in nil))
))
)));end blk-visib-param-auditor

;=======================================================================================================================================================

; *** 07 *** ;Head Function
;Function for removing selected elements from the current Visibility Set

(defun C:VSPDelsel (/ el-sel-cur length_Nabor_sel ST_Nabor list_Nabor_sel list_Nabor_sel12 tecuch_spis current_visibility current_visibility2)
;Selecting elements
(setq el-sel-cur (ssget))
;Determining number of selected elements
(setq length_Nabor_sel (sslength el-sel-cur))
;Converting sset to list
(setq ST_Nabor 0)
(setq list_Nabor_sel nil)
(while (<=  ST_Nabor length_Nabor_sel) (setq list_Nabor_sel (append list_Nabor_sel (list (ssname el-sel-cur ST_Nabor)))) (setq ST_Nabor (1+ ST_Nabor)))
;Removing nil form the list and reversing it
(setq list_Nabor_sel (cdr (reverse list_Nabor_sel)))
;Deleting dynamic properties frim the list
(setq list_Nabor_sel12 nil)
(mapcar '(lambda (x) (if (/= (length (entget x)) 1) (setq list_Nabor_sel12 (append list_Nabor_sel12 (list x))))) list_Nabor_sel)
;Getting ACAD_EVALUATION_GRAPH dictionary
(eval_graf_output)
;Getting list of all the Visibility Sets
(setq tecuch_spis nil)
(mapcar '(lambda (x) 
  (if (and (= (car x) 360) 
           (= (cdr (assoc 0 (entget (cdr x)))) "BLOCKVISIBILITYPARAMETER"))
  (setq tecuch_spis (append tecuch_spis (list (cdr x)))))) EVAL_GRAPH)
;Determining current Visibility Set (using position in the list)
(setq current_visibility (entget (car tecuch_spis)))
;Removing selected elements from the Visibility Set
(setq current_visibility2 (vl-remove-if '(lambda (x) (member (cdr x) list_Nabor_sel12)) current_visibility))
;Arranging dotted pairs specifying number of elements in the list of states
(blk-visib-param-auditor current_visibility2)
;Modifying block
(entmod BLC-VISPAR)
;Saving block
(command "_.BSAVE")
);end element-sel-current-del

;=======================================================================================================================================================

; *** 08 *** ; Head function
;Function for removing all the elements from the current Visibility Set

(defun C:VSPDelAll (/ tecuch_spis current_visibility list_Nabor_sel12 current_visibility2)
;Getting ACAD_EVALUATION_GRAPH dictionary
(eval_graf_output)
;Getting list of all theVisibility Sets
(setq tecuch_spis nil)
(mapcar '(lambda (x) 
  (if (and (= (car x) 360) 
           (= (cdr (assoc 0 (entget (cdr x)))) "BLOCKVISIBILITYPARAMETER"))
  (setq tecuch_spis (append tecuch_spis (list (cdr x)))))) EVAL_GRAPH)
;Retrieving current (using position in the list)
(setq current_visibility (entget (car tecuch_spis)))
;Creating list of all the elements of the current Visibility Set
(setq list_Nabor_sel12 nil)
(mapcar '(lambda (x)  (if (= (car x) 331) (setq list_Nabor_sel12 (append list_Nabor_sel12 (list (cdr x)))))) current_visibility)
;Removing all the elements (dotted pair 331)
(setq current_visibility2 (vl-remove-if '(lambda (x) (member (cdr x) list_Nabor_sel12)) current_visibility))
;Arranging dotted pairs  specifying number of elements in the list of states
(blk-visib-param-auditor current_visibility2)
;Modifying block
(entmod BLC-VISPAR)
;Saving block
(command "_.BSAVE")
);end element-all-current-del

;=======================================================================================================================================================

; *** 09 *** ; Head function
;Function for adding selected elements to current Visibility Set

(defun C:VSPAddsel (/ el-sel-cur length_Nabor_sel tecuch_spis list_Nabor_sel14 current_visibility5 list_Nabor_sel12 spis-end BLC-VISPAR BLC-VISPAR-in)
;Setting visible for all the block elements
 (foreach item (mapcar 'vlax-ename->vla-object (vl-remove-if 'listp (mapcar 'cadr (ssnamex (ssget "_A"))))) (vla-put-visible item :vlax-true))
;Selected required elements
(setq el-sel-cur (ssget ))
;Returning to initial visibility/invisibility for all elements
(command "_.undo" "2")
;Determining number of elements taken into sset
(setq length_Nabor_sel (sslength el-sel-cur))
;Converting sset to list
(setq ST_Nabor 0)
(setq list_Nabor_sel nil)
(while (<=  ST_Nabor length_Nabor_sel) (setq list_Nabor_sel (append list_Nabor_sel (list (ssname el-sel-cur ST_Nabor)))) (setq ST_Nabor (1+ ST_Nabor)))
;Reversing list (it was created in an opposite order) and kill Nil in it
(setq list_Nabor_sel (cdr (reverse list_Nabor_sel)))
;Removing dynamic properties and grips frim the list
(setq list_Nabor_sel14 nil)
(mapcar '(lambda (x) (if (/= (length (entget x)) 1) (setq list_Nabor_sel14 (append list_Nabor_sel14 (list (cons 331 x)))))) list_Nabor_sel)
;Getting ACAD_EVALUATION_GRAPH dictionary
(eval_graf_output)
;Getting list of all the Visibility Sets
(setq tecuch_spis nil)
(mapcar '(lambda (x) 
  (if (and (= (car x) 360) 
           (= (cdr (assoc 0 (entget (cdr x)))) "BLOCKVISIBILITYPARAMETER"))
  (setq tecuch_spis (append tecuch_spis (list (cdr x)))))) EVAL_GRAPH)
;Selecting current (using order in the list)
(setq current_visibility5 (entget (car tecuch_spis)))
;Creating list of all the elements of the current Visibility Set
(setq list_Nabor_sel12 nil)
(mapcar '(lambda (x)  (if (= (car x) 331) (setq list_Nabor_sel12 (append list_Nabor_sel12 (list x))))) current_visibility5)
;Removing from list_Nabor_sel14 list the pointers to elements that are already included into list_Nabor_sel12 list
(mapcar '(lambda (x) (if (member x list_Nabor_sel14) (setq list_Nabor_sel14 (vl-remove x list_Nabor_sel14)))) list_Nabor_sel12)
;Joining both lists
(setq spis-end (append list_Nabor_sel12 list_Nabor_sel14))
;This is a slightly modified source of the audit utility testing mapping between dotted pair values and pointers to number of elements, but instead of counting pairs 331 we remove them and add our common spis-end list to BLC-VISPAR list
(if (= (cdr (assoc 0 current_visibility5)) "BLOCKVISIBILITYPARAMETER") (progn
(setq BLC-VISPAR nil)
(setq BLC-VISPAR-in (reverse current_visibility5))
(setq st-vispar 0)
(while
(cond 
((= (caar BLC-VISPAR-in) 333) (setq BLC-VISPAR (append BLC-VISPAR (list (car BLC-VISPAR-in)))) (setq st-vispar (1+ st-vispar)) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 95) (setq BLC-VISPAR (append BLC-VISPAR (list (cons 95 st-vispar)))) (setq st-vispar 0) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 332) (setq BLC-VISPAR (append BLC-VISPAR (list (car BLC-VISPAR-in)))) (setq st-vispar (1+ st-vispar)) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 94) (setq BLC-VISPAR (append BLC-VISPAR (list (cons 94 st-vispar)))) (setq st-vispar 0) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 303) (setq BLC-VISPAR (append BLC-VISPAR (list (car BLC-VISPAR-in)))) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 92) (setq BLC-VISPAR (append BLC-VISPAR (list (car BLC-VISPAR-in)))) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 331) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 93) (setq BLC-VISPAR (append BLC-VISPAR spis-end)) (setq BLC-VISPAR (append BLC-VISPAR (list (cons 93 (length spis-end))))) (setq st-vispar 0) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 91) (setq BLC-VISPAR (append BLC-VISPAR BLC-VISPAR-in)) (setq BLC-VISPAR (reverse (vl-remove (assoc 1071 BLC-VISPAR) (vl-remove (assoc 1010 BLC-VISPAR) BLC-VISPAR)))) (setq BLC-VISPAR-in nil))
))
))
;Modifying block
(entmod BLC-VISPAR)
;Saving block
(command "_.BSAVE")
);end element-sel-current-insert

;===========================================================================================================================================================

; *** 10 *** ; Head function
;Function for complete cleaning current state from all the elements, dynamic properties and states

(defun C:VSPclean (/ object-load listprop BLC-VIS-PAR tecuchiy del1010 del1071)
;Getting ACAD_EVALUATION_GRAPH dictionary
(eval_graf_output)
;Getting pointer to required Visibility Set
(setq object-load (car (entsel "Select parameter of required Visibility Set: ")))
;If it is a Visibility Set then we retrieve its name, otherwise we scold and exit function
(if (= (vla-get-ObjectName (vlax-ename->vla-object object-load)) "AcDbBlockVisibilityParameterEntity")
(setq listprop (vlax-get-property (vlax-ename->vla-object object-load) "VisibilityName")) 
(progn (alert "Selected object is not a Visibility parameter") (exit)))
;Switching off all the selections in the block editor space
(sssetfirst nil nil)
;Getting pointer of the selected Visibility Set
(mapcar '(lambda (x) 
  (if (and (= (car x) 360) 
           (= (cdr (assoc 0 (entget (cdr x)))) "BLOCKVISIBILITYPARAMETER"))
     (if (= (cdr (assoc 301 (entget (cdr x)))) listprop)
      (setq BLC-VIS-PAR (cdr x))))) EVAL_GRAPH)
;Getting list of dotted pairs for selected Visibility Set (alas, 'mapcar' fails here, 'and' needs only two parameters)
(setq BLC-VIS-PAR (entget BLC-VIS-PAR))
;Getting begin for the list of Visibility Set
(setq tecuchiy (reverse (cdr (member (assoc 91 BLC-VIS-PAR) (reverse BLC-VIS-PAR)))))
;Removing dotted pairs 1010 and 1071
(setq del1010 (assoc 1010 tecuchiy))
(setq tecuchiy (vl-remove del1010 tecuchiy))
(setq del1071 (assoc 1071 tecuchiy))
(setq tecuchiy (vl-remove del1071 tecuchiy))
;Appending pure "tail" of Visibility Set's description
(setq tecuchiy (append tecuchiy '((91 . 0) (93 . 0) (92 . 1) (303 . "Clean") (94 . 0) (95 . 0))))
;Modifying block
(entmod tecuchiy)
;Saving block
(command "_.BSAVE")
);end Visibility_clear

;===========================================================================================================================================================

; *** 11 *** ; Head function
;Function for setting visibility of all the dynamic properties and grips in all the states of all Visibility Sets

(defun C:VSPallProps (/ el-sel-cur length_Nabor_sel ST_Nabor list_Nabor_sel list_Nabor_sel14 Nabor_sel16 tecuch_spis BLC-VISPAR st-vispar BLC-VISPAR-in)
;Selecting required elements
(setq el-sel-cur (ssget))
;Determining number of elements taken to sset
(setq length_Nabor_sel (sslength el-sel-cur))
;Converting sset to list
(setq ST_Nabor 0)
(setq list_Nabor_sel nil)
(while (<=  ST_Nabor length_Nabor_sel) (setq list_Nabor_sel (append list_Nabor_sel (list (ssname el-sel-cur ST_Nabor)))) (setq ST_Nabor (1+ ST_Nabor)))
;Reversing list (it was created in an opposite order) and kill Nil in it
(setq list_Nabor_sel (cdr (reverse list_Nabor_sel)))
;Leaving in the list only dynamic properties and grips and forming dotted pairs 333
(setq list_Nabor_sel14 nil)
(mapcar '(lambda (x) (if (= (length (entget x)) 1) (setq list_Nabor_sel14 (append list_Nabor_sel14 (list (cons 333 (sootvetstvie x))))))) list_Nabor_sel)
;Getting ACAD_EVALUATION_GRAPH dictionary
(eval_graf_output)
;Getting list of all Visibility Sets
(setq tecuch_spis nil)
(mapcar '(lambda (x) 
  (if (and (= (car x) 360) 
           (= (cdr (assoc 0 (entget (cdr x)))) "BLOCKVISIBILITYPARAMETER"))
  (setq tecuch_spis (append tecuch_spis (list (cdr x)))))) EVAL_GRAPH)
;Looping, applied to each Visibility Set
(mapcar '(lambda (x)
;Common starting settings
(setq BLC-VISPAR nil)
(setq st-vispar 0)
(setq BLC-VISPAR-in (reverse (entget x)))
(setq Nabor_sel16 nil)
;Looping applied to Visibility Set being processed, while handling pairs 333 group we join this group 
;with list of selected ;properties, and while handling pair 95 we join list with BLC-VISPAR list
(while
;In the loop BLC-VISPAR-in is being reduced, BLC-VISPAR is being extended and next pair value is being edited
(cond 
((= (caar BLC-VISPAR-in) 333) (if (member (car BLC-VISPAR-in) list_Nabor_sel14) T (progn (setq Nabor_sel16 (append Nabor_sel16 (list (car BLC-VISPAR-in)))))) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 95) (setq Nabor_sel16 (append Nabor_sel16 list_Nabor_sel14)) (setq BLC-VISPAR (append BLC-VISPAR Nabor_sel16 (list (cons 95 (length Nabor_sel16))))) (setq Nabor_sel16 nil) (setq st-vispar 0) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 332) (setq BLC-VISPAR (append BLC-VISPAR (list (car BLC-VISPAR-in)))) (setq st-vispar (1+ st-vispar)) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 94) (setq BLC-VISPAR (append BLC-VISPAR (list (cons 94 st-vispar)))) (setq st-vispar 0) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 303) (setq BLC-VISPAR (append BLC-VISPAR (list (car BLC-VISPAR-in)))) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 92) (setq BLC-VISPAR (append BLC-VISPAR (list (car BLC-VISPAR-in)))) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 331) (setq BLC-VISPAR (append BLC-VISPAR (list (car BLC-VISPAR-in)))) (setq st-vispar (1+ st-vispar)) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 93) (setq BLC-VISPAR (append BLC-VISPAR (list (cons 93 st-vispar)))) (setq st-vispar 0) (setq BLC-VISPAR-in (cdr BLC-VISPAR-in)))
((= (caar BLC-VISPAR-in) 91) (setq BLC-VISPAR (append BLC-VISPAR BLC-VISPAR-in)) (setq BLC-VISPAR (reverse (vl-remove (assoc 1071 BLC-VISPAR) (vl-remove (assoc 1010 BLC-VISPAR) BLC-VISPAR)))) (setq BLC-VISPAR-in nil))
))
;Modifying Visibility Set
(entmod BLC-VISPAR)
) tecuch_spis)
;Saving block
(command "_.BSAVE")
);end properties_add_all_visibility

;========================================================================================================================================================================================

; *** 12 ***;	Used by 11
;Utility function for determining accordance of element pointer in the block editor space with ACAD_EVALUATION_GRAPH and BLOCKVISIBILITYPARAMETER dictionaries
;Function argument is element pointer in block editor space

(defun sootvetstvie (ukaz-15 / ukaz Nabor_all length_Nabor_all ST_Nabor list_Nabor_all prop_nabor prop_eval ukaz-1)
(setq ukaz ukaz-15)
;If argument is dynamic property or grip then we continue work and if no we return the argument
(if (= (length (entget ukaz)) 1)
(progn
;Getting ACAD_EVALUATION_GRAPH dictionary
(eval_graf_output)
;Getting sset of all the elements and dynamic properties (as entities) in block editor space
(setq Nabor_all (ssget "_X"))
;Counting number of elements in the sset
(setq length_Nabor_all (sslength Nabor_all))
;Converting sset to list, killing Nil
(setq ST_Nabor 0)
(setq list_Nabor_all nil)
(while (<=  ST_Nabor length_Nabor_all) (setq list_Nabor_all (append list_Nabor_all (list (ssname Nabor_all ST_Nabor)))) (setq ST_Nabor (1+ ST_Nabor)))
(setq list_Nabor_all (vl-remove nil list_Nabor_all))
;Leaving in the list only dynamic propeties and grips
(setq prop_nabor nil)
(mapcar '(lambda (x) (if (= (length (entget x)) 1) (setq prop_nabor (append prop_nabor (list x))))
) list_Nabor_all)
;Getting list of dynamic properties and grips from ACAD_EVALUATION_GRAPH dictionary (BLOCKGRIPLOCATIONCOMPONENT parameters excluded)
(setq prop_eval nil)
(mapcar '(lambda (x) 
(if (and (= (car x) 360) (/= (cdr (assoc 0 (entget (cdr x)))) "BLOCKGRIPLOCATIONCOMPONENT"))
(setq prop_eval (append prop_eval (list (cdr x))))
)) EVAL_GRAPH)
;Reversing list of properties from ACAD_EVALUATION_GRAPH (for it was created in a reverse order)
(setq prop_eval (reverse prop_eval))
;Determinig position number for function argument in the properties list of block editor space
(setq ukaz-1 (vl-position ukaz prop_nabor))
;Overriding value of the variable containing function argument with value from ACAD_EVALUATION_GRAPH dictionary
(setq ukaz (nth ukaz-1 prop_eval))
;Returning received value
(print ukaz)
);end progn
;If argument was neither property nor grip we return argument value
(print ukaz)
));end sootvetstvie
;============================================================================================================================================================
; *** 13 *** ; Head

;Function for batch setting visibility of selected entities in several chosen states of the current visibility set

(defun C:VSPSel2VS ()	;move-to-visibilityset: Using a form to Set/Add (in)visibility for selected objects in several visibility States
       
;We turn off visibility of all the elements that do not belong to the current Visibility Set
(eddedd) S
(kpblc-objects-hide 2)
(command "_.BVMODE" "0")
(command "_.BVMODE" "1")

;Creating a temporary "point" element
(vl-cmdf "_.POINT" "0,0,0")
(setq point_block (entlast))
(setq block_block (cdr (assoc 330 (entget point_block))))

;Getting ACAD_EVALUATION_GRAPH dictionary
(eval_graf_output)

;Getting states list for current Visibility Set (spis_name_vis-state variable)
; and current state name for current Visibility Set (current-vis-state variable)
(setq spis_name_vis-state nil)
(mapcar '(lambda (x) 
(if (and (= (car x) 360) (= (cdr (assoc 0 (entget (cdr x)))) "BLOCKVISIBILITYPARAMETER") (= (cdr (assoc 301 (entget (cdr x)))) (tecuch_visibility)))
(progn (mapcar '(lambda (y) (if (= (car y) 303) (setq spis_name_vis-state (append spis_name_vis-state (list (cdr y)))))
) (entget (cdr x)))
(setq current-vis-state (cdr (assoc 303 (member (cons 332 point_block) (reverse (entget (cdr x)))))))
);end progn
)
) EVAL_GRAPH)

;Removing temporary "point" element
(vla-Delete (vlax-ename->vla-object point_block))

;Function for calculation of selected value in DCL window
(defun modes3 () 
(setq listname nil)
(setq listnum nil)
(setq getb10 (get_tile "b10")) 
(while (/= getb10 "")
(setq read-get (read getb10))
(setq listnum (append listnum (list read-get)))
(setq getb10 (vl-string-left-trim (itoa read-get) getb10))
(setq getb10 (vl-string-left-trim " " getb10))
)
(mapcar '(lambda (x) (setq listname (append listname (list (nth x spis_name_vis-state))))) listnum)
(mode_tile "df5" 0)
(mode_tile "df6" 0)
(mode_tile "df9" 0)
(mode_tile "df10" 0)
)

;Function for processing DCL dialog
(defun dialog-recruss ()
(if (not (new_dialog "np_prop" Selprop "" done-dialog-fact)) (progn (alert "Program error") (exit)))
(modes3)
(mode_tile "df5" 1)
(mode_tile "df6" 1)
(mode_tile "df9" 1)
(action_tile "b10" "(modes3)") ; After actions listname contains list of selected Visibilities
(action_tile "df3" "(exit)")
(action_tile "df7" "(setq quit-dialog 2 done-dialog-fact (done_dialog 92))")
(action_tile "df8" "(setq quit-dialog 3 done-dialog-fact (done_dialog 92))")
(action_tile "df4" "(setq quit-dialog 1 done-dialog-fact (done_dialog 92))")
(action_tile "df5" "(setq quit-dialog 4 done-dialog-fact (done_dialog 92))")
(action_tile "df6" "(setq quit-dialog 5 done-dialog-fact (done_dialog 92))")
(action_tile "df9" "(setq quit-dialog 6 done-dialog-fact (done_dialog 92))")
(start_list "b10")
(setq ddffdd (mapcar 'add_list spis_name_vis-state))
(end_list)
(set_tile "df11" (vl-princ-to-string (sslength nabor_block)))
(start_dialog)
)

;Creation of DCL file
(setq Fdcl "move_to_visibilityset.dcl")                                          ;;; Add VVA 12.09.2008
(setq Fdcl (strcat (VL-FILENAME-DIRECTORY(vl-filename-mktemp Fdcl)) "\\" Fdcl))
(vl-file-delete Fdcl) ;_Mod VVA 12.09.2008 ;Kill such a file if it exists for it is created from the very beginning each time
(setq dsl0066 (open Fdcl "w")) ;Filling-in of move_to_visibilityset.dcl file with controls
(write-line "np_prop: dialog{label=\" - Virtual Building Technologies - \";" dsl0066)
(write-line "  :spacer{width=1;height=1;}" dsl0066)
(write-line "  :column{label=\"Set visibility mode in several Visibility Sets at once\";" dsl0066)
(write-line "  :row{label=\"\";" dsl0066)
(write-line "  :button{label=\"Select objects\";key=\"df4\";fixed_width=true;}" dsl0066)
(write-line "  :edit_box{label=\"Elements selected:\";value=0;key=\"df11\";fixed_width=true;}" dsl0066)
(write-line "  }" dsl0066)
(write-line "  :button{label=\"Set visibility for selected objects everywhere\";key=\"df7\";fixed_width=true;width=95;}" dsl0066)
(write-line "  :button{label=\"Set invisibility for selected objects everywhere\";key=\"df8\";fixed_width=true;width=95;}" dsl0066)
(write-line "  :button{label=\"Add visibility for selected objects in selected Visibility states\";key=\"df5\";fixed_width=true;width=95;}" dsl0066)
(write-line "  :button{label=\"Set visibility for selected objects only in selected Visibility states\";key=\"df6\";fixed_width=true;width=95;}" dsl0066)
(write-line "  :button{label=\"Set invisibility for selected objects in selected Visibility states\";key=\"df9\";fixed_width=true;width=95;}" dsl0066)
(write-line "  }" dsl0066)
(write-line "  :list_box{label=\"List of Visibility state names\";list=\" \";value=\"\";key=\"b10\";width=35;multiple_select=true;" dsl0066)
(write-line "  }" dsl0066)
(write-line "  :ok_button{label=\"Ok\";key=\"df3\";alignment=centered;fixed_width=true;is_cancel=true;}" dsl0066)
(write-line "  }" dsl0066)
(write-line "  //" dsl0066)
(close dsl0066)

;Launching the first dialog
(if (/= (setq Selprop (load_dialog Fdcl)) -1)
(new_dialog "np_prop" Selprop "" (list 222 114)) (alert "File move_to_visibilityset.dcl not found"))
(mode_tile "b10" 1) 
(action_tile "df3" "(exit)")
(mode_tile "df7" 1)
(action_tile "df4" "(setq quit-dialog 1 done-dialog-fact (done_dialog 92))")
(mode_tile "df5" 1)
(mode_tile "df6" 1)
(mode_tile "df8" 1)
(mode_tile "df9" 1)
(start_dialog)

;Launching next dialogs
(while (= 1 1)
(if (= quit-dialog 1) (progn (alert "1") (setq quit-dialog nil) (setq nabor_block (ssget)) (dialog-recruss)))
(if (= quit-dialog 2) (progn (alert "2") (setq quit-dialog nil) (sssetfirst nil nabor_block) (vl-cmdf "_.BVSHOW" "_A") (dialog-recruss)))
(if (= quit-dialog 3) (progn (alert "3") (setq quit-dialog nil) (sssetfirst nil nabor_block) (vl-cmdf "_.BVHIDE" "_A") (dialog-recruss)))
(if (= quit-dialog 4) (progn (alert "4") (setq quit-dialog nil) (mapcar '(lambda (x) (vl-cmdf "_.-BVSTATE" "_S" x) (sssetfirst nil nabor_block) (command "_.BVSHOW" "_C")) listname) (vl-cmdf "_.-BVSTATE" "_S" current-vis-state) (dialog-recruss)))
(if (= quit-dialog 5) (progn (alert "5") (setq quit-dialog nil) (sssetfirst nil nabor_block) (vl-cmdf "_BVHIDE" "_A") (mapcar '(lambda (x) (vl-cmdf "_.-BVSTATE" "_S" x) (sssetfirst nil nabor_block) (vl-cmdf "_.BVSHOW" "_C")) listname) (vl-cmdf "_.-BVSTATE" "_S" current-vis-state) (dialog-recruss)))
(if (= quit-dialog 6) (progn (alert "6") (setq quit-dialog nil) (mapcar '(lambda (x) (vl-cmdf "_.-BVSTATE" "_S" x) (sssetfirst nil nabor_block) (vl-cmdf "_.BVHIDE" "_C")) listname) (vl-cmdf "_.-BVSTATE" "_S" current-vis-state) (dialog-recruss)))
)
);end defun move-to-visibilityset

;============================================================================================================================================================
; *** 14 *** ; Used by 03 and 13

;Function for switching visibility of selected entities
;Used as utility function in visibility-up and move-to-visibilityset
;© 2008, Alexey Kulik, Saint Petersburg, Russian Federation
; Some code is taken from the book "AutoCAD-Based System - How to Do It" by S.Zuev, N.Poleshchuk (BHV-Petersburg, 2004)
; (see http://poleshchuk.spb.ru/cad/2004/book10e.htm, http://cad.kurganobl.ru)


(defun kpblc-objects-hide (bit
                           /
                           *error*
                           _kpblc-error-catch
                           _kpblc-layer-status-restore
                           _kpblc-layer-status-save
                           selset
                           selset_all
                           msg
                           item
                           )
            ;|
*   Hiding selected entities / unselected entities / showing entities
* Done as an attempt to create an analog of ADT "Isolate objects" command
* Works only in active space
*    Call parameters:
*  bit: what to do. 0 — show all; 1 — hide selected; 2 — hide all except selected
*    Call examples:
(kpblc-objects-hide 0); Show all the objects
(kpblc-objects-hide 1); Hide selected objects
(kpblc-objects-hide 2); Hide all objects except selected
|;

  (defun *error* (msg)
    (_kpblc-layer-status-restore)
    (vla-endundomark *kpblc-activedoc*)
    (princ msg)
    (princ)
    );_ end of defun

  (defun _kpblc-error-catch (protected-function
                             on-error-function
                             /
                             catch_error_result
                             )
                    ;|
*** Function is taken from the book version of ruCAD with no changes
*** but renaming
*    Error catching shell.
*    Call parameters:
*    protected-function    - function "to be protected"
*    on-error-function     - function called on error
|;
    (setq catch_error_result (vl-catch-all-apply protected-function))
    (if (and (vl-catch-all-error-p catch_error_result)
             on-error-function
             );_ end of and
      (apply on-error-function
             (list (vl-catch-all-error-message catch_error_result))
             );_ end of apply
      catch_error_result
      );_ end of if
    );_ end of defun

  (defun _kpblc-layer-status-restore (/ item)
                    ;|
*    Restoring layer states from the global list
* *kpblc-list-layer-status*
*    Call parameters:
*    none
*    Call examples:
(_kpblc-layer-status-restore)
|;
    (if *kpblc-list-layer-status*
      (progn
        (foreach item *kpblc-list-layer-status*
          (_kpblc-error-catch
            '(lambda ()
               (vla-put-freeze (car item) (cdr (assoc "freeze" (cdr item))))
               );_ end of LAMBDA
            nil
            );_ end of _kpblc-error-catch
          (_kpblc-error-catch
            '(lambda ()
               (vla-put-lock (car item) (cdr (assoc "lock" (cdr item))))
               );_ end of LAMBDA
            nil
            );_ end of _kpblc-error-catch
          );_ end of foreach
        );_ end of progn
      );_ end of if
    (setq *kpblc-list-layer-status* nil)
    );_ end of defun

  (defun _kpblc-layer-status-save (layers-on / item)
                    ;|
*    Unlocking and thawing all the layers of the active document. State
* is saved in the global list *kpblc-list-layer-status* like
* '(vla-pointer ("freeze" . :vlax-true) ("lock" . :vlax-false))
*    Call parameters:
*    layers-on    to switch layers on (t) or no (nil)
*    Call examples:
(_kpblc-layer-status-save t)
|;
    (vlax-for item (vla-get-layers *kpblc-activedoc*)
      (setq *kpblc-list-layer-status*
             (append *kpblc-list-layer-status*
                     (list
                       (list item
                             (cons "freeze" (vla-get-freeze item))
                             (cons "lock" (vla-get-lock item))
                             );_ end of list
                       );_ end of list
                     );_ end of append
            );_ end of setq
      (if layers-on
        (progn
          (_kpblc-error-catch
            '(lambda ()
               (vla-put-freeze item :vlax-false)
               );_ end of LAMBDA
            nil
            );_ end of _kpblc-error-catch
          (vla-put-lock item :vlax-false)
          );_ end of progn
        );_ end of if
      );_ end of vlax-for
    );_ end of defun

  (vl-load-com)
  (or *kpblc-activedoc*
      (setq *kpblc-activedoc* (vla-get-activedocument (vlax-get-acad-object)))
      );_ end of if
  (vla-startundomark *kpblc-activedoc*)
  (_kpblc-layer-status-save t)
  (cond
    ((= bit 1) (setq msg "Hide selected objects"))
    ((= bit 2) (setq msg "Hide all excluding selected"))
    );_ end of cond
  (if (= bit 0)
    (progn
      (foreach item
               (mapcar
                 'vlax-ename->vla-object
                 (vl-remove-if 'listp (mapcar 'cadr (ssnamex (ssget "_A"))))
                 );_ end of mapcar
        (vla-put-visible item :vlax-true)
        );_ end of foreach
      );_ end of progn
    (progn
      (setq selset (ssget "_I"))
      (while (not selset)
        (prompt msg)
        (setq selset (ssget))
        );_ end of while
      (cond
        ((= bit 1); Hide selected
         (foreach item
                  (mapcar 'vlax-ename->vla-object
                          (vl-remove-if 'listp (mapcar 'cadr (ssnamex selset)))
                          );_ end of mapcar
           (vla-put-visible item :vlax-false)
           );_ end of while
         )
        ((= bit 2); Hide except selected
         (setq selset_all (ssget "_A"))
         (while (and selset_all (> (sslength selset_all) 0))
           (setq item (ssname selset_all 0))
           (ssdel item selset_all)
           (if (not (ssmemb item selset))
             (vla-put-visible (vlax-ename->vla-object item) :vlax-false)
             );_ end of if
           );_ end of while
         )
        );_ end of cond
      );_ end of progn
    );_ end of if
  (sssetfirst nil nil)
  (_kpblc-layer-status-restore)
  (vla-endundomark *kpblc-activedoc*)
  (princ)
  );_ end of defun

(defun c:hideobj (/ answer)
  (vl-load-com)
  (if
    (not (vl-catch-all-error-p
           (vl-catch-all-apply
             '(lambda ()
                (initget
                  "Show SElected Exclude _ 0 1 2"
                  );_ end of initget
                (setq answer
                       (getkword
                         "\nWhat to do [Show all/hide SElected/hide & Exclude selected] <Cancel> : "
                         );_ end of GETKWORD
                      );_ end of setq
                );_ end of lambda
             );_ end of vl-catch-all-apply
           );_ end of vl-catch-all-error-p
         );_ end of not
     (kpblc-objects-hide (atoi answer))
     );_ end of if
  );_ end of defun

;============================================================================================================================================================

);end progn
); end if