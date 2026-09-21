CLASS ycl_spwf_carr_lib DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_workflow.

    CLASS-EVENTS start_carr_Wf
        EXPORTING VALUE(carrier) TYPE yspwf_s_carrier.

    CLASS-METHODS register_new_wf
      IMPORTING wi_id       TYPE sww_wiid
                carrier     TYPE yspwf_s_carrier
                initiator   TYPE swp_initia
      EXPORTING first_agent TYPE swp_agent.

    CLASS-METHODS register_approval
      IMPORTING wi_id              TYPE sww_wiid
                posnr              TYPE posnr
      EXPORTING has_more_approvers TYPE abap_bool
                next_posnr         TYPE posnr
                next_agent         TYPE swp_Agent.

    CLASS-METHODS register_rejection
      IMPORTING wi_id TYPE sww_wiid
                posnr TYPE posnr.

    CLASS-METHODS finalize IMPORTING wi_id TYPE sww_wiid.

ENDCLASS.



CLASS ycl_spwf_carr_lib IMPLEMENTATION.
  METHOD register_new_Wf.
    DATA db_decisions TYPE SORTED TABLE OF yspwf_t_Cadec WITH UNIQUE KEY wi_id posnr.

    " Cleanup
    CLEAR first_agent.

    " Create DB records
    DATA(db_request) = VALUE yspwf_t_careq( wi_id = wi_id
                                            ernam = initiator+2(12) " USDEVELOPER -> DEVELOPER
                                            erdat = Sy-datum
                                            erzet = sy-uzeit ).

    MOVE-CORRESPONDING carrier TO db_request.

    SELECT FROM yspwf_t_caprv
      FIELDS @wi_id   AS wi_id,
             posnr,
             approver
      ORDER BY posnr
      INTO CORRESPONDING FIELDS OF TABLE @db_decisions.

    INSERT yspwf_t_Careq FROM db_request.
    INSERT yspwf_t_cadec FROM TABLE db_decisions.
    COMMIT WORK AND WAIT.

    " Return the first approver
    first_agent = |US{ db_decisions[ 1 ]-approver }|.
  ENDMETHOD.

  METHOD register_approval.
    " Clear
    CLEAR: has_more_approvers,
           next_posnr,
           next_Agent.

    " Set this decision
    UPDATE yspwf_t_cadec
        SET decision = 'A',
            aenam = @sy-uname,
            aedat = @sy-datum,
            aezet = @sy-uzeit
        WHERE wi_id = @wi_id
          AND posnr = @posnr.

    COMMIT WORK AND WAIT.

    " Tell about next decision
    next_posnr = posnr + 1.

    SELECT SINGLE FROM yspwf_t_cadec
      FIELDS approver
      WHERE wi_id = @wi_id
        AND posnr = @next_posnr
      INTO @DATA(next_approver).

    IF sy-subrc = 0.
      has_more_approvers = abap_true.
      next_agent = |US{ next_approver }|.
    ENDIF.
  ENDMETHOD.

  METHOD register_rejection.
    " Set this decision
    UPDATE yspwf_t_cadec
        SET decision = 'R',
            aenam = @sy-uname,
            aedat = @sy-datum,
            aezet = @sy-uzeit
        WHERE wi_id = @wi_id
          AND posnr = @posnr.

    COMMIT WORK AND WAIT.
  ENDMETHOD.

  METHOD finalize.
    " Handle rejection
    SELECT SINGLE FROM yspwf_t_cadec
      FIELDS @abap_true
      WHERE wi_id    = @wi_id
        AND decision = 'R'
      INTO @DATA(is_rejected).

    IF is_rejected = abap_true.
      " Send e-mail or something
      RETURN.
    ENDIF.

    " Handle approval
    SELECT SINGLE FROM yspwf_t_careq
      FIELDS *
      WHERE wi_id = @wi_id
      INTO @DATA(req_carrier).

    DATA(db_carrier) = CORRESPONDING scarr( req_carrier ).
    INSERT scarr FROM @db_carrier.
    COMMIT WORK AND WAIT.
  ENDMETHOD.

  METHOD bi_object~default_attribute_value.

  ENDMETHOD.

  METHOD bi_object~execute_default_method.

  ENDMETHOD.

  METHOD bi_persistent~find_by_lpor.

  ENDMETHOD.

  METHOD bi_persistent~lpor.

  ENDMETHOD.

  METHOD bi_persistent~refresh.

  ENDMETHOD.

  METHOD bi_object~release.

  ENDMETHOD.

ENDCLASS.
