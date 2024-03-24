; *** 01 ***
;Utility function for getting ACAD_EVALUATION_GRAPH dictionary from the block editor space
;List of dotted pairs and DXF codes is being written to EVAL_GRAPH variable
; 11.02.10
(defun eval_graf_output (/ BLK_RECORD DICTIONARY point) 
	(if (= (getvar "BLOCKEDITOR") 0)
		(progn
			(setq lst (entget (TBLOBJNAME "block" (vla-get-EffectiveName (vlax-ename->vla-object (car (entsel "Specify the block you need"))))) '("*")))
			(setq aa (cdr (assoc 330 lst)))
      (setq entL (entget(cdr (assoc 360 (entget aa)))))
			(setq entL (member '(3 . "ACAD_ENHANCEDBLOCK") entL))
			(setq EVAL_GRAPH (entget (cdr(assoc 360 entL))))

		;	(setq EVAL_GRAPH (entget (car (setq lst_dict (mapcar 'cdr (vl-remove-if-not '(lambda(x) (= (car x) 360)) (entget (cdr (assoc 360 (entget aa))))))))))
		)
		(progn
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
		)
	)	
);end of eval_graf_output function

;===========================================================================================================================================================
(defun C:ListBLOCKPROPERTIESTABLE (/ object-load listprop BLC-TBL-PAR entL del1010 del1071)
	;Getting ACAD_EVALUATION_GRAPH dictionary
	(eval_graf_output)
	;Switching off all the selections in the block editor space
	(sssetfirst nil nil)
	;Getting pointer of the selected Visibility Set
	(setq listProp "Block Table")
	(mapcar '(lambda (x) 
	  (if (and (= (car x) 360)(= (cdr (assoc 0 (entget (cdr x)))) "BLOCKPROPERTIESTABLE" ))
	     (if (= (cdr (assoc 300 (entget (cdr x)))) listprop)
	        (setq BLC-TBL-PAR (cdr x))))) EVAL_GRAPH)

		(setq BLC-TBL-PAR (entget BLC-TBL-PAR))
		;  (princ(member '(170 . 1) BLC-TBL-PAR))
	  ;(princ(member (assoc 91 BLC-TBL-PAR) BLC-TBL-PAR))
	(while (assoc 302 BLC-TBL-PAR)
	  (setq  BLC-TBL-PAR (cdr (member (assoc 302 BLC-TBL-PAR) BLC-TBL-PAR)))
	)
	(princ "\nNumber of Columns")
	(setq iLen (cdr(assoc 90 BLC-TBL-PAR)))
  (while (member '(90 . 0) BLC-TBL-PAR)
	  (setq  BLC-TBL-PAR (cdr (member '(90 . 0) BLC-TBL-PAR)))
	)
	(setq iLen (* 2 iLen)
				lst '()
	)
	(while BLC-TBL-PAR
		(setq i 1
					row '()
		)
		(while (< i iLen)
		  (setq row (append row (list  (cdr(nth i BLC-TBL-PAR)))))
			(setq i (+ i 2))
		)
		(if (member (assoc 90 BLC-TBL-PAR) BLC-TBL-PAR)
	    (setq  BLC-TBL-PAR (cdr (member (assoc 90 BLC-TBL-PAR) BLC-TBL-PAR)))
			(setq  BLC-TBL-PAR nil)
  	)
		(setq lst (append lst (list row)))	
	)	
);end


;===========================================================================================================================================================
(defun C:UpdBLOCKPROPERTIESTABLE (/ object-load listprop BLC-TBL-PAR entL del1010 del1071)
	;Getting ACAD_EVALUATION_GRAPH dictionary
	(eval_graf_output)
	;Switching off all the selections in the block editor space
	(sssetfirst nil nil)
	;Getting pointer of the selected Visibility Set
	(setq listProp "Block Table")
	(mapcar '(lambda (x) 
	  (if (and (= (car x) 360)(= (cdr (assoc 0 (entget (cdr x)))) "BLOCKPROPERTIESTABLE" ))
	     (if (= (cdr (assoc 300 (entget (cdr x)))) listprop)
	        (setq BLC-TBL-PAR (cdr x))))) EVAL_GRAPH)

		(setq BLC-TBL-PAR (entget BLC-TBL-PAR))
  (setq entL (reverse BLC-TBL-PAR))
  (setq entL (subst (cons 300 "bb") (assoc 300 entL) entL))
	(setq entL (reverse entL))
;;;	(setq del90 (assoc 90 entL))
;;;	(setq entL (vl-remove del90 entL))
;;;	(setq del90 (assoc 90 entL))
;;;	(setq entL (vl-remove del90 entL))
;;;	(setq del90 (assoc 90 entL))
;;;	(setq entL (vl-remove del90 entL))
;;;  (setq del90 (assoc 90 entL))
;;;	(setq entL (vl-remove del90 entL))
;;;	(setq del90 (assoc 90 entL))
;;;	(setq entL (vl-remove del90 entL))
;;;	(setq del90 (assoc 90 entL))
;;;	(setq entL (vl-remove del90 entL))
;;;	(setq del92 (assoc 92 entL))
;;;	(setq entL (vl-remove del92 entL))
;;;	
;;;	(setq del91 (assoc 91 entL))
;;;	(setq entL (vl-remove del91 entL))
;;;	(setq del91 (assoc 91 entL))
;;;	(setq entL (vl-remove del91 entL))
;;;	(setq del93 (assoc 93 entL))
;;;	(setq entL (vl-remove del93 entL))
;;;	(setq del93 (assoc 93 entL))
;;;	(setq entL (vl-remove del93 entL))
;;;	(setq del93 (assoc 93 entL))
;;;	(setq entL (vl-remove del93 entL))
;;;	
;;;  (setq del98 (assoc 98 entL))
;;;	(setq entL (vl-remove del98 entL))
;;;	(setq del99 (assoc 99 entL))
;;;	(setq entL (vl-remove del99 entL))
;;;	(setq del99 (assoc 99 entL))
;;;	(setq entL (vl-remove del99 entL))
;;;  (setq del99 (assoc 99 entL))
;;;	(setq entL (vl-remove del99 entL))
;;;	  at Autodesk.AutoCAD.DatabaseServices.BlockPropertiesTableRow.set_Item(Int32 columnIndex, ResultBuffer value)
;;;   at Autodesk.AutoCAD.AuthoringEnvironment.BlockPropertiesTableDialog.mMainGrid_CellParsing(Object sender, DataGridViewCellParsingEventArgs e)
;;;   at System.Windows.Forms.DataGridView.OnCellParsing(DataGridViewCellParsingEventArgs e)
;;;   at System.Windows.Forms.DataGridView.PushFormattedValue(DataGridViewCell& dataGridViewCurrentCell, Object formattedValue, Exception& exception)
;;;   at System.Windows.Forms.DataGridView.CommitEdit(DataGridViewCell& dataGridViewCurrentCell, DataGridViewDataErrorContexts context, DataGridViewValidateCellInternal validateCell, Boolean fireCellLeave, Boolean fireCellEnter, Boolean fireRowLeave, Boolean fireRowEnter, Boolean fireLeave)
;;;   at System.Windows.Forms.DataGridView.EndEdit(DataGridViewDataErrorContexts context, DataGridViewValidateCellInternal validateCell, Boolean fireCellLeave, Boolean fireCellEnter, Boolean fireRowLeave, Boolean fireRowEnter, Boolean fireLeave, Boolean keepFocus, Boolean resetCurrentCell, Boolean resetAnchorCell)
;;;   at System.Windows.Forms.DataGridView.OnValidating(CancelEventArgs e)
;;;   at System.Windows.Forms.Control.NotifyValidating()
;;;   at System.Windows.Forms.Control.PerformControlValidation(Boolean bulkValidation)
;;;   at System.Windows.Forms.ContainerControl.ValidateThroughAncestor(Control ancestorControl, Boolean preventFocusChangeOnError)
;;;   at System.Windows.Forms.ContainerControl.UpdateFocusedControl()
;;;   at System.Windows.Forms.ContainerControl.AssignActiveControlInternal(Control value)
;;;   at System.Windows.Forms.ContainerControl.ActivateControlInternal(Control control, Boolean originator)
;;;   at System.Windows.Forms.Control.WmSetFocus(Message& m)
;;;   at System.Windows.Forms.Control.WndProc(Message& m)
;;;   at System.Windows.Forms.ButtonBase.WndProc(Message& m)
;;;   at System.Windows.Forms.Button.WndProc(Message& m)
;;;   at System.Windows.Forms.NativeWindow.Callback(IntPtr hWnd, Int32 msg, IntPtr wparam, IntPtr lparam)
;;;
;;;
;;;************** Loaded Assemblies **************
;;;mscorlib
;;;    A

	(UpdateBlockPropertyTable "aaa" '(("aa" "bb")))
	(UpdateBlockPropertyTable "aa" '(("a" "b")))
	(UpdateBlockPropertyTable "aa" '(("a" "b")("c" "d")))
	
  ;Removing dotted pairs 1010 and 1071
	(setq del1010 (assoc 1010 entL));=double presission floating point but a point is stored
	;(setq entL (vl-remove del1010 entL))
	(setq del1071 (assoc 1071 entL));=32 bit integer = 0
	;(setq entL (subst '((1071 . 0.0)) '(1071 . 1.0) entL))
	;(setq entL (vl-remove del1071 entL))
	;(setq entL (append entL '((1071 . 0.0))))
	;(vla-
  (entmod entL);<========================================================HELP
	(entupd (cdr (car entL)))
 
	;Saving block
	(if (= (getvar "BLOCKEDITOR") 1)(command "_.BSAVE"))
);end Visibility_clear


(defun C:UpdBLOCKLOOKUPACTION (/ object-load listprop BLC-TBL-PAR entL del1010 del1071)
	;Getting ACAD_EVALUATION_GRAPH dictionary
	(eval_graf_output)
	;Switching off all the selections in the block editor space
	(sssetfirst nil nil)
	;Getting pointer of the selected Visibility Set
	(setq listProp "*")
	(mapcar '(lambda (x) 
	  (if (and (= (car x) 360)(= (cdr (assoc 0 (entget (cdr x)))) "BLOCKLOOKUPACTION"  ))
	     (if (wcmatch (cdr (assoc 300 (entget (cdr x)))) listprop)
	        (setq BLC-TBL-PAR (cdr x))))) EVAL_GRAPH)
	
  
	(setq BLC-TBL-PAR (entget BLC-TBL-PAR))
  (setq entL (reverse BLC-TBL-PAR))
  (setq entL (subst (cons 302 "bb") (assoc 302 entL) entL))
	(setq entL (reverse entL))
  ;Removing dotted pairs 1010 and 1071
	(setq del1010 (assoc 1010 entL))
	(setq entL (vl-remove del1010 entL))
	(setq del1071 (assoc 1071 entL))
	(setq entL (vl-remove del1071 entL))

  (entmod entL);<========================================================HELP
	(entupd (cdr (car entL)))
 
	;Saving block
  (if (= (getvar "BLOCKEDITOR") 1)(command "_.BSAVE"))
);end Visibility_clear