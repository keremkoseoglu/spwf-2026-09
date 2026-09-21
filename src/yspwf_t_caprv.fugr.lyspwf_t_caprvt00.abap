*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: YSPWF_T_CAPRV...................................*
DATA:  BEGIN OF STATUS_YSPWF_T_CAPRV                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_YSPWF_T_CAPRV                 .
CONTROLS: TCTRL_YSPWF_T_CAPRV
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *YSPWF_T_CAPRV                 .
TABLES: YSPWF_T_CAPRV                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
