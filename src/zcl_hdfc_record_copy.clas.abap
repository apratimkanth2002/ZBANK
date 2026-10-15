CLASS zcl_hdfc_record_copy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HDFC_RECORD_COPY IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  SELECT * FROM zdt_bank_intg into TABLE @data(it) .
  if sy-subrc = 0.

  MODIFY zdt_bank_intg_c FROM TABLE @it.
  if sy-subrc = 0.
  COMMIT WORK .

  ENDIF.


  endif.



  ENDMETHOD.
ENDCLASS.
