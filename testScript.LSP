(if (not UpdateBlockPropertyTable)
  (progn
    (alert "\nPlease Load UpdateBlockPropertyTable.arx First")
    (arxload "UpdateBlockPropertyTable.arx")
  )
)  
;(setq lstData '(("none" "None" 0) ("TYPE 1" "Type 1" 1) ("TYPE 2" "Type 2" 2) ("TYPE 3" "Type 3" 3)))
 (setq lstData '(("none" "None" 0) ("AYPE 1" "Type 1" 1) ("BYPE 2" "Type 2" 2) ("CYPE 3" "Type 3" 3)))
(UpdateBlockPropertyTable "Cable2" lstData)