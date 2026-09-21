REPORT yspwf_p_crt_carr_req.

tables yspwf_t_cadec.

parameters: p_carrid type yspwf_t_careq-carrid obligatory,
            p_carrnm type yspwf_t_careq-carrname obligatory,
            p_currcd type yspwf_t_careq-currcode obligatory,
            p_url type yspwf_t_careq-url.

START-OF-SELECTION.
  DATA(container) = cl_swf_evt_event=>get_event_container( im_objcateg = 'CL'
                                                           im_objtype  = 'YCL_SPWF_CARR_LIB'
                                                           im_event    = 'START_CARR_WF' ).

  container->set( name  = 'CARRIER'
                  value = VALUE yspwf_s_carrier( carrid   = p_carrid
                                                 carrname = p_carrnm
                                                 currcode = p_currcd
                                                 url      = p_url ) ).

  cl_swf_evt_event=>raise( im_objcateg        = 'CL'
                           im_objtype         = 'YCL_SPWF_CARR_LIB'
                           im_event           = 'START_CARR_WF'
                           im_objkey          = p_carrid
                           im_event_container = container ).

  COMMIT WORK AND WAIT.
