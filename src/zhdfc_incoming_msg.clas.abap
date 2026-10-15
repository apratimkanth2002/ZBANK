CLASS zhdfc_incoming_msg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun,
                if_apj_dt_exec_object,
                if_apj_rt_exec_object.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS:
               gc_cpi_url_so TYPE string VALUE
               'https://sona-dev-3eio9v2r.it-cpi021-rt.cfapps.in30.hana.ondemand.com/http/incomingInvoice_Whatsapp'
                .

    METHODS:
        insert_sample_data
        RAISING cx_static_check.

   METHODS:

      send_to_cpi
        IMPORTING iv_payload      TYPE string
        RETURNING VALUE(rv_status) TYPE i.



ENDCLASS.



CLASS ZHDFC_INCOMING_MSG IMPLEMENTATION.


  METHOD send_to_cpi.



  ENDMETHOD.


METHOD insert_sample_data.

DATA(lv_cloud_date) = cl_abap_context_info=>get_system_date( ).


 SHIFT lv_cloud_date LEFT DELETING LEADING '0'  .

 DATa(kdt) = |{ lv_cloud_date+0(2) }| .


  SELECT * FROM zdt_bank_intg   into TABLE @data(it).
  SELECT * FROM zdt_bank_intg_c into TABLE @data(it_copy).
  SELECT * FROM zdt_bank_intg_c into TABLE @data(it_copy_n).
  data:wa_copy_n type zdt_bank_intg_c.





*data: rv_json type string.



  LOOP AT it INTO data(wa) .

  READ TABLE it_copy into data(wa_copy)  WITH KEY virtualaccount = wa-virtualaccount
                                                  remarks = wa-remarks
                                                  utr     = wa-utr
                                                  fromaccountnumber = wa-fromaccountnumber
                                                  remitterifsc  = wa-remitterifsc.




 if sy-subrc <> 0 .
DATA cust TYPE char10.

DATA(lv_result) = wa-virtualaccount+6(*).

DATA(c1) = CONV char10( lv_result ).
CONDENSE c1 NO-GAPS.
shift c1 LEFT DELETING LEADING ' ' .

cust = |{ c1 ALPHA = IN }|.






 SELECT SINGLE * FROM I_Customer WHERE Customer = @cust INTO @data(ph) .

 if ph-TelephoneNumber1 <> '' .
 data(tel) = ph-TelephoneNumber1 .
 ELSEIF ph-TelephoneNumber2 <> '' .
 tel = ph-TelephoneNumber2 .


 endif.


  data(rv_json) = |\{| &&
      |"UTR":"{ wa-utr }",| &&
      |"ValueDate":"{ wa-valuedate }",| &&
      |"CustomerName":"{ wa-remittername }",| &&
      |"Amt":"{ wa-amount }",| &&
      |"creationDate":"{ wa-creditdatetime1 }", | &&
      |"PhoneNo1":"{ tel }"| &&
*      |"PhoneNo2":"{ lv_p2 }",| &&
*      |"PhoneNo3":"{ lv_p3 }",| &&
*      |"PhoneNo4":"{ lv_p4 }",| &&
*      |"PhoneNo5":"{ lv_p5 }",| &&
*      |"PhoneNo6":"{ lv_p6 }"| &&

      |\}|.


   data(iv_payload) = rv_json  .


     TRY.
        DATA(lo_dest)   = cl_http_destination_provider=>create_by_url( gc_cpi_url_so ).
        DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_req)    = lo_client->get_http_request( ).

        lo_req->set_authorization_basic(
          i_username = 'sb-2ebb3ed6-7f49-4052-9116-545a8822b16e!b37983|it-rt-sona-dev-3eio9v2r!b148'      " pull from destination/SECSTORE, don't hardcode
          i_password = '395d6919-d323-4730-a7d8-00376572a361$tokCb8L4xqxdCAFefFKrQnVOwW9aI1mNXdmyQyMI70g=' ).
        lo_req->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
        lo_req->set_text( iv_payload ).

        DATA(lo_resp) = lo_client->execute( if_web_http_client=>post ).
        data(rv_status1) = lo_resp->get_status( ).

        if rv_status1-code = '200' or rv_status1-code = '204'.
        wa_copy_n = wa.
        APPEND wa_copy_n to it_copy_n.


        MODIFY zdt_bank_intg_c FROM TABLE @it_copy_n .
        if sy-subrc = 0.
        commit WORK.
        endif.

        ENDIF.


        lo_client->close( ).

      CATCH cx_static_check INTO DATA(lx_error).

    ENDTRY.



   ENDIF.




   ENDLOOP.
   ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA: application_log           TYPE REF TO if_bali_log,
          application_log_free_text TYPE REF TO if_bali_free_text_setter.
   TRY.
   insert_sample_data( ).
application_log = cl_bali_log=>create_with_header(
                               header = cl_bali_header_setter=>create( object = 'XYZ' " Use your custom log object/subobject
                                                                       subobject = 'INSERT' ) ).
        application_log_free_text = cl_bali_free_text_setter=>create(
                                        severity = if_bali_constants=>c_severity_information " Or c_severity_success
                                        text     = 'Sample data inserted successfully.' ).

        application_log->add_item( item = application_log_free_text ).
        cl_bali_log_db=>get_instance( )->save_log(
            log                        = application_log
            assign_to_current_appl_job = abap_true  ).

      CATCH cx_root INTO DATA(lx_error).
      ENDTRY.

  ENDMETHOD.
ENDCLASS.
