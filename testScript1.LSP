(if (not UpdateBlockPropertyTable)
  (progn
    (alert "\nPlease Load UpdateBlockPropertyTable.arx First")
    (arxload "UpdateBlockPropertyTable.arx")
  )
)  
;(setq lstData '(("none" "None" 0) ("1YPE 1" "Type 1" 1) ("TYPE 2" "Type 2" 2) ("TYPE 3" "Type 3" 3)))
 (setq lstData '(("none" "None" 0) ("1YPE 1" "Type 1" 1) ("1YPE 2" "Type 2" 2) ("1YPE 3" "Type 3" 3)))
(UpdateBlockPropertyTable "Cable2" lstData)